# APPENDIX P — Complete Docker Compose & Kubernetes Production Manifests

## Production-Ready Deployment Configurations

---

## P.1 Introduction

This appendix provides complete, production-ready deployment configurations for the ScaleCart platform. It covers:

1. **Production Docker Compose** – Full production stack with monitoring
2. **Kubernetes Manifests** – Complete K8s deployment
3. **Helm Chart** – Package manager deployment
4. **Service Mesh** – Istio configuration
5. **GitOps** – ArgoCD integration

---

## P.2 Production Docker Compose

### P.2.1 Complete Production Stack

```yaml
# File: docker-compose.prod.yml
# Production Docker Compose configuration
# Usage: docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

version: '3.8'

services:
  # ============================================
  # POSTGRESQL - Primary Database
  # ============================================
  postgres:
    image: postgres:15
    container_name: scalecart_postgres_prod
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-scalecart}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB:-scalecart}
      POSTGRES_INITDB_ARGS: "--data-checksums"
    volumes:
      - postgres_data_prod:/var/lib/postgresql/data
      - ./postgresql.conf:/etc/postgresql/postgresql.conf:ro
      - ./init-scripts:/docker-entrypoint-initdb.d:ro
      - ./backups:/backups:ro
    command: postgres -c config_file=/etc/postgresql/postgresql.conf
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-scalecart} -d ${POSTGRES_DB:-scalecart}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
    networks:
      - scalecart_network_prod
    secrets:
      - postgres_password

  # ============================================
  # PGBOUNCER - Connection Pooler
  # ============================================
  pgbouncer:
    image: edoburu/pgbouncer:latest
    container_name: scalecart_pgbouncer_prod
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER:-scalecart}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB:-scalecart}
      POOL_MODE: transaction
      MAX_CLIENT_CONN: 1000
      DEFAULT_POOL_SIZE: 200
      MIN_POOL_SIZE: 20
      RESERVE_POOL_SIZE: 10
      RESERVE_POOL_TIMEOUT: 5
      SERVER_IDLE_TIMEOUT: 60
    ports:
      - "6432:6432"
    depends_on:
      - postgres
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    networks:
      - scalecart_network_prod

  # ============================================
  # REDIS - Cache & Session Store
  # ============================================
  redis:
    image: redis:7-alpine
    container_name: scalecart_redis_prod
    command: redis-server
      --requirepass ${REDIS_PASSWORD}
      --maxmemory 512mb
      --maxmemory-policy allkeys-lru
      --save 60 1000
      --appendonly yes
      --appendfsync everysec
      --tcp-backlog 511
      --timeout 0
      --tcp-keepalive 300
    ports:
      - "${REDIS_PORT:-6379}:6379"
    volumes:
      - redis_data_prod:/data
      - ./redis.conf:/usr/local/etc/redis/redis.conf:ro
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD}", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    networks:
      - scalecart_network_prod
    secrets:
      - redis_password

  # ============================================
  # MONGODB - Document Cache
  # ============================================
  mongodb:
    image: mongo:7.0
    container_name: scalecart_mongodb_prod
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER:-scalecart}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
      MONGO_INITDB_DATABASE: ${MONGO_DB:-scalecart}
    ports:
      - "${MONGO_PORT:-27017}:27017"
    volumes:
      - mongodb_data_prod:/data/db
      - ./mongod.conf:/etc/mongod.conf:ro
    command: mongod --config /etc/mongod.conf --replSet rs0
    healthcheck:
      test: ["CMD", "mongosh", "-u", "${MONGO_USER:-scalecart}", "-p", "${MONGO_PASSWORD}", "--authenticationDatabase", "admin", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    networks:
      - scalecart_network_prod
    secrets:
      - mongo_password

  # ============================================
  # NEO4J - Graph Database
  # ============================================
  neo4j:
    image: neo4j:5-enterprise
    container_name: scalecart_neo4j_prod
    environment:
      NEO4J_AUTH: ${NEO4J_USER:-neo4j}/${NEO4J_PASSWORD}
      NEO4J_ACCEPT_LICENSE_AGREEMENT: "yes"
      NEO4J_dbms_memory_heap_max__size: ${NEO4J_HEAP_MAX_SIZE:-2G}
      NEO4J_dbms_memory_pagecache_size: ${NEO4J_PAGE_CACHE_SIZE:-1G}
      NEO4J_dbms_logs_debug_level: "INFO"
      NEO4J_dbms_backup_enabled: "true"
    ports:
      - "7474:7474"
      - "7687:7687"
    volumes:
      - neo4j_data_prod:/data
      - neo4j_logs_prod:/logs
      - neo4j_backups:/backups
    healthcheck:
      test: ["CMD", "cypher-shell", "-u", "${NEO4J_USER:-neo4j}", "-p", "${NEO4J_PASSWORD}", "RETURN 1"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    networks:
      - scalecart_network_prod
    secrets:
      - neo4j_password

  # ============================================
  # TIMESCALEDB - Time-Series Metrics
  # ============================================
  timescaledb:
    image: timescale/timescaledb:2.11-pg15
    container_name: scalecart_timescaledb_prod
    environment:
      POSTGRES_USER: ${TIMESCALE_USER:-scalecart}
      POSTGRES_PASSWORD: ${TIMESCALE_PASSWORD}
      POSTGRES_DB: ${TIMESCALE_DB:-scalecart_metrics}
      TIMESCALEDB_TELEMETRY: "off"
    ports:
      - "${TIMESCALE_PORT:-5433}:5432"
    volumes:
      - timescaledb_data_prod:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${TIMESCALE_USER:-scalecart} -d ${TIMESCALE_DB:-scalecart_metrics}"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    networks:
      - scalecart_network_prod
    secrets:
      - timescale_password

  # ============================================
  # API - Application Service
  # ============================================
  api:
    build:
      context: .
      dockerfile: Dockerfile
      target: production
    image: ${REGISTRY:-docker.io}/${IMAGE_NAME:-scalecart/api}:${IMAGE_TAG:-latest}
    container_name: scalecart_api_prod
    environment:
      APP_ENV: production
      DEBUG: "false"
      LOG_LEVEL: ${LOG_LEVEL:-INFO}
      LOG_FORMAT: json
      DATABASE_URL: postgresql://${POSTGRES_USER:-scalecart}:${POSTGRES_PASSWORD}@pgbouncer:6432/${POSTGRES_DB:-scalecart}
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379/0
      MONGODB_URI: mongodb://${MONGO_USER:-scalecart}:${MONGO_PASSWORD}@mongodb:27017/${MONGO_DB:-scalecart}
      NEO4J_URI: bolt://neo4j:7687
      NEO4J_USER: ${NEO4J_USER:-neo4j}
      NEO4J_PASSWORD: ${NEO4J_PASSWORD}
      TIMESCALE_URL: postgresql://${TIMESCALE_USER:-scalecart}:${TIMESCALE_PASSWORD}@timescaledb:5432/${TIMESCALE_DB:-scalecart_metrics}
      SECRET_KEY: ${SECRET_KEY}
      JWT_SECRET_KEY: ${JWT_SECRET_KEY}
      OPENAI_API_KEY: ${OPENAI_API_KEY}
      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY}
      SENTRY_DSN: ${SENTRY_DSN}
      ALLOWED_HOSTS: ${ALLOWED_HOSTS}
      DB_POOL_SIZE: ${DB_POOL_SIZE:-40}
      DB_MAX_OVERFLOW: ${DB_MAX_OVERFLOW:-80}
    ports:
      - "${API_PORT:-8000}:8000"
    depends_on:
      pgbouncer:
        condition: service_started
      redis:
        condition: service_healthy
      mongodb:
        condition: service_healthy
      neo4j:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s
    deploy:
      mode: replicated
      replicas: ${API_REPLICAS:-3}
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
      update_config:
        parallelism: 1
        delay: 10s
        order: start-first
      rollback_config:
        parallelism: 1
        delay: 10s
        order: stop-first
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "10"
    networks:
      - scalecart_network_prod
    secrets:
      - postgres_password
      - redis_password
      - mongo_password
      - neo4j_password
      - timescale_password
      - secret_key
      - jwt_secret_key
    command: gunicorn -w ${WORKER_COUNT:-4} -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000 --timeout ${WORKER_TIMEOUT:-120} src.api.app:app

  # ============================================
  # WORKER - Background Tasks
  # ============================================
  worker:
    build:
      context: .
      dockerfile: Dockerfile
      target: production
    image: ${REGISTRY:-docker.io}/${IMAGE_NAME:-scalecart/worker}:${IMAGE_TAG:-latest}
    container_name: scalecart_worker_prod
    environment:
      APP_ENV: production
      DEBUG: "false"
      LOG_LEVEL: ${LOG_LEVEL:-INFO}
      DATABASE_URL: postgresql://${POSTGRES_USER:-scalecart}:${POSTGRES_PASSWORD}@pgbouncer:6432/${POSTGRES_DB:-scalecart}
      REDIS_URL: redis://:${REDIS_PASSWORD}@redis:6379/0
      MONGODB_URI: mongodb://${MONGO_USER:-scalecart}:${MONGO_PASSWORD}@mongodb:27017/${MONGO_DB:-scalecart}
      NEO4J_URI: bolt://neo4j:7687
      NEO4J_USER: ${NEO4J_USER:-neo4j}
      NEO4J_PASSWORD: ${NEO4J_PASSWORD}
      SECRET_KEY: ${SECRET_KEY}
    depends_on:
      pgbouncer:
        condition: service_started
      redis:
        condition: service_healthy
    deploy:
      mode: replicated
      replicas: ${WORKER_REPLICAS:-2}
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "10"
    networks:
      - scalecart_network_prod
    secrets:
      - postgres_password
      - redis_password
      - mongo_password
      - neo4j_password
      - secret_key
      - jwt_secret_key
    command: python -m src.worker.main

  # ============================================
  # NGINX - Reverse Proxy & Load Balancer
  # ============================================
  nginx:
    image: nginx:1.25-alpine
    container_name: scalecart_nginx_prod
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./static:/usr/share/nginx/html/static:ro
    depends_on:
      - api
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    networks:
      - scalecart_network_prod
    secrets:
      - ssl_certificate
      - ssl_certificate_key

  # ============================================
  # PROMETHEUS - Monitoring
  # ============================================
  prometheus:
    image: prom/prometheus:v2.46.0
    container_name: scalecart_prometheus_prod
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./alerts.yml:/etc/prometheus/alerts.yml:ro
      - prometheus_data_prod:/prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
      - '--web.enable-lifecycle'
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 2G
    restart: unless-stopped
    networks:
      - scalecart_network_prod
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ============================================
  # GRAFANA - Dashboards
  # ============================================
  grafana:
    image: grafana/grafana:10.2.0
    container_name: scalecart_grafana_prod
    environment:
      GF_SECURITY_ADMIN_USER: ${GRAFANA_USER:-admin}
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD}
      GF_INSTALL_PLUGINS: grafana-piechart-panel,grafana-clock-panel
      GF_SERVER_ROOT_URL: https://monitoring.scalecart.com
      GF_SERVER_SERVE_FROM_SUB_PATH: "true"
    volumes:
      - grafana_data_prod:/var/lib/grafana
      - ./grafana-provisioning:/etc/grafana/provisioning:ro
      - ./grafana-dashboards:/var/lib/grafana/dashboards:ro
    ports:
      - "3000:3000"
    depends_on:
      - prometheus
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
    restart: unless-stopped
    networks:
      - scalecart_network_prod
    secrets:
      - grafana_password

  # ============================================
  # ALERTMANAGER - Alerting
  # ============================================
  alertmanager:
    image: prom/alertmanager:v0.25.0
    container_name: scalecart_alertmanager_prod
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml:ro
    ports:
      - "9093:9093"
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
      - '--storage.path=/alertmanager'
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M
    restart: unless-stopped
    networks:
      - scalecart_network_prod

  # ============================================
  # LOGSTASH - Log Aggregation
  # ============================================
  logstash:
    image: docker.elastic.co/logstash/logstash:8.11.0
    container_name: scalecart_logstash_prod
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf:ro
    ports:
      - "5044:5044"
      - "5000:5000"
    environment:
      LS_JAVA_OPTS: "-Xmx512m -Xms512m"
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 1G
    restart: unless-stopped
    networks:
      - scalecart_network_prod

  # ============================================
  # ELASTICSEARCH - Log Storage
  # ============================================
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.0
    container_name: scalecart_elasticsearch_prod
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
      - xpack.security.enabled=false
    volumes:
      - elasticsearch_data_prod:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
      - "9300:9300"
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
    restart: unless-stopped
    networks:
      - scalecart_network_prod

  # ============================================
  # KIBANA - Log Visualization
  # ============================================
  kibana:
    image: docker.elastic.co/kibana/kibana:8.11.0
    container_name: scalecart_kibana_prod
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 1G
    restart: unless-stopped
    networks:
      - scalecart_network_prod

  # ============================================
  # BACKUP SERVICE
  # ============================================
  backup:
    image: alpine:latest
    container_name: scalecart_backup_prod
    volumes:
      - ./backup-scripts:/scripts:ro
      - ./backups:/backups
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      BACKUP_CRON: ${BACKUP_CRON:-0 1 * * *}
      BACKUP_RETENTION_DAYS: ${BACKUP_RETENTION_DAYS:-30}
      AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
      AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
      AWS_S3_BUCKET: ${BACKUP_S3_BUCKET}
    command: /bin/sh -c "apk add --no-cache curl docker-cli aws-cli && /scripts/backup.sh"
    restart: unless-stopped
    networks:
      - scalecart_network_prod
    secrets:
      - aws_access_key
      - aws_secret_key

# ============================================
# SECRETS
# ============================================
secrets:
  postgres_password:
    external: true
  redis_password:
    external: true
  mongo_password:
    external: true
  neo4j_password:
    external: true
  timescale_password:
    external: true
  secret_key:
    external: true
  jwt_secret_key:
    external: true
  grafana_password:
    external: true
  ssl_certificate:
    external: true
  ssl_certificate_key:
    external: true
  aws_access_key:
    external: true
  aws_secret_key:
    external: true

# ============================================
# NETWORKS
# ============================================
networks:
  scalecart_network_prod:
    driver: bridge
    ipam:
      config:
        - subnet: 172.29.0.0/16
    name: scalecart_network_prod
    external: true

# ============================================
# VOLUMES
# ============================================
volumes:
  postgres_data_prod:
    name: scalecart_postgres_data_prod
    external: true
  redis_data_prod:
    name: scalecart_redis_data_prod
    external: true
  mongodb_data_prod:
    name: scalecart_mongodb_data_prod
    external: true
  neo4j_data_prod:
    name: scalecart_neo4j_data_prod
    external: true
  neo4j_logs_prod:
    name: scalecart_neo4j_logs_prod
    external: true
  neo4j_backups:
    name: scalecart_neo4j_backups
    external: true
  timescaledb_data_prod:
    name: scalecart_timescaledb_data_prod
    external: true
  prometheus_data_prod:
    name: scalecart_prometheus_data_prod
    external: true
  grafana_data_prod:
    name: scalecart_grafana_data_prod
    external: true
  elasticsearch_data_prod:
    name: scalecart_elasticsearch_data_prod
    external: true
```

