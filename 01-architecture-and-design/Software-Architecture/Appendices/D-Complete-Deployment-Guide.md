# Appendix D: Complete Deployment Guide

## Deploying the Orchestrator System to Production

This appendix provides comprehensive deployment instructions for the Orchestrator system across multiple environments. Think of this as the launch checklist for your restaurant chain - ensuring everything is in place before opening to customers.

### 1. Deployment Overview

#### Deployment Targets

| Environment | Purpose | URL |
|-------------|---------|-----|
| Development | Local development | http://localhost:3000 |
| Testing | Automated tests | http://test.orchestrator.local |
| Staging | Pre-production validation | https://staging.orchestrator.com |
| Production | Live system | https://api.orchestrator.com |

#### Deployment Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         DEPLOYMENT PIPELINE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌───────────┐ │
│  │   Code       │    │   Build      │    │   Test       │    │  Deploy   │ │
│  │   Commit     │───▶│   & Bundle   │───▶│   & Validate │───▶│  Staging  │ │
│  └──────────────┘    └──────────────┘    └──────────────┘    └───────────┘ │
│                                                                      │      │
│                                                                      ▼      │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌───────────┐ │
│  │   Smoke      │    │   Blue-Green │    │   Canary     │    │  Production│ │
│  │   Test       │◀───│   Deploy     │───▶│   Test       │───▶│  Deploy   │ │
│  └──────────────┘    └──────────────┘    └──────────────┘    └───────────┘ │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. Prerequisites

#### Infrastructure Requirements

```bash
# AWS CLI
aws --version  # v2.x or later

# Terraform
terraform --version  # v1.5.x or later

# Wrangler (Cloudflare)
wrangler --version  # v3.x or later

# kubectl (if using Kubernetes)
kubectl version

# Helm (if using Kubernetes)
helm version
```

#### Required Access

| Platform | Required Permissions |
|----------|---------------------|
| AWS | Lambda, API Gateway, CloudFront, RDS, ElastiCache |
| Cloudflare | Workers, KV, Cache |
| GitHub | Actions, Secrets, Environments |
| Docker Hub | Push images (if using containers) |

### 3. Environment Configuration

#### Production Environment Variables

**File:** `packages/gateway/.env.production`

```env
# Application
NODE_ENV=production
PORT=3000
LOG_LEVEL=info
SERVICE_NAME=gateway
SERVICE_VERSION=1.0.0

# Database
DATABASE_URL=postgresql://user:password@host:5432/orchestrator
DATABASE_MAX_CONNECTIONS=20
DATABASE_IDLE_TIMEOUT=30000

# Redis
REDIS_URL=redis://:password@host:6379/0
REDIS_MAX_RETRIES=5

# External Services
AUTH_SERVICE_URL=https://auth.orchestrator.com
USER_SERVICE_URL=https://user.orchestrator.com
TASK_SERVICE_URL=https://task.orchestrator.com

# Security
JWT_SECRET=<generate-strong-secret>
API_KEY=<generate-api-key>
CORS_ORIGINS=https://orchestrator.com,https://*.orchestrator.com

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_WINDOW=60000
RATE_LIMIT_MAX_REQUESTS=1000

# Monitoring
METRICS_ENABLED=true
METRICS_PORT=9090
HEALTH_CHECK_INTERVAL=30000

# Workers
WORKER_COUNT=5
WORKER_QUEUE_NAME=tasks

# AI
OPENAI_API_KEY=<openai-api-key>
OPENAI_MODEL=gpt-4-turbo-preview
```

#### Generate Secrets

```bash
# Generate JWT secret
openssl rand -base64 32 > .secrets/jwt-secret.txt

# Generate API key
openssl rand -hex 32 > .secrets/api-key.txt

# Store secrets in AWS Secrets Manager
aws secretsmanager create-secret \
    --name orchestrator/jwt-secret \
    --secret-string file://.secrets/jwt-secret.txt
```

### 4. Database Deployment

#### AWS RDS Setup

```bash
# Create RDS instance
aws rds create-db-instance \
    --db-instance-identifier orchestrator-db \
    --db-instance-class db.t3.medium \
    --engine postgres \
    --engine-version 16.3 \
    --master-username orchestrator_admin \
    --master-user-password <password> \
    --allocated-storage 20 \
    --storage-type gp3 \
    --vpc-security-group-ids sg-12345678 \
    --db-subnet-group-name orchestrator-subnet-group \
    --backup-retention-period 7 \
    --multi-az false \
    --publicly-accessible false

# Wait for instance to be available
aws rds wait db-instance-available \
    --db-instance-identifier orchestrator-db

# Get connection details
aws rds describe-db-instances \
    --db-instance-identifier orchestrator-db \
    --query 'DBInstances[0].Endpoint.Address'
```

#### Run Database Migrations

```bash
# Using the admin tool
npm run admin:db-migrate

# Or using AWS Lambda
aws lambda invoke \
    --function-name orchestrator-admin \
    --payload '{"action":"migrate"}' \
    output.json
```

