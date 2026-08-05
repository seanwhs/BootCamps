# Appendix H: Deployment Strategies and Infrastructure as Code

### Purpose of This Appendix

Throughout the main series and previous appendices, we've built, tested, and optimized our application. Now it's time to deploy it to production reliably and repeatedly. This appendix covers deployment strategies, infrastructure as code (IaC), containerization, orchestration, and operational best practices.

**What you'll find here:**
- **Infrastructure as Code (IaC)** – using Terraform to provision cloud resources.
- **Containerization** – advanced Docker strategies with multi‑stage builds and caching.
- **Orchestration** – deploying to Kubernetes with Helm charts.
- **Serverless deployment** – Vercel, AWS Lambda, and Cloudflare Workers.
- **Database deployment** – managing PostgreSQL in the cloud (AWS RDS, Neon, Supabase).
- **CI/CD pipelines** – advanced GitHub Actions workflows for multi‑environment deployments.
- **Secrets management** – using HashiCorp Vault and cloud secret managers.
- **Monitoring and alerting** – setting up dashboards and alerts.
- **Disaster recovery** – backup strategies and failover planning.

---

## Appendix H, Section 1: Infrastructure as Code with Terraform

Terraform allows you to define your infrastructure in code, enabling version control, reproducibility, and collaboration.

### 1.1 Terraform Configuration for AWS

**File:** `infrastructure/terraform/main.tf`

```hcl
# infrastructure/terraform/main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = { Name = "taskflow-vpc" }
}

# Subnets (public and private)
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = { Name = "taskflow-public-${count.index}" }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "taskflow-private-${count.index}" }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "taskflow-igw" }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "taskflow-public-rt" }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Groups
resource "aws_security_group" "app" {
  name        = "taskflow-app-sg"
  description = "Security group for TaskFlow application"
  vpc_id      = aws_vpc.main.id

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

  tags = { Name = "taskflow-app-sg" }
}

resource "aws_security_group" "database" {
  name        = "taskflow-db-sg"
  description = "Security group for TaskFlow database"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = { Name = "taskflow-db-sg" }
}

# RDS PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier     = "taskflow-db"
  engine         = "postgres"
  engine_version = "16.3"
  instance_class = "db.t4g.medium"
  allocated_storage = 100
  storage_encrypted = true

  db_name  = "taskflow"
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  skip_final_snapshot = false
  final_snapshot_identifier = "taskflow-db-final-snapshot"

  tags = { Name = "taskflow-db" }
}

resource "aws_db_subnet_group" "main" {
  name       = "taskflow-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags       = { Name = "taskflow-db-subnet-group" }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "taskflow-cluster"
}

# ECR Repository
resource "aws_ecr_repository" "app" {
  name = "taskflow-app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

# IAM Roles for ECS
resource "aws_iam_role" "ecs_execution_role" {
  name = "taskflow-ecs-execution-role"
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

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Application Load Balancer
resource "aws_lb" "app" {
  name               = "taskflow-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.app.id]
  subnets            = aws_subnet.public[*].id
}

resource "aws_lb_target_group" "app" {
  name     = "taskflow-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    path                = "/api/health"
    port                = "3000"
  }
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "taskflow-app"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = "512"
  memory                  = "1024"
  execution_role_arn      = aws_iam_role.ecs_execution_role.arn
  task_role_arn          = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "${aws_ecr_repository.app.repository_url}:latest"
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "NODE_ENV", value = "production" },
        { name = "DATABASE_URL", value = var.database_url },
        { name = "PRISMA_ACCELERATE_URL", value = var.prisma_accelerate_url },
      ]
      secrets = [
        { name = "NEXTAUTH_SECRET", valueFrom = "${var.secrets_arn}:nextauth::" },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/taskflow-app"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
      healthCheck = {
        command = ["CMD-SHELL", "curl -f http://localhost:3000/api/health || exit 1"]
        interval = 30
        timeout  = 5
        retries  = 3
        startPeriod = 60
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "app" {
  name            = "taskflow-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.app.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.app]

  lifecycle {
    ignore_changes = [task_definition] # Allow rolling updates via CI/CD
  }
}
```

### 1.2 Terraform Variables

