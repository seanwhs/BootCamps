# Comprehensive Quiz and Test Bank with Answer Keys

## How to Use This Test Bank

This test bank is designed for instructors, self‑assessors, and study groups. It covers **all parts and appendices** of the masterclass.

**Question Types:**
- **Multiple Choice** (MC) – one correct answer.
- **True / False** (TF) – with justification.
- **Short Answer** (SA) – concise, focused responses.
- **Coding Exercises** (CE) – write or complete code snippets.
- **Scenario‑Based** (SB) – apply knowledge to real‑world contexts.

**Answer Keys:**
- Each question includes the correct answer and a brief explanation referencing the relevant section.

---

## Part 0: Introduction

### MC1. What is the primary goal of the TaskFlow Pro application built in this series?
A) To demonstrate a simple to‑do list  
B) To showcase a production‑grade multi‑tenant project management system  
C) To compare only the syntax of Prisma and Drizzle  
D) To build a mobile‑only application  

**Answer:** B  
**Explanation:** TaskFlow Pro is a complete, real‑world application with authentication, teams, projects, tasks, comments, etc., designed to highlight the full capabilities of both ORMs. (Part 0 – Architecture Preview)

---

### MC2. Which of the following is NOT listed as a prerequisite for this series?
A) Basic SQL knowledge  
B) Experience with GraphQL  
C) Familiarity with TypeScript  
D) Comfort with the terminal/CLI  

**Answer:** B  
**Explanation:** The series assumes familiarity with TypeScript, SQL basics, and CLI usage, but GraphQL is not required. GraphQL is covered only as an optional integration in the appendices. (Part 0 – Prerequisites)

---

### TF1. The series uses both Prisma and Drizzle in the same codebase to build the same application twice.
**Answer:** True  
**Explanation:** The monorepo contains both ORM implementations, and the capstone project builds the application using each ORM separately for comparison.

---

### SA1. Name three core technologies used in the series besides Prisma and Drizzle.
**Answer:** (Any three of) TypeScript, Node.js, Next.js, React, PostgreSQL, Docker, Redis, BullMQ, Terraform, etc.

---

## Part 1: ORM Philosophy, Architecture, and Design Principles

### MC3. Prisma's Query Engine is written in:
A) TypeScript  
B) Rust  
C) Go  
D) Python  

**Answer:** B  
**Explanation:** Prisma's Query Engine is a compiled Rust binary that handles query parsing, optimisation, and execution. (Part 1 – Prisma Architecture)

---

### MC4. Which ORM uses a code‑first approach where the schema is defined in TypeScript?
A) Prisma  
B) Drizzle  
C) Both  
D) Neither  

**Answer:** B  
**Explanation:** Drizzle's schema is defined using TypeScript functions (`pgTable`, etc.), whereas Prisma uses a dedicated DSL in `schema.prisma`. (Part 1 – Philosophy)

---

### MC5. Which of the following is a key advantage of Drizzle over Prisma in serverless environments?
A) Built‑in connection pooling  
B) Smaller bundle size and faster cold starts  
C) Automatic migration generation  
D) Native support for MongoDB  

**Answer:** B  
**Explanation:** Drizzle has no external Query Engine, so it loads faster and has a much smaller footprint, reducing cold start latency. (Part 1 – Architecture Comparison)

---

### TF2. Prisma's type safety relies entirely on TypeScript inference without any code generation.
**Answer:** False  
**Explanation:** Prisma generates explicit types from the schema file; it does not rely solely on inference. (Part 1 – Type Safety)

---

### TF3. Drizzle requires a separate runtime binary to execute queries.
**Answer:** False  
**Explanation:** Drizzle is pure TypeScript and uses the underlying database driver (e.g., `pg`) directly, with no external binary.

---

### SA2. Briefly describe the difference between schema‑first and code‑first ORM design.
**Answer:**  
Schema‑first (Prisma) defines the database schema in a dedicated language/DSL, from which code (client, types, migrations) is generated.  
Code‑first (Drizzle) defines the schema using the programming language itself (TypeScript), and the ORM infers types and generates SQL from that definition.

---

### SB1. Your team consists of junior developers new to SQL and you need to build a CRUD‑heavy admin dashboard quickly. Which ORM would you recommend and why?
**Answer:** Prisma – because the declarative schema and generated client are easier to learn, reduce the need for writing raw SQL, and speed up development.

---

## Part 2: Schema Design, Modeling, and Migrations

### MC6. In Prisma, which attribute is used to map a model field to a different column name in the database?
A) `@db`  
B) `@map`  
C) `@relation`  
D) `@id`  

**Answer:** B  
**Explanation:** `@map` is used to specify the underlying column name, while `@db` specifies the database type. (Part 2 – Prisma Schema)

---

