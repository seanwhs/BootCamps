# Primer 9: Understanding Performance Optimization

## A Deep Dive into Making Systems Fast and Efficient

Welcome to the ninth primer! This is a comprehensive deep dive into performance optimization - the art and science of making your system run faster, use fewer resources, and scale better. Think of this like optimizing a race car: every component needs to work efficiently, and small improvements in many places add up to significant gains.

### 1. The Big Picture

#### Performance Optimization Hierarchy

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PERFORMANCE OPTIMIZATION HIERARCHY                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. Architecture                                                    Impact  │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │ • Choose right patterns • Scale appropriately               │ 80%  │
│     │ • Database design • Caching strategy                         │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  2. Code Efficiency                                                       │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │ • Algorithm optimization • Data structures                   │ 15%  │
│     │ • Memory management • Async patterns                         │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  3. Infrastructure                                                         │
│     ┌────────────────────────────────────────────────────────────────┐     │
│     │ • Hardware selection • Network optimization                  │ 5%   │
│     │ • Load balancing • CDN usage                                 │     │
│     └────────────────────────────────────────────────────────────────┘     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Performance Metrics

#### Key Metrics to Monitor

```typescript
class PerformanceMetrics {
    private metrics: {
        requests: number;
        errors: number;
        latency: number[];
        memoryUsage: number[];
        cpuUsage: number[];
        dbConnections: number[];
        cacheHitRate: number[];
    } = {
        requests: 0,
        errors: 0,
        latency: [],
        memoryUsage: [],
        cpuUsage: [],
        dbConnections: [],
        cacheHitRate: [],
    };

    recordRequest(startTime: number, error?: Error): void {
        const latency = Date.now() - startTime;
        this.metrics.requests++;
        this.metrics.latency.push(latency);
        
        if (error) {
            this.metrics.errors++;
        }

        // Keep only last 1000 values
        if (this.metrics.latency.length > 1000) {
            this.metrics.latency.shift();
        }
    }

    recordMemoryUsage(): void {
        const usage = process.memoryUsage();
        this.metrics.memoryUsage.push(usage.heapUsed);
        if (this.metrics.memoryUsage.length > 100) {
            this.metrics.memoryUsage.shift();
        }
    }

    recordCacheHit(hit: boolean): void {
        this.metrics.cacheHitRate.push(hit ? 1 : 0);
        if (this.metrics.cacheHitRate.length > 1000) {
            this.metrics.cacheHitRate.shift();
        }
    }

    getMetrics(): PerformanceReport {
        const { latency, memoryUsage } = this.metrics;
        const sortedLatency = [...latency].sort((a, b) => a - b);
        const cacheHitRate = this.metrics.cacheHitRate.reduce((a, b) => a + b, 0) / 
                            (this.metrics.cacheHitRate.length || 1);

        return {
            throughput: this.metrics.requests / (Date.now() / 1000),
            errorRate: (this.metrics.errors / this.metrics.requests) * 100 || 0,
            latency: {
                avg: latency.reduce((a, b) => a + b, 0) / (latency.length || 1),
                p50: sortedLatency[Math.floor(sortedLatency.length * 0.5)] || 0,
                p95: sortedLatency[Math.floor(sortedLatency.length * 0.95)] || 0,
                p99: sortedLatency[Math.floor(sortedLatency.length * 0.99)] || 0,
            },
            memory: {
                heapUsed: memoryUsage[memoryUsage.length - 1] || 0,
                heapTotal: process.memoryUsage().heapTotal,
                external: process.memoryUsage().external,
            },
            cacheHitRate: cacheHitRate * 100,
            timestamp: new Date().toISOString(),
        };
    }
}
```

### 3. Code-Level Optimization

#### Algorithm Optimization

