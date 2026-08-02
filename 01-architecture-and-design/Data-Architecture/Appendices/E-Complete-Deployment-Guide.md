# Appendix E: Complete Deployment Guide

Welcome to Appendix E, which provides a comprehensive deployment strategy for the entire data architecture platform. Think of deployment like launching a spacecraft - it requires careful planning, staging, monitoring, and rollback procedures to ensure a successful mission.

## E.1 Deployment Strategy Overview

### The Concept

A robust deployment strategy covers:

- **Infrastructure as Code**: Define infrastructure programmatically
- **CI/CD Pipeline**: Automate build, test, and deployment
- **Blue-Green Deployment**: Zero-downtime releases
- **Canary Releases**: Gradual rollout with monitoring
- **Rollback Procedures**: Quick recovery from issues
- **Monitoring and Alerting**: Track deployment health

### The Implementation

**File: `deployment/terraform/main.tf`**
```hcl
# ============================================
# TERRAFORM CONFIGURATION
# Infrastructure as Code for AWS
# ============================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
  backend "s3" {
    bucket         = "dataarch-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = var.environment
      Project     = "DataArchitecture"
      ManagedBy   = "Terraform"
    }
  }
}

# ============================================
# VPC AND NETWORKING
# ============================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "dataarch-vpc-${var.environment}"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Name = "dataarch-vpc-${var.environment}"
  }
}

# ============================================
# EKS CLUSTER
# ============================================

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "dataarch-${var.environment}"
  cluster_version = "1.27"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  node_groups = {
    main = {
      desired_capacity = var.desired_capacity
      max_capacity     = var.max_capacity
      min_capacity     = var.min_capacity

      instance_types = var.instance_types

      k8s_labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }
    }
  }

  manage_aws_auth_configmap = true

  tags = {
    Name = "dataarch-eks-${var.environment}"
  }
}

# ============================================
# RDS POSTGRESQL
# ============================================

resource "aws_db_instance" "postgres" {
  identifier = "dataarch-postgres-${var.environment}"

  engine               = "postgres"
  engine_version       = "15.5"
  instance_class       = var.postgres_instance_class
  allocated_storage    = var.postgres_storage_gb
  storage_encrypted    = true
  storage_type         = "gp3"
  
  db_name  = "dataarch"
  username = var.postgres_username
  password = random_password.postgres_password.result

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name

  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  multi_az               = var.environment == "production"
  publicly_accessible    = false
  deletion_protection    = var.environment == "production"

  tags = {
    Name = "dataarch-postgres-${var.environment}"
  }
}

resource "random_password" "postgres_password" {
  length  = 20
  special = false
}

resource "aws_db_subnet_group" "rds" {
  name       = "dataarch-rds-subnet-${var.environment}"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "dataarch-rds-subnet-${var.environment}"
  }
}

resource "aws_security_group" "rds" {
  name        = "dataarch-rds-sg-${var.environment}"
  description = "Security group for RDS"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dataarch-rds-sg-${var.environment}"
  }
}

# ============================================
# ELASTICACHE REDIS
# ============================================

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "dataarch-redis-${var.environment}"
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = var.redis_node_type
  num_cache_nodes      = var.environment == "production" ? 2 : 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  
  subnet_group_name = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis.id]

  tags = {
    Name = "dataarch-redis-${var.environment}"
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "dataarch-redis-subnet-${var.environment}"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "redis" {
  name        = "dataarch-redis-sg-${var.environment}"
  description = "Security group for Redis"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  tags = {
    Name = "dataarch-redis-sg-${var.environment}"
  }
}

# ============================================
# MSK KAFKA
# ============================================

resource "aws_msk_cluster" "kafka" {
  cluster_name = "dataarch-kafka-${var.environment}"
  kafka_version = "3.5.0"
  number_of_broker_nodes = var.environment == "production" ? 3 : 1

  broker_node_group_info {
    instance_type   = var.kafka_instance_type
    client_subnets  = module.vpc.private_subnets
    security_groups = [aws_security_group.kafka.id]
    
    storage_info {
      ebs_storage_info {
        volume_size = var.kafka_storage_gb
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  tags = {
    Name = "dataarch-kafka-${var.environment}"
  }
}

resource "aws_security_group" "kafka" {
  name        = "dataarch-kafka-sg-${var.environment}"
  description = "Security group for Kafka"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id]
  }

  tags = {
    Name = "dataarch-kafka-sg-${var.environment}"
  }
}

# ============================================
# S3 BUCKETS
# ============================================

resource "aws_s3_bucket" "data_lake" {
  bucket = "dataarch-datalake-${var.environment}"
  
  tags = {
    Name = "dataarch-datalake-${var.environment}"
  }
}

resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    id     = "archive"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }

  rule {
    id     = "delete"
    status = "Enabled"

    expiration {
      days = 365
    }
  }
}

# ============================================
# SECRETS MANAGEMENT
# ============================================

resource "aws_secretsmanager_secret" "database" {
  name = "dataarch/database/${var.environment}"
  
  tags = {
    Name = "dataarch-database-secret-${var.environment}"
  }
}

resource "aws_secretsmanager_secret_version" "database" {
  secret_id = aws_secretsmanager_secret.database.id
  secret_string = jsonencode({
    POSTGRES_HOST     = aws_db_instance.postgres.address
    POSTGRES_PORT     = aws_db_instance.postgres.port
    POSTGRES_DB       = aws_db_instance.postgres.db_name
    POSTGRES_USER     = var.postgres_username
    POSTGRES_PASSWORD = random_password.postgres_password.result
  })
}
```

