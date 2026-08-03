# Mastering Inngest: Building Reliable Serverless Workflows with Durable Execution

## Design Resilient Event-Driven Systems Without Managing Queues, Workers, or Workflow Infrastructure

---

# Part 1: Foundations — Thinking in Events and Durable Execution

## Building Your First Production-Grade Workflow

---

## Module 1.1: Understanding Event-Driven Architecture

### The Target

In this module, we'll establish the foundational mental model for event-driven architecture and understand why it's superior to traditional request/response patterns for modern applications.

### The Concept

Think of your application as a busy restaurant kitchen:

**Traditional Request/Response (REST API)** is like a customer walking up to the counter and waiting while their entire meal is prepared from scratch. The cook can't start the next order until this one is completely finished. If the customer wants a complex meal, everyone behind them waits.

**Event-Driven Architecture** is like a well-organized kitchen where:

- **The Customer** places an order (publishes an event)
- **The Expediter** receives the order and breaks it into tasks (event router)
- **The Grill Cook** hears "fire steak" and starts cooking (event consumer)
- **The Saute Cook** hears "fire vegetables" and starts cooking (another consumer)
- **The Plater** assembles everything when ready (event consumer)
- Everyone works asynchronously based on events they care about

In our application, events are simply messages that say "something happened." They contain just enough information to describe what happened and who it happened to.

### Event Flow Architecture

Here's what a typical event flow looks like in our system:

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

### The Implementation

Let's create our project structure and install the necessary dependencies.

#### Step 1: Project Setup

Open your terminal and run the following commands:

```bash
# Create a new Next.js project with TypeScript and Tailwind
pnpm create next-app@latest workflowhub --typescript --tailwind --app --eslint --no-src-dir

# Navigate into the project
cd workflowhub

# Install Inngest dependencies
pnpm add inngest inngest/next

# Install additional utilities
pnpm add zod uuid
pnpm add -D @types/uuid

# Verify installation
pnpm list --depth=0
```

**Understanding these dependencies:**

- `inngest`: The core SDK for creating workflows
- `inngest/next`: Next.js integration for Inngest
- `zod`: Runtime type validation (ensures events have correct data)
- `uuid`: Generate unique IDs for entities

#### Step 2: Environment Setup

Create a `.env.local` file in your project root:

```bash
# .env.local - Environment variables for local development

# Inngest Configuration
# You'll get these from app.inngest.com after creating an account
INNGEST_EVENT_KEY="ev_..." # For signing events
INNGEST_SIGNING_KEY="sign_..." # For verifying events

# Application URL (used by Inngest sync endpoint)
NEXT_PUBLIC_APP_URL="http://localhost:3000"

# Email Service (we'll use Resend)
RESEND_API_KEY="re_..." # Get from resend.com

# Database (we'll use SQLite with Prisma)
DATABASE_URL="file:./dev.db"

# Optional: Enable Inngest Dev Server auto-start
INNGEST_DEV="true"
```

#### Step 3: Initialize Inngest Client

Create the Inngest client that all your functions will use:

```typescript
// src/inngest/client.ts
import { Inngest } from 'inngest';

// Create the Inngest client with configuration
export const inngest = new Inngest({
  id: 'workflowhub', // Unique identifier for your app
  name: 'WorkflowHub', // Display name in Inngest dashboard
  
  // Event signing for security (prevents spoofing)
  eventKey: process.env.INNGEST_EVENT_KEY,
  
  // Retry configuration for all functions
  retryFunction: (attempt: number) => ({
    // Exponential backoff: 1s, 2s, 4s, 8s, 16s, 30s, 60s...
    delay: Math.min(Math.pow(2, attempt) * 1000, 60000),
    maxAttempts: 5, // Retry up to 5 times
  }),
  
  // Optional: Enable logging in development
  logger: process.env.NODE_ENV === 'development' ? console : undefined,
});
```

#### Step 4: Set Up the Inngest API Route

Create the API route that Inngest will use to receive events and register functions:

```typescript
// src/app/api/inngest/route.ts
import { serve } from 'inngest/next';
import { inngest } from '@/inngest/client';

// Import your functions (we'll create these next)
import { userRegistrationWorkflow } from '@/inngest/functions/user-registration';
import { orderCreatedWorkflow } from '@/inngest/functions/order-created';

// Create the Inngest server handler
export const { GET, POST, PUT } = serve({
  client: inngest,
  functions: [
    // Register all your functions here
    userRegistrationWorkflow,
    orderCreatedWorkflow,
  ],
  
  // Optional: Customize streaming behavior
  streaming: {
    interval: 1000, // How often to send updates (ms)
    heartbeat: 10000, // Keep-alive interval
  },
});

// Disable body parser for Inngest (handles raw JSON)
export const config = {
  api: {
    bodyParser: false,
  },
};
```

#### Step 5: Create Your First Function

Now let's create a workflow that responds to user registration events:

```typescript
// src/inngest/functions/user-registration.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Define the event schema with Zod for type safety
const UserRegistrationEventSchema = z.object({
  userId: z.string().uuid(), // Validate UUID format
  email: z.string().email(), // Validate email format
  name: z.string().min(2).max(100),
  plan: z.enum(['free', 'pro', 'enterprise']),
});

// Export the workflow definition
export const userRegistrationWorkflow = inngest.createFunction(
  {
    // Unique ID for this function
    id: 'user-registration-workflow',
    
    // Function metadata
    name: 'User Registration Workflow',
    description: 'Process new user registrations with email, profile creation, and CRM sync',
    
    // Retry configuration specific to this function
    retries: 3, // Override default retry count
    retryDelay: '5s', // Fixed delay between retries
    
    // Optional: Rate limiting
    rateLimit: {
      limit: 100, // Max 100 registrations per
      period: '1m', // minute
    },
    
    // Optional: Concurrency control
    concurrency: {
      limit: 50, // Max 50 registrations at a time
      scope: 'fn', // Apply to all executions of this function
    },
  },
  // The event that triggers this function
  { event: 'user/registered' },
  // The workflow execution handler
  async ({ event, step, logger }) => {
    // Validate the event data
    const validatedData = UserRegistrationEventSchema.parse(event.data);
    const { userId, email, name, plan } = validatedData;
    
    logger.info('Processing user registration', { userId, email, plan });
    
    // Step 1: Send welcome email
    const emailResult = await step.run('send-welcome-email', async () => {
      // In a real app, you'd use a service like Resend, SendGrid, etc.
      // For now, we'll simulate the email send
      logger.info('Sending welcome email', { email });
      
      // Simulate API call with potential failure
      await new Promise((resolve) => setTimeout(resolve, 1000));
      
      // Return the email ID for tracking
      return {
        messageId: `email-${Date.now()}-${Math.random().toString(36).substring(7)}`,
        sentAt: new Date().toISOString(),
      };
    });
    
    // Step 2: Create user profile in database
    const profile = await step.run('create-user-profile', async () => {
      // In a real app, you'd interact with your database
      // For now, we'll simulate the database operation
      logger.info('Creating user profile', { userId, name });
      
      // Simulate database latency
      await new Promise((resolve) => setTimeout(resolve, 500));
      
      // Return the profile data
      return {
        id: userId,
        name,
        email,
        plan,
        createdAt: new Date().toISOString(),
        profileUrl: `https://workflowhub.com/users/${userId}`,
      };
    });
    
    // Step 3: Sync with CRM
    const crmResult = await step.run('sync-with-crm', async () => {
      // In a real app, you'd sync with Salesforce, HubSpot, etc.
      logger.info('Syncing with CRM', { userId, email });
      
      // Simulate CRM API call
      await new Promise((resolve) => setTimeout(resolve, 700));
      
      // Return CRM integration data
      return {
        crmId: `crm-${userId.slice(0, 8)}`,
        syncedAt: new Date().toISOString(),
        status: 'synced',
      };
    });
    
    // Step 4: Optional - Initialize tenant for enterprise users
    let tenantResult = null;
    if (plan === 'enterprise') {
      tenantResult = await step.run('initialize-tenant', async () => {
        // In a real app, you'd set up a tenant in your database
        logger.info('Initializing enterprise tenant', { userId });
        
        // Simulate tenant creation
        await new Promise((resolve) => setTimeout(resolve, 1200));
        
        return {
          tenantId: `tenant-${userId.slice(0, 8)}`,
          status: 'initialized',
          features: ['sso', 'audit-logs', 'custom-domains'],
        };
      });
    }
    
    // Return the complete workflow result
    const result = {
      userId,
      email,
      processed: true,
      emailSent: emailResult.messageId,
      profileCreated: profile.id,
      crmSynced: crmResult.crmId,
      tenant: tenantResult,
      processedAt: new Date().toISOString(),
    };
    
    logger.info('Registration workflow completed', { userId, result });
    
    return result;
  }
);
```

#### Step 6: Create a Second Function (Order Processing)

Let's create another workflow for order processing to demonstrate event-driven coordination:

```typescript
// src/inngest/functions/order-created.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Event schema for order creation
const OrderCreatedEventSchema = z.object({
  orderId: z.string().uuid(),
  userId: z.string().uuid(),
  total: z.number().positive(),
  items: z.array(
    z.object({
      productId: z.string(),
      quantity: z.number().int().positive(),
      price: z.number().positive(),
    })
  ),
  paymentMethod: z.enum(['credit-card', 'paypal', 'crypto']),
});

