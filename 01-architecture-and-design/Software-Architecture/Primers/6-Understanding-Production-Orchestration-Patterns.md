# Primer 6: Understanding Production Orchestration Patterns

## A Deep Dive into Building Resilient Production Systems

Welcome to the sixth primer! This is a comprehensive deep dive into production orchestration patterns - the patterns and practices that make your system production-ready. Think of this like building the control center for your restaurant chain - it manages everything from order intake to delivery, handles failures gracefully, and keeps the entire operation running smoothly.

### 1. The Big Picture

#### Production Orchestration Stack

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    PRODUCTION ORCHESTRATION STACK                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        REQUEST MANAGEMENT                           │   │
│  │  • Rate Limiting   • Request Queuing   • Deduplication             │   │
│  │  • Priority        • Timeout Control   • Bulk Processing            │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      FAULT TOLERANCE                                │   │
│  │  • Circuit Breaker   • Retry Policy    • Fallback Strategies       │   │
│  │  • Timeouts          • Backpressure    • Graceful Degradation      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                   OBSERVABILITY                                     │   │
│  │  • Logging          • Metrics          • Distributed Tracing       │   │
│  │  • Health Checks    • Alerts           • Performance Monitoring    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                   RESOURCE MANAGEMENT                               │   │
│  │  • Connection Pooling   • Memory Management   • CPU Management     │   │
│  │  • Thread Pools         • Cache Management    • GC Optimization    │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Request Management Patterns

#### Rate Limiting

Rate limiting protects your system from being overwhelmed by too many requests.

```typescript
// Sliding Window Rate Limiter
class SlidingWindowRateLimiter {
    private requests: Map<string, number[]> = new Map();
    private readonly maxRequests: number;
    private readonly windowMs: number;

    constructor(maxRequests: number, windowMs: number) {
        this.maxRequests = maxRequests;
        this.windowMs = windowMs;
    }

    isAllowed(key: string): boolean {
        const now = Date.now();
        const windowStart = now - this.windowMs;
        
        // Get existing requests
        let timestamps = this.requests.get(key) || [];
        
        // Remove old requests
        timestamps = timestamps.filter(t => t > windowStart);
        
        // Check limit
        if (timestamps.length >= this.maxRequests) {
            return false;
        }
        
        // Add current request
        timestamps.push(now);
        this.requests.set(key, timestamps);
        
        return true;
    }

    getRemaining(key: string): number {
        const now = Date.now();
        const windowStart = now - this.windowMs;
        const timestamps = this.requests.get(key) || [];
        const recent = timestamps.filter(t => t > windowStart);
        return Math.max(0, this.maxRequests - recent.length);
    }

    getResetTime(key: string): Date {
        const now = Date.now();
        const timestamps = this.requests.get(key) || [];
        if (timestamps.length === 0) {
            return new Date(now + this.windowMs);
        }
        const oldest = Math.min(...timestamps);
        return new Date(oldest + this.windowMs);
    }
}

// Rate Limiting Middleware
function rateLimitMiddleware(limiter: SlidingWindowRateLimiter) {
    return async (request: FastifyRequest, reply: FastifyReply) => {
        const key = getRateLimitKey(request);
        
        if (!limiter.isAllowed(key)) {
            const remaining = limiter.getRemaining(key);
            const resetTime = limiter.getResetTime(key);
            
            reply.header('X-RateLimit-Limit', limiter.maxRequests);
            reply.header('X-RateLimit-Remaining', remaining);
            reply.header('X-RateLimit-Reset', resetTime.toISOString());
            
            reply.status(429).send({
                error: 'Too Many Requests',
                message: 'Rate limit exceeded',
                retryAfter: Math.ceil((resetTime.getTime() - Date.now()) / 1000),
            });
            return;
        }
    };
}

function getRateLimitKey(request: FastifyRequest): string {
    // Use user ID, IP, or API key
    const userId = request.headers['x-user-id'];
    if (userId) {
        return `user:${userId}`;
    }
    
    const apiKey = request.headers['x-api-key'];
    if (apiKey) {
        return `apikey:${apiKey}`;
    }
    
    return `ip:${request.ip}`;
}
```

#### Priority Queuing

Priority queuing ensures important requests are processed first.

