# Mastering Inngest: Student Workbook

## Building Reliable Serverless Workflows with Durable Execution

---

# Welcome & Instructions

## How to Use This Workbook

This workbook is designed to accompany the "Mastering Inngest" video series or instructor-led training. It contains:

1. **Learning Objectives** — What you should know after each module
2. **Key Takeaways** — The most important concepts from each module
3. **Hands-on Exercises** — Practical coding challenges to reinforce learning
4. **Exercise Solutions** — Complete code solutions for each exercise
5. **Self-Assessment** — Check your understanding with quizzes
6. **Reflection Questions** — Apply concepts to your own work
7. **Code Templates** — Starter code for exercises

---

## How to Use This Workbook

### For Video-Based Learning
- Watch the module video first
- Review the learning objectives
- Complete the exercise before the instructor's solution
- Check your work against the solution
- Answer reflection questions

### For Instructor-Led Training
- Follow along with the live demonstration
- Complete exercises during lab time
- Use the workbook as your reference guide
- Ask questions about any unclear concepts

### For Self-Study
- Read the module summary
- Complete exercises from scratch
- Compare with solutions
- Use additional resources for deeper understanding

---

# Table of Contents

**Part 0: Introduction & Foundations** ... 5
- Module 0.1: Course Overview
- Module 0.2: Development Environment Setup
- Module 0.3: The WorkflowMindset

**Part 1: Events & Durable Execution** ... 7
- Module 1.1: Event-Driven Architecture
- Module 1.2: Your First Durable Function
- Module 1.3: The Inngest Dev Server

**Part 2: State Management & Fault Tolerance** ... 11
- Module 2.1: Understanding Durable Execution
- Module 2.2: Managing Workflow State
- Module 2.3: Error Handling & Retries
- Module 2.4: Time-Based Orchestration

**Part 3: High-Performance Patterns** ... 16
- Module 3.1: Fan-Out / Fan-In
- Module 3.2: Concurrency Management
- Module 3.3: Rate Limiting & Throttling
- Module 3.4: Debouncing & Batching

**Part 4: Long-Running Workflows** ... 21
- Module 4.1: Long-Running Workflow Architecture
- Module 4.2: The Saga Pattern
- Module 4.3: Human-in-the-Loop
- Module 4.4: Workflow Versioning

**Part 5: Full-Stack Integration** ... 26
- Module 5.1: Next.js & React Integration
- Module 5.2: Server Actions
- Module 5.3: Real-Time Updates with SSE
- Module 5.4: AI Content Generation Dashboard

**Part 6: Production & Observability** ... 32
- Module 6.1: Production Configuration
- Module 6.2: Deployment Strategies
- Module 6.3: Monitoring & Observability
- Module 6.4: Production Checklist

**Appendix A: AI Workflows** ... 37
- Module A.1: AI Content Generation
- Module A.2: Multi-Agent Orchestration
- Module A.3: RAG Workflows

**Appendix B: Reference** ... 41
- Quick Reference Cards
- Common Commands
- Troubleshooting Guide
- Glossary

---

# Part 0: Introduction & Foundations

## Module 0.1: Course Overview

### Learning Objectives
- Understand what this course will teach you
- Identify the problems that durable execution solves
- Recognize the architecture you'll build

### Key Takeaways
```
- Traditional background processing is brittle and complex
- Durable execution provides automatic resilience
- By the end, you'll build 6 production-ready workflows
```

### Exercise 0.1: Your Current Approach
**Instructions:** Think about a background job or workflow in your current or past project. Write down:

1. What was the job? (e.g., "Sending welcome emails after signup")

2. How did you handle failures? (e.g., "Manual retry with cron job")

3. What was the hardest part about maintaining it? (e.g., "Tracking which emails were sent")

4. What would make this job easier? (e.g., "Automatic retry with idempotency")

**Reflection:**
```
1. _________________________________________________________________

2. _________________________________________________________________

3. _________________________________________________________________

4. _________________________________________________________________
```

---

## Module 0.2: Development Environment Setup

### Learning Objectives
- Set up Node.js, pnpm/npm, and a code editor
- Create a Next.js project with Inngest
- Verify the development environment works

### Key Takeaways
```
- Node.js 20+ is required
- Use pnpm for better dependency management
- The Inngest Dev Server runs alongside your application
```

### Exercise 0.2: Environment Setup

**Instructions:** Follow these steps to set up your development environment.

**Step 1: Check Node.js Version**
```bash
node --version
# Should output v20.x or higher
```

**Step 2: Install pnpm (Optional)**
```bash
npm install -g pnpm
```

**Step 3: Create Next.js Project**
```bash
pnpm create next-app@latest workflowhub --typescript --tailwind --app --no-src-dir
cd workflowhub
```

**Step 4: Install Inngest**
```bash
pnpm add inngest inngest/next zod uuid
pnpm add -D @types/uuid
```

**Step 5: Verify Installation**
```bash
pnpm dev
# Should start on http://localhost:3000
```

**Step 6: Install Inngest CLI**
```bash
curl -sSfL https://cli.inngest.com/install.sh | sh
inngest --version
```

**Step 7: Start Dev Server**
```bash
inngest dev -u http://localhost:3000/api/inngest
```

**Verification:**
- [ ] `node --version` shows v20+
- [ ] `pnpm dev` starts without errors
- [ ] `inngest --version` shows version
- [ ] Dev Server opens at http://localhost:8288

**Troubleshooting:**
```
If pnpm dev fails: Run npm install instead
If Inngest CLI not found: Check your PATH
If port 3000 in use: Change port with `pnpm dev --port 3001`
```

---

## Module 0.3: The WorkflowMindset

### Learning Objectives
- Understand the mental shift from request/response to event-driven
- Identify business processes that benefit from durable execution
- Recognize the questions to ask when designing workflows

### Key Takeaways
```
- Before: "How do I process this in the background?"
- After: "What are the steps in this business process?"
- Think in terms of steps, failures, and idempotency
```

### Exercise 0.3: Identifying Workflow Opportunities

**Instructions:** For each scenario below, identify whether it's a good fit for durable execution and explain why.

**Scenario 1: Send a password reset email after user requests it**
```
Durable execution needed? ☐ Yes ☐ No

Why? _________________________________________________________________
```

**Scenario 2: Process a multi-step order with payment, inventory, and shipping**
```
Durable execution needed? ☐ Yes ☐ No

Why? _________________________________________________________________
```

**Scenario 3: Display a user's profile information on their dashboard**
```
Durable execution needed? ☐ Yes ☐ No

Why? _________________________________________________________________
```

**Scenario 4: Generate a monthly report from hundreds of data sources**
```
Durable execution needed? ☐ Yes ☐ No

Why? _________________________________________________________________
```

**Reflection:**
- What do scenarios 2 and 4 have in common? 
  ____________________________________________________________
- What makes a good fit for durable execution? 
  ____________________________________________________________

---

# Part 1: Events & Durable Execution

## Module 1.1: Event-Driven Architecture

### Learning Objectives
- Explain event-driven architecture using the restaurant analogy
- Understand the difference between request/response and event-driven
- Define events, functions, and steps

### Key Takeaways
```
- Events: "Something happened" messages
- Functions: Workflows that respond to events
- Steps: Individual units of work, automatically retried
- Event-driven systems are loosely coupled and asynchronous
```

### Exercise 1.1: Event Design Practice

**Instructions:** For each business event below, design the event data structure and the steps that would follow.

**Event: Customer Signs Up**
```
Event Name: user/registered

Event Data:
{
  // Design the shape of data this event carries
}

Workflow Steps:
1. ___________________________________________________________
2. ___________________________________________________________
3. ___________________________________________________________
4. ___________________________________________________________
```

**Event: Order Is Placed**
```
Event Name: order/placed

Event Data:
{
  // Design the shape of data this event carries
}

Workflow Steps:
1. ___________________________________________________________
2. ___________________________________________________________
3. ___________________________________________________________
4. ___________________________________________________________
```

