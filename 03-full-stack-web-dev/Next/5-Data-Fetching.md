# Part 5: Data Fetching in Next.js 16

Until now, LaunchPad’s projects have lived in a TypeScript array. That was useful while learning routing and component boundaries, but production applications need persistent data.

In this part, we will replace the temporary catalog with PostgreSQL, a relational database.

By the end of Part 5, LaunchPad will include:

- A local PostgreSQL development database
- Versioned SQL migrations
- Repeatable seed data
- Validated server environment variables
- A protected database client
- Parameterized SQL queries
- Runtime validation of database results
- Async Server Components
- Request-level query deduplication
- Dynamic database-backed pages
- Suspense and streamed dashboard sections
- Route loading interfaces
- A workspace error boundary
- Database verification and production build checks

> **Important:** Docker is used for the local database. The application itself continues to run directly through Node.js and Next.js.

---

# Step 1: Understand the Data-Fetching Architecture

## The Target

Understand how requests will travel from a Next.js page to PostgreSQL before adding database code.

## The Concept

The browser must never connect directly to the database.

A database connection contains powerful credentials. Giving those credentials to browser code would be like handing every visitor the master key to a building.

Instead, the request flow will be:

```text
Browser
   ↓ HTTPS request
Next.js route
   ↓
Server Component
   ↓
Server-only query function
   ↓
Protected database client
   ↓
PostgreSQL
```

The database returns rows to the server. The server then decides which values are safe to render or pass to Client Components.

Our source architecture will become:

```text
src/
├── app/
│   └── (workspace)/
│       ├── dashboard/
│       └── projects/
├── components/
│   ├── dashboard-active-projects.tsx
│   ├── dashboard-metrics.tsx
│   └── project-list.tsx
└── lib/
    ├── database/
    │   ├── client.ts
    │   ├── project-queries.ts
    │   └── schemas.ts
    ├── environment.ts
    └── project-types.ts
```

The old `project-catalog.ts` module will be removed after every route has been migrated.

## The Implementation

No files change in this planning step.

We will use four distinct layers:

### Environment layer

```text
src/lib/environment.ts
```

Validates private server configuration such as `DATABASE_URL`.

### Database client layer

```text
src/lib/database/client.ts
```

Creates and reuses the PostgreSQL connection pool.

### Query layer

```text
src/lib/database/project-queries.ts
```

Contains parameterized SQL and converts database rows into application types.

### Presentation layer

```text
src/app
src/components
```

Calls query functions and renders the resulting data.

## The Verification

Confirm that no Client Component imports the current server-only catalog:

```bash
if grep -R \
  'project-catalog' \
  src/components \
  --include="*.tsx"; then
  echo "A component imports the protected catalog."
  exit 1
else
  echo "Client components do not import the server catalog."
fi
```

Expected output:

```text
Client components do not import the server catalog.
```

[GENERATED: Part 5, Step 1: Data Architecture] [STARTING: Part 5, Step 2: PostgreSQL Development Service]

---

# Step 2: Create the PostgreSQL Development Service

## The Target

Run PostgreSQL locally in a Docker container with persistent development storage and a health check.

## The Concept

A container packages a service and its operating environment into a repeatable unit.

Think of it as a standardized shipping container. The contents remain predictable regardless of the machine carrying it.

Docker Compose describes one or more related containers in a YAML file. LaunchPad currently needs one service:

```text
db → PostgreSQL
```

A Docker **volume** preserves database files when the container stops. Without a volume, deleting the container would also delete its data.

A **health check** tests whether PostgreSQL is ready to receive connections. A running process is not necessarily ready to serve requests.

## The Implementation

First, verify Docker:

```bash
docker --version
docker compose version
```

If Docker is unavailable, install Docker Desktop from:

```text
https://www.docker.com/products/docker-desktop/
```

Create this file in the project root.

### `compose.yaml`

```yaml
services:
  db:
    image: postgres:17-alpine
    container_name: launchpad-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: launchpad
      POSTGRES_USER: launchpad
      POSTGRES_PASSWORD: launchpad-development-password
    ports:
      - "5432:5432"
    volumes:
      - launchpad-postgres-data:/var/lib/postgresql/data
    healthcheck:
      test:
        - CMD-SHELL
        - pg_isready --username=launchpad --dbname=launchpad
      interval: 5s
      timeout: 5s
      retries: 10
      start_period: 5s

volumes:
  launchpad-postgres-data:
```

### Why the password is acceptable here

This credential is only for the disposable local development database declared in source control.

It must not be reused in staging or production.

Production credentials will be supplied through the deployment platform’s secret-management system rather than committed files.

### Start PostgreSQL

Run:

```bash
docker compose up --detach db
```

Inspect the container:

```bash
docker compose ps
```

Expected output should show the `db` service as running. After a short delay, its health should become:

```text
healthy
```

If it initially says `starting`, wait several seconds and run the command again.

## The Verification

Run PostgreSQL’s readiness command inside the container:

```bash
docker compose exec db \
  pg_isready \
  --username=launchpad \
  --dbname=launchpad
```

Expected output resembles:

```text
/var/run/postgresql:5432 - accepting connections
```

Run a test query:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="SELECT current_database(), current_user;"
```

Expected output includes:

```text
launchpad | launchpad
```

[GENERATED: Part 5, Step 2: PostgreSQL Development Service] [STARTING: Part 5, Step 3: Database Migration]

---

# Step 3: Create the Initial Database Migration

## The Target

Create versioned SQL that defines the project and task tables, constraints, indexes, and relationships.

## The Concept

A **migration** is a versioned change to a database’s structure.

It is similar to a set of architectural renovation instructions:

```text
Migration 001: create the first rooms
Migration 002: add a new doorway
Migration 003: reinforce a wall
```

A database schema defines:

- Tables
- Columns
- Data types
- Relationships
- Constraints
- Indexes

A **constraint** is a rule enforced by the database. For example, a task cannot reference a project that does not exist.

An **index** is an additional data structure that helps PostgreSQL locate rows efficiently. It resembles the index at the back of a book: maintaining it requires some work, but finding information becomes faster.

## The Implementation

Create the database directories:

```bash
mkdir -p database/migrations database/seeds
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force database/migrations | Out-Null
New-Item -ItemType Directory -Force database/seeds | Out-Null
```

Create the migration.

### `database/migrations/001_create_projects_and_tasks.sql`

```sql
BEGIN;

CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  description TEXT NOT NULL,
  status VARCHAR(20) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT projects_name_not_blank
    CHECK (length(trim(name)) > 0),

  CONSTRAINT projects_description_not_blank
    CHECK (length(trim(description)) > 0),

  CONSTRAINT projects_status_allowed
    CHECK (status IN ('PLANNED', 'ACTIVE', 'COMPLETED'))
);

CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL,
  title VARCHAR(160) NOT NULL,
  description TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'TODO',
  priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
  due_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT tasks_project_foreign_key
    FOREIGN KEY (project_id)
    REFERENCES projects(id)
    ON DELETE CASCADE,

  CONSTRAINT tasks_title_not_blank
    CHECK (length(trim(title)) > 0),

  CONSTRAINT tasks_status_allowed
    CHECK (status IN ('TODO', 'IN_PROGRESS', 'COMPLETED')),

  CONSTRAINT tasks_priority_allowed
    CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH'))
);

CREATE INDEX projects_status_index
  ON projects(status);

CREATE INDEX projects_created_at_index
  ON projects(created_at DESC);

CREATE INDEX tasks_project_id_index
  ON tasks(project_id);

CREATE INDEX tasks_project_status_index
  ON tasks(project_id, status);

COMMIT;
```

### Why the migration uses a transaction

The migration begins with:

```sql
BEGIN;
```

and ends with:

```sql
COMMIT;
```

A transaction groups changes into one unit. If an operation fails before the commit, PostgreSQL can avoid leaving the database half-migrated.

### Why task deletion cascades

This relationship includes:

```sql
ON DELETE CASCADE
```

If a project is deleted, its tasks are deleted with it. Tasks have no useful meaning without their parent project.

This is a product rule encoded at the database boundary instead of relying only on application code.

### Apply the migration

On macOS, Linux, or Git Bash:

```bash
docker compose exec -T db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --set=ON_ERROR_STOP=1 \
  < database/migrations/001_create_projects_and_tasks.sql
```

PowerShell:

```powershell
Get-Content `
  -Raw `
  database/migrations/001_create_projects_and_tasks.sql |
  docker compose exec -T db `
    psql `
    --username=launchpad `
    --dbname=launchpad `
    --set=ON_ERROR_STOP=1
```

Expected output includes:

```text
BEGIN
CREATE TABLE
CREATE TABLE
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE INDEX
COMMIT
```

## The Verification

List the tables:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="\dt"
```

Expected output includes:

```text
projects
tasks
```

Inspect the projects table:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="\d projects"
```

Inspect the tasks table:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="\d tasks"
```

Confirm that:

- Both primary keys use UUIDs.
- `tasks.project_id` references `projects.id`.
- Status constraints are present.
- The indexes are listed.

[GENERATED: Part 5, Step 3: Initial Database Migration] [STARTING: Part 5, Step 4: Development Seed Data]

---

# Step 4: Create Repeatable Seed Data

## The Target

Insert deterministic development projects and tasks that can be safely re-seeded.

## The Concept

**Seed data** gives a development database predictable records.

A seed script is similar to staging a model home. The building exists after migration, but sample furniture makes it possible to inspect and test the space.

Our seed will be **idempotent**. Idempotent means running it more than once produces the same final result instead of creating duplicates.

For this development seed, we accomplish that by deleting existing records before inserting known records.

> Do not use destructive development seed scripts against production databases.

## The Implementation

Create the seed file.

### `database/seeds/development.sql`

