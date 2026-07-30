# Phase 3, Part 1: Distributed Systems & Concurrency

## From Local Async to Distributed Coordination

Welcome to Phase 3! We're moving from a single-service architecture to distributed systems. Think of this like expanding from a single restaurant to a restaurant chain - suddenly you need to coordinate between multiple locations, handle delivery delays, and manage failures across the entire network.

### 1. The Target

**What we're building:** Distributed coordination patterns for our gateway service:
- API composition pattern (translating `Promise.all` to distributed calls)
- Saga orchestration pattern for distributed transactions
- Circuit breaker pattern for fault tolerance
- Request cancellation propagation across service boundaries
- Distributed timeout and retry management

**Updated File Structure:**
```
packages/gateway/
├── src/
│   ├── core/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   └── application/
│   │       ├── commands/
│   │       ├── queries/
│   │       └── handlers/
│   │
│   ├── infrastructure/
│   │   ├── adapters/
│   │   │   ├── http/
│   │   │   ├── persistence/
│   │   │   ├── cache/
│   │   │   └── distributed/          # NEW: Distributed patterns
│   │   │       ├── api-composition.ts
│   │   │       ├── saga-orchestrator.ts
│   │   │       ├── circuit-breaker.ts
│   │   │       ├── retry-manager.ts
│   │   │       └── request-context.ts
│   │   └── di/
│   │       └── container.ts
│   │
│   └── server.ts
│
└── tests/
    ├── unit/
    ├── integration/
    └── e2e/
```

### 2. The Concept: Distributed Patterns

Think of each pattern as a different way to manage a complex operation across multiple services:

**API Composition (`Promise.all`):**
Like asking multiple department heads for reports simultaneously and combining them.

```
┌─────────┐     ┌──────────┐     ┌──────────┐
│         │     │  User    │     │  Task    │
│ Client  │────▶│  Service │     │  Service │
│         │     └──────────┘     └──────────┘
└─────────┘           │                │
                      │                │
                      ▼                ▼
                ┌──────────┐     ┌──────────┐
                │  Email   │     │  Orders  │
                │  Service │     │  Service │
                └──────────┘     └──────────┘
```

**Saga Pattern:**
Like a choreographed dance where each step can be undone if something goes wrong.

```
Step 1: Reserve Inventory → Success ✓
Step 2: Process Payment → Success ✓
Step 3: Create Order → Failed ✗
Step 4: COMPENSATE - Refund Payment
Step 5: COMPENSATE - Release Inventory
```

**Circuit Breaker:**
Like an electrical circuit breaker that prevents overload by stopping requests to a failing service.

```
Closed → Request → Success → Stay Closed
Closed → Request → Failure (3x) → Open
Open → Requests fail immediately (no timeout)
Open → After timeout → Half-Open
Half-Open → Test request → Success → Closed
Half-Open → Test request → Failure → Open
```

### 3. The Implementation

#### Step 1: Request Context Propagation

**File:** `packages/gateway/src/infrastructure/adapters/distributed/request-context.ts`