```typescript
enum Priority {
    CRITICAL = 0,
    HIGH = 1,
    MEDIUM = 2,
    LOW = 3,
    BACKGROUND = 4,
}

interface QueuedRequest<T> {
    id: string;
    priority: Priority;
    execute: () => Promise<T>;
    resolve: (value: T) => void;
    reject: (error: Error) => void;
    timeout: number;
    enqueuedAt: Date;
}

class PriorityQueue {
    private queues: Map<Priority, QueuedRequest<any>[]> = new Map();
    private processing: number = 0;
    private maxConcurrent: number = 10;

    constructor(maxConcurrent: number = 10) {
        this.maxConcurrent = maxConcurrent;
        // Initialize queues
        for (const priority of Object.values(Priority)) {
            this.queues.set(priority, []);
        }
    }

    async enqueue<T>(
        execute: () => Promise<T>,
        priority: Priority = Priority.MEDIUM,
        timeout: number = 30000
    ): Promise<T> {
        return new Promise((resolve, reject) => {
            const request: QueuedRequest<T> = {
                id: `req_${Date.now()}_${Math.random().toString(36).slice(2)}`,
                priority,
                execute,
                resolve,
                reject,
                timeout,
                enqueuedAt: new Date(),
            };

            // Add to the appropriate queue
            this.queues.get(priority)!.push(request);
            
            // Start processing if not already running
            this.processNext();
        });
    }

    private async processNext(): Promise<void> {
        if (this.processing >= this.maxConcurrent) {
            return;
        }

        // Get the highest priority non-empty queue
        let request: QueuedRequest<any> | undefined;
        let priority: Priority | undefined;

        for (const p of [Priority.CRITICAL, Priority.HIGH, Priority.MEDIUM, Priority.LOW, Priority.BACKGROUND]) {
            const queue = this.queues.get(p)!;
            if (queue.length > 0) {
                request = queue.shift();
                priority = p;
                break;
            }
        }

        if (!request || priority === undefined) {
            return;
        }

        this.processing++;

        try {
            // Execute with timeout
            const result = await this.executeWithTimeout(request);
            request.resolve(result);
        } catch (error) {
            request.reject(error);
        } finally {
            this.processing--;
            this.processNext();
        }
    }

    private async executeWithTimeout<T>(request: QueuedRequest<T>): Promise<T> {
        return new Promise((resolve, reject) => {
            const timeoutId = setTimeout(() => {
                reject(new Error(`Request timeout after ${request.timeout}ms`));
            }, request.timeout);

            request.execute()
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

    getStats(): {
        queueSizes: Record<string, number>;
        processing: number;
        maxConcurrent: number;
    } {
        const queueSizes: Record<string, number> = {};
        for (const [priority, queue] of this.queues) {
            queueSizes[Priority[priority]] = queue.length;
        }

        return {
            queueSizes,
            processing: this.processing,
            maxConcurrent: this.maxConcurrent,
        };
    }
}
```

#### Request Deduplication

Deduplication prevents processing the same request multiple times.

```typescript
class RequestDeduplicator {
    private pending: Map<string, Promise<any>> = new Map();
    private cache: Map<string, { result: any; timestamp: number }> = new Map();
    private ttl: number = 5000;

    async execute<T>(
        key: string,
        operation: () => Promise<T>,
        options?: { ttl?: number; force?: boolean }
    ): Promise<T> {
        // Check cache
        if (!options?.force) {
            const cached = this.cache.get(key);
            if (cached && Date.now() - cached.timestamp < (options?.ttl || this.ttl)) {
                return cached.result as T;
            }
        }

        // Check if already executing
        const existing = this.pending.get(key);
        if (existing) {
            return existing as Promise<T>;
        }

        // Execute the operation
        const promise = operation().then(result => {
            // Cache the result
            this.cache.set(key, {
                result,
                timestamp: Date.now(),
            });
            
            // Clean up
            this.pending.delete(key);
            
            return result;
        }).catch(error => {
            this.pending.delete(key);
            throw error;
        });

        this.pending.set(key, promise);
        return promise;
    }

    invalidate(key: string): void {
        this.cache.delete(key);
        this.pending.delete(key);
    }

    invalidatePattern(pattern: RegExp): void {
        for (const key of this.cache.keys()) {
            if (pattern.test(key)) {
                this.cache.delete(key);
            }
        }
        for (const key of this.pending.keys()) {
            if (pattern.test(key)) {
                this.pending.delete(key);
            }
        }
    }
}
```

### 3. Fault Tolerance Patterns

