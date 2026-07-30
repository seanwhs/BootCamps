# Primer 13: Understanding Deployment & DevOps Practices

## A Deep Dive into Production Deployment and Operations

Welcome to the thirteenth primer! This is a comprehensive deep dive into deployment and DevOps practices - the practices that take your code from development to production reliably and efficiently. Think of this like the logistics and operations of your restaurant chain - getting everything to the right place at the right time, ensuring quality, and having backup plans ready.

### 1. The Big Picture

#### Deployment Pipeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DEPLOYMENT PIPELINE                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌───────────┐ │
│  │   Code       │    │   Build      │    │   Test       │    │  Deploy   │ │
│  │   Commit     │───▶│   & Package  │───▶│   & Validate │───▶│  Staging  │ │
│  └──────────────┘    └──────────────┘    └──────────────┘    └───────────┘ │
│                                                                      │      │
│                                                                      ▼      │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐    ┌───────────┐ │
│  │   Canary     │    │   Blue/Green │    │   Smoke      │    │  Production│ │
│  │   Deploy     │───▶│   Deploy     │───▶│   Test       │───▶│  Deploy   │ │
│  └──────────────┘    └──────────────┘    └──────────────┘    └───────────┘ │
│                                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                 │
│  │   Monitor    │    │   Rollback   │    │   Alert      │                 │
│  │   & Observe  │◀───│   if needed  │◀───│   on Issues  │                 │
│  └──────────────┘    └──────────────┘    └──────────────┘                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2. CI/CD Pipeline

#### GitHub Actions Workflow

**File:** `.github/workflows/deploy.yml`

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]
    paths:
      - 'packages/gateway/**'
      - '!packages/gateway/**/*.md'
      - '!packages/gateway/**/*.test.ts'
  pull_request:
    branches: [main]
    paths:
      - 'packages/gateway/**'

jobs:
  # Build and Test
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: packages/gateway/package-lock.json

      - name: Install dependencies
        run: |
          cd packages/gateway
          npm ci

      - name: Type check
        run: |
          cd packages/gateway
          npm run type-check

      - name: Lint
        run: |
          cd packages/gateway
          npm run lint

      - name: Run tests
        run: |
          cd packages/gateway
          npm test -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          directory: packages/gateway/coverage
          flags: unittests

      - name: Build application
        run: |
          cd packages/gateway
          npm run build

      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-artifacts
          path: |
            packages/gateway/dist/
            packages/gateway/package.json
            packages/gateway/package-lock.json
          retention-days: 7

  # Deploy to Staging
  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    environment: staging
    concurrency: staging

    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-artifacts
          path: packages/gateway/

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Deploy to AWS Lambda (Staging)
        env:
          ENVIRONMENT: staging
          LAMBDA_FUNCTION_NAME: orchestrator-gateway-staging
        run: |
          cd packages/gateway
          ./scripts/deploy-lambda.sh

      - name: Run smoke tests
        env:
          API_URL: ${{ secrets.STAGING_API_URL }}
        run: |
          cd packages/gateway
          ./scripts/smoke-test.sh

  # Deploy to Production (with approval)
  deploy-production:
    needs: deploy-staging
    runs-on: ubuntu-latest
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    environment: 
      name: production
      url: ${{ secrets.PRODUCTION_API_URL }}
    concurrency: production

    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-artifacts
          path: packages/gateway/

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ secrets.AWS_REGION }}

      - name: Deploy to AWS Lambda (Production)
        env:
          ENVIRONMENT: production
          LAMBDA_FUNCTION_NAME: orchestrator-gateway-production
        run: |
          cd packages/gateway
          ./scripts/deploy-lambda.sh

      - name: Run canary tests
        env:
          API_URL: ${{ secrets.PRODUCTION_API_URL }}
          CANARY_PERCENTAGE: 10
        run: |
          cd packages/gateway
          ./scripts/canary-test.sh

      - name: Run smoke tests
        env:
          API_URL: ${{ secrets.PRODUCTION_API_URL }}
        run: |
          cd packages/gateway
          ./scripts/smoke-test.sh

      - name: Invalidate CloudFront cache
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} \
            --paths "/*"

      - name: Notify deployment success
        if: success()
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
                    "text": "✅ *Production Deployment Successful*"
                  }
                },
                {
                  "type": "section",
                  "fields": [
                    {
                      "type": "mrkdwn",
                      "text": "*Version:* `${{ github.sha }}`"
                    },
                    {
                      "type": "mrkdwn",
                      "text": "*Environment:* Production"
                    },
                    {
                      "type": "mrkdwn",
                      "text": "*Deployed By:* ${{ github.actor }}"
                    }
                  ]
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}

      - name: Notify deployment failure
        if: failure()
        uses: slackapi/slack-github-action@v1.25.0
        with:
          payload: |
            {
              "text": "❌ Production deployment failed!",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "❌ *Production Deployment Failed*"
                  }
                },
                {
                  "type": "section",
                  "fields": [
                    {
                      "type": "mrkdwn",
                      "text": "*Version:* `${{ github.sha }}`"
                    },
                    {
                      "type": "mrkdwn",
                      "text": "*Environment:* Production"
                    }
                  ]
                }
              ]
            }
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### 3. Infrastructure as Code (Terraform)

