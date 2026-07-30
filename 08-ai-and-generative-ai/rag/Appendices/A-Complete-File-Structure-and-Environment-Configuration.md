# Appendix A: Complete File Structure and Environment Configuration

## Overview

This appendix provides a comprehensive reference for the complete file structure, environment configuration, and all configuration files used throughout the series. Use this as a quick reference when setting up or troubleshooting your RAG Agent System.

---

## A.1 Complete File Tree

```
rag-agent-system/
│
├── .env.example                 # Environment variables template
├── .env                        # Your actual environment variables (gitignored)
├── .gitignore                  # Git ignore file
├── package.json                # NPM package manifest
├── package-lock.json           # NPM lock file
├── tsconfig.json               # TypeScript configuration
├── docker-compose.yml          # Docker Compose configuration
├── test-hybrid.ts              # Hybrid search test script
├── test-ingestion.ts           # Ingestion test script
├── test-agent.ts               # Agent test script
├── test-production.sh          # Production test script
│
├── docs/                       # Sample documents
│   └── sample.txt
│
├── checkpoints/                # Agent checkpoint storage
│
├── logs/                       # Application logs
│   ├── combined.log
│   └── error.log
│
├── prisma/                     # Prisma database schema
│   └── schema.prisma
│
├── scripts/                    # Utility scripts
│   ├── init-db.sql            # Database initialization
│   ├── setup-database.js      # Database setup script
│   ├── seed.ts                # Seed data script
│   └── migrate.ts             # Migration script
│
├── docker/                     # Docker configuration
│   ├── Dockerfile             # Multi-stage Docker build
│   ├── nginx.conf             # Nginx configuration
│   └── ssl/                   # SSL certificates
│
└── src/                        # Source code
    ├── app.ts                  # Main application entry point
    │
    ├── api/                    # API Layer
    │   ├── server.ts          # Fastify server setup
    │   ├── middleware/        # Middleware
    │   │   ├── auth.ts        # Authentication middleware
    │   │   ├── logging.ts     # Request logging middleware
    │   │   └── validation.ts  # Request validation middleware
    │   ├── routes/            # API routes
    │   │   ├── queries.ts     # Query endpoints
    │   │   ├── ingestion.ts   # Ingestion endpoints
    │   │   ├── checkpoints.ts # Checkpoint endpoints
    │   │   └── admin.ts       # Administrative endpoints
    │   └── schemas/           # Request/response schemas
    │       ├── request.ts     # Request validation schemas
    │       └── response.ts    # Response schemas
    │
    ├── agent/                  # LangGraph.js Agent Layer
    │   ├── graph.ts           # Main agent graph definition
    │   ├── state.ts           # State annotations and types
    │   ├── persistence.ts     # Checkpoint persistence
    │   ├── parallel.ts        # Parallel execution utilities
    │   └── nodes/             # Agent nodes
    │       ├── search.ts      # Search node
    │       ├── evaluate.ts    # Evaluate node
    │       ├── generate.ts    # Generate node
    │       ├── reflect.ts     # Reflect node
    │       └── human-approval.ts # Human approval node
    │
    ├── ingestion/              # Document Ingestion Layer
    │   ├── loader.ts          # Document loader
    │   ├── chunker.ts         # Text chunker
    │   └── embedder.ts        # Embedding service
    │
    ├── retrieval/              # Retrieval Layer
    │   ├── retriever.ts       # Hybrid retriever
    │   ├── lexical.ts         # BM25 lexical search
    │   ├── fusion.ts          # Reciprocal Rank Fusion
    │   ├── reranker.ts        # Cross-encoder reranker
    │   ├── generator.ts       # Response generator
    │   ├── pipeline.ts        # Complete RAG pipeline
    │   └── governance.ts      # Metadata governance
    │
    ├── orchestration/          # Orchestration Layer
    │   ├── runnables/         # LangChain.js runnables
    │   │   ├── base.ts        # Base runnables
    │   │   └── rag-pipeline.ts # RAG pipeline runnables
    │   ├── prompts.ts         # Prompt templates
    │   ├── schemas.ts         # Zod schemas
    │   ├── telemetry.ts       # Telemetry service
    │   └── orchestrator.ts    # Main orchestrator
    │
    ├── services/               # Core Services
    │   ├── vector-db.ts       # Vector database service
    │   ├── logger.ts          # Logging service
    │   ├── notification.ts    # Notification service
    │   ├── email.ts           # Email service
    │   └── webhook.ts         # Webhook service
    │
    ├── workers/                # Async Workers
    │   ├── index.ts           # Worker entry point
    │   ├── ingestion-worker.ts # Ingestion worker
    │   ├── query-worker.ts    # Query worker
    │   └── hitl-worker.ts     # HITL worker
    │
    ├── queues/                 # Queue Definitions
    │   ├── ingestion-queue.ts # Ingestion queue
    │   └── hitl-queue.ts      # HITL queue
    │
    ├── websocket/              # WebSocket Layer
    │   ├── manager.ts         # WebSocket connection manager
    │   └── handlers.ts        # WebSocket message handlers
    │
    └── types/                  # TypeScript Types
        └── index.ts           # Shared type definitions
```

