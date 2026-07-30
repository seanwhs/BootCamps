# Phase 1, Part 1: The JavaScript Runtime Boundary

## Understanding How Your Code Actually Runs

Welcome to the first technical part of our series! Before we build anything, we need to understand the environment our code runs in. Think of this like learning how your car's engine works before you start modifying it - you don't need to be a mechanic, but understanding the basics helps you drive better.

### 1. The Target

**What we're building:** A production-ready HTTP service that demonstrates proper runtime understanding, including:
- Graceful startup and shutdown
- Health check endpoints
- Signal handling (SIGTERM, SIGINT)
- Proper error handling
- Environment-based configuration

**File Structure:**
```
packages/gateway/
├── src/
│   ├── index.ts
│   ├── server.ts
│   ├── config.ts
│   ├── logger.ts
│   └── health/
│       ├── health.controller.ts
│       └── health.routes.ts
├── package.json
├── tsconfig.json
├── .env.example
└── docker-compose.yml
```

### 2. The Concept: The JavaScript Runtime

#### The Three-Layer Cake

JavaScript runtime is like a three-layer cake:

```
┌─────────────────────────────────────────────────────┐
│              YOUR JAVASCRIPT CODE                   │  ← Layer 3: Your Code
│  console.log('Hello'), async functions, callbacks   │
├─────────────────────────────────────────────────────┤
│              V8 ENGINE (Google)                    │  ← Layer 2: JavaScript Engine
│  • Parses and compiles JS to machine code          │
│  • Manages memory (Garbage Collection)             │
│  • Handles function calls, objects, prototypes    │
├─────────────────────────────────────────────────────┤
│              LIBUV (C Library)                     │  ← Layer 1: Event Loop & I/O
│  • Event Loop (the heart of async)                │
│  • Thread pool for file system, DNS, etc.         │
│  • Handles timers, signals, child processes       │
└─────────────────────────────────────────────────────┘
```

**The Core Problem:** JavaScript is single-threaded. That means it can only do one thing at a time. But your server needs to handle thousands of requests simultaneously. How?

**The Solution:** The event loop. Think of it like a super-efficient restaurant waiter:
- A waiter takes an order (request arrives)
- Goes to the kitchen (starts async operation)
- Doesn't wait there (continues taking other orders)
- When the food is ready (operation completes), the waiter delivers it (callback executes)

**Why This Matters for Architecture:**
1. **CPU-bound work** (like image processing) blocks everything because it runs on the main thread
2. **I/O-bound work** (like database queries) is perfect because it uses Libuv's thread pool
3. **Service boundaries** should separate CPU-heavy tasks into their own services

### 3. The Implementation

Let's build our service step by step.

#### Step 1: Project Setup and Configuration

First, let's set up our project with proper TypeScript configuration and dependencies.

**File:** `packages/gateway/package.json`

```json
{
  "name": "@orchestrator/gateway",
  "version": "1.0.0",
  "description": "API Gateway for Orchestrator System - Demonstrating JavaScript Runtime Fundamentals",
  "main": "dist/index.js",
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "vitest",
    "type-check": "tsc --noEmit",
    "lint": "eslint src/**/*.ts"
  },
  "dependencies": {
    "fastify": "^4.25.0",
    "dotenv": "^16.3.1",
    "pino": "^8.15.0",
    "pino-pretty": "^10.2.0"
  },
  "devDependencies": {
    "@types/node": "^20.10.0",
    "tsx": "^4.6.0",
    "typescript": "^5.3.0",
    "vitest": "^1.0.0",
    "eslint": "^8.55.0",
    "@typescript-eslint/eslint-plugin": "^6.13.0",
    "@typescript-eslint/parser": "^6.13.0"
  }
}
```

**File:** `packages/gateway/tsconfig.json`

```json
{
  "compilerOptions": {
    // Language and Environment
    "target": "ES2022",
    "lib": ["ES2022"],
    "module": "ES2022",
    "moduleResolution": "node",
    "types": ["node", "vitest/globals"],
    
    // Output
    "outDir": "./dist",
    "rootDir": "./src",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    
    // JavaScript Support
    "allowJs": false,
    "checkJs": false,
    
    // Interop Constraints
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    
    // Type Checking
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    
    // Completeness
    "skipLibCheck": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "**/*.test.ts"]
}
```

