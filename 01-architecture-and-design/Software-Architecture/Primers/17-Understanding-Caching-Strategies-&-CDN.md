# Primer 17: Understanding Caching Strategies & CDN

## A Comprehensive Guide to Caching for Performance & Scale

Welcome to the seventeenth primer! This is a comprehensive deep dive into caching strategies and CDN (Content Delivery Network) implementation. Think of this like having a well-stocked prep kitchen at each restaurant location - frequently needed ingredients are always available nearby, dramatically reducing wait times and improving efficiency.

### 1. The Big Picture

#### Caching Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CACHING ARCHITECTURE                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    EDGE CACHE (CDN)                                 │   │
│  │  • Global distribution                                             │   │
│  │  • Static assets                                                   │   │
│  │  • API responses                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    REVERSE PROXY CACHE                              │   │
│  │  • Nginx/Varnish                                                   │   │
│  │  • API responses                                                   │   │
│  │  • Rate limiting                                                   │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    DISTRIBUTED CACHE (Redis)                        │   │
│  │  • Session data                                                    │   │
│  │  • API responses                                                   │   │
│  │  • Computed results                                                │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    APPLICATION CACHE                               │   │
│  │  • In-memory (local)                                               │   │
│  │  • Database query cache                                            │   │
│  │  • Object cache                                                    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Caching Strategies

#### Cache-Aside Pattern

```typescript
class CacheAside<T> {
    private cache: CacheService;
    private source: () => Promise<T>;
    private ttl: number;
    private logger: Logger;

    constructor(
        cache: CacheService,
        source: () => Promise<T>,
        ttl: number = 300 // 5 minutes default
    ) {
        this.cache = cache;
        this.source = source;
        this.ttl = ttl;
        this.logger = createLogger({ service: 'cache-aside' });
    }

    async get(key: string): Promise<T> {
        // 1. Check cache
        const cached = await this.cache.get<T>(key);
        
        if (cached !== null) {
            this.logger.debug({ key }, 'Cache hit');
            return cached;
        }

        // 2. Cache miss - fetch from source
        this.logger.debug({ key }, 'Cache miss');
        const value = await this.source();

        // 3. Store in cache
        if (value !== null && value !== undefined) {
            await this.cache.set(key, value, this.ttl);
            this.logger.debug({ key }, 'Value cached');
        }

        return value;
    }

    async invalidate(key: string): Promise<void> {
        await this.cache.delete(key);
        this.logger.debug({ key }, 'Cache invalidated');
    }
}
```

#### Write-Through Pattern

```typescript
class WriteThroughCache<T> {
    private cache: CacheService;
    private database: DatabaseService;
    private logger: Logger;

    constructor(cache: CacheService, database: DatabaseService) {
        this.cache = cache;
        this.database = database;
        this.logger = createLogger({ service: 'write-through' });
    }

    async write(key: string, value: T): Promise<void> {
        // 1. Write to database first
        await this.database.save(key, value);
        this.logger.debug({ key }, 'Database write successful');

        // 2. Then write to cache
        await this.cache.set(key, value);
        this.logger.debug({ key }, 'Cache write successful');
    }

    async read(key: string): Promise<T | null> {
        // 1. Check cache first
        const cached = await this.cache.get<T>(key);
        if (cached !== null) {
            this.logger.debug({ key }, 'Cache hit');
            return cached;
        }

        // 2. Cache miss - read from database
        const value = await this.database.get<T>(key);
        if (value !== null) {
            // 3. Write back to cache
            await this.cache.set(key, value);
            this.logger.debug({ key }, 'Value cached');
        }

        return value;
    }
}
```

#### Write-Behind Pattern

```typescript
class WriteBehindCache<T> {
    private cache: CacheService;
    private database: DatabaseService;
    private queue: WriteOperation<T>[] = [];
    private flushInterval: NodeJS.Timeout;
    private logger: Logger;

    constructor(
        cache: CacheService,
        database: DatabaseService,
        flushIntervalMs: number = 5000
    ) {
        this.cache = cache;
        this.database = database;
        this.logger = createLogger({ service: 'write-behind' });
        
        // Start periodic flush
        this.flushInterval = setInterval(
            () => this.flush(),
            flushIntervalMs
        );
    }

    async write(key: string, value: T): Promise<void> {
        // 1. Write to cache immediately
        await this.cache.set(key, value);
        
        // 2. Queue for database write
        this.queue.push({
            key,
            value,
            timestamp: Date.now(),
        });

        // 3. Flush if queue is large
        if (this.queue.length >= 100) {
            await this.flush();
        }
    }

    private async flush(): Promise<void> {
        if (this.queue.length === 0) return;

        const operations = this.queue.splice(0, this.queue.length);
        this.logger.debug(
            { count: operations.length },
            'Flushing write-behind queue'
        );

        try {
            // Batch write to database
            await this.database.batchSave(operations);
            
            this.logger.debug(
                { count: operations.length },
                'Write-behind flush successful'
            );
        } catch (error) {
            this.logger.error(
                { error, count: operations.length },
                'Write-behind flush failed'
            );
            // Re-queue operations for retry
            this.queue.unshift(...operations);
        }
    }

    async shutdown(): Promise<void> {
        clearInterval(this.flushInterval);
        // Final flush
        await this.flush();
    }
}

interface WriteOperation<T> {
    key: string;
    value: T;
    timestamp: number;
}
```

