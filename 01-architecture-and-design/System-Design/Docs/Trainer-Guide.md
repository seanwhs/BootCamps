**Trainer Guide**  
**System Design Mastery: From Code to Distributed Architecture**

This guide is for instructors, mentors, team leads, or study-group facilitators who want to teach or run the series effectively. It assumes you have access to the full materials: main Parts 0–8, Appendices, Primers, Student Workbook, and Student Notes.

---

### 1. Course Goals

By the end of the program, participants should be able to:

- Reason clearly about latency, throughput, consistency, and failure.
- Produce structured system-design answers under time pressure.
- Make explicit trade-offs instead of jumping to technology names.
- Apply reliability, security, and multi-tenancy patterns deliberately.
- Translate interview-style thinking into real architectural decisions.

Success is measured more by the quality of reasoning and trade-off discussion than by memorizing specific architectures.

---

### 2. Recommended Formats

| Format | Duration | Best for |
|--------|----------|----------|
| Intensive workshop | 3–5 full days | Teams, bootcamps |
| Weekly cohort | 8–10 weeks (1 session/week) | Study groups, internal training |
| Self-paced + office hours | 6–12 weeks | Individuals with mentor support |
| Interview prep track | 4–6 weeks | Focused practice on Part 8 + Capstone |

---

### 3. Suggested Session Flow (90–120 min)

1. **Review / Warm-up** (10–15 min)  
   Quick quiz or discussion of previous concepts (use Student Notes).

2. **Concept Input** (20–30 min)  
   Teach or walk through the key ideas of the Part / Primers for that session. Prefer diagrams and examples over slides full of text.

3. **Guided Practice** (20–30 min)  
   Work a small design fragment or worksheet section together.

4. **Timed or Group Exercise** (25–40 min)  
   Participants design in pairs or individually. Use prompts from Appendix G.

5. **Debrief** (15–20 min)  
   Compare approaches, highlight strong trade-off discussions, correct anti-patterns.

6. **Assignment / Preview** (5 min)  
   Point to workbook sections and next primers.

---

### 4. Module Mapping & Teaching Notes

**Part 0 + Primer A**  
Goal: Set expectations and shared vocabulary.  
Emphasize that the series prioritizes reasoning over pattern memorization.

**Part 1 + Primers A, B, D, E**  
Focus on mental models. Force participants to explain latency vs throughput out loud.  
Common confusion: treating availability and reliability as the same thing.

**Part 2 + Primers F, H, X**  
Live-draw a request path. Have the group decide where to put rate limiting and why.  
Exercise: “Protect this endpoint from abuse” – discuss dimensions (IP, user, tenant).

**Part 3 + Primers C, E, U, AC**  
Spend real time on consistency choices. Use concrete examples (payments vs likes).  
Have pairs map product features to storage types and consistency needs.

**Part 4 + Primers G, H, I, J**  
Cache-aside on the whiteboard. Then ask: “What happens when this popular key expires?”  
Fan-out discussion: force the celebrity problem into the open.

**Part 5 + Primers J–O, K, L, M, N, P**  
This is the reliability core. Teach the patterns as a layered defense, not isolated tools.  
Scenario drill: “Dependency X is slow – what do you do?” (timeouts → circuit breaker → bulkhead → degradation).

**Part 6 + Primers V, W, Y, S, T, U, AD**  
Security and multi-tenancy are often rushed. Slow down here.  
Exercise: Find the cross-tenant leakage risks in a naïve design.

**Part 7**  
Use as case-study workshops. Assign different blueprints to different groups and have them present trade-offs.

**Part 8 + Capstone (Appendix L)**  
Shift to deliberate practice. Timed designs + rubric scoring (Appendix D).  
Capstone can be done as a take-home or as a multi-session group project.

---

### 5. Facilitation Tips