**File: `deployment/terraform/variables.tf`**
```hcl
# ============================================
# TERRAFORM VARIABLES
# ============================================

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "desired_capacity" {
  description = "Desired EKS node count"
  type        = number
  default     = 3
}

variable "max_capacity" {
  description = "Maximum EKS node count"
  type        = number
  default     = 10
}

variable "min_capacity" {
  description = "Minimum EKS node count"
  type        = number
  default     = 2
}

variable "instance_types" {
  description = "EKS node instance types"
  type        = list(string)
  default     = ["t3.medium", "t3.large"]
}

variable "postgres_instance_class" {
  description = "RDS PostgreSQL instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "postgres_storage_gb" {
  description = "RDS storage size in GB"
  type        = number
  default     = 100
}

variable "postgres_username" {
  description = "RDS PostgreSQL username"
  type        = string
  default     = "dataarch"
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "kafka_instance_type" {
  description = "MSK Kafka instance type"
  type        = string
  default     = "kafka.t3.small"
}

variable "kafka_storage_gb" {
  description = "Kafka storage size in GB"
  type        = number
  default     = 100
}
```

**File: `deployment/terraform/outputs.tf`**
```hcl
# ============================================
# TERRAFORM OUTPUTS
# ============================================

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = module.eks.cluster_security_group_id
}

output "postgres_host" {
  description = "PostgreSQL host"
  value       = aws_db_instance.postgres.address
}

output "postgres_port" {
  description = "PostgreSQL port"
  value       = aws_db_instance.postgres.port
}

output "redis_host" {
  description = "Redis host"
  value       = aws_elasticache_cluster.redis.cache_nodes[0].address
}

output "redis_port" {
  description = "Redis port"
  value       = aws_elasticache_cluster.redis.port
}

output "kafka_brokers" {
  description = "Kafka broker addresses"
  value       = aws_msk_cluster.kafka.bootstrap_brokers_tls
}

output "s3_bucket_name" {
  description = "S3 data lake bucket name"
  value       = aws_s3_bucket.data_lake.id
}

output "database_secret_arn" {
  description = "Database secret ARN"
  value       = aws_secretsmanager_secret.database.arn
}
```

**File: `deployment/kubernetes/deployment.yaml`**
```yaml
# ============================================
# KUBERNETES DEPLOYMENT
# ============================================

apiVersion: apps/v1
kind: Deployment
metadata:
  name: dataarch-api
  namespace: data-platform
  labels:
    app: dataarch-api
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
      app: dataarch-api
  template:
    metadata:
      labels:
        app: dataarch-api
        component: api
    spec:
      containers:
      - name: api
        image: ${ECR_REGISTRY}/dataarch-api:${IMAGE_TAG}
        imagePullPolicy: Always
        ports:
        - containerPort: 8000
          name: http
        env:
        - name: APP_ENV
          value: "${ENVIRONMENT}"
        - name: APP_DEBUG
          value: "false"
        - name: POSTGRES_HOST
          valueFrom:
            secretKeyRef:
              name: dataarch-secrets
              key: postgres-host
        - name: POSTGRES_PORT
          valueFrom:
            secretKeyRef:
              name: dataarch-secrets
              key: postgres-port
        - name: POSTGRES_DB
          valueFrom:
            secretKeyRef:
              name: dataarch-secrets
              key: postgres-db
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: dataarch-secrets
              key: postgres-user
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: dataarch-secrets
              key: postgres-password
        - name: REDIS_HOST
          valueFrom:
            secretKeyRef:
              name: dataarch-secrets
              key: redis-host
        - name: REDIS_PORT
          valueFrom:
            secretKeyRef:
              name: dataarch-secrets
              key: redis-port
        - name: AWS_ACCESS_KEY_ID
          valueFrom:
            secretKeyRef:
              name: dataarch-secrets
              key: aws-access-key-id
        - name: AWS_SECRET_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: dataarch-secrets
              key: aws-secret-access-key
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
      imagePullSecrets:
      - name: regcred
---
# ============================================
# SERVICE
# ============================================

apiVersion: v1
kind: Service
metadata:
  name: dataarch-api
  namespace: data-platform
  labels:
    app: dataarch-api
spec:
  type: ClusterIP
  ports:
  - port: 8000
    targetPort: 8000
    protocol: TCP
    name: http
  selector:
    app: dataarch-api
---
# ============================================
# INGRESS
# ============================================

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: dataarch-api
  namespace: data-platform
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/proxy-body-size: "100m"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - api.dataarch.example.com
    secretName: dataarch-api-tls
  rules:
  - host: api.dataarch.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: dataarch-api
            port:
              number: 8000
---
# ============================================
# HORIZONTAL POD AUTOSCALER
# ============================================

apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: dataarch-api
  namespace: data-platform
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: dataarch-api
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
```