### MC7. Which Drizzle function is used to define a PostgreSQL enumeration?
A) `pgEnum`  
B) `enumType`  
C) `createEnum`  
D) `defineEnum`  

**Answer:** A  
**Explanation:** `pgEnum` is exported from `drizzle-orm/pg-core` and used to create an enum type. (Part 2 – Drizzle Schema)

---

### MC8. What is the recommended strategy for adding a `NOT NULL` constraint to a column that currently contains null values?
A) Alter the column directly; PostgreSQL will handle it.  
B) Backfill the null values first, then add the constraint.  
C) Drop the column and recreate it.  
D) Use a default value and then add the constraint.  

**Answer:** B  
**Explanation:** You must populate all rows with non‑null values before applying the constraint; otherwise the migration will fail. (Part 2 – Production Migration Strategies)

---

### TF4. Drizzle migrations are stored as plain SQL files, which you can edit manually.
**Answer:** True  
**Explanation:** Drizzle Kit generates `.sql` migration files that you can modify before applying. (Part 2 – Migration Workflows)

---

### TF5. Prisma's `@@unique` directive creates a composite unique constraint on multiple fields.
**Answer:** True  
**Explanation:** `@@unique([field1, field2])` is used for composite unique constraints. (Part 2 – Prisma Schema)

---

### SA3. What is a "zero‑downtime migration" and why is it important?
**Answer:** A zero‑downtime migration is a process of evolving a database schema without causing application downtime. It allows the application to continue serving requests while the schema changes are applied in phases (expand, backfill, switch, cleanup). It is critical for production services that cannot afford interruptions.

---

### CE1. Write a Prisma model for a `Comment` table with fields: `id` (UUID, default), `content` (text), `createdAt` (timestamp with default), and a foreign key to `Post` (one‑to‑many). Include appropriate attributes.
**Answer:**  
```prisma
model Comment {
  id        String   @id @default(uuid()) @db.Uuid
  content   String   @db.Text
  createdAt DateTime @default(now()) @map("created_at")
  postId    String   @map("post_id") @db.Uuid
  post      Post     @relation(fields: [postId], references: [id], onDelete: Cascade)
}
```

---

### CE2. Write the equivalent Drizzle table definition for the same `Comment` table.
**Answer:**  
```typescript
import { pgTable, uuid, text, timestamp } from 'drizzle-orm/pg-core'
import { posts } from './posts'

export const comments = pgTable('comments', {
  id: uuid('id').primaryKey().defaultRandom(),
  content: text('content').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  postId: uuid('post_id').notNull().references(() => posts.id, { onDelete: 'cascade' }),
})
```

---

## Part 3: Querying, Performance, and Type Safety

### MC9. Which Prisma method is used to execute a raw SQL query that returns rows?
A) `prisma.$executeRaw`  
B) `prisma.$queryRaw`  
C) `prisma.rawQuery`  
D) `prisma.sql`  

**Answer:** B  
**Explanation:** `$queryRaw` is for SELECT queries that return data; `$executeRaw` is for INSERT/UPDATE/DELETE. (Part 3 – Raw SQL)

---

### MC10. In Drizzle, which function is used to combine multiple WHERE conditions with AND logic?
A) `and()`  
B) `combine()`  
C) `all()`  
D) `sql.and()`  

**Answer:** A  
**Explanation:** `and(cond1, cond2, ...)` from `drizzle-orm` is used to create a conjunction of conditions. (Part 3 – Advanced Query Construction)

---

### MC11. Which pagination strategy is more efficient for large datasets and uses a `WHERE` clause on the cursor columns?
A) Offset pagination  
B) Cursor pagination  
C) Limit‑only pagination  
D) Random pagination  

**Answer:** B  
**Explanation:** Cursor (keyset) pagination avoids scanning offset rows and is more efficient for large result sets. (Part 3 – Pagination)

---

### TF6. Prisma's `groupBy` is a stable, production‑ready feature for aggregations.
**Answer:** False  
**Explanation:** `groupBy` is still a preview feature; for reliable aggregations, raw SQL is recommended. (Part 3 – Aggregations)

---

### TF7. Drizzle transactions must be used with the `db.transaction` callback and all operations inside use the transaction client.
**Answer:** True  
**Explanation:** `db.transaction` provides a transactional client (`tx`) that must be used for all operations within that transaction. (Part 3 – Transactions)

---

### SA4. Name two advantages of cursor‑based pagination over offset‑based pagination.
**Answer:**  
1. It is more efficient for large offsets because the database does not have to scan skipped rows.  
2. It prevents missing or duplicate rows when new data is inserted while paginating (consistent order).

---

