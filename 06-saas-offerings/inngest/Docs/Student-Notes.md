# Mastering Inngest: Student Notes

## Complete Study Guide for the Mastering Inngest Series

---

# How to Use These Notes

These notes are designed to accompany the "Mastering Inngest" video series, instructor-led training, or self-study program. They provide:

1. **Key Concepts** — The most important ideas from each module
2. **Code Snippets** — Essential code patterns you'll use repeatedly
3. **Diagrams** — Visual representations of key concepts
4. **Checklists** — Quick reference for implementation steps
5. **Troubleshooting Tips** — Common issues and solutions
6. **Notes Section** — Space for your own annotations

Use these notes as a reference during and after the course. They are not a replacement for the full content but a condensed version for quick lookup.

---

# Part 0: Introduction & Foundations

## What Is Durable Execution?

```
Traditional Problem:
┌─────────────────────────────────────┐
│  Job fails halfway → Start over     │
│  Duplicate charges                  │
│  Lost state                         │
│  Manual retry logic                 │
└─────────────────────────────────────┘

Durable Execution Solution:
┌─────────────────────────────────────┐
│  Job fails → Resume from last step  │
│  Exactly-once processing            │
│  State preserved                    │
│  Automatic retry                    │
└─────────────────────────────────────┘
```

## The Restaurant Analogy

| Component | Analogy |
|-----------|---------|
| Event | Customer order |
| Event Router | Expediter |
| Function | Head chef |
| Step | Individual cook |
| Run | Complete service |

## Core Primitives

| Primitive | Purpose |
|-----------|---------|
| **Event** | "Something happened" — triggers workflows |
| **Function** | Durable workflow that responds to events |
| **Step** | Unit of work, automatically retried on failure |

## Key Commands

```bash
# Create Next.js project
pnpm create next-app@latest workflowhub --typescript --tailwind --app
cd workflowhub

# Install Inngest
pnpm add inngest inngest/next zod uuid

# Install Inngest CLI
curl -sSfL https://cli.inngest.com/install.sh | sh

# Start Dev Server
inngest dev -u http://localhost:3000/api/inngest

# Start Next.js
pnpm dev
```

## Dev Server Features

- [x] Real-time execution dashboard
- [x] Step-by-step tracing
- [x] Retry simulation
- [x] Event replay
- [x] Function registration

---

**Your Notes:**
```
____________________________________________________________
____________________________________________________________
____________________________________________________________
____________________________________________________________
```

---

# Part 1: Events & Durable Execution

## Event Flow Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   User      │     │   Frontend  │     │   Inngest   │
│  Signs Up   │────▶│  Sends      │────▶│   Event     │
│             │     │   Event     │     │   API       │
└─────────────┘     └─────────────┘     └─────────────┘
                                                     │
                                                     ▼
                                            ┌─────────────┐
                                            │   Inngest   │
                                            │   Function  │
                                            │   Runner    │
                                            └─────────────┘
                                                     │
                    ┌─────────────┐     ┌─────────────┐
                    │   Email     │◀────│   Step 1:   │
                    │   Service   │     │   Send      │
                    └─────────────┘     │   Welcome   │
                    ┌─────────────┐     └─────────────┘
                    │   Database  │◀────│   Step 2:   │
                    │             │     │   Create    │
                    └─────────────┘     │   Profile   │
                    ┌─────────────┐     └─────────────┘
                    │   CRM       │◀────│   Step 3:   │
                    │             │     │   Sync to   │
                    └─────────────┘     │   CRM       │
                                        └─────────────┘
```

## The Three Parts of a Function

```typescript
inngest.createFunction(
  // 1. Configuration
  {
    id: "my-workflow",
    name: "My Workflow",
    retries: 3,
  },
  // 2. Trigger
  { event: "user/registered" },
  // 3. Handler
  async ({ event, step, logger }) => {
    // Step logic
  }
);
```

## Basic Workflow Template

```typescript
// src/inngest/client.ts
import { Inngest } from 'inngest';

export const inngest = new Inngest({
  id: 'workflowhub',
  name: 'WorkflowHub',
  eventKey: process.env.INNGEST_EVENT_KEY,
});

// src/inngest/functions/registration.ts
import { inngest } from '@/inngest/client';

