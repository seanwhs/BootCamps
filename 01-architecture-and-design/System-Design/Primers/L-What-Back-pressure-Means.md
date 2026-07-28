# Primer L: What “Back-pressure” Means

Back-pressure is one of the most important ideas for keeping systems stable under load. It is also one of the most frequently ignored. This primer explains what it is, why it matters, and how it appears in real designs.

### 1. The Simple Definition

**Back-pressure** is the ability of a system to say “slow down” to the things that are sending it work, so that it does not become overwhelmed.

In plain language:

> When a component is busy or overloaded, it signals upstream producers to reduce the rate of new work.

Without back-pressure, load keeps arriving even when the system can no longer process it. Queues grow without limit, memory is exhausted, latency explodes, and the system eventually collapses.

### 2. Everyday Analogy

Imagine a coffee shop:

- Customers keep walking in and placing orders.
- The baristas can only make drinks at a certain rate.
- If there is no back-pressure, the line of unfinished orders grows until the counter collapses under piles of cups.
- With back-pressure, the shop either:
  - Stops accepting new orders until the current ones are finished, or
  - Tells customers “there is a 15-minute wait” so some leave, or
  - Opens a limited ticket system so only a fixed number of orders can be in progress.

The same dynamics appear in software.

### 3. Where Back-pressure Appears

| Layer | What “slow down” looks like |
|-------|-----------------------------|
| Thread / connection pools | New requests wait or are rejected when the pool is full |
| Message queues | Producers block or receive errors when the queue reaches a limit |
| HTTP APIs | 429 Too Many Requests or 503 Service Unavailable |
| Load balancers / gateways | Rate limiting or connection limits |
| Stream processing | Consumers slow the commit / acknowledgement rate, which slows producers |
| Databases | Connection limits and query queues |

### 4. Bounded vs Unbounded Queues

This is the most practical place where back-pressure is won or lost.

- **Unbounded queue**  
  Producers can keep adding work forever. Under overload the queue grows until the process runs out of memory and crashes. This is a classic outage pattern.

- **Bounded queue**  
  The queue has a maximum size. When it is full, producers are forced to wait, drop work, or receive an error. That signal *is* back-pressure.

Most production systems prefer bounded queues (or other bounded buffers) precisely so that overload becomes visible and controllable instead of turning into a silent memory leak.

### 5. Common Strategies for Applying Back-pressure

1. **Reject early** (load shedding)  
   Return an error quickly when the system is saturated so the caller can decide what to do.

2. **Block the producer**  
   Make the producer wait until there is capacity (common inside a single process or with certain queue clients).

3. **Rate limiting**  
   Limit how many requests a client or tenant can send per unit time.

4. **Adaptive concurrency limits**  
   Dynamically adjust how many concurrent requests are allowed based on observed latency or error rates.

5. **Credit-based or window-based flow control**  
   Used in many networking and streaming protocols: the receiver tells the sender how much more data it is willing to accept.

### 6. Relationship to Other Reliability Patterns

- **Timeouts** detect that work is taking too long.
- **Retries** try again after a transient failure.
- **Circuit breakers** stop calling a dependency that is clearly unhealthy.
- **Back-pressure** prevents the system from accepting more work than it can handle in the first place.

They are complementary. A system with retries but no back-pressure can still drown itself in retry traffic. A system with back-pressure but no timeouts can still hold resources forever.

### 7. Typical Failure Mode Without Back-pressure

1. Traffic spikes or a dependency slows down.
2. Work queues grow rapidly.
3. Memory usage climbs.
4. Garbage collection or swapping makes the system even slower.
5. Latency goes to infinity and the service crashes or becomes unusable.
6. Clients retry, making the load even worse.

This pattern is extremely common in production incidents.

### 8. What Good Looks Like

A healthy design usually includes:

- Bounded queues or explicit concurrency limits
- Clear signals to upstream when capacity is exhausted
- Load shedding of non-critical work under extreme pressure
- Metrics on queue depth, rejection rate, and processing lag
- Alerts that fire while there is still time to react

### 9. What You Should Be Able to Do After This Primer

- Define back-pressure in one plain sentence.
- Explain why unbounded queues are dangerous.
- Give two concrete examples of how a system can signal “slow down.”
- Describe the relationship between back-pressure, timeouts, and retries.
- Look at a design and identify where missing back-pressure could cause an outage.
- Suggest at least one practical way to add back-pressure to a common component (API, queue consumer, worker pool).

This primer supports the reliability and scaling discussions in Parts 4 and 5 and is relevant to almost every high-throughput design in Part 7.

**[END OF PRIMER L]**
