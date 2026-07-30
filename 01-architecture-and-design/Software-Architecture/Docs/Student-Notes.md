# Student Notes: JavaScript Systems Architecture Series

## Complete Notes for the Orchestrator System Course

---

## PART 0: INTRODUCTION

### What is System Architecture?
- Architecture is the **blueprint** of your system
- It defines how components interact
- It balances **trade-offs** (performance vs maintainability, etc.)
- Good architecture enables **evolution** over time

### The Orchestrator System
We're building a complete distributed system that demonstrates:
- Microservices with hexagonal architecture
- Event sourcing and CQRS
- AI integration
- Production orchestration

### Key Principles
- **Code-Heavy, No Placeholders**: Every code block is complete and working
- **Production-Grade**: Real-world patterns, error handling, observability
- **Logical Progression**: Each step builds on previous knowledge

---

## PHASE 1: RUNTIME & EXECUTION

### The JavaScript Runtime

#### Three-Layer Cake

```
┌─────────────────────────────────────────────┐
│         YOUR JAVASCRIPT CODE               │  ← Layer 3
├─────────────────────────────────────────────┤
│         V8 ENGINE (Google)                 │  ← Layer 2
│  • Parses/compiles JS to machine code      │
│  • Manages memory (GC)                     │
├─────────────────────────────────────────────┤
│         LIBUV (C Library)                  │  ← Layer 1
│  • Event Loop (heart of async)            │
│  • Thread pool (FS, DNS, etc.)            │
│  • Handles timers, signals, processes     │
└─────────────────────────────────────────────┘
```

**Key Insight**: JavaScript is single-threaded but non-blocking.

### The Event Loop

#### Restaurant Waiter Analogy
- Waiter takes order (call stack)
- Gives to kitchen (async operation)
- Continues taking orders (non-blocking)
- Delivers when ready (callback executes)

#### Six Event Loop Phases
1. **TIMERS**: setTimeout/setInterval callbacks
2. **PENDING CALLBACKS**: I/O callbacks deferred
3. **IDLE/PREPARE**: Internal use only
4. **POLL**: Retrieves new I/O events (most time here)
5. **CHECK**: setImmediate callbacks
6. **CLOSE CALLBACKS**: socket.on('close', ...)

#### Microtasks vs Macrotasks

| Type | Examples | Execution |
|------|----------|-----------|
| **Macrotasks** | setTimeout, setInterval, setImmediate | One per event loop phase |
| **Microtasks** | Promise.then, process.nextTick | Run immediately after each macrotask |

**Order of Execution**:
1. All microtasks in queue
2. One macrotask
3. Repeat

**Memory Trick**: "Micro before Macro"

### Blocking the Event Loop

**What Blocks**:
- CPU-intensive sync operations
- Infinite loops
- JSON.parse/stringify on large data
- Sync file operations

**Solutions**:
1. Worker threads for CPU work
2. setImmediate to yield
3. Offload to separate service

### 12-Factor Principles

| Factor | Name | Key Point |
|--------|------|-----------|
| I | Codebase | One repo, one app |
| II | Dependencies | Explicit in package.json |
| III | Config | Environment variables only |
| IV | Backing Services | Attached resources |
| V | Build/Release/Run | Strict separation |
| VI | Stateless Processes | No local state |
| VII | Port Binding | Environment-driven port |
| VIII | Concurrency | Scale via processes |
| IX | Disposability | Fast start, graceful shutdown |
| X | Dev/Prod Parity | Similar environments |
| XI | Logs | Event streams (stdout) |
| XII | Admin Processes | One-off tasks |

**Remember**: "Config in environment, logs to stdout, state in backing services"

### Graceful Shutdown

```typescript
process.on('SIGTERM', async () => {
    // 1. Stop accepting new requests
    await server.close();
    
    // 2. Wait for existing connections
    await waitForConnections();
    
    // 3. Clean up resources
    await db.disconnect();
    await redis.disconnect();
    
    process.exit(0);
});
```

### Configuration Management

**Why validate at startup**:
- Catch errors early
- Fail fast in production
- Self-documenting

**Use Zod or Joi** for runtime validation:
```typescript
const configSchema = z.object({
    DATABASE_URL: z.string().url(),
    // ... other config
});
```

### Structured Logging

**Best Practices**:
- Use JSON format (pino, winston)
- Include correlation ID
- Log at appropriate levels (debug, info, warn, error)
- Redact sensitive data
- Use child loggers for context

```typescript
logger.info({ userId: '123', action: 'login' }, 'User logged in');
```

---

## PHASE 2: STRUCTURAL FOUNDATIONS

### Hexagonal Architecture (Ports & Adapters)

#### Key Concept
The Domain depends on **interfaces (ports)**, not implementations (adapters). Dependencies point **inward**.

#### Three Layers

