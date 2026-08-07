# Appendix E: Deployment and DevOps Reference

## Welcome to Appendix E!

This appendix provides a comprehensive reference for deploying Django applications to production. You'll find everything from server setup to monitoring and maintenance.

---

## E.1: Server Setup Checklist

### Initial Server Setup (Ubuntu/Debian)

```bash
# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Create deployment user
sudo adduser deploy
sudo usermod -aG sudo deploy
su - deploy

# 3. Install essential packages
sudo apt install -y \
    python3-pip \
    python3-dev \
    python3-venv \
    build-essential \
    libpq-dev \
    nginx \
    postgresql \
    postgresql-contrib \
    redis-server \
    git \
    curl \
    htop \
    fail2ban \
    ufw

# 4. Configure firewall
sudo ufw allow 22/tcp      # SSH
sudo ufw allow 80/tcp      # HTTP
sudo ufw allow 443/tcp     # HTTPS
sudo ufw allow 5432/tcp    # PostgreSQL (if needed externally)
sudo ufw enable

# 5. Configure timezone
sudo timedatectl set-timezone UTC

# 6. Increase file limits
sudo nano /etc/security/limits.conf
# Add:
# deploy soft nofile 65536
# deploy hard nofile 65536

# 7. Configure swap (if needed)
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## E.2: PostgreSQL Setup

### Installation and Configuration

```bash
# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create database and user
sudo -u postgres psql

# In PostgreSQL shell:
CREATE DATABASE django_blog;
CREATE USER django_user WITH PASSWORD 'secure_password_here';
ALTER ROLE django_user SET client_encoding TO 'utf8';
ALTER ROLE django_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE django_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE django_blog TO django_user;
\q

# Configure PostgreSQL for production
sudo nano /etc/postgresql/16/main/postgresql.conf

# Update settings:
# max_connections = 200
# shared_buffers = 256MB
# effective_cache_size = 768MB
# maintenance_work_mem = 64MB
# checkpoint_completion_target = 0.9
# wal_buffers = 16MB
# default_statistics_target = 100
# random_page_cost = 1.1
# effective_io_concurrency = 200
# work_mem = 8MB
# min_wal_size = 1GB
# max_wal_size = 4GB

# Restart PostgreSQL
sudo systemctl restart postgresql

# Backup and restore
# Backup
pg_dump -U django_user django_blog > backup.sql

# Restore
psql -U django_user django_blog < backup.sql

# Scheduled backup (cron)
0 2 * * * pg_dump -U django_user django_blog > /backups/django_blog_$(date +\%Y\%m\%d).sql
```

---

## E.3: Redis Setup

### Installation and Configuration

```bash
# Install Redis
sudo apt install -y redis-server

# Configure Redis
sudo nano /etc/redis/redis.conf

# Update settings:
# maxmemory 256mb
# maxmemory-policy allkeys-lru
# appendonly yes
# appendfsync everysec

# Restart Redis
sudo systemctl restart redis-server
sudo systemctl enable redis-server

# Test Redis
redis-cli ping
# Should return: PONG

# Redis security
sudo nano /etc/redis/redis.conf
# Set requirepass your_redis_password
# Then restart redis
sudo systemctl restart redis-server

# Test with password
redis-cli -a your_redis_password ping
```

---

## E.4: Nginx Configuration

### Basic Configuration

**File: `/etc/nginx/sites-available/django_blog`**

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    
    # Redirect to HTTPS (if SSL configured)
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self' https: data: 'unsafe-inline' 'unsafe-eval';" always;
    
    # Logging
    access_log /var/log/nginx/django_blog_access.log;
    error_log /var/log/nginx/django_blog_error.log;
    
    # Root directory
    root /var/www/django_blog_project;
    
    # Static Files
    location /static/ {
        alias /var/www/django_blog_project/staticfiles/;
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # Media Files
    location /media/ {
        alias /var/www/django_blog_project/media/;
        expires 30d;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # Favicon
    location /favicon.ico {
        alias /var/www/django_blog_project/staticfiles/favicon.ico;
        access_log off;
    }
    
    # Robots.txt
    location /robots.txt {
        alias /var/www/django_blog_project/staticfiles/robots.txt;
        access_log off;
    }
    
    # Django Application
    location / {
        proxy_pass http://unix:/var/www/django_blog_project/django.sock;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_redirect off;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffering
        proxy_buffering off;
        
        # Headers for Django
        proxy_set_header X-Forwarded-Host $server_name;
    }
}
```

