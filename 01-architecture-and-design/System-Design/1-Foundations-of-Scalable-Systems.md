# Part 1 – Foundations of Scalable Systems

This part gives you the shared vocabulary and mental models that every later module builds on. By the end you will be able to look at a simple architecture diagram, point to the places that will break first when traffic grows, and explain *why* in plain language.

We will stay deliberately concrete. Every concept is paired with a real-world analogy and, where useful, a tiny runnable illustration so the idea is not just abstract.

---

### 1.1 Scalability, Availability, Reliability, Latency vs Throughput

**The Target**  
Define the four most-used words in system design and make them measurable.

**The Concept**  
Think of a busy coffee shop.

- **Latency** is how long *you* wait for your coffee once you place the order.  
- **Throughput** is how many coffees the shop can hand out per hour.  
- **Availability** is the percentage of time the shop is actually open and able to take orders.  
- **Reliability** is how often the coffee that *is* served is correct and consistent (no missing espresso shots).  
- **Scalability** is the shop’s ability to keep latency low and throughput high when the line suddenly grows from 10 people to 1 000 people.

In software the same ideas apply, only the units change:

| Metric        | What it measures                          | Typical unit          |
|---------------|-------------------------------------------|-----------------------|
| Latency       | Time for a single request to complete     | milliseconds (ms)     |
| Throughput    | Requests the system can handle per second | RPS / QPS             |
| Availability  | Fraction of time the system is usable     | 99.9 % (“three nines”) |
| Reliability   | Probability that a completed request is correct | error rate / MTBF |

**Important relationship**  
You can often improve *one* of latency or throughput by sacrificing the other, but availability and reliability are usually non-negotiable for user-facing systems.

**The Implementation (measurement mindset)**  
Even before we write any production code, get used to measuring these numbers. A minimal Python example that records latency and throughput for a fake endpoint:

```python
# file: part1/measure_basics.py
import time
import statistics
from concurrent.futures import ThreadPoolExecutor, as_completed

def fake_handler(request_id: int) -> float:
    """Simulate work that takes between 5–15 ms."""
    start = time.perf_counter()
    time.sleep(0.005 + (request_id % 10) * 0.001)  # variable work
    return (time.perf_counter() - start) * 1000  # latency in ms

def run_load(num_requests: int = 200, concurrency: int = 20):
    latencies = []
    start_wall = time.perf_counter()

    with ThreadPoolExecutor(max_workers=concurrency) as pool:
        futures = [pool.submit(fake_handler, i) for i in range(num_requests)]
        for f in as_completed(futures):
            latencies.append(f.result())

    wall_seconds = time.perf_counter() - start_wall
    throughput = num_requests / wall_seconds

    print(f"Requests          : {num_requests}")
    print(f"Concurrency       : {concurrency}")
    print(f"Throughput        : {throughput:.1f} RPS")
    print(f"Avg latency       : {statistics.mean(latencies):.2f} ms")
    print(f"p95 latency       : {statistics.quantiles(latencies, n=20)[18]:.2f} ms")
    print(f"p99 latency       : {statistics.quantiles(latencies, n=100)[98]:.2f} ms")

if __name__ == "__main__":
    run_load()
```

**The Verification**  
```bash
cd part1
python measure_basics.py
```
You should see throughput in the low hundreds of RPS and latencies in the 5–20 ms range. Change `concurrency` and `num_requests` and watch how the numbers move. This is the measurement habit we will keep for the rest of the series.

---

### 1.2 Vertical vs Horizontal Scaling and Where Bottlenecks Appear

**The Target**  
Understand the two fundamental ways to make a system handle more load, and learn to predict which resource will saturate first.

**The Concept**  
- **Vertical scaling** (“scale up”) = buy a bigger machine (more CPU cores, more RAM, faster disk).  
  Analogy: replace the single barista with a super-barista who can make three drinks at once.  
  Limit: there is a physical ceiling, and the bigger machine becomes a single point of failure.

- **Horizontal scaling** (“scale out”) = add more machines of the same size and spread the work.  
  Analogy: hire more baristas and open more counters.  
  Requires a way to distribute requests (load balancer) and usually forces the application to become *stateless*.

**Typical bottleneck progression** (the order things usually break):

1. **CPU** – heavy computation or inefficient code.  
2. **Memory** – large in-memory structures or connection pools.  
3. **Disk I/O** – database writes or logging.  
4. **Network** – bandwidth or connection limits.  
5. **Database connections / locks** – the classic “we scaled the app servers but the DB is on fire”.

**The Implementation (seeing the difference)**  
A tiny demonstration that shows why a single process eventually saturates:

```python
# file: part1/scale_demo.py
import time
from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor
import os

def cpu_bound_work(n: int) -> int:
    """Pure CPU work – benefits from more cores / processes."""
    total = 0
    for i in range(n):
        total += i * i
    return total

def run_vertical_style(workers: int = 4, work_size: int = 5_000_000):
    """Simulate 'bigger machine' by using more threads in one process.
    GIL limits true parallelism for CPU work in CPython.
    """
    start = time.perf_counter()
    with ThreadPoolExecutor(max_workers=workers) as pool:
        list(pool.map(cpu_bound_work, [work_size] * workers))
    return time.perf_counter() - start

def run_horizontal_style(workers: int = 4, work_size: int = 5_000_000):
    """Simulate multiple machines by using separate processes."""
    start = time.perf_counter()
    with ProcessPoolExecutor(max_workers=workers) as pool:
        list(pool.map(cpu_bound_work, [work_size] * workers))
    return time.perf_counter() - start

if __name__ == "__main__":
    print(f"CPU count on this machine: {os.cpu_count()}")
    print("Vertical-style (threads):  ", f"{run_vertical_style():.2f}s")
    print("Horizontal-style (processes):", f"{run_horizontal_style():.2f}s")
```

