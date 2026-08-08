# Part 29: Docker Compose

## Orchestrating Your Complete Application Stack

Welcome to **Part 29** of the Django REST Framework & Next.js 16 masterclass. Now that we have both Django and Next.js containerized, it's time to orchestrate the entire application stack. We'll use Docker Compose to run all services together, including PostgreSQL, Redis, Nginx, and both frontend and backend applications.

In this part, we'll:
- Configure complete Docker Compose for the entire stack
- Set up Nginx as a reverse proxy
- Configure development and production environments
- Implement service dependencies and health checks
- Set up volumes for persistent data and logs
- Create a production-ready compose file

Think of Docker Compose as your **application conductor**. Just as an orchestra conductor coordinates all the musicians to create a symphony, Docker Compose coordinates all your services to create a complete application.

---

## The Target

We'll create a complete Docker Compose setup:

```
docker-compose.yml              # Development setup
docker-compose.prod.yml         # Production setup
docker-compose.override.yml    # Development overrides
nginx/
├── nginx.conf                  # Nginx configuration
└── conf.d/
    └── default.conf            # Site configuration
```

---

## The Concept

### Service Orchestration

Docker Compose coordinates multiple containers:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Docker Compose Architecture                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                        Nginx                                │   │
│  │                    (Reverse Proxy)                         │   │
│  │                Port 80/443 → 3000/8000                     │   │
│  └──────────────────────┬──────────────────────────────────────┘   │
│                         │                                         │
│            ┌────────────┴────────────┐                           │
│            ▼                         ▼                           │
│  ┌─────────────────┐     ┌─────────────────┐                     │
│  │    Frontend     │     │    Backend      │                     │
│  │   (Next.js)     │────▶│    (Django)     │                     │
│  │     Port 3000   │     │   Port 8000     │                     │
│  └─────────────────┘     └────────┬────────┘                     │
│                                   │                               │
│                        ┌──────────┴──────────┐                   │
│                        ▼                     ▼                   │
│              ┌─────────────────┐   ┌─────────────────┐          │
│              │   PostgreSQL   │   │     Redis      │          │
│              │   (Database)   │   │    (Cache)     │          │
│              │     Port 5432  │   │    Port 6379   │          │
│              └─────────────────┘   └─────────────────┘          │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Development vs Production Differences

| Aspect | Development | Production |
|--------|-------------|------------|
| **Source Code** | Mounted as volume | Built into image |
| **Server** | Django runserver / Next.js dev | Gunicorn / Node production |
| **Debug** | Enabled | Disabled |
| **Logging** | Verbose | Minimal |
| **Security** | Lax | Strict |
| **Health Checks** | Optional | Required |
| **Restart Policy** | No | Unless-stopped |

---

## The Implementation

### Step 1: Create Nginx Configuration

**nginx/nginx.conf** (create)

```nginx
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;

    # Performance settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 20M;
    client_body_timeout 60;
    client_header_timeout 60;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss 
               application/rss+xml image/svg+xml text/html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Include site configurations
    include /etc/nginx/conf.d/*.conf;
}
```

**nginx/conf.d/default.conf** (create)

