# Mastering Inngest: Building Reliable Serverless Workflows with Durable Execution

## Design Resilient Event-Driven Systems Without Managing Queues, Workers, or Workflow Infrastructure

---

# Appendix B: Complete Project Structure & Code Index

This appendix provides a comprehensive overview of the complete project structure built throughout this series, along with a quick-reference index of all code files, their purposes, and the parts where they were introduced.

---

## B.1 Project Directory Structure

```
workflowhub/
├── .env.local                    # Local development environment variables
├── .env.production               # Production environment variables
├── .eslintrc.json                # ESLint configuration
├── .gitignore                    # Git ignore file
├── .prettierrc                   # Prettier configuration
├── docker-compose.prod.yml       # Production Docker Compose
├── Dockerfile                    # Production Docker build
├── lambda.js                     # AWS Lambda handler
├── next.config.js                # Next.js configuration
├── package.json                  # NPM dependencies and scripts
├── serverless.yml                # AWS Serverless configuration
├── tsconfig.json                 # TypeScript configuration
├── vercel.json                   # Vercel deployment configuration
├── vite.config.ts                # Vite test configuration
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml             # CI/CD Pipeline (Part 6)
│
├── public/
│   └── favicon.ico
│
└── src/
    ├── app/
    │   ├── api/
    │   │   ├── health/
    │   │   │   └── route.ts      # Health check endpoint (Part 6)
    │   │   ├── inngest/
    │   │   │   └── route.ts      # Inngest API endpoint (Part 1)
    │   │   ├── workflows/
    │   │   │   ├── trigger/
    │   │   │   │   └── route.ts  # Trigger workflows from API (Part 5)
    │   │   │   ├── status/
    │   │   │   │   └── [runId]/
    │   │   │   │       └── route.ts # Get workflow status (Part 5)
    │   │   │   └── status/
    │   │   │       └── stream/
    │   │   │           └── route.ts # SSE endpoint (Part 5)
    │   │   └── events/
    │   │       └── route.ts       # Send events programmatically (Part 5)
    │   │
    │   ├── admin/
    │   │   └── monitoring/
    │   │       └── page.tsx       # Production monitoring dashboard (Part 6)
    │   │
    │   ├── dashboard/
    │   │   ├── page.tsx           # Main dashboard page (Part 5)
    │   │   ├── ai-content/
    │   │   │   └── page.tsx       # AI content generation UI (Part 5)
    │   │   ├── components/
    │   │   │   ├── TriggerForm.tsx # Trigger workflows from UI (Part 5)
    │   │   │   ├── WorkflowList.tsx # List of workflows (Part 5)
    │   │   │   ├── WorkflowStatus.tsx # Workflow status component (Part 5)
    │   │   │   └── WorkflowProgress.tsx # Progress tracking (Part 5)
    │   │   └── trigger/
    │   │       └── page.tsx       # Event trigger form page (Part 1)
    │   │
    │   ├── workflows/
    │   │   ├── [id]/
    │   │   │   └── page.tsx       # Single workflow view (Part 5)
    │   │   └── new/
    │   │       └── page.tsx       # Create new workflow (Part 5)
    │   │
    │   ├── layout.tsx             # Root layout
    │   └── page.tsx               # Home page
    │
    ├── components/
    │   └── ui/
    │       ├── Button.tsx         # Reusable button component
    │       ├── Card.tsx           # Reusable card component
    │       └── Spinner.tsx        # Loading spinner component
    │
    ├── inngest/
    │   ├── client.ts              # Inngest client configuration (Part 1, 2, 6)
    │   ├── error-handler.ts       # Error handling utilities (Part 2, 6)
    │   ├── middleware/
    │   │   ├── logging.ts         # Logging middleware (Part 1)
    │   │   ├── metrics.ts         # Metrics collection middleware (Part 3, 6)
    │   │   ├── sentry.ts          # Sentry error tracking (Part 6)
    │   │   └── version-tracking.ts # Version tracking (Part 4)
    │   │
    │   ├── functions/
    │   │   ├── user-registration.ts     # User registration workflow (Part 1)
    │   │   ├── order-created.ts        # Order processing workflow (Part 1)
    │   │   ├── invoice-generation.ts   # Invoice generation (Part 2)
    │   │   ├── payment-retry.ts        # Payment with retry (Part 2)
    │   │   ├── saga-pattern-example.ts # Saga pattern (Part 2, 4)
    │   │   ├── reminder-system.ts      # Scheduled reminders (Part 2)
    │   │   ├── bulk-email-campaign.ts  # Bulk email campaign (Part 3)
    │   │   ├── task-scheduler.ts       # Task scheduler (Part 3)
    │   │   ├── image-processing-pipeline.ts # Image processing (Part 3)
    │   │   ├── event-aggregator.ts     # Event aggregator (Part 3)
    │   │   ├── batch-processor.ts      # Batch processor (Part 3)
    │   │   ├── purchase-approval.ts    # Purchase approval (Part 4)
    │   │   ├── customer-onboarding-saga.ts # Customer onboarding (Part 4)
    │   │   ├── subscription-lifecycle.ts # Subscription management (Part 4)
    │   │   ├── multi-level-approval.ts  # Multi-level approval (Part 4)
    │   │   └── ai-content-generation.ts # AI content generation (Part 5)
    │   │
    │   ├── channels/
    │   │   └── pipeline.ts        # Realtime channels (Part 5)
    │   │
    │   ├── helpers/
    │   │   ├── simulate-failure.ts # Failure simulation (Part 1)
    │   │   ├── optimization.ts    # Performance optimization (Part 3)
    │   │   ├── warmup.ts          # Cold start mitigation (Part 3)
    │   │   └── token-bucket.ts    # Rate limiting implementation (Part 3)
    │   │
    │   ├── __tests__/
    │   │   ├── workflow-utils.ts   # Test utilities (Part 2)
    │   │   ├── invoice-generation.test.ts # Unit tests (Part 2)
    │   │   ├── workflow.test.ts    # Workflow unit tests (Part 6)
    │   │   ├── integration.test.ts # Integration tests (Part 6)
    │   │   └── performance.test.ts # Performance tests (Part 6)
    │   │
    │   └── types/
    │       └── events.ts          # Event type definitions
    │
    ├── lib/
    │   ├── actions/
    │   │   ├── workflow.actions.ts # Server actions for workflows (Part 5)
    │   │   ├── events.actions.ts  # Server actions for events (Part 5)
    │   │   └── ai.actions.ts      # Server actions for AI (Part 5)
    │   │
    │   ├── config/
    │   │   └── index.ts           # Configuration validation (Part 6)
    │   │
    │   ├── hooks/
    │   │   ├── useWorkflowStatus.ts # Workflow status hook (Part 5)
    │   │   ├── useSSE.ts          # Server-sent events hook (Part 5)
    │   │   └── useWorkflow.ts     # General workflow hook (Part 5)
    │   │
    │   ├── monitoring/
    │   │   ├── metrics.ts         # Metrics collection (Part 6)
    │   │   └── logger.ts          # Structured logging (Part 6)
    │   │
    │   └── utils/
    │       ├── validation.ts      # Validation utilities
    │       └── date.ts            # Date utilities
    │
    └── styles/
        └── globals.css            # Global styles
```