---

## A.2 Environment Configuration (.env.example)

```env
# ============================================
# Application Configuration
# ============================================
NODE_ENV=development
PORT=3000
HOST=0.0.0.0
LOG_LEVEL=info
LOG_FORMAT=pretty

# ============================================
# API Configuration
# ============================================
API_HOST=localhost
CORS_ORIGIN=http://localhost:3000,http://localhost:8080
RATE_LIMIT_MAX=100
RATE_LIMIT_WINDOW=60000

# ============================================
# OpenAI Configuration
# ============================================
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_EMBEDDING_MODEL=text-embedding-3-small
OPENAI_CHAT_MODEL=gpt-4o-mini
OPENAI_API_BASE=https://api.openai.com/v1

# ============================================
# Vector Database Configuration (pgvector)
# ============================================
VECTOR_DB_TYPE=pgvector
PGVECTOR_HOST=localhost
PGVECTOR_PORT=5432
PGVECTOR_DATABASE=rag_db
PGVECTOR_USER=postgres
PGVECTOR_PASSWORD=postgres
PGVECTOR_POOL_SIZE=10

# ============================================
# Redis Configuration (for queues)
# ============================================
REDIS_URL=redis://localhost:6379
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# ============================================
# Database Configuration (Prisma)
# ============================================
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/rag_db

# ============================================
# Chunking Configuration
# ============================================
CHUNK_SIZE=1000
CHUNK_OVERLAP=200
MIN_CHUNK_SIZE=100
CHUNKING_STRATEGY=recursive

# ============================================
# Retrieval Configuration
# ============================================
TOP_K_RETRIEVAL=5
SIMILARITY_THRESHOLD=0.7
USE_HYBRID_SEARCH=true
USE_RERANKING=true

# ============================================
# Agent Configuration
# ============================================
MAX_AGENT_ITERATIONS=5
EXECUTION_TIMEOUT_MS=30000
ENABLE_CHECKPOINTING=true
CHECKPOINT_DIR=./checkpoints

# ============================================
# Human-in-the-Loop Configuration
# ============================================
ENABLE_HITL=true
HITL_TIMEOUT_MS=300000
APPROVAL_REQUIRED_FOR_RISK_THRESHOLD=0.3
HITL_NOTIFICATION_EMAIL=admin@example.com
HITL_WEBHOOK_URL=

# ============================================
# Email Configuration (for HITL notifications)
# ============================================
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
SMTP_FROM=rag-system@example.com

# ============================================
# LangSmith Configuration (optional)
# ============================================
LANGCHAIN_TRACING_V2=false
LANGCHAIN_API_KEY=
LANGCHAIN_PROJECT=rag-agent-series

# ============================================
# Monitoring Configuration
# ============================================
PROMETHEUS_ENABLED=false
PROMETHEUS_PORT=9090

# ============================================
# Security Configuration
# ============================================
JWT_SECRET=your_jwt_secret_here
JWT_EXPIRY=7d
SESSION_TIMEOUT=3600
BCRYPT_ROUNDS=12

# ============================================
# Feature Flags
# ============================================
ENABLE_STREAMING=true
ENABLE_BATCH_PROCESSING=false
ENABLE_CACHE=true
```

---

