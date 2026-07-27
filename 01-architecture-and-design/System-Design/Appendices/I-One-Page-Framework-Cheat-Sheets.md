# Appendix I: One-Page Framework Cheat Sheets 

These are deliberately dense, single-page references. Print them, keep them open during practice sessions, or pin them next to your screen during design reviews. Each sheet compresses a core part of the series into a form you can scan in seconds.

---

### I.1 The 6-Step System Design Framework

```
1. CLARIFY & SCOPE                          (3–5 min)
   • Functional requirements
   • Non-functional (latency, QPS, consistency, availability)
   • Out-of-scope items
   • State assumptions out loud

2. BACK-OF-ENVELOPE ESTIMATES               (2–3 min)
   • QPS (avg + peak)
   • Storage size
   • Read/write ratio
   • Bandwidth if relevant

3. HIGH-LEVEL DESIGN                        (8–10 min)
   • Major components + primary data flow
   • Sync vs async boundaries
   • Core data model + partition key

4. DEEP DIVES                               (12–15 min)
   Pick 2–3 hard parts:
   • Data model & storage
   • Scaling / partitioning / hot keys
   • Caching & performance
   • Consistency & transactions
   • Failure modes & mitigation

5. TRADE-OFFS & ALTERNATIVES                (5 min)
   • What did you optimize for?
   • What did you sacrifice?
   • One alternative you rejected and why

6. EVOLUTION & OBSERVABILITY                (2–3 min)
   • How it grows to 10×
   • Key metrics & alerts
   • Open questions
```

---

### I.2 Estimation Quick Reference

```
Seconds/day          ≈ 10^5
Seconds/year         ≈ 3 × 10^7

1 KB = 10^3 B        1 MB = 10^6 B
1 GB = 10^9 B        1 TB = 10^12 B

QPS ≈ DAU × actions/user/day / 86 400
Peak ≈ 2–5 × average (higher for social)

Rough capacity (order of magnitude):
• Simple API server:     1k–5k QPS
• Redis GET:             50k–200k QPS
• PostgreSQL point lookup: 5k–20k QPS

Latency comfort zones:
• Same-region RTT:       0.5–2 ms
• Redis:                 < 1 ms
• DB point lookup:       1–5 ms
• User-facing p99 target: usually < 100–200 ms
```

---

### I.3 Storage Decision Snapshot

```
Need multi-row ACID + joins          → Relational (Postgres)
Document-shaped, flexible schema     → Document store
Simple key lookup, ultra-low latency → Key-value (Redis / DynamoDB)
Analytics / large scans              → Columnar
Relationship traversal               → Graph (or relational + care)

Consistency cheat:
• Money / inventory / unique constraints → Strong
• Likes, views, feeds, recommendations   → Eventual
• “I just wrote it, I must see it”        → Read-your-writes
```

---

### I.4 Caching & Async Snapshot

```
Cache placement:
  Browser → CDN → App (Redis) → DB buffer pool

Patterns:
  Cache-aside     most common
  Write-through   when freshness is critical
  Write-behind    when write speed matters more than durability risk

Eviction: LRU (common), LFU (frequency-sensitive)

Async when:
  • Work is not needed for the user response
  • Fan-out is large
  • You want independent scaling of producers/consumers

Prefer: at-least-once + idempotency over chasing exactly-once
```

---

### I.5 Reliability Patterns Snapshot

```
First line of defense:
  Timeouts → Retries (jittered backoff) → Idempotency

Isolation:
  Circuit breaker → Bulkhead → Load shedding

Survival:
  Redundancy + health checks + graceful degradation

Data changes:
  Expand / Contract migrations only

Deployment:
  Canary or rolling + automated rollback + feature flags
```

---

### I.6 Failure-Mode Prompt List

When reviewing any design, force yourself to answer:

```
1. What happens if this instance disappears?
2. What happens if this dependency becomes slow?
3. What happens if this dependency returns errors?
4. What happens if traffic suddenly multiplies by 10×?
5. What happens if we lose a whole availability zone?
6. How will we detect each of the above?
7. How will we recover?
8. What is the blast radius?
```

---

### I.7 Production Launch Gate (Minimum Bar)

```
□ Timeouts + retries + idempotency on critical writes
□ Health checks (liveness + readiness)
□ Structured logging + basic metrics (golden signals)
□ TLS everywhere
□ Secrets from a secret manager (not in images)
□ Automated deploy + tested rollback
□ Edge rate limiting
□ Explicit consistency decisions for core data
□ At least one tested backup/restore path
```

---

### I.8 Interview Communication Habits

```
• Speak assumptions out loud
• Use “we” language
• Pause after high-level design and check in
• Draw clean, labeled diagrams
• Name trade-offs explicitly
• When stuck, narrate the tension you see
• Prefer precise language over buzzwords
• Defend decisions with reasoning, not authority
```

---

### I.9 Self-Scoring Reminder (After Every Practice)

```
Requirements & Scoping          /10
Estimation & Scale              /10
High-Level Design               /20
Depth on Critical Areas         /25
Scalability & Reliability       /15
Trade-offs & Alternatives       /10
Communication                   /10
──────────────────────────────────
Total                           /100
```

---

**Printing tip**  
Print I.1 + I.2 + I.6 on one sheet (front/back) for most practice sessions. Add I.3–I.5 when you are drilling specific areas. Keep I.7 visible when the conversation turns to productionization.

---

**[END OF APPENDIX I]**
