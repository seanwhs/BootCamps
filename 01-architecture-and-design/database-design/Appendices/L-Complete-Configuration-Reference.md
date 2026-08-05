# APPENDIX L — Complete Configuration Reference

## All Configuration Options for ScaleCart

---

## L.1 Introduction

This appendix provides a complete reference for all configuration options available in the ScaleCart platform. It covers:

1. **Environment Variables** – All configurable environment settings
2. **Docker Configuration** – Docker and Docker Compose settings
3. **Application Configuration** – FastAPI, logging, and feature flags
4. **Database Configuration** – PostgreSQL, Redis, MongoDB, Neo4j settings
5. **Monitoring Configuration** – Prometheus, Grafana, logging
6. **Security Configuration** – TLS, CORS, rate limiting
7. **Performance Configuration** – Caching, connection pools, timeouts

---

## L.2 Environment Variables Reference

### L.2.1 Complete .env.example

```bash
# File: .env.example
# ScaleCart Environment Variables
# Copy this file to .env and adjust values as needed

# ============================================
# APPLICATION CONFIGURATION
# ============================================

# Application environment: development, staging, production
APP_ENV=development

# Debug mode (true/false) - enable detailed error messages
DEBUG=true

# Application secret key - CHANGE IN PRODUCTION!
SECRET_KEY=your-secret-key-here-change-in-production

# JWT secret key - CHANGE IN PRODUCTION!
JWT_SECRET_KEY=your-jwt-secret-key-here

# Application name
APP_NAME=ScaleCart

# Allowed hosts (comma-separated)
ALLOWED_HOSTS=localhost,127.0.0.1,api.scalecart.com

# API version and prefix
API_VERSION=v1
API_PREFIX=/api/v1

# Logging level: DEBUG, INFO, WARNING, ERROR, CRITICAL
LOG_LEVEL=INFO

# Log format: json, text
LOG_FORMAT=json

# Log file path
LOG_FILE=/var/log/scalecart/app.log

# ============================================
# POSTGRESQL CONFIGURATION
# ============================================

# Database connection
POSTGRES_USER=scalecart
POSTGRES_PASSWORD=scalecart_password
POSTGRES_DB=scalecart
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# Full connection URL (overrides individual settings)
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}

# Connection pool settings
DB_POOL_SIZE=20
DB_MAX_OVERFLOW=40
DB_POOL_TIMEOUT=30
DB_POOL_RECYCLE=3600
DB_ECHO=false

# SSL settings
DB_SSL_MODE=prefer
DB_SSL_CA_CERT=/etc/ssl/certs/ca.pem

# ============================================
# REDIS CONFIGURATION
# ============================================

REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=scalecart_password
REDIS_DB=0

# Full Redis URL
REDIS_URL=redis://:${REDIS_PASSWORD}@${REDIS_HOST}:${REDIS_PORT}/${REDIS_DB}

# Redis connection pool
REDIS_MAX_CONNECTIONS=50
REDIS_SOCKET_TIMEOUT=5
REDIS_SOCKET_CONNECT_TIMEOUT=5

# Redis cluster (for high availability)
REDIS_CLUSTER_ENABLED=false
REDIS_CLUSTER_NODES=redis1:6379,redis2:6379,redis3:6379

# ============================================
# MONGODB CONFIGURATION
# ============================================

MONGO_USER=scalecart
MONGO_PASSWORD=scalecart_password
MONGO_DB=scalecart
MONGO_HOST=mongodb
MONGO_PORT=27017

# Full MongoDB URI
MONGO_URI=mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB}

# Connection pool
MONGO_MAX_POOL_SIZE=50
MONGO_MIN_POOL_SIZE=10
MONGO_MAX_IDLE_TIME_MS=300000
MONGO_WAIT_QUEUE_TIMEOUT_MS=5000
MONGO_SOCKET_TIMEOUT_MS=10000

# Replica set
MONGO_REPLICA_SET=rs0

# ============================================
# NEO4J CONFIGURATION
# ============================================

NEO4J_HOST=neo4j
NEO4J_PORT=7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=scalecart_neo4j_password

# Full Neo4j URI
NEO4J_URI=bolt://${NEO4J_HOST}:${NEO4J_PORT}

# Connection pool
NEO4J_MAX_CONNECTION_POOL_SIZE=50
NEO4J_CONNECTION_ACQUISITION_TIMEOUT=10
NEO4J_MAX_TRANSACTION_RETRY_TIME=30

# ============================================
# TIMESCALEDB CONFIGURATION
# ============================================

TIMESCALE_HOST=timescaledb
TIMESCALE_PORT=5433
TIMESCALE_USER=scalecart
TIMESCALE_PASSWORD=scalecart_password
TIMESCALE_DB=scalecart_metrics

# Full TimescaleDB URL
TIMESCALE_URL=postgresql://${TIMESCALE_USER}:${TIMESCALE_PASSWORD}@${TIMESCALE_HOST}:${TIMESCALE_PORT}/${TIMESCALE_DB}

# ============================================
# CACHING CONFIGURATION
# ============================================

# Product cache TTL in seconds
PRODUCT_CACHE_TTL=3600

# Category cache TTL in seconds
CATEGORY_CACHE_TTL=7200

# Session TTL in seconds
SESSION_TTL=86400

# Rate limit cache TTL in seconds
RATE_LIMIT_CACHE_TTL=60

# Cache warming enabled
CACHE_WARMING_ENABLED=true

# ============================================
# FEATURE FLAGS
# ============================================

# Enable caching
ENABLE_CACHING=true

# Enable graph recommendations
ENABLE_GRAPH_RECOMMENDATIONS=true

# Enable vector search
ENABLE_VECTOR_SEARCH=false

# Enable metrics collection
ENABLE_METRICS=true

# Enable rate limiting
ENABLE_RATE_LIMITING=true

# Enable audit logging
ENABLE_AUDIT_LOG=true

# Enable compression
ENABLE_COMPRESSION=true

# Enable OpenTelemetry tracing
ENABLE_TRACING=false

# ============================================
# SECURITY CONFIGURATION
# ============================================

# CORS settings
CORS_ORIGINS=http://localhost:3000,http://localhost:8080,https://scalecart.com

# Rate limiting
RATE_LIMIT_PER_MINUTE=100
RATE_LIMIT_PER_HOUR=1000
RATE_LIMIT_PER_DAY=10000

# JWT settings
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
JWT_REFRESH_TOKEN_EXPIRE_DAYS=7
JWT_ALGORITHM=HS256

# Password settings
PASSWORD_MIN_LENGTH=8
PASSWORD_REQUIRE_UPPERCASE=true
PASSWORD_REQUIRE_LOWERCASE=true
PASSWORD_REQUIRE_NUMBER=true
PASSWORD_REQUIRE_SPECIAL=true

# Session settings
SESSION_COOKIE_NAME=session
SESSION_COOKIE_SECURE=true
SESSION_COOKIE_HTTPONLY=true
SESSION_COOKIE_SAMESITE=lax

# Security headers
SECURITY_HEADERS_ENABLED=true
HSTS_MAX_AGE=31536000
HSTS_INCLUDE_SUBDOMAINS=true
HSTS_PRELOAD=true

# ============================================
# EXTERNAL SERVICES
# ============================================

# OpenAI (for embeddings and AI features)
OPENAI_API_KEY=your-openai-api-key-here
OPENAI_MODEL=text-embedding-3-small
OPENAI_MAX_TOKENS=8192

# Stripe (payments)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_CURRENCY=usd

# AWS (for backups and file storage)
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
AWS_S3_BUCKET=scalecart-backups
AWS_S3_USE_SSL=true

# Email (SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_USE_TLS=true
SMTP_FROM_EMAIL=noreply@scalecart.com

# Sentry (error tracking)
SENTRY_DSN=https://your-sentry-dsn.ingest.sentry.io/
SENTRY_ENVIRONMENT=development

# New Relic (APM)
NEW_RELIC_LICENSE_KEY=your-newrelic-key
NEW_RELIC_APP_NAME=ScaleCart

# DataDog (APM)
DATADOG_API_KEY=your-datadog-key
DATADOG_SITE=datadoghq.com

# ============================================
# BACKUP CONFIGURATION
# ============================================

# Backup schedule (cron expression)
BACKUP_CRON=0 1 * * *

# Backup retention (days)
BACKUP_RETENTION_DAYS=30

# Backup directory
BACKUP_DIR=/backups

# Backup AWS S3 bucket
BACKUP_S3_BUCKET=scalecart-backups

# Backup encryption
BACKUP_ENCRYPTION_ENABLED=true
BACKUP_ENCRYPTION_KEY=your-backup-encryption-key

# ============================================
# MONITORING CONFIGURATION
# ============================================

# Prometheus
PROMETHEUS_ENABLED=true
PROMETHEUS_PORT=9090

# Grafana
GRAFANA_ENABLED=true
GRAFANA_PORT=3000
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=admin

# Health check endpoints
HEALTH_CHECK_PATH=/health
READINESS_CHECK_PATH=/health/ready
LIVENESS_CHECK_PATH=/health/live

# ============================================
# PERFORMANCE CONFIGURATION
# ============================================

# Worker count (for gunicorn)
WORKER_COUNT=4
WORKER_CONNECTIONS=1000
WORKER_TIMEOUT=120

# Async settings
ASYNC_WORKER_COUNT=100
ASYNC_QUEUE_MAX_SIZE=1000

# Batch processing
BATCH_SIZE=1000
BATCH_TIMEOUT_MS=100

# Compression (gzip/brotli)
COMPRESSION_MIN_SIZE=1024
COMPRESSION_LEVEL=6

# ============================================
# DATABASE PERFORMANCE TUNING
# ============================================

# PostgreSQL performance (see postgresql.conf)
POSTGRES_SHARED_BUFFERS=4GB
POSTGRES_WORK_MEM=64MB
POSTGRES_MAINTENANCE_WORK_MEM=1GB
POSTGRES_EFFECTIVE_CACHE_SIZE=12GB
POSTGRES_MAX_CONNECTIONS=200

# Redis performance
REDIS_MAXMEMORY=512mb
REDIS_MAXMEMORY_POLICY=allkeys-lru

# MongoDB performance
MONGO_CACHE_SIZE_GB=8
MONGO_MAX_CONNECTIONS=100

# Neo4j performance
NEO4J_HEAP_MAX_SIZE=2G
NEO4J_PAGE_CACHE_SIZE=1G

# ============================================
# DEVELOPMENT TOOLS
# ============================================

# Hot reload
HOT_RELOAD_ENABLED=true

# SQL logging
SQL_ECHO=false

# Debug toolbar
DEBUG_TOOLBAR_ENABLED=false

# Sample data generation
SAMPLE_DATA_ENABLED=true
SAMPLE_DATA_COUNT=1000

# ============================================
# DEPLOYMENT SPECIFIC
# ============================================

# Deployment type: docker, kubernetes, ecs
DEPLOYMENT_TYPE=docker

# Container registry
CONTAINER_REGISTRY=docker.io/username

# Image tag
IMAGE_TAG=latest

# Kubernetes namespace
KUBERNETES_NAMESPACE=scalecart

# Helm release name
HELM_RELEASE_NAME=scalecart
```

