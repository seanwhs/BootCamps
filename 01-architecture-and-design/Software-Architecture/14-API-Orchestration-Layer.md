# Phase 6, Part 2: API Orchestration Layer

## Production-Grade Request Management

Welcome to the final part of our journey! This is the capstone where we combine everything we've learned into a production-grade API orchestration layer. Think of this like building the ultimate control center for your restaurant chain - managing orders (requests), handling failures, preventing overload, and gracefully canceling operations when needed.

### 1. The Target

**What we're building:** A comprehensive API orchestration layer featuring:
- Custom request queuing with priority support
- Automatic retries with exponential backoff and jitter
- Rate limiting with sliding windows
- Full AbortController integration for request cancellation
- Request deduplication
- Bulk request processing
- Comprehensive observability and metrics

**Updated File Structure:**
```
packages/gateway/
├── src/
│   ├── core/
│   │   └── application/
│   │       └── orchestration/                    # NEW: Orchestration layer
│   │           ├── request-queue.ts
│   │           ├── retry-policy.ts
│   │           ├── rate-limiter.ts
│   │           ├── deduplicator.ts
│   │           ├── bulk-processor.ts
│   │           └── orchestrator.ts
│   ├── infrastructure/
│   │   └── adapters/
│   │       └── orchestration/                    # NEW: Orchestration adapters
│   │           ├── queue-adapter.ts
│   │           └── redis-queue.ts
│   └── server.ts (updated)
│
└── tests/
    ├── unit/
    │   ├── request-queue.test.ts
    │   ├── retry-policy.test.ts
    │   ├── rate-limiter.test.ts
    │   └── orchestrator.test.ts
    └── integration/
        └── orchestration-flow.test.ts
```

### 2. The Concept: The Final Boss Architecture

**The Orchestration Layer:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         API ORCHESTRATION LAYER                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Incoming Request                                                           │
│  ┌─────────────────────┐                                                   │
│  │ 1. Rate Limiter     │───❌ Rate Limited ──▶ 429 Response               │
│  └─────────────────────┘                                                   │
│           │                                                                 │
│           ▼                                                                 │
│  ┌─────────────────────┐                                                   │
│  │ 2. Deduplicator     │───✅ Duplicate ──▶ Return Cached Response        │
│  └─────────────────────┘                                                   │
│           │                                                                 │
│           ▼                                                                 │
│  ┌─────────────────────┐                                                   │
│  │ 3. Request Queue    │───▶ Prioritize and Schedule                      │
│  └─────────────────────┘                                                   │
│           │                                                                 │
│           ▼                                                                 │
│  ┌─────────────────────┐                                                   │
│  │ 4. Retry Policy     │───▶ Exponential Backoff                          │
│  └─────────────────────┘                                                   │
│           │                                                                 │
│           ▼                                                                 │
│  ┌─────────────────────┐                                                   │
│  │ 5. Execute          │───▶ With AbortController                         │
│  └─────────────────────┘                                                   │
│           │                                                                 │
│           ▼                                                                 │
│  ┌─────────────────────┐                                                   │
│  │ 6. Bulk Processing  │───▶ Batch similar requests                       │
│  └─────────────────────┘                                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3. The Implementation

#### Step 1: Request Queue with Priority

**File:** `packages/gateway/src/core/application/orchestration/request-queue.ts`

