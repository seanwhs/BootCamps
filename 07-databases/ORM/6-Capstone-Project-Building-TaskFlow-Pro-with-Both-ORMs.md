# Drizzle ORM vs. Prisma ORM Masterclass

## Capstone Project: Building TaskFlow Pro with Both ORMs

### Introduction to the Capstone

Congratulations on reaching the final module! Over the past five parts, you've built a solid foundation—from designing schemas and writing queries to integrating with Next.js and preparing for production. Now, we bring everything together into a single, fully functional application: **TaskFlow Pro**.

In this capstone, you'll implement the same feature set twice—once using Prisma and once using Drizzle—so you can directly compare the developer experience, implementation complexity, performance, and operational characteristics. By the end, you'll have two complete, production‑ready applications, and you'll be equipped to choose the right ORM for your future projects.

---

### Capstone Requirements

We'll implement the following features, all of which we've touched on in previous parts:

| Feature | Description |
|---------|-------------|
| **Authentication & Authorization** | Secure login, registration, and session management with NextAuth.js (JWT). Role‑based access control (RBAC) for organizations. |
| **Multi‑tenancy** | Each user belongs to one or more organizations. Data is isolated per organization. |
| **Complete CRUD** | Create, read, update, delete for projects, tasks, comments, and attachments. |
| **Advanced Search & Filtering** | Search tasks by title, description, status, priority, assignee, and date ranges. |
| **Pagination** | Offset and cursor‑based pagination for task lists. |
| **Transactions** | Atomic operations: create a project with initial tasks, transfer task ownership, etc. |
| **Audit Logging** | Record all user actions (create, update, delete) with details. |
| **Background Jobs** | Process webhook events and send notifications using BullMQ with Redis. |
| **Performance Benchmarking** | Run a benchmark suite to compare query performance and throughput. |
| **Automated Testing** | Unit, integration, and end‑to‑end tests for both ORM implementations. |
| **CI/CD Pipeline** | GitHub Actions workflow to build, test, and deploy. |
| **Docker Deployment** | Containerize the application for consistent environments. |
| **Cloud Deployment** | Deploy to Vercel (frontend) and Neon (database) with monitoring. |
| **Monitoring & Observability** | Structured logging, metrics, and OpenTelemetry tracing. |

---

### Architecture Overview

We'll use the monorepo structure established earlier, with separate packages for the database layer, services, and Next.js app. The key difference is that we'll have **two database packages**—one for Prisma and one for Drizzle—or we can keep them in the same package but with clear separation. For simplicity, we'll keep both in the same `@taskflow/database` package as before, but we'll expose two distinct clients.

The application code will be **ORM‑agnostic** as much as possible, with service classes that abstract the data access. This allows us to swap implementations easily.

```
taskflow-pro/
├── apps/
│   └── nextjs/          # Next.js 16 app with both ORM integrations
├── packages/
│   ├── database/        # Contains both Prisma and Drizzle schemas/clients
│   ├── services/        # Business logic with interfaces (e.g., IProjectService)
│   ├── types/           # Shared TypeScript types
│   └── ui/              # Shared React components
├── infrastructure/      # Docker, Kubernetes, Terraform
├── scripts/             # Benchmark, seed, migration scripts
└── .github/             # GitHub Actions workflows
```

---

### Implementation Plan

We'll implement each feature in a logical order, providing code for both ORMs. For brevity, I'll present key files and explain the differences. The complete repository would contain all files, but I'll highlight the most important ones.

Let's begin.

---

## Capstone, Part 1: Authentication & Authorization

We'll use NextAuth.js with JWT for authentication. Users sign up and log in. After login, they select an organization (or create one) to work in. All subsequent queries are scoped to that organization.

### Database Schema Additions

We already have `users`, `organizations`, and `organization_members` tables. We'll add a `sessions` table (optional, since we use JWT) and ensure passwords are hashed with bcrypt.

### Implementation Steps

1. **Install NextAuth.js**

```bash
pnpm add next-auth @auth/prisma-adapter @auth/drizzle-adapter
```

2. **Set up NextAuth configuration**

Create `app/api/auth/[...nextauth]/route.ts`:

```typescript
// apps/nextjs/app/api/auth/[...nextauth]/route.ts
import NextAuth from 'next-auth'
import CredentialsProvider from 'next-auth/providers/credentials'
import { prisma } from '@taskflow/database/prisma/client'
import { compare } from 'bcryptjs'
import { PrismaAdapter } from '@next-auth/prisma-adapter'

const handler = NextAuth({
  adapter: PrismaAdapter(prisma),
  providers: [
    CredentialsProvider({
      name: 'Credentials',
      credentials: {
        email: { label: 'Email', type: 'text' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        if (!credentials?.email || !credentials?.password) return null
        const user = await prisma.user.findUnique({
          where: { email: credentials.email },
        })
        if (!user) return null
        const isValid = await compare(credentials.password, user.passwordHash)
        if (!isValid) return null
        return { id: user.id, email: user.email, name: user.fullName }
      },
    }),
  ],
  callbacks: {
    async session({ session, token }) {
      // Attach user ID and organization context
      if (token.sub) {
        session.user.id = token.sub
        // We'll fetch the default organization later
      }
      return session
    },
    async jwt({ token, user }) {
      if (user) {
        token.id = user.id
      }
      return token
    },
  },
  session: {
    strategy: 'jwt',
  },
  pages: {
    signIn: '/login',
  },
})

export { handler as GET, handler as POST }
```

For Drizzle, we'd use the Drizzle adapter similarly, but we'll show a unified approach using the service layer.

3. **Create middleware for authentication**

`apps/nextjs/middleware.ts`:

```typescript
import { withAuth } from 'next-auth/middleware'
import { NextResponse } from 'next/server'

export default withAuth(
  function middleware(req) {
    // Additional logic: check organization context
    return NextResponse.next()
  },
  {
    callbacks: {
      authorized: ({ token }) => !!token,
    },
  }
)

export const config = { matcher: ['/dashboard/:path*', '/projects/:path*', '/tasks/:path*'] }
```

4. **Add RBAC middleware**

We'll create a middleware that checks the user's role in the organization for each request. We'll store the current organization in a cookie or session.

---

## Capstone, Part 2: Multi‑tenancy with Organization Context

We need to scope all queries to the user's selected organization. We'll store the organization ID in the session and use it in all database queries.

### Service Layer

We'll create service classes that accept the organization ID as a parameter. For example:

```typescript
// packages/services/src/project.service.ts
import { prisma } from '@taskflow/database/prisma/client'

export class ProjectService {
  constructor(private orgId: string) {}

  async getProjects() {
    return prisma.project.findMany({
      where: { organizationId: this.orgId },
      include: { tasks: true },
    })
  }

  async createProject(data: { name: string; description?: string; createdBy: string }) {
    return prisma.project.create({
      data: { ...data, organizationId: this.orgId },
    })
  }
}
```

We'll also implement the same service using Drizzle, with a factory that returns the appropriate service based on configuration.

### Drizzle Version

```typescript
// packages/services/src/project.service.drizzle.ts
import { db, projects } from '@taskflow/database/drizzle/client'
import { eq } from 'drizzle-orm'

export class DrizzleProjectService {
  constructor(private orgId: string) {}

  async getProjects() {
    return db.query.projects.findMany({
      where: eq(projects.organizationId, this.orgId),
      with: { tasks: true },
    })
  }

  async createProject(data: { name: string; description?: string; createdBy: string }) {
    const [project] = await db.insert(projects).values({
      ...data,
      organizationId: this.orgId,
    }).returning()
    return project
  }
}
```

We'll inject the appropriate service based on an environment variable or configuration.

---

## Capstone, Part 3: Complete CRUD Operations

We'll implement CRUD for **Projects**, **Tasks**, **Comments**, and **Attachments**. We've already written many of these functions in Part 3. Now we'll organize them into services.

### Task Service (Prisma)