**Event: Payment Is Received**
```
Event Name: payment/received

Event Data:
{
  // Design the shape of data this event carries
}

Workflow Steps:
1. ___________________________________________________________
2. ___________________________________________________________
3. ___________________________________________________________
4. ___________________________________________________________
```

---

## Module 1.2: Your First Durable Function

### Learning Objectives
- Create an Inngest client
- Write a durable function with `step.run()`
- Understand the three parts of a function
- Trigger events from the UI or terminal

### Key Takeaways
```
- Functions have: Configuration, Trigger, Handler
- Each step.run() is automatically retried on failure
- The Dev Server provides complete visibility
```

### Exercise 1.2: Build Your First Function

**Instructions:** Follow the code below to build a user registration workflow. Write the code in your project.

**Step 1: Create the Inngest Client**

```typescript
// src/inngest/client.ts
import { Inngest } from 'inngest';

export const inngest = new Inngest({
  id: 'workflowhub',
  name: 'WorkflowHub',
  eventKey: process.env.INNGEST_EVENT_KEY,
});
```

**Step 2: Create the API Route**

```typescript
// src/app/api/inngest/route.ts
import { serve } from 'inngest/next';
import { inngest } from '@/inngest/client';
import { userRegistrationWorkflow } from '@/inngest/functions/user-registration';

export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [
    userRegistrationWorkflow,
  ],
});

export const config = {
  api: {
    bodyParser: false,
  },
};
```

**Step 3: Create the Workflow**

```typescript
// src/inngest/functions/user-registration.ts
import { inngest } from '@/inngest/client';

export const userRegistrationWorkflow = inngest.createFunction(
  {
    id: 'user-registration-workflow',
    name: 'User Registration Workflow',
    retries: 3,
  },
  { event: 'user/registered' },
  async ({ event, step, logger }) => {
    const { userId, email, name } = event.data;

    logger.info('Processing user registration', { userId, email });

    // Step 1: Send welcome email
    const emailResult = await step.run('send-welcome-email', async () => {
      await new Promise((resolve) => setTimeout(resolve, 1000));
      return { messageId: `msg-${Date.now()}`, sentAt: new Date().toISOString() };
    });

    // Step 2: Create profile
    const profile = await step.run('create-profile', async () => {
      await new Promise((resolve) => setTimeout(resolve, 500));
      return { id: userId, email, name, createdAt: new Date().toISOString() };
    });

    // Step 3: Sync with CRM
    const crmResult = await step.run('sync-crm', async () => {
      await new Promise((resolve) => setTimeout(resolve, 700));
      return { crmId: `crm-${userId.slice(0, 8)}`, status: 'synced' };
    });

    return {
      userId,
      email,
      processed: true,
      emailSent: emailResult.messageId,
      profileCreated: profile.id,
      crmSynced: crmResult.crmId,
    };
  }
);
```

**Step 4: Trigger the Event**

```bash
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "user/registered",
    "data": {
      "userId": "user_123",
      "email": "test@example.com",
      "name": "Test User"
    }
  }'
```

**Verification:**
- [ ] Dev Server shows the function registered
- [ ] Curl command returns `{"ids":["run_..."],"status":"success"}`
- [ ] Run appears in the Dev Server UI
- [ ] All three steps completed successfully

---

## Module 1.3: The Inngest Dev Server

### Learning Objectives
- Navigate the Inngest Dev Server UI
- Inspect function executions step by step
- Trigger events from the Dev Server
- Understand step memoization

### Key Takeaways
```
- The Dev Server shows every step with input/output
- Memoization means step results are cached on retry
- You can replay events for testing
```

### Exercise 1.3: Inspect Your First Run

**Instructions:** Follow the steps below to explore the Inngest Dev Server.

**Step 1: Open the Dev Server**

Navigate to http://localhost:8288 in your browser.

**Step 2: Find Your Run**

1. Click "Runs" in the sidebar
2. Find your recent user registration run
3. Click on it to see details

**Step 3: Explore the Run Details**

Answer these questions:

1. What is the Run ID? _________________________________

2. How long did the entire workflow take? _________________________________

3. How many steps were executed? _________________________________

4. What was the output of the `send-welcome-email` step? _________________________________

5. What was the final return value? _________________________________

**Step 4: Test Retry Behavior**

1. Create a new file to simulate failure:

```typescript
// src/inngest/helpers/simulate-failure.ts
export const simulateFailure = (failRate: number = 0.5) => {
  if (Math.random() < failRate) {
    throw new Error('Simulated failure for testing');
  }
  return { success: true };
};
```

2. Add it to your workflow:

```typescript
import { simulateFailure } from '@/inngest/helpers/simulate-failure';

// Inside the email step
const emailResult = await step.run('send-welcome-email', async () => {
  simulateFailure(0.7); // 70% chance of failure
  // ... rest of step
});
```

3. Trigger the event again and watch the retry behavior in the Dev Server.

**Reflection:**
- What did you observe when a step failed?
  ____________________________________________________________
- How many retries occurred before success?
  ____________________________________________________________
- Did the successful step's result get memoized?
  ____________________________________________________________

---

# Part 2: State Management & Fault Tolerance

## Module 2.1: Understanding Durable Execution

### Learning Objectives
- Explain how checkpointing works
- Understand idempotency and why it matters
- Build workflows that survive crashes and restarts

### Key Takeaways
```
- Each step is checkpointed after completion
- On failure, workflow resumes from last checkpoint
- Idempotent steps prevent duplicate side effects
```

### Exercise 2.1: Idempotency Practice

**Instructions:** For each operation below, determine if it's idempotent and explain why.

**Operation: Charge a credit card**
```
Idempotent? ☐ Yes ☐ No

Why? _________________________________________________________________

How would you make it idempotent? _____________________________________
_____________________________________________________________________
```

**Operation: Send a welcome email**
```
Idempotent? ☐ Yes ☐ No

Why? _________________________________________________________________

How would you make it idempotent? _____________________________________
_____________________________________________________________________
```

**Operation: Update a user's profile with new data**
```
Idempotent? ☐ Yes ☐ No

Why? _________________________________________________________________

How would you make it idempotent? _____________________________________
_____________________________________________________________________
```

**Operation: Add an item to a cart**
```
Idempotent? ☐ Yes ☐ No

Why? _________________________________________________________________

How would you make it idempotent? _____________________________________
_____________________________________________________________________
```

**Exercise 2.2: Build an Idempotent Step**

```typescript
// src/inngest/functions/idempotent-payment.ts
import { inngest } from '@/inngest/client';

export const idempotentPaymentWorkflow = inngest.createFunction(
  { id: 'idempotent-payment-workflow' },
  { event: 'payment/requested' },
  async ({ event, step, logger }) => {
    const { orderId, amount } = event.data;

    // FILL IN THE BLANK: Make this step idempotent
    const payment = await step.run('process-payment', async () => {
      // 1. Check if this payment was already processed
      // HINT: Use orderId as a key
      
      // 2. If it was processed, return the existing result
      
      // 3. If not, process the payment
      
      // 4. Store the result with the idempotency key
    });

    return { success: true, payment };
  }
);
```

**Solution:**
```typescript
const payment = await step.run('process-payment', async () => {
  // 1. Check if this payment was already processed
  const idempotencyKey = `payment-${orderId}`;
  const existing = await getPayment(idempotencyKey);
  
  // 2. If it was processed, return the existing result
  if (existing) {
    logger.info('Payment already processed, returning cached result', { orderId });
    return existing;
  }
  
  // 3. If not, process the payment
  const result = await chargeCard(orderId, amount);
  
  // 4. Store the result with the idempotency key
  await storePayment(idempotencyKey, result);
  
  return result;
});
```

---

## Module 2.2: Managing Workflow State

### Learning Objectives
- Pass data between workflow steps
- Store and access results from previous steps
- Practice state minimalism
- Handle complex state objects

### Key Takeaways
```
- Return data from step.run() to pass to subsequent steps
- Only store what you need (state minimalism)
- Use external storage for large data
```

### Exercise 2.3: Building a Multi-Step Stateful Workflow