### P.2.2 Environment Variables for Production

```bash
# File: .env.prod
# Production environment variables

# ============================================
# DATABASE PASSWORDS (Generate secure ones)
# ============================================
POSTGRES_PASSWORD=generate_secure_password_here
REDIS_PASSWORD=generate_secure_password_here
MONGO_PASSWORD=generate_secure_password_here
NEO4J_PASSWORD=generate_secure_password_here
TIMESCALE_PASSWORD=generate_secure_password_here

# ============================================
# APPLICATION SECRETS
# ============================================
SECRET_KEY=generate_secure_secret_here
JWT_SECRET_KEY=generate_secure_secret_here
GRAFANA_PASSWORD=generate_secure_password_here

# ============================================
# DOMAINS
# ============================================
ALLOWED_HOSTS=api.scalecart.com,monitoring.scalecart.com,logs.scalecart.com
CORS_ORIGINS=https://scalecart.com,https://admin.scalecart.com

# ============================================
# SCALING
# ============================================
API_REPLICAS=3
WORKER_REPLICAS=2
WORKER_COUNT=4
DB_POOL_SIZE=40
DB_MAX_OVERFLOW=80

# ============================================
# EXTERNAL SERVICES
# ============================================
OPENAI_API_KEY=sk-...
STRIPE_SECRET_KEY=sk_...
SENTRY_DSN=https://...
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
BACKUP_S3_BUCKET=scalecart-backups

# ============================================
# BACKUP
# ============================================
BACKUP_CRON=0 1 * * *
BACKUP_RETENTION_DAYS=30

# ============================================
# LOGGING
# ============================================
LOG_LEVEL=INFO
```

