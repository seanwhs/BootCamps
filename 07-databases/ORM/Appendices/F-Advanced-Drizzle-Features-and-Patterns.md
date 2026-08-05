# Appendix F: Advanced Drizzle Features and Patterns

### Purpose of This Appendix

Throughout the main series, we covered the core features of Drizzle ORM, but there are many advanced capabilities that we didn't have space to explore fully. This appendix is your reference for the more sophisticated aspects of Drizzle—features that make it a powerful tool for complex applications.

**What you'll find here:**
- **Drizzle Kit advanced usage** – custom migrations, introspection, and schema push.
- **SQL templates and raw SQL** – advanced patterns with `sql` template literals.
- **Custom types** – creating custom column types (e.g., UUID, JSON, vector embeddings).
- **Drizzle with GraphQL** – integrating with GraphQL and generating types.
- **Drizzle with TypeScript** – advanced type inference, generic utilities, and type‑safe dynamic queries.
- **Drizzle with SQLite** – advanced SQLite features and performance tips.
- **Drizzle with multiple databases** – handling multiple connections and cross‑database queries.
- **Drizzle extensions** – creating your own extensions and helpers.
- **Drizzle with Zod** – integrating validation with schemas.

---

## Appendix F, Section 1: Drizzle Kit Advanced Usage

Drizzle Kit is the CLI tool for managing migrations and schema introspection. We've used the basic commands, but there's more.

### 1.1 Introspecting an Existing Database

If you have an existing database and want to generate Drizzle schemas from it:

```bash
drizzle-kit introspect:pg
```

This creates a schema file based on your database tables. You can then customize it.

### 1.2 Generating Migrations with Custom Names

```bash
drizzle-kit generate:pg --name "add_priority_rank_to_tasks"
```

### 1.3 Checking for Differences Without Generating

```bash
drizzle-kit check
```

This compares your schema with the database and reports differences without writing files.

### 1.4 Pushing Schema Directly (Development Only)

```bash
drizzle-kit push:pg
```

This applies schema changes directly to the database without generating migration files. **Never use this in production**—it doesn't create a migration history.

### 1.5 Custom Migration Folders

You can specify a custom migration folder:

```bash
drizzle-kit generate:pg --out ./custom-migrations
```

### 1.6 Using Environment Variables in Configuration

```typescript
// drizzle.config.ts
import { defineConfig } from 'drizzle-kit'

export default defineConfig({
  dialect: 'postgresql',
  schema: './src/drizzle/schema/index.ts',
  out: './src/drizzle/migrations',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
  verbose: true,
  strict: true,
})
```

---

## Appendix F, Section 2: SQL Templates and Raw SQL Advanced Patterns

Drizzle's `sql` template literal is powerful. Let's explore advanced patterns.

### 2.1 Conditional SQL Fragments

```typescript
import { sql } from 'drizzle-orm'

function buildOrderBy(sortField: string, sortOrder: 'asc' | 'desc') {
  return sql`ORDER BY ${sql.identifier(sortField)} ${sql.raw(sortOrder)}`
}

// Usage
const query = db.select()
  .from(tasks)
  .where(eq(tasks.projectId, projectId))
  .orderBy(buildOrderBy('createdAt', 'desc'))
```

### 2.2 Using SQL Functions

```typescript
import { sql } from 'drizzle-orm'

// Use PostgreSQL functions
const result = await db.select({
  id: tasks.id,
  title: tasks.title,
  titleLength: sql<number>`char_length(${tasks.title})`,
  createdAt: tasks.createdAt,
}).from(tasks)
```

### 2.3 Full‑Text Search with PostgreSQL

