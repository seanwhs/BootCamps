# Primer 3: Advanced Step Patterns

**Estimated Time**: 20 Minutes
**Prerequisites**: Completion of Primer 2, or basic understanding of Inngest concepts. Node.js and TypeScript/JavaScript knowledge assumed.

---

## 1. Building Complex Workflows with Advanced Step Patterns

In Primer 2, you learned the basic anatomy of a durable function. Now, we'll explore advanced patterns for building sophisticated workflows that go beyond simple sequential steps.

**What You'll Learn:**
- Fan-Out / Fan-In for parallel processing
- Conditional branching and dynamic steps
- Error handling with fallbacks and compensation
- Human-in-the-loop with `step.waitForEvent()`
- Chaining workflows and sending events

---

## 2. Fan-Out / Fan-In Pattern

### The Concept

**Fan-Out**: Split a single task into many parallel operations.  
**Fan-In**: Wait for all parallel operations to complete and aggregate results.

This pattern is essential for:
- Processing multiple items in parallel
- Calling multiple external services simultaneously
- Generating bulk reports or emails
- Processing large datasets

### Implementation Example: Bulk Email Sender

```typescript
export const bulkEmailWorkflow = inngest.createFunction(
  {
    id: "bulk-email-workflow",
    name: "Bulk Email Sender",
    concurrency: { limit: 10 },
  },
  { event: "email/bulk-request" },
  async ({ event, step, logger }) => {
    const { campaignId, recipients, message } = event.data;
    
    logger.info("Starting bulk email", { 
      campaignId, 
      recipientCount: recipients.length 
    });

    // Step 1: Prepare the email content (shared across all recipients)
    const emailContent = await step.run("prepare-email-content", async () => {
      return await renderEmailTemplate(message);
    });

    // Step 2: FAN-OUT - Process all recipients in parallel batches
    const BATCH_SIZE = 50;
    const allResults = [];

    for (let i = 0; i < recipients.length; i += BATCH_SIZE) {
      const batch = recipients.slice(i, i + BATCH_SIZE);
      
      // Process each batch in parallel
      const batchResults = await step.run(`process-batch-${i}`, async () => {
        // FAN-OUT: Send all emails in this batch in parallel
        const emailPromises = batch.map(async (recipient) => {
          try {
            const result = await sendEmail({
              to: recipient.email,
              subject: message.subject,
              html: emailContent,
              campaignId,
            });
            return { recipient: recipient.email, success: true, result };
          } catch (error) {
            return { recipient: recipient.email, success: false, error: error.message };
          }
        });

        // FAN-IN: Wait for all emails in this batch to complete
        return await Promise.all(emailPromises);
      });

      allResults.push(...batchResults);
    }

    // Step 3: FAN-IN - Aggregate all results
    const summary = await step.run("aggregate-results", async () => {
      const stats = {
        total: allResults.length,
        sent: allResults.filter(r => r.success).length,
        failed: allResults.filter(r => !r.success).length,
      };

      const failedRecipients = allResults
        .filter(r => !r.success)
        .map(r => ({ email: r.recipient, error: r.error }));

      return {
        campaignId,
        stats,
        failedRecipients,
        completedAt: new Date().toISOString(),
      };
    });

    return summary;
  }
);
```

### Pattern: Controlled Parallelism

Use concurrency limits to prevent overwhelming external systems:

```typescript
// Process in smaller chunks with controlled concurrency
const CONCURRENCY_LIMIT = 10;

for (let i = 0; i < items.length; i += CONCURRENCY_LIMIT) {
  const chunk = items.slice(i, i + CONCURRENCY_LIMIT);
  
  const results = await step.run(`process-chunk-${i}`, async () => {
    // Process chunk with limited concurrency
    return await Promise.all(
      chunk.map(item => processItem(item))
    );
  });
  
  // Optionally: add delay between chunks
  if (i + CONCURRENCY_LIMIT < items.length) {
    await step.sleep("rate-limit-delay", 1000);
  }
}
```

---

