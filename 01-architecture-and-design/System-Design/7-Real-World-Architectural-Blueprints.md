# Part 7 – Real-World Architectural Blueprints

We now put every previous module to work. Each case study is a complete “whiteboard” design: requirements, high-level architecture, data model, key algorithms, failure modes, and the concrete trade-offs you would discuss in an interview or design review.

You will see the same building blocks—load balancing, caching, sharding, async processing, consistency choices, rate limiting, and observability—recombined to solve different problems.

---

### 7.1 High-Throughput URL Shortener

**The Target**  
Design a service that turns long URLs into short, shareable links and redirects with very low latency at high scale.

**The Concept**  
Core requirements:

- Generate a short, unique key for any long URL.  
- Redirect `GET /{key}` to the original URL in single-digit milliseconds.  
- Handle billions of URLs and hundreds of thousands of redirects per second.  
- Optional: custom aliases, expiration, analytics.

**Key design decisions**

| Concern              | Choice                                      | Why |
|----------------------|---------------------------------------------|-----|
| Key generation       | Base62-encoded counter or hash + collision check | Short, URL-safe, unique |
| Storage              | Key-value store (key → long URL)            | Simple point lookups |
| Read path            | Cache + DB                                  | Extremely hot keys |
| Write path           | Synchronous, idempotent                     | User expects the short link immediately |
| Scaling              | Shard by key hash                           | Even distribution |

**High-level architecture**

```
Client
  │
  ▼
API Gateway / Load Balancer
  │
  ▼
URL Service (stateless)
  │
  ├──► Redis (cache of hot keys)
  │
  └──► Sharded Key-Value Store (or relational table with secondary index)
```

**The Implementation**  
Complete core logic for key generation, storage, and redirect, including collision handling.

```python
# file: part7/url_shortener.py
import hashlib
import string
import threading
from typing import Optional

BASE62 = string.digits + string.ascii_letters

def encode_base62(num: int) -> str:
    if num == 0:
        return BASE62[0]
    digits = []
    while num:
        digits.append(BASE62[num % 62])
        num //= 62
    return "".join(reversed(digits))

class URLShortener:
    def __init__(self):
        self.lock = threading.Lock()
        self.counter = 1000000          # start from a reasonable size
        self.store: dict[str, str] = {} # key → long URL
        self.reverse: dict[str, str] = {} # long URL → key (optional dedup)

    def shorten(self, long_url: str, custom: Optional[str] = None) -> str:
        with self.lock:
            # Optional: return existing key if we already shortened this URL
            if long_url in self.reverse:
                return self.reverse[long_url]

            if custom:
                if custom in self.store:
                    raise ValueError("Custom key already taken")
                key = custom
            else:
                # Counter-based generation (predictable length, no collisions)
                self.counter += 1
                key = encode_base62(self.counter)

                # Extremely unlikely hash-based alternative with collision retry
                # key = self._hash_key(long_url)

            self.store[key] = long_url
            self.reverse[long_url] = key
            return key

    def _hash_key(self, long_url: str, length: int = 7) -> str:
        """Hash + collision retry (alternative to counter)."""
        digest = hashlib.sha256(long_url.encode()).hexdigest()
        for i in range(0, len(digest) - length + 1):
            candidate = encode_base62(int(digest[i:i+length], 16))[:length]
            if candidate not in self.store:
                return candidate
        raise RuntimeError("Could not find unique key")

    def resolve(self, key: str) -> Optional[str]:
        return self.store.get(key)

if __name__ == "__main__":
    s = URLShortener()
    key1 = s.shorten("https://example.com/very/long/path/to/resource")
    key2 = s.shorten("https://example.com/another/page")
    key3 = s.shorten("https://example.com/very/long/path/to/resource")  # dedup

    print("key1:", key1)
    print("key2:", key2)
    print("key3 (dedup):", key3)
    print("resolve:", s.resolve(key1))
```

**The Verification**  
```bash
cd part7
python url_shortener.py
```
You receive short keys and can resolve them back to the original URLs. In production the in-memory dict becomes Redis + a sharded persistent store; the counter becomes a distributed ID generator (Snowflake, Redis INCR, or DB sequence per shard).

**Failure modes & mitigations**
- Cache stampedes on very popular keys → request coalescing or early refresh.  
- Counter exhaustion or hotspot → switch to UUID/hash or range-allocated counters per shard.  
- Data loss → synchronous write to durable store before returning the short key.

---

### 7.2 Event-Driven Notification Engine

**The Target**  
Build a system that accepts notification requests and reliably delivers them through multiple channels (email, push, SMS) with fan-out, retries, and provider failover.

**The Concept**  
Requirements:

- Accept a notification request (user_id, template, data, channels).  
- Fan-out to one or more delivery channels.  
- At-least-once delivery with idempotency.  
- Automatic failover when a provider is down.  
- Respect user preferences and quiet hours.

