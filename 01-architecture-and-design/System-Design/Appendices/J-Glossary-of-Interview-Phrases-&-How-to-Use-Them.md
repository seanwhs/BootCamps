# Appendix J: Glossary of Interview Phrases & How to Use Them

Strong system-design interviews are conversations, not monologues. The phrases below are high-leverage tools for steering the discussion, demonstrating structured thinking, and showing senior judgment. Each entry includes **when to use it**, **why it works**, and **a concrete example**.

Use them naturally — the goal is clarity and collaboration, not sounding scripted.

---

### J.1 Opening & Scoping

| Phrase | When to use | Why it works | Example |
|--------|-------------|--------------|---------|
| “Before I start designing, I’d like to clarify a few requirements.” | Very start of the interview | Shows process discipline and prevents wasted work | “Before I start designing, I’d like to clarify a few requirements. What are the core actions users must be able to perform?” |
| “I’m going to state a few assumptions — please correct me if any are off.” | When numbers or constraints are missing | Makes assumptions visible and invites collaboration | “I’m going to assume 10 M DAU and a 100:1 read/write ratio. Please correct me if any of that is off.” |
| “Just to confirm scope: X is in, Y is out for now?” | After gathering requirements | Prevents later disagreements about what was asked | “Just to confirm scope: real-time delivery is in, but analytics dashboards are out for now?” |
| “What’s the most important non-functional requirement here — latency, consistency, or cost?” | When priorities are unclear | Forces prioritization early | — |

---

### J.2 Estimation & Numbers

| Phrase | When to use | Why it works | Example |
|--------|-------------|--------------|---------|
| “Let me do a quick back-of-the-envelope calculation.” | Right after requirements | Signals you design with scale in mind | — |
| “That gives us roughly X QPS at peak. I’ll design for that and note where it would break.” | After calculating | Links numbers to design decisions | “That gives us roughly 15 kQPS at peak. I’ll design for that and note where a single database would break.” |
| “Does this order of magnitude match the scale you had in mind?” | After presenting estimates | Invites course correction | — |

---

### J.3 High-Level Design

| Phrase | When to use | Why it works | Example |
|--------|-------------|--------------|---------|
| “I’ll start with a high-level design and then zoom into the hardest parts.” | Transitioning into diagramming | Sets expectations and shows structure | — |
| “The main data flow looks like this…” | While drawing | Keeps the interviewer oriented | “The main data flow looks like this: client → gateway → application tier → cache → database.” |
| “Does this overall shape look reasonable before I go deeper?” | After the high-level diagram | Creates a natural checkpoint and shows collaboration | — |
| “I’m treating the application tier as stateless so we can scale it horizontally.” | When introducing components | Explicitly justifies a key decision | — |

---

### J.4 Deep Dives & Trade-offs

| Phrase | When to use | Why it works | Example |
|--------|-------------|--------------|---------|
| “The hardest part of this design is X — I’ll focus there next.” | Choosing where to go deep | Shows prioritization skill | “The hardest part of this design is the fan-out for high-follower users — I’ll focus there next.” |
| “There are two main approaches here. I’m choosing A because…” | When a major decision appears | Demonstrates trade-off thinking | “There are two main approaches: fan-out-on-write vs fan-out-on-read. I’m choosing a hybrid because…” |
| “The trade-off I’m making is X in exchange for Y.” | After any significant choice | Makes the cost of the decision visible | “The trade-off I’m making is higher write amplification in exchange for very fast read timelines.” |
| “An alternative I considered and rejected is…” | When you want to show breadth | Signals you didn’t just pick the first idea | “An alternative I considered and rejected is pure fan-out-on-write for everyone — it breaks for celebrity accounts.” |
| “This is an availability-vs-consistency tension. For this use case I’m favoring…” | When CAP/PACELC appears | Shows you recognize the fundamental trade-off | — |

---

### J.5 Failure & Reliability

| Phrase | When to use | Why it works | Example |
|--------|-------------|--------------|---------|
| “Let’s talk about what happens when things fail.” | After the happy-path design | Shows mature thinking | — |
| “If this dependency becomes slow, the blast radius would be…” | Discussing a specific component | Forces isolation thinking | “If the recommendation service becomes slow, the blast radius would be limited to the optional recommendation block because we have a bulkhead and a short timeout.” |
| “I’d protect this call with a timeout, circuit breaker, and fallback.” | When mentioning external calls | Demonstrates concrete resilience patterns | — |
| “We need this operation to be idempotent so retries are safe.” | When discussing retries or at-least-once delivery | Shows you understand the consequences of retries | — |

---

### J.6 Scaling & Evolution

| Phrase | When to use | Why it works | Example |
|--------|-------------|--------------|---------|
| “This design should be fine until roughly X. After that the first bottleneck will be…” | When discussing growth | Shows you design for the next order of magnitude | “This design should be fine until roughly 50 kQPS. After that the first bottleneck will be the single primary database.” |
| “At that point I would introduce Y.” | Continuing the previous thought | Turns a limitation into an evolution plan | “At that point I would introduce read replicas and eventually shard by user_id.” |
| “I’m choosing this partition key because it appears in most of the hot queries.” | When explaining sharding | Justifies one of the most important decisions | — |

---

### J.7 Communication & Recovery Phrases

| Phrase | When to use | Why it works | Example |
|--------|-------------|--------------|---------|
| “Let me take a few seconds to organize my thoughts.” | When you feel stuck or rushed | Buys time without looking lost | — |
| “The tension I’m seeing is between X and Y.” | When the design has a real conflict | Turns confusion into a clear problem statement | “The tension I’m seeing is between strict ordering and high availability under partition.” |
| “That’s a good point — let me adjust the design.” | When the interviewer challenges you | Shows intellectual honesty and flexibility | — |
| “Would you like me to go deeper on this part or move to failure modes?” | When you need a signal on priorities | Hands the interviewer control of depth vs breadth | — |
| “I want to make sure I’m still aligned with what you’re looking for.” | If the conversation feels off-track | Resets collaboration | — |

---

### J.8 Closing Phrases

| Phrase | When to use | Why it works | Example |
|--------|-------------|--------------|---------|
| “To summarize the core design…” | Near the end | Leaves a clear final picture | — |
| “The main open questions I’d want to resolve next are…” | When time is running out | Shows awareness of remaining risk | — |
| “If we had more time I’d dig further into X.” | Graceful close | Demonstrates you know where the remaining depth is | — |

---

### J.9 Phrases to Avoid (or Use Very Carefully)

| Phrase | Problem | Better alternative |
|--------|---------|--------------------|
| “We should just use Kafka / Kubernetes / Microservices…” | Technology name-dropping without justification | “We need durable, replayable events with multiple consumers — a log-based system like Kafka is a good fit because…” |
| “This is the standard way to do it.” | Appeals to authority instead of reasoning | “This approach optimizes for X at the cost of Y, which matches our requirements.” |
| “I’d have to look that up.” (when used too often) | Undermines confidence | “I’m not certain of the exact number, but the order of magnitude is…” |
| Long unbroken monologues | Loses the interviewer | Speak in shorter chunks and check in |

---

### J.10 How to Practice These Phrases

1. Pick 5–6 phrases that feel least natural to you.  
2. In your next timed practice, deliberately use each of them at least once.  
3. Record yourself. Notice whether the phrases create clearer structure or just add filler.  
4. Over time, most of them will become automatic.

The best candidates do not sound like they are reciting a script. They sound like thoughtful engineers who have a clear internal checklist and are inviting the interviewer to design with them.

---

**[END OF APPENDIX J]**