---

## P.3 Kubernetes Manifests

### P.3.1 Namespace

```yaml
# File: k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: scalecart
  labels:
    name: scalecart
    environment: production
    app: scalecart
```

### P.3.2 ConfigMap

```yaml
# File: k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: scalecart-config
  namespace: scalecart
  labels:
    app: scalecart
    component: config
data:
  APP_ENV: "production"
  DEBUG: "false"
  LOG_LEVEL: "INFO"
  LOG_FORMAT: "json"
  ALLOWED_HOSTS: "api.scalecart.com"
  DB_POOL_SIZE: "40"
  DB_MAX_OVERFLOW: "80"
  PRODUCT_CACHE_TTL: "3600"
  CATEGORY_CACHE_TTL: "7200"
  SESSION_TTL: "86400"
  RATE_LIMIT_PER_MINUTE: "100"
  RATE_LIMIT_PER_HOUR: "1000"
  ENABLE_CACHING: "true"
  ENABLE_GRAPH_RECOMMENDATIONS: "true"
  ENABLE_VECTOR_SEARCH: "false"
  ENABLE_METRICS: "true"
  ENABLE_AUDIT_LOG: "true"
  ENABLE_RATE_LIMITING: "true"
  ENABLE_COMPRESSION: "true"
  CORS_ORIGINS: "https://scalecart.com,https://admin.scalecart.com"
  WORKER_COUNT: "4"
  WORKER_TIMEOUT: "120"
  POSTGRES_USER: "scalecart"
  POSTGRES_DB: "scalecart"
  MONGO_USER: "scalecart"
  MONGO_DB: "scalecart"
  NEO4J_USER: "neo4j"
```

