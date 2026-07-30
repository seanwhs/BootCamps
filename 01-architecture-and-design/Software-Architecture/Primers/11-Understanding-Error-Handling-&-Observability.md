# Primer 11: Understanding Error Handling & Observability

## A Deep Dive into Building Resilient & Observable Systems

Welcome to the eleventh primer! This is a comprehensive deep dive into error handling and observability - the practices that make your system resilient, debuggable, and trustworthy. Think of this like having a highly skilled maintenance team in your restaurant chain: they need to know immediately when something goes wrong, understand exactly what happened, and fix it before customers even notice.

### 1. The Big Picture

#### Error Handling & Observability Stack

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ERROR HANDLING & OBSERVABILITY STACK                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    ERROR HANDLING                                   │   │
│  │  • Structured Errors  • Error Hierarchy  • Error Recovery          │   │
│  │  • Retry Logic        • Circuit Breakers  • Fallbacks              │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    LOGGING                                          │   │
│  │  • Structured Logs  • Log Levels    • Contextual Logging           │   │
│  │  • Log Aggregation  • Log Retention • Log Analysis                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    METRICS                                          │   │
│  │  • Performance      • Business      • Infrastructure               │   │
│  │  • Alerts           • Dashboards    • SLO/SLI                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│                                    ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    DISTRIBUTED TRACING                              │   │
│  │  • Request Tracing  • Span Context  • Service Maps                 │   │
│  │  • Performance Analysis • Root Cause Analysis                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Structured Error Handling

#### Error Hierarchy

```typescript
// Base application error
export class AppError extends Error {
    public readonly statusCode: number;
    public readonly code: string;
    public readonly details?: unknown;
    public readonly isOperational: boolean;

    constructor(
        message: string,
        statusCode: number = 500,
        code: string = 'INTERNAL_ERROR',
        details?: unknown,
        isOperational: boolean = true
    ) {
        super(message);
        this.name = this.constructor.name;
        this.statusCode = statusCode;
        this.code = code;
        this.details = details;
        this.isOperational = isOperational;
        
        Error.captureStackTrace(this, this.constructor);
    }

    toJSON(): Record<string, any> {
        return {
            name: this.name,
            message: this.message,
            code: this.code,
            statusCode: this.statusCode,
            details: this.details,
            stack: process.env.NODE_ENV === 'development' ? this.stack : undefined,
        };
    }
}

// Specific error types
export class ValidationError extends AppError {
    constructor(message: string, details?: unknown) {
        super(message, 400, 'VALIDATION_ERROR', details);
    }
}

export class NotFoundError extends AppError {
    constructor(message: string = 'Resource not found') {
        super(message, 404, 'NOT_FOUND');
    }
}

export class UnauthorizedError extends AppError {
    constructor(message: string = 'Unauthorized') {
        super(message, 401, 'UNAUTHORIZED');
    }
}

export class ForbiddenError extends AppError {
    constructor(message: string = 'Forbidden') {
        super(message, 403, 'FORBIDDEN');
    }
}

export class ConflictError extends AppError {
    constructor(message: string, details?: unknown) {
        super(message, 409, 'CONFLICT', details);
    }
}

export class ServiceError extends AppError {
    constructor(message: string, statusCode: number = 503, details?: unknown) {
        super(message, statusCode, 'SERVICE_UNAVAILABLE', details);
    }
}

export class DatabaseError extends AppError {
    constructor(message: string, details?: unknown) {
        super(message, 500, 'DATABASE_ERROR', details);
    }
}

export class RateLimitError extends AppError {
    constructor(message: string = 'Rate limit exceeded', details?: unknown) {
        super(message, 429, 'RATE_LIMIT_EXCEEDED', details);
    }
}
```

#### Error Handler Service

