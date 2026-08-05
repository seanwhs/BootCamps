# APPENDIX H — Complete Production Environment Setup & Deployment Walkthrough

## End-to-End Production Deployment Guide

---

## H.1 Introduction

This appendix provides a complete, step-by-step walkthrough for deploying ScaleCart to a production environment. Unlike the conceptual deployment discussions in Appendix C, this is a **practical, hands-on guide** that you can follow to actually deploy the system.

We'll cover:

1. **Provisioning Infrastructure** – Setting up cloud resources
2. **Database Setup** – Initializing and configuring databases
3. **Application Deployment** – Deploying the API and workers
4. **Monitoring Setup** – Configuring observability
5. **Security Hardening** – Production security configuration
6. **Validation** – Verifying the deployment

**Prerequisites:** You'll need:
- AWS/Azure/GCP account with billing enabled
- Docker and kubectl installed locally
- Domain name (optional but recommended)
- ~$100-200 budget for initial testing (can be scaled down)

---

## H.2 Option A: AWS ECS Fargate Deployment (Recommended)

This is the simplest path to production with minimal operational overhead.

### H.2.1 Prerequisites

```bash
# Install required tools
brew install awscli terraform kubectl
# or: apt-get install awscli terraform kubectl

# Configure AWS CLI
aws configure
# Enter: AWS Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)

# Verify
aws sts get-caller-identity
```

### H.2.2 Infrastructure Provisioning with Terraform

**Step 1: Create Terraform Configuration**

```hcl
# File: terraform/providers.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "scalecart-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# File: terraform/variables.tf
variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  default     = "production"
}

variable "project_name" {
  description = "Project name"
  default     = "scalecart"
}

# File: terraform/vpc.tf
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}

# Public subnets (for load balancer)
resource "aws_subnet" "public" {
  count = 2
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  map_public_ip_on_launch = true
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-public-${count.index}"
    Environment = var.environment
  }
}

# Private subnets (for databases and tasks)
resource "aws_subnet" "private" {
  count = 2
  
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-private-${count.index}"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count = 2
  
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway for private subnets
resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = {
    Name = "${var.project_name}-${var.environment}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  
  tags = {
    Name = "${var.project_name}-${var.environment}-nat"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  
  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count = 2
  
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security Groups
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-ecs-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "api" {
  name     = "${var.project_name}-${var.environment}-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 30
    path                = "/health"
    port                = "8000"
  }
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-tg"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

# RDS PostgreSQL
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet"
  subnet_ids = aws_subnet.private[*].id
  
  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet"
  }
}

resource "aws_db_instance" "postgres" {
  identifier           = "${var.project_name}-${var.environment}-postgres"
  engine               = "postgres"
  engine_version       = "15.5"
  instance_class       = "db.t3.medium"  # Change for production scale
  allocated_storage    = 100
  storage_type         = "gp3"
  storage_encrypted    = true
  db_name              = "scalecart"
  username             = "scalecart"
  password             = random_password.db_password.result
  port                 = 5432
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name = aws_db_subnet_group.main.name
  backup_retention_period = 30
  backup_window        = "03:00-04:00"
  maintenance_window   = "sun:04:00-sun:05:00"
  multi_az             = false  # Set true for production
  skip_final_snapshot  = false
  final_snapshot_identifier = "${var.project_name}-${var.environment}-final-snapshot"
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-postgres"
    Environment = var.environment
  }
}

# Random password for database
resource "random_password" "db_password" {
  length  = 24
  special = true
  override_special = "!@#$%^&*()_+"
}

# Secrets Manager for database credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project_name}/${var.environment}/database"
  
  tags = {
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "scalecart"
    password = random_password.db_password.result
    host     = aws_db_instance.postgres.address
    port     = aws_db_instance.postgres.port
    dbname   = "scalecart"
  })
}

# S3 Bucket for Backups
resource "aws_s3_bucket" "backups" {
  bucket = "${var.project_name}-${var.environment}-backups-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-backups"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id
  
  rule {
    id     = "transition-to-glacier"
    status = "Enabled"
    
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
}

# IAM Roles for ECS
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-${var.environment}-ecs-execution"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_secrets" {
  name = "${var.project_name}-${var.environment}-ecs-secrets"
  role = aws_iam_role.ecs_task_execution.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.db_credentials.arn
        ]
      }
    ]
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    Environment = var.environment
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 30
  
  tags = {
    Environment = var.environment
  }
}
```

