# Appendix J: Performance Optimization Reference

## Overview

This appendix provides a comprehensive reference for optimizing the performance of your MCP servers, A2A agents, and multi-agent systems. It covers everything from database optimization to caching strategies, load testing, and monitoring.

---

## Part 1: Database Optimization

### 1.1 Query Optimization

**Overview:** Optimize database queries for faster execution.

**SQLite Query Optimization:**

```sql
-- Use EXPLAIN QUERY PLAN to analyze queries
EXPLAIN QUERY PLAN
SELECT * FROM users WHERE email = 'alice@example.com';

-- Add indexes for frequently queried columns
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_age ON users(age);

-- Use covering indexes to avoid table lookups
CREATE INDEX idx_users_email_age ON users(email, age);

-- Use LIMIT for large result sets
SELECT * FROM users LIMIT 100;

-- Use specific columns instead of *
SELECT id, name, email FROM users WHERE age > 25;

-- Use EXISTS instead of IN for better performance
SELECT * FROM users u 
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.user_id = u.id);

-- Use UNION ALL instead of UNION when possible (faster)
SELECT id, name FROM active_users
UNION ALL
SELECT id, name FROM pending_users;
```

**PostgreSQL Query Optimization:**

```sql
-- Analyze query plan
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'alice@example.com';

-- Use appropriate indexes
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
CREATE INDEX CONCURRENTLY idx_users_age ON users(age);

-- Use partial indexes for specific queries
CREATE INDEX idx_active_users ON users(id) WHERE active = true;

-- Use expression indexes for computed columns
CREATE INDEX idx_users_email_lower ON users(LOWER(email));

-- Use covering indexes
CREATE INDEX idx_users_email_cover ON users(email) INCLUDE (name, age);

-- Use materialized views for complex aggregations
CREATE MATERIALIZED VIEW monthly_orders_summary AS
SELECT 
  DATE_TRUNC('month', order_date) as month,
  COUNT(*) as order_count,
  SUM(total) as total_revenue
FROM orders
GROUP BY DATE_TRUNC('month', order_date)
WITH DATA;

REFRESH MATERIALIZED VIEW monthly_orders_summary;
```

### 1.2 Connection Pooling

**SQLite Connection Pooling:**

```typescript
// Connection pool for SQLite
export class SQLiteConnectionPool {
  private pool: sqlite3.Database[];
  private maxSize: number = 10;
  private currentSize: number = 0;
  private waiting: Array<{
    resolve: (db: sqlite3.Database) => void;
    reject: (error: Error) => void;
  }> = [];

  async getConnection(): Promise<sqlite3.Database> {
    // Check if there's an available connection
    const available = this.pool.find(db => !this.isInUse(db));
    if (available) {
      this.markInUse(available);
      return available;
    }

    // Create new connection if pool not full
    if (this.currentSize < this.maxSize) {
      const db = await this.createConnection();
      this.pool.push(db);
      this.currentSize++;
      this.markInUse(db);
      return db;
    }

    // Wait for available connection
    return new Promise((resolve, reject) => {
      this.waiting.push({ resolve, reject });
    });
  }

  releaseConnection(db: sqlite3.Database): void {
    this.markAvailable(db);
    
    // Resolve any waiting requests
    if (this.waiting.length > 0) {
      const { resolve } = this.waiting.shift()!;
      resolve(db);
    }
  }
}
```

**PostgreSQL Connection Pooling (using pg-pool):**

```typescript
import { Pool, PoolConfig } from 'pg';

// Optimized pool configuration
const poolConfig: PoolConfig = {
  host: process.env.POSTGRES_HOST,
  port: parseInt(process.env.POSTGRES_PORT || '5432'),
  user: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  database: process.env.POSTGRES_DATABASE,
  max: 20, // Maximum connections in pool
  idleTimeoutMillis: 30000, // Close idle connections after 30 seconds
  connectionTimeoutMillis: 2000, // Timeout for getting connection
  maxUses: 7500, // Connection reuse limit
  keepAlive: true, // Keep connections alive
  ssl: process.env.POSTGRES_SSL === 'true' ? { rejectUnauthorized: false } : false
};

const pool = new Pool(poolConfig);

// Connection pool events for monitoring
pool.on('connect', () => {
  console.log('New connection established');
});

pool.on('acquire', () => {
  console.log('Connection acquired from pool');
});

pool.on('remove', () => {
  console.log('Connection removed from pool');
});

// Get connection with timeout
async function getConnectionWithTimeout(timeoutMs: number = 5000): Promise<any> {
  const timeout = new Promise((_, reject) => {
    setTimeout(() => reject(new Error('Connection timeout')), timeoutMs);
  });
  
  return Promise.race([pool.connect(), timeout]);
}
```

