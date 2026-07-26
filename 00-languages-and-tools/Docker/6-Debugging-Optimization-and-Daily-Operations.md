# Part 6 – Debugging, Optimization, and Daily Operations

Your application is now production-ready, but the journey doesn't end at deployment. In the real world, containers will misbehave, performance will degrade, and you'll need to troubleshoot issues quickly. This part transforms you from a Docker developer into a Docker operator—someone who can debug, optimize, and maintain containerized systems in production.

By the end, you'll have a systematic approach to troubleshooting, a toolkit of debugging commands, and strategies for optimizing container performance and rebuild times.

## 6.1 The Debugging Mindset

When containers fail, panic is not your friend. Instead, follow a systematic approach:

**The Debugging Checklist:**

1. **What changed?** Check recent deployments, configuration changes, or code updates
2. **What's the symptom?** 500 errors? Timeouts? Memory issues? Slow responses?
3. **Is the container running?** `docker ps` is your first command
4. **What do the logs say?** Logs are your primary debugging tool
5. **Can we get inside?** `docker exec` gives you a terminal
6. **What's happening inside?** Process list, network connections, resource usage
7. **Is it the environment?** Check environment variables, mounted volumes, networks
8. **Has this happened before?** Check history, documentation, known issues

## 6.2 Container Inspection Commands

### `docker ps` – The Status Check

```bash
# All containers (including stopped)
docker ps -a

# Show only container IDs
docker ps -q

# Show with custom format
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

# Filter by status
docker ps --filter "status=exited"
docker ps --filter "status=running"

# Filter by label
docker ps --filter "label=environment=production"

# Filter by network
docker ps --filter "network=three-tier"
```

**Understanding container states:**
- `Up` – Running normally
- `Exited (0)` – Stopped successfully
- `Exited (1)` – Failed with error code
- `Restarting` – In restart loop (check health checks)
- `Paused` – Suspended
- `Created` – Created but not started

### `docker logs` – The Primary Debugging Tool

```bash
# Show all logs
docker logs container-name

# Show last N lines
docker logs --tail 100 container-name

# Follow logs in real-time (like tail -f)
docker logs -f container-name

# Show with timestamps
docker logs -t container-name

# Show logs since a specific time
docker logs --since 2024-01-15T10:00:00 container-name

# Show logs from last 30 minutes
docker logs --since 30m container-name

# Show logs with timestamps and follow
docker logs -f -t --tail 50 container-name
```

**Debugging with `docker logs`:**
```bash
# Find errors in logs
docker logs backend 2>&1 | grep -i error

# Look for specific patterns
docker logs backend | grep "ERROR\|WARN\|FATAL"

# Count occurrences
docker logs backend | grep "Database connection" | wc -l

# Analyze JSON logs (if using structured logging)
docker logs backend | jq '.level' | sort | uniq -c
```

### `docker inspect` – Deep Dive

```bash
# Full inspection (JSON)
docker inspect container-name

# Get specific fields using Go templates
docker inspect container-name --format='{{.State.Status}}'
docker inspect container-name --format='{{.NetworkSettings.IPAddress}}'
docker inspect container-name --format='{{.Config.Env}}'

# Multiple fields
docker inspect container-name --format='
Status: {{.State.Status}}
IP: {{.NetworkSettings.IPAddress}}
Image: {{.Image}}
'

# Inspect the running process
docker inspect container-name --format='{{.State.Pid}}'

# Get container mounts
docker inspect container-name --format='{{json .Mounts}}' | jq .
```

**Common inspection patterns:**
```bash
# Check if container is restarting
docker inspect container-name --format='{{.State.Restarting}}'

# Get exit code
docker inspect container-name --format='{{.State.ExitCode}}'

# Check health status
docker inspect container-name --format='{{.State.Health.Status}}'

# View health check logs
docker inspect container-name --format='{{.State.Health.Log}}'
```

### `docker exec` – Getting Inside

**Interactive shell:**
```bash
# Execute bash in running container
docker exec -it container-name /bin/bash

# Execute sh (for Alpine)
docker exec -it container-name /bin/sh

# Execute as specific user
docker exec -it --user appuser container-name bash
```

