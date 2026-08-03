# Mastering Inngest: References & Resources

## Official Documentation

### Inngest Core Documentation
The Inngest documentation is the definitive source for SDK details, API references, and architectural concepts.

**Primary Resources:**
- **TypeScript SDK v4 Reference:** The v4 SDK delivers major upgrades including rewritten middleware, better schemas with Standard Schema support, faster parallel step optimization, improved structured logging, and cleaner APIs .
- **Inngest Client Setup:** The `Inngest` client is the core configuration object. It requires an `id` (unique application identifier) and accepts options like `eventKey`, `baseUrl`, `isDev`, and `logger`. **Best practice:** Share a single client instance across your codebase .
- **Next.js Quick Start:** A ten-minute tutorial for adding Inngest to a Next.js app using the App Router. Covers installation, the Dev Server, client creation, writing your first function, and triggering it .
- **LLM-Ready Documentation:** AI-friendly docs are available at `inngest.com/llms.txt` (table of contents for smaller contexts) and `inngest.com/llms-full.txt` (full markdown) .

---

## Architecture & Patterns

### Flow Control Patterns
Managing traffic spikes and protecting downstream services is critical for production workflows.

**Four Core Primitives :**

| Pattern | When to Use | What It Does |
|---------|-------------|--------------|
| **Throttle** | External APIs return 429s or timeout | Caps executions per time window |
| **Concurrency** | Too many functions hit the same resource | Caps parallel executions per key |
| **Debounce** | One action triggers the same function multiple times | Waits for a burst to settle, runs once |
| **Idempotency** | Webhooks or events arrive more than once | Guarantees exactly-once execution per key |

**Throttle vs. Concurrency:**
- **Throttle** is about **rate** (X per minute). Use when an API says "100 requests per minute."
- **Concurrency** is about **parallelism** (X at the same time). Use when a database performs poorly with more than 20 concurrent writes.

**Key Code Patterns:**
```typescript
// Throttle: stay under a provider's rate limit
throttle: {
  limit: 80,
  period: "1m",
  key: "event.data.carrier", // separate budget per carrier
}

// Concurrency: protect a warehouse API
concurrency: [
  {
    key: "event.data.warehouse_id",
    limit: 10,
  },
]

// Debounce: one execution per order, wait 30s after last event
debounce: {
  key: "event.data.order_id",
  period: "30s",
}

// Idempotency: one execution per payment, guaranteed
idempotency: "event.data.payment_id",
```

### Durable Execution Patterns
Breaking long-running jobs into discrete, independently retried steps is the core of durable execution .

**Key Design Principles :**
- **Determinism and Replay:** Code inside steps must be deterministic; replay uses cached step results.
- **Idempotency:** Use at-most-once vs. at-least-once carefully. Pair with idempotency tokens and database patterns.
- **Manage State:** Checkpoint size matters. Store references instead of payloads to avoid size limits.
- **Step Design:** Consider naming, granularity, error handling inside steps, and the boundary between orchestration and business logic.

**Example: Multi-Step AI Pipeline **
```typescript
export const processDocument = inngest.createFunction(
  { id: "process-uploaded-document" },
  async ({ event, step }) => {
    // Step 1: Validate the upload
    const { isValid } = await step.run("validate-upload", async () => {
      return validateDocument(file);
    });

    // Step 2: Extract and summarize content with an LLM
    const summary = await step.run("summarize-content", async () => {
      return await llm.summarize(content);
    });

    // Step 3: Classify the document
    const classification = await step.run("classify-document", async () => {
      return await llm.classify(summary);
    });

    // Step 4: Store results
    await step.run("save-results", async () => {
      await db.documents.update({ data: { summary, classification } });
    });

    // Step 5: Notify the user
    await step.run("notify-success", async () => {
      await sendProcessingCompleteEmail(userId, documentId);
    });
  }
);
```

---

## AI & Agent Workflows

### Building Durable AI Agents
AI agents are loops: Think → Act → Observe → Repeat. Inngest makes each step durable .

**Three Primitives for AI Agents :**
- `step.run()` - Execute a unit of work durably. Use for LLM calls, tool execution, saving data. Each step is memoized.
- `step.invoke()` - Call another Inngest function and wait. Delegate to sub-agents synchronously.
- `step.sendEvent()` - Fire-and-forget event emission. Trigger async work or schedule future tasks.

**Key AI Agent Loop Structure :**
```typescript
while (!done && iterations < maxIterations) {
  iterations++;
  // Think: call the LLM
  const llmResponse = await step.run("think", async () => {
    return await callLLM(systemPrompt, messages, tools);
  });
  const toolCalls = llmResponse.toolCalls;
  if (toolCalls.length > 0) {
    messages.push(llmResponse.message);
    // Act: execute each tool
    for (const tc of toolCalls) {
      const toolResult = await step.run(`tool-${tc.name}`, async () => {
        return await executeTool(tc);
      });
      // Observe: feed result back
      messages.push(toolResult);
    }
  } else if (llmResponse.text) {
    finalResponse = llmResponse.text;
    done = true;
  }
}
```