```typescript
// packages/services/src/task.service.ts
import { prisma, TaskStatus, TaskPriority } from '@taskflow/database/prisma/client'

export class TaskService {
  constructor(private orgId: string) {}

  async getTasks(filters: any) {
    // Use the advanced filtering from Part 3
    return prisma.task.findMany({
      where: {
        project: { organizationId: this.orgId },
        ...filters,
      },
      include: { assignee: true, creator: true, comments: true },
    })
  }

  async createTask(data: any) {
    // Ensure project belongs to the organization
    const project = await prisma.project.findUnique({
      where: { id: data.projectId, organizationId: this.orgId },
    })
    if (!project) throw new Error('Project not found')
    return prisma.task.create({ data })
  }

  // ... update, delete, etc.
}
```

### Task Service (Drizzle)

Similar structure but using Drizzle's query builder.

---

## Capstone, Part 4: Advanced Search & Filtering

We already implemented filtering in Part 3. We'll expose these via API routes and server actions.

### API Route for Task Search

`apps/nextjs/app/api/tasks/route.ts`:

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { TaskService } from '@taskflow/services/task.service'
import { getServerSession } from 'next-auth'

export async function GET(req: NextRequest) {
  const session = await getServerSession()
  if (!session) return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  const orgId = session.user.orgId // we'd set this
  const service = new TaskService(orgId)
  const searchParams = req.nextUrl.searchParams
  const filters = {
    status: searchParams.get('status'),
    priority: searchParams.get('priority'),
    assignedTo: searchParams.get('assignedTo'),
    search: searchParams.get('search'),
    dueDateFrom: searchParams.get('dueDateFrom'),
    dueDateTo: searchParams.get('dueDateTo'),
  }
  const tasks = await service.getTasks(filters)
  return NextResponse.json(tasks)
}
```

---

## Capstone, Part 5: Pagination

We'll implement both offset and cursor pagination in the services.

### Prisma Cursor Pagination

```typescript
async getTasksCursor(cursor?: { id: string; createdAt: Date }, limit = 10) {
  return prisma.task.findMany({
    where: { project: { organizationId: this.orgId } },
    orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
    take: limit,
    cursor: cursor ? { id: cursor.id } : undefined,
    skip: cursor ? 1 : 0,
  })
}
```

### Drizzle Cursor Pagination

We'll use the `where` with `lt` and `and` as shown in Part 3.

---

## Capstone, Part 6: Transactions

We'll implement transaction examples, such as creating a project with initial tasks and assigning members.

### Prisma Transaction

```typescript
async createProjectWithTasks(projectData: any, tasksData: any[]) {
  return prisma.$transaction(async (tx) => {
    const project = await tx.project.create({
      data: { ...projectData, organizationId: this.orgId },
    })
    const tasks = await tx.task.createMany({
      data: tasksData.map(t => ({ ...t, projectId: project.id })),
    })
    // Log activity
    await tx.activityLog.create({
      data: {
        userId: projectData.createdBy,
        organizationId: this.orgId,
        action: 'project.created',
        details: { projectId: project.id },
      },
    })
    return { project, tasks }
  })
}
```

### Drizzle Transaction

```typescript
async createProjectWithTasks(projectData: any, tasksData: any[]) {
  return db.transaction(async (tx) => {
    const [project] = await tx.insert(projects).values({
      ...projectData,
      organizationId: this.orgId,
    }).returning()
    const tasks = await tx.insert(tasks).values(
      tasksData.map(t => ({ ...t, projectId: project.id }))
    ).returning()
    await tx.insert(activityLogs).values({
      userId: projectData.createdBy,
      organizationId: this.orgId,
      action: 'project.created',
      details: { projectId: project.id },
    })
    return { project, tasks }
  })
}
```

---

## Capstone, Part 7: Audit Logging

We already have the `activity_logs` table. We'll create a middleware that logs all mutations.

### Prisma Middleware (using Prisma's client extensions)

```typescript
// packages/database/src/prisma/client.ts
const prisma = new PrismaClient().$extends({
  query: {
    $allModels: {
      async onBefore({ model, operation, args, query }) {
        // Log the operation
        // We can capture the user from context
        return query(args)
      },
      async onAfter({ result }) {
        // Log success
        return result
      },
    },
  },
})
```

### Drizzle Interceptor

We can wrap the `db` with a proxy that logs queries.

---

## Capstone, Part 8: Background Jobs with BullMQ

We'll set up BullMQ with Redis to process webhook events and send notifications.

### Worker Implementation

```typescript
// packages/jobs/src/worker.ts
import { Worker } from 'bullmq'
import { prisma } from '@taskflow/database/prisma/client'
import { sendWebhook } from './webhook'

