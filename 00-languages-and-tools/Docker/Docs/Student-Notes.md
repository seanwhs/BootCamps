# DOCKER MASTERY: CONTAINERIZE ANYTHING FROM ZERO TO PRODUCTION

## Student Notes – Complete Series

---

**Purpose:** These notes accompany the Docker Mastery series and the Student Workbook. Use them as a quick reference during and after the course. They contain key definitions, command summaries, and concept overviews in a condensed format.

**How to Use:**
- Follow along with the series
- Take additional notes in the margins
- Use as a quick reference when working with Docker
- Review before certification exams

---

---

# PART 0: INTRODUCTION

## Key Concepts

**Environment Drift:** The phenomenon where development, testing, and production environments differ, causing unexpected behavior.

**The Docker Promise:** "It works in my container" – consistent environments everywhere.

**Containers vs Virtual Machines:**

| Aspect | Virtual Machines | Containers |
|--------|------------------|------------|
| OS | Full guest OS | Shared kernel |
| Size | GBs | MBs |
| Boot Time | Minutes | Seconds |
| Isolation | Strong | Moderate |
| Resource Overhead | High | Low |

---

## Architecture You'll Build

**Final Stack:**
- Reverse Proxy (Nginx)
- Frontend (React/Vue.js)
- Backend API (Node/Python/Go)
- Database (PostgreSQL/MySQL)
- Named Volumes
- User-Defined Network
- CI/CD Pipeline
- Container Registry

---

## Series Roadmap

| Part | Topic | Key Outcome |
|------|-------|-------------|
| 0 | Introduction | Understand the journey |
| 1 | Core Foundation | Run containers |
| 2 | Custom Images | Build Dockerfiles |
| 3 | Persistence & Networking | Volumes & networks |
| 4 | Docker Compose | Multi-container apps |
| 5 | Production Readiness | Security & limits |
| 6 | Debugging & Operations | Troubleshoot |
| 7 | Security & Registries | Sign & scan |
| 8 | Orchestration | Swarm & K8s |

---

---

# PART 1: CORE FOUNDATION

## What is a Container?

**Definition:** A lightweight, standalone, executable package that includes everything needed to run software (code, runtime, system tools, libraries, settings).

**Mental Model:** A shipping container for software – standardized, portable, isolated.

---

## Containers vs VMs Visual

```
Virtual Machines:
┌─────────────────────────────────────┐
│ App A  │ App B  │ App C            │
│ Guest  │ Guest  │ Guest            │
│ OS     │ OS     │ OS               │
├────┬───┴────┬──┴────┬────────────────┤
│    │Hypervisor│     │                 │
├────┴─────────┴──────┴─────────────────┤
│         Hardware                      │
└─────────────────────────────────────┘

Containers:
┌─────────────────────────────────────┐
│ App A  │ App B  │ App C            │
│ Libs   │ Libs   │ Libs             │
├────┬───┴────┬──┴────┬────────────────┤
│    │Container Engine│                 │
├────┴─────────┴──────┴─────────────────┤
│         Host OS                       │
├─────────────────────────────────────┤
│         Hardware                      │
└─────────────────────────────────────┘
```

---

## How Containers Work

**Namespaces:** Provide isolated views of system resources.

| Namespace | What it Isolates |
|-----------|------------------|
| PID | Process IDs |
| NET | Network stack |
| MNT | Filesystem mounts |
| UTS | Hostname |
| IPC | Inter-process communication |
| USER | User/group IDs |
| CGROUP | Resource limits |

**Cgroups:** Limit and account for resource usage (CPU, memory, I/O).

---

## Docker Architecture

```
┌─────────────────────────────────────────────┐
│           Docker Client                     │
│         (docker command)                    │
└────────────────────┬────────────────────────┘
                     │ REST API
┌────────────────────▼────────────────────────┐
│           Docker Daemon (dockerd)           │
│         (Manages containers, images)        │
└────────────────────┬────────────────────────┘
                     │
┌────────────────────▼────────────────────────┐
│           containerd (Runtime)              │
│         (Container lifecycle)               │
└────────────────────┬────────────────────────┘
                     │
┌────────────────────▼────────────────────────┐
│           runc (Low-level)                  │
│         (Creates namespaces/cgroups)        │
└─────────────────────────────────────────────┘
```

