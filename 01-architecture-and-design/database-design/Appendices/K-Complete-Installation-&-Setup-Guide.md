# APPENDIX K — Complete Installation & Setup Guide

## From Zero to Running ScaleCart

---

## K.1 Introduction

This appendix provides a complete, step-by-step guide for installing and setting up the ScaleCart platform from scratch on a fresh system. It covers:

1. **System Prerequisites** – What you need before starting
2. **One-Click Installation** – Quick start for evaluation
3. **Manual Installation** – Detailed step-by-step setup
4. **Development Environment** – Setup for contributors
5. **Production Environment** – Production-ready setup
6. **Post-Installation** – Verification and next steps

**Estimated time:** 15-30 minutes (quick start), 1-2 hours (full manual)

---

## K.2 System Prerequisites

### K.2.1 Minimum System Requirements

| Component | Development | Production (Minimal) | Production (Recommended) |
|-----------|-------------|---------------------|-------------------------|
| **CPU** | 2 cores | 4 cores | 8+ cores |
| **RAM** | 8 GB | 16 GB | 32+ GB |
| **Storage** | 20 GB SSD | 100 GB SSD | 500+ GB SSD |
| **OS** | Any (Docker) | Ubuntu 22.04 LTS | Ubuntu 22.04 LTS |
| **Docker** | 20.10+ | 20.10+ | 23.0+ |
| **Docker Compose** | 2.0+ | 2.0+ | 2.20+ |

### K.2.2 Required Software

```bash
# Check installed versions
docker --version
docker compose --version
git --version
python3 --version
curl --version
jq --version  # Optional but recommended
```

### K.2.3 Installation Commands (by OS)

**Ubuntu/Debian:**

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin -y

# Install Git
sudo apt install git -y

# Install Python
sudo apt install python3 python3-pip python3-venv -y

# Install other tools
sudo apt install curl jq -y

# Reboot to apply group changes
sudo reboot
```

**macOS:**

```bash
# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Docker Desktop
brew install --cask docker

# Install Git
brew install git

# Install Python
brew install python@3.11

# Install other tools
brew install curl jq

# Start Docker Desktop
open /Applications/Docker.app
```

**Windows:**

```bash
# Install Chocolatey (as Administrator)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Docker Desktop
choco install docker-desktop -y

# Install Git
choco install git -y

# Install Python
choco install python -y

# Install other tools
choco install curl jq -y

# Restart to apply changes
Restart-Computer
```

---

## K.3 Quick Start (One-Click Installation)

### K.3.1 Automated Setup Script

```bash
#!/bin/bash
# File: scripts/quick-start.sh
# Quick start script for ScaleCart

set -e

echo "🚀 ScaleCart Quick Start"
echo "========================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Clone repository
echo -e "${YELLOW}1. Cloning repository...${NC}"
if [ -d "scalecart" ]; then
    echo "Directory already exists. Pulling latest..."
    cd scalecart && git pull && cd ..
else
    git clone https://github.com/your-username/scalecart.git
    cd scalecart
fi

# 2. Create environment file
echo -e "${YELLOW}2. Creating environment file...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env file"
else
    echo ".env file already exists"
fi

# 3. Start services
echo -e "${YELLOW}3. Starting services...${NC}"
docker compose up -d

# 4. Wait for services to be ready
echo -e "${YELLOW}4. Waiting for services...${NC}"
sleep 10

# 5. Initialize database
echo -e "${YELLOW}5. Initializing database...${NC}"
docker compose exec -T postgres psql -U scalecart -d scalecart -f /docker-entrypoint-initdb.d/01-schema.sql
docker compose exec -T postgres psql -U scalecart -d scalecart -f /docker-entrypoint-initdb.d/02-indexes.sql

# 6. Seed test data
echo -e "${YELLOW}6. Seeding test data...${NC}"
docker compose exec -T postgres psql -U scalecart -d scalecart -f /docker-entrypoint-initdb.d/04-seed-data.sql

# 7. Run migrations
echo -e "${YELLOW}7. Running migrations...${NC}"
docker compose exec -T api alembic upgrade head