---

## B.2 Complete File Index by Part

### Part 1: Foundations - Thinking in Events and Durable Execution

| File Path | Purpose | Code Blocks |
|-----------|---------|-------------|
| `src/inngest/client.ts` | Inngest client configuration | Full |
| `src/app/api/inngest/route.ts` | Inngest API endpoint | Full |
| `src/inngest/functions/user-registration.ts` | User registration workflow | Full |
| `src/inngest/functions/order-created.ts` | Order processing workflow | Full |
| `src/app/dashboard/trigger/page.tsx` | Event trigger form UI | Full |
| `src/app/dashboard/page.tsx` | Dashboard page | Full |
| `src/inngest/middleware/logging.ts` | Logging middleware | Partial |
| `src/inngest/helpers/simulate-failure.ts` | Failure simulation | Partial |

### Part 2: Durable Functions, State Management & Fault Tolerance

| File Path | Purpose | Code Blocks |
|-----------|---------|-------------|
| `src/inngest/client.ts` | Enhanced client with tracking middleware | Full |
| `src/inngest/functions/invoice-generation.ts` | Invoice generation workflow | Full |
| `src/inngest/functions/payment-retry.ts` | Payment with retry workflow | Full |
| `src/inngest/functions/saga-pattern-example.ts` | Saga pattern implementation | Full |
| `src/inngest/functions/reminder-system.ts` | Scheduled reminder system | Full |
| `src/inngest/__tests__/workflow-utils.ts` | Test utilities | Full |
| `src/inngest/__tests__/invoice-generation.test.ts` | Unit tests | Full |

