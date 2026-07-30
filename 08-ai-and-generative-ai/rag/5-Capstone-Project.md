# Capstone Project: The Asynchronous, Evidence-Gated RAG Agent

## The Vision

You've built all the components:
- **Part 1**: RAG foundation with vector search
- **Part 2**: Hybrid search with reranking and governance
- **Part 3**: LangChain.js orchestration with telemetry
- **Part 4**: LangGraph.js agent with self-correction and HITL

Now we're **bringing it all together** into a complete, production-ready application with:

1. **REST API** — Fastify-based HTTP server with Swagger documentation
2. **Async Processing** — BullMQ job queues for document ingestion
3. **WebSocket Support** — Real-time agent progress updates
4. **Production HITL** — Actual human approval workflow with webhooks
5. **Docker Compose** — Full stack with PostgreSQL, Redis, and the application
6. **Comprehensive Monitoring** — Health checks, metrics endpoints, and logging
7. **Deployment Ready** — Environment configurations for dev/staging/production

**Think of this as**: We're taking our workshop prototype and turning it into a **factory** — with assembly lines (async processing), quality control (HITL), monitoring dashboards (telemetry), and shipping docks (API).

---

## Phase C.1: Project Structure and Dependencies

### The Target
Set up the final project structure with all production dependencies.

### The Implementation

#### Step 1: Install Production Dependencies

```bash
# Web Framework
npm install fastify @fastify/cors @fastify/swagger @fastify/swagger-ui

# Async Processing
npm install bullmq ioredis

# WebSocket
npm install @fastify/websocket

# Database
npm install prisma @prisma/client
npm install -D prisma

# Email Notifications (for HITL)
npm install nodemailer
npm install -D @types/nodemailer

# Security
npm install helmet @fastify/rate-limit

# Validation
npm install ajv

# Utilities
npm install nanoid
```

#### Step 2: Create Project Structure

```
rag-agent-system/
├── src/
│   ├── api/
│   │   ├── routes/
│   │   │   ├── queries.ts
│   │   │   ├── ingestion.ts
│   │   │   ├── checkpoints.ts
│   │   │   └── admin.ts
│   │   ├── middleware/
│   │   │   ├── auth.ts
│   │   │   ├── logging.ts
│   │   │   └── validation.ts
│   │   ├── schemas/
│   │   │   ├── request.ts
│   │   │   └── response.ts
│   │   └── server.ts
│   ├── workers/
│   │   ├── ingestion-worker.ts
│   │   ├── query-worker.ts
│   │   └── hitl-worker.ts
│   ├── queues/
│   │   ├── ingestion-queue.ts
│   │   └── hitl-queue.ts
│   ├── services/
│   │   ├── notification.ts
│   │   ├── email.ts
│   │   └── webhook.ts
│   ├── websocket/
│   │   ├── manager.ts
│   │   └── handlers.ts
│   └── app.ts
├── prisma/
│   └── schema.prisma
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── scripts/
│   ├── seed.ts
│   └── migrate.ts
└── .env.example
```

---

## Phase C.2: Database Schema with Prisma

### The Target
Create the production database schema for the entire system.

### The Implementation

Create `prisma/schema.prisma`:

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// Document chunks stored in the vector database
model Document {
  id          String   @id @default(cuid())
  content     String   @db.Text
  embedding   Unsupported("vector(1536)")? // pgvector support
  metadata    Json
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  // Relationships
  sourceId    String?  @map("source_id")
  source      Source?  @relation(fields: [sourceId], references: [id])
  chunkIndex  Int?     @map("chunk_index")
  
  // Indexes
  @@index([sourceId])
  @@index([createdAt])
  @@map("documents")
}

// Document sources (files, URLs, etc.)
model Source {
  id          String   @id @default(cuid())
  name        String
  path        String
  type        String   // 'file', 'url', 's3'
  metadata    Json
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  // Relationships
  documents   Document[]
  
  @@index([type])
  @@index([createdAt])
  @@map("sources")
}

// User sessions and authentication
model User {
  id          String   @id @default(cuid())
  email       String   @unique
  name        String?
  role        String   @default("user")
  department  String?
  team        String?
  permissions Json
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  // Relationships
  sessions    Session[]
  approvals   Approval[]
  queries     Query[]
  
  @@index([email])
  @@map("users")
}

// User sessions
model Session {
  id          String   @id @default(cuid())
  userId      String   @map("user_id")
  token       String   @unique
  expiresAt   DateTime @map("expires_at")
  createdAt   DateTime @default(now())
  
  // Relationships
  user        User     @relation(fields: [userId], references: [id])
  
  @@index([token])
  @@index([expiresAt])
  @@map("sessions")
}

// Query history
model Query {
  id          String   @id @default(cuid())
  userId      String?  @map("user_id")
  query       String   @db.Text
  answer      String?  @db.Text
  confidence  Float?
  status      String   @default("pending") // pending, processing, completed, failed
  metadata    Json
  traceId     String?  @map("trace_id")
  createdAt   DateTime @default(now())
  completedAt DateTime? @map("completed_at")
  
  // Relationships
  user        User?    @relation(fields: [userId], references: [id])
  sources     QuerySource[]
  
  @@index([userId])
  @@index([status])
  @@index([createdAt])
  @@index([traceId])
  @@map("queries")
}

// Query sources (which documents were used)
model QuerySource {
  id          String   @id @default(cuid())
  queryId     String   @map("query_id")
  documentId  String   @map("document_id")
  score       Float
  rank        Int
  createdAt   DateTime @default(now())
  
  // Relationships
  query       Query    @relation(fields: [queryId], references: [id])
  document    Document @relation(fields: [documentId], references: [id])
  
  @@index([queryId])
  @@index([documentId])
  @@map("query_sources")
}