### CE3. Write a Prisma query that fetches all tasks in a project (projectId given), sorted by dueDate ascending, and includes the assignee's full name and email.
**Answer:**  
```typescript
const tasks = await prisma.task.findMany({
  where: { projectId: projectId },
  orderBy: { dueDate: 'asc' },
  include: {
    assignee: {
      select: { fullName: true, email: true }
    }
  }
})
```

---

### CE4. Write the equivalent Drizzle query using the relational API (`db.query.tasks.findMany`).
**Answer:**  
```typescript
const tasks = await db.query.tasks.findMany({
  where: eq(tasks.projectId, projectId),
  orderBy: [asc(tasks.dueDate)],
  with: {
    assignee: {
      columns: { fullName: true, email: true }
    }
  }
})
```

---

### SB2. Your analytics team needs to run a complex query with multiple joins, window functions, and a CTE. Which ORM would you prefer and why?
**Answer:** Drizzle – because it allows writing SQL‑like queries directly with full type safety and supports window functions and CTEs natively, whereas Prisma would require raw SQL for these, losing some type safety.

---

## Part 4: Framework Integration

### MC12. In Next.js Server Actions, which directive must be used at the top of the function to mark it as a server‑side action?
A) `'use client'`  
B) `'use server'`  
C) `'use action'`  
D) `'server action'`  

**Answer:** B  
**Explanation:** `'use server'` is used to designate functions that run on the server and can be called from client components. (Part 4 – Server Actions)

---

### MC13. Which React 19 hook is used to handle optimistic UI updates?
A) `useActionState`  
B) `useOptimistic`  
C) `useTransition`  
D) `useDeferredValue`  

**Answer:** B  
**Explanation:** `useOptimistic` allows you to optimistically update the UI while a server action is pending. (Part 4 – React 19 Integration)

---

### MC14. Which database client is recommended for Drizzle when deploying to Vercel Edge Functions?
A) `node-postgres` (pg)  
B) `drizzle-orm/neon-http`  
C) `drizzle-orm/libsql`  
D) `prisma accelerate`  

**Answer:** B  
**Explanation:** The Neon HTTP driver works over HTTP and is compatible with edge runtimes. (Part 4 – Edge Runtime)

---

### TF8. Prisma Client should be instantiated once and reused across requests in serverless environments to avoid exhausting connections.
**Answer:** True  
**Explanation:** Using a singleton pattern (globalThis) prevents creating new client instances on each invocation, saving connection overhead. (Part 4 – Connection Management)

---

### TF9. Drizzle cannot be used with SQLite in React Native.
**Answer:** False  
**Explanation:** Drizzle has excellent SQLite support through `drizzle-orm/expo-sqlite` and is a good choice for mobile apps. (Part 4 – React Native)

---

### SA5. What is the purpose of `revalidatePath` in Next.js Server Actions?
**Answer:** It invalidates the cache for a specific route, forcing the server to re‑fetch fresh data on the next request, ensuring the UI reflects the changes made by the action. (Part 4 – Server Actions)

---

### CE5. Write a Next.js Server Action that creates a new project and revalidates the `/projects` page. Use Prisma.
**Answer:**  
```typescript
'use server'
import { prisma } from '@taskflow/database/prisma/client'
import { revalidatePath } from 'next/cache'

export async function createProject(data: { name: string; orgId: string; userId: string }) {
  await prisma.project.create({
    data: {
      name: data.name,
      organizationId: data.orgId,
      createdBy: data.userId,
    }
  })
  revalidatePath('/projects')
}
```

---

## Part 5: Production Readiness

### MC15. Which Prisma service helps reduce cold start latency in serverless environments by providing a connection pool and query proxy?
A) Prisma Client  
B) Prisma Accelerate  
C) Prisma Studio  
D) Prisma Migrate  

**Answer:** B  
**Explanation:** Prisma Accelerate offloads the Query Engine and manages connections, reducing cold start. (Part 5 – Serverless Optimization)

---

### MC16. Which tool is recommended for integration testing with a real PostgreSQL database in a CI pipeline?
A) Jest with manual mocks  
B) Testcontainers  
C) In‑memory SQLite  
D) Prisma Studio  

**Answer:** B  
**Explanation:** Testcontainers spins up a real PostgreSQL container, providing a true integration test environment. (Part 5 – Testing Strategies)

---

### MC17. What is the purpose of Row‑Level Security (RLS) in PostgreSQL?
A) To encrypt data at rest  
B) To restrict row access based on user permissions  
C) To enforce foreign key constraints  
D) To improve query performance  

**Answer:** B  
**Explanation:** RLS allows you to define policies that control which rows a user can see or modify, adding an extra security layer. (Part 5 – Security)

---

### TF10. Drizzle can use HTTP drivers to connect to databases like Neon and Turso, making it suitable for edge deployments.
**Answer:** True  
**Explanation:** Drizzle's `neon-http` and `libsql` drivers are built for edge runtimes. (Part 5 – Edge Runtime)

