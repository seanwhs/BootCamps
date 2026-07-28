# Primer T: Feature Flags and Progressive Delivery

Deploying code and releasing features to users do not have to be the same event. **Feature flags** (also called feature toggles) separate the two. This primer explains what they are, why they are powerful, and how they enable safer, more progressive delivery.

### 1. The Core Idea

A **feature flag** is a runtime switch that controls whether a particular piece of behavior is active.

Instead of:

> “The new code is deployed, so every user gets the new feature.”

You get:

> “The new code is deployed, but the feature is only turned on for the users, tenants, or percentage we choose.”

**Mental model**  
A light switch for a feature. The wiring (code) can be installed without the light being on. You decide later who sees the light and when.

### 2. Why Feature Flags Matter

They provide several important capabilities:

- **Decouple deployment from release**  
  You can ship code to production continuously and decide later when (and for whom) it becomes visible.

- **Reduce risk**  
  Turn a feature on for a small internal group or a tiny percentage of users first. If something is wrong, turn it off instantly without a new deployment.

- **Progressive delivery**  
  Gradually increase exposure: employees → beta users → 1 % → 5 % → 20 % → 100 %.

- **Targeting**  
  Enable features for specific users, workspaces, regions, or customer tiers.

- **Kill switches**  
  Instantly disable a problematic feature in production.

- **Experimentation**  
  Run A/B tests by showing different variants to different cohorts.

### 3. Common Types of Flags

| Type | Purpose | Typical lifetime |
|------|---------|------------------|
| **Release flag** | Turn on a new feature gradually | Short – removed after full rollout |
| **Experiment flag** | A/B or multivariate testing | Short – removed after the experiment |
| **Ops / kill-switch flag** | Emergency control of behavior | Medium – may stay longer |
| **Permission / entitlement flag** | Control access by plan or role | Long-lived |

The most common hygiene rule: **release flags should be temporary**. Leaving them forever creates technical debt and combinatorial complexity.

### 4. How Flags Are Evaluated

At the point where behavior would differ, the code asks a flag service (or local evaluation library):

```text
if feature_flag.is_enabled("new-checkout", user):
    show_new_checkout()
else:
    show_old_checkout()
```

The flag service decides based on:

- Flag configuration (on/off, percentage)
- Targeting rules (user ID, email domain, workspace, country, etc.)
- Sometimes random assignment for percentage rollouts

Evaluation must be very fast and highly available; it usually happens in-process with a periodically refreshed ruleset, not as a remote call on every decision.

### 5. Progressive Delivery in Practice

A typical safe rollout looks like this:

1. Deploy the new code with the flag **off** for everyone.
2. Turn it on for internal staff or a dogfooding group.
3. Enable for a small percentage of real users (canary).
4. Watch error rates, latency, business metrics, and support tickets.
5. Increase the percentage in steps.
6. When confident, enable for 100 % and later remove the flag from the code.

If anything looks wrong at any step, flip the flag off. No redeployment is required.

### 6. Relationship to Deployment Strategies

Feature flags complement the strategies from the previous primer:

- **Rolling / Canary / Blue-Green** control *which version of the code* is running.
- **Feature flags** control *which behavior* that code exhibits.

Using both gives defense in depth: you can canary a new binary *and* keep the new feature inside it turned off until you are ready.

### 7. Risks and Costs

Feature flags are powerful but not free:

- **Code complexity** – every flag adds branching.
- **Technical debt** – old flags that are never cleaned up become a maintenance burden.
- **Testing surface** – you must consider multiple combinations of flags.
- **Consistency** – in distributed systems you need a clear model for when a flag change becomes visible everywhere.
- **Security / authorization** – flags that grant access must be treated with the same care as other authorization logic.

Good teams treat flag lifecycle management (especially removal) as a first-class practice.

### 8. What You Should Be Able to Do After This Primer

- Define a feature flag and explain how it decouples deployment from release.
- Describe at least three practical benefits of using flags.
- Outline a progressive rollout sequence from internal users to 100 %.
- Explain how flags work together with canary or rolling deployments.
- List common risks of feature flags and how to mitigate them (especially cleanup).
- Decide when a change is better controlled by a flag versus a pure deployment strategy.

This primer supports the production-engineering and safe-release topics in Part 6 and is highly relevant to any modern continuous-delivery practice.

**[END OF PRIMER T]**
