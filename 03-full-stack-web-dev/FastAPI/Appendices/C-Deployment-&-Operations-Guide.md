# Appendix C: Deployment & Operations Guide

Welcome to Appendix C of the FastAPI Masterclass series! This comprehensive guide covers everything you need to deploy, operate, and maintain your FastAPI application in production. From environment setup to disaster recovery, this appendix serves as your operations handbook.

## Table of Contents
1. [Production Environment Setup](#production-environment-setup)
2. [Deployment Strategies](#deployment-strategies)
3. [Monitoring & Alerting](#monitoring--alerting)
4. [Logging & Observability](#logging--observability)
5. [Backup & Recovery](#backup--recovery)
6. [Security Hardening](#security-hardening)
7. [Performance Tuning](#performance-tuning)
8. [Troubleshooting Guide](#troubleshooting-guide)
9. [Maintenance Procedures](#maintenance-procedures)
10. [Disaster Recovery Plan](#disaster-recovery-plan)

---

## Production Environment Setup

### System Requirements

**Minimum Production Specifications:**
- CPU: 2+ cores
- RAM: 4GB minimum, 8GB recommended
- Storage: 20GB SSD minimum
- OS: Ubuntu 20.04 LTS or 22.04 LTS
- Database: PostgreSQL 15+
- Cache: Redis 7+
- Message Queue: RabbitMQ 3.11+ (optional)

**Recommended Production Specifications:**
- CPU: 4+ cores
- RAM: 16GB+
- Storage: 100GB+ SSD
- Network: 1 Gbps

### Server Initial Setup Script

**`scripts/server-setup.sh`:**

```bash
#!/bin/bash
# Server initialization script for Ubuntu 20.04/22.04

set -e

echo "🚀 Starting server initialization..."

# ────────────────────────────────────────────────────────────────
# 1. System Updates
# ────────────────────────────────────────────────────────────────
echo "📦 Updating system packages..."
apt-get update && apt-get upgrade -y

# ────────────────────────────────────────────────────────────────
# 2. Install Essential Packages
# ────────────────────────────────────────────────────────────────
echo "📦 Installing essential packages..."
apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    htop \
    net-tools \
    ufw \
    fail2ban

# ────────────────────────────────────────────────────────────────
# 3. Install Docker
# ────────────────────────────────────────────────────────────────
echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# ────────────────────────────────────────────────────────────────
# 4. Install Docker Compose
# ────────────────────────────────────────────────────────────────
echo "🐳 Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# ────────────────────────────────────────────────────────────────
# 5. Install PostgreSQL
# ────────────────────────────────────────────────────────────────
echo "🐘 Installing PostgreSQL..."
apt-get install -y postgresql-15 postgresql-contrib-15
systemctl enable postgresql
systemctl start postgresql

# ────────────────────────────────────────────────────────────────
# 6. Install Redis
# ────────────────────────────────────────────────────────────────
echo "📦 Installing Redis..."
apt-get install -y redis-server
systemctl enable redis-server
systemctl start redis-server

# ────────────────────────────────────────────────────────────────
# 7. Install Nginx
# ────────────────────────────────────────────────────────────────
echo "🌐 Installing Nginx..."
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

# ────────────────────────────────────────────────────────────────
# 8. Install Certbot (SSL)
# ────────────────────────────────────────────────────────────────
echo "🔐 Installing Certbot..."
apt-get install -y certbot python3-certbot-nginx

# ────────────────────────────────────────────────────────────────
# 9. Configure Firewall
# ────────────────────────────────────────────────────────────────
echo "🛡️ Configuring firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# ────────────────────────────────────────────────────────────────
# 10. Set up Fail2ban
# ────────────────────────────────────────────────────────────────
echo "🛡️ Configuring Fail2ban..."
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
systemctl enable fail2ban
systemctl start fail2ban

# ────────────────────────────────────────────────────────────────
# 11. Create Application Directory
# ────────────────────────────────────────────────────────────────
echo "📁 Creating application directory..."
mkdir -p /opt/fastapi-app
chown -R ubuntu:ubuntu /opt/fastapi-app

# ────────────────────────────────────────────────────────────────
# 12. Set up Log Rotation
# ────────────────────────────────────────────────────────────────
echo "📝 Setting up log rotation..."
cat > /etc/logrotate.d/fastapi-app << EOF
/var/log/fastapi-app/*.log {
    daily
    rotate 30
    compress
    delaycompress
    notifempty
    create 0640 ubuntu ubuntu
    sharedscripts
    postrotate
        docker exec fastapi_app kill -HUP 1 2>/dev/null || true
    endscript
}
EOF

echo "✅ Server initialization complete!"
```

### Database Setup

**Create Database and User:**

```sql
-- scripts/create-database.sql
-- Run as postgres user: psql -U postgres -f scripts/create-database.sql

-- Create database
CREATE DATABASE fastapi_db;
CREATE DATABASE fastapi_test;

-- Create user
CREATE USER fastapi_user WITH PASSWORD 'your_secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE fastapi_db TO fastapi_user;
GRANT ALL PRIVILEGES ON DATABASE fastapi_test TO fastapi_user;

-- Enable extensions
\c fastapi_db
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Set search path
ALTER DATABASE fastapi_db SET search_path TO app, public;
```

### Environment Configuration

**`/opt/fastapi-app/.env.production`:**

```env
# ────────────────────────────────────────────────────────────────
# APPLICATION
# ────────────────────────────────────────────────────────────────
APP_NAME=FastAPI Masterclass
APP_VERSION=1.0.0
APP_ENV=production
DEBUG=false

# ────────────────────────────────────────────────────────────────
# DATABASE
# ────────────────────────────────────────────────────────────────
DATABASE_URL=postgresql+asyncpg://fastapi_user:your_secure_password@localhost:5432/fastapi_db
DATABASE_POOL_SIZE=20
DATABASE_MAX_OVERFLOW=40
DATABASE_ECHO=false

# ────────────────────────────────────────────────────────────────
# SECURITY
# ────────────────────────────────────────────────────────────────
SECRET_KEY=your_super_secure_secret_key_at_least_32_chars
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=7

# ────────────────────────────────────────────────────────────────
# REDIS
# ────────────────────────────────────────────────────────────────
REDIS_URL=redis://localhost:6379/0
REDIS_CACHE_EXPIRE=3600

# ────────────────────────────────────────────────────────────────
# CORS
# ────────────────────────────────────────────────────────────────
CORS_ORIGINS=["https://your-domain.com", "https://www.your-domain.com"]
CORS_CREDENTIALS=true

# ────────────────────────────────────────────────────────────────
# RATE LIMITING
# ────────────────────────────────────────────────────────────────
RATE_LIMIT_REQUESTS=50
RATE_LIMIT_PERIOD=60

# ────────────────────────────────────────────────────────────────
# LOGGING
# ────────────────────────────────────────────────────────────────
LOG_LEVEL=WARNING
LOG_FORMAT=json
LOG_FILE=/var/log/fastapi-app/app.log

# ────────────────────────────────────────────────────────────────
# SENTRY
# ────────────────────────────────────────────────────────────────
SENTRY_DSN=https://your-sentry-dsn@sentry.io/12345

# ────────────────────────────────────────────────────────────────
# STORAGE
# ────────────────────────────────────────────────────────────────
STORAGE_TYPE=s3
S3_BUCKET_NAME=your-production-bucket
S3_REGION=us-east-1
S3_ACCESS_KEY=your-access-key
S3_SECRET_KEY=your-secret-key
```

---

## Deployment Strategies

### Blue-Green Deployment with Docker

**`scripts/deploy-blue-green.sh`:**

```bash
#!/bin/bash
# Blue-Green deployment script

set -e

# Configuration
APP_NAME="fastapi-app"
BLUE_PORT=8001
GREEN_PORT=8002
NGINX_CONFIG="/etc/nginx/sites-available/fastapi"

# Determine current active environment
CURRENT_ACTIVE=$(docker ps --filter "name=${APP_NAME}-blue" --format "{{.Names}}" | grep -q . && echo "blue" || echo "green")

# Determine new environment
if [ "$CURRENT_ACTIVE" == "blue" ]; then
    NEW_ENV="green"
    NEW_PORT=$GREEN_PORT
else
    NEW_ENV="blue"
    NEW_PORT=$BLUE_PORT
fi

echo "🔄 Current active: $CURRENT_ACTIVE"
echo "🔄 Deploying to: $NEW_ENV on port $NEW_PORT"

# ────────────────────────────────────────────────────────────────
# 1. Pull latest images
# ────────────────────────────────────────────────────────────────
echo "📦 Pulling latest images..."
docker-compose -f docker-compose.prod.yml pull

# ────────────────────────────────────────────────────────────────
# 2. Deploy new environment
# ────────────────────────────────────────────────────────────────
echo "🚀 Deploying $NEW_ENV..."
export ENV_NAME=$NEW_ENV
export APP_PORT=$NEW_PORT
docker-compose -f docker-compose.prod.yml up -d --scale app=1 --no-recreate

# ────────────────────────────────────────────────────────────────
# 3. Wait for health check
# ────────────────────────────────────────────────────────────────
echo "⏳ Waiting for health check..."
sleep 10

# Check health
for i in {1..30}; do
    if curl -s "http://localhost:$NEW_PORT/health" | grep -q "healthy"; then
        echo "✅ Health check passed!"
        break
    fi
    echo "⏳ Waiting for health... ($i/30)"
    sleep 2
done

# ────────────────────────────────────────────────────────────────
# 4. Update Nginx
# ────────────────────────────────────────────────────────────────
echo "🔀 Updating Nginx configuration..."

cat > $NGINX_CONFIG << EOF
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:$NEW_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Test and reload Nginx
nginx -t && systemctl reload nginx

# ────────────────────────────────────────────────────────────────
# 5. Scale down old environment
# ────────────────────────────────────────────────────────────────
echo "📉 Scaling down $CURRENT_ACTIVE..."
docker-compose -f docker-compose.prod.yml stop ${APP_NAME}-${CURRENT_ACTIVE}
docker-compose -f docker-compose.prod.yml rm -f ${APP_NAME}-${CURRENT_ACTIVE}

echo "✅ Deployment complete! Active: $NEW_ENV"
```

### Canary Deployment with Kubernetes

**`k8s/canary.yaml`:**

```yaml
# k8s/canary.yaml
# Canary deployment configuration

apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastapi-app-canary
  namespace: fastapi-app
  labels:
    app: fastapi-app
    track: canary
spec:
  replicas: 1
  selector:
    matchLabels:
      app: fastapi-app
      track: canary
  template:
    metadata:
      labels:
        app: fastapi-app
        track: canary
    spec:
      containers:
        - name: fastapi-app
          image: ghcr.io/your-username/fastapi-masterclass:canary
          imagePullPolicy: Always
          ports:
            - containerPort: 8000
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: DATABASE_URL
            - name: REDIS_URL
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: REDIS_URL
            - name: SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: fastapi-secrets
                  key: SECRET_KEY
          envFrom:
            - configMapRef:
                name: fastapi-config
          resources:
            requests:
              memory: "256Mi"
              cpu: "250m"
            limits:
              memory: "512Mi"
              cpu: "500m"
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: fastapi-ingress-canary
  namespace: fastapi-app
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "10"
    nginx.ingress.kubernetes.io/canary-by-header: "Canary"
spec:
  rules:
    - host: api.your-domain.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: fastapi-app-canary
                port:
                  number: 8000
```

---

## Monitoring & Alerting

### Prometheus Configuration

**`prometheus/alerts.yml`:**

```yaml
# prometheus/alerts.yml
groups:
  - name: fastapi_alerts
    rules:
      # ──────────────────── HIGH ERROR RATE ────────────────────
      - alert: HighErrorRate
        expr: |
          (sum(rate(http_requests_total{status_code=~"5.."}[5m])) 
          / sum(rate(http_requests_total[5m]))) * 100 > 5
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }}% in the last 5 minutes"

      # ──────────────────── HIGH LATENCY ────────────────────
      - alert: HighLatency
        expr: |
          histogram_quantile(0.95, 
            sum(rate(http_request_duration_seconds_bucket[5m])) by (le, endpoint)
          ) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "95th percentile latency is {{ $value }}s on {{ $labels.endpoint }}"

      # ──────────────────── LOW REQUEST RATE ────────────────────
      - alert: LowRequestRate
        expr: rate(http_requests_total[5m]) < 1
        for: 30m
        labels:
          severity: warning
        annotations:
          summary: "Low request rate detected"
          description: "No requests received in the last 30 minutes"

      # ──────────────────── HIGH DB CONNECTIONS ────────────────────
      - alert: HighDatabaseConnections
        expr: pg_stat_database_numbackends > 100
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High database connections"
          description: "Database connections at {{ $value }}"

      # ──────────────────── LOW DISK SPACE ────────────────────
      - alert: LowDiskSpace
        expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100 < 10
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Low disk space"
          description: "Only {{ $value }}% disk space remaining"

      # ──────────────────── HIGH MEMORY USAGE ────────────────────
      - alert: HighMemoryUsage
        expr: (container_memory_usage_bytes / container_memory_limit_bytes) * 100 > 90
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage at {{ $value }}%"
```

### Grafana Dashboard Configuration

**`grafana/dashboards/fastapi-dashboard.json`:**

```json
{
  "dashboard": {
    "title": "FastAPI Masterclass Monitoring",
    "panels": [
      {
        "id": 1,
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[$interval])",
            "legendFormat": "{{method}} {{endpoint}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "id": 2,
        "title": "Error Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total{status_code=~\"5..\"}[$interval])",
            "legendFormat": "5xx errors"
          },
          {
            "expr": "rate(http_requests_total{status_code=~\"4..\"}[$interval])",
            "legendFormat": "4xx errors"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      },
      {
        "id": 3,
        "title": "Response Time (95th percentile)",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[$interval])) by (le, endpoint))",
            "legendFormat": "{{endpoint}}"
          }
        ],
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 8}
      },
      {
        "id": 4,
        "title": "Database Connections",
        "type": "graph",
        "targets": [
          {
            "expr": "pg_stat_database_numbackends",
            "legendFormat": "connections"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 16}
      },
      {
        "id": 5,
        "title": "Redis Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "redis_memory_used_bytes / 1024 / 1024",
            "legendFormat": "Memory (MB)"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 16}
      },
      {
        "id": 6,
        "title": "Celery Queue Length",
        "type": "graph",
        "targets": [
          {
            "expr": "celery_queues_messages_total",
            "legendFormat": "{{queue}}"
          }
        ],
        "gridPos": {"h": 8, "w": 24, "x": 0, "y": 24}
      }
    ]
  }
}
```

### Alerting Configuration

**`scripts/configure-alerts.sh`:**

```bash
#!/bin/bash
# Configure alerting for monitoring

echo "🔔 Configuring alerts..."

# ────────────────────────────────────────────────────────────────
# Email Alert Configuration
# ────────────────────────────────────────────────────────────────
cat > /etc/alertmanager/config.yml << EOF
route:
  receiver: 'email'
  routes:
    - match:
        severity: critical
      receiver: 'pagerduty'
    - match:
        severity: warning
      receiver: 'slack'

receivers:
  - name: 'email'
    email_configs:
      - to: 'alert@your-domain.com'
        send_resolved: true
        
  - name: 'slack'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/...'
        channel: '#alerts'
        send_resolved: true
        title: 'Alert: {{ .CommonLabels.alertname }}'
        text: '{{ .CommonAnnotations.description }}'
        
  - name: 'pagerduty'
    pagerduty_configs:
      - service_key: 'your-pagerduty-service-key'
        send_resolved: true
EOF

echo "✅ Alerting configured!"
```

---

## Logging & Observability

### Centralized Logging with ELK Stack

**`docker-compose-elk.yml`:**

```yaml
# docker-compose-elk.yml - Elasticsearch, Logstash, Kibana

version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - ES_JAVA_OPTS=-Xms1g -Xmx1g
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    networks:
      - logging_network

  logstash:
    image: docker.elastic.co/logstash/logstash:8.11.0
    container_name: logstash
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
    ports:
      - "5000:5000"
      - "5044:5044"
    environment:
      - xpack.monitoring.enabled=false
    depends_on:
      - elasticsearch
    networks:
      - logging_network

  kibana:
    image: docker.elastic.co/kibana/kibana:8.11.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch
    networks:
      - logging_network

networks:
  logging_network:
    driver: bridge

volumes:
  elasticsearch_data:
```

**`logstash/pipeline/fastapi.conf`:**

```ruby
# logstash/pipeline/fastapi.conf
input {
  beats {
    port => 5044
  }
  tcp {
    port => 5000
    codec => json_lines
  }
}

filter {
  if [service] == "fastapi-app" {
    # Parse JSON logs
    json {
      source => "message"
    }
    
    # Extract fields
    if [level] {
      mutate {
        add_field => { "severity" => "%{[level]}" }
      }
    }
    
    # GeoIP for client IP
    geoip {
      source => "client_ip"
      target => "geoip"
      database => "/usr/share/logstash/GeoLite2-City.mmdb"
    }
    
    # Date parsing
    date {
      match => [ "timestamp", "ISO8601" ]
      target => "@timestamp"
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "fastapi-logs-%{+YYYY.MM.dd}"
    user => "elastic"
    password => "changeme"
  }
}
```

### Structured Logging Configuration

**`app/core/logging.py`** (production version):

```python
from loguru import logger
import sys
import json
from datetime import datetime
import sentry_sdk

def setup_production_logging():
    """Configure production logging with JSON format."""
    
    # Remove default handler
    logger.remove()
    
    # JSON formatter
    def json_formatter(record):
        log_entry = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "level": record["level"].name,
            "message": record["message"],
            "service": "fastapi-app",
            "environment": settings.APP_ENV,
            "version": settings.APP_VERSION,
        }
        
        # Add extra fields
        if "extra" in record:
            for key, value in record["extra"].items():
                if key not in log_entry:
                    log_entry[key] = value
        
        return json.dumps(log_entry) + "\n"
    
    # Console output (JSON)
    logger.add(
        sys.stdout,
        format=json_formatter,
        level=settings.LOG_LEVEL,
    )
    
    # File output (JSON)
    logger.add(
        settings.LOG_FILE,
        rotation="100 MB",
        retention="30 days",
        compression="gz",
        format=json_formatter,
        level=settings.LOG_LEVEL,
    )
    
    # Add correlation ID
    def add_correlation_id(record):
        if hasattr(logger, "correlation_id"):
            record["extra"]["correlation_id"] = logger.correlation_id
        return True
    
    logger.configure(patcher=add_correlation_id)
    
    logger.info("✅ Production logging configured")
```

### Log Aggregation Commands

```bash
# View application logs
docker logs -f fastapi_app

# Tail JSON logs with jq
tail -f /var/log/fastapi-app/app.log | jq '.'

# Search logs by correlation ID
grep "correlation_id: abc-123" /var/log/fastapi-app/app.log

# Count errors by type
grep '"level":"ERROR"' /var/log/fastapi-app/app.log | jq '.error_type' | sort | uniq -c

# Analyze request patterns
jq -r 'select(.method and .endpoint) | "\(.method) \(.endpoint)"' /var/log/fastapi-app/app.log | sort | uniq -c | sort -rn

# Find slow requests
jq -r 'select(.duration > 1) | "\(.duration)s - \(.method) \(.endpoint)"' /var/log/fastapi-app/app.log | sort -rn
```

---

## Backup & Recovery

### Database Backup Script

**`scripts/backup-db.sh`:**

```bash
#!/bin/bash
# Database backup script

set -e

# Configuration
BACKUP_DIR="/backups/postgres"
RETENTION_DAYS=7
S3_BUCKET="your-backup-bucket"
DB_NAME="fastapi_db"
DB_USER="fastapi_user"

# Create backup directory
mkdir -p $BACKUP_DIR

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql.gz"
BACKUP_FILE_ENCRYPTED="$BACKUP_FILE.enc"

echo "📦 Starting database backup..."

# ────────────────────────────────────────────────────────────────
# 1. Dump database
# ────────────────────────────────────────────────────────────────
echo "📤 Dumping database..."
PGPASSWORD=$DB_PASSWORD pg_dump \
    -h localhost \
    -U $DB_USER \
    -d $DB_NAME \
    -F c \
    -Z 9 \
    -f $BACKUP_FILE

# ────────────────────────────────────────────────────────────────
# 2. Encrypt backup
# ────────────────────────────────────────────────────────────────
echo "🔐 Encrypting backup..."
openssl enc -aes-256-cbc \
    -salt \
    -in $BACKUP_FILE \
    -out $BACKUP_FILE_ENCRYPTED \
    -pass pass:$ENCRYPTION_KEY

# ────────────────────────────────────────────────────────────────
# 3. Upload to S3
# ────────────────────────────────────────────────────────────────
echo "☁️ Uploading to S3..."
aws s3 cp $BACKUP_FILE_ENCRYPTED s3://$S3_BUCKET/backups/

# ────────────────────────────────────────────────────────────────
# 4. Clean old backups
# ────────────────────────────────────────────────────────────────
echo "🧹 Cleaning old backups..."
find $BACKUP_DIR -name "*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete
find $BACKUP_DIR -name "*.sql.gz.enc" -type f -mtime +$RETENTION_DAYS -delete

# ────────────────────────────────────────────────────────────────
# 5. Send notification
# ────────────────────────────────────────────────────────────────
echo "📧 Sending notification..."
curl -X POST https://hooks.slack.com/services/... \
    -H "Content-Type: application/json" \
    -d "{\"text\": \"✅ Database backup completed: $BACKUP_FILE_ENCRYPTED\"}"

echo "✅ Backup complete: $BACKUP_FILE_ENCRYPTED"
```

### Database Recovery Script

**`scripts/restore-db.sh`:**

```bash
#!/bin/bash
# Database recovery script

set -e

# Configuration
BACKUP_FILE=$1
DB_NAME="fastapi_db"
DB_USER="fastapi_user"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup-file>"
    exit 1
fi

echo "🔄 Starting database restore..."

# ────────────────────────────────────────────────────────────────
# 1. Decrypt backup
# ────────────────────────────────────────────────────────────────
echo "🔓 Decrypting backup..."
TEMP_FILE=$(mktemp)
openssl enc -d -aes-256-cbc \
    -in $BACKUP_FILE \
    -out $TEMP_FILE \
    -pass pass:$ENCRYPTION_KEY

# ────────────────────────────────────────────────────────────────
# 2. Drop and recreate database
# ────────────────────────────────────────────────────────────────
echo "🗑️ Dropping and recreating database..."
PGPASSWORD=$DB_PASSWORD dropdb -h localhost -U $DB_USER $DB_NAME
PGPASSWORD=$DB_PASSWORD createdb -h localhost -U $DB_USER $DB_NAME

# ────────────────────────────────────────────────────────────────
# 3. Restore database
# ────────────────────────────────────────────────────────────────
echo "📥 Restoring database..."
PGPASSWORD=$DB_PASSWORD pg_restore \
    -h localhost \
    -U $DB_USER \
    -d $DB_NAME \
    -F c \
    -c \
    $TEMP_FILE

# ────────────────────────────────────────────────────────────────
# 4. Cleanup
# ────────────────────────────────────────────────────────────────
rm $TEMP_FILE

# ────────────────────────────────────────────────────────────────
# 5. Run migrations (ensure schema is up to date)
# ────────────────────────────────────────────────────────────────
echo "📦 Running migrations..."
alembic upgrade head

echo "✅ Restore complete"
```

### Automated Backup Cron Job

```bash
# /etc/cron.d/fastapi-backup
# Run database backup daily at 2 AM
0 2 * * * ubuntu /opt/fastapi-app/scripts/backup-db.sh >> /var/log/fastapi-backup.log 2>&1

# Run database backup weekly to a separate location
0 3 * * 0 ubuntu /opt/fastapi-app/scripts/backup-db.sh weekly >> /var/log/fastapi-backup.log 2>&1
```

---

## Security Hardening

### SSL/TLS Configuration

**`scripts/configure-ssl.sh`:**

```bash
#!/bin/bash
# SSL configuration script

# ────────────────────────────────────────────────────────────────
# 1. Obtain SSL Certificate
# ────────────────────────────────────────────────────────────────
echo "🔐 Obtaining SSL certificate..."
certbot --nginx -d your-domain.com -d www.your-domain.com \
    --non-interactive \
    --agree-tos \
    --email admin@your-domain.com

# ────────────────────────────────────────────────────────────────
# 2. Harden SSL Configuration
# ────────────────────────────────────────────────────────────────
echo "🔒 Hardening SSL configuration..."
cat > /etc/nginx/conf.d/ssl.conf << EOF
# SSL configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 1d;
ssl_session_tickets off;

# HSTS
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

# OCSP Stapling
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
EOF

# ────────────────────────────────────────────────────────────────
# 3. Auto-renewal
# ────────────────────────────────────────────────────────────────
echo "🔄 Setting up auto-renewal..."
cat > /etc/cron.d/certbot-renew << EOF
0 0,12 * * * root certbot renew --quiet --post-hook "systemctl reload nginx"
EOF

echo "✅ SSL configuration complete"
```

### Security Headers Configuration

**`nginx/conf.d/security-headers.conf`:**

```nginx
# Security Headers
add_header X-Frame-Options "DENY" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self';" always;
add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=()" always;

# Remove server information
server_tokens off;
proxy_hide_header X-Powered-By;
```

### Fail2ban Configuration

**`/etc/fail2ban/jail.local`:**

```ini
[fastapi-auth]
enabled = true
port = http,https
filter = fastapi-auth
logpath = /var/log/nginx/access.log
maxretry = 5
bantime = 3600
findtime = 600

[fastapi-api]
enabled = true
port = http,https
filter = fastapi-api
logpath = /var/log/fastapi-app/app.log
maxretry = 20
bantime = 3600
findtime = 300
```

**`/etc/fail2ban/filter.d/fastapi-auth.conf`:**

```ini
[Definition]
failregex = ^<HOST> .* "POST /api/v1/auth/login HTTP/.*" 401
ignoreregex =
```

### Security Scanning

```bash
# ────────────────────────────────────────────────────────────────
# Container Security Scanning
# ────────────────────────────────────────────────────────────────
# Scan Docker images for vulnerabilities
docker scan fastapi-app:latest

# Use Trivy for comprehensive scanning
trivy image ghcr.io/your-username/fastapi-masterclass:latest

# ────────────────────────────────────────────────────────────────
# Dependencies Scanning
# ────────────────────────────────────────────────────────────────
# Check Python dependencies for vulnerabilities
safety check -r requirements.txt

# Use pip-audit
pip-audit -r requirements.txt

# ────────────────────────────────────────────────────────────────
# Code Security Scanning
# ────────────────────────────────────────────────────────────────
# Run Bandit
bandit -r app/

# Run Semgrep
semgrep --config=auto app/
```

---

## Performance Tuning

### Database Optimization

**`scripts/optimize-db.sql`:**

```sql
-- Database performance optimization

-- ────────────────────────────────────────────────────────────────
-- 1. Index Management
-- ────────────────────────────────────────────────────────────────

-- Create missing indexes
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_assignee_status ON tasks(assignee_id, status);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_project_status ON tasks(project_id, status);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_tasks_due_date ON tasks(due_date) WHERE status NOT IN ('done', 'archived');
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_projects_owner_status ON projects(owner_id, status);

-- Remove unused indexes
DROP INDEX IF EXISTS idx_old_unused_index;

-- ────────────────────────────────────────────────────────────────
-- 2. Query Optimization
-- ────────────────────────────────────────────────────────────────

-- Analyze tables for query planner
ANALYZE VERBOSE;

-- Find slow queries
SELECT 
    query,
    calls,
    total_time / calls AS avg_time_ms,
    max_time,
    rows
FROM pg_stat_statements
WHERE calls > 100
ORDER BY total_time DESC
LIMIT 20;

-- ────────────────────────────────────────────────────────────────
-- 3. Vacuum Settings
-- ────────────────────────────────────────────────────────────────

-- Configure autovacuum
ALTER SYSTEM SET autovacuum_vacuum_scale_factor = 0.1;
ALTER SYSTEM SET autovacuum_analyze_scale_factor = 0.05;
ALTER SYSTEM SET autovacuum_vacuum_cost_limit = 1000;

-- Manual vacuum for large tables
VACUUM ANALYZE tasks;
VACUUM ANALYZE users;
```

### Redis Optimization

**`redis-production.conf`:**

```conf
# Redis production configuration

# Memory management
maxmemory 1gb
maxmemory-policy allkeys-lru
maxmemory-samples 5

# Save snapshots
save 900 1
save 300 10
save 60 10000

# Performance
tcp-backlog 511
timeout 300
tcp-keepalive 300
io-threads 4
io-threads-do-reads yes

# Persistence
appendonly yes
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# Slow log
slowlog-log-slower-than 10000
slowlog-max-len 128

# Monitoring
redis-cli INFO stats
redis-cli MONITOR
```

### Application Performance Tuning

**`app/core/performance.py`:**

```python
"""
Application performance optimization settings.
"""

from typing import Dict, Any
from functools import lru_cache

# ────────────────────────────────────────────────────────────────
# Connection Pool Settings
# ────────────────────────────────────────────────────────────────

DATABASE_POOL_CONFIG = {
    "pool_size": 20,
    "max_overflow": 40,
    "pool_recycle": 3600,
    "pool_pre_ping": True,
    "pool_timeout": 30,
}

# ────────────────────────────────────────────────────────────────
# Cache Settings
# ────────────────────────────────────────────────────────────────

CACHE_CONFIG = {
    "default_ttl": 300,  # 5 minutes
    "user_ttl": 600,     # 10 minutes
    "task_ttl": 60,      # 1 minute
    "project_ttl": 120,  # 2 minutes
}

# ────────────────────────────────────────────────────────────────
# Rate Limiting Settings
# ────────────────────────────────────────────────────────────────

RATE_LIMIT_CONFIG = {
    "default": {"requests": 100, "period": 60},
    "auth": {"requests": 10, "period": 60},
    "admin": {"requests": 200, "period": 60},
    "upload": {"requests": 5, "period": 60},
}

# ────────────────────────────────────────────────────────────────
# Cache Decorator with TTL
# ────────────────────────────────────────────────────────────────

@lru_cache(maxsize=1000)
def get_user_by_id(user_id: int) -> Optional[Dict]:
    """
    Cached user lookup.
    
    Example: get_user_by_id.cache_clear() to clear cache.
    """
    # Implementation here
    pass

# ────────────────────────────────────────────────────────────────
# Async Worker Settings
# ────────────────────────────────────────────────────────────────

WORKER_CONFIG = {
    "gunicorn": {
        "workers": 4,
        "worker_class": "uvicorn.workers.UvicornWorker",
        "worker_connections": 1000,
        "max_requests": 1000,
        "max_requests_jitter": 100,
        "timeout": 120,
        "graceful_timeout": 30,
    },
    "celery": {
        "worker_concurrency": 4,
        "worker_prefetch_multiplier": 1,
        "task_time_limit": 1800,
        "task_soft_time_limit": 1500,
        "broker_connection_retry_on_startup": True,
    },
}
```

---

## Troubleshooting Guide

### Common Issues & Solutions

**Issue: High Memory Usage**

```bash
# Check container memory usage
docker stats

# Investigate memory leaks
docker exec -it fastapi_app python -c "
import tracemalloc
tracemalloc.start()
# ... run operations ...
snapshot = tracemalloc.take_snapshot()
top_stats = snapshot.statistics('lineno')
for stat in top_stats[:10]:
    print(stat)
"

# Increase memory limit in docker-compose
# services:
#   app:
#     deploy:
#       resources:
#         limits:
#           memory: 2G
```

**Issue: Database Connection Pool Exhaustion**

```bash
# Check active connections
psql -U fastapi_user -d fastapi_db -c "
SELECT pid, usename, application_name, client_addr, state, query 
FROM pg_stat_activity 
WHERE state = 'active';
"

# Increase pool size
# Update DATABASE_POOL_SIZE in .env.production
# Restart application
```

**Issue: Slow Response Times**

```bash
# Enable query logging
# Set DATABASE_ECHO=true in .env.production

# Identify slow endpoints
# Check /metrics endpoint for latency

# Profile in production
docker exec -it fastapi_app python -m cProfile -o /tmp/profile.stats /usr/local/bin/uvicorn app.main:app --workers 1
# Analyze with snakeviz
snakeviz /tmp/profile.stats
```

**Issue: Redis Connection Issues**

```bash
# Check Redis status
redis-cli ping
redis-cli INFO stats

# Check memory usage
redis-cli INFO memory

# Monitor in real-time
redis-cli --stat

# Clear cache if needed
redis-cli flushall
```

**Issue: Celery Worker Not Processing Tasks**

```bash
# Check worker status
celery -A app.core.celery_app inspect active
celery -A app.core.celery_app inspect scheduled
celery -A app.core.celery_app status

# View logs
docker logs -f fastapi_celery_worker

# Check queue size
redis-cli LLEN celery:default

# Restart workers
docker-compose restart celery_worker
```

---

## Maintenance Procedures

### Monthly Maintenance Checklist

```markdown
# Monthly Maintenance Checklist

## Database
- [ ] Run VACUUM ANALYZE on all tables
- [ ] Check for unused indexes
- [ ] Review slow query logs
- [ ] Verify backup integrity
- [ ] Check replication status (if applicable)

## Application
- [ ] Review error logs for patterns
- [ ] Check dependency updates
- [ ] Review performance metrics
- [ ] Check disk space usage
- [ ] Review API usage patterns

## Security
- [ ] Review security logs
- [ ] Check SSL certificate expiry
- [ ] Update security headers
- [ ] Review user permissions
- [ ] Check for new CVEs

## Infrastructure
- [ ] Check server health metrics
- [ ] Review resource utilization
- [ ] Check backup retention
- [ ] Test disaster recovery
- [ ] Review monitoring alerts

## Code
- [ ] Review code coverage reports
- [ ] Check for technical debt
- [ ] Review open issues
- [ ] Plan upcoming features
- [ ] Update documentation
```

### Health Check Script

**`scripts/health-check.sh`:**

```bash
#!/bin/bash
# Comprehensive health check script

set -e

echo "🔍 Running health checks..."

# ────────────────────────────────────────────────────────────────
# 1. Application Health
# ────────────────────────────────────────────────────────────────
echo "📍 Checking application..."
if curl -s -f http://localhost:8000/health | grep -q "healthy"; then
    echo "✅ Application is healthy"
else
    echo "❌ Application is unhealthy"
    exit 1
fi

# ────────────────────────────────────────────────────────────────
# 2. Database Health
# ────────────────────────────────────────────────────────────────
echo "📍 Checking database..."
if PGPASSWORD=$DB_PASSWORD psql -h localhost -U $DB_USER -d $DB_NAME -c "SELECT 1" > /dev/null 2>&1; then
    echo "✅ Database is healthy"
else
    echo "❌ Database is unhealthy"
    exit 1
fi

# ────────────────────────────────────────────────────────────────
# 3. Redis Health
# ────────────────────────────────────────────────────────────────
echo "📍 Checking Redis..."
if redis-cli ping | grep -q "PONG"; then
    echo "✅ Redis is healthy"
else
    echo "❌ Redis is unhealthy"
    exit 1
fi

# ────────────────────────────────────────────────────────────────
# 4. Celery Health
# ────────────────────────────────────────────────────────────────
echo "📍 Checking Celery..."
if celery -A app.core.celery_app status 2>/dev/null | grep -q "OK"; then
    echo "✅ Celery is healthy"
else
    echo "❌ Celery is unhealthy"
    exit 1
fi

# ────────────────────────────────────────────────────────────────
# 5. Disk Space
# ────────────────────────────────────────────────────────────────
echo "📍 Checking disk space..."
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -lt 80 ]; then
    echo "✅ Disk space is healthy ($DISK_USAGE%)"
else
    echo "⚠️ Disk space is low ($DISK_USAGE%)"
fi

# ────────────────────────────────────────────────────────────────
# 6. Memory
# ────────────────────────────────────────────────────────────────
echo "📍 Checking memory..."
MEMORY_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100}' | cut -d. -f1)
if [ $MEMORY_USAGE -lt 80 ]; then
    echo "✅ Memory is healthy ($MEMORY_USAGE%)"
else
    echo "⚠️ Memory is high ($MEMORY_USAGE%)"
fi

echo "✅ All health checks passed!"
```

---

## Disaster Recovery Plan

### Recovery Procedures

**1. Database Recovery**

```bash
# Step 1: Stop application
docker-compose -f docker-compose.prod.yml stop app

# Step 2: Restore database from latest backup
./scripts/restore-db.sh /backups/postgres/fastapi_db_20240115_020000.sql.gz.enc

# Step 3: Verify database integrity
PGPASSWORD=$DB_PASSWORD psql -h localhost -U $DB_USER -d $DB_NAME -c "VACUUM ANALYZE"

# Step 4: Start application
docker-compose -f docker-compose.prod.yml start app

# Step 5: Verify application health
./scripts/health-check.sh
```

**2. Full System Recovery**

```markdown
# Disaster Recovery Runbook

## Scenario: Complete Server Failure

### Phase 1: Infrastructure Recovery
1. Provision new server with same specs
2. Run server-setup.sh script
3. Restore SSL certificates
4. Configure DNS (if needed)

### Phase 2: Application Recovery
1. Clone repository: git clone <repo-url>
2. Copy .env.production from backup
3. Run database restore
4. Deploy application

### Phase 3: Verification
1. Run health checks
2. Verify API endpoints
3. Check monitoring
4. Test backup restoration

### Timeline
- Infrastructure: 30 minutes
- Application: 15 minutes
- Verification: 15 minutes
- Total RTO: ~1 hour
```

**3. Backup Verification**

```bash
#!/bin/bash
# scripts/verify-backup.sh
# Verify backup integrity

echo "🔍 Verifying backup..."

# Test restore to temporary database
TEMP_DB="restore_test_$(date +%s)"
PGPASSWORD=$DB_PASSWORD createdb -h localhost -U $DB_USER $TEMP_DB

# Restore from backup
PGPASSWORD=$DB_PASSWORD pg_restore \
    -h localhost \
    -U $DB_USER \
    -d $TEMP_DB \
    -F c \
    -c \
    /backups/postgres/latest.sql.gz

# Verify data
TABLE_COUNT=$(PGPASSWORD=$DB_PASSWORD psql -h localhost -U $DB_USER -d $TEMP_DB -t -c "SELECT count(*) FROM tasks;")
if [ $TABLE_COUNT -gt 0 ]; then
    echo "✅ Backup verified: $TABLE_COUNT tasks found"
else
    echo "❌ Backup verification failed"
    exit 1
fi

# Cleanup
PGPASSWORD=$DB_PASSWORD dropdb -h localhost -U $DB_USER $TEMP_DB

echo "✅ Backup verification complete"
```

---

## Operations Dashboard

### Quick Reference Commands

```bash
# ──────────────────── DEPLOYMENT ────────────────────
# Deploy new version
docker-compose -f docker-compose.prod.yml up -d --build

# Rollback
docker-compose -f docker-compose.prod.yml up -d --no-build

# Check logs
docker-compose logs -f app

# Scale application
docker-compose up -d --scale app=5

# ──────────────────── MONITORING ────────────────────
# Check system resources
htop
docker stats

# Check logs
tail -f /var/log/fastapi-app/app.log

# Check metrics
curl http://localhost:8000/metrics

# ──────────────────── DATABASE ────────────────────
# Connect to database
psql -U fastapi_user -d fastapi_db

# Check connections
psql -U fastapi_user -d fastapi_db -c "SELECT count(*) FROM pg_stat_activity;"

# Vacuum tables
psql -U fastapi_user -d fastapi_db -c "VACUUM ANALYZE;"

# ──────────────────── REDIS ────────────────────
# Connect to Redis
redis-cli

# Check memory usage
redis-cli INFO memory

# Monitor commands
redis-cli MONITOR

# ──────────────────── CELERY ────────────────────
# Check workers
celery -A app.core.celery_app status

# Inspect tasks
celery -A app.core.celery_app inspect active

# Clear queues
celery -A app.core.celery_app purge -f

# ──────────────────── NGINX ────────────────────
# Check config
nginx -t

# Reload config
systemctl reload nginx

# Check logs
tail -f /var/log/nginx/access.log

# ──────────────────── DOCKER ────────────────────
# Clean resources
docker system prune -af
docker volume prune -f

# List containers
docker ps

# Enter container
docker exec -it fastapi_app /bin/bash

# ──────────────────── BACKUP ────────────────────
# Run backup
./scripts/backup-db.sh

# List backups
ls -la /backups/postgres/

# Restore backup
./scripts/restore-db.sh /backups/postgres/fastapi_db_20240115_020000.sql.gz.enc
```

---

This comprehensive operations guide provides everything you need to run your FastAPI application in production. Use it as a reference for deployment, monitoring, troubleshooting, and maintenance tasks.

**[END OF APPENDIX C]**
