# Part 5 – Scaling, Reliability & Fault Tolerance

Up to now we have focused on making a system correct and fast under normal conditions. Real systems, however, spend most of their life dealing with partial failures: machines die, networks partition, dependencies slow down, and traffic spikes. This part teaches you to design for those realities.

By the end you will be able to look at any component and answer: “What happens when this piece breaks, and how does the rest of the system survive?”

---

### 5.1 Horizontal Scaling, Consistent Hashing & Data Partitioning at Scale

**The Target**  
Revisit horizontal scaling with the concrete techniques that keep both compute and data balanced as the fleet grows.

**The Concept**  
Adding more machines is easy. Keeping the *work* and the *data* evenly distributed is harder.

- **Stateless compute** scales almost linearly once you have a load balancer.  
- **Stateful data** must be partitioned (sharded). The choice of partition key and the hashing scheme determine whether the system stays balanced when nodes are added or removed.

**Consistent hashing** (already introduced in Part 2) is the standard solution: it minimizes the fraction of keys that must move when the set of nodes changes.

**The Implementation**  
A more complete consistent-hashing ring that supports virtual nodes and node addition/removal—exactly the behavior you need in a real sharded cache or database.

```python
# file: part5/consistent_hash_ring.py
import hashlib
from sortedcontainers import SortedDict          # pip install sortedcontainers
from typing import List, Optional, Any

class ConsistentHashRing:
    def __init__(self, virtual_nodes: int = 100):
        self.virtual_nodes = virtual_nodes
        self.ring = SortedDict()                 # hash → node_name
        self.nodes = set()

    def _hash(self, key: str) -> int:
        return int(hashlib.md5(key.encode()).hexdigest(), 16)

    def add_node(self, node: str):
        if node in self.nodes:
            return
        self.nodes.add(node)
        for i in range(self.virtual_nodes):
            h = self._hash(f"{node}:{i}")
            self.ring[h] = node

    def remove_node(self, node: str):
        if node not in self.nodes:
            return
        self.nodes.discard(node)
        for i in range(self.virtual_nodes):
            h = self._hash(f"{node}:{i}")
            self.ring.pop(h, None)

    def get_node(self, key: str) -> Optional[str]:
        if not self.ring:
            return None
        h = self._hash(key)
        # Find the first point on the ring >= h
        idx = self.ring.bisect_left(h)
        if idx == len(self.ring):
            idx = 0
        return self.ring.peekitem(idx)[1]

    def distribution(self, keys: List[str]) -> dict:
        counts = {n: 0 for n in self.nodes}
        for k in keys:
            node = self.get_node(k)
            counts[node] += 1
        return counts

if __name__ == "__main__":
    ring = ConsistentHashRing(virtual_nodes=50)

    # Start with 3 nodes
    for n in ["node-a", "node-b", "node-c"]:
        ring.add_node(n)

    keys = [f"user:{i}" for i in range(1000)]
    print("Initial distribution:", ring.distribution(keys))

    # Add a fourth node – only a fraction of keys should move
    ring.add_node("node-d")
    print("After adding node-d:", ring.distribution(keys))

    # Remove a node
    ring.remove_node("node-b")
    print("After removing node-b:", ring.distribution(keys))
```

**The Verification**  
```bash
cd part5
pip install sortedcontainers
python consistent_hash_ring.py
```
You will see that adding or removing a node only redistributes a minority of the keys—exactly the property that makes consistent hashing practical at scale.

---

### 5.2 Redundancy, Failover, Bulkheads, Rate Limiting & Graceful Degradation

**The Target**  
Learn the core isolation and survival patterns that keep a system available when parts of it fail.

**The Concept**  

| Pattern                | Analogy                                      | Purpose |
|------------------------|----------------------------------------------|---------|
| Redundancy             | Two engines on an airplane                   | Survive the loss of one instance |
| Failover               | Automatic switch to the backup generator     | Detect failure and redirect traffic |
| Bulkhead               | Ship compartments that flood independently   | Limit the blast radius of a failure |
| Rate limiting          | Nightclub bouncer                            | Protect downstream services from overload |
| Graceful degradation   | Elevator that still works (slowly) when one motor fails | Keep core functionality alive under stress |

**Bulkhead example**  
If the “recommendation” service starts timing out, you do not want those slow calls to exhaust the thread pool of the “checkout” service. Separate thread pools, connection pools, or even separate process groups create the bulkheads.

**The Implementation**  
A practical bulkhead + graceful-degradation example using separate thread pools.

