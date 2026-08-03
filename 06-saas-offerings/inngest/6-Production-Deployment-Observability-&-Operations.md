# Mastering Inngest: Building Reliable Serverless Workflows with Durable Execution

## Design Resilient Event-Driven Systems Without Managing Queues, Workers, or Workflow Infrastructure

---

# Part 6: Production Deployment, Observability & Operations

## Taking Your Workflows from Development to Enterprise-Grade Production

---

## Module 6.1: Production Architecture and Configuration

### The Target

In this final module, you'll learn how to configure, secure, and deploy your Inngest workflows to production environments with enterprise-grade reliability.

### The Concept

Production deployment is like **launching a spacecraft**:

1. **Pre-flight Checks** (Testing): Everything must work perfectly
2. **Mission Control** (Monitoring): Constant oversight during operation
3. **Backup Systems** (Resilience): Redundancy for critical components
4. **Emergency Procedures** (Incident Response): Plans for when things go wrong
5. **Post-Mission Analysis** (Observability): Learn from every flight

Let's prepare your workflows for the harsh environment of production.

### The Implementation: Production Configuration

#### Step 1: Environment Configuration

Create a robust environment configuration system:

```typescript
// src/lib/config/index.ts
import { z } from 'zod';

// Define environment variable schema
const envSchema = z.object({
  // Node environment
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  
  // Inngest configuration
  INNGEST_EVENT_KEY: z.string().min(1, 'INNGEST_EVENT_KEY is required'),
  INNGEST_SIGNING_KEY: z.string().min(1, 'INNGEST_SIGNING_KEY is required'),
  INNGEST_DEV: z.enum(['true', 'false']).default('false'),
  
  // Application configuration
  NEXT_PUBLIC_APP_URL: z.string().url('NEXT_PUBLIC_APP_URL must be a valid URL'),
  DATABASE_URL: z.string().min(1, 'DATABASE_URL is required'),
  
  // External services
  RESEND_API_KEY: z.string().optional(),
  STRIPE_SECRET_KEY: z.string().optional(),
  OPENAI_API_KEY: z.string().optional(),
  
  // Security
  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be at least 32 characters'),
  ENCRYPTION_KEY: z.string().min(32, 'ENCRYPTION_KEY must be at least 32 characters'),
  
  // Rate limiting
  RATE_LIMIT_WINDOW: z.string().default('60s'),
  RATE_LIMIT_MAX_REQUESTS: z.string().default('100'),
  
  // Monitoring
  SENTRY_DSN: z.string().url().optional(),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
});

// Validate environment variables
function validateEnv() {
  try {
    return envSchema.parse(process.env);
  } catch (error) {
    if (error instanceof z.ZodError) {
      const issues = error.issues.map(issue => 
        `${issue.path.join('.')}: ${issue.message}`
      ).join('\n');
      throw new Error(`Environment validation failed:\n${issues}`);
    }
    throw error;
  }
}

// Export validated config
export const config = validateEnv();

// Helper to check if we're in production
export const isProduction = config.NODE_ENV === 'production';
export const isDevelopment = config.NODE_ENV === 'development';
export const isTest = config.NODE_ENV === 'test';

// Helper for logging based on environment
export function log(level: string, message: string, data?: any) {
  if (isDevelopment && level === 'debug') {
    console.debug(`[${level}] ${message}`, data);
  } else if (isProduction && level !== 'debug') {
    // In production, use a proper logging service
    console.log(`[${level}] ${message}`, data);
  }
}
```

#### Step 2: Enhanced Inngest Client for Production

```typescript
// src/inngest/client.ts
import { Inngest, InngestMiddleware } from 'inngest';
import { config, isProduction, isDevelopment, log } from '@/lib/config';
import { Sentry } from '@sentry/nextjs';

// Production middleware for error tracking
export const sentryMiddleware = new InngestMiddleware({
  name: 'Sentry Error Tracking',
  init: () => ({
    onFunctionRun: ({ fn, ctx }) => ({
      onStepRun: ({ step, run }) => ({
        transformOutput: ({ output }) => {
          // If the step failed, capture the error in Sentry
          if (output instanceof Error) {
            Sentry.captureException(output, {
              tags: {
                function: fn.id,
                step: step.name,
                runId: ctx.runId,
              },
              extra: {
                event: ctx.event,
              },
            });
          }
          return { output };
        },
      }),
      onFunctionComplete: ({ result }) => {
        if (!result.success) {
          Sentry.captureException(result.error, {
            tags: {
              function: fn.id,
              runId: ctx.runId,
            },
            extra: {
              event: ctx.event,
              result,
            },
          });
        }
      },
    }),
  }),
});

// Production middleware for metrics
export const metricsMiddleware = new InngestMiddleware({
  name: 'Metrics Collection',
  init: () => ({
    onFunctionRun: ({ fn, ctx }) => {
      const startTime = Date.now();
      
      return {
        onFunctionComplete: ({ result }) => {
          const duration = Date.now() - startTime;
          
          // Log metrics
          log('info', 'Function execution metrics', {
            functionId: fn.id,
            runId: ctx.runId,
            duration,
            success: result.success,
            attempts: ctx.attempt,
          });
          
          // In production, you'd send metrics to a service like Prometheus
          if (isProduction) {
            // Example: send to your metrics system
            // metricsService.record({
            //   name: 'inngest.function.execution',
            //   duration,
            //   tags: {
            //     function: fn.id,
            //     success: result.success,
            //   },
            // });
          }
        },
      };
    },
  }),
});

// Create the production-ready Inngest client
export const inngest = new Inngest({
  id: 'workflowhub',
  name: 'WorkflowHub',
  
  // In production, always use environment variables
  eventKey: config.INNGEST_EVENT_KEY,
  signingKey: config.INNGEST_SIGNING_KEY,
  
  // Add middleware in production
  middleware: isProduction 
    ? [sentryMiddleware, metricsMiddleware]
    : [metricsMiddleware],
  
  // Production retry configuration
  retryFunction: (attempt: number) => {
    // Exponential backoff with jitter for production
    const baseDelay = Math.min(Math.pow(2, attempt) * 1000, 60000);
    const jitter = Math.random() * 1000;
    const maxAttempts = isProduction ? 5 : 3;
    
    return {
      delay: baseDelay + jitter,
      maxAttempts,
    };
  },
  
  // Logger configuration
  logger: isProduction 
    ? {
        debug: () => {}, // Disable debug logs in production
        info: (message: string) => log('info', message),
        warn: (message: string) => log('warn', message),
        error: (message: string) => log('error', message),
      }
    : {
        debug: (message: string) => log('debug', message),
        info: (message: string) => log('info', message),
        warn: (message: string) => log('warn', message),
        error: (message: string) => log('error', message),
      },
});

// Export a helper to check client health
export async function checkInngestHealth() {
  try {
    // In a real app, you'd make a health check request
    // For now, we'll simulate
    return { healthy: true, timestamp: new Date().toISOString() };
  } catch (error) {
    return { healthy: false, error: error.message };
  }
}
```