```typescript
import { EventEmitter } from 'events';
import { createChildLogger } from '../../../logger.js';

/**
 * Request Priority
 */
export enum RequestPriority {
  CRITICAL = 0,  // Highest priority
  HIGH = 1,
  MEDIUM = 2,
  LOW = 3,
  BACKGROUND = 4,
}

/**
 * Queued Request
 */
export interface QueuedRequest<T = any> {
  id: string;
  priority: RequestPriority;
  execute: (signal: AbortSignal) => Promise<T>;
  resolve: (value: T) => void;
  reject: (error: Error) => void;
  signal: AbortSignal;
  enqueuedAt: Date;
  timeout: number;
  retryCount: number;
  maxRetries: number;
  metadata?: Record<string, any>;
}

/**
 * Request Queue Configuration
 */
export interface RequestQueueConfig {
  maxSize: number;
  defaultTimeout: number;
  defaultMaxRetries: number;
  processingConcurrency: number;
}

/**
 * Request Queue
 * 
 * Manages requests with priority-based queuing.
 * 
 * Features:
 * 1. Priority-based ordering (higher priority first)
 * 2. Concurrency control
 * 3. Request timeout handling
 * 4. Auto-cancellation on timeout
 * 5. Queue size limits
 */
export class RequestQueue extends EventEmitter {
  private queue: QueuedRequest[] = [];
  private processing: Set<string> = new Set();
  private readonly logger = createChildLogger({ module: 'RequestQueue' });
  private isPaused = false;
  private stats = {
    enqueued: 0,
    processed: 0,
    failed: 0,
    timedOut: 0,
    cancelled: 0,
    queueFull: 0,
  };

  constructor(private readonly config: RequestQueueConfig) {
    super();
    this.startProcessing();
  }

  /**
   * Enqueue a request
   */
  async enqueue<T>(
    execute: (signal: AbortSignal) => Promise<T>,
    options?: {
      priority?: RequestPriority;
      timeout?: number;
      maxRetries?: number;
      signal?: AbortSignal;
      metadata?: Record<string, any>;
    }
  ): Promise<T> {
    // Check queue size
    if (this.queue.length >= this.config.maxSize) {
      this.stats.queueFull++;
      throw new Error('Queue is full');
    }

    const id = `req_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`;
    const priority = options?.priority ?? RequestPriority.MEDIUM;
    const timeout = options?.timeout ?? this.config.defaultTimeout;
    const maxRetries = options?.maxRetries ?? this.config.defaultMaxRetries;

    // Create abort controller for this request
    const controller = new AbortController();
    const signal = controller.signal;

    // Combine with provided signal
    if (options?.signal) {
      options.signal.addEventListener('abort', () => {
        controller.abort(options.signal.reason);
      });
    }

    // Create promise
    return new Promise<T>((resolve, reject) => {
      const queuedRequest: QueuedRequest = {
        id,
        priority,
        execute,
        resolve,
        reject,
        signal,
        enqueuedAt: new Date(),
        timeout,
        retryCount: 0,
        maxRetries,
        metadata: options?.metadata,
      };

      // Insert in priority order
      let inserted = false;
      for (let i = 0; i < this.queue.length; i++) {
        if (this.queue[i].priority > priority) {
          this.queue.splice(i, 0, queuedRequest);
          inserted = true;
          break;
        }
      }
      
      if (!inserted) {
        this.queue.push(queuedRequest);
      }

      this.stats.enqueued++;
      this.logger.debug({
        id,
        priority,
        queueSize: this.queue.length,
      }, 'Request enqueued');

      // Emit event
      this.emit('enqueued', queuedRequest);

      // Start processing if not already running
      this.processNext();
    });
  }

  /**
   * Process the next request in the queue
   */
  private async processNext(): Promise<void> {
    if (this.isPaused) {
      return;
    }

    // Check concurrency limit
    if (this.processing.size >= this.config.processingConcurrency) {
      return;
    }

    // Check if queue is empty
    if (this.queue.length === 0) {
      return;
    }

    // Get next request
    const request = this.queue.shift();
    if (!request) {
      return;
    }

    // Check if already aborted
    if (request.signal.aborted) {
      this.stats.cancelled++;
      request.reject(new Error('Request cancelled'));
      this.emit('cancelled', request);
      return this.processNext();
    }

    // Process the request
    this.processing.add(request.id);
    this.logger.debug({
      id: request.id,
      processingCount: this.processing.size,
      queueSize: this.queue.length,
    }, 'Processing request');

    try {
      // Execute with timeout
      const result = await this.executeWithTimeout(request);
      
      // Resolve successfully
      request.resolve(result);
      this.stats.processed++;
      this.emit('completed', request);

    } catch (error) {
      const err = error instanceof Error ? error : new Error(String(error));
      
      // Check if it's a timeout
      if (err.message.includes('timeout')) {
        this.stats.timedOut++;
        this.emit('timeout', request);
      } else {
        this.stats.failed++;
        this.emit('failed', request, err);
      }

      // Check if we should retry
      if (this.shouldRetry(request, err)) {
        request.retryCount++;
        // Re-queue with same priority
        this.queue.unshift(request);
        this.logger.debug({
          id: request.id,
          retryCount: request.retryCount,
          maxRetries: request.maxRetries,
        }, 'Retrying request');
      } else {
        request.reject(err);
      }
    } finally {
      this.processing.delete(request.id);
      // Process next request
      this.processNext();
    }
  }

  /**
   * Execute request with timeout
   */
  private async executeWithTimeout(request: QueuedRequest): Promise<any> {
    return new Promise((resolve, reject) => {
      const timeoutId = setTimeout(() => {
        reject(new Error(`Request timeout after ${request.timeout}ms`));
      }, request.timeout);

      // Listen for abort
      request.signal.addEventListener('abort', () => {
        clearTimeout(timeoutId);
        reject(new Error('Request cancelled'));
      });

      // Execute the request
      request.execute(request.signal)
        .then(result => {
          clearTimeout(timeoutId);
          resolve(result);
        })
        .catch(error => {
          clearTimeout(timeoutId);
          reject(error);
        });
    });
  }

  /**
   * Check if a request should be retried
   */
  private shouldRetry(request: QueuedRequest, error: Error): boolean {
    if (request.retryCount >= request.maxRetries) {
      return false;
    }

    // Don't retry client errors (4xx)
    if (error.message.includes('400') ||
        error.message.includes('401') ||
        error.message.includes('403') ||
        error.message.includes('404')) {
      return false;
    }

    // Retry on timeouts and server errors
    return true;
  }

  /**
   * Start processing loop
   */
  private startProcessing(): void {
    setInterval(() => {
      this.processNext();
    }, 100);
  }

  /**
   * Pause queue processing
   */
  pause(): void {
    this.isPaused = true;
    this.logger.info('Queue paused');
  }

  /**
   * Resume queue processing
   */
  resume(): void {
    this.isPaused = false;
    this.logger.info('Queue resumed');
    this.processNext();
  }

  /**
   * Get queue statistics
   */
  getStats(): {
    queueSize: number;
    processing: number;
    stats: typeof this.stats;
  } {
    return {
      queueSize: this.queue.length,
      processing: this.processing.size,
      stats: { ...this.stats },
    };
  }

  /**
   * Get queue status
   */
  getStatus(): {
    queueSize: number;
    processing: number;
    isPaused: boolean;
    maxSize: number;
    concurrency: number;
  } {
    return {
      queueSize: this.queue.length,
      processing: this.processing.size,
      isPaused: this.isPaused,
      maxSize: this.config.maxSize,
      concurrency: this.config.processingConcurrency,
    };
  }

  /**
   * Clear the queue
   */
  clear(): void {
    const remaining = this.queue.length;
    for (const request of this.queue) {
      request.reject(new Error('Queue cleared'));
    }
    this.queue = [];
    this.logger.info({ cleared: remaining }, 'Queue cleared');
  }
}
```

#### Step 2: Retry Policy

**File:** `packages/gateway/src/core/application/orchestration/retry-policy.ts`

