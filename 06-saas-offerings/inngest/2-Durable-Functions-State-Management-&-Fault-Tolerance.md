# Mastering Inngest: Building Reliable Serverless Workflows with Durable Execution

## Design Resilient Event-Driven Systems Without Managing Queues, Workers, or Workflow Infrastructure

---

# Part 2: Durable Functions, State Management & Fault Tolerance

## Building Workflows That Survive Crashes, Retries, and Deployments

---

## Module 2.1: Understanding Durable Execution Deep Dive

### The Target

In this module, we'll master the inner workings of durable execution—understanding how Inngest manages state, handles failures, and ensures exactly-once execution of workflow steps.

### The Concept

Think of durable execution like a **time-traveling debugger** for your workflows:

Imagine you're writing a complex document with autosave. If your computer crashes:
- Without autosave: You lose everything and start over
- With autosave: You resume exactly where you left off

Durable execution works the same way. After each step completes, Inngest "autosaves" the workflow state. If anything fails, the workflow "time-travels" back to the last successful step and continues from there.

Here's what happens during a workflow execution:

```
Time →  [Step 1] → [SAVE] → [Step 2] → [SAVE] → [Step 3] → [SAVE]
                    ↓         ↓                    ↓         ↓
              Checkpoint   Checkpoint          Checkpoint   Checkpoint
                    ↓         ↓                    ↓         ↓
              ┌─────────────────────────────────────────────────┐
              │           Durable State Storage                │
              │  • Step 1: Completed                          │
              │  • Step 2: Completed                          │
              │  • Step 3: In Progress                        │
              └─────────────────────────────────────────────────┘
```

If Step 3 fails and retries, it doesn't re-run Steps 1 and 2—their results are already saved.

### The Implementation: Enhanced Client Configuration

Let's start by enhancing our Inngest client with better observability and configuration:

```typescript
// src/inngest/client.ts
import { Inngest, InngestMiddleware } from 'inngest';
import { z } from 'zod';

// Create a middleware for tracking step execution
export const stepTrackingMiddleware = new InngestMiddleware({
  name: 'Step Tracking',
  init: ({ client }) => {
    return {
      onFunctionRun: ({ fn, ctx }) => {
        // Track start time for performance monitoring
        const startTime = Date.now();
        const stepDurations: Record<string, number> = {};
        
        return {
          onStepRun: ({ step, run }) => {
            // Called before each step runs
            const stepStart = Date.now();
            
            return {
              transformOutput: ({ output }) => {
                // Called after step completes
                const duration = Date.now() - stepStart;
                stepDurations[step.name] = duration;
                
                // Log step duration
                console.log(`[${fn.id}] Step "${step.name}" took ${duration}ms`);
                
                return { output };
              },
            };
          },
          onFunctionComplete: ({ result }) => {
            const totalDuration = Date.now() - startTime;
            console.log(`[${fn.id}] Total duration: ${totalDuration}ms`);
            console.log(`[${fn.id}] Step durations:`, stepDurations);
          },
        };
      },
    };
  },
});

// Create the enhanced Inngest client
export const inngest = new Inngest({
  id: 'workflowhub',
  name: 'WorkflowHub',
  eventKey: process.env.INNGEST_EVENT_KEY,
  
  // Register middlewares
  middleware: [stepTrackingMiddleware],
  
  // Custom retry function with exponential backoff and jitter
  retryFunction: (attempt: number) => {
    // Exponential backoff with jitter to prevent thundering herd
    const baseDelay = Math.min(Math.pow(2, attempt) * 1000, 60000);
    const jitter = Math.random() * 1000; // Add randomness to spread retries
    return {
      delay: baseDelay + jitter,
      maxAttempts: 5,
    };
  },
  
  // Logger for debugging
  logger: process.env.NODE_ENV === 'development' 
    ? {
        debug: console.debug,
        info: console.info,
        warn: console.warn,
        error: console.error,
      }
    : undefined,
});
```

---

## Module 2.2: Advanced State Management

### The Target

Learn how to pass complex data between workflow steps, manage state transformations, and handle large datasets efficiently.

### The Concept

State management in durable execution is like passing a **relay baton** between runners:

1. **Runner 1** (Step 1) runs with the baton
2. **Runner 1** passes the baton to **Runner 2** (returns data)
3. **Runner 2** runs with the baton + previous data
4. And so on...

Each step receives the accumulated state and adds its own contribution. Inngest automatically persists this state between steps.

### The Implementation: Invoice Generation Workflow

Let's build a complete invoice generation workflow that demonstrates complex state management:

```typescript
// src/inngest/functions/invoice-generation.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Define schemas for each step
const InvoiceCreatedEventSchema = z.object({
  orderId: z.string().uuid(),
  userId: z.string().uuid(),
  items: z.array(
    z.object({
      id: z.string(),
      name: z.string(),
      quantity: z.number().int().positive(),
      unitPrice: z.number().positive(),
    })
  ),
  billingAddress: z.object({
    name: z.string(),
    street: z.string(),
    city: z.string(),
    state: z.string(),
    postalCode: z.string(),
    country: z.string(),
  }),
});

// Define the workflow
export const invoiceGenerationWorkflow = inngest.createFunction(
  {
    id: 'invoice-generation-workflow',
    name: 'Invoice Generation Pipeline',
    description: 'Generate, format, and deliver invoices with comprehensive state management',
    
    // Retry configuration
    retries: 3,
    retryDelay: '30s', // Longer delay for invoice generation
    
    // Rate limit to prevent abuse
    rateLimit: {
      limit: 50,
      period: '1m',
    },
  },
  { event: 'invoice/generate' },
  async ({ event, step, logger }) => {
    // Step 1: Validate and parse the event
    const validatedData = InvoiceCreatedEventSchema.parse(event.data);
    const { orderId, userId, items, billingAddress } = validatedData;
    
    logger.info('Starting invoice generation', { orderId, userId });
    
    // Step 2: Calculate invoice totals
    const totals = await step.run('calculate-totals', async () => {
      logger.info('Calculating invoice totals', { orderId });
      
      // Calculate subtotal
      const subtotal = items.reduce((sum, item) => {
        return sum + (item.quantity * item.unitPrice);
      }, 0);
      
      // Calculate tax (10% for demonstration)
      const taxRate = 0.10;
      const tax = Math.round(subtotal * taxRate * 100) / 100;
      
      // Calculate shipping (free over $100)
      const shipping = subtotal > 100 ? 0 : 5.99;
      
      // Calculate total
      const total = Math.round((subtotal + tax + shipping) * 100) / 100;
      
      // Return comprehensive totals
      return {
        subtotal,
        tax,
        taxRate,
        shipping,
        total,
        currency: 'USD',
        itemCount: items.length,
        lineItems: items.map(item => ({
          ...item,
          lineTotal: Math.round(item.quantity * item.unitPrice * 100) / 100,
        })),
      };
    });
    
    // Step 3: Generate the invoice PDF (simulated)
    const pdfGeneration = await step.run('generate-invoice-pdf', async () => {
      logger.info('Generating invoice PDF', { orderId, total: totals.total });
      
      // In a real app, you'd use a library like PDFKit, Puppeteer, or a service like Docmosis
      // For now, we'll simulate PDF generation
      await new Promise((resolve) => setTimeout(resolve, 2000));
      
      // Simulate PDF generation result
      const invoiceNumber = `INV-${new Date().getFullYear()}-${String(Math.floor(Math.random() * 10000)).padStart(4, '0')}`;
      
      return {
        invoiceNumber,
        pdfUrl: `https://storage.workflowhub.com/invoices/${invoiceNumber}.pdf`,
        generatedAt: new Date().toISOString(),
        fileSize: `${Math.floor(100 + Math.random() * 400)}KB`,
        pages: 1,
      };
    });
    
    // Step 4: Format for email delivery
    const emailContent = await step.run('format-email-content', async () => {
      logger.info('Formatting email content', { orderId, invoiceNumber: pdfGeneration.invoiceNumber });
      
      // Build HTML email content
      const itemsHtml = totals.lineItems
        .map(item => `
          <tr>
            <td>${item.name}</td>
            <td>${item.quantity}</td>
            <td>$${item.unitPrice.toFixed(2)}</td>
            <td>$${item.lineTotal.toFixed(2)}</td>
          </tr>
        `)
        .join('');
      
      const emailHtml = `
        <h1>Invoice ${pdfGeneration.invoiceNumber}</h1>
        <p>Thank you for your order!</p>
        
        <h2>Order Details</h2>
        <p>Order ID: ${orderId}</p>
        <p>Date: ${new Date().toISOString().split('T')[0]}</p>
        
        <h2>Items</h2>
        <table border="1" cellpadding="5">
          <tr>
            <th>Item</th>
            <th>Quantity</th>
            <th>Unit Price</th>
            <th>Total</th>
          </tr>
          ${itemsHtml}
          <tr>
            <td colspan="3"><strong>Subtotal</strong></td>
            <td><strong>$${totals.subtotal.toFixed(2)}</strong></td>
          </tr>
          <tr>
            <td colspan="3"><strong>Tax (${(totals.taxRate * 100).toFixed(0)}%)</strong></td>
            <td><strong>$${totals.tax.toFixed(2)}</strong></td>
          </tr>
          <tr>
            <td colspan="3"><strong>Shipping</strong></td>
            <td><strong>$${totals.shipping.toFixed(2)}</strong></td>
          </tr>
          <tr>
            <td colspan="3"><strong>Total</strong></td>
            <td><strong>$${totals.total.toFixed(2)}</strong></td>
          </tr>
        </table>
        
        <h2>Billing Address</h2>
        <p>
          ${billingAddress.name}<br>
          ${billingAddress.street}<br>
          ${billingAddress.city}, ${billingAddress.state} ${billingAddress.postalCode}<br>
          ${billingAddress.country}
        </p>
        
        <p><a href="${pdfGeneration.pdfUrl}">Download PDF Invoice</a></p>
        <p>If you have any questions, please contact our support team.</p>
      `;
      
      // Return email content
      return {
        subject: `Invoice ${pdfGeneration.invoiceNumber} for Order ${orderId}`,
        html: emailHtml,
        text: `
          Invoice ${pdfGeneration.invoiceNumber}
          
          Total: $${totals.total.toFixed(2)}
          Date: ${new Date().toISOString().split('T')[0]}
          
          Download PDF: ${pdfGeneration.pdfUrl}
        `,
        invoiceNumber: pdfGeneration.invoiceNumber,
      };
    });
    
    // Step 5: Send the invoice via email (simulated)
    const emailDelivery = await step.run('send-invoice-email', async () => {
      logger.info('Sending invoice email', { 
        orderId, 
        invoiceNumber: pdfGeneration.invoiceNumber 
      });
      
      // In a real app, you'd use an email service
      await new Promise((resolve) => setTimeout(resolve, 1000));
      
      return {
        messageId: `email-${Date.now()}`,
        sentAt: new Date().toISOString(),
        delivered: true,
        provider: 'Resend',
      };
    });
    
    // Step 6: Store invoice record in database (simulated)
    const invoiceRecord = await step.run('store-invoice-record', async () => {
      logger.info('Storing invoice record', { 
        orderId, 
        invoiceNumber: pdfGeneration.invoiceNumber 
      });
      
      // Simulate database insert
      await new Promise((resolve) => setTimeout(resolve, 500));
      
      return {
        id: `inv-${Date.now()}`,
        invoiceNumber: pdfGeneration.invoiceNumber,
        orderId,
        userId,
        total: totals.total,
        pdfUrl: pdfGeneration.pdfUrl,
        status: 'sent',
        createdAt: new Date().toISOString(),
      };
    });
    
    // Return the complete result with all state
    const result = {
      success: true,
      invoice: {
        number: pdfGeneration.invoiceNumber,
        total: totals.total,
        currency: totals.currency,
        generatedAt: pdfGeneration.generatedAt,
        pdfUrl: pdfGeneration.pdfUrl,
      },
      order: {
        id: orderId,
        itemCount: totals.itemCount,
        subtotal: totals.subtotal,
        tax: totals.tax,
        shipping: totals.shipping,
      },
      email: {
        sent: emailDelivery.delivered,
        messageId: emailDelivery.messageId,
        sentAt: emailDelivery.sentAt,
      },
      record: invoiceRecord,
      processedAt: new Date().toISOString(),
    };
    
    logger.info('Invoice generation completed successfully', {
      invoiceNumber: pdfGeneration.invoiceNumber,
      orderId,
    });
    
    return result;
  }
);
```

---

## Module 2.3: Error Handling and Retry Strategies

### The Target

Master the art of handling failures in durable workflows, implementing custom retry strategies, and building compensating actions for partial failures.

### The Concept

Error handling in durable execution is like **insurance for your workflows**:

1. **Prevention**: You design steps to be idempotent (safe to retry)
2. **Detection**: You catch and categorize errors
3. **Recovery**: You retry with appropriate strategies
4. **Compensation**: You undo partial work if needed
5. **Escalation**: You alert humans if automation fails

Think of building a safety net where the workflow can always recover gracefully, no matter what fails.

### The Implementation: Payment Retry Workflow with Compensating Actions

Let's build a sophisticated payment processing workflow that handles failures gracefully:

```typescript
// src/inngest/functions/payment-retry.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Define payment event schema
const PaymentInitiatedEventSchema = z.object({
  paymentId: z.string().uuid(),
  userId: z.string().uuid(),
  amount: z.number().positive(),
  currency: z.string().length(3),
  paymentMethod: z.enum(['card', 'bank-transfer', 'paypal']),
  description: z.string().optional(),
  retryCount: z.number().int().min(0).default(0),
});

