# Appendix G: Environment Variables Reference

**[GENERATED: Appendix G: Environment Variables Reference]**

## Overview

This appendix provides a comprehensive reference for all environment variables used throughout the tutorial series. Each variable includes its purpose, default value, valid options, and which components use it.

---

## Part 1: General Configuration

### Node.js Environment

| Variable | Description | Default | Used By |
|----------|-------------|---------|---------|
| `NODE_ENV` | Runtime environment | `development` | All components |
| `LOG_LEVEL` | Logging verbosity | `info` | All components |

**Valid Values for `NODE_ENV`:**
- `development` — Full logging, source maps
- `staging` — Reduced logging, test environment
- `production` — Minimal logging, optimized

**Valid Values for `LOG_LEVEL`:**
- `debug` — Verbose output
- `info` — General information
- `warn` — Warnings only
- `error` — Errors only

---

## Part 2: MCP Server Configuration

### First Server

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `MCP_SERVER_NAME` | Server identifier | `first-server` | No |
| `MCP_SERVER_VERSION` | Server version | `1.0.0` | No |
| `PORT` | HTTP port (if using HTTP transport) | `3000` | No |

### Database Server (SQLite)

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `MCP_SERVER_NAME` | Server identifier | `database-server` | No |
| `MCP_SERVER_VERSION` | Server version | `1.0.0` | No |
| `DB_PATH` | SQLite database file path | `./data/app.db` | No |
| `DB_READ_ONLY` | Read-only mode | `false` | No |
| `DB_BACKUP_INTERVAL` | Backup interval (ms) | `3600000` | No |
| `DB_MAX_CONNECTIONS` | Connection pool size | `10` | No |
| `DB_QUERY_TIMEOUT` | Query timeout (ms) | `30000` | No |
| `DB_ALLOW_DDL` | Allow DDL operations | `true` | No |
| `DB_ALLOW_DROP` | Allow DROP operations | `false` | No |
| `DB_QUERY_WHITELIST_ENABLED` | Enable query whitelist | `false` | No |
| `DB_QUERY_WHITELIST` | Comma-separated whitelist patterns | `""` | No |
| `DB_QUERY_BLACKLIST_ENABLED` | Enable query blacklist | `true` | No |
| `DB_QUERY_BLACKLIST` | Comma-separated blacklist patterns | `""` | No |

### PostgreSQL Server

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `MCP_SERVER_NAME` | Server identifier | `postgres-server` | No |
| `MCP_SERVER_VERSION` | Server version | `1.0.0` | No |
| `POSTGRES_HOST` | Database host | `localhost` | Yes |
| `POSTGRES_PORT` | Database port | `5432` | Yes |
| `POSTGRES_USER` | Database user | `postgres` | Yes |
| `POSTGRES_PASSWORD` | Database password | `""` | Yes |
| `POSTGRES_DATABASE` | Database name | `postgres` | Yes |
| `POSTGRES_SCHEMA` | Default schema | `public` | No |
| `POSTGRES_SSL` | Enable SSL | `false` | No |
| `POSTGRES_MAX_CONNECTIONS` | Connection pool size | `10` | No |
| `POSTGRES_IDLE_TIMEOUT_MS` | Idle connection timeout (ms) | `10000` | No |
| `POSTGRES_CONNECTION_TIMEOUT_MS` | Connection timeout (ms) | `5000` | No |
| `POSTGRES_MAX_USES` | Max uses per connection | `7500` | No |
| `POSTGRES_READ_ONLY` | Read-only mode | `false` | No |
| `POSTGRES_ALLOW_DDL` | Allow DDL operations | `true` | No |
| `POSTGRES_REQUIRE_CONFIRMATION` | Require confirmation for writes | `true` | No |
| `POSTGRES_QUERY_TIMEOUT_MS` | Query timeout (ms) | `30000` | No |

### Knowledge Server

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `MCP_SERVER_NAME` | Server identifier | `knowledge-server` | No |
| `MCP_SERVER_VERSION` | Server version | `1.0.0` | No |
| `CACHE_TTL` | Cache time-to-live (seconds) | `300` | No |
| `CACHE_MAX_SIZE` | Maximum cache entries | `1000` | No |

**Knowledge Server inherits all PostgreSQL, SQLite, GitHub, and REST API variables.**

### GitHub Adapter

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `GITHUB_TOKEN` | GitHub Personal Access Token | `""` | Yes |
| `GITHUB_OWNER` | Repository owner | `""` | Yes |
| `GITHUB_REPO` | Repository name | `""` | Yes |