### Enable Site

```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/django_blog /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx
```

---

## E.5: Gunicorn Setup

### Gunicorn Configuration

**File: `/etc/systemd/system/gunicorn.service`**

```ini
[Unit]
Description=gunicorn daemon for Django Blog
After=network.target postgresql.service redis.service

[Service]
User=deploy
Group=www-data
WorkingDirectory=/var/www/django_blog_project
Environment="PATH=/var/www/django_blog_project/venv/bin"
Environment="DJANGO_SETTINGS_MODULE=config.settings"
EnvironmentFile=/var/www/django_blog_project/.env.production
ExecStart=/var/www/django_blog_project/venv/bin/gunicorn \
    --workers 4 \
    --threads 2 \
    --worker-class sync \
    --bind unix:/var/www/django_blog_project/django.sock \
    --config gunicorn.conf.py \
    config.wsgi:application
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### Enable Gunicorn

```bash
# Create log directory
sudo mkdir -p /var/log/gunicorn
sudo chown deploy:www-data /var/log/gunicorn

# Start and enable Gunicorn
sudo systemctl start gunicorn
sudo systemctl enable gunicorn

# Check status
sudo systemctl status gunicorn

# View logs
sudo journalctl -u gunicorn -f
```

---

## E.6: SSL Certificate with Let's Encrypt

### Installation and Setup

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal (certbot sets up automatically)
sudo systemctl status certbot.timer

# Manual renewal test
sudo certbot renew --dry-run

# If renewal fails, force renew
sudo certbot renew --force-renewal

# Check certificate status
sudo certbot certificates
```

---

## E.7: Docker Production Setup

### Docker Compose Production File

**File: `docker-compose.prod.yml`**

```yaml
version: '3.8'

services:
  db:
    image: postgres:16-alpine
    container_name: django_blog_db
    restart: always
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - django_network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  redis:
    image: redis:7-alpine
    container_name: django_blog_redis
    restart: always
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - django_network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  web:
    build: 
      context: .
      dockerfile: Dockerfile.prod
    image: django_blog:latest
    container_name: django_blog_web
    restart: always
    volumes:
      - ./media:/app/media
      - ./staticfiles:/app/staticfiles
      - ./logs:/app/logs
      - /etc/ssl:/etc/ssl:ro
    environment:
      - DJANGO_SETTINGS_MODULE=config.settings
    env_file:
      - .env.production
    environment:
      - DB_HOST=db
      - REDIS_URL=redis://:${REDIS_PASSWORD}@redis:6379/1
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - django_network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  nginx:
    image: nginx:alpine
    container_name: django_blog_nginx
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.prod.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/conf.d:/etc/nginx/conf.d:ro
      - ./staticfiles:/app/staticfiles:ro
      - ./media:/app/media:ro
      - ./ssl:/etc/ssl:ro
    depends_on:
      - web
    networks:
      - django_network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

volumes:
  postgres_data:
  redis_data:

networks:
  django_network:
    driver: bridge
```

### Dockerfile Production

**File: `Dockerfile.prod`**

```dockerfile
# Build stage
FROM python:3.14-slim-bookworm AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir gunicorn

# Final stage
FROM python:3.14-slim-bookworm

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    libwebp-dev \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN addgroup --system django && \
    adduser --system --group django

# Set work directory
WORKDIR /app

# Copy application
COPY --from=builder /usr/local/lib/python3.14/site-packages /usr/local/lib/python3.14/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY . .

# Create necessary directories
RUN mkdir -p /app/staticfiles /app/media /app/logs && \
    chown -R django:django /app

# Switch to non-root user
USER django

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health/ || exit 1

# Expose port
EXPOSE 8000

# Start Gunicorn
CMD ["gunicorn", "--config", "gunicorn.conf.py", "config.wsgi:application"]
```

---

## E.8: CI/CD Pipeline (GitHub Actions)

### Complete Workflow

**File: `.github/workflows/deploy.yml`**