---

## Images vs Containers

**Image:** Read-only template (blueprint)
**Container:** Running instance of an image

```
Image (Read-only layers):
┌─────────────────────────────┐
│ Layer: CMD ["python", ...]  │
├─────────────────────────────┤
│ Layer: COPY . /app          │
├─────────────────────────────┤
│ Layer: RUN pip install...   │
├─────────────────────────────┤
│ Layer: FROM python:3.11     │
└─────────────────────────────┘
        │
        ▼ (docker run)
┌─────────────────────────────┐
│ Container (writable layer)  │ ← Changes go here
├─────────────────────────────┤
│ Image layers (read-only)    │
└─────────────────────────────┘
```

---

## Essential Commands

**Run Containers:**
```bash
docker run -d --name web nginx:alpine   # Detached
docker run -it ubuntu:22.04 bash        # Interactive
docker run --rm -it python:3.11 bash    # Remove on exit
```

**Lifecycle:**
```bash
docker start web
docker stop web
docker pause web
docker restart web
docker rm web
docker rm -f web    # Force remove
```

**Inspect:**
```bash
docker ps -a
docker logs -f web
docker inspect web
docker stats web
docker top web
```

---

## Port Mapping

**Syntax:** `-p [host-port]:[container-port]`

```bash
# Map port 8080 on host to port 80 in container
docker run -p 8080:80 nginx

# Bind to specific host IP
docker run -p 127.0.0.1:8080:80 nginx

# UDP port
docker run -p 53:53/udp dns

# Multiple ports
docker run -p 8080:80 -p 8443:443 nginx
```

---

## Container Lifecycle

```
┌──────────┐
│ Created  │
└────┬─────┘
     │ docker start
     ▼
┌──────────┐
│ Running  │◄─────────┐
└────┬─────┘          │ docker unpause
     │ docker stop    │
     ▼                 │
┌──────────┐    ┌─────────────┐
│ Exited   │    │   Paused   │──┘
└────┬─────┘    └─────────────┘
     │ docker rm
     ▼
┌──────────┐
│ Removed  │
└──────────┘
```

---

---

# PART 2: CUSTOM IMAGES

## Dockerfile Directives

| Directive | Purpose | Example |
|-----------|---------|---------|
| FROM | Base image | `FROM python:3.11-slim` |
| WORKDIR | Working directory | `WORKDIR /app` |
| COPY | Copy files | `COPY . /app` |
| RUN | Execute commands | `RUN pip install -r requirements.txt` |
| CMD | Default command | `CMD ["python", "app.py"]` |
| ENTRYPOINT | Main executable | `ENTRYPOINT ["python"]` |
| ENV | Environment variables | `ENV NODE_ENV=production` |
| EXPOSE | Document ports | `EXPOSE 8000` |
| USER | Run as user | `USER appuser` |
| ARG | Build arguments | `ARG VERSION=latest` |
| LABEL | Metadata | `LABEL version="1.0"` |
| HEALTHCHECK | Health monitoring | `HEALTHCHECK CMD curl ...` |

---

## CMD vs ENTRYPOINT

| Configuration | Run Command | What Executes |
|---------------|-------------|---------------|
| `CMD ["app.py"]` | `docker run image` | `app.py` |
| `CMD ["app.py"]` | `docker run image test.py` | `test.py` (override) |
| `ENTRYPOINT ["python"]` | `docker run image` | `python` (no args) |
| `ENTRYPOINT ["python"]` | `docker run image app.py` | `python app.py` |
| `ENTRYPOINT ["python"]` `CMD ["app.py"]` | `docker run image` | `python app.py` |
| `ENTRYPOINT ["python"]` `CMD ["app.py"]` | `docker run image test.py` | `python test.py` |

**Best Practice:** Use `ENTRYPOINT` for main executable, `CMD` for default arguments.

---