const webhookWorker = new Worker('webhook-events', async (job) => {
  const { eventId } = job.data
  const event = await prisma.webhookEvent.findUnique({
    where: { id: eventId },
  })
  if (!event) return
  // Send webhook
  await sendWebhook(event.payload)
  // Update status
  await prisma.webhookEvent.update({
    where: { id: eventId },
    data: { status: 'sent', updatedAt: new Date() },
  })
}, { connection: { host: 'localhost', port: 6379 } })
```

---

## Capstone, Part 9: Performance Benchmarking

We'll reuse the benchmark script from Part 3 but expand it to cover more operations and include the full application context.

---

## Capstone, Part 10: Automated Testing

We'll write unit tests for services, integration tests with Testcontainers, and E2E tests with Playwright. We'll also set up a GitHub Actions workflow to run tests on every push.

### GitHub Actions Workflow

`.github/workflows/test.yml`:

```yaml
name: Test
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: testdb
        ports:
          - 5432:5432
      redis:
        image: redis:7-alpine
        ports:
          - 6379:6379
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v3
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
      - run: pnpm install
      - run: pnpm db:generate
      - run: pnpm db:migrate
      - run: pnpm test
      - run: pnpm test:e2e
```

---

## Capstone, Part 11: Docker Deployment

We already have a Dockerfile and docker-compose. We'll add a production Dockerfile that includes both ORMs.

---

## Capstone, Part 12: Cloud Deployment

We'll deploy the Next.js app to Vercel and the database to Neon. We'll also set up monitoring with Sentry and OpenTelemetry.

---

## Capstone, Part 13: Monitoring & Observability

We'll integrate Winston for logging, Prometheus for metrics, and OpenTelemetry for traces. We'll also set up a dashboard in Grafana.

---

## Capstone, Part 14: Side‑by‑Side Comparison

Now we'll compare the two implementations across several dimensions:

| Criteria | Prisma | Drizzle |
|----------|--------|---------|
| **Developer Experience** | Excellent – declarative schema, easy to learn. | Good – requires SQL knowledge, but powerful. |
| **Type Safety** | Generated types are explicit and robust. | Inferred types, but can be slower in large projects. |
| **Query Capabilities** | Great for CRUD, but complex queries require raw SQL. | Excellent – full SQL power with type safety. |
| **Performance** | Good, but heavier due to Query Engine. | Lighter and faster, especially in serverless. |
| **Cold Start** | Slower (200-400ms) without Accelerate. | Faster (20-50ms) with HTTP drivers. |
| **Edge Support** | Limited without Accelerate. | Excellent. |
| **Migration Workflow** | Built‑in, easy. | Works well with drizzle-kit. |
| **Community & Ecosystem** | Larger community, commercial offerings. | Growing, vibrant community. |
| **Learning Curve** | Gentle. | Steeper for SQL beginners. |
| **Enterprise Features** | Prisma Accelerate, Data Proxy. | Flexible, works with any database. |
| **Overall Recommendation** | Best for CRUD-heavy apps, teams new to SQL. | Best for performance-critical apps, SQL experts, edge/Serverless. |

---

## Final Decision Framework

Based on your project's needs:

- **Choose Prisma if**:
  - You're building a typical web application with standard CRUD.
  - You have a team with mixed skill levels.
  - You value a declarative schema and easy migrations.
  - You're willing to pay for Accelerate if you need serverless optimization.

- **Choose Drizzle if**:
  - Performance is critical (e.g., analytics, real-time).
  - You need edge deployment (Cloudflare Workers, Vercel Edge).
  - You love writing SQL and want full control.
  - You're building a mobile app with SQLite (React Native).
  - You want minimal bundle size and fast cold starts.

---

## Conclusion

You've now completed the entire masterclass! You've built a production‑grade application using both Prisma and Drizzle, and you've gained deep insights into their philosophies, architectures, and tradeoffs. Armed with this knowledge, you can confidently choose the right ORM for your next project, and you'll be able to implement it with best practices from the start.

Thank you for following along. Happy coding!
