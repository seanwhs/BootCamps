# Appendix C: Deployment and Operations Guide

## Overview

This appendix provides comprehensive guidance for deploying, operating, and maintaining the RAG Agent System in production environments. It covers everything from initial deployment to monitoring, scaling, and disaster recovery.

---

## C.1 Deployment Architectures

### Development Environment

**Purpose**: Local development and testing

```
┌─────────────────────────────────────┐
│         Development Machine         │
├─────────────────────────────────────┤
│  ┌───────────────┐                   │
│  │  API Server   │  Port: 3000      │
│  │  (nodemon)    │                   │
│  └───────────────┘                   │
│  ┌───────────────┐                   │
│  │   PostgreSQL  │  Port: 5432      │
│  │   (Docker)    │                   │
│  └───────────────┘                   │
│  ┌───────────────┐                   │
│  │    Redis      │  Port: 6379      │
│  │   (Docker)    │                   │
│  └───────────────┘                   │
└─────────────────────────────────────┘
```

**Start Command**:
```bash
npm run dev
```

### Staging Environment

**Purpose**: Pre-production testing with production-like setup

```
┌─────────────────────────────────────────────────────┐
│                   Staging Server                    │
├─────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐               │
│  │ API Server 1 │  │ API Server 2 │               │
│  │  (Port 3000) │  │  (Port 3001) │               │
│  └──────────────┘  └──────────────┘               │
│         │                  │                       │
│         └────────┬─────────┘                       │
│                  ▼                                 │
│          ┌──────────────┐                          │
│          │  Nginx LB    │  Port: 80               │
│          │  (Port 80)   │                          │
│          └──────────────┘                          │
│                  │                                 │
│         ┌────────┴────────┐                       │
│         ▼                 ▼                       │
│  ┌──────────────┐  ┌──────────────┐              │
│  │  PostgreSQL  │  │    Redis     │              │
│  │  (Primary)   │  │  (Primary)   │              │
│  └──────────────┘  └──────────────┘              │
│         │                 │                       │
│         ▼                 ▼                       │
│  ┌──────────────┐  ┌──────────────┐              │
│  │  PostgreSQL  │  │    Redis     │              │
│  │  (Replica)   │  │  (Replica)   │              │
│  └──────────────┘  └──────────────┘              │
└─────────────────────────────────────────────────────┘
```

**Start Command**:
```bash
docker-compose -f docker-compose.staging.yml up -d
```

### Production Environment

**Purpose**: High-availability production deployment

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Production Cluster                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    Load Balancer (Nginx/ALB)                 │   │
│  │                    Port: 443 (HTTPS)                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│         ┌────────────────────┼────────────────────┐                │
│         │                    │                    │                │
│         ▼                    ▼                    ▼                │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐         │
│  │  API Server  │   │  API Server  │   │  API Server  │         │
│  │  (Node.js)   │   │  (Node.js)   │   │  (Node.js)   │         │
│  │  Instance 1  │   │  Instance 2  │   │  Instance 3  │         │
│  └──────────────┘   └──────────────┘   └──────────────┘         │
│         │                    │                    │                │
│         └────────────────────┼────────────────────┘                │
│                              │                                      │
│         ┌────────────────────┼────────────────────┐                │
│         │                    │                    │                │
│         ▼                    ▼                    ▼                │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐         │
│  │  PostgreSQL  │   │  PostgreSQL  │   │    Redis     │         │
│  │  (Primary)   │   │  (Replica 1) │   │  (Primary)   │         │
│  │  + pgvector  │   │  + pgvector  │   │              │         │
│  └──────────────┘   └──────────────┘   └──────────────┘         │
│         │                    │                    │                │
│         ▼                    ▼                    ▼                │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐         │
│  │  Worker 1    │   │  Worker 2    │   │  Redis       │         │
│  │  (BullMQ)    │   │  (BullMQ)    │   │  (Replica)   │         │
│  └──────────────┘   └──────────────┘   └──────────────┘         │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                Monitoring Stack                              │   │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐     │   │
│  │  │Prometheus│  │ Grafana │  │  ELK    │  │ Alert-  │     │   │
│  │  │         │  │         │  │ Stack   │  │ manager │     │   │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘     │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## C.2 Environment Configuration

