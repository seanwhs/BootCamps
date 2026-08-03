# Mastering Inngest: Lab Book

## Hands-On Laboratory Exercises for the Complete Series

---

# Welcome & Instructions

## How to Use This Lab Book

This Lab Book contains all the hands-on exercises for the "Mastering Inngest" series. Each exercise is designed to reinforce key concepts through practical implementation.

**Lab Structure:**
- **Objective:** What you will accomplish
- **Estimated Time:** How long the exercise should take
- **Prerequisites:** What you need before starting
- **Steps:** Detailed instructions with code blocks
- **Verification:** How to confirm your work is correct
- **Challenge:** Additional tasks for advanced learners
- **Troubleshooting:** Common issues and solutions

**Lab Environment Requirements:**
- Node.js 20+ installed
- pnpm or npm installed
- VS Code (recommended)
- Git (optional)

---

# Lab 0: Environment Setup

## 0.1: Development Environment Verification

**Objective:** Ensure your development environment is properly configured
**Estimated Time:** 15 minutes
**Prerequisites:** Node.js installed

### Setup Instructions

**Step 1: Verify Node.js Version**
```bash
node --version
# Should show v20.x or higher
```

**Step 2: Verify Package Manager**
```bash
pnpm --version
# or
npm --version
```

**Step 3: Install Inngest CLI**
```bash
curl -sSfL https://cli.inngest.com/install.sh | sh
inngest --version
```

**Step 4: Install Code Editor Extensions (VS Code)**
- TypeScript/JavaScript
- ESLint
- Prettier
- Tailwind CSS IntelliSense

### Verification Checklist
- [ ] Node.js 20+ installed
- [ ] Package manager installed
- [ ] Inngest CLI installed
- [ ] Code editor ready

---

## 0.2: Project Creation

**Objective:** Create the Next.js project with Inngest
**Estimated Time:** 15 minutes
**Prerequisites:** Lab 0.1 completed

**Step 1: Create Next.js Project**
```bash
pnpm create next-app@latest workflowhub --typescript --tailwind --app --no-src-dir
cd workflowhub
```

**Step 2: Install Dependencies**
```bash
pnpm add inngest inngest/next zod uuid
pnpm add -D @types/uuid
```

**Step 3: Create .env.local**
```bash
echo "INNGEST_DEV=true" > .env.local
```

**Step 4: Start Development Server**
```bash
pnpm dev
# Should start on http://localhost:3000
```

### Verification Checklist
- [ ] Next.js project created
- [ ] Dependencies installed
- [ ] Development server starts
- [ ] http://localhost:3000 displays the app

---

# Lab 1: Foundations — Events & Durable Execution

## 1.1: Creating the Inngest Client

**Objective:** Set up the Inngest client and API route
**Estimated Time:** 20 minutes
**Prerequisites:** Lab 0 completed

**Step 1: Create Client File**
Create `src/inngest/client.ts`:
```typescript
import { Inngest } from 'inngest';

export const inngest = new Inngest({
  id: 'workflowhub',
  name: 'WorkflowHub',
  eventKey: process.env.INNGEST_EVENT_KEY,
});
```

**Step 2: Create API Route**
Create `src/app/api/inngest/route.ts`:
```typescript
import { serve } from 'inngest/next';
import { inngest } from '@/inngest/client';

export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [], // We'll add functions later
});

export const config = {
  api: {
    bodyParser: false,
  },
};
```

**Step 3: Start Dev Server**
```bash
# Terminal 1: Start Next.js
pnpm dev

# Terminal 2: Start Dev Server
inngest dev -u http://localhost:3000/api/inngest
```

### Verification Checklist
- [ ] Client file created
- [ ] API route created
- [ ] Dev Server running
- [ ] http://localhost:8288 displays the dashboard

---

## 1.2: Building Your First Function

**Objective:** Create a user registration workflow
**Estimated Time:** 30 minutes
**Prerequisites:** Lab 1.1 completed

**Step 1: Create the Function**
Create `src/inngest/functions/user-registration.ts`:
```typescript
import { inngest } from '@/inngest/client';
import { z } from 'zod';

const schema = z.object({
  userId: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(2),
  plan: z.enum(['free', 'pro', 'enterprise']),
});

export const userRegistrationWorkflow = inngest.createFunction(
  {
    id: 'user-registration-workflow',
    name: 'User Registration Workflow',
    retries: 3,
  },
  { event: 'user/registered' },
  async ({ event, step, logger }) => {
    const validated = schema.parse(event.data);
    const { userId, email, name, plan } = validated;

    logger.info('Processing user registration', { userId, email, plan });

    // Step 1: Send welcome email
    const emailResult = await step.run('send-welcome-email', async () => {
      // Simulate email sending
      await new Promise((resolve) => setTimeout(resolve, 1000));
      return {
        messageId: `msg-${Date.now()}`,
        sentAt: new Date().toISOString(),
      };
    });

    // Step 2: Create user profile
    const profile = await step.run('create-user-profile', async () => {
      await new Promise((resolve) => setTimeout(resolve, 500));
      return {
        id: userId,
        email,
        name,
        plan,
        createdAt: new Date().toISOString(),
      };
    });

    // Step 3: Sync with CRM
    const crmResult = await step.run('sync-with-crm', async () => {
      await new Promise((resolve) => setTimeout(resolve, 700));
      return {
        crmId: `crm-${userId.slice(0, 8)}`,
        status: 'synced',
      };
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

**Step 2: Register the Function**
Update `src/app/api/inngest/route.ts`:
```typescript
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

**Step 3: Trigger the Event**
```bash
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "user/registered",
    "data": {
      "userId": "123e4567-e89b-12d3-a456-426614174000",
      "email": "test@example.com",
      "name": "Test User",
      "plan": "pro"
    }
  }'
```

### Verification Checklist
- [ ] Function created and registered
- [ ] Event triggered successfully
- [ ] Run appears in Dev Server
- [ ] All steps completed

---

## 1.3: Testing Retry Behavior

**Objective:** Simulate failures and observe retry behavior
**Estimated Time:** 20 minutes
**Prerequisites:** Lab 1.2 completed

**Step 1: Add Failure Simulation**
Update `src/inngest/functions/user-registration.ts`:
```typescript
// Add at the top of the file
const simulateFailure = (rate: number = 0.5) => {
  if (Math.random() < rate) {
    throw new Error('Simulated failure for testing');
  }
};

// Update the email step
const emailResult = await step.run('send-welcome-email', async () => {
  simulateFailure(0.7); // 70% chance of failure
  await new Promise((resolve) => setTimeout(resolve, 1000));
  return {
    messageId: `msg-${Date.now()}`,
    sentAt: new Date().toISOString(),
  };
});
```

**Step 2: Trigger Again**
```bash
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "user/registered",
    "data": {
      "userId": "223e4567-e89b-12d3-a456-426614174000",
      "email": "retry-test@example.com",
      "name": "Retry Test",
      "plan": "free"
    }
  }'
```

**Step 3: Observe in Dev Server**
- Note how many retries occurred
- Observe the delay between retries
- Check which steps were re-executed

### Challenge
- Change the failure rate to 0.9 (90%)
- Observe what happens
- Try to make the step succeed on the second attempt

### Verification Checklist
- [ ] Retry behavior observed
- [ ] Failed step is retried
- [ ] Previous steps not re-executed
- [ ] Successful steps are memoized