export const orderCreatedWorkflow = inngest.createFunction(
  {
    id: 'order-created-workflow',
    name: 'Order Processing Workflow',
    description: 'Process new orders with payment, inventory, and shipping',
    
    // Custom retry strategy
    retries: 3,
    retryDelay: '5s',
  },
  { event: 'order/created' },
  async ({ event, step, logger }) => {
    // Validate the incoming data
    const validatedOrder = OrderCreatedEventSchema.parse(event.data);
    const { orderId, userId, total, items, paymentMethod } = validatedOrder;
    
    logger.info('Processing order', { orderId, userId, total, itemCount: items.length });
    
    // Step 1: Process payment
    const payment = await step.run('process-payment', async () => {
      logger.info('Processing payment', { 
        orderId, 
        total, 
        method: paymentMethod 
      });
      
      // Simulate payment processing
      await new Promise((resolve) => setTimeout(resolve, 1500));
      
      // Simulate successful payment
      return {
        transactionId: `txn-${Date.now()}-${Math.random().toString(36).substring(7)}`,
        amount: total,
        method: paymentMethod,
        status: 'completed',
        processedAt: new Date().toISOString(),
      };
    });
    
    // Step 2: Update inventory for each item
    const inventoryUpdates = await step.run('update-inventory', async () => {
      logger.info('Updating inventory', { 
        orderId, 
        items: items.length 
      });
      
      // In a real app, you'd interact with your inventory system
      // We'll simulate updating each item
      const updates = items.map((item: { productId: string; quantity: number }) => ({
        productId: item.productId,
        quantityDeducted: item.quantity,
        status: 'reserved',
        updatedAt: new Date().toISOString(),
      }));
      
      await new Promise((resolve) => setTimeout(resolve, 800));
      
      return {
        updates,
        success: true,
      };
    });
    
    // Step 3: Schedule shipping
    const shipping = await step.run('schedule-shipping', async () => {
      logger.info('Scheduling shipping', { orderId });
      
      // Simulate shipping API call
      await new Promise((resolve) => setTimeout(resolve, 500));
      
      // Estimate shipping date (2-5 days from now)
      const shipDate = new Date();
      shipDate.setDate(shipDate.getDate() + 3 + Math.floor(Math.random() * 3));
      
      return {
        trackingId: `TRK-${Date.now().toString(36).toUpperCase()}`,
        estimatedShipDate: shipDate.toISOString().split('T')[0],
        carrier: ['UPS', 'FedEx', 'USPS'][Math.floor(Math.random() * 3)],
        status: 'scheduled',
      };
    });
    
    // Step 4: Send order confirmation
    await step.run('send-order-confirmation', async () => {
      logger.info('Sending order confirmation', { orderId, userId });
      
      // Simulate sending confirmation email
      await new Promise((resolve) => setTimeout(resolve, 400));
      
      return {
        emailId: `email-${Date.now()}`,
        sentAt: new Date().toISOString(),
      };
    });
    
    // Return comprehensive order result
    return {
      orderId,
      userId,
      total,
      payment: {
        transactionId: payment.transactionId,
        status: payment.status,
      },
      inventory: inventoryUpdates.updates,
      shipping: {
        trackingId: shipping.trackingId,
        carrier: shipping.carrier,
        estimatedShipDate: shipping.estimatedShipDate,
        status: shipping.status,
      },
      processedAt: new Date().toISOString(),
    };
  }
);
```

---

## Module 1.2: Running and Testing Locally

### The Concept

Inngest provides a powerful development server that runs locally and simulates the production environment. It gives you:

1. **Real-time Execution Dashboard**: See exactly what's happening in your workflows
2. **Event Logging**: Every event is logged with full payload
3. **Step-by-step Tracing**: Watch each step execute with its results
4. **Retry Simulation**: Test how your workflows handle failures
5. **No Cloud Dependency**: Everything runs locally

Think of it like having a full kitchen command center where you can watch every order being prepared, see each ingredient being added, and instantly spot if something goes wrong.

### The Implementation

#### Step 1: Start the Development Server

Open your terminal and run:

```bash
# Start the Next.js development server
pnpm dev
```

You should see output similar to:
```
✓ Ready in 2.3s
- Local:        http://localhost:3000
- Inngest Dev:  http://localhost:3000/api/inngest
- Environments: .env.local
```

The Inngest Dev Server automatically starts alongside Next.js (thanks to our `INNGEST_DEV="true"` setting).

#### Step 2: Access the Dev Dashboard

Open your browser and navigate to:

```
http://localhost:3000/api/inngest
```

You'll see the Inngest development dashboard showing:
- Registered functions
- Recent events
- Active runs
- Execution history

#### Step 3: Send Test Events

Let's test our workflows by sending events. In a new terminal window, use curl:

```bash
# Test the user registration workflow
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

