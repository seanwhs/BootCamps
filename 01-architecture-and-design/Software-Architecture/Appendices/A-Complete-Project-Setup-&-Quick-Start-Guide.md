# Appendix A: Complete Project Setup & Quick Start Guide

## Getting Your Development Environment Ready

Welcome to the first appendix! This guide will help you set up your development environment from scratch and get the Orchestrator system running quickly. Think of this like setting up your kitchen before you start cooking - all the tools and ingredients need to be in place before you can create a masterpiece.

### 1. Prerequisites

Before you begin, ensure you have the following installed:

#### Required Software

```bash
# Check your versions
node --version    # v20.x or later
npm --version     # v10.x or later
docker --version  # v24.x or later
docker-compose --version  # v2.x or later
git --version     # v2.x or later
```

**Installation Links:**
- [Node.js](https://nodejs.org/) (v20 or later)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Git](https://git-scm.com/downloads)
- [Visual Studio Code](https://code.visualstudio.com/) (recommended)

#### Recommended VS Code Extensions

```json
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "ms-azuretools.vscode-docker",
    "mtxr.sqltools",
    "mtxr.sqltools-driver-pg",
    "redhat.vscode-yaml",
    "hashicorp.terraform",
    "ms-vscode-remote.remote-containers"
  ]
}
```

### 2. Quick Start: Get the System Running in 5 Minutes

#### Option A: Clone and Run (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/orchestrator-system.git
cd orchestrator-system

# Navigate to the gateway service
cd packages/gateway

# Install dependencies
npm install

# Copy environment configuration
cp .env.example .env

# Start all services with Docker Compose
docker-compose up -d

# Run database migrations
npm run admin:db-migrate

# Start the development server
npm run dev
```

Your system is now running! Access it at:
- **API:** http://localhost:3000
- **Health Check:** http://localhost:3000/health
- **Metrics:** http://localhost:3000/metrics
- **Queue Stats:** http://localhost:3000/queue/stats
- **Tracing Stats:** http://localhost:3000/tracing/stats

#### Option B: Create from Scratch

If you want to build the project step by step:

```bash
# Create project directory
mkdir orchestrator-system
cd orchestrator-system

# Initialize workspace
mkdir -p packages/gateway
cd packages/gateway

# Initialize package.json
npm init -y

# Install core dependencies
npm install fastify dotenv pino pino-pretty zod pg ioredis

# Install development dependencies
npm install -D @types/node @types/pg @types/ioredis typescript tsx vitest eslint @typescript-eslint/eslint-plugin @typescript-eslint/parser

# Initialize TypeScript
npx tsc --init

# Create project structure
mkdir -p src/{core,infrastructure,tests}
mkdir -p src/core/{domain,application}
mkdir -p src/infrastructure/{adapters,di}
```

### 3. Environment Configuration

#### .env File Setup

Create your `.env` file with these minimal settings:

```env
# Server Configuration
NODE_ENV=development
PORT=3000
HOST=0.0.0.0
LOG_LEVEL=debug

# Service Metadata
SERVICE_NAME=gateway
SERVICE_VERSION=1.0.0

# PostgreSQL (local development)
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/orchestrator

# Redis (local development)
REDIS_URL=redis://localhost:6379

# Security (development only)
JWT_SECRET=dev-secret-key-change-in-production

# CORS (development)
CORS_ORIGINS=*

# Worker Configuration
WORKER_COUNT=2
```

#### Docker Compose Configuration

**File:** `packages/gateway/docker-compose.yml`

```yaml
version: '3.8'

services:
  # PostgreSQL
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: orchestrator
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Redis
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Admin Tools (optional)
  admin:
    image: node:20-alpine
    working_dir: /app
    volumes:
      - .:/app
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/orchestrator
      - REDIS_URL=redis://redis:6379
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    command: npm run admin:db-migrate
    profiles:
      - admin

volumes:
  postgres_data:
```

### 4. Development Commands Cheat Sheet

#### Setup Commands

```bash
# Install dependencies
npm install

# Set up environment
cp .env.example .env

# Start infrastructure (PostgreSQL + Redis)
docker-compose up -d

# Run database migrations
npm run admin:db-migrate

# Start development server with hot reload
npm run dev
```

#### Build Commands

```bash
# TypeScript build
npm run build

# Build serverless bundles
npm run build:serverless

# Optimize bundles for production
npm run build:optimize
```

#### Test Commands

```bash
# Run all tests
npm test

# Run specific test suite
npm test -- tests/unit/
npm test -- tests/integration/
npm test -- tests/e2e/

# Run tests with coverage
npm run test:coverage

# Run tests with watch mode
npm test -- --watch
```

#### Deployment Commands

```bash
# Deploy to AWS Lambda
npm run deploy:lambda

# Deploy to Cloudflare Workers
npm run deploy:worker

# Deploy with Terraform
npm run deploy:terraform
```

#### Admin Commands

```bash
# Run health check
npm run admin:health

# Run database migrations
npm run admin:db-migrate

# Seed database with test data
npm run admin:db-seed

# Check queue stats
curl http://localhost:3000/queue/stats

# Check tracing stats
curl http://localhost:3000/tracing/stats
```

### 5. Troubleshooting Common Issues

#### Issue 1: PostgreSQL Connection Failed

**Error:** `Error: connect ECONNREFUSED 127.0.0.1:5432`

**Solution:**
```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Start PostgreSQL
docker-compose up -d postgres

# Wait for it to be ready
docker-compose exec postgres pg_isready -U postgres
```

#### Issue 2: Redis Connection Failed

**Error:** `Error: connect ECONNREFUSED 127.0.0.1:6379`

**Solution:**
```bash
# Check if Redis is running
docker ps | grep redis

# Start Redis
docker-compose up -d redis

# Test Redis connection
docker-compose exec redis redis-cli ping
```

#### Issue 3: Port Already in Use

**Error:** `Error: listen EADDRINUSE: address already in use :::3000`

**Solution:**
```bash
# Find the process using port 3000
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or use a different port
# Change PORT in .env file
```

#### Issue 4: Migration Failed

**Error:** `Error: migration 001_initial_schema.sql failed`

**Solution:**
```bash
# Check if database exists
docker-compose exec postgres psql -U postgres -l

# Drop and recreate database (⚠️ DEV ONLY)
docker-compose exec postgres psql -U postgres -c "DROP DATABASE IF EXISTS orchestrator"
docker-compose exec postgres psql -U postgres -c "CREATE DATABASE orchestrator"

# Re-run migrations
npm run admin:db-migrate
```

#### Issue 5: TypeScript Compilation Errors

**Error:** `TS2307: Cannot find module`

**Solution:**
```bash
# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Clear TypeScript cache
rm -rf dist
npx tsc --noEmit
```

### 6. Development Workflow

#### Standard Development Cycle

```bash
# 1. Start infrastructure
docker-compose up -d

# 2. Run migrations (first time only)
npm run admin:db-migrate

# 3. Start development server
npm run dev

# 4. Make changes to code
#   - Edit files in src/
#   - Server automatically reloads

# 5. Run tests
npm test

# 6. Commit changes
git add .
git commit -m "Description of changes"

# 7. Push to repository
git push
```

#### Testing a Specific Feature

```bash
# 1. Create a test user
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "username": "testuser",
    "password": "SecurePass123",
    "firstName": "Test",
    "lastName": "User"
  }'

# 2. Create a task
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Task",
    "description": "This is a test task",
    "userId": "YOUR_USER_ID",
    "priority": "high"
  }'

