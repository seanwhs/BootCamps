# Mastering Inngest: Building Reliable Serverless Workflows with Durable Execution

## Design Resilient Event-Driven Systems Without Managing Queues, Workers, or Workflow Infrastructure

---

# Appendix E: Glossary of Terms

This appendix provides a comprehensive glossary of terms used throughout the series. Terms are organized alphabetically with clear definitions, context, and cross-references to relevant parts of the series.

---

## A

### Action (Server Action)
*Introduced in Part 5*

A React 19 feature that allows running server-side logic directly from client components. Server Actions provide type-safe communication between the UI and server, making it easy to trigger workflows and handle responses.

**Context:** Used with `useActionState` and `useOptimistic` for building responsive UIs.

**Example:**
```typescript
'use server';
export async function triggerWorkflow(formData: FormData) {
  // Server-side logic
  const result = await inngest.send({
    name: 'workflow/trigger',
    data: { ... }
  });
  return result;
}
```

### Agent
*Introduced in Part 5*

An AI system designed to perform specific tasks autonomously. In Inngest, agents can be created using AgentKit to handle complex AI workflows with durable execution.

**Context:** Used for AI content generation, multi-agent systems, and LLM pipelines.

**Example:** An AI agent that writes blog posts, another that edits them, and a third that publishes them.

### Anti-Pattern
*Introduced in Appendix D*

A common practice or approach that appears to solve a problem but actually creates more issues. In durable workflows, common anti-patterns include giant steps, excessive state, and ignoring idempotency.

---

## B

### Batching
*Introduced in Part 3*

A pattern where multiple events are grouped together and processed as a single unit. Batching improves efficiency by reducing the overhead of processing each event individually.

**Context:** Used with `batch` configuration for collecting events before processing.

**Example:**
```typescript
batch: {
  maxSize: 100,
  timeout: '60s',
  key: 'data.tenantId',
}
```

### Blue-Green Deployment
*Introduced in Part 6*

A deployment strategy where two identical environments (blue and green) are maintained. Only one is active at a time, allowing zero-downtime deployments and easy rollbacks.

**Context:** Used with Inngest function versioning for safe deployments.

### Bulkhead Pattern
*Introduced in Appendix D*

A resource isolation pattern that prevents failures in one part of the system from cascading to others. In Inngest, this is implemented using concurrency limits.

**Context:** Used for tenant isolation and resource protection.

**Example:** Each tenant gets their own concurrency limit of 5 concurrent executions.

---

## C

### Canary Deployment
*Introduced in Appendix D*

A gradual deployment strategy where a new version is rolled out to a small percentage of users before full deployment.

**Context:** Used with feature flags or user segmentation to test new workflow versions.

### Checkpoint
*Introduced in Part 2*

A saved point in a workflow's execution. After each step completes, Inngest automatically creates a checkpoint. If a failure occurs, the workflow resumes from the last checkpoint.

**Context:** Core to durable execution - ensures progress is never lost.

### Circuit Breaker
*Introduced in Appendix D*

A pattern that prevents repeated calls to a failing service, allowing it time to recover. The circuit breaker has three states: closed (normal), open (failing), and half-open (testing recovery).

**Context:** Used to protect external services from being overwhelmed.

### Cold Start
*Introduced in Part 6*

The initial delay when a serverless function is invoked for the first time or after being idle. In Inngest, cold starts can affect workflow execution timing.

**Context:** Mitigated through warmup endpoints and connection pooling.

### Compensating Action
*Introduced in Part 2 and Part 4*

An operation that undoes the effects of a previous step in a workflow. Part of the Saga pattern, compensating actions ensure consistency when failures occur.

**Context:** Critical for transactional workflows and distributed systems.

**Example:** If a hotel booking fails, cancel the flight reservation that was already made.

### Concurrency
*Introduced in Part 3*

The number of workflow executions that can run simultaneously. Inngest supports concurrency limits at multiple levels: function-level, key-based, and global.

**Context:** Used to control resource usage and protect downstream systems.

**Example:**
```typescript
concurrency: {
  limit: 10,
  scope: 'fn',
}
```

### Cron Trigger
*Introduced in Part 4*

A scheduled trigger that executes a workflow at specific times or intervals, similar to traditional cron jobs.

