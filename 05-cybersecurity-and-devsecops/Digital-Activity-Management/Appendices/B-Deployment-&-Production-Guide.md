# Appendix B: Deployment & Production Guide

Welcome to Appendix B of our Database Activity Management series! This comprehensive guide walks you through deploying your DAM system to production environments, scaling it for high-volume workloads, and maintaining it over time. While the main tutorial focused on building the system, this appendix focuses on **operationalizing** it.

---

## B.1: Production Deployment Checklist

Use this checklist to ensure your DAM system is production-ready:

### Pre-Deployment

- [ ] **Database Migration**: Audit tables created and indexed
- [ ] **Environment Configuration**: All secrets in environment variables
- [ ] **Network Security**: Database connections over TLS/SSL
- [ ] **Access Control**: Restricted access to audit logs and vault
- [ ] **Backup Strategy**: Regular backups configured
- [ ] **Monitoring**: Health checks and metrics implemented
- [ ] **Alerting**: Critical incident notifications configured
- [ ] **Logging**: Structured logging to central aggregator
- [ ] **Performance Testing**: Benchmark results acceptable
- [ ] **Disaster Recovery**: Recovery procedures documented

### Post-Deployment

- [ ] **Health Check**: All components reporting healthy
- [ ] **Audit Logs**: Writing to database successfully
- [ ] **Threat Detection**: Rules loaded and working
- [ ] **Incident Response**: Vault accessible and writable
- [ ] **Notifications**: Test alert received
- [ ] **Circuit Breaker**: Can be triggered and reset
- [ ] **Performance Metrics**: Gathering baseline data
- [ ] **Security Scan**: No vulnerabilities identified

---

## B.2: Deployment Architectures

### Architecture 1: Single Application (Small/Medium)

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Server                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                    Your App                            │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │              DAM System                          │ │ │
│  │  │  ┌──────────┐ ┌──────────┐ ┌──────────┐       │ │ │
│  │  │  │  Audit   │ │  Detect  │ │ Respond  │       │ │ │
│  │  │  └──────────┘ └──────────┘ └──────────┘       │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                            │
         ┌──────────────────┼──────────────────┐
         ▼                  ▼                  ▼
┌─────────────────┐ ┌─────────────────┐ ┌──────────────────┐
│   PostgreSQL    │ │   Audit Logs    │ │ Incident Vault   │
│   (Neon/Cloud)  │ │   (Same DB)     │ │   (JSONL File)   │
└─────────────────┘ └─────────────────┘ └──────────────────┘
```

**When to use:** Small to medium applications (< 1000 req/sec)
**Pros:** Simple, minimal infrastructure
**Cons:** Audit logs in same database, single point of failure

### Architecture 2: Separate Audit Database (Medium/Large)

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Server                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                    Your App                            │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │              DAM System                          │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
        │                                       │
        ▼                                       ▼
┌─────────────────┐                 ┌─────────────────────────┐
│   Application   │                 │     Audit Database       │
│   Database      │                 │  ┌──────────────────┐   │
│   (Primary)     │                 │  │  Audit Tables    │   │
└─────────────────┘                 │  │  Threat Data     │   │
                                    │  │  Statistics      │   │
                                    │  └──────────────────┘   │
                                    └─────────────────────────┘
```

**When to use:** Medium to large applications (1000-10,000 req/sec)
**Pros:** Audit logs separate from application data
**Cons:** Additional database infrastructure

### Architecture 3: Distributed (Large/Enterprise)

```
┌─────────────────────────────────────────────────────────────┐
│                   Load Balancer                              │
└─────────────────────────────────────────────────────────────┘
                            │
         ┌──────────────────┼──────────────────┐
         ▼                  ▼                  ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────────┐
│  App Server 1   │ │  App Server 2   │ │  App Server 3       │
│  ┌────────────┐ │ │  ┌────────────┐ │ │  ┌──────────────┐   │
│  │ DAM System │ │ │  │ DAM System │ │ │  │ DAM System   │   │
│  └────────────┘ │ │  └────────────┘ │ │  └──────────────┘   │
└─────────────────┘ └─────────────────┘ └─────────────────────┘
        │                  │                  │
        └──────────────────┼──────────────────┘
                           ▼
              ┌─────────────────────────────┐
              │   Distributed Audit Store    │
              │  ┌──────────┐ ┌──────────┐  │
              │  │ Kafka/   │ │ Elastic- │  │
              │  │ Streaming│ │ search   │  │
              │  └──────────┘ └──────────┘  │
              │  ┌──────────┐ ┌──────────┐  │
              │  │ Object   │ │ Timescale│  │
              │  │ Storage  │ │ DB       │  │
              │  └──────────┘ └──────────┘  │
              └─────────────────────────────┘
```

**When to use:** Large/Enterprise applications (> 10,000 req/sec)
**Pros:** Scalable, fault-tolerant, high availability
**Cons:** Complex infrastructure

---

## B.3: Environment Configuration

### Node.js/JavaScript

**Production `.env` File:**