export const registrationWorkflow = inngest.createFunction(
  {
    id: 'registration-workflow',
    name: 'User Registration',
    retries: 3,
  },
  { event: 'user/registered' },
  async ({ event, step, logger }) => {
    // Step 1: Send welcome email
    const email = await step.run('send-welcome-email', async () => {
      await sendEmail(event.data.email);
      return { sent: true };
    });

    // Step 2: Create profile
    const profile = await step.run('create-profile', async () => {
      return await createUser(event.data);
    });

    return { success: true, email, profile };
  }
);

// src/app/api/inngest/route.ts
import { serve } from 'inngest/next';
import { inngest } from '@/inngest/client';
import { registrationWorkflow } from '@/inngest/functions/registration';

export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [registrationWorkflow],
});

export const config = {
  api: { bodyParser: false },
};
```

## Triggering Events

```bash
# Curl
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "user/registered",
    "data": {
      "userId": "user_123",
      "email": "test@example.com"
    }
  }'
```

```typescript
// From Code
await inngest.send({
  name: 'user/registered',
  data: { userId: 'user_123', email: 'test@example.com' },
});
```

## Testing Retry Behavior

```typescript
// Simulate failure
export const simulateFailure = (rate: number = 0.5) => {
  if (Math.random() < rate) {
    throw new Error('Simulated failure');
  }
};

// Use in step
await step.run('step-with-retry', async () => {
  simulateFailure(0.7);
  // Business logic
});
```

---

**Your Notes:**
```
____________________________________________________________
____________________________________________________________
____________________________________________________________
____________________________________________________________
```

---

# Part 2: State Management & Fault Tolerance

## How Checkpointing Works

```
Step 1 → [SAVE] → Step 2 → [SAVE] → Step 3 → [SAVE]
              ↓            ↓              ↓
          Checkpoint  Checkpoint      Checkpoint
```

## Idempotency Pattern

```typescript
// Idempotent payment step
const payment = await step.run('process-payment', async () => {
  const idempotencyKey = `payment-${orderId}`;
  
  // Check if already processed
  const existing = await db.payments.findUnique({
    where: { idempotencyKey }
  });
  if (existing) return existing;
  
  // Process payment
  const result = await chargeCard(orderId, amount);
  
  // Store with idempotency key
  await db.payments.create({
    data: { idempotencyKey, ...result }
  });
  
  return result;
});
```

## Saga Pattern (Compensating Actions)

```
┌─────────────────────────────────────────────────────────┐
│                    Saga Pattern                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Step 1: Book Flight  ──────────────────────┐           │
│  │                                           │           │
│  ▼                                           │           │
│  Step 2: Book Hotel  ──────────────┐        │           │
│  │                                   │        │           │
│  ▼                                   │        │           │
│  Step 3: Book Car  ─────────┐       │        │           │
│  │                          │       │        │           │
│  ▼                          ▼       ▼        ▼           │
│  COMPENSATION:           Cancel   Cancel    Cancel      │
│  (Reverse Order)         Car      Hotel     Flight      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Saga Pattern Code

```typescript
const reservations = {};

try {
  reservations.flight = await step.run('reserve-flight', () => airline.reserve());
  reservations.hotel = await step.run('reserve-hotel', () => hotel.reserve());
  reservations.car = await step.run('reserve-car', () => carRental.reserve());
  
  await step.run('confirm-all', () => confirmAll(reservations));
} catch (error) {
  // Compensate in reverse order
  if (reservations.car) {
    await step.run('cancel-car', () => carRental.cancel(reservations.car.id));
  }
  if (reservations.hotel) {
    await step.run('cancel-hotel', () => hotel.cancel(reservations.hotel.id));
  }
  if (reservations.flight) {
    await step.run('cancel-flight', () => airline.cancel(reservations.flight.id));
  }
  throw error;
}
```

## Time-Based Orchestration

```typescript
// Sleep for duration
await step.sleep('wait-5s', 5000);
await step.sleep('wait-1m', '1m');

// Sleep until time
await step.sleepUntil('wait-for-date', new Date('2024-12-31T23:59:59'));

// Calculated wait
const waitTime = scheduledDate.getTime() - Date.now();
await step.sleep('wait-for-schedule', waitTime);
```

## Error Handling Strategies

| Strategy | When to Use |
|----------|-------------|
| **Graceful Degradation** | Optional features |
| **Retry with Backoff** | Transient failures |
| **Dead Letter Queue** | Unrecoverable failures |
| **Fallback with Cache** | API failures |

## Configuring Retries

```typescript
// Function-level
retries: 5,
retryDelay: '10s',

// Custom retry function
retryFunction: (attempt: number) => ({
  delay: Math.min(Math.pow(2, attempt) * 1000, 60000),
  maxAttempts: 5,
});
```

