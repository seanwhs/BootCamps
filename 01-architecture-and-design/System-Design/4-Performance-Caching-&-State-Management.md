# Part 4 – Performance, Caching & State Management

Once you can store data correctly, the next pressure is speed. Users expect responses in tens of milliseconds even when the system is under heavy load. Caching and asynchronous processing are the two most powerful levers for achieving that.

By the end of this part you will know where to place caches, which caching pattern to choose, how to keep caches correct, and why making services stateless unlocks horizontal scaling.

---

### 4.1 Cache Placement – The Four Layers

**The Target**  
Understand the four common places a cache can live and the trade-offs of each.

**The Concept**  
Think of caching as keeping a photocopy of a frequently used document closer to the person who needs it.

| Layer              | Where it lives                          | Latency | Scope of sharing          | Typical data                     |
|--------------------|-----------------------------------------|---------|---------------------------|----------------------------------|
| Browser            | User’s device                           | Lowest  | Single user               | Static assets, some API responses |
| CDN / Edge         | Global edge nodes                       | Very low| Many users in a region    | Images, JS, CSS, public pages    |
| Application        | In-process or Redis next to app servers | Low     | All app servers           | User sessions, computed results, hot DB rows |
| Database           | Inside the DB engine (buffer pool) or query cache | Medium | All clients of that DB | Recently accessed pages / rows   |

The closer the cache is to the client, the lower the latency, but the harder it becomes to keep the data fresh and coherent.

**The Implementation**  
No new code yet—just a concrete decision checklist you will reuse:

```text
1. Can the data be public and identical for every user?
   → Prefer CDN / browser cache with long TTL + cache-busting hashes.

2. Is the data private or personalized?
   → Application-level cache (Redis) keyed by user_id or session_id.

3. Is the data expensive to compute but still changes occasionally?
   → Application cache with short TTL or explicit invalidation.

4. Is the data the result of a heavy SQL query that is repeated?
   → Consider a materialized view or Redis first; only then rely on the DB buffer pool.
```

**The Verification**  
Open DevTools on any large site → Network tab → look at the `Cache-Control`, `Age`, and `X-Cache` (or similar) headers. You will see browser and CDN caches in action for static assets and sometimes for public API responses.

---

### 4.2 Caching Patterns and Eviction Policies

**The Target**  
Master the four classic caching patterns and the two most common eviction policies.

**The Concept**  

**Patterns**

| Pattern         | How it works                                      | Pros                              | Cons                              |
|-----------------|---------------------------------------------------|-----------------------------------|-----------------------------------|
| Cache-aside     | App checks cache → on miss loads from DB → writes cache | Simple, cache only holds useful data | Extra round-trip on miss, possible stampede |
| Write-through   | App writes to cache *and* DB in the same request  | Cache always fresh                | Higher write latency              |
| Write-behind    | App writes to cache; cache asynchronously flushes to DB | Very fast writes                  | Risk of data loss on crash, more complexity |
| Read-through    | Cache itself knows how to load from DB on miss    | App code stays simple             | Cache becomes a dependency        |

**Eviction policies**

- **LRU (Least Recently Used)** – discard the item that has not been touched for the longest time.  
- **LFU (Least Frequently Used)** – discard the item that has been requested the fewest times.

**The Implementation**  
A complete, thread-safe cache-aside implementation with LRU eviction (the pattern you will use most often).

```python
# file: part4/cache_aside_lru.py
from collections import OrderedDict
import threading
import time
from typing import Any, Callable, Optional

class LRUCache:
    """Simple thread-safe LRU cache with TTL support."""
    def __init__(self, capacity: int = 100, default_ttl: float = 60.0):
        self.capacity = capacity
        self.default_ttl = default_ttl
        self._data: OrderedDict[str, tuple[Any, float]] = OrderedDict()  # key → (value, expiry)
        self._lock = threading.RLock()

    def get(self, key: str) -> Optional[Any]:
        with self._lock:
            if key not in self._data:
                return None
            value, expiry = self._data[key]
            if time.monotonic() > expiry:
                del self._data[key]
                return None
            # Move to end (most recently used)
            self._data.move_to_end(key)
            return value

    def set(self, key: str, value: Any, ttl: Optional[float] = None):
        with self._lock:
            if key in self._data:
                self._data.move_to_end(key)
            expiry = time.monotonic() + (ttl if ttl is not None else self.default_ttl)
            self._data[key] = (value, expiry)
            if len(self._data) > self.capacity:
                self._data.popitem(last=False)  # evict least recently used

    def delete(self, key: str):
        with self._lock:
            self._data.pop(key, None)

class CacheAsideStore:
    """Classic cache-aside pattern on top of an LRU cache."""
    def __init__(self, capacity: int = 100):
        self.cache = LRUCache(capacity=capacity)
        self.db: dict[str, Any] = {}          # fake database
        self.db_hits = 0
        self.cache_hits = 0

    def get(self, key: str) -> Optional[Any]:
        value = self.cache.get(key)
        if value is not None:
            self.cache_hits += 1
            return value
        # Cache miss → load from “DB”
        self.db_hits += 1
        value = self.db.get(key)
        if value is not None:
            self.cache.set(key, value)
        return value

    def set(self, key: str, value: Any):
        self.db[key] = value
        self.cache.set(key, value)            # write-through for simplicity

    def delete(self, key: str):
        self.db.pop(key, None)
        self.cache.delete(key)

if __name__ == "__main__":
    store = CacheAsideStore(capacity=3)

    # Populate
    for i in range(5):
        store.set(f"user:{i}", {"name": f"User{i}"})

    # Access pattern that demonstrates LRU
    print(store.get("user:0"))   # hit
    print(store.get("user:1"))   # hit
    print(store.get("user:2"))   # hit
    print(store.get("user:3"))   # miss → loads, may evict user:0
    print(store.get("user:0"))   # possible miss if evicted

    print(f"\nCache hits: {store.cache_hits}, DB hits: {store.db_hits}")
    print(f"Current cache size: {len(store.cache._data)}")
```