### Part 3: High-Performance Workflow Patterns

| File Path | Purpose | Code Blocks |
|-----------|---------|-------------|
| `src/inngest/functions/bulk-email-campaign.ts` | Bulk email campaign with fan-out | Full |
| `src/inngest/functions/task-scheduler.ts` | Multi-tenant task scheduler | Full |
| `src/inngest/functions/image-processing-pipeline.ts` | Image processing with throttling | Full |
| `src/inngest/functions/event-aggregator.ts` | Event aggregator with debouncing | Full |
| `src/inngest/functions/batch-processor.ts` | Batch event processor | Full |
| `src/inngest/helpers/optimization.ts` | Performance optimization utilities | Full |
| `src/inngest/helpers/token-bucket.ts` | Token bucket rate limiter | Full |

### Part 4: Long-Running Workflows & Human-in-the-Loop Automation

| File Path | Purpose | Code Blocks |
|-----------|---------|-------------|
| `src/inngest/functions/purchase-approval.ts` | Purchase approval system | Full |
| `src/inngest/functions/customer-onboarding-saga.ts` | Customer onboarding saga | Full |
| `src/inngest/functions/subscription-lifecycle.ts` | Subscription lifecycle management | Full |
| `src/inngest/functions/multi-level-approval.ts` | Multi-level approval with escalation | Full |
| `src/inngest/version-router.ts` | Version routing middleware | Full |

### Part 5: Modern Full-Stack Integration with React 19 & Next.js 16

| File Path | Purpose | Code Blocks |
|-----------|---------|-------------|
| `src/lib/actions/workflow.actions.ts` | Server actions for workflows | Full |
| `src/lib/actions/ai.actions.ts` | Server actions for AI content | Full |
| `src/lib/hooks/useWorkflowStatus.ts` | Workflow status hook | Full |
| `src/lib/hooks/useSSE.ts` | Server-sent events hook | Full |
| `src/app/api/workflows/status/stream/route.ts` | SSE endpoint | Full |
| `src/app/dashboard/ai-content/page.tsx` | AI content generation UI | Full |
| `src/app/dashboard/components/WorkflowStatus.tsx` | Workflow status component | Full |
| `src/app/dashboard/components/TriggerForm.tsx` | Trigger form component | Full |
| `src/app/dashboard/page.tsx` | Main dashboard with SSE | Full |

### Part 6: Production Deployment, Observability & Operations

