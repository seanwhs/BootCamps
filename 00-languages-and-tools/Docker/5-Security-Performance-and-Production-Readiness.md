# Part 5 – Security, Performance, and Production Readiness

Your application works beautifully on your laptop. But is it ready for the real world? Production environments demand more than just functional code—they require security, reliability, performance, and observability.

In this part, we'll transform our working application into a production-grade system. We'll harden security, set resource limits, implement proper logging, add health monitoring, and create a CI/CD pipeline. By the end, you'll have a deployable system that meets enterprise standards.

## 5.1 The Production Readiness Checklist

Before we dive in, let's understand what makes a container production-ready:

**Security:**
- [ ] Run as non-root user
- [ ] Use minimal base images
- [ ] Scan for vulnerabilities
- [ ] No secrets in images
- [ ] Read-only filesystem where possible
- [ ] Proper network isolation

**Performance:**
- [ ] CPU and memory limits set
- [ ] Proper logging (stdout/stderr)
- [ ] Health checks configured
- [ ] Optimized image size
- [ ] Efficient cache usage

**Reliability:**
- [ ] Restart policies defined
- [ ] Health checks with proper intervals
- [ ] Graceful shutdown handling
- [ ] Connection retries and timeouts

**Observability:**
- [ ] Structured logging
- [ ] Metrics collection
- [ ] Distributed tracing (if needed)
- [ ] Proper log rotation

## 5.2 Security Hardening: From Insecure to Production-Ready

Let's start with an intentionally insecure setup and harden it step by step.

### The Insecure Setup (DO NOT USE)

**`insecure/Dockerfile`:**
```dockerfile
FROM ubuntu:latest
RUN apt-get update && apt-get install -y python3 python3-pip
COPY app.py /app.py
# Running as root!
CMD ["python3", "/app.py"]
```

**Problems:**
1. Running as root
2. Using `latest` tag (unpredictable)
3. Huge image size
4. No vulnerability scanning
5. Secrets likely baked in

### Step 1: Run as Non-Root User

**`backend/Dockerfile` (security step 1):**
```dockerfile
FROM python:3.11-slim

# Create a non-root user
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .

# Switch to non-root user
USER appuser

CMD ["python", "app.py"]
```

**Why this matters:**
If an attacker exploits your application, they'll have limited permissions. They can't install packages, modify system files, or access other containers' data.

### Step 2: Read-Only Filesystem

**`docker-compose.yml` (read-only mode):**
```yaml
services:
  backend:
    build: ./backend
    read_only: yes  # Root filesystem is read-only
    volumes:
      - ./logs:/app/logs:rw     # Only writable directory
      - ./uploads:/app/uploads:rw
    tmpfs:
      - /tmp  # Temporary storage in memory
    security_opt:
      - no-new-privileges:true  # Prevent privilege escalation
    cap_drop:
      - ALL  # Drop all capabilities
    cap_add:
      - NET_BIND_SERVICE  # Only allow binding to ports
```

**Verification:**
```bash
# Try to create a file outside allowed directories
docker compose exec backend touch /test.txt
```
```
touch: /test.txt: Read-only file system
```

### Step 3: Drop Unnecessary Capabilities

Linux capabilities give processes special permissions. By default, containers get many capabilities they don't need.

**`docker-compose.yml` (capabilities):**
```yaml
services:
  backend:
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE  # Required for port binding (<1024)
      - CHOWN             # For file ownership changes
      - DAC_OVERRIDE      # For file permissions
      - SETGID
      - SETUID
    security_opt:
      - no-new-privileges:true
```

**Common capabilities:**
| Capability | Purpose | Keep? |
|------------|---------|-------|
| NET_BIND_SERVICE | Bind to ports <1024 | Usually yes |
| CHOWN | Change file ownership | Maybe |
| DAC_OVERRIDE | Bypass file permissions | Maybe |
| SYS_ADMIN | Many admin operations | Rarely |

