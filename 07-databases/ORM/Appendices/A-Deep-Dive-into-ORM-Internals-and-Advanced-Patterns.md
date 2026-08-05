# Appendix A: Deep Dive into ORM Internals and Advanced Patterns

### Purpose of This Appendix

Throughout the main series, we focused on building practical applications with Prisma and Drizzle. However, we deliberately kept some advanced topics—like Prisma Client extensions, Drizzle's relational query API internals, custom migration scripts, and edge‑runtime nuances—out of the main flow to avoid overwhelming beginners. This appendix is your reference for those deep dives.

**What you'll find here:**
- **Prisma Client Extensions** – adding custom methods, middleware, and logging.
- **Drizzle Relational Query API** – mastering `findMany`, `with`, `columns`, and the relation‑style syntax.
- **Drizzle SQL Builder** – raw SQL, `sql` template literals, and type inference tricks.
- **Transactions Deep Dive** – interactive transactions, savepoints, and concurrent access patterns.
- **Migration Internals** – customizing migrations, handling data migrations, and zero‑downtime strategies.
- **Connection Management** – pooling, timeouts, and retry logic in serverless.
- **Edge Runtime Compatibility** – making both ORMs work on Vercel Edge, Cloudflare Workers, and other edge platforms.

This appendix is **code‑heavy** and assumes you're comfortable with the basics from the main series. Let's dive in.

---

## Appendix A, Section 1: Prisma Client Extensions

Prisma Client extensions allow you to add custom methods, override existing behavior, and add middleware (hooks) to your Prisma Client. This is the primary way to add cross‑cutting concerns like logging, auditing, and soft deletes.

### Target

We'll build a Prisma Client extension that:
- Adds a `softDelete` method to all models.
- Automatically logs every query with execution time.
- Adds a custom `findManyWithCount` method that returns both data and total count in one call.

### Concept

Prisma extensions are defined using `$extends()`. They can:
- Add new methods at the client, model, or result level.
- Override existing query methods via `query` or `model` hooks.
- Add computed fields to returned objects.

We'll use the `query` hook to intercept `findMany`, `update`, `delete`, etc., and add our logic.

### Implementation

**File:** `packages/database/src/prisma/extensions.ts`

```typescript
// packages/database/src/prisma/extensions.ts
import { Prisma } from '@prisma/client'
import { logger } from '../logger'

// 1. Soft delete extension – adds a `deletedAt` field to models (we'd need to add this to schema first)
// We'll simulate with a filter on `findMany` that excludes soft-deleted records.
const softDeleteExtension = Prisma.defineExtension({
  name: 'softDelete',
  query: {
    $allModels: {
      async findMany({ model, operation, args, query }) {
        // Inject a filter to exclude soft-deleted records unless explicitly requested
        const where = args.where || {}
        // If no explicit `deletedAt` filter, add one to exclude deleted
        if (!('deletedAt' in where) && !('deletedAt' in (args as any).includeDeleted)) {
          args.where = {
            ...where,
            deletedAt: null,
          }
        }
        return query(args)
      },
      // Also modify `findUnique`, `findFirst`, etc.
      async findUnique({ args, query }) {
        const where = args.where || {}
        if (!('deletedAt' in where)) {
          args.where = {
            ...where,
            deletedAt: null,
          }
        }
        return query(args)
      },
      // Intercept `delete` to perform soft delete instead
      async delete({ model, args, query }) {
        // Instead of hard delete, update deletedAt
        const id = args.where.id
        return (prisma as any)[model].update({
          where: { id },
          data: { deletedAt: new Date() },
        })
      },
    },
  },
  // Add a model-level method to include deleted records
  model: {
    $allModels: {
      async includeDeleted<T>(this: T) {
        // This is a hack; we can't easily add dynamic methods.
        // We'll instead use a global flag via context.
        // See the official Prisma docs for better patterns.
      },
    },
  },
})

// 2. Logging extension – logs query execution time
const loggingExtension = Prisma.defineExtension({
  name: 'logging',
  query: {
    $allModels: {
      async $allOperations({ model, operation, args, query }) {
        const start = performance.now()
        const result = await query(args)
        const duration = performance.now() - start
        logger.info(`Prisma query ${model}.${operation} took ${duration.toFixed(2)}ms`, {
          model,
          operation,
          duration,
          args: JSON.stringify(args).slice(0, 500), // truncate
        })
        return result
      },
    },
  },
})

// 3. Extension to add `findManyWithCount` to the client
const paginationExtension = Prisma.defineExtension({
  name: 'pagination',
  client: {
    $findManyWithCount: async function<T>(
      this: PrismaClient,
      model: string,
      args: any
    ): Promise<{ data: T[]; count: number }> {
      // We need to use the client's internal methods; this is simplified.
      // In practice, you'd use the model's `findMany` and `count` separately.
      const client = this as any
      const data = await client[model].findMany(args)
      const count = await client[model].count({ where: args.where })
      return { data, count }
    },
  },
})

// Combine extensions
export const extendedPrisma = (prisma: PrismaClient) => {
  return prisma
    .$extends(softDeleteExtension)
    .$extends(loggingExtension)
    .$extends(paginationExtension)
}

// Usage:
// const prismaWithExtensions = extendedPrisma(new PrismaClient())
// const result = await prismaWithExtensions.$findManyWithCount('project', { where: { status: 'active' } })
```

