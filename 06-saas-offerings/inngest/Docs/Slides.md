# Mastering Inngest: Complete Slide Outline

## Teaching the Series — Comprehensive Presentation Framework

---

## Overview

This slide outline transforms the "Mastering Inngest" series into a comprehensive teaching presentation. It follows the "Tell 'em what you're going to tell 'em, tell 'em, tell 'em what you've told 'em" structure , with each part expanded into detailed slides suitable for a workshop, course, or conference talk.

**Total Slides: 127**
**Estimated Delivery Time: 6-8 hours (with demos)**

---

## PART 0: Introduction & Series Roadmap

### Section 0.1: Opening (3 slides)

#### Slide 0.1: Title
- **Title:** Mastering Inngest: Building Reliable Serverless Workflows with Durable Execution
- **Subtitle:** Design Resilient Event-Driven Systems Without Managing Queues, Workers, or Workflow Infrastructure
- **Visual:** Inngest logo + architecture diagram placeholder
- **Presenter Notes:** "Welcome. Today we're going to completely change how you think about background jobs and workflow orchestration."

#### Slide 0.2: The Problem We're Solving 
- **Title:** The Hidden Complexity of Modern Applications
- **Bullet Points:**
  - Applications rarely consist of a single request and response
  - They send emails, process payments, generate reports, synchronize data, perform AI inference
  - Building these traditionally requires: Message queues, Cron jobs, Retry mechanisms, Distributed locks, Workflow engines, State stores, Custom monitoring
- **Visual:** Complex diagram showing all pieces
- **Presenter Notes:** "Ask the audience: Who's built a background job system? Who's dealt with duplicate emails? Who's had a job fail halfway through and not know where to resume?"

#### Slide 0.3: The Cost of Traditional Approaches 
- **Title:** Why Traditional Background Processing Fails
- **Bullet Points:**
  - ❌ Complex queue configuration
  - ❌ Manual retry logic
  - ❌ Poor observability
  - ❌ Not serverless-friendly
  - ❌ Long-running workers & polling for messages
  - ❌ No message history for replay/complex system recovery
- **Visual:** Comparison table (Traditional Queues vs Event Streams vs Inngest)
- **Presenter Notes:** "Serverless platforms make this even harder because functions are short-lived and stateless. You can't just poll a queue indefinitely."

---

### Section 0.2: The Solution (3 slides)

#### Slide 0.4: What is Inngest? 
- **Title:** Inngest — Queuing and Orchestration for Modern Software Teams
- **Subtitle:** A developer-first platform for building event-driven background jobs and workflows
- **Bullet Points:**
  - Write reliable, fault-tolerant code with ease
  - Run on serverless, servers, or both
  - No queues, workers, or additional state management required
- **Key Quote:** "Inngest reimagines workflow orchestration through durable execution"
- **Visual:** Inngest platform diagram

#### Slide 0.5: Core Concepts Preview 
- **Title:** Three Primitives — All You Need
- **Card Layout:**
  1. **Events** — The backbone of Inngest. Signals that something happened.
  2. **Functions** — Workflows that run when events occur.
  3. **Steps** — Individual units of work, independently retryable.
- **Visual:** Flow diagram showing Event → Function → Steps → Result
- **Presenter Notes:** "Everything in Inngest is built on these three concepts. Master them, and you've mastered the platform."

#### Slide 0.6: What Makes Inngest Different? 
- **Title:** Key Differentiators
- **Bullet Points:**
  - ✅ Built-in retries and idempotency
  - ✅ Long-running workflows (minutes, hours, days)
  - ✅ Observability dashboard
  - ✅ Serverless-friendly
  - ✅ Step orchestration with automatic state management
  - ✅ No infrastructure to manage
- **Visual:** Side-by-side comparison with traditional queues
- **Presenter Notes:** "This isn't just another queue. It's a fundamentally different approach to building reliable systems."

---

### Section 0.3: What You'll Build (2 slides)

#### Slide 0.7: The Application Stack
- **Title:** The Architecture You'll Build
- **Visual:** Stack diagram showing:
  - Frontend Layer: Next.js 16 + React 19
  - API Layer: Route Handlers & Server Actions
  - Orchestration Layer: Inngest Durable Execution
  - External Services: Database, Email, Payment, Storage, AI
- **Presenter Notes:** "By the end of this series, you'll have built a complete production-ready application."

#### Slide 0.8: The Workflows You'll Build
- **Title:** Six Production-Ready Workflows
- **Bullet Points:**
  1. User Registration Pipeline (Part 1)
  2. Invoice Generation (Part 2)
  3. Bulk Email Campaign (Part 3)
  4. Purchase Approval System (Part 4)
  5. AI Content Generation Dashboard (Part 5)
  6. Production Deployment Pipeline (Part 6)
- **Visual:** Each workflow as a card with icon
- **Presenter Notes:** "You're not just learning theory. Every part ends with a working, production-ready workflow."

---

### Section 0.4: Series Navigation (2 slides)

#### Slide 0.9: Series Structure
- **Title:** The Path to Mastery
- **Visual:** Timeline/roadmap showing:
  - Part 1: Foundations (2 hours reading, 4 hours coding)
  - Part 2: State Management (2.5h, 5h)
  - Part 3: Performance (2h, 4h)
  - Part 4: Long-Running (2h, 4h)
  - Part 5: Full-Stack (2.5h, 5h)
  - Part 6: Production (2h, 3h)
- **Presenter Notes:** "Each part builds on the previous. Follow them in order."

#### Slide 0.10: Prerequisites
- **Title:** What You Need to Know
- **Bullet Points:**
  - JavaScript (ES2023+) or TypeScript
  - Node.js
  - Modern React
  - Next.js App Router
  - REST APIs
  - Async programming (Promises, async/await)
- **Note:** No prior experience with workflow engines or distributed systems required.
- **Presenter Notes:** "If you're comfortable with modern JavaScript and React, you're ready for this series."

---

## PART 1: Foundations — Thinking in Events and Durable Execution

