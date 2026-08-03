# Primer 5: Production Deployment & Monitoring

**Estimated Time**: 15 Minutes
**Prerequisites**: Completion of Primer 4, or basic understanding of Inngest concepts. Familiarity with deployment and cloud platforms assumed.

---

## 1. From Development to Production

You've built and tested your durable workflows locally. Now it's time to deploy them to production where they'll handle real traffic, process critical business logic, and need to be reliable at scale.

**What You'll Learn:**
- Production configuration for Inngest
- Environment variables and secrets management
- Deployment strategies (Vercel, AWS, Docker)
- Monitoring and observability
- Health checks and alerting

---

## 2. Production Configuration

### A. Environment Setup

First, ensure your production environment variables are properly configured:

```bash
# .env.production
# Inngest Configuration
INNGEST_EVENT_KEY="ev_prod_xxxxxxxxxxxxxxxx"
INNGEST_SIGNING_KEY="sign_prod_xxxxxxxxxxxxxxxx"
NEXT_PUBLIC_APP_URL="https://your-app.com"

# Database
DATABASE_URL="postgresql://user:pass@host:5432/database"

# Secrets (generate with: openssl rand -base64 32)
JWT_SECRET="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
ENCRYPTION_KEY="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# External Services
RESEND_API_KEY="re_prod_xxxxxxxxxxxxxxxx"
STRIPE_SECRET_KEY="sk_live_xxxxxxxxxxxxxxxx"
OPENAI_API_KEY="sk-proj-xxxxxxxxxxxxxxxx"

# Monitoring
SENTRY_DSN="https://xxx@xxx.ingest.sentry.io/xxx"
LOG_LEVEL="info"
```

### B. Production-Ready Inngest Client

Configure your Inngest client for production with proper middleware and error handling:

```typescript
// src/inngest/client.ts
import { Inngest, InngestMiddleware } from "inngest";
import { config, isProduction } from "@/lib/config";
import * as Sentry from "@sentry/nextjs";

// Sentry middleware for error tracking
const sentryMiddleware = new InngestMiddleware({
  name: "Sentry Error Tracking",
  init: () => ({
    onFunctionRun: ({ fn, ctx }) => ({
      onStepRun: ({ step, run }) => ({
        transformOutput: ({ output }) => {
          if (output instanceof Error) {
            Sentry.captureException(output, {
              tags: {
                function: fn.id,
                step: step.name,
                runId: ctx.runId,
              },
              extra: {
                event: ctx.event,
              },
            });
          }
          return { output };
        },
      }),
      onFunctionComplete: ({ result }) => {
        if (!result.success) {
          Sentry.captureException(result.error, {
            tags: {
              function: fn.id,
              runId: ctx.runId,
            },
          });
        }
      },
    }),
  }),
});

// Metrics middleware
const metricsMiddleware = new InngestMiddleware({
  name: "Metrics Collection",
  init: () => ({
    onFunctionRun: ({ fn, ctx }) => {
      const startTime = Date.now();
      
      return {
        onFunctionComplete: ({ result }) => {
          const duration = Date.now() - startTime;
          
          // In a real app, send to Prometheus, DataDog, etc.
          console.log("Function execution metrics:", {
            functionId: fn.id,
            runId: ctx.runId,
            duration,
            success: result.success,
          });
        },
      };
    },
  }),
});

// Create the production client
export const inngest = new Inngest({
  id: "workflowhub",
  name: "WorkflowHub",
  
  // Production keys
  eventKey: config.INNGEST_EVENT_KEY,
  signingKey: config.INNGEST_SIGNING_KEY,
  
  // Production middleware
  middleware: isProduction 
    ? [sentryMiddleware, metricsMiddleware]
    : [metricsMiddleware],
  
  // Production retry strategy
  retryFunction: (attempt: number) => ({
    delay: Math.min(Math.pow(2, attempt) * 1000, 60000),
    maxAttempts: 5,
  }),
  
  // Production logger
  logger: isProduction 
    ? {
        debug: () => {},
        info: (msg) => console.log(`[INFO] ${msg}`),
        warn: (msg) => console.warn(`[WARN] ${msg}`),
        error: (msg) => console.error(`[ERROR] ${msg}`),
      }
    : {
        debug: console.debug,
        info: console.info,
        warn: console.warn,
        error: console.error,
      },
});
```

### C. Health Check Endpoint

Add a health check endpoint for monitoring:

```typescript
// src/app/api/health/route.ts
import { NextResponse } from "next/server";
import { config, isProduction } from "@/lib/config";

export async function GET() {
  try {
    const startTime = Date.now();
    
    // Check database connectivity
    const dbHealthy = await checkDatabaseHealth();
    
    // Check Inngest connectivity
    const inngestHealthy = await checkInngestHealth();
    
    const uptime = (Date.now() - startTime) / 1000;
    
    const health = {
      status: dbHealthy && inngestHealthy ? "healthy" : "degraded",
      timestamp: new Date().toISOString(),
      version: process.env.npm_package_version || "unknown",
      services: {
        database: { healthy: dbHealthy },
        inngest: { healthy: inngestHealthy },
      },
      uptime,
    };

    const statusCode = health.status === "healthy" ? 200 : 503;
    return NextResponse.json(health, { status: statusCode });

  } catch (error) {
    return NextResponse.json(
      {
        status: "unhealthy",
        timestamp: new Date().toISOString(),
        error: error.message,
      },
      { status: 503 }
    );
  }
}

async function checkDatabaseHealth(): Promise<boolean> {
  try {
    // In a real app, query your database
    // await prisma.$queryRaw`SELECT 1`;
    return true;
  } catch {
    return false;
  }
}

async function checkInngestHealth(): Promise<boolean> {
  try {
    // In a real app, check Inngest API
    // const response = await fetch("https://api.inngest.com/health");
    // return response.ok;
    return true;
  } catch {
    return false;
  }
}
```

---

## 3. Deployment Strategies

### A. Vercel Deployment

Deploy to Vercel with the following configuration:

```json
// vercel.json
{
  "version": 2,
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/next"
    }
  ],
  "env": {
    "NODE_ENV": "production",
    "INNGEST_EVENT_KEY": "@inngest-event-key",
    "INNGEST_SIGNING_KEY": "@inngest-signing-key",
    "NEXT_PUBLIC_APP_URL": "@app-url",
    "DATABASE_URL": "@database-url"
  },
  "functions": {
    "api/inngest/**/*.ts": {
      "maxDuration": 60,
      "memory": 1024
    }
  }
}
```

```bash
# Deploy to production
vercel --prod

# Deploy to preview (staging)
vercel
```

### B. AWS Lambda Deployment

```yaml
# serverless.yml
service: workflowhub

provider:
  name: aws
  runtime: nodejs20.x
  region: us-east-1
  stage: ${opt:stage, 'prod'}
  memorySize: 1024
  timeout: 60
  environment:
    NODE_ENV: production
    INNGEST_EVENT_KEY: ${env:INNGEST_EVENT_KEY}
    INNGEST_SIGNING_KEY: ${env:INNGEST_SIGNING_KEY}
    NEXT_PUBLIC_APP_URL: ${env:NEXT_PUBLIC_APP_URL}
    DATABASE_URL: ${env:DATABASE_URL}

functions:
  api:
    handler: lambda.handler
    events:
      - http:
          path: /{proxy+}
          method: ANY
          cors: true
      - http:
          path: /api/inngest
          method: POST
          cors: true

plugins:
  - serverless-offline
  - serverless-dotenv-plugin
```

```bash
# Deploy to AWS
serverless deploy

# Deploy to a specific stage
serverless deploy --stage staging
```

### C. Docker Deployment

```dockerfile
# Dockerfile
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM node:20-alpine AS runner

WORKDIR /app
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

CMD ["npm", "start"]
```

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  app:
    build: .
    image: workflowhub:latest
    restart: always
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - INNGEST_EVENT_KEY=${INNGEST_EVENT_KEY}
      - INNGEST_SIGNING_KEY=${INNGEST_SIGNING_KEY}
      - NEXT_PUBLIC_APP_URL=${NEXT_PUBLIC_APP_URL}
      - DATABASE_URL=${DATABASE_URL}
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:15-alpine
    restart: always
    environment:
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=${DB_NAME}
    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    restart: always
    volumes:
      - redis-data:/data

volumes:
  postgres-data:
  redis-data:
```

```bash
# Build and run
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f
```

---

## 4. Monitoring and Observability

### A. Structured Logging

```typescript
// src/lib/monitoring/logger.ts
import { config } from "@/lib/config";

export enum LogLevel {
  DEBUG = "debug",
  INFO = "info",
  WARN = "warn",
  ERROR = "error",
}

interface LogEntry {
  level: LogLevel;
  message: string;
  timestamp: string;
  context?: Record<string, any>;
  error?: Error;
}

export class Logger {
  private static instance: Logger;
  private logLevel: LogLevel;
  
  private constructor() {
    this.logLevel = (config.LOG_LEVEL as LogLevel) || LogLevel.INFO;
  }
  
  static getInstance() {
    if (!Logger.instance) {
      Logger.instance = new Logger();
    }
    return Logger.instance;
  }
  
  log(level: LogLevel, message: string, context?: Record<string, any>, error?: Error) {
    const entry: LogEntry = {
      level,
      message,
      timestamp: new Date().toISOString(),
      context,
      error,
    };
    
    // In production, send to logging service
    if (process.env.NODE_ENV === "production") {
      // Send to DataDog, Logtail, etc.
      console.log(JSON.stringify(entry));
    } else {
      console.log(`[${entry.level.toUpperCase()}] ${entry.message}`, context || "");
    }
  }
  