**File:** `infrastructure/terraform/variables.tf`

```hcl
variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "db_username" {
  description = "Database username"
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  sensitive   = true
}

variable "database_url" {
  description = "Full database connection URL"
  sensitive   = true
}

variable "prisma_accelerate_url" {
  description = "Prisma Accelerate URL"
  sensitive   = true
}

variable "secrets_arn" {
  description = "ARN of the secrets manager secret"
  sensitive   = true
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate"
  sensitive   = false
}

data "aws_availability_zones" "available" {
  state = "available"
}
```

### 1.3 Terraform Outputs

**File:** `infrastructure/terraform/outputs.tf`

```hcl
output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.app.dns_name
}

output "database_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.postgres.endpoint
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}
```

### 1.4 Deploying with Terraform

```bash
cd infrastructure/terraform

# Initialize
terraform init

# Plan
terraform plan -var-file="prod.tfvars"

# Apply
terraform apply -var-file="prod.tfvars"
```

---

## Appendix H, Section 2: Advanced Docker Strategies

### 2.1 Multi‑Stage Docker Build

**File:** `Dockerfile.prod`

```dockerfile
# Dockerfile.prod - Multi-stage build for production

# Stage 1: Build
FROM node:20-alpine AS builder

# Install pnpm
RUN corepack enable && corepack prepare pnpm@9.0.0 --activate

WORKDIR /app

# Copy package files for dependency caching
COPY package.json pnpm-workspace.yaml ./
COPY packages/database/package.json ./packages/database/
COPY apps/nextjs/package.json ./apps/nextjs/

# Install dependencies
RUN pnpm install --frozen-lockfile --prod=false

# Copy source code
COPY . .

# Build the database package
RUN pnpm --filter @taskflow/database build

# Build the Next.js application
RUN pnpm --filter nextjs build

# Prune dev dependencies
RUN pnpm install --frozen-lockfile --prod

# Stage 2: Runtime
FROM node:20-alpine AS runner

WORKDIR /app

# Copy necessary files from builder
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/pnpm-lock.yaml ./pnpm-lock.yaml
COPY --from=builder /app/pnpm-workspace.yaml ./pnpm-workspace.yaml
COPY --from=builder /app/packages/database/package.json ./packages/database/package.json
COPY --from=builder /app/apps/nextjs/package.json ./apps/nextjs/package.json
COPY --from=builder /app/apps/nextjs/.next ./apps/nextjs/.next
COPY --from=builder /app/apps/nextjs/public ./apps/nextjs/public
COPY --from=builder /app/packages/database/dist ./packages/database/dist
COPY --from=builder /app/packages/database/node_modules ./packages/database/node_modules
COPY --from=builder /app/apps/nextjs/node_modules ./apps/nextjs/node_modules
COPY --from=builder /app/node_modules ./node_modules

# Copy Prisma Query Engine
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma

# Environment variables (set at runtime)
ENV NODE_ENV=production

EXPOSE 3000

CMD ["pnpm", "--filter", "nextjs", "start"]
```

### 2.2 Docker Compose with Production Overrides

**File:** `docker-compose.prod.yml`

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.prod
      cache_from:
        - taskflow-app:latest
    image: taskflow-app:latest
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - PRISMA_ACCELERATE_URL=${PRISMA_ACCELERATE_URL}
      - NEXTAUTH_SECRET=${NEXTAUTH_SECRET}
      - NEXTAUTH_URL=${NEXTAUTH_URL}
    ports:
      - "3000:3000"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 3
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - app
    restart: unless-stopped

volumes:
  redis_data:
```

### 2.3 Building and Pushing Docker Images

```bash
# Build the image
docker build -f Dockerfile.prod -t taskflow-app:latest .

# Tag for ECR
docker tag taskflow-app:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/taskflow-app:latest

# Push to ECR
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/taskflow-app:latest
```

---

## Appendix H, Section 3: Kubernetes Deployment with Helm

### 3.1 Helm Chart Structure

```
infrastructure/helm/taskflow/
├── Chart.yaml
├── values.yaml
├── values-prod.yaml
├── templates/
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── configmap.yaml
│   ├── secrets.yaml
│   ├── pvc.yaml
│   └── hpa.yaml
```

### 3.2 Helm Values

**File:** `infrastructure/helm/taskflow/values.yaml`

```yaml
# infrastructure/helm/taskflow/values.yaml
replicaCount: 2