---

### TF11. It is safe to run `drizzle-kit push:pg` in production to quickly update the schema.
**Answer:** False  
**Explanation:** `push` applies changes without a migration history and can cause data loss; production should use generated migration files. (Part 5 – Migration Strategies)

---

### SA6. List four components of a robust observability stack for a production application.
**Answer:** Structured logging (e.g., Winston), metrics (e.g., Prometheus), distributed tracing (e.g., OpenTelemetry), and a dashboard (e.g., Grafana). (Part 5 – Observability)

---

### CE6. Write a Prisma middleware that logs every query execution time using `$use`.
**Answer:**  
```typescript
prisma.$use(async (params, next) => {
  const before = Date.now()
  const result = await next(params)
  const after = Date.now()
  console.log(`Query ${params.model}.${params.action} took ${after - before}ms`)
  return result
})
```

---

## Appendices

### MC18. In Prisma, which method in a custom extension allows you to add computed fields to result objects?
A) `query`  
B) `result`  
C) `model`  
D) `client`  

**Answer:** B  
**Explanation:** The `result` block defines computed fields that are added to the returned objects. (Appendix G – Computed Fields)

---

### MC19. Which Drizzle function is used to create a custom column type, such as a vector column for embeddings?
A) `customType`  
B) `columnType`  
C) `defineType`  
D) `createType`  

**Answer:** A  
**Explanation:** `customType` is exported from `drizzle-orm/pg-core` and allows defining custom column types. (Appendix F – Custom Types)

---

### MC20. In a zero‑downtime migration, which phase involves removing the old, unused columns?
A) Expand  
B) Backfill  
C) Switch  
D) Cleanup  

**Answer:** D  
**Explanation:** The cleanup phase is the final step where obsolete schema elements are dropped. (Appendix E – Migration Strategies)

---

### TF12. In Drizzle, you can use the `sql` template literal to include arbitrary SQL fragments, including function calls, while still maintaining type safety.
**Answer:** True  
**Explanation:** `sql` allows you to embed raw SQL in a type‑safe way with placeholders for parameters. (Appendix F – SQL Templates)

---

### TF13. Prisma's extensions can override default query methods to implement soft deletes and tenant isolation.
**Answer:** True  
**Explanation:** The `query` block in extensions allows you to intercept and modify query behaviour. (Appendix G – Client Extensions)

---

### SA7. Explain the purpose of a snapshot in Drizzle migrations.
**Answer:** The snapshot (stored as `snapshot.json`) records the current state of the schema as understood by Drizzle Kit. It is used to detect changes when generating new migrations, ensuring consistency between the schema definition and the migration files.

---

### CE7. (Coding Exercise) Write a Drizzle migration file (custom SQL) that adds a `priority` column to the `projects` table with a default value of `'medium'`, and then backfills the new column for all rows.
**Answer:**  
```sql
-- Migration file
ALTER TABLE projects ADD COLUMN priority TEXT DEFAULT 'medium';
UPDATE projects SET priority = 'medium' WHERE priority IS NULL;
ALTER TABLE projects ALTER COLUMN priority SET NOT NULL;
```

---

### SB3. A client wants to migrate a large Prisma‑based codebase to Drizzle to improve performance. What are three key challenges they might face and how would you address them?
**Answer:**  
1. **Schema translation** – Prisma's DSL must be converted to Drizzle's TypeScript tables; use an automated script and manual review.  
2. **Query rewriting** – Many `include`/`select` queries need to be rewritten as joins or `with`; provide a mapping guide and test thoroughly.  
3. **Migration compatibility** – Existing migration history must be reconciled; generate Drizzle migrations from the current database state using introspection.  

---

## Answer Key Summary

| Question | Answer |
|----------|--------|
| MC1 | B |
| MC2 | B |
| MC3 | B |
| MC4 | B |
| MC5 | B |
| MC6 | B |
| MC7 | A |
| MC8 | B |
| MC9 | B |
| MC10 | A |
| MC11 | B |
| MC12 | B |
| MC13 | B |
| MC14 | B |
| MC15 | B |
| MC16 | B |
| MC17 | B |
| MC18 | B |
| MC19 | A |
| MC20 | D |
| TF1 | True |
| TF2 | False |
| TF3 | False |
| TF4 | True |
| TF5 | True |
| TF6 | False |
| TF7 | True |
| TF8 | True |
| TF9 | False |
| TF10 | True |
| TF11 | False |
| TF12 | True |
| TF13 | True |

---

## Final Notes

This test bank covers the entire masterclass. Use these questions for:
- Pre‑training assessments to gauge prior knowledge.
- Post‑training quizzes to validate learning.
- Certification exams (if offering a certificate).

**Good luck with your teaching and learning!**

---

**[END OF QUIZ AND TEST BANK]**