```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/db?sslmode=require

# DAM Configuration
DAM_VAULT_PATH=/var/log/dam/incident_vault.jsonl
DAM_ENABLE_AUDIT=true
DAM_ENABLE_DETECTION=true
DAM_ENABLE_RESPONSE=true
DAM_ENABLE_CONSOLE=false
DAM_NOTIFY_SECURITY=true
DAM_CIRCUIT_BREAKER=true
DAM_TERMINATE_CONNECTIONS=true
DAM_REVOKE_CREDENTIALS=false
DAM_COOLDOWN_PERIOD=60000

# Security
DAM_ENCRYPTION_KEY=your-encryption-key
DAM_SLACK_WEBHOOK=https://hooks.slack.com/services/...
DAM_PAGERDUTY_KEY=your-pagerduty-key

# Performance
DAM_POOL_SIZE=20
DAM_CONNECTION_TIMEOUT=5000
DAM_MAX_INCIDENTS_MEMORY=100

# Logging
DAM_LOG_LEVEL=info
DAM_STRUCTURED_LOGGING=true
```

**Production `config.js`:**

```javascript
// config.js
import 'dotenv/config';
import { createRequire } from 'module';
const require = createRequire(import.meta.url);

export const config = {
    database: {
        url: process.env.DATABASE_URL,
        poolSize: parseInt(process.env.DAM_POOL_SIZE) || 20,
        connectionTimeout: parseInt(process.env.DAM_CONNECTION_TIMEOUT) || 5000,
        ssl: { rejectUnauthorized: true }
    },
    
    dam: {
        vaultPath: process.env.DAM_VAULT_PATH || './incident_vault.jsonl',
        enableAudit: process.env.DAM_ENABLE_AUDIT !== 'false',
        enableDetection: process.env.DAM_ENABLE_DETECTION !== 'false',
        enableResponse: process.env.DAM_ENABLE_RESPONSE !== 'false',
        enableConsoleLogging: process.env.DAM_ENABLE_CONSOLE === 'true',
        notifySecurity: process.env.DAM_NOTIFY_SECURITY !== 'false',
        useCircuitBreaker: process.env.DAM_CIRCUIT_BREAKER !== 'false',
        terminateConnections: process.env.DAM_TERMINATE_CONNECTIONS !== 'false',
        revokeCredentials: process.env.DAM_REVOKE_CREDENTIALS === 'true',
        cooldownPeriod: parseInt(process.env.DAM_COOLDOWN_PERIOD) || 60000,
        maxIncidentsMemory: parseInt(process.env.DAM_MAX_INCIDENTS_MEMORY) || 100
    },
    
    security: {
        encryptionKey: process.env.DAM_ENCRYPTION_KEY,
        slackWebhook: process.env.DAM_SLACK_WEBHOOK,
        pagerdutyKey: process.env.DAM_PAGERDUTY_KEY
    },
    
    logging: {
        level: process.env.DAM_LOG_LEVEL || 'info',
        structured: process.env.DAM_STRUCTURED_LOGGING !== 'false'
    }
};
```

### Python

**Production `config.py`:**

```python
# config.py
import os
import json

class DAMConfig:
    def __init__(self):
        # Database
        self.db_path = os.getenv('DAM_DB_PATH', 'dam_database.db')
        
        # DAM Configuration
        self.vault_path = os.getenv('DAM_VAULT_PATH', '/var/log/dam/incident_vault.jsonl')
        self.enable_audit = os.getenv('DAM_ENABLE_AUDIT', 'true').lower() != 'false'
        self.enable_detection = os.getenv('DAM_ENABLE_DETECTION', 'true').lower() != 'false'
        self.enable_response = os.getenv('DAM_ENABLE_RESPONSE', 'true').lower() != 'false'
        self.enable_console_logging = os.getenv('DAM_ENABLE_CONSOLE', 'false').lower() == 'true'
        
        # Security
        self.notify_security = os.getenv('DAM_NOTIFY_SECURITY', 'true').lower() != 'false'
        self.use_circuit_breaker = os.getenv('DAM_CIRCUIT_BREAKER', 'true').lower() != 'false'
        self.terminate_connections = os.getenv('DAM_TERMINATE_CONNECTIONS', 'true').lower() != 'false'
        self.revoke_credentials = os.getenv('DAM_REVOKE_CREDENTIALS', 'false').lower() == 'true'
        
        # Performance
        self.cooldown_period = int(os.getenv('DAM_COOLDOWN_PERIOD', '60000'))
        self.max_incidents_memory = int(os.getenv('DAM_MAX_INCIDENTS_MEMORY', '100'))
        
        # Integrations
        self.slack_webhook = os.getenv('DAM_SLACK_WEBHOOK')
        self.pagerduty_key = os.getenv('DAM_PAGERDUTY_KEY')
        
        # Logging
        self.log_level = os.getenv('DAM_LOG_LEVEL', 'INFO')
        self.structured_logging = os.getenv('DAM_STRUCTURED_LOGGING', 'true').lower() != 'false'
    
    def to_dict(self):
        return {
            'db_path': self.db_path,
            'vault_path': self.vault_path,
            'enable_audit': self.enable_audit,
            'enable_detection': self.enable_detection,
            'enable_response': self.enable_response,
            'enable_console_logging': self.enable_console_logging,
            'notify_security': self.notify_security,
            'use_circuit_breaker': self.use_circuit_breaker,
            'terminate_connections': self.terminate_connections,
            'revoke_credentials': self.revoke_credentials,
            'cooldown_period': self.cooldown_period,
            'max_incidents_memory': self.max_incidents_memory
        }

config = DAMConfig()
```