---

**Your Notes:**
```
____________________________________________________________
____________________________________________________________
____________________________________________________________
____________________________________________________________
```

---

# Part 3: High-Performance Patterns

## Fan-Out / Fan-In

```
┌─────────────────────────────────────────────────────────┐
│                    Fan-Out / Fan-In                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│           ┌─────────────┐                               │
│           │  Process    │                               │
│           │  Item 1     │                               │
│           └─────────────┘                               │
│           ┌─────────────┐                               │
│           │  Process    │                               │
│  Fan-Out  │  Item 2     │ ────┐  Fan-In               │
│           └─────────────┘     │                        │
│           ┌─────────────┐     │      ┌─────────────┐   │
│           │  Process    │     ─────▶│  Aggregate  │   │
│           │  Item 3     │          │  Results    │   │
│           └─────────────┘          └─────────────┘   │
│           ┌─────────────┐                             │
│           │  Process    │                             │
│           │  Item N     │                             │
│           └─────────────┘                             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Bulk Processing Pattern

```typescript
const BATCH_SIZE = 50;
const allResults = [];

for (let i = 0; i < items.length; i += BATCH_SIZE) {
  const batch = items.slice(i, i + BATCH_SIZE);
  
  const batchResults = await step.run(`process-batch-${i}`, async () => {
    const promises = batch.map(item => processItem(item));
    return await Promise.all(promises);
  });
  
  allResults.push(...batchResults);
}

// Aggregate results
const stats = {
  total: allResults.length,
  success: allResults.filter(r => r.success).length,
  failed: allResults.filter(r => !r.success).length,
};
```

## Concurrency Configuration

```typescript
// Function-level concurrency
concurrency: {
  limit: 10,
  scope: 'fn',
}

// Key-based concurrency (per tenant/user)
concurrency: {
  limit: 5,
  scope: 'key',
  key: 'data.tenantId',
}

// Global concurrency
concurrency: {
  limit: 100,
  scope: 'global',
}
```

## Rate Limiting & Throttling

```typescript
// Rate limiting
rateLimit: {
  limit: 100,
  period: '1m',
  key: 'data.userId',
}

// Debouncing
debounce: {
  key: 'data.userId',
  period: '30s',
}

// Batching
batch: {
  maxSize: 100,
  timeout: '60s',
  key: 'data.tenantId',
}
```

## Comparison Table

| Pattern | Purpose | Key Config |
|---------|---------|------------|
| **Rate Limit** | Cap requests per time period | `rateLimit` |
| **Throttle** | Delay between requests | `throttle` |
| **Debounce** | Wait for quiet period | `debounce` |
| **Batch** | Group events for processing | `batch` |

## Circuit Breaker Pattern

```typescript
class CircuitBreaker {
  private state: 'closed' | 'open' | 'half-open' = 'closed';
  private failures = 0;
  private readonly threshold = 5;
  private readonly timeout = 60000;

  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'open') {
      if (Date.now() - this.lastFailure > this.timeout) {
        this.state = 'half-open';
      } else {
        throw new Error('Circuit breaker is open');
      }
    }

    try {
      const result = await fn();
      this.failures = 0;
      this.state = 'closed';
      return result;
    } catch (error) {
      this.failures++;
      if (this.failures >= this.threshold) {
        this.state = 'open';
        this.lastFailure = Date.now();
      }
      throw error;
    }
  }
}
```

---

**Your Notes:**
```
____________________________________________________________
____________________________________________________________
____________________________________________________________
____________________________________________________________
```

---

# Part 4: Long-Running Workflows & Human-in-the-Loop

## Long-Running Workflow Architecture

```
┌─────────────────────────────────────────────────────────┐
│              Long-Running Workflow                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Event → Step 1 → [SLEEP] → Step 2 → [WAIT] → Step 3  │
│                ↑                    ↑                   │
│                │                    │                   │
│           Durable State      External Event            │
│           (Persisted)        (Human/System)            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## step.waitForEvent() Syntax

```typescript
try {
  const decision = await step.waitForEvent('wait-for-approval', {
    event: 'approval/decision',
    timeout: '24h',
    match: (data) => data.approvalId === approvalId,
  });
  
  if (decision.data.approved) {
    // Execute approved action
  }
} catch {
  // Timeout - handle escalation
}
```

## Approval Workflow Pattern

