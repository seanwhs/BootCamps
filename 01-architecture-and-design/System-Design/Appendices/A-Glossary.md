# Appendix A: Core Terminology & Mental Models Glossary

A living reference of the most important terms and analogies used throughout the series. Use this when you need a precise definition or a quick mental model during an interview or design discussion.

### Scalability & Performance

| Term | Definition | Mental Model |
|------|------------|--------------|
| **Latency** | Time taken to process a single request | How long you wait in line for your coffee |
| **Throughput** | Number of requests the system can handle per unit time | How many coffees the shop can serve per hour |
| **Availability** | Percentage of time the system is able to respond successfully | Percentage of time the shop is open |
| **Reliability** | Probability that a response is correct and consistent | Probability that the coffee actually contains the right ingredients |
| **Scalability** | Ability to maintain latency and throughput as load grows | Ability to keep serving coffee quickly when the line grows 10× |
| **Vertical scaling** | Adding more resources (CPU, RAM, disk) to a single machine | Hiring a stronger, faster barista |
| **Horizontal scaling** | Adding more machines and distributing work | Opening more counters and hiring more baristas |

### Networking & Traffic

| Term | Definition | Mental Model |
|------|------------|--------------|
| **Load balancer** | Distributes incoming requests across multiple backend instances | Traffic cop directing cars to open toll booths |
| **L4 vs L7** | Layer-4 (transport) vs Layer-7 (application) load balancing | Directing by street address vs directing by the contents of the package |
| **API Gateway** | Single entry point that handles routing, auth, rate limiting, SSL, etc. | Smart front desk that checks ID, routes visitors, and enforces building rules |
| **CDN** | Geographically distributed cache for static (and sometimes dynamic) content | Local bookstores that already have the popular titles |
| **Circuit breaker** | Stops calling a failing dependency for a period of time | Electrical breaker that trips to protect the rest of the house |
| **Rate limiting** | Restricting how many requests a client can make in a time window | Nightclub bouncer controlling entry rate |

### Data & Consistency

| Term | Definition | Mental Model |
|------|------------|--------------|
| **ACID** | Atomicity, Consistency, Isolation, Durability – classic relational guarantees | All-or-nothing bank transfer that either fully completes or fully rolls back |
| **BASE** | Basically Available, Soft state, Eventual consistency | Social media “likes” that eventually converge |
| **CAP Theorem** | Under partition, choose Consistency or Availability | Two cashiers who cannot phone each other must decide whether to sell the last item |
| **PACELC** | If Partition → A/C; Else → Latency/Consistency | Extends CAP to the normal (non-partitioned) case |
| **Strong consistency** | Every read sees the latest write | Bank balance – you always see the real current amount |
| **Eventual consistency** | Reads may be stale but will converge if writes stop | View counters or “likes” that catch up over time |
| **Read-your-writes** | A client always sees its own writes | After you edit your profile, you immediately see the new version |
| **Sharding / Partitioning** | Splitting data across multiple machines by a key | Giving each city its own phone book |
| **Consistent hashing** | Hashing technique that minimizes key movement when nodes change | A ring where adding/removing a node only affects a fraction of keys |
| **Saga** | Sequence of local transactions with compensating actions | Friends who each pay their share; if one cannot, the others get refunds |
| **Two-Phase Commit (2PC)** | Coordinated prepare + commit protocol across participants | Everyone raises their hand before anyone pays the bill |

### Caching & State

| Term | Definition | Mental Model |
|------|------------|--------------|
| **Cache-aside** | Application checks cache first; on miss loads from DB and populates cache | Checking your notebook before walking to the filing cabinet |
| **Write-through** | Writes go to cache and database together | Updating both your notebook and the official ledger at the same time |
| **Write-behind** | Writes go to cache; database is updated asynchronously | Writing in your notebook and letting someone else update the ledger later |
| **LRU** | Evict the least recently used item | Throwing out the book you haven’t touched for the longest time |
| **LFU** | Evict the least frequently used item | Throwing out the book that has been opened the fewest times |
| **Stateless service** | Any instance can handle any request; no local session state | Any cashier can take any customer’s order |
| **Stateful service** | Instance holds client-specific state in memory | A cashier who keeps your unfinished order in their own drawer |

### Reliability & Operations

| Term | Definition | Mental Model |
|------|------------|--------------|
| **Bulkhead** | Isolating resources so failure in one area cannot sink the whole system | Ship compartments that can flood independently |
| **Graceful degradation** | System continues to provide core functionality when non-critical parts fail | Elevator that still moves (slowly) when one motor fails |
| **Idempotency** | Performing the same operation multiple times has the same effect as once | Pressing the “pay” button twice only charges you once |
| **Retry with backoff** | Re-attempting failed operations with increasing delays + jitter | Calling again, but waiting longer each time and not everyone calling at once |
| **Health check** | Endpoint used by load balancers/orchestrators to decide if an instance can receive traffic | “Are you alive and ready?” pulse check |
| **Observability** | Ability to understand system behavior through metrics, logs, and traces | Dashboard + flight recorder + detailed timeline of a single request |
| **Zero-trust** | Never trust; always verify – even inside the network | Every room requires its own keycard, checked on every entry |
| **Expand/Contract migration** | Safe schema change pattern: add new → dual write → switch read → remove old | Building a new bridge beside the old one before tearing the old one down |

### Communication Styles

| Term | Definition | Mental Model |
|------|------------|--------------|
| **Synchronous** | Caller waits for the response | Phone call – you stay on the line |
| **Asynchronous** | Caller continues without waiting | Leaving a note in a shared inbox |
| **Request-response** | Classic RPC / HTTP style | Asking a question and waiting for the answer |
| **Event-driven / Pub-Sub** | Producers emit events; consumers react independently | Announcing news on a bulletin board; interested people read it later |

---

**How to use this appendix**
- During interview practice: quickly look up a precise definition when you feel yourself hand-waving.
- During design reviews: paste the relevant mental model into an RFC or discussion to align the team.
- When teaching others: the analogies are deliberately simple so they transfer cleanly.

**[END OF APPENDIX A]**
