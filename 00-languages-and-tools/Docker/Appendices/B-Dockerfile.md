# Appendix B – Complete Dockerfile Reference

This appendix provides a comprehensive reference for writing Dockerfiles, from basic instructions to advanced patterns. Use this as your go-to guide when crafting container images.

## B.1 Dockerfile Instructions Reference

### FROM – Set Base Image

The `FROM` instruction initializes a new build stage and sets the base image for subsequent instructions.

```dockerfile
# Basic usage
FROM ubuntu:22.04
FROM python:3.11-slim
FROM node:18-alpine

# Multi-stage builds
FROM python:3.11-slim AS builder

# Scratch (empty image)
FROM scratch

# Using a specific digest for security
FROM alpine@sha256:5cb04f4c6c3a97c49d6b6b10c46e6d0a42c95aab5b60a1419c86fe59c62ff1f8
```

**Best Practices:**
- Use specific version tags, never `latest`
- Prefer slim/alpine variants for smaller images
- Use `AS` to name stages in multi-stage builds

### RUN – Execute Commands

Executes commands in a new layer on top of the current image.

```dockerfile
# Single command
RUN apt-get update

# Multiple commands (preferred - fewer layers)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Package manager examples
RUN npm install
RUN pip install -r requirements.txt
RUN go mod download

# With BuildKit cache mount (faster builds)
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# With security considerations
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    curl -sSL https://example.com/script.sh | bash && \
    apt-get purge -y curl && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*
```

**Best Practices:**
- Combine multiple commands with `&&` to create fewer layers
- Clean up package manager caches after installation
- Use `--no-install-recommends` to reduce size
- Use BuildKit cache mounts when available

### COPY and ADD – Copy Files

**COPY** – Copies files/directories from build context to image.

```dockerfile
# Basic syntax
COPY source destination
COPY ["source", "destination"]  # For paths with spaces

# Examples
COPY package.json /app/
COPY . /app/
COPY --chown=appuser:appgroup . /app/

# Copy multiple files
COPY package.json package-lock.json /app/
COPY *.py /app/

# With wildcards
COPY src/*.js /app/dist/
```

**ADD** – Extended COPY with additional features.

```dockerfile
# Similar to COPY
ADD package.json /app/

# Supports URL downloads (avoid - use curl)
ADD https://example.com/file.tar.gz /tmp/

# Auto-extracts tar files (use with caution)
ADD app.tar.gz /app/

# Git repositories (avoid - use git clone)
ADD git@github.com:user/repo.git#main /app/
```

**Best Practices:**
- Prefer `COPY` over `ADD` unless you need specific features
- Use `--chown` to set proper ownership
- Use `.dockerignore` to exclude unnecessary files
- Copy dependency manifests first for better caching

### WORKDIR – Set Working Directory

Sets the working directory for `RUN`, `CMD`, `ENTRYPOINT`, `COPY`, and `ADD`.

```dockerfile
# Basic usage
WORKDIR /app

# Creates directory if it doesn't exist
WORKDIR /app/src

# Multiple WORKDIRs
WORKDIR /app
WORKDIR src
WORKDIR backend
# Now in /app/src/backend

# Absolute path
WORKDIR /var/www/html

# With chown (requires root)
WORKDIR --chown=appuser:appgroup /app
```

**Best Practices:**
- Always use `WORKDIR` instead of `RUN mkdir` and `cd`
- Use absolute paths for clarity
- Set `WORKDIR` before `COPY` and `RUN`

### CMD vs ENTRYPOINT

**CMD** – Provides defaults for an executing container.

```dockerfile
# Exec form (preferred)
CMD ["python", "app.py"]
CMD ["nginx", "-g", "daemon off;"]

# Shell form (uses /bin/sh -c)
CMD python app.py

# Multiple CMDs - only last one takes effect
CMD echo "first"
CMD echo "second"  # This one wins

# With default arguments to ENTRYPOINT
ENTRYPOINT ["python"]
CMD ["app.py"]  # Default argument
```

**ENTRYPOINT** – Configures a container that runs as an executable.

```dockerfile
# Exec form (preferred)
ENTRYPOINT ["python"]
ENTRYPOINT ["nginx", "-g", "daemon off;"]

# Shell form
ENTRYPOINT python app.py

# With CMD for default args
ENTRYPOINT ["python"]
CMD ["--help"]  # Can be overridden

# Advanced: entrypoint script
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["--help"]
```