```typescript
import { AsyncLocalStorage } from 'async_hooks';
import { randomUUID } from 'crypto';

/**
 * Request Context
 * 
 * Propagates context across service boundaries using AsyncLocalStorage.
 * This is critical for distributed tracing and request cancellation.
 * 
 * Think of this as a "carrier pigeon" that carries information about
 * the request through the entire system - even across service boundaries.
 */
export interface RequestContext {
  requestId: string;
  userId?: string;
  correlationId: string;
  startTime: number;
  timeout: number;
  headers: Record<string, string>;
  cancellations: AbortController[];
}

/**
 * Context Manager
 * 
 * Manages request context throughout the request lifecycle.
 * Uses AsyncLocalStorage for automatic context propagation.
 */
export class RequestContextManager {
  private static readonly storage = new AsyncLocalStorage<RequestContext>();
  private static defaultTimeout = 30000; // 30 seconds

  /**
   * Create a new request context
   */
  static createContext(options?: Partial<RequestContext>): RequestContext {
    return {
      requestId: options?.requestId || randomUUID(),
      correlationId: options?.correlationId || randomUUID(),
      startTime: options?.startTime || Date.now(),
      timeout: options?.timeout || this.defaultTimeout,
      headers: options?.headers || {},
      cancellations: options?.cancellations || [],
      userId: options?.userId,
    };
  }

  /**
   * Run a function with a request context
   */
  static run<T>(context: RequestContext, fn: () => T): T {
    return this.storage.run(context, fn);
  }

  /**
   * Get the current request context
   */
  static getContext(): RequestContext | null {
    return this.storage.getStore() || null;
  }

  /**
   * Get the current request ID
   */
  static getRequestId(): string {
    const context = this.getContext();
    return context?.requestId || 'unknown';
  }

  /**
   * Check if the request is cancelled
   */
  static isCancelled(): boolean {
    const context = this.getContext();
    if (!context) return false;
    
    // Check if any cancellation signal is triggered
    return context.cancellations.some(controller => controller.signal.aborted);
  }

  /**
   * Create a timeout for the current request
   */
  static getRemainingTime(): number {
    const context = this.getContext();
    if (!context) return this.defaultTimeout;
    
    const elapsed = Date.now() - context.startTime;
    const remaining = context.timeout - elapsed;
    return Math.max(0, remaining);
  }

  /**
   * Add a cancellation controller
   */
  static addCancellation(controller: AbortController): void {
    const context = this.getContext();
    if (context) {
      context.cancellations.push(controller);
    }
  }

  /**
   * Create an AbortSignal that times out with the request
   */
  static createTimeoutSignal(): AbortSignal {
    const remaining = this.getRemainingTime();
    const controller = new AbortController();
    
    // Add to context for propagation
    this.addCancellation(controller);
    
    // Set timeout
    const timeout = setTimeout(() => {
      controller.abort(new Error('Request timeout'));
    }, remaining);
    
    // Clean up timeout when signal is aborted
    controller.signal.addEventListener('abort', () => {
      clearTimeout(timeout);
    });
    
    return controller.signal;
  }

  /**
   * Get headers for propagation to downstream services
   */
  static getPropagationHeaders(): Record<string, string> {
    const context = this.getContext();
    if (!context) return {};
    
    return {
      'x-request-id': context.requestId,
      'x-correlation-id': context.correlationId,
      'x-user-id': context.userId || '',
      'x-timeout': String(context.timeout),
    };
  }

  /**
   * Create a child context for a downstream request
   */
  static createChildContext(overrides?: Partial<RequestContext>): RequestContext {
    const parent = this.getContext();
    if (!parent) {
      return this.createContext(overrides);
    }
    
    return {
      ...parent,
      ...overrides,
      // Always generate a new request ID for the child
      requestId: overrides?.requestId || randomUUID(),
      // Preserve correlation ID for traceability
      correlationId: parent.correlationId,
    };
  }
}

/**
 * Context Middleware for Fastify
 */
export async function contextMiddleware(
  request: any,
  reply: any
): Promise<void> {
  // Extract headers
  const headers = request.headers as Record<string, string>;
  
  // Create context from request
  const context = RequestContextManager.createContext({
    requestId: headers['x-request-id'] || randomUUID(),
    correlationId: headers['x-correlation-id'] || randomUUID(),
    headers: headers,
    userId: headers['x-user-id'],
    timeout: parseInt(headers['x-timeout'] || '30000'),
  });
  
  // Set response headers for propagation
  reply.header('x-request-id', context.requestId);
  reply.header('x-correlation-id', context.correlationId);
  
  // Run the request with context
  return new Promise((resolve, reject) => {
    RequestContextManager.run(context, () => {
      // Store context in request for later use
      request.requestContext = context;
      resolve();
    });
  });
}
```

#### Step 2: Circuit Breaker Pattern

**File:** `packages/gateway/src/infrastructure/adapters/distributed/circuit-breaker.ts`