| File Path | Purpose | Code Blocks |
|-----------|---------|-------------|
| `src/lib/config/index.ts` | Environment configuration | Full |
| `src/lib/monitoring/metrics.ts` | Metrics collection | Full |
| `src/lib/monitoring/logger.ts` | Structured logging | Full |
| `src/app/api/health/route.ts` | Health check endpoint | Full |
| `src/app/admin/monitoring/page.tsx` | Production monitoring UI | Full |
| `src/inngest/error-handler.ts` | Error handling utilities | Full |
| `src/inngest/client.ts` | Production-ready client | Full |
| `next.config.js` | Next.js production config | Full |
| `vercel.json` | Vercel deployment config | Full |
| `serverless.yml` | AWS Lambda config | Full |
| `Dockerfile` | Production Docker build | Full |
| `docker-compose.prod.yml` | Production Docker Compose | Full |
| `.github/workflows/ci-cd.yml` | CI/CD pipeline | Full |
| `src/inngest/__tests__/workflow.test.ts` | Unit tests | Full |
| `src/inngest/__tests__/integration.test.ts` | Integration tests | Full |
| `src/inngest/__tests__/performance.test.ts` | Performance tests | Full |

---

## B.3 Key File Mappings by Feature

### Authentication & Security

| File | Description |
|------|-------------|
| `src/lib/config/index.ts` | Environment validation and security keys |
| `src/inngest/client.ts` | Event and signing key configuration |
| `next.config.js` | Security headers and CORS configuration |
| `src/inngest/error-handler.ts` | Authentication error handling |

### Database Integration

| File | Description |
|------|-------------|
| `src/lib/config/index.ts` | Database URL configuration |
| `src/inngest/functions/*.ts` | Database operations in workflows |
| `src/app/api/health/route.ts` | Database health check |

### Workflow Definitions

| File | Description |
|------|-------------|
| `src/inngest/functions/user-registration.ts` | User registration workflow |
| `src/inngest/functions/order-created.ts` | Order processing workflow |
| `src/inngest/functions/invoice-generation.ts` | Invoice generation workflow |
| `src/inngest/functions/payment-retry.ts` | Payment retry workflow |
| `src/inngest/functions/bulk-email-campaign.ts` | Email campaign workflow |
| `src/inngest/functions/purchase-approval.ts` | Purchase approval workflow |
| `src/inngest/functions/ai-content-generation.ts` | AI content workflow |

### UI Components

| File | Description |
|------|-------------|
| `src/app/dashboard/page.tsx` | Main dashboard |
| `src/app/dashboard/ai-content/page.tsx` | AI content generator |
| `src/app/dashboard/components/TriggerForm.tsx` | Workflow trigger form |
| `src/app/dashboard/components/WorkflowStatus.tsx` | Status display |
| `src/app/admin/monitoring/page.tsx` | Monitoring dashboard |

### API Routes

| File | Description |
|------|-------------|
| `src/app/api/inngest/route.ts` | Inngest webhook endpoint |
| `src/app/api/workflows/trigger/route.ts` | Workflow trigger API |
| `src/app/api/workflows/status/stream/route.ts` | SSE streaming endpoint |
| `src/app/api/health/route.ts` | Health check endpoint |

### Server Actions

| File | Description |
|------|-------------|
| `src/lib/actions/workflow.actions.ts` | Workflow server actions |
| `src/lib/actions/ai.actions.ts` | AI content server actions |

### Hooks

| File | Description |
|------|-------------|
| `src/lib/hooks/useWorkflowStatus.ts` | Real-time workflow status |
| `src/lib/hooks/useSSE.ts` | Server-sent events handling |

### Monitoring & Observability

| File | Description |
|------|-------------|
| `src/lib/monitoring/metrics.ts` | Metrics collection |
| `src/lib/monitoring/logger.ts` | Structured logging |
| `src/inngest/middleware/sentry.ts` | Error tracking |
| `src/app/admin/monitoring/page.tsx` | Monitoring UI |

### Deployment Configuration

| File | Description |
|------|-------------|
| `vercel.json` | Vercel deployment |
| `serverless.yml` | AWS Lambda deployment |
| `Dockerfile` | Docker container build |
| `docker-compose.prod.yml` | Production Docker orchestration |
| `.github/workflows/ci-cd.yml` | CI/CD pipeline |

---

