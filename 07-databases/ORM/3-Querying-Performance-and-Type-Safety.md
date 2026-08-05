# Drizzle ORM vs. Prisma ORM Masterclass

## Part 3: Querying, Performance, and Type Safety

### Introduction to Part 3

With a production‑ready schema in place, it's time to put our ORMs to work. In this module, we'll explore the full spectrum of data operations—from simple CRUD to complex analytical queries—and compare how Prisma and Drizzle handle each. We'll also dive deep into performance, measuring real‑world benchmarks and understanding the type safety guarantees each ORM provides.

By the end of Part 3, you will:
- Write type‑safe CRUD, bulk, and upsert operations.
- Construct advanced queries with filters, sorting, aggregations, and grouping.
- Use joins and relations to fetch nested data.
- Implement offset and cursor‑based pagination.
- Manage transactions with ACID guarantees.
- Execute raw SQL when needed.
- Measure and compare performance with a custom benchmarking suite.
- Understand the type‑safety mechanisms under the hood.

---

## Part 3, Section 1: Type‑Safe CRUD Operations

CRUD stands for Create, Read, Update, Delete—the basic building blocks of any data‑driven application. Both Prisma and Drizzle offer fully type‑safe APIs for these operations, but the syntax and patterns differ.

### Target

We'll implement a set of utility functions that perform CRUD operations on our TaskFlow Pro models, demonstrating both ORMs side‑by‑side.

### Concept

Type safety means that the compiler catches errors like misspelled column names, passing the wrong data type, or using a non‑existent relation. Both ORMs leverage TypeScript to provide autocompletion and compile‑time checks.

### Implementation

We'll create a new file in the database package that exports functions for both ORMs. For clarity, we'll separate them into distinct namespaces.

**File:** `packages/database/src/crud.ts`

```typescript
// packages/database/src/crud.ts

import { prisma } from './prisma/client'
import { db } from './drizzle/client'
import { 
  users, organizations, projects, tasks, 
  eq, and, or, desc, asc, isNull, sql 
} from './drizzle/schema'
import { hash } from 'bcryptjs'

// =============================================
// PRISMA CRUD OPERATIONS
// =============================================

export namespace PrismaCrud {
  // --- CREATE ---
  export async function createUser(data: {
    email: string
    password: string
    fullName: string
    avatarUrl?: string
  }) {
    const hashed = await hash(data.password, 10)
    return prisma.user.create({
      data: {
        email: data.email,
        passwordHash: hashed,
        fullName: data.fullName,
        avatarUrl: data.avatarUrl,
      },
    })
  }

  export async function createProject(data: {
    organizationId: string
    name: string
    description?: string
    createdBy: string
  }) {
    return prisma.project.create({
      data: {
        organizationId: data.organizationId,
        name: data.name,
        description: data.description,
        createdBy: data.createdBy,
      },
    })
  }

  // --- READ (single) ---
  export async function getUserById(id: string) {
    return prisma.user.findUnique({
      where: { id },
    })
  }

  export async function getUserByEmail(email: string) {
    return prisma.user.findUnique({
      where: { email },
    })
  }

  // --- READ (many) ---
  export async function getProjectsForOrganization(orgId: string, status?: 'active' | 'archived' | 'on_hold') {
    return prisma.project.findMany({
      where: {
        organizationId: orgId,
        ...(status && { status }),
      },
      orderBy: { createdAt: 'desc' },
      include: {
        tasks: {
          select: {
            id: true,
            title: true,
            status: true,
            priority: true,
            assignedTo: true,
          },
        },
        creator: {
          select: {
            id: true,
            fullName: true,
            email: true,
          },
        },
      },
    })
  }

  // --- UPDATE ---
  export async function updateTaskStatus(taskId: string, status: string) {
    return prisma.task.update({
      where: { id: taskId },
      data: { status: status as any }, // cast because Prisma enums are typed
    })
  }

  // --- DELETE ---
  export async function deleteTask(taskId: string) {
    return prisma.task.delete({
      where: { id: taskId },
    })
  }

  // --- UPSERT ---
  export async function upsertOrganization(data: {
    slug: string
    name: string
  }) {
    return prisma.organization.upsert({
      where: { slug: data.slug },
      update: { name: data.name },
      create: {
        slug: data.slug,
        name: data.name,
      },
    })
  }

  // --- BULK CREATE ---
  export async function createManyTasks(tasksData: Array<{
    projectId: string
    title: string
    createdBy: string
    assignedTo?: string
    status?: string
    priority?: string
  }>) {
    return prisma.task.createMany({
      data: tasksData.map(t => ({
        projectId: t.projectId,
        title: t.title,
        createdBy: t.createdBy,
        assignedTo: t.assignedTo,
        status: (t.status || 'backlog') as any,
        priority: (t.priority || 'medium') as any,
      })),
      skipDuplicates: true,
    })
  }
}

// =============================================
// DRIZZLE CRUD OPERATIONS
// =============================================

export namespace DrizzleCrud {
  // --- CREATE ---
  export async function createUser(data: {
    email: string
    password: string
    fullName: string
    avatarUrl?: string
  }) {
    const hashed = await hash(data.password, 10)
    const [user] = await db.insert(users).values({
      email: data.email,
      passwordHash: hashed,
      fullName: data.fullName,
      avatarUrl: data.avatarUrl,
    }).returning()
    return user
  }

  export async function createProject(data: {
    organizationId: string
    name: string
    description?: string
    createdBy: string
  }) {
    const [project] = await db.insert(projects).values({
      organizationId: data.organizationId,
      name: data.name,
      description: data.description,
      createdBy: data.createdBy,
    }).returning()
    return project
  }

  // --- READ (single) ---
  export async function getUserById(id: string) {
    return db.query.users.findFirst({
      where: eq(users.id, id),
    })
  }

  export async function getUserByEmail(email: string) {
    return db.query.users.findFirst({
      where: eq(users.email, email),
    })
  }

  // --- READ (many) with joins ---
  export async function getProjectsForOrganization(orgId: string, status?: 'active' | 'archived' | 'on_hold') {
    // With Drizzle's relational query API
    return db.query.projects.findMany({
      where: (projects, { eq, and }) => 
        and(
          eq(projects.organizationId, orgId),
          status ? eq(projects.status, status) : undefined
        ),
      orderBy: (projects, { desc }) => [desc(projects.createdAt)],
      with: {
        tasks: {
          columns: {
            id: true,
            title: true,
            status: true,
            priority: true,
            assignedTo: true,
          },
        },
        creator: {
          columns: {
            id: true,
            fullName: true,
            email: true,
          },
        },
      },
    })
  }

  // Alternatively, using the SQL-like query builder for more control:
  export async function getProjectsForOrganizationSql(orgId: string, status?: 'active' | 'archived' | 'on_hold') {
    const query = db
      .select()
      .from(projects)
      .where(
        and(
          eq(projects.organizationId, orgId),
          status ? eq(projects.status, status) : sql`true`
        )
      )
      .orderBy(desc(projects.createdAt))
    return query.all()
  }

  // --- UPDATE ---
  export async function updateTaskStatus(taskId: string, status: 'backlog' | 'todo' | 'in_progress' | 'in_review' | 'done') {
    const [updated] = await db.update(tasks)
      .set({ status, updatedAt: new Date() })
      .where(eq(tasks.id, taskId))
      .returning()
    return updated
  }

  // --- DELETE ---
  export async function deleteTask(taskId: string) {
    const [deleted] = await db.delete(tasks)
      .where(eq(tasks.id, taskId))
      .returning()
    return deleted
  }

  // --- UPSERT ---
  export async function upsertOrganization(data: {
    slug: string
    name: string
  }) {
    // Drizzle does not have built-in upsert; we use a manual approach
    const existing = await db.query.organizations.findFirst({
      where: eq(organizations.slug, data.slug),
    })
    if (existing) {
      const [updated] = await db.update(organizations)
        .set({ name: data.name, updatedAt: new Date() })
        .where(eq(organizations.slug, data.slug))
        .returning()
      return updated
    } else {
      const [created] = await db.insert(organizations)
        .values({
          slug: data.slug,
          name: data.name,
        })
        .returning()
      return created
    }
  }

  // --- BULK CREATE ---
  export async function createManyTasks(tasksData: Array<{
    projectId: string
    title: string
    createdBy: string
    assignedTo?: string
    status?: 'backlog' | 'todo' | 'in_progress' | 'in_review' | 'done'
    priority?: 'low' | 'medium' | 'high' | 'urgent'
  }>) {
    // Drizzle's insert supports array values
    const result = await db.insert(tasks).values(
      tasksData.map(t => ({
        projectId: t.projectId,
        title: t.title,
        createdBy: t.createdBy,
        assignedTo: t.assignedTo,
        status: t.status || 'backlog',
        priority: t.priority || 'medium',
      }))
    ).returning()
    return result
  }
}
```