### 1.3 Query Caching

**Redis Caching Implementation:**

```typescript
import Redis from 'ioredis';

export class QueryCache {
  private redis: Redis;
  private defaultTTL: number = 300; // 5 minutes

  constructor(redisUrl: string) {
    this.redis = new Redis(redisUrl);
  }

  /**
   * Get cached query result
   */
  async get<T>(key: string): Promise<T | null> {
    const cached = await this.redis.get(`query:${key}`);
    if (cached) {
      return JSON.parse(cached);
    }
    return null;
  }

  /**
   * Cache query result
   */
  async set(key: string, value: any, ttl: number = this.defaultTTL): Promise<void> {
    await this.redis.set(
      `query:${key}`,
      JSON.stringify(value),
      'EX',
      ttl
    );
  }

  /**
   * Cache-aware query execution
   */
  async executeWithCache<T>(
    key: string,
    query: () => Promise<T>,
    ttl?: number
  ): Promise<T> {
    // Check cache
    const cached = await this.get<T>(key);
    if (cached !== null) {
      return cached;
    }

    // Execute query
    const result = await query();

    // Cache result
    await this.set(key, result, ttl);

    return result;
  }

  /**
   * Invalidate cache by pattern
   */
  async invalidate(pattern: string): Promise<void> {
    const keys = await this.redis.keys(`query:${pattern}`);
    if (keys.length > 0) {
      await this.redis.del(...keys);
    }
  }

  /**
   * Clear all cache
   */
  async clear(): Promise<void> {
    await this.redis.del('query:*');
  }
}

// Usage
const cache = new QueryCache(process.env.REDIS_URL || 'redis://localhost:6379');

// Cache user query
const users = await cache.executeWithCache(
  'users:all',
  async () => {
    return await pool.query('SELECT * FROM users');
  },
  600 // 10 minutes TTL
);
```

---

## Part 2: MCP Server Optimization

### 2.1 Tool Execution Optimization

**Optimized Tool Execution:**

```typescript
import { z } from 'zod';

// Tool with batching
export function createBatchingTool(
  name: string,
  schema: z.ZodSchema,
  batchHandler: (items: any[]) => Promise<any[]>
) {
  const queue: any[] = [];
  let processing = false;
  let batchTimeout: NodeJS.Timeout | null = null;

  return {
    name,
    schema,
    handler: async (args: any) => {
      // Add to queue
      return new Promise((resolve, reject) => {
        queue.push({ args, resolve, reject });
        
        // Process immediately if batch is large enough
        if (queue.length >= 10) {
          processQueue();
        } else if (!batchTimeout) {
          // Otherwise wait for batch window
          batchTimeout = setTimeout(() => {
            processQueue();
          }, 100);
        }
      });
    }
  };

  function processQueue(): void {
    if (processing || queue.length === 0) return;
    
    processing = true;
    batchTimeout = null;
    
    const batch = queue.splice(0, Math.min(queue.length, 10));
    const items = batch.map(item => item.args);
    
    batchHandler(items)
      .then(results => {
        for (let i = 0; i < batch.length; i++) {
          batch[i].resolve(results[i]);
        }
      })
      .catch(error => {
        for (const item of batch) {
          item.reject(error);
        }
      })
      .finally(() => {
        processing = false;
        if (queue.length > 0) {
          processQueue();
        }
      });
  }
}
```

### 2.2 Resource Caching

**Resource Caching Implementation:**