---

## B.4: Docker Deployment

### Node.js Dockerfile

**File: `Dockerfile`**

```dockerfile
# Node.js DAM System Dockerfile

FROM node:18-alpine

# Install dependencies
RUN apk add --no-cache tzdata

# Set working directory
WORKDIR /app

# Copy package files
COPY javascript/package*.json ./

# Install production dependencies only
RUN npm ci --only=production

# Copy source code
COPY javascript/src ./src
COPY javascript/tests ./tests

# Create directories for logs and vault
RUN mkdir -p /var/log/dam /var/lib/dam

# Set user
USER node

# Environment variables
ENV NODE_ENV=production
ENV DAM_VAULT_PATH=/var/lib/dam/incident_vault.jsonl
ENV DAM_LOG_LEVEL=info

# Expose port if API is enabled
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the application
CMD ["node", "src/index.js"]
```

### Python Dockerfile

**File: `Dockerfile`**

```dockerfile
# Python DAM System Dockerfile

FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements
COPY python/requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY python/*.py ./

# Create directories for logs and vault
RUN mkdir -p /var/log/dam /var/lib/dam

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DAM_VAULT_PATH=/var/lib/dam/incident_vault.jsonl
ENV DAM_LOG_LEVEL=INFO

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD python -c "import sys; import http.client; conn = http.client.HTTPConnection('localhost', 5000); conn.request('GET', '/health'); resp = conn.getresponse(); sys.exit(0 if resp.status == 200 else 1)"

# Start the application
CMD ["python", "main.py"]
```

### Docker Compose

**File: `docker-compose.yml`**

```yaml
version: '3.8'

services:
  # PostgreSQL with audit database
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: dam_user
      POSTGRES_PASSWORD: ${DAM_DB_PASSWORD}
      POSTGRES_DB: dam_audit
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
    networks:
      - dam_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U dam_user"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Node.js DAM System
  node_dam:
    build:
      context: .
      dockerfile: Dockerfile.node
    environment:
      DATABASE_URL: postgresql://dam_user:${DAM_DB_PASSWORD}@postgres:5432/dam_audit?sslmode=disable
      DAM_VAULT_PATH: /var/lib/dam/incident_vault.jsonl
      DAM_NOTIFY_SECURITY: "true"
      DAM_SLACK_WEBHOOK: ${DAM_SLACK_WEBHOOK}
      DAM_LOG_LEVEL: "info"
    volumes:
      - dam_vault:/var/lib/dam
      - dam_logs:/var/log/dam
    ports:
      - "3000:3000"
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - dam_network
    restart: unless-stopped

  # Python DAM System
  python_dam:
    build:
      context: .
      dockerfile: Dockerfile.python
    environment:
      DAM_DB_PATH: /var/lib/dam/dam_database.db
      DAM_VAULT_PATH: /var/lib/dam/incident_vault.jsonl
      DAM_NOTIFY_SECURITY: "true"
      DAM_SLACK_WEBHOOK: ${DAM_SLACK_WEBHOOK}
      DAM_LOG_LEVEL: "INFO"
    volumes:
      - dam_vault:/var/lib/dam
      - dam_logs:/var/log/dam
    ports:
      - "5000:5000"
    networks:
      - dam_network
    restart: unless-stopped

  # Prometheus for monitoring
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - dam_network

  # Grafana for visualization
  grafana:
    image: grafana/grafana:latest
    environment:
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./dashboards:/etc/grafana/provisioning/dashboards
    ports:
      - "3001:3000"
    networks:
      - dam_network
    depends_on:
      - prometheus

networks:
  dam_network:
    driver: bridge

volumes:
  postgres_data:
  dam_vault:
  dam_logs:
  prometheus_data:
  grafana_data:
```

---

## B.5: Kubernetes Deployment

### Kubernetes Secrets

**File: `k8s/secrets.yaml`**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: dam-secrets
type: Opaque
stringData:
  DATABASE_URL: "postgresql://user:pass@postgres-service:5432/dam_audit?sslmode=require"
  DAM_ENCRYPTION_KEY: "your-encryption-key"
  DAM_SLACK_WEBHOOK: "https://hooks.slack.com/services/..."
  DAM_PAGERDUTY_KEY: "your-pagerduty-key"
```

### Kubernetes ConfigMap

**File: `k8s/configmap.yaml`**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: dam-config
data:
  DAM_ENABLE_AUDIT: "true"
  DAM_ENABLE_DETECTION: "true"
  DAM_ENABLE_RESPONSE: "true"
  DAM_ENABLE_CONSOLE: "false"
  DAM_NOTIFY_SECURITY: "true"
  DAM_CIRCUIT_BREAKER: "true"
  DAM_TERMINATE_CONNECTIONS: "true"
  DAM_REVOKE_CREDENTIALS: "false"
  DAM_COOLDOWN_PERIOD: "60000"
  DAM_MAX_INCIDENTS_MEMORY: "100"
  DAM_LOG_LEVEL: "info"
  DAM_STRUCTURED_LOGGING: "true"
  DAM_VAULT_PATH: "/var/lib/dam/incident_vault.jsonl"
```