**Instructions:** Build a workflow that processes an order with the following steps:

1. **Validate order** — Check if the order is valid
2. **Process payment** — Charge the customer
3. **Update inventory** — Deduct stock
4. **Schedule shipping** — Create shipping label
5. **Send confirmation** — Email the customer

**Requirements:**
- Each step should pass data to the next
- Step 2 should use data from Step 1
- Step 3 should use data from Step 2
- Final return should include all relevant data

```typescript
// src/inngest/functions/order-processing.ts
import { inngest } from '@/inngest/client';

export const orderProcessingWorkflow = inngest.createFunction(
  {
    id: 'order-processing-workflow',
    name: 'Order Processing Workflow',
  },
  { event: 'order/placed' },
  async ({ event, step, logger }) => {
    // YOUR CODE HERE
    
    // Step 1: Validate the order
    
    // Step 2: Process payment using validation result
    
    // Step 3: Update inventory using payment result
    
    // Step 4: Schedule shipping using inventory result
    
    // Step 5: Send confirmation
    
    // Return final result
  }
);
```

**Self-Check:**
- [ ] Step 1 returns validation data
- [ ] Step 2 uses Step 1's data
- [ ] Step 3 uses Step 2's data
- [ ] All data flows correctly
- [ ] Final return includes complete information

---

## Module 2.3: Error Handling & Retries

### Learning Objectives
- Configure retry policies
- Implement custom error handling
- Build compensating actions (Saga pattern)
- Handle timeouts gracefully

### Key Takeaways
```
- Retries are automatic with exponential backoff
- Compensating actions undo partial work on failure
- Error handling strategies: Degrade, Retry, DLQ, Fallback
```

### Exercise 2.4: Implementing Compensation

**Instructions:** Complete the saga pattern implementation below.

```typescript
// src/inngest/functions/booking-saga.ts
import { inngest } from '@/inngest/client';

export const bookingSagaWorkflow = inngest.createFunction(
  { id: 'booking-saga-workflow' },
  { event: 'booking/requested' },
  async ({ event, step, logger }) => {
    const { bookingId, flightId, hotelId, carId } = event.data;
    
    const reservations = {};
    
    try {
      // Step 1: Reserve flight
      reservations.flight = await step.run('reserve-flight', async () => {
        // Simulate flight reservation
        return { id: flightId, status: 'reserved' };
      });
      
      // Step 2: Reserve hotel
      // YOUR CODE: Reserve hotel
      
      // Step 3: Reserve car (may fail 30% of the time)
      reservations.car = await step.run('reserve-car', async () => {
        // Simulate random failure
        if (Math.random() < 0.3) {
          throw new Error('Car rental service unavailable');
        }
        return { id: carId, status: 'reserved' };
      });
      
      // Step 4: Confirm booking
      // YOUR CODE: Confirm all reservations
      
      return { success: true, reservations };
      
    } catch (error) {
      // COMPENSATION: Cancel all successful reservations
      // YOUR CODE: Cancel flight if reserved
      
      // YOUR CODE: Cancel hotel if reserved
      
      // YOUR CODE: Cancel car if reserved
      
      throw new Error(`Booking failed: ${error.message}`);
    }
  }
);
```

**Solution:**
```typescript
// Step 2: Reserve hotel
reservations.hotel = await step.run('reserve-hotel', async () => {
  return { id: hotelId, status: 'reserved' };
});

// Step 4: Confirm booking
await step.run('confirm-booking', async () => {
  return { id: bookingId, status: 'confirmed' };
});

// Compensation
if (reservations.car) {
  await step.run('cancel-car', async () => {
    return { id: reservations.car.id, status: 'canceled' };
  });
}
if (reservations.hotel) {
  await step.run('cancel-hotel', async () => {
    return { id: reservations.hotel.id, status: 'canceled' };
  });
}
if (reservations.flight) {
  await step.run('cancel-flight', async () => {
    return { id: reservations.flight.id, status: 'canceled' };
  });
}
```

---

## Module 2.4: Time-Based Orchestration

### Learning Objectives
- Use step.sleep() and step.sleepUntil()
- Build scheduled reminder systems
- Implement timeouts and delays

### Key Takeaways
```
- Sleep is durable — survives server restarts
- Use step.sleep() for durations
- Use step.sleepUntil() for absolute times
- Sleep saves state and resumes exactly where it left off
```

### Exercise 2.5: Build a Reminder System

**Instructions:** Build a reminder workflow that:
1. Accepts a reminder time
2. Sleeps until that time
3. Sends a reminder email
4. If recurrence is enabled, schedules the next reminder

```typescript
// src/inngest/functions/reminder-system.ts
import { inngest } from '@/inngest/client';

export const reminderWorkflow = inngest.createFunction(
  {
    id: 'reminder-workflow',
    name: 'Reminder System',
  },
  { event: 'reminder/created' },
  async ({ event, step, logger }) => {
    const { reminderId, email, message, scheduledFor, recurrence } = event.data;
    
    // Step 1: Calculate wait time
    // YOUR CODE: Calculate wait time from scheduledFor
    
    // Step 2: Sleep until the reminder time
    // YOUR CODE: Use step.sleep() to wait
    
    // Step 3: Send the reminder
    // YOUR CODE: Send the email
    
    // Step 4: Handle recurrence
    // YOUR CODE: If recurrence is not 'once', schedule next
    // HINT: Use step.sendEvent() to trigger another reminder
    
    // Step 5: Return result
    return {
      reminderId,
      sent: true,
      sentAt: new Date().toISOString(),
      nextReminder: null, // Update this
    };
  }
);
```

**Solution:**
```typescript
// Step 1: Calculate wait time
const scheduledTime = new Date(scheduledFor).getTime();
const currentTime = Date.now();
const waitTime = scheduledTime - currentTime;

// Step 2: Sleep until the reminder time
if (waitTime > 0) {
  await step.sleep('wait-for-reminder', waitTime);
}

// Step 3: Send the reminder
await step.run('send-reminder', async () => {
  await sendEmail(email, message);
  return { sent: true, sentAt: new Date().toISOString() };
});

// Step 4: Handle recurrence
if (recurrence !== 'once') {
  const nextDate = new Date(scheduledTime);
  nextDate.setDate(nextDate.getDate() + 1); // Daily recurrence
  
  await step.sendEvent('schedule-next-reminder', {
    name: 'reminder/created',
    data: {
      reminderId: `${reminderId}-${Date.now()}`,
      email,
      message,
      scheduledFor: nextDate.toISOString(),
      recurrence,
    },
  });
  
  nextReminder = nextDate.toISOString();
}
```

---

# Part 3: High-Performance Workflow Patterns

## Module 3.1: Fan-Out / Fan-In

### Learning Objectives
- Implement fan-out/fan-in for parallel processing
- Process large datasets efficiently
- Aggregate results from parallel operations

### Key Takeaways
```
- Fan-out: Split work across parallel operations
- Fan-in: Aggregate results back together
- Use Promise.all() for parallel execution
- Batch operations to control resource usage
```

### Exercise 3.1: Bulk Email Campaign

**Instructions:** Complete the bulk email campaign workflow that sends emails to multiple recipients in parallel batches.

```typescript
// src/inngest/functions/bulk-email-campaign.ts
import { inngest } from '@/inngest/client';

export const bulkEmailCampaignWorkflow = inngest.createFunction(
  {
    id: 'bulk-email-campaign-workflow',
    name: 'Bulk Email Campaign',
  },
  { event: 'campaign/triggered' },
  async ({ event, step, logger }) => {
    const { campaignId, recipients, message } = event.data;
    
    const BATCH_SIZE = 50;
    const allResults = [];
    
    // Step 1: Loop through recipients in batches
    for (let i = 0; i < recipients.length; i += BATCH_SIZE) {
      const batch = recipients.slice(i, i + BATCH_SIZE);
      
      // Step 2: Process each batch
      const batchResults = await step.run(`process-batch-${i}`, async () => {
        // YOUR CODE: Process all emails in this batch in parallel
        // Use Promise.all() to send multiple emails simultaneously
        
        // YOUR CODE: Return results for this batch
      });
      
      allResults.push(...batchResults);
    }
    
    // Step 3: Aggregate all results
    // YOUR CODE: Calculate total, sent, failed counts
    
    // Step 4: Return summary
    return {
      campaignId,
      stats: {
        total: 0, // Update this
        sent: 0,  // Update this
        failed: 0, // Update this
      },
      completedAt: new Date().toISOString(),
    };
  }
);
```

