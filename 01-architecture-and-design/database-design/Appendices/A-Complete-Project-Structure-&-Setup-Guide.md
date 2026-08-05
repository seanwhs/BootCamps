# APPENDIX A — Complete Project Structure & Setup Guide

---

## A.1 Introduction to the Appendix

This appendix provides a comprehensive reference for the entire ScaleCart project structure, complete setup instructions, and all configuration files needed to run the application. Use this as your canonical source for recreating the environment from scratch.

**This appendix covers:**

1. Complete directory structure with all files
2. Environment configuration
3. Docker setup and orchestration
4. Database initialization scripts
5. Python dependency management
6. Makefile for common operations
7. Quick start guide

---

## A.2 Complete Project Directory Structure

```
scalecart/
├── .env.example                 # Environment variables template
├── .gitignore                   # Git ignore rules
├── docker-compose.yml           # Main Docker orchestration
├── docker-compose.prod.yml      # Production Docker setup
├── Dockerfile                   # Application container build
├── Makefile                     # Common operations shortcuts
├── README.md                    # Project documentation
├── requirements.txt             # Python dependencies
├── alembic.ini                  # Alembic migration configuration
├── postgresql.conf              # PostgreSQL performance tuning
├── prometheus.yml               # Prometheus monitoring config
│
├── backups/                     # Backup storage (created at runtime)
├── backups-scripts/             # Backup automation scripts
│   └── backup.sh
│
├── init-scripts/                # Database initialization
│   ├── 01-schema.sql            # Core schema creation
│   ├── 02-indexes.sql           # Performance indexes
│   ├── 03-triggers.sql          # Triggers and functions
│   └── 04-seed-data.sql         # Initial test data
│
├── src/                         # Source code
│   ├── __init__.py
│   ├── api/                     # API layer
│   │   ├── __init__.py
│   │   ├── app.py               # Flask/FastAPI application
│   │   ├── health.py            # Health check endpoints
│   │   ├── routes/              # API route handlers
│   │   │   ├── __init__.py
│   │   │   ├── products.py
│   │   │   ├── orders.py
│   │   │   └── customers.py
│   │   └── middleware/          # Request/response middleware
│   │       ├── __init__.py
│   │       ├── auth.py
│   │       └── logging.py
│   │
│   ├── models/                  # Database models
│   │   ├── __init__.py
│   │   ├── base.py              # SQLAlchemy Base
│   │   ├── product.py
│   │   ├── order.py
│   │   ├── customer.py
│   │   ├── inventory.py
│   │   ├── payment.py
│   │   └── review.py
│   │
│   ├── services/                # Business logic
│   │   ├── __init__.py
│   │   ├── order_service.py
│   │   ├── product_service.py
│   │   ├── inventory_service.py
│   │   ├── catalog_cache.py     # MongoDB cache
│   │   ├── session_manager.py   # Redis session
│   │   ├── graph_service.py     # Neo4j graph
│   │   ├── metrics_service.py   # TimescaleDB metrics
│   │   ├── vector_service.py    # pgvector search
│   │   ├── saga_orchestrator.py # Distributed transactions
│   │   └── outbox_*.py          # Outbox pattern
│   │
│   ├── migrations/              # Alembic migrations
│   │   ├── env.py
│   │   ├── script.py.mako
│   │   └── versions/
│   │       ├── 001_initial_schema.py
│   │       ├── 002_add_product_indexes.py
│   │       ├── 003_partition_orders.py
│   │       └── 004_add_weight_to_products.py
│   │
│   ├── scripts/                 # Utility scripts
│   │   ├── __init__.py
│   │   ├── generate_test_data.py
│   │   ├── populate_graph.py
│   │   ├── backfill_embeddings.py
│   │   └── rollback.py
│   │
│   └── utils/                   # Shared utilities
│       ├── __init__.py
│       ├── db.py                # Database connections
│       ├── config.py            # Configuration management
│       └── logging.py           # Logging setup
│
├── tests/                       # Test suite
│   ├── __init__.py
│   ├── conftest.py              # Pytest fixtures
│   ├── test_migrations.py
│   ├── test_models.py
│   ├── test_services.py
│   └── test_api.py
│
└── docs/                        # Documentation
    ├── architecture.md
    ├── erd.png
    ├── migration_guide.md
    └── api_reference.md
```

---

## A.3 Environment Configuration

### A.3.1 .env.example File