```typescript
class ErrorHandlerService {
    private logger: Logger;

    constructor() {
        this.logger = createLogger('error-handler');
    }

    handleError(error: unknown, context?: Record<string, any>): ErrorResponse {
        // Normalize error
        const appError = this.normalizeError(error);
        
        // Log error with context
        this.logError(appError, context);
        
        // Determine if we should send alert
        if (this.shouldAlert(appError)) {
            this.sendAlert(appError, context);
        }

        // Return safe response
        return {
            success: false,
            error: {
                code: appError.code,
                message: this.getSafeMessage(appError),
                details: this.getSafeDetails(appError),
            },
            requestId: context?.requestId,
        };
    }

    private normalizeError(error: unknown): AppError {
        if (error instanceof AppError) {
            return error;
        }

        if (error instanceof Error) {
            // Map common errors
            if (error.message.includes('timeout')) {
                return new AppError('Request timeout', 408, 'TIMEOUT');
            }
            if (error.message.includes('ECONNREFUSED')) {
                return new ServiceError('Service unavailable');
            }
            if (error.message.includes('validation')) {
                return new ValidationError(error.message);
            }
            
            return new AppError(
                error.message,
                500,
                'UNKNOWN_ERROR',
                { originalError: error.message }
            );
        }

        return new AppError('An unexpected error occurred', 500, 'UNKNOWN_ERROR');
    }

    private logError(error: AppError, context?: Record<string, any>): void {
        const logEntry = {
            timestamp: new Date().toISOString(),
            error: error.toJSON(),
            context,
            environment: process.env.NODE_ENV,
            service: process.env.SERVICE_NAME,
            host: require('os').hostname(),
        };

        if (error.statusCode >= 500) {
            this.logger.error(logEntry);
        } else if (error.statusCode >= 400) {
            this.logger.warn(logEntry);
        } else {
            this.logger.info(logEntry);
        }
    }

    private shouldAlert(error: AppError): boolean {
        // Alert on server errors or critical issues
        return error.statusCode >= 500 && error.isOperational;
    }

    private sendAlert(error: AppError, context?: Record<string, any>): void {
        // Send alert to monitoring system (Slack, PagerDuty, etc.)
        // This would be implemented with your alerting system
        console.error('ALERT:', error.toJSON(), context);
    }

    private getSafeMessage(error: AppError): string {
        // Don't expose internal details in production
        if (process.env.NODE_ENV === 'production' && error.statusCode === 500) {
            return 'An internal error occurred';
        }
        return error.message;
    }

    private getSafeDetails(error: AppError): unknown {
        // Don't expose internal details in production
        if (process.env.NODE_ENV === 'production') {
            return undefined;
        }
        return error.details;
    }
}

interface ErrorResponse {
    success: false;
    error: {
        code: string;
        message: string;
        details?: unknown;
    };
    requestId?: string;
}
```

### 3. Structured Logging

#### Logger Implementation

```typescript
import pino from 'pino';

class Logger {
    private logger: pino.Logger;
    private context: Record<string, any>;

    constructor(context: Record<string, any> = {}) {
        this.context = context;
        
        this.logger = pino({
            level: process.env.LOG_LEVEL || 'info',
            base: {
                service: process.env.SERVICE_NAME || 'orchestrator',
                version: process.env.SERVICE_VERSION || '1.0.0',
                environment: process.env.NODE_ENV || 'development',
                pid: process.pid,
                hostname: require('os').hostname(),
            },
            timestamp: pino.stdTimeFunctions.isoTime,
            formatters: {
                level: (label) => ({ level: label }),
            },
            serializers: {
                err: pino.stdSerializers.err,
                req: (req) => ({
                    id: req.id,
                    method: req.method,
                    url: req.url,
                    headers: {
                        'user-agent': req.headers?.['user-agent'],
                        'x-request-id': req.headers?.['x-request-id'],
                    },
                }),
                res: (res) => ({
                    statusCode: res.statusCode,
                    duration: res.duration,
                }),
                error: (error) => ({
                    message: error.message,
                    stack: error.stack,
                    code: error.code,
                    statusCode: error.statusCode,
                }),
            },
        });
    }

    child(bindings: Record<string, any>): Logger {
        return new Logger({
            ...this.context,
            ...bindings,
        });
    }

    trace(message: string, data?: Record<string, any>): void {
        this.logger.trace(this.buildLogData(message, data));
    }

    debug(message: string, data?: Record<string, any>): void {
        this.logger.debug(this.buildLogData(message, data));
    }

    info(message: string, data?: Record<string, any>): void {
        this.logger.info(this.buildLogData(message, data));
    }

    warn(message: string, data?: Record<string, any>): void {
        this.logger.warn(this.buildLogData(message, data));
    }

    error(message: string, error?: Error | AppError, data?: Record<string, any>): void {
        const logData = this.buildLogData(message, data);
        
        if (error) {
            logData.error = {
                message: error.message,
                stack: error.stack,
                name: error.name,
                code: (error as AppError).code,
                statusCode: (error as AppError).statusCode,
                details: (error as AppError).details,
            };
        }
        
        this.logger.error(logData);
    }

    fatal(message: string, error?: Error, data?: Record<string, any>): void {
        const logData = this.buildLogData(message, data);
        
        if (error) {
            logData.error = {
                message: error.message,
                stack: error.stack,
                name: error.name,
            };
        }
        
        this.logger.fatal(logData);
    }

    private buildLogData(message: string, data?: Record<string, any>): Record<string, any> {
        return {
            message,
            ...this.context,
            ...data,
            timestamp: new Date().toISOString(),
        };
    }

    // Specialized logging methods
    logRequest(req: any, res: any, duration: number): void {
        this.info('Request completed', {
            method: req.method,
            url: req.url,
            statusCode: res.statusCode,
            duration,
            requestId: req.id,
            userId: req.userId,
            ip: req.ip,
        });
    }

    logUserAction(userId: string, action: string, details?: Record<string, any>): void {
        this.info('User action', {
            userId,
            action,
            ...details,
        });
    }

    logBusinessEvent(event: string, data: Record<string, any>): void {
        this.info(`Business event: ${event}`, {
            event,
            ...data,
        });
    }

    logSecurityEvent(event: string, data: Record<string, any>): void {
        this.warn(`Security event: ${event}`, {
            event,
            ...data,
        });
    }

    // Performance logging
    logPerformance(operation: string, duration: number, data?: Record<string, any>): void {
        this.info('Performance metric', {
            operation,
            duration,
            ...data,
        });
    }
}

function createLogger(context?: Record<string, any>): Logger {
    return new Logger(context);
}
```