**One-off commands:**
```bash
# Check environment variables
docker exec container-name env

# Check running processes
docker exec container-name ps aux

# Check network connections
docker exec container-name netstat -tulpn

# Check DNS resolution
docker exec container-name nslookup redis

# Check if ports are listening
docker exec container-name ss -tulpn

# Test HTTP endpoints internally
docker exec container-name curl -v http://localhost:5000/health

# Check disk usage inside container
docker exec container-name df -h
```

### `docker top` and `docker stats`

```bash
# Show processes inside container
docker top container-name

# Show with more details
docker top container-name aux

# Real-time resource usage (all containers)
docker stats

# Specific container
docker stats container-name

# No streaming (one-shot)
docker stats --no-stream container-name
```

## 6.3 Debugging Common Issues

### Issue 1: Container Won't Start

**Symptom:** Container exits immediately

**Debugging steps:**
```bash
# 1. Check if container exists
docker ps -a | grep container-name

# 2. Get exit code
docker inspect container-name --format='{{.State.ExitCode}}'

# 3. View logs
docker logs container-name

# 4. Run without detach to see startup
docker run --rm --name test-container your-image

# 5. Override command for debugging
docker run --rm -it your-image /bin/bash
# Then manually run the command
```

**Common causes:**
- Missing environment variables
- Incorrect command or entrypoint
- Port conflicts
- Volume permission issues
- Configuration file errors

### Issue 2: Container in Restart Loop

**Symptom:** `docker ps` shows `Restarting` state

**Debugging:**
```bash
# 1. Check restart policy
docker inspect container-name --format='{{.HostConfig.RestartPolicy}}'

# 2. View logs from multiple attempts
docker logs container-name --tail 50

# 3. Check health check failures
docker inspect container-name --format='{{.State.Health.Log}}'

# 4. Temporarily disable restart
docker update --restart=no container-name
docker stop container-name
docker start container-name
# Debug with logs
docker logs -f container-name
```

### Issue 3: Container Exits with Error Code 137

**Error code 137 = SIGKILL (usually OOM)**

```bash
# Check memory usage
docker stats container-name --no-stream

# Check if OOM killer was triggered
docker inspect container-name --format='{{.State.OOMKilled}}'

# Increase memory limit
docker update --memory 1G container-name
```

### Issue 4: Network Connectivity Issues

**Symptom:** Containers can't communicate

```bash
# Check network connectivity
docker network ls
docker network inspect app-network

# Test DNS resolution
docker exec container-name nslookup other-service

# Test ping (if ping command available)
docker exec container-name ping other-service

# Check ports are exposed
docker port container-name

# Check running services on ports
docker exec container-name netstat -tulpn

# Test from inside the container
docker exec container-name curl -v http://other-service:port

# Check firewall rules on host
sudo iptables -L -n | grep DOCKER
```

### Issue 5: Volume Permission Issues

**Symptom:** Container can't write to mounted volumes

```bash
# Check volume mount permissions
docker inspect container-name --format='{{.Mounts}}'

# Check ownership inside container
docker exec container-name ls -la /app/data

# Check UID/GID mapping
docker exec container-name id

# Fix by setting user in Dockerfile
# USER appuser
# Ensure UID matches host user if needed
```

## 6.4 Performance Optimization

### Image Optimization

**Step 1: Analyze image size**

```bash
# Check image sizes
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Analyze layers
docker history image-name

# Analyze with dive (great tool)
# Install: brew install dive (macOS) or snap install dive
dive image-name
```

**Step 2: Optimize Dockerfile**

```dockerfile
# ❌ Before (large image)
FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
COPY . /app
RUN pip3 install -r requirements.txt
CMD ["python3", "app.py"]

# ✅ After (optimized)
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN find . -name "*.pyc" -delete
CMD ["python", "app.py"]
```

**Step 3: Use Multi-stage Builds**

```dockerfile
# Build stage with dependencies
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Runtime stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
```

### Layer Cache Optimization

**Order layers from least to most frequently changing:**

```dockerfile
# ✅ Optimal order
FROM python:3.11-slim

# 1. Install system packages (rarely changes)
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Python dependencies (changes less often)
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Copy application code (changes frequently)
COPY . .

# 4. Build step (depends on code)
RUN python setup.py build

CMD ["python", "app.py"]
```