**GitHub Token Scopes Required:**
- `repo` — Access to repositories
- `read:org` — Organization information
- `read:user` — User information

### REST API Adapter

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `REST_API_BASE_URL` | API base URL | `""` | Yes |
| `REST_API_KEY` | API key | `""` | No |
| `REST_API_TIMEOUT` | Request timeout (ms) | `30000` | No |

---

## Part 3: MCP Client Configuration

### MCP Client Library

| Variable | Description | Default | Used By |
|----------|-------------|---------|---------|
| `MCP_CLIENT_NAME` | Client identifier | `mcp-client` | Client |
| `MCP_CLIENT_VERSION` | Client version | `1.0.0` | Client |
| `MCP_SERVER_TIMEOUT` | Server connection timeout (ms) | `30000` | Client |
| `MCP_AUTO_RECONNECT` | Auto-reconnect on failure | `true` | Client |
| `MCP_MAX_RECONNECT_ATTEMPTS` | Max reconnection attempts | `5` | Client |

---

## Part 4: AI Agent Configuration

### Research Assistant

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `OPENAI_API_KEY` | OpenAI API key | `""` | Yes |
| `OPENAI_MODEL` | Model to use | `gpt-4-turbo-preview` | No |
| `OPENAI_MAX_TOKENS` | Max tokens per request | `4096` | No |
| `OPENAI_TEMPERATURE` | Response randomness (0-2) | `0.7` | No |
| `MCP_CLIENT_NAME` | Client identifier | `research-assistant` | No |
| `MCP_KNOWLEDGE_SERVER_PATH` | Path to knowledge server | `../../mcp-protocol/servers/knowledge-server/dist/index.js` | No |
| `AGENT_MAX_ITERATIONS` | Max execution iterations | `20` | No |
| `AGENT_MAX_TOOL_CALLS` | Max tool calls per session | `50` | No |
| `AGENT_MEMORY_SIZE` | Short-term memory size | `10` | No |
| `AGENT_MEMORY_LONG_TERM` | Long-term memory size | `1000` | No |
| `AGENT_LOG_LEVEL` | Agent log level | `info` | No |

### Multi-Agent System

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `OPENAI_API_KEY` | OpenAI API key | `""` | Yes |
| `OPENAI_MODEL` | Model to use | `gpt-4-turbo-preview` | No |
| `A2A_AGENT_NAME` | Agent identifier | `coordinator` | No |
| `A2A_AGENT_ROLE` | Agent role | `coordinator` | No |
| `A2A_REGISTRY_PATH` | Registry file path | `./agent-registry.json` | No |
| `A2A_HEARTBEAT_INTERVAL` | Heartbeat interval (ms) | `5000` | No |
| `A2A_MESSAGE_TTL` | Message TTL (ms) | `60000` | No |
| `SUPERVISOR_AGENT_ID` | Supervisor agent ID | `supervisor` | No |

---

## Part 5: A2A Protocol Configuration

### Agent Registry

| Variable | Description | Default | Used By |
|----------|-------------|---------|---------|
| `A2A_REGISTRY_PATH` | Registry storage path | `./agent-registry.json` | Registry |
| `A2A_REGISTRY_CLEANUP_INTERVAL` | Cleanup interval (ms) | `3600000` | Registry |
| `A2A_AGENT_TIMEOUT` | Agent timeout (ms) | `60000` | Registry |

### Message Router

| Variable | Description | Default | Used By |
|----------|-------------|---------|---------|
| `A2A_MESSAGE_QUEUE_SIZE` | Max queue size | `1000` | Router |
| `A2A_MESSAGE_TIMEOUT` | Message delivery timeout (ms) | `30000` | Router |
| `A2A_MAX_RETRIES` | Max delivery retries | `3` | Router |
| `A2A_RETRY_DELAY` | Retry delay (ms) | `1000` | Router |

---

## Part 6: Security Configuration

### Authentication

| Variable | Description | Default | Used By |
|----------|-------------|---------|---------|
| `MCP_AUTH_ENABLED` | Enable authentication | `false` | All MCP servers |
| `MCP_API_KEYS` | Comma-separated API keys | `""` | All MCP servers |
| `MCP_JWT_SECRET` | JWT secret key | `""` | All MCP servers |
| `MCP_AUTH_SKIP_METHODS` | Methods to skip auth | `"initialize"` | All MCP servers |
| `MCP_TOKEN_EXPIRATION` | Token expiration (seconds) | `86400` | All MCP servers |

