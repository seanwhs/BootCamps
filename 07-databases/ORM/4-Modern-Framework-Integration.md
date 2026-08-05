# Drizzle ORM vs. Prisma ORM Masterclass

## Part 4: Modern Framework Integration (Next.js 16, React 19, React Native)

### Introduction to Part 4

In Parts 1–3, we built a robust database layer with both Prisma and Drizzle, complete with schemas, migrations, CRUD, advanced queries, transactions, and performance benchmarks. Now it's time to bring these ORMs into the real world—integrating them into modern full‑stack applications.

This module is the most practical yet. We'll build a complete Next.js 16 application using the App Router, React 19, and server components. We'll leverage React's new features like Server Actions, `useActionState`, `useOptimistic`, and Suspense. We'll also explore how to connect our ORMs to cloud databases and edge runtimes, and we'll even dive into mobile development with React Native and Drizzle SQLite.

By the end of Part 4, you'll have a fully functional TaskFlow Pro frontend that communicates with your database through type‑safe server‑side code, with both ORMs integrated and ready for production.

---

## Part 4, Section 1: Setting Up the Next.js Application

We'll create a Next.js 16 application in our monorepo that consumes our database package.

### Target

- Create `apps/nextjs` with Next.js 16 (canary) and React 19 (canary).
- Configure the app to use the database package via workspace imports.
- Set up environment variables and a singleton database client for both ORMs.

### Implementation

**Step 1: Create the Next.js app**

Navigate to the root and create the app:

```bash
cd ../..  # back to taskflow-pro root
mkdir -p apps/nextjs
cd apps/nextjs

# Initialize with pnpm
pnpm init

# Install dependencies
pnpm add next@canary react@canary react-dom@canary
pnpm add -D typescript @types/node @types/react @types/react-dom
pnpm add @taskflow/database@0.0.1  # reference our local package
```

**Step 2: Set up TypeScript and Next.js**

Create `tsconfig.json`:

```json
// apps/nextjs/tsconfig.json
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "incremental": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "react-jsx",
    "plugins": [
      {
        "name": "next"
      }
    ],
    "paths": {
      "@/*": ["./*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

Create `next.config.ts`:

```typescript
// apps/nextjs/next.config.ts
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  experimental: {
    // Enable React 19 features
    reactCompiler: true,
  },
  // Transpile packages from the monorepo
  transpilePackages: ['@taskflow/database'],
  // Environment variables exposed to the browser
  env: {
    NEXT_PUBLIC_APP_NAME: 'TaskFlow Pro',
  },
}

export default nextConfig
```

**Step 3: Create the app directory structure**

```bash
mkdir -p app
mkdir -p app/api
mkdir -p app/(auth)/login
mkdir -p app/(auth)/register
mkdir -p app/(dashboard)/dashboard
mkdir -p app/(dashboard)/projects
mkdir -p app/(dashboard)/tasks
mkdir -p components
mkdir -p lib
mkdir -p hooks
```

**Step 4: Create environment variables**

Create `.env.local`:

```env
# apps/nextjs/.env.local
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/taskflow?schema=public"

# We'll also use these for auth later
NEXTAUTH_SECRET="your-secret-key-change-this"
NEXTAUTH_URL="http://localhost:3000"
```

**Step 5: Create a database client singleton**

We'll reuse the clients from our database package, but we need to ensure we don't create multiple instances in development (hot reload). The database package already handles this for Prisma, but we should also handle Drizzle's pool.

We'll create a wrapper in the Next.js app that imports and re‑exports the clients from the package, ensuring they are singletons.

Create `lib/db.ts`:

```typescript
// apps/nextjs/lib/db.ts
// Re-export the database clients from the package
export { prisma } from '@taskflow/database/prisma/client'
export { db } from '@taskflow/database/drizzle/client'
// Also export the schema and types for convenience
export * from '@taskflow/database/drizzle/schema'
```

Since the package exports both clients, we can import them directly. However, we need to ensure the package is built or we use TypeScript paths. The `tsconfig`'s `paths` already maps `@taskflow/database` to `../../packages/database/src` so we can import directly.

**Step 6: Create a root layout**

`app/layout.tsx`:

```tsx
// apps/nextjs/app/layout.tsx
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'TaskFlow Pro',
  description: 'Project management with Prisma and Drizzle',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        {children}
      </body>
    </html>
  )
}
```

We'll need a global CSS file, but we can keep it minimal for now.

**Step 7: Add a simple page to test the database connection**

Create `app/page.tsx`:

```tsx
// apps/nextjs/app/page.tsx
import { prisma } from '@taskflow/database/prisma/client'

