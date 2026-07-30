# Appendix E: Performance Tuning Guide

## Optimizing Your Orchestrator System for Production

This appendix provides comprehensive performance tuning strategies for the Orchestrator system. Think of this like tuning a race car - every component needs to work together at maximum efficiency for peak performance.

### 1. Performance Overview

#### Key Performance Metrics

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| Response Time (p95) | < 100ms | > 500ms |
| Throughput | > 1000 req/s | < 100 req/s |
| Error Rate | < 0.1% | > 1% |
| Memory Usage | < 512MB | > 1GB |
| CPU Usage | < 70% | > 90% |
| Database Connections | < 20 | > 50 |
| Event Processing Lag | < 1s | > 5s |

#### Performance Bottlenecks

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      PERFORMANCE BOTTLENECKS                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Database             2. Cache              3. Network                  │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────────┐    │
│  │ • Slow queries  │    │ • Cache misses  │    │ • High latency      │    │
│  │ • Connection    │    │ • Eviction      │    │ • Bandwidth limits  │    │
│  │   pooling       │    │ • TTL           │    │ • DNS resolution    │    │
│  │ • Index usage   │    │ • Serialization │    │ • SSL handshake     │    │
│  └─────────────────┘    └─────────────────┘    └─────────────────────┘    │
│                                                                             │
│  4. Application         5. Event Store       6. AI Integration             │
│  └─────────────────┘    └─────────────────┘    └─────────────────────┘    │
│  • CPU-intensive      │  • Event volume   │  • LLM latency          │    │
│  • Memory leaks       │  • Backpressure   │  • Token usage          │    │
│  • Garbage            │  • Stream         │  • Rate limits          │    │
│    collection         │    processing     │                         │    │
│                       │                   │                         │    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Database Optimization

#### Index Optimization

**Identifying Slow Queries:**

```sql
-- Find slow queries
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    max_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- Find queries with low index usage
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_scan DESC;
```

**Recommended Indexes:**

```sql
-- Users table
CREATE INDEX idx_users_email_lower ON users(LOWER(email));
CREATE INDEX idx_users_username_lower ON users(LOWER(username));
CREATE INDEX idx_users_created_at_desc ON users(created_at DESC);

-- Tasks table
CREATE INDEX idx_tasks_user_status_priority ON tasks(user_id, status, priority);
CREATE INDEX idx_tasks_due_date_status ON tasks(due_date, status);
CREATE INDEX idx_tasks_priority_created ON tasks(priority, created_at DESC);

-- Events table
CREATE INDEX idx_events_aggregate_type_occurred ON events(aggregate_type, occurred_at DESC);
CREATE INDEX idx_events_event_type_created ON events(event_type, created_at DESC);

-- Partial indexes for specific use cases
CREATE INDEX idx_tasks_pending_due ON tasks(due_date) WHERE status = 'pending';
CREATE INDEX idx_users_active_email ON users(email) WHERE is_active = true;
```

**Query Optimization Examples:**

```typescript
// ❌ BAD: N+1 Query Problem
const users = await getUsers();
for (const user of users) {
    const tasks = await getTasksByUser(user.id); // N queries!
}

// ✅ GOOD: Single Query with JOIN
const result = await db.query(`
    SELECT u.*, json_agg(t.*) as tasks
    FROM users u
    LEFT JOIN tasks t ON u.id = t.user_id
    WHERE u.id = ANY($1)
    GROUP BY u.id
`, [userIds]);

// ✅ GOOD: Batch Query
const tasks = await db.query(
    'SELECT * FROM tasks WHERE user_id = ANY($1)',
    [userIds]
);
```

#### Connection Pooling

**Recommended Pool Configuration:**

