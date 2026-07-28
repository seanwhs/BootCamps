# Primer AC: Messaging Semantics (At-Most-Once, At-Least-Once, Exactly-Once)

When services communicate through queues or event streams, the delivery guarantee determines how you must write consumers and what correctness properties you can claim. This primer explains the three classic semantics in plain language and shows what they imply in practice.

### 1. The Core Question

If a producer sends a message, how many times will the consumer process it?

The answer is almost never “exactly once” by default. Distributed systems have failures, retries, network partitions, and crashes. Messaging systems therefore offer different delivery guarantees, and each guarantee places different responsibilities on the application.

### 2. At-Most-Once Delivery

**Meaning**  
A message is delivered zero or one time. It may be lost; it will never be delivered (and processed) more than once.

**How it arises**
- Fire-and-forget (no acknowledgement)
- Consumer crashes after receiving the message but before processing it, and the message is not redelivered

**Characteristics**
- Simplest and lowest overhead
- Possible data loss
- No duplicate processing

**When it is acceptable**
- Metrics and non-critical telemetry
- Best-effort notifications where loss is tolerable
- Situations where losing some messages is better than risking duplicates

**Mental model**  
Dropping a letter in a mailbox that sometimes catches fire. The letter may never arrive, but it will not arrive twice.

### 3. At-Least-Once Delivery

**Meaning**  
A message is delivered one or more times. It will not be lost (assuming the messaging system itself is durable), but the consumer may see it more than once.

**How it arises**
- Consumer receives the message, processes it, then crashes before acknowledging
- Network failure after processing but before acknowledgement
- Automatic retries by the broker or client library

**Characteristics**
- No loss (under normal durability assumptions)
- Possible duplicate processing
- The most common practical guarantee in production systems

**When it is used**
- Almost all business-critical event processing
- Order events, payment events, notification commands, etc.

**Requirement it imposes**  
Consumers **must be idempotent** (or must perform their own deduplication). Processing the same message twice must not create incorrect results.

**Mental model**  
A reliable postal service that will keep trying until the letter is signed for. You may occasionally receive two copies; your process for handling the letter must tolerate that.

### 4. Exactly-Once Delivery / Processing

**Meaning**  
The message is processed effectively one time. No loss, no visible duplicates.

**Reality check**  
True end-to-end exactly-once processing is difficult and often expensive. Many systems that advertise “exactly-once” provide it only under specific conditions or only within a limited scope (for example, within a single stream-processing framework with transactional sinks).

**Common approaches**
- Idempotent consumers + at-least-once delivery (effectively exactly-once from a business perspective)
- Transactional outbox + idempotent consumers
- Exactly-once stream processing features (Kafka transactions, certain Flink configurations, etc.) with careful sink design
- Deduplication tables or idempotency keys stored durably

**When people ask for it**
- Financial movements, inventory changes, and other cases where duplicates are highly painful
- Even then, the practical solution is usually “at-least-once + strong idempotency” rather than a magical exactly-once transport

**Mental model**  
You want the effect of the letter to happen once, even if the postal system sometimes delivers two copies. You achieve that by making the act of opening and acting on the letter safe to repeat.

### 5. Comparison Table

| Semantic        | Loss possible? | Duplicates possible? | Consumer requirement          | Typical use |
|-----------------|----------------|----------------------|-------------------------------|-------------|
| At-most-once    | Yes            | No                   | None beyond normal logic      | Metrics, best-effort |
| At-least-once   | No*            | Yes                  | Idempotency or deduplication  | Most business events |
| Exactly-once    | No             | No (effectively)     | Strong idempotency or transactional support | High-stakes state changes |

\*Assuming the broker and its storage are durable and correctly configured.

### 6. Practical Design Rules

1. Default to **at-least-once** for any important work.
2. Make every consumer **idempotent**.
3. Use **idempotency keys** or natural unique business keys for any operation that has side effects.
4. Treat “exactly-once” claims with skepticism; ask “exactly-once *under what failure scenarios* and *across which boundaries*?”
5. Prefer simple, well-understood patterns (at-least-once + idempotency) over complex transactional messaging unless the complexity is clearly justified.
6. Monitor lag, retry rates, dead-letter queues, and duplicate rates.

### 7. Relationship to Earlier Primers

- **Idempotency (Primer J)** is the main tool that makes at-least-once safe.
- **Timeouts, retries, and backoff (Primer K)** interact heavily with messaging clients.
- **Back-pressure (Primer L)** appears when consumers cannot keep up.
- **Synchronous vs asynchronous (Primer H)** is the broader context in which these semantics live.
- **Transactional outbox** patterns (mentioned in the main series) are a common way to get reliable publishing with at-least-once semantics.

### 8. What You Should Be Able to Do After This Primer

- Define at-most-once, at-least-once, and exactly-once in plain language.
- Explain why at-least-once is the most common practical choice.
- State the main application-level requirement that at-least-once imposes.
- Argue why true end-to-end exactly-once is hard and what teams usually do instead.
- Choose an appropriate semantic for a given use case (metrics vs payments vs notifications).
- Connect messaging semantics to idempotency and consumer design.

This primer supports the asynchronous-processing and reliability material in Parts 4 and 5 and is essential for any design that uses queues or event streams.

**[END OF PRIMER AC]**
