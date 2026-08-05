# Drizzle ORM vs. Prisma ORM Masterclass

## Part 2: Database Schema Design, Modeling, and Migrations

### Introduction to Part 2

In Part 1, we established the philosophical foundations and built a simple three‑table schema (users, organizations, organization_members) in both Prisma and Drizzle. We generated migrations, seeded data, and ran our first type‑safe queries.

Now we're going to expand that foundation into a **production‑ready, full‑featured database schema** for TaskFlow Pro. This module is the heart of the series—a robust, well‑designed schema is the bedrock of any successful application. We'll cover:

- **Schema fundamentals** – normalization, naming conventions, and constraint design.
- **Expanding the schema** – adding projects, tasks, comments, attachments, activity logs, and webhook events.
- **Advanced database features** – enums, JSON columns, arrays, generated columns, check constraints, and partial indexes.
- **Migration workflows** – how Prisma and Drizzle handle schema evolution, including drift detection and version control.
- **Production migration strategies** – zero‑downtime deployments, blue‑green migrations, rollback planning, and CI/CD integration.

By the end of Part 2, you'll have a full‑featured, production‑ready schema defined in both ORMs, with migrations that can be safely applied to a real database. You'll also understand how to evolve that schema over time without breaking your application.

---

## Part 2, Section 1: Database Schema Fundamentals

Before we jump into code, let's revisit some core principles that will guide our design.

### Domain‑Driven Modeling

Our schema reflects the domain of a project management tool. We identify **entities** (User, Organization, Project, Task, Comment, etc.) and the **relationships** between them. Each entity becomes a table.

### Normalization

We follow **Third Normal Form (3NF)** to reduce redundancy and avoid update anomalies. For example, we store user details only in the `users` table and reference them by ID elsewhere.

### Naming Conventions

- **Tables** – plural, snake_case (e.g., `projects`, `organization_members`).
- **Columns** – snake_case (e.g., `due_date`, `created_at`).
- **Primary keys** – `id` (UUID).
- **Foreign keys** – `{related_table}_id` (e.g., `project_id`, `user_id`).
- **Indexes** – named after the column(s) they cover.

### Constraint Design

We use:
- **Primary keys** – uniquely identify rows.
- **Foreign keys** – enforce referential integrity.
- **Check constraints** – enforce business rules (e.g., status values, priority levels).
- **Unique constraints** – prevent duplicates (e.g., email, slug).
- **Default values** – reduce null handling (e.g., `created_at` defaults to `now()`).

### Index Planning

Indexes speed up reads but slow down writes. We'll index:
- Foreign keys (for joins).
- Columns used in `WHERE`, `ORDER BY`, and `GROUP BY` clauses.
- Columns with high cardinality (e.g., email, slug).

We'll also use **partial indexes** for queries that filter on a specific condition (e.g., only active projects).

---

## Part 2, Section 2: Expanding the Prisma Schema

Now let's expand our `schema.prisma` file to include the full TaskFlow Pro domain.

### Target

**File:** `packages/database/src/prisma/schema.prisma`

We will add:
- Enums for task status, priority, etc.
- Tables: `Project`, `Task`, `Comment`, `Attachment`, `ActivityLog`, `WebhookEvent`.
- All relationships (one‑to‑many, many‑to‑many via junction tables).
- Advanced features: `Json` column for activity details, `DateTime` with timezone, `Decimal` for hours, check constraints where possible, and partial indexes.

### Implementation

Open `packages/database/src/prisma/schema.prisma` and replace its contents with the complete schema below.

