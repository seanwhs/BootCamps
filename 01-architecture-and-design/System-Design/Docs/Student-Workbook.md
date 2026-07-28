**Student Workbook**  
**System Design Mastery: From Code to Distributed Architecture**

This workbook is meant to be *used*, not just read. Print it, copy it into a notes doc, or work through it digitally. It turns the series, primers, and appendices into active practice.

---

### How to Use This Workbook

1. Work linearly or jump to the section that matches what you just studied.
2. Write answers in your own words — short bullet points are fine.
3. After timed practice designs, fill in the reflection pages.
4. Revisit weak areas using the Primer Index (Primer AE) and the main series.

---

## Section 1: Foundations Self-Check

**After Part 1 + Primers A, B, D, E**

1. In one sentence each, define:
   - Latency
   - Throughput
   - Availability
   - Reliability

2. Give a real-world analogy for vertical scaling vs horizontal scaling.

3. Sketch (or describe) the main hops a typical web request takes from browser to database and back.

4. When would you choose strong consistency? When is eventual consistency acceptable? Give one example of each.

5. Why do stateless services make horizontal scaling easier?

**Self-score (1–5):** ____  
**What still feels fuzzy?** _______________________________

---

## Section 2: Networking & Traffic Worksheet

**After Part 2 + Primers F, H, X**

1. L4 vs L7 load balancing — what is the key difference, and when would you choose each?

2. List three responsibilities commonly handled by an API Gateway.

3. Token bucket vs sliding window rate limiting — which allows bursts more naturally?

4. Synchronous vs asynchronous communication:  
   For each scenario below, mark S or A and give a one-line reason.  
   - Loading a user profile page  
   - Sending a welcome email after signup  
   - Charging a credit card during checkout  
   - Updating a search index after a new post  

5. Where would you place rate limiting in a typical architecture, and why (list at least two places)?

**Self-score (1–5):** ____  
**Notes:** _______________________________

---

## Section 3: Data & Consistency Exercises

**After Part 3 + Primers C, E, U, AC**

1. For each data type, suggest a storage style (relational, document, key-value, etc.) and consistency need:  
   - Bank account balance  
   - Social media “like” count  
   - User session data  
   - Product catalog  
   - Order + payment records  

2. What does a database index actually do? What is the main cost of adding more indexes?

3. Explain the expand/contract pattern using a column rename as the example.

4. At-least-once delivery requires what critical property in the consumer? Why?

5. Sketch a simple Saga for: Create Order → Charge Payment → Reserve Inventory. Include one compensating action.

**Self-score (1–5):** ____  
**Notes:** _______________________________

---

## Section 4: Caching, Async & Fan-out

**After Part 4 + Primers G, H, I, J**

1. Describe the cache-aside pattern step by step.

2. What is a cache stampede and name two ways to reduce it.

3. Fan-out on write vs fan-out on read:  
   - Which is better for a normal user posting to a small audience?  
   - Which protects the system better from celebrity accounts?

4. Give two concrete techniques to make an operation idempotent.

5. When should work be moved off the critical request path onto an asynchronous queue?

**Self-score (1–5):** ____  
**Notes:** _______________________________

---

## Section 5: Reliability Toolkit Drill

**After Part 5 + Primers J–O, K, L, M, N**

For each pattern, write one sentence explaining what problem it solves:

| Pattern              | Problem it solves                          |
|----------------------|--------------------------------------------|
| Timeout              |                                            |
| Retry + jittered backoff |                                        |
| Idempotency          |                                            |
| Circuit breaker      |                                            |
| Bulkhead             |                                            |
| Back-pressure        |                                            |
| Graceful degradation |                                            |

**Scenario practice**  
A recommendation service has become very slow.  
List three patterns you would apply and what each one does in this situation.

**Self-score (1–5):** ____  
**Notes:** _______________________________

---

## Section 6: Security & Multi-Tenancy Checks

**After Part 6 + Primers V, W, Y, AD, X**

1. Authentication vs Authorization — one-sentence definitions.

2. List four golden rules of secrets management.

3. In a multi-tenant system, name two isolation goals and one technique for each.

4. Why is “the UI already hides that button” never sufficient authorization?

5. Identify three security anti-patterns that could appear in a typical SaaS design.

**Self-score (1–5):** ____  
**Notes:** _______________________________

---

## Section 7: Operations & Delivery

**After Part 6 + Primers P, Q, R, S, T, U**

1. Liveness vs Readiness — what does the platform do when each fails?

2. Name the four Golden Signals.