#### Circuit Breaker

```typescript
enum CircuitState {
    CLOSED = 'CLOSED',       // Normal operation
    OPEN = 'OPEN',           // Failure threshold reached
    HALF_OPEN = 'HALF_OPEN', // Testing if service recovered
}

class CircuitBreaker {
    private state: CircuitState = CircuitState.CLOSED;
    private failureCount: number = 0;
    private lastFailureTime: number = 0;
    
    constructor(
        private readonly failureThreshold: number = 5,
        private readonly resetTimeout: number = 60000,
        private readonly halfOpenTimeout: number = 10000
    ) {}

    async execute<T>(
        operation: () => Promise<T>,
        fallback?: () => Promise<T>
    ): Promise<T> {
        // Check current state
        this.checkState();

        if (this.state === CircuitState.OPEN) {
            if (fallback) {
                return await fallback();
            }
            throw new Error('Circuit breaker is OPEN');
        }

        try {
            const result = await operation();
            this.onSuccess();
            return result;
        } catch (error) {
            this.onFailure();
            
            if (fallback) {
                return await fallback();
            }
            throw error;
        }
    }

    private checkState(): void {
        if (this.state === CircuitState.OPEN) {
            // Check if reset timeout has elapsed
            if (Date.now() - this.lastFailureTime > this.resetTimeout) {
                this.state = CircuitState.HALF_OPEN;
            }
        }
    }

    private onSuccess(): void {
        if (this.state === CircuitState.HALF_OPEN) {
            this.state = CircuitState.CLOSED;
            this.failureCount = 0;
        }
        // Gradually reduce failure count
        this.failureCount = Math.max(0, this.failureCount - 1);
    }

    private onFailure(): void {
        this.failureCount++;
        this.lastFailureTime = Date.now();

        if (this.state === CircuitState.HALF_OPEN) {
            // A failure in half-open state immediately opens the circuit
            this.state = CircuitState.OPEN;
            return;
        }

        if (this.failureCount >= this.failureThreshold) {
            this.state = CircuitState.OPEN;
        }
    }

    getState(): CircuitState {
        this.checkState();
        return this.state;
    }

    getMetrics(): {
        state: CircuitState;
        failureCount: number;
        failureThreshold: number;
        timeSinceLastFailure: number;
    } {
        return {
            state: this.state,
            failureCount: this.failureCount,
            failureThreshold: this.failureThreshold,
            timeSinceLastFailure: Date.now() - this.lastFailureTime,
        };
    }
}
```

#### Retry with Exponential Backoff

```typescript
interface RetryConfig {
    maxAttempts: number;
    initialDelay: number;
    maxDelay: number;
    backoffMultiplier: number;
    useJitter: boolean;
    retryableErrors?: Array<new (...args: any[]) => Error>;
}

class RetryManager {
    private config: RetryConfig;

    constructor(config: Partial<RetryConfig> = {}) {
        this.config = {
            maxAttempts: 3,
            initialDelay: 1000,
            maxDelay: 30000,
            backoffMultiplier: 2,
            useJitter: true,
            ...config,
        };
    }

    async execute<T>(
        operation: () => Promise<T>,
        context?: Record<string, any>
    ): Promise<T> {
        let lastError: Error | null = null;
        let attempt = 0;

        while (attempt < this.config.maxAttempts) {
            attempt++;
            
            try {
                return await operation();
            } catch (error) {
                lastError = error instanceof Error ? error : new Error(String(error));
                
                // Check if we should retry
                if (!this.shouldRetry(lastError, attempt)) {
                    throw lastError;
                }
                
                // Calculate delay with backoff
                const delay = this.calculateDelay(attempt);
                
                // Wait before next attempt
                await this.sleep(delay);
            }
        }

        throw lastError;
    }

    private shouldRetry(error: Error, attempt: number): boolean {
        // Check max attempts
        if (attempt >= this.config.maxAttempts) {
            return false;
        }

        // Check retryable error types
        if (this.config.retryableErrors) {
            for (const ErrorType of this.config.retryableErrors) {
                if (error instanceof ErrorType) {
                    return true;
                }
            }
        }

        // Default retryable errors
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

        return false;
    }

    private calculateDelay(attempt: number): number {
        // Exponential backoff
        let delay = this.config.initialDelay * 
                    Math.pow(this.config.backoffMultiplier, attempt - 1);
        
        // Cap at max delay
        delay = Math.min(delay, this.config.maxDelay);
        
        // Add jitter
        if (this.config.useJitter) {
            const jitter = 0.8 + Math.random() * 0.4;
            delay = delay * jitter;
        }
        
        return Math.round(delay);
    }

    private sleep(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
```