```nginx
# Upstream definitions
upstream backend {
    server backend:8000;
    keepalive 32;
}

upstream frontend {
    server frontend:3000;
    keepalive 32;
}

# Main server block
server {
    listen 80;
    server_name localhost taskflow.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS server (for production with SSL)
server {
    listen 443 ssl http2;
    server_name localhost taskflow.com;

    # SSL configuration (uncomment for production)
    # ssl_certificate /etc/nginx/ssl/cert.pem;
    # ssl_certificate_key /etc/nginx/ssl/key.pem;
    # ssl_protocols TLSv1.2 TLSv1.3;
    # ssl_ciphers HIGH:!aNULL:!MD5;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; img-src 'self' data: https:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; font-src 'self' data:;" always;

    # Static files from Django
    location /static/ {
        alias /static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Media files from Django
    location /media/ {
        alias /media/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Backend API
    location /api/ {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Connection "";
        
        # CORS headers
        add_header 'Access-Control-Allow-Origin' '*' always;
        add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, PATCH, DELETE, OPTIONS' always;
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization' always;
        
        # Handle preflight requests
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, PATCH, DELETE, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range,Authorization';
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }
    }

    # Admin interface (restrict access in production)
    location /admin/ {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health checks
    location /health/ {
        proxy_pass http://backend/health/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Frontend - all other routes
    location / {
        proxy_pass http://frontend;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Connection "";
        
        # WebSocket support (for Next.js)
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}

# Health check endpoint for Nginx
server {
    listen 8080;
    server_name localhost;
    
    location /nginx-health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

### Step 2: Update Development Docker Compose

**docker-compose.yml** (complete update)

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
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-taskflow_user}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - taskflow-network
    restart: unless-stopped

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
    restart: unless-stopped

  # Backend
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    container_name: taskflow-backend
    env_file:
      - ./backend/.env
    environment:
      - DATABASE_URL=postgresql://${DB_USER:-taskflow_user}:${DB_PASSWORD:-taskflow_pass}@db:5432/${DB_NAME:-taskflow_db}
      - REDIS_URL=redis://redis:6379/1
      - DJANGO_ENV=development
      - DEBUG=True
    volumes:
      - ./backend:/app
      - /app/staticfiles
      - /app/media
      - ./logs/backend:/app/logs
    ports:
      - "8000:8000"
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - taskflow-network
    restart: unless-stopped

  # Frontend
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    container_name: taskflow-frontend
    env_file:
      - ./frontend/.env.local
    environment:
      - NEXT_PUBLIC_API_URL=http://localhost:8000/api/v1
      - NODE_ENV=development
    volumes:
      - ./frontend:/app
      - /app/node_modules
      - /app/.next
      - ./logs/frontend:/app/logs
    ports:
      - "3000:3000"
    depends_on:
      - backend
    networks:
      - taskflow-network
    restart: unless-stopped

  # Nginx
  nginx:
    image: nginx:alpine
    container_name: taskflow-nginx
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./backend/staticfiles:/static:ro
      - ./backend/media:/media:ro
      - ./logs/nginx:/var/log/nginx
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend
      - frontend
    networks:
      - taskflow-network
    restart: unless-stopped

networks:
  taskflow-network:
    driver: bridge

volumes:
  postgres_data:
  redis_data:
```

### Step 3: Create Production Docker Compose

**docker-compose.prod.yml** (complete)

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
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-taskflow_user}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - taskflow-network
    restart: unless-stopped

  # Redis
  redis:
    image: redis:7-alpine
    container_name: taskflow-redis
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD:-}
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - taskflow-network
    restart: unless-stopped

  # Backend
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
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
    networks:
      - taskflow-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Frontend
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
      - NEXT_PUBLIC_APP_URL=https://app.taskflow.com
      - NODE_ENV=production
    ports:
      - "3000:3000"
    networks:
      - taskflow-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Nginx
  nginx:
    image: nginx:alpine
    container_name: taskflow-nginx
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - static_volume:/static:ro
      - media_volume:/media:ro
      - ./ssl:/etc/nginx/ssl:ro
      - ./logs/nginx:/var/log/nginx
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - backend
      - frontend
    networks:
      - taskflow-network
    restart: unless-stopped

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

### Step 4: Create Environment Variables

**backend/.env.example** (update)

```bash
# Django settings
SECRET_KEY=django-insecure-your-secret-key-here
DEBUG=True
DATABASE_URL=postgresql://taskflow_user:taskflow_pass@db:5432/taskflow_db
ALLOWED_HOSTS=localhost,127.0.0.1,backend

# Redis
REDIS_URL=redis://redis:6379/1

# JWT
JWT_SECRET_KEY=your-jwt-secret-key

# Email (optional)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
EMAIL_USE_TLS=True
```

**backend/.env.production** (create)

```bash
# Django settings
SECRET_KEY=${DJANGO_SECRET_KEY}
DEBUG=False
DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
ALLOWED_HOSTS=api.taskflow.com,www.api.taskflow.com

# Redis
REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379/1

# JWT
JWT_SECRET_KEY=${JWT_SECRET_KEY}

# Email
EMAIL_HOST=${EMAIL_HOST}
EMAIL_PORT=${EMAIL_PORT}
EMAIL_HOST_USER=${EMAIL_HOST_USER}
EMAIL_HOST_PASSWORD=${EMAIL_HOST_PASSWORD}
EMAIL_USE_TLS=True
```

**frontend/.env.production** (create)

```bash
# Production environment variables
NEXT_PUBLIC_API_URL=https://api.taskflow.com/api/v1
NEXT_PUBLIC_APP_URL=https://app.taskflow.com
```

### Step 5: Create Deployment Scripts

**scripts/deploy.sh** (create)