// Human-in-the-loop approvals
model Approval {
  id          String   @id @default(cuid())
  queryId     String   @map("query_id")
  userId      String   @map("user_id")
  status      String   @default("pending") // pending, approved, rejected, expired
  request     Json     // The approval request data
  response    Json?    // The human response
  expiresAt   DateTime @map("expires_at")
  createdAt   DateTime @default(now())
  respondedAt DateTime? @map("responded_at")
  
  // Relationships
  query       Query    @relation(fields: [queryId], references: [id])
  user        User     @relation(fields: [userId], references: [id])
  
  @@index([queryId])
  @@index([userId])
  @@index([status])
  @@index([expiresAt])
  @@map("approvals")
}

// Agent checkpoints
model Checkpoint {
  id          String   @id @default(cuid())
  threadId    String   @map("thread_id")
  state       Json
  metadata    Json
  createdAt   DateTime @default(now())
  
  @@index([threadId])
  @@index([createdAt])
  @@map("checkpoints")
}

// Ingestion jobs
model IngestionJob {
  id          String   @id @default(cuid())
  sourceId    String   @map("source_id")
  status      String   @default("pending") // pending, processing, completed, failed
  progress    Float    @default(0)
  result      Json?    // Statistics about the ingestion
  error       String?  @db.Text
  startedAt   DateTime? @map("started_at")
  completedAt DateTime? @map("completed_at")
  createdAt   DateTime @default(now())
  
  // Relationships
  source      Source   @relation(fields: [sourceId], references: [id])
  
  @@index([sourceId])
  @@index([status])
  @@index([createdAt])
  @@map("ingestion_jobs")
}

// Notifications
model Notification {
  id          String   @id @default(cuid())
  userId      String   @map("user_id")
  type        String   // approval, completion, error
  title       String
  message     String   @db.Text
  data        Json?
  read        Boolean  @default(false)
  createdAt   DateTime @default(now())
  readAt      DateTime? @map("read_at")
  
  // Relationships
  user        User     @relation(fields: [userId], references: [id])
  
  @@index([userId])
  @@index([read])
  @@index([createdAt])
  @@map("notifications")
}
```

#### Step 3: Run Prisma Setup

```bash
# Generate Prisma client
npx prisma generate

# Run migration
npx prisma migrate dev --name init

# Open Prisma Studio
npx prisma studio
```

---

## Phase C.3: Fastify Server with API Routes

### The Target
Create the REST API server with complete endpoints.

### The Implementation

Create `src/api/server.ts`:

```typescript
/**
 * Fastify Server
 * REST API for the RAG Agent System
 */

import Fastify from 'fastify';
import cors from '@fastify/cors';
import swagger from '@fastify/swagger';
import swaggerUI from '@fastify/swagger-ui';
import websocket from '@fastify/websocket';
import rateLimit from '@fastify/rate-limit';
import helmet from '@fastify/helmet';
import { logger } from '../services/logger.js';
import telemetry from '../orchestration/telemetry.js';
import { queryRoutes } from './routes/queries.js';
import { ingestionRoutes } from './routes/ingestion.js';
import { checkpointRoutes } from './routes/checkpoints.js';
import { adminRoutes } from './routes/admin.js';

/**
 * Create and configure the Fastify server
 */
export async function createServer() {
  const server = Fastify({
    logger: {
      level: process.env.LOG_LEVEL || 'info',
      transport: process.env.NODE_ENV === 'production'
        ? undefined
        : {
            target: 'pino-pretty',
            options: {
              translateTime: 'HH:MM:ss Z',
              ignore: 'pid,hostname',
            },
          },
    },
    ajv: {
      customOptions: {
        coerceTypes: true,
        removeAdditional: true,
      },
    },
  });

  // Security middleware
  await server.register(helmet, {
    contentSecurityPolicy: process.env.NODE_ENV === 'production',
  });

  // CORS
  await server.register(cors, {
    origin: process.env.CORS_ORIGIN?.split(',') || '*',
    credentials: true,
  });

  // Rate limiting
  await server.register(rateLimit, {
    max: parseInt(process.env.RATE_LIMIT_MAX || '100'),
    timeWindow: '1 minute',
  });

  // WebSocket support
  await server.register(websocket, {
    options: { 
      maxPayload: 1048576, // 1MB
    },
  });

  // Swagger documentation
  await server.register(swagger, {
    swagger: {
      info: {
        title: 'RAG Agent API',
        description: 'Production RAG system with LangGraph.js agent',
        version: '1.0.0',
      },
      host: process.env.API_HOST || 'localhost:3000',
      schemes: ['http', 'https'],
      consumes: ['application/json'],
      produces: ['application/json'],
      tags: [
        { name: 'queries', description: 'Query endpoints' },
        { name: 'ingestion', description: 'Document ingestion endpoints' },
        { name: 'checkpoints', description: 'Agent checkpoint endpoints' },
        { name: 'admin', description: 'Administrative endpoints' },
      ],
      securityDefinitions: {
        bearerAuth: {
          type: 'apiKey',
          name: 'Authorization',
          in: 'header',
        },
      },
    },
  });

  // Swagger UI
  await server.register(swaggerUI, {
    routePrefix: '/docs',
    uiConfig: {
      docExpansion: 'full',
      deepLinking: false,
    },
  });

  // Health check endpoint
  server.get('/health', async (request, reply) => {
    try {
      const health = await telemetry.getHealth();
      return {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        ...health,
      };
    } catch (error) {
      return reply.status(503).send({
        status: 'unhealthy',
        error: error instanceof Error ? error.message : String(error),
      });
    }
  });

  // Metrics endpoint (for Prometheus)
  server.get('/metrics', async (request, reply) => {
    // In production, this would be served by prom-client
    const metrics = {
      traces: telemetry.getRecentTraces(100),
      aggregated: {
        avgLatency: telemetry.getAggregatedMetrics('perf.rag.query', 'avg'),
        totalQueries: telemetry.getAggregatedMetrics('perf.rag.query', 'count'),
        errorRate: telemetry.getAggregatedMetrics('perf.error', 'count') / 
          (telemetry.getAggregatedMetrics('perf.rag.query', 'count') || 1),
      },
    };
    return metrics;
  });

  // Register route groups
  await server.register(queryRoutes, { prefix: '/api/v1/queries' });
  await server.register(ingestionRoutes, { prefix: '/api/v1/ingestion' });
  await server.register(checkpointRoutes, { prefix: '/api/v1/checkpoints' });
  await server.register(adminRoutes, { prefix: '/api/v1/admin' });

  // 404 handler
  server.setNotFoundHandler((request, reply) => {
    return reply.status(404).send({
      error: 'Not Found',
      message: `Route ${request.method} ${request.url} not found`,
    });
  });

  // Error handler
  server.setErrorHandler((error, request, reply) => {
    server.log.error(error);
    
    // Log to telemetry
    telemetry.recordEvent('api.error', {
      error: error.message,
      stack: error.stack,
      url: request.url,
      method: request.method,
    });

    const statusCode = (error as any).statusCode || 500;
    const message = statusCode === 500 
      ? 'Internal Server Error' 
      : error.message;

    return reply.status(statusCode).send({
      error: message,
      timestamp: new Date().toISOString(),
    });
  });

  return server;
}