**Solution:**
```typescript
// Step 2: Process each batch
const batchResults = await step.run(`process-batch-${i}`, async () => {
  const emailPromises = batch.map(async (recipient) => {
    try {
      const result = await sendEmail({
        to: recipient.email,
        subject: message.subject,
        body: message.body,
      });
      return { recipient: recipient.email, success: true, messageId: result.messageId };
    } catch (error) {
      return { recipient: recipient.email, success: false, error: error.message };
    }
  });
  
  return await Promise.all(emailPromises);
});

// Step 3: Aggregate results
const stats = {
  total: allResults.length,
  sent: allResults.filter(r => r.success).length,
  failed: allResults.filter(r => !r.success).length,
};
```

---

## Module 3.2: Concurrency Management

### Learning Objectives
- Configure concurrency limits at multiple levels
- Implement tenant-specific concurrency
- Protect downstream systems with concurrency controls

### Key Takeaways
```
- Function-level: Limit runs of a specific function
- Key-based: Limit runs per tenant/user
- Global: Limit runs across all functions
- Concurrency protects your system from overload
```

### Exercise 3.2: Multi-Tenant Task Scheduler

**Instructions:** Build a task scheduler with tenant-specific concurrency limits.

```typescript
// src/inngest/functions/task-scheduler.ts
import { inngest } from '@/inngest/client';

export const taskSchedulerWorkflow = inngest.createFunction(
  {
    id: 'task-scheduler-workflow',
    name: 'Task Scheduler',
    // YOUR CODE: Add concurrency limits
    // 1. Global limit: 100 concurrent runs total
    // 2. Per-tenant limit: 5 concurrent runs per tenant
  },
  { event: 'task/scheduled' },
  async ({ event, step, logger }) => {
    const { taskId, tenantId, type, payload } = event.data;
    
    // Step 1: Validate tenant
    // YOUR CODE: Check if tenant is valid
    
    // Step 2: Process the task
    const result = await step.run('process-task', async () => {
      // YOUR CODE: Process the task
      // Simulate processing time
      await new Promise((resolve) => setTimeout(resolve, 1000 + Math.random() * 2000));
      return { taskId, tenantId, status: 'completed' };
    });
    
    // Step 3: Store result
    // YOUR CODE: Store the task result
    
    return {
      taskId,
      tenantId,
      status: 'completed',
      result,
      completedAt: new Date().toISOString(),
    };
  }
);
```

**Solution:**
```typescript
export const taskSchedulerWorkflow = inngest.createFunction(
  {
    id: 'task-scheduler-workflow',
    name: 'Task Scheduler',
    concurrency: {
      limit: 100,
      scope: 'fn', // Global limit
    },
    // Note: Per-tenant limits use key-based concurrency
    // Configured on the client or per-tenant basis
  },
  { event: 'task/scheduled' },
  // ... rest of workflow
);

// For per-tenant limits, use key-based concurrency:
{
  concurrency: {
    limit: 5,
    scope: 'key',
    key: 'data.tenantId',
  }
}
```

---

## Module 3.3: Rate Limiting & Throttling

### Learning Objectives
- Configure rate limits to protect external services
- Implement throttling between operations
- Handle rate limit errors gracefully

### Key Takeaways
```
- Rate limit: "100 requests per minute"
- Throttle: "Wait 1 second between requests"
- Rate limiting protects downstream services
```

### Exercise 3.3: Image Processing with Throttling

**Instructions:** Build an image processing workflow that respects rate limits.

```typescript
// src/inngest/functions/image-processing.ts
import { inngest } from '@/inngest/client';

export const imageProcessingWorkflow = inngest.createFunction(
  {
    id: 'image-processing-workflow',
    name: 'Image Processing Workflow',
    // YOUR CODE: Add rate limiting
    // - Max 10 batches per minute
  },
  { event: 'images/process' },
  async ({ event, step, logger }) => {
    const { batchId, images } = event.data;
    const processedImages = [];
    
    // Step 1: Process images one by one with throttling
    for (let i = 0; i < images.length; i++) {
      const image = images[i];
      
      // YOUR CODE: Add throttling between images
      // - Wait 1 second between each image
      
      // Process the image
      const result = await step.run(`process-image-${i}`, async () => {
        // Simulate processing
        await new Promise((resolve) => setTimeout(resolve, 500 + Math.random() * 1000));
        return { imageId: image.id, status: 'processed' };
      });
      
      processedImages.push(result);
    }
    
    return {
      batchId,
      processed: processedImages.length,
      results: processedImages,
      completedAt: new Date().toISOString(),
    };
  }
);
```

**Solution:**
```typescript
export const imageProcessingWorkflow = inngest.createFunction(
  {
    id: 'image-processing-workflow',
    name: 'Image Processing Workflow',
    rateLimit: {
      limit: 10,
      period: '1m',
    },
  },
  { event: 'images/process' },
  async ({ event, step, logger }) => {
    // ... rest of code
    
    // Throttling between images
    if (i > 0) {
      await step.sleep('throttle-wait', 1000);
    }
    
    // ... process image
  }
);
```

---

## Module 3.4: Debouncing & Batching

### Learning Objectives
- Implement debouncing for rapid events
- Configure batching for efficient processing
- Understand when to use each pattern

### Key Takeaways
```
- Debounce: Wait for a quiet period before processing
- Batch: Collect events and process together
- Both improve efficiency and reduce load
```

### Exercise 3.4: Event Aggregator

**Instructions:** Complete the event aggregator with debouncing.

```typescript
// src/inngest/functions/event-aggregator.ts
import { inngest } from '@/inngest/client';

export const eventAggregatorWorkflow = inngest.createFunction(
  {
    id: 'event-aggregator-workflow',
    name: 'Event Aggregator',
    // YOUR CODE: Add debouncing
    // - Group by user ID
    // - Wait 30 seconds after the last event
  },
  { event: 'user/action' },
  async ({ event, step, logger }) => {
    const { userId, action } = event.data;
    
    // Step 1: Store the action
    await step.run('store-action', async () => {
      // Simulate storing action
      await new Promise((resolve) => setTimeout(resolve, 100));
      return { stored: true };
    });
    
    // Step 2: Get all recent actions for this user
    const recentActions = await step.run('get-recent-actions', async () => {
      // YOUR CODE: Fetch recent actions from database
      // Simulate fetching
      await new Promise((resolve) => setTimeout(resolve, 200));
      return {
        actions: [
          { action: 'view', timestamp: new Date().toISOString() },
          { action: 'click', timestamp: new Date().toISOString() },
          { action: 'view', timestamp: new Date().toISOString() },
        ],
        count: 3,
      };
    });
    
    // Step 3: Generate digest (if more than 3 actions)
    if (recentActions.count > 3) {
      // YOUR CODE: Generate and send digest
    }
    
    return {
      userId,
      processed: true,
      actionCount: recentActions.count,
      processedAt: new Date().toISOString(),
    };
  }
);
```

**Solution:**
```typescript
export const eventAggregatorWorkflow = inngest.createFunction(
  {
    id: 'event-aggregator-workflow',
    name: 'Event Aggregator',
    debounce: {
      key: 'data.userId',
      period: '30s',
    },
  },
  { event: 'user/action' },
  // ... rest of workflow
);

// Digest generation
if (recentActions.count > 3) {
  await step.run('send-digest', async () => {
    await sendEmail(userId, `You had ${recentActions.count} actions`);
    return { sent: true };
  });
}
```

---

# Part 4: Long-Running Workflows & Human-in-the-Loop