**Architecture**

```
API → Validation → Event Bus (topic: notification.requested)
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
     Email Worker  Push Worker  SMS Worker
          │           │           │
          ▼           ▼           ▼
     Provider A    Provider B   Provider C
     (with failover to secondary providers)
```

**The Implementation**  
Complete fan-out + retry + failover logic.

```python
# file: part7/notification_engine.py
import time
import random
import queue
import threading
from dataclasses import dataclass, field
from typing import List, Dict, Callable
from enum import Enum, auto

class Channel(Enum):
    EMAIL = auto()
    PUSH = auto()
    SMS = auto()

@dataclass
class Notification:
    id: str
    user_id: str
    template: str
    data: dict
    channels: List[Channel]

@dataclass
class DeliveryAttempt:
    notification_id: str
    channel: Channel
    provider: str
    success: bool
    error: str = ""

class Provider:
    def __init__(self, name: str, failure_rate: float = 0.2):
        self.name = name
        self.failure_rate = failure_rate

    def send(self, notification: Notification, channel: Channel) -> bool:
        time.sleep(random.uniform(0.05, 0.15))
        if random.random() < self.failure_rate:
            raise Exception(f"{self.name} temporary failure")
        return True

class NotificationEngine:
    def __init__(self):
        self.providers: Dict[Channel, List[Provider]] = {
            Channel.EMAIL: [Provider("SendGrid"), Provider("SES")],
            Channel.PUSH:  [Provider("FCM"), Provider("APNs")],
            Channel.SMS:   [Provider("Twilio"), Provider("Nexmo")],
        }
        self.queue: queue.Queue = queue.Queue()
        self.attempts: List[DeliveryAttempt] = []
        self._start_workers()

    def _start_workers(self):
        for _ in range(3):
            t = threading.Thread(target=self._worker, daemon=True)
            t.start()

    def submit(self, notification: Notification):
        self.queue.put(notification)

    def _worker(self):
        while True:
            notif = self.queue.get()
            try:
                for channel in notif.channels:
                    self._deliver_with_failover(notif, channel)
            finally:
                self.queue.task_done()

    def _deliver_with_failover(self, notif: Notification, channel: Channel):
        providers = self.providers[channel]
        last_error = ""
        for provider in providers:
            try:
                provider.send(notif, channel)
                self.attempts.append(DeliveryAttempt(
                    notif.id, channel, provider.name, True
                ))
                print(f"✓ {notif.id} → {channel.name} via {provider.name}")
                return
            except Exception as e:
                last_error = str(e)
                self.attempts.append(DeliveryAttempt(
                    notif.id, channel, provider.name, False, last_error
                ))
                print(f"✗ {notif.id} → {channel.name} via {provider.name}: {e}")
        print(f"!! All providers failed for {notif.id} {channel.name}")

if __name__ == "__main__":
    engine = NotificationEngine()

    for i in range(5):
        n = Notification(
            id=f"notif-{i}",
            user_id=f"user-{i}",
            template="welcome",
            data={"name": f"User{i}"},
            channels=[Channel.EMAIL, Channel.PUSH],
        )
        engine.submit(n)

    engine.queue.join()
    print("\nDelivery summary:")
    for a in engine.attempts:
        status = "OK" if a.success else "FAIL"
        print(f"  {a.notification_id} {a.channel.name} {a.provider}: {status}")
```

**The Verification**  
```bash
python notification_engine.py
```
You will see fan-out to multiple channels, automatic failover to secondary providers, and a clear audit of every attempt. In production the in-memory queue becomes Kafka or SQS, and each worker is an independent horizontally-scaled service.

---

### 7.3 Scalable Rate Limiter

**The Target**  
Design a rate limiter that can protect APIs at high scale and support different policies (per-user, per-IP, per-API-key).

**The Concept**  
Two classic algorithms:

| Algorithm            | Pros                              | Cons                              | Best for |
|----------------------|-----------------------------------|-----------------------------------|----------|
| Token bucket         | Allows controlled bursts          | Needs careful refill logic        | Most API rate limits |
| Sliding window log   | Precise, smooth                   | Higher memory (stores timestamps) | Strict fairness |

At scale the limiter itself must be distributed (Redis, or a dedicated service) so every API node sees the same counters.

**The Implementation**  
Both algorithms side-by-side, ready to be backed by Redis.

