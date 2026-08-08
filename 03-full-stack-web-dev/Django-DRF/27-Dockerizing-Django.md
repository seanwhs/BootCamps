# Part 27: Dockerizing Django

## Containerizing Your Backend for Production

Welcome to **Part 27** of the Django REST Framework & Next.js 16 masterclass. Now that we have comprehensive testing and documentation, it's time to containerize our application with Docker. We'll create production-ready Docker images for our Django backend, ensuring consistent environments across development, testing, and production.

In this part, we'll:
- Create a production-grade Dockerfile for Django
- Configure Gunicorn as the production server
- Set up environment variables for different environments
- Optimize Docker image size and build time
- Implement health checks
- Configure logging and monitoring

Think of Docker as your application's **shipping container**. Just as shipping containers standardize how goods are transported across the world, Docker standardizes how applications are packaged and deployed across any infrastructure.

---

## The Target

We'll create a complete Docker setup for Django:

```
backend/
├── Dockerfile                    # Production image
├── Dockerfile.dev               # Development image
├── .dockerignore                # Exclude files from Docker build
├── docker-compose.yml           # Local development (updated)
├── docker-compose.prod.yml      # Production compose
├── gunicorn.conf.py             # Gunicorn configuration
├── entrypoint.sh               # Container entrypoint script
└── scripts/
    └── docker-entrypoint.sh    # Pre-startup setup script
```

---

## The Concept

### Docker Image Layering

Docker images are built in layers:

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Image Layers                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Layer 5: Application Code (changes frequently)      │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Layer 4: Python Dependencies (changes occasionally) │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Layer 3: System Packages (rarely changes)           │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Layer 2: Base Python Image                         │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Layer 1: Base OS (Alpine Linux)                    │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Multi-Stage Builds

Multi-stage builds allow you to:
- **Build stage**: Install build dependencies, compile assets
- **Production stage**: Copy only necessary files, reducing image size

### Best Practices

1. **Minimize layers**: Combine RUN commands
2. **Use .dockerignore**: Exclude unnecessary files
3. **Run as non-root**: Create a dedicated user
4. **Use specific tags**: Python 3.12-slim, not latest
5. **Cache dependencies**: Install requirements first (before copying code)
6. **Use health checks**: Monitor container health

---

## The Implementation

### Step 1: Create .dockerignore

**backend/.dockerignore** (create)

```gitignore
# Python
*.pyc
*.pyo
*.pyd
__pycache__
*.so
*.egg
*.egg-info
dist
build
.env
.venv
venv
env/

# Django
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal
/media/
/staticfiles/
/media/

# Testing
.coverage
htmlcov/
.pytest_cache/
.tox/
*.cover
.hypothesis/
**/__pycache__

# Docker
Dockerfile
.dockerignore
docker-compose*.yml

# Git
.git
.gitignore

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Environment
.env
.env.local
.env.*.local

# Documentation
docs/
*.md
README.md

# Other
*.bak
*.tmp
*.pid
*.lock
```

### Step 2: Create Entrypoint Script

**backend/entrypoint.sh** (create)

```bash
#!/bin/sh
set -e

# Create logs directory
mkdir -p /app/logs

# Run database migrations
echo "Running database migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Create superuser if it doesn't exist (for development)
if [ "$DJANGO_ENV" = "development" ]; then
    echo "Creating superuser if it doesn't exist..."
    python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(email='admin@example.com').exists():
    User.objects.create_superuser(
        email='admin@example.com',
        username='admin',
        password='${DJANGO_SUPERUSER_PASSWORD:-admin123}'
    )
    print('Superuser created successfully')
else:
    print('Superuser already exists')
"
fi

# Execute the main command
exec "$@"
```

Make it executable:

```bash
chmod +x backend/entrypoint.sh
```

### Step 3: Create Dockerfile

**backend/Dockerfile** (create)

```dockerfile
# Stage 1: Build stage
FROM python:3.12-slim AS builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies for building
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements/base.txt requirements/base.txt
COPY requirements/production.txt requirements/production.txt

# Install Python dependencies
RUN pip install -r requirements/production.txt

# Stage 2: Production stage
FROM python:3.12-slim

# Create non-root user
RUN addgroup --system --gid 1000 appuser && \
    adduser --system --uid 1000 --gid 1000 appuser

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    libpq-dev \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_ENV=production \
    PYTHONPATH=/app \
    PORT=8000

# Create necessary directories
RUN mkdir -p /app/staticfiles /app/media /app/logs

# Set work directory
WORKDIR /app

# Copy installed packages from builder stage
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy project files
COPY . .

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Change ownership to non-root user
RUN chown -R appuser:appuser /app
RUN chown -R appuser:appuser /entrypoint.sh

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health/')" || exit 1

# Expose port
EXPOSE 8000

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["gunicorn", "--config", "gunicorn.conf.py", "config.wsgi:application"]
```