# 3. Check task status
curl http://localhost:3000/api/tasks/TASK_ID?userId=YOUR_USER_ID

# 4. Complete the task
curl -X POST http://localhost:3000/api/tasks/TASK_ID/complete \
  -H "Content-Type: application/json" \
  -d '{"userId": "YOUR_USER_ID"}'
```

### 7. Useful Debugging Tools

#### PostgreSQL CLI

```bash
# Connect to PostgreSQL
docker-compose exec postgres psql -U postgres -d orchestrator

# Useful commands
\dt                    # List all tables
\d users              # Describe users table
SELECT * FROM users;   # Query users
SELECT * FROM events ORDER BY occurred_at DESC LIMIT 10;  # Query events
```

#### Redis CLI

```bash
# Connect to Redis
docker-compose exec redis redis-cli

# Useful commands
KEYS *                # List all keys
GET user:123          # Get a specific key
DEL user:123          # Delete a key
FLUSHDB               # Clear database (⚠️ DEV ONLY)
INFO                  # Get Redis info
```

#### Logs Inspection

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs gateway
docker-compose logs postgres
docker-compose logs redis

# Follow logs in real-time
docker-compose logs -f gateway

# View application logs
tail -f logs/app.log

# View error logs
tail -f logs/error.log
```

### 8. Performance Testing