### Verification

Create a test file to verify the logging and soft delete behavior.

```typescript
// scripts/test-extension.ts
import { PrismaClient } from '@prisma/client'
import { extendedPrisma } from '../packages/database/src/prisma/extensions'

async function test() {
  const prisma = new PrismaClient()
  const extended = extendedPrisma(prisma)

  // Test logging: a query should be logged
  const projects = await extended.project.findMany({ take: 1 })
  console.log('Projects:', projects)

  // Test soft delete: delete a project (should set deletedAt)
  if (projects.length) {
    await extended.project.delete({ where: { id: projects[0].id } })
    // Now findMany should exclude it
    const remaining = await extended.project.findMany()
    console.log('Remaining after soft delete:', remaining.length)
  }

  // Test findManyWithCount
  const result = await extended.$findManyWithCount('project', { where: { status: 'active' } })
  console.log('With count:', result.count)
}

test().catch(console.error)
```

---

## Appendix A, Section 2: Drizzle Relational Query API

Drizzle's relational query API (`findMany`, `findFirst`, etc.) provides a convenient way to fetch related data without writing explicit joins. It's inspired by Prisma's `include` syntax but uses a different mechanism.

### Target

We'll explore the full capabilities of `findMany` with `with`, `columns`, and nested relations. We'll also see how to use `findFirst`, `findMany`, and `findById` (via `where`).

### Concept

Drizzle's relational query API generates SQL joins behind the scenes. You specify:
- `with` – which relations to include (can be nested).
- `columns` – which fields to select from the main table and from relations (using `true` for all, or an object).
- `where` – filtering using the familiar `where` conditions.
- `orderBy`, `limit`, `offset` – standard pagination.

The API is available on `db.query.{tableName}` after you define relations.

### Implementation

We'll use the schema from Part 2. Here's a comprehensive example:

**File:** `scripts/drizzle-relational.ts`