```typescript
import NodeCache from 'node-cache';

export class ResourceCache {
  private cache: NodeCache;
  
  constructor(ttlSeconds: number = 300, maxKeys: number = 100) {
    this.cache = new NodeCache({
      stdTTL: ttlSeconds,
      maxKeys: maxKeys,
      checkperiod: 60
    });
  }

  /**
   * Get cached resource
   */
  get(uri: string): any | null {
    return this.cache.get(`resource:${uri}`) || null;
  }

  /**
   * Cache resource
   */
  set(uri: string, data: any, ttl?: number): void {
    this.cache.set(`resource:${uri}`, data, ttl);
  }

  /**
   * Check if resource is cached
   */
  has(uri: string): boolean {
    return this.cache.has(`resource:${uri}`);
  }

  /**
   * Invalidate resource
   */
  invalidate(uri: string): void {
    this.cache.del(`resource:${uri}`);
  }

  /**
   * Get cache statistics
   */
  getStats(): any {
    return this.cache.getStats();
  }
}

// Usage in MCP resource handler
const resourceCache = new ResourceCache(600, 1000);

server.resource(
  'cached_data',
  'cached://*',
  {
    description: 'Cached data resource',
    mimeType: 'application/json'
  },
  async (uri: string) => {
    // Check cache
    const cached = resourceCache.get(uri);
    if (cached) {
      return {
        contents: [
          {
            uri,
            text: JSON.stringify(cached),
            mimeType: 'application/json'
          }
        ]
      };
    }

    // Fetch fresh data
    const data = await fetchData(uri);
    
    // Cache data
    resourceCache.set(uri, data);
    
    return {
      contents: [
        {
          uri,
          text: JSON.stringify(data),
          mimeType: 'application/json'
        }
      ]
    };
  }
);
```

### 2.3 Worker Threads for CPU-Intensive Operations

**Using Worker Threads:**

```typescript
import { Worker } from 'worker_threads';
import path from 'path';

export class WorkerPool {
  private workers: Worker[] = [];
  private queue: Array<{
    task: any;
    resolve: (value: any) => void;
    reject: (error: Error) => void;
  }> = [];
  private maxWorkers: number;

  constructor(maxWorkers: number = 4) {
    this.maxWorkers = maxWorkers;
  }

  /**
   * Execute a task using a worker
   */
  async execute(task: any): Promise<any> {
    return new Promise((resolve, reject) => {
      const worker = this.getAvailableWorker();
      
      if (worker) {
        this.runTask(worker, task, resolve, reject);
      } else {
        this.queue.push({ task, resolve, reject });
        if (this.workers.length < this.maxWorkers) {
          this.createWorker();
        }
      }
    });
  }

  /**
   * Get an available worker
   */
  private getAvailableWorker(): Worker | null {
    for (const worker of this.workers) {
      if (!worker['busy']) {
        return worker;
      }
    }
    return null;
  }

  /**
   * Create a new worker
   */
  private createWorker(): void {
    const worker = new Worker(path.join(__dirname, 'worker.js'));
    worker['busy'] = false;
    
    worker.on('message', (result) => {
      worker['busy'] = false;
      // Process next queued task
      if (this.queue.length > 0) {
        const next = this.queue.shift()!;
        this.runTask(worker, next.task, next.resolve, next.reject);
      }
    });
    
    worker.on('error', (error) => {
      // Remove failed worker
      const index = this.workers.indexOf(worker);
      if (index !== -1) {
        this.workers.splice(index, 1);
      }
    });
    
    this.workers.push(worker);
  }

  /**
   * Run task on worker
   */
  private runTask(worker: Worker, task: any, resolve: any, reject: any): void {
    worker['busy'] = true;
    worker.postMessage(task);
    
    // Handle response in existing listeners
    const messageHandler = (result: any) => {
      resolve(result);
      worker.removeListener('message', messageHandler);
    };
    
    const errorHandler = (error: Error) => {
      reject(error);
      worker.removeListener('error', errorHandler);
    };
    
    worker.once('message', messageHandler);
    worker.once('error', errorHandler);
  }

  /**
   * Shut down all workers
   */
  async shutdown(): Promise<void> {
    await Promise.all(this.workers.map(worker => worker.terminate()));
    this.workers = [];
    this.queue = [];
  }
}

// worker.js
import { parentPort } from 'worker_threads';

parentPort?.on('message', async (task) => {
  try {
    // Process task (CPU-intensive)
    const result = await processTask(task);
    parentPort?.postMessage(result);
  } catch (error) {
    parentPort?.postMessage({ error: error.message });
  }
});
```