```python
# file: part7/rate_limiter_algorithms.py
import time
import threading
from collections import defaultdict, deque
from typing import Deque

class TokenBucketLimiter:
    def __init__(self, rate: float, capacity: float):
        self.rate = rate
        self.capacity = capacity
        self.buckets: dict[str, tuple[float, float]] = {}  # key → (tokens, last_refill)
        self.lock = threading.Lock()

    def allow(self, key: str) -> bool:
        with self.lock:
            now = time.monotonic()
            tokens, last = self.buckets.get(key, (self.capacity, now))
            elapsed = now - last
            tokens = min(self.capacity, tokens + elapsed * self.rate)
            if tokens >= 1:
                self.buckets[key] = (tokens - 1, now)
                return True
            self.buckets[key] = (tokens, now)
            return False

class SlidingWindowLogLimiter:
    def __init__(self, max_requests: int, window_seconds: float):
        self.max_requests = max_requests
        self.window = window_seconds
        self.logs: dict[str, Deque[float]] = defaultdict(deque)
        self.lock = threading.Lock()

    def allow(self, key: str) -> bool:
        with self.lock:
            now = time.monotonic()
            q = self.logs[key]
            # Drop timestamps outside the window
            while q and q[0] <= now - self.window:
                q.popleft()
            if len(q) < self.max_requests:
                q.append(now)
                return True
            return False

if __name__ == "__main__":
    tb = TokenBucketLimiter(rate=5, capacity=10)
    sw = SlidingWindowLogLimiter(max_requests=5, window_seconds=1.0)

    print("=== Token Bucket (5/s, burst 10) ===")
    for i in range(15):
        print(i, "allow" if tb.allow("user-1") else "deny")
        time.sleep(0.05)

    print("\n=== Sliding Window (5 per second) ===")
    for i in range(12):
        print(i, "allow" if sw.allow("user-1") else "deny")
        time.sleep(0.1)
```

**The Verification**  
```bash
python rate_limiter_algorithms.py
```
Token bucket permits an initial burst then settles to the steady rate. Sliding window enforces a hard cap inside any rolling one-second period. In production both are implemented with Redis (INCR + EXPIRE or sorted sets for the log).

---

### 7.4 Additional Case Studies (Condensed Blueprints)

#### Chat System (Real-time Messaging)

- **Presence & connection layer**: sticky WebSocket connections behind a load balancer that supports connection draining.  
- **Message flow**: client → chat service → message queue → fan-out to online recipients + durable store for offline users.  
- **Ordering**: per-conversation sequence numbers.  
- **Storage**: messages sharded by conversation_id; recent messages in Redis, older in object storage or Cassandra.  
- **Fan-out trade-off**: fan-out-on-write for small group chats, fan-out-on-read for large channels.

#### Social News Feed

- **Write path**: user posts → store post → fan-out to followers’ timeline caches (or write to a global post store).  
- **Read path**: merge timeline cache + ranking service.  
- **Celebrity problem**: hybrid fan-out (on-write for normal users, on-read for high-follower accounts).  
- **Consistency**: eventual for feed; strong for the post itself.  
- **Caching**: per-user timeline in Redis; CDN for media.

#### Ride Dispatch

- **Core loop**: rider request → matching service → driver inventory (geo-indexed).  
- **Geo data**: geohash or S2 cells in Redis / specialized store.  
- **Matching**: approximate nearest drivers, then refine; use a short-lived lock so two riders do not get the same driver.  
- **State machine**: ride lifecycle (requested → matched → in-progress → completed) with clear timeouts and compensations.  
- **Scale**: partition by city or geohash ranges.

#### Video Streaming

- **Upload path**: client → upload service → object storage + transcoding pipeline (async).  
- **Playback path**: CDN → origin (object storage); adaptive bitrate manifests.  
- **Hot content**: aggressive CDN caching + regional pre-positioning.  
- **Metadata**: title, duration, thumbnails in a document or relational store; search via dedicated search cluster.  
- **DRM / auth**: signed URLs or token-based authorization at the edge.

---

### Reference Section – How to Attack Any New Blueprint

When faced with a new system-design prompt, walk through this sequence:

1. **Clarify requirements** – functional + non-functional (QPS, latency, consistency, durability).  
2. **Estimate scale** – storage size, peak QPS, read/write ratio.  
3. **Draw the high-level flow** – client → edge → services → storage.  
4. **Choose data model & partitioning** – what is the primary key? Where are the hot spots?  
5. **Add caching & async** – what can be cached? What can be eventually consistent?  
6. **Protect the system** – rate limits, circuit breakers, bulkheads, authn/authz.  
7. **Plan for failure** – redundancy, failover, graceful degradation, observability.  
8. **Iterate on bottlenecks** – which component will break first when traffic grows 10×?

---

### What You Can Do Now

You can take any of the classic interview prompts (URL shortener, news feed, chat, ride sharing, rate limiter, notification system, etc.) and produce a coherent, multi-layered design that explicitly calls out:

- the data model and sharding strategy,  
- the caching layers,  
- the synchronous versus asynchronous boundaries,  
- the consistency guarantees,  
- the failure modes and mitigations,  
- and the observability hooks.

That combination of breadth and concrete trade-off analysis is what separates a senior design from a junior one.