```bash
# File: .env.example
# Copy this to .env and fill in your values

# ============================================
# DATABASE CONFIGURATION
# ============================================

# PostgreSQL
POSTGRES_USER=scalecart
POSTGRES_PASSWORD=scalecart_password
POSTGRES_DB=scalecart
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}

# MongoDB
MONGO_USER=scalecart
MONGO_PASSWORD=scalecart_password
MONGO_DB=scalecart
MONGO_HOST=mongodb
MONGO_PORT=27017
MONGO_URI=mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB}

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=scalecart_password
REDIS_URL=redis://:${REDIS_PASSWORD}@${REDIS_HOST}:${REDIS_PORT}/0

# Neo4j
NEO4J_HOST=neo4j
NEO4J_PORT=7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=scalecart_neo4j_password
NEO4J_URI=bolt://${NEO4J_HOST}:${NEO4J_PORT}

# TimescaleDB (metrics)
TIMESCALE_HOST=timescaledb
TIMESCALE_PORT=5433
TIMESCALE_USER=scalecart
TIMESCALE_PASSWORD=scalecart_password
TIMESCALE_DB=scalecart_metrics
TIMESCALE_URL=postgresql://${TIMESCALE_USER}:${TIMESCALE_PASSWORD}@${TIMESCALE_HOST}:${TIMESCALE_PORT}/${TIMESCALE_DB}

# ============================================
# APPLICATION CONFIGURATION
# ============================================

# Flask/FastAPI
APP_NAME=ScaleCart
APP_ENV=development
DEBUG=true
SECRET_KEY=your-secret-key-here-change-in-production
JWT_SECRET_KEY=your-jwt-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1

# API Settings
API_VERSION=v1
API_PREFIX=/api/v1
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# ============================================
# EXTERNAL SERVICES
# ============================================

# OpenAI (for embeddings)
OPENAI_API_KEY=your-openai-api-key-here

# Stripe (payments)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# AWS (for backups)
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_S3_BUCKET=scalecart-backups
AWS_REGION=us-east-1

# ============================================
# PERFORMANCE TUNING
# ============================================

# Connection Pool
DB_POOL_SIZE=20
DB_MAX_OVERFLOW=40
DB_POOL_TIMEOUT=30

# Cache TTLs (seconds)
PRODUCT_CACHE_TTL=3600
SESSION_TTL=86400
RATE_LIMIT_CACHE_TTL=60

# Logging
LOG_LEVEL=INFO
LOG_FILE=/var/log/scalecart/app.log

# ============================================
# FEATURE FLAGS
# ============================================

ENABLE_CACHING=true
ENABLE_GRAPH_RECOMMENDATIONS=true
ENABLE_VECTOR_SEARCH=false
ENABLE_METRICS=true
ENABLE_RATE_LIMITING=true
```

### A.3.2 .gitignore File

```gitignore
# File: .gitignore

# Python
__pycache__/
*.py[cod]
*.so
.Python
env/
venv/
ENV/
dist/
build/
*.egg-info/
*.egg
.eggs/

# Environment
.env
.env.local
.env.production

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Database
*.db
*.sqlite
*.sqlite3
*.postgresql
*.dump
backups/
*.rdb
*.tar.gz

# Logs
logs/
*.log
*.pid

# Docker
*.pid
*.sock
docker-compose.override.yml
.data/
postgres_data/
redis_data/
mongodb_data/
neo4j_data/
timescaledb_data/
prometheus_data/
grafana_data/

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/
*_test.py

# Alembic
src/migrations/versions/*.pyc
src/migrations/versions/*.py.orig

# OS
.DS_Store
Thumbs.db

# Sensitive
*.pem
*.key
*.crt
secrets/
```

---

## A.4 Docker Configuration

### A.4.1 Full docker-compose.yml