**Context:** Used for scheduled maintenance, daily reports, and recurring tasks.

**Example:** `cron("0 0 * * *")` for daily midnight execution.

---

## D

### Dashboard (Inngest Dev Server)
*Introduced in Part 1*

The local development dashboard that shows workflow executions, events, and step-by-step progress in real-time. Accessed at `/api/inngest` during development.

**Context:** Essential for debugging and understanding workflow behavior.

### Dead Letter Queue (DLQ)
*Introduced in Appendix D*

A pattern where failed messages/events are stored for later analysis and manual processing.

**Context:** Used to handle unrecoverable failures and prevent data loss.

### Debouncing
*Introduced in Part 3*

A pattern that waits for a "quiet period" before executing a workflow, preventing rapid-fire events from triggering multiple executions.

**Context:** Used with `debounce` configuration for user actions and events.

**Example:**
```typescript
debounce: {
  key: 'data.userId',
  period: '30s',
}
```

### Deterministic Execution
*Introduced in Part 2*

The property where a step produces the same output given the same input. Determinism is essential for durable execution because steps may be replayed during retries.

**Context:** Avoid using `Math.random()` or `Date.now()` directly in steps.

### Domain Event
*Introduced in Part 1*

A meaningful occurrence in the domain that other parts of the system may react to. Events are the primary way to trigger workflows.

**Context:** Named using domain language (e.g., "OrderPlaced", "InvoiceGenerated").

### Durable Execution
*Introduced in Part 1 and Part 2*

The ability of a workflow to survive failures, retries, and infrastructure restarts. Inngest provides durable execution through automatic checkpointing, state management, and idempotency.

**Context:** The core capability that differentiates Inngest from traditional queues.

---

## E

### Event
*Introduced in Part 1*

A message that signals something has happened in the system. Events have a name (e.g., `user/registered`) and data payload.

**Context:** The trigger for all Inngest workflows.

### Event Sourcing
*Introduced in Part 4 (Bonus)*

A pattern where state changes are stored as a sequence of events, allowing reconstruction of state at any point in time.

**Context:** Used for audit trails, debugging, and rebuilding state.

### Event-Driven Architecture
*Introduced in Part 1*

An architectural style where components communicate through events rather than direct requests. Enables loose coupling and asynchronous processing.

**Context:** The foundation for building scalable, resilient systems.

### Exponential Backoff
*Introduced in Part 2*

A retry strategy where the delay between attempts increases exponentially (e.g., 1s, 2s, 4s, 8s). Reduces load on failing services.

**Context:** Default retry strategy in Inngest.

**Example:**
```typescript
retryFunction: (attempt: number) => ({
  delay: Math.min(Math.pow(2, attempt) * 1000, 60000),
  maxAttempts: 5,
})
```

---

## F

### Fan-Out / Fan-In
*Introduced in Part 3*

A pattern where one workflow splits into many parallel operations (fan-out) and later aggregates the results (fan-in).

**Context:** Used for bulk processing, parallel API calls, and data aggregation.

### Fault Tolerance
*Introduced in Part 2*

The ability of a system to continue operating correctly despite failures. Inngest provides fault tolerance through automatic retries, checkpointing, and state recovery.

### Function (Inngest Function)
*Introduced in Part 1*

A workflow defined using `inngest.createFunction()`. Functions respond to triggers and execute steps durably.

**Context:** The primary unit of work in Inngest.

---

## G

### Global Concurrency
*Introduced in Part 3*

A concurrency limit that applies across all functions, preventing the system from being overwhelmed.

**Context:** Used as a safety net for production systems.

### Graceful Degradation
*Introduced in Appendix D*

A design principle where a system continues to function, albeit with reduced capability, when parts of the system fail.

**Context:** Critical for building resilient workflows.

---

## H

### Health Check
*Introduced in Part 6*

An endpoint that verifies the system is running correctly. Health checks typically validate database connections, service availability, and basic functionality.

**Context:** Used for monitoring and load balancer health checks.

### Human-in-the-Loop
*Introduced in Part 4*

A pattern where workflows pause and wait for human input or decision before continuing.

**Context:** Used for approvals, reviews, and manual interventions.

**Example:** Purchase approval workflow waiting for a manager to approve.

---

## I

