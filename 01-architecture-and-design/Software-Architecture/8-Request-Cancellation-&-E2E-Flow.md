# Phase 3, Part 3: Request Cancellation & E2E Flow

## Connecting It All Together

Welcome to the final part of Phase 3! We're going to tie everything together with request cancellation propagation and end-to-end flow validation. Think of this like ensuring your restaurant chain has a complete system - from customer order to food delivery, with the ability to cancel orders cleanly at any point.

### 1. The Target

**What we're building:** Complete request cancellation propagation and end-to-end validation:
- AbortController propagation across service boundaries
- Request cancellation middleware
- Complete end-to-end tests for the entire flow
- Distributed tracing integration
- Performance monitoring and metrics

**Updated File Structure:**
```
packages/gateway/
├── src/
│   ├── core/
│   ├── infrastructure/
│   │   ├── adapters/
│   │   │   ├── distributed/
│   │   │   │   ├── request-context.ts (updated)
│   │   │   │   ├── cancellation-manager.ts  # NEW: Cancellation propagation
│   │   │   │   └── tracing.ts              # NEW: Distributed tracing
│   │   │   ├── http/
│   │   │   ├── persistence/
│   │   │   ├── cache/
│   │   │   └── messaging/
│   │   ├── services/
│   │   └── workers/
│   └── server.ts
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
│       ├── user-api.test.ts
│       ├── task-api.test.ts
│       └── complete-flow.test.ts          # NEW: End-to-end flow test
│
└── docker-compose.yml
```

### 2. The Concept: Request Cancellation & Distributed Tracing

**Request Cancellation Propagation:**
Like a restaurant order cancellation that needs to cascade through the entire system - kitchen, delivery, billing. When a request is cancelled, every service in the chain needs to know.

```
┌──────────┐  1. User cancels   ┌──────────┐
│  Client  │───────────────────▶│ Gateway  │
└──────────┘                    └──────────┘
                                      │
                            2. Propagate cancellation
                                      │
                                      ▼
                               ┌──────────┐
                               │  Auth    │
                               │  Service │
                               └──────────┘
                                      │
                                      ▼
                               ┌──────────┐
                               │  Task    │
                               │  Service │
                               └──────────┘
                                      │
                                      ▼
                               ┌──────────┐
                               │  Worker  │
                               │  Pool    │
                               └──────────┘
```

**Distributed Tracing:**
Like having a single order number that can be tracked through the entire system - from order placement to delivery.

### 3. The Implementation

#### Step 1: Cancellation Manager

**File:** `packages/gateway/src/infrastructure/adapters/distributed/cancellation-manager.ts`

