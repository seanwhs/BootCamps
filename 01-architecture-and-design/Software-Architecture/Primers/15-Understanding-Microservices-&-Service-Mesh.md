# Primer 15: Understanding Microservices & Service Mesh

## A Comprehensive Guide to Building Microservices Architectures

Welcome to the fifteenth primer! This is a comprehensive deep dive into microservices and service mesh - the architectural patterns that enable building large-scale, distributed systems with independent deployable services. Think of this like building a city where each building (service) operates independently but they all connect through a transportation network (service mesh).

### 1. The Big Picture

#### Microservices Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    MICROSERVICES ARCHITECTURE                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    API GATEWAY                                      │   │
│  │  • Routing • Authentication • Rate Limiting • Load Balancing      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    SERVICE MESH                                     │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │   Sidecar    │  │   Sidecar    │  │   Sidecar    │              │   │
│  │  │   Proxy      │  │   Proxy      │  │   Proxy      │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    SERVICES                                         │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │   User       │  │   Task       │  │   Analytics  │              │   │
│  │  │   Service    │  │   Service    │  │   Service    │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    DATA LAYER                                       │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │   User DB    │  │   Task DB    │  │   Analytics  │              │   │
│  │  │   (Primary)  │  │   (Primary)  │  │   (Data)     │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Microservices Design Patterns

#### Service Discovery

```typescript
interface ServiceInstance {
    id: string;
    serviceName: string;
    host: string;
    port: number;
    healthy: boolean;
    metadata: Record<string, string>;
    lastHeartbeat: Date;
}

class ServiceRegistry {
    private instances: Map<string, ServiceInstance[]> = new Map();
    private logger: Logger;

    constructor() {
        this.logger = createLogger({ service: 'service-registry' });
    }

    register(instance: ServiceInstance): void {
        if (!this.instances.has(instance.serviceName)) {
            this.instances.set(instance.serviceName, []);
        }

        const instances = this.instances.get(instance.serviceName)!;
        const existing = instances.findIndex(i => i.id === instance.id);
        
        if (existing !== -1) {
            instances[existing] = instance;
        } else {
            instances.push(instance);
        }

        this.logger.info({
            service: instance.serviceName,
            id: instance.id,
            total: instances.length,
        }, 'Service registered');
    }

    deregister(serviceName: string, instanceId: string): void {
        const instances = this.instances.get(serviceName);
        if (!instances) return;

        const index = instances.findIndex(i => i.id === instanceId);
        if (index !== -1) {
            instances.splice(index, 1);
            this.logger.info({
                service: serviceName,
                id: instanceId,
            }, 'Service deregistered');
        }
    }

    getInstances(serviceName: string): ServiceInstance[] {
        const instances = this.instances.get(serviceName) || [];
        return instances.filter(i => i.healthy);
    }

    getInstance(serviceName: string): ServiceInstance | null {
        const instances = this.getInstances(serviceName);
        if (instances.length === 0) return null;

        // Load balancing - round robin
        return this.roundRobin(instances);
    }

    private roundRobin(instances: ServiceInstance[]): ServiceInstance {
        // Simple round-robin implementation
        const index = Math.floor(Math.random() * instances.length);
        return instances[index];
    }

    async healthCheck(): Promise<void> {
        const now = Date.now();
        const timeout = 30000; // 30 seconds

        for (const [serviceName, instances] of this.instances) {
            for (const instance of instances) {
                if (now - instance.lastHeartbeat.getTime() > timeout) {
                    instance.healthy = false;
                    this.logger.warn({
                        service: serviceName,
                        instance: instance.id,
                    }, 'Instance marked unhealthy');
                }
            }
        }
    }
}
```

#### API Gateway Pattern

