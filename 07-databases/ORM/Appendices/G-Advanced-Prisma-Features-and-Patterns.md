# Appendix G: Advanced Prisma Features and Patterns

### Purpose of This Appendix

While Appendix F focused on Drizzle's advanced capabilities, this appendix is dedicated to Prisma's advanced features. Prisma has a rich ecosystem of extensions, middleware, and advanced query patterns that can significantly enhance your application. This appendix explores those features in depth.

**What you'll find here:**
- **Prisma Client extensions** – building custom methods, overriding queries, and adding computed fields.
- **Prisma middleware** – intercepting queries for logging, auditing, and soft deletes.
- **Advanced relations** – nested writes, filters on relations, and composite unique constraints.
- **Raw SQL with Prisma** – using `$queryRaw` and `$executeRaw` with type safety.
- **Prisma with MongoDB** – using Prisma with a non‑relational database.
- **Prisma Accelerate and Data Proxy** – optimizing for serverless and edge.
- **Prisma Studio** – advanced data visualization and management.
- **Prisma with TypeScript** – advanced type utilities and generics.
- **Prisma performance tuning** – connection pooling, query optimization, and caching.
- **Prisma with GraphQL** – integrating Prisma with GraphQL resolvers.

---

## Appendix G, Section 1: Prisma Client Extensions Deep Dive

Prisma Client extensions allow you to add custom methods, override existing methods, and add computed fields. We covered the basics in Appendix A, but let's explore more advanced patterns.

### 1.1 Adding Custom Methods to Models

You can add custom methods to specific models using the `model` extension.

```typescript
// packages/database/src/prisma/extensions/advanced.ts
import { Prisma } from '@prisma/client'

export const advancedExtensions = Prisma.defineExtension({
  model: {
    user: {
      async findWithOrganizations(this: Prisma.UserDelegate<any>, email: string) {
        // 'this' refers to the Prisma client's user model
        return this.findUnique({
          where: { email },
          include: {
            organizationMembers: {
              include: {
                organization: true,
              },
            },
          },
        })
      },

      async updatePassword(this: Prisma.UserDelegate<any>, userId: string, newPasswordHash: string) {
        return this.update({
          where: { id: userId },
          data: { passwordHash: newPasswordHash },
        })
      },
    },

    project: {
      async getWithTaskStats(this: Prisma.ProjectDelegate<any>, projectId: string) {
        // Using raw SQL for complex aggregation
        const result = await this.client.$queryRaw<Array<{
          id: string
          name: string
          totalTasks: bigint
          completedTasks: bigint
          completionRate: number
        }>>`
          SELECT 
            p.id,
            p.name,
            COUNT(t.id) as total_tasks,
            COUNT(CASE WHEN t.status = 'done' THEN 1 END) as completed_tasks,
            ROUND(CAST(COUNT(CASE WHEN t.status = 'done' THEN 1 END) AS DECIMAL) / COUNT(t.id) * 100, 2) as completion_rate
          FROM projects p
          LEFT JOIN tasks t ON t.project_id = p.id
          WHERE p.id = ${projectId}
          GROUP BY p.id
        `
        return result[0]
      },
    },
  },
})

// Usage
const prisma = new PrismaClient().$extends(advancedExtensions)
const user = await prisma.user.findWithOrganizations('alice@acme.com')
const projectStats = await prisma.project.getWithTaskStats('project-id')
```

### 1.2 Adding Computed Fields

Computed fields are added to the result objects.

```typescript
import { Prisma } from '@prisma/client'

export const computedFieldsExtension = Prisma.defineExtension({
  result: {
    task: {
      // Add a computed field that doesn't exist in the database
      isOverdue: {
        needs: { dueDate: true, completedAt: true },
        compute(task) {
          if (!task.dueDate) return false
          if (task.completedAt) return task.completedAt > task.dueDate
          return new Date() > task.dueDate
        },
      },
      // Add a computed field that depends on a relation
      projectName: {
        needs: { project: { name: true } },
        compute(task) {
          return task.project?.name
        },
      },
    },
    project: {
      taskCount: {
        needs: { tasks: { id: true } },
        compute(project) {
          return project.tasks?.length || 0
        },
      },
    },
  },
})

// Usage
const prisma = new PrismaClient().$extends(computedFieldsExtension)
const task = await prisma.task.findUnique({
  where: { id: 'task-id' },
  include: { project: true },
})
console.log(task.isOverdue) // true/false based on logic
console.log(task.projectName) // project name
```

### 1.3 Customizing Query Behavior