### Idempotency
*Introduced in Part 2*

The property where an operation can be performed multiple times without changing the result beyond the first execution. Essential for safe retries.

**Context:** Prevent duplicate charges, emails, and side effects.

**Example:**
```typescript
idempotency: {
  key: 'data.orderId',
  ttl: '30d',
}
```

### Integration Test
*Introduced in Part 6*

A test that verifies the interaction between multiple components, such as a workflow and its dependencies.

**Context:** Ensures workflows work correctly in the real environment.

### Inngest Dev Server
*Introduced in Part 1*

A local development server that simulates the Inngest execution environment. Provides real-time workflow visualization and debugging capabilities.

---

## J

### Jitter
*Introduced in Part 4*

Random variation added to timing to prevent the "thundering herd" problem where many processes start simultaneously.

**Context:** Used with cron triggers and retry delays.

**Example:**
```typescript
triggers: [{
  cron: '0 * * * *',
  jitter: '5m',
}]
```

---

## K

### Key-Based Concurrency
*Introduced in Part 3*

A concurrency limit that applies per key value, such as per tenant or per user.

**Context:** Used for resource isolation and fair resource allocation.

**Example:**
```typescript
concurrency: {
  limit: 5,
  scope: 'key',
  key: 'data.tenantId',
}
```

---

## L

### Long-Running Workflow
*Introduced in Part 4*

A workflow that may take minutes, hours, days, or even months to complete. Requires durable execution to survive interruptions.

**Context:** Used for business processes, approvals, and scheduled operations.

---

## M

### Memoization
*Introduced in Part 2*

The automatic caching of step results. If a step is retried, Inngest returns the cached result rather than re-executing the step.

**Context:** Prevents duplicate side effects during retries.

### Middleware
*Introduced in Part 1 and Part 2*

Code that runs before and after function execution, used for logging, metrics, authentication, and error tracking.

**Context:** Extensible hooks in the Inngest client.

**Example:**
```typescript
const loggingMiddleware = new InngestMiddleware({
  name: 'Logging',
  init: () => ({
    onFunctionRun: ({ fn }) => {
      console.log(`Starting ${fn.id}`);
    },
  }),
});
```

---

## N

### Next.js App Router
*Introduced in Part 5*

The newer routing system in Next.js that supports React Server Components and nested layouts. Used to host Inngest API endpoints.

**Context:** Integration point for Inngest with React frontends.

---

## O

### Observability
*Introduced in Part 6*

The ability to understand what's happening inside a system from external outputs (logs, metrics, traces).

**Context:** Essential for production workflow monitoring.

### Optimistic Update
*Introduced in Part 5*

A UI pattern where changes are shown immediately while the server processes them in the background. Uses React 19's `useOptimistic` hook.

**Context:** Creates responsive user experiences for long-running workflows.

---

## P

### Parallel Execution
*Introduced in Part 3*

Running multiple steps simultaneously using `Promise.all()` or similar patterns.

**Context:** Improves performance for independent operations.

### Pipeline (Event Pipeline)
*Introduced in Part 3*

A sequence of processing steps that transform data from input to output.

**Context:** Used for data processing, ETL, and AI workflows.

### Production Deployment
*Introduced in Part 6*

The process of deploying workflows to a production environment with appropriate configuration, security, and monitoring.

**Context:** Includes Vercel, AWS Lambda, and Docker deployments.

---

## R

### Rate Limiting
*Introduced in Part 3*

Limiting the number of workflow executions within a time period. Prevents abuse and protects downstream systems.

**Context:** Used with `rateLimit` configuration.

**Example:**
```typescript
rateLimit: {
  limit: 100,
  period: '1m',
}
```

### Realtime
*Introduced in Part 5*

Inngest's realtime feature for streaming workflow updates to clients via WebSockets or Server-Sent Events.

**Context:** Used for live dashboards and user notifications.

### Retry
*Introduced in Part 2*

Re-executing a failed step. Inngest supports automatic retries with configurable policies.

**Context:** Core to fault tolerance in durable execution.

### Run
*Introduced in Part 1*

A single execution of a workflow triggered by an event.

**Context:** Each run has a unique ID and execution history.

---

## S

### Saga Pattern
*Introduced in Part 4*