```typescript
import { createChildLogger } from '../../../logger.js';

/**
 * Circuit Breaker States
 * 
 * CLOSED: Allowing requests through
 * OPEN: Blocking requests (service is failing)
 * HALF_OPEN: Testing if service has recovered
 */
export enum CircuitBreakerState {
  CLOSED = 'closed',
  OPEN = 'open',
  HALF_OPEN = 'half_open',
}

/**
 * Circuit Breaker Configuration
 */
export interface CircuitBreakerConfig {
  /** Number of failures before opening the circuit */
  failureThreshold: number;
  
  /** Time in milliseconds to wait before trying again */
  resetTimeout: number;
  
  /** Number of requests in half-open state to test */
  halfOpenRequests: number;
  
  /** Timeout for a single operation in milliseconds */
  operationTimeout: number;
}

/**
 * Circuit Breaker
 * 
 * Prevents cascading failures by stopping requests to a failing service.
 * 
 * How it works:
 * 1. CLOSED: Requests flow through, failures are counted
 * 2. If failures exceed threshold → OPEN
 * 3. OPEN: All requests fail immediately (fast fail)
 * 4. After timeout → HALF_OPEN
 * 5. HALF_OPEN: Limited requests allowed through
 * 6. If successful → CLOSED, if fails → OPEN
 */
export class CircuitBreaker {
  private state: CircuitBreakerState = CircuitBreakerState.CLOSED;
  private failureCount = 0;
  private lastFailureTime: number = 0;
  private halfOpenCount = 0;
  private readonly logger = createChildLogger({ module: 'CircuitBreaker' });
  
  constructor(
    private readonly name: string,
    private readonly config: Partial<CircuitBreakerConfig> = {}
  ) {
    this.config = {
      failureThreshold: 5,
      resetTimeout: 60000, // 1 minute
      halfOpenRequests: 3,
      operationTimeout: 10000, // 10 seconds
      ...config,
    };
  }

  /**
   * Execute an operation with circuit breaker protection
   */
  async execute<T>(
    operation: (signal?: AbortSignal) => Promise<T>,
    signal?: AbortSignal
  ): Promise<T> {
    // Check current state
    this.checkState();
    
    if (this.state === CircuitBreakerState.OPEN) {
      throw new Error(`Circuit breaker '${this.name}' is OPEN`);
    }
    
    // Abort if signal is already aborted
    if (signal?.aborted) {
      throw new Error(`Request cancelled: ${signal.reason}`);
    }
    
    // Create timeout for operation
    const timeoutController = new AbortController();
    const timeout = setTimeout(() => {
      timeoutController.abort(new Error(`Operation timed out after ${this.config.operationTimeout}ms`));
    }, this.config.operationTimeout);
    
    // Combine signals
    const combinedSignal = this.combineSignals(signal, timeoutController.signal);
    
    try {
      const result = await operation(combinedSignal);
      
      // Operation successful
      this.onSuccess();
      
      return result;
    } catch (error) {
      // Operation failed
      const isTimeout = error instanceof Error && error.message.includes('timed out');
      const isCancelled = error instanceof Error && error.message.includes('cancelled');
      
      // Only count timeouts and errors as failures, not cancellations
      if (!isCancelled) {
        this.onFailure(isTimeout);
      }
      
      throw error;
    } finally {
      clearTimeout(timeout);
    }
  }

  /**
   * Check and update circuit state
   */
  private checkState(): void {
    if (this.state === CircuitBreakerState.OPEN) {
      // Check if reset timeout has elapsed
      const timeSinceLastFailure = Date.now() - this.lastFailureTime;
      if (timeSinceLastFailure >= (this.config.resetTimeout || 60000)) {
        this.logger.info({ circuit: this.name }, 'Circuit breaker: OPEN → HALF_OPEN');
        this.state = CircuitBreakerState.HALF_OPEN;
        this.halfOpenCount = 0;
      }
    }
  }

  /**
   * Handle successful operation
   */
  private onSuccess(): void {
    if (this.state === CircuitBreakerState.HALF_OPEN) {
      this.halfOpenCount++;
      
      // If enough half-open requests succeed, close the circuit
      if (this.halfOpenCount >= (this.config.halfOpenRequests || 3)) {
        this.logger.info({ circuit: this.name }, 'Circuit breaker: HALF_OPEN → CLOSED');
        this.state = CircuitBreakerState.CLOSED;
        this.failureCount = 0;
      }
    } else if (this.state === CircuitBreakerState.CLOSED) {
      // Reset failure count on success
      this.failureCount = Math.max(0, this.failureCount - 1);
    }
  }

  /**
   * Handle failed operation
   */
  private onFailure(isTimeout: boolean): void {
    if (this.state === CircuitBreakerState.HALF_OPEN) {
      // Failure in half-open state: immediately open the circuit
      this.logger.warn({ circuit: this.name }, 'Circuit breaker: HALF_OPEN → OPEN');
      this.state = CircuitBreakerState.OPEN;
      this.lastFailureTime = Date.now();
      this.failureCount = (this.config.failureThreshold || 5);
      return;
    }
    
    if (this.state === CircuitBreakerState.CLOSED) {
      this.failureCount++;
      this.lastFailureTime = Date.now();
      
      const threshold = this.config.failureThreshold || 5;
      
      this.logger.debug({
        circuit: this.name,
        failureCount: this.failureCount,
        threshold,
      }, 'Circuit breaker failure recorded');
      
      // Check if failure threshold is reached
      if (this.failureCount >= threshold) {
        this.logger.warn({ circuit: this.name }, 'Circuit breaker: CLOSED → OPEN');
        this.state = CircuitBreakerState.OPEN;
      }
    }
  }

  /**
   * Combine multiple AbortSignals
   */
  private combineSignals(...signals: (AbortSignal | undefined)[]): AbortSignal {
    const controller = new AbortController();
    
    for (const signal of signals) {
      if (!signal) continue;
      
      if (signal.aborted) {
        controller.abort(signal.reason);
        return controller.signal;
      }
      
      signal.addEventListener('abort', () => {
        controller.abort(signal.reason);
      });
    }
    
    return controller.signal;
  }

  /**
   * Get circuit breaker state
   */
  getState(): CircuitBreakerState {
    this.checkState();
    return this.state;
  }

  /**
   * Get metrics
   */
  getMetrics() {
    return {
      name: this.name,
      state: this.state,
      failureCount: this.failureCount,
      lastFailureTime: this.lastFailureTime,
      halfOpenCount: this.halfOpenCount,
    };
  }

  /**
   * Reset the circuit breaker
   */
  reset(): void {
    this.state = CircuitBreakerState.CLOSED;
    this.failureCount = 0;
    this.lastFailureTime = 0;
    this.halfOpenCount = 0;
    this.logger.info({ circuit: this.name }, 'Circuit breaker reset');
  }
}

/**
 * Circuit Breaker Registry
 * 
 * Manages multiple circuit breakers by service name
 */
export class CircuitBreakerRegistry {
  private static instance: CircuitBreakerRegistry;
  private breakers: Map<string, CircuitBreaker> = new Map();

  private constructor() {}

  static getInstance(): CircuitBreakerRegistry {
    if (!CircuitBreakerRegistry.instance) {
      CircuitBreakerRegistry.instance = new CircuitBreakerRegistry();
    }
    return CircuitBreakerRegistry.instance;
  }

  /**
   * Get or create a circuit breaker
   */
  getOrCreate(
    name: string,
    config?: Partial<CircuitBreakerConfig>
  ): CircuitBreaker {
    if (!this.breakers.has(name)) {
      this.breakers.set(name, new CircuitBreaker(name, config));
    }
    return this.breakers.get(name)!;
  }

  /**
   * Get all circuit breaker metrics
   */
  getAllMetrics() {
    const metrics: Record<string, any> = {};
    for (const [name, breaker] of this.breakers) {
      metrics[name] = breaker.getMetrics();
    }
    return metrics;
  }

  /**
   * Reset all circuit breakers
   */
  resetAll(): void {
    for (const breaker of this.breakers.values()) {
      breaker.reset();
    }
  }
}
```