---

# Lab 2: State Management & Fault Tolerance

## 2.1: Implementing Idempotency

**Objective:** Build an idempotent payment step
**Estimated Time:** 30 minutes
**Prerequisites:** Lab 1 completed

**Step 1: Create Payment Workflow**
Create `src/inngest/functions/payment-processing.ts`:
```typescript
import { inngest } from '@/inngest/client';

// Simulate database
const payments: Record<string, any> = {};

export const paymentWorkflow = inngest.createFunction(
  {
    id: 'payment-workflow',
    name: 'Payment Processing Workflow',
    retries: 3,
  },
  { event: 'payment/initiated' },
  async ({ event, step, logger }) => {
    const { orderId, amount } = event.data;

    // IDEMPOTENT PAYMENT STEP
    const payment = await step.run('process-payment', async () => {
      const idempotencyKey = `payment-${orderId}`;

      // Check if already processed
      const existing = payments[idempotencyKey];
      if (existing) {
        logger.info('Payment already processed', { orderId });
        return existing;
      }

      // Simulate payment processing
      await new Promise((resolve) => setTimeout(resolve, 1500));

      // Simulate occasional failure
      if (Math.random() < 0.2) {
        throw new Error('Payment service temporarily unavailable');
      }

      const result = {
        transactionId: `txn-${Date.now()}`,
        amount,
        status: 'completed',
        processedAt: new Date().toISOString(),
      };

      // Store result
      payments[idempotencyKey] = result;
      return result;
    });

    // Step 2: Update order status
    const order = await step.run('update-order-status', async () => {
      await new Promise((resolve) => setTimeout(resolve, 300));
      return {
        orderId,
        status: 'paid',
        updatedAt: new Date().toISOString(),
      };
    });

    return {
      success: true,
      payment,
      order,
    };
  }
);
```

**Step 2: Register the Function**
Update `src/app/api/inngest/route.ts`:
```typescript
import { paymentWorkflow } from '@/inngest/functions/payment-processing';
// Add to functions array
```

**Step 3: Trigger Multiple Times**
```bash
# Trigger once
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "payment/initiated",
    "data": {
      "orderId": "order-123",
      "amount": 99.99
    }
  }'

# Trigger again with same orderId
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "payment/initiated",
    "data": {
      "orderId": "order-123",
      "amount": 99.99
    }
  }'
```

### Verification Checklist
- [ ] First execution succeeds
- [ ] Second execution returns cached result
- [ ] No duplicate payment processing
- [ ] Payment appears once in logs

---

## 2.2: Implementing the Saga Pattern

**Objective:** Build a travel booking saga with compensation
**Estimated Time:** 45 minutes
**Prerequisites:** Lab 2.1 completed

**Step 1: Create the Saga Workflow**
Create `src/inngest/functions/booking-saga.ts`:
```typescript
import { inngest } from '@/inngest/client';

// Simulate external services
const services = {
  airline: {
    reservations: {} as Record<string, any>,
    reserve: async (id: string) => {
      await new Promise((resolve) => setTimeout(resolve, 800));
      const result = { id, status: 'reserved', provider: 'airline' };
      services.airline.reservations[id] = result;
      return result;
    },
    cancel: async (id: string) => {
      await new Promise((resolve) => setTimeout(resolve, 500));
      delete services.airline.reservations[id];
      return { id, status: 'canceled' };
    },
  },
  hotel: {
    reservations: {} as Record<string, any>,
    reserve: async (id: string) => {
      await new Promise((resolve) => setTimeout(resolve, 800));
      const result = { id, status: 'reserved', provider: 'hotel' };
      services.hotel.reservations[id] = result;
      return result;
    },
    cancel: async (id: string) => {
      await new Promise((resolve) => setTimeout(resolve, 500));
      delete services.hotel.reservations[id];
      return { id, status: 'canceled' };
    },
  },
  car: {
    reservations: {} as Record<string, any>,
    reserve: async (id: string) => {
      // Simulate occasional failure (30% chance)
      if (Math.random() < 0.3) {
        throw new Error('Car rental service unavailable');
      }
      await new Promise((resolve) => setTimeout(resolve, 800));
      const result = { id, status: 'reserved', provider: 'car' };
      services.car.reservations[id] = result;
      return result;
    },
    cancel: async (id: string) => {
      await new Promise((resolve) => setTimeout(resolve, 500));
      delete services.car.reservations[id];
      return { id, status: 'canceled' };
    },
  },
};

export const bookingSagaWorkflow = inngest.createFunction(
  {
    id: 'booking-saga-workflow',
    name: 'Travel Booking Saga',
    retries: 2,
  },
  { event: 'booking/requested' },
  async ({ event, step, logger }) => {
    const { bookingId, flightId, hotelId, carId } = event.data;
    const reservations = {};

    try {
      // Step 1: Reserve flight
      reservations.flight = await step.run('reserve-flight', async () => {
        return await services.airline.reserve(flightId);
      });

      // Step 2: Reserve hotel
      reservations.hotel = await step.run('reserve-hotel', async () => {
        return await services.hotel.reserve(hotelId);
      });

      // Step 3: Reserve car (may fail)
      reservations.car = await step.run('reserve-car', async () => {
        return await services.car.reserve(carId);
      });

      // Step 4: Confirm booking
      await step.run('confirm-booking', async () => {
        await new Promise((resolve) => setTimeout(resolve, 300));
        return { id: bookingId, status: 'confirmed' };
      });

      return { success: true, reservations };

    } catch (error) {
      logger.error('Booking failed, initiating compensation', {
        bookingId,
        error: error.message,
      });

      // COMPENSATION: Cancel in reverse order
      if (reservations.car) {
        await step.run('cancel-car', async () => {
          return await services.car.cancel(reservations.car.id);
        });
      }
      if (reservations.hotel) {
        await step.run('cancel-hotel', async () => {
          return await services.hotel.cancel(reservations.hotel.id);
        });
      }
      if (reservations.flight) {
        await step.run('cancel-flight', async () => {
          return await services.airline.cancel(reservations.flight.id);
        });
      }

      throw new Error(`Booking failed: ${error.message}`);
    }
  }
);
```

**Step 2: Register the Function**
Update `src/app/api/inngest/route.ts`:
```typescript
import { bookingSagaWorkflow } from '@/inngest/functions/booking-saga';
// Add to functions array
```

**Step 3: Trigger the Saga**
```bash
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "booking/requested",
    "data": {
      "bookingId": "booking-123",
      "flightId": "flight-456",
      "hotelId": "hotel-789",
      "carId": "car-101"
    }
  }'
```

### Challenge
- Trigger the workflow multiple times
- Observe when the car step fails
- Verify compensation executes in correct order

### Verification Checklist
- [ ] Saga completes successfully when car available
- [ ] Saga compensates when car fails
- [ ] Compensation executes in reverse order
- [ ] All reservations are canceled on failure

---

## 2.3: Time-Based Orchestration

**Objective:** Build a scheduled reminder system
**Estimated Time:** 30 minutes
**Prerequisites:** Lab 2.2 completed