```typescript
/**
 * Retry Policy Configuration
 */
export interface RetryPolicyConfig {
  maxAttempts: number;
  initialDelayMs: number;
  maxDelayMs: number;
  backoffMultiplier: number;
  useJitter: boolean;
  retryableErrors?: Array<new (...args: any[]) => Error>;
}

/**
 * Retry Policy
 * 
 * Implements exponential backoff with jitter for retries.
 * 
 * This is used by the orchestrator to determine when and how
 * to retry failed requests.
 */
export class RetryPolicy {
  constructor(private readonly config: RetryPolicyConfig) {}

  /**
   * Calculate the delay before the next retry
   */
  getDelay(attempt: number): number {
    // Exponential backoff
    let delay = this.config.initialDelayMs * 
                Math.pow(this.config.backoffMultiplier, attempt - 1);

    // Cap at max delay
    delay = Math.min(delay, this.config.maxDelayMs);

    // Add jitter (random ±30%)
    if (this.config.useJitter) {
      const jitter = 0.7 + (Math.random() * 0.6); // 0.7 to 1.3
      delay = delay * jitter;
    }

    return Math.round(delay);
  }

  /**
   * Check if a request should be retried
   */
  shouldRetry(error: Error, attempt: number): boolean {
    // Check max attempts
    if (attempt >= this.config.maxAttempts) {
      return false;
    }

    // Check if error is retryable
    if (this.config.retryableErrors) {
      for (const ErrorType of this.config.retryableErrors) {
        if (error instanceof ErrorType) {
          return true;
        }
      }
    }

    // Retry on network errors and timeouts
    const message = error.message.toLowerCase();
    if (message.includes('timeout') ||
        message.includes('connection') ||
        message.includes('network') ||
        message.includes('econnreset') ||
        message.includes('econnrefused') ||
        message.includes('500') ||
        message.includes('502') ||
        message.includes('503') ||
        message.includes('504')) {
      return true;
    }

    // Don't retry client errors (4xx)
    if (message.includes('400') ||
        message.includes('401') ||
        message.includes('403') ||
        message.includes('404') ||
        message.includes('422')) {
      return false;
    }

    // Default to retry for unknown errors
    return true;
  }

  /**
   * Get retry statistics
   */
  getStats(attempt: number): {
    attempt: number;
    maxAttempts: number;
    delay: number;
    remainingAttempts: number;
  } {
    return {
      attempt,
      maxAttempts: this.config.maxAttempts,
      delay: this.getDelay(attempt),
      remainingAttempts: this.config.maxAttempts - attempt,
    };
  }
}

/**
 * Create a retry policy with default settings
 */
export function createDefaultRetryPolicy(): RetryPolicy {
  return new RetryPolicy({
    maxAttempts: 3,
    initialDelayMs: 1000,
    maxDelayMs: 30000,
    backoffMultiplier: 2,
    useJitter: true,
  });
}
```

#### Step 3: Rate Limiter

**File:** `packages/gateway/src/core/application/orchestration/rate-limiter.ts`

```typescript
/**
 * Rate Limiter Configuration
 */
export interface RateLimiterConfig {
  /** Maximum number of requests per window */
  maxRequests: number;
  
  /** Time window in milliseconds */
  windowMs: number;
  
  /** Whether to use sliding window (vs fixed window) */
  slidingWindow: boolean;
  
  /** Key generator function */
  keyGenerator?: (context: any) => string;
}

/**
 * Rate Limit Info
 */
export interface RateLimitInfo {
  limited: boolean;
  remaining: number;
  resetAt: Date;
  limit: number;
  windowMs: number;
}

/**
 * Rate Limiter
 * 
 * Implements rate limiting with sliding window support.
 * 
 * This prevents API abuse and ensures fair usage.
 * 
 * Two approaches:
 * 1. Fixed Window: Simple, but has boundary issues
 * 2. Sliding Window: More accurate, but more expensive
 */
export class RateLimiter {
  private store: Map<string, { count: number; windowStart: number; requests: number[] }> = new Map();
  private readonly logger = createChildLogger({ module: 'RateLimiter' });

  constructor(private readonly config: RateLimiterConfig) {}

  /**
   * Check if a request is allowed
   */
  isAllowed(key: string): RateLimitInfo {
    const now = Date.now();
    const windowStart = now - this.config.windowMs;

    // Get or create entry
    let entry = this.store.get(key);
    if (!entry) {
      entry = {
        count: 0,
        windowStart: now,
        requests: [],
      };
      this.store.set(key, entry);
    }

    // Clean old requests for sliding window
    if (this.config.slidingWindow) {
      entry.requests = entry.requests.filter(timestamp => timestamp > windowStart);
      entry.count = entry.requests.length;
    } else {
      // Fixed window - reset if window expired
      if (now - entry.windowStart > this.config.windowMs) {
        entry.count = 0;
        entry.windowStart = now;
        entry.requests = [];
      }
    }

    // Check if allowed
    const limited = entry.count >= this.config.maxRequests;
    const remaining = Math.max(0, this.config.maxRequests - entry.count);
    const resetAt = new Date(entry.windowStart + this.config.windowMs);

    if (!limited) {
      // Increment for this request
      entry.count++;
      if (this.config.slidingWindow) {
        entry.requests.push(now);
      }
    }

    return {
      limited,
      remaining,
      resetAt,
      limit: this.config.maxRequests,
      windowMs: this.config.windowMs,
    };
  }

  /**
   * Check if a request is allowed (with context)
   */
  check(context: any): RateLimitInfo {
    const key = this.config.keyGenerator 
      ? this.config.keyGenerator(context)
      : this.getDefaultKey(context);
    
    return this.isAllowed(key);
  }

  /**
   * Get default key from context
   */
  private getDefaultKey(context: any): string {
    if (context.userId) {
      return `user:${context.userId}`;
    }
    if (context.ip) {
      return `ip:${context.ip}`;
    }
    if (context.apiKey) {
      return `apikey:${context.apiKey}`;
    }
    return 'global';
  }

  /**
   * Reset rate limit for a key
   */
  reset(key: string): void {
    this.store.delete(key);
    this.logger.debug({ key }, 'Rate limit reset');
  }

  /**
   * Reset all rate limits
   */
  resetAll(): void {
    this.store.clear();
    this.logger.info('All rate limits reset');
  }

  /**
   * Get rate limit statistics
   */
  getStats(): {
    totalKeys: number;
    keys: Array<{
      key: string;
      count: number;
      limit: number;
      remaining: number;
      resetIn: number;
    }>;
  } {
    const now = Date.now();
    const keys: Array<any> = [];

    for (const [key, entry] of this.store) {
      const remaining = Math.max(0, this.config.maxRequests - entry.count);
      const resetIn = Math.max(0, (entry.windowStart + this.config.windowMs) - now);
      
      keys.push({
        key,
        count: entry.count,
        limit: this.config.maxRequests,
        remaining,
        resetIn,
      });
    }

    return {
      totalKeys: this.store.size,
      keys,
    };
  }

  /**
   * Clean up old entries (run periodically)
   */
  cleanup(): void {
    const now = Date.now();
    const expiredBefore = now - this.config.windowMs;

    for (const [key, entry] of this.store) {
      if (this.config.slidingWindow) {
        entry.requests = entry.requests.filter(ts => ts > expiredBefore);
        entry.count = entry.requests.length;
        
        if (entry.count === 0 && entry.requests.length === 0) {
          this.store.delete(key);
        }
      } else {
        // Fixed window - if window expired, remove entry
        if (now - entry.windowStart > this.config.windowMs * 2) {
          this.store.delete(key);
        }
      }
    }
  }
}

/**
 * Create a rate limiter with default settings
 */
export function createDefaultRateLimiter(): RateLimiter {
  return new RateLimiter({
    maxRequests: 100,
    windowMs: 60000,
    slidingWindow: true,
  });
}
```