```typescript
// Create a tsvector column for full-text search
export const tasks = pgTable('tasks', {
  // ...
  searchVector: tsvector('search_vector').generatedAlwaysAs(
    sql`setweight(to_tsvector('english', ${tasks.title}), 'A') || setweight(to_tsvector('english', coalesce(${tasks.description}, '')), 'B')`
  ),
}, (table) => ({
  searchIdx: index('tasks_search_idx').using('gin', table.searchVector),
}))

// Query using full-text search
const results = await db.select()
  .from(tasks)
  .where(sql`${tasks.searchVector} @@ to_tsquery('english', ${searchTerm})`)
  .orderBy(sql`ts_rank(${tasks.searchVector}, to_tsquery('english', ${searchTerm})) DESC`)
```

### 2.4 JSON Operations with PostgreSQL

```typescript
import { sql } from 'drizzle-orm'

// Query JSON field
const result = await db.select({
  id: activityLogs.id,
  action: activityLogs.action,
  details: activityLogs.details,
  userId: sql`${activityLogs.details}->>'userId'`,
}).from(activityLogs)
```

### 2.5 Using `sql.raw` for Dynamic Column Names

```typescript
function selectColumns(columns: string[]) {
  return columns.map(col => sql.raw(col))
}

const result = await db.select(selectColumns(['id', 'name', 'status']))
  .from(projects)
  .where(eq(projects.organizationId, orgId))
```

### 2.6 Common Table Expressions (CTEs) with Multiple CTEs

```typescript
import { with } from 'drizzle-orm'

const taskStats = db.$with('task_stats').as(
  db.select({
    projectId: tasks.projectId,
    count: count(tasks.id),
    avgPriority: avg(tasks.priorityRank),
  })
  .from(tasks)
  .groupBy(tasks.projectId)
)

const projectStats = db.$with('project_stats').as(
  db.select({
    id: projects.id,
    name: projects.name,
    taskCount: taskStats.count,
    avgPriority: taskStats.avgPriority,
  })
  .from(projects)
  .leftJoin(taskStats, eq(projects.id, taskStats.projectId))
)

const result = await db
  .with(taskStats, projectStats)
  .select()
  .from(projectStats)
  .where(gt(projectStats.taskCount, 10))
```

---

## Appendix F, Section 3: Custom Column Types

Drizzle allows you to create custom column types for specialized data.

### 3.1 Creating a UUID Column Type

```typescript
import { customType } from 'drizzle-orm/pg-core'

export const uuid = customType<{ data: string }>({
  dataType() {
    return 'uuid'
  },
  // Optional: add a default generator
  default: () => sql`gen_random_uuid()`,
})
```

Usage:

```typescript
export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  // ...
})
```

### 3.2 Creating a Vector Type (for embeddings)

```typescript
import { customType } from 'drizzle-orm/pg-core'

export const vector = customType<{ data: number[] }>({
  dataType() {
    return 'vector(1536)' // for OpenAI embeddings
  },
  toDriver(value: number[]) {
    return `[${value.join(',')}]`
  },
  fromDriver(value: string) {
    return JSON.parse(value)
  },
})
```

Usage:

```typescript
export const documents = pgTable('documents', {
  id: uuid('id').primaryKey().defaultRandom(),
  content: text('content').notNull(),
  embedding: vector('embedding'),
})
```

### 3.3 Creating an Encrypted Column Type

```typescript
import { customType } from 'drizzle-orm/pg-core'
import { encrypt, decrypt } from '../encryption'

export const encryptedText = customType<{ data: string }>({
  dataType() {
    return 'text'
  },
  toDriver(value: string) {
    return encrypt(value)
  },
  fromDriver(value: string) {
    return decrypt(value)
  },
})
```

---

## Appendix F, Section 4: Drizzle with GraphQL

You can generate GraphQL types from your Drizzle schemas using a code generator.

### 4.1 Using `drizzle-graphql`

There's a community package `drizzle-graphql` that generates GraphQL schema from Drizzle tables.

```bash
pnpm add @graphql-codegen/cli @graphql-codegen/typescript @graphql-codegen/typescript-resolvers
```

### 4.2 Manual GraphQL Integration

You can also manually create GraphQL types and resolvers using your Drizzle schemas.

**Example: GraphQL resolver with Drizzle**