### Section 1.1: Event-Driven Architecture (4 slides)

#### Slide 1.1: Module Introduction
- **Title:** Part 1 — Foundations
- **Subtitle:** Thinking in Events and Durable Execution
- **Learning Objectives:**
  - Understand the limitations of traditional background processing
  - Learn the principles of durable execution
  - Build your first event-driven workflow
- **Presenter Notes:** "We start from first principles. No assumptions about what you already know."

#### Slide 1.2: The Restaurant Analogy
- **Title:** Event-Driven Architecture Explained
- **Visual:** Side-by-side comparison:
  - **Traditional (REST):** Customer waits at counter while entire meal prepared
  - **Event-Driven:** Kitchen with expediter, grill cook, saute cook, plater working asynchronously
- **Key Insight:** Events are just messages that say "something happened."
- **Presenter Notes:** "This analogy will make everything click. Think of events as orders in a kitchen."

#### Slide 1.3: Event Flow Architecture
- **Title:** How Events Flow Through Your System
- **Visual:** Flow diagram:
  ```
  User Signs Up → Frontend Sends Event → Inngest Event API → 
  Inngest Function Runner → Step 1: Send Welcome Email → 
  Step 2: Create Profile → Step 3: Sync to CRM
  ```
- **Presenter Notes:** "Every event follows this same path. Learn it once, apply it everywhere."

#### Slide 1.4: Project Setup
- **Title:** Getting Started with Code
- **Commands:**
  ```bash
  pnpm create next-app@latest workflowhub --typescript --tailwind --app
  cd workflowhub
  pnpm add inngest inngest/next
  pnpm add zod uuid
  ```
- **Key Files Created:**
  - `src/inngest/client.ts`
  - `src/app/api/inngest/route.ts`
- **Presenter Notes:** "Let's fire up our editors and build something."

---

### Section 1.2: First Workflow (4 slides)

#### Slide 1.5: The Inngest Client
- **Title:** Creating the Inngest Client
- **Code:**
  ```typescript
  // src/inngest/client.ts
  import { Inngest } from 'inngest';
  export const inngest = new Inngest({
    id: 'workflowhub',
    name: 'WorkflowHub',
    eventKey: process.env.INNGEST_EVENT_KEY,
    retryFunction: (attempt) => ({
      delay: Math.min(Math.pow(2, attempt) * 1000, 60000),
      maxAttempts: 5,
    }),
  });
  ```
- **Key Concepts:**
  - `id`: Unique identifier
  - `eventKey`: For signing events (security)
  - `retryFunction`: Exponential backoff strategy
- **Presenter Notes:** "This is your control center. Every workflow starts here."

#### Slide 1.6: User Registration Workflow
- **Title:** Your First Durable Function
- **Code:** (Show full function with steps)
  ```typescript
  export const userRegistrationWorkflow = inngest.createFunction(
    { id: 'user-registration-workflow' },
    { event: 'user/registered' },
    async ({ event, step, logger }) => {
      // Step 1: Send welcome email
      const emailResult = await step.run('send-welcome-email', async () => {
        // email logic
      });
      // Step 2: Create profile
      // Step 3: Sync with CRM
    }
  );
  ```
- **Presenter Notes:** "This is a complete, production-ready workflow. We'll dissect each piece."

#### Slide 1.7: Anatomy of a Function
- **Title:** Breaking It Down — Three Parts
- **Visual:** Annotated function showing:
  1. **Configuration Object:** id, retries, concurrency
  2. **Trigger Definition:** What event starts this workflow
  3. **Handler Function:** The actual workflow logic
- **Key Concept:** `step.run()` creates a durable step — automatically retried on failure
- **Presenter Notes:** "Every function has these three parts. Once you understand this pattern, you can build anything."

#### Slide 1.8: Running Locally
- **Title:** The Inngest Dev Server 
- **Commands:**
  ```bash
  # Install the CLI
  curl -sSfL https://cli.inngest.com/install.sh | sh
  
  # Run the dev server
  inngest dev -u http://localhost:3000/api/inngest
  ```
- **Visual:** Screenshot of Dev Server UI showing functions, runs, and events
- **Key Features:**
  - Real-time execution dashboard
  - Step-by-step tracing
  - Retry simulation
  - Event replay
- **Presenter Notes:** "This is where you'll spend most of your development time. It's the most powerful local development tool in the ecosystem."

---

### Section 1.3: Testing Your Workflow (2 slides)

#### Slide 1.9: Triggering Events
- **Title:** Testing Your Workflow
- **Methods:**
  1. **From Dev Server UI:** Click "Invoke" on the function
  2. **From curl:**
  ```bash
  curl -X POST http://localhost:3000/api/inngest \
    -H "Content-Type: application/json" \
    -d '{"name":"user/registered","data":{...}}'
  ```
  3. **From Code:** `await inngest.send({ name: "user/registered", data: {...} })`
- **Presenter Notes:** "Three ways to trigger. Pick the one that works for your workflow."

#### Slide 1.10: Monitoring Execution
- **Title:** What You See in the Dev Server
- **Visual:** Screenshot of:
  - Recent Events list
  - Run details with steps
  - Step-by-step execution timeline
  - Input/output for each step
- **Key Insight:** Each step's result is memoized — if retried, returns cached result
- **Presenter Notes:** "This visibility is game-changing. You can see exactly what happened, step by step."

---

## PART 2: Durable Functions, State Management & Fault Tolerance

### Section 2.1: Deep Dive into Durable Execution (4 slides)

#### Slide 2.1: Module Introduction
- **Title:** Part 2 — Durable Functions, State Management & Fault Tolerance
- **Learning Objectives:**
  - Build workflows resilient to crashes
  - Understand deterministic execution
  - Manage state safely across workflow steps
- **Presenter Notes:** "This is where we go deep. Everything you need to build workflows that never lose state."