#### Step 3: Retry Manager

**File:** `packages/gateway/src/infrastructure/adapters/distributed/retry-manager.ts`

```typescript
import { createChildLogger } from '../../../logger.js';

/**
 * Retry Configuration
 */
export interface RetryConfig {
  /** Maximum number of retry attempts */
  maxAttempts: number;
  
  /** Initial delay in milliseconds */
  initialDelay: number;
  
  /** Maximum delay in milliseconds */
  maxDelay: number;
  
  /** Backoff multiplier (e.g., 2 for exponential) */
  backoffMultiplier: number;
  
  /** Whether to use jitter to prevent thundering herd */
  useJitter: boolean;
  
  /** Which errors to retry on */
  retryableErrors?: Array<new (...args: any[]) => Error>;
}

/**
 * Retry Manager
 * 
 * Implements retry logic with exponential backoff and jitter.
 * 
 * Exponential Backoff: Delay increases exponentially with each retry
 * Jitter: Random variation to prevent multiple clients retrying simultaneously
 */
export class RetryManager {
  private readonly logger = createChildLogger({ module: 'RetryManager' });

  constructor(private readonly config: RetryConfig = {
    maxAttempts: 3,
    initialDelay: 1000,
    maxDelay: 30000,
    backoffMultiplier: 2,
    useJitter: true,
  }) {}

  /**
   * Execute an operation with retries
   */
  async execute<T>(
    operation: () => Promise<T>,
    context?: Record<string, unknown>
  ): Promise<T> {
    let lastError: Error | null = null;
    let attempt = 0;

    while (attempt < this.config.maxAttempts) {
      attempt++;
      
      try {
        this.logger.debug({
          attempt,
          maxAttempts: this.config.maxAttempts,
          ...context,
        }, 'Executing operation with retry');
        
        return await operation();
      } catch (error) {
        lastError = error instanceof Error ? error : new Error(String(error));
        
        // Check if error is retryable
        if (!this.isRetryableError(lastError)) {
          this.logger.debug({
            error: lastError.message,
            attempt,
          }, 'Non-retryable error, stopping');
          throw lastError;
        }
        
        // Check if this was the last attempt
        if (attempt >= this.config.maxAttempts) {
          this.logger.warn({
            error: lastError.message,
            attempts: attempt,
            ...context,
          }, 'All retry attempts exhausted');
          throw lastError;
        }
        
        // Calculate delay with backoff
        const delay = this.calculateDelay(attempt, lastError);
        
        this.logger.debug({
          attempt,
          delay,
          nextAttempt: attempt + 1,
          error: lastError.message,
          ...context,
        }, 'Retrying after delay');
        
        // Wait before next attempt
        await this.sleep(delay);
      }
    }

    // Should never reach here, but TypeScript needs it
    throw lastError || new Error('Retry failed');
  }

  /**
   * Calculate delay with exponential backoff and jitter
   */
  private calculateDelay(attempt: number, error: Error): number {
    // Base exponential backoff
    let delay = this.config.initialDelay * Math.pow(this.config.backoffMultiplier, attempt - 1);
    
    // Cap at max delay
    delay = Math.min(delay, this.config.maxDelay);
    
    // Add jitter if enabled (random ±20%)
    if (this.config.useJitter) {
      const jitter = 0.8 + (Math.random() * 0.4); // 0.8 to 1.2
      delay = delay * jitter;
    }
    
    return Math.round(delay);
  }

  /**
   * Check if an error is retryable
   */
  private isRetryableError(error: Error): boolean {
    // Check if error matches retryable error types
    if (this.config.retryableErrors) {
      for (const ErrorType of this.config.retryableErrors) {
        if (error instanceof ErrorType) {
          return true;
        }
      }
    }
    
    // Retry on network errors and timeouts
    const message = error.message.toLowerCase();
    if (
      message.includes('timeout') ||
      message.includes('connection') ||
      message.includes('network') ||
      message.includes('econnreset') ||
      message.includes('econnrefused')
    ) {
      return true;
    }
    
    // Don't retry on validation errors (4xx) or permission errors
    if (message.includes('validation') ||
        message.includes('unauthorized') ||
        message.includes('forbidden') ||
        message.includes('not found')) {
      return false;
    }
    
    // Default to retry for unknown errors
    return true;
  }

  /**
   * Sleep for a specified duration
   */
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

/**
 * Decorator for automatic retry
 * 
 * Usage: @retry({ maxAttempts: 3 })
 */
export function retry(config?: Partial<RetryConfig>) {
  const manager = new RetryManager({
    maxAttempts: 3,
    initialDelay: 1000,
    maxDelay: 30000,
    backoffMultiplier: 2,
    useJitter: true,
    ...config,
  });

  return function (
    target: any,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ) {
    const originalMethod = descriptor.value;

    descriptor.value = async function (...args: any[]) {
      return manager.execute(
        () => originalMethod.apply(this, args),
        { method: propertyKey }
      );
    };

    return descriptor;
  };
}
```

#### Step 4: API Composition Pattern