```typescript
// graphql/resolvers/project.resolver.ts
import { db } from '@taskflow/database/drizzle/client'
import { projects, tasks } from '@taskflow/database/drizzle/schema'
import { eq } from 'drizzle-orm'

export const projectResolvers = {
  Query: {
    projects: async (_: any, { orgId }: { orgId: string }) => {
      return db.query.projects.findMany({
        where: eq(projects.organizationId, orgId),
        with: { tasks: true },
      })
    },
    project: async (_: any, { id }: { id: string }) => {
      return db.query.projects.findFirst({
        where: eq(projects.id, id),
        with: { tasks: true },
      })
    },
  },
  Mutation: {
    createProject: async (_: any, { input }: { input: any }) => {
      const [project] = await db.insert(projects)
        .values(input)
        .returning()
      return project
    },
  },
  Project: {
    tasks: async (project: any) => {
      return db.query.tasks.findMany({
        where: eq(tasks.projectId, project.id),
      })
    },
  },
}
```

---

## Appendix F, Section 5: Advanced Type Inference and Generic Utilities

Drizzle's type system is powerful but can be complex. Here are patterns to write type‑safe utilities.

### 5.1 Creating a Type‑Safe Query Builder

```typescript
import { getTableColumns, type AnyPgTable } from 'drizzle-orm/pg-core'
import { type SQL } from 'drizzle-orm'

type TableWithColumns<T extends AnyPgTable> = {
  table: T
  columns: ReturnType<typeof getTableColumns<T>>
}

function createQueryBuilder<T extends AnyPgTable>(table: T) {
  return {
    select: (columns: Partial<Record<keyof ReturnType<typeof getTableColumns<T>>, true>> = {}) => {
      const cols = getTableColumns(table)
      const selected = Object.keys(columns).length > 0
        ? Object.fromEntries(Object.entries(cols).filter(([key]) => columns[key as keyof typeof columns]))
        : cols
      return db.select(selected).from(table)
    },
    where: (condition: SQL) => {
      return db.select().from(table).where(condition)
    },
  }
}

// Usage
const qb = createQueryBuilder(tasks)
const tasksWithIdAndTitle = await qb.select({ id: true, title: true }).where(eq(tasks.projectId, 'some-id'))
```

### 5.2 Generic CRUD Service

```typescript
import { type AnyPgTable, type InferSelectModel, type InferInsertModel } from 'drizzle-orm/pg-core'
import { db } from '../drizzle/client'

export class GenericCrudService<T extends AnyPgTable> {
  constructor(private table: T) {}

  async findById(id: string): Promise<InferSelectModel<T> | undefined> {
    const result = await db.query[this.table.getName() as keyof typeof db.query].findFirst({
      where: (table: any) => eq(table.id, id),
    })
    return result
  }

  async findAll(where?: any): Promise<InferSelectModel<T>[]> {
    const query = db.select().from(this.table)
    if (where) {
      query.where(where)
    }
    return query.all()
  }

  async create(data: InferInsertModel<T>): Promise<InferSelectModel<T>> {
    const [result] = await db.insert(this.table).values(data).returning()
    return result
  }

  async update(id: string, data: Partial<InferInsertModel<T>>): Promise<InferSelectModel<T>> {
    const [result] = await db.update(this.table)
      .set(data as any)
      .where(eq((this.table as any).id, id))
      .returning()
    return result
  }

  async delete(id: string): Promise<void> {
    await db.delete(this.table).where(eq((this.table as any).id, id))
  }
}

// Usage
const projectService = new GenericCrudService(projects)
const project = await projectService.findById('project-id')
```

---

## Appendix F, Section 6: Drizzle with SQLite Advanced Features

SQLite has unique features that Drizzle supports well.

### 6.1 Using SQLite with Expo (React Native)

```typescript
import { drizzle } from 'drizzle-orm/expo-sqlite'
import { openDatabaseSync } from 'expo-sqlite'

const expoDb = openDatabaseSync('taskflow.db')
export const db = drizzle(expoDb, { schema })
```