```typescript
export const approvalWorkflow = inngest.createFunction(
  { id: 'approval-workflow' },
  { event: 'approval/requested' },
  async ({ event, step, logger }) => {
    // 1. Notify approver
    await step.run('notify-approver', async () => {
      await sendEmail(approverEmail, 'Approval needed');
    });

    // 2. Wait for decision with timeout
    let approved = false;
    try {
      const decision = await step.waitForEvent('wait-for-approval', {
        event: 'approval/decision',
        timeout: '24h',
        match: (data) => data.approvalId === approvalId,
      });
      approved = decision.data.approved;
    } catch {
      // 3. Handle timeout - escalate
      await step.run('escalate', async () => {
        await sendEmail(managerEmail, 'Approval timed out');
      });
    }

    // 4. Execute or reject
    if (approved) {
      await step.run('execute', async () => {
        await executeAction(approvalId);
      });
    }

    return { approved, approvalId };
  }
);
```

## Escalation Chain

```
Attempt 1 (1h) → Remind Approver
Attempt 2 (4h) → Notify Manager
Attempt 3 (12h) → Auto-Approval or Escalate
```

## Workflow Versioning

```typescript
// Version 1.0.0
export const workflowV1 = inngest.createFunction(
  {
    id: 'my-workflow',
    version: '1.0.0',
  },
  { event: 'workflow/trigger' },
  async ({ event, step }) => {
    // Original logic
  }
);

// Version 2.0.0
export const workflowV2 = inngest.createFunction(
  {
    id: 'my-workflow',
    version: '2.0.0',
  },
  { event: 'workflow/trigger' },
  async ({ event, step }) => {
    // Enhanced logic
  }
);

// Register both
serve({
  client: inngest,
  functions: [workflowV1, workflowV2],
});
```

## Safe Deployment Process

1. Deploy new version alongside existing version
2. Test new version with test events
3. Gradually route traffic to new version
4. Monitor for errors
5. Fully switch to new version
6. Remove old version after all executions complete

---

**Your Notes:**
```
____________________________________________________________
____________________________________________________________
____________________________________________________________
____________________________________________________________
```

---

# Part 5: Full-Stack Integration

## Full-Stack Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Layer                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  React 19 Components                               │  │
│  │  • useActionState for forms                       │  │
│  │  • useOptimistic for responsive UI                │  │
│  │  • useSSE for real-time updates                   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    API Layer                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Next.js API Routes                                │  │
│  │  • /api/inngest - Inngest endpoint                 │  │
│  │  • Server Actions (trigger workflows)              │  │
│  │  • SSE endpoint (stream status)                   │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Workflow Orchestration Layer                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Inngest Durable Workflows                         │  │
│  │  • Event processing                                │  │
│  │  • State management                                │  │
│  │  • Retry & recovery                                │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Server Action Pattern

```typescript
// src/lib/actions/workflow.actions.ts
'use server';

import { inngest } from '@/inngest/client';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

const schema = z.object({
  orderId: z.string(),
  total: z.number().positive(),
});

export async function createOrder(formData: FormData) {
  try {
    const data = schema.parse({
      orderId: formData.get('orderId'),
      total: parseFloat(formData.get('total') as string),
    });

    const result = await inngest.send({
      name: 'order/placed',
      data,
    });

    revalidatePath('/dashboard');

    return { success: true, runId: result.ids?.[0] };
  } catch (error) {
    return { success: false, error: error.message };
  }
}
```

## useActionState Pattern

```typescript
'use client';

import { useActionState } from 'react';
import { createOrder } from '@/lib/actions/workflow.actions';

const initialState = {
  success: false,
  error: null,
  runId: null,
};

export function OrderForm() {
  const [state, formAction, isPending] = useActionState(
    createOrder,
    initialState
  );

  return (
    <form action={formAction}>
      <input name="orderId" required />
      <input name="total" type="number" required />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Processing...' : 'Submit'}
      </button>
      {state.success && <p>Order placed: {state.runId}</p>}
      {state.error && <p className="text-red-600">{state.error}</p>}
    </form>
  );
}
```

## useOptimistic Pattern

```typescript
'use client';

import { useOptimistic } from 'react';

export function AIContentGenerator() {
  const [content, setContent] = useState('');
  const [isGenerating, setIsGenerating] = useState(false);

  const [optimisticContent, addOptimisticContent] = useOptimistic(
    content,
    (state, newContent: string) => newContent
  );

  const handleGenerate = async (prompt: string) => {
    setIsGenerating(true);
    
    // Show optimistic content immediately
    addOptimisticContent(`✨ Generating: "${prompt.substring(0, 50)}..."`);

    // Actual generation
    const result = await generateContent(prompt);
    setContent(result);
    setIsGenerating(false);
  };

  return (
    <div>
      <button onClick={() => handleGenerate('Write a blog post')}>
        Generate
      </button>
      <div>{optimisticContent}</div>
    </div>
  );
}
```