### Step 4: Secrets Management

**Never** bake secrets into images. Here are proper approaches:

**Approach 1: Environment Variables (Simple):**
```yaml
services:
  backend:
    environment:
      - DB_PASSWORD=${DB_PASSWORD}  # From .env file
    env_file:
      - .env.production  # Not committed to git
```

**`.env.production` (DO NOT COMMIT):**
```
DB_PASSWORD=your-super-secret-production-password
SECRET_KEY=something-very-long-and-random
```

**Approach 2: Docker Secrets (Swarm Mode):**
```yaml
services:
  backend:
    secrets:
      - db_password
      - api_key

secrets:
  db_password:
    file: ./secrets/db_password.txt
  api_key:
    external: true
```

**Approach 3: HashiCorp Vault (Advanced):**
```yaml
services:
  backend:
    environment:
      - VAULT_ADDR=http://vault:8200
    volumes:
      - ./vault-agent-config.hcl:/vault/config/config.hcl
```

### Step 5: Vulnerability Scanning

**Using Docker Scout (built-in):**
```bash
# Scan your image
docker scout quickview backend:1.0

# Detailed scan
docker scout cves backend:1.0
```

**Using Trivy (open source):**
```bash
# Install Trivy
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Scan image
trivy image backend:1.0

# Scan with severity threshold
trivy image --severity HIGH,CRITICAL backend:1.0
```

**Using Grype:**
```bash
# Install Grype
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

# Scan image
grype backend:1.0
```

**Automated scanning in CI:**
```yaml
# .github/workflows/security-scan.yml
name: Security Scan
on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build image
        run: docker build -t app:latest .
      - name: Scan with Trivy
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'app:latest'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'HIGH,CRITICAL'
```

## 5.3 Resource Limits: Preventing Noisy Neighbors

Without limits, a single container can consume all host resources, affecting other containers.

### CPU Limits

**`docker-compose.yml`:**
```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '1.5'  # 1.5 CPU cores maximum
        reservations:
          cpus: '0.5'  # Guaranteed 0.5 cores

  redis:
    deploy:
      resources:
        limits:
          cpus: '1'
        reservations:
          cpus: '0.25'
```

**CPU limit formats:**
- `'0.5'` = 50% of one core
- `'1'` = One full core
- `'1.5'` = 1.5 cores
- `'2'` = Two cores

### Memory Limits

```yaml
services:
  backend:
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

  postgres:
    deploy:
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
```

**Memory formats:**
- `512M` = 512 megabytes
- `1G` = 1 gigabyte
- `1024Mi` = 1024 mebibytes
- `2Gi` = 2 gibibytes

### Example: Complete Resource Configuration

**`docker-compose.resources.yml`:**
```yaml
version: '3.8'

services:
  backend:
    build: ./backend
    deploy:
      resources:
        limits:
          cpus: '1.5'
          memory: 768M
        reservations:
          cpus: '0.5'
          memory: 256M
    ulimits:
      nofile:
        soft: 65536
        hard: 65536
      nproc:
        soft: 512
        hard: 512

  postgres:
    image: postgres:15-alpine
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
    shm_size: 256mb  # Shared memory for PostgreSQL
    ulimits:
      nofile:
        soft: 65536
        hard: 65536

  redis:
    image: redis:7.2-alpine
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 128M
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
```

### Monitoring Resource Usage

```bash
# Real-time stats for all containers
docker stats

# Specific container
docker stats backend

# With formatting
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
```

## 5.4 Logging: Production-Grade Logging

### The 12-Factor App: Log to stdout/stderr

**Never** write logs to files inside containers. Always log to stdout/stderr.

