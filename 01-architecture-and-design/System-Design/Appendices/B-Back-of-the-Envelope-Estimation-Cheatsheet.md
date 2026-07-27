# Appendix B: Back-of-the-Envelope Estimation Cheatsheet

Precise numbers are rarely available at the start of a design. Strong engineers make reasonable assumptions, state them clearly, and use them to drive decisions. This appendix gives you the formulas, rules of thumb, and worked examples you will reach for in interviews and real capacity planning.

### 1. Core Formulas

| Quantity | Formula | Notes |
|----------|---------|-------|
| **QPS** | Daily active users × actions per user per day / 86 400 | Always calculate both average and peak (usually 2–5× average) |
| **Storage** | Records × size per record × retention × replication factor | Don’t forget indexes, overhead, and growth |
| **Bandwidth** | QPS × average payload size | Separate ingress and egress |
| **Cache hit ratio needed** | 1 – (DB capacity / total read QPS) | Quick way to see how effective a cache must be |
| **Number of servers** | Peak QPS / QPS per server | Add 30–50 % headroom |
| **Shard count (rough)** | Total data size / target size per shard | Or total QPS / QPS capacity per shard |

### 2. Useful Constants & Rules of Thumb

| Item | Typical Value | Comments |
|------|---------------|----------|
| Seconds in a day | 86 400 | — |
| Seconds in a year | ≈ 31.5 million | — |
| Average web request size | 1–10 KB | HTML/JSON |
| Image / media request | 100 KB – several MB | Depends on quality |
| Typical DB row (user, post, order) | 1–10 KB | Including indexes |
| Redis/memory item overhead | ~50–100 bytes + data | — |
| Network RTT (same region) | 0.5–2 ms | — |
| Network RTT (cross-continent) | 50–150 ms | — |
| SSD sequential read | 500 MB/s – several GB/s | — |
| HDD sequential read | ~100–200 MB/s | Avoid for random I/O |
| Commodity server cores | 16–64 | 2024–2026 range |
| Safe QPS per simple API server | 1 000–5 000 | Highly dependent on work per request |
| Safe QPS per Redis instance (simple GET) | 50 000–200 000 | Single instance, in-memory |
| Safe QPS per well-indexed PostgreSQL | 5 000–20 000 | Point lookups; much lower for complex joins |
| Replication factor (production) | 3 | Common for durability + availability |
| Peak-to-average ratio | 2–5× | Social apps often higher; B2B often lower |

### 3. Latency Budgets (Rule of Thumb)

| Layer | Comfortable Latency | Notes |
|-------|---------------------|-------|
| Browser → CDN edge | < 50 ms | Static assets |
| Edge → origin (same region) | 5–30 ms | — |
| Application logic (simple) | 1–10 ms | — |
| In-memory cache (Redis) | < 1 ms | Same AZ |
| Database point lookup | 1–5 ms | Good indexes, warm cache |
| Database complex query | 10–100+ ms | Needs optimization or caching |
| Cross-region call | 50–200 ms | Avoid on critical path |

**Total user-facing budget**: most interactive APIs aim for < 100–200 ms p99 end-to-end.

### 4. Worked Examples

#### Example A – URL Shortener
**Assumptions**  
- 100 million new URLs per month  
- Read:write ratio = 100:1  
- Peak QPS = 3 × average  

**Calculations**
- Write QPS (average) = 100e6 / (30 × 86 400) ≈ 40 QPS  
- Peak write QPS ≈ 120 QPS  
- Peak read QPS ≈ 12 000 QPS  

**Storage** (5 years, 500 bytes per record, 3× replication)  
100e6 × 12 × 5 × 500 × 3 ≈ 9 TB  

**Conclusion**: A single well-designed key-value cluster + cache can handle this comfortably. Focus shifts to hot-key protection and low-latency redirects.

#### Example B – Social News Feed
**Assumptions**  
- 300 million DAU  
- Average user posts 0.2 times/day and reads feed 10 times/day  
- Average feed response = 50 KB  

**Calculations**
- Write QPS (posts) ≈ 300e6 × 0.2 / 86 400 ≈ 700 QPS  
- Read QPS (feed) ≈ 300e6 × 10 / 86 400 ≈ 35 000 QPS  
- Peak read QPS ≈ 100 000 QPS  
- Egress bandwidth ≈ 100 000 × 50 KB ≈ 5 GB/s  

**Conclusion**: Heavy read load → aggressive caching + fan-out strategy is mandatory. Pure request-response against a single database will not survive.

#### Example C – Rate Limiter
**Assumptions**  
- 1 million API keys  
- Each key limited to 100 requests/minute  
- Check happens on every API call (500 kQPS peak)  

**Calculations**
- Redis commands per second ≈ 500 000  
- Memory for token buckets (assuming 64 bytes per key) ≈ 64 MB  

**Conclusion**: A small Redis cluster easily handles the data plane. The design challenge is availability of the limiter itself and correct behavior under Redis failure.

### 5. Estimation Hygiene (What Interviewers Notice)

- Always state your assumptions out loud.  
- Round aggressively (order-of-magnitude is usually enough).  
- Calculate both average and peak.  
- Convert everything to the same units (usually per second).  
- Sanity-check against known systems (“Does this sound like Twitter-scale or like a mid-size SaaS?”).  
- Use the numbers to decide *where* to put effort (caching, sharding, async, etc.).

### 6. Quick Reference Card (Memorize These)

```
1 day          ≈ 10^5 seconds
1 year         ≈ 3 × 10^7 seconds
1 KB           = 10^3 bytes
1 MB           = 10^6 bytes
1 GB           = 10^9 bytes
1 TB           = 10^12 bytes

Typical peak QPS targets:
- Small service:     hundreds
- Medium service:    low thousands
- Large consumer app: tens to hundreds of thousands
- Global giants:     millions
```

---

**How to use this appendix**
- In interviews: spend 2–3 minutes on estimates right after requirements. Write the key numbers on the board.  
- In real projects: turn the same calculations into a short capacity model before major features or traffic events.  
- When numbers feel uncertain: pick a conservative (higher) peak and design for that; it is easier to scale down than to be surprised.

**[END OF APPENDIX B]**
