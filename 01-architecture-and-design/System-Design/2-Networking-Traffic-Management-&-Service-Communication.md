# Part 2 – Networking, Traffic Management & Service Communication

In Part 1 we learned the vocabulary of scale and traced a request at a high level. Now we zoom into the path that request actually travels and the machinery that keeps millions of concurrent users from overwhelming any single component.

By the end of this part you will be able to answer the practical question:  
“How do we safely accept, distribute, protect, and route traffic when the same endpoint is hit by a flood of clients?”

---

### 2.1 Load Balancing Strategies (L4 vs L7, Round-Robin, Least Connections, Consistent Hashing)

**The Target**  
Understand the different ways a load balancer chooses which backend server receives the next request, and know when to use Layer-4 versus Layer-7 balancing.

**The Concept**  
A load balancer is the traffic cop standing in front of a row of identical cashiers (app servers).

- **Layer-4 (L4)** – looks only at IP addresses and ports (the “street address”). Fast, cheap, knows nothing about HTTP.  
- **Layer-7 (L7)** – understands HTTP headers, URLs, cookies, etc. Can route `/api/users` to one pool and `/api/payments` to another, or stick a user to the same server based on a cookie.

Common selection algorithms:

| Algorithm            | How it works                                      | Best when…                          |
|----------------------|---------------------------------------------------|-------------------------------------|
| Round-robin          | Next server in the list, cycling forever          | Servers are roughly equal           |
| Least connections    | Server that currently has the fewest open connections | Requests have very different durations |
| Consistent hashing   | Hash(request key) → server; minimal reshuffling when servers are added/removed | Sticky sessions or cache locality needed |

**The Implementation**  
A pure-Python simulation that lets you watch the three algorithms side-by-side.

```python
# file: part2/load_balancer_sim.py
from collections import defaultdict
import hashlib
import itertools
import random
from typing import List, Dict

class Server:
    def __init__(self, name: str):
        self.name = name
        self.active_connections = 0
        self.total_requests = 0

    def handle(self, request_id: str):
        self.active_connections += 1
        self.total_requests += 1
        # Simulate variable work
        work = random.uniform(0.01, 0.05)
        self.active_connections -= 1
        return work

class LoadBalancer:
    def __init__(self, servers: List[Server], algorithm: str = "round_robin"):
        self.servers = servers
        self.algorithm = algorithm
        self._rr_cycle = itertools.cycle(servers)
        self._hash_ring: Dict[int, Server] = {}
        if algorithm == "consistent_hash":
            self._build_hash_ring()

    def _build_hash_ring(self, virtual_nodes: int = 100):
        self._hash_ring.clear()
        for server in self.servers:
            for i in range(virtual_nodes):
                key = hashlib.md5(f"{server.name}-{i}".encode()).hexdigest()
                self._hash_ring[int(key, 16)] = server
        self._sorted_keys = sorted(self._hash_ring.keys())

    def _consistent_hash(self, request_key: str) -> Server:
        h = int(hashlib.md5(request_key.encode()).hexdigest(), 16)
        # Find first point on the ring clockwise
        for key in self._sorted_keys:
            if key >= h:
                return self._hash_ring[key]
        return self._hash_ring[self._sorted_keys[0]]

    def choose(self, request_key: str = "") -> Server:
        if self.algorithm == "round_robin":
            return next(self._rr_cycle)
        elif self.algorithm == "least_connections":
            return min(self.servers, key=lambda s: s.active_connections)
        elif self.algorithm == "consistent_hash":
            return self._consistent_hash(request_key)
        raise ValueError(f"Unknown algorithm: {self.algorithm}")

def run_simulation(algorithm: str, num_requests: int = 1000):
    servers = [Server(f"s{i}") for i in range(4)]
    lb = LoadBalancer(servers, algorithm)

    for i in range(num_requests):
        # For consistent hashing we pretend the request belongs to a user
        key = f"user-{i % 50}" if algorithm == "consistent_hash" else ""
        server = lb.choose(key)
        server.handle(str(i))

    print(f"\n=== {algorithm.upper()} ===")
    for s in servers:
        print(f"{s.name}: {s.total_requests:4d} requests")

if __name__ == "__main__":
    for algo in ["round_robin", "least_connections", "consistent_hash"]:
        run_simulation(algo)
```

**The Verification**  
```bash
cd part2
python load_balancer_sim.py
```
You will see round-robin and least-connections distribute fairly evenly. Consistent hashing keeps the same “users” on the same servers (important later for cache locality and sticky sessions).

---

### 2.2 API Gateways, Edge Routing, Rate Limiting, SSL Termination, Circuit Breaking

**The Target**  
Learn the responsibilities that sit at the very edge of the system before traffic ever reaches an application server.

**The Concept**  
An **API Gateway** is the smart front door. It usually performs:

- **SSL/TLS termination** – decrypts HTTPS so internal services can speak plain HTTP (or mTLS).  
- **Routing** – sends `/v1/users` to the user service, `/v1/orders` to the order service.  
- **Rate limiting** – protects backends from abusive or runaway clients.  
- **Authentication / authorization** – verifies JWTs or API keys once, then forwards identity.  
- **Circuit breaking** – stops sending traffic to a backend that is already failing (fail fast).

**Rate limiting analogy**  
A nightclub bouncer who lets only N people in per minute. Two classic algorithms:

- **Token bucket** – tokens are added at a steady rate; each request costs one token.  
- **Sliding window** – counts requests in the last N seconds.

**Circuit breaker analogy**  
A home circuit breaker that trips when too much current flows, protecting the rest of the house. States: Closed (normal) → Open (failing, reject immediately) → Half-Open (try one request).

**The Implementation**  
A minimal but complete token-bucket rate limiter and a circuit breaker you can drop into any service.

```python
# file: part2/edge_components.py
import time
import threading
from collections import deque
from enum import Enum, auto

class TokenBucket:
    """Thread-safe token-bucket rate limiter."""
    def __init__(self, rate: float, capacity: int):
        self.rate = rate          # tokens per second
        self.capacity = capacity
        self.tokens = capacity
        self.last_refill = time.monotonic()
        self.lock = threading.Lock()

    def allow(self) -> bool:
        with self.lock:
            now = time.monotonic()
            elapsed = now - self.last_refill
            self.tokens = min(self.capacity, self.tokens + elapsed * self.rate)
            self.last_refill = now
            if self.tokens >= 1:
                self.tokens -= 1
                return True
            return False

class CircuitState(Enum):
    CLOSED = auto()
    OPEN = auto()
    HALF_OPEN = auto()

class CircuitBreaker:
    def __init__(self, failure_threshold: int = 5, recovery_timeout: float = 30.0):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failure_count = 0
        self.state = CircuitState.CLOSED
        self.last_failure_time = 0.0
        self.lock = threading.Lock()

    def call(self, func, *args, **kwargs):
        with self.lock:
            if self.state == CircuitState.OPEN:
                if time.monotonic() - self.last_failure_time > self.recovery_timeout:
                    self.state = CircuitState.HALF_OPEN
                else:
                    raise Exception("Circuit is OPEN – request rejected")

        try:
            result = func(*args, **kwargs)
            with self.lock:
                self.failure_count = 0
                self.state = CircuitState.CLOSED
            return result
        except Exception as e:
            with self.lock:
                self.failure_count += 1
                self.last_failure_time = time.monotonic()
                if self.failure_count >= self.failure_threshold:
                    self.state = CircuitState.OPEN
            raise e

# --- Demo ---
if __name__ == "__main__":
    limiter = TokenBucket(rate=5, capacity=10)  # 5 req/s, burst 10
    allowed = sum(1 for _ in range(20) if limiter.allow())
    print(f"Token bucket allowed {allowed}/20 requests (expected ~10-15)")

    cb = CircuitBreaker(failure_threshold=3, recovery_timeout=2)

    def flaky():
        if random.random() < 0.7:
            raise Exception("backend error")
        return "ok"

    import random
    for i in range(15):
        try:
            print(i, cb.call(flaky))
        except Exception as e:
            print(i, type(e).__name__, str(e)[:40])
        time.sleep(0.3)
```

**The Verification**  
```bash
python edge_components.py
```
You should see the token bucket reject excess requests and the circuit breaker open after consecutive failures, then attempt recovery.

---

### 2.3 DNS and CDNs for Static vs Dynamic Content

**The Target**  
Know what happens at the very first hop (DNS) and how a CDN changes the performance profile of static versus dynamic content.

**The Concept**  
- **DNS** is the distributed phone book. A client asks “What is the IP of `api.example.com`?” and receives an answer that may be cached for minutes or hours (TTL).  
- **CDN** is a global network of cache servers. Static assets (JS, CSS, images, videos) are copied to many edge locations so a user in Tokyo does not pull them from a server in Virginia.

Dynamic content (personalized HTML, API responses) usually bypasses or only partially uses the CDN unless you deliberately cache it with short TTLs or surrogate keys.

**Practical rule of thumb**  
| Content type       | Typical caching strategy          | Who serves it          |
|--------------------|-----------------------------------|------------------------|
| JS / CSS / images  | Long TTL + cache-busting hashes   | CDN edge               |
| Public API responses | Short TTL or no cache           | Origin / regional cache |
| Personalized pages | No shared cache                   | Origin only            |

**The Implementation**  
No code required here—this is pure infrastructure. Instead, a concrete checklist you can apply to any project:

```text
1. Put all static assets under a dedicated domain or path (static.example.com or /static/).
2. Give them a content-hash filename (app.a1b2c3d4.js) so you can set Cache-Control: max-age=31536000.
3. Configure the CDN to respect origin Cache-Control headers.
4. For API responses that can be cached, set short max-age and use Vary: Authorization or surrogate keys.
5. Keep DNS TTL for the apex domain relatively low (60–300 s) so you can change load-balancer IPs quickly.
```

**The Verification**  
Open Chrome DevTools → Network, reload a major site, and filter by “Img”, “JS”, “CSS”. Look at the “Remote Address” and “Cache-Control” / “Age” headers. You will see most static files coming from a CDN edge with long cache lifetimes.

---

### 2.4 Synchronous vs Asynchronous Communication

**The Target**  
Choose the right communication style between services: HTTP/REST, gRPC, WebSockets, or message queues.

**The Concept**  

| Style              | Analogy                              | When to use                              | Trade-offs                          |
|--------------------|--------------------------------------|------------------------------------------|-------------------------------------|
| HTTP/REST          | Phone call – wait for answer         | Simple CRUD, public APIs                 | Easy, but chatty & higher latency   |
| gRPC               | Phone call with a strict script      | Internal service-to-service, low latency | Needs schema, HTTP/2, codegen       |
| WebSockets         | Walkie-talkie left open              | Real-time updates (chat, dashboards)     | Stateful, harder to load-balance    |
| Message queue      | Leave a note in a shared inbox       | Work that can be done later, fan-out     | Eventual consistency, more moving parts |

**Synchronous** (REST/gRPC) = the caller blocks until the callee answers.  
**Asynchronous** (queues/pub-sub) = the caller drops a message and continues; another worker processes it later.

**The Implementation**  
A side-by-side illustration of a synchronous REST-style call versus an asynchronous queue-style hand-off (using the standard library only).

```python
# file: part2/sync_vs_async.py
import time
import queue
import threading
from dataclasses import dataclass

@dataclass
class Order:
    id: str
    amount: float

# ---------- Synchronous style ----------
def process_payment_sync(order: Order) -> str:
    time.sleep(0.2)          # pretend network + DB work
    return f"paid-{order.id}"

def place_order_sync(order: Order):
    print(f"[sync] placing {order.id}")
    result = process_payment_sync(order)
    print(f"[sync] done → {result}")

# ---------- Asynchronous style ----------
payment_queue: queue.Queue = queue.Queue()

def payment_worker():
    while True:
        order = payment_queue.get()
        if order is None:
            break
        time.sleep(0.2)
        print(f"[async] paid-{order.id}")
        payment_queue.task_done()

def place_order_async(order: Order):
    print(f"[async] placing {order.id}")
    payment_queue.put(order)
    # caller returns immediately

if __name__ == "__main__":
    # Start background worker
    worker = threading.Thread(target=payment_worker, daemon=True)
    worker.start()

    orders = [Order(f"ord-{i}", 10.0 + i) for i in range(5)]

    print("=== Synchronous ===")
    start = time.perf_counter()
    for o in orders:
        place_order_sync(o)
    print(f"Total wall time: {time.perf_counter() - start:.2f}s\n")

    print("=== Asynchronous ===")
    start = time.perf_counter()
    for o in orders:
        place_order_async(o)
    payment_queue.join()          # wait for all work to finish
    print(f"Total wall time: {time.perf_counter() - start:.2f}s")

    payment_queue.put(None)       # stop worker
```

**The Verification**  
```bash
python sync_vs_async.py
```
Synchronous version takes roughly 5 × 0.2 s. Asynchronous version finishes the “place order” calls almost instantly and the work happens in the background—exactly the latency-versus-throughput trade-off you will exploit at scale.

---

### Reference Section – Decision Cheat-Sheet

| Question                                      | Prefer                          |
|-----------------------------------------------|---------------------------------|
| Public API used by browsers / mobile apps     | HTTP/REST + JSON                |
| Internal service calls that need low latency  | gRPC                            |
| Real-time bidirectional updates               | WebSockets (or SSE for one-way) |
| Work that can be delayed or retried           | Message queue / pub-sub         |
| Need to protect backends from overload        | Rate limiter + circuit breaker at gateway |
| Static assets                                 | CDN with long TTL               |
| Want minimal disruption when adding servers   | Consistent hashing              |
| Requests have very different durations        | Least-connections load balancing |

---

### What You Can Do Now

You can look at any service boundary and decide:

1. Should this hop be synchronous or asynchronous?  
2. Does the traffic need L7 awareness (path-based routing, header inspection) or is L4 enough?  
3. Where will you place rate limiting and circuit breaking so a single noisy client cannot take down the fleet?  
4. Which responses can safely be cached at the CDN versus which must always hit the origin?

These decisions are the everyday work of traffic management.
