# Part 2 – Crafting Custom, Production-Friendly Images

Now that you understand containers from the outside, it's time to build your own. In this part, you'll learn how to create Docker images that are secure, efficient, and production-ready. We'll start with a naive approach that creates massive images, then iteratively refactor until we have lean, professional-grade containers.

## 2.1 The Journey from Naive to Production-Ready

Let's see how a typical Dockerfile evolves from "works on my machine" to "production-grade."

**The Naive Image (1GB+)**
```
FROM ubuntu:latest
RUN apt-get update && apt-get install -y python3 python3-pip
COPY . /app
RUN pip3 install -r requirements.txt
CMD ["python3", "app.py"]
```

**The Production Image (<100MB)**
```
FROM python:3.11-slim AS builder
COPY requirements.txt .
RUN pip install --user -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
EXPOSE 8000
CMD ["python", "app.py"]
```

By the end of this part, you'll understand every line of that production Dockerfile and why it's superior.

## 2.2 Dockerfile Fundamentals

### What is a Dockerfile?

A **Dockerfile** is a text document that contains all the commands a user could call on the command line to assemble an image. It's the recipe for your container.

### Key Directives

Let's explore each important directive with examples.

#### `FROM` – The Foundation

Every Dockerfile starts with `FROM`, which specifies the base image.

```dockerfile
# Official image from Docker Hub
FROM ubuntu:22.04

# Alpine variant (much smaller)
FROM alpine:3.18

# Specific version
FROM python:3.11-slim

# Scratch (empty image for truly minimal containers)
FROM scratch
```

**Why base image matters:**
- **Size:** Alpine is ~5MB, Ubuntu is ~77MB
- **Security:** Slim variants have fewer vulnerabilities
- **Compatibility:** Some apps need specific system libraries

#### `WORKDIR` – Setting the Workspace

Sets the working directory for any `RUN`, `CMD`, `ENTRYPOINT`, `COPY`, and `ADD` instructions.

```dockerfile
WORKDIR /app
```

**Best Practice:** Use `WORKDIR` instead of `RUN mkdir` and `cd`. It's cleaner and more maintainable.

```dockerfile
# Good
WORKDIR /app
COPY . .

# Bad (don't do this)
RUN mkdir /app && cd /app
COPY . /app
```

#### `COPY` vs `ADD`

Both copy files from the build context into the image.

**COPY:** Simple, straightforward file/directory copying.
```dockerfile
COPY package.json /app/
COPY . /app/
```

**ADD:** Same as COPY but with additional features:
- Can handle remote URLs
- Can auto-extract tar files

```dockerfile
# Download from URL
ADD https://example.com/file.tar.gz /tmp/

# Auto-extract tar
ADD file.tar.gz /app/
```

**Best Practice:** Use `COPY` unless you specifically need `ADD`'s extra features. `COPY` is more predictable.

#### `RUN` – Executing Commands

Executes commands in a new layer on top of the current image.

```dockerfile
# Single command
RUN apt-get update

# Multiple commands (use && to chain)
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*
```

**Important Layer Caching Rule:** Each `RUN` creates a new layer. Order matters for caching.

```dockerfile
# ❌ Inefficient – cache invalidated on every code change
COPY . /app
RUN apt-get update && apt-get install -y python3

# ✅ Efficient – dependencies installed before copying app code
RUN apt-get update && apt-get install -y python3
COPY . /app
```

#### `CMD` vs `ENTRYPOINT`

These are often confused. Here's the distinction:

**CMD:** Provides defaults for an executing container. Can be overridden.
```dockerfile
CMD ["python", "app.py"]
# Override: docker run image python app2.py
```

**ENTRYPOINT:** Configures a container that will run as an executable. Cannot be overridden (but can have appended arguments).
```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
# Override: docker run image app2.py
```

**Best Practice:** Use `ENTRYPOINT` for the main executable and `CMD` for default arguments.