**`backend/app.py` (logging properly):**
```python
import logging
import sys
import json
from datetime import datetime

# Configure logging to stdout
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    stream=sys.stdout  # Explicitly use stdout
)

logger = logging.getLogger(__name__)

# Structured logging (JSON)
class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
            'module': record.module,
            'function': record.funcName,
            'line': record.lineno
        }
        return json.dumps(log_entry)

# Use JSON formatter in production
if os.getenv('ENVIRONMENT') == 'production':
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JSONFormatter())
    logger.handlers = [handler]

# Example usage
logger.info('Application started', extra={'event': 'startup'})
logger.error('Database connection failed', extra={'event': 'db_error'})
```

### Log Drivers and Rotation

**`docker-compose.yml` (logging configuration):**
```yaml
services:
  backend:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"      # Rotate when file reaches 10MB
        max-file: "3"        # Keep 3 rotated files
        compress: "true"     # Compress rotated logs
        tag: "{{.Name}}/{{.ID}}"  # Add identifying tags

  frontend:
    logging:
      driver: "fluentd"      # Send to Fluentd aggregator
      options:
        fluentd-address: localhost:24224
        tag: "docker.frontend"
```

**Alternative log drivers:**
```yaml
# AWS CloudWatch
logging:
  driver: "awslogs"
  options:
    awslogs-group: my-app-logs
    awslogs-region: us-east-1
    awslogs-stream: backend

# Syslog
logging:
  driver: "syslog"
  options:
    syslog-address: "tcp://192.168.0.42:123"
    syslog-facility: "daemon"

# GELF (Graylog Extended Log Format)
logging:
  driver: "gelf"
  options:
    gelf-address: "udp://graylog-server:12201"
```

### Centralized Logging with ELK Stack

**`docker-compose.logging.yml`:**
```yaml
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    volumes:
      - es-data:/usr/share/elasticsearch/data
    networks:
      - monitoring

  logstash:
    image: docker.elastic.co/logstash/logstash:8.10.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    ports:
      - "5000:5000"
    networks:
      - monitoring

  kibana:
    image: docker.elastic.co/kibana/kibana:8.10.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    networks:
      - monitoring

volumes:
  es-data:

networks:
  monitoring:
```

## 5.5 Health Checks: Making Services Self-Aware

Health checks let Docker know if your service is working properly.

### Basic Health Check Patterns

**HTTP health check (most common):**
```yaml
services:
  backend:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 10s
```

**TCP health check:**
```yaml
services:
  postgres:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U appuser -d appdb"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
```

**Custom script health check:**
```yaml
services:
  redis:
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
```

**Application-level health check:**
```python
# In your app code
@app.route('/health')
def health():
    checks = {
        'database': check_database(),
        'redis': check_redis(),
        'status': 'healthy'
    }
    
    if any(not check for check in checks.values()):
        return jsonify(checks), 503  # Service Unavailable
    
    return jsonify(checks), 200
```

### Advanced Health Checks

**`docker-compose.health.yml`:**
```yaml
services:
  backend:
    healthcheck:
      test: |
        ["CMD-SHELL", 
         "python -c \"import requests; requests.get('http://localhost:5000/health', timeout=2).raise_for_status()\""]
      interval: 15s
      timeout: 5s
      retries: 3
      start_period: 30s

  frontend:
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 3s
      retries: 3

  redis:
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  postgres:
    healthcheck:
      test: ["CMD-SHELL", 
             "pg_isready -U ${DB_USER:-appuser} -d ${DB_NAME:-appdb}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
```

### Using Health Checks in Dependencies

```yaml
services:
  backend:
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy

  frontend:
    depends_on:
      backend:
        condition: service_healthy
```

## 5.6 Graceful Shutdown and Signal Handling

Containers should handle termination signals gracefully.

### Signal Handling in Python