export default async function HomePage() {
  // Simple query to verify connection
  const orgCount = await prisma.organization.count()
  return (
    <main className="p-8">
      <h1 className="text-2xl font-bold">TaskFlow Pro</h1>
      <p>Database connected. Organizations: {orgCount}</p>
    </main>
  )
}
```

Now, run the development server:

```bash
pnpm dev
# or from the root: pnpm --filter nextjs dev
```

Visit `http://localhost:3000`. You should see the page with the organization count. If it works, your Next.js app can talk to the database using Prisma.

We can do the same for Drizzle, but we'll build more comprehensive examples later.

---

## Part 4, Section 2: Next.js 16 App Router – Server Components and Route Handlers

Now we'll build out the application with real features, using both ORMs.

### Concept

Next.js 16 introduces the App Router with Server Components by default. This means we can fetch data directly in our components without an API layer, reducing network overhead. We can also use Route Handlers (API routes) for external clients or for actions that need to be called from client components.

We'll demonstrate both patterns.

### Implementation

#### 2.1 Server Component: Project List

Create `app/(dashboard)/projects/page.tsx`:

```tsx
// apps/nextjs/app/(dashboard)/projects/page.tsx
import { prisma } from '@taskflow/database/prisma/client'
import Link from 'next/link'

// This is a Server Component by default
export default async function ProjectsPage() {
  // Fetch projects with their task counts
  const projects = await prisma.project.findMany({
    include: {
      _count: {
        select: { tasks: true },
      },
      creator: {
        select: { fullName: true },
      },
    },
    orderBy: { createdAt: 'desc' },
  })

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">Projects</h1>
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {projects.map((project) => (
          <div key={project.id} className="border rounded-lg p-4 shadow-sm">
            <h2 className="text-xl font-semibold">{project.name}</h2>
            <p className="text-gray-600">{project.description || 'No description'}</p>
            <div className="mt-2 text-sm text-gray-500">
              <span>Tasks: {project._count.tasks}</span>
              <span className="ml-4">Created by: {project.creator.fullName}</span>
            </div>
            <Link
              href={`/projects/${project.id}`}
              className="mt-3 inline-block text-blue-600 hover:underline"
            >
              View Details →
            </Link>
          </div>
        ))}
      </div>
    </div>
  )
}
```

Note: We haven't created the `/projects/[id]` page yet, but we'll get there.

#### 2.2 Route Handler: Create a Project (API endpoint)

Create `app/api/projects/route.ts` for POST requests:

```ts
// apps/nextjs/app/api/projects/route.ts
import { prisma } from '@taskflow/database/prisma/client'
import { NextRequest, NextResponse } from 'next/server'
import { z } from 'zod'

// Validation schema
const createProjectSchema = z.object({
  organizationId: z.string().uuid(),
  name: z.string().min(1).max(255),
  description: z.string().optional(),
  createdBy: z.string().uuid(),
})

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const validated = createProjectSchema.parse(body)

    const project = await prisma.project.create({
      data: {
        organizationId: validated.organizationId,
        name: validated.name,
        description: validated.description,
        createdBy: validated.createdBy,
      },
    })

    return NextResponse.json(project, { status: 201 })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json({ error: error.errors }, { status: 400 })
    }
    console.error('Error creating project:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

export async function GET(request: NextRequest) {
  const searchParams = request.nextUrl.searchParams
  const orgId = searchParams.get('organizationId')
  if (!orgId) {
    return NextResponse.json({ error: 'organizationId required' }, { status: 400 })
  }
  const projects = await prisma.project.findMany({
    where: { organizationId: orgId },
    include: { creator: { select: { fullName: true } } },
  })
  return NextResponse.json(projects)
}
```

#### 2.3 Server Action: Create a Project (form submission)

Next.js 16 supports Server Actions for mutations. We'll create an action that creates a project.

Create `app/actions/projects.ts`:

```ts
// apps/nextjs/app/actions/projects.ts
'use server'

import { prisma } from '@taskflow/database/prisma/client'
import { revalidatePath } from 'next/cache'
import { z } from 'zod'
import { redirect } from 'next/navigation'

const createProjectSchema = z.object({
  organizationId: z.string().uuid(),
  name: z.string().min(1),
  description: z.string().optional(),
  createdBy: z.string().uuid(),
})

export async function createProject(formData: FormData) {
  // Parse form data
  const rawData = {
    organizationId: formData.get('organizationId') as string,
    name: formData.get('name') as string,
    description: formData.get('description') as string || undefined,
    createdBy: formData.get('createdBy') as string,
  }

  try {
    const validated = createProjectSchema.parse(rawData)
    await prisma.project.create({
      data: validated,
    })
    // Revalidate the projects list
    revalidatePath('/projects')
    // Redirect to the projects page
    redirect('/projects')
  } catch (error) {
    if (error instanceof z.ZodError) {
      // Return validation errors to the client
      return { errors: error.errors }
    }
    console.error('Server action error:', error)
    return { errors: [{ message: 'Failed to create project' }] }
  }
}
```