**Comparison:**

| Configuration | Command | What runs |
|---------------|---------|-----------|
| CMD ["app.py"] | `docker run image` | `app.py` |
| CMD ["app.py"] | `docker run image test.py` | `test.py` (overridden) |
| ENTRYPOINT ["python"] | `docker run image` | `python` (with no args) |
| ENTRYPOINT ["python"] | `docker run image app.py` | `python app.py` |
| ENTRYPOINT ["python"] CMD ["app.py"] | `docker run image` | `python app.py` |
| ENTRYPOINT ["python"] CMD ["app.py"] | `docker run image test.py` | `python test.py` |

**Best Practices:**
- Use exec form (`["cmd", "arg"]`) over shell form
- Use `ENTRYPOINT` for the main executable
- Use `CMD` for default arguments
- Create custom entrypoint scripts for complex startup logic

### ENV – Environment Variables

Sets environment variables that persist in the container.

```dockerfile
# Single variable
ENV NODE_ENV production
ENV PORT 3000

# Multiple variables
ENV NODE_ENV=production \
    PORT=3000 \
    LOG_LEVEL=info

# Using previous ENV
ENV APP_HOME=/app
ENV CONFIG_PATH=$APP_HOME/config

# For build time only (ARG)
ARG VERSION=latest
ENV APP_VERSION=$VERSION
```

**Best Practices:**
- Set `ENV` early in Dockerfile for caching
- Use `ENV` for runtime environment variables
- Use `ARG` for build-time configuration
- Don't hardcode secrets in `ENV`

### ARG – Build Arguments

Defines variables that can be passed at build time.

```dockerfile
# Define with default value
ARG VERSION=latest
ARG NODE_ENV=production

# Use in build
FROM node:${VERSION}-alpine

# Build-time conditional
ARG BUILD_TYPE=production
RUN if [ "$BUILD_TYPE" = "development" ]; then \
        npm install -g nodemon; \
    fi

# Multiple ARG with defaults
ARG USER=appuser
ARG UID=1001
RUN adduser --uid $UID $USER
```

**Build-time usage:**
```bash
docker build --build-arg VERSION=18 --build-arg NODE_ENV=development -t myapp .
```

### EXPOSE – Document Ports

Informs Docker that the container listens on specified ports.

```dockerfile
# Single port
EXPOSE 80

# Multiple ports
EXPOSE 80 443 8080

# Specify protocol
EXPOSE 53/udp
EXPOSE 5432/tcp

# Multiple in one line
EXPOSE 80/tcp 443/tcp 8080/udp
```

**Note:** `EXPOSE` is informational – it doesn't actually publish the port. Use `-p` or `-P` with `docker run` to publish.

### USER – Set User

Sets the user for `RUN`, `CMD`, and `ENTRYPOINT`.

```dockerfile
# By name
USER appuser
USER appuser:appgroup

# By UID/GID
USER 1001:1001

# Create user and switch (common pattern)
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup
USER appuser

# Switch back to root
USER root

# With specific home directory
RUN adduser -S -h /app/home appuser
USER appuser
```

**Best Practices:**
- Always run containers as non-root in production
- Create user with minimal permissions
- Switch to user after installing dependencies

### VOLUME – Create Mount Points

Creates a mount point for external volumes.

```dockerfile
# Basic usage
VOLUME /data
VOLUME ["/var/log", "/etc/config"]

# With multiple paths
VOLUME /app/logs /app/uploads

# Named volumes in compose
VOLUME /var/lib/postgresql/data
```

**Best Practices:**
- Use `VOLUME` for directories that need persistence
- Don't use `VOLUME` for directories with sensitive data
- Use named volumes in compose instead of anonymous ones

### LABEL – Add Metadata

Adds metadata to the image.