### Kubernetes Deployment (Node.js)

**File: `k8s/deployment-node.yaml`**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dam-node
  labels:
    app: dam
    component: node
spec:
  replicas: 3
  selector:
    matchLabels:
      app: dam
      component: node
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  template:
    metadata:
      labels:
        app: dam
        component: node
    spec:
      containers:
      - name: dam-node
        image: dam-node:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 3000
          name: http
        envFrom:
        - secretRef:
            name: dam-secrets
        - configMapRef:
            name: dam-config
        env:
        - name: NODE_ENV
          value: "production"
        - name: DAM_VAULT_PATH
          value: "/var/lib/dam/incident_vault.jsonl"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        volumeMounts:
        - name: dam-vault
          mountPath: /var/lib/dam
        - name: dam-logs
          mountPath: /var/log/dam
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 10
          periodSeconds: 5
      volumes:
      - name: dam-vault
        persistentVolumeClaim:
          claimName: dam-vault-pvc
      - name: dam-logs
        persistentVolumeClaim:
          claimName: dam-logs-pvc
```

### Kubernetes Service

**File: `k8s/service.yaml`**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: dam-service
  labels:
    app: dam
spec:
  selector:
    app: dam
  ports:
  - name: http
    port: 80
    targetPort: 3000
  type: ClusterIP

---
apiVersion: v1
kind: Service
metadata:
  name: dam-node-service
  labels:
    app: dam
    component: node
spec:
  selector:
    app: dam
    component: node
  ports:
  - port: 3000
    targetPort: 3000
  type: ClusterIP

---
apiVersion: v1
kind: Service
metadata:
  name: dam-python-service
  labels:
    app: dam
    component: python
spec:
  selector:
    app: dam
    component: python
  ports:
  - port: 5000
    targetPort: 5000
  type: ClusterIP
```

### Persistent Volume Claims

**File: `k8s/pvc.yaml`**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dam-vault-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: standard

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dam-logs-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 50Gi
  storageClassName: standard
```

---

## B.6: Monitoring & Alerting

### Prometheus Metrics

**File: `prometheus.yml`**

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'dam-node'
    static_configs:
      - targets: ['dam-node-service:3000']
    metrics_path: '/metrics'

  - job_name: 'dam-python'
    static_configs:
      - targets: ['dam-python-service:5000']
    metrics_path: '/metrics'
```

### Key Metrics to Monitor

| Metric | Description | Threshold |
|--------|-------------|-----------|
| `dam_queries_total` | Total queries processed | Monitor trend |
| `dam_threats_total` | Total threats detected | Alert on spike |
| `dam_incidents_total` | Total incidents | Alert on increase |
| `dam_query_duration_seconds` | Query execution time | Alert > 1s |
| `dam_circuit_breaker_active` | Circuit breaker state | Alert if active |
| `dam_audit_errors_total` | Audit log failures | Alert if > 0 |
| `dam_vault_size_bytes` | Incident vault size | Alert if growing |
| `dam_memory_usage_bytes` | Memory usage | Alert > 80% |
| `dam_cpu_usage_seconds` | CPU usage | Alert > 80% |

### Alert Rules (Prometheus)

**File: `alerts.yaml`**

```yaml
groups:
  - name: dam_alerts
    rules:
      - alert: DAMHighThreatRate
        expr: rate(dam_threats_total[5m]) > 10
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High rate of threats detected"
          description: "{{ $value }} threats per minute detected"

      - alert: DAMCircuitBreakerActive
        expr: dam_circuit_breaker_active == 1
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "DAM Circuit Breaker is active"
          description: "Circuit breaker activated - queries are being blocked"

      - alert: DAMAuditErrors
        expr: rate(dam_audit_errors_total[5m]) > 0
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "Audit logging is failing"
          description: "{{ $value }} audit errors per minute"

      - alert: DAMVaultGrowth
        expr: dam_vault_size_bytes > 1e9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Incident vault is growing rapidly"
          description: "Vault size: {{ $value }} bytes"

      - alert: DAMHighResponseTime
        expr: histogram_quantile(0.95, rate(dam_query_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "DAM query response time is high"
          description: "95th percentile: {{ $value }} seconds"
```

---

## B.7: Performance Tuning

### Node.js Performance Tuning

**File: `src/performance.js`**