**File:** `packages/gateway/.env.example`

```env
# Server Configuration
NODE_ENV=development
PORT=3000
HOST=0.0.0.0

# Logging
LOG_LEVEL=info

# Service Configuration
SERVICE_NAME=gateway
SERVICE_VERSION=1.0.0
```

#### Step 2: Configuration Management

**File:** `packages/gateway/src/config.ts`

```typescript
import dotenv from 'dotenv';
import { z } from 'zod'; // We'll add this for validation

// Load environment variables from .env file
dotenv.config();

/**
 * Configuration Schema using Zod for runtime validation
 * This ensures we catch configuration errors at startup, not runtime
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
});

// Parse and validate configuration
const parseResult = configSchema.safeParse(process.env);

if (!parseResult.success) {
  // If configuration is invalid, log errors and exit
  console.error('❌ Invalid configuration:', parseResult.error.errors);
  process.exit(1);
}

// Export typed configuration
export const config = parseResult.data;

// Export individual constants for convenience
export const {
  NODE_ENV,
  PORT,
  HOST,
  LOG_LEVEL,
  SERVICE_NAME,
  SERVICE_VERSION,
} = config;

// Additional derived configuration
export const IS_DEVELOPMENT = NODE_ENV === 'development';
export const IS_TEST = NODE_ENV === 'test';
export const IS_PRODUCTION = NODE_ENV === 'production';
```

**Update dependencies:** Add zod to package.json

```json
{
  "dependencies": {
    "fastify": "^4.25.0",
    "dotenv": "^16.3.1",
    "pino": "^8.15.0",
    "pino-pretty": "^10.2.0",
    "zod": "^3.22.4"  // ← Add this
  }
}
```

#### Step 3: Logging System

**File:** `packages/gateway/src/logger.ts`

```typescript
import pino from 'pino';
import { NODE_ENV, LOG_LEVEL, SERVICE_NAME, SERVICE_VERSION, IS_PRODUCTION } from './config.js';

/**
 * Configure the logger with environment-appropriate settings
 * 
 * In development: Pretty-printed, human-readable logs
 * In production: JSON format for log aggregation systems
 */
const logger = pino({
  // Set minimum log level from config
  level: LOG_LEVEL,
  
  // Base fields included in every log entry
  base: {
    service: SERVICE_NAME,
    version: SERVICE_VERSION,
    env: NODE_ENV,
  },
  
  // Transport configuration - how logs are output
  transport: IS_PRODUCTION 
    ? undefined // In production, use default JSON output
    : {
        target: 'pino-pretty',
        options: {
          colorize: true,
          translateTime: 'yyyy-mm-dd HH:MM:ss.l',
          ignore: 'pid,hostname',
          levelFirst: true,
          messageFormat: '{msg}',
        },
      },
  
  // Timestamp format
  timestamp: pino.stdTimeFunctions.isoTime,
  
  // Error serialization
  serializers: {
    err: pino.stdSerializers.err,
    error: pino.stdSerializers.err,
  },
});

// Export a type-safe logger
export type Logger = typeof logger;

// Create child loggers with context
export const createChildLogger = (bindings: Record<string, unknown>) => {
  return logger.child(bindings);
};

export default logger;
```

#### Step 4: Health Check Module

**File:** `packages/gateway/src/health/health.controller.ts`

