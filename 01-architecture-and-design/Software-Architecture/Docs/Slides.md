# Complete Slide Outline: JavaScript Systems Architecture Series

## A Comprehensive Teaching Deck for the Entire Series

This is a comprehensive, extensive, and expanded slide outline designed to teach the entire JavaScript Systems Architecture series. Each slide includes detailed content, analogies, code snippets, and teaching notes. This can be used to create a complete presentation deck for workshops, courses, or training sessions.

---

## PART 0: INTRODUCTION (5 Slides)

### Slide 0.1: Title Slide
**Title:** JavaScript Systems Architecture
**Subtitle:** From Zero to Production-Grade Distributed Systems

**Content:**
- Welcome message
- Brief overview of the journey
- What you'll build: The Orchestrator System
- Estimated time: 20-40 hours of hands-on work

**Teaching Notes:**
- Show the final architecture diagram
- Set expectations: "You'll build a complete production system"
- Explain the "Chef/Restaurant" analogies used throughout

---

### Slide 0.2: What You'll Build
**Title:** The Orchestrator System

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                      ORCHESTRATOR SYSTEM                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐    ┌─────────────┐    ┌──────────────────┐   │
│  │   API       │    │   Auth      │    │   Task           │   │
│  │   Gateway   │◄──►│   Service   │    │   Orchestrator   │   │
│  │   (Fastify) │    │   (JWT)     │    │   (Saga/State)   │   │
│  └─────────────┘    └─────────────┘    └──────────────────┘   │
│         │                                       │              │
│         ▼                                       ▼              │
│  ┌─────────────┐    ┌─────────────┐    ┌──────────────────┐   │
│  │   User      │    │   Event     │    │   AI Agent       │   │
│  │   Service   │    │   Store     │    │   (LLM + Tools)  │   │
│  └─────────────┘    └─────────────┘    └──────────────────┘   │
│         │                 │                     │              │
│         ▼                 ▼                     ▼              │
│  ┌─────────────┐    ┌─────────────┐    ┌──────────────────┐   │
│  │  PostgreSQL  │    │   Redis     │    │   S3/Cloud       │   │
│  │  (Primary)   │    │   (Cache)   │    │   (Storage)      │   │
│  └─────────────┘    └─────────────┘    └──────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain each component's role
- Emphasize this is what they'll build by the end
- Reference back to this diagram throughout

---

### Slide 0.3: The Journey Ahead
**Title:** 7 Phases, 20 Primers

**Content:**
| Phase | Focus | Key Topics |
|-------|-------|------------|
| 1 | Runtime & Execution | Event Loop, Libuv, 12-Factor |
| 2 | Structural Foundations | Hexagonal Architecture, DI |
| 3 | Distributed Systems | Sagas, Circuit Breakers, Cancellation |
| 4 | Cloud-Native | Serverless, Edge, Observability |
| 5 | Data Systems | Event Sourcing, CQRS, Streams |
| 6 | AI & The Final Boss | Agentic Loops, Production Orchestration |
| 7 | Primers (20 Deep Dives) | Comprehensive Pattern Reference |

**Teaching Notes:**
- Give a brief overview of each phase
- Explain the progression from simple to complex
- Emphasize the hands-on nature

---

### Slide 0.4: Prerequisites & Setup
**Title:** What You Need to Begin

**Content:**
```
Technical Prerequisites:
├── Node.js (v20+)         ── Check: node --version
├── TypeScript (v5+)       ── Check: tsc --version
├── Docker & Docker Compose ── Check: docker --version
├── PostgreSQL (via Docker) ── Check: docker-compose up postgres
├── Redis (via Docker)      ── Check: docker-compose up redis
├── Git                     ── Check: git --version
└── VS Code (recommended)   ── Extensions listed

Knowledge Prerequisites:
├── Basic JavaScript/TypeScript
├── Async/await & Promises
├── HTTP & REST APIs
├── Command line basics
└── Git fundamentals
```

**Teaching Notes:**
- Show verification commands
- Explain Docker setup
- Mention VS Code extensions
- Emphasize "you don't need to be an expert"

---

### Slide 0.5: How Each Part Is Structured
**Title:** Consistent Learning Pattern

**Content:**
```
PART STRUCTURE
├── 1. The Target ── What we're building
├── 2. The Concept ── Explanation with analogies
├── 3. Implementation ── Step-by-step code
│   ├── Step 1: Setup
│   ├── Step 2: Core files
│   ├── Step 3: Supporting files
│   └── Step 4: Verification
├── 4. Verification ── How to test it works
├── 5. Deep Dive ── Advanced concepts (Optional)
└── 6. Summary ── What we built and where we're going
```

**Teaching Notes:**
- Explain the consistent structure
- Emphasize "no placeholders" - everything is complete
- Mention the verification steps
- Reference the "Deep Dives" as optional advanced content

---

## PHASE 1: RUNTIME & EXECUTION (30 Slides)

### PART 1.1: The JavaScript Runtime Boundary (15 Slides)

#### Slide 1.1.1: The JavaScript Runtime
**Title:** Understanding How Your Code Actually Runs

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│              JAVASCRIPT RUNTIME ENVIRONMENT                    │
├─────────────────────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                  YOUR JAVASCRIPT CODE                    │ │
│  │  console.log('Hello'), async functions, callbacks        │ │
│  └───────────────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                  V8 ENGINE (Google)                      │ │
│  │  • Parses and compiles JS to machine code               │ │
│  │  • Manages memory (Garbage Collection)                  │ │
│  │  • Handles function calls, objects, prototypes          │ │
│  └───────────────────────────────────────────────────────────┘ │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │                  LIBUV (C Library)                       │ │
│  │  • Event Loop (the heart of async)                     │ │
│  │  • Thread pool for file system, DNS, etc.              │ │
│  │  • Handles timers, signals, child processes             │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain each layer with an analogy
- V8 = The interpreter
- Libuv = The I/O manager
- Show actual process: Node.js starts → V8 initializes → Libuv event loop

---

#### Slide 1.1.2: The Event Loop Explained
**Title:** The Heart of Async JavaScript

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                   RESTAURANT WAITER ANALOGY                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐     │
│  │ WAITER  │    │ KITCHEN │    │ CUSTOMER│    │ ORDERS  │     │
│  │ takes   │    │ cooks   │    │ waits   │    │ queued  │     │
│  │ order   │    │ food    │    │ for     │    │ for     │     │
│  │         │    │         │    │ result  │    │ pick-up │     │
│  └─────────┘    └─────────┘    └─────────┘    └─────────┘     │
│       │              │             │              │            │
│       ▼              ▼             ▼              ▼            │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │               EVENT LOOP (The Waiter)                  │   │
│  │  1. Takes order (call stack)                         │   │
│  │  2. Gives to kitchen (async operation)              │   │
│  │  3. Takes more orders (continues working)          │   │
│  │  4. Delivers when ready (callback executes)        │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- This is the most important concept
- Use the waiter analogy thoroughly
- Emphasize: JavaScript is single-threaded but non-blocking
- Show the flow: Call Stack → Web APIs → Callback Queue → Event Loop

---

#### Slide 1.1.3: Event Loop Phases
**Title:** The Six Phases of the Event Loop

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                   EVENT LOOP PHASES                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────┐     ┌──────────┐     ┌──────────┐               │
│  │ TIMERS  │────▶│ PENDING  │────▶│ IDLE/    │               │
│  │(setTimeout) │  CALLBACKS │     │ PREPARE  │               │
│  └─────────┘     └──────────┘     └──────────┘               │
│       │                  │              │                      │
│       ▼                  ▼              ▼                      │
│  ┌─────────┐     ┌──────────┐     ┌──────────┐               │
│  │ POLL    │◀────│ CHECK    │◀────│ CLOSE    │               │
│  │ (I/O)   │     │(setImmediate)│  CALLBACKS│               │
│  └─────────┘     └──────────┘     └──────────┘               │
│       │                   │              │                      │
│       └───────────────────┴──────────────┘                     │
│                                                                 │
│  1. TIMERS: setTimeout/setInterval callbacks                   │
│  2. PENDING CALLBACKS: I/O callbacks deferred                  │
│  3. IDLE/PREPARE: Internal use only                           │
│  4. POLL: Retrieves new I/O events                           │
│  5. CHECK: setImmediate callbacks                            │
│  6. CLOSE CALLBACKS: socket.on('close', ...)                │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Go through each phase in detail
- Emphasize POLL is where most time is spent
- Explain the difference between setTimeout and setImmediate
- Show order with code examples

---

#### Slide 1.1.4: Microtasks vs Macrotasks
**Title:** The Critical Distinction

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│              MICROTASKS vs MACROTASKS                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                      MACROTASKS                        │   │
│  │  • setTimeout, setInterval, setImmediate               │   │
│  │  • I/O operations                                     │   │
│  │  • UI rendering                                       │   │
│  │  • Executed in event loop phases                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                      MICROTASKS                        │   │
│  │  • Promise.then, catch, finally                        │   │
│  │  • process.nextTick (Node.js)                         │   │
│  │  • queueMicrotask                                     │   │
│  │  • Executed immediately after each macrotask          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  EXECUTION ORDER:                                              │
│  1. Execute all microtasks in the queue                       │
│  2. Execute one macrotask                                     │
│  3. Repeat                                                    │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- This explains why Promise is faster
- Show code example with execution order
- Explain process.nextTick in Node.js
- Emphasize: Microtasks run BEFORE next macrotask

---

#### Slide 1.1.5: Code Example - Async Order
**Title:** Understanding Async Execution Order

**Content:**
```javascript
console.log('1');

setTimeout(() => console.log('2'), 0);

Promise.resolve()
    .then(() => console.log('3'))
    .then(() => console.log('4'));

console.log('5');

// Output: 1, 5, 3, 4, 2
// Explanation:
// 1. Synchronous code: 1, 5
// 2. Microtasks: 3, 4
// 3. Macrotasks: 2
```

**Teaching Notes:**
- Run this code live
- Step through the execution
- Ask students to predict output
- Explain why order matters

---

#### Slide 1.1.6: Blocking the Event Loop
**Title:** What Happens When You Block

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 BLOCKING THE EVENT LOOP                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ❌ BAD: CPU-intensive synchronous operation                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ function heavyComputation() {                         │   │
│  │   let sum = 0;                                        │   │
│  │   for (let i = 0; i < 1e9; i++) {                     │   │
│  │     sum += i;                                         │   │
│  │   }                                                   │   │
│  │   return sum;                                         │   │
│  │ }                                                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Effects:                                                       │
│  • ALL requests are blocked                                   │
│  • No other operations can execute                            │
│  • API becomes unresponsive                                   │
│                                                                 │
│  Solutions:                                                     │
│  • Use worker threads                                         │
│  • Use setImmediate to yield                                  │
│  • Offload to separate service                                │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Show the problem with live demo
- Explain why this happens
- Discuss solutions

---

#### Slide 1.1.7: Worker Threads Solution
**Title:** Moving CPU Work to Workers

**Content:**
```javascript
const { Worker } = require('worker_threads');

function heavyComputationWorker(data) {
    return new Promise((resolve, reject) => {
        const worker = new Worker(`
            const { parentPort } = require('worker_threads');
            let sum = 0;
            for (let i = 0; i < 1e9; i++) {
                sum += i;
            }
            parentPort.postMessage(sum);
        `, { eval: true });
        
        worker.on('message', resolve);
        worker.on('error', reject);
    });
}

// Main thread continues to handle requests
app.get('/compute', async (req, res) => {
    const result = await heavyComputationWorker(req.data);
    res.json({ result });
});
```