```sql
BEGIN;

DELETE FROM tasks;
DELETE FROM projects;

INSERT INTO projects (
  id,
  name,
  description,
  status,
  created_at,
  updated_at
)
VALUES
  (
    '10000000-0000-4000-8000-000000000001',
    'Website redesign',
    'Refresh the marketing website with clearer messaging, faster pages, and an accessible component system.',
    'ACTIVE',
    CURRENT_TIMESTAMP - INTERVAL '30 days',
    CURRENT_TIMESTAMP - INTERVAL '2 days'
  ),
  (
    '10000000-0000-4000-8000-000000000002',
    'Mobile application',
    'Plan and deliver the first mobile experience for customers who manage work away from their desks.',
    'PLANNED',
    CURRENT_TIMESTAMP - INTERVAL '20 days',
    CURRENT_TIMESTAMP - INTERVAL '5 days'
  ),
  (
    '10000000-0000-4000-8000-000000000003',
    'Documentation hub',
    'Create a searchable home for product guides, engineering standards, and onboarding material.',
    'COMPLETED',
    CURRENT_TIMESTAMP - INTERVAL '60 days',
    CURRENT_TIMESTAMP - INTERVAL '1 day'
  ),
  (
    '10000000-0000-4000-8000-000000000004',
    'Analytics dashboard',
    'Build a shared dashboard that turns product activity into clear and actionable insights.',
    'ACTIVE',
    CURRENT_TIMESTAMP - INTERVAL '15 days',
    CURRENT_TIMESTAMP - INTERVAL '3 days'
  );

INSERT INTO tasks (
  id,
  project_id,
  title,
  description,
  status,
  priority,
  due_date
)
VALUES
  (
    '20000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000001',
    'Audit existing pages',
    'Review content, accessibility, performance, and analytics.',
    'COMPLETED',
    'HIGH',
    CURRENT_DATE - INTERVAL '20 days'
  ),
  (
    '20000000-0000-4000-8000-000000000002',
    '10000000-0000-4000-8000-000000000001',
    'Create component inventory',
    'Document reusable components and missing design-system primitives.',
    'COMPLETED',
    'MEDIUM',
    CURRENT_DATE - INTERVAL '14 days'
  ),
  (
    '20000000-0000-4000-8000-000000000003',
    '10000000-0000-4000-8000-000000000001',
    'Implement responsive navigation',
    'Build keyboard-accessible navigation for desktop and mobile layouts.',
    'IN_PROGRESS',
    'HIGH',
    CURRENT_DATE + INTERVAL '5 days'
  ),
  (
    '20000000-0000-4000-8000-000000000004',
    '10000000-0000-4000-8000-000000000001',
    'Optimize landing-page images',
    'Convert and resize source assets for responsive delivery.',
    'TODO',
    'MEDIUM',
    CURRENT_DATE + INTERVAL '10 days'
  ),
  (
    '20000000-0000-4000-8000-000000000005',
    '10000000-0000-4000-8000-000000000002',
    'Interview mobile users',
    'Identify the most important workflows for the first release.',
    'TODO',
    'HIGH',
    CURRENT_DATE + INTERVAL '14 days'
  ),
  (
    '20000000-0000-4000-8000-000000000006',
    '10000000-0000-4000-8000-000000000002',
    'Evaluate platform strategy',
    'Compare native and cross-platform implementation approaches.',
    'TODO',
    'HIGH',
    CURRENT_DATE + INTERVAL '21 days'
  ),
  (
    '20000000-0000-4000-8000-000000000007',
    '10000000-0000-4000-8000-000000000003',
    'Define information architecture',
    'Organize guides into predictable categories.',
    'COMPLETED',
    'HIGH',
    CURRENT_DATE - INTERVAL '40 days'
  ),
  (
    '20000000-0000-4000-8000-000000000008',
    '10000000-0000-4000-8000-000000000003',
    'Import engineering standards',
    'Move current standards into the documentation system.',
    'COMPLETED',
    'MEDIUM',
    CURRENT_DATE - INTERVAL '25 days'
  ),
  (
    '20000000-0000-4000-8000-000000000009',
    '10000000-0000-4000-8000-000000000003',
    'Add full-text search',
    'Make documentation searchable by title and body content.',
    'COMPLETED',
    'HIGH',
    CURRENT_DATE - INTERVAL '10 days'
  ),
  (
    '20000000-0000-4000-8000-000000000010',
    '10000000-0000-4000-8000-000000000004',
    'Define core metrics',
    'Agree on the product measures displayed in the first dashboard.',
    'COMPLETED',
    'HIGH',
    CURRENT_DATE - INTERVAL '7 days'
  ),
  (
    '20000000-0000-4000-8000-000000000011',
    '10000000-0000-4000-8000-000000000004',
    'Create warehouse queries',
    'Build reviewed queries for each approved metric.',
    'IN_PROGRESS',
    'HIGH',
    CURRENT_DATE + INTERVAL '7 days'
  ),
  (
    '20000000-0000-4000-8000-000000000012',
    '10000000-0000-4000-8000-000000000004',
    'Design dashboard filters',
    'Define date, segment, and product filtering controls.',
    'TODO',
    'MEDIUM',
    CURRENT_DATE + INTERVAL '12 days'
  );

COMMIT;
```

### Apply the seed

macOS, Linux, or Git Bash:

```bash
docker compose exec -T db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --set=ON_ERROR_STOP=1 \
  < database/seeds/development.sql
```

PowerShell:

```powershell
Get-Content `
  -Raw `
  database/seeds/development.sql |
  docker compose exec -T db `
    psql `
    --username=launchpad `
    --dbname=launchpad `
    --set=ON_ERROR_STOP=1
```

## The Verification

Count projects:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="SELECT COUNT(*) AS project_count FROM projects;"
```

Expected result:

```text
4
```

Count tasks:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="SELECT COUNT(*) AS task_count FROM tasks;"
```

Expected result:

```text
12
```

Inspect projects with computed counts:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      p.name,
      p.status,
      COUNT(t.id) AS task_count,
      COUNT(t.id) FILTER (
        WHERE t.status = 'COMPLETED'
      ) AS completed_task_count
    FROM projects AS p
    LEFT JOIN tasks AS t
      ON t.project_id = p.id
    GROUP BY p.id
    ORDER BY p.name;
  "
```

Expected values:

| Project | Tasks | Completed |
|---|---:|---:|
| Analytics dashboard | 3 | 1 |
| Documentation hub | 3 | 3 |
| Mobile application | 2 | 0 |
| Website redesign | 4 | 2 |

Run the seed a second time and confirm the counts remain `4` and `12`.

[GENERATED: Part 5, Step 4: Development Seed Data] [STARTING: Part 5, Step 5: Environment Configuration]

---

# Step 5: Validate the Database Environment Variable

## The Target

Create documented local environment configuration and validate `DATABASE_URL` before using it.

## The Concept

An environment variable supplies configuration from outside source code.

Examples include:

- Database connection strings
- Authentication secrets
- Service credentials
- Monitoring endpoints

Environment variables arrive as strings and may be:

- Missing
- Empty
- Misspelled
- Malformed

We will validate them with Zod. Zod is a runtime validation library. TypeScript checks our source code, while Zod checks values that enter the running application.

## The Implementation

Install the PostgreSQL driver and validation library:

```bash
npm install postgres zod
```

Create a documented example file.

### `.env.example`

```dotenv
# Copy this file to .env.local for local development.
# Never place production credentials in this example file.
DATABASE_URL=postgresql://launchpad:launchpad-development-password@localhost:5432/launchpad
```

Create the actual local file:

### `.env.local`

```dotenv
DATABASE_URL=postgresql://launchpad:launchpad-development-password@localhost:5432/launchpad
```

Confirm that `.env.local` is ignored:

```bash
git check-ignore .env.local
```

Expected output:

```text
.env.local
```

If it is not ignored, add this line to `.gitignore`:

```gitignore
.env*
```

Then explicitly allow the safe example:

```gitignore
!.env.example
```

Create the environment module.

### `src/lib/environment.ts`

```ts
import "server-only";

import { z } from "zod";

const serverEnvironmentSchema = z.object({
  DATABASE_URL: z
    .string()
    .min(1, "DATABASE_URL is required.")
    .refine(
      (value) =>
        value.startsWith("postgres://") ||
        value.startsWith("postgresql://"),
      "DATABASE_URL must use the postgres:// or postgresql:// protocol.",
    ),
});

const parsedEnvironment = serverEnvironmentSchema.safeParse({
  DATABASE_URL: process.env.DATABASE_URL,
});

if (!parsedEnvironment.success) {
  const formattedErrors = parsedEnvironment.error.issues
    .map((issue) => `${issue.path.join(".")}: ${issue.message}`)
    .join("\n");

  throw new Error(
    `Invalid server environment configuration:\n${formattedErrors}`,
  );
}

export const serverEnvironment = Object.freeze(
  parsedEnvironment.data,
);
```

### Why the validated object is frozen

This expression prevents accidental reassignment of configuration properties:

```ts
Object.freeze(parsedEnvironment.data)
```

Environment configuration should be read as immutable application input.

### Why the value is not prefixed with `NEXT_PUBLIC_`

Next.js exposes variables prefixed with:

```text
NEXT_PUBLIC_
```

to browser code when referenced there.

A database URL is private and must never use that prefix.

## The Verification

Run:

```bash
npm ls postgres zod
npx tsc --noEmit
npm run lint
```

All commands should succeed.

Confirm that Git does not stage the secret:

```bash
git status --short
```

You should see `.env.example`, but not `.env.local`.

Test the database URL directly through the containerized PostgreSQL client:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="SELECT 1 AS connection_test;"
```

Expected result:

```text
1
```

[GENERATED: Part 5, Step 5: Environment Configuration] [STARTING: Part 5, Step 6: Database Client]

---

# Step 6: Create the Protected Database Client

## The Target

Create one reusable, server-only PostgreSQL client with safe connection-pool limits.

## The Concept

Opening a new database connection for every module import would waste resources. In development, Fast Refresh can also re-evaluate modules repeatedly.

We will store the client on Node’s global object during development so code reloads reuse it.

A **connection pool** manages a limited collection of database connections. It resembles a taxi rank: requests borrow an available connection and return it when finished rather than manufacturing a new vehicle for every trip.

## The Implementation

Create the database directory:

```bash
mkdir -p src/lib/database
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force src/lib/database | Out-Null
```

Create the client.

### `src/lib/database/client.ts`