```typescript
import fastify from 'fastify';
import { ServiceRegistry } from './service-registry.js';

class APIGateway {
    private app: FastifyInstance;
    private serviceRegistry: ServiceRegistry;
    private logger: Logger;

    constructor(serviceRegistry: ServiceRegistry) {
        this.app = fastify({
            logger: true,
        });
        this.serviceRegistry = serviceRegistry;
        this.logger = createLogger({ service: 'api-gateway' });
        
        this.setupRoutes();
        this.setupMiddleware();
    }

    private setupMiddleware(): void {
        // Authentication middleware
        this.app.addHook('preHandler', async (request, reply) => {
            const authHeader = request.headers.authorization;
            if (authHeader) {
                try {
                    const token = authHeader.replace('Bearer ', '');
                    const decoded = await this.verifyToken(token);
                    request.user = decoded;
                } catch (error) {
                    // Continue without authentication
                }
            }
        });

        // Request logging
        this.app.addHook('preHandler', (request, reply, done) => {
            request.startTime = Date.now();
            done();
        });

        this.app.addHook('onResponse', (request, reply, done) => {
            const duration = Date.now() - request.startTime;
            this.logger.info({
                method: request.method,
                url: request.url,
                status: reply.statusCode,
                duration,
            }, 'Request processed');
            done();
        });
    }

    private setupRoutes(): void {
        // Route all requests through gateway
        this.app.all('/*', async (request, reply) => {
            const path = request.url;
            const method = request.method;

            try {
                // Route based on path prefix
                const service = this.routeToService(path);
                const instance = this.serviceRegistry.getInstance(service);

                if (!instance) {
                    reply.status(503).send({
                        error: 'Service Unavailable',
                        message: `No healthy instance of ${service}`,
                    });
                    return;
                }

                // Forward request to service
                const response = await this.forwardRequest(
                    instance,
                    method,
                    path,
                    request.body,
                    request.headers
                );

                reply.status(response.status).send(response.data);
            } catch (error) {
                this.logger.error({ error, path }, 'Request failed');
                reply.status(500).send({
                    error: 'Internal Server Error',
                    message: error.message,
                });
            }
        });
    }

    private routeToService(path: string): string {
        const routes: Record<string, string> = {
            '/api/users': 'user-service',
            '/api/tasks': 'task-service',
            '/api/auth': 'auth-service',
            '/api/analytics': 'analytics-service',
        };

        for (const [prefix, service] of Object.entries(routes)) {
            if (path.startsWith(prefix)) {
                return service;
            }
        }

        return 'default-service';
    }

    private async forwardRequest(
        instance: ServiceInstance,
        method: string,
        path: string,
        body: any,
        headers: Record<string, string>
    ): Promise<{ status: number; data: any }> {
        const url = `http://${instance.host}:${instance.port}${path}`;
        
        const response = await fetch(url, {
            method,
            headers: {
                'Content-Type': 'application/json',
                ...headers,
            },
            body: body ? JSON.stringify(body) : undefined,
        });

        const data = await response.json();
        return {
            status: response.status,
            data,
        };
    }

    private async verifyToken(token: string): Promise<any> {
        // JWT verification
        // Implementation omitted for brevity
        return { id: 'user-123' };
    }

    async start(port: number): Promise<void> {
        try {
            await this.app.listen({ port });
            this.logger.info(`API Gateway started on port ${port}`);
        } catch (error) {
            this.logger.error({ error }, 'Failed to start API Gateway');
            throw error;
        }
    }
}
```

### 3. Service Mesh Concepts

#### Circuit Breaker with Service Mesh

```typescript
class ServiceMeshCircuitBreaker {
    private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';
    private failureCount: number = 0;
    private failureThreshold: number = 5;
    private resetTimeout: number = 60000;
    private halfOpenTimeout: number = 10000;
    private lastFailureTime: number = 0;
    private logger: Logger;

    constructor() {
        this.logger = createLogger({ service: 'circuit-breaker' });
    }

    async execute<T>(
        serviceName: string,
        operation: () => Promise<T>,
        fallback?: () => Promise<T>
    ): Promise<T> {
        this.checkState();

        if (this.state === 'OPEN') {
            this.logger.warn({ service: serviceName }, 'Circuit breaker open');
            if (fallback) {
                return await fallback();
            }
            throw new Error(`Circuit breaker open for ${serviceName}`);
        }

        try {
            const result = await operation();
            this.onSuccess(serviceName);
            return result;
        } catch (error) {
            this.onFailure(serviceName);
            if (fallback) {
                return await fallback();
            }
            throw error;
        }
    }

    private checkState(): void {
        if (this.state === 'OPEN') {
            if (Date.now() - this.lastFailureTime > this.resetTimeout) {
                this.state = 'HALF_OPEN';
                this.logger.info('Circuit breaker half open');
            }
        }
    }