**Teaching Notes:**
- Explain worker threads concept
- Show how main thread remains free
- Discuss trade-offs (overhead, communication cost)

---

#### Slide 1.1.8: 12-Factor Principles
**Title:** Building Production-Ready Services

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 12-FACTOR PRINCIPLES                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Factor 3: Config in Environment ── No config files            │
│  Factor 4: Backing Services ── Treat as attached resources     │
│  Factor 5: Build, Release, Run ── Strict separation           │
│  Factor 6: Stateless Processes ── No local state              │
│  Factor 8: Port Binding ── Export via port                   │
│  Factor 9: Disposability ── Fast startup, graceful shutdown  │
│  Factor 11: Logs as Event Streams ── Log to stdout/stderr    │
│  Factor 12: Admin Processes ── One-off tasks                │
│                                                                 │
│  RESTAURANT ANALOGY:                                           │
│  • Recipe works everywhere (config)                            │
│  • Switch suppliers easily (backing services)                 │
│  • Each shift starts fresh (stateless)                        │
│  • Dish prepared quickly (disposability)                     │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Cover each factor briefly
- Use the restaurant analogy
- Emphasize why these matter in production

---

#### Slide 1.1.9: Graceful Shutdown
**Title:** Handling SIGTERM and SIGINT

**Content:**
```typescript
// Signal handling for graceful shutdown
const signals: NodeJS.Signals[] = ['SIGINT', 'SIGTERM', 'SIGQUIT'];

for (const signal of signals) {
    process.on(signal, async () => {
        logger.info(`Received ${signal}, starting graceful shutdown...`);
        
        // 1. Stop accepting new connections
        await server.close();
        
        // 2. Wait for existing requests to complete
        await waitForConnections();
        
        // 3. Close database connections
        await database.disconnect();
        
        // 4. Close Redis connections
        await redis.disconnect();
        
        logger.info('Graceful shutdown complete');
        process.exit(0);
    });
}
```

**Teaching Notes:**
- Explain why graceful shutdown matters
- Show each step
- Discuss timeout handling
- Demonstrate in Docker/Kubernetes context

---

#### Slide 1.1.10: Health Checks
**Title:** Keeping Your Service Alive

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                      HEALTH CHECKS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  /health      │  Basic health check for load balancers        │
│  /health/ready│  Readiness probe for Kubernetes               │
│  /health/live │  Liveness probe for Kubernetes                │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  // Server.ts                                          │   │
│  │  app.get('/health', async (req, reply) => {           │   │
│  │    reply.send({                                       │   │
│  │      status: 'ok',                                    │   │
│  │      service: SERVICE_NAME,                          │   │
│  │      version: SERVICE_VERSION,                      │   │
│  │      timestamp: new Date().toISOString(),          │   │
│  │    });                                              │   │
│  │  });                                                │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain each health endpoint purpose
- Show Kubernetes probe configuration
- Discuss what makes a service "ready" vs "live"

---

#### Slide 1.1.11: Configuration Management
**Title:** Environment-Based Configuration

**Content:**
```typescript
import { z } from 'zod';
import dotenv from 'dotenv';

dotenv.config();

const configSchema = z.object({
    NODE_ENV: z.enum(['development', 'test', 'production']),
    PORT: z.coerce.number().default(3000),
    DATABASE_URL: z.string().optional(),
    REDIS_URL: z.string().optional(),
    JWT_SECRET: z.string().min(32).optional(),
    LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
});

// Validate at startup
const config = configSchema.parse(process.env);
if (config.NODE_ENV === 'production' && !config.JWT_SECRET) {
    console.error('JWT_SECRET is required in production');
    process.exit(1);
}
```

**Teaching Notes:**
- Show why validation matters
- Demonstrate failure on startup
- Explain environment-specific config

---

#### Slide 1.1.12: Structured Logging
**Title:** Logs as Event Streams

**Content:**
```typescript
import pino from 'pino';

const logger = pino({
    level: LOG_LEVEL,
    base: {
        service: SERVICE_NAME,
        version: SERVICE_VERSION,
        env: NODE_ENV,
    },
    timestamp: pino.stdTimeFunctions.isoTime,
    redact: {
        paths: ['req.headers.authorization', 'req.headers.cookie'],
        censor: '***REDACTED***',
    },
});

// Development: Pretty printing
if (!IS_PRODUCTION) {
    logger.transport = {
        target: 'pino-pretty',
        options: { colorize: true, translateTime: true },
    };
}

// Usage
logger.info({ userId: '123', action: 'login' }, 'User logged in');
```

**Teaching Notes:**
- Show difference between dev/production
- Explain structured vs unstructured logging
- Demonstrate redaction of sensitive data

---

#### Slide 1.1.13: Error Handling
**Title:** Production-Grade Error Handling

**Content:**
```typescript
// Custom Error Classes
export class AppError extends Error {
    public readonly statusCode: number;
    public readonly code: string;
    public readonly details?: unknown;
    
    constructor(message: string, statusCode: number = 500, code: string = 'INTERNAL_ERROR') {
        super(message);
        this.statusCode = statusCode;
        this.code = code;
        Error.captureStackTrace(this, this.constructor);
    }
}

// Global Error Handler
app.setErrorHandler((error, request, reply) => {
    if (error instanceof AppError) {
        reply.status(error.statusCode).send({
            success: false,
            error: {
                code: error.code,
                message: error.message,
                details: IS_DEVELOPMENT ? error.details : undefined,
            },
            requestId: request.id,
        });
    } else {
        // Unknown error
        logger.error({ error, requestId: request.id }, 'Unhandled error');
        reply.status(500).send({
            success: false,
            error: {
                code: 'INTERNAL_ERROR',
                message: IS_DEVELOPMENT ? error.message : 'Internal server error',
            },
        });
    }
});
```

**Teaching Notes:**
- Explain error hierarchy
- Show global handler
- Discuss environment-specific error messages

---

#### Slide 1.1.14: Putting It All Together
**Title:** Your Complete Production Service

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                    COMPLETE SERVICE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  src/                                                 │   │
│  │  ├── index.ts          # Entry point                  │   │
│  │  ├── server.ts         # Main server                  │   │
│  │  ├── config.ts         # Environment config          │   │
│  │  ├── logger.ts         # Structured logging          │   │
│  │  ├── error-handler.ts  # Global error handling      │   │
│  │  └── health/           # Health check endpoints      │   │
│  │      ├── health.controller.ts                       │   │
│  │      └── health.routes.ts                           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Features:                                                      │
│  ✅ Graceful shutdown (SIGTERM/SIGINT)                         │
│  ✅ Health checks (ready/live)                                │
│  ✅ Structured logging                                        │
│  ✅ Configuration validation                                  │
│  ✅ Global error handling                                     │
│  ✅ Request ID propagation                                    │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Review all components
- Show how they work together
- Emphasize this is production-ready

---

#### Slide 1.1.15: Verification
**Title:** Testing Your Service

**Content:**
```bash
# Run the service
npm run dev

# Check health
curl http://localhost:3000/health
# Response: {"status":"ok","service":"gateway","version":"1.0.0"}

# Check readiness
curl http://localhost:3000/health/ready
# Response: {"status":"ready","uptime":"1m 32s"}

# Check metrics
curl http://localhost:3000/metrics
# Response: {"requestCount":0,"errorRate":0,"uptime":92}

# Test graceful shutdown
kill -TERM <PID>
# Logs should show graceful shutdown sequence
```

**Teaching Notes:**
- Run through each verification step
- Show expected outputs
- Demonstrate graceful shutdown

---

### PART 1.2: 12-Factor in Practice (15 Slides)

#### Slide 1.2.1: 12-Factor Overview
**Title:** The Twelve Factors

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                  12-FACTOR APP METHODOLOGY                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1.  Codebase ── One codebase tracked in revision control     │
│  2.  Dependencies ── Explicitly declare and isolate          │
│  3.  Config ── Store config in environment                   │
│  4.  Backing Services ── Treat as attached resources         │
│  5.  Build, Release, Run ── Strict separation               │
│  6.  Processes ── Execute as stateless processes            │
│  7.  Port Binding ── Export services via port binding       │
│  8.  Concurrency ── Scale out via process model             │
│  9.  Disposability ── Fast startup and graceful shutdown   │
│  10. Dev/Prod Parity ── Keep environments similar           │
│  11. Logs ── Treat logs as event streams                    │
│  12. Admin Processes ── Run admin tasks as one-off         │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Go through each factor with examples
- Explain why each matters
- Connect to restaurant analogy

---

#### Slide 1.2.2: Factor 3 - Config
**Title:** Config in Environment

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│               STORE CONFIG IN ENVIRONMENT                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ❌ BAD: Hardcoded config                                      │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ const DB_HOST = 'localhost';                          │   │
│  │ const DB_PORT = 5432;                                 │   │
│  │ const DB_PASSWORD = 'password123';                   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ✅ GOOD: Environment variables                                │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ const DB_HOST = process.env.DB_HOST;                  │   │
│  │ const DB_PORT = process.env.DB_PORT;                  │   │
│  │ const DB_PASSWORD = process.env.DB_PASSWORD;          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Benefits:                                                      │
│  • Same code works everywhere                                 │
│  • No config files in repo                                    │
│  • Easy to rotate secrets                                     │
│  • Environment-specific without code changes                 │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Show the problem with hardcoded config
- Demonstrate .env files
- Discuss secrets management

---

#### Slide 1.2.3: Factor 4 - Backing Services
**Title:** Backing Services as Attached Resources

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│              BACKING SERVICES AS RESOURCES                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  DATABASE_URL=postgresql://host:5432/db               │   │
│  │  REDIS_URL=redis://host:6379                          │   │
│  │  RABBITMQ_URL=amqp://host:5672                       │   │
│  │  S3_URL=s3://bucket                                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Benefits:                                                      │
│  • Swap services without code changes                         │
│  • Development vs Production can use different services      │
│  • Easy to switch cloud providers                            │
│  • Services can be scaled independently                     │
│                                                                 │
│  Restaurant Analogy: Switch suppliers without changing recipe │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Show connection strings
- Explain how to swap services
- Demonstrate dev/prod parity

---

#### Slide 1.2.4: Factor 5 - Build, Release, Run
**Title:** Strict Separation of Stages

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                  BUILD, RELEASE, RUN                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐     │
│  │    BUILD     │───▶│   RELEASE    │───▶│     RUN      │     │
│  │  (Compile,   │    │  (Package,   │    │  (Execute    │     │
│  │   Test)      │    │   Deploy)    │    │   Process)   │     │
│  └──────────────┘    └──────────────┘    └──────────────┘     │
│                                                                 │
│  Docker Multi-Stage Build:                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  # Build Stage                                         │   │
│  │  FROM node:20-alpine AS builder                       │   │
│  │  COPY . .                                            │   │
│  │  RUN npm install && npm run build                    │   │
│  │                                                      │   │
│  │  # Release Stage                                     │   │
│  │  FROM node:20-alpine                                │   │
│  │  COPY --from=builder /app/dist ./dist              │   │
│  │  COPY --from=builder /app/node_modules ./node_modules│   │
│  │  CMD ["node", "dist/index.js"]                     │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain each stage
- Show Docker multi-stage build
- Discuss why separation matters

---