```ts
import "server-only";

import postgres from "postgres";

import { serverEnvironment } from "@/lib/environment";

type DatabaseClient = ReturnType<typeof postgres>;

const globalForDatabase = globalThis as typeof globalThis & {
  launchpadDatabase?: DatabaseClient;
};

function createDatabaseClient(): DatabaseClient {
  return postgres(serverEnvironment.DATABASE_URL, {
    /**
     * Keep the pool intentionally small for the tutorial application.
     * Production limits must also account for the number of application
     * instances and the database provider's connection allowance.
     */
    max: 10,

    /**
     * Close idle connections after 20 seconds. They will be recreated when
     * another query needs them.
     */
    idle_timeout: 20,

    /**
     * Stop waiting after 10 seconds when no connection can be established.
     */
    connect_timeout: 10,

    /**
     * PostgreSQL notices can be useful interactively but create noisy
     * application logs. Actual query errors still reject their promises.
     */
    onnotice: () => undefined,
  });
}

export const database =
  globalForDatabase.launchpadDatabase ?? createDatabaseClient();

if (process.env.NODE_ENV !== "production") {
  globalForDatabase.launchpadDatabase = database;
}
```

### Why no database client is exported to the browser

The file begins with:

```ts
import "server-only";
```

Client Components cannot safely import it.

Every query will also remain in a server-only module.

### Production connection counts

The `max: 10` option applies per application process.

If production runs 20 instances, the theoretical maximum becomes:

```text
20 × 10 = 200 connections
```

Production sizing must therefore consider:

- Database provider limits
- Application instance count
- Serverless concurrency
- Connection pooling proxies
- Query duration

We will revisit deployment concerns in Part 10.

## The Verification

Run:

```bash
npx tsc --noEmit
npm run lint
```

Confirm both database modules are protected:

```bash
grep -R 'import "server-only"' \
  src/lib/environment.ts \
  src/lib/database/client.ts
```

Expected output contains both files.

[GENERATED: Part 5, Step 6: Database Client] [STARTING: Part 5, Step 7: Database Result Schemas]

---

# Step 7: Validate Database Results

## The Target

Create Zod schemas that verify database rows before they enter the presentation layer.

## The Concept

The database is more trustworthy than arbitrary user input, but application assumptions can still drift from the schema.

For example:

- A migration may rename a column.
- A SQL alias may be misspelled.
- A count may arrive as a string instead of a number.
- A nullable value may be treated as required.

Validating rows at the query boundary converts raw data into a dependable application contract.

## The Implementation

Create the database schemas.

### `src/lib/database/schemas.ts`

```ts
import { z } from "zod";

import { PROJECT_STATUSES } from "@/lib/project-types";

export const projectSummarySchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  description: z.string().min(1),
  status: z.enum(PROJECT_STATUSES),
  taskCount: z.number().int().nonnegative(),
  completedTaskCount: z.number().int().nonnegative(),
});

export const projectSummaryListSchema = z.array(
  projectSummarySchema,
);

export const dashboardMetricsSchema = z.object({
  projectCount: z.number().int().nonnegative(),
  activeProjectCount: z.number().int().nonnegative(),
  taskCount: z.number().int().nonnegative(),
  completedTaskCount: z.number().int().nonnegative(),
});

export type DashboardMetrics = z.infer<
  typeof dashboardMetricsSchema
>;
```

### Why the application uses camel case

PostgreSQL columns conventionally use snake case:

```text
completed_task_count
```

TypeScript properties conventionally use camel case:

```text
completedTaskCount
```

Our SQL will alias database columns into the application naming convention.

That creates a clear transformation boundary rather than spreading database naming conventions throughout every component.

## The Verification

Run:

```bash
npx tsc --noEmit
npm run lint
```

Both commands should succeed.

[GENERATED: Part 5, Step 7: Database Result Validation] [STARTING: Part 5, Step 8: Parameterized Project Queries]

---

# Step 8: Build the Project Query Layer

## The Target

Create server-only, parameterized queries for project lists, individual projects, dashboard metrics, and active projects.

## The Concept

A **parameterized query** keeps SQL instructions separate from untrusted values.

Unsafe string construction looks like this:

```ts
const query = `SELECT * FROM projects WHERE id = '${projectId}'`;
```

An attacker may attempt to place SQL syntax inside `projectId`.

The `postgres` package uses tagged templates:

```ts
database`
  SELECT *
  FROM projects
  WHERE id = ${projectId}
`
```

The library sends the value as a parameter rather than concatenating it into SQL source.

We will also wrap individual-project lookup with React’s `cache` function. Here, `cache` provides request-level memoization: if metadata generation and page rendering request the same project during one render, React can reuse the result.

This is not a long-lived shared application cache.

## The Implementation

Create the query module.

### `src/lib/database/project-queries.ts`

```ts
import "server-only";

import { cache } from "react";

import { database } from "@/lib/database/client";
import {
  dashboardMetricsSchema,
  projectSummaryListSchema,
  projectSummarySchema,
  type DashboardMetrics,
} from "@/lib/database/schemas";
import type {
  ProjectStatus,
  ProjectSummary,
} from "@/lib/project-types";

type ProjectSummaryRow = {
  id: string;
  name: string;
  description: string;
  status: ProjectStatus;
  taskCount: number;
  completedTaskCount: number;
};

type DashboardMetricsRow = {
  projectCount: number;
  activeProjectCount: number;
  taskCount: number;
  completedTaskCount: number;
};

export async function getProjects(
  status?: ProjectStatus,
): Promise<ProjectSummary[]> {
  const rows = status
    ? await database<ProjectSummaryRow[]>`
        SELECT
          p.id,
          p.name,
          p.description,
          p.status,
          COUNT(t.id)::integer AS "taskCount",
          COUNT(t.id) FILTER (
            WHERE t.status = 'COMPLETED'
          )::integer AS "completedTaskCount"
        FROM projects AS p
        LEFT JOIN tasks AS t
          ON t.project_id = p.id
        WHERE p.status = ${status}
        GROUP BY p.id
        ORDER BY p.updated_at DESC, p.name ASC
      `
    : await database<ProjectSummaryRow[]>`
        SELECT
          p.id,
          p.name,
          p.description,
          p.status,
          COUNT(t.id)::integer AS "taskCount",
          COUNT(t.id) FILTER (
            WHERE t.status = 'COMPLETED'
          )::integer AS "completedTaskCount"
        FROM projects AS p
        LEFT JOIN tasks AS t
          ON t.project_id = p.id
        GROUP BY p.id
        ORDER BY p.updated_at DESC, p.name ASC
      `;

  return projectSummaryListSchema.parse(rows);
}

/**
 * React cache deduplicates identical calls during one server-rendering
 * request. It prevents generateMetadata and the page from issuing the same
 * project query twice during that request.
 */
export const getProjectById = cache(
  async (projectId: string): Promise<ProjectSummary | null> => {
    const rows = await database<ProjectSummaryRow[]>`
      SELECT
        p.id,
        p.name,
        p.description,
        p.status,
        COUNT(t.id)::integer AS "taskCount",
        COUNT(t.id) FILTER (
          WHERE t.status = 'COMPLETED'
        )::integer AS "completedTaskCount"
      FROM projects AS p
      LEFT JOIN tasks AS t
        ON t.project_id = p.id
      WHERE p.id = ${projectId}
      GROUP BY p.id
      LIMIT 1
    `;

    const row = rows[0];

    if (!row) {
      return null;
    }

    return projectSummarySchema.parse(row);
  },
);

export async function getDashboardMetrics(): Promise<DashboardMetrics> {
  const rows = await database<DashboardMetricsRow[]>`
    SELECT
      COUNT(DISTINCT p.id)::integer AS "projectCount",
      COUNT(DISTINCT p.id) FILTER (
        WHERE p.status = 'ACTIVE'
      )::integer AS "activeProjectCount",
      COUNT(t.id)::integer AS "taskCount",
      COUNT(t.id) FILTER (
        WHERE t.status = 'COMPLETED'
      )::integer AS "completedTaskCount"
    FROM projects AS p
    LEFT JOIN tasks AS t
      ON t.project_id = p.id
  `;

  const row = rows[0];

  if (!row) {
    return {
      projectCount: 0,
      activeProjectCount: 0,
      taskCount: 0,
      completedTaskCount: 0,
    };
  }

  return dashboardMetricsSchema.parse(row);
}

export async function getActiveProjects(
  limit = 4,
): Promise<ProjectSummary[]> {
  if (!Number.isInteger(limit) || limit < 1 || limit > 20) {
    throw new RangeError(
      "Active project limit must be an integer between 1 and 20.",
    );
  }

  const rows = await database<ProjectSummaryRow[]>`
    SELECT
      p.id,
      p.name,
      p.description,
      p.status,
      COUNT(t.id)::integer AS "taskCount",
      COUNT(t.id) FILTER (
        WHERE t.status = 'COMPLETED'
      )::integer AS "completedTaskCount"
    FROM projects AS p
    LEFT JOIN tasks AS t
      ON t.project_id = p.id
    WHERE p.status = 'ACTIVE'
    GROUP BY p.id
    ORDER BY p.updated_at DESC, p.name ASC
    LIMIT ${limit}
  `;

  return projectSummaryListSchema.parse(rows);
}
```

### Why counts are cast to integers

PostgreSQL’s `COUNT` returns `bigint` by default. Some drivers represent large integer values as strings to avoid JavaScript precision loss.

Our application counts are small, so SQL explicitly converts them:

```sql
COUNT(t.id)::integer
```

The Zod schema can then safely require:

```ts
z.number().int().nonnegative()
```

### Why the limit is validated

Even internal function arguments deserve explicit contracts:

```ts
limit < 1 || limit > 20
```

This prevents accidental queries requesting unreasonable amounts of dashboard data.

## The Verification

Run:

```bash
npx tsc --noEmit
npm run lint
```

Confirm the module is protected:

```bash
head -n 1 src/lib/database/project-queries.ts
```

Expected output:

```ts
import "server-only";
```

Confirm queries use tagged parameters:

```bash
grep -n '\${projectId}\|\${status}\|\${limit}' \
  src/lib/database/project-queries.ts
```

Expected output shows parameter expressions inside tagged SQL templates.

[GENERATED: Part 5, Step 8: Project Query Layer] [STARTING: Part 5, Step 9: Database-Backed Project List]

---

# Step 9: Fetch Project Lists in an Async Server Component

## The Target

Replace temporary catalog reads on `/projects` with asynchronous PostgreSQL queries.

## The Concept

A Server Component can be declared `async` and await data directly:

```tsx
export default async function Page() {
  const projects = await getProjects();

  return <ProjectList projects={projects} />;
}
```

There is no browser-side `useEffect` and no temporary empty render.

The server:

1. Receives the route request.
2. Validates the URL filter.
3. Queries PostgreSQL.
4. Renders the initial project list.
5. Sends the result to the browser.

The Client Component still receives plain project data and performs immediate text searching.