## B.4 Quick Reference: Function IDs

| Function ID | File | Trigger | Description |
|-------------|------|---------|-------------|
| `user-registration-workflow` | `user-registration.ts` | `user/registered` | Process new user registrations |
| `order-created-workflow` | `order-created.ts` | `order/created` | Process new orders |
| `invoice-generation-workflow` | `invoice-generation.ts` | `invoice/generate` | Generate and send invoices |
| `payment-retry-workflow` | `payment-retry.ts` | `payment/initiated` | Process payments with retry |
| `booking-saga-workflow` | `saga-pattern-example.ts` | `booking/requested` | Saga pattern example |
| `reminder-workflow` | `reminder-system.ts` | `reminder/scheduled` | Scheduled reminders |
| `event-reminder-workflow` | `reminder-system.ts` | `event/reminder-requested` | Event reminders |
| `bulk-email-campaign-workflow` | `bulk-email-campaign.ts` | `campaign/triggered` | Bulk email campaigns |
| `task-scheduler-workflow` | `task-scheduler.ts` | `task/scheduled` | Task scheduling |
| `tenant-concurrency-workflow` | `task-scheduler.ts` | `tenant/task/created` | Tenant-specific concurrency |
| `image-processing-workflow` | `image-processing-pipeline.ts` | `images/processing-requested` | Image processing |
| `event-aggregator-workflow` | `event-aggregator.ts` | `user/action` | Event aggregation |
| `batch-processor-workflow` | `batch-processor.ts` | `event/to/process` | Batch processing |
| `purchase-approval-workflow` | `purchase-approval.ts` | `purchase/requested` | Purchase approval |
| `customer-onboarding-saga` | `customer-onboarding-saga.ts` | `customer/onboarding-requested` | Customer onboarding |
| `subscription-lifecycle-workflow` | `subscription-lifecycle.ts` | `subscription/created` | Subscription management |
| `multi-level-approval-workflow` | `multi-level-approval.ts` | `request/approval-requested` | Multi-level approval |
| `ai-content-generation-workflow` | `ai-content-generation.ts` | `ai/content-generation-requested` | AI content generation |

---

## B.5 Event Reference

| Event Name | Schema | Used In | Description |
|------------|--------|---------|-------------|
| `user/registered` | `userId`, `email`, `name`, `plan` | Part 1, 5 | User registration |
| `order/created` | `orderId`, `userId`, `total`, `items`, `paymentMethod` | Part 1 | Order creation |
| `invoice/generate` | `orderId`, `userId`, `items`, `billingAddress` | Part 2 | Invoice generation |
| `payment/initiated` | `paymentId`, `userId`, `amount`, `currency`, `paymentMethod` | Part 2 | Payment processing |
| `booking/requested` | `bookingId`, `userId`, `flightId`, `hotelId`, `carId` | Part 2 | Saga pattern |
| `reminder/scheduled` | `reminderId`, `userId`, `email`, `message`, `scheduledFor`, `recurrence` | Part 2 | Scheduled reminders |
| `event/reminder-requested` | `eventId`, `userId`, `email`, `eventName`, `eventTime`, `notifyBefore` | Part 2 | Event reminders |
| `campaign/triggered` | `campaignId`, `name`, `subject`, `htmlContent`, `recipients` | Part 3 | Email campaigns |
| `task/scheduled` | `taskId`, `tenantId`, `type`, `priority`, `payload` | Part 3 | Task scheduling |
| `tenant/task/created` | `taskId`, `tenantId`, `data` | Part 3 | Tenant tasks |
| `images/processing-requested` | `batchId`, `userId`, `images`, `priority` | Part 3 | Image processing |
| `user/action` | `userId`, `action`, `resourceId`, `metadata` | Part 3 | Event aggregation |
| `event/to/process` | Any data | Part 3 | Batch processing |
| `purchase/requested` | `purchaseId`, `userId`, `department`, `amount`, `description`, `vendor`, `items`, `urgency` | Part 4 | Purchase approval |
| `purchase/approved` | `purchaseId`, `approved`, `approver`, `comments` | Part 4 | Approval decision |
| `customer/onboarding-requested` | `customerId`, `email`, `companyName`, `plan`, `billingAddress`, `contactName` | Part 4 | Customer onboarding |
| `subscription/created` | `subscriptionId`, `userId`, `planId`, `trialEndsAt`, `billingInterval`, `features` | Part 4 | Subscription lifecycle |
| `request/approval-requested` | `requestId`, `requesterId`, `title`, `description`, `type`, `approvals` | Part 4 | Multi-level approval |
| `request/approval-response` | `requestId`, `level`, `approverId`, `approved`, `comments` | Part 4 | Approval response |
| `ai/content-generation-requested` | `generationId`, `prompt`, `contentType`, `userId` | Part 5 | AI content generation |