#### Slide 1.2.5: Factor 6 - Stateless Processes
**Title:** Processes Are Stateless and Share-Nothing

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│              STATELESS PROCESSES                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ❌ BAD: Storing state in memory                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  const sessions = new Map();                           │   │
│  │  sessions.set(userId, sessionData);                    │   │
│  │  // Lost if process restarts                           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ✅ GOOD: State in backing service                            │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  await redis.set(`session:${userId}`, sessionData);   │   │
│  │  // Survives process restart                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Benefits:                                                      │
│  • Horizontal scaling                                         │
│  • Rollback safe                                              │
│  • Fault tolerant                                             │
│  • No "sticky sessions" needed                               │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Show the problem with in-memory state
- Demonstrate external state storage
- Explain scaling implications

---

#### Slide 1.2.6: Factor 8 - Port Binding
**Title:** Export Services via Port Binding

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                   PORT BINDING                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ❌ BAD: Hardcoded port                                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  app.listen(3000);                                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ✅ GOOD: Port from environment                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  const PORT = process.env.PORT || 3000;               │   │
│  │  app.listen(PORT, process.env.HOST || '0.0.0.0');    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Cloud-Native Pattern:                                         │
│  • Externalize port                                            │
│  • Cloud platforms assign ports                                │
│  • Multiple instances can bind to different ports             │
│  • Load balancer routes to instances                          │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Show environment-based port binding
- Explain cloud-native port assignment

---

#### Slide 1.2.7: Factor 9 - Disposability
**Title:** Fast Startup and Graceful Shutdown

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                  DISPOSABILITY                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ✅ Fast Startup (Seconds, not minutes)                        │
│  • Minimal initialization                                      │
│  • Lazy connections                                            │
│  • No long-running init tasks                                 │
│                                                                 │
│  ✅ Graceful Shutdown                                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  process.on('SIGTERM', async () => {                   │   │
│  │    // 1. Stop accepting new requests                   │   │
│  │    await server.close();                               │   │
│  │    // 2. Finish existing requests                      │   │
│  │    await waitForConnections();                         │   │
│  │    // 3. Clean up resources                            │   │
│  │    await database.disconnect();                       │   │
│  │    process.exit(0);                                   │   │
│  │  });                                                  │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain why fast startup matters (scaling, rollback)
- Demonstrate graceful shutdown sequence
- Show timeout handling

---

#### Slide 1.2.8: Factor 11 - Logs as Event Streams
**Title:** Logs as Event Streams

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│              LOGS AS EVENT STREAMS                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ❌ BAD: Writing to files                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  fs.appendFileSync('/var/log/app.log', message);     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ✅ GOOD: Log to stdout/stderr                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  console.log(JSON.stringify({                          │   │
│  │    level: 'info',                                     │   │
│  │    message: 'User logged in',                         │   │
│  │    userId: '123',                                    │   │
│  │    timestamp: new Date().toISOString(),              │   │
│  │  }));                                                │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Benefits:                                                      │
│  • Platform captures logs                                     │
│  • Structured (JSON) for parsing                              │
│  • Centralized aggregation                                    │
│  • No file rotation issues                                   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Show structured logging
- Explain why stdout/stderr
- Demonstrate log aggregation

---

#### Slide 1.2.9: Factor 12 - Admin Processes
**Title:** Admin Tasks as One-Off Processes

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│              ADMIN PROCESSES                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Example Admin Tasks:                                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  • Database migrations                                 │   │
│  │  • Data seeding                                        │   │
│  │  • Health checks                                       │   │
│  │  • Report generation                                   │   │
│  │  • Data cleanup                                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Implementation:                                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  // Run as: npm run admin:db-migrate                   │   │
│  │  // admin/db-migrate.ts                               │   │
│  │  async function main() {                              │   │
│  │    await connectDatabase();                           │   │
│  │    await runMigrations();                             │   │
│  │    process.exit(0);                                  │   │
│  │  }                                                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Key Principle: Same codebase, different entry point          │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Show admin script examples
- Explain one-off nature
- Demonstrate separation from main process

---

#### Slide 1.2.10: Putting 12-Factor Together
**Title:** Complete 12-Factor Service

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│              12-FACTOR COMPLIANT SERVICE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ✅ Codebase: One git repo                                     │
│  ✅ Dependencies: package.json (explicit)                     │
│  ✅ Config: Environment variables                             │
│  ✅ Backing Services: DATABASE_URL, REDIS_URL                 │
│  ✅ Build/Release/Run: Docker multi-stage                    │
│  ✅ Stateless: All state in backing services                  │
│  ✅ Port Binding: process.env.PORT                           │
│  ✅ Concurrency: Horizontal scaling                          │
│  ✅ Disposability: Fast start, graceful shutdown             │
│  ✅ Dev/Prod Parity: Same container image                    │
│  ✅ Logs: JSON to stdout                                     │
│  ✅ Admin: One-off scripts                                  │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Review all factors
- Show how they work together
- Emphasize this is production-ready

---

## PHASE 2: STRUCTURAL FOUNDATIONS (40 Slides)

### PART 2.1: Hexagonal Architecture (20 Slides)

#### Slide 2.1.1: What is Hexagonal Architecture?
**Title:** Ports & Adapters Architecture

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 HEXAGONAL ARCHITECTURE                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│                    ┌─────────────────────────────────┐         │
│                    │      EXTERNAL WORLD             │         │
│                    │  (HTTP, Database, Queues, etc.) │         │
│                    └─────────────────────────────────┘         │
│                            │           │                       │
│                            ▼           ▼                       │
│                   ┌─────────────────────────────┐              │
│                   │      ADAPTERS               │              │
│                   │  (Controllers, Repositories, │              │
│                   │   Clients, etc.)            │              │
│                   └─────────────────────────────┘              │
│                            │           │                       │
│                            ▼           ▼                       │
│                   ┌─────────────────────────────┐              │
│                   │         PORTS               │              │
│                   │  (Interfaces/Contracts)     │              │
│                   └─────────────────────────────┘              │
│                            │           │                       │
│                            ▼           ▼                       │
│          ┌─────────────────────────────────────────────────┐   │
│          │                APPLICATION CORE                 │   │
│          │  ┌───────────────────────────────────────────┐  │   │
│          │  │          DOMAIN LAYER                    │  │   │
│          │  │  (Entities, Business Logic, Rules)       │  │   │
│          │  └───────────────────────────────────────────┘  │   │
│          │  ┌───────────────────────────────────────────┐  │   │
│          │  │       APPLICATION LAYER                  │  │   │
│          │  │  (Use Cases, Commands, Queries)          │  │   │
│          │  └───────────────────────────────────────────┘  │   │
│          └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain the "onion" concept
- Point out dependency direction (inward)
- Use the "kitchen" analogy

---

#### Slide 2.1.2: Dependency Inversion Principle
**Title:** The Most Important Principle

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│              DEPENDENCY INVERSION PRINCIPLE                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Traditional (BAD):                                            │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐       │
│  │   UI Layer  │───▶│ Business    │───▶│  Data       │       │
│  │             │    │  Layer      │    │  Layer      │       │
│  └─────────────┘    └─────────────┘    └─────────────┘       │
│                                                                 │
│  Hexagonal (GOOD):                                             │
│  ┌─────────────┐         ┌─────────────┐         ┌──────────┐ │
│  │   UI        │◀────────│   Ports     │◀────────│  Domain  │ │
│  │  Adapter    │         │  (Abstract) │         │  Core    │ │
│  └─────────────┘         └─────────────┘         └──────────┘ │
│        │                       ▲                       ▲        │
│        ▼                       │                       │        │
│  ┌─────────────┐         ┌─────────────┐         ┌──────────┐ │
│  │  Database   │─────────│   Ports     │─────────│  Domain  │ │
│  │  Adapter    │         │  (Abstract) │         │  Core    │ │
│  └─────────────┘         └─────────────┘         └──────────┘ │
│                                                                 │
│  KEY: Dependencies point INWARD                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Show the two diagrams side by side
- Explain why dependencies should point inward
- Use the restaurant manager analogy

---

#### Slide 2.1.3: Domain Entities
**Title:** The Heart of Your Application

**Content:**
```typescript
// Pure business logic - no infrastructure
export class User {
    private _email: string;
    private _name: string;
    private _isActive: boolean;

    constructor(email: string, name: string) {
        this.setEmail(email);
        this._name = name;
        this._isActive = true;
    }

    // Business rule: Email must be valid
    private setEmail(email: string): void {
        if (!this.isValidEmail(email)) {
            throw new Error('Invalid email format');
        }
        this._email = email;
    }

    // Business rule: Only active users can update
    updateName(newName: string): void {
        if (!this._isActive) {
            throw new Error('Cannot update inactive user');
        }
        this._name = newName;
    }

    private isValidEmail(email: string): boolean {
        return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
    }
}
```

**Teaching Notes:**
- Emphasize: Business rules ONLY
- No dependencies on infrastructure
- Show validation examples

---

#### Slide 2.1.4: Repository Port (Interface)
**Title:** The Repository Pattern

**Content:**
```typescript
// PORT: The contract the domain depends on
export interface IUserRepository {
    save(user: User): Promise<User>;
    findById(id: string): Promise<User | null>;
    findByEmail(email: string): Promise<User | null>;
    delete(id: string): Promise<boolean>;
    existsByEmail(email: string): Promise<boolean>;
}

// Implementation: PostgreSQL Adapter
export class PostgresUserRepository implements IUserRepository {
    async save(user: User): Promise<User> {
        const query = `
            INSERT INTO users (id, email, name, is_active)
            VALUES ($1, $2, $3, $4)
            ON CONFLICT (id) DO UPDATE
            SET email = $2, name = $3, is_active = $4
            RETURNING *
        `;
        const result = await this.db.query(query, [
            user.id,
            user.email,
            user.name,
            user.isActive,
        ]);
        return this.mapRowToUser(result.rows[0]);
    }
}
```

**Teaching Notes:**
- Show interface first (port)
- Show implementation (adapter)
- Explain why domain depends on interface

---

#### Slide 2.1.5: Domain Services
**Title:** Complex Business Logic

**Content:**
```typescript
// Domain Service: Orchestrates entities and business rules
export class UserDomainService {
    constructor(private readonly userRepository: IUserRepository) {}

    async registerUser(props: UserProps): Promise<User> {
        // 1. Check uniqueness
        if (await this.userRepository.existsByEmail(props.email)) {
            throw new Error('Email already registered');
        }
        if (await this.userRepository.existsByUsername(props.username)) {
            throw new Error('Username already taken');
        }

        // 2. Create entity (business rules enforced)
        const user = new User(props);

        // 3. Save
        return await this.userRepository.save(user);
    }

    async deactivateUser(id: string): Promise<void> {
        const user = await this.userRepository.findById(id);
        if (!user) {
            throw new Error('User not found');
        }
        // Business rule: Can't deactivate twice
        user.deactivate();
        await this.userRepository.save(user);
    }
}
```

**Teaching Notes:**
- Explain when to use domain services
- Show orchestration of multiple entities
- Emphasize business rules

---

#### Slide 2.1.6: CQRS - Commands and Queries
**Title:** Separating Reads and Writes

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                      CQRS                                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────────┐    ┌──────────────────────────┐  │
│  │    COMMAND SIDE          │    │    QUERY SIDE            │  │
│  │    (Write)               │    │    (Read)                │  │
│  ├──────────────────────────┤    ├──────────────────────────┤  │
│  │  • Commands             │    │  • Queries              │  │
│  │  • Validates input      │    │  • Optimized for reads  │  │
│  │  • Business logic       │    │  • Denormalized data    │  │
│  │  • Produces events      │    │  • Fast responses       │  │
│  └──────────────────────────┘    └──────────────────────────┘  │
│         │                              ▲                       │
│         ▼                              │                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              EVENT STORE                               │   │
│  │  (Source of truth - immutable event log)              │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain why separate read/write models
- Show command example
- Show query example