```typescript
// src/infrastructure/adapters/persistence/postgres/connection.ts
const poolConfig = {
    max: process.env.NODE_ENV === 'production' ? 20 : 10,
    min: process.env.NODE_ENV === 'production' ? 5 : 0,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
    statement_timeout: 30000,
    query_timeout: 30000,
    maxUses: 7500, // Recycle connections
};

// Monitor pool usage
pool.on('acquire', (client) => {
    console.log('Pool acquire', pool.totalCount, pool.idleCount, pool.waitingCount);
});
```

#### Read Replicas

```sql
-- Configure read replica
CREATE USER replicator WITH REPLICATION;
GRANT CONNECT ON DATABASE orchestrator TO replicator;

-- Use read replica for queries
const readPool = new Pool({
    connectionString: process.env.DATABASE_READ_URL,
    ...poolConfig,
});

// Route queries
async function getUser(id: string) {
    // Reads go to replica
    const result = await readPool.query('SELECT * FROM users WHERE id = $1', [id]);
    // Writes go to primary
    if (needsUpdate) {
        await writePool.query('UPDATE users SET ...');
    }
}
```

### 3. Redis Cache Optimization

#### Cache Strategy

**Optimizing Cache Hit Ratio:**

```typescript
// src/infrastructure/adapters/cache/redis/cache.service.ts
class OptimizedCacheService {
    // Multi-level cache with different TTLs
    async getOrSet<T>(key: string, fetchFn: () => Promise<T>): Promise<T> {
        // 1. Check L1 (local memory) cache
        const l1 = await this.localCache.get(key);
        if (l1) return l1;

        // 2. Check L2 (Redis) cache
        const l2 = await this.redis.get(key);
        if (l2) {
            // Populate L1 for future requests
            await this.localCache.set(key, l2, 30);
            return l2;
        }

        // 3. Fetch from source
        const result = await fetchFn();
        
        // 4. Populate caches with appropriate TTLs
        await this.localCache.set(key, result, 30);
        await this.redis.set(key, result, 300);
        
        return result;
    }

    // Cache warming for popular data
    async warmCache(): Promise<void> {
        const popularUsers = await this.getPopularUsers();
        for (const user of popularUsers) {
            await this.getOrSet(`user:${user.id}`, () => user);
        }
    }
}
```

**Redis Memory Management:**

```bash
# Redis config optimization
redis-cli CONFIG SET maxmemory 2GB
redis-cli CONFIG SET maxmemory-policy allkeys-lru
redis-cli CONFIG SET save "900 1 300 10 60 10000"

# Monitor memory usage
redis-cli INFO memory
redis-cli INFO stats | grep evicted_keys
redis-cli --bigkeys
```

#### Batch Operations

```typescript
// ❌ BAD: Individual operations
for (const key of keys) {
    await redis.get(key); // N round trips
}

// ✅ GOOD: Batch operations
const pipeline = redis.pipeline();
for (const key of keys) {
    pipeline.get(key);
}
const results = await pipeline.exec();

// ✅ GOOD: MGET for simple keys
const results = await redis.mget(keys);
```

### 4. API Gateway Optimization

#### Response Caching

**File:** `src/infrastructure/adapters/http/middleware/cache.ts`

```typescript
import { FastifyReply, FastifyRequest } from 'fastify';
import { createHash } from 'crypto';

export async function responseCacheMiddleware(
    request: FastifyRequest,
    reply: FastifyReply
): Promise<void> {
    // Only cache GET requests
    if (request.method !== 'GET') return;

    // Generate cache key
    const cacheKey = generateCacheKey(request);
    
    // Check cache
    const cached = await cacheService.get(cacheKey);
    if (cached) {
        reply.header('X-Cache', 'HIT');
        reply.send(cached);
        return;
    }

    // Store response in cache
    reply.hook('onSend', async (payload) => {
        if (reply.statusCode === 200) {
            const ttl = getTTL(request.url);
            await cacheService.set(cacheKey, payload, ttl);
        }
        return payload;
    });
}

function generateCacheKey(request: FastifyRequest): string {
    const { url, headers } = request;
    const userKey = headers['x-user-id'] || 'anonymous';
    const acceptLanguage = headers['accept-language'] || 'en';
    
    const str = `${url}:${userKey}:${acceptLanguage}`;
    return createHash('sha256').update(str).digest('hex');
}
```

