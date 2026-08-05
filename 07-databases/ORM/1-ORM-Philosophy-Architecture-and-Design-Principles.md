# Drizzle ORM vs. Prisma ORM Masterclass

## Part 1: ORM Philosophy, Architecture, and Design Principles

### Introduction to Part 1

Welcome to the first technical module of our masterclass. In Part 0, we laid the groundwork—understood what we're building, established our technology stack, and set up our development environment. Now, we're diving into the deep end.

In this module, we'll explore the philosophical foundations of Prisma and Drizzle—why they were built differently, how their architectural choices influence everything from query performance to developer experience, and most importantly, you'll set up both ORMs in a real project, define a database schema, and run your first queries.

By the end of this module, you will:
- Understand the evolution of ORMs in the TypeScript ecosystem.
- Grasp the core philosophies: schema-first (Prisma) vs. code-first (Drizzle).
- Set up a production-grade project structure.
- Configure both Prisma and Drizzle in the same codebase.
- Define a shared database schema using both approaches.
- Run migrations and write your first type-safe queries.

Let's begin.

---

## Part 1, Section 1: The Evolution of Modern TypeScript ORMs

Before we write a single line of code, it's essential to understand *why* we have two such different tools in the same ecosystem.

### The Old Guard: Traditional ORMs

Traditional ORMs like Sequelize, TypeORM, and Objection.js have served the JavaScript community for years. They typically follow the **Active Record** or **Data Mapper** patterns, mapping classes to database tables. They work, but they come with challenges:

- **Type Safety:** Many older ORMs lacked strong TypeScript support. Even with decorators and type definitions, the query builder often returns `any` or requires manual casting.
- **Performance:** Heavy runtime reflection and complex object mapping can introduce overhead.
- **Complexity:** As applications grow, the ORM's abstractions become leaky—you often need to drop to raw SQL for complex queries.
- **Migration Management:** Hand-written migrations or auto-sync features can be error-prone in production.

### The Rise of TypeScript-Native Solutions

As TypeScript gained mainstream adoption, developers demanded tools that leverage the type system for compile-time correctness. Two distinct approaches emerged:

1. **Schema-First (Prisma):** Define your schema in a dedicated DSL, then generate a type-safe client.
2. **Code-First (Drizzle):** Define your schema in TypeScript itself, using the type system as the single source of truth.

### Why Two Approaches?

The debate isn't about which is "better"—it's about tradeoffs. Schema-first tools like Prisma offer an unparalleled developer experience with a unified workflow, but they introduce a layer of abstraction and runtime overhead. Code-first tools like Drizzle give you full control and transparency, but require a deeper understanding of SQL and TypeScript's type system.

Understanding these tradeoffs is crucial for making an informed decision.

---

## Part 1, Section 2: Prisma ORM - Schema-First Development

### The Philosophy

Prisma's philosophy is **"Declare once, generate everywhere."** You define your database schema in a single `schema.prisma` file using Prisma's own Domain-Specific Language (DSL). From that declaration, Prisma generates:

- A type-safe Prisma Client for querying.
- SQL migration files to evolve your database.
- TypeScript types for your application.

This declarative approach ensures that your database schema, migration history, and application types are always in sync.

### Architecture Overview

Prisma consists of several components:

```
┌─────────────────────────────────────────────────────────┐
│                     Application Code                     │
│                  (using Prisma Client)                   │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                   Prisma Client                         │
│   (TypeScript library with generated methods)           │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                  Query Engine                           │
│   (Rust binary - handles query parsing, optimization,   │
│    and execution)                                       │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                    Database                             │
└─────────────────────────────────────────────────────────┘
```

Key points:
- The **Query Engine** is a separate binary written in Rust. It communicates with the Prisma Client via a protocol.
- This separation means Prisma Client is lightweight, but the Query Engine must be available at runtime.
- The Query Engine is responsible for generating SQL, parameterization, and result mapping.
- Prisma's type generation happens at build time, providing full type safety in your application.

### Developer Workflow

1. **Define schema** in `schema.prisma`.
2. **Run `prisma generate`** to generate the client.
3. **Run `prisma migrate dev`** to create and apply migrations.
4. **Use the client** in your application.

### When to Choose Prisma

- **Rapid prototyping:** The declarative schema and automatic migrations accelerate development.
- **CRUD-heavy applications:** Prisma's intuitive API for create, read, update, delete shines.
- **Teams with diverse skill levels:** The generated client provides clear, discoverable methods.
- **Multi-database projects:** Prisma supports PostgreSQL, MySQL, SQLite, SQL Server, and MongoDB with the same API.
- **Enterprise systems:** Prisma's commercial offerings (Accelerate, Data Proxy) provide additional capabilities.

