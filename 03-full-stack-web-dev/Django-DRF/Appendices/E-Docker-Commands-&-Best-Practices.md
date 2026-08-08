# Appendix E: Docker Commands & Best Practices

## Complete Docker Reference Guide

Welcome to **Appendix E** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive reference for Docker commands, best practices, and troubleshooting techniques used throughout the masterclass.

---

## Section 1: Docker Commands Reference

### 1.1 Container Management

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# List containers with more details
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Start a container
docker start container_name

# Stop a container
docker stop container_name

# Stop all running containers
docker stop $(docker ps -q)

# Restart a container
docker restart container_name

# Remove a container
docker rm container_name

# Remove all stopped containers
docker container prune

# Remove all containers (including running with -f)
docker rm -f $(docker ps -aq)

# Execute command in a running container
docker exec -it container_name bash
docker exec -it container_name python manage.py shell

# Copy files to/from container
docker cp local_file.txt container_name:/path/
docker cp container_name:/path/file.txt local_file.txt
```

### 1.2 Image Management

```bash
# List images
docker images

# List images with details
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Build an image
docker build -t image_name:tag .

# Build with specific Dockerfile
docker build -f Dockerfile.dev -t image_name:dev .

# Build with build arguments
docker build --build-arg ENVIRONMENT=production -t image_name:prod .

# Remove an image
docker rmi image_name:tag

# Remove all unused images
docker image prune

# Remove all images
docker rmi -f $(docker images -q)

# Tag an image for registry
docker tag source_image:tag registry.example.com/image:tag

# Push image to registry
docker push registry.example.com/image:tag

# Pull image from registry
docker pull registry.example.com/image:tag

# Inspect image layers
docker history image_name:tag
```

### 1.3 Image Optimization Commands

```bash
# View image size breakdown
docker system df

# Analyze image size
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive image_name:tag

# Remove unused build cache
docker builder prune

# Remove all unused data
docker system prune -a

# Check image vulnerabilities
docker scan image_name:tag

# Export image to tar file
docker save -o image.tar image_name:tag

# Import image from tar file
docker load -i image.tar
```

### 1.4 Network Commands

```bash
# List networks
docker network ls

# Create a network
docker network create network_name

# Inspect a network
docker network inspect network_name

# Connect a container to a network
docker network connect network_name container_name

# Disconnect a container from a network
docker network disconnect network_name container_name

# Remove a network
docker network rm network_name

# View network details
docker network inspect bridge
```

### 1.5 Volume Commands

```bash
# List volumes
docker volume ls

# Create a volume
docker volume create volume_name

# Inspect a volume
docker volume inspect volume_name

# Remove a volume
docker volume rm volume_name

# Remove all unused volumes
docker volume prune

# Run a container with a volume
docker run -v volume_name:/container/path image_name
docker run --mount type=volume,source=volume_name,target=/container/path image_name

# Mount local directory
docker run -v $(pwd)/local_path:/container/path image_name
```

### 1.6 Logging Commands

```bash
# Show logs
docker logs container_name

# Show last N lines
docker logs --tail=100 container_name

# Follow logs in real-time
docker logs -f container_name

# Show logs with timestamps
docker logs -t container_name

# Show logs since a specific time
docker logs --since=2026-01-15T12:00:00 container_name

# Show logs with details
docker logs --details container_name

# Combine with grep
docker logs container_name | grep ERROR
```

### 1.7 Docker Compose Commands

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

# Execute command in a service
docker-compose exec backend bash
docker-compose exec db psql -U taskflow_user taskflow_db

# Build services
docker-compose build
docker-compose build --no-cache

# Pull latest images
docker-compose pull

# Restart service
docker-compose restart backend

# Stop a single service
docker-compose stop backend

# Remove containers
docker-compose rm

# Run a one-off command
docker-compose run backend python manage.py migrate

# Use multiple compose files
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up

# Scale a service
docker-compose up --scale backend=3 -d

# Check health status
docker-compose ps --filter "health=healthy"
```

---

## Section 2: Dockerfile Best Practices

### 2.1 Base Image Selection