#### Step 4: Request Deduplicator

**File:** `packages/gateway/src/core/application/orchestration/deduplicator.ts`

```typescript
/**
 * Deduplicator
 * 
 * Prevents duplicate requests from being processed.
 * 
 * This is useful for:
 * 1. Idempotent operations
 * 2. Rate limiting friendly
 * 3. Reducing load on backend services
 * 
 * Uses a simple in-memory cache with TTL.
 */
export class Deduplicator {
  private cache: Map<string, { result: any; timestamp: number }> = new Map();
  private readonly logger = createChildLogger({ module: 'Deduplicator' });

  constructor(
    private readonly ttlMs: number = 5000,
    private readonly maxSize: number = 10000
  ) {
    // Clean up expired entries periodically
    setInterval(() => this.cleanup(), 60000);
  }

  /**
   * Get or create a deduplicated request
   */
  async getOrCreate<T>(
    key: string,
    execute: () => Promise<T>,
    options?: {
      ttl?: number;
      force?: boolean;
    }
  ): Promise<T> {
    // Check if we have a cached result
    if (!options?.force) {
      const cached = this.cache.get(key);
      if (cached) {
        const age = Date.now() - cached.timestamp;
        const ttl = options?.ttl ?? this.ttlMs;

        if (age < ttl) {
          this.logger.debug({ key, age }, 'Deduplicated request');
          return cached.result as T;
        }
      }
    }

    // Execute the request
    const result = await execute();

    // Cache the result
    this.cache.set(key, {
      result,
      timestamp: Date.now(),
    });

    // Enforce max size
    if (this.cache.size > this.maxSize) {
      this.evictOldest();
    }

    this.logger.debug({ key }, 'Executed and cached request');
    return result;
  }

  /**
   * Invalidate a cached result
   */
  invalidate(key: string): void {
    this.cache.delete(key);
    this.logger.debug({ key }, 'Cache invalidated');
  }

  /**
   * Invalidate by pattern
   */
  invalidateByPattern(pattern: string): void {
    const regex = new RegExp(pattern);
    let count = 0;

    for (const key of this.cache.keys()) {
      if (regex.test(key)) {
        this.cache.delete(key);
        count++;
      }
    }

    this.logger.debug({ pattern, count }, 'Cache invalidated by pattern');
  }

  /**
   * Clean up expired entries
   */
  private cleanup(): void {
    const now = Date.now();
    let count = 0;

    for (const [key, entry] of this.cache) {
      if (now - entry.timestamp > this.ttlMs * 2) {
        this.cache.delete(key);
        count++;
      }
    }

    if (count > 0) {
      this.logger.debug({ count }, 'Cleaned up expired cache entries');
    }
  }

  /**
   * Evict oldest entries when cache is full
   */
  private evictOldest(): void {
    const entries = Array.from(this.cache.entries())
      .sort((a, b) => a[1].timestamp - b[1].timestamp);

    const toRemove = Math.ceil(this.maxSize * 0.1);
    for (let i = 0; i < toRemove && i < entries.length; i++) {
      this.cache.delete(entries[i][0]);
    }

    this.logger.debug({ removed: toRemove }, 'Evicted oldest cache entries');
  }

  /**
   * Get cache statistics
   */
  getStats(): {
    size: number;
    maxSize: number;
    ttlMs: number;
  } {
    return {
      size: this.cache.size,
      maxSize: this.maxSize,
      ttlMs: this.ttlMs,
    };
  }

  /**
   * Clear the cache
   */
  clear(): void {
    this.cache.clear();
    this.logger.info('Cache cleared');
  }
}
```

#### Step 5: Bulk Processor

**File:** `packages/gateway/src/core/application/orchestration/bulk-processor.ts`