### Rate Limiting

| Variable | Description | Default | Used By |
|----------|-------------|---------|---------|
| `RATE_LIMIT_ENABLED` | Enable rate limiting | `true` | Gateway/API |
| `RATE_LIMIT_WINDOW_MS` | Rate limit window (ms) | `60000` | Gateway/API |
| `RATE_LIMIT_MAX_REQUESTS` | Max requests per window | `100` | Gateway/API |

### CORS

| Variable | Description | Default | Used By |
|----------|-------------|---------|---------|
| `CORS_ENABLED` | Enable CORS | `true` | Gateway/API |
| `CORS_ALLOWED_ORIGINS` | Comma-separated origins | `"*"` | Gateway/API |

---

## Part 7: Production Configuration

### Docker/Kubernetes

| Variable | Description | Default | Used By |
|----------|-------------|---------|---------|
| `DOCKER_REGISTRY` | Container registry | `ghcr.io` | CI/CD |
| `KUBERNETES_NAMESPACE` | Kubernetes namespace | `ai-platform` | K8s |
| `KUBERNETES_CLUSTER` | Cluster identifier | `prod` | K8s |
| `REPLICA_COUNT` | Default replica count | `3` | K8s |
| `POD_MEMORY_LIMIT` | Memory limit per pod | `1Gi` | K8s |
| `POD_CPU_LIMIT` | CPU limit per pod | `1000m` | K8s |

### Monitoring

| Variable | Description | Default | Used By |
|----------|-------------|---------|---------|
| `PROMETHEUS_ENABLED` | Enable Prometheus | `true` | All components |
| `PROMETHEUS_PORT` | Prometheus metrics port | `9090` | Prometheus |
| `GRAFANA_ENABLED` | Enable Grafana | `true` | Grafana |
| `GRAFANA_PORT` | Grafana port | `3001` | Grafana |
| `GRAFANA_ADMIN_PASSWORD` | Grafana admin password | `admin` | Grafana |
| `ELK_ENABLED` | Enable ELK stack | `true` | ELK |
| `LOGSTASH_HOST` | Logstash host | `logstash` | Logging |
| `LOGSTASH_PORT` | Logstash port | `5000` | Logging |

### Database (Production)

| Variable | Description | Default | Used By |
|----------|-------------|---------|---------|
| `DB_BACKUP_ENABLED` | Enable automatic backups | `true` | Database servers |
| `DB_BACKUP_SCHEDULE` | Backup schedule (cron) | `0 2 * * *` | Database servers |
| `DB_BACKUP_RETENTION` | Backup retention (days) | `30` | Database servers |
| `DB_BACKUP_S3_BUCKET` | S3 bucket for backups | `""` | Database servers |
| `DB_BACKUP_S3_REGION` | S3 region | `us-east-1` | Database servers |
| `DB_BACKUP_S3_ACCESS_KEY` | S3 access key | `""` | Database servers |
| `DB_BACKUP_S3_SECRET_KEY` | S3 secret key | `""` | Database servers |

---

## Part 8: CI/CD Configuration

### GitHub Actions

| Variable | Description | Default | Used By |
|----------|-------------|---------|---------|
| `GITHUB_TOKEN` | GitHub access token | `${{ secrets.GITHUB_TOKEN }}` | CI/CD |
| `REGISTRY` | Container registry URL | `ghcr.io` | CI/CD |
| `IMAGE_NAME` | Image repository name | `${{ github.repository }}` | CI/CD |
| `TAG` | Image tag | `${{ github.sha }}` | CI/CD |
| `KUBECONFIG_STAGING` | Staging kubeconfig | `""` | CI/CD |
| `KUBECONFIG_PRODUCTION` | Production kubeconfig | `""` | CI/CD |
| `TEST_TARGET_URL` | Test target URL | `https://staging.ai-platform.example.com` | CI/CD |

---

## Part 9: Development Environment (.env.example)

### Complete `.env.example` File