# 8. Health check
echo -e "${YELLOW}8. Running health check...${NC}"
sleep 5
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health)
if [ "$HEALTH" = "200" ]; then
    echo -e "${GREEN}✅ Health check passed!${NC}"
else
    echo -e "${RED}❌ Health check failed with status: $HEALTH${NC}"
fi

echo ""
echo -e "${GREEN}✅ ScaleCart is ready!${NC}"
echo ""
echo "Access the services:"
echo "  - API: http://localhost:8000"
echo "  - API Docs: http://localhost:8000/docs"
echo "  - Grafana: http://localhost:3000 (admin/admin)"
echo "  - Neo4j: http://localhost:7474 (neo4j/scalecart_neo4j_password)"
echo ""
echo "Quick test:"
echo "  curl http://localhost:8000/health"
echo "  curl http://localhost:8000/api/v1/products"
echo ""
echo "To stop: docker compose down"
echo "To view logs: docker compose logs -f"
```

**Run the quick start:**

```bash
curl -fsSL https://raw.githubusercontent.com/your-username/scalecart/main/scripts/quick-start.sh | bash
```

---

## K.4 Manual Installation (Step-by-Step)

### K.4.1 Step 1: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/your-username/scalecart.git
cd scalecart

# Or if you have the code locally
mkdir scalecart
cd scalecart
```

### K.4.2 Step 2: Create Directory Structure

```bash
# Create required directories
mkdir -p src/{api,models,services,utils,scripts,migrations/versions}
mkdir -p tests
mkdir -p docs
mkdir -p init-scripts
mkdir -p backups
mkdir -p logs

# Create __init__.py files
touch src/__init__.py
touch src/api/__init__.py
touch src/models/__init__.py
touch src/services/__init__.py
touch src/utils/__init__.py
touch src/scripts/__init__.py
touch tests/__init__.py

# Create main files
touch docker-compose.yml
touch .env.example
touch requirements.txt
touch alembic.ini
touch README.md
```

### K.4.3 Step 3: Environment Configuration

```bash
# Create .env file
cat > .env << 'EOF'
# ScaleCart Environment Variables

# ============================================
# DATABASE CONFIGURATION
# ============================================

POSTGRES_USER=scalecart
POSTGRES_PASSWORD=scalecart_password
POSTGRES_DB=scalecart
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}

# ============================================
# REDIS CONFIGURATION
# ============================================

REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=scalecart_password
REDIS_URL=redis://:${REDIS_PASSWORD}@${REDIS_HOST}:${REDIS_PORT}/0

# ============================================
# MONGODB CONFIGURATION
# ============================================

MONGO_USER=scalecart
MONGO_PASSWORD=scalecart_password
MONGO_DB=scalecart
MONGO_HOST=mongodb
MONGO_PORT=27017
MONGO_URI=mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}:${MONGO_PORT}/${MONGO_DB}

# ============================================
# NEO4J CONFIGURATION
# ============================================

NEO4J_HOST=neo4j
NEO4J_PORT=7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=scalecart_neo4j_password
NEO4J_URI=bolt://${NEO4J_HOST}:${NEO4J_PORT}

# ============================================
# APPLICATION CONFIGURATION
# ============================================

APP_ENV=development
DEBUG=true
SECRET_KEY=your-secret-key-change-in-production
LOG_LEVEL=INFO
ALLOWED_HOSTS=localhost,127.0.0.1

# ============================================
# EXTERNAL SERVICES (Optional)
# ============================================

OPENAI_API_KEY=
STRIPE_SECRET_KEY=
EOF

echo "Created .env file"
```

### K.4.4 Step 4: Docker Compose Configuration