### P.3.3 Secrets (using External Secrets Operator)

```yaml
# File: k8s/secrets.yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secretsmanager
  namespace: scalecart
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: scalecart-sa

---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: scalecart-secrets
  namespace: scalecart
spec:
  refreshInterval: "1h"
  secretStoreRef:
    name: aws-secretsmanager
    kind: SecretStore
  target:
    name: scalecart-secrets
    creationPolicy: Owner
  data:
    - secretKey: postgres_password
      remoteRef:
        key: scalecart/prod/postgres
        property: password
    - secretKey: redis_password
      remoteRef:
        key: scalecart/prod/redis
        property: password
    - secretKey: mongo_password
      remoteRef:
        key: scalecart/prod/mongodb
        property: password
    - secretKey: neo4j_password
      remoteRef:
        key: scalecart/prod/neo4j
        property: password
    - secretKey: timescale_password
      remoteRef:
        key: scalecart/prod/timescale
        property: password
    - secretKey: secret_key
      remoteRef:
        key: scalecart/prod/app
        property: secret_key
    - secretKey: jwt_secret_key
      remoteRef:
        key: scalecart/prod/app
        property: jwt_secret_key
    - secretKey: openai_api_key
      remoteRef:
        key: scalecart/prod/openai
        property: api_key
    - secretKey: stripe_secret_key
      remoteRef:
        key: scalecart/prod/stripe
        property: secret_key
    - secretKey: sentry_dsn
      remoteRef:
        key: scalecart/prod/sentry
        property: dsn
```