## Multi-Stage Build Pattern

**Problem:** Build tools and dev dependencies in production images.

**Solution:** Separate build and runtime stages.

**Python Example:**
```dockerfile
# Stage 1: Builder
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["python", "app.py"]
```

**Benefits:**
- Smaller images
- Fewer vulnerabilities
- No build tools in production

---

## Build Cache Optimization

**Golden Rule:** Order from least-changing to most-changing.

```dockerfile
# ✅ Good (cached)
FROM python:3.11-slim
COPY requirements.txt .    # Changes rarely
RUN pip install -r requirements.txt  # Cached
COPY . .    # Changes frequently

# ❌ Bad (no cache)
FROM python:3.11-slim
COPY . .    # Changes every time
RUN pip install -r requirements.txt  # Re-runs every time
```

---

## .dockerignore

**Exclude unnecessary files from build context:**

```
# Version control
.git/
.gitignore

# Dependencies
node_modules/
__pycache__/

# Secrets
.env
*.key
*.pem

# Build outputs
dist/
build/
target/

# IDE
.vscode/
.idea/
*.swp
```

---

## Base Image Selection

| Image | Size | Use Case |
|-------|------|----------|
| Alpine | ~5MB | Minimal attack surface |
| Slim | ~50MB | Reduced attack surface |
| Full | ~500MB+ | Development |
| Distroless | ~20MB | Production (no package manager) |
| Scratch | ~0MB | Static binaries (Go) |

---

---

# PART 3: PERSISTENCE AND NETWORKING

## Storage Options Comparison

| Type | Managed By | Use Case | Persistence |
|------|------------|----------|-------------|
| Named Volume | Docker | Production data | Yes |
| Anonymous Volume | Docker | Temporary data | Yes |
| Bind Mount | User | Development | Yes |
| tmpfs | Docker (memory) | Caches, secrets | No (in-memory) |

---

## Volume Commands

```bash
# Create volume
docker volume create my-data

# Use volume
docker run -v my-data:/data postgres

# Inspect
docker volume inspect my-data

# List
docker volume ls

# Remove
docker volume rm my-data

# Clean up unused
docker volume prune
```

---

## Bind Mounts (Development)

```bash
# Mount current directory to /app
docker run -v $(pwd):/app node:18

# Mount specific host directory
docker run -v /host/path:/container/path nginx

# Mount with options
docker run -v /host/path:/container/path:ro  # Read-only
```

**Use Case:** Hot reload in development – edit code, see changes immediately.

---

## tmpfs Mounts (In-Memory)

```bash
# Mount tmpfs
docker run --tmpfs /tmp:rw,size=100M nginx

# With options
docker run --tmpfs /tmp:size=100M,mode=0700 nginx
```

---

## Network Drivers

| Driver | Description | Use Case |
|--------|-------------|----------|
| bridge | Default, isolated | Single-host apps |
| host | Host network | Performance-critical |
| none | No network | Maximum isolation |
| overlay | Multi-host | Swarm/Kubernetes |
| macvlan | MAC addresses | Legacy systems |

---

## User-Defined Bridge Networks

**Benefits over default bridge:**
- DNS resolution between containers
- Better isolation
- Containers reachable by name

```bash
# Create network
docker network create app-net

# Run containers on network
docker run --network app-net --name redis redis
docker run --network app-net --name api my-api

# Test connectivity by name
docker exec api ping redis  # Works!
```

---

## Network Commands

```bash
# Create network
docker network create app-net

# List networks
docker network ls

# Inspect
docker network inspect app-net

# Connect container
docker network connect app-net container1

# Disconnect container
docker network disconnect app-net container1

# Remove
docker network rm app-net
```

---

---

# PART 4: DOCKER COMPOSE

## Compose File Structure

```yaml
version: '3.8'

services:
  web:
    # Service configuration

  backend:
    # Service configuration

volumes:
  # Named volumes

networks:
  # Networks
```

---

## Key Service Options

