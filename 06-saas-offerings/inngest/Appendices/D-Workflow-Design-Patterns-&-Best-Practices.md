# Mastering Inngest: Building Reliable Serverless Workflows with Durable Execution

## Design Resilient Event-Driven Systems Without Managing Queues, Workers, or Workflow Infrastructure

---

# Appendix D: Workflow Design Patterns & Best Practices

This appendix consolidates the most important design patterns, architectural principles, and best practices for building production-grade durable workflows with Inngest. Use this as a reference guide when designing new workflows or refactoring existing ones.

---

## D.1 Core Architectural Principles

### The 5 Principles of Durable Workflow Design

#### 1. Idempotency First
Every operation that has side effects must be idempotent. A workflow should produce the same outcome when retried.

```typescript
// ✅ Idempotent payment processing
const payment = await step.run('process-payment', async () => {
  const idempotencyKey = `payment-${orderId}-${amount}`;
  
  // Check if already processed
  const existing = await db.payments.findUnique({
    where: { idempotencyKey }
  });
  if (existing) return existing;
  
  // Process payment
  const result = await chargeCard(orderId, amount);
  
  // Store with idempotency key
  await db.payments.create({
    data: {
      idempotencyKey,
      ...result
    }
  });
  
  return result;
});
```

#### 2. Deterministic Execution
Steps should produce the same output given the same input. Avoid using non-deterministic values like `Math.random()`, `Date.now()`, or `new Date()` directly in step logic.

```typescript
// ❌ Non-deterministic
const id = await step.run('generate-id', async () => {
  return Math.random().toString(36); // Different on retry
});

// ✅ Deterministic
const id = await step.run('generate-id', async () => {
  return `order-${orderId}-${timestamp}`; // Same inputs = same output
});

// ❌ Non-deterministic timing
const startedAt = Date.now(); // Different on retry

// ✅ Deterministic from event
const startedAt = event.data.timestamp; // From the original event
```

#### 3. Compensating Actions
Always plan for failure. If a step fails, earlier steps may need to be undone.

```typescript
const reservations = {};

try {
  // Reserve resources
  reservations.flight = await step.run('reserve-flight', async () => {
    return await airlineAPI.reserve(flightId);
  });
  
  reservations.hotel = await step.run('reserve-hotel', async () => {
    return await hotelAPI.reserve(hotelId);
  });
  
  // If we get here, all reservations succeeded
  return { success: true, reservations };
  
} catch (error) {
  // Compensate: cancel all reservations
  for (const [type, reservation] of Object.entries(reservations)) {
    await step.run(`cancel-${type}`, async () => {
      await cancelReservation(type, reservation.id);
    });
  }
  throw new Error(`Booking failed: ${error.message}`);
}
```

#### 4. State Minimalism
Only store what you need. Large state objects slow down execution and increase memory usage.

```typescript
// ❌ Storing large objects
const fullUser = await step.run('get-user', async () => {
  return await db.user.findUnique({
    where: { id: userId },
    include: {
      orders: true,
      profile: true,
      settings: true,
      history: true // 1000s of records
    }
  });
});

// ✅ Storing only what's needed
const user = await step.run('get-user', async () => {
  const user = await db.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      email: true,
      name: true,
      planId: true // Only what's needed
    }
  });
  return user;
});

// Store large data externally
const largeDataId = await step.run('store-large-data', async () => {
  const data = await generateLargeData();
  await redis.setex(`data:${dataId}`, 3600, JSON.stringify(data));
  return { dataId };
});

// Retrieve only when needed
const data = await step.run('use-large-data', async () => {
  const cached = await redis.get(`data:${dataId}`);
  return JSON.parse(cached);
});
```

#### 5. Failure Isolation
Design workflows so that a failure in one part doesn't cascade unnecessarily.

```typescript
// ✅ Isolated steps with graceful degradation
const results = [];

// Primary operation
try {
  const main = await step.run('main-operation', async () => {
    return await primaryService.call();
  });
  results.push({ step: 'main', success: true, result: main });
} catch (error) {
  results.push({ step: 'main', success: false, error: error.message });
}

// Secondary operation (continues even if primary fails)
try {
  const secondary = await step.run('secondary-operation', async () => {
    return await secondaryService.call();
  });
  results.push({ step: 'secondary', success: true, result: secondary });
} catch (error) {
  results.push({ step: 'secondary', success: false, error: error.message });
}

// Continue with partial results
return {
  partial: true,
  results,
  failedCount: results.filter(r => !r.success).length,
};
```