```yaml
name: Deploy to Production

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: django_user
          POSTGRES_PASSWORD: test_password
          POSTGRES_DB: django_blog
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.14'
        cache: 'pip'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install flake8 black isort coverage
    
    - name: Lint with flake8
      run: |
        flake8 . --max-line-length=88 --extend-ignore=E203,W503
    
    - name: Check formatting with black
      run: |
        black --check .
    
    - name: Check imports with isort
      run: |
        isort --check-only --profile black .
    
    - name: Run tests with coverage
      env:
        DB_NAME: django_blog
        DB_USER: django_user
        DB_PASSWORD: test_password
        DB_HOST: localhost
        DB_PORT: 5432
        SECRET_KEY: test-secret-key
        DEBUG: False
      run: |
        coverage run manage.py test blog
        coverage report --fail-under=80
        coverage xml
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v4
      with:
        file: ./coverage.xml
        flags: unittests
    
    - name: Security check with bandit
      run: |
        pip install bandit
        bandit -r blog/ -f json -o bandit-report.json
    
    - name: Upload bandit report
      uses: actions/upload-artifact@v4
      with:
        name: bandit-report
        path: bandit-report.json

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
    
    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        file: Dockerfile.prod
        push: true
        tags: |
          ${{ secrets.DOCKER_USERNAME }}/django_blog:latest
          ${{ secrets.DOCKER_USERNAME }}/django_blog:${{ github.sha }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up SSH
      uses: webfactory/ssh-agent@v0.9.0
      with:
        ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
    
    - name: Add SSH known hosts
      run: |
        ssh-keyscan -H ${{ secrets.DEPLOY_HOST }} >> ~/.ssh/known_hosts
    
    - name: Deploy to server
      run: |
        ssh ${{ secrets.DEPLOY_USER }}@${{ secrets.DEPLOY_HOST }} << 'ENDSSH'
          cd /var/www/django_blog_project
          docker login -u ${{ secrets.DOCKER_USERNAME }} -p ${{ secrets.DOCKER_PASSWORD }}
          docker pull ${{ secrets.DOCKER_USERNAME }}/django_blog:latest
          docker compose -f docker-compose.prod.yml down
          docker compose -f docker-compose.prod.yml up -d
          docker system prune -f
        ENDSSH
    
    - name: Verify deployment
      run: |
        curl -f https://${{ secrets.DEPLOY_HOST }}/health/ || exit 1
    
    - name: Send deployment notification
      if: success()
      uses: actions/github-script@v7
      with:
        script: |
          const message = `✅ Deployment successful!\nEnvironment: Production\nVersion: ${context.sha}`;
          // Add Slack/Discord/Email notification here
```

---

## E.9: Monitoring and Logging

### Prometheus + Grafana Setup (Docker)

**File: `docker-compose.monitoring.yml`**

```yaml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    ports:
      - "9090:9090"
    restart: always
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/dashboards:/etc/grafana/dashboards
      - ./grafana/grafana.ini:/etc/grafana/grafana.ini
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    ports:
      - "3000:3000"
    restart: always
    networks:
      - monitoring
    depends_on:
      - prometheus

volumes:
  prometheus_data:
  grafana_data:

networks:
  monitoring:
    driver: bridge
```

### Prometheus Configuration

**File: `prometheus/prometheus.yml`**

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'django'
    static_configs:
      - targets: ['web:8000']
    metrics_path: '/metrics'
  
  - job_name: 'postgresql'
    static_configs:
      - targets: ['db:9187']
  
  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx:9113']
  
  - job_name: 'redis'
    static_configs:
      - targets: ['redis:9121']
```

---

## E.10: Backup and Recovery

### Database Backup Script

**File: `scripts/backup.py`**

```python
#!/usr/bin/env python
"""
Database backup script.
Run daily via cron: 0 2 * * * python /path/to/backup.py
"""

import os
import sys
import subprocess
from datetime import datetime
from pathlib import Path
from django.conf import settings