### 4. Bulk Processing

Bulk processing groups similar requests for efficiency.

```typescript
interface BatchOperation {
    id: string;
    execute: () => Promise<any>;
    resolve: (value: any) => void;
    reject: (error: Error) => void;
}

class BulkProcessor {
    private batches: Map<string, BatchOperation[]> = new Map();
    private processing: Set<string> = new Set();
    private batchWindowMs: number;
    private maxBatchSize: number;

    constructor(batchWindowMs: number = 100, maxBatchSize: number = 100) {
        this.batchWindowMs = batchWindowMs;
        this.maxBatchSize = maxBatchSize;
        this.startProcessing();
    }

    async add<T>(key: string, operation: () => Promise<T>): Promise<T> {
        return new Promise((resolve, reject) => {
            const batchItem: BatchOperation = {
                id: `batch_${Date.now()}_${Math.random().toString(36).slice(2)}`,
                execute: operation,
                resolve,
                reject,
            };

            if (!this.batches.has(key)) {
                this.batches.set(key, []);
            }

            this.batches.get(key)!.push(batchItem);

            // Process if batch is full
            if (this.batches.get(key)!.length >= this.maxBatchSize) {
                this.processBatch(key);
            }
        });
    }

    private startProcessing(): void {
        setInterval(() => {
            const now = Date.now();
            for (const [key, operations] of this.batches) {
                if (operations.length > 0 && !this.processing.has(key)) {
                    const firstOp = operations[0];
                    if (firstOp && now - this.getBatchStartTime(firstOp) >= this.batchWindowMs) {
                        this.processBatch(key);
                    }
                }
            }
        }, this.batchWindowMs);
    }

    private async processBatch(key: string): Promise<void> {
        if (this.processing.has(key)) {
            return;
        }

        this.processing.add(key);
        const operations = this.batches.get(key) || [];
        this.batches.delete(key);

        if (operations.length === 0) {
            this.processing.delete(key);
            return;
        }

        try {
            // Process operations in batch
            const results: any[] = [];
            for (const op of operations) {
                try {
                    const result = await op.execute();
                    results.push(result);
                } catch (error) {
                    results.push(error);
                }
            }

            // Resolve individual promises
            for (let i = 0; i < operations.length; i++) {
                const op = operations[i];
                const result = results[i];
                
                if (result instanceof Error) {
                    op.reject(result);
                } else {
                    op.resolve(result);
                }
            }
        } catch (error) {
            // If batch processing fails, reject all
            for (const op of operations) {
                op.reject(error instanceof Error ? error : new Error(String(error)));
            }
        } finally {
            this.processing.delete(key);
        }
    }

    private getBatchStartTime(operation: BatchOperation): number {
        // Return the timestamp from the operation ID
        const timestamp = parseInt(operation.id.split('_')[1]);
        return timestamp;
    }

    getStats(): {
        totalBatches: number;
        processing: number;
        batches: Array<{ key: string; size: number }>;
    } {
        const batches: Array<{ key: string; size: number }> = [];
        for (const [key, operations] of this.batches) {
            batches.push({ key, size: operations.length });
        }

        return {
            totalBatches: this.batches.size,
            processing: this.processing.size,
            batches,
        };
    }
}
```

### 5. Request Context & Cancellation

#### Request Context with Cancellation