**File:** `infrastructure/terraform/main.tf`

```hcl
provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = var.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
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
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Security Groups
resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-lambda-sg"
    Environment = var.environment
  }
}

# AWS Lambda Function
resource "aws_lambda_function" "gateway" {
  filename         = "${path.module}/../../packages/gateway/dist/lambda.zip"
  function_name    = "${var.project_name}-${var.environment}"
  role            = aws_iam_role.lambda.arn
  handler         = "lambda.handler"
  runtime         = "nodejs18.x"
  memory_size     = var.lambda_memory_size
  timeout         = var.lambda_timeout
  publish         = true

  environment {
    variables = {
      NODE_ENV        = var.environment
      LOG_LEVEL       = "info"
      DATABASE_URL    = var.database_url
      REDIS_URL       = var.redis_url
      JWT_SECRET      = var.jwt_secret
      SERVICE_NAME    = var.project_name
      SERVICE_VERSION = var.service_version
    }
  }

  vpc_config {
    subnet_ids         = aws_subnet.public[*].id
    security_group_ids = [aws_security_group.lambda.id]
  }

  tracing_config {
    mode = "Active"
  }

  tags = {
    Name        = "${var.project_name}-lambda"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda
  ]
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-lambda-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# API Gateway
resource "aws_apigatewayv2_api" "gateway" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  tags = {
    Name        = "${var.project_name}-api"
    Environment = var.environment
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.gateway.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.gateway.invoke_arn
}

resource "aws_apigatewayv2_route" "proxy" {
  api_id    = aws_apigatewayv2_api.gateway.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.gateway.id
  name        = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      ip                      = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      httpMethod              = "$context.httpMethod"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      protocol                = "$context.protocol"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }

  tags = {
    Name        = "${var.project_name}-api-stage"
    Environment = var.environment
  }
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/api_gateway/${var.project_name}"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-api-logs"
    Environment = var.environment
  }
}

# Lambda Permission
resource "aws_lambda_permission" "api_gateway" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.gateway.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.gateway.execution_arn}/*"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "gateway" {
  enabled = true

  origin {
    domain_name = aws_apigatewayv2_api.gateway.api_endpoint
    origin_id   = "api-gateway"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id = "api-gateway"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 300
    max_ttl     = 3600
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name        = "${var.project_name}-cf"
    Environment = var.environment
  }
}

# Variables
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "orchestrator"
}

variable "environment" {
  description = "Environment (dev/staging/production)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "lambda_memory_size" {
  description = "Lambda memory size"
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "database_url" {
  description = "Database connection URL"
  type        = string
  sensitive   = true
}

variable "redis_url" {
  description = "Redis connection URL"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret"
  type        = string
  sensitive   = true
}

variable "service_version" {
  description = "Service version"
  type        = string
  default     = "1.0.0"
}
```

### 4. Containerization

#### Dockerfile

**File:** `packages/gateway/Dockerfile`

