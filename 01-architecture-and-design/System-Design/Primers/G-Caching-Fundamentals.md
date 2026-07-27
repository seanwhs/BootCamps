# Primer G: Caching Fundamentals in One Picture

Caching is one of the highest-leverage techniques in system design. Done well, it dramatically improves latency and reduces load on databases. Done poorly, it creates consistency bugs and hard-to-debug incidents. This primer gives you the essential mental model.

### 1. The Core Idea

A **cache** is a fast, smaller store that sits between the client and the slower source of truth (usually a database). The goal is to answer repeated or popular requests from the fast store instead of the slow one.

Analogy: instead of walking to the library every time you need a fact, you keep the most-used books on your desk.

### 2. The Four Most Common Places to Cache

```
User’s device
    │
    ▼
CDN / Edge cache          ← static assets, public pages
    │
    ▼
Application cache         ← Redis, Memcached, in-process
    │
    ▼
Database buffer / query cache
    │
    ▼
Source of truth (database, object storage, etc.)
```

The closer the cache is to the user, the lower the latency, but the harder it becomes to keep the data correct and up-to-date.

### 3. The Dominant Pattern: Cache-Aside (Lazy Loading)

This is the pattern you will use most often:

1. Application receives a read request.
2. It first asks the cache.
3. **Cache hit** → return the data immediately.
4. **Cache miss** → load from the database, store the result in the cache, then return it.

Writes usually go to the database first; the cache entry is either updated or deleted (invalidated) so the next read refreshes it.

**Why it is popular**: The cache only contains data that has actually been requested. You do not waste memory on unused items.

### 4. Other Important Patterns (Short Version)

| Pattern | How it works | Main advantage | Main risk |
|---------|--------------|----------------|-----------|
| **Cache-aside** | App manages the cache | Simple, only hot data is cached | Extra logic in the application |
| **Write-through** | Write goes to cache and database together | Cache is always fresh | Higher write latency |
| **Write-behind** (write-back) | Write goes to cache; database is updated later | Very fast writes | Data loss if cache dies before flush |
| **Read-through** | Cache itself knows how to load data on miss | Application code is simpler | Cache becomes a more critical dependency |

### 5. Expiration and Eviction

Caches are limited in size, so entries must eventually leave.

**TTL (Time-To-Live)**  
Each entry is given a lifetime. After it expires, the next request is a miss and the data is reloaded. Simple and widely used.

**Eviction policies** (when the cache is full):

- **LRU (Least Recently Used)** – discard the item that has not been touched for the longest time. Most common.
- **LFU (Least Frequently Used)** – discard the item that has been requested least often.
- Others exist (FIFO, random, etc.), but LRU and LFU cover most practical cases.

### 6. The Consistency Problem

The moment you add a cache, you create the possibility that the cache and the database disagree.

Common strategies:

- **Invalidate on write** – delete the cache entry when the data changes. Next read reloads fresh data.
- **Update on write** – write the new value into the cache at the same time as the database.
- **Short TTLs** – accept a bounded period of staleness.
- **Version numbers or cache keys that include a version** – make stale entries naturally unreachable.

There is no perfect universal solution. You choose based on how harmful stale data is for that particular piece of information.

### 7. Classic Failure Mode: Cache Stampede (Thundering Herd)

When a popular item expires (or is invalidated), many concurrent requests can all miss the cache at the same moment and slam the database.

Typical mitigations:

- Soft expiration / early refresh (refresh just before the real TTL)
- Request coalescing / single-flight (only one request loads the data; others wait for it)
- Locking around the fill operation
- Serving slightly stale data while a background refresh happens

### 8. What Caching Does *Not* Fix

- Bad database queries that return huge result sets
- Correctness problems in business logic
- The need for proper indexes
- Write-heavy workloads where the data is almost never re-read

Caching is a performance tool, not a substitute for sound data modeling.

### 9. What You Should Be Able to Do After This Primer

- Explain the cache-aside pattern step by step.
- List the main layers where caches commonly sit.
- Describe the trade-off between freshness and performance.
- Explain what a cache stampede is and name at least one mitigation.
- Decide, for a given piece of data, whether a short TTL, explicit invalidation, or strong consistency is more appropriate.
- Argue why “just cache everything” is rarely a good strategy.

This primer directly supports Part 4 of the series and appears in almost every real architectural blueprint.

**[END OF PRIMER G]**