### Step 4: Create Development Dockerfile

**backend/Dockerfile.dev** (create)

```dockerfile
# Development Dockerfile
FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_ENV=development \
    PIP_NO_CACHE_DIR=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    netcat-openbsd \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Copy requirements first
COPY requirements/base.txt requirements/base.txt
COPY requirements/development.txt requirements/development.txt

# Install dependencies
RUN pip install -r requirements/development.txt

# Copy project files
COPY . .

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port
EXPOSE 8000

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
```

### Step 5: Create Gunicorn Configuration

**backend/gunicorn.conf.py** (create)

```python
"""
Gunicorn configuration for production.
"""

import os
import multiprocessing

# Server socket
bind = f"0.0.0.0:{os.getenv('PORT', '8000')}"
backlog = 2048

# Worker processes
workers = int(os.getenv('GUNICORN_WORKERS', multiprocessing.cpu_count() * 2 + 1))
worker_class = 'sync'
worker_connections = 1000
timeout = 30
graceful_timeout = 30
max_requests = 1000
max_requests_jitter = 100

# Logging
accesslog = '/app/logs/gunicorn-access.log'
errorlog = '/app/logs/gunicorn-error.log'
loglevel = os.getenv('GUNICORN_LOG_LEVEL', 'info')
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'

# Process naming
proc_name = 'taskflow-backend'

# Server mechanics
daemon = False
pidfile = None
umask = 0
user = None
group = None
tmp_upload_dir = None

# Security
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190

# Reloading
reload = False  # Set to True for development

# Statistics
statsd_host = None
statsd_prefix = None

# Health check endpoint
def when_ready(server):
    """
    Called when Gunicorn is ready.
    """
    server.log.info("Gunicorn ready - TaskFlow API is running")

def post_fork(server, worker):
    """
    Called after a worker is forked.
    """
    server.log.info(f"Worker spawned: {worker.pid}")
```

### Step 6: Update Docker Compose for Development

**docker-compose.yml** (update for backend)

```yaml
version: '3.8'

services:
  # Database
  db:
    image: postgres:15-alpine
    container_name: taskflow-db
    environment:
      POSTGRES_DB: taskflow_db
      POSTGRES_USER: taskflow_user
      POSTGRES_PASSWORD: taskflow_pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./postgres-init:/docker-entrypoint-initdb.d
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U taskflow_user"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - taskflow-network

  # Redis
  redis:
    image: redis:7-alpine
    container_name: taskflow-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - taskflow-network

  # Django Backend - Development
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    container_name: taskflow-backend
    env_file:
      - ./backend/.env
    environment:
      - DATABASE_URL=postgresql://taskflow_user:taskflow_pass@db:5432/taskflow_db
      - REDIS_URL=redis://redis:6379/1
      - DJANGO_ENV=development
      - DEBUG=True
    volumes:
      - ./backend:/app
      - /app/staticfiles
      - /app/media
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - taskflow-network

volumes:
  postgres_data:
  redis_data:

networks:
  taskflow-network:
    driver: bridge
```

### Step 7: Create Production Docker Compose

**docker-compose.prod.yml** (create)

```yaml
version: '3.8'

services:
  # Database
  db:
    image: postgres:15-alpine
    container_name: taskflow-db
    environment:
      POSTGRES_DB: ${DB_NAME:-taskflow_db}
      POSTGRES_USER: ${DB_USER:-taskflow_user}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-taskflow_pass}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-taskflow_user}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - taskflow-network

  # Redis
  redis:
    image: redis:7-alpine
    container_name: taskflow-redis
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD:-}
    volumes:
      - redis_data:/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - taskflow-network

  # Django Backend - Production
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
      args:
        - ENVIRONMENT=production
    image: taskflow-backend:latest
    container_name: taskflow-backend
    env_file:
      - ./backend/.env.production
    environment:
      - DATABASE_URL=postgresql://${DB_USER:-taskflow_user}:${DB_PASSWORD:-taskflow_pass}@db:5432/${DB_NAME:-taskflow_db}
      - REDIS_URL=redis://:${REDIS_PASSWORD:-}@redis:6379/1
      - DJANGO_ENV=production
      - DEBUG=False
      - GUNICORN_WORKERS=${GUNICORN_WORKERS:-4}
    volumes:
      - static_volume:/app/staticfiles
      - media_volume:/app/media
      - logs_volume:/app/logs
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - taskflow-network

  # Nginx (reverse proxy)
  nginx:
    image: nginx:alpine
    container_name: taskflow-nginx
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - static_volume:/static:ro
      - media_volume:/media:ro
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend
    restart: unless-stopped
    networks:
      - taskflow-network

volumes:
  postgres_data:
  redis_data:
  static_volume:
  media_volume:
  logs_volume:

networks:
  taskflow-network:
    driver: bridge
```