def backup_database():
    """Backup PostgreSQL database."""
    backup_dir = Path('/var/backups/django_blog')
    backup_dir.mkdir(parents=True, exist_ok=True)
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    backup_file = backup_dir / f'backup_{timestamp}.sql'
    
    # Get database settings
    db_settings = settings.DATABASES['default']
    
    # Build pg_dump command
    cmd = [
        'pg_dump',
        '-h', db_settings.get('HOST', 'localhost'),
        '-p', db_settings.get('PORT', '5432'),
        '-U', db_settings['USER'],
        '-d', db_settings['NAME'],
        '-F', 'c',  # Custom format (compressed)
        '-f', str(backup_file)
    ]
    
    # Set password environment
    env = os.environ.copy()
    env['PGPASSWORD'] = db_settings['PASSWORD']
    
    # Run backup
    try:
        subprocess.run(cmd, env=env, check=True)
        print(f"Backup created: {backup_file}")
        
        # Delete backups older than 7 days
        for backup in backup_dir.glob('backup_*.sql'):
            if backup.stat().st_mtime < (datetime.now().timestamp() - 7 * 24 * 60 * 60):
                backup.unlink()
                print(f"Deleted old backup: {backup}")
        
        return True
    except subprocess.CalledProcessError as e:
        print(f"Backup failed: {e}")
        return False

def restore_database(backup_file):
    """Restore PostgreSQL database from backup."""
    db_settings = settings.DATABASES['default']
    
    cmd = [
        'pg_restore',
        '-h', db_settings.get('HOST', 'localhost'),
        '-p', db_settings.get('PORT', '5432'),
        '-U', db_settings['USER'],
        '-d', db_settings['NAME'],
        '--clean',  # Clean before restore
        '--if-exists',
        str(backup_file)
    ]
    
    env = os.environ.copy()
    env['PGPASSWORD'] = db_settings['PASSWORD']
    
    try:
        subprocess.run(cmd, env=env, check=True)
        print(f"Restored: {backup_file}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Restore failed: {e}")
        return False

if __name__ == '__main__':
    backup_database()
```

### Backup Cron Jobs

```bash
# Edit crontab
crontab -e

# Daily database backup at 2 AM
0 2 * * * /var/www/django_blog_project/venv/bin/python /var/www/django_blog_project/scripts/backup.py

# Weekly media files backup (tar.gz)
0 3 * * 0 tar -czf /backups/media_$(date +\%Y\%m\%d).tar.gz /var/www/django_blog_project/media/

# Monthly full backup
0 4 1 * * tar -czf /backups/full_$(date +\%Y\%m).tar.gz /var/www/django_blog_project/

# Cleanup old backups (keep 30 days)
0 5 * * * find /backups -name "*.sql" -mtime +30 -delete
```

---

## E.11: Error Tracking (Sentry)

### Sentry Setup

```python
# config/settings.py

import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration
from sentry_sdk.integrations.redis import RedisIntegration

if not DEBUG:
    sentry_sdk.init(
        dsn=os.environ.get('SENTRY_DSN'),
        integrations=[
            DjangoIntegration(),
            RedisIntegration(),
        ],
        traces_sample_rate=0.1,
        send_default_pii=False,
        environment=os.environ.get('ENVIRONMENT', 'production'),
        release=os.environ.get('RELEASE', '1.0.0'),
    )
```

### Manual Error Reporting

```python
# In views.py
import sentry_sdk

def my_view(request):
    try:
        # Do something risky
        result = risky_operation()
    except Exception as e:
        # Report to Sentry
        sentry_sdk.capture_exception(e)
        
        # Add context
        with sentry_sdk.configure_scope() as scope:
            scope.set_tag('view', 'my_view')
            scope.set_extra('user_id', request.user.id)
        
        # Return friendly error page
        return render(request, 'error.html', {'error': str(e)})
```

---

## E.12: Health Check Endpoint

### Django Health Check

**File: `blog/views.py`**

```python
from django.http import JsonResponse
from django.db import connection
from django.core.cache import cache
import time