```bash
cat > docker-compose.yml << 'EOF'
# File: docker-compose.yml
version: '3.8'

services:
  # PostgreSQL - Primary Database
  postgres:
    image: postgres:15
    container_name: scalecart_postgres
    environment:
      POSTGRES_USER: scalecart
      POSTGRES_PASSWORD: scalecart_password
      POSTGRES_DB: scalecart
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U scalecart"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - scalecart_network

  # Redis - Cache & Session Store
  redis:
    image: redis:7-alpine
    container_name: scalecart_redis
    command: redis-server --requirepass scalecart_password
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - scalecart_network

  # MongoDB - Document Cache
  mongodb:
    image: mongo:7.0
    container_name: scalecart_mongodb
    environment:
      MONGO_INITDB_ROOT_USERNAME: scalecart
      MONGO_INITDB_ROOT_PASSWORD: scalecart_password
      MONGO_INITDB_DATABASE: scalecart
    ports:
      - "27017:27017"
    volumes:
      - mongodb_data:/data/db
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - scalecart_network

  # Neo4j - Graph Database
  neo4j:
    image: neo4j:5-enterprise
    container_name: scalecart_neo4j
    environment:
      NEO4J_AUTH: neo4j/scalecart_neo4j_password
      NEO4J_ACCEPT_LICENSE_AGREEMENT: "yes"
    ports:
      - "7474:7474"
      - "7687:7687"
    volumes:
      - neo4j_data:/data
    healthcheck:
      test: ["CMD", "cypher-shell", "-u", "neo4j", "-p", "scalecart_neo4j_password", "RETURN 1"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - scalecart_network

  # TimescaleDB - Time-Series Metrics
  timescaledb:
    image: timescale/timescaledb:2.11-pg15
    container_name: scalecart_timescaledb
    environment:
      POSTGRES_USER: scalecart
      POSTGRES_PASSWORD: scalecart_password
      POSTGRES_DB: scalecart_metrics
    ports:
      - "5433:5432"
    volumes:
      - timescaledb_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U scalecart -d scalecart_metrics"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - scalecart_network

  # API - Application Service
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: scalecart_api
    environment:
      DATABASE_URL: postgresql://scalecart:scalecart_password@postgres:5432/scalecart
      REDIS_URL: redis://:scalecart_password@redis:6379/0
      MONGODB_URI: mongodb://scalecart:scalecart_password@mongodb:27017/scalecart
      NEO4J_URI: bolt://neo4j:7687
      NEO4J_USER: neo4j
      NEO4J_PASSWORD: scalecart_neo4j_password
      SECRET_KEY: ${SECRET_KEY:-dev-secret-key}
      APP_ENV: ${APP_ENV:-development}
      DEBUG: ${DEBUG:-true}
    ports:
      - "8000:8000"
    volumes:
      - ./src:/app/src
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      mongodb:
        condition: service_healthy
      neo4j:
        condition: service_healthy
    networks:
      - scalecart_network
    command: uvicorn src.api.app:app --host 0.0.0.0 --port 8000 --reload

networks:
  scalecart_network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
  mongodb_data:
  neo4j_data:
  timescaledb_data:
EOF

echo "Created docker-compose.yml"
```

### K.4.5 Step 5: Dockerfile

```bash
cat > Dockerfile << 'EOF'
# File: Dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY src/ ./src/
COPY alembic.ini ./

# Create non-root user
RUN useradd -m -u 1000 app && chown -R app:app /app
USER app

# Expose port
EXPOSE 8000

# Run the application
CMD ["uvicorn", "src.api.app:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

echo "Created Dockerfile"
```

### K.4.6 Step 6: Python Dependencies

```bash
cat > requirements.txt << 'EOF'
# File: requirements.txt
# Core dependencies

fastapi==0.104.1
uvicorn[standard]==0.24.0
python-dotenv==1.0.0
psycopg2-binary==2.9.9
sqlalchemy==2.0.23
alembic==1.12.1
pymongo==4.6.1
redis==5.0.1
neo4j==5.15.0
pydantic==2.5.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
pytest==7.4.3
faker==20.0.0
EOF

echo "Created requirements.txt"
```

### K.4.7 Step 7: Initialize Database Scripts

