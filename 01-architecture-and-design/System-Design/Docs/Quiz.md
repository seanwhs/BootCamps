**Quiz & Test Bank**  
**System Design Mastery – With Answer Keys**

Use these for self-testing, study groups, or formal assessment. Questions are grouped by topic. Answer keys follow each section.

---

### Section A: Foundations (Parts 1, Primers A–E)

**A1.** Which statement best distinguishes latency from throughput?  
a) Latency is errors per second; throughput is time per request  
b) Latency is time per request; throughput is requests per unit time  
c) Latency is availability; throughput is reliability  
d) They are interchangeable terms  

**A2.** A system can serve 50,000 requests per second with an average response time of 20 ms. What is being described?  
a) Only latency  
b) Only throughput  
c) Both latency and throughput  
d) Only availability  

**A3.** Which scaling approach adds more machines of similar size?  
a) Vertical scaling  
b) Horizontal scaling  
c) Diagonal scaling  
d) Functional scaling  

**A4.** Why do stateless application servers make horizontal scaling easier?  
(Short answer)

**A5.** Give one example of data that typically needs strong consistency and one that can usually accept eventual consistency.

**A6.** Under a network partition, CAP theorem says a system must choose between:  
a) Latency and throughput  
b) Consistency and Availability  
c) Security and Performance  
d) Scalability and Reliability  

---

**Answer Key – Section A**  
**A1.** b  
**A2.** c  
**A3.** b  
**A4.** Any instance can handle any request; no need for sticky sessions or migrating in-memory state when adding/removing instances.  
**A5.** Strong: bank balance, inventory reservation, unique username. Eventual: like counts, view counters, social feed, product catalog browsing.  
**A6.** b  

---

### Section B: Networking & Traffic (Part 2, Primers F, H, X)

**B1.** An L7 load balancer can route traffic based on:  
a) Only IP address and port  
b) HTTP path, headers, cookies, etc.  
c) Only TCP connection state  
d) Only geographic location  

**B2.** Which load-balancing algorithm is most helpful when requests have very different processing times?  
a) Round-robin  
b) Least connections  
c) Random  
d) Source IP hash only  

**B3.** Token bucket rate limiting primarily allows:  
a) Strict fixed windows with no bursts  
b) Controlled bursts up to bucket capacity while enforcing a long-term rate  
c) Unlimited traffic as long as the average is low  
d) Only per-IP limits  

**B4.** When is asynchronous communication generally preferable to synchronous?  
(Short answer – list two conditions)

**B5.** A client receives HTTP 429. What does this most commonly mean, and what header should it respect?

---

**Answer Key – Section B**  
**B1.** b  
**B2.** b  
**B3.** b  
**B4.** When the work is not required for the immediate user response; when the work is slow/bursty/fan-out heavy; when you want independent scaling of producers and consumers.  
**B5.** Too Many Requests (rate limit exceeded). Respect `Retry-After` (and back off).  

---

### Section C: Data, Consistency & Messaging (Part 3, Primers C, E, U, AC)

**C1.** What is the main purpose of a database index?  
a) To compress data  
b) To allow the database to find rows without scanning the entire table  
c) To enforce strong consistency  
d) To automatically shard data  

**C2.** Adding more indexes to a table typically:  
a) Speeds up all writes and reads  
b) Speeds up some reads but slows down writes  
c) Has no impact on writes  
d) Only affects storage cost, not performance  

**C3.** At-least-once delivery means:  
a) Messages may be lost but never duplicated  
b) Messages may be duplicated but should not be lost  
c) Messages are processed exactly once  
d) Messages are delivered in strict global order  

**C4.** What application-level property is required to make at-least-once delivery safe for business operations?

**C5.** Briefly describe the expand/contract pattern for renaming a database column.

**C6.** Which consistency model guarantees that a client always sees its own writes?  
a) Eventual consistency  
b) Strong consistency  
c) Read-your-writes  
d) Monotonic reads only  

---

**Answer Key – Section C**  
**C1.** b  
**C2.** b  
**C3.** b  
**C4.** Idempotency (or equivalent deduplication).  
**C5.** Add the new column (expand) → dual-write to both → backfill → switch reads to the new column → remove the old column (contract).  
**C6.** c  

---

### Section D: Caching, Async & Fan-out (Part 4, Primers G, H, I, J)

**D1.** In the cache-aside pattern, who is responsible for loading data into the cache on a miss?  
a) The database automatically  
b) The cache itself (read-through)  
c) The application  
d) The load balancer  

**D2.** A cache stampede is most likely when:  
a) Many clients simultaneously miss on the same popular key  
b) The cache is too large  
c) TTL is very long  
d) Only one client is active  

**D3.** Fan-out on write is generally better when:  
a) The audience is extremely large and unpredictable (celebrities)  
b) The audience is moderate and reads must be very fast  
c) Writes must be as cheap as possible  
d) You never want to duplicate data  

**D4.** Give two practical techniques to make an operation idempotent.

**D5.** Why is it usually better to push session state out of the application process into Redis or a database?

---

**Answer Key – Section D**  
**D1.** c  
**D2.** a  
**D3.** b  
**D4.** Idempotency keys; natural unique constraints; state-based checks (“if already cancelled, do nothing”); upserts.  
**D5.** Keeps application instances stateless so they can be scaled, replaced, or fail without losing session data or requiring sticky sessions.  