**Step 1: Create Reminder Workflow**
Create `src/inngest/functions/reminder-system.ts`:
```typescript
import { inngest } from '@/inngest/client';

export const reminderWorkflow = inngest.createFunction(
  {
    id: 'reminder-workflow',
    name: 'Reminder System',
    retries: 3,
  },
  { event: 'reminder/created' },
  async ({ event, step, logger }) => {
    const { reminderId, email, message, scheduledFor, recurrence } = event.data;

    // Calculate wait time
    const scheduledTime = new Date(scheduledFor).getTime();
    const currentTime = Date.now();
    const waitTime = scheduledTime - currentTime;

    logger.info('Processing reminder', {
      reminderId,
      scheduledFor,
      waitTimeSeconds: Math.floor(waitTime / 1000),
    });

    // Wait until the scheduled time
    if (waitTime > 0) {
      await step.sleep('wait-for-reminder', waitTime);
    }

    logger.info('Reminder time arrived', { reminderId });

    // Send reminder
    await step.run('send-reminder', async () => {
      // Simulate sending
      await new Promise((resolve) => setTimeout(resolve, 500));
      logger.info('Reminder sent', { reminderId, email });
      return {
        sent: true,
        sentAt: new Date().toISOString(),
        messageId: `msg-${Date.now()}`,
      };
    });

    // Handle recurrence
    let nextReminder = null;
    if (recurrence !== 'once') {
      const nextDate = new Date(scheduledTime);
      if (recurrence === 'daily') {
        nextDate.setDate(nextDate.getDate() + 1);
      } else if (recurrence === 'weekly') {
        nextDate.setDate(nextDate.getDate() + 7);
      }

      // Schedule next reminder
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

    return {
      reminderId,
      sent: true,
      sentAt: new Date().toISOString(),
      nextReminder,
    };
  }
);
```

**Step 2: Register the Function**
Update `src/app/api/inngest/route.ts`:
```typescript
import { reminderWorkflow } from '@/inngest/functions/reminder-system';
// Add to functions array
```

**Step 3: Schedule a Reminder (10 seconds from now)**
```bash
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "reminder/created",
    "data": {
      "reminderId": "reminder-123",
      "email": "test@example.com",
      "message": "Test reminder",
      "scheduledFor": "'$(date -v+10S -Iseconds)'",
      "recurrence": "once"
    }
  }'
```

### Challenge
- Schedule a reminder for 1 minute from now
- Schedule a daily recurring reminder
- Observe the workflow in the Dev Server during the sleep

### Verification Checklist
- [ ] Workflow sleeps until scheduled time
- [ ] Reminder sent at correct time
- [ ] Next reminder scheduled for recurrence
- [ ] Sleep state persists in Dev Server

---

# Lab 3: High-Performance Patterns

## 3.1: Fan-Out / Fan-In

**Objective:** Build a bulk email campaign with fan-out/fan-in
**Estimated Time:** 45 minutes
**Prerequisites:** Lab 2 completed

**Step 1: Create Bulk Email Workflow**
Create `src/inngest/functions/bulk-email.ts`:
```typescript
import { inngest } from '@/inngest/client';

// Simulate email sending
const sendEmail = async (recipient: any) => {
  await new Promise((resolve) => setTimeout(resolve, 100 + Math.random() * 200));
  // Simulate occasional failure (5%)
  if (Math.random() < 0.05) {
    throw new Error(`Failed to send to ${recipient.email}`);
  }
  return {
    messageId: `msg-${Date.now()}-${recipient.id}`,
    sentAt: new Date().toISOString(),
  };
};

export const bulkEmailWorkflow = inngest.createFunction(
  {
    id: 'bulk-email-workflow',
    name: 'Bulk Email Campaign',
    retries: 2,
  },
  { event: 'campaign/triggered' },
  async ({ event, step, logger }) => {
    const { campaignId, recipients, subject, body } = event.data;

    logger.info('Starting bulk email campaign', {
      campaignId,
      recipientCount: recipients.length,
    });

    const BATCH_SIZE = 50;
    const allResults = [];

    // Process in batches
    for (let i = 0; i < recipients.length; i += BATCH_SIZE) {
      const batch = recipients.slice(i, i + BATCH_SIZE);

      const batchResults = await step.run(`process-batch-${i}`, async () => {
        logger.info(`Processing batch ${i / BATCH_SIZE + 1}`, {
          batchStart: i,
          batchEnd: Math.min(i + BATCH_SIZE, recipients.length),
        });

        // FAN-OUT: Send all emails in this batch in parallel
        const emailPromises = batch.map(async (recipient: any) => {
          try {
            const result = await sendEmail(recipient);
            return {
              recipientId: recipient.id,
              email: recipient.email,
              success: true,
              ...result,
            };
          } catch (error) {
            return {
              recipientId: recipient.id,
              email: recipient.email,
              success: false,
              error: error.message,
            };
          }
        });

        // FAN-IN: Wait for all emails in this batch
        return await Promise.all(emailPromises);
      });

      allResults.push(...batchResults);

      // Rate limiting delay between batches
      if (i + BATCH_SIZE < recipients.length) {
        await step.sleep('rate-limit-delay', 500);
      }
    }

    // Aggregate results
    const stats = {
      total: allResults.length,
      sent: allResults.filter((r) => r.success).length,
      failed: allResults.filter((r) => !r.success).length,
    };

    logger.info('Campaign completed', {
      campaignId,
      stats,
    });

    return {
      campaignId,
      stats,
      failedRecipients: allResults
        .filter((r) => !r.success)
        .map((r) => ({ email: r.email, error: r.error })),
      completedAt: new Date().toISOString(),
    };
  }
);
```

**Step 2: Register the Function**
Update `src/app/api/inngest/route.ts`:
```typescript
import { bulkEmailWorkflow } from '@/inngest/functions/bulk-email';
// Add to functions array
```

**Step 3: Trigger the Campaign**
```bash
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "campaign/triggered",
    "data": {
      "campaignId": "campaign-123",
      "subject": "Weekly Newsletter",
      "body": "<h1>Hello!</h1><p>Here is your newsletter...</p>",
      "recipients": [
        {"id": "1", "email": "user1@example.com"},
        {"id": "2", "email": "user2@example.com"},
        {"id": "3", "email": "user3@example.com"},
        {"id": "4", "email": "user4@example.com"},
        {"id": "5", "email": "user5@example.com"}
      ]
    }
  }'
```

### Challenge
- Increase the recipient count to 100
- Observe the parallel processing in the Dev Server
- Add more sophisticated error handling

### Verification Checklist
- [ ] All emails processed in parallel batches
- [ ] Results aggregated correctly
- [ ] Failures are captured
- [ ] Rate limiting between batches works

---

## 3.2: Concurrency & Rate Limiting

**Objective:** Configure concurrency and rate limiting
**Estimated Time:** 30 minutes
**Prerequisites:** Lab 3.1 completed

**Step 1: Create Task Scheduler**
Create `src/inngest/functions/task-scheduler.ts`:
```typescript
import { inngest } from '@/inngest/client';

export const taskSchedulerWorkflow = inngest.createFunction(
  {
    id: 'task-scheduler-workflow',
    name: 'Task Scheduler',
    // CONFIGURATION: Add concurrency and rate limiting
    concurrency: {
      limit: 5, // Max 5 concurrent runs
      scope: 'fn',
    },
    rateLimit: {
      limit: 20, // Max 20 executions per
      period: '1m', // minute
    },
  },
  { event: 'task/scheduled' },
  async ({ event, step, logger }) => {
    const { taskId, tenantId, type, payload } = event.data;

    logger.info('Processing task', { taskId, tenantId, type });

    // Simulate task processing
    const result = await step.run('process-task', async () => {
      // Variable processing time
      const duration = 1000 + Math.random() * 3000;
      await new Promise((resolve) => setTimeout(resolve, duration));

      // Simulate occasional failure (10%)
      if (Math.random() < 0.1) {
        throw new Error('Task processing failed');
      }

      return {
        taskId,
        status: 'completed',
        processedAt: new Date().toISOString(),
        duration,
      };
    });

    return result;
  }
);
```