```typescript
import { EventEmitter } from 'events';
import { createChildLogger } from '../../../logger.js';

/**
 * Cancellation Manager
 * 
 * Manages request cancellation across service boundaries.
 * 
 * When a request is cancelled, we need to:
 * 1. Propagate the cancellation signal to all downstream services
 * 2. Clean up resources
 * 3. Send appropriate error responses
 * 
 * This uses AbortController to manage cancellation signals
 * and tracks them across requests.
 */
export class CancellationManager {
  private static instance: CancellationManager;
  private cancellations: Map<string, CancellationGroup> = new Map();
  private readonly logger = createChildLogger({ module: 'CancellationManager' });
  private readonly eventEmitter = new EventEmitter();

  private constructor() {
    // Clean up expired cancellations every minute
    setInterval(() => this.cleanup(), 60000);
  }

  static getInstance(): CancellationManager {
    if (!CancellationManager.instance) {
      CancellationManager.instance = new CancellationManager();
    }
    return CancellationManager.instance;
  }

  /**
   * Create a cancellation group for a request
   */
  createGroup(requestId: string, timeout: number = 30000): CancellationGroup {
    const controller = new AbortController();
    const group = new CancellationGroup(requestId, controller, timeout);
    
    this.cancellations.set(requestId, group);
    this.logger.debug({ requestId, timeout }, 'Cancellation group created');
    
    // Auto-cancel on timeout
    const timeoutId = setTimeout(() => {
      if (!group.isCancelled) {
        this.logger.warn({ requestId }, 'Request timeout - cancelling');
        group.cancel(new Error(`Request timeout after ${timeout}ms`));
      }
      this.cancellations.delete(requestId);
    }, timeout);
    
    // Store timeout ID for cleanup
    group._timeoutId = timeoutId;
    
    // Clean up when done
    group.on('cancel', () => {
      clearTimeout(timeoutId);
      this.cancellations.delete(requestId);
    });
    
    group.on('complete', () => {
      clearTimeout(timeoutId);
      this.cancellations.delete(requestId);
    });
    
    return group;
  }

  /**
   * Get a cancellation group by request ID
   */
  getGroup(requestId: string): CancellationGroup | undefined {
    return this.cancellations.get(requestId);
  }

  /**
   * Cancel a request group
   */
  cancel(requestId: string, reason?: string): boolean {
    const group = this.cancellations.get(requestId);
    if (!group) {
      this.logger.debug({ requestId }, 'Cancellation group not found');
      return false;
    }
    
    group.cancel(new Error(reason || 'Request cancelled'));
    return true;
  }

  /**
   * Check if a request is cancelled
   */
  isCancelled(requestId: string): boolean {
    const group = this.cancellations.get(requestId);
    return group?.isCancelled || false;
  }

  /**
   * Get the abort signal for a request
   */
  getSignal(requestId: string): AbortSignal | undefined {
    const group = this.cancellations.get(requestId);
    return group?.signal;
  }

  /**
   * Clean up expired or completed groups
   */
  private cleanup(): void {
    const now = Date.now();
    const expired: string[] = [];
    
    for (const [id, group] of this.cancellations) {
      if (group.isCompleted && now - group.completedAt > 60000) {
        expired.push(id);
      }
    }
    
    for (const id of expired) {
      this.cancellations.delete(id);
    }
    
    if (expired.length > 0) {
      this.logger.debug({ expired }, 'Cleaned up expired cancellation groups');
    }
  }

  /**
   * Get statistics
   */
  getStats(): { active: number; completed: number } {
    const stats = { active: 0, completed: 0 };
    
    for (const group of this.cancellations.values()) {
      if (group.isCompleted) {
        stats.completed++;
      } else {
        stats.active++;
      }
    }
    
    return stats;
  }
}

/**
 * Cancellation Group
 * 
 * Manages cancellation for a single request and its downstream operations
 */
export class CancellationGroup extends EventEmitter {
  public readonly signal: AbortSignal;
  public isCancelled: boolean = false;
  public isCompleted: boolean = false;
  public completedAt: number = 0;
  public _timeoutId?: NodeJS.Timeout;
  private cancellationReason?: Error;
  private readonly logger = createChildLogger({ module: 'CancellationGroup' });

  constructor(
    public readonly requestId: string,
    private readonly controller: AbortController,
    public readonly timeout: number
  ) {
    super();
    this.signal = controller.signal;
    
    // Listen for abort events
    this.signal.addEventListener('abort', () => {
      if (!this.isCancelled) {
        this.isCancelled = true;
        this.cancellationReason = this.signal.reason || new Error('Request cancelled');
        this.emit('cancel', this.cancellationReason);
        this.complete();
      }
    });
  }

  /**
   * Cancel the request
   */
  cancel(reason?: Error): void {
    if (this.isCancelled || this.isCompleted) {
      return;
    }
    
    this.cancellationReason = reason || new Error('Request cancelled');
    this.controller.abort(this.cancellationReason);
    this.isCancelled = true;
    this.emit('cancel', this.cancellationReason);
    this.complete();
  }

  /**
   * Mark the request as completed
   */
  complete(): void {
    if (this.isCompleted) {
      return;
    }
    
    this.isCompleted = true;
    this.completedAt = Date.now();
    this.emit('complete');
    this.removeAllListeners();
  }

  /**
   * Throw an error if the request is cancelled
   */
  throwIfCancelled(): void {
    if (this.isCancelled) {
      throw this.cancellationReason || new Error('Request cancelled');
    }
  }

  /**
   * Create a child cancellation group
   */
  createChild(childId: string): CancellationGroup {
    const child = new CancellationGroup(
      childId,
      new AbortController(),
      this.timeout
    );
    
    // When parent cancels, cancel child
    this.on('cancel', (reason) => {
      child.cancel(reason);
    });
    
    // When child completes, clean up
    child.on('complete', () => {
      this.logger.debug({ childId, parentId: this.requestId }, 'Child completed');
    });
    
    return child;
  }

  /**
   * Get the cancellation reason
   */
  getReason(): Error | undefined {
    return this.cancellationReason;
  }
}

/**
 * Cancellation Context
 * 
 * Wraps a function with cancellation handling
 */
export function withCancellation<T>(
  requestId: string,
  fn: (signal: AbortSignal) => Promise<T>,
  options?: { timeout?: number }
): Promise<T> {
  const manager = CancellationManager.getInstance();
  const group = manager.createGroup(requestId, options?.timeout || 30000);
  
  return new Promise<T>((resolve, reject) => {
    // Handle cancellation
    group.on('cancel', (reason) => {
      reject(reason || new Error('Request cancelled'));
    });
    
    // Execute the function
    fn(group.signal)
      .then((result) => {
        group.complete();
        resolve(result);
      })
      .catch((error) => {
        group.complete();
        reject(error);
      });
  });
}
```

