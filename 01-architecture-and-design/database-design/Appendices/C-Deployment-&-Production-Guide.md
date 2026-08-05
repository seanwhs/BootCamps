# APPENDIX C — Deployment & Production Guide

## Taking ScaleCart to Production

---

## C.1 Introduction

This appendix provides comprehensive guidance for deploying ScaleCart to production environments. We'll cover:

1. **Infrastructure requirements** – Hardware, network, and security
2. **Cloud deployment** – AWS, GCP, and Azure configurations
3. **Kubernetes deployment** – Container orchestration
4. **CI/CD pipeline** – Automated testing and deployment
5. **Monitoring & alerting** – Production observability
6. **Scaling strategies** – Horizontal and vertical scaling
7. **Disaster recovery** – Backup and restoration procedures

---

## C.2 Infrastructure Requirements

### C.2.1 Minimum Production Specifications

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | 4 cores | 8+ cores |
| **RAM** | 16 GB | 32+ GB |
| **Storage** | 100 GB SSD | 500+ GB SSD |
| **Network** | 1 Gbps | 10 Gbps |
| **OS** | Ubuntu 22.04 LTS | Ubuntu 22.04 LTS |

### C.2.2 Database Server Specifications

| Metric | PostgreSQL | MongoDB | Neo4j | Redis |
|--------|------------|---------|-------|-------|
| **CPU** | 4+ cores | 2+ cores | 4+ cores | 2+ cores |
| **RAM** | 16+ GB | 8+ GB | 8+ GB | 4+ GB |
| **Storage** | 500+ GB SSD | 200+ GB SSD | 100+ GB SSD | 20+ GB SSD |
| **Disk IOPS** | 5000+ | 3000+ | 2000+ | 10000+ |

### C.2.3 Network Requirements

| Service | Port | Protocol | Access |
|---------|------|----------|--------|
| API | 443/80 | HTTPS/HTTP | Public |
| PostgreSQL | 5432 | TCP | Private subnet |
| MongoDB | 27017 | TCP | Private subnet |
| Redis | 6379 | TCP | Private subnet |
| Neo4j | 7687/7474 | TCP | Private subnet |
| Prometheus | 9090 | TCP | Internal |
| Grafana | 3000 | TCP | Internal/VPN |
| PgBouncer | 6432 | TCP | Private subnet |

---

## C.3 Cloud Deployment

### C.3.1 AWS Deployment

#### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    AWS Architecture                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────┐       │
│  │                     Route 53                         │       │
│  │              (DNS & Load Balancing)                  │       │
│  └─────────────────┬────────────────────────────────────┘       │
│                    │                                            │
│  ┌─────────────────▼────────────────────────────────────┐       │
│  │                  AWS WAF                            │       │
│  │           (Security & Rate Limiting)                │       │
│  └─────────────────┬────────────────────────────────────┘       │
│                    │                                            │
│  ┌─────────────────▼────────────────────────────────────┐       │
│  │             Application Load Balancer                │       │
│  └─────────┬──────────────────────────┬─────────────────┘       │
│            │                          │                         │
│  ┌─────────▼─────────┐    ┌───────────▼──────────┐             │
│  │    ECS Cluster    │    │    ECS Cluster       │             │
│  │   (API Service)   │    │  (Worker Service)    │             │
│  └───────────────────┘    └──────────────────────┘             │
│            │                          │                         │
│            └──────────┬───────────────┘                         │
│                       │                                         │
│  ┌────────────────────▼────────────────────────────────┐       │
│  │                  RDS PostgreSQL                     │       │
│  │            (Multi-AZ with Read Replica)             │       │
│  └────────────────────────────────────────────────────┘       │
│                                                                  │
│  ┌────────────────────────────────────────────────────┐       │
│  │                   ElastiCache Redis                │       │
│  │               (Cluster Mode Disabled)              │       │
│  └────────────────────────────────────────────────────┘       │
│                                                                  │
│  ┌────────────────────────────────────────────────────┐       │
│  │               DocumentDB (MongoDB)                 │       │
│  │              (3-node replica set)                  │       │
│  └────────────────────────────────────────────────────┘       │
│                                                                  │
│  ┌────────────────────────────────────────────────────┐       │
│  │                  S3 Buckets                        │       │
│  │        (Backups, Static Assets, Logs)              │       │
│  └────────────────────────────────────────────────────┘       │
│                                                                  │
│  ┌────────────────────────────────────────────────────┐       │
│  │                CloudWatch                          │       │
│  │      (Logs, Metrics, Alarms, Dashboards)           │       │
│  └────────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────────┘
```

#### Terraform Configuration

```hcl
# File: terraform/main.tf
provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "scalecart-vpc"
  }
}

# Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "scalecart-public-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "scalecart-private-${count.index}"
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier           = "scalecart-postgres"
  engine               = "postgres"
  engine_version       = "15.2"
  instance_class       = "db.r5.large"
  allocated_storage    = 500
  storage_type         = "gp3"
  storage_encrypted    = true
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  port                 = 5432
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  backup_retention_period = 30
  backup_window        = "03:00-04:00"
  maintenance_window   = "sun:04:00-sun:05:00"
  multi_az             = true
  skip_final_snapshot  = false
  final_snapshot_identifier = "scalecart-postgres-final-${formatdate("YYYYMMDD", timestamp())}"

  tags = {
    Name = "scalecart-postgres"
  }
}

# RDS Read Replica
resource "aws_db_instance" "postgres_replica" {
  identifier           = "scalecart-postgres-replica"
  replicate_source_db  = aws_db_instance.postgres.id
  instance_class       = "db.r5.large"
  availability_zone    = data.aws_availability_zones.available.names[1]
  backup_retention_period = 0
  skip_final_snapshot  = true

  tags = {
    Name = "scalecart-postgres-replica"
  }
}

# ElastiCache Redis
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "scalecart-redis"
  description          = "Redis cache for ScaleCart"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = "cache.r6g.large"
  port                 = 6379
  parameter_group_name = "default.redis7"
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.redis.id]
  automatic_failover_enabled = true
  multi_az_enabled     = true
  num_node_groups      = 1
  replicas_per_node_group = 1

  tags = {
    Name = "scalecart-redis"
  }
}

# S3 Backups Bucket
resource "aws_s3_bucket" "backups" {
  bucket = "scalecart-backups-${data.aws_caller_identity.current.account_id}"
  
  lifecycle_rule {
    enabled = true
    
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    
    expiration {
      days = 365
    }
  }
  
  versioning {
    enabled = true
  }
}

# Security Groups
resource "aws_security_group" "rds" {
  name   = "scalecart-rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
}

resource "aws_security_group" "redis" {
  name   = "scalecart-redis-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
}