    private onSuccess(serviceName: string): void {
        if (this.state === 'HALF_OPEN') {
            this.state = 'CLOSED';
            this.failureCount = 0;
            this.logger.info({ service: serviceName }, 'Circuit breaker closed');
        }
        this.failureCount = Math.max(0, this.failureCount - 1);
    }

    private onFailure(serviceName: string): void {
        this.failureCount++;
        this.lastFailureTime = Date.now();

        if (this.state === 'HALF_OPEN') {
            this.state = 'OPEN';
            this.logger.warn({ service: serviceName }, 'Circuit breaker opened');
            return;
        }

        if (this.failureCount >= this.failureThreshold) {
            this.state = 'OPEN';
            this.logger.warn({
                service: serviceName,
                failureCount: this.failureCount,
            }, 'Circuit breaker opened');
        }
    }
}
```

#### Retry & Timeout Policies

```typescript
class ServiceMeshRetryPolicy {
    private logger: Logger;

    constructor(
        private maxRetries: number = 3,
        private initialDelay: number = 1000,
        private maxDelay: number = 30000,
        private backoffMultiplier: number = 2
    ) {
        this.logger = createLogger({ service: 'retry-policy' });
    }

    async execute<T>(
        operation: () => Promise<T>,
        context?: Record<string, any>
    ): Promise<T> {
        let lastError: Error | null = null;
        let attempt = 0;
        let delay = this.initialDelay;

        while (attempt < this.maxRetries) {
            attempt++;
            
            try {
                const result = await operation();
                this.logger.debug({
                    attempt,
                    success: true,
                    ...context,
                }, 'Operation succeeded');
                return result;
            } catch (error) {
                lastError = error instanceof Error ? error : new Error(String(error));
                
                this.logger.warn({
                    attempt,
                    error: lastError.message,
                    ...context,
                }, 'Operation failed, retrying');

                if (attempt === this.maxRetries) {
                    break;
                }

                // Wait with jitter
                const jitter = 0.8 + Math.random() * 0.4;
                const waitTime = Math.min(delay * jitter, this.maxDelay);
                await this.sleep(waitTime);
                delay *= this.backoffMultiplier;
            }
        }

        throw lastError;
    }

