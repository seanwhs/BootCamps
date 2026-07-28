# Primer K: Timeouts, Retries, and Why They Belong Together

In distributed systems, calls to other services fail or become slow. How you handle those failures determines whether your system stays resilient or collapses under partial outages. Timeouts and retries are the two most basic tools. This primer explains each one and why they must be designed together.

### 1. Timeouts – “Don’t Wait Forever”

A **timeout** is a limit on how long you are willing to wait for a response before giving up.

Without timeouts:
- A slow dependency can hold your threads or connections indefinitely.
- Thread pools and connection pools become exhausted.
- Latency cascades through the system.
- One unhealthy service can take down many others.

**Mental model**  
You call a friend and say “If you don’t answer in 10 seconds, I’m hanging up and doing something else.”

Good practice:
- Almost every remote call (HTTP, gRPC, database, cache, queue) should have an explicit timeout.
- Timeouts should be shorter than the caller’s own timeout so failures surface quickly.
- Different operations often need different timeouts (a user profile lookup vs a complex report).

### 2. Retries – “Try Again, Carefully”

A **retry** means attempting the same operation again after a failure.

Retries are useful for **transient** failures:
- Temporary network glitches
- Short-lived overload
- Brief database failovers
- Momentary rate limiting

Retries are dangerous for **non-transient** failures or when the operation is not idempotent:
- Permanent 400-level client errors
- Business-logic rejections
- Operations that would create duplicates (charges, emails, etc.)

### 3. Why Timeouts and Retries Must Be Designed Together

Timeouts without retries → users see frequent failures for temporary problems.  
Retries without timeouts → you can wait a very long time and still amplify load.

They form a pair:

1. Set a reasonable timeout so you detect problems quickly.
2. Decide whether the failure is worth retrying.
3. If you retry, do so with **backoff** and **jitter**.

### 4. Exponential Backoff + Jitter

Naïve retries (retry immediately, or retry at fixed intervals) can create a **thundering herd**: many clients retry at the same moment and overwhelm a recovering service.

**Exponential backoff**  
Wait longer after each failure: 100 ms, 200 ms, 400 ms, 800 ms, …

**Jitter**  
Add randomness so not all clients retry in lockstep.

A common pattern is “full jitter”: choose a random delay between 0 and the current exponential ceiling.

This combination dramatically reduces the risk of retry storms.

### 5. Retry Budgets and Limits

Unbounded retries are dangerous. Practical controls include:

- **Maximum number of attempts** (e.g., 3 total tries)
- **Maximum total time** spent retrying
- **Retry budget** – limit the percentage of traffic that may be retries so the system cannot be dominated by retry traffic
- **Circuit breakers** (covered in a later primer) that stop retrying a dependency that is clearly down

### 6. Idempotency Is Required for Safe Retries

If an operation is not idempotent, retrying it can create duplicate side effects (double charges, duplicate records, extra notifications).

Therefore:

> Only retry operations that are safe to perform more than once,  
> or make them safe with idempotency keys / unique constraints / state checks.

This is why the previous primer on idempotency sits directly next to this one.

### 7. Common Practical Patterns

| Situation | Typical approach |
|-----------|------------------|
| Read from cache or database | Short timeout + a few retries with backoff |
| Payment charge | Timeout + retries only with an idempotency key |
| Sending an email | Async + retries in the background worker (with idempotency) |
| Critical user-facing mutation | Timeout, limited retries, clear error to the user if still failing |
| Non-critical background work | More aggressive retries + dead-letter queue for permanent failures |

### 8. What Good Looks Like

A well-behaved service call typically includes:

- Explicit timeout
- Limited number of retries
- Exponential backoff with jitter
- Idempotency (when the operation has side effects)
- Metrics on timeout rate, retry rate, and final failure rate
- Clear distinction between transient and permanent errors

### 9. What You Should Be Able to Do After This Primer

- Explain why every remote call needs a timeout.
- Describe the danger of retries without backoff.
- Define exponential backoff and jitter and why they are used together.
- State the relationship between retries and idempotency.
- Look at a proposed service call and recommend sensible timeout + retry behavior.
- Recognize retry storms as a failure mode and describe how to reduce them.

This primer is foundational for the reliability patterns in Part 5 and appears whenever services communicate in the later architectural blueprints.

**[END OF PRIMER K]**