#### Database Backup Strategy

```bash
# Create backup script
cat > scripts/backup-db.sh << 'EOF'
#!/bin/bash
BACKUP_NAME="orchestrator-$(date +%Y%m%d-%H%M%S)"

# Dump database
pg_dump -h $DB_HOST -U $DB_USER $DB_NAME > backups/$BACKUP_NAME.sql

# Compress
gzip backups/$BACKUP_NAME.sql

# Upload to S3
aws s3 cp backups/$BACKUP_NAME.sql.gz \
    s3://orchestrator-backups/database/

# Clean up old backups (keep 30 days)
find backups/ -name "*.sql.gz" -mtime +30 -delete
EOF

chmod +x scripts/backup-db.sh

# Schedule with cron
# 0 2 * * * /path/to/scripts/backup-db.sh
```

### 5. AWS Lambda Deployment

#### Build Lambda Bundle

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Bundle for Lambda
npm run build:lambda

# Optimize bundle
npm run build:optimize
```

#### Deploy with Serverless Framework

**File:** `serverless.yml`

```yaml
service: orchestrator-gateway

provider:
  name: aws
  runtime: nodejs18.x
  region: us-east-1
  memorySize: 512
  timeout: 30
  environment:
    NODE_ENV: production
    LOG_LEVEL: info
    DATABASE_URL: ${env:DATABASE_URL}
    REDIS_URL: ${env:REDIS_URL}
    JWT_SECRET: ${env:JWT_SECRET}

functions:
  gateway:
    handler: dist/lambda.handler
    events:
      - httpApi:
          path: /
          method: ANY
      - httpApi:
          path: /{proxy+}
          method: ANY
    reservedConcurrency: 10
    provisionedConcurrency: 5

resources:
  Resources:
    GatewayApi:
      Type: AWS::ApiGatewayV2::Api
      Properties:
        Name: orchestrator-gateway
        ProtocolType: HTTP
```

#### Deploy with Terraform

```bash
# Initialize Terraform
cd infrastructure/terraform
terraform init

# Plan deployment
terraform plan -var-file="production.tfvars"

# Apply deployment
terraform apply -var-file="production.tfvars" -auto-approve
```

#### Lambda Deployment Script

**File:** `scripts/deploy-lambda-production.sh`

```bash
#!/bin/bash

set -e

# Configuration
FUNCTION_NAME="orchestrator-gateway-production"
REGION="us-east-1"
S3_BUCKET="orchestrator-lambda-deployments"

# Build bundle
echo "📦 Building Lambda bundle..."
npm run build:lambda

# Upload to S3
echo "📤 Uploading to S3..."
aws s3 cp dist/lambda.zip \
    s3://$S3_BUCKET/lambda/$FUNCTION_NAME/$(date +%Y%m%d-%H%M%S)/lambda.zip

# Update Lambda
echo "🚀 Updating Lambda function..."
aws lambda update-function-code \
    --function-name $FUNCTION_NAME \
    --s3-bucket $S3_BUCKET \
    --s3-key lambda/$FUNCTION_NAME/$(date +%Y%m%d-%H%M%S)/lambda.zip \
    --region $REGION

# Wait for update
aws lambda wait function-updated \
    --function-name $FUNCTION_NAME \
    --region $REGION

# Publish new version
VERSION=$(aws lambda publish-version \
    --function-name $FUNCTION_NAME \
    --region $REGION \
    --query '{Version:Version}' \
    --output text)

echo "✅ Deployment successful! Version: $VERSION"
```

### 6. Cloudflare Worker Deployment

#### Build Worker Bundle

```bash
# Build for Cloudflare
npm run build:worker

# Optimize bundle
npm run build:optimize
```

#### Deploy with Wrangler

**File:** `wrangler.toml`

```toml
name = "orchestrator-gateway"
main = "dist/worker.js"
compatibility_date = "2024-01-01"
minify = true
logpush = true

[vars]
NODE_ENV = "production"
LOG_LEVEL = "info"
DATABASE_URL = "${DATABASE_URL}"
REDIS_URL = "${REDIS_URL}"
JWT_SECRET = "${JWT_SECRET}"

[[env.production.vars]]
NODE_ENV = "production"
LOG_LEVEL = "info"

[env.production.secrets]
DATABASE_URL = true
REDIS_URL = true
JWT_SECRET = true
```

#### Deploy Command

```bash
# Login to Cloudflare
wrangler login

# Set secrets
wrangler secret put DATABASE_URL --env production
wrangler secret put REDIS_URL --env production
wrangler secret put JWT_SECRET --env production

# Deploy
wrangler deploy --env production

# Create alias
wrangler tail --env production
```

### 7. Kubernetes Deployment (Optional)

#### Create Docker Image

**File:** `Dockerfile.production`

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production=false
COPY . .
RUN npm run build
RUN npm prune --production

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./

EXPOSE 3000
CMD ["node", "dist/index.js"]
```