**Step 2: Apply Terraform**

```bash
cd terraform

# Initialize Terraform
terraform init

# Plan the infrastructure
terraform plan -out=plan.out

# Apply the infrastructure
terraform apply plan.out

# Note the outputs
terraform output
```

### H.2.3 Build and Push Docker Image

```bash
# Build the production image
docker build --target production -t scalecart/api:latest .

# Tag for ECR
aws ecr create-repository --repository-name scalecart-api
# Note the repository URI from output

# Tag the image
docker tag scalecart/api:latest <your-ecr-repo-uri>:latest

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <your-aws-account-id>.dkr.ecr.us-east-1.amazonaws.com

# Push the image
docker push <your-ecr-repo-uri>:latest
```

### H.2.4 ECS Task Definition

```json
# File: ecs-task-definition.json
{
  "family": "scalecart-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "1024",
  "memory": "2048",
  "executionRoleArn": "<ecs-execution-role-arn>",
  "taskRoleArn": "<ecs-task-role-arn>",
  "containerDefinitions": [
    {
      "name": "api",
      "image": "<your-ecr-repo-uri>:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {"name": "APP_ENV", "value": "production"},
        {"name": "DEBUG", "value": "false"},
        {"name": "LOG_LEVEL", "value": "INFO"},
        {"name": "ALLOWED_HOSTS", "value": "api.scalecart.com"}
      ],
      "secrets": [
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:us-east-1:123456789012:secret:scalecart/production/database:password"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/scalecart-production",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "api"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 60
      }
    }
  ]
}
```

**Register the task definition:**

```bash
aws ecs register-task-definition --cli-input-json file://ecs-task-definition.json
```

### H.2.5 Deploy ECS Service

```bash
# Create the ECS service
aws ecs create-service \
  --cluster scalecart-production-cluster \
  --service-name scalecart-api \
  --task-definition scalecart-api \
  --desired-count 2 \
  --launch-type FARGATE \
  --platform-version LATEST \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-123,subnet-456],securityGroups=[sg-789],assignPublicIp=DISABLED}" \
  --load-balancers "targetGroupArn=<target-group-arn>,containerName=api,containerPort=8000"

# Wait for service to stabilize
aws ecs wait services-stable \
  --cluster scalecart-production-cluster \
  --services scalecart-api

# Check service status
aws ecs describe-services \
  --cluster scalecart-production-cluster \
  --services scalecart-api
```

### H.2.6 Database Migration

```bash
# Run migration task
aws ecs run-task \
  --cluster scalecart-production-cluster \
  --task-definition scalecart-api \
  --overrides '{"containerOverrides":[{"name":"api","command":["alembic","upgrade","head"]}]}'

# Check migration status
aws ecs list-tasks --cluster scalecart-production-cluster --desired-status RUNNING
```

---

## H.3 Option B: Kubernetes Deployment (GCP/Azure)

For those who prefer Kubernetes, here's a GCP deployment.

### H.3.1 GCP Setup

```bash
# Install gcloud CLI
brew install google-cloud-sdk

# Authenticate
gcloud auth login

# Set project
gcloud config set project scalecart-production

# Enable required services
gcloud services enable compute.googleapis.com container.googleapis.com \
  sqladmin.googleapis.com redis.googleapis.com monitoring.googleapis.com

# Create GKE cluster
gcloud container clusters create scalecart-cluster \
  --zone us-central1-a \
  --machine-type n2-standard-4 \
  --num-nodes 3 \
  --enable-autoscaling \
  --min-nodes 2 \
  --max-nodes 10 \
  --enable-autorepair \
  --enable-autoupgrade

# Get credentials
gcloud container clusters get-credentials scalecart-cluster --zone us-central1-a
```

### H.3.2 Deploy with Helm