## The Implementation

Completely replace the project list page.

### `src/app/(workspace)/projects/page.tsx`

```tsx
import type { Metadata } from "next";

import { ProjectList } from "@/components/project-list";
import { getProjects } from "@/lib/database/project-queries";
import {
  formatProjectStatus,
  isProjectStatus,
  PROJECT_STATUSES,
  type ProjectStatus,
} from "@/lib/project-types";

export const metadata: Metadata = {
  title: "Projects",
  description:
    "Browse, filter, and search database-backed LaunchPad projects.",
};

type ProjectsPageProps = {
  searchParams: Promise<{
    status?: string | string[];
  }>;
};

function readStatusFilter(
  value: string | string[] | undefined,
): ProjectStatus | undefined {
  if (typeof value !== "string") {
    return undefined;
  }

  const normalizedValue = value.toUpperCase();

  return isProjectStatus(normalizedValue)
    ? normalizedValue
    : undefined;
}

export default async function ProjectsPage({
  searchParams,
}: ProjectsPageProps) {
  const query = await searchParams;
  const requestedStatus = query.status;
  const selectedStatus = readStatusFilter(requestedStatus);
  const hasInvalidStatus =
    requestedStatus !== undefined && selectedStatus === undefined;

  /**
   * The query runs only after the untrusted URL value has been validated.
   * An invalid status is not forwarded to the database.
   */
  const projects = await getProjects(selectedStatus);

  const resultsHeading = selectedStatus
    ? `${formatProjectStatus(selectedStatus)} projects`
    : "All projects";

  return (
    <main className="site-shell page-content">
      <header className="page-heading">
        <p className="eyebrow">Project workspace</p>
        <h1>Explore the work already on the LaunchPad</h1>
        <p>
          Project records and task totals now come from PostgreSQL. Status
          filtering runs on the server, while text searching remains a
          focused browser interaction.
        </p>
      </header>

      <section className="filter-panel" aria-labelledby="filter-heading">
        <div>
          <h2 id="filter-heading">Filter projects by status</h2>
          <p>
            The selected status is stored in the URL so this view can be
            bookmarked or shared.
          </p>
        </div>

        <form action="/projects" method="get" className="filter-form">
          <label htmlFor="status">Project status</label>

          <div className="filter-controls">
            <select
              id="status"
              name="status"
              defaultValue={selectedStatus ?? ""}
            >
              <option value="">All statuses</option>

              {PROJECT_STATUSES.map((status) => (
                <option key={status} value={status}>
                  {formatProjectStatus(status)}
                </option>
              ))}
            </select>

            <button className="primary-button" type="submit">
              Apply filter
            </button>
          </div>
        </form>
      </section>

      {hasInvalidStatus ? (
        <div className="notice notice--warning" role="status">
          <p>
            The requested status is not supported. Showing all projects
            instead.
          </p>
        </div>
      ) : null}

      <ProjectList
        heading={resultsHeading}
        projects={projects}
      />
    </main>
  );
}
```

### Why this route is dynamic

The route reads changing database data when requested.

We are intentionally not applying a persistent cross-request cache yet because:

- Database writes arrive in Part 7.
- User-specific authorization arrives in Part 8.
- Cache invalidation rules should be designed with those mutations and users in mind.

Fresh database access is a safer initial default than accidentally sharing stale or private data.

## The Verification

Ensure PostgreSQL is running:

```bash
docker compose up --detach db
```

Start Next.js:

```bash
npm run dev
```

Open:

```text
http://localhost:3000/projects
```

Confirm that four projects appear with the new task counts:

- Website redesign: 4 tasks, 2 complete
- Mobile application: 2 tasks, 0 complete
- Documentation hub: 3 tasks, 3 complete
- Analytics dashboard: 3 tasks, 1 complete

Verify Active filtering:

```bash
active_page="$(
  curl --fail --silent \
    "http://localhost:3000/projects?status=ACTIVE"
)"

printf "%s" "${active_page}" |
  grep --quiet "Website redesign"

printf "%s" "${active_page}" |
  grep --quiet "Analytics dashboard"

if printf "%s" "${active_page}" |
  grep --quiet "Mobile application"; then
  echo "The Active filter returned a planned project."
  exit 1
fi

echo "Database-backed status filtering works."
```

Expected output:

```text
Database-backed status filtering works.
```

Run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 5, Step 9: Database-Backed Project List] [STARTING: Part 5, Step 10: Database-Backed Dynamic Project Page]

---

# Step 10: Fetch Individual Projects from PostgreSQL

## The Target

Replace static dynamic-route generation and catalog lookup with database-backed project lookup.

## The Concept

The project ID is now a UUID:

```text
10000000-0000-4000-8000-000000000001
```

The page must handle three outcomes:

1. A valid UUID identifies a project.
2. A valid UUID has no matching project.
3. The URL contains an invalid UUID.

Sending an invalid UUID to PostgreSQL’s UUID comparison can produce a database error. We will validate the parameter before querying.

This is another example of treating URLs as untrusted input.

## The Implementation

Completely replace the project-detail page.

### `src/app/(workspace)/projects/[projectId]/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { z } from "zod";

import { CopyProjectLink } from "@/components/copy-project-link";
import { InteractiveDisclosure } from "@/components/interactive-disclosure";
import { getProjectById } from "@/lib/database/project-queries";
import {
  calculateProjectProgress,
  formatProjectStatus,
} from "@/lib/project-types";

type ProjectPageProps = {
  params: Promise<{
    projectId: string;
  }>;
};

const projectIdSchema = z.string().uuid();

async function findProject(projectId: string) {
  const parsedProjectId = projectIdSchema.safeParse(projectId);

  if (!parsedProjectId.success) {
    return null;
  }

  return getProjectById(parsedProjectId.data);
}

export async function generateMetadata({
  params,
}: ProjectPageProps): Promise<Metadata> {
  const { projectId } = await params;
  const project = await findProject(projectId);

  if (!project) {
    return {
      title: "Project not found",
      description: "The requested LaunchPad project could not be found.",
    };
  }

  return {
    title: project.name,
    description: project.description,
  };
}

export default async function ProjectPage({
  params,
}: ProjectPageProps) {
  const { projectId } = await params;
  const project = await findProject(projectId);

  if (!project) {
    notFound();
  }

  const progress = calculateProjectProgress(project);
  const remainingTaskCount =
    project.taskCount - project.completedTaskCount;

  return (
    <main className="site-shell page-content">
      <nav className="breadcrumb" aria-label="Breadcrumb">
        <ol>
          <li>
            <Link href="/dashboard">Dashboard</Link>
          </li>
          <li aria-hidden="true">/</li>
          <li>
            <Link href="/projects">Projects</Link>
          </li>
          <li aria-hidden="true">/</li>
          <li aria-current="page">{project.name}</li>
        </ol>
      </nav>

      <article>
        <header className="project-detail-heading">
          <div>
            <p className="eyebrow">Project details</p>
            <h1>{project.name}</h1>
            <p>{project.description}</p>
          </div>

          <span
            className={`status-badge status-badge--${project.status.toLowerCase()}`}
          >
            {formatProjectStatus(project.status)}
          </span>
        </header>

        <div className="project-detail-actions">
          <CopyProjectLink projectName={project.name} />
        </div>

        <section
          className="project-stat-grid"
          aria-label="Project statistics"
        >
          <div className="stat-card">
            <span className="stat-card__label">Total tasks</span>
            <strong>{project.taskCount}</strong>
          </div>

          <div className="stat-card">
            <span className="stat-card__label">Completed</span>
            <strong>{project.completedTaskCount}</strong>
          </div>

          <div className="stat-card">
            <span className="stat-card__label">Remaining</span>
            <strong>{remainingTaskCount}</strong>
          </div>

          <div className="stat-card">
            <span className="stat-card__label">Progress</span>
            <strong>{progress}%</strong>
          </div>
        </section>

        <section
          className="detail-progress"
          aria-labelledby="progress-heading"
        >
          <div className="progress-summary__labels">
            <h2 id="progress-heading">Task completion</h2>
            <span>{progress}%</span>
          </div>

          <progress
            max={100}
            value={progress}
            aria-label={`${project.name} task completion`}
          >
            {progress}%
          </progress>

          <p>
            {project.completedTaskCount} of {project.taskCount} tasks are
            complete.
          </p>
        </section>

        <div className="project-disclosures">
          <InteractiveDisclosure title="How this page is rendered">
            <div className="prose-content">
              <p>
                The route parameter is validated before a parameterized
                PostgreSQL query runs. Metadata and page rendering share the
                same request-level cached lookup.
              </p>

              <p>
                Only the disclosure and copy-link controls need browser-side
                JavaScript.
              </p>
            </div>
          </InteractiveDisclosure>

          <InteractiveDisclosure title="Current data source">
            <div className="prose-content">
              <p>
                This project and its computed task totals come from
                PostgreSQL.
              </p>

              <p>
                The query, connection string, and database client remain in
                server-only modules.
              </p>
            </div>
          </InteractiveDisclosure>
        </div>
      </article>

      <Link className="secondary-link" href="/projects">
        <span aria-hidden="true">← </span>
        Return to all projects
      </Link>
    </main>
  );
}
```

### Why `generateStaticParams` was removed

The old catalog contained a fixed public set of records known during the build.

Database records can change after deployment. Later, they will also belong to individual users.

The project route is now resolved dynamically rather than generating a permanent build-time list.

### Why metadata and page lookup can be deduplicated

Both functions eventually call:

```ts
getProjectById(projectId)
```

That function is wrapped with React `cache`, allowing identical lookup work during one render request to be reused.

## The Verification

Open:

```text
http://localhost:3000/projects/10000000-0000-4000-8000-000000000001
```

Confirm:

- Website redesign appears.
- Total tasks are `4`.
- Completed tasks are `2`.
- Remaining tasks are `2`.
- Progress is `50%`.

Verify the title:

```bash
curl --silent \
  http://localhost:3000/projects/10000000-0000-4000-8000-000000000001 |
  grep -o "<title>[^<]*</title>"
```

Expected output:

```html
<title>Website redesign | LaunchPad</title>
```

Test an invalid UUID:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/projects/not-a-uuid
```

Expected output:

```text
404
```