## SSE Stream Pattern

```typescript
// Server (SSE endpoint)
export async function GET(request: NextRequest) {
  const runId = request.nextUrl.searchParams.get('runId');
  
  const stream = new ReadableStream({
    async start(controller) {
      const sendUpdate = async () => {
        const status = await getWorkflowStatus(runId);
        controller.enqueue(`data: ${JSON.stringify(status)}\n\n`);
        if (status.status === 'completed') {
          controller.close();
          return;
        }
        setTimeout(sendUpdate, 2000);
      };
      sendUpdate();
    },
  });

  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  });
}
```

```typescript
// Client (useSSE hook)
export function useSSE(url: string) {
  const [data, setData] = useState(null);
  const [isConnected, setIsConnected] = useState(false);

  useEffect(() => {
    const eventSource = new EventSource(url);

    eventSource.onopen = () => setIsConnected(true);
    eventSource.onmessage = (event) => {
      setData(JSON.parse(event.data));
    };
    eventSource.onerror = () => {
      setIsConnected(false);
      setTimeout(() => {
        // Auto-reconnect
        new EventSource(url);
      }, 3000);
    };

    return () => eventSource.close();
  }, [url]);

  return { data, isConnected };
}
```

---

**Your Notes:**
```
____________________________________________________________
____________________________________________________________
____________________________________________________________
____________________________________________________________
```

---

# Part 6: Production & Observability

## Environment Variables

```bash
# .env.production
INNGEST_EVENT_KEY="ev_prod_xxxxxxxxxxxxxxxx"
INNGEST_SIGNING_KEY="sign_prod_xxxxxxxxxxxxxxxx"
NEXT_PUBLIC_APP_URL="https://your-app.com"
DATABASE_URL="postgresql://user:pass@host:5432/database"
JWT_SECRET="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
ENCRYPTION_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
LOG_LEVEL="info"
```

## Production-Ready Client

```typescript
// src/inngest/client.ts
import { Inngest, InngestMiddleware } from 'inngest';
import * as Sentry from '@sentry/nextjs';

// Sentry middleware
const sentryMiddleware = new InngestMiddleware({
  name: 'Sentry Error Tracking',
  init: () => ({
    onFunctionRun: ({ fn, ctx }) => ({
      onStepRun: ({ step }) => ({
        transformOutput: ({ output }) => {
          if (output instanceof Error) {
            Sentry.captureException(output, {
              tags: { function: fn.id, step: step.name },
            });
          }
          return { output };
        },
      }),
    }),
  }),
});

// Metrics middleware
const metricsMiddleware = new InngestMiddleware({
  name: 'Metrics Collection',
  init: () => ({
    onFunctionRun: ({ fn, ctx }) => {
      const startTime = Date.now();
      return {
        onFunctionComplete: ({ result }) => {
          console.log('Function metrics:', {
            functionId: fn.id,
            duration: Date.now() - startTime,
            success: result.success,
          });
        },
      };
    },
  }),
});

// Production client
export const inngest = new Inngest({
  id: 'workflowhub',
  name: 'WorkflowHub',
  eventKey: process.env.INNGEST_EVENT_KEY,
  signingKey: process.env.INNGEST_SIGNING_KEY,
  middleware: [sentryMiddleware, metricsMiddleware],
  retryFunction: (attempt) => ({
    delay: Math.min(Math.pow(2, attempt) * 1000, 60000),
    maxAttempts: 5,
  }),
  logger: {
    info: console.info,
    warn: console.warn,
    error: console.error,
  },
});
```

## Health Check Endpoint

```typescript
// src/app/api/health/route.ts
import { NextResponse } from 'next/server';

export async function GET() {
  try {
    const startTime = Date.now();
    const dbHealthy = await checkDatabase();
    const inngestHealthy = await checkInngest();

    const status = dbHealthy && inngestHealthy ? 'healthy' : 'degraded';
    
    return NextResponse.json({
      status,
      timestamp: new Date().toISOString(),
      services: {
        database: { healthy: dbHealthy },
        inngest: { healthy: inngestHealthy },
      },
      uptime: (Date.now() - startTime) / 1000,
    }, { status: status === 'healthy' ? 200 : 503 });
  } catch (error) {
    return NextResponse.json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: error.message,
    }, { status: 503 });
  }
}
```

