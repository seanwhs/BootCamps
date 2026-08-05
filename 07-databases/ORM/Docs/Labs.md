# Appendix K: Lab Book – Step‑by‑Step Practical Labs

## How to Use This Lab Book

This lab book contains **12 hands‑on labs** that guide you through building TaskFlow Pro from scratch. Each lab includes:

- **Lab Objectives** – what you will accomplish.
- **Preparation** – any setup needed.
- **Step‑by‑Step Instructions** – numbered steps with code blocks.
- **Verification** – how to check your work.
- **Lab Questions** – reflection and deeper understanding.

**Duration:** Each lab takes approximately 45–90 minutes.

**Prerequisites:** Node.js 20+, pnpm, Docker, and a code editor.

---

## Lab 0: Environment Setup

### Objectives
- Install required software.
- Set up the project repository.
- Verify PostgreSQL is running.

### Preparation
None.

### Steps

#### 0.1 Install Required Software
```bash
# Check versions
node --version  # v20 or higher
pnpm --version  # v9 or higher
docker --version
git --version
```

If any are missing, install them:
- **Node.js:** https://nodejs.org
- **pnpm:** `npm install -g pnpm`
- **Docker:** https://www.docker.com

#### 0.2 Create Project Directory
```bash
mkdir ~/projects/taskflow-pro
cd ~/projects/taskflow-pro
```

#### 0.3 Initialize Git and pnpm
```bash
git init
pnpm init
```

#### 0.4 Create pnpm Workspace
Create `pnpm-workspace.yaml`:
```yaml
packages:
  - "apps/*"
  - "packages/*"
```

#### 0.5 Start PostgreSQL via Docker
```bash
docker run --name taskflow-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=taskflow \
  -p 5432:5432 \
  -d postgres:16-alpine
```

#### 0.6 Verify PostgreSQL
```bash
docker ps | grep taskflow-postgres
# Should show the container running

# Test connection (if psql installed)
psql -h localhost -U postgres -d taskflow -c "SELECT 1"
# Should return 1
```

### Verification
- [ ] `node --version` shows v20+.
- [ ] `pnpm --version` shows v9+.
- [ ] Docker container is running.
- [ ] PostgreSQL accepts connections.

### Lab Questions
1. What is the purpose of a monorepo?
2. Why are we using Docker for PostgreSQL?

---

## Lab 1: Project Structure and Prisma Setup

### Objectives
- Create the monorepo structure.
- Set up Prisma ORM.
- Define a minimal schema and run migrations.

### Preparation
- Lab 0 completed.

### Steps

#### 1.1 Create Root Files
Create `package.json` in the root:
```json
{
  "name": "taskflow-pro",
  "private": true,
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build"
  },
  "devDependencies": {
    "turbo": "^2.0.0"
  },
  "packageManager": "pnpm@9.0.0"
}
```

Create `tsconfig.json` in the root:
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "declaration": true,
    "baseUrl": ".",
    "paths": {
      "@taskflow/database/*": ["./packages/database/src/*"]
    }
  },
  "exclude": ["node_modules", "dist"]
}
```

#### 1.2 Create Database Package
```bash
mkdir -p packages/database/src/prisma
cd packages/database
```

Create `packages/database/package.json`:
```json
{
  "name": "@taskflow/database",
  "version": "0.0.1",
  "main": "./src/index.ts",
  "scripts": {
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate deploy"
  },
  "dependencies": {
    "@prisma/client": "^5.16.0"
  },
  "devDependencies": {
    "prisma": "^5.16.0",
    "typescript": "^5.5.0"
  }
}
```

#### 1.3 Create Prisma Schema
Create `packages/database/src/prisma/schema.prisma`:
```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  name  String
}
```

#### 1.4 Create .env File
Create `packages/database/.env`:
```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/taskflow"
```

#### 1.5 Install Dependencies and Generate Client
```bash
pnpm install
pnpm prisma:generate
```

#### 1.6 Run Migration
```bash
pnpm prisma migrate dev --name init
```

### Verification
- [ ] `prisma` folder contains `schema.prisma`.
- [ ] `node_modules/.prisma` generated.
- [ ] Migration applied – check via `psql` or Prisma Studio (`prisma studio`).

### Lab Questions
1. What does `prisma migrate dev` do?
2. Why do we need to generate the client before using it?

---

## Lab 2: Drizzle Setup and Schema

### Objectives
- Install Drizzle ORM.
- Define the same schema using Drizzle.
- Generate and run Drizzle migrations.

### Preparation
- Lab 1 completed.

### Steps

#### 2.1 Install Drizzle in Database Package
```bash
cd packages/database
pnpm add drizzle-orm pg
pnpm add -D drizzle-kit @types/pg
```

#### 2.2 Create Drizzle Schema
Create `packages/database/src/drizzle/schema.ts`:
```typescript
import { pgTable, serial, text, varchar } from 'drizzle-orm/pg-core'

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: text('email').notNull().unique(),
  name: varchar('name', { length: 255 }).notNull(),
})
```

#### 2.3 Create Drizzle Client
Create `packages/database/src/drizzle/client.ts`:
```typescript
import { drizzle } from 'drizzle-orm/node-postgres'
import { Pool } from 'pg'
import * as schema from './schema'

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
})

