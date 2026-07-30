# Phase 3, Part 2: Service Communication & Task Workers

## Building the Distributed Network

Welcome to the second part of Phase 3! Now that we have distributed patterns in place, we need to actually connect our services together. Think of this like setting up a communication network between your restaurant chain locations - you need reliable channels, clear protocols, and efficient ways to handle tasks that can't be completed immediately.

### 1. The Target

**What we're building:** Inter-service communication and background task processing:
- HTTP service client with circuit breaker and retry integration
- Service discovery and registration
- Task worker service for background processing
- Message queue integration for async communication
- Complete task processing pipeline with status tracking

**Updated File Structure:**
```
packages/gateway/
├── src/
│   ├── core/
│   │   ├── domain/
│   │   ├── application/
│   │   └── infrastructure/
│   │       └── services/
│   │           ├── service-client.ts        # NEW: HTTP client for services
│   │           ├── service-registry.ts      # NEW: Service discovery
│   │           └── task-queue.ts            # NEW: Message queue interface
│   │
│   ├── infrastructure/
│   │   ├── adapters/
│   │   │   ├── distributed/
│   │   │   ├── http/
│   │   │   ├── persistence/
│   │   │   ├── cache/
│   │   │   └── messaging/                   # NEW: Message queue adapters
│   │   │       ├── in-memory/
│   │   │       │   └── task-queue.ts
│   │   │       └── rabbitmq/
│   │   │           ├── connection.ts
│   │   │           └── task-queue.ts
│   │   └── workers/
│   │       ├── task-worker.ts               # NEW: Background task worker
│   │       └── worker-pool.ts               # NEW: Worker pool management
│   │
│   ├── admin/
│   └── server.ts
│
└── tests/
    ├── unit/
    ├── integration/
    └── e2e/
```

### 2. The Concept: Service Communication Patterns

Think of service communication like different ways to coordinate work across your restaurant chain:

**Synchronous Communication (HTTP/REST):**
Like calling a restaurant manager on the phone - you wait for an immediate response. Good for: Quick queries, simple operations.

**Asynchronous Communication (Message Queues):**
Like sending a work order via email - you don't wait for an immediate response. Good for: Long-running tasks, batch processing, decoupling services.

**Service Discovery:**
Like having a central directory of all restaurant locations and their phone numbers. Services can find each other without hardcoding addresses.

```
┌─────────────────────────────────────────────────────────────────┐
│                     SERVICE COMMUNICATION                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐    HTTP/REST    ┌──────────────┐            │
│  │   Gateway    │────────────────▶│   Auth       │            │
│  │   Service    │◀────────────────│   Service    │            │
│  └──────────────┘    Sync         └──────────────┘            │
│         │                    │                                 │
│         │                    │                                 │
│         ▼                    ▼                                 │
│  ┌──────────────┐    Queue   ┌──────────────┐                 │
│  │   Task       │───────────▶│   Worker     │                 │
│  │   Producer   │            │   Pool       │                 │
│  └──────────────┘    Async   └──────────────┘                 │
│                                    │                           │
│                                    ▼                           │
│                            ┌──────────────┐                   │
│                            │   Database   │                   │
│                            │   Updates    │                   │
│                            └──────────────┘                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3. The Implementation

#### Step 1: Service Client with Circuit Breaker

**File:** `packages/gateway/src/infrastructure/services/service-client.ts`

```typescript
import { RequestContextManager } from '../adapters/distributed/request-context.js';
import { CircuitBreakerRegistry } from '../adapters/distributed/circuit-breaker.js';
import { RetryManager } from '../adapters/distributed/retry-manager.js';
import { createChildLogger } from '../../logger.js';

/**
 * Service Client Configuration
 */
export interface ServiceClientConfig {
  /** Base URL of the service */
  baseUrl: string;
  
  /** Service name (for circuit breaker) */
  serviceName: string;
  
  /** Default timeout in milliseconds */
  timeout?: number;
  
  /** Circuit breaker configuration */
  circuitBreaker?: {
    failureThreshold?: number;
    resetTimeout?: number;
    halfOpenRequests?: number;
  };
  
  /** Retry configuration */
  retry?: {
    maxAttempts?: number;
    initialDelay?: number;
    maxDelay?: number;
  };
}

/**
 * HTTP Service Client
 * 
 * A robust HTTP client for inter-service communication with:
 * - Circuit breaker protection
 * - Automatic retries with backoff
 * - Request context propagation
 * - Timeout handling
 * - Error transformation
 * 
 * This client wraps fetch() with distributed system patterns.
 */
export class ServiceClient {
  private readonly logger = createChildLogger({ module: 'ServiceClient' });
  private readonly retryManager: RetryManager;
  private readonly circuitBreakerRegistry = CircuitBreakerRegistry.getInstance();