### 4. Metrics & Monitoring

#### Metrics Service

```typescript
class MetricsService {
    private metrics: Map<string, Metric> = new Map();
    private healthChecks: Map<string, HealthCheck> = new Map();
    private logger: Logger;

    constructor() {
        this.logger = createLogger({ service: 'metrics' });
    }

    // Counter
    incrementCounter(name: string, tags?: Record<string, string>, value: number = 1): void {
        const metric = this.getOrCreateMetric(name, 'counter', tags);
        metric.value += value;
        metric.lastUpdated = Date.now();
    }

    // Gauge
    setGauge(name: string, value: number, tags?: Record<string, string>): void {
        const metric = this.getOrCreateMetric(name, 'gauge', tags);
        metric.value = value;
        metric.lastUpdated = Date.now();
    }

    // Histogram
    recordHistogram(name: string, value: number, tags?: Record<string, string>): void {
        const metric = this.getOrCreateMetric(name, 'histogram', tags);
        if (!Array.isArray(metric.values)) {
            metric.values = [];
        }
        metric.values.push(value);
        
        // Keep only last 1000 values
        if (metric.values.length > 1000) {
            metric.values.shift();
        }
        metric.lastUpdated = Date.now();
    }

    // Timer
    time<T>(name: string, fn: () => Promise<T>, tags?: Record<string, string>): Promise<T> {
        const start = Date.now();
        return fn().finally(() => {
            const duration = Date.now() - start;
            this.recordHistogram(name, duration, tags);
        });
    }

    // Health checks
    registerHealthCheck(name: string, check: () => Promise<HealthCheckResult>): void {
        this.healthChecks.set(name, { check, lastCheck: 0, status: 'unknown' });
    }

    async runHealthChecks(): Promise<HealthStatus> {
        const results: Record<string, HealthCheckResult> = {};
        let overallStatus: 'healthy' | 'degraded' | 'unhealthy' = 'healthy';

        for (const [name, healthCheck] of this.healthChecks) {
            try {
                const result = await healthCheck.check();
                results[name] = result;
                healthCheck.status = result.status;
                healthCheck.lastCheck = Date.now();

                if (result.status === 'unhealthy') {
                    overallStatus = 'unhealthy';
                } else if (result.status === 'degraded' && overallStatus === 'healthy') {
                    overallStatus = 'degraded';
                }
            } catch (error) {
                results[name] = {
                    status: 'unhealthy',
                    details: error instanceof Error ? error.message : String(error),
                };
                overallStatus = 'unhealthy';
            }
        }

        return {
            status: overallStatus,
            checks: results,
            timestamp: new Date().toISOString(),
        };
    }

    private getOrCreateMetric(name: string, type: MetricType, tags?: Record<string, string>): Metric {
        const key = this.getMetricKey(name, tags);
        let metric = this.metrics.get(key);
        
        if (!metric) {
            metric = {
                name,
                type,
                tags: tags || {},
                value: 0,
                values: [],
                lastUpdated: Date.now(),
            };
            this.metrics.set(key, metric);
        }
        
        return metric;
    }

    private getMetricKey(name: string, tags?: Record<string, string>): string {
        if (!tags) return name;
        const sortedTags = Object.keys(tags).sort().reduce((acc, key) => {
            acc[key] = tags[key];
            return acc;
        }, {} as Record<string, string>);
        return `${name}?${JSON.stringify(sortedTags)}`;
    }

    getMetrics(): MetricsSnapshot {
        const snapshot: MetricsSnapshot = {
            timestamp: new Date().toISOString(),
            counters: {},
            gauges: {},
            histograms: {},
        };

        for (const [key, metric] of this.metrics) {
            const name = metric.name;
            const tags = metric.tags;
            const keyWithTags = Object.keys(tags).length > 0 
                ? `${name}{${Object.entries(tags).map(([k, v]) => `${k}=${v}`).join(',')}}`
                : name;

            switch (metric.type) {
                case 'counter':
                case 'gauge':
                    snapshot[metric.type === 'counter' ? 'counters' : 'gauges'][keyWithTags] = metric.value;
                    break;
                case 'histogram':
                    if (Array.isArray(metric.values) && metric.values.length > 0) {
                        const sorted = [...metric.values].sort((a, b) => a - b);
                        snapshot.histograms[keyWithTags] = {
                            count: metric.values.length,
                            min: sorted[0],
                            max: sorted[sorted.length - 1],
                            avg: metric.values.reduce((a, b) => a + b, 0) / metric.values.length,
                            p50: sorted[Math.floor(sorted.length * 0.5)],
                            p90: sorted[Math.floor(sorted.length * 0.9)],
                            p95: sorted[Math.floor(sorted.length * 0.95)],
                            p99: sorted[Math.floor(sorted.length * 0.99)],
                        };
                    }
                    break;
            }
        }

        return snapshot;
    }
}

type MetricType = 'counter' | 'gauge' | 'histogram';

interface Metric {
    name: string;
    type: MetricType;
    tags: Record<string, string>;
    value: any;
    values?: number[];
    lastUpdated: number;
}

interface HealthCheck {
    check: () => Promise<HealthCheckResult>;
    lastCheck: number;
    status: string;
}

interface HealthCheckResult {
    status: 'healthy' | 'degraded' | 'unhealthy';
    details?: any;
}

interface HealthStatus {
    status: 'healthy' | 'degraded' | 'unhealthy';
    checks: Record<string, HealthCheckResult>;
    timestamp: string;
}

interface MetricsSnapshot {
    timestamp: string;
    counters: Record<string, number>;
    gauges: Record<string, number>;
    histograms: Record<string, {
        count: number;
        min: number;
        max: number;
        avg: number;
        p50: number;
        p90: number;
        p95: number;
        p99: number;
    }>;
}
```