## A.3 TypeScript Configuration (tsconfig.json)

```json
{
  "compilerOptions": {
    /* Language and Environment */
    "target": "ES2022",
    "lib": ["ES2022", "DOM"],
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    
    /* Type Checking */
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    
    /* Modules */
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    
    /* Output */
    "outDir": "./dist",
    "rootDir": "./src",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    
    /* Interop */
    "allowSyntheticDefaultImports": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    
    /* Advanced */
    "incremental": true,
    "tsBuildInfoFile": "./.tsbuildinfo"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests", "**/*.test.ts"]
}
```

---

## A.4 Package.json

```json
{
  "name": "rag-agent-system",
  "version": "1.0.0",
  "description": "Production-grade RAG and agentic workflow system with LangChain.js and LangGraph.js",
  "main": "dist/app.js",
  "type": "module",
  "scripts": {
    "build": "tsc",
    "build:watch": "tsc --watch",
    "start": "node dist/app.js",
    "start:dev": "nodemon --exec ts-node src/app.ts",
    "start:api": "node dist/api/server.js",
    "start:worker": "node dist/workers/index.js",
    "start:all": "concurrently \"npm run start:api\" \"npm run start:worker\"",
    "dev": "npm run start:dev",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:integration": "jest --testMatch='**/*.integration.test.ts'",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix",
    "format": "prettier --write 'src/**/*.ts'",
    "format:check": "prettier --check 'src/**/*.ts'",
    "clean": "rm -rf dist",
    "clean:all": "rm -rf dist node_modules",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate dev",
    "prisma:deploy": "prisma migrate deploy",
    "prisma:studio": "prisma studio",
    "setup:db": "node scripts/setup-database.js",
    "seed": "ts-node scripts/seed.ts",
    "docker:build": "docker-compose build",
    "docker:up": "docker-compose up -d",
    "docker:down": "docker-compose down",
    "docker:logs": "docker-compose logs -f",
    "docker:clean": "docker-compose down -v"
  },
  "dependencies": {
    "@fastify/cors": "^8.5.0",
    "@fastify/helmet": "^11.1.1",
    "@fastify/rate-limit": "^8.0.3",
    "@fastify/swagger": "^8.14.0",
    "@fastify/swagger-ui": "^3.0.0",
    "@fastify/websocket": "^10.0.1",
    "@langchain/anthropic": "^0.2.11",
    "@langchain/community": "^0.2.24",
    "@langchain/core": "^0.2.20",
    "@langchain/langgraph": "^0.0.28",
    "@langchain/langsmith": "^0.1.28",
    "@langchain/openai": "^0.2.10",
    "@prisma/client": "^5.16.1",
    "@xenova/transformers": "^2.17.2",
    "ajv": "^8.16.0",
    "bm25js": "^0.0.3",
    "bullmq": "^5.1.5",
    "dotenv": "^16.4.5",
    "fastify": "^4.27.0",
    "helmet": "^7.1.0",
    "ioredis": "^5.4.1",
    "js-tiktoken": "^1.0.12",
    "langchain": "^0.2.14",
    "nanoid": "^5.0.7",
    "nodemailer": "^6.9.13",
    "pdf-parse": "^1.1.1",
    "pg": "^8.12.0",
    "prisma": "^5.16.1",
    "uuid": "^10.0.0",
    "winston": "^3.13.0",
    "zod": "^3.23.8"
  },
  "devDependencies": {
    "@types/bm25js": "^0.0.3",
    "@types/jest": "^29.5.12",
    "@types/node": "^20.14.10",
    "@types/nodemailer": "^6.4.15",
    "@types/pg": "^8.11.6",
    "@types/uuid": "^10.0.0",
    "@typescript-eslint/eslint-plugin": "^7.16.0",
    "@typescript-eslint/parser": "^7.16.0",
    "concurrently": "^8.2.2",
    "eslint": "^8.57.0",
    "jest": "^29.7.0",
    "nodemon": "^3.1.4",
    "prettier": "^3.3.2",
    "ts-jest": "^29.1.5",
    "ts-node": "^10.9.2",
    "typescript": "^5.5.3"
  },
  "engines": {
    "node": ">=20.0.0"
  },
  "keywords": [
    "rag",
    "langchain",
    "langgraph",
    "ai",
    "vector-database",
    "pgvector",
    "agent",
    "llm"
  ],
  "author": "",
  "license": "MIT"
}
```