  constructor(private readonly config: ServiceClientConfig) {
    this.retryManager = new RetryManager({
      maxAttempts: config.retry?.maxAttempts || 3,
      initialDelay: config.retry?.initialDelay || 1000,
      maxDelay: config.retry?.maxDelay || 30000,
      backoffMultiplier: 2,
      useJitter: true,
    });
  }

  /**
   * Make a GET request
   */
  async get<T>(
    path: string,
    options?: {
      params?: Record<string, string>;
      headers?: Record<string, string>;
      signal?: AbortSignal;
    }
  ): Promise<T> {
    return this.request<T>('GET', path, { ...options, body: undefined });
  }

  /**
   * Make a POST request
   */
  async post<T>(
    path: string,
    data?: any,
    options?: {
      headers?: Record<string, string>;
      signal?: AbortSignal;
    }
  ): Promise<T> {
    return this.request<T>('POST', path, { ...options, body: data });
  }

  /**
   * Make a PUT request
   */
  async put<T>(
    path: string,
    data?: any,
    options?: {
      headers?: Record<string, string>;
      signal?: AbortSignal;
    }
  ): Promise<T> {
    return this.request<T>('PUT', path, { ...options, body: data });
  }

  /**
   * Make a DELETE request
   */
  async delete<T>(
    path: string,
    options?: {
      headers?: Record<string, string>;
      signal?: AbortSignal;
    }
  ): Promise<T> {
    return this.request<T>('DELETE', path, options);
  }

  /**
   * Core request method with all distributed patterns
   */
  private async request<T>(
    method: string,
    path: string,
    options?: {
      params?: Record<string, string>;
      headers?: Record<string, string>;
      body?: any;
      signal?: AbortSignal;
    }
  ): Promise<T> {
    const startTime = Date.now();
    const url = this.buildUrl(path, options?.params);
    
    // Get request context for propagation
    const context = RequestContextManager.getContext();
    const requestId = context?.requestId || 'unknown';
    
    // Get circuit breaker for this service
    const circuitBreaker = this.circuitBreakerRegistry.getOrCreate(
      this.config.serviceName,
      this.config.circuitBreaker
    );

    this.logger.debug({
      service: this.config.serviceName,
      method,
      url,
      requestId,
    }, 'Service request starting');

    try {
      // Execute with circuit breaker
      const result = await circuitBreaker.execute(
        async (cbSignal) => {
          // Combine signals
          const combinedSignal = this.combineSignals(
            cbSignal,
            options?.signal,
            RequestContextManager.createTimeoutSignal()
          );

          // Execute with retries
          return await this.retryManager.execute(
            () => this.executeRequest<T>(method, url, options, combinedSignal),
            { service: this.config.serviceName, requestId }
          );
        },
        options?.signal
      );

      const duration = Date.now() - startTime;
      this.logger.debug({
        service: this.config.serviceName,
        method,
        url,
        duration,
        requestId,
      }, 'Service request completed');

      return result;

    } catch (error) {
      const duration = Date.now() - startTime;
      const err = error instanceof Error ? error : new Error(String(error));
      
      this.logger.error({
        service: this.config.serviceName,
        method,
        url,
        error: err.message,
        duration,
        requestId,
      }, 'Service request failed');

      // Transform error for consistent handling
      throw this.transformError(err);
    }
  }

  /**
   * Execute the actual HTTP request
   */
  private async executeRequest<T>(
    method: string,
    url: string,
    options?: {
      headers?: Record<string, string>;
      body?: any;
      signal?: AbortSignal;
    },
    signal?: AbortSignal
  ): Promise<T> {
    // Check if aborted
    if (signal?.aborted) {
      throw new Error(`Request cancelled: ${signal.reason || 'no reason'}`);
    }

    // Build headers with context propagation
    const headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
      ...this.getPropagationHeaders(),
      ...(options?.headers || {}),
    };

    // Build fetch options
    const fetchOptions: RequestInit = {
      method,
      headers,
      signal,
    };

    // Add body for non-GET requests
    if (method !== 'GET' && options?.body !== undefined) {
      fetchOptions.body = JSON.stringify(options.body);
    }

    // Execute fetch with timeout
    const response = await fetch(url, fetchOptions);

    // Check for HTTP errors
    if (!response.ok) {
      const errorBody = await response.text().catch(() => '');
      throw new ServiceError(
        `Service returned ${response.status}: ${response.statusText}`,
        response.status,
        errorBody
      );
    }

    // Parse response
    const contentType = response.headers.get('content-type');
    if (contentType?.includes('application/json')) {
      return await response.json();
    }