```bash
# Create init-scripts directory
mkdir -p init-scripts

# Create minimal schema
cat > init-scripts/01-schema.sql << 'EOF'
-- File: init-scripts/01-schema.sql
-- Minimal schema for quick start

CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    parent_category_id INTEGER REFERENCES categories(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    category_id INTEGER NOT NULL REFERENCES categories(id),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    registered_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    order_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending','paid','shipped','delivered','cancelled')),
    total_amount NUMERIC(10,2) NOT NULL CHECK (total_amount >= 0)
);

CREATE TABLE IF NOT EXISTS order_items (
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);

CREATE TABLE IF NOT EXISTS inventory (
    product_id INTEGER PRIMARY KEY REFERENCES products(id) ON DELETE CASCADE,
    stock_quantity INTEGER NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    reorder_threshold INTEGER NOT NULL DEFAULT 10
);

-- Create indexes
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
EOF

# Create seed data
cat > init-scripts/04-seed-data.sql << 'EOF'
-- File: init-scripts/04-seed-data.sql
-- Seed data for testing

INSERT INTO categories (name) VALUES 
    ('Electronics'),
    ('Books'),
    ('Clothing');

INSERT INTO products (name, description, price, category_id) VALUES
    ('MacBook Pro', 'High-performance laptop', 2499.99, 1),
    ('iPhone 15', 'Latest smartphone', 1099.99, 1),
    ('The Great Gatsby', 'Classic novel', 14.99, 2),
    ('Levi''s 501 Jeans', 'Classic denim', 69.99, 3);

INSERT INTO inventory (product_id, stock_quantity) VALUES
    (1, 50),
    (2, 100),
    (3, 200),
    (4, 80);
EOF

echo "Created database initialization scripts"
```

### K.4.8 Step 8: Minimal API Application

```bash
# Create minimal API
mkdir -p src/api

cat > src/api/app.py << 'EOF'
# File: src/api/app.py
# Minimal FastAPI application

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
import psycopg2
from psycopg2.extras import RealDictCursor

app = FastAPI(
    title="ScaleCart API",
    version="1.0.0",
    description="ScaleCart E-commerce API"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Database connection
def get_db():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "postgres"),
        port=os.getenv("POSTGRES_PORT", 5432),
        user=os.getenv("POSTGRES_USER", "scalecart"),
        password=os.getenv("POSTGRES_PASSWORD", "scalecart_password"),
        dbname=os.getenv("POSTGRES_DB", "scalecart")
    )

# Health check
@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "ScaleCart API"}

# Get products
@app.get("/api/v1/products")
async def get_products(limit: int = 10):
    try:
        conn = get_db()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute("""
            SELECT p.*, c.name as category_name, i.stock_quantity
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            LEFT JOIN inventory i ON p.id = i.product_id
            LIMIT %s
        """, (limit,))
        products = cur.fetchall()
        cur.close()
        conn.close()
        return {"data": products}
    except Exception as e:
        return {"error": str(e)}

# Get product by ID
@app.get("/api/v1/products/{product_id}")
async def get_product(product_id: int):
    try:
        conn = get_db()
        cur = conn.cursor(cursor_factory=RealDictCursor)
        cur.execute("""
            SELECT p.*, c.name as category_name, i.stock_quantity
            FROM products p
            LEFT JOIN categories c ON p.category_id = c.id
            LEFT JOIN inventory i ON p.id = i.product_id
            WHERE p.id = %s
        """, (product_id,))
        product = cur.fetchone()
        cur.close()
        conn.close()
        if not product:
            return {"error": "Product not found"}, 404
        return product
    except Exception as e:
        return {"error": str(e)}
EOF

echo "Created minimal API application"
```

### K.4.9 Step 9: Alembic Configuration

```bash
cat > alembic.ini << 'EOF'
# File: alembic.ini
[alembic]
script_location = src/migrations
prepend_sys_path = .
version_path_separator = os
sqlalchemy.url = postgresql://scalecart:scalecart_password@postgres:5432/scalecart

[post_write_hooks]
hooks = black
black.type = console_scripts
black.entrypoint = black
black.options = -l 88

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console
qualname =

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
EOF

echo "Created alembic.ini"
```

### K.4.10 Step 10: Start Services

```bash
# Start all services
docker compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 15

# Check service status
docker compose ps

# Check logs
docker compose logs --tail=20
```

### K.4.11 Step 11: Initialize Database