### Concept Notes

- **Prisma's `createMany`** does not return the created records by default (you can use `skipDuplicates`). To get them, you'd need to use `create` in a loop or use transactions.
- **Drizzle's `insert().returning()`** returns the inserted rows, which is convenient.
- **Upsert** in Drizzle requires manual logic; there is a `onConflictDoUpdate` that we could use, but it's less type‑safe. We'll demonstrate a manual approach.
- **Enums** in Prisma are strongly typed; Drizzle uses string literals inferred from the enum definition.

### Verification

Let's write a small test script that exercises these functions.

**File:** `packages/database/src/test-crud.ts`

```typescript
// packages/database/src/test-crud.ts

import { PrismaCrud, DrizzleCrud } from './crud'
import { prisma } from './prisma/client'
import { db } from './drizzle/client'

async function testPrismaCrud() {
  console.log('🧪 Testing Prisma CRUD...')
  const user = await PrismaCrud.createUser({
    email: 'test-prisma@example.com',
    password: 'secret123',
    fullName: 'Prisma Test User',
  })
  console.log('Created user:', user)

  const found = await PrismaCrud.getUserByEmail('test-prisma@example.com')
  console.log('Found user:', found)

  const org = await PrismaCrud.upsertOrganization({
    slug: 'prisma-test',
    name: 'Prisma Test Org',
  })
  console.log('Upserted org:', org)

  const project = await PrismaCrud.createProject({
    organizationId: org.id,
    name: 'Test Project',
    createdBy: user.id,
  })
  console.log('Created project:', project)

  const tasks = await PrismaCrud.createManyTasks([
    {
      projectId: project.id,
      title: 'Task 1',
      createdBy: user.id,
      status: 'todo',
      priority: 'high',
    },
    {
      projectId: project.id,
      title: 'Task 2',
      createdBy: user.id,
      assignedTo: user.id,
    },
  ])
  console.log('Created tasks count:', tasks.count)

  const projects = await PrismaCrud.getProjectsForOrganization(org.id)
  console.log('Projects with tasks:', JSON.stringify(projects, null, 2))

  const updated = await PrismaCrud.updateTaskStatus(tasks[0]?.id || '', 'in_progress')
  console.log('Updated task:', updated)
}

async function testDrizzleCrud() {
  console.log('🧪 Testing Drizzle CRUD...')
  const user = await DrizzleCrud.createUser({
    email: 'test-drizzle@example.com',
    password: 'secret123',
    fullName: 'Drizzle Test User',
  })
  console.log('Created user:', user)

  const found = await DrizzleCrud.getUserByEmail('test-drizzle@example.com')
  console.log('Found user:', found)

  const org = await DrizzleCrud.upsertOrganization({
    slug: 'drizzle-test',
    name: 'Drizzle Test Org',
  })
  console.log('Upserted org:', org)

  const project = await DrizzleCrud.createProject({
    organizationId: org.id,
    name: 'Test Project',
    createdBy: user.id,
  })
  console.log('Created project:', project)

  const tasks = await DrizzleCrud.createManyTasks([
    {
      projectId: project.id,
      title: 'Task 1',
      createdBy: user.id,
      status: 'todo',
      priority: 'high',
    },
    {
      projectId: project.id,
      title: 'Task 2',
      createdBy: user.id,
      assignedTo: user.id,
    },
  ])
  console.log('Created tasks count:', tasks.length)

  const projects = await DrizzleCrud.getProjectsForOrganization(org.id)
  console.log('Projects with tasks:', JSON.stringify(projects, null, 2))

  const updated = await DrizzleCrud.updateTaskStatus(tasks[0]?.id || '', 'in_progress')
  console.log('Updated task:', updated)
}

async function main() {
  await testPrismaCrud()
  await testDrizzleCrud()
  console.log('✅ CRUD tests passed.')
}

main()
  .catch(console.error)
  .finally(async () => {
    await prisma.$disconnect()
    await db.$client.end()
  })
```