**File: `deployment/kubernetes/secrets.yaml`**
```yaml
# ============================================
# SECRETS (Managed by AWS Secrets Manager)
# ============================================

apiVersion: v1
kind: Secret
metadata:
  name: dataarch-secrets
  namespace: data-platform
type: Opaque
stringData:
  # These will be injected from AWS Secrets Manager
  postgres-host: "{{ .Values.secrets.POSTGRES_HOST }}"
  postgres-port: "{{ .Values.secrets.POSTGRES_PORT }}"
  postgres-db: "{{ .Values.secrets.POSTGRES_DB }}"
  postgres-user: "{{ .Values.secrets.POSTGRES_USER }}"
  postgres-password: "{{ .Values.secrets.POSTGRES_PASSWORD }}"
  redis-host: "{{ .Values.secrets.REDIS_HOST }}"
  redis-port: "{{ .Values.secrets.REDIS_PORT }}"
  redis-password: "{{ .Values.secrets.REDIS_PASSWORD }}"
  aws-access-key-id: "{{ .Values.secrets.AWS_ACCESS_KEY_ID }}"
  aws-secret-access-key: "{{ .Values.secrets.AWS_SECRET_ACCESS_KEY }}"
  jwt-secret: "{{ .Values.secrets.JWT_SECRET }}"
  encryption-key: "{{ .Values.secrets.ENCRYPTION_KEY }}"
```

**File: `deployment/ci-cd/github-actions.yml`**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  release:
    types: [published]

env:
  AWS_REGION: us-east-1
  ECR_REGISTRY: ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.us-east-1.amazonaws.com
  ECR_REPOSITORY: dataarch-api

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install pytest pytest-cov

      - name: Run tests
        run: |
          pytest -v --cov=. --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          flags: unittests

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name != 'pull_request'
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Build Docker image
        run: |
          docker build -t ${{ env.ECR_REGISTRY }}/${{ env.ECR_REPOSITORY }}:${{ github.sha }} .
          docker tag ${{ env.ECR_REGISTRY }}/${{ env.ECR_REPOSITORY }}:${{ github.sha }} ${{ env.ECR_REGISTRY }}/${{ env.ECR_REPOSITORY }}:latest

      - name: Push Docker image
        run: |
          docker push ${{ env.ECR_REGISTRY }}/${{ env.ECR_REPOSITORY }}:${{ github.sha }}
          docker push ${{ env.ECR_REGISTRY }}/${{ env.ECR_REPOSITORY }}:latest

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' || startsWith(github.ref, 'refs/tags/')
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Update kubeconfig
        run: |
          aws eks update-kubeconfig --name dataarch-${{ env.ENVIRONMENT }} --region ${{ env.AWS_REGION }}

      - name: Deploy to Kubernetes
        env:
          IMAGE_TAG: ${{ github.sha }}
        run: |
          envsubst < deployment/kubernetes/deployment.yaml | kubectl apply -f -
          envsubst < deployment/kubernetes/service.yaml | kubectl apply -f -

      - name: Verify deployment
        run: |
          kubectl rollout status deployment/dataarch-api -n data-platform --timeout=300s

  rollback:
    needs: deploy
    runs-on: ubuntu-latest
    if: failure()
    steps:
      - name: Rollback deployment
        run: |
          kubectl rollout undo deployment/dataarch-api -n data-platform