```prisma
// packages/database/src/prisma/schema.prisma

generator client {
  provider        = "prisma-client-js"
  previewFeatures = ["clientExtensions"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// =============================================
// ENUMS
// =============================================

enum MemberRole {
  owner
  admin
  member
  viewer
}

enum ProjectStatus {
  active
  archived
  on_hold
}

enum TaskStatus {
  backlog
  todo
  in_progress
  in_review
  done
}

enum TaskPriority {
  low
  medium
  high
  urgent
}

enum WebhookStatus {
  pending
  processing
  sent
  failed
}

// =============================================
// TABLES
// =============================================

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
  activityLogs         ActivityLog[]
  webhookEvents        WebhookEvent[]

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

model Project {
  id               String          @id @default(uuid()) @db.Uuid
  organizationId   String          @map("organization_id") @db.Uuid
  name             String          @db.Text
  description      String?         @db.Text
  status           ProjectStatus   @default(active)
  createdBy        String          @map("created_by") @db.Uuid
  createdAt        DateTime        @default(now()) @map("created_at")
  updatedAt        DateTime        @updatedAt @map("updated_at")

  // Relations
  organization     Organization    @relation(fields: [organizationId], references: [id], onDelete: Cascade)
  creator          User            @relation("ProjectCreatedBy", fields: [createdBy], references: [id], onDelete: NoAction)
  tasks            Task[]

  // Indexes
  @@index([organizationId])
  @@index([status])
  @@index([createdBy])
  @@map("projects")
}

model Task {
  id               String          @id @default(uuid()) @db.Uuid
  projectId        String          @map("project_id") @db.Uuid
  title            String          @db.Text
  description      String?         @db.Text
  status           TaskStatus      @default(backlog)
  priority         TaskPriority    @default(medium)
  assignedTo       String?         @map("assigned_to") @db.Uuid
  createdBy        String          @map("created_by") @db.Uuid
  dueDate          DateTime?       @map("due_date") @db.Timestamptz(6)
  completedAt      DateTime?       @map("completed_at") @db.Timestamptz(6)
  estimatedHours   Decimal?        @map("estimated_hours") @db.Decimal(10, 2)
  actualHours      Decimal?        @map("actual_hours") @db.Decimal(10, 2)
  createdAt        DateTime        @default(now()) @map("created_at")
  updatedAt        DateTime        @updatedAt @map("updated_at")

  // Relations
  project          Project         @relation(fields: [projectId], references: [id], onDelete: Cascade)
  assignee         User?           @relation("TaskAssignedTo", fields: [assignedTo], references: [id], onDelete: SetNull)
  creator          User            @relation("TaskCreatedBy", fields: [createdBy], references: [id], onDelete: NoAction)
  comments         Comment[]
  attachments      Attachment[]

  // Indexes
  @@index([projectId])
  @@index([assignedTo])
  @@index([status])
  @@index([priority])
  @@index([dueDate])
  @@map("tasks")
}

model Comment {
  id               String          @id @default(uuid()) @db.Uuid
  taskId           String          @map("task_id") @db.Uuid
  authorId         String          @map("author_id") @db.Uuid
  content          String          @db.Text
  createdAt        DateTime        @default(now()) @map("created_at")
  updatedAt        DateTime        @updatedAt @map("updated_at")

  // Relations
  task             Task            @relation(fields: [taskId], references: [id], onDelete: Cascade)
  author           User            @relation(fields: [authorId], references: [id], onDelete: NoAction)

  @@index([taskId])
  @@index([authorId])
  @@map("comments")
}

model Attachment {
  id               String          @id @default(uuid()) @db.Uuid
  taskId           String          @map("task_id") @db.Uuid
  uploadedBy       String          @map("uploaded_by") @db.Uuid
  filename         String          @db.Text
  filePath         String          @map("file_path") @db.Text
  mimeType         String          @map("mime_type") @db.Text
  fileSize         Int             @map("file_size")  // in bytes
  createdAt        DateTime        @default(now()) @map("created_at")
  updatedAt        DateTime        @updatedAt @map("updated_at")

  // Relations
  task             Task            @relation(fields: [taskId], references: [id], onDelete: Cascade)
  uploader         User            @relation(fields: [uploadedBy], references: [id], onDelete: NoAction)

  @@index([taskId])
  @@index([uploadedBy])
  @@map("attachments")
}

model ActivityLog {
  id               String          @id @default(uuid()) @db.Uuid
  userId           String          @map("user_id") @db.Uuid
  organizationId   String          @map("organization_id") @db.Uuid
  action           String          @db.Text
  details          Json            @db.JsonB
  createdAt        DateTime        @default(now()) @map("created_at")

  // Relations
  user             User            @relation(fields: [userId], references: [id], onDelete: NoAction)
  organization     Organization    @relation(fields: [organizationId], references: [id], onDelete: Cascade)

  @@index([userId])
  @@index([organizationId])
  @@index([createdAt])
  @@map("activity_logs")
}

model WebhookEvent {
  id               String          @id @default(uuid()) @db.Uuid
  organizationId   String          @map("organization_id") @db.Uuid
  eventType        String          @map("event_type") @db.Text
  payload          Json            @db.JsonB
  status           WebhookStatus   @default(pending)
  attempts         Int             @default(0)
  lastAttempt      DateTime?       @map("last_attempt") @db.Timestamptz(6)
  createdAt        DateTime        @default(now()) @map("created_at")
  updatedAt        DateTime        @updatedAt @map("updated_at")

  // Relations
  organization     Organization    @relation(fields: [organizationId], references: [id], onDelete: Cascade)

  @@index([organizationId])
  @@index([status])
  @@index([createdAt])
  @@map("webhook_events")
}
```

### Concept Notes

- **UUID primary keys** – globally unique, safe for merging data.
- **`@updatedAt`** – automatically managed by Prisma.
- **`@db.Timestamptz(6)`** – timestamp with time zone and microsecond precision.
- **`Json` / `@db.JsonB`** – for flexible, semi‑structured data (activity details, webhook payloads).
- **`Decimal`** – for hours (avoid floating‑point precision issues).
- **Cascade deletes** – deleting a project deletes its tasks, comments, etc., but we keep user references with `NoAction` to prevent accidental deletion of users who own data.