#### Step 3: Production Error Handler

```typescript
// src/inngest/error-handler.ts
import { log } from '@/lib/config';

// Custom error handler for production
export class WorkflowErrorHandler {
  private static instance: WorkflowErrorHandler;
  private errorCounts: Record<string, number> = {};
  private errorWindow: number = 60000; // 1 minute
  
  static getInstance() {
    if (!WorkflowErrorHandler.instance) {
      WorkflowErrorHandler.instance = new WorkflowErrorHandler();
    }
    return WorkflowErrorHandler.instance;
  }
  
  // Handle error with retry logic
  async handleError(error: Error, context: {
    functionId: string;
    runId: string;
    step?: string;
    attempt: number;
    maxAttempts: number;
  }): Promise<{ shouldRetry: boolean; delay?: number }> {
    const { functionId, step, attempt, maxAttempts } = context;
    
    // Log the error
    log('error', 'Workflow error occurred', {
      functionId,
      step,
      attempt,
      error: error.message,
      stack: error.stack,
    });
    
    // Check if error is retryable
    const isRetryable = this.isRetryableError(error);
    
    if (!isRetryable) {
      log('warn', 'Non-retryable error, failing workflow', { functionId, error: error.message });
      return { shouldRetry: false };
    }
    
    // Check if we've exceeded retries
    if (attempt >= maxAttempts) {
      log('error', 'Max retries exceeded', { functionId, maxAttempts });
      return { shouldRetry: false };
    }
    
    // Check for rate limiting
    const isRateLimited = this.isRateLimited(functionId);
    if (isRateLimited) {
      const delay = this.getBackoffDelay(attempt);
      log('info', 'Rate limited, retrying with delay', { functionId, delay });
      return { shouldRetry: true, delay };
    }
    
    // Calculate backoff delay
    const delay = this.getBackoffDelay(attempt);
    log('info', 'Retrying after error', { functionId, attempt, delay });
    
    return { shouldRetry: true, delay };
  }
  
  // Determine if error is retryable
  private isRetryableError(error: Error): boolean {
    // Network errors are retryable
    if (error.message.includes('ECONNRESET') ||
        error.message.includes('ETIMEDOUT') ||
        error.message.includes('socket hang up')) {
      return true;
    }
    
    // API rate limit errors are retryable
    if (error.message.includes('rate limit') ||
        error.message.includes('too many requests')) {
      return true;
    }
    
    // Service unavailable errors are retryable
    if (error.message.includes('503') ||
        error.message.includes('service unavailable')) {
      return true;
    }
    
    // Timeout errors are retryable
    if (error.message.includes('timeout') ||
        error.message.includes('timed out')) {
      return true;
    }
    
    // Database connection errors are retryable
    if (error.message.includes('connection') &&
        (error.message.includes('database') || error.message.includes('DB'))) {
      return true;
    }
    
    // Validation errors are NOT retryable
    if (error.message.includes('validation') ||
        error.message.includes('invalid')) {
      return false;
    }
    
    // Authentication errors are NOT retryable
    if (error.message.includes('unauthorized') ||
        error.message.includes('forbidden') ||
        error.message.includes('authentication')) {
      return false;
    }
    
    // Default: retry once
    return true;
  }
  
  // Check if function is rate limited
  private isRateLimited(functionId: string): boolean {
    const now = Date.now();
    const key = `${functionId}-errors`;
    
    // Clean old entries
    this.errorCounts = Object.fromEntries(
      Object.entries(this.errorCounts).filter(([_, count]) => count > 0)
    );
    
    // Count errors in window
    const count = this.errorCounts[key] || 0;
    
    // If more than 10 errors in the window, rate limit
    if (count > 10) {
      return true;
    }
    
    // Increment counter
    this.errorCounts[key] = count + 1;
    
    // Schedule cleanup
    setTimeout(() => {
      this.errorCounts[key] = (this.errorCounts[key] || 1) - 1;
    }, this.errorWindow);
    
    return false;
  }
  
  // Calculate backoff delay with jitter
  private getBackoffDelay(attempt: number): number {
    const baseDelay = Math.min(Math.pow(2, attempt) * 1000, 30000);
    const jitter = Math.random() * 1000;
    return baseDelay + jitter;
  }
}

export const errorHandler = WorkflowErrorHandler.getInstance();
```

---

## Module 6.2: Production Deployment Strategies

### The Target

Learn how to deploy your Inngest workflows to various production environments including Vercel, AWS Lambda, and Docker.

### The Concept

Deployment strategies are like **choosing the right launch vehicle**:

1. **Vercel**: Like a commercial airline - easy, fast, and scalable
2. **AWS Lambda**: Like a private jet - powerful but more complex
3. **Docker**: Like building your own rocket - full control

Each has its strengths and use cases. We'll cover all three.

### The Implementation: Deployment Configurations

#### Vercel Deployment

```typescript
// vercel.json - Vercel deployment configuration
{
  "version": 2,
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/next"
    }
  ],
  "routes": [
    {
      "src": "/api/inngest",
      "dest": "/api/inngest"
    }
  ],
  "env": {
    "NODE_ENV": "production",
    "INNGEST_EVENT_KEY": "@inngest-event-key",
    "INNGEST_SIGNING_KEY": "@inngest-signing-key",
    "NEXT_PUBLIC_APP_URL": "@app-url",
    "DATABASE_URL": "@database-url",
    "JWT_SECRET": "@jwt-secret",
    "ENCRYPTION_KEY": "@encryption-key"
  },
  "functions": {
    "api/inngest/**/*.ts": {
      "maxDuration": 60,
      "memory": 1024
    }
  }
}
```