#### Compression

```typescript
// Enable compression
fastify.register(require('@fastify/compress'), {
    global: true,
    threshold: 1024, // Only compress responses > 1KB
    brotli: true,
    zlib: {
        level: 9,
    },
});

// Response size comparison
// Before compression: 50KB
// After compression: 12KB (76% reduction)
```

### 5. Event Store Optimization

#### Event Processing Batching

```typescript
// src/infrastructure/adapters/streams/event-processor.ts
class OptimizedEventProcessor {
    constructor(
        private batchSize: number = 100,
        private batchTimeout: number = 100
    ) {}

    async processEvents(events: DomainEvent[]): Promise<void> {
        // 1. Batch writes
        const batches = chunk(events, this.batchSize);
        for (const batch of batches) {
            await this.writeBatch(batch);
        }

        // 2. Use COPY for bulk inserts
        await this.bulkInsert(events);
    }

    async bulkInsert(events: DomainEvent[]): Promise<void> {
        const client = await pool.connect();
        try {
            const query = `
                INSERT INTO events (event_id, aggregate_id, ...)
                VALUES ${events.map((_, i) => 
                    `($${i * 7 + 1}, $${i * 7 + 2}, ...)`
                ).join(', ')}
            `;
            await client.query(query, this.flattenEvents(events));
        } finally {
            client.release();
        }
    }
}
```

#### Snapshot Strategy

```typescript
// Take snapshots every N events
class SnapshotManager {
    async getAggregate(id: string): Promise<Aggregate> {
        // Get latest snapshot
        const snapshot = await this.getLatestSnapshot(id);
        
        // Get events after snapshot
        const events = await eventStore.getEventsFromVersion(
            id, 
            snapshot.version
        );

        // Rebuild from snapshot
        const aggregate = this.rebuildFromSnapshot(snapshot.data);
        for (const event of events) {
            aggregate.apply(event);
        }

        // Take snapshot if needed
        if (events.length > this.snapshotThreshold) {
            await this.takeSnapshot(aggregate);
        }

        return aggregate;
    }
}
```

### 6. AI Agent Optimization

#### Token Optimization

```typescript
// src/core/domain/agents/base-agent.ts
class OptimizedAgent {
    private async plan(): Promise<any> {
        // 1. Summarize context to reduce tokens
        const context = await this.getOptimizedContext();
        
        // 2. Use smaller model for simple tasks
        const model = this.isComplexTask() ? 'gpt-4' : 'gpt-3.5-turbo';
        
        // 3. Cache common responses
        const cacheKey = `plan:${this.taskType}:${this.contextHash}`;
        const cached = await this.cache.get(cacheKey);
        if (cached) return cached;

        // 4. Limit tool descriptions to what's needed
        const tools = this.getRelevantTools();
        
        const response = await this.llm.complete(messages, {
            model,
            maxTokens: this.calculateOptimalTokens(),
            tools: tools.map(t => this.compressToolDefinition(t)),
        });

        await this.cache.set(cacheKey, response, 300);
        return response;
    }

    private calculateOptimalTokens(): number {
        // Dynamic token limit based on complexity
        const baseTokens = 500;
        const toolTokens = this.tools.size * 50;
        const contextTokens = this.contextLength * 0.1;
        return Math.min(baseTokens + toolTokens + contextTokens, 2000);
    }
}
```

#### Response Streaming

```typescript
// Stream responses for better perceived performance
async *streamAgentResponse(task: string): AsyncIterable<string> {
    const stream = await this.llm.stream(
        this.buildMessages(task),
        { temperature: 0.7 }
    );

    for await (const chunk of stream) {
        yield chunk.content;
        // Update client immediately
        await this.sendProgress(chunk.content);
    }

    // Final processing
    await this.finalize();
}
```