**Step 2: Register the Function**
Update `src/app/api/inngest/route.ts`:
```typescript
import { taskSchedulerWorkflow } from '@/inngest/functions/task-scheduler';
// Add to functions array
```

**Step 3: Trigger Multiple Tasks**
```bash
# Send 20 tasks quickly
for i in {1..20}; do
  curl -X POST http://localhost:3000/api/inngest \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"task/scheduled\",
      \"data\": {
        \"taskId\": \"task-$i\",
        \"tenantId\": \"tenant-1\",
        \"type\": \"data-processing\",
        \"payload\": {\"job\": \"task-$i\"}
      }
    }"
done
```

### Challenge
- Add key-based concurrency per tenant
- Configure different limits for different tenant tiers

### Verification Checklist
- [ ] Only 5 tasks run concurrently
- [ ] Rate limiting prevents more than 20 per minute
- [ ] Tasks are queued when limits are reached
- [ ] Dev Server shows queued tasks

---

# Lab 4: Long-Running Workflows & Human-in-the-Loop

## 4.1: Approval Workflow

**Objective:** Build an approval workflow with human-in-the-loop
**Estimated Time:** 45 minutes
**Prerequisites:** Lab 3 completed

**Step 1: Create Approval Workflow**
Create `src/inngest/functions/approval-workflow.ts`:
```typescript
import { inngest } from '@/inngest/client';

export const approvalWorkflow = inngest.createFunction(
  {
    id: 'approval-workflow',
    name: 'Approval Workflow',
    retries: 3,
  },
  { event: 'approval/requested' },
  async ({ event, step, logger }) => {
    const {
      approvalId,
      requesterId,
      amount,
      description,
      approverEmail,
      urgency,
    } = event.data;

    logger.info('Starting approval process', {
      approvalId,
      amount,
      urgency,
    });

    // Step 1: Notify approver
    await step.run('notify-approver', async () => {
      logger.info('Notifying approver', { approvalId, approverEmail });
      await new Promise((resolve) => setTimeout(resolve, 300));
      return { notified: true, notifiedAt: new Date().toISOString() };
    });

    // Step 2: Wait for approval decision
    let approved = false;
    let decision = null;
    let timeout = false;

    const timeoutDuration = urgency === 'critical' ? '1h' : '24h';

    try {
      decision = await step.waitForEvent('wait-for-approval', {
        event: 'approval/decision',
        timeout: timeoutDuration,
        match: (data: any) => data.approvalId === approvalId,
      });

      approved = decision.data.approved;
      logger.info('Approval decision received', {
        approvalId,
        approved,
        approver: decision.data.approver,
      });

    } catch {
      timeout = true;
      logger.warn('Approval timed out', { approvalId, timeoutDuration });
    }

    // Step 3: Handle decision or timeout
    if (timeout) {
      // Escalate for critical or high urgency
      if (urgency === 'critical' || urgency === 'high') {
        await step.run('escalate-approval', async () => {
          logger.info('Escalating approval', { approvalId });
          await new Promise((resolve) => setTimeout(resolve, 500));
          return {
            escalated: true,
            escalatedTo: 'manager@workflowhub.com',
            escalatedAt: new Date().toISOString(),
          };
        });

        // Wait for escalation decision
        try {
          const escalationDecision = await step.waitForEvent('wait-for-escalation', {
            event: 'approval/escalation-decision',
            timeout: '2h',
            match: (data: any) => data.approvalId === approvalId,
          });

          approved = escalationDecision.data.approved;
        } catch {
          // Escalation timeout - auto-deny
          approved = false;
          logger.warn('Escalation timed out, auto-denying', { approvalId });
        }
      } else {
        // Auto-deny for low/medium urgency
        approved = false;
        logger.info('Auto-denying approval due to timeout', { approvalId });
      }
    }

    // Step 4: Execute approved action
    if (approved) {
      await step.run('execute-approval', async () => {
        logger.info('Executing approved action', { approvalId });
        await new Promise((resolve) => setTimeout(resolve, 1000));
        return {
          executed: true,
          executedAt: new Date().toISOString(),
        };
      });

      await step.run('notify-requester-approved', async () => {
        logger.info('Notifying requester of approval', { approvalId });
        await new Promise((resolve) => setTimeout(resolve, 300));
        return { notified: true };
      });
    } else {
      await step.run('notify-requester-denied', async () => {
        logger.info('Notifying requester of denial', { approvalId });
        await new Promise((resolve) => setTimeout(resolve, 300));
        return { notified: true };
      });
    }

    return {
      approvalId,
      status: approved ? 'approved' : 'denied',
      approved,
      decision,
      timeout,
      processedAt: new Date().toISOString(),
    };
  }
);
```

**Step 2: Register the Function**
Update `src/app/api/inngest/route.ts`:
```typescript
import { approvalWorkflow } from '@/inngest/functions/approval-workflow';
// Add to functions array
```

**Step 3: Request Approval**
```bash
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "approval/requested",
    "data": {
      "approvalId": "approval-123",
      "requesterId": "user-456",
      "amount": 5000,
      "description": "New server equipment",
      "approverEmail": "approver@workflowhub.com",
      "urgency": "medium"
    }
  }'
```

**Step 4: Send Approval Decision**
```bash
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "approval/decision",
    "data": {
      "approvalId": "approval-123",
      "approved": true,
      "approver": "approver@workflowhub.com",
      "comments": "Approved. Budget is available.",
      "timestamp": "'$(date -Iseconds)'"
    }
  }'
```

### Challenge
- Test the timeout behavior
- Test escalation for critical requests
- Test the auto-deny for low urgency

### Verification Checklist
- [ ] Workflow waits for approval decision
- [ ] Approval resumes workflow correctly
- [ ] Timeout triggers escalation or auto-deny
- [ ] Escalation works correctly

---

## 4.2: Workflow Versioning

**Objective:** Implement versioning for safe deployments
**Estimated Time:** 30 minutes
**Prerequisites:** Lab 4.1 completed