# You should see: {"ids":["run_xxxxxxxxxxxx"],"status":"success"}
```

Now test the order workflow:

```bash
# Test the order creation workflow
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "order/created",
    "data": {
      "orderId": "123e4567-e89b-12d3-a456-426614174001",
      "userId": "123e4567-e89b-12d3-a456-426614174000",
      "total": 149.99,
      "items": [
        {
          "productId": "prod_123",
          "quantity": 2,
          "price": 49.99
        },
        {
          "productId": "prod_456",
          "quantity": 1,
          "price": 50.01
        }
      ],
      "paymentMethod": "credit-card"
    }
  }'
```

#### Step 4: Monitor Execution

Switch back to your browser and refresh the Inngest dashboard. You should see:

1. **Recent Events**: Both events listed with timestamps
2. **Running Workflows**: Your workflows executing
3. **Step-by-Step Progress**: Each step completing
4. **Execution Details**: Click on any run to see:
   - The event that triggered it
   - Each step's input and output
   - Duration of each step
   - Any errors or retries

#### Step 5: Test Error Handling

Let's simulate a failure to see retry behavior. For this test, we'll create a helper file:

```typescript
// src/inngest/helpers/simulate-failure.ts
export const simulateFailure = (failRate: number = 0.3) => {
  if (Math.random() < failRate) {
    throw new Error('Simulated failure for testing retry behavior');
  }
  return { success: true };
};
```

Now update your user registration workflow to use this helper:

```typescript
// src/inngest/functions/user-registration.ts (partial update)
import { simulateFailure } from '@/inngest/helpers/simulate-failure';

// ... inside the step.run for email:
const emailResult = await step.run('send-welcome-email', async () => {
  // Simulate failures for testing
  simulateFailure(0.5); // 50% chance of failure
  
  logger.info('Sending welcome email', { email });
  // ... rest of code
});
```

Now run the event again and watch what happens:

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

In the dashboard, you should see:
1. The step fails and retries
2. Exponential backoff delays between retries
3. Eventually succeeds if the random failure passes

---

## Module 1.3: Understanding the Dev Server Internals

### The Concept

To truly master Inngest, you need to understand what's happening under the hood. The Dev Server provides a complete local simulation of the production environment.

#### How It Works

```
┌──────────────────────────────────────────────────────────────┐
│                    Inngest Dev Server                       │
├──────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Receives events via POST /api/inngest                   │
│  2. Validates event structure                              │
│  3. Routes to matching functions                           │
│  4. Starts new run for each event                          │
│  5. Executes steps sequentially                            │
│  6. Saves state after each step                           │
│  7. Handles retries and failures                           │
│  8. Updates UI in real-time                               │
│                                                             │
└──────────────────────────────────────────────────────────────┘
```

### The Implementation

Let's add logging to see what's happening:

```typescript
// src/inngest/middleware/logging.ts
import { InngestMiddleware } from 'inngest';