    // Handle non-JSON responses
    const text = await response.text();
    try {
      return JSON.parse(text) as T;
    } catch {
      return text as T;
    }
  }

  /**
   * Build URL with query parameters
   */
  private buildUrl(path: string, params?: Record<string, string>): string {
    const baseUrl = this.config.baseUrl.replace(/\/+$/, '');
    const pathname = path.startsWith('/') ? path : `/${path}`;
    const url = new URL(baseUrl + pathname);

    if (params) {
      for (const [key, value] of Object.entries(params)) {
        if (value !== undefined && value !== null) {
          url.searchParams.append(key, value);
        }
      }
    }

    return url.toString();
  }

  /**
   * Get propagation headers for distributed tracing
   */
  private getPropagationHeaders(): Record<string, string> {
    const context = RequestContextManager.getContext();
    if (!context) return {};

    return {
      'x-request-id': context.requestId,
      'x-correlation-id': context.correlationId,
      'x-user-id': context.userId || '',
      'x-timeout': String(context.timeout),
    };
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
   * Transform errors for consistent handling
   */
  private transformError(error: Error): Error {
    // Check if it's already a ServiceError
    if (error instanceof ServiceError) {
      return error;
    }

    // Check for network errors
    if (error.message.includes('fetch') || 
        error.message.includes('network') ||
        error.message.includes('ECONNREFUSED')) {
      return new ServiceError(
        `Network error connecting to ${this.config.serviceName}: ${error.message}`,
        503,
        error.message
      );
    }

    // Check for timeout errors
    if (error.message.includes('timeout') || 
        error.message.includes('Timed out')) {
      return new ServiceError(
        `Service ${this.config.serviceName} timed out: ${error.message}`,
        504,
        error.message
      );
    }

    // Pass through other errors
    return error;
  }

  /**
   * Get health of the service
   */
  async healthCheck(): Promise<{ healthy: boolean; details?: any }> {
    try {
      const response = await fetch(`${this.config.baseUrl}/health`);
      const data = await response.json();
      return {
        healthy: response.ok,
        details: data,
      };
    } catch (error) {
      return {
        healthy: false,
        details: { error: String(error) },
      };
    }
  }
}

/**
 * Service Error
 * 
 * Represents an error from a service call with status code
 */
export class ServiceError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number,
    public readonly responseBody?: string
  ) {
    super(message);
    this.name = 'ServiceError';
    Error.captureStackTrace(this, ServiceError);
  }

  /**
   * Check if the error is retryable
   */
  isRetryable(): boolean {
    // Retry on 5xx errors, 429 (rate limit), and 408 (timeout)
    return this.statusCode >= 500 ||
           this.statusCode === 429 ||
           this.statusCode === 408;
  }
}

/**
 * Service Client Factory
 * 
 * Creates service clients with consistent configuration
 */
export class ServiceClientFactory {
  private static clients: Map<string, ServiceClient> = new Map();

  /**
   * Get or create a service client
   */
  static getClient(
    serviceName: string,
    baseUrl: string,
    config?: Partial<ServiceClientConfig>
  ): ServiceClient {
    const key = `${serviceName}:${baseUrl}`;
    
    if (!this.clients.has(key)) {
      this.clients.set(
        key,
        new ServiceClient({
          baseUrl,
          serviceName,
          timeout: 10000,
          retry: {
            maxAttempts: 3,
            initialDelay: 1000,
            maxDelay: 30000,
          },
          circuitBreaker: {
            failureThreshold: 5,
            resetTimeout: 60000,
            halfOpenRequests: 3,
          },
          ...config,
        })
      );
    }

    return this.clients.get(key)!;
  }
}
```

#### Step 2: Service Registry (Discovery)

**File:** `packages/gateway/src/infrastructure/services/service-registry.ts`

```typescript
import { createChildLogger } from '../../logger.js';

/**
 * Service Definition
 */
export interface ServiceDefinition {
  name: string;
  url: string;
  version: string;
  health: string;
  metadata?: Record<string, string>;
  status?: 'healthy' | 'unhealthy' | 'unknown';
  lastChecked?: Date;
}

/**
 * Service Registry
 * 
 * Simple service discovery mechanism.
 * 
 * In a production environment, you would use:
 * - Consul
 * - Eureka
 * - Kubernetes Service Discovery
 * - etcd
 * 
 * This implementation is a simplified version for learning purposes.
 */
export class ServiceRegistry {
  private static instance: ServiceRegistry;
  private services: Map<string, ServiceDefinition> = new Map();
  private readonly logger = createChildLogger({ module: 'ServiceRegistry' });
  private healthCheckInterval: NodeJS.Timeout | null = null;

  private constructor() {
    // Start health checking in the background
    this.startHealthChecks();
  }

  static getInstance(): ServiceRegistry {
    if (!ServiceRegistry.instance) {
      ServiceRegistry.instance = new ServiceRegistry();
    }
    return ServiceRegistry.instance;
  }