```typescript
// scripts/drizzle-relational.ts
import { db } from '../packages/database/src/drizzle/client'
import { users, organizations, projects, tasks, comments } from '../packages/database/src/drizzle/schema'
import { eq, and, or, sql } from 'drizzle-orm'

async function relationalExamples() {
  // 1. Find a user with their organization memberships and organizations
  const userWithOrgs = await db.query.users.findFirst({
    where: eq(users.email, 'alice@acme.com'),
    with: {
      organizationMembers: {
        with: {
          organization: {
            with: {
              projects: {
                columns: { id: true, name: true },
                limit: 5,
                orderBy: (projects, { desc }) => [desc(projects.createdAt)],
              },
            },
          },
        },
      },
    },
  })
  console.log('User with orgs:', JSON.stringify(userWithOrgs, null, 2))

  // 2. Find projects with tasks and task assignees, but only include certain fields
  const projectsWithTasks = await db.query.projects.findMany({
    where: eq(projects.organizationId, 'some-org-id'),
    columns: {
      id: true,
      name: true,
      status: true,
      createdAt: true,
    },
    with: {
      tasks: {
        columns: {
          id: true,
          title: true,
          status: true,
          priority: true,
        },
        with: {
          assignee: {
            columns: {
              id: true,
              fullName: true,
              email: true,
            },
          },
          comments: {
            columns: {
              id: true,
              content: true,
              createdAt: true,
            },
            limit: 3,
            orderBy: (comments, { desc }) => [desc(comments.createdAt)],
          },
        },
        orderBy: (tasks, { desc }) => [desc(tasks.priority)],
        limit: 10,
      },
      creator: {
        columns: { fullName: true },
      },
    },
    orderBy: (projects, { desc }) => [desc(projects.createdAt)],
    limit: 20,
    offset: 0,
  })

  // 3. Using `where` with relational conditions (filtering by related data)
  // This requires using the `sql` template or the `with` approach.
  // For example, find users who are members of an organization with a specific slug:
  const usersInOrg = await db.query.users.findMany({
    where: (users, { exists }) => 
      exists(
        db.select()
          .from(organizationMembers)
          .where(
            and(
              eq(organizationMembers.userId, users.id),
              eq(organizationMembers.organizationId, 
                db.select({ id: organizations.id })
                  .from(organizations)
                  .where(eq(organizations.slug, 'acme'))
                  .limit(1)
              )
            )
          )
      ),
  })

  // 4. Using `findFirst` with ordering and relation limiting
  const latestTaskInProject = await db.query.tasks.findFirst({
    where: eq(tasks.projectId, 'project-id'),
    orderBy: (tasks, { desc }) => [desc(tasks.createdAt)],
    with: {
      assignee: true,
      comments: {
        limit: 1,
        orderBy: (comments, { desc }) => [desc(comments.createdAt)],
      },
    },
  })

  // 5. Using `findMany` with `having` (not directly supported; use groupBy separately)
  // For groupBy, we use the SQL builder.
}

relationalExamples().catch(console.error)
```

### Verification

Run the script with `tsx` and inspect the output. The generated SQL can be logged by setting `logger: true` in the drizzle client.

---

## Appendix A, Section 3: Drizzle SQL Builder and Type Inference

Drizzle's SQL builder is powerful but can be intimidating. This section demystifies the `sql` template literal, conditional types, and how to write type‑safe dynamic queries.

### Target

Write a dynamic query builder that accepts arbitrary filters and sorts, while maintaining full type safety.

### Implementation

```typescript
// scripts/drizzle-dynamic.ts
import { db } from '../packages/database/src/drizzle/client'
import { tasks, users, projects } from '../packages/database/src/drizzle/schema'
import { eq, and, or, ilike, desc, asc, sql, getTableColumns } from 'drizzle-orm'

type TaskFilters = {
  title?: string
  status?: 'backlog' | 'todo' | 'in_progress' | 'in_review' | 'done'
  priority?: 'low' | 'medium' | 'high' | 'urgent'
  assigneeId?: string
  dueDateFrom?: Date
  dueDateTo?: Date
}

function buildTaskQuery(filters: TaskFilters, sort?: { field: keyof typeof tasks; order: 'asc' | 'desc' }) {
  const conditions = []
  if (filters.title) {
    conditions.push(ilike(tasks.title, `%${filters.title}%`))
  }
  if (filters.status) {
    conditions.push(eq(tasks.status, filters.status))
  }
  if (filters.priority) {
    conditions.push(eq(tasks.priority, filters.priority))
  }
  if (filters.assigneeId) {
    conditions.push(eq(tasks.assignedTo, filters.assigneeId))
  }
  if (filters.dueDateFrom) {
    conditions.push(sql`${tasks.dueDate} >= ${filters.dueDateFrom}`)
  }
  if (filters.dueDateTo) {
    conditions.push(sql`${tasks.dueDate} <= ${filters.dueDateTo}`)
  }

  let query = db.select().from(tasks)
  if (conditions.length) {
    query = query.where(and(...conditions))
  }
  if (sort) {
    const orderFn = sort.order === 'asc' ? asc : desc
    query = query.orderBy(orderFn(tasks[sort.field]))
  }
  return query
}

async function useDynamicQuery() {
  const filters: TaskFilters = {
    title: 'design',
    status: 'todo',
    priority: 'high',
  }
  const query = buildTaskQuery(filters, { field: 'dueDate', order: 'asc' })
  const results = await query.all()
  console.log('Dynamic query results:', results)
}

useDynamicQuery().catch(console.error)
```