```typescript
// Next.js configuration for production
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Enable server actions
  experimental: {
    serverActions: {
      allowedOrigins: ['workflowhub.com', '*.vercel.app'],
      bodySizeLimit: '5mb',
    },
  },
  
  // Optimize images
  images: {
    domains: ['storage.workflowhub.com'],
    formats: ['image/webp'],
  },
  
  // Security headers
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
          {
            key: 'Permissions-Policy',
            value: 'camera=(), microphone=(), geolocation=()',
          },
        ],
      },
    ];
  },
  
  // Increase timeout for long-running operations
  serverRuntimeConfig: {
    maxRequestBodySize: '10mb',
  },
  
  // Webpack optimization
  webpack: (config, { isServer }) => {
    if (isServer) {
      // Optimize server bundle
      config.optimization = {
        ...config.optimization,
        minimize: true,
        moduleIds: 'deterministic',
      };
    }
    return config;
  },
};

module.exports = nextConfig;
```

```bash
# .env.production - Production environment variables
NODE_ENV=production
INNGEST_EVENT_KEY=ev_prod_xxxxxxxxxxxxxxxx
INNGEST_SIGNING_KEY=sign_prod_xxxxxxxxxxxxxxxx
NEXT_PUBLIC_APP_URL=https://workflowhub.com
DATABASE_URL=postgresql://user:password@host:5432/database
RESEND_API_KEY=re_prod_xxxxxxxxxxxxxxxx
STRIPE_SECRET_KEY=sk_live_xxxxxxxxxxxxxxxx
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxx
JWT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ENCRYPTION_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
RATE_LIMIT_WINDOW=60s
RATE_LIMIT_MAX_REQUESTS=100
SENTRY_DSN=https://xxxxxxxxxxxxxxxx@xxxxxxxxxxxxxxxx.ingest.sentry.io/xxxxxxxx
LOG_LEVEL=info
```

#### AWS Lambda Deployment

```typescript
// serverless.yml - AWS Lambda deployment configuration
service: workflowhub

provider:
  name: aws
  runtime: nodejs20.x
  region: us-east-1
  stage: ${opt:stage, 'prod'}
  memorySize: 1024
  timeout: 60
  environment:
    NODE_ENV: ${env:NODE_ENV, 'production'}
    INNGEST_EVENT_KEY: ${env:INNGEST_EVENT_KEY}
    INNGEST_SIGNING_KEY: ${env:INNGEST_SIGNING_KEY}
    NEXT_PUBLIC_APP_URL: ${env:NEXT_PUBLIC_APP_URL}
    DATABASE_URL: ${env:DATABASE_URL}
    JWT_SECRET: ${env:JWT_SECRET}
    ENCRYPTION_KEY: ${env:ENCRYPTION_KEY}
  
  iamRoleStatements:
    - Effect: Allow
      Action:
        - lambda:InvokeFunction
        - dynamodb:Query
        - dynamodb:Scan
        - dynamodb:GetItem
        - dynamodb:PutItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
      Resource: "*"

functions:
  api:
    handler: lambda.handler
    events:
      - http:
          path: /{proxy+}
          method: ANY
          cors: true
      - http:
          path: /api/inngest
          method: POST
          cors: true
      - http:
          path: /api/inngest
          method: GET
          cors: true

plugins:
  - serverless-offline
  - serverless-dotenv-plugin

custom:
  dotenv:
    path: .env.${opt:stage, 'prod'}
  serverless-offline:
    httpPort: 3000
```

```typescript
// lambda.js - AWS Lambda handler
import { Inngest } from 'inngest';
import { serve } from 'inngest/next';

// Import your functions
import { userRegistrationWorkflow } from './src/inngest/functions/user-registration';
import { orderCreatedWorkflow } from './src/inngest/functions/order-created';

const inngest = new Inngest({
  id: 'workflowhub',
  name: 'WorkflowHub',
  eventKey: process.env.INNGEST_EVENT_KEY,
});

// Create the handler
const handler = serve({
  client: inngest,
  functions: [
    userRegistrationWorkflow,
    orderCreatedWorkflow,
  ],
});

// Lambda handler wrapper
export const handler = async (event: any, context: any) => {
  // Add Lambda context to the request
  context.callbackWaitsForEmptyEventLoop = false;
  
  // Handle the request
  return await handler(event, context);
};
```

#### Docker Deployment

```dockerfile
# Dockerfile - Production Docker build
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application code
COPY . .

# Build the application
RUN npm run build

# Production image
FROM node:20-alpine AS runner

WORKDIR /app

# Install production dependencies
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Start the application
CMD ["npm", "start"]
```

```yaml
# docker-compose.prod.yml - Production Docker Compose
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: runner
    image: workflowhub:latest
    container_name: workflowhub-app
    restart: always
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - INNGEST_EVENT_KEY=${INNGEST_EVENT_KEY}
      - INNGEST_SIGNING_KEY=${INNGEST_SIGNING_KEY}
      - NEXT_PUBLIC_APP_URL=${NEXT_PUBLIC_APP_URL}
      - DATABASE_URL=${DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
      - ENCRYPTION_KEY=${ENCRYPTION_KEY}
      - REDIS_URL=${REDIS_URL}
    networks:
      - workflowhub-network
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:15-alpine
    container_name: workflowhub-db
    restart: always
    environment:
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=${DB_NAME}
    volumes:
      - postgres-data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    networks:
      - workflowhub-network

  redis:
    image: redis:7-alpine
    container_name: workflowhub-cache
    restart: always
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - workflowhub-network

  nginx:
    image: nginx:alpine
    container_name: workflowhub-nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./certs:/etc/nginx/certs
    networks:
      - workflowhub-network
    depends_on:
      - app

volumes:
  postgres-data:
  redis-data:

networks:
  workflowhub-network:
    driver: bridge
```

---

## Module 6.3: Monitoring and Observability

### The Target

Implement comprehensive monitoring, logging, and alerting for your production workflows.

### The Concept

Observability is like **mission control for your workflows**:

1. **Logs**: The raw telemetry data (everything that happened)
2. **Metrics**: The dashboard gauges (how fast, how many)
3. **Traces**: The flight path (exactly what happened when)
4. **Alerts**: The alarms (when something goes wrong)

### The Implementation: Monitoring System