```yaml
# File: docker-compose.yml
version: '3.8'

services:
  # ============================================
  # POSTGRESQL - Primary Database
  # ============================================
  postgres:
    image: postgres:15
    container_name: scalecart_postgres
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-scalecart}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-scalecart_password}
      POSTGRES_DB: ${POSTGRES_DB:-scalecart}
      POSTGRES_INITDB_ARGS: "--data-checksums"
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./postgresql.conf:/etc/postgresql/postgresql.conf:ro
      - ./init-scripts:/docker-entrypoint-initdb.d:ro
    command: postgres -c config_file=/etc/postgresql/postgresql.conf
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-scalecart} -d ${POSTGRES_DB:-scalecart}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    networks:
      - scalecart_network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ============================================
  # MONGODB - Document Cache
  # ============================================
  mongodb:
    image: mongo:7.0
    container_name: scalecart_mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: ${MONGO_USER:-scalecart}
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD:-scalecart_password}
      MONGO_INITDB_DATABASE: ${MONGO_DB:-scalecart}
    ports:
      - "${MONGO_PORT:-27017}:27017"
    volumes:
      - mongodb_data:/data/db
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    networks:
      - scalecart_network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ============================================
  # REDIS - Session & Cache Store
  # ============================================
  redis:
    image: redis:7-alpine
    container_name: scalecart_redis
    command: redis-server 
      --requirepass ${REDIS_PASSWORD:-scalecart_password}
      --maxmemory 512mb
      --maxmemory-policy allkeys-lru
      --save 60 1000
      --appendonly yes
    ports:
      - "${REDIS_PORT:-6379}:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    networks:
      - scalecart_network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ============================================
  # NEO4J - Graph Database
  # ============================================
  neo4j:
    image: neo4j:5-enterprise
    container_name: scalecart_neo4j
    environment:
      NEO4J_AUTH: ${NEO4J_USER:-neo4j}/${NEO4J_PASSWORD:-scalecart_neo4j_password}
      NEO4J_ACCEPT_LICENSE_AGREEMENT: "yes"
      NEO4J_dbms_memory_heap_max__size: 2G
      NEO4J_dbms_memory_pagecache_size: 1G
      NEO4J_dbms_logs_debug_level: "INFO"
    ports:
      - "7474:7474"  # HTTP
      - "7687:7687"  # Bolt
    volumes:
      - neo4j_data:/data
      - neo4j_logs:/logs
    healthcheck:
      test: ["CMD", "cypher-shell", "-u", "${NEO4J_USER:-neo4j}", "-p", "${NEO4J_PASSWORD:-scalecart_neo4j_password}", "RETURN 1"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped
    networks:
      - scalecart_network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ============================================
  # TIMESCALEDB - Time-Series Metrics
  # ============================================
  timescaledb:
    image: timescale/timescaledb:2.11-pg15
    container_name: scalecart_timescaledb
    environment:
      POSTGRES_USER: ${TIMESCALE_USER:-scalecart}
      POSTGRES_PASSWORD: ${TIMESCALE_PASSWORD:-scalecart_password}
      POSTGRES_DB: ${TIMESCALE_DB:-scalecart_metrics}
      TIMESCALEDB_TELEMETRY: "off"
    ports:
      - "${TIMESCALE_PORT:-5433}:5432"
    volumes:
      - timescaledb_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${TIMESCALE_USER:-scalecart} -d ${TIMESCALE_DB:-scalecart_metrics}"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped
    networks:
      - scalecart_network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ============================================
  # PROMETHEUS - Monitoring
  # ============================================
  prometheus:
    image: prom/prometheus:v2.46.0
    container_name: scalecart_prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=15d'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
      - '--web.enable-lifecycle'
    restart: unless-stopped
    networks:
      - scalecart_network
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
    container_name: scalecart_grafana
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD:-admin}
      GF_INSTALL_PLUGINS: grafana-piechart-panel,grafana-clock-panel
      GF_SERVER_ROOT_URL: http://localhost:3000
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana-provisioning:/etc/grafana/provisioning:ro
    ports:
      - "3000:3000"
    depends_on:
      - prometheus
    restart: unless-stopped
    networks:
      - scalecart_network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ============================================
  # PGBOUNCER - Connection Pooling
  # ============================================
  pgbouncer:
    image: edoburu/pgbouncer:latest
    container_name: scalecart_pgbouncer
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER:-scalecart}:${POSTGRES_PASSWORD:-scalecart_password}@postgres:5432/${POSTGRES_DB:-scalecart}
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
    networks:
      - scalecart_network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ============================================
  # APPLICATION API (Python)
  # ============================================
  api:
    build:
      context: .
      dockerfile: Dockerfile
      target: development
    container_name: scalecart_api
    environment:
      DATABASE_URL: postgresql://${POSTGRES_USER:-scalecart}:${POSTGRES_PASSWORD:-scalecart_password}@pgbouncer:6432/${POSTGRES_DB:-scalecart}
      MONGO_URI: mongodb://${MONGO_USER:-scalecart}:${MONGO_PASSWORD:-scalecart_password}@mongodb:27017/${MONGO_DB:-scalecart}
      REDIS_URL: redis://:${REDIS_PASSWORD:-scalecart_password}@redis:6379/0
      NEO4J_URI: bolt://neo4j:7687
      NEO4J_USER: ${NEO4J_USER:-neo4j}
      NEO4J_PASSWORD: ${NEO4J_PASSWORD:-scalecart_neo4j_password}
      TIMESCALE_URL: postgresql://${TIMESCALE_USER:-scalecart}:${TIMESCALE_PASSWORD:-scalecart_password}@timescaledb:5432/${TIMESCALE_DB:-scalecart_metrics}
      OPENAI_API_KEY: ${OPENAI_API_KEY:-}
      SECRET_KEY: ${SECRET_KEY:-dev-secret-key}
      APP_ENV: ${APP_ENV:-development}
      DEBUG: ${DEBUG:-true}
      LOG_LEVEL: ${LOG_LEVEL:-INFO}
    ports:
      - "8000:8000"
    volumes:
      - ./src:/app/src
      - ./tests:/app/tests
    depends_on:
      postgres:
        condition: service_healthy
      mongodb:
        condition: service_healthy
      redis:
        condition: service_healthy
      neo4j:
        condition: service_healthy
      timescaledb:
        condition: service_healthy
      pgbouncer:
        condition: service_started
    restart: unless-stopped
    networks:
      - scalecart_network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
    command: uvicorn src.api.app:app --host 0.0.0.0 --port 8000 --reload

# ============================================
# NETWORK
# ============================================
networks:
  scalecart_network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16

# ============================================
# VOLUMES (Persistent Data)
# ============================================
volumes:
  postgres_data:
    driver: local
  mongodb_data:
    driver: local
  redis_data:
    driver: local
  neo4j_data:
    driver: local
  neo4j_logs:
    driver: local
  timescaledb_data:
    driver: local
  prometheus_data:
    driver: local
  grafana_data:
    driver: local
```