```typescript
// ❌ BAD: O(n²) algorithm
function findDuplicatesBad(items: any[]): any[] {
    const duplicates: any[] = [];
    for (let i = 0; i < items.length; i++) {
        for (let j = i + 1; j < items.length; j++) {
            if (items[i] === items[j] && !duplicates.includes(items[i])) {
                duplicates.push(items[i]);
            }
        }
    }
    return duplicates;
}

// ✅ GOOD: O(n) algorithm
function findDuplicatesGood(items: any[]): any[] {
    const seen = new Set();
    const duplicates = new Set();
    
    for (const item of items) {
        if (seen.has(item)) {
            duplicates.add(item);
        } else {
            seen.add(item);
        }
    }
    
    return Array.from(duplicates);
}

// ❌ BAD: Multiple passes
function processDataBad(data: any[]): any[] {
    // Filter
    const filtered = data.filter(item => item.active);
    // Map
    const mapped = filtered.map(item => item.value);
    // Sort
    return mapped.sort((a, b) => a - b);
}

// ✅ GOOD: Single pass
function processDataGood(data: any[]): any[] {
    const result: any[] = [];
    for (const item of data) {
        if (item.active) {
            result.push(item.value);
        }
    }
    return result.sort((a, b) => a - b);
}
```

#### Data Structure Selection

```typescript
// Map vs Object: When to use what

// ❌ BAD: Using object for dynamic keys
const userCache: Record<string, User> = {};
userCache['user-123'] = user;

// ✅ GOOD: Using Map for dynamic keys
const userCache = new Map<string, User>();
userCache.set('user-123', user);

// Set vs Array: Fast lookups

// ❌ BAD: Array for membership checks
const activeUsers: string[] = [];
function isActive(userId: string): boolean {
    return activeUsers.includes(userId); // O(n)
}

// ✅ GOOD: Set for membership checks
const activeUsers = new Set<string>();
function isActive(userId: string): boolean {
    return activeUsers.has(userId); // O(1)
}

// Queue implementation

// ❌ BAD: Array as queue (shift is O(n))
class QueueBad {
    private items: any[] = [];
    enqueue(item: any): void { this.items.push(item); }
    dequeue(): any { return this.items.shift(); } // O(n)
}

// ✅ GOOD: Linked list or circular buffer
class QueueGood {
    private head = 0;
    private tail = 0;
    private items: any[] = [];

    enqueue(item: any): void {
        this.items[this.tail++] = item;
    }

    dequeue(): any {
        if (this.head === this.tail) return undefined;
        const item = this.items[this.head];
        delete this.items[this.head++];
        return item;
    }
}
```

#### Memory Management

```typescript
// ❌ BAD: Creating unnecessary objects
function processItemsBad(items: any[]): any[] {
    const result = [];
    for (const item of items) {
        const temp = { ...item }; // Creates new object
        temp.processed = true;
        result.push(temp);
    }
    return result;
}

// ✅ GOOD: Reuse objects
function processItemsGood(items: any[]): any[] {
    const result = [];
    for (const item of items) {
        // Modify in place
        item.processed = true;
        result.push(item);
    }
    return result;
}

// ❌ BAD: Memory leak with closures
function createLeak() {
    const largeData = new Array(1000000).fill('data');
    return function() {
        // largeData stays in memory
        console.log(largeData.length);
    };
}

// ✅ GOOD: Clean up references
function createClean() {
    const largeData = new Array(1000000).fill('data');
    return function() {
        // Use and release
        const data = largeData;
        console.log(data.length);
        // Allow garbage collection
        largeData = null;
    };
}

// ❌ BAD: Accumulating data
let history: any[] = [];
function addHistory(item: any): void {
    history.push(item);
    // Never cleans up
}

// ✅ GOOD: Use bounded array or LRU cache
class BoundedHistory {
    private items: any[] = [];
    constructor(private maxSize: number) {}

    add(item: any): void {
        this.items.push(item);
        if (this.items.length > this.maxSize) {
            this.items.shift();
        }
    }

    getItems(): any[] {
        return this.items;
    }
}
```

### 4. Database Optimization

#### Query Optimization

```typescript
// ❌ BAD: N+1 query problem
async function getUsersWithTasksBad(userIds: string[]): Promise<UserWithTasks[]> {
    const users = await db.users.findMany({ where: { id: { in: userIds } } });
    const result = [];
    
    for (const user of users) {
        // N+1 queries!
        const tasks = await db.tasks.findMany({ where: { userId: user.id } });
        result.push({ ...user, tasks });
    }
    
    return result;
}

// ✅ GOOD: Single query with JOIN
async function getUsersWithTasksGood(userIds: string[]): Promise<UserWithTasks[]> {
    return await db.users.findMany({
        where: { id: { in: userIds } },
        include: {
            tasks: true, // Single query with JOIN
        },
    });
}

// ✅ BETTER: Denormalized read model
async function getUsersWithTasksBest(userIds: string[]): Promise<UserWithTasks[]> {
    // Use pre-joined read model
    return await db.userReadModel.findMany({
        where: { id: { in: userIds } },
    });
}
```

