# Appendix G: Troubleshooting Guide

## Diagnosing and Resolving Common Issues

This appendix provides a comprehensive troubleshooting guide for the Orchestrator system. Think of this like the maintenance manual for your restaurant chain - when something goes wrong, you need to diagnose and fix it quickly.

### 1. Troubleshooting Overview

#### Common Issue Categories

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       COMMON ISSUE CATEGORIES                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │    Startup      │  │   Runtime       │  │   Performance   │             │
│  │    Issues       │  │   Issues        │  │   Issues        │             │
│  │                 │  │                 │  │                 │             │
│  │ • Port in use  │  │ • Memory leaks  │  │ • Slow queries  │             │
│  │ • Config error │  │ • CPU spikes    │  │ • High latency  │             │
│  │ • DB connect   │  │ • Event loop    │  │ • Cache misses  │             │
│  │ • Migration    │  │   blocking      │  │ • Queue backup  │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
│                                                                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐             │
│  │    Database     │  │   Cache/Redis   │  │   Integration   │             │
│  │    Issues       │  │   Issues        │  │   Issues        │             │
│  │                 │  │                 │  │                 │             │
│  │ • Connection    │  │ • Connection    │  │ • Service       │             │
│  │ • Locking       │  │ • Memory        │  │   unavailable   │             │
│  │ • Replication   │  │ • Eviction      │  │ • Timeout       │             │
│  │ • Corruption    │  │ • Serialization │  │ • Auth errors   │             │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘             │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Startup Issues

#### Port Already in Use

**Error:** `Error: listen EADDRINUSE: address already in use :::3000`

**Diagnosis:**
```bash
# Check what's using the port
lsof -i :3000
netstat -tulpn | grep 3000

# On Windows
netstat -ano | findstr :3000
```

**Solution:**
```bash
# Kill the process
kill -9 <PID>

# Or use a different port
PORT=3001 npm run dev

# Or update .env
echo "PORT=3001" >> .env
```

#### Configuration Errors

**Error:** `Invalid configuration: ...`

**Diagnosis:**
```bash
# Check environment variables
env | grep -E "DATABASE|REDIS|JWT"

# Validate .env file
cat .env | grep -v '^#' | grep -v '^$'

# Run config validation
node -e "require('./dist/config.js')"
```

**Solution:**
```bash
# Copy example config
cp .env.example .env

# Update required variables
# DATABASE_URL, REDIS_URL, JWT_SECRET

# Validate configuration
npm run type-check
```

#### Database Connection Failed

**Error:** `Error: connect ECONNREFUSED 127.0.0.1:5432`

**Diagnosis:**
```bash
# Check if PostgreSQL is running
docker ps | grep postgres
ps aux | grep postgres

# Test connection
psql -U postgres -h localhost -c "SELECT 1"

# Check logs
docker logs orchestrator-postgres-1
tail -f /var/log/postgresql/postgresql.log
```

**Solution:**
```bash
# Start PostgreSQL
docker-compose up -d postgres

# Or for local PostgreSQL
sudo systemctl start postgresql

# Test connection string
node -e "require('pg').Pool({connectionString: process.env.DATABASE_URL}).connect()"
```

### 3. Runtime Issues

#### Memory Leaks

**Symptoms:**
- Memory usage gradually increasing
- Process crashes with "JavaScript heap out of memory"
- Slow response times over time

**Diagnosis:**
```bash
# Monitor memory usage
npm run start -- --inspect
# Open chrome://inspect

# Use heap dump
node --heap-prof app.js
node --heap-prof-analyse heap-*.heapprofile

# Check memory usage
curl http://localhost:3000/metrics | jq '.process.memory'
```

**Common Causes & Solutions:**

```typescript
// ❌ BAD: Large objects not cleaned up
const globalCache = new Map();

// ✅ GOOD: Use LRU cache with max size
const cache = new LRUCache({ max: 1000 });

// ❌ BAD: Event listeners not removed
emitter.on('event', handler);

// ✅ GOOD: Remove listeners when done
emitter.once('event', handler);

// ❌ BAD: Large string operations
let data = '';
for (const chunk of chunks) {
    data += chunk; // Creates new string each time
}

// ✅ GOOD: Use array join
const parts = [];
for (const chunk of chunks) {
    parts.push(chunk);
}
const data = parts.join('');
```

#### CPU Spikes