```typescript
import { AsyncLocalStorage } from 'async_hooks';
import { randomUUID } from 'crypto';

interface RequestContext {
    requestId: string;
    userId?: string;
    correlationId: string;
    startTime: number;
    timeout: number;
    signal: AbortSignal;
    headers: Record<string, string>;
}

class RequestContextManager {
    private static storage = new AsyncLocalStorage<RequestContext>();

    static run<T>(context: RequestContext, fn: () => T): T {
        return this.storage.run(context, fn);
    }

    static getContext(): RequestContext | null {
        return this.storage.getStore() || null;
    }

    static getRequestId(): string {
        return this.getContext()?.requestId || 'unknown';
    }

    static getCorrelationId(): string {
        return this.getContext()?.correlationId || 'unknown';
    }

    static createContext(options: {
        timeout?: number;
        signal?: AbortSignal;
        headers?: Record<string, string>;
        userId?: string;
    } = {}): RequestContext {
        const requestId = options.headers?.['x-request-id'] || randomUUID();
        const correlationId = options.headers?.['x-correlation-id'] || randomUUID();
        const controller = new AbortController();

        // Create signal from options or default
        let signal = options.signal || controller.signal;

        // Add timeout
        const timeout = options.timeout || 30000;
        const timeoutId = setTimeout(() => {
            controller.abort(new Error('Request timeout'));
        }, timeout);

        // Clean up on abort
        signal.addEventListener('abort', () => {
            clearTimeout(timeoutId);
        });

        return {
            requestId,
            userId: options.userId || options.headers?.['x-user-id'],
            correlationId,
            startTime: Date.now(),
            timeout,
            signal: signal,
            headers: options.headers || {},
        };
    }
}

// Middleware to set request context
async function contextMiddleware(
    request: FastifyRequest,
    reply: FastifyReply
): Promise<void> {
    const context = RequestContextManager.createContext({
        headers: request.headers as Record<string, string>,
        signal: request.abortController?.signal,
        userId: (request as any).user?.id,
    });

    // Set response headers
    reply.header('x-request-id', context.requestId);
    reply.header('x-correlation-id', context.correlationId);

    // Run the request with context
    return new Promise((resolve, reject) => {
        RequestContextManager.run(context, () => {
            // Store context on request for downstream use
            (request as any).requestContext = context;
            resolve();
        });
    });
}
```

#### AbortController Integration

```typescript
class CancellableOperation {
    private controller: AbortController;
    private operations: Array<{ cancel: () => void }> = [];

    constructor() {
        this.controller = new AbortController();
    }

    get signal(): AbortSignal {
        return this.controller.signal;
    }

    cancel(reason?: string): void {
        this.controller.abort(new Error(reason || 'Operation cancelled'));
        
        // Cancel child operations
        for (const op of this.operations) {
            op.cancel();
        }
        this.operations = [];
    }

    addChild(child: CancellableOperation): void {
        // Link cancellation
        child.signal.addEventListener('abort', () => {
            this.cancel(child.signal.reason);
        });
        
        this.operations.push({
            cancel: () => child.cancel(),
        });
    }

    async execute<T>(
        operation: (signal: AbortSignal) => Promise<T>,
        fallback?: () => Promise<T>
    ): Promise<T> {
        // Check if already cancelled
        if (this.controller.signal.aborted) {
            if (fallback) {
                return await fallback();
            }
            throw new Error('Operation cancelled');
        }

        try {
            return await operation(this.controller.signal);
        } catch (error) {
            // Check if it was a cancellation
            if (error instanceof Error && error.name === 'AbortError') {
                if (fallback) {
                    return await fallback();
                }
                throw error;
            }
            throw error;
        }
    }
}

// Example usage
async function processRequest(request: FastifyRequest): Promise<any> {
    const cancellable = new CancellableOperation();
    
    // Register with request for cancellation
    request.abortController = cancellable;
    
    try {
        // Execute multiple operations that can be cancelled together
        const result = await cancellable.execute(async (signal) => {
            // Child operation 1
            const child1 = new CancellableOperation();
            cancellable.addChild(child1);
            
            // Child operation 2
            const child2 = new CancellableOperation();
            cancellable.addChild(child2);
            
            // Execute operations in parallel with cancellation
            const [data1, data2] = await Promise.all([
                child1.execute(() => fetchData1(signal)),
                child2.execute(() => fetchData2(signal)),
            ]);
            
            return { data1, data2 };
        }, () => ({ data1: null, data2: null }));
        
        return result;
    } catch (error) {
        // Handle errors
        throw error;
    }
}
```

### 6. Observability

#### Structured Logging