## 3. Conditional Branching

### The Concept

Workflows often need to take different paths based on conditions. In Inngest, you can use standard JavaScript control flow within your handler.

### Implementation Example: Order Processing with Conditional Logic

```typescript
export const conditionalOrderWorkflow = inngest.createFunction(
  {
    id: "conditional-order-workflow",
    name: "Conditional Order Processing",
  },
  { event: "order/placed" },
  async ({ event, step, logger }) => {
    const { orderId, total, customerId, isNewCustomer } = event.data;

    // Step 1: Common validation for all orders
    await step.run("validate-order", async () => {
      await validateOrder(orderId);
    });

    // Step 2: Conditional logic based on order value
    let paymentResult;
    let approvalRequired = false;

    if (total > 10000) {
      // High-value order: requires approval
      approvalRequired = true;
      
      // Request approval
      await step.run("request-approval", async () => {
        await sendApprovalRequest(orderId, total);
      });

      // Wait for approval decision
      try {
        const decision = await step.waitForEvent("wait-for-approval", {
          event: "order/approved",
          timeout: "24h",
          match: data => data.orderId === orderId,
        });

        if (!decision.data.approved) {
          // Order denied
          return {
            orderId,
            status: "denied",
            reason: "Management approval denied",
          };
        }
      } catch {
        // Timeout - auto-deny
        return {
          orderId,
          status: "denied",
          reason: "Approval timed out",
        };
      }
    }

    // Step 3: Process payment based on customer type
    if (isNewCustomer) {
      // New customers: require additional verification
      paymentResult = await step.run("process-payment-new-customer", async () => {
        await verifyCustomer(customerId);
        return await chargeCustomer(customerId, total);
      });
    } else {
      // Existing customers: standard payment
      paymentResult = await step.run("process-payment-existing", async () => {
        return await chargeCustomer(customerId, total);
      });
    }

    // Step 4: Conditional fulfillment
    if (total > 5000) {
      // High-value orders: expedited shipping
      await step.run("expedited-shipping", async () => {
        await scheduleExpeditedShipping(orderId);
      });
    } else {
      // Standard orders: regular shipping
      await step.run("standard-shipping", async () => {
        await scheduleStandardShipping(orderId);
      });
    }

    // Step 5: Conditional notification
    if (isNewCustomer) {
      await step.run("send-welcome-package", async () => {
        await sendWelcomeEmail(customerId);
        await sendDiscountCode(customerId);
      });
    } else {
      await step.run("send-order-confirmation", async () => {
        await sendOrderConfirmation(customerId, orderId);
      });
    }

    return {
      orderId,
      status: "processed",
      paymentId: paymentResult.transactionId,
      approvalRequired,
    };
  }
);
```

---

## 4. Error Handling with Fallbacks and Compensation

### The Concept

In durable workflows, you should plan for failures. **Fallbacks** provide alternative paths when a step fails. **Compensation** undoes previous steps when a later step fails.

### Implementation Example: Payment Processing with Fallbacks

