# Mastering Inngest: Trainer Guide
## Comprehensive Instructor's Manual for the Complete Series

---

## Table of Contents

**Introduction to the Trainer Guide** ... 3
- How to Use This Guide
- Series Overview
- Target Audience Analysis
- Prerequisite Knowledge

**Part 0: Preparing to Teach** ... 5
- Trainer Preparation Checklist
- Room and Materials Setup
- Technical Setup
- Session Structure

**Part 1: Foundations — Events & Durable Execution** ... 8
- Session Overview
- Detailed Session Plan
- Teaching Script & Key Talking Points
- Common Questions & Answers
- Exercise Facilitation Guide
- Troubleshooting Guide

**Part 2: State Management & Fault Tolerance** ... 15
- Session Overview
- Detailed Session Plan
- Teaching Script & Key Talking Points
- Common Questions & Answers
- Exercise Facilitation Guide
- Troubleshooting Guide

**Part 3: High-Performance Workflow Patterns** ... 21
- Session Overview
- Detailed Session Plan
- Teaching Script & Key Talking Points
- Common Questions & Answers
- Exercise Facilitation Guide
- Troubleshooting Guide

**Part 4: Long-Running Workflows & Human-in-the-Loop** ... 27
- Session Overview
- Detailed Session Plan
- Teaching Script & Key Talking Points
- Common Questions & Answers
- Exercise Facilitation Guide
- Troubleshooting Guide

**Part 5: Full-Stack Integration** ... 33
- Session Overview
- Detailed Session Plan
- Teaching Script & Key Talking Points
- Common Questions & Answers
- Exercise Facilitation Guide
- Troubleshooting Guide

**Part 6: Production & Observability** ... 39
- Session Overview
- Detailed Session Plan
- Teaching Script & Key Talking Points
- Common Questions & Answers
- Exercise Facilitation Guide
- Troubleshooting Guide

**Appendix A: Trainer Resources** ... 45
- Trainer Preparation Checklist
- Room Setup Checklist
- Materials Checklist
- Session Evaluation Forms
- Training Skills Checklist

**Appendix B: Managing Classroom Dynamics** ... 49
- Handling Difficult Participants
- Facilitating Group Work
- Managing Time
- Providing Effective Feedback

---

## Introduction to the Trainer Guide

### How to Use This Guide

This Trainer Guide is your essential tool for teaching the "Mastering Inngest" series . It provides detailed session plans, teaching scripts, facilitation guidance, and troubleshooting support for every part of the curriculum.

**Before You Begin:**
- Read through the entire guide before teaching
- Familiarize yourself with the Participant's Manual and Student Workbook
- Practice the code exercises in advance
- Set up your development environment

**During Training:**
- Follow the session plans as a roadmap, but adapt to your participants' needs
- Use the teaching scripts as guidance, not scripts to be read verbatim
- Refer to the Troubleshooting Guide when participants encounter issues
- Use the evaluation forms to gather feedback and improve future sessions 

**After Training:**
- Review the Session Evaluation forms
- Note any issues for future sessions
- Update your materials based on feedback

### Series Overview

**Total Sessions:** 6 (Plus Introduction)
**Target Duration per Session:** 3-4 hours (including hands-on exercises)
**Total Course Duration:** 18-24 hours (2-3 days)

| Session | Title | Key Focus |
|---------|-------|-----------|
| 0 | Introduction & Setup | Environment setup, core concepts |
| 1 | Foundations | Events, functions, steps, Dev Server |
| 2 | State Management | Checkpointing, idempotency, saga pattern |
| 3 | High-Performance Patterns | Fan-out, concurrency, rate limiting |
| 4 | Long-Running Workflows | waitForEvent, human-in-the-loop |
| 5 | Full-Stack Integration | Next.js, React 19, Server Actions |
| 6 | Production & Observability | Deployment, monitoring, security |

### Target Audience Analysis

**Primary Audience:** Full-stack JavaScript/TypeScript developers with experience in:
- JavaScript (ES2023+) or TypeScript
- React and Next.js App Router
- REST APIs
- Async programming (Promises, async/await)

**Experience Level:** Intermediate to Advanced

**Key Learning Styles to Address:**
- **Visual Learners:** Use diagrams and architecture visualizations
- **Auditory Learners:** Explain concepts with analogies (restaurant, wedding planning)
- **Kinesthetic Learners:** Hands-on coding exercises throughout 

**Common Learning Challenges:**
- Understanding durable execution vs. traditional queues
- Grasping why idempotency matters
- Distinguishing between throttle, concurrency, and rate limiting
- Managing state in long-running workflows

### Prerequisite Knowledge

Participants should be comfortable with:

**Required:**
- Creating a Next.js App Router project
- Writing React components (functional components, hooks)
- Using TypeScript (basic types, interfaces)
- Making API calls (fetch, async/await)
- Using npm/pnpm for package management
- Basic understanding of event-driven architecture

**Nice to Have (Not Required):**
- Experience with message queues (Redis, SQS)
- Understanding of microservices
- Experience with cloud platforms

**Technical Requirements for Participants:**
- Node.js 20+ installed
- VS Code (recommended) with extensions:
  - TypeScript/JavaScript
  - ESLint
  - Prettier
- Git
- An Inngest account (free tier) — for optional cloud features 