**1. Domain Layer (The Core)**
- Business entities
- Business rules
- Domain services
- **No external dependencies!**

**2. Application Layer (Use Cases)**
- Commands (write)
- Queries (read)
- Handlers (orchestrate domain)

**3. Infrastructure Layer (Adapters)**
- HTTP controllers
- Database repositories
- Cache services
- Message queues

#### Dependency Inversion Principle
```
HIGH-LEVEL (Domain) → PORT (Interface) ← LOW-LEVEL (Adapter)
```

**The Core never knows about the database!**

### Domain Entities

**Characteristics**:
- Contain business logic
- Enforce business rules
- Have identity (id)
- Track state changes

**Example Business Rules**:
- Email must be valid format
- Username must be unique
- User must be active to update
- Task cannot be completed twice

### Repository Pattern

**Port (Interface)**:
```typescript
interface IUserRepository {
    save(user: User): Promise<User>;
    findById(id: string): Promise<User | null>;
    // ...
}
```

**Adapter (Implementation)**:
```typescript
class PostgresUserRepository implements IUserRepository {
    async save(user: User): Promise<User> {
        // PostgreSQL implementation
    }
}
```

**Benefits**:
- Swap databases without changing domain
- Easy to test (mock)
- Clear separation of concerns

### CQRS (Command Query Responsibility Segregation)

**Commands (Write)**:
- Change state
- Validate input
- Enforce business rules
- Produce events

**Queries (Read)**:
- Return data
- No state change
- Optimized for reads
- Use separate read models

**Key Insight**: Use different models for reads and writes!

### Dependency Injection

**Purpose**: Wire components together
**Pattern**: Composition root - one place where everything is wired

```typescript
class Container {
    configure() {
        this.register('IRepository', new PostgresRepository());
        this.register('Service', new DomainService(repository));
        this.register('Handler', new CommandHandler(service));
        this.register('Controller', new Controller(handler));
    }
}
```

### Testing Hexagonal Architecture

**Unit Tests**: Domain layer (fast, isolated)
**Integration Tests**: Application layer (in-memory repos)
**E2E Tests**: Adapters (real dependencies)

### PostgreSQL Integration

**Connection Pooling**
- **Why**: Creating connections is expensive
- **Config**: max, idleTimeout, connectionTimeout
- **Always release connections**!

**Transactions**
- Use for data consistency
- Keep them short
- Handle rollbacks

```typescript
await db.transaction(async (client) => {
    await client.query('BEGIN');
    // Multiple operations
    await client.query('COMMIT');
});
```

**Migrations**
- Version control for your database schema
- Run in order
- Idempotent (can run multiple times)

### Caching with Redis

#### Cache-Aside Pattern
1. Check cache
2. If miss, query database
3. Store in cache
4. Return data

#### Cache Invalidation Strategies
1. **TTL**: Time-based expiration
2. **Event-Based**: Invalidate on update
3. **Version-Based**: Version in cache key

#### Multi-Level Cache
- **L1**: In-memory (fastest, per instance)
- **L2**: Redis (shared, slower but shared)

#### Cache Headers
- `Cache-Control: max-age=60`
- `stale-while-revalidate=300`
- `public` vs `private`

---

## PHASE 3: DISTRIBUTED SYSTEMS

### API Composition

**Replace Sequential with Parallel**:
```typescript
// Sequential (BAD): 300ms
const user = await getUser();
const tasks = await getTasks();
const stats = await getStats();

// Parallel (GOOD): 100ms
const [user, tasks, stats] = await Promise.all([
    getUser(),
    getTasks(),
    getStats()
]);
```

### Circuit Breaker

**States**:
- **CLOSED**: Normal operation
- **OPEN**: Failing fast
- **HALF_OPEN**: Testing recovery

**When to Open**: After N consecutive failures
**When to Close**: After successful test in HALF_OPEN

**Benefits**:
- Prevents cascading failures
- Fast failure (no timeouts)
- Auto-recovery

### Saga Pattern

**Problem**: Distributed transactions across services
**Solution**: Sequence of local transactions with compensation

**Two Approaches**:
1. **Choreography**: Services publish events
2. **Orchestration**: Central coordinator

**Key Principle**: Each step has a compensating action

### Retry with Exponential Backoff

**Why**: Handle transient failures
**Pattern**: Delay doubles each attempt (+ jitter)

```
Attempt 1: 1s
Attempt 2: 2s
Attempt 3: 4s
Attempt 4: 8s
```

**Jitter**: Random variation to prevent thundering herd

### Request Context

**Purpose**: Propagate information across services
**Use AsyncLocalStorage** in Node.js

**What to propagate**:
- Request ID (for tracing)
- Correlation ID (for chain)
- User ID (for auth)
- Timeout (for deadlines)

### AbortController