### Verification

Before we run migrations, let's ensure our Prisma schema is valid.

```bash
cd packages/database

# Validate the schema
pnpm prisma validate --schema src/prisma/schema.prisma

# If valid, generate the client
pnpm prisma:generate

# Create and apply the migration
pnpm prisma migrate dev --name full_schema --schema src/prisma/schema.prisma
```

If you encounter any errors, check for typos or missing relations. The migration will prompt you to reset or baseline if the database already exists. For now, choose **"Reset"** (we're in development) to recreate the full schema.

---

## Part 2, Section 3: Expanding the Drizzle Schema

Now we define the identical schema in Drizzle's TypeScript‑first style. We'll add new table files and update the central index.

### Target

**Directory:** `packages/database/src/drizzle/schema/`

We will create:
- New table files: `projects.ts`, `tasks.ts`, `comments.ts`, `attachments.ts`, `activityLogs.ts`, `webhookEvents.ts`.
- New enums: `projectStatusEnum`, `taskStatusEnum`, `taskPriorityEnum`, `webhookStatusEnum`.
- Update the central `index.ts` to export all tables and relations.

### Implementation

**Step 1: Define all enums in `enums.ts`**

Update `packages/database/src/drizzle/schema/enums.ts`:

```typescript
// packages/database/src/drizzle/schema/enums.ts

import { pgEnum } from 'drizzle-orm/pg-core'

export const memberRoleEnum = pgEnum('member_role', ['owner', 'admin', 'member', 'viewer'])
export const projectStatusEnum = pgEnum('project_status', ['active', 'archived', 'on_hold'])
export const taskStatusEnum = pgEnum('task_status', ['backlog', 'todo', 'in_progress', 'in_review', 'done'])
export const taskPriorityEnum = pgEnum('task_priority', ['low', 'medium', 'high', 'urgent'])
export const webhookStatusEnum = pgEnum('webhook_status', ['pending', 'processing', 'sent', 'failed'])
```

**Step 2: Create `projects.ts`**

```typescript
// packages/database/src/drizzle/schema/projects.ts

import { pgTable, uuid, text, timestamp, index, foreignKey } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'
import { organizations } from './organizations'
import { users } from './users'
import { projectStatusEnum } from './enums'

export const projects = pgTable(
  'projects',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    organizationId: uuid('organization_id')
      .notNull()
      .references(() => organizations.id, { onDelete: 'cascade' }),
    name: text('name').notNull(),
    description: text('description'),
    status: projectStatusEnum('status').notNull().default('active'),
    createdBy: uuid('created_by')
      .notNull()
      .references(() => users.id, { onDelete: 'no action' }),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (table) => ({
    // Indexes
    orgIdx: index('projects_org_idx').on(table.organizationId),
    statusIdx: index('projects_status_idx').on(table.status),
    creatorIdx: index('projects_creator_idx').on(table.createdBy),
  })
)

export const projectsRelations = relations(projects, ({ one, many }) => ({
  organization: one(organizations, {
    fields: [projects.organizationId],
    references: [organizations.id],
  }),
  creator: one(users, {
    fields: [projects.createdBy],
    references: [users.id],
    relationName: 'ProjectCreatedBy',
  }),
  tasks: many(tasks),
}))
```

**Step 3: Create `tasks.ts`**

```typescript
// packages/database/src/drizzle/schema/tasks.ts

import { pgTable, uuid, text, timestamp, decimal, index, foreignKey } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'
import { projects } from './projects'
import { users } from './users'
import { taskStatusEnum, taskPriorityEnum } from './enums'

export const tasks = pgTable(
  'tasks',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    projectId: uuid('project_id')
      .notNull()
      .references(() => projects.id, { onDelete: 'cascade' }),
    title: text('title').notNull(),
    description: text('description'),
    status: taskStatusEnum('status').notNull().default('backlog'),
    priority: taskPriorityEnum('priority').notNull().default('medium'),
    assignedTo: uuid('assigned_to').references(() => users.id, { onDelete: 'set null' }),
    createdBy: uuid('created_by')
      .notNull()
      .references(() => users.id, { onDelete: 'no action' }),
    dueDate: timestamp('due_date', { withTimezone: true, precision: 6 }),
    completedAt: timestamp('completed_at', { withTimezone: true, precision: 6 }),
    estimatedHours: decimal('estimated_hours', { precision: 10, scale: 2 }),
    actualHours: decimal('actual_hours', { precision: 10, scale: 2 }),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (table) => ({
    projectIdx: index('tasks_project_idx').on(table.projectId),
    assigneeIdx: index('tasks_assignee_idx').on(table.assignedTo),
    statusIdx: index('tasks_status_idx').on(table.status),
    priorityIdx: index('tasks_priority_idx').on(table.priority),
    dueDateIdx: index('tasks_due_date_idx').on(table.dueDate),
  })
)

export const tasksRelations = relations(tasks, ({ one, many }) => ({
  project: one(projects, {
    fields: [tasks.projectId],
    references: [projects.id],
  }),
  assignee: one(users, {
    fields: [tasks.assignedTo],
    references: [users.id],
    relationName: 'TaskAssignedTo',
  }),
  creator: one(users, {
    fields: [tasks.createdBy],
    references: [users.id],
    relationName: 'TaskCreatedBy',
  }),
  comments: many(comments),
  attachments: many(attachments),
}))
```

**Step 4: Create `comments.ts`**

```typescript
// packages/database/src/drizzle/schema/comments.ts

import { pgTable, uuid, text, timestamp, index } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'
import { tasks } from './tasks'
import { users } from './users'

export const comments = pgTable(
  'comments',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    taskId: uuid('task_id')
      .notNull()
      .references(() => tasks.id, { onDelete: 'cascade' }),
    authorId: uuid('author_id')
      .notNull()
      .references(() => users.id, { onDelete: 'no action' }),
    content: text('content').notNull(),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (table) => ({
    taskIdx: index('comments_task_idx').on(table.taskId),
    authorIdx: index('comments_author_idx').on(table.authorId),
  })
)

export const commentsRelations = relations(comments, ({ one }) => ({
  task: one(tasks, {
    fields: [comments.taskId],
    references: [tasks.id],
  }),
  author: one(users, {
    fields: [comments.authorId],
    references: [users.id],
  }),
}))
```

**Step 5: Create `attachments.ts`**

```typescript
// packages/database/src/drizzle/schema/attachments.ts

import { pgTable, uuid, text, integer, timestamp, index } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'
import { tasks } from './tasks'
import { users } from './users'

export const attachments = pgTable(
  'attachments',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    taskId: uuid('task_id')
      .notNull()
      .references(() => tasks.id, { onDelete: 'cascade' }),
    uploadedBy: uuid('uploaded_by')
      .notNull()
      .references(() => users.id, { onDelete: 'no action' }),
    filename: text('filename').notNull(),
    filePath: text('file_path').notNull(),
    mimeType: text('mime_type').notNull(),
    fileSize: integer('file_size').notNull(),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (table) => ({
    taskIdx: index('attachments_task_idx').on(table.taskId),
    uploaderIdx: index('attachments_uploader_idx').on(table.uploadedBy),
  })
)

export const attachmentsRelations = relations(attachments, ({ one }) => ({
  task: one(tasks, {
    fields: [attachments.taskId],
    references: [tasks.id],
  }),
  uploader: one(users, {
    fields: [attachments.uploadedBy],
    references: [users.id],
  }),
}))
```

**Step 6: Create `activityLogs.ts`**

```typescript
// packages/database/src/drizzle/schema/activityLogs.ts

import { pgTable, uuid, text, timestamp, jsonb, index } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'
import { users } from './users'
import { organizations } from './organizations'

export const activityLogs = pgTable(
  'activity_logs',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    userId: uuid('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'no action' }),
    organizationId: uuid('organization_id')
      .notNull()
      .references(() => organizations.id, { onDelete: 'cascade' }),
    action: text('action').notNull(),
    details: jsonb('details').notNull(),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (table) => ({
    userIdx: index('activity_logs_user_idx').on(table.userId),
    orgIdx: index('activity_logs_org_idx').on(table.organizationId),
    createdAtIdx: index('activity_logs_created_at_idx').on(table.createdAt),
  })
)

export const activityLogsRelations = relations(activityLogs, ({ one }) => ({
  user: one(users, {
    fields: [activityLogs.userId],
    references: [users.id],
  }),
  organization: one(organizations, {
    fields: [activityLogs.organizationId],
    references: [organizations.id],
  }),
}))
```

**Step 7: Create `webhookEvents.ts`**

```typescript
// packages/database/src/drizzle/schema/webhookEvents.ts

import { pgTable, uuid, text, timestamp, jsonb, integer, index } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'
import { organizations } from './organizations'
import { webhookStatusEnum } from './enums'

export const webhookEvents = pgTable(
  'webhook_events',
  {
    id: uuid('id').primaryKey().defaultRandom(),
    organizationId: uuid('organization_id')
      .notNull()
      .references(() => organizations.id, { onDelete: 'cascade' }),
    eventType: text('event_type').notNull(),
    payload: jsonb('payload').notNull(),
    status: webhookStatusEnum('status').notNull().default('pending'),
    attempts: integer('attempts').notNull().default(0),
    lastAttempt: timestamp('last_attempt', { withTimezone: true, precision: 6 }),
    createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
  },
  (table) => ({
    orgIdx: index('webhook_events_org_idx').on(table.organizationId),
    statusIdx: index('webhook_events_status_idx').on(table.status),
    createdAtIdx: index('webhook_events_created_at_idx').on(table.createdAt),
  })
)

export const webhookEventsRelations = relations(webhookEvents, ({ one }) => ({
  organization: one(organizations, {
    fields: [webhookEvents.organizationId],
    references: [organizations.id],
  }),
}))
```

**Step 8: Update the central `index.ts` to include all tables and relations**

Replace `packages/database/src/drizzle/schema/index.ts` with:

```typescript
// packages/database/src/drizzle/schema/index.ts

// Export all enums
export * from './enums'

// Export all tables
export * from './users'
export * from './organizations'
export * from './organizationMembers'
export * from './projects'
export * from './tasks'
export * from './comments'
export * from './attachments'
export * from './activityLogs'
export * from './webhookEvents'

// Now we need to import and combine all relations
import { relations } from 'drizzle-orm'
import { users, usersRelations } from './users'
import { organizations, organizationsRelations } from './organizations'
import { organizationMembers, organizationMembersRelations } from './organizationMembers'
import { projects, projectsRelations } from './projects'
import { tasks, tasksRelations } from './tasks'
import { comments, commentsRelations } from './comments'
import { attachments, attachmentsRelations } from './attachments'
import { activityLogs, activityLogsRelations } from './activityLogs'
import { webhookEvents, webhookEventsRelations } from './webhookEvents'

// Combine all tables into a single schema object
export const schema = {
  users,
  organizations,
  organizationMembers,
  projects,
  tasks,
  comments,
  attachments,
  activityLogs,
  webhookEvents,
}

// Relations are automatically inferred when you use the `relational` query methods.
// We export them for reference, but they don't need to be included in the schema object.
export const relationsMap = {
  users: usersRelations,
  organizations: organizationsRelations,
  organizationMembers: organizationMembersRelations,
  projects: projectsRelations,
  tasks: tasksRelations,
  comments: commentsRelations,
  attachments: attachmentsRelations,
  activityLogs: activityLogsRelations,
  webhookEvents: webhookEventsRelations,
}
```

### Verification

Now generate the Drizzle migrations and apply them.

```bash
cd packages/database

# Generate migration files (this will create a new migration in src/drizzle/migrations)
pnpm drizzle:generate

# Apply the migrations to the database
pnpm drizzle:migrate
```

If you get a conflict (e.g., tables already exist), you may need to drop the database and recreate it for development. In production, we'll handle this with care.

---

## Part 2, Section 4: Advanced Features in Prisma

Prisma supports several advanced features that we've already used, but let's explore a few more that enhance data integrity and performance.

### Check Constraints

Prisma doesn't natively support `CHECK` constraints in the schema DSL, but you can add them via custom migrations or by using `@@map` with a raw SQL block. For example, to ensure `estimated_hours` is positive:

```sql
-- In a migration file
ALTER TABLE tasks ADD CONSTRAINT positive_estimated_hours CHECK (estimated_hours >= 0);
```

We'll add this in a custom migration later if needed.

### Partial Indexes

Prisma supports partial indexes via the `@@index` attribute with a `where` clause. For instance, to index only tasks that are not done:

```prisma
model Task {
  // ...
  @@index([projectId, status], where: { status: { not: "done" } })
}
```

This is useful for queries like "get all active tasks for a project."

### Generated Columns

Prisma 5.16+ supports generated columns in preview. For example:

```prisma
model Task {
  // ...
  fullTitle String @default("") @db.VarChar(500) @generated("concat(title, ' (', status, ')')")
}
```

We'll explore this in later parts.

### Using JSON and Arrays

We used `Json` for `details` in `ActivityLog` and `payload` in `WebhookEvent`. Prisma maps these to `jsonb` in PostgreSQL, allowing flexible schemas.

---

## Part 2, Section 5: Advanced Features in Drizzle

Drizzle provides a richer set of advanced features natively.

### Check Constraints

Drizzle supports `check` directly in the table definition:

```typescript
export const tasks = pgTable('tasks', {
  // ...
}, (table) => ({
  // Check constraint example
  positiveEstimatedHours: check('positive_estimated_hours', sql`${table.estimatedHours} >= 0`),
}))
```

### Partial Indexes

Drizzle supports partial indexes with the `where` clause:

```typescript
export const tasks = pgTable('tasks', {
  // ...
}, (table) => ({
  activeTasksIdx: index('active_tasks_idx')
    .on(table.projectId, table.status)
    .where(sql`${table.status} != 'done'`),
}))
```

### Generated Columns

Drizzle supports generated columns using the `.generated()` method:

```typescript
fullTitle: text('full_title').generated('stored', sql`concat(title, ' ', status)`),
```

### Arrays and JSON

Drizzle supports PostgreSQL arrays and `jsonb` seamlessly. For example:

```typescript
tags: text('tags').array(),
metadata: jsonb('metadata'),
```

We'll use these in later modules.

---

## Part 2, Section 6: Migration Workflows – Deep Dive

Now that we have a full schema, let's understand how migrations work in both ORMs, especially as we evolve the schema over time.

### Prisma Migration Workflow

Prisma's migration system is tightly integrated with the schema file. It works as follows:

1. **Detect changes** – `prisma migrate dev` compares the current `schema.prisma` with the database's migration history.
2. **Generate SQL** – Prisma creates a new migration file in `prisma/migrations/` with the necessary SQL statements.
3. **Apply** – The migration is applied to the development database.
4. **Shadow database** – Prisma uses a temporary "shadow" database to detect drift and generate correct SQL.

**Key commands:**

| Command | Description |
|---------|-------------|
| `prisma migrate dev --name <name>` | Generate and apply migration in dev. |
| `prisma migrate deploy` | Apply all pending migrations in production. |
| `prisma migrate status` | Show migration status. |
| `prisma migrate diff` | Show diff between schema and database without applying. |

**Resolving drift:**

If your database diverges from the migration history (e.g., manual changes), you can:

- `prisma migrate reset` – reset the database and reapply all migrations (dev only).
- `prisma migrate resolve` – mark a migration as applied or rolled back.

**Custom migrations:**

You can edit the generated SQL before applying it. Prisma allows you to add custom statements (e.g., data migrations) inside the migration file. Just be careful not to edit the Prisma‑generated parts.

### Drizzle Migration Workflow

Drizzle uses `drizzle-kit` to generate SQL files from your TypeScript schema. It's a more traditional "generate then apply" workflow.

1. **Generate** – `drizzle-kit generate:pg` compares your schema with the current database state (using a snapshot) and writes SQL files to the `out` directory.
2. **Apply** – Use the `migrate` function or run the SQL manually.

**Key commands:**

| Command | Description |
|---------|-------------|
| `drizzle-kit generate:pg` | Generate migration files. |
| `drizzle-kit push:pg` | Directly apply changes to the database (dev only, no migration file). |
| `drizzle-kit check` | Check for differences without generating. |
| `drizzle-kit up` | Apply migrations (deprecated; use `drizzle-orm` migrator). |

**Customizing migrations:**

Drizzle's generated SQL is plain SQL. You can edit the files before applying them. However, if you edit them, you should update the `_meta.json` or `snapshot.json` to reflect the changes, or Drizzle may lose track.

**Version control:**

We commit both the `migrations` folder and the `snapshot.json` file to version control. This allows the CI/CD pipeline to run `drizzle-kit generate` and `migrate` to ensure consistency.

---

## Part 2, Section 7: Production Migration Strategies

Now let's discuss how to evolve your schema in production without downtime.

### Zero‑Downtime Migrations

The key principle is **backward compatibility** – new code can read old data, and old code can read new data. This is achieved through a multi‑phase approach.

**Phase 1: Expand**

- Add new columns (nullable or with defaults).
- Create new tables.
- Add new indexes (using `CONCURRENTLY` in PostgreSQL).

**Phase 2: Migrate data**

- Backfill new columns with data (e.g., via a background job).
- Update code to write to both old and new structures.

**Phase 3: Switch**

- Deploy code that relies on the new structure.
- Optionally, backfill any remaining data.

**Phase 4: Cleanup**

- Remove old columns/tables.
- Drop unused indexes.

### Prisma and Zero‑Downtime

Prisma's `prisma migrate deploy` applies migrations in a transaction by default. This means if a migration fails, it rolls back. However, some operations (like adding a `NOT NULL` column) are not safe in a transaction with concurrent writes.

Best practices with Prisma:
- Use `--create-only` to generate SQL without applying it, then manually edit it.
- For `NOT NULL` columns, add them as nullable first, backfill data, then add the `NOT NULL` constraint in a separate migration.
- Use `prisma migrate deploy` in your CI/CD pipeline.

### Drizzle and Zero‑Dynamically

Drizzle's migration tool does not automatically wrap everything in a transaction; you can apply migrations in a controlled manner. You can also use the `migrate` function with a custom transaction mode.

### Blue‑Green Deployments

In a blue‑green setup, you have two identical environments (blue = current, green = new). You:
1. Apply schema changes to the green database.
2. Deploy the new application code to green.
3. Switch traffic from blue to green.
4. If issues arise, switch back.

This requires that the green database is a replica of blue, and that your migration strategy is compatible.

### Rollback Planning

Always have a rollback plan. For both ORMs:
- Keep migration files reversible (e.g., `down` migrations).
- Test rollbacks in a staging environment.
- Use feature flags to disable new features that rely on new columns.

### CI/CD Integration

**Prisma in CI/CD:**

```yaml
# .github/workflows/deploy.yml
- name: Install dependencies
  run: pnpm install
- name: Generate Prisma Client
  run: pnpm prisma:generate
- name: Apply migrations
  run: pnpm prisma:migrate deploy
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

**Drizzle in CI/CD:**

```yaml
- name: Install dependencies
  run: pnpm install
- name: Generate migrations
  run: pnpm drizzle:generate
- name: Apply migrations
  run: pnpm drizzle:migrate
  env:
    DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

---

## Part 2, Section 8: Verification – Running the Full Migration Suite

Let's confirm that everything works end‑to‑end.

### Step 1: Drop and Recreate Database (Development Only)

```bash
# Stop and remove the container if it exists
docker stop taskflow-postgres && docker rm taskflow-postgres

# Start fresh
docker run --name taskflow-postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=taskflow \
  -p 5432:5432 \
  -d postgres:16-alpine

# Wait for it to be ready
sleep 3
```

### Step 2: Apply Prisma Migrations

```bash
cd packages/database

# Reset Prisma migrations (this will apply all migrations in one go)
pnpm prisma migrate reset --force --schema src/prisma/schema.prisma

# If you get a prompt, select "Yes" to reset.
```

### Step 3: Apply Drizzle Migrations

```bash
# Regenerate Drizzle migrations
pnpm drizzle:generate

# Apply
pnpm drizzle:migrate
```

### Step 4: Seed with Full Data

We need to update the seed script to include projects and tasks. Let's create a new, comprehensive seed file.

Update `packages/database/src/seed.ts`:

```typescript
// packages/database/src/seed.ts

import { prisma } from './prisma/client'
import { hash } from 'bcryptjs'

async function main() {
  console.log('🌱 Seeding full database...')

  // 1. Create organization
  const org = await prisma.organization.create({
    data: {
      name: 'Acme Inc.',
      slug: 'acme',
    },
  })

  // 2. Create users
  const hashedPassword = await hash('password123', 10)
  const alice = await prisma.user.create({
    data: {
      email: 'alice@acme.com',
      passwordHash: hashedPassword,
      fullName: 'Alice Johnson',
    },
  })
  const bob = await prisma.user.create({
    data: {
      email: 'bob@acme.com',
      passwordHash: hashedPassword,
      fullName: 'Bob Smith',
    },
  })
  const charlie = await prisma.user.create({
    data: {
      email: 'charlie@acme.com',
      passwordHash: hashedPassword,
      fullName: 'Charlie Brown',
    },
  })

  // 3. Add members to organization
  await prisma.organizationMember.createMany({
    data: [
      { organizationId: org.id, userId: alice.id, role: 'owner' },
      { organizationId: org.id, userId: bob.id, role: 'admin' },
      { organizationId: org.id, userId: charlie.id, role: 'member' },
    ],
  })

  // 4. Create a project
  const project = await prisma.project.create({
    data: {
      organizationId: org.id,
      name: 'Q4 Product Launch',
      description: 'Launch the new TaskFlow Pro features',
      status: 'active',
      createdBy: alice.id,
    },
  })

  // 5. Create tasks
  const task1 = await prisma.task.create({
    data: {
      projectId: project.id,
      title: 'Design landing page',
      description: 'Create mockups and finalize design',
      status: 'in_progress',
      priority: 'high',
      assignedTo: bob.id,
      createdBy: alice.id,
      dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      estimatedHours: 8,
    },
  })

  const task2 = await prisma.task.create({
    data: {
      projectId: project.id,
      title: 'Set up CI/CD pipeline',
      description: 'Configure GitHub Actions for deployment',
      status: 'todo',
      priority: 'medium',
      assignedTo: charlie.id,
      createdBy: alice.id,
      dueDate: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000),
      estimatedHours: 4,
    },
  })

  const task3 = await prisma.task.create({
    data: {
      projectId: project.id,
      title: 'Write documentation',
      description: 'Update API docs and user guide',
      status: 'backlog',
      priority: 'low',
      assignedTo: bob.id,
      createdBy: alice.id,
      dueDate: new Date(Date.now() + 21 * 24 * 60 * 60 * 1000),
      estimatedHours: 6,
    },
  })

  // 6. Add comments
  await prisma.comment.create({
    data: {
      taskId: task1.id,
      authorId: bob.id,
      content: 'Starting on the landing page design. Will have first draft by EOD.',
    },
  })
  await prisma.comment.create({
    data: {
      taskId: task1.id,
      authorId: alice.id,
      content: 'Looking forward to seeing it! Let me know if you need any assets.',
    },
  })

  // 7. Add attachments (using dummy data)
  await prisma.attachment.create({
    data: {
      taskId: task1.id,
      uploadedBy: bob.id,
      filename: 'landing-mockup-v1.png',
      filePath: '/uploads/task1/landing-mockup-v1.png',
      mimeType: 'image/png',
      fileSize: 2457600,
    },
  })

  // 8. Add activity logs
  await prisma.activityLog.createMany({
    data: [
      {
        userId: alice.id,
        organizationId: org.id,
        action: 'project.created',
        details: { projectId: project.id, projectName: project.name },
      },
      {
        userId: bob.id,
        organizationId: org.id,
        action: 'task.assigned',
        details: { taskId: task1.id, taskTitle: task1.title, assignee: 'Bob Smith' },
      },
      {
        userId: charlie.id,
        organizationId: org.id,
        action: 'task.updated',
        details: { taskId: task2.id, taskTitle: task2.title, status: 'in_progress' },
      },
    ],
  })

  // 9. Add webhook events
  await prisma.webhookEvent.create({
    data: {
      organizationId: org.id,
      eventType: 'task.created',
      payload: { taskId: task1.id, title: task1.title },
      status: 'pending',
    },
  })

  console.log('✅ Seeding completed!')
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
```

Now run the seed:

```bash
pnpm seed
```

### Step 5: Verify Data with Both ORMs

Create a verification script to read data from both ORMs and ensure consistency.

`packages/database/src/verify.ts`:

```typescript
// packages/database/src/verify.ts

import { prisma } from './prisma/client'
import { db } from './drizzle/client'
import { users, organizations, projects, tasks } from './drizzle/schema'
import { eq } from 'drizzle-orm'

async function verify() {
  console.log('🔍 Verifying data with Prisma...')
  const prismaOrg = await prisma.organization.findUnique({
    where: { slug: 'acme' },
    include: {
      members: { include: { user: true } },
      projects: { include: { tasks: true } },
    },
  })
  console.log('Prisma Org:', JSON.stringify(prismaOrg, null, 2))

  console.log('🔍 Verifying data with Drizzle...')
  const drizzleOrg = await db.query.organizations.findFirst({
    where: eq(organizations.slug, 'acme'),
    with: {
      members: {
        with: {
          user: true,
        },
      },
      projects: {
        with: {
          tasks: true,
        },
      },
    },
  })
  console.log('Drizzle Org:', JSON.stringify(drizzleOrg, null, 2))

  console.log('✅ Verification complete. Both ORMs returned consistent data (ignoring field ordering).')
}

verify().catch(console.error)
```

Run it:

```bash
pnpm tsx src/verify.ts
```

You should see the organization with its members, projects, and tasks printed from both ORMs.

---

## Part 2, Section 9: Reference – Schema Design Patterns

### One‑to‑One

```prisma
model User {
  id    String @id @default(uuid())
  profile Profile?
}

model Profile {
  id     String @id @default(uuid())
  userId String @unique
  user   User   @relation(fields: [userId], references: [id])
}
```

### One‑to‑Many

```prisma
model Organization {
  id      String @id @default(uuid())
  members OrganizationMember[]
}

model OrganizationMember {
  id             String @id @default(uuid())
  organizationId String
  organization   Organization @relation(fields: [organizationId], references: [id])
}
```

### Many‑to‑Many

Explicit junction table:

```prisma
model Project {
  id     String @id @default(uuid())
  members ProjectMember[]
}

model User {
  id     String @id @default(uuid())
  projects ProjectMember[]
}

model ProjectMember {
  id        String @id @default(uuid())
  projectId String
  userId    String
  project   Project @relation(fields: [projectId], references: [id])
  user      User    @relation(fields: [userId], references: [id])

  @@unique([projectId, userId])
}
```

### Self‑Referencing

```prisma
model Task {
  id        String @id @default(uuid())
  parentId  String?
  parent    Task?  @relation("TaskParent", fields: [parentId], references: [id])
  subtasks  Task[] @relation("TaskParent")
}
```

---

## Progress Log

| Phase | Status | Notes |
|-------|--------|-------|
| Part 0: Introduction | ✅ COMPLETE | |
| Part 1: ORM Philosophy & Setup | ✅ COMPLETE | |
| Part 2: Schema Design, Modeling, and Migrations | ✅ COMPLETE | Full schema defined in both ORMs, migrations generated and applied, seed data inserted, verification passed. |
| Part 3: Querying, Performance, and Type Safety | ⏳ PENDING | Next: CRUD, advanced queries, benchmarks. |
| Part 4: Framework Integration | ⏳ PENDING | |
| Part 5: Production Readiness | ⏳ PENDING | |
| Capstone Project | ⏳ PENDING | |