---

## D.2 Common Workflow Patterns

### Pattern 1: Transactional Workflow (Saga)

```typescript
export const sagaWorkflow = inngest.createFunction(
  { id: 'saga-workflow' },
  { event: 'transaction/start' },
  async ({ event, step }) => {
    const state = {};
    
    try {
      // Phase 1: Reserve resources
      state.step1 = await step.run('reserve-resource-1', async () => {
        return await resource1.reserve(event.data);
      });
      
      state.step2 = await step.run('reserve-resource-2', async () => {
        return await resource2.reserve(event.data);
      });
      
      state.step3 = await step.run('reserve-resource-3', async () => {
        return await resource3.reserve(event.data);
      });
      
      // Phase 2: Commit all
      await step.run('commit-all', async () => {
        await commitAll(state);
      });
      
      return { success: true, state };
      
    } catch (error) {
      // Phase 3: Compensate
      await step.run('compensate-all', async () => {
        await compensateAll(state);
      });
      
      throw error;
    }
  }
);
```

### Pattern 2: Fan-Out / Fan-In

```typescript
export const fanOutFanInWorkflow = inngest.createFunction(
  { id: 'fan-out-fan-in' },
  { event: 'bulk/process' },
  async ({ event, step }) => {
    const { items, batchSize = 10 } = event.data;
    
    // Fan-Out: Process all items in parallel batches
    const batchResults = [];
    for (let i = 0; i < items.length; i += batchSize) {
      const batch = items.slice(i, i + batchSize);
      
      const results = await step.run(`process-batch-${i}`, async () => {
        // Process each item in parallel within the batch
        return await Promise.all(
          batch.map(item => processItem(item))
        );
      });
      
      batchResults.push(...results);
    }
    
    // Fan-In: Aggregate all results
    const aggregated = await step.run('aggregate-results', async () => {
      return {
        total: batchResults.length,
        success: batchResults.filter(r => r.success).length,
        failed: batchResults.filter(r => !r.success).length,
        results: batchResults,
      };
    });
    
    return aggregated;
  }
);
```

### Pattern 3: Notification Workflow with Reminders

```typescript
export const notificationWithReminders = inngest.createFunction(
  { id: 'notification-with-reminders' },
  { event: 'notification/requested' },
  async ({ event, step }) => {
    const { recipient, message, urgency } = event.data;
    
    // Initial notification
    await step.run('send-initial-notification', async () => {
      return await sendNotification(recipient, message);
    });
    
    // Wait for acknowledgment
    let acknowledged = false;
    let attempt = 1;
    const maxAttempts = 5;
    
    while (!acknowledged && attempt <= maxAttempts) {
      try {
        const ack = await step.waitForEvent(`wait-for-ack-${attempt}`, {
          event: 'notification/acknowledged',
          timeout: getTimeoutForAttempt(attempt),
          match: (data) => data.recipientId === recipient.id,
        });
        
        if (ack.data.acknowledged) {
          acknowledged = true;
          break;
        }
      } catch {
        // Timeout - send reminder
        if (attempt <= maxAttempts) {
          await step.run(`send-reminder-${attempt}`, async () => {
            return await sendReminder(recipient, message, attempt);
          });
        }
        attempt++;
      }
    }
    
    // Escalate if not acknowledged
    if (!acknowledged) {
      await step.run('escalate-notification', async () => {
        return await escalate(recipient, message);
      });
    }
    
    return { acknowledged, attempts: attempt };
  }
);

function getTimeoutForAttempt(attempt: number): string {
  return ['5m', '10m', '30m', '1h', '2h'][attempt - 1] || '2h';
}
```

### Pattern 4: Circuit Breaker for External Services

```typescript
class CircuitBreaker {
  private state: 'closed' | 'open' | 'half-open' = 'closed';
  private failureCount = 0;
  private lastFailureTime = 0;
  private readonly threshold = 5;
  private readonly timeout = 60000; // 60 seconds
  
  async execute<T>(fn: () => Promise<T>, step: any): Promise<T> {
    if (this.state === 'open') {
      const now = Date.now();
      if (now - this.lastFailureTime > this.timeout) {
        this.state = 'half-open';
      } else {
        throw new Error('Circuit breaker is open');
      }
    }
    
    try {
      const result = await fn();
      
      if (this.state === 'half-open') {
        this.state = 'closed';
        this.failureCount = 0;
      }
      
      return result;
    } catch (error) {
      this.failureCount++;
      this.lastFailureTime = Date.now();
      
      if (this.failureCount >= this.threshold) {
        this.state = 'open';
      }
      
      throw error;
    }
  }
}

export const circuitBreakerWorkflow = inngest.createFunction(
  { id: 'circuit-breaker-example' },
  { event: 'external/call' },
  async ({ event, step }) => {
    const breaker = new CircuitBreaker();
    
    const result = await step.run('protected-external-call', async () => {
      return await breaker.execute(
        () => externalService.call(event.data),
        step
      );
    });
    
    return { result };
  }
);
```