---

## Part 1, Section 3: Drizzle ORM - Code-First SQL

### The Philosophy

Drizzle's philosophy is **"SQL in TypeScript, without compromises."** Instead of a separate DSL, you define your database schema using TypeScript functions and objects. The schema is the source of truth; there's no code generation step (though you can optionally generate types).

Drizzle embraces SQL fully—you write queries that look like SQL, but they're type-safe and composable. It's a **SQL query builder** with a small runtime footprint.

### Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                     Application Code                     │
│                 (using Drizzle API)                      │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                   Drizzle Core                          │
│   (TypeScript library - query builder, schema           │
│    definition, connection management)                   │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│              Database Driver (e.g., pg, mysql2)         │
└─────────────────────┬───────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────┐
│                    Database                             │
└─────────────────────────────────────────────────────────┘
```

Key points:
- Drizzle is **pure TypeScript**—no separate runtime engine.
- It uses the underlying database driver (e.g., `pg` for PostgreSQL) for connection and execution.
- Queries are built using TypeScript functions that map directly to SQL syntax.
- Type safety is achieved through TypeScript's type system, not code generation (though you can generate types for better performance).

### Developer Workflow

1. **Define schema** in TypeScript files using Drizzle's table definitions.
2. **Run `drizzle-kit generate`** to generate SQL migration files.
3. **Run `drizzle-kit migrate`** to apply migrations.
4. **Use the `drizzle` client** in your application.

### When to Choose Drizzle

- **Performance-critical applications:** The lightweight runtime and direct SQL translation minimize overhead.
- **Complex SQL queries:** Drizzle gives you full SQL power with type safety.
- **Serverless / Edge environments:** Smaller bundle size and no external engine make it ideal for Vercel Edge, Cloudflare Workers, etc.
- **Developers who love SQL:** If you're comfortable with SQL, Drizzle feels natural.
- **Local-first / mobile:** Drizzle supports SQLite, making it a great fit for React Native with Expo.

---

## Part 1, Section 4: Architecture Comparison

Let's compare the two side by side.

| Aspect | Prisma | Drizzle |
|--------|--------|---------|
| **Schema Definition** | `schema.prisma` (DSL) | TypeScript functions |
| **Code Generation** | Yes (`prisma generate`) | Optional (`drizzle-typegen`) |
| **Runtime** | Requires Rust Query Engine binary | Pure TypeScript, no external binary |
| **Bundle Size** | ~6 MB (Query Engine) | ~100 KB (core) |
| **Cold Start** | Slower due to Query Engine startup | Fast (just loads JavaScript) |
| **Edge Support** | Limited (except with Data Proxy) | Excellent (HTTP drivers available) |
| **Type Safety** | Generated types, fully inferred | Inferred from TypeScript definitions |
| **SQL Transparency** | Black box (you don't see SQL unless you log) | Full transparency (you write SQL-like queries) |
| **Migration Tool** | `prisma migrate` (built-in) | `drizzle-kit` (separate CLI) |
| **Database Support** | PostgreSQL, MySQL, SQLite, SQL Server, MongoDB (experimental) | PostgreSQL, MySQL, SQLite, Turso, Neon, PlanetScale, Cloudflare D1 |
| **Learning Curve** | Low to moderate | Moderate to high (requires SQL knowledge) |

### Cold Start and Bundle Size: A Deeper Dive

**Prisma's Query Engine** is a compiled Rust binary. This binary must be loaded into memory when the application starts. In serverless environments (AWS Lambda, Vercel Functions), this adds significant cold start latency—often 200-400ms extra. Prisma has addressed this with Prisma Accelerate (a connection pooler) and the Data Proxy, which offloads the Query Engine to a remote service, reducing cold start.

**Drizzle** has no such external binary. It's just JavaScript/TypeScript, so startup is nearly instantaneous. This makes Drizzle ideal for edge functions where cold starts are a critical concern.

### Type Safety: Generation vs. Inference

Prisma generates TypeScript types from your `schema.prisma` file. These types are explicit and can be inspected in the `node_modules/.prisma` directory. They are fully static and provide excellent autocompletion.

Drizzle infers types from your TypeScript schema definitions. This works seamlessly because you're writing in TypeScript, and the type system handles everything. However, complex type inference can occasionally slow down your TypeScript language server in large projects (though Drizzle has optimizations).

---

## Part 1, Section 5: Decision Framework

Choosing between Prisma and Drizzle isn't a one-size-fits-all decision. Here's a practical framework:

### Choose Prisma if:

- You're building a **CRUD-heavy application** (e.g., an admin dashboard, an internal tool).
- You have a **team with mixed skill levels** and want a gentle learning curve.
- You need **multi-database support** with a consistent API.
- You're willing to **pay for Prisma Accelerate** if you need serverless optimization.
- You prefer a **declarative schema** that's separate from your business logic.

### Choose Drizzle if:

- You're building a **performance-critical application** (e.g., analytics, real-time features).
- You want to **minimize cold start latency** in serverless environments.
- You're working on the **edge** (Cloudflare Workers, Vercel Edge).
- You're building a **mobile app with React Native** (Drizzle SQLite support).
- You **love writing SQL** and want type safety without abstraction.
- You want **maximum control** over the generated SQL.

### Hybrid Approach

It's worth noting that you can use both in the same project (e.g., Drizzle for query-heavy analytics, Prisma for admin CRUD). However, this increases complexity, and we won't cover that in this series.

---

## Part 1, Section 6: Hands-On Setup - Building the Foundation

Now that you understand the philosophies, let's get our hands dirty. We'll set up a monorepo with both ORMs, define a simple user-organization schema, run migrations, and write queries.

### Target

We're going to:
1. Set up a TypeScript monorepo with pnpm and Turborepo.
2. Create a database package that houses both Prisma and Drizzle schemas.
3. Define an identical schema in both ORMs: `users`, `organizations`, and `organization_members`.
4. Run migrations for both.
5. Write a seed script to populate data.
6. Write a few queries to fetch data with relations.

### Concept: Monorepo and Package Structure

We'll use a monorepo approach so that the database layer is a separate package that can be imported by other applications (Next.js, mobile, etc.). This promotes separation of concerns and reusability.

We'll structure the database package as follows:
```
packages/database/
├── src/
│   ├── prisma/
│   │   ├── schema.prisma    # Prisma schema
│   │   └── client.ts        # Export singleton PrismaClient
│   ├── drizzle/
│   │   ├── schema/          # Drizzle table definitions
│   │   │   ├── users.ts
│   │   │   ├── organizations.ts
│   │   │   ├── organizationMembers.ts
│   │   │   └── index.ts     # Export all tables
│   │   ├── migrations/      # Drizzle migration files (generated)
│   │   ├── client.ts        # Export drizzle instance
│   │   └── migrate.ts       # Migration runner
│   └── index.ts             # Export both ORMs
├── package.json
├── tsconfig.json
├── drizzle.config.ts        # Drizzle Kit config
└── .env
```

### Step-by-Step Implementation

#### Step 1: Set Up the Monorepo

We'll use pnpm workspaces and Turborepo for build orchestration.

**1.1 Create the root directory and initialize**

```bash
mkdir taskflow-pro
cd taskflow-pro