**File:** `packages/gateway/src/infrastructure/adapters/distributed/api-composition.ts`

```typescript
import { RequestContextManager } from './request-context.js';
import { CircuitBreakerRegistry } from './circuit-breaker.js';
import { RetryManager } from './retry-manager.js';
import { createChildLogger } from '../../../logger.js';

/**
 * API Composition Service
 * 
 * Implements the API Composition pattern.
 * Translates local Promise.all to distributed service calls.
 * 
 * Instead of making sequential calls to multiple services,
 * we compose the response from multiple parallel calls.
 */
export class ApiCompositionService {
  private readonly logger = createChildLogger({ module: 'ApiCompositionService' });
  private readonly retryManager = new RetryManager();
  private readonly circuitBreakerRegistry = CircuitBreakerRegistry.getInstance();

  /**
   * Compose a response from multiple API calls
   * 
   * This is the distributed equivalent of Promise.all
   */
  async compose<T extends Record<string, any>>(
    calls: {
      [K in keyof T]: () => Promise<T[K]>
    },
    options?: {
      requireAll?: boolean;
      timeout?: number;
    }
  ): Promise<Partial<T>> {
    const startTime = Date.now();
    const timeout = options?.timeout || RequestContextManager.getRemainingTime() || 30000;

    this.logger.debug({
      serviceCount: Object.keys(calls).length,
      timeout,
      requireAll: options?.requireAll,
    }, 'Composing API calls');

    // Create abort signal with timeout
    const abortController = new AbortController();
    const timeoutId = setTimeout(() => {
      abortController.abort(new Error('API composition timeout'));
    }, timeout);

    try {
      // Execute all calls in parallel
      const results = await this.executeAllWithTimeout(
        calls,
        abortController.signal,
        timeout
      );

      // Handle partial failures
      const result = {} as Partial<T>;
      const failures: string[] = [];

      for (const [key, value] of Object.entries(results)) {
        if (value instanceof Error) {
          failures.push(key);
          if (options?.requireAll) {
            throw new Error(`Required API call failed: ${key} - ${value.message}`);
          }
        } else {
          result[key as keyof T] = value;
        }
      }

      // Log partial failures
      if (failures.length > 0) {
        this.logger.warn({
          failures,
          totalCalls: Object.keys(calls).length,
          duration: Date.now() - startTime,
        }, 'API composition completed with partial failures');
      } else {
        this.logger.debug({
          callCount: Object.keys(calls).length,
          duration: Date.now() - startTime,
        }, 'API composition completed successfully');
      }

      return result;
    } finally {
      clearTimeout(timeoutId);
    }
  }

  /**
   * Execute all calls with timeout handling
   */
  private async executeAllWithTimeout<T extends Record<string, any>>(
    calls: T,
    signal: AbortSignal,
    timeout: number
  ): Promise<{ [K in keyof T]: T[K] | Error }> {
    const results = {} as { [K in keyof T]: T[K] | Error };
    const keys = Object.keys(calls) as (keyof T)[];

    // Create a promise for each call
    const promises = keys.map(async (key) => {
      try {
        // Check if already aborted
        if (signal.aborted) {
          results[key] = new Error('Request aborted');
          return;
        }

        // Execute the call with circuit breaker and retry
        const serviceName = String(key);
        const circuitBreaker = this.circuitBreakerRegistry.getOrCreate(serviceName);
        
        const result = await circuitBreaker.execute(async (cbSignal) => {
          // Combine signals
          const combinedSignal = this.combineSignals(signal, cbSignal);
          
          // Execute with retry
          return await this.retryManager.execute(async () => {
            if (combinedSignal.aborted) {
              throw new Error('Request cancelled');
            }
            return await calls[key]();
          }, { service: serviceName });
        }, signal);

        results[key] = result;
      } catch (error) {
        results[key] = error instanceof Error ? error : new Error(String(error));
      }
    });

    // Wait for all promises to complete (or timeout)
    await Promise.allSettled(promises);

    return results;
  }

  /**
   * Combine multiple AbortSignals
   */
  private combineSignals(...signals: (AbortSignal | undefined)[]): AbortSignal {
    const controller = new AbortController();
    
    for (const signal of signals) {
      if (!signal) continue;
      
      if (signal.aborted) {
        controller.abort(signal.reason);
        return controller.signal;
      }
      
      signal.addEventListener('abort', () => {
        controller.abort(signal.reason);
      });
    }
    
    return controller.signal;
  }

  /**
   * Create a typed API composition call
   * 
   * Example:
   * const result = await apiComposition.composeTyped({
   *   user: () => userService.getUser(userId),
   *   tasks: () => taskService.getUserTasks(userId),
   *   stats: () => statsService.getUserStats(userId),
   * });
   */
  async composeTyped<T extends Record<string, any>>(
    calls: {
      [K in keyof T]: () => Promise<T[K]>
    },
    options?: {
      requireAll?: boolean;
      timeout?: number;
    }
  ): Promise<Partial<T>> {
    return this.compose(calls, options);
  }
}

// Singleton instance
export const apiComposition = new ApiCompositionService();
```

#### Step 5: Saga Orchestrator

**File:** `packages/gateway/src/infrastructure/adapters/distributed/saga-orchestrator.ts`

