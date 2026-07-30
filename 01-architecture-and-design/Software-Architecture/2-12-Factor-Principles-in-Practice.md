# Phase 1, Part 2: 12-Factor Principles in Practice

## Building a Production-Ready Foundation

Now that we have a working service, let's make it production-ready by applying the 12-Factor App methodology. Think of this as upgrading from a prototype to something that can survive in the wild - like moving from a test kitchen to a real restaurant.

### 1. The Target

**What we're building:** Enhancements to our gateway service that implement 12-Factor principles:
- Externalized configuration (Factor 3)
- Backing services as attached resources (Factor 4)
- Strict separation of build, release, run (Factor 5)
- Processes that are stateless and share-nothing (Factor 6)
- Port binding (Factor 8)
- Disposability with fast startup and graceful shutdown (Factor 9)
- Logging as event streams (Factor 11)
- Admin processes run as one-off tasks (Factor 12)

**Updated File Structure:**
```
packages/gateway/
├── src/
│   ├── index.ts
│   ├── server.ts
│   ├── config.ts
│   ├── logger.ts
│   ├── health/
│   │   ├── health.controller.ts
│   │   └── health.routes.ts
│   ├── middleware/
│   │   ├── request-id.ts
│   │   ├── cors.ts
│   │   └── metrics.ts
│   └── admin/
│       ├── db-migrate.ts
│       └── health-check.ts
├── scripts/
│   ├── build.sh
│   └── docker-entrypoint.sh
├── package.json
├── tsconfig.json
├── .env.example
├── Dockerfile
├── docker-compose.yml
└── .dockerignore
```

### 2. The Concept: 12-Factor Principles Explained

Imagine you're running a restaurant chain. The 12-Factor principles are like standard operating procedures that ensure every location runs consistently:

**Factor 3: Config in Environment** → Like having a standard recipe that works everywhere, but allowing each location to adjust based on local ingredients and equipment.

**Factor 4: Backing Services** → Like treating your suppliers (meat, produce, dairy) as interchangeable resources. You can switch suppliers without changing your recipes.

**Factor 6: Stateless Processes** → Like a chef who doesn't remember orders from the previous day. Each shift starts fresh.

**Factor 9: Disposability** → Like a dish that can be quickly prepared (fast startup) and cleaned up (graceful shutdown) without leaving a mess.

**Factor 11: Logs as Event Streams** → Like having security cameras that record everything. You don't analyze the footage in real-time; you stream it to a central monitoring system.

### 3. The Implementation

Let's enhance our service step by step.

#### Step 1: Enhanced Configuration Management

**File:** `packages/gateway/src/config.ts` (Updated)