#### Kubernetes Deployment

**File:** `k8s/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orchestrator-gateway
  namespace: orchestrator
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: orchestrator-gateway
  template:
    metadata:
      labels:
        app: orchestrator-gateway
    spec:
      containers:
      - name: gateway
        image: orchestrator/gateway:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-secret
              key: url
        livenessProbe:
          httpGet:
            path: /health/live
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health/ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: orchestrator-gateway
  namespace: orchestrator
spec:
  selector:
    app: orchestrator-gateway
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
```

### 8. CI/CD Pipeline

#### GitHub Actions Workflow

**File:** `.github/workflows/deploy-production.yml`

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]
    paths:
      - 'packages/gateway/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    concurrency: production

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: |
          cd packages/gateway
          npm ci

      - name: Build
        run: |
          cd packages/gateway
          npm run build
          npm run build:serverless

      - name: Run tests
        env:
          DATABASE_URL: ${{ secrets.TEST_DATABASE_URL }}
          REDIS_URL: ${{ secrets.TEST_REDIS_URL }}
        run: |
          cd packages/gateway
          npm test

      - name: Deploy to AWS Lambda
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: ${{ secrets.AWS_REGION }}
        run: |
          cd packages/gateway
          ./scripts/deploy-lambda-production.sh

      - name: Deploy to Cloudflare Worker
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
        run: |
          cd packages/gateway
          ./scripts/deploy-worker-production.sh

      - name: Run smoke tests
        env:
          API_URL: ${{ secrets.PRODUCTION_API_URL }}
        run: |
          cd packages/gateway
          ./scripts/smoke-test.sh

      - name: Notify deployment
        uses: slackapi/slack-github-action@v1.25.0
        with:
          payload: |
            {
              "text": "✅ Production deployment successful!",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "✅ *Production Deployment Successful*\nVersion: `${{ github.sha }}`"
                  }
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### 9. Monitoring & Alerting

#### CloudWatch Alarms

**File:** `infrastructure/terraform/cloudwatch.tf`

```hcl
# Lambda Error Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "orchestrator-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Lambda errors exceeded threshold"

  dimensions = {
    FunctionName = aws_lambda_function.gateway.function_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# API Gateway 5xx Alarm
resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name          = "orchestrator-api-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 300
  statistic           = "Sum"
  threshold           = 10

  dimensions = {
    ApiName = aws_apigatewayv2_api.gateway.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
```

#### Health Check Endpoint

```bash
# Monitor health endpoint
while true; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" \
    https://api.orchestrator.com/health)
  
  if [ $STATUS -ne 200 ]; then
    echo "⚠️ Health check failed: $STATUS"
    # Send alert
    curl -X POST https://hooks.slack.com/services/xxx \
      -H "Content-Type: application/json" \
      -d "{\"text\":\"⚠️ API health check failed: $STATUS\"}"
  fi
  
  sleep 30
done
```

### 10. Disaster Recovery

#### Backup Strategy

```bash
# Daily automated backups
0 2 * * * /path/to/backup-db.sh

# Weekly full backup
0 3 * * 0 /path/to/full-backup.sh

# Replicate to secondary region
aws rds create-db-instance-read-replica \
    --db-instance-identifier orchestrator-db-replica \
    --source-db-instance-identifier orchestrator-db \
    --region us-west-2
```

#### Rollback Procedure

```bash
# 1. Identify previous version
aws lambda list-versions-by-function \
    --function-name orchestrator-gateway-production

# 2. Rollback Lambda
aws lambda update-alias \
    --function-name orchestrator-gateway-production \
    --name production \
    --function-version $PREVIOUS_VERSION

# 3. Rollback Cloudflare Worker
wrangler rollback --env production

# 4. Rollback database (if needed)
aws rds restore-db-instance-to-point-in-time \
    --source-db-instance-identifier orchestrator-db \
    --target-db-instance-identifier orchestrator-db-rollback \
    --use-latest-restorable-time

# 5. Switch traffic
aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '{
        "Changes": [{
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "api.orchestrator.com",
                "Type": "A",
                "AliasTarget": {
                    "HostedZoneId": "Z2FDTNDATAQYW2",
                    "DNSName": "orchestrator-db-rollback.region.rds.amazonaws.com",
                    "EvaluateTargetHealth": false
                }
            }
        }]
    }'
```

### 11. Post-Deployment Checklist

- [ ] Health checks pass (all endpoints)
- [ ] Database migrations applied
- [ ] Redis connections active
- [ ] Rate limiting enabled
- [ ] SSL/TLS certificates valid
- [ ] Monitoring dashboards updated
- [ ] Alerts configured and tested
- [ ] Backups verified
- [ ] Disaster recovery plan documented
- [ ] Rollback procedure tested

---

This deployment guide provides a complete roadmap for taking your Orchestrator system from development to production. Use it as a checklist and reference for production deployments.
