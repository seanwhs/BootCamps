# Part 28: Dockerizing Next.js

## Containerizing Your Next.js Frontend for Production

Welcome to **Part 28** of the Django REST Framework & Next.js 16 masterclass. Now that we have our Django backend containerized, it's time to containerize our Next.js frontend. We'll create a production-grade Docker image optimized for performance, security, and reliability.

In this part, we'll:
- Create a multi-stage Dockerfile for Next.js
- Optimize the Next.js production build
- Implement health checks for Next.js
- Configure environment variables for containers
- Set up Next.js standalone output for smaller images

Think of this as **packaging your frontend** for the journey to production. Just as we carefully packed our backend in a container, we need to package our Next.js application with all its dependencies, configurations, and optimizations.

---

## The Target

We'll create a complete Docker setup for Next.js:

```
frontend/
├── Dockerfile                    # Production image
├── Dockerfile.dev               # Development image
├── .dockerignore                # Exclude files from Docker build
├── entrypoint.sh               # Container entrypoint script
├── next.config.js              # Updated with standalone output
└── scripts/
    └── docker-entrypoint.sh    # Pre-startup setup script
```

---

## The Concept

### Next.js Build Optimizations

Next.js provides several production optimizations:

1. **Standalone Output**: Creates a self-contained deployment
2. **Static Generation**: Pre-renders pages at build time
3. **Image Optimization**: Automatic image optimization
4. **Code Splitting**: Only loads necessary JavaScript

### Standalone Build

Next.js standalone output creates a minimal production build:

```
.next/standalone/
├── server.js          # Minimal server
├── node_modules/      # Production dependencies only
└── static/            # Static assets
```

### Multi-Stage Benefits

1. **Smaller Image**: Only production dependencies
2. **Faster Builds**: Better caching of layers
3. **Cleaner Image**: No build tools in production
4. **Better Security**: Reduced attack surface

---

## The Implementation

### Step 1: Create .dockerignore

**frontend/.dockerignore** (create)

```gitignore
# Node
node_modules
npm-debug.log
yarn-error.log
yarn-debug.log
.pnpm-debug.log

# Next.js
.next
out
.vercel
build
dist
.standalone

# Testing
coverage
.nyc_output
.pytest_cache
.cypress
cypress/videos
cypress/screenshots

# Environment
.env
.env.*
!.env.example
*.local

# Git
.git
.gitignore
.github

# IDE
.vscode
.idea
*.swp
*.swo
.DS_Store

# Docker
Dockerfile
.dockerignore
docker-compose*.yml

# Documentation
docs/
*.md
README.md

# Other
*.log
*.bak
*.tmp
```

### Step 2: Update Next.js Configuration for Standalone

**frontend/next.config.js** (update)

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  // Standalone output for Docker
  output: 'standalone',
  
  // Images configuration
  images: {
    domains: ['localhost'],
    remotePatterns: [
      {
        protocol: 'http',
        hostname: 'localhost',
        port: '8000',
        pathname: '/media/**',
      },
    ],
  },
  
  // API rewrites
  async rewrites() {
    const apiUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000/api/v1';
    return [
      {
        source: '/api/:path*',
        destination: `${apiUrl}/:path*`,
      },
    ];
  },
  
  // Security headers
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
          {
            key: 'Content-Security-Policy',
            value: process.env.NODE_ENV === 'production'
              ? "default-src 'self'; img-src 'self' data: https:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; font-src 'self' data:; connect-src 'self' https://api.taskflow.com;"
              : "default-src 'self'; img-src 'self' data: https:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; font-src 'self' data:; connect-src 'self' http://localhost:8000;",
          },
        ],
      },
    ];
  },
  
  // Experimental features
  experimental: {
    optimizeCss: true,
  },
  
  // Compression
  compress: true,
  
  // Powered by header (disable for security)
  poweredByHeader: false,
  
  // React strict mode
  reactStrictMode: true,
};

module.exports = nextConfig;
```

### Step 3: Create Entrypoint Script

**frontend/entrypoint.sh** (create)

```bash
#!/bin/sh
set -e

# Check if we're in development or production
if [ "$NODE_ENV" = "production" ]; then
    echo "Starting Next.js in production mode..."
    exec node server.js
else
    echo "Starting Next.js in development mode..."
    exec npm run dev
fi
```

Make it executable:

```bash
chmod +x frontend/entrypoint.sh
```

### Step 4: Create Dockerfile

**frontend/Dockerfile** (create)

```dockerfile
# Stage 1: Dependencies
FROM node:20-alpine AS deps

# Install dependencies only when needed
RUN apk add --no-cache libc6-compat

# Set work directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --only=production --no-cache

# Stage 2: Builder
FROM node:20-alpine AS builder

# Set work directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Install all dependencies
RUN npm ci --no-cache

# Copy source files
COPY . .

# Set environment variables for build
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build the application
RUN npm run build

# Stage 3: Runner
FROM node:20-alpine AS runner

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Install only runtime dependencies
RUN apk add --no-cache curl

# Set environment variables
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000

# Set work directory
WORKDIR /app

# Copy standalone output from builder
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to non-root user
USER nextjs

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:3000/api/health || exit 1