```typescript
import dotenv from 'dotenv';
import { z } from 'zod';
import { existsSync } from 'fs';
import { resolve } from 'path';

// Load environment files based on NODE_ENV
const envFile = process.env.NODE_ENV === 'production' 
  ? '.env.production' 
  : process.env.NODE_ENV === 'test' 
    ? '.env.test' 
    : '.env.development';

// Try to load environment-specific file, fallback to .env
const envPath = resolve(process.cwd(), envFile);
if (existsSync(envPath)) {
  dotenv.config({ path: envPath });
} else {
  dotenv.config(); // Load default .env
}

/**
 * 12-Factor: Config in Environment (Factor 3)
 * 
 * All configuration is stored in environment variables.
 * This allows the same codebase to run in different environments
 * without changes.
 */
const configSchema = z.object({
  // Environment
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  
  // Server
  PORT: z.coerce.number().min(1).max(65535).default(3000),
  HOST: z.string().default('0.0.0.0'),
  
  // Logging
  LOG_LEVEL: z.enum(['trace', 'debug', 'info', 'warn', 'error', 'fatal']).default('info'),
  
  // Service metadata
  SERVICE_NAME: z.string().default('gateway'),
  SERVICE_VERSION: z.string().default('1.0.0'),
  
  // Database (12-Factor: Backing Services - Factor 4)
  DATABASE_URL: z.string().optional(),
  DATABASE_MAX_CONNECTIONS: z.coerce.number().default(10),
  DATABASE_IDLE_TIMEOUT: z.coerce.number().default(30000),
  
  // Redis (12-Factor: Backing Services - Factor 4)
  REDIS_URL: z.string().optional(),
  REDIS_MAX_RETRIES: z.coerce.number().default(3),
  
  // External Services (12-Factor: Backing Services - Factor 4)
  AUTH_SERVICE_URL: z.string().default('http://auth-service:3001'),
  USER_SERVICE_URL: z.string().default('http://user-service:3002'),
  
  // Metrics
  METRICS_ENABLED: z.coerce.boolean().default(true),
  METRICS_PORT: z.coerce.number().default(9090),
  
  // Health Checks
  HEALTH_CHECK_INTERVAL: z.coerce.number().default(30000), // 30 seconds
  
  // Security
  JWT_SECRET: z.string().min(32).optional(),
  API_KEY: z.string().optional(),
  CORS_ORIGINS: z.string().default('*'),
  
  // Rate Limiting
  RATE_LIMIT_ENABLED: z.coerce.boolean().default(true),
  RATE_LIMIT_WINDOW: z.coerce.number().default(60000), // 1 minute
  RATE_LIMIT_MAX_REQUESTS: z.coerce.number().default(100),
});

// Parse and validate configuration
const parseResult = configSchema.safeParse(process.env);

if (!parseResult.success) {
  console.error('❌ Invalid configuration:', parseResult.error.errors);
  process.exit(1);
}

export const config = parseResult.data;

// Export individual constants for convenience
export const {
  NODE_ENV,
  PORT,
  HOST,
  LOG_LEVEL,
  SERVICE_NAME,
  SERVICE_VERSION,
  DATABASE_URL,
  DATABASE_MAX_CONNECTIONS,
  DATABASE_IDLE_TIMEOUT,
  REDIS_URL,
  REDIS_MAX_RETRIES,
  AUTH_SERVICE_URL,
  USER_SERVICE_URL,
  METRICS_ENABLED,
  METRICS_PORT,
  HEALTH_CHECK_INTERVAL,
  JWT_SECRET,
  API_KEY,
  CORS_ORIGINS,
  RATE_LIMIT_ENABLED,
  RATE_LIMIT_WINDOW,
  RATE_LIMIT_MAX_REQUESTS,
} = config;

// Derived configuration
export const IS_DEVELOPMENT = NODE_ENV === 'development';
export const IS_TEST = NODE_ENV === 'test';
export const IS_PRODUCTION = NODE_ENV === 'production';

// Validate required configuration for production
if (IS_PRODUCTION) {
  if (!JWT_SECRET) {
    console.error('❌ JWT_SECRET is required in production');
    process.exit(1);
  }
  if (!DATABASE_URL) {
    console.error('❌ DATABASE_URL is required in production');
    process.exit(1);
  }
}

// 12-Factor: Admin processes run as one-off tasks (Factor 12)
// We can detect if we're running as a one-off admin task
export const IS_ADMIN_TASK = process.argv.includes('--admin') || 
                            process.env.ADMIN_TASK === 'true';
```

#### Step 2: Enhanced Logging with Structured Events

**File:** `packages/gateway/src/logger.ts` (Updated)