**`backend/app.py` (graceful shutdown):**
```python
import signal
import sys
import time

class Application:
    def __init__(self):
        self.running = True
        signal.signal(signal.SIGTERM, self.shutdown)
        signal.signal(signal.SIGINT, self.shutdown)
    
    def shutdown(self, signum, frame):
        logger.info(f"Received signal {signum}, shutting down gracefully...")
        self.running = False
        # Clean up connections
        self.close_connections()
        # Allow time for cleanup
        time.sleep(2)
        sys.exit(0)
    
    def close_connections(self):
        """Close database connections, flush logs, etc."""
        if self.db_connection:
            self.db_connection.close()
        logger.info("Connections closed")
    
    def run(self):
        logger.info("Application started")
        while self.running:
            # Your main loop
            time.sleep(1)
        logger.info("Application stopped")

if __name__ == '__main__':
    app = Application()
    app.run()
```

### Docker Stop Behavior

```bash
# Default: sends SIGTERM, waits 10 seconds, then SIGKILL
docker stop container

# Custom timeout (30 seconds)
docker stop -t 30 container
```

**`docker-compose.yml` (stop behavior):**
```yaml
services:
  backend:
    stop_grace_period: 30s  # Wait 30 seconds for graceful shutdown
    stop_signal: SIGTERM    # Signal to send (default: SIGTERM)

  app-with-queue:
    stop_grace_period: 60s  # Longer for apps with pending work
```

### PreStop Hooks (Kubernetes)

```yaml
services:
  backend:
    lifecycle:
      pre_stop:
        exec:
          command: ["sh", "-c", "sleep 10 && python manage.py drain_queue"]
```

## 5.7 CI/CD Pipeline: GitHub Actions

Now let's automate building, testing, and deploying our containers.

### Complete GitHub Actions Workflow

**`.github/workflows/deploy.yml`:**
```yaml
name: Build, Test, and Deploy

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  REGISTRY: ghcr.io  # GitHub Container Registry
  IMAGE_NAME: ${{ github.repository }}

jobs:
  # ============================================================
  # Job 1: Build and Test
  # ============================================================
  build-and-test:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v2
    
    - name: Cache Docker layers
      uses: actions/cache@v3
      with:
        path: /tmp/.buildx-cache
        key: ${{ runner.os }}-buildx-${{ github.sha }}
        restore-keys: |
          ${{ runner.os }}-buildx-
    
    - name: Build Docker images
      run: |
        docker compose -f docker-compose.yml -f docker-compose.ci.yml build
    
    - name: Run tests
      run: |
        docker compose up -d
        docker compose exec -T backend pytest /app/tests
        docker compose exec -T backend python -m unittest discover
    
    - name: Security scan
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'backend:latest'
        format: 'sarif'
        output: 'trivy-results.sarif'
        severity: 'HIGH,CRITICAL'
    
    - name: Upload scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'
    
    - name: Log in to container registry
      uses: docker/login-action@v2
      if: github.event_name != 'pull_request'
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v4
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=sha,format=short
          type=raw,value=latest,enable=${{ github.ref == 'refs/heads/main' }}
    
    - name: Build and push
      uses: docker/build-push-action@v4
      if: github.event_name != 'pull_request'
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=local,src=/tmp/.buildx-cache
        cache-to: type=local,dest=/tmp/.buildx-cache-new,mode=max
    
    - name: Move cache
      run: |
        rm -rf /tmp/.buildx-cache
        mv /tmp/.buildx-cache-new /tmp/.buildx-cache

  # ============================================================
  # Job 2: Deploy to Production
  # ============================================================
  deploy-production:
    runs-on: ubuntu-latest
    needs: build-and-test
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: production
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Deploy to production server
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.PRODUCTION_HOST }}
        username: ${{ secrets.PRODUCTION_USER }}
        key: ${{ secrets.PRODUCTION_SSH_KEY }}
        script: |
          cd /app
          docker compose pull
          docker compose up -d --force-recreate
          docker system prune -af

  # ============================================================
  # Job 3: Deploy to Staging
  # ============================================================
  deploy-staging:
    runs-on: ubuntu-latest
    needs: build-and-test
    if: github.ref == 'refs/heads/develop' && github.event_name == 'push'
    environment: staging
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Deploy to staging
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.STAGING_HOST }}
        username: ${{ secrets.STAGING_USER }}
        key: ${{ secrets.STAGING_SSH_KEY }}
        script: |
          cd /app
          docker compose -f docker-compose.yml -f docker-compose.staging.yml pull
          docker compose -f docker-compose.yml -f docker-compose.staging.yml up -d --force-recreate
```

