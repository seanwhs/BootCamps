# Primer 5: Flask Deployment Primer

Welcome to Primer 5! This foundational primer is designed for beginners who want to understand how to deploy their Flask applications to production. Building on the basics from Primers 1-4, you'll learn how to take your application from your local computer to the internet where users can access it.

---

## Table of Contents

1. [Why Deployment Matters](#1-why-deployment-matters)
2. [Understanding Deployment Options](#2-understanding-deployment-options)
3. [Preparing Your Application for Production](#3-preparing-your-application-for-production)
4. [Deployment with Gunicorn & Nginx](#4-deployment-with-gunicorn--nginx)
5. [Deployment with Docker](#5-deployment-with-docker)
6. [Deployment to the Cloud](#6-deployment-to-the-cloud)
7. [Environment Variables & Secrets](#7-environment-variables--secrets)
8. [Database Configuration](#8-database-configuration)
9. [Monitoring & Logging](#9-monitoring--logging)
10. [Maintenance & Updates](#10-maintenance--updates)

---

## 1. Why Deployment Matters

### The Problem: Local Development

```python
# Development mode (not suitable for production)
if __name__ == '__main__':
    app.run(debug=True)  # ❌ Not for production!

# Problems with development server:
# - Single-threaded (can only handle one request at a time)
# - Debug mode exposes sensitive information
# - Not secure (no HTTPS, no authentication)
# - No load balancing
# - Crashes can't be recovered
# - Logs go to console only
# - No process management
```

### Development vs Production

| Aspect | Development | Production |
|--------|-------------|------------|
| **Server** | Flask built-in | Gunicorn, uWSGI |
| **Debug** | Enabled | Disabled |
| **Speed** | Slow (reloads) | Optimized |
| **Security** | Minimal | Maximum |
| **Database** | SQLite (local) | PostgreSQL |
| **HTTPS** | No | Yes |
| **Users** | 1 developer | Many users |
| **Logs** | Console | File/Cloud |

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
│                   Nginx (Reverse Proxy)                     │
│  - Handles HTTPS                                            │
│  - Serves static files                                      │
│  - Load balancing                                           │
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

---

## 2. Understanding Deployment Options

### Deployment Options Comparison

```yaml
# 1. Platform as a Service (PaaS)
# - Heroku, PythonAnywhere, Google App Engine
# - Easiest option
# - Managed infrastructure
# - Limited customization
# - Good for: Beginners, small apps

# 2. Virtual Private Server (VPS)
# - DigitalOcean, AWS EC2, Linode
# - Full control
# - More complex setup
# - You manage everything
# - Good for: Learning, custom requirements

# 3. Containerization
# - Docker, Kubernetes
# - Consistent environment
# - Easy scaling
# - More complex
# - Good for: Microservices, complex apps

# 4. Serverless
# - AWS Lambda, Google Cloud Functions
# - Pay per use
# - Auto-scaling
# - Cold starts
# - Good for: APIs, event-driven apps
```

### Choosing Your Deployment Option

```python
# Decision tree for deployment

def choose_deployment_option(project_size, budget, control_needed):
    if project_size == 'small' and budget == 'low':
        return 'Heroku (PaaS)'
    elif project_size == 'medium' and control_needed == 'high':
        return 'VPS (DigitalOcean)'
    elif project_size == 'large' and budget == 'high':
        return 'AWS with Docker'
    elif project_size == 'huge' and control_needed == 'very_high':
        return 'Kubernetes'
    else:
        return 'Start with Heroku, scale as needed'

# For beginners: Start with Heroku or PythonAnywhere
# For learning: Use a VPS (DigitalOcean) for full control
# For serious projects: Use Docker + AWS
```

---

## 3. Preparing Your Application for Production

### Production-Ready Checklist

```python
# 1. Configuration
app.config.update({
    'DEBUG': False,           # Disable debug mode
    'TESTING': False,         # Disable testing mode
    'SECRET_KEY': os.environ.get('SECRET_KEY'),  # Environment variable
    'SESSION_COOKIE_SECURE': True,  # HTTPS only
    'SESSION_COOKIE_HTTPONLY': True,  # No JavaScript access
    'SESSION_COOKIE_SAMESITE': 'Strict',  # CSRF protection
})

# 2. Database
# Use PostgreSQL in production (not SQLite)
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL')

# 3. Logging
# Set up proper logging
import logging
logging.basicConfig(level=logging.INFO)

# 4. Error Handling
# Don't expose stack traces

# 5. Static Files
# Use CDN or Nginx for static files
```

### Environment Separation

```python
# config.py - Different configurations for different environments

import os
from pathlib import Path

class Config:
    """Base configuration."""
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-key-change-in-production')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
class DevelopmentConfig(Config):
    DEBUG = True
    TESTING = False
    SQLALCHEMY_DATABASE_URI = 'sqlite:///dev.db'
    SESSION_COOKIE_SECURE = False

class TestingConfig(Config):
    DEBUG = False
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    SESSION_COOKIE_SECURE = False

class ProductionConfig(Config):
    DEBUG = False
    TESTING = False
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL')
    SESSION_COOKIE_SECURE = True
    SESSION_COOKIE_HTTPONLY = True
    SESSION_COOKIE_SAMESITE = 'Strict'

# In app.py
from config import DevelopmentConfig, TestingConfig, ProductionConfig

env = os.environ.get('FLASK_ENV', 'development')
if env == 'production':
    app.config.from_object(ProductionConfig)
elif env == 'testing':
    app.config.from_object(TestingConfig)
else:
    app.config.from_object(DevelopmentConfig)
```

### Environment Variables

```bash
# .env (not committed to git)
SECRET_KEY=your-super-secret-key
DATABASE_URL=postgresql://user:password@localhost/dbname
FLASK_ENV=production
REDIS_URL=redis://localhost:6379/0
MAIL_SERVER=smtp.gmail.com
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# .env.example (committed to git)
SECRET_KEY=change-this
DATABASE_URL=postgresql://user:password@localhost/dbname
FLASK_ENV=development
# REDIS_URL=redis://localhost:6379/0
# MAIL_SERVER=smtp.gmail.com
```

---

## 4. Deployment with Gunicorn & Nginx

### Installing Gunicorn

```bash
# Install Gunicorn
pip install gunicorn

# Test Gunicorn locally
gunicorn app:app

# With custom settings
gunicorn --workers=4 --bind=0.0.0.0:8000 app:app
```

### Gunicorn Configuration

```python
# gunicorn.conf.py

import os
import multiprocessing

# Bind to port
bind = os.environ.get('GUNICORN_BIND', '0.0.0.0:8000')

# Workers (2 * CPU cores + 1)
workers = multiprocessing.cpu_count() * 2 + 1

# Worker class (sync, gevent, eventlet)
worker_class = 'sync'

# Threads per worker
threads = 2

# Timeout
timeout = 120

# Logging
accesslog = '-'
errorlog = '-'
loglevel = 'info'

# Preload app for better performance
preload_app = True

# Max requests before worker restart
max_requests = 1000
max_requests_jitter = 100

# Graceful timeout
graceful_timeout = 30

# Environment variables
raw_env = [
    f'FLASK_ENV=production',
    f'SECRET_KEY={os.environ.get("SECRET_KEY")}',
]
```

### Nginx Configuration

```nginx
# /etc/nginx/sites-available/taskflow

server {
    listen 80;
    server_name your-domain.com;
    
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Static files
    location /static/ {
        alias /var/www/taskflow/app/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # Uploads
    location /uploads/ {
        alias /var/www/taskflow/app/static/uploads/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}

# Enable site
sudo ln -s /etc/nginx/sites-available/taskflow /etc/nginx/sites-enabled/
sudo nginx -t  # Test configuration
sudo systemctl restart nginx
```

### Process Management with Supervisor

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

[group:taskflow]
programs=taskflow
```

### Complete Production Setup Script

```bash
#!/bin/bash
# deploy.sh - Complete deployment script

set -e

echo "🚀 Starting deployment..."

# 1. Pull latest code
echo "📦 Pulling latest code..."
git pull origin main

# 2. Install dependencies
echo "📦 Installing dependencies..."
source venv/bin/activate
pip install -r requirements.txt

# 3. Run migrations
echo "🗄️ Running migrations..."
flask db upgrade

# 4. Build static files
echo "🎨 Building static files..."
flask assets build

# 5. Restart application
echo "🔄 Restarting application..."
sudo supervisorctl restart taskflow

# 6. Verify deployment
echo "✅ Verifying deployment..."
curl -f http://localhost:8000/health

echo "🎉 Deployment complete!"
```

---

## 5. Deployment with Docker

### Dockerfile

```dockerfile
# Dockerfile

FROM python:3.13-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create non-root user
RUN adduser --disabled-password --no-create-home appuser
USER appuser

# Expose port
EXPOSE 8000

# Run with Gunicorn
CMD ["gunicorn", "-c", "gunicorn.conf.py", "app:app"]
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
      - REDIS_URL=redis://redis:6379/0
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
  
  nginx:
    image: nginx:1.25-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./static:/app/static:ro
      - ./uploads:/app/uploads:ro
    depends_on:
      - web

volumes:
  postgres_data:
```

### Build and Deploy with Docker

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# Run migrations
docker-compose exec web flask db upgrade

# Check logs
docker-compose logs -f

# Stop services
docker-compose down

# Update application
git pull
docker-compose build web
docker-compose up -d web

# Full rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

---

## 6. Deployment to the Cloud

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
```

### Deploying to DigitalOcean

```bash
# Create Droplet (Ubuntu)

# SSH into droplet
ssh root@your-server-ip

# Update system
apt update && apt upgrade -y

# Install dependencies
apt install -y python3-pip python3-venv nginx postgresql redis

# Clone repository
git clone https://github.com/yourusername/taskflow.git
cd taskflow

# Create virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Set up PostgreSQL
sudo -u postgres createdb taskflow
sudo -u postgres psql -c "CREATE USER taskflow WITH PASSWORD 'password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE taskflow TO taskflow;"

# Run migrations
flask db upgrade

# Set up Gunicorn with systemd
# Create /etc/systemd/system/taskflow.service

[Unit]
Description=Gunicorn instance to serve TaskFlow
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/taskflow
Environment="PATH=/var/www/taskflow/venv/bin"
Environment="FLASK_ENV=production"
ExecStart=/var/www/taskflow/venv/bin/gunicorn --workers 3 --bind unix:taskflow.sock -m 007 app:app

[Install]
WantedBy=multi-user.target

# Start service
sudo systemctl start taskflow
sudo systemctl enable taskflow

# Configure Nginx
# (Use the Nginx configuration from section 4)

# Restart Nginx
sudo systemctl restart nginx
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
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

---

## 7. Environment Variables & Secrets

### Managing Secrets in Production

```python
# Using python-dotenv for development
from dotenv import load_dotenv
load_dotenv()

# Using environment variables in production
import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY')
    DATABASE_URL = os.environ.get('DATABASE_URL')
    
    @classmethod
    def init_app(cls, app):
        # Validate critical variables
        if not cls.SECRET_KEY:
            raise ValueError("SECRET_KEY must be set!")
        if not cls.DATABASE_URL:
            raise ValueError("DATABASE_URL must be set!")

# Using AWS Secrets Manager
import boto3
import json

def get_secret(secret_name):
    session = boto3.session.Session()
    client = session.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

# In production config
secrets = get_secret('taskflow/production')
app.config['SECRET_KEY'] = secrets['SECRET_KEY']
app.config['DATABASE_URL'] = secrets['DATABASE_URL']
```

### Secure Environment Variable Management

```bash
# Never commit secrets to git!

# .gitignore (always include)
.env
.env.local
.env.*.local
*.key
*.pem
secrets.json

# Use secret managers:
# - Heroku: heroku config:set KEY=value
# - AWS: AWS Secrets Manager
# - Google Cloud: Secret Manager
# - HashiCorp Vault: For enterprise

# Example: Using AWS CLI
aws secretsmanager create-secret \
    --name taskflow/production \
    --secret-string '{"SECRET_KEY":"key","DATABASE_URL":"postgresql://..."}'
```

---

## 8. Database Configuration

### PostgreSQL Production Setup

```sql
-- Create database
CREATE DATABASE taskflow;

-- Create user
CREATE USER taskflow WITH PASSWORD 'secure-password';

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE taskflow TO taskflow;

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Optimize for performance
ALTER SYSTEM SET max_connections = 100;
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '768MB';
ALTER SYSTEM SET work_mem = '16MB';
ALTER SYSTEM SET maintenance_work_mem = '128MB';
```

### Database Migration in Production

```bash
# Run migrations
flask db upgrade

# Rollback if needed
flask db downgrade -1

# Check current version
flask db current

# Backup before migration
pg_dump -U taskflow -d taskflow > backup.sql

# Safe migration
# 1. Backup database
# 2. Run migrations
# 3. Verify app works
# 4. Rollback if issues
```

### Database Backup Strategy

```bash
#!/bin/bash
# backup.sh - Daily database backup

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/var/backups/taskflow"
BACKUP_FILE="$BACKUP_DIR/taskflow_$DATE.sql.gz"

# Create backup
pg_dump -U taskflow -d taskflow | gzip > $BACKUP_FILE

# Keep last 30 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete

# Upload to S3 (optional)
aws s3 cp $BACKUP_FILE s3://taskflow-backups/
```

---

## 9. Monitoring & Logging

### Application Logging

```python
import logging
from logging.handlers import RotatingFileHandler

# Production logging setup
def setup_production_logging(app):
    # Remove default handlers
    app.logger.handlers.clear()
    
    # File handler with rotation
    file_handler = RotatingFileHandler(
        'logs/taskflow.log',
        maxBytes=10*1024*1024,  # 10MB
        backupCount=5
    )
    file_handler.setLevel(logging.INFO)
    
    # Format
    formatter = logging.Formatter(
        '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
    )
    file_handler.setFormatter(formatter)
    
    app.logger.addHandler(file_handler)
    app.logger.setLevel(logging.INFO)
    
    # Log startup
    app.logger.info('Application started')

# Request logging
@app.before_request
def log_request():
    app.logger.info(f"Request: {request.method} {request.path}")

@app.after_request
def log_response(response):
    app.logger.info(f"Response: {response.status_code}")
    return response
```

### Health Check Endpoint

```python
@app.route('/health')
def health_check():
    """Health check endpoint for monitoring."""
    # Check database
    db_healthy = True
    try:
        db.session.execute('SELECT 1')
    except Exception:
        db_healthy = False
    
    return jsonify({
        'status': 'healthy' if db_healthy else 'unhealthy',
        'database': 'connected' if db_healthy else 'disconnected',
        'timestamp': datetime.utcnow().isoformat()
    }), 200 if db_healthy else 503
```

### Monitoring Tools

```python
# 1. Application Performance Monitoring (APM)
# - New Relic, Datadog, Sentry

# 2. Server Monitoring
# - Prometheus + Grafana
# - AWS CloudWatch
# - DigitalOcean Monitoring

# 3. Log Management
# - ELK Stack (Elasticsearch, Logstash, Kibana)
# - Papertrail
# - Loggly

# 4. Uptime Monitoring
# - UptimeRobot
# - Pingdom
# - StatusCake

# Example: Sentry for error tracking
import sentry_sdk
from sentry_sdk.integrations.flask import FlaskIntegration

sentry_sdk.init(
    dsn="your-sentry-dsn",
    integrations=[FlaskIntegration()],
    environment=os.environ.get('FLASK_ENV', 'development'),
    traces_sample_rate=1.0
)
```

---

## 10. Maintenance & Updates

### Zero-Downtime Deployment

```python
# Use blue-green deployment strategy

# 1. Deploy new version alongside old
# 2. Test new version
# 3. Switch traffic to new version
# 4. If issues, switch back

# Example with Nginx upstream
upstream taskflow {
    server app1:8000 weight=1;
    server app2:8000 weight=1;
}

# With Docker Compose (rolling update)
docker-compose up -d --no-deps --build web
docker-compose restart web
```

### Rollback Strategy

```bash
#!/bin/bash
# rollback.sh - Rollback to previous version

# 1. Revert code
git revert HEAD

# 2. Rebuild Docker
docker-compose build --no-cache web

# 3. Restart
docker-compose up -d web

# 4. Rollback database
flask db downgrade

# Alternative: Use previous Docker image
docker tag taskflow:previous taskflow:latest
docker-compose up -d web
```

### Maintenance Checklist

```yaml
# Daily Checks
- [ ] Check application logs
- [ ] Check error rates
- [ ] Check database connections
- [ ] Check disk space

# Weekly Checks
- [ ] Check SSL certificate expiry
- [ ] Review security logs
- [ ] Check for updates
- [ ] Review performance metrics

# Monthly Checks
- [ ] Rotate logs
- [ ] Clean old backups
- [ ] Apply security patches
- [ ] Review user feedback

# Before Deployment
- [ ] Run all tests
- [ ] Check migrations
- [ ] Update dependencies
- [ ] Verify backups
- [ ] Create rollback plan
```

---

## Summary

This primer has introduced you to deploying Flask applications:

1. **Deployment Options**: PaaS, VPS, Docker, Serverless
2. **Production Preparation**: Configuration, environment separation
3. **Gunicorn & Nginx**: Production WSGI server
4. **Docker**: Containerization for consistency
5. **Cloud Platforms**: Heroku, DigitalOcean, AWS
6. **Environment Variables**: Managing secrets
7. **Database Configuration**: PostgreSQL setup and backups
8. **Monitoring & Logging**: Keeping track of your app
9. **Maintenance**: Updates and rollbacks

### Deployment Checklist

```yaml
Pre-deployment:
  - [ ] Run all tests: pytest
  - [ ] Check migrations: flask db upgrade
  - [ ] Update dependencies: pip install -r requirements.txt
  - [ ] Build static files
  - [ ] Set DEBUG=False
  - [ ] Check environment variables

Deployment:
  - [ ] Backup database
  - [ ] Pull/upload code
  - [ ] Install dependencies
  - [ ] Run migrations
  - [ ] Restart application
  - [ ] Verify health check

Post-deployment:
  - [ ] Check logs for errors
  - [ ] Monitor performance
  - [ ] Test critical features
  - [ ] Update documentation
```

### Quick Commands

```bash
# Development
python app.py
flask run
flask shell

# Deployment
gunicorn -c gunicorn.conf.py app:app
docker-compose up -d
heroku git push heroku main

# Maintenance
flask db upgrade
flask db downgrade
docker-compose logs -f
heroku logs --tail

# Monitoring
curl http://localhost:5000/health
tail -f logs/taskflow.log
supervisorctl status
```

**Next Steps**:
- Deploy a test application
- Set up monitoring
- Configure SSL certificate
- Implement continuous deployment