// This middleware logs every step of execution
export const loggingMiddleware = new InngestMiddleware({
  name: 'Logging Middleware',
  init: ({ client }) => {
    return {
      onFunctionRun: ({ fn, ctx }) => {
        // Called when a function starts
        console.log(`[${fn.id}] Starting run for event:`, ctx.event.name);
        
        return {
          transformInput: () => {
            // Modify input before passing to function
            console.log(`[${fn.id}] Transforming input`);
          },
          onStepRun: ({ step, run }) => {
            // Called before each step executes
            console.log(`[${fn.id}] Starting step: ${step.name}`);
            
            return {
              transformOutput: ({ output }) => {
                // Called after step completes
                console.log(`[${fn.id}] Step completed: ${step.name}`);
                return { output };
              },
            };
          },
          onFunctionComplete: ({ result }) => {
            console.log(`[${fn.id}] Function completed:`, 
              result.success ? 'Success' : 'Failed');
          },
        };
      },
    };
  },
});
```

Now register the middleware in your client:

```typescript
// src/inngest/client.ts (updated)
import { Inngest } from 'inngest';
import { loggingMiddleware } from '@/inngest/middleware/logging';

export const inngest = new Inngest({
  id: 'workflowhub',
  name: 'WorkflowHub',
  eventKey: process.env.INNGEST_EVENT_KEY,
  
  // Register middleware
  middleware: [loggingMiddleware],
  
  retryFunction: (attempt: number) => ({
    delay: Math.min(Math.pow(2, attempt) * 1000, 60000),
    maxAttempts: 5,
  }),
  
  logger: process.env.NODE_ENV === 'development' ? console : undefined,
});
```

Now when you run events, you'll see detailed logs in your terminal:

```
[user-registration-workflow] Starting run for event: user/registered
[user-registration-workflow] Starting step: send-welcome-email
[user-registration-workflow] Step completed: send-welcome-email
[user-registration-workflow] Starting step: create-user-profile
[user-registration-workflow] Step completed: create-user-profile
...
```

---

## Module 1.4: Building the Event Dashboard UI

### The Concept

To make our workflows more tangible, let's build a simple UI that:
1. Shows recent events
2. Displays workflow status
3. Provides a form to trigger events manually

This is like creating a "command center" where you can see all activity and trigger new processes.

### The Implementation

#### Step 1: Create the Dashboard Page

```typescript
// src/app/dashboard/page.tsx
'use client';

import { useState, useEffect } from 'react';

// Type definitions
interface Event {
  id: string;
  name: string;
  data: any;
  timestamp: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
}

interface Workflow {
  id: string;
  name: string;
  status: 'idle' | 'running' | 'completed' | 'failed';
  lastRun?: string;
  totalRuns: number;
}