```typescript
/**
 * Bulk Processor
 * 
 * Groups similar requests for batch processing.
 * 
 * This reduces overhead by:
 * 1. Batching database operations
 * 2. Reducing network round trips
 * 3. Improving throughput
 * 
 * Requests are grouped by operation type and processed together.
 */
export class BulkProcessor {
  private batches: Map<string, BatchGroup> = new Map();
  private readonly logger = createChildLogger({ module: 'BulkProcessor' });

  constructor(
    private readonly batchWindowMs: number = 100,
    private readonly maxBatchSize: number = 100
  ) {
    // Process batches periodically
    setInterval(() => this.processBatches(), this.batchWindowMs);
  }

  /**
   * Add a request to a batch
   */
  async add<T>(
    groupKey: string,
    operation: () => Promise<T>
  ): Promise<T> {
    // Get or create batch group
    let group = this.batches.get(groupKey);
    if (!group) {
      group = {
        key: groupKey,
        operations: [],
        promises: [],
        timestamp: Date.now(),
      };
      this.batches.set(groupKey, group);
    }

    // Add operation to batch
    return new Promise<T>((resolve, reject) => {
      group.operations.push(operation);
      group.promises.push({ resolve, reject });
    });
  }

  /**
   * Process all batches
   */
  private async processBatches(): Promise<void> {
    const now = Date.now();

    for (const [key, group] of this.batches) {
      // Check if batch is ready
      const ready = group.operations.length >= this.maxBatchSize ||
                    (now - group.timestamp) >= this.batchWindowMs;

      if (!ready) {
        continue;
      }

      // Process batch
      try {
        this.logger.debug({
          group: key,
          size: group.operations.length,
        }, 'Processing batch');

        // Process operations sequentially
        const results: any[] = [];
        for (const operation of group.operations) {
          try {
            const result = await operation();
            results.push(result);
          } catch (error) {
            results.push(error);
          }
        }

        // Resolve promises
        for (let i = 0; i < group.promises.length; i++) {
          const { resolve, reject } = group.promises[i];
          const result = results[i];

          if (result instanceof Error) {
            reject(result);
          } else {
            resolve(result);
          }
        }

      } catch (error) {
        // If batch processing fails, reject all promises
        for (const { reject } of group.promises) {
          reject(error instanceof Error ? error : new Error(String(error)));
        }
      }

      // Remove processed group
      this.batches.delete(key);
    }
  }

  /**
   * Get batch statistics
   */
  getStats(): {
    totalBatches: number;
    batches: Array<{
      key: string;
      size: number;
      age: number;
    }>;
  } {
    const now = Date.now();
    const batches = [];

    for (const [key, group] of this.batches) {
      batches.push({
        key,
        size: group.operations.length,
        age: now - group.timestamp,
      });
    }

    return {
      totalBatches: this.batches.size,
      batches,
    };
  }

  /**
   * Force process all batches immediately
   */
  async flush(): Promise<void> {
    await this.processBatches();
  }

  /**
   * Clear all batches
   */
  clear(): void {
    for (const group of this.batches.values()) {
      for (const { reject } of group.promises) {
        reject(new Error('Batch cleared'));
      }
    }
    this.batches.clear();
    this.logger.info('All batches cleared');
  }
}

interface BatchGroup {
  key: string;
  operations: Array<() => Promise<any>>;
  promises: Array<{
    resolve: (value: any) => void;
    reject: (error: any) => void;
  }>;
  timestamp: number;
}
```

#### Step 6: Main Orchestrator

**File:** `packages/gateway/src/core/application/orchestration/orchestrator.ts`