---

## L.3 Docker Configuration Reference

### L.3.1 Docker Compose Complete Options

```yaml
# File: docker-compose.yml (with all options)

version: '3.8'

services:
  # ============================================
  # PostgreSQL Service
  # ============================================
  postgres:
    image: postgres:15
    container_name: scalecart_postgres
    restart: unless-stopped
    
    # Environment variables
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-scalecart}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-scalecart_password}
      POSTGRES_DB: ${POSTGRES_DB:-scalecart}
      POSTGRES_INITDB_ARGS: "--data-checksums"
      PGDATA: /var/lib/postgresql/data/pgdata
    
    # Port mapping
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    
    # Volumes for persistence
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./postgresql.conf:/etc/postgresql/postgresql.conf:ro
      - ./init-scripts:/docker-entrypoint-initdb.d:ro
    
    # Command override
    command: postgres -c config_file=/etc/postgresql/postgresql.conf
    
    # Health check
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-scalecart} -d ${POSTGRES_DB:-scalecart}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s
    
    # Resource limits
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G
    
    # Logging
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    
    # Network
    networks:
      - scalecart_network
    
    # Security
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_ADMIN
      - NET_RAW

  # ============================================
  # Redis Service
  # ============================================
  redis:
    image: redis:7-alpine
    container_name: scalecart_redis
    restart: unless-stopped
    
    command: redis-server
      --requirepass ${REDIS_PASSWORD:-scalecart_password}
      --maxmemory ${REDIS_MAXMEMORY:-512mb}
      --maxmemory-policy ${REDIS_MAXMEMORY_POLICY:-allkeys-lru}
      --save 60 1000
      --appendonly yes
      --appendfsync everysec
      --tcp-backlog 511
      --timeout 0
      --tcp-keepalive 300
    
    ports:
      - "${REDIS_PORT:-6379}:6379"
    
    volumes:
      - redis_data:/data
      - ./redis.conf:/usr/local/etc/redis/redis.conf:ro
    
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "${REDIS_PASSWORD:-scalecart_password}", "ping"]
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
    
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    
    networks:
      - scalecart_network

  # ============================================
  # MongoDB Service
  # ============================================
  mongodb:
    image: mongo:7.0
    container_name: scalecart_mongodb
    restart: unless-stopped
    
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER:-scalecart}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD:-scalecart_password}
      MONGO_INITDB_DATABASE: ${MONGO_DB:-scalecart}
    
    ports:
      - "${MONGO_PORT:-27017}:27017"
    
    volumes:
      - mongodb_data:/data/db
      - ./mongod.conf:/etc/mongod.conf:ro
    
    command: mongod --config /etc/mongod.conf
    
    healthcheck:
      test: ["CMD", "mongosh", "-u", "${MONGO_USER:-scalecart}", "-p", "${MONGO_PASSWORD:-scalecart_password}", "--authenticationDatabase", "admin", "--eval", "db.adminCommand('ping')"]
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
    
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    
    networks:
      - scalecart_network

  # ============================================
  # Neo4j Service
  # ============================================
  neo4j:
    image: neo4j:5-enterprise
    container_name: scalecart_neo4j
    restart: unless-stopped
    
    environment:
      NEO4J_AUTH: ${NEO4J_USER:-neo4j}/${NEO4J_PASSWORD:-scalecart_neo4j_password}
      NEO4J_ACCEPT_LICENSE_AGREEMENT: "yes"
      NEO4J_dbms_memory_heap_max__size: ${NEO4J_HEAP_MAX_SIZE:-2G}
      NEO4J_dbms_memory_pagecache_size: ${NEO4J_PAGE_CACHE_SIZE:-1G}
      NEO4J_dbms_logs_debug_level: "INFO"
    
    ports:
      - "7474:7474"
      - "7687:7687"
    
    volumes:
      - neo4j_data:/data
      - neo4j_logs:/logs
      - neo4j_plugins:/plugins
    
    healthcheck:
      test: ["CMD", "cypher-shell", "-u", "${NEO4J_USER:-neo4j}", "-p", "${NEO4J_PASSWORD:-scalecart_neo4j_password}", "RETURN 1"]
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
    
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    
    networks:
      - scalecart_network

  # ============================================
  # API Service
  # ============================================
  api:
    build:
      context: .
      dockerfile: Dockerfile
      target: ${API_TARGET:-development}
    
    container_name: scalecart_api
    restart: unless-stopped
    
    environment:
      APP_ENV: ${APP_ENV:-development}
      DEBUG: ${DEBUG:-true}
      LOG_LEVEL: ${LOG_LEVEL:-INFO}
      DATABASE_URL: ${DATABASE_URL}
      REDIS_URL: ${REDIS_URL}
      MONGODB_URI: ${MONGODB_URI}
      NEO4J_URI: ${NEO4J_URI}
      SECRET_KEY: ${SECRET_KEY:-dev-secret-key}
      JWT_SECRET_KEY: ${JWT_SECRET_KEY:-dev-jwt-secret}
      OPENAI_API_KEY: ${OPENAI_API_KEY:-}
      STRIPE_SECRET_KEY: ${STRIPE_SECRET_KEY:-}
      SENTRY_DSN: ${SENTRY_DSN:-}
    
    ports:
      - "${API_PORT:-8000}:8000"
    
    volumes:
      - ./src:/app/src
      - ./tests:/app/tests
      - ./alembic.ini:/app/alembic.ini
    
    depends_on:
      postgres:
        condition: service_healthy
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
      replicas: ${API_REPLICAS:-1}
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
    
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "10"
    
    networks:
      - scalecart_network
    
    command: ${API_COMMAND:-uvicorn src.api.app:app --host 0.0.0.0 --port 8000 --reload}

# ============================================
# Networks
# ============================================
networks:
  scalecart_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16
    name: scalecart_network

# ============================================
# Volumes
# ============================================
volumes:
  postgres_data:
    name: scalecart_postgres_data
  redis_data:
    name: scalecart_redis_data
  mongodb_data:
    name: scalecart_mongodb_data
  neo4j_data:
    name: scalecart_neo4j_data
  neo4j_logs:
    name: scalecart_neo4j_logs
  neo4j_plugins:
    name: scalecart_neo4j_plugins
```