### P.3.4 PostgreSQL StatefulSet

```yaml
# File: k8s/postgres-statefulset.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: scalecart-postgres
  namespace: scalecart
  labels:
    app: scalecart
    component: postgres
spec:
  serviceName: scalecart-postgres
  replicas: 1
  selector:
    matchLabels:
      app: scalecart
      component: postgres
  template:
    metadata:
      labels:
        app: scalecart
        component: postgres
    spec:
      containers:
        - name: postgres
          image: postgres:15
          env:
            - name: POSTGRES_USER
              valueFrom:
                configMapKeyRef:
                  name: scalecart-config
                  key: POSTGRES_USER
            - name: POSTGRES_DB
              valueFrom:
                configMapKeyRef:
                  name: scalecart-config
                  key: POSTGRES_DB
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: postgres_password
            - name: POSTGRES_INITDB_ARGS
              value: "--data-checksums"
            - name: PGDATA
              value: "/var/lib/postgresql/data/pgdata"
          ports:
            - containerPort: 5432
              name: postgres
          volumeMounts:
            - name: postgres-data
              mountPath: /var/lib/postgresql/data
          resources:
            requests:
              memory: "4Gi"
              cpu: "2000m"
            limits:
              memory: "8Gi"
              cpu: "4000m"
          livenessProbe:
            exec:
              command:
                - pg_isready
                - -U
                - scalecart
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          readinessProbe:
            exec:
              command:
                - pg_isready
                - -U
                - scalecart
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 2
      volumes:
        - name: postgres-data
          persistentVolumeClaim:
            claimName: postgres-data
      securityContext:
        runAsUser: 999
        runAsGroup: 999
        fsGroup: 999
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-data
  namespace: scalecart
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
  storageClassName: gp2
```