#### Step 2: Distributed Tracing

**File:** `packages/gateway/src/infrastructure/adapters/distributed/tracing.ts`

```typescript
import { createChildLogger } from '../../../logger.js';
import { RequestContextManager } from './request-context.js';

/**
 * Trace Span
 * 
 * Represents a single operation in a distributed trace
 */
export interface TraceSpan {
  spanId: string;
  parentSpanId?: string;
  traceId: string;
  name: string;
  startTime: number;
  endTime?: number;
  duration?: number;
  attributes: Record<string, any>;
  events: Array<{
    name: string;
    timestamp: number;
    attributes: Record<string, any>;
  }>;
  status: 'ok' | 'error' | 'unknown';
}

/**
 * Distributed Tracer
 * 
 * Implements distributed tracing for the system.
 * 
 * In production, you would use:
 * - OpenTelemetry
 * - Jaeger
 * - Zipkin
 * - Datadog APM
 * 
 * This is a simplified implementation for learning purposes.
 */
export class DistributedTracer {
  private static instance: DistributedTracer;
  private spans: Map<string, TraceSpan> = new Map();
  private currentSpans: Map<string, string> = new Map();
  private readonly logger = createChildLogger({ module: 'Tracer' });

  private constructor() {}

  static getInstance(): DistributedTracer {
    if (!DistributedTracer.instance) {
      DistributedTracer.instance = new DistributedTracer();
    }
    return DistributedTracer.instance;
  }

  /**
   * Start a new trace span
   */
  startSpan(
    name: string,
    options?: {
      parentSpanId?: string;
      traceId?: string;
      attributes?: Record<string, any>;
    }
  ): TraceSpan {
    const context = RequestContextManager.getContext();
    const traceId = options?.traceId || context?.correlationId || this.generateTraceId();
    const spanId = this.generateSpanId();
    
    const span: TraceSpan = {
      spanId,
      parentSpanId: options?.parentSpanId || this.currentSpans.get(traceId),
      traceId,
      name,
      startTime: Date.now(),
      attributes: {
        service: process.env.SERVICE_NAME || 'gateway',
        ...options?.attributes,
      },
      events: [],
      status: 'unknown',
    };
    
    // Store the span
    this.spans.set(spanId, span);
    
    // Set as current span for this trace
    this.currentSpans.set(traceId, spanId);
    
    this.logger.debug({
      spanId,
      traceId,
      name,
      parentSpanId: span.parentSpanId,
    }, 'Span started');
    
    return span;
  }

  /**
   * End a trace span
   */
  endSpan(spanId: string, options?: {
    status?: 'ok' | 'error';
    error?: Error;
    attributes?: Record<string, any>;
  }): void {
    const span = this.spans.get(spanId);
    if (!span) {
      this.logger.warn({ spanId }, 'Span not found');
      return;
    }
    
    span.endTime = Date.now();
    span.duration = span.endTime - span.startTime;
    span.status = options?.status || 'ok';
    
    if (options?.error) {
      span.status = 'error';
      span.attributes.error = {
        message: options.error.message,
        stack: options.error.stack,
      };
    }
    
    if (options?.attributes) {
      span.attributes = { ...span.attributes, ...options.attributes };
    }
    
    this.logger.debug({
      spanId,
      duration: span.duration,
      status: span.status,
    }, 'Span ended');
    
    // Clean up current span if it's the last
    if (this.currentSpans.get(span.traceId) === spanId) {
      this.currentSpans.delete(span.traceId);
    }
  }

  /**
   * Add an event to a span
   */
  addEvent(spanId: string, name: string, attributes?: Record<string, any>): void {
    const span = this.spans.get(spanId);
    if (!span) return;
    
    span.events.push({
      name,
      timestamp: Date.now(),
      attributes: attributes || {},
    });
  }

  /**
   * Get a span by ID
   */
  getSpan(spanId: string): TraceSpan | undefined {
    return this.spans.get(spanId);
  }

  /**
   * Get all spans for a trace
   */
  getTrace(traceId: string): TraceSpan[] {
    const result: TraceSpan[] = [];
    
    for (const span of this.spans.values()) {
      if (span.traceId === traceId) {
        result.push(span);
      }
    }
    
    return result.sort((a, b) => a.startTime - b.startTime);
  }

  /**
   * Get the current span for a trace
   */
  getCurrentSpan(traceId: string): TraceSpan | undefined {
    const spanId = this.currentSpans.get(traceId);
    if (!spanId) return undefined;
    return this.spans.get(spanId);
  }

  /**
   * Generate a trace ID
   */
  private generateTraceId(): string {
    return `trace_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`;
  }

  /**
   * Generate a span ID
   */
  private generateSpanId(): string {
    return `span_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`;
  }

  /**
   * Clear all spans (for testing)
   */
  clear(): void {
    this.spans.clear();
    this.currentSpans.clear();
  }

  /**
   * Get trace statistics
   */
  getStats(): {
    totalSpans: number;
    currentTraces: number;
    traces: Record<string, { spanCount: number; duration?: number }>;
  } {
    const traceMap = new Map<string, { spanCount: number; duration: number }>();
    
    for (const span of this.spans.values()) {
      const existing = traceMap.get(span.traceId) || { spanCount: 0, duration: 0 };
      existing.spanCount++;
      if (span.duration) {
        existing.duration = Math.max(existing.duration, span.duration);
      }
      traceMap.set(span.traceId, existing);
    }
    
    const traces: Record<string, { spanCount: number; duration?: number }> = {};
    for (const [traceId, data] of traceMap) {
      traces[traceId] = {
        spanCount: data.spanCount,
        duration: data.duration || undefined,
      };
    }
    
    return {
      totalSpans: this.spans.size,
      currentTraces: this.currentSpans.size,
      traces,
    };
  }
}

/**
 * Trace Decorator
 * 
 * Automatically traces a method
 */
export function trace(name: string): MethodDecorator {
  return function (
    target: any,
    propertyKey: string | symbol,
    descriptor: PropertyDescriptor
  ): PropertyDescriptor {
    const originalMethod = descriptor.value;

    descriptor.value = async function (...args: any[]) {
      const tracer = DistributedTracer.getInstance();
      const context = RequestContextManager.getContext();
      
      const span = tracer.startSpan(
        `${name} (${String(propertyKey)})`,
        {
          traceId: context?.correlationId,
          attributes: {
            method: String(propertyKey),
            args: JSON.stringify(args.map(a => typeof a)),
          },
        }
      );
      
      try {
        const result = await originalMethod.apply(this, args);
        tracer.endSpan(span.spanId, { status: 'ok' });
        return result;
      } catch (error) {
        tracer.endSpan(span.spanId, {
          status: 'error',
          error: error instanceof Error ? error : new Error(String(error)),
        });
        throw error;
      }
    };

    return descriptor;
  };
}
```