### Build Cache Management

```bash
# View build cache usage
docker system df

# Detailed breakdown
docker system df -v

# Clean build cache
docker builder prune

# Aggressive pruning
docker builder prune -a -f

# Clean everything
docker system prune -a --volumes
```

### Development Optimization: Hot Reload

**`docker-compose.dev.yml`:**
```yaml
services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    volumes:
      - ./backend:/app
      - /app/__pycache__
    environment:
      - FLASK_DEBUG=1
      - PYTHONUNBUFFERED=1
    command: python -m flask run --host=0.0.0.0 --port=5000 --reload

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    command: npm start
```

### Network Optimization

```bash
# Use host network for performance-critical services
docker run --network host performance-critical-service

# Use specific network with custom subnet
docker network create --subnet=172.20.0.0/16 custom-net

# Optimize DNS settings
docker run --dns 8.8.8.8 --dns 1.1.1.1 your-image
```

## 6.5 Logging Optimization

### Log Rotation Configuration

**`docker-compose.yml` (production logging):**
```yaml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"      # Rotate at 10MB
        max-file: "5"        # Keep 5 files
        compress: "true"     # Compress old logs
        tag: "{{.Name}}/{{.ID}}"
```

### Structured Logging

**`backend/structured_logger.py`:**
```python
import json
import logging
from datetime import datetime

class StructuredLogger:
    def __init__(self, name, level=logging.INFO):
        self.logger = logging.getLogger(name)
        self.logger.setLevel(level)
        
        # Add JSON handler
        handler = logging.StreamHandler()
        handler.setFormatter(JSONFormatter())
        self.logger.addHandler(handler)
    
    def log(self, level, message, **kwargs):
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': level,
            'message': message,
            **kwargs
        }
        self.logger.log(getattr(logging, level.upper()), json.dumps(log_entry))

# Usage
logger = StructuredLogger('app')
logger.log('info', 'User logged in', user_id=123, ip='192.168.1.1')
logger.log('error', 'Database connection failed', error='Connection timeout')
```

### Log Aggregation with Filebeat

**`docker-compose.logging.yml`:**
```yaml
services:
  filebeat:
    image: docker.elastic.co/beats/filebeat:8.10.0
    user: root
    volumes:
      - ./filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - monitoring
    command: filebeat -e -strict.perms=false
```

## 6.6 Resource Optimization

### Monitoring Resource Usage

```bash
# Real-time monitoring
docker stats

# With formatting
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

# One-shot for all containers
docker stats --no-stream

# Specific container with JSON output
docker stats --no-stream --format "{{json .}}" container-name | jq .
```

### Tuning Resource Limits

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '1.5'
          memory: 768M
        reservations:
          cpus: '0.5'
          memory: 256M
    # Also set application-level limits
    environment:
      - NODE_OPTIONS=--max-old-space-size=512
      - PYTHON_MEMORY_LIMIT=512M
```

### Database Connection Pooling

**`backend/db_pool.py`:**
```python
import psycopg2
from psycopg2 import pool
import os