image:
  repository: taskflow-app
  pullPolicy: IfNotPresent
  tag: "latest"

imagePullSecrets: []
nameOverride: ""
fullnameOverride: ""

service:
  type: ClusterIP
  port: 3000

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: taskflow.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: taskflow-tls
      hosts:
        - taskflow.example.com

resources:
  limits:
    cpu: 1000m
    memory: 1024Mi
  requests:
    cpu: 500m
    memory: 512Mi

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80

env:
  - name: NODE_ENV
    value: "production"
  - name: DATABASE_URL
    valueFrom:
      secretKeyRef:
        name: taskflow-secrets
        key: database-url
  - name: PRISMA_ACCELERATE_URL
    valueFrom:
      secretKeyRef:
        name: taskflow-secrets
        key: prisma-accelerate-url
  - name: NEXTAUTH_SECRET
    valueFrom:
      secretKeyRef:
        name: taskflow-secrets
        key: nextauth-secret

configmap:
  data:
    LOG_LEVEL: "info"
    REDIS_URL: "redis://redis:6379"

persistence:
  enabled: true
  size: 10Gi
  storageClass: "gp2"

nodeSelector: {}
tolerations: []
affinity: {}
```

### 3.3 Deployment Template

**File:** `infrastructure/helm/taskflow/templates/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "taskflow.fullname" . }}
  labels:
    {{- include "taskflow.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "taskflow.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "taskflow.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 3000
              protocol: TCP
          env:
            {{- toYaml .Values.env | nindent 12 }}
          envFrom:
            - configMapRef:
                name: {{ include "taskflow.fullname" . }}-config
          livenessProbe:
            httpGet:
              path: /api/health
              port: http
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /api/health
              port: http
            initialDelaySeconds: 5
            periodSeconds: 5
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          volumeMounts:
            - name: uploads
              mountPath: /app/uploads
      volumes:
        - name: uploads
          {{- if .Values.persistence.enabled }}
          persistentVolumeClaim:
            claimName: {{ include "taskflow.fullname" . }}-pvc
          {{- else }}
          emptyDir: {}
          {{- end }}
```

### 3.4 Deploying with Helm

```bash
# Install the Helm chart
helm install taskflow ./infrastructure/helm/taskflow -f ./infrastructure/helm/taskflow/values-prod.yaml

# Upgrade
helm upgrade taskflow ./infrastructure/helm/taskflow -f ./infrastructure/helm/taskflow/values-prod.yaml

# Rollback
helm rollback taskflow 1

# Uninstall
helm uninstall taskflow
```

---

## Appendix H, Section 4: Serverless Deployment

### 4.1 Vercel Deployment (Next.js)

**File:** `vercel.json`

```json
{
  "buildCommand": "pnpm --filter nextjs build",
  "outputDirectory": "apps/nextjs/.next",
  "installCommand": "pnpm install",
  "framework": "nextjs",
  "env": {
    "NEXT_PUBLIC_APP_URL": "https://taskflow.example.com"
  },
  "functions": {
    "api/**/*.js": {
      "maxDuration": 30,
      "memory": 1024
    }
  }
}
```

**Deployment:**

```bash
# Install Vercel CLI
pnpm add -g vercel

# Deploy
vercel --prod
```

### 4.2 AWS Lambda with Serverless Framework

**File:** `serverless.yml`

```yaml
service: taskflow-api

provider:
  name: aws
  runtime: nodejs20.x
  region: us-east-1
  environment:
    NODE_ENV: production
    DATABASE_URL: ${ssm:/taskflow/DATABASE_URL}
    PRISMA_ACCELERATE_URL: ${ssm:/taskflow/PRISMA_ACCELERATE_URL}
  iam:
    role:
      statements:
        - Effect: Allow
          Action:
            - ssm:GetParameter
          Resource: "*"

package:
  exclude:
    - node_modules/.prisma/client/**/*.wasm
    - node_modules/.prisma/client/*.node

functions:
  api:
    handler: apps/nextjs/.next/server/pages/api/[...next].js
    events:
      - http:
          path: /{proxy+}
          method: ANY
    memorySize: 1024
    timeout: 30

plugins:
  - serverless-nextjs-plugin

custom:
  nextjs:
    build:
      args:
        - NEXT_PUBLIC_APP_URL=${env:NEXT_PUBLIC_APP_URL}
```

### 4.3 Cloudflare Workers

**File:** `wrangler.toml`

```toml
name = "taskflow-api"
main = "dist/index.js"
compatibility_date = "2024-01-01"

[vars]
DATABASE_URL = "postgresql://..."
PRISMA_ACCELERATE_URL = "https://..."

[env.production]
vars = { NODE_ENV = "production" }
```

---

## Appendix H, Section 5: CI/CD Pipelines

### 5.1 GitHub Actions Multi-Environment Deployment

**File:** `.github/workflows/deploy.yml`

```yaml
name: Deploy

on:
  push:
    branches:
      - main
      - develop
  workflow_dispatch:

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: taskflow-app

jobs:
  build-and-push:
    name: Build and Push Docker Image
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.image-tag.outputs.tag }}
    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v2

      - name: Generate image tag
        id: image-tag
        run: |
          TAG=$(echo ${{ github.sha }} | cut -c1-7)
          echo "tag=$TAG" >> $GITHUB_OUTPUT

      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          file: Dockerfile.prod
          push: true
          tags: |
            ${{ steps.login-ecr.outputs.registry }}/${{ env.ECR_REPOSITORY }}:${{ steps.image-tag.outputs.tag }}
            ${{ steps.login-ecr.outputs.registry }}/${{ env.ECR_REPOSITORY }}:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max
          build-args: |
            NEXT_PUBLIC_APP_URL=${{ vars.NEXT_PUBLIC_APP_URL }}

  deploy-ecs:
    name: Deploy to ECS
    runs-on: ubuntu-latest
    needs: build-and-push
    environment:
      name: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Download task definition
        run: |
          aws ecs describe-task-definition --task-definition taskflow-app \
            --query taskDefinition > task-definition.json

      - name: Update task definition
        id: task-def
        uses: aws-actions/amazon-ecs-render-task-definition@v1
        with:
          task-definition: task-definition.json
          container-name: app
          image: ${{ steps.login-ecr.outputs.registry }}/${{ env.ECR_REPOSITORY }}:${{ needs.build-and-push.outputs.image-tag }}

      - name: Deploy to ECS
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: ${{ steps.task-def.outputs.task-definition }}
          service: taskflow-app-service
          cluster: taskflow-cluster
          wait-for-service-stability: true
```

### 5.2 Database Migrations in CI/CD

```yaml
- name: Run Database Migrations
  run: |
    if [ "${{ github.ref }}" == "refs/heads/main" ]; then
      echo "Running migrations in production"
      pnpm prisma migrate deploy
    else
      echo "Running migrations in staging"
      pnpm prisma migrate deploy --preview-feature
    fi
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
    PRISMA_ACCELERATE_URL: ${{ secrets.PRISMA_ACCELERATE_URL }}
```

---

## Appendix H, Section 6: Secrets Management

### 6.1 HashiCorp Vault

```typescript
// packages/database/src/vault.ts
import { VaultClient } from '@hashicorp/vault'

const vault = new VaultClient({
  apiVersion: 'v1',
  endpoint: process.env.VAULT_ADDR!,
  token: process.env.VAULT_TOKEN!,
})

export async function getSecret(path: string) {
  const { data } = await vault.read(path)
  return data
}

// Usage
const dbSecret = await getSecret('secret/data/database')
const DATABASE_URL = dbSecret.data.url
```

### 6.2 AWS Secrets Manager

```typescript
import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager'

const client = new SecretsManagerClient({ region: 'us-east-1' })

export async function getSecret(secretName: string) {
  const command = new GetSecretValueCommand({ SecretId: secretName })
  const response = await client.send(command)
  return JSON.parse(response.SecretString!)
}
```

---

## Appendix H, Section 7: Monitoring and Alerting

### 7.1 Prometheus Metrics

```typescript
// packages/database/src/metrics.ts
import { register, Counter, Histogram, Gauge } from 'prom-client'

export const queryCounter = new Counter({
  name: 'db_queries_total',
  help: 'Total number of database queries',
  labelNames: ['model', 'operation', 'orm'],
})

export const queryDuration = new Histogram({
  name: 'db_query_duration_seconds',
  help: 'Duration of database queries',
  labelNames: ['model', 'operation', 'orm'],
  buckets: [0.001, 0.005, 0.01, 0.05, 0.1, 0.5, 1, 5],
})

export const activeConnections = new Gauge({
  name: 'db_active_connections',
  help: 'Number of active database connections',
})

// In a middleware
queryCounter.inc({ model: 'project', operation: 'findMany', orm: 'prisma' })
const end = queryDuration.startTimer()
await query()
end({ model: 'project', operation: 'findMany', orm: 'prisma' })
```

### 7.2 Grafana Dashboard

A Grafana dashboard can visualize:
- Request latency (p50, p95, p99)
- Error rates
- Database query performance
- Connection pool utilization
- Cache hit/miss rates
- Background job queue sizes
- Cold start times

### 7.3 Alerting Rules (Prometheus)

```yaml
groups:
  - name: taskflow-alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        annotations:
          summary: "High error rate detected"
          
      - alert: SlowDatabaseQueries
        expr: histogram_quantile(0.95, db_query_duration_seconds) > 1
        for: 5m
        annotations:
          summary: "Database queries are slow"
          
      - alert: HighConnectionUsage
        expr: db_active_connections / db_connection_limit > 0.8
        for: 2m
        annotations:
          summary: "Database connection pool is almost full"
```

---

## Appendix H, Section 8: Disaster Recovery

### 8.1 Backup Strategy

```bash
# PostgreSQL daily backup
#!/bin/bash
BACKUP_FILE="/backups/taskflow-$(date +%Y%m%d-%H%M%S).sql.gz"
pg_dump taskflow | gzip > $BACKUP_FILE
aws s3 cp $BACKUP_FILE s3://taskflow-backups/daily/

# Weekly full backup
if [ $(date +%u) -eq 7 ]; then
  aws s3 cp $BACKUP_FILE s3://taskflow-backups/weekly/
fi

# Monthly archive
if [ $(date +%d) -eq 1 ]; then
  aws s3 cp $BACKUP_FILE s3://taskflow-backups/monthly/
fi
```

### 8.2 Restore Procedure

```bash
# Download backup
aws s3 cp s3://taskflow-backups/daily/taskflow-20250101-000000.sql.gz /tmp/

# Restore
gunzip -c /tmp/taskflow-20250101-000000.sql.gz | psql taskflow
```

### 8.3 Multi-Region Failover

For AWS, use RDS Multi-AZ and cross-region replicas. For manual failover:

```bash
# Promote replica to primary
aws rds promote-read-replica --db-instance-identifier taskflow-replica

# Update application to point to the new primary
aws ecs update-service --cluster taskflow-cluster --service taskflow-app-service \
  --task-definition taskflow-app-new
```

---

## Appendix H, Section 9: Deployment Checklist

Before deploying to production, verify:

- [ ] All tests pass (unit, integration, E2E).
- [ ] Database migrations are tested and backward‑compatible.
- [ ] Feature flags are configured for new functionality.
- [ ] Environment variables are set in all services.
- [ ] SSL certificates are valid and configured.
- [ ] Backup strategy is in place and tested.
- [ ] Monitoring dashboards are configured.
- [ ] Alerting rules are defined and tested.
- [ ] Rollback plan is documented and tested.
- [ ] Security group and firewall rules are restrictive.
- [ ] Rate limiting is configured.
- [ ] Logging is configured to forward to a central system.
- [ ] Performance benchmarks are within SLAs.
- [ ] Disaster recovery drill has been performed.

---

## Conclusion of Appendix H

This appendix has provided comprehensive deployment strategies for your application, covering infrastructure as code, containerization, orchestration, serverless deployment, CI/CD, secrets management, monitoring, and disaster recovery. You now have all the tools to deploy and operate TaskFlow Pro (or any similar application) in a production environment with confidence.