```typescript
import { createChildLogger } from '../../../logger.js';
import { RequestContextManager } from './request-context.js';
import { RetryManager } from './retry-manager.js';

/**
 * Saga Step
 * 
 * A single step in a saga transaction
 */
export interface SagaStep<T = any> {
  /** Step identifier */
  name: string;
  
  /** Execute the step (forward operation) */
  execute: (context: T) => Promise<void>;
  
  /** Compensate the step (rollback operation) */
  compensate: (context: T) => Promise<void>;
  
  /** Whether this step is required (can't be skipped on failure) */
  required?: boolean;
  
  /** Maximum retries for this step */
  maxRetries?: number;
}

/**
 * Saga Context
 * 
 * Carries data through the saga execution
 */
export interface SagaContext {
  [key: string]: any;
}

/**
 * Saga Result
 */
export interface SagaResult {
  success: boolean;
  steps: {
    name: string;
    status: 'pending' | 'completed' | 'failed' | 'compensated';
    error?: string;
  }[];
  error?: string;
}

/**
 * Saga Orchestrator
 * 
 * Implements the Saga pattern for distributed transactions.
 * 
 * A saga is a sequence of local transactions where each step
 * has a compensating action to rollback changes if something fails.
 * 
 * There are two approaches:
 * 1. Choreography: Each service publishes events that trigger the next step
 * 2. Orchestration: A central coordinator manages the steps (we're using this)
 */
export class SagaOrchestrator {
  private readonly logger = createChildLogger({ module: 'SagaOrchestrator' });
  private readonly retryManager = new RetryManager();

  /**
   * Execute a saga
   * 
   * Steps are executed in order. If any step fails:
   * - Required steps: Trigger compensation for all completed steps
   * - Non-required steps: Skip the step and continue
   */
  async execute<T extends SagaContext>(
    steps: SagaStep<T>[],
    context: T,
    options?: {
      timeout?: number;
      onStepComplete?: (step: SagaStep<T>, context: T) => void;
      onStepFailed?: (step: SagaStep<T>, context: T, error: Error) => void;
      onCompensated?: (step: SagaStep<T>, context: T, error: Error) => void;
    }
  ): Promise<SagaResult> {
    const result: SagaResult = {
      success: false,
      steps: steps.map(step => ({
        name: step.name,
        status: 'pending',
      })),
    };

    const completedSteps: SagaStep<T>[] = [];
    const timeout = options?.timeout || RequestContextManager.getRemainingTime() || 60000;

    this.logger.info({
      saga: steps.map(s => s.name).join(' → '),
      stepCount: steps.length,
      timeout,
    }, 'Saga execution started');

    try {
      // Create abort signal with timeout
      const abortController = new AbortController();
      const timeoutId = setTimeout(() => {
        abortController.abort(new Error('Saga execution timeout'));
      }, timeout);

      try {
        // Execute each step
        for (let i = 0; i < steps.length; i++) {
          const step = steps[i];
          
          // Check if aborted
          if (abortController.signal.aborted) {
            throw new Error('Saga aborted');
          }

          try {
            this.logger.debug({ step: step.name }, 'Executing saga step');
            
            // Execute step with retries
            const maxRetries = step.maxRetries || 3;
            const retryManager = new RetryManager({
              maxAttempts: maxRetries + 1,
              initialDelay: 1000,
              maxDelay: 30000,
              backoffMultiplier: 2,
              useJitter: true,
            });

            await retryManager.execute(
              () => step.execute(context),
              { step: step.name, saga: steps.map(s => s.name).join(' → ') }
            );

            // Step completed successfully
            completedSteps.push(step);
            result.steps[i].status = 'completed';
            
            if (options?.onStepComplete) {
              options.onStepComplete(step, context);
            }

          } catch (error) {
            const err = error instanceof Error ? error : new Error(String(error));
            
            // Step failed
            result.steps[i].status = 'failed';
            result.steps[i].error = err.message;

            this.logger.error({
              step: step.name,
              error: err.message,
              required: step.required,
            }, 'Saga step failed');

            if (options?.onStepFailed) {
              options.onStepFailed(step, context, err);
            }

            // Check if this is a required step
            if (step.required !== false) {
              // Required step failed - trigger compensation
              this.logger.warn({
                step: step.name,
                completedSteps: completedSteps.map(s => s.name),
              }, 'Required step failed - starting compensation');

              await this.compensate(completedSteps, context, options);
              
              result.success = false;
              result.error = `Required step '${step.name}' failed: ${err.message}`;
              
              clearTimeout(timeoutId);
              return result;
            }

            // Non-required step failed - skip it and continue
            this.logger.info({
              step: step.name,
            }, 'Non-required step failed - skipping');
          }
        }

        // All steps completed successfully
        result.success = true;
        this.logger.info({
          saga: steps.map(s => s.name).join(' → '),
          stepCount: steps.length,
        }, 'Saga execution completed successfully');

        clearTimeout(timeoutId);
        return result;

      } catch (error) {
        clearTimeout(timeoutId);
        throw error;
      }

    } catch (error) {
      const err = error instanceof Error ? error : new Error(String(error));
      
      this.logger.error({
        error: err.message,
        completedSteps: completedSteps.map(s => s.name),
      }, 'Saga execution failed');

      // Trigger compensation for all completed steps
      await this.compensate(completedSteps, context, options);
      
      result.success = false;
      result.error = err.message;
      
      return result;
    }
  }

  /**
   * Compensate completed steps (rollback)
   * 
   * Steps are compensated in reverse order (LIFO)
   */
  private async compensate<T extends SagaContext>(
    completedSteps: SagaStep<T>[],
    context: T,
    options?: {
      onCompensated?: (step: SagaStep<T>, context: T, error: Error) => void;
    }
  ): Promise<void> {
    if (completedSteps.length === 0) {
      this.logger.debug('No steps to compensate');
      return;
    }

    this.logger.info({
      steps: completedSteps.map(s => s.name).join(' ← '),
    }, 'Starting compensation');

    // Compensate in reverse order
    const reverseSteps = [...completedSteps].reverse();

    for (const step of reverseSteps) {
      try {
        this.logger.debug({ step: step.name }, 'Compensating step');
        await step.compensate(context);
        this.logger.debug({ step: step.name }, 'Step compensated');
      } catch (error) {
        const err = error instanceof Error ? error : new Error(String(error));
        
        this.logger.error({
          step: step.name,
          error: err.message,
        }, 'Compensation failed');
        
        if (options?.onCompensated) {
          options.onCompensated(step, context, err);
        }
        
        // Continue compensation even if one fails
        // In production, you might want to log this to an error queue
      }
    }

    this.logger.info('Compensation completed');
  }

  /**
   * Create a saga step
   */
  static step<T extends SagaContext>(
    name: string,
    execute: (context: T) => Promise<void>,
    compensate: (context: T) => Promise<void>,
    options?: {
      required?: boolean;
      maxRetries?: number;
    }
  ): SagaStep<T> {
    return {
      name,
      execute,
      compensate,
      required: options?.required !== false,
      maxRetries: options?.maxRetries || 3,
    };
  }
}
```