// Simulate payment processor with configurable failure
class PaymentProcessor {
  private failureRates: Record<string, number> = {
    card: 0.1, // 10% failure rate
    'bank-transfer': 0.3, // 30% failure rate (more likely to fail)
    paypal: 0.05, // 5% failure rate
  };
  
  async processPayment(data: {
    amount: number;
    currency: string;
    paymentMethod: string;
    description?: string;
  }): Promise<{ transactionId: string; status: string; timestamp: string }> {
    // Simulate processing delay
    await new Promise((resolve) => setTimeout(resolve, 1500));
    
    // Simulate random failure based on payment method
    const failureRate = this.failureRates[data.paymentMethod] || 0.1;
    if (Math.random() < failureRate) {
      throw new Error(`Payment processing failed for ${data.paymentMethod}`);
    }
    
    return {
      transactionId: `txn-${Date.now()}-${Math.random().toString(36).substring(7)}`,
      status: 'completed',
      timestamp: new Date().toISOString(),
    };
  }
  
  async refundPayment(transactionId: string): Promise<{ success: boolean; timestamp: string }> {
    // Simulate refund processing
    await new Promise((resolve) => setTimeout(resolve, 1000));
    return {
      success: true,
      timestamp: new Date().toISOString(),
    };
  }
}

// Initialize payment processor
const paymentProcessor = new PaymentProcessor();

