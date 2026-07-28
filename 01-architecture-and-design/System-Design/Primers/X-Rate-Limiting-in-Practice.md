# Primer X: Rate Limiting in Practice

Rate limiting protects systems from overload, abuse, and noisy neighbors. It appears at the edge, at API gateways, inside services, and around expensive dependencies. This primer covers the practical algorithms, placement decisions, and design considerations you will actually use.

### 1. Why Rate Limiting Exists

Without rate limits:

- A single client (or bug, or attack) can consume enough resources to degrade the service for everyone.
- Expensive operations (search, exports, AI calls, password resets) can be abused.
- Dependencies can be overwhelmed by sudden bursts.
- Cost can spiral in metered cloud services.

Rate limiting enforces a controlled maximum rate of requests (or other units of work) per client, tenant, IP, API key, or other dimension.

### 2. The Two Most Common Algorithms

#### Token Bucket

- A bucket holds up to *N* tokens.
- Tokens are added at a steady rate of *R* per second.
- Each request consumes one token.
- If the bucket is empty, the request is rejected (or delayed).

**Properties**
- Allows short bursts up to the bucket capacity.
- Steady-state rate is limited to *R*.
- Simple and widely implemented.

**Mental model**  
A bucket of tickets that refills at a constant speed. You can spend a handful quickly, then you must wait for more tickets to appear.

#### Sliding Window (and Sliding Window Log / Counter)

- Count how many requests occurred in the last *T* seconds.
- If the count would exceed the limit, reject the new request.

**Properties**
- Smooth and precise.
- No “boundary burst” problem that fixed windows have.
- Can use more memory (especially the pure log version that stores timestamps).

**Mental model**  
Look at the last *T* seconds through a moving window and refuse new work once the limit inside that window is reached.

Many production systems use token bucket for its simplicity and burst friendliness, or a sliding-window counter for more accurate enforcement.

### 3. Where to Place Rate Limiters

| Location | Typical purpose |
|----------|-----------------|
| Edge / CDN / WAF | Coarse protection against DDoS and extreme abuse |
| API Gateway | Per-API-key, per-user, or per-tenant limits; consistent enforcement |
| Application service | Business-specific limits (e.g., “max 5 exports per hour”) |
| Around expensive dependencies | Protect databases, search clusters, third-party APIs |
| Per-tenant or per-user | Noisy-neighbor control in multi-tenant systems |

Best practice is **defense in depth**: coarse limits at the edge plus finer, business-aware limits closer to the application.

### 4. Dimensions You Commonly Limit On

- IP address
- Authenticated user ID
- API key
- Tenant / workspace ID
- Combination (e.g., user + endpoint)
- Global (whole service)

Choosing the right dimension is as important as choosing the algorithm. Limiting only by IP is often too crude; limiting only by user can still allow one tenant to hurt others if many users belong to the same tenant.

### 5. What Happens When the Limit Is Exceeded

Common responses:

- Return `429 Too Many Requests`
- Include headers such as `Retry-After`, `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`
- Optionally queue or delay the request instead of rejecting it (more complex)
- Log and metric the event for monitoring and abuse detection

Clients should be written to respect `Retry-After` and to back off.

### 6. Distributed Rate Limiting

When many application instances are running, an in-memory counter on each instance is not sufficient — the effective limit becomes *N × local limit*.

Solutions:

- Centralized store (Redis is the most common) that all instances consult
- Local approximation with periodic reconciliation (more complex)
- Edge or gateway enforcement so the limit is applied before traffic fans out to many instances

For most systems a Redis-backed token bucket or sliding window is the pragmatic choice.

### 7. Design Considerations

- **Burst vs steady rate** — Decide whether short bursts are acceptable.
- **Fairness** — Should one power user be able to consume the entire budget?
- **Visibility** — Expose clear errors and headers so legitimate clients can adapt.
- **Bypass paths** — Internal health checks and certain system traffic usually need exemptions.
- **Cost of the limiter itself** — The rate limiter must be highly available and low-latency; it should not become a new bottleneck or single point of failure.
- **Idempotency and retries** — Clients that retry aggressively can make rate limiting more painful; combine with good retry policy guidance.

### 8. Relationship to Other Patterns

- **Back-pressure** — Rate limiting is one concrete way of applying back-pressure to clients.
- **Bulkheads / multi-tenancy** — Per-tenant rate limits are a primary noisy-neighbor defense.
- **Circuit breakers** — Protect your service from dependencies; rate limits protect your service (and its dependencies) from clients.
- **Observability** — Rate-limit counters and 429 rates are important signals.

### 9. What You Should Be Able to Do After This Primer

- Explain token bucket and sliding window in plain language.
- Choose sensible dimensions (user, tenant, IP, API key) for a given problem.
- Decide where in the architecture rate limits should be enforced.
- Describe what a well-behaved 429 response looks like.
- Explain why distributed rate limiting usually needs a shared store.
- Relate rate limiting to noisy-neighbor control and back-pressure.

This primer supports the traffic-management material in Part 2, the reliability patterns in Part 5, and the multi-tenant and production topics in Part 6.

**[END OF PRIMER X]**
- Primer AA: Common Observability Anti-Patterns