---

## Part 0: Preparing to Teach

### Trainer Preparation Checklist

Use this checklist before each session to ensure you're fully prepared .

**At Least One Week Before:**
- [ ] Review the entire Trainer Guide for the module
- [ ] Complete all exercises yourself
- [ ] Test all code examples in your environment
- [ ] Prepare any additional examples or analogies
- [ ] Review the Student Workbook exercises
- [ ] Prepare answers to anticipated questions

**One Day Before:**
- [ ] Verify the training room and technical setup
- [ ] Test the projector/LCD and audio equipment
- [ ] Check internet connectivity
- [ ] Prepare backup materials in case of technical issues
- [ ] Review the participant list (if available)

**Day of the Session:**
- [ ] Arrive 30-60 minutes before the session 
- [ ] Set up your laptop and projector
- [ ] Test the Inngest Dev Server 
- [ ] Place sign outside the room with session name and time 
- [ ] Write your name and the session title on the whiteboard 
- [ ] Have handouts and materials ready
- [ ] Set up an "Issues Board" for parking questions 

### Room and Materials Setup

**Recommended Room Layout:**
- U-shape or theater-style seating for presentations
- Small tables for group work (4-5 participants per table) 
- Clear sightlines to the projection screen
- Power outlets available for laptops

**Materials Checklist :**
- [ ] Projector/LCD screen (tested)
- [ ] Laptop with presentation and code examples
- [ ] Whiteboard or flip chart with markers
- [ ] Participant's Manual copies (one per participant)
- [ ] Student Workbook copies (one per participant)
- [ ] Name tags/tent cards
- [ ] Notepads and pens
- [ ] Water and refreshments

**Audiovisual Setup Checklist :**
- [ ] Projector connected and focused
- [ ] Audio system working
- [ ] Presentation slides loaded
- [ ] Code editor open with example projects
- [ ] Browser open to Dev Server and example applications

### Technical Setup

**Before the Session, Verify:**
1. **Node.js** is installed and working:
   ```bash
   node --version
   ```

2. **pnpm/npm** is installed:
   ```bash
   pnpm --version
   # or
   npm --version
   ```

3. **Inngest CLI** is installed:
   ```bash
   curl -sSfL https://cli.inngest.com/install.sh | sh
   ```

4. **Dev Server** can be started:
   ```bash
   inngest dev -u http://localhost:3000/api/inngest
   ```

5. **Example Project** runs without errors:
   ```bash
   cd examples/workflowhub
   pnpm install
   pnpm dev
   ```

**Backup Plans:**
- If the projector fails: Have printed copies of key diagrams
- If the internet fails: Have cached versions of documentation
- If code examples fail: Have pre-built solutions ready

### Session Structure

Each session follows a consistent structure to maximize learning .

**Typical 3-Hour Session:**

| Time | Activity | Duration |
|------|----------|----------|
| 0-15 min | Welcome, Housekeeping, Review | 15 min |
| 15-45 min | Module 1: Concepts & Lecture | 30 min |
| 45-60 min | Module 2: Live Demo | 15 min |
| 60-105 min | Module 3: Hands-On Exercise | 45 min |
| 105-120 min | Break | 15 min |
| 120-150 min | Module 4: Advanced Concepts | 30 min |
| 150-180 min | Module 5: Hands-On Exercise | 30 min |
| 180-185 min | Q&A and Wrap-up | 5 min |

**Session Opening Routine:**
1. **Greet participants** as they arrive
2. **Housekeeping** — restrooms, breaks, emergency procedures 
3. **Introductions** — Trainer introduction, participant introductions 
4. **Review previous session** — Quick recap of key concepts
5. **Preview today's session** — Learning objectives and agenda

**Session Closing Routine:**
1. **Summarize** key takeaways from the session
2. **Preview** the next session
3. **Q&A** — Answer remaining questions
4. **Final check** — Ensure all participants completed exercises
5. **Distribute** any required materials for next session

**BREAK STRUCTURE:**
- **Morning Session:** 15-minute break at approximately 10:00 AM
- **Afternoon Session:** 15-minute break at approximately 3:00 PM 

---

## Part 1: Foundations — Events & Durable Execution

### Session Overview

**Duration:** 3-4 hours
**Learning Objectives:**
- Understand event-driven architecture concepts
- Set up Inngest in a Next.js project
- Create a durable function with steps
- Use the Inngest Dev Server

**Key Concepts:**
- Events, Functions, Steps
- Durable execution vs. traditional queues
- The Inngest Dev Server

### Detailed Session Plan

#### Module 1.1: Introduction to Event-Driven Architecture (30 min)

**Opening (5 min)**
- Welcome participants
- Housekeeping announcements
- Brief introductions

**Lecture: The Restaurant Analogy (10 min)**
- **Key Point:** Traditional request/response is like a customer waiting at the counter while a single cook prepares everything.
- **Key Point:** Event-driven architecture is like a well-organized kitchen with multiple cooks working asynchronously .

**Lecture: Core Concepts (10 min)**
1. **Events:** "Something happened" messages
2. **Functions:** Workflows that respond to events
3. **Steps:** Individual units of work, automatically retried

**Discussion (5 min)**
- Ask participants: "What background jobs does your application have?"
- Write examples on the whiteboard
- Discuss which would benefit from durable execution