**Why**: Cancel expensive operations
**How**: Propagate signal through the call chain

```typescript
const controller = new AbortController();
fetch(url, { signal: controller.signal });
controller.abort(); // Cancels the fetch
```

**Use Cases**:
- Client disconnects
- Request timeout
- User cancels operation

### Distributed Tracing

**Key Concepts**:
- **Trace**: Complete request flow
- **Span**: Single operation
- **Propagation**: Headers (x-trace-id, x-span-id)

**Benefits**:
- Debugging distributed systems
- Performance analysis
- Identifying bottlenecks

---

## PHASE 4: CLOUD-NATIVE ARCHITECTURE

### Serverless Overview

**Traditional vs Serverless**:
| Aspect | Traditional | Serverless |
|--------|-------------|------------|
| Server | Always running | Invoked on demand |
| Cost | 24/7 | Per execution |
| Scaling | Manual | Automatic |

### Cold Starts

**What**: Initialization delay when function is invoked
**Why**: Creating runtime environment, loading dependencies

**Mitigation Strategies**:
1. **Keep bundle small**: Tree shaking, minification
2. **Lazy initialization**: Connect on first request
3. **Provisioned concurrency**: Keep instances warm
4. **Smaller runtime**: Node.js 18+, avoid large frameworks

**Key Principle**: Initialize outside the handler (reuse across invocations)

### AWS Lambda

**Entry Point**:
```typescript
export async function handler(event, context) {
    // Initialize once (outside handler)
    // Process request
    return response;
}
```

**Optimization**: Use connection pooling (reuse connections)

### Cloudflare Workers

**Key Differences**:
- Runs at edge (global network)
- V8 isolates (not containers)
- 128MB memory limit
- Fast cold starts

**Benefits**:
- Reduced latency
- Global distribution
- DDoS protection

### Edge Caching

**CDN Architecture**:
```
Origin → Edge Location → User
```

**Cache Rules**:
- TTL per path
- stale-while-revalidate
- Cache control headers

**Invalidation**: Purge CDN cache on updates

---

## PHASE 5: DATA SYSTEMS

### Event Sourcing

**Traditional CRUD vs Event Sourcing**:

| CRUD | Event Sourcing |
|------|----------------|
| Stores current state | Stores all events |
| Lost history | Complete audit trail |
| Hard to query time | Temporal queries |

**Event** = Fact that happened (immutable)

**Benefits**:
- Complete audit trail
- Rebuild state at any point
- Temporal queries
- Event replay for new read models

### Domain Events

**Characteristics**:
- Immutable (never change)
- Past tense names (UserCreated)
- Contains all relevant data
- Versioned for evolution

**Event Structure**:
```typescript
{
    eventId: string;
    eventType: string;
    aggregateId: string;
    version: number;
    timestamp: Date;
    data: { ... };
}
```

### Event Store

**Schema**:
```sql
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    event_id UUID NOT NULL UNIQUE,
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(50) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    version INTEGER NOT NULL,
    data JSONB NOT NULL,
    created_at TIMESTAMP NOT NULL
);
```

**Index**: (aggregate_id, version) for replay

### Projections (Read Models)

**What**: Denormalized views for querying
**How**: Process events to build views
**Rebuild**: Replay all events from scratch

```typescript
class UserProjection {
    async handleUserCreated(event: UserCreatedEvent) {
        // Insert into read model
    }
}
```

### Event Versioning

**Why**: Events evolve over time
**How**: Upcasters convert old events
**Key**: Never change existing events

### Node.js Streams

**Types**:
- **Readable**: Source (file, HTTP request)
- **Writable**: Destination (file, HTTP response)
- **Transform**: Process in transit
- **Duplex**: Both readable and writable

**Pipeline**: Source → Transform → Sink

### Backpressure

**Problem**: Fast producer, slow consumer
**Solution**: Signal to slow down

**How**: Streams handle backpressure automatically
**Control**: pipe() handles it, highWaterMark controls buffer

---

## PHASE 6: AI & THE FINAL BOSS

### AI Agents

**Components**:
1. **LLM (Brain)** : Understands and reasons
2. **Memory**: Short-term (context) + Long-term (experiences)
3. **Tools**: Actions the agent can take

### Agentic Loop

```
PERCEIVE → PLAN → EXECUTE → REFLECT
```

**Perceive**: Understand current state
**Plan**: Decide next action
**Execute**: Use tools
**Reflect**: Learn from results

### LLM Integration

**Messages**:
- System: Set behavior
- User: User input
- Assistant: AI response
- Tool: Tool execution result

**Tools (Function Calling)**:
- Define tool schema
- LLM decides when to use
- Execute and return result

### Vector Memory

**What**: Semantic search using embeddings
**How**: Store text as vectors, search by similarity