### Production Environment Variables

Create `.env.production`:

```env
# ============================================
# Production Configuration
# ============================================
NODE_ENV=production
PORT=3000
HOST=0.0.0.0
LOG_LEVEL=info
LOG_FORMAT=json

# ============================================
# Database - Use RDS or Cloud SQL
# ============================================
DATABASE_URL=postgresql://user:password@db-primary.region.rds.amazonaws.com:5432/rag_db
PGVECTOR_HOST=db-primary.region.rds.amazonaws.com
PGVECTOR_PORT=5432
PGVECTOR_DATABASE=rag_db
PGVECTOR_USER=user
PGVECTOR_PASSWORD=password
PGVECTOR_POOL_SIZE=20
PGVECTOR_SSL=true

# ============================================
# Redis - Use ElastiCache or Cloud Memorystore
# ============================================
REDIS_URL=redis://:password@redis.region.cache.amazonaws.com:6379
REDIS_HOST=redis.region.cache.amazonaws.com
REDIS_PORT=6379
REDIS_PASSWORD=password
REDIS_TLS=true

# ============================================
# API Configuration
# ============================================
CORS_ORIGIN=https://app.example.com,https://admin.example.com
RATE_LIMIT_MAX=1000
RATE_LIMIT_WINDOW=60000
API_HOST=api.example.com

# ============================================
# OpenAI
# ============================================
OPENAI_API_KEY=${OPENAI_API_KEY}
OPENAI_EMBEDDING_MODEL=text-embedding-3-large
OPENAI_CHAT_MODEL=gpt-4o
OPENAI_API_BASE=https://api.openai.com/v1

# ============================================
# Security
# ============================================
JWT_SECRET=${JWT_SECRET}
JWT_EXPIRY=7d
SESSION_TIMEOUT=3600
ENABLE_HTTPS=true
ENABLE_CORS=true

# ============================================
# Monitoring
# ============================================
PROMETHEUS_ENABLED=true
PROMETHEUS_PORT=9090
ENABLE_TELEMETRY=true
TELEMETRY_EXPORT_INTERVAL=60000

# ============================================
# Feature Flags
# ============================================
ENABLE_STREAMING=true
ENABLE_BATCH_PROCESSING=true
ENABLE_CACHE=true
ENABLE_CHECKPOINTING=true
ENABLE_HITL=true
```

### Staging Environment Variables

Create `.env.staging`:

```env
# ============================================
# Staging Configuration
# ============================================
NODE_ENV=staging
PORT=3000
LOG_LEVEL=debug
LOG_FORMAT=pretty

# Similar to production but with staging resources
DATABASE_URL=postgresql://user:password@db-staging.region.rds.amazonaws.com:5432/rag_db
REDIS_URL=redis://redis-staging.region.cache.amazonaws.com:6379

# Use cheaper models
OPENAI_CHAT_MODEL=gpt-4o-mini
OPENAI_EMBEDDING_MODEL=text-embedding-3-small

# Enable all features for testing
ENABLE_STREAMING=true
ENABLE_BATCH_PROCESSING=true
ENABLE_CACHE=true
ENABLE_CHECKPOINTING=true
ENABLE_HITL=true
```

---

## C.3 Deployment Scripts

### Deploy Script (deploy.sh)