```typescript
import { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import { createChildLogger } from '../logger.js';
import { SERVICE_NAME, SERVICE_VERSION, IS_DEVELOPMENT } from '../config.js';
import os from 'os';

/**
 * Health Check Controller
 * 
 * Provides endpoints for monitoring service health and status
 * This is critical for:
 * 1. Load balancer health checks
 * 2. Service discovery
 * 3. Monitoring and alerting
 * 4. Kubernetes liveness/readiness probes
 */
export class HealthController {
  private startTime = Date.now();
  private readonly logger = createChildLogger({ module: 'HealthController' });

  /**
   * Register health check routes with Fastify
   */
  registerRoutes(server: FastifyInstance): void {
    server.get('/health', this.getHealth.bind(this));
    server.get('/health/ready', this.getReadiness.bind(this));
    server.get('/health/live', this.getLiveness.bind(this));
    
    // Only expose detailed status in development
    if (IS_DEVELOPMENT) {
      server.get('/status', this.getDetailedStatus.bind(this));
    }
  }

  /**
   * Basic health check - returns overall service health
   * Used by load balancers and monitoring systems
   */
  private async getHealth(
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    this.logger.debug('Health check requested');
    
    const health = {
      status: 'ok' as const,
      service: SERVICE_NAME,
      version: SERVICE_VERSION,
      timestamp: new Date().toISOString(),
    };

    await reply.code(200).send(health);
  }

  /**
   * Readiness check - indicates if service is ready to accept traffic
   * Used by Kubernetes readiness probes
   * 
   * A service is ready when:
   * - Dependencies (database, cache, etc.) are available
   * - Service has warmed up (no cold start)
   */
  private async getReadiness(
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    this.logger.debug('Readiness check requested');
    
    // Check if service is ready to accept traffic
    // For now, we're always ready
    // In later phases, we'll check:
    // - Database connection
    // - Cache connection
    // - Other service dependencies
    
    const readiness = {
      status: 'ready' as const,
      service: SERVICE_NAME,
      version: SERVICE_VERSION,
      uptime: this.getUptime(),
    };

    await reply.code(200).send(readiness);
  }

  /**
   * Liveness check - indicates if service is alive
   * Used by Kubernetes liveness probes
   * 
   * A service is live if:
   * - The process is running
   * - It can respond to requests
   */
  private async getLiveness(
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    // Always respond - if we can't, Kubernetes will restart the pod
    await reply.code(200).send({
      status: 'alive',
      timestamp: new Date().toISOString(),
    });
  }

  /**
   * Detailed status - provides comprehensive service information
   * Only available in development mode
   */
  private async getDetailedStatus(
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    this.logger.info('Detailed status requested');
    
    const status = {
      service: SERVICE_NAME,
      version: SERVICE_VERSION,
      environment: process.env.NODE_ENV || 'development',
      uptime: this.getUptime(),
      process: {
        pid: process.pid,
        memory: process.memoryUsage(),
        cpu: process.cpuUsage(),
        versions: {
          node: process.version,
          v8: process.versions.v8,
          libuv: process.versions.uv,
        },
        platform: {
          os: os.platform(),
          arch: os.arch(),
          cpus: os.cpus().length,
          totalMemory: os.totalmem(),
          freeMemory: os.freemem(),
        },
      },
      runtime: {
        eventLoop: {
          lag: this.getEventLoopLag(),
        },
      },
    };

    await reply.code(200).send(status);
  }

  /**
   * Calculate service uptime
   */
  private getUptime(): string {
    const uptimeMs = Date.now() - this.startTime;
    const uptimeSeconds = Math.floor(uptimeMs / 1000);
    const days = Math.floor(uptimeSeconds / 86400);
    const hours = Math.floor((uptimeSeconds % 86400) / 3600);
    const minutes = Math.floor((uptimeSeconds % 3600) / 60);
    const seconds = uptimeSeconds % 60;

    if (days > 0) {
      return `${days}d ${hours}h ${minutes}m ${seconds}s`;
    } else if (hours > 0) {
      return `${hours}h ${minutes}m ${seconds}s`;
    } else if (minutes > 0) {
      return `${minutes}m ${seconds}s`;
    } else {
      return `${seconds}s`;
    }
  }

  /**
   * Simple event loop lag measurement
   * Helps detect if the event loop is blocked
   */
  private getEventLoopLag(): number {
    const start = process.hrtime.bigint();
    // Force a microtask to measure event loop delay
    const lag = process.hrtime.bigint() - start;
    return Number(lag) / 1_000_000; // Convert nanoseconds to milliseconds
  }
}
```

**File:** `packages/gateway/src/health/health.routes.ts`

```typescript
import { FastifyInstance } from 'fastify';
import { HealthController } from './health.controller.js';

/**
 * Register health check routes
 * 
 * This function is called by the server to set up health endpoints
 * It creates a new controller instance and registers its routes
 */
export async function registerHealthRoutes(
  server: FastifyInstance
): Promise<void> {
  const healthController = new HealthController();
  healthController.registerRoutes(server);
}
```

#### Step 5: Main Server

**File:** `packages/gateway/src/server.ts`

