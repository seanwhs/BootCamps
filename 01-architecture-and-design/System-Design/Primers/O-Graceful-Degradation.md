# Primer O: Graceful Degradation

When parts of a system fail or become overloaded, the ideal outcome is not a total outage. **Graceful degradation** is the practice of deliberately reducing functionality so that the most important user journeys continue to work. This primer explains the idea and how to apply it.

### 1. The Core Idea

**Graceful degradation** means the system continues to deliver *core value* even when non-critical components are slow, unavailable, or overloaded.

**Mental model**  
An elevator with two motors. When one motor fails, the elevator does not stop working entirely; it continues to run, just more slowly. Passengers still reach their floors.

In software terms: if the recommendation engine is down, the product page still loads and the user can still buy the item — they just see fewer or no personalized recommendations.

### 2. Why It Matters

Most large systems have a mix of:

- **Critical path** – the minimum functionality users need (login, view core data, place an order, send a message).
- **Non-critical enhancements** – features that improve the experience but are not required for the primary goal (recommendations, social proof, secondary analytics, personalization, some notifications).

If a failure in a non-critical component takes down the critical path, the system is more fragile than it needs to be. Graceful degradation deliberately protects the critical path.

### 3. Common Techniques

| Technique | How it works | Example |
|-----------|--------------|---------|
| **Fallback responses** | Return a safe default or cached value when a dependency fails | Show a generic homepage instead of a personalized one |
| **Feature shedding** | Turn off non-essential features under load or failure | Disable “related products” or “live chat” when the system is saturated |
| **Cached or static alternatives** | Serve slightly stale or precomputed data | Serve yesterday’s leaderboard if the live ranking service is down |
| **Partial results** | Return what you can instead of failing the entire request | Show the task list even if the activity feed fails to load |
| **Read-only mode** | Temporarily disable writes while keeping reads available | Allow users to view documents but not edit them during a storage incident |
| **Degraded real-time behavior** | Fall back from live updates to polling or manual refresh | Collaborative editor falls back to “refresh to see changes” |

### 4. Designing for Degradation

Graceful degradation is rarely something you can add as an afterthought. It requires deliberate design decisions:

1. **Identify the critical path**  
   What must keep working for the product to still be useful?

2. **Identify non-critical dependencies**  
   Which calls or features can fail without destroying the core experience?

3. **Define explicit fallback behavior**  
   What exactly should the user see or be able to do when that dependency is unavailable?

4. **Make the failure visible to the system**  
   Use timeouts, circuit breakers, and health signals so the application *knows* it should degrade.

5. **Instrument the degradation**  
   Metrics and logs should show how often and why fallbacks are being used.

### 5. Relationship to Other Patterns

- **Timeouts** detect that a dependency is too slow.
- **Circuit breakers** stop calling a dependency that is repeatedly failing.
- **Bulkheads** limit how many resources a failing dependency can consume.
- **Graceful degradation** decides what the user experience becomes once the system has detected the problem.

These patterns work together. Detection and isolation create the opportunity; graceful degradation defines the user-visible response.

### 6. Examples Across Domains

| System | Critical path | Graceful degradation example |
|--------|---------------|------------------------------|
| E-commerce | Browse + purchase | Hide recommendations and reviews if those services are down |
| Social feed | View posts + post updates | Show a chronological feed without ranking or personalization |
| Collaborative editor | Load document + basic editing | Disable live cursors and presence; keep editing + save |
| Ride sharing | Request ride + match driver | Disable surge pricing display or non-essential map layers |
| Search | Return relevant results | Fall back to a simpler ranking model or cached popular results |

### 7. What Graceful Degradation Is *Not*

- It is not an excuse for ignoring reliability of core components.
- It is not the same as “best-effort” with no monitoring.
- It does not mean silently returning incorrect data when correctness is required (e.g., payment amounts, inventory counts, permissions).

For data that must be correct, prefer strong consistency and clear failure over a quietly wrong answer.

### 8. What You Should Be Able to Do After This Primer

- Define graceful degradation in one clear sentence.
- Distinguish critical path from non-critical enhancements in a given product.
- Suggest at least two concrete degradation strategies for a typical web application.
- Explain how timeouts, circuit breakers, and bulkheads enable graceful degradation.
- Recognize designs that fail entirely when a non-essential dependency is unavailable, and propose a better fallback.
- Argue why degradation behavior should be deliberate and observable rather than accidental.

This primer completes the core set of resilience patterns introduced in Part 5 (timeouts, retries, circuit breakers, bulkheads, and now graceful degradation) and is relevant to almost every user-facing system in Part 7.

**[END OF PRIMER O]**
