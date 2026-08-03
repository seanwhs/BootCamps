# Mastering Inngest: Building Reliable Serverless Workflows with Durable Execution

## Design Resilient Event-Driven Systems Without Managing Queues, Workers, or Workflow Infrastructure

---

# Appendix A: Inngest API Reference & Cheatsheet

This appendix serves as a comprehensive reference for the Inngest TypeScript SDK v4. It consolidates all the core APIs, patterns, and configuration options covered throughout the series, organized for quick lookup.

---

## A.1 Client Configuration

### Basic Client Setup

```typescript
import { Inngest } from "inngest";

export const inngest = new Inngest({
  id: "workflowhub", // Unique identifier for your application
  name: "WorkflowHub", // Display name in the Inngest dashboard
  
  // Authentication - always use environment variables in production
  eventKey: process.env.INNGEST_EVENT_KEY,
  signingKey: process.env.INNGEST_SIGNING_KEY,
  
  // Retry configuration for all functions
  retryFunction: (attempt: number) => ({
    delay: Math.min(Math.pow(2, attempt) * 1000, 60000),
    maxAttempts: 5,
  }),
  
  // Logger configuration
  logger: {
    debug: console.debug,
    info: console.info,
    warn: console.warn,
    error: console.error,
  },
  
  // Middleware stack
  middleware: [customMiddleware, loggingMiddleware],
  
  // Force dev or cloud mode
  isDev: process.env.NODE_ENV === "development",
});
```

### Client Configuration Options

| Option | Type | Description |
|--------|------|-------------|
| `id` | string (required) | Unique identifier for your application. Use hyphenated slug format. |
| `name` | string (optional) | Display name shown in the Inngest dashboard. |
| `eventKey` | string (optional) | Inngest event key for signing events. Prefer environment variable `INNGEST_EVENT_KEY`. |
| `signingKey` | string (optional) | Used to verify incoming requests. |
| `baseUrl` | string (optional) | Override default base URL for sending events. Use `INNGEST_BASE_URL` env var. |
| `env` | string (optional) | Environment name, required for Branch Environments. |
| `isDev` | boolean (optional) | Force Dev mode (disables signature verification) or Cloud mode. |
| `retryFunction` | function (optional) | Custom retry strategy for all functions. |
| `logger` | Logger (optional) | Logger object with `.info()`, `.warn()`, `.error()`, `.debug()` methods. |
| `middleware` | array (optional) | Stack of middleware to add to the client. |

### Environment Variables

```bash
# Required for production
INNGEST_EVENT_KEY="ev_..."       # For signing events
INNGEST_SIGNING_KEY="sign_..."   # For verifying incoming requests

# Optional
INNGEST_BASE_URL="https://..."   # Override default API URL
INNGEST_DEV="true"               # Force dev mode
INNGEST_RETRY_ATTEMPTS="5"       # Default retry count
```

---

## A.2 Creating Functions

### Basic Function Structure

```typescript
import { inngest } from "@/inngest/client";

export const myWorkflow = inngest.createFunction(
  {
    // Function configuration
    id: "my-workflow",
    name: "My Workflow",
    retries: 3,
    retryDelay: "5s",
  },
  // Trigger definition
  { event: "app/event.name" },
  // Handler function
  async ({ event, step, logger }) => {
    // Workflow logic
    const result = await step.run("do-something", async () => {
      return { processed: true };
    });
    return result;
  }
);
```

### Function Configuration Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | string (required) | Unique identifier for the function. |
| `name` | string (optional) | Display name in dashboard. |
| `retries` | number (optional) | Number of retry attempts for failed steps (default: 3). |
| `retryDelay` | string (optional) | Delay between retries (e.g., "5s", "1m"). |
| `concurrency` | object (optional) | Concurrency limits. |
| `rateLimit` | object (optional) | Rate limiting configuration. |
| `debounce` | object (optional) | Debounce configuration. |
| `throttle` | object (optional) | Throttling configuration. |
| `idempotency` | object (optional) | Idempotency configuration. |
| `version` | string (optional) | Function version for safe deployments. |

---

## A.3 Triggers

### Event Triggers

```typescript
import { eventType } from "inngest";
import { z } from "zod";

// Define a typed event with validation
const orderPlaced = eventType("shop/order.placed", {
  schema: z.object({
    orderId: z.string().uuid(),
    total: z.number().positive(),
    items: z.array(z.object({
      productId: z.string(),
      quantity: z.number(),
    })),
  }),
});

// Use as a trigger with type safety
inngest.createFunction(
  {
    id: "process-order",
    triggers: [orderPlaced],
  },
  async ({ event }) => {
    // event.data is fully typed
    console.log(event.data.orderId);
  }
);

// Use with if condition
inngest.createFunction(
  {
    id: "process-large-orders",
    triggers: [{
      event: orderPlaced,
      if: "event.data.total > 100",
    }],
  },
  async ({ event }) => {
    // Only runs for orders over 100
  }
);
```