```bash
#!/bin/bash
# deploy.sh - Production deployment script

set -e

# Configuration
APP_NAME="rag-agent"
DEPLOY_ENV="${1:-production}"
DEPLOY_PATH="/var/www/${APP_NAME}"
BACKUP_PATH="/var/backups/${APP_NAME}"

echo "🚀 Deploying ${APP_NAME} to ${DEPLOY_ENV}"

# 1. Pull latest code
echo "📦 Pulling latest code..."
git pull origin main

# 2. Install dependencies
echo "📦 Installing dependencies..."
npm ci --only=production

# 3. Build application
echo "🔨 Building application..."
npm run build

# 4. Run database migrations
echo "🗄️ Running database migrations..."
NODE_ENV=${DEPLOY_ENV} npx prisma migrate deploy

# 5. Generate Prisma client
echo "🔧 Generating Prisma client..."
npx prisma generate

# 6. Backup current deployment
echo "💾 Backing up current deployment..."
timestamp=$(date +%Y%m%d_%H%M%S)
if [ -d "${DEPLOY_PATH}" ]; then
    mkdir -p "${BACKUP_PATH}"
    tar -czf "${BACKUP_PATH}/${APP_NAME}_${timestamp}.tar.gz" -C "${DEPLOY_PATH}" .
fi

# 7. Deploy new version
echo "📤 Deploying new version..."
mkdir -p "${DEPLOY_PATH}"
cp -r dist "${DEPLOY_PATH}/"
cp -r prisma "${DEPLOY_PATH}/"
cp package.json "${DEPLOY_PATH}/"
cp .env.${DEPLOY_ENV} "${DEPLOY_PATH}/.env"

# 8. Restart services
echo "🔄 Restarting services..."
if command -v pm2 &> /dev/null; then
    pm2 reload ${APP_NAME} || pm2 start dist/app.js --name ${APP_NAME}
else
    systemctl restart ${APP_NAME}
fi

# 9. Health check
echo "🏥 Running health check..."
sleep 10
curl -f http://localhost:3000/health || {
    echo "❌ Health check failed! Rolling back..."
    # Rollback logic
    exit 1
}

echo "✅ Deployment complete!"
```

### Rollback Script (rollback.sh)

```bash
#!/bin/bash
# rollback.sh - Rollback to previous deployment

set -e

APP_NAME="rag-agent"
DEPLOY_PATH="/var/www/${APP_NAME}"
BACKUP_PATH="/var/backups/${APP_NAME}"

echo "⏪ Rolling back ${APP_NAME}"

# List available backups
echo "📂 Available backups:"
ls -lt ${BACKUP_PATH}/${APP_NAME}_*.tar.gz

# Get backup to restore
read -p "Enter backup filename: " BACKUP_FILE

if [ ! -f "${BACKUP_PATH}/${BACKUP_FILE}" ]; then
    echo "❌ Backup file not found!"
    exit 1
fi

# Restore backup
echo "📤 Restoring backup..."
rm -rf ${DEPLOY_PATH}/*
tar -xzf "${BACKUP_PATH}/${BACKUP_FILE}" -C "${DEPLOY_PATH}"

# Restart services
echo "🔄 Restarting services..."
pm2 reload ${APP_NAME} || systemctl restart ${APP_NAME}

echo "✅ Rollback complete!"
```

---

## C.4 Monitoring and Observability

### Prometheus Configuration (prometheus.yml)

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'rag-agent'
    static_configs:
      - targets: ['api:3000']
    metrics_path: '/metrics'
    scheme: 'http'

  - job_name: 'postgresql'
    static_configs:
      - targets: ['postgres-exporter:9187']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']
```

### Alert Rules (alerts.yml)

```yaml
groups:
  - name: rag_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} for {{ $labels.job }}"

      - alert: SlowQueries
        expr: histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le)) > 5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Slow queries detected"
          description: "95th percentile query latency is {{ $value }}s"

      - alert: DatabaseConnectionIssues
        expr: pg_stat_database_numbackends < 1
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Database connection issues"
          description: "No database connections available"

      - alert: RedisDown
        expr: redis_connected_clients == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Redis is down"
          description: "Redis instance is not responding"

      - alert: HighMemoryUsage
        expr: process_resident_memory_bytes / 1024^3 > 4
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value }}GB"

      - alert: QueueBacklog
        expr: bull_queue_count > 100
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Queue backlog detected"
          description: "{{ $value }} jobs waiting in queue"