You can override the default query methods to add functionality like soft deletes, tenant isolation, or caching.

```typescript
import { Prisma } from '@prisma/client'

// Soft delete extension (with automatic filtering)
export const softDeleteExtension = Prisma.defineExtension({
  name: 'softDelete',
  query: {
    // Override findMany to exclude soft-deleted records
    $allModels: {
      async findMany({ model, operation, args, query }) {
        // Add a condition to exclude deleted records
        const where = args.where || {}
        if (!('deletedAt' in where)) {
          args.where = {
            ...where,
            deletedAt: null,
          }
        }
        return query(args)
      },
      // Similarly for findUnique, findFirst, etc.
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
      // Override delete to perform soft delete
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
})

// Tenant isolation extension (automatic organization filtering)
export const tenantExtension = (orgId: string) => {
  return Prisma.defineExtension({
    query: {
      project: {
        async findMany({ args, query }) {
          args.where = {
            ...args.where,
            organizationId: orgId,
          }
          return query(args)
        },
        async findUnique({ args, query }) {
          args.where = {
            ...args.where,
            organizationId: orgId,
          }
          return query(args)
        },
        // ... other methods
      },
      task: {
        async findMany({ args, query }) {
          args.where = {
            ...args.where,
            project: {
              organizationId: orgId,
            },
          }
          return query(args)
        },
        // ... other methods
      },
      // Apply to all models that belong to an organization
    },
  })
}
```

### 1.4 Combining Extensions

You can chain extensions for a powerful, customized client.

```typescript
// packages/database/src/prisma/client.ts
import { PrismaClient } from '@prisma/client'
import { softDeleteExtension } from './extensions/soft-delete'
import { computedFieldsExtension } from './extensions/computed-fields'
import { loggingExtension } from './extensions/logging'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
  })
    .$extends(softDeleteExtension)
    .$extends(computedFieldsExtension)
    .$extends(loggingExtension)

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma

// For tenant isolation, create a factory
export function createTenantPrisma(orgId: string) {
  return prisma.$extends(tenantExtension(orgId))
}
```

---

## Appendix G, Section 2: Prisma Middleware

Middleware (also called hooks) allows you to run code before or after queries. Prisma provides query‑level middleware via `$use` or via extensions.

### 2.1 Using `$use` Middleware

The `$use` method is the traditional way to add middleware.

```typescript
// packages/database/src/prisma/middleware.ts
import { Prisma } from '@prisma/client'

export function setupMiddleware(prisma: PrismaClient) {
  // Logging middleware
  prisma.$use(async (params, next) => {
    const before = Date.now()
    const result = await next(params)
    const after = Date.now()
    console.log(`Query ${params.model}.${params.action} took ${after - before}ms`)
    return result
  })

  // Auditing middleware (log all updates)
  prisma.$use(async (params, next) => {
    if (params.action === 'update' && params.model) {
      // Fetch the current record before update
      const before = await (prisma as any)[params.model].findUnique({
        where: params.args.where,
      })
      const result = await next(params)
      // Log the change
      await prisma.activityLog.create({
        data: {
          userId: getCurrentUserId(),
          organizationId: getCurrentOrgId(),
          action: `${params.model}.updated`,
          details: {
            recordId: result.id,
            before,
            after: result,
          },
        },
      })
      return result
    }
    return next(params)
  })

  // Tenant isolation middleware
  prisma.$use(async (params, next) => {
    // Automatically add tenant filter for models that belong to an organization
    const tenantModels = ['Project', 'Task', 'Comment', 'Attachment']
    if (tenantModels.includes(params.model || '') && params.action === 'findMany') {
      const orgId = getCurrentOrgId()
      if (orgId && !params.args.where?.organizationId) {
        params.args.where = {
          ...params.args.where,
          organizationId: orgId,
        }
      }
    }
    return next(params)
  })

  return prisma
}
```

### 2.2 Using Extensions for Middleware

Extensions provide a more type‑safe and composable way to add middleware.

```typescript
import { Prisma } from '@prisma/client'

export const middlewareExtension = Prisma.defineExtension({
  query: {
    $allModels: {
      async $allOperations({ model, operation, args, query }) {
        // This runs for every operation
        const start = performance.now()
        try {
          const result = await query(args)
          const duration = performance.now() - start
          // Log or metrics
          return result
        } catch (error) {
          // Log error
          throw error
        }
      },
    },
  },
})
```

---

## Appendix G, Section 3: Advanced Relations and Nested Writes