// Define the payment retry workflow
export const paymentRetryWorkflow = inngest.createFunction(
  {
    id: 'payment-retry-workflow',
    name: 'Payment Processing with Retry',
    description: 'Process payments with automatic retry and compensation',
    
    // Custom retry strategy for payment processing
    retries: 0, // We'll handle retries manually for fine-grained control
  },
  { event: 'payment/initiated' },
  async ({ event, step, logger }) => {
    const validatedData = PaymentInitiatedEventSchema.parse(event.data);
    const { paymentId, userId, amount, currency, paymentMethod, description, retryCount } = validatedData;
    
    logger.info('Processing payment', { paymentId, userId, amount, currency, paymentMethod, retryCount });
    
    let transactionId: string | null = null;
    let paymentAttempts = 0;
    let paymentSuccess = false;
    
    // Step 1: Process payment with retry loop
    const paymentResult = await step.run('process-payment-with-retry', async () => {
      const maxAttempts = 3;
      let lastError: Error | null = null;
      
      for (let attempt = 0; attempt < maxAttempts; attempt++) {
        try {
          paymentAttempts = attempt + 1;
          logger.info(`Payment attempt ${attempt + 1} of ${maxAttempts}`, { paymentId });
          
          // Attempt the payment
          const result = await paymentProcessor.processPayment({
            amount,
            currency,
            paymentMethod,
            description,
          });
          
          transactionId = result.transactionId;
          paymentSuccess = true;
          
          logger.info('Payment succeeded', { 
            paymentId, 
            attempt: attempt + 1, 
            transactionId 
          });
          
          return {
            success: true,
            transactionId,
            attempts: attempt + 1,
            timestamp: result.timestamp,
          };
          
        } catch (error) {
          lastError = error;
          logger.warn(`Payment attempt ${attempt + 1} failed`, { 
            paymentId, 
            error: error.message 
          });
          
          // If this is not the last attempt, wait before retrying
          if (attempt < maxAttempts - 1) {
            // Exponential backoff with jitter
            const delay = Math.min(Math.pow(2, attempt) * 2000, 10000);
            const jitter = Math.random() * 1000;
            await new Promise((resolve) => setTimeout(resolve, delay + jitter));
          }
        }
      }
      
      // If we get here, all attempts failed
      throw new Error(`Payment failed after ${maxAttempts} attempts: ${lastError?.message || 'Unknown error'}`);
    });
    
    // If we get here, payment succeeded. Step 2: Store payment record
    const paymentRecord = await step.run('store-payment-record', async () => {
      logger.info('Storing payment record', { paymentId, transactionId });
      
      // Simulate database operation
      await new Promise((resolve) => setTimeout(resolve, 300));
      
      return {
        paymentId,
        transactionId,
        userId,
        amount,
        currency,
        paymentMethod,
        status: 'completed',
        attempts: paymentResult.attempts,
        createdAt: new Date().toISOString(),
      };
    });
    
    // Step 3: Update order status (simulated)
    const orderUpdate = await step.run('update-order-status', async () => {
      logger.info('Updating order status', { paymentId });
      
      // Simulate order update
      await new Promise((resolve) => setTimeout(resolve, 200));
      
      return {
        orderId: `order-${paymentId}`,
        status: 'paid',
        updatedAt: new Date().toISOString(),
      };
    });
    
    // Step 4: Send payment confirmation (with retry)
    const confirmation = await step.run('send-payment-confirmation', async () => {
      let attempts = 0;
      let lastError: Error | null = null;
      
      // Try up to 3 times to send the confirmation
      for (attempts = 0; attempts < 3; attempts++) {
        try {
          logger.info('Sending payment confirmation', { paymentId, attempt: attempts + 1 });
          
          // Simulate email sending with potential failure
          await new Promise((resolve) => setTimeout(resolve, 1000));
          
          // Randomly fail for demonstration
          if (Math.random() < 0.2) {
            throw new Error('Email service temporarily unavailable');
          }
          
          return {
            sent: true,
            timestamp: new Date().toISOString(),
            emailId: `email-${Date.now()}`,
          };
        } catch (error) {
          lastError = error;
          logger.warn('Confirmation email failed', { paymentId, error: error.message });
          
          if (attempts < 2) {
            await new Promise((resolve) => setTimeout(resolve, 2000 * (attempts + 1)));
          }
        }
      }
      
      // If all attempts fail, log but don't fail the workflow
      // The order is still paid, just the confirmation failed
      logger.error('Failed to send confirmation email after 3 attempts', { 
        paymentId, 
        error: lastError?.message 
      });
      
      return {
        sent: false,
        timestamp: new Date().toISOString(),
        error: lastError?.message || 'Unknown error',
      };
    });
    
    return {
      payment: {
        id: paymentId,
        transactionId,
        amount,
        currency,
        status: 'completed',
        attempts: paymentResult.attempts,
      },
      order: orderUpdate,
      confirmation: {
        sent: confirmation.sent,
        timestamp: confirmation.timestamp,
      },
      paymentRecord,
      processedAt: new Date().toISOString(),
    };
  }
);
```

### Compensating Actions Workflow

Sometimes we need to reverse operations when a later step fails. This is called the **Saga Pattern**:

```typescript
// src/inngest/functions/saga-pattern-example.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Define the workflow with compensating actions
export const bookingSagaWorkflow = inngest.createFunction(
  {
    id: 'booking-saga-workflow',
    name: 'Booking with Saga Pattern',
    description: 'Reserve resources with compensating actions on failure',
  },
  { event: 'booking/requested' },
  async ({ event, step, logger }) => {
    const { bookingId, userId, flightId, hotelId, carId } = event.data;
    
    logger.info('Starting booking saga', { bookingId });
    
    // Track all reservations to compensate if needed
    const reservations: Record<string, any> = {};
    
    try {
      // Step 1: Reserve flight
      reservations.flight = await step.run('reserve-flight', async () => {
        logger.info('Reserving flight', { bookingId, flightId });
        await new Promise((resolve) => setTimeout(resolve, 1000));
        
        return {
          id: flightId,
          status: 'reserved',
          reference: `FL-${Date.now()}`,
          expiresAt: new Date(Date.now() + 600000).toISOString(), // 10 minutes
        };
      });
      
      // Step 2: Reserve hotel
      reservations.hotel = await step.run('reserve-hotel', async () => {
        logger.info('Reserving hotel', { bookingId, hotelId });
        await new Promise((resolve) => setTimeout(resolve, 1000));
        
        return {
          id: hotelId,
          status: 'reserved',
          reference: `HT-${Date.now()}`,
          expiresAt: new Date(Date.now() + 600000).toISOString(),
        };
      });
      
      // Step 3: Reserve car
      reservations.car = await step.run('reserve-car', async () => {
        logger.info('Reserving car', { bookingId, carId });
        await new Promise((resolve) => setTimeout(resolve, 1000));
        
        // Simulate failure to demonstrate compensation
        if (Math.random() < 0.3) {
          throw new Error('Car rental service unavailable');
        }
        
        return {
          id: carId,
          status: 'reserved',
          reference: `CR-${Date.now()}`,
          expiresAt: new Date(Date.now() + 600000).toISOString(),
        };
      });
      
      // Step 4: Confirm booking
      const confirmation = await step.run('confirm-booking', async () => {
        logger.info('Confirming booking', { bookingId });
        await new Promise((resolve) => setTimeout(resolve, 500));
        
        return {
          id: bookingId,
          status: 'confirmed',
          confirmedAt: new Date().toISOString(),
        };
      });
      
      return {
        success: true,
        booking: confirmation,
        reservations,
      };
      
    } catch (error) {
      // If any step fails, compensate for all successful reservations
      logger.error('Booking failed, initiating compensation', { 
        bookingId, 
        error: error.message 
      });
      
      // Step 5: Compensate flight if reserved
      if (reservations.flight) {
        await step.run('cancel-flight-reservation', async () => {
          logger.info('Canceling flight reservation', { 
            bookingId, 
            flightId: reservations.flight.id 
          });
          await new Promise((resolve) => setTimeout(resolve, 500));
          
          return {
            id: reservations.flight.id,
            status: 'canceled',
            canceledAt: new Date().toISOString(),
          };
        });
      }
      
      // Step 6: Compensate hotel if reserved
      if (reservations.hotel) {
        await step.run('cancel-hotel-reservation', async () => {
          logger.info('Canceling hotel reservation', { 
            bookingId, 
            hotelId: reservations.hotel.id 
          });
          await new Promise((resolve) => setTimeout(resolve, 500));
          
          return {
            id: reservations.hotel.id,
            status: 'canceled',
            canceledAt: new Date().toISOString(),
          };
        });
      }
      
      // Car compensation if reserved (will only be set if car reservation succeeded)
      if (reservations.car) {
        await step.run('cancel-car-reservation', async () => {
          logger.info('Canceling car reservation', { 
            bookingId, 
            carId: reservations.car.id 
          });
          await new Promise((resolve) => setTimeout(resolve, 500));
          
          return {
            id: reservations.car.id,
            status: 'canceled',
            canceledAt: new Date().toISOString(),
          };
        });
      }
      
      // Re-throw with compensation context
      throw new Error(`Booking failed after compensation: ${error.message}`);
    }
  }
);
```

---

## Module 2.4: Time-Based Orchestration

### The Target

Learn how to schedule delays, timeouts, and future actions in your workflows using `step.sleep()` and `step.sleepUntil()`.

### The Concept

Time-based orchestration is like **programming a DVR** for your workflows:

1. **`step.sleep()`**: "Pause the workflow for X seconds" (like hitting pause on a recording)
2. **`step.sleepUntil()`**: "Wait until a specific time" (like setting a timer to record a show)

During sleep, the workflow state is saved. If the system restarts, the sleep continues from where it left off.

### The Implementation: Scheduled Reminder System

Let's build a comprehensive reminder system that demonstrates time-based orchestration:

```typescript
// src/inngest/functions/reminder-system.ts
import { inngest } from '@/inngest/client';
import { z } from 'zod';

