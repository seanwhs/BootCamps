# Part 4 – Multi-Container Systems with Docker Compose

In Parts 1-3, we mastered running individual containers, building custom images, managing persistence, and setting up networks. But if you need to run a complex application with multiple services, typing long `docker run` commands for each container becomes tedious and error-prone.

Enter **Docker Compose** – a tool that lets you define and run multi-container applications with a single, declarative configuration file. Instead of remembering complex commands, you write a clean YAML file that describes your entire stack.

By the end of this part, you'll transform dozens of manual `docker run` commands into a single `docker compose up` that launches a complete application stack with proper dependencies, networking, and volume management.

## 4.1 From Manual Commands to Declarative Configuration

### The Problem: Command Sprawl

Remember our three-tier stack from Part 3? Here's what we had to type:

```bash
# 1. Create network
docker network create three-tier

# 2. Create volume
docker volume create redis-data

# 3. Run Redis
docker run -d --name redis \
  --network three-tier \
  -v redis-data:/data \
  redis:alpine redis-server --appendonly yes

# 4. Build backend
cd backend
docker build -t backend-api:1.0 .

# 5. Run backend
docker run -d --name backend \
  --network three-tier \
  -e REDIS_HOST=redis \
  -p 5000:5000 \
  backend-api:1.0

# 6. Build frontend
cd ../frontend
docker build -t frontend:1.0 .

# 7. Run frontend
docker run -d --name frontend \
  --network three-tier \
  -p 8080:80 \
  frontend:1.0
```

**This is fragile and hard to maintain.** Imagine doing this for 10+ services!

### The Solution: Docker Compose

**`docker-compose.yml` (our target):**
```yaml
version: '3.8'

services:
  redis:
    image: redis:alpine
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data
    networks:
      - three-tier
    restart: unless-stopped

  backend:
    build: ./backend
    environment:
      - REDIS_HOST=redis
    ports:
      - "5000:5000"
    networks:
      - three-tier
    depends_on:
      - redis
    restart: unless-stopped

  frontend:
    build: ./frontend
    ports:
      - "8080:80"
    networks:
      - three-tier
    depends_on:
      - backend

volumes:
  redis-data:

networks:
  three-tier:
```

**One command to rule them all:**
```bash
docker compose up -d
```

## 4.2 Installing Docker Compose

### Docker Desktop (macOS/Windows)

Docker Compose is included with Docker Desktop. Verify:
```bash
docker compose version
```
```
Docker Compose version v2.23.0
```

### Linux

If you installed Docker via the official repository, Compose is included as a plugin:
```bash
docker compose version
```

If not, install it:
```bash
# Install Docker Compose plugin
sudo apt update
sudo apt install docker-compose-plugin
```

## 4.3 Docker Compose File Structure

A Compose file has three main top-level sections:

```yaml
version: '3.8'  # Compose file format version

services:       # Define your containers
  service1:
    # ... configuration ...
  service2:
    # ... configuration ...

volumes:        # Define named volumes
  volume1:

networks:       # Define custom networks
  network1:
```

### Version Matrix

| Version | Features | Docker Engine |
|---------|----------|---------------|
| 3.8 | Current standard | 20.10.0+ |
| 3.7 | Latest 3.x features | 18.06.0+ |
| 3.0 | Basic multi-container | 1.13.0+ |
| 2.x | Legacy (avoid) | 1.10.0+ |

**Best Practice:** Use `version: '3.8'` unless you need specific newer features.

## 4.4 Core Compose Service Configuration

Let's explore each configuration option in detail.

### `image` – Using a Pre-built Image

```yaml
services:
  web:
    image: nginx:alpine
    # Uses official Nginx image from Docker Hub

  app:
    image: myregistry/myapp:1.0
    # Uses private registry image

  db:
    image: postgres:15
    # Specifies version tag
```

### `build` – Building from Dockerfile

```yaml
services:
  backend:
    build: ./backend
    # Builds using Dockerfile in ./backend directory

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
      args:
        - NODE_ENV=production
        - VERSION=1.0
    # Full build configuration with context, Dockerfile, and args
```

### `ports` – Port Mapping

```yaml
services:
  web:
    ports:
      - "8080:80"                # Host:Container
      - "8443:443/tcp"           # Explicit protocol
      - "53:53/udp"              # UDP port

  # Short syntax (same as above)
  web:
    ports:
      - target: 80
        published: 8080
        protocol: tcp
        mode: host               # host or ingress
```