```javascript
// performance.js
import { performance } from 'perf_hooks';

export class PerformanceOptimizer {
    constructor(options = {}) {
        this.options = {
            enableAsyncLogging: true,
            logBatchSize: parseInt(process.env.DAM_LOG_BATCH_SIZE) || 100,
            logBatchTimeout: parseInt(process.env.DAM_LOG_BATCH_TIMEOUT) || 5000,
            enableSampling: false,
            sampleRate: parseFloat(process.env.DAM_SAMPLE_RATE) || 0.1,
            ...options
        };
        
        this.logBatch = [];
        this.batchTimer = null;
        this.queryCount = 0;
    }

    /**
     * Check if query should be sampled (for high-volume systems)
     */
    shouldSample() {
        if (!this.options.enableSampling) {
            return true;
        }
        
        this.queryCount++;
        return this.queryCount % (1 / this.options.sampleRate) === 0;
    }

    /**
     * Async log batching
     */
    async logAuditAsync(auditEntry) {
        if (this.options.enableAsyncLogging) {
            this.logBatch.push(auditEntry);
            
            if (this.logBatch.length >= this.options.logBatchSize) {
                await this.flushBatch();
            } else if (!this.batchTimer) {
                this.batchTimer = setTimeout(() => {
                    this.flushBatch();
                }, this.options.logBatchTimeout);
            }
        } else {
            // Sync logging
            await this.logAuditSync(auditEntry);
        }
    }

    async flushBatch() {
        if (this.logBatch.length === 0) {
            return;
        }
        
        const batch = [...this.logBatch];
        this.logBatch = [];
        this.batchTimer = null;
        
        try {
            // Write batch to database
            await this.writeBatch(batch);
        } catch (error) {
            console.error('Batch write failed:', error);
            // Fallback to individual writes
            for (const entry of batch) {
                try {
                    await this.logAuditSync(entry);
                } catch (e) {
                    console.error('Failed to write individual log:', e);
                }
            }
        }
    }

    async writeBatch(batch) {
        // Implement batch insert logic
        const values = batch.map(() => 
            '($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)'
        ).join(',');
        
        const params = batch.flatMap(entry => [
            entry.query_text,
            entry.normalized_query,
            entry.query_fingerprint,
            entry.placeholder_count,
            JSON.stringify(entry.query_params),
            entry.duration_ms,
            entry.user_id,
            entry.user_ip,
            entry.status,
            entry.error_message
        ]);
        
        await this.pool.query(
            `INSERT INTO dam_audit_logs 
             (query_text, normalized_query, query_fingerprint, placeholder_count, 
              query_params, duration_ms, user_id, user_ip, status, error_message)
             VALUES ${values}`,
            params
        );
    }

    /**
     * Connection pool optimization
     */
    optimizePoolConfig(config) {
        return {
            ...config,
            // Use connection pool with proper settings
            max: parseInt(process.env.DAM_POOL_MAX) || 20,
            min: parseInt(process.env.DAM_POOL_MIN) || 5,
            idleTimeoutMillis: parseInt(process.env.DAM_POOL_IDLE_TIMEOUT) || 30000,
            connectionTimeoutMillis: parseInt(process.env.DAM_POOL_CONNECTION_TIMEOUT) || 5000,
            // Enable prepared statements
            prepare: true,
            // Statement cache for performance
            statementCacheSize: parseInt(process.env.DAM_STATEMENT_CACHE_SIZE) || 1000
        };
    }
}
```

### Python Performance Tuning

**File: `python/performance.py`**

```python
# performance.py
import threading
import time
import queue
from typing import List, Dict, Any
from datetime import datetime

class PerformanceOptimizer:
    """Performance optimization utilities for the DAM system."""
    
    def __init__(self, options: Dict[str, Any] = None):
        self.options = {
            'enable_async_logging': True,
            'log_batch_size': int(os.getenv('DAM_LOG_BATCH_SIZE', 100)),
            'log_batch_timeout': int(os.getenv('DAM_LOG_BATCH_TIMEOUT', 5000)),
            'enable_sampling': False,
            'sample_rate': float(os.getenv('DAM_SAMPLE_RATE', 0.1)),
            'queue_max_size': int(os.getenv('DAM_QUEUE_MAX_SIZE', 10000)),
            ** (options or {})
        }
        
        self.log_queue = queue.Queue(maxsize=self.options['queue_max_size'])
        self.batch_timer = None
        self.query_count = 0
        self.is_running = True
        self.worker_thread = None
        self.start_worker()
    
    def start_worker(self):
        """Start the background worker thread."""
        if self.options['enable_async_logging']:
            self.worker_thread = threading.Thread(target=self._worker_loop)
            self.worker_thread.daemon = True
            self.worker_thread.start()
    
    def _worker_loop(self):
        """Background worker for async logging."""
        batch = []
        last_flush = time.time()
        
        while self.is_running:
            try:
                # Get item from queue with timeout
                try:
                    item = self.log_queue.get(timeout=1)
                    batch.append(item)
                except queue.Empty:
                    pass
                
                # Check if we should flush
                current_time = time.time()
                if (len(batch) >= self.options['log_batch_size'] or
                    (batch and current_time - last_flush >= self.options['log_batch_timeout'] / 1000)):
                    self._flush_batch(batch)
                    batch = []
                    last_flush = current_time
                    
            except Exception as e:
                print(f"[PERFORMANCE] Worker error: {e}")
    
    def _flush_batch(self, batch: List[Dict[str, Any]]):
        """Write a batch of logs to the database."""
        if not batch:
            return
        
        try:
            # Implement batch insert
            import sqlite3
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            # Prepare batch insert
            cursor.executemany(
                """
                INSERT INTO audit_logs (
                    query_text, normalized_query, query_fingerprint,
                    placeholder_count, query_params, duration_ms,
                    user_id, user_ip, status, error_message
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                [(entry['query_text'], entry.get('normalized_query'),
                  entry.get('query_fingerprint'), entry.get('placeholder_count', 0),
                  entry.get('query_params', '[]'), entry['duration_ms'],
                  entry.get('user_id', 'system'), entry.get('user_ip', 'unknown'),
                  entry['status'], entry.get('error_message'))
                 for entry in batch]
            )
            conn.commit()
            conn.close()
            
        except Exception as e:
            print(f"[PERFORMANCE] Batch write failed: {e}")
            # Fallback to individual writes
            for entry in batch:
                try:
                    self._write_single(entry)
                except Exception as e2:
                    print(f"[PERFORMANCE] Single write failed: {e2}")
    
    def log_audit_async(self, audit_entry: Dict[str, Any]):
        """Add audit entry to async queue."""
        if self.options['enable_async_logging']:
            try:
                self.log_queue.put(audit_entry, timeout=1)
            except queue.Full:
                # Queue is full - log sync as fallback
                self._write_single(audit_entry)
        else:
            self._write_single(audit_entry)
    
    def _write_single(self, entry: Dict[str, Any]):
        """Write a single audit entry synchronously."""
        # Implement single write logic
        pass
    
    def should_sample(self) -> bool:
        """Check if query should be sampled."""
        if not self.options['enable_sampling']:
            return True
        
        self.query_count += 1
        return self.query_count % int(1 / self.options['sample_rate']) == 0
    
    def shutdown(self):
        """Shutdown the worker thread."""
        self.is_running = False
        if self.worker_thread:
            self.worker_thread.join(timeout=5)
```

