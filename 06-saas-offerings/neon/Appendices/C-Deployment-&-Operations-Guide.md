# Serverless Postgres with Neon: From Zero to Production

## Appendix C: Deployment & Operations Guide

### Overview

This comprehensive operations guide covers everything you need to deploy, monitor, maintain, and scale your Neon PostgreSQL application in production. From initial deployment strategies to disaster recovery, this appendix provides battle-tested procedures and best practices.

---

### C.1 Production Deployment Checklist

#### Pre-Deployment Verification

```sql
-- C.1.1 Run pre-deployment validation
\echo '🔍 Running pre-deployment checks...'

-- 1. Check for pending migrations
SELECT 
    version,
    applied_at,
    success,
    error_message
FROM schema_migrations
WHERE success = FALSE
ORDER BY applied_at DESC;

-- 2. Verify all extensions are installed
SELECT 
    extname,
    extversion,
    extrelocatable
FROM pg_extension
WHERE extname IN ('uuid-ossp', 'pg_trgm', 'btree_gin', 'pgcrypto')
ORDER BY extname;

-- 3. Check for missing indexes on foreign keys
SELECT 
    conname AS constraint_name,
    conrelid::regclass AS table_name,
    a.attname AS column_name
FROM pg_constraint c
JOIN pg_attribute a ON a.attnum = ANY(c.conkey) AND a.attrelid = c.conrelid
WHERE c.contype = 'f'
  AND NOT EXISTS (
      SELECT 1 FROM pg_index i
      WHERE i.indrelid = c.conrelid
        AND a.attnum = ANY(i.indkey)
  );

-- 4. Check table sizes and growth trends
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
    pg_size_pretty(pg_indexes_size(schemaname||'.'||tablename)) AS index_size,
    (pg_total_relation_size(schemaname||'.'||tablename) / 1024 / 1024) AS size_mb
FROM pg_tables
WHERE schemaname = 'public'
  AND pg_total_relation_size(schemaname||'.'||tablename) > 10485760  -- > 10MB
ORDER BY size_mb DESC;

-- 5. Check for long-running queries
SELECT 
    pid,
    now() - pg_stat_activity.query_start AS duration,
    query,
    state
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes'
  AND state = 'active';

-- 6. Verify connection pool settings
SHOW max_connections;
SHOW superuser_reserved_connections;

-- 7. Check SSL configuration
SHOW ssl;
SHOW ssl_cert_file;
SHOW ssl_key_file;

-- 8. Verify backup strategy
SELECT 
    backup_name,
    created_at,
    status
FROM backup_log
ORDER BY created_at DESC
LIMIT 5;
```

#### Deployment Steps

```bash
#!/bin/bash
# C.1.2 deploy.sh - Production deployment script

set -e  # Exit on any error

echo "🚀 Starting production deployment..."
echo "=========================================="

# Load environment variables
source .env.production

# 1. Create backup branch
echo "📦 Creating pre-deployment backup..."
BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S)"
neonctl branches create \
    --name "$BACKUP_NAME" \
    --parent main \
    --project-id "$NEON_PROJECT_ID"

# 2. Run migrations on staging branch first
echo "🧪 Testing migrations on staging..."
neonctl branches create \
    --name staging-test \
    --parent main \
    --project-id "$NEON_PROJECT_ID"

STAGING_URL=$(neonctl branches get-connection-string staging-test --project-id "$NEON_PROJECT_ID")

# Run migrations on staging
psql "$STAGING_URL" -f migrations/001_create_users_table.sql
psql "$STAGING_URL" -f migrations/002_create_ecommerce_tables.sql
psql "$STAGING_URL" -f migrations/003_add_wishlists.sql
psql "$STAGING_URL" -f migrations/004_add_inventory_tables.sql

# Run validation on staging
psql "$STAGING_URL" -f scripts/validate_data.sql

# 3. If staging passes, deploy to production
echo "✅ Staging validation passed. Deploying to production..."

# Apply migrations to production
psql "$DATABASE_POOLED_URL" -f migrations/001_create_users_table.sql
psql "$DATABASE_POOLED_URL" -f migrations/002_create_ecommerce_tables.sql
psql "$DATABASE_POOLED_URL" -f migrations/003_add_wishlists.sql
psql "$DATABASE_POOLED_URL" -f migrations/004_add_inventory_tables.sql

# 4. Clean up staging branch
echo "🧹 Cleaning up staging branch..."
neonctl branches delete staging-test --project-id "$NEON_PROJECT_ID"

# 5. Run final validation
echo "🔍 Running final validation..."
psql "$DATABASE_POOLED_URL" -c "SELECT 'Deployment successful!' AS status;"

# 6. Update application
echo "📦 Deploying application..."
# Add your application deployment commands here
# e.g., npm run deploy or docker-compose up -d

echo "=========================================="
echo "✅ Deployment complete!"
echo "📊 Database backup created: $BACKUP_NAME"
```

---

### C.2 Environment Configuration

#### C.2.1 Environment Variables (.env.production)

```bash
# .env.production
# Production environment configuration

# Database Configuration
DATABASE_POOLED_URL="postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require&pool_mode=transaction"
DATABASE_DIRECT_URL="postgresql://username:password@ep-xyz.us-east-1.aws.neon.tech/neondb?sslmode=require"

# Neon Configuration
NEON_PROJECT_ID="your-project-id"
NEON_API_KEY="your-api-key"

# Connection Pool Settings
DB_POOL_MAX=20
DB_POOL_IDLE_TIMEOUT=30000
DB_POOL_CONNECTION_TIMEOUT=2000
DB_POOL_KEEP_ALIVE=true

# SSL Configuration
DB_SSL_MODE=require
DB_SSL_REJECT_UNAUTHORIZED=true

# Query Timeouts
DB_STATEMENT_TIMEOUT=60000
DB_IDLE_TRANSACTION_TIMEOUT=30000

# Monitoring
DB_SLOW_QUERY_THRESHOLD=1000  # milliseconds
DB_HEALTH_CHECK_INTERVAL=30000

# Backup Configuration
BACKUP_ENABLED=true
BACKUP_SCHEDULE="0 2 * * *"  # Daily at 2 AM
BACKUP_RETENTION_DAYS=30

# Logging
LOG_LEVEL=info
LOG_QUERIES=false
LOG_SLOW_QUERIES=true

# Security
DB_PASSWORD_ENCRYPTION=scram-sha-256
DB_ENCRYPTION_KEY="your-encryption-key"
```