### P.3.5 PostgreSQL Service

```yaml
# File: k8s/postgres-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: scalecart-postgres
  namespace: scalecart
  labels:
    app: scalecart
    component: postgres
spec:
  selector:
    app: scalecart
    component: postgres
  ports:
    - port: 5432
      targetPort: 5432
      name: postgres
  clusterIP: None
```

### P.3.6 API Deployment

```yaml
# File: k8s/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scalecart-api
  namespace: scalecart
  labels:
    app: scalecart
    component: api
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: scalecart
      component: api
  template:
    metadata:
      labels:
        app: scalecart
        component: api
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"
        checksum/config: "{{ .Values.configChecksum }}"
        checksum/secrets: "{{ .Values.secretsChecksum }}"
    spec:
      containers:
        - name: api
          image: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
          imagePullPolicy: Always
          ports:
            - containerPort: 8000
              name: http
          env:
            - name: APP_ENV
              valueFrom:
                configMapKeyRef:
                  name: scalecart-config
                  key: APP_ENV
            - name: DEBUG
              valueFrom:
                configMapKeyRef:
                  name: scalecart-config
                  key: DEBUG
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: scalecart-config
                  key: LOG_LEVEL
            - name: ALLOWED_HOSTS
              valueFrom:
                configMapKeyRef:
                  name: scalecart-config
                  key: ALLOWED_HOSTS
            - name: DATABASE_URL
              value: "postgresql://scalecart:$(POSTGRES_PASSWORD)@scalecart-postgres:5432/scalecart"
            - name: REDIS_URL
              value: "redis://:$(REDIS_PASSWORD)@scalecart-redis:6379/0"
            - name: MONGODB_URI
              value: "mongodb://scalecart:$(MONGO_PASSWORD)@scalecart-mongodb:27017/scalecart"
            - name: NEO4J_URI
              value: "bolt://scalecart-neo4j:7687"
            - name: NEO4J_USER
              valueFrom:
                configMapKeyRef:
                  name: scalecart-config
                  key: NEO4J_USER
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: postgres_password
            - name: REDIS_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: redis_password
            - name: MONGO_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: mongo_password
            - name: NEO4J_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: neo4j_password
            - name: SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: secret_key
            - name: JWT_SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: jwt_secret_key
            - name: OPENAI_API_KEY
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: openai_api_key
            - name: STRIPE_SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: stripe_secret_key
          resources:
            requests:
              memory: "1Gi"
              cpu: "1000m"
            limits:
              memory: "2Gi"
              cpu: "2000m"
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 8000
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 2
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: tmp
          emptyDir: {}
      nodeSelector:
        node-group: api
      tolerations:
        - key: api
          operator: Equal
          value: "true"
          effect: NoSchedule
```

### P.3.7 API Service

```yaml
# File: k8s/api-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: scalecart-api
  namespace: scalecart
  labels:
    app: scalecart
    component: api
spec:
  selector:
    app: scalecart
    component: api
  ports:
    - port: 80
      targetPort: 8000
      protocol: TCP
      name: http
  type: ClusterIP
```

### P.3.8 Ingress