# Initialize root package.json with workspaces
cat > package.json << 'EOF'
{
  "name": "taskflow-pro",
  "private": true,
  "workspaces": [
    "packages/*",
    "apps/*"
  ],
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "lint": "turbo lint",
    "test": "turbo test",
    "db:generate": "pnpm -C packages/database generate",
    "db:migrate": "pnpm -C packages/database migrate",
    "db:seed": "pnpm -C packages/database seed"
  },
  "devDependencies": {
    "turbo": "^2.0.0"
  },
  "packageManager": "pnpm@9.0.0",
  "engines": {
    "node": ">=20"
  }
}
EOF

# Create pnpm-workspace.yaml
cat > pnpm-workspace.yaml << 'EOF'
packages:
  - "apps/*"
  - "packages/*"
EOF

# Create a root tsconfig
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "composite": true,
    "incremental": true,
    "noEmit": false,
    "outDir": "./dist",
    "baseUrl": ".",
    "paths": {
      "@taskflow/database": ["./packages/database/src"],
      "@taskflow/types": ["./packages/types/src"]
    }
  },
  "exclude": ["node_modules", "dist", "build"]
}
EOF

# Install dependencies
pnpm install
```

**1.2 Create the database package**

```bash
mkdir -p packages/database/src/{prisma,drizzle/schema}
cd packages/database