```typescript
// src/lib/monitoring/metrics.ts
import { config, isProduction } from '@/lib/config';

// Metrics collector
class MetricsCollector {
  private metrics: Record<string, number[]> = {};
  private timers: Record<string, number> = {};
  
  // Record a metric
  record(name: string, value: number, tags?: Record<string, string>) {
    if (!this.metrics[name]) {
      this.metrics[name] = [];
    }
    this.metrics[name].push(value);
    
    // In production, send to metrics service
    if (isProduction) {
      // Example: send to Datadog, Prometheus, etc.
      // metricsService.record(name, value, tags);
    }
    
    // Keep only last 1000 values
    if (this.metrics[name].length > 1000) {
      this.metrics[name].shift();
    }
  }
  
  // Start a timer
  startTimer(name: string) {
    this.timers[name] = Date.now();
  }
  
  // End a timer and record duration
  endTimer(name: string, tags?: Record<string, string>) {
    const startTime = this.timers[name];
    if (!startTime) return;
    
    const duration = Date.now() - startTime;
    this.record(`${name}.duration`, duration, tags);
    delete this.timers[name];
    
    return duration;
  }
  
  // Get metrics summary
  getMetrics() {
    const summary: Record<string, any> = {};
    
    for (const [name, values] of Object.entries(this.metrics)) {
      const sorted = [...values].sort();
      const sum = sorted.reduce((a, b) => a + b, 0);
      
      summary[name] = {
        count: values.length,
        min: sorted[0],
        max: sorted[sorted.length - 1],
        avg: sum / values.length,
        p50: sorted[Math.floor(values.length * 0.5)],
        p95: sorted[Math.floor(values.length * 0.95)],
        p99: sorted[Math.floor(values.length * 0.99)],
      };
    }
    
    return summary;
  }
  
  // Reset metrics
  reset() {
    this.metrics = {};
    this.timers = {};
  }
}

export const metrics = new MetricsCollector();

// Middleware to track workflow performance
export const metricsMiddleware = new InngestMiddleware({
  name: 'Metrics Collection',
  init: () => ({
    onFunctionRun: ({ fn, ctx }) => {
      metrics.startTimer(`function.${fn.id}`);
      
      return {
        onStepRun: ({ step, run }) => {
          metrics.startTimer(`step.${step.name}`);
          
          return {
            transformOutput: ({ output }) => {
              metrics.endTimer(`step.${step.name}`, {
                function: fn.id,
                success: !(output instanceof Error),
              });
              return { output };
            },
          };
        },
        onFunctionComplete: ({ result }) => {
          metrics.endTimer(`function.${fn.id}`, {
            function: fn.id,
            success: result.success,
          });
          
          // Track status
          metrics.record(`function.${fn.id}.status`, result.success ? 1 : 0);
        },
      };
    },
  }),
});
```

#### Logging System

```typescript
// src/lib/monitoring/logger.ts
import { config, isProduction } from '@/lib/config';

// Log levels
export enum LogLevel {
  DEBUG = 'debug',
  INFO = 'info',
  WARN = 'warn',
  ERROR = 'error',
}

// Log entry interface
interface LogEntry {
  level: LogLevel;
  message: string;
  timestamp: string;
  context?: Record<string, any>;
  error?: Error;
}

// Structured logger
export class Logger {
  private static instance: Logger;
  private logLevel: LogLevel;
  
  private constructor() {
    this.logLevel = (config.LOG_LEVEL as LogLevel) || LogLevel.INFO;
  }
  
  static getInstance() {
    if (!Logger.instance) {
      Logger.instance = new Logger();
    }
    return Logger.instance;
  }
  
  // Log a message
  log(level: LogLevel, message: string, context?: Record<string, any>, error?: Error) {
    // Check if we should log this level
    if (this.shouldLog(level)) {
      const entry: LogEntry = {
        level,
        message,
        timestamp: new Date().toISOString(),
        context,
        error,
      };
      
      // Format for output
      const output = this.formatLogEntry(entry);
      
      // Write to appropriate output
      switch (level) {
        case LogLevel.ERROR:
          console.error(output);
          break;
        case LogLevel.WARN:
          console.warn(output);
          break;
        case LogLevel.INFO:
          console.info(output);
          break;
        case LogLevel.DEBUG:
          console.debug(output);
          break;
      }
      
      // In production, send to logging service
      if (isProduction && level === LogLevel.ERROR) {
        // Example: send to DataDog, Logtail, etc.
        // logService.send(entry);
      }
    }
  }
  
  // Convenience methods
  debug(message: string, context?: Record<string, any>) {
    this.log(LogLevel.DEBUG, message, context);
  }
  
  info(message: string, context?: Record<string, any>) {
    this.log(LogLevel.INFO, message, context);
  }
  
  warn(message: string, context?: Record<string, any>) {
    this.log(LogLevel.WARN, message, context);
  }
  
  error(message: string, error?: Error, context?: Record<string, any>) {
    this.log(LogLevel.ERROR, message, context, error);
  }
  
  // Check if we should log this level
  private shouldLog(level: LogLevel): boolean {
    const levels = Object.values(LogLevel);
    const currentIndex = levels.indexOf(this.logLevel);
    const levelIndex = levels.indexOf(level);
    return levelIndex >= currentIndex;
  }
  
  // Format log entry
  private formatLogEntry(entry: LogEntry): string {
    const { level, message, timestamp, context, error } = entry;
    
    let output = `[${timestamp}] [${level.toUpperCase()}] ${message}`;
    
    if (context && Object.keys(context).length > 0) {
      output += `\nContext: ${JSON.stringify(context, null, 2)}`;
    }
    
    if (error) {
      output += `\nError: ${error.message}`;
      if (error.stack) {
        output += `\nStack: ${error.stack}`;
      }
    }
    
    return output;
  }
}

export const logger = Logger.getInstance();
```

#### Health Check Endpoint