A pattern for managing distributed transactions using a sequence of local transactions with compensating actions.

**Context:** Used for multi-step business processes that span services.

### Server Action
*See Action (Server Action)*

### Server Component
*Introduced in Part 5*

A React component that runs on the server, used in Next.js App Router. Server Components can be combined with Server Actions to build full-stack applications.

### Server-Sent Events (SSE)
*Introduced in Part 5*

A technology for streaming server updates to the client over HTTP. Used for real-time workflow status updates.

### State (Workflow State)
*Introduced in Part 2*

The accumulated data and progress of a workflow run. Inngest automatically manages state through checkpointing.

### Step
*Introduced in Part 1*

A single unit of work within a workflow. Steps are defined using `step.run()` and are automatically checkpointed.

---

## T

### Throttling
*Introduced in Part 3*

Limiting the rate of execution by adding delays between operations.

**Context:** Used with `throttle` configuration for API calls.

**Example:**
```typescript
throttle: {
  limit: 10,
  period: '1s',
  key: 'data.tenantId',
}
```

### Thundering Herd
*Introduced in Appendix D*

A problem where many processes start simultaneously, overwhelming the system. Mitigated with jitter and scheduling delays.

### Trace
*Introduced in Part 6*

A record of a workflow's complete execution path, including all steps, timing, and errors.

**Context:** Used for debugging and performance analysis.

### Trigger
*Introduced in Part 1*

The event or schedule that initiates a workflow execution.

**Context:** Events, cron schedules, and invocations.

---

## U

### Unit Test
*Introduced in Part 6*

A test that verifies a single unit of code in isolation.

**Context:** Used to test individual workflow steps.

### useActionState
*Introduced in Part 5*

A React 19 hook that manages form state and pending states for Server Actions.

**Context:** Used for workflow trigger forms.

### useOptimistic
*Introduced in Part 5*

A React 19 hook for implementing optimistic UI updates.

**Context:** Used for immediate user feedback in workflows.

---

## V

### Versioning (Workflow Versioning)
*Introduced in Part 4*

The practice of maintaining multiple versions of a workflow to allow safe deployments and backward compatibility.

**Context:** Used with `version` configuration in functions.

**Example:**
```typescript
version: '2.0.0'
```

---

## W

### Wait for Event (step.waitForEvent())
*Introduced in Part 4*

A step that pauses workflow execution until an external event is received, with optional timeout.

**Context:** Used for human-in-the-loop and external service coordination.

### Workflow
*Introduced in Part 1*

A sequence of steps that process an event, managed by Inngest with durable execution.

**Context:** The primary construct in Inngest.

### Write-Ahead Log
*Introduced in Part 2*

A logging mechanism where changes are recorded before they are applied, enabling recovery after failures.

**Context:** The underlying mechanism for durable state management.

---

## Z

### Zod
*Introduced in Part 1*

A TypeScript-first schema validation library used for validating event data.

**Context:** Provides type safety and runtime validation.

**Example:**
```typescript
const schema = z.object({
  userId: z.string().uuid(),
  email: z.string().email(),
});
```

---

## Quick Reference: Core Concepts

| Term | Category | Part |
|------|----------|------|
| Durable Execution | Core | 1, 2 |
| Event | Core | 1 |
| Function | Core | 1 |
| Step | Core | 1 |
| Run | Core | 1 |
| Checkpoint | Core | 2 |
| Idempotency | Core | 2 |
| Retry | Core | 2 |
| Concurrency | Performance | 3 |
| Rate Limiting | Performance | 3 |
| Fan-Out/Fan-In | Performance | 3 |
| Saga Pattern | Long-Running | 4 |
| Human-in-the-Loop | Long-Running | 4 |
| waitForEvent | Long-Running | 4 |
| Server Action | Full-Stack | 5 |
| useActionState | Full-Stack | 5 |
| useOptimistic | Full-Stack | 5 |
| SSE | Full-Stack | 5 |
| Observability | Production | 6 |
| Circuit Breaker | Production | App D |
| Bulkhead | Production | App D |
| Blue-Green | Deployment | App D |

---

This glossary provides a comprehensive reference for all the terminology used throughout the Mastering Inngest series. Refer to it when encountering unfamiliar terms or when you need a quick reminder of a concept's definition and context.