- **Make trade-offs explicit.** Whenever someone names a technology, ask “What are you optimizing for, and what are you giving up?”
- **Push for numbers.** Even rough order-of-magnitude estimates change the conversation.
- **Normalize “I don’t know yet.”** Reward clear assumption-stating over confident hand-waving.
- **Use the whiteboard heavily.** Force clear diagrams with labeled data flows.
- **Separate process from knowledge.** Early sessions may score low on depth but high on structure — that is progress.
- **Watch for common failure modes in discussion:**
  - Jumping into components before requirements
  - Ignoring failure modes
  - Treating all data as strongly consistent
  - Forgetting multi-tenant isolation
  - Over-engineering the MVP

---

### 6. Using the Supporting Materials

| Material | Trainer use |
|----------|-------------|
| **Primers** | Pre-reading or just-in-time clarification |
| **Student Notes** | Quick review handout or warm-up material |
| **Student Workbook** | In-session exercises + homework |
| **Appendix D (Rubric)** | Score practice designs; teach participants to self-score |
| **Appendix G (Prompts)** | Source of timed exercises |
| **Appendix L (Capstone)** | Final integrative assessment |
| **Appendix I (Cheat Sheets)** | Leave visible during practice sessions |
| **Anti-pattern primers (AA, AD)** | Excellent for “spot the problem” activities |

---

### 7. Assessment Approach

**Formative (ongoing)**  
- Workbook completion  
- Timed design self-scores  
- Contribution to debriefs  

**Summative**  
- One or two full timed designs scored with the rubric  
- Capstone design document or presentation  
- Optional: short oral defense of trade-offs  

Target for a solid senior-level signal: consistent 80+ on the rubric and a coherent Capstone that addresses multi-tenancy, real-time, consistency, and failure modes.

---

### 8. Sample 8-Week Cohort Outline

| Week | Focus | Key Exercise |
|------|-------|--------------|
| 1 | Foundations + Request path | Explain a request journey + latency/throughput |
| 2 | Networking + Rate limiting | Protect an API + choose L4/L7 |
| 3 | Data + Consistency | Map features to storage & consistency |
| 4 | Caching + Async + Fan-out | Design feed or notification fan-out |
| 5 | Reliability patterns | Dependency-failure scenario drill |
| 6 | Security + Multi-tenancy + Ops | Find isolation & secret-management flaws |
| 7 | Blueprints + Interview framework | Timed design (news feed or chat) |
| 8 | Capstone + Review | Capstone progress + final timed design |

---

### 9. Common Participant Profiles & Adjustments

**Strong backend engineers, weak on distributed trade-offs**  
Emphasize consistency, failure modes, and multi-tenancy. Give them harder Capstone constraints.

**Frontend / full-stack leaning**  
Spend extra time on request path, caching, authn/authz, and real-time patterns. Keep early wins concrete.

**Interview-focused candidates**  
Heavy on Part 8, rubric, timed prompts, and phrase practice (Appendix J). Still force them through reliability and multi-tenancy — those are frequent differentiators.

**Experienced but rusty**  
Use anti-pattern primers and design reviews of real systems they know. Less lecture, more critique.

---

### 10. Trainer Preparation Checklist

Before each session:

- [ ] Re-read the relevant Part and Primers  
- [ ] Prepare 1–2 whiteboard diagrams  
- [ ] Select a concrete exercise or prompt  
- [ ] Decide which trade-offs you want the group to surface  
- [ ] Have the rubric or a simplified scoring sheet ready  
- [ ] Prepare one “what if this fails?” question for the design under discussion  

---

### 11. Closing Advice for Trainers

The goal is not to produce people who can recite the “perfect” URL shortener. The goal is to produce engineers who can:

- Structure an ambiguous problem  
- Make scale and failure visible  
- Choose consistency and isolation deliberately  
- Communicate trade-offs calmly under pressure  

When participants start spontaneously asking “What is the blast radius?” and “What consistency does this data actually need?”, the training is working.

Use the materials as a scaffold, not a script. Adapt examples to your audience’s domain, keep the exercises active, and always return to reasoning over buzzwords.

---

**End of Trainer Guide**