```typescript
import { RequestQueue, RequestPriority } from './request-queue.js';
import { RetryPolicy, createDefaultRetryPolicy } from './retry-policy.js';
import { RateLimiter, createDefaultRateLimiter } from './rate-limiter.js';
import { Deduplicator } from './deduplicator.js';
import { BulkProcessor } from './bulk-processor.js';
import { createChildLogger } from '../../../logger.js';

/**
 * Orchestrator Configuration
 */
export interface OrchestratorConfig {
  queue: {
    maxSize: number;
    defaultTimeout: number;
    defaultMaxRetries: number;
    processingConcurrency: number;
  };
  retry: {
    maxAttempts: number;
    initialDelayMs: number;
    maxDelayMs: number;
    backoffMultiplier: number;
    useJitter: boolean;
  };
  rateLimit: {
    maxRequests: number;
    windowMs: number;
    slidingWindow: boolean;
  };
  deduplication: {
    ttlMs: number;
    maxSize: number;
  };
  bulk: {
    batchWindowMs: number;
    maxBatchSize: number;
  };
}

/**
 * Request Context
 */
export interface RequestContext {
  userId?: string;
  ip?: string;
  apiKey?: string;
  requestId: string;
  headers: Record<string, string>;
}

/**
 * Orchestrator
 * 
 * The main orchestration layer that coordinates all components.
 * 
 * This is the "Final Boss" - it combines:
 * 1. Request queuing
 * 2. Retry logic
 * 3. Rate limiting
 * 4. Deduplication
 * 5. Bulk processing
 * 6. Cancellation support
 */
export class Orchestrator {
  private queue: RequestQueue;
  private retryPolicy: RetryPolicy;
  private rateLimiter: RateLimiter;
  private deduplicator: Deduplicator;
  private bulkProcessor: BulkProcessor;
  private readonly logger = createChildLogger({ module: 'Orchestrator' });

  constructor(private readonly config: OrchestratorConfig) {
    // Initialize components
    this.queue = new RequestQueue({
      maxSize: config.queue.maxSize,
      defaultTimeout: config.queue.defaultTimeout,
      defaultMaxRetries: config.queue.defaultMaxRetries,
      processingConcurrency: config.queue.processingConcurrency,
    });

    this.retryPolicy = new RetryPolicy({
      maxAttempts: config.retry.maxAttempts,
      initialDelayMs: config.retry.initialDelayMs,
      maxDelayMs: config.retry.maxDelayMs,
      backoffMultiplier: config.retry.backoffMultiplier,
      useJitter: config.retry.useJitter,
    });

    this.rateLimiter = new RateLimiter({
      maxRequests: config.rateLimit.maxRequests,
      windowMs: config.rateLimit.windowMs,
      slidingWindow: config.rateLimit.slidingWindow,
    });

    this.deduplicator = new Deduplicator(
      config.deduplication.ttlMs,
      config.deduplication.maxSize
    );

    this.bulkProcessor = new BulkProcessor(
      config.bulk.batchWindowMs,
      config.bulk.maxBatchSize
    );

    this.logger.info('Orchestrator initialized');
  }

  /**
   * Execute a request through the orchestration layer
   */
  async execute<T>(
    operation: (signal: AbortSignal) => Promise<T>,
    options?: {
      priority?: RequestPriority;
      timeout?: number;
      maxRetries?: number;
      signal?: AbortSignal;
      context?: RequestContext;
      deduplicateKey?: string;
      idempotencyKey?: string;
      metadata?: Record<string, any>;
    }
  ): Promise<T> {
    const requestId = options?.context?.requestId || `req_${Date.now()}`;
    const startTime = Date.now();

    this.logger.debug({
      requestId,
      priority: options?.priority,
      hasDedupKey: !!options?.deduplicateKey,
    }, 'Executing request');

    try {
      // 1. Rate Limit Check
      if (options?.context) {
        const rateLimitInfo = this.rateLimiter.check(options.context);
        if (rateLimitInfo.limited) {
          throw new Error(`Rate limited. Try again in ${rateLimitInfo.resetAt.toISOString()}`);
        }
      }

      // 2. Deduplication Check
      if (options?.deduplicateKey) {
        return await this.deduplicator.getOrCreate(
          options.deduplicateKey,
          () => this.executeWithRetry(operation, options, requestId)
        );
      }

      // 3. Execute with retry and queue
      return await this.executeWithRetry(operation, options, requestId);

    } catch (error) {
      const err = error instanceof Error ? error : new Error(String(error));
      const duration = Date.now() - startTime;

      this.logger.error({
        requestId,
        error: err.message,
        duration,
      }, 'Request failed');

      throw err;
    }
  }

  /**
   * Execute with retry logic
   */
  private async executeWithRetry<T>(
    operation: (signal: AbortSignal) => Promise<T>,
    options?: any,
    requestId?: string
  ): Promise<T> {
    let attempt = 0;
    let lastError: Error | null = null;

    while (true) {
      attempt++;
      this.logger.debug({
        requestId,
        attempt,
        maxAttempts: this.config.retry.maxAttempts,
      }, 'Executing request attempt');

      try {
        // Execute through queue
        const result = await this.queue.enqueue(
          async (signal) => {
            // Check if operation should be bulk processed
            if (options?.bulkKey) {
              return await this.bulkProcessor.add(
                options.bulkKey,
                () => operation(signal)
              );
            }
            return await operation(signal);
          },
          {
            priority: options?.priority,
            timeout: options?.timeout,
            maxRetries: options?.maxRetries,
            signal: options?.signal,
            metadata: { ...options?.metadata, requestId },
          }
        );

        return result;

      } catch (error) {
        const err = error instanceof Error ? error : new Error(String(error));
        lastError = err;

        // Check if we should retry
        if (!this.retryPolicy.shouldRetry(err, attempt)) {
          throw err;
        }

        // Calculate delay
        const delay = this.retryPolicy.getDelay(attempt);
        this.logger.debug({
          requestId,
          attempt,
          delay,
          error: err.message,
        }, 'Retrying after delay');

        await this.sleep(delay);
      }
    }
  }

  /**
   * Execute multiple requests in parallel
   */
  async executeAll<T>(
    operations: Array<(signal: AbortSignal) => Promise<T>>,
    options?: {
      priority?: RequestPriority;
      timeout?: number;
      signal?: AbortSignal;
      context?: RequestContext;
    }
  ): Promise<T[]> {
    const results = await Promise.allSettled(
      operations.map(op => this.execute(op, options))
    );

    const successful: T[] = [];
    const errors: Error[] = [];

    for (const result of results) {
      if (result.status === 'fulfilled') {
        successful.push(result.value);
      } else {
        errors.push(result.reason);
      }
    }

    if (errors.length > 0) {
      // Log but don't fail - return partial results
      this.logger.warn({
        total: operations.length,
        successful: successful.length,
        failed: errors.length,
      }, 'Some requests failed');
    }

    return successful;
  }

  /**
   * Get orchestrator status
   */
  getStatus() {
    return {
      queue: this.queue.getStatus(),
      queueStats: this.queue.getStats(),
      rateLimiter: this.rateLimiter.getStats(),
      deduplicator: this.deduplicator.getStats(),
      bulk: this.bulkProcessor.getStats(),
    };
  }

  /**
   * Pause the orchestrator
   */
  pause(): void {
    this.queue.pause();
    this.logger.info('Orchestrator paused');
  }

  /**
   * Resume the orchestrator
   */
  resume(): void {
    this.queue.resume();
    this.logger.info('Orchestrator resumed');
  }

  /**
   * Sleep helper
   */
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}

/**
 * Create orchestrator with default configuration
 */
export function createDefaultOrchestrator(): Orchestrator {
  return new Orchestrator({
    queue: {
      maxSize: 10000,
      defaultTimeout: 30000,
      defaultMaxRetries: 3,
      processingConcurrency: 10,
    },
    retry: {
      maxAttempts: 3,
      initialDelayMs: 1000,
      maxDelayMs: 30000,
      backoffMultiplier: 2,
      useJitter: true,
    },
    rateLimit: {
      maxRequests: 100,
      windowMs: 60000,
      slidingWindow: true,
    },
    deduplication: {
      ttlMs: 5000,
      maxSize: 10000,
    },
    bulk: {
      batchWindowMs: 100,
      maxBatchSize: 100,
    },
  });
}
```

### 4. The Verification

#### Step 1: Test Request Queue

**File:** `packages/gateway/tests/unit/request-queue.test.ts`