### Pattern 5: Bulkhead (Resource Isolation)

```typescript
export const bulkheadWorkflow = inngest.createFunction(
  {
    id: 'bulkhead-example',
    concurrency: {
      limit: 10, // Max 10 concurrent executions
      scope: 'fn',
    },
  },
  { event: 'task/process' },
  async ({ event, step }) => {
    // Each tenant gets their own concurrency limit
    const tenantId = event.data.tenantId;
    
    // This is handled by key-based concurrency
    // Each tenant can have 5 concurrent executions
    // ... workflow logic
  }
);

// Key-based concurrency for tenant isolation
export const tenantIsolatedWorkflow = inngest.createFunction(
  {
    id: 'tenant-isolated',
    concurrency: {
      limit: 5,
      scope: 'key',
      key: 'data.tenantId', // 5 concurrent per tenant
    },
  },
  { event: 'tenant/task' },
  async ({ event, step }) => {
    // Process tenant task
  }
);
```

---

## D.3 Error Handling Strategies

### Strategy 1: Graceful Degradation

```typescript
const result = await step.run('optional-feature', async () => {
  try {
    return await experimentalFeature(event.data);
  } catch (error) {
    // Log but don't fail the workflow
    logger.warn('Optional feature failed, continuing', {
      error: error.message,
      feature: 'experimental-feature',
    });
    return { available: false, reason: error.message };
  }
});

// Continue with fallback
if (!result.available) {
  await step.run('fallback-path', async () => {
    return await traditionalFeature(event.data);
  });
}
```

### Strategy 2: Retry with Exponential Backoff

```typescript
const MAX_RETRIES = 5;
let attempt = 0;
let lastError: Error | null = null;

while (attempt < MAX_RETRIES) {
  try {
    const result = await step.run(`operation-attempt-${attempt + 1}`, async () => {
      return await flakyOperation(event.data);
    });
    return result;
  } catch (error) {
    lastError = error;
    attempt++;
    
    if (attempt < MAX_RETRIES) {
      // Exponential backoff: 1s, 2s, 4s, 8s, 16s
      const delay = Math.min(Math.pow(2, attempt) * 1000, 30000);
      await step.sleep(`backoff-${attempt}`, delay);
    }
  }
}

throw new Error(`Operation failed after ${MAX_RETRIES} attempts: ${lastError?.message}`);
```

### Strategy 3: Dead Letter Queue

```typescript
const result = await step.run('process-with-dlq', async () => {
  try {
    return await processItem(event.data);
  } catch (error) {
    // Send to dead letter queue
    await inngest.send({
      name: 'task/failed',
      data: {
        originalEvent: event,
        error: error.message,
        timestamp: new Date().toISOString(),
        retryCount: event.data.retryCount || 0,
      },
    });
    
    throw error; // Still throw to trigger retry
  }
});
```

### Strategy 4: Fallback with Cached Response

```typescript
const result = await step.run('api-with-fallback', async () => {
  try {
    return await primaryAPI.call(event.data);
  } catch (error) {
    logger.warn('Primary API failed, using cache', {
      error: error.message,
    });
    
    const cached = await redis.get(`api-cache:${event.data.id}`);
    if (cached) {
      return { cached: true, data: JSON.parse(cached) };
    }
    
    // No cache, use fallback API
    return await fallbackAPI.call(event.data);
  }
});
```

---

## D.4 Performance Optimization Patterns

### Pattern 1: Parallel Processing with Concurrency Limit