---

#### Slide 2.1.7: Commands Example
**Title:** Write Operations

**Content:**
```typescript
// Command: Represents user intention
export class CreateUserCommand {
    public readonly email: string;
    public readonly username: string;
    public readonly name: string;

    private constructor(props: { email: string; username: string; name: string }) {
        this.email = props.email;
        this.username = props.username;
        this.name = props.name;
    }

    // Factory with validation
    static create(data: unknown): CreateUserCommand {
        const schema = z.object({
            email: z.string().email(),
            username: z.string().min(3).max(30),
            name: z.string().min(1).max(100),
        });
        const validated = schema.parse(data);
        return new CreateUserCommand(validated);
    }
}

// Command Handler
export class UserCommandHandler {
    constructor(private readonly userService: UserDomainService) {}

    async handleCreateUser(command: CreateUserCommand): Promise<User> {
        return await this.userService.registerUser({
            email: command.email,
            username: command.username,
            name: command.name,
        });
    }
}
```

**Teaching Notes:**
- Show command validation
- Show handler orchestration
- Explain separation of concerns

---

#### Slide 2.1.8: Queries Example
**Title:** Read Operations

**Content:**
```typescript
// Query: Represents a read operation
export class GetUserQuery {
    public readonly userId: string;

    private constructor(userId: string) {
        this.userId = userId;
    }

    static create(data: unknown): GetUserQuery {
        const schema = z.object({
            userId: z.string().uuid(),
        });
        const validated = schema.parse(data);
        return new GetUserQuery(validated.userId);
    }
}

// Query Handler (uses read model)
export class UserQueryHandler {
    constructor(private readonly userReadModel: UserReadModel) {}

    async handleGetUser(query: GetUserQuery): Promise<UserDTO | null> {
        // Read from optimized read model
        return await this.userReadModel.findById(query.userId);
    }
}

// Read Model: Denormalized for fast reads
export class UserReadModel {
    async findById(id: string): Promise<UserDTO | null> {
        const result = await this.db.query(
            'SELECT * FROM user_read_model WHERE id = $1',
            [id]
        );
        return result.rows[0] ? this.mapToDTO(result.rows[0]) : null;
    }
}
```

**Teaching Notes:**
- Show query validation
- Show read model usage
- Explain denormalization

---

#### Slide 2.1.9: Dependency Injection
**Title:** Wiring Everything Together

**Content:**
```typescript
// DI Container
export class Container {
    private static instance: Container;
    private services: Map<string, any> = new Map();

    static getInstance(): Container {
        if (!Container.instance) {
            Container.instance = new Container();
        }
        return Container.instance;
    }

    configure(): void {
        // Repositories (Adapters)
        this.services.set('IUserRepository', new PostgresUserRepository());
        this.services.set('IEventPublisher', new EventPublisher());

        // Domain Services
        this.services.set('UserDomainService', new UserDomainService(
            this.services.get('IUserRepository')
        ));

        // Command Handlers
        this.services.set('UserCommandHandler', new UserCommandHandler(
            this.services.get('UserDomainService')
        ));

        // Query Handlers
        this.services.set('UserQueryHandler', new UserQueryHandler(
            this.services.get('UserReadModel')
        ));

        // Controllers
        this.services.set('UserController', new UserController(
            this.services.get('UserCommandHandler'),
            this.services.get('UserQueryHandler')
        ));
    }

    resolve<T>(key: string): T {
        return this.services.get(key) as T;
    }
}
```

**Teaching Notes:**
- Show how dependencies are wired
- Explain the composition root
- Demonstrate clean separation

---

#### Slide 2.1.10: Testing in Hexagonal Architecture
**Title:** Why This Architecture is Testable

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 TESTING IN HEXAGONAL ARCHITECTURE              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  UNIT TESTS: Domain Layer                                      │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  • Test business logic without infrastructure          │   │
│  │  • Mock all ports                                      │   │
│  │  • Fast and isolated                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  INTEGRATION TESTS: Application Layer                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  • Test use cases                                       │   │
│  │  • Use test implementations of ports                   │   │
│  │  • In-memory repositories                               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  E2E TESTS: Adapters                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  • Test full system                                     │   │
│  │  • Real databases and services                         │   │
│  │  • Fewer, focused tests                               │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Show each test layer
- Explain why domain is easy to test
- Demonstrate with examples

---

### PART 2.2: PostgreSQL Integration (10 Slides)

#### Slide 2.2.1: Database Schema
**Title:** PostgreSQL Schema for Users and Tasks

**Content:**
```sql
-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Tasks Table
CREATE TABLE tasks (
    id UUID PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id),
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    due_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB DEFAULT '{}'::jsonb
);

-- Indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_user_status ON tasks(user_id, status);
```

**Teaching Notes:**
- Go through each table
- Explain relationships
- Show indexing strategy

---

#### Slide 2.2.2: Connection Pooling
**Title:** Managing Database Connections

**Content:**
```typescript
import { Pool } from 'pg';

const pool = new Pool({
    host: process.env.DB_HOST,
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    max: 20,              // Maximum connections
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
    maxUses: 7500,        // Recycle connections
});

// Monitor pool
pool.on('acquire', () => {
    console.log('Pool acquire', pool.totalCount, pool.idleCount);
});

// Use pool
async function query(sql: string, params?: any[]) {
    const client = await pool.connect();
    try {
        return await client.query(sql, params);
    } finally {
        client.release(); // Always release!
    }
}
```

**Teaching Notes:**
- Explain why pooling matters
- Show configuration options
- Demonstrate proper release

---

#### Slide 2.2.3: PostgreSQL Repository
**Title:** Implementing the Repository

**Content:**
```typescript
export class PostgresUserRepository implements IUserRepository {
    async save(user: User): Promise<User> {
        const query = `
            INSERT INTO users (id, email, username, first_name, last_name, password_hash, created_at, updated_at, is_active)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            ON CONFLICT (id) DO UPDATE
            SET email = $2, username = $3, first_name = $4, last_name = $5, updated_at = $8, is_active = $9
            RETURNING *
        `;
        
        const result = await this.db.query(query, [
            user.id,
            user.email,
            user.username,
            user.firstName,
            user.lastName,
            user.passwordHash,
            user.createdAt,
            user.updatedAt,
            user.isActive,
        ]);
        
        return this.mapRowToUser(result.rows[0]);
    }

    private mapRowToUser(row: any): User {
        return new User({
            id: row.id,
            email: row.email,
            username: row.username,
            firstName: row.first_name,
            lastName: row.last_name,
            passwordHash: row.password_hash,
            createdAt: row.created_at,
            updatedAt: row.updated_at,
            isActive: row.is_active,
        });
    }
}
```

**Teaching Notes:**
- Show the mapping between domain and database
- Explain ON CONFLICT for upsert
- Demonstrate error handling

---

#### Slide 2.2.4: Database Migrations
**Title:** Managing Schema Changes

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 DATABASE MIGRATIONS                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  migrations/                                                    │
│  ├── 001_initial_schema.sql                                    │
│  ├── 002_add_indexes.sql                                       │
│  └── 003_event_store.sql                                       │
│                                                                 │
│  migrations table:                                              │
│  ┌────┬──────────────────────┬─────────────────────┐           │
│  │ id │ name                 │ executed_at         │           │
│  ├────┼──────────────────────┼─────────────────────┤           │
│  │ 1  │ 001_initial_schema   │ 2024-01-01 10:00:00 │           │
│  │ 2  │ 002_add_indexes      │ 2024-01-01 10:00:01 │           │
│  └────┴──────────────────────┴─────────────────────┘           │
│                                                                 │
│  Migration Runner:                                             │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  async function runMigrations() {                     │   │
│  │    const pending = getPendingMigrations();           │   │
│  │    for (const migration of pending) {                │   │
│  │      await executeMigration(migration);              │   │
│  │      await recordMigration(migration);               │   │
│  │    }                                                 │   │
│  │  }                                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain migration strategy
- Show how to run migrations
- Discuss rollback plans

---

### PART 2.3: Caching with Redis (10 Slides)

#### Slide 2.3.1: Redis Overview
**Title:** In-Memory Data Store

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                      REDIS                                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Features:                                                      │
│  • In-memory (fast)                                           │
│  • Data structures: String, Hash, List, Set, Sorted Set      │
│  • Persistence (optional)                                    │
│  • Pub/Sub                                                    │
│  • TTL (Time To Live)                                         │
│                                                                 │
│  Use Cases:                                                    │
│  • Caching                                                    │
│  • Session storage                                            │
│  • Rate limiting                                              │
│  • Distributed locking                                        │
│  • Message queues                                             │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain Redis features
- Show use cases
- Demonstrate basic commands

---

#### Slide 2.3.2: Redis Connection
**Title:** Connecting to Redis

**Content:**
```typescript
import Redis from 'ioredis';

const redis = new Redis({
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
    password: process.env.REDIS_PASSWORD,
    retryStrategy: (times) => {
        if (times > 3) {
            return null; // Stop retrying
        }
        return Math.min(times * 100, 3000);
    },
    maxRetriesPerRequest: 3,
});

// Event monitoring
redis.on('connect', () => console.log('Redis connected'));
redis.on('error', (error) => console.error('Redis error:', error));
redis.on('close', () => console.log('Redis connection closed'));

// Usage
await redis.set('key', 'value', 'EX', 60); // TTL 60 seconds
const value = await redis.get('key');
```

**Teaching Notes:**
- Show connection configuration
- Explain retry strategy
- Demonstrate event monitoring

---

#### Slide 2.3.3: Cache-Aside Pattern
**Title:** The Most Common Caching Pattern

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 CACHE-ASIDE PATTERN                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Client requests data                                       │
│         │                                                       │
│         ▼                                                       │
│  2. Check Cache                                                │
│         │                                                       │
│     ┌───┴───┐                                                  │
│     │       │                                                  │
│   Hit       Miss                                               │
│     │       │                                                  │
│     │       ▼                                                  │
│     │   3. Query Database                                      │
│     │       │                                                  │
│     │       ▼                                                  │
│     │   4. Store in Cache                                      │
│     │       │                                                  │
│     ▼       ▼                                                  │
│  5. Return data                                                │
│                                                                 │
│  Code:                                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  async function getUser(id: string): Promise<User> {  │   │
│  │    const cached = await redis.get(`user:${id}`);     │   │
│  │    if (cached) return JSON.parse(cached);            │   │
│  │                                                       │   │
│  │    const user = await db.query('SELECT * FROM users WHERE id = $1', [id]); │
│  │    await redis.set(`user:${id}`, JSON.stringify(user), 'EX', 300); │
│  │    return user;                                      │   │
│  │  }                                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Walk through the flow diagram
- Show the code implementation
- Discuss cache invalidation

---

#### Slide 2.3.4: Cache Invalidation
**Title:** Keeping Cache Fresh