// Define reminder event schema
const ReminderScheduledEventSchema = z.object({
  reminderId: z.string().uuid(),
  userId: z.string().uuid(),
  email: z.string().email(),
  message: z.string().min(1).max(500),
  scheduledFor: z.string().datetime(), // ISO datetime
  recurrence: z.enum(['once', 'daily', 'weekly', 'monthly']).default('once'),
  remindBefore: z.number().min(0).max(7 * 24 * 60 * 60 * 1000).optional(), // milliseconds
});

// Main reminder workflow
export const reminderWorkflow = inngest.createFunction(
  {
    id: 'reminder-workflow',
    name: 'Scheduled Reminder System',
    description: 'Send reminders at specified times with configurable timing',
    
    // Retry configuration for reminders
    retries: 3,
    retryDelay: '5s',
  },
  { event: 'reminder/scheduled' },
  async ({ event, step, logger }) => {
    const validatedData = ReminderScheduledEventSchema.parse(event.data);
    const { 
      reminderId, 
      userId, 
      email, 
      message, 
      scheduledFor, 
      recurrence,
      remindBefore 
    } = validatedData;
    
    logger.info('Processing reminder', { reminderId, userId, scheduledFor });
    
    // Calculate wait time
    const scheduledTime = new Date(scheduledFor).getTime();
    const currentTime = Date.now();
    const waitTime = scheduledTime - currentTime;
    
    if (waitTime < 0) {
      logger.warn('Reminder scheduled in the past, sending immediately', { reminderId });
    }
    
    // Step 1: Wait until the scheduled time
    await step.sleep('wait-until-scheduled-time', waitTime > 0 ? waitTime : 0);
    
    logger.info('Reminder time arrived', { reminderId, scheduledFor });
    
    // Step 2: Send the reminder
    const reminderSent = await step.run('send-reminder', async () => {
      logger.info('Sending reminder', { reminderId, email });
      
      // Simulate sending
      await new Promise((resolve) => setTimeout(resolve, 1000));
      
      return {
        sent: true,
        sentAt: new Date().toISOString(),
        messageId: `msg-${Date.now()}`,
        recipient: email,
      };
    });
    
    // Step 3: Handle recurrence
    let nextReminder: any = null;
    if (recurrence !== 'once') {
      nextReminder = await step.run('schedule-next-reminder', async () => {
        logger.info('Scheduling next reminder', { reminderId, recurrence });
        
        // Calculate next occurrence
        const nextDate = new Date(scheduledTime);
        switch (recurrence) {
          case 'daily':
            nextDate.setDate(nextDate.getDate() + 1);
            break;
          case 'weekly':
            nextDate.setDate(nextDate.getDate() + 7);
            break;
          case 'monthly':
            nextDate.setMonth(nextDate.getMonth() + 1);
            break;
        }
        
        // In a real app, you'd store this in database
        // For now, we'll send another event
        await inngest.send({
          name: 'reminder/scheduled',
          data: {
            reminderId: `${reminderId}-${Date.now()}`,
            userId,
            email,
            message,
            scheduledFor: nextDate.toISOString(),
            recurrence,
          },
        });
        
        return {
          nextScheduledFor: nextDate.toISOString(),
          recurrence,
        };
      });
    }
    
    // Step 4: Store reminder history
    const history = await step.run('store-reminder-history', async () => {
      logger.info('Storing reminder history', { reminderId });
      
      // Simulate database storage
      await new Promise((resolve) => setTimeout(resolve, 200));
      
      return {
        reminderId,
        userId,
        sentAt: reminderSent.sentAt,
        nextReminder: nextReminder?.nextScheduledFor || null,
        status: 'completed',
      };
    });
    
    return {
      reminderId,
      sent: reminderSent.sentAt,
      nextReminder: nextReminder?.nextScheduledFor || null,
      history,
      processedAt: new Date().toISOString(),
    };
  }
);