### 3. Multi-Level Cache

```typescript
class MultiLevelCache<T> {
    private l1Cache: Map<string, { value: T; expires: number }>;
    private l2Cache: RedisCache;
    private l1TTL: number;
    private stats: {
        l1Hit: number;
        l1Miss: number;
        l2Hit: number;
        l2Miss: number;
    };

    constructor(l2Cache: RedisCache, l1TTL: number = 10000) {
        this.l1Cache = new Map();
        this.l2Cache = l2Cache;
        this.l1TTL = l1TTL;
        this.stats = { l1Hit: 0, l1Miss: 0, l2Hit: 0, l2Miss: 0 };
    }

    async get(key: string): Promise<T | null> {
        // Check L1 (in-memory) cache
        const l1Entry = this.l1Cache.get(key);
        if (l1Entry && l1Entry.expires > Date.now()) {
            this.stats.l1Hit++;
            return l1Entry.value;
        }
        this.stats.l1Miss++;

        // Check L2 (Redis) cache
        const l2Value = await this.l2Cache.get<T>(key);
        if (l2Value !== null) {
            this.stats.l2Hit++;
            // Promote to L1
            this.l1Cache.set(key, {
                value: l2Value,
                expires: Date.now() + this.l1TTL,
            });
            return l2Value;
        }
        this.stats.l2Miss++;

        return null;
    }

    async set(key: string, value: T): Promise<void> {
        // Set in both caches
        this.l1Cache.set(key, {
            value,
            expires: Date.now() + this.l1TTL,
        });
        await this.l2Cache.set(key, value);
    }

    async delete(key: string): Promise<void> {
        // Delete from both caches
        this.l1Cache.delete(key);
        await this.l2Cache.delete(key);
    }

    getStats(): {
        l1HitRate: number;
        l2HitRate: number;
        overallHitRate: number;
    } {
        const { l1Hit, l1Miss, l2Hit, l2Miss } = this.stats;
        const total = l1Hit + l1Miss + l2Hit + l2Miss;

        return {
            l1HitRate: l1Hit / (l1Hit + l1Miss) || 0,
            l2HitRate: l2Hit / (l2Hit + l2Miss) || 0,
            overallHitRate: (l1Hit + l2Hit) / total || 0,
        };
    }
}
```

### 4. Cache Invalidation Strategies

```typescript
class CacheInvalidationManager {
    private cache: MultiLevelCache<any>;
    private logger: Logger;

    constructor(cache: MultiLevelCache<any>) {
        this.cache = cache;
        this.logger = createLogger({ service: 'cache-invalidation' });
    }

    // TTL-based invalidation
    async invalidateByTime(
        keys: string[],
        ttl: number
    ): Promise<void> {
        for (const key of keys) {
            await this.cache.delete(key);
        }
        this.logger.debug(
            { count: keys.length, ttl },
            'Time-based invalidation'
        );
    }

    // Event-based invalidation
    async invalidateByEvent(
        event: DomainEvent,
        pattern: string
    ): Promise<void> {
        // Use pattern matching to invalidate related keys
        const keys = await this.findMatchingKeys(pattern);
        
        if (keys.length > 0) {
            for (const key of keys) {
                await this.cache.delete(key);
            }
            this.logger.debug({
                event: event.type,
                pattern,
                count: keys.length,
            }, 'Event-based invalidation');
        }
    }

    // Version-based invalidation
    async invalidateByVersion(
        key: string,
        newVersion: number
    ): Promise<void> {
        const versionKey = `${key}:version`;
        const currentVersion = await this.cache.get<number>(versionKey);
        
        if (currentVersion !== newVersion) {
            await this.cache.delete(key);
            await this.cache.set(versionKey, newVersion);
            this.logger.debug({
                key,
                currentVersion,
                newVersion,
            }, 'Version-based invalidation');
        }
    }

    private async findMatchingKeys(pattern: string): Promise<string[]> {
        // Implementation depends on cache provider
        // Redis: SCAN with pattern
        // This is a simplified version
        return [];
    }
}
```