### A.4.2 Dockerfile

```dockerfile
# File: Dockerfile
# Multi-stage build for ScaleCart API

# ============================================
# STAGE 1: Builder
# ============================================
FROM python:3.10-slim AS builder

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ============================================
# STAGE 2: Development
# ============================================
FROM python:3.10-slim AS development

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN addgroup --system --gid 1001 app && \
    adduser --system --uid 1001 --gid 1001 app

# Copy installed packages from builder
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

WORKDIR /app

# Copy application code
COPY src/ /app/src/
COPY alembic.ini /app/
COPY pyproject.toml /app/ 2>/dev/null || true

# Set ownership
RUN chown -R app:app /app

USER app

# Expose port
EXPOSE 8000

# Development command with hot reload
CMD ["uvicorn", "src.api.app:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

# ============================================
# STAGE 3: Production
# ============================================
FROM development AS production

# Remove development dependencies
RUN pip uninstall -y pytest pytest-cov pytest-postgresql || true

# Copy production requirements
COPY requirements-prod.txt .
RUN pip install --no-cache-dir -r requirements-prod.txt

# Run with production settings
ENV APP_ENV=production
ENV DEBUG=false

CMD ["gunicorn", "-w", "4", "-k", "uvicorn.workers.UvicornWorker", "src.api.app:app", "--bind", "0.0.0.0:8000"]
```

---

## A.5 Database Initialization Scripts

### A.5.1 01-schema.sql (Core Schema)