### 6.2 SQLite JSON Support

SQLite doesn't have native JSON like PostgreSQL, but you can use `jsonb` with the `@sqlite.org/json` extension.

```typescript
import { sqliteTable, text, jsonb } from 'drizzle-orm/sqlite-core'

export const activityLogs = sqliteTable('activity_logs', {
  id: text('id').primaryKey().default(sql`uuid4()`),
  details: jsonb('details').notNull(),
})
```

### 6.3 SQLite Full‑Text Search (FTS5)

```typescript
import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core'

// FTS virtual table
export const tasksFts = sqliteTable('tasks_fts', {
  id: integer('id'),
  title: text('title'),
  description: text('description'),
}, (table) => ({
  // FTS5 requires special syntax
}))

// Query FTS
const results = await db.execute(sql`
  SELECT * FROM tasks_fts('${searchTerm}')
`)
```

---

## Appendix F, Section 7: Drizzle with Multiple Databases

Sometimes you need to connect to multiple databases (e.g., a primary and a read replica, or different services).

### 7.1 Multiple Connections

```typescript
// packages/database/src/drizzle/clients.ts
import { drizzle as drizzlePg } from 'drizzle-orm/node-postgres'
import { drizzle as drizzleSqlite } from 'drizzle-orm/libsql'
import { Pool } from 'pg'
import { createClient } from '@libsql/client'
import * as pgSchema from './schema/pg'
import * as sqliteSchema from './schema/sqlite'

// PostgreSQL
const pgPool = new Pool({ connectionString: process.env.DATABASE_URL })
export const pgDb = drizzle(pgPool, { schema: pgSchema })

// SQLite (Turso)
const sqliteClient = createClient({
  url: process.env.TURSO_URL!,
  authToken: process.env.TURSO_TOKEN!,
})
export const sqliteDb = drizzle(sqliteClient, { schema: sqliteSchema })
```

### 7.2 Cross‑Database Queries

Drizzle doesn't support cross‑database joins natively. You'll need to fetch data from each database and combine in application code.

```typescript
async function getProjectWithAnalytics(projectId: string) {
  const project = await pgDb.query.projects.findFirst({
    where: eq(pgProjects.id, projectId),
  })
  const analytics = await sqliteDb.query.analytics.findMany({
    where: eq(sqliteAnalytics.projectId, projectId),
  })
  return { ...project, analytics }
}
```

---

## Appendix F, Section 8: Drizzle Extensions

While Drizzle doesn't have an official extension system like Prisma, you can create helper functions and utilities.

### 8.1 Logging Extension

```typescript
// packages/database/src/drizzle/extensions/logger.ts
import { type PgDatabase } from 'drizzle-orm/pg-core'
import { logger } from '../logger'

export function withLogging<T extends PgDatabase<any>>(db: T): T {
  const originalExecute = db.execute.bind(db)
  db.execute = async (query: any) => {
    const start = performance.now()
    const result = await originalExecute(query)
    const duration = performance.now() - start
    const sqlString = query instanceof SQL ? query.getSQL() : String(query)
    logger.info(`Drizzle query executed in ${duration.toFixed(2)}ms`, {
      sql: sqlString,
      duration,
    })
    return result
  }
  return db
}
```

### 8.2 Soft Delete Extension

```typescript
// packages/database/src/drizzle/extensions/soft-delete.ts
import { type PgDatabase } from 'drizzle-orm/pg-core'
import { eq, and, isNull } from 'drizzle-orm'

export function withSoftDelete<T extends PgDatabase<any>>(db: T): T {
  // Add a helper to the db instance
  const extended = db as any
  extended.softDelete = async (table: any, id: string) => {
    return db.update(table)
      .set({ deletedAt: new Date() })
      .where(eq(table.id, id))
  }
  extended.softDeleteMany = async (table: any, where: any) => {
    return db.update(table)
      .set({ deletedAt: new Date() })
      .where(where)
  }
  return extended
}
```

---

## Appendix F, Section 9: Drizzle with Zod Integration