---

## B.8: Backup & Recovery

### Backup Strategy

**File: `scripts/backup.sh`**

```bash
#!/bin/bash
# backup.sh - Backup the DAM system

set -e

# Configuration
BACKUP_DIR="/var/backups/dam"
RETENTION_DAYS=30
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="dam_backup_${TIMESTAMP}"

# Create backup directory
mkdir -p "${BACKUP_DIR}/${BACKUP_NAME}"

# 1. Backup audit logs (PostgreSQL)
echo "Backing up PostgreSQL audit logs..."
PGPASSWORD=${DAM_DB_PASSWORD} pg_dump \
    -h ${DAM_DB_HOST} \
    -U ${DAM_DB_USER} \
    -d ${DAM_DB_NAME} \
    -t dam_audit_logs \
    -F p \
    > "${BACKUP_DIR}/${BACKUP_NAME}/audit_logs.sql"

# 2. Backup incident vault
echo "Backing up incident vault..."
cp /var/lib/dam/incident_vault.jsonl \
    "${BACKUP_DIR}/${BACKUP_NAME}/incident_vault.jsonl"

# 3. Backup configuration
echo "Backing up configuration..."
cp /etc/dam/config.env \
    "${BACKUP_DIR}/${BACKUP_NAME}/config.env"

# 4. Create checksums
echo "Creating checksums..."
cd "${BACKUP_DIR}/${BACKUP_NAME}"
sha256sum * > checksums.txt

# 5. Compress backup
echo "Compressing backup..."
tar -czf "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
rm -rf "${BACKUP_DIR}/${BACKUP_NAME}"

# 6. Remove old backups
echo "Removing backups older than ${RETENTION_DAYS} days..."
find "${BACKUP_DIR}" -name "*.tar.gz" -mtime +${RETENTION_DAYS} -delete

echo "Backup completed: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
```

### Recovery Procedure

**File: `scripts/recover.sh`**

```bash
#!/bin/bash
# recover.sh - Recover the DAM system from backup

set -e

# Configuration
BACKUP_FILE=$1
RESTORE_DIR="/var/lib/dam/restore"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup-file.tar.gz>"
    exit 1
fi

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "Starting recovery from: $BACKUP_FILE"

# Create restore directory
mkdir -p "${RESTORE_DIR}"

# Extract backup
echo "Extracting backup..."
tar -xzf "${BACKUP_FILE}" -C "${RESTORE_DIR}"

# Verify checksums
echo "Verifying checksums..."
cd "${RESTORE_DIR}"
sha256sum -c checksums.txt

# 1. Restore PostgreSQL audit logs
echo "Restoring PostgreSQL audit logs..."
PGPASSWORD=${DAM_DB_PASSWORD} psql \
    -h ${DAM_DB_HOST} \
    -U ${DAM_DB_USER} \
    -d ${DAM_DB_NAME} \
    < audit_logs.sql

# 2. Restore incident vault
echo "Restoring incident vault..."
cp incident_vault.jsonl /var/lib/dam/incident_vault.jsonl

# 3. Restore configuration
echo "Restoring configuration..."
cp config.env /etc/dam/config.env

# 4. Clean up
echo "Cleaning up..."
rm -rf "${RESTORE_DIR}"

echo "Recovery completed successfully!"
```

---

## B.9: Maintenance Procedures

### Daily Maintenance

```bash
#!/bin/bash
# daily_maintenance.sh

# 1. Rotate logs
logrotate /etc/logrotate.d/dam

# 2. Clean up old incident files
find /var/lib/dam -name "*.jsonl" -mtime +90 -delete

# 3. Check vault size
VAULT_SIZE=$(stat -c%s /var/lib/dam/incident_vault.jsonl)
if [ $VAULT_SIZE -gt 1073741824 ]; then  # 1GB
    echo "WARNING: Vault size exceeds 1GB. Archive old entries."
fi

# 4. Check audit table growth
# (Run SQL query to check audit table size)

# 5. Verify health checks
curl -f http://localhost:3000/health || echo "Health check failed!"

# 6. Check for errors
tail -100 /var/log/dam/error.log | grep ERROR || echo "No errors found."
```