```typescript
async function parallelWithLimit<T>(
  items: any[],
  processor: (item: any) => Promise<T>,
  concurrency: number = 10
): Promise<T[]> {
  const results: T[] = [];
  const chunks = [];
  
  // Split into chunks
  for (let i = 0; i < items.length; i += concurrency) {
    chunks.push(items.slice(i, i + concurrency));
  }
  
  // Process each chunk in parallel
  for (const chunk of chunks) {
    const chunkResults = await Promise.all(
      chunk.map(item => processor(item))
    );
    results.push(...chunkResults);
  }
  
  return results;
}

// Usage in workflow
const results = await step.run('parallel-processing', async () => {
  return await parallelWithLimit(
    items,
    async (item) => processItem(item),
    20 // 20 concurrent
  );
});
```

### Pattern 2: Caching Expensive Operations

```typescript
const cachedResult = await step.run('cached-operation', async () => {
  const cacheKey = `op:${event.data.id}:${event.data.timestamp}`;
  
  // Try cache
  const cached = await redis.get(cacheKey);
  if (cached) {
    return { cached: true, data: JSON.parse(cached) };
  }
  
  // Expensive operation
  const result = await expensiveOperation(event.data);
  
  // Cache for future use
  await redis.setex(cacheKey, 3600, JSON.stringify(result));
  
  return { cached: false, data: result };
});
```

### Pattern 3: Pagination for Large Datasets

```typescript
const allData = [];
let cursor = null;
let hasMore = true;

while (hasMore) {
  const page = await step.run(`fetch-page-${allData.length}`, async () => {
    const results = await db.query({
      limit: 100,
      cursor,
    });
    return results;
  });
  
  allData.push(...page.items);
  cursor = page.nextCursor;
  hasMore = page.hasMore;
}

return allData;
```

---

## D.5 Testing Patterns

### Pattern 1: Unit Test with Mocked Steps

```typescript
// test-utils.ts
export function createMockStep() {
  const step = {
    run: vi.fn().mockImplementation(async (name: string, fn: () => any) => {
      return await fn();
    }),
    sleep: vi.fn().mockResolvedValue(undefined),
    waitForEvent: vi.fn(),
    sendEvent: vi.fn(),
  };
  return step;
}

// workflow.test.ts
const mockStep = createMockStep();
const result = await workflow.handler({
  event: mockEvent,
  step: mockStep,
  logger: mockLogger,
});
expect(mockStep.run).toHaveBeenCalledWith('step-name', expect.any(Function));
```

### Pattern 2: Integration Test with Real Services

```typescript
describe('Integration Tests', () => {
  beforeAll(async () => {
    await setupTestDatabase();
    await setupTestQueue();
  });
  
  afterAll(async () => {
    await cleanup();
  });
  
  it('should process order end-to-end', async () => {
    const result = await inngest.send({
      name: 'order/created',
      data: testOrder,
    });
    
    // Wait for processing
    await waitForWorkflow(result.ids[0]);
    
    // Verify database state
    const order = await db.order.findUnique({
      where: { id: testOrder.id }
    });
    expect(order.status).toBe('processed');
  });
});
```

### Pattern 3: Performance Test

```typescript
describe('Performance Tests', () => {
  it('should handle 100 concurrent workflows', async () => {
    const events = Array.from({ length: 100 }, (_, i) => ({
      name: 'test/event',
      data: { id: `test-${i}` },
    }));
    
    const startTime = Date.now();
    const results = await Promise.all(
      events.map(e => inngest.send(e))
    );
    const duration = Date.now() - startTime;
    
    expect(results.length).toBe(100);
    expect(duration).toBeLessThan(5000);
    console.log(`Processed 100 events in ${duration}ms`);
  });
});
```

---

## D.6 Deployment Patterns

### Pattern 1: Blue-Green Deployment

```typescript
// Use versioned functions
export const workflowV1 = inngest.createFunction(
  { id: 'my-workflow', version: '1.0.0' },
  { event: 'workflow/trigger' },
  async ({ event, step }) => {
    // Version 1 implementation
  }
);

export const workflowV2 = inngest.createFunction(
  { id: 'my-workflow', version: '2.0.0' },
  { event: 'workflow/trigger' },
  async ({ event, step }) => {
    // Version 2 implementation
  }
);

// Register both versions
serve({
  client: inngest,
  functions: [workflowV1, workflowV2],
});
```

### Pattern 2: Canary Deployment

```typescript
// Route events based on user ID or feature flag
export const canaryWorkflow = inngest.createFunction(
  { id: 'canary-workflow' },
  { event: 'feature/request' },
  async ({ event, step }) => {
    const userId = event.data.userId;
    const rollPercentage = 10; // 10% to new version
    
    const shouldUseNewVersion = parseInt(userId.slice(-2), 16) % 100 < rollPercentage;
    
    if (shouldUseNewVersion) {
      return await newFeature(event.data);
    } else {
      return await stableFeature(event.data);
    }
  }
);
```