```dockerfile
# Good pattern
ENTRYPOINT ["python"]
CMD ["app.py"]

# Also good (for CLI tools)
ENTRYPOINT ["/bin/bash"]
CMD ["-c", "echo Hello"]
```

#### `ENV` – Setting Environment Variables

Sets environment variables that persist in the container.

```dockerfile
ENV APP_HOME=/app
ENV PYTHONPATH=${APP_HOME}
ENV PORT=8000
```

**During build time:**
```dockerfile
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update  # Won't prompt for user input
```

**During runtime:**
```bash
docker run -e PORT=9000 image-name
```

#### `EXPOSE` – Documenting Ports

Documents which ports the container listens on. Note: this is informational – it doesn't actually publish the port.

```dockerfile
EXPOSE 8000
EXPOSE 443/tcp
EXPOSE 53/udp
```

#### `ARG` – Build-Time Variables

Defines variables that can be passed at build time.

```dockerfile
ARG VERSION=latest
FROM node:${VERSION}
```

```bash
docker build --build-arg VERSION=18-alpine -t my-app .
```

#### `LABEL` – Adding Metadata

Adds metadata to an image.

```dockerfile
LABEL maintainer="dev@example.com"
LABEL version="1.0"
LABEL description="My awesome application"
```

#### `USER` – Setting the User

Changes the user for `RUN`, `CMD`, and `ENTRYPOINT`.

```dockerfile
# Create a non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

**Security Best Practice:** Always run containers as a non-root user in production.

## 2.3 The Build Cache: Your Best Friend

Docker builds images layer by layer. If a layer hasn't changed, Docker reuses it from the cache. This dramatically speeds up builds.

### How the Cache Works

```
Layer 1: FROM node:18     ← Cache hit (same as before)
Layer 2: WORKDIR /app      ← Cache hit
Layer 3: COPY package.json ← Cache hit (file unchanged)
Layer 4: RUN npm install   ← Cache hit (dependencies unchanged)
Layer 5: COPY . .          ← Cache miss (source changed)
Layer 6: RUN npm run build ← Cache miss (new layer)
```

### Optimizing for Cache

**The Golden Rule:** Order your Dockerfile from least-changing to most-changing.

```dockerfile
# ❌ Bad caching
COPY . .                     # Changes on every file edit
RUN npm install             # Re-runs on every build

# ✅ Good caching
COPY package.json package-lock.json . # Changes rarely
RUN npm install              # Reuses cache
COPY . .                     # Changes frequently
```

### Example: Node.js Application

Let's see the caching strategy in action:

```dockerfile
# Base image
FROM node:18-alpine AS builder

# Install dependencies first (changes infrequently)
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Copy source (changes frequently)
COPY . .

# Build step
RUN npm run build

# Final stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["node", "dist/server.js"]
```

## 2.4 Multi-Stage Builds: The Game Changer

Multi-stage builds are the single most important technique for creating production-ready images. They let you:
- Use full development tools in build stages
- Copy only the final artifacts into the runtime stage
- Dramatically reduce image size
- Keep build secrets out of the final image

### The Problem Without Multi-Stage

```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

**Problems:**
- Includes `node_modules` with dev dependencies
- Includes source code (unnecessary for production)
- Build tools are in the final image
- Size: ~900MB

### The Solution: Multi-Stage

```dockerfile
# Stage 1: Build
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Production
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
RUN npm ci --only=production
CMD ["node", "dist/server.js"]
```

**Benefits:**
- Dev dependencies not included
- Build tools removed
- Only production assets remain
- Size: ~150MB

### Python Example Without Multi-Stage

```dockerfile
FROM python:3.11
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["python", "app.py"]
```
Size: ~1.2GB (includes Python build tools, test files, etc.)

### Python Example With Multi-Stage

```dockerfile
# Builder stage
FROM python:3.11-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends gcc build-essential
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Runtime stage
FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
EXPOSE 8000
CMD ["python", "app.py"]
```
Size: ~150MB (dramatic reduction!)

### Even Better: Alpine-Based