// Advanced: Event reminder with early notification
export const eventReminderWorkflow = inngest.createFunction(
  {
    id: 'event-reminder-workflow',
    name: 'Event Reminder with Early Notice',
    description: 'Send reminders before an event with configurable notice periods',
  },
  { event: 'event/reminder-requested' },
  async ({ event, step, logger }) => {
    const { eventId, userId, email, eventName, eventTime, notifyBefore } = event.data;
    
    logger.info('Processing event reminder', { eventId, userId, eventName });
    
    // Wait for the reminder timing (event time - notifyBefore)
    const eventDate = new Date(eventTime).getTime();
    const currentTime = Date.now();
    const reminderTime = eventDate - notifyBefore;
    const waitTime = reminderTime - currentTime;
    
    if (waitTime > 0) {
      // Wait until the reminder time
      await step.sleep('wait-for-reminder-time', waitTime);
    }
    
    // Send the reminder
    const reminder = await step.run('send-event-reminder', async () => {
      logger.info('Sending event reminder', { eventId, email, eventName });
      
      // Simulate notification
      await new Promise((resolve) => setTimeout(resolve, 1000));
      
      return {
        sent: true,
        sentAt: new Date().toISOString(),
        eventId,
        eventName,
        eventTime,
      };
    });
    
    // Optionally, wait for the event and send a follow-up
    const eventWaitTime = eventDate - Date.now();
    if (eventWaitTime > 0) {
      await step.sleep('wait-for-event', eventWaitTime);
      
      // Send event start notification
      await step.run('send-event-start-notification', async () => {
        logger.info('Event starting now', { eventId, eventName });
        await new Promise((resolve) => setTimeout(resolve, 500));
        
        return {
          notification: 'event-start',
          eventId,
          timestamp: new Date().toISOString(),
        };
      });
    }
    
    return {
      eventId,
      reminders: {
        before: reminder,
        during: {
          sent: true,
          timestamp: new Date().toISOString(),
        },
      },
    };
  }
);
```

---

## Module 2.5: Testing and Debugging Durable Workflows

### The Target

Learn how to effectively test and debug durable workflows, including unit testing, integration testing, and using the Dev Server for debugging.

### The Concept

Testing durable workflows is like **flight simulation** for pilots:

1. **Unit Tests**: Test individual step logic in isolation
2. **Integration Tests**: Test the entire workflow with mocked dependencies
3. **Debug Mode**: Use the Dev Server to step through executions
4. **Logging**: Use strategic logging to trace execution flow

### The Implementation: Testing Utilities

```typescript
// src/inngest/__tests__/workflow-utils.ts
import { Inngest } from 'inngest';
import { vi } from 'vitest';

// Mock Inngest for testing
export function createMockInngest() {
  const mockInngest = {
    createFunction: vi.fn((config, trigger, handler) => ({
      config,
      trigger,
      handler,
    })),
    send: vi.fn(),
    events: {
      send: vi.fn(),
    },
  };
  
  return mockInngest;
}

// Mock step utilities
export function createMockStep() {
  const steps: any[] = [];
  
  const step = {
    run: vi.fn((name, fn) => {
      steps.push({ name, type: 'run' });
      return fn();
    }),
    sleep: vi.fn((name, duration) => {
      steps.push({ name, type: 'sleep', duration });
      return new Promise((resolve) => setTimeout(resolve, 10));
    }),
    sleepUntil: vi.fn((name, date) => {
      steps.push({ name, type: 'sleepUntil', date });
      return new Promise((resolve) => setTimeout(resolve, 10));
    }),
  };
  
  return { step, steps };
}

// Test helper for workflows
export function createWorkflowTest() {
  return {
    async execute(
      workflow: any,
      eventData: any,
      options: { failSteps?: string[] } = {}
    ) {
      const { step, steps } = createMockStep();
      const logger = {
        info: vi.fn(),
        error: vi.fn(),
        warn: vi.fn(),
        debug: vi.fn(),
      };
      
      const context = {
        event: {
          data: eventData,
          name: 'test/event',
          id: 'test-123',
          ts: Date.now(),
        },
        step,
        logger,
        attempt: 1,
        runId: 'test-run',
      };
      
      try {
        const result = await workflow.handler(context);
        return { success: true, result, steps, logger };
      } catch (error) {
        return { success: false, error, steps, logger };
      }
    },
  };
}
```

### Unit Test Example

```typescript
// src/inngest/__tests__/invoice-generation.test.ts
import { describe, it, expect, vi } from 'vitest';
import { invoiceGenerationWorkflow } from '../functions/invoice-generation';
import { createWorkflowTest } from './workflow-utils';