Test a valid but missing UUID:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/projects/99999999-9999-4999-8999-999999999999
```

Expected output:

```text
404
```

Run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 5, Step 10: Database-Backed Project Page] [STARTING: Part 5, Step 11: Streaming Dashboard Components]

---

# Step 11: Stream Independent Dashboard Sections

## The Target

Split the dashboard into independent async Server Components and wrap them with Suspense boundaries.

## The Concept

Without streaming, a route may wait for all data before sending its useful interface.

With React Suspense, independent sections can have independent loading fallbacks:

```text
Dashboard shell
├── Metrics loading…
└── Active projects loading…
```

When one section finishes, the server can stream it without waiting for every other section.

Think of a restaurant serving completed courses instead of holding the entire meal until every dish is ready.

Suspense does not make the database query itself faster. It improves how independently completing work reaches the user.

## The Implementation

Create the metrics component.

### `src/components/dashboard-metrics.tsx`

```tsx
import { getDashboardMetrics } from "@/lib/database/project-queries";

export async function DashboardMetrics() {
  const metrics = await getDashboardMetrics();

  const overallProgress =
    metrics.taskCount === 0
      ? 0
      : Math.round(
          (metrics.completedTaskCount / metrics.taskCount) * 100,
        );

  return (
    <section
      className="dashboard-stat-grid"
      aria-label="Workspace statistics"
    >
      <article className="dashboard-stat">
        <span>Projects</span>
        <strong>{metrics.projectCount}</strong>
        <p>{metrics.activeProjectCount} currently active</p>
      </article>

      <article className="dashboard-stat">
        <span>Total tasks</span>
        <strong>{metrics.taskCount}</strong>
        <p>Across every project</p>
      </article>

      <article className="dashboard-stat">
        <span>Completed tasks</span>
        <strong>{metrics.completedTaskCount}</strong>
        <p>{overallProgress}% overall progress</p>
      </article>
    </section>
  );
}
```

Create the active-project component.

### `src/components/dashboard-active-projects.tsx`

```tsx
import Link from "next/link";

import { getActiveProjects } from "@/lib/database/project-queries";
import {
  calculateProjectProgress,
  formatProjectStatus,
} from "@/lib/project-types";

export async function DashboardActiveProjects() {
  const activeProjects = await getActiveProjects(4);

  return (
    <section
      className="dashboard-section"
      aria-labelledby="active-projects-heading"
    >
      <div className="results-heading">
        <div>
          <p className="eyebrow">Current focus</p>
          <h2 id="active-projects-heading">Active projects</h2>
        </div>

        <Link className="text-link" href="/projects?status=ACTIVE">
          View filtered list
          <span aria-hidden="true"> →</span>
        </Link>
      </div>

      {activeProjects.length > 0 ? (
        <div className="project-grid">
          {activeProjects.map((project) => {
            const progress = calculateProjectProgress(project);

            return (
              <article className="project-card" key={project.id}>
                <div className="project-card__heading">
                  <h3>
                    <Link href={`/projects/${project.id}`}>
                      {project.name}
                    </Link>
                  </h3>

                  <span className="status-badge status-badge--active">
                    {formatProjectStatus(project.status)}
                  </span>
                </div>

                <p>{project.description}</p>

                <div className="progress-summary">
                  <div className="progress-summary__labels">
                    <span>Task progress</span>
                    <span>{progress}%</span>
                  </div>

                  <progress
                    max={100}
                    value={progress}
                    aria-label={`${project.name} task completion`}
                  >
                    {progress}%
                  </progress>

                  <p>
                    {project.completedTaskCount} of {project.taskCount} tasks
                    completed
                  </p>
                </div>
              </article>
            );
          })}
        </div>
      ) : (
        <div className="empty-state">
          <h3>No active projects</h3>
          <p>Active projects will appear here when work begins.</p>
        </div>
      )}
    </section>
  );
}
```

Create reusable skeleton fallbacks.

### `src/components/dashboard-skeletons.tsx`

```tsx
export function DashboardMetricsSkeleton() {
  return (
    <section
      className="dashboard-stat-grid"
      aria-label="Loading workspace statistics"
      aria-busy="true"
    >
      {Array.from({ length: 3 }, (_, index) => (
        <div
          className="dashboard-stat skeleton-card"
          key={index}
          aria-hidden="true"
        >
          <span className="skeleton-line skeleton-line--short" />
          <span className="skeleton-line skeleton-line--large" />
          <span className="skeleton-line" />
        </div>
      ))}
    </section>
  );
}

export function ActiveProjectsSkeleton() {
  return (
    <section
      className="dashboard-section"
      aria-label="Loading active projects"
      aria-busy="true"
    >
      <div className="results-heading">
        <div>
          <span className="skeleton-line skeleton-line--short" />
          <span className="skeleton-line skeleton-line--heading" />
        </div>
      </div>

      <div className="project-grid">
        {Array.from({ length: 2 }, (_, index) => (
          <div
            className="project-card skeleton-card"
            key={index}
            aria-hidden="true"
          >
            <span className="skeleton-line skeleton-line--heading" />
            <span className="skeleton-line" />
            <span className="skeleton-line" />
            <span className="skeleton-line skeleton-line--short" />
          </div>
        ))}
      </div>
    </section>
  );
}
```

Now replace the dashboard page.

### `src/app/(workspace)/dashboard/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";
import { Suspense } from "react";

import { DashboardActiveProjects } from "@/components/dashboard-active-projects";
import { DashboardMetrics } from "@/components/dashboard-metrics";
import {
  ActiveProjectsSkeleton,
  DashboardMetricsSkeleton,
} from "@/components/dashboard-skeletons";

export const metadata: Metadata = {
  title: "Dashboard",
  description:
    "View database-backed project and task progress in the LaunchPad workspace.",
};

export default function DashboardPage() {
  return (
    <main className="site-shell page-content">
      <header className="page-heading dashboard-heading">
        <div>
          <p className="eyebrow">Workspace overview</p>
          <h1>Good work starts with a clear view.</h1>
          <p>
            Independent dashboard sections load from PostgreSQL inside
            separate streaming boundaries.
          </p>
        </div>

        <Link className="primary-link" href="/projects">
          View all projects
        </Link>
      </header>

      <Suspense fallback={<DashboardMetricsSkeleton />}>
        <DashboardMetrics />
      </Suspense>

      <Suspense fallback={<ActiveProjectsSkeleton />}>
        <DashboardActiveProjects />
      </Suspense>
    </main>
  );
}
```

### Why the page itself is not async

The page does not await the queries directly.

Instead, each child performs its own work:

```tsx
<DashboardMetrics />
<DashboardActiveProjects />
```

The Suspense boundaries can therefore resolve independently.

## The Verification

Open:

```text
http://localhost:3000/dashboard
```

Confirm the final dashboard displays:

- 4 projects
- 2 active projects
- 12 total tasks
- 6 completed tasks
- 50% overall progress
- Website redesign
- Analytics dashboard

Verify the server response:

```bash
dashboard_page="$(
  curl --fail --silent http://localhost:3000/dashboard
)"

printf "%s" "${dashboard_page}" |
  grep --quiet "Good work starts with a clear view"

printf "%s" "${dashboard_page}" |
  grep --quiet "Website redesign"

printf "%s" "${dashboard_page}" |
  grep --quiet "Analytics dashboard"

echo "Database-backed dashboard content found."
```

Expected output:

```text
Database-backed dashboard content found.
```

Run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 5, Step 11: Streaming Dashboard] [STARTING: Part 5, Step 12: Route Loading UI]

---

# Step 12: Add Workspace Loading Interfaces

## The Target

Create route-segment loading interfaces for dashboard and project navigation.

## The Concept

A `loading.tsx` file defines a route-level Suspense fallback.

It provides immediate feedback while a route segment’s server work is pending.

The relationship is conceptually:

```tsx
<Suspense fallback={<Loading />}>
  <Page />
</Suspense>
```

Next.js creates this boundary from the file convention.

We will use separate loading interfaces because dashboard and project routes have different page shapes.

## The Implementation

Create the dashboard loading file.

### `src/app/(workspace)/dashboard/loading.tsx`

```tsx
import {
  ActiveProjectsSkeleton,
  DashboardMetricsSkeleton,
} from "@/components/dashboard-skeletons";

export default function DashboardLoading() {
  return (
    <main
      className="site-shell page-content"
      aria-label="Loading dashboard"
      aria-busy="true"
    >
      <header className="page-heading">
        <p className="eyebrow">Workspace overview</p>
        <h1>Loading your dashboard…</h1>
        <p>
          LaunchPad is preparing project and task statistics.
        </p>
      </header>

      <DashboardMetricsSkeleton />
      <ActiveProjectsSkeleton />
    </main>
  );
}
```

Create the projects loading file.

### `src/app/(workspace)/projects/loading.tsx`

```tsx
export default function ProjectsLoading() {
  return (
    <main
      className="site-shell page-content"
      aria-label="Loading projects"
      aria-busy="true"
    >
      <header className="page-heading">
        <p className="eyebrow">Project workspace</p>
        <h1>Loading projects…</h1>
        <p>
          LaunchPad is retrieving the latest project information.
        </p>
      </header>

      <div className="project-grid">
        {Array.from({ length: 4 }, (_, index) => (
          <div
            className="project-card skeleton-card"
            key={index}
            aria-hidden="true"
          >
            <span className="skeleton-line skeleton-line--heading" />
            <span className="skeleton-line" />
            <span className="skeleton-line" />
            <span className="skeleton-line skeleton-line--short" />
          </div>
        ))}
      </div>
    </main>
  );
}
```

## The Verification

Run:

```bash
npx tsc --noEmit
npm run lint
```

To observe loading UI in a fast local environment:

1. Open browser developer tools.
2. Select the Network panel.
3. Enable network throttling such as **Fast 3G**.
4. Navigate from `/dashboard` to `/projects`.
5. Navigate back to `/dashboard`.
6. Observe the loading interface while route work completes.
7. Disable throttling after the test.

Do not add artificial production delays merely to make loading states easier to see.

[GENERATED: Part 5, Step 12: Route Loading UI] [STARTING: Part 5, Step 13: Workspace Error Boundary]

---

# Step 13: Add a Workspace Error Boundary

## The Target

Display a recoverable error interface when unexpected workspace rendering or database failures occur.

## The Concept

A loading boundary handles pending work. An error boundary handles unexpected failure.

Examples include:

- PostgreSQL becoming unavailable
- A malformed database result
- A programming error during rendering
- A network failure between the application and database

The `error.tsx` file must be a Client Component because it receives a `reset` function and allows the user to retry rendering.

Expected problems such as invalid filters should still use normal validation feedback. Error boundaries are for unexpected failures.

## The Implementation

Create the workspace error boundary.

### `src/app/(workspace)/error.tsx`

```tsx
"use client";