| Option | Purpose | Example |
|--------|---------|---------|
| image | Use pre-built image | `image: nginx:alpine` |
| build | Build from Dockerfile | `build: ./backend` |
| ports | Port mapping | `ports: - "8080:80"` |
| volumes | Mount volumes | `volumes: - ./src:/app` |
| environment | Env variables | `environment: - NODE_ENV=prod` |
| env_file | Load env from file | `env_file: - .env` |
| depends_on | Dependencies | `depends_on: - db` |
| restart | Restart policy | `restart: unless-stopped` |
| networks | Networks to join | `networks: - app-net` |
| healthcheck | Health monitoring | `healthcheck: test: ...` |
| deploy | Resource limits | `deploy: resources: ...` |

---

## Essential Compose Commands

```bash
# Start in background
docker compose up -d

# Stop and remove
docker compose down -v

# List services
docker compose ps

# View logs
docker compose logs -f backend

# Execute command
docker compose exec backend bash

# Build services
docker compose build --no-cache

# Scale service
docker compose up -d --scale backend=3

# Pull latest images
docker compose pull

# Restart
docker compose restart
```

---

## Environment Variables

**.env file:**
```
NODE_ENV=production
DB_PASSWORD=secret
PORT=3000
```

**docker-compose.yml:**
```yaml
services:
  app:
    environment:
      - NODE_ENV=${NODE_ENV}
      - DB_PASSWORD=${DB_PASSWORD}
```

---

## Profiles

```yaml
services:
  app:
    profiles:
      - production
      - development

  adminer:
    profiles:
      - dev-tools    # Only starts with profile
```

```bash
# Run with profile
docker compose --profile dev-tools up -d
```

---

## Development vs Production

**Development:** Bind mounts, hot reload, debug tools
**Production:** Built images, no mounts (except volumes), security hardened

**Override Files:**
- `docker-compose.override.yml` (development, auto-loaded)
- `docker-compose.prod.yml` (production)
- `docker-compose.ci.yml` (CI/CD)

---

---

# PART 5: PRODUCTION READINESS

## Security Hardening Checklist

- [ ] Non-root user
- [ ] Read-only filesystem
- [ ] Drop unnecessary capabilities
- [ ] Seccomp profile
- [ ] No secrets in images
- [ ] Resource limits
- [ ] Health checks
- [ ] Minimal base image
- [ ] Vulnerability scanning

---

## Non-Root User (Dockerfile)

```dockerfile
FROM python:3.11-slim

# Create user
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

# Switch user
USER appuser
```

---

## Resource Limits

**Docker Run:**
```bash
docker run --memory=512M --cpus=1 --memory-swap=1G my-app
```

**Docker Compose:**
```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '1.5'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

**Ulimits:**
```yaml
services:
  app:
    ulimits:
      nofile:
        soft: 65536
        hard: 65536
```

---

## Health Checks

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/health"]
  interval: 30s
  timeout: 5s
  retries: 3
  start_period: 10s
```

**Common Health Check Types:**
- HTTP: `curl -f http://localhost/health`
- TCP: `pg_isready -U user`
- Command: `redis-cli ping`
- Script: `/usr/local/bin/health-check.sh`

---

## Logging

**12-Factor App:** Log to stdout/stderr

```python
import sys
import logging

logging.basicConfig(stream=sys.stdout)
logger = logging.getLogger(__name__)
```

**Log Configuration:**
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
    compress: "true"
```

**Structured Logging (JSON):**
```json
{"timestamp":"2024-01-15","level":"INFO","message":"Started"}
```

---

## Graceful Shutdown

**Signal Handling (Python):**
```python
import signal
import sys

def handle_sigterm(signum, frame):
    print("Shutting down gracefully...")
    # Cleanup
    sys.exit(0)

signal.signal(signal.SIGTERM, handle_sigterm)
```

**Docker Stop:**
```bash
# Send SIGTERM, wait 10s, then SIGKILL
docker stop container

# Custom timeout
docker stop -t 30 container
```

---

## CI/CD Pipeline (GitHub Actions)

```yaml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .
      
      - name: Security scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: myapp:${{ github.sha }}
      
      - name: Push to registry
        run: |
          docker tag myapp:${{ github.sha }} ghcr.io/user/myapp:latest
          docker push ghcr.io/user/myapp:latest
      
      - name: Deploy
        uses: appleboy/ssh-action@v0.1.5
        with:
          script: |
            docker compose pull
            docker compose up -d