---

## L.4 Application Configuration Reference

### L.4.1 FastAPI Configuration

```python
# File: src/config/settings.py
from typing import List, Optional
from pydantic import BaseSettings, Field, validator
from pydantic.networks import AnyUrl, PostgresDsn, RedisDsn

class Settings(BaseSettings):
    """Application settings."""
    
    # ============================================
    # APPLICATION
    # ============================================
    
    APP_NAME: str = "ScaleCart"
    APP_ENV: str = "development"
    DEBUG: bool = True
    SECRET_KEY: str = Field(..., min_length=32)
    
    ALLOWED_HOSTS: List[str] = ["localhost", "127.0.0.1"]
    API_PREFIX: str = "/api/v1"
    
    # ============================================
    # DATABASE
    # ============================================
    
    DATABASE_URL: PostgresDsn = Field(
        "postgresql://scalecart:scalecart_password@postgres:5432/scalecart"
    )
    DB_POOL_SIZE: int = 20
    DB_MAX_OVERFLOW: int = 40
    DB_POOL_TIMEOUT: int = 30
    DB_POOL_RECYCLE: int = 3600
    DB_ECHO: bool = False
    
    @validator("DATABASE_URL", pre=True)
    def validate_database_url(cls, v):
        if isinstance(v, str):
            return v
        return str(v)
    
    # ============================================
    # REDIS
    # ============================================
    
    REDIS_URL: RedisDsn = Field(
        "redis://:scalecart_password@redis:6379/0"
    )
    REDIS_MAX_CONNECTIONS: int = 50
    REDIS_SOCKET_TIMEOUT: int = 5
    
    # ============================================
    # MONGODB
    # ============================================
    
    MONGODB_URI: AnyUrl = Field(
        "mongodb://scalecart:scalecart_password@mongodb:27017/scalecart"
    )
    MONGODB_MAX_POOL_SIZE: int = 50
    MONGODB_MIN_POOL_SIZE: int = 10
    
    # ============================================
    # NEO4J
    # ============================================
    
    NEO4J_URI: str = "bolt://neo4j:7687"
    NEO4J_USER: str = "neo4j"
    NEO4J_PASSWORD: str = "scalecart_neo4j_password"
    NEO4J_MAX_POOL_SIZE: int = 50
    
    # ============================================
    # JWT
    # ============================================
    
    JWT_SECRET_KEY: str = Field(..., min_length=32)
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    JWT_REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    
    # ============================================
    # CACHING
    # ============================================
    
    ENABLE_CACHING: bool = True
    PRODUCT_CACHE_TTL: int = 3600
    CATEGORY_CACHE_TTL: int = 7200
    SESSION_TTL: int = 86400
    
    # ============================================
    # RATE LIMITING
    # ============================================
    
    ENABLE_RATE_LIMITING: bool = True
    RATE_LIMIT_PER_MINUTE: int = 100
    RATE_LIMIT_PER_HOUR: int = 1000
    RATE_LIMIT_PER_DAY: int = 10000
    
    # ============================================
    # CORS
    # ============================================
    
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
    ]
    
    # ============================================
    # FEATURE FLAGS
    # ============================================
    
    ENABLE_GRAPH_RECOMMENDATIONS: bool = True
    ENABLE_VECTOR_SEARCH: bool = False
    ENABLE_METRICS: bool = True
    ENABLE_AUDIT_LOG: bool = True
    ENABLE_TRACING: bool = False
    
    # ============================================
    # EXTERNAL SERVICES
    # ============================================
    
    OPENAI_API_KEY: Optional[str] = None
    STRIPE_SECRET_KEY: Optional[str] = None
    STRIPE_WEBHOOK_SECRET: Optional[str] = None
    
    AWS_ACCESS_KEY_ID: Optional[str] = None
    AWS_SECRET_ACCESS_KEY: Optional[str] = None
    AWS_REGION: str = "us-east-1"
    AWS_S3_BUCKET: Optional[str] = None
    
    SENTRY_DSN: Optional[str] = None
    
    # ============================================
    # LOGGING
    # ============================================
    
    LOG_LEVEL: str = "INFO"
    LOG_FORMAT: str = "json"
    LOG_FILE: Optional[str] = None
    
    # ============================================
    # SECURITY
    # ============================================
    
    SECURITY_HEADERS_ENABLED: bool = True
    HSTS_MAX_AGE: int = 31536000
    HSTS_INCLUDE_SUBDOMAINS: bool = True
    HSTS_PRELOAD: bool = True
    
    # ============================================
    # PERFORMANCE
    # ============================================
    
    WORKER_COUNT: int = 4
    WORKER_CONNECTIONS: int = 1000
    WORKER_TIMEOUT: int = 120
    
    COMPRESSION_ENABLED: bool = True
    COMPRESSION_MIN_SIZE: int = 1024
    COMPRESSION_LEVEL: int = 6
    
    # ============================================
    # VALIDATION
    # ============================================
    
    @validator("SECRET_KEY")
    def validate_secret_key(cls, v):
        if len(v) < 32:
            raise ValueError("SECRET_KEY must be at least 32 characters")
        return v
    
    @validator("JWT_SECRET_KEY")
    def validate_jwt_secret(cls, v):
        if len(v) < 32:
            raise ValueError("JWT_SECRET_KEY must be at least 32 characters")
        return v
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True
        extra = "ignore"

# Singleton instance
settings = Settings()
```