```yaml
# File: k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: scalecart-ingress
  namespace: scalecart
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-burst: "150"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: "https://scalecart.com,https://admin.scalecart.com"
    nginx.ingress.kubernetes.io/cors-allow-methods: "GET, POST, PUT, DELETE, OPTIONS"
    nginx.ingress.kubernetes.io/cors-allow-headers: "Authorization, Content-Type"
spec:
  tls:
    - hosts:
        - api.scalecart.com
      secretName: scalecart-tls
  rules:
    - host: api.scalecart.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: scalecart-api
                port:
                  number: 80
```

### P.3.9 Horizontal Pod Autoscaler

```yaml
# File: k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: scalecart-api-hpa
  namespace: scalecart
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: scalecart-api
  minReplicas: 3
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
    - type: Pods
      pods:
        metric:
          name: requests_per_second
        target:
          type: AverageValue
          averageValue: "500"
```

### P.3.10 Network Policy

```yaml
# File: k8s/network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: scalecart-network-policy
  namespace: scalecart
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: ingress-nginx
      ports:
        - port: 8000
          protocol: TCP
    - from:
        - podSelector:
            matchLabels:
              app: scalecart
              component: worker
      ports:
        - port: 8000
          protocol: TCP
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: scalecart
              component: postgres
      ports:
        - port: 5432
          protocol: TCP
    - to:
        - podSelector:
            matchLabels:
              app: scalecart
              component: redis
      ports:
        - port: 6379
          protocol: TCP
    - to:
        - podSelector:
            matchLabels:
              app: scalecart
              component: mongodb
      ports:
        - port: 27017
          protocol: TCP
    - to:
        - podSelector:
            matchLabels:
              app: scalecart
              component: neo4j
      ports:
        - port: 7687
          protocol: TCP
    - to:
        - external:
            cidr: 0.0.0.0/0
      ports:
        - port: 443
          protocol: TCP
        - port: 80
          protocol: TCP
```

---

## P.4 Deployment Commands

### P.4.1 Docker Compose Production Deployment

```bash
#!/bin/bash
# File: scripts/deploy-compose-prod.sh
# Deploy ScaleCart to production using Docker Compose

set -e

echo "🚀 Deploying ScaleCart Production (Docker Compose)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Create required volumes
echo -e "${YELLOW}1. Creating volumes...${NC}"
docker volume create scalecart_postgres_data_prod
docker volume create scalecart_redis_data_prod
docker volume create scalecart_mongodb_data_prod
docker volume create scalecart_neo4j_data_prod
docker volume create scalecart_timescaledb_data_prod
docker volume create scalecart_prometheus_data_prod
docker volume create scalecart_grafana_data_prod
docker volume create scalecart_elasticsearch_data_prod

# 2. Create networks
echo -e "${YELLOW}2. Creating networks...${NC}"
docker network create scalecart_network_prod --subnet=172.29.0.0/16 2>/dev/null || true

# 3. Load environment variables
echo -e "${YELLOW}3. Loading environment...${NC}"
set -o allexport
source .env.prod
set +o allexport

# 4. Run database migrations
echo -e "${YELLOW}4. Running migrations...${NC}"
docker compose -f docker-compose.yml -f docker-compose.prod.yml run --rm api alembic upgrade head

# 5. Deploy services
echo -e "${YELLOW}5. Deploying services...${NC}"
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 6. Wait for services
echo -e "${YELLOW}6. Waiting for services...${NC}"
sleep 10

# 7. Health check
echo -e "${YELLOW}7. Running health check...${NC}"
if curl -f http://localhost:8000/health; then
    echo -e "${GREEN}✅ Health check passed${NC}"
else
    echo -e "${RED}❌ Health check failed${NC}"
    exit 1
fi

# 8. Show status
echo ""
echo -e "${GREEN}✅ ScaleCart Production deployed successfully!${NC}"
echo ""
echo "Access services:"
echo "  API: http://localhost:8000"
echo "  API Docs: http://localhost:8000/docs"
echo "  Grafana: http://localhost:3000 (admin/your-password)"
echo "  Kibana: http://localhost:5601"
echo "  Neo4j: http://localhost:7474"
echo ""
echo "To view logs: docker compose -f docker-compose.yml -f docker-compose.prod.yml logs -f"
echo "To stop: docker compose -f docker-compose.yml -f docker-compose.prod.yml down"
```

### P.4.2 Kubernetes Production Deployment

