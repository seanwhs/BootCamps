# Primer P: Health Checks (Liveness vs Readiness)

In any system that runs multiple instances behind a load balancer or orchestrator (Kubernetes, ECS, etc.), the platform needs a way to know which instances are safe to send traffic to. That mechanism is the **health check**. This primer explains the two most important kinds and how to use them correctly.

### 1. The Core Problem

When you run many copies of a service:

- Some instances may still be starting up.
- Some may be overloaded or broken.
- Some may be shutting down.
- Some may be alive but unable to do useful work (e.g., cannot reach the database).

If the load balancer sends traffic to a bad instance, users see errors. Health checks are how the platform decides which instances should receive traffic.

### 2. Two Distinct Concepts

**Liveness**  
“Is the process still running and not in a deadlocked or crashed state?”

- If a liveness check fails, the platform usually **restarts** the instance.
- A failing liveness check means “this process is hopeless; kill it and start a new one.”

**Readiness**  
“Is this instance ready to receive user traffic *right now*?”

- If a readiness check fails, the platform **stops sending new traffic** to the instance but does not necessarily restart it.
- A failing readiness check means “leave it alone for now; it may become ready again.”

These two questions are deliberately separate.

### 3. Simple Mental Model

Think of a cashier in a store:

- **Liveness** = “Is the cashier conscious?”  
  If not, replace them.
- **Readiness** = “Is the cashier ready to take the next customer?”  
  They might be conscious but still counting the drawer, on a break, or waiting for the register to finish rebooting. In that case you simply don’t send them customers until they are ready.

### 4. Typical Implementation

Most platforms expect HTTP endpoints (or equivalent TCP checks):

- `GET /healthz` or `GET /live` → **liveness**
- `GET /ready` or `GET /readyz` → **readiness**

**Liveness check** should be very cheap and should almost never fail unless the process is truly stuck. It usually just returns “OK” if the main event loop is still running.

**Readiness check** is more thorough. It often verifies:

- The process has finished initialization
- Critical dependencies (database, cache, config) are reachable
- The instance is not overloaded
- The instance is not in the middle of a graceful shutdown

### 5. Common Lifecycle

1. Instance starts → both checks fail (or readiness fails).
2. Initialization completes → readiness starts passing → traffic begins.
3. Instance becomes overloaded or loses a critical dependency → readiness fails → traffic is removed.
4. If the process deadlocks or crashes → liveness fails → platform restarts it.
5. During graceful shutdown → readiness fails immediately so new traffic stops, then the instance finishes in-flight work and exits.

### 6. Important Design Rules

- **Do not** make the liveness check depend on external services.  
  If the database is down and your liveness check calls the database, every instance will be restarted in a loop, making the outage worse.

- **Do** make the readiness check reflect whether the instance can actually do useful work.

- Keep both checks fast and lightweight. Slow health checks can themselves cause problems.

- During deployments, readiness checks are what enable zero-downtime rolling updates: new instances only receive traffic once they are ready; old instances stop receiving traffic before they are terminated.

### 7. Relationship to Other Patterns

- Load balancers and orchestrators use readiness to decide where to send traffic.
- Graceful shutdown relies on failing readiness early.
- Circuit breakers and bulkheads protect the application *while* it is receiving traffic; health checks decide *whether* it should receive traffic at all.
- Observability systems often monitor the rate of readiness and liveness failures as an early warning signal.

### 8. What You Should Be Able to Do After This Primer

- Clearly distinguish liveness from readiness.
- Explain what the platform typically does when each kind of check fails.
- Argue why liveness checks should not depend on external services.
- Describe the role of readiness checks in zero-downtime deployments and graceful shutdown.
- Design simple `/live` and `/ready` behavior for a typical web service.
- Recognize designs that conflate the two checks and the problems that creates.

This primer supports the operational and reliability material in Parts 5 and 6 and is essential for any design that runs multiple instances behind a load balancer or in Kubernetes-style environments.

**[END OF PRIMER P]**