import { useEffect } from "react";

type WorkspaceErrorProps = {
  error: Error & {
    digest?: string;
  };
  reset: () => void;
};

export default function WorkspaceError({
  error,
  reset,
}: WorkspaceErrorProps) {
  useEffect(() => {
    /**
     * A production application would send this error to an approved
     * monitoring service. Logging it here preserves useful development
     * diagnostics without showing technical details to the user.
     */
    console.error("Workspace rendering failed.", error);
  }, [error]);

  return (
    <main className="site-shell page-content">
      <div className="error-panel" role="alert">
        <p className="eyebrow">Workspace unavailable</p>
        <h1>LaunchPad could not load this information.</h1>
        <p>
          The problem may be temporary. Confirm the database is running, then
          try the request again.
        </p>

        <button
          className="primary-button"
          type="button"
          onClick={() => {
            reset();
          }}
        >
          Try again
        </button>

        {error.digest ? (
          <p className="error-reference">
            Error reference: <code>{error.digest}</code>
          </p>
        ) : null}
      </div>
    </main>
  );
}
```

### Why the technical error is not rendered

This would be unsafe:

```tsx
<p>{error.message}</p>
```

An internal error may reveal:

- Database details
- File paths
- Query information
- Service names
- Implementation details

The user receives a safe, actionable message. The complete error is written to the browser’s development console for this tutorial.

A production monitoring system will replace or supplement that logging in Part 10.

### Why `reset()` does not reload the whole browser document

The error boundary receives:

```ts
reset: () => void
```

Calling it asks React and Next.js to retry rendering the failed boundary. This is less disruptive than forcing a full page reload.

A retry cannot repair every failure. If PostgreSQL remains unavailable, the boundary will fail again and continue displaying the error interface.

## The Verification

First, verify the normal workspace still works:

```bash
curl --fail --silent http://localhost:3000/projects |
  grep --quiet "Website redesign"

echo "Normal database request succeeded."
```

Expected output:

```text
Normal database request succeeded.
```

Now test an actual database failure.

Stop PostgreSQL:

```bash
docker compose stop db
```

Open or refresh:

```text
http://localhost:3000/projects
```

The workspace error interface should display:

```text
LaunchPad could not load this information.
```

The development terminal should contain the underlying database connection error.

Restart PostgreSQL:

```bash
docker compose start db
```

Wait for it to become healthy:

```bash
docker compose ps
```

Then select **Try again** in the browser.

The project list should render successfully.

Verify PostgreSQL readiness:

```bash
docker compose exec db \
  pg_isready \
  --username=launchpad \
  --dbname=launchpad
```

Expected output includes:

```text
accepting connections
```

Run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 5, Step 13: Workspace Error Boundary] [STARTING: Part 5, Step 14: Loading and Error Styles]

---

# Step 14: Style Loading and Error States

## The Target

Add accessible visual treatment for skeleton loading interfaces and unexpected workspace errors.

## The Concept

A skeleton is a temporary shape that resembles the content being loaded.

A good loading state should:

- Preserve approximately the final layout
- Avoid pretending that placeholder values are real
- Communicate that the region is busy
- Respect reduced-motion preferences

An error interface should:

- State what failed in everyday language
- Avoid leaking technical details
- Give the user a recovery action
- Remain readable on narrow screens

## The Implementation

Append the following styles to the end of:

### `src/app/globals.css`

```css
/* Part 5: database loading and error states */

.skeleton-card {
  pointer-events: none;
}

.skeleton-line {
  display: block;
  width: 100%;
  height: 0.85rem;
  border-radius: 999rem;
  background:
    linear-gradient(
      90deg,
      var(--color-surface-subtle) 25%,
      #ffffff 50%,
      var(--color-surface-subtle) 75%
    );
  background-size: 200% 100%;
  animation: skeleton-shimmer 1.5s linear infinite;
}

.skeleton-line + .skeleton-line {
  margin-top: 0.8rem;
}

.skeleton-line--short {
  width: 40%;
}

.skeleton-line--heading {
  width: min(75%, 22rem);
  height: 1.5rem;
}

.skeleton-line--large {
  width: 35%;
  height: 3.5rem;
}

.error-panel {
  max-width: 44rem;
  margin-inline: auto;
  padding: clamp(1.5rem, 5vw, 3rem);
  border: 0.0625rem solid #efb5b5;
  border-left: 0.35rem solid #a32626;
  border-radius: 1rem;
  background: #fff5f5;
  box-shadow: var(--shadow-card);
}

.error-panel h1 {
  margin: 0;
  font-size: clamp(2rem, 5vw, 3.25rem);
  line-height: 1.1;
  letter-spacing: -0.04em;
}

.error-panel > p:not(.eyebrow, .error-reference) {
  margin: 1rem 0 1.5rem;
  color: var(--color-text-muted);
}

.error-reference {
  margin: 1.25rem 0 0;
  color: var(--color-text-muted);
  font-size: 0.85rem;
}

.error-reference code {
  overflow-wrap: anywhere;
}

@keyframes skeleton-shimmer {
  from {
    background-position: 200% 0;
  }

  to {
    background-position: -200% 0;
  }
}

@media (prefers-reduced-motion: reduce) {
  .skeleton-line {
    animation: none;
    background: var(--color-surface-subtle);
  }
}
```

## The Verification

Open:

```text
http://localhost:3000/dashboard
```

Using browser network throttling, confirm that:

- Skeletons approximately preserve the dashboard layout.
- Placeholder lines are visually distinct from real text.
- Final content replaces the loading interface.

Enable reduced motion in your operating system or browser developer tools.

Confirm that skeleton shimmer animation stops.

Repeat the database-failure test:

```bash
docker compose stop db
```

Refresh:

```text
http://localhost:3000/dashboard
```

Confirm that the error panel:

- Uses a clear visual boundary
- Displays a retry button
- Does not display a raw SQL or connection error
- Remains readable on a narrow screen

Restart the database:

```bash
docker compose start db
```

Run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 5, Step 14: Loading and Error Styles] [STARTING: Part 5, Step 15: Remove the Temporary Catalog]

---

# Step 15: Remove the Temporary In-Memory Catalog

## The Target

Remove `project-catalog.ts` after confirming every route now uses PostgreSQL.

## The Concept

A migration is not complete while two competing data sources remain.

Leaving the temporary catalog in place could cause future developers to:

- Import stale sample data accidentally
- Update one source but not the other
- Misunderstand which records are authoritative
- Reintroduce build-time assumptions

PostgreSQL is now the **source of truth**. A source of truth is the authoritative location from which current application data is read.

## The Implementation

Search for remaining catalog imports:

```bash
grep -R \
  'project-catalog' \
  src \
  --include="*.ts" \
  --include="*.tsx" || true
```

The dashboard may still import it if its page was not replaced exactly. The command must produce no matches before deletion.

Remove the old module.

macOS, Linux, or Git Bash:

```bash
rm src/lib/project-catalog.ts
```

PowerShell:

```powershell
Remove-Item src/lib/project-catalog.ts
```

Search for the old URL slugs:

```bash
grep -R \
  'website-redesign\|mobile-application\|documentation-hub\|analytics-dashboard' \
  src \
  --include="*.ts" \
  --include="*.tsx" || true
```

No source file should depend on those former route identifiers.

The database project URLs now use UUIDs, for example:

```text
/projects/10000000-0000-4000-8000-000000000001
```

## The Verification

Run:

```bash
npx tsc --noEmit
npm run lint
```

Verify that the old file is absent:

```bash
test ! -f src/lib/project-catalog.ts &&
  echo "Temporary catalog removed."
```

Expected output:

```text
Temporary catalog removed.
```

PowerShell:

```powershell
if (Test-Path src/lib/project-catalog.ts) {
  throw "Temporary catalog still exists."
}

Write-Output "Temporary catalog removed."
```

Verify that PostgreSQL remains the source for the page:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    UPDATE projects
    SET name = 'Website redesign verification'
    WHERE id = '10000000-0000-4000-8000-000000000001';
  "
```

Refresh:

```text
http://localhost:3000/projects
```

The page should display:

```text
Website redesign verification
```

Restore repeatable development data by rerunning the seed:

```bash
docker compose exec -T db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --set=ON_ERROR_STOP=1 \
  < database/seeds/development.sql
```

Refresh again. The name should return to:

```text
Website redesign
```

This test proves that the interface reads from PostgreSQL rather than a compiled TypeScript array.

[GENERATED: Part 5, Step 15: Temporary Catalog Removal] [STARTING: Part 5, Step 16: Database Scripts]

---

# Step 16: Add Repeatable Database Commands

## The Target

Add npm scripts for starting, stopping, migrating, seeding, and inspecting the development database.

## The Concept

Long commands are easy to mistype and difficult for a team to remember.

Project scripts create one documented interface:

```text
npm run db:start
npm run db:migrate
npm run db:seed
```

The commands become part of the project’s operational contract.

We will use shell redirection in the migration and seed scripts. These particular scripts are portable across macOS, Linux, WSL, and Git Bash. Native PowerShell users can continue using the commands shown earlier or invoke the scripts from Git Bash.

## The Implementation

Open `package.json` and replace only its `"scripts"` object with the following complete object.

### `package.json` — `"scripts"`

```json
{
  "scripts": {
    "dev": "next dev --turbopack",
    "build": "next build",
    "start": "next start",
    "lint": "eslint",
    "typecheck": "tsc --noEmit",
    "db:start": "docker compose up --detach db",
    "db:stop": "docker compose stop db",
    "db:status": "docker compose ps",
    "db:migrate": "docker compose exec -T db psql --username=launchpad --dbname=launchpad --set=ON_ERROR_STOP=1 < database/migrations/001_create_projects_and_tasks.sql",
    "db:seed": "docker compose exec -T db psql --username=launchpad --dbname=launchpad --set=ON_ERROR_STOP=1 < database/seeds/development.sql",
    "db:shell": "docker compose exec db psql --username=launchpad --dbname=launchpad"
  }
}
```

Do not replace the rest of `package.json`. Keep its generated dependencies and development dependencies.

### Important migration limitation