**Step 1: Create Versioned Functions**
Create `src/inngest/functions/subscription-lifecycle.ts`:
```typescript
import { inngest } from '@/inngest/client';

// Version 1.0.0 - Basic subscription management
export const subscriptionLifecycleV1 = inngest.createFunction(
  {
    id: 'subscription-lifecycle-workflow',
    name: 'Subscription Lifecycle v1.0.0',
    version: '1.0.0',
    retries: 3,
  },
  { event: 'subscription/created' },
  async ({ event, step, logger }) => {
    const { subscriptionId, userId, planId } = event.data;

    logger.info('Processing subscription (v1)', { subscriptionId, planId });

    // Simple subscription creation
    const subscription = await step.run('create-subscription', async () => {
      await new Promise((resolve) => setTimeout(resolve, 500));
      return {
        id: subscriptionId,
        userId,
        planId,
        status: 'active',
        createdAt: new Date().toISOString(),
        version: '1.0.0',
      };
    });

    return subscription;
  }
);

// Version 2.0.0 - Enhanced with trial period
export const subscriptionLifecycleV2 = inngest.createFunction(
  {
    id: 'subscription-lifecycle-workflow',
    name: 'Subscription Lifecycle v2.0.0',
    version: '2.0.0',
    retries: 3,
  },
  { event: 'subscription/created' },
  async ({ event, step, logger }) => {
    const { subscriptionId, userId, planId } = event.data;

    logger.info('Processing subscription (v2)', { subscriptionId, planId });

    // Create subscription with trial
    const subscription = await step.run('create-subscription-v2', async () => {
      await new Promise((resolve) => setTimeout(resolve, 500));
      return {
        id: subscriptionId,
        userId,
        planId,
        status: 'trial',
        trialEndsAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString(),
        createdAt: new Date().toISOString(),
        version: '2.0.0',
      };
    });

    // Wait for trial to end
    const trialEnd = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
    await step.sleepUntil('wait-for-trial', trialEnd);

    // Convert to paid
    await step.run('convert-to-paid', async () => {
      await new Promise((resolve) => setTimeout(resolve, 500));
      return {
        id: subscriptionId,
        status: 'active',
        convertedAt: new Date().toISOString(),
      };
    });

    return subscription;
  }
);
```

**Step 2: Register Both Versions**
Update `src/app/api/inngest/route.ts`:
```typescript
import { 
  subscriptionLifecycleV1,
  subscriptionLifecycleV2,
} from '@/inngest/functions/subscription-lifecycle';

export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [
    subscriptionLifecycleV1,
    subscriptionLifecycleV2,
    // ... other functions
  ],
});
```

**Step 3: Test Both Versions**
```bash
# Trigger v1 (uses the same event name but different version)
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "subscription/created",
    "data": {
      "subscriptionId": "sub-v1-123",
      "userId": "user-456",
      "planId": "pro"
    }
  }'

# Trigger v2
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "subscription/created",
    "data": {
      "subscriptionId": "sub-v2-123",
      "userId": "user-456",
      "planId": "pro"
    }
  }'
```

### Verification Checklist
- [ ] Both versions run for the same event
- [ ] v1 completes without trial
- [ ] v2 includes trial period
- [ ] Running workflows are not interrupted

---

# Lab 5: Full-Stack Integration

## 5.1: Server Actions

**Objective:** Trigger workflows from React components
**Estimated Time:** 45 minutes
**Prerequisites:** Lab 4 completed

**Step 1: Create Server Action**
Create `src/lib/actions/workflow.actions.ts`:
```typescript
'use server';

import { inngest } from '@/inngest/client';
import { revalidatePath } from 'next/cache';
import { z } from 'zod';

const triggerSchema = z.object({
  workflowName: z.enum([
    'user/registered',
    'order/created',
    'campaign/triggered',
    'approval/requested',
  ]),
  data: z.record(z.any()),
  userId: z.string().uuid().optional(),
});

export async function triggerWorkflow(formData: FormData) {
  try {
    const rawData = {
      workflowName: formData.get('workflowName'),
      data: JSON.parse(formData.get('data') as string || '{}'),
      userId: formData.get('userId') || undefined,
    };

    const validated = triggerSchema.parse(rawData);

    const result = await inngest.send({
      name: validated.workflowName,
      data: validated.data,
      user: validated.userId ? { id: validated.userId } : undefined,
    });

    revalidatePath('/dashboard');

    return {
      success: true,
      runId: result.ids?.[0],
      message: 'Workflow triggered successfully',
    };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}
```

**Step 2: Create Trigger Form Component**
Create `src/app/dashboard/trigger/page.tsx`:
```typescript
'use client';

import { useActionState, useState } from 'react';
import { triggerWorkflow } from '@/lib/actions/workflow.actions';

const initialState = {
  success: false,
  error: null as string | null,
  message: null as string | null,
  runId: null as string | null,
};

export default function TriggerPage() {
  const [state, formAction, isPending] = useActionState(
    triggerWorkflow,
    initialState
  );

  const [eventData, setEventData] = useState('{\n  "userId": "user_123",\n  "email": "test@example.com"\n}');

  return (
    <div className="max-w-2xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">Trigger Workflow</h1>

      <form action={formAction} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Workflow
          </label>
          <select
            name="workflowName"
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500"
          >
            <option value="user/registered">User Registration</option>
            <option value="order/created">Order Created</option>
            <option value="campaign/triggered">Email Campaign</option>
            <option value="approval/requested">Approval Request</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Event Data (JSON)
          </label>
          <textarea
            name="data"
            value={eventData}
            onChange={(e) => setEventData(e.target.value)}
            rows={6}
            className="w-full px-3 py-2 border border-gray-300 rounded-md font-mono text-sm focus:ring-2 focus:ring-blue-500"
            spellCheck={false}
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            User ID (Optional)
          </label>
          <input
            type="text"
            name="userId"
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500"
            placeholder="user_123"
          />
        </div>

        <button
          type="submit"
          disabled={isPending}
          className="w-full px-4 py-2 bg-blue-600 text-white font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
        >
          {isPending ? (
            <span className="flex items-center justify-center gap-2">
              <span className="animate-spin">⟳</span>
              Triggering...
            </span>
          ) : (
            'Trigger Workflow'
          )}
        </button>
      </form>

      {state.success && (
        <div className="mt-4 p-4 bg-green-50 border border-green-200 rounded-md">
          <p className="text-green-700">{state.message}</p>
          <p className="text-sm text-gray-600 mt-1">Run ID: {state.runId}</p>
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

**Step 3: Test the Trigger Form**
1. Navigate to http://localhost:3000/dashboard/trigger
2. Select a workflow
3. Fill in the event data
4. Click "Trigger Workflow"
5. Check the Dev Server for the run

### Verification Checklist
- [ ] Trigger form loads correctly
- [ ] Form submission triggers workflow
- [ ] Success/error messages display
- [ ] Run appears in Dev Server

---

## 5.2: Real-Time Status Updates (SSE)

**Objective:** Display real-time workflow status in the UI
**Estimated Time:** 45 minutes
**Prerequisites:** Lab 5.1 completed

**Step 1: Create SSE Hook**
Create `src/lib/hooks/useSSE.ts`:
```typescript
'use client';

import { useState, useEffect, useCallback, useRef } from 'react';

interface SSEOptions {
  onMessage?: (data: any) => void;
  onError?: (error: Event) => void;
  onOpen?: () => void;
  onClose?: () => void;
  autoReconnect?: boolean;
  reconnectDelay?: number;
}

