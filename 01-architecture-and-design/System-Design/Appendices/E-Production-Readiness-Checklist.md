# Appendix E: Production Readiness Checklist

A system can look excellent on a whiteboard and still be dangerous to run in production. This checklist is the bridge between “design complete” and “safe to put in front of users.”

Use it in three situations:

1. Before the first production deployment of a new service  
2. During architecture reviews of existing systems  
3. As a final gate in an interview when the interviewer asks “How would you actually ship this?”

Score each item as **Done**, **Partial**, or **Missing**. Anything still Missing on a critical path item should block launch.

---

### E.1 Reliability & Failure Handling

| # | Item | Status | Notes |
|---|------|--------|-------|
| 1 | Timeouts defined on every external call | | |
| 2 | Retries with exponential backoff + jitter on transient failures | | |
| 3 | Idempotency keys (or equivalent) for all non-safe operations | | |
| 4 | Circuit breakers around critical dependencies | | |
| 5 | Bulkheads / separate thread or connection pools for different dependency types | | |
| 6 | Graceful degradation paths for non-critical features | | |
| 7 | Health checks (liveness + readiness) implemented and used by the orchestrator | | |
| 8 | Explicit handling of partial failures in distributed workflows (Saga compensations, etc.) | | |

---

### E.2 Scalability & Performance

| # | Item | Status | Notes |
|---|------|--------|-------|
| 9 | Stateless application tier (or explicit sticky-session justification) | | |
| 10 | Data partitioning / sharding strategy defined and tested | | |
| 11 | Caching strategy documented (what, where, TTL, invalidation) | | |
| 12 | Load-testing results exist for expected peak + 2–3× headroom | | |
| 13 | Back-pressure mechanisms (rate limiting, queue limits, load shedding) | | |
| 14 | Auto-scaling policies defined with sensible metrics and cooldowns | | |

---

### E.3 Data & Consistency

| # | Item | Status | Notes |
|---|------|--------|-------|
| 15 | Consistency model explicitly chosen for each major data type | | |
| 16 | Backup and restore tested (not just configured) | | |
| 17 | Migration strategy is expand/contract (or equivalent safe pattern) | | |
| 18 | Data retention and deletion policies defined | | |
| 19 | Schema or data-format compatibility rules documented | | |

---

### E.4 Security

| # | Item | Status | Notes |
|---|------|--------|-------|
| 20 | All external traffic terminates TLS | | |
| 21 | Service-to-service authentication (mTLS or equivalent short-lived identity) | | |
| 22 | Authorization checks on every sensitive operation | | |
| 23 | Secrets loaded at runtime from a secret manager (never baked into images) | | |
| 24 | Least-privilege IAM roles / service accounts | | |
| 25 | Rate limiting and basic DDoS protections at the edge | | |
| 26 | Audit logging for security-relevant events | | |
| 27 | Dependency vulnerability scanning in CI | | |

---

### E.5 Observability

| # | Item | Status | Notes |
|---|------|--------|-------|
| 28 | Golden signals instrumented (latency, traffic, errors, saturation) | | |
| 29 | Structured logging with request / trace IDs | | |
| 30 | Distributed tracing propagated across service boundaries | | |
| 31 | Key business and technical metrics have dashboards | | |
| 32 | Alerting rules defined with clear ownership and runbooks | | |
| 33 | SLOs (or at least SLIs) defined for critical user journeys | | |

---

### E.6 Operations & Deployment

| # | Item | Status | Notes |
|---|------|--------|-------|
| 34 | Immutable infrastructure / immutable container images | | |
| 35 | Automated, repeatable deployment pipeline | | |
| 36 | Rolling, blue-green, or canary deployment strategy | | |
| 37 | One-click (or one-command) rollback tested | | |
| 38 | Configuration injected externally (not compiled in) | | |
| 39 | Feature flags for risky or gradual rollouts | | |
| 40 | Runbooks exist for common failure modes | | |
| 41 | On-call ownership and escalation path defined | | |

---

### E.7 Dependency & Capacity Management

| # | Item | Status | Notes |
|---|------|--------|-------|
| 42 | External dependencies documented with owners and SLAs | | |
| 43 | Capacity model exists and is reviewed periodically | | |
| 44 | Cost estimates and budgets are known | | |
| 45 | Chaos or failure-injection testing performed on critical paths | | |

---

### E.8 Minimal Viable Production Bar (Launch Gate)

For a first production release, the following subset is usually considered the minimum acceptable bar. If any of these are Missing, the system is not ready:

- Timeouts + retries + idempotency on critical writes  
- Health checks + basic metrics + structured logging  
- TLS everywhere + secrets from a secret manager  
- Automated deployment with rollback capability  
- Explicit consistency decisions for core data  
- Rate limiting at the edge  
- At least one tested backup/restore path  

Everything else should be planned, but the items above are the ones that most often prevent 3 a.m. disasters.

---

### E.9 How to Use This Checklist

**In interviews**  
When asked “How would you productionize this?”, walk through the sections that matter most for the problem (usually Reliability, Observability, and Operations). You do not need to cover every line — showing that you have a systematic checklist is itself a strong signal.

**In real projects**  
- Copy the checklist into the design doc or RFC.  
- Require a status update before the launch review.  
- Treat “Partial” items as explicit follow-up work with owners and dates.  
- Revisit the checklist after major incidents — many post-mortems reveal items that were marked Done but were not actually effective.

**Scoring tip**  
A useful internal metric is “% of checklist items that are Done for services that have been in production > 6 months.” Tracking this over time shows whether the organization is actually improving its production discipline.

---

**[END OF APPENDIX E]**