# Initialize package.json
cat > package.json << 'EOF'
{
  "name": "@taskflow/database",
  "version": "0.0.1",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "generate": "pnpm prisma:generate && pnpm drizzle:generate",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate deploy",
    "drizzle:generate": "drizzle-kit generate:pg",
    "drizzle:migrate": "tsx src/drizzle/migrate.ts",
    "seed": "tsx src/seed.ts"
  },
  "dependencies": {
    "@prisma/client": "^5.16.0",
    "drizzle-orm": "^0.32.0",
    "pg": "^8.12.0"
  },
  "devDependencies": {
    "@types/pg": "^8.11.0",
    "prisma": "^5.16.0",
    "drizzle-kit": "^0.24.0",
    "tsx": "^4.16.0",
    "typescript": "^5.5.0"
  }
}
EOF

# Create .env for database URL
cat > .env << 'EOF'
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/taskflow?schema=public"
EOF

# Create tsconfig.json for the package
cat > tsconfig.json << 'EOF'
{
  "extends": "../../tsconfig.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"]
}
EOF
```

#### Step 2: Define the Schema in Prisma

**2.1 Create the Prisma schema file**

```bash
# Create prisma directory and schema
mkdir -p src/prisma
cat > src/prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
  // Add preview features for improved type safety
  previewFeatures = ["clientExtensions"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// Define enums
enum MemberRole {
  owner
  admin
  member
  viewer
}

// Core tables
model User {
  id                   String                @id @default(uuid()) @db.Uuid
  email                String                @unique
  passwordHash         String                @map("password_hash") @db.Text
  fullName             String                @map("full_name") @db.Text
  avatarUrl            String?               @map("avatar_url") @db.Text
  createdAt            DateTime              @default(now()) @map("created_at")
  updatedAt            DateTime              @updatedAt @map("updated_at")

  // Relations
  organizationMembers  OrganizationMember[]
  createdProjects      Project[]             @relation("ProjectCreatedBy")
  createdTasks         Task[]                @relation("TaskCreatedBy")
  assignedTasks        Task[]                @relation("TaskAssignedTo")
  comments             Comment[]
  attachments          Attachment[]
  activityLogs         ActivityLog[]

  @@map("users")
}

model Organization {
  id                   String                @id @default(uuid()) @db.Uuid
  name                 String                @db.Text
  slug                 String                @unique @db.Text
  createdAt            DateTime              @default(now()) @map("created_at")
  updatedAt            DateTime              @updatedAt @map("updated_at")

  // Relations
  members              OrganizationMember[]
  projects             Project[]

  @@map("organizations")
}

model OrganizationMember {
  id               String          @id @default(uuid()) @db.Uuid
  organizationId   String          @map("organization_id") @db.Uuid
  userId           String          @map("user_id") @db.Uuid
  role             MemberRole
  joinedAt         DateTime        @default(now()) @map("joined_at")
  updatedAt        DateTime        @updatedAt @map("updated_at")

  // Relations
  organization     Organization    @relation(fields: [organizationId], references: [id], onDelete: Cascade)
  user             User            @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([organizationId, userId])
  @@map("organization_members")
}

// We'll add more models (Project, Task, etc.) in later parts
// For now, these three tables are enough to demonstrate relationships.

EOF
```

**2.2 Create the Prisma client export**

```bash
cat > src/prisma/client.ts << 'EOF'
import { PrismaClient } from '@prisma/client'
import { env } from '../env'

// Define a singleton to prevent multiple instances in development with hot reloading
const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log:
      process.env.NODE_ENV === 'development'
        ? ['query', 'info', 'warn', 'error']
        : ['error'],
  })

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma

export default prisma
EOF
```

**2.3 Create the environment variable validation helper**

We'll create a simple env validation to ensure `DATABASE_URL` is set.

```bash
cat > src/env.ts << 'EOF'
import { z } from 'zod'

const envSchema = z.object({
  DATABASE_URL: z.string().url().min(1),
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
})

export const env = envSchema.parse(process.env)
EOF
```

Wait, we haven't installed zod in the database package. Let's add it:

```bash
pnpm add zod -D
# Note: we'll install later when we run pnpm install at root
```

We'll hold off and install dependencies later.

#### Step 3: Define the Schema in Drizzle

**3.1 Create the Drizzle table definitions**

First, define the `users` table:

```bash
cat > src/drizzle/schema/users.ts << 'EOF'
import { pgTable, uuid, text, timestamp, unique } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'