```dockerfile
FROM python:3.11-alpine AS builder
WORKDIR /app
RUN apk add --no-cache gcc musl-dev
COPY requirements.txt .
RUN pip install --user -r requirements.txt

FROM python:3.11-alpine
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
CMD ["python", "app.py"]
```
Size: ~80MB

## 2.5 Creating Your First Dockerfile: A Web Application

Now let's build something real. We'll create a simple web application and containerize it.

### Project Structure

Create this directory structure:

```
my-first-app/
├── app.py
├── requirements.txt
├── Dockerfile
├── .dockerignore
└── README.md
```

### Step 1: The Application Code

**`app.py`**
```python
#!/usr/bin/env python3
"""
A simple web application for learning Docker.
"""
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class HealthHandler(BaseHTTPRequestHandler):
    """HTTP request handler for our application."""
    
    def do_GET(self):
        """Handle GET requests."""
        parsed_path = self.path
        
        if parsed_path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            self.wfile.write(b'<h1>Hello from Docker!</h1><p>This app is running in a container.</p>')
            logger.info('Served index page')
            
        elif parsed_path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            health_data = {
                'status': 'healthy',
                'container': os.getenv('HOSTNAME', 'unknown'),
                'app_version': '1.0.0'
            }
            self.wfile.write(json.dumps(health_data).encode())
            logger.info('Health check requested')
            
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'404 Not Found')
            logger.warning(f'404 for path: {parsed_path}')
    
    def log_message(self, format, *args):
        """Override to use our logger."""
        logger.info(f'Request: {format % args}')

def run_server(port=8000):
    """Start the HTTP server."""
    server_address = ('', port)
    httpd = HTTPServer(server_address, HealthHandler)
    logger.info(f'Starting server on port {port}...')
    logger.info(f'Health check: http://localhost:{port}/health')
    logger.info(f'Index: http://localhost:{port}/')
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        logger.info('Shutting down server...')
        httpd.shutdown()

if __name__ == '__main__':
    port = int(os.getenv('PORT', 8000))
    run_server(port)
```

**`requirements.txt`**
```
# No external dependencies for this simple app
# We'll keep it minimal
```

### Step 2: The Naive Dockerfile

**`Dockerfile` (naive version)**
```dockerfile
# Naive Dockerfile - we'll refactor this!
FROM python:3.11

# Set working directory
WORKDIR /app

# Copy application code
COPY app.py .
COPY requirements.txt .

# Install dependencies
RUN pip install -r requirements.txt

# Expose the port
EXPOSE 8000

# Run the application
CMD ["python", "app.py"]
```

### Step 3: Build and Run

```bash
# Build the naive image
docker build -t my-app-naive:1.0 .

# Check the size
docker images my-app-naive:1.0
```
```
REPOSITORY       TAG       IMAGE ID       CREATED         SIZE
my-app-naive     1.0       abc123def456   2 minutes ago   1.02GB
```

```bash
# Run it
docker run -d --name naive-app -p 8000:8000 my-app-naive:1.0

# Test it
curl http://localhost:8000/health
```
```json
{"status": "healthy", "container": "abc123def456", "app_version": "1.0.0"}
```

```bash
# Check logs
docker logs naive-app
```

```bash
# Clean up
docker stop naive-app
docker rm naive-app
```

## 2.6 Refactoring the Dockerfile

Now let's transform our naive Dockerfile into a production-ready one.

### Step 1: Add `.dockerignore`

Before we refactor, create a `.dockerignore` file to exclude unnecessary files.

**`.dockerignore`**
```
# Version control
.git/
.gitignore

# Python cache
__pycache__/
*.pyc
*.pyo
*.pyd

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Logs
*.log

# Documentation
README.md

# Docker files
Dockerfile*
.dockerignore

# Test files
tests/
test_*.py
```

### Step 2: Optimize for Caching