### Cron Triggers

```typescript
import { cron } from "inngest";

// Simple cron trigger
inngest.createFunction(
  {
    id: "daily-cleanup",
    triggers: [cron("0 0 * * *")], // Every day at midnight UTC
  },
  async ({ step }) => {
    // Cleanup logic
  }
);

// Cron with jitter
inngest.createFunction(
  {
    id: "hourly-sync",
    triggers: [{
      cron: "0 * * * *",
      jitter: "30s", // Random delay up to 30 seconds after boundary
    }],
  },
  async ({ step }) => {
    // Sync logic
  }
);

// Timezone-aware cron
inngest.createFunction(
  {
    id: "eod-report",
    triggers: [cron("TZ=America/New_York 0 17 * * 5")], // Friday 5pm ET
  },
  async ({ step }) => {
    // End of week report
  }
);
```

### Wildcard Triggers

```typescript
// Match any user-related event
const anyUserEvent = eventType("user/*");

inngest.createFunction(
  {
    id: "audit-user-events",
    triggers: [anyUserEvent],
  },
  async ({ event }) => {
    // Triggers on user.created, user.updated, user.deleted, etc.
    console.log(`User event: ${event.name}`);
  }
);
```

---

## A.4 Step API

### step.run() - Executing Steps

```typescript
// Basic step execution
const result = await step.run("fetch-data", async () => {
  const data = await fetch("https://api.example.com/data");
  return data.json();
});

// Step with return value
const user = await step.run("get-user", async () => {
  return await db.user.findUnique({ where: { id: userId } });
});

// Step with no return value (side effects only)
await step.run("send-notification", async () => {
  await emailService.send({ to: user.email, subject: "Welcome" });
});

// Steps with async operations
const processedData = await step.run("process-data", async () => {
  const raw = await fetchRawData();
  const transformed = transformData(raw);
  await saveToDatabase(transformed);
  return transformed;
});
```

### Parallel Steps

```typescript
// Run multiple steps in parallel
const [user, orders, profile] = await Promise.all([
  step.run("get-user", () => db.user.findUnique({ where: { id: userId } })),
  step.run("get-orders", () => db.order.findMany({ where: { userId } })),
  step.run("get-profile", () => db.profile.findUnique({ where: { userId } })),
]);

// Fan-out pattern with parallel execution
const results = await Promise.all(
  items.map((item, index) =>
    step.run(`process-item-${index}`, () => processItem(item))
  )
);
```

### step.sleep() - Delays

```typescript
// Sleep for a duration (milliseconds)
await step.sleep("wait-5-seconds", 5000);

// Sleep with duration string
await step.sleep("wait-1-minute", "1m");

// Sleep until a specific date
const targetDate = new Date("2024-12-31T23:59:59");
await step.sleepUntil("wait-for-new-year", targetDate);

// Calculated wait time
const waitTime = new Date(event.data.scheduledFor).getTime() - Date.now();
if (waitTime > 0) {
  await step.sleep("wait-for-schedule", waitTime);
}
```

### step.waitForEvent() - Waiting for Events

```typescript
// Wait for a single event
try {
  const decision = await step.waitForEvent("wait-for-approval", {
    event: "purchase/approved",
    timeout: "24h",
  });
  
  // Handle decision
  if (decision.data.approved) {
    await executePurchase();
  }
} catch {
  // Timeout handling
  await handleTimeout();
}

// Wait with matching
const approval = await step.waitForEvent("wait-for-approval", {
  event: "purchase/approved",
  timeout: "24h",
  match: (data: any) => data.purchaseId === purchaseId,
});

// Wait for multiple events
const result = await step.waitForEvent("wait-for-decision", {
  event: ["order/approved", "order/denied"],
  timeout: "7d",
});

// Wait with condition
const event = await step.waitForEvent("wait-for-event", {
  event: "system/notification",
  timeout: "1h",
  if: "data.priority === 'high'",
});
```

### step.sendEvent() - Sending Events from Steps

```typescript
// Send a single event from a step
const { ids } = await step.sendEvent("notify-order", {
  name: "order/processed",
  data: {
    orderId: event.data.orderId,
    status: "completed",
  },
});

// Send multiple events
await step.sendEvent("send-notifications", [
  {
    name: "user/welcome-email",
    data: { userId: user.id },
  },
  {
    name: "crm/sync-requested",
    data: { userId: user.id },
  },
]);

// Use eventType for typed payloads
const orderCreated = eventType("order/created", {
  schema: z.object({ orderId: z.string() }),
});

await step.sendEvent("send-order-event",
  orderCreated.create({
    orderId: "order-123",
  })
);
```

