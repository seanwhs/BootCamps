# Primer J: Idempotency in Plain Language

Idempotency is one of the most important ideas in reliable distributed systems, yet it is often explained in overly abstract terms. This primer makes it concrete and practical.

### 1. The Simple Definition

An operation is **idempotent** if performing it multiple times has the **same effect** as performing it once.

In everyday language:

> Doing it again doesn’t change the result beyond the first time.

### 2. Everyday Examples

| Operation | Idempotent? | Why |
|-----------|-------------|-----|
| Setting a thermostat to 21°C | Yes | Doing it five times still leaves the temperature at 21°C |
| Turning a light switch on | Yes | The light stays on |
| Adding $10 to a bank account | No | Doing it three times adds $30 |
| Creating a user with a specific ID | Yes (if designed properly) | The second attempt finds the user already exists and does nothing (or returns the existing user) |
| Incrementing a counter | No | Each call increases the value |

### 3. Why Idempotency Matters in Distributed Systems

In real systems, the same request can be executed more than once for many reasons:

- The network fails after the server did the work but before the client received the response.
- A retry library automatically retries a timed-out request.
- A message queue delivers the same message at least once.
- A load balancer or proxy retries a request.
- A user double-clicks a submit button.

If the operation is **not** idempotent, these retries cause duplicate side effects: double charges, duplicate orders, extra emails, incorrect counters, etc.

If the operation **is** idempotent, retries become safe.

### 4. How We Make Operations Idempotent

Common techniques:

**1. Idempotency keys**  
The client generates a unique key (UUID, etc.) for each logical operation and sends it with the request. The server stores the key and the result. If the same key arrives again, the server returns the previous result without re-executing the work.

**2. Natural unique constraints**  
Design the operation around a unique business key.  
Example: “Create user with email X” — the second attempt hits a unique constraint and is treated as success (or returns the existing user).

**3. State-based checks**  
Before doing work, check the current state.  
Example: “Cancel order 123” — if the order is already cancelled, do nothing and return success.

**4. Upserts**  
“Insert or update” operations that produce the same final state regardless of how many times they run.

### 5. Safe vs Unsafe HTTP Methods (Reminder)

From an earlier primer:

- `GET`, `PUT`, `DELETE` are intended to be idempotent.
- `POST` is not idempotent by default (which is why we often add idempotency keys to important `POST` endpoints).

### 6. Idempotency and At-Least-Once Delivery

Most modern message queues and event systems promise **at-least-once** delivery. That means:

- You must assume a message can be processed more than once.
- Therefore every consumer must be written as if retries will happen.
- Idempotency (or careful deduplication) is required for correctness.

Chasing “exactly-once” delivery is usually a distraction. Designing for at-least-once + idempotency is the practical and robust approach.

### 7. Where You Will See It in Designs

- Payment and order creation endpoints
- Notification sending
- Inventory reservation
- Any write performed by a background worker
- API endpoints that clients may retry
- Saga steps and compensating actions

When someone says “this operation must be idempotent,” they mean: “It must be safe to execute this more than once without creating incorrect results.”

### 8. What You Should Be Able to Do After This Primer

- Define idempotency in one clear, non-academic sentence.
- Give two everyday examples and two system-design examples.
- Explain why retries and message queues make idempotency necessary.
- Describe at least two practical techniques for making an operation idempotent.
- Recognize when a proposed API or worker is unsafe under retries and suggest how to fix it.

This primer supports the reliability patterns in Part 5, the asynchronous designs in Part 4, and almost every real-world blueprint that involves writes or messaging.

**[END OF PRIMER J]**