## Module 4.1: Long-Running Workflow Architecture

### Learning Objectives
- Design workflows that span minutes, days, or weeks
- Use step.waitForEvent() for pausing execution
- Handle timeouts and escalations

### Key Takeaways
```
- step.waitForEvent() pauses the workflow
- The workflow state is saved during the wait
- Timeouts prevent indefinite waiting
- Escalation handles missed deadlines
```

### Exercise 4.1: Approval Request Workflow

**Instructions:** Build an approval workflow that waits for a manager's decision.

```typescript
// src/inngest/functions/approval-workflow.ts
import { inngest } from '@/inngest/client';

export const approvalWorkflow = inngest.createFunction(
  {
    id: 'approval-workflow',
    name: 'Approval Workflow',
  },
  { event: 'approval/requested' },
  async ({ event, step, logger }) => {
    const { approvalId, requester, amount, approver } = event.data;
    
    // Step 1: Notify approver
    await step.run('notify-approver', async () => {
      // YOUR CODE: Send notification to approver
    });
    
    // Step 2: Wait for approval decision
    let approved = false;
    let timeout = false;
    
    try {
      const decision = await step.waitForEvent('wait-for-approval', {
        event: 'approval/decision',
        // YOUR CODE: Set timeout based on urgency
        // - Critical: 1 hour
        // - Normal: 24 hours
        match: (data) => data.approvalId === approvalId,
      });
      
      approved = decision.data.approved;
      
    } catch {
      timeout = true;
    }
    
    // Step 3: Handle decision or timeout
    if (timeout) {
      // YOUR CODE: Handle timeout
      // - Escalate to manager
      // - Auto-deny
    }
    
    if (approved) {
      // YOUR CODE: Execute approved action
    } else {
      // YOUR CODE: Handle denial
    }
    
    return {
      approvalId,
      status: approved ? 'approved' : 'denied',
      // YOUR CODE: Add additional fields
    };
  }
);
```

**Solution:**
```typescript
// Step 1: Notify approver
await step.run('notify-approver', async () => {
  await sendEmail(approver.email, `Approval needed: $${amount}`);
});

// Step 2: Wait with appropriate timeout
const timeoutDuration = event.data.urgency === 'critical' ? '1h' : '24h';

const decision = await step.waitForEvent('wait-for-approval', {
  event: 'approval/decision',
  timeout: timeoutDuration,
  match: (data) => data.approvalId === approvalId,
});

// Step 3: Handle timeout
if (timeout) {
  // Escalate
  await step.run('escalate-approval', async () => {
    await sendEmail('manager@example.com', `Approval timed out: $${amount}`);
  });
  return { approvalId, status: 'escalated' };
}
```

---

## Module 4.2: The Saga Pattern

### Learning Objectives
- Implement the Saga pattern for distributed transactions
- Build compensating actions for each step
- Handle partial failures gracefully

### Key Takeaways
```
- Saga: Distributed transaction with compensation
- Each step has a compensating action
- Compensation occurs in reverse order
- Prevents partial updates
```

### Exercise 4.2: Travel Booking Saga

**Instructions:** Complete the travel booking saga with compensation.

```typescript
// src/inngest/functions/travel-booking-saga.ts
import { inngest } from '@/inngest/client';

export const travelBookingSaga = inngest.createFunction(
  {
    id: 'travel-booking-saga',
    name: 'Travel Booking Saga',
  },
  { event: 'travel/booking-requested' },
  async ({ event, step, logger }) => {
    const { bookingId, flightId, hotelId, carId } = event.data;
    const reservations = {};
    
    try {
      // Step 1: Book flight
      // YOUR CODE: Reserve flight
      
      // Step 2: Book hotel
      // YOUR CODE: Reserve hotel
      
      // Step 3: Book car
      // YOUR CODE: Reserve car (may fail)
      
      // Step 4: Confirm all
      // YOUR CODE: Confirm booking
      
      return { success: true, reservations };
      
    } catch (error) {
      // COMPENSATION
      // YOUR CODE: Cancel in reverse order
      // - Car (if reserved)
      // - Hotel (if reserved)
      // - Flight (if reserved)
      
      throw new Error(`Booking failed: ${error.message}`);
    }
  }
);
```

**Solution:**
```typescript
// Step 1: Book flight
reservations.flight = await step.run('book-flight', async () => {
  return { id: flightId, status: 'reserved' };
});

// Step 2: Book hotel
reservations.hotel = await step.run('book-hotel', async () => {
  return { id: hotelId, status: 'reserved' };
});

// Step 3: Book car
reservations.car = await step.run('book-car', async () => {
  if (Math.random() < 0.2) throw new Error('Car not available');
  return { id: carId, status: 'reserved' };
});

// Step 4: Confirm booking
await step.run('confirm-booking', async () => {
  return { id: bookingId, status: 'confirmed' };
});

// Compensation
// Cancel in reverse order
if (reservations.car) {
  await step.run('cancel-car', async () => {
    return { id: reservations.car.id, status: 'canceled' };
  });
}
if (reservations.hotel) {
  await step.run('cancel-hotel', async () => {
    return { id: reservations.hotel.id, status: 'canceled' };
  });
}
if (reservations.flight) {
  await step.run('cancel-flight', async () => {
    return { id: reservations.flight.id, status: 'canceled' };
  });
}
```

---

## Module 4.3: Human-in-the-Loop

### Learning Objectives
- Build workflows that wait for human decisions
- Implement escalation chains
- Handle timeouts with auto-decision

### Key Takeaways
```
- Human-in-the-loop = workflow pauses for human input
- Escalation chain ensures timely response
- Auto-decision prevents indefinite waiting
- All state is preserved during human wait
```

### Exercise 4.3: Document Review Workflow

**Instructions:** Build a document review workflow with escalation.

```typescript
// src/inngest/functions/document-review.ts
import { inngest } from '@/inngest/client';

export const documentReviewWorkflow = inngest.createFunction(
  {
    id: 'document-review-workflow',
    name: 'Document Review Workflow',
  },
  { event: 'document/review-requested' },
  async ({ event, step, logger }) => {
    const { documentId, content, reviewerEmail, urgency } = event.data;
    
    // Step 1: Assign to reviewer
    await step.run('assign-reviewer', async () => {
      // YOUR CODE: Assign document to reviewer
    });
    
    // Step 2: Wait for review
    let reviewed = false;
    let approved = false;
    let attempt = 1;
    
    while (!reviewed && attempt <= 3) {
      try {
        const timeout = attempt === 1 ? '1h' : attempt === 2 ? '4h' : '12h';
        
        const decision = await step.waitForEvent(`wait-for-review-${attempt}`, {
          event: 'document/reviewed',
          timeout,
          match: (data) => data.documentId === documentId,
        });
        
        reviewed = true;
        approved = decision.data.approved;
        
      } catch {
        // YOUR CODE: Escalate on timeout
        // - Attempt 1: Remind reviewer
        // - Attempt 2: Notify manager
        // - Attempt 3: Auto-approve or escalate
      }
    }
    
    return {
      documentId,
      reviewed,
      approved,
      // YOUR CODE: Add additional fields
    };
  }
);
```

**Solution:**
```typescript
// Step 1: Assign reviewer
await step.run('assign-reviewer', async () => {
  await sendEmail(reviewerEmail, 'New document for review');
});

// Step 2: Wait with escalation
while (!reviewed && attempt <= 3) {
  try {
    const timeout = attempt === 1 ? '1h' : attempt === 2 ? '4h' : '12h';
    
    const decision = await step.waitForEvent(`wait-for-review-${attempt}`, {
      event: 'document/reviewed',
      timeout,
      match: (data) => data.documentId === documentId,
    });
    
    reviewed = true;
    approved = decision.data.approved;
    
  } catch {
    // Escalate
    if (attempt === 1) {
      await step.run('remind-reviewer', async () => {
        await sendEmail(reviewerEmail, 'Reminder: Document needs review');
      });
    } else if (attempt === 2) {
      await step.run('notify-manager', async () => {
        await sendEmail('manager@example.com', 'Review overdue');
      });
    } else {
      // Auto-approve on final timeout
      approved = true;
      reviewed = true;
      await step.run('auto-approve', async () => {
        await sendEmail(reviewerEmail, 'Document auto-approved due to timeout');
      });
    }
    attempt++;
  }
}
```