// Users table definition
export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: text('email').notNull().unique(),
  passwordHash: text('password_hash').notNull(),
  fullName: text('full_name').notNull(),
  avatarUrl: text('avatar_url'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

// Relations for users
export const usersRelations = relations(users, ({ many }) => ({
  organizationMembers: many(organizationMembers),
  // We'll add more relations later
}))

// We'll need to import organizationMembers later, so we'll split relations.
// We'll define all relations in a separate file after all tables are defined.
// For now, we'll keep them separate.
EOF
```

Now `organizations` table:

```bash
cat > src/drizzle/schema/organizations.ts << 'EOF'
import { pgTable, uuid, text, timestamp } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'

export const organizations = pgTable('organizations', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: text('name').notNull(),
  slug: text('slug').notNull().unique(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

export const organizationsRelations = relations(organizations, ({ many }) => ({
  members: many(organizationMembers),
}))
EOF
```

Now `organization_members` table with enums.

Drizzle supports enums via `pgEnum`. Let's create an enum first.

```bash
cat > src/drizzle/schema/enums.ts << 'EOF'
import { pgEnum } from 'drizzle-orm/pg-core'

export const memberRoleEnum = pgEnum('member_role', ['owner', 'admin', 'member', 'viewer'])
EOF
```

Now `organizationMembers` table:

```bash
cat > src/drizzle/schema/organizationMembers.ts << 'EOF'
import { pgTable, uuid, timestamp, unique } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'
import { users } from './users'
import { organizations } from './organizations'
import { memberRoleEnum } from './enums'

export const organizationMembers = pgTable('organization_members', {
  id: uuid('id').primaryKey().defaultRandom(),
  organizationId: uuid('organization_id').notNull().references(() => organizations.id, { onDelete: 'cascade' }),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  role: memberRoleEnum('role').notNull().default('member'),
  joinedAt: timestamp('joined_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
}, (table) => ({
  // Composite unique constraint
  uniqueOrgUser: unique().on(table.organizationId, table.userId),
}))

export const organizationMembersRelations = relations(organizationMembers, ({ one }) => ({
  organization: one(organizations, {
    fields: [organizationMembers.organizationId],
    references: [organizations.id],
  }),
  user: one(users, {
    fields: [organizationMembers.userId],
    references: [users.id],
  }),
}))
EOF
```

Now, we need a central index that exports all schemas and relations. Drizzle requires all tables to be in the same schema object. We'll create a combined schema.

```bash
cat > src/drizzle/schema/index.ts << 'EOF'
// Export all tables
export * from './enums'
export * from './users'
export * from './organizations'
export * from './organizationMembers'

// Now define relations using the imported tables and relations
import { relations } from 'drizzle-orm'
import { users, usersRelations } from './users'
import { organizations, organizationsRelations } from './organizations'
import { organizationMembers, organizationMembersRelations } from './organizationMembers'

// Combine all relations
export const schema = {
  users,
  organizations,
  organizationMembers,
}

// Also export relations if needed (for advanced queries)
export const relationsMap = {
  users: usersRelations,
  organizations: organizationsRelations,
  organizationMembers: organizationMembersRelations,
}
EOF
```

**3.2 Create the Drizzle client**

```bash
cat > src/drizzle/client.ts << 'EOF'
import { drizzle } from 'drizzle-orm/node-postgres'
import { Pool } from 'pg'
import { schema } from './schema'
import { env } from '../env'

// Create a pool
const pool = new Pool({
  connectionString: env.DATABASE_URL,
  max: 20, // max connections
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
})

// Create drizzle instance
export const db = drizzle(pool, { schema })

// For type inference
export type DB = typeof db

export default db
EOF
```

**3.3 Create migration runner**

Drizzle Kit generates migration files, but we need a script to apply them.

```bash
cat > src/drizzle/migrate.ts << 'EOF'
import { migrate } from 'drizzle-orm/node-postgres/migrator'
import { db, pool } from './client'

async function main() {
  console.log('Running Drizzle migrations...')
  await migrate(db, { migrationsFolder: './src/drizzle/migrations' })
  console.log('Migrations completed!')
  await pool.end()
}

main().catch((err) => {
  console.error('Migration failed:', err)
  process.exit(1)
})
EOF
```

**3.4 Create Drizzle Kit configuration**

We need a `drizzle.config.ts` in the database package root.

```bash
cat > drizzle.config.ts << 'EOF'
import { defineConfig } from 'drizzle-kit'
import dotenv from 'dotenv'
dotenv.config()

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
EOF
```

We need to install dotenv as dev dependency.

#### Step 4: Install Dependencies

Now let's install all dependencies for the database package and the root.

First, go back to the root and run pnpm install:

```bash
cd ../..  # back to root
pnpm install
```

Now navigate back to database package and install dotenv:

```bash
cd packages/database
pnpm add -D dotenv
```

#### Step 5: Set Up Database

We'll use Docker to spin up PostgreSQL.

```bash
# If you have Docker, run:
docker run --name taskflow-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=taskflow \
  -p 5432:5432 \
  -d postgres:16-alpine

# Wait a few seconds for PostgreSQL to start
```

If you don't have Docker, you can use a local PostgreSQL installation, or a cloud database like Neon or Supabase.

#### Step 6: Generate and Run Migrations

**6.1 Prisma Migrations**

```bash
cd packages/database

# Generate Prisma Client
pnpm prisma:generate

# Create initial migration
pnpm prisma migrate dev --name init --schema src/prisma/schema.prisma
# This will apply the migration and generate the client.
```

**6.2 Drizzle Migrations**

For Drizzle, we use Drizzle Kit to generate SQL and then we apply it.

```bash
# Generate migration files
pnpm drizzle:generate

# This will create a folder src/drizzle/migrations with SQL files.
# To apply them, run:
pnpm drizzle:migrate
```

#### Step 7: Seed the Database

We'll create a seed script that inserts some test data using both ORMs (we'll use Prisma for seeding for simplicity, but we could also use Drizzle). We'll create a seed script that uses Prisma.

```bash
cat > src/seed.ts << 'EOF'
import { prisma } from './prisma/client'
import { hash } from 'bcryptjs'

async function main() {
  console.log('🌱 Seeding database...')

  // Create an organization
  const org = await prisma.organization.create({
    data: {
      name: 'Acme Inc.',
      slug: 'acme',
    },
  })

  // Create a user
  const hashedPassword = await hash('password123', 10)
  const user = await prisma.user.create({
    data: {
      email: 'alice@acme.com',
      passwordHash: hashedPassword,
      fullName: 'Alice Johnson',
    },
  })

  // Add user as owner of the organization
  await prisma.organizationMember.create({
    data: {
      organizationId: org.id,
      userId: user.id,
      role: 'owner',
    },
  })

  // Create a second user
  const user2 = await prisma.user.create({
    data: {
      email: 'bob@acme.com',
      passwordHash: hashedPassword,
      fullName: 'Bob Smith',
    },
  })

  await prisma.organizationMember.create({
    data: {
      organizationId: org.id,
      userId: user2.id,
      role: 'member',
    },
  })

  console.log(`✅ Seeded organization "${org.name}" with user "${user.email}" and "${user2.email}"`)
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
EOF
```

We need to install `bcryptjs` and its types:

```bash
pnpm add bcryptjs
pnpm add -D @types/bcryptjs
```

Now run the seed:

```bash
pnpm seed
```

#### Step 8: Write Query Examples

Now we'll create a simple script to demonstrate querying with both ORMs.

**8.1 Prisma Query Example**

Create a file `src/prisma/queries.ts`:

```bash
cat > src/prisma/queries.ts << 'EOF'
import { prisma } from './client'

export async function getOrganizationWithMembers(orgSlug: string) {
  const org = await prisma.organization.findUnique({
    where: { slug: orgSlug },
    include: {
      members: {
        include: {
          user: true,
        },
      },
    },
  })
  return org
}

export async function findUserByEmail(email: string) {
  return prisma.user.findUnique({
    where: { email },
    include: {
      organizationMembers: {
        include: {
          organization: true,
        },
      },
    },
  })
}
EOF
```

**8.2 Drizzle Query Example**

Drizzle doesn't have an include syntax; you use joins. Let's write equivalent queries.

```bash
cat > src/drizzle/queries.ts << 'EOF'
import { db } from './client'
import { users, organizations, organizationMembers } from './schema'
import { eq, and } from 'drizzle-orm'

export async function getOrganizationWithMembers(orgSlug: string) {
  // We need to join organization, members, and users
  const result = await db
    .select({
      organization: organizations,
      member: organizationMembers,
      user: users,
    })
    .from(organizations)
    .where(eq(organizations.slug, orgSlug))
    .leftJoin(organizationMembers, eq(organizationMembers.organizationId, organizations.id))
    .leftJoin(users, eq(users.id, organizationMembers.userId))
    .all()

  // Reconstruct the structure: organization with members array
  if (result.length === 0) return null

  const org = result[0].organization
  const members = result
    .filter(row => row.member !== null && row.user !== null)
    .map(row => ({
      member: row.member!,
      user: row.user!,
    }))

  return {
    ...org,
    members,
  }
}

export async function findUserByEmail(email: string) {
  const result = await db
    .select({
      user: users,
      member: organizationMembers,
      org: organizations,
    })
    .from(users)
    .where(eq(users.email, email))
    .leftJoin(organizationMembers, eq(organizationMembers.userId, users.id))
    .leftJoin(organizations, eq(organizations.id, organizationMembers.organizationId))
    .all()

  if (result.length === 0) return null

  // Reconstruct
  const user = result[0].user
  const memberships = result
    .filter(row => row.member !== null && row.org !== null)
    .map(row => ({
      member: row.member!,
      organization: row.org!,
    }))

  return {
    ...user,
    organizationMembers: memberships,
  }
}
EOF
```

**8.3 Test the queries**

Let's write a small test script to run these queries.

```bash
cat > src/test-queries.ts << 'EOF'
import 'dotenv/config'
import { getOrganizationWithMembers as getOrgPrisma, findUserByEmail as findUserPrisma } from './prisma/queries'
import { getOrganizationWithMembers as getOrgDrizzle, findUserByEmail as findUserDrizzle } from './drizzle/queries'

async function test() {
  console.log('🔍 Testing Prisma queries...')
  const orgPrisma = await getOrgPrisma('acme')
  console.log('Prisma: Organization with members:', JSON.stringify(orgPrisma, null, 2))

  const userPrisma = await findUserPrisma('alice@acme.com')
  console.log('Prisma: User:', JSON.stringify(userPrisma, null, 2))

  console.log('🔍 Testing Drizzle queries...')
  const orgDrizzle = await getOrgDrizzle('acme')
  console.log('Drizzle: Organization with members:', JSON.stringify(orgDrizzle, null, 2))

  const userDrizzle = await findUserDrizzle('alice@acme.com')
  console.log('Drizzle: User:', JSON.stringify(userDrizzle, null, 2))

  console.log('✅ Query tests completed.')
}

test().catch(console.error)
EOF
```

Now run it:

```bash
pnpm tsx src/test-queries.ts
```

You should see the data fetched from both ORMs.

---

## Part 1, Section 7: Deep Dive - Prisma's Query Engine

Let's understand what happens when you run a Prisma query.

### The Query Pipeline

1. **Application calls `prisma.user.findUnique()`** - This is a generated method with type safety.
2. **Prisma Client serializes the query** into a JSON object representing the operation.
3. **This JSON is sent to the Query Engine** via a local socket or named pipe.
4. **Query Engine parses the JSON**, generates the SQL, and executes it using a database driver.
5. **Results are returned as JSON** to the Client, which maps them to TypeScript objects.

### Generated SQL

You can log the SQL Prisma generates by setting `log: ['query']`. Let's see an example.

Create a quick script:

```bash
cat > src/prisma/debug-sql.ts << 'EOF'
import { prisma } from './client'

async function debug() {
  // This will log the SQL to console because we set log: ['query'] in client.ts
  await prisma.user.findUnique({
    where: { email: 'alice@acme.com' },
    include: { organizationMembers: { include: { organization: true } } },
  })
}

debug().finally(() => prisma.$disconnect())
EOF
```

Run it:

```bash
pnpm tsx src/prisma/debug-sql.ts
```

You'll see something like:

```sql
SELECT "public"."users"."id", "public"."users"."email", ...,
       "public"."organization_members"."id" as "organizationMembers_id", ...
FROM "public"."users"
LEFT JOIN "public"."organization_members" ON "public"."users"."id" = "public"."organization_members"."user_id"
LEFT JOIN "public"."organizations" ON "public"."organization_members"."organization_id" = "public"."organizations"."id"
WHERE "public"."users"."email" = $1
```

Note the JOINs and the column aliasing. Prisma uses a technique to flatten the result set and then reconstruct the nested objects.

### Performance Considerations

- Prisma's Query Engine is highly optimized and written in Rust, so it's fast.
- However, the serialization/deserialization adds overhead.
- For simple CRUD, this overhead is negligible.
- For complex queries with many joins, the SQL generated may not be as optimal as hand-written SQL, but it's often good enough.

---

## Part 1, Section 8: Deep Dive - Drizzle's Query Building

Drizzle is a query builder. When you call `db.select().from(users).where(...)`, it constructs a SQL AST (Abstract Syntax Tree) in memory, then compiles it to a parameterized SQL string and sends it to the database driver.

### Query Example

The Drizzle query:

```typescript
await db
  .select()
  .from(users)
  .where(eq(users.email, 'alice@acme.com'))
  .leftJoin(organizationMembers, eq(organizationMembers.userId, users.id))
```

Generates SQL like:

```sql
SELECT "users".*, "organization_members".* 
FROM "users" 
LEFT JOIN "organization_members" ON "organization_members"."user_id" = "users"."id" 
WHERE "users"."email" = $1
```

### Type Safety

Drizzle infers the result type from the query structure. The `select()` call returns a type that includes all columns from the selected tables. When you use joins, the result type includes the joined tables as well. This is achieved with advanced TypeScript mapped types.

---

## Part 1, Section 9: Verification Checklist

Before we move on, ensure you have completed these steps successfully:

- [ ] Monorepo initialized with pnpm workspaces.
- [ ] Database package created with Prisma and Drizzle dependencies.
- [ ] Prisma schema defined with User, Organization, OrganizationMember.
- [ ] Drizzle schema defined with equivalent tables and relations.
- [ ] Prisma migration generated and applied.
- [ ] Drizzle migration generated and applied.
- [ ] Seed script ran successfully, populating the database.
- [ ] Prisma and Drizzle query scripts executed without errors.
- [ ] Observed SQL output from both ORMs.

If all are green, you're ready for Part 2.

---

## Part 1, Section 10: Reference - Installation and Commands Cheat Sheet

### Prisma Commands

| Command | Purpose |
|---------|---------|
| `prisma generate` | Generate Prisma Client from schema |
| `prisma migrate dev --name <name>` | Create and apply migration in development |
| `prisma migrate deploy` | Apply pending migrations in production |
| `prisma db seed` | Run seed script (if configured) |
| `prisma studio` | Open Prisma Studio GUI to view data |

### Drizzle Commands

| Command | Purpose |
|---------|---------|
| `drizzle-kit generate:pg` | Generate SQL migration files for PostgreSQL |
| `drizzle-kit migrate` | Apply migrations (using drizzle-orm migrator) |
| `drizzle-kit push` | Push schema directly (not recommended for production) |
| `drizzle-kit studio` | Open Drizzle Studio (if supported) |

### Useful NPM Scripts in the Package

We added these scripts in `package.json`:

- `pnpm prisma:generate` - Generate Prisma Client.
- `pnpm prisma:migrate` - Apply Prisma migrations.
- `pnpm drizzle:generate` - Generate Drizzle migrations.
- `pnpm drizzle:migrate` - Apply Drizzle migrations.
- `pnpm seed` - Run the seed script.
- `pnpm tsx <file>` - Run TypeScript files with tsx.

---

## Part 1, Section 11: Common Pitfalls and Troubleshooting

### Prisma Migration Errors

- **"Database already exists"** - If you've run migrations before, you may need to reset: `prisma migrate reset` (warning: drops data).
- **"Prisma Client not found"** - Run `prisma generate` after schema changes.
- **"Connection refused"** - Ensure PostgreSQL is running and the DATABASE_URL is correct.

### Drizzle Migration Errors

- **"No schema defined"** - Ensure your `drizzle.config.ts` points to the correct schema file.
- **"Relation already exists"** - If you need to recreate, drop the database or use `drizzle-kit push` with caution.
- **"Missing driver"** - Ensure you have `pg` or `mysql2` installed.

### Both ORMs in the Same Project

- **Dependency conflicts** - Keep versions in sync; both ORMs use separate dependencies, so they should be fine.
- **Type collisions** - Ensure you use appropriate import namespaces (e.g., `import * as prisma from '@prisma/client'` vs `import { users } from './drizzle/schema'`).

---

## Progress Log

| Phase | Status | Notes |
|-------|--------|-------|
| Part 0: Introduction | ✅ COMPLETE | |
| Part 1: ORM Philosophy, Architecture, and Design Principles | ✅ COMPLETE | Conceptual deep-dive and hands-on setup with both ORMs |
| Part 2: Database Schema Design, Modeling, and Migrations | ⏳ PENDING | Next: Expand schema, relationships, and advanced migrations |
| Part 3: Querying, Performance, and Type Safety | ⏳ PENDING | |
| Part 4: Framework Integration | ⏳ PENDING | |
| Part 5: Production Readiness | ⏳ PENDING | |
| Capstone Project | ⏳ PENDING | |