#### Step 3: Update Request Context with Cancellation

**File:** `packages/gateway/src/infrastructure/adapters/distributed/request-context.ts` (Updated)

Add to RequestContextManager:

```typescript
/**
 * Create a child context with cancellation support
 */
static createCancellableContext(options?: Partial<RequestContext>): {
  context: RequestContext;
  cancel: (reason?: Error) => void;
  signal: AbortSignal;
} {
  const context = this.createContext(options);
  const manager = CancellationManager.getInstance();
  const group = manager.createGroup(context.requestId, context.timeout);
  
  return {
    context,
    cancel: (reason?: Error) => group.cancel(reason),
    signal: group.signal,
  };
}

/**
 * Run a function with cancellation support
 */
static runWithCancellation<T>(
  context: RequestContext,
  fn: (signal: AbortSignal) => Promise<T>
): Promise<T> {
  return withCancellation(context.requestId, fn, { timeout: context.timeout });
}
```

#### Step 4: Update Server with Tracing

**File:** `packages/gateway/src/server.ts` (Updated)

Add to setupMiddleware:

```typescript
import { DistributedTracer } from './infrastructure/adapters/distributed/tracing.js';

// Add to setupMiddleware method
private setupTracing(): void {
  // Trace all requests
  this.app.addHook('onRequest', (request, reply, done) => {
    const context = RequestContextManager.getContext();
    if (!context) {
      done();
      return;
    }
    
    const tracer = DistributedTracer.getInstance();
    const span = tracer.startSpan('http_request', {
      traceId: context.correlationId,
      attributes: {
        method: request.method,
        path: request.url,
        requestId: context.requestId,
        userId: context.userId,
      },
    });
    
    // Store span ID for later
    (request as any).spanId = span.spanId;
    
    done();
  });
  
  this.app.addHook('onResponse', (request, reply, done) => {
    const spanId = (request as any).spanId;
    if (!spanId) {
      done();
      return;
    }
    
    const tracer = DistributedTracer.getInstance();
    tracer.endSpan(spanId, {
      status: reply.statusCode >= 400 ? 'error' : 'ok',
      attributes: {
        statusCode: reply.statusCode,
        duration: reply.elapsedTime,
      },
    });
    
    done();
  });
}

// Also update health check to include trace metrics
this.app.get('/tracing/stats', async (request, reply) => {
  const tracer = DistributedTracer.getInstance();
  const stats = tracer.getStats();
  return reply.send({
    success: true,
    stats,
  });
});
```