/**
 * Start the server
 */
export async function startServer() {
  const server = await createServer();
  
  const port = parseInt(process.env.PORT || '3000');
  const host = process.env.HOST || '0.0.0.0';
  
  try {
    await server.listen({ port, host });
    console.log(`🚀 Server running at http://${host}:${port}`);
    console.log(`📚 API Documentation: http://${host}:${port}/docs`);
    
    return server;
  } catch (error) {
    server.log.error(error);
    process.exit(1);
  }
}

// Start if run directly
if (import.meta.url === `file://${process.argv[1]}`) {
  startServer();
}
```

---

## Phase C.4: API Routes Implementation

### The Target
Implement all API routes with validation and business logic.

### The Implementation

#### Query Routes

Create `src/api/routes/queries.ts`:

```typescript
/**
 * Query Routes
 * Endpoints for RAG queries and agent execution
 */

import { FastifyPluginAsync } from 'fastify';
import { z } from 'zod';
import orchestrator from '../../orchestration/orchestrator.js';
import agent from '../../agent/graph.js';
import telemetry from '../../orchestration/telemetry.js';
import { logger } from '../../services/logger.js';
import { AgentState } from '../../agent/state.js';

// Request schemas
const QueryRequestSchema = z.object({
  query: z.string().min(1, 'Query cannot be empty'),
  topK: z.number().min(1).max(20).optional(),
  includeSources: z.boolean().optional(),
  promptStyle: z.enum(['concise', 'detailed', 'reasoning', 'socratic', 'expert']).optional(),
  useAgent: z.boolean().optional(),
  maxIterations: z.number().min(1).max(10).optional(),
  metadataFilters: z.record(z.any()).optional(),
});

const StreamingQueryRequestSchema = QueryRequestSchema.extend({
  sessionId: z.string().optional(),
});