**Whiteboard Diagram:**
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
```

#### Module 1.2: Setting Up Inngest (30 min)

**Live Demo: Project Setup (15 min)**
1. Create Next.js project
2. Install Inngest
3. Create the Inngest client
4. Set up the API route

**Walk through the code line-by-line:**
```typescript
// src/inngest/client.ts
import { Inngest } from 'inngest';
export const inngest = new Inngest({
  id: 'workflowhub',
  name: 'WorkflowHub',
  eventKey: process.env.INNGEST_EVENT_KEY,
});
```

**Explain each part:**
- `id`: Unique identifier for your application
- `eventKey`: For signing events (security)
- `retryFunction`: How retries work

**Common Issues to Watch:**
- Participants may forget to disable body parser
- Environment variables may be missing
- Next.js version compatibility issues

#### Module 1.3: Your First Durable Function (45 min)

**Live Demo: Building a User Registration Workflow (15 min)**
1. Create the function
2. Add steps with `step.run()`
3. Register the function
4. Trigger the event
5. View the execution in the Dev Server

**Code Walkthrough:**
```typescript
export const userRegistrationWorkflow = inngest.createFunction(
  {
    id: 'user-registration-workflow',
    name: 'User Registration Workflow',
    retries: 3,
  },
  { event: 'user/registered' },
  async ({ event, step, logger }) => {
    // Step 1: Send welcome email
    const emailResult = await step.run('send-welcome-email', async () => {
      // ... email logic
    });

    // Step 2: Create profile
    const profile = await step.run('create-profile', async () => {
      // ... profile logic
    });

    // Step 3: Sync with CRM
    const crmResult = await step.run('sync-crm', async () => {
      // ... CRM logic
    });

    return { success: true };
  }
);
```

**Key Teaching Points:**
- Each `step.run()` is a checkpoint
- If a step fails, only that step retries
- Previous steps' results are memoized

**Hands-On Exercise (30 min)**
- **Instructions:** Participants create their own user registration workflow
- **Starter Code:** Provide the client and API route
- **Task:** Add the three steps with their own business logic
- **Verification:** Trigger the workflow and view it in the Dev Server

#### Module 1.4: The Inngest Dev Server (30 min)

**Live Demo: Exploring the Dev Server (15 min)**
1. Navigate to http://localhost:8288
2. View registered functions
3. Trigger an event from the UI
4. Inspect a run step-by-step
5. View step input and output

**Key Features to Show:**
- Real-time execution dashboard
- Step-by-step tracing 
- Input/output for each step
- Retry simulation

**Teaching Script:**
> "The Dev Server is your most powerful development tool. It shows you exactly what's happening in your workflows step by step. You can see the input to each step, the output, and how long each step took. This is where you'll spend most of your debugging time."

**Hands-On Exercise: Retry Simulation (15 min)**
1. Add a simulated failure to the welcome email step
2. Trigger the event
3. Watch the retry behavior in the Dev Server
4. Discuss what participants observed

**Common Questions & Answers**

**Q: "What's the difference between a queue and Inngest?"**
A: Queues store messages and workers process them. Inngest manages the entire workflow state. With a queue, if a worker crashes, you lose progress. With Inngest, the workflow state is saved at each step, so you can resume where you left off. 

**Q: "How do I trigger an event from the frontend?"**
A: You can use a Server Action to send an event. We'll cover this in detail in Part 5. For now, you can use the Dev Server UI or curl.

**Q: "What happens if the server restarts during a workflow?"**
A: The workflow state is saved to durable storage. When the server restarts, the workflow resumes from the last successful step. 

**Troubleshooting Guide**

**Issue: "Function not registered"**
- **Solution:** Verify the function is in the `serve()` functions array
- **Check:** API route has the correct import and registration

**Issue: "Events not triggering"**
- **Solution:** Verify event name matches exactly
- **Check:** Event name is spelled correctly (case-sensitive)
- **Check:** Function is properly registered

**Issue: "Dev Server not showing runs"**
- **Solution:** Verify the serve endpoint is publicly accessible
- **Check:** No authentication on the endpoint
- **Check:** `INNGEST_DEV=true` environment variable is set

---

## Part 2: State Management & Fault Tolerance

### Session Overview

**Duration:** 3-4 hours
**Learning Objectives:**
- Understand checkpointing and memoization
- Build idempotent steps
- Implement the Saga pattern
- Use time-based orchestration

### Detailed Session Plan

#### Module 2.1: Understanding Durable Execution (45 min)

**Lecture: The Autosave Analogy (15 min)**
> "Think of durable execution like autosave in a document. Without autosave, if your computer crashes, you lose everything. With autosave, you resume exactly where you left off."

**Whiteboard Diagram:**
```
Step 1 → [SAVE] → Step 2 → [SAVE] → Step 3 → [SAVE]
              ↓            ↓              ↓
          Checkpoint  Checkpoint      Checkpoint
```

**Key Teaching Points:**
- After each step completes, Inngest saves the workflow state
- If a failure occurs, the workflow resumes from the last checkpoint
- This is why the workflow can survive crashes and restarts

**Lecture: Idempotency (15 min)**
- **Definition:** An operation that produces the same result no matter how many times it's performed
- **Why it matters:** Prevents duplicate side effects (like charging a credit card twice)

**Code Example:**
```typescript
// Non-idempotent — could charge twice
await step.run('process-payment', async () => {
  return await chargeCard(orderId, amount);
});