```dockerfile
# Multi-stage build
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY tsconfig*.json ./

# Install dependencies
RUN npm ci --only=production=false

# Copy source code
COPY src ./src

# Build TypeScript
RUN npm run build

# Prune dev dependencies
RUN npm prune --production

# Production stage
FROM node:20-alpine AS production

WORKDIR /app

# Copy built artifacts
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/scripts ./scripts

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node dist/admin/health-check.js || exit 1

EXPOSE 3000

CMD ["node", "dist/index.js"]
```

#### Docker Compose

**File:** `docker-compose.yml`

```yaml
version: '3.8'

services:
  # PostgreSQL
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: ${DB_USER:-postgres}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-postgres}
      POSTGRES_DB: ${DB_NAME:-orchestrator}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-postgres}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - orchestrator-network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # Redis
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - orchestrator-network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # Gateway Service
  gateway:
    build:
      context: ./packages/gateway
      target: production
    environment:
      NODE_ENV: ${NODE_ENV:-development}
      PORT: 3000
      DATABASE_URL: postgresql://${DB_USER:-postgres}:${DB_PASSWORD:-postgres}@postgres:5432/${DB_NAME:-orchestrator}
      REDIS_URL: redis://redis:6379
      JWT_SECRET: ${JWT_SECRET:-dev-secret}
      LOG_LEVEL: ${LOG_LEVEL:-info}
    ports:
      - "3000:3000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - orchestrator-network
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  # Admin Tools (one-off)
  admin:
    build:
      context: ./packages/gateway
      target: production
    environment:
      NODE_ENV: ${NODE_ENV:-development}
      DATABASE_URL: postgresql://${DB_USER:-postgres}:${DB_PASSWORD:-postgres}@postgres:5432/${DB_NAME:-orchestrator}
      REDIS_URL: redis://redis:6379
      JWT_SECRET: ${JWT_SECRET:-dev-secret}
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - orchestrator-network
    profiles:
      - admin
    entrypoint: ["node", "dist/admin/${ADMIN_COMMAND:-health-check.js}"]

networks:
  orchestrator-network:
    driver: bridge

volumes:
  postgres_data:
```

### 5. Blue-Green Deployment

**File:** `scripts/blue-green-deploy.sh`