---

### Section E: Reliability Patterns (Part 5, Primers J–O, K, L, M, N)

**E1.** Match the pattern to the problem it primarily solves:

| Pattern | Problem |
|---------|---------|
| 1. Timeout | A. Stop calling a dependency that is repeatedly failing |
| 2. Circuit breaker | B. Prevent one failure from consuming all resources |
| 3. Bulkhead | C. Avoid waiting forever for a response |
| 4. Back-pressure | D. Tell upstream to slow down when overloaded |

**E2.** Why should retries use jitter?

**E3.** What is the difference between liveness and readiness probes?

**E4.** A non-critical recommendation service is down. What does graceful degradation look like on a product page?

**E5.** True or False: Circuit breakers replace the need for timeouts.

---

**Answer Key – Section E**  
**E1.** 1-C, 2-A, 3-B, 4-D  
**E2.** To avoid thundering herds / synchronized retries that all hit the dependency at the same moment.  
**E3.** Liveness: “Is the process alive?” (failure → restart). Readiness: “Is it ready for traffic right now?” (failure → stop sending traffic).  
**E4.** Page still loads and core purchase flow works; recommendations are hidden, replaced by a fallback, or omitted.  
**E5.** False. They complement each other.  

---

### Section F: Security, Multi-Tenancy & Operations (Part 6, Primers V, W, Y, S, T, AD)

**F1.** Authentication answers ________; Authorization answers ________.

**F2.** Which of the following is a secrets anti-pattern?  
a) Injecting secrets at runtime from a secret manager  
b) Storing database passwords in the container image  
c) Using short-lived credentials  
d) Rotating keys regularly  

**F3.** Name two techniques to reduce noisy-neighbor risk in a multi-tenant system.

**F4.** Why is “the UI already prevents that action” insufficient for authorization?

**F5.** Feature flags primarily allow you to:  
a) Avoid writing tests  
b) Decouple code deployment from feature release  
c) Replace monitoring  
d) Eliminate the need for rollbacks  

**F6.** Expand/contract is preferred over big-bang schema changes because:

---

**Answer Key – Section F**  
**F1.** Who are you?; What are you allowed to do?  
**F2.** b  
**F3.** Per-tenant rate limits/quotas; separate connection pools or worker pools; dedicated resources for large tenants; per-tenant concurrency limits.  
**F4.** Attackers (or other clients) can call the API directly and bypass the UI. Authorization must be enforced on the server.  
**F5.** b  
**F6.** It keeps the system compatible with both old and new code during the transition, enabling zero-downtime and safer rollback.  

---

### Section G: Scenario / Integration Questions

**G1.** You are designing a multi-tenant project-management tool with real-time board updates.  
List four major design concerns you must address and one concrete technique for each.

**G2.** A downstream payment provider starts returning high latency and intermittent errors.  
Describe the sequence of protections you would want in place around calls to it.

**G3.** Why is a pure fan-out-on-write design risky for a social feed, and what hybrid approach is commonly used?

**G4.** A service has good average latency but users complain it sometimes “feels stuck.” What metric are you likely missing, and why?

---

**Answer Key – Section G**  
**G1.** (Sample answers – any strong set is acceptable)  
- Multi-tenant isolation → mandatory tenant filter + per-tenant rate limits  
- Real-time updates → WebSockets (or similar) + fan-out to connected clients  
- Consistency of task mutations → strong consistency for core task data  
- Failure isolation → timeouts, circuit breakers, bulkheads so non-critical features don’t kill the board  
- Search / secondary views → async indexing, eventual consistency  

**G2.** Timeouts on every call → limited retries with exponential backoff + jitter (only if idempotent) → circuit breaker to stop calling when failure rate is high → bulkhead so payment latency cannot exhaust the main thread/connection pool → graceful degradation or clear user-facing error for the payment step.  

**G3.** Celebrity accounts create massive write amplification. Hybrid: fan-out on write for normal users; fan-out on read (or hybrid) for high-follower accounts.  

**G4.** Tail latency (p95/p99). Averages hide the slow requests that users actually notice.  

---

### Section H: Quick True/False Mini-Quiz

1. Sticky sessions are the preferred way to scale application servers.  
2. At-least-once delivery requires idempotent consumers for safety.  
3. Liveness probes should check deep dependencies such as the database.  
4. Error budgets help teams decide when to prioritize reliability work.  
5. Vertical scaling has no practical limits.  
6. Cache-aside means the cache itself knows how to load data from the database.  
7. Rate limiting should often be applied at more than one layer.  
8. Strong consistency is required for every piece of data in a system.  

---

**Answer Key – Section H**  
1. False (prefer stateless + externalized state)  
2. True  
3. False (liveness should be shallow; readiness can check dependencies)  
4. True  
5. False  
6. False (that is closer to read-through; cache-aside is application-managed)  
7. True  
8. False  

---

### How to Use This Bank

- **Self-study**: Do one section, check answers, revisit weak primers/parts.  
- **Study group**: Assign sections; discuss scenario answers out loud.  
- **Trainer**: Use as pre/post checks or exam questions. Score scenarios with the rubric in Appendix D.  
- **Interview prep**: Practice answering G-section questions in 3–5 minutes each with clear structure.

**End of Quiz & Test Bank**