---

## Appendix A, Section 4: Transactions Deep Dive

We covered basic transactions, but here we look at interactive transactions, savepoints, and concurrency patterns.

### Prisma Interactive Transactions

Prisma's interactive transactions allow you to execute queries and use the results within the same transaction, with full control.

```typescript
// packages/database/src/prisma/transactions-advanced.ts
import { prisma } from '../prisma/client'

export async function transferTaskAndLock(taskId: string, newOwnerId: string) {
  return prisma.$transaction(async (tx) => {
    // Lock the task row to prevent concurrent updates
    const task = await tx.$queryRaw<Array<{ id: string }>>`
      SELECT id FROM tasks WHERE id = ${taskId} FOR UPDATE
    `
    if (task.length === 0) throw new Error('Task not found')

    // Check if new owner exists and belongs to the same organization
    const newOwner = await tx.user.findUnique({
      where: { id: newOwnerId },
      include: { organizationMembers: true },
    })
    if (!newOwner) throw new Error('User not found')

    // Update task
    const updated = await tx.task.update({
      where: { id: taskId },
      data: { assignedTo: newOwnerId },
    })

    // Log activity
    await tx.activityLog.create({
      data: {
        userId: newOwnerId,
        organizationId: (await tx.project.findUnique({ where: { id: updated.projectId } }))!.organizationId,
        action: 'task.transferred',
        details: { taskId, newOwnerId },
      },
    })
    return updated
  })
}
```

### Drizzle Transactions with Savepoints

Drizzle transactions support savepoints via `tx.transaction` nested calls.

```typescript
export async function complexTransaction() {
  return db.transaction(async (tx) => {
    // Start a savepoint
    await tx.execute(sql`SAVEPOINT sp1`)
    try {
      // Some operations
      await tx.insert(users).values({ email: 'test@example.com' })
      // If something fails, rollback to savepoint
      await tx.execute(sql`ROLLBACK TO SAVEPOINT sp1`)
    } catch (e) {
      // Handle error
    }
    // Commit the outer transaction
  })
}
```

---

## Appendix A, Section 5: Migration Internals

We covered basic migrations, but here's how to write custom migrations, handle data migrations, and implement zero‑downtime strategies.

### Prisma Custom Migrations

Generate a migration without applying it:

```bash
prisma migrate dev --create-only --name add_new_field
```

Then edit the generated SQL file to add custom logic, e.g., backfilling data.

Example migration file:

```sql
-- prisma/migrations/20250101000000_add_new_field/migration.sql
-- Add column nullable first
ALTER TABLE "tasks" ADD COLUMN "priority_rank" INTEGER;

-- Backfill data
UPDATE "tasks" SET "priority_rank" = 
  CASE priority 
    WHEN 'urgent' THEN 1 
    WHEN 'high' THEN 2 
    WHEN 'medium' THEN 3 
    WHEN 'low' THEN 4 
  END;

-- Make not null
ALTER TABLE "tasks" ALTER COLUMN "priority_rank" SET NOT NULL;
```

Then apply it with `prisma migrate deploy`.

### Drizzle Custom Migrations