---

## L.5 Database Configuration Reference

### L.5.1 PostgreSQL Configuration

```ini
# File: postgresql.conf
# PostgreSQL configuration for ScaleCart

# ============================================
# CONNECTIONS AND AUTHENTICATION
# ============================================

listen_addresses = '*'
port = 5432
max_connections = 200
superuser_reserved_connections = 3

# Authentication
password_encryption = scram-sha-256

# ============================================
# MEMORY
# ============================================

shared_buffers = 4GB
work_mem = 64MB
maintenance_work_mem = 1GB
effective_cache_size = 12GB
huge_pages = try

# ============================================
# WRITE-AHEAD LOG
# ============================================

wal_level = replica
wal_buffers = 64MB
wal_writer_delay = 200ms
wal_compression = on

checkpoint_timeout = 15min
checkpoint_completion_target = 0.9
max_wal_size = 20GB
min_wal_size = 5GB

# ============================================
# QUERY TUNING
# ============================================

random_page_cost = 1.1
effective_io_concurrency = 200

# Parallel queries
max_parallel_workers_per_gather = 4
max_parallel_workers = 8
parallel_tuple_cost = 0.1
parallel_setup_cost = 1000.0

# Join optimization
join_collapse_limit = 8
from_collapse_limit = 8

# ============================================
# STATISTICS
# ============================================

default_statistics_target = 100
track_activities = on
track_counts = on
track_io_timing = on
track_functions = all

# ============================================
# AUTOVACUUM
# ============================================

autovacuum = on
autovacuum_naptime = 10s
autovacuum_vacuum_threshold = 1000
autovacuum_analyze_threshold = 500
autovacuum_vacuum_scale_factor = 0.05
autovacuum_analyze_scale_factor = 0.02
autovacuum_vacuum_cost_delay = 2ms
autovacuum_vacuum_cost_limit = 1000

# ============================================
# LOGGING
# ============================================

log_destination = 'stderr'
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB

log_min_duration_statement = 1000
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on
log_temp_files = 0
log_autovacuum_min_duration = 1000

# ============================================
# EXTENSIONS
# ============================================

shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.track = all
pg_stat_statements.max = 10000

# ============================================
# REPLICATION (for read replicas)
# ============================================

# hot_standby = on
# max_wal_senders = 10
# wal_keep_segments = 100
# max_replication_slots = 10
```