```typescript
// src/app/api/health/route.ts
import { NextResponse } from 'next/server';
import { config, isProduction } from '@/lib/config';
import { checkInngestHealth } from '@/inngest/client';

// Health check response interface
interface HealthResponse {
  status: 'healthy' | 'unhealthy' | 'degraded';
  timestamp: string;
  version: string;
  services: {
    inngest: { healthy: boolean; error?: string };
    database: { healthy: boolean; error?: string };
    redis?: { healthy: boolean; error?: string };
  };
  uptime: number;
  metrics?: any;
}

// GET /api/health - Health check endpoint
export async function GET() {
  try {
    const startTime = Date.now();
    
    // Check all services
    const [inngestHealth, dbHealth] = await Promise.all([
      checkInngestHealth(),
      checkDatabaseHealth(),
      checkRedisHealth(),
    ]);
    
    const services = {
      inngest: inngestHealth,
      database: dbHealth,
      redis: { healthy: true }, // Optional
    };
    
    // Determine overall status
    let status: 'healthy' | 'unhealthy' | 'degraded' = 'healthy';
    const unhealthyServices = Object.entries(services)
      .filter(([_, service]) => !service.healthy);
    
    if (unhealthyServices.length > 0) {
      status = unhealthyServices.length === 1 ? 'degraded' : 'unhealthy';
    }
    
    // Build response
    const response: HealthResponse = {
      status,
      timestamp: new Date().toISOString(),
      version: process.env.npm_package_version || 'unknown',
      services,
      uptime: (Date.now() - startTime) / 1000,
    };
    
    // Add metrics in production (but not on every request)
    if (isProduction && Math.random() < 0.01) {
      response.metrics = { /* metrics summary */ };
    }
    
    // Return response with appropriate status code
    const statusCode = status === 'healthy' ? 200 : status === 'degraded' ? 207 : 503;
    
    return NextResponse.json(response, { status: statusCode });
    
  } catch (error) {
    // If health check itself fails
    return NextResponse.json(
      {
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        error: error.message,
      },
      { status: 503 }
    );
  }
}

// Helper: Check database health
async function checkDatabaseHealth() {
  try {
    // In a real app, you'd query the database
    // await prisma.$queryRaw`SELECT 1`;
    return { healthy: true };
  } catch (error) {
    return { healthy: false, error: error.message };
  }
}

// Helper: Check Redis health
async function checkRedisHealth() {
  try {
    // In a real app, you'd ping Redis
    // await redis.ping();
    return { healthy: true };
  } catch (error) {
    return { healthy: false, error: error.message };
  }
}
```

---

## Module 6.4: Testing and CI/CD

### The Target

Implement comprehensive testing and CI/CD pipelines for your workflows.

### The Concept

Testing is like **flight simulator training** for your workflows:

1. **Unit Tests**: Test individual steps in isolation
2. **Integration Tests**: Test entire workflows with dependencies
3. **End-to-End Tests**: Test the complete system
4. **Performance Tests**: Test under load
5. **CI/CD**: Automate the whole process

### The Implementation: Testing Suite

```typescript
// src/inngest/__tests__/workflow.test.ts
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { inngest } from '@/inngest/client';
import { userRegistrationWorkflow } from '@/inngest/functions/user-registration';

// Mock Inngest for testing
vi.mock('@/inngest/client', () => ({
  inngest: {
    createFunction: vi.fn(),
    send: vi.fn(),
  },
}));

describe('User Registration Workflow', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });
  
  afterEach(() => {
    vi.resetAllMocks();
  });
  
  it('should process user registration successfully', async () => {
    // Mock step.run to execute the provided function
    const mockStep = {
      run: vi.fn().mockImplementation(async (name: string, fn: () => any) => {
        return await fn();
      }),
    };
    
    const mockLogger = {
      info: vi.fn(),
      error: vi.fn(),
      warn: vi.fn(),
      debug: vi.fn(),
    };
    
    const event = {
      data: {
        userId: '123e4567-e89b-12d3-a456-426614174000',
        email: 'test@example.com',
        name: 'Test User',
        plan: 'pro' as const,
      },
      name: 'user/registered' as const,
      id: 'test-123',
      ts: Date.now(),
    };
    
    // Execute the workflow handler
    const result = await userRegistrationWorkflow.handler({
      event,
      step: mockStep,
      logger: mockLogger,
      attempt: 1,
      runId: 'test-run',
    });
    
    // Assertions
    expect(result).toBeDefined();
    expect(result.userId).toBe(event.data.userId);
    expect(result.email).toBe(event.data.email);
    expect(result.processed).toBe(true);
    expect(result.emailSent).toBeDefined();
    expect(result.profileCreated).toBeDefined();
    expect(result.crmSynced).toBeDefined();
    
    // Verify step execution
    expect(mockStep.run).toHaveBeenCalledTimes(3);
    expect(mockStep.run).toHaveBeenCalledWith(
      'send-welcome-email',
      expect.any(Function)
    );
    expect(mockStep.run).toHaveBeenCalledWith(
      'create-user-profile',
      expect.any(Function)
    );
    expect(mockStep.run).toHaveBeenCalledWith(
      'sync-with-crm',
      expect.any(Function)
    );
    
    // Verify logging
    expect(mockLogger.info).toHaveBeenCalled();
    expect(mockLogger.info).toHaveBeenCalledWith(
      'Processing user registration',
      expect.objectContaining({
        userId: event.data.userId,
        email: event.data.email,
      })
    );
  });
  
  it('should handle validation errors', async () => {
    const mockStep = {
      run: vi.fn().mockImplementation(async (name: string, fn: () => any) => {
        return await fn();
      }),
    };
    
    const mockLogger = {
      info: vi.fn(),
      error: vi.fn(),
      warn: vi.fn(),
      debug: vi.fn(),
    };
    
    const invalidEvent = {
      data: {
        userId: 'invalid-uuid', // Invalid UUID
        email: 'not-an-email', // Invalid email
        name: 'A', // Too short
        plan: 'invalid' as any, // Invalid plan
      },
      name: 'user/registered' as const,
      id: 'test-123',
      ts: Date.now(),
    };
    
    // Execute the workflow handler and expect it to throw
    await expect(
      userRegistrationWorkflow.handler({
        event: invalidEvent,
        step: mockStep,
        logger: mockLogger,
        attempt: 1,
        runId: 'test-run',
      })
    ).rejects.toThrow();
  });
  
  it('should handle step failures with retries', async () => {
    let callCount = 0;
    
    const mockStep = {
      run: vi.fn().mockImplementation(async (name: string, fn: () => any) => {
        callCount++;
        if (name === 'send-welcome-email' && callCount === 1) {
          throw new Error('Simulated failure');
        }
        return await fn();
      }),
    };
    
    const mockLogger = {
      info: vi.fn(),
      error: vi.fn(),
      warn: vi.fn(),
      debug: vi.fn(),
    };
    
    const event = {
      data: {
        userId: '123e4567-e89b-12d3-a456-426614174000',
        email: 'test@example.com',
        name: 'Test User',
        plan: 'pro' as const,
      },
      name: 'user/registered' as const,
      id: 'test-123',
      ts: Date.now(),
    };
    
    // Execute the workflow handler
    const result = await userRegistrationWorkflow.handler({
      event,
      step: mockStep,
      logger: mockLogger,
      attempt: 1,
      runId: 'test-run',
    });
    
    // Verify the failed step was retried
    expect(mockStep.run).toHaveBeenCalledWith(
      'send-welcome-email',
      expect.any(Function)
    );
    
    // Verify the overall workflow still succeeded
    expect(result.processed).toBe(true);
  });
});
```