```typescript
import pino from 'pino';
import { 
  NODE_ENV, 
  LOG_LEVEL, 
  SERVICE_NAME, 
  SERVICE_VERSION, 
  IS_PRODUCTION 
} from './config.js';
import os from 'os';

/**
 * 12-Factor: Logs as Event Streams (Factor 11)
 * 
 * Logs are treated as event streams, not files.
 * In production, logs go to stdout/stderr and are captured
 * by log aggregation systems (ELK, Datadog, etc.)
 */
const loggerConfig = {
  // Minimum log level
  level: LOG_LEVEL,
  
  // Base fields for every log entry
  base: {
    service: SERVICE_NAME,
    version: SERVICE_VERSION,
    env: NODE_ENV,
    host: os.hostname(),
    pid: process.pid,
  },
  
  // Timestamp format (ISO 8601)
  timestamp: pino.stdTimeFunctions.isoTime,
  
  // Error serializers
  serializers: {
    err: pino.stdSerializers.err,
    error: pino.stdSerializers.err,
    req: (req: any) => ({
      id: req.id,
      method: req.method,
      url: req.url,
      headers: {
        'user-agent': req.headers?.['user-agent'],
        'x-request-id': req.headers?.['x-request-id'],
      },
    }),
    res: (res: any) => ({
      statusCode: res.statusCode,
      duration: res.duration,
    }),
  },
  
  // Redact sensitive information
  redact: {
    paths: [
      'req.headers.authorization',
      'req.headers.cookie',
      'req.headers["x-api-key"]',
      'res.headers["set-cookie"]',
    ],
    censor: '***REDACTED***',
  },
  
  // Custom log levels
  customLevels: {
    trace: 10,
    debug: 20,
    info: 30,
    warn: 40,
    error: 50,
    fatal: 60,
  },
};

// Transport configuration (how logs are output)
if (!IS_PRODUCTION) {
  // Development: Pretty-printed logs for human consumption
  loggerConfig.transport = {
    target: 'pino-pretty',
    options: {
      colorize: true,
      translateTime: 'yyyy-mm-dd HH:MM:ss.l',
      ignore: 'pid,hostname',
      levelFirst: true,
      messageFormat: '{msg}',
      errorLikeObjectKeys: ['err', 'error'],
    },
  };
} else {
  // Production: JSON logs for machine consumption
  // No transport specified = use default JSON output
}

export const logger = pino(loggerConfig);

/**
 * Create a child logger with additional context
 * Used for request-specific logging
 */
export const createChildLogger = (bindings: Record<string, unknown>) => {
  return logger.child(bindings);
};

/**
 * Create a request-specific logger
 */
export const createRequestLogger = (requestId: string, extra?: Record<string, unknown>) => {
  return logger.child({
    requestId,
    ...extra,
  });
};

/**
 * Log performance metrics
 */
export const logPerformance = (
  operation: string,
  duration: number,
  metadata?: Record<string, unknown>
) => {
  logger.info({
    operation,
    duration,
    duration_ms: duration,
    ...metadata,
  }, `Performance: ${operation} took ${duration}ms`);
};

/**
 * Log business events
 */
export const logEvent = (
  eventName: string,
  payload: Record<string, unknown>,
  metadata?: Record<string, unknown>
) => {
  logger.info({
    event: eventName,
    payload,
    ...metadata,
  }, `Event: ${eventName}`);
};

/**
 * Log errors with proper formatting
 */
export const logError = (
  error: Error | unknown,
  context?: Record<string, unknown>
) => {
  logger.error({
    err: error instanceof Error ? error : new Error(String(error)),
    ...context,
  }, 'Error occurred');
};

export default logger;
```

#### Step 3: Middleware for Request Context

**File:** `packages/gateway/src/middleware/request-id.ts`

```typescript
import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { randomUUID } from 'crypto';

/**
 * Request ID Middleware
 * 
 * Generates a unique ID for each request for tracing.
 * This enables correlation between logs from different services.
 */
export async function requestIdMiddleware(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  // Check for existing request ID in headers (from upstream services)
  let requestId = request.headers['x-request-id'] as string | undefined;
  
  // Generate new ID if none provided
  if (!requestId) {
    requestId = randomUUID();
  }
  
  // Store request ID in request object
  (request as any).requestId = requestId;
  
  // Set response header
  reply.header('x-request-id', requestId);
  
  // Add to logger context
  request.log = request.log.child({ requestId });
}
```

**File:** `packages/gateway/src/middleware/cors.ts`

```typescript
import { FastifyInstance } from 'fastify';
import { CORS_ORIGINS, IS_DEVELOPMENT } from '../config.js';

/**
 * CORS Configuration
 * 
 * Configures Cross-Origin Resource Sharing for the API.
 * In development, we allow any origin for easy testing.
 * In production, we restrict to specific origins.
 */
export function setupCors(server: FastifyInstance): void {
  const origins = IS_DEVELOPMENT 
    ? '*' 
    : CORS_ORIGINS.split(',').map(origin => origin.trim());
  
  server.addHook('onRequest', (request, reply, done) => {
    // Simple CORS header
    if (typeof origins === 'string' && origins === '*') {
      reply.header('Access-Control-Allow-Origin', '*');
    } else if (Array.isArray(origins)) {
      const origin = request.headers.origin;
      if (origin && origins.includes(origin)) {
        reply.header('Access-Control-Allow-Origin', origin);
      }
    }
    
    // Always set these headers for preflight
    reply.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    reply.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Request-ID');
    reply.header('Access-Control-Allow-Credentials', 'true');
    
    // Handle preflight requests
    if (request.method === 'OPTIONS') {
      reply.status(204).send();
      return;
    }
    
    done();
  });
}
```

**File:** `packages/gateway/src/middleware/metrics.ts`