**`Dockerfile` (optimized for caching)**
```dockerfile
# Optimized Dockerfile with better layer ordering
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies first (changes less often)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code (changes often)
COPY app.py .

# Create a non-root user for security
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

# Switch to non-root user
USER appuser

# Expose the port
EXPOSE 8000

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Run the application
CMD ["python", "app.py"]
```

```bash
# Build the optimized image
docker build -t my-app-cached:1.0 .

# Check the size (now using slim base)
docker images my-app-cached:1.0
```
```
REPOSITORY       TAG       IMAGE ID       CREATED         SIZE
my-app-cached    1.0       def456abc789   2 minutes ago   118MB  # Much smaller!
```

### Step 3: Multi-Stage Build

Now for the ultimate optimization:

**`Dockerfile` (multi-stage production)**
```dockerfile
# ============================================================
# Stage 1: Builder
# ============================================================
FROM python:3.11-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy and install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# ============================================================
# Stage 2: Runtime
# ============================================================
FROM python:3.11-slim

# Install runtime dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser

WORKDIR /app

# Copy dependencies from builder stage
COPY --from=builder /root/.local /root/.local

# Copy application code
COPY app.py .

# Set PATH so Python finds user-installed packages
ENV PATH=/root/.local/bin:$PATH

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Switch to non-root user
USER appuser

# Expose the port
EXPOSE 8000

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# Run the application
CMD ["python", "app.py"]
```

```bash
# Build the production image
docker build -t my-app-prod:1.0 .

# Check the size
docker images my-app-prod:1.0
```
```
REPOSITORY       TAG       IMAGE ID       CREATED         SIZE
my-app-prod      1.0       ghi789jkl012   2 minutes ago   112MB  # Even smaller!
```

## 2.7 Comparing Image Sizes

Let's benchmark our progress:

```bash
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```
```
REPOSITORY       TAG       SIZE
my-app-naive     1.0       1.02GB
my-app-cached    1.0       118MB
my-app-prod      1.0       112MB
```

**Key Takeaways:**
- **Base image matters:** Python:3.11 → 1.02GB vs slim → 118MB
- **Multi-stage builds:** Removed build tools from final image
- **Security:** Non-root user, minimal packages
- **Health checks:** Added for production readiness

## 2.8 Advanced Dockerfile Patterns

### Pattern 1: Dependency Caching for Node.js

```dockerfile
FROM node:18-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

FROM node:18-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package.json .
CMD ["node", "dist/index.js"]
```

### Pattern 2: Development vs Production

```dockerfile
# Development stage
FROM node:18-alpine AS dev
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]

# Production stage
FROM dev AS prod-builder
RUN npm run build

FROM nginx:alpine
COPY --from=prod-builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Use in `docker-compose.yml`:
```yaml
services:
  app:
    build:
      context: .
      target: dev  # Use dev stage
```

### Pattern 3: Go Application (Static Binary)

```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/main ./cmd/app

FROM scratch
COPY --from=builder /app/main /app/main
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
EXPOSE 8080
ENTRYPOINT ["/app/main"]
```

Size: ~15MB (compared to ~1GB with full Go image)

### Pattern 4: Distroless Images

**Distroless** images contain only your application and its runtime dependencies, without package managers, shells, or other OS tools.

```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -o main .

FROM gcr.io/distroless/static-debian11
COPY --from=builder /app/main /app/main
ENTRYPOINT ["/app/main"]
```

**Pros:** Minimal attack surface
**Cons:** No shell for debugging (can't `docker exec` in)

## 2.9 Debugging Build Failures

### Common Build Issues

#### Issue 1: `COPY failed: file not found`

**Error:**
```
COPY failed: stat /path/to/file: no such file or directory
```

**Solutions:**
```bash
# Check the build context
docker build --no-cache --progress=plain .

# List build context contents
docker build --file Dockerfile .
```

#### Issue 2: `RUN` commands failing

```dockerfile
# Debug by adding shell flags
RUN set -x && command-that-fails