### 7. Network Optimization

#### Connection Pooling

```typescript
// HTTP connection pooling
import { Agent } from 'https';
const agent = new Agent({
    keepAlive: true,
    keepAliveMsecs: 1000,
    maxSockets: 50,
    maxFreeSockets: 10,
    timeout: 60000,
});

// Use in fetch
fetch(url, { 
    agent,
    // or
    // Use undici for better performance
});
```

#### DNS Caching

```typescript
// Enable DNS caching
import { setDefaultResultOrder } from 'dns';
setDefaultResultOrder('ipv4first');

// Use cache dns
const dnsCache = new Map();
async function getCachedDNS(hostname: string): Promise<string> {
    if (dnsCache.has(hostname)) {
        return dnsCache.get(hostname);
    }
    const result = await dns.promises.lookup(hostname);
    dnsCache.set(hostname, result.address);
    setTimeout(() => dnsCache.delete(hostname), 60000);
    return result.address;
}
```

### 8. Monitoring & Profiling

#### Performance Monitoring

```typescript
// src/infrastructure/adapters/monitoring/performance.ts
export class PerformanceMonitor {
    private metrics: {
        requests: number;
        errors: number;
        latency: number[];
        memoryUsage: number[];
        cpuUsage: number[];
    } = { requests: 0, errors: 0, latency: [], memoryUsage: [], cpuUsage: [] };

    trackRequest(startTime: number, error?: Error): void {
        const latency = Date.now() - startTime;
        this.metrics.requests++;
        this.metrics.latency.push(latency);
        
        if (error) this.metrics.errors++;
        
        // Keep only last 1000 values
        if (this.metrics.latency.length > 1000) {
            this.metrics.latency.shift();
        }
    }

    getMetrics(): PerformanceMetrics {
        const { latency } = this.metrics;
        const sorted = [...latency].sort((a, b) => a - b);
        
        return {
            requests: this.metrics.requests,
            errors: this.metrics.errors,
            errorRate: (this.metrics.errors / this.metrics.requests) * 100,
            latency: {
                avg: latency.reduce((a, b) => a + b, 0) / latency.length,
                p50: sorted[Math.floor(sorted.length * 0.5)],
                p95: sorted[Math.floor(sorted.length * 0.95)],
                p99: sorted[Math.floor(sorted.length * 0.99)],
            },
            memory: process.memoryUsage(),
            cpu: process.cpuUsage(),
        };
    }
}
```

#### Performance Testing

```bash
# Load test with Apache Bench
ab -n 10000 -c 100 -k https://api.orchestrator.com/health

# Load test with wrk
wrk -t12 -c400 -d30s https://api.orchestrator.com/health

# Detailed performance profiling
node --prof app.js
node --prof-process isolate-0x*.log > profile.txt
```

### 9. Performance Tuning Checklist

#### Database
- [ ] Add proper indexes for all query patterns
- [ ] Configure connection pooling
- [ ] Use read replicas for reporting
- [ ] Implement query caching
- [ ] Monitor slow query log

#### Cache
- [ ] Implement multi-level caching
- [ ] Optimize TTL values
- [ ] Use batch operations
- [ ] Implement cache warming
- [ ] Monitor hit ratio

#### Application
- [ ] Enable compression
- [ ] Use connection pooling
- [ ] Implement response caching
- [ ] Optimize event processing
- [ ] Minimize garbage collection

#### Network
- [ ] Enable keep-alive
- [ ] Use HTTP/2
- [ ] Implement DNS caching
- [ ] Use CDN for static assets
- [ ] Optimize TLS/SSL

#### AI Integration
- [ ] Optimize token usage
- [ ] Use appropriate models
- [ ] Implement caching
- [ ] Use streaming responses
- [ ] Batch similar requests

---

This performance tuning guide provides comprehensive strategies to optimize every component of your Orchestrator system. Use these techniques to achieve maximum performance in production.