#### Integration Tests

```typescript
// src/inngest/__tests__/integration.test.ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { inngest } from '@/inngest/client';
import { userRegistrationWorkflow } from '@/inngest/functions/user-registration';

describe('Integration Tests', () => {
  beforeAll(async () => {
    // Setup test environment
    // - Start test database
    // - Seed test data
    // - Configure test environment variables
  });
  
  afterAll(async () => {
    // Cleanup
    // - Close database connections
    // - Remove test data
  });
  
  it('should process a real user registration end-to-end', async () => {
    // Send a test event
    const result = await inngest.send({
      name: 'user/registered',
      data: {
        userId: '123e4567-e89b-12d3-a456-426614174000',
        email: 'integration-test@example.com',
        name: 'Integration Test',
        plan: 'pro',
      },
    });
    
    // Verify the event was sent
    expect(result.ids).toBeDefined();
    expect(result.ids.length).toBeGreaterThan(0);
    
    // Wait for the workflow to complete (in a real test, you'd poll)
    await new Promise((resolve) => setTimeout(resolve, 5000));
    
    // Verify the workflow completed successfully
    // In a real test, you'd check the database
    // const user = await prisma.user.findUnique({ where: { email: 'integration-test@example.com' } });
    // expect(user).toBeDefined();
    // expect(user.name).toBe('Integration Test');
  });
});
```

#### Performance Tests

```typescript
// src/inngest/__tests__/performance.test.ts
import { describe, it, expect } from 'vitest';

describe('Performance Tests', () => {
  it('should handle high concurrency', async () => {
    const concurrency = 50;
    const events = [];
    
    // Create many events
    for (let i = 0; i < concurrency; i++) {
      events.push({
        name: 'user/registered',
        data: {
          userId: `user-${i}-${Date.now()}`,
          email: `user${i}@test.com`,
          name: `User ${i}`,
          plan: 'pro' as const,
        },
      });
    }
    
    const startTime = Date.now();
    
    // Send all events concurrently
    const results = await Promise.all(
      events.map(event => inngest.send(event))
    );
    
    const duration = Date.now() - startTime;
    
    // Verify all events were sent
    expect(results.length).toBe(concurrency);
    expect(results.every(r => r.ids.length > 0)).toBe(true);
    
    // Log performance metrics
    console.log(`Processed ${concurrency} events in ${duration}ms`);
    console.log(`Average: ${duration / concurrency}ms per event`);
    
    // Performance expectation: < 10 seconds for 50 events
    expect(duration).toBeLessThan(10000);
  });
  
  it('should maintain performance under load', async () => {
    const iterations = 10;
    const durations = [];
    
    for (let i = 0; i < iterations; i++) {
      const startTime = Date.now();
      
      await inngest.send({
        name: 'user/registered',
        data: {
          userId: `load-user-${i}-${Date.now()}`,
          email: `load${i}@test.com`,
          name: `Load User ${i}`,
          plan: 'pro' as const,
        },
      });
      
      durations.push(Date.now() - startTime);
    }
    
    // Calculate statistics
    const average = durations.reduce((a, b) => a + b, 0) / durations.length;
    const min = Math.min(...durations);
    const max = Math.max(...durations);
    
    console.log(`Performance test results:`);
    console.log(`  Average: ${average}ms`);
    console.log(`  Min: ${min}ms`);
    console.log(`  Max: ${max}ms`);
    
    // Performance expectation: average < 1000ms
    expect(average).toBeLessThan(1000);
  });
});
```

#### CI/CD Pipeline

```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '20'

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        node-version: [18.x, 20.x]
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'pnpm'
      
      - name: Install dependencies
        run: pnpm install --frozen-lockfile
      
      - name: Run linting
        run: pnpm lint
      
      - name: Run type checking
        run: pnpm type-check
      
      - name: Run unit tests
        run: pnpm test
      
      - name: Run integration tests
        run: pnpm test:integration
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
      
      - name: Run performance tests
        run: pnpm test:performance
      
      - name: Upload test coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
      
      - name: Upload test results
        uses: actions/upload-artifact@v3
        if: failure()
        with:
          name: test-results
          path: ./test-results/

  build:
    name: Build
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'pnpm'
      
      - name: Install dependencies
        run: pnpm install --frozen-lockfile
      
      - name: Build application
        run: pnpm build
        env:
          NODE_ENV: production
      
      - name: Upload build artifacts
        uses: actions/upload-artifact@v3
        with:
          name: build
          path: .next/

  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/develop'
    
    environment:
      name: staging
      url: https://staging.workflowhub.com
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: build
          path: .next/
      
      - name: Deploy to Vercel (Preview)
        run: npx vercel --prod --prebuilt --token ${{ secrets.VERCEL_TOKEN }}
        env:
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
      
      - name: Run smoke tests
        run: pnpm test:smoke
        env:
          APP_URL: https://staging.workflowhub.com

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: [build, deploy-staging]
    if: github.ref == 'refs/heads/main'
    
    environment:
      name: production
      url: https://workflowhub.com
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Download build artifacts
        uses: actions/download-artifact@v3
        with:
          name: build
          path: .next/
      
      - name: Deploy to Vercel (Production)
        run: npx vercel --prod --prebuilt --token ${{ secrets.VERCEL_TOKEN }}
        env:
          VERCEL_ORG_ID: ${{ secrets.VERCEL_ORG_ID }}
          VERCEL_PROJECT_ID: ${{ secrets.VERCEL_PROJECT_ID }}
      
      - name: Run smoke tests
        run: pnpm test:smoke
        env:
          APP_URL: https://workflowhub.com
      
      - name: Create GitHub Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: v${{ env.VERSION }}
          release_name: Release v${{ env.VERSION }}
          draft: false
          prerelease: false
```

---

## Module 6.5: Production Monitoring Dashboard

### The Target

Build a comprehensive monitoring dashboard for your production workflows.

### The Concept

A monitoring dashboard is like **mission control for your workflows**:

1. **System Health**: Are all systems operational?
2. **Workflow Status**: What's running, completed, or failed?
3. **Performance Metrics**: How fast are workflows completing?
4. **Error Rates**: Are there any recurring issues?
5. **Alerts**: What needs immediate attention?

### The Implementation: Monitoring UI