  /**
   * Register a service
   */
  register(service: ServiceDefinition): void {
    this.services.set(service.name, {
      ...service,
      status: 'unknown',
    });
    this.logger.info({ service: service.name, url: service.url }, 'Service registered');
  }

  /**
   * Unregister a service
   */
  unregister(name: string): void {
    this.services.delete(name);
    this.logger.info({ service: name }, 'Service unregistered');
  }

  /**
   * Get a service by name
   */
  getService(name: string): ServiceDefinition | undefined {
    return this.services.get(name);
  }

  /**
   * Get all services
   */
  getAllServices(): ServiceDefinition[] {
    return Array.from(this.services.values());
  }

  /**
   * Get healthy services
   */
  getHealthyServices(): ServiceDefinition[] {
    return Array.from(this.services.values())
      .filter(s => s.status === 'healthy');
  }

  /**
   * Update service health
   */
  updateHealth(name: string, healthy: boolean): void {
    const service = this.services.get(name);
    if (!service) return;

    service.status = healthy ? 'healthy' : 'unhealthy';
    service.lastChecked = new Date();
  }

  /**
   * Start automatic health checks
   */
  private startHealthChecks(): void {
    // Run health checks every 30 seconds
    this.healthCheckInterval = setInterval(async () => {
      await this.checkAllServices();
    }, 30000);

    // Run first check immediately
    setTimeout(() => this.checkAllServices(), 1000);
  }

  /**
   * Check health of all registered services
   */
  private async checkAllServices(): Promise<void> {
    const services = Array.from(this.services.values());
    
    for (const service of services) {
      try {
        const response = await fetch(`${service.url}${service.health}`, {
          signal: AbortSignal.timeout(5000),
        });
        
        const healthy = response.ok;
        this.updateHealth(service.name, healthy);
        
        if (!healthy) {
          this.logger.warn({
            service: service.name,
            status: response.status,
          }, 'Service health check failed');
        }
      } catch (error) {
        this.updateHealth(service.name, false);
        this.logger.error({
          service: service.name,
          error: String(error),
        }, 'Service health check error');
      }
    }
  }

  /**
   * Stop health checks
   */
  stop(): void {
    if (this.healthCheckInterval) {
      clearInterval(this.healthCheckInterval);
      this.healthCheckInterval = null;
    }
  }

  /**
   * Get service metrics
   */
  getMetrics() {
    const services = this.getAllServices();
    const healthy = services.filter(s => s.status === 'healthy').length;
    const total = services.length;

    return {
      total,
      healthy,
      unhealthy: total - healthy,
      services: services.map(s => ({
        name: s.name,
        status: s.status,
        version: s.version,
        url: s.url,
      })),
    };
  }
}

/**
 * Service Discovery Middleware
 * 
 * Automatically discovers and registers services from environment
 */
export function discoverServices(): void {
  const registry = ServiceRegistry.getInstance();
  
  // Register services from environment variables
  const serviceUrls = {
    auth: process.env.AUTH_SERVICE_URL,
    user: process.env.USER_SERVICE_URL,
    task: process.env.TASK_SERVICE_URL,
  };

  for (const [name, url] of Object.entries(serviceUrls)) {
    if (url) {
      registry.register({
        name,
        url,
        version: process.env[`${name.toUpperCase()}_SERVICE_VERSION`] || '1.0.0',
        health: '/health',
      });
    }
  }

  // In a real system, you would also:
  // 1. Use DNS SRV records
  // 2. Query Consul/etcd
  // 3. Use Kubernetes service discovery
  // 4. Read from a configuration service
}
```

#### Step 3: Message Queue Interface

**File:** `packages/gateway/src/infrastructure/adapters/messaging/in-memory/task-queue.ts`

```typescript
import { EventEmitter } from 'events';
import { createChildLogger } from '../../../../logger.js';

/**
 * Task Message
 */
export interface TaskMessage<T = any> {
  id: string;
  type: string;
  payload: T;
  timestamp: Date;
  retries: number;
  maxRetries: number;
  delay?: number;
}

/**
 * In-Memory Task Queue
 * 
 * A simple in-memory message queue for development and testing.
 * 
 * In production, you would use:
 * - RabbitMQ
 * - Redis (with Bull or similar)
 * - AWS SQS
 * - Apache Kafka
 * 
 * This implementation demonstrates the queue pattern without
 * requiring external dependencies for development.
 */
export class InMemoryTaskQueue extends EventEmitter {
  private queues: Map<string, TaskMessage[]> = new Map();
  private processing: Map<string, boolean> = new Map();
  private readonly logger = createChildLogger({ module: 'InMemoryTaskQueue' });
  private isRunning = true;

  constructor() {
    super();
    this.startProcessing();
  }