```yaml
# File: helm/values.yaml
# ScaleCart Helm chart values

global:
  environment: production
  domain: api.scalecart.com

image:
  repository: gcr.io/scalecart-production/api
  tag: latest
  pullPolicy: Always

replicaCount: 3

resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "2000m"

database:
  postgresql:
    enabled: false
    external:
      host: "scalecart-postgres.private.cloudsql.goog"
      port: 5432
      database: scalecart
      username: scalecart
      existingSecret: postgresql-credentials

redis:
  enabled: true
  architecture: standalone
  auth:
    existingSecret: redis-credentials
  resources:
    requests:
      memory: "256Mi"
      cpu: "200m"
    limits:
      memory: "512Mi"
      cpu: "500m"

mongodb:
  enabled: true
  architecture: replicaset
  replicaSetNumber: 3
  auth:
    existingSecret: mongodb-credentials
  resources:
    requests:
      memory: "512Mi"
      cpu: "250m"
    limits:
      memory: "1Gi"
      cpu: "500m"

neo4j:
  enabled: true
  neo4jPassword: "scalecart_neo4j_password"
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: api.scalecart.com
      paths:
        - path: /
          pathType: Prefix

monitoring:
  enabled: true
  prometheus:
    enabled: true
  grafana:
    enabled: true
    adminPassword: "grafana-admin-password"

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
```

**Deploy with Helm:**

```bash
# Add the Helm chart
helm repo add scalecart https://charts.scalecart.com
helm repo update

# Deploy
helm install scalecart scalecart/scalecart \
  --namespace scalecart \
  --create-namespace \
  --values helm/values.yaml \
  --set database.postgresql.external.password=$(gcloud secrets versions access latest --secret=postgresql-password)

# Wait for deployment
kubectl wait --namespace scalecart \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/instance=scalecart \
  --timeout=300s
```

---

## H.4 Database Initialization & Seeding

### H.4.1 Initial Schema Setup

```sql
-- Run this on the production database
-- Connect to the database first

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "btree_gin";
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- Create schema (run the full schema.sql from Part 1)
-- You can pipe it directly:
-- psql -U scalecart -d scalecart < src/migrations/001_initial_schema.sql

-- Create admin user (for first login)
INSERT INTO customers (email, password_hash, full_name, is_verified, is_active)
VALUES (
    'admin@scalecart.com',
    -- This is a bcrypt hash of 'admin123!'
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8.LewY5UY2rUeZ5sX92',
    'System Administrator',
    true,
    true
);

-- Create initial categories
INSERT INTO categories (name) VALUES 
    ('Electronics'),
    ('Books'),
    ('Clothing'),
    ('Home & Garden'),
    ('Sports'),
    ('Toys');

-- Create initial products (a few to test)
INSERT INTO products (name, price, category_id) 
SELECT 
    'Test Product ' || generate_series,
    (random() * 1000)::numeric(10,2),
    (random() * 5 + 1)::int
FROM generate_series(1, 100);

-- Create inventory for initial products
INSERT INTO inventory (product_id, stock_quantity, reorder_threshold)
SELECT id, (random() * 100)::int, 10
FROM products;

-- Run migrations
-- alembic upgrade head
```

### H.4.2 Data Seeding

```bash
# If you have seed data, load it
# For production, only seed essential data

# Load essential reference data
psql -U scalecart -d scalecart -f init-scripts/04-seed-data.sql

# Generate test data (optional, for testing environment only)
# python src/scripts/generate_test_data.py --limit 10000

# Warm up caches
python src/scripts/warm_cache.py
```

---

## H.5 Monitoring & Observability Setup

### H.5.1 CloudWatch Dashboard (AWS)