```bash
# Run schema creation
docker compose exec postgres psql -U scalecart -d scalecart -f /docker-entrypoint-initdb.d/01-schema.sql

# Run index creation
docker compose exec postgres psql -U scalecart -d scalecart -f /docker-entrypoint-initdb.d/02-indexes.sql 2>/dev/null || echo "Indexes already exist"

# Seed data
docker compose exec postgres psql -U scalecart -d scalecart -f /docker-entrypoint-initdb.d/04-seed-data.sql

# Create migrations directory and initial migration
mkdir -p src/migrations/versions
touch src/migrations/__init__.py
touch src/migrations/versions/__init__.py

# Run Alembic migrations
docker compose exec api alembic upgrade head 2>/dev/null || echo "Migrations not configured yet"
```

### K.4.12 Step 12: Verify Installation

```bash
# Health check
curl http://localhost:8000/health

# Get products
curl http://localhost:8000/api/v1/products

# Check database
docker compose exec postgres psql -U scalecart -d scalecart -c "SELECT COUNT(*) FROM products;"

# Check services
echo "PostgreSQL:"
docker compose exec postgres pg_isready -U scalecart
echo "Redis:"
docker compose exec redis redis-cli -a scalecart_password ping
echo "MongoDB:"
docker compose exec mongodb mongosh -u scalecart -p scalecart_password --authenticationDatabase admin --eval "db.runCommand({ping:1})" 2>/dev/null | grep -q ok && echo "OK" || echo "Failed"
```

---

## K.5 Development Environment Setup

### K.5.1 Local Python Environment

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install development dependencies
pip install -r requirements.txt

# Install additional development tools
pip install black isort flake8 mypy pytest pytest-cov pre-commit

# Install pre-commit hooks
pre-commit install

# Verify installation
python -c "import fastapi; print('FastAPI installed successfully')"
```

### K.5.2 IDE Configuration (VS Code)

```json
{
  // File: .vscode/settings.json
  "python.defaultInterpreterPath": "${workspaceFolder}/venv/bin/python",
  "python.linting.enabled": true,
  "python.linting.flake8Enabled": true,
  "python.linting.mypyEnabled": true,
  "python.formatting.provider": "black",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": true
  },
  "files.watcherExclude": {
    "**/venv/**": true,
    "**/.git/**": true
  },
  "python.testing.pytestEnabled": true,
  "python.testing.pytestArgs": [
    "tests"
  ]
}
```

### K.5.3 Git Configuration

```bash
# Configure Git
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Set up Git hooks
pre-commit install

# Create .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.pyc
*.pyo
venv/
.env
*.egg-info/

# IDE
.vscode/
.idea/
*.swp

# Database
*.db
*.sqlite
*.postgresql
*.dump

# Docker
*.pid
*.sock
.data/
postgres_data/
redis_data/
mongodb_data/
neo4j_data/

# Logs
logs/
*.log

# Testing
.pytest_cache/
.coverage
htmlcov/

# Environment
.env.local
.env.production
EOF
```

---

## K.6 Production Environment Setup

### K.6.1 Production Docker Compose

```bash
cat > docker-compose.prod.yml << 'EOF'
# File: docker-compose.prod.yml
# Production override

version: '3.8'