---

## Module 4.4: Workflow Versioning

### Learning Objectives
- Version workflows for safe deployments
- Understand how versioning affects running workflows
- Implement versioned functions

### Key Takeaways
```
- Each workflow can have a version
- Running workflows continue with their version
- New workflows use the latest version
- Versioning enables safe deployments
```

### Exercise 4.4: Versioned Subscription Workflow

**Instructions:** Build a versioned subscription workflow.

```typescript
// src/inngest/functions/subscription-lifecycle.ts
import { inngest } from '@/inngest/client';

// VERSION 1.0.0
export const subscriptionLifecycleV1 = inngest.createFunction(
  {
    id: 'subscription-lifecycle-workflow',
    name: 'Subscription Lifecycle v1.0.0',
    version: '1.0.0',
  },
  { event: 'subscription/created' },
  async ({ event, step, logger }) => {
    // Simple version: just create subscription
    return {
      version: '1.0.0',
      subscriptionId: event.data.subscriptionId,
      status: 'created',
    };
  }
);

// VERSION 2.0.0
export const subscriptionLifecycleV2 = inngest.createFunction(
  {
    id: 'subscription-lifecycle-workflow',
    name: 'Subscription Lifecycle v2.0.0',
    // YOUR CODE: Set version to 2.0.0
  },
  { event: 'subscription/created' },
  async ({ event, step, logger }) => {
    // YOUR CODE: Enhanced version with trial period
    // 1. Create subscription
    // 2. Set trial period
    // 3. Wait for trial to end
    // 4. Convert to paid
    
    return {
      version: '2.0.0',
      subscriptionId: event.data.subscriptionId,
      status: 'trial',
      trialEndsAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
    };
  }
);
```

**Solution:**
```typescript
// VERSION 2.0.0
export const subscriptionLifecycleV2 = inngest.createFunction(
  {
    id: 'subscription-lifecycle-workflow',
    name: 'Subscription Lifecycle v2.0.0',
    version: '2.0.0',
  },
  { event: 'subscription/created' },
  async ({ event, step, logger }) => {
    // 1. Create subscription
    const subscription = await step.run('create-subscription', async () => {
      return { id: event.data.subscriptionId, status: 'trial' };
    });
    
    // 2. Wait for trial period
    const trialEnd = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    await step.sleepUntil('wait-for-trial', trialEnd);
    
    // 3. Convert to paid
    await step.run('convert-to-paid', async () => {
      return { id: subscription.id, status: 'active' };
    });
    
    return {
      version: '2.0.0',
      subscriptionId: event.data.subscriptionId,
      status: 'active',
    };
  }
);
```

---

# Part 5: Full-Stack Integration

## Module 5.1: Next.js & React Integration

### Learning Objectives
- Set up Inngest with Next.js App Router
- Create API routes for workflows
- Understand the full-stack flow

### Key Takeaways
```
- App Router provides built-in API routes
- Server Actions bridge UI to workflows
- React components display workflow status
```

### Exercise 5.1: Complete the API Integration

**Instructions:** Set up the Inngest API route with your functions.

```typescript
// src/app/api/inngest/route.ts
import { serve } from 'inngest/next';
import { inngest } from '@/inngest/client';
// YOUR CODE: Import your workflows
// - userRegistrationWorkflow
// - orderProcessingWorkflow
// - approvalWorkflow

export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [
    // YOUR CODE: Add your workflows to the array
  ],
});

export const config = {
  api: {
    bodyParser: false,
  },
};
```

**Solution:**
```typescript
import { serve } from 'inngest/next';
import { inngest } from '@/inngest/client';
import { userRegistrationWorkflow } from '@/inngest/functions/user-registration';
import { orderProcessingWorkflow } from '@/inngest/functions/order-processing';
import { approvalWorkflow } from '@/inngest/functions/approval-workflow';

export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [
    userRegistrationWorkflow,
    orderProcessingWorkflow,
    approvalWorkflow,
  ],
});

export const config = {
  api: {
    bodyParser: false,
  },
};
```

---

## Module 5.2: Server Actions

### Learning Objectives
- Create Server Actions for triggering workflows
- Use useActionState for form management
- Handle form submission with loading states

### Key Takeaways
```
- Server Actions run server-side logic from the UI
- useActionState manages form state
- Type-safe communication between client and server
```

### Exercise 5.2: Build a Workflow Trigger Form

**Instructions:** Complete the trigger form with Server Actions.

```typescript
// src/lib/actions/workflow.actions.ts
'use server';

import { inngest } from '@/inngest/client';
import { revalidatePath } from 'next/cache';

// YOUR CODE: Create a Server Action that:
// 1. Accepts form data
// 2. Validates the data
// 3. Sends an event to Inngest
// 4. Returns success/failure

export async function triggerWorkflow(formData: FormData) {
  try {
    // YOUR CODE: Extract data from formData
    
    // YOUR CODE: Validate data
    
    // YOUR CODE: Send event
    const result = await inngest.send({
      name: 'workflow/triggered',
      data: {
        // YOUR CODE: Add event data
      },
    });
    
    revalidatePath('/dashboard');
    
    return {
      success: true,
      runId: result.ids?.[0],
      message: 'Workflow triggered',
    };
  } catch (error) {
    return {
      success: false,
      error: error.message,
    };
  }
}
```

**Solution:**
```typescript
'use server';

import { inngest } from '@/inngest/client';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

const schema = z.object({
  workflowType: z.string(),
  data: z.string().transform(str => JSON.parse(str)),
});

export async function triggerWorkflow(formData: FormData) {
  try {
    const validated = schema.parse({
      workflowType: formData.get('workflowType'),
      data: formData.get('data'),
    });
    
    const result = await inngest.send({
      name: validated.workflowType,
      data: validated.data,
    });
    
    revalidatePath('/dashboard');
    
    return {
      success: true,
      runId: result.ids?.[0],
      message: 'Workflow triggered',
    };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}
```

---

## Module 5.3: Real-Time Updates with SSE

### Learning Objectives
- Implement Server-Sent Events for real-time status
- Build a custom useSSE hook
- Display live workflow progress

### Key Takeaways
```
- SSE streams data from server to client
- Ideal for workflow status updates
- Auto-reconnect handles connection drops
```

### Exercise 5.3: Build the Status Stream

**Instructions:** Complete the SSE endpoint for real-time workflow updates.