```dockerfile
# Basic labels
LABEL maintainer="dev@example.com"
LABEL version="1.0.0"
LABEL description="My awesome application"

# Multiple in one line
LABEL maintainer="dev@example.com" version="1.0.0"

# JSON-like for complex metadata
LABEL org.opencontainers.image.title="MyApp"
LABEL org.opencontainers.image.description="A web application"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.authors="dev@example.com"
LABEL org.opencontainers.image.source="https://github.com/user/repo"

# OCI image spec labels (recommended)
LABEL org.opencontainers.image.created="2024-01-15T10:00:00Z"
LABEL org.opencontainers.image.url="https://example.com"
LABEL org.opencontainers.image.documentation="https://docs.example.com"
LABEL org.opencontainers.image.vendor="MyCompany"
```

**View labels:**
```bash
docker inspect --format='{{json .Config.Labels}}' myapp
```

### HEALTHCHECK – Health Monitoring

Tells Docker how to check if a container is working.

```dockerfile
# HTTP check (most common)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Command check
HEALTHCHECK --interval=10s --timeout=5s \
    CMD pg_isready -U appuser

# Shell script check
HEALTHCHECK --interval=60s --timeout=30s \
    CMD /usr/local/bin/health-check.sh

# NONE (disable inherited healthcheck)
HEALTHCHECK NONE
```

**Options:**
- `--interval=DURATION` (default: 30s)
- `--timeout=DURATION` (default: 30s)
- `--start-period=DURATION` (default: 0s)
- `--retries=N` (default: 3)

**Exit codes:**
- 0: healthy
- 1: unhealthy
- 2: reserved (do not use)

### SHELL – Change Default Shell

Changes the default shell for shell-form commands.

```dockerfile
# Default is ["/bin/sh", "-c"] on Linux
SHELL ["/bin/bash", "-c"]

# With options
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# For Windows
SHELL ["powershell", "-Command"]

# Use with RUN commands
SHELL ["/bin/bash", "-c"]
RUN echo "Hello from bash"
```

### ONBUILD – Trigger Instructions

Adds triggers to be executed when the image is used as a base.

```dockerfile
# Parent Dockerfile
FROM python:3.11
RUN pip install my-package
ONBUILD COPY . /app
ONBUILD RUN pip install -r requirements.txt
CMD ["python", "app.py"]

# Child Dockerfile (user's)
FROM parent-image
# ONBUILD instructions run here
CMD ["python", "app.py"]
```

**Use Cases:**
- Framework base images
- Language runtime images
- Starter templates

### STOPSIGNAL – Set Stop Signal

Sets the system call signal that will be sent to the container to stop it.

```dockerfile
# Default is SIGTERM
STOPSIGNAL SIGTERM

# Alternative signals
STOPSIGNAL SIGKILL
STOPSIGNAL SIGUSR1
STOPSIGNAL SIGQUIT
```

### ADDITIONAL DIRECTIVES

```dockerfile
# Set the working directory to the path specified in case of Windows
SHELL ["powershell", "-Command"]

# Configure networking
EXPOSE 80

# Set the entry point
ENTRYPOINT ["python"]

# Set the working directory
WORKDIR /app
```

## B.2 Multi-Stage Build Patterns

### Pattern 1: Python Application

```dockerfile
# Stage 1: Builder
FROM python:3.11-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /root/.local /root/.local

# Copy application code
COPY app.py .

# Set PATH
ENV PATH=/root/.local/bin:$PATH

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

CMD ["python", "app.py"]
```

### Pattern 2: Node.js Application

```dockerfile
# Stage 1: Dependencies
FROM node:18-alpine AS deps

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Builder
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 3: Runtime
FROM node:18-alpine

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=deps /app/node_modules ./node_modules_prod
COPY package.json .

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

### Pattern 3: Go Application

```dockerfile
# Stage 1: Builder
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install dependencies
COPY go.mod go.sum ./
RUN go mod download

# Build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/main ./cmd/app

# Stage 2: Runtime
FROM scratch

# Copy binary
COPY --from=builder /app/main /app/main

# Copy certificates (if needed)
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 8080
ENTRYPOINT ["/app/main"]
```

### Pattern 4: Java Application

```dockerfile
# Stage 1: Builder
FROM maven:3.9-openjdk-17 AS builder

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn package -DskipTests

# Stage 2: Runtime
FROM openjdk:17-slim

WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Pattern 5: React Application with Build and Runtime

```dockerfile
# Stage 1: Dependencies
FROM node:18-alpine AS deps

WORKDIR /app
COPY package*.json ./
RUN npm ci

# Stage 2: Builder
FROM node:18-alpine AS builder

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

# Stage 3: Runtime (using Nginx)
FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## B.3 Optimized Dockerfile Patterns

### Development vs Production Pattern

```dockerfile
# Development stage
FROM node:18-alpine AS dev

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