  debug(message: string, context?: Record<string, any>) {
    this.log(LogLevel.DEBUG, message, context);
  }
  
  info(message: string, context?: Record<string, any>) {
    this.log(LogLevel.INFO, message, context);
  }
  
  warn(message: string, context?: Record<string, any>) {
    this.log(LogLevel.WARN, message, context);
  }
  
  error(message: string, error?: Error, context?: Record<string, any>) {
    this.log(LogLevel.ERROR, message, context, error);
  }
}

export const logger = Logger.getInstance();
```

### B. Metrics Collection

```typescript
// src/lib/monitoring/metrics.ts
interface Metric {
  name: string;
  value: number;
  tags?: Record<string, string>;
  timestamp?: string;
}

class MetricsCollector {
  private metrics: Metric[] = [];
  
  record(name: string, value: number, tags?: Record<string, string>) {
    const metric: Metric = {
      name,
      value,
      tags,
      timestamp: new Date().toISOString(),
    };
    
    this.metrics.push(metric);
    
    // In production, send to metrics service
    if (process.env.NODE_ENV === "production") {
      // Send to Prometheus, DataDog, etc.
      console.log(`[METRIC] ${name}: ${value}`, tags);
    }
    
    // Keep only last 1000 metrics
    if (this.metrics.length > 1000) {
      this.metrics.shift();
    }
  }
  
  getMetrics() {
    return this.metrics;
  }
  
  reset() {
    this.metrics = [];
  }
}

export const metrics = new MetricsCollector();
```

### C. Monitoring Middleware

```typescript
// src/inngest/middleware/monitoring.ts
import { InngestMiddleware } from "inngest";
import { metrics } from "@/lib/monitoring/metrics";

export const monitoringMiddleware = new InngestMiddleware({
  name: "Monitoring",
  init: () => ({
    onFunctionRun: ({ fn, ctx }) => {
      const startTime = Date.now();
      
      // Record function start
      metrics.record(`workflow.${fn.id}.started`, 1, {
        runId: ctx.runId,
      });
      
      return {
        onStepRun: ({ step }) => {
          const stepStart = Date.now();
          
          return {
            transformOutput: ({ output }) => {
              const duration = Date.now() - stepStart;
              
              // Record step completion
              metrics.record(`step.${step.name}.duration`, duration, {
                function: fn.id,
                success: !(output instanceof Error),
              });
              
              return { output };
            },
          };
        },
        onFunctionComplete: ({ result }) => {
          const duration = Date.now() - startTime;
          
          // Record function completion
          metrics.record(`workflow.${fn.id}.duration`, duration, {
            runId: ctx.runId,
            success: result.success,
          });
          
          // Record status
          metrics.record(`workflow.${fn.id}.status`, result.success ? 1 : 0, {
            runId: ctx.runId,
          });
        },
      };
    },
  }),
});
```

---

## 5. Alerting and Incident Response

### A. Alert Configuration

```typescript
// src/lib/monitoring/alerts.ts
import { logger } from "@/lib/monitoring/logger";

interface Alert {
  id: string;
  severity: "info" | "warning" | "critical";
  message: string;
  timestamp: string;
  context?: Record<string, any>;
}

class AlertManager {
  private alerts: Alert[] = [];
  
  send(severity: Alert["severity"], message: string, context?: Record<string, any>) {
    const alert: Alert = {
      id: `alert-${Date.now()}`,
      severity,
      message,
      timestamp: new Date().toISOString(),
      context,
    };
    
    this.alerts.push(alert);
    
    // Log the alert
    logger.warn(`[ALERT] ${severity.toUpperCase()}: ${message}`, context);
    
    // In production, send to alerting service
    if (process.env.NODE_ENV === "production") {
      if (severity === "critical") {
        // Send to PagerDuty, Slack, etc.
        console.log(`🚨 CRITICAL ALERT: ${message}`);
      }
    }
    
    return alert;
  }
  
  getAlerts() {
    return this.alerts;
  }
  
  acknowledge(alertId: string) {
    // Mark alert as acknowledged
  }
}

export const alerts = new AlertManager();

// Example usage in workflow
export const monitoredWorkflow = inngest.createFunction(
  { id: "monitored-workflow" },
  { event: "critical/process" },
  async ({ event, step, logger }) => {
    try {
      // ... workflow logic
    } catch (error) {
      alerts.send("critical", "Critical workflow failed", {
        runId: context.runId,
        error: error.message,
      });
      throw error;
    }
  }
);
```

### B. Production Dashboard UI

```typescript
// src/app/admin/monitoring/page.tsx
'use client';