**The Verification**  
```bash
cd part4
python cache_aside_lru.py
```
You will see some cache hits, some DB hits, and the cache size never exceeding the configured capacity. Change the access order and watch which keys get evicted.

---

### 4.3 Asynchronous Processing – Event-Driven Architecture

**The Target**  
Move slow or non-critical work off the request path using queues and pub/sub.

**The Concept**  
When a user clicks “Place Order”, several things must happen:

1. Validate and create the order (must be synchronous).  
2. Charge the credit card (must be reliable).  
3. Send a confirmation email (can be asynchronous).  
4. Update recommendation models (can be asynchronous).  
5. Notify the warehouse (can be asynchronous).

Anything that does not need to finish before the user sees “Order confirmed” should be pushed to a message queue or pub/sub topic. This keeps the HTTP response fast and lets you scale the workers independently.

**Common brokers**  
- RabbitMQ – classic message queues, good routing.  
- Kafka / Pulsar – high-throughput, durable, ordered logs (excellent for event streaming).  
- Cloud equivalents – SQS, Pub/Sub, Service Bus, etc.

**The Implementation**  
A complete in-process simulation of a producer + multiple competing consumers (the pattern you will later replace with a real broker).

```python
# file: part4/async_workers.py
import queue
import threading
import time
import random
from dataclasses import dataclass
from typing import Callable

@dataclass
class Event:
    type: str
    payload: dict

class EventBus:
    """Minimal in-memory pub/sub + work queue."""
    def __init__(self):
        self._queues: dict[str, queue.Queue] = {}
        self._lock = threading.Lock()

    def subscribe(self, topic: str) -> queue.Queue:
        with self._lock:
            if topic not in self._queues:
                self._queues[topic] = queue.Queue()
            return self._queues[topic]

    def publish(self, topic: str, event: Event):
        with self._lock:
            q = self._queues.get(topic)
            if q:
                q.put(event)

def start_worker(name: str, topic: str, bus: EventBus, handler: Callable[[Event], None]):
    q = bus.subscribe(topic)

    def loop():
        while True:
            event = q.get()
            if event is None:          # shutdown signal
                break
            try:
                print(f"[{name}] processing {event.type}")
                handler(event)
            except Exception as e:
                print(f"[{name}] error: {e}")
            finally:
                q.task_done()

    t = threading.Thread(target=loop, daemon=True, name=name)
    t.start()
    return t

# ---------- Handlers ----------
def send_email(event: Event):
    time.sleep(random.uniform(0.1, 0.3))   # pretend SMTP
    print(f"  → email sent to {event.payload['email']}")

def update_analytics(event: Event):
    time.sleep(random.uniform(0.05, 0.15))
    print(f"  → analytics recorded for order {event.payload['order_id']}")

def notify_warehouse(event: Event):
    time.sleep(random.uniform(0.1, 0.25))
    print(f"  → warehouse notified for order {event.payload['order_id']}")

if __name__ == "__main__":
    bus = EventBus()

    # Start workers (in real life these would be separate processes/containers)
    start_worker("email-1", "order.placed", bus, send_email)
    start_worker("email-2", "order.placed", bus, send_email)   # competing consumer
    start_worker("analytics", "order.placed", bus, update_analytics)
    start_worker("warehouse", "order.placed", bus, notify_warehouse)

    # Simulate HTTP request handlers publishing events
    for i in range(5):
        event = Event(
            type="order.placed",
            payload={"order_id": f"ord-{100+i}", "email": f"user{i}@example.com"}
        )
        print(f"\n[API] Order placed → publishing event")
        bus.publish("order.placed", event)
        time.sleep(0.05)          # small gap between requests

    # Give workers time to finish
    time.sleep(2)
    print("\nAll done.")
```