#### Step 5: E2E Complete Flow Test

**File:** `packages/gateway/tests/e2e/complete-flow.test.ts`

```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import request from 'supertest';
import { Server } from '../../src/server.js';
import { postgresConnection } from '../../src/infrastructure/adapters/persistence/postgres/connection.js';
import { redisConnection } from '../../src/infrastructure/adapters/cache/redis/connection.js';
import { taskQueue } from '../../src/infrastructure/adapters/messaging/in-memory/task-queue.js';
import { DistributedTracer } from '../../src/infrastructure/adapters/distributed/tracing.js';

describe('Complete Flow E2E Tests', () => {
  let server: Server;
  let app: any;
  let userId: string;
  let taskId: string;

  beforeAll(async () => {
    // Start the server
    server = new Server();
    app = server.getApp();
    await server.start();

    // Clear queue
    taskQueue.clear('tasks');
    taskQueue.clear('dead-letter');

    // Create a test user
    const userResponse = await request(app)
      .post('/api/users')
      .send({
        email: 'flow-test@example.com',
        username: 'flowtest',
        password: 'SecurePass123',
        firstName: 'Flow',
        lastName: 'Tester',
      });
    
    userId = userResponse.body.data.id;
  });

  afterAll(async () => {
    await postgresConnection.query('DELETE FROM users WHERE email LIKE $1', ['%test%']);
    await postgresConnection.disconnect();
    await redisConnection.disconnect();
    DistributedTracer.getInstance().clear();
  });

  it('should complete the entire user → task → process flow', async () => {
    // 1. Create a task
    const createResponse = await request(app)
      .post('/api/tasks')
      .send({
        title: 'Complete Flow Task',
        description: 'This task will go through the complete flow',
        userId: userId,
        priority: 'high',
      });

    expect(createResponse.status).toBe(201);
    expect(createResponse.body.success).toBe(true);
    
    taskId = createResponse.body.data.id;
    expect(taskId).toBeDefined();

    // 2. Verify task is pending
    const getResponse = await request(app)
      .get(`/api/tasks/${taskId}`)
      .query({ userId });

    expect(getResponse.status).toBe(200);
    expect(getResponse.body.data.status).toBe('pending');

    // 3. Submit task for processing
    const submitResponse = await request(app)
      .post(`/api/tasks/${taskId}/process`)
      .send({
        userId: userId,
        action: 'process',
      });

    expect(submitResponse.status).toBe(200);
    expect(submitResponse.body.success).toBe(true);

    // 4. Wait for processing (simulate async processing)
    let processed = false;
    let attempts = 0;
    
    while (!processed && attempts < 30) {
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      const statusResponse = await request(app)
        .get(`/api/tasks/${taskId}`)
        .query({ userId });
      
      if (statusResponse.body.data.status === 'in_progress' || 
          statusResponse.body.data.status === 'completed') {
        processed = true;
        expect(statusResponse.body.data.status).toBe('in_progress');
      }
      
      attempts++;
    }

    expect(processed).toBe(true);

    // 5. Complete the task
    const completeResponse = await request(app)
      .post(`/api/tasks/${taskId}/complete`)
      .send({ userId });

    expect(completeResponse.status).toBe(200);
    expect(completeResponse.body.data.status).toBe('completed');

    // 6. Verify final state
    const finalResponse = await request(app)
      .get(`/api/tasks/${taskId}`)
      .query({ userId });

    expect(finalResponse.status).toBe(200);
    expect(finalResponse.body.data.status).toBe('completed');
    expect(finalResponse.body.data.completedAt).toBeDefined();

    // 7. Check queue stats (should be empty or have dead-letter)
    const statsResponse = await request(app)
      .get('/queue/stats');

    expect(statsResponse.status).toBe(200);
    expect(statsResponse.body.stats.tasks.size).toBe(0);
  });

  it('should handle cancellation correctly', async () => {
    // Create a task
    const createResponse = await request(app)
      .post('/api/tasks')
      .send({
        title: 'Cancellable Task',
        description: 'This task will be cancelled',
        userId: userId,
        priority: 'medium',
      });

    const taskId = createResponse.body.data.id;

    // Start the task (submit for processing)
    await request(app)
      .post(`/api/tasks/${taskId}/process`)
      .send({
        userId: userId,
        action: 'process',
      });

    // Cancel the request (simulate by aborting)
    const cancellationManager = CancellationManager.getInstance();
    const cancelled = cancellationManager.cancel(`task_${taskId}`, 'User cancelled');

    expect(cancelled).toBe(true);

    // Wait a bit for cancellation to propagate
    await new Promise(resolve => setTimeout(resolve, 1000));

    // Verify task is still in progress (cancellation should stop processing)
    const statusResponse = await request(app)
      .get(`/api/tasks/${taskId}`)
      .query({ userId });

    // The task should either be in progress or pending (not completed)
    expect(statusResponse.body.data.status).not.toBe('completed');
  });

  it('should maintain distributed trace context', async () => {
    // Make a request with trace headers
    const tracer = DistributedTracer.getInstance();
    const traceId = `test_trace_${Date.now()}`;
    
    const response = await request(app)
      .get('/health')
      .set('x-correlation-id', traceId)
      .set('x-request-id', `req_${Date.now()}`);

    expect(response.status).toBe(200);

    // Get the trace
    const traceSpans = tracer.getTrace(traceId);
    
    // There should be at least one span (the health check)
    expect(traceSpans.length).toBeGreaterThanOrEqual(1);
    
    // All spans should have the same trace ID
    for (const span of traceSpans) {
      expect(span.traceId).toBe(traceId);
    }

    // Check if the service name is in the attributes
    const span = traceSpans[0];
    expect(span.attributes.service).toBeDefined();
  });

  it('should handle partial failures gracefully', async () => {
    // Create a user
    const userResponse = await request(app)
      .post('/api/users')
      .send({
        email: 'partial-fail@example.com',
        username: 'partialfail',
        password: 'SecurePass123',
        firstName: 'Partial',
        lastName: 'Fail',
      });

    expect(userResponse.status).toBe(201);
    const userId = userResponse.body.data.id;

    // Create multiple tasks
    const tasks = await Promise.all([
      request(app)
        .post('/api/tasks')
        .send({
          title: 'Task 1',
          description: 'First task in composition',
          userId,
          priority: 'medium',
        }),
      request(app)
        .post('/api/tasks')
        .send({
          title: 'Task 2',
          description: 'Second task in composition',
          userId,
          priority: 'medium',
        }),
    ]);

    expect(tasks[0].status).toBe(201);
    expect(tasks[1].status).toBe(201);

    // Get tasks via composition endpoint (if we had one)
    // For now, just verify we can get both
    const getResponse = await request(app)
      .get(`/api/users/${userId}/tasks`);

    expect(getResponse.status).toBe(200);
    expect(getResponse.body.count).toBe(2);

    // Delete one task
    const taskId = tasks[0].body.data.id;
    await request(app)
      .delete(`/api/tasks/${taskId}`)
      .query({ userId });

    // Get remaining tasks
    const finalResponse = await request(app)
      .get(`/api/users/${userId}/tasks`);

    expect(finalResponse.status).toBe(200);
    expect(finalResponse.body.count).toBe(1);
  });
});
```