Prisma provides powerful APIs for working with relations, including nested writes and filters on relations.

### 3.1 Nested Writes (Create with Relations)

```typescript
// Create a user with an organization membership in one go
const user = await prisma.user.create({
  data: {
    email: 'alice@acme.com',
    passwordHash: 'hashed',
    fullName: 'Alice Johnson',
    organizationMembers: {
      create: {
        organizationId: 'org-id',
        role: 'owner',
      },
    },
  },
})

// Create a project with tasks and comments
const project = await prisma.project.create({
  data: {
    name: 'New Project',
    organizationId: 'org-id',
    createdBy: 'user-id',
    tasks: {
      create: [
        {
          title: 'Task 1',
          createdBy: 'user-id',
          comments: {
            create: [
              { content: 'First comment', authorId: 'user-id' },
            ],
          },
        },
        {
          title: 'Task 2',
          createdBy: 'user-id',
        },
      ],
    },
  },
  include: {
    tasks: {
      include: {
        comments: true,
      },
    },
  },
})
```

### 3.2 Nested Updates

```typescript
// Update a project and its tasks
const updated = await prisma.project.update({
  where: { id: 'project-id' },
  data: {
    name: 'Updated Project Name',
    tasks: {
      updateMany: [
        {
          where: { status: 'todo' },
          data: { priority: 'high' },
        },
      ],
      deleteMany: {
        status: 'done',
      },
    },
  },
})
```

### 3.3 Filters on Relations

```typescript
// Find projects that have at least one task with a specific status
const projects = await prisma.project.findMany({
  where: {
    tasks: {
      some: {
        status: 'in_progress',
      },
    },
  },
})

// Find users who have no assigned tasks
const users = await prisma.user.findMany({
  where: {
    assignedTasks: {
      none: {},
    },
  },
})

// Find tasks with at least 5 comments
const popularTasks = await prisma.task.findMany({
  where: {
    comments: {
      some: {
        // We need to use a count condition, which requires raw SQL or a query
      },
    },
  },
})

// Using raw SQL for count condition
const popularTasksRaw = await prisma.$queryRaw<Array<any>>`
  SELECT t.*, COUNT(c.id) as comment_count
  FROM tasks t
  LEFT JOIN comments c ON c.task_id = t.id
  GROUP BY t.id
  HAVING COUNT(c.id) >= 5
`
```

### 3.4 Composite Unique Constraints

```typescript
// In schema.prisma
model OrganizationMember {
  id               String   @id @default(uuid()) @db.Uuid
  organizationId   String   @map("organization_id") @db.Uuid
  userId           String   @map("user_id") @db.Uuid
  role             MemberRole
  joinedAt         DateTime @default(now()) @map("joined_at")
  updatedAt        DateTime @updatedAt @map("updated_at")

  organization     Organization @relation(fields: [organizationId], references: [id], onDelete: Cascade)
  user             User         @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([organizationId, userId])
  @@map("organization_members")
}

// This creates a composite unique constraint
// You can use it in queries:
const member = await prisma.organizationMember.findUnique({
  where: {
    organizationId_userId: {
      organizationId: 'org-id',
      userId: 'user-id',
    },
  },
})
```

---

## Appendix G, Section 4: Raw SQL with Prisma

Prisma supports raw SQL for complex queries that can't be expressed with the ORM's API.

### 4.1 `$queryRaw` with Type Safety

```typescript
// Using $queryRaw with template literals (type-safe)
const users = await prisma.$queryRaw<Array<{
  id: string
  email: string
  full_name: string
}>>`
  SELECT id, email, full_name
  FROM users
  WHERE email LIKE ${'%@acme.com'}
  ORDER BY created_at DESC
`

// Using $queryRaw with tagged template
const searchTerm = 'design'
const tasks = await prisma.$queryRaw`
  SELECT * FROM tasks
  WHERE to_tsvector('english', title) @@ to_tsquery('english', ${searchTerm})
`

// You can also use $queryRawUnsafe (not recommended - risk of SQL injection)
const sql = 'SELECT * FROM users WHERE email = $1'
const usersUnsafe = await prisma.$queryRawUnsafe(sql, 'alice@acme.com')
```

### 4.2 `$executeRaw` for Data Manipulation

```typescript
// Execute raw SQL for updates, inserts, deletes
const result = await prisma.$executeRaw`
  UPDATE tasks
  SET status = 'archived'
  WHERE completed_at < ${cutoffDate}