#### Slide 2.2: The Autosave Analogy
- **Title:** Think of Durable Execution Like Autosave
- **Visual:** Side-by-side:
  - **No Autosave:** Computer crashes, lose everything, start over
  - **With Autosave:** Computer crashes, resume exactly where you left off
- **Key Insight:** After each step, Inngest "autosaves" the workflow state
- **Presenter Notes:** "If anything fails, the workflow time-travels back to the last successful step."

#### Slide 2.3: Checkpointing Mechanism
- **Title:** How Checkpointing Works
- **Visual:** Flow diagram showing:
  ```
  Step 1 → [SAVE] → Step 2 → [SAVE] → Step 3 → [SAVE]
              ↓            ↓              ↓
          Checkpoint  Checkpoint      Checkpoint
  ```
- **Key Concepts:**
  - "Started" entry written before step
  - Result saved after completion
  - On failure, resume from last checkpoint
- **Presenter Notes:** "This is the magic. Every step is checkpointed."

#### Slide 2.4: Idempotency Explained
- **Title:** Exactly-Once Execution
- **Definition:** An operation can be performed multiple times without changing the result beyond the first execution
- **Example:**
  ```typescript
  // ❌ Non-idempotent
  await chargeCard(orderId); // Could charge twice on retry
  
  // ✅ Idempotent
  const result = await step.run('process-payment', async () => {
    const existing = await db.payments.findUnique({ where: { orderId } });
    if (existing) return existing;
    const result = await chargeCard(orderId);
    await db.payments.create({ data: { orderId, ...result } });
    return result;
  });
  ```
- **Presenter Notes:** "Idempotency is how you prevent duplicate charges, emails, and side effects. Implement it in every step with side effects."

---

### Section 2.2: State Management (3 slides)

#### Slide 2.5: Passing Data Between Steps
- **Title:** Data Flows Through Your Workflow
- **Visual:** Flow diagram showing:
  ```
  Step 1 → Returns data → Step 2 uses data → Returns more data → Step 3...
  ```
- **Example:**
  ```typescript
  const user = await step.run('get-user', async () => {
    return await db.user.findUnique({ where: { id: userId } });
  });
  const orders = await step.run('get-orders', async () => {
    return await db.order.findMany({ where: { userId: user.id } });
  });
  ```
- **Key Insight:** Data returned from one step is available in all subsequent steps
- **Presenter Notes:** "Think of it like a relay race. Each runner passes the baton."

#### Slide 2.6: The Invoice Generation Workflow
- **Title:** Real-World Example — Invoice Generation
- **Visual:** Flow diagram showing steps:
  1. Calculate totals
  2. Generate PDF
  3. Format email content
  4. Send invoice
  5. Store record
- **Code:** Show step sequence with state flowing between them
- **Key Concept:** Each step builds on the previous step's results
- **Presenter Notes:** "This is a complete business process. Every step is durable."

#### Slide 2.7: State Minimalism
- **Title:** Don't Store Everything
- **❌ Anti-Pattern:**
  ```typescript
  const fullUser = await step.run('get-user', async () => {
    return await db.user.findUnique({
      include: { orders: true, profile: true, history: true }
    });
  });
  ```
- **✅ Best Practice:**
  ```typescript
  const user = await step.run('get-user', async () => {
    return await db.user.findUnique({
      select: { id: true, email: true, name: true }
    });
  });
  ```
- **Key Insight:** Large state objects slow execution and increase memory usage
- **Presenter Notes:** "Store only what you need. Access everything else on demand."

---

### Section 2.3: Error Handling (3 slides)

#### Slide 2.8: Automatic Retry Strategy
- **Title:** Built-in Retry with Exponential Backoff
- **Configuration:**
  ```typescript
  retryFunction: (attempt: number) => ({
    delay: Math.min(Math.pow(2, attempt) * 1000, 60000),
    maxAttempts: 5,
  })
  ```
- **Visual:** Graph showing exponential backoff: 1s → 2s → 4s → 8s → 16s → 32s
- **Key Insight:** Only the failed step retries, not the entire workflow
- **Presenter Notes:** "This is the difference between a brittle system and a resilient one."

#### Slide 2.9: Compensating Actions (Saga Pattern)
- **Title:** Undoing Partial Work
- **Definition:** When a later step fails, earlier steps may need to be undone
- **Example:**
  ```typescript
  try {
    state.flight = await step.run('reserve-flight', () => airline.reserve());
    state.hotel = await step.run('reserve-hotel', () => hotel.reserve());
    state.car = await step.run('reserve-car', () => carRental.reserve());
  } catch (error) {
    // Compensate in reverse order
    if (state.car) await step.run('cancel-car', () => carRental.cancel());
    if (state.hotel) await step.run('cancel-hotel', () => hotel.cancel());
    if (state.flight) await step.run('cancel-flight', () => airline.cancel());
  }
  ```
- **Presenter Notes:** "This is the Saga pattern. It's how you build distributed transactions that survive failures."

#### Slide 2.10: Error Handling Strategies
- **Title:** Four Error Handling Patterns
- **Card Layout:**
  1. **Graceful Degradation:** Continue with reduced capability
  2. **Retry with Backoff:** Exponential delay between attempts
  3. **Dead Letter Queue:** Store failed messages for later processing
  4. **Fallback with Cached Response:** Use stale data when service is down
- **Presenter Notes:** "Each pattern has its place. Choose based on your business requirements."

---

### Section 2.4: Time-Based Orchestration (2 slides)

#### Slide 2.11: step.sleep() and step.sleepUntil()
- **Title:** Pause Your Workflow
- **Code:**
  ```typescript
  // Sleep for a duration
  await step.sleep('wait-5-seconds', 5000);
  await step.sleep('wait-1-minute', '1m');
  
  // Sleep until a specific time
  await step.sleepUntil('wait-for-new-year', new Date('2024-12-31T23:59:59'));
  
  // Calculated wait
  const waitTime = scheduledDate.getTime() - Date.now();
  await step.sleep('wait-for-schedule', waitTime);
  ```