### `environment` and `env_file`

**`environment` – Direct key-value:**
```yaml
services:
  app:
    environment:
      - NODE_ENV=production
      - DB_HOST=postgres
      - DB_PASSWORD=${DB_PASSWORD}  # Uses host environment variable
      - SECRET_KEY=hardcoded        # Not recommended
```

**`env_file` – Load from file:**
```yaml
services:
  app:
    env_file:
      - .env              # Default environment variables
      - .env.production   # Production overrides
```

**`.env` file:**
```
NODE_ENV=production
DB_HOST=postgres
DB_USER=appuser
DB_PASSWORD=supersecret
REDIS_URL=redis://redis:6379
```

### `volumes` – Persistent Storage

```yaml
services:
  db:
    volumes:
      # Named volume (Docker manages)
      - postgres-data:/var/lib/postgresql/data
      
      # Bind mount (host directory)
      - ./data:/app/data
      
      # Read-only bind mount
      - ./config:/app/config:ro
      
      # Relative path
      - ../shared:/shared

  app:
    volumes:
      - ./src:/app/src    # Development hot reload
      - ./logs:/app/logs

volumes:
  postgres-data:          # Declare named volume
    external: false       # Default, creates volume
```

### `networks` – Service Communication

```yaml
services:
  backend:
    networks:
      - app-network       # Single network

  frontend:
    networks:
      - app-network
      - monitoring       # Multiple networks

  db:
    networks:
      - app-network

networks:
  app-network:           # Default bridge network
    driver: bridge
  monitoring:            # External network
    external: true
```

### `depends_on` – Service Dependencies

```yaml
services:
  backend:
    depends_on:
      - redis
      - postgres

  frontend:
    depends_on:
      - backend

  worker:
    depends_on:
      backend:
        condition: service_healthy
      redis:
        condition: service_started
```

**Important:** `depends_on` only waits for containers to start, not for services to be ready. Use health checks for service readiness.

### `restart` – Restart Policies

```yaml
services:
  app:
    restart: "no"              # Never restart (default)
    restart: always            # Always restart
    restart: unless-stopped    # Restart unless manually stopped
    restart: on-failure:3      # Restart on failure, max 3 times
```

### `healthcheck` – Service Health Monitoring

```yaml
services:
  backend:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s    # Give service time to start
```

### `command` and `entrypoint`

```yaml
services:
  redis:
    image: redis:alpine
    command: redis-server --appendonly yes --maxmemory 512mb

  app:
    build: ./app
    entrypoint: ["python", "app.py"]
    command: ["--port", "8000"]      # Appended to entrypoint
```

### `user` – Running as Non-Root

```yaml
services:
  app:
    user: "1001:1001"                # By UID/GID
    # OR
    user: "appuser:appgroup"         # By name
```

### `container_name` – Fixed Container Names

```yaml
services:
  web:
    container_name: my-web-server
```

**Best Practice:** Let Compose generate names (e.g., `project_service_1`) to avoid conflicts.

## 4.5 Building Our Three-Tier Stack with Compose

Now let's create a complete production-ready Compose configuration for our application.

### Step 1: Project Structure

```
three-tier-app/
├── backend/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── index.html
│   └── Dockerfile
├── docker-compose.yml
├── .env
├── .env.example
└── README.md
```

### Step 2: The Production Compose File