---

## Part 3: A2A Performance Optimization

### 3.1 Message Batch Processing

**Message Batching Implementation:**

```typescript
export class MessageBatcher {
  private batches: Map<string, A2AMessage[]> = new Map();
  private batchWindow: number = 100; // milliseconds
  private maxBatchSize: number = 50;
  private timer: NodeJS.Timeout | null = null;
  private router: MessageRouter;

  constructor(router: MessageRouter, config?: { batchWindow?: number; maxBatchSize?: number }) {
    this.router = router;
    this.batchWindow = config?.batchWindow || 100;
    this.maxBatchSize = config?.maxBatchSize || 50;
  }

  /**
   * Add message to batch
   */
  add(message: A2AMessage): void {
    const key = this.getBatchKey(message);
    
    if (!this.batches.has(key)) {
      this.batches.set(key, []);
    }
    
    const batch = this.batches.get(key)!;
    batch.push(message);
    
    // Process immediately if batch is full
    if (batch.length >= this.maxBatchSize) {
      this.flushBatch(key);
      return;
    }
    
    // Schedule flush
    if (!this.timer) {
      this.timer = setTimeout(() => {
        this.flushAll();
      }, this.batchWindow);
    }
  }

  /**
   * Get batch key for grouping
   */
  private getBatchKey(message: A2AMessage): string {
    // Group by recipient and priority
    const recipient = typeof message.to === 'string' ? message.to : message.to.join(',');
    return `${recipient}:${message.priority}`;
  }

  /**
   * Flush a specific batch
   */
  private flushBatch(key: string): void {
    const messages = this.batches.get(key);
    if (!messages || messages.length === 0) return;
    
    this.batches.delete(key);
    
    // Process batch
    this.processBatch(messages);
  }

  /**
   * Flush all batches
   */
  private flushAll(): void {
    if (this.timer) {
      clearTimeout(this.timer);
      this.timer = null;
    }
    
    const keys = Array.from(this.batches.keys());
    for (const key of keys) {
      this.flushBatch(key);
    }
  }

  /**
   * Process a batch of messages
   */
  private processBatch(messages: A2AMessage[]): void {
    // Create batch message
    const batchMessage: A2AMessage = {
      id: `batch-${Date.now()}`,
      type: 'notification',
      from: messages[0].from,
      to: messages[0].to,
      subject: 'Batch of messages',
      body: { messages },
      priority: messages[0].priority,
      createdAt: new Date(),
      requiresResponse: false
    };
    
    // Send batch
    this.router.send(batchMessage).catch(error => {
      console.error('Failed to send batch:', error);
    });
  }

  /**
   * Get batch statistics
   */
  getStats(): {
    batchCount: number;
    messageCount: number;
  } {
    let messageCount = 0;
    for (const messages of this.batches.values()) {
      messageCount += messages.length;
    }
    
    return {
      batchCount: this.batches.size,
      messageCount
    };
  }
}
```

### 3.2 Agent Load Balancing

**Agent Load Balancing Implementation:**