3. What is an error budget, and how can a team use it?

4. Rolling vs Canary vs Blue-Green: give one major advantage of each.

5. How do feature flags decouple deployment from release?

**Self-score (1–5):** ____  
**Notes:** _______________________________

---

## Section 8: Timed Practice Design Log

**Use this page for every timed practice (35–45 min)**

**Date:** ______________  
**Prompt:** _______________________________________________  
**Time allowed:** ________ min   **Actual time used:** ________ min

**Quick self-score (use Appendix D rubric dimensions)**

| Dimension                        | Score (1–5) | Notes |
|----------------------------------|-------------|-------|
| Requirements & Scoping           |             |       |
| Estimation & Scale               |             |       |
| High-Level Design                |             |       |
| Depth on Critical Areas          |             |       |
| Scalability & Reliability        |             |       |
| Trade-offs & Alternatives        |             |       |
| Communication / Clarity          |             |       |

**What I did well:**  
1. ________________________________________________  
2. ________________________________________________  

**What I missed or handled weakly:**  
1. ________________________________________________  
2. ________________________________________________  
3. ________________________________________________  

**Top 1–2 primers or series sections to revisit:**  
________________________________________________

**Next practice focus:** ________________________________

---

## Section 9: Capstone Tracker (Appendix L)

**Use while working on the final Capstone**

| Deliverable                              | Done? | Confidence (1–5) | Notes / Gaps |
|------------------------------------------|-------|------------------|--------------|
| Clarified requirements & assumptions     |       |                  |              |
| Back-of-envelope estimates               |       |                  |              |
| High-level architecture                  |       |                  |              |
| Data model & partitioning                |       |                  |              |
| Real-time collaboration design           |       |                  |              |
| Search design                            |       |                  |              |
| Notification & activity feed             |       |                  |              |
| File attachments                         |       |                  |              |
| Multi-tenancy & isolation                |       |                  |              |
| Consistency decisions                    |       |                  |              |
| Failure modes & mitigations              |       |                  |              |
| Security design                          |       |                  |              |
| Observability & SLOs                     |       |                  |              |
| Deployment / rollout / migrations        |       |                  |              |
| Evolution path (5–10×)                   |       |                  |              |
| Key trade-offs                           |       |                  |              |

**After finishing the Capstone — reflection**

- Strongest parts of my design: _______________________________  
- Weakest parts: _______________________________  
- Concepts I still need to deepen: _______________________________  
- What I would prototype first to de-risk: _______________________________

---

## Section 10: Quick Reference Pocket Cards

**Copy these onto a single sheet or keep them open during practice.**

**6-Step Framework**  
1. Clarify & Scope  
2. Estimates  
3. High-Level Design  
4. Deep Dives  
5. Trade-offs  
6. Evolution & Observability

**Reliability Minimums**  
Timeouts → Retries (with jitter) → Idempotency → Circuit Breaker → Bulkhead → Graceful Degradation

**Consistency Rule of Thumb**  
Money / inventory / uniqueness → Strong  
Likes / feeds / counters / catalogs → Eventual  
“I just wrote it” → Read-your-writes

**Multi-Tenant Musts**  
Tenant filter on every query + cache key  
Per-tenant rate limits / quotas  
No trust of client-supplied tenant ID without verification

**Observability Minimums**  
Golden Signals + structured logs with request/trace ID + sampled traces + actionable alerts tied to SLIs

---

## Section 11: Progress Snapshot

**Date:** ______________

| Area                         | Current Comfort (1–5) | Target Date to Improve |
|------------------------------|-----------------------|------------------------|
| Foundations & Vocabulary     |                       |                        |
| Networking & Traffic         |                       |                        |
| Data Modeling & Consistency  |                       |                        |
| Caching & Async              |                       |                        |
| Reliability Patterns         |                       |                        |
| Security & Multi-tenancy     |                       |                        |
| Operations & Delivery        |                       |                        |
| End-to-end Design Fluency    |                       |                        |
| Interview Communication      |                       |                        |

**Three focus items for the next two weeks:**  
1. ________________________________________________  
2. ________________________________________________  
3. ________________________________________________

---

**End of Student Workbook**

You now have:
- The full multi-part series
- Appendices (glossary, estimation, decision maps, rubrics, checklists, failure modes, practice prompts, resources, cheat sheets, phrases, cloud mappings, capstone)
- A complete primer collection
- This workbook for active practice

Work the workbook in parallel with the material. The combination of structured knowledge + deliberate practice is what produces real system-design skill.