### CI-Specific Compose File

**`docker-compose.ci.yml`:**
```yaml
version: '3.8'

services:
  backend:
    build:
      context: ./backend
      target: builder  # Build test stage
    environment:
      - ENVIRONMENT=testing
      - DB_HOST=postgres
      - REDIS_HOST=redis
    volumes:
      - ./backend:/app
    command: python -m pytest --cov=/app --cov-report=xml

  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=testuser
      - POSTGRES_PASSWORD=testpass
      - POSTGRES_DB=testdb
    ports:
      - "5432:5432"

  redis:
    image: redis:7.2-alpine
    ports:
      - "6379:6379"
```

### Docker Buildx for Multi-Platform

**`.github/workflows/multi-platform.yml`:**
```yaml
name: Build Multi-Platform Images

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up QEMU
        uses: docker/setup-qemu-action@v2
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          platforms: linux/amd64,linux/arm64,linux/arm/v7
          push: true
          tags: |
            user/app:latest
            user/app:${{ github.ref_name }}
```

## 5.8 Production-Ready Configuration: Putting It All Together

Now let's combine everything into a production-grade configuration.

### Complete Production Dockerfile

**`backend/Dockerfile.prod`:**
```dockerfile
# ============================================================
# Stage 1: Builder
# ============================================================
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# ============================================================
# Stage 2: Runtime
# ============================================================
FROM python:3.11-slim

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app user with specific UID/GID
RUN groupadd --system --gid 1001 appgroup && \
    useradd --system --uid 1001 --gid 1001 --no-create-home appuser

WORKDIR /app

# Create necessary directories
RUN mkdir -p logs uploads tmp && \
    chown -R appuser:appgroup /app && \
    chmod 755 /app

# Copy dependencies from builder
COPY --from=builder /root/.local /root/.local

# Copy application code
COPY --chown=appuser:appgroup app.py .

# Set PATH
ENV PATH=/root/.local/bin:$PATH

# Python settings
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONHASHSEED=random

# Security settings
ENV ENVIRONMENT=production

# Switch to non-root user
USER appuser

# Port configuration
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Start application
CMD ["python", "app.py"]
```

### Complete Production Compose File

