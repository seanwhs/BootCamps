# Student Notes: Drizzle vs. Prisma Masterclass

## Purpose

These notes are your **quick reference** during the course and beyond. They summarise the most important concepts, commands, code snippets, and best practices from each part of the series. Keep them handy while working through exercises and when making decisions in your own projects.

---

## Part 0: Introduction – Key Points

### The Application: TaskFlow Pro
- Multi‑tenant project management system.
- Features: auth, teams, projects, tasks, comments, attachments, audit logs, webhooks.

### Technology Stack
- **Language:** TypeScript 5.5+
- **Runtime:** Node.js 20+
- **Framework:** Next.js 16 (App Router) + React 19
- **Database:** PostgreSQL 16
- **ORMs:** Prisma (schema‑first) & Drizzle (code‑first)
- **Other:** Docker, Redis, BullMQ, Turborepo, pnpm

### Setup Commands
```bash
# Create monorepo
mkdir taskflow-pro && cd taskflow-pro
pnpm init
# create pnpm-workspace.yaml
# create packages/database and apps/nextjs
```

### Essential Environment Variables
```env
DATABASE_URL="postgresql://user:pass@localhost:5432/taskflow"
```

---

## Part 1: ORM Philosophy and Architecture

### Prisma (Schema‑First)
- **Schema file:** `schema.prisma`
- **Generates:** Prisma Client, migration SQL, TypeScript types.
- **Runtime:** Rust Query Engine (external binary).
- **Workflow:** define schema → `prisma generate` → `prisma migrate` → query.
- **Pros:** Declarative, easy migrations, great DX, multi‑DB support.
- **Cons:** Heavier, slower cold starts, less SQL transparency.

### Drizzle (Code‑First)
- **Schema:** TypeScript with `pgTable`, `relations`.
- **Generates:** Optional types (`drizzle-typegen`), migration SQL.
- **Runtime:** Pure TypeScript – no external binary.
- **Workflow:** define schema → `drizzle-kit generate` → `drizzle migrate` → query.
- **Pros:** Lightweight, fast cold starts, full SQL power, edge‑ready.
- **Cons:** Steeper learning curve, requires SQL knowledge.

### Decision Framework (Quick)
| Criterion | Prisma | Drizzle |
|-----------|--------|---------|
| CRUD heavy | ✅ | ✅ |
| Complex SQL | ⚠️ (raw SQL) | ✅ (native) |
| Serverless cold start | Slower (unless Accelerate) | Fast |
| Edge deployment | Limited | ✅ |
| Mobile (SQLite) | ❌ | ✅ |
| Multi‑DB (SQL Server) | ✅ | ❌ |

---

## Part 2: Schema Design and Migrations

### Prisma Schema Snippets
```prisma
// Enums
enum TaskStatus {
  backlog todo in_progress in_review done
}

// Model with relations and indexes
model Task {
  id          String     @id @default(uuid()) @db.Uuid
  title       String     @db.Text
  status      TaskStatus @default(backlog)
  projectId   String     @map("project_id") @db.Uuid
  project     Project    @relation(fields: [projectId], references: [id])
  @@index([projectId, status])
  @@map("tasks")
}
```

### Drizzle Schema Snippets
```typescript
import { pgTable, uuid, text, timestamp, index } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'

export const tasks = pgTable('tasks', {
  id: uuid('id').primaryKey().defaultRandom(),
  title: text('title').notNull(),
  status: taskStatusEnum('status').default('backlog'),
  projectId: uuid('project_id').notNull().references(() => projects.id),
}, (table) => ({
  idx: index('tasks_project_status_idx').on(table.projectId, table.status),
}))
```

### Migration Commands
| Prisma | Drizzle |
|--------|---------|
| `prisma migrate dev --name <name>` | `drizzle-kit generate:pg` |
| `prisma migrate deploy` (prod) | `drizzle-kit push:pg` (dev only) |
| `prisma migrate reset` (dev) | `drizzle migrate` (custom script) |

### Zero‑Downtime Migration Pattern
1. **Expand:** add column nullable.
2. **Backfill:** populate new column in background.
3. **Switch:** deploy code using new column.
4. **Cleanup:** drop old column.

---

## Part 3: Querying and Performance

### Common Query Patterns

| Operation | Prisma | Drizzle |
|-----------|--------|---------|
| Find by ID | `prisma.user.findUnique({ where: { id } })` | `db.query.users.findFirst({ where: eq(users.id, id) })` |
| All with filter | `prisma.task.findMany({ where: { status: 'todo' } })` | `db.select().from(tasks).where(eq(tasks.status, 'todo'))` |
| Include relation | `include: { assignee: true }` | `with: { assignee: true }` (relational API) or `leftJoin` |
| Create | `prisma.task.create({ data })` | `db.insert(tasks).values(data).returning()` |
| Update | `prisma.task.update({ where: { id }, data })` | `db.update(tasks).set(data).where(eq(tasks.id, id)).returning()` |
| Delete | `prisma.task.delete({ where: { id } })` | `db.delete(tasks).where(eq(tasks.id, id)).returning()` |
| Transaction | `prisma.$transaction(async (tx) => { ... })` | `db.transaction(async (tx) => { ... })` |
| Raw SQL | `prisma.$queryRaw` / `$executeRaw` | `db.execute(sql`...`)` |

### Pagination
- **Offset:** `skip` + `take` – simple but inefficient for large offsets.
- **Cursor:** `where` + `cursor` + `take` – efficient, use sortable unique columns.