Run the test:

```bash
cd packages/database
pnpm tsx src/test-crud.ts
```

You should see output showing successful creation, update, and query operations.

---

## Part 3, Section 2: Advanced Query Construction

Now we'll go beyond basic CRUD and build complex queries: filtering, sorting, aggregations, grouping, window functions, and CTEs.

### Target

We'll create a set of advanced query functions that demonstrate the capabilities of both ORMs, including:
- Filtering with multiple conditions (AND/OR, comparison operators)
- Sorting by multiple fields
- Aggregations (count, sum, avg, min, max)
- Grouping with having
- Window functions (rank, row_number)
- Common Table Expressions (CTEs)

### Implementation

We'll add more functions to our CRUD file (or create a new file `advanced-queries.ts`). For brevity, I'll present the functions directly.

**File:** `packages/database/src/advanced-queries.ts`

```typescript
// packages/database/src/advanced-queries.ts

import { prisma } from './prisma/client'
import { db } from './drizzle/client'
import { 
  users, organizations, projects, tasks, comments, 
  eq, ne, gt, lt, gte, lte, like, ilike, and, or, 
  desc, asc, count, sum, avg, min, max, sql, 
  getTableColumns, 
  // For CTEs
  with as withCte
} from './drizzle-orm'
// Note: Drizzle's 'with' is a function; we'll use it correctly.

// =============================================
// PRISMA ADVANCED QUERIES
// =============================================

export namespace PrismaAdvanced {
  // --- Filtering with multiple conditions ---
  export async function getTasksByFilters(filters: {
    projectId?: string
    status?: string
    priority?: string
    assignedTo?: string
    dueDateFrom?: Date
    dueDateTo?: Date
    search?: string
  }) {
    return prisma.task.findMany({
      where: {
        AND: [
          filters.projectId ? { projectId: filters.projectId } : {},
          filters.status ? { status: filters.status as any } : {},
          filters.priority ? { priority: filters.priority as any } : {},
          filters.assignedTo ? { assignedTo: filters.assignedTo } : {},
          filters.dueDateFrom ? { dueDate: { gte: filters.dueDateFrom } } : {},
          filters.dueDateTo ? { dueDate: { lte: filters.dueDateTo } } : {},
          filters.search ? {
            OR: [
              { title: { contains: filters.search, mode: 'insensitive' } },
              { description: { contains: filters.search, mode: 'insensitive' } },
            ]
          } : {},
        ].filter(cond => Object.keys(cond).length > 0), // remove empty objects
      },
      orderBy: [
        { priority: 'asc' },
        { dueDate: 'asc' },
      ],
      include: {
        assignee: { select: { id: true, fullName: true, email: true } },
        creator: { select: { id: true, fullName: true } },
        project: { select: { id: true, name: true } },
        comments: {
          select: { id: true, content: true, createdAt: true, author: { select: { fullName: true } } },
          orderBy: { createdAt: 'asc' },
          take: 5,
        },
      },
    })
  }

  // --- Aggregations ---
  export async function getTaskStats(projectId: string) {
    // Prisma does not have a built-in aggregation API like Drizzle.
    // We can use $queryRaw or use `groupBy` (preview feature).
    // Using raw SQL for aggregations is common.
    const result = await prisma.$queryRaw<Array<{
      status: string
      count: bigint
      avgEstimatedHours: number | null
      totalTasks: bigint
    }>>`
      SELECT 
        status,
        COUNT(*) as count,
        AVG(estimated_hours) as avg_estimated_hours,
        SUM(estimated_hours) as total_estimated_hours
      FROM tasks
      WHERE project_id = ${projectId}
      GROUP BY status
      ORDER BY status
    `
    return result
  }

  // Alternatively, we can use `groupBy` (experimental) if enabled:
  // await prisma.task.groupBy({
  //   by: ['status'],
  //   where: { projectId },
  //   _count: true,
  //   _avg: { estimatedHours: true },
  //   _sum: { estimatedHours: true },
  // })
  // But we'll stick with raw for now.

  // --- Window functions (use raw SQL) ---
  export async function getTaskRankingByProject(projectId: string) {
    return prisma.$queryRaw<Array<{
      id: string
      title: string
      priority: string
      rank: number
    }>>`
      SELECT 
        id,
        title,
        priority,
        RANK() OVER (ORDER BY priority ASC, created_at DESC) as rank
      FROM tasks
      WHERE project_id = ${projectId}
    `
  }

  // --- CTE (Common Table Expression) via raw SQL ---
  export async function getProjectWithTaskStats(orgId: string) {
    return prisma.$queryRaw<Array<{
      project_id: string
      project_name: string
      total_tasks: bigint
      completed_tasks: bigint
      avg_priority: number
    }>>`
      WITH task_stats AS (
        SELECT 
          project_id,
          COUNT(*) as total_tasks,
          COUNT(CASE WHEN status = 'done' THEN 1 END) as completed_tasks,
          AVG(CASE 
            WHEN priority = 'urgent' THEN 4
            WHEN priority = 'high' THEN 3
            WHEN priority = 'medium' THEN 2
            WHEN priority = 'low' THEN 1
          END) as avg_priority
        FROM tasks
        GROUP BY project_id
      )
      SELECT 
        p.id as project_id,
        p.name as project_name,
        ts.total_tasks,
        ts.completed_tasks,
        ts.avg_priority
      FROM projects p
      JOIN task_stats ts ON p.id = ts.project_id
      WHERE p.organization_id = ${orgId}
    `
  }
}

// =============================================
// DRIZZLE ADVANCED QUERIES
// =============================================

export namespace DrizzleAdvanced {
  // --- Filtering with multiple conditions ---
  export async function getTasksByFilters(filters: {
    projectId?: string
    status?: 'backlog' | 'todo' | 'in_progress' | 'in_review' | 'done'
    priority?: 'low' | 'medium' | 'high' | 'urgent'
    assignedTo?: string
    dueDateFrom?: Date
    dueDateTo?: Date
    search?: string
  }) {
    const conditions = []
    if (filters.projectId) conditions.push(eq(tasks.projectId, filters.projectId))
    if (filters.status) conditions.push(eq(tasks.status, filters.status))
    if (filters.priority) conditions.push(eq(tasks.priority, filters.priority))
    if (filters.assignedTo) conditions.push(eq(tasks.assignedTo, filters.assignedTo))
    if (filters.dueDateFrom) conditions.push(gte(tasks.dueDate, filters.dueDateFrom))
    if (filters.dueDateTo) conditions.push(lte(tasks.dueDate, filters.dueDateTo))
    if (filters.search) {
      conditions.push(
        or(
          ilike(tasks.title, `%${filters.search}%`),
          ilike(tasks.description, `%${filters.search}%`)
        )
      )
    }

    // Use the relational query API for includes
    return db.query.tasks.findMany({
      where: conditions.length ? and(...conditions) : undefined,
      orderBy: [asc(tasks.priority), asc(tasks.dueDate)],
      with: {
        assignee: {
          columns: { id: true, fullName: true, email: true },
        },
        creator: {
          columns: { id: true, fullName: true },
        },
        project: {
          columns: { id: true, name: true },
        },
        comments: {
          columns: { id: true, content: true, createdAt: true },
          with: {
            author: {
              columns: { fullName: true },
            },
          },
          orderBy: (comments, { asc }) => [asc(comments.createdAt)],
          limit: 5,
        },
      },
    })
  }

  // --- Aggregations ---
  export async function getTaskStats(projectId: string) {
    const result = await db
      .select({
        status: tasks.status,
        count: count(tasks.id),
        avgEstimatedHours: avg(tasks.estimatedHours),
        totalEstimatedHours: sum(tasks.estimatedHours),
      })
      .from(tasks)
      .where(eq(tasks.projectId, projectId))
      .groupBy(tasks.status)
      .orderBy(asc(tasks.status))
    return result
  }

  // --- Window functions ---
  export async function getTaskRankingByProject(projectId: string) {
    // Drizzle supports window functions via sql template
    const result = await db
      .select({
        id: tasks.id,
        title: tasks.title,
        priority: tasks.priority,
        rank: sql<number>`RANK() OVER (ORDER BY ${tasks.priority} ASC, ${tasks.createdAt} DESC)`,
      })
      .from(tasks)
      .where(eq(tasks.projectId, projectId))
    return result
  }

  // --- CTE ---
  export async function getProjectWithTaskStats(orgId: string) {
    // Define the CTE
    const taskStats = db.$with('task_stats').as(
      db
        .select({
          projectId: tasks.projectId,
          totalTasks: count(tasks.id),
          completedTasks: sql<number>`COUNT(CASE WHEN ${tasks.status} = 'done' THEN 1 END)`,
          avgPriority: sql<number>`AVG(CASE 
            WHEN ${tasks.priority} = 'urgent' THEN 4
            WHEN ${tasks.priority} = 'high' THEN 3
            WHEN ${tasks.priority} = 'medium' THEN 2
            WHEN ${tasks.priority} = 'low' THEN 1
          END)`,
        })
        .from(tasks)
        .groupBy(tasks.projectId)
    )

    // Use the CTE in the main query
    const result = await db
      .with(taskStats)
      .select({
        projectId: projects.id,
        projectName: projects.name,
        totalTasks: taskStats.totalTasks,
        completedTasks: taskStats.completedTasks,
        avgPriority: taskStats.avgPriority,
      })
      .from(projects)
      .leftJoin(taskStats, eq(projects.id, taskStats.projectId))
      .where(eq(projects.organizationId, orgId))

    return result
  }

  // Another approach: using the `with` function directly in a query builder
  export async function getProjectWithTaskStatsAlt(orgId: string) {
    // This is another way using raw SQL
    return db.execute(sql`
      WITH task_stats AS (
        SELECT 
          project_id,
          COUNT(*) as total_tasks,
          COUNT(CASE WHEN status = 'done' THEN 1 END) as completed_tasks,
          AVG(CASE 
            WHEN priority = 'urgent' THEN 4
            WHEN priority = 'high' THEN 3
            WHEN priority = 'medium' THEN 2
            WHEN priority = 'low' THEN 1
          END) as avg_priority
        FROM tasks
        GROUP BY project_id
      )
      SELECT 
        p.id as project_id,
        p.name as project_name,
        ts.total_tasks,
        ts.completed_tasks,
        ts.avg_priority
      FROM projects p
      LEFT JOIN task_stats ts ON p.id = ts.project_id
      WHERE p.organization_id = ${orgId}
    `)
  }
}
```