```typescript
import { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import { METRICS_ENABLED } from '../config.js';
import logger from '../logger.js';

/**
 * Simple metrics collection
 * 
 * 12-Factor: Processes are stateless and share-nothing (Factor 6)
 * Metrics are collected in-memory but should be exported to a
 * monitoring system (Prometheus) in production.
 */
export class MetricsCollector {
  private requestCount = 0;
  private errorCount = 0;
  private requestDuration: number[] = [];
  private statusCodes: Record<number, number> = {};
  private startTime = Date.now();
  
  /**
   * Record a request
   */
  recordRequest(request: FastifyRequest, reply: FastifyReply, duration: number): void {
    if (!METRICS_ENABLED) return;
    
    this.requestCount++;
    const statusCode = reply.statusCode;
    this.statusCodes[statusCode] = (this.statusCodes[statusCode] || 0) + 1;
    
    if (duration > 0) {
      this.requestDuration.push(duration);
      // Keep only last 1000 durations
      if (this.requestDuration.length > 1000) {
        this.requestDuration.shift();
      }
    }
    
    if (statusCode >= 400) {
      this.errorCount++;
    }
  }
  
  /**
   * Get current metrics snapshot
   */
  getMetrics() {
    const uptime = Date.now() - this.startTime;
    const avgDuration = this.requestDuration.length > 0
      ? this.requestDuration.reduce((a, b) => a + b, 0) / this.requestDuration.length
      : 0;
    
    return {
      requestCount: this.requestCount,
      errorCount: this.errorCount,
      errorRate: this.requestCount > 0 
        ? (this.errorCount / this.requestCount) * 100 
        : 0,
      averageDuration: Math.round(avgDuration),
      statusCodes: this.statusCodes,
      uptime: Math.floor(uptime / 1000),
      timestamp: new Date().toISOString(),
    };
  }
  
  /**
   * Reset metrics (for testing)
   */
  reset(): void {
    this.requestCount = 0;
    this.errorCount = 0;
    this.requestDuration = [];
    this.statusCodes = {};
    this.startTime = Date.now();
  }
}

// Singleton instance
export const metricsCollector = new MetricsCollector();

/**
 * Metrics Middleware
 */
export async function metricsMiddleware(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  if (!METRICS_ENABLED) return;
  
  const startTime = process.hrtime.bigint();
  
  // Store start time in request
  (request as any).metricsStartTime = startTime;
  
  // Hook into response finish event
  reply.raw.once('finish', () => {
    const duration = Number(process.hrtime.bigint() - startTime) / 1_000_000;
    metricsCollector.recordRequest(request, reply, duration);
  });
}
```

#### Step 4: Admin Tools (12-Factor: Admin Processes - Factor 12)

**File:** `packages/gateway/src/admin/health-check.ts`

```typescript
#!/usr/bin/env node

import { config } from '../config.js';
import logger from '../logger.js';

/**
 * Health Check Admin Tool
 * 
 * 12-Factor: Admin processes run as one-off tasks (Factor 12)
 * This script can be run to check service health from the command line.
 * 
 * Usage: npm run admin:health-check -- --service=gateway
 */
async function main(): Promise<void> {
  logger.info('Running health check admin tool...');
  
  const args = process.argv.slice(2);
  const service = args.find(arg => arg.startsWith('--service='))?.split('=')[1] || 'gateway';
  
  console.log(`🔍 Checking health of service: ${service}`);
  console.log(`📊 Environment: ${config.NODE_ENV}`);
  console.log(`📍 Service URL: http://localhost:${config.PORT}/health`);
  
  try {
    const response = await fetch(`http://localhost:${config.PORT}/health`);
    const data = await response.json();
    
    if (response.ok) {
      console.log('✅ Service is healthy!');
      console.log('Response:', JSON.stringify(data, null, 2));
      process.exit(0);
    } else {
      console.error('❌ Service is unhealthy!');
      console.error('Response:', JSON.stringify(data, null, 2));
      process.exit(1);
    }
  } catch (error) {
    console.error('❌ Failed to connect to service:', error);
    process.exit(1);
  }
}

// Run if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch(console.error);
}
```

**File:** `packages/gateway/src/admin/db-migrate.ts`

```typescript
#!/usr/bin/env node

import { DATABASE_URL, NODE_ENV } from '../config.js';
import logger from '../logger.js';

/**
 * Database Migration Tool
 * 
 * 12-Factor: Admin processes run as one-off tasks (Factor 12)
 * This script runs database migrations before application startup.
 * 
 * Usage: npm run admin:db-migrate
 */
async function main(): Promise<void> {
  logger.info('Starting database migration...', { env: NODE_ENV });
  
  if (!DATABASE_URL) {
    console.error('❌ DATABASE_URL environment variable is required');
    process.exit(1);
  }
  
  // In a real application, you would use a migration tool like:
  // - Prisma: npx prisma migrate deploy
  // - TypeORM: npm run typeorm migration:run
  // - Knex: npx knex migrate:latest
  
  console.log('📦 Running database migrations...');
  
  // Simulate migration for now
  console.log('✅ Database migration completed successfully');
  
  // Additional migration steps:
  // 1. Validate schema
  // 2. Run migrations
  // 3. Seed data if needed
  // 4. Verify migration status
  
  process.exit(0);
}