```typescript
import Fastify, { FastifyInstance, FastifyServerOptions } from 'fastify';
import { config, PORT, HOST, IS_DEVELOPMENT } from './config.js';
import logger, { createChildLogger } from './logger.js';
import { registerHealthRoutes } from './health/health.routes.js';
import { ServerErrorHandler } from './error-handler.js';

/**
 * Server Configuration
 * 
 * This class manages the Fastify server lifecycle:
 * - Setup: Configure middleware, plugins, routes
 * - Start: Begin listening on configured port
 * - Shutdown: Gracefully close connections
 */
export class Server {
  private readonly app: FastifyInstance;
  private readonly logger = createChildLogger({ module: 'Server' });
  private isShuttingDown = false;
  private connections: Set<any> = new Set();

  constructor() {
    // Configure Fastify with production-ready options
    const options: FastifyServerOptions = {
      // Logger configuration - use our pino logger
      logger: logger as any,
      
      // Disable request logging in development (we handle it separately)
      disableRequestLogging: IS_DEVELOPMENT,
      
      // Trust proxy headers (behind load balancer)
      trustProxy: !IS_DEVELOPMENT,
      
      // Body limit (100MB by default)
      bodyLimit: 100 * 1024 * 1024, // 100MB
      
      // Connection timeout
      connectionTimeout: 60000, // 60 seconds
      
      // Keep-alive timeout
      keepAliveTimeout: 72000, // 72 seconds
      
      // Plugin timeout
      pluginTimeout: 10000, // 10 seconds
    };

    this.app = Fastify(options);

    // Setup error handling
    this.setupErrorHandling();

    // Setup hooks
    this.setupHooks();

    // Register routes
    this.registerRoutes();

    // Setup shutdown handling
    this.setupShutdownHandling();

    // Add connection tracking
    this.setupConnectionTracking();
  }

  /**
   * Setup global error handling
   */
  private setupErrorHandling(): void {
    // Global error handler - catches any unhandled errors in request handlers
    this.app.setErrorHandler((error, request, reply) => {
      this.logger.error({ error, requestId: request.id }, 'Request error handled');
      
      // Use our error handler to format the response
      return ServerErrorHandler.handle(error, request, reply);
    });

    // Not found handler
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
    // Pre-handler hook - runs before route handler
    this.app.addHook('preHandler', (request, reply, done) => {
      // Add request ID to logger context
      (request.log as any).child({ requestId: request.id });
      
      // Add timing header
      const startTime = process.hrtime.bigint();
      (request as any).startTime = startTime;
      
      done();
    });

    // On-response hook - runs after response is sent
    this.app.addHook('onResponse', (request, reply, done) => {
      // Calculate request duration
      const startTime = (request as any).startTime as bigint;
      if (startTime) {
        const duration = Number(process.hrtime.bigint() - startTime) / 1_000_000;
        (request.log as any).info({
          statusCode: reply.statusCode,
          duration: `${duration}ms`,
          method: request.method,
          url: request.url,
        }, 'Request completed');
      }
      
      done();
    });

    // On-close hook - cleanup
    this.app.addHook('onClose', (instance, done) => {
      this.logger.info('Server closing - cleaning up connections');
      this.closeConnections();
      done();
    });
  }

  /**
   * Register all routes
   */
  private registerRoutes(): void {
    this.logger.info('Registering routes...');
    
    // Health check routes
    registerHealthRoutes(this.app);
    
    // TODO: More routes will be added in future phases
    
    this.logger.info('Routes registered');
  }

  /**
   * Setup connection tracking for graceful shutdown
   */
  private setupConnectionTracking(): void {
    this.app.addHook('onRequest', (request, reply, done) => {
      // Track connection
      const connection = (request as any).raw.socket;
      this.connections.add(connection);
      
      // Remove connection when closed
      connection.once('close', () => {
        this.connections.delete(connection);
      });
      
      done();
    });
  }

  /**
   * Setup signal handling for graceful shutdown
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
   * Graceful shutdown
   * 
   * This performs a clean shutdown:
   * 1. Stops accepting new requests
   * 2. Waits for existing requests to complete
   * 3. Closes the server
   * 4. Forces remaining connections to close after timeout
   */
  private async shutdown(): Promise<void> {
    const shutdownTimeout = 30000; // 30 seconds
    
    this.logger.info('Beginning graceful shutdown...');
    
    // 1. Close the server (stop accepting new connections)
    await this.app.close();
    this.logger.info('Server stopped accepting new connections');
    
    // 2. Wait for existing connections to finish
    const connectionCount = this.connections.size;
    this.logger.info(`Waiting for ${connectionCount} connections to finish...`);
    
    if (connectionCount > 0) {
      // Wait for connections to close or timeout
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
      
      // Check every 100ms if connections are gone
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
   * Start the server
   */
  async start(): Promise<void> {
    try {
      // Start listening on configured port
      await this.app.listen({
        port: PORT,
        host: HOST,
      });
      
      this.logger.info(`🚀 Server started on ${HOST}:${PORT}`);
      this.logger.info(`📊 Health check: http://${HOST}:${PORT}/health`);
      
      if (IS_DEVELOPMENT) {
        this.logger.info(`🔍 Status: http://${HOST}:${PORT}/status`);
      }
      
      this.logger.info(`✨ Service ${config.SERVICE_NAME} v${config.SERVICE_VERSION}`);
      this.logger.info(`📝 Log level: ${config.LOG_LEVEL}`);
      this.logger.info(`🌍 Environment: ${config.NODE_ENV}`);
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

