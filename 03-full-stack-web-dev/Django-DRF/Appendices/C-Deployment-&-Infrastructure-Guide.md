# Appendix C: Deployment & Infrastructure Guide

## Complete Deployment Reference

Welcome to **Appendix C** of the Django REST Framework & Next.js 16 masterclass. This appendix provides comprehensive deployment guides, infrastructure configurations, and troubleshooting references for deploying your application to production.

---

## Section 1: Cloud Platform Guides

### 1.1 AWS Deployment (ECS/Fargate)

**Prerequisites:**
- AWS Account
- AWS CLI installed and configured
- Docker images in ECR

**Step 1: Create ECR Repositories**

```bash
# Create repository for backend
aws ecr create-repository --repository-name taskflow-backend

# Create repository for frontend
aws ecr create-repository --repository-name taskflow-frontend

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Tag and push images
docker tag taskflow-backend:latest $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/taskflow-backend:latest
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/taskflow-backend:latest
```

**Step 2: Create RDS Database**

```bash
# Create PostgreSQL instance
aws rds create-db-instance \
    --db-instance-identifier taskflow-db \
    --db-instance-class db.t3.medium \
    --engine postgres \
    --engine-version 15.4 \
    --master-username taskflow_user \
    --master-user-password YourSecurePassword123! \
    --allocated-storage 20 \
    --vpc-security-group-ids sg-12345678 \
    --db-name taskflow_db
```

**Step 3: Create ElastiCache Redis**

```bash
# Create Redis cluster
aws elasticache create-cache-cluster \
    --cache-cluster-id taskflow-redis \
    --cache-node-type cache.t3.micro \
    --engine redis \
    --num-cache-nodes 1 \
    --security-group-ids sg-12345678
```

**Step 4: Create ECS Cluster**

```bash
# Create ECS cluster
aws ecs create-cluster --cluster-name taskflow-cluster

# Register task definitions (see ECS task definitions below)
```

**ECS Task Definitions:**

**backend-task.json**
```json
{
    "family": "taskflow-backend",
    "networkMode": "awsvpc",
    "containerDefinitions": [
        {
            "name": "backend",
            "image": "$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/taskflow-backend:latest",
            "portMappings": [
                {
                    "containerPort": 8000,
                    "protocol": "tcp"
                }
            ],
            "environment": [
                {"name": "DATABASE_URL", "value": "postgresql://taskflow_user:YourSecurePassword123!@taskflow-db.xxxxxx.us-east-1.rds.amazonaws.com:5432/taskflow_db"},
                {"name": "REDIS_URL", "value": "redis://taskflow-redis.xxxxxx.ng.0001.use1.cache.amazonaws.com:6379/1"},
                {"name": "DJANGO_ENV", "value": "production"},
                {"name": "DEBUG", "value": "False"},
                {"name": "SECRET_KEY", "value": "your-production-secret-key"}
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/taskflow-backend",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "backend"
                }
            }
        }
    ],
    "requiresCompatibilities": ["FARGATE"],
    "cpu": "512",
    "memory": "1024"
}
```

---

### 1.2 Google Cloud Platform (Cloud Run)

**Prerequisites:**
- GCP Project
- gcloud CLI installed

**Step 1: Build and Push to Artifact Registry**

```bash
# Create Artifact Registry repository
gcloud artifacts repositories create taskflow \
    --repository-format=docker \
    --location=us-central1

# Configure Docker authentication
gcloud auth configure-docker us-central1-docker.pkg.dev

# Build and push images
docker build -t us-central1-docker.pkg.dev/$PROJECT_ID/taskflow/backend:latest ./backend
docker push us-central1-docker.pkg.dev/$PROJECT_ID/taskflow/backend:latest

docker build -t us-central1-docker.pkg.dev/$PROJECT_ID/taskflow/frontend:latest ./frontend
docker push us-central1-docker.pkg.dev/$PROJECT_ID/taskflow/frontend:latest
```

**Step 2: Deploy Backend to Cloud Run**

```bash
gcloud run deploy taskflow-backend \
    --image us-central1-docker.pkg.dev/$PROJECT_ID/taskflow/backend:latest \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --memory 1Gi \
    --cpu 1 \
    --set-env-vars "DATABASE_URL=postgresql://user:pass@/taskflow_db?host=/cloudsql/INSTANCE_CONNECTION_NAME" \
    --set-env-vars "DJANGO_ENV=production" \
    --set-env-vars "SECRET_KEY=your-secret-key" \
    --add-cloudsql-instances INSTANCE_CONNECTION_NAME
```

**Step 3: Create Cloud SQL Instance**