```sql
-- File: init-scripts/01-schema.sql
-- ScaleCart Core Schema
-- PostgreSQL 15+

-- ============================================
-- EXTENSIONS
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- ============================================
-- CATEGORIES
-- ============================================

CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    parent_category_id INTEGER REFERENCES categories(id) ON DELETE RESTRICT,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE categories IS 'Product categories with hierarchical self-reference';
COMMENT ON COLUMN categories.parent_category_id IS 'Self-reference for subcategories';

-- ============================================
-- SUPPLIERS
-- ============================================

CREATE TABLE IF NOT EXISTS suppliers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    contact_email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE suppliers IS 'Product suppliers and vendors';

-- ============================================
-- PRODUCTS
-- ============================================

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    weight_kg NUMERIC(5,2) DEFAULT 0.0,
    sku VARCHAR(50) UNIQUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    search_vector TSVECTOR GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B')
    ) STORED
);

COMMENT ON TABLE products IS 'Core product catalog with full-text search support';

-- Create GIN index for full-text search
CREATE INDEX IF NOT EXISTS idx_products_search_vector ON products USING GIN (search_vector);

-- ============================================
-- SUPPLIER_PRODUCTS (Junction)
-- ============================================

CREATE TABLE IF NOT EXISTS supplier_products (
    supplier_id INTEGER NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    supply_price NUMERIC(10,2) NOT NULL CHECK (supply_price >= 0),
    is_preferred BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (supplier_id, product_id)
);

COMMENT ON TABLE supplier_products IS 'Many-to-many between suppliers and products with supply pricing';

-- ============================================
-- CUSTOMERS
-- ============================================

CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    registered_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    version INTEGER DEFAULT 1, -- Optimistic locking
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE customers IS 'Registered customers with authentication';

-- ============================================
-- ADDRESSES
-- ============================================

CREATE TABLE IF NOT EXISTS addresses (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    address_type VARCHAR(20) NOT NULL DEFAULT 'shipping' CHECK (address_type IN ('shipping', 'billing', 'both')),
    street VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE addresses IS 'Customer shipping and billing addresses';

-- ============================================
-- ORDERS
-- ============================================

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    order_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled', 'refunded')),
    total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
    shipping_address_id INTEGER REFERENCES addresses(id) ON DELETE SET NULL,
    billing_address_id INTEGER REFERENCES addresses(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE orders IS 'Customer orders with status tracking';

-- ============================================
-- ORDER_ITEMS
-- ============================================

CREATE TABLE IF NOT EXISTS order_items (
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    discount_percent NUMERIC(5,2) DEFAULT 0.0 CHECK (discount_percent >= 0 AND discount_percent <= 100),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (order_id, product_id)
);

COMMENT ON TABLE order_items IS 'Line items within an order (historical snapshot of price)';

-- ============================================
-- INVENTORY
-- ============================================

CREATE TABLE IF NOT EXISTS inventory (
    product_id INTEGER PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    reserved_quantity INTEGER NOT NULL DEFAULT 0 CHECK (reserved_quantity >= 0),
    reorder_threshold INTEGER NOT NULL DEFAULT 10 CHECK (reorder_threshold >= 0),
    reorder_quantity INTEGER DEFAULT 100,
    last_restocked_at TIMESTAMPTZ,
    last_updated TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE inventory IS 'Current stock levels with reservation tracking';

-- ============================================
-- PAYMENTS
-- ============================================

CREATE TABLE IF NOT EXISTS payments (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    method VARCHAR(30) NOT NULL CHECK (method IN ('credit_card', 'paypal', 'bank_transfer', 'apple_pay', 'google_pay')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
    transaction_id VARCHAR(100),
    payment_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE payments IS 'Payment records with transaction tracking';

-- ============================================
-- REVIEWS
-- ============================================

CREATE TABLE IF NOT EXISTS reviews (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(200),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_count INTEGER DEFAULT 0,
    review_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (product_id, customer_id)
);

COMMENT ON TABLE reviews IS 'Product reviews from customers with verification';

-- ============================================
-- OUTBOX MESSAGES
-- ============================================

CREATE TABLE IF NOT EXISTS outbox_messages (
    id SERIAL PRIMARY KEY,
    message_id UUID NOT NULL UNIQUE DEFAULT uuid_generate_v4(),
    aggregate_id VARCHAR(100) NOT NULL,
    aggregate_type VARCHAR(50) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMPTZ,
    retry_count INTEGER DEFAULT 0,
    last_error TEXT
);

COMMENT ON TABLE outbox_messages IS 'Transactional outbox for reliable event publishing';

CREATE INDEX IF NOT EXISTS idx_outbox_messages_published ON outbox_messages (published_at NULLS FIRST) WHERE published_at IS NULL;

-- ============================================
-- AUDIT LOG
-- ============================================

CREATE TABLE IF NOT EXISTS audit_log (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id INTEGER NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_data JSONB,
    new_data JSONB,
    changed_by INTEGER REFERENCES customers(id) ON DELETE SET NULL,
    changed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    client_ip INET,
    user_agent TEXT
);

COMMENT ON TABLE audit_log IS 'Audit trail for all data modifications';
```

### A.5.2 02-indexes.sql

```sql
-- File: init-scripts/02-indexes.sql
-- Performance Indexes for ScaleCart

-- ============================================
-- FOREIGN KEY INDEXES
-- ============================================

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_products_sku ON products(sku);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_addresses_customer_id ON addresses(customer_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_shipping_address_id ON orders(shipping_address_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_billing_address_id ON orders(billing_address_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_payments_order_id ON payments(order_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_payments_transaction_id ON payments(transaction_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_reviews_product_id ON reviews(product_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_reviews_customer_id ON reviews(customer_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_categories_parent_category_id ON categories(parent_category_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_supplier_products_supplier_id ON supplier_products(supplier_id);
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_supplier_products_product_id ON supplier_products(product_id);

-- ============================================
-- COMPOSITE INDEXES
-- ============================================

-- Orders by customer and status (common query pattern)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_customer_status ON orders(customer_id, status);

-- Orders by date range
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_order_date ON orders(order_date DESC);

-- Order items by order and product (already composite PK, but we add descending)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_order_items_order_id_product_id ON order_items(order_id, product_id);

-- Reviews by product rating
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_reviews_product_rating ON reviews(product_id, rating DESC);

-- ============================================
-- PARTIAL INDEXES
-- ============================================

-- Only active customers
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_customers_active_email ON customers(email) WHERE is_active = true;

-- Only pending orders (for queue processing)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_pending ON orders(order_date) WHERE status = 'pending';

-- Products with low stock (for reorder alerts)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_inventory_low_stock ON inventory(product_id) WHERE stock_quantity < reorder_threshold;

-- ============================================
-- EXPRESSION INDEXES
-- ============================================

-- Case-insensitive email search
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_customers_email_lower ON customers(LOWER(email));

-- Case-insensitive product name search
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_products_name_lower ON products(LOWER(name));

-- ============================================
-- COVERING INDEXES
-- ============================================

-- Cover product name, price, category in queries
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_products_covering ON products(category_id) INCLUDE (name, price);

-- Cover order total for customer queries
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_covering ON orders(customer_id) INCLUDE (total_amount, status);

-- ============================================
-- BRIN INDEXES (for large tables with natural ordering)
-- ============================================

-- For order_date on very large tables (millions+ rows)
-- CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_orders_order_date_brin ON orders USING BRIN (order_date);

-- ============================================
-- GIN INDEXES (full-text and arrays)
-- ============================================

-- For product name trigram search (partial matches)
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_products_name_trgm ON products USING GIN (name gin_trgm_ops);

-- ============================================
-- STATISTICS
-- ============================================

-- Increase statistics for columns with skewed distributions
ALTER TABLE products ALTER COLUMN category_id SET STATISTICS 1000;
ALTER TABLE orders ALTER COLUMN customer_id SET STATISTICS 1000;
ALTER TABLE order_items ALTER COLUMN product_id SET STATISTICS 1000;

-- Update statistics
ANALYZE products;
ANALYZE orders;
ANALYZE customers;
ANALYZE order_items;
```