### Step 8: Create Health Check Endpoint

**backend/apps/api/views.py** (add health check)

```python
from django.http import JsonResponse
from django.db import connections
from django.db.utils import OperationalError
from django.core.cache import cache
import redis
import os


@api_view(['GET'])
def health_check(request):
    """
    Health check endpoint for container orchestration.
    """
    status = {
        'status': 'healthy',
        'timestamp': time.time(),
        'version': '1.0.0',
        'services': {}
    }
    
    # Check database
    try:
        db_conn = connections['default']
        db_conn.cursor()
        status['services']['database'] = 'healthy'
    except OperationalError:
        status['services']['database'] = 'unhealthy'
        status['status'] = 'unhealthy'
    
    # Check Redis
    try:
        cache.get('health_check')
        status['services']['redis'] = 'healthy'
    except redis.RedisError:
        status['services']['redis'] = 'unhealthy'
        status['status'] = 'unhealthy'
    
    # Check environment
    status['environment'] = os.getenv('DJANGO_ENV', 'production')
    
    # If any service is unhealthy, return 503
    if status['status'] == 'unhealthy':
        return JsonResponse(status, status=503)
    
    return JsonResponse(status)
```

**backend/config/urls.py** (add health check URL)

```python
from apps.api.views import health_check

urlpatterns = [
    # ... other URLs ...
    path('health/', health_check, name='health-check'),
]
```

### Step 9: Create Build Script

**backend/scripts/build.sh** (create)

```bash
#!/bin/bash

# Build script for Docker images

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Building TaskFlow Backend Docker images...${NC}"

# Build development image
echo -e "${YELLOW}Building development image...${NC}"
docker build -f backend/Dockerfile.dev -t taskflow-backend:dev .

# Build production image
echo -e "${YELLOW}Building production image...${NC}"
docker build -f backend/Dockerfile -t taskflow-backend:latest .

# Tag for registry (optional)
if [ -n "$DOCKER_REGISTRY" ]; then
    echo -e "${YELLOW}Tagging image for registry...${NC}"
    docker tag taskflow-backend:latest $DOCKER_REGISTRY/taskflow-backend:latest
fi

echo -e "${GREEN}✓ Build complete!${NC}"
echo ""
echo -e "Development:  taskflow-backend:dev"
echo -e "Production:   taskflow-backend:latest"
echo ""
echo -e "To run: docker-compose up"
echo -e "To run production: docker-compose -f docker-compose.prod.yml up"
```

Make it executable:

```bash
chmod +x backend/scripts/build.sh
```

---

## The Verification

### Step 1: Build the Docker Image

```bash
cd project-root
./backend/scripts/build.sh
```

### Step 2: Run Development Environment

```bash
docker-compose up
```

### Step 3: Test the Container

```bash
# Check if the container is running
docker ps

# Test the health check
curl http://localhost:8000/health/

# Test the API
curl http://localhost:8000/api/v1/tasks/
```

### Step 4: Check Container Logs

```bash
docker logs taskflow-backend
docker logs taskflow-db
docker logs taskflow-redis
```

### Step 5: Run Production Build

```bash
# Build production image
docker build -f backend/Dockerfile -t taskflow-backend:prod .

# Run with production compose
docker-compose -f docker-compose.prod.yml up -d
```

---

## Key Takeaways

1. **Multi-stage builds** reduce image size by separating build and runtime.

2. **Non-root user** improves security in containers.

3. **Health checks** enable container orchestration and monitoring.

4. **Environment variables** configure containers for different environments.

5. **Volume mounts** persist data and manage secrets.

6. **Entrypoint scripts** handle pre-startup tasks.

7. **Gunicorn** provides production-ready WSGI serving.

---

## What's Next

In **Part 28**, we'll Dockerize Next.js:

- Multi-stage Dockerfile for Next.js
- Production optimizations
- Environment configuration
- Standalone builds

---

**End of Part 27**

*Next: Part 28 - Dockerizing Next.js*