```

### Grafana Dashboard Configuration

```json
{
  "title": "RAG Agent System Dashboard",
  "panels": [
    {
      "title": "Query Volume",
      "type": "graph",
      "targets": [
        {
          "expr": "rate(http_requests_total{path=\"/api/v1/queries\"}[5m])",
          "legendFormat": "Queries per second"
        }
      ]
    },
    {
      "title": "Response Latency",
      "type": "graph",
      "targets": [
        {
          "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))",
          "legendFormat": "P95 Latency"
        },
        {
          "expr": "histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))",
          "legendFormat": "P50 Latency"
        }
      ]
    },
    {
      "title": "Error Rate",
      "type": "graph",
      "targets": [
        {
          "expr": "rate(http_requests_total{status=~\"5..\"}[5m]) / rate(http_requests_total[5m]) * 100",
          "legendFormat": "Error Rate %"
        }
      ]
    },
    {
      "title": "Queue Depth",
      "type": "graph",
      "targets": [
        {
          "expr": "bull_queue_count",
          "legendFormat": "{{ queue }}"
        }
      ]
    },
    {
      "title": "Token Usage",
      "type": "graph",
      "targets": [
        {
          "expr": "rate(tokens_total[5m])",
          "legendFormat": "{{ model }} - {{ type }}"
        }
      ]
    },
    {
      "title": "Agent Status",
      "type": "stat",
      "targets": [
        {
          "expr": "agent_status",
          "legendFormat": "Status"
        }
      ]
    }
  ]
}
```

### Logging Configuration

#### Winston Logger (src/services/logger.ts)

```typescript
import winston from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';

// Production logger with rotation
export const productionLogger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    // Daily rotate file for all logs
    new DailyRotateFile({
      filename: 'logs/application-%DATE%.log',
      datePattern: 'YYYY-MM-DD',
      maxSize: '100m',
      maxFiles: '14d',
      format: winston.format.json(),
    }),
    // Daily rotate file for errors
    new DailyRotateFile({
      filename: 'logs/error-%DATE%.log',
      datePattern: 'YYYY-MM-DD',
      maxSize: '100m',
      maxFiles: '30d',
      level: 'error',
      format: winston.format.json(),
    }),
    // Console output for dev
    ...(process.env.NODE_ENV === 'development' ? [
      new winston.transports.Console({
        format: winston.format.combine(
          winston.format.colorize(),
          winston.format.simple()
        ),
      })
    ] : []),
  ],
});

export const logger = productionLogger;
```

#### Log Rotation (logrotate.conf)

```
/var/www/rag-agent/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        systemctl reload rag-agent > /dev/null 2>&1 || true
    endscript
}
```

---

## C.5 Performance Tuning

### Database Tuning (postgresql.conf)

```conf
# Memory settings
shared_buffers = 2GB
work_mem = 128MB
maintenance_work_mem = 1GB

# Connection settings
max_connections = 200
pool_size = 20

# IO settings
effective_cache_size = 6GB
random_page_cost = 1.1

# Query performance
enable_hashjoin = on
enable_mergejoin = on
enable_indexscan = on
enable_seqscan = off  # Use indexes aggressively

# Logging
log_min_duration_statement = 5000  # Log queries > 5s
log_checkpoints = on
log_connections = on
log_disconnections = on
log_error_verbosity = verbose

# pgvector specific
maintenance_work_mem = 2GB  # For building HNSW indexes
```

### Node.js Tuning

```bash
# Node.js environment variables
export NODE_OPTIONS="--max-old-space-size=4096 --max-semi-space-size=64"
export UV_THREADPOOL_SIZE=16

# For PM2 (ecosystem.config.js)
module.exports = {
  apps: [{
    name: 'rag-agent',
    script: 'dist/app.js',
    instances: 'max', // Use all CPU cores
    exec_mode: 'cluster',
    max_memory_restart: '4G',
    env: {
      NODE_ENV: 'production',
      UV_THREADPOOL_SIZE: 16,
    },
    instance_var: 'INSTANCE_ID',
    error_file: 'logs/pm2-error.log',
    out_file: 'logs/pm2-out.log',
    merge_logs: true,
  }],
};
```

### Connection Pool Configuration

```typescript
// src/services/vector-db.ts
const dbConfig = {
  host: process.env.PGVECTOR_HOST || 'localhost',
  port: parseInt(process.env.PGVECTOR_PORT || '5432'),
  database: process.env.PGVECTOR_DATABASE || 'rag_db',
  user: process.env.PGVECTOR_USER || 'postgres',
  password: process.env.PGVECTOR_PASSWORD || 'postgres',
  max: parseInt(process.env.PGVECTOR_POOL_SIZE || '20'),
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
  ssl: process.env.PGVECTOR_SSL === 'true',
};
```

---

## C.6 Scaling Strategies

### Horizontal Scaling

**API Servers:**
```bash
# Add more API instances
docker-compose up -d --scale api=3