```dockerfile
# ✅ Good: Use specific version
FROM python:3.12-slim

# ❌ Bad: Use 'latest' tag
FROM python:latest

# ✅ Good: Use Alpine for small images (with caution)
FROM python:3.12-alpine

# ✅ Good: Multi-stage builds
FROM python:3.12-slim AS builder
# ... build steps ...
FROM python:3.12-slim
# ... copy only artifacts ...
```

### 2.2 Layer Optimization

```dockerfile
# ✅ Good: Combine RUN commands
RUN apt-get update && apt-get install -y \
    package1 \
    package2 \
    && rm -rf /var/lib/apt/lists/*

# ❌ Bad: Separate RUN commands
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get install -y package2

# ✅ Good: Copy requirements first (caching)
COPY requirements.txt .
RUN pip install -r requirements.txt

# ❌ Bad: Copy everything first
COPY . .
RUN pip install -r requirements.txt

# ✅ Good: Use .dockerignore
# .dockerignore file prevents unnecessary files from being copied
```

### 2.3 Security Best Practices

```dockerfile
# ✅ Good: Run as non-root user
RUN addgroup --system --gid 1001 appuser && \
    adduser --system --uid 1001 --gid 1001 appuser
USER appuser

# ❌ Bad: Run as root
USER root

# ✅ Good: Use specific versions for packages
RUN pip install django==6.0.0

# ❌ Bad: Use latest version
RUN pip install django

# ✅ Good: Don't expose unnecessary ports
EXPOSE 8000

# ❌ Bad: Expose multiple ports
EXPOSE 8000 8001 8002

# ✅ Good: Use health checks
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/health/ || exit 1
```

### 2.4 Performance Optimization

```dockerfile
# ✅ Good: Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# ✅ Good: Use --no-cache-dir with pip
RUN pip install --no-cache-dir -r requirements.txt

# ✅ Good: Mount volumes for development
# Don't copy source for development, mount it instead
docker run -v $(pwd):/app image_name

# ✅ Good: Use Docker build cache
COPY requirements/base.txt requirements/base.txt
RUN pip install -r requirements/base.txt
COPY . .
```

---

## Section 3: Docker Compose Best Practices

### 3.1 Service Dependencies

```yaml
# ✅ Good: Use health checks
services:
  db:
    image: postgres:15
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user"]
      interval: 10s
      timeout: 5s
      retries: 5

  backend:
    depends_on:
      db:
        condition: service_healthy
    # ❌ Bad: depends_on: [db]
```

### 3.2 Environment Variables

```yaml
# ✅ Good: Use env_file
services:
  backend:
    env_file:
      - .env
      - .env.production

# ✅ Good: Use environment with secrets
services:
  backend:
    environment:
      - DATABASE_URL=${DB_URL}
      - SECRET_KEY=${SECRET_KEY}

# ❌ Bad: Hardcode values
services:
  backend:
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/db
      - SECRET_KEY=mysecretkey
```

### 3.3 Resource Limits

```yaml
# ✅ Good: Set resource limits
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 512M

  # ✅ Good: Set restart policies
  services:
    backend:
      restart: unless-stopped
```

---

## Section 4: Docker Troubleshooting Guide

### 4.1 Common Issues and Solutions

**Issue: Container won't start**

```bash
# Check logs
docker logs container_name

# Check if container exists
docker ps -a

# Check image
docker inspect container_name

# Common causes:
# - Port conflict
# - Missing environment variables
# - Volume permission issues
# - Command not found
```

**Issue: "Port already in use"**

```bash
# Find process using port
sudo lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Kill process
kill -9 PID  # macOS/Linux
taskkill /PID PID /F  # Windows

# Use different port
docker run -p 8001:8000 image_name
```

**Issue: "Permission denied"**

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes
newgrp docker

# Or use sudo
sudo docker run image_name

# For volume permissions
docker run -u $(id -u):$(id -g) -v $(pwd):/app image_name
```

**Issue: "No space left on device"**

```bash
# Clean unused resources
docker system prune -a

# Clean volumes
docker volume prune