```typescript
export class AgentLoadBalancer {
  private agents: Map<string, {
    agent: AgentIdentity;
    load: number; // Current load (0-100)
    capacity: number; // Maximum capacity
    tasks: string[]; // Pending task IDs
  }> = new Map();

  /**
   * Register an agent for load balancing
   */
  register(agent: AgentIdentity, capacity: number = 10): void {
    this.agents.set(agent.id, {
      agent,
      load: 0,
      capacity,
      tasks: []
    });
  }

  /**
   * Get the best agent for a task
   */
  getBestAgent(requiredRole?: AgentRole): AgentIdentity | null {
    let bestAgent: typeof this.agents extends Map<any, infer V> ? V : never = null;
    let bestScore = Infinity;

    for (const [id, entry] of this.agents) {
      // Check role if specified
      if (requiredRole && entry.agent.role !== requiredRole) {
        continue;
      }

      // Check if agent has capacity
      if (entry.load >= entry.capacity) {
        continue;
      }

      // Calculate score (lower is better)
      const score = entry.load / entry.capacity;
      
      if (score < bestScore) {
        bestScore = score;
        bestAgent = entry;
      }
    }

    return bestAgent?.agent || null;
  }

  /**
   * Assign a task to an agent
   */
  assignTask(agentId: string, taskId: string): void {
    const entry = this.agents.get(agentId);
    if (!entry) {
      throw new Error(`Agent ${agentId} not found`);
    }
    
    entry.load++;
    entry.tasks.push(taskId);
  }

  /**
   * Complete a task on an agent
   */
  completeTask(agentId: string, taskId: string): void {
    const entry = this.agents.get(agentId);
    if (!entry) {
      return;
    }
    
    entry.load = Math.max(0, entry.load - 1);
    const index = entry.tasks.indexOf(taskId);
    if (index !== -1) {
      entry.tasks.splice(index, 1);
    }
  }

  /**
   * Get agent statistics
   */
  getStats(): Array<{
    id: string;
    name: string;
    load: number;
    capacity: number;
    utilization: number;
    pendingTasks: number;
  }> {
    const stats: any[] = [];
    
    for (const entry of this.agents.values()) {
      stats.push({
        id: entry.agent.id,
        name: entry.agent.name,
        load: entry.load,
        capacity: entry.capacity,
        utilization: (entry.load / entry.capacity) * 100,
        pendingTasks: entry.tasks.length
      });
    }
    
    return stats;
  }

  /**
   * Get the least loaded agent
   */
  getLeastLoadedAgent(): AgentIdentity | null {
    let minLoad = Infinity;
    let bestAgent: AgentIdentity | null = null;
    
    for (const entry of this.agents.values()) {
      if (entry.load < minLoad) {
        minLoad = entry.load;
        bestAgent = entry.agent;
      }
    }
    
    return bestAgent;
  }
}

// Usage
const loadBalancer = new AgentLoadBalancer();

// Register agents
loadBalancer.register(researchAgent1, 10);
loadBalancer.register(researchAgent2, 10);
loadBalancer.register(codingAgent, 5);

// Get best agent for task
const bestAgent = loadBalancer.getBestAgent('researcher');
if (bestAgent) {
  loadBalancer.assignTask(bestAgent.id, taskId);
  // Delegate task to bestAgent
}
```

---

## Part 4: Monitoring and Metrics

### 4.1 Prometheus Metrics

**Metrics Implementation:**