CMD ["npm", "run", "dev"]

# Test stage
FROM dev AS test

CMD ["npm", "test"]

# Build stage
FROM dev AS build

RUN npm run build

# Production stage
FROM nginx:alpine AS prod

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Environment-Specific Build Pattern

```dockerfile
ARG NODE_ENV=production
ARG BUILD_TARGET=production

FROM node:18-alpine AS base

WORKDIR /app
COPY package*.json ./

# Development dependencies
FROM base AS dev-deps
RUN npm install

# Production dependencies
FROM base AS prod-deps
RUN npm ci --only=production

# Development build
FROM dev-deps AS dev-build
COPY . .
CMD ["npm", "run", "dev"]

# Production build
FROM prod-deps AS prod-build
COPY . .
RUN npm run build

# Final stage based on target
FROM ${BUILD_TARGET}-build AS final
EXPOSE 3000
CMD ["node", "dist/server.js"]
```

### Security-Focused Pattern

```dockerfile
FROM python:3.11-slim AS builder

# Minimal build
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Non-root user for builder
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

FROM python:3.11-slim AS runtime

# Security hardening
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy with specific ownership
COPY --chown=appuser:appgroup --from=builder /home/appuser/.local /home/appuser/.local
COPY --chown=appuser:appgroup app.py .

# No new privileges
RUN chmod 750 /app && chmod 640 /app/app.py

USER appuser

# Read-only filesystem
LABEL org.opencontainers.image.security="hardened"

HEALTHCHECK --interval=30s --timeout=3s \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost/health')"

# Drop capabilities at runtime (done in compose or run command)
EXPOSE 8000
CMD ["python", "app.py"]
```

## B.4 Common Dockerfile Patterns and Anti-Patterns

### Anti-Patterns to Avoid

**❌ 1. Using `latest` tag**
```dockerfile
FROM ubuntu:latest  # DON'T DO THIS
```

**✅ Fix:**
```dockerfile
FROM ubuntu:22.04  # Specific version
```

**❌ 2. Copying everything before installing dependencies**
```dockerfile
COPY . /app
RUN npm install
```

**✅ Fix:**
```dockerfile
COPY package*.json /app/
RUN npm install
COPY . /app
```

**❌ 3. Running many separate RUN commands**
```dockerfile
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN rm -rf /var/lib/apt/lists/*
```

**✅ Fix:**
```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*
```

**❌ 4. Leaving package manager caches**
```dockerfile
RUN apt-get update && apt-get install -y python3
```

**✅ Fix:**
```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends python3 && \
    rm -rf /var/lib/apt/lists/*
```

**❌ 5. Running as root**
```dockerfile
COPY . /app
CMD ["python", "app.py"]
```

**✅ Fix:**
```dockerfile
COPY --chown=appuser:appgroup . /app
USER appuser
CMD ["python", "app.py"]
```

### Best Practice Template

```dockerfile
# ============================================================
# Meta
# ============================================================
ARG NODE_VERSION=18
ARG ALPINE_VERSION=3.18

# ============================================================
# Builder
# ============================================================
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS builder

WORKDIR /app

# Copy package files first (cache optimization)
COPY package*.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run build

# ============================================================
# Runtime
# ============================================================
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION}

WORKDIR /app

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy built assets
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/package*.json ./
RUN npm ci --only=production

# Security hardening
USER appuser
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=512"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Metadata
LABEL org.opencontainers.image.title="MyApp"
LABEL org.opencontainers.image.version="${APP_VERSION:-latest}"
LABEL org.opencontainers.image.created="2024-01-15T10:00:00Z"

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

## B.5 .dockerignore Reference

### Common Patterns

```bash
# Version Control
.git/
.gitignore
.gitattributes
.svn/

# CI/CD
.github/
.gitlab/
.azure/
circle.yml
.travis.yml
Jenkinsfile

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
package-lock.json  # Include if you want (depends on strategy)
.npmrc

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
env.bak/
venv.bak/
pip-log.txt
pip-delete-this-directory.txt
.pytest_cache/
.coverage
htmlcov/
.tox/
.mypy_cache/
.dmypy.json
dmypy.json
*.log
*.pot
*.pyc