import { useState, useEffect } from 'react';

interface SystemMetrics {
  totalWorkflows: number;
  activeWorkflows: number;
  completedWorkflows: number;
  failedWorkflows: number;
  avgDuration: number;
  errorRate: number;
}

interface Alert {
  id: string;
  severity: 'info' | 'warning' | 'critical';
  message: string;
  timestamp: string;
  acknowledged: boolean;
}

export default function MonitoringPage() {
  const [metrics, setMetrics] = useState<SystemMetrics | null>(null);
  const [alerts, setAlerts] = useState<Alert[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchMetrics();
    
    // Refresh every 10 seconds
    const interval = setInterval(fetchMetrics, 10000);
    return () => clearInterval(interval);
  }, []);

  async function fetchMetrics() {
    try {
      // In a real app, fetch from your API
      const mockMetrics: SystemMetrics = {
        totalWorkflows: 1247,
        activeWorkflows: 23,
        completedWorkflows: 1198,
        failedWorkflows: 26,
        avgDuration: 2430,
        errorRate: 2.08,
      };
      setMetrics(mockMetrics);
    } catch (error) {
      console.error('Failed to fetch metrics:', error);
    } finally {
      setLoading(false);
    }
  }

  if (loading) {
    return <div>Loading...</div>;
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">System Monitoring</h1>

      {/* Metrics Grid */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
        <MetricCard
          title="Total Workflows"
          value={metrics?.totalWorkflows || 0}
          color="blue"
        />
        <MetricCard
          title="Active"
          value={metrics?.activeWorkflows || 0}
          color="green"
        />
        <MetricCard
          title="Error Rate"
          value={`${metrics?.errorRate || 0}%`}
          color="red"
        />
        <MetricCard
          title="Avg Duration"
          value={`${((metrics?.avgDuration || 0) / 1000).toFixed(1)}s`}
          color="purple"
        />
      </div>

      {/* Alerts */}
      <div className="bg-white rounded-lg shadow">
        <div className="px-6 py-4 border-b border-gray-200">
          <h2 className="text-lg font-semibold">Recent Alerts</h2>
        </div>
        <div className="divide-y divide-gray-200">
          {alerts.length === 0 ? (
            <div className="p-4 text-gray-500">No alerts</div>
          ) : (
            alerts.map((alert) => (
              <div key={alert.id} className="p-4 flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <span className={
                    alert.severity === 'critical' ? 'text-red-600' :
                    alert.severity === 'warning' ? 'text-yellow-600' :
                    'text-blue-600'
                  }>
                    {alert.severity === 'critical' ? '🔴' :
                     alert.severity === 'warning' ? '⚠️' :
                     'ℹ️'}
                  </span>
                  <span>{alert.message}</span>
                </div>
                <span className="text-sm text-gray-500">
                  {new Date(alert.timestamp).toLocaleString()}
                </span>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}

function MetricCard({ title, value, color }: { title: string; value: string | number; color: string }) {
  const colors = {
    blue: 'text-blue-600',
    green: 'text-green-600',
    red: 'text-red-600',
    purple: 'text-purple-600',
  };

  return (
    <div className="bg-white p-4 rounded-lg shadow-sm border border-gray-200">
      <div className="text-sm text-gray-500">{title}</div>
      <div className={`text-2xl font-bold ${colors[color as keyof typeof colors]}`}>
        {value}
      </div>
    </div>
  );
}
```

---

## 6. Production Checklist

Before going to production, ensure you've completed:

### Security
- [ ] All secrets are in environment variables
- [ ] Event signing keys are configured
- [ ] Rate limiting is enabled
- [ ] CORS is properly configured
- [ ] Security headers are set

### Reliability
- [ ] Retry policies are configured
- [ ] Error handling is comprehensive
- [ ] Health checks are implemented
- [ ] Circuit breakers are in place

### Observability
- [ ] Logging is structured
- [ ] Metrics are collected
- [ ] Alerts are configured
- [ ] Dashboard is set up

### Deployment
- [ ] CI/CD pipeline is configured
- [ ] Rollback plan exists
- [ ] Database migrations are automated
- [ ] Load testing has been performed

---

## 7. Summary: Production Deployment

| Component | Purpose | Key Features |
|-----------|---------|--------------|
| **Environment Variables** | Secure configuration | Secrets, API keys, URLs |
| **Health Check** | Monitor system health | Database, Inngest connectivity |
| **Logging** | Debugging and auditing | Structured, levels, context |
| **Metrics** | Performance monitoring | Duration, counts, error rates |
| **Alerts** | Incident notification | Severity levels, escalation |
| **Dashboard** | Visual monitoring | Metrics, alerts, status |

---

## Next Steps

You now know how to deploy and monitor your Inngest workflows in production. The next primer will cover advanced topics including AI workflows and enterprise patterns.