// Run if this file is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch((error) => {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  });
}
```

#### Step 5: Updated Server with 12-Factor Principles

**File:** `packages/gateway/src/server.ts` (Updated)

```typescript
import Fastify, { FastifyInstance, FastifyServerOptions } from 'fastify';
import { 
  config, 
  PORT, 
  HOST, 
  IS_DEVELOPMENT, 
  IS_PRODUCTION,
  SERVICE_NAME,
  SERVICE_VERSION,
} from './config.js';
import logger, { createChildLogger } from './logger.js';
import { registerHealthRoutes } from './health/health.routes.js';
import { ServerErrorHandler } from './error-handler.js';
import { requestIdMiddleware } from './middleware/request-id.js';
import { setupCors } from './middleware/cors.js';
import { metricsMiddleware, metricsCollector } from './middleware/metrics.js';

/**
 * Server Implementation with 12-Factor Principles
 * 
 * Factor 8: Port Binding - Export the service via port binding
 * Factor 9: Disposability - Fast startup and graceful shutdown
 * Factor 6: Stateless - No local state, share-nothing architecture
 */
export class Server {
  private readonly app: FastifyInstance;
  private readonly logger = createChildLogger({ module: 'Server' });
  private isShuttingDown = false;
  private connections: Set<any> = new Set();
  private readonly startTime = Date.now();

  constructor() {
    // Fastify configuration with production-ready settings
    const options: FastifyServerOptions = {
      logger: logger as any,
      
      // 12-Factor: Disable request logging in production (use our logger)
      disableRequestLogging: true,
      
      // 12-Factor: Trust proxy headers (for load balancers)
      trustProxy: !IS_DEVELOPMENT,
      
      // Body limit
      bodyLimit: 100 * 1024 * 1024,
      
      // 12-Factor: Disposability - Connection timeouts
      connectionTimeout: 60000,
      keepAliveTimeout: 72000,
      pluginTimeout: 10000,
      
      // 12-Factor: Strict separation of build/run
      // Expose server version
      version: SERVICE_VERSION,
    };

    this.app = Fastify(options);
    
    // 12-Factor: Config in environment - Setup middleware
    this.setupMiddleware();
    
    // Setup error handling
    this.setupErrorHandling();
    
    // Setup lifecycle hooks
    this.setupHooks();
    
    // Register routes
    this.registerRoutes();
    
    // 12-Factor: Disposability - Setup shutdown handling
    this.setupShutdownHandling();
    
    // Setup connection tracking
    this.setupConnectionTracking();
  }

  /**
   * 12-Factor: Strict separation of build/run (Factor 5)
   * Middleware is configured at runtime, not build time
   */
  private setupMiddleware(): void {
    // Request ID middleware
    this.app.decorateRequest('requestId', null);
    this.app.addHook('onRequest', requestIdMiddleware);
    
    // Metrics middleware
    this.app.addHook('onRequest', metricsMiddleware);
    
    // CORS setup
    setupCors(this.app);
  }

  /**
   * Setup error handling
   */
  private setupErrorHandling(): void {
    this.app.setErrorHandler((error, request, reply) => {
      this.logger.error({ error, requestId: request.id }, 'Request error');
      return ServerErrorHandler.handle(error, request, reply);
    });

    this.app.setNotFoundHandler((request, reply) => {
      this.logger.warn({ 
        url: request.url, 
        method: request.method,
        requestId: request.id 
      }, 'Route not found');
      
      return reply.code(404).send({
        statusCode: 404,
        error: 'Not Found',
        message: `Route ${request.method} ${request.url} not found`,
        requestId: request.id,
      });
    });
  }

  /**
   * Setup lifecycle hooks
   */
  private setupHooks(): void {
    // Pre-handler hook
    this.app.addHook('preHandler', (request, reply, done) => {
      const startTime = process.hrtime.bigint();
      (request as any).startTime = startTime;
      done();
    });

    // On-response hook
    this.app.addHook('onResponse', (request, reply, done) => {
      const startTime = (request as any).startTime as bigint;
      if (startTime) {
        const duration = Number(process.hrtime.bigint() - startTime) / 1_000_000;
        request.log.info({
          statusCode: reply.statusCode,
          duration: `${duration}ms`,
          method: request.method,
          url: request.url,
          duration_ms: duration,
        }, 'Request completed');
      }
      done();
    });

    // On-close hook
    this.app.addHook('onClose', (instance, done) => {
      this.logger.info('Server closing - cleaning up connections');
      this.closeConnections();
      done();
    });
  }