### L.5.2 Redis Configuration

```ini
# File: redis.conf
# Redis configuration for ScaleCart

# ============================================
# MEMORY MANAGEMENT
# ============================================

maxmemory 512mb
maxmemory-policy allkeys-lru
maxmemory-samples 5

# ============================================
# PERSISTENCE
# ============================================

# RDB persistence
save 900 1
save 300 10
save 60 10000

# AOF persistence
appendonly yes
appendfsync everysec
no-appendfsync-on-rewrite yes
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# ============================================
# PERFORMANCE
# ============================================

tcp-backlog 511
timeout 0
tcp-keepalive 300
lazyfree-lazy-eviction yes
lazyfree-lazy-expire yes
lazyfree-lazy-server-del yes
replica-lazy-flush yes

# ============================================
# SECURITY
# ============================================

# requirepass scalecart_password
# masterauth scalecart_password

# ============================================
# MONITORING
# ============================================

slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 100

# ============================================
# ADVANCED
# ============================================

hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
```

### L.5.3 MongoDB Configuration

```yaml
# File: mongod.conf
# MongoDB configuration for ScaleCart

systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true
  logRotate: reopen

storage:
  dbPath: /data/db
  journal:
    enabled: true
  wiredTiger:
    engineConfig:
      cacheSizeGB: 8
      journalCompressor: snappy
    collectionConfig:
      blockCompressor: snappy
    indexConfig:
      prefixCompression: true

net:
  port: 27017
  bindIp: 0.0.0.0
  maxIncomingConnections: 1000
  serviceExecutor: adaptive

security:
  authorization: enabled
  keyFile: /data/keyfile

setParameter:
  enableLocalhostAuthBypass: false

operationProfiling:
  mode: slowOp
  slowOpThresholdMs: 100
  slowOpSampleRate: 0.1

replication:
  oplogSizeMB: 2048
  replSetName: rs0

# For replica sets:
# replication:
#   replSetName: rs0
#   oplogSizeMB: 2048
```