### Concept Notes

- **Prisma's filtering** uses a nested `where` object with `AND`/`OR` operators. For `contains`, we use `mode: 'insensitive'` for case‑insensitive search.
- **Drizzle** uses a `where` array of conditions combined with `and()`. We can also use `or()` for OR conditions.
- **Aggregations** in Prisma are best done with `$queryRaw` or the `groupBy` preview feature (not stable). In Drizzle, we use the `select` with `count`, `sum`, etc., directly.
- **Window functions** and **CTEs** are advanced SQL features that are directly supported in Drizzle via the `sql` template and `$with` method. Prisma requires raw SQL for these.

### Verification

We'll create a test script for advanced queries.

**File:** `packages/database/src/test-advanced.ts`

```typescript
// packages/database/src/test-advanced.ts

import { PrismaAdvanced, DrizzleAdvanced } from './advanced-queries'
import { prisma } from './prisma/client'
import { db } from './drizzle/client'

async function testPrismaAdvanced() {
  console.log('🧪 Testing Prisma Advanced Queries...')
  // Get a real project ID from the database
  const project = await prisma.project.findFirst()
  if (!project) throw new Error('No project found, run seed first')
  const org = await prisma.organization.findFirst()
  if (!org) throw new Error('No organization found')

  const tasks = await PrismaAdvanced.getTasksByFilters({
    projectId: project.id,
    status: 'todo',
    search: 'design',
  })
  console.log('Filtered tasks:', tasks.length)

  const stats = await PrismaAdvanced.getTaskStats(project.id)
  console.log('Task stats:', stats)

  const ranking = await PrismaAdvanced.getTaskRankingByProject(project.id)
  console.log('Task ranking:', ranking)

  const projectStats = await PrismaAdvanced.getProjectWithTaskStats(org.id)
  console.log('Project stats:', projectStats)
}

async function testDrizzleAdvanced() {
  console.log('🧪 Testing Drizzle Advanced Queries...')
  const project = await db.query.projects.findFirst()
  if (!project) throw new Error('No project found')
  const org = await db.query.organizations.findFirst()
  if (!org) throw new Error('No organization found')

  const tasks = await DrizzleAdvanced.getTasksByFilters({
    projectId: project.id,
    status: 'todo',
    search: 'design',
  })
  console.log('Filtered tasks:', tasks.length)

  const stats = await DrizzleAdvanced.getTaskStats(project.id)
  console.log('Task stats:', stats)

  const ranking = await DrizzleAdvanced.getTaskRankingByProject(project.id)
  console.log('Task ranking:', ranking)

  const projectStats = await DrizzleAdvanced.getProjectWithTaskStats(org.id)
  console.log('Project stats:', projectStats)
}

async function main() {
  await testPrismaAdvanced()
  await testDrizzleAdvanced()
  console.log('✅ Advanced query tests passed.')
}

main()
  .catch(console.error)
  .finally(async () => {
    await prisma.$disconnect()
    await db.$client.end()
  })
```