- **Key Insight:** During sleep, workflow state is saved. If server restarts, resumes from sleep.
- **Presenter Notes:** "Sleep is durable. Not like setTimeout."

#### Slide 2.12: Scheduled Reminder System
- **Title:** Real-World Example — Reminder Workflow
- **Visual:** Flow diagram:
  1. Reminder scheduled with `scheduledFor` time
  2. Sleep until that time
  3. Send reminder email
  4. If recurrence, schedule next reminder
- **Code:** Show the complete reminder workflow
- **Presenter Notes:** "This workflow can run for days, weeks, or months. It will never lose its place."

---

## PART 3: High-Performance Workflow Patterns

### Section 3.1: Fan-Out / Fan-In (3 slides)

#### Slide 3.1: Module Introduction
- **Title:** Part 3 — High-Performance Workflow Patterns
- **Learning Objectives:**
  - Execute thousands of jobs safely
  - Optimize concurrency
  - Build resilient event pipelines
- **Presenter Notes:** "Now we scale. These patterns handle thousands of operations efficiently."

#### Slide 3.2: The Fan-Out/Fan-In Pattern
- **Title:** Parallel Processing Made Simple
- **Visual:** Diagram showing:
  - **Fan-Out:** Single workflow splits into many parallel operations
  - **Parallel Execution:** All operations run simultaneously
  - **Fan-In:** Results aggregated back into single workflow
- **Analogy:** Restaurant kitchen — head chef assigns dishes to different cooks, collects finished dishes
- **Presenter Notes:** "This is how you process thousands of items without keeping the user waiting."

#### Slide 3.3: Bulk Email Campaign
- **Title:** Real-World Example — Bulk Email Sender
- **Key Code:**
  ```typescript
  const BATCH_SIZE = 50;
  for (let i = 0; i < recipients.length; i += BATCH_SIZE) {
    const batch = recipients.slice(i, i + BATCH_SIZE);
    const batchResults = await step.run(`process-batch-${i}`, async () => {
      const emailPromises = batch.map(recipient => sendEmail(recipient));
      return await Promise.all(emailPromises);
    });
  }
  ```
- **Key Features:**
  - Process 50 recipients at a time
  - Each batch processes in parallel
  - Results aggregated for reporting
- **Presenter Notes:** "This pattern is essential for any bulk operation."

---

### Section 3.2: Concurrency Management (3 slides)

#### Slide 3.4: The Crowd Control Analogy
- **Title:** Concurrency Is Like Crowd Control
- **Visual:** Side-by-side:
  - **Global Limits:** "Only 100 people inside at a time"
  - **Per-User Limits:** "Each person can reserve 5 tickets"
  - **Per-Resource Limits:** "Only 10 people can use the VIP lounge"
- **Key Insight:** Concurrency limits protect downstream systems from overload
- **Presenter Notes:** "You're the bouncer. Decide who gets in and how many."

#### Slide 3.5: Configuring Concurrency
- **Title:** Concurrency in Code
- **Code:**
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
- **Key Insight:** Scopes can be at multiple levels
- **Presenter Notes:** "One line of code controls concurrency. No more building your own queue."

#### Slide 3.6: Multi-Tenant Task Scheduler
- **Title:** Real-World Example — Task Scheduler
- **Features:**
  - Tenant-specific concurrency limits
  - Priority-based processing
  - Global limits as safety net
- **Code:** Show configuration with tenant-specific limits
- **Presenter Notes:** "This is how you build fair, multi-tenant systems."

---

### Section 3.3: Rate Limiting and Throttling (2 slides)

#### Slide 3.7: Protecting External Services
- **Title:** Rate Limiting and Throttling
- **Visual:** Side-by-side:
  - **Rate Limiting:** "Only 100 requests per minute"
  - **Throttling:** "Wait 1 second between requests"
  - **Debouncing:** "Only let the last request through"
  - **Batching:** "Process 10 at a time, then wait"
- **Code:**
  ```typescript
  rateLimit: {
    limit: 100,
    period: '1m',
    key: 'data.userId',
  }
  ```
- **Presenter Notes:** "Protect your APIs. One line of code."

#### Slide 3.8: Image Processing Pipeline
- **Title:** Real-World Example — Image Processing
- **Features:**
  - Throttling between images
  - Priority-based processing
  - Rate limit tracking
- **Visual:** Flow diagram showing throttled processing
- **Presenter Notes:** "This pattern works for any external service with rate limits."

---

### Section 3.4: Debouncing and Batching (2 slides)

#### Slide 3.9: Grouping Events
- **Title:** Debouncing and Batching
- **Visual:** Side-by-side:
  - **Debouncing:** "Wait 5 seconds after the last request before processing"
  - **Batching:** "Collect all requests from last 5 minutes and process together"
- **Code:**
  ```typescript
  // Debounce
  debounce: {
    key: 'data.userId',
    period: '30s',
  }
  
  // Batch
  batch: {
    maxSize: 100,
    timeout: '60s',
    key: 'data.userId',
  }
  ```
- **Presenter Notes:** "These patterns are essential for event aggregation and API optimization."

#### Slide 3.10: Event Aggregator
- **Title:** Real-World Example — Event Aggregator
- **Features:**
  - Debounced user actions
  - Digest generation
  - Notification batching
- **Visual:** Flow showing individual actions → debounce → aggregated digest
- **Presenter Notes:** "This is how you build notification systems that don't spam users."

---

## PART 4: Long-Running Workflows & Human-in-the-Loop

### Section 4.1: Long-Running Workflow Architecture (3 slides)

#### Slide 4.1: Module Introduction
- **Title:** Part 4 — Long-Running Workflows & Human-in-the-Loop
- **Learning Objectives:**
  - Build workflows that pause and resume safely
  - Coordinate approvals and asynchronous callbacks
  - Implement business process orchestration
- **Presenter Notes:** "This is where workflows become business processes. Days, weeks, or months."