```typescript
import prometheus from 'prom-client';

// Create a Registry
const register = new prometheus.Registry();

// Enable default metrics
prometheus.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestsTotal = new prometheus.Counter({
  name: 'mcp_http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'path', 'status'],
  registers: [register]
});

const httpRequestDuration = new prometheus.Histogram({
  name: 'mcp_http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'path'],
  buckets: [0.1, 0.5, 1, 2, 5, 10],
  registers: [register]
});

const toolCallsTotal = new prometheus.Counter({
  name: 'mcp_tool_calls_total',
  help: 'Total number of tool calls',
  labelNames: ['tool', 'success'],
  registers: [register]
});

const toolCallDuration = new prometheus.Histogram({
  name: 'mcp_tool_call_duration_seconds',
  help: 'Tool call duration in seconds',
  labelNames: ['tool'],
  buckets: [0.1, 0.5, 1, 2, 5, 10, 30],
  registers: [register]
});

const activeConnections = new prometheus.Gauge({
  name: 'mcp_active_connections',
  help: 'Number of active connections',
  registers: [register]
});

const memoryUsage = new prometheus.Gauge({
  name: 'mcp_memory_usage_bytes',
  help: 'Memory usage in bytes',
  labelNames: ['type'],
  registers: [register]
});

const queryDuration = new prometheus.Histogram({
  name: 'mcp_query_duration_seconds',
  help: 'Database query duration in seconds',
  labelNames: ['database', 'type'],
  buckets: [0.01, 0.05, 0.1, 0.5, 1, 2, 5, 10],
  registers: [register]
});

// Request tracking middleware
function trackRequestMetrics() {
  return (req: any, res: any, next: () => void) => {
    const startTime = Date.now();
    
    res.on('finish', () => {
      const duration = (Date.now() - startTime) / 1000;
      
      httpRequestsTotal.inc({
        method: req.method,
        path: req.path,
        status: res.statusCode
      });
      
      httpRequestDuration.observe({
        method: req.method,
        path: req.path
      }, duration);
      
      // Update metrics
      memoryUsage.set({ type: 'heapUsed' }, process.memoryUsage().heapUsed);
      memoryUsage.set({ type: 'rss' }, process.memoryUsage().rss);
    });
    
    activeConnections.inc();
    res.on('close', () => {
      activeConnections.dec();
    });
    
    next();
  };
}

// Tool call tracking
function trackToolCall(toolName: string, fn: Function) {
  return async (...args: any[]) => {
    const startTime = Date.now();
    
    try {
      const result = await fn(...args);
      toolCallsTotal.inc({ tool: toolName, success: 'true' });
      return result;
    } catch (error) {
      toolCallsTotal.inc({ tool: toolName, success: 'false' });
      throw error;
    } finally {
      const duration = (Date.now() - startTime) / 1000;
      toolCallDuration.observe({ tool: toolName }, duration);
    }
  };
}

// Query tracking
async function trackQuery<T>(
  database: string,
  type: 'read' | 'write',
  fn: () => Promise<T>
): Promise<T> {
  const startTime = Date.now();
  
  try {
    return await fn();
  } finally {
    const duration = (Date.now() - startTime) / 1000;
    queryDuration.observe({ database, type }, duration);
  }
}

// Express middleware
export function metricsMiddleware() {
  return async (req: any, res: any, next: () => void) => {
    if (req.path === '/metrics') {
      res.set('Content-Type', register.contentType);
      res.send(await register.metrics());
      return;
    }
    next();
  };
}

// Usage
app.use(trackRequestMetrics());
app.use(metricsMiddleware());

// Track tool calls
server.tool(
  'expensive_operation',
  schema,
  trackToolCall('expensive_operation', async (args) => {
    // Tool implementation
    return await trackQuery('postgres', 'read', () => {
      // Database query
    });
  })
);
```

### 4.2 Health Checks

**Health Check Implementation:**

```typescript
export class HealthChecker {
  private checks: Map<string, () => Promise<{ healthy: boolean; message?: string }>> = new Map();
  private results: Map<string, { healthy: boolean; message?: string; timestamp: Date }> = new Map();

  /**
   * Register a health check
   */
  register(name: string, check: () => Promise<{ healthy: boolean; message?: string }>): void {
    this.checks.set(name, check);
  }

  /**
   * Run all health checks
   */
  async runAll(): Promise<{
    healthy: boolean;
    checks: Record<string, { healthy: boolean; message?: string }>;
  }> {
    const results: Record<string, { healthy: boolean; message?: string }> = {};
    let allHealthy = true;

    for (const [name, check] of this.checks) {
      try {
        const result = await check();
        results[name] = result;
        if (!result.healthy) {
          allHealthy = false;
        }
        this.results.set(name, { ...result, timestamp: new Date() });
      } catch (error) {
        results[name] = {
          healthy: false,
          message: error instanceof Error ? error.message : 'Unknown error'
        };
        allHealthy = false;
      }
    }

    return {
      healthy: allHealthy,
      checks: results
    };
  }

  /**
   * Get historical health results
   */
  getHistory(): Record<string, { healthy: boolean; message?: string; timestamp: Date }> {
    const result: Record<string, any> = {};
    for (const [name, entry] of this.results) {
      result[name] = { ...entry };
    }
    return result;
  }

  /**
   * Create health check endpoint
   */
  createEndpoint() {
    return async (req: any, res: any) => {
      const result = await this.runAll();
      
      res.status(result.healthy ? 200 : 503).json({
        status: result.healthy ? 'healthy' : 'unhealthy',
        timestamp: new Date().toISOString(),
        checks: result.checks,
        uptime: process.uptime()
      });
    };
  }
}

// Usage
const healthChecker = new HealthChecker();

// Register database check
healthChecker.register('database', async () => {
  try {
    await db.query('SELECT 1');
    return { healthy: true };
  } catch (error) {
    return {
      healthy: false,
      message: error instanceof Error ? error.message : 'Database unavailable'
    };
  }
});

// Register Redis check
healthChecker.register('redis', async () => {
  try {
    await redis.ping();
    return { healthy: true };
  } catch (error) {
    return {
      healthy: false,
      message: error instanceof Error ? error.message : 'Redis unavailable'
    };
  }
});

// Register MCP server check
healthChecker.register('mcp-server', async () => {
  try {
    // Check if server is accepting connections
    return { healthy: true };
  } catch (error) {
    return {
      healthy: false,
      message: error instanceof Error ? error.message : 'MCP server unavailable'
    };
  }
});

app.get('/health', healthChecker.createEndpoint());
```