### step.fetch() - Durable HTTP Requests

```typescript
// Basic durable fetch
const response = await step.fetch("fetch-api-data", {
  url: "https://api.example.com/data",
  method: "GET",
  headers: {
    "Authorization": `Bearer ${process.env.API_KEY}`,
  },
});
const data = await response.json();

// POST request with body
const result = await step.fetch("create-resource", {
  url: "https://api.example.com/resources",
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ name: "New Resource" }),
});

// Parallel fetches
const responses = await Promise.all(
  urls.map((url, index) =>
    step.fetch(`fetch-url-${index}`, { url })
  )
);
```

### step.realtime.publish() - Durable Realtime Publishing

```typescript
import { realtime } from "inngest";

// Define a channel
const pipelineChannel = realtime.channel({
  name: ({ runId }: { runId: string }) => `pipeline:${runId}`,
  topics: {
    status: {
      schema: z.object({ message: z.string() }),
    },
  },
});

// In your function, durable publish
const ch = pipelineChannel({ runId: event.data.runId });

// Durable publish (recommended for important state changes)
await step.realtime.publish("update-status", ch.status, {
  message: "Processing started...",
});

// Non-durable publish (faster, but may replay on retry)
await publish(ch.status, {
  message: "This may replay",
});
```

---

## A.5 AI and LLM Integration

### step.ai.infer() - Offloaded AI Calls

```typescript
// Call OpenAI with offloaded inference
const response = await step.ai.infer("call-openai", {
  model: step.ai.models.openai({ model: "gpt-4o" }),
  body: {
    messages: [
      { role: "system", content: "You are a helpful assistant." },
      { role: "user", content: "What is durable execution?" },
    ],
  },
});

// Call Anthropic Claude
const claudeResponse = await step.ai.infer("call-claude", {
  model: step.ai.models.anthropic({ model: "claude-3-5-sonnet-20241022" }),
  body: {
    messages: [{ role: "user", content: "Hello, Claude!" }],
  },
});

// Call Google Gemini
const geminiResponse = await step.ai.infer("call-gemini", {
  model: step.ai.models.gemini({ model: "gemini-1.5-pro" }),
  body: {
    contents: [{ parts: [{ text: "Explain AI" }] }],
  },
});
```

### step.ai.wrap() - Wrapping AI SDKs

```typescript
import { generateText } from "ai";
import { openai } from "@ai-sdk/openai";

// Wrap Vercel AI SDK call
const { text } = await step.ai.wrap("generate-content", generateText, {
  model: openai("gpt-4o-mini"),
  prompt: "Write a haiku about programming",
});

// Wrap with custom function for prompt editing in dev server
const args = {
  model: "gpt-4o-mini",
  prompt: "Write a haiku about recursion",
};

const gen = ({ model, prompt }: { model: string; prompt: string }) =>
  generateText({
    model: openai(model),
    prompt,
  });

await step.ai.wrap("generate-haiku", gen, args);

// Bind client context for Anthropic SDK
import Anthropic from "@anthropic-ai/sdk";
const anthropic = new Anthropic();
const createCompletion = anthropic.messages.create.bind(anthropic.messages);

await step.ai.wrap("call-anthropic", createCompletion, {
  model: "claude-3-5-sonnet-20241022",
  max_tokens: 1024,
  messages: [{ role: "user", content: "Hello" }],
});
```

### AgentKit Integration

```typescript
import { Agent, agenticOpenai as openai, createAgent } from "@inngest/agent-kit";

// Create an AI agent
const writer = createAgent({
  name: "writer",
  system: "You are an expert writer who creates clear, concise content.",
  model: openai({ model: "gpt-4o", step }),
});

// Run the agent
const { output } = await writer.run("Write a tweet about AI");

// Multi-agent workflow
const researcher = createAgent({
  name: "researcher",
  system: "You research topics thoroughly and provide factual information.",
  model: openai({ model: "gpt-4o", step }),
});

const content = await researcher.run(`Research: ${topic}`);
```

---

## A.6 Flow Control Configuration

### Concurrency

```typescript
// Function-level concurrency
concurrency: {
  limit: 10, // Max 10 concurrent runs
  scope: "fn", // Applies to this function only
}

// Key-based concurrency (per tenant/user)
concurrency: {
  limit: 5,
  scope: "key",
  key: "data.tenantId", // Each tenant gets 5 concurrent runs
}

// Global concurrency
concurrency: {
  limit: 100,
  scope: "global", // Across all functions
}
```