#### Slide 4.2: The Wedding Planning Analogy
- **Title:** Think of Long-Running Workflows Like Planning a Wedding
- **Visual:** Timeline showing:
  1. Book venue → Wait for confirmation (days)
  2. Hire caterer → Wait for contract (weeks)
  3. Send invitations → Wait for RSVPs (months)
  4. Coordinate vendors → Wait for confirmations (day of)
  5. Execute the wedding → All pieces come together
- **Key Insight:** Each step involves waiting. The workflow survives for months.
- **Presenter Notes:** "Your workflow is the wedding planner. It remembers everything."

#### Slide 4.3: The Three Waiting Mechanisms
- **Title:** How to Pause Your Workflow
- **Card Layout:**
  1. **step.sleep():** Pause for a duration
  2. **step.sleepUntil():** Pause until a specific time
  3. **step.waitForEvent():** Pause and wait for an external event
- **Key Insight:** All are durable — survive server restarts and deployments
- **Presenter Notes:** "These three primitives handle any waiting scenario."

---

### Section 4.2: The Saga Pattern (2 slides)

#### Slide 4.4: Distributed Transactions
- **Title:** The Saga Pattern — Coordinating Multiple Services
- **Definition:** A pattern for managing distributed transactions using local transactions with compensating actions
- **Visual:** Flow diagram:
  ```
  Reserve Flight → Reserve Hotel → Reserve Car → Confirm All
                    ↓              ↓              ↓
               Compensate Hotel  Compensate Car  Compensate Flight
  ```
- **Presenter Notes:** "This is how you build reliable systems across multiple services."

#### Slide 4.5: Customer Onboarding Saga
- **Title:** Real-World Example — Customer Onboarding
- **Steps:**
  1. Create CRM account
  2. Create billing account
  3. Send welcome email
  4. Provision resources
  5. Create user account
  6. Send onboarding survey
- **Compensation:** If any step fails, undo previous steps in reverse order
- **Code:** Show compensation queue implementation
- **Presenter Notes:** "This pattern is essential for any multi-step business process."

---

### Section 4.3: Human-in-the-Loop (3 slides)

#### Slide 4.6: Waiting for Humans
- **Title:** step.waitForEvent() — Wait for Human Decisions
- **Code:**
  ```typescript
  try {
    const decision = await step.waitForEvent('wait-for-approval', {
      event: 'purchase/approved',
      timeout: '24h',
      match: (data) => data.purchaseId === purchaseId,
    });
    if (decision.data.approved) {
      await executePurchase();
    }
  } catch {
    // Timeout - handle accordingly
    await handleTimeout();
  }
  ```
- **Key Insight:** Workflow pauses, waiting for human input
- **Presenter Notes:** "This is how you build approval systems, review processes, and any workflow that needs human judgment."

#### Slide 4.7: Purchase Approval System
- **Title:** Real-World Example — Purchase Approval
- **Features:**
  - Multi-level approvals
  - Timeout handling
  - Escalation for critical requests
  - Auto-approval for high urgency
- **Visual:** Flow diagram showing approval chain
- **Presenter Notes:** "This workflow can run for weeks. It survives deployments, restarts, everything."

#### Slide 4.8: Multi-Level Approval
- **Title:** Complex Approval Chains
- **Features:**
  - Sequential approval levels
  - Different timeouts per level
  - Escalation on timeout
  - Emergency auto-approval
- **Visual:** Flow showing Level 1 → Level 2 → Level 3 with timeouts
- **Presenter Notes:** "Real-world approval processes are complex. This handles them."

---

### Section 4.4: Versioning and Safe Deployments (2 slides)

#### Slide 4.9: The Airplane Analogy
- **Title:** Versioning Is Like Updating Airplane Software
- **Visual:** Side-by-side:
  - **Planes in flight** (running workflows): Continue with current version
  - **New flights** (new workflows): Use updated version
  - **Flight plan updates** (workflow changes): Applied to new executions only
- **Key Insight:** Running workflows are never interrupted
- **Presenter Notes:** "You can deploy anytime. Running workflows keep running."

#### Slide 4.10: Subscription Lifecycle Management
- **Title:** Real-World Example — Subscription Lifecycle
- **Features:**
  - Versioned workflow (v1.0.0, v2.0.0)
  - Different behavior per version
  - Safe deployment strategy
- **Code:** Show version configuration
  ```typescript
  {
    id: 'subscription-lifecycle-workflow',
    version: '2.0.0',
    retries: 3,
  }
  ```
- **Presenter Notes:** "This is how you evolve your workflows without breaking running processes."

---

## PART 5: Modern Full-Stack Integration

### Section 5.1: Next.js App Router Integration (3 slides)

#### Slide 5.1: Module Introduction
- **Title:** Part 5 — Full-Stack Integration with React 19 & Next.js 16
- **Learning Objectives:**
  - Trigger workflows from the UI
  - Provide instant feedback for asynchronous operations
  - Connect frontend state with backend execution
- **Presenter Notes:** "Now we bridge the gap. UI triggers workflows, users see real-time status."

#### Slide 5.2: The Full-Stack Architecture
- **Title:** How Everything Fits Together
- **Visual:** Stack diagram showing:
  - **Frontend:** React 19 Components (useActionState, useOptimistic, useSSE)
  - **API Layer:** Next.js Routes + Server Actions
  - **Orchestration Layer:** Inngest Durable Workflows
- **Presenter Notes:** "This is a complete, production-ready full-stack architecture."

#### Slide 5.3: Server Actions
- **Title:** Triggering Workflows from UI
- **Code:**
  ```typescript
  // Server Action
  'use server';
  export async function createOrder(formData: FormData) {
    const validated = schema.parse(formData);
    const result = await inngest.send({
      name: 'order/placed',
      data: validated,
    });
    return { success: true, runId: result.ids?.[0] };
  }
  
  // React Component
  const [state, formAction, isPending] = useActionState(createOrder, initialState);
  ```
- **Key Insight:** Server Actions are type-safe, server-side logic called from client components
- **Presenter Notes:** "This is the simplest way to trigger workflows from your UI."