---

## Part 5: Load Testing

### 5.1 Load Test Script

**Load Test Implementation (using autocannon):**

```javascript
import autocannon from 'autocannon';
import fs from 'fs';

const config = {
  url: process.env.TARGET_URL || 'http://localhost:3000',
  connections: parseInt(process.env.CONNECTIONS || '100'),
  duration: parseInt(process.env.DURATION || '60'),
  warmup: parseInt(process.env.WARMUP || '10'),
  pipelining: parseInt(process.env.PIPELINING || '1')
};

// Define test scenarios
const scenarios = [
  {
    name: 'Health Check',
    path: '/health',
    method: 'GET',
    expectedStatus: 200
  },
  {
    name: 'List Tools',
    path: '/tools/list',
    method: 'POST',
    body: {},
    expectedStatus: 200
  },
  {
    name: 'Call Tool',
    path: '/tools/call',
    method: 'POST',
    body: {
      name: 'add',
      arguments: { a: 5, b: 3 }
    },
    expectedStatus: 200
  },
  {
    name: 'Database Query',
    path: '/tools/call',
    method: 'POST',
    body: {
      name: 'execute_query',
      arguments: {
        sql: 'SELECT * FROM users LIMIT 10'
      }
    },
    expectedStatus: 200
  }
];

// Run load test
async function runLoadTest(scenario) {
  console.log(`\n🚀 Running load test: ${scenario.name}`);
  console.log(`   Connections: ${config.connections}`);
  console.log(`   Duration: ${config.duration}s`);

  const instance = autocannon({
    url: config.url,
    connections: config.connections,
    duration: config.duration,
    warmup: config.warmup,
    pipelining: config.pipelining,
    requests: [
      {
        method: scenario.method,
        path: scenario.path,
        body: scenario.body ? JSON.stringify(scenario.body) : undefined,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.API_KEY || 'test-key'}`
        }
      }
    ]
  });

  return new Promise((resolve) => {
    autocannon.track(instance, { renderProgressBar: true });
    
    instance.on('done', (result) => {
      const summary = {
        name: scenario.name,
        duration: result.duration,
        requests: result.requests,
        throughput: result.throughput,
        latency: {
          average: result.latency.avg,
          p50: result.latency.p50,
          p90: result.latency.p90,
          p99: result.latency.p99,
          max: result.latency.max
        },
        errors: result.errors,
        timeouts: result.timeouts,
        non2xx: result.non2xx,
        statusCodeStats: result.statusCodeStats
      };
      
      console.log('\n📊 Results:');
      console.log(`   Requests: ${summary.requests.total}`);
      console.log(`   Throughput: ${summary.throughput} req/sec`);
      console.log(`   Latency (avg): ${summary.latency.average}ms`);
      console.log(`   Latency (p99): ${summary.latency.p99}ms`);
      console.log(`   Errors: ${summary.errors}`);
      
      resolve(summary);
    });
  });
}

// Run all scenarios
async function main() {
  console.log('🔬 Running load tests...');
  console.log(`Target: ${config.url}`);
  console.log(`Connections: ${config.connections}`);
  console.log(`Duration: ${config.duration}s`);
  
  const results = {};
  
  for (const scenario of scenarios) {
    try {
      results[scenario.name] = await runLoadTest(scenario);
    } catch (error) {
      console.error(`❌ Test failed: ${scenario.name}`, error);
      results[scenario.name] = { error: error.message };
    }
  }
  
  // Save results
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  fs.writeFileSync(
    `load-test-results-${timestamp}.json`,
    JSON.stringify({ config, results, timestamp }, null, 2)
  );
  
  console.log(`\n✅ Load tests complete!`);
  console.log(`Results saved to: load-test-results-${timestamp}.json`);
}