```json
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ { "stat": "Average", "label": "API Latency" }, "AWS/ECS", "CPUUtilization" ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "CPU Utilization"
      }
    },
    {
      "type": "metric",
      "x": 12,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ { "stat": "Average" }, "AWS/ECS", "MemoryUtilization" ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Memory Utilization"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 6,
      "width": 24,
      "height": 6,
      "properties": {
        "metrics": [
          [ { "stat": "Sum", "label": "Request Count" }, "AWS/ApplicationELB", "RequestCount" ],
          [ ".", "TargetResponseTime", { "stat": "Average", "label": "Response Time" } ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "API Performance"
      }
    },
    {
      "type": "metric",
      "x": 0,
      "y": 12,
      "width": 24,
      "height": 6,
      "properties": {
        "metrics": [
          [ "AWS/RDS", "DatabaseConnections" ],
          [ ".", "FreeStorageSpace" ]
        ],
        "period": 300,
        "stat": "Average",
        "region": "us-east-1",
        "title": "Database Metrics"
      }
    }
  ]
}
```

### H.5.2 Prometheus & Grafana (Kubernetes)

```yaml
# File: monitoring/prometheus-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    
    scrape_configs:
      - job_name: 'kubernetes-pods'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
            action: replace
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            target_label: __address__
          
      - job_name: 'postgresql'
        static_configs:
          - targets: ['postgres-exporter:9187']
      
      - job_name: 'redis'
        static_configs:
          - targets: ['redis-exporter:9121']
      
      - job_name: 'mongodb'
        static_configs:
          - targets: ['mongodb-exporter:9216']
```

### H.5.3 Custom Health Checks

```python
# File: src/api/health.py (enhanced for production)
from fastapi import APIRouter, Depends
from src.utils.db import get_db
from src.services.health_service import HealthService

router = APIRouter(tags=["health"])

@router.get("/health")
async def health_check():
    """Basic health check."""
    return {"status": "healthy", "version": "1.0.0"}

@router.get("/health/ready")
async def readiness_check():
    """Readiness check for load balancer."""
    # Check if database is ready
    try:
        db = next(get_db())
        db.execute("SELECT 1")
        db_ready = True
    except Exception:
        db_ready = False
    
    return {
        "status": "ready" if db_ready else "not_ready",
        "checks": {
            "database": db_ready
        }
    }

@router.get("/health/live")
async def liveness_check():
    """Liveness check for container orchestration."""
    # Simple check - always returns ok if service is running
    return {"status": "alive"}

@router.get("/health/full")
async def full_health_check():
    """Comprehensive health check for monitoring."""
    service = HealthService()
    return await service.check_all_services()
```

---

## H.6 Security Hardening (Production)

### H.6.1 SSL/TLS Configuration

```bash
# Generate SSL certificate using Let's Encrypt (for Kubernetes)
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@scalecart.com
    privateKeySecretRef:
      name: letsencrypt-prod-key
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

# For AWS with ACM
aws acm request-certificate \
  --domain-name api.scalecart.com \
  --validation-method DNS \
  --subject-alternative-names api.scalecart.com \
  --region us-east-1
```

### H.6.2 WAF Configuration

```yaml
# File: waf-rules.json
{
  "Name": "scalecart-waf",
  "Rules": [
    {
      "Name": "SQLInjectionRule",
      "Priority": 0,
      "Statement": {
        "ManagedRuleGroupStatement": {
          "VendorName": "AWS",
          "Name": "AWSManagedRulesSQLInjectionRuleSet"
        }
      },
      "Action": { "Block": {} },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "SQLInjectionRule"
      }
    },
    {
      "Name": "RateLimitRule",
      "Priority": 1,
      "Statement": {
        "RateBasedStatement": {
          "Limit": 1000,
          "AggregateKeyType": "IP"
        }
      },
      "Action": { "Block": {} },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "RateLimitRule"
      }
    },
    {
      "Name": "BadInputsRule",
      "Priority": 2,
      "Statement": {
        "ManagedRuleGroupStatement": {
          "VendorName": "AWS",
          "Name": "AWSManagedRulesCommonRuleSet"
        }
      },
      "Action": { "Block": {} },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "BadInputsRule"
      }
    }
  ],
  "VisibilityConfig": {
    "SampledRequestsEnabled": true,
    "CloudWatchMetricsEnabled": true,
    "MetricName": "scalecart-waf"
  }
}
```

### H.6.3 Database Security Hardening