```

---

---

# PART 6: DEBUGGING AND OPERATIONS

## Debugging Flow

```
1. docker ps -a          # Is container running?
2. docker logs           # What do the logs say?
3. docker inspect        # What's the container configuration?
4. docker exec           # Can I get inside?
5. docker stats          # What are the resources?
6. docker top            # What processes are running?
```

---

## Debugging Commands

**Status:**
```bash
docker ps -a
docker inspect container --format='{{.State.Status}}'
```

**Logs:**
```bash
docker logs -f --tail 100 container
docker logs --since 30m container
docker logs --timestamps container
```

**Inside Container:**
```bash
docker exec -it container /bin/bash
docker exec container ps aux
docker exec container env
docker exec container netstat -tulpn
docker exec container curl http://localhost/health
```

**Resources:**
```bash
docker stats --no-stream container
docker top container
docker system df
```

---

## Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| Container exits immediately | Main process exits | Check CMD/ENTRYPOINT, check logs |
| Port already allocated | Port in use | Find with `docker ps --filter publish=8080`, change port |
| Permission denied | User permissions | Run as non-root, check volume permissions |
| OOM Killed (137) | Out of memory | Increase memory limit with `docker update` |
| No such network | Network missing | `docker network create` |
| Image not found | Wrong tag/path | Check tag, pull image |
| Cannot connect to daemon | Docker not running | Start Docker service |

---

## Performance Optimization

**Image Size:**
- Multi-stage builds
- Slim/alpine base images
- Clean package manager caches
- .dockerignore
- Remove build tools

**Build Time:**
- Order layers for caching
- Use BuildKit: `DOCKER_BUILDKIT=1`
- Use cache mounts
- Parallel builds in CI

**Resource Usage:**
- Set CPU/memory limits
- Connection pooling
- Monitor with `docker stats`
- Use alpine images

---

## Daily Operations Checklist

**Morning:**
```bash
# Check containers
docker ps --format "table {{.Names}}\t{{.Status}}"

# Check resource usage
docker stats --no-stream

# Check for errors
docker ps -a | grep Exited

# Check disk usage
docker system df

# Check logs
docker ps -q | xargs -I {} docker logs --tail 10 {}
```

**Backup Volumes:**
```bash
docker run --rm \
  -v my-volume:/source \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup.tar.gz -C /source .
```

---

---

# PART 7: SECURITY AND REGISTRIES

## Image Signing (Cosign)

**Generate Keys:**
```bash
cosign generate-key-pair
```

**Sign Image:**
```bash
cosign sign --key cosign.key ghcr.io/user/app:v1.0.0
```

**Verify:**
```bash
cosign verify --key cosign.pub ghcr.io/user/app:v1.0.0
```

**In CI/CD:**
```yaml
cosign sign --key env://COSIGN_PRIVATE_KEY ghcr.io/user/app:${{ github.sha }}
```

---

## SBOM (Software Bill of Materials)

**Generate SBOM:**
```bash
syft image:latest -o spdx-json > sbom.json
```

**Why SBOM Matters:**
- Know what's in your images
- Compliance requirements
- Vulnerability tracking
- Supply chain security

---

## Secrets Management

| Method | Use Case | Security |
|--------|----------|----------|
| Environment Variables | Non-sensitive config | Low |
| Secret Files | Development | Medium |
| Docker Secrets | Swarm mode | High |
| HashiCorp Vault | Enterprise | Very High |
| AWS Secrets Manager | Cloud | High |

**Docker Secrets (Swarm):**
```yaml
secrets:
  db_password:
    file: ./secrets/db_password.txt

services:
  app:
    secrets:
      - db_password