---

## A.5 Docker Compose Configuration (docker-compose.yml)

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
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '0.5'
          memory: 1G

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
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '0.5'
          memory: 1G

  # Nginx for load balancing (optional)
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
    profiles:
      - production

  # pgAdmin (development only)
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
    driver: local
  redis_data:
    driver: local
```

---

## A.6 Dockerfile (docker/Dockerfile)

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

# Generate Prisma client
RUN npx prisma generate

# Stage 2: Production
FROM node:20-alpine AS production

WORKDIR /app

# Install production dependencies only
COPY package*.json ./
RUN npm ci --only=production

# Copy built files from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

# Copy necessary files
COPY .env.example .env

# Create necessary directories
RUN mkdir -p logs checkpoints

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

# Development stage
FROM node:20-alpine AS development

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Install nodemon for development
RUN npm install -g nodemon

# Expose port
EXPOSE 3000

# Run in development mode
CMD ["npm", "run", "dev"]
```

---

## A.7 Prisma Schema (prisma/schema.prisma)

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
  embedding   Unsupported("vector(1536)")? // pgvector extension
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

---

## A.8 .gitignore

```gitignore
# ============================================
# Node.js
# ============================================
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
package-lock.json
yarn.lock
pnpm-lock.yaml

# ============================================
# TypeScript
# ============================================
dist/
*.tsbuildinfo
*.d.ts.map
*.js.map

# ============================================
# Environment
# ============================================
.env
.env.local
.env.*.local
.env.production

# ============================================
# IDE / Editor
# ============================================
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db
*.iml

# ============================================
# Database
# ============================================
*.db
*.sqlite
*.sqlite3
pgdata/
prisma/*.db
prisma/migrations/*.sql
prisma/migrations/migration_lock.toml

# ============================================
# Logs
# ============================================
logs/
*.log
*.log.gz

# ============================================
# Checkpoints
# ============================================
checkpoints/
*.checkpoint

# ============================================
# Testing
# ============================================
coverage/
.nyc_output/
*.test.js
*.spec.js

# ============================================
# Docker
# ============================================
docker/ssl/*.pem
docker/ssl/*.crt
docker/ssl/*.key

# ============================================
# OS
# ============================================
.DS_Store
Thumbs.db
.desktop.ini
*.tmp
*.temp

# ============================================
# Misc
# ============================================
.terraform/
*.tfstate
*.tfstate.backup
.terragrunt-cache/
```

---

## A.9 Database Initialization Script (scripts/init-db.sql)

```sql
-- Enable the vector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create the documents table
CREATE TABLE IF NOT EXISTS documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content TEXT NOT NULL,
    embedding VECTOR(1536),  -- 1536 dimensions for text-embedding-3-small
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create an HNSW index for fast similarity search
CREATE INDEX IF NOT EXISTS documents_embedding_idx 
ON documents 
USING hnsw (embedding vector_cosine_ops);

-- Create GIN index for JSONB metadata filtering
CREATE INDEX IF NOT EXISTS documents_metadata_idx 
ON documents 
USING gin (metadata);

-- Create a function to automatically update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to update updated_at
CREATE TRIGGER update_documents_updated_at
BEFORE UPDATE ON documents
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Create a function for cosine similarity search
CREATE OR REPLACE FUNCTION search_documents(
    query_embedding VECTOR(1536),
    match_threshold FLOAT,
    match_count INT
)
RETURNS TABLE(
    id UUID,
    content TEXT,
    metadata JSONB,
    similarity FLOAT,
    created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        documents.id,
        documents.content,
        documents.metadata,
        1 - (documents.embedding <=> query_embedding) AS similarity,
        documents.created_at
    FROM documents
    WHERE 1 - (documents.embedding <=> query_embedding) > match_threshold
    ORDER BY documents.embedding <=> query_embedding
    LIMIT match_count;
END;
$$;

-- Create a function for metadata-filtered search
CREATE OR REPLACE FUNCTION search_documents_with_metadata(
    query_embedding VECTOR(1536),
    match_threshold FLOAT,
    match_count INT,
    metadata_filters JSONB
)
RETURNS TABLE(
    id UUID,
    content TEXT,
    metadata JSONB,
    similarity FLOAT,
    created_at TIMESTAMP WITH TIME ZONE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        documents.id,
        documents.content,
        documents.metadata,
        1 - (documents.embedding <=> query_embedding) AS similarity,
        documents.created_at
    FROM documents
    WHERE 
        1 - (documents.embedding <=> query_embedding) > match_threshold
        AND documents.metadata @> metadata_filters
    ORDER BY documents.embedding <=> query_embedding
    LIMIT match_count;
END;
$$;

-- Create a view for document statistics
CREATE OR REPLACE VIEW document_stats AS
SELECT 
    COUNT(*) as total_documents,
    AVG(LENGTH(content)) as avg_content_length,
    MIN(created_at) as oldest_document,
    MAX(created_at) as newest_document
FROM documents;

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO postgres;
```