# Docker
Dockerfile*
.dockerignore
*.dockerignore

# IDE
.vscode/
.idea/
*.swp
*.swo
*~
.ensime
*.iml
.project
.classpath
.settings/

# OS Files
.DS_Store
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/

# Secrets
*.pem
*.key
*.crt
*.p12
*.jks
.secrets/
.env
.env.local
.env.*.local
*.secret
secrets/

# Build Outputs
dist/
build/
out/
target/
*.jar
*.war
*.ear
*.class
*.exe
*.dll
*.so
*.dylib

# Logs
logs/
*.log
*.pid
*.seed
*.pid.lock

# Coverage
coverage/
*.cover
*.gcda
*.gcno
*.gcov

# Compressed Files
*.7z
*.dmg
*.gz
*.iso
*.jar
*.rar
*.tar
*.zip

# Temporary Files
tmp/
temp/
*.tmp
*.temp

# Dependencies
vendor/
packages/
*.lock  # Be careful with this one

# Documentation
README.md
README.rst
*.md
doc/
docs/
*.pdf
*.epub

# Testing
tests/
test/
spec/
*.test.js
*.spec.js
__tests__/

# Other
*.swp
*.swo
*~
.directory
```

### Example .dockerignore

```bash
# ============================================================
# Docker-specific
# ============================================================
Dockerfile*
.dockerignore
*.dockerignore

# ============================================================
# Version Control
# ============================================================
.git/
.gitignore
.gitattributes

# ============================================================
# IDE & Editor
# ============================================================
.vscode/
.idea/
*.swp
*.swo

# ============================================================
# Dependencies
# ============================================================
node_modules/
vendor/
packages/

# ============================================================
# Build Outputs
# ============================================================
dist/
build/
target/

# ============================================================
# Secrets & Config
# ============================================================
.env
.env.*
*.secret
*.key
*.pem
*.crt

# ============================================================
# Logs & Temp
# ============================================================
logs/
*.log
tmp/
temp/

# ============================================================
# System Files
# ============================================================
.DS_Store
Thumbs.db

# ============================================================
# Documentation
# ============================================================
*.md
doc/
docs/

# ============================================================
# Tests
# ============================================================
tests/
test/
__tests__/
*.test.js
*.spec.js
*.test.py

# ============================================================
# CI/CD
# ============================================================
.github/
.gitlab/
.azure/
*.yml
*.yaml
```

## B.6 Complete Dockerfile Templates

### Basic Web Application

**Node.js with Express:**
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
USER node
EXPOSE 3000
CMD ["node", "server.js"]
```

**Python with Flask:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
RUN adduser -D appuser
USER appuser
EXPOSE 5000
CMD ["python", "app.py"]
```

**Go with Gin:**
```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o main

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/main .
EXPOSE 8080
CMD ["./main"]
```

### Database Containers

**PostgreSQL:**
```dockerfile
FROM postgres:15-alpine
ENV POSTGRES_USER=appuser
ENV POSTGRES_PASSWORD=secret
ENV POSTGRES_DB=appdb
EXPOSE 5432
```

**Custom PostgreSQL with init scripts:**
```dockerfile
FROM postgres:15-alpine
COPY init.sql /docker-entrypoint-initdb.d/
EXPOSE 5432
```

**Redis:**
```dockerfile
FROM redis:7.2-alpine
COPY redis.conf /usr/local/etc/redis/redis.conf
EXPOSE 6379
CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
```

### Reverse Proxy

**Nginx:**
```dockerfile
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY static/ /usr/share/nginx/html/static/
EXPOSE 80
```

**Custom Nginx with SSL:**
```dockerfile
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY ssl/ /etc/nginx/ssl/
EXPOSE 80 443
```

### CI/CD Images

**Test Runner:**
```dockerfile
FROM python:3.11-slim AS test
WORKDIR /app
COPY requirements.txt .
COPY requirements-dev.txt .
RUN pip install --no-cache-dir -r requirements-dev.txt
COPY . .
CMD ["pytest", "--cov=.", "--cov-report=xml"]
```

**Builder Image:**
```dockerfile
FROM node:18-alpine AS builder
RUN npm install -g typescript
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
```