# Or with PM2
pm2 scale rag-agent 3
```

**Workers:**
```bash
# Scale workers for queue processing
docker-compose up -d --scale worker=5

# BullMQ with multiple workers
const worker = new Worker('rag-queue', processor, {
  concurrency: 10,
  connection: {
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT,
    password: process.env.REDIS_PASSWORD,
  },
});
```

### Vertical Scaling

```yaml
# docker-compose.yml - Resource limits
services:
  api:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G
```

### Database Replication

```sql
-- Setup streaming replication
-- Primary: postgresql.conf
wal_level = replica
max_wal_senders = 10
wal_keep_size = 1GB

-- Replica: recovery.conf
primary_conninfo = 'host=primary-ip port=5432 user=replica password=password'
restore_command = 'cp /var/lib/postgresql/archive/%f %p'
```

### Read Replicas

```typescript
// Read/Write splitting
class DatabaseRouter {
  private primary: Pool;
  private replicas: Pool[] = [];

  async query(query: string, values?: any[]) {
    if (query.toLowerCase().startsWith('select')) {
      // Read from replica
      const replica = this.getReplica();
      return replica.query(query, values);
    } else {
      // Write to primary
      return this.primary.query(query, values);
    }
  }
}
```

---

## C.7 Security Best Practices

### Security Checklist

```yaml
Security Checklist:
  ✅ Use environment variables for secrets
  ✅ Enable HTTPS in production
  ✅ Implement rate limiting
  ✅ Use JWT authentication
  ✅ Validate all inputs
  ✅ Sanitize outputs
  ✅ Implement RBAC
  ✅ Enable CORS properly
  ✅ Use security headers (Helmet)
  ✅ Enable database SSL
  ✅ Use Redis TLS
  ✅ Encrypt sensitive data
  ✅ Regular security audits
  ✅ Dependency scanning
  ✅ Container scanning
  ✅ Penetration testing
```

### Security Headers

```typescript
// src/api/server.ts
import helmet from '@fastify/helmet';

await fastify.register(helmet, {
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
    },
  },
  xssFilter: true,
  noSniff: true,
  hidePoweredBy: true,
  frameguard: true,
});
```

### Database Security

```sql
-- Create read-only user for reporting
CREATE USER report_user WITH PASSWORD 'secure_password';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO report_user;

-- Create limited user for API
CREATE USER api_user WITH PASSWORD 'secure_password';
GRANT SELECT, INSERT, UPDATE ON documents, sources TO api_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO api_user;

-- Audit logging
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    table_name TEXT,
    action TEXT,
    user_name TEXT,
    old_data JSONB,
    new_data JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION audit_trigger() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log(table_name, action, user_name, old_data, new_data)
    VALUES (TG_TABLE_NAME, TG_OP, CURRENT_USER, row_to_json(OLD), row_to_json(NEW));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to sensitive tables
CREATE TRIGGER audit_users
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION audit_trigger();
```

---

## C.8 Backup and Disaster Recovery

### Database Backup

```bash
#!/bin/bash
# backup-db.sh - Database backup script

BACKUP_DIR="/var/backups/postgres"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/rag_db_${TIMESTAMP}.sql"

# Create backup
PGPASSWORD=${PGVECTOR_PASSWORD} pg_dump \
  -h ${PGVECTOR_HOST} \
  -U ${PGVECTOR_USER} \
  -d ${PGVECTOR_DATABASE} \
  --clean \
  --if-exists \
  --format=custom \
  > ${BACKUP_FILE}

# Compress
gzip ${BACKUP_FILE}

# Upload to S3
aws s3 cp "${BACKUP_FILE}.gz" "s3://my-bucket/backups/rag_db/"

# Keep local backups for 7 days
find ${BACKUP_DIR} -name "*.gz" -mtime +7 -delete

echo "Backup complete: ${BACKUP_FILE}.gz"
```

### Recovery Script

```bash
#!/bin/bash
# restore-db.sh - Database restore script

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: ./restore-db.sh <backup-file>"
    exit 1
fi

