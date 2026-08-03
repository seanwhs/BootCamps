# Primer 2: The Anatomy of a Durable Function

**Estimated Time**: 15 Minutes
**Prerequisites**: Completion of Primer 1, or basic understanding of Inngest concepts. Node.js and TypeScript/JavaScript knowledge assumed.

---

## 1. Understanding the Structure

Now that you've written your first "Hello, World!" durable function, let's dissect it to understand exactly what's happening under the hood. A durable function in Inngest is more than just a function—it's a declarative description of a workflow that can survive failures and be resumed at any point.

Here's the complete anatomy of a durable function:

```typescript
const myWorkflow = inngest.createFunction(
  {
    id: "my-workflow",
    // Configuration options
  },
  {
    event: "my/event", // Trigger
  },
  async ({ event, step, logger }) => {
    // Workflow logic with durable steps
    const result = await step.run("step-name", async () => {
      // Business logic here
    });
    return result;
  }
);
```

Let's break this down component by component.

---

## 2. The Function Declaration: `inngest.createFunction()`

The `createFunction()` method is the entry point for defining any durable workflow. It takes three arguments:

### A. Configuration Object (First Argument)

This object defines the identity and behavior of your function:

```typescript
{
  id: "my-workflow",              // Unique identifier (required)
  name: "My Workflow",            // Display name in dashboard (optional)
  retries: 3,                     // Number of retry attempts (default: 3)
  retryDelay: "5s",               // Delay between retries (default: "5s")
  concurrency: {                  // Concurrency limits (optional)
    limit: 10,
    scope: "fn",
  },
  rateLimit: {                    // Rate limiting (optional)
    limit: 100,
    period: "1m",
  },
  idempotency: {                  // Idempotency configuration (optional)
    key: "data.orderId",
    ttl: "30d",
  },
}
```

**Key Configuration Properties:**

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `id` | `string` | Unique identifier. Use snake-case or kebab-case. | Required |
| `name` | `string` | Display name in the Inngest dashboard. | `id` value |
| `retries` | `number` | Maximum number of retry attempts for failed steps. | `3` |
| `retryDelay` | `string` | Initial delay between retries (uses exponential backoff). | `"5s"` |
| `concurrency` | `object` | Limit concurrent executions. | Unlimited |
| `rateLimit` | `object` | Limit execution rate. | Unlimited |
| `idempotency` | `object` | Prevent duplicate processing. | Disabled |

### B. Trigger Definition (Second Argument)

This defines what starts your workflow. The most common trigger is an event:

```typescript
// Simple event trigger
{ event: "user/registered" }

// Event with schema validation
import { eventType } from "inngest";
const userRegistered = eventType("user/registered", {
  schema: z.object({
    userId: z.string().uuid(),
    email: z.string().email(),
  }),
});
{ triggers: [userRegistered] }

// Cron/scheduled trigger
import { cron } from "inngest";
{ triggers: [cron("0 0 * * *")] } // Midnight daily

// Multiple triggers
{
  triggers: [
    { event: "user/registered" },
    { event: "user/updated" },
    cron("0 0 * * *"), // Also run daily
  ]
}

// Trigger with condition
{
  event: "order/placed",
  if: "event.data.total > 1000", // Only process large orders
}
```

### C. Handler Function (Third Argument)

This is the actual workflow logic. It receives a context object with powerful tools:

```typescript
async ({ event, step, logger, attempt, runId }) => {
  // `event`: The event that triggered this run
  // `step`: Contains durable step methods (.run(), .sleep(), .waitForEvent())
  // `logger`: Structured logger (info, warn, error, debug)
  // `attempt`: Current retry attempt number
  // `runId`: Unique identifier for this execution
}
```

---

## 3. The Handler Context: What's Available

### A. The `event` Object

The event that triggered your function contains:

```typescript
{
  name: "user/registered",      // Event name
  id: "evt_123456789",          // Unique event ID
  data: {                       // User-provided event payload
    userId: "user_123",
    email: "test@example.com"
  },
  ts: 1700000000000,           // Timestamp (milliseconds)
  user: { id: "user_123" },    // Optional user context
}
```

### B. The `step` Object

The `step` object is your primary tool for building durable workflows. It contains:

| Method | Description | Usage Example |
|--------|-------------|---------------|
| `step.run()` | Execute a durable step | `step.run("payment", async () => {...})` |
| `step.sleep()` | Pause execution for a duration | `step.sleep("wait", 5000)` |
| `step.sleepUntil()` | Pause until a specific time | `step.sleepUntil("wait", new Date("2024-12-31"))` |
| `step.waitForEvent()` | Pause and wait for an external event | `step.waitForEvent("wait", { event: "order/approved", timeout: "24h" })` |
| `step.sendEvent()` | Send events from within a step | `step.sendEvent("notify", { name: "email/sent", data: {...} })` |
| `step.fetch()` | Make durable HTTP requests | `step.fetch("api-call", { url: "https://api.example.com" })` |
| `step.ai.infer()` | Make durable AI calls | `step.ai.infer("ai-call", { model: step.ai.models.openai({ model: "gpt-4" }) })` |

### C. The `logger` Object

Inngest provides a structured logger that automatically includes context:

```typescript
logger.info("Processing order", {
  orderId: event.data.orderId,
  amount: event.data.amount,
  attempt: attempt,
});

logger.warn("Payment method declined", {
  orderId: event.data.orderId,
  paymentMethod: event.data.paymentMethod,
});

logger.error("Failed to process order", {
  orderId: event.data.orderId,
  error: error.message,
  stack: error.stack,
});
```

---

## 4. The Core Step Types

### A. `step.run()` - Basic Durable Step

The `step.run()` method is the fundamental building block of any durable function:

```typescript
const result = await step.run("fetch-user-data", async () => {
  // This code is automatically retried on failure
  const response = await fetch("https://api.example.com/user");
  return response.json();
});
```

**How it works:**

1. **First execution**: The step runs your code.
2. **Success**: The result is saved to durable storage.
3. **Failure**: The step is retried automatically.
4. **Retry**: The step is re-executed from the beginning.

**Important**: A `step.run()` block is a transaction. If it succeeds, its result is persisted. If it fails, the entire block is retried. This makes it safe to perform multiple operations inside a single step as long as they're atomic.

### B. `step.sleep()` - Pausing Execution

Sleep is useful for delaying actions or implementing rate limiting:

```typescript
// Sleep for a specific duration (milliseconds)
await step.sleep("wait-5-seconds", 5000);

// Sleep using a duration string
await step.sleep("wait-1-minute", "1m");

// Sleep for a calculated time
const waitTime = scheduledDate.getTime() - Date.now();
await step.sleep("wait-for-schedule", waitTime);
```

**Important**: During a sleep, the workflow state is saved. If the server restarts, the workflow resumes from the sleep, not from the beginning. This makes sleep operations durable and reliable.

### C. `step.waitForEvent()` - Pausing for External Events

The `waitForEvent` method enables human-in-the-loop and cross-service coordination:

```typescript
try {
  const decision = await step.waitForEvent("wait-for-approval", {
    event: "approval/decision",
    timeout: "24h",
    match: (data) => data.approvalId === event.data.approvalId,
  });
  
  if (decision.data.approved) {
    // Execute the approved action
    await step.run("execute-approval", async () => {
      await finalizeApproval(event.data.approvalId);
    });
  } else {
    // Handle rejection
    await step.run("handle-rejection", async () => {
      await notifyRequester(event.data.requesterId, "Request denied");
    });
  }
} catch {
  // Timeout - no decision made
  await step.run("escalate-approval", async () => {
    await escalateToManager(event.data.approvalId);
  });
}
```

---

## 5. Return Values and Output

Your function should return a meaningful result that can be observed in the dashboard:

```typescript
const orderResult = await step.run("place-order", async () => {
  // Simulate placing an order
  return {
    orderId: `ORD-${Date.now()}`,
    status: "placed",
    timestamp: new Date().toISOString(),
  };
});

// The final function return value
return {
  success: true,
  orderId: orderResult.orderId,
  processedAt: new Date().toISOString(),
};
```

**Best Practices for Return Values:**

1. **Be Descriptive**: Include useful metadata (IDs, timestamps, statuses).
2. **Keep It Small**: Don't return huge objects. Store large data externally.
3. **Include Errors**: If the workflow failed, include the error information.

---

## 6. Complete Example: Order Processing Workflow

Here's a complete example that demonstrates all the components we've discussed:

```typescript
import { Inngest, eventType, cron } from "inngest";
import { z } from "zod";

// Define the event schema
const orderPlaced = eventType("order/placed", {
  schema: z.object({
    orderId: z.string().uuid(),
    customerId: z.string().uuid(),
    total: z.number().positive(),
    items: z.array(z.object({
      productId: z.string(),
      quantity: z.number().int().positive(),
      price: z.number().positive(),
    })),
  }),
});

// Create the client
const inngest = new Inngest({
  id: "my-ecommerce-app",
  name: "My E-Commerce App",
});

// Define the workflow
export const orderProcessingWorkflow = inngest.createFunction(
  {
    id: "order-processing-workflow",
    name: "Order Processing Workflow",
    retries: 3,
    retryDelay: "5s",
    concurrency: {
      limit: 100,
      scope: "fn",
    },
    idempotency: {
      key: "data.orderId",
      ttl: "30d",
    },
  },
  { triggers: [orderPlaced] },
  async ({ event, step, logger, attempt }) => {
    const { orderId, customerId, total, items } = event.data;

    logger.info("Starting order processing", {
      orderId,
      customerId,
      total,
      itemCount: items.length,
      attempt,
    });

    // Step 1: Validate the order
    const validation = await step.run("validate-order", async () => {
      // Check stock availability for each item
      for (const item of items) {
        const stock = await checkStock(item.productId);
        if (stock < item.quantity) {
          throw new Error(`Insufficient stock for product: ${item.productId}`);
        }
      }
      return { valid: true, validatedAt: new Date().toISOString() };
    });

    // Step 2: Process payment
    const payment = await step.run("process-payment", async () => {
      // Use idempotency to prevent double charges
      const idempotencyKey = `payment-${orderId}`;
      const existing = await getPayment(idempotencyKey);
      if (existing) return existing;

      const result = await chargePayment(customerId, total);
      await storePayment(idempotencyKey, result);
      return result;
    });

    // Step 3: Update inventory
    await step.run("update-inventory", async () => {
      for (const item of items) {
        await deductStock(item.productId, item.quantity);
      }
    });

    // Step 4: Schedule shipping (async, non-blocking)
    const shipping = await step.run("schedule-shipping", async () => {
      return await scheduleShipment(orderId, items);
    });

    // Step 5: Send confirmation (non-critical)
    try {
      await step.run("send-confirmation", async () => {
        await sendEmail(customerId, `Order ${orderId} confirmed`);
      });
    } catch (error) {
      // Log but don't fail the workflow
      logger.warn("Confirmation email failed", {
        orderId,
        error: error.message,
      });
    }

    // Step 6: Return final result
    const result = {
      success: true,
      orderId,
      customerId,
      total,
      paymentId: payment.transactionId,
      shippingId: shipping.trackingId,
      processedAt: new Date().toISOString(),
    };

    logger.info("Order processed successfully", result);
    return result;
  }
);

// Helper functions (implementation details)
async function checkStock(productId: string): Promise<number> {
  // Check stock in database
  return 10;
}

async function chargePayment(customerId: string, total: number) {
  // Process payment
  return { transactionId: `txn-${Date.now()}` };
}

async function storePayment(idempotencyKey: string, result: any) {
  // Store payment result
}

async function deductStock(productId: string, quantity: number) {
  // Update inventory
}

async function scheduleShipment(orderId: string, items: any[]) {
  return { trackingId: `TRK-${Date.now()}` };
}

async function sendEmail(customerId: string, message: string) {
  // Send email
}
```

---

## 7. Summary: The Anatomy at a Glance

```
inngest.createFunction(
  // 1. Configuration
  {
    id: "my-workflow",                // Unique identifier
    name: "My Workflow",               // Display name
    retries: 3,                        // Retry attempts
    retryDelay: "5s",                  // Retry delay
    concurrency: { limit: 10 },        // Concurrency control
    rateLimit: { limit: 100 },         // Rate limiting
    idempotency: { key: "data.id" },   // Duplicate prevention
  },
  
  // 2. Trigger
  {
    event: "my/event",                 // Event trigger
    // OR cron("0 0 * * *")            // Cron trigger
    // OR multiple triggers
  },
  
  // 3. Handler
  async ({ event, step, logger }) => {
    // Durable steps
    const result = await step.run("step-1", async () => {
      // Business logic
    });
    
    await step.sleep("wait", 5000);
    
    const decision = await step.waitForEvent("wait", {
      event: "decision/made",
      timeout: "24h",
    });
    
    // Final result
    return { success: true };
  }
);
```

---

## Next Steps

You now understand the complete anatomy of a durable function. In the next primer, we'll explore advanced step patterns, error handling, and building multi-step workflows.