```typescript
// src/app/admin/monitoring/page.tsx
'use client';

import { useState, useEffect } from 'react';
import { useWorkflowStatus } from '@/lib/hooks/useWorkflowStatus';

interface SystemMetrics {
  totalWorkflows: number;
  activeWorkflows: number;
  completedWorkflows: number;
  failedWorkflows: number;
  averageDuration: number;
  errorRate: number;
  throughput: number;
  timestamp: string;
}

interface Alert {
  id: string;
  severity: 'info' | 'warning' | 'critical';
  message: string;
  timestamp: string;
  acknowledged: boolean;
}

export default function MonitoringPage() {
  const [metrics, setMetrics] = useState<SystemMetrics | null>(null);
  const [alerts, setAlerts] = useState<Alert[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedTimeRange, setSelectedTimeRange] = useState('1h');
  
  // Fetch metrics
  useEffect(() => {
    async function fetchMetrics() {
      try {
        // In a real app, you'd fetch from your API
        const mockMetrics: SystemMetrics = {
          totalWorkflows: 1247,
          activeWorkflows: 23,
          completedWorkflows: 1198,
          failedWorkflows: 26,
          averageDuration: 2430, // milliseconds
          errorRate: 2.08, // percentage
          throughput: 12.4, // workflows per minute
          timestamp: new Date().toISOString(),
        };
        setMetrics(mockMetrics);
      } catch (error) {
        console.error('Failed to fetch metrics:', error);
      } finally {
        setLoading(false);
      }
    }
    
    fetchMetrics();
    
    // Refresh every 10 seconds
    const interval = setInterval(fetchMetrics, 10000);
    return () => clearInterval(interval);
  }, []);
  
  // Fetch alerts
  useEffect(() => {
    async function fetchAlerts() {
      try {
        // In a real app, you'd fetch from your API
        const mockAlerts: Alert[] = [
          {
            id: 'alert-1',
            severity: 'critical',
            message: 'High error rate detected in order processing workflow',
            timestamp: new Date(Date.now() - 300000).toISOString(),
            acknowledged: false,
          },
          {
            id: 'alert-2',
            severity: 'warning',
            message: 'Rate limit approaching for email campaign workflow',
            timestamp: new Date(Date.now() - 600000).toISOString(),
            acknowledged: false,
          },
          {
            id: 'alert-3',
            severity: 'info',
            message: 'New version 2.0.0 deployed successfully',
            timestamp: new Date(Date.now() - 3600000).toISOString(),
            acknowledged: true,
          },
        ];
        setAlerts(mockAlerts);
      } catch (error) {
        console.error('Failed to fetch alerts:', error);
      }
    }
    
    fetchAlerts();
    
    // Refresh every 30 seconds
    const interval = setInterval(fetchAlerts, 30000);
    return () => clearInterval(interval);
  }, []);
  
  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>
    );
  }
  
  return (
    <div className="max-w-7xl mx-auto p-6">
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-3xl font-bold">System Monitoring</h1>
          <p className="text-gray-600 mt-1">
            Last updated: {new Date().toLocaleString()}
          </p>
        </div>
        <div className="flex items-center gap-3">
          <select
            value={selectedTimeRange}
            onChange={(e) => setSelectedTimeRange(e.target.value)}
            className="px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500"
          >
            <option value="1h">Last Hour</option>
            <option value="6h">Last 6 Hours</option>
            <option value="24h">Last 24 Hours</option>
            <option value="7d">Last 7 Days</option>
          </select>
          <button
            onClick={() => window.location.reload()}
            className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors"
          >
            Refresh
          </button>
        </div>
      </div>
      
      {/* Metrics Grid */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div className="text-sm text-gray-500">Total Workflows</div>
          <div className="text-2xl font-bold mt-1">{metrics?.totalWorkflows}</div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div className="text-sm text-gray-500">Active Workflows</div>
          <div className="text-2xl font-bold mt-1 text-blue-600">
            {metrics?.activeWorkflows}
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div className="text-sm text-gray-500">Success Rate</div>
          <div className="text-2xl font-bold mt-1 text-green-600">
            {(100 - (metrics?.errorRate || 0)).toFixed(1)}%
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div className="text-sm text-gray-500">Throughput</div>
          <div className="text-2xl font-bold mt-1 text-purple-600">
            {metrics?.throughput} /min
          </div>
        </div>
      </div>
      
      {/* Performance Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div className="text-sm text-gray-500">Avg Duration</div>
          <div className="text-xl font-bold mt-1">
            {(metrics?.averageDuration || 0) / 1000}s
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div className="text-sm text-gray-500">Completed</div>
          <div className="text-xl font-bold mt-1 text-green-600">
            {metrics?.completedWorkflows}
          </div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div className="text-sm text-gray-500">Failed</div>
          <div className="text-xl font-bold mt-1 text-red-600">
            {metrics?.failedWorkflows}
          </div>
        </div>
      </div>
      
      {/* Alerts */}
      <div className="bg-white rounded-lg shadow-sm border border-gray-200">
        <div className="px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold">Alerts</h2>
        </div>
        <div className="divide-y divide-gray-200">
          {alerts.length === 0 ? (
            <div className="p-8 text-center text-gray-500">No alerts</div>
          ) : (
            alerts.map((alert) => (
              <div
                key={alert.id}
                className={`p-4 hover:bg-gray-50 transition-colors ${
                  !alert.acknowledged ? 'bg-yellow-50' : ''
                }`}
              >
                <div className="flex items-start justify-between">
                  <div className="flex items-start gap-3">
                    <span className={`text-2xl ${
                      alert.severity === 'critical' ? 'text-red-600' :
                      alert.severity === 'warning' ? 'text-yellow-600' :
                      'text-blue-600'
                    }`}>
                      {alert.severity === 'critical' ? '🔴' :
                       alert.severity === 'warning' ? '⚠️' :
                       'ℹ️'}
                    </span>
                    <div>
                      <p className="font-medium">{alert.message}</p>
                      <p className="text-sm text-gray-500 mt-1">
                        {new Date(alert.timestamp).toLocaleString()}
                      </p>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    {!alert.acknowledged && (
                      <button className="px-3 py-1 text-sm bg-blue-100 text-blue-700 rounded hover:bg-blue-200 transition-colors">
                        Acknowledge
                      </button>
                    )}
                    <span className={`px-2 py-1 text-xs rounded-full ${
                      alert.severity === 'critical' ? 'bg-red-100 text-red-800' :
                      alert.severity === 'warning' ? 'bg-yellow-100 text-yellow-800' :
                      'bg-blue-100 text-blue-800'
                    }`}>
                      {alert.severity}
                    </span>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
```