```typescript
export const robustPaymentWorkflow = inngest.createFunction(
  {
    id: "robust-payment-workflow",
    name: "Robust Payment Processing",
  },
  { event: "payment/requested" },
  async ({ event, step, logger }) => {
    const { paymentId, amount, customerId, primaryMethod } = event.data;

    // Track what's been processed for compensation
    const processed = {
      primaryPayment: false,
      secondaryPayment: false,
      inventory: false,
      shipping: false,
    };

    // Step 1: Try primary payment method with fallback
    let paymentResult;
    let methodUsed;

    try {
      // Primary payment attempt
      paymentResult = await step.run("process-primary-payment", async () => {
        return await processPayment(customerId, amount, primaryMethod);
      });
      processed.primaryPayment = true;
      methodUsed = primaryMethod;

    } catch (error) {
      logger.warn("Primary payment failed, trying fallback", {
        paymentId,
        error: error.message,
      });

      // Fallback 1: Try alternate payment method
      try {
        paymentResult = await step.run("process-fallback-payment", async () => {
          return await processPayment(customerId, amount, "credit-card");
        });
        processed.primaryPayment = true; // We succeeded, but with fallback
        methodUsed = "credit-card (fallback)";

      } catch (fallbackError) {
        logger.error("All payment methods failed", {
          paymentId,
          error: fallbackError.message,
        });

        // Fallback 2: Set payment to pending, notify support
        paymentResult = await step.run("mark-payment-pending", async () => {
          return await markPaymentPending(paymentId, "All payment methods failed");
        });
        methodUsed = "pending (manual review required)";
      }
    }

    // Step 2: Update inventory (only if payment succeeded or is pending)
    if (paymentResult.status !== "failed") {
      try {
        await step.run("update-inventory", async () => {
          await deductInventory(event.data.items);
          processed.inventory = true;
        });
      } catch (error) {
        logger.error("Inventory update failed", {
          paymentId,
          error: error.message,
        });

        // If inventory update fails and payment succeeded, we need to compensate
        if (paymentResult.status === "succeeded") {
          await step.run("compensate-payment", async () => {
            await refundPayment(paymentResult.transactionId);
            processed.primaryPayment = false;
          });
        }

        throw new Error(`Workflow failed at inventory step: ${error.message}`);
      }
    }

    // Step 3: Schedule shipping (optional, can be retried later)
    try {
      await step.run("schedule-shipping", async () => {
        await scheduleShipping(event.data.orderId);
        processed.shipping = true;
      });
    } catch (error) {
      // Non-critical: mark for later processing
      await step.run("mark-shipping-pending", async () => {
        await scheduleShippingRetry(event.data.orderId);
      });
      logger.warn("Shipping scheduling failed, marked for retry", {
        paymentId,
        error: error.message,
      });
    }

    // Step 4: Send confirmation based on payment status
    if (paymentResult.status === "succeeded") {
      await step.run("send-success-confirmation", async () => {
        await sendPaymentSuccessEmail(customerId, paymentResult.transactionId);
      });
    } else if (paymentResult.status === "pending") {
      await step.run("send-pending-notification", async () => {
        await sendPaymentPendingEmail(customerId, paymentId);
      });
    }

    // Return comprehensive result
    return {
      paymentId,
      status: paymentResult.status || "processed",
      methodUsed,
      processed: {
        payment: processed.primaryPayment,
        inventory: processed.inventory,
        shipping: processed.shipping,
      },
      result: paymentResult,
      processedAt: new Date().toISOString(),
    };
  }
);
```

### Pattern: Saga Pattern with Compensation

For multi-step distributed transactions, use the Saga pattern:

```typescript
export const sagaWorkflow = inngest.createFunction(
  {
    id: "saga-workflow",
    name: "Saga Pattern Example",
  },
  { event: "transaction/start" },
  async ({ event, step, logger }) => {
    const state = {};

    try {
      // Phase 1: Reserve resources
      state.flight = await step.run("reserve-flight", async () => {
        return await airlineAPI.reserve(event.data.flightId);
      });

      state.hotel = await step.run("reserve-hotel", async () => {
        return await hotelAPI.reserve(event.data.hotelId);
      });

      state.car = await step.run("reserve-car", async () => {
        return await carRentalAPI.reserve(event.data.carId);
      });

      // Phase 2: Confirm all reservations
      await step.run("confirm-booking", async () => {
        await confirmAllBookings(state);
      });

      return { success: true, state };

    } catch (error) {
      // Phase 3: Compensate - undo all successful reservations
      logger.error("Booking failed, initiating compensation", {
        error: error.message,
      });

      // Cancel in reverse order (LIFO)
      if (state.car) {
        await step.run("cancel-car", async () => {
          await carRentalAPI.cancel(state.car.id);
        });
      }

      if (state.hotel) {
        await step.run("cancel-hotel", async () => {
          await hotelAPI.cancel(state.hotel.id);
        });
      }

      if (state.flight) {
        await step.run("cancel-flight", async () => {
          await airlineAPI.cancel(state.flight.id);
        });
      }

      throw new Error(`Booking failed: ${error.message}`);
    }
  }
);
```