// Idempotent — safe to retry
await step.run('process-payment', async () => {
  const key = `payment-${orderId}`;
  const existing = await db.payments.findUnique({ where: { idempotencyKey: key } });
  if (existing) return existing;
  const result = await chargeCard(orderId, amount);
  await db.payments.create({ data: { idempotencyKey: key, ...result } });
  return result;
});
```

**Group Discussion (15 min)**
- Ask participants to identify non-idempotent operations in their own applications
- Discuss how they would make those operations idempotent

#### Module 2.2: The Saga Pattern (60 min)

**Lecture: Distributed Transactions (15 min)**
> "The Saga pattern is how you manage distributed transactions across multiple services. When one step fails, you need to undo the work of previous steps."

**Whiteboard Diagram:**
```
┌─────────────────────────────────────────────────────────────┐
│                    Saga Pattern                            │
├─────────────────────────────────────────────────────────────┤
│  Step 1: Reserve Flight  ──────────────────────┐           │
│  │                                               │           │
│  ▼                                               │           │
│  Step 2: Reserve Hotel  ──────────────┐          │           │
│  │                                     │          │           │
│  ▼                                     │          │           │
│  Step 3: Reserve Car  ─────────┐       │          │           │
│  │                            │       │          │           │
│  ▼                            ▼       ▼          ▼           │
│  COMPENSATION:             Cancel   Cancel    Cancel        │
│  (Reverse Order)           Car      Hotel     Flight        │
└─────────────────────────────────────────────────────────────┘
```

**Live Demo: Implementing a Saga (20 min)**
1. Create a travel booking workflow
2. Add flight, hotel, and car reservation steps
3. Add compensation for each step
4. Simulate a failure and watch the compensation execute

**Key Teaching Points:**
- Compensation should be idempotent
- Compensation executes in reverse order (LIFO)
- Each compensation step is also durable

**Hands-On Exercise: Build Your Own Saga (25 min)**
- Participants build an order processing saga
- Steps: Validate → Reserve Inventory → Process Payment → Schedule Shipping
- Compensation for each step

#### Module 2.3: Time-Based Orchestration (45 min)

**Lecture: step.sleep() and step.sleepUntil() (15 min)**
- `step.sleep()`: Pause for a duration
- `step.sleepUntil()`: Pause until a specific time
- Both are durable — survive server restarts

**Code Examples:**
```typescript
// Sleep for 5 seconds
await step.sleep('wait-5s', 5000);

// Sleep for 1 minute
await step.sleep('wait-1m', '1m');

// Sleep until a specific date
await step.sleepUntil('wait-for-date', new Date('2024-12-31T23:59:59'));

// Calculated wait
const waitTime = scheduledDate.getTime() - Date.now();
await step.sleep('wait-for-schedule', waitTime);
```

**Live Demo: Reminder System (15 min)**
- Build a reminder workflow that sleeps until a scheduled time
- Wait for the reminder time
- Send the reminder email
- Schedule the next reminder (recurrence)

**Key Teaching Points:**
- Sleep state is saved
- If the server restarts during sleep, the workflow resumes from the sleep

**Hands-On Exercise: Build a Scheduled Reminder (15 min)**
- Participants build their own reminder workflow
- Sleep until a scheduled time
- Send a notification
- Support recurrence

**Common Questions & Answers**

**Q: "What happens if a sleep is interrupted by a deployment?"**
A: The sleep state is saved. When the new version deploys, the workflow resumes from the sleep. This is why sleep is durable.

**Q: "Is there a maximum sleep duration?"**
A: No, there is no hard limit. Workflows can sleep for days, weeks, or even months.

**Q: "What's the difference between a time-based workflow and a cron job?"**
A: Cron jobs run on a schedule. Time-based workflows run relative to an event. For example, "3 days after the user signed up" vs "every day at midnight."

---

## Part 3: High-Performance Workflow Patterns

### Session Overview

**Duration:** 3-4 hours
**Learning Objectives:**
- Implement Fan-Out / Fan-In for parallel processing
- Configure concurrency limits
- Use rate limiting and throttling
- Apply debouncing and batching

### Detailed Session Plan

#### Module 3.1: Fan-Out / Fan-In (45 min)

**Lecture: Parallel Processing (15 min)**
> "Fan-Out splits a single task into many parallel operations. Fan-In aggregates the results back together."

**Whiteboard Diagram:**
```
┌─────────────────────────────────────────────────────────┐
│                    Fan-Out / Fan-In                    │
├─────────────────────────────────────────────────────────┤
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
└─────────────────────────────────────────────────────────┘
```

**Live Demo: Bulk Email Campaign (15 min)**
1. Create a bulk email workflow
2. Process recipients in batches
3. Use `Promise.all()` for parallel execution
4. Aggregate results

**Key Code:**
```typescript
const BATCH_SIZE = 50;
for (let i = 0; i < recipients.length; i += BATCH_SIZE) {
  const batch = recipients.slice(i, i + BATCH_SIZE);
  const batchResults = await step.run(`process-batch-${i}`, async () => {
    const promises = batch.map(recipient => sendEmail(recipient));
    return await Promise.all(promises);
  });
  allResults.push(...batchResults);
}
```

**Hands-On Exercise: Bulk Processor (15 min)**
- Participants build their own bulk processing workflow
- Process 100 items in batches of 20
- Aggregate results

#### Module 3.2: Concurrency Management (45 min)

**Lecture: The Crowd Control Analogy (15 min)**
> "Concurrency is like crowd control at a venue. Global limits: 'Only 100 people inside at a time.' Per-user limits: 'Each person can reserve 5 tickets.' Per-resource limits: 'Only 10 people can use the VIP lounge.'"

**Configuration Options:**
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

**Live Demo: Multi-Tenant Task Scheduler (15 min)**
1. Create a task scheduler with tenant-specific concurrency
2. Demonstrate how each tenant gets their own limit
3. Show what happens when limits are reached

**Key Teaching Points:**
- Concurrency protects downstream systems
- Key-based concurrency enables fair resource allocation
- Global concurrency is a safety net

**Hands-On Exercise: Configure Concurrency (15 min)**
- Participants configure concurrency for a multi-tenant application
- Set up: Global limit, per-tenant limit
- Test with multiple tenants

#### Module 3.3: Rate Limiting & Throttling (45 min)

**Lecture: Protecting External Services (15 min)**
- **Rate Limit:** "100 requests per minute"
- **Throttle:** "Wait 1 second between requests"

**Code Examples:**
```typescript
// Rate limiting
rateLimit: {
  limit: 100,
  period: '1m',
  key: 'data.userId',
}