```typescript
// src/app/api/workflows/status/stream/route.ts
import { NextRequest } from 'next/server';

export async function GET(request: NextRequest) {
  const runId = request.nextUrl.searchParams.get('runId');
  
  if (!runId) {
    return new Response('Missing runId', { status: 400 });
  }
  
  // YOUR CODE: Create a ReadableStream that:
  // 1. Fetches workflow status periodically
  // 2. Sends updates as SSE events
  // 3. Closes when workflow is complete
  
  const stream = new ReadableStream({
    async start(controller) {
      let isComplete = false;
      
      const sendUpdate = async () => {
        try {
          // YOUR CODE: Fetch status
          const status = await getWorkflowStatus(runId);
          
          // YOUR CODE: Send as SSE
          // Format: `data: ${JSON.stringify(status)}\n\n`
          
          // YOUR CODE: Check if complete
          if (['completed', 'failed'].includes(status.status)) {
            isComplete = true;
            controller.close();
            return;
          }
          
          // YOUR CODE: Continue polling
          if (!isComplete) {
            setTimeout(sendUpdate, 2000);
          }
        } catch (error) {
          controller.error(error);
        }
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

**Solution:**
```typescript
export async function GET(request: NextRequest) {
  const runId = request.nextUrl.searchParams.get('runId');
  
  if (!runId) {
    return new Response('Missing runId', { status: 400 });
  }
  
  const stream = new ReadableStream({
    async start(controller) {
      let isComplete = false;
      
      const sendUpdate = async () => {
        try {
          // Fetch status
          const status = await getWorkflowStatus(runId);
          
          // Send as SSE
          const eventData = `data: ${JSON.stringify(status)}\n\n`;
          controller.enqueue(new TextEncoder().encode(eventData));
          
          // Check if complete
          if (['completed', 'failed', 'cancelled'].includes(status.status)) {
            isComplete = true;
            controller.close();
            return;
          }
          
          // Continue polling
          if (!isComplete) {
            setTimeout(sendUpdate, 2000);
          }
        } catch (error) {
          controller.error(error);
        }
      };
      
      sendUpdate();
    },
  });
  
  return new Response(stream, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache, no-transform',
      'Connection': 'keep-alive',
      'X-Accel-Buffering': 'no',
    },
  });
}
```

---

## Module 5.4: AI Content Generation Dashboard

### Learning Objectives
- Build an AI content generation dashboard
- Use useOptimistic for immediate feedback
- Display workflow status in real-time

### Key Takeaways
```
- useOptimistic shows results before they're ready
- The AI workflow runs durably in the background
- The UI updates as the workflow progresses
```

### Exercise 5.4: AI Content Dashboard

**Instructions:** Complete the AI content dashboard component.

```typescript
// src/app/dashboard/ai-content/page.tsx
'use client';

import { useActionState, useOptimistic, useState } from 'react';
import { generateAIContent } from '@/lib/actions/ai.actions';

const initialState = {
  content: '',
  error: null,
  runId: null,
};

export default function AIContentDashboard() {
  const [state, formAction, isPending] = useActionState(
    generateAIContent,
    initialState
  );
  
  // YOUR CODE: Add useOptimistic for content
  // - Show optimistic content immediately
  // - Fall back to actual content when ready
  
  return (
    <div className="max-w-2xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">AI Content Generator</h1>
      
      <form action={formAction} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">
            Prompt
          </label>
          <textarea
            name="prompt"
            rows={4}
            className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md"
            placeholder="Describe the content you want..."
            required
          />
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700">
            Content Type
          </label>
          <select name="contentType" className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md">
            <option value="blog-post">Blog Post</option>
            <option value="social-media">Social Media</option>
            <option value="email">Email Newsletter</option>
          </select>
        </div>
        
        <button
          type="submit"
          disabled={isPending}
          className="w-full px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
        >
          {isPending ? 'Generating...' : 'Generate Content'}
        </button>
      </form>
      
      {/* YOUR CODE: Display content */}
      {/* - Show optimistic content immediately */}
      {/* - Show actual content when available */}
    </div>
  );
}
```

**Solution:**
```typescript
'use client';

import { useActionState, useOptimistic } from 'react';
import { generateAIContent } from '@/lib/actions/ai.actions';

const initialState = {
  content: '',
  error: null,
  runId: null,
};

export default function AIContentDashboard() {
  const [state, formAction, isPending] = useActionState(
    generateAIContent,
    initialState
  );
  
  const [optimisticContent, addOptimisticContent] = useOptimistic(
    state.content,
    (state, newContent: string) => newContent
  );
  
  return (
    <div className="max-w-2xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">AI Content Generator</h1>
      
      <form action={formAction} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700">
            Prompt
          </label>
          <textarea
            name="prompt"
            rows={4}
            className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md"
            placeholder="Describe the content you want..."
            required
          />
        </div>
        
        <div>
          <label className="block text-sm font-medium text-gray-700">
            Content Type
          </label>
          <select name="contentType" className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md">
            <option value="blog-post">Blog Post</option>
            <option value="social-media">Social Media</option>
            <option value="email">Email Newsletter</option>
          </select>
        </div>
        
        <button
          type="submit"
          disabled={isPending}
          className="w-full px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50"
        >
          {isPending ? 'Generating...' : 'Generate Content'}
        </button>
      </form>
      
      {optimisticContent && (
        <div className="mt-6 p-4 bg-gray-50 border border-gray-200 rounded-lg">
          <h3 className="font-medium mb-2">Generated Content</h3>
          <div className="prose max-w-none whitespace-pre-wrap">
            {optimisticContent}
          </div>
          {isPending && (
            <div className="mt-2 text-sm text-gray-500 animate-pulse">
              ✨ Generating...
            </div>
          )}
        </div>
      )}
      
      {state.error && (
        <div className="mt-4 p-4 bg-red-50 border border-red-200 rounded-md">
          <p className="text-red-600">{state.error}</p>
        </div>
      )}
    </div>
  );
}
```

---

# Part 6: Production & Observability

## Module 6.1: Production Configuration

### Learning Objectives
- Configure environment variables
- Set up production middleware
- Implement health checks

### Key Takeaways
```
- Use environment variables for secrets
- Production middleware adds monitoring
- Health checks monitor system status
```

### Exercise 6.1: Production Configuration

**Instructions:** Complete the production configuration file.

```typescript
// src/lib/config/index.ts
import { z } from 'zod';

// YOUR CODE: Define environment variable schema
// - NODE_ENV (development, test, production)
// - INNGEST_EVENT_KEY
// - INNGEST_SIGNING_KEY
// - DATABASE_URL
// - JWT_SECRET (min 32 chars)

// YOUR CODE: Validate and export config

export const config = { /* ... */ };
export const isProduction = false; // Update this
```

**Solution:**
```typescript
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  INNGEST_EVENT_KEY: z.string().min(1),
  INNGEST_SIGNING_KEY: z.string().min(1),
  DATABASE_URL: z.string().min(1),
  JWT_SECRET: z.string().min(32),
});

const validateEnv = () => {
  try {
    return envSchema.parse(process.env);
  } catch (error) {
    if (error instanceof z.ZodError) {
      throw new Error(`Environment validation failed:\n${error.issues.map(i => `${i.path.join('.')}: ${i.message}`).join('\n')}`);
    }
    throw error;
  }
};

export const config = validateEnv();
export const isProduction = config.NODE_ENV === 'production';
```

---

## Module 6.2: Deployment Strategies

### Learning Objectives
- Deploy workflows to Vercel
- Deploy workflows to AWS Lambda
- Deploy workflows with Docker

### Key Takeaways
```
- Vercel: Fastest, simplest deployment
- AWS Lambda: Enterprise-grade, most control
- Docker: Ultimate flexibility
```

### Exercise 6.2: Deployment Configuration

**Instructions:** Complete the Vercel deployment configuration.

```json
// vercel.json
{
  "version": 2,
  "builds": [
    {
      // YOUR CODE: Specify build configuration
    }
  ],
  "env": {
    // YOUR CODE: List environment variables
  },
  "functions": {
    "api/inngest/**/*.ts": {
      // YOUR CODE: Configure function settings
    }
  }
}
```

**Solution:**
```json
{
  "version": 2,
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/next"
    }
  ],
  "env": {
    "NODE_ENV": "production",
    "INNGEST_EVENT_KEY": "@inngest-event-key",
    "INNGEST_SIGNING_KEY": "@inngest-signing-key",
    "NEXT_PUBLIC_APP_URL": "@app-url",
    "DATABASE_URL": "@database-url"
  },
  "functions": {
    "api/inngest/**/*.ts": {
      "maxDuration": 60,
      "memory": 1024
    }
  }
}
```

---

## Module 6.3: Monitoring & Observability

### Learning Objectives
- Implement structured logging
- Collect metrics from workflows
- Build a monitoring dashboard

### Key Takeaways
```
- Structured logs include context
- Metrics track performance over time
- A dashboard provides visibility
```

### Exercise 6.3: Structured Logging

**Instructions:** Complete the structured logger.

```typescript
// src/lib/monitoring/logger.ts
export enum LogLevel {
  DEBUG = 'debug',
  INFO = 'info',
  WARN = 'warn',
  ERROR = 'error',
}