export const db = drizzle(pool, { schema })
```

#### 2.4 Configure Drizzle Kit
Create `packages/database/drizzle.config.ts`:
```typescript
import { defineConfig } from 'drizzle-kit'
import dotenv from 'dotenv'
dotenv.config()

export default defineConfig({
  dialect: 'postgresql',
  schema: './src/drizzle/schema.ts',
  out: './src/drizzle/migrations',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
})
```

#### 2.5 Generate and Run Migrations
```bash
pnpm drizzle-kit generate:pg
pnpm drizzle-kit push:pg
```

### Verification
- [ ] Drizzle schema defined.
- [ ] Migration folder (`src/drizzle/migrations`) created.
- [ ] Database has a `users` table (verify via `psql \dt`).

### Lab Questions
1. How does Drizzle's schema definition differ from Prisma's?
2. What is the purpose of `drizzle-kit`?

---

## Lab 3: CRUD Operations

### Objectives
- Write type‑safe CRUD functions using Prisma.
- Write type‑safe CRUD functions using Drizzle.
- Compare the code side‑by‑side.

### Preparation
- Labs 1 and 2 completed.

### Steps

#### 3.1 Prisma CRUD Functions
Create `packages/database/src/prisma/crud.ts`:
```typescript
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

export async function createUser(data: { email: string; name: string }) {
  return prisma.user.create({ data })
}

export async function findUserByEmail(email: string) {
  return prisma.user.findUnique({ where: { email } })
}

export async function getAllUsers() {
  return prisma.user.findMany()
}

export async function updateUser(id: number, data: { name?: string; email?: string }) {
  return prisma.user.update({ where: { id }, data })
}

export async function deleteUser(id: number) {
  return prisma.user.delete({ where: { id } })
}
```

#### 3.2 Drizzle CRUD Functions
Create `packages/database/src/drizzle/crud.ts`:
```typescript
import { db } from './client'
import { users } from './schema'
import { eq } from 'drizzle-orm'

export async function createUser(data: { email: string; name: string }) {
  const [user] = await db.insert(users).values(data).returning()
  return user
}

export async function findUserByEmail(email: string) {
  return db.query.users.findFirst({ where: eq(users.email, email) })
}

export async function getAllUsers() {
  return db.select().from(users)
}

export async function updateUser(id: number, data: { name?: string; email?: string }) {
  const [user] = await db.update(users)
    .set(data)
    .where(eq(users.id, id))
    .returning()
  return user
}

export async function deleteUser(id: number) {
  const [user] = await db.delete(users)
    .where(eq(users.id, id))
    .returning()
  return user
}
```

#### 3.3 Test the Functions
Create `packages/database/src/test-crud.ts`:
```typescript
// Test Prisma
import * as PrismaCrud from './prisma/crud'
async function testPrisma() {
  const user = await PrismaCrud.createUser({ email: 'test@test.com', name: 'Test' })
  console.log('Prisma created:', user)
  const found = await PrismaCrud.findUserByEmail('test@test.com')
  console.log('Prisma found:', found)
}
testPrisma()

