# Primer M: Circuit Breakers in Plain Language

When one service depends on another, a failure or slowdown in the dependency can cascade and take down the caller as well. Circuit breakers are a standard pattern for stopping that cascade. This primer explains how they work and when to use them.

### 1. The Core Idea

A **circuit breaker** monitors calls to a dependency. If the dependency starts failing (or becoming too slow) beyond a threshold, the circuit “opens” and further calls are **immediately rejected** without even trying the dependency. After a period of time, the circuit allows a limited number of test requests; if those succeed, the circuit closes again.

**Mental model**  
An electrical circuit breaker in a house. When too much current flows (a fault), the breaker trips and cuts power so the rest of the house is protected. After the fault is cleared, the breaker can be reset.

### 2. The Three States

Most circuit breakers have three states:

| State | Behavior | Meaning |
|-------|----------|---------|
| **Closed** | Requests flow normally | Everything looks healthy |
| **Open** | Requests fail immediately (fail-fast) | Dependency is considered unhealthy; protect the caller |
| **Half-Open** | A small number of test requests are allowed | Probe whether the dependency has recovered |

Typical transition logic:

1. While **Closed**, count failures (or slow calls).
2. When failures exceed a threshold → go to **Open**.
3. While **Open**, reject requests and start a timer.
4. When the timer expires → go to **Half-Open**.
5. In **Half-Open**, let a few requests through:
   - If they succeed → go back to **Closed**.
   - If they fail → go back to **Open**.

### 3. Why Circuit Breakers Help

Without a circuit breaker:

- Your threads/connections stay blocked waiting for a dying dependency.
- Timeouts eventually fire, but only after consuming resources.
- Retries can amplify the load on the already-struggling dependency.
- The failure spreads upstream.

With a circuit breaker:

- You fail fast once the dependency is known to be unhealthy.
- Resources in the caller are protected.
- The dependency gets a chance to recover without being hammered by continuous traffic.
- You can serve a fallback response (cached data, default value, degraded experience) instead of waiting for a timeout.

### 4. What to Measure

Circuit breakers usually track:

- Error rate (percentage of failed calls)
- Slow call rate (calls that exceed a latency threshold)
- Absolute number of failures in a time window
- Sometimes consecutive failures

You configure thresholds that match the dependency’s expected behavior. A dependency that is normally very reliable can have a tighter threshold than one that is known to be occasionally flaky.

### 5. Relationship to Timeouts and Retries

These three patterns work best together:

- **Timeouts** detect that a single call is taking too long.
- **Retries** (with backoff) handle occasional transient failures.
- **Circuit breakers** stop calling a dependency that is repeatedly failing or slow.

A common healthy pattern:

1. Each call has a timeout.
2. Transient failures may be retried a small number of times.
3. If the overall failure rate becomes too high, the circuit opens and further calls (including retries) are short-circuited until the dependency recovers.

### 6. Fallbacks

When the circuit is open, you often want to do something better than just returning an error:

- Return cached data
- Return a default or degraded response
- Skip a non-critical feature
- Queue the work for later (if appropriate)

The circuit breaker itself only decides whether to attempt the call. The fallback policy is application logic that runs when the call is not attempted or fails.

### 7. Common Places to Use Circuit Breakers

- Calls to external payment providers
- Calls to recommendation or personalization services
- Calls to search clusters
- Calls to any dependency that is not on the absolute critical path
- Cross-region or cross-zone remote calls

They are less critical for extremely reliable, low-latency local dependencies (for example, a co-located Redis used as a pure cache), but still useful when the cost of failure is high.

### 8. What Circuit Breakers Do *Not* Solve

- They do not fix the underlying dependency problem.
- They do not replace proper timeouts.
- They do not make non-idempotent operations safe to retry.
- They do not eliminate the need for monitoring and alerting.

They are a protection mechanism for the caller, not a cure for the callee.

### 9. What You Should Be Able to Do After This Primer

- Explain the circuit-breaker pattern with the electrical analogy.
- Describe the three states and the typical transitions.
- State why failing fast is often better than waiting for timeouts under heavy failure.
- Relate circuit breakers to timeouts and retries.
- Give two realistic examples of where you would place a circuit breaker and what fallback you might use.
- Recognize that a circuit breaker is a form of load shedding and failure isolation for remote calls.

This primer supports the fault-tolerance material in Part 5 and appears in any design that has non-critical or less-reliable dependencies.

**[END OF PRIMER M]**