**Why Durable Steps Matter for AI :**
- Each tool call is independently retryable. If a tool times out, Inngest retries **that step**—not the entire loop iteration.
- Tool results are memoized. On restart, completed steps return cached results instantly. No re-execution.
- You get a trace per tool call in the dashboard—input, output, and duration.

---

## CLI & Developer Tools

### Inngest CLI
The CLI provides terminal-first access to your Inngest data .

**Installation:**
```bash
curl -sfL https://cli.inngest.com/install.sh | sh
```

**Key Commands :**
```bash
# Set your API key
export INNGEST_API_KEY=sk-inn-api-...

# Get a function run
inngest api get-function-run 01KTCTWT8XDEGWDMVX3Q9M69ND

# Get runs triggered by an event
inngest api get-event-runs 01KTCTWSZJEKAFEDA4F9GYHFQW --include-output --limit 5

# Invoke a function
inngest api invoke-function my-app my-function --data '{"message": "hello"}'

# Fetch a full trace
inngest api get-function-trace 01KTCTWT8XDEGWDMVX3Q9M69ND --include-output
```

**Target Resolution :**
- Local dev server (default): no flags needed
- Inngest Cloud: `--prod` flag
- Custom host: `--api-host` flag

### Dev Server
The Dev Server is a local environment where you can send events, trigger functions, and inspect runs in real time .

**Installation & Setup:**
```bash
# Install the CLI
curl -sSfL https://cli.inngest.com/install.sh | sh

# Run the dev server
inngest dev

# With dev mode enabled (v4 SDK)
INNGEST_DEV=1 npm run dev
```

Open `http://localhost:8288` to see the Dev Server UI .

### LLM-Ready Documentation
For AI coding agents building with Inngest, the docs are available in LLM-friendly formats :
- `inngest.com/llms.txt` - Table of contents for smaller contexts
- `inngest.com/llms-full.txt` - Full docs in markdown format

---

## Realtime Publishing (TypeScript SDK v4)

The v4 SDK includes a built-in realtime system for streaming updates from Inngest functions to client applications .

**Key Concepts :**
- **Channels:** Named scope for messages (static or parameterized with runtime values like `runId`).
- **Topics:** Typed message streams within a channel, each with a schema.
- **Durable Publishing:** Prefer `step.realtime.publish()` for publishes inside functions. It is memoized and durable.
- **React Subscription:** `useRealtime` hook for consuming realtime updates in React components.

**Quick Start Example :**
```typescript
// 1. Define a channel
const pipelineChannel = realtime.channel({
  name: ({ runId }: { runId: string }) => `pipeline:${runId}`,
  topics: {
    status: { schema: z.object({ message: z.string() }) },
    tokens: { schema: staticSchema<{ token: string }>() },
  },
});

// 2. Publish from a function
export const generate = inngest.createFunction(
  { id: "generate" },
  async ({ event, publish, step }) => {
    const ch = pipelineChannel({ runId: event.data.runId });
    await publish(ch.status, { message: "Starting..." });
    // Prefer durable publish for important state changes
    await step.realtime.publish("final-status", ch.status, {
      message: "Done!",
    });
  }
);

// 3. Subscribe from React
const { messages } = useRealtime({
  channel: pipelineChannel({ runId }),
  topics: ["status", "tokens"],
  token: () => fetch(`/api/realtime-token?runId=${runId}`).then(r => r.json()),
});
```

---

## Community & Additional Resources

- **GitHub:** Inngest TypeScript SDK and related packages are open source at [inngest/inngest-js](https://github.com/inngest/inngest-js) .
- **Official Libraries :**
  - `inngest` - The Inngest SDK
  - `@inngest/eslint-plugin` - Specific ESLint rules for Inngest
  - `@inngest/middleware-encryption` - Middleware providing end-to-end encryption
- **SDK Reference Hub:** [inngest.com/docs/reference](https://inngest.vercel.app/docs/reference) covers TypeScript v3/v4, Python SDK, Go SDK, and the REST API .

---

## Suggested Learning Path

1. **Start with the Quick Start:** [Next.js Quick Start](https://inngest.vercel.app/docs/getting-started/nextjs-quick-start) 
2. **Master Flow Control:** Understand throttling, concurrency, debouncing, and idempotency 
3. **Build Multi-Step Workflows:** Create durable, independently retried pipelines 
4. **Add AI Agents:** Build the agent loop with durable tool execution 
5. **Add Real-time:** Stream status to clients with v4 realtime 
6. **Deploy to Production:** Use CLI commands and Cloud mode 