**`docker-compose.yml`:**
```yaml
version: '3.8'

# ============================================================
# Services Definition
# ============================================================
services:
  # ------------------------------------------------------------------
  # Redis - In-memory cache and database
  # ------------------------------------------------------------------
  redis:
    image: redis:7.2-alpine
    container_name: three-tier-redis
    command: redis-server --appendonly yes --maxmemory 256mb
    volumes:
      - redis-data:/data
      - ./redis/redis.conf:/usr/local/etc/redis/redis.conf:ro
    networks:
      - three-tier
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
      start_period: 5s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ------------------------------------------------------------------
  # PostgreSQL - Relational database
  # ------------------------------------------------------------------
  postgres:
    image: postgres:15-alpine
    container_name: three-tier-postgres
    environment:
      POSTGRES_USER: ${DB_USER:-appuser}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-secretpassword}
      POSTGRES_DB: ${DB_NAME:-appdb}
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./postgres/init:/docker-entrypoint-initdb.d:ro
    networks:
      - three-tier
    ports:
      - "${DB_PORT:-5432}:5432"    # Optional for external tools
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-appuser} -d ${DB_NAME:-appdb}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ------------------------------------------------------------------
  # Backend API - Python Flask application
  # ------------------------------------------------------------------
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
      args:
        - ENVIRONMENT=${ENVIRONMENT:-production}
    container_name: three-tier-backend
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=${DB_USER:-appuser}
      - DB_PASSWORD=${DB_PASSWORD:-secretpassword}
      - DB_NAME=${DB_NAME:-appdb}
      - SECRET_KEY=${SECRET_KEY:-change_me_in_production}
      - ENVIRONMENT=${ENVIRONMENT:-production}
      - LOG_LEVEL=${LOG_LEVEL:-INFO}
    volumes:
      - ./backend:/app:ro                # Read-only source code
      - ./backend/logs:/app/logs         # Log persistence
      - ./backend/uploads:/app/uploads   # User uploads
    ports:
      - "${BACKEND_PORT:-5000}:5000"
    networks:
      - three-tier
    depends_on:
      redis:
        condition: service_healthy
      postgres:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "python", "-c", 
             "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M

  # ------------------------------------------------------------------
  # Frontend - Static web server
  # ------------------------------------------------------------------
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: three-tier-frontend
    volumes:
      - ./frontend/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    ports:
      - "${FRONTEND_PORT:-8080}:80"
    networks:
      - three-tier
    depends_on:
      backend:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 3s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ------------------------------------------------------------------
  # Nginx Reverse Proxy (Optional - for production)
  # ------------------------------------------------------------------
  nginx-proxy:
    image: nginx:alpine
    container_name: three-tier-nginx
    volumes:
      - ./nginx/proxy.conf:/etc/nginx/conf.d/default.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    ports:
      - "80:80"
      - "443:443"
    networks:
      - three-tier
    depends_on:
      - frontend
      - backend
    restart: unless-stopped
    profiles:
      - production
      - full-stack

# ============================================================
# Volumes Definition
# ============================================================
volumes:
  redis-data:
    driver: local
    driver_opts:
      type: none
      device: ${PWD}/data/redis
      o: bind
    # In production, use a dedicated volume driver

  postgres-data:
    driver: local
    driver_opts:
      type: none
      device: ${PWD}/data/postgres
      o: bind

# ============================================================
# Networks Definition
# ============================================================
networks:
  three-tier:
    name: three-tier-network
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
          gateway: 172.20.0.1
```

### Step 3: Environment Configuration

**`.env` (Production):**
```env
# Application Configuration
ENVIRONMENT=production
LOG_LEVEL=INFO

# Database Configuration
DB_USER=appuser
DB_PASSWORD=change_me_in_production
DB_NAME=appdb
DB_PORT=5432

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379

# Service Ports
BACKEND_PORT=5000
FRONTEND_PORT=8080

# Security
SECRET_KEY=your-secret-key-change-this-in-production

# Volume Paths (Linux/Mac)
# On Windows, use Windows paths like: C:/docker-data
DATA_PATH=/var/lib/docker-data
```

**`.env.example` (Template):**
```env
# Copy this file to .env and modify for your environment
ENVIRONMENT=development
LOG_LEVEL=DEBUG

DB_USER=appuser
DB_PASSWORD=secretpassword
DB_NAME=appdb
DB_PORT=5432

BACKEND_PORT=5000
FRONTEND_PORT=8080

SECRET_KEY=development-secret-key
DATA_PATH=./data
```

### Step 4: Enhanced Backend for PostgreSQL

Let's update the backend to use PostgreSQL:

**`backend/app.py`:**
```python
#!/usr/bin/env python3
"""
Enhanced backend with PostgreSQL and Redis support
"""
from flask import Flask, jsonify, request
import redis
import psycopg2
import psycopg2.extras
import os
import logging
from datetime import datetime

logging.basicConfig(
    level=logging.getLevelName(os.getenv('LOG_LEVEL', 'INFO')),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# ============================================================
# Redis Connection
# ============================================================
try:
    redis_client = redis.Redis(
        host=os.getenv('REDIS_HOST', 'localhost'),
        port=int(os.getenv('REDIS_PORT', 6379)),
        decode_responses=True,
        socket_connect_timeout=5,
        socket_timeout=5
    )
    redis_client.ping()
    logger.info("Redis connection successful")
except Exception as e:
    logger.error(f"Redis connection failed: {e}")
    redis_client = None

# ============================================================
# PostgreSQL Connection
# ============================================================
def get_db_connection():
    """Create a PostgreSQL database connection"""
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            port=int(os.getenv('DB_PORT', 5432)),
            database=os.getenv('DB_NAME', 'appdb'),
            user=os.getenv('DB_USER', 'appuser'),
            password=os.getenv('DB_PASSWORD', 'secretpassword'),
            connect_timeout=5
        )
        return conn
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        return None

# ============================================================
# Initialize Database
# ============================================================
def init_database():
    """Create tables if they don't exist"""
    conn = get_db_connection()
    if not conn:
        logger.error("Cannot initialize database - no connection")
        return False
    
    try:
        cur = conn.cursor()
        cur.execute("""
            CREATE TABLE IF NOT EXISTS visits (
                id SERIAL PRIMARY KEY,
                visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                user_agent TEXT,
                ip_address VARCHAR(45)
            )
        """)
        
        # Create index for performance
        cur.execute("""
            CREATE INDEX IF NOT EXISTS idx_visits_time 
            ON visits (visit_time DESC)
        """)
        
        conn.commit()
        cur.close()
        conn.close()
        logger.info("Database initialized successfully")
        return True
    except Exception as e:
        logger.error(f"Database initialization failed: {e}")
        return False

# Initialize on startup
init_database()

# ============================================================
# API Endpoints
# ============================================================
@app.route('/')
def index():
    """Welcome endpoint"""
    return jsonify({
        'service': 'backend-api',
        'version': '2.0.0',
        'environment': os.getenv('ENVIRONMENT', 'development'),
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/visit')
def visit():
    """Record a visit with Redis counter and PostgreSQL logging"""
    try:
        # Increment Redis counter
        visits = 0
        if redis_client:
            visits = int(redis_client.incr('visits'))
        else:
            # Fallback to database if Redis is unavailable
            conn = get_db_connection()
            if conn:
                cur = conn.cursor()
                cur.execute("SELECT COUNT(*) FROM visits")
                visits = cur.fetchone()[0]
                conn.close()
        
        # Log visit to PostgreSQL
        conn = get_db_connection()
        if conn:
            cur = conn.cursor()
            cur.execute("""
                INSERT INTO visits (user_agent, ip_address)
                VALUES (%s, %s)
            """, (
                request.headers.get('User-Agent', 'unknown'),
                request.remote_addr
            ))
            conn.commit()
            cur.close()
            conn.close()
            logger.info(f"Visit logged: {visits}")
        
        return jsonify({
            'visits': visits,
            'message': 'Hello from the API!',
            'timestamp': datetime.utcnow().isoformat()
        })
    except Exception as e:
        logger.error(f"Visit endpoint error: {e}")
        return jsonify({
            'error': 'Internal server error',
            'details': str(e) if os.getenv('ENVIRONMENT') == 'development' else None
        }), 500

@app.route('/health')
def health():
    """Health check endpoint"""
    status = {
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'services': {}
    }
    
    # Check Redis
    if redis_client:
        try:
            redis_client.ping()
            status['services']['redis'] = 'connected'
        except:
            status['services']['redis'] = 'disconnected'
            status['status'] = 'degraded'
    else:
        status['services']['redis'] = 'unavailable'
        status['status'] = 'degraded'
    
    # Check PostgreSQL
    conn = get_db_connection()
    if conn:
        try:
            cur = conn.cursor()
            cur.execute('SELECT 1')
            cur.close()
            conn.close()
            status['services']['postgres'] = 'connected'
        except:
            status['services']['postgres'] = 'disconnected'
            status['status'] = 'degraded'
    else:
        status['services']['postgres'] = 'unavailable'
        status['status'] = 'degraded'
    
    return jsonify(status)

@app.route('/stats')
def stats():
    """Get visit statistics"""
    try:
        # Get Redis counter
        total_visits = 0
        if redis_client:
            total_visits = int(redis_client.get('visits') or 0)
        
        # Get database stats
        conn = get_db_connection()
        recent_visits = []
        if conn:
            cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
            cur.execute("""
                SELECT visit_time, ip_address, user_agent 
                FROM visits 
                ORDER BY visit_time DESC 
                LIMIT 10
            """)
            recent_visits = cur.fetchall()
            cur.close()
            conn.close()
        
        return jsonify({
            'total_visits': total_visits,
            'recent_visits': recent_visits,
            'cached': bool(redis_client)
        })
    except Exception as e:
        logger.error(f"Stats error: {e}")
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('ENVIRONMENT') == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug)
```