**`docker-compose.prod.yml`:**
```yaml
version: '3.8'

services:
  # ============================================================
  # Nginx Reverse Proxy
  # ============================================================
  nginx:
    image: nginx:alpine
    container_name: prod-nginx
    volumes:
      - ./nginx/prod.conf:/etc/nginx/conf.d/default.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./certbot/www:/var/www/certbot:ro
    ports:
      - "80:80"
      - "443:443"
    networks:
      - web
    depends_on:
      - frontend
      - backend
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ============================================================
  # Frontend
  # ============================================================
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
    container_name: prod-frontend
    volumes:
      - ./frontend/static:/usr/share/nginx/html/static:ro
    networks:
      - web
    depends_on:
      backend:
        condition: service_healthy
    restart: unless-stopped
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 128M
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ============================================================
  # Backend API
  # ============================================================
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    container_name: prod-backend
    environment:
      - REDIS_HOST=redis
      - REDIS_PORT=6379
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_USER=${DB_USER}
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_NAME=${DB_NAME}
      - SECRET_KEY=${SECRET_KEY}
      - ENVIRONMENT=production
      - LOG_LEVEL=WARNING
    volumes:
      - ./logs:/app/logs:rw
      - ./uploads:/app/uploads:rw
    networks:
      - web
      - internal
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped
    read_only: yes
    tmpfs:
      - /tmp:size=100M
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    deploy:
      resources:
        limits:
          cpus: '1.5'
          memory: 768M
        reservations:
          cpus: '0.5'
          memory: 256M
      replicas: 2
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
      rollback_config:
        parallelism: 1
        delay: 10s
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 5s
      retries: 3
      start_period: 40s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
        tag: "backend"

  # ============================================================
  # PostgreSQL
  # ============================================================
  postgres:
    image: postgres:15-alpine
    container_name: prod-postgres
    environment:
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=${DB_NAME}
      - PGDATA=/var/lib/postgresql/data/pgdata
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./postgres/init:/docker-entrypoint-initdb.d:ro
    networks:
      - internal
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
    shm_size: 256mb
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER} -d ${DB_NAME}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # ============================================================
  # Redis
  # ============================================================
  redis:
    image: redis:7.2-alpine
    container_name: prod-redis
    command: redis-server --appendonly yes --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - redis-data:/data
    networks:
      - internal
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - DAC_OVERRIDE
      - SETGID
      - SETUID
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 128M
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

# ============================================================
# Volumes
# ============================================================
volumes:
  postgres-data:
    driver: local
    driver_opts:
      type: none
      device: ${DATA_PATH:-/var/lib/docker-data}/postgres
      o: bind
  redis-data:
    driver: local
    driver_opts:
      type: none
      device: ${DATA_PATH:-/var/lib/docker-data}/redis
      o: bind

# ============================================================
# Networks
# ============================================================
networks:
  web:
    name: prod-web
    driver: bridge
  internal:
    name: prod-internal
    driver: bridge
    internal: true  # No external access
```

### Nginx Production Configuration

**`nginx/prod.conf`:**
```nginx
# Rate limiting
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

server {
    listen 80;
    server_name example.com;
    
    # Redirect to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name example.com;
    
    # SSL configuration
    ssl_certificate /etc/nginx/ssl/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Frontend
    location / {
        proxy_pass http://frontend:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Backend API
    location /api/ {
        limit_req zone=api burst=20 nodelay;
        
        proxy_pass http://backend:5000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Static assets
    location /static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Health check (bypass rate limiting)
    location /health {
        access_log off;
        proxy_pass http://backend:5000/health;
    }
}
```

## 5.9 Deployment Strategies

### Blue-Green Deployment

**`docker-compose.blue.yml`:**
```yaml
services:
  backend:
    image: ghcr.io/user/app:blue
    container_name: backend-blue
    # ... rest of configuration
```

**`docker-compose.green.yml`:**
```yaml
services:
  backend:
    image: ghcr.io/user/app:green
    container_name: backend-green
    # ... rest of configuration
```

**Deployment script:**
```bash
#!/bin/bash
# deploy.sh
set -e

# Deploy green
docker compose -f docker-compose.green.yml up -d

# Wait for health check
sleep 30

# Test green
if curl -s http://localhost:5000/health | grep -q healthy; then
    # Switch traffic
    docker compose -f docker-compose.proxy.yml up -d --force-recreate
    # Remove blue
    docker compose -f docker-compose.blue.yml down
else
    echo "Deployment failed! Rolling back..."
    docker compose -f docker-compose.green.yml down
    exit 1
fi
```

### Canary Deployment

```yaml
services:
  backend:
    deploy:
      replicas: 2
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback
      rollback_config:
        parallelism: 1
        delay: 10s
```

## 5.10 Monitoring and Alerting

### Prometheus and Grafana Setup