Run it:

```bash
pnpm tsx src/test-advanced.ts
```

You should see results from the advanced queries.

---

## Part 3, Section 3: Pagination Strategies

Pagination is essential for large datasets. We'll implement two common strategies: offset‑based and cursor‑based (keyset pagination).

### Implementation

**File:** `packages/database/src/pagination.ts`

```typescript
// packages/database/src/pagination.ts

import { prisma } from './prisma/client'
import { db } from './drizzle/client'
import { tasks, eq, gt, lt, asc, desc, sql } from './drizzle/schema'

// =============================================
// PRISMA PAGINATION
// =============================================

export namespace PrismaPagination {
  // Offset-based pagination
  export async function getTasksOffset(
    projectId: string,
    page: number = 1,
    pageSize: number = 10
  ) {
    const skip = (page - 1) * pageSize
    const [items, total] = await Promise.all([
      prisma.task.findMany({
        where: { projectId },
        skip,
        take: pageSize,
        orderBy: { createdAt: 'desc' },
        include: {
          assignee: { select: { id: true, fullName: true } },
          creator: { select: { id: true, fullName: true } },
        },
      }),
      prisma.task.count({ where: { projectId } }),
    ])
    return {
      items,
      total,
      page,
      pageSize,
      totalPages: Math.ceil(total / pageSize),
    }
  }

  // Cursor-based pagination (using createdAt as cursor)
  export async function getTasksCursor(
    projectId: string,
    cursor?: { id: string; createdAt: Date },
    limit: number = 10
  ) {
    const items = await prisma.task.findMany({
      where: {
        projectId,
        ...(cursor && {
          OR: [
            { createdAt: { lt: cursor.createdAt } },
            { createdAt: { equals: cursor.createdAt }, id: { lt: cursor.id } },
          ],
        }),
      },
      orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
      take: limit,
      include: {
        assignee: { select: { id: true, fullName: true } },
        creator: { select: { id: true, fullName: true } },
      },
    })
    const nextCursor = items.length === limit ? {
      id: items[items.length - 1].id,
      createdAt: items[items.length - 1].createdAt,
    } : null
    return {
      items,
      nextCursor,
    }
  }
}

// =============================================
// DRIZZLE PAGINATION
// =============================================

export namespace DrizzlePagination {
  // Offset-based pagination
  export async function getTasksOffset(
    projectId: string,
    page: number = 1,
    pageSize: number = 10
  ) {
    const offset = (page - 1) * pageSize
    const items = await db.query.tasks.findMany({
      where: eq(tasks.projectId, projectId),
      orderBy: [desc(tasks.createdAt)],
      limit: pageSize,
      offset,
      with: {
        assignee: { columns: { id: true, fullName: true } },
        creator: { columns: { id: true, fullName: true } },
      },
    })
    const totalResult = await db
      .select({ count: sql<number>`count(*)` })
      .from(tasks)
      .where(eq(tasks.projectId, projectId))
    const total = totalResult[0]?.count ?? 0
    return {
      items,
      total,
      page,
      pageSize,
      totalPages: Math.ceil(total / pageSize),
    }
  }

  // Cursor-based pagination
  export async function getTasksCursor(
    projectId: string,
    cursor?: { id: string; createdAt: Date },
    limit: number = 10
  ) {
    const conditions = [eq(tasks.projectId, projectId)]
    if (cursor) {
      conditions.push(
        or(
          lt(tasks.createdAt, cursor.createdAt),
          and(
            eq(tasks.createdAt, cursor.createdAt),
            lt(tasks.id, cursor.id)
          )
        )
      )
    }
    const items = await db.query.tasks.findMany({
      where: and(...conditions),
      orderBy: [desc(tasks.createdAt), desc(tasks.id)],
      limit: limit,
      with: {
        assignee: { columns: { id: true, fullName: true } },
        creator: { columns: { id: true, fullName: true } },
      },
    })
    const nextCursor = items.length === limit ? {
      id: items[items.length - 1].id,
      createdAt: items[items.length - 1].createdAt,
    } : null
    return {
      items,
      nextCursor,
    }
  }
}
```