**The Verification**  
```bash
python async_workers.py
```
You will see the API “requests” return almost immediately while the email, analytics, and warehouse work happens in the background, distributed across the workers.

---

### 4.4 Stateful vs Stateless Services

**The Target**  
Understand why making the application tier *stateless* is one of the highest-leverage decisions you can make for scaling and reliability.

**The Concept**  
- **Stateful service** – remembers client-specific data in memory (shopping cart, WebSocket connections, in-process sessions).  
  Problem: a particular user’s requests must keep hitting the same instance, and when that instance dies the state is lost or must be migrated.

- **Stateless service** – every request contains everything needed (or the state lives in an external store such as Redis or the database).  
  Benefit: any instance can handle any request. You can add or remove instances freely, and load balancers can distribute traffic without sticky sessions.

**Rule**  
Keep the application servers as close to pure functions as possible. Push all durable or shared state into external systems that are themselves designed for concurrency and durability.

**The Implementation**  
A side-by-side contrast of a stateful in-memory session store versus a stateless design that keeps sessions in an external cache.

```python
# file: part4/stateful_vs_stateless.py
import uuid
from typing import Dict, Any, Optional

# ---------- Stateful (in-process) ----------
class StatefulSessionManager:
    def __init__(self):
        self.sessions: Dict[str, Dict[str, Any]] = {}

    def create(self, user_id: str) -> str:
        session_id = str(uuid.uuid4())
        self.sessions[session_id] = {"user_id": user_id, "cart": []}
        return session_id

    def get(self, session_id: str) -> Optional[Dict[str, Any]]:
        return self.sessions.get(session_id)

    def add_to_cart(self, session_id: str, item: str):
        session = self.sessions.get(session_id)
        if session:
            session["cart"].append(item)

# ---------- Stateless (external store) ----------
class ExternalStore:
    """Pretend this is Redis."""
    def __init__(self):
        self.data: Dict[str, Dict[str, Any]] = {}

    def set(self, key: str, value: Dict[str, Any]):
        self.data[key] = value

    def get(self, key: str) -> Optional[Dict[str, Any]]:
        return self.data.get(key)

class StatelessSessionManager:
    def __init__(self, store: ExternalStore):
        self.store = store

    def create(self, user_id: str) -> str:
        session_id = str(uuid.uuid4())
        self.store.set(session_id, {"user_id": user_id, "cart": []})
        return session_id

    def get(self, session_id: str) -> Optional[Dict[str, Any]]:
        return self.store.get(session_id)

    def add_to_cart(self, session_id: str, item: str):
        session = self.store.get(session_id)
        if session:
            session["cart"].append(item)
            self.store.set(session_id, session)   # write back

if __name__ == "__main__":
    print("=== Stateful ===")
    stateful = StatefulSessionManager()
    sid = stateful.create("alice")
    stateful.add_to_cart(sid, "book")
    print(stateful.get(sid))

    print("\n=== Stateless ===")
    store = ExternalStore()
    # Two “different app instances” sharing the same external store
    instance_a = StatelessSessionManager(store)
    instance_b = StatelessSessionManager(store)

    sid2 = instance_a.create("bob")
    instance_a.add_to_cart(sid2, "laptop")
    # Request now lands on instance_b – still works
    print(instance_b.get(sid2))
```

**The Verification**  
```bash
python stateful_vs_stateless.py
```
Both styles work for a single process. The critical difference appears only when you run multiple instances: the stateful version would require sticky sessions or session migration; the stateless version works with any load-balancing algorithm.

---

### Reference Section – Caching & Async Decision Guide

| Situation                              | Recommended approach                          |
|----------------------------------------|-----------------------------------------------|
| Public static assets                   | CDN + long TTL + content-hash filenames       |
| Personalized but read-heavy data       | Cache-aside in Redis with short TTL           |
| Data that must never be stale          | Write-through or explicit invalidation        |
| Extremely high write volume, durable later OK | Write-behind (with care)                   |
| Work that is not needed for the HTTP response | Publish event → async workers              |
| Need ordered, replayable event stream  | Kafka-style log                               |
| Need simple competing consumers        | Classic queue (RabbitMQ, SQS)                 |
| Application servers must scale freely  | Make them completely stateless                |

---

### What You Can Do Now

For any new endpoint or feature you can ask:

1. Which parts of the response can be cached, and at which layer?  
2. Which caching pattern keeps the data correct enough for this use case?  
3. Which pieces of work can be moved off the critical path into asynchronous workers?  
4. Does this service hold any in-memory state that would prevent us from freely adding or removing instances?

Answering these four questions consistently is the difference between a system that stays fast under load and one that collapses when traffic spikes.