  /**
   * Publish a message to a queue
   */
  async publish<T>(queue: string, message: Omit<TaskMessage<T>, 'id' | 'timestamp' | 'retries'>): Promise<void> {
    const fullMessage: TaskMessage<T> = {
      id: `msg_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`,
      timestamp: new Date(),
      retries: 0,
      ...message,
    };

    if (!this.queues.has(queue)) {
      this.queues.set(queue, []);
    }

    this.queues.get(queue)!.push(fullMessage);
    
    this.logger.debug({
      queue,
      messageId: fullMessage.id,
      type: fullMessage.type,
    }, 'Message published');

    // Emit event for processing
    this.emit('message', queue);
  }

  /**
   * Consume messages from a queue
   */
  async consume<T>(
    queue: string,
    handler: (message: TaskMessage<T>) => Promise<void>
  ): Promise<void> {
    if (!this.queues.has(queue)) {
      this.queues.set(queue, []);
    }

    // Start processing messages
    while (this.isRunning) {
      const messages = this.queues.get(queue) || [];
      
      if (messages.length === 0) {
        // Wait for messages
        await new Promise(resolve => {
          const listener = () => {
            this.removeListener('message', listener);
            resolve(null);
          };
          this.once('message', listener);
        });
        continue;
      }

      // Get the next message
      const message = messages.shift() as TaskMessage<T>;
      
      try {
        this.logger.debug({
          queue,
          messageId: message.id,
          type: message.type,
        }, 'Processing message');

        // Process the message
        await handler(message);

        this.logger.debug({
          queue,
          messageId: message.id,
        }, 'Message processed successfully');

      } catch (error) {
        const err = error instanceof Error ? error : new Error(String(error));
        
        this.logger.error({
          queue,
          messageId: message.id,
          error: err.message,
          retries: message.retries,
        }, 'Message processing failed');

        // Check if we should retry
        if (message.retries < message.maxRetries) {
          message.retries++;
          
          // Add delay for retry (exponential backoff)
          const delay = message.delay || 1000 * Math.pow(2, message.retries - 1);
          message.delay = Math.min(delay, 30000);
          
          // Re-queue with delay
          setTimeout(() => {
            if (!this.queues.has(queue)) {
              this.queues.set(queue, []);
            }
            this.queues.get(queue)!.push(message);
            this.emit('message', queue);
          }, message.delay);
        } else {
          // Max retries exceeded - send to dead letter queue
          this.logger.warn({
            queue,
            messageId: message.id,
            type: message.type,
            retries: message.retries,
          }, 'Max retries exceeded - moving to dead letter queue');
          
          await this.publish('dead-letter', {
            ...message,
            type: 'dead_letter',
            payload: {
              originalQueue: queue,
              originalMessage: message,
              error: err.message,
            },
          });
        }
      }

      // Small delay to prevent CPU spinning
      await new Promise(resolve => setTimeout(resolve, 10));
    }
  }

  /**
   * Start processing loop
   */
  private startProcessing(): void {
    this.isRunning = true;
  }

  /**
   * Stop processing
   */
  stop(): void {
    this.isRunning = false;
  }

  /**
   * Get queue statistics
   */
  getStats(queue?: string): Record<string, { size: number; processing: boolean }> {
    const stats: Record<string, { size: number; processing: boolean }> = {};
    
    const queues = queue ? [queue] : Array.from(this.queues.keys());
    
    for (const q of queues) {
      const messages = this.queues.get(q) || [];
      stats[q] = {
        size: messages.length,
        processing: this.processing.get(q) || false,
      };
    }
    
    return stats;
  }

  /**
   * Clear a queue
   */
  clear(queue: string): void {
    this.queues.set(queue, []);
    this.logger.debug({ queue }, 'Queue cleared');
  }
}

// Singleton instance
export const taskQueue = new InMemoryTaskQueue();
```

#### Step 4: Task Worker Service

**File:** `packages/gateway/src/infrastructure/workers/task-worker.ts`

```typescript
import { TaskMessage, taskQueue } from '../adapters/messaging/in-memory/task-queue.js';
import { ServiceClientFactory } from '../services/service-client.js';
import { createChildLogger } from '../../logger.js';

/**
 * Task Types
 */
export enum TaskType {
  PROCESS_TASK = 'process_task',
  UPDATE_TASK_STATUS = 'update_task_status',
  NOTIFY_USER = 'notify_user',
  GENERATE_REPORT = 'generate_report',
}

/**
 * Task Payloads
 */
export interface ProcessTaskPayload {
  taskId: string;
  userId: string;
  action: 'process' | 'approve' | 'reject';
  data?: any;
}

export interface UpdateTaskStatusPayload {
  taskId: string;
  userId: string;
  status: string;
  reason?: string;
}