export default function DashboardPage() {
  const [events, setEvents] = useState<Event[]>([]);
  const [workflows, setWorkflows] = useState<Workflow[]>([]);
  const [loading, setLoading] = useState(true);
  
  // Simulated events (in a real app, you'd fetch from API)
  useEffect(() => {
    const mockEvents: Event[] = [
      {
        id: 'evt_1',
        name: 'user/registered',
        data: { userId: 'user_123', email: 'john@example.com' },
        timestamp: new Date().toISOString(),
        status: 'completed',
      },
      {
        id: 'evt_2',
        name: 'order/created',
        data: { orderId: 'ord_456', total: 149.99 },
        timestamp: new Date(Date.now() - 5000).toISOString(),
        status: 'processing',
      },
    ];
    
    const mockWorkflows: Workflow[] = [
      {
        id: 'wf_1',
        name: 'User Registration',
        status: 'completed',
        lastRun: new Date().toISOString(),
        totalRuns: 42,
      },
      {
        id: 'wf_2',
        name: 'Order Processing',
        status: 'running',
        lastRun: new Date(Date.now() - 10000).toISOString(),
        totalRuns: 17,
      },
    ];
    
    setEvents(mockEvents);
    setWorkflows(mockWorkflows);
    setLoading(false);
  }, []);
  
  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>
    );
  }
  
  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">
          Workflow Dashboard
        </h1>
        
        {/* Workflow Status Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-medium text-gray-900">Total Workflows</h3>
              <span className="text-2xl font-bold text-blue-600">2</span>
            </div>
            <p className="text-sm text-gray-500 mt-2">Active workflows in system</p>
          </div>
          
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-medium text-gray-900">Today's Events</h3>
              <span className="text-2xl font-bold text-green-600">24</span>
            </div>
            <p className="text-sm text-gray-500 mt-2">Events processed today</p>
          </div>
          
          <div className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between">
              <h3 className="text-lg font-medium text-gray-900">Success Rate</h3>
              <span className="text-2xl font-bold text-purple-600">98.5%</span>
            </div>
            <p className="text-sm text-gray-500 mt-2">Last 30 days</p>
          </div>
        </div>
        
        {/* Workflows List */}
        <div className="bg-white rounded-lg shadow mb-8">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-xl font-semibold text-gray-900">Active Workflows</h2>
          </div>
          <div className="divide-y divide-gray-200">
            {workflows.map((workflow) => (
              <div key={workflow.id} className="px-6 py-4 flex items-center justify-between">
                <div>
                  <h4 className="text-sm font-medium text-gray-900">
                    {workflow.name}
                  </h4>
                  <p className="text-sm text-gray-500">
                    Total runs: {workflow.totalRuns}
                    {workflow.lastRun && (
                      <>
                        {' '}· Last run: {new Date(workflow.lastRun).toLocaleString()}
                      </>
                    )}
                  </p>
                </div>
                <div className="flex items-center gap-3">
                  <span className={`px-2 py-1 text-xs rounded-full ${
                    workflow.status === 'running'
                      ? 'bg-yellow-100 text-yellow-800'
                      : workflow.status === 'completed'
                      ? 'bg-green-100 text-green-800'
                      : workflow.status === 'failed'
                      ? 'bg-red-100 text-red-800'
                      : 'bg-gray-100 text-gray-800'
                  }`}>
                    {workflow.status}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
        
        {/* Recent Events */}
        <div className="bg-white rounded-lg shadow">
          <div className="px-6 py-4 border-b border-gray-200">
            <h2 className="text-xl font-semibold text-gray-900">Recent Events</h2>
          </div>
          <div className="divide-y divide-gray-200">
            {events.map((event) => (
              <div key={event.id} className="px-6 py-4">
                <div className="flex items-center justify-between">
                  <div>
                    <code className="text-sm bg-gray-100 px-2 py-1 rounded">
                      {event.name}
                    </code>
                    <p className="text-sm text-gray-500 mt-1">
                      {new Date(event.timestamp).toLocaleString()}
                    </p>
                  </div>
                  <div className="flex items-center gap-3">
                    <span className={`px-2 py-1 text-xs rounded-full ${
                      event.status === 'completed'
                        ? 'bg-green-100 text-green-800'
                        : event.status === 'processing'
                        ? 'bg-yellow-100 text-yellow-800'
                        : event.status === 'failed'
                        ? 'bg-red-100 text-red-800'
                        : 'bg-gray-100 text-gray-800'
                    }`}>
                      {event.status}
                    </span>
                    <button className="text-sm text-blue-600 hover:text-blue-800">
                      View Details
                    </button>
                  </div>
                </div>
                {event.data && (
                  <details className="mt-2">
                    <summary className="text-xs text-gray-500 cursor-pointer">
                      Show event data
                    </summary>
                    <pre className="mt-2 p-2 bg-gray-50 rounded text-xs overflow-auto">
                      {JSON.stringify(event.data, null, 2)}
                    </pre>
                  </details>
                )}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
```

#### Step 2: Create an Event Trigger Form

```typescript
// src/app/dashboard/trigger/page.tsx
'use client';

import { useState } from 'react';

export default function TriggerEventPage() {
  const [eventName, setEventName] = useState('user/registered');
  const [eventData, setEventData] = useState('{\n  "userId": "user_123",\n  "email": "test@example.com"\n}');
  const [sending, setSending] = useState(false);
  const [response, setResponse] = useState<any>(null);
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSending(true);
    setResponse(null);
    
    try {
      const payload = {
        name: eventName,
        data: JSON.parse(eventData),
      };
      
      const response = await fetch('/api/inngest', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
      });
      
      const result = await response.json();
      setResponse(result);
    } catch (error) {
      setResponse({ error: error.message });
    } finally {
      setSending(false);
    }
  };
  
  const presetEvents = [
    { label: 'User Registration', value: 'user/registered', 
      data: '{\n  "userId": "user_123",\n  "email": "test@example.com",\n  "name": "Test User",\n  "plan": "pro"\n}' },
    { label: 'Order Created', value: 'order/created', 
      data: '{\n  "orderId": "ord_456",\n  "userId": "user_123",\n  "total": 149.99,\n  "items": [\n    { "productId": "prod_1", "quantity": 2, "price": 49.99 },\n    { "productId": "prod_2", "quantity": 1, "price": 50.01 }\n  ],\n  "paymentMethod": "credit-card"\n}' },
  ];
  
  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-3xl mx-auto">
        <div className="bg-white rounded-lg shadow p-6">
          <h1 className="text-2xl font-bold text-gray-900 mb-6">
            Trigger Event
          </h1>
          
          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Event Type Presets */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Quick Presets
              </label>
              <div className="flex flex-wrap gap-2">
                {presetEvents.map((preset) => (
                  <button
                    key={preset.value}
                    type="button"
                    onClick={() => {
                      setEventName(preset.value);
                      setEventData(preset.data);
                    }}
                    className="px-3 py-2 text-sm bg-gray-100 hover:bg-gray-200 rounded-md transition-colors"
                  >
                    {preset.label}
                  </button>
                ))}
              </div>
            </div>
            
            {/* Event Name */}
            <div>
              <label htmlFor="eventName" className="block text-sm font-medium text-gray-700 mb-2">
                Event Name
              </label>
              <input
                type="text"
                id="eventName"
                value={eventName}
                onChange={(e) => setEventName(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>
            
            {/* Event Data */}
            <div>
              <label htmlFor="eventData" className="block text-sm font-medium text-gray-700 mb-2">
                Event Data (JSON)
              </label>
              <textarea
                id="eventData"
                value={eventData}
                onChange={(e) => setEventData(e.target.value)}
                rows={8}
                className="w-full px-3 py-2 border border-gray-300 rounded-md font-mono text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
                spellCheck="false"
              />
            </div>
            
            {/* Submit Button */}
            <button
              type="submit"
              disabled={sending}
              className="w-full px-4 py-2 bg-blue-600 text-white font-medium rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {sending ? (
                <span className="flex items-center justify-center gap-2">
                  <span className="animate-spin">⟳</span>
                  Sending...
                </span>
              ) : (
                'Trigger Event'
              )}
            </button>
          </form>
          
          {/* Response */}
          {response && (
            <div className="mt-6 p-4 bg-gray-50 rounded-md">
              <h3 className="text-sm font-medium text-gray-700 mb-2">
                Response
              </h3>
              <pre className="text-sm overflow-auto">
                {JSON.stringify(response, null, 2)}
              </pre>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
```

---

## Verification: Testing Your Complete Setup

### Step 1: Start Everything

```bash
# Terminal 1: Start the development server
pnpm dev

# Terminal 2: Monitor logs (optional)
tail -f .next/server/app/api/inngest/route.js.log
```

### Step 2: Trigger Events via UI

1. Open `http://localhost:3000/dashboard/trigger`
2. Select "User Registration" preset
3. Click "Trigger Event"
4. Check the response
5. Navigate to `http://localhost:3000/dashboard` to see the event

### Step 3: Trigger Events via API

```bash
# Trigger user registration
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

# Expected response:
# {"ids":["run_xxxxxxxxxxxxxxxx"],"status":"success"}

# Check the dashboard at http://localhost:3000/dashboard
```

### Step 4: Verify Workflow Execution

In the Inngest Dev Server dashboard:
1. Look for the run ID from the response
2. Click on it to see execution details
3. Verify all steps completed successfully
4. Check the output matches the event data

### Step 5: Test Error Handling

```bash
# Send an invalid event (missing required fields)
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "user/registered",
    "data": {
      "userId": "not-a-uuid",
      "email": "invalid-email"
    }
  }'

# Expected: Validation error in logs
# The function should fail with a clear error message
```

---

## Troubleshooting Common Issues

### Issue: Dev Server Not Starting
```
Error: Could not start Inngest dev server
```

**Solution:**
```bash
# Check your environment variables
echo $INNGEST_DEV

# Set it explicitly
export INNGEST_DEV=true

# Or add to .env.local
echo "INNGEST_DEV=true" >> .env.local
```

### Issue: Events Not Triggering Workflows
```
No matching function found for event
```

**Solution:**
1. Verify event name matches exactly: `user/registered`
2. Check function is registered in `src/app/api/inngest/route.ts`
3. Restart dev server: `pnpm dev`

### Issue: Type Errors
```
Property 'userId' does not exist on type 'never'
```

**Solution:**
```bash
# Check your event schema matches the data
# Install TypeScript types if needed
pnpm add -D @types/node
```

---

## What You've Accomplished

In Part 1, you've built:

1. ✅ A complete Next.js project with Inngest integration
2. ✅ Two production-ready durable workflows (user registration and order processing)
3. ✅ Event-driven architecture with type safety and validation
4. ✅ Local development environment with the Inngest Dev Server
5. ✅ Dashboard UI for monitoring and triggering events
6. ✅ Error handling and retry mechanisms
7. ✅ Logging middleware for debugging

You've learned:
- How event-driven architecture differs from request/response
- How durable execution automatically handles failures
- How to structure workflows with steps
- How to test and debug workflows locally
- How to build a monitoring dashboard

---

## Deep Dive: Understanding Inngest Internals

### How Step Execution Works

When you call `step.run()`, Inngest does several things:

1. **Checks for existing result**: If this step ran before, return the cached result
2. **Executes the function**: Runs your code
3. **Saves the result**: Stores it in durable storage
4. **Advances the workflow**: Moves to the next step

This is why your code appears to run multiple times during retries, but side effects (like sending emails) only happen once.

### State Management

Inngest manages state automatically using a journal-like mechanism:

```
Step 1: send-welcome-email
  → Input: { email: 'test@example.com' }
  → Output: { messageId: 'email_123', sentAt: '2024-01-01T00:00:00Z' }
  → State: ✓ COMPLETED

Step 2: create-user-profile
  → Input: { userId: 'user_123', name: 'Test User' }
  → Output: { id: 'user_123', name: 'Test User', createdAt: '2024-01-01T00:00:01Z' }
  → State: ✓ COMPLETED

Step 3: sync-with-crm
  → Input: { userId: 'user_123', email: 'test@example.com' }
  → Output: { crmId: 'crm_123', status: 'synced' }
  → State: ✓ COMPLETED
```

Each step's result is stored, so if Step 3 fails, only Step 3 retries.

### The Orchestration Loop

1. **Event Received** → Create a new run
2. **Load State** → Resume from last checkpoint
3. **Execute Next Step** → Run user code
4. **Save State** → Checkpoint progress
5. **Repeat** → Until all steps complete

This loop continues until the workflow succeeds or exhausts retries.

---

## Next Steps

In **Part 2**, we'll dive deeper into durable execution with:
- Advanced state management between steps
- Custom error handling and compensating actions
- Scheduled workflows with `step.sleep()`
- Parallel execution patterns
- Real-world failure scenarios and recovery

---

## References

- [Inngest Documentation](https://www.inngest.com/docs)
- [Inngest GitHub](https://github.com/inngest/inngest)
- [Event-Driven Architecture Patterns](https://www.inngest.com/docs/learn/event-driven-architecture)
- [Durable Execution Explained](https://www.inngest.com/docs/learn/durable-execution)
- [Next.js App Router](https://nextjs.org/docs/app)