---

### Section 5.2: React 19 Action APIs (3 slides)

#### Slide 5.4: useActionState
- **Title:** useActionState — Form State Made Easy
- **Code:**
  ```typescript
  const initialState = { success: false, error: null };
  const [state, formAction, isPending] = useActionState(
    createOrder,
    initialState
  );
  ```
- **Benefits:**
  - Automatic pending state
  - Type-safe state management
  - Works with Server Actions
- **Presenter Notes:** "This hook removes all the boilerplate from form handling."

#### Slide 5.5: useOptimistic — Immediate UI Feedback
- **Title:** Optimistic Updates
- **Definition:** Show changes immediately, while server processes in background
- **Code:**
  ```typescript
  const [optimisticContent, addOptimisticContent] = useOptimistic(
    content,
    (state, newContent) => newContent
  );
  ```
- **Key Insight:** Creates responsive, snappy user experiences
- **Presenter Notes:** "Users don't wait. The UI updates instantly, the workflow runs in the background."

#### Slide 5.6: AI Content Generation Dashboard
- **Title:** Real-World Example — AI Content Generator
- **Features:**
  - Immediate optimistic updates
  - Workflow status tracking
  - Real-time progress display
- **Visual:** Screenshot of AI content dashboard
- **Presenter Notes:** "This is a complete, production-ready AI workflow with a responsive UI."

---

### Section 5.3: Real-Time Updates (3 slides)

#### Slide 5.7: Server-Sent Events (SSE)
- **Title:** Streaming Status Updates
- **Definition:** Lightweight way to push real-time updates from server to client
- **Code (Server):**
  ```typescript
  const stream = new ReadableStream({
    start(controller) {
      const sendUpdate = async () => {
        const status = await getWorkflowStatus(runId);
        controller.enqueue(`data: ${JSON.stringify(status)}\n\n`);
        if (status.status === 'completed') controller.close();
        else setTimeout(sendUpdate, 2000);
      };
      sendUpdate();
    }
  });
  ```
- **Presenter Notes:** "SSE is perfect for workflows. Simple, reliable, real-time."

#### Slide 5.8: The useSSE Hook
- **Title:** Consuming SSE in React
- **Code:**
  ```typescript
  const { isConnected, lastMessage } = useSSE(
    `/api/workflows/status/stream?runId=${runId}`,
    {
      onMessage: (data) => setStatus(data),
      onError: () => console.error('Connection lost'),
    }
  );
  ```
- **Key Features:**
  - Auto-reconnect
  - Message parsing
  - Connection status
- **Presenter Notes:** "One hook handles all the complexity of real-time updates."

#### Slide 5.9: Workflow Status Component
- **Title:** Displaying Workflow Status
- **Features:**
  - Real-time status updates
  - Step-by-step progress
  - Visual indicators (running, completed, failed)
  - Cancellation support
- **Visual:** Screenshot of status component
- **Presenter Notes:** "Users see exactly what's happening, step by step."

---

## PART 6: Production Deployment & Observability

### Section 6.1: Production Configuration (3 slides)

#### Slide 6.1: Module Introduction
- **Title:** Part 6 — Production Deployment, Observability & Operations
- **Learning Objectives:**
  - Secure production deployments
  - Monitor workflow health
  - Debug distributed executions efficiently
- **Presenter Notes:** "This is the final step. Taking your workflows from development to production."

#### Slide 6.2: Environment Configuration
- **Title:** Production Environment Variables
- **.env.production:**
  ```bash
  INNGEST_EVENT_KEY="ev_prod_xxxxxxxxxxxxxxxx"
  INNGEST_SIGNING_KEY="sign_prod_xxxxxxxxxxxxxxxx"
  NEXT_PUBLIC_APP_URL="https://your-app.com"
  DATABASE_URL="postgresql://user:pass@host:5432/database"
  JWT_SECRET="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  ENCRYPTION_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  LOG_LEVEL="info"
  ```
- **Security:** Never commit these to version control
- **Presenter Notes:** "Secrets stay secret. Always use environment variables in production."

#### Slide 6.3: Production-Ready Client
- **Title:** The Production Inngest Client
- **Key Features:**
  - Sentry middleware for error tracking
  - Metrics middleware for performance
  - Production retry strategy
  - Production logging (info, warn, error only)
- **Code:** Show enhanced client with middleware
- **Presenter Notes:** "This is what you deploy. It monitors, tracks, and alerts."

---

### Section 6.2: Deployment Strategies (4 slides)

#### Slide 6.4: Vercel Deployment
- **Title:** Deploy to Vercel
- **Configuration:**
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
- **Command:** `vercel --prod`
- **Key Features:** Automatic scaling, zero configuration, CDN
- **Presenter Notes:** "Vercel is the fastest way to deploy. One command and you're live."

#### Slide 6.5: AWS Lambda Deployment
- **Title:** Deploy to AWS Lambda
- **Configuration:** `serverless.yml` with functions and environment variables
- **Command:** `serverless deploy`
- **Key Features:** Enterprise-grade, fine-grained control, VPC support
- **Presenter Notes:** "AWS gives you the most control. Configure once, deploy forever."

#### Slide 6.6: Docker Deployment
- **Title:** Deploy with Docker
- **Dockerfile:** Multi-stage build for optimization
- **Docker Compose:** Postgres, Redis, Nginx, App
- **Commands:**
  ```bash
  docker build -t workflowhub .
  docker-compose -f docker-compose.prod.yml up -d
  ```
- **Key Features:** Any environment, complete control, portable
- **Presenter Notes:** "Docker gives you the ultimate flexibility. Run anywhere."

#### Slide 6.7: CI/CD Pipeline
- **Title:** Automate Everything
- **GitHub Actions Workflow:**
  - Test → Build → Deploy to Staging → Smoke Tests → Deploy to Production
- **Visual:** Flow diagram showing CI/CD pipeline
- **Key Features:** Automated testing, staging environment, production deployment
- **Presenter Notes:** "Automate your deployments. Never deploy manually again."