### Weekly Maintenance

```bash
#!/bin/bash
# weekly_maintenance.sh

# 1. Run database vacuum (PostgreSQL)
PGPASSWORD=${DAM_DB_PASSWORD} vacuumdb \
    -h ${DAM_DB_HOST} \
    -U ${DAM_DB_USER} \
    -d ${DAM_DB_NAME} \
    --analyze

# 2. Analyze query patterns
# (Run SQL to analyze most frequent query patterns)

# 3. Review incident trends
# (Generate weekly incident report)

# 4. Update threat rules
# (Check for new threat patterns and update rules)

# 5. Performance review
# (Analyze performance metrics for the week)

# 6. Backup
/opt/dam/scripts/backup.sh
```

### Monthly Maintenance

```bash
#!/bin/bash
# monthly_maintenance.sh

# 1. Archive old audit logs
# (Move logs older than 90 days to archive)

# 2. Run full database analysis
PGPASSWORD=${DAM_DB_PASSWORD} analyze \
    -h ${DAM_DB_HOST} \
    -U ${DAM_DB_USER} \
    -d ${DAM_DB_NAME}

# 3. Review and update threat rules
# (Analyze false positive rate and update rules)

# 4. Security review
# (Review access logs and permissions)

# 5. Capacity planning
# (Analyze growth trends and plan for scaling)

# 6. Documentation update
# (Update runbooks and procedures)

# 7. Disaster recovery test
# (Test recovery procedure)
```

---

## B.10: Troubleshooting Production Issues

### Issue: Database Connection Failures

**Symptoms:**
- `ECONNREFUSED` or `connection timeout` errors
- Queries are slow or failing

**Diagnostic:**
```bash
# Check database connectivity
nc -zv ${DAM_DB_HOST} ${DAM_DB_PORT}

# Check connection pool status
curl http://localhost:3000/debug/pool-status
```

**Resolution:**
```javascript
// Increase connection timeout
const pool = new AuditedPool(connectionString, {
    connectionTimeoutMillis: 10000,
    max: 50
});

// Implement retry logic
async function queryWithRetry(query, params, maxRetries = 3) {
    for (let i = 0; i < maxRetries; i++) {
        try {
            return await pool.query(query, params);
        } catch (error) {
            if (i === maxRetries - 1) throw error;
            await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
        }
    }
}
```

### Issue: High Memory Usage

**Symptoms:**
- Container or pod hitting memory limits
- System becoming slow or unresponsive

**Diagnostic:**
```bash
# Check memory usage
docker stats dam-container

# Check Node.js memory
node --max-old-space-size=512 app.js

# Check Python memory
python -c "import resource; print(resource.getrusage(resource.RUSAGE_SELF).ru_maxrss)"
```

**Resolution:**
```javascript
// Reduce memory in Node.js
const options = {
    maxIncidentsMemory: 50,  // Reduce from 100
    enableSampling: true,    // Enable sampling
    sampleRate: 0.5          // Log 50% of queries
};

// Implement memory monitoring
setInterval(() => {
    const memory = process.memoryUsage();
    if (memory.heapUsed > 500 * 1024 * 1024) { // 500MB
        console.warn('High memory usage detected:', memory);
        // Trigger GC or restart
    }
}, 60000);
```

### Issue: Vault File Corruption

**Symptoms:**
- JSON parse errors in incident logs
- Missing incident data

**Diagnostic:**
```bash
# Check vault file
tail -100 /var/lib/dam/incident_vault.jsonl

# Validate JSON lines
cat incident_vault.jsonl | jq '.' > /dev/null 2>&1
```

**Resolution:**
```javascript
// Implement vault validation
async function validateVault() {
    try {
        const lines = await fs.readFile(vaultPath, 'utf-8');
        const validLines = [];
        const corruptedLines = [];
        
        lines.split('\n').forEach((line, index) => {
            try {
                JSON.parse(line);
                validLines.push(line);
            } catch {
                corruptedLines.push(index);
            }
        });
        
        if (corruptedLines.length > 0) {
            console.error(`Found ${corruptedLines.length} corrupted lines`);
            // Recover valid lines
            await fs.writeFile(
                vaultPath + '.recovered',
                validLines.join('\n')
            );
        }
    } catch (error) {
        console.error('Vault validation failed:', error);
    }
}
```

### Issue: Alert Fatigue

**Symptoms:**
- Too many notifications
- Security team ignoring alerts
- High false positive rate

**Diagnostic:**
```sql
-- Analyze threat patterns
SELECT 
    normalized_query,
    COUNT(*) as count,
    AVG(threat_score) as avg_score,
    COUNT(CASE WHEN status = 'BLOCKED' THEN 1 END) as blocked
FROM dam_audit_logs
WHERE threat_level IS NOT NULL
GROUP BY normalized_query
ORDER BY count DESC
LIMIT 10;
```