describe('Invoice Generation Workflow', () => {
  const testRunner = createWorkflowTest();
  
  it('should generate invoice successfully', async () => {
    const result = await testRunner.execute(invoiceGenerationWorkflow, {
      orderId: '123e4567-e89b-12d3-a456-426614174000',
      userId: '223e4567-e89b-12d3-a456-426614174000',
      items: [
        {
          id: 'item-1',
          name: 'Widget',
          quantity: 2,
          unitPrice: 29.99,
        },
        {
          id: 'item-2',
          name: 'Gadget',
          quantity: 1,
          unitPrice: 49.99,
        },
      ],
      billingAddress: {
        name: 'Test User',
        street: '123 Test St',
        city: 'Test City',
        state: 'TS',
        postalCode: '12345',
        country: 'USA',
      },
    });
    
    expect(result.success).toBe(true);
    expect(result.result).toBeDefined();
    expect(result.result.invoice.total).toBeGreaterThan(0);
    expect(result.result.invoice.number).toContain('INV-');
    expect(result.result.email.sent).toBe(true);
  });
  
  it('should handle validation errors', async () => {
    const result = await testRunner.execute(invoiceGenerationWorkflow, {
      orderId: 'invalid-uuid', // Invalid UUID
      userId: '223e4567-e89b-12d3-a456-426614174000',
      items: [],
      billingAddress: {
        name: 'Test User',
        street: '123 Test St',
        city: 'Test City',
        state: 'TS',
        postalCode: '12345',
        country: 'USA',
      },
    });
    
    expect(result.success).toBe(false);
    expect(result.error).toBeDefined();
  });
});
```

---

## Verification: Testing Your Enhanced Workflows

### Step 1: Run the Invoice Generation

```bash
# Trigger invoice generation
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "invoice/generate",
    "data": {
      "orderId": "123e4567-e89b-12d3-a456-426614174000",
      "userId": "223e4567-e89b-12d3-a456-426614174000",
      "items": [
        {
          "id": "item-1",
          "name": "Premium Widget",
          "quantity": 3,
          "unitPrice": 49.99
        },
        {
          "id": "item-2",
          "name": "Deluxe Gadget",
          "quantity": 2,
          "unitPrice": 29.99
        }
      ],
      "billingAddress": {
        "name": "Jane Doe",
        "street": "456 Business Ave",
        "city": "Commerce City",
        "state": "CA",
        "postalCode": "90210",
        "country": "USA"
      }
    }
  }'
```

### Step 2: Test Payment Retry Workflow

```bash
# Trigger payment processing with retry
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "payment/initiated",
    "data": {
      "paymentId": "123e4567-e89b-12d3-a456-426614174001",
      "userId": "223e4567-e89b-12d3-a456-426614174000",
      "amount": 149.99,
      "currency": "USD",
      "paymentMethod": "bank-transfer",
      "description": "Order #ORD-123"
    }
  }'

# Check the output. It should show retry attempts in the logs
```

### Step 3: Test Scheduled Reminders

```bash
# Schedule a reminder for 10 seconds from now
curl -X POST http://localhost:3000/api/inngest \
  -H "Content-Type: application/json" \
  -d '{
    "name": "reminder/scheduled",
    "data": {
      "reminderId": "123e4567-e89b-12d3-a456-426614174002",
      "userId": "223e4567-e89b-12d3-a456-426614174000",
      "email": "test@example.com",
      "message": "Test reminder message",
      "scheduledFor": "'$(date -v+10S -Iseconds)'",
      "recurrence": "once"
    }
  }'
```

### Step 4: View Execution in Dev Server

Open your browser to `http://localhost:3000/api/inngest` and:
1. Click on recent runs
2. Examine the step-by-step execution
3. Check the state transitions
4. Verify error handling and retries

---

## Deep Dive: Durable Execution Internals

### How State Checkpointing Works

Inngest uses a **write-ahead log** approach:

1. **Before** a step runs, Inngest writes a "started" entry
2. **During** execution, the step can use `step.run()` to create sub-steps
3. **After** completion, Inngest writes the result
4. **If** the step fails, Inngest has the start entry and can retry

```typescript
// Pseudo-code of checkpointing mechanism
class StepExecutor {
  async executeStep(step: Step, context: Context) {
    // 1. Check if this step already has a result
    const checkpoint = await this.loadCheckpoint(step.id);
    if (checkpoint) {
      // Return the saved result (idempotency)
      return checkpoint.result;
    }
    
    // 2. Write "started" checkpoint
    await this.saveCheckpoint({
      stepId: step.id,
      status: 'started',
      startTime: Date.now(),
    });
    
    try {
      // 3. Execute the step
      const result = await step.fn(context);
      
      // 4. Write "completed" checkpoint
      await this.saveCheckpoint({
        stepId: step.id,
        status: 'completed',
        result,
        endTime: Date.now(),
      });
      
      return result;
    } catch (error) {
      // 5. Write "failed" checkpoint
      await this.saveCheckpoint({
        stepId: step.id,
        status: 'failed',
        error: error.message,
        endTime: Date.now(),
      });
      
      throw error;
    }
  }
}
```

### Idempotency Guarantees

Inngest ensures idempotency through several mechanisms:

1. **Step Memoization**: The result of each step is cached
2. **Deduplication**: Events with the same ID are not processed twice
3. **Retry Awareness**: The system knows when it's retrying and can adjust behavior

```typescript
// Example of idempotent step design
const paymentStep = await step.run('process-payment', async () => {
  // Generate a unique idempotency key
  const idempotencyKey = `${event.data.orderId}-${event.data.amount}`;
  
  // Check if this payment was already processed
  const existing = await db.payments.findUnique({
    where: { idempotencyKey },
  });
  
  if (existing) {
    // Return existing result (idempotent)
    return existing;
  }
  
  // Process the payment
  const payment = await processPayment(event.data);
  
  // Store with idempotency key
  await db.payments.create({
    data: {
      ...payment,
      idempotencyKey,
    },
  });
  
  return payment;
});
```

### Deterministic Execution

For true durability, steps must be **deterministic**:

- **DO**: Use fixed values, database lookups, or API calls with retries
- **DON'T**: Use random values without tracking, current time without step.sleep

```typescript
// ❌ Non-deterministic - will produce different results on retry
const result = await step.run('bad-step', async () => {
  const randomId = Math.random().toString(36); // Different each time
  const now = new Date(); // Different each time
  return { id: randomId, timestamp: now };
});

// ✅ Deterministic - same input produces same output
const result = await step.run('good-step', async () => {
  // Use fixed values from event or previous steps
  const orderId = event.data.orderId;
  const timestamp = event.data.timestamp;
  return { id: `order-${orderId}`, timestamp };
});
```

---

## Troubleshooting Common Issues