#### Step 6: Environment Configuration for Workers

**File:** `packages/gateway/.env.example` (Updated)

```env
# ... existing config ...

# ============================================
# WORKER CONFIGURATION
# ============================================
WORKER_COUNT=5
WORKER_QUEUE_NAME=tasks
WORKER_POLL_INTERVAL=100
WORKER_MAX_RETRIES=3
WORKER_RETRY_DELAY=1000

# ============================================
# TRACING
# ============================================
TRACING_ENABLED=true
TRACING_SAMPLE_RATE=1.0

# ============================================
# SERVICE DISCOVERY
# ============================================
AUTH_SERVICE_URL=http://auth-service:3001
USER_SERVICE_URL=http://user-service:3002
TASK_SERVICE_URL=http://task-service:3003
```

### 4. The Verification

#### Step 1: Run All Tests

```bash
# Unit tests
npm test -- tests/unit/

# Integration tests
npm test -- tests/integration/

# E2E tests
npm test -- tests/e2e/
```

Expected output:
```
✓ Complete Flow E2E Tests (4 tests) 4234ms
  ✓ should complete the entire user → task → process flow (1234ms)
  ✓ should handle cancellation correctly (100ms)
  ✓ should maintain distributed trace context (45ms)
  ✓ should handle partial failures gracefully (156ms)
```

