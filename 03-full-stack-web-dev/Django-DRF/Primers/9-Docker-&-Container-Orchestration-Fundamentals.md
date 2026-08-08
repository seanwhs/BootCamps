# Primer 9: Docker & Container Orchestration Fundamentals

## Essential Docker and Orchestration Knowledge for the Masterclass

Welcome to **Primer 9** of the Django REST Framework & Next.js 16 masterclass. This primer provides a comprehensive introduction to Docker and container orchestration concepts used throughout the series.

---

## Section 1: Docker Fundamentals

### 1.1 What is Docker?

Docker is a platform for developing, shipping, and running applications in containers. Containers are lightweight, portable, and self-sufficient environments that package an application and its dependencies.

**Key Benefits:**
- **Consistency**: Same environment everywhere (dev, test, prod)
- **Isolation**: Applications run in isolated environments
- **Portability**: Run on any system with Docker
- **Efficiency**: Lightweight compared to virtual machines
- **Reproducibility**: Infrastructure as code

### 1.2 Docker Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Architecture                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Docker Client                         │   │
│  │    (docker CLI, Docker Compose, API)               │   │
│  └─────────────────────┬───────────────────────────────┘   │
│                        │                                    │
│                        ▼                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Docker Daemon                         │   │
│  │    (dockerd - manages containers, images, etc.)    │   │
│  └─────────────────────┬───────────────────────────────┘   │
│                        │                                    │
│            ┌───────────┴───────────┐                       │
│            ▼                       ▼                       │
│  ┌─────────────────┐     ┌─────────────────┐              │
│  │  Docker Images  │     │   Containers    │              │
│  │   (Blueprints)  │     │   (Running)     │              │
│  └─────────────────┘     └─────────────────┘              │
│            │                       │                       │
│            ▼                       ▼                       │
│  ┌─────────────────┐     ┌─────────────────┐              │
│  │  Docker Registry│     │   Volumes       │              │
│  │   (Storage)     │     │   (Data)        │              │
│  └─────────────────┘     └─────────────────┘              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 Docker Components

| Component | Description | Analogy |
|-----------|-------------|---------|
| **Image** | Read-only template | Recipe |
| **Container** | Running instance of image | Cooked meal |
| **Dockerfile** | Instructions for building image | Recipe card |
| **Registry** | Storage for images | Recipe book |
| **Volume** | Persistent data | Pantry |
| **Network** | Communication between containers | Phone lines |

---

## Section 2: Docker Images

### 2.1 Dockerfile Structure

```dockerfile
# 1. Base image
FROM python:3.12-slim

# 2. Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# 3. Set working directory
WORKDIR /app

# 4. Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# 5. Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 6. Copy application code
COPY . .

# 7. Create non-root user
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --gid 1001 appuser
USER appuser

# 8. Expose port
EXPOSE 8000

# 9. Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8000/health/ || exit 1

# 10. Command
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "config.wsgi"]
```

### 2.2 Image Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Image Layers                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Layer 5: Application Code                          │  │
│  │  (COPY . .)                                        │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Layer 4: Python Dependencies                       │  │
│  │  (pip install -r requirements.txt)                 │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Layer 3: System Packages                           │  │
│  │  (apt-get install libpq-dev)                       │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Layer 2: Base Python Image                         │  │
│  │  (FROM python:3.12-slim)                            │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Layer 1: Base OS (Alpine Linux)                    │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 2.3 Multi-Stage Builds

```dockerfile
# Stage 1: Builder
FROM python:3.12-slim AS builder

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Stage 2: Production
FROM python:3.12-slim

WORKDIR /app

# Copy from builder
COPY --from=builder /root/.local /root/.local
COPY . .

# Update PATH
ENV PATH=/root/.local/bin:$PATH

# Run
CMD ["python", "app.py"]
```

### 2.4 .dockerignore

