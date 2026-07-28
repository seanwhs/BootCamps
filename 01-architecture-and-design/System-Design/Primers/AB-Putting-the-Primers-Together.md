# Primer AB: Putting the Primers Together – A Mini Design Walkthrough

Individual primers teach concepts. Real design requires combining them. This primer walks through a small but realistic system and explicitly shows which ideas from earlier primers apply at each decision point.

### 1. The Mini Prompt

**Design a URL shortener** that:

- Accepts a long URL and returns a short link.
- Redirects short links to the original URL with very low latency.
- Records basic click counts.
- Must handle high read traffic and moderate write traffic.
- Should be multi-tenant (different customers / API keys have their own links and quotas).

We will not produce a full interview-grade answer. Instead we will highlight how the primers inform the key decisions.

### 2. Step-by-Step Decisions and the Primers They Use

#### A. Requirements & Scale (Primers A, R, Z)

- Clarify latency target for redirects (user-facing, must be fast).
- Estimate redirect QPS vs creation QPS (read-heavy).
- Decide on availability expectations and a rough SLO (e.g., 99.9 % successful redirects).

Relevant primers:  
**A** (latency vs throughput), **R** (SLIs/SLOs), **Z** (preparation checklist).

#### B. High-Level Flow (Primers D, F)

- Client → DNS → Load Balancer / API Gateway → Application service → Cache → Database.
- Redirect path must be extremely lean.
- TLS terminated at the edge / gateway.

Relevant primers:  
**D** (HTTP/TLS), **F** (load balancer).

#### C. Data Model & Storage (Primers C, E, U, W)

- Primary key: short code.
- Store: long URL, owner (tenant), creation time, click counter.
- Short-code generation must avoid collisions.
- Strong consistency for creation (do not hand out the same short code twice).
- Eventual consistency is acceptable for click counts and analytics.
- Multi-tenant: every row carries a `tenant_id`; all queries filter on it.
- Schema evolution later will use expand/contract.

Relevant primers:  
**C** (indexes), **E** (consistency), **U** (expand/contract), **W** (multi-tenancy).

#### D. Caching for Redirects (Primer G)

- Redirect is the hottest path → cache short code → long URL in Redis (or equivalent).
- Cache-aside pattern.
- TTL + invalidation on deletion or update.
- Protect against cache stampedes on very popular links.

Relevant primer:  
**G** (caching).

#### E. Rate Limiting & Quotas (Primers X, W, L)

- Per-tenant (or per-API-key) rate limits on link creation.
- Global and per-tenant limits on redirects if needed for protection.
- Token bucket or sliding window, enforced at the gateway and/or service.
- Quotas prevent noisy-neighbor problems.

Relevant primers:  
**X** (rate limiting), **W** (multi-tenancy), **L** (back-pressure).

#### F. Reliability of the Write Path (Primers J, K, M, N, O)

- Creation must be idempotent (client retries should not create duplicate short links).
- Timeouts on database and cache calls.
- Limited retries with backoff + jitter for transient failures.
- Circuit breaker around the database if it becomes unhealthy.
- Bulkhead so that analytics or click-recording problems cannot starve the redirect path.
- Graceful degradation: if click counting fails, the redirect still succeeds.

Relevant primers:  
**J** (idempotency), **K** (timeouts & retries), **M** (circuit breakers), **N** (bulkheads), **O** (graceful degradation).

#### G. Asynchronous Work (Primer H)

- Click counting and any analytics can be asynchronous.
- Redirect path writes an event or increments a counter out-of-band so the user-facing redirect stays fast.

Relevant primer:  
**H** (sync vs async).

#### H. Security Basics (Primers V, Y)

- Authentication of API clients (API keys or tokens).
- Authorization: a tenant can only manage its own links.
- Secrets (database credentials, signing keys) injected at runtime, never baked into images.

Relevant primers:  
**V** (secrets), **Y** (authn vs authz).

#### I. Operations (Primers P, Q, S, T)

- Liveness and readiness probes.
- Metrics: redirect latency (p99), error rate, cache hit ratio, creation QPS, 429 rate.
- Structured logs with `request_id` and `tenant_id`.
- Traces for the creation path; sampled traces for redirects.
- Rolling or canary deployments.
- Feature flags for any experimental change to the creation or redirect logic.

Relevant primers:  
**P** (health checks), **Q** (observability), **S** (deployments), **T** (feature flags).

### 3. How the Pieces Fit Together

```
Client
  │
  ▼
API Gateway (TLS, authn, rate limiting)
  │
  ▼
Stateless App Instances
  │
  ├──► Redis cache  (hot redirects)
  │
  ├──► Primary DB   (source of truth, strongly consistent creates)
  │
  └──► Async path   (click events → counters / analytics)
```

- Redirects are optimized for latency (cache + lean path + graceful degradation).
- Creates are protected by idempotency, rate limits, and strong uniqueness.
- Multi-tenancy is enforced on every data access and by per-tenant limits.
- Failure of non-critical work (counting, analytics) does not break redirects.
- Observability and health checks make the system operable.

### 4. What This Walkthrough Demonstrates

No single primer is enough. A workable design emerges only when you combine:

- Foundations (latency, consistency, scaling)
- Data and isolation choices
- Caching and async patterns
- Reliability tools (timeouts, retries, idempotency, circuit breakers, bulkheads)
- Security and multi-tenant controls
- Operational practices (health, metrics, deployments, flags)

The Capstone Exercise in Appendix L requires the same style of integrated thinking at a larger scale.

### 5. What You Should Be Able to Do After This Primer

- Take a modest system prompt and map each major decision to concepts from the primers.
- Recognize that real designs are assemblages of many small, deliberate choices.
- Use the same linking process when you tackle the full Capstone or any new design problem.
- Notice gaps in your own knowledge when a decision appears that you cannot yet ground in a primer or series section.

This primer is the bridge between isolated concepts and integrated system design.

**[END OF PRIMER AB]**