// Throttling
throttle: {
  limit: 10,
  period: '1s',
  key: 'data.tenantId',
}
```

**Live Demo: Image Processing with Throttling (15 min)**
1. Create an image processing workflow
2. Add throttling between images
3. Demonstrate rate limit behavior

**Hands-On Exercise: Add Rate Limiting (15 min)**
- Participants add rate limiting to an existing workflow
- Configure appropriate limits
- Test the behavior

#### Module 3.4: Debouncing & Batching (45 min)

**Lecture: Grouping Events (15 min)**
- **Debouncing:** Wait for a quiet period before processing
- **Batching:** Collect events and process together

**Code Examples:**
```typescript
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

**Live Demo: Event Aggregator (15 min)**
1. Build an event aggregator with debouncing
2. Collect user actions
3. Generate a digest

**Hands-On Exercise: Build an Aggregator (15 min)**
- Participants build their own event aggregator
- Use debouncing or batching
- Generate a summary

**Common Questions & Answers**

**Q: "What's the difference between concurrency and rate limiting?"**
A: Concurrency limits how many executions can run at the same time. Rate limiting limits how many executions can start in a time period. Think of concurrency as "how many are in the building" and rate limiting as "how many can enter per minute."

**Q: "When should I use throttling vs. rate limiting?"**
A: Use rate limiting when you need to stay under a total request cap (e.g., API provider says 100 requests per minute). Use throttling when you need to ensure a minimum delay between operations (e.g., avoid overwhelming a database with rapid writes).

**Q: "How do I choose the right concurrency limit?"**
A: Start with the capacity of your downstream system. If your database can handle 50 concurrent writes, set concurrency to 50. Monitor performance and adjust.

---

## Part 4: Long-Running Workflows & Human-in-the-Loop

### Session Overview

**Duration:** 3-4 hours
**Learning Objectives:**
- Build workflows that pause and resume over time
- Implement the Saga pattern
- Handle human-in-the-loop with `step.waitForEvent()`
- Use workflow versioning for safe deployments

### Detailed Session Plan

#### Module 4.1: Long-Running Workflow Architecture (45 min)

**Lecture: The Wedding Planning Analogy (15 min)**
> "Think of long-running workflows like planning a wedding. Book venue → Wait for confirmation (days). Hire caterer → Wait for contract (weeks). Send invitations → Wait for RSVPs (months)."

**Key Teaching Points:**
- Each step involves waiting
- The workflow might take months to complete
- It needs to survive server restarts and deployments

**Whiteboard Diagram:**
```
┌─────────────────────────────────────────────────────────┐
│              Long-Running Workflow                     │
├─────────────────────────────────────────────────────────┤
│  Event → Step 1 → [SLEEP] → Step 2 → [WAIT] → Step 3  │
│                ↑                    ↑                   │
│                │                    │                   │
│           Durable State      External Event            │
│           (Persisted)        (Human/System)            │
└─────────────────────────────────────────────────────────┘
```

**Lecture: The Three Waiting Mechanisms (15 min)**
1. `step.sleep()`: Pause for a duration
2. `step.sleepUntil()`: Pause until a specific time
3. `step.waitForEvent()`: Pause and wait for an external event

**Group Discussion (15 min)**
- Ask participants: "What business processes in your organization involve human approval?"
- Discuss how these could be implemented with `step.waitForEvent()`

#### Module 4.2: The Saga Pattern (45 min)

**Lecture: Distributed Transactions (15 min)**
- Review the Saga pattern from Part 2
- Focus on long-running transactions
- Discuss how compensation works over time