### 5. Distributed Tracing

#### Tracer Implementation

```typescript
import { AsyncLocalStorage } from 'async_hooks';

class Tracer {
    private static instance: Tracer;
    private spans: Map<string, Span> = new Map();
    private context: AsyncLocalStorage<SpanContext> = new AsyncLocalStorage();
    private logger: Logger;

    private constructor() {
        this.logger = createLogger({ service: 'tracer' });
    }

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
        const context = this.context.getStore();
        const traceId = options?.traceId || context?.traceId || this.generateId();
        const parentSpanId = options?.parentSpanId || context?.spanId;
        const spanId = this.generateId();

        const span: Span = {
            traceId,
            spanId,
            parentSpanId,
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
        
        // Set as current context
        this.context.enterWith({
            traceId,
            spanId,
        });

        this.logger.debug('Span started', { traceId, spanId, name });

        return span;
    }

    endSpan(
        spanId: string,
        options?: {
            status?: 'ok' | 'error' | 'unknown';
            error?: Error;
            attributes?: Record<string, any>;
        }
    ): void {
        const span = this.spans.get(spanId);
        if (!span) {
            this.logger.warn('Span not found', { spanId });
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
                name: options.error.name,
            };
        }

        if (options?.attributes) {
            span.attributes = { ...span.attributes, ...options.attributes };
        }

        this.logger.debug('Span ended', {
            spanId,
            duration: span.duration,
            status: span.status,
        });

        // Clean up context
        this.context.exit(() => {});
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

    getTrace(traceId: string): Span[] {
        const result: Span[] = [];
        for (const span of this.spans.values()) {
            if (span.traceId === traceId) {
                result.push(span);
            }
        }
        return result.sort((a, b) => a.startTime - b.startTime);
    }

    getCurrentSpan(): Span | null {
        const context = this.context.getStore();
        if (!context) return null;
        return this.spans.get(context.spanId) || null;
    }

    getCurrentTraceId(): string | null {
        const context = this.context.getStore();
        return context?.traceId || null;
    }

    private generateId(): string {
        return `${Date.now()}_${Math.random().toString(36).slice(2, 9)}`;
    }

    // Propagation helpers
    getTraceHeaders(): Record<string, string> {
        const context = this.context.getStore();
        if (!context) return {};
        
        return {
            'x-trace-id': context.traceId,
            'x-span-id': context.spanId,
        };
    }

    extractContext(headers: Record<string, string>): SpanContext | null {
        if (!headers['x-trace-id']) {
            return null;
        }
        
        return {
            traceId: headers['x-trace-id'],
            spanId: headers['x-span-id'] || this.generateId(),
        };
    }

    // Clean up old traces
    cleanup(maxAge: number = 3600000): void {
        const now = Date.now();
        for (const [spanId, span] of this.spans) {
            if (span.endTime && now - span.endTime > maxAge) {
                this.spans.delete(spanId);
            }
        }
    }
}

interface SpanContext {
    traceId: string;
    spanId: string;
}

interface Span {
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

// Tracing middleware
function traceMiddleware() {
    const tracer = Tracer.getInstance();

    return async (request: FastifyRequest, reply: FastifyReply) => {
        // Extract context from headers
        const headers = request.headers as Record<string, string>;
        const parentContext = tracer.extractContext(headers);

        // Start span for request
        const span = tracer.startSpan('http_request', {
            traceId: parentContext?.traceId,
            parentSpanId: parentContext?.spanId,
            attributes: {
                method: request.method,
                path: request.url,
                requestId: request.id,
                userId: (request as any).userId,
            },
        });

        // Add response handler
        reply.hook('onSend', async () => {
            tracer.addEvent(span.spanId, 'response_sent', {
                statusCode: reply.statusCode,
            });
            tracer.endSpan(span.spanId, {
                status: reply.statusCode >= 400 ? 'error' : 'ok',
                attributes: {
                    statusCode: reply.statusCode,
                },
            });
        });

        // Store span in request
        (request as any).spanId = span.spanId;
    };
}
```

### 6. Key Takeaways

1. **Structured Error Handling:**
   - Create meaningful error hierarchy
   - Include context in errors
   - Handle errors gracefully
   - Never expose internal details

2. **Comprehensive Logging:**
   - Use structured logs (JSON)
   - Include appropriate context
   - Different log levels for different needs
   - Secure sensitive information

3. **Metrics are Essential:**
   - Track performance metrics
   - Monitor business metrics
   - Set up alerts
   - Define SLOs and SLIs

4. **Distributed Tracing:**
   - Trace requests across services
   - Include context propagation
   - Identify bottlenecks
   - Correlate with logs

5. **Observability Best Practices:**
   - Correlate logs, metrics, and traces
   - Include correlation IDs
   - Monitor key indicators
   - Regular health checks

6. **Alerting Strategy:**
   - Define meaningful thresholds
   - Avoid alert fatigue
   - Include context in alerts
   - Have runbooks for common alerts

---

This primer provides a comprehensive understanding of error handling and observability. A well-observable system provides the insights needed to maintain reliability, diagnose issues quickly, and continuously improve.