---

## A.6 Python Dependencies

### A.6.1 requirements.txt

```txt
# File: requirements.txt
# Core dependencies for ScaleCart

# ============================================
# WEB FRAMEWORK
# ============================================
fastapi==0.104.1
uvicorn[standard]==0.24.0
gunicorn==21.2.0
python-multipart==0.0.6
python-dotenv==1.0.0

# ============================================
# DATABASE - PostgreSQL
# ============================================
psycopg2-binary==2.9.9
sqlalchemy==2.0.23
alembic==1.12.1
asyncpg==0.29.0

# ============================================
# DATABASE - MongoDB
# ============================================
pymongo==4.6.1

# ============================================
# DATABASE - Redis
# ============================================
redis==5.0.1

# ============================================
# DATABASE - Neo4j
# ============================================
neo4j==5.15.0

# ============================================
# DATA VALIDATION & SERIALIZATION
# ============================================
pydantic==2.5.0
pydantic-settings==2.1.0
email-validator==2.1.0

# ============================================
# AUTHENTICATION & SECURITY
# ============================================
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6

# ============================================
# EXTERNAL SERVICES
# ============================================
openai==1.3.0
stripe==6.12.0
boto3==1.33.0

# ============================================
# UTILITIES
# ============================================
faker==20.0.0
requests==2.31.0
tenacity==8.2.3
structlog==24.1.0
prometheus-client==0.19.0

# ============================================
# TESTING
# ============================================
pytest==7.4.3
pytest-cov==4.1.0
pytest-asyncio==0.21.1
pytest-postgresql==5.0.0
pytest-mock==3.12.0
httpx==0.25.2

# ============================================
# DEVELOPMENT
# ============================================
black==23.11.0
flake8==6.1.0
mypy==1.7.0
isort==5.12.0
pre-commit==3.5.0

# ============================================
# MONITORING
# ============================================
opentelemetry-api==1.21.0
opentelemetry-sdk==1.21.0
opentelemetry-instrumentation-fastapi==0.42b0
opentelemetry-exporter-jaeger==1.21.0
```

### A.6.2 requirements-prod.txt

```txt
# File: requirements-prod.txt
# Production-only dependencies

-r requirements.txt

# Remove development packages (clean install)
# These will be installed in production

# ============================================
# PRODUCTION PERFORMANCE
# ============================================
ujson==5.8.0
orjson==3.9.10
python-snappy==0.6.1
```

---

## A.7 Makefile for Common Operations