# Check disk usage
docker system df

# Remove large images
docker images --filter "size>100M"
docker rmi image_id
```

**Issue: "Network timeouts"**

```bash
# Check network connectivity
docker run --rm alpine ping -c 4 google.com

# Check DNS
docker run --rm alpine nslookup google.com

# Use host network mode
docker run --network host image_name

# Configure DNS in daemon.json
{
  "dns": ["8.8.8.8", "8.8.4.4"]
}
```

---

## Section 5: Docker Security Checklist

### 5.1 Image Security

- [ ] Use official/base images when possible
- [ ] Use specific tags, not `latest`
- [ ] Regularly update base images
- [ ] Scan images for vulnerabilities (`docker scan`)
- [ ] Use minimal base images (`-slim`, `-alpine`)
- [ ] Remove unnecessary packages
- [ ] Use multi-stage builds
- [ ] Don't store secrets in images

### 5.2 Runtime Security

- [ ] Run as non-root user
- [ ] Use read-only filesystem when possible
- [ ] Drop unnecessary capabilities
- [ ] Set resource limits
- [ ] Use AppArmor or SELinux
- [ ] Enable Docker content trust
- [ ] Use Docker secrets for sensitive data
- [ ] Configure logging for security events

### 5.3 Network Security

- [ ] Use internal networks for backend services
- [ ] Limit exposed ports
- [ ] Use HTTPS for exposed services
- [ ] Configure firewall rules
- [ ] Use TLS for container-to-container communication
- [ ] Implement rate limiting at proxy level
- [ ] Use secure ciphers for SSL/TLS

---

## Section 6: Production Docker Best Practices

### 6.1 Image Optimization

```dockerfile
# Multi-stage build for production
FROM python:3.12-slim AS builder
COPY requirements.txt .
RUN pip install --user -r requirements.txt

FROM python:3.12-slim
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["gunicorn", "config.wsgi"]
```

### 6.2 Logging Configuration

```yaml
# docker-compose.prod.yml
services:
  backend:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"

  nginx:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "5"
```

### 6.3 Health Checks

```dockerfile
# Dockerfile
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/health/ || exit 1
```

```yaml
# docker-compose.yml
services:
  backend:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### 6.4 Graceful Shutdown

```python
# Django configuration for graceful shutdown
import signal
import sys

def signal_handler(sig, frame):
    print('Shutting down gracefully...')
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)
```

---

## Section 7: Docker Monitoring Commands

```bash
# Container metrics
docker stats
docker stats --no-stream

# System information
docker info
docker system df

# Container details
docker inspect container_name

# Resource usage per container
docker ps -q | xargs docker stats --no-stream

# Log size per container
docker ps -q | xargs -I {} sh -c 'echo {}: $(docker logs {} 2>&1 | wc -l)'

# Check disk usage
docker system df -v

# Monitor events
docker events
docker events --filter event=start
docker events --filter container=container_name

# Health status
docker ps --filter "health=healthy"
docker ps --filter "health=unhealthy"
```

---

## Quick Reference Card

### Dockerfile Instructions

| Instruction | Purpose |
|-------------|---------|
| `FROM` | Base image |
| `RUN` | Execute commands |
| `COPY` | Copy files |
| `ADD` | Copy with features |
| `WORKDIR` | Set working directory |
| `ENV` | Set environment variables |
| `EXPOSE` | Document ports |
| `CMD` | Default command |
| `ENTRYPOINT` | Main command |
| `USER` | Set user |
| `VOLUME` | Mount point |
| `LABEL` | Metadata |
| `HEALTHCHECK` | Health check |

### Docker Run Arguments

| Argument | Purpose |
|----------|---------|
| `-d` | Run in background |
| `-it` | Interactive terminal |
| `--name` | Container name |
| `-p` | Port mapping |
| `-v` | Volume mount |
| `-e` | Environment variable |
| `--rm` | Remove after exit |
| `--network` | Network |
| `--restart` | Restart policy |
| `--health-*` | Health check options |

---

*This concludes Appendix E. This Docker reference will help you manage and troubleshoot your containerized applications.*