The current migration creates tables and is intentionally run once on a new database.

Running it again against the same database will fail with:

```text
relation "projects" already exists
```

That failure is useful: silently ignoring migration state can hide deployment mistakes.

A production migration system should record which migrations have been applied. We will address production migration workflow in Part 10.

### Test the scripts against a clean local database if desired

The destructive reset command below deletes the development volume and all local database data:

```bash
docker compose down --volumes
```

Then rebuild the local database:

```bash
npm run db:start
npm run db:migrate
npm run db:seed
```

Do not run `docker compose down --volumes` if your local database contains work you need to preserve.

## The Verification

Run:

```bash
npm run typecheck
npm run lint
npm run db:status
```

Expected database status includes:

```text
healthy
```

Verify the seeded counts:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      (SELECT COUNT(*) FROM projects) AS projects,
      (SELECT COUNT(*) FROM tasks) AS tasks;
  "
```

Expected result:

```text
4 | 12
```

[GENERATED: Part 5, Step 16: Database Scripts] [STARTING: Part 5, Step 17: End-to-End Data Verification]

---

# Step 17: Verify Data Fetching End to End

## The Target

Systematically verify database state, route output, filters, project lookup, missing resources, and error recovery.

## The Concept

Data fetching crosses several boundaries:

```text
PostgreSQL schema
        ↓
Seed records
        ↓
SQL query
        ↓
Runtime schema validation
        ↓
Server Component
        ↓
Client Component props
        ↓
Rendered browser interface
```

A successful page proves only that one path worked. We will verify each important outcome.

## The Implementation

Make sure both services are available:

```bash
npm run db:start
npm run dev
```

Open a second terminal.

### Verify database records

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --tuples-only \
  --no-align \
  --command="
    SELECT COUNT(*) FROM projects;
    SELECT COUNT(*) FROM tasks;
  "
```

Expected output:

```text
4
12
```

### Verify successful pages

```bash
for path in \
  "/dashboard" \
  "/projects" \
  "/projects?status=ACTIVE" \
  "/projects/10000000-0000-4000-8000-000000000001"
do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000${path}"
  )"

  printf "%-70s %s\n" "${path}" "${status_code}"
done
```

Every route should return:

```text
200
```

### Verify project counts and content

```bash
projects_page="$(
  curl --fail --silent http://localhost:3000/projects
)"

for project_name in \
  "Website redesign" \
  "Mobile application" \
  "Documentation hub" \
  "Analytics dashboard"
do
  printf "%s" "${projects_page}" |
    grep --quiet "${project_name}"

  echo "Found project: ${project_name}"
done
```

Expected output lists all four names.

### Verify server-side status filtering

```bash
completed_page="$(
  curl --fail --silent \
    "http://localhost:3000/projects?status=COMPLETED"
)"

printf "%s" "${completed_page}" |
  grep --quiet "Documentation hub"

if printf "%s" "${completed_page}" |
  grep --quiet "Website redesign"; then
  echo "Completed filter returned an active project."
  exit 1
fi

echo "Completed status filter verified."
```

### Verify invalid URL input

```bash
invalid_filter_page="$(
  curl --fail --silent \
    "http://localhost:3000/projects?status=INVALID"
)"

printf "%s" "${invalid_filter_page}" |
  grep --quiet "The requested status is not supported"

echo "Invalid filter handling verified."
```

### Verify dynamic project lookup

```bash
project_page="$(
  curl --fail --silent \
    http://localhost:3000/projects/10000000-0000-4000-8000-000000000001
)"

printf "%s" "${project_page}" |
  grep --quiet "Website redesign"

printf "%s" "${project_page}" |
  grep --quiet "2 of 4 tasks are complete"

echo "Dynamic database project verified."
```

### Verify not-found behavior

```bash
for project_id in \
  "not-a-uuid" \
  "99999999-9999-4999-8999-999999999999"
do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000/projects/${project_id}"
  )"

  if [ "${status_code}" != "404" ]; then
    echo "Expected 404 for ${project_id}, received ${status_code}."
    exit 1
  fi

  echo "Not-found behavior verified: ${project_id}"
done
```

## The Verification

The commands above are the primary verification.

Also complete these browser checks:

1. Open `/dashboard`.
2. Confirm database metrics appear.
3. Navigate to `/projects`.
4. Apply each status filter.
5. Use immediate client-side text search.
6. Open a UUID-based project route.
7. Use the copy-link button.
8. Open and close the disclosures.
9. Navigate backward and forward.
10. Confirm loading and error interfaces preserve the workspace shell.

Finally, run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 5, Step 17: End-to-End Data Verification] [STARTING: Part 5, Step 18: Production Build]

---

# Step 18: Verify the Production Build

## The Target

Build and run LaunchPad in production mode with PostgreSQL available.

## The Concept

A production build may execute server code while analyzing routes. Any server-rendered route that depends on PostgreSQL must have valid environment configuration and database connectivity available when required.

The production environment therefore needs:

- `DATABASE_URL`
- Applied migrations
- Reachable PostgreSQL
- Valid records or support for an empty database
- Sufficient connection capacity

Our local production test uses `.env.local` and the Docker database.

## The Implementation

Stop the development server:

```text
Ctrl+C
```

Confirm PostgreSQL is healthy:

```bash
npm run db:status
```

Run the complete production quality gate:

```bash
npm run typecheck
npm run lint
npm run build
```

The build should identify the database-backed workspace routes as dynamic where request-time data is required.

Start the production server:

```bash
npm run start
```

## The Verification

In another terminal:

```bash
for path in \
  "/" \
  "/about" \
  "/dashboard" \
  "/projects" \
  "/projects?status=ACTIVE" \
  "/projects/10000000-0000-4000-8000-000000000001"
do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000${path}"
  )"

  printf "%-70s %s\n" "${path}" "${status_code}"
done
```

Every known route should return:

```text
200
```

Verify production database content:

```bash
curl --fail --silent http://localhost:3000/dashboard |
  grep --quiet "12"

curl --fail --silent http://localhost:3000/projects |
  grep --quiet "Documentation hub"

echo "Production database rendering verified."
```

Expected output:

```text
Production database rendering verified.
```

Verify missing resources:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/projects/not-a-uuid
```

Expected output:

```text
404
```

Open:

```text
http://localhost:3000/projects
```

Confirm the client-side search still works in production mode.

Stop the production server:

```text
Ctrl+C
```

[GENERATED: Part 5, Step 18: Production Build] [STARTING: Part 5, Step 19: Git Checkpoint]

---

# Step 19: Create the Part 5 Git Checkpoint

## The Target

Commit the database, data-fetching, streaming, loading, and error-boundary work.

## The Concept

This checkpoint records the transition from temporary data to persistent infrastructure.

The commit should contain:

- `compose.yaml`
- SQL migration
- Development seed
- Safe environment example
- New dependencies
- Environment validation
- Database client
- Query layer
- Runtime schemas
- Database-backed pages
- Streaming dashboard components
- Loading interfaces
- Error boundary
- Styles
- Removal of the temporary catalog

It must not contain:

```text
.env.local
```

## The Implementation

Inspect repository status:

```bash
git status
```

Explicitly verify that `.env.local` is ignored:

```bash
git check-ignore .env.local
```

Review changes:

```bash
git diff --stat
git diff
```

Run the final quality gate:

```bash
npm run typecheck
npm run lint
npm run build
```

Stage the changes:

```bash
git add \
  .env.example \
  compose.yaml \
  database \
  package.json \
  package-lock.json \
  src
```

Inspect staged files:

```bash
git status --short
git diff --cached --stat
```

Confirm `.env.local` is absent.

Create the commit:

```bash
git commit -m "feat: add PostgreSQL data fetching and streaming"
```

## The Verification

Inspect the latest commit:

```bash
git log -1 --oneline
```

Expected output resembles:

```text
b2c3d4e feat: add PostgreSQL data fetching and streaming
```

Confirm a clean working tree:

```bash
git status
```

Expected output:

```text
nothing to commit, working tree clean
```

The database container and volume are not Git files. They may remain running after the commit.

[GENERATED: Part 5, Step 19: Git Checkpoint] [STARTING: Part 5 Reference Sections]

---

# Part 5 Reference A: Data-Fetching Locations

Next.js applications can fetch data in several server-side locations.

## Server Components

Use Server Components when data directly supports rendered interface content:

```tsx
export default async function ProjectsPage() {
  const projects = await getProjects();

  return <ProjectList projects={projects} />;
}
```

Benefits include:

- Data access remains server-side.
- The initial response contains useful content.
- Private credentials remain out of browser code.
- No client-side loading effect is required.

## Route Handlers

Use Route Handlers when an explicit HTTP interface is needed:

```text
app/api/projects/route.ts
```

Examples include:

- Third-party integrations
- Webhooks
- Public or private JSON APIs
- Health checks
- Non-React clients

Route Handlers arrive in Part 7.

## Server Actions

Use Server Actions for server-side mutations connected to Next.js interfaces:

- Creating a project
- Updating a task
- Archiving a record

Server Actions also arrive in Part 7.

## Client Components

Client Components may fetch browser-specific or highly interactive data, but they should not receive database credentials or import server query modules.

For LaunchPad’s main records, server-side fetching remains the default.

---

# Part 5 Reference B: Static and Dynamic Rendering

## Static rendering

Static output is prepared ahead of requests and reused.

Good candidates include:

- Marketing content
- Documentation that changes infrequently
- Public product information

Benefits:

- Fast delivery
- Reduced server work
- Easy content distribution

Trade-off:

- Changes require revalidation or rebuilding.

## Dynamic rendering

Dynamic output is prepared with request-time information.

Good candidates include:

- Authenticated dashboards
- User-owned projects
- Request-specific data
- Frequently changing private records

Benefits:

- Fresh, request-aware output
- Appropriate security boundaries

Trade-off:

- Requires server and data-source work at request time.

## Streaming

Streaming sends ready route sections while slower sections continue rendering.

Benefits:

- Earlier meaningful feedback
- Independent loading boundaries
- Improved perceived performance

Trade-off:

- Requires thoughtful boundary placement.
- Does not make slow queries intrinsically faster.
- Too many boundaries can create visual instability.

---

# Part 5 Reference C: Request Memoization Versus Persistent Caching

These concepts are related but not identical.

## Request-level memoization

Our detail lookup uses:

```ts
export const getProjectById = cache(async (projectId: string) => {
  // Query PostgreSQL.
});
```

During one server-rendering request, identical calls can share the same result.

This is useful when:

- `generateMetadata` needs a project.
- The page needs the same project.
- Both use the same function and argument.

The result should not be assumed to remain cached across unrelated requests.

## Persistent cross-request caching

A persistent cache reuses results among multiple requests and may survive longer than one render.

That requires deliberate policy:

- Which users may share the result?
- How stale may it become?
- Which mutation invalidates it?
- Is the result public or private?
- Does the cache key include identity and filters?

We postpone persistent database caching until mutations and authorization make those answers concrete.

---

# Part 5 Reference D: PostgreSQL Relationships

LaunchPad currently has:

```text
projects
    1
    │
    │ owns
    │
    many
