# Appendix E: Deployment & DevOps Guide

Welcome to Appendix E! This comprehensive guide covers everything you need to know about deploying your React Native app to production, setting up CI/CD pipelines, managing infrastructure, and maintaining your app in the wild. You'll learn how to build a professional DevOps workflow that ensures reliable, automated deployments.

---

## Table of Contents

1. [CI/CD Pipeline Architecture](#cicd-pipeline-architecture)
2. [Advanced GitHub Actions Workflows](#advanced-github-actions-workflows)
3. [EAS Build Advanced Configuration](#eas-build-advanced-configuration)
4. [Infrastructure as Code](#infrastructure-as-code)
5. [Monitoring & Alerting](#monitoring--alerting)
6. [Release Management](#release-management)
7. [Rollback Strategies](#rollback-strategies)
8. [Disaster Recovery](#disaster-recovery)
9. [DevOps Security](#devops-security)

---

## CI/CD Pipeline Architecture

### Complete CI/CD Architecture

```typescript
// docs/devops/architecture.md
/**
 * CI/CD Pipeline Architecture
 * 
 * ┌─────────────────────────────────────────────────────────────────┐
 * │                    DEVELOPMENT WORKFLOW                        │
 * ├─────────────────────────────────────────────────────────────────┤
 * │                                                                 │
 * │  ┌──────────┐     ┌──────────┐     ┌──────────┐              │
 * │  │  Feature │────▶│   PR     │────▶│   Build  │              │
 * │  │  Branch  │     │  Review  │     │   Check  │              │
 * │  └──────────┘     └──────────┘     └──────────┘              │
 * │                       │                  │                     │
 * │                       ▼                  ▼                     │
 * │                 ┌──────────┐     ┌──────────┐                │
 * │                 │  Unit    │     │  Bundle  │                │
 * │                 │  Tests   │     │  Analysis│                │
 * │                 └──────────┘     └──────────┘                │
 * │                       │                  │                     │
 * │                       └────────┬─────────┘                     │
 * │                                ▼                               │
 * │                        ┌──────────────┐                       │
 * │                        │    Merge     │                       │
 * │                        │    to Main   │                       │
 * │                        └──────────────┘                       │
 * │                                │                               │
 * │                                ▼                               │
 * │  ┌──────────────────────────────────────────────────────────┐ │
 * │  │                   STAGING DEPLOYMENT                    │ │
 * │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐ │ │
 * │  │  │ Build    │─▶│ Test     │─▶│ Deploy   │─▶│ Smoke  │ │ │
 * │  │  │ Staging  │  │ E2E      │  │ to EAS   │  │ Tests  │ │ │
 * │  │  └──────────┘  └──────────┘  └──────────┘  └────────┘ │ │
 * │  └──────────────────────────────────────────────────────────┘ │
 * │                                │                               │
 * │                                ▼                               │
 * │  ┌──────────────────────────────────────────────────────────┐ │
 * │  │                 PRODUCTION DEPLOYMENT                   │ │
 * │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐ │ │
 * │  │  │ Build    │─▶│ Review   │─▶│ Deploy   │─▶│ Canary │ │ │
 * │  │  │ Release  │  │ App      │  │ to Store │  │ Release│ │ │
 * │  │  └──────────┘  └──────────┘  └──────────┘  └────────┘ │ │
 * │  └──────────────────────────────────────────────────────────┘ │
 * └─────────────────────────────────────────────────────────────────┘
 */

export const CI_CD_ARCHITECTURE = {
  stages: {
    development: {
      trigger: 'Pull Request',
      steps: [
        'Linting',
        'Type Checking',
        'Unit Tests',
        'Bundle Analysis',
        'Preview Build',
      ],
      artifacts: ['Preview APK', 'Test Reports'],
    },
    staging: {
      trigger: 'Merge to Main',
      steps: [
        'Build Staging APK/IPA',
        'E2E Tests',
        'Deploy to EAS',
        'Smoke Tests',
      ],
      artifacts: ['Staging APK', 'E2E Reports'],
    },
    production: {
      trigger: 'Git Tag / Manual',
      steps: [
        'Build Production',
        'App Review',
        'Deploy to Stores',
        'Canary Release',
        'Full Release',
      ],
      artifacts: ['Production APK/IPA', 'Release Notes'],
    },
  },
};
```

---

## Advanced GitHub Actions Workflows

### Complete Production Workflow

```yaml
# .github/workflows/deploy-production.yml
name: Production Deployment

on:
  release:
    types: [published]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'production'
        type: choice
        options:
          - production
          - staging
      platform:
        description: 'Platform to deploy'
        required: true
        default: 'both'
        type: choice
        options:
          - ios
          - android
          - both

env:
  NODE_VERSION: '18.x'
  EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}
  APP_ENV: production

jobs:
  validate:
    name: Validate Release
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Validate version
        id: version
        run: |
          VERSION=$(node -p "require('./package.json').version")
          echo "version=$VERSION" >> $GITHUB_OUTPUT
          echo "📦 Release version: $VERSION"

      - name: Validate release notes
        run: |
          if [ ! -f "./release-notes/${{ steps.version.outputs.version }}.md" ]; then
            echo "❌ Release notes not found for version ${{ steps.version.outputs.version }}"
            exit 1
          fi

      - name: Run validation suite
        run: |
          npm run lint
          npm run type-check
          npm test -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          files: ./coverage/lcov.info

  build-android:
    name: Build Android
    runs-on: ubuntu-latest
    needs: validate
    if: ${{ github.event.inputs.platform == 'android' || github.event.inputs.platform == 'both' }}
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install EAS CLI
        run: npm install -g eas-cli

      - name: Login to Expo
        run: eas login --non-interactive --username ${{ secrets.EXPO_USERNAME }} --password ${{ secrets.EXPO_PASSWORD }}

      - name: Build Android
        run: eas build --platform android --profile production --non-interactive
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}

      - name: Upload Android Build
        uses: actions/upload-artifact@v3
        with:
          name: android-build
          path: |
            build/*.apk
            build/*.aab

  build-ios:
    name: Build iOS
    runs-on: macos-latest
    needs: validate
    if: ${{ github.event.inputs.platform == 'ios' || github.event.inputs.platform == 'both' }}
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install EAS CLI
        run: npm install -g eas-cli

      - name: Login to Expo
        run: eas login --non-interactive --username ${{ secrets.EXPO_USERNAME }} --password ${{ secrets.EXPO_PASSWORD }}

      - name: Build iOS
        run: eas build --platform ios --profile production --non-interactive
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}

      - name: Upload iOS Build
        uses: actions/upload-artifact@v3
        with:
          name: ios-build
          path: |
            build/*.ipa

  submit-android:
    name: Submit Android to Play Store
    runs-on: ubuntu-latest
    needs: build-android
    if: ${{ github.event.inputs.platform == 'android' || github.event.inputs.platform == 'both' }}
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install EAS CLI
        run: npm install -g eas-cli

      - name: Login to Expo
        run: eas login --non-interactive --username ${{ secrets.EXPO_USERNAME }} --password ${{ secrets.EXPO_PASSWORD }}

      - name: Submit to Google Play
        run: eas submit --platform android --track production --non-interactive
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}
          ANDROID_GOOGLE_SERVICES_JSON: ${{ secrets.ANDROID_GOOGLE_SERVICES_JSON }}

  submit-ios:
    name: Submit iOS to App Store
    runs-on: macos-latest
    needs: build-ios
    if: ${{ github.event.inputs.platform == 'ios' || github.event.inputs.platform == 'both' }}
    environment: production
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: ${{ env.NODE_VERSION }}
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install EAS CLI
        run: npm install -g eas-cli

      - name: Login to Expo
        run: eas login --non-interactive --username ${{ secrets.EXPO_USERNAME }} --password ${{ secrets.EXPO_PASSWORD }}

      - name: Submit to App Store
        run: eas submit --platform ios --non-interactive
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}
          APPLE_ID: ${{ secrets.APPLE_ID }}
          APPLE_TEAM_ID: ${{ secrets.APPLE_TEAM_ID }}
          ASC_APP_ID: ${{ secrets.ASC_APP_ID }}

  monitor:
    name: Monitor Deployment
    runs-on: ubuntu-latest
    needs: [submit-android, submit-ios]
    if: always()
    steps:
      - name: Check deployment status
        run: |
          echo "✅ Deployment completed!"
          echo "📱 Android: ${{ needs.submit-android.result }}"
          echo "📱 iOS: ${{ needs.submit-ios.result }}"
          
      - name: Send notification on failure
        if: ${{ needs.submit-android.result == 'failure' || needs.submit-ios.result == 'failure' }}
        uses: slackapi/slack-github-action@v1.24.0
        with:
          channel-id: '#deployments'
          slack-message: '❌ Production deployment failed! Check GitHub Actions for details.'
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
```

### Automated Rollback Workflow

```yaml
# .github/workflows/rollback.yml
name: Automated Rollback

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to rollback to'
        required: true
      platform:
        description: 'Platform to rollback'
        required: true
        default: 'both'
        type: choice
        options:
          - ios
          - android
          - both

jobs:
  rollback:
    name: Rollback Release
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        with:
          ref: ${{ github.event.inputs.version }}

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18.x'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install EAS CLI
        run: npm install -g eas-cli

      - name: Login to Expo
        run: eas login --non-interactive --username ${{ secrets.EXPO_USERNAME }} --password ${{ secrets.EXPO_PASSWORD }}

      - name: Rollback Android
        if: ${{ github.event.inputs.platform == 'android' || github.event.inputs.platform == 'both' }}
        run: |
          echo "🔄 Rolling back Android to version ${{ github.event.inputs.version }}"
          eas submit --platform android --track production --non-interactive

      - name: Rollback iOS
        if: ${{ github.event.inputs.platform == 'ios' || github.event.inputs.platform == 'both' }}
        run: |
          echo "🔄 Rolling back iOS to version ${{ github.event.inputs.version }}"
          eas submit --platform ios --non-interactive

      - name: Notify rollback
        uses: slackapi/slack-github-action@v1.24.0
        with:
          channel-id: '#deployments'
          slack-message: '⚠️ Rollback to version ${{ github.event.inputs.version }} completed!'
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
```

---

## EAS Build Advanced Configuration

### Multi-Environment Build Configuration

```json
// eas.json - Advanced configuration
{
  "cli": {
    "version": ">= 3.0.0",
    "appVersionSource": "remote"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "channel": "development",
      "ios": {
        "simulator": true,
        "resourceClass": "m1-medium"
      },
      "android": {
        "buildType": "apk",
        "resourceClass": "medium"
      },
      "env": {
        "APP_ENV": "development",
        "API_URL": "https://dev-api.taskflow.app",
        "SENTRY_DSN": "https://dev-sentry-dsn"
      }
    },
    "staging": {
      "distribution": "internal",
      "channel": "staging",
      "ios": {
        "simulator": false,
        "resourceClass": "m1-medium"
      },
      "android": {
        "buildType": "app-bundle",
        "resourceClass": "medium"
      },
      "env": {
        "APP_ENV": "staging",
        "API_URL": "https://staging-api.taskflow.app",
        "SENTRY_DSN": "https://staging-sentry-dsn"
      },
      "secrets": {
        "ANDROID_KEYSTORE_PASSWORD": "$ANDROID_KEYSTORE_PASSWORD",
        "ANDROID_KEY_ALIAS": "$ANDROID_KEY_ALIAS",
        "ANDROID_KEY_PASSWORD": "$ANDROID_KEY_PASSWORD"
      }
    },
    "production": {
      "distribution": "store",
      "channel": "production",
      "autoIncrement": true,
      "ios": {
        "image": "latest",
        "simulator": false,
        "resourceClass": "m1-medium"
      },
      "android": {
        "buildType": "app-bundle",
        "image": "latest",
        "resourceClass": "medium"
      },
      "env": {
        "APP_ENV": "production",
        "API_URL": "https://api.taskflow.app",
        "SENTRY_DSN": "https://production-sentry-dsn"
      },
      "secrets": {
        "ANDROID_KEYSTORE_PASSWORD": "$ANDROID_KEYSTORE_PASSWORD",
        "ANDROID_KEY_ALIAS": "$ANDROID_KEY_ALIAS",
        "ANDROID_KEY_PASSWORD": "$ANDROID_KEY_PASSWORD"
      }
    },
    "production-canary": {
      "extends": "production",
      "channel": "production-canary",
      "distribution": "store",
      "android": {
        "track": "internal"
      },
      "ios": {
        "distribution": "store",
        "beta": true
      }
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "$APPLE_ID",
        "ascAppId": "$ASC_APP_ID",
        "appleTeamId": "$APPLE_TEAM_ID",
        "simulator": false
      },
      "android": {
        "track": "production",
        "serviceAccountKeyPath": "./service-account-key.json",
        "packageName": "com.yourcompany.taskflow"
      }
    },
    "internal": {
      "ios": {
        "appleId": "$APPLE_ID",
        "ascAppId": "$ASC_APP_ID",
        "appleTeamId": "$APPLE_TEAM_ID"
      },
      "android": {
        "track": "internal",
        "serviceAccountKeyPath": "./service-account-key.json",
        "packageName": "com.yourcompany.taskflow"
      }
    }
  }
}
```

---

## Infrastructure as Code

### Terraform Configuration for Backend

```hcl
# terraform/main.tf
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
  region = "us-west-2"
}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "taskflow-vpc"
    Environment = var.environment
  }
}

# Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name        = "taskflow-public-subnet-${count.index}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name        = "taskflow-private-subnet-${count.index}"
    Environment = var.environment
  }
}

# Security Groups
resource "aws_security_group" "app" {
  name        = "taskflow-app-sg"
  description = "Security group for TaskFlow app"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "taskflow-app-sg"
    Environment = var.environment
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "taskflow-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "taskflow-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn           = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "taskflow-api"
      image = "${var.ecr_repository}:latest"
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "MONGODB_URI"
          value = var.mongodb_uri
        },
        {
          name  = "REDIS_URL"
          value = var.redis_url
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/taskflow"
          "awslogs-region"        = "us-west-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

# RDS Database
resource "aws_db_instance" "postgres" {
  identifier     = "taskflow-postgres"
  engine         = "postgres"
  engine_version = "15.3"
  instance_class = "db.t3.medium"
  storage_type   = "gp3"
  storage_encrypted = true
  allocated_storage = 20
  
  db_name  = "taskflow"
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  enabled_cloudwatch_logs_exports = ["postgresql"]
  
  tags = {
    Name        = "taskflow-postgres"
    Environment = var.environment
  }
}

# ElastiCache Redis
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "taskflow-redis"
  replication_group_description = "TaskFlow Redis Cache"
  engine                        = "redis"
  engine_version               = "7.0"
  node_type                    = "cache.t3.micro"
  number_cache_clusters        = 2
  port                         = 6379
  subnet_group_name            = aws_elasticache_subnet_group.main.name
  security_group_ids          = [aws_security_group.redis.id]
  automatic_failover_enabled   = true
  multi_az_enabled            = true
  transit_encryption_enabled   = true
  at_rest_encryption_enabled   = true
  
  tags = {
    Name        = "taskflow-redis"
    Environment = var.environment
  }
}
```

---

## Monitoring & Alerting

### Complete Monitoring Setup

```typescript
// src/monitoring/Setup.ts
import { config } from 'dotenv';
import * as Sentry from '@sentry/react-native';
import { FirebaseAnalytics } from '@react-native-firebase/analytics';
import { FirebaseCrashlytics } from '@react-native-firebase/crashlytics';

/**
 * Production Monitoring Setup
 * 
 * This configures comprehensive monitoring for your app:
 * - Error tracking (Sentry)
 * - Analytics (Firebase)
 * - Performance monitoring
 * - Crash reporting
 * - Custom metrics
 */
export class MonitoringSetup {
  private static instance: MonitoringSetup;
  private isInitialized = false;

  private constructor() {}

  static getInstance(): MonitoringSetup {
    if (!MonitoringSetup.instance) {
      MonitoringSetup.instance = new MonitoringSetup();
    }
    return MonitoringSetup.instance;
  }

  /**
   * Initialize all monitoring services
   */
  async initialize() {
    if (this.isInitialized || __DEV__) return;

    try {
      // Initialize Sentry
      this.initSentry();
      
      // Initialize Firebase
      await this.initFirebase();
      
      // Initialize custom monitoring
      this.initCustomMonitoring();
      
      this.isInitialized = true;
      console.log('✅ Monitoring initialized');
    } catch (error) {
      console.error('❌ Monitoring initialization failed:', error);
    }
  }

  /**
   * Initialize Sentry
   */
  private initSentry() {
    Sentry.init({
      dsn: process.env.EXPO_PUBLIC_SENTRY_DSN,
      environment: process.env.APP_ENV || 'production',
      release: `taskflow@${process.env.APP_VERSION}`,
      enableInExpoDevelopment: false,
      debug: false,
      tracesSampleRate: 0.2,
      profilesSampleRate: 0.1,
      
      // Before send hook for filtering
      beforeSend(event) {
        // Filter out non-critical errors
        if (event.level === 'debug') {
          return null;
        }
        return event;
      },
      
      // Integrations
      integrations: [
        new Sentry.ReactNativeTracing({
          tracingOrigins: ['localhost', /^\//],
          routingInstrumentation: new Sentry.ReactNavigationInstrumentation(),
        }),
      ],
    });

    // Set user context
    Sentry.setContext('app', {
      platform: Platform.OS,
      version: process.env.APP_VERSION,
    });
  }

  /**
   * Initialize Firebase
   */
  private async initFirebase() {
    try {
      // Analytics
      await FirebaseAnalytics.setAnalyticsCollectionEnabled(true);
      await FirebaseAnalytics.setUserId('user_id');
      
      // Crashlytics
      await FirebaseCrashlytics.setCrashlyticsCollectionEnabled(true);
      await FirebaseCrashlytics.setUserId('user_id');
      
      // Set custom attributes
      await FirebaseCrashlytics.setAttribute('platform', Platform.OS);
      await FirebaseCrashlytics.setAttribute('version', process.env.APP_VERSION || '');
      
    } catch (error) {
      console.error('Firebase initialization error:', error);
    }
  }

  /**
   * Initialize custom monitoring
   */
  private initCustomMonitoring() {
    // Track app start
    this.trackAppStart();
    
    // Monitor performance
    this.setupPerformanceMonitoring();
    
    // Set up error handlers
    this.setupErrorHandlers();
  }

  /**
   * Track app start
   */
  private trackAppStart() {
    const startTime = Date.now();
    
    // Track when app becomes active
    AppState.addEventListener('change', (state) => {
      if (state === 'active') {
        const loadTime = Date.now() - startTime;
        Sentry.addBreadcrumb({
          category: 'app',
          message: `App started in ${loadTime}ms`,
          level: 'info',
        });
        
        // Track performance metric
        this.trackPerformance('app_startup', loadTime);
      }
    });
  }

  /**
   * Setup performance monitoring
   */
  private setupPerformanceMonitoring() {
    // Monitor JavaScript thread
    setInterval(() => {
      // Track UI thread performance
      const fps = this.getCurrentFPS();
      if (fps < 30) {
        Sentry.addBreadcrumb({
          category: 'performance',
          message: `Low FPS detected: ${fps}`,
          level: 'warning',
        });
      }
      
      // Track memory usage
      const memory = this.getMemoryUsage();
      if (memory > 0.8) {
        Sentry.addBreadcrumb({
          category: 'performance',
          message: `High memory usage: ${(memory * 100).toFixed(0)}%`,
          level: 'warning',
        });
      }
    }, 10000);
  }

  /**
   * Setup error handlers
   */
  private setupErrorHandlers() {
    // Global error handler
    ErrorUtils.setGlobalHandler((error, isFatal) => {
      Sentry.captureException(error, {
        tags: {
          fatal: isFatal ? 'yes' : 'no',
        },
      });
      
      if (isFatal) {
        // Send to crash reporting
        FirebaseCrashlytics.recordError(error);
      }
    });

    // Unhandled promise rejections
    // @ts-ignore - React Native global
    global.ErrorUtils.setGlobalHandler((error) => {
      Sentry.captureException(error);
    });
  }

  /**
   * Track performance metric
   */
  private trackPerformance(name: string, value: number, tags?: Record<string, string>) {
    Sentry.addBreadcrumb({
      category: 'performance',
      message: `${name}: ${value}ms`,
      level: 'info',
      data: { name, value, ...tags },
    });
    
    // Send to Firebase
    FirebaseAnalytics.logEvent('performance_metric', {
      name,
      value,
      ...tags,
    });
  }

  /**
   * Get current FPS (simulated)
   */
  private getCurrentFPS(): number {
    // In production, use actual FPS monitoring
    return 60;
  }

  /**
   * Get memory usage (simulated)
   */
  private getMemoryUsage(): number {
    // @ts-ignore - Memory info
    if (global.performance?.memory) {
      // @ts-ignore
      const { usedJSHeapSize, totalJSHeapSize } = global.performance.memory;
      return usedJSHeapSize / totalJSHeapSize;
    }
    return 0;
  }

  /**
   * Track user interaction
   */
  trackInteraction(name: string, properties?: Record<string, any>) {
    FirebaseAnalytics.logEvent(name, properties);
    Sentry.addBreadcrumb({
      category: 'user',
      message: name,
      level: 'info',
      data: properties,
    });
  }

  /**
   * Track screen view
   */
  trackScreen(screenName: string) {
    FirebaseAnalytics.logScreenView({
      screen_name: screenName,
      screen_class: screenName,
    });
    
    Sentry.addBreadcrumb({
      category: 'navigation',
      message: `Screen: ${screenName}`,
      level: 'info',
    });
  }
}

export const monitoringSetup = MonitoringSetup.getInstance();
```

---

## Release Management

### Release Management System

```typescript
// src/release/ReleaseManager.ts
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as Updates from 'expo-updates';

interface ReleaseInfo {
  version: string;
  buildNumber: number;
  releaseDate: string;
  features: string[];
  bugFixes: string[];
  breakingChanges?: string[];
  rolloutPercentage?: number;
}

interface ReleaseChecklist {
  codeFreeze: boolean;
  testsPassed: boolean;
  qaApproved: boolean;
  storeReady: boolean;
  marketingReady: boolean;
  supportReady: boolean;
}

/**
 * Release Management System
 * 
 * This manages the entire release process:
 * - Version management
 * - Release checklists
 * - Rollout strategies
 * - Feature flags
 * - Release notes generation
 */
export class ReleaseManager {
  private static instance: ReleaseManager;
  private currentRelease: ReleaseInfo | null = null;
  private checklists: Map<string, ReleaseChecklist> = new Map();

  private constructor() {}

  static getInstance(): ReleaseManager {
    if (!ReleaseManager.instance) {
      ReleaseManager.instance = new ReleaseManager();
    }
    return ReleaseManager.instance;
  }

  /**
   * Create a new release
   */
  async createRelease(version: string): Promise<ReleaseInfo> {
    const release: ReleaseInfo = {
      version,
      buildNumber: await this.getNextBuildNumber(),
      releaseDate: new Date().toISOString(),
      features: [],
      bugFixes: [],
      rolloutPercentage: 100,
    };
    
    await this.saveRelease(release);
    this.currentRelease = release;
    
    return release;
  }

  /**
   * Get next build number
   */
  private async getNextBuildNumber(): Promise<number> {
    try {
      const lastBuild = await AsyncStorage.getItem('@TaskFlow/lastBuildNumber');
      const current = lastBuild ? parseInt(lastBuild, 10) : 0;
      const next = current + 1;
      await AsyncStorage.setItem('@TaskFlow/lastBuildNumber', String(next));
      return next;
    } catch {
      return 1;
    }
  }

  /**
   * Save release
   */
  private async saveRelease(release: ReleaseInfo) {
    try {
      const releases = await this.getReleases();
      releases.push(release);
      await AsyncStorage.setItem('@TaskFlow/releases', JSON.stringify(releases));
    } catch (error) {
      console.error('Error saving release:', error);
    }
  }

  /**
   * Get all releases
   */
  async getReleases(): Promise<ReleaseInfo[]> {
    try {
      const data = await AsyncStorage.getItem('@TaskFlow/releases');
      return data ? JSON.parse(data) : [];
    } catch {
      return [];
    }
  }

  /**
   * Get release checklist
   */
  async getReleaseChecklist(version: string): Promise<ReleaseChecklist> {
    if (this.checklists.has(version)) {
      return this.checklists.get(version)!;
    }
    
    const checklist: ReleaseChecklist = {
      codeFreeze: false,
      testsPassed: false,
      qaApproved: false,
      storeReady: false,
      marketingReady: false,
      supportReady: false,
    };
    
    this.checklists.set(version, checklist);
    return checklist;
  }

  /**
   * Update release checklist
   */
  async updateReleaseChecklist(
    version: string,
    updates: Partial<ReleaseChecklist>
  ) {
    const checklist = await this.getReleaseChecklist(version);
    Object.assign(checklist, updates);
    this.checklists.set(version, checklist);
  }

  /**
   * Check if release is ready
   */
  async isReleaseReady(version: string): Promise<boolean> {
    const checklist = await this.getReleaseChecklist(version);
    return Object.values(checklist).every(value => value === true);
  }

  /**
   * Get release status
   */
  async getReleaseStatus(version: string) {
    const checklist = await this.getReleaseChecklist(version);
    const isReady = await this.isReleaseReady(version);
    
    return {
      version,
      isReady,
      checklist,
      progress: this.getChecklistProgress(checklist),
      estimatedRemaining: this.estimateRemainingTime(checklist),
    };
  }

  /**
   * Get checklist progress
   */
  private getChecklistProgress(checklist: ReleaseChecklist): number {
    const total = Object.keys(checklist).length;
    const completed = Object.values(checklist).filter(v => v).length;
    return (completed / total) * 100;
  }

  /**
   * Estimate remaining time
   */
  private estimateRemainingTime(checklist: ReleaseChecklist): string {
    const remaining = Object.values(checklist).filter(v => !v).length;
    const estimates: Record<string, string> = {
      0: 'Ready to release!',
      1: '~1 hour remaining',
      2: '~2-3 hours remaining',
      3: '~4-6 hours remaining',
      4: '~1 day remaining',
      5: '~1-2 days remaining',
      6: '~2-3 days remaining',
    };
    return estimates[remaining] || 'Timeframe unknown';
  }

  /**
   * Generate release notes
   */
  async generateReleaseNotes(version: string): Promise<string> {
    const releases = await this.getReleases();
    const release = releases.find(r => r.version === version);
    if (!release) return 'Release notes not available';
    
    let notes = `# TaskFlow ${version} Release Notes\n\n`;
    notes += `## Release Date: ${new Date(release.releaseDate).toLocaleDateString()}\n\n`;
    
    if (release.features.length > 0) {
      notes += '## ✨ New Features\n';
      release.features.forEach(feature => {
        notes += `- ${feature}\n`;
      });
      notes += '\n';
    }
    
    if (release.bugFixes.length > 0) {
      notes += '## 🐛 Bug Fixes\n';
      release.bugFixes.forEach(fix => {
        notes += `- ${fix}\n`;
      });
      notes += '\n';
    }
    
    if (release.breakingChanges?.length) {
      notes += '## ⚠️ Breaking Changes\n';
      release.breakingChanges.forEach(change => {
        notes += `- ${change}\n`;
      });
      notes += '\n';
    }
    
    return notes;
  }

  /**
   * Perform canary release
   */
  async performCanaryRelease(version: string, percentage: number = 10) {
    // Update release with rollout percentage
    const releases = await this.getReleases();
    const index = releases.findIndex(r => r.version === version);
    if (index === -1) {
      throw new Error('Release not found');
    }
    
    releases[index].rolloutPercentage = percentage;
    await AsyncStorage.setItem('@TaskFlow/releases', JSON.stringify(releases));
    
    console.log(`📱 Canary release: ${version} at ${percentage}%`);
    
    // Check rollout
    await this.monitorRollout(version);
  }

  /**
   * Monitor rollout
   */
  private async monitorRollout(version: string) {
    // In production, monitor crash rates and performance
    console.log(`📊 Monitoring rollout for ${version}`);
    
    // Simulated monitoring
    return {
      version,
      status: 'healthy',
      crashRate: 0.01,
      performance: 'normal',
    };
  }

  /**
   * Complete release
   */
  async completeRelease(version: string) {
    // Set rollout to 100%
    const releases = await this.getReleases();
    const index = releases.findIndex(r => r.version === version);
    if (index === -1) {
      throw new Error('Release not found');
    }
    
    releases[index].rolloutPercentage = 100;
    await AsyncStorage.setItem('@TaskFlow/releases', JSON.stringify(releases));
    
    console.log(`✅ Release ${version} completed`);
  }
}

export const releaseManager = ReleaseManager.getInstance();
```

---

## DevOps Security

### Security Best Practices

```typescript
// src/devops/Security.ts
/**
 * DevOps Security Best Practices
 * 
 * This documents security practices for your DevOps pipeline:
 * - Secret management
 * - Access control
 * - Security scanning
 * - Compliance
 */

export const DevOpsSecurity = {
  // 1. Secret Management
  secrets: {
    bestPractices: [
      'Never commit secrets to version control',
      'Use environment variables for all secrets',
      'Rotate secrets regularly',
      'Use dedicated secret management service (e.g., AWS Secrets Manager)',
    ],
    tools: [
      'GitHub Secrets',
      'AWS Secrets Manager',
      'Azure Key Vault',
      'HashiCorp Vault',
    ],
  },

  // 2. Access Control
  accessControl: {
    bestPractices: [
      'Use principle of least privilege',
      'Implement role-based access control (RBAC)',
      'Enable two-factor authentication for all team members',
      'Review access permissions regularly',
    ],
    roles: [
      'Developer - Read/write to development branches',
      'Lead Developer - Merge to main branch',
      'DevOps - Manage CI/CD pipeline',
      'Admin - Full access',
    ],
  },

  // 3. Security Scanning
  securityScanning: {
    bestPractices: [
      'Run security scans on every PR',
      'Use dependency vulnerability scanning',
      'Implement SAST (Static Application Security Testing)',
      'Implement DAST (Dynamic Application Security Testing)',
    ],
    tools: [
      'GitHub CodeQL',
      'Snyk',
      'OWASP ZAP',
      'SonarQube',
    ],
  },

  // 4. Compliance
  compliance: {
    standards: [
      'GDPR - Data protection for EU users',
      'CCPA - Data protection for California users',
      'SOC2 - Service organization controls',
      'ISO 27001 - Information security management',
    ],
    requirements: [
      'Data encryption at rest and in transit',
      'Audit logging for all sensitive operations',
      'Data retention and deletion policies',
      'Breach notification procedures',
    ],
  },

  // 5. Secure Development Lifecycle
  sdlc: {
    phases: [
      'Requirements - Security requirements defined',
      'Design - Threat modeling',
      'Development - Secure coding practices',
      'Testing - Security testing',
      'Deployment - Security hardening',
      'Maintenance - Vulnerability management',
    ],
    practices: [
      'Code reviews with security focus',
      'Security training for developers',
      'Regular penetration testing',
      'Bug bounty program',
    ],
  },
};
```

---

This appendix provides a comprehensive DevOps and deployment strategy for production React Native applications. By implementing these practices, you'll ensure reliable, secure, and automated deployments for your TaskFlow app.