// Test Drizzle
import * as DrizzleCrud from './drizzle/crud'
async function testDrizzle() {
  const user = await DrizzleCrud.createUser({ email: 'test2@test.com', name: 'Test2' })
  console.log('Drizzle created:', user)
  const found = await DrizzleCrud.findUserByEmail('test2@test.com')
  console.log('Drizzle found:', found)
}
testDrizzle()
```

Run the test:
```bash
pnpm tsx src/test-crud.ts
```

### Verification
- [ ] Users are created and found with both ORMs.
- [ ] All CRUD functions return expected results.
- [ ] No errors in console.

### Lab Questions
1. What differences do you notice in the API syntax?
2. Which approach feels more natural to you?

---

## Lab 4: Advanced Schema (TaskFlow Pro)

### Objectives
- Expand the schema to include all TaskFlow Pro tables.
- Create migrations for both ORMs.

### Preparation
- Lab 3 completed.

### Steps

#### 4.1 Update Prisma Schema
Replace `packages/database/src/prisma/schema.prisma` with the full TaskFlow Pro schema from Part 2 of the series.

Key tables: `users`, `organizations`, `organization_members`, `projects`, `tasks`, `comments`, `attachments`, `activity_logs`, `webhook_events`.

#### 4.2 Run Prisma Migration
```bash
pnpm prisma migrate dev --name full_schema
```

#### 4.3 Update Drizzle Schema
Create the corresponding Drizzle tables in `packages/database/src/drizzle/schema/`:
- `enums.ts` – all PostgreSQL enums.
- `users.ts`, `organizations.ts`, etc.
- Update `index.ts` to export all.

#### 4.4 Generate Drizzle Migrations
```bash
pnpm drizzle-kit generate:pg
pnpm drizzle-kit push:pg
```

### Verification
- [ ] All tables exist in the database (`psql \dt`).
- [ ] Relations and indexes are applied.

### Lab Questions
1. Why do we separate Drizzle schemas into multiple files?
2. How do Prisma and Drizzle handle enums differently?

---

## Lab 5: Advanced Queries

### Objectives
- Write advanced queries: filtering, aggregations, joins, pagination.

### Preparation
- Lab 4 completed.

### Steps

#### 5.1 Seed Data
Create `packages/database/src/seed.ts` using Prisma to insert:
- 2 organizations.
- 5 users per organization.
- 3 projects per organization.
- 10 tasks per project.

#### 5.2 Prisma Advanced Query
Write a query that fetches:
- Projects in an organization.
- With task count.
- Filtered by status.
- Sorted by creation date.

#### 5.3 Drizzle Advanced Query
Write the equivalent using Drizzle's relational API or joins.

#### 5.4 Pagination Implementation
Implement cursor‑based pagination for tasks.

### Verification
- [ ] Query returns correct filtered results.
- [ ] Pagination works and returns next cursor.

### Lab Questions
1. How does Prisma's `include` compare to Drizzle's `with`?
2. When would you use cursor pagination over offset?

---

## Lab 6: Next.js Integration

### Objectives
- Create a Next.js 16 app.
- Fetch data from the database in Server Components.
- Create a simple API route.

### Preparation
- Lab 5 completed.

### Steps

#### 6.1 Create Next.js App
```bash
mkdir -p apps/nextjs
cd apps/nextjs
pnpm init
pnpm add next@canary react@canary react-dom@canary
```

#### 6.2 Add Next.js Config
Create `apps/nextjs/next.config.ts`:
```typescript
import type { NextConfig } from 'next'
const nextConfig: NextConfig = {
  experimental: { reactCompiler: true },
  transpilePackages: ['@taskflow/database'],
}
export default nextConfig
```

#### 6.3 Create a Page
`apps/nextjs/app/page.tsx`:
```tsx
import { prisma } from '@taskflow/database/prisma/client'

export default async function Home() {
  const users = await prisma.user.findMany()
  return <div>Found {users.length} users</div>
}
```

#### 6.4 Run Development Server
```bash
pnpm dev
# Visit http://localhost:3000
```

### Verification
- [ ] Next.js app loads.
- [ ] User count appears.

### Lab Questions
1. Why can we query the database directly in a Server Component?
2. What are the benefits of Server Components?

---

## Lab 7: Server Actions

### Objectives
- Create a Server Action to insert data.
- Use `useActionState` and `useOptimistic`.

### Preparation
- Lab 6 completed.

### Steps

#### 7.1 Create Server Action
`apps/nextjs/app/actions/users.ts`:
```typescript
'use server'
import { prisma } from '@taskflow/database/prisma/client'
import { revalidatePath } from 'next/cache'