### Aggregations
- **Prisma:** use `$queryRaw` or preview `groupBy`.
- **Drizzle:** use `count()`, `sum()`, `avg()` inside `select`.

### Performance Tips
- Use `select` to fetch only needed columns.
- Index foreign keys and frequently filtered columns.
- For Prisma, enable `log: ['query']` to see generated SQL.
- For Drizzle, set `logger: true` in drizzle config.
- Use `EXPLAIN` to analyse slow queries.

---

## Part 4: Framework Integration

### Next.js 16 + React 19

#### Server Components (default)
```tsx
// Fetch data directly in a server component
export default async function Page() {
  const projects = await prisma.project.findMany()
  return <div>{/* render projects */}</div>
}
```

#### Server Actions
```typescript
'use server'
import { revalidatePath } from 'next/cache'
export async function createProject(data: FormData) {
  await prisma.project.create({ data })
  revalidatePath('/projects')
}
```

#### useActionState (form handling)
```tsx
const [state, formAction, isPending] = useActionState(createProject, null)
```

#### useOptimistic (optimistic UI)
```tsx
const [optimisticTasks, addOptimistic] = useOptimistic(tasks, (state, newTask) => [...state, newTask])
```

### Connection Management
- **Prisma:** Singleton with `globalThis` to reuse across requests.
- **Drizzle:** Singleton `Pool` from `pg`; for edge, use HTTP drivers.

### Edge Deployment (Drizzle)
```typescript
import { drizzle } from 'drizzle-orm/neon-http'
import { neon } from '@neondatabase/serverless'
const sql = neon(process.env.DATABASE_URL)
export const db = drizzle(sql, { schema })
```

### React Native (Drizzle + SQLite)
```typescript
import { drizzle } from 'drizzle-orm/expo-sqlite'
import { openDatabaseSync } from 'expo-sqlite'
const expoDb = openDatabaseSync('taskflow.db')
export const db = drizzle(expoDb, { schema })
```

---

## Part 5: Production Readiness

### Deployment Options
- **Traditional:** PM2, systemd.
- **Container:** Docker, Kubernetes.
- **Serverless:** Vercel, AWS Lambda.
- **Edge:** Cloudflare Workers, Vercel Edge.

### Testing
- **Unit:** mock ORM clients (Vitest).
- **Integration:** Testcontainers (real PostgreSQL).
- **E2E:** Playwright with test database.

### Observability
- **Logging:** Winston, structured JSON logs.
- **Metrics:** Prometheus (counters, histograms, gauges).
- **Tracing:** OpenTelemetry.
- **Dashboard:** Grafana.

### Security
- **SQL injection:** Use parameterised queries (default in both ORMs).
- **Input validation:** Zod.
- **Secrets:** Environment variables, Vault, AWS Secrets Manager.
- **RLS:** PostgreSQL row‑level security with session variables.
- **RBAC:** Role checks in service layer.

### Scalability
- **Read replicas:** Separate DB for reads.
- **Connection pooling:** Prisma Accelerate, PgBouncer.
- **Caching:** Redis.
- **Background jobs:** BullMQ.

---

## Quick Reference Commands

### Prisma
```bash
npx prisma generate          # Generate client
npx prisma migrate dev       # Dev migration
npx prisma migrate deploy    # Prod migration
npx prisma studio            # GUI
```

### Drizzle
```bash
npx drizzle-kit generate:pg  # Generate migration
npx drizzle-kit push:pg      # Push schema (dev only)
npx drizzle-kit check        # Check differences
```

### Monorepo
```bash
pnpm install                 # Install all
pnpm --filter <pkg> dev      # Run dev script
pnpm build                   # Build all packages
```

---

## Common Pitfalls & Solutions

| Problem | Solution |
|---------|----------|
| Prisma "Cannot find module" | Run `prisma generate` after schema change. |
| Drizzle "relation does not exist" | Check migration order or run `drizzle-kit push`. |
| Cold start > 200ms | Use Prisma Accelerate or Drizzle HTTP driver. |
| Slow join query | Add index on foreign key; consider denormalization. |
| Transaction deadlock | Keep transactions short; use `FOR UPDATE` carefully. |
| Data duplication in joins | Use `select` distinct or use Drizzle's relational API. |

---

## Decision Flowchart (Summary)

```
Is your app mostly CRUD with simple queries?
├─ Yes → Team SQL skills?
│   ├─ Beginner → Prisma
│   └─ Expert → Drizzle (or Prisma for convenience)
└─ No (complex queries, analytics, edge)
    ├─ Need edge or ultra‑low latency? → Drizzle
    └─ Otherwise → Prisma (if multi‑DB) or Drizzle (if performance)
```

---

## Final Cheat Sheet

| Concept | Prisma | Drizzle |
|---------|--------|---------|
| Schema definition | `schema.prisma` | TypeScript `pgTable` |
| Relations | `@relation` | `relations()` |
| Migrations | `prisma migrate` | `drizzle-kit` |
| Client | `PrismaClient` | `drizzle(pool, { schema })` |
| Query builder | Generated methods | `select()`, `where()`, `with` |
| Raw SQL | `$queryRaw` | `db.execute(sql`...`)` |
| Transactions | `$transaction` | `db.transaction` |
| Type safety | Generated types | Inferred types |
| Edge support | Accelerate required | Native HTTP drivers |

---

*These notes are meant to be a living document – add your own annotations, favourite snippets, and corrections as you learn!*

---

**[END OF STUDENT NOTES]**
