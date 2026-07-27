# Appendix C: Technology Decision Maps

Choosing technologies is less about “which is best” and more about “which constraints matter most for this problem.” This appendix gives you practical decision maps you can use in interviews and real design discussions.

Each map follows the same pattern:  
**Primary question → Options → When to prefer each → Common traps**

---

### C.1 Data Storage: SQL vs NoSQL Families

**Primary question**: What do the access patterns and consistency requirements look like?

| If you need… | Prefer | Examples | Watch out for |
|--------------|--------|----------|---------------|
| Multi-row transactions, complex joins, strong consistency | Relational (SQL) | PostgreSQL, MySQL | Scaling writes horizontally is harder |
| Flexible schema, document-shaped data, frequent reads of whole aggregates | Document store | MongoDB, DynamoDB (document), Couchbase | Cross-document transactions are limited or expensive |
| Simple key lookups, extremely high throughput, low latency | Key-value store | Redis, DynamoDB, etcd, FoundationDB | Poor for secondary indexes or complex queries |
| Time-series or analytical scans over many rows | Columnar / wide-column | ClickHouse, BigQuery, Cassandra, ScyllaDB | Not ideal for high-frequency single-row updates |
| Rich relationship traversal (social graph, recommendations) | Graph database | Neo4j, Amazon Neptune | Can become expensive at very large scale; sometimes a relational DB + recursive CTEs is enough |

**Rule of thumb**: Start with PostgreSQL unless you have a clear reason not to. Move to specialized stores when a specific access pattern becomes the bottleneck.

---

### C.2 Caching Layer

**Primary question**: Where does the data live and how fresh must it be?

| Need | Prefer | Why |
|------|--------|-----|
| Ultra-low latency, simple data structures, ephemeral state | Redis | Rich data structures, high performance, mature ecosystem |
| Pure cache with very large working set and simple get/set | Memcached | Lower memory overhead, simpler, multi-threaded |
| Cache that must survive restarts and support complex queries | Redis (with persistence) or a dedicated cache tier in front of DB | — |
| Global static or semi-static content | CDN | Closest to users, massive scale |
| Application-level computed results | Redis or in-process + Redis | — |

**Common trap**: Using Redis as a primary database without understanding persistence and failover implications.

---

### C.3 Messaging & Asynchronous Communication

**Primary question**: Do you need a work queue, an event stream, or both?

| Requirement | Prefer | Examples | Notes |
|-------------|--------|----------|-------|
| Simple task distribution, competing consumers, acknowledgments | Classic message queue | RabbitMQ, Amazon SQS, Google Cloud Tasks | Excellent for background jobs |
| High-throughput event streaming, replay, multiple independent consumers, ordering per key | Log-based streaming | Kafka, Pulsar, Kinesis | Strong durability and replay story |
| Lightweight pub/sub inside a single cloud | Cloud-native pub/sub | SNS + SQS, Pub/Sub, Event Grid | Fast to adopt, less operational burden |
| Exactly-once or very strong ordering | Kafka (with care) or transactional outbox + queue | Harder than it sounds; prefer at-least-once + idempotency |

**Decision shortcut**:
- “Fire and forget background work” → Queue  
- “Multiple downstream systems need the same events + replay” → Kafka-style log  
- “I just want decoupling inside one cloud” → Managed pub/sub

---

### C.4 Load Balancing & Traffic Management

| Situation | Prefer | Reason |
|-----------|--------|--------|
| Simple TCP/UDP distribution, maximum performance | L4 load balancer | Lower latency, less CPU |
| Path-based or header-based routing, SSL termination, WAF, auth | L7 load balancer / API Gateway | Application awareness |
| Sticky sessions required (legacy) | L7 with session affinity or consistent hashing | Avoid if possible — prefer stateless |
| Global traffic direction | DNS + Geo / latency-based routing + anycast | Cloud load balancers or Cloudflare, Fastly, etc. |

---

### C.5 Consistency & Coordination

| Need | Prefer | Examples |
|------|--------|----------|
| Strong consistency + coordination (leader election, locks, config) | Consensus systems | etcd, ZooKeeper, Consul |
| Strong consistency for business data | Relational DB with proper transactions | PostgreSQL |
| High availability over strong consistency | AP stores + application-level conflict resolution | Cassandra, DynamoDB (eventual), Riak |
| Distributed transactions across services | Saga (preferred) or 2PC (rare) | Orchestration or choreography |

---

### C.6 Service Communication Style

| Situation | Prefer | Why |
|-----------|--------|-----|
| Public APIs, browser/mobile clients | HTTP/REST + JSON | Universal, debuggable, cacheable |
| Internal service-to-service, low latency, strict contracts | gRPC | Efficient, typed, HTTP/2, streaming |
| Real-time bidirectional updates | WebSockets (or SSE for one-way) | Persistent connection |
| Heavy fan-out or background processing | Async events / messages | Decouples producers from consumers |

---

### C.7 Deployment & Orchestration (High-Level)

| Stage / Need | Common Choice | Notes |
|--------------|---------------|-------|
| Simple services, small team | Managed containers (ECS, Cloud Run, App Service) or even VMs | Lower operational overhead |
| Complex microservices, advanced traffic control | Kubernetes | Powerful but higher complexity |
| Serverless / event-driven spikes | Functions (Lambda, Cloud Functions) + managed queues | Great for bursty or infrequent work |
| Global low-latency edge logic | Cloudflare Workers, Fastly Compute, etc. | When logic must run close to users |

---

### C.8 Security Building Blocks

| Concern | Typical Choice |
|---------|----------------|
| Service-to-service identity | mTLS (service mesh) or short-lived tokens (SPIFFE/SPIRE, cloud IAM) |
| External API authentication | OAuth2 / OIDC + JWT |
| Secrets | Cloud secret manager or Vault — never in images or git |
| Edge protection | CDN + WAF + rate limiting + DDoS protection |
| Network isolation | Security groups / network policies (deny by default) |

---

### Quick Decision Flow (One-Page Version)

```
1. What does the data look like and how is it accessed?
   → Choose primary store (SQL / document / KV / columnar / graph)

2. How fresh must reads be?
   → Strong consistency vs eventual + caching strategy

3. Is the work on the critical path?
   → Synchronous vs asynchronous (queue or stream)

4. How will traffic enter the system?
   → L4 vs L7, API Gateway, CDN, rate limits

5. What happens when a dependency fails?
   → Timeouts, retries, circuit breakers, bulkheads, fallbacks

6. How will we operate it?
   → Deployment strategy, observability, secret management, migration plan
```

---

**How to use this appendix in practice**

- In interviews: when you name a technology, immediately follow with the constraint that justified it (“I’m choosing Redis here because we need sub-millisecond reads and simple data structures”).  
- In design docs: paste the relevant row into an “Alternatives Considered” section.  
- When teams argue about technology: bring the conversation back to the primary question each map starts with.

**[END OF APPENDIX C]**