export interface NotifyUserPayload {
  userId: string;
  type: 'email' | 'sms' | 'push';
  subject: string;
  body: string;
}

/**
 * Task Worker
 * 
 * Processes background tasks asynchronously.
 * 
 * The worker:
 * 1. Listens for messages on the task queue
 * 2. Processes each message
 * 3. Handles errors and retries
 * 4. Updates status when complete
 */
export class TaskWorker {
  private readonly logger = createChildLogger({ module: 'TaskWorker' });
  private isRunning = false;

  /**
   * Start the worker
   */
  async start(): Promise<void> {
    if (this.isRunning) {
      this.logger.warn('Worker already running');
      return;
    }

    this.isRunning = true;
    this.logger.info('Task worker started');

    // Consume messages from the task queue
    await taskQueue.consume<TaskMessage<any>>('tasks', async (message) => {
      await this.processMessage(message);
    });
  }

  /**
   * Process a single message
   */
  private async processMessage(message: TaskMessage<any>): Promise<void> {
    this.logger.info({
      messageId: message.id,
      type: message.type,
    }, 'Processing task');

    try {
      switch (message.type) {
        case TaskType.PROCESS_TASK:
          await this.processTask(message.payload);
          break;

        case TaskType.UPDATE_TASK_STATUS:
          await this.updateTaskStatus(message.payload);
          break;

        case TaskType.NOTIFY_USER:
          await this.notifyUser(message.payload);
          break;

        case TaskType.GENERATE_REPORT:
          await this.generateReport(message.payload);
          break;

        default:
          this.logger.warn({
            messageId: message.id,
            type: message.type,
          }, 'Unknown task type');
      }

      this.logger.info({
        messageId: message.id,
        type: message.type,
      }, 'Task processed successfully');

    } catch (error) {
      const err = error instanceof Error ? error : new Error(String(error));
      
      this.logger.error({
        messageId: message.id,
        type: message.type,
        error: err.message,
      }, 'Task processing failed');

      throw error; // Let the queue handle retry
    }
  }

  /**
   * Process a task (business logic)
   */
  private async processTask(payload: ProcessTaskPayload): Promise<void> {
    this.logger.debug({ payload }, 'Processing task action');

    // Simulate processing
    await this.simulateWork(1000, 3000);

    // Update task status
    await this.updateTaskStatus({
      taskId: payload.taskId,
      userId: payload.userId,
      status: payload.action === 'process' ? 'processed' : 
              payload.action === 'approve' ? 'approved' : 'rejected',
      reason: payload.action === 'reject' ? 'Rejected by user' : undefined,
    });
  }

  /**
   * Update task status
   */
  private async updateTaskStatus(payload: UpdateTaskStatusPayload): Promise<void> {
    this.logger.debug({ payload }, 'Updating task status');

    // Call the task service to update status
    const taskClient = ServiceClientFactory.getClient(
      'task-service',
      process.env.TASK_SERVICE_URL || 'http://localhost:3000'
    );

    await taskClient.put(`/api/tasks/${payload.taskId}`, {
      userId: payload.userId,
      status: payload.status,
      ...(payload.reason && { metadata: { reason: payload.reason } }),
    });
  }

  /**
   * Notify a user
   */
  private async notifyUser(payload: NotifyUserPayload): Promise<void> {
    this.logger.debug({ payload }, 'Notifying user');

    // In production, you would:
    // 1. Send an email via SES/SendGrid
    // 2. Send an SMS via Twilio
    // 3. Send a push notification via Firebase
    
    // Simulate notification
    await this.simulateWork(500, 2000);
  }

  /**
   * Generate a report
   */
  private async generateReport(payload: any): Promise<void> {
    this.logger.debug({ payload }, 'Generating report');

    // In production, you would:
    // 1. Query the database for data
    // 2. Generate PDF/CSV
    // 3. Upload to S3
    // 4. Notify the user

    // Simulate report generation
    await this.simulateWork(5000, 15000);
  }

  /**
   * Simulate work with random duration
   */
  private async simulateWork(minMs: number, maxMs: number): Promise<void> {
    const duration = minMs + Math.random() * (maxMs - minMs);
    await new Promise(resolve => setTimeout(resolve, duration));
  }

  /**
   * Stop the worker
   */
  stop(): void {
    this.isRunning = false;
    this.logger.info('Task worker stopped');
  }
}

/**
 * Worker Pool
 * 
 * Manages multiple task workers for concurrent processing
 */
export class WorkerPool {
  private workers: TaskWorker[] = [];
  private readonly logger = createChildLogger({ module: 'WorkerPool' });

  constructor(private readonly workerCount: number = 5) {}

  /**
   * Start all workers
   */
  async start(): Promise<void> {
    this.logger.info({ count: this.workerCount }, 'Starting worker pool');

    const workers = Array.from({ length: this.workerCount }, () => new TaskWorker());
    
    await Promise.all(workers.map(worker => worker.start()));
    
    this.workers = workers;
    this.logger.info('Worker pool started');
  }

