# Primer R: SLOs, SLIs, and Error Budgets at a Glance

Once you can observe a system, the next question is: “How reliable does it actually need to be?” SLIs, SLOs, and error budgets give teams a precise, shared language for answering that question. This primer introduces the three concepts and how they work together.

### 1. The Core Problem

Saying “the system should be reliable” is too vague. Different people interpret it differently, and without a clear target it is hard to decide:

- How hard should we work on reliability versus new features?
- When is an incident serious enough to page someone at 3 a.m.?
- Is the current reliability good enough, or do we need to invest more?

SLIs, SLOs, and error budgets turn vague wishes into measurable, actionable targets.

### 2. SLI – Service Level Indicator

An **SLI** is a quantitative measure of some aspect of the service’s behavior.

Common examples:
- Availability: proportion of successful requests
- Latency: proportion of requests faster than some threshold
- Throughput: requests processed per second (less common as a reliability SLI)
- Freshness: how up-to-date a particular piece of data is
- Correctness: proportion of results that match expectations

**Good SLIs** are:
- Measured from the user’s point of view (or as close as possible)
- Aggregatable over time
- Directly related to user experience

**Mental model**  
The raw measurement — the number you can put on a graph.

### 3. SLO – Service Level Objective

An **SLO** is a target value (or range) for an SLI over a period of time.

Examples:
- 99.9 % of requests in a rolling 30-day window succeed
- 99 % of API requests complete in under 200 ms
- 99.95 % of payment attempts are processed correctly

The SLO is the promise (or internal goal) you are trying to keep.

**Key point**: SLOs are chosen by the business and engineering team together. They are not automatically “as high as possible.” Higher SLOs are exponentially more expensive to achieve.

### 4. Error Budget – The Derived Allowance

Once you have an SLO, the **error budget** is simply the amount of unreliability you are allowed.

Example:
- SLO = 99.9 % availability over 30 days
- Allowed failure rate = 0.1 %
- 30 days ≈ 43 200 minutes
- Error budget ≈ 43.2 minutes of downtime (or equivalent failed requests) per month

If you have consumed only 10 minutes of the budget so far this month, you still have room. If you have already used 40 minutes, you should become very cautious about risky changes.

**Mental model**  
The error budget is the “reliability spending money” you can use on incidents, experiments, and releases. When it is gone, you stop spending and focus on stability.

### 5. How the Three Work Together

```
SLI  →  the measurement
SLO  →  the target for that measurement
Error budget  →  how much room you have left before you miss the target
```

Practical uses of the error budget:

- **Release decisions**: If the budget is nearly exhausted, freeze risky deployments.
- **Prioritization**: If the budget is consistently exhausted, invest in reliability work.
- **Incident response**: The severity of an incident can be judged partly by how much budget it consumes.
- **Communication**: Gives product and engineering a shared, non-emotional language about reliability.

### 6. Choosing Good SLOs (Practical Advice)

- Start from user experience, not from internal component metrics.
- Prefer fewer, better SLOs over a large collection of mediocre ones.
- Use percentiles for latency (p95 or p99), not averages.
- Set targets that are achievable with the current architecture; then improve the architecture if higher targets are truly required.
- Review SLOs periodically — they are not set in stone forever.

Common starting points many teams use:

| Service type | Typical availability SLO |
|--------------|--------------------------|
| Critical user-facing API | 99.9 % – 99.99 % |
| Internal non-critical service | 99 % – 99.9 % |
| Batch / analytics pipeline | Often measured by freshness or completion time rather than pure availability |

### 7. Relationship to Observability

- **SLIs** are usually calculated from metrics (and sometimes from traces or logs).
- Dashboards and alerts are often built directly on SLI/SLO compliance.
- Error-budget burn rate is a particularly useful alerting signal: it tells you how quickly you are consuming the remaining budget.

### 8. What You Should Be Able to Do After This Primer

- Define SLI, SLO, and error budget in one clear sentence each.
- Explain how an error budget is derived from an SLO.
- Give two realistic SLI examples and matching SLO targets.
- Describe at least two ways a team can use an error budget to make decisions.
- Argue why “make it as reliable as possible” is not a good engineering objective.
- Relate SLOs back to the Golden Signals and user experience.

This primer supports the production-engineering and reliability discussions in Parts 5 and 6 and gives you the language used in mature operations and SRE-style teams.

**[END OF PRIMER R]**