```bash
#!/bin/bash
# File: scripts/deploy-k8s-prod.sh
# Deploy ScaleCart to production using Kubernetes

set -e

echo "🚀 Deploying ScaleCart Production (Kubernetes)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
NAMESPACE="scalecart"
REGISTRY="${REGISTRY:-docker.io}"
IMAGE_NAME="${IMAGE_NAME:-scalecart/api}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

# 1. Check Kubernetes connection
echo -e "${YELLOW}1. Checking Kubernetes connection...${NC}"
kubectl cluster-info

# 2. Create namespace
echo -e "${YELLOW}2. Creating namespace...${NC}"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 3. Apply ConfigMaps and Secrets
echo -e "${YELLOW}3. Applying ConfigMaps and Secrets...${NC}"
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml

# 4. Deploy databases
echo -e "${YELLOW}4. Deploying databases...${NC}"
kubectl apply -f k8s/postgres-statefulset.yaml
kubectl apply -f k8s/postgres-service.yaml

# 5. Deploy API
echo -e "${YELLOW}5. Deploying API...${NC}"
# Update image in deployment
sed -i.bak "s|image:.*|image: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}|g" k8s/api-deployment.yaml
kubectl apply -f k8s/api-deployment.yaml
kubectl apply -f k8s/api-service.yaml
# Restore backup
mv k8s/api-deployment.yaml.bak k8s/api-deployment.yaml 2>/dev/null || true

# 6. Deploy Ingress
echo -e "${YELLOW}6. Deploying Ingress...${NC}"
kubectl apply -f k8s/ingress.yaml

# 7. Deploy HPA
echo -e "${YELLOW}7. Deploying HPA...${NC}"
kubectl apply -f k8s/hpa.yaml

# 8. Deploy Network Policy
echo -e "${YELLOW}8. Deploying Network Policy...${NC}"
kubectl apply -f k8s/network-policy.yaml

# 9. Wait for deployments
echo -e "${YELLOW}9. Waiting for deployments...${NC}"
kubectl -n $NAMESPACE rollout status deployment/scalecart-api

# 10. Check status
echo -e "${YELLOW}10. Checking status...${NC}"
kubectl -n $NAMESPACE get pods
kubectl -n $NAMESPACE get svc
kubectl -n $NAMESPACE get ingress

# 11. Health check
echo -e "${YELLOW}11. Running health check...${NC}"
POD_NAME=$(kubectl -n $NAMESPACE get pods -l app=scalecart,component=api -o jsonpath='{.items[0].metadata.name}')
kubectl -n $NAMESPACE exec $POD_NAME -- curl -f http://localhost:8000/health

echo -e "${GREEN}✅ ScaleCart Production deployed successfully!${NC}"
```

---

## P.5 Deployment Verification

### P.5.1 Verification Script

```bash
#!/bin/bash
# File: scripts/verify-production.sh
# Verify production deployment

echo "🔍 Verifying Production Deployment"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

# 1. Check API
echo -n "1. API Health: "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health | grep -q 200; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 2. Check API Ready
echo -n "2. API Ready: "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health/ready | grep -q 200; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 3. Check Database
echo -n "3. Database: "
if docker compose exec -T postgres psql -U scalecart -d scalecart -c "SELECT 1" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 4. Check Redis
echo -n "4. Redis: "
if docker compose exec -T redis redis-cli -a $REDIS_PASSWORD ping &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 5. Check MongoDB
echo -n "5. MongoDB: "
if docker compose exec -T mongodb mongosh -u scalecart -p $MONGO_PASSWORD --authenticationDatabase admin --eval "db.adminCommand('ping')" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 6. Check Neo4j
echo -n "6. Neo4j: "
if docker compose exec -T neo4j cypher-shell -u neo4j -p $NEO4J_PASSWORD "RETURN 1" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 7. Check Prometheus
echo -n "7. Prometheus: "
if curl -s http://localhost:9090/-/healthy | grep -q "Healthy"; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 8. Check Grafana
echo -n "8. Grafana: "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health | grep -q 200; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed!${NC}"
else
    echo -e "${RED}❌ Some checks failed. See above for details.${NC}"
    exit 1
fi
```

---

**[END OF APPENDIX P]**

*This comprehensive deployment appendix provides everything needed to run ScaleCart in production using Docker Compose or Kubernetes. Use these manifests as a starting point for your production deployment.*