---

## A.10 Nginx Configuration (docker/nginx.conf)

```nginx
events {
    worker_connections 1024;
}

http {
    upstream rag_api {
        server api:3000 max_fails=3 fail_timeout=30s;
        keepalive 32;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=ingestion:10m rate=2r/s;

    server {
        listen 80;
        server_name localhost;

        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;

        # Gzip compression
        gzip on;
        gzip_vary on;
        gzip_min_length 1024;
        gzip_types text/plain text/css text/xml text/javascript application/javascript application/json;

        # API Routes
        location /api/ {
            proxy_pass http://rag_api;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Connection "";

            # Rate limiting
            limit_req zone=api burst=20 nodelay;

            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        # WebSocket routes
        location /ws/ {
            proxy_pass http://rag_api;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # Longer timeout for WebSockets
            proxy_connect_timeout 3600s;
            proxy_send_timeout 3600s;
            proxy_read_timeout 3600s;
        }

        # Ingestion routes - lower rate limit
        location /api/v1/ingestion/ {
            proxy_pass http://rag_api;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            limit_req zone=ingestion burst=5 nodelay;
        }

        # Health check - no rate limiting
        location /health {
            proxy_pass http://rag_api;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            access_log off;
        }

        # Swagger documentation
        location /docs {
            proxy_pass http://rag_api;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Static files
        location /static/ {
            alias /usr/share/nginx/html/;
            expires 1y;
            add_header Cache-Control "public, immutable";
        }

        # Error pages
        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
            root /usr/share/nginx/html;
        }

        # Default route
        location / {
            return 301 /docs;
        }
    }
}
```

---

## A.11 Common npm Scripts Quick Reference

```json
{
  "build": "tsc",
  "start": "node dist/app.js",
  "dev": "nodemon --exec ts-node src/app.ts",
  "test": "jest",
  "lint": "eslint src/**/*.ts",
  "format": "prettier --write 'src/**/*.ts'",
  "prisma:generate": "prisma generate",
  "prisma:migrate": "prisma migrate dev",
  "prisma:studio": "prisma studio",
  "setup:db": "node scripts/setup-database.js",
  "docker:up": "docker-compose up -d",
  "docker:down": "docker-compose down"
}
```

---

## A.12 Quick Start Commands

### Initial Setup

```bash
# 1. Clone and enter the project
git clone <repository>
cd rag-agent-system

# 2. Install dependencies
npm install

# 3. Copy environment file
cp .env.example .env
# Edit .env with your API keys

# 4. Setup database
docker-compose up -d postgres
npm run setup:db
npm run prisma:migrate

# 5. Start the development server
npm run dev
```

### Production Deployment

```bash
# Build and start all services
docker-compose up -d

# Check logs
docker-compose logs -f

# Scale workers
docker-compose up -d --scale worker=3

# Stop services
docker-compose down

# Clean everything (including volumes)
docker-compose down -v
```

### Testing

```bash
# Run all tests
npm test

# Run integration tests
npm run test:integration

# Test agent
npx ts-node test-agent.ts

# Test hybrid search
npx ts-node test-hybrid.ts

# Test ingestion
npx ts-node test-ingestion.ts
```

---

**[APPENDIX A — COMPLETE]**