  /**
   * Stop all workers
   */
  stop(): void {
    this.logger.info('Stopping worker pool');
    
    for (const worker of this.workers) {
      worker.stop();
    }
    
    this.workers = [];
    this.logger.info('Worker pool stopped');
  }

  /**
   * Get worker status
   */
  getStatus(): {
    workerCount: number;
    workers: { running: boolean }[];
  } {
    return {
      workerCount: this.workers.length,
      workers: this.workers.map(() => ({
        running: this.workers.length > 0,
      })),
    };
  }
}
```

#### Step 5: Task Service Integration

**File:** `packages/gateway/src/core/application/handlers/task.handlers.ts` (Updated)

Add this method to the TaskCommandHandler:

```typescript
/**
 * Submit a task for background processing
 */
async handleSubmitTaskForProcessing(
  taskId: string,
  userId: string,
  action: 'process' | 'approve' | 'reject'
): Promise<void> {
  this.logger.info({ taskId, userId, action }, 'Submitting task for processing');
  
  // Get the task to verify it exists
  const task = await this.taskService.getTaskById(taskId, userId);
  if (!task) {
    throw new Error('Task not found');
  }

  // Submit to queue for background processing
  await taskQueue.publish('tasks', {
    type: TaskType.PROCESS_TASK,
    payload: {
      taskId,
      userId,
      action,
      data: task.toJSON(),
    },
    maxRetries: 3,
  });

  // Update task status to in_progress
  await this.taskService.startTask(taskId, userId);
  
  this.logger.info({ taskId, userId }, 'Task submitted for processing');
}
```

#### Step 6: Update Server to Start Workers

**File:** `packages/gateway/src/server.ts` (Updated)

Add to the Server class:

```typescript
import { WorkerPool } from './infrastructure/workers/task-worker.js';
import { discoverServices } from './infrastructure/services/service-registry.js';

export class Server {
  private workerPool: WorkerPool | null = null;

  // Add to constructor after setupControllers()
  private setupWorkers(): void {
    this.logger.info('Setting up task workers...');
    
    // Get worker count from environment
    const workerCount = parseInt(process.env.WORKER_COUNT || '5', 10);
    this.workerPool = new WorkerPool(workerCount);
    
    // Start workers in the background
    this.workerPool.start().catch((error) => {
      this.logger.error({ error }, 'Failed to start workers');
    });
  }

  // Add to constructor after setupWorkers()
  private setupServiceDiscovery(): void {
    this.logger.info('Discovering services...');
    discoverServices();
  }

  // Update shutdown method
  private async shutdown(): Promise<void> {
    const shutdownTimeout = 30000;
    
    this.logger.info('Beginning graceful shutdown...');
    
    // Stop workers first
    if (this.workerPool) {
      this.logger.info('Stopping workers...');
      this.workerPool.stop();
    }
    
    // Close server
    await this.app.close();
    this.logger.info('Server stopped accepting new connections');
    
    // Wait for connections
    const connectionCount = this.connections.size;
    this.logger.info(`Waiting for ${connectionCount} connections to finish...`);
    
    if (connectionCount > 0) {
      await Promise.race([
        this.waitForConnections(),
        new Promise(resolve => setTimeout(resolve, shutdownTimeout)),
      ]);
    }
    
    // Force close remaining
    this.closeConnections();
    
    // Close database connections
    await postgresConnection.disconnect().catch(() => {});
    
    // Close Redis connection
    await redisConnection.disconnect().catch(() => {});
    
    // Stop service registry
    ServiceRegistry.getInstance().stop();
    
    this.logger.info('Graceful shutdown complete');
  }
}
```

### 4. The Verification

#### Step 1: Start Services

```bash
# Start PostgreSQL and Redis
cd packages/gateway
docker-compose up -d postgres redis

# Start the gateway service
npm run dev
```

#### Step 2: Test Service Client

Create a test script:

**File:** `packages/gateway/tests/manual/service-client.test.ts`

```typescript
import { ServiceClientFactory } from '../../src/infrastructure/services/service-client.js';

async function testServiceClient() {
  const client = ServiceClientFactory.getClient(
    'test-service',
    'https://jsonplaceholder.typicode.com'
  );

  try {
    // Test GET
    const posts = await client.get('/posts/1');
    console.log('✅ GET successful:', posts);
    
    // Test with retry
    const users = await client.get('/users', {
      params: { id: '1' },
    });
    console.log('✅ GET with params successful:', users);
    
  } catch (error) {
    console.error('❌ Service client test failed:', error);
  }
}