export function useSSE(url: string, options: SSEOptions = {}) {
  const {
    onMessage,
    onError,
    onOpen,
    onClose,
    autoReconnect = true,
    reconnectDelay = 3000,
  } = options;

  const [isConnected, setIsConnected] = useState(false);
  const [lastMessage, setLastMessage] = useState<any>(null);
  const [error, setError] = useState<Event | null>(null);
  const eventSourceRef = useRef<EventSource | null>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  const connect = useCallback(() => {
    if (eventSourceRef.current) {
      eventSourceRef.current.close();
    }

    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
    }

    try {
      const eventSource = new EventSource(url);
      eventSourceRef.current = eventSource;

      eventSource.onopen = () => {
        setIsConnected(true);
        setError(null);
        onOpen?.();
      };

      eventSource.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          setLastMessage(data);
          onMessage?.(data);
        } catch (parseError) {
          console.error('Failed to parse SSE message:', parseError);
        }
      };

      eventSource.onerror = (event) => {
        setError(event);
        onError?.(event);
        setIsConnected(false);

        if (autoReconnect) {
          if (reconnectTimeoutRef.current) {
            clearTimeout(reconnectTimeoutRef.current);
          }
          reconnectTimeoutRef.current = setTimeout(() => {
            connect();
          }, reconnectDelay);
        }
      };
    } catch (err) {
      setError(err as Event);
      setIsConnected(false);
    }
  }, [url, onMessage, onError, onOpen, onClose, autoReconnect, reconnectDelay]);

  const disconnect = useCallback(() => {
    if (eventSourceRef.current) {
      eventSourceRef.current.close();
      eventSourceRef.current = null;
    }
    if (reconnectTimeoutRef.current) {
      clearTimeout(reconnectTimeoutRef.current);
      reconnectTimeoutRef.current = null;
    }
    setIsConnected(false);
    onClose?.();
  }, [onClose]);

  useEffect(() => {
    connect();
    return () => disconnect();
  }, [connect, disconnect]);

  return {
    isConnected,
    lastMessage,
    error,
    connect,
    disconnect,
    reconnect: connect,
  };
}
```

**Step 2: Create Status Component**
Create `src/app/dashboard/components/WorkflowStatus.tsx`:
```typescript
'use client';

import { useSSE } from '@/lib/hooks/useSSE';
import { useState } from 'react';

interface WorkflowStatusProps {
  runId: string;
}

export function WorkflowStatus({ runId }: WorkflowStatusProps) {
  const [status, setStatus] = useState<{
    status: string;
    steps: any[];
    startedAt: string;
    duration: number;
  } | null>(null);

  const { isConnected } = useSSE(
    `/api/workflows/status/stream?runId=${runId}`,
    {
      onMessage: (data) => setStatus(data),
      onError: () => console.error('SSE connection error'),
    }
  );

  if (!status) {
    return (
      <div className="p-4 bg-gray-50 rounded-lg">
        <p className="text-gray-500">Waiting for status...</p>
      </div>
    );
  }

  const statusColors = {
    pending: 'bg-yellow-100 text-yellow-800',
    running: 'bg-blue-100 text-blue-800',
    completed: 'bg-green-100 text-green-800',
    failed: 'bg-red-100 text-red-800',
  };

  const statusIcons = {
    pending: '⏳',
    running: '🔄',
    completed: '✅',
    failed: '❌',
  };

  return (
    <div className="border border-gray-200 rounded-lg overflow-hidden">
      <div className="p-4 bg-white">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <span className="text-2xl">
              {statusIcons[status.status] || '⚪'}
            </span>
            <span className={`px-2 py-1 text-sm font-medium rounded-full ${statusColors[status.status]}`}>
              {status.status.toUpperCase()}
            </span>
            {isConnected ? (
              <span className="text-sm text-green-600">● Live</span>
            ) : (
              <span className="text-sm text-red-600">● Disconnected</span>
            )}
          </div>
        </div>

        {/* Progress bar */}
        <div className="mt-4">
          <div className="w-full bg-gray-200 rounded-full h-2">
            <div
              className="bg-blue-600 h-2 rounded-full transition-all duration-500"
              style={{
                width: `${getProgress(status)}%`,
              }}
            />
          </div>
        </div>

        {/* Steps */}
        {status.steps && status.steps.length > 0 && (
          <div className="mt-4 space-y-2">
            {status.steps.map((step, index) => (
              <div key={index} className="flex items-center justify-between text-sm">
                <div className="flex items-center gap-2">
                  <span className={
                    step.status === 'completed' ? 'text-green-600' :
                    step.status === 'running' ? 'text-blue-600' :
                    'text-gray-400'
                  }>
                    {step.status === 'completed' ? '✅' :
                     step.status === 'running' ? '🔄' :
                     '⏳'}
                  </span>
                  <span className={step.status === 'pending' ? 'text-gray-400' : ''}>
                    {step.name}
                  </span>
                </div>
                <span className="text-gray-500">
                  {step.duration ? `${(step.duration / 1000).toFixed(1)}s` : 'Waiting...'}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

function getProgress(status: any): number {
  if (status.status === 'completed') return 100;
  if (status.status === 'failed') return 0;
  if (!status.steps || status.steps.length === 0) return 0;

  const completed = status.steps.filter((s: any) => s.status === 'completed').length;
  return (completed / status.steps.length) * 100;
}
```

### Verification Checklist
- [ ] SSE connection established
- [ ] Status updates in real-time
- [ ] Progress bar shows progress
- [ ] Step details displayed

---

## 5.3: Optimistic Updates

**Objective:** Use useOptimistic for AI content generation
**Estimated Time:** 30 minutes
**Prerequisites:** Lab 5.2 completed

**Step 1: Create AI Content Dashboard**
Create `src/app/dashboard/ai-content/page.tsx`:
```typescript
'use client';

import { useActionState, useOptimistic, useState } from 'react';
import { generateAIContent } from '@/lib/actions/ai.actions';
import { WorkflowStatus } from '@/app/dashboard/components/WorkflowStatus';

const initialState = {
  content: '',
  error: null as string | null,
  runId: null as string | null,
};

export default function AIContentPage() {
  const [state, formAction, isPending] = useActionState(
    generateAIContent,
    initialState
  );

  const [optimisticContent, addOptimisticContent] = useOptimistic(
    state.content,
    (state, newContent: string) => newContent
  );

  const [prompt, setPrompt] = useState('');
  const [contentType, setContentType] = useState('blog-post');

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const formData = new FormData(e.currentTarget);

    // Optimistic update
    const promptText = formData.get('prompt') as string;
    const type = formData.get('contentType') as string;
    addOptimisticContent(`✨ Generating ${type} content for: "${promptText.substring(0, 50)}..."`);

    // Trigger workflow
    const result = await generateAIContent(formData);
    // State will be updated by useActionState
  };

  return (
    <div className="max-w-4xl mx-auto p-6">
      <h1 className="text-2xl font-bold mb-6">AI Content Generator</h1>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Prompt
          </label>
          <textarea
            name="prompt"
            rows={4}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500"
            placeholder="Describe the content you want to generate..."
            required
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Content Type
          </label>
          <select
            name="contentType"
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500"
          >
            <option value="blog-post">Blog Post</option>
            <option value="social-media">Social Media</option>
            <option value="email">Email Newsletter</option>
            <option value="product-description">Product Description</option>
          </select>
        </div>

        <button
          type="submit"
          disabled={isPending}
          className="w-full px-4 py-2 bg-blue-600 text-white font-medium rounded-md hover:bg-blue-700 disabled:opacity-50"
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
              ✨ Updating content optimistically...
            </div>
          )}
        </div>
      )}

      {state.runId && (
        <div className="mt-6">
          <h3 className="text-lg font-semibold mb-4">Generation Status</h3>
          <WorkflowStatus runId={state.runId} />
        </div>
      )}
    </div>
  );
}
```

**Step 2: Create AI Server Action**
Create `src/lib/actions/ai.actions.ts`:
```typescript
'use server';

import { inngest } from '@/inngest/client';
import { z } from 'zod';
import { revalidatePath } from 'next/cache';

const schema = z.object({
  prompt: z.string().min(10),
  contentType: z.enum(['blog-post', 'social-media', 'email', 'product-description']),
  userId: z.string().optional(),
});

export async function generateAIContent(prevState: any, formData: FormData) {
  try {
    const validated = schema.parse({
      prompt: formData.get('prompt'),
      contentType: formData.get('contentType'),
      userId: formData.get('userId'),
    });

    const generationId = `gen-${Date.now()}-${Math.random().toString(36).substring(7)}`;

    const result = await inngest.send({
      name: 'ai/content-generation-requested',
      data: {
        generationId,
        prompt: validated.prompt,
        contentType: validated.contentType,
        userId: validated.userId || 'anonymous',
      },
    });

    return {
      content: `✨ Generating ${validated.contentType} content for: "${validated.prompt.substring(0, 60)}..."`,
      error: null,
      runId: result.ids?.[0] || generationId,
    };
  } catch (error) {
    return {
      content: '',
      error: error instanceof Error ? error.message : 'Failed to generate content',
      runId: null,
    };
  }
}
```

### Verification Checklist
- [ ] Optimistic content appears immediately
- [ ] Content updates when generation completes
- [ ] Workflow status shows progress
- [ ] Error handling works correctly

---

# Lab 6: Production & Observability

## 6.1: Production Configuration

**Objective:** Configure production environment and health checks
**Estimated Time:** 30 minutes
**Prerequisites:** Lab 5 completed

**Step 1: Create Configuration**
Create `src/lib/config/index.ts`:
```typescript
import { z } from 'zod';

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  INNGEST_EVENT_KEY: z.string().min(1, 'INNGEST_EVENT_KEY is required'),
  INNGEST_SIGNING_KEY: z.string().min(1, 'INNGEST_SIGNING_KEY is required'),
  NEXT_PUBLIC_APP_URL: z.string().url('NEXT_PUBLIC_APP_URL must be a valid URL'),
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),
  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be at least 32 characters'),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
});