### 5. CDN Integration

#### CDN Cache Configuration

```typescript
interface CDNConfig {
    distributionId: string;
    domain: string;
    cacheBehavior: {
        defaultTTL: number;
        maxTTL: number;
        minTTL: number;
        compress: boolean;
    };
    cacheRules: Array<{
        path: string;
        ttl: number;
        cacheMethods: string[];
    }>;
    invalidation: {
        batchSize: number;
        maxInvalidations: number;
    };
}

class CDNManager {
    private config: CDNConfig;
    private cloudfront: CloudFront;
    private logger: Logger;

    constructor(config: CDNConfig) {
        this.config = config;
        this.cloudfront = new CloudFront({
            region: 'us-east-1',
        });
        this.logger = createLogger({ service: 'cdn-manager' });
    }

    async invalidateCache(
        paths: string[],
        options?: {
            waitForCompletion?: boolean;
        }
    ): Promise<InvalidationResult> {
        if (paths.length === 0) {
            return { id: '', status: 'success', paths: [] };
        }

        // Group paths into batches
        const batches = this.chunkArray(
            paths,
            this.config.invalidation.batchSize
        );

        const results: InvalidationResult[] = [];

        for (const batch of batches) {
            try {
                const result = await this.cloudfront.createInvalidation({
                    DistributionId: this.config.distributionId,
                    InvalidationBatch: {
                        CallerReference: `${Date.now()}`,
                        Paths: {
                            Quantity: batch.length,
                            Items: batch,
                        },
                    },
                });

                results.push({
                    id: result.Invalidation.Id || '',
                    status: 'success',
                    paths: batch,
                });

                this.logger.info({
                    batchSize: batch.length,
                    invalidationId: result.Invalidation.Id,
                }, 'Cache invalidation created');

            } catch (error) {
                this.logger.error({
                    error,
                    batch,
                }, 'Cache invalidation failed');

                results.push({
                    id: '',
                    status: 'failed',
                    paths: batch,
                    error: error instanceof Error ? error.message : String(error),
                });
            }
        }

        return {
            id: results.map(r => r.id).join(','),
            status: results.every(r => r.status === 'success') ? 'success' : 'partial',
            paths,
            details: results,
        };
    }

    async getCacheStatus(path: string): Promise<{
        cached: boolean;
        lastInvalidated?: Date;
        ttl?: number;
    }> {
        // Implementation depends on CDN provider
        return { cached: true };
    }

    private chunkArray<T>(array: T[], size: number): T[][] {
        const chunks: T[][] = [];
        for (let i = 0; i < array.length; i += size) {
            chunks.push(array.slice(i, i + size));
        }
        return chunks;
    }
}
```

#### Edge Caching Strategy