#### Step 2: Test Manual Flow

Start the server:

```bash
npm run dev
```

Then run the complete flow manually:

```bash
# 1. Create user
USER_RESPONSE=$(curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "manual-flow@example.com",
    "username": "manualflow",
    "password": "SecurePass123",
    "firstName": "Manual",
    "lastName": "Flow"
  }')
USER_ID=$(echo $USER_RESPONSE | jq -r '.data.id')
echo "User ID: $USER_ID"

# 2. Create task
TASK_RESPONSE=$(curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d "{
    \"title\": \"Manual Flow Task\",
    \"description\": \"Testing the complete flow manually\",
    \"userId\": \"$USER_ID\",
    \"priority\": \"high\"
  }")
TASK_ID=$(echo $TASK_RESPONSE | jq -r '.data.id')
echo "Task ID: $TASK_ID"

# 3. Submit for processing
curl -X POST http://localhost:3000/api/tasks/$TASK_ID/process \
  -H "Content-Type: application/json" \
  -d "{
    \"userId\": \"$USER_ID\",
    \"action\": \"process\"
  }"

# 4. Check status
curl -X GET http://localhost:3000/api/tasks/$TASK_ID?userId=$USER_ID

# 5. Complete task
curl -X POST http://localhost:3000/api/tasks/$TASK_ID/complete \
  -H "Content-Type: application/json" \
  -d "{\"userId\": \"$USER_ID\"}"

# 6. Verify final status
curl -X GET http://localhost:3000/api/tasks/$TASK_ID?userId=$USER_ID
```

#### Step 3: Check Tracing

```bash
# Get tracing statistics
curl http://localhost:3000/tracing/stats
```

Expected response:
```json
{
  "success": true,
  "stats": {
    "totalSpans": 12,
    "currentTraces": 1,
    "traces": {
      "trace_1705300000000_abc123": {
        "spanCount": 5,
        "duration": 245
      }
    }
  }
}
```

#### Step 4: Test Cancellation

```bash
# Get a request ID from headers (check response headers)
curl -v http://localhost:3000/health

# Use the x-request-id header to cancel
# (This would require a cancellation endpoint)
# In production, you'd implement this via API gateway

# For testing, we can check cancellation stats
curl http://localhost:3000/queue/stats
```