#### Indexing Strategy

```sql
-- ❌ BAD: No indexes
SELECT * FROM tasks WHERE user_id = 1 AND status = 'pending';

-- ✅ GOOD: Composite index
CREATE INDEX idx_tasks_user_status ON tasks(user_id, status);

-- ❌ BAD: Query with function on indexed column
SELECT * FROM users WHERE LOWER(email) = 'test@example.com';

-- ✅ GOOD: Use expression index
CREATE INDEX idx_users_email_lower ON users(LOWER(email));

-- ❌ BAD: Full table scan for partial match
SELECT * FROM tasks WHERE title LIKE '%search%';

-- ✅ GOOD: Use full-text search or trigram index
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_tasks_title_trgm ON tasks USING GIN (title gin_trgm_ops);
```

#### Connection Pooling

```typescript
// ❌ BAD: Creating new connection for each request
class BadDatabase {
    async query(sql: string, params: any[]): Promise<any> {
        const client = new Client({ /* config */ });
        await client.connect();
        try {
            return await client.query(sql, params);
        } finally {
            await client.end(); // Expensive!
        }
    }
}

// ✅ GOOD: Using connection pool
class GoodDatabase {
    private pool: Pool;

    constructor() {
        this.pool = new Pool({
            max: 20,
            min: 5,
            idleTimeoutMillis: 30000,
            connectionTimeoutMillis: 2000,
        });
    }

    async query(sql: string, params: any[]): Promise<any> {
        const client = await this.pool.connect();
        try {
            return await client.query(sql, params);
        } finally {
            client.release();
        }
    }
}

// ✅ GOOD: Transaction with connection reuse
async function transaction<T>(
    operation: (client: PoolClient) => Promise<T>
): Promise<T> {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        const result = await operation(client);
        await client.query('COMMIT');
        return result;
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
}
```

### 5. Caching Strategies

#### Multi-Level Cache

```typescript
class MultiLevelCache {
    private l1Cache = new Map<string, { value: any; expires: number }>();
    private l2Cache: Redis;
    private stats = { l1Hit: 0, l1Miss: 0, l2Hit: 0, l2Miss: 0 };

    constructor(private l1TTL: number = 10000, private l2TTL: number = 300000) {
        this.l2Cache = new Redis({ /* config */ });
    }

    async get<T>(key: string): Promise<T | null> {
        // Check L1 (memory) cache
        const l1 = this.l1Cache.get(key);
        if (l1 && l1.expires > Date.now()) {
            this.stats.l1Hit++;
            return l1.value;
        }
        this.stats.l1Miss++;

        // Check L2 (Redis) cache
        const l2 = await this.l2Cache.get(key);
        if (l2) {
            this.stats.l2Hit++;
            // Promote to L1
            this.l1Cache.set(key, {
                value: JSON.parse(l2),
                expires: Date.now() + this.l1TTL,
            });
            return JSON.parse(l2);
        }
        this.stats.l2Miss++;

        return null;
    }

    async set<T>(key: string, value: T): Promise<void> {
        // Set in both caches
        this.l1Cache.set(key, {
            value,
            expires: Date.now() + this.l1TTL,
        });
        await this.l2Cache.set(key, JSON.stringify(value), 'PX', this.l2TTL);
    }

    getStats(): { hitRate: number; l1HitRate: number; l2HitRate: number } {
        const total = this.stats.l1Hit + this.stats.l1Miss + this.stats.l2Hit + this.stats.l2Miss;
        const l1Total = this.stats.l1Hit + this.stats.l1Miss;
        const l2Total = this.stats.l2Hit + this.stats.l2Miss;

        return {
            hitRate: (this.stats.l1Hit + this.stats.l2Hit) / total || 0,
            l1HitRate: this.stats.l1Hit / l1Total || 0,
            l2HitRate: this.stats.l2Hit / l2Total || 0,
        };
    }
}
```

#### Cache-Aside Pattern