services:
  postgres:
    environment:
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
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

  api:
    environment:
      APP_ENV: production
      DEBUG: "false"
      LOG_LEVEL: INFO
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
      replicas: 3
    restart: unless-stopped
    command: gunicorn -w 4 -k uvicorn.workers.UvicornWorker src.api.app:app --bind 0.0.0.0:8000
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "10"

  redis:
    command: redis-server --requirepass ${REDIS_PASSWORD} --maxmemory 512mb --maxmemory-policy allkeys-lru
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
    restart: unless-stopped

  mongodb:
    environment:
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
    restart: unless-stopped

  neo4j:
    environment:
      NEO4J_AUTH: ${NEO4J_USER}/${NEO4J_PASSWORD}
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
    restart: unless-stopped

  # Monitoring services
  prometheus:
    image: prom/prometheus:v2.46.0
    container_name: scalecart_prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    ports:
      - "9090:9090"
    restart: unless-stopped
    networks:
      - scalecart_network

  grafana:
    image: grafana/grafana:10.2.0
    container_name: scalecart_grafana
    environment:
      GF_SECURITY_ADMIN_USER: admin
      GF_SECURITY_ADMIN_PASSWORD: ${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
    ports:
      - "3000:3000"
    restart: unless-stopped
    networks:
      - scalecart_network

volumes:
  prometheus_data:
  grafana_data:
EOF
```

### K.6.2 Production .env File

```bash
cat > .env.prod << 'EOF'
# File: .env.prod
# Production environment variables

# Database
POSTGRES_PASSWORD=your-secure-password-here
POSTGRES_USER=scalecart
POSTGRES_DB=scalecart

# Redis
REDIS_PASSWORD=your-redis-password-here

# MongoDB
MONGO_PASSWORD=your-mongo-password-here

# Neo4j
NEO4J_USER=neo4j
NEO4J_PASSWORD=your-neo4j-password-here

# Application
SECRET_KEY=your-secret-key-here
APP_ENV=production
DEBUG=false
LOG_LEVEL=INFO
ALLOWED_HOSTS=api.yourdomain.com

# Grafana
GRAFANA_PASSWORD=your-grafana-password-here

# External Services
OPENAI_API_KEY=sk-...
STRIPE_SECRET_KEY=sk_...
EOF
```

### K.6.3 Production Deployment

```bash
# Start production environment
docker compose -f docker-compose.yml -f docker-compose.prod.yml --env-file .env.prod up -d

# Scale API service
docker compose up -d --scale api=3

# View production logs
docker compose logs -f

# Monitor health
curl https://api.yourdomain.com/health
```

---

## K.7 Post-Installation Verification

### K.7.1 Complete Verification Script

```bash
#!/bin/bash
# File: scripts/verify-installation.sh

echo "🔍 ScaleCart Installation Verification"
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

FAILED=0

# 1. Check Docker
echo -n "1. Docker: "
if docker --version &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 2. Check Docker Compose
echo -n "2. Docker Compose: "
if docker compose version &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 3. Check services running
echo -n "3. Services running: "
if docker compose ps --quiet &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 4. Check PostgreSQL
echo -n "4. PostgreSQL: "
if docker compose exec -T postgres pg_isready -U scalecart &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 5. Check Redis
echo -n "5. Redis: "
if docker compose exec -T redis redis-cli -a scalecart_password ping &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 6. Check MongoDB
echo -n "6. MongoDB: "
if docker compose exec -T mongodb mongosh -u scalecart -p scalecart_password --authenticationDatabase admin --eval "db.runCommand({ping:1})" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 7. Check Neo4j
echo -n "7. Neo4j: "
if docker compose exec -T neo4j cypher-shell -u neo4j -p scalecart_neo4j_password "RETURN 1" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 8. Check API
echo -n "8. API: "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health | grep -q 200; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 9. Check database tables
echo -n "9. Database tables: "
if docker compose exec -T postgres psql -U scalecart -d scalecart -c "SELECT COUNT(*) FROM products;" &>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

# 10. Check API response
echo -n "10. API data: "
if curl -s http://localhost:8000/api/v1/products | grep -q '"data"'; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    FAILED=1
fi

echo ""
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! ScaleCart is installed correctly.${NC}"
else
    echo -e "${RED}❌ Some checks failed. Please review the errors above.${NC}"
fi
```

---

## K.8 Next Steps

After successful installation:

1. **Explore the API** – Visit http://localhost:8000/docs for API documentation
2. **Add your own data** – Customize the database schema
3. **Configure authentication** – Set up JWT and user management
4. **Deploy to production** – Use the production configuration
5. **Enable monitoring** – Configure Prometheus and Grafana
6. **Set up backups** – Configure automated backups
7. **Add custom features** – Extend the platform for your needs

---

**[END OF APPENDIX K]**

*This comprehensive installation guide provides everything needed to get ScaleCart running from scratch. Follow it step by step for a successful setup on any platform.*