main().catch(console.error);
```

### 5.2 Performance Benchmarking

**Benchmark Script:**

```typescript
import { performance } from 'perf_hooks';

export class Benchmark {
  private results: Map<string, {
    runs: number[];
    totalTime: number;
    average: number;
    min: number;
    max: number;
  }> = new Map();

  /**
   * Run a benchmark
   */
  async run(name: string, fn: () => Promise<any>, iterations: number = 10): Promise<void> {
    console.log(`🏃 Running benchmark: ${name}`);
    console.log(`   Iterations: ${iterations}`);
    
    const times: number[] = [];
    
    for (let i = 0; i < iterations; i++) {
      const start = performance.now();
      await fn();
      const end = performance.now();
      times.push(end - start);
    }
    
    const totalTime = times.reduce((a, b) => a + b, 0);
    const average = totalTime / times.length;
    const min = Math.min(...times);
    const max = Math.max(...times);
    
    this.results.set(name, {
      runs: times,
      totalTime,
      average,
      min,
      max
    });
    
    console.log(`   Average: ${average.toFixed(2)}ms`);
    console.log(`   Min: ${min.toFixed(2)}ms`);
    console.log(`   Max: ${max.toFixed(2)}ms`);
  }

  /**
   * Print benchmark results
   */
  printResults(): void {
    console.log('\n📊 Benchmark Results');
    console.log('====================');
    
    for (const [name, result] of this.results) {
      console.log(`\n${name}:`);
      console.log(`  Average: ${result.average.toFixed(2)}ms`);
      console.log(`  Min: ${result.min.toFixed(2)}ms`);
      console.log(`  Max: ${result.max.toFixed(2)}ms`);
      console.log(`  Total: ${result.totalTime.toFixed(2)}ms`);
    }
  }

  /**
   * Save results to file
   */
  saveToFile(filename: string): void {
    const data = Array.from(this.results.entries()).map(([name, result]) => ({
      name,
      ...result,
      runs: result.runs.slice(0, 10) // Only save first 10 runs
    }));
    
    fs.writeFileSync(filename, JSON.stringify(data, null, 2));
  }
}

// Usage
const benchmark = new Benchmark();

// Benchmark database query
await benchmark.run('Database Query', async () => {
  await db.query('SELECT * FROM users LIMIT 10');
}, 100);

// Benchmark tool call
await benchmark.run('Tool Call', async () => {
  await client.callTool('add', { a: 5, b: 3 });
}, 100);

// Benchmark MCP server initialization
await benchmark.run('Server Init', async () => {
  const server = new McpServer({ name: 'test', version: '1.0.0' });
  await server.connect(transport);
}, 10);

benchmark.printResults();
benchmark.saveToFile('benchmark-results.json');
```

---

## Part 6: Performance Optimization Checklist

### Database Optimization
- [ ] Add appropriate indexes
- [ ] Use covering indexes
- [ ] Optimize queries with EXPLAIN
- [ ] Use connection pooling
- [ ] Implement query caching
- [ ] Use read replicas for reads
- [ ] Partition large tables
- [ ] Use materialized views

### MCP Server Optimization
- [ ] Cache resource responses
- [ ] Batch tool calls
- [ ] Use worker threads for CPU-intensive operations
- [ ] Implement request throttling
- [ ] Enable response compression
- [ ] Use connection keep-alive

### A2A Optimization
- [ ] Batch messages
- [ ] Implement agent load balancing
- [ ] Use message queues for async processing
- [ ] Cache agent responses
- [ ] Optimize message routing

### Infrastructure Optimization
- [ ] Use CDN for static assets
- [ ] Implement horizontal scaling
- [ ] Use load balancers
- [ ] Optimize container resources
- [ ] Use auto-scaling

### Monitoring
- [ ] Implement performance monitoring
- [ ] Set up alerting
- [ ] Track key metrics
- [ ] Regular performance testing
- [ ] Monitor resource usage

---

This appendix provides a comprehensive reference for optimizing the performance of your AI systems. Use it as a guide when tuning your MCP servers, A2A agents, and multi-agent systems for production workloads.