#### C.2.2 Docker Compose Configuration

```yaml
# docker-compose.production.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.production
    environment:
      - NODE_ENV=production
      - DATABASE_POOLED_URL=${DATABASE_POOLED_URL}
      - DATABASE_DIRECT_URL=${DATABASE_DIRECT_URL}
      - DB_POOL_MAX=${DB_POOL_MAX}
      - DB_POOL_IDLE_TIMEOUT=${DB_POOL_IDLE_TIMEOUT}
    ports:
      - "3000:3000"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M

  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - app
    restart: unless-stopped
```

#### C.2.3 Kubernetes Deployment

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ecommerce-backend
  namespace: production
  labels:
    app: ecommerce-backend
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: ecommerce-backend
  template:
    metadata:
      labels:
        app: ecommerce-backend
    spec:
      containers:
      - name: app
        image: ecommerce-backend:latest
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_POOLED_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: database-pooled-url
        - name: DB_POOL_MAX
          value: "20"
        - name: NODE_ENV
          value: "production"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "1"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 15
          periodSeconds: 5
        volumeMounts:
        - name: logs
          mountPath: /var/log/app
      volumes:
      - name: logs
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: ecommerce-backend
  namespace: production
spec:
  selector:
    app: ecommerce-backend
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: ecommerce-backend-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: ecommerce-backend
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

---

### C.3 Monitoring & Alerting

#### C.3.1 Database Monitoring Queries

```sql
-- C.3.1.1 Real-time Monitoring View
CREATE OR REPLACE VIEW real_time_monitoring AS
SELECT 
    CURRENT_TIMESTAMP AS checked_at,
    -- Connection metrics
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') AS active_connections,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle') AS idle_connections,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle in transaction') AS idle_in_transaction,
    -- Query performance
    (SELECT COUNT(*) FROM pg_stat_activity WHERE query_start < NOW() - INTERVAL '5 minutes') AS long_running_queries,
    (SELECT COUNT(*) FROM pg_stat_activity WHERE wait_event_type IS NOT NULL) AS waiting_queries,
    -- Table sizes
    pg_size_pretty(pg_database_size(current_database())) AS database_size,
    -- Transaction rates
    (SELECT xact_commit FROM pg_stat_database WHERE datname = current_database()) AS commits,
    (SELECT xact_rollback FROM pg_stat_database WHERE datname = current_database()) AS rollbacks,
    -- Cache hit ratios
    (SELECT 
        ROUND((sum(heap_blks_hit)::numeric / (sum(heap_blks_hit) + sum(heap_blks_read)) * 100), 2)
     FROM pg_statio_user_tables) AS cache_hit_ratio,
    -- Connection utilization
    ROUND(
        (SELECT count(*) FROM pg_stat_activity)::numeric / 
        (SELECT setting::numeric FROM pg_settings WHERE name = 'max_connections') * 100, 
        2
    ) AS connection_utilization;

-- C.3.1.2 Slow Query Logging
CREATE OR REPLACE FUNCTION log_slow_queries()
RETURNS VOID AS $$
DECLARE
    v_slow_query RECORD;
BEGIN
    FOR v_slow_query IN
        SELECT 
            pid,
            usename,
            query,
            EXTRACT(EPOCH FROM (NOW() - query_start))::INTEGER AS duration_seconds,
            state,
            wait_event_type
        FROM pg_stat_activity
        WHERE state = 'active'
          AND NOW() - query_start > INTERVAL '5 seconds'
    LOOP
        -- Insert into slow query log table
        INSERT INTO slow_query_log (
            pid,
            username,
            query_text,
            duration_seconds,
            query_state,
            wait_event,
            logged_at
        ) VALUES (
            v_slow_query.pid,
            v_slow_query.usename,
            v_slow_query.query,
            v_slow_query.duration_seconds,
            v_slow_query.state,
            v_slow_query.wait_event_type,
            CURRENT_TIMESTAMP
        );
        
        -- If query is taking > 30 seconds, raise alert
        IF v_slow_query.duration_seconds > 30 THEN
            PERFORM pg_notify('slow_query_alert', 
                jsonb_build_object(
                    'pid', v_slow_query.pid,
                    'query', v_slow_query.query,
                    'duration', v_slow_query.duration_seconds
                )::text
            );
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Create slow query log table
CREATE TABLE IF NOT EXISTS slow_query_log (
    id BIGSERIAL PRIMARY KEY,
    pid INTEGER,
    username TEXT,
    query_text TEXT,
    duration_seconds INTEGER,
    query_state TEXT,
    wait_event TEXT,
    logged_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index for efficient querying
CREATE INDEX idx_slow_query_log_duration ON slow_query_log(duration_seconds DESC);
CREATE INDEX idx_slow_query_log_logged_at ON slow_query_log(logged_at DESC);

-- Schedule slow query logging (runs every minute)
-- Note: In production, this would be scheduled with pg_cron or external scheduler
-- CREATE EXTENSION IF NOT EXISTS pg_cron;
-- SELECT cron.schedule('log-slow-queries', '* * * * *', 'SELECT log_slow_queries();');
```

#### C.3.2 Application Health Checks