```bash
# Create PostgreSQL instance
gcloud sql instances create taskflow-db \
    --database-version POSTGRES_15 \
    --tier db-f1-micro \
    --region us-central1

# Set password
gcloud sql users set-password postgres \
    --instance taskflow-db \
    --password YourSecurePassword123!

# Create database
gcloud sql databases create taskflow_db --instance taskflow-db
```

**Step 4: Create Memorystore (Redis)**

```bash
# Create Redis instance
gcloud redis instances create taskflow-redis \
    --size=1 \
    --region=us-central1 \
    --redis-version=redis_7_0
```

---

### 1.3 Azure Deployment (Container Instances)

**Prerequisites:**
- Azure Subscription
- Azure CLI installed

**Step 1: Create Container Registry**

```bash
# Create resource group
az group create --name taskflow-rg --location eastus

# Create container registry
az acr create --resource-group taskflow-rg --name taskflowacr --sku Basic

# Login to ACR
az acr login --name taskflowacr

# Build and push images
az acr build --registry taskflowacr --image backend:latest ./backend
az acr build --registry taskflowacr --image frontend:latest ./frontend
```

**Step 2: Create PostgreSQL Database**

```bash
# Create PostgreSQL server
az postgres server create \
    --resource-group taskflow-rg \
    --name taskflow-db \
    --location eastus \
    --admin-user taskflow_user \
    --admin-password YourSecurePassword123! \
    --sku-name B_Gen5_1

# Create database
az postgres db create \
    --resource-group taskflow-rg \
    --server-name taskflow-db \
    --name taskflow_db
```

**Step 3: Deploy to Container Instances**

```bash
# Deploy backend
az container create \
    --resource-group taskflow-rg \
    --name taskflow-backend \
    --image taskflowacr.azurecr.io/backend:latest \
    --dns-name-label taskflow-backend \
    --ports 8000 \
    --environment-variables \
        DATABASE_URL="postgresql://taskflow_user:YourSecurePassword123!@taskflow-db.postgres.database.azure.com:5432/taskflow_db" \
        DJANGO_ENV="production" \
        SECRET_KEY="your-secret-key"
```

---

## Section 2: SSL/TLS Configuration

### 2.1 Let's Encrypt with Certbot

**Install Certbot:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install certbot python3-certbot-nginx

# RHEL/CentOS
sudo yum install certbot python3-certbot-nginx
```

**Generate Certificate:**
```bash
# For Nginx
sudo certbot --nginx -d api.taskflow.com -d app.taskflow.com

# For standalone (without Nginx)
sudo certbot certonly --standalone -d api.taskflow.com

# Auto-renewal
sudo certbot renew --dry-run
```

**Manual Renewal Script:**
```bash
#!/bin/bash
# /etc/cron.daily/ssl-renewal

certbot renew --quiet
nginx -s reload
```

---

### 2.2 Cloudflare SSL

**Step 1: Configure DNS**
- Add domain to Cloudflare
- Update nameservers
- Set SSL/TLS encryption mode to "Full (strict)"

**Step 2: Origin Certificate**
```bash
# Generate origin certificate in Cloudflare dashboard
# Download certificate and private key