export class Logger {
  // YOUR CODE: Implement a structured logger
  // - Include timestamp
  // - Include level
  // - Include message
  // - Include context
  // - Include error (for error level)
}
```

**Solution:**
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
    const entry = {
      level,
      message,
      timestamp: new Date().toISOString(),
      context,
      error: error ? { message: error.message, stack: error.stack } : undefined,
    };
    
    const output = JSON.stringify(entry);
    
    switch (level) {
      case LogLevel.ERROR:
        console.error(output);
        break;
      case LogLevel.WARN:
        console.warn(output);
        break;
      case LogLevel.DEBUG:
        console.debug(output);
        break;
      default:
        console.log(output);
    }
  }
  
  debug(message: string, context?: Record<string, any>) {
    this.log(LogLevel.DEBUG, message, context);
  }
  
  info(message: string, context?: Record<string, any>) {
    this.log(LogLevel.INFO, message, context);
  }
  
  warn(message: string, context?: Record<string, any>) {
    this.log(LogLevel.WARN, message, context);
  }
  
  error(message: string, error?: Error, context?: Record<string, any>) {
    this.log(LogLevel.ERROR, message, context, error);
  }
}

export const logger = Logger.getInstance();
```

---

## Module 6.4: Production Checklist

### Learning Objectives
- Review all production requirements
- Complete the pre-deployment checklist
- Ensure production readiness

### Key Takeaways
```
- Security is the top priority
- Monitoring provides visibility
- Testing prevents failures
```

### Exercise 6.4: Production Readiness Review

**Instructions:** Mark each item as complete or incomplete for your project.

**Security**
- [ ] All secrets are in environment variables
- [ ] Event signing keys are configured
- [ ] Rate limiting is enabled
- [ ] CORS is properly configured
- [ ] Security headers are set

**Reliability**
- [ ] Retry policies are configured
- [ ] Error handling is comprehensive
- [ ] Health checks are implemented
- [ ] Circuit breakers are in place

**Observability**
- [ ] Logging is structured
- [ ] Metrics are collected
- [ ] Alerts are configured
- [ ] Dashboard is set up

**Deployment**
- [ ] CI/CD pipeline is configured
- [ ] Rollback plan exists
- [ ] Database migrations are automated
- [ ] Load testing has been performed

**Reflection:**
- What's the biggest gap in your production readiness?
  ____________________________________________________________
- What will you work on next?
  ____________________________________________________________

---

# Appendix A: AI Workflows

## Module A.1: AI Content Generation

### Learning Objectives
- Build AI-powered content generation workflows
- Use step.ai.infer() for durable AI calls
- Handle AI rate limits and costs

### Exercise A.1: AI Content Workflow

**Instructions:** Complete the AI content generation workflow.

```typescript
// src/inngest/functions/ai-content.ts
import { inngest } from '@/inngest/client';
import { openai, models } from '@/lib/ai/client';

export const aiContentWorkflow = inngest.createFunction(
  {
    id: 'ai-content-workflow',
    name: 'AI Content Workflow',
    rateLimit: {
      // YOUR CODE: Add rate limiting
    },
  },
  { event: 'ai/content-requested' },
  async ({ event, step, logger }) => {
    const { generationId, prompt, format } = event.data;
    
    // Step 1: Enhance the prompt
    // YOUR CODE: Build a system prompt
    
    // Step 2: Generate content with LLM
    // YOUR CODE: Use step.ai.infer() or openai.chat.completions
    
    // Step 3: Analyze content quality
    // YOUR CODE: Check word count, readability
    
    // Step 4: Store content
    // YOUR CODE: Save to database
    
    return {
      generationId,
      content,
      // YOUR CODE: Add metadata
    };
  }
);
```

---

## Module A.2: Multi-Agent Orchestration

### Learning Objectives
- Orchestrate multiple AI agents
- Coordinate agent interactions
- Aggregate agent results

### Exercise A.2: Multi-Agent Document Processing

**Instructions:** Complete the multi-agent workflow.

```typescript
// src/inngest/functions/multi-agent.ts
import { inngest } from '@/inngest/client';

export const multiAgentWorkflow = inngest.createFunction(
  {
    id: 'multi-agent-workflow',
    name: 'Multi-Agent Document Processing',
  },
  { event: 'document/process' },
  async ({ event, step, logger }) => {
    const { documentId, content } = event.data;
    
    // Agent 1: Summarizer
    // YOUR CODE: Summarize the document
    
    // Agent 2: Extractor
    // YOUR CODE: Extract key entities
    
    // Agent 3: Sentiment Analyzer
    // YOUR CODE: Analyze sentiment
    
    // Step 4: Aggregate results
    // YOUR CODE: Combine all agent outputs
    
    return {
      documentId,
      summary,
      entities,
      sentiment,
      // YOUR CODE: Add more fields
    };
  }
);
```

---

## Module A.3: RAG Workflows

### Learning Objectives
- Implement Retrieval-Augmented Generation
- Build vector search integration
- Combine retrieval with generation

### Exercise A.3: RAG Implementation

**Instructions:** Complete the RAG workflow.

```typescript
// src/inngest/functions/rag-workflow.ts
import { inngest } from '@/inngest/client';

export const ragWorkflow = inngest.createFunction(
  {
    id: 'rag-workflow',
    name: 'RAG Workflow',
  },
  { event: 'rag/query' },
  async ({ event, step, logger }) => {
    const { queryId, query } = event.data;
    
    // Step 1: Retrieve relevant documents
    // YOUR CODE: Search vector database
    
    // Step 2: Augment prompt with context
    // YOUR CODE: Build prompt with retrieved documents
    
    // Step 3: Generate response
    // YOUR CODE: Call LLM with augmented prompt
    
    // Step 4: Evaluate response
    // YOUR CODE: Check quality
    
    return {
      queryId,
      answer,
      sources,
      // YOUR CODE: Add evaluation
    };
  }
);
```

---

# Appendix B: Reference

## Quick Reference Cards

### Function Configuration
```typescript
{
  id: "unique-id",
  name: "Display Name",
  retries: 3,
  retryDelay: "5s",
  concurrency: { limit: 10 },
  rateLimit: { limit: 100, period: "1m" },
  idempotency: { key: "data.orderId", ttl: "30d" },
  version: "1.0.0",
}
```

### Step Methods
| Method | Purpose |
|--------|---------|
| `step.run(name, fn)` | Execute a durable step |
| `step.sleep(name, ms)` | Pause for duration |
| `step.sleepUntil(name, date)` | Pause until time |
| `step.waitForEvent(name, config)` | Wait for event |
| `step.sendEvent(name, events)` | Send events |

### Common Commands
```bash
# Start dev server
inngest dev -u http://localhost:3000/api/inngest

# Trigger event (curl)
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{"name":"event/name","data":{...}}'

# Send event (code)
await inngest.send({ name: "event/name", data: { ... } })
```

---

## Troubleshooting Guide

### Issue: Function Not Registered
**Solution:** Check `serve()` includes the function in the array.

### Issue: Events Not Triggering
**Solution:** Verify event name matches exactly.

### Issue: WaitForEvent Timing Out
**Solution:** Check matching condition, increase timeout.

### Issue: Retries Exhausted
**Solution:** Check step logic, verify external service availability.

### Issue: Concurrency Limit Reached
**Solution:** Increase concurrency limit, check for stuck executions.

### Issue: Rate Limit Exceeded
**Solution:** Reduce event frequency, increase limit, add throttling.

---

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

# Conclusion

Congratulations on completing the Mastering Inngest Student Workbook!

**What You've Accomplished:**
- ✅ Built 6 production-ready workflows
- ✅ Mastered durable execution concepts
- ✅ Implemented high-performance patterns
- ✅ Integrated with React and Next.js
- ✅ Deployed to production
- ✅ Built AI workflows

**Next Steps:**
1. Build your own workflows
2. Join the Inngest community
3. Contribute to open source
4. Share what you've learned

**Resources:**
- Inngest Documentation: https://www.inngest.com/docs
- Inngest Discord: https://discord.gg/inngest
- GitHub: https://github.com/inngest/inngest

---

*End of Student Workbook*