### 4. The Verification

Let's test our distributed patterns.

#### Step 1: Install Dependencies

```bash
cd packages/gateway
npm install
```

#### Step 2: Create a Test Saga

**File:** `packages/gateway/tests/unit/saga.test.ts`

```typescript
import { describe, it, expect } from 'vitest';
import { SagaOrchestrator, SagaStep } from '../../src/infrastructure/adapters/distributed/saga-orchestrator.js';

describe('Saga Orchestrator', () => {
  it('should execute a saga successfully', async () => {
    const steps: SagaStep<any>[] = [
      SagaOrchestrator.step(
        'step1',
        async (ctx) => { ctx.step1 = 'done'; },
        async (ctx) => { ctx.step1 = 'compensated'; }
      ),
      SagaOrchestrator.step(
        'step2',
        async (ctx) => { ctx.step2 = 'done'; },
        async (ctx) => { ctx.step2 = 'compensated'; }
      ),
    ];

    const context = {};
    const orchestrator = new SagaOrchestrator();
    const result = await orchestrator.execute(steps, context);

    expect(result.success).toBe(true);
    expect(context).toHaveProperty('step1', 'done');
    expect(context).toHaveProperty('step2', 'done');
    expect(result.steps).toHaveLength(2);
    expect(result.steps[0].status).toBe('completed');
    expect(result.steps[1].status).toBe('completed');
  });

  it('should compensate on failure', async () => {
    const steps: SagaStep<any>[] = [
      SagaOrchestrator.step(
        'step1',
        async (ctx) => { ctx.step1 = 'done'; },
        async (ctx) => { ctx.step1 = 'compensated'; }
      ),
      SagaOrchestrator.step(
        'step2',
        async () => { throw new Error('Step 2 failed'); },
        async (ctx) => { ctx.step2 = 'compensated'; }
      ),
    ];

    const context = {};
    const orchestrator = new SagaOrchestrator();
    const result = await orchestrator.execute(steps, context);

    expect(result.success).toBe(false);
    expect(context).toHaveProperty('step1', 'compensated');
    expect(result.error).toContain('Step 2 failed');
  });
});
```

Run the test:

```bash
npm test -- tests/unit/saga.test.ts
```

#### Step 3: Test Circuit Breaker

Create a test file:

**File:** `packages/gateway/tests/unit/circuit-breaker.test.ts`

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { CircuitBreaker, CircuitBreakerState } from '../../src/infrastructure/adapters/distributed/circuit-breaker.js';

describe('Circuit Breaker', () => {
  let breaker: CircuitBreaker;

  beforeEach(() => {
    breaker = new CircuitBreaker('test', {
      failureThreshold: 3,
      resetTimeout: 1000,
      halfOpenRequests: 2,
      operationTimeout: 1000,
    });
  });

  it('should start in CLOSED state', () => {
    expect(breaker.getState()).toBe(CircuitBreakerState.CLOSED);
  });

  it('should open after failures exceed threshold', async () => {
    const failingOperation = async () => {
      throw new Error('Operation failed');
    };

    // First 3 attempts should fail but keep circuit closed
    await expect(breaker.execute(failingOperation)).rejects.toThrow();
    await expect(breaker.execute(failingOperation)).rejects.toThrow();
    await expect(breaker.execute(failingOperation)).rejects.toThrow();
    
    // Circuit should now be OPEN
    expect(breaker.getState()).toBe(CircuitBreakerState.OPEN);

    // Next attempt should fail immediately without executing
    await expect(breaker.execute(failingOperation)).rejects.toThrow(
      "Circuit breaker 'test' is OPEN"
    );
  });

  it('should allow successful operations', async () => {
    const successfulOperation = async () => 'success';

    const result = await breaker.execute(successfulOperation);
    expect(result).toBe('success');
    expect(breaker.getState()).toBe(CircuitBreakerState.CLOSED);
  });
});
```

#### Step 4: Test API Composition

Create a test file:

**File:** `packages/gateway/tests/unit/api-composition.test.ts`

```typescript
import { describe, it, expect } from 'vitest';
import { ApiCompositionService } from '../../src/infrastructure/adapters/distributed/api-composition.js';