# Install on server
mkdir -p /etc/nginx/ssl
cp origin-cert.pem /etc/nginx/ssl/
cp origin-key.pem /etc/nginx/ssl/
chmod 600 /etc/nginx/ssl/*.pem
```

**Nginx Configuration:**
```nginx
server {
    listen 443 ssl http2;
    server_name api.taskflow.com;
    
    ssl_certificate /etc/nginx/ssl/origin-cert.pem;
    ssl_certificate_key /etc/nginx/ssl/origin-key.pem;
    ssl_client_certificate /etc/nginx/ssl/origin-cert.pem;
    ssl_verify_client off;
    
    # ... rest of configuration
}
```

---

## Section 3: CI/CD Pipeline Examples

### 3.1 GitLab CI

**.gitlab-ci.yml:**
```yaml
stages:
  - test
  - build
  - deploy

variables:
  DOCKER_IMAGE_BACKEND: $CI_REGISTRY_IMAGE/backend
  DOCKER_IMAGE_FRONTEND: $CI_REGISTRY_IMAGE/frontend

test-backend:
  stage: test
  image: python:3.12
  script:
    - cd backend
    - pip install -r requirements/development.txt
    - pytest --cov=apps
  services:
    - postgres:15-alpine
    - redis:7-alpine

test-frontend:
  stage: test
  image: node:20
  script:
    - cd frontend
    - npm ci
    - npm run test

build-backend:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $DOCKER_IMAGE_BACKEND:$CI_COMMIT_SHORT_SHA ./backend
    - docker push $DOCKER_IMAGE_BACKEND:$CI_COMMIT_SHORT_SHA

deploy-production:
  stage: deploy
  script:
    - ssh $PRODUCTION_HOST "cd /app && docker-compose pull && docker-compose up -d"
  only:
    - main
```

---

### 3.2 Jenkins Pipeline

**Jenkinsfile:**
```groovy
pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'registry.example.com'
        DOCKER_IMAGE_BACKEND = "${DOCKER_REGISTRY}/taskflow-backend"
        DOCKER_IMAGE_FRONTEND = "${DOCKER_REGISTRY}/taskflow-frontend"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Test Backend') {
            steps {
                dir('backend') {
                    sh '''
                        python -m venv venv
                        . venv/bin/activate
                        pip install -r requirements/development.txt
                        pytest --cov=apps
                    '''
                }
            }
        }
        
        stage('Test Frontend') {
            steps {
                dir('frontend') {
                    sh '''
                        npm ci
                        npm run test
                    '''
                }
            }
        }
        
        stage('Build Backend Image') {
            steps {
                script {
                    sh """
                        docker build -t ${env.DOCKER_IMAGE_BACKEND}:${env.BUILD_ID} ./backend
                        docker push ${env.DOCKER_IMAGE_BACKEND}:${env.BUILD_ID}
                    """
                }
            }
        }
        
        stage('Build Frontend Image') {
            steps {
                script {
                    sh """
                        docker build -t ${env.DOCKER_IMAGE_FRONTEND}:${env.BUILD_ID} ./frontend
                        docker push ${env.DOCKER_IMAGE_FRONTEND}:${env.BUILD_ID}
                    """
                }
            }
        }
        
        stage('Deploy') {
            when { branch 'main' }
            steps {
                sh '''
                    ssh production-server "
                        cd /app
                        docker-compose down
                        docker-compose pull
                        docker-compose up -d
                    "
                '''
            }
        }
    }
}
```

---

## Section 4: Monitoring & Alerting

### 4.1 Prometheus AlertManager Configuration

**alertmanager.yml:**
```yaml
route:
  group_by: ['alertname', 'cluster']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  receiver: 'default'

receivers:
  - name: 'default'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/xxx'
        channel: '#alerts'
        send_resolved: true
        title: '{{ .GroupLabels.alertname }}'
        text: |
          {{ range .Alerts }}
          *Alert:* {{ .Annotations.summary }}
          *Description:* {{ .Annotations.description }}
          *Severity:* {{ .Labels.severity }}
          {{ end }}

  - name: 'pagerduty'
    pagerduty_configs:
      - service_key: 'your-pagerduty-key'

  - name: 'email'
    email_configs:
      - to: 'team@taskflow.com'
        from: 'alerts@taskflow.com'
        smarthost: 'smtp.gmail.com:587'
        auth_username: 'alerts@taskflow.com'
        auth_password: 'app-password'
```

### 4.2 Log Aggregation with ELK

**docker-compose ELK stack:**
```yaml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

  logstash:
    image: docker.elastic.co/logstash/logstash:8.10.0
    volumes:
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
    ports:
      - "5000:5000"
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.10.0
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch

volumes:
  elasticsearch_data:
```

**logstash.conf:**
```ruby
input {
  gelf {
    port => 12201
  }
}

filter {
  json {
    source => "message"
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "taskflow-logs-%{+YYYY.MM.dd}"
  }
}
```

---

## Section 5: Database Backup & Recovery

### 5.1 Automated Backup Script

**backup.sh:**
```bash
#!/bin/bash

# Database backup script
BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/taskflow_$TIMESTAMP.sql.gz"

# Create backup
docker-compose exec -T db pg_dump -U taskflow_user taskflow_db | gzip > $BACKUP_FILE

# Upload to S3 (AWS)
aws s3 cp $BACKUP_FILE s3://taskflow-backups/

# Upload to GCS (GCP)
gsutil cp $BACKUP_FILE gs://taskflow-backups/

# Cleanup old backups
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

# Send notification
curl -X POST $SLACK_WEBHOOK_URL \
    -H "Content-Type: application/json" \
    -d "{\"text\": \"✅ Database backup completed: $BACKUP_FILE\"}"
```

### 5.2 Recovery Script

**restore.sh:**
```bash
#!/bin/bash

# Database restore script
RESTORE_FILE=$1

if [ -z "$RESTORE_FILE" ]; then
    echo "Usage: ./restore.sh <backup-file>"
    exit 1
fi

# Stop application
docker-compose down

# Drop and recreate database
docker-compose exec -T db psql -U taskflow_user -c "DROP DATABASE IF EXISTS taskflow_db;"
docker-compose exec -T db psql -U taskflow_user -c "CREATE DATABASE taskflow_db;"

# Restore backup
gunzip -c $RESTORE_FILE | docker-compose exec -T db psql -U taskflow_user taskflow_db

# Run migrations
docker-compose exec backend python manage.py migrate

# Start application
docker-compose up -d

# Send notification
curl -X POST $SLACK_WEBHOOK_URL \
    -H "Content-Type: application/json" \
    -d "{\"text\": \"✅ Database restored from: $RESTORE_FILE\"}"
```

---

## Section 6: Troubleshooting Guide

### 6.1 Common Issues and Solutions

**Issue: Container Won't Start**

```bash
# Check logs
docker-compose logs backend

# Common causes:
# - Environment variables missing
# - Database not ready
# - Port conflicts

# Solution:
# 1. Check .env file
# 2. Wait for database to be healthy
# 3. Check port availability
```

**Issue: Database Connection Error**

```bash
# Test connection
docker-compose exec db psql -U taskflow_user -c "SELECT 1"

# Check connection string
echo $DATABASE_URL

# Common fixes:
# - Verify credentials
# - Check network connectivity
# - Ensure database is running
# - Check connection pool limits
```

**Issue: Slow Performance**

```bash
# Check query performance
docker-compose exec backend python manage.py shell -c "
from django.db import connection
print(connection.queries)
"

# Check indexes
docker-compose exec db psql -U taskflow_user -c "SELECT * FROM pg_stat_user_indexes;"

# Common fixes:
# - Add missing indexes
# - Optimize queries
# - Increase resources
# - Enable caching
```

**Issue: 502 Bad Gateway**

```bash
# Check if services are running
docker-compose ps

# Check Nginx logs
docker-compose logs nginx

# Common causes:
# - Backend or frontend not running
# - Timeout issues
# - Port mismatches

# Solution:
# - Restart services
# - Increase timeout settings
# - Verify port mappings
```

### 6.2 Health Check Commands

```bash
# Check all services
docker-compose ps

# Check backend health
curl http://localhost:8000/health/

# Check frontend health
curl http://localhost:3000/api/health

# Check database
docker-compose exec db pg_isready -U taskflow_user

# Check Redis
docker-compose exec redis redis-cli ping

# Check Nginx
curl -I http://localhost/nginx-health
```

### 6.3 Log Analysis Commands

```bash
# View all logs
docker-compose logs -f

# View backend logs
docker-compose logs -f backend

# View frontend logs
docker-compose logs -f frontend

# View Nginx logs
docker-compose logs -f nginx

# Filter logs by error
docker-compose logs backend | grep ERROR

# Export logs
docker-compose logs > logs_$(date +%Y%m%d).txt

# Follow logs with timestamp
docker-compose logs -f --timestamps

# View last 100 lines
docker-compose logs --tail=100 backend
```

---

## Section 7: Security Checklist

### Pre-Deployment Security Audit

- [ ] All sensitive data in environment variables
- [ ] SECRET_KEY is secure and not in code
- [ ] DEBUG is False
- [ ] ALLOWED_HOSTS is configured
- [ ] CORS_ALLOWED_ORIGINS is restricted
- [ ] Database password is secure
- [ ] Redis password is set
- [ ] SSL/TLS is configured
- [ ] Security headers are enabled
- [ ] Rate limiting is configured
- [ ] Logging does not expose sensitive data
- [ ] Container runs as non-root user
- [ ] Docker images are scanned for vulnerabilities
- [ ] Backups are configured
- [ ] Monitoring is set up

---

## Section 8: Performance Tuning

### Django Settings

```python
# Production performance settings
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': REDIS_URL,
        'OPTIONS': {
            'CONNECTION_POOL_CLASS': 'redis.BlockingConnectionPool',
            'CONNECTION_POOL_CLASS_KWARGS': {
                'max_connections': 50,
                'timeout': 20,
            },
        }
    }
}

# Database connection pooling
DATABASES['default']['CONN_MAX_AGE'] = 600
DATABASES['default']['CONN_HEALTH_CHECKS'] = True

# Static files
STATICFILES_STORAGE = 'django.contrib.staticfiles.storage.ManifestStaticFilesStorage'

# Template caching
TEMPLATES[0]['OPTIONS']['loaders'] = [
    ('django.template.loaders.cached.Loader', [
        'django.template.loaders.filesystem.Loader',
        'django.template.loaders.app_directories.Loader',
    ]),
]
```

### Gunicorn Settings

```python
# gunicorn.conf.py
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = 'sync'
worker_connections = 1000
timeout = 30
max_requests = 1000
max_requests_jitter = 100
preload_app = True  # Preload application code
```

### Nginx Performance Tuning

```nginx
# In nginx.conf
worker_processes auto;
worker_rlimit_nofile 65535;

# Event settings
events {
    worker_connections 4096;
    use epoll;
    multi_accept on;
}

# HTTP settings
sendfile on;
tcp_nopush on;
tcp_nodelay on;
keepalive_timeout 65;
keepalive_requests 100;
```

---

*This concludes Appendix C. Use this guide as your comprehensive reference for deploying and maintaining your TaskFlow application in production.*