---

## 5. Human-in-the-Loop with `step.waitForEvent()`

### The Concept

Many workflows require human intervention. `step.waitForEvent()` allows your workflow to pause and wait for an external event—often from a human decision.

### Implementation Example: Approval Workflow

```typescript
export const approvalWorkflow = inngest.createFunction(
  {
    id: "approval-workflow",
    name: "Approval Workflow",
  },
  { event: "approval/requested" },
  async ({ event, step, logger }) => {
    const { requestId, requesterId, details, requiredApprovers } = event.data;

    logger.info("Starting approval process", {
      requestId,
      requiredApprovers: requiredApprovers.length,
    });

    // Step 1: Notify all approvers
    await step.run("notify-approvers", async () => {
      for (const approver of requiredApprovers) {
        await sendApprovalRequest(approver.email, requestId, details);
      }
    });

    // Step 2: Wait for all approvals with timeout
    const approvalResults = [];
    const maxWaitTime = "7d"; // Wait up to 7 days
    let allApproved = true;

    for (const approver of requiredApprovers) {
      try {
        const decision = await step.waitForEvent(`wait-for-${approver.id}`, {
          event: "approval/decision",
          timeout: maxWaitTime,
          match: (data) => 
            data.requestId === requestId && 
            data.approverId === approver.id,
        });

        approvalResults.push({
          approver: approver.id,
          approved: decision.data.approved,
          timestamp: decision.data.timestamp,
          comment: decision.data.comment,
        });

        if (!decision.data.approved) {
          allApproved = false;
          break; // No need to wait for others if one rejects
        }

      } catch {
        // Timeout - treat as rejection
        approvalResults.push({
          approver: approver.id,
          approved: false,
          timestamp: new Date().toISOString(),
          comment: "Approval timed out",
        });
        allApproved = false;
        break;
      }
    }

    // Step 3: Process final decision
    if (allApproved) {
      await step.run("execute-request", async () => {
        await executeApprovedRequest(requestId);
      });

      await step.run("notify-requester-approved", async () => {
        await notifyRequester(requesterId, "Your request was approved");
      });

      return {
        requestId,
        status: "approved",
        approvals: approvalResults,
        executedAt: new Date().toISOString(),
      };

    } else {
      await step.run("notify-requester-denied", async () => {
        await notifyRequester(requesterId, "Your request was denied");
      });

      return {
        requestId,
        status: "denied",
        approvals: approvalResults,
        deniedAt: new Date().toISOString(),
      };
    }
  }
);
```

### Pattern: Escalation Workflow

```typescript
export const escalationWorkflow = inngest.createFunction(
  {
    id: "escalation-workflow",
    name: "Escalation Workflow",
  },
  { event: "support/ticket-created" },
  async ({ event, step, logger }) => {
    const { ticketId, priority, assignedTo } = event.data;

    // Step 1: Assign to primary agent
    await step.run("assign-ticket", async () => {
      await assignTicket(ticketId, assignedTo);
    });

    // Step 2: Wait for resolution with timeouts
    let attempt = 1;
    const maxAttempts = 3;

    while (attempt <= maxAttempts) {
      // Calculate timeout based on priority
      const timeouts = {
        critical: "1h",
        high: "4h",
        medium: "24h",
        low: "72h",
      };
      const timeout = timeouts[priority] || "24h";

      try {
        const resolution = await step.waitForEvent(`wait-for-resolution-${attempt}`, {
          event: "ticket/resolved",
          timeout,
          match: data => data.ticketId === ticketId,
        });

        if (resolution.data.resolved) {
          return {
            ticketId,
            status: "resolved",
            resolvedBy: resolution.data.resolvedBy,
            resolvedAt: resolution.data.timestamp,
          };
        }

      } catch {
        // Timeout - escalate
        logger.warn("Ticket resolution timed out, escalating", {
          ticketId,
          attempt,
          priority,
        });

        if (attempt < maxAttempts) {
          await step.run(`escalate-ticket-${attempt}`, async () => {
            await escalateTicket(
              ticketId,
              `Attempt ${attempt}: Resolution timed out`,
              getEscalationLevel(attempt)
            );
          });
          attempt++;
        } else {
          // Max attempts reached - send to management
          await step.run("escalate-to-management", async () => {
            await escalateToManagement(ticketId, "Maximum escalation attempts reached");
          });

          return {
            ticketId,
            status: "escalated",
            escalationLevel: "management",
            attempts: attempt,
          };
        }
      }
    }
  }
);

function getEscalationLevel(attempt: number): string {
  const levels = ['team-lead', 'manager', 'director'];
  return levels[attempt - 1] || 'director';
}
```