testServiceClient();
```

Run the test:
```bash
npx tsx tests/manual/service-client.test.ts
```

#### Step 3: Test Task Queue

**File:** `packages/gateway/tests/manual/task-queue.test.ts`

```typescript
import { taskQueue } from '../../src/infrastructure/adapters/messaging/in-memory/task-queue.js';
import { TaskWorker } from '../../src/infrastructure/workers/task-worker.js';

async function testTaskQueue() {
  console.log('Testing task queue...');
  
  // Start a worker
  const worker = new TaskWorker();
  worker.start().catch(console.error);
  
  // Publish a task
  await taskQueue.publish('tasks', {
    type: 'notify_user',
    payload: {
      userId: 'user-123',
      type: 'email',
      subject: 'Test Notification',
      body: 'This is a test notification from the task queue.',
    },
    maxRetries: 3,
  });
  
  console.log('✅ Task published');
  
  // Wait for processing
  await new Promise(resolve => setTimeout(resolve, 5000));
  
  console.log('✅ Task should be processed');
  
  // Stop worker
  worker.stop();
}

testTaskQueue().catch(console.error);
```

#### Step 4: Test Task Submission API

Create a task and submit it for processing:

```bash
# Create a user
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "worker-test@example.com",
    "username": "workertest",
    "password": "SecurePass123",
    "firstName": "Worker",
    "lastName": "Test"
  }'

# Save the userId from response

# Create a task
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Process this task",
    "description": "This task will be processed by the worker",
    "userId": "YOUR_USER_ID",
    "priority": "high"
  }'

# Save the taskId from response

# Submit for processing
curl -X POST http://localhost:3000/api/tasks/TASK_ID/process \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "YOUR_USER_ID",
    "action": "process"
  }'
```

Expected response:
```json
{
  "success": true,
  "message": "Task submitted for processing"
}
```

#### Step 5: Check Queue Stats

Add a metrics endpoint for the queue:

**File:** `packages/gateway/src/server.ts` (Add to registerRoutes)

```typescript
// Add to registerRoutes method
this.app.get('/queue/stats', async (request, reply) => {
  const stats = taskQueue.getStats();
  return reply.send({
    success: true,
    stats,
  });
});

this.app.get('/queue/stats/:queue', async (request, reply) => {
  const { queue } = request.params as { queue: string };
  const stats = taskQueue.getStats(queue);
  return reply.send({
    success: true,
    stats: stats[queue] || { size: 0, processing: false },
  });
});
```

Check queue stats:
```bash
curl http://localhost:3000/queue/stats
```

Expected response:
```json
{
  "success": true,
  "stats": {
    "tasks": {
      "size": 0,
      "processing": true
    },
    "dead-letter": {
      "size": 0,
      "processing": false
    }
  }
}
```

### 5. Deep Dive: Service Communication Patterns

#### Synchronous vs Asynchronous Communication

**Synchronous (HTTP/REST):**

Pros:
- Simple to implement
- Request-response pattern
- Easy to trace

Cons:
- Tight coupling
- Service availability issues
- Blocking operations

**Asynchronous (Message Queues):**

Pros:
- Decoupled services
- Better fault tolerance
- Load leveling

Cons:
- More complex setup
- Eventual consistency
- Harder to debug

#### Message Queue Patterns

**Queue Types:**
1. **Point-to-Point:** One producer, one consumer
2. **Pub/Sub:** One producer, multiple consumers
3. **Work Queue:** One producer, multiple consumers competing for work

**Delivery Semantics:**
1. **At-most-once:** Message may be lost
2. **At-least-once:** Message may be delivered multiple times
3. **Exactly-once:** Message delivered exactly once (hard)

**Dead Letter Queue:**
Messages that fail processing go to a dead letter queue for:
- Manual inspection
- Reprocessing
- Debugging

### 6. Summary

**What We Built:**
- ✅ HTTP service client with circuit breaker and retry
- ✅ Service discovery and registration
- ✅ In-memory task queue
- ✅ Task worker for background processing
- ✅ Worker pool for concurrent processing
- ✅ Complete task processing pipeline
- ✅ Queue monitoring endpoints

**Key Concepts Learned:**
- Service communication patterns (sync vs async)
- Circuit breaker integration with HTTP client
- Message queue patterns
- Background processing with workers
- Service discovery patterns
- Task queue monitoring

**What's Next:**
In Part 3 of Phase 3, we'll add request cancellation propagation, implement the final components of the distributed system, and create end-to-end tests that validate the entire flow from API to worker processing.

**Verification Checklist:**
- [ ] Service client works with circuit breaker
- [ ] Service registry discovers services
- [ ] Task queue processes messages
- [ ] Worker handles tasks asynchronously
- [ ] Task submission flow works end-to-end
- [ ] Queue stats endpoint returns data
- [ ] Graceful shutdown handles workers properly