# Drop and recreate database
PGPASSWORD=${PGVECTOR_PASSWORD} psql \
  -h ${PGVECTOR_HOST} \
  -U ${PGVECTOR_USER} \
  -d postgres \
  -c "DROP DATABASE IF EXISTS ${PGVECTOR_DATABASE};"

PGPASSWORD=${PGVECTOR_PASSWORD} psql \
  -h ${PGVECTOR_HOST} \
  -U ${PGVECTOR_USER} \
  -d postgres \
  -c "CREATE DATABASE ${PGVECTOR_DATABASE};"

# Restore from backup
PGPASSWORD=${PGVECTOR_PASSWORD} pg_restore \
  -h ${PGVECTOR_HOST} \
  -U ${PGVECTOR_USER} \
  -d ${PGVECTOR_DATABASE} \
  ${BACKUP_FILE}

echo "Restore complete"
```

### Disaster Recovery Plan

```yaml
Disaster Recovery Plan:
  Recovery Time Objective (RTO): 1 hour
  Recovery Point Objective (RPO): 15 minutes
  
  Steps:
    1. Assess the situation
    2. Notify stakeholders
    3. Restore database from latest backup
    4. Restore application from git tag
    5. Restore checkpoints from backup
    6. Validate system health
    7. Switch to disaster recovery DNS
    8. Investigate root cause
    9. Document incident
    10. Post-mortem and improvements
```

---

## C.9 Maintenance Tasks

### Regular Maintenance

```bash
#!/bin/bash
# maintenance.sh - Regular maintenance tasks

echo "🔧 Running maintenance tasks..."

# 1. Database maintenance
echo "🗄️ Vacuuming database..."
PGPASSWORD=${PGVECTOR_PASSWORD} psql \
  -h ${PGVECTOR_HOST} \
  -U ${PGVECTOR_USER} \
  -d ${PGVECTOR_DATABASE} \
  -c "VACUUM ANALYZE;"

# 2. Clean old checkpoints
echo "🧹 Cleaning old checkpoints..."
node dist/scripts/cleanup.js --maxAge=7d

# 3. Rotate logs
echo "📃 Rotating logs..."
logrotate -f /etc/logrotate.d/rag-agent

# 4. Update dependencies (weekly)
if [ $(date +%u) -eq 1 ]; then
    echo "📦 Checking for updates..."
    npm outdated
fi

# 5. Health check
echo "🏥 Running health check..."
curl -f http://localhost:3000/health || {
    echo "❌ Health check failed!"
    exit 1
}

echo "✅ Maintenance complete!"
```

### Cron Jobs

```cron
# /etc/cron.d/rag-agent

# Backup database daily at 2 AM
0 2 * * * root /var/www/rag-agent/scripts/backup-db.sh

# Run maintenance weekly at 3 AM on Monday
0 3 * * 1 root /var/www/rag-agent/scripts/maintenance.sh

# Clean logs weekly at 4 AM
0 4 * * 0 root /usr/sbin/logrotate /etc/logrotate.d/rag-agent

# Check health every 5 minutes
*/5 * * * * root curl -f http://localhost:3000/health || systemctl restart rag-agent
```

---

## C.10 Troubleshooting Guide

### Common Issues and Solutions

#### Database Connection Issues

**Symptom**: `ECONNREFUSED` errors when connecting to database

**Solutions**:
```bash
# Check if PostgreSQL is running
docker ps | grep postgres
systemctl status postgresql

# Check connection string
echo $DATABASE_URL

# Test connection
psql $DATABASE_URL -c "SELECT 1"

# Increase connection pool size
PGVECTOR_POOL_SIZE=50
```

#### Redis Connection Issues

**Symptom**: Queue jobs not processing

**Solutions**:
```bash
# Check Redis status
redis-cli ping

# Check queue health
redis-cli llen bull:rag-queue:waiting

# Clear stalled jobs
redis-cli del bull:rag-queue:stalled
```

#### OpenAPI Rate Limiting

**Symptom**: `429 Too Many Requests`

**Solutions**:
```bash
# Check current rate limit usage
curl -I http://localhost:3000/api/v1/queries

# Increase rate limit
RATE_LIMIT_MAX=200

# Add API key authentication for higher limits
```

#### Memory Issues

**Symptom**: Process crashes with OOM

**Solutions**:
```bash
# Increase memory limit
export NODE_OPTIONS="--max-old-space-size=8192"