function validateEnv() {
  try {
    return envSchema.parse(process.env);
  } catch (error) {
    if (error instanceof z.ZodError) {
      const issues = error.issues
        .map(issue => `${issue.path.join('.')}: ${issue.message}`)
        .join('\n');
      throw new Error(`Environment validation failed:\n${issues}`);
    }
    throw error;
  }
}

export const config = validateEnv();
export const isProduction = config.NODE_ENV === 'production';
```

**Step 2: Create Health Check**
Create `src/app/api/health/route.ts`:
```typescript
import { NextResponse } from 'next/server';

export async function GET() {
  try {
    const startTime = Date.now();

    // Check database
    const dbHealthy = await checkDatabase();

    // Check Inngest
    const inngestHealthy = await checkInngest();

    const status = dbHealthy && inngestHealthy ? 'healthy' : 'degraded';

    return NextResponse.json({
      status,
      timestamp: new Date().toISOString(),
      version: process.env.npm_package_version || 'unknown',
      services: {
        database: { healthy: dbHealthy },
        inngest: { healthy: inngestHealthy },
      },
      uptime: (Date.now() - startTime) / 1000,
    }, {
      status: status === 'healthy' ? 200 : 503,
    });
  } catch (error) {
    return NextResponse.json({
      status: 'unhealthy',
      timestamp: new Date().toISOString(),
      error: error.message,
    }, { status: 503 });
  }
}

async function checkDatabase(): Promise<boolean> {
  try {
    // In a real app: await prisma.$queryRaw`SELECT 1`
    // For now, simulate
    await new Promise((resolve) => setTimeout(resolve, 100));
    return true;
  } catch {
    return false;
  }
}

async function checkInngest(): Promise<boolean> {
  try {
    // In a real app: check Inngest API
    // const response = await fetch('https://api.inngest.com/health');
    // return response.ok;
    return true;
  } catch {
    return false;
  }
}
```

**Step 3: Test Health Check**
```bash
curl -X GET http://localhost:3000/api/health
```

### Verification Checklist
- [ ] Configuration validates environment variables
- [ ] Health check returns status
- [ ] Services are checked
- [ ] Health check responds with appropriate status code

---

## 6.2: Production Client

**Objective:** Configure production-ready Inngest client
**Estimated Time:** 30 minutes
**Prerequisites:** Lab 6.1 completed

**Step 1: Create Production Client**
Update `src/inngest/client.ts`:
```typescript
import { Inngest, InngestMiddleware } from 'inngest';
import { config, isProduction } from '@/lib/config';

// Metrics middleware
const metricsMiddleware = new InngestMiddleware({
  name: 'Metrics Collection',
  init: () => ({
    onFunctionRun: ({ fn, ctx }) => {
      const startTime = Date.now();

      return {
        onFunctionComplete: ({ result }) => {
          const duration = Date.now() - startTime;

          console.log('Function metrics:', {
            functionId: fn.id,
            runId: ctx.runId,
            duration,
            success: result.success,
            attempts: ctx.attempt,
          });
        },
      };
    },
  }),
});

// Error handling middleware
const errorMiddleware = new InngestMiddleware({
  name: 'Error Handling',
  init: () => ({
    onFunctionRun: ({ fn, ctx }) => ({
      onStepRun: ({ step }) => ({
        transformOutput: ({ output }) => {
          if (output instanceof Error) {
            // Log error with context
            console.error('Step failed:', {
              functionId: fn.id,
              stepName: step.name,
              runId: ctx.runId,
              error: output.message,
              stack: output.stack,
            });
          }
          return { output };
        },
      }),
    }),
  }),
});

export const inngest = new Inngest({
  id: 'workflowhub',
  name: 'WorkflowHub',
  eventKey: config.INNGEST_EVENT_KEY,
  signingKey: config.INNGEST_SIGNING_KEY,

  // Add middleware in production
  middleware: isProduction
    ? [metricsMiddleware, errorMiddleware]
    : [metricsMiddleware],

  // Production retry strategy
  retryFunction: (attempt: number) => ({
    delay: Math.min(Math.pow(2, attempt) * 1000, 60000),
    maxAttempts: isProduction ? 5 : 3,
  }),

  // Production logger
  logger: isProduction
    ? {
        info: (msg: string) => console.log(`[INFO] ${msg}`),
        warn: (msg: string) => console.warn(`[WARN] ${msg}`),
        error: (msg: string) => console.error(`[ERROR] ${msg}`),
        debug: () => {},
      }
    : {
        info: console.info,
        warn: console.warn,
        error: console.error,
        debug: console.debug,
      },
});
```

### Verification Checklist
- [ ] Client uses environment variables
- [ ] Middleware added
- [ ] Production retry strategy configured
- [ ] Logger configured

---

## 6.3: Deployment Configuration

**Objective:** Configure deployment for Vercel
**Estimated Time:** 30 minutes
**Prerequisites:** Lab 6.2 completed

**Step 1: Create Vercel Configuration**
Create `vercel.json`:
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
    "DATABASE_URL": "@database-url",
    "JWT_SECRET": "@jwt-secret"
  },
  "functions": {
    "api/inngest/**/*.ts": {
      "maxDuration": 60,
      "memory": 1024
    }
  }
}
```