#### Load Testing with Apache Bench

```bash
# Test health endpoint
ab -n 1000 -c 10 http://localhost:3000/health

# Test user creation
ab -n 100 -c 5 -T 'application/json' -p test-user.json http://localhost:3000/api/users
```

#### Performance Monitoring

```bash
# Check process metrics
curl http://localhost:3000/metrics

# Check queue stats
curl http://localhost:3000/queue/stats

# Check tracing stats
curl http://localhost:3000/tracing/stats

# Check event store stats
curl http://localhost:3000/event-store/stats
```

### 9. Project Structure Quick Reference

```
orchestrator-system/
├── packages/
│   └── gateway/                  # Main service
│       ├── src/
│       │   ├── core/             # Domain & Application logic
│       │   │   ├── domain/       # Entities, Events, Repositories
│       │   │   └── application/  # Commands, Queries, Handlers
│       │   ├── infrastructure/   # Adapters & Infrastructure
│       │   │   ├── adapters/     # HTTP, Persistence, Cache, etc.
│       │   │   └── di/           # Dependency Injection
│       │   ├── config.ts         # Configuration
│       │   ├── logger.ts         # Logging
│       │   └── server.ts         # Main server
│       ├── infrastructure/       # DevOps & Infrastructure
│       │   ├── terraform/        # IaC
│       │   ├── cloudformation/   # AWS templates
│       │   └── github-actions/   # CI/CD
│       ├── tests/
│       │   ├── unit/             # Unit tests
│       │   ├── integration/      # Integration tests
│       │   └── e2e/              # End-to-end tests
│       ├── scripts/              # Utility scripts
│       ├── docker-compose.yml    # Local services
│       ├── Dockerfile            # Container build
│       ├── package.json          # Dependencies
│       └── tsconfig.json         # TypeScript config
└── README.md                     # Project documentation
```

### 10. Quick Reference: Key Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/health/ready` | GET | Readiness probe |
| `/health/live` | GET | Liveness probe |
| `/metrics` | GET | Performance metrics |
| `/status` | GET | Detailed status (dev only) |
| `/api/users` | POST | Create user |
| `/api/users/:id` | GET | Get user |
| `/api/users/:id` | PUT | Update user |
| `/api/users/:id` | DELETE | Delete user |
| `/api/tasks` | POST | Create task |
| `/api/tasks/:id` | GET | Get task |
| `/api/tasks/:id` | PUT | Update task |
| `/api/tasks/:id` | DELETE | Delete task |
| `/api/tasks/:id/start` | POST | Start task |
| `/api/tasks/:id/complete` | POST | Complete task |
| `/api/tasks/:id/fail` | POST | Fail task |
| `/api/tasks/:id/cancel` | POST | Cancel task |
| `/api/users/:id/tasks` | GET | Get user's tasks |
| `/queue/stats` | GET | Queue statistics |
| `/tracing/stats` | GET | Tracing statistics |
| `/event-store/stats` | GET | Event store statistics |

---

This appendix provides everything you need to get started with the Orchestrator system. With these tools and commands, you can quickly set up, develop, test, and debug your application.