**Use Cases**:
- Retrieving relevant context
- Finding similar examples
- Memory recall

### The Final Boss: Orchestration Layer

**Components**:

1. **Rate Limiter**: Prevent overload
2. **Deduplicator**: Prevent duplicate requests
3. **Request Queue**: Priority-based scheduling
4. **Retry Policy**: Exponential backoff
5. **Bulk Processor**: Batch similar requests

### Rate Limiter

**Sliding Window**: Most accurate
**Headers**: Limit, Remaining, Reset

**Key**: Use multiple factors (IP, UserID, API Key)

### Priority Queue

**Priorities**:
0. CRITICAL
1. HIGH
2. MEDIUM
3. LOW
4. BACKGROUND

**Processing**: Highest priority first, concurrency control

### Request Deduplication

**Why**: Prevent duplicate processing
**How**: Key-based cache with TTL

**Use Cases**:
- Idempotent operations
- Preventing duplicates
- Reducing load

### Bulk Processing

**Why**: Reduce overhead
**How**: Group similar requests

**Triggers**:
- Batch size reached
- Time window expired

---

## KEY TAKEAWAYS

### Architecture is About Trade-offs
- No perfect solution
- Balance competing requirements
- Document decisions

### Code Quality Matters
- Production-grade code
- Error handling
- Observability

### Patterns are Tools
- Learn the patterns
- Apply appropriately
- Avoid over-engineering

### Distributed Systems are Different
- Expect failures
- Design for resilience
- Monitor everything

### Continuous Improvement
- Learn from each system
- Evolve with requirements
- Stay curious

---

## COMMAND REFERENCE

### Development
```bash
npm run dev        # Start dev server
npm run build      # Build TypeScript
npm run test       # Run tests
npm run lint       # Lint code
```

### Database
```bash
npm run admin:db-migrate  # Run migrations
npm run admin:db-seed     # Seed data
docker-compose up -d postgres
docker-compose exec postgres psql -U postgres
```

### Deployment
```bash
npm run deploy:lambda      # Deploy to AWS Lambda
npm run deploy:worker      # Deploy to Cloudflare
npm run deploy:terraform   # Terraform apply
```

### Monitoring
```bash
curl http://localhost:3000/health
curl http://localhost:3000/metrics
curl http://localhost:3000/queue/stats
curl http://localhost:3000/tracing/stats
```

---

## GLOSSARY

| Term | Definition |
|------|------------|
| **Event Loop** | JavaScript's asynchronous runtime model |
| **Libuv** | C library powering Node.js async I/O |
| **Hexagonal Architecture** | Ports & Adapters pattern |
| **Dependency Inversion** | Depend on abstractions, not implementations |
| **CQRS** | Command Query Responsibility Segregation |
| **Event Sourcing** | Storing state as events |
| **Saga** | Distributed transaction pattern |
| **Circuit Breaker** | Prevents cascading failures |
| **Backpressure** | Slow down producer to match consumer |
| **Idempotency** | Operation can be repeated safely |
| **Eventual Consistency** | Data will eventually be consistent |
| **Vector Memory** | Semantic search using embeddings |
| **Agentic Loop** | Perceive → Plan → Execute → Reflect |

---

## TROUBLESHOOTING CHEAT SHEET

| Issue | Check | Fix |
|-------|-------|-----|
| Port already in use | `lsof -i :3000` | Kill process or change port |
| DB connection failed | `docker ps \| grep postgres` | Start PostgreSQL |
| Redis connection failed | `docker ps \| grep redis` | Start Redis |
| Migration failed | Check migration logs | Run migration manually |
| Rate limited | `RateLimit-Reset` header | Wait for reset |
| Circuit open | Check circuit metrics | Wait for timeout |
| Event loop blocked | Check event loop lag | Use worker threads |

---

## FINAL NOTES

### What You've Built

✅ Production-Ready HTTP Service
✅ Hexagonal Architecture with Clean Separation
✅ PostgreSQL Integration with Connection Pooling
✅ Redis Caching with Multi-Level Strategy
✅ Distributed Patterns (Circuit Breaker, Saga, Retry)
✅ Request Context & Cancellation Propagation
✅ Cloud-Native Deployment (Lambda, Workers)
✅ Event Sourcing with Complete Audit Trail
✅ AI Agents with LLM Integration
✅ Production Orchestration Layer

### What's Next

**Deepen Your Knowledge**:
- Kubernetes
- Service Mesh (Istio, Linkerd)
- Kafka for event streaming
- GraphQL for APIs

**Expand the System**:
- Mobile apps
- Web UI
- Additional services
- Machine Learning integration

**Production Optimizations**:
- Load testing
- Security scanning
- Performance tuning
- Disaster recovery

---

**Congratulations! You've completed the JavaScript Systems Architecture series!** 🎉

Go build something amazing! 🚀