### Concept Notes

- **Offset pagination** is simple but becomes inefficient for large offsets because the database still scans rows.
- **Cursor pagination** (keyset pagination) uses a `WHERE` clause on the cursor columns and is more efficient for large datasets. It requires a unique, sortable column (or combination).
- Both ORMs support these patterns, but Drizzle's relational API makes it straightforward; Prisma requires custom logic for cursor pagination (using `OR` conditions).

### Verification

You can test these functions in a similar manner as before (omitted for brevity).

---

## Part 3, Section 4: Transactions and Concurrency

Transactions ensure that a set of operations either all succeed or all fail, maintaining data integrity. Both ORMs support transactions.

### Implementation

**File:** `packages/database/src/transactions.ts`

```typescript
// packages/database/src/transactions.ts

import { prisma } from './prisma/client'
import { db } from './drizzle/client'
import { users, organizations, organizationMembers } from './drizzle/schema'
import { eq, and } from 'drizzle-orm'

// =============================================
// PRISMA TRANSACTIONS
// =============================================

export namespace PrismaTransactions {
  // Basic transaction
  export async function createOrganizationWithOwner(
    orgData: { name: string; slug: string },
    userData: { email: string; password: string; fullName: string }
  ) {
    return prisma.$transaction(async (tx) => {
      // Create the user
      const user = await tx.user.create({
        data: {
          email: userData.email,
          passwordHash: userData.password, // assume hashed elsewhere
          fullName: userData.fullName,
        },
      })
      // Create the organization
      const org = await tx.organization.create({
        data: {
          name: orgData.name,
          slug: orgData.slug,
        },
      })
      // Create membership with owner role
      await tx.organizationMember.create({
        data: {
          organizationId: org.id,
          userId: user.id,
          role: 'owner',
        },
      })
      return { user, org }
    })
  }

  // Interactive transaction with conditions
  export async function transferTaskOwnership(taskId: string, newOwnerId: string) {
    return prisma.$transaction(async (tx) => {
      const task = await tx.task.findUnique({
        where: { id: taskId },
        select: { assignedTo: true },
      })
      if (!task) throw new Error('Task not found')
      // Perform business logic, e.g., check if new owner exists
      const newUser = await tx.user.findUnique({
        where: { id: newOwnerId },
      })
      if (!newUser) throw new Error('New owner not found')
      // Update the task
      const updated = await tx.task.update({
        where: { id: taskId },
        data: { assignedTo: newOwnerId },
      })
      // Log activity
      await tx.activityLog.create({
        data: {
          userId: newOwnerId,
          organizationId: (await tx.task.findUnique({ where: { id: taskId } }))!.project.organizationId,
          action: 'task.assigned',
          details: { taskId, newOwnerId },
        },
      })
      return updated
    })
  }
}

// =============================================
// DRIZZLE TRANSACTIONS
// =============================================

export namespace DrizzleTransactions {
  // Drizzle transactions use a callback that receives a transaction client
  export async function createOrganizationWithOwner(
    orgData: { name: string; slug: string },
    userData: { email: string; password: string; fullName: string }
  ) {
    return db.transaction(async (tx) => {
      // Create user
      const [user] = await tx.insert(users).values({
        email: userData.email,
        passwordHash: userData.password,
        fullName: userData.fullName,
      }).returning()
      // Create organization
      const [org] = await tx.insert(organizations).values({
        name: orgData.name,
        slug: orgData.slug,
      }).returning()
      // Create membership
      await tx.insert(organizationMembers).values({
        organizationId: org.id,
        userId: user.id,
        role: 'owner',
      })
      return { user, org }
    })
  }

  export async function transferTaskOwnership(taskId: string, newOwnerId: string) {
    return db.transaction(async (tx) => {
      // Check task and new owner in the same transaction
      const taskResult = await tx.select()
        .from(tasks)
        .where(eq(tasks.id, taskId))
        .limit(1)
      if (taskResult.length === 0) throw new Error('Task not found')
      const task = taskResult[0]

      const userResult = await tx.select()
        .from(users)
        .where(eq(users.id, newOwnerId))
        .limit(1)
      if (userResult.length === 0) throw new Error('New owner not found')

      // Update task
      const [updated] = await tx.update(tasks)
        .set({ assignedTo: newOwnerId, updatedAt: new Date() })
        .where(eq(tasks.id, taskId))
        .returning()

      // Log activity (need organizationId)
      const projectResult = await tx.select()
        .from(projects)
        .where(eq(projects.id, task.projectId))
        .limit(1)
      if (projectResult.length === 0) throw new Error('Project not found')
      const orgId = projectResult[0].organizationId

      await tx.insert(activityLogs).values({
        userId: newOwnerId,
        organizationId: orgId,
        action: 'task.assigned',
        details: { taskId, newOwnerId },
      })

      return updated
    })
  }
}
```

