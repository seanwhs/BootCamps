# Primer 9: Flask Production Deployment & DevOps Primer

Welcome to Primer 9! This foundational primer is designed for beginners who want to understand how to deploy Flask applications to production using modern DevOps practices. Building on the basics from Primers 1-8, you'll learn how to take your application from development to a live, production-ready environment.

---

## Table of Contents

1. [From Development to Production](#1-from-development-to-production)
2. [Understanding the Production Stack](#2-understanding-the-production-stack)
3. [Preparing for Deployment](#3-preparing-for-deployment)
4. [Deployment with Gunicorn & Nginx](#4-deployment-with-gunicorn--nginx)
5. [Containerization with Docker](#5-containerization-with-docker)
6. [Cloud Deployment Options](#6-cloud-deployment-options)
7. [CI/CD Pipeline](#7-cicd-pipeline)
8. [Monitoring & Logging](#8-monitoring--logging)
9. [Scaling Your Application](#9-scaling-your-application)
10. [DevOps Best Practices](#10-devops-best-practices)

---

## 1. From Development to Production

### Development vs Production Environments

```yaml
Development Environment:
  - Flask's built-in server
  - SQLite database
  - Debug mode: ON
  - Reload on changes: YES
  - Single-threaded
  - Local only
  - No SSL/HTTPS

Production Environment:
  - Gunicorn/uWSGI server
  - PostgreSQL database
  - Debug mode: OFF
  - Reload on changes: NO
  - Multi-threaded/worker-based
  - Publicly accessible
  - SSL/HTTPS required
  - Load balanced
  - Monitored
```

### The Deployment Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                       Development                               │
│  - Write code                                                  │
│  - Run tests locally                                            │
│  - Test in development environment                             │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                       Version Control                           │
│  - Commit changes                                               │
│  - Push to GitHub/GitLab                                        │
│  - Create pull request                                          │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Continuous Integration                        │
│  - Run tests                                                    │
│  - Run linters                                                  │
│  - Build Docker image                                           │
│  - Security scanning                                            │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Staging Deployment                            │
│  - Deploy to staging environment                                │
│  - Run integration tests                                        │
│  - Manual QA                                                    │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Production Deployment                          │
│  - Deploy to production                                         │
│  - Monitor for issues                                           │
│  - Rollback if needed                                           │
└─────────────────────────────────────────────────────────────────┘
```

### The Production-Ready Checklist

```python
# Production Checklist

# 1. Application Configuration
app.config.update({
    'DEBUG': False,
    'TESTING': False,
    'SECRET_KEY': os.environ.get('SECRET_KEY'),  # Not hardcoded!
    'SESSION_COOKIE_SECURE': True,
    'SESSION_COOKIE_HTTPONLY': True,
    'SESSION_COOKIE_SAMESITE': 'Strict',
})

# 2. Database Configuration
# PostgreSQL or other production database
# Connection pooling
# Regular backups

# 3. Security
# HTTPS enabled
# Security headers
# Rate limiting
# Input validation
# SQL injection prevention

# 4. Performance
# Caching
# Static file optimization
# Database indexing
# Query optimization

# 5. Monitoring
# Error logging
# Application performance monitoring
# Health checks
# Alerting

# 6. Disaster Recovery
# Database backups
# Configuration backups
# Rollback procedures
```

---

## 2. Understanding the Production Stack

### The Production Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Users                               │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    Internet                                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  Load Balancer                              │
│  (AWS ELB, Nginx, HAProxy)                                 │
│  - Distributes traffic                                      │
│  - SSL termination                                          │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  Nginx (Reverse Proxy)                      │
│  - Serves static files                                      │
│  - Proxies requests                                         │
│  - Caching                                                  │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  Gunicorn (WSGI Server)                     │
│  - Multiple workers                                         │
│  - Handles dynamic requests                                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              Flask Application (Your Code)                  │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    PostgreSQL (Database)                    │
└─────────────────────────────────────────────────────────────┘
```

### Production Server Components

```python
# 1. Gunicorn - WSGI Server
# Handles multiple concurrent requests
# Spawns multiple workers
# Manages worker lifecycles

# gunicorn.conf.py
import multiprocessing

bind = '0.0.0.0:8000'
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = 'sync'
max_requests = 1000
max_requests_jitter = 100
timeout = 120
graceful_timeout = 30
preload_app = True

# 2. Nginx - Web Server & Reverse Proxy
# Serves static files efficiently
# Load balances requests
# Handles SSL termination
# Caches responses

# 3. PostgreSQL - Database
# Handles connections
# Manages transactions
# Provides ACID compliance

# 4. Redis - Cache & Queue
# Caching responses
# Session storage
# Message broker for Celery
```

---

## 3. Preparing for Deployment

### Setting Up Configuration

```python
# config.py
import os

class Config:
    """Base configuration."""
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

class DevelopmentConfig(Config):
    """Development configuration."""
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///dev.db'

class TestingConfig(Config):
    """Testing configuration."""
    DEBUG = False
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'

class ProductionConfig(Config):
    """Production configuration."""
    DEBUG = False
    TESTING = False
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    
    # Production security
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Strict'
    
    # Connection pooling
    SQLALCHEMY_ENGINE_OPTIONS = {
        'pool_size': 10,
        'pool_recycle': 3600,
        'pool_pre_ping': True,
        'max_overflow': 20,
    }

# Environment variable configuration
config_by_name = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
}

# In app.py
env = os.environ.get('FLASK_ENV', 'development')
app.config.from_object(config_by_name[env])
```

### Environment Variables (.env)

```bash
# .env.production

# Flask Settings
FLASK_ENV=production
FLASK_DEBUG=0
SECRET_KEY=your-very-secure-secret-key-here

# Database
DATABASE_URL=postgresql://taskflow:password@localhost:5432/taskflow
DATABASE_POOL_SIZE=20

# Redis/Celery
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/1
REDIS_CACHE_URL=redis://localhost:6379/2

# Email
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=noreply@taskflow.com
MAIL_PASSWORD=your-app-password

# Monitoring
SENTRY_DSN=your-sentry-dsn
NEW_RELIC_LICENSE_KEY=your-license-key

# Deployment Settings
GUNICORN_WORKERS=4
GUNICORN_THREADS=2
```

---

## 4. Deployment with Gunicorn & Nginx

### Gunicorn Setup

```python
# gunicorn.conf.py
import os
import multiprocessing

# Server socket
bind = os.environ.get('GUNICORN_BIND', '0.0.0.0:8000')
backlog = 2048

# Worker processes
workers = int(os.environ.get('GUNICORN_WORKERS', multiprocessing.cpu_count() * 2 + 1))
worker_class = os.environ.get('GUNICORN_WORKER_CLASS', 'sync')
threads = int(os.environ.get('GUNICORN_THREADS', 2))

# Worker timeouts
timeout = 120
graceful_timeout = 30
max_requests = 1000
max_requests_jitter = 100

# Process management
preload_app = True
worker_tmp_dir = '/dev/shm'

# Logging
accesslog = '-'
errorlog = '-'
loglevel = 'info'

# Access log format
access_log_format = '%(h)s %(l)s %(u)s %(t)s "%(r)s" %(s)s %(b)s "%(f)s" "%(a)s"'
```

### Nginx Configuration

```nginx
# /etc/nginx/sites-available/taskflow

upstream taskflow_app {
    # Gunicorn socket
    server unix:/tmp/taskflow.sock fail_timeout=0;
    
    # Or TCP connection
    # server 127.0.0.1:8000 fail_timeout=0;
}

server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;
    
    # SSL Configuration
    ssl_certificate /etc/ssl/certs/your-domain.crt;
    ssl_certificate_key /etc/ssl/private/your-domain.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    ssl_prefer_server_ciphers off;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Static files
    location /static/ {
        alias /var/www/taskflow/app/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        gzip on;
        gzip_types text/css text/javascript application/javascript;
    }
    
    # Uploads
    location /uploads/ {
        alias /var/www/taskflow/uploads/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Health check
    location /health {
        proxy_pass http://taskflow_app;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # API (with rate limiting)
    location /api/ {
        proxy_pass http://taskflow_app;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Rate limiting
        limit_req zone=api burst=20 nodelay;
        limit_conn addr 10;
    }
    
    # Main application
    location / {
        proxy_pass http://taskflow_app;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;
}
```

### Supervisor Configuration

```ini
# /etc/supervisor/conf.d/taskflow.conf

[program:taskflow]
command=/var/www/taskflow/venv/bin/gunicorn -c gunicorn.conf.py app:app
directory=/var/www/taskflow
user=www-data
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
stderr_logfile=/var/log/taskflow/error.log
stdout_logfile=/var/log/taskflow/access.log
```

### Deployment Script

```bash
#!/bin/bash
# deploy.sh

set -e

echo "🚀 Starting deployment..."

# Pull latest code
echo "📦 Pulling latest code..."
git pull origin main

# Install dependencies
echo "📦 Installing dependencies..."
source venv/bin/activate
pip install -r requirements.txt

# Run migrations
echo "🗄️ Running migrations..."
flask db upgrade

# Build static assets
echo "🎨 Building static assets..."
flask assets build

# Restart application
echo "🔄 Restarting application..."
sudo supervisorctl restart taskflow

# Clear cache
echo "🗑️ Clearing cache..."
sudo supervisorctl restart taskflow

# Verify deployment
echo "✅ Verifying deployment..."
curl -f http://localhost:8000/health

echo "🎉 Deployment complete!"
```

---

## 5. Containerization with Docker

### Dockerfile

```dockerfile
# Dockerfile

# Build stage
FROM python:3.13-slim AS builder

WORKDIR /build

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Final stage
FROM python:3.13-slim

WORKDIR /app

# Create non-root user
RUN adduser --disabled-password --no-create-home appuser

# Copy application
COPY --from=builder /root/.local /root/.local
COPY . .

# Install Gunicorn
RUN /root/.local/bin/pip install gunicorn

# Create directories
RUN mkdir -p /app/instance /app/logs /app/static/uploads \
    && chown -R appuser:appuser /app

USER appuser

# Environment variables
ENV PATH=/root/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=app

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

EXPOSE 8000

# Start Gunicorn
CMD ["gunicorn", "-c", "gunicorn.conf.py", "--bind", "0.0.0.0:8000", "app:app"]
```

### Docker Compose

```yaml
# docker-compose.yml

version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - FLASK_ENV=production
      - SECRET_KEY=${SECRET_KEY}
      - DATABASE_URL=postgresql://${DB_USER}:${DB_PASSWORD}@db:5432/${DB_NAME}
      - CELERY_BROKER_URL=redis://redis:6379/0
      - CELERY_RESULT_BACKEND=redis://redis:6379/1
    depends_on:
      - db
      - redis
    volumes:
      - ./logs:/app/logs
      - ./uploads:/app/static/uploads
  
  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=${DB_NAME}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
  
  nginx:
    image: nginx:1.25-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./app/static:/app/static:ro
      - ./uploads:/app/uploads:ro
    depends_on:
      - web

volumes:
  postgres_data:
  redis_data:
```

### Docker Commands

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# View logs
docker-compose logs -f
docker-compose logs -f web

# Stop services
docker-compose down

# Run migrations
docker-compose exec web flask db upgrade

# Shell into container
docker-compose exec web bash

# Rebuild and restart
docker-compose up -d --build

# Clean everything
docker-compose down -v
docker system prune -f
```

---

## 6. Cloud Deployment Options

### Deploying to Heroku

```bash
# Install Heroku CLI
# https://devcenter.heroku.com/articles/heroku-cli

# Login
heroku login

# Create app
heroku create taskflow-app

# Add PostgreSQL
heroku addons:create heroku-postgresql:hobby-dev

# Add Redis
heroku addons:create heroku-redis:hobby-dev

# Set environment variables
heroku config:set SECRET_KEY=your-secret-key
heroku config:set FLASK_ENV=production

# Deploy
git push heroku main

# Run migrations
heroku run flask db upgrade

# Open app
heroku open

# View logs
heroku logs --tail

# Scale dynos
heroku ps:scale web=2
```

### Deploying to AWS EC2

```bash
# 1. Launch EC2 instance (Ubuntu 22.04 LTS)

# 2. SSH into instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# 3. Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# 4. Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 5. Clone and deploy
git clone https://github.com/yourusername/taskflow.git
cd taskflow
docker-compose up -d

# 6. Setup SSL with Let's Encrypt
sudo apt update
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### Deploying to DigitalOcean

```bash
# 1. Create Droplet (Ubuntu 22.04)

# 2. SSH into droplet
ssh root@your-server-ip

# 3. Update system
apt update && apt upgrade -y

# 4. Install dependencies
apt install -y python3-pip python3-venv nginx postgresql redis

# 5. Clone repository
git clone https://github.com/yourusername/taskflow.git
cd taskflow

# 6. Setup Python environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 7. Setup PostgreSQL
sudo -u postgres createdb taskflow
sudo -u postgres psql -c "CREATE USER taskflow WITH PASSWORD 'password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE taskflow TO taskflow;"

# 8. Run migrations
flask db upgrade

# 9. Setup Gunicorn systemd service
# Create /etc/systemd/system/taskflow.service

# 10. Setup Nginx
# Configure Nginx as reverse proxy

# 11. Start services
sudo systemctl start taskflow
sudo systemctl enable taskflow
sudo systemctl restart nginx

# 12. Setup SSL with Let's Encrypt
```

### Deploying to Google Cloud Platform

```bash
# 1. Install Google Cloud SDK
# https://cloud.google.com/sdk/docs/install

# 2. Login
gcloud auth login

# 3. Create project
gcloud projects create taskflow-project

# 4. Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable sqladmin.googleapis.com

# 5. Create Cloud SQL instance
gcloud sql instances create taskflow-db \
    --database-version=POSTGRES_15 \
    --cpu=2 \
    --memory=4GB \
    --region=us-central1

# 6. Create Cloud SQL database
gcloud sql databases create taskflow --instance=taskflow-db

# 7. Create Compute Engine instance
gcloud compute instances create taskflow-web \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud

# 8. Deploy application via SSH
gcloud compute ssh taskflow-web

# 9. Setup with Docker (as shown in AWS section)
```

---

## 7. CI/CD Pipeline

### GitHub Actions Workflow

```yaml
# .github/workflows/deploy.yml

name: Deploy TaskFlow

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.13'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install -r requirements-dev.txt
      
      - name: Run tests
        run: |
          pytest --cov=app --cov-report=xml
        env:
          FLASK_ENV: testing
          DATABASE_URL: sqlite:///test.db
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml

  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Build and push Docker image
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            taskflow/web:latest
            taskflow/web:${{ github.sha }}
          build-args: |
            BUILD_VERSION=${{ github.sha }}
            BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Deploy to staging
        run: |
          # Deploy script for staging
          ssh user@staging-server "cd /var/www/taskflow && docker-compose pull && docker-compose up -d"
  
  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    environment: production
    if: github.ref == 'refs/heads/main'
    steps:
      - name: Deploy to production
        run: |
          # Deploy script for production
          ssh user@production-server "cd /var/www/taskflow && docker-compose pull && docker-compose up -d"
```

### GitLab CI Pipeline

```yaml
# .gitlab-ci.yml

stages:
  - test
  - build
  - deploy

variables:
  DOCKER_IMAGE: registry.gitlab.com/$CI_PROJECT_PATH

cache:
  paths:
    - .pip_cache/

test:
  stage: test
  image: python:3.13
  script:
    - python -m pip install --upgrade pip
    - pip install -r requirements.txt
    - pip install -r requirements-dev.txt
    - pytest --cov=app --cov-report=xml
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $DOCKER_IMAGE:$CI_COMMIT_SHA .
    - docker tag $DOCKER_IMAGE:$CI_COMMIT_SHA $DOCKER_IMAGE:latest
    - docker push $DOCKER_IMAGE:$CI_COMMIT_SHA
    - docker push $DOCKER_IMAGE:latest

deploy-staging:
  stage: deploy
  script:
    - echo "Deploying to staging..."
  environment:
    name: staging
    url: https://staging.taskflow.com
  only:
    - main

deploy-production:
  stage: deploy
  script:
    - echo "Deploying to production..."
  environment:
    name: production
    url: https://taskflow.com
  only:
    - tags
  when: manual
```

---

## 8. Monitoring & Logging

### Health Check Endpoint

```python
@app.route('/health')
def health_check():
    """Health check endpoint."""
    # Check database
    db_healthy = True
    try:
        db.session.execute('SELECT 1')
    except Exception:
        db_healthy = False
    
    # Check Redis
    redis_healthy = True
    try:
        from redis import Redis
        redis_client = Redis.from_url(app.config.get('CELERY_BROKER_URL'))
        redis_client.ping()
    except Exception:
        redis_healthy = False
    
    status = 'healthy' if (db_healthy and redis_healthy) else 'unhealthy'
    
    return jsonify({
        'status': status,
        'timestamp': datetime.utcnow().isoformat(),
        'database': 'connected' if db_healthy else 'disconnected',
        'redis': 'connected' if redis_healthy else 'disconnected',
        'version': os.environ.get('APP_VERSION', '1.0.0')
    }), 200 if status == 'healthy' else 503
```

### Application Logging

```python
import logging
from logging.handlers import RotatingFileHandler

def setup_production_logging(app):
    """Setup logging for production."""
    # Remove default handlers
    app.logger.handlers.clear()
    
    # Create logs directory
    import os
    os.makedirs('logs', exist_ok=True)
    
    # File handler with rotation
    file_handler = RotatingFileHandler(
        'logs/taskflow.log',
        maxBytes=10*1024*1024,  # 10MB
        backupCount=5
    )
    file_handler.setLevel(logging.INFO)
    
    # Error file handler
    error_handler = RotatingFileHandler(
        'logs/taskflow_errors.log',
        maxBytes=10*1024*1024,
        backupCount=10
    )
    error_handler.setLevel(logging.ERROR)
    
    # Format
    formatter = logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    )
    file_handler.setFormatter(formatter)
    error_handler.setFormatter(formatter)
    
    app.logger.addHandler(file_handler)
    app.logger.addHandler(error_handler)
    app.logger.setLevel(logging.INFO)
    
    app.logger.info('Application started in production mode')
```

### Error Tracking with Sentry

```python
import sentry_sdk
from sentry_sdk.integrations.flask import FlaskIntegration

# Initialize Sentry
sentry_sdk.init(
    dsn=os.environ.get('SENTRY_DSN'),
    integrations=[FlaskIntegration()],
    environment=os.environ.get('FLASK_ENV', 'production'),
    traces_sample_rate=0.1,  # Sample 10% of transactions
    release=os.environ.get('APP_VERSION', '1.0.0')
)

# Manual error capturing
try:
    # Risky operation
    result = risky_operation()
except Exception as e:
    sentry_sdk.capture_exception(e)
    app.logger.error(f"Error: {e}")

# User context for better error tracking
@app.before_request
def set_sentry_user():
    if current_user.is_authenticated:
        sentry_sdk.set_user({
            'id': current_user.id,
            'username': current_user.username,
            'email': current_user.email
        })
```

### Performance Monitoring

```python
from prometheus_client import Counter, Histogram, generate_latest, REGISTRY

# Define metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration', ['method', 'endpoint'])
ERROR_COUNT = Counter('http_errors_total', 'Total HTTP errors', ['method', 'endpoint'])

@app.before_request
def before_request():
    g.start_time = time.time()

@app.after_request
def after_request(response):
    duration = time.time() - g.start_time
    
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown'
    ).inc()
    
    REQUEST_DURATION.labels(
        method=request.method,
        endpoint=request.endpoint or 'unknown'
    ).observe(duration)
    
    if response.status_code >= 400:
        ERROR_COUNT.labels(
            method=request.method,
            endpoint=request.endpoint or 'unknown'
        ).inc()
    
    return response

@app.route('/metrics')
def metrics():
    return Response(generate_latest(REGISTRY), mimetype='text/plain')
```

---

## 9. Scaling Your Application

### Horizontal Scaling

```python
# Multiple application instances

# Gunicorn with multiple workers
workers = 4  # (2 * CPU cores) + 1

# Load balancer configuration
# Nginx upstream with multiple servers
upstream taskflow_app {
    server web1:8000;
    server web2:8000;
    server web3:8000;
    least_conn;  # Load balancing strategy
}

# Docker Compose scaling
docker-compose up -d --scale web=3
```

### Database Scaling

```python
# 1. Connection Pooling
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 20,
    'max_overflow': 40,
    'pool_recycle': 3600,
    'pool_pre_ping': True,
}

# 2. Read Replicas
SQLALCHEMY_BINDS = {
    'master': 'postgresql://...',
    'replica1': 'postgresql://...',
    'replica2': 'postgresql://...',
}

# 3. Database Partitioning
# Partition tasks table by month
# CREATE TABLE tasks PARTITION BY RANGE (created_at);

# 4. Query Optimization
# Add indexes
class Task(db.Model):
    __table_args__ = (
        Index('idx_tasks_user_status', 'user_id', 'status'),
        Index('idx_tasks_due_date', 'due_date'),
    )
```

### Caching Strategy

```python
from flask_caching import Cache

# Redis cache
cache = Cache(app, config={
    'CACHE_TYPE': 'redis',
    'CACHE_REDIS_URL': 'redis://localhost:6379/2',
    'CACHE_DEFAULT_TIMEOUT': 300,
})

# Cache view functions
@app.route('/api/tasks')
@cache.cached(timeout=300, query_string=True)
def list_tasks():
    return jsonify([task.to_dict() for task in Task.query.all()])

# Cache function results
@cache.memoize(timeout=600)
def get_user_stats(user_id):
    return compute_user_stats(user_id)

# Invalidate cache on updates
@app.route('/api/tasks', methods=['POST'])
def create_task():
    task = Task(**request.json)
    db.session.add(task)
    db.session.commit()
    
    # Invalidate cache
    cache.delete('list_tasks')
    cache.delete_memoized(get_user_stats, task.user_id)
    
    return jsonify(task.to_dict()), 201
```

---

## 10. DevOps Best Practices

### Infrastructure as Code

```terraform
# terraform/main.tf

provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "taskflow" {
  cidr_block = "10.0.0.0/16"
}

# Subnets
resource "aws_subnet" "taskflow" {
  count             = 2
  vpc_id            = aws_vpc.taskflow.id
  cidr_block        = cidrsubnet(aws_vpc.taskflow.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

# Security Group
resource "aws_security_group" "taskflow" {
  name        = "taskflow-sg"
  description = "TaskFlow security group"
  vpc_id      = aws_vpc.taskflow.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance
resource "aws_db_instance" "taskflow" {
  identifier     = "taskflow"
  engine         = "postgres"
  engine_version = "15.3"
  instance_class = "db.t3.medium"
  allocated_storage = 100
  
  db_name  = "taskflow"
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.taskflow.id]
  db_subnet_group_name   = aws_db_subnet_group.taskflow.name
  
  backup_retention_period = 30
  backup_window         = "03:00-04:00"
  maintenance_window    = "sun:04:00-sun:05:00"
}

# EC2 Instances
resource "aws_instance" "taskflow" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  key_name      = var.key_name
  
  vpc_security_group_ids = [aws_security_group.taskflow.id]
  subnet_id              = aws_subnet.taskflow[count.index].id
  
  tags = {
    Name = "taskflow-web-${count.index}"
  }
}
```

### Blue-Green Deployment

```bash
#!/bin/bash
# blue-green-deploy.sh

# Deploy to green environment
docker-compose -f docker-compose.green.yml up -d

# Wait for health check
sleep 30
curl -f http://localhost:8001/health || exit 1

# Switch traffic from blue to green
docker-compose -f docker-compose.blue.yml down
docker-compose -f docker-compose.green.yml down

# Update load balancer
# Update Nginx upstream to point to green
```

### Rollback Strategy

```bash
#!/bin/bash
# rollback.sh

# Check if previous version exists
if [ ! -d "../taskflow_previous" ]; then
    echo "No previous version to rollback to"
    exit 1
fi

# Stop current version
docker-compose down

# Restore previous version
mv ../taskflow_previous/* .
docker-compose up -d

# Verify rollback
curl -f http://localhost:8000/health || exit 1

echo "✅ Rollback complete!"
```

---

## Summary

This primer has introduced you to production deployment and DevOps:

1. **Production Environment**: Different from development
2. **Production Stack**: Gunicorn, Nginx, PostgreSQL, Redis
3. **Preparation**: Configuration, environment variables
4. **Gunicorn & Nginx**: WSGI server and reverse proxy
5. **Docker**: Containerization for consistency
6. **Cloud Deployment**: Heroku, AWS, DigitalOcean, GCP
7. **CI/CD**: Automated testing and deployment
8. **Monitoring**: Health checks, logging, metrics
9. **Scaling**: Horizontal scaling, caching
10. **DevOps Best Practices**: IaC, blue-green, rollback

### Deployment Quick Reference

```bash
# Gunicorn
gunicorn -c gunicorn.conf.py app:app

# Docker
docker-compose up -d
docker-compose logs -f
docker-compose down

# Heroku
git push heroku main
heroku run flask db upgrade
heroku logs --tail

# AWS EC2
ssh -i key.pem ubuntu@ec2-ip
docker-compose up -d

# GitLab CI/CD
# Push to main triggers pipeline

# Monitoring
curl /health
tail -f logs/taskflow.log

# Scaling
docker-compose up -d --scale web=3
```

**Next Steps**:
- Deploy your application
- Set up monitoring
- Configure CI/CD
- Practice rollback procedures
- Implement security best practices