**Symptoms:**
- High CPU usage (90%+)
- Slow request processing
- Event loop lag

**Diagnosis:**
```bash
# CPU profiling
node --cpu-prof app.js
node --cpu-prof-analyse cpu-*.cpuprofile

# Check event loop lag
curl http://localhost:3000/status | jq '.runtime.eventLoop'

# Using clinic.js
npx clinic flame -- node app.js
```

**Common Causes & Solutions:**

```typescript
// ❌ BAD: CPU-intensive sync operations
function processLargeArray(data: number[]): number[] {
    return data.map(x => heavyComputation(x));
}

// ✅ GOOD: Use worker threads or batch processing
const { Worker } = require('worker_threads');

function processLargeArrayAsync(data: number[]): Promise<number[]> {
    return new Promise((resolve, reject) => {
        const worker = new Worker('./worker.js');
        worker.postMessage(data);
        worker.on('message', resolve);
        worker.on('error', reject);
    });
}

// ❌ BAD: Blocking loop
for (let i = 0; i < 1e9; i++) {
    // Heavy computation
}

// ✅ GOOD: Use setImmediate to yield
function processInBatches(data: any[], index: number = 0) {
    const batchSize = 10000;
    const batch = data.slice(index, index + batchSize);
    
    // Process batch
    for (const item of batch) {
        // process item
    }
    
    if (index + batchSize < data.length) {
        setImmediate(() => processInBatches(data, index + batchSize));
    }
}
```

#### Event Loop Blocking

**Symptoms:**
- Response times increase dramatically
- Timeouts on all requests
- Health checks failing

**Diagnosis:**
```bash
# Check event loop lag
while true; do
    curl -s http://localhost:3000/status | jq '.runtime.eventLoop.lag'
    sleep 1
done

# Using event-loop-lag module
npm install event-loop-lag
```

**Solution:**
```typescript
// Detect and log blocking
const lag = require('event-loop-lag')(1000);

setInterval(() => {
    const delay = lag();
    if (delay > 50) { // > 50ms lag
        logger.warn({ delay }, 'Event loop blocked');
        // Optionally capture stack trace
        // console.trace();
    }
}, 1000);
```

### 4. Database Issues

#### Slow Queries

**Diagnosis:**
```sql
-- Enable slow query logging
ALTER SYSTEM SET log_min_duration_statement = 1000;
SELECT pg_reload_conf();

-- View slow queries
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    max_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- Find missing indexes
SELECT 
    relname,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch
FROM pg_stat_user_tables
WHERE seq_scan > 0
ORDER BY seq_scan DESC;
```

**Solutions:**
```sql
-- Add missing indexes
CREATE INDEX CONCURRENTLY idx_users_created_at ON users(created_at DESC);
CREATE INDEX CONCURRENTLY idx_tasks_user_status ON tasks(user_id, status);

-- Optimize queries
-- Before
SELECT * FROM tasks WHERE user_id = 1 AND status = 'pending';

-- After - use composite index
CREATE INDEX idx_tasks_user_status ON tasks(user_id, status);

-- Use covering indexes
CREATE INDEX idx_tasks_covering ON tasks(user_id, status) 
    INCLUDE (title, created_at, priority);

-- Use partial indexes
CREATE INDEX idx_tasks_pending ON tasks(user_id) 
    WHERE status = 'pending';
```

#### Connection Pool Issues

**Symptoms:**
- `Error: Connection pool exhausted`
- Timeouts when acquiring connections
- Database errors about max connections

**Diagnosis:**
```bash
# Check connection usage
psql -U postgres -c "SELECT count(*) FROM pg_stat_activity;"
psql -U postgres -c "SELECT count(*) FROM pg_stat_activity WHERE state = 'active';"

# Check pool stats
curl http://localhost:3000/metrics | jq '.database'
```

**Solutions:**
```typescript
// Adjust pool configuration
const pool = new Pool({
    max: 20,                // Maximum connections
    min: 5,                 // Minimum connections
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
});

// Ensure connections are released
async function query(sql: string, params?: any[]) {
    const client = await pool.connect();
    try {
        return await client.query(sql, params);
    } finally {
        client.release(); // Always release!
    }
}
```

#### Deadlocks

