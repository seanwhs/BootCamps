# Primer Z: The Capstone Preparation Checklist

You now have the full series plus a large set of focused primers. The final step before (or while) tackling the Capstone Exercise in Appendix L is to make sure the key ideas are ready at hand. This primer is a practical checklist you can use to prepare.

### 1. Purpose

The Capstone (a multi-tenant real-time collaborative task platform) forces you to combine almost every major theme of the series. This checklist helps you surface the concepts you will need so you do not forget them under time pressure.

Use it in three ways:

- As a pre-flight review before you start the Capstone.
- As a quick open-book reference while you work.
- As a post-mortem tool after you finish: which items did you miss or handle weakly?

### 2. Foundations & Mental Models

- [ ] I can clearly distinguish latency vs throughput and availability vs reliability.
- [ ] I can describe the path of a request from client → edge → service → data store and back.
- [ ] I understand vertical vs horizontal scaling and why stateless services make horizontal scaling easier.
- [ ] I can explain strong vs eventual consistency and give examples of data that need each.
- [ ] I know what CAP/PACELC imply for real design choices.

### 3. Networking & Traffic

- [ ] I can explain L4 vs L7 load balancing and common selection algorithms.
- [ ] I know what an API Gateway typically handles (routing, auth, rate limiting, TLS termination).
- [ ] I understand the difference between synchronous and asynchronous communication and when to use each.
- [ ] I can describe basic rate-limiting algorithms (token bucket, sliding window) and where to place them.

### 4. Data & Storage

- [ ] I can choose between relational, document, key-value, and other store types based on access patterns.
- [ ] I understand indexing at a practical level (what it helps, what it costs).
- [ ] I can explain sharding/partitioning and the importance of the partition key.
- [ ] I know the expand/contract pattern for safe schema changes.
- [ ] I can sketch a Saga-style approach for multi-step business workflows.

### 5. Caching & Performance

- [ ] I can describe cache-aside and the main cache placement layers.
- [ ] I understand TTLs, invalidation, and the risk of cache stampedes.
- [ ] I know why we prefer stateless application tiers and where state should live instead.

### 6. Reliability & Failure Handling

- [ ] I can explain timeouts, retries with backoff + jitter, and why they belong together.
- [ ] I understand idempotency and how to achieve it (keys, unique constraints, state checks).
- [ ] I can describe circuit breakers, bulkheads, and graceful degradation.
- [ ] I know what back-pressure is and why unbounded queues are dangerous.
- [ ] I can distinguish liveness vs readiness health checks.

### 7. Security & Isolation

- [ ] I clearly distinguish authentication (“who are you?”) from authorization (“what may you do?”).
- [ ] I understand basic multi-tenant data isolation and noisy-neighbor protection.
- [ ] I know the core rules of secrets management (no secrets in git or images, inject at runtime, least privilege, rotatable).
- [ ] I can sketch a reasonable approach to service-to-service identity.

### 8. Operations & Delivery

- [ ] I can compare rolling, canary, and blue-green deployments.
- [ ] I understand how feature flags decouple deployment from release.
- [ ] I can list the Golden Signals and the basic roles of metrics, logs, and traces.
- [ ] I understand SLIs, SLOs, and error budgets at a high level.
- [ ] I know what a minimal production-readiness bar looks like.

### 9. Capstone-Specific Focus Areas

These are the topics the Capstone most heavily exercises. Make sure you are comfortable with them:

- [ ] Multi-tenant data model and enforcement of tenant isolation
- [ ] Real-time updates (WebSockets or similar) and fan-out to connected clients
- [ ] Consistency choices for task mutations vs secondary views (search, feeds, notifications)
- [ ] Search indexing approach and freshness trade-offs
- [ ] Notification path (async, idempotent, multi-channel)
- [ ] File attachment handling (direct-to-object-storage, access control)
- [ ] Noisy-neighbor defenses (per-tenant rate limits, quotas, isolation)
- [ ] Failure modes and graceful degradation for real-time and non-critical features
- [ ] Observability that can answer tenant-specific questions
- [ ] Safe evolution (schema changes, feature rollout, deployments)

### 10. How to Use This Checklist with the Capstone

1. Skim the checklist and mark any item you cannot explain out loud in 60–90 seconds.
2. Revisit the corresponding primer or series section for the weak items.
3. Start the Capstone (Appendix L) with a timer.
4. After you finish, return to the checklist and honestly mark what you covered well, partially, or missed.
5. The gaps become your next focused practice targets.

### 11. Final Mindset Reminder

A strong Capstone answer does not require perfection on every bullet above. It does require:

- Clear requirements and assumptions
- Explicit scale estimates
- A coherent high-level design
- Thoughtful decisions on the hardest parts (real-time, multi-tenancy, consistency, isolation)
- Honest discussion of trade-offs and failure modes
- A realistic view of how the system would be operated and evolved

If you can do that, you are demonstrating the skill the entire series set out to build.

**[END OF PRIMER Z]**