# Check memory usage
pm2 monit

# Debug memory leaks
node --inspect dist/app.js

# Reduce batch sizes
EMBEDDING_BATCH_SIZE=50
RERANKING_BATCH_SIZE=4
```

#### Queue Backlog

**Symptom**: Jobs accumulate in queue

**Solutions**:
```bash
# Increase workers
docker-compose up -d --scale worker=5

# Check worker health
docker-compose logs worker

# Clear stuck jobs
docker-compose exec redis redis-cli del bull:rag-queue:stalled
```

---

## C.11 Performance Benchmarks

### Expected Performance Metrics

| Metric | Value | Notes |
|--------|-------|-------|
| Query Latency (P50) | 200ms | Standard pipeline |
| Query Latency (P95) | 800ms | With agent and reranking |
| Query Latency (P99) | 2s | Complex queries |
| Ingestion Speed | 100 docs/min | With embeddings |
| Concurrent Queries | 50/sec | With caching |
| Worker Throughput | 10 jobs/sec | Per worker |
| Token Usage | 1000 tokens/query | Average |
| Memory Usage | 2-4GB | Depending on load |
| CPU Usage | 40-60% | Under load |

### Load Testing

```bash
#!/bin/bash
# load-test.sh - Load test the API

# Install wrk
apt-get install wrk

# Test query endpoint
wrk -t12 -c400 -d30s \
  -s load-test.lua \
  http://localhost:3000/api/v1/queries

# load-test.lua
request = function()
   local body = '{"query":"What is RAG?","useAgent":false}'
   return wrk.format("POST", "/api/v1/queries", 
     {["Content-Type"] = "application/json"}, body)
end
```

---

## C.12 Production Checklist

### Pre-Deployment Checklist

```yaml
Application:
  ✅ All tests passing
  ✅ Build successful
  ✅ Dependencies scanned for vulnerabilities
  ✅ Feature flags configured correctly
  ✅ Environment variables set
  ✅ Logging configured
  ✅ Monitoring configured
  ✅ Alerts configured

Infrastructure:
  ✅ SSL certificates installed
  ✅ Domain DNS configured
  ✅ Load balancer configured
  ✅ Auto-scaling configured
  ✅ Database backups configured
  ✅ Disaster recovery plan documented
  ✅ Security groups configured
  ✅ Network policies configured

Security:
  ✅ HTTPS enforced
  ✅ Rate limiting configured
  ✅ Authentication implemented
  ✅ Authorization implemented
  ✅ Input validation implemented
  ✅ Output sanitization implemented
  ✅ Security headers set
  ✅ Secrets in environment variables

Operations:
  ✅ Runbooks documented
  ✅ On-call rotation established
  ✅ Monitoring dashboard created
  ✅ Alerts configured
  ✅ Backup tested
  ✅ Recovery tested
  ✅ Logging configured
  ✅ Performance baseline established
```

### Go-Live Check

```bash
#!/bin/bash
# go-live-check.sh - Pre-live verification

echo "🚀 Running go-live checks..."

# 1. Health check
echo "🏥 Health check..."
curl -f http://localhost:3000/health || exit 1

# 2. Database check
echo "🗄️ Database check..."
curl -f http://localhost:3000/api/v1/admin/status | jq '.components.database'

# 3. Redis check
echo "📡 Redis check..."
redis-cli ping

# 4. Index check
echo "📊 BM25 index check..."
curl -f http://localhost:3000/api/v1/admin/index/reload

# 5. Sample query
echo "🔍 Sample query test..."
curl -X POST http://localhost:3000/api/v1/queries \
  -H "Content-Type: application/json" \
  -d '{"query":"What is RAG?"}' | jq '.'

# 6. Agent test
echo "🤖 Agent test..."
curl -X POST http://localhost:3000/api/v1/queries \
  -H "Content-Type: application/json" \
  -d '{"query":"What is RAG?","useAgent":true}' | jq '.'

# 7. Performance check
echo "⏱️ Performance check..."
curl -f http://localhost:3000/metrics

echo "✅ All checks passed! Ready to go live."
```

---

**[APPENDIX C — COMPLETE]**