**Content:**
```typescript
class CacheInvalidation {
    // 1. TTL-Based Invalidation
    async setWithTTL(key: string, value: any, ttl: number = 300): Promise<void> {
        await redis.set(key, JSON.stringify(value), 'EX', ttl);
    }

    // 2. Event-Based Invalidation
    async invalidateOnUpdate(entityType: string, entityId: string): Promise<void> {
        const keys = [
            `${entityType}:${entityId}`,
            `${entityType}s:${entityId}`,
            `${entityType}:list:*`,
        ];
        await Promise.all(keys.map(key => redis.del(key)));
    }

    // 3. Version-Based Invalidation
    async setWithVersion(key: string, value: any, version: number): Promise<void> {
        const versionKey = `${key}:version`;
        const currentVersion = await redis.get(versionKey);
        if (currentVersion && parseInt(currentVersion) > version) {
            // Ignore stale updates
            return;
        }
        await redis.set(key, JSON.stringify(value));
        await redis.set(versionKey, version);
    }
}
```

**Teaching Notes:**
- Explain each invalidation strategy
- Show when to use each
- Demonstrate trade-offs

---

#### Slide 2.3.5: Multi-Level Cache
**Title:** L1 (Memory) + L2 (Redis)

**Content:**
```typescript
class MultiLevelCache {
    private l1Cache = new Map<string, { value: any; expires: number }>();
    private l1TTL = 10000; // 10 seconds
    private l2Cache = new Redis({ /* config */ });
    private stats = { l1Hit: 0, l1Miss: 0, l2Hit: 0, l2Miss: 0 };

    async get(key: string): Promise<any | null> {
        // Check L1 (in-memory)
        const l1 = this.l1Cache.get(key);
        if (l1 && l1.expires > Date.now()) {
            this.stats.l1Hit++;
            return l1.value;
        }
        this.stats.l1Miss++;

        // Check L2 (Redis)
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

    async set(key: string, value: any): Promise<void> {
        this.l1Cache.set(key, {
            value,
            expires: Date.now() + this.l1TTL,
        });
        await this.l2Cache.set(key, JSON.stringify(value), 'EX', 300);
    }

    getStats() {
        const total = this.stats.l1Hit + this.stats.l1Miss + this.stats.l2Hit + this.stats.l2Miss;
        return {
            hitRate: (this.stats.l1Hit + this.stats.l2Hit) / total || 0,
            l1HitRate: this.stats.l1Hit / (this.stats.l1Hit + this.stats.l1Miss) || 0,
            l2HitRate: this.stats.l2Hit / (this.stats.l2Hit + this.stats.l2Miss) || 0,
        };
    }
}
```

**Teaching Notes:**
- Explain why multi-level caching matters
- Show the performance benefits
- Demonstrate trade-offs

---

## PHASE 3: DISTRIBUTED SYSTEMS (30 Slides)

### PART 3.1: Distributed Patterns (15 Slides)

#### Slide 3.1.1: Distributed Systems Overview
**Title:** Why Distributed Systems?

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│              WHY DISTRIBUTED SYSTEMS?                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Benefits:                                                      │
│  • Scalability ── Add more nodes to handle load              │
│  • Fault Tolerance ── System survives node failures           │
│  • Geography ── Serve users from nearby locations            │
│  • Team Autonomy ── Independent service teams                │
│                                                                 │
│  Challenges:                                                   │
│  • Network Latency ── Communication is slow                   │
│  • Partial Failures ── Some services work, some don't        │
│  • Consistency ── Keeping data in sync across services       │
│  • Complexity ── Debugging is harder                         │
│                                                                 │
│  The Fallacies of Distributed Computing:                      │
│  1. The network is reliable                                   │
│  2. Latency is zero                                           │
│  3. Bandwidth is infinite                                     │
│  4. The network is secure                                     │
│  5. Topology doesn't change                                   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Discuss benefits and challenges
- Explain the "fallacies"
- Set realistic expectations

---

#### Slide 3.1.2: API Composition
**Title:** The Distributed Promise.all

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 API COMPOSITION                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Sequential (BAD):                                            │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  const user = await userService.getUser(userId);      │   │
│  │  const tasks = await taskService.getTasks(userId);    │   │
│  │  const stats = await statsService.getStats(userId);   │   │
│  │  // Total: 300ms                                      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Parallel (GOOD):                                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  const [user, tasks, stats] = await Promise.all([     │   │
│  │    userService.getUser(userId),                       │   │
│  │    taskService.getTasks(userId),                      │   │
│  │    statsService.getStats(userId),                     │   │
│  │  ]);                                                  │   │
│  │  // Total: MAX(100ms, 100ms, 100ms) = 100ms           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Code:                                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  async function getUserDashboard(userId: string) {    │   │
│  │    const composition = new ApiComposition();         │   │
│  │    return await composition.compose({                │   │
│  │      user: () => userService.getUser(userId),       │   │
│  │      tasks: () => taskService.getTasks(userId),     │   │
│  │      stats: () => statsService.getStats(userId),    │   │
│  │    });                                               │   │
│  │  }                                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Show the performance difference
- Explain parallel execution
- Demonstrate error handling

---

#### Slide 3.1.3: Circuit Breaker
**Title:** Preventing Cascading Failures

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 CIRCUIT BREAKER                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  States:                                                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  CLOSED ──▶ Request flows through                     │   │
│  │  OPEN ──▶ Requests fail immediately (fast fail)       │   │
│  │  HALF_OPEN ──▶ Test if service recovered             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Transition:                                                   │
│  ┌─────────────┐    Success    ┌─────────────┐                │
│  │   CLOSED    │──────────────▶│   CLOSED    │                │
│  └─────────────┘               └─────────────┘                │
│         │                              ▲                       │
│         │ Failure (5x)                │                        │
│         ▼                              │                       │
│  ┌─────────────┐    Timeout     ┌─────────────┐                │
│  │    OPEN     │───────────────▶│  HALF_OPEN  │                │
│  └─────────────┘                └─────────────┘                │
│                                                                 │
│  Code:                                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  const breaker = new CircuitBreaker({                  │   │
│  │    failureThreshold: 5,                               │   │
│  │    resetTimeout: 60000,                               │   │
│  │  });                                                  │   │
│  │                                                       │   │
│  │  try {                                                │   │
│  │    const result = await breaker.execute(() =>        │   │
│  │      service.call()                                  │   │
│  │    );                                                │   │
│  │  } catch (error) {                                    │   │
│  │    // Fallback                                      │   │
│  │  }                                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain the state machine
- Show the transition rules
- Discuss fallback strategies

---

#### Slide 3.1.4: Saga Pattern
**Title:** Distributed Transactions

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                      SAGA PATTERN                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Choreographed Saga:                                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Order Service ──▶ Payment Service ──▶ Inventory      │   │
│  │      │                    │                    │        │   │
│  │      ▼                    ▼                    ▼        │   │
│  │  (Rollback)          (Rollback)          (Rollback)   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Orchestrated Saga:                                            │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                   Orchestrator                         │   │
│  │                    │                                    │   │
│  │     ┌──────────────┼──────────────┐                    │   │
│  │     ▼              ▼              ▼                    │   │
│  │  Order          Payment        Inventory               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Code:                                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  const saga = new Saga();                             │   │
│  │  saga.addStep({                                       │   │
│  │    name: 'reserve_inventory',                         │   │
│  │    execute: () => inventoryService.reserve(),        │   │
│  │    compensate: () => inventoryService.release(),     │   │
│  │  });                                                  │   │
│  │  saga.addStep({                                       │   │
│  │    name: 'process_payment',                          │   │
│  │    execute: () => paymentService.charge(),          │   │
│  │    compensate: () => paymentService.refund(),       │   │
│  │  });                                                  │   │
│  │  await saga.execute();                               │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain both approaches
- Show compensation logic
- Discuss when to use each

---

#### Slide 3.1.5: Retry with Exponential Backoff
**Title:** Handling Transient Failures

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│              RETRY WITH EXPONENTIAL BACKOFF                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Backoff Pattern:                                              │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Attempt 1: 1s                                        │   │
│  │  Attempt 2: 2s                                        │   │
│  │  Attempt 3: 4s                                        │   │
│  │  Attempt 4: 8s                                        │   │
│  │  Attempt 5: 16s                                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Code:                                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  class RetryManager {                                 │   │
│  │    async execute<T>(operation: () => Promise<T>) {   │   │
│  │      let attempt = 0;                                │   │
│  │      let delay = 1000;                              │   │
│  │                                                       │   │
│  │      while (attempt < this.maxRetries) {            │   │
│  │        try {                                         │   │
│  │          return await operation();                  │   │
│  │        } catch (error) {                            │   │
│  │          if (!this.shouldRetry(error)) throw error;│   │
│  │          await this.sleep(delay + jitter);          │   │
│  │          delay *= this.backoffMultiplier;          │   │
│  │          attempt++;                                 │   │
│  │        }                                            │   │
│  │      }                                              │   │
│  │    }                                                │   │
│  │  }                                                  │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain why backoff is needed
- Show jitter addition
- Discuss retryable errors

---

### PART 3.2: Request Context & Cancellation (15 Slides)

#### Slide 3.2.1: Request Context
**Title:** Propagating Context Across Services

**Content:**
```typescript
import { AsyncLocalStorage } from 'async_hooks';

interface RequestContext {
    requestId: string;
    userId?: string;
    correlationId: string;
    startTime: number;
    timeout: number;
    headers: Record<string, string>;
}

class RequestContextManager {
    private static storage = new AsyncLocalStorage<RequestContext>();

    static run<T>(context: RequestContext, fn: () => T): T {
        return this.storage.run(context, fn);
    }

    static getContext(): RequestContext | null {
        return this.storage.getStore() || null;
    }

    static getRequestId(): string {
        return this.getContext()?.requestId || 'unknown';
    }

    static getPropagationHeaders(): Record<string, string> {
        const context = this.getContext();
        if (!context) return {};
        
        return {
            'x-request-id': context.requestId,
            'x-correlation-id': context.correlationId,
            'x-user-id': context.userId || '',
        };
    }
}

// Middleware
async function contextMiddleware(request, reply) {
    const context = RequestContextManager.createContext({
        requestId: request.headers['x-request-id'] || randomUUID(),
        correlationId: request.headers['x-correlation-id'] || randomUUID(),
        headers: request.headers,
        userId: request.headers['x-user-id'],
    });
    
    RequestContextManager.run(context, () => {
        reply.header('x-request-id', context.requestId);
        // Continue request
    });
}
```

**Teaching Notes:**
- Explain AsyncLocalStorage
- Show context propagation
- Demonstrate use in logging

---

#### Slide 3.2.2: AbortController
**Title:** Request Cancellation

**Content:**
```typescript
// Create cancellation
const controller = new AbortController();
const signal = controller.signal;

// Execute with cancellation
async function fetchWithTimeout(url: string, timeout: number) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
        const response = await fetch(url, { signal: controller.signal });
        return response.json();
    } finally {
        clearTimeout(timeoutId);
    }
}

// Propagate cancellation
class CancellableRequest {
    private controller = new AbortController();

    async execute(operation: (signal: AbortSignal) => Promise<any>): Promise<any> {
        try {
            return await operation(this.controller.signal);
        } catch (error) {
            if (error.name === 'AbortError') {
                throw new Error('Request cancelled');
            }
            throw error;
        }
    }

    cancel(): void {
        this.controller.abort();
    }
}

// Usage
const request = new CancellableRequest();
const result = request.execute(async (signal) => {
    const response = await fetch(url, { signal });
    return response.json();
});

// Cancel if needed
setTimeout(() => request.cancel(), 5000);
```

**Teaching Notes:**
- Explain AbortController
- Show cancellation propagation
- Demonstrate timeout handling