```sql
-- Production database security settings

-- 1. Create minimal-privilege users
CREATE USER api_user WITH PASSWORD 'strong_password';
GRANT CONNECT ON DATABASE scalecart TO api_user;
GRANT USAGE ON SCHEMA public TO api_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO api_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO api_user;

-- 2. Create read-only user for monitoring/analytics
CREATE USER readonly_user WITH PASSWORD 'readonly_password';
GRANT CONNECT ON DATABASE scalecart TO readonly_user;
GRANT USAGE ON SCHEMA public TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO readonly_user;

-- 3. Create admin user (only for emergency)
CREATE USER admin_user WITH PASSWORD 'admin_password' SUPERUSER;

-- 4. Revoke public permissions
REVOKE ALL ON DATABASE scalecart FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;

-- 5. Enable SSL
ALTER SYSTEM SET ssl = on;
ALTER SYSTEM SET ssl_cert_file = '/etc/ssl/certs/server.crt';
ALTER SYSTEM SET ssl_key_file = '/etc/ssl/private/server.key';
ALTER SYSTEM SET ssl_ca_file = '/etc/ssl/certs/ca.crt';

-- 6. Set connection limits
ALTER USER api_user CONNECTION LIMIT 100;
ALTER USER readonly_user CONNECTION LIMIT 20;

-- 7. Enable row-level security
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;

-- 8. Create audit trigger
CREATE OR REPLACE FUNCTION audit_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_log (
        table_name,
        record_id,
        action,
        old_data,
        new_data,
        changed_by,
        client_ip
    ) VALUES (
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        TG_OP,
        CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN row_to_json(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) ELSE NULL END,
        current_setting('app.current_user_id', true)::int,
        current_setting('app.client_ip', true)
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Apply audit triggers
CREATE TRIGGER audit_customers
    AFTER INSERT OR UPDATE OR DELETE ON customers
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_orders
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();

CREATE TRIGGER audit_payments
    AFTER INSERT OR UPDATE OR DELETE ON payments
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_function();
```

---

## H.7 Deployment Validation Checklist

### H.7.1 Smoke Tests

```bash
#!/bin/bash
# File: scripts/deployment-smoke-tests.sh

echo "🚀 Running deployment smoke tests..."

# Test base URL
BASE_URL="https://api.scalecart.com"

# 1. Health check
echo "1. Health check..."
curl -f $BASE_URL/health || exit 1

# 2. Readiness check
echo "2. Readiness check..."
curl -f $BASE_URL/health/ready || exit 1

# 3. API response
echo "3. API response..."
curl -f $BASE_URL/api/v1/products?limit=1 || exit 1

# 4. Database connection (via health check)
echo "4. Database connection..."
curl -f $BASE_URL/health/full | jq '.checks.database' | grep -q true || exit 1

# 5. Cache connection
echo "5. Cache connection..."
curl -f $BASE_URL/health/full | jq '.checks.cache' | grep -q true || exit 1

# 6. Authentication
echo "6. Authentication..."
TOKEN=$(curl -s -X POST $BASE_URL/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@scalecart.com","password":"admin123!"}' \
  | jq -r '.access_token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
    echo "❌ Authentication failed"
    exit 1
fi

# 7. Protected endpoint
echo "7. Protected endpoint..."
curl -f -H "Authorization: Bearer $TOKEN" $BASE_URL/api/v1/customers/me || exit 1

echo "✅ All smoke tests passed!"
```

### H.7.2 Performance Validation

```bash
# Run load test with vegeta
echo "GET https://api.scalecart.com/api/v1/products" | \
  vegeta attack -rate=50 -duration=60s | \
  vegeta report

# Check response times
# Should be < 100ms p95, < 200ms p99
```

### H.7.3 Security Validation

```bash
# Run security scan with OWASP ZAP
docker run -t owasp/zap2docker-stable zap-full-scan.py \
  -t https://api.scalecart.com \
  -r scan-report.html

# Check for SSL/TLS vulnerabilities
docker run --rm -t drwetter/testssl.sh \
  https://api.scalecart.com
```

---

## H.8 Production Deployment Checklist