#### Step 6: Error Handler

**File:** `packages/gateway/src/error-handler.ts`

```typescript
import { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { IS_DEVELOPMENT } from './config.js';
import logger from './logger.js';

/**
 * Custom error classes for specific scenarios
 */
export class AppError extends Error {
  constructor(
    public statusCode: number,
    message: string,
    public code?: string,
    public details?: unknown
  ) {
    super(message);
    this.name = this.constructor.name;
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, details?: unknown) {
    super(400, message, 'VALIDATION_ERROR', details);
  }
}

export class NotFoundError extends AppError {
  constructor(message: string) {
    super(404, message, 'NOT_FOUND');
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized') {
    super(401, message, 'UNAUTHORIZED');
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string = 'Forbidden') {
    super(403, message, 'FORBIDDEN');
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(409, message, 'CONFLICT');
  }
}

export class InternalServerError extends AppError {
  constructor(message: string = 'Internal Server Error') {
    super(500, message, 'INTERNAL_SERVER_ERROR');
  }
}

/**
 * Server Error Handler
 * 
 * Handles all errors thrown in the application:
 * - Maps exceptions to HTTP responses
 * - Logs errors appropriately
 * - Sanitizes error messages in production
 */
export class ServerErrorHandler {
  /**
   * Handle an error and send appropriate response
   */
  static handle(
    error: unknown,
    request: FastifyRequest,
    reply: FastifyReply
  ): void {
    const requestId = request.id || 'unknown';
    
    // Log error with context
    if (error instanceof Error) {
      logger.error({
        error: {
          name: error.name,
          message: error.message,
          stack: error.stack,
        },
        requestId,
        url: request.url,
        method: request.method,
      }, 'Error handling request');
    } else {
      logger.error({
        error,
        requestId,
        url: request.url,
        method: request.method,
      }, 'Unknown error handling request');
    }

    // Handle specific error types
    if (error instanceof AppError) {
      return this.handleAppError(error, reply);
    }

    if (error instanceof ZodError) {
      return this.handleValidationError(error, reply);
    }

    // Handle unknown errors
    return this.handleUnknownError(error, reply);
  }

  /**
   * Handle application errors
   */
  private static handleAppError(error: AppError, reply: FastifyReply): void {
    const response = {
      statusCode: error.statusCode,
      error: error.name,
      message: error.message,
      code: error.code,
      ...(IS_DEVELOPMENT && error.details && { details: error.details }),
      ...(IS_DEVELOPMENT && { stack: error.stack }),
    };

    reply.code(error.statusCode).send(response);
  }

  /**
   * Handle Zod validation errors
   */
  private static handleValidationError(error: ZodError, reply: FastifyReply): void {
    const formattedErrors = error.errors.map((err) => ({
      path: err.path.join('.'),
      message: err.message,
      code: err.code,
    }));

    const response = {
      statusCode: 400,
      error: 'Validation Error',
      message: 'Invalid request data',
      errors: formattedErrors,
      ...(IS_DEVELOPMENT && { stack: error.stack }),
    };

    reply.code(400).send(response);
  }

  /**
   * Handle unknown errors
   */
  private static handleUnknownError(error: unknown, reply: FastifyReply): void {
    const statusCode = 500;
    const message = IS_DEVELOPMENT 
      ? error instanceof Error ? error.message : 'Unknown error'
      : 'Internal Server Error';

    const response = {
      statusCode,
      error: 'Internal Server Error',
      message,
      ...(IS_DEVELOPMENT && {
        stack: error instanceof Error ? error.stack : undefined,
        type: typeof error,
      }),
    };

    reply.code(statusCode).send(response);
  }
}
```