  /**
   * Register routes
   */
  private registerRoutes(): void {
    this.logger.info('Registering routes...');
    
    // Health check routes
    registerHealthRoutes(this.app);
    
    // Metrics endpoint (exposes metrics for monitoring)
    this.app.get('/metrics', async (request, reply) => {
      const metrics = metricsCollector.getMetrics();
      return reply.send({
        service: SERVICE_NAME,
        version: SERVICE_VERSION,
        ...metrics,
        uptime: metrics.uptime,
      });
    });
    
    // 12-Factor: Processes are stateless (Factor 6)
    // No session storage in memory
    // No local file system writes
    // No shared memory between processes
    
    this.logger.info('Routes registered');
  }

  /**
   * 12-Factor: Disposability - Connection tracking for graceful shutdown
   */
  private setupConnectionTracking(): void {
    this.app.addHook('onRequest', (request, reply, done) => {
      const connection = (request as any).raw.socket;
      this.connections.add(connection);
      
      connection.once('close', () => {
        this.connections.delete(connection);
      });
      
      done();
    });
  }

  /**
   * 12-Factor: Disposability - Graceful shutdown handling
   */
  private setupShutdownHandling(): void {
    const signals: NodeJS.Signals[] = ['SIGINT', 'SIGTERM', 'SIGQUIT'];
    
    for (const signal of signals) {
      process.on(signal, async () => {
        if (this.isShuttingDown) {
          this.logger.warn('Forceful shutdown initiated');
          process.exit(1);
        }
        
        this.logger.info(`Received ${signal}, starting graceful shutdown...`);
        this.isShuttingDown = true;
        
        try {
          await this.shutdown();
        } catch (error) {
          this.logger.error({ error }, 'Error during shutdown');
          process.exit(1);
        }
      });
    }
  }

  /**
   * 12-Factor: Disposability - Graceful shutdown implementation
   */
  private async shutdown(): Promise<void> {
    const shutdownTimeout = 30000;
    
    this.logger.info('Beginning graceful shutdown...');
    
    // 1. Close the server (stop accepting new connections)
    await this.app.close();
    this.logger.info('Server stopped accepting new connections');
    
    // 2. Wait for existing connections to finish
    const connectionCount = this.connections.size;
    this.logger.info(`Waiting for ${connectionCount} connections to finish...`);
    
    if (connectionCount > 0) {
      await Promise.race([
        this.waitForConnections(),
        new Promise(resolve => setTimeout(resolve, shutdownTimeout)),
      ]);
    }
    
    // 3. Force close remaining connections
    this.closeConnections();
    
    this.logger.info('Graceful shutdown complete');
  }

  /**
   * Wait for connections to close naturally
   */
  private async waitForConnections(): Promise<void> {
    return new Promise((resolve) => {
      if (this.connections.size === 0) {
        resolve();
        return;
      }
      
      const interval = setInterval(() => {
        if (this.connections.size === 0) {
          clearInterval(interval);
          resolve();
        }
      }, 100);
    });
  }

  /**
   * Force close remaining connections
   */
  private closeConnections(): void {
    for (const connection of this.connections) {
      try {
        connection.destroy();
      } catch (error) {
        this.logger.warn({ error }, 'Error destroying connection');
      }
    }
    this.connections.clear();
  }

  /**
   * 12-Factor: Port Binding (Factor 8)
   * The service binds to a port and listens for requests
   */
  async start(): Promise<void> {
    try {
      await this.app.listen({
        port: PORT,
        host: HOST,
      });
      
      this.logger.info(`🚀 Server started on ${HOST}:${PORT}`);
      this.logger.info(`📊 Health check: http://${HOST}:${PORT}/health`);
      this.logger.info(`📈 Metrics: http://${HOST}:${PORT}/metrics`);
      
      if (IS_DEVELOPMENT) {
        this.logger.info(`🔍 Status: http://${HOST}:${PORT}/status`);
      }
      
      this.logger.info(`✨ Service ${SERVICE_NAME} v${SERVICE_VERSION}`);
      this.logger.info(`📝 Log level: ${config.LOG_LEVEL}`);
      this.logger.info(`🌍 Environment: ${config.NODE_ENV}`);
      this.logger.info(`🔄 Process ID: ${process.pid}`);
      
      // 12-Factor: Processes are stateless (Factor 6)
      // Log that we're stateless
      this.logger.info('📦 Stateless process running');
    } catch (error) {
      this.logger.error({ error }, 'Failed to start server');
      throw error;
    }
  }

