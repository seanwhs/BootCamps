# Primer 4: Docker & Containerization Fundamentals

## Essential Docker and Containerization Knowledge for the Masterclass

Welcome to **Primer 4** of the Django REST Framework & Next.js 16 masterclass. This primer is designed for developers who need a quick refresh or introduction to Docker and containerization fundamentals before diving into the main series.

---

## Section 1: What is Docker?

### 1.1 Containerization Concepts

**Virtual Machines vs Containers:**

```
┌─────────────────────────────────────────────────────────────┐
│                    Virtual Machines                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │   App    │  │   App    │  │   App    │                  │
│  ├──────────┤  ├──────────┤  ├──────────┤                  │
│  │   Guest  │  │   Guest  │  │   Guest  │                  │
│  │   OS     │  │   OS     │  │   OS     │                  │
│  ├──────────┤  ├──────────┤  ├──────────┤                  │
│  │Hypervisor│  │Hypervisor│  │Hypervisor│                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                 Host OS                             │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      Containers                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                  │
│  │   App    │  │   App    │  │   App    │                  │
│  ├──────────┤  ├──────────┤  ├──────────┤                  │
│  │Container │  │Container │  │Container │                  │
│  │Runtime   │  │Runtime   │  │Runtime   │                  │
│  └──────────┘  └──────────┘  └──────────┘                  │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                 Docker Engine                       │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                 Host OS                             │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

**Key Differences:**
- **VMs**: Heavy, full OS, slower startup, more resources
- **Containers**: Lightweight, share host OS, fast startup, efficient

### 1.2 Docker Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Architecture                       │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Docker Client                         │   │
│  │         (docker CLI, Docker Compose)               │   │
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
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 1.3 Docker Components

**Images:** Read-only templates that define how to create containers
**Containers:** Running instances of images
**Dockerfile:** Recipe for building images
**Registry:** Storage for images (Docker Hub, ECR, etc.)
**Volumes:** Persistent data storage
**Networks:** Communication between containers
**Docker Compose:** Multi-container orchestration

---

## Section 2: Docker Commands

### 2.1 Image Management

```bash
# List images
docker images
docker image ls

# Pull an image
docker pull python:3.12-slim
docker pull postgres:15-alpine
docker pull nginx:alpine

# Build an image
docker build -t myapp:latest .
docker build -t myapp:1.0 -f Dockerfile.prod .

# Build with build args
docker build --build-arg ENV=production -t myapp:prod .

# Tag an image
docker tag myapp:latest myregistry/myapp:latest

# Push an image
docker push myregistry/myapp:latest

# Remove an image
docker rmi myapp:latest
docker image prune  # Remove unused images
docker image prune -a  # Remove all unused images

# Inspect an image
docker inspect myapp:latest
docker history myapp:latest
```

### 2.2 Container Management

```bash
# Run a container
docker run python:3.12-slim
docker run -d --name myapp -p 8000:8000 myapp:latest
docker run -it --rm python:3.12-slim /bin/bash

# Run with environment variables
docker run -e DATABASE_URL=postgresql://... -e DEBUG=False myapp:latest

# Run with mounts
docker run -v /host/path:/container/path myapp:latest
docker run -v my_volume:/app/data myapp:latest

# List containers
docker ps  # Running containers
docker ps -a  # All containers
docker ps -q  # Only container IDs

# Start/Stop/Restart
docker start container_name
docker stop container_name
docker restart container_name

# Remove containers
docker rm container_name
docker rm -f container_name  # Force remove
docker container prune  # Remove stopped containers

# Execute commands
docker exec -it container_name /bin/bash
docker exec container_name python manage.py migrate

# Logs
docker logs container_name
docker logs -f container_name  # Follow logs
docker logs --tail=100 container_name

# Inspect container
docker inspect container_name
docker stats container_name  # Resource usage
docker top container_name  # Processes
```

### 2.3 Volume Management

```bash
# List volumes
docker volume ls

# Create volume
docker volume create my_data

# Remove volume
docker volume rm my_data
docker volume prune  # Remove unused volumes

# Inspect volume
docker volume inspect my_data

# Use volume with container
docker run -v my_data:/app/data myapp:latest
docker run --mount type=volume,source=my_data,target=/app/data myapp:latest