**Live Demo: Customer Onboarding Saga (15 min)**
1. Create a customer onboarding workflow
2. Add multiple steps with compensation
3. Demonstrate a failure and compensation

**Key Teaching Points:**
- Compensation should be durable
- Compensation may need to happen days later
- Idempotency is critical

**Hands-On Exercise: Build a Saga (15 min)**
- Participants build their own saga
- Include at least 3 steps with compensation
- Test failure scenarios

#### Module 4.3: Human-in-the-Loop (60 min)

**Lecture: Waiting for Humans (15 min)**
> "`step.waitForEvent()` is how you implement human-in-the-loop. The workflow pauses and waits for a human decision."

**Code Example:**
```typescript
try {
  const decision = await step.waitForEvent('wait-for-approval', {
    event: 'approval/decision',
    timeout: '24h',
    match: (data) => data.approvalId === approvalId,
  });

  if (decision.data.approved) {
    await step.run('execute', async () => {
      await executeAction();
    });
  }
} catch {
  // Timeout — escalate
  await step.run('escalate', async () => {
    await sendEmail(managerEmail, 'Approval timed out');
  });
}
```

**Live Demo: Purchase Approval System (20 min)**
1. Create an approval workflow
2. Notify approver
3. Wait for decision
4. Handle timeout with escalation

**Hands-On Exercise: Build an Approval Workflow (25 min)**
- Participants build their own approval workflow
- Include: notification, waiting, decision handling, timeout

#### Module 4.4: Workflow Versioning (45 min)

**Lecture: The Airplane Analogy (15 min)**
> "Workflow versioning is like updating software on a fleet of airplanes. Planes in flight continue with their current version. New flights use the updated version."

**Code Example:**
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

**Live Demo: Versioned Subscription Workflow (15 min)**
1. Create a subscription workflow with version 1
2. Add version 2 with enhanced features
3. Demonstrate both versions running

**Key Teaching Points:**
- Running workflows continue with their version
- New workflows use the latest version
- Safe deployment strategy

**Hands-On Exercise: Version Your Workflow (15 min)**
- Participants version their own workflow
- Add a new feature in version 2
- Deploy both versions

**Common Questions & Answers**

**Q: "What happens if I delete version 1 while workflows are still running?"**
A: Don't delete version 1 until all workflows using it have completed. Check the Inngest dashboard to see if any runs are still active.

**Q: "Can I have more than two versions?"**
A: Yes, you can have as many versions as needed. But only the latest version should be used for new executions.

**Q: "How long can a workflow wait for a human decision?"**
A: There is no hard limit. Workflows can wait for days, weeks, or even months. The state is saved durably.

---

## Part 5: Full-Stack Integration

### Session Overview

**Duration:** 3-4 hours
**Learning Objectives:**
- Integrate Inngest with Next.js App Router
- Use Server Actions to trigger workflows
- Implement real-time updates with Server-Sent Events
- Use React 19 features: `useActionState`, `useOptimistic`

### Detailed Session Plan

#### Module 5.1: Next.js Integration (45 min)

**Lecture: The Full-Stack Architecture (15 min)**
> "The UI triggers workflows through Server Actions. The workflows run on the server with durable execution. Real-time updates stream back to the UI."

**Whiteboard Diagram:**
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
```

**Live Demo: API Route Setup (15 min)**
1. Create the Inngest API route
2. Register functions
3. Configure the serve handler

**Hands-On Exercise: Configure API Route (15 min)**
- Participants set up their own API route
- Register at least two functions
- Verify the endpoint

#### Module 5.2: Server Actions (45 min)

**Lecture: Server Actions Explained (15 min)**
> "Server Actions are server-side functions that can be called from client components. They provide type-safe communication between UI and server."

**Code Example:**
```typescript
// Server Action
'use server';
export async function createOrder(formData: FormData) {
  const data = schema.parse(formData);
  const result = await inngest.send({
    name: 'order/placed',
    data,
  });
  return { success: true, runId: result.ids?.[0] };
}