**`backend/requirements.txt`:**
```
Flask==2.3.3
redis==5.0.1
psycopg2-binary==2.9.9
```

**`backend/Dockerfile`:**
```dockerfile
# Stage 1: Builder
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create directories that will be mounted
RUN mkdir -p logs uploads && \
    chmod 755 logs uploads

# Copy dependencies from builder
COPY --from=builder /root/.local /root/.local

# Copy application code
COPY app.py .

# Set PATH for user-installed packages
ENV PATH=/root/.local/bin:$PATH

# Python settings
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Create non-root user
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

# Fix permissions for mounted volumes
RUN chown -R appuser:appgroup /app

USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

EXPOSE 5000

CMD ["python", "app.py"]
```

### Step 5: Run the Stack

**Start all services:**
```bash
# From the project root
docker compose up -d
```
```
[+] Running 4/4
 ✔ Container three-tier-redis      Started
 ✔ Container three-tier-postgres   Started
 ✔ Container three-tier-backend    Started
 ✔ Container three-tier-frontend   Started
```

**View logs:**
```bash
# All services
docker compose logs

# Specific service
docker compose logs backend

# Follow logs
docker compose logs -f backend
```

**Check service status:**
```bash
docker compose ps
```
```
NAME                   IMAGE                   COMMAND                  SERVICE             CREATED             STATUS                    PORTS
three-tier-backend     three-tier-backend      "python app.py"          backend             2 minutes ago       Up 2 minutes (healthy)    0.0.0.0:5000->5000/tcp
three-tier-frontend    three-tier-frontend     "/docker-entrypoint.…"   frontend            2 minutes ago       Up 2 minutes (healthy)    0.0.0.0:8080->80/tcp
three-tier-postgres    postgres:15-alpine      "docker-entrypoint.s…"   postgres            2 minutes ago       Up 2 minutes (healthy)    0.0.0.0:5432->5432/tcp
three-tier-redis       redis:7.2-alpine        "docker-entrypoint.s…"   redis               2 minutes ago       Up 2 minutes (healthy)    6379/tcp
```

**Test the application:**
```bash
# Health check
curl http://localhost:5000/health

# Visit endpoint (should return JSON)
curl http://localhost:5000/visit

# Stats endpoint
curl http://localhost:5000/stats

# Frontend
open http://localhost:8080
```

## 4.6 Development vs Production Profiles

Docker Compose supports **profiles** for different environments:

**`docker-compose.override.yml` (Development overrides):**
```yaml
version: '3.8'

services:
  backend:
    environment:
      - ENVIRONMENT=development
      - LOG_LEVEL=DEBUG
    volumes:
      - ./backend:/app        # Write access for hot reload
    command: python app.py --debug

  frontend:
    volumes:
      - ./frontend:/usr/share/nginx/html:ro

  # Development-only services
  adminer:
    image: adminer:latest
    ports:
      - "8081:8080"
    networks:
      - three-tier
    profiles:
      - dev-tools
      - development

  mailhog:
    image: mailhog/mailhog:latest
    ports:
      - "8025:8025"
    networks:
      - three-tier
    profiles:
      - dev-tools
      - development
```

**Run with profiles:**
```bash
# Development stack (with tools)
docker compose --profile dev-tools up -d

# Production stack (without tools)
docker compose up -d
```

## 4.7 Advanced Compose Features

### Environment Variable Substitution

Compose supports variable substitution from `.env`:

**`docker-compose.yml`:**
```yaml
services:
  app:
    environment:
      - DB_URL=postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME}
      - MEMORY_LIMIT=${APP_MEMORY:-512m}
```

### `depends_on` with Health Checks

```yaml
services:
  app:
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
```

### Service Scale

```bash
# Scale a service
docker compose up -d --scale backend=3
```

### External Configuration

```yaml
services:
  app:
    configs:
      - source: app_config
        target: /app/config.json

configs:
  app_config:
    file: ./config/app.json
```

### Secrets Management

