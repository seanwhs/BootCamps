# Primer A: Latency, Throughput, and What Happens When You Click a Button

Before we design large systems, we need a clear, shared picture of two numbers and one journey.

### 1. Latency vs Throughput

These two words are used constantly and often mixed up.

**Latency** is the time it takes for *one* request to finish.  
**Throughput** is how many requests the system can finish *per unit of time*.

Simple analogy:

- Latency = how long *you* wait for your coffee after ordering.
- Throughput = how many coffees the shop can hand out in an hour.

A system can have excellent latency for a single user and still collapse under high throughput (many users at once). The reverse is also possible: high throughput with painful latency.

When people say “the system is slow,” they usually mean latency. When they say “the system can’t handle the load,” they usually mean throughput.

### 2. The Journey of a Single Click

When you click a button in a web or mobile app, a surprising number of steps occur. Here is a simplified but realistic path:

1. **Your device** prepares an HTTP request and hands it to the operating system.
2. **DNS lookup** – Your device asks “What is the IP address of api.example.com?” (this result is often cached).
3. **TCP connection** (and usually TLS handshake) – A secure connection is established to a server.
4. **Edge / CDN / Load Balancer** – The request first hits a globally distributed edge or a load balancer that decides which backend machine should handle it.
5. **Application server** – The code that knows the business logic runs. It may talk to caches, databases, or other services.
6. **Database or external services** – Data is read or written.
7. **Response travels back** through the same path (application → load balancer → edge → your device).
8. **Your device** renders the result.

Every one of these steps adds a little latency. The total latency the user feels is the sum of all of them (plus any queueing delays when the system is busy).

### 3. Why This Matters for System Design

Almost every design decision is an attempt to improve latency, throughput, or both, under constraints:

- Putting a cache in front of a database → lower latency for repeated reads, higher effective throughput.
- Adding more application servers behind a load balancer → higher throughput.
- Moving static files to a CDN → much lower latency for users far from your main data center.
- Making a service asynchronous → the user-facing request finishes faster (better latency) even if the total work remains the same.

When we later talk about “bottlenecks,” we mean the step in the journey above that is currently limiting either latency or throughput.

### 4. Order-of-Magnitude Feel for Latency

Useful rough numbers to keep in your head:

| Step                              | Typical latency          |
|-----------------------------------|--------------------------|
| Reading from memory (RAM)         | ~100 nanoseconds         |
| Reading from SSD                  | ~100 microseconds        |
| Network round-trip (same region)  | 0.5–2 milliseconds       |
| Network round-trip (cross-continent) | 50–150 milliseconds  |
| Database point query (good case)  | 1–5 milliseconds         |
| Full page load users consider “fast” | under 100–200 ms     |

These numbers explain why we work so hard to avoid extra network hops and why caches are powerful.

### 5. What You Should Be Able to Do After This Primer

- Correctly distinguish latency from throughput in any conversation.
- Describe, in plain language, the main hops a request takes from device to database and back.
- Explain why adding more servers does not automatically improve latency for a single user.
- Look at a simple system and point to the places most likely to add significant latency.

You now have the basic vocabulary and mental model that Part 1 of the series builds on directly.

**[END OF PRIMER A]**
