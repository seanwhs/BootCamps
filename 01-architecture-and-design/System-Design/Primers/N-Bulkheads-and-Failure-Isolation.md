# Primer N: Bulkheads and Failure Isolation

Even with timeouts, retries, and circuit breakers, a single failure can still spread if resources are shared carelessly. Bulkheads are the pattern that limits the **blast radius** of a failure. This primer explains the idea and how it appears in real systems.

### 1. The Core Idea

A **bulkhead** isolates resources so that a failure or overload in one part of the system cannot consume all the resources of another part.

**Mental model**  
Ships are divided into watertight compartments (bulkheads). If one compartment is holed and floods, the others stay dry and the ship can remain afloat.

In software the “water” is usually threads, connections, memory, CPU, or queue capacity. The bulkhead is a deliberate separation that prevents one failing or overloaded component from taking everything else down with it.

### 2. Why Isolation Matters

Consider a service that does two things:

- Critical path: process payments and confirm orders.
- Non-critical path: fetch personalized recommendations.

If both paths share the same thread pool and the recommendation service becomes extremely slow, all threads can end up blocked waiting for recommendations. Payment processing then fails even though the payment dependency itself is healthy.

A bulkhead would give the recommendation calls their **own** limited thread pool (or connection pool, or concurrency limit). When recommendations fail or slow down, only that pool is affected. The payment path continues to operate with its own dedicated resources.

### 3. Common Forms of Bulkheads

| Resource being isolated | Typical bulkhead technique |
|-------------------------|----------------------------|
| Threads | Separate thread pools per dependency or per workload type |
| Database connections | Separate connection pools |
| Concurrent requests | Separate concurrency limits / semaphores |
| Queue capacity | Separate queues for different types of work |
| CPU / processes | Separate services or containers |
| Network | Separate connection pools or even separate network paths |
| Tenants | Per-tenant limits, separate clusters, or noisy-neighbor controls |

The principle is the same in every case: **do not let one category of work exhaust a shared resource that other categories depend on**.

### 4. Bulkheads vs Circuit Breakers

The two patterns complement each other:

- **Circuit breaker** – decides whether to *attempt* a call to a dependency.
- **Bulkhead** – limits *how many resources* can be consumed by calls to that dependency (or by a particular type of work).

You often use both:

1. A bulkhead caps the maximum concurrent calls to the recommendation service.
2. A circuit breaker stops calling it entirely once it is clearly unhealthy.

Together they provide defense in depth.

### 5. Practical Examples

**Example 1 – Separate thread pools**  
An application has one pool for core order-processing work and a smaller pool for calls to a flaky external personalization API. The personalization pool can become fully blocked without starving order processing.

**Example 2 – Separate queues**  
Critical commands and low-priority background jobs use different queues and different consumer groups. A flood of background jobs cannot delay critical commands.

**Example 3 – Multi-tenant isolation**  
Each large tenant is given its own rate limit, connection quota, or even a separate compute pool so that one noisy tenant cannot degrade the experience for everyone else.

**Example 4 – Service decomposition**  
Instead of one large service that handles both high-priority and low-priority workloads, the workloads are split into separate services with independent scaling and resource limits.

### 6. Cost of Bulkheads

Isolation is not free:

- More pools or queues mean more configuration and monitoring.
- Resources that are partitioned can sit idle in one partition while another is overloaded (reduced overall utilization).
- Over-isolation can create operational complexity.

The art is to isolate at the boundaries where failure or overload is most dangerous, not to create an unbounded number of tiny partitions.

### 7. Relationship to Other Patterns

- **Timeouts** limit how long a single call can hold a resource.
- **Circuit breakers** stop calling a bad dependency.
- **Back-pressure** signals upstream to slow down.
- **Bulkheads** ensure that even if some calls are stuck or some work is overloaded, the rest of the system still has resources left.

They form a layered defense.

### 8. What You Should Be Able to Do After This Primer

- Explain the bulkhead pattern using the ship analogy.
- Describe why shared thread or connection pools can turn a partial failure into a total failure.
- Give two concrete examples of bulkheads in application design.
- Contrast bulkheads with circuit breakers and explain how they work together.
- Identify places in a design where missing isolation could allow a non-critical feature to harm a critical one.
- Recognize the trade-off between isolation and resource utilization.

This primer supports the reliability and fault-tolerance material in Part 5 and is directly relevant to multi-tenant and multi-dependency designs in later parts.

**[END OF PRIMER N]**