---

#### Slide 3.2.3: Distributed Tracing
**Title:** Following Requests Across Services

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│              DISTRIBUTED TRACING                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Trace: user-request-123                                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Span: API Gateway (50ms)                             │   │
│  │    ├── Span: User Service (30ms)                     │   │
│  │    │   └── Span: Database Query (20ms)              │   │
│  │    ├── Span: Task Service (25ms)                    │   │
│  │    │   └── Span: Cache Hit (1ms)                   │   │
│  │    └── Span: Response (5ms)                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Code:                                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  class Tracer {                                       │   │
│  │    startSpan(name: string): Span {                   │   │
│  │      const span = new Span(name);                   │   │
│  │      // Store in context                            │   │
│  │      return span;                                   │   │
│  │    }                                                 │   │
│  │                                                       │   │
│  │    injectHeaders(span: Span): Record<string, string> { │   │
│  │      return {                                        │   │
│  │        'x-trace-id': span.traceId,                  │   │
│  │        'x-span-id': span.spanId,                   │   │
│  │      };                                             │   │
│  │    }                                                 │   │
│  │  }                                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain spans and traces
- Show header propagation
- Discuss performance analysis

---

## PHASE 4: CLOUD-NATIVE (25 Slides)

### PART 4.1: Serverless Deployment (15 Slides)

#### Slide 4.1.1: Serverless Overview
**Title:** What is Serverless?

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 SERVERLESS ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Traditional:                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Server (always running)                              │   │
│  │  Pay for uptime (24/7)                                │   │
│  │  Manual scaling                                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Serverless:                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Function (invoked on demand)                         │   │
│  │  Pay for execution time                               │   │
│  │  Auto-scaling                                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Benefits:                                                      │
│  • No server management                                       │
│  • Automatic scaling                                          │
│  • Pay per use                                               │
│  • Focus on code                                              │
│                                                                 │
│  Challenges:                                                   │
│  • Cold starts                                                │
│  • Execution limits                                           │
│  • Vendor lock-in                                             │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Compare traditional vs serverless
- Show benefits and challenges
- Explain cold starts

---

#### Slide 4.1.2: AWS Lambda
**Title:** Deploying to AWS Lambda

**Content:**
```typescript
// lambda.ts - Entry point for AWS Lambda
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';

let server: Server | null = null;

// Lazy initialization (reuse across invocations)
async function initialize(): Promise<void> {
    if (!server) {
        server = new Server();
        await server.start();
    }
}

export async function handler(
    event: APIGatewayProxyEvent,
    context: Context
): Promise<APIGatewayProxyResult> {
    const startTime = Date.now();
    const requestId = event.headers['x-request-id'] || context.awsRequestId;

    try {
        // Lazy init
        await initialize();

        // Process request
        const result = await server!.handle(event);

        return {
            statusCode: 200,
            headers: {
                'content-type': 'application/json',
                'x-request-id': requestId,
            },
            body: JSON.stringify(result),
        };
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({ error: error.message }),
        };
    }
}
```

**Teaching Notes:**
- Show Lambda entry point
- Explain lazy initialization
- Discuss cold start mitigation

---

#### Slide 4.1.3: Cold Start Optimization
**Title:** Mitigating Cold Starts

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│              COLD START OPTIMIZATION                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Strategies:                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  1. Keep Bundle Small                                  │   │
│  │     • Tree shaking                                     │   │
│  │     • Minification                                     │   │
│  │     • Fewer dependencies                               │   │
│  │                                                       │   │
│  │  2. Lazy Initialization                              │   │
│  │     • Initialize outside handler                     │   │
│  │     • Connect to DB on first request                 │   │
│  │     • Use connection pooling                         │   │
│  │                                                       │   │
│  │  3. Provisioned Concurrency                          │   │
│  │     • Keep instances warm                            │   │
│  │     • Higher cost                                    │   │
│  │     • Predictable latency                            │   │
│  │                                                       │   │
│  │  4. Smaller Runtime                                 │   │
│  │     • Use Node.js 18+                               │   │
│  │     • Avoid large frameworks                        │   │
│  │     • Optimize startup time                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Code:                                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  // Initialize outside handler                        │   │
│  │  const db = new Database();  // Reused across calls   │   │
│  │  const cache = new Cache();   // Reused               │   │
│  │                                                       │   │
│  │  export async function handler(event) {              │   │
│  │    // db and cache are already initialized           │   │
│  │    return await processRequest(event);              │   │
│  │  }                                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain each strategy
- Show optimization examples
- Discuss trade-offs

---

#### Slide 4.1.4: Cloudflare Workers
**Title:** Edge Computing with Workers

**Content:**
```typescript
// worker.ts - Cloudflare Worker
import { Server } from './server.js';

let server: Server | null = null;

export default {
    async fetch(request: Request, env: any, ctx: any): Promise<Response> {
        const url = new URL(request.url);
        const requestId = request.headers.get('x-request-id') || crypto.randomUUID();

        try {
            // Lazy initialization
            if (!server) {
                server = new Server();
            }

            // Process request at the edge
            const result = await server.handle(request);

            return new Response(JSON.stringify(result), {
                headers: {
                    'content-type': 'application/json',
                    'x-request-id': requestId,
                    'Cache-Control': 'public, max-age=300',
                },
            });
        } catch (error) {
            return new Response(
                JSON.stringify({ error: error.message }),
                { status: 500 }
            );
        }
    },
};
```

**Teaching Notes:**
- Show Worker entry point
- Explain edge computing benefits
- Demonstrate cache headers

---

### PART 4.2: CDN & Edge Caching (10 Slides)

#### Slide 4.2.1: CDN Architecture
**Title:** Content Delivery Network

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                    CDN ARCHITECTURE                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    ORIGIN SERVER                       │   │
│  │                    (US East)                           │   │
│  └─────────────────────────────────────────────────────────┘   │
│                         │                                       │
│         ┌───────────────┼───────────────┐                      │
│         │               │               │                      │
│         ▼               ▼               ▼                      │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐                 │
│  │ Edge      │  │ Edge      │  │ Edge      │                 │
│  │ Location  │  │ Location  │  │ Location  │                 │
│  │ (Tokyo)   │  │ (London)  │  │ (NY)      │                 │
│  └───────────┘  └───────────┘  └───────────┘                 │
│         │               │               │                      │
│         ▼               ▼               ▼                      │
│  ┌───────────┐  ┌───────────┐  ┌───────────┐                 │
│  │ User in   │  │ User in   │  │ User in   │                 │
│  │ Tokyo     │  │ London    │  │ NY        │                 │
│  │ <5ms      │  │ <5ms      │  │ <5ms      │                 │
│  └───────────┘  └───────────┘  └───────────┘                 │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Show CDN architecture
- Explain edge locations
- Discuss latency benefits

---

#### Slide 4.2.2: Edge Cache Rules
**Title:** Configuring Edge Caching