```makefile
# File: Makefile
# Common operations for ScaleCart

.PHONY: help build up down restart logs shell psql mongo redis neo4j test lint format clean backup

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

help:
	@echo "${GREEN}ScaleCart Makefile Commands${NC}"
	@echo ""
	@echo "${YELLOW}Environment:${NC}"
	@echo "  make env          Create .env from .env.example"
	@echo ""
	@echo "${YELLOW}Docker:${NC}"
	@echo "  make build        Build Docker images"
	@echo "  make up           Start all services"
	@echo "  make down         Stop all services"
	@echo "  make restart      Restart all services"
	@echo "  make logs         View logs"
	@echo "  make logs-api     View API logs"
	@echo "  make logs-db      View PostgreSQL logs"
	@echo ""
	@echo "${YELLOW}Shell Access:${NC}"
	@echo "  make shell        Open shell in API container"
	@echo "  make psql         Connect to PostgreSQL"
	@echo "  make mongo        Connect to MongoDB"
	@echo "  make redis        Connect to Redis CLI"
	@echo "  make neo4j        Connect to Neo4j Cypher shell"
	@echo ""
	@echo "${YELLOW}Database:${NC}"
	@echo "  make db-init      Initialize database schema"
	@echo "  make db-seed      Seed database with test data"
	@echo "  make db-migrate   Run Alembic migrations"
	@echo "  make db-rollback  Rollback last migration"
	@echo "  make db-backup    Create database backup"
	@echo "  make db-reset     Reset database (danger!)"
	@echo ""
	@echo "${YELLOW}Testing:${NC}"
	@echo "  make test         Run all tests"
	@echo "  make test-unit    Run unit tests"
	@echo "  make test-integration Run integration tests"
	@echo ""
	@echo "${YELLOW}Code Quality:${NC}"
	@echo "  make lint         Run linters"
	@echo "  make format       Format code"
	@echo "  make type-check   Run mypy type checking"
	@echo ""
	@echo "${YELLOW}Cleanup:${NC}"
	@echo "  make clean        Remove Python cache and build artifacts"
	@echo "  make clean-data   Remove all data volumes (danger!)"

# ============================================
# ENVIRONMENT
# ============================================

env:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "${GREEN}Created .env from .env.example${NC}"; \
	else \
		echo "${YELLOW}.env already exists${NC}"; \
	fi

# ============================================
# DOCKER COMMANDS
# ============================================

build:
	docker compose build

up:
	docker compose up -d
	@echo "${GREEN}Services started${NC}"
	@echo "  API:        http://localhost:8000"
	@echo "  Grafana:    http://localhost:3000"
	@echo "  Prometheus: http://localhost:9090"
	@echo "  Neo4j:      http://localhost:7474"

down:
	docker compose down

restart: down up

logs:
	docker compose logs -f

logs-api:
	docker compose logs -f api

logs-db:
	docker compose logs -f postgres

logs-pgbouncer:
	docker compose logs -f pgbouncer

# ============================================
# SHELL ACCESS
# ============================================

shell:
	docker compose exec api /bin/bash

psql:
	docker compose exec postgres psql -U ${POSTGRES_USER:-scalecart} -d ${POSTGRES_DB:-scalecart}

mongo:
	docker compose exec mongodb mongosh -u ${MONGO_USER:-scalecart} -p ${MONGO_PASSWORD:-scalecart_password} --authenticationDatabase admin ${MONGO_DB:-scalecart}

redis:
	docker compose exec redis redis-cli -a ${REDIS_PASSWORD:-scalecart_password}

neo4j:
	docker compose exec neo4j cypher-shell -u ${NEO4J_USER:-neo4j} -p ${NEO4J_PASSWORD:-scalecart_neo4j_password}

# ============================================
# DATABASE
# ============================================

db-init:
	docker compose exec postgres psql -U ${POSTGRES_USER:-scalecart} -d ${POSTGRES_DB:-scalecart} -f /docker-entrypoint-initdb.d/01-schema.sql
	docker compose exec postgres psql -U ${POSTGRES_USER:-scalecart} -d ${POSTGRES_DB:-scalecart} -f /docker-entrypoint-initdb.d/02-indexes.sql
	docker compose exec postgres psql -U ${POSTGRES_USER:-scalecart} -d ${POSTGRES_DB:-scalecart} -f /docker-entrypoint-initdb.d/03-triggers.sql
	@echo "${GREEN}Database schema initialized${NC}"

db-seed:
	docker compose exec postgres psql -U ${POSTGRES_USER:-scalecart} -d ${POSTGRES_DB:-scalecart} -f /docker-entrypoint-initdb.d/04-seed-data.sql
	@echo "${GREEN}Test data seeded${NC}"

db-migrate:
	docker compose exec api alembic upgrade head
	@echo "${GREEN}Migrations applied${NC}"

db-rollback:
	docker compose exec api alembic downgrade -1
	@echo "${YELLOW}Rolled back last migration${NC}"

db-backup:
	./scripts/backup.sh
	@echo "${GREEN}Backup created${NC}"

db-reset:
	@echo "${YELLOW}WARNING: This will delete all data!${NC}"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
		docker compose up -d; \
		sleep 5; \
		make db-init; \
		make db-seed; \
		echo "${GREEN}Database reset${NC}"; \
	else \
		echo "Cancelled"; \
	fi

# ============================================
# TESTING
# ============================================

test:
	docker compose exec api pytest -v

test-unit:
	docker compose exec api pytest -v -m "not integration"

test-integration:
	docker compose exec api pytest -v -m integration

test-coverage:
	docker compose exec api pytest --cov=src --cov-report=html --cov-report=term

# ============================================
# CODE QUALITY
# ============================================

lint:
	docker compose exec api flake8 src/
	docker compose exec api black --check src/
	docker compose exec api isort --check-only src/

format:
	docker compose exec api black src/
	docker compose exec api isort src/

type-check:
	docker compose exec api mypy src/

# ============================================
# CLEANUP
# ============================================

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type f -name ".coverage" -delete
	rm -rf .pytest_cache/ 2>/dev/null || true
	rm -rf htmlcov/ 2>/dev/null || true
	rm -rf dist/ 2>/dev/null || true
	rm -rf build/ 2>/dev/null || true
	rm -rf *.egg-info/ 2>/dev/null || true
	@echo "${GREEN}Cleanup complete${NC}"

clean-data:
	@echo "${YELLOW}WARNING: This will delete ALL data volumes!${NC}"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo ""; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
		echo "${GREEN}Data volumes removed${NC}"; \
	else \
		echo "Cancelled"; \
	fi

# ============================================
# DATA GENERATION
# ============================================

generate-test-data:
	docker compose exec api python src/scripts/generate_test_data.py
	@echo "${GREEN}Test data generated${NC}"

generate-graph-data:
	docker compose exec api python src/scripts/populate_graph.py
	@echo "${GREEN}Graph data populated${NC}"

# ============================================
# MONITORING
# ============================================

metrics:
	@echo "${GREEN}Querying metrics...${NC}"
	@docker compose exec postgres psql -U ${POSTGRES_USER:-scalecart} -d ${POSTGRES_DB:-scalecart} -c "SELECT schemaname, tablename, n_dead_tup, n_live_tup FROM pg_stat_user_tables ORDER BY n_dead_tup DESC LIMIT 10;"

slow-queries:
	@docker compose exec postgres psql -U ${POSTGRES_USER:-scalecart} -d ${POSTGRES_DB:-scalecart} -c "SELECT query, calls, total_time, mean_time FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"

# ============================================
# INSTALLATION
# ============================================

install:
	pip install -r requirements.txt
	pre-commit install
	@echo "${GREEN}Installation complete${NC}"
```

