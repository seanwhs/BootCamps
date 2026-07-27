# Primer E: Consistency at a Glance (Strong vs Eventual)

Consistency questions appear in almost every serious system-design discussion. This primer gives you a clear, practical understanding of the two most important models and when each is appropriate. We stay at the level of intuition and consequences; deeper theory lives in the main series.

### 1. The Core Question

After a write happens, **who sees the new value, and how soon?**

That single question is the heart of consistency.

### 2. Strong Consistency

**Definition**  
Once a write is accepted, every subsequent read (from any client) will see that write, or a later one. It looks as if there is a single, up-to-date copy of the data.

**Mental model**  
A single shared whiteboard. When someone writes on it, everyone who looks at the whiteboard afterward sees the new text.

**Practical consequences**
- Easier to reason about correctness.
- Often requires coordination (locks, consensus, or a single primary).
- Can increase latency and reduce availability during network problems.

**Typical use cases**
- Bank balances and transfers
- Inventory reservation (“only 3 left”)
- Unique username or email constraints
- Any decision that must not be based on stale data

### 3. Eventual Consistency

**Definition**  
If no new writes occur, all readers will *eventually* see the same value. In the meantime, different readers can see different values.

**Mental model**  
Multiple whiteboards that are copied to each other in the background. After a write on one board, some people may still see the old text for a short (or sometimes not-so-short) time.

**Practical consequences**
- Higher availability and often lower latency.
- Can continue accepting reads and writes even when some replicas are unreachable.
- Requires the application (or user) to tolerate temporary staleness.

**Typical use cases**
- Like counts, view counts, recommendation scores
- Social media feeds and activity streams
- Product catalog browsing
- Analytics and aggregated dashboards
- Session data that is not mission-critical

### 4. The Spectrum in Between

Real systems often provide models that sit between the two extremes:

| Model | What it guarantees | Common scenario |
|-------|--------------------|-----------------|
| **Read-your-writes** | A client always sees its own writes | After you update your profile, *you* immediately see the change |
| **Monotonic reads** | Once a client has seen a value, it never sees an older one | Scrolling a feed does not jump backward in time |
| **Causal consistency** | If A happened before B and you know it, everyone else sees A before B | Comment threads, collaborative editing |

These intermediate models are frequently “good enough” and cheaper than full strong consistency.

### 5. Why You Cannot Have Everything at Once (CAP Intuition)

When a network partition occurs (some machines cannot talk to each other), a distributed system must choose:

- Keep serving reads and writes (availability) and accept that some clients may see stale data, **or**
- Refuse some requests until the partition heals so that strong consistency can be preserved.

This is the practical heart of the CAP theorem. In normal operation (no partition) there is still a latency-versus-consistency trade-off: stronger guarantees usually cost extra coordination and therefore extra latency.

### 6. How Designers Actually Choose

Ask two questions:

1. **What goes wrong if a reader sees stale data?**  
   - If the answer is “money is lost / inventory is oversold / security is violated” → lean toward strong consistency.  
   - If the answer is “the like count is briefly wrong / the feed is a few seconds behind” → eventual consistency is usually acceptable.

2. **How painful is higher latency or lower availability for this particular operation?**  
   - User-facing interactive operations often prefer lower latency and will accept eventual consistency when the business risk is low.
   - Administrative or financial operations often prefer stronger guarantees even at higher cost.

### 7. Consistency Is Per-Data, Not Per-System

A single product almost always mixes models:

- Task status and assignee → strong consistency  
- Activity feed and search index → eventual consistency  
- Notification counters → eventual consistency  
- Payment status → strong consistency  

Treating the entire system as “strongly consistent” or “eventually consistent” is usually a mistake. Good designs make the decision **per type of data**.

### 8. What You Should Be Able to Do After This Primer

- Define strong and eventual consistency in one clear sentence each.
- Give two realistic examples of data that need strong consistency and two that can accept eventual consistency.
- Explain why a system might deliberately choose eventual consistency.
- Recognize that different pieces of data inside the same product can (and usually should) have different consistency guarantees.
- Relate the choice to real consequences: latency, availability, and correctness risk.

This primer prepares you for the deeper storage and consistency discussions in Part 3 and for the trade-off conversations that appear throughout the later parts of the series.

**[END OF PRIMER E]**
