**Student Notes**  
**System Design Mastery – Condensed Study Notes**

Use these for quick review, interview prep, or revision after working through the full series and workbook.

---

### 1. Core Vocabulary

| Term | One-line meaning |
|------|------------------|
| **Latency** | Time for one request to complete |
| **Throughput** | Requests handled per unit time |
| **Availability** | % of time the system works |
| **Reliability** | Probability that responses are correct |
| **Vertical scaling** | Bigger machine |
| **Horizontal scaling** | More machines |
| **Stateless** | Any instance can handle any request |
| **Strong consistency** | Every read sees the latest write |
| **Eventual consistency** | Reads may be stale but eventually converge |
| **Idempotent** | Doing it multiple times has the same effect as once |

---

### 2. Request Journey (Simplified)

```
Client → DNS → CDN/Edge → Load Balancer / API Gateway
      → App Servers (stateless) → Cache → Database
      → (optional) Async queues / workers
```

Every hop adds latency. Design decisions try to shorten, parallelize, or eliminate hops on the critical path.

---

### 3. Scaling Principles

- Prefer **horizontal scaling** of stateless services.
- Push state into external stores (DB, Redis, object storage).
- Identify the first bottleneck (CPU, memory, DB connections, network, locks).
- Partition/shard data by a key that appears in most queries.
- Watch for hot keys / celebrity problems.

---

### 4. Consistency Quick Guide

| Data type | Preferred consistency |
|-----------|-----------------------|
| Money, inventory, unique constraints | Strong |
| Likes, views, feeds, recommendations | Eventual |
| “I just updated my profile” | Read-your-writes |
| Comment threads, collaborative edits | Causal or strong |

**CAP reminder**: Under partition you choose Consistency or Availability.  
**PACELC**: Even without partition you still trade Latency vs Consistency.

---

### 5. Storage Decision Snapshot

- Complex queries + transactions → Relational (PostgreSQL, etc.)
- Flexible documents / aggregates → Document store
- Simple key lookup, ultra-low latency → Key-value (Redis, DynamoDB)
- Analytics / large scans → Columnar
- Relationships / graph traversal → Graph (or relational + care)

Index the columns used in `WHERE`, `JOIN`, and `ORDER BY`. Every index speeds some reads and slows writes.

---

### 6. Caching Essentials

**Cache-aside (most common)**:
1. Check cache
2. On miss → load from DB
3. Store in cache → return

**Placement**: Browser → CDN → App (Redis) → DB  

**Key risks**: Stale data, cache stampedes  
**Mitigations**: TTL, invalidation on write, single-flight / early refresh

---

### 7. Sync vs Async

| Use Synchronous when… | Use Asynchronous when… |
|------------------------|------------------------|
| User needs the result now | Work is not needed for the immediate response |
| Operation is fast & critical | Work is slow, bursty, or fan-out heavy |
| Strong consistency required | You want independent scaling of producers/consumers |

Async almost always requires **idempotency** + retries + monitoring of lag.

---

### 8. Reliability Toolkit (Memorize This Order)

1. **Timeouts** – don’t wait forever  
2. **Retries + exponential backoff + jitter** – survive transient failures  
3. **Idempotency** – make retries safe  
4. **Circuit breaker** – stop calling a sick dependency  
5. **Bulkhead** – limit blast radius (separate pools/queues)  
6. **Back-pressure** – tell upstream to slow down  
7. **Graceful degradation** – keep core value when non-critical parts fail  

Health checks:  
- **Liveness** = “restart me if I’m dead”  
- **Readiness** = “don’t send me traffic right now”

---

### 9. Messaging Semantics

| Semantic | Loss? | Duplicates? | Consumer must… |
|----------|-------|-------------|----------------|
| At-most-once | Possible | No | — |
| At-least-once | No* | Possible | Be idempotent |
| Exactly-once | No | No (effectively) | Strong idempotency or transactional support |

*Most production systems use **at-least-once + idempotency**.

---

### 10. Fan-out