### Rate Limiting

```typescript
// Basic rate limiting
rateLimit: {
  limit: 100,
  period: "1m", // 100 runs per minute
}

// Key-based rate limiting
rateLimit: {
  limit: 10,
  period: "1s",
  key: "data.userId", // 10 runs per second per user
}
```

### Debouncing

```typescript
// Wait 30 seconds after the last event
debounce: {
  key: "data.userId",
  period: "30s",
}

// Wait for at least 5 events
debounce: {
  key: "data.tenantId",
  period: "10s",
}
```

### Batching

```typescript
// Collect up to 100 events or wait 60 seconds
batch: {
  maxSize: 100,
  timeout: "60s",
  key: "data.userId",
}
```

---

## A.7 Realtime Subscriptions (Client)

```typescript
"use client";
import { useRealtime } from "inngest/react";
import { pipelineChannel } from "../inngest/channels";

export default function PipelinePage({ runId }: { runId: string }) {
  const ch = pipelineChannel({ runId });
  const topics = ["status", "progress"] as const;

  const { connectionStatus, runStatus, messages } = useRealtime({
    channel: ch,
    topics,
    token: () =>
      fetch(`/api/realtime-token?runId=${runId}`).then((res) => res.json()),
  });

  return (
    <div>
      <p>Connection: {connectionStatus}</p>
      <p>Run: {runStatus}</p>
      {messages.byTopic.status && (
        <p>Status: {messages.byTopic.status.data.message}</p>
      )}
      <ul>
        {messages.all.map((msg, i) => (
          <li key={i}>
            [{msg.topic}] {JSON.stringify(msg.data)}
          </li>
        ))}
      </ul>
    </div>
  );
}
```

---

## A.8 Common Patterns Reference

### Retry Configuration

```typescript
// Function-level retries
retries: 3,
retryDelay: "5s",

// Custom retry function on client
retryFunction: (attempt: number) => ({
  delay: Math.min(Math.pow(2, attempt) * 1000, 60000),
  maxAttempts: 5,
}),

// Per-step retry handling
try {
  const result = await step.run("risky-operation", async () => {
    // This step has its own retry counter
    return await apiCall();
  });
} catch (error) {
  // Handle final failure after all retries
  await step.run("handle-failure", async () => {
    await compensateOperation();
  });
}
```

### Idempotency

```typescript
idempotency: {
  key: "data.orderId", // Prevent duplicate processing
  ttl: "30d", // How long to remember
}

// In step implementation
await step.run("process-payment", async () => {
  const idempotencyKey = `${event.data.orderId}-${Date.now()}`;
  // Check if already processed
  const existing = await db.find({ where: { idempotencyKey } });
  if (existing) return existing;
  // Process and store with key
  const result = await chargeCard();
  await db.create({ data: { ...result, idempotencyKey } });
  return result;
});
```

### Error Handling

```typescript
try {
  const result = await step.run("operation", async () => {
    // Throws on failure
    return await riskyOperation();
  });
} catch (error) {
  // Step failed after retries
  logger.error("Operation failed", { error });
  
  // Compensate or escalate
  await step.run("compensate", async () => {
    await rollbackOperation();
  });
  
  throw new Error(`Workflow failed: ${error.message}`);
}
```

---

## A.9 SDK v3 to v4 Migration Notes

### Key Changes

| Feature | v3 | v4 |
|---------|----|----|
| Triggers | String-based | `eventType()`, `cron()`, `invoke()` helpers |
| Realtime | Separate package | Built-in `realtime` module |
| Middleware | Limited | Enhanced middleware with full lifecycle |
| Type Safety | Basic | Full type inference with Standard Schema |
| AI Features | `step.ai` methods | Enhanced with `step.ai.infer()`, `step.ai.wrap()` |

### Migration Quick Checklist

```typescript
// v3
triggers: [{ event: "user/created" }]

// v4
import { eventType } from "inngest";
const userCreated = eventType("user/created", {
  schema: z.object({ userId: z.string() }),
});
triggers: [userCreated]
```

---

## A.10 Useful CLI Commands

```bash
# Start Dev Server
npx inngest-cli dev

# Run with auto-discovery
npx inngest-cli dev --pkg "@/*"

# Get API resources
inngest api get events
inngest api get runs --env prod

# Debug traces
inngest api get traces --run-id run_123

# Check health
curl http://localhost:8288/health
```

---

This appendix consolidates the essential APIs and patterns from the Inngest SDK v4. Use it as a quick reference while building your durable workflows. For detailed explanations and examples, refer to the corresponding chapters in the main series.