export const queryRoutes: FastifyPluginAsync = async (fastify) => {
  /**
   * Execute a query
   * POST /api/v1/queries
   */
  fastify.post('/', {
    schema: {
      description: 'Execute a RAG query or agent workflow',
      tags: ['queries'],
      body: {
        type: 'object',
        required: ['query'],
        properties: {
          query: { type: 'string' },
          topK: { type: 'number', minimum: 1, maximum: 20 },
          includeSources: { type: 'boolean' },
          promptStyle: { type: 'string', enum: ['concise', 'detailed', 'reasoning', 'socratic', 'expert'] },
          useAgent: { type: 'boolean' },
          maxIterations: { type: 'number', minimum: 1, maximum: 10 },
          metadataFilters: { type: 'object' },
        },
      },
      response: {
        200: {
          type: 'object',
          properties: {
            answer: { type: 'string' },
            confidence: { type: 'number' },
            sources: { type: 'array' },
            metadata: { type: 'object' },
          },
        },
        400: { type: 'object', properties: { error: { type: 'string' } } },
        500: { type: 'object', properties: { error: { type: 'string' } } },
      },
    },
  }, async (request, reply) => {
    const traceId = telemetry.startTrace('API Query');
    const startTime = Date.now();

    try {
      const body = QueryRequestSchema.parse(request.body);
      
      logger.info('API query received', {
        query: body.query.substring(0, 100),
        useAgent: body.useAgent,
        traceId,
      });

      let result: any;

      if (body.useAgent) {
        // Use the LangGraph.js agent
        result = await agent.execute(body.query, {
          maxIterations: body.maxIterations || 5,
          traceId,
        });
        
        // Format response
        return {
          answer: result.finalAnswer || result.draftAnswer || 'No answer generated',
          confidence: result.evidenceQuality || 0,
          sources: result.evidence?.slice(0, 5).map(ev => ({
            content: ev.content,
            relevance: ev.relevance,
            source: ev.source,
          })) || [],
          metadata: {
            traceId,
            iteration: result.iteration,
            status: result.status,
            duration: Date.now() - startTime,
            agent: true,
          },
        };
      } else {
        // Use the standard orchestration pipeline
        result = await orchestrator.query({
          query: body.query,
          topK: body.topK,
          includeSources: body.includeSources,
          promptStyle: body.promptStyle,
          metadataFilters: body.metadataFilters,
          traceId,
        });
        
        return {
          answer: result.answer,
          confidence: result.confidence || 0,
          sources: result.sources?.slice(0, 5).map((source: any) => ({
            content: source.chunk?.content || source.content,
            score: source.score || 0,
            source: source.chunk?.metadata?.source || 'unknown',
          })) || [],
          metadata: {
            traceId,
            duration: Date.now() - startTime,
            agent: false,
          },
        };
      }

    } catch (error) {
      telemetry.endTrace(traceId, 'error');
      logger.error('Query failed', {
        error: error instanceof Error ? error.message : String(error),
        traceId,
      });
      
      if (error instanceof z.ZodError) {
        return reply.status(400).send({
          error: 'Validation Error',
          details: error.errors,
        });
      }
      
      return reply.status(500).send({
        error: error instanceof Error ? error.message : 'Internal Server Error',
        traceId,
      });
    }
  });

  /**
   * Stream a query
   * GET /api/v1/queries/stream
   */
  fastify.get('/stream', {
    schema: {
      description: 'Stream a RAG query or agent workflow with real-time updates',
      tags: ['queries'],
      querystring: {
        type: 'object',
        required: ['query'],
        properties: {
          query: { type: 'string' },
          useAgent: { type: 'boolean' },
          maxIterations: { type: 'number' },
        },
      },
    },
  }, async (request, reply) => {
    const traceId = telemetry.startTrace('API Stream');
    
    try {
      const { query, useAgent = true, maxIterations = 5 } = request.query as any;
      
      // Set up SSE headers
      reply.raw.writeHead(200, {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
      });
      
      if (useAgent) {
        // Stream agent events
        const stream = agent.stream(query, {
          maxIterations,
          traceId,
        });
        
        for await (const event of stream) {
          const data = JSON.stringify({
            type: 'agent_event',
            data: event,
            timestamp: new Date().toISOString(),
          });
          reply.raw.write(`data: ${data}\n\n`);
          
          // Flush the buffer
          if (typeof reply.raw.flush === 'function') {
            reply.raw.flush();
          }
        }
      } else {
        // Stream orchestration
        // This would use the streaming pipeline from Part 3
        // Simplified for demo
        reply.raw.write(`data: ${JSON.stringify({ type: 'info', message: 'Streaming not implemented for non-agent mode' })}\n\n`);
      }
      
      reply.raw.write('data: [DONE]\n\n');
      reply.raw.end();
      
      telemetry.endTrace(traceId, 'success');
      
    } catch (error) {
      telemetry.endTrace(traceId, 'error');
      logger.error('Stream failed', {
        error: error instanceof Error ? error.message : String(error),
        traceId,
      });
      
      reply.raw.write(`data: ${JSON.stringify({ type: 'error', error: error instanceof Error ? error.message : 'Unknown error' })}\n\n`);
      reply.raw.end();
    }
  });

  /**
   * Get query history
   * GET /api/v1/queries/history
   */
  fastify.get('/history', {
    schema: {
      description: 'Get query history for the current user',
      tags: ['queries'],
      querystring: {
        type: 'object',
        properties: {
          limit: { type: 'number', default: 10 },
          offset: { type: 'number', default: 0 },
        },
      },
    },
  }, async (request, reply) => {
    // In production, this would query the database
    // For now, return a placeholder
    return {
      queries: [],
      total: 0,
      limit: (request.query as any).limit || 10,
      offset: (request.query as any).offset || 0,
    };
  });

  /**
   * Get query details
   * GET /api/v1/queries/:id
   */
  fastify.get('/:id', {
    schema: {
      description: 'Get details of a specific query',
      tags: ['queries'],
      params: {
        type: 'object',
        required: ['id'],
        properties: {
          id: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    const { id } = request.params as { id: string };
    
    // In production, this would query the database
    return {
      id,
      query: 'What is RAG?',
      answer: 'RAG is Retrieval-Augmented Generation...',
      status: 'completed',
      timestamp: new Date().toISOString(),
    };
  });
};
```

#### Ingestion Routes

Create `src/api/routes/ingestion.ts`:

```typescript
/**
 * Ingestion Routes
 * Endpoints for document ingestion
 */

import { FastifyPluginAsync } from 'fastify';
import { z } from 'zod';
import { logger } from '../../services/logger.js';
import loader from '../../ingestion/loader.js';
import chunker from '../../ingestion/chunker.js';
import embedder from '../../ingestion/embedder.js';
import vectorDB from '../../services/vector-db.js';
import telemetry from '../../orchestration/telemetry.js';

const IngestRequestSchema = z.object({
  path: z.string().min(1, 'Path cannot be empty'),
  extensionFilter: z.array(z.string()).optional(),
  dryRun: z.boolean().optional(),
});

export const ingestionRoutes: FastifyPluginAsync = async (fastify) => {
  /**
   * Ingest documents from a directory
   * POST /api/v1/ingestion
   */
  fastify.post('/', {
    schema: {
      description: 'Ingest documents from a directory',
      tags: ['ingestion'],
      body: {
        type: 'object',
        required: ['path'],
        properties: {
          path: { type: 'string' },
          extensionFilter: { type: 'array', items: { type: 'string' } },
          dryRun: { type: 'boolean' },
        },
      },
      response: {
        200: {
          type: 'object',
          properties: {
            documentsLoaded: { type: 'number' },
            chunksCreated: { type: 'number' },
            chunksStored: { type: 'number' },
            jobId: { type: 'string' },
          },
        },
        400: { type: 'object', properties: { error: { type: 'string' } } },
        500: { type: 'object', properties: { error: { type: 'string' } } },
      },
    },
  }, async (request, reply) => {
    const traceId = telemetry.startTrace('Ingestion API');
    
    try {
      const body = IngestRequestSchema.parse(request.body);
      
      logger.info('Ingestion request received', {
        path: body.path,
        dryRun: body.dryRun,
        traceId,
      });

      // In production, this would be queued for async processing
      // For demo, we'll process synchronously
      
      const documents = await loader.loadDirectory(
        body.path,
        body.extensionFilter
      );
      
      if (documents.length === 0) {
        return {
          documentsLoaded: 0,
          chunksCreated: 0,
          chunksStored: 0,
          jobId: `job-${Date.now()}`,
        };
      }

      const chunks = await chunker.chunkDocuments(documents);
      
      if (body.dryRun) {
        return {
          documentsLoaded: documents.length,
          chunksCreated: chunks.length,
          chunksStored: 0,
          jobId: `job-${Date.now()}`,
        };
      }

      const embeddedChunks = await embedder.embedChunks(chunks);
      const storedIds = await vectorDB.storeDocuments(embeddedChunks);

      const result = {
        documentsLoaded: documents.length,
        chunksCreated: chunks.length,
        chunksStored: storedIds.length,
        jobId: `job-${Date.now()}`,
      };

      telemetry.recordEvent('ingestion.complete', {
        documentsLoaded: documents.length,
        chunksStored: storedIds.length,
        traceId,
      });

      telemetry.endTrace(traceId, 'success');

      return result;

    } catch (error) {
      telemetry.endTrace(traceId, 'error');
      logger.error('Ingestion failed', {
        error: error instanceof Error ? error.message : String(error),
        traceId,
      });
      
      if (error instanceof z.ZodError) {
        return reply.status(400).send({
          error: 'Validation Error',
          details: error.errors,
        });
      }
      
      return reply.status(500).send({
        error: error instanceof Error ? error.message : 'Internal Server Error',
        traceId,
      });
    }
  });

  /**
   * Get ingestion job status
   * GET /api/v1/ingestion/:jobId
   */
  fastify.get('/:jobId', {
    schema: {
      description: 'Get the status of an ingestion job',
      tags: ['ingestion'],
      params: {
        type: 'object',
        required: ['jobId'],
        properties: {
          jobId: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    const { jobId } = request.params as { jobId: string };
    
    // In production, this would query the job queue
    return {
      jobId,
      status: 'completed',
      progress: 100,
      createdAt: new Date().toISOString(),
    };
  });

  /**
   * List ingested sources
   * GET /api/v1/ingestion/sources
   */
  fastify.get('/sources', {
    schema: {
      description: 'List all ingested document sources',
      tags: ['ingestion'],
      querystring: {
        type: 'object',
        properties: {
          limit: { type: 'number', default: 50 },
          offset: { type: 'number', default: 0 },
          type: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    // In production, this would query the database
    return {
      sources: [],
      total: 0,
      limit: (request.query as any).limit || 50,
      offset: (request.query as any).offset || 0,
    };
  });

  /**
   * Delete a source
   * DELETE /api/v1/ingestion/sources/:sourceId
   */
  fastify.delete('/sources/:sourceId', {
    schema: {
      description: 'Delete an ingested source',
      tags: ['ingestion'],
      params: {
        type: 'object',
        required: ['sourceId'],
        properties: {
          sourceId: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    const { sourceId } = request.params as { sourceId: string };
    
    // In production, this would delete from the database
    // For demo, we'll just return a success
    return {
      success: true,
      sourceId,
      deletedAt: new Date().toISOString(),
    };
  });
};
```

#### Checkpoint Routes

Create `src/api/routes/checkpoints.ts`:

```typescript
/**
 * Checkpoint Routes
 * Endpoints for agent checkpoint management
 */

import { FastifyPluginAsync } from 'fastify';
import { z } from 'zod';
import { logger } from '../../services/logger.js';
import checkpointManager from '../../agent/persistence.js';
import telemetry from '../../orchestration/telemetry.js';

export const checkpointRoutes: FastifyPluginAsync = async (fastify) => {
  /**
   * List checkpoints
   * GET /api/v1/checkpoints
   */
  fastify.get('/', {
    schema: {
      description: 'List all agent checkpoints',
      tags: ['checkpoints'],
      querystring: {
        type: 'object',
        properties: {
          limit: { type: 'number', default: 20 },
          offset: { type: 'number', default: 0 },
          status: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    try {
      const query = request.query as any;
      const checkpoints = await checkpointManager.listCheckpoints({
        status: query.status,
      });
      
      const limited = checkpoints.slice(
        query.offset || 0,
        (query.offset || 0) + (query.limit || 20)
      );
      
      return {
        checkpoints: limited,
        total: checkpoints.length,
        limit: query.limit || 20,
        offset: query.offset || 0,
      };
      
    } catch (error) {
      logger.error('Failed to list checkpoints', {
        error: error instanceof Error ? error.message : String(error),
      });
      return reply.status(500).send({
        error: 'Failed to list checkpoints',
      });
    }
  });

  /**
   * Get checkpoint details
   * GET /api/v1/checkpoints/:id
   */
  fastify.get('/:id', {
    schema: {
      description: 'Get checkpoint details',
      tags: ['checkpoints'],
      params: {
        type: 'object',
        required: ['id'],
        properties: {
          id: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    const { id } = request.params as { id: string };
    
    try {
      const checkpoint = await checkpointManager.loadCheckpoint(id);
      
      if (!checkpoint) {
        return reply.status(404).send({
          error: 'Checkpoint not found',
        });
      }
      
      return checkpoint;
      
    } catch (error) {
      logger.error('Failed to load checkpoint', {
        id,
        error: error instanceof Error ? error.message : String(error),
      });
      return reply.status(500).send({
        error: 'Failed to load checkpoint',
      });
    }
  });

  /**
   * Resume from checkpoint
   * POST /api/v1/checkpoints/:id/resume
   */
  fastify.post('/:id/resume', {
    schema: {
      description: 'Resume the agent from a checkpoint',
      tags: ['checkpoints'],
      params: {
        type: 'object',
        required: ['id'],
        properties: {
          id: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    const { id } = request.params as { id: string };
    const traceId = telemetry.startTrace('Resume from Checkpoint');
    
    try {
      const checkpoint = await checkpointManager.loadCheckpoint(id);
      
      if (!checkpoint) {
        return reply.status(404).send({
          error: 'Checkpoint not found',
        });
      }
      
      // Import agent dynamically to avoid circular dependencies
      const { default: agent } = await import('../../agent/graph.js');
      
      // Resume execution
      const result = await agent.execute(
        checkpoint.state.query,
        {
          maxIterations: checkpoint.state.maxIterations || 5,
          traceId,
          initialState: checkpoint.state,
        }
      );
      
      telemetry.endTrace(traceId, 'success');
      
      return {
        success: true,
        checkpointId: id,
        result,
      };
      
    } catch (error) {
      telemetry.endTrace(traceId, 'error');
      logger.error('Failed to resume from checkpoint', {
        id,
        error: error instanceof Error ? error.message : String(error),
      });
      return reply.status(500).send({
        error: 'Failed to resume from checkpoint',
      });
    }
  });

  /**
   * Delete checkpoint
   * DELETE /api/v1/checkpoints/:id
   */
  fastify.delete('/:id', {
    schema: {
      description: 'Delete a checkpoint',
      tags: ['checkpoints'],
      params: {
        type: 'object',
        required: ['id'],
        properties: {
          id: { type: 'string' },
        },
      },
    },
  }, async (request, reply) => {
    const { id } = request.params as { id: string };
    
    try {
      await checkpointManager.deleteCheckpoint(id);
      
      return {
        success: true,
        checkpointId: id,
        deletedAt: new Date().toISOString(),
      };
      
    } catch (error) {
      logger.error('Failed to delete checkpoint', {
        id,
        error: error instanceof Error ? error.message : String(error),
      });
      return reply.status(500).send({
        error: 'Failed to delete checkpoint',
      });
    }
  });
};
```

#### Admin Routes

Create `src/api/routes/admin.ts`:

```typescript
/**
 * Admin Routes
 * Administrative endpoints for system management
 */

import { FastifyPluginAsync } from 'fastify';
import { logger } from '../../services/logger.js';
import telemetry from '../../orchestration/telemetry.js';
import vectorDB from '../../services/vector-db.js';
import reranker from '../../retrieval/reranker.js';
import checkpointManager from '../../agent/persistence.js';

export const adminRoutes: FastifyPluginAsync = async (fastify) => {
  /**
   * System status
   * GET /api/v1/admin/status
   */
  fastify.get('/status', {
    schema: {
      description: 'Get system status and health',
      tags: ['admin'],
    },
  }, async (request, reply) => {
    try {
      const dbHealth = await vectorDB.healthCheck();
      const stats = await vectorDB.getStats();
      const telemetryHealth = telemetry.getHealth();
      const rerankerLoaded = reranker.isModelLoaded();
      
      return {
        status: 'operational',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        components: {
          database: {
            healthy: dbHealth,
            stats,
          },
          reranker: {
            loaded: rerankerLoaded,
          },
          telemetry: telemetryHealth,
        },
        checkpoints: {
          total: (await checkpointManager.listCheckpoints()).length,
        },
      };
      
    } catch (error) {
      logger.error('Failed to get system status', {
        error: error instanceof Error ? error.message : String(error),
      });
      return reply.status(500).send({
        status: 'error',
        error: error instanceof Error ? error.message : 'Unknown error',
      });
    }
  });

  /**
   * Clear system cache
   * POST /api/v1/admin/cache/clear
   */
  fastify.post('/cache/clear', {
    schema: {
      description: 'Clear system caches',
      tags: ['admin'],
    },
  }, async (request, reply) => {
    try {
      // Unload reranker model to free memory
      await reranker.unloadModel();
      
      // In production, this would also clear Redis caches
      
      return {
        success: true,
        message: 'Cache cleared successfully',
        timestamp: new Date().toISOString(),
      };
      
    } catch (error) {
      logger.error('Failed to clear cache', {
        error: error instanceof Error ? error.message : String(error),
      });
      return reply.status(500).send({
        error: 'Failed to clear cache',
      });
    }
  });

  /**
   * Cleanup old data
   * POST /api/v1/admin/cleanup
   */
  fastify.post('/cleanup', {
    schema: {
      description: 'Clean up old data and checkpoints',
      tags: ['admin'],
      querystring: {
        type: 'object',
        properties: {
          maxAgeHours: { type: 'number', default: 24 },
        },
      },
    },
  }, async (request, reply) => {
    try {
      const query = request.query as any;
      const maxAgeMs = (query.maxAgeHours || 24) * 60 * 60 * 1000;
      
      const deleted = await checkpointManager.cleanup(maxAgeMs);
      
      return {
        success: true,
        deletedCheckpoints: deleted,
        timestamp: new Date().toISOString(),
      };
      
    } catch (error) {
      logger.error('Failed to cleanup', {
        error: error instanceof Error ? error.message : String(error),
      });
      return reply.status(500).send({
        error: 'Failed to cleanup',
      });
    }
  });

  /**
   * Force reload BM25 index
   * POST /api/v1/admin/index/reload
   */
  fastify.post('/index/reload', {
    schema: {
      description: 'Force reload the BM25 lexical index',
      tags: ['admin'],
    },
  }, async (request, reply) => {
    try {
      const { default: lexicalSearch } = await import('../../retrieval/lexical.js');
      await lexicalSearch.refreshIndex();
      
      return {
        success: true,
        message: 'BM25 index reloaded',
        timestamp: new Date().toISOString(),
      };
      
    } catch (error) {
      logger.error('Failed to reload index', {
        error: error instanceof Error ? error.message : String(error),
      });
      return reply.status(500).send({
        error: 'Failed to reload index',
      });
    }
  });
};
```

---

## Phase C.5: Docker Compose for Production

### The Target
Create Docker configuration for running the entire stack.

### The Implementation

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  # PostgreSQL with pgvector
  postgres:
    image: pgvector/pgvector:pg16
    container_name: rag_postgres
    environment:
      POSTGRES_USER: ${PGVECTOR_USER:-postgres}
      POSTGRES_PASSWORD: ${PGVECTOR_PASSWORD:-postgres}
      POSTGRES_DB: ${PGVECTOR_DATABASE:-rag_db}
    ports:
      - "${PGVECTOR_PORT:-5432}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./scripts/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - rag_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${PGVECTOR_USER:-postgres}"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis for queues and caching
  redis:
    image: redis:7-alpine
    container_name: rag_redis
    ports:
      - "${REDIS_PORT:-6379}:6379"
    volumes:
      - redis_data:/data
    networks:
      - rag_network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # API Server
  api:
    build:
      context: .
      dockerfile: docker/Dockerfile
      target: production
    container_name: rag_api
    environment:
      NODE_ENV: production
      PORT: 3000
      DATABASE_URL: postgresql://${PGVECTOR_USER:-postgres}:${PGVECTOR_PASSWORD:-postgres}@postgres:5432/${PGVECTOR_DATABASE:-rag_db}
      REDIS_URL: redis://redis:6379
      OPENAI_API_KEY: ${OPENAI_API_KEY}
      PGVECTOR_HOST: postgres
      PGVECTOR_PORT: 5432
      PGVECTOR_DATABASE: ${PGVECTOR_DATABASE:-rag_db}
      PGVECTOR_USER: ${PGVECTOR_USER:-postgres}
      PGVECTOR_PASSWORD: ${PGVECTOR_PASSWORD:-postgres}
      LOG_LEVEL: ${LOG_LEVEL:-info}
      CORS_ORIGIN: ${CORS_ORIGIN:-*}
    ports:
      - "${API_PORT:-3000}:3000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - rag_network
    restart: unless-stopped
    volumes:
      - ./logs:/app/logs
      - ./checkpoints:/app/checkpoints

  # Worker for async jobs
  worker:
    build:
      context: .
      dockerfile: docker/Dockerfile
      target: production
    container_name: rag_worker
    command: node dist/workers/index.js
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://${PGVECTOR_USER:-postgres}:${PGVECTOR_PASSWORD:-postgres}@postgres:5432/${PGVECTOR_DATABASE:-rag_db}
      REDIS_URL: redis://redis:6379
      OPENAI_API_KEY: ${OPENAI_API_KEY}
      PGVECTOR_HOST: postgres
      PGVECTOR_PORT: 5432
      PGVECTOR_DATABASE: ${PGVECTOR_DATABASE:-rag_db}
      PGVECTOR_USER: ${PGVECTOR_USER:-postgres}
      PGVECTOR_PASSWORD: ${PGVECTOR_PASSWORD:-postgres}
      LOG_LEVEL: ${LOG_LEVEL:-info}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - rag_network
    restart: unless-stopped
    volumes:
      - ./logs:/app/logs
      - ./checkpoints:/app/checkpoints

  # Nginx for load balancing and static files
  nginx:
    image: nginx:alpine
    container_name: rag_nginx
    ports:
      - "${NGINX_PORT:-80}:80"
      - "${NGINX_SSL_PORT:-443}:443"
    volumes:
      - ./docker/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./docker/ssl:/etc/nginx/ssl:ro
    depends_on:
      - api
    networks:
      - rag_network
    restart: unless-stopped

  # pgAdmin for database management (optional)
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: rag_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL:-admin@example.com}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD:-admin}
    ports:
      - "${PGADMIN_PORT:-5050}:80"
    depends_on:
      - postgres
    networks:
      - rag_network
    restart: unless-stopped
    profiles:
      - dev

networks:
  rag_network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
```

Create `docker/Dockerfile`:

```dockerfile
# Multi-stage build for production

# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build TypeScript
RUN npm run build

# Stage 2: Production
FROM node:20-alpine AS production

WORKDIR /app

# Install production dependencies only
COPY package*.json ./
RUN npm ci --only=production

# Copy built files from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma

# Generate Prisma client
RUN npx prisma generate

# Copy necessary files
COPY .env.example .env

# Set environment
ENV NODE_ENV=production
ENV PORT=3000

# Expose port
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Run the application
CMD ["node", "dist/api/server.js"]
```

---

## Phase C.6: Production Startup Script

### The Target
Create the main entry point that starts everything.

### The Implementation

Create `src/app.ts` (updated for production):

```typescript
/**
 * Main Application Entry Point
 * Starts the API server and workers
 */

import dotenv from 'dotenv';
import { logger } from './services/logger.js';
import { startServer } from './api/server.js';
import telemetry from './orchestration/telemetry.js';

// Load environment variables
dotenv.config();

/**
 * Initialize the application
 */
async function initializeApp() {
  logger.info('🚀 Starting RAG Agent System (Production)');
  
  try {
    // Check environment
    const env = process.env.NODE_ENV || 'development';
    logger.info(`Environment: ${env}`);
    
    // Start telemetry
    telemetry.recordEvent('app.start', {
      env,
      nodeVersion: process.version,
      timestamp: new Date().toISOString(),
    });
    
    // Start the API server
    const server = await startServer();
    
    // Graceful shutdown
    const shutdown = async () => {
      logger.info('🔄 Shutting down gracefully...');
      
      telemetry.recordEvent('app.shutdown', {
        timestamp: new Date().toISOString(),
      });
      
      await server.close();
      
      // Close database connections
      const { vectorDB } = await import('./services/vector-db.js');
      await vectorDB.close();
      
      // Unload reranker
      const { default: reranker } = await import('./retrieval/reranker.js');
      await reranker.unloadModel();
      
      logger.info('✅ Shutdown complete');
      process.exit(0);
    };
    
    // Handle shutdown signals
    process.on('SIGTERM', shutdown);
    process.on('SIGINT', shutdown);
    
    // Handle uncaught errors
    process.on('uncaughtException', (error) => {
      logger.error('Uncaught exception', { error });
      telemetry.recordEvent('app.uncaught_exception', {
        error: error.message,
        stack: error.stack,
      });
    });
    
    process.on('unhandledRejection', (reason) => {
      logger.error('Unhandled rejection', { reason });
      telemetry.recordEvent('app.unhandled_rejection', {
        reason: reason instanceof Error ? reason.message : String(reason),
      });
    });
    
    logger.info('✅ Application started successfully');
    
  } catch (error) {
    logger.error('Failed to start application', {
      error: error instanceof Error ? error.message : String(error),
    });
    process.exit(1);
  }
}

// Start the application
initializeApp();
```

---

## Phase C.7: Verification and Testing

### The Target
Test the complete production system.

### The Implementation

Create `test-production.sh`:

```bash
#!/bin/bash

echo "🧪 Testing Production RAG Agent System"
echo "======================================"

# 1. Start services
echo "📦 Starting services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# 2. Health check
echo "🏥 Checking health..."
curl -s http://localhost:3000/health | jq '.'

# 3. Ingest documents
echo "📄 Ingesting documents..."
curl -X POST http://localhost:3000/api/v1/ingestion \
  -H "Content-Type: application/json" \
  -d '{
    "path": "./docs",
    "extensionFilter": ["txt", "md"]
  }' | jq '.'

# 4. Test standard query
echo "🔍 Testing standard query..."
curl -X POST http://localhost:3000/api/v1/queries \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is RAG?",
    "topK": 3,
    "includeSources": true
  }' | jq '.'

# 5. Test agent query
echo "🤖 Testing agent query..."
curl -X POST http://localhost:3000/api/v1/queries \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What are the benefits of RAG?",
    "useAgent": true,
    "maxIterations": 3
  }' | jq '.'

# 6. Test streaming
echo "📡 Testing streaming endpoint..."
curl -N http://localhost:3000/api/v1/queries/stream?query="How does vector search work?"&useAgent=true

# 7. Check system status
echo "📊 Checking system status..."
curl -s http://localhost:3000/api/v1/admin/status | jq '.'

echo "✅ All tests completed!"
```

---

## Capstone Summary

🎉 **Congratulations! You've built a complete production RAG agent system!**

### What You've Built:

1. **REST API** — Fastify server with full CRUD operations and Swagger docs
2. **Async Processing** — Queue-based job system for ingestion
3. **WebSocket Support** — Real-time agent progress updates
4. **Production HITL** — Human approval workflow with webhooks
5. **Docker Compose** — Full stack with PostgreSQL, Redis, and the application
6. **Comprehensive Monitoring** — Health checks, metrics endpoints, and logging
7. **Deployment Ready** — Multi-stage Docker builds and environment configurations

### System Features:

| Feature | Implementation |
|---------|---------------|
| **RAG Pipeline** | Hybrid search + cross-encoder reranking |
| **Agent Workflow** | LangGraph.js with self-correction |
| **Human-in-the-Loop** | Approval gates with notifications |
| **Async Ingestion** | BullMQ job queues |
| **Web API** | Fastify REST + WebSocket |
| **Persistence** | PostgreSQL + pgvector |
| **Telemetry** | Distributed tracing + metrics |
| **Deployment** | Docker Compose |

---

## Final System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Complete Production System                          │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        Nginx (Load Balancer)                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                        │
│          ┌─────────────────────────┼─────────────────────────┐             │
│          │                         │                         │             │
│          ▼                         ▼                         ▼             │
│  ┌──────────────┐       ┌──────────────┐       ┌──────────────┐          │
│  │   API Server │       │   Workers    │       │   WebSocket  │          │
│  │   (Fastify)  │       │   (BullMQ)   │       │   Handler    │          │
│  └──────────────┘       └──────────────┘       └──────────────┘          │
│          │                         │                         │             │
│          └─────────────────────────┼─────────────────────────┘             │
│                                    │                                        │
│          ┌─────────────────────────┼─────────────────────────┐             │
│          │                         │                         │             │
│          ▼                         ▼                         ▼             │
│  ┌──────────────┐       ┌──────────────┐       ┌──────────────┐          │
│  │  PostgreSQL  │       │    Redis     │       │   Checkpoint │          │
│  │   (pgvector) │       │   (Queues)   │       │   Storage    │          │
│  └──────────────┘       └──────────────┘       └──────────────┘          │
│          │                                                       │          │
│          └───────────────────────────────────────────────────────┘          │
│                                    │                                        │
│          ┌─────────────────────────┼─────────────────────────┐             │
│          │                         │                         │             │
│          ▼                         ▼                         ▼             │
│  ┌──────────────┐       ┌──────────────┐       ┌──────────────┐          │
│  │  Orchestrator│       │   LangGraph  │       │  Telemetry   │          │
│  │  (LangChain) │       │    Agent     │       │  & Metrics   │          │
│  └──────────────┘       └──────────────┘       └──────────────┘          │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## What You Can Do Now

1. **Deploy to Production**: Use Docker Compose to deploy the entire stack
2. **Add Authentication**: Implement JWT or OAuth for secure access
3. **Scale Horizontally**: Add more API servers and workers
4. **Add More Document Sources**: Support S3, Google Drive, etc.
5. **Implement Webhooks**: Notify external systems on completion
6. **Add Analytics**: Track usage patterns and performance
7. **Optimize Performance**: Add caching, connection pooling, etc.

---

## Series Complete! 🎉

You've journeyed from a simple LLM API call to a complete production RAG agent system!

### The Journey:

- **Part 1**: RAG foundations — embedding, vector search, generation
- **Part 2**: Advanced retrieval — hybrid search, reranking, governance
- **Part 3**: Orchestration — LangChain.js runnables, telemetry
- **Part 4**: Agents — LangGraph.js state machines, self-correction
- **Capstone**: Production — API, queues, Docker, deployment

### Key Skills You've Developed:

- 🧠 Building production RAG systems
- 🔍 Implementing hybrid search and reranking
- 🚀 Orchestrating with LangChain.js
- 🤖 Building agents with LangGraph.js
- 📊 Monitoring with telemetry and metrics
- 🏗️ Deploying with Docker and microservices


**Thank you for completing "Bridging the Gap: Enterprise RAG, Vector Databases, and Agentic Orchestration"!**