### Issue: Steps Failing with "Maximum retries exceeded"

**Problem:** Your step keeps failing and exhausts all retry attempts.

**Solution:**
```typescript
// Add more logging to understand the failure
await step.run('problem-step', async () => {
  try {
    // Your code
    const result = await riskyOperation();
    return result;
  } catch (error) {
    // Log detailed error information
    logger.error('Step failed with details:', {
      error: error.message,
      stack: error.stack,
      context: { /* relevant context */ }
    });
    throw error; // Re-throw to trigger retry
  }
});

// Reduce retry delay to fail faster in development
export const inngest = new Inngest({
  // ... other config
  retryFunction: (attempt: number) => ({
    delay: attempt === 0 ? 1000 : Math.min(Math.pow(2, attempt) * 1000, 10000),
    maxAttempts: process.env.NODE_ENV === 'development' ? 2 : 5,
  }),
});
```

### Issue: Sleep Not Working as Expected

**Problem:** `step.sleep()` doesn't seem to wait the right amount of time.

**Solution:**
```typescript
// Check your time calculation
const scheduledTime = new Date(scheduledFor).getTime();
const currentTime = Date.now();
const waitTime = scheduledTime - currentTime;

// Log the wait time for debugging
logger.info('Sleep details:', {
  scheduledFor,
  scheduledTime: new Date(scheduledTime).toISOString(),
  currentTime: new Date(currentTime).toISOString(),
  waitTime,
  waitTimeSeconds: Math.floor(waitTime / 1000),
});

// Ensure waitTime is positive
if (waitTime < 0) {
  logger.warn('Wait time is negative, skipping sleep');
  // Continue execution immediately
} else {
  await step.sleep('custom-sleep', waitTime);
}
```

### Issue: State Not Persisting Between Steps

**Problem:** Data from previous steps isn't available in later steps.

**Solution:**
```typescript
// ❌ Incorrect - trying to use step.run result outside the step
let userId;
await step.run('step1', async () => {
  userId = await getUser(); // This won't work
});
await step.run('step2', async () => {
  // userId is undefined here
  await processUser(userId);
});

// ✅ Correct - return data from step
const user = await step.run('step1', async () => {
  return await getUser(); // Return the value
});
await step.run('step2', async () => {
  // user is available here
  await processUser(user.id);
});

// ✅ Also correct - use step context
const result = await step.run('step1', async () => {
  // Return complex data
  return {
    userId: 'user-123',
    email: 'test@example.com',
    profile: { name: 'Test User' },
  };
});
```

---

## What You've Accomplished

In Part 2, you've mastered:

1. ✅ Deep understanding of durable execution internals
2. ✅ Complex state management between workflow steps
3. ✅ Advanced error handling with automatic retries
4. ✅ Compensating actions with the Saga pattern
5. ✅ Time-based orchestration with `step.sleep()` and `step.sleepUntil()`
6. ✅ Testing strategies for durable workflows
7. ✅ Production-ready invoice generation workflow
8. ✅ Robust payment processing with retry logic
9. ✅ Scheduled reminder system with recurrence
10. ✅ Comprehensive logging and debugging techniques

You've learned:
- How Inngest persists state between steps
- How to build idempotent steps
- How to compensate for partial failures
- How to schedule future actions
- How to test and debug durable workflows
- Best practices for error handling

---

## Deep Dive Reference: Inngest API Cheatsheet

### Step API

```typescript
// Run a single step
await step.run('step-name', async () => {
  // Your step logic
  return result;
});

// Sleep for a duration
await step.sleep('sleep-name', 5000); // 5 seconds

// Sleep until a specific time
await step.sleepUntil('sleep-name', new Date('2024-12-31T23:59:59'));

// Wait for an external event
const result = await step.waitForEvent('wait-name', {
  event: 'order/fulfilled',
  timeout: '60s', // Or '1h', '1d'
  match: 'data.orderId', // Match on event data
});

// Parallel steps
const [result1, result2] = await Promise.all([
  step.run('parallel-1', async () => { /* ... */ }),
  step.run('parallel-2', async () => { /* ... */ }),
]);
```

### Function Configuration

```typescript
const function = inngest.createFunction(
  {
    id: 'unique-id',
    name: 'Display Name',
    retries: 3,
    retryDelay: '5s',
    concurrency: {
      limit: 10,
      scope: 'fn',
    },
    rateLimit: {
      limit: 100,
      period: '1m',
    },
    debounce: {
      key: 'data.userId',
      period: '10s',
    },
    throttle: {
      limit: 10,
      period: '1s',
      key: 'data.tenantId',
    },
  },
  { event: 'event/name' },
  async ({ event, step, logger }) => {
    // Handler
  }
);
```

### Event Sending

```typescript
// Send a single event
await inngest.send({
  name: 'event/name',
  data: { /* event data */ },
  user: { id: 'user-123' }, // Optional user context
});

// Send multiple events
await inngest.send([
  {
    name: 'event/name-1',
    data: { /* ... */ },
  },
  {
    name: 'event/name-2',
    data: { /* ... */ },
  },
]);
```

---

## Next Steps

In **Part 3**, we'll explore high-performance workflow patterns:
- Fan-out / fan-in orchestration
- Parallel step execution
- Concurrency management at scale
- Throttling and rate limiting
- Bulk processing patterns
- Performance optimization techniques

---

## References

- [Inngest Durable Execution Documentation](https://www.inngest.com/docs/learn/durable-execution)
- [Inngest Step API Reference](https://www.inngest.com/docs/reference/step)
- [Saga Pattern Explained](https://www.inngest.com/docs/learn/saga-pattern)
- [Testing Inngest Functions](https://www.inngest.com/docs/guides/testing)
- [Error Handling Best Practices](https://www.inngest.com/docs/learn/error-handling)