#### Step 7: Entry Point

**File:** `packages/gateway/src/index.ts`

```typescript
#!/usr/bin/env node

import { Server } from './server.js';
import logger from './logger.js';
import { config, NODE_ENV, SERVICE_NAME, SERVICE_VERSION } from './config.js';

/**
 * Application Entry Point
 * 
 * This is where everything starts:
 * 1. Log startup information
 * 2. Create and start the server
 * 3. Handle uncaught exceptions
 */

// Log startup information
logger.info(`🔧 Starting ${SERVICE_NAME} v${SERVICE_VERSION}`);
logger.info(`📁 Environment: ${NODE_ENV}`);
logger.info(`📝 Log level: ${config.LOG_LEVEL}`);

// Set up unhandled rejection handler
process.on('unhandledRejection', (error: unknown) => {
  logger.error({ error }, 'Unhandled Promise rejection');
  // In production, you might want to exit and let the process manager restart
  // For now, we'll log and continue
});

// Set up uncaught exception handler
process.on('uncaughtException', (error: Error) => {
  logger.error({ error }, 'Uncaught exception');
  // For uncaught exceptions, we should exit cleanly
  // The process manager will restart if needed
  process.exit(1);
});

// Create server instance
const server = new Server();

// Start the server
async function bootstrap(): Promise<void> {
  try {
    await server.start();
  } catch (error) {
    logger.error({ error }, 'Failed to start server');
    process.exit(1);
  }
}

// Boot the application
bootstrap();

// Export for testing
export { server };
```

### 4. The Verification

Let's test our service works correctly.

#### Step 1: Install Dependencies

```bash
cd packages/gateway
npm install
```

#### Step 2: Set Up Environment

```bash
# Copy environment example
cp .env.example .env

# Edit if needed (defaults should work)
# PORT=3000
# LOG_LEVEL=info
```

#### Step 3: Run the Service

```bash
# Development mode with hot reload
npm run dev

# Or build and run
npm run build
npm start
```

You should see output like:
```
[INFO] 2024-01-15 10:30:45.123 🔧 Starting gateway v1.0.0
[INFO] 2024-01-15 10:30:45.124 📁 Environment: development
[INFO] 2024-01-15 10:30:45.124 📝 Log level: info
[INFO] 2024-01-15 10:30:45.456 🚀 Server started on 0.0.0.0:3000
[INFO] 2024-01-15 10:30:45.456 📊 Health check: http://0.0.0.0:3000/health
[INFO] 2024-01-15 10:30:45.456 🔍 Status: http://0.0.0.0:3000/status
[INFO] 2024-01-15 10:30:45.456 ✨ Service gateway v1.0.0
[INFO] 2024-01-15 10:30:45.456 📝 Log level: info
[INFO] 2024-01-15 10:30:45.456 🌍 Environment: development
```

#### Step 4: Test Health Endpoints

**Basic Health Check:**
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "service": "gateway",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:50.123Z"
}
```

**Readiness Check:**
```bash
curl http://localhost:3000/health/ready
```

Expected response:
```json
{
  "status": "ready",
  "service": "gateway",
  "version": "1.0.0",
  "uptime": "1m 32s"
}
```

**Liveness Check:**
```bash
curl http://localhost:3000/health/live
```

Expected response:
```json
{
  "status": "alive",
  "timestamp": "2024-01-15T10:30:55.456Z"
}
```

**Detailed Status (Development Only):**
```bash
curl http://localhost:3000/status
```

Expected response: (truncated for brevity)
```json
{
  "service": "gateway",
  "version": "1.0.0",
  "environment": "development",
  "uptime": "2m 15s",
  "process": {
    "pid": 12345,
    "memory": {
      "rss": 52707328,
      "heapTotal": 40894464,
      "heapUsed": 35123456,
      "external": 1423488
    },
    // ... more process info
  },
  "runtime": {
    "eventLoop": {
      "lag": 0.023
    }
  }
}
```

#### Step 5: Test Graceful Shutdown

In another terminal, send a SIGTERM signal:

```bash
# Find the process ID
ps aux | grep "node.*gateway"