---

## Final Production Checklist

Before deploying to production, ensure you have completed the following:

### Security
- [ ] Environment variables are properly encrypted/secret
- [ ] Event signing keys are secure
- [ ] API endpoints are authenticated
- [ ] Rate limiting is configured
- [ ] Security headers are set
- [ ] CORS is properly configured

### Performance
- [ ] Concurrency limits are optimized
- [ ] Rate limits are configured
- [ ] Database indexes are created
- [ ] Redis caching is set up (if needed)
- [ ] Cold start mitigation is in place

### Reliability
- [ ] Retry policies are configured
- [ ] Error handling is comprehensive
- [ ] Health checks are implemented
- [ ] Monitoring is set up
- [ ] Alerts are configured
- [ ] Backups are scheduled

### Observability
- [ ] Logging is configured
- [ ] Metrics are collected
- [ ] Tracing is implemented
- [ ] Dashboard is set up
- [ ] Incident response plan is documented

### Testing
- [ ] Unit tests are passing
- [ ] Integration tests are passing
- [ ] Performance tests are passing
- [ ] CI/CD pipeline is working
- [ ] Smoke tests are passing

### Deployment
- [ ] Deployment strategy is defined
- [ ] Rollback plan is documented
- [ ] Blue-green or canary deployment is configured
- [ ] Database migrations are automated
- [ ] Production environment is prepared

---

## What You've Accomplished

In Part 6, you've mastered production deployment:

1. ✅ Production architecture and configuration
2. ✅ Environment validation and security
3. ✅ Multiple deployment strategies (Vercel, AWS, Docker)
4. ✅ Comprehensive monitoring and observability
5. ✅ Structured logging system
6. ✅ Health checks and status endpoints
7. ✅ Testing suite (unit, integration, performance)
8. ✅ CI/CD pipeline with GitHub Actions
9. ✅ Production monitoring dashboard
10. ✅ Complete deployment checklist

You've learned:
- How to configure Inngest for production
- How to deploy to various cloud platforms
- How to monitor and observe production workflows
- How to test workflows comprehensively
- How to set up CI/CD pipelines
- Best practices for production operations

---

## Deep Dive Reference: Production Best Practices

### Inngest Production Configuration

```typescript
// Production-ready Inngest client
export const inngest = new Inngest({
  id: 'workflowhub',
  name: 'WorkflowHub',
  
  // Always use environment variables in production
  eventKey: process.env.INNGEST_EVENT_KEY,
  signingKey: process.env.INNGEST_SIGNING_KEY,
  
  // Production retry strategy
  retryFunction: (attempt: number) => ({
    delay: Math.min(Math.pow(2, attempt) * 1000, 60000),
    maxAttempts: 5,
  }),
  
  // Production middleware
  middleware: [
    sentryMiddleware,
    metricsMiddleware,
    loggingMiddleware,
  ],
  
  // Production logger
  logger: {
    debug: () => {},
    info: (msg) => console.log(`[INFO] ${msg}`),
    warn: (msg) => console.warn(`[WARN] ${msg}`),
    error: (msg) => console.error(`[ERROR] ${msg}`),
  },
});
```

### Security Best Practices

```typescript
// API authentication middleware
export const authMiddleware = new InngestMiddleware({
  name: 'Authentication',
  init: () => ({
    onFunctionRun: ({ ctx }) => {
      // Verify API key
      const apiKey = ctx.headers['x-api-key'];
      if (!apiKey || apiKey !== process.env.API_KEY) {
        throw new Error('Unauthorized');
      }
      
      // Verify signature
      const signature = ctx.headers['x-inngest-signature'];
      if (signature) {
        // Verify the signature
        // ...
      }
    },
  }),
});
```

### Performance Optimization

```typescript
// Use connection pooling for databases
const pool = new Pool({
  max: 20,
  idleTimeoutMillis: 30000,
});

// Use Redis for caching
const cache = new Redis({
  host: process.env.REDIS_HOST,
  password: process.env.REDIS_PASSWORD,
  retryStrategy: (times) => Math.min(times * 100, 3000),
});

// Implement circuit breaker pattern
class CircuitBreaker {
  private failureCount = 0;
  private lastFailureTime = 0;
  private state: 'closed' | 'open' | 'half-open' = 'closed';
  
  async execute<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'open') {
      throw new Error('Circuit breaker is open');
    }
    
    try {
      const result = await fn();
      this.reset();
      return result;
    } catch (error) {
      this.recordFailure();
      throw error;
    }
  }
  
  private recordFailure() {
    this.failureCount++;
    if (this.failureCount >= 5) {
      this.state = 'open';
      this.lastFailureTime = Date.now();
      setTimeout(() => {
        this.state = 'half-open';
      }, 60000);
    }
  }
  
  private reset() {
    this.failureCount = 0;
    this.state = 'closed';
  }
}
```

---

## Series Conclusion

Congratulations! You've completed the entire Mastering Inngest series. You now have:

1. **A deep understanding** of event-driven architecture and durable execution
2. **Production-ready workflows** for registration, orders, invoices, payments, campaigns, and approvals
3. **High-performance patterns** including fan-out, concurrency control, and rate limiting
4. **Long-running workflows** with human-in-the-loop and saga patterns
5. **Full-stack integration** with React 19, Next.js 16, and real-time updates
6. **Production deployment** strategies with monitoring, observability, and CI/CD

### The WorkflowMindset

You've developed the WorkflowMindset—thinking in terms of durable, resilient, event-driven processes that survive failures and scale effortlessly.

### Next Steps

Continue your journey with:

1. **Build your own workflows**: Apply these patterns to your specific business needs
2. **Explore advanced patterns**: AI workflows, event sourcing, CQRS
3. **Join the Inngest community**: Share your experiences and learn from others
4. **Contribute to open source**: Help improve the Inngest ecosystem
5. **Teach others**: Share what you've learned with your team and community

### Resources

- [Inngest Documentation](https://www.inngest.com/docs)
- [Inngest Discord Community](https://discord.gg/inngest)
- [GitHub Repository](https://github.com/inngest/inngest)
- [Inngest Blog](https://www.inngest.com/blog)

### Thank You

Thank you for going on this journey with me. You've invested significant time and effort to master durable execution, and I'm confident it will pay dividends in your career and projects.

Now go build something amazing! 🚀