# Use bind mount
docker run -v /host/path:/container/path myapp:latest
```

### 2.4 Network Management

```bash
# List networks
docker network ls

# Create network
docker network create my_network
docker network create --driver bridge my_network
docker network create --driver overlay my_network  # Swarm

# Connect/Disconnect
docker network connect my_network container_name
docker network disconnect my_network container_name

# Inspect network
docker network inspect my_network

# Remove network
docker network rm my_network
docker network prune

# Run with network
docker run --network my_network myapp:latest
docker run --network host myapp:latest  # Use host network
```

---

## Section 3: Dockerfile

### 3.1 Basic Dockerfile

```dockerfile
# Base image
FROM python:3.12-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create non-root user
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --gid 1001 appuser
USER appuser

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/health/ || exit 1

# Command
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "config.wsgi"]
```

### 3.2 Dockerfile Best Practices

```dockerfile
# 1. Use specific base image tags
FROM python:3.12-slim  # Good
# FROM python:latest  # Bad

# 2. Combine RUN commands
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*

# 3. Copy requirements first (better caching)
COPY requirements.txt .
RUN pip install -r requirements.txt

# 4. Use .dockerignore
# Create .dockerignore file

# 5. Multi-stage builds
FROM python:3.12-slim AS builder
# ... build steps ...

FROM python:3.12-slim
COPY --from=builder /app /app

# 6. Run as non-root
RUN adduser --system --uid 1001 appuser
USER appuser

# 7. Use health checks
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost/health/ || exit 1
```

### 3.3 .dockerignore

```dockerignore
# Python
__pycache__/
*.pyc
*.pyo
*.pyd
*.so
*.egg
*.egg-info
dist
build
.venv
venv/
env/

# Django
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal
/media/
/staticfiles/

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
*.swo
.DS_Store

# Docker
Dockerfile
.dockerignore
```

---

## Section 4: Docker Compose

### 4.1 Basic docker-compose.yml

```yaml
version: '3.8'

services:
  # Backend service
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

  # Nginx
  nginx:
    image: nginx:alpine
    container_name: taskflow-nginx
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./staticfiles:/static:ro
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - taskflow-network

networks:
  taskflow-network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
```

### 4.2 Docker Compose Commands

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

# Execute command
docker-compose exec backend bash
docker-compose exec db psql -U user -d db

# Build services
docker-compose build
docker-compose build --no-cache

# Pull images
docker-compose pull

# Restart services
docker-compose restart backend

# Check health
docker-compose ps --filter "health=healthy"

# Scale service
docker-compose up --scale backend=3 -d

# Use multiple compose files
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up
```

### 4.3 Environment Variables in Compose

```yaml
# docker-compose.yml
services:
  backend:
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - SECRET_KEY=${SECRET_KEY}
    env_file:
      - .env
      - .env.production
```

```bash
# .env file
DATABASE_URL=postgresql://user:pass@db:5432/db
SECRET_KEY=my-secret-key
```

---

## Section 5: Docker Best Practices

### 5.1 Image Optimization

```dockerfile
# 1. Use Alpine or slim images
FROM python:3.12-slim
# FROM python:3.12-alpine

# 2. Clean package manager cache
RUN apt-get update && apt-get install -y \
    package \
    && rm -rf /var/lib/apt/lists/*

# 3. Use multi-stage builds
FROM python:3.12-slim AS builder
# ... build ...

FROM python:3.12-slim
COPY --from=builder /app /app

# 4. Combine RUN commands
RUN apt-get update && \
    apt-get install -y package1 package2 && \
    rm -rf /var/lib/apt/lists/*

# 5. Use .dockerignore
# Prevents copying unnecessary files

# 6. Copy dependencies first (better caching)
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
```

### 5.2 Security Best Practices

```dockerfile
# 1. Run as non-root
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --gid 1001 appuser
USER appuser

# 2. Use specific base images
FROM python:3.12-slim

# 3. Don't expose unnecessary ports
EXPOSE 8000

# 4. Use health checks
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost/health/ || exit 1

# 5. Use secrets for sensitive data
# Don't use environment variables for secrets
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
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

---

## Section 6: Common Docker Commands Reference

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

---

## Quick Reference Cards

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

*This concludes Primer 4. You now have the essential Docker and containerization knowledge needed for the masterclass.*