# Send SIGTERM (replace 12345 with actual PID)
kill -TERM 12345
```

You should see:
```
[INFO] Received SIGTERM, starting graceful shutdown...
[INFO] Beginning graceful shutdown...
[INFO] Server stopped accepting new connections
[INFO] Graceful shutdown complete
```

#### Step 6: Test Error Handling

**Test 404:**
```bash
curl -v http://localhost:3000/not-found
```

Expected: 404 Not Found with JSON error response.

**Test Validation (in future phases when we add routes):**
We'll test validation errors when we add more endpoints in later parts.

### 5. Deep Dive: Understanding the JavaScript Runtime

#### The Event Loop in Detail

```
┌───────────────────────────────────────────────────────┐
│                     EVENT LOOP                        │
├───────────────────────────────────────────────────────┤
│                                                       │
│  ┌─────────┐     ┌──────────┐     ┌──────────┐     │
│  │ TIMERS  │────▶│ PENDING │────▶│ IDLE/    │     │
│  │ (setTimeout) │  CALLBACKS │     │ PREPARE │     │
│  └─────────┘     └──────────┘     └──────────┘     │
│       │                  │              │            │
│       ▼                  ▼              ▼            │
│  ┌─────────┐     ┌──────────┐     ┌──────────┐     │
│  │ POLL    │◀────│ CHECK    │◀────│ CLOSE    │     │
│  │ (I/O)   │     │ (setImmediate)│  CALLBACKS│     │
│  └─────────┘     └──────────┘     └──────────┘     │
│       │                   │              │           │
│       └───────────────────┴──────────────┘          │
│                                                       │
└───────────────────────────────────────────────────────┘
```

**Phases Explained:**

1. **Timers:** Executes callbacks scheduled by `setTimeout` and `setInterval`
2. **Pending Callbacks:** Executes I/O callbacks deferred from the previous cycle
3. **Idle/Prepare:** Internal use only
4. **Poll:** Retrieves new I/O events, executes I/O callbacks
5. **Check:** Executes `setImmediate` callbacks
6. **Close Callbacks:** Executes `close` event callbacks

**Practical Implications:**

```typescript
// CPU-intensive work blocks the event loop
function cpuIntensiveWork() {
  let result = 0;
  for (let i = 0; i < 1e9; i++) {
    result += i;
  }
  return result;
}

// This will block ALL requests while it runs
// Bad for server performance!

// Better: Offload CPU work to child processes or separate services
// We'll cover this in later phases
```

#### Why This Matters for Architecture

1. **Keep the Event Loop Healthy:**
   - Never block with synchronous CPU work
   - Use async for all I/O operations
   - Offload heavy computation

2. **Service Boundaries:**
   - I/O-bound services (API, database) can be Node.js
   - CPU-bound services (image processing) should be separate

3. **Graceful Shutdown:**
   - Always handle SIGTERM/SIGINT
   - Give connections time to finish
   - Clean up resources

### 6. Summary

**What We Built:**
- ✅ Production-ready HTTP service with Fastify
- ✅ Health check endpoints (health, ready, live)
- ✅ Graceful shutdown with signal handling
- ✅ Configuration management with Zod validation
- ✅ Structured logging with Pino
- ✅ Error handling with custom error types
- ✅ Connection tracking for clean shutdown

**Key Concepts Learned:**
- How the event loop works (timers, poll, check phases)
- Why CPU work blocks the event loop
- How Libuv handles I/O operations
- Why graceful shutdown matters
- How to structure a production Node.js service

**What's Next:**
In Part 2, we'll take this service and add architectural boundaries. We'll refactor our code using Hexagonal Architecture patterns to make it easier to:
- Test business logic in isolation
- Swap out dependencies (databases, external services)
- Scale to microservices

**Verification Checklist:**
- [ ] Service starts without errors
- [ ] `/health` returns 200 OK
- [ ] `/health/ready` returns correct response
- [ ] `/health/live` returns correct response
- [ ] `/status` works in development
- [ ] 404 handling works
- [ ] Graceful shutdown completes without errors
- [ ] Logging shows request timing information