```typescript
import { describe, it, expect, beforeAll } from 'vitest';
import { RequestQueue, RequestPriority } from '../../src/core/application/orchestration/request-queue.js';

describe('Request Queue', () => {
  let queue: RequestQueue;

  beforeAll(() => {
    queue = new RequestQueue({
      maxSize: 10,
      defaultTimeout: 1000,
      defaultMaxRetries: 2,
      processingConcurrency: 2,
    });
  });

  it('should process requests in priority order', async () => {
    const order: number[] = [];

    const createRequest = (priority: RequestPriority) => {
      return () => {
        return new Promise<void>((resolve) => {
          order.push(priority);
          resolve();
        });
      };
    };

    await Promise.all([
      queue.enqueue(createRequest(RequestPriority.LOW), { priority: RequestPriority.LOW }),
      queue.enqueue(createRequest(RequestPriority.MEDIUM), { priority: RequestPriority.MEDIUM }),
      queue.enqueue(createRequest(RequestPriority.HIGH), { priority: RequestPriority.HIGH }),
      queue.enqueue(createRequest(RequestPriority.CRITICAL), { priority: RequestPriority.CRITICAL }),
    ]);

    // Wait for processing
    await new Promise(resolve => setTimeout(resolve, 500));

    expect(order[0]).toBe(RequestPriority.CRITICAL);
    expect(order[1]).toBe(RequestPriority.HIGH);
    expect(order[2]).toBe(RequestPriority.MEDIUM);
    expect(order[3]).toBe(RequestPriority.LOW);
  });

  it('should handle timeouts', async () => {
    const slowRequest = () => {
      return new Promise((resolve) => {
        setTimeout(resolve, 2000);
      });
    };

    await expect(queue.enqueue(slowRequest, { timeout: 500 })).rejects.toThrow('timeout');
  });

  it('should handle retries', async () => {
    let attempts = 0;
    const flakyRequest = () => {
      return new Promise((resolve, reject) => {
        attempts++;
        if (attempts < 3) {
          reject(new Error('Temporary failure'));
        } else {
          resolve('success');
        }
      });
    };

    const result = await queue.enqueue(flakyRequest, { maxRetries: 3 });
    expect(result).toBe('success');
    expect(attempts).toBe(3);
  });
});
```

#### Step 2: Test Rate Limiter

**File:** `packages/gateway/tests/unit/rate-limiter.test.ts`

```typescript
import { describe, it, expect, beforeAll } from 'vitest';
import { RateLimiter } from '../../src/core/application/orchestration/rate-limiter.js';

describe('Rate Limiter', () => {
  let limiter: RateLimiter;

  beforeAll(() => {
    limiter = new RateLimiter({
      maxRequests: 5,
      windowMs: 1000,
      slidingWindow: true,
    });
  });

  it('should allow requests within limit', () => {
    for (let i = 0; i < 5; i++) {
      const result = limiter.isAllowed('test-key');
      expect(result.limited).toBe(false);
      expect(result.remaining).toBe(5 - i - 1);
    }
  });

  it('should block requests over limit', () => {
    const result = limiter.isAllowed('test-key');
    expect(result.limited).toBe(true);
    expect(result.remaining).toBe(0);
  });

  it('should reset after window', async () => {
    await new Promise(resolve => setTimeout(resolve, 1100));
    const result = limiter.isAllowed('test-key');
    expect(result.limited).toBe(false);
    expect(result.remaining).toBe(4);
  });
});
```

#### Step 3: Test Orchestrator

**File:** `packages/gateway/tests/integration/orchestration-flow.test.ts`

```typescript
import { describe, it, expect, beforeAll } from 'vitest';
import { Orchestrator, createDefaultOrchestrator } from '../../src/core/application/orchestration/orchestrator.js';
import { RequestPriority } from '../../src/core/application/orchestration/request-queue.js';

describe('Orchestrator Flow Tests', () => {
  let orchestrator: Orchestrator;

  beforeAll(() => {
    orchestrator = createDefaultOrchestrator();
  });

  it('should execute a simple request', async () => {
    const result = await orchestrator.execute(
      async () => 'Hello, World!'
    );

    expect(result).toBe('Hello, World!');
  });

  it('should handle concurrent requests', async () => {
    const operations = Array.from({ length: 10 }, (_, i) => {
      return async () => `Request ${i}`;
    });

    const results = await orchestrator.executeAll(operations);

    expect(results).toHaveLength(10);
    expect(results[0]).toBe('Request 0');
  });

  it('should deduplicate requests', async () => {
    let executionCount = 0;

    const operation = async () => {
      executionCount++;
      return 'cached result';
    };

    // First execution
    const result1 = await orchestrator.execute(operation, {
      deduplicateKey: 'test-key',
    });

    // Second execution (should be deduplicated)
    const result2 = await orchestrator.execute(operation, {
      deduplicateKey: 'test-key',
    });

    expect(result1).toBe('cached result');
    expect(result2).toBe('cached result');
    expect(executionCount).toBe(1);
  });

  it('should handle rate limiting', async () => {
    // Create a rate-limited orchestrator
    const limitedOrchestrator = new Orchestrator({
      queue: {
        maxSize: 10,
        defaultTimeout: 30000,
        defaultMaxRetries: 3,
        processingConcurrency: 2,
      },
      retry: {
        maxAttempts: 3,
        initialDelayMs: 100,
        maxDelayMs: 1000,
        backoffMultiplier: 2,
        useJitter: false,
      },
      rateLimit: {
        maxRequests: 2,
        windowMs: 1000,
        slidingWindow: true,
      },
      deduplication: {
        ttlMs: 5000,
        maxSize: 10,
      },
      bulk: {
        batchWindowMs: 100,
        maxBatchSize: 10,
      },
    });

    // First 2 should succeed
    for (let i = 0; i < 2; i++) {
      await limitedOrchestrator.execute(
        async () => 'success',
        { context: { userId: 'test-user' } }
      );
    }

    // Third should be rate limited
    await expect(
      limitedOrchestrator.execute(
        async () => 'success',
        { context: { userId: 'test-user' } }
      )
    ).rejects.toThrow('Rate limited');
  });

  it('should respect priority', async () => {
    const results: number[] = [];

    const createRequest = (id: number, priority: RequestPriority) => {
      return async () => {
        results.push(id);
        return id;
      };
    };

    await Promise.all([
      orchestrator.execute(createRequest(1, RequestPriority.LOW), {
        priority: RequestPriority.LOW,
      }),
      orchestrator.execute(createRequest(2, RequestPriority.MEDIUM), {
        priority: RequestPriority.MEDIUM,
      }),
      orchestrator.execute(createRequest(3, RequestPriority.HIGH), {
        priority: RequestPriority.HIGH,
      }),
    ]);

    await new Promise(resolve => setTimeout(resolve, 1000));

    // Higher priority should complete first
    expect(results[0]).toBe(3);
    expect(results[1]).toBe(2);
    expect(results[2]).toBe(1);
  });

  it('should handle cancellation', async () => {
    const controller = new AbortController();

    const slowOperation = async (signal: AbortSignal) => {
      return new Promise((resolve, reject) => {
        const timeout = setTimeout(() => resolve('done'), 5000);
        signal.addEventListener('abort', () => {
          clearTimeout(timeout);
          reject(new Error('Cancelled'));
        });
      });
    };

    // Start the operation
    const promise = orchestrator.execute(slowOperation, {
      signal: controller.signal,
    });

    // Cancel after 100ms
    setTimeout(() => controller.abort(), 100);

    await expect(promise).rejects.toThrow('Cancelled');
  });

  it('should get status', async () => {
    const status = orchestrator.getStatus();
    expect(status.queue).toBeDefined();
    expect(status.rateLimiter).toBeDefined();
    expect(status.deduplicator).toBeDefined();
    expect(status.bulk).toBeDefined();
  });
});
```