    private sleep(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
```

### 4. Distributed Tracing in Service Mesh

```typescript
class ServiceMeshTracer {
    private spans: Map<string, Span> = new Map();
    private logger: Logger;

    constructor() {
        this.logger = createLogger({ service: 'tracer' });
    }

    startSpan(
        name: string,
        context?: TraceContext
    ): TraceSpan {
        const traceId = context?.traceId || this.generateId();
        const spanId = this.generateId();
        const parentSpanId = context?.spanId;

        const span: TraceSpan = {
            traceId,
            spanId,
            parentSpanId,
            name,
            startTime: Date.now(),
            attributes: {
                service: process.env.SERVICE_NAME || 'unknown',
            },
            events: [],
            status: 'unknown',
        };

        this.spans.set(spanId, span);
        this.logger.debug({
            traceId,
            spanId,
            parentSpanId,
            name,
        }, 'Span started');

        return {
            span,
            injectHeaders: this.getPropagationHeaders(traceId, spanId),
        };
    }

    endSpan(spanId: string, status: 'ok' | 'error' = 'ok'): void {
        const span = this.spans.get(spanId);
        if (!span) return;

        span.endTime = Date.now();
        span.duration = span.endTime - span.startTime;
        span.status = status;

        this.logger.debug({
            spanId,
            duration: span.duration,
            status,
        }, 'Span ended');
    }

    private getPropagationHeaders(traceId: string, spanId: string): Record<string, string> {
        return {
            'x-trace-id': traceId,
            'x-span-id': spanId,
        };
    }

    private generateId(): string {
        return `${Date.now()}_${Math.random().toString(36).slice(2, 9)}`;
    }

    getTrace(traceId: string): TraceSpan[] {
        const result: TraceSpan[] = [];
        for (const span of this.spans.values()) {
            if (span.traceId === traceId) {
                result.push(span);
            }
        }
        return result.sort((a, b) => a.startTime - b.startTime);
    }
}

interface TraceContext {
    traceId: string;
    spanId: string;
}

interface TraceSpan {
    traceId: string;
    spanId: string;
    parentSpanId?: string;
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
```

### 5. Service Mesh Middleware

```typescript
class ServiceMeshMiddleware {
    private circuitBreaker: ServiceMeshCircuitBreaker;
    private retryPolicy: ServiceMeshRetryPolicy;
    private tracer: ServiceMeshTracer;
    private logger: Logger;

    constructor() {
        this.circuitBreaker = new ServiceMeshCircuitBreaker();
        this.retryPolicy = new ServiceMeshRetryPolicy();
        this.tracer = new ServiceMeshTracer();
        this.logger = createLogger({ service: 'service-mesh' });
    }

    async callService<T>(
        serviceName: string,
        operation: () => Promise<T>,
        context?: {
            retryable?: boolean;
            timeout?: number;
            traceContext?: TraceContext;
        }
    ): Promise<T> {
        // Start trace
        const trace = this.tracer.startSpan(
            `call_${serviceName}`,
            context?.traceContext
        );

        try {
            // Execute with circuit breaker, retry, and timeout
            const result = await this.circuitBreaker.execute(
                serviceName,
                async () => {
                    return this.retryPolicy.execute(
                        async () => {
                            if (context?.timeout) {
                                return this.withTimeout(operation, context.timeout);
                            }
                            return operation();
                        },
                        { service: serviceName }
                    );
                },
                // Fallback
                async () => {
                    this.logger.warn({ service: serviceName }, 'Circuit breaker fallback');
                    return null as T;
                }
            );

            if (result === null) {
                throw new Error(`Service ${serviceName} unavailable`);
            }

            this.tracer.endSpan(trace.span.spanId, 'ok');
            return result;
        } catch (error) {
            this.tracer.endSpan(trace.span.spanId, 'error');
            throw error;
        }
    }

    private withTimeout<T>(
        operation: () => Promise<T>,
        timeoutMs: number
    ): Promise<T> {
        return new Promise((resolve, reject) => {
            const timeout = setTimeout(() => {
                reject(new Error(`Operation timed out after ${timeoutMs}ms`));
            }, timeoutMs);

            operation()
                .then(result => {
                    clearTimeout(timeout);
                    resolve(result);
                })
                .catch(error => {
                    clearTimeout(timeout);
                    reject(error);
                });
        });
    }

    // Middleware for incoming requests
    handleIncoming(request: any, next: () => Promise<any>): Promise<any> {
        // Extract trace context from headers
        const traceContext: TraceContext = {
            traceId: request.headers['x-trace-id'] || this.generateId(),
            spanId: request.headers['x-span-id'] || this.generateId(),
        };

        // Start trace
        const trace = this.tracer.startSpan(
            `incoming_${request.method}_${request.url}`,
            traceContext
        );

        // Add trace headers to response
        request.reply.headers(trace.injectHeaders);

        return next()
            .then(result => {
                this.tracer.endSpan(trace.span.spanId, 'ok');
                return result;
            })
            .catch(error => {
                this.tracer.endSpan(trace.span.spanId, 'error');
                throw error;
            });
    }

    private generateId(): string {
        return `${Date.now()}_${Math.random().toString(36).slice(2, 9)}`;
    }
}
```

### 6. Key Takeaways

1. **Microservices Benefits:**
   - Independent deployment
   - Technology diversity
   - Team autonomy
   - Scalability
   - Resilience

2. **Microservices Challenges:**
   - Distributed complexity
   - Network latency
   - Data consistency
   - Testing difficulty
   - Operational overhead

3. **Service Mesh Value:**
   - Standardizes communication
   - Adds reliability features
   - Provides observability
   - Reduces application complexity

4. **Key Service Mesh Features:**
   - Circuit breaking
   - Retry policies
   - Timeouts
   - Load balancing
   - Service discovery
   - Distributed tracing

5. **API Gateway Role:**
   - Single entry point
   - Authentication/Authorization
   - Rate limiting
   - Request routing

6. **Best Practices:**
   - Design for failure
   - Implement observability
   - Use circuit breakers
   - Include retry logic
   - Monitor everything

---

This primer provides a comprehensive understanding of microservices and service mesh. These patterns enable building large-scale, resilient distributed systems with independent services.