```gitignore
# Python
__pycache__/
*.pyc
*.pyo
.venv
venv/
env/

# Environment
.env
.env.local

# Git
.git
.gitignore

# IDE
.vscode/
.idea/
*.swp

# Docker
Dockerfile
.dockerignore

# Logs
*.log
logs/

# Testing
tests/
.coverage
htmlcov/
.pytest_cache/

# Build
dist/
build/
*.egg-info/
```

---

## Section 3: Docker Compose

### 3.1 Basic docker-compose.yml

```yaml
version: '3.8'

services:
  # Backend
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: taskflow-backend
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/db
      - REDIS_URL=redis://redis:6379/1
      - DJANGO_ENV=development
    volumes:
      - ./backend:/app
      - /app/staticfiles
    ports:
      - "8000:8000"
    depends_on:
      - db
      - redis
    networks:
      - taskflow-network

  # Database
  db:
    image: postgres:15-alpine
    container_name: taskflow-db
    environment:
      - POSTGRES_DB=taskflow_db
      - POSTGRES_USER=taskflow_user
      - POSTGRES_PASSWORD=taskflow_pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
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
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    networks:
      - taskflow-network

networks:
  taskflow-network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
```

### 3.2 Compose Commands

```bash
# Start services
docker-compose up
docker-compose up -d  # Detached mode

# Stop services
docker-compose down
docker-compose down -v  # Remove volumes

# View logs
docker-compose logs
docker-compose logs -f
docker-compose logs backend

# List services
docker-compose ps

# Execute commands
docker-compose exec backend bash
docker-compose exec db psql -U user -d db

# Build/rebuild
docker-compose build
docker-compose build --no-cache

# Pull latest images
docker-compose pull

# Restart service
docker-compose restart backend

# Scale service
docker-compose up --scale backend=3 -d
```

---

## Section 4: Container Orchestration

### 4.1 What is Orchestration?

Container orchestration is the automated management of containers at scale. It handles:
- Deployment and scaling
- Load balancing
- Service discovery
- Health monitoring
- Rolling updates
- Self-healing

### 4.2 Orchestration Tools

| Tool | Description | Best For |
|------|-------------|----------|
| **Kubernetes** | Industry standard, complex | Large-scale, complex apps |
| **Docker Swarm** | Built into Docker | Simple, small-scale |
| **Amazon ECS** | AWS managed | AWS workloads |
| **Google GKE** | Google managed | GCP workloads |
| **Azure AKS** | Azure managed | Azure workloads |

### 4.3 Kubernetes Concepts

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Architecture                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                 Control Plane                       │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐         │   │
│  │  │  API     │  │  Scheduler│  │  Controller│        │   │
│  │  │  Server  │  │          │  │  Manager   │        │   │
│  │  └──────────┘  └──────────┘  └──────────┘         │   │
│  └─────────────────────┬───────────────────────────────┘   │
│                        │                                    │
│  ┌─────────────────────┴───────────────────────────────┐   │
│  │                    Worker Nodes                     │   │
│  │  ┌────────────────────────────────────────────────┐│   │
│  │  │  Pods                                          ││   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐   ││   │
│  │  │  │Container │  │Container │  │Container │   ││   │
│  │  │  └──────────┘  └──────────┘  └──────────┘   ││   │
│  │  └────────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 4.4 Kubernetes Resources

```yaml
# Pod - Smallest deployable unit
apiVersion: v1
kind: Pod
metadata:
  name: taskflow-backend
  labels:
    app: taskflow
    tier: backend
spec:
  containers:
  - name: backend
    image: taskflow-backend:latest
    ports:
    - containerPort: 8000
    env:
    - name: DATABASE_URL
      value: "postgresql://user:pass@db:5432/db"

---
# Deployment - Manages Pods
apiVersion: apps/v1
kind: Deployment
metadata:
  name: taskflow-backend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: taskflow
      tier: backend
  template:
    metadata:
      labels:
        app: taskflow
        tier: backend
    spec:
      containers:
      - name: backend
        image: taskflow-backend:latest
        ports:
        - containerPort: 8000

---
# Service - Exposes Pods
apiVersion: v1
kind: Service
metadata:
  name: taskflow-backend
spec:
  selector:
    app: taskflow
    tier: backend
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer

---
# Ingress - HTTP Routing
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: taskflow-ingress
spec:
  rules:
  - host: api.taskflow.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: taskflow-backend
            port:
              number: 80

---
# ConfigMap - Configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: taskflow-config
data:
  DJANGO_ENV: "production"
  DEBUG: "False"

---
# Secret - Sensitive Data
apiVersion: v1
kind: Secret
metadata:
  name: taskflow-secrets
type: Opaque
data:
  SECRET_KEY: <base64-encoded-key>
  DB_PASSWORD: <base64-encoded-password>
```