export async function createUser(formData: FormData) {
  const email = formData.get('email') as string
  const name = formData.get('name') as string
  await prisma.user.create({ data: { email, name } })
  revalidatePath('/')
}
```

#### 7.2 Client Component with Form
`apps/nextjs/components/AddUserForm.tsx`:
```tsx
'use client'
import { useActionState } from 'react'
import { createUser } from '@/app/actions/users'

export function AddUserForm() {
  const [, action, pending] = useActionState(createUser, null)
  return (
    <form action={action}>
      <input name="email" placeholder="Email" />
      <input name="name" placeholder="Name" />
      <button type="submit" disabled={pending}>Add User</button>
    </form>
  )
}
```

#### 7.3 Add Form to Page
Update `app/page.tsx` to include the form.

### Verification
- [ ] Form submits successfully.
- [ ] Page revalidates and shows updated user count.

### Lab Questions
1. What is the role of `useActionState`?
2. Why is `revalidatePath` necessary?

---

## Lab 8: Transactions

### Objectives
- Write a transaction that creates a project with tasks.
- Implement using both ORMs.

### Preparation
- Lab 7 completed.

### Steps

#### 8.1 Prisma Transaction
Create `packages/database/src/prisma/transactions.ts`:
```typescript
import { prisma } from './client'

export async function createProjectWithTasks(
  projectData: any,
  tasksData: any[]
) {
  return prisma.$transaction(async (tx) => {
    const project = await tx.project.create({ data: projectData })
    const tasks = await tx.task.createMany({
      data: tasksData.map(t => ({ ...t, projectId: project.id })),
    })
    return { project, tasks }
  })
}
```

#### 8.2 Drizzle Transaction
```typescript
import { db } from '../drizzle/client'
import { projects, tasks } from '../drizzle/schema'

export async function createProjectWithTasks(
  projectData: any,
  tasksData: any[]
) {
  return db.transaction(async (tx) => {
    const [project] = await tx.insert(projects).values(projectData).returning()
    const insertedTasks = await tx.insert(tasks)
      .values(tasksData.map(t => ({ ...t, projectId: project.id })))
      .returning()
    return { project, tasks: insertedTasks }
  })
}
```

#### 8.3 Test the Transaction
Write a script to call both functions and verify all operations complete or rollback on error.

### Verification
- [ ] Transaction creates project and tasks atomically.
- [ ] If an error occurs, no data is saved.

### Lab Questions
1. Why are transactions important?
2. What happens if the second operation fails in a transaction?

---

## Lab 9: Observability

### Objectives
- Add logging to both ORMs.
- Implement a health check endpoint.

### Preparation
- Lab 8 completed.

### Steps

#### 9.1 Add Winston Logging
```bash
pnpm add winston
```

Create `packages/database/src/logger.ts`:
```typescript
import winston from 'winston'
export const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [new winston.transports.Console()],
})
```

#### 9.2 Prisma Logging Middleware
```typescript
prisma.$use(async (params, next) => {
  const start = Date.now()
  const result = await next(params)
  const duration = Date.now() - start
  logger.info('Prisma query', { model: params.model, duration })
  return result
})
```

#### 9.3 Drizzle Logging
Enable `logger: true` in Drizzle configuration:
```typescript
const db = drizzle(pool, { schema, logger: true })
```

#### 9.4 Health Check Endpoint
`apps/nextjs/app/api/health/route.ts`:
```typescript
import { NextResponse } from 'next/server'
import { prisma } from '@taskflow/database/prisma/client'

export async function GET() {
  try {
    await prisma.$queryRaw`SELECT 1`
    return NextResponse.json({ status: 'ok' })
  } catch (error) {
    return NextResponse.json({ status: 'error' }, { status: 500 })
  }
}
```

### Verification
- [ ] Logs appear in console.
- [ ] Health endpoint returns 200 OK.

### Lab Questions
1. Why is logging important in production?
2. What other metrics would you track?

---

## Lab 10: Testing

### Objectives
- Write unit tests mocking the ORM.
- Write integration tests with Testcontainers.

### Preparation
- Lab 9 completed.

### Steps

#### 10.1 Install Test Dependencies
```bash
pnpm add -D vitest @testcontainers/postgresql
```

#### 10.2 Unit Test (Prisma)
`packages/database/src/__tests__/prisma.unit.test.ts`:
```typescript
import { describe, it, expect, vi } from 'vitest'
import { prisma } from '../prisma/client'