```markdown
# Final Production Deployment Checklist

## Infrastructure
- [ ] VPC/Network configured with private subnets
- [ ] Load balancer configured with health checks
- [ ] Auto-scaling configured
- [ ] SSL certificate installed
- [ ] WAF rules applied
- [ ] DDoS protection enabled

## Databases
- [ ] PostgreSQL running with Multi-AZ
- [ ] Read replica configured
- [ ] Backup schedule configured (daily)
- [ ] Point-in-time recovery enabled
- [ ] Connection pooling configured (PgBouncer)
- [ ] MongoDB replica set configured
- [ ] Redis sentinel configured
- [ ] Neo4j cluster configured (if using enterprise)

## Application
- [ ] Container images built and pushed
- [ ] Environment variables configured
- [ ] Secrets stored in Secrets Manager
- [ ] Database migrations applied
- [ ] Caches warmed up
- [ ] Health checks configured
- [ ] Logging configured (to CloudWatch/ELK)
- [ ] Metrics exposed to Prometheus

## Monitoring
- [ ] Dashboards created (Grafana/CloudWatch)
- [ ] Alerts configured for critical metrics
- [ ] On-call rotation set up
- [ ] Incident response runbook created
- [ ] SLI/SLO defined

## Security
- [ ] WAF rules applied
- [ ] Rate limiting configured
- [ ] Security headers present
- [ ] SQL injection protection active
- [ ] No exposed secrets in code
- [ ] IAM roles least-privilege
- [ ] Security groups restricted
- [ ] Audit logging enabled
- [ ] GDPR compliance verified

## Disaster Recovery
- [ ] Daily backups confirmed working
- [ ] Restore procedure documented
- [ ] Disaster recovery drill performed
- [ ] Multi-region failover considered
- [ ] Backup retention policy defined

## Documentation
- [ ] Architecture diagram updated
- [ ] Runbook written
- [ ] API documentation deployed
- [ ] Monitoring dashboard guide
- [ ] Rollback procedure documented

## Sign-off
- [ ] All smoke tests passed
- [ ] Performance benchmarks met
- [ ] Security scan passed
- [ ] Load test completed successfully
- [ ] Team notified
- [ ] Maintenance window scheduled
```

---

## H.9 Post-Deployment Tasks

### H.9.1 Initial Data Verification

```sql
-- Verify data integrity after migration
SELECT 
    'customers' as table_name, COUNT(*) as row_count,
    MIN(created_at) as oldest, MAX(created_at) as newest
FROM customers
UNION ALL
SELECT 'orders', COUNT(*), MIN(created_at), MAX(created_at)
FROM orders
UNION ALL
SELECT 'products', COUNT(*), MIN(created_at), MAX(created_at)
FROM products;

-- Check for any constraint violations
SELECT * FROM products WHERE price < 0;
SELECT * FROM orders WHERE total_amount < 0;
SELECT * FROM customers WHERE email IS NULL;
```

### H.9.2 Cache Warming

```python
# File: scripts/warm_cache.py
import asyncio
from src.services.catalog_cache import CatalogCache
from src.utils.db import get_db

async def warm_cache():
    """Warm up all caches after deployment."""
    cache = CatalogCache()
    
    # Warm product cache (top 1000 products)
    db = next(get_db())
    products = db.execute("SELECT id FROM products LIMIT 1000").fetchall()
    
    print(f"Warming cache for {len(products)} products...")
    for product in products:
        await cache.set_product(product[0])
    
    # Warm category cache
    categories = db.execute("SELECT id FROM categories").fetchall()
    for category in categories:
        await cache.set_category(category[0])
    
    print("Cache warming complete")

if __name__ == "__main__":
    asyncio.run(warm_cache())
```

### H.9.3 First Production Order Test

```bash
# Create first production order
curl -X POST https://api.scalecart.com/api/v1/orders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_id": 1,
    "items": [
      {"product_id": 1, "quantity": 1}
    ],
    "shipping_address_id": 1,
    "billing_address_id": 1,
    "payment_method": "credit_card"
  }'

# Verify order was created
curl https://api.scalecart.com/api/v1/orders/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

**[END OF APPENDIX H]**

This complete production deployment walkthrough provides everything needed to deploy ScaleCart to a production environment. Follow it step by step for a successful production launch.