- **Fan-out on write (push)**: fast reads, expensive writes, celebrity problem  
- **Fan-out on read (pull)**: cheap writes, more expensive reads  
- **Hybrid**: push for normal users, pull for high-degree / celebrity accounts  

---

### 11. Security Essentials

- **Authentication** = Who are you?  
- **Authorization** = What are you allowed to do?  

Golden rules for secrets:
- Never in git or images
- Inject at runtime
- Least privilege
- Rotatable / short-lived preferred

Multi-tenant musts:
- Tenant filter on every query + cache key
- Per-tenant rate limits & quotas
- Never trust client-supplied tenant ID without verification

---

### 12. Rate Limiting

- **Token bucket**: allows controlled bursts  
- **Sliding window**: smoother, more precise  

Place limits at edge + gateway + application.  
Use per-user **and** per-tenant dimensions.  
Return clear `429` + `Retry-After`.

---

### 13. Observability

**Golden Signals**: Latency, Traffic, Errors, Saturation  

- **Metrics** → dashboards & alerts  
- **Logs** (structured) → what happened  
- **Traces** → path of one request across services  

Alert on user-facing SLIs and error-budget burn, not just CPU.

**SLI** = measurement  
**SLO** = target  
**Error budget** = allowed unreliability  

---

### 14. Deployment & Evolution

| Strategy | Blast radius | Rollback | Extra cost |
|----------|--------------|----------|------------|
| Rolling | Gradual | Moderate | Low |
| Canary | Very small first | Fast | Low–moderate |
| Blue-Green | All-at-once switch | Very fast | High |

**Feature flags** decouple deployment from release.  
**Expand/Contract** is the safe way to change schemas and APIs.

---

### 15. 6-Step Interview / Design Framework

1. **Clarify & Scope** (functional + non-functional + out-of-scope)  
2. **Estimates** (QPS, storage, read/write ratio)  
3. **High-Level Design** (components + data flow + sync/async)  
4. **Deep Dives** (data, scale, consistency, failure modes…)  
5. **Trade-offs** (what you optimized vs sacrificed)  
6. **Evolution & Observability** (10× growth, metrics, open questions)

---

### 16. Production Launch Minimum Bar

- Timeouts + retries + idempotency on critical writes  
- Health checks (liveness + readiness)  
- Structured logs + basic metrics (Golden Signals)  
- TLS everywhere  
- Secrets from a secret manager  
- Automated deploy + tested rollback  
- Edge rate limiting  
- Explicit consistency decisions  
- Tested backup/restore path  

---

### 17. Common Failure Modes (Quick List)

- Cascading failure (no circuit breaker / bulkhead)  
- Retry storm (no jitter / no budget)  
- Cache stampede  
- Hot partition / hot key  
- Unbounded queue → OOM  
- Missing tenant filter → data leak  
- Dual write without coordination  
- Config change without progressive rollout  

---

### 18. High-Leverage Interview Phrases

- “Before I design, I’d like to clarify requirements and state assumptions…”  
- “Let me do a quick back-of-the-envelope calculation…”  
- “The hardest part of this design is X — I’ll focus there next.”  
- “The trade-off I’m making is X in exchange for Y.”  
- “If this dependency becomes slow, the blast radius would be…”  
- “I’d protect this call with timeout, circuit breaker, and fallback.”  
- “Does this overall shape look reasonable before I go deeper?”

---

### 19. One-Page Mental Checklist (Before Any Design)

- What are the critical user journeys?  
- What are the scale numbers (peak QPS, storage, connections)?  
- Where is the state, and is the app tier stateless?  
- What consistency does each piece of data need?  
- What can be cached? What can be async?  
- What happens when X fails?  
- How do we isolate tenants / noisy neighbors?  
- How will we observe and deploy this safely?  

---

**End of Student Notes**

These notes compress the series into a form you can review in 20–30 minutes. For depth, return to the relevant Part, Primer, or Appendix. For skill, work the Student Workbook and timed practice designs.