```python
# file: part5/bulkhead_degradation.py
from concurrent.futures import ThreadPoolExecutor, TimeoutError
import time
import random

class BulkheadedService:
    def __init__(self):
        # Separate pools = bulkheads
        self.checkout_pool = ThreadPoolExecutor(max_workers=4, thread_name_prefix="checkout")
        self.recommend_pool = ThreadPoolExecutor(max_workers=2, thread_name_prefix="recommend")

    def _checkout_work(self, order_id: str) -> str:
        time.sleep(0.05)
        return f"order-{order_id}-confirmed"

    def _recommend_work(self, user_id: str) -> list:
        # Simulate occasional slowness or failure
        if random.random() < 0.3:
            time.sleep(2.0)          # slow dependency
        else:
            time.sleep(0.1)
        return [f"item-{i}" for i in range(3)]

    def place_order(self, order_id: str, user_id: str) -> dict:
        # Critical path – always try to complete
        checkout_future = self.checkout_pool.submit(self._checkout_work, order_id)

        # Non-critical path – degrade gracefully
        recommendations = []
        try:
            rec_future = self.recommend_pool.submit(self._recommend_work, user_id)
            recommendations = rec_future.result(timeout=0.3)   # hard timeout
        except TimeoutError:
            recommendations = ["fallback-item"]               # graceful degradation
        except Exception:
            recommendations = []

        return {
            "order": checkout_future.result(),
            "recommendations": recommendations,
        }

if __name__ == "__main__":
    svc = BulkheadedService()
    for i in range(8):
        result = svc.place_order(f"ord-{i}", f"user-{i}")
        print(result)
```

**The Verification**  
```bash
python bulkhead_degradation.py
```
You will see that even when the recommendation path is slow or fails, the checkout path continues to succeed and the response still returns (with a fallback). That is bulkheading + graceful degradation in action.

---

### 5.3 Fault-Tolerance Patterns: Retries with Backoff, Idempotency, Circuit Breakers

**The Target**  
Implement the three patterns that turn transient failures into recoverable events instead of user-visible errors.

**The Concept**  

- **Retries with exponential backoff + jitter** – try again, but wait longer each time and add randomness so thundering herds do not form.  
- **Idempotency** – making the same request multiple times has the same effect as making it once (critical once you retry).  
- **Circuit breaker** – after repeated failures, stop calling the dependency for a while (already shown in Part 2; we now combine it with the others).

**The Implementation**  
A production-grade retry decorator with exponential backoff, jitter, and an idempotency key example.

```python
# file: part5/retries_idempotency.py
import time
import random
import functools
from typing import Callable, TypeVar, Any

T = TypeVar("T")

def retry_with_backoff(
    max_attempts: int = 5,
    base_delay: float = 0.1,
    max_delay: float = 2.0,
    exceptions: tuple = (Exception,),
):
    def decorator(func: Callable[..., T]) -> Callable[..., T]:
        @functools.wraps(func)
        def wrapper(*args, **kwargs) -> T:
            last_exc = None
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    last_exc = e
                    if attempt == max_attempts:
                        break
                    # Exponential backoff + full jitter
                    delay = min(max_delay, base_delay * (2 ** (attempt - 1)))
                    delay = random.uniform(0, delay)
                    print(f"  attempt {attempt} failed ({e}); retrying in {delay:.2f}s")
                    time.sleep(delay)
            raise last_exc
        return wrapper
    return decorator

# ---------- Idempotent payment example ----------
class PaymentGateway:
    def __init__(self):
        self.processed = set()          # pretend this is a durable store
        self.fail_count = 0

    def charge(self, idempotency_key: str, amount: float) -> str:
        # Simulate transient failures for the first few calls
        self.fail_count += 1
        if self.fail_count < 3:
            raise ConnectionError("temporary network glitch")

        if idempotency_key in self.processed:
            print(f"  (idempotent hit for {idempotency_key})")
            return f"already-charged-{idempotency_key}"

        self.processed.add(idempotency_key)
        return f"charged-{amount}-key-{idempotency_key}"

if __name__ == "__main__":
    gw = PaymentGateway()

    @retry_with_backoff(max_attempts=5, base_delay=0.05)
    def safe_charge(key: str, amount: float) -> str:
        return gw.charge(key, amount)

    print("First call (will retry through failures):")
    print("→", safe_charge("idem-abc-123", 49.99))

    print("\nSecond call with same key (should be idempotent):")
    print("→", safe_charge("idem-abc-123", 49.99))
```

**The Verification**  
```bash
python retries_idempotency.py
```
The first call fails a couple of times, backs off, then succeeds. The second call with the same idempotency key returns immediately without charging again.

---

### 5.4 Observability – Metrics, Logging, Tracing & Health Checks

**The Target**  
Instrument a system so that you can answer “Is it broken?” and “Why is it broken?” without SSH-ing into machines.

**The Concept**  
The three pillars of observability:

1. **Metrics** – numeric measurements over time (request rate, error rate, latency percentiles, queue depth).  
2. **Logs** – discrete events with context (structured JSON preferred).  
3. **Traces** – the path of a single request across multiple services (OpenTelemetry is the modern standard).

Plus **health checks** – simple endpoints that load balancers and orchestrators (Kubernetes, etc.) use to decide whether an instance is ready to receive traffic.

**The Implementation**  
A minimal but complete instrumentation example that records metrics, emits structured logs, and propagates a trace ID.

```python
# file: part5/observability_basics.py
import time
import uuid
import json
import threading
from collections import defaultdict
from contextlib import contextmanager
from typing import Optional

# ---------- Metrics (in-memory for illustration) ----------
class Metrics:
    def __init__(self):
        self.counters = defaultdict(int)
        self.timers = defaultdict(list)
        self._lock = threading.Lock()

    def inc(self, name: str, value: int = 1, **labels):
        key = (name, tuple(sorted(labels.items())))
        with self._lock:
            self.counters[key] += value

    def observe(self, name: str, value: float, **labels):
        key = (name, tuple(sorted(labels.items())))
        with self._lock:
            self.timers[key].append(value)

    def report(self):
        print("\n=== Metrics ===")
        for (name, labels), count in self.counters.items():
            print(f"  {name}{dict(labels)} = {count}")
        for (name, labels), values in self.timers.items():
            avg = sum(values) / len(values)
            p99 = sorted(values)[int(len(values) * 0.99)] if values else 0
            print(f"  {name}{dict(labels)} avg={avg:.3f}s p99={p99:.3f}s")

metrics = Metrics()

# ---------- Structured logging ----------
def log(level: str, msg: str, **fields):
    entry = {
        "ts": time.time(),
        "level": level,
        "msg": msg,
        **fields,
    }
    print(json.dumps(entry))

# ---------- Trace context ----------
_trace_local = threading.local()

def get_trace_id() -> str:
    return getattr(_trace_local, "trace_id", "no-trace")

@contextmanager
def start_span(name: str):
    parent = get_trace_id()
    trace_id = str(uuid.uuid4())[:8]
    _trace_local.trace_id = trace_id
    start = time.perf_counter()
    log("INFO", f"span start: {name}", trace_id=trace_id, parent=parent)
    try:
        yield
    finally:
        duration = time.perf_counter() - start
        metrics.observe("span_duration_seconds", duration, span=name)
        log("INFO", f"span end: {name}", trace_id=trace_id, duration_ms=round(duration * 1000, 1))
        _trace_local.trace_id = parent

# ---------- Health check ----------
class HealthChecker:
    def __init__(self):
        self.ready = True
        self.live = True

    def set_ready(self, value: bool):
        self.ready = value

    def status(self) -> dict:
        return {
            "live": self.live,
            "ready": self.ready,
        }

health = HealthChecker()

# ---------- Example instrumented handler ----------
def handle_request(user_id: str):
    with start_span("handle_request"):
        metrics.inc("requests_total", endpoint="order")
        log("INFO", "request received", user_id=user_id, trace_id=get_trace_id())

        with start_span("db_query"):
            time.sleep(0.05)          # pretend DB work

        with start_span("payment_call"):
            time.sleep(0.08)

        metrics.inc("requests_success", endpoint="order")
        return {"status": "ok"}

if __name__ == "__main__":
    for i in range(5):
        handle_request(f"user-{i}")

    metrics.report()
    print("\nHealth:", health.status())
```

**The Verification**  
```bash
python observability_basics.py
```
You will see structured JSON logs with trace IDs, nested spans, and a final metrics summary. In production these would be shipped to Prometheus, Grafana, Loki/ELK, Jaeger/Zipkin, etc.

---

### Reference Section – Failure-Mode Checklist

When reviewing any design, walk through this list:

1. **What happens if this instance disappears?** (redundancy + failover)  
2. **What happens if this dependency becomes slow?** (timeouts + circuit breaker + bulkhead)  
3. **What happens if this dependency returns errors?** (retries with backoff + idempotency)  
4. **What happens if traffic suddenly multiplies by 10×?** (rate limiting + auto-scaling + graceful degradation)  
5. **How will we know any of the above is happening?** (metrics, logs, traces, health checks)

If you cannot answer every question, the design is not yet production-ready.

---

### What You Can Do Now

You can look at any service or data store and systematically ask:

- How is the load distributed when we add or remove nodes?  
- What is the blast radius if this component fails?  
- Are all external calls protected by timeouts, retries, and circuit breakers?  
- Is every critical path observable with metrics, logs, and traces?  
- Can the system still deliver core value when non-critical dependencies are degraded?

These questions turn “hope it stays up” into deliberate reliability engineering.