```yaml
services:
  app:
    secrets:
      - db_password
      - api_key

secrets:
  db_password:
    file: ./secrets/db_password.txt
  api_key:
    external: true
```

## 4.8 Common Compose Commands

```bash
# Build and start services
docker compose up -d

# Build without cache
docker compose build --no-cache

# View logs
docker compose logs -f [service]

# Execute command in service
docker compose exec backend bash

# Run one-off command
docker compose run --rm backend python manage.py migrate

# Stop services
docker compose stop

# Stop and remove containers, networks
docker compose down

# Remove volumes too
docker compose down -v

# View resource usage
docker compose top
```

## 4.9 Lab: Three-Tier Application with Hot Reload

Let's set up a development environment with hot reloading.

### Step 1: Development Dockerfile

**`backend/Dockerfile.dev`:**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Don't copy source code - we'll mount it

# Install development tools
RUN pip install watchdog

# Run with hot reload
CMD ["python", "-m", "watchdog.tricks.auto_restart", "--", "python", "app.py"]
```

### Step 2: Development Compose Override

**`docker-compose.override.yml`:**
```yaml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    environment:
      - ENVIRONMENT=development
      - LOG_LEVEL=DEBUG
      - FLASK_DEBUG=1
    volumes:
      - ./backend:/app
      - /app/__pycache__  # Ignore cache
    command: python app.py

  frontend:
    volumes:
      - ./frontend:/usr/share/nginx/html:ro

  # Development-only debugging tools
  debug:
    image: alpine:latest
    command: sleep infinity
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    profiles:
      - debug
```

### Step 3: Development Workflow

```bash
# Start development stack
docker compose up -d

# Edit backend/app.py
# Changes are reflected immediately (with hot reload)

# Run debugging tools
docker compose --profile debug up -d debug
docker compose exec debug sh
```

## 4.10 Backup and Migration with Compose

### Automated Backups

**`docker-compose.backup.yml`:**
```yaml
version: '3.8'

services:
  backup:
    image: alpine:latest
    volumes:
      - postgres-data:/data/postgres:ro
      - redis-data:/data/redis:ro
      - ./backups:/backups
    command: |
      sh -c "
        apk add tar
        tar -czf /backups/backup-$$(date +%Y%m%d-%H%M%S).tar.gz /data
      "
    profiles:
      - backup
```

### Database Migration

```bash
# Run migration
docker compose exec backend python manage.py migrate

# With one-off container
docker compose run --rm backend python manage.py migrate
```

## 4.11 Troubleshooting Compose

### Issue: Port Conflicts

**Error:** `Error response from daemon: port is already allocated`

**Solution:**
```bash
# Change port in .env
FRONTEND_PORT=8081

# Or find and stop conflicting container
docker ps | grep 8080
docker stop [container-id]
```

### Issue: Container Exits Immediately

```bash
# Check logs
docker compose logs [service]

# Check if environment variables are set
docker compose config  # Prints resolved configuration
```

### Issue: Volumes Not Mounting

```bash
# Check volume existence
docker volume ls

# Inspect volume
docker volume inspect three-tier_redis-data
```

## 4.12 Cleanup

```bash
# Stop and remove everything
docker compose down -v

# Remove all volumes, networks, images
docker compose down -v --rmi all

# Prune unused resources
docker system prune -a --volumes
```

## 4.13 Summary

You've now mastered Docker Compose, the essential tool for multi-container applications:

**Key Concepts:**
- ✅ Declarative configuration with YAML
- ✅ Service definitions with images, builds, ports, volumes
- ✅ Environment management with `.env` files
- ✅ Network isolation and service discovery
- ✅ Development vs production profiles
- ✅ Service scaling and dependencies
- ✅ Health checks for service readiness

**Mental Models:**
- **Compose is orchestration**: It defines how services work together
- **Declarative over imperative**: Describe what you want, not how to do it
- **Environment matters**: Separate dev, staging, and production configs
- **Dependencies are explicit**: Define which services need which others

**What You Can Now Build:**
- Complete web application stacks
- Development environments with hot reload
- Production-ready multi-service deployments
- Complex systems with proper logging and monitoring

**Next Up:** Part 5 takes everything we've built and makes it production-ready with security hardening, resource limits, CI/CD pipelines, and performance optimization. Your application will go from "it works" to "it's safe, fast, and reliable."