resource "aws_security_group" "ecs" {
  name   = "scalecart-ecs-sg"
  vpc_id = aws_vpc.main.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### C.3.2 ECS Task Definition

```json
{
  "family": "scalecart-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "2048",
  "memory": "4096",
  "executionRoleArn": "arn:aws:iam::account:role/ecsExecutionRole",
  "taskRoleArn": "arn:aws:iam::account:role/ecsTaskRole",
  "containerDefinitions": [
    {
      "name": "api",
      "image": "account.dkr.ecr.region.amazonaws.com/scalecart:latest",
      "portMappings": [
        {
          "containerPort": 8000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {"name": "APP_ENV", "value": "production"},
        {"name": "DEBUG", "value": "false"},
        {"name": "LOG_LEVEL", "value": "INFO"}
      ],
      "secrets": [
        {"name": "DATABASE_URL", "valueFrom": "arn:aws:secretsmanager:region:account:secret:db-url"},
        {"name": "REDIS_URL", "valueFrom": "arn:aws:secretsmanager:region:account:secret:redis-url"},
        {"name": "MONGODB_URI", "valueFrom": "arn:aws:secretsmanager:region:account:secret:mongo-uri"},
        {"name": "NEO4J_URI", "valueFrom": "arn:aws:secretsmanager:region:account:secret:neo4j-uri"},
        {"name": "SECRET_KEY", "valueFrom": "arn:aws:secretsmanager:region:account:secret:secret-key"}
      ],
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/scalecart",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "api"
        }
      }
    }
  ]
}
```

### C.3.3 ECS Service

```hcl
resource "aws_ecs_service" "api" {
  name            = "scalecart-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = 3
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets         = aws_subnet.private[*].id
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "api"
    container_port   = 8000
  }
  
  deployment_controller {
    type = "ECS"
  }
  
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  
  health_check_grace_period_seconds = 60
  
  lifecycle {
    ignore_changes = [desired_count]
  }
}
```

---

## C.4 Kubernetes Deployment

### C.4.1 Kubernetes Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌────────────────────────────────────────────────────┐        │
│  │                Ingress Controller                  │        │
│  │           (NGINX / AWS ALB Ingress)               │        │
│  └─────────────────┬──────────────────────────────────┘        │
│                    │                                           │
│  ┌─────────────────▼──────────────────────────────────┐        │
│  │             API Service (3 replicas)               │        │
│  │     ┌──────────┬──────────┬──────────┐            │        │
│  │     │  Pod 1   │  Pod 2   │  Pod 3   │            │        │
│  │     └──────────┴──────────┴──────────┘            │        │
│  └────────────────────────────────────────────────────┘        │
│                    │                                           │
│  ┌─────────────────▼──────────────────────────────────┐        │
│  │             Worker Service (2 replicas)             │        │
│  │     ┌──────────────────┬──────────────────┐        │        │
│  │     │  Pod 1           │  Pod 2           │        │        │
│  │     └──────────────────┴──────────────────┘        │        │
│  └────────────────────────────────────────────────────┘        │
│                    │                                           │
│  ┌─────────────────▼──────────────────────────────────┐        │
│  │             StatefulSets                           │        │
│  │  ┌────────────┬────────────┬────────────┐        │        │
│  │  │ PostgreSQL │  MongoDB   │   Redis    │        │        │
│  │  │  (HA)      │   (RS)     │   (Sentinel)│        │        │
│  │  └────────────┴────────────┴────────────┘        │        │
│  └────────────────────────────────────────────────────┘        │
│                                                                  │
│  ┌────────────────────────────────────────────────────┐        │
│  │              Monitoring Stack                      │        │
│  │  ┌────────────────┬────────────────────┐          │        │
│  │  │  Prometheus    │    Grafana         │          │        │
│  │  └────────────────┴────────────────────┘          │        │
│  └────────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

### C.4.2 Kubernetes Manifests

#### Namespace

```yaml
# File: k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: scalecart
  labels:
    name: scalecart
    environment: production
```

#### ConfigMap

```yaml
# File: k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: scalecart-config
  namespace: scalecart
data:
  APP_ENV: "production"
  DEBUG: "false"
  LOG_LEVEL: "INFO"
  API_PREFIX: "/api/v1"
  ALLOWED_HOSTS: "api.scalecart.com"
  DB_POOL_SIZE: "20"
  DB_MAX_OVERFLOW: "40"
  PRODUCT_CACHE_TTL: "3600"
  SESSION_TTL: "86400"
  ENABLE_CACHING: "true"
  ENABLE_GRAPH_RECOMMENDATIONS: "true"
  ENABLE_VECTOR_SEARCH: "true"
  ENABLE_METRICS: "true"
```

#### Secrets (Using External Secrets Operator)

```yaml
# File: k8s/secrets.yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: scalecart-secrets
  namespace: scalecart
spec:
  refreshInterval: "1h"
  secretStoreRef:
    name: aws-secretsmanager
    kind: SecretStore
  target:
    name: scalecart-secrets
    creationPolicy: Owner
  data:
    - secretKey: database_url
      remoteRef:
        key: scalecart/prod/database
        property: url
    - secretKey: redis_url
      remoteRef:
        key: scalecart/prod/redis
        property: url
    - secretKey: mongodb_uri
      remoteRef:
        key: scalecart/prod/mongodb
        property: uri
    - secretKey: neo4j_uri
      remoteRef:
        key: scalecart/prod/neo4j
        property: uri
    - secretKey: secret_key
      remoteRef:
        key: scalecart/prod/app
        property: secret_key
    - secretKey: openai_api_key
      remoteRef:
        key: scalecart/prod/openai
        property: api_key
```

#### API Deployment

```yaml
# File: k8s/api-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scalecart-api
  namespace: scalecart
  labels:
    app: scalecart
    component: api
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: scalecart
      component: api
  template:
    metadata:
      labels:
        app: scalecart
        component: api
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8000"
        prometheus.io/path: "/metrics"
    spec:
      containers:
        - name: api
          image: scalecart/api:latest
          imagePullPolicy: Always
          ports:
            - containerPort: 8000
              name: http
          env:
            - name: APP_ENV
              valueFrom:
                configMapKeyRef:
                  name: scalecart-config
                  key: APP_ENV
            - name: DEBUG
              valueFrom:
                configMapKeyRef:
                  name: scalecart-config
                  key: DEBUG
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: scalecart-config
                  key: LOG_LEVEL
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: database_url
            - name: REDIS_URL
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: redis_url
            - name: MONGODB_URI
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: mongodb_uri
            - name: NEO4J_URI
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: neo4j_uri
            - name: SECRET_KEY
              valueFrom:
                secretKeyRef:
                  name: scalecart-secrets
                  key: secret_key
          resources:
            requests:
              memory: "512Mi"
              cpu: "500m"
            limits:
              memory: "1Gi"
              cpu: "1000m"
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 8000
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 2
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: tmp
          emptyDir: {}
      nodeSelector:
        node-group: api
      tolerations:
        - key: api
          operator: Equal
          value: "true"
          effect: NoSchedule
```

#### API Service

```yaml
# File: k8s/api-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: scalecart-api
  namespace: scalecart
  labels:
    app: scalecart
    component: api
spec:
  selector:
    app: scalecart
    component: api
  ports:
    - port: 80
      targetPort: 8000
      protocol: TCP
      name: http
  type: ClusterIP
```

#### Ingress

```yaml
# File: k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: scalecart-ingress
  namespace: scalecart
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "60"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "60"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    nginx.ingress.kubernetes.io/rate-limit-burst: "150"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
    - hosts:
        - api.scalecart.com
      secretName: scalecart-tls
  rules:
    - host: api.scalecart.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: scalecart-api
                port:
                  number: 80
```

#### Horizontal Pod Autoscaler

```yaml
# File: k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: scalecart-api-hpa
  namespace: scalecart
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: scalecart-api
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
    - type: Pods
      pods:
        metric:
          name: requests_per_second
        target:
          type: AverageValue
          averageValue: "500"
```

---

## C.5 CI/CD Pipeline

### C.5.1 GitHub Actions Workflow

```yaml
# File: .github/workflows/deploy-prod.yaml
name: Deploy to Production

on:
  push:
    branches:
      - main
    paths:
      - 'src/**'
      - 'Dockerfile'
      - 'requirements*.txt'

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Cache dependencies
        uses: actions/cache@v3
        with:
          path: ~/.cache/pip
          key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov
      
      - name: Run tests
        run: |
          pytest --cov=src --cov-report=xml
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml

  build:
    needs: test
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
      id-token: write
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2
      
      - name: Log in to Container Registry
        uses: docker/login-action@v2
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v4
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=sha,format=long
            type=ref,event=branch
            type=raw,value=latest,enable={{is_default_branch}}
      
      - name: Build and push image
        uses: docker/build-push-action@v4
        with:
          context: .
          target: production
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      
      - name: Update ECS service
        run: |
          aws ecs update-service \
            --cluster scalecart-prod \
            --service scalecart-api \
            --task-definition $TASK_DEFINITION_ARN \
            --force-new-deployment
        env:
          TASK_DEFINITION_ARN: ${{ secrets.ECS_TASK_DEFINITION_ARN }}
      
      - name: Wait for deployment
        run: |
          aws ecs wait services-stable \
            --cluster scalecart-prod \
            --services scalecart-api
      
      - name: Run database migrations
        run: |
          aws ecs run-task \
            --cluster scalecart-prod \
            --task-definition ${{ secrets.ECS_MIGRATION_TASK_ARN }} \
            --overrides '{"containerOverrides":[{"name":"migrate","command":["alembic","upgrade","head"]}]}'

  smoke-test:
    needs: deploy
    runs-on: ubuntu-latest
    
    steps:
      - name: Run smoke tests
        run: |
          curl -f https://api.scalecart.com/health || exit 1
          curl -f https://api.scalecart.com/api/v1/products?limit=1 || exit 1
      
      - name: Notify on success
        if: success()
        uses: slackapi/slack-github-action@v1.24.0
        with:
          channel-id: 'deployments'
          slack-message: '✅ ScaleCart production deployed successfully'
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
      
      - name: Notify on failure
        if: failure()
        uses: slackapi/slack-github-action@v1.24.0
        with:
          channel-id: 'alerts'
          slack-message: '❌ ScaleCart production deployment failed'
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
```

---

## C.6 Monitoring & Alerting

### C.6.1 Prometheus Rules

```yaml
# File: prometheus-rules.yaml
groups:
  - name: scalecart-alerts
    rules:
      - alert: HighAPIErrorRate
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m])) / 
          sum(rate(http_requests_total[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High API error rate"
          description: "API error rate is {{ $value }}% for 5 minutes"

      - alert: DatabaseConnectionHigh
        expr: |
          pg_stat_database_numbackends > 80
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Database connections high"
          description: "{{ $value }} connections to PostgreSQL"

      - alert: RedisMemoryUsage
        expr: |
          redis_memory_used_bytes / redis_memory_max_bytes > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Redis memory usage high"
          description: "Redis using {{ $value }}% of memory"

      - alert: DeadlockCount
        expr: |
          increase(pg_stat_database_deadlocks[5m]) > 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Database deadlocks detected"
          description: "{{ $value }} deadlocks in last 5 minutes"

      - alert: SlowQueries
        expr: |
          increase(pg_stat_statements_mean_time{mean_time>5000}[5m]) > 10
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "Slow queries detected"
          description: "More than 10 queries > 5s in last 5 minutes"

      - alert: ReplicationLag
        expr: |
          pg_replication_lag_seconds > 60
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Database replication lag"
          description: "Replica is {{ $value }}s behind primary"

      - alert: ServiceDown
        expr: |
          up{job="api"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "{{ $labels.instance }} is unreachable"

      - alert: DiskSpaceLow
        expr: |
          node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"} < 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space low"
          description: "Only {{ $value }}% disk space remaining"
```

### C.6.2 Grafana Dashboard JSON

```json
{
  "dashboard": {
    "title": "ScaleCart Production Monitoring",
    "timezone": "browser",
    "panels": [
      {
        "title": "API Requests per Second",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[1m])",
            "legendFormat": "{{method}} {{path}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0}
      },
      {
        "title": "API Response Time (p95)",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "{{path}}"
          }
        ],
        "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0}
      },
      {
        "title": "Database Connections",
        "type": "stat",
        "targets": [
          {
            "expr": "pg_stat_database_numbackends",
            "legendFormat": "connections"
          }
        ],
        "gridPos": {"h": 4, "w": 4, "x": 0, "y": 8}
      },
      {
        "title": "Cache Hit Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "rate(redis_keyspace_hits_total[5m]) / (rate(redis_keyspace_hits_total[5m]) + rate(redis_keyspace_misses_total[5m])) * 100",
            "legendFormat": "hit rate"
          }
        ],
        "gridPos": {"h": 4, "w": 4, "x": 4, "y": 8}
      },
      {
        "title": "Active Users",
        "type": "stat",
        "targets": [
          {
            "expr": "sum(redis_db_keys{db='session'})",
            "legendFormat": "active sessions"
          }
        ],
        "gridPos": {"h": 4, "w": 4, "x": 8, "y": 8}
      }
    ]
  }
}
```

---

## C.7 Scaling Strategies

### C.7.1 Horizontal Scaling (API)

```yaml
# Auto-scaling based on custom metrics
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: scalecart-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: scalecart-api
  minReplicas: 3
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
    - type: Pods
      pods:
        metric:
          name: requests_per_second
        target:
          type: AverageValue
          averageValue: "500"
    - type: Pods
      pods:
        metric:
          name: queue_depth
        target:
          type: AverageValue
          averageValue: "1000"
```

### C.7.2 Database Scaling

```sql
-- Read replicas for analytics queries
CREATE TABLE orders_read_replica AS TABLE orders;

-- Table partitioning by date
CREATE TABLE orders_2026 PARTITION OF orders
    FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- Connection pooling with PgBouncer
-- Already configured in docker-compose.yml

-- Query optimization with pg_stat_statements
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    rows
FROM pg_stat_statements
ORDER BY total_time DESC
LIMIT 10;
```

### C.7.3 Cache Scaling

```python
# Redis Cluster configuration for horizontal scaling
import redis
from redis.cluster import RedisCluster

class RedisClusterManager:
    def __init__(self, startup_nodes):
        self.redis = RedisCluster(
            startup_nodes=startup_nodes,
            decode_responses=True,
            max_connections=100,
            retry_on_timeout=True
        )
    
    def get(self, key):
        return self.redis.get(key)
    
    def set(self, key, value, ttl=3600):
        self.redis.setex(key, ttl, value)
    
    def invalidate_pattern(self, pattern):
        for key in self.redis.scan_iter(pattern):
            self.redis.delete(key)
```

---

## C.8 Disaster Recovery

### C.8.1 Backup Automation

```bash
#!/bin/bash
# File: scripts/production-backup.sh

# Configuration
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
S3_BUCKET="scalecart-backups"
RETENTION_DAYS=30

# PostgreSQL backup
echo "Backing up PostgreSQL..."
pg_dump -U scalecart -h localhost scalecart \
    --clean \
    --if-exists \
    --format=custom \
    --file="$BACKUP_DIR/postgres_$DATE.dump"

# MongoDB backup
echo "Backing up MongoDB..."
mongodump \
    --uri="mongodb://scalecart:password@localhost:27017/scalecart" \
    --archive="$BACKUP_DIR/mongodb_$DATE.archive" \
    --gzip

# Redis backup (RDB)
echo "Backing up Redis..."
redis-cli -a password --rdb "$BACKUP_DIR/redis_$DATE.rdb"

# Neo4j backup
echo "Backing up Neo4j..."
neo4j-admin backup \
    --from=bolt://localhost:7687 \
    --backup-dir="$BACKUP_DIR/neo4j_$DATE"

# Upload to S3
echo "Uploading to S3..."
aws s3 sync "$BACKUP_DIR" "s3://$S3_BUCKET/$DATE/" \
    --exclude "*.tmp" \
    --storage-class STANDARD_IA

# Cleanup old backups
echo "Cleaning up old backups..."
find "$BACKUP_DIR" -name "*.dump" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "*.archive" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "*.rdb" -mtime +$RETENTION_DAYS -delete

# Delete old backups from S3 (30 days)
aws s3 ls "s3://$S3_BUCKET/" | \
    grep "PRE" | \
    awk '{print $2}' | \
    while read -r folder; do
        folder_date=$(echo $folder | sed 's/\/$//')
        if [[ $(date -d "$folder_date" +%s 2>/dev/null) -lt $(date -d "$RETENTION_DAYS days ago" +%s) ]]; then
            aws s3 rm "s3://$S3_BUCKET/$folder" --recursive
        fi
    done

echo "Backup completed: $DATE"
```

### C.8.2 Restoration Script

```bash
#!/bin/bash
# File: scripts/production-restore.sh

# Configuration
RESTORE_DATE=$1
S3_BUCKET="scalecart-backups"

if [ -z "$RESTORE_DATE" ]; then
    echo "Usage: $0 <YYYYMMDD_HHMMSS>"
    exit 1
fi

# Download backups
echo "Downloading backups from S3..."
aws s3 sync "s3://$S3_BUCKET/$RESTORE_DATE/" /restore/

# Stop application
echo "Stopping application..."
kubectl scale deployment scalecart-api --replicas=0 -n scalecart

# Restore PostgreSQL
echo "Restoring PostgreSQL..."
pg_restore -U scalecart -d scalecart --clean --if-exists /restore/postgres_$RESTORE_DATE.dump

# Restore MongoDB
echo "Restoring MongoDB..."
mongorestore --uri="mongodb://scalecart:password@localhost:27017/scalecart" \
    --archive=/restore/mongodb_$RESTORE_DATE.archive --gzip

# Restore Redis
echo "Restoring Redis..."
redis-cli -a password FLUSHALL
cat /restore/redis_$RESTORE_DATE.rdb | redis-cli -a password --pipe

# Restore Neo4j
echo "Restoring Neo4j..."
neo4j-admin restore --from=/restore/neo4j_$RESTORE_DATE

# Start application
echo "Starting application..."
kubectl scale deployment scalecart-api --replicas=3 -n scalecart

# Run health checks
echo "Running health checks..."
sleep 30
curl -f https://api.scalecart.com/health || exit 1

echo "Restoration completed successfully"
```

---

## C.9 Security Hardening Checklist

### C.9.1 Database Security

```sql
-- 1. Use strong passwords
ALTER USER scalecart WITH PASSWORD 'strong_password_here';

-- 2. Limit connections
ALTER SYSTEM SET max_connections = 100;

-- 3. Enable SSL
ALTER SYSTEM SET ssl = on;
ALTER SYSTEM SET ssl_cert_file = '/etc/ssl/certs/server.crt';
ALTER SYSTEM SET ssl_key_file = '/etc/ssl/private/server.key';

-- 4. Set password expiration
ALTER USER scalecart VALID UNTIL '2027-01-01';

-- 5. Revoke unnecessary privileges
REVOKE ALL ON DATABASE scalecart FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;

-- 6. Create read-only user for analytics
CREATE USER readonly WITH PASSWORD 'readonly_password';
GRANT CONNECT ON DATABASE scalecart TO readonly;
GRANT USAGE ON SCHEMA public TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;

-- 7. Enable row-level security
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
CREATE POLICY customer_access ON customers 
    USING (id = current_setting('app.current_customer_id')::INTEGER);
```

### C.9.2 Network Security

```yaml
# NetworkPolicy for Kubernetes
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: scalecart-network-policy
  namespace: scalecart
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: ingress-nginx
      ports:
        - port: 8000
  egress:
    - to:
        - namespaceSelector: {}
      ports:
        - port: 5432
        - port: 6379
        - port: 27017
        - port: 7687
    - to:
        - external:
            cidr: 0.0.0.0/0
      ports:
        - port: 443
        - port: 80
```

### C.9.3 Secrets Management

```yaml
# AWS Secrets Manager configuration
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: aws-secretsmanager
  namespace: scalecart
spec:
  provider:
    aws:
      service: SecretsManager
      region: us-east-1
      auth:
        jwt:
          serviceAccountRef:
            name: scalecart-sa
```

---

## C.10 Performance Tuning in Production

### C.10.1 PostgreSQL Tuning

```sql
-- File: postgresql-prod.conf
# Memory settings
shared_buffers = '4GB'
work_mem = '64MB'
maintenance_work_mem = '1GB'
effective_cache_size = '12GB'

# WAL settings
wal_buffers = '64MB'
checkpoint_completion_target = 0.9
max_wal_size = '20GB'
min_wal_size = '5GB'

# Query tuning
random_page_cost = 1.1
effective_io_concurrency = 200

# Connection settings
max_connections = 200
max_parallel_workers_per_gather = 4

# Autovacuum
autovacuum = on
autovacuum_vacuum_scale_factor = 0.05
autovacuum_analyze_scale_factor = 0.02

# Monitoring
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.track = all
```

### C.10.2 Application Tuning

```python
# File: src/utils/tuning.py
import os
from functools import lru_cache

# Connection pool configuration
DB_CONFIG = {
    'pool_size': int(os.getenv('DB_POOL_SIZE', 20)),
    'max_overflow': int(os.getenv('DB_MAX_OVERFLOW', 40)),
    'pool_pre_ping': True,
    'pool_recycle': 3600,
    'pool_timeout': 30
}

# Cache configuration
@lru_cache(maxsize=1024)
def get_expensive_data(product_id):
    """Cache expensive database queries"""
    return query_database(product_id)

# Query optimization
def optimize_product_query():
    return """
        SELECT id, name, price
        FROM products
        WHERE category_id = $1
          AND price BETWEEN $2 AND $3
        ORDER BY id
        LIMIT 100
    """

# Bulk insert optimization
def bulk_insert_orders(orders):
    # Use execute_values for bulk inserts
    from psycopg2.extras import execute_values
    
    with connection.cursor() as cur:
        execute_values(
            cur,
            """
            INSERT INTO orders (customer_id, total_amount, status)
            VALUES %s
            """,
            orders,
            page_size=1000
        )
```

---

## C.11 Go-Live Checklist

### Pre-Launch Verification

```markdown
# ScaleCart Production Go-Live Checklist

## Infrastructure
- [ ] All database instances running and healthy
- [ ] Load balancer configured and responding
- [ ] SSL certificates installed and valid
- [ ] Monitoring agents installed and reporting
- [ ] Backup system tested and scheduled

## Database
- [ ] Schema migrations applied to production
- [ ] Indexes created on all production tables
- [ ] Data integrity verified (foreign keys, constraints)
- [ ] Connection pooling configured
- [ ] Read replicas synchronized

## Application
- [ ] All environment variables set correctly
- [ ] Feature flags configured
- [ ] Logging to centralized system
- [ ] Metrics exposed to Prometheus
- [ ] Health endpoints accessible

## Security
- [ ] WAF configured with proper rules
- [ ] Rate limiting enabled
- [ ] Secrets stored securely (not in code)
- [ ] Network policies enforced
- [ ] Audit logging enabled

## Performance
- [ ] Query performance tested with production-like data
- [ ] Cache warming executed
- [ ] Load tested with expected traffic
- [ ] Auto-scaling configured

## Documentation
- [ ] Runbooks updated for all services
- [ ] On-call rotation configured
- [ ] Incident response plan documented
- [ ] API documentation deployed

## Monitoring
- [ ] Dashboards created for all services
- [ ] Alerts configured for critical metrics
- [ ] Synthetic monitoring set up
- [ ] Error tracking configured (Sentry, etc.)

## Rollback Plan
- [ ] Database rollback procedure documented
- [ ] Application rollback tested
- [ ] Backup restoration tested
- [ ] Feature flags for emergency rollback

## Post-Launch
- [ ] Canary deployment ready
- [ ] Smoke tests automated
- [ ] Performance baseline established
- [ ] Disaster recovery drill scheduled
```

---

**[END OF APPENDIX C]**

*This deployment guide provides comprehensive instructions for taking ScaleCart to production. Use it alongside the other appendices for complete production readiness.*