```typescript
class CacheAsidePattern {
    constructor(
        private cache: MultiLevelCache,
        private db: Database
    ) {}

    async getUser(id: string): Promise<User | null> {
        const cacheKey = `user:${id}`;

        // Try cache first
        const cached = await this.cache.get<User>(cacheKey);
        if (cached) {
            return cached;
        }

        // Cache miss - fetch from database
        const user = await this.db.getUser(id);
        if (user) {
            // Store in cache
            await this.cache.set(cacheKey, user);
        }

        return user;
    }

    async updateUser(id: string, data: UserData): Promise<User> {
        const user = await this.db.updateUser(id, data);
        
        // Invalidate cache
        await this.cache.delete(`user:${id}`);
        // Optionally: write-through
        await this.cache.set(`user:${id}`, user);
        
        return user;
    }
}
```

### 6. Async Optimization

#### Parallel Processing

```typescript
// ❌ BAD: Sequential processing
async function processUsersSequential(userIds: string[]): Promise<any[]> {
    const results = [];
    for (const id of userIds) {
        const user = await getUser(id); // Sequential
        const tasks = await getTasks(id); // Sequential
        results.push({ user, tasks });
    }
    return results;
}

// ✅ GOOD: Parallel processing with limits
async function processUsersParallel(
    userIds: string[],
    concurrency: number = 10
): Promise<any[]> {
    const results = [];
    const chunks = chunkArray(userIds, concurrency);
    
    for (const chunk of chunks) {
        const batch = chunk.map(async (id) => {
            const [user, tasks] = await Promise.all([
                getUser(id),
                getTasks(id),
            ]);
            return { user, tasks };
        });
        const batchResults = await Promise.all(batch);
        results.push(...batchResults);
    }
    
    return results;
}

function chunkArray<T>(array: T[], size: number): T[][] {
    const chunks: T[][] = [];
    for (let i = 0; i < array.length; i += size) {
        chunks.push(array.slice(i, i + size));
    }
    return chunks;
}
```

#### Batch Processing

```typescript
// ❌ BAD: Individual operations
async function processItems(items: any[]): Promise<void> {
    for (const item of items) {
        await processItem(item); // One at a time
    }
}

// ✅ GOOD: Batch operations
class BatchProcessor {
    private batchSize: number;
    private buffer: any[] = [];
    private timer: NodeJS.Timeout | null = null;
    private processFn: (batch: any[]) => Promise<void>;

    constructor(processFn: (batch: any[]) => Promise<void>, batchSize: number = 100) {
        this.processFn = processFn;
        this.batchSize = batchSize;
    }

    add(item: any): void {
        this.buffer.push(item);
        
        if (this.buffer.length >= this.batchSize) {
            this.flush();
        } else if (!this.timer) {
            this.timer = setTimeout(() => this.flush(), 1000);
        }
    }

    async flush(): Promise<void> {
        if (this.timer) {
            clearTimeout(this.timer);
            this.timer = null;
        }

        if (this.buffer.length === 0) return;

        const batch = this.buffer;
        this.buffer = [];
        
        try {
            await this.processFn(batch);
        } catch (error) {
            // Handle batch failure
            console.error('Batch processing failed:', error);
            // Could implement retry logic here
        }
    }
}

// Usage
const processor = new BatchProcessor(async (batch) => {
    await db.tasks.insertMany(batch);
});
```

### 7. Load Testing & Performance Analysis

#### Load Testing Script