tasks
```

Each task contains:

```sql
project_id UUID NOT NULL
```

The foreign key requires the project to exist:

```sql
FOREIGN KEY (project_id)
REFERENCES projects(id)
```

Deletion cascades:

```sql
ON DELETE CASCADE
```

This means deleting one project removes its dependent tasks in the same database operation.

Database constraints protect data even if a future script, API, or application bug bypasses ordinary interface validation.

---

# Part 5 Reference E: Parameterized SQL

Never construct SQL by concatenating untrusted input.

Unsafe:

```ts
const result = await database.unsafe(
  `SELECT * FROM projects WHERE id = '${projectId}'`,
);
```

Safe tagged template:

```ts
const rows = await database`
  SELECT *
  FROM projects
  WHERE id = ${projectId}
`;
```

The driver separates SQL instructions from values.

Parameterized queries help prevent SQL injection, but application validation is still required for:

- Meaningful error handling
- Business rules
- Length restrictions
- Allowed enumerations
- Correct data types

Security controls work in layers.

---

# Part 5 Reference F: Runtime Validation

TypeScript types disappear when JavaScript runs.

This declaration:

```ts
type ProjectStatus = "PLANNED" | "ACTIVE" | "COMPLETED";
```

does not inspect database data at runtime.

Zod does:

```ts
const schema = z.object({
  status: z.enum([
    "PLANNED",
    "ACTIVE",
    "COMPLETED",
  ]),
});
```

If the database result violates the expected contract, parsing throws an error. The nearest error boundary can display a safe failure interface while developers investigate the mismatch.

Use runtime validation at trust and transformation boundaries, including:

- Environment variables
- HTTP request bodies
- Form data
- External API responses
- Database rows when schema drift is a meaningful risk

---

# Part 5 Reference G: Suspense Boundary Placement

A Suspense boundary is useful when its child can complete independently.

Good:

```tsx
<Suspense fallback={<MetricsSkeleton />}>
  <DashboardMetrics />
</Suspense>

<Suspense fallback={<ProjectsSkeleton />}>
  <ActiveProjects />
</Suspense>
```

The sections use separate queries and can stream separately.

Less useful:

```tsx
<Suspense fallback={<TinySpinner />}>
  <StaticHeading />
</Suspense>
```

The heading performs no asynchronous work.

Avoid wrapping every small component in Suspense. Boundaries should correspond to meaningful visual and data-loading units.

---

# Part 5 Reference H: Loading Versus Error Versus Empty States

These states communicate different conditions.

## Loading

The result is not ready yet:

```text
Retrieving projects…
```

Use:

- `loading.tsx`
- Suspense fallbacks
- `aria-busy="true"`

## Error

The operation failed unexpectedly:

```text
LaunchPad could not load this information.
```

Use:

- `error.tsx`
- Safe user-facing messages
- Logging or monitoring
- Retry when useful

## Empty

The operation succeeded but returned no matching records:

```text
No active projects
```

Use normal page content, not an error boundary.

## Invalid input

The user supplied unsupported input:

```text
The requested status is not supported.
```

Use validation feedback, not a system-error interface.

Distinguishing these conditions produces clearer interfaces and more maintainable code.

---

# Part 5 Reference I: Development Database Lifecycle

## Start the database

```bash
npm run db:start
```

## Inspect status

```bash
npm run db:status
```

## Open PostgreSQL shell

```bash
npm run db:shell
```

Exit with:

```text
\q
```

## Stop without deleting data

```bash
npm run db:stop
```

The Docker volume remains.

## Stop containers and delete development data

```bash
docker compose down --volumes
```

This is destructive.

## Recreate from scratch

```bash
npm run db:start
npm run db:migrate
npm run db:seed
```

---

# Part 5 Reference J: Environment Variable Rules

## Server-only variable

```dotenv
DATABASE_URL=postgresql://...
```

Use it only from protected server modules.

## Browser-exposed variable

```dotenv
NEXT_PUBLIC_ANALYTICS_SITE_ID=...
```

A `NEXT_PUBLIC_` variable may be included in browser assets. It must never contain a secret.

## Local secrets

Store local private values in:

```text
.env.local
```

Ensure Git ignores it.

## Documented examples

Commit safe placeholder or local-development values in:

```text
.env.example
```

Never copy production secrets into an example file.

---

# Part 5 Reference K: Production Database Considerations

The local Docker database is for development only.

A production PostgreSQL deployment needs:

- Managed or carefully operated infrastructure
- Encrypted network connections
- Unique strong credentials
- Restricted network access
- Automated backups
- Restore testing
- Migration tracking
- Connection limits
- Monitoring
- Storage growth alerts
- High-availability decisions
- A rollback strategy

The production application should receive `DATABASE_URL` from a secret manager or deployment platform.

Do not deploy the development password:

```text
launchpad-development-password
```

---

# Part 5 Reference L: Current Project Structure

After Part 5, the important structure is:

```text
launchpad/
├── database/
│   ├── migrations/
│   │   └── 001_create_projects_and_tasks.sql
│   └── seeds/
│       └── development.sql
├── src/
│   ├── app/
│   │   └── (workspace)/
│   │       ├── dashboard/
│   │       │   ├── loading.tsx
│   │       │   └── page.tsx
│   │       ├── projects/
│   │       │   ├── [projectId]/
│   │       │   │   └── page.tsx
│   │       │   ├── loading.tsx
│   │       │   └── page.tsx
│   │       ├── error.tsx
│   │       └── layout.tsx
│   ├── components/
│   │   ├── dashboard-active-projects.tsx
│   │   ├── dashboard-metrics.tsx
│   │   ├── dashboard-skeletons.tsx
│   │   ├── project-list.tsx
│   │   └── ...
│   └── lib/
│       ├── database/
│       │   ├── client.ts
│       │   ├── project-queries.ts
│       │   └── schemas.ts
│       ├── environment.ts
│       └── project-types.ts
├── .env.example
├── compose.yaml
├── package-lock.json
└── package.json
```

The old file is gone:

```text
src/lib/project-catalog.ts
```

The data flow is now:

```text
PostgreSQL
    ↓
database/client.ts
    ↓
database/project-queries.ts
    ↓
Async Server Components
    ↓
Serializable props
    ↓
Focused Client Components
```

---

# Part 5 Reference M: Common Data-Fetching Mistakes

## Mistake 1: Connecting to PostgreSQL from a Client Component

Incorrect:

```tsx
"use client";

import { database } from "@/lib/database/client";
```

The database client and connection URL must stay server-side.

## Mistake 2: Fetching initial page data in `useEffect`

Avoid this when a Server Component can load the data directly:

```tsx
"use client";

useEffect(() => {
  fetch("/api/projects");
}, []);
```

That pattern often creates:

1. An empty browser render
2. A JavaScript download
3. A second network request
4. Another render

Server Components can usually provide the initial content directly.

## Mistake 3: Concatenating SQL

Incorrect:

```ts
`WHERE status = '${status}'`
```

Use parameterized tagged templates.

## Mistake 4: Trusting a URL because TypeScript typed it

This remains untrusted:

```ts
const projectId: string = routeParameter;
```

Validate it before using it as a UUID.

## Mistake 5: Caching private data globally

A cache key that ignores user identity can expose one user’s result to another.

Caching policy must be designed with authentication and authorization.

## Mistake 6: Treating `noindex` as security

Crawler metadata does not protect database records.

## Mistake 7: Showing raw database errors

Do not render exception messages directly to users.

## Mistake 8: Running destructive seeds in production

The development seed begins by deleting records. It is not a production operation.

## Mistake 9: Assuming streaming makes SQL faster

Streaming improves delivery behavior. Query indexes, query design, connection health, and database capacity determine SQL performance.

---

# Part 5 Completion Checklist

Before continuing, confirm every item:

- [ ] Docker and Docker Compose are installed.
- [ ] PostgreSQL reports a healthy status.
- [ ] The initial migration creates `projects` and `tasks`.
- [ ] Database constraints and indexes exist.
- [ ] The seed creates 4 projects and 12 tasks.
- [ ] Rerunning the seed does not create duplicates.
- [ ] `.env.local` is ignored by Git.
- [ ] `.env.example` documents `DATABASE_URL`.
- [ ] Server environment values are validated with Zod.
- [ ] The database client is server-only.
- [ ] Query modules are server-only.
- [ ] SQL values use parameterized tagged templates.
- [ ] Database rows are validated at the query boundary.
- [ ] `/projects` reads PostgreSQL records.
- [ ] Status filtering happens on the server.
- [ ] Client-side text search still works.
- [ ] Project detail routes use UUIDs.
- [ ] Invalid UUIDs return `404`.
- [ ] Missing valid UUIDs return `404`.
- [ ] Metadata and page lookup share request-level memoization.
- [ ] Dashboard metrics come from PostgreSQL.
- [ ] Dashboard sections use separate Suspense boundaries.
- [ ] Dashboard and project loading interfaces render correctly.
- [ ] Unexpected database failures reach the workspace error boundary.
- [ ] Raw technical errors are not displayed to users.
- [ ] The temporary TypeScript catalog is removed.
- [ ] Database npm scripts work.
- [ ] `npm run typecheck` succeeds.
- [ ] `npm run lint` succeeds.
- [ ] `npm run build` succeeds while PostgreSQL is available.
- [ ] Production-mode database routes return `200`.
- [ ] Git contains the Part 5 checkpoint.
- [ ] `.env.local` is absent from the commit.
- [ ] `git status` reports a clean working tree.

LaunchPad now has a real persistence layer. You have implemented server-only database access, runtime-validated SQL results, async Server Components, streaming dashboard sections, loading states, and recoverable error handling.