**Step 2: Create .env.production**
```bash
NODE_ENV=production
INNGEST_EVENT_KEY=ev_prod_xxxxxxxxxxxxxxxx
INNGEST_SIGNING_KEY=sign_prod_xxxxxxxxxxxxxxxx
NEXT_PUBLIC_APP_URL=https://workflowhub.com
DATABASE_URL=postgresql://user:pass@host:5432/database
JWT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
LOG_LEVEL=info
```

**Step 3: Deployment Commands**
```bash
# Deploy to Vercel
vercel --prod

# Or deploy to preview
vercel
```

### Verification Checklist
- [ ] Vercel configuration file created
- [ ] Environment variables configured
- [ ] Function settings configured
- [ ] Deployment command works

---

# Lab 7: AI Workflows (Bonus)

## 7.1: AI Content Generation

**Objective:** Build an AI content generation workflow
**Estimated Time:** 45 minutes
**Prerequisites:** Lab 6 completed

**Step 1: Create AI Workflow**
Create `src/inngest/functions/ai-generation.ts`:
```typescript
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Simulate AI generation
const generateContent = async (prompt: string, type: string) => {
  await new Promise((resolve) => setTimeout(resolve, 2000));

  // Simulate different content types
  let content = '';
  switch (type) {
    case 'blog-post':
      content = `# ${prompt.substring(0, 40)}\n\n## Introduction\nThis blog post explores ${prompt.substring(0, 30)}...\n\n## Key Points\n- Point 1\n- Point 2\n- Point 3\n\n## Conclusion\n${prompt.substring(0, 20)} is an important topic.`;
      break;
    case 'social-media':
      content = `🚀 ${prompt.substring(0, 50)}\n\n💡 ${prompt.substring(0, 30)}\n\n#innovation #tech #trending`;
      break;
    case 'email':
      content = `Subject: ${prompt.substring(0, 40)}\n\nDear Team,\n\n${prompt.substring(0, 60)}...\n\nBest regards,\nAI Assistant`;
      break;
    default:
      content = `Generated content for: ${prompt}`;
  }

  return {
    content,
    wordCount: content.split(' ').length,
    tokens: Math.floor(content.length / 4),
  };
};

const AIRequestSchema = z.object({
  generationId: z.string().uuid(),
  prompt: z.string().min(10),
  contentType: z.enum(['blog-post', 'social-media', 'email', 'product-description']),
  userId: z.string().uuid(),
});

export const aiContentWorkflow = inngest.createFunction(
  {
    id: 'ai-content-workflow',
    name: 'AI Content Generation',
    retries: 3,
    rateLimit: {
      limit: 10,
      period: '1m',
    },
  },
  { event: 'ai/content-generation-requested' },
  async ({ event, step, logger }) => {
    const validated = AIRequestSchema.parse(event.data);
    const { generationId, prompt, contentType, userId } = validated;

    logger.info('Starting AI content generation', {
      generationId,
      contentType,
      promptLength: prompt.length,
    });

    // Step 1: Enhance prompt
    const enhanced = await step.run('enhance-prompt', async () => {
      await new Promise((resolve) => setTimeout(resolve, 200));
      return {
        systemPrompt: `Generate a ${contentType} based on the following prompt.`,
        userPrompt: prompt,
      };
    });

    // Step 2: Generate content
    const generation = await step.run('generate-content', async () => {
      return await generateContent(prompt, contentType);
    });

    // Step 3: Analyze quality
    const analysis = await step.run('analyze-quality', async () => {
      const quality = {
        wordCount: generation.wordCount,
        score: Math.min(100, (generation.wordCount / 100) * 20 + 60),
        hasMarkdown: /[#*`]/g.test(generation.content),
        hasList: /[•\-*]\s/g.test(generation.content),
      };
      return quality;
    });

    // Step 4: Store content
    const storage = await step.run('store-content', async () => {
      await new Promise((resolve) => setTimeout(resolve, 300));
      return {
        stored: true,
        contentId: `content-${generationId}`,
        storedAt: new Date().toISOString(),
      };
    });

    // Step 5: Notify user
    await step.run('notify-user', async () => {
      await new Promise((resolve) => setTimeout(resolve, 200));
      return {
        notified: true,
        notifiedAt: new Date().toISOString(),
      };
    });

    return {
      success: true,
      generationId,
      contentType,
      content: generation.content,
      wordCount: generation.wordCount,
      qualityScore: analysis.score,
      storage: storage.contentId,
      completedAt: new Date().toISOString(),
    };
  }
);
```

**Step 2: Register the Function**
Update `src/app/api/inngest/route.ts`:
```typescript
import { aiContentWorkflow } from '@/inngest/functions/ai-generation';
// Add to functions array
```

**Step 3: Trigger AI Generation**
```bash
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "ai/content-generation-requested",
    "data": {
      "generationId": "123e4567-e89b-12d3-a456-426614174000",
      "prompt": "Write a blog post about serverless computing",
      "contentType": "blog-post",
      "userId": "223e4567-e89b-12d3-a456-426614174000"
    }
  }'
```

### Challenge
- Add a human review loop for low-quality content
- Implement multi-agent orchestration
- Add RAG (Retrieval-Augmented Generation) support

### Verification Checklist
- [ ] AI content generation workflow works
- [ ] Content is generated based on prompt
- [ ] Quality analysis is performed
- [ ] Content is stored and user notified

---

# Appendix: Common Commands

## Development Commands
```bash
# Start Next.js dev server
pnpm dev

# Start Inngest Dev Server
inngest dev -u http://localhost:3000/api/inngest

# Trigger event with curl
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{"name":"event/name","data":{...}}'

# Install dependencies
pnpm install

# Run type checking
pnpm tsc --noEmit
```

## Deployment Commands
```bash
# Vercel
vercel --prod

# AWS Lambda
serverless deploy

# Docker
docker build -t workflowhub .
docker run -p 3000:3000 workflowhub
```

## Troubleshooting Commands
```bash
# Check Node.js version
node --version

# Check Inngest CLI version
inngest --version

# Check environment variables
env | grep INNGEST

# Clear npm cache
npm cache clean --force

# Kill process on port 3000
lsof -i :3000
kill -9 <PID>
```

---

# Lab Completion Checklist

## Lab 0: Environment Setup
- [ ] Node.js 20+ installed
- [ ] Package manager installed
- [ ] Inngest CLI installed
- [ ] Project created

## Lab 1: Foundations
- [ ] Inngest client created
- [ ] API route configured
- [ ] User registration workflow built
- [ ] Retry behavior tested

## Lab 2: State Management
- [ ] Idempotent payment step built
- [ ] Saga pattern implemented
- [ ] Reminder system built

## Lab 3: High-Performance Patterns
- [ ] Bulk email with fan-out/fan-in built
- [ ] Concurrency configured
- [ ] Rate limiting configured

## Lab 4: Long-Running Workflows
- [ ] Approval workflow built
- [ ] Workflow versioning implemented

## Lab 5: Full-Stack Integration
- [ ] Server Actions created
- [ ] SSE implemented
- [ ] Optimistic updates implemented

## Lab 6: Production
- [ ] Configuration validated
- [ ] Health check created
- [ ] Production client configured
- [ ] Deployment configured

## Lab 7: AI Workflows (Bonus)
- [ ] AI content workflow built
- [ ] AI generation tested

---

*End of Lab Book*