**Resolution:**
```javascript
// Implement alert throttling
class AlertThrottler {
    constructor(options = {}) {
        this.thresholds = {
            critical: { perMinute: 5, perHour: 20 },
            high: { perMinute: 10, perHour: 50 },
            medium: { perMinute: 20, perHour: 100 }
        };
        this.alerts = {};
    }
    
    shouldSendAlert(severity, userKey) {
        const key = `${severity}:${userKey}`;
        const now = Date.now();
        const minute = 60 * 1000;
        const hour = 60 * minute;
        
        if (!this.alerts[key]) {
            this.alerts[key] = [];
        }
        
        // Clean old alerts
        this.alerts[key] = this.alerts[key].filter(
            t => now - t < hour
        );
        
        // Check thresholds
        const lastMinute = this.alerts[key].filter(
            t => now - t < minute
        );
        const lastHour = this.alerts[key];
        
        const threshold = this.thresholds[severity.toLowerCase()];
        if (threshold) {
            if (lastMinute.length >= threshold.perMinute) return false;
            if (lastHour.length >= threshold.perHour) return false;
        }
        
        // Record this alert
        this.alerts[key].push(now);
        return true;
    }
}
```

---

## B.11: Scaling Guidelines

### Horizontal Scaling

**Node.js:**
```javascript
// Use Redis for shared state between instances
import Redis from 'ioredis';

const redis = new Redis({
    host: process.env.REDIS_HOST,
    port: process.env.REDIS_PORT
});

// Share circuit breaker state
async function checkCircuitBreaker() {
    const state = await redis.get('dam:circuit_breaker');
    if (state) {
        const data = JSON.parse(state);
        if (Date.now() < data.expiry) {
            return true;
        }
    }
    return false;
}

// Share incident cooldown state
async function checkCooldown(userKey) {
    const key = `dam:cooldown:${userKey}`;
    const lastIncident = await redis.get(key);
    if (lastIncident) {
        const timeSince = Date.now() - parseInt(lastIncident);
        if (timeSince < cooldownPeriod) {
            return true;
        }
    }
    await redis.set(key, Date.now(), 'PX', cooldownPeriod);
    return false;
}
```

**Python:**
```python
# Use Redis for shared state
import redis

redis_client = redis.Redis(
    host=os.getenv('REDIS_HOST'),
    port=int(os.getenv('REDIS_PORT'))
)

def check_circuit_breaker():
    state = redis_client.get('dam:circuit_breaker')
    if state:
        data = json.loads(state)
        if time.time() < data['expiry']:
            return True
    return False

def check_cooldown(user_key):
    key = f'dam:cooldown:{user_key}'
    last_incident = redis_client.get(key)
    if last_inst ident:
        time_since = time.time() * 1000 - int(last_incident)
        if time_since < cooldown_period:
            return True
    redis_client.set(key, int(time.time() * 1000), px=cooldown_period)
    return False
```

### Database Sharding

```sql
-- Partition audit logs by date
CREATE TABLE dam_audit_logs_2026_01 PARTITION OF dam_audit_logs
    FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');

CREATE TABLE dam_audit_logs_2026_02 PARTITION OF dam_audit_logs
    FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');

-- Or use pg_partman extension
CREATE EXTENSION IF NOT EXISTS pg_partman;
SELECT create_parent('public.dam_audit_logs', 'timestamp', 'native', 'monthly');
```

---

## B.12: Production Runbook

### Incident Response Runbook

**File: `runbooks/incident-response.md`**

```markdown
# DAM Incident Response Runbook

## 1. Incident Detection
- **System Alert**: Prometheus alert triggered
- **User Report**: User reports suspicious activity
- **Manual Detection**: Security team identifies incident

## 2. Initial Assessment
- Check incident severity (LOW, MEDIUM, HIGH, CRITICAL)
- Identify affected users and tables
- Determine if incident is in progress or completed

## 3. Immediate Response
- **CRITICAL**: 
  - Activate circuit breaker (if not already)
  - Revoke affected credentials
  - Isolate affected user(s)
  - Notify security team (PagerDuty/Slack)
  - Begin incident logging

- **HIGH**:
  - Block affected queries
  - Terminate affected connections
  - Notify security team (Slack)
  - Monitor for recurrence

- **MEDIUM**:
  - Log incident
  - Notify security team (Email)
  - Review and update rules if needed

- **LOW**:
  - Log incident
  - Review for patterns

## 4. Investigation
- Query incident vault for related incidents
- Analyze audit logs for similar patterns
- Identify root cause (SQL injection, insider threat, etc.)
- Determine data impact (what was accessed/modified)

## 5. Eradication
- Patch vulnerabilities
- Update security rules
- Remove malicious content
- Change compromised credentials

## 6. Recovery
- Restore affected data from backup
- Reconnect legitimate users
- Resume normal operations

## 7. Post-Incident
- Generate incident report
- Update runbook with lessons learned
- Implement preventive measures
- Schedule security review

## 8. Escalation
- **Primary**: Security Team Lead (contact: security@company.com)
- **Secondary**: CISO (contact: ciso@company.com)
- **Emergency**: VP of Engineering (contact: vpeng@company.com)
```

---

This completes Appendix B. You now have a comprehensive guide for deploying, operating, and maintaining your DAM system in production. Use this alongside the main tutorial and Appendix A to successfully run your Database Activity Management system in any environment.