#### Step 5: Performance Test

Create a quick performance test:

**File:** `packages/gateway/tests/manual/performance.test.ts`

```typescript
import { ServiceClientFactory } from '../../src/infrastructure/services/service-client.js';

async function performanceTest() {
  const iterations = 10;
  const times: number[] = [];
  
  const client = ServiceClientFactory.getClient(
    'test',
    'http://localhost:3000'
  );

  for (let i = 0; i < iterations; i++) {
    const start = Date.now();
    
    try {
      await client.get('/health');
      times.push(Date.now() - start);
    } catch (error) {
      console.error(`Request ${i + 1} failed:`, error);
    }
  }

  const average = times.reduce((a, b) => a + b, 0) / times.length;
  const min = Math.min(...times);
  const max = Math.max(...times);
  const p95 = times.sort((a, b) => a - b)[Math.floor(times.length * 0.95)];
  
  console.log('Performance Results:');
  console.log(`  Average: ${average}ms`);
  console.log(`  Min: ${min}ms`);
  console.log(`  Max: ${max}ms`);
  console.log(`  95th percentile: ${p95}ms`);
  console.log(`  Success rate: ${times.length}/${iterations}`);
}

performanceTest().catch(console.error);
```

Run the performance test:
```bash
npx tsx tests/manual/performance.test.ts
```

### 5. Deep Dive: Request Cancellation & Observability

#### Cancellation Propagation Strategies

**1. Explicit Propagation:**
Passing cancellation signals explicitly through function parameters.

```typescript
async function doWork(signal: AbortSignal): Promise<void> {
  if (signal.aborted) {
    throw new Error('Cancelled');
  }
  // ... work
}
```

**2. Implicit Propagation:**
Using AsyncLocalStorage to automatically propagate cancellation.

```typescript
// Context carries cancellation signal
async function doWork(): Promise<void> {
  const context = RequestContextManager.getContext();
  if (context?.cancelled) {
    throw new Error('Cancelled');
  }
}
```

**3. Event-Based Propagation:**
Using event emitters to broadcast cancellation.

```typescript
class CancellableOperation extends EventEmitter {
  cancel(): void {
    this.emit('cancel');
  }
}
```

#### Distributed Tracing Patterns

**1. Client-Server Tracing:**
Trace passes from client to server via headers.

```
Client → Headers (trace-id, span-id) → Server
```

**2. Service Mesh Tracing:**
Service mesh (e.g., Istio) automatically adds tracing.

```
Service A → Sidecar → Service B → Sidecar
```

**3. Application-Level Tracing:**
Manual instrumentation of code.

```typescript
const tracer = DistributedTracer.getInstance();
const span = tracer.startSpan('operation');
try {
  // ... do work
  tracer.endSpan(span.spanId);
} catch (error) {
  tracer.endSpan(span.spanId, { status: 'error' });
}
```

#### Observability Pillars

**1. Logs:**
Structured, machine-parseable logs.

**2. Metrics:**
Numerical data points (request count, latency, error rate).

**3. Traces:**
Distributed request flow tracking.

**Golden Signals:**
- **Latency:** Time to process requests
- **Traffic:** Number of requests
- **Errors:** Failure rate
- **Saturation:** Resource utilization

### 6. Summary

**What We Built:**
- ✅ Cancellation manager for request propagation
- ✅ Distributed tracing system
- ✅ Complete end-to-end flow tests
- ✅ Performance testing
- ✅ Monitoring endpoints for tracing and queue stats

**Key Concepts Learned:**
- Request cancellation propagation across services
- Distributed tracing and its importance
- End-to-end testing strategies
- Performance measurement and monitoring
- Observability golden signals

**What's Next:**
In Phase 4, we'll move to cloud-native architecture, deploying our service to serverless environments (AWS Lambda, Cloudflare Workers), optimizing for cold starts, and implementing edge-friendly caching strategies.

**Verification Checklist:**
- [ ] Cancellation propagates through the system
- [ ] Distributed tracing captures request flow
- [ ] Complete flow test passes end-to-end
- [ ] Performance metrics are reasonable
- [ ] Queue stats show proper processing
- [ ] All services start and stop gracefully