---

## A.8 Quick Start Guide

### A.8.1 One-Command Setup

```bash
# Clone the repository
git clone https://github.com/your-username/scalecart.git
cd scalecart

# Create environment file
make env

# Start all services
make up

# Initialize database
make db-init

# Seed with test data
make db-seed

# Run migrations
make db-migrate

# Generate test data (for performance testing)
make generate-test-data

# View logs
make logs
```

### A.8.2 Accessing Services

After starting everything, you can access:

| Service | URL | Credentials |
|---------|-----|-------------|
| **API** | http://localhost:8000 | N/A |
| **API Docs** | http://localhost:8000/docs | N/A |
| **Grafana** | http://localhost:3000 | admin/admin |
| **Prometheus** | http://localhost:9090 | N/A |
| **Neo4j Browser** | http://localhost:7474 | neo4j/scalecart_neo4j_password |
| **PgBouncer** | localhost:6432 | scalecart/scalecart_password |

### A.8.3 First API Call

```bash
# Get API health
curl http://localhost:8000/health

# Get products
curl http://localhost:8000/api/v1/products?limit=10

# Get product by ID
curl http://localhost:8000/api/v1/products/1

# Create order (requires authentication)
curl -X POST http://localhost:8000/api/v1/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "customer_id": 42,
    "items": [
      {"product_id": 1, "quantity": 2},
      {"product_id": 5, "quantity": 1}
    ]
  }'
```

### A.8.4 Running Tests

```bash
# Run all tests
make test

# Run specific test file
docker compose exec api pytest tests/test_services.py -v

# Run with coverage
make test-coverage
```

---

## A.9 Troubleshooting Common Issues

### A.9.1 Port Conflicts

If you have existing services on standard ports, modify the `.env` file:

```bash
# Change ports in .env
POSTGRES_PORT=5433
MONGO_PORT=27018
REDIS_PORT=6380
NEO4J_HTTP_PORT=7475
NEO4J_BOLT_PORT=7688
TIMESCALE_PORT=5434
```

### A.9.2 Docker Memory Issues

If Docker runs out of memory, adjust limits:

```bash
# In docker-compose.yml, add to services:
deploy:
  resources:
    limits:
      memory: 2G
    reservations:
      memory: 1G
```

### A.9.3 Database Connection Issues

```bash
# Check if PostgreSQL is running
docker compose ps postgres

# Check logs
docker compose logs postgres

# Test connection
docker compose exec postgres pg_isready -U scalecart
```

### A.9.4 Alembic Migration Issues

```bash
# Check current version
docker compose exec api alembic current

# Force reset (danger!)
docker compose exec api alembic stamp base
docker compose exec api alembic upgrade head
```

---

**[END OF APPENDIX A]**

This appendix provides everything you need to set up, run, and maintain the complete ScaleCart platform. Use it as your reference guide for all operational tasks.