---

## L.6 Monitoring Configuration

### L.6.1 Prometheus Configuration

```yaml
# File: prometheus.yml
# Prometheus configuration

global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: scalecart
    environment: production

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

rule_files:
  # - "alerts.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'scalecart-api'
    metrics_path: /metrics
    static_configs:
      - targets: ['api:8000']

  - job_name: 'postgresql'
    static_configs:
      - targets: ['postgres-exporter:9187']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']

  - job_name: 'mongodb'
    static_configs:
      - targets: ['mongodb-exporter:9216']

  - job_name: 'neo4j'
    static_configs:
      - targets: ['neo4j-exporter:9100']

  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'container'
    static_configs:
      - targets: ['cadvisor:8080']
```

### L.6.2 Alert Rules

```yaml
# File: alerts.yml
# Prometheus alert rules

groups:
  - name: scalecart_alerts
    interval: 30s
    rules:
      - alert: APIHighErrorRate
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m])) / 
          sum(rate(http_requests_total[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High API error rate"
          description: "API error rate is {{ $value }}% for 5 minutes"

      - alert: DatabaseHighConnections
        expr: pg_stat_database_numbackends > 150
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Database connections high"
          description: "{{ $value }} connections to PostgreSQL"

      - alert: RedisMemoryHigh
        expr: redis_memory_used_bytes / redis_memory_max_bytes > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Redis memory usage high"
          description: "Redis using {{ $value }}% of memory"

      - alert: ServiceDown
        expr: up{job="scalecart-api"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "API service is down"
          description: "API service has been down for 1 minute"

      - alert: SlowQueries
        expr: |
          increase(pg_stat_statements_mean_time{mean_time>5000}[5m]) > 10
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Slow queries detected"
          description: "More than 10 queries > 5s in last 5 minutes"

      - alert: DiskSpaceLow
        expr: node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"} < 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space low"
          description: "Only {{ $value }}% disk space remaining"
```

