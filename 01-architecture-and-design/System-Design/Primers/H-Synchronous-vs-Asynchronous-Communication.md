# Primer H: Synchronous vs Asynchronous Communication

Almost every multi-service design decision eventually comes down to this question:  
**Should the caller wait for the work to finish, or should it continue and let the work happen later?**

This primer gives you a clear mental model of both styles, their consequences, and when to choose each.

### 1. Synchronous Communication

**Definition**  
The caller sends a request and **blocks** until it receives a response (or an error).

**Mental model**  
A phone call. You dial, wait for the other person to answer, have the conversation, and only then hang up and continue with your day.

**Typical technologies**
- HTTP/REST
- gRPC (unary calls)
- Most database queries
- Direct function calls inside a single process

**Characteristics**
- Simple to reason about: you know the result before you proceed.
- The caller’s latency includes the full time of the callee.
- If the callee is slow or down, the caller is directly affected.
- Natural fit for request/response APIs where the user is waiting.

### 2. Asynchronous Communication

**Definition**  
The caller hands work off (usually by putting a message in a queue or publishing an event) and **continues without waiting** for the work to be finished.

**Mental model**  
Leaving a note in a shared inbox or on a bulletin board. You drop the message and go do something else; someone else will process it later.

**Typical technologies**
- Message queues (SQS, RabbitMQ, etc.)
- Event streams / logs (Kafka, Pulsar, Kinesis)
- Pub/Sub systems
- Background job systems

**Characteristics**
- Caller latency is low (just the cost of enqueuing).
- Callers and workers can scale independently.
- Natural fit for work that does not need to finish before the user gets a response.
- Introduces eventual consistency and the need for retries, idempotency, and monitoring of lag.

### 3. Side-by-Side Comparison

| Aspect                  | Synchronous                          | Asynchronous                            |
|-------------------------|--------------------------------------|-----------------------------------------|
| Caller waits?           | Yes                                  | No                                      |
| Latency for caller      | Includes full downstream work        | Usually just the cost of sending        |
| Failure visibility      | Immediate error to caller            | Failure happens later; harder to surface |
| Scaling                 | Coupled                              | Producers and consumers scale separately |
| Ordering & correctness  | Easier to reason about               | Requires more care (idempotency, retries) |
| Typical user experience | User waits for the full result       | User gets fast acknowledgment, work finishes later |

### 4. When to Choose Synchronous

Prefer synchronous when:

- The user (or upstream service) **needs the result** before continuing.
- The operation is fast and reliable.
- Strong consistency or immediate confirmation is required.
- The call graph is simple and you want easy debugging.

Examples:
- Loading a user’s profile
- Checking inventory before confirming an order
- Authenticating a request
- Fetching data needed to render a page

### 5. When to Choose Asynchronous

Prefer asynchronous when:

- The work is **not required** for the immediate response.
- The work is slow, bursty, or resource-intensive.
- You want to protect the primary request path from downstream failures or load.
- Multiple independent consumers need the same event.
- You are performing fan-out (one event triggers many downstream actions).

Examples:
- Sending a confirmation email
- Updating search indexes
- Generating recommendations
- Processing uploaded videos
- Emitting analytics events
- Notifying many followers

### 6. Hybrid Patterns You Will See Constantly

Most real systems mix both styles:

1. **Synchronous front, asynchronous back**  
   The API accepts a request, does the minimum critical work synchronously, then enqueues the rest.

2. **Request + callback / polling**  
   The service accepts work asynchronously and the client either polls for status or receives a webhook later.

3. **Transactional outbox**  
   A service writes both its business data and an event into the same database transaction, then an async process publishes the event. This keeps the “accept work” step reliable.

### 7. Important Consequences of Going Asynchronous

Once you choose async, you usually also need:

- **Idempotency** – processing the same message twice must be safe.
- **Retries with backoff** – transient failures should not lose work.
- **Dead-letter queues** – permanently failing messages need a place to go.
- **Monitoring of lag** – “How far behind are the consumers?”
- **Ordering decisions** – do you need per-key ordering or is unordered acceptable?

Ignoring these turns a clean async design into a source of subtle production bugs.

### 8. What You Should Be Able to Do After This Primer

- Clearly define synchronous and asynchronous communication.
- Explain the latency, scaling, and failure-visibility trade-offs of each.
- Look at a concrete operation (e.g., “place order”, “send email”, “update search index”) and decide which style is more appropriate.
- Recognize why most production systems are hybrids rather than purely one or the other.
- List at least three additional concerns that appear as soon as you make something asynchronous.

This primer supports the communication discussions in Part 2, the performance patterns in Part 4, and almost every real blueprint in Part 7.

**[END OF PRIMER H]**