def health_check(request):
    """Health check endpoint for monitoring."""
    status = {
        'status': 'healthy',
        'timestamp': time.time(),
        'checks': {}
    }
    
    # Check database
    try:
        with connection.cursor() as cursor:
            cursor.execute('SELECT 1')
        status['checks']['database'] = 'ok'
    except Exception as e:
        status['status'] = 'unhealthy'
        status['checks']['database'] = str(e)
    
    # Check cache
    try:
        cache.set('health_check', 'ok', timeout=5)
        if cache.get('health_check') != 'ok':
            raise Exception('Cache write/read failed')
        status['checks']['cache'] = 'ok'
    except Exception as e:
        status['status'] = 'unhealthy'
        status['checks']['cache'] = str(e)
    
    # Check disk space
    import shutil
    try:
        total, used, free = shutil.disk_usage('/')
        status['checks']['disk'] = {
            'free_mb': free // (1024 * 1024),
            'used_percent': (used / total) * 100
        }
    except Exception as e:
        status['checks']['disk'] = str(e)
    
    return JsonResponse(status)
```

### Nginx Health Check

```nginx
# In nginx configuration
location /health/ {
    proxy_pass http://unix:/var/www/django_blog_project/django.sock;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    
    # Return 503 if unhealthy
    proxy_intercept_errors on;
    error_page 502 503 504 = @unhealthy;
}

location @unhealthy {
    return 503 '{"status": "unhealthy"}';
    add_header Content-Type application/json;
}
```

---

## E.13: Performance Monitoring

### Django Debug Toolbar (Production)

```python
# config/settings.py

if DEBUG:
    # Debug toolbar in development
    INSTALLED_APPS += ['debug_toolbar']
    MIDDLEWARE.insert(0, 'debug_toolbar.middleware.DebugToolbarMiddleware')
else:
    # Production performance monitoring
    MIDDLEWARE.insert(0, 'blog.middleware.PerformanceMiddleware')
```

**File: `blog/middleware.py`**

```python
import time
import logging
from django.db import connection

logger = logging.getLogger(__name__)

class PerformanceMiddleware:
    """Monitor and log request performance."""
    
    def __init__(self, get_response):
        self.get_response = get_response
    
    def __call__(self, request):
        # Start timing
        start_time = time.time()
        
        # Clear query log
        connection.queries_log.clear()
        
        # Process request
        response = self.get_response(request)
        
        # Calculate duration
        duration = time.time() - start_time
        
        # Log slow requests
        if duration > 1.0:  # 1 second
            logger.warning(
                f"Slow request: {request.path} "
                f"Duration: {duration:.3f}s "
                f"User: {request.user.username if request.user.is_authenticated else 'Anonymous'}"
            )
        
        # Log high query count
        query_count = len(connection.queries)
        if query_count > 10:
            logger.warning(
                f"High query count: {request.path} "
                f"Queries: {query_count} "
                f"User: {request.user.username if request.user.is_authenticated else 'Anonymous'}"
            )
        
        # Add timing header
        response['X-Response-Time'] = f"{duration:.3f}s"
        
        return response
```

---

## E.14: Server Maintenance Commands

### Daily Maintenance Tasks

```bash
# 1. Check disk space
df -h

# 2. Check memory usage
free -h
htop

# 3. Check logs
tail -f /var/log/nginx/error.log
tail -f /var/log/gunicorn/gunicorn.log
sudo journalctl -u gunicorn -f

# 4. Check PostgreSQL
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity;"

# 5. Check Redis
redis-cli info

# 6. Check SSL certificate
sudo certbot certificates

# 7. Update system
sudo apt update
sudo apt upgrade -y

# 8. Clean Docker
docker system prune -a -f
docker volume prune -f

# 9. Restart services (if needed)
sudo systemctl restart nginx
sudo systemctl restart gunicorn
sudo systemctl restart postgresql
sudo systemctl restart redis

# 10. Check application health
curl -f https://yourdomain.com/health/
```

### Emergency Recovery

```bash
# 1. Check service status
sudo systemctl status nginx
sudo systemctl status gunicorn
sudo systemctl status postgresql
sudo systemctl status redis

# 2. View recent errors
sudo journalctl -u gunicorn -n 50
sudo journalctl -u nginx -n 50

# 3. Restart services
sudo systemctl restart gunicorn

# 4. Restore database (if needed)
sudo -u postgres pg_restore -d django_blog /backups/backup_latest.sql

# 5. Clear cache
redis-cli flushall

# 6. Collect static files
python manage.py collectstatic --noinput

# 7. Run migrations
python manage.py migrate --noinput
```

---

This appendix provides everything you need for deploying and maintaining Django applications in production. Use it as your DevOps reference guide!