We'll create a client component that uses this action with `useActionState` in the next section.

---

## Part 4, Section 3: React 19 Integration – Server Actions, useActionState, useOptimistic

React 19 introduces Server Actions as a first‑class feature, along with hooks like `useActionState` (formerly `useFormState`) and `useOptimistic` for optimistic UI updates.

We'll build a form that creates a project using the Server Action we just defined, with optimistic UI for a smoother experience.

### Implementation

#### 3.1 Client Component with useActionState

Create `components/NewProjectForm.tsx`:

```tsx
// apps/nextjs/components/NewProjectForm.tsx
'use client'

import { useActionState } from 'react'
import { createProject } from '@/app/actions/projects'

// Define the initial state shape
type InitialState = {
  errors?: Array<{ path?: string[]; message: string }>
  success?: boolean
} | null

const initialState: InitialState = null

export function NewProjectForm({
  organizationId,
  userId,
}: {
  organizationId: string
  userId: string
}) {
  // useActionState binds the action and returns state, form action, and pending status
  const [state, formAction, isPending] = useActionState<InitialState, FormData>(
    async (prevState, formData) => {
      // We'll call the server action directly
      const result = await createProject(formData)
      // If result has errors, return them; else, we'll redirect
      if (result && 'errors' in result) {
        return { errors: result.errors }
      }
      // On success, we don't need to return anything because we redirect.
      // But the action might return undefined; we handle that.
      return { success: true }
    },
    initialState
  )

  return (
    <form action={formAction} className="space-y-4 max-w-md">
      {/* Hidden fields */}
      <input type="hidden" name="organizationId" value={organizationId} />
      <input type="hidden" name="createdBy" value={userId} />

      <div>
        <label htmlFor="name" className="block text-sm font-medium">
          Project Name
        </label>
        <input
          type="text"
          id="name"
          name="name"
          required
          className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
          disabled={isPending}
        />
      </div>
      <div>
        <label htmlFor="description" className="block text-sm font-medium">
          Description (optional)
        </label>
        <textarea
          id="description"
          name="description"
          rows={3}
          className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm p-2"
          disabled={isPending}
        />
      </div>
      <button
        type="submit"
        disabled={isPending}
        className="bg-blue-600 text-white px-4 py-2 rounded-md hover:bg-blue-700 disabled:opacity-50"
      >
        {isPending ? 'Creating...' : 'Create Project'}
      </button>
      {state?.errors && (
        <div className="text-red-600 text-sm">
          {state.errors.map((err, idx) => (
            <p key={idx}>{err.message}</p>
          ))}
        </div>
      )}
    </form>
  )
}
```

Now we can include this form in a page.

#### 3.2 Optimistic Updates with useOptimistic

For tasks, we can use `useOptimistic` to immediately reflect changes before the server confirms them.

Create `components/TaskList.tsx`:

```tsx
// apps/nextjs/components/TaskList.tsx
'use client'

import { useOptimistic, useTransition } from 'react'
import { updateTaskStatus } from '@/app/actions/tasks'

type Task = {
  id: string
  title: string
  status: 'backlog' | 'todo' | 'in_progress' | 'in_review' | 'done'
}

export function TaskList({ initialTasks }: { initialTasks: Task[] }) {
  // Optimistic state for tasks
  const [optimisticTasks, addOptimisticTask] = useOptimistic<Task[], Task>(
    initialTasks,
    (currentTasks, updatedTask) => {
      // Replace the task with the same id
      return currentTasks.map(task =>
        task.id === updatedTask.id ? updatedTask : task
      )
    }
  )

  const [isPending, startTransition] = useTransition()

  const handleStatusChange = (taskId: string, newStatus: Task['status']) => {
    // Find the task to optimistically update
    const taskToUpdate = optimisticTasks.find(t => t.id === taskId)
    if (!taskToUpdate) return

    const updatedTask = { ...taskToUpdate, status: newStatus }

    // Start a transition for the optimistic update
    startTransition(async () => {
      // Optimistically update the UI
      addOptimisticTask(updatedTask)

      // Actually call the server action
      await updateTaskStatus(taskId, newStatus)
      // The server action will revalidate, but our optimistic update is already applied
    })
  }

  return (
    <div>
      {optimisticTasks.map(task => (
        <div key={task.id} className="flex items-center justify-between border-b py-2">
          <span className="text-lg">{task.title}</span>
          <select
            value={task.status}
            onChange={(e) => handleStatusChange(task.id, e.target.value as any)}
            className="border rounded p-1"
            disabled={isPending}
          >
            <option value="backlog">Backlog</option>
            <option value="todo">Todo</option>
            <option value="in_progress">In Progress</option>
            <option value="in_review">In Review</option>
            <option value="done">Done</option>
          </select>
        </div>
      ))}
    </div>
  )
}
```