---

### Section 6.3: Monitoring and Observability (4 slides)

#### Slide 6.8: The Mission Control Analogy
- **Title:** Observability Is Like Mission Control
- **Visual:** Side-by-side:
  - **Logs:** Raw telemetry data (everything that happened)
  - **Metrics:** Dashboard gauges (how fast, how many)
  - **Traces:** Flight path (exactly what happened when)
  - **Alerts:** Alarms (when something goes wrong)
- **Key Insight:** You need all four to understand your system
- **Presenter Notes:** "Think of yourself as mission control. You need complete visibility."

#### Slide 6.9: Structured Logging
- **Title:** Logging That Tells a Story
- **Code:**
  ```typescript
  logger.info('Processing order', {
    orderId: event.data.orderId,
    amount: event.data.amount,
    customerId: event.data.customerId,
    attempt: attempt,
    duration: Date.now() - startTime,
  });
  ```
- **Key Features:** Context, levels, structured data
- **Presenter Notes:** "Logs are useless without context. Always include relevant data."

#### Slide 6.10: Metrics Collection
- **Title:** Tracking Performance
- **Metrics to Collect:**
  - Workflow duration
  - Step duration
  - Success/failure rates
  - Error rates
  - Throughput
- **Code:** Show metrics middleware
- **Key Insight:** Metrics tell you how your system is performing over time
- **Presenter Notes:** "You can't optimize what you can't measure."

#### Slide 6.11: Health Checks
- **Title:** Monitoring System Health
- **Endpoint:** `GET /api/health`
- **Checks:**
  - Database connectivity
  - Inngest connectivity
  - Redis connectivity
  - Overall system status
- **Response:**
  ```json
  { "status": "healthy", "timestamp": "...", "services": { ... } }
  ```
- **Presenter Notes:** "Your health check is the first thing to fail when something goes wrong."

---

### Section 6.4: Production Checklist (1 slide)

#### Slide 6.12: The Production Checklist
- **Title:** Before You Go Live
- **Categories:**
  - **Security:** Secrets, signing keys, rate limiting, CORS, headers
  - **Reliability:** Retries, error handling, health checks, circuit breakers
  - **Observability:** Logging, metrics, alerts, dashboard
  - **Deployment:** CI/CD, rollback plan, database migrations, load testing
- **Presenter Notes:** "Go through this checklist before every production deployment."

---

## PART 7: AI Workflows & Enterprise Patterns

### Section 7.1: AI Workflow Basics (2 slides)

#### Slide 7.1: Module Introduction
- **Title:** AI Workflows & Enterprise Patterns
- **Learning Objectives:**
  - Build AI-powered workflows with durable execution
  - Implement multi-agent orchestration
  - Build Retrieval-Augmented Generation (RAG) workflows
  - Handle human review loops
- **Presenter Notes:** "AI is transforming how we build applications. Inngest handles the complexity."

#### Slide 7.2: The Challenge of AI Integration
- **Title:** Why AI Needs Durable Execution
- **Challenges:**
  1. **Unpredictable Latency:** LLM calls can take seconds to minutes
  2. **Rate Limits:** API providers have strict limits
  3. **Cost Sensitivity:** Each call costs money
  4. **Quality Variability:** Outputs can be inconsistent
  5. **Human Review:** Many outputs need human validation
- **Key Insight:** Inngest handles all of these automatically
- **Presenter Notes:** "AI is unreliable. Your workflow infrastructure can't be."

---

### Section 7.2: Multi-Agent Orchestration (2 slides)

#### Slide 7.3: The Agent Loop
- **Title:** Every Agent Is a Loop
- **Visual:** Flow diagram:
  ```
  Think → Act → Observe → Repeat → Done
  (LLM)   (Tool)  (Result)   (Loop)
  ```
- **Code:** Show the agent loop structure
  ```typescript
  while (!done && iterations < maxIterations) {
    const llmResponse = await step.run('think', async () => {
      return await callLLM(systemPrompt, messages, tools);
    });
    if (toolCalls.length > 0) {
      // Execute each tool
      for (const tc of toolCalls) {
        const toolResult = await step.run(`tool-${tc.name}`, async () => {
          return await executeTool(tc);
        });
        // Feed result back to LLM
        messages.push({ role: 'toolResult', content: toolResult });
      }
    } else {
      done = true;
    }
  }
  ```
- **Key Insight:** Each LLM call is a durable step, each tool execution is a durable step
- **Presenter Notes:** "This is the most reliable way to build AI agents. Every step is retryable, resumable."

#### Slide 7.4: Why Durable Steps Matter for AI
- **Title:** The Durability Advantage
- **Visual:** Side-by-side:
  - **Without Durability:** Agent fails on iteration 7, tool call 4. Everything is lost. Start over. Pay for 11 LLM calls again.
  - **With Durability:** Agent resumes from iteration 7, tool call 4. No work is duplicated. No state is lost.
- **Key Insight:** Durability saves money and time
- **Presenter Notes:** "This is the difference between a system that works and a system that fails."

---

### Section 7.3: RAG Workflows (2 slides)

#### Slide 7.5: Retrieval-Augmented Generation
- **Title:** RAG — Answer Questions from Documents
- **Visual:** Flow diagram:
  1. **Retrieve:** Search vector database for relevant documents
  2. **Augment:** Build prompt with retrieved context
  3. **Generate:** LLM answers based on context
- **Key Insight:** RAG combines retrieval with generation for accurate answers
- **Presenter Notes:** "RAG is how you build AI that knows your data."

#### Slide 7.6: RAG Implementation
- **Title:** RAG Workflow in Code
- **Steps:**
  1. **Retrieve documents:** `vectorDB.search(query, limit)`
  2. **Augment prompt:** Build context from documents
  3. **Generate response:** LLM answers with context
  4. **Evaluate quality:** Check accuracy and completeness
  5. **Store history:** Record conversation