class DatabasePool:
    def __init__(self):
        self.pool = psycopg2.pool.SimpleConnectionPool(
            1,  # min connections
            10,  # max connections
            host=os.getenv('DB_HOST'),
            port=os.getenv('DB_PORT'),
            database=os.getenv('DB_NAME'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD')
        )
    
    def get_connection(self):
        return self.pool.getconn()
    
    def return_connection(self, conn):
        self.pool.putconn(conn)
    
    def close_all(self):
        self.pool.closeall()

# Usage with context manager
db_pool = DatabasePool()

with db_pool.get_connection() as conn:
    cur = conn.cursor()
    cur.execute("SELECT * FROM users")
    results = cur.fetchall()
```

## 6.7 Advanced Debugging Techniques

### Docker Events

```bash
# Watch all Docker events
docker events

# Filter events
docker events --filter "type=container" --filter "event=die"

# Watch specific container
docker events --filter "container=container-name"

# Monitor restart events
docker events --filter "event=restart"
```

### Debugging with `docker cp`

```bash
# Copy files from container
docker cp container-name:/app/logs/app.log ./app.log

# Copy files to container
docker cp ./config.json container-name:/app/config.json

# Copy entire directory
docker cp container-name:/app/data ./data-backup
```

### Debugging the Docker Daemon

```bash
# Check Docker daemon logs (Linux)
sudo journalctl -u docker.service

# Mac/Windows: Check Docker Desktop logs
# Settings -> Troubleshoot -> Get support -> View logs

# Increase Docker daemon debug level
sudo dockerd --debug

# Check daemon configuration
cat /etc/docker/daemon.json
```

## 6.8 Troubleshooting Lab: Fix the Broken Setup

### The Broken Setup

You've been handed a broken multi-container setup. Let's debug and fix it.

**`docker-compose.broken.yml`:**
```yaml
version: '3.8'

services:
  web:
    image: nginx:latest
    volumes:
      - ./html:/usr/share/nginx/html
    ports:
      - "8080:80"
    environment:
      - NGINX_HOST=localhost
    depends_on:
      - app

  app:
    build: .
    environment:
      - DB_HOST=db
      - REDIS_HOST=redis
    ports:
      - "5000:5000"
    depends_on:
      - db
      - redis

  db:
    image: postgres
    environment:
      - POSTGRES_DB=app
    volumes:
      - ./data:/var/lib/postgresql/data

  redis:
    image: redis
    command: redis-server --maxmemory 100mb
```

### Debugging Steps

**Step 1: Check container status**
```bash
docker compose -f docker-compose.broken.yml ps
```
```
NAME          IMAGE     COMMAND     SERVICE   CREATED   STATUS    PORTS
web           nginx     ...         web       2m ago    Running   0.0.0.0:8080->80/tcp
app           ...       ...         app       2m ago    Exited(1)   ...
db            postgres  ...         db        2m ago    Running   5432/tcp
redis         redis     ...         redis     2m ago    Running   6379/tcp
```

**Step 2: Check logs of the failed container**
```bash
docker compose -f docker-compose.broken.yml logs app
```
```
app_1  | Traceback (most recent call last):
app_1  |   File "app.py", line 5, in <module>
app_1  |     from flask import Flask
app_1  | ModuleNotFoundError: No module named 'flask'
```

**Step 3: Check the Dockerfile**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]
```

**Problem:** Flask not installed in Dockerfile.

**Fix:** Add requirements.txt installation.

**Step 4: Check database configuration**
```bash
docker compose -f docker-compose.broken.yml logs db
```
```
db_1  | FATAL:  role "root" does not exist
```

**Problem:** Database credentials not set properly.

**Fix:** Set POSTGRES_USER and POSTGRES_PASSWORD.

**Step 5: Check port conflicts**
```bash
docker compose -f docker-compose.broken.yml ps
```
```
web   Exited(1)
```
```bash
docker logs broken_web_1
```
```
2024/01/15 10:00:00 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address in use)
```

**Problem:** Port 80 already in use on host.

**Fix:** Change host port mapping.

### The Fixed Setup

**`docker-compose.fixed.yml`:**
```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine  # Fixed: Use smaller, specific version
    volumes:
      - ./html:/usr/share/nginx/html:ro  # Fixed: Read-only for security
    ports:
      - "8081:80"  # Fixed: Different host port
    depends_on:
      app:
        condition: service_healthy
    restart: unless-stopped

  app:
    build:
      context: .
      dockerfile: Dockerfile.fixed  # Fixed: New Dockerfile
    environment:
      - DB_HOST=db
      - DB_USER=appuser  # Fixed: Set explicit user
      - DB_PASSWORD=secret  # Fixed: Set password
      - DB_NAME=appdb
      - REDIS_HOST=redis
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 5s
      retries: 3

  db:
    image: postgres:15-alpine  # Fixed: Specific version
    environment:
      - POSTGRES_USER=appuser  # Fixed: Set user
      - POSTGRES_PASSWORD=secret  # Fixed: Set password
      - POSTGRES_DB=appdb
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - pg-data:/var/lib/postgresql/data  # Fixed: Named volume
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7.2-alpine  # Fixed: Specific version
    command: redis-server --maxmemory 256mb --appendonly yes
    volumes:
      - redis-data:/data  # Fixed: Named volume

volumes:
  pg-data:
  redis-data:
```

**`Dockerfile.fixed`:**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies first
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app.py .

# Add health check endpoint
RUN echo "from flask import Flask\napp=Flask(__name__)\n@app.route('/health')\ndef health():return {'status':'ok'}" > health.py

# Run as non-root
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser
USER appuser

CMD ["python", "app.py"]
```

## 6.9 Daily Operations Checklist

### Morning Check
```bash
# 1. Check all containers are running
docker ps --format "table {{.Names}}\t{{.Status}}"

# 2. Check resource usage
docker stats --no-stream

# 3. Check for recent errors
docker ps -a | grep Exited

# 4. Check disk usage
docker system df

# 5. Check logs for anomalies
docker ps -q | xargs -I {} docker logs --tail 10 {}
```

### Backup Routine
```bash
#!/bin/bash
# backup.sh - Daily backup script

BACKUP_DIR="/backups/$(date +%Y%m%d)"

# Backup volumes
docker run --rm -v pg-data:/source -v $BACKUP_DIR:/backup alpine \
    tar czf /backup/pg-data.tar.gz -C /source .

docker run --rm -v redis-data:/source -v $BACKUP_DIR:/backup alpine \
    tar czf /backup/redis-data.tar.gz -C /source .

# Backup environment configs
cp .env.production $BACKUP_DIR/

# Clean old backups (keep 30 days)
find /backups -type d -mtime +30 -exec rm -rf {} \;
```

### Health Check Automation
```bash
#!/bin/bash
# health-check.sh - Service health verification

# Check each service
for service in backend frontend redis postgres; do
    if docker compose ps --filter "status=healthy" | grep -q $service; then
        echo "✅ $service is healthy"
    else
        echo "❌ $service is unhealthy"
        # Take action: alert, restart, etc.
        docker compose restart $service
    fi
done

# Check API response
if curl -s -f http://localhost:5000/health > /dev/null; then
    echo "✅ API is responding"
else
    echo "❌ API is down"
    # Send alert
fi
```

## 6.10 Optimizing Rebuild Times

### Development Workflow

**`docker-compose.dev.yml`:**
```yaml
services:
  app:
    build:
      context: .
      cache_from:
        - app:latest
        - app:cache
    volumes:
      - .:/app
      - /app/node_modules
      - /app/__pycache__
    environment:
      - NODE_ENV=development
      - WATCHPACK_POLLING=true
    command: npm run dev
```

### Use BuildKit for Faster Builds

```bash
# Enable BuildKit
export DOCKER_BUILDKIT=1

# Build with BuildKit
docker build --progress=plain -t app .

# Use cache mounts for faster builds
docker build --mount=type=cache,target=/root/.cache/pip -t app .
```

**Dockerfile with BuildKit cache:**
```dockerfile
# syntax=docker/dockerfile:1.4
FROM python:3.11-slim

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

COPY . .

CMD ["python", "app.py"]
```

### Parallel Builds with Compose

```bash
# Build all services in parallel
docker compose build --parallel

# Build specific services
docker compose build --parallel backend frontend
```

## 6.11 Summary

You've now mastered the art of operating containers in production:

**Debugging:**
- ✅ Systematic approach to troubleshooting
- ✅ `docker logs`, `docker inspect`, `docker exec`
- ✅ Resource monitoring with `docker stats`
- ✅ Event monitoring with `docker events`
- ✅ Debugging common issues (startup failures, OOM, networking)

**Optimization:**
- ✅ Image size optimization
- ✅ Layer cache optimization
- ✅ Resource limit tuning
- ✅ Development workflow optimization
- ✅ Build time optimization

**Operations:**
- ✅ Daily health checks
- ✅ Backup and restore procedures
- ✅ Log rotation and management
- ✅ Security scanning
- ✅ Performance monitoring

**Mental Models:**
- **Logs are truth**: Always start with logs when debugging
- **Systems are observable**: Use the right tools to see what's happening
- **Caches are opportunities**: Optimize build times through smart caching
- **Resources are limited**: Monitor and tune resource usage constantly

**What's Next:** Part 7 deepens container security and introduces registry-centric workflows—image signing, provenance, secrets management, and advanced CI/CD patterns for container registries.