**Diagnosis:**
```sql
-- Check for deadlocks
SELECT * FROM pg_locks WHERE NOT granted;

-- View deadlock logs
tail -f /var/log/postgresql/postgresql.log | grep "deadlock"

-- Enable deadlock logging
ALTER SYSTEM SET log_lock_waits = on;
SELECT pg_reload_conf();
```

**Solutions:**
```typescript
// Use consistent ordering
async function transferTask(fromUserId: string, toUserId: string) {
    const client = await pool.connect();
    try {
        // Always lock in the same order
        const ids = [fromUserId, toUserId].sort();
        await client.query('BEGIN');
        
        // Lock in sorted order
        for (const id of ids) {
            await client.query('SELECT 1 FROM users WHERE id = $1 FOR UPDATE', [id]);
        }
        
        // Perform transfer
        await client.query('UPDATE tasks SET user_id = $1 WHERE user_id = $2', [toUserId, fromUserId]);
        
        await client.query('COMMIT');
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
}
```

### 5. Redis/Cache Issues

#### Connection Issues

**Diagnosis:**
```bash
# Test Redis connection
redis-cli ping

# Check Redis logs
docker logs orchestrator-redis-1

# Check connection stats
redis-cli INFO clients
```

**Solutions:**
```typescript
// Implement retry logic
const redis = new Redis({
    host: 'localhost',
    port: 6379,
    retryStrategy: (times) => {
        if (times > 3) {
            return null; // Stop retrying
        }
        return Math.min(times * 100, 3000);
    },
    lazyConnect: true,
});

// Connection monitoring
redis.on('error', (error) => {
    logger.error({ error }, 'Redis connection error');
});

redis.on('reconnecting', (delay) => {
    logger.warn({ delay }, 'Redis reconnecting');
});
```

#### Memory Issues

**Diagnosis:**
```bash
# Check memory usage
redis-cli INFO memory

# Find large keys
redis-cli --bigkeys

# Check eviction stats
redis-cli INFO stats | grep evicted
```

**Solutions:**
```bash
# Configure memory limit
redis-cli CONFIG SET maxmemory 2GB
redis-cli CONFIG SET maxmemory-policy allkeys-lru

# Monitor keyspace
redis-cli INFO keyspace

# Clear specific pattern
redis-cli KEYS "user:*" | xargs redis-cli DEL
```

### 6. Performance Issues

#### High Latency

**Diagnosis:**
```bash
# Check overall latency
curl -w "@curl-format.txt" -o /dev/null -s http://localhost:3000/health

# Check specific endpoints
time curl http://localhost:3000/api/users/123

# Profile the application
npm run start -- --inspect
# Open chrome://inspect
```

**Solutions:**
```typescript
// Add timing middleware
fastify.addHook('onRequest', (request, reply, done) => {
    request.startTime = Date.now();
    done();
});

fastify.addHook('onResponse', (request, reply, done) => {
    const duration = Date.now() - request.startTime;
    if (duration > 100) {
        logger.warn({
            url: request.url,
            method: request.method,
            duration,
            statusCode: reply.statusCode,
        }, 'Slow request');
    }
    done();
});

// Use caching
const cacheKey = `user:${userId}`;
const cached = await cache.get(cacheKey);
if (cached) {
    return cached;
}

// Use connection pooling
const httpAgent = new https.Agent({
    keepAlive: true,
    maxSockets: 50,
});

fetch(url, { agent: httpAgent });
```

#### Queue Backup

**Symptoms:**
- Tasks stuck in "pending" state
- High queue size
- Workers not processing

**Diagnosis:**
```bash
# Check queue stats
curl http://localhost:3000/queue/stats

# Check worker status
curl http://localhost:3000/queue/workers

# Check database for pending tasks
psql -U postgres -c "SELECT COUNT(*) FROM tasks WHERE status = 'pending';"
```

**Solutions:**
```typescript
// Increase workers
process.env.WORKER_COUNT = '10';

// Implement queue monitoring
setInterval(() => {
    const stats = queue.getStats();
    if (stats.queueSize > 1000) {
        logger.warn({ stats }, 'Queue backup detected');
        // Scale up workers
        workerPool.increaseWorkers(5);
    }
}, 10000);

// Implement dead letter queue
class DeadLetterHandler {
    async handleDeadLetter(message: any): Promise<void> {
        logger.error({ message }, 'Message moved to dead letter queue');
        // Store in dead letter queue
        await db.query(
            'INSERT INTO dead_letter_queue (message, error) VALUES ($1, $2)',
            [message, message.error]
        );
    }
}
```