---

## B.6 API Endpoints Summary

| Endpoint | Method | Description | Authentication |
|----------|--------|-------------|----------------|
| `/api/inngest` | POST | Receive events | Inngest signature |
| `/api/inngest` | GET | Dev server dashboard | None (dev only) |
| `/api/workflows/trigger` | POST | Trigger workflow | API key (production) |
| `/api/workflows/status/[runId]` | GET | Get workflow status | API key (production) |
| `/api/workflows/status/stream` | GET | SSE stream | API key (production) |
| `/api/events` | POST | Send event | API key (production) |
| `/api/health` | GET | Health check | None |

---

## B.7 Environment Variables Reference

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `INNGEST_EVENT_KEY` | Inngest event signing key | `ev_xxxxxxxxxxxxxxxx` |
| `INNGEST_SIGNING_KEY` | Inngest signing verification key | `sign_xxxxxxxxxxxxxxxx` |
| `NEXT_PUBLIC_APP_URL` | Application public URL | `https://workflowhub.com` |
| `DATABASE_URL` | Database connection string | `postgresql://user:pass@host:5432/db` |
| `JWT_SECRET` | JWT signing secret (min 32 chars) | `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |
| `ENCRYPTION_KEY` | Data encryption key (min 32 chars) | `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |

### Optional Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `RESEND_API_KEY` | Resend email API key | `re_xxxxxxxxxxxxxxxx` |
| `STRIPE_SECRET_KEY` | Stripe payment secret key | `sk_live_xxxxxxxxxxxxxxxx` |
| `OPENAI_API_KEY` | OpenAI API key | `sk-proj-xxxxxxxxxxxxxxxx` |
| `SENTRY_DSN` | Sentry error tracking DSN | `https://...@...ingest.sentry.io/...` |
| `REDIS_URL` | Redis connection string | `redis://localhost:6379` |
| `LOG_LEVEL` | Logging level | `debug`, `info`, `warn`, `error` |
| `RATE_LIMIT_WINDOW` | Rate limit window | `60s` |
| `RATE_LIMIT_MAX_REQUESTS` | Max requests per window | `100` |

### Development Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `INNGEST_DEV` | Enable dev server | `true` |
| `NODE_ENV` | Node environment | `development` |

---

## B.8 Scripts Reference

### Package.json Scripts

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "type-check": "tsc --noEmit",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:integration": "vitest run --config vitest.integration.config.ts",
    "test:performance": "vitest run --config vitest.performance.config.ts",
    "test:smoke": "vitest run --config vitest.smoke.config.ts",
    "test:coverage": "vitest run --coverage",
    "inngest:dev": "inngest-cli dev",
    "deploy:vercel": "vercel --prod",
    "deploy:aws": "serverless deploy",
    "docker:build": "docker build -t workflowhub .",
    "docker:run": "docker-compose -f docker-compose.prod.yml up"
  }
}
```

---

This appendix provides a complete map of the WorkflowHub project structure, making it easy to navigate the codebase and find specific implementations referenced throughout the series.