  /**
   * Get the Fastify instance (for testing)
   */
  getApp(): FastifyInstance {
    return this.app;
  }
}
```

#### Step 6: Dockerfile (12-Factor: Build/Release/Run Separation)

**File:** `packages/gateway/Dockerfile`

```dockerfile
# 12-Factor: Strict separation of build, release, run (Factor 5)
# This Dockerfile creates a production image with three distinct stages

# STAGE 1: Build Stage
# This stage installs dependencies and builds the application
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production=false

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Prune dev dependencies
RUN npm prune --production

# STAGE 2: Release Stage
# This stage creates the final release image with only what's needed
FROM node:20-alpine AS release

# 12-Factor: Disposability - Small, fast-starting containers
WORKDIR /app

# Copy built artifacts from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/scripts ./scripts

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# 12-Factor: Port binding (Factor 8)
EXPOSE 3000

# 12-Factor: Health check (Factor 9 - Disposability)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node dist/admin/health-check.js --service=gateway || exit 1

# Run the application
CMD ["node", "dist/index.js"]

# STAGE 3: Development Stage (for local development)
# This stage can be used for development with hot reload
FROM builder AS development

# Install development dependencies
RUN npm install -g nodemon tsx

# Expose port for development
EXPOSE 3000

# Run in development mode
CMD ["npm", "run", "dev"]
```

#### Step 7: Docker Compose for Local Development

**File:** `packages/gateway/docker-compose.yml`

```yaml
# Docker Compose configuration for development and testing
# 12-Factor: Backing services (Factor 4) - External services as attached resources

version: '3.8'

services:
  # Gateway Service
  gateway:
    build:
      context: .
      target: development  # Use development stage for hot reload
    ports:
      - "3000:3000"
      - "9090:9090"  # Metrics port
    environment:
      - NODE_ENV=development
      - PORT=3000
      - LOG_LEVEL=debug
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/orchestrator
      - REDIS_URL=redis://redis:6379
      - AUTH_SERVICE_URL=http://auth-service:3001
      - USER_SERVICE_URL=http://user-service:3002
      - JWT_SECRET=dev-secret-key-change-in-production
      - CORS_ORIGINS=http://localhost:3000,http://localhost:5173
      - METRICS_ENABLED=true
    volumes:
      - .:/app
      - /app/node_modules  # Keep container node_modules
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - orchestrator-network

  # PostgreSQL - Backing Service
  postgres:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=orchestrator
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - orchestrator-network

  # Redis - Backing Service
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - orchestrator-network

  # Admin Tools (12-Factor: Admin Processes - Factor 12)
  admin:
    build:
      context: .
      target: release
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/orchestrator
      - REDIS_URL=redis://redis:6379
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - orchestrator-network
    command: ["node", "dist/admin/db-migrate.js"]
    profiles:
      - admin

networks:
  orchestrator-network:
    driver: bridge

volumes:
  postgres_data:
```

#### Step 8: Package Scripts Update

**File:** `packages/gateway/package.json` (Updated scripts section)

```json
{
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "vitest",
    "type-check": "tsc --noEmit",
    "lint": "eslint src/**/*.ts",
    "docker:build": "docker build -t orchestrator-gateway .",
    "docker:run": "docker-compose up",
    "docker:down": "docker-compose down",
    "docker:prod": "docker-compose -f docker-compose.yml -f docker-compose.prod.yml up",
    "admin:health": "node dist/admin/health-check.js",
    "admin:db-migrate": "node dist/admin/db-migrate.js",
    "admin:db-seed": "node dist/admin/db-seed.js"
  }
}
```

### 4. The Verification

Let's verify our 12-Factor implementation works.

#### Step 1: Install Dependencies

```bash
cd packages/gateway
npm install
```

#### Step 2: Test Admin Tools

**Health Check Admin Tool:**
```bash
npm run admin:health
```

Expected output:
```
🔍 Checking health of service: gateway
📊 Environment: development
📍 Service URL: http://localhost:3000/health
❌ Service is unhealthy!
Response: ...
```

(It will fail because the service isn't running yet - that's expected!)

#### Step 3: Run with Docker Compose

```bash
# Start all services
npm run docker:run

