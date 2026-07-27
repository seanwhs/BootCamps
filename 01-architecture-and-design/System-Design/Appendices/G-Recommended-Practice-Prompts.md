# Appendix G: Recommended Practice Prompts (with Hidden Focus Areas)

Deliberate practice beats random practice. This appendix gives you a curated set of system-design prompts organized by difficulty and learning goal. Each prompt includes the **hidden focus areas** that strong candidates are expected to surface — do not look at them until you have finished your own design.

**How to use**
1. Set a timer (35–45 minutes).  
2. Follow the six-step framework from Part 8.  
3. Score yourself with the rubric in Appendix D.  
4. Only then read the hidden focus areas and compare.

---

### G.1 Foundational Prompts (Build Process Muscle)

#### Prompt 1 – URL Shortener
Design a URL shortening service like bit.ly.

**Hidden focus areas**  
- Key generation strategy (counter vs hash) and collision handling  
- Read-heavy workload → caching and low-latency redirect path  
- Analytics / click tracking without hurting the redirect path  
- Sharding and hot-key protection  

#### Prompt 2 – Pastebin / Code Snippet Store
Design a service that lets users upload text snippets and share them via short links. Snippets can be public or private and may expire.

**Hidden focus areas**  
- Storage choice for potentially large text blobs  
- Expiration and background deletion  
- Access control for private pastes  
- Rate limiting on creation to prevent abuse  

#### Prompt 3 – Rate Limiter Service
Design a distributed rate limiter that can be used by many internal services.

**Hidden focus areas**  
- Algorithm choice (token bucket vs sliding window) and trade-offs  
- Centralized vs decentralized implementation  
- Behavior when the rate-limiter store itself is unavailable  
- Supporting multiple limit dimensions (per user, per IP, per API key)

---

### G.2 Intermediate Prompts (Depth + Trade-offs)

#### Prompt 4 – Notification System
Design a multi-channel notification system (email, push, SMS) that can handle high volume and guarantee eventual delivery.

**Hidden focus areas**  
- Fan-out and async processing  
- Provider failover and retry semantics  
- User preferences, quiet hours, and unsubscribe  
- Idempotency and deduplication  
- At-least-once delivery and exactly-once illusions  

#### Prompt 5 – News Feed
Design a Facebook/Twitter-style news feed.

**Hidden focus areas**  
- Fan-out-on-write vs fan-out-on-read vs hybrid  
- Celebrity / hot-key problem  
- Ranking and personalization as a separate concern  
- Consistency model for the feed vs the source posts  
- Timeline storage and eviction  

#### Prompt 6 – Chat / Messaging System
Design a WhatsApp or Slack-style messaging system that supports 1:1 and group chats.

**Hidden focus areas**  
- WebSocket connection management and presence  
- Message ordering and delivery guarantees  
- Fan-out for group chats  
- Offline delivery and multi-device sync  
- Media handling and storage  

#### Prompt 7 – Ride-Sharing Dispatch
Design the matching and dispatch system for a ride-sharing app (Uber/Lyft style).

**Hidden focus areas**  
- Geo-indexing and nearest-driver search  
- Consistency of driver inventory (avoid double-booking)  
- Ride state machine and timeouts  
- Surge pricing and real-time location updates  
- Failure handling when a driver or rider disconnects  

---

### G.3 Advanced Prompts (Multi-System Thinking)

#### Prompt 8 – Video Streaming Platform
Design a YouTube/Netflix-style video streaming service.

**Hidden focus areas**  
- Upload + transcoding pipeline (async)  
- CDN strategy and adaptive bitrate  
- Metadata vs media storage separation  
- Recommendation and watch-history systems  
- DRM / authorization for paid content  
- Hot content vs long-tail content handling  

#### Prompt 9 – Collaborative Document Editor
Design a Google Docs-style real-time collaborative editor.

**Hidden focus areas**  
- Conflict resolution (OT or CRDT)  
- Real-time synchronization protocol  
- Presence and cursor sharing  
- Persistent storage of document versions  
- Access control and sharing model  
- Scaling large documents with many concurrent editors  

#### Prompt 10 – E-Commerce Checkout & Inventory
Design the checkout and inventory reservation system for a large online store.

**Hidden focus areas**  
- Inventory reservation and overselling prevention  
- Distributed transaction / Saga across payment, inventory, order  
- Idempotency of payment and order creation  
- Cart consistency and abandonment  
- High contention on popular items  

#### Prompt 11 – Search Autocomplete / Typeahead
Design a system that provides low-latency search suggestions as the user types.

**Hidden focus areas**  
- Prefix indexing and data structures (tries, sorted sets)  
- Personalization vs global popularity  
- Handling typos and ranking  
- Freshness of the suggestion index  
- Extremely tight latency budget  

#### Prompt 12 – Multi-Tenant SaaS Metrics / Analytics Platform
Design a system that ingests, stores, and queries metrics for thousands of customer tenants.

**Hidden focus areas**  
- Tenant isolation (noisy-neighbor protection)  
- High-cardinality time-series storage  
- Query patterns (range scans, aggregations)  
- Retention and downsampling  
- Cost control and per-tenant quotas  

---

### G.4 Specialized / Cross-Cutting Prompts

#### Prompt 13 – Distributed Locking Service
Design a highly available distributed lock service.

**Hidden focus areas**  
- Correctness under network partitions  
- Fencing tokens / generation numbers  
- Lease-based vs lock-based designs  
- Performance vs safety trade-offs  

#### Prompt 14 – Feature Flag System
Design an internal feature-flag service used by many product teams.

**Hidden focus areas**  
- Low-latency evaluation at high QPS  
- Targeting rules (user, percentage, segment)  
- Consistency of flag state across services  
- Auditability and kill switches  
- Integration with CI/CD and progressive delivery  

#### Prompt 15 – Global Unique ID Generator
Design a service that generates unique, roughly ordered 64-bit IDs at very high throughput.

**Hidden focus areas**  
- Snowflake-style design vs UUID vs database sequences  
- Clock skew handling  
- Availability vs uniqueness guarantees  
- Scaling across data centers  

---

### G.5 Practice Schedule Suggestion

| Week | Focus | Prompts |
|------|-------|---------|
| 1 | Process & estimation | 1, 2, 3 |
| 2 | Async & fan-out | 4, 5 |
| 3 | Real-time & state | 6, 7 |
| 4 | Media & large scale | 8, 9 |
| 5 | Transactions & contention | 10, 11 |
| 6 | Platform / infra style | 12, 13, 14, 15 |
| Ongoing | Mixed timed mocks | Random selection + full rubric scoring |

---

### G.6 How to Extract Maximum Learning

After each session ask:

1. Which hidden focus areas did I completely miss?  
2. Which ones did I touch only superficially?  
3. Did my estimates actually influence any design decision?  
4. Did I discuss at least two failure modes relevant to this problem?  
5. What is the single highest-leverage improvement for the next attempt?

Record the answers. Patterns will emerge quickly (for example: “I keep forgetting offline/fallback behavior” or “I never quantify the hot-key risk”).

---

**[END OF APPENDIX G]**