## Deployment Configurations

### Vercel
```json
{
  "functions": {
    "api/inngest/**/*.ts": {
      "maxDuration": 60,
      "memory": 1024
    }
  }
}
```
```bash
vercel --prod
```

### AWS Lambda
```yaml
# serverless.yml
functions:
  api:
    handler: lambda.handler
    memorySize: 1024
    timeout: 60
```
```bash
serverless deploy
```

### Docker
```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm install && npm run build
CMD ["npm", "start"]
```
```bash
docker build -t workflowhub .
docker run -p 3000:3000 workflowhub
```

## Structured Logger

```typescript
export enum LogLevel {
  DEBUG = 'debug',
  INFO = 'info',
  WARN = 'warn',
  ERROR = 'error',
}

export class Logger {
  private static instance: Logger;
  
  static getInstance() {
    if (!Logger.instance) {
      Logger.instance = new Logger();
    }
    return Logger.instance;
  }

  log(level: LogLevel, message: string, context?: Record<string, any>, error?: Error) {
    console.log(JSON.stringify({
      level,
      message,
      timestamp: new Date().toISOString(),
      context,
      error: error ? { message: error.message, stack: error.stack } : undefined,
    }));
  }

  info(message: string, context?: Record<string, any>) {
    this.log(LogLevel.INFO, message, context);
  }

  error(message: string, error?: Error, context?: Record<string, any>) {
    this.log(LogLevel.ERROR, message, context, error);
  }
}
```

## Production Checklist

### Security
- [ ] All secrets are in environment variables
- [ ] Event signing keys are configured
- [ ] Rate limiting is enabled
- [ ] CORS is properly configured
- [ ] Security headers are set

### Reliability
- [ ] Retry policies are configured
- [ ] Error handling is comprehensive
- [ ] Health checks are implemented
- [ ] Circuit breakers are in place

### Observability
- [ ] Logging is structured
- [ ] Metrics are collected
- [ ] Alerts are configured
- [ ] Dashboard is set up

### Deployment
- [ ] CI/CD pipeline is configured
- [ ] Rollback plan exists
- [ ] Database migrations are automated
- [ ] Load testing has been performed

---

**Your Notes:**
```
____________________________________________________________
____________________________________________________________
____________________________________________________________
____________________________________________________________
```

---

# Appendix: Quick Reference Cards

## Function Configuration

```typescript
{
  id: "unique-id",
  name: "Display Name",
  retries: 3,
  retryDelay: "5s",
  concurrency: { limit: 10, scope: "fn" },
  rateLimit: { limit: 100, period: "1m" },
  idempotency: { key: "data.orderId", ttl: "30d" },
  version: "1.0.0",
}
```

## Step Methods

| Method | Purpose |
|--------|---------|
| `step.run(name, fn)` | Execute a durable step |
| `step.sleep(name, ms)` | Pause for duration |
| `step.sleepUntil(name, date)` | Pause until time |
| `step.waitForEvent(name, config)` | Wait for event |
| `step.sendEvent(name, events)` | Send events |

## Common Commands

```bash
# Start dev server
inngest dev -u http://localhost:3000/api/inngest

# Trigger event
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{"name":"event/name","data":{...}}'

# Send event (code)
await inngest.send({ name: "event/name", data: { ... } })
```

## Troubleshooting Quick Reference

| Issue | Solution |
|-------|----------|
| Function not registered | Check `serve()` includes the function |
| Events not triggering | Verify event name matches exactly |
| WaitForEvent timing out | Check matching condition, increase timeout |
| Retries exhausted | Check step logic, verify external service |
| Concurrency limit reached | Increase limit, check for stuck executions |
| Rate limit exceeded | Reduce frequency, increase limit, add throttling |

## Glossary

| Term | Definition |
|------|------------|
| **Event** | A signal that something happened |
| **Function** | A durable workflow that responds to events |
| **Step** | A unit of work within a function |
| **Run** | A single execution of a function |
| **Checkpoint** | Saved state after a step |
| **Idempotency** | Exactly-once execution guarantee |
| **Saga Pattern** | Distributed transaction with compensation |
| **Fan-Out/Fan-In** | Parallel processing pattern |
| **SSE** | Server-Sent Events for real-time updates |
| **RAG** | Retrieval-Augmented Generation |

---

*End of Student Notes*