```env
# ========================================
# General Configuration
# ========================================
NODE_ENV=development
LOG_LEVEL=info

# ========================================
# MCP Servers
# ========================================

# First Server
MCP_SERVER_NAME=first-server
MCP_SERVER_VERSION=1.0.0
PORT=3000

# Database Server (SQLite)
DB_PATH=./data/app.db
DB_READ_ONLY=false
DB_BACKUP_INTERVAL=3600000
DB_MAX_CONNECTIONS=10
DB_QUERY_TIMEOUT=30000
DB_ALLOW_DDL=true
DB_ALLOW_DROP=false
DB_QUERY_WHITELIST_ENABLED=false
DB_QUERY_BLACKLIST_ENABLED=true

# PostgreSQL Server
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DATABASE=postgres
POSTGRES_SCHEMA=public
POSTGRES_SSL=false
POSTGRES_MAX_CONNECTIONS=10
POSTGRES_IDLE_TIMEOUT_MS=10000
POSTGRES_CONNECTION_TIMEOUT_MS=5000
POSTGRES_MAX_USES=7500
POSTGRES_READ_ONLY=false
POSTGRES_ALLOW_DDL=true
POSTGRES_REQUIRE_CONFIRMATION=true
POSTGRES_QUERY_TIMEOUT_MS=30000

# GitHub Adapter
GITHUB_TOKEN=your_github_pat_here
GITHUB_OWNER=your-org
GITHUB_REPO=your-repo

# REST API Adapter
REST_API_BASE_URL=https://api.example.com
REST_API_KEY=your_api_key
REST_API_TIMEOUT=30000

# Knowledge Server
CACHE_TTL=300
CACHE_MAX_SIZE=1000

# ========================================
# MCP Client
# ========================================
MCP_CLIENT_NAME=mcp-client
MCP_CLIENT_VERSION=1.0.0
MCP_SERVER_TIMEOUT=30000
MCP_AUTO_RECONNECT=true
MCP_MAX_RECONNECT_ATTEMPTS=5

# ========================================
# AI Agents
# ========================================

# OpenAI
OPENAI_API_KEY=your_openai_api_key_here
OPENAI_MODEL=gpt-4-turbo-preview
OPENAI_MAX_TOKENS=4096
OPENAI_TEMPERATURE=0.7

# Research Assistant
MCP_KNOWLEDGE_SERVER_PATH=../../mcp-protocol/servers/knowledge-server/dist/index.js
AGENT_MAX_ITERATIONS=20
AGENT_MAX_TOOL_CALLS=50
AGENT_MEMORY_SIZE=10
AGENT_MEMORY_LONG_TERM=1000

# A2A Protocol
A2A_AGENT_NAME=coordinator
A2A_AGENT_ROLE=coordinator
A2A_REGISTRY_PATH=./agent-registry.json
A2A_HEARTBEAT_INTERVAL=5000
A2A_MESSAGE_TTL=60000
A2A_MESSAGE_QUEUE_SIZE=1000
A2A_MESSAGE_TIMEOUT=30000
A2A_MAX_RETRIES=3
A2A_RETRY_DELAY=1000

# Supervisor Agent
SUPERVISOR_AGENT_ID=supervisor

# ========================================
# Security
# ========================================

# Authentication
MCP_AUTH_ENABLED=false
MCP_API_KEYS=dev_key_123456, dev_key_789012
MCP_JWT_SECRET=your_jwt_secret_here
MCP_AUTH_SKIP_METHODS=initialize
MCP_TOKEN_EXPIRATION=86400

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_WINDOW_MS=60000
RATE_LIMIT_MAX_REQUESTS=100

# CORS
CORS_ENABLED=true
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3001

# ========================================
# Production
# ========================================

# Docker/Kubernetes
DOCKER_REGISTRY=ghcr.io
KUBERNETES_NAMESPACE=ai-platform
KUBERNETES_CLUSTER=prod
REPLICA_COUNT=3
POD_MEMORY_LIMIT=1Gi
POD_CPU_LIMIT=1000m

# Monitoring
PROMETHEUS_ENABLED=true
PROMETHEUS_PORT=9090
GRAFANA_ENABLED=true
GRAFANA_PORT=3001
GRAFANA_ADMIN_PASSWORD=admin
ELK_ENABLED=true
LOGSTASH_HOST=logstash
LOGSTASH_PORT=5000

# Database Backups
DB_BACKUP_ENABLED=true
DB_BACKUP_SCHEDULE=0 2 * * *
DB_BACKUP_RETENTION=30
DB_BACKUP_S3_BUCKET=ai-platform-backups
DB_BACKUP_S3_REGION=us-east-1
DB_BACKUP_S3_ACCESS_KEY=your_s3_access_key
DB_BACKUP_S3_SECRET_KEY=your_s3_secret_key

# ========================================
# CI/CD
# ========================================
TEST_TARGET_URL=https://staging.ai-platform.example.com
```

---

## Part 10: Environment Variable Validation

### Validation Script