---

## D.7 Monitoring Patterns

### Pattern 1: Structured Logging

```typescript
// Structured log entry
const logEntry = {
  timestamp: new Date().toISOString(),
  level: 'info',
  workflow: 'order-processing',
  runId: context.runId,
  event: {
    name: event.name,
    id: event.id,
  },
  step: 'process-payment',
  data: {
    orderId: orderId,
    amount: amount,
    status: 'success',
  },
  duration: duration,
};

logger.info('Payment processed', logEntry);
```

### Pattern 2: Metrics Collection

```typescript
// Track metrics
const metrics = {
  workflow: {
    name: 'order-processing',
    status: result.success ? 'success' : 'failed',
    duration: endTime - startTime,
  },
  step: {
    name: 'process-payment',
    duration: stepDuration,
    retries: retryCount,
  },
  business: {
    orderId: orderId,
    amount: amount,
    items: itemCount,
  },
};

// Send to monitoring service
await monitoringService.record(metrics);
```

---

## D.8 Anti-Patterns to Avoid

### Anti-Pattern 1: Giant Step

```typescript
// ❌ Giant step doing everything
const result = await step.run('process-everything', async () => {
  // 100+ lines of code
  // Multiple API calls
  // Database operations
  // File processing
  // Email sending
  // ALL IN ONE STEP
});

// ✅ Break into smaller steps
const user = await step.run('get-user', () => getUser());
const order = await step.run('create-order', () => createOrder(user));
const payment = await step.run('process-payment', () => processPayment(order));
await step.run('send-notification', () => sendNotification(order));
```

### Anti-Pattern 2: Excessive State

```typescript
// ❌ Storing everything
const state = await step.run('get-state', async () => {
  return {
    user: await getUser(),
    orders: await getOrders(),
    profile: await getProfile(),
    history: await getHistory(),
    settings: await getSettings(),
    preferences: await getPreferences(),
    // ... 1000s of records
  };
});

// ✅ Store only what's needed
const state = await step.run('get-state', async () => {
  return {
    userId: userId,
    email: userEmail,
    plan: planId,
    // Everything else accessed on demand
  };
});
```

### Anti-Pattern 3: Ignoring Idempotency

```typescript
// ❌ Not idempotent
await step.run('process-order', async () => {
  await chargeCard(orderId, amount);
  await updateInventory(orderId);
  await sendEmail(orderId);
});

// ✅ Idempotent
await step.run('process-order', async () => {
  const idempotencyKey = `order-${orderId}`;
  
  // Check if already processed
  const existing = await db.processing.findUnique({
    where: { idempotencyKey }
  });
  if (existing) return existing;
  
  // Process with idempotency
  await chargeCard(orderId, amount);
  await updateInventory(orderId);
  await sendEmail(orderId);
  
  // Record processing
  await db.processing.create({
    data: { idempotencyKey, status: 'completed' }
  });
});
```

---

## D.9 Design Decision Checklist

Before implementing a workflow, consider these questions:

### Is This Right for Durable Execution?
- [ ] Does the process take more than a few seconds?
- [ ] Does it involve multiple external services?
- [ ] Does it need to survive crashes or restarts?
- [ ] Is there a need for retry logic?
- [ ] Does it involve human interaction?

### Is the Step Design Correct?
- [ ] Are steps properly isolated?
- [ ] Are steps idempotent?
- [ ] Is state minimal and deterministic?
- [ ] Are error paths handled?
- [ ] Are compensating actions defined?

### Is Performance Considered?
- [ ] Can steps run in parallel?
- [ ] Are there appropriate concurrency limits?
- [ ] Is caching used where appropriate?
- [ ] Are database queries optimized?
- [ ] Is batch size appropriate?

### Is Security Addressed?
- [ ] Are events signed and verified?
- [ ] Are secrets properly stored?
- [ ] Is input validated?
- [ ] Is output sanitized?
- [ ] Are rate limits configured?

### Is Monitoring in Place?
- [ ] Are errors logged?
- [ ] Are metrics collected?
- [ ] Is performance tracked?
- [ ] Are alerts configured?
- [ ] Is there a dashboard?

---

This appendix provides a comprehensive reference for designing, implementing, and maintaining production-grade durable workflows. Refer to these patterns and practices as you build and evolve your workflows.
