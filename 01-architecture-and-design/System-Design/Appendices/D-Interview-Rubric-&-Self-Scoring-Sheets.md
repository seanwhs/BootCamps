# Appendix D: Interview Rubric & Self-Scoring Sheets

This appendix turns the vague feeling of “I think that went okay” into a concrete evaluation. Use it in two ways:

1. **After every practice session** – score yourself honestly.  
2. **As a checklist while practicing** – keep the dimensions visible so you deliberately cover them.

The rubric is calibrated to what most strong mid-to-senior and staff-level interviewers actually look for.

---

### D.1 Scoring Dimensions (Total 100 points)

| Dimension | Weight | What a strong answer looks like | What a weak answer looks like |
|-----------|--------|---------------------------------|-------------------------------|
| **1. Requirements & Scoping** | 10 | Clarifies functional + non-functional needs, states assumptions, explicitly lists out-of-scope items | Jumps straight into design, makes silent assumptions |
| **2. Estimation & Scale** | 10 | Performs back-of-envelope calculations, uses them to drive decisions, distinguishes average vs peak | No numbers, or numbers that are never referenced again |
| **3. High-Level Design** | 20 | Clear components, correct major data flows, sensible sync/async boundaries, readable diagram | Missing major pieces, confusing or missing data flow, spaghetti |
| **4. Depth on Critical Areas** | 25 | Goes deep on 2–3 hard parts (data model, scaling, consistency, failure modes, etc.) with concrete reasoning | Stays superficial everywhere, or only deep on easy parts |
| **5. Scalability & Reliability** | 15 | Addresses partitioning, caching, failure modes, redundancy, graceful degradation | Only happy path, no discussion of what breaks at 10× load |
| **6. Trade-offs & Alternatives** | 10 | Explicitly names what was optimized and what was sacrificed; mentions at least one rejected alternative | Presents the design as the only possible solution |
| **7. Communication & Collaboration** | 10 | Structured, checks in with interviewer, thinks aloud clearly, uses precise language | Monologue, unstructured, hand-wavy, defensive when questioned |

**Score interpretation (approximate)**

- **85–100**: Strong senior / staff signal  
- **70–84**: Solid senior signal, some gaps  
- **55–69**: Mid-level; needs more structure or depth  
- **Below 55**: Significant gaps in process or fundamentals  

---

### D.2 Self-Scoring Sheet (Copy for Each Practice Session)

```text
Prompt: _______________________________________________
Date: ______________  Time taken: ________ min

1. Requirements & Scoping          ___ / 10
   Notes: ____________________________________________

2. Estimation & Scale              ___ / 10
   Notes: ____________________________________________

3. High-Level Design               ___ / 20
   Notes: ____________________________________________

4. Depth on Critical Areas         ___ / 25
   Notes: ____________________________________________

5. Scalability & Reliability       ___ / 15
   Notes: ____________________________________________

6. Trade-offs & Alternatives       ___ / 10
   Notes: ____________________________________________

7. Communication & Collaboration   ___ / 10
   Notes: ____________________________________________

TOTAL                              ___ / 100

Top 3 things I did well:
1. ________________________________________________
2. ________________________________________________
3. ________________________________________________

Top 3 things to improve next time:
1. ________________________________________________
2. ________________________________________________
3. ________________________________________________

Key technical gap exposed (if any):
____________________________________________________
```

---

### D.3 Quick Post-Session Diagnostic Questions

Ask yourself these immediately after finishing a practice design:

1. Did I state my scale assumptions out loud and write the key numbers down?  
2. Did I explicitly say what is in scope and what is out of scope?  
3. Can someone look at my diagram and understand the primary data flow in under 30 seconds?  
4. Did I go deep on the hardest part of *this particular* problem (not just the part I like)?  
5. Did I mention at least one failure mode and how the system survives it?  
6. Did I name a real trade-off (e.g., “I chose eventual consistency here to keep write latency low”)?  
7. Did I check in with the interviewer after the high-level design?  
8. If the interviewer challenged a decision, did I defend it with reasoning or just fold?

If you answer “no” to three or more, that session still has high learning value — focus the next practice on those gaps.

---

### D.4 Dimension-Specific Red Flags

| Dimension | Red flags that usually cost points |
|-----------|------------------------------------|
| Requirements | “I’ll just assume…” without stating the assumption |
| Estimation | Calculating numbers and then never using them |
| High-Level | No clear entry point or no distinction between read and write paths |
| Depth | Spending 10 minutes on the easy CRUD part and 2 minutes on the hard fan-out or consistency part |
| Scalability | “We’ll add more servers” with no discussion of state or data partitioning |
| Reliability | Zero mention of timeouts, retries, circuit breakers, or degradation |
| Trade-offs | “This is the best way” with no alternative considered |
| Communication | Long monologue, no pauses, defensive when asked “why not X?” |

---

### D.5 How to Use This Rubric in Real Design Reviews

The same dimensions translate almost directly to internal architecture discussions:

- Requirements & Scoping → Goals / Non-goals section of an RFC  
- Estimation → Capacity and cost model  
- High-Level Design → Context and container diagrams  
- Depth → Detailed design sections  
- Scalability & Reliability → Failure modes and operability  
- Trade-offs → Alternatives Considered  
- Communication → Clarity of the written document and discussion

Scoring your own RFCs against a simplified version of this rubric is one of the fastest ways to improve architectural communication.

---

### D.6 Practice Progression Recommendation

| Stage | Focus | Target Score |
|-------|-------|--------------|
| Week 1–2 | Force the 6-step framework; ignore depth | 60+ (process first) |
| Week 3–4 | Add real estimates + one deep dive | 70+ |
| Week 5–6 | Full depth + failure modes + trade-offs | 80+ |
| Ongoing | Timed mocks with the full rubric | 85+ consistently |

Record yourself (audio or video) at least once a week. The difference between how clear you *think* you were and how clear you actually were is usually large at the beginning.

---

**How to use this appendix**
- Print the self-scoring sheet or keep it in a notes file.  
- After every practice design, fill it out within 10 minutes while the memory is fresh.  
- Track scores over time; the trend matters more than any single number.  
- When you plateau, look at which dimension is consistently lowest and deliberately practice only that dimension for a few sessions.

**[END OF APPENDIX D]**