### Concept Notes

- **Prisma** uses `$transaction` with a callback that provides a transactional client. All operations inside the callback are atomic.
- **Drizzle** uses `db.transaction` similarly, with a callback that receives a transaction client (`tx`). You must use `tx` for all operations within the transaction to ensure they are part of the same transaction.
- Both support nested transactions, though they may be flattened under the hood.
- Concurrency control: use `SELECT ... FOR UPDATE` if needed; Prisma and Drizzle can execute raw SQL for that.

### Verification

You can test these transaction functions by running them and verifying that either all changes are committed or rolled back on error.

---

## Part 3, Section 5: Raw SQL

Sometimes you need to write raw SQL for complex queries, performance tuning, or vendor‑specific features. Both ORMs support raw SQL.

### Implementation

**File:** `packages/database/src/raw-sql.ts`

```typescript
// packages/database/src/raw-sql.ts

import { prisma } from './prisma/client'
import { db } from './drizzle/client'
import { sql } from 'drizzle-orm'

// =============================================
// PRISMA RAW SQL
// =============================================

export namespace PrismaRaw {
  // Using $queryRaw for SELECT
  export async function getComplexReport() {
    return prisma.$queryRaw<Array<{
      project_name: string
      task_count: number
      completion_rate: number
    }>>`
      SELECT 
        p.name as project_name,
        COUNT(t.id) as task_count,
        ROUND(CAST(COUNT(CASE WHEN t.status = 'done' THEN 1 END) AS DECIMAL) / COUNT(t.id) * 100, 2) as completion_rate
      FROM projects p
      LEFT JOIN tasks t ON p.id = t.project_id
      GROUP BY p.id
      HAVING COUNT(t.id) > 0
      ORDER BY completion_rate DESC
    `
  }

  // Using $executeRaw for INSERT/UPDATE/DELETE
  export async function archiveOldTasks(days: number) {
    const cutoff = new Date()
    cutoff.setDate(cutoff.getDate() - days)
    return prisma.$executeRaw`
      UPDATE tasks
      SET status = 'archived'
      WHERE completed_at IS NOT NULL AND completed_at < ${cutoff}
    `
  }
}

// =============================================
// DRIZZLE RAW SQL
// =============================================

export namespace DrizzleRaw {
  // Using sql template for SELECT
  export async function getComplexReport() {
    return db.execute(sql`
      SELECT 
        p.name as project_name,
        COUNT(t.id) as task_count,
        ROUND(CAST(COUNT(CASE WHEN t.status = 'done' THEN 1 END) AS DECIMAL) / COUNT(t.id) * 100, 2) as completion_rate
      FROM projects p
      LEFT JOIN tasks t ON p.id = t.project_id
      GROUP BY p.id
      HAVING COUNT(t.id) > 0
      ORDER BY completion_rate DESC
    `)
  }

  // For INSERT/UPDATE/DELETE, we can also use execute
  export async function archiveOldTasks(days: number) {
    const cutoff = new Date()
    cutoff.setDate(cutoff.getDate() - days)
    return db.execute(sql`
      UPDATE tasks
      SET status = 'archived'
      WHERE completed_at IS NOT NULL AND completed_at < ${cutoff}
    `)
  }
}
```

### Concept Notes

- **Prisma** uses `$queryRaw` for queries that return rows and `$executeRaw` for commands that return a row count.
- **Drizzle** uses `db.execute(sql`...`)` for both (it returns a result object with rows and rowCount).
- Raw SQL should be parameterized to prevent SQL injection; both ORMs support parameter placeholders (`${}`) in the SQL template, which are properly escaped.

---

## Part 3, Section 6: Performance Benchmarking

Now we'll design and run benchmarks to compare the performance of Prisma and Drizzle under various workloads. We'll measure query execution time, throughput, and memory usage.

### Benchmark Design

We'll create a simple benchmark suite that runs a set of operations multiple times and records the average duration.

**File:** `packages/database/src/benchmark.ts`