```typescript
class EdgeCacheStrategy {
    private cdnManager: CDNManager;
    private logger: Logger;

    constructor(cdnManager: CDNManager) {
        this.cdnManager = cdnManager;
        this.logger = createLogger({ service: 'edge-cache' });
    }

    determineCacheHeaders(
        path: string,
        method: string,
        statusCode: number,
        body?: any
    ): CacheHeaders {
        const rules = {
            '/api': {
                ttl: 0,
                staleWhileRevalidate: 0,
                cacheableStatuses: [200],
            },
            '/api/users': {
                ttl: 60,
                staleWhileRevalidate: 300,
                cacheableStatuses: [200],
            },
            '/api/tasks': {
                ttl: 60,
                staleWhileRevalidate: 300,
                cacheableStatuses: [200],
            },
            '/static': {
                ttl: 86400,
                staleWhileRevalidate: 604800,
                cacheableStatuses: [200, 304],
            },
            '/health': {
                ttl: 1,
                staleWhileRevalidate: 5,
                cacheableStatuses: [200],
            },
        };

        let rule = rules['/api']; // Default
        for (const [pattern, r] of Object.entries(rules)) {
            if (path.startsWith(pattern)) {
                rule = r;
                break;
            }
        }

        // Check if response is cacheable
        const isCacheable = method === 'GET' &&
            rule.cacheableStatuses.includes(statusCode);

        if (!isCacheable) {
            return {
                'cache-control': 'no-cache, no-store, must-revalidate',
                'pragma': 'no-cache',
                'expires': '0',
            };
        }

        // Include Vary headers for dynamic content
        const vary = path.startsWith('/api') ? 'Accept-Encoding, Accept-Language' : '';

        return {
            'cache-control': [
                `max-age=${rule.ttl}`,
                `stale-while-revalidate=${rule.staleWhileRevalidate}`,
                'public',
            ].join(', '),
            'cdn-cache-control': `max-age=${rule.ttl}`,
            'vary': vary,
            'x-cache-rule': this.getRuleName(path),
        };
    }

    private getRuleName(path: string): string {
        const rules = {
            '/api/users': 'users-api',
            '/api/tasks': 'tasks-api',
            '/static': 'static-assets',
            '/health': 'health-check',
        };

        for (const [pattern, name] of Object.entries(rules)) {
            if (path.startsWith(pattern)) {
                return name;
            }
        }
        return 'default';
    }

    async invalidateOnUpdate(
        entityType: string,
        entityId: string
    ): Promise<void> {
        const patterns = [
            `/${entityType}/*`,
            `/${entityType}s/*`,
            `/${entityType}/${entityId}`,
        ];

        await this.cdnManager.invalidateCache(patterns);
        this.logger.info({
            entityType,
            entityId,
            patterns,
        }, 'Cache invalidated on update');
    }
}

interface CacheHeaders {
    'cache-control': string;
    'cdn-cache-control': string;
    'vary'?: string;
    'x-cache-rule'?: string;
    'pragma'?: string;
    'expires'?: string;
}
```

### 6. Cache Metrics & Monitoring

```typescript
class CacheMetrics {
    private metrics: {
        hits: number;
        misses: number;
        invalidations: number;
        hitRate: number[];
        latency: number[];
        errors: number;
    };

    constructor() {
        this.metrics = {
            hits: 0,
            misses: 0,
            invalidations: 0,
            hitRate: [],
            latency: [],
            errors: 0,
        };
    }

    recordHit(latency: number): void {
        this.metrics.hits++;
        this.metrics.latency.push(latency);
        this.updateHitRate();
    }

    recordMiss(latency: number): void {
        this.metrics.misses++;
        this.metrics.latency.push(latency);
        this.updateHitRate();
    }

    recordInvalidation(): void {
        this.metrics.invalidations++;
    }

    recordError(): void {
        this.metrics.errors++;
    }

    private updateHitRate(): void {
        const total = this.metrics.hits + this.metrics.misses;
        const rate = total > 0 ? (this.metrics.hits / total) * 100 : 0;
        this.metrics.hitRate.push(rate);
        
        // Keep only last 1000 values
        if (this.metrics.hitRate.length > 1000) {
            this.metrics.hitRate.shift();
        }
    }

    getMetrics(): {
        hits: number;
        misses: number;
        hitRate: number;
        avgLatency: number;
        p95Latency: number;
        invalidations: number;
        errors: number;
    } {
        const { hits, misses, hitRate, latency, invalidations, errors } = this.metrics;
        const total = hits + misses;
        const sortedLatency = [...latency].sort((a, b) => a - b);

        return {
            hits,
            misses,
            hitRate: total > 0 ? (hits / total) * 100 : 0,
            avgLatency: latency.reduce((a, b) => a + b, 0) / (latency.length || 1),
            p95Latency: sortedLatency[Math.floor(sortedLatency.length * 0.95)] || 0,
            invalidations,
            errors,
        };
    }

    reset(): void {
        this.metrics = {
            hits: 0,
            misses: 0,
            invalidations: 0,
            hitRate: [],
            latency: [],
            errors: 0,
        };
    }
}
```

### 7. Key Takeaways

1. **Cache-Aside Pattern:**
   - Most common caching strategy
   - Application manages cache
   - Simple to implement
   - Good for read-heavy workloads

2. **Write-Through Pattern:**
   - Consistent cache and database
   - More write latency
   - Good for write-heavy workloads

3. **Write-Behind Pattern:**
   - Low write latency
   - Risk of data loss
   - Good for high-write workloads

4. **Multi-Level Cache:**
   - L1: In-memory (fastest)
   - L2: Redis (shared)
   - L3: Database (source of truth)

5. **Cache Invalidation Strategies:**
   - TTL-based (time-based)
   - Event-based (event-driven)
   - Version-based (semantic)
   - Manual (explicit)

6. **CDN Integration:**
   - Edge caching for global distribution
   - Cache rules by path/type
   - Automatic invalidation
   - Performance improvement

7. **Monitor Everything:**
   - Hit/miss ratio
   - Latency
   - Invalidation rate
   - Error rate

---

This primer provides a comprehensive understanding of caching strategies and CDN integration. Proper caching is essential for building high-performance, scalable applications that provide excellent user experience.