```

---

## Registry Selection

| Registry | Best For |
|----------|----------|
| Docker Hub | Public images, official images |
| GHCR | GitHub integration |
| AWS ECR | AWS deployments |
| Google AR | GCP deployments |
| Azure CR | Azure deployments |
| Harbor | Self-hosted |
| JFrog | Enterprise artifact management |

---

## Tagging Strategy

```
v1.0.0          # Semantic version
v1.0.0-alpha.1  # Pre-release
latest          # Latest stable (use carefully)
stable          # Stable version
staging         # Staging environment
production      # Production environment
main-abc123     # Branch + commit SHA
pr-42           # Pull request
2024-01-15      # Date
```

---

## Vulnerability Scanning

| Tool | Command | Features |
|------|---------|----------|
| Trivy | `trivy image image:tag` | Comprehensive, fast |
| Grype | `grype image:tag` | SBOM-focused |
| Docker Scout | `docker scout cves image:tag` | Built-in |
| Clair | `clair-scanner` | Registry integration |

**In CI:**
```yaml
trivy image --severity HIGH,CRITICAL --exit-code 1 image:tag
grype --fail-on high image:tag
```

---

---

# PART 8: ORCHESTRATION

## Why Orchestration?

| Challenge | Solution |
|-----------|----------|
| Scaling | Run on multiple nodes |
| High Availability | Automatic failover |
| Zero-Downtime Deployments | Rolling updates |
| Self-Healing | Restart failed containers |
| Resource Optimization | Efficient scheduling |

**Pets vs Cattle:**
- Pets: Named, nurtured, replaced with care
- Cattle: Numbered, replaced when sick

**Containers should be cattle.**

---

## Docker Swarm

**Initialize:**
```bash
docker swarm init --advertise-addr 192.168.1.100
```

**Join:**
```bash
docker swarm join --token SWMTKN-... 192.168.1.100:2377
```

**Service:**
```bash
docker service create --name web --replicas 3 --publish 8080:80 nginx
```

**Manage:**
```bash
docker service scale web=5
docker service update --image nginx:1.25 web
docker service rollback web
docker service rm web
```

**Stack:**
```bash
docker stack deploy -c docker-compose.swarm.yml myapp
docker stack services myapp
docker stack ps myapp
docker stack rm myapp
```

---

## Kubernetes Concepts

| Docker Concept | Kubernetes Equivalent |
|----------------|----------------------|
| Container | Pod (one or more containers) |
| Image | Image (same) |
| Volume | PersistentVolume |
| Network | Service, Ingress |
| docker run | kubectl run |
| docker-compose.yml | Deployment + Service |
| Port mapping | NodePort/LoadBalancer |
| Health check | Liveness/Readiness Probe |

---

## When to Use What

| Factor | Docker Swarm | Kubernetes |
|--------|--------------|------------|
| Complexity | Low | High |
| Learning Curve | Easy | Steep |
| Features | Basic | Extensive |
| Community | Small | Huge |
| Cloud Support | Limited | All major |
| Use Case | Small teams, simple apps | Enterprise, complex apps |

**Start with Swarm, move to Kubernetes as needs grow.**

---

## Kubernetes Commands

```bash
# Apply configuration
kubectl apply -f deployment.yaml

# Get resources
kubectl get pods
kubectl get services
kubectl get deployments

# Scale
kubectl scale deployment app --replicas=5

# Update image
kubectl set image deployment/app app=image:v2

# Rollout status
kubectl rollout status deployment/app

# Rollback
kubectl rollout undo deployment/app

# Logs
kubectl logs pod-name

# Execute
kubectl exec -it pod-name -- bash