```bash
#!/bin/bash

# Deployment script

set -e

echo "🚀 Deploying TaskFlow to production..."

# Pull latest changes
echo "📦 Pulling latest code..."
git pull origin main

# Build and start containers
echo "🐳 Building and starting containers..."
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d

# Run migrations
echo "🔄 Running database migrations..."
docker-compose -f docker-compose.prod.yml exec backend python manage.py migrate

# Collect static files
echo "📁 Collecting static files..."
docker-compose -f docker-compose.prod.yml exec backend python manage.py collectstatic --noinput

# Check health
echo "🏥 Checking health..."
sleep 10
curl -f http://localhost/health/ || echo "⚠️ Health check failed!"

echo "✅ Deployment complete!"
```

**scripts/backup.sh** (create)

```bash
#!/bin/bash

# Database backup script

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/taskflow_backup_$TIMESTAMP.sql"

echo "📦 Creating database backup..."

mkdir -p $BACKUP_DIR

docker-compose -f docker-compose.prod.yml exec -T db pg_dump -U ${DB_USER:-taskflow_user} ${DB_NAME:-taskflow_db} > $BACKUP_FILE

echo "✅ Backup created: $BACKUP_FILE"

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
```

Make scripts executable:

```bash
chmod +x scripts/deploy.sh
chmod +x scripts/backup.sh
```

### Step 6: Create Development Setup Script

**scripts/setup-dev.sh** (create)

```bash
#!/bin/bash

# Development environment setup

set -e

echo "🔧 Setting up development environment..."

# Create .env files from examples if they don't exist
if [ ! -f backend/.env ]; then
    cp backend/.env.example backend/.env
fi

if [ ! -f frontend/.env.local ]; then
    cp frontend/.env.local.example frontend/.env.local
fi

# Create logs directory
mkdir -p logs/backend
mkdir -p logs/frontend
mkdir -p logs/nginx

# Build and start containers
echo "🐳 Building and starting development containers..."
docker-compose down
docker-compose build
docker-compose up -d

# Run migrations
echo "🔄 Running migrations..."
docker-compose exec backend python manage.py migrate

# Create superuser
echo "👤 Creating superuser..."
docker-compose exec backend python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(email='admin@example.com').exists():
    User.objects.create_superuser(
        email='admin@example.com',
        username='admin',
        password='admin123'
    )
    print('✅ Superuser created: admin@example.com / admin123')
"

echo "✅ Development environment ready!"
echo ""
echo "🌐 Access the application:"
echo "  Frontend:  http://localhost"
echo "  Backend:   http://localhost/api/"
echo "  Admin:     http://localhost/admin/"
echo "  API Docs:  http://localhost/api/docs/"
echo "  Health:    http://localhost/health/"
echo ""
echo "👤 Admin credentials:"
echo "  Email: admin@example.com"
echo "  Password: admin123"
echo ""
echo "📋 To view logs: docker-compose logs -f"
echo "🛑 To stop: docker-compose down"
```

Make it executable:

```bash
chmod +x scripts/setup-dev.sh
```

---

## The Verification

### Step 1: Set Up Development Environment

```bash
cd project-root
./scripts/setup-dev.sh
```

### Step 2: Test All Services

```bash
# Check all containers are running
docker-compose ps

# Test backend health
curl http://localhost/health/

# Test frontend
curl http://localhost/

# Test API
curl http://localhost/api/v1/tasks/

# Test admin
curl http://localhost/admin/
```

### Step 3: View Logs

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f nginx
```

### Step 4: Test Production Build

```bash
# Build production images
docker-compose -f docker-compose.prod.yml build

# Start production
docker-compose -f docker-compose.prod.yml up -d

# Test health
curl http://localhost/health/

# Check logs
docker-compose -f docker-compose.prod.yml logs -f
```

### Step 5: Stop Everything

```bash
# Stop development
docker-compose down

# Stop production
docker-compose -f docker-compose.prod.yml down
```

---

## Key Takeaways

1. **Docker Compose** orchestrates multiple containers into a single application.

2. **Nginx** serves as a reverse proxy, routing requests to the appropriate services.

3. **Environment variables** configure containers for different environments.

4. **Health checks** ensure services are running properly.

5. **Volume mounts** persist data and share files between containers.

6. **Service dependencies** ensure proper startup order.

7. **Development vs production** compose files separate concerns.

8. **Deployment scripts** automate the deployment process.

---

## What's Next

In **Part 30**, we'll configure production settings:

- Production Django settings
- Security configurations
- Logging and monitoring
- Performance tuning

---

**End of Part 29**

*Next: Part 30 - Production Configuration*