```typescript
// packages/database/src/benchmark.ts

import { prisma } from './prisma/client'
import { db } from './drizzle/client'
import { tasks, eq } from './drizzle/schema'

// Helper to measure time
function measureTime(fn: () => Promise<any>) {
  const start = process.hrtime.bigint()
  return fn().then(() => {
    const end = process.hrtime.bigint()
    return Number(end - start) / 1_000_000 // milliseconds
  })
}

async function runBenchmark(name: string, fn: () => Promise<any>, iterations: number = 10) {
  const times: number[] = []
  for (let i = 0; i < iterations; i++) {
    const duration = await measureTime(fn)
    times.push(duration)
  }
  const avg = times.reduce((a, b) => a + b, 0) / times.length
  const min = Math.min(...times)
  const max = Math.max(...times)
  console.log(`  ${name}: avg=${avg.toFixed(2)}ms, min=${min.toFixed(2)}ms, max=${max.toFixed(2)}ms`)
  return { avg, min, max, times }
}

async function benchmark() {
  console.log('🔬 Running Performance Benchmarks...\n')

  // Make sure we have some data
  const project = await prisma.project.findFirst()
  if (!project) throw new Error('No project found. Run seed first.')

  // 1. Simple find by ID
  const tasksList = await prisma.task.findMany({ take: 50 })
  const taskIds = tasksList.map(t => t.id)

  console.log('Benchmark: Find task by ID (single)')
  await runBenchmark('Prisma', () => prisma.task.findUnique({ where: { id: taskIds[0] } }), 100)
  await runBenchmark('Drizzle', () => db.query.tasks.findFirst({ where: eq(tasks.id, taskIds[0]) }), 100)

  // 2. Find many with filters
  console.log('\nBenchmark: Find many tasks with filter (project, status)')
  await runBenchmark('Prisma', () => prisma.task.findMany({ 
    where: { projectId: project.id, status: 'todo' },
    take: 20 
  }), 50)
  await runBenchmark('Drizzle', () => db.query.tasks.findMany({
    where: (tasks, { and, eq }) => and(eq(tasks.projectId, project.id), eq(tasks.status, 'todo')),
    limit: 20
  }), 50)

  // 3. Complex join with includes
  console.log('\nBenchmark: Fetch project with tasks and assignees')
  await runBenchmark('Prisma', () => prisma.project.findUnique({
    where: { id: project.id },
    include: { tasks: { include: { assignee: true } } }
  }), 30)
  await runBenchmark('Drizzle', () => db.query.projects.findFirst({
    where: eq(projects.id, project.id),
    with: { tasks: { with: { assignee: true } } }
  }), 30)

  // 4. Aggregation query
  console.log('\nBenchmark: Aggregation (count and average)')
  await runBenchmark('Prisma', () => prisma.$queryRaw`SELECT COUNT(*), AVG(estimated_hours) FROM tasks WHERE project_id = ${project.id}`)
  await runBenchmark('Drizzle', () => db.select({ count: sql`count(*)`, avg: sql`avg(estimated_hours)` })
    .from(tasks)
    .where(eq(tasks.projectId, project.id))
  , 30)

  // 5. Bulk insert (100 tasks)
  console.log('\nBenchmark: Bulk insert 100 tasks')
  const dummyTasks = Array.from({ length: 100 }, (_, i) => ({
    projectId: project.id,
    title: `Benchmark Task ${i}`,
    createdBy: (await prisma.user.findFirst())!.id,
    status: 'todo',
    priority: 'medium',
  }))
  await runBenchmark('Prisma', () => prisma.task.createMany({ data: dummyTasks, skipDuplicates: true }), 5)
  await runBenchmark('Drizzle', () => db.insert(tasks).values(dummyTasks).returning(), 5)

  console.log('\n✅ Benchmark complete.')
}

// Run benchmark with cleanup to avoid duplicate data issues
benchmark()
  .catch(console.error)
  .finally(async () => {
    await prisma.$disconnect()
    await db.$client.end()
  })
```

Run the benchmark:

```bash
pnpm tsx src/benchmark.ts
```

### Expected Results (Illustrative)

- **Prisma** typically has slightly higher latency due to the Query Engine overhead, but it's often within acceptable bounds.
- **Drizzle** tends to be faster for simple queries and bulk inserts, especially in serverless/edge scenarios due to smaller bundle size and no external engine.
- For complex joins, both perform similarly; the quality of generated SQL matters.

We'll discuss the results in the text.

---

## Part 3, Section 7: Type Safety Deep Dive

Both ORMs boast strong type safety, but the mechanisms differ.

### Prisma Type Safety

Prisma generates types from `schema.prisma`. The generated types are explicit and can be inspected in `node_modules/.prisma`. This provides:

- **Strong autocompletion** in IDEs.
- **Compile‑time errors** for misspelled fields or wrong types.
- **Relation types** that are recursively generated.

However, Prisma's type system is not as flexible as Drizzle's when it comes to dynamic queries; you may need to cast or use `Prisma.Validator` for complex input types.

### Drizzle Type Safety

Drizzle infers types from your TypeScript schema definitions. This means:

- The schema is the source of truth; no separate generation step.
- Types are inferred from the table definitions; if you change a column type, the query types update automatically.
- Drizzle uses conditional types and mapped types extensively to provide autocompletion for `where`, `select`, `with`, etc.
- The type inference can be slow in very large schemas, but Drizzle has optimizations.

### Example: Type Inference Comparison

```typescript
// Prisma: explicit type import
import { User, Prisma } from '@prisma/client'
type UserWithProfile = Prisma.UserGetPayload<{ include: { profile: true } }>

// Drizzle: inferred from query
const userWithProfile = await db.query.users.findFirst({
  with: { profile: true }
})
// userWithProfile is automatically typed with the profile included.
```

Drizzle's approach is more "write once, use everywhere," while Prisma's approach provides more explicit control but requires importing generated types.

### Handling Dynamic Queries

Both ORMs allow building queries dynamically, but Drizzle's type system sometimes struggles with complex dynamic conditions (you may need to use `any` or type assertions). Prisma's generated types are more predictable in those cases.

---

## Part 3, Section 8: Verification – Comprehensive Test Suite

We'll create a test suite that runs all the query functions we've built to ensure they work correctly and to catch regressions.

Since we're writing a tutorial, we'll keep it simple: a script that calls each function and logs the results.

**File:** `packages/database/src/test-all.ts`

```typescript
// packages/database/src/test-all.ts

import './test-crud'
import './test-advanced'
import './test-pagination' // we didn't create this, but you can
import './test-transactions'
import './test-raw-sql'

console.log('All tests completed.')
```

We won't run this here, but it demonstrates how to organize tests.

---

## Progress Log

| Phase | Status | Notes |
|-------|--------|-------|
| Part 0: Introduction | ✅ COMPLETE | |
| Part 1: ORM Philosophy & Setup | ✅ COMPLETE | |
| Part 2: Schema Design, Modeling, and Migrations | ✅ COMPLETE | |
| Part 3: Querying, Performance, and Type Safety | ✅ COMPLETE | Covered CRUD, advanced queries, pagination, transactions, raw SQL, benchmarking, and type safety. |
| Part 4: Framework Integration | ⏳ PENDING | Next: Next.js, React, React Native integration. |
| Part 5: Production Readiness | ⏳ PENDING | |
| Capstone Project | ⏳ PENDING | |