# Delete
kubectl delete -f deployment.yaml
```

---

---

# APPENDICES SUMMARY

## Appendix A: Command Reference

**Containers:**
```bash
docker run, start, stop, restart, pause, unpause, kill, rm
docker ps, logs, inspect, stats, top, exec, cp
```

**Images:**
```bash
docker build, pull, push, tag, images, rmi, history
```

**Volumes:**
```bash
docker volume create, ls, inspect, rm, prune
```

**Networks:**
```bash
docker network create, ls, inspect, connect, disconnect, rm
```

**Compose:**
```bash
docker compose up, down, ps, logs, exec, build, pull, restart, scale
```

**System:**
```bash
docker system df, prune, info, version
```

---

## Appendix B: Dockerfile Reference

| Instruction | Syntax |
|-------------|--------|
| FROM | `FROM image:tag` |
| WORKDIR | `WORKDIR /path` |
| COPY | `COPY source destination` |
| ADD | `ADD source destination` |
| RUN | `RUN command` |
| CMD | `CMD ["executable", "args"]` |
| ENTRYPOINT | `ENTRYPOINT ["executable"]` |
| ENV | `ENV key=value` |
| EXPOSE | `EXPOSE port` |
| USER | `USER username` |
| ARG | `ARG name=default` |
| LABEL | `LABEL key=value` |
| HEALTHCHECK | `HEALTHCHECK CMD command` |

---

## Appendix C: Compose Reference

| Key | Purpose |
|-----|---------|
| image | Pre-built image |
| build | Build context |
| ports | Port mapping |
| volumes | Volume mounts |
| environment | Env variables |
| env_file | Env from file |
| depends_on | Dependencies |
| restart | Restart policy |
| networks | Networks |
| healthcheck | Health monitoring |
| deploy | Resource limits |

---

## Appendix D: Common Errors

| Error | Quick Fix |
|-------|-----------|
| Port already allocated | `docker ps --filter publish=PORT` |
| Container exits immediately | Check logs, CMD/ENTRYPOINT |
| Permission denied | Check user, volume permissions |
| OOM Killed | Increase memory limit |
| No such network | `docker network create` |
| Image not found | Pull image, check tag |
| Cannot connect to daemon | Start Docker service |

---

## Appendix E: Glossary

| Term | Definition |
|------|------------|
| Container | Lightweight, standalone executable package |
| Image | Read-only template for containers |
| Dockerfile | Text file with build instructions |
| Volume | Persistent data storage |
| Bind Mount | Host directory mounted in container |
| Bridge Network | Default Docker network |
| Orchestration | Automated container management |
| Registry | Storage for images |
| Multi-stage Build | Separate build and runtime stages |
| Health Check | Container health monitoring |
| Seccomp | System call filtering |
| Capabilities | Fine-grained permissions |
| SBOM | Software Bill of Materials |
| Namespace | Resource isolation |
| Cgroup | Resource limiting |

---

# QUICK REFERENCE CARDS

## Card 1: Docker Run Flags

```
-d          Detached mode
-it         Interactive terminal
--rm        Remove on exit
--name      Container name
-p          Port mapping
-v          Volume mount
-e          Environment variable
--env-file  Environment file
--network   Network
--user      User (UID:GID)
--memory    Memory limit
--cpus      CPU limit
--restart   Restart policy
--read-only Read-only filesystem
--cap-add   Add capability
--cap-drop  Drop capability
--security-opt Security options
```

---

## Card 2: Compose File Skeleton

```yaml
version: '3.8'

services:
  service1:
    image: image:tag
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:80"
    volumes:
      - ./src:/app
    environment:
      - ENV=value
    env_file:
      - .env
    depends_on:
      - service2
    restart: unless-stopped
    networks:
      - net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 5s
      retries: 3
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1'

volumes:
  data:

networks:
  net:
    driver: bridge
```

---

## Card 3: Debugging Quick Flow

```
1. docker ps -a
2. docker logs --tail 50 container
3. docker inspect container
4. docker exec -it container /bin/bash
5. docker stats container
6. docker top container
7. docker system df
```

---

## Card 4: Security Quick Checklist

```
☐ Non-root user (USER in Dockerfile)
☐ Read-only filesystem (--read-only)
☐ Capabilities dropped (--cap-drop=ALL)
☐ Seccomp profile (--security-opt seccomp=default.json)
☐ Resource limits (--memory, --cpus)
☐ Health check (HEALTHCHECK)
☐ Minimal base image (slim/alpine)
☐ No secrets in image
☐ Vulnerability scanned (trivy/grype)
☐ Image signed (cosign)
☐ SBOM generated (syft)
```

---

**End of Student Notes**

---