Validating data before inserting or updating is crucial. You can integrate Zod with Drizzle schemas.

### 9.1 Generating Zod Schemas from Drizzle Tables

```typescript
import { z } from 'zod'
import { tasks } from './schema'
import { getTableColumns } from 'drizzle-orm/pg-core'

// Manually create Zod schema based on Drizzle table
export const taskSchema = z.object({
  id: z.string().uuid().optional(),
  projectId: z.string().uuid(),
  title: z.string().min(1).max(255),
  description: z.string().optional(),
  status: z.enum(['backlog', 'todo', 'in_progress', 'in_review', 'done']).default('backlog'),
  priority: z.enum(['low', 'medium', 'high', 'urgent']).default('medium'),
  assignedTo: z.string().uuid().optional(),
  createdBy: z.string().uuid(),
  dueDate: z.date().optional(),
  estimatedHours: z.number().positive().optional(),
})

// Type inference
export type TaskInput = z.infer<typeof taskSchema>
```

### 9.2 Validation Middleware

```typescript
import { z } from 'zod'

export async function validateCreateTask(input: unknown) {
  const result = taskSchema.safeParse(input)
  if (!result.success) {
    throw new ValidationError(result.error)
  }
  return result.data
}

// Usage in service
async function createTask(input: unknown) {
  const validated = await validateCreateTask(input)
  const [task] = await db.insert(tasks).values(validated).returning()
  return task
}
```

### 9.3 Using Zod with Drizzle's `infer` Types

```typescript
import { z } from 'zod'
import { tasks, type InferSelectModel } from 'drizzle-orm/pg-core'

type Task = InferSelectModel<typeof tasks>

// Create Zod schema that matches the type
export const taskSchema = z.object({
  id: z.string().uuid(),
  projectId: z.string().uuid(),
  // ... other fields
}) satisfies z.ZodType<Task>
```

---

## Appendix F, Section 10: Drizzle Performance Optimization Advanced Tips

### 10.1 Using `drizzle-typegen`

For large schemas, type inference can slow down your TypeScript compiler. Use `drizzle-typegen` to generate explicit types.

```bash
pnpm add -D drizzle-typegen
```

```typescript
// drizzle-typegen.config.ts
import { defineConfig } from 'drizzle-typegen'

export default defineConfig({
  schema: './src/drizzle/schema/index.ts',
  out: './src/drizzle/types.ts',
})
```

### 10.2 Prepared Statements

Drizzle automatically uses prepared statements when you use `db.execute` with `sql` templates. You can also prepare them manually:

```typescript
const statement = db.prepare(sql`
  SELECT * FROM tasks WHERE project_id = $1 AND status = $2
`)

// Execute multiple times with different parameters
const results1 = await statement.execute([projectId1, 'todo'])
const results2 = await statement.execute([projectId2, 'in_progress'])
```

### 10.3 Batch Insert Optimization

```typescript
// Insert multiple rows in a single statement
const tasksData = [
  { title: 'Task 1', projectId: '...', createdBy: '...' },
  { title: 'Task 2', projectId: '...', createdBy: '...' },
  // ...
]

// Using insert with array of values
await db.insert(tasks).values(tasksData).returning()
```

### 10.4 Using `EXPLAIN` with Drizzle

```typescript
const query = db.select()
  .from(tasks)
  .where(eq(tasks.projectId, projectId))
  .orderBy(desc(tasks.createdAt))

// Get the SQL with parameters
const { sql: sqlString, params } = query.toSQL()
console.log('Query:', sqlString)
console.log('Params:', params)

// Use EXPLAIN to analyze
const explainResult = await db.execute(sql`EXPLAIN ${sqlString}`)
console.log('Explain:', explainResult)
```

---

## Conclusion of Appendix F

This appendix has explored the advanced features of Drizzle ORM, from custom types and full‑text search to GraphQL integration and performance optimizations. You now have a deep understanding of Drizzle's capabilities and can leverage them to build sophisticated, high‑performance applications.