```typescript
import { z } from 'zod';

/**
 * Environment variable validation schema
 */
const envSchema = z.object({
  // General
  NODE_ENV: z.enum(['development', 'staging', 'production']).default('development'),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  
  // PostgreSQL
  POSTGRES_HOST: z.string().min(1),
  POSTGRES_PORT: z.string().transform(Number).pipe(z.number().min(1).max(65535)).default('5432'),
  POSTGRES_USER: z.string().min(1),
  POSTGRES_PASSWORD: z.string(),
  POSTGRES_DATABASE: z.string().min(1),
  
  // OpenAI
  OPENAI_API_KEY: z.string().min(1),
  OPENAI_MODEL: z.string().default('gpt-4-turbo-preview'),
  
  // GitHub
  GITHUB_TOKEN: z.string().optional(),
  GITHUB_OWNER: z.string().optional(),
  GITHUB_REPO: z.string().optional(),
  
  // REST API
  REST_API_BASE_URL: z.string().url().optional(),
  REST_API_KEY: z.string().optional(),
  
  // Security
  MCP_AUTH_ENABLED: z.string().transform(v => v === 'true').default('false'),
  MCP_API_KEYS: z.string().optional(),
  MCP_JWT_SECRET: z.string().optional(),
});

/**
 * Validate environment variables
 */
export function validateEnv(): void {
  try {
    envSchema.parse(process.env);
    console.log('✅ Environment variables validated successfully');
  } catch (error) {
    if (error instanceof z.ZodError) {
      console.error('❌ Environment validation failed:');
      for (const issue of error.issues) {
        console.error(`  - ${issue.path.join('.')}: ${issue.message}`);
      }
      process.exit(1);
    }
    throw error;
  }
}

// Use in your application
import dotenv from 'dotenv';
dotenv.config();
validateEnv();
```

---

## Part 11: Environment Variable Security

### Best Practices

1. **Never commit `.env` files** — Always use `.env.example` as a template.

2. **Use different keys per environment**:
   - Development: `dev_key_xxx`
   - Staging: `stg_key_xxx`
   - Production: `prod_key_xxx`

3. **Rotate secrets regularly** — Especially API keys and tokens.

4. **Use secret management in production**:
   - Kubernetes: Use `Secrets` resources
   - AWS: Use `Secrets Manager` or `Parameter Store`
   - Vault: Use HashiCorp Vault

5. **Validate required variables on startup** — Fail fast if missing.

6. **Mask secrets in logs** — Never log raw secrets.

### Secret Masking

```typescript
/**
 * Mask sensitive values in logs
 */
export function maskSecret(value: string): string {
  if (!value) return '[empty]';
  if (value.length < 8) return '[hidden]';
  return `${value.substring(0, 4)}...${value.substring(value.length - 4)}`;
}

// Usage
console.log(`Using API key: ${maskSecret(process.env.OPENAI_API_KEY || '')}`);
console.log(`Database password: ${maskSecret(process.env.POSTGRES_PASSWORD || '')}`);
```

---

## Part 12: Environment Variable Quick Reference

### Essential Variables (Required for Basic Function)

| Variable | Purpose |
|----------|---------|
| `OPENAI_API_KEY` | Required for all AI features |
| `POSTGRES_HOST` | Required for PostgreSQL adapter |
| `POSTGRES_USER` | Required for PostgreSQL adapter |
| `POSTGRES_PASSWORD` | Required for PostgreSQL adapter |
| `POSTGRES_DATABASE` | Required for PostgreSQL adapter |

### Optional But Recommended

| Variable | Purpose |
|----------|---------|
| `GITHUB_TOKEN` | For GitHub integration |
| `REST_API_BASE_URL` | For REST API integration |
| `MCP_API_KEYS` | For authentication |
| `LOG_LEVEL` | For debugging |

### Environment-Specific Overrides

**Development:**
```env
NODE_ENV=development
LOG_LEVEL=debug
MCP_AUTH_ENABLED=false
```

**Staging:**
```env
NODE_ENV=staging
LOG_LEVEL=debug
MCP_AUTH_ENABLED=true
MCP_API_KEYS=stg_key_123,stg_key_456
```

**Production:**
```env
NODE_ENV=production
LOG_LEVEL=info
MCP_AUTH_ENABLED=true
MCP_API_KEYS=prod_key_123,prod_key_456
```

---

This appendix serves as a complete reference for all environment variables used in the tutorial series. Use it when configuring your development environment, setting up CI/CD pipelines, or deploying to production.