**`docker-compose.monitoring.yml`:**
```yaml
services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    ports:
      - "9090:9090"
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    volumes:
      - grafana-data:/var/lib/grafana
    ports:
      - "3000:3000"
    networks:
      - monitoring
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}

  node-exporter:
    image: prom/node-exporter:latest
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    ports:
      - "9100:9100"
    networks:
      - monitoring

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    ports:
      - "8080:8080"
    networks:
      - monitoring

volumes:
  prometheus-data:
  grafana-data:

networks:
  monitoring:
```

### Application Metrics

**`backend/metrics.py`:**
```python
from prometheus_client import Counter, Histogram, Gauge, generate_latest
from flask import Response

# Metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'Request duration', ['method', 'endpoint'])
ACTIVE_CONNECTIONS = Gauge('active_connections', 'Active connections')

@app.before_request
def before_request():
    request.start_time = time.time()
    ACTIVE_CONNECTIONS.inc()

@app.after_request
def after_request(response):
    request_duration = time.time() - request.start_time
    REQUEST_COUNT.labels(method=request.method, endpoint=request.path).inc()
    REQUEST_DURATION.labels(method=request.method, endpoint=request.path).observe(request_duration)
    ACTIVE_CONNECTIONS.dec()
    return response

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype='text/plain')
```

## 5.11 Lab: Production Readiness Exercise

### Part 1: Harden the Insecure Setup

**Given this insecure Dockerfile:**
```dockerfile
FROM ubuntu:latest
RUN apt-get update
COPY . /app
RUN apt-get install -y python3
EXPOSE 8000
CMD ["python3", "/app/app.py"]
```

**Your tasks:**
1. Switch to a slim base image
2. Add multi-stage build
3. Run as non-root user
4. Add health check
5. Configure logging to stdout

### Part 2: Resource Limits

**Add limits to the insecure setup:**
1. CPU: 1 core limit, 0.5 core reservation
2. Memory: 512MB limit, 256MB reservation
3. Set ulimits for file descriptors

### Part 3: Production Compose File

**Create a production compose file with:**
1. All security hardening
2. Resource limits
3. Health checks with dependencies
4. Proper logging configuration
5. Network isolation (public vs private)

### Solution

**`Dockerfile.prod`:**
```dockerfile
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser
COPY --from=builder /root/.local /root/.local
COPY app.py .
ENV PATH=/root/.local/bin:$PATH
USER appuser
HEALTHCHECK CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1
EXPOSE 8000
CMD ["python", "app.py"]
```

**`docker-compose.prod.yml`:**
```yaml
version: '3.8'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.prod
    read_only: yes
    tmpfs:
      - /tmp
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
    logging:
      driver: json-file
      options:
        max-size: 10m
        max-file: 3
    restart: unless-stopped
```

## 5.12 Summary

You've now transformed a simple container into a production-grade system:

**Security:**
- ✅ Non-root user execution
- ✅ Read-only filesystem
- ✅ Dropped unnecessary capabilities
- ✅ Secrets management
- ✅ Vulnerability scanning
- ✅ Minimal base images

**Performance:**
- ✅ CPU and memory limits
- ✅ Resource reservations
- ✅ Optimal logging configuration
- ✅ Multi-stage builds for small images

**Reliability:**
- ✅ Health checks with proper intervals
- ✅ Restart policies
- ✅ Graceful shutdown handling
- ✅ Connection retries and timeouts

**CI/CD:**
- ✅ Automated builds and tests
- ✅ Security scanning in pipeline
- ✅ Multi-platform builds
- ✅ Automated deployments

**Observability:**
- ✅ Structured logging to stdout
- ✅ Health check endpoints
- ✅ Metrics collection
- ✅ Monitoring stack ready

**Mental Models:**
- **Defense in depth**: Multiple security layers protect your application
- **Resource guarantees**: Limits prevent noisy neighbors
- **Health as contract**: Health checks define service readiness
- **Pipeline as automation**: CI/CD removes manual error

**What's Next:** Part 6 focuses on debugging, optimization, and daily operations—how to troubleshoot issues, optimize performance, and maintain your containerized application over time.