```bash
#!/bin/bash

# Blue-Green Deployment Script
set -e

# Configuration
PROJECT_NAME="orchestrator"
ENVIRONMENT="production"
REGION="us-east-1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "${GREEN}🔄 Starting Blue-Green Deployment${NC}"

# Get current active environment (blue or green)
CURRENT=$(aws lambda get-alias \
    --function-name "${PROJECT_NAME}-${ENVIRONMENT}" \
    --name "active" \
    --region $REGION \
    --query 'FunctionVersion' \
    --output text)

CURRENT_COLOR="blue"
if [[ $CURRENT == *"green"* ]]; then
    CURRENT_COLOR="green"
fi

# Determine target color
if [ "$CURRENT_COLOR" == "blue" ]; then
    TARGET_COLOR="green"
else
    TARGET_COLOR="blue"
fi

echo "${YELLOW}Current: $CURRENT_COLOR, Target: $TARGET_COLOR${NC}"

# Deploy to target
echo "${YELLOW}📦 Deploying to $TARGET_COLOR...${NC}"

# Update target Lambda
aws lambda update-function-code \
    --function-name "${PROJECT_NAME}-${ENVIRONMENT}-${TARGET_COLOR}" \
    --zip-file fileb://packages/gateway/dist/lambda.zip \
    --region $REGION

# Wait for update
aws lambda wait function-updated \
    --function-name "${PROJECT_NAME}-${ENVIRONMENT}-${TARGET_COLOR}" \
    --region $REGION

# Publish new version
VERSION=$(aws lambda publish-version \
    --function-name "${PROJECT_NAME}-${ENVIRONMENT}-${TARGET_COLOR}" \
    --region $REGION \
    --query '{Version:Version}' \
    --output text)

echo "${GREEN}✅ Deployed version $VERSION to $TARGET_COLOR${NC}"

# Run smoke tests on target
echo "${YELLOW}🧪 Running smoke tests on $TARGET_COLOR...${NC}"

TARGET_URL=$(aws lambda get-function-url-config \
    --function-name "${PROJECT_NAME}-${ENVIRONMENT}-${TARGET_COLOR}" \
    --region $REGION \
    --query 'FunctionUrl' \
    --output text)

if curl -s -f "$TARGET_URL/health" > /dev/null; then
    echo "${GREEN}✅ Smoke tests passed${NC}"
else
    echo "${RED}❌ Smoke tests failed, aborting deployment${NC}"
    exit 1
fi

# Switch traffic
echo "${YELLOW}🔄 Switching traffic from $CURRENT_COLOR to $TARGET_COLOR...${NC}"

# Update alias to point to new version
aws lambda update-alias \
    --function-name "${PROJECT_NAME}-${ENVIRONMENT}" \
    --name "active" \
    --function-version $VERSION \
    --region $REGION

echo "${GREEN}✅ Traffic switched to $TARGET_COLOR${NC}"

# Run post-deployment validation
echo "${YELLOW}🧪 Running post-deployment validation...${NC}"

if curl -s -f "${PRODUCTION_URL}/health" > /dev/null; then
    echo "${GREEN}✅ Deployment successful!${NC}"
else
    echo "${RED}❌ Post-deployment validation failed${NC}"
    echo "${YELLOW}Rolling back...${NC}"
    
    # Rollback
    aws lambda update-alias \
        --function-name "${PROJECT_NAME}-${ENVIRONMENT}" \
        --name "active" \
        --function-version $(aws lambda get-alias \
            --function-name "${PROJECT_NAME}-${ENVIRONMENT}" \
            --name "previous" \
            --region $REGION \
            --query 'FunctionVersion' \
            --output text) \
        --region $REGION
    
    echo "${RED}❌ Rollback complete${NC}"
    exit 1
fi

echo "${GREEN}🎉 Blue-Green deployment complete!${NC}"
echo "Active: $TARGET_COLOR (version $VERSION)"
```

### 6. Monitoring & Alerting

#### CloudWatch Alarms

**File:** `infrastructure/terraform/alarms.tf`

```hcl
# Lambda Error Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Lambda errors exceeded threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.gateway.function_name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn,
    aws_sns_topic.email.arn,
  ]
}

# Lambda Duration Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.project_name}-lambda-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Average"
  threshold           = 25000 // 25 seconds
  alarm_description   = "Lambda duration exceeded threshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.gateway.function_name
  }

  alarm_actions = [
    aws_sns_topic.alerts.arn,
    aws_sns_topic.email.arn,
  ]
}

# API Gateway 5xx Alarm
resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name          = "${var.project_name}-api-5xx"
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

  alarm_actions = [
    aws_sns_topic.alerts.arn,
    aws_sns_topic.email.arn,
  ]
}

# SNS Topics
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"
}

resource "aws_sns_topic" "email" {
  name = "${var.project_name}-email-alerts"
}

# Email Subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.email.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
```

### 7. Key Takeaways

1. **CI/CD Pipeline is Essential:**
   - Automate build, test, and deployment
   - Use different environments (staging, production)
   - Implement quality gates
   - Rollback capability

2. **Infrastructure as Code:**
   - Define infrastructure declaratively
   - Version control infrastructure
   - Enable reproducibility
   - Easy disaster recovery

3. **Containerization:**
   - Consistent runtime environment
   - Easy scaling
   - Simplified deployment
   - Resource isolation

4. **Deployment Strategies:**
   - Blue-Green for zero downtime
   - Canary for gradual rollout
   - Rolling for minimal impact
   - A/B testing for feature validation

5. **Monitoring & Alerting:**
   - Monitor key metrics
   - Set up actionable alerts
   - Create dashboards
   - Regular health checks

6. **Security Considerations:**
   - Use secrets management
   - Follow least privilege
   - Regular security scanning
   - Audit logs

---

This primer provides a comprehensive understanding of deployment and DevOps practices. These practices are essential for reliably delivering software to production and maintaining it at scale.