// React Component
const [state, formAction, isPending] = useActionState(createOrder, initialState);
```

**Live Demo: Build a Trigger Form (15 min)**
1. Create a Server Action
2. Build a React form with `useActionState`
3. Trigger a workflow from the UI

**Key Teaching Points:**
- `useActionState` manages form state
- `isPending` indicates submission status
- `revalidatePath` refreshes the UI

**Hands-On Exercise: Build Your Own Form (15 min)**
- Participants build their own trigger form
- Use `useActionState`
- Trigger a workflow

#### Module 5.3: Real-Time Updates (45 min)

**Lecture: Server-Sent Events (15 min)**
> "Server-Sent Events provide a lightweight way to stream real-time updates from server to client."

**Code Example (Server):**
```typescript
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
```

**Code Example (Client):**
```typescript
const { isConnected, lastMessage } = useSSE(
  `/api/workflows/status/stream?runId=${runId}`,
  {
    onMessage: (data) => setStatus(data),
  }
);
```

**Live Demo: Real-Time Status Dashboard (15 min)**
1. Create the SSE endpoint
2. Build the `useSSE` hook
3. Create the `WorkflowStatus` component

**Hands-On Exercise: Build a Status Component (15 min)**
- Participants build their own status component
- Use SSE for real-time updates
- Display step progress

#### Module 5.4: AI Content Generation Dashboard (45 min)

**Lecture: useOptimistic (15 min)**
> "`useOptimistic` provides immediate UI feedback while the server processes the actual update."

**Code Example:**
```typescript
const [optimisticContent, addOptimisticContent] = useOptimistic(
  content,
  (state, newContent) => newContent
);
```

**Live Demo: Build the AI Dashboard (15 min)**
1. Create the AI content workflow
2. Build the React component with `useOptimistic`
3. Show immediate feedback

**Hands-On Exercise: Build an AI Dashboard (15 min)**
- Participants build their own AI dashboard
- Use `useOptimistic`
- Show real-time status

**Common Questions & Answers**

**Q: "What's the difference between Server Actions and API routes?"**
A: Server Actions are functions called directly from React components. API routes are HTTP endpoints. Server Actions handle form submissions, API routes handle REST requests.

**Q: "How do I handle authentication with Server Actions?"**
A: Server Actions run on the server and can use the same authentication mechanisms as API routes (sessions, cookies, JWT).

**Q: "What if the SSE connection is lost?"**
A: The `useSSE` hook should auto-reconnect. EventSource natively supports reconnection with a delay.

---

## Part 6: Production & Observability

### Session Overview

**Duration:** 3-4 hours
**Learning Objectives:**
- Configure production environment variables
- Implement health checks and monitoring
- Deploy to Vercel, AWS, or Docker
- Build a monitoring dashboard

### Detailed Session Plan

#### Module 6.1: Production Configuration (45 min)

**Lecture: Environment Setup (15 min)**
> "Never commit secrets to version control. Always use environment variables in production."

**Environment Variables:**
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

**Live Demo: Production-Ready Client (15 min)**
1. Add Sentry middleware
2. Add metrics middleware
3. Configure production retry strategy

**Hands-On Exercise: Configure Production Client (15 min)**
- Participants add middleware to their client
- Configure retry strategy
- Set up logging

#### Module 6.2: Deployment Strategies (60 min)

**Lecture: Vercel Deployment (15 min)**
> "Vercel is the fastest way to deploy. One command and you're live."

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

**Lecture: AWS Lambda Deployment (15 min)**
> "AWS gives you the most control. Configure once, deploy forever."

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

**Lecture: Docker Deployment (15 min)**
> "Docker gives you ultimate flexibility. Run anywhere."

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

**Group Discussion (15 min)**
- Ask participants: "Which deployment platform best fits your needs?"
- Discuss trade-offs between platforms

#### Module 6.3: Monitoring & Observability (45 min)

**Lecture: Structured Logging (15 min)**
> "Structured logs are machine-readable and include context. They tell a complete story."

```typescript
logger.info('Processing order', {
  orderId: event.data.orderId,
  amount: event.data.amount,
  customerId: event.data.customerId,
  duration: Date.now() - startTime,
});
```

**Lecture: Health Checks (15 min)**
> "A health check is your first line of defense. It monitors system health and verifies all services are working."

```typescript
export async function GET() {
  const dbHealthy = await checkDatabase();
  const inngestHealthy = await checkInngest();
  const status = dbHealthy && inngestHealthy ? 'healthy' : 'degraded';
  return NextResponse.json({ status, services: { database: dbHealthy, inngest: inngestHealthy } });
}
```

**Live Demo: Monitoring Dashboard (15 min)**
1. Build a monitoring dashboard
2. Display metrics and alerts
3. Show health status

**Hands-On Exercise: Implement Logging (15 min)**
- Participants implement structured logging
- Create a health check endpoint
- Build a simple dashboard

#### Module 6.4: Production Checklist (30 min)

**Review: Production Checklist (15 min)**
Go through the production checklist with participants:

**Security:**
- [ ] Secrets in environment variables
- [ ] Event signing keys configured
- [ ] Rate limiting enabled
- [ ] CORS properly configured

**Reliability:**
- [ ] Retry policies configured
- [ ] Error handling comprehensive
- [ ] Health checks implemented
- [ ] Circuit breakers in place

**Observability:**
- [ ] Structured logging
- [ ] Metrics collection
- [ ] Alerts configured
- [ ] Dashboard set up

**Deployment:**
- [ ] CI/CD pipeline configured
- [ ] Rollback plan exists
- [ ] Database migrations automated
- [ ] Load testing performed

**Open Discussion (15 min)**
- Ask participants: "What's the biggest gap in your production readiness?"
- Discuss how to address gaps

**Common Questions & Answers**

**Q: "How do I know if my rate limiting is working?"**
A: Monitor the rate limit metrics in the Inngest dashboard. You can see when limits are reached and which functions are being throttled.

**Q: "What should I monitor besides error rates?"**
A: Monitor workflow duration, step duration, success/failure rates, throughput, and resource usage. These metrics tell you how your system is performing.

**Q: "How do I test my production deployment?"**
A: Use a staging environment first. Run smoke tests against the staging URL. Deploy gradually with canary or blue-green deployment.

---

## Appendix A: Trainer Resources

### Trainer Preparation Checklist

Use this checklist before each session .

**One Week Before:**
- [ ] Review the entire Trainer Guide for the module
- [ ] Complete all exercises yourself
- [ ] Test all code examples in your environment
- [ ] Prepare any additional examples or analogies
- [ ] Review the Student Workbook exercises
- [ ] Prepare answers to anticipated questions

**One Day Before:**
- [ ] Verify the training room and technical setup
- [ ] Test the projector/LCD and audio equipment
- [ ] Check internet connectivity
- [ ] Prepare backup materials in case of technical issues
- [ ] Review the participant list (if available)

**Day of the Session:**
- [ ] Arrive 30-60 minutes before the session 
- [ ] Set up your laptop and projector
- [ ] Test the Inngest Dev Server
- [ ] Place sign outside the room with session name and time 
- [ ] Write your name and the session title on the whiteboard 
- [ ] Have handouts and materials ready
- [ ] Set up an "Issues Board" for parking questions 

### Room Setup Checklist 

- [ ] Is there a natural focus point or "front" for the trainer?
- [ ] Can all participants see the screen easily?
- [ ] Are there remote controls for the AV equipment?
- [ ] Is there a table for handouts and materials?
- [ ] Is there room for small-group discussions?
- [ ] Can tables and chairs be moved?
- [ ] Can all participants see the flip charts?
- [ ] Is there a thermostat that can be adjusted?
- [ ] Are there enough power outlets for laptops?

### Materials Checklist 

- [ ] Name tags/tent cards
- [ ] Participant's Manual copies
- [ ] Student Workbook copies
- [ ] Blank sign-in sheet
- [ ] Presentation slides (preloaded)
- [ ] Projector/LCD (tested)
- [ ] Laptop with code examples
- [ ] Whiteboard markers and erasers
- [ ] Flip chart markers
- [ ] Extra flip chart paper
- [ ] Prepared flip charts
- [ ] Notepads and pens
- [ ] Water and cups

### Session Evaluation Form

**Session Evaluation**

**Session Title:** _________________________
**Trainer Name:** _________________________
**Date:** _________________________

**Rate the following (1-5):**

1. The session met its learning objectives.
2. The content was clear and well-organized.
3. The trainer was knowledgeable and engaging.
4. The examples and exercises were helpful.
5. The pace was appropriate.

**What was most valuable about this session?**

____________________________________________________________

**What could be improved?**

____________________________________________________________

**What would you like to learn more about?**

____________________________________________________________

### Training Skills Checklist 

| Skill | Excellent | Good | Needs Improvement |
|-------|-----------|------|-------------------|
| Use of visual aids | ☐ | ☐ | ☐ |
| Clear explanations | ☐ | ☐ | ☐ |
| Answering questions | ☐ | ☐ | ☐ |
| Involving participants | ☐ | ☐ | ☐ |
| Using the Trainer's Guide | ☐ | ☐ | ☐ |
| Including all key points | ☐ | ☐ | ☐ |
| Keeping to time | ☐ | ☐ | ☐ |
| Movement and speech | ☐ | ☐ | ☐ |

---

## Appendix B: Managing Classroom Dynamics

### Handling Difficult Participants

**The Disruptive Participant**
- **Strategy:** Stand near the participant while speaking
- **Strategy:** Make eye contact to signal awareness
- **Strategy:** Gently redirect: "Let's hear what others think"

**The Overly Quiet Participant**
- **Strategy:** Ask open-ended questions
- **Strategy:** Use small group work where they can speak
- **Strategy:** Call on them directly (only if comfortable)

**The Know-It-All**
- **Strategy:** Validate their contribution, then move on
- **Strategy:** Acknowledge: "That's one approach. Let's explore others."
- **Strategy:** Redirect to group work

**The Questioner**
- **Strategy:** Answer if time allows
- **Strategy:** Use the Issues Board for lengthy questions
- **Strategy:** "That's a great question. I'll research and report back."

### Facilitating Group Work

**Breaking into Groups :**
1. **Random groups:** Count off (e.g., 1-4 for 4 groups)
2. **Affinity groups:** Group by interest or experience
3. **Pairs:** Quick discussions

**Giving Instructions :**
1. Break participants into groups first
2. Give the task instructions
3. Tell them the time available
4. Inform them about reporting back
5. Ask if they are clear
6. Let them know when time is almost up

**Reporting Back :**
- Groups pair up to report to each other
- Gallery walk: Post flip charts and read each other's work
- Different tasks for different groups
- All groups report on the same issue

### Managing Time 

**Timing Strategies:**
- Use a large watch on the table to track time
- Have co-trainer indicate time remaining
- If going over time, adjust the rest of the program

**When You Run Over:**
1. Note the delay
2. Decide what to shorten or drop
3. Communicate the change to participants
4. Continue with adjusted program

### Providing Effective Feedback 

**When Giving Individual Feedback:**
1. Identify what was understood correctly
2. Identify what wasn't understood
3. Ensure the participant understands the main points
4. Give praise for correct answers
5. For incorrect answers, discuss and help them think of a better answer
6. Don't give the answer too quickly

**During Teaching Practice:**
1. Ask: "What did the trainer do well?"
2. Ask: "What difficulties did you observe?"
3. Ask: "What could the trainer do differently?"

**For Written Exercises:**
- Follow the suggested answers in the Trainer's Guide
- Accept other appropriate answers
- Give praise for appropriate answers
- Discuss and guide for inappropriate answers

---

*End of Trainer Guide*