We'll need the `updateTaskStatus` action, which we'll create next.

Create `app/actions/tasks.ts`:

```ts
// apps/nextjs/app/actions/tasks.ts
'use server'

import { prisma } from '@taskflow/database/prisma/client'
import { revalidatePath } from 'next/cache'

export async function updateTaskStatus(taskId: string, status: string) {
  await prisma.task.update({
    where: { id: taskId },
    data: { status: status as any }, // cast to enum type
  })
  revalidatePath(`/tasks`) // adjust as needed
}
```

Now we can use `TaskList` in a Server Component that fetches initial tasks.

---

## Part 4, Section 4: Connection Management and Serverless Optimization

When using Next.js with serverless deployments (Vercel, etc.), database connection management is critical. We must ensure we don't exhaust database connections and that cold starts are minimized.

### Prisma Connection Management

Prisma's client maintains a connection pool. In serverless environments, we need to ensure that the client is reused across invocations. The singleton pattern we used earlier (globalThis) helps.

But Prisma also offers **Prisma Accelerate** (a connection pooler) that can drastically reduce cold starts. We'll discuss that in Part 5.

### Drizzle Connection Management

Drizzle uses the underlying driver (e.g., `pg` pool). We need to manage the pool properly. We can create a singleton pool similar to the Prisma approach.

We already have a singleton pool in `packages/database/src/drizzle/client.ts`. However, in serverless environments, we might want to use a connection pooler like PgBouncer or use a serverless-friendly driver like `@neondatabase/serverless` for Neon.

Drizzle supports HTTP drivers via `drizzle-orm/neon-http`, `drizzle-orm/planetscale-serverless`, etc. We'll show an example with Neon.

### Edge Runtime Compatibility

For Vercel Edge or Cloudflare Workers, we need to use a database that supports HTTP connections (e.g., Neon, PlanetScale, Turso).

Drizzle's HTTP drivers are lightweight and work on the edge. Prisma can also work on the edge with Prisma Accelerate (which proxies queries).

Let's implement a Drizzle client for Neon using HTTP.

**Update `packages/database/src/drizzle/client.ts` to support both Node and Edge:**

```typescript
// packages/database/src/drizzle/client.ts (updated)
import { drizzle } from 'drizzle-orm/neon-http'
import { neon } from '@neondatabase/serverless'
import { schema } from './schema'
import { env } from '../env'

// For Node, we use the pg pool; for edge, we use HTTP.
// We'll determine based on environment.

let db: any

if (process.env.NODE_ENV === 'development' || process.env.USE_PG_POOL) {
  // Node environment
  import('drizzle-orm/node-postgres').then(({ drizzle }) => {
    import('pg').then(({ Pool }) => {
      const pool = new Pool({ connectionString: env.DATABASE_URL })
      db = drizzle(pool, { schema })
    })
  })
} else {
  // Edge environment: use Neon HTTP
  const sql = neon(env.DATABASE_URL)
  db = drizzle(sql, { schema })
}

export { db }
```

However, this dynamic import might complicate things. For simplicity, we'll create separate clients for different environments in the Next.js app itself.

We'll stick with the `pg` pool for development and production in Node.

---

## Part 4, Section 5: React Native Integration

React Native apps run on mobile devices, and they typically do not talk directly to a PostgreSQL database. Instead, they use an API layer (REST or GraphQL) to communicate with a backend server. However, for offline‑first applications, we can use a local SQLite database with Drizzle.

Drizzle has excellent SQLite support, making it a perfect fit for React Native with Expo.

### Concept

We'll create a separate React Native app (using Expo) that uses Drizzle with SQLite for local data storage. We'll also demonstrate synchronization strategies (e.g., using a remote API to sync data).

### Implementation

**Step 1: Create a React Native app**

```bash
cd ../..
npx create-expo-app apps/mobile --template
cd apps/mobile
```

