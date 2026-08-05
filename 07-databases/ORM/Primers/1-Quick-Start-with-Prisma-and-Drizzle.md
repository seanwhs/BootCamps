# Primer 1: Quick Start with Prisma and Drizzle

### Who This Primer Is For

You've heard about Prisma and Drizzle, but you're not sure where to start. You want to see **real code** – side by side – so you can decide which one feels right. This primer is for you.

We'll build a **tiny blog database** with two tables: `User` and `Post`. You'll see how to:

- Set up both ORMs in a new project.
- Define schemas.
- Run migrations.
- Write a few queries.
- Compare the code.

**Time to complete:** ~20 minutes.

---

## 1. Prerequisites

- Node.js (v20 or newer)
- pnpm (or npm/yarn)
- A PostgreSQL database (local or cloud). We'll assume you have one running locally.

---

## 2. Project Setup

```bash
mkdir orm-primer
cd orm-primer
pnpm init
```

Create a `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "outDir": "./dist"
  },
  "include": ["src/**/*"]
}
```

Create an `.env` file with your database URL:

```
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/primerdb?schema=public"
```

---

## 3. Prisma Implementation

### 3.1 Install Prisma

```bash
pnpm add prisma @prisma/client
```

### 3.2 Define Schema

Create `prisma/schema.prisma`:

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
  posts Post[]
}

model Post {
  id        Int      @id @default(autoincrement())
  title     String
  content   String?
  published Boolean  @default(false)
  authorId  Int
  author    User     @relation(fields: [authorId], references: [id])
}
```

### 3.3 Run Migrations

```bash
npx prisma migrate dev --name init
```

### 3.4 Write Some Queries

Create `src/prisma-queries.ts`:

```typescript
import { PrismaClient } from '@prisma/client'

const prisma = new PrismaClient()

async function main() {
  // Create a user
  const user = await prisma.user.create({
    data: {
      email: 'alice@example.com',
      name: 'Alice',
    },
  })
  console.log('Created user:', user)

  // Create a post
  const post = await prisma.post.create({
    data: {
      title: 'Hello Prisma',
      content: 'This is my first post',
      authorId: user.id,
    },
  })
  console.log('Created post:', post)

  // Fetch user with posts
  const userWithPosts = await prisma.user.findUnique({
    where: { id: user.id },
    include: { posts: true },
  })
  console.log('User with posts:', JSON.stringify(userWithPosts, null, 2))
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect())
```

---

## 4. Drizzle Implementation

### 4.1 Install Drizzle

```bash
pnpm add drizzle-orm pg
pnpm add -D drizzle-kit @types/pg
```

### 4.2 Define Schema

Create `src/drizzle-schema.ts`:

```typescript
import { pgTable, serial, text, integer, boolean, timestamp } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: text('email').notNull().unique(),
  name: text('name').notNull(),
})

export const posts = pgTable('posts', {
  id: serial('id').primaryKey(),
  title: text('title').notNull(),
  content: text('content'),
  published: boolean('published').default(false),
  authorId: integer('author_id').notNull(),
})

export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}))

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
  }),
}))
```

### 4.3 Configure Drizzle Kit

Create `drizzle.config.ts`:

```typescript
import { defineConfig } from 'drizzle-kit'
import dotenv from 'dotenv'
dotenv.config()

export default defineConfig({
  dialect: 'postgresql',
  schema: './src/drizzle-schema.ts',
  out: './drizzle',
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
})
```

### 4.4 Generate and Run Migrations

```bash
npx drizzle-kit generate:pg
npx drizzle-kit push:pg
```

### 4.5 Write Some Queries

Create `src/drizzle-queries.ts`:

```typescript
import { drizzle } from 'drizzle-orm/node-postgres'
import { Pool } from 'pg'
import { users, posts } from './drizzle-schema'
import { eq } from 'drizzle-orm'

const pool = new Pool({ connectionString: process.env.DATABASE_URL })
const db = drizzle(pool)

async function main() {
  // Create a user
  const [user] = await db.insert(users).values({
    email: 'bob@example.com',
    name: 'Bob',
  }).returning()
  console.log('Created user:', user)

  // Create a post
  const [post] = await db.insert(posts).values({
    title: 'Hello Drizzle',
    content: 'My first post with Drizzle',
    authorId: user.id,
  }).returning()
  console.log('Created post:', post)

  // Fetch user with posts (via join)
  const result = await db.select()
    .from(users)
    .leftJoin(posts, eq(users.id, posts.authorId))
    .where(eq(users.id, user.id))
  console.log('User with posts:', result)
}

main()
  .catch(console.error)
  .finally(() => pool.end())
```

---

## 5. Side‑by‑Side Comparison

| Aspect | Prisma | Drizzle |
|--------|--------|---------|
| Schema Definition | `schema.prisma` (DSL) | TypeScript functions |
| Migration Command | `prisma migrate dev` | `drizzle-kit generate` + `push` |
| Create User | `prisma.user.create({ data })` | `db.insert(users).values(...).returning()` |
| Include Relations | `include: { posts: true }` | Need to perform joins manually or use `with` (if using relational queries) |
| Client Initialization | `new PrismaClient()` | `drizzle(pool, { schema })` |
| Type Safety | Generated types | Inferred types |

Both approaches are valid. Prisma provides a more "batteries‑included" experience with built‑in relation handling, while Drizzle gives you direct SQL control and lighter runtime.

---

## 6. Run the Examples

```bash
# Prisma
pnpm tsx src/prisma-queries.ts

# Drizzle
pnpm tsx src/drizzle-queries.ts
```

You should see the output of user creation, post creation, and fetching the user with their posts.

---

## 7. Next Steps

- Read the **full masterclass** for deep dives into schema design, complex queries, production deployment, and more.
- Explore **Part 1** to understand the philosophies behind each ORM.
- Use the **decision framework** from Appendix I to choose the right tool for your project.

---

## 8. Final Thoughts

This primer showed you the bare minimum to get started. You've seen that both ORMs are capable and that the choice often comes down to team preference, performance needs, and project complexity.

Now, go build something great!