---

## 6. Chaining Workflows with `step.sendEvent()`

### The Concept

Complex business processes often span multiple workflows. Use `step.sendEvent()` to trigger subsequent workflows from within a step.

### Implementation Example: Order Fulfillment Pipeline

```typescript
export const orderFulfillmentWorkflow = inngest.createFunction(
  {
    id: "order-fulfillment-workflow",
    name: "Order Fulfillment Pipeline",
  },
  { event: "order/placed" },
  async ({ event, step, logger }) => {
    const { orderId, customerId, items, paymentMethod } = event.data;

    // Step 1: Process payment
    const payment = await step.run("process-payment", async () => {
      return await processPayment(orderId, paymentMethod);
    });

    // Step 2: Update inventory
    await step.run("update-inventory", async () => {
      for (const item of items) {
        await deductInventory(item.productId, item.quantity);
      }
    });

    // Step 3: Generate invoice
    const invoice = await step.run("generate-invoice", async () => {
      return await generateInvoice(orderId);
    });

    // Step 4: Send events to trigger downstream workflows
    await step.sendEvent("trigger-downstream-workflows", [
      // Trigger shipping workflow
      {
        name: "shipping/requested",
        data: {
          orderId,
          customerId,
          items,
          priority: "standard",
        },
      },
      // Trigger email workflow
      {
        name: "email/order-confirmation",
        data: {
          customerId,
          orderId,
          invoiceUrl: invoice.url,
        },
      },
      // Trigger analytics workflow
      {
        name: "analytics/order-tracked",
        data: {
          orderId,
          total: payment.amount,
          items: items.length,
        },
      },
    ]);

    // Step 5: Wait for shipping confirmation (optional)
    try {
      const shippingConfirm = await step.waitForEvent("wait-for-shipping", {
        event: "shipping/confirmed",
        timeout: "2h",
        match: data => data.orderId === orderId,
      });

      logger.info("Shipping confirmed", {
        orderId,
        trackingId: shippingConfirm.data.trackingId,
      });

    } catch {
      logger.warn("Shipping confirmation not received", { orderId });
    }

    return {
      orderId,
      status: "fulfilled",
      paymentId: payment.transactionId,
      invoiceId: invoice.id,
      processedAt: new Date().toISOString(),
    };
  }
);
```

---

## 7. Summary: Advanced Step Patterns Quick Reference

| Pattern | Use Case | Key Method |
|---------|----------|------------|
| **Fan-Out/Fan-In** | Process multiple items in parallel | `Promise.all()` inside `step.run()` |
| **Conditional Branching** | Different logic based on conditions | `if/else` with `step.run()` |
| **Error Fallbacks** | Alternative when primary fails | `try/catch` with fallback steps |
| **Compensation** | Undo previous steps on failure | Saga pattern with compensating steps |
| **Human-in-the-Loop** | Wait for human decisions | `step.waitForEvent()` |
| **Escalation** | Timeout with auto-escalation | `step.waitForEvent()` with retries |
| **Workflow Chaining** | Trigger downstream workflows | `step.sendEvent()` |

---

## Next Steps

You now understand advanced step patterns for building complex workflows. In the next primer, we'll explore how to integrate Inngest with Next.js and React for full-stack applications.