`

// Execute with returning values (if needed)
const [updated] = await prisma.$queryRaw<Array<{ id: string }>>`
  UPDATE tasks
  SET status = 'archived'
  WHERE completed_at < ${cutoffDate}
  RETURNING id
`
```

### 4.3 Building Dynamic Queries with Raw SQL

```typescript
function buildDynamicQuery(filters: any) {
  const conditions: string[] = []
  const params: any[] = []
  let paramIndex = 1

  if (filters.status) {
    conditions.push(`status = $${paramIndex}`)
    params.push(filters.status)
    paramIndex++
  }
  if (filters.priority) {
    conditions.push(`priority = $${paramIndex}`)
    params.push(filters.priority)
    paramIndex++
  }
  if (filters.search) {
    conditions.push(`title ILIKE $${paramIndex}`)
    params.push(`%${filters.search}%`)
    paramIndex++
  }

  const whereClause = conditions.length > 0
    ? `WHERE ${conditions.join(' AND ')}`
    : ''

  const sql = `SELECT * FROM tasks ${whereClause} ORDER BY created_at DESC`

  return prisma.$queryRawUnsafe(sql, ...params)
}

// Usage
const tasks = await buildDynamicQuery({
  status: 'todo',
  priority: 'high',
  search: 'design',
})
```

---

## Appendix G, Section 5: Prisma with MongoDB

Prisma supports MongoDB as a database provider. The schema and API are slightly different.

### 5.1 Prisma Schema for MongoDB

```prisma
// schema.prisma for MongoDB
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mongodb"
  url      = env("DATABASE_URL")
}

model User {
  id    String @id @default(auto()) @map("_id") @db.ObjectId
  email String @unique
  name  String
  posts Post[]
}

model Post {
  id       String @id @default(auto()) @map("_id") @db.ObjectId
  title    String
  content  String
  author   User   @relation(fields: [authorId], references: [id])
  authorId String @db.ObjectId
  comments Comment[]
}

model Comment {
  id      String @id @default(auto()) @map("_id") @db.ObjectId
  text    String
  post    Post   @relation(fields: [postId], references: [id])
  postId  String @db.ObjectId
}
```

### 5.2 MongoDB-Specific Features

```typescript
// MongoDB uses ObjectId as the default ID type
const user = await prisma.user.create({
  data: {
    email: 'test@example.com',
    name: 'Test User',
  },
})
console.log(user.id) // ObjectId string like "507f191e810c19729de860ea"

// You can use string IDs as well
const user = await prisma.user.create({
  data: {
    id: 'custom-id-123',
    email: 'test@example.com',
    name: 'Test User',
  },
})
```

---

## Appendix G, Section 6: Prisma Accelerate and Data Proxy

### 6.1 Prisma Accelerate

Prisma Accelerate is a connection pooler and query engine proxy that reduces cold starts in serverless environments.

**Setup:**

```bash
pnpm add @prisma/extension-accelerate
```

```typescript
// packages/database/src/prisma/client.ts
import { PrismaClient } from '@prisma/client'
import { withAccelerate } from '@prisma/extension-accelerate'

const prisma = new PrismaClient()
  .$extends(withAccelerate())

export { prisma }
```

**Environment Variables:**

```env
DATABASE_URL="postgresql://..."
PRISMA_ACCELERATE_URL="https://...prisma-data..."
```

### 6.2 Prisma Data Proxy

The Data Proxy provides a similar function but with a different architecture. It's useful for edge environments.

```typescript
import { PrismaClient } from '@prisma/client'
import { PrismaDataProxy } from '@prisma/data-proxy'

const prisma = new PrismaClient({
  adapter: new PrismaDataProxy({
    url: process.env.DATA_PROXY_URL!,
  }),
})
```

---

## Appendix G, Section 7: Prisma with GraphQL

### 7.1 Generating GraphQL Types

```bash
pnpm add @graphql-codegen/cli @graphql-codegen/typescript @graphql-codegen/typescript-resolvers
```

**`codegen.ts`:**

```typescript
import type { CodegenConfig } from '@graphql-codegen/cli'

const config: CodegenConfig = {
  schema: './graphql/schema.graphql',
  generates: {
    './graphql/types.ts': {
      plugins: ['typescript', 'typescript-resolvers'],
      config: {
        useIndexSignature: true,
      },
    },
  },
}
export default config
```

### 7.2 GraphQL Resolvers with Prisma