**The Verification**  
```bash
python scale_demo.py
```
On a multi-core machine the process-based (horizontal) version is noticeably faster for CPU-bound work. This is the same reason we prefer many modest app servers over one giant server once load grows.

---

### 1.3 The Anatomy of a Request

**The Target**  
Trace a single HTTP request from the user’s browser all the way to the database and back, naming every major hop.

**The Concept**  
Imagine ordering a book online. The request travels through several specialized stations before the book leaves the warehouse:

1. **DNS** – the phone book that turns `shop.example.com` into an IP address.  
2. **CDN (Content Delivery Network)** – local bookstores that already have popular titles (static assets, cached pages).  
3. **Load Balancer** – the receptionist who decides which cashier (app server) is free.  
4. **Application Server** – the cashier who knows the business rules.  
5. **Database** – the warehouse inventory system.  
6. (Often) **Cache** – a quick-reference notebook the cashier keeps so they don’t have to walk to the warehouse every time.

**The Implementation (textual walk-through + simple diagram)**  

```
User Browser
    │  1. DNS lookup  (shop.example.com → 203.0.113.10)
    ▼
CDN Edge Node
    │  2. Cache hit?  → return static JS/CSS/images immediately
    │  Cache miss for dynamic page → forward
    ▼
Load Balancer (L4 or L7)
    │  3. Choose healthy app server (round-robin / least-conn / consistent hash)
    │  Optionally terminate TLS here
    ▼
App Server (stateless)
    │  4. Authenticate, authorize, run business logic
    │  Check application cache (Redis)
    │  If miss → query database
    ▼
Database (primary + replicas)
    │  5. Execute SQL / document query
    │  Return rows
    ▼
App Server
    │  6. Render response, optionally write to cache
    ▼
Load Balancer → CDN → User
```

You will see this exact path repeatedly. Every later part of the series adds detail or a new component to one of these hops.

**The Verification**  
No code to run yet. Instead, open your browser’s developer tools (Network tab), visit any major site, and identify:

- The first request that returns the HTML (origin).  
- Subsequent requests served from a CDN domain (`*.cloudfront.net`, `*.akamai`, etc.).  
- The difference in timing between cached and uncached resources.

This is the observational skill we will sharpen.

---

### 1.4 Core Trade-offs: CAP Theorem, PACELC, Consistency vs Availability

**The Target**  
Internalize the two most important theoretical tools that force real design decisions.

**The Concept**  

**CAP Theorem** (Brewer, 2000)  
In the presence of a *network partition* (some machines cannot talk to each other), a distributed system can provide at most two of the following three:

- **C**onsistency – every read receives the most recent write.  
- **A**vailability – every request receives a non-error response.  
- **P**artition tolerance – the system continues to operate despite network splits.

Because partitions *will* happen in any real network, you are forced to choose between **CP** (sacrifice availability) and **AP** (sacrifice strong consistency).

**PACELC** (Abadi)  
CAP only talks about what happens *during* a partition. PACELC adds the normal case:

> If there is a **P**artition, choose **A** or **C**;  
> **E**lse (no partition), choose **L**atency or **C**onsistency.

This is why many systems that claim “eventual consistency” still offer a strongly consistent read mode that costs extra latency.

**Everyday analogy**  
Two cashiers in different cities update the same inventory count.

- **Strong consistency (CP)** – they must lock the inventory record and wait for each other. Customers sometimes see “system busy”.  
- **High availability (AP)** – each cashier updates a local copy and they reconcile later. Customers never see an error, but two people might buy the last item.

**The Implementation (decision table you will reuse)**  

| Requirement                          | Prefer | Typical technology choice          |
|--------------------------------------|--------|------------------------------------|
| Bank balance, inventory reservation  | CP     | PostgreSQL, etcd, ZooKeeper        |
| Social media “likes”, product views  | AP     | Cassandra, DynamoDB, Riak          |
| Low-latency reads, can tolerate stale| PA/EL  | Redis (async replication), CDN     |
| Must be both fast *and* consistent   | PC/EC  | Single-region primary + careful design |

**The Verification**  
Write down three features of an application you know (e.g. “user login”, “news feed”, “payment”). For each, decide whether you would choose CP or AP and why. Keep the notes; we will revisit them in later parts when we actually pick databases.

---

### Reference Section – Quick Glossary & Mental Models

| Term                | One-sentence definition                                      | Mental model                          |
|---------------------|--------------------------------------------------------------|---------------------------------------|
| Latency             | Time for one request                                        | How long you stand in line            |
| Throughput          | Requests per unit time                                      | How many customers the shop serves/hour |
| Availability        | % of time the system answers                                | Shop opening hours                    |
| Reliability         | Correctness of the answers it *does* give                   | Coffee actually contains espresso     |
| Vertical scaling    | Bigger machine                                              | Stronger barista                      |
| Horizontal scaling  | More machines                                               | More counters                         |
| Stateless service   | Any instance can handle any request                         | Any cashier can take any order        |
| CAP                 | During partition: Consistency or Availability               | Two cashiers who can’t phone each other |
| PACELC              | CAP + normal-case Latency vs Consistency trade-off          | Same cashiers when the phone *does* work |

---

### What You Can Do Now

You can look at any simple architecture (client → load balancer → app → database) and answer:

1. Which resource is most likely to saturate first as traffic grows?  
2. Would you scale that tier vertically or horizontally, and what must be true for horizontal scaling to work?  
3. If the network between two data centers partitions, does the system prefer consistency or availability for this particular feature?

These three questions are the foundation of every design conversation that follows.