```typescript
class LoadTester {
    private config: {
        concurrentUsers: number;
        rampUpTime: number;
        duration: number;
        targetEndpoint: string;
    };

    constructor(config: Partial<LoadTester['config']>) {
        this.config = {
            concurrentUsers: 10,
            rampUpTime: 10000, // 10 seconds
            duration: 60000, // 1 minute
            targetEndpoint: 'http://localhost:3000/health',
            ...config,
        };
    }

    async run(): Promise<LoadTestResult> {
        const results: LoadTestResult = {
            requests: 0,
            errors: 0,
            latencies: [],
            statusCodes: new Map(),
            startTime: Date.now(),
        };

        const users = Array.from(
            { length: this.config.concurrentUsers },
            (_, i) => this.createUser(results, i)
        );

        // Ramp up users gradually
        const usersPerSecond = this.config.concurrentUsers / (this.config.rampUpTime / 1000);
        let activeUsers = 0;

        while (activeUsers < users.length) {
            const start = Math.min(users.length, activeUsers + usersPerSecond);
            for (let i = activeUsers; i < start; i++) {
                users[i](); // Start user
            }
            activeUsers = start;
            await this.sleep(1000);
        }

        // Wait for duration
        await this.sleep(this.config.duration);

        // Collect results
        return results;
    }

    private createUser(results: LoadTestResult, userId: number): () => Promise<void> {
        return async () => {
            const client = new HttpClient({ keepAlive: true });
            
            while (Date.now() - results.startTime < this.config.duration + this.config.rampUpTime) {
                try {
                    const startTime = Date.now();
                    const response = await client.get(this.config.targetEndpoint);
                    const latency = Date.now() - startTime;
                    
                    results.requests++;
                    results.latencies.push(latency);
                    
                    const status = response.statusCode || 0;
                    results.statusCodes.set(status, (results.statusCodes.get(status) || 0) + 1);
                    
                    if (status >= 400) {
                        results.errors++;
                    }
                    
                    // Simulate think time
                    await this.sleep(Math.random() * 100);
                } catch (error) {
                    results.errors++;
                }
            }
        };
    }

    private sleep(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

interface LoadTestResult {
    requests: number;
    errors: number;
    latencies: number[];
    statusCodes: Map<number, number>;
    startTime: number;
}
```

#### Performance Profiling

```typescript
class PerformanceProfiler {
    private profiles: Map<string, ProfileData> = new Map();

    start(label: string): void {
        this.profiles.set(label, {
            startTime: process.hrtime.bigint(),
            endTime: 0n,
            startMemory: process.memoryUsage().heapUsed,
            endMemory: 0,
            operations: 0,
            errors: 0,
        });
    }

    end(label: string): ProfileResult {
        const profile = this.profiles.get(label);
        if (!profile) {
            throw new Error(`Profile ${label} not found`);
        }

        profile.endTime = process.hrtime.bigint();
        profile.endMemory = process.memoryUsage().heapUsed;

        const duration = Number(profile.endTime - profile.startTime) / 1_000_000;
        const memoryDelta = profile.endMemory - profile.startMemory;

        const result = {
            label,
            duration: duration,
            memoryDelta: memoryDelta,
            operations: profile.operations,
            errors: profile.errors,
            opsPerSecond: (profile.operations / duration) * 1000,
            memoryPerOp: memoryDelta / (profile.operations || 1),
        };

        console.log(`Profile: ${label}`);
        console.log(`  Duration: ${duration.toFixed(2)}ms`);
        console.log(`  Memory: ${(memoryDelta / 1024 / 1024).toFixed(2)}MB`);
        console.log(`  Ops/s: ${result.opsPerSecond.toFixed(2)}`);
        console.log(`  Memory/op: ${(result.memoryPerOp / 1024).toFixed(2)}KB`);

        return result;
    }

    recordOperation(label: string): void {
        const profile = this.profiles.get(label);
        if (profile) {
            profile.operations++;
        }
    }

    recordError(label: string): void {
        const profile = this.profiles.get(label);
        if (profile) {
            profile.errors++;
        }
    }
}

interface ProfileData {
    startTime: bigint;
    endTime: bigint;
    startMemory: number;
    endMemory: number;
    operations: number;
    errors: number;
}

interface ProfileResult {
    label: string;
    duration: number;
    memoryDelta: number;
    operations: number;
    errors: number;
    opsPerSecond: number;
    memoryPerOp: number;
}
```

### 8. Key Takeaways

1. **Measure Before Optimizing:**
   - Profile to find bottlenecks
   - Use metrics to track improvements
   - Focus on the biggest wins first

2. **Choose the Right Data Structures:**
   - Map for key-value lookups
   - Set for membership checks
   - Array for ordered collections

3. **Optimize Database Access:**
   - Use indexes effectively
   - Avoid N+1 queries
   - Use connection pooling
   - Consider read replicas

4. **Implement Caching Strategically:**
   - Multi-level caching (memory + Redis)
   - Cache-aside pattern
   - Invalidate on changes
   - Monitor hit rates

5. **Parallelize When Possible:**
   - Use Promise.all for independent operations
   - Batch processing for efficiency
   - Control concurrency to avoid overload

6. **Monitor and Alert:**
   - Track response times
   - Monitor error rates
   - Set up performance alerts
   - Review metrics regularly

---

This primer provides a comprehensive understanding of performance optimization. A well-optimized system provides better user experience, lower costs, and more efficient resource utilization.