Drizzle generates SQL files. You can edit them before applying.

```bash
drizzle-kit generate:pg
# Edit the generated SQL in drizzle/migrations
pnpm drizzle:migrate
```

### Zero‑Downtime Migration Strategy

1. **Add new columns with defaults or nullable.**
2. **Deploy code that writes to both old and new columns.**
3. **Backfill data in the background.**
4. **Switch code to read from new columns.**
5. **Remove old columns in a later migration.**

---

## Appendix A, Section 6: Connection Management and Pooling

### Prisma Connection Pool

Prisma uses a connection pool with a default size of 10. You can configure it via `datasource` block:

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  // connectionLimit = 20
}
```

Or via the client:

```typescript
new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
      connectionLimit: 20,
    },
  },
})
```

### Drizzle Pool with `pg`

```typescript
import { Pool } from 'pg'
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 20, // max connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
})
```

### Serverless Best Practices

- **Prisma:** Use Prisma Accelerate or Data Proxy to manage connections and reduce cold starts.
- **Drizzle:** Use HTTP drivers (Neon, Turso) to avoid TCP connection overhead.

---

## Appendix A, Section 7: Edge Runtime Compatibility

### Vercel Edge

**Prisma:** Needs Prisma Accelerate or Data Proxy. Set `runtime: 'edge'` in the client.

```typescript
const prisma = new PrismaClient({
  adapter: new PrismaNeonHTTP({ connectionString: process.env.DATABASE_URL }),
})
```

**Drizzle:** Use the HTTP driver.

```typescript
import { drizzle } from 'drizzle-orm/neon-http'
import { neon } from '@neondatabase/serverless'

const sql = neon(process.env.DATABASE_URL)
const db = drizzle(sql, { schema })
```

### Cloudflare Workers

**Drizzle:** Use the `@libsql/client` for Turso or the HTTP driver for Neon.

```typescript
import { drizzle } from 'drizzle-orm/libsql'
import { createClient } from '@libsql/client'

const client = createClient({
  url: process.env.TURSO_URL,
  authToken: process.env.TURSO_TOKEN,
})
const db = drizzle(client, { schema })
```

---

## Appendix A, Section 8: Performance Tuning – Indexing and Query Optimization

We covered indexing briefly. Here are concrete recommendations.

### Prisma Indexing

```prisma
model Task {
  // ...
  @@index([projectId, status])
  @@index([assignedTo, dueDate])
  @@index([createdAt])
}
```

### Drizzle Indexing

```typescript
export const tasks = pgTable('tasks', {
  // ...
}, (table) => ({
  idx1: index('task_project_status_idx').on(table.projectId, table.status),
  idx2: index('task_assigned_due_idx').on(table.assignedTo, table.dueDate),
  idx3: index('task_created_at_idx').on(table.createdAt),
}))
```

### Query Optimization Tips

- Use `select` to fetch only needed columns.
- Use `include`/`with` judiciously; too many joins can slow down queries.
- Use `explain` to analyze query plans.
- For large datasets, use cursor pagination instead of offset.
- Use prepared statements (both ORMs do this automatically).

---

## Appendix A, Section 9: Common Pitfalls and Solutions

| Pitfall | Solution |
|---------|----------|
| **Prisma N+1 queries with includes** | Use `select` or batch loading with `findMany`. |
| **Drizzle type inference slow** | Use `drizzle-typegen` to generate types for large projects. |
| **Connection timeout in serverless** | Use HTTP drivers or Accelerate; increase timeout settings. |
| **Migration conflicts** | Use a shadow database (Prisma) or version control snapshots (Drizzle). |
| **Raw SQL injection** | Always use parameterized queries (`$queryRaw` with placeholders). |
| **Memory leaks** | Ensure database connections are closed; use singleton clients. |

---

## Conclusion of Appendix A

This appendix has provided deep dives into the advanced capabilities of both Prisma and Drizzle. You now have the knowledge to customize, optimize, and troubleshoot your ORM of choice at a professional level.