- **Key Insight:** All steps are durable — if retrieval fails, retry only retrieval
- **Presenter Notes:** "This pattern works for any RAG implementation."

---

### Section 7.4: Human Review Loop (2 slides)

#### Slide 7.7: Validating AI Outputs
- **Title:** Human Review Loop
- **Visual:** Flow diagram:
  1. AI generates content
  2. Quality check (low score → human review)
  3. Assign reviewer
  4. Wait for review decision (timeout with escalation)
  5. Publish or reject
- **Key Insight:** Human review is a durable step with timeout handling
- **Presenter Notes:** "For sensitive AI outputs, always have a human in the loop."

#### Slide 7.8: Enterprise Patterns
- **Title:** Multi-Tenant AI Workflows
- **Features:**
  - Tenant-specific concurrency limits
  - Quota management
  - Fair resource allocation
- **Code:**
  ```typescript
  concurrency: {
    limit: 10,
    scope: 'key',
    key: 'data.tenantId',
  },
  rateLimit: {
    limit: 100,
    period: '1m',
    key: 'data.tenantId',
  }
  ```
- **Presenter Notes:** "These patterns are essential for any SaaS application."

---

## PART 8: Conclusion & Next Steps

### Section 8.1: What You've Learned (2 slides)

#### Slide 8.1: The Journey
- **Title:** You've Come a Long Way
- **Visual:** Timeline showing all 6 parts
- **Bullet Points:**
  - ✅ Event-driven architecture fundamentals
  - ✅ Durable execution and state management
  - ✅ High-performance patterns (fan-out, concurrency)
  - ✅ Long-running workflows and human-in-the-loop
  - ✅ Full-stack integration with React & Next.js
  - ✅ Production deployment and observability
  - ✅ AI workflows and enterprise patterns
- **Presenter Notes:** "Congratulations! You've mastered durable execution."

#### Slide 8.2: The WorkflowMindset
- **Title:** How You Think Has Changed
- **Before WorkflowMindset:**
  - "How do I process this in the background?"
  - "How do I handle failures?"
  - "How do I track progress?"
  - "How do I prevent duplicates?"
- **After WorkflowMindset:**
  - "What are the steps in this business process?"
  - "What happens if each step fails?"
  - "How do I roll back on failure?"
  - "What operations need to be idempotent?"
- **Key Insight:** This mindset is the single most valuable outcome
- **Presenter Notes:** "The code is important. The way you think about building systems is transformative."

---

### Section 8.2: Next Steps (2 slides)

#### Slide 8.3: Where to Go from Here
- **Title:** Continuing Your Journey
- **Next Steps:**
  1. **Build your own workflows:** Apply these patterns to your business needs
  2. **Explore advanced patterns:** AI workflows, event sourcing, CQRS
  3. **Join the Inngest community:** Share experiences, learn from others
  4. **Contribute to open source:** Help improve the ecosystem
  5. **Teach others:** Share what you've learned
- **Presenter Notes:** "You're ready. Go build something amazing."

#### Slide 8.4: Resources
- **Title:** Helpful Resources
- **Links:**
  - Inngest Documentation: https://www.inngest.com/docs
  - Inngest Discord Community: https://discord.gg/inngest
  - GitHub Repository: https://github.com/inngest/inngest
  - Inngest Blog: https://www.inngest.com/blog
  - The WorkflowHub Code: [link to your repo]
- **Presenter Notes:** "These resources will support you as you continue your journey."

---

## Appendices

### Appendix A: Demo Slides (3 slides)

#### Demo A.1: Hello World Function
- **Title:** Live Demo — Your First Function
- **What to Show:**
  1. Create client
  2. Create function with step.sleep()
  3. Start dev server
  4. Trigger via UI
  5. View run in dashboard
- **Time:** 5 minutes
- **Key Takeaway:** "You can build a durable function in under a minute."

#### Demo A.2: Long-Running Approval
- **Title:** Live Demo — Human-in-the-Loop
- **What to Show:**
  1. Create approval workflow with waitForEvent
  2. Trigger workflow
  3. Send approval event
  4. Watch workflow resume
- **Time:** 5 minutes
- **Key Takeaway:** "Workflows can pause for days and resume instantly."

#### Demo A.3: AI Content Generation
- **Title:** Live Demo — AI Workflow
- **What to Show:**
  1. Create AI workflow with step.ai.infer
  2. Trigger from UI
  3. Show real-time status updates
  4. View final output
- **Time:** 5 minutes
- **Key Takeaway:** "AI workflows with durability are production-ready."

---

### Appendix B: Q&A Preparation (1 slide)

#### Slide B.1: Common Questions
- **Title:** Anticipating Audience Questions
- **Questions:**
  - "How does Inngest compare to traditional queues?"
  - "Can I run Inngest on my existing infrastructure?"
  - "What happens to running workflows during deployments?"
  - "How do I handle errors in AI workflows?"
  - "What's the cost of using Inngest?"
  - "Can I use Inngest without a cloud platform?"
- **Preparation:** Have answers ready for each
- **Presenter Notes:** "The Q&A is where real learning happens."

---

## Slide Summary

| Part | Title | Slides |
|------|-------|--------|
| 0 | Introduction & Series Roadmap | 10 |
| 1 | Foundations — Events & Durable Execution | 10 |
| 2 | Durable Functions & State Management | 10 |
| 3 | High-Performance Workflow Patterns | 10 |
| 4 | Long-Running Workflows & Human-in-the-Loop | 10 |
| 5 | Full-Stack Integration with Next.js & React | 10 |
| 6 | Production Deployment & Observability | 12 |
| 7 | AI Workflows & Enterprise Patterns | 8 |
| 8 | Conclusion & Next Steps | 4 |
| A | Demos | 3 |
| B | Q&A | 1 |
| **Total** | | **88** |

---

*This slide outline provides a comprehensive framework for teaching the Mastering Inngest series. Each slide should include speaker notes, visual aids, and code examples as indicated. The presentation is designed for a 6-8 hour workshop or a multi-day course.*
