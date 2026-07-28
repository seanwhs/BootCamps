# Primer S: Deployment Strategies (Rolling, Canary, Blue-Green)

Shipping new code is one of the riskiest moments in a system’s life. Deployment strategies exist to reduce that risk. This primer explains the three most common production strategies and when each is appropriate.

### 1. The Core Problem

If you simply stop the old version, install the new version, and start it again (a “big bang” or “recreate” deployment), you get:

- Downtime
- An all-or-nothing risk — if the new version is bad, every user is affected immediately
- A slow and stressful rollback

Modern strategies aim for:

- Little or no downtime
- Limited blast radius if something goes wrong
- Fast, reliable rollback

### 2. Rolling Deployment

**How it works**  
Replace instances gradually. Take a few instances out of the load balancer, update them, put them back, then move to the next batch.

**Characteristics**
- Simple and widely supported
- Requires only one “environment”
- Traffic shifts gradually to the new version
- Rollback = continue rolling the old version back in

**Pros**
- Easy to implement
- Resource-efficient (no full duplicate environment)

**Cons**
- Old and new versions run side-by-side for a while (must be compatible)
- A bad release still eventually reaches 100 % of traffic
- Harder to test the new version in isolation under real load

**Typical use**  
Most everyday deployments of stateless services.

### 3. Canary Deployment

**How it works**  
Route a small percentage of real traffic (the “canary”) to the new version while the majority of traffic still goes to the old version. Watch metrics carefully. If the canary looks healthy, gradually increase its traffic share until it reaches 100 %. If problems appear, shift traffic back immediately.

**Characteristics**
- Explicit, controlled exposure of real users to the new version
- Strong focus on metrics and automated analysis
- Rollback is usually just a traffic shift

**Pros**
- Very small initial blast radius
- Real production traffic and data exercise the new version
- Excellent for detecting subtle problems

**Cons**
- Requires good metrics, alerting, and usually some automation
- Slightly more complex traffic routing
- Still needs the old and new versions to be compatible while both are live

**Typical use**  
Higher-risk changes, user-facing services, or teams with mature observability.

### 4. Blue-Green Deployment

**How it works**  
Keep two complete environments: “Blue” (current production) and “Green” (the new version). Deploy and test the new version in the idle environment. When ready, switch the load balancer (or router) so all traffic moves from Blue to Green in one step. The previous environment is kept warm for quick rollback.

**Characteristics**
- Instant switch (and instant rollback)
- Full isolation between old and new versions during testing
- Requires roughly double the resources while both environments are up

**Pros**
- Extremely fast rollback
- Clean separation — easy to run smoke tests before switching
- Simple mental model

**Cons**
- Higher infrastructure cost (two full environments)
- Database and stateful changes still need careful handling
- Switching all traffic at once can still expose problems broadly if testing was incomplete

**Typical use**  
Situations where instant rollback is highly valued, or where the team prefers strong isolation between versions.

### 5. Side-by-Side Comparison

| Aspect              | Rolling              | Canary                     | Blue-Green              |
|---------------------|----------------------|----------------------------|-------------------------|
| Blast radius        | Gradual              | Very small at first        | All-or-nothing switch   |
| Rollback speed      | Moderate             | Fast (traffic shift)       | Very fast               |
| Extra resources     | Low                  | Low–moderate               | High (near 2×)          |
| Complexity          | Low                  | Moderate–high              | Moderate                |
| Version coexistence | Yes                  | Yes                        | Only during cutover     |
| Best for            | Routine releases     | Risky or high-visibility changes | Fast rollback priority |

### 6. Important Shared Requirements

Regardless of strategy, successful deployments need:

- **Health / readiness checks** so traffic only goes to healthy instances
- **Backward compatibility** (or a short compatibility window) when two versions run at the same time
- **Database migrations** that follow expand/contract rules so both old and new code can work
- **Observability** so you can tell whether the new version is healthy
- **Automated or well-practiced rollback**

Without these, even a sophisticated deployment strategy can still cause outages.

### 7. Relationship to Other Concepts

- **Feature flags** can complement any of these strategies by decoupling code deployment from feature activation.
- **Error budgets** often influence how aggressively a team is willing to deploy.
- **Canary analysis** relies heavily on the metrics and SLIs discussed in earlier primers.
- **Graceful shutdown + readiness checks** are what make rolling and canary deployments zero-downtime.

### 8. What You Should Be Able to Do After This Primer

- Describe rolling, canary, and blue-green deployments in plain language.
- Compare them on blast radius, rollback speed, and resource cost.
- Choose a reasonable default strategy for a typical stateless service and justify it.
- Explain why database changes and backward compatibility still matter even with fancy deployment techniques.
- Recognize that the strategy alone is not enough without health checks, observability, and safe migrations.

This primer supports the production-engineering topics in Part 6 and is relevant whenever you discuss how a design will actually be shipped and iterated on.

**[END OF PRIMER S]**