```typescript
class StructuredLogger {
    private fields: Record<string, any> = {};
    private level: LogLevel = 'info';

    constructor(fields: Record<string, any> = {}) {
        this.fields = fields;
    }

    child(fields: Record<string, any>): StructuredLogger {
        return new StructuredLogger({
            ...this.fields,
            ...fields,
        });
    }

    log(level: LogLevel, message: string, fields?: Record<string, any>): void {
        const logEntry = {
            timestamp: new Date().toISOString(),
            level,
            message,
            ...this.fields,
            ...fields,
            pid: process.pid,
            hostname: require('os').hostname(),
        };

        // Output as JSON
        console.log(JSON.stringify(logEntry));
    }

    debug(message: string, fields?: Record<string, any>): void {
        if (this.shouldLog('debug')) {
            this.log('debug', message, fields);
        }
    }

    info(message: string, fields?: Record<string, any>): void {
        if (this.shouldLog('info')) {
            this.log('info', message, fields);
        }
    }

    warn(message: string, fields?: Record<string, any>): void {
        if (this.shouldLog('warn')) {
            this.log('warn', message, fields);
        }
    }

    error(message: string, error?: Error, fields?: Record<string, any>): void {
        if (this.shouldLog('error')) {
            this.log('error', message, {
                ...fields,
                error: error ? {
                    message: error.message,
                    stack: error.stack,
                    name: error.name,
                } : undefined,
            });
        }
    }

    private shouldLog(level: LogLevel): boolean {
        const levels: Record<LogLevel, number> = {
            debug: 0,
            info: 1,
            warn: 2,
            error: 3,
        };
        return levels[level] >= levels[this.level];
    }

    setLevel(level: LogLevel): void {
        this.level = level;
    }
}

type LogLevel = 'debug' | 'info' | 'warn' | 'error';
```

#### Distributed Tracing

```typescript
interface Span {
    traceId: string;
    spanId: string;
    parentSpanId?: string;
    name: string;
    startTime: number;
    endTime?: number;
    attributes: Record<string, any>;
    events: Array<{ name: string; timestamp: number; attributes: Record<string, any> }>;
    status: 'ok' | 'error' | 'unknown';
}

class Tracer {
    private static instance: Tracer;
    private spans: Map<string, Span> = new Map();

    static getInstance(): Tracer {
        if (!Tracer.instance) {
            Tracer.instance = new Tracer();
        }
        return Tracer.instance;
    }

    startSpan(
        name: string,
        options?: {
            parentSpanId?: string;
            traceId?: string;
            attributes?: Record<string, any>;
        }
    ): Span {
        const context = RequestContextManager.getContext();
        const traceId = options?.traceId || context?.correlationId || this.generateId();
        const spanId = this.generateId();

        const span: Span = {
            traceId,
            spanId,
            parentSpanId: options?.parentSpanId || context?.requestId,
            name,
            startTime: Date.now(),
            attributes: {
                service: process.env.SERVICE_NAME || 'unknown',
                ...options?.attributes,
            },
            events: [],
            status: 'unknown',
        };

        this.spans.set(spanId, span);
        return span;
    }

    endSpan(
        spanId: string,
        options?: {
            status?: 'ok' | 'error';
            error?: Error;
            attributes?: Record<string, any>;
        }
    ): void {
        const span = this.spans.get(spanId);
        if (!span) return;

        span.endTime = Date.now();
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
    }

    addEvent(spanId: string, name: string, attributes?: Record<string, any>): void {
        const span = this.spans.get(spanId);
        if (!span) return;

        span.events.push({
            name,
            timestamp: Date.now(),
            attributes: attributes || {},
        });
    }

    private generateId(): string {
        return `${Date.now()}_${Math.random().toString(36).slice(2, 9)}`;
    }

    getTrace(traceId: string): Span[] {
        const result: Span[] = [];
        for (const span of this.spans.values()) {
            if (span.traceId === traceId) {
                result.push(span);
            }
        }
        return result.sort((a, b) => a.startTime - b.startTime);
    }
}
```

### 7. Key Takeaways

1. **Rate Limiting is Essential:**
   - Protects against overload
   - Fair resource allocation
   - Different limits for different users

2. **Priority Queuing for Critical Requests:**
   - Important requests first
   - Prevents starvation
   - Fair scheduling

3. **Fault Tolerance Patterns:**
   - Circuit breakers prevent cascading failures
   - Retries with backoff for transient failures
   - Fallback strategies for graceful degradation

4. **Bulk Processing for Efficiency:**
   - Groups similar requests
   - Reduces overhead
   - Improves throughput

5. **Context is Everything:**
   - Request context for tracing
   - Cancellation for cleanup
   - Correlation IDs for debugging

6. **Observability is Critical:**
   - Logs for debugging
   - Metrics for monitoring
   - Traces for performance

---

This primer provides a comprehensive understanding of production orchestration patterns. These patterns are essential for building robust, scalable, and reliable production systems.