```javascript
// C.3.2.1 Health Check Endpoint
const express = require('express');
const { Pool } = require('pg');
const router = express.Router();

// Health check endpoint
router.get('/health', async (req, res) => {
    const healthChecks = {
        uptime: process.uptime(),
        timestamp: new Date().toISOString(),
        status: 'healthy',
        checks: {}
    };

    try {
        // Database health check
        const pool = new Pool({ connectionString: process.env.DATABASE_POOLED_URL });
        const startTime = Date.now();
        await pool.query('SELECT 1 as health_check');
        const responseTime = Date.now() - startTime;
        
        healthChecks.checks.database = {
            status: 'healthy',
            responseTime: `${responseTime}ms`,
            connections: pool.totalCount,
            idle: pool.idleCount,
            waiting: pool.waitingCount
        };
        await pool.end();
    } catch (error) {
        healthChecks.status = 'unhealthy';
        healthChecks.checks.database = {
            status: 'unhealthy',
            error: error.message
        };
    }

    // Memory usage check
    const memoryUsage = process.memoryUsage();
    healthChecks.checks.memory = {
        used: Math.round(memoryUsage.heapUsed / 1024 / 1024) + 'MB',
        total: Math.round(memoryUsage.heapTotal / 1024 / 1024) + 'MB',
        external: Math.round(memoryUsage.external / 1024 / 1024) + 'MB'
    };

    // CPU usage would require additional monitoring tools

    // Return 200 if healthy, 503 if unhealthy
    const statusCode = healthChecks.status === 'healthy' ? 200 : 503;
    res.status(statusCode).json(healthChecks);
});

// Detailed health check with system metrics
router.get('/health/detailed', async (req, res) => {
    try {
        const pool = new Pool({ connectionString: process.env.DATABASE_POOLED_URL });
        
        // Get detailed database metrics
        const metrics = await pool.query(`
            SELECT 
                (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active') AS active_connections,
                (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'idle') AS idle_connections,
                (SELECT pg_database_size(current_database()) / 1024 / 1024) AS database_size_mb,
                (SELECT 
                    ROUND((sum(heap_blks_hit)::numeric / (sum(heap_blks_hit) + sum(heap_blks_read)) * 100), 2)
                 FROM pg_statio_user_tables) AS cache_hit_ratio,
                (SELECT COUNT(*) FROM slow_query_log WHERE logged_at > NOW() - INTERVAL '1 hour') AS slow_queries_last_hour
        `);

        await pool.end();

        res.json({
            status: 'healthy',
            timestamp: new Date().toISOString(),
            metrics: metrics.rows[0],
            system: {
                memory: process.memoryUsage(),
                uptime: process.uptime(),
                cpu: process.cpuUsage()
            }
        });
    } catch (error) {
        res.status(503).json({
            status: 'unhealthy',
            error: error.message
        });
    }
});

module.exports = router;
```

#### C.3.3 Prometheus Metrics

```javascript
// C.3.3.1 Prometheus Metrics Endpoint
const prometheus = require('prom-client');
const express = require('express');
const router = express.Router();

// Create a Registry
const register = new prometheus.Registry();

// Add default metrics (collects CPU, memory, etc.)
prometheus.collectDefaultMetrics({ register });

// Custom metrics
const dbQueryDuration = new prometheus.Histogram({
    name: 'db_query_duration_seconds',
    help: 'Database query duration in seconds',
    buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 5, 10]
});

const dbQueryErrors = new prometheus.Counter({
    name: 'db_query_errors_total',
    help: 'Total number of database query errors'
});

const activeConnections = new prometheus.Gauge({
    name: 'db_active_connections',
    help: 'Active database connections'
});

const httpRequestsTotal = new prometheus.Counter({
    name: 'http_requests_total',
    help: 'Total HTTP requests',
    labelNames: ['method', 'route', 'status_code']
});

const httpRequestDuration = new prometheus.Histogram({
    name: 'http_request_duration_seconds',
    help: 'HTTP request duration in seconds',
    labelNames: ['method', 'route'],
    buckets: [0.01, 0.05, 0.1, 0.5, 1, 2.5, 5, 10]
});

// Register custom metrics
register.registerMetric(dbQueryDuration);
register.registerMetric(dbQueryErrors);
register.registerMetric(activeConnections);
register.registerMetric(httpRequestsTotal);
register.registerMetric(httpRequestDuration);

// Metrics endpoint
router.get('/metrics', async (req, res) => {
    try {
        res.set('Content-Type', register.contentType);
        res.end(await register.metrics());
    } catch (error) {
        res.status(500).end(error.message);
    }
});

// Middleware to track HTTP requests
function metricsMiddleware(req, res, next) {
    const start = Date.now();
    
    res.on('finish', () => {
        const duration = (Date.now() - start) / 1000;
        const route = req.route ? req.route.path : req.path;
        
        httpRequestsTotal.inc({
            method: req.method,
            route: route || 'unknown',
            status_code: res.statusCode
        });
        
        httpRequestDuration.observe(
            { method: req.method, route: route || 'unknown' },
            duration
        );
    });
    
    next();
}

module.exports = { router, metricsMiddleware, register, dbQueryDuration, dbQueryErrors };
```

#### C.3.4 Alerting Configuration

```yaml
# C.3.4.1 prometheus-alerts.yml
groups:
  - name: database_alerts
    rules:
      # Alert when database is down
      - alert: DatabaseDown
        expr: pg_up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Database {{ $labels.instance }} is down"
          description: "Database has been down for more than 1 minute"
      
      # Alert when connection pool is full
      - alert: DatabaseConnectionPoolFull
        expr: pg_stat_database_numbackends / pg_settings_max_connections > 0.9
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Database connection pool is almost full"
          description: "Connection utilization is {{ $value | humanizePercentage }}"
      
      # Alert on slow queries
      - alert: SlowDatabaseQueries
        expr: rate(pg_stat_statements_mean_exec_time[5m]) > 5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Slow database queries detected"
          description: "Queries are taking more than 5 seconds on average"
      
      # Alert on low cache hit ratio
      - alert: LowCacheHitRatio
        expr: pg_stat_database_blks_hit_rate < 0.95
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Low cache hit ratio"
          description: "Cache hit ratio is {{ $value | humanizePercentage }}"
      
      # Alert on high error rate
      - alert: HighDatabaseErrorRate
        expr: rate(pg_stat_statements_error_count[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High database error rate"
          description: "Error rate is {{ $value }} errors per second"
      
      # Alert on failing database connections
      - alert: DatabaseConnectionFailures
        expr: rate(pg_stat_database_tup_returned[5m]) < 10
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Possible database connection issues"
          description: "Low tuple return rate detected, possible connection problems"

  - name: application_alerts
    rules:
      # Alert on high request latency
      - alert: HighRequestLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High request latency"
          description: "95th percentile request latency is {{ $value }} seconds"
      
      # Alert on high error rate
      - alert: HighErrorRate
        expr: rate(http_requests_total{status_code=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate"
          description: "Error rate is {{ $value | humanizePercentage }}"
      
      # Alert on memory usage
      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value | humanizePercentage }}"
      
      # Alert on CPU usage
      - alert: HighCPUUsage
        expr: rate(node_cpu_seconds_total{mode="user"}[5m]) * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "CPU usage is {{ $value }}%"

  - name: business_alerts
    rules:
      # Alert on low inventory
      - alert: LowInventory
        expr: (inventory_quantity - inventory_reserved_quantity) < inventory_reorder_point
        for: 1h
        labels:
          severity: warning
        annotations:
          summary: "Low inventory detected"
          description: "Product {{ $labels.product_name }} has low inventory"
      
      # Alert on unusual order volume drop
      - alert: OrderVolumeDrop
        expr: rate(orders_total[1h]) < rate(orders_total[24h]) * 0.5
        for: 2h
        labels:
          severity: warning
        annotations:
          summary: "Unusual drop in orders"
          description: "Order volume has dropped by more than 50% compared to 24-hour average"
```

---

### C.4 Backup & Disaster Recovery

#### C.4.1 Automated Backup Script

```bash
#!/bin/bash
# C.4.1 backup.sh - Automated database backup script

set -e

# Load environment variables
source .env.production

# Configuration
BACKUP_DIR="/var/backups/neon"
RETENTION_DAYS=30
BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S)"

echo "📦 Starting database backup: $BACKUP_NAME"
echo "=========================================="

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# 1. Create a branch in Neon (instant backup)
echo "Creating Neon branch backup..."
neonctl branches create \
    --name "$BACKUP_NAME" \
    --parent main \
    --project-id "$NEON_PROJECT_ID"

# 2. Create a full SQL dump
echo "Creating SQL dump..."
pg_dump "$DATABASE_DIRECT_URL" \
    --clean \
    --if-exists \
    --format=custom \
    --file="$BACKUP_DIR/$BACKUP_NAME.dump"

# 3. Create a readable SQL dump (for version control)
echo "Creating readable SQL dump..."
pg_dump "$DATABASE_DIRECT_URL" \
    --clean \
    --if-exists \
    --format=plain \
    --file="$BACKUP_DIR/$BACKUP_NAME.sql"

# 4. Create a schema-only dump
echo "Creating schema-only dump..."
pg_dump "$DATABASE_DIRECT_URL" \
    --schema-only \
    --format=custom \
    --file="$BACKUP_DIR/$BACKUP_NAME-schema.dump"

# 5. Compress the SQL dump
echo "Compressing backups..."
gzip "$BACKUP_DIR/$BACKUP_NAME.sql"

# 6. Create metadata file
cat > "$BACKUP_DIR/$BACKUP_NAME.metadata" << EOF
BACKUP_NAME=$BACKUP_NAME
BACKUP_TIME=$(date -Iseconds)
DATABASE_URL=$DATABASE_DIRECT_URL
PG_VERSION=$(psql "$DATABASE_DIRECT_URL" -t -c "SELECT version();" | tr -d ' ')
BRANCH_NAME=$BACKUP_NAME
FILES:
  - $BACKUP_NAME.dump (custom format)
  - $BACKUP_NAME.sql.gz (compressed SQL)
  - $BACKUP_NAME-schema.dump (schema only)
EOF

# 7. Upload to cloud storage (if configured)
if [ ! -z "$AWS_S3_BUCKET" ]; then
    echo "Uploading to S3..."
    aws s3 sync "$BACKUP_DIR" "s3://$AWS_S3_BUCKET/backups/$(date +%Y-%m-%d)" \
        --exclude "*.metadata" \
        --include "$BACKUP_NAME*"
fi

# 8. Clean up old backups
echo "Cleaning up old backups..."
find "$BACKUP_DIR" -name "backup-*.dump" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "backup-*.sql.gz" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "backup-*.metadata" -mtime +$RETENTION_DAYS -delete

# 9. Log the backup
psql "$DATABASE_DIRECT_URL" -c "
INSERT INTO backup_log (backup_name, created_at, status, notes)
VALUES ('$BACKUP_NAME', CURRENT_TIMESTAMP, 'success', 'Automated backup');
"

echo "=========================================="
echo "✅ Backup complete: $BACKUP_NAME"
echo "📊 Backup location: $BACKUP_DIR"
echo "📈 Total backup size: $(du -sh "$BACKUP_DIR" | cut -f1)"

# 10. Report backup status to monitoring
if [ ! -z "$SLACK_WEBHOOK_URL" ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"✅ Database backup completed successfully: $BACKUP_NAME\"}" \
        "$SLACK_WEBHOOK_URL"
fi
```

#### C.4.2 Disaster Recovery Procedure

```bash
#!/bin/bash
# C.4.2 restore.sh - Database restore script

set -e

# Usage information
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <backup-name>"
    echo "Example: $0 backup-20240101-020000"
    exit 1
fi

BACKUP_NAME=$1
BACKUP_DIR="/var/backups/neon"

echo "🚨 Starting disaster recovery: $BACKUP_NAME"
echo "=========================================="
echo "⚠️  WARNING: This will overwrite the current database!"
echo "Press Ctrl+C to cancel or any key to continue..."
read -n 1 -s

# 1. Verify backup exists
if [ ! -f "$BACKUP_DIR/$BACKUP_NAME.dump" ]; then
    echo "❌ Backup file not found: $BACKUP_DIR/$BACKUP_NAME.dump"
    exit 1
fi

# 2. Create a recovery branch
echo "Creating recovery branch..."
RECOVERY_BRANCH="recovery-$BACKUP_NAME"
neonctl branches create \
    --name "$RECOVERY_BRANCH" \
    --parent "$BACKUP_NAME" \
    --project-id "$NEON_PROJECT_ID"

# 3. Validate recovery branch
echo "Validating recovery branch..."
RECOVERY_URL=$(neonctl branches get-connection-string "$RECOVERY_BRANCH" --project-id "$NEON_PROJECT_ID")

# Run validation queries
psql "$RECOVERY_URL" -c "
SELECT 
    'Users' AS table_name, COUNT(*) AS count FROM users
UNION ALL
SELECT 
    'Products', COUNT(*) FROM products
UNION ALL
SELECT 
    'Orders', COUNT(*) FROM orders;
"

echo "✅ Recovery branch validated!"

# 4. Option to promote recovery branch to main
echo ""
echo "Promote recovery branch to main? (y/n)"
read -n 1 -s CONFIRM

if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
    echo "Promoting recovery branch to main..."
    
    # Take a final backup before promotion
    echo "Creating final backup before promotion..."
    ./backup.sh
    
    # Merge recovery to main
    neonctl branches merge "$RECOVERY_BRANCH" \
        --target main \
        --project-id "$NEON_PROJECT_ID"
    
    echo "✅ Recovery branch promoted to main!"
else
    echo "Recovery branch kept for manual review: $RECOVERY_BRANCH"
    echo "Connection string: $RECOVERY_URL"
fi

echo ""
echo "=========================================="
echo "✅ Disaster recovery completed: $BACKUP_NAME"
echo "🔍 Verify the data before resuming operations"
```

#### C.4.3 Point-in-Time Recovery

```sql
-- C.4.3.1 Point-in-Time Recovery (using Neon's branching)
-- Neon supports PITR by creating a branch at a specific timestamp

-- To restore to a point in time:
-- 1. In Neon Console, go to Branches
-- 2. Click "Create Branch"
-- 3. Select "Point in Time" option
-- 4. Choose the timestamp
-- 5. Name the branch (e.g., pitr-20240101-120000)

-- Verify the restored data
SELECT 
    COUNT(*) AS total_orders,
    SUM(total) AS total_revenue,
    MAX(order_date) AS last_order_date
FROM orders;

-- Compare with current data
SELECT 
    'Current' AS version,
    COUNT(*) AS total_orders,
    SUM(total) AS total_revenue
FROM main.orders
UNION ALL
SELECT 
    'PITR' AS version,
    COUNT(*) AS total_orders,
    SUM(total) AS total_revenue
FROM pitr_branch.orders;
```

---

### C.5 Performance Tuning

#### C.5.1 Database Performance Tuning

```sql
-- C.5.1.1 Analyze Performance Bottlenecks
CREATE OR REPLACE FUNCTION analyze_performance_bottlenecks()
RETURNS TABLE(
    issue_type TEXT,
    description TEXT,
    recommendation TEXT,
    severity TEXT
) AS $$
BEGIN
    -- Check for missing indexes
    RETURN QUERY
    SELECT 
        'Missing Index' AS issue_type,
        'Table ' || relname || ' missing index on foreign key' AS description,
        'CREATE INDEX ON ' || relname || '(' || attname || ')' AS recommendation,
        'HIGH' AS severity
    FROM pg_class
    JOIN pg_constraint ON conrelid = pg_class.oid
    JOIN pg_attribute ON attrelid = pg_class.oid AND attnum = ANY(conkey)
    WHERE contype = 'f'
      AND NOT EXISTS (
          SELECT 1 FROM pg_index 
          WHERE indrelid = pg_class.oid 
            AND attname = ANY(indkey::int[])
      );

    -- Check for unused indexes
    RETURN QUERY
    SELECT 
        'Unused Index' AS issue_type,
        'Index ' || indexname || ' on table ' || tablename || ' has not been used' AS description,
        'DROP INDEX ' || indexname AS recommendation,
        'MEDIUM' AS severity
    FROM pg_stat_user_indexes
    WHERE idx_scan = 0 
      AND schemaname = 'public'
      AND indexname NOT LIKE 'idx_%_gin';  -- Keep GIN indexes

    -- Check for table bloat
    RETURN QUERY
    SELECT 
        'Table Bloat' AS issue_type,
        'Table ' || tablename || ' has significant bloat' AS description,
        'VACUUM FULL ' || tablename || '; REINDEX TABLE ' || tablename AS recommendation,
        CASE 
            WHEN (pg_total_relation_size(schemaname||'.'||tablename) - 
                  pg_relation_size(schemaname||'.'||tablename))::numeric / 
                  pg_total_relation_size(schemaname||'.'||tablename) > 0.3 
            THEN 'HIGH'
            ELSE 'MEDIUM'
        END AS severity
    FROM pg_tables    WHERE schemaname = 'public'
      AND pg_total_relation_size(schemaname||'.'||tablename) > 10485760  -- > 10MB
      AND (pg_total_relation_size(schemaname||'.'||tablename) - 
           pg_relation_size(schemaname||'.'||tablename))::numeric / 
           pg_total_relation_size(schemaname||'.'||tablename) > 0.2;

    -- Check for long-running transactions
    RETURN QUERY
    SELECT 
        'Long Transaction' AS issue_type,
        'Transaction ' || pid || ' running for ' || 
        EXTRACT(EPOCH FROM (NOW() - xact_start))::INTEGER || ' seconds' AS description,
        'COMMIT or ROLLBACK the transaction' AS recommendation,
        'HIGH' AS severity
    FROM pg_stat_activity
    WHERE state = 'idle in transaction'
      AND NOW() - xact_start > INTERVAL '5 minutes';
END;
$$ LANGUAGE plpgsql;

-- Run performance analysis
SELECT * FROM analyze_performance_bottlenecks();
```

#### C.5.2 Query Optimization Template

```sql
-- C.5.2.1 Query Optimization Checklist
-- Use this template to optimize slow queries

/*
1. Identify the query
   - Query: [INSERT QUERY]
   - Execution time: [INSERT TIME]

2. Run EXPLAIN ANALYZE
   - Output: [INSERT EXPLAIN OUTPUT]

3. Analysis
   - Sequential scans? (Look for "Seq Scan")
   - Nested loops on large datasets?
   - Missing indexes?
   - Outdated statistics?

4. Optimization Steps
   a. Add indexes
   b. Rewrite query
   c. Update statistics
   d. Consider materialized views

5. Verify improvement
   - Compare before/after execution times
*/

-- Example optimization:
-- Before: Slow query
EXPLAIN ANALYZE
SELECT 
    u.full_name,
    SUM(o.total) AS total_spent,
    COUNT(DISTINCT o.id) AS order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE o.status IN ('completed', 'shipped')
  AND o.order_date > CURRENT_DATE - INTERVAL '30 days'
  AND u.deleted_at IS NULL
GROUP BY u.id, u.full_name
ORDER BY total_spent DESC;

-- After: Create composite index
CREATE INDEX idx_orders_user_status_date ON orders(user_id, status, order_date DESC);

-- After: Covering index
CREATE INDEX idx_orders_covering ON orders(user_id, order_date) 
INCLUDE (total, status);

-- After: Vacuum and analyze
VACUUM ANALYZE orders;
VACUUM ANALYZE users;

-- Verify improvement
EXPLAIN ANALYZE
SELECT 
    u.full_name,
    SUM(o.total) AS total_spent,
    COUNT(DISTINCT o.id) AS order_count
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE o.status IN ('completed', 'shipped')
  AND o.order_date > CURRENT_DATE - INTERVAL '30 days'
  AND u.deleted_at IS NULL
GROUP BY u.id, u.full_name
ORDER BY total_spent DESC;
```

#### C.5.3 Connection Pool Management

```javascript
// C.5.3.1 Advanced Connection Pool Configuration
const { Pool } = require('pg');

class DatabasePool {
    constructor(config) {
        this.pool = new Pool({
            connectionString: config.connectionString,
            max: config.maxConnections || 20,
            idleTimeoutMillis: config.idleTimeout || 30000,
            connectionTimeoutMillis: config.connectionTimeout || 2000,
            maxUses: config.maxUses || 7500,  // Recycle connections
            keepAlive: true,
            keepAliveInitialDelayMillis: 10000,
            
            // SSL configuration
            ssl: config.ssl || {
                rejectUnauthorized: true,
                ca: config.caCert,
            },
            
            // Statement timeout
            statement_timeout: config.statementTimeout || 60000,
            
            // Application name for monitoring
            application_name: config.applicationName || 'my-app',
            
            // Error handling
            onError: (err, client) => {
                console.error('Database error:', err);
                // Log to monitoring system
                // metrics.dbQueryErrors.inc();
            },
        });

        // Set up event listeners
        this.pool.on('connect', (client) => {
            console.log('New database connection established');
            // Register connection for metrics
            // metrics.activeConnections.inc();
        });

        this.pool.on('acquire', (client) => {
            console.log('Connection acquired from pool');
        });

        this.pool.on('remove', (client) => {
            console.log('Connection removed from pool');
            // metrics.activeConnections.dec();
        });

        this.pool.on('error', (err, client) => {
            console.error('Unexpected error on idle client', err);
            // logError(err);
        });
    }

    // Execute a query with automatic connection handling
    async query(text, params) {
        const start = Date.now();
        const client = await this.pool.connect();
        
        try {
            const result = await client.query(text, params);
            const duration = Date.now() - start;
            
            // Log slow queries
            if (duration > 1000) {
                console.warn('Slow query:', {
                    duration: `${duration}ms`,
                    query: text.substring(0, 200),
                    params: params
                });
                // logSlowQuery(text, duration);
            }
            
            return result;
        } catch (error) {
            // metrics.dbQueryErrors.inc();
            throw error;
        } finally {
            client.release();
        }
    }

    // Transaction helper
    async transaction(callback) {
        const client = await this.pool.connect();
        
        try {
            await client.query('BEGIN');
            const result = await callback(client);
            await client.query('COMMIT');
            return result;
        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    // Health check
    async healthCheck() {
        try {
            const result = await this.query('SELECT 1 as healthy');
            return {
                healthy: true,
                totalConnections: this.pool.totalCount,
                idleConnections: this.pool.idleCount,
                waitingConnections: this.pool.waitingCount,
            };
        } catch (error) {
            return {
                healthy: false,
                error: error.message,
            };
        }
    }

    // Graceful shutdown
    async end() {
        await this.pool.end();
    }

    // Pool metrics
    getMetrics() {
        return {
            total: this.pool.totalCount,
            idle: this.pool.idleCount,
            waiting: this.pool.waitingCount,
            max: this.pool.max,
            created: this.pool.createdCount,
        };
    }
}

module.exports = DatabasePool;
```

---

### C.6 Security Best Practices

#### C.6.1 Database Security Checklist

```sql
-- C.6.1.1 Security Audit Query
CREATE OR REPLACE FUNCTION security_audit()
RETURNS TABLE(
    check_name TEXT,
    status TEXT,
    recommendation TEXT
) AS $$
BEGIN
    -- Check SSL configuration
    RETURN QUERY SELECT 
        'SSL Connection' AS check_name,
        CASE WHEN current_setting('ssl') = 'on' THEN 'PASS' ELSE 'FAIL' END AS status,
        'Ensure SSL is enabled in connection string: sslmode=require' AS recommendation;

    -- Check password encryption
    RETURN QUERY SELECT 
        'Password Encryption' AS check_name,
        CASE WHEN current_setting('password_encryption') = 'scram-sha-256' 
             THEN 'PASS' ELSE 'WARNING' END AS status,
        'Use scram-sha-256 for password encryption' AS recommendation;

    -- Check superuser accounts
    RETURN QUERY SELECT 
        'Superuser Accounts' AS check_name,
        CASE WHEN (SELECT COUNT(*) FROM pg_user WHERE usesuper = true AND usename != 'postgres') = 0
             THEN 'PASS' ELSE 'WARNING' END AS status,
        'Limit superuser accounts' AS recommendation;

    -- Check for users with empty passwords
    RETURN QUERY SELECT 
        'Empty Passwords' AS check_name,
        CASE WHEN (SELECT COUNT(*) FROM pg_shadow WHERE passwd IS NULL) = 0
             THEN 'PASS' ELSE 'FAIL' END AS status,
        'No users should have empty passwords' AS recommendation;

    -- Check for privileged roles
    RETURN QUERY SELECT 
        'Privileged Roles' AS check_name,
        CASE WHEN (SELECT COUNT(*) FROM pg_roles WHERE rolcreaterole = true OR rolcreatedb = true) > 2
             THEN 'WARNING' ELSE 'PASS' END AS status,
        'Limit role creation and database creation privileges' AS recommendation;

    -- Check for public schema permissions
    RETURN QUERY SELECT 
        'Public Schema Permissions' AS check_name,
        CASE WHEN (SELECT has_schema_privilege('public', 'USAGE')) = false
             THEN 'PASS' ELSE 'WARNING' END AS status,
        'Consider restricting public schema usage' AS recommendation;

    -- Check RLS policies (if applicable)
    RETURN QUERY SELECT 
        'Row Level Security' AS check_name,
        CASE WHEN (SELECT COUNT(*) FROM pg_policy) > 0
             THEN 'PASS' ELSE 'INFO' END AS status,
        'Implement RLS for sensitive tables' AS recommendation;

    -- Check for unencrypted connections (in pg_hba.conf)
    RETURN QUERY SELECT 
        'Connection Security' AS check_name,
        CASE WHEN current_setting('ssl') = 'on' 
             THEN 'PASS' ELSE 'WARNING' END AS status,
        'Enforce SSL for all connections' AS recommendation;
END;
$$ LANGUAGE plpgsql;

-- Run security audit
SELECT * FROM security_audit();
```

#### C.6.2 Application Security Configuration

```javascript
// C.6.2.1 Security Middleware
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const cors = require('cors');
const crypto = require('crypto');

// Rate limiting configuration
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.',
    standardHeaders: true,
    legacyHeaders: false,
});

// Sensitive data encryption
const encryption = {
    algorithm: 'aes-256-gcm',
    key: Buffer.from(process.env.ENCRYPTION_KEY || crypto.randomBytes(32), 'hex'),
    
    encrypt(text) {
        const iv = crypto.randomBytes(16);
        const cipher = crypto.createCipheriv(this.algorithm, this.key, iv);
        let encrypted = cipher.update(text, 'utf8', 'hex');
        encrypted += cipher.final('hex');
        const authTag = cipher.getAuthTag();
        return { encrypted, iv: iv.toString('hex'), authTag: authTag.toString('hex') };
    },
    
    decrypt(encrypted, iv, authTag) {
        const decipher = crypto.createDecipheriv(
            this.algorithm, 
            this.key, 
            Buffer.from(iv, 'hex')
        );
        decipher.setAuthTag(Buffer.from(authTag, 'hex'));
        let decrypted = decipher.update(encrypted, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        return decrypted;
    }
};

// Security headers configuration
const securityHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
    'Permissions-Policy': 'geolocation=(), microphone=(), camera=()',
    'Content-Security-Policy': "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self'; img-src 'self' data:;",
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
};

// SQL Injection prevention through parameterized queries
// Always use parameterized queries with pg
const safeQuery = async (pool, text, params) => {
    // Never concatenate user input directly into SQL
    // Use pg's built-in parameterization
    return pool.query(text, params);
};

// Input validation middleware
const validateInput = (schema) => {
    return (req, res, next) => {
        const { error } = schema.validate(req.body);
        if (error) {
            return res.status(400).json({
                error: 'Validation failed',
                details: error.details,
            });
        }
        next();
    };
};

// Apply security middleware
app.use(helmet());
app.use(limiter);
app.use(cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Apply security headers
app.use((req, res, next) => {
    for (const [key, value] of Object.entries(securityHeaders)) {
        res.setHeader(key, value);
    }
    next();
});
```

---

### C.7 Scaling & Capacity Planning

#### C.7.1 Scaling Strategies

```sql
-- C.7.1.1 Capacity Planning Queries
CREATE OR REPLACE VIEW capacity_metrics AS
SELECT 
    'Current' AS metric,
    -- Connection usage
    (SELECT COUNT(*) FROM pg_stat_activity) AS active_connections,
    (SELECT setting::integer FROM pg_settings WHERE name = 'max_connections') AS max_connections,
    -- Storage usage
    pg_size_pretty(pg_database_size(current_database())) AS database_size,
    pg_size_pretty(pg_database_size(current_database()) + 
                   (SELECT sum(pg_total_relation_size(schemaname||'.'||tablename)) 
                    FROM pg_tables WHERE schemaname = 'public')) AS total_with_indexes,
    -- Growth rate (7-day average)
    (SELECT 
        (pg_database_size(current_database()) - 
         (SELECT pg_database_size(current_database()) - 
          sum(pg_wal_lsn_diff(pg_current_wal_lsn(), '0/0')))) / 7
    ) AS avg_daily_growth_bytes,
    -- Table sizes for growth prediction
    (SELECT count(*) FROM orders WHERE order_date > CURRENT_DATE - INTERVAL '7 days') AS orders_last_7_days,
    (SELECT count(*) FROM orders WHERE order_date > CURRENT_DATE - INTERVAL '30 days') AS orders_last_30_days,
    -- Performance metrics
    (SELECT round(avg(EXTRACT(EPOCH FROM (NOW() - query_start)))::numeric, 2)
     FROM pg_stat_activity WHERE state = 'active') AS avg_query_time_seconds,
    (SELECT count(*) FROM pg_stat_activity WHERE state = 'active' AND query_start < NOW() - INTERVAL '5 seconds')
     AS slow_queries_current;

-- Scale prediction
CREATE OR REPLACE FUNCTION predict_scaling_needs(
    days_forward INTEGER DEFAULT 30
)
RETURNS TABLE(
    metric TEXT,
    current_value NUMERIC,
    predicted_value NUMERIC,
    growth_percent NUMERIC,
    action_needed TEXT
) AS $$
DECLARE
    v_daily_growth NUMERIC;
    v_current_size NUMERIC;
BEGIN
    -- Calculate daily growth
    SELECT (pg_database_size(current_database()) - 
            (SELECT pg_database_size(current_database()) - 
             sum(pg_wal_lsn_diff(pg_current_wal_lsn(), '0/0')))) / 7
    INTO v_daily_growth;
    
    -- Current database size
    SELECT pg_database_size(current_database()) INTO v_current_size;
    
    -- Storage prediction
    RETURN QUERY SELECT 
        'Storage (MB)'::TEXT,
        round(v_current_size / 1024 / 1024, 2),
        round((v_current_size + (v_daily_growth * days_forward)) / 1024 / 1024, 2),
        round((v_daily_growth * days_forward / v_current_size) * 100, 2),
        CASE 
            WHEN (v_current_size + (v_daily_growth * 30)) > 10 * 1024 * 1024 * 1024 
            THEN 'Upgrade storage'
            ELSE 'OK'
        END;
    
    -- Connection prediction
    RETURN QUERY SELECT 
        'Connections'::TEXT,
        (SELECT COUNT(*) FROM pg_stat_activity)::NUMERIC,
        ((SELECT COUNT(*) FROM pg_stat_activity) * (1 + (days_forward / 30.0) * 0.1))::NUMERIC,
        (days_forward / 30.0 * 10)::NUMERIC,
        CASE 
            WHEN (SELECT COUNT(*) FROM pg_stat_activity) * 1.2 > 
                 (SELECT setting::numeric FROM pg_settings WHERE name = 'max_connections') 
            THEN 'Increase max_connections'
            ELSE 'OK'
        END;
    
    -- Query performance prediction
    RETURN QUERY SELECT 
        'Avg Query Time (ms)'::TEXT,
        (SELECT round(avg(EXTRACT(EPOCH FROM (NOW() - query_start)) * 1000)::numeric, 2)
         FROM pg_stat_activity WHERE state = 'active'),
        (SELECT round(avg(EXTRACT(EPOCH FROM (NOW() - query_start)) * 1000)::numeric * 1.2, 2)
         FROM pg_stat_activity WHERE state = 'active'),
        20.0,
        CASE 
            WHEN (SELECT avg(EXTRACT(EPOCH FROM (NOW() - query_start)))::numeric
                  FROM pg_stat_activity WHERE state = 'active') > 5 
            THEN 'Optimize queries'
            ELSE 'OK'
        END;
END;
$$ LANGUAGE plpgsql;

-- Run capacity planning
SELECT * FROM predict_scaling_needs(30);
```

#### C.7.2 Neon Scaling Best Practices

```yaml
# C.7.2.1 Neon Scaling Configuration
# Scaling recommendations based on workload

workload_characteristics:
  development:
    compute_size: "0.25"  # vCPU
    memory: "1GB"
    max_connections: 20
    autoscaling: false
    branch_retention: 30  # days
    
  staging:
    compute_size: "0.5"
    memory: "2GB"
    max_connections: 50
    autoscaling: true
    branch_retention: 14
    
  production_small:
    compute_size: "1"
    memory: "4GB"
    max_connections: 100
    autoscaling: true
    min_compute: 1
    max_compute: 4
    branch_retention: 7
    
  production_medium:
    compute_size: "2"
    memory: "8GB"
    max_connections: 200
    autoscaling: true
    min_compute: 2
    max_compute: 8
    branch_retention: 7
    
  production_large:
    compute_size: "4"
    memory: "16GB"
    max_connections: 500
    autoscaling: true
    min_compute: 4
    max_compute: 16
    branch_retention: 7

# Neon connection pooling best practices
connection_pooling:
  serverless:
    pool_mode: "transaction"
    max_pool_size: 10
    idle_timeout: 30  # seconds
    
  api:
    pool_mode: "session"
    max_pool_size: 20
    idle_timeout: 300  # seconds
    
  batch:
    pool_mode: "session"
    max_pool_size: 50
    idle_timeout: 600  # seconds

# Backup strategy
backup_strategy:
  automated:
    schedule: "daily"
    retention: 30  # days
    
  on_demand:
    enabled: true
    retention: 90  # days
    
  pitr:
    enabled: true
    retention: 7  # days
    
  branches:
    enabled: true
    max_branches: 50
    cleanup_threshold: 90  # days
```

---

### C.8 Operations Runbook

#### C.8.1 Common Operations Tasks

```sql
-- C.8.1.1 Daily Operations Checklist

-- 1. Check database health
SELECT * FROM database_health_check;

-- 2. Review slow queries
SELECT 
    pid,
    query,
    EXTRACT(EPOCH FROM (NOW() - query_start))::INTEGER AS duration_seconds
FROM pg_stat_activity
WHERE state = 'active'
  AND NOW() - query_start > INTERVAL '5 seconds'
ORDER BY duration_seconds DESC;

-- 3. Check for failed jobs
SELECT * FROM schema_migrations 
WHERE success = FALSE 
  AND applied_at > CURRENT_DATE - INTERVAL '1 day';

-- 4. Review backup status
SELECT 
    backup_name,
    created_at,
    status
FROM backup_log
ORDER BY created_at DESC
LIMIT 5;

-- 5. Check inventory alerts
SELECT 
    p.name,
    i.quantity,
    i.reorder_point,
    i.quantity - i.reserved_quantity AS available
FROM inventory i
JOIN products p ON i.product_id = p.id
WHERE i.quantity < i.reorder_point
ORDER BY available ASC;

-- 6. Monitor database growth
SELECT 
    pg_size_pretty(pg_database_size(current_database())) AS db_size,
    pg_size_pretty(pg_database_size(current_database()) - 
                   pg_database_size(current_database()) * 0.9) AS growth
FROM pg_database
WHERE datname = current_database();

-- 7. Check for long-running transactions
SELECT 
    pid,
    usename,
    xact_start,
    NOW() - xact_start AS duration,
    state,
    query
FROM pg_stat_activity
WHERE state = 'idle in transaction'
  AND NOW() - xact_start > INTERVAL '5 minutes'
ORDER BY xact_start;

-- 8. Verify replication status (if using replicas)
SELECT 
    application_name,
    state,
    sync_state,
    sent_lsn,
    write_lsn,
    flush_lsn,
    replay_lsn,
    sync_priority,
    replay_lag
FROM pg_stat_replication;
```

#### C.8.2 Emergency Procedures

```bash
#!/bin/bash
# C.8.2.1 emergency-failover.sh
# Emergency failover procedure

echo "🚨 EMERGENCY FAILOVER PROCEDURE"
echo "=========================================="
echo "⚠️  WARNING: This will failover to a backup branch!"
echo "Press Ctrl+C to cancel or any key to continue..."
read -n 1 -s

# Load environment
source .env.production

# 1. Create emergency branch from latest backup
echo "Creating emergency branch..."
EMERGENCY_BRANCH="emergency-$(date +%Y%m%d-%H%M%S)"
neonctl branches create \
    --name "$EMERGENCY_BRANCH" \
    --parent "$(neonctl branches list --project-id "$NEON_PROJECT_ID" | grep backup | head -1 | awk '{print $1}')" \
    --project-id "$NEON_PROJECT_ID"

# 2. Validate emergency branch
echo "Validating emergency branch..."
EMERGENCY_URL=$(neonctl branches get-connection-string "$EMERGENCY_BRANCH" --project-id "$NEON_PROJECT_ID")

# Basic validation
psql "$EMERGENCY_URL" -c "SELECT COUNT(*) FROM users;" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Emergency branch validation failed!"
    exit 1
fi

# 3. Notify team
if [ ! -z "$SLACK_WEBHOOK_URL" ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"🚨 Emergency failover initiated: $EMERGENCY_BRANCH\"}" \
        "$SLACK_WEBHOOK_URL"
fi

# 4. Switch application to use emergency branch
echo "Updating application connection string..."
# Update your application configuration here

# 5. Monitor for recovery
echo "Monitoring for recovery..."
while true; do
    echo "Checking system status..."
    # Add your health check here
    sleep 30
done

# 6. Recover main branch
echo "Recovering main branch..."
# Steps to recover main from emergency branch
```

---

This comprehensive operations guide provides everything you need to deploy, monitor, and maintain your Neon PostgreSQL application in production. Use these procedures, scripts, and checklists to ensure smooth operations and rapid recovery when issues arise.