```

**File: `deployment/scripts/deploy.sh`**
```bash
#!/bin/bash
# ============================================
# DEPLOYMENT SCRIPT
# ============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=========================================="
echo "DATA ARCHITECTURE DEPLOYMENT"
echo "==========================================${NC}"

# Load environment
export ENVIRONMENT=${1:-development}
export IMAGE_TAG=${2:-latest}

echo -e "\n${YELLOW}Environment: ${ENVIRONMENT}${NC}"
echo -e "${YELLOW}Image Tag: ${IMAGE_TAG}${NC}"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    echo -e "${RED}Error: Invalid environment${NC}"
    exit 1
fi

# 1. Terraform infrastructure
echo -e "\n${YELLOW}Step 1: Infrastructure Provisioning${NC}"
cd deployment/terraform

terraform init
terraform plan -var="environment=${ENVIRONMENT}"
terraform apply -auto-approve -var="environment=${ENVIRONMENT}"

# 2. Build Docker image
echo -e "\n${YELLOW}Step 2: Building Docker Image${NC}"
cd ../..

docker build -t dataarch-api:${IMAGE_TAG} .
docker tag dataarch-api:${IMAGE_TAG} ${ECR_REGISTRY}/dataarch-api:${IMAGE_TAG}

# 3. Push to ECR
echo -e "\n${YELLOW}Step 3: Pushing to ECR${NC}"
docker push ${ECR_REGISTRY}/dataarch-api:${IMAGE_TAG}

# 4. Deploy to Kubernetes
echo -e "\n${YELLOW}Step 4: Deploying to Kubernetes${NC}"

# Update kubeconfig
aws eks update-kubeconfig --name dataarch-${ENVIRONMENT} --region ${AWS_REGION}

# Apply manifests with environment variables
envsubst < deployment/kubernetes/namespace.yaml | kubectl apply -f -
envsubst < deployment/kubernetes/configmap.yaml | kubectl apply -f -
envsubst < deployment/kubernetes/secrets.yaml | kubectl apply -f -
envsubst < deployment/kubernetes/deployment.yaml | kubectl apply -f -
envsubst < deployment/kubernetes/service.yaml | kubectl apply -f -

# 5. Wait for deployment
echo -e "\n${YELLOW}Step 5: Waiting for deployment${NC}"
kubectl rollout status deployment/dataarch-api -n data-platform --timeout=300s

# 6. Verify health
echo -e "\n${YELLOW}Step 6: Verifying health${NC}"
sleep 10
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- \
    curl -f http://dataarch-api:8000/health

# 7. Smoke tests
echo -e "\n${YELLOW}Step 7: Running smoke tests${NC}"
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- \
    curl -f http://dataarch-api:8000/api/v1/status

echo -e "\n${GREEN}=========================================="
echo "DEPLOYMENT COMPLETE!"
echo "==========================================${NC}"
```

## Verification

Let's verify the deployment setup:

```bash
# Navigate to the deployment directory
cd deployment

# Validate Terraform configuration
cd terraform
terraform fmt -check
terraform validate

# Validate Kubernetes manifests
cd ../kubernetes
kubectl apply --dry-run=client -f deployment.yaml
kubectl apply --dry-run=client -f service.yaml

# Run the deployment script (development environment)
cd ../scripts
./deploy.sh development latest

# Expected output:
# ============================================================
# DATA ARCHITECTURE DEPLOYMENT
# ============================================================
# 
# Environment: development
# Image Tag: latest
# 
# Step 1: Infrastructure Provisioning
# Initializing Terraform...
# Terraform has been successfully initialized!
# Plan: 15 to add, 0 to change, 0 to destroy.
# Apply complete! Resources: 15 added.
# 
# Step 2: Building Docker Image
# [+] Building 45.2s (12/12) FINISHED
# 
# Step 3: Pushing to ECR
# The push refers to repository [xxxxx.dkr.ecr.us-east-1.amazonaws.com/dataarch-api]
# latest: digest: sha256:xxxxx size: 1234
# 
# Step 4: Deploying to Kubernetes
# deployment.apps/dataarch-api created
# service/dataarch-api created
# 
# Step 5: Waiting for deployment
# deployment "dataarch-api" successfully rolled out
# 
# Step 6: Verifying health
# {"status":"healthy","version":"1.0.0"}
# 
# Step 7: Running smoke tests
# {"status":"ok","timestamp":"2024-01-15T10:30:00Z"}
# 
# ============================================================
# DEPLOYMENT COMPLETE!
# ============================================================
```