# Expose port
EXPOSE 3000

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["node", "server.js"]
```

### Step 5: Create Development Dockerfile

**frontend/Dockerfile.dev** (create)

```dockerfile
# Development Dockerfile
FROM node:20-alpine

# Install dependencies for development
RUN apk add --no-cache curl

# Set work directory
WORKDIR /app

# Set environment variables
ENV NODE_ENV=development
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000

# Copy package files
COPY package.json package-lock.json ./

# Install all dependencies (including dev)
RUN npm ci --no-cache

# Copy source files
COPY . .

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose port
EXPOSE 3000

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["npm", "run", "dev"]
```

### Step 6: Update Docker Compose for Frontend

**docker-compose.yml** (add frontend service)

```yaml
version: '3.8'

services:
  # ... existing services (db, redis, backend) ...

  # Next.js Frontend - Development
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    container_name: taskflow-frontend
    env_file:
      - ./frontend/.env.local
    environment:
      - NEXT_PUBLIC_API_URL=http://backend:8000/api/v1
      - NODE_ENV=development
    volumes:
      - ./frontend:/app
      - /app/node_modules
      - /app/.next
    ports:
      - "3000:3000"
    depends_on:
      - backend
    networks:
      - taskflow-network
```

### Step 7: Create Production Docker Compose

**docker-compose.prod.yml** (add frontend service)

```yaml
version: '3.8'

services:
  # ... existing services (db, redis, backend, nginx) ...

  # Next.js Frontend - Production
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    image: taskflow-frontend:latest
    container_name: taskflow-frontend
    env_file:
      - ./frontend/.env.production
    environment:
      - NEXT_PUBLIC_API_URL=https://api.taskflow.com/api/v1
      - NODE_ENV=production
    ports:
      - "3000:3000"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    networks:
      - taskflow-network
```

### Step 8: Create Health Check API Route

**frontend/app/api/health/route.ts** (create)

```typescript
import { NextResponse } from 'next/server';

export async function GET() {
  return NextResponse.json({
    status: 'healthy',
    timestamp: Date.now(),
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
  });
}
```

### Step 9: Create Build Script

**frontend/scripts/build.sh** (create)

```bash
#!/bin/bash

# Build script for Docker images

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Building TaskFlow Frontend Docker images...${NC}"

# Build development image
echo -e "${YELLOW}Building development image...${NC}"
docker build -f frontend/Dockerfile.dev -t taskflow-frontend:dev .

# Build production image
echo -e "${YELLOW}Building production image...${NC}"
docker build -f frontend/Dockerfile -t taskflow-frontend:latest .

# Tag for registry (optional)
if [ -n "$DOCKER_REGISTRY" ]; then
    echo -e "${YELLOW}Tagging image for registry...${NC}"
    docker tag taskflow-frontend:latest $DOCKER_REGISTRY/taskflow-frontend:latest
fi

echo -e "${GREEN}✓ Build complete!${NC}"
echo ""
echo -e "Development:  taskflow-frontend:dev"
echo -e "Production:   taskflow-frontend:latest"
echo ""
echo -e "To run: docker-compose up"
echo -e "To run production: docker-compose -f docker-compose.prod.yml up"
```

Make it executable:

```bash
chmod +x frontend/scripts/build.sh
```

### Step 10: Create Production Environment File

**frontend/.env.production.example** (create)

```bash
# Production environment variables
NEXT_PUBLIC_API_URL=https://api.taskflow.com/api/v1
NEXT_PUBLIC_APP_URL=https://app.taskflow.com

# Internal (not exposed to browser)
# These are used at build time
# Next.js will inline these values
```

---

## The Verification

### Step 1: Build the Docker Images

```bash
cd project-root

# Build frontend images
./frontend/scripts/build.sh

# Or build all images
docker-compose build
```

### Step 2: Run Development Environment

```bash
docker-compose up
```

### Step 3: Test the Frontend Container

```bash
# Check if the container is running
docker ps

# Test the health check
curl http://localhost:3000/api/health

# Test the application
curl http://localhost:3000

# Test API proxying
curl http://localhost:3000/api/v1/tasks/
```

### Step 4: Check Container Logs

```bash
docker logs taskflow-frontend
```

### Step 5: Run Production Build

```bash
# Build production image
docker build -f frontend/Dockerfile -t taskflow-frontend:prod .

# Run with production compose
docker-compose -f docker-compose.prod.yml up -d
```

### Step 6: Test Image Size

```bash
# Check image sizes
docker images | grep taskflow-frontend

# Should see:
# taskflow-frontend:dev    ~1.2GB
# taskflow-frontend:latest ~200MB  (standalone build)
```

---

## Key Takeaways

1. **Standalone output** creates smaller, self-contained images.

2. **Multi-stage builds** separate build and runtime.

3. **Non-root user** improves security.

4. **Health checks** enable container orchestration.

5. **Environment variables** configure the application.

6. **Optimized builds** reduce image size significantly.

7. **Build-time configuration** improves performance.

8. **Development vs production** images serve different needs.

---

## What's Next

In **Part 29**, we'll set up Docker Compose for the entire stack:

- Complete Docker Compose configuration
- Nginx reverse proxy
- Development vs production environments
- Service orchestration

---

**End of Part 28**

*Next: Part 29 - Docker Compose*