vi.mock('../prisma/client', () => ({
  prisma: { user: { create: vi.fn() } },
}))

describe('Prisma unit tests', () => {
  it('should create a user', async () => {
    const mockUser = { id: 1, email: 'test@test.com', name: 'Test' }
    ;(prisma.user.create as any).mockResolvedValue(mockUser)
    const result = await prisma.user.create({ data: { email: 'test@test.com', name: 'Test' } })
    expect(result).toEqual(mockUser)
  })
})
```

#### 10.3 Integration Test with Testcontainers
`packages/database/src/__tests__/integration.test.ts`:
```typescript
import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { PostgreSqlContainer } from '@testcontainers/postgresql'
import { PrismaClient } from '@prisma/client'

describe('Integration tests', () => {
  let container: any
  let prisma: PrismaClient

  beforeAll(async () => {
    container = await new PostgreSqlContainer().start()
    const url = container.getConnectionUri()
    prisma = new PrismaClient({ datasourceUrl: url })
    await prisma.$connect()
    // Run migrations
  })

  afterAll(async () => {
    await prisma.$disconnect()
    await container.stop()
  })

  it('should create and find a user', async () => {
    const user = await prisma.user.create({ data: { email: 'test@test.com', name: 'Test' } })
    const found = await prisma.user.findUnique({ where: { id: user.id } })
    expect(found).toBeDefined()
  })
})
```

### Verification
- [ ] Unit tests pass.
- [ ] Integration tests pass.

### Lab Questions
1. What is the benefit of using Testcontainers?
2. How do you test Drizzle integration?

---

## Lab 11: Deployment

### Objectives
- Containerize the application.
- Deploy to a cloud platform (Vercel).

### Preparation
- Lab 10 completed.

### Steps

#### 11.1 Create Dockerfile
```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY . .
RUN pnpm install
RUN pnpm build

FROM node:20-alpine AS runner
WORKDIR /app
COPY --from=builder /app/apps/nextjs/.next ./.next
COPY --from=builder /app/apps/nextjs/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD ["pnpm", "start"]
```

#### 11.2 Build and Run Docker Image
```bash
docker build -t taskflow-pro .
docker run -p 3000:3000 taskflow-pro
```

#### 11.3 Deploy to Vercel
```bash
pnpm add -g vercel
vercel login
vercel --prod
```

### Verification
- [ ] Docker container runs.
- [ ] Application accessible at `http://localhost:3000`.
- [ ] Vercel deployment live.

### Lab Questions
1. Why use multi‑stage Docker builds?
2. What environment variables need to be set in Vercel?

---

## Lab 12: Capstone – Build It Twice

### Objectives
- Implement the full TaskFlow Pro application using Prisma.
- Re‑implement the same application using Drizzle.

### Preparation
- All previous labs completed.

### Steps

#### 12.1 Prisma Implementation
Build the complete application with:
- Schema with all relations.
- Migrations.
- Services (CRUD, advanced queries).
- Next.js integration (pages, actions, API).
- Authentication (NextAuth.js).
- Testing.
- Deployment.

#### 12.2 Drizzle Implementation
Repeat the entire process using Drizzle.

#### 12.3 Comparison
Create a report comparing:
- Development time.
- Lines of code.
- Query performance.
- Ease of debugging.
- Cold start.

### Verification
- [ ] Both implementations work.
- [ ] Comparison report is complete.

### Lab Questions
1. Which implementation would you choose for production?
2. What was the biggest surprise in the comparison?

---

## Lab Completion Checklist

| Lab | Completed? | Date |
|-----|------------|------|
| 0 – Environment Setup | ☐ | |
| 1 – Project Structure & Prisma | ☐ | |
| 2 – Drizzle Setup | ☐ | |
| 3 – CRUD Operations | ☐ | |
| 4 – Advanced Schema | ☐ | |
| 5 – Advanced Queries | ☐ | |
| 6 – Next.js Integration | ☐ | |
| 7 – Server Actions | ☐ | |
| 8 – Transactions | ☐ | |
| 9 – Observability | ☐ | |
| 10 – Testing | ☐ | |
| 11 – Deployment | ☐ | |
| 12 – Capstone | ☐ | |

---

**[END OF LAB BOOK]**