---

## Section 5: Docker Best Practices

### 5.1 Security Best Practices

```dockerfile
# ✅ Run as non-root
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --gid 1001 appuser
USER appuser

# ✅ Use specific base image
FROM python:3.12-slim

# ✅ Don't expose unnecessary ports
EXPOSE 8000

# ✅ Use health checks
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8000/health/ || exit 1

# ✅ Use secrets for sensitive data
# ❌ Don't use environment variables for secrets
```

### 5.2 Performance Best Practices

```dockerfile
# ✅ Combine RUN commands
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*

# ✅ Copy requirements first (better caching)
COPY requirements.txt .
RUN pip install -r requirements.txt

# ✅ Use multi-stage builds
FROM python:3.12-slim AS builder
# ... build ...
FROM python:3.12-slim
COPY --from=builder /app /app

# ✅ Use .dockerignore
# Prevents copying unnecessary files
```

### 5.3 Production Best Practices

```yaml
# docker-compose.prod.yml
services:
  backend:
    image: ${DOCKER_REGISTRY}/backend:${IMAGE_TAG}
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M
```

---

## Section 6: Docker Commands Reference

### Quick Reference

```bash
# Images
docker images
docker build -t name:tag .
docker pull image:tag
docker push image:tag
docker rmi image:tag
docker image prune

# Containers
docker run -d --name name image
docker ps
docker ps -a
docker stop container
docker start container
docker rm container
docker exec -it container bash
docker logs container
docker logs -f container

# Volumes
docker volume ls
docker volume create name
docker volume rm name
docker volume prune

# Networks
docker network ls
docker network create name
docker network rm name
docker network prune

# System
docker info
docker version
docker system df
docker system prune
docker stats
```

### Docker Run Options

| Option | Description | Example |
|--------|-------------|---------|
| `-d` | Run in background | `docker run -d image` |
| `-it` | Interactive terminal | `docker run -it image /bin/bash` |
| `--name` | Container name | `docker run --name myapp image` |
| `-p` | Port mapping | `docker run -p 8000:8000 image` |
| `-v` | Volume mount | `docker run -v /host:/container image` |
| `-e` | Environment variable | `docker run -e KEY=value image` |
| `--rm` | Remove on exit | `docker run --rm image` |
| `--network` | Network | `docker run --network net image` |

### Dockerfile Instructions

| Instruction | Purpose | Example |
|-------------|---------|---------|
| `FROM` | Base image | `FROM python:3.12-slim` |
| `RUN` | Execute command | `RUN pip install -r requirements.txt` |
| `COPY` | Copy files | `COPY . /app` |
| `ADD` | Copy with features | `ADD https://example.com/file /tmp/` |
| `WORKDIR` | Working directory | `WORKDIR /app` |
| `ENV` | Environment variable | `ENV DEBUG=False` |
| `EXPOSE` | Document port | `EXPOSE 8000` |
| `CMD` | Default command | `CMD ["python", "app.py"]` |
| `ENTRYPOINT` | Main command | `ENTRYPOINT ["/entrypoint.sh"]` |
| `USER` | Run as user | `USER appuser` |
| `VOLUME` | Mount point | `VOLUME /data` |
| `HEALTHCHECK` | Health check | `HEALTHCHECK CMD curl -f http://localhost/` |

---

*This concludes Primer 9. You now have the essential Docker and container orchestration knowledge needed for the masterclass.*