describe('API Composition', () => {
  it('should compose multiple API calls', async () => {
    const composition = new ApiCompositionService();
    
    const result = await composition.compose({
      user: async () => ({ id: '1', name: 'John' }),
      tasks: async () => [{ id: '1', title: 'Task 1' }],
      stats: async () => ({ total: 5, completed: 3 }),
    });

    expect(result).toHaveProperty('user');
    expect(result).toHaveProperty('tasks');
    expect(result).toHaveProperty('stats');
    expect(result.user).toEqual({ id: '1', name: 'John' });
    expect(result.tasks).toEqual([{ id: '1', title: 'Task 1' }]);
    expect(result.stats).toEqual({ total: 5, completed: 3 });
  });

  it('should handle partial failures', async () => {
    const composition = new ApiCompositionService();
    
    const result = await composition.compose({
      user: async () => ({ id: '1', name: 'John' }),
      tasks: async () => { throw new Error('Tasks failed'); },
      stats: async () => ({ total: 5 }),
    });

    expect(result).toHaveProperty('user');
    expect(result).toHaveProperty('stats');
    expect(result).not.toHaveProperty('tasks');
    expect(result.user).toEqual({ id: '1', name: 'John' });
    expect(result.stats).toEqual({ total: 5 });
  });
});
```

#### Step 5: Test Retry Logic

**File:** `packages/gateway/tests/unit/retry.test.ts`

```typescript
import { describe, it, expect, vi } from 'vitest';
import { RetryManager } from '../../src/infrastructure/adapters/distributed/retry-manager.js';

describe('Retry Manager', () => {
  it('should retry on failure', async () => {
    const retryManager = new RetryManager({
      maxAttempts: 3,
      initialDelay: 100,
      backoffMultiplier: 2,
    });

    let attempts = 0;
    const operation = vi.fn(async () => {
      attempts++;
      if (attempts < 3) {
        throw new Error('Temporary failure');
      }
      return 'success';
    });

    const result = await retryManager.execute(operation);
    expect(result).toBe('success');
    expect(operation).toHaveBeenCalledTimes(3);
  });

  it('should throw after max attempts', async () => {
    const retryManager = new RetryManager({
      maxAttempts: 2,
      initialDelay: 100,
    });

    const operation = vi.fn(async () => {
      throw new Error('Always fails');
    });

    await expect(retryManager.execute(operation)).rejects.toThrow('Always fails');
    expect(operation).toHaveBeenCalledTimes(2);
  });
});
```

### 5. Deep Dive: Distributed Patterns in Practice

#### API Composition vs Sequential Calls

**Sequential (Bad):**
```typescript
// 100ms + 100ms + 100ms = 300ms
const user = await getUser(userId);
const tasks = await getTasks(userId);
const stats = await getStats(userId);
```

**Parallel (Good):**
```typescript
// MAX(100ms, 100ms, 100ms) = 100ms
const [user, tasks, stats] = await Promise.all([
  getUser(userId),
  getTasks(userId),
  getStats(userId),
]);
```

#### When to Use Sagas

**Use Sagas For:**
- Cross-service transactions
- Multi-step operations
- When you need rollback capability
- Order processing, payment flows

**Don't Use Sagas For:**
- Simple single-service operations
- Read-only operations
- When eventual consistency is acceptable

#### Circuit Breaker Tuning

**Considerations:**
- **Failure Threshold:** Too low → false positives, Too high → slow failure detection
- **Reset Timeout:** Too short → repeated failures, Too long → slow recovery
- **Half-Open Requests:** More requests = better testing, but more risk

### 6. Summary

**What We Built:**
- ✅ Request context propagation with AsyncLocalStorage
- ✅ Circuit breaker pattern for fault tolerance
- ✅ Retry manager with exponential backoff
- ✅ API composition for parallel service calls
- ✅ Saga orchestrator for distributed transactions
- ✅ AbortController integration for cancellation

**Key Concepts Learned:**
- Distributed coordination patterns
- Circuit breaker states and transitions
- Exponential backoff and jitter
- Saga orchestration vs choreography
- Request cancellation propagation
- The importance of timeouts and retries

**What's Next:**
In Part 2 of Phase 3, we'll implement service-to-service communication, add a task worker service, and build out the complete task processing pipeline with proper error handling and monitoring.

**Verification Checklist:**
- [ ] Circuit breaker opens and closes correctly
- [ ] Retry logic works with exponential backoff
- [ ] API composition handles parallel calls
- [ ] Saga orchestrator performs rollbacks
- [ ] Request context propagates properly
- [ ] AbortController integrates with all patterns