We'll use Expo's SQLite module.

**Step 2: Install dependencies**

```bash
pnpm add drizzle-orm expo-sqlite
pnpm add -D drizzle-kit
```

**Step 3: Define a Drizzle schema for SQLite**

We can reuse the same schema but with SQLite types. Drizzle supports SQLite via `drizzle-orm/sqlite-core`.

Create `packages/database/src/drizzle/schema-sqlite.ts` with similar table definitions but using `sqliteTable` instead of `pgTable`. For brevity, we'll show a minimal version.

**Step 4: Set up the SQLite client**

In the mobile app, create `lib/db.ts`:

```typescript
// apps/mobile/lib/db.ts
import { drizzle } from 'drizzle-orm/expo-sqlite'
import { openDatabaseSync } from 'expo-sqlite'
import * as schema from '@taskflow/database/drizzle/schema-sqlite'

const expoDb = openDatabaseSync('taskflow.db')
export const db = drizzle(expoDb, { schema })
```

**Step 5: Use Drizzle in React Native components**

You can now use `db` to query and mutate data locally, providing offline capabilities.

Since this part is more advanced, we'll cover the basics and point to resources for synchronization.

---

## Part 4, Section 6: Cloud Database Integration

Our ORMs support various cloud databases:

- **Neon** – serverless PostgreSQL with HTTP API.
- **Turso** – SQLite-based edge database.
- **PlanetScale** – Vitess-based MySQL.
- **Supabase** – PostgreSQL with a generous free tier.
- **AWS RDS** – traditional managed PostgreSQL.

We'll show how to connect to Neon and Turso with Drizzle, and to Neon with Prisma.

### Prisma with Neon

Neon uses a standard PostgreSQL connection string, so you can just set `DATABASE_URL` to your Neon connection string. For serverless, use Prisma Accelerate or the Data Proxy.

### Drizzle with Neon

Use the HTTP driver:

```typescript
import { drizzle } from 'drizzle-orm/neon-http'
import { neon } from '@neondatabase/serverless'

const sql = neon(process.env.DATABASE_URL!)
export const db = drizzle(sql, { schema })
```

### Drizzle with Turso (SQLite)

```typescript
import { drizzle } from 'drizzle-orm/libsql'
import { createClient } from '@libsql/client'

const client = createClient({
  url: process.env.TURSO_URL!,
  authToken: process.env.TURSO_TOKEN!,
})
export const db = drizzle(client, { schema })
```

---

## Part 4, Section 7: Verification

To verify our Next.js integration, we can run the dev server and test the project creation flow.

```bash
# In the root, start the database if not running
docker start taskflow-postgres

# Run Next.js
pnpm --filter nextjs dev
```

Then visit `http://localhost:3000/projects` and use the form (we'll add it to a page). Ensure that projects are created and the list updates.

We can also test the API endpoint with curl:

```bash
curl -X POST http://localhost:3000/api/projects \
  -H "Content-Type: application/json" \
  -d '{"organizationId":"<your-org-id>","name":"Test Project","createdBy":"<your-user-id>"}'
```

You should get a 201 response with the project.

---

## Part 4, Section 8: Reference – React 19 and Next.js 16 Features

### Server Actions

Server Actions are functions that run on the server but can be called from client components. They are defined with `'use server'` at the top of the file or function. They can accept `FormData` or plain objects.

Benefits:
- Type‑safe.
- Can revalidate cache with `revalidatePath`.
- Can redirect.

### useActionState

`useActionState` is a hook that wraps a Server Action and returns state, a form action, and pending status. It's ideal for forms.

### useOptimistic

`useOptimistic` allows you to update the UI optimistically while a server action is pending. It takes the current state and an update function.

### Suspense and Streaming

Next.js 16 supports Suspense for data fetching in Server Components. You can wrap components in `<Suspense>` to show fallback while data loads. This can be combined with `use` hook in client components.

We'll cover this in the next part (capstone).

---

## Progress Log

| Phase | Status | Notes |
|-------|--------|-------|
| Part 0: Introduction | ✅ COMPLETE | |
| Part 1: ORM Philosophy & Setup | ✅ COMPLETE | |
| Part 2: Schema Design, Modeling, and Migrations | ✅ COMPLETE | |
| Part 3: Querying, Performance, and Type Safety | ✅ COMPLETE | |
| Part 4: Framework Integration | ✅ COMPLETE | Next.js, React, React Native, cloud DBs. |
| Part 5: Production Readiness | ⏳ PENDING | Next: Deployment, testing, monitoring, scaling. |
| Capstone Project | ⏳ PENDING | |
