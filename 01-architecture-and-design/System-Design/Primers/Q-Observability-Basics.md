# Primer Q: Observability Basics (Metrics, Logs, Traces)

When a system is running in production, you need ways to understand what it is doing and why it is misbehaving. **Observability** is the ability to ask questions about the system’s internal state using the data it produces. The three primary signals are metrics, logs, and traces. This primer explains each one and how they work together.

### 1. The Core Idea

You cannot SSH into every machine and read minds. Instead, the system must emit data that lets you answer questions such as:

- Is it broken right now?
- How bad is the problem?
- Which component is responsible?
- What happened to a specific user request?

Metrics, logs, and traces are the three complementary ways of producing that data.

### 2. Metrics – “How much / how often / how fast?”

**Metrics** are numeric measurements recorded over time.

Common examples:
- Request rate (requests per second)
- Error rate
- Latency (p50, p95, p99)
- Queue depth
- CPU / memory utilization
- Cache hit ratio
- Active connections

**Characteristics**
- Cheap to collect and store at high volume
- Excellent for dashboards, alerting, and spotting trends
- Aggregate by nature — you see overall behavior, not a single request

**Mental model**  
The gauges and speedometer on a car dashboard. They tell you speed, fuel level, and temperature at a glance, but not the story of a particular trip.

### 3. Logs – “What happened?”

**Logs** are discrete timestamped events, usually text or structured JSON.

Common examples:
- “User 12345 authenticated successfully”
- “Payment failed for order 98765: card declined”
- “Timeout calling recommendation service”

**Characteristics**
- High cardinality and high detail
- Essential for debugging specific incidents
- More expensive to store and search at very large scale
- Structured logs (JSON with consistent fields) are far more useful than free-form text

**Mental model**  
A detailed diary or flight recorder. It tells you the sequence of events, but you may have to dig through a lot of entries.

### 4. Traces – “What was the path of this one request?”

A **trace** follows a single request as it travels through multiple services. Each step is a **span**.

A typical trace might show:
- API gateway received request (2 ms)
- Auth service validated token (5 ms)
- Order service processed order (18 ms)
- Inventory service reserved stock (12 ms)
- Payment service charged card (45 ms)
- Total end-to-end latency: 82 ms

**Characteristics**
- Shows causality and timing across service boundaries
- Invaluable for diagnosing latency and understanding dependencies
- Requires context propagation (usually a trace ID passed in headers)
- Sampling is often used because tracing every request can be expensive

**Mental model**  
A GPS track of one particular journey, including every stop and how long each stop took.

### 5. How the Three Work Together

| Question | Best signal |
|----------|-------------|
| Is error rate elevated right now? | Metrics |
| When did the spike start? | Metrics |
| What exact error message occurred? | Logs |
| Which user or order IDs were affected? | Logs |
| Why is this particular request slow? | Traces |
| Which downstream service is contributing the most latency? | Traces |
| What is the overall health of the service? | Metrics + Health checks |

A mature setup lets you move fluidly between them: an alert on a metric → inspect related logs → look at traces for the slow or failing requests.

### 6. Golden Signals (A Practical Starting Set)

Many teams begin with these four high-level metrics for every user-facing service:

1. **Latency** – how long requests take
2. **Traffic** – how many requests
3. **Errors** – what fraction of requests fail
4. **Saturation** – how full the service’s resources are (CPU, memory, queues, etc.)

These are often called the “Golden Signals.”

### 7. Context Propagation

For traces (and sometimes for structured logs) to work across services, each request needs a unique **trace ID** (and often a span ID) that is passed along in headers. When Service A calls Service B, it includes the trace ID so the two pieces of work can later be stitched together into one trace.

Without propagation, you only have isolated fragments.

### 8. What Good Observability Enables

- Faster incident detection (alerting on metrics)
- Faster diagnosis (logs + traces)
- Capacity planning (traffic and saturation trends)
- Understanding of real user experience (latency percentiles, not just averages)
- Safer deployments (compare metrics before and after a release)

### 9. What You Should Be Able to Do After This Primer

- Define metrics, logs, and traces in one clear sentence each.
- Explain which signal is best suited to different kinds of questions.
- List the four Golden Signals.
- Describe why context propagation is necessary for distributed tracing.
- Argue why averages alone are insufficient for latency (and why percentiles matter).
- Sketch a minimal observability setup for a new service (basic metrics + structured logs + trace propagation).

This primer supports the observability discussions in Part 5 and the production-engineering material in Part 6. It is also essential background for any real-world design review.

**[END OF PRIMER Q]**