### 7. Integration Issues

#### Service Unavailable

**Symptoms:**
- `ServiceError: Service unavailable`
- Timeouts when calling external services
- Circuit breaker trips

**Diagnosis:**
```bash
# Check service health
curl http://auth-service:3001/health
curl http://user-service:3002/health
curl http://task-service:3003/health

# Check service registry
curl http://localhost:3000/registry/status

# Check logs for service errors
grep "ServiceError" logs/app.log
```

**Solutions:**
```typescript
// Implement circuit breaker
const breaker = new CircuitBreaker({
    failureThreshold: 5,
    resetTimeout: 60000,
});

// Implement fallback
const user = await circuitBreaker.execute(
    () => userService.getUser(id),
    () => ({ id, name: 'Unknown User', fallback: true })
);

// Implement retry with backoff
const result = await retry(() => service.call(), {
    maxAttempts: 3,
    initialDelay: 1000,
    maxDelay: 30000,
});
```

#### Authentication Errors

**Symptoms:**
- `401 Unauthorized`
- `403 Forbidden`
- Token validation failures

**Diagnosis:**
```bash
# Decode JWT token
jwt decode <token>

# Check token expiration
jwt decode <token> | grep exp

# Check user roles
curl -H "Authorization: Bearer <token>" http://localhost:3000/api/users/me
```

**Solutions:**
```typescript
// Token refresh
async function refreshToken(token: string): Promise<string> {
    try {
        const decoded = jwt.decode(token);
        if (!decoded.exp || decoded.exp * 1000 < Date.now() + 300000) {
            // Token expires in < 5 minutes
            return await authService.refreshToken(token);
        }
        return token;
    } catch (error) {
        throw new Error('Invalid token');
    }
}

// Permission checking
function checkPermission(user: User, requiredPermission: string): boolean {
    return user.roles.some(role => 
        PERMISSIONS[requiredPermission]?.includes(role)
    );
}
```

### 8. Debug Commands Quick Reference

#### Application Debugging
```bash
# Run with debug logging
LOG_LEVEL=debug npm run dev

# Run with inspector
node --inspect dist/index.js

# Run with profiler
node --prof dist/index.js

# Check event loop
node -e "console.log(process.eventNames())"
```

#### Database Debugging
```bash
# Connect to database
psql -U postgres -d orchestrator

# Monitor queries
SELECT * FROM pg_stat_activity WHERE state = 'active';

# Check locks
SELECT * FROM pg_locks WHERE NOT granted;

# Analyze tables
ANALYZE users;
ANALYZE tasks;
ANALYZE events;
```

#### Redis Debugging
```bash
# Monitor Redis
redis-cli MONITOR

# Check slow queries
redis-cli SLOWLOG GET 10

# Check memory
redis-cli INFO memory

# List keys
redis-cli KEYS "orchestrator:*"
```

#### Log Analysis
```bash
# Application logs
tail -f logs/app.log

# Error logs
tail -f logs/error.log

# Security logs
tail -f logs/security.log

# Access logs
tail -f logs/access.log

# Database logs
tail -f /var/log/postgresql/postgresql.log

# Redis logs
tail -f /var/log/redis/redis-server.log
```

### 9. Emergency Procedures

#### Service Outage

1. **Immediate Actions:**
```bash
# Restart the service
docker-compose restart gateway

# Check health endpoints
curl http://localhost:3000/health

# Check database
psql -U postgres -c "SELECT 1"

# Check Redis
redis-cli ping
```

2. **Rollback:**
```bash
# Rollback Lambda
aws lambda update-alias \
    --function-name orchestrator-gateway \
    --name production \
    --function-version $PREVIOUS_VERSION

# Rollback Cloudflare
wrangler rollback --env production

# Rollback Kubernetes
kubectl rollout undo deployment/orchestrator-gateway
```

3. **Emergency Contact:**
```bash
# Send alert
curl -X POST https://hooks.slack.com/services/xxx \
    -H "Content-Type: application/json" \
    -d '{"text": "🚨 Service outage detected! Immediate action required."}'
```

---

This troubleshooting guide should help you diagnose and resolve common issues in the Orchestrator system. Remember to always check logs first, verify configurations, and test solutions in a non-production environment first.
