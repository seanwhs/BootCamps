# Primer AA: Common Observability Anti-Patterns

Having metrics, logs, and traces is not enough. Many teams collect large amounts of telemetry and still cannot diagnose production problems quickly. This primer catalogs the most frequent observability mistakes and the practical corrections.

### 1. The Core Problem

Observability fails in two opposite ways:

- Too little signal → you cannot answer important questions.
- Too much noise → the important signal is buried and alerts become ignored.

Most anti-patterns fall into one of those two categories (or into “wrong signal for the question”).

### 2. Anti-Pattern Catalog

| Anti-Pattern | What it looks like | Why it hurts | Better approach |
|--------------|--------------------|--------------|-----------------|
| **Averaging latency only** | Dashboards show only mean / average latency | Hides tail latency; a few very slow requests can ruin user experience while the average looks fine | Track at least p95 and p99 (and ideally histograms) |
| **Alerting on CPU / memory alone** | Pages fire when CPU > 80 % | Resource usage is a cause, not the user symptom; many serious issues do not show up as high CPU | Alert on user-facing SLIs (error rate, latency, availability) first; use resource metrics for diagnosis |
| **High-cardinality labels everywhere** | Metrics labeled with user ID, full URL, request ID, etc. | Explodes metric cardinality, costs, and query performance | Keep metrics low-to-medium cardinality; put high-cardinality data in logs or traces |
| **Unstructured logs** | Free-form text strings with no consistent fields | Hard to search, filter, or aggregate; slow incident response | Emit structured logs (JSON) with consistent field names (`request_id`, `tenant_id`, `error_code`, etc.) |
| **No request / trace context** | Logs and metrics from different services cannot be correlated | Impossible to follow one user request across the system | Propagate a trace ID (and request ID) and include it in logs and spans |
| **Tracing everything at 100 %** | Every request generates a full trace | Extremely expensive; can itself become a performance problem | Sample (head-based or tail-based); always keep error and high-latency traces |
| **Alerts without owners or runbooks** | Many alerts fire but nobody knows what to do | Alert fatigue; slow or incorrect response | Every alert has a clear owner, severity, and a short runbook |
| **Alerting on symptoms that are not user-visible** | Alerts for minor internal cache misses, background job lag that users never feel | Noisy; trains people to ignore alerts | Prefer alerts tied to SLOs / error budgets and real user impact |
| **Logging sensitive data** | Tokens, passwords, personal data appear in logs | Security and compliance risk | Scrub or never log secrets and sensitive PII; use deliberate redaction |
| **Dashboards as the only tool** | Team stares at dashboards but cannot answer “why” | Dashboards show *what*; logs and traces show *why* | Use metrics for detection, logs and traces for diagnosis |
| **No SLO / error-budget connection** | Reliability work is driven by gut feel or the loudest incident | Hard to prioritize; over- or under-investment in reliability | Define SLIs/SLOs and use error-budget burn as a primary signal |
| **Ignoring saturation** | Only watching errors and latency | System can be close to collapse while still “working” | Monitor queue depths, thread-pool utilization, connection-pool usage, disk, etc. |

### 3. The Golden Path (What Good Looks Like)

1. **Define a few user-facing SLIs** (availability, latency, correctness).
2. **Alert on those SLIs** (and on error-budget burn rate).
3. **Use metrics** for dashboards, trends, and alerting.
4. **Use structured logs** with consistent identity fields for detailed debugging.
5. **Use distributed tracing** (sampled) to understand request paths and latency contributions.
6. **Propagate context** (trace ID / request ID) everywhere.
7. **Keep cardinality under control** on metrics.
8. **Give every alert an owner and a runbook**.
9. **Regularly review and delete** noisy alerts and unused dashboards.

### 4. Quick Diagnostic Questions

When observability feels ineffective, ask:

- Can we tell within 1–2 minutes that users are hurting?
- Can we tell *which* dependency or component is responsible within a few more minutes?
- Can we follow a single failing request across service boundaries?
- Are our alerts actionable, or do people routinely ignore them?
- Are we measuring what users experience, or only what is easy to measure internally?

### 5. Relationship to Earlier Primers

- Primer Q introduced metrics, logs, and traces.
- Primer R introduced SLIs, SLOs, and error budgets.
- This primer shows how those tools are commonly misused and how to correct course.

Observability is not a tooling problem first; it is a design and discipline problem. The best tools in the world will not help if you measure the wrong things, alert on noise, or cannot correlate signals.

### 6. What You Should Be Able to Do After This Primer

- Recognize the most common observability anti-patterns in a design or an existing system.
- Explain why averages hide important latency problems.
- Describe why high-cardinality metric labels are dangerous.
- Argue for structured logs and context propagation.
- Connect alerting to SLIs and error budgets rather than to raw resource metrics.
- Propose a minimal, high-signal observability setup for a new service.

This primer strengthens the operational and production topics in Parts 5 and 6 and is especially useful when reviewing real systems or preparing for design discussions that include operability.

**[END OF PRIMER AA]**