# In another terminal, check health
npm run admin:health
```

Expected output when service is running:
```
🔍 Checking health of service: gateway
📊 Environment: development
📍 Service URL: http://localhost:3000/health
✅ Service is healthy!
Response: {
  "status": "ok",
  "service": "gateway",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:50.123Z"
}
```

#### Step 4: Test Metrics Endpoint

```bash
# Make some requests first
curl http://localhost:3000/health
curl http://localhost:3000/health/ready
curl http://localhost:3000/health/live

# Check metrics
curl http://localhost:3000/metrics
```

Expected output:
```json
{
  "service": "gateway",
  "version": "1.0.0",
  "requestCount": 3,
  "errorCount": 0,
  "errorRate": 0,
  "averageDuration": 12,
  "statusCodes": {
    "200": 3
  },
  "uptime": 45,
  "timestamp": "2024-01-15T10:31:30.123Z"
}
```

#### Step 5: Test Graceful Shutdown with Docker

```bash
# In another terminal, stop the container gracefully
docker-compose stop -t 30 gateway

# Watch the logs for graceful shutdown messages
```

Expected logs:
```
[INFO] Received SIGTERM, starting graceful shutdown...
[INFO] Beginning graceful shutdown...
[INFO] Server stopped accepting new connections
[INFO] Waiting for 0 connections to finish...
[INFO] Graceful shutdown complete
```

#### Step 6: Run Database Migration

```bash
# Run migration as an admin task
docker-compose run --rm admin node dist/admin/db-migrate.js
```

Expected output:
```
📦 Running database migrations...
✅ Database migration completed successfully
```

### 5. Deep Dive: 12-Factor Principles in Practice

#### Factor 3: Config in Environment

**Why it matters:**
- Same codebase can run in different environments
- No configuration files in the repository
- Easy to rotate secrets without redeploying

**Best Practices:**
```typescript
// ✅ DO: Use environment variables
const databaseUrl = process.env.DATABASE_URL;

// ❌ DON'T: Hardcode configuration
const databaseUrl = 'postgresql://user:pass@localhost/db';
```

#### Factor 4: Backing Services

**Why it matters:**
- Treat databases, caches, and external services as attached resources
- Can swap out services without changing code
- Enables cloud-native design

**Best Practices:**
```typescript
// ✅ DO: Treat services as resources
const db = await createConnection(process.env.DATABASE_URL);

// ❌ DON'T: Hardcode service locations
const db = await createConnection('localhost:5432');
```

#### Factor 6: Stateless Processes

**Why it matters:**
- Enables horizontal scaling
- Simplifies deployment and rollback
- Improves fault tolerance

**Best Practices:**
```typescript
// ✅ DO: Store state in external services
const session = await redis.get(sessionId);

// ❌ DON'T: Store state in memory
const sessions = new Map();
sessions.set(sessionId, sessionData);
```

#### Factor 9: Disposability

**Why it matters:**
- Fast startup enables scaling
- Graceful shutdown prevents data loss
- Quick deployment and rollback

**Best Practices:**
```typescript
// ✅ DO: Handle signals gracefully
process.on('SIGTERM', async () => {
  await server.close();
  await db.disconnect();
  process.exit(0);
});

// ❌ DON'T: Ignore signals
// Just let the process die
```

#### Factor 11: Logs as Event Streams

**Why it matters:**
- Centralized log management
- Easy to search and analyze logs
- Correlate logs across services

**Best Practices:**
```typescript
// ✅ DO: Log structured data
logger.info({
  event: 'user_created',
  userId: '123',
  email: 'user@example.com'
});

// ❌ DON'T: Log plain text
console.log(`User 123 created`);
```

### 6. Summary

**What We Built:**
- ✅ Externalized configuration with environment variables
- ✅ Backing services as attached resources
- ✅ Strict separation of build, release, run
- ✅ Stateless processes
- ✅ Port binding
- ✅ Disposability with graceful shutdown
- ✅ Logs as event streams
- ✅ Admin processes as one-off tasks

**Key Concepts Learned:**
- The 12-Factor methodology and why it matters
- How to structure configuration for different environments
- Why services should be stateless
- How to handle graceful shutdown
- The importance of structured logging

**What's Next:**
In Phase 2, we'll move to architectural discipline. We'll transform our gateway into a modular monolith using Hexagonal Architecture, making it easier to test, maintain, and eventually split into microservices.

**Verification Checklist:**
- [ ] Service starts with environment-based configuration
- [ ] Metrics endpoint returns request statistics
- [ ] Admin tools work as one-off tasks
- [ ] Docker build completes successfully
- [ ] Docker Compose starts all services
- [ ] Graceful shutdown works in Docker
- [ ] Database migration runs successfully
- [ ] Logs are structured and redact sensitive data

---