---

## L.7 Security Configuration Reference

### L.7.1 TLS/SSL Configuration

```python
# File: src/security/tls_config.py
import ssl
from pathlib import Path
from typing import Optional

class TLSConfig:
    """TLS configuration."""
    
    # Certificate paths
    CERT_PATH: Path = Path("/etc/ssl/certs/server.crt")
    KEY_PATH: Path = Path("/etc/ssl/private/server.key")
    CA_PATH: Optional[Path] = Path("/etc/ssl/certs/ca.pem")
    
    # Protocol settings
    MINIMUM_VERSION: int = ssl.TLSVersion.TLSv1_2
    CIPHERS: str = 'ECDHE+AESGCM:ECDHE+CHACHA20:DHE+AESGCM'
    
    # Verification
    VERIFY_MODE: bool = True
    VERIFY_DEPTH: int = 2
    
    @classmethod
    def get_ssl_context(cls) -> ssl.SSLContext:
        """Get SSL context for secure connections."""
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        
        if cls.CERT_PATH.exists() and cls.KEY_PATH.exists():
            context.load_cert_chain(
                str(cls.CERT_PATH),
                str(cls.KEY_PATH)
            )
            
            if cls.CA_PATH and cls.VERIFY_MODE:
                context.load_verify_locations(str(cls.CA_PATH))
                context.verify_mode = ssl.CERT_REQUIRED
                context.verify_depth = cls.VERIFY_DEPTH
        
        context.minimum_version = cls.MINIMUM_VERSION
        context.set_ciphers(cls.CIPHERS)
        context.options |= ssl.OP_NO_TICKET
        context.options |= ssl.OP_NO_COMPRESSION
        
        return context
```