#### Step 4: Run All Tests

```bash
# Run unit tests
npm test -- tests/unit/request-queue.test.ts
npm test -- tests/unit/rate-limiter.test.ts

# Run integration tests
npm test -- tests/integration/orchestration-flow.test.ts

# Run all tests
npm test
```

#### Step 5: Manual Performance Test

**File:** `packages/gateway/tests/manual/orchestrator-performance.test.ts`

```typescript
import { createDefaultOrchestrator } from '../../src/core/application/orchestration/orchestrator.js';

async function testPerformance() {
  const orchestrator = createDefaultOrchestrator();

  console.log('Testing orchestrator performance...');

  const start = Date.now();
  const operations = 100;

  // Create operations
  const tasks = Array.from({ length: operations }, (_, i) => {
    return async () => {
      // Simulate some work
      await new Promise(resolve => setTimeout(resolve, Math.random() * 10));
      return i;
    };
  });

  // Execute all
  const results = await orchestrator.executeAll(tasks);
  const duration = Date.now() - start;
  const throughput = operations / (duration / 1000);

  console.log(`✅ Executed ${operations} operations in ${duration}ms`);
  console.log(`✅ Throughput: ${throughput.toFixed(2)} ops/sec`);
  console.log(`✅ Status:`, orchestrator.getStatus());

  // Test with deduplication
  console.log('\nTesting deduplication...');
  const dupStart = Date.now();
  let executions = 0;

  const dedupOperation = async () => {
    executions++;
    await new Promise(resolve => setTimeout(resolve, 5));
    return 'result';
  };

  const promises = [];
  for (let i = 0; i < 50; i++) {
    promises.push(
      orchestrator.execute(dedupOperation, {
        deduplicateKey: 'test-key',
      })
    );
  }

  await Promise.all(promises);
  const dupDuration = Date.now() - dupStart;

  console.log(`✅ 50 duplicate operations executed in ${dupDuration}ms`);
  console.log(`✅ Actual executions: ${executions} (should be 1)`);

  // Get final status
  console.log('\nFinal Status:', JSON.stringify(orchestrator.getStatus(), null, 2));
}

testPerformance().catch(console.error);
```

### 5. Deep Dive: Production Patterns

#### Circuit Breaker Integration

Add circuit breaker to the orchestrator:

```typescript
class Orchestrator {
  private circuitBreaker: CircuitBreaker;

  async execute(operation, options) {
    return this.circuitBreaker.execute(
      async (signal) => {
        // Original execution logic
        return await this.executeWithRetry(operation, options);
      },
      options?.signal
    );
  }
}
```

#### Graceful Shutdown

```typescript
class Orchestrator {
  async shutdown(): Promise<void> {
    this.logger.info('Shutting down orchestrator...');
    
    // 1. Pause queue
    this.queue.pause();
    
    // 2. Wait for processing to complete
    while (this.queue.getStatus().processing > 0) {
      await this.sleep(100);
    }
    
    // 3. Flush bulk processor
    await this.bulkProcessor.flush();
    
    // 4. Close connections
    // ...
    
    this.logger.info('Orchestrator shutdown complete');
  }
}
```

#### Metrics and Monitoring

```typescript
class Orchestrator {
  getMetrics(): OrchestratorMetrics {
    return {
      queue: this.queue.getStats(),
      rateLimiter: this.rateLimiter.getStats(),
      deduplicator: this.deduplicator.getStats(),
      bulk: this.bulkProcessor.getStats(),
      system: {
        uptime: Date.now() - this.startTime,
        memory: process.memoryUsage(),
        cpu: process.cpuUsage(),
      },
    };
  }
}
```

### 6. Summary

**What We Built:**
- ✅ Priority-based request queue with concurrency control
- ✅ Exponential backoff retry policy with jitter
- ✅ Sliding window rate limiter
- ✅ Request deduplication with TTL
- ✅ Bulk processing for similar requests
- ✅ Full AbortController integration
- ✅ Comprehensive test suite
- ✅ Production-grade orchestration layer

**Key Concepts Learned:**
- Request queuing and prioritization
- Retry policies and exponential backoff
- Rate limiting strategies (fixed vs sliding window)
- Deduplication patterns
- Bulk processing for efficiency
- Cancellation propagation
- Production monitoring and metrics

**Final System Status:**
We've built a complete, production-ready distributed system with:
- Hexagonal Architecture
- CQRS and Event Sourcing
- Distributed coordination
- Cloud-native deployment
- AI-powered agents
- Production orchestration layer