# Or split into multiple RUNs for debugging
RUN apt-get update
RUN apt-get install -y package-name
```

#### Issue 3: Cache invalidation

```dockerfile
# Force rebuild of all layers
docker build --no-cache -t my-app .

# Rebuild only up to a specific layer (use ARG to break cache)
ARG CACHE_BUST=1
RUN command-to-force-rebuild
```

### Build Arguments for Debugging

```dockerfile
# Add debugging tools in development
ARG ENVIRONMENT=production
RUN if [ "$ENVIRONMENT" = "development" ]; then \
        apt-get install -y vim curl telnet; \
    fi
```

```bash
docker build --build-arg ENVIRONMENT=development -t my-app:dev .
```

## 2.10 Security Best Practices

### 1. Run as Non-Root

```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

### 2. Use Specific Versions

```dockerfile
# ❌ Bad: latest is unpredictable
FROM python:latest

# ✅ Good: specific version
FROM python:3.11.7-slim
```

### 3. Keep Layers Small

```dockerfile
# ❌ Bad: multiple layers
RUN apt-get update
RUN apt-get install -y package1
RUN apt-get install -y package2
RUN rm -rf /var/lib/apt/lists/*

# ✅ Good: single layer
RUN apt-get update && \
    apt-get install -y package1 package2 && \
    rm -rf /var/lib/apt/lists/*
```

### 4. Use `.dockerignore`

Always include a `.dockerignore` file to prevent secrets from being copied into the image.

### 5. Scan Your Images

```bash
# Scan for vulnerabilities
docker scan my-app:1.0

# Or use Trivy (more comprehensive)
trivy image my-app:1.0
```

## 2.11 Lab: Build Your Own Dockerfile

### Part 1: Create a Simple Web App

Create `app.py`:
```python
#!/usr/bin/env python3
from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def index():
    return '<h1>My Flask App in Docker</h1>'

@app.route('/health')
def health():
    return jsonify({
        'status': 'ok',
        'hostname': os.getenv('HOSTNAME', 'unknown')
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

Create `requirements.txt`:
```
Flask==2.3.3
```

### Part 2: Write Production Dockerfile

**Your Task:** Write a production Dockerfile that:

1. Uses multi-stage builds
2. Runs as non-root user
3. Has health checks
4. Is optimized for caching
5. < 120MB in size

**`Dockerfile` (solution)**
```dockerfile
# Stage 1: Builder
FROM python:3.11-slim AS builder

WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends gcc
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY app.py .
ENV PATH=/root/.local/bin:$PATH

RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 --no-create-home appuser
USER appuser

HEALTHCHECK --interval=30s --timeout=3s \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

EXPOSE 5000
CMD ["python", "app.py"]
```

### Part 3: Build and Test

```bash
# Build
docker build -t flask-app:latest .

# Check size
docker images flask-app:latest

# Run
docker run -d --name flask-app -p 5000:5000 flask-app:latest

# Test
curl http://localhost:5000/health

# View logs
docker logs flask-app

# Clean up
docker stop flask-app
docker rm flask-app
```

## 2.12 Summary

You've now mastered the art of creating production-grade Docker images. You understand:

- **Dockerfile directives:** FROM, WORKDIR, COPY, RUN, CMD, ENTRYPOINT, ENV, EXPOSE, USER
- **Layer caching:** How to order instructions for fastest rebuilds
- **Multi-stage builds:** Separating build and runtime environments
- **Image size optimization:** Slim base images, Alpine, distroless
- **Security:** Non-root users, minimal packages, .dockerignore
- **Production features:** Health checks, logging, environment variables

**Best Practice Checklist for Your Images:**
- [ ] Use specific, slim base images
- [ ] Order instructions for optimal caching
- [ ] Use multi-stage builds for production images
- [ ] Run as non-root user
- [ ] Include `.dockerignore`
- [ ] Set `PYTHONUNBUFFERED=1` (Python apps)
- [ ] Add health checks
- [ ] Use `--no-cache-dir` with pip
- [ ] Keep packages minimal
- [ ] Scan for vulnerabilities