```typescript
// graphql/resolvers.ts
import { prisma } from '@taskflow/database/prisma/client'

export const resolvers = {
  Query: {
    projects: async (_: any, { orgId }: { orgId: string }) => {
      return prisma.project.findMany({
        where: { organizationId: orgId },
        include: { tasks: true },
      })
    },
    project: async (_: any, { id }: { id: string }) => {
      return prisma.project.findUnique({
        where: { id },
        include: { tasks: true },
      })
    },
    tasks: async (_: any, { projectId }: { projectId: string }) => {
      return prisma.task.findMany({
        where: { projectId },
        include: { assignee: true, comments: true },
      })
    },
  },

  Mutation: {
    createProject: async (_: any, { input }: any) => {
      return prisma.project.create({
        data: {
          name: input.name,
          description: input.description,
          organizationId: input.organizationId,
          createdBy: input.createdBy,
        },
      })
    },
    updateTaskStatus: async (_: any, { taskId, status }: any) => {
      return prisma.task.update({
        where: { id: taskId },
        data: { status },
      })
    },
  },

  Project: {
    tasks: async (project: any) => {
      return prisma.task.findMany({
        where: { projectId: project.id },
      })
    },
    creator: async (project: any) => {
      return prisma.user.findUnique({
        where: { id: project.createdBy },
      })
    },
  },

  Task: {
    assignee: async (task: any) => {
      if (!task.assignedTo) return null
      return prisma.user.findUnique({
        where: { id: task.assignedTo },
      })
    },
    comments: async (task: any) => {
      return prisma.comment.findMany({
        where: { taskId: task.id },
        orderBy: { createdAt: 'asc' },
      })
    },
  },
}
```

### 7.3 Type-Safe GraphQL with Generated Types

```typescript
import { prisma } from '@taskflow/database/prisma/client'
import { Resolvers } from './generated/types'

export const resolvers: Resolvers = {
  Query: {
    projects: async (_, { orgId }) => {
      return prisma.project.findMany({
        where: { organizationId: orgId },
        include: { tasks: true },
      })
    },
  },
  // ...
}
```

---

## Appendix G, Section 8: Prisma Performance Tuning

### 8.1 Connection Pool Tuning

```typescript
const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
      connectionLimit: 20, // Increase for higher concurrency
    },
  },
})
```

### 8.2 Query Optimization

```typescript
// Use select to reduce data transfer
const projects = await prisma.project.findMany({
  select: {
    id: true,
    name: true,
    tasks: {
      select: {
        id: true,
        title: true,
        status: true,
      },
    },
  },
})

// Use distinct
const distinctStatuses = await prisma.task.findMany({
  select: { status: true },
  distinct: ['status'],
})

// Use aggregate functions (via raw SQL for complex ones)
const stats = await prisma.$queryRaw`
  SELECT 
    COUNT(*) as total,
    AVG(estimated_hours) as avg_hours
  FROM tasks
  WHERE project_id = ${projectId}
`
```

### 8.3 Caching with Prisma

```typescript
import { prisma } from '../prisma/client'
import { cache } from 'react'

// Use React's cache for server components
export const getCachedProjects = cache(async (orgId: string) => {
  return prisma.project.findMany({
    where: { organizationId: orgId },
    include: { tasks: true },
  })
})
```

### 8.4 Batch Operations

```typescript
// Use createMany for bulk inserts
await prisma.task.createMany({
  data: [
    { title: 'Task 1', projectId: '...', createdBy: '...' },
    { title: 'Task 2', projectId: '...', createdBy: '...' },
    // ...
  ],
})

// Use deleteMany for bulk deletes
await prisma.task.deleteMany({
  where: {
    status: 'archived',
    completedAt: { lt: cutoffDate },
  },
})

// Use updateMany for bulk updates
await prisma.task.updateMany({
  where: { projectId: '...' },
  data: { priority: 'high' },
})
```

---

## Appendix G, Section 9: Prisma Studio Advanced

Prisma Studio is a GUI for viewing and editing data.

### 9.1 Customizing Studio

```prisma
// schema.prisma
/// @database({ studio: { hidden: true } })
model InternalLog {
  id   String @id
  data Json
}

/// @database({ studio: { defaultDisplay: ['email', 'fullName'] } })
model User {
  id       String @id
  email    String
  fullName String
}
```

### 9.2 Running Studio with Custom Port

```bash
prisma studio --port 5556
```

---

## Conclusion of Appendix G

This appendix has explored the advanced features of Prisma ORM, from custom extensions and middleware to raw SQL, GraphQL integration, and performance tuning. You now have a comprehensive understanding of Prisma's capabilities and can leverage them to build sophisticated, high‑performance applications.