**Content:**
```typescript
class EdgeCacheStrategy {
    determineCacheHeaders(path: string, method: string, statusCode: number): CacheHeaders {
        const rules = {
            '/api': { ttl: 0, cacheableStatuses: [200] },
            '/api/users': { ttl: 60, staleWhileRevalidate: 300 },
            '/api/tasks': { ttl: 60, staleWhileRevalidate: 300 },
            '/static': { ttl: 86400, staleWhileRevalidate: 604800 },
            '/health': { ttl: 1, staleWhileRevalidate: 5 },
        };

        let rule = rules['/api'];
        for (const [pattern, r] of Object.entries(rules)) {
            if (path.startsWith(pattern)) {
                rule = r;
                break;
            }
        }

        const isCacheable = method === 'GET' && rule.cacheableStatuses.includes(statusCode);

        if (!isCacheable) {
            return {
                'Cache-Control': 'no-cache, no-store, must-revalidate',
            };
        }

        return {
            'Cache-Control': [
                `max-age=${rule.ttl}`,
                `stale-while-revalidate=${rule.staleWhileRevalidate}`,
                'public',
            ].join(', '),
            'Vary': 'Accept-Encoding, Accept-Language',
        };
    }

    async invalidateOnUpdate(entityType: string, entityId: string): Promise<void> {
        const patterns = [
            `/${entityType}/*`,
            `/${entityType}s/*`,
            `/${entityType}/${entityId}`,
        ];
        await this.cdnManager.invalidateCache(patterns);
    }
}
```

**Teaching Notes:**
- Show cache rules
- Explain stale-while-revalidate
- Demonstrate invalidation

---

## PHASE 5: DATA SYSTEMS (35 Slides)

### PART 5.1: Event Sourcing (20 Slides)

#### Slide 5.1.1: Event Sourcing Overview
**Title:** Storing State as Events

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 EVENT SOURCING                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Traditional CRUD:                                             │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  User { id: 1, name: "John", email: "john@example.com" } │   │
│  │  Update → { id: 1, name: "John Doe", email: "..." }     │   │
│  │  → Only current state                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Event Sourcing:                                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Event 1: UserCreated { id: 1, name: "John", email }   │   │
│  │  Event 2: UserNameChanged { id: 1, newName: "John D" }│   │
│  │  Event 3: UserEmailChanged { id: 1, newEmail: "..." } │   │
│  │  → Complete history                                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Benefits:                                                      │
│  • Complete audit trail                                        │
│  • Rebuild state at any point                                 │
│  • Event replay for new read models                          │
│  • Temporal queries                                          │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Compare CRUD vs Event Sourcing
- Show event examples
- Explain benefits

---

#### Slide 5.1.2: Domain Events
**Title:** Modeling Business Events

**Content:**
```typescript
// Domain Events
export class UserCreatedEvent {
    constructor(
        public readonly aggregateId: string,
        public readonly email: string,
        public readonly username: string,
        public readonly firstName: string,
        public readonly lastName: string,
        public readonly version: number = 1
    ) {}

    toJSON(): Record<string, any> {
        return {
            eventId: this.eventId,
            eventType: 'UserCreated',
            aggregateId: this.aggregateId,
            version: this.version,
            timestamp: new Date().toISOString(),
            data: {
                email: this.email,
                username: this.username,
                firstName: this.firstName,
                lastName: this.lastName,
            },
        };
    }
}

export class UserEmailChangedEvent {
    constructor(
        public readonly aggregateId: string,
        public readonly oldEmail: string,
        public readonly newEmail: string,
        public readonly version: number
    ) {}

    toJSON(): Record<string, any> {
        return {
            eventId: this.eventId,
            eventType: 'UserEmailChanged',
            aggregateId: this.aggregateId,
            version: this.version,
            timestamp: new Date().toISOString(),
            data: {
                oldEmail: this.oldEmail,
                newEmail: this.newEmail,
            },
        };
    }
}
```

**Teaching Notes:**
- Show event structure
- Explain versioning
- Demonstrate immutability

---

#### Slide 5.1.3: Event Store
**Title:** Storing Events in PostgreSQL

**Content:**
```sql
-- Event Store Schema
CREATE TABLE events (
    id BIGSERIAL PRIMARY KEY,
    event_id UUID NOT NULL UNIQUE,
    aggregate_id UUID NOT NULL,
    aggregate_type VARCHAR(50) NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    version INTEGER NOT NULL,
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL,
    data JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_events_aggregate_id_version ON events(aggregate_id, version);
CREATE INDEX idx_events_event_type ON events(event_type);
CREATE INDEX idx_events_occurred_at ON events(occurred_at DESC);

-- Appending Events
INSERT INTO events (event_id, aggregate_id, aggregate_type, event_type, version, occurred_at, data)
VALUES ($1, $2, $3, $4, $5, $6, $7);

-- Retrieving Events
SELECT * FROM events 
WHERE aggregate_id = $1 
ORDER BY version ASC;
```

**Teaching Notes:**
- Show schema design
- Explain indexes
- Demonstrate queries

---

#### Slide 5.1.4: Building Read Models
**Title:** Projections from Events

**Content:**
```typescript
class UserProjection {
    async processEvent(event: DomainEvent): Promise<void> {
        switch (event.eventType) {
            case 'UserCreated':
                await this.handleUserCreated(event);
                break;
            case 'UserEmailChanged':
                await this.handleUserEmailChanged(event);
                break;
            case 'UserProfileUpdated':
                await this.handleUserProfileUpdated(event);
                break;
            case 'UserDeactivated':
                await this.handleUserDeactivated(event);
                break;
        }
    }

    private async handleUserCreated(event: UserCreatedEvent): Promise<void> {
        await this.db.query(
            `INSERT INTO user_read_model (id, email, username, first_name, last_name, is_active, created_at, updated_at)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8)`,
            [
                event.aggregateId,
                event.email,
                event.username,
                event.firstName,
                event.lastName,
                true,
                event.occurredAt,
                event.occurredAt,
            ]
        );
    }

    private async handleUserEmailChanged(event: UserEmailChangedEvent): Promise<void> {
        await this.db.query(
            `UPDATE user_read_model SET email = $1, updated_at = $2 WHERE id = $3`,
            [event.newEmail, event.occurredAt, event.aggregateId]
        );
    }

    // Rebuild from scratch
    async rebuild(): Promise<void> {
        await this.db.query('TRUNCATE user_read_model');
        const events = await this.eventStore.getEventsByType('User');
        for (const event of events) {
            await this.processEvent(event);
        }
    }
}
```

**Teaching Notes:**
- Show event processing
- Explain projection logic
- Demonstrate rebuild

---

#### Slide 5.1.5: Event Versioning
**Title:** Evolving Events Over Time

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 EVENT VERSIONING                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Version 1:                                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  UserCreated { id, name, email }                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Version 2:                                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  UserCreated { id, firstName, lastName, email }      │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Upcaster:                                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  class UserCreatedUpcaster {                          │   │
│  │    upcast(event: any): any {                         │   │
│  │      // Version 1 → Version 2                       │   │
│  │      if (!event.data.firstName && event.data.name) { │   │
│  │        const [first, ...rest] = event.data.name.split(' '); │
│  │        return {                                      │   │
│  │          ...event,                                  │   │
│  │          version: 2,                                │   │
│  │          data: {                                   │   │
│  │            firstName: first,                       │   │
│  │            lastName: rest.join(' '),              │   │
│  │            email: event.data.email,              │   │
│  │          },                                       │   │
│  │        };                                         │   │
│  │      }                                             │   │
│  │      return event;                                 │   │
│  │    }                                               │   │
│  │  }                                                 │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain event evolution
- Show upcasting
- Discuss backward compatibility

---

### PART 5.2: Stream Processing (15 Slides)

#### Slide 5.2.1: Node.js Streams
**Title:** Processing Data as Streams

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 NODE.JS STREAMS                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Types:                                                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Readable ──▶ Source of data                          │   │
│  │  Writable ──▶ Destination for data                    │   │
│  │  Transform ──▶ Process data in transit                │   │
│  │  Duplex ──▶ Both readable and writable                │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Pipeline:                                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Source ──▶ Transform ──▶ Transform ──▶ Sink          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Code:                                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  const { Readable, Transform, Writable } = require('stream'); │
│  │                                                       │   │
│  │  const source = new Readable({ ... });              │   │
│  │  const transform = new Transform({ ... });          │   │
│  │  const sink = new Writable({ ... });               │   │
│  │                                                       │   │
│  │  source.pipe(transform).pipe(sink);                 │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain stream types
- Show pipeline composition
- Demonstrate with examples

---

#### Slide 5.2.2: Backpressure
**Title:** Controlling Flow

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 BACKPRESSURE                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Problem:                                                      │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Fast Producer →→→→ Slow Consumer                      │   │
│  │  Memory grows until crash                              │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Solution: Backpressure                                        │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Fast Producer ──▶ Buffer ──▶ Slow Consumer           │   │
│  │                      ▲                                   │   │
│  │                      │ (Stop when full)                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Code:                                                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  class BackpressureHandler {                          │   │
│  │    private buffer: any[] = [];                       │   │
│  │    private maxBufferSize = 1000;                    │   │
│  │                                                       │   │
│  │    write(data: any): boolean {                      │   │
│  │      if (this.buffer.length >= this.maxBufferSize) { │   │
│  │        return false; // Backpressure                │   │
│  │      }                                               │   │
│  │      this.buffer.push(data);                         │   │
│  │      return true;                                    │   │
│  │    }                                                 │   │
│  │                                                       │   │
│  │    read(): any | undefined {                         │   │
│  │      return this.buffer.shift();                    │   │
│  │    }                                                 │   │
│  │  }                                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain the problem
- Show the solution
- Demonstrate with code

---

#### Slide 5.2.3: Event Processor
**Title:** Processing Event Streams

**Content:**
```typescript
class EventProcessor {
    private batchSize = 100;
    private batchTimeout = 100; // ms

    async processEvents(
        eventStream: Readable,
        handler: (events: DomainEvent[]) => Promise<void>
    ): Promise<void> {
        const batch: DomainEvent[] = [];
        let timer: NodeJS.Timeout | null = null;

        const flush = async () => {
            if (batch.length === 0) return;
            
            const events = [...batch];
            batch.length = 0;
            
            try {
                await handler(events);
            } catch (error) {
                // Handle batch failure
                // Could retry or send to DLQ
                console.error('Batch processing failed:', error);
            }
        };

        const scheduleFlush = () => {
            if (timer) return;
            timer = setTimeout(async () => {
                timer = null;
                await flush();
            }, this.batchTimeout);
        };

        for await (const event of eventStream) {
            batch.push(event);
            
            if (batch.length >= this.batchSize) {
                await flush();
            } else {
                scheduleFlush();
            }
        }

        // Flush remaining events
        await flush();
    }
}
```

**Teaching Notes:**
- Show batch processing
- Explain timeout handling
- Demonstrate error recovery

---

## PHASE 6: AI & FINAL BOSS (40 Slides)

### PART 6.1: AI Agents (20 Slides)

#### Slide 6.1.1: AI Agent Overview
**Title:** What is an AI Agent?

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 AI AGENT ARCHITECTURE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    AGENT CORE                          │   │
│  │                                                       │   │
│  │  ┌──────────────────────────────────────────────────┐ │   │
│  │  │              LLM (Brain)                        │ │   │
│  │  │  • Understands natural language                │ │   │
│  │  │  • Reasons about problems                     │ │   │
│  │  │  • Makes plans and decisions                  │ │   │
│  │  └──────────────────────────────────────────────────┘ │   │
│  │                                                       │   │
│  │  ┌──────────────────────────────────────────────────┐ │   │
│  │  │              MEMORY                            │ │   │
│  │  │  • Short-term: Current context                │ │   │
│  │  │  • Long-term: Past experiences               │ │   │
│  │  │  • Vector embeddings for search              │ │   │
│  │  └──────────────────────────────────────────────────┘ │   │
│  │                                                       │   │
│  │  ┌──────────────────────────────────────────────────┐ │   │
│  │  │              TOOLS                             │ │   │
│  │  │  • APIs and integrations                       │ │   │
│  │  │  • Functions and operations                   │ │   │
│  │  │  • External services                           │ │   │
│  │  └──────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  Agentic Loop:                                                 │
│  Perceive → Plan → Execute → Reflect                          │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Explain agent components
- Show the agentic loop
- Use the "digital assistant" analogy

---

#### Slide 6.1.2: LLM Integration
**Title:** Connecting to Large Language Models

**Content:**
```typescript
// LLM Adapter
interface ILLMAdapter {
    complete(messages: Message[], options?: LLMOptions): Promise<LLMResponse>;
    stream(messages: Message[], options?: LLMOptions): AsyncIterable<LLMResponse>;
    embed(text: string): Promise<number[]>;
}

// OpenAI Implementation
class OpenAIAdapter implements ILLMAdapter {
    private client: OpenAI;
    private model: string;

    async complete(messages: Message[], options?: LLMOptions): Promise<LLMResponse> {
        const response = await this.client.chat.completions.create({
            model: this.model,
            messages: messages.map(m => ({
                role: m.role,
                content: m.content,
            })),
            temperature: options?.temperature || 0.7,
            max_tokens: options?.maxTokens || 1000,
            tools: options?.tools,
        });

        return {
            content: response.choices[0].message.content || '',
            toolCalls: response.choices[0].message.tool_calls || [],
            usage: {
                promptTokens: response.usage?.prompt_tokens || 0,
                completionTokens: response.usage?.completion_tokens || 0,
                totalTokens: response.usage?.total_tokens || 0,
            },
        };
    }
}
```

**Teaching Notes:**
- Show LLM integration
- Explain message format
- Discuss tool calling

---

#### Slide 6.1.3: Agent Tools
**Title:** Extending Agent Capabilities

**Content:**
```typescript
interface Tool {
    name: string;
    description: string;
    parameters: {
        type: 'object';
        properties: Record<string, {
            type: string;
            description: string;
            enum?: string[];
        }>;
        required: string[];
    };
    execute: (params: Record<string, any>) => Promise<any>;
}

// Example Tool: Create Task
class CreateTaskTool implements Tool {
    name = 'create_task';
    description = 'Create a new task in the system';
    parameters = {
        type: 'object' as const,
        properties: {
            title: { type: 'string', description: 'Task title' },
            description: { type: 'string', description: 'Task description' },
            priority: { type: 'string', enum: ['low', 'medium', 'high', 'critical'] },
        },
        required: ['title', 'description'],
    };

    async execute(params: Record<string, any>): Promise<any> {
        return await taskService.createTask({
            title: params.title,
            description: params.description,
            priority: params.priority || 'medium',
        });
    }
}
```

**Teaching Notes:**
- Show tool definition
- Explain parameter schema
- Demonstrate execution

---

#### Slide 6.1.4: Vector Memory
**Title:** Semantic Search Memory

**Content:**
```typescript
class VectorMemory {
    private memories: Map<string, MemoryEntry> = new Map();

    async store(content: string, metadata: Record<string, any> = {}): Promise<string> {
        const id = randomUUID();
        const embedding = await this.llm.embed(content);
        
        this.memories.set(id, {
            id,
            content,
            embedding,
            metadata,
            timestamp: new Date(),
        });

        return id;
    }

    async search(query: string, limit: number = 10): Promise<MemoryEntry[]> {
        const queryEmbedding = await this.llm.embed(query);
        const results: Array<{ entry: MemoryEntry; similarity: number }> = [];

        for (const entry of this.memories.values()) {
            if (!entry.embedding) continue;
            const similarity = this.cosineSimilarity(queryEmbedding, entry.embedding);
            results.push({ entry, similarity });
        }

        results.sort((a, b) => b.similarity - a.similarity);
        return results.slice(0, limit).map(r => r.entry);
    }

    private cosineSimilarity(a: number[], b: number[]): number {
        // Calculate similarity between vectors
        let dotProduct = 0;
        let normA = 0;
        let normB = 0;

        for (let i = 0; i < a.length; i++) {
            dotProduct += a[i] * b[i];
            normA += a[i] * a[i];
            normB += b[i] * b[i];
        }

        if (normA === 0 || normB === 0) return 0;
        return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
    }
}
```

**Teaching Notes:**
- Explain vector embeddings
- Show semantic search
- Demonstrate storage

---

### PART 6.2: The Final Boss (20 Slides)

#### Slide 6.2.1: Request Queue
**Title:** Priority-Based Queuing

**Content:**
```typescript
enum Priority {
    CRITICAL = 0,
    HIGH = 1,
    MEDIUM = 2,
    LOW = 3,
    BACKGROUND = 4,
}

class RequestQueue {
    private queues: Map<Priority, QueuedRequest[]> = new Map();
    private processing = 0;
    private maxConcurrent = 10;

    async enqueue<T>(
        execute: () => Promise<T>,
        priority: Priority = Priority.MEDIUM,
        timeout: number = 30000
    ): Promise<T> {
        return new Promise((resolve, reject) => {
            const request: QueuedRequest<T> = {
                id: randomUUID(),
                priority,
                execute,
                resolve,
                reject,
                timeout,
                enqueuedAt: new Date(),
            };

            this.queues.get(priority)!.push(request);
            this.processNext();
        });
    }

    private async processNext(): Promise<void> {
        if (this.processing >= this.maxConcurrent) return;

        // Get highest priority request
        let request: QueuedRequest | undefined;
        for (const p of Object.values(Priority).sort()) {
            const queue = this.queues.get(p)!;
            if (queue.length > 0) {
                request = queue.shift();
                break;
            }
        }

        if (!request) return;

        this.processing++;
        try {
            const result = await this.executeWithTimeout(request);
            request.resolve(result);
        } catch (error) {
            request.reject(error);
        } finally {
            this.processing--;
            this.processNext();
        }
    }
}
```

**Teaching Notes:**
- Show priority system
- Explain concurrency control
- Demonstrate timeout handling

---

#### Slide 6.2.2: Rate Limiter
**Title:** Preventing Overload

**Content:**
```typescript
class RateLimiter {
    private requests: Map<string, number[]> = new Map();
    private maxRequests: number;
    private windowMs: number;

    constructor(maxRequests: number, windowMs: number) {
        this.maxRequests = maxRequests;
        this.windowMs = windowMs;
    }

    isAllowed(key: string): boolean {
        const now = Date.now();
        const windowStart = now - this.windowMs;
        
        // Get recent requests
        let timestamps = this.requests.get(key) || [];
        timestamps = timestamps.filter(t => t > windowStart);
        
        // Check limit
        if (timestamps.length >= this.maxRequests) {
            return false;
        }
        
        // Add request
        timestamps.push(now);
        this.requests.set(key, timestamps);
        
        return true;
    }

    getRemaining(key: string): number {
        const now = Date.now();
        const windowStart = now - this.windowMs;
        const timestamps = this.requests.get(key) || [];
        const recent = timestamps.filter(t => t > windowStart);
        return Math.max(0, this.maxRequests - recent.length);
    }

    getResetTime(key: string): Date {
        const now = Date.now();
        const timestamps = this.requests.get(key) || [];
        if (timestamps.length === 0) {
            return new Date(now + this.windowMs);
        }
        const oldest = Math.min(...timestamps);
        return new Date(oldest + this.windowMs);
    }
}
```

**Teaching Notes:**
- Show sliding window
- Explain headers
- Demonstrate usage

---

#### Slide 6.2.3: Complete Orchestrator
**Title:** Bringing It All Together

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│              FINAL ORCHESTRATOR                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    ORCHESTRATOR                        │   │
│  │                                                       │   │
│  │  ┌──────────────────────────────────────────────────┐ │   │
│  │  │  1. Rate Limiter                              │ │   │
│  │  │     Checks if request is allowed              │ │   │
│  │  └──────────────────────────────────────────────────┘ │   │
│  │                         │                           │   │
│  │                         ▼                           │   │
│  │  ┌──────────────────────────────────────────────────┐ │   │
│  │  │  2. Deduplicator                             │ │   │
│  │  │     Prevents duplicate requests              │ │   │
│  │  └──────────────────────────────────────────────────┘ │   │
│  │                         │                           │   │
│  │                         ▼                           │   │
│  │  ┌──────────────────────────────────────────────────┐ │   │
│  │  │  3. Request Queue                            │ │   │
│  │  │     Prioritize and schedule                  │ │   │
│  │  └──────────────────────────────────────────────────┘ │   │
│  │                         │                           │   │
│  │                         ▼                           │   │
│  │  ┌──────────────────────────────────────────────────┐ │   │
│  │  │  4. Retry Policy                             │ │   │
│  │  │     Exponential backoff on failure          │ │   │
│  │  └──────────────────────────────────────────────────┘ │   │
│  │                         │                           │   │
│  │                         ▼                           │   │
│  │  ┌──────────────────────────────────────────────────┐ │   │
│  │  │  5. Execute                                  │ │   │
│  │  │     With AbortController                      │ │   │
│  │  └──────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Walk through each component
- Show how they work together
- Emphasize production readiness

---

## PRIMERS OVERVIEW (10 Slides)

### Slide P.1: Complete Primer List
**Title:** 20 Deep Dive Primers

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│               20 COMPREHENSIVE PRIMERS                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1.  Understanding the JavaScript Event Loop                   │
│  2.  Understanding Hexagonal Architecture                      │
│  3.  Understanding Distributed Systems Patterns                │
│  4.  Understanding CQRS & Event Sourcing                      │
│  5.  Understanding AI Agents & LLM Integration                │
│  6.  Understanding Production Orchestration Patterns          │
│  7.  Understanding Node.js Streams & Backpressure            │
│  8.  Understanding Testing Strategies                        │
│  9.  Understanding Performance Optimization                   │
│  10. Understanding Security Best Practices                    │
│  11. Understanding Error Handling & Observability            │
│  12. Understanding Real-Time Systems & WebSockets            │
│  13. Understanding Deployment & DevOps Practices             │
│  14. Understanding Event-Driven Architecture                  │
│  15. Understanding Microservices & Service Mesh              │
│  16. Understanding Database Patterns & Data Management       │
│  17. Understanding Caching Strategies & CDN                  │
│  18. Understanding Message Queues & Event Streaming          │
│  19. Understanding API Design & Documentation                │
│  20. Understanding System Architecture & Design Patterns     │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Briefly introduce each primer
- Explain when to reference them
- Emphasize they're optional deep dives

---

## CONCLUSION (5 Slides)

### Slide C.1: What You've Built
**Title:** Your Complete System

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                COMPLETE ORCHESTRATOR SYSTEM                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ✅ Production-Ready HTTP Service                              │
│  ✅ Hexagonal Architecture with Clean Separation              │
│  ✅ PostgreSQL Integration with Connection Pooling            │
│  ✅ Redis Caching with Multi-Level Strategy                   │
│  ✅ Distributed Patterns (Circuit Breaker, Saga, Retry)      │
│  ✅ Request Context & Cancellation Propagation                │
│  ✅ Cloud-Native Deployment (Lambda, Workers)                │
│  ✅ Event Sourcing with Complete Audit Trail                 │
│  ✅ AI Agents with LLM Integration                            │
│  ✅ Production Orchestration Layer                            │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Review the complete system
- Connect back to the original architecture diagram
- Celebrate the achievement

---

### Slide C.2: Key Takeaways
**Title:** What You Learned

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                    KEY TAKEAWAYS                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. Architecture is About Trade-offs                           │
│     • No perfect solution                                      │
│     • Balance competing requirements                          │
│                                                                 │
│  2. Code Quality Matters                                       │
│     • Production-grade code                                   │
│     • Error handling                                           │
│     • Observability                                            │
│                                                                 │
│  3. Patterns are Tools                                         │
│     • Learn the patterns                                      │
│     • Apply appropriately                                     │
│     • Avoid over-engineering                                  │
│                                                                 │
│  4. Distributed Systems are Different                         │
│     • Expect failures                                          │
│     • Design for resilience                                   │
│     • Monitor everything                                       │
│                                                                 │
│  5. Continuous Improvement                                     │
│     • Learn from each system                                  │
│     • Evolve with requirements                                │
│     • Stay curious                                            │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Summarize key lessons
- Encourage continued learning
- Provide resources for next steps

---

### Slide C.3: What's Next?
**Title:** Your Continued Journey

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                   WHAT'S NEXT?                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Deepen Your Knowledge:                                        │
│  • Kubernetes for orchestration                               │
│  • Service Mesh (Istio, Linkerd)                              │
│  • Kafka for event streaming                                  │
│  • GraphQL for APIs                                          │
│                                                                 │
│  Expand the System:                                           │
│  • Mobile apps (React Native)                                │
│  • Web UI (React, Next.js)                                   │
│  • Additional services                                        │
│  • Machine Learning integration                              │
│                                                                 │
│  Production Optimizations:                                    │
│  • Load testing                                               │
│  • Security scanning                                          │
│  • Performance tuning                                         │
│  • Disaster recovery planning                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Suggest next steps
- Provide learning resources
- Encourage building

---

### Slide C.4: Resources
**Title:** Recommended Resources

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│                 RECOMMENDED RESOURCES                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Books:                                                        │
│  • "Designing Data-Intensive Applications" - Martin Kleppmann │
│  • "Building Microservices" - Sam Newman                     │
│  • "The Pragmatic Programmer" - David Thomas                  │
│                                                                 │
│  Documentation:                                                │
│  • Node.js Official Docs                                      │
│  • TypeScript Handbook                                        │
│  • PostgreSQL Documentation                                   │
│  • Redis Documentation                                        │
│                                                                 │
│  Courses:                                                      │
│  • AWS Training                                               │
│  • Cloudflare Workers                                         │
│  • OpenAI API Documentation                                   │
│                                                                 │
│  Community:                                                    │
│  • Stack Overflow                                             │
│  • GitHub                                                     │
│  • Local meetups                                              │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Share book recommendations
- Provide documentation links
- Suggest community resources

---

### Slide C.5: Thank You
**Title:** 🎉 Thank You!

**Content:**
```
┌─────────────────────────────────────────────────────────────────┐
│               🎉🎉🎉  CONGRATULATIONS  🎉🎉🎉                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  You have completed the JavaScript Systems Architecture       │
│  Series!                                                       │
│                                                                 │
│  7 Phases • 20 Primers • 100+ Code Files                     │
│  10,000+ Lines of Code • Production-Grade System              │
│                                                                 │
│  You are now equipped to:                                     │
│  ✅ Design distributed systems                                │
│  ✅ Build microservices                                      │
│  ✅ Implement event-driven architecture                       │
│  ✅ Deploy to cloud                                          │
│  ✅ Integrate AI agents                                      │
│  ✅ Production orchestration                                  │
│                                                                 │
│  Go build something amazing! 🚀                              │
│                                                                 │
│  Questions? Reach out at [your-email]                         │
│  Share your projects at [your-social]                         │
└─────────────────────────────────────────────────────────────────┘
```

**Teaching Notes:**
- Celebrate with the students
- Encourage sharing
- Provide contact information
- End on a positive note

---

## TOTAL SLIDE COUNT: 185 Slides

This comprehensive slide outline covers the entire JavaScript Systems Architecture series with detailed content, code examples, and teaching notes for each slide. The slides are designed to be used in sequential order, with each building on the previous content.