---

## L.8 Quick Configuration Reference

### L.8.1 Essential Configuration Checklist

| Setting | Development | Staging | Production |
|---------|-------------|---------|------------|
| `APP_ENV` | development | staging | production |
| `DEBUG` | true | false | false |
| `LOG_LEVEL` | DEBUG | INFO | INFO |
| `SECRET_KEY` | dev-secret | staging-secret | production-secret |
| `DATABASE_URL` | localhost | staging-db | production-db |
| `REDIS_URL` | localhost | staging-redis | production-redis |
| `DB_POOL_SIZE` | 5 | 20 | 40 |
| `RATE_LIMIT_PER_MINUTE` | 1000 | 100 | 100 |

### L.8.2 Environment Variable Precedence

1. Command line arguments
2. Environment variables
3. .env file
4. Default values

### L.8.3 Common Configuration Mistakes

| Mistake | Solution |
|---------|----------|
| Leaving `DEBUG=true` in production | Set `DEBUG=false` |
| Using default secret keys | Generate new keys for each environment |
| Not setting `ALLOWED_HOSTS` | Add production domain to ALLOWED_HOSTS |
| Using default passwords | Use secure, random passwords |
| Not configuring SSL | Enable SSL with proper certificates |

---

**[END OF APPENDIX L]**

*This complete configuration reference provides all available settings for the ScaleCart platform. Use it to customize your deployment for any environment.*
