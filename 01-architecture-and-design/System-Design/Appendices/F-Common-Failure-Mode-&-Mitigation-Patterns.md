# Appendix F: Common Failure Modes & Mitigation Patterns

Most production incidents are not caused by exotic new bugs. They are caused by a relatively small set of recurring failure modes. This appendix catalogs the most frequent ones and the standard mitigations you should reach for automatically.

Use it in three ways:

- During design: ask “Which of these could happen to us?”  
- During interviews: when the interviewer asks about failure handling, walk through the relevant rows.  
- During incident reviews: map the incident to one or more of these patterns so the fix is systematic rather than one-off.

---

### F.1 Compute & Application Layer

| Failure Mode | Typical Symptoms | Primary Mitigations | Notes |
|--------------|------------------|---------------------|-------|
| Instance crash / OOM | Sudden 5xx spike, pod restarts | Stateless services, health checks, resource limits, multiple replicas | Prefer crash-over-corrupt |
| Thread / connection pool exhaustion | Latency climbs, then timeouts | Separate pools (bulkheads), strict timeouts, bounded queues | Very common under partial dependency failure |
| CPU / memory saturation | Rising latency, throttling | Auto-scaling on the right metrics, load shedding, rate limiting | Watch saturation, not just utilization |
| Bad deployment | Error rate jumps after release | Canary / rolling deploys, automated rollback, feature flags | Make rollback boring and fast |
| Thundering herd after restart | Stampede on caches or databases | Request coalescing, staggered startups, cache warming, jitter | Classic after a large deploy or cache flush |

---

### F.2 Dependency & Network Failures

| Failure Mode | Typical Symptoms | Primary Mitigations | Notes |
|--------------|------------------|---------------------|-------|
| Slow dependency | Latency rises, threads block | Aggressive timeouts, circuit breakers, bulkheads | Timeouts are the first and most important defense |
| Dependency hard failure | Elevated error rate | Circuit breaker, retries with backoff (only on idempotent/safe ops), fallback | Don’t retry non-idempotent requests without care |
| Network partition | Partial success / split brain | Prefer AP or CP deliberately, avoid 2PC across partitions | Design for it; don’t pretend it won’t happen |
| DNS failure / discovery issues | Intermittent or total inability to reach dependents | Local caching of discovery results, multiple DNS servers, retries | Often overlooked |
| Cascading failure | One bad service takes down many | Circuit breakers + bulkheads + rate limiting + load shedding | The classic distributed-systems death spiral |

---

### F.3 Data & Storage Failures

| Failure Mode | Typical Symptoms | Primary Mitigations | Notes |
|--------------|------------------|---------------------|-------|
| Primary database failure | Write outage or high latency | Automatic failover, read replicas, connection pool draining | Test failover regularly |
| Replication lag | Stale reads after write | Read-your-writes routing, bounded staleness, or strong consistency where required | Especially visible in multi-region |
| Hot partition / hot key | One shard or key saturates | Better partition key, request coalescing, local caching, key salting | Celebrity / “hot key” problem |
| Cache stampede | DB overload after cache expiry | Probabilistic early expiration, single-flight / request coalescing, lock-based fill | Very common with popular keys |
| Data corruption or bad write | Silent or eventual incorrect results | Checksums, immutable event logs, careful migrations, audit trails | Harder to detect than availability issues |
| Backup / restore never tested | “We have backups” but recovery fails | Regular restore drills, measured RTO/RPO | A backup you have never restored is a wish |

---

### F.4 Traffic & Load Failures

| Failure Mode | Typical Symptoms | Primary Mitigations | Notes |
|--------------|------------------|---------------------|-------|
| Sudden traffic spike | Elevated latency and errors | Auto-scaling, rate limiting, load shedding, queue buffering | Prefer graceful degradation over total failure |
| DDoS or abusive client | Resource exhaustion | Edge rate limiting, WAF, IP reputation, challenge pages | Defend in depth (edge + application) |
| Retry storm | Amplified traffic after a blip | Jittered backoff, circuit breakers, retry budgets | Client-side retries can make outages worse |
| Queue overload | Growing lag, memory pressure | Bounded queues, dead-letter queues, back-pressure to producers | Never let queues grow without limit |

---

### F.5 Consistency & Correctness Failures

| Failure Mode | Typical Symptoms | Primary Mitigations | Notes |
|--------------|------------------|---------------------|-------|
| Lost update / race condition | Incorrect values under concurrency | Optimistic locking, transactions, idempotency keys, single-writer patterns | Classic in inventory, balances, counters |
| Dual writes without coordination | Divergent state across stores | Transactional outbox, change-data-capture, or accept eventual consistency | Dual writes are a frequent source of subtle bugs |
| Incomplete Saga / partial business transaction | Money taken but order not created (or vice versa) | Compensating actions, idempotent steps, clear state machines | Design compensations up front |
| Clock skew effects | Wrong ordering or expired tokens | Prefer logical clocks or hybrid logical clocks where ordering matters; avoid relying on perfect sync | Especially relevant for TTLs and leases |

---

### F.6 Operational & Human Failures

| Failure Mode | Typical Symptoms | Primary Mitigations | Notes |
|--------------|------------------|---------------------|-------|
| Misconfiguration | Sudden widespread incorrect behavior | Immutable config, validation on startup, progressive rollout of config changes | Config changes are a leading cause of outages |
| Secret leakage or rotation failure | Security incident or sudden auth failures | Short-lived credentials, automated rotation, least privilege | Treat secret distribution as a first-class problem |
| Alert fatigue | Real incidents ignored | SLO-based alerting, high signal-to-noise, clear ownership | Noisy alerts are worse than missing alerts |
| Missing runbooks | Slow or incorrect incident response | Executable runbooks, game days, clear ownership | The first time you need a runbook should not be during an outage |

---

### F.7 Mitigation Pattern Quick Reference

| Pattern | One-sentence purpose |
|---------|----------------------|
| **Timeout** | Stop waiting for a dependency that is probably dead |
| **Retry + jittered backoff** | Survive transient failures without creating a thundering herd |
| **Idempotency key** | Make retries safe |
| **Circuit breaker** | Stop calling a dependency that is already failing |
| **Bulkhead** | Limit the blast radius of a failure |
| **Load shedding / rate limiting** | Protect the system from overload |
| **Graceful degradation** | Keep core value available when non-critical parts fail |
| **Back-pressure** | Slow producers down when consumers cannot keep up |
| **Canary / progressive rollout** | Limit the blast radius of a bad change |
| **Feature flag** | Decouple deployment from release and enable instant rollback of behavior |
| **Expand/contract migration** | Change schemas without downtime or dual-version pain |
| **Transactional outbox** | Reliably publish events as part of a database transaction |

---

### F.8 How to Apply This in Design Conversations

When reviewing any architecture, pick the three most likely failure modes from the tables above and ask:

1. How will we detect it?  
2. How will the system behave while it is happening?  
3. How will we recover?  
4. How will we prevent the same class of failure next time?

If the design has no good answers for the top three risks, it is not yet production-ready.

In interviews, you do not need to recite the entire catalog. Choosing two or three relevant failure modes and walking through detection → mitigation → recovery is usually enough to demonstrate senior-level thinking.

---

**[END OF APPENDIX F]**
