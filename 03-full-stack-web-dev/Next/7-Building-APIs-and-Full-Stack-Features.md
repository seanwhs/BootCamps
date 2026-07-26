# Part 7: Building APIs and Full-Stack Features

LaunchPad can now read projects and task totals from PostgreSQL. However, the application is still effectively read-only.

In this part, we will add the operations that change application data.

By the end of Part 7, LaunchPad will include:

- Shared input-validation schemas
- Project and task mutation queries
- JSON Route Handlers
- Standardized API error responses
- A project collection API
- Individual project API operations
- A health-check endpoint
- Server Actions for forms
- A project-creation page
- Task creation on project pages
- Task-status updates
- Accessible mutation feedback
- Cache and route revalidation
- Complete `curl` verification
- A production build checkpoint

Authentication and record ownership will arrive in Part 8. Until then, these mutation routes are suitable only for local development and controlled environments.

---

# Step 1: Design the Mutation Architecture

## The Target

Understand how browser forms, Server Actions, Route Handlers, validation, database mutations, and revalidation fit together.

## The Concept

A **mutation** is an operation that changes persistent data.

Examples include:

- Creating a project
- Updating a project
- Deleting a project
- Creating a task
- Changing task status

LaunchPad will support two server entry points.

### Server Actions

Server Actions are appropriate when a Next.js interface submits a mutation directly.

```text
Browser form
    ↓
Server Action
    ↓
Validation
    ↓
Database mutation
    ↓
Route revalidation
    ↓
Updated interface
```

### Route Handlers

Route Handlers provide explicit HTTP endpoints.

```text
HTTP client
    ↓
POST /api/projects
    ↓
JSON validation
    ↓
Database mutation
    ↓
JSON response
```

They are useful for:

- Mobile clients
- Third-party integrations
- Automated scripts
- Webhooks
- Explicit JSON APIs

Both entry points will call the same validation and database layers. We will not duplicate business rules inside every route.

## The Implementation

No files change in this planning step.

The architecture will become:

```text
src/
├── app/
│   ├── (workspace)/
│   │   └── projects/
│   │       ├── [projectId]/
│   │       │   ├── actions.ts
│   │       │   └── page.tsx
│   │       ├── new/
│   │       │   └── page.tsx
│   │       └── actions.ts
│   └── api/
│       ├── health/
│       │   └── route.ts
│       └── projects/
│           ├── [projectId]/
│           │   └── route.ts
│           └── route.ts
├── components/
│   ├── create-project-form.tsx
│   ├── create-task-form.tsx
│   └── task-list.tsx
└── lib/
    ├── database/
    │   ├── project-mutations.ts
    │   ├── project-queries.ts
    │   └── schemas.ts
    ├── api-response.ts
    ├── action-state.ts
    ├── project-inputs.ts
    └── task-types.ts
```

## The Verification

Run the current quality gate:

```bash
npm run typecheck
npm run lint
npm run build
```

Confirm the database is healthy:

```bash
npm run db:start
npm run db:status
```

[GENERATED: Part 7, Step 1: Mutation Architecture] [STARTING: Part 7, Step 2: Shared Input Schemas]

---

# Step 2: Create Shared Input-Validation Schemas

## The Target

Define reusable runtime schemas for project and task mutations.

## The Concept

Input can arrive through several doors:

- HTML form data
- JSON request bodies
- URL parameters
- External integrations

Every door must lead through validation before reaching the database.

We will use Zod schemas as the shared rulebook.

A schema will enforce requirements such as:

- Project names cannot be blank.
- Project names cannot exceed the database column length.
- Status values must be supported.
- Task titles cannot exceed their database column length.
- Empty optional descriptions become `null`.

Client-side HTML constraints improve feedback, but the server schemas remain authoritative.

## The Implementation

Create task types.

### `src/lib/task-types.ts`

```ts
export const TASK_STATUSES = [
  "TODO",
  "IN_PROGRESS",
  "COMPLETED",
] as const;

export type TaskStatus = (typeof TASK_STATUSES)[number];

export const TASK_PRIORITIES = [
  "LOW",
  "MEDIUM",
  "HIGH",
] as const;

export type TaskPriority = (typeof TASK_PRIORITIES)[number];

export type Task = {
  id: string;
  projectId: string;
  title: string;
  description: string | null;
  status: TaskStatus;
  priority: TaskPriority;
  dueDate: string | null;
  createdAt: string;
  updatedAt: string;
};

export function formatTaskStatus(status: TaskStatus): string {
  const labels: Record<TaskStatus, string> = {
    TODO: "To do",
    IN_PROGRESS: "In progress",
    COMPLETED: "Completed",
  };

  return labels[status];
}

export function formatTaskPriority(
  priority: TaskPriority,
): string {
  const labels: Record<TaskPriority, string> = {
    LOW: "Low",
    MEDIUM: "Medium",
    HIGH: "High",
  };

  return labels[priority];
}
```

Create input schemas.

### `src/lib/project-inputs.ts`

```ts
import { z } from "zod";

import { PROJECT_STATUSES } from "@/lib/project-types";
import {
  TASK_PRIORITIES,
  TASK_STATUSES,
} from "@/lib/task-types";

/**
 * Trimming belongs in the schema so every caller receives normalized values.
 */
export const createProjectInputSchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, "Enter a project name.")
    .max(120, "Project names must contain at most 120 characters."),
  description: z
    .string()
    .trim()
    .min(1, "Enter a project description.")
    .max(
      2_000,
      "Project descriptions must contain at most 2,000 characters.",
    ),
  status: z.enum(PROJECT_STATUSES),
});

export const updateProjectInputSchema =
  createProjectInputSchema.partial().refine(
    (value) => Object.keys(value).length > 0,
    {
      message: "Provide at least one project field to update.",
    },
  );

export const createTaskInputSchema = z.object({
  title: z
    .string()
    .trim()
    .min(1, "Enter a task title.")
    .max(160, "Task titles must contain at most 160 characters."),
  description: z
    .string()
    .trim()
    .max(
      2_000,
      "Task descriptions must contain at most 2,000 characters.",
    )
    .transform((value) => (value.length === 0 ? null : value)),
  priority: z.enum(TASK_PRIORITIES),
  dueDate: z
    .string()
    .trim()
    .refine(
      (value) =>
        value.length === 0 ||
        /^\d{4}-\d{2}-\d{2}$/.test(value),
      "Due dates must use the YYYY-MM-DD format.",
    )
    .transform((value) => (value.length === 0 ? null : value)),
});

export const updateTaskStatusInputSchema = z.object({
  status: z.enum(TASK_STATUSES),
});

export type CreateProjectInput = z.infer<
  typeof createProjectInputSchema
>;

export type UpdateProjectInput = z.infer<
  typeof updateProjectInputSchema
>;

export type CreateTaskInput = z.infer<
  typeof createTaskInputSchema
>;

export type UpdateTaskStatusInput = z.infer<
  typeof updateTaskStatusInputSchema
>;
```

### Why schema lengths match database columns

The database defines:

```sql
name VARCHAR(120)
title VARCHAR(160)
```

Validation uses the same maximum lengths.

This gives users clear feedback before PostgreSQL rejects an oversized value.

The database constraint remains necessary because another program could bypass this Next.js application.

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

Confirm all enum values appear:

```bash
grep -E \
  '"TODO"|"IN_PROGRESS"|"COMPLETED"|"LOW"|"MEDIUM"|"HIGH"' \
  src/lib/task-types.ts
```

[GENERATED: Part 7, Step 2: Shared Input Schemas] [STARTING: Part 7, Step 3: Database Schemas and Queries]

---

# Step 3: Add Task Result Schemas and Queries

## The Target

Validate task rows and add database queries for project tasks and database health.

## The Concept

Mutations need to return dependable records, just like read queries.

PostgreSQL dates and timestamps require deliberate conversion:

- A task due date becomes `YYYY-MM-DD`.
- Timestamps become ISO-compatible strings.
- Nullable fields remain explicitly `null`.

We will perform these conversions in SQL aliases so the application receives stable JSON-friendly values.

## The Implementation

Completely replace the database schema module.

### `src/lib/database/schemas.ts`

```ts
import { z } from "zod";

import { PROJECT_STATUSES } from "@/lib/project-types";
import {
  TASK_PRIORITIES,
  TASK_STATUSES,
} from "@/lib/task-types";

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

export const taskSchema = z.object({
  id: z.string().uuid(),
  projectId: z.string().uuid(),
  title: z.string().min(1),
  description: z.string().nullable(),
  status: z.enum(TASK_STATUSES),
  priority: z.enum(TASK_PRIORITIES),
  dueDate: z.string().nullable(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const taskListSchema = z.array(taskSchema);

export type DashboardMetrics = z.infer<
  typeof dashboardMetricsSchema
>;
```

Append the following imports and function to the existing query module.

### `src/lib/database/project-queries.ts` — add to imports

```ts
import {
  taskListSchema,
} from "@/lib/database/schemas";
import type { Task } from "@/lib/task-types";
```

The existing file already imports other values from `database/schemas`. Merge `taskListSchema` into that existing import instead of creating duplicate imports.

Append this function to the end of the file:

```ts
export async function getTasksForProject(
  projectId: string,
): Promise<Task[]> {
  const rows = await database<Task[]>`
    SELECT
      id,
      project_id AS "projectId",
      title,
      description,
      status,
      priority,
      to_char(due_date, 'YYYY-MM-DD') AS "dueDate",
      created_at::text AS "createdAt",
      updated_at::text AS "updatedAt"
    FROM tasks
    WHERE project_id = ${projectId}
    ORDER BY
      CASE status
        WHEN 'IN_PROGRESS' THEN 1
        WHEN 'TODO' THEN 2
        WHEN 'COMPLETED' THEN 3
      END,
      due_date ASC NULLS LAST,
      created_at ASC
  `;

  return taskListSchema.parse(rows);
}
```

Create a small health query module.

### `src/lib/database/health.ts`

```ts
import "server-only";

import { database } from "@/lib/database/client";

export async function checkDatabaseHealth(): Promise<void> {
  await database`SELECT 1`;
}
```

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

Verify the task query directly in PostgreSQL:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT title, status, priority
    FROM tasks
    WHERE project_id =
      '10000000-0000-4000-8000-000000000001'
    ORDER BY created_at;
  "
```

Expected output contains four Website redesign tasks.

[GENERATED: Part 7, Step 3: Task Queries] [STARTING: Part 7, Step 4: Database Mutations]

---

# Step 4: Create the Database Mutation Layer

## The Target

Implement server-only functions for creating, updating, and deleting projects and for creating and updating tasks.

## The Concept

Route Handlers and Server Actions should not contain raw SQL.

A dedicated mutation layer provides one location for:

- Parameterized SQL
- Return-value validation
- Missing-record handling
- Timestamp updates
- Transaction boundaries when needed

This resembles a service counter. Different customers may arrive through different entrances, but the same trained staff performs the actual operation.

## The Implementation

Create the mutation module.

### `src/lib/database/project-mutations.ts`

```ts
import "server-only";

import { database } from "@/lib/database/client";
import {
  projectSummarySchema,
  taskSchema,
} from "@/lib/database/schemas";
import type {
  CreateProjectInput,
  CreateTaskInput,
  UpdateProjectInput,
  UpdateTaskStatusInput,
} from "@/lib/project-inputs";
import type { ProjectSummary } from "@/lib/project-types";
import type { Task } from "@/lib/task-types";

type ProjectMutationRow = {
  id: string;
  name: string;
  description: string;
  status: ProjectSummary["status"];
  taskCount: number;
  completedTaskCount: number;
};

async function readProjectAfterMutation(
  projectId: string,
): Promise<ProjectSummary | null> {
  const rows = await database<ProjectMutationRow[]>`
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

  return row ? projectSummarySchema.parse(row) : null;
}

export async function createProject(
  input: CreateProjectInput,
): Promise<ProjectSummary> {
  const rows = await database<{ id: string }[]>`
    INSERT INTO projects (
      name,
      description,
      status
    )
    VALUES (
      ${input.name},
      ${input.description},
      ${input.status}
    )
    RETURNING id
  `;

  const projectId = rows[0]?.id;

  if (!projectId) {
    throw new Error("The project insert returned no identifier.");
  }

  const project = await readProjectAfterMutation(projectId);

  if (!project) {
    throw new Error("The created project could not be read.");
  }

  return project;
}

export async function updateProject(
  projectId: string,
  input: UpdateProjectInput,
): Promise<ProjectSummary | null> {
  const rows = await database<{ id: string }[]>`
    UPDATE projects
    SET
      name = COALESCE(${input.name ?? null}, name),
      description = COALESCE(
        ${input.description ?? null},
        description
      ),
      status = COALESCE(${input.status ?? null}, status),
      updated_at = CURRENT_TIMESTAMP
    WHERE id = ${projectId}
    RETURNING id
  `;

  if (!rows[0]) {
    return null;
  }

  return readProjectAfterMutation(projectId);
}

export async function deleteProject(
  projectId: string,
): Promise<boolean> {
  const rows = await database<{ id: string }[]>`
    DELETE FROM projects
    WHERE id = ${projectId}
    RETURNING id
  `;

  return rows.length === 1;
}

export async function createTask(
  projectId: string,
  input: CreateTaskInput,
): Promise<Task | null> {
  const rows = await database<Task[]>`
    INSERT INTO tasks (
      project_id,
      title,
      description,
      priority,
      due_date
    )
    SELECT
      p.id,
      ${input.title},
      ${input.description},
      ${input.priority},
      ${input.dueDate}
    FROM projects AS p
    WHERE p.id = ${projectId}
    RETURNING
      id,
      project_id AS "projectId",
      title,
      description,
      status,
      priority,
      to_char(due_date, 'YYYY-MM-DD') AS "dueDate",
      created_at::text AS "createdAt",
      updated_at::text AS "updatedAt"
  `;

  const row = rows[0];

  if (!row) {
    return null;
  }

  await database`
    UPDATE projects
    SET updated_at = CURRENT_TIMESTAMP
    WHERE id = ${projectId}
  `;

  return taskSchema.parse(row);
}

export async function updateTaskStatus(
  projectId: string,
  taskId: string,
  input: UpdateTaskStatusInput,
): Promise<Task | null> {
  const rows = await database<Task[]>`
    UPDATE tasks
    SET
      status = ${input.status},
      updated_at = CURRENT_TIMESTAMP
    WHERE id = ${taskId}
      AND project_id = ${projectId}
    RETURNING
      id,
      project_id AS "projectId",
      title,
      description,
      status,
      priority,
      to_char(due_date, 'YYYY-MM-DD') AS "dueDate",
      created_at::text AS "createdAt",
      updated_at::text AS "updatedAt"
  `;

  const row = rows[0];

  if (!row) {
    return null;
  }

  await database`
    UPDATE projects
    SET updated_at = CURRENT_TIMESTAMP
    WHERE id = ${projectId}
  `;

  return taskSchema.parse(row);
}
```

### Why task creation uses `INSERT ... SELECT`

This statement inserts only when the project exists:

```sql
INSERT INTO tasks (...)
SELECT ...
FROM projects
WHERE projects.id = ...
```

If no project matches, no task is inserted and the function returns `null`.

### Why task status checks both IDs

The update requires:

```sql
WHERE id = taskId
  AND project_id = projectId
```

This prevents a task from being updated through an unrelated project route.

Part 8 will add the authenticated owner condition to this same boundary.

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

Confirm every SQL value is parameterized:

```bash
grep -n '\${' src/lib/database/project-mutations.ts
```

Review the output and confirm expressions appear inside `database` tagged templates rather than concatenated strings.

[GENERATED: Part 7, Step 4: Database Mutations] [STARTING: Part 7, Step 5: API Response Utilities]

---

# Step 5: Standardize API Responses

## The Target

Create consistent JSON success and error response helpers.

## The Concept

An API is easier to consume when responses follow a predictable envelope.

Successful responses will use:

```json
{
  "data": {}
}
```

Errors will use:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The request body is invalid.",
    "details": []
  }
}
```

A stable error code is more useful to software clients than matching arbitrary human-readable sentences.

## The Implementation

Create the utility.

### `src/lib/api-response.ts`

```ts
import { NextResponse } from "next/server";
import type { ZodError } from "zod";

type ApiErrorCode =
  | "BAD_REQUEST"
  | "INVALID_JSON"
  | "VALIDATION_ERROR"
  | "NOT_FOUND"
  | "METHOD_NOT_ALLOWED"
  | "INTERNAL_ERROR"
  | "SERVICE_UNAVAILABLE";

export function apiSuccess<T>(
  data: T,
  init?: ResponseInit,
): NextResponse<{ data: T }> {
  return NextResponse.json(
    { data },
    init,
  );
}

export function apiError(
  status: number,
  code: ApiErrorCode,
  message: string,
  details?: unknown,
): NextResponse {
  return NextResponse.json(
    {
      error: {
        code,
        message,
        ...(details === undefined ? {} : { details }),
      },
    },
    { status },
  );
}

export function zodErrorDetails(error: ZodError) {
  return error.issues.map((issue) => ({
    path: issue.path.join("."),
    message: issue.message,
  }));
}

export async function readJsonBody(
  request: Request,
): Promise<
  | { success: true; data: unknown }
  | { success: false; response: NextResponse }
> {
  const contentType = request.headers.get("content-type");

  if (!contentType?.toLowerCase().includes("application/json")) {
    return {
      success: false,
      response: apiError(
        400,
        "BAD_REQUEST",
        "Content-Type must be application/json.",
      ),
    };
  }

  try {
    return {
      success: true,
      data: await request.json(),
    };
  } catch {
    return {
      success: false,
      response: apiError(
        400,
        "INVALID_JSON",
        "The request body is not valid JSON.",
      ),
    };
  }
}
```

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

The helper is not publicly reachable yet. Route Handlers will use it next.

[GENERATED: Part 7, Step 5: API Response Utilities] [STARTING: Part 7, Step 6: Project Collection API]

---

# Step 6: Build the Project Collection Route Handler

## The Target

Create:

```text
GET /api/projects
POST /api/projects
```

## The Concept

A Route Handler lives in a `route.ts` file and exports functions named after HTTP methods.

```tsx
export async function GET() {}
export async function POST() {}
```

The collection endpoint will support:

- Listing all projects
- Filtering by status
- Creating a project from JSON

A successful creation returns HTTP `201 Created`.

## The Implementation

Create the route directory:

```bash
mkdir -p src/app/api/projects
```

Create the handler.

### `src/app/api/projects/route.ts`

```ts
import { revalidatePath } from "next/cache";

import {
  apiError,
  apiSuccess,
  readJsonBody,
  zodErrorDetails,
} from "@/lib/api-response";
import { createProject } from "@/lib/database/project-mutations";
import { getProjects } from "@/lib/database/project-queries";
import { createProjectInputSchema } from "@/lib/project-inputs";
import {
  isProjectStatus,
  type ProjectStatus,
} from "@/lib/project-types";

export async function GET(request: Request) {
  const url = new URL(request.url);
  const requestedStatus = url.searchParams.get("status");

  let status: ProjectStatus | undefined;

  if (requestedStatus !== null) {
    const normalizedStatus = requestedStatus.toUpperCase();

    if (!isProjectStatus(normalizedStatus)) {
      return apiError(
        400,
        "VALIDATION_ERROR",
        "The status query parameter is invalid.",
        [
          {
            path: "status",
            message:
              "Status must be PLANNED, ACTIVE, or COMPLETED.",
          },
        ],
      );
    }

    status = normalizedStatus;
  }

  try {
    const projects = await getProjects(status);

    return apiSuccess(projects);
  } catch (error) {
    console.error("GET /api/projects failed.", error);

    return apiError(
      500,
      "INTERNAL_ERROR",
      "Projects could not be retrieved.",
    );
  }
}

export async function POST(request: Request) {
  const body = await readJsonBody(request);

  if (!body.success) {
    return body.response;
  }

  const parsedInput = createProjectInputSchema.safeParse(body.data);

  if (!parsedInput.success) {
    return apiError(
      422,
      "VALIDATION_ERROR",
      "The project input is invalid.",
      zodErrorDetails(parsedInput.error),
    );
  }

  try {
    const project = await createProject(parsedInput.data);

    revalidatePath("/dashboard");
    revalidatePath("/projects");

    return apiSuccess(project, {
      status: 201,
      headers: {
        Location: `/api/projects/${project.id}`,
      },
    });
  } catch (error) {
    console.error("POST /api/projects failed.", error);

    return apiError(
      500,
      "INTERNAL_ERROR",
      "The project could not be created.",
    );
  }
}
```

### Why validation errors use `422`

The JSON is syntactically valid, but its values violate the application contract.

HTTP `422 Unprocessable Content` communicates that distinction.

### Why route paths are revalidated

After creation, these views may be affected:

```text
/dashboard
/projects
```

Calling `revalidatePath` invalidates framework-managed route data associated with those paths.

Our current database queries are dynamic, but declaring invalidation at the mutation point prepares the architecture for later cache policy.

## The Verification

Start the database and application:

```bash
npm run db:start
npm run dev
```

List projects:

```bash
curl --fail --silent \
  http://localhost:3000/api/projects |
  python -m json.tool
```

The response should contain:

```json
{
  "data": [
    {
      "id": "...",
      "name": "..."
    }
  ]
}
```

Filter active projects:

```bash
curl --fail --silent \
  "http://localhost:3000/api/projects?status=ACTIVE" |
  python -m json.tool
```

Test invalid status:

```bash
curl --silent \
  --write-out "\nStatus: %{http_code}\n" \
  "http://localhost:3000/api/projects?status=UNKNOWN"
```

Expected status:

```text
400
```

Create a project:

```bash
curl --silent \
  --request POST \
  --header "Content-Type: application/json" \
  --data '{
    "name": "API verification project",
    "description": "A temporary project created while testing the API.",
    "status": "PLANNED"
  }' \
  --write-out "\nStatus: %{http_code}\n" \
  http://localhost:3000/api/projects
```

Expected status:

```text
201
```

Test invalid input:

```bash
curl --silent \
  --request POST \
  --header "Content-Type: application/json" \
  --data '{
    "name": "",
    "description": "",
    "status": "UNKNOWN"
  }' \
  --write-out "\nStatus: %{http_code}\n" \
  http://localhost:3000/api/projects
```

Expected status:

```text
422
```

[GENERATED: Part 7, Step 6: Project Collection API] [STARTING: Part 7, Step 7: Individual Project API]

---

# Step 7: Build the Individual Project Route Handler

## The Target

Create:

```text
GET /api/projects/:projectId
PATCH /api/projects/:projectId
DELETE /api/projects/:projectId
```

## The Concept

A collection route operates on the group:

```text
/api/projects
```

An item route operates on one identified resource:

```text
/api/projects/uuid
```

The dynamic parameter must be validated before it reaches PostgreSQL.

`PATCH` performs a partial update. Unlike `PUT`, it does not require a complete replacement representation.

## The Implementation

Create the dynamic API directory:

```bash
mkdir -p 'src/app/api/projects/[projectId]'
```

Create the handler.

### `src/app/api/projects/[projectId]/route.ts`

```ts
import { revalidatePath } from "next/cache";
import { z } from "zod";

import {
  apiError,
  apiSuccess,
  readJsonBody,
  zodErrorDetails,
} from "@/lib/api-response";
import {
  deleteProject,
  updateProject,
} from "@/lib/database/project-mutations";
import { getProjectById } from "@/lib/database/project-queries";
import { updateProjectInputSchema } from "@/lib/project-inputs";

type ProjectRouteContext = {
  params: Promise<{
    projectId: string;
  }>;
};

const projectIdSchema = z.string().uuid();

async function readProjectId(context: ProjectRouteContext) {
  const { projectId } = await context.params;
  return projectIdSchema.safeParse(projectId);
}

export async function GET(
  _request: Request,
  context: ProjectRouteContext,
) {
  const parsedProjectId = await readProjectId(context);

  if (!parsedProjectId.success) {
    return apiError(
      400,
      "VALIDATION_ERROR",
      "The project identifier is invalid.",
    );
  }

  try {
    const project = await getProjectById(parsedProjectId.data);

    if (!project) {
      return apiError(
        404,
        "NOT_FOUND",
        "The requested project does not exist.",
      );
    }

    return apiSuccess(project);
  } catch (error) {
    console.error("GET /api/projects/:projectId failed.", error);

    return apiError(
      500,
      "INTERNAL_ERROR",
      "The project could not be retrieved.",
    );
  }
}

export async function PATCH(
  request: Request,
  context: ProjectRouteContext,
) {
  const parsedProjectId = await readProjectId(context);

  if (!parsedProjectId.success) {
    return apiError(
      400,
      "VALIDATION_ERROR",
      "The project identifier is invalid.",
    );
  }

  const body = await readJsonBody(request);

  if (!body.success) {
    return body.response;
  }

  const parsedInput = updateProjectInputSchema.safeParse(body.data);

  if (!parsedInput.success) {
    return apiError(
      422,
      "VALIDATION_ERROR",
      "The project update is invalid.",
      zodErrorDetails(parsedInput.error),
    );
  }

  try {
    const project = await updateProject(
      parsedProjectId.data,
      parsedInput.data,
    );

    if (!project) {
      return apiError(
        404,
        "NOT_FOUND",
        "The requested project does not exist.",
      );
    }

    revalidatePath("/dashboard");
    revalidatePath("/projects");
    revalidatePath(`/projects/${project.id}`);

    return apiSuccess(project);
  } catch (error) {
    console.error("PATCH /api/projects/:projectId failed.", error);

    return apiError(
      500,
      "INTERNAL_ERROR",
      "The project could not be updated.",
    );
  }
}

export async function DELETE(
  _request: Request,
  context: ProjectRouteContext,
) {
  const parsedProjectId = await readProjectId(context);

  if (!parsedProjectId.success) {
    return apiError(
      400,
      "VALIDATION_ERROR",
      "The project identifier is invalid.",
    );
  }

  try {
    const deleted = await deleteProject(parsedProjectId.data);

    if (!deleted) {
      return apiError(
        404,
        "NOT_FOUND",
        "The requested project does not exist.",
      );
    }

    revalidatePath("/dashboard");
    revalidatePath("/projects");

    return new Response(null, {
      status: 204,
    });
  } catch (error) {
    console.error("DELETE /api/projects/:projectId failed.", error);

    return apiError(
      500,
      "INTERNAL_ERROR",
      "The project could not be deleted.",
    );
  }
}
```

## The Verification

Capture the temporary project ID created in the previous step:

```bash
PROJECT_ID="$(
  curl --silent http://localhost:3000/api/projects |
    python -c '
import json, sys
projects = json.load(sys.stdin)["data"]
match = next(
    project
    for project in projects
    if project["name"] == "API verification project"
)
print(match["id"])
'
)"

echo "${PROJECT_ID}"
```

Read it:

```bash
curl --fail --silent \
  "http://localhost:3000/api/projects/${PROJECT_ID}" |
  python -m json.tool
```

Update it:

```bash
curl --fail --silent \
  --request PATCH \
  --header "Content-Type: application/json" \
  --data '{
    "status": "ACTIVE"
  }' \
  "http://localhost:3000/api/projects/${PROJECT_ID}" |
  python -m json.tool
```

The response status field should be:

```text
ACTIVE
```

Delete it:

```bash
curl --silent \
  --request DELETE \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  "http://localhost:3000/api/projects/${PROJECT_ID}"
```

Expected output:

```text
204
```

Verify it is gone:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  "http://localhost:3000/api/projects/${PROJECT_ID}"
```

Expected output:

```text
404
```

[GENERATED: Part 7, Step 7: Individual Project API] [STARTING: Part 7, Step 8: Health Route]

---

# Step 8: Create a Health-Check Route

## The Target

Create:

```text
GET /api/health
```

that reports application and database availability.

## The Concept

A health endpoint gives infrastructure a simple way to ask:

> Can this application serve its essential dependency-backed workload?

The endpoint must not expose:

- Database URLs
- Credentials
- Raw exceptions
- Internal network names
- Stack traces

It returns:

- `200` when the database responds
- `503 Service Unavailable` when the database cannot be reached

## The Implementation

Create the route.

```bash
mkdir -p src/app/api/health
```

### `src/app/api/health/route.ts`

```ts
import {
  apiError,
  apiSuccess,
} from "@/lib/api-response";
import { checkDatabaseHealth } from "@/lib/database/health";

export const dynamic = "force-dynamic";

export async function GET() {
  const checkedAt = new Date().toISOString();

  try {
    await checkDatabaseHealth();

    return apiSuccess({
      status: "ok",
      database: "reachable",
      checkedAt,
    });
  } catch (error) {
    console.error("Health check failed.", error);

    return apiError(
      503,
      "SERVICE_UNAVAILABLE",
      "A required application service is unavailable.",
      {
        status: "degraded",
        checkedAt,
      },
    );
  }
}
```

### Why the route is explicitly dynamic

A health response must describe the current moment:

```ts
export const dynamic = "force-dynamic";
```

A cached success response would be dangerous because it could remain healthy-looking after the database failed.

## The Verification

With PostgreSQL running:

```bash
curl --silent \
  --write-out "\nStatus: %{http_code}\n" \
  http://localhost:3000/api/health
```

Expected status:

```text
200
```

Stop PostgreSQL:

```bash
npm run db:stop
```

Request the endpoint again:

```bash
curl --silent \
  --write-out "\nStatus: %{http_code}\n" \
  http://localhost:3000/api/health
```

Expected status:

```text
503
```

Restart PostgreSQL:

```bash
npm run db:start
```

Wait until healthy and verify the endpoint returns `200` again.

[GENERATED: Part 7, Step 8: Health Route] [STARTING: Part 7, Step 9: Server Action State]

---

# Step 9: Create Shared Server Action State

## The Target

Define the serializable response contract used by form Server Actions.

## The Concept

A form needs feedback after submission:

- Did the operation succeed?
- Was there a general error?
- Which fields were invalid?

The state crossing from a Server Action to a Client Component must be serializable.

We will use:

```ts
{
  status: "idle" | "error" | "success";
  message?: string;
  fieldErrors?: {
    name?: string[];
  };
}
```

## The Implementation

Create the state module.

### `src/lib/action-state.ts`

```ts
export type ActionStatus =
  | "idle"
  | "error"
  | "success";

export type FormActionState = {
  status: ActionStatus;
  message?: string;
  fieldErrors?: Record<string, string[]>;
};

export const INITIAL_FORM_ACTION_STATE: FormActionState = {
  status: "idle",
};

export function createFieldErrors(
  issues: readonly {
    path: PropertyKey[];
    message: string;
  }[],
): Record<string, string[]> {
  const fieldErrors: Record<string, string[]> = {};

  for (const issue of issues) {
    const fieldName = String(issue.path[0] ?? "form");
    const existingMessages = fieldErrors[fieldName] ?? [];

    fieldErrors[fieldName] = [
      ...existingMessages,
      issue.message,
    ];
  }

  return fieldErrors;
}
```

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 7, Step 9: Server Action State] [STARTING: Part 7, Step 10: Project Creation Server Action]

---

# Step 10: Build the Project Creation Server Action

## The Target

Create a Server Action that validates form data, creates a project, revalidates affected routes, and redirects to the new project.

## The Concept

A Server Action is a server-side function marked by:

```ts
"use server";
```

The form submits standard `FormData`. The action validates it before calling the mutation layer.

On success:

1. Create the project.
2. Revalidate affected routes.
3. Redirect to the new project.

The redirect must occur outside the `try/catch` block because Next.js implements redirects by throwing a special framework control-flow value.

## The Implementation

Create the action.

### `src/app/(workspace)/projects/actions.ts`

```ts
"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

import {
  createFieldErrors,
  type FormActionState,
} from "@/lib/action-state";
import { createProject } from "@/lib/database/project-mutations";
import { createProjectInputSchema } from "@/lib/project-inputs";

export async function createProjectAction(
  _previousState: FormActionState,
  formData: FormData,
): Promise<FormActionState> {
  const parsedInput = createProjectInputSchema.safeParse({
    name: formData.get("name"),
    description: formData.get("description"),
    status: formData.get("status"),
  });

  if (!parsedInput.success) {
    return {
      status: "error",
      message: "Correct the highlighted project fields.",
      fieldErrors: createFieldErrors(parsedInput.error.issues),
    };
  }

  let projectId: string;

  try {
    const project = await createProject(parsedInput.data);
    projectId = project.id;
  } catch (error) {
    console.error("Project creation action failed.", error);

    return {
      status: "error",
      message:
        "The project could not be created. Please try again.",
    };
  }

  revalidatePath("/dashboard");
  revalidatePath("/projects");

  redirect(`/projects/${projectId}`);
}
```

### Why the action validates `FormData`

Form fields are untrusted even when the HTML contains:

```html
required
maxlength
```

A caller can bypass browser validation and submit a direct request.

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

The action is not exposed until a form uses it.

[GENERATED: Part 7, Step 10: Project Creation Action] [STARTING: Part 7, Step 11: Project Creation Form]

---

# Step 11: Build the Project Creation Page and Form

## The Target

Create `/projects/new` with accessible validation and pending-state feedback.

## The Concept

React’s `useActionState` connects a form to a Server Action.

It provides:

- Current action state
- A form action function
- Pending status

The page remains a Server Component. Only the form becomes a Client Component because it needs pending and validation feedback.

## The Implementation

Create the form component.

### `src/components/create-project-form.tsx`

```tsx
"use client";

import { useActionState } from "react";

import { createProjectAction } from "@/app/(workspace)/projects/actions";
import { INITIAL_FORM_ACTION_STATE } from "@/lib/action-state";
import {
  formatProjectStatus,
  PROJECT_STATUSES,
} from "@/lib/project-types";

function FieldErrors({
  errors,
}: {
  errors?: string[];
}) {
  if (!errors || errors.length === 0) {
    return null;
  }

  return (
    <ul className="field-errors">
      {errors.map((error) => (
        <li key={error}>{error}</li>
      ))}
    </ul>
  );
}

export function CreateProjectForm() {
  const [state, formAction, isPending] = useActionState(
    createProjectAction,
    INITIAL_FORM_ACTION_STATE,
  );

  return (
    <form className="stack-form" action={formAction}>
      <div className="form-field">
        <label htmlFor="name">Project name</label>
        <input
          id="name"
          name="name"
          type="text"
          maxLength={120}
          required
          aria-invalid={
            state.fieldErrors?.name ? true : undefined
          }
          aria-describedby={
            state.fieldErrors?.name
              ? "name-errors"
              : "name-help"
          }
        />
        <p className="field-help" id="name-help">
          Use a short, recognizable name.
        </p>
        <div id="name-errors">
          <FieldErrors errors={state.fieldErrors?.name} />
        </div>
      </div>

      <div className="form-field">
        <label htmlFor="description">
          Project description
        </label>
        <textarea
          id="description"
          name="description"
          rows={6}
          maxLength={2_000}
          required
          aria-invalid={
            state.fieldErrors?.description ? true : undefined
          }
          aria-describedby={
            state.fieldErrors?.description
              ? "description-errors"
              : "description-help"
          }
        />
        <p className="field-help" id="description-help">
          Explain the outcome this project should produce.
        </p>
        <div id="description-errors">
          <FieldErrors
            errors={state.fieldErrors?.description}
          />
        </div>
      </div>

      <div className="form-field">
        <label htmlFor="status">Initial status</label>
        <select
          id="status"
          name="status"
          defaultValue="PLANNED"
          aria-invalid={
            state.fieldErrors?.status ? true : undefined
          }
        >
          {PROJECT_STATUSES.map((status) => (
            <option key={status} value={status}>
              {formatProjectStatus(status)}
            </option>
          ))}
        </select>
        <FieldErrors errors={state.fieldErrors?.status} />
      </div>

      {state.message ? (
        <p
          className={
            state.status === "error"
              ? "form-message form-message--error"
              : "form-message"
          }
          role={state.status === "error" ? "alert" : "status"}
        >
          {state.message}
        </p>
      ) : null}

      <button
        className="primary-button"
        type="submit"
        disabled={isPending}
      >
        {isPending ? "Creating project…" : "Create project"}
      </button>
    </form>
  );
}
```

Create the page:

```bash
mkdir -p 'src/app/(workspace)/projects/new'
```

### `src/app/(workspace)/projects/new/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";

import { CreateProjectForm } from "@/components/create-project-form";

export const metadata: Metadata = {
  title: "New project",
  description: "Create a new LaunchPad project.",
};

export default function NewProjectPage() {
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
          <li aria-current="page">New project</li>
        </ol>
      </nav>

      <header className="page-heading">
        <p className="eyebrow">New project</p>
        <h1>Create a focused space for meaningful work.</h1>
        <p>
          Server-side validation protects every submitted value before the
          project is written to PostgreSQL.
        </p>
      </header>

      <CreateProjectForm />
    </main>
  );
}
```

Add a creation link to the projects page. In:

```text
src/app/(workspace)/projects/page.tsx
```

replace its opening `<header className="page-heading">...</header>` with:

```tsx
<header className="page-heading dashboard-heading">
  <div>
    <p className="eyebrow">Project workspace</p>
    <h1>Explore the work already on the LaunchPad</h1>
    <p>
      Project records and task totals come from PostgreSQL. Status filtering
      runs on the server, while text searching remains a focused browser
      interaction.
    </p>
  </div>

  <Link className="primary-link" href="/projects/new">
    Create project
  </Link>
</header>
```

Also add this import at the top:

```tsx
import Link from "next/link";
```

## The Verification

Open:

```text
http://localhost:3000/projects/new
```

Submit the empty form. Browser validation should prevent submission.

Enter:

```text
Name: Full-stack tutorial verification
Description: Verify project creation through a Server Action.
Status: Active
```

Submit.

Expected behavior:

1. The button displays `Creating project…`.
2. The browser redirects to the new project.
3. The project has zero tasks.
4. The project appears on `/projects`.
5. Dashboard totals increase.

Verify it exists in PostgreSQL:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT id, name, status
    FROM projects
    WHERE name = 'Full-stack tutorial verification';
  "
```

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 7, Step 11: Project Creation Form] [STARTING: Part 7, Step 12: Task Server Actions]

---

# Step 12: Build Task Creation and Status Actions

## The Target

Create Server Actions for adding tasks and changing task status.

## The Concept

Task operations belong to a particular project. The project identifier will be bound to the Server Action separately from the submitted form fields.

The server still verifies:

- The project ID is a UUID.
- The form fields are valid.
- The task belongs to the project during status updates.

## The Implementation

Create the action file.

### `src/app/(workspace)/projects/[projectId]/actions.ts`

```ts
"use server";

import { revalidatePath } from "next/cache";
import { z } from "zod";

import {
  createFieldErrors,
  type FormActionState,
} from "@/lib/action-state";
import {
  createTask,
  updateTaskStatus,
} from "@/lib/database/project-mutations";
import {
  createTaskInputSchema,
  updateTaskStatusInputSchema,
} from "@/lib/project-inputs";

const identifierSchema = z.string().uuid();

export async function createTaskAction(
  projectId: string,
  _previousState: FormActionState,
  formData: FormData,
): Promise<FormActionState> {
  const parsedProjectId = identifierSchema.safeParse(projectId);

  if (!parsedProjectId.success) {
    return {
      status: "error",
      message: "The project identifier is invalid.",
    };
  }

  const parsedInput = createTaskInputSchema.safeParse({
    title: formData.get("title"),
    description: formData.get("description"),
    priority: formData.get("priority"),
    dueDate: formData.get("dueDate"),
  });

  if (!parsedInput.success) {
    return {
      status: "error",
      message: "Correct the highlighted task fields.",
      fieldErrors: createFieldErrors(parsedInput.error.issues),
    };
  }

  try {
    const task = await createTask(
      parsedProjectId.data,
      parsedInput.data,
    );

    if (!task) {
      return {
        status: "error",
        message: "The project no longer exists.",
      };
    }

    revalidatePath("/dashboard");
    revalidatePath("/projects");
    revalidatePath(`/projects/${parsedProjectId.data}`);

    return {
      status: "success",
      message: "Task created.",
    };
  } catch (error) {
    console.error("Task creation action failed.", error);

    return {
      status: "error",
      message: "The task could not be created.",
    };
  }
}

export async function updateTaskStatusAction(
  projectId: string,
  taskId: string,
  formData: FormData,
): Promise<void> {
  const parsedProjectId = identifierSchema.safeParse(projectId);
  const parsedTaskId = identifierSchema.safeParse(taskId);
  const parsedInput = updateTaskStatusInputSchema.safeParse({
    status: formData.get("status"),
  });

  if (
    !parsedProjectId.success ||
    !parsedTaskId.success ||
    !parsedInput.success
  ) {
    throw new Error("The task status request is invalid.");
  }

  const task = await updateTaskStatus(
    parsedProjectId.data,
    parsedTaskId.data,
    parsedInput.data,
  );

  if (!task) {
    throw new Error("The requested task does not exist.");
  }

  revalidatePath("/dashboard");
  revalidatePath("/projects");
  revalidatePath(`/projects/${parsedProjectId.data}`);
}
```

### Why status update uses a simple action

The status form is small and rendered once for each task. It submits one supported enum value and refreshes the server-rendered route.

A richer optimistic interface can be added later if measurements show that immediate speculative feedback is valuable.

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

The actions become usable after adding their forms.

[GENERATED: Part 7, Step 12: Task Server Actions] [STARTING: Part 7, Step 13: Task Forms and List]

---

# Step 13: Build the Task Creation Form and Task List

## The Target

Create a Client Component for task creation and a Server Component for rendering and updating tasks.

## The Concept

The task form needs Client Component behavior for:

- Pending state
- Validation feedback
- Success feedback
- Resetting after success

The task list itself can remain server-rendered. Each status selector submits a standard form to a Server Action.

## The Implementation

Create the task form.

### `src/components/create-task-form.tsx`

```tsx
"use client";

import { useActionState, useEffect, useRef } from "react";

import { createTaskAction } from "@/app/(workspace)/projects/[projectId]/actions";
import { INITIAL_FORM_ACTION_STATE } from "@/lib/action-state";
import {
  formatTaskPriority,
  TASK_PRIORITIES,
} from "@/lib/task-types";

type CreateTaskFormProps = {
  projectId: string;
};

export function CreateTaskForm({
  projectId,
}: CreateTaskFormProps) {
  const formRef = useRef<HTMLFormElement>(null);
  const boundAction = createTaskAction.bind(null, projectId);

  const [state, formAction, isPending] = useActionState(
    boundAction,
    INITIAL_FORM_ACTION_STATE,
  );

  useEffect(() => {
    if (state.status === "success") {
      formRef.current?.reset();
    }
  }, [state.status]);

  return (
    <form
      className="stack-form"
      action={formAction}
      ref={formRef}
    >
      <div className="form-field">
        <label htmlFor="task-title">Task title</label>
        <input
          id="task-title"
          name="title"
          type="text"
          required
          maxLength={160}
          aria-invalid={
            state.fieldErrors?.title ? true : undefined
          }
        />
        {state.fieldErrors?.title?.map((error) => (
          <p className="field-error" key={error}>
            {error}
          </p>
        ))}
      </div>

      <div className="form-field">
        <label htmlFor="task-description">
          Description <span>(optional)</span>
        </label>
        <textarea
          id="task-description"
          name="description"
          rows={4}
          maxLength={2_000}
          aria-invalid={
            state.fieldErrors?.description ? true : undefined
          }
        />
        {state.fieldErrors?.description?.map((error) => (
          <p className="field-error" key={error}>
            {error}
          </p>
        ))}
      </div>

      <div className="form-row">
        <div className="form-field">
          <label htmlFor="task-priority">Priority</label>
          <select
            id="task-priority"
            name="priority"
            defaultValue="MEDIUM"
          >
            {TASK_PRIORITIES.map((priority) => (
              <option key={priority} value={priority}>
                {formatTaskPriority(priority)}
              </option>
            ))}
          </select>
        </div>

        <div className="form-field">
          <label htmlFor="task-due-date">
            Due date <span>(optional)</span>
          </label>
          <input
            id="task-due-date"
            name="dueDate"
            type="date"
            aria-invalid={
              state.fieldErrors?.dueDate ? true : undefined
            }
          />
          {state.fieldErrors?.dueDate?.map((error) => (
            <p className="field-error" key={error}>
              {error}
            </p>
          ))}
        </div>
      </div>

      {state.message ? (
        <p
          className={
            state.status === "error"
              ? "form-message form-message--error"
              : "form-message form-message--success"
          }
          role={state.status === "error" ? "alert" : "status"}
        >
          {state.message}
        </p>
      ) : null}

      <button
        className="primary-button"
        type="submit"
        disabled={isPending}
      >
        {isPending ? "Creating task…" : "Add task"}
      </button>
    </form>
  );
}
```

Create the task list.

### `src/components/task-list.tsx`

```tsx
import { updateTaskStatusAction } from "@/app/(workspace)/projects/[projectId]/actions";
import {
  formatTaskPriority,
  formatTaskStatus,
  TASK_STATUSES,
  type Task,
} from "@/lib/task-types";

type TaskListProps = {
  projectId: string;
  tasks: readonly Task[];
};

export function TaskList({
  projectId,
  tasks,
}: TaskListProps) {
  if (tasks.length === 0) {
    return (
      <div className="empty-state">
        <h3>No tasks yet</h3>
        <p>Add the first task to begin tracking project work.</p>
      </div>
    );
  }

  return (
    <div className="task-list">
      {tasks.map((task) => {
        const updateAction = updateTaskStatusAction.bind(
          null,
          projectId,
          task.id,
        );

        return (
          <article className="task-card" key={task.id}>
            <div className="task-card__content">
              <div className="task-card__heading">
                <h3>{task.title}</h3>
                <span
                  className={`priority-badge priority-badge--${task.priority.toLowerCase()}`}
                >
                  {formatTaskPriority(task.priority)}
                </span>
              </div>

              {task.description ? (
                <p>{task.description}</p>
              ) : null}

              <dl className="task-metadata">
                <div>
                  <dt>Status</dt>
                  <dd>{formatTaskStatus(task.status)}</dd>
                </div>

                <div>
                  <dt>Due date</dt>
                  <dd>{task.dueDate ?? "No due date"}</dd>
                </div>
              </dl>
            </div>

            <form className="task-status-form" action={updateAction}>
              <label htmlFor={`task-status-${task.id}`}>
                Change status
              </label>
              <select
                id={`task-status-${task.id}`}
                name="status"
                defaultValue={task.status}
              >
                {TASK_STATUSES.map((status) => (
                  <option key={status} value={status}>
                    {formatTaskStatus(status)}
                  </option>
                ))}
              </select>
              <button className="secondary-button" type="submit">
                Update
              </button>
            </form>
          </article>
        );
      })}
    </div>
  );
}
```

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

The components compile but are not yet rendered.

[GENERATED: Part 7, Step 13: Task Forms and List] [STARTING: Part 7, Step 14: Project Task Composition]

---

# Step 14: Add Tasks to the Project Detail Page

## The Target

Fetch project tasks and render task creation and status-management interfaces on the dynamic project page.

## The Concept

The project and its task list can be loaded in parallel.

Instead of:

```ts
const project = await getProjectById(id);
const tasks = await getTasksForProject(id);
```

we can start both promises together:

```ts
const [project, tasks] = await Promise.all([...]);
```

This avoids waiting for one independent query before starting the other.

## The Implementation

In:

```text
src/app/(workspace)/projects/[projectId]/page.tsx
```

add these imports:

```tsx
import { CreateTaskForm } from "@/components/create-task-form";
import { TaskList } from "@/components/task-list";
```

Change the query import to:

```tsx
import {
  getProjectById,
  getTasksForProject,
} from "@/lib/database/project-queries";
```

Replace the page’s lookup:

```tsx
const project = await findProject(projectId);

if (!project) {
  notFound();
}
```

with:

```tsx
const parsedProjectId = projectIdSchema.safeParse(projectId);

if (!parsedProjectId.success) {
  notFound();
}

const [project, tasks] = await Promise.all([
  getProjectById(parsedProjectId.data),
  getTasksForProject(parsedProjectId.data),
]);

if (!project) {
  notFound();
}
```

Then insert the following section after the existing `project-disclosures` block and before `</article>`:

```tsx
<section
  className="project-tasks-section"
  aria-labelledby="project-tasks-heading"
>
  <div className="results-heading">
    <div>
      <p className="eyebrow">Project work</p>
      <h2 id="project-tasks-heading">Tasks</h2>
    </div>

    <p>
      {tasks.length} {tasks.length === 1 ? "task" : "tasks"}
    </p>
  </div>

  <TaskList
    projectId={project.id}
    tasks={tasks}
  />

  <div className="task-form-panel">
    <div>
      <p className="eyebrow">Add work</p>
      <h2>Create a task</h2>
      <p>
        Tasks begin in the To do status and can be updated after creation.
      </p>
    </div>

    <CreateTaskForm projectId={project.id} />
  </div>
</section>
```

### Why project metadata still uses `findProject`

Metadata only needs the project. It does not need tasks.

The page validates once and loads both required datasets in parallel.

## The Verification

Open the project created through the form, or use:

```text
http://localhost:3000/projects/10000000-0000-4000-8000-000000000001
```

Confirm existing tasks appear.

Create a task:

```text
Title: Verify task Server Action
Description: Confirm task creation and route revalidation.
Priority: High
Due date: choose a future date
```

Submit.

Confirm:

- Success feedback appears.
- The form resets.
- The task appears in the list.
- The task count increases.
- Project progress recalculates.

Change its status to **Completed** and select **Update**.

Confirm:

- The task status changes.
- Completed task count increases.
- Project progress changes.
- Dashboard metrics update after navigation.

Verify directly:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT title, status, priority, due_date
    FROM tasks
    WHERE title = 'Verify task Server Action';
  "
```

[GENERATED: Part 7, Step 14: Project Task Composition] [STARTING: Part 7, Step 15: Form and Task Styles]

---

# Step 15: Style Forms and Task Management

## The Target

Add responsive, accessible styles for project forms, task forms, validation feedback, and task cards.

## The Concept

Form styling should communicate:

- Which text labels a control
- Which fields are invalid
- Whether an operation is pending
- Whether an operation succeeded
- Which action is primary
- How related controls are grouped

Disabled controls should remain readable. Error messages must use text, not only red borders.

## The Implementation

Append to:

### `src/app/globals.css`

```css
/* Part 7: full-stack forms and task management */

.stack-form {
  display: grid;
  max-width: 48rem;
  padding: var(--space-8);
  border: 0.0625rem solid var(--color-border);
  border-radius: var(--radius-large);
  background: var(--color-surface);
  box-shadow: var(--shadow-card);
  gap: var(--space-6);
}

.form-field {
  display: grid;
  min-width: 0;
  gap: var(--space-2);
}

.form-field label {
  font-weight: 800;
}

.form-field label span {
  color: var(--color-text-muted);
  font-weight: 400;
}

.form-field input,
.form-field textarea,
.form-field select {
  width: 100%;
  padding: var(--space-3);
  border: 0.0625rem solid var(--color-border-strong);
  border-radius: var(--radius-small);
  background: var(--color-surface);
  color: var(--color-text);
}

.form-field textarea {
  resize: vertical;
}

.form-field [aria-invalid="true"] {
  border-color: var(--color-danger);
  background: var(--color-danger-soft);
}

.field-help {
  margin: 0;
  color: var(--color-text-muted);
  font-size: var(--font-size-small);
}

.field-errors {
  margin: 0;
  padding-left: var(--space-5);
  color: var(--color-danger);
  font-size: var(--font-size-small);
  font-weight: 700;
}

.field-error {
  margin: 0;
  color: var(--color-danger);
  font-size: var(--font-size-small);
  font-weight: 700;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: var(--space-4);
}

.form-message {
  margin: 0;
  padding: var(--space-3);
  border-radius: var(--radius-small);
  font-weight: 700;
}

.form-message--success {
  background: var(--color-success-soft);
  color: var(--color-success);
}

.form-message--error {
  background: var(--color-danger-soft);
  color: var(--color-danger);
}

button:disabled {
  cursor: not-allowed;
  opacity: 0.65;
}

.project-tasks-section {
  margin-top: var(--space-16);
  padding-top: var(--space-12);
  border-top: 0.0625rem solid var(--color-border);
}

.task-list {
  display: grid;
  gap: var(--space-4);
}

.task-card {
  display: grid;
  padding: var(--space-6);
  border: 0.0625rem solid var(--color-border);
  border-radius: var(--radius-large);
  background: var(--color-surface);
  box-shadow: var(--shadow-small);
  grid-template-columns: minmax(0, 1fr) minmax(12rem, 0.35fr);
  align-items: start;
  gap: var(--space-6);
}

.task-card__content {
  min-width: 0;
}

.task-card__heading {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-4);
}

.task-card__heading h3 {
  margin: 0;
  font-size: var(--font-size-heading-small);
  line-height: 1.25;
}

.task-card__content > p {
  margin: var(--space-3) 0 0;
  color: var(--color-text-muted);
}

.task-metadata {
  display: flex;
  margin: var(--space-5) 0 0;
  flex-wrap: wrap;
  gap: var(--space-6);
}

.task-metadata div {
  display: grid;
  gap: var(--space-1);
}

.task-metadata dt {
  color: var(--color-text-muted);
  font-size: var(--font-size-xs);
  font-weight: 800;
  letter-spacing: 0.05em;
  text-transform: uppercase;
}

.task-metadata dd {
  margin: 0;
  font-size: var(--font-size-small);
  font-weight: 700;
}

.task-status-form {
  display: grid;
  gap: var(--space-2);
}

.task-status-form label {
  font-size: var(--font-size-small);
  font-weight: 800;
}

.task-status-form select {
  width: 100%;
  padding-inline: var(--space-3);
  border: 0.0625rem solid var(--color-border-strong);
  border-radius: var(--radius-small);
  background: var(--color-surface);
  color: var(--color-text);
}

.priority-badge {
  display: inline-flex;
  min-height: 1.75rem;
  padding: var(--space-1) var(--space-3);
  border-radius: var(--radius-pill);
  align-items: center;
  flex: 0 0 auto;
  font-size: var(--font-size-xs);
  font-weight: 800;
  letter-spacing: 0.04em;
  line-height: 1;
  text-transform: uppercase;
}

.priority-badge--low {
  background: var(--color-surface-subtle);
  color: var(--color-text-muted);
}

.priority-badge--medium {
  background: var(--color-warning-soft);
  color: var(--color-warning);
}

.priority-badge--high {
  background: var(--color-danger-soft);
  color: var(--color-danger);
}

.task-form-panel {
  display: grid;
  margin-top: var(--space-10);
  padding: var(--space-8);
  border: 0.0625rem solid var(--color-border);
  border-radius: var(--radius-large);
  background: var(--color-primary-soft);
  grid-template-columns: minmax(12rem, 0.6fr) minmax(0, 1fr);
  align-items: start;
  gap: var(--space-8);
}

.task-form-panel > div:first-child h2 {
  margin: 0;
  font-size: var(--font-size-heading-medium);
  line-height: var(--line-height-tight);
}

.task-form-panel > div:first-child p:last-child {
  margin: var(--space-3) 0 0;
  color: var(--color-text-muted);
}

.task-form-panel .stack-form {
  padding: var(--space-6);
  box-shadow: none;
}

@media (max-width: 56rem) {
  .task-card,
  .task-form-panel {
    grid-template-columns: 1fr;
  }

  .task-status-form {
    max-width: 20rem;
  }
}

@media (max-width: 36rem) {
  .stack-form,
  .task-form-panel {
    padding: var(--space-5);
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .task-card__heading {
    flex-direction: column;
  }

  .task-metadata {
    display: grid;
    gap: var(--space-3);
  }
}

@media print {
  .task-status-form,
  .task-form-panel {
    display: none !important;
  }

  .task-card {
    display: block;
    break-inside: avoid;
    box-shadow: none;
  }
}
```

## The Verification

Open:

```text
http://localhost:3000/projects/new
```

Confirm:

- Labels are visibly associated with controls.
- The form has a constrained readable width.
- Invalid fields receive both border treatment and text feedback.
- The pending button remains readable.
- The form fits a narrow viewport.

Open a project-detail route and confirm:

- Task cards form clear visual groups.
- Priority labels include text.
- Status controls remain usable with a keyboard.
- Task cards become one column on narrower screens.
- The task-creation panel becomes one column.
- Printed output hides mutation controls.

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 7, Step 15: Form and Task Styles] [STARTING: Part 7, Step 16: API and Mutation Verification]

---

# Step 16: Verify APIs and Mutations End to End

## The Target

Run a repeatable verification covering health, project CRUD operations, validation failures, form-backed mutations, and database state.

## The Concept

**CRUD** is a common abbreviation for four basic data operations:

- **Create**
- **Read**
- **Update**
- **Delete**

A production-quality API must handle more than successful requests. We also need to verify:

- Malformed JSON
- Incorrect content types
- Invalid field values
- Invalid identifiers
- Missing resources
- Correct success status codes
- Correct failure status codes

We will create a temporary API record, operate on it, and delete it when finished.

## The Implementation

Ensure PostgreSQL and Next.js are running:

```bash
npm run db:start
npm run dev
```

Open a second terminal in the project root.

### 1. Verify application health

```bash
curl --fail --silent \
  http://localhost:3000/api/health |
  python -m json.tool
```

Expected response shape:

```json
{
  "data": {
    "status": "ok",
    "database": "reachable",
    "checkedAt": "..."
  }
}
```

### 2. Verify project collection reads

```bash
curl --fail --silent \
  http://localhost:3000/api/projects |
  python -m json.tool
```

### 3. Create a temporary project and capture its ID

```bash
PROJECT_RESPONSE="$(
  curl --fail --silent \
    --request POST \
    --header "Content-Type: application/json" \
    --data '{
      "name": "Part 7 API verification",
      "description": "A disposable project used to verify full-stack API operations.",
      "status": "PLANNED"
    }' \
    http://localhost:3000/api/projects
)"

printf "%s\n" "${PROJECT_RESPONSE}" |
  python -m json.tool

PROJECT_ID="$(
  printf "%s" "${PROJECT_RESPONSE}" |
    python -c '
import json, sys
print(json.load(sys.stdin)["data"]["id"])
'
)"

echo "Created project: ${PROJECT_ID}"
```

Confirm that `PROJECT_ID` contains a UUID.

### 4. Read the created project

```bash
curl --fail --silent \
  "http://localhost:3000/api/projects/${PROJECT_ID}" |
  python -m json.tool
```

### 5. Partially update the project

```bash
curl --fail --silent \
  --request PATCH \
  --header "Content-Type: application/json" \
  --data '{
    "name": "Part 7 API verification updated",
    "status": "ACTIVE"
  }' \
  "http://localhost:3000/api/projects/${PROJECT_ID}" |
  python -m json.tool
```

The response should preserve the existing description while updating the supplied fields.

### 6. Verify the browser route sees the mutation

```bash
curl --fail --silent \
  "http://localhost:3000/projects/${PROJECT_ID}" |
  grep --quiet "Part 7 API verification updated"

echo "The dynamic page reflects the API mutation."
```

Expected output:

```text
The dynamic page reflects the API mutation.
```

### 7. Verify an incorrect content type

```bash
curl --silent \
  --request POST \
  --data '{
    "name": "Invalid content type",
    "description": "This request intentionally omits application/json.",
    "status": "PLANNED"
  }' \
  --write-out "\nStatus: %{http_code}\n" \
  http://localhost:3000/api/projects
```

Expected status:

```text
400
```

Expected error code:

```text
BAD_REQUEST
```

### 8. Verify malformed JSON

```bash
curl --silent \
  --request POST \
  --header "Content-Type: application/json" \
  --data '{"name":' \
  --write-out "\nStatus: %{http_code}\n" \
  http://localhost:3000/api/projects
```

Expected status:

```text
400
```

Expected error code:

```text
INVALID_JSON
```

### 9. Verify valid JSON with invalid fields

```bash
curl --silent \
  --request POST \
  --header "Content-Type: application/json" \
  --data '{
    "name": "",
    "description": "",
    "status": "UNSUPPORTED"
  }' \
  --write-out "\nStatus: %{http_code}\n" \
  http://localhost:3000/api/projects
```

Expected status:

```text
422
```

Expected error code:

```text
VALIDATION_ERROR
```

### 10. Verify an empty PATCH

```bash
curl --silent \
  --request PATCH \
  --header "Content-Type: application/json" \
  --data '{}' \
  --write-out "\nStatus: %{http_code}\n" \
  "http://localhost:3000/api/projects/${PROJECT_ID}"
```

Expected status:

```text
422
```

### 11. Verify an invalid identifier

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/api/projects/not-a-uuid
```

Expected output:

```text
400
```

### 12. Verify a missing project

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/api/projects/99999999-9999-4999-8999-999999999999
```

Expected output:

```text
404
```

### 13. Delete the temporary project

```bash
curl --silent \
  --request DELETE \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  "http://localhost:3000/api/projects/${PROJECT_ID}"
```

Expected output:

```text
204
```

### 14. Verify cascading deletion behavior

The temporary API project has no tasks, so also verify the database’s cascade rule with the project created through the browser if you added tasks to it.

First, inspect its ID:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT id, name
    FROM projects
    ORDER BY created_at DESC;
  "
```

Do not delete any project you want to keep. The development seed can restore the original four records later.

## The Verification

Complete these browser checks:

1. Open `/projects/new`.
2. Create a project with valid data.
3. Confirm redirection to its detail page.
4. Add a task.
5. Confirm the success message is announced.
6. Change the task status.
7. Confirm project totals update.
8. Navigate to `/dashboard`.
9. Confirm dashboard metrics reflect the new data.
10. Navigate back to `/projects`.
11. Confirm the project appears.

Inspect the database:

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
    ORDER BY p.created_at;
  "
```

Finally, run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 7, Step 16: API and Mutation Verification] [STARTING: Part 7, Step 17: Restore Deterministic Development Data]

---

# Step 17: Restore the Deterministic Seed State

## The Target

Return the development database to the known four-project, twelve-task state after mutation testing.

## The Concept

Manual verification changes persistent data. If later tutorial parts assume a known baseline, those changes can make expected counts inconsistent.

A deterministic seed acts like resetting a laboratory before the next experiment.

This seed is destructive and intended only for the local development database.

## The Implementation

Stop the development server only if you want a quiet terminal; it is not technically required.

Run:

```bash
npm run db:seed
```

This executes:

```sql
DELETE FROM tasks;
DELETE FROM projects;
```

before recreating the original records.

## The Verification

Confirm the counts:

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

Expected output:

```text
4 | 12
```

Verify that temporary test records are absent:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT name
    FROM projects
    WHERE name ILIKE '%verification%';
  "
```

Expected result:

```text
0 rows
```

Refresh:

```text
http://localhost:3000/dashboard
```

The metrics should return to:

- 4 projects
- 2 active projects
- 12 tasks
- 6 completed tasks
- 50% overall completion

[GENERATED: Part 7, Step 17: Seed Restoration] [STARTING: Part 7, Step 18: Production Build]

---

# Step 18: Verify the Production Build

## The Target

Build and run the complete mutation architecture in production mode.

## The Concept

The production build verifies:

- Route Handler exports
- Dynamic API route parameters
- Server Action module boundaries
- Client form serialization
- Server-only database imports
- CSS extraction
- Type correctness
- Route composition

A successful development mutation does not guarantee production compilation.

## The Implementation

Stop the development server:

```text
Ctrl+C
```

Confirm PostgreSQL is healthy:

```bash
npm run db:start
npm run db:status
```

Run:

```bash
npm run typecheck
npm run lint
npm run build
```

Start the production server:

```bash
npm run start
```

## The Verification

Verify page and API routes:

```bash
for path in \
  "/" \
  "/dashboard" \
  "/projects" \
  "/projects/new" \
  "/projects/10000000-0000-4000-8000-000000000001" \
  "/api/projects" \
  "/api/health"
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

Every listed route should return:

```text
200
```

Create a temporary project in production mode:

```bash
PRODUCTION_RESPONSE="$(
  curl --fail --silent \
    --request POST \
    --header "Content-Type: application/json" \
    --data '{
      "name": "Production-mode API verification",
      "description": "A temporary project proving production mutations work.",
      "status": "PLANNED"
    }' \
    http://localhost:3000/api/projects
)"

printf "%s\n" "${PRODUCTION_RESPONSE}" |
  python -m json.tool

PRODUCTION_PROJECT_ID="$(
  printf "%s" "${PRODUCTION_RESPONSE}" |
    python -c '
import json, sys
print(json.load(sys.stdin)["data"]["id"])
'
)"
```

Verify its page:

```bash
curl --fail --silent \
  "http://localhost:3000/projects/${PRODUCTION_PROJECT_ID}" |
  grep --quiet "Production-mode API verification"

echo "Production mutation verified."
```

Delete it:

```bash
curl --silent \
  --request DELETE \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  "http://localhost:3000/api/projects/${PRODUCTION_PROJECT_ID}"
```

Expected output:

```text
204
```

Stop the production server:

```text
Ctrl+C
```

Restore the seed once more:

```bash
npm run db:seed
```

[GENERATED: Part 7, Step 18: Production Build] [STARTING: Part 7, Step 19: Git Checkpoint]

---

# Step 19: Create the Part 7 Git Checkpoint

## The Target

Commit the API, Server Action, form, task-management, and mutation work.

## The Concept

This checkpoint captures the transition from a read-only database application to a full-stack system.

The commit should contain:

- Shared validation schemas
- Mutation functions
- Task query support
- API response utilities
- Project Route Handlers
- Health Route Handler
- Server Actions
- Project creation form
- Task creation and status controls
- Form and task styles

It should not contain generated database data or `.env.local`.

## The Implementation

Inspect the repository:

```bash
git status
git diff --stat
git diff
```

Run the final quality gate:

```bash
npm run typecheck
npm run lint
npm run build
```

Stage the Part 7 changes:

```bash
git add src
```

No dependency or database migration was introduced in this part, so `src` contains the expected source changes.

Inspect staged files:

```bash
git diff --cached --stat
git status --short
```

Create the commit:

```bash
git commit -m "feat: add APIs and full-stack mutations"
```

## The Verification

Inspect the latest commit:

```bash
git log -1 --oneline
```

Expected output resembles:

```text
d4e5f6a feat: add APIs and full-stack mutations
```

Confirm a clean working tree:

```bash
git status
```

Expected output:

```text
nothing to commit, working tree clean
```

[GENERATED: Part 7, Step 19: Git Checkpoint] [STARTING: Part 7 Reference Sections]

---

# Part 7 Reference A: Route Handlers

A Route Handler is defined in a `route.ts` file:

```text
src/app/api/projects/route.ts
```

It exports one or more HTTP method functions:

```ts
export async function GET() {
  return Response.json({
    data: [],
  });
}

export async function POST(request: Request) {
  const body = await request.json();

  return Response.json(
    {
      data: body,
    },
    {
      status: 201,
    },
  );
}
```

Supported methods include:

```text
GET
POST
PUT
PATCH
DELETE
HEAD
OPTIONS
```

Route Handlers use standard web-platform objects:

- `Request`
- `Response`
- `Headers`
- `URL`
- `FormData`

Next.js also provides helpers such as `NextResponse`.

---

# Part 7 Reference B: HTTP Method Semantics

## GET

Reads a resource without intentionally changing it:

```text
GET /api/projects
GET /api/projects/:projectId
```

GET requests should be safe and idempotent.

## POST

Creates a resource or triggers a non-idempotent operation:

```text
POST /api/projects
```

Sending the same creation request twice may create two records.

## PATCH

Partially changes a resource:

```text
PATCH /api/projects/:projectId
```

Only supplied fields change.

## PUT

Usually replaces a complete resource representation.

LaunchPad does not currently expose PUT.

## DELETE

Removes a resource:

```text
DELETE /api/projects/:projectId
```

A successful deletion may return:

```text
204 No Content
```

A `204` response must not include a response body.

---

# Part 7 Reference C: Important HTTP Status Codes

| Status | Meaning | LaunchPad usage |
|---:|---|---|
| `200` | Request succeeded | Reads and updates |
| `201` | Resource created | Project creation |
| `204` | Success without body | Project deletion |
| `400` | Malformed request | Invalid ID, JSON, or content type |
| `401` | Authentication required | Added in Part 8 |
| `403` | Authenticated but forbidden | Added in Part 8 |
| `404` | Resource absent | Missing project |
| `409` | State conflict | Useful for duplicate/conflicting state |
| `422` | Valid syntax, invalid content | Zod validation failure |
| `429` | Too many requests | Future rate limiting |
| `500` | Unexpected server failure | Safe generic API error |
| `503` | Required service unavailable | Failed health check |

Status codes are part of an API’s contract. Do not return `200` for every outcome.

---

# Part 7 Reference D: Server Actions

A Server Action is marked with:

```ts
"use server";
```

Example:

```ts
"use server";

export async function createSomething(
  formData: FormData,
) {
  const name = formData.get("name");

  // Validate and mutate on the server.
}
```

A form can invoke it:

```tsx
<form action={createSomething}>
  <input name="name" />
  <button type="submit">Create</button>
</form>
```

Server Actions are useful for mutations originating in a Next.js interface.

They do not replace Route Handlers when an explicit HTTP API is required.

---

# Part 7 Reference E: Server Actions Are Public Server Entry Points

A function being located in a server file does not mean it can trust its arguments.

Treat every Server Action like an externally callable endpoint.

It must:

- Validate form data
- Validate bound identifiers
- Authenticate the caller
- Authorize the operation
- Handle expected failures
- Avoid exposing secrets in returned state

Part 8 will add authentication and ownership checks to these actions.

This code would be unsafe:

```ts
"use server";

export async function deleteProject(projectId: string) {
  await database`
    DELETE FROM projects
    WHERE id = ${projectId}
  `;
}
```

It validates neither identity nor ownership.

---

# Part 7 Reference F: Route Handlers Versus Server Actions

Use a Route Handler when you need:

- A stable HTTP URL
- JSON request and response bodies
- Third-party access
- Mobile-client access
- Webhooks
- Health checks
- Explicit HTTP caching or status semantics

Use a Server Action when:

- A Next.js form or component triggers the mutation
- The operation belongs closely to the rendered application
- You want direct integration with revalidation and form state
- No external HTTP API is required

Both should call shared application and database functions rather than duplicating rules.

---

# Part 7 Reference G: Form Validation Layers

LaunchPad now uses several validation layers.

## HTML constraints

```tsx
<input
  required
  maxLength={120}
/>
```

Benefits:

- Immediate browser feedback
- Better user experience
- No server round trip for simple omissions

Limit:

- Callers can bypass them.

## Zod validation

```ts
createProjectInputSchema.safeParse(input)
```

Benefits:

- Runs on the server
- Produces structured errors
- Reusable by Route Handlers and Server Actions

## Database constraints

```sql
CHECK (length(trim(name)) > 0)
```

Benefits:

- Protects data regardless of which application writes it
- Enforces relational integrity

All three layers are useful. They solve different problems.

---

# Part 7 Reference H: Revalidation

After a mutation, previously rendered routes may no longer represent current data.

LaunchPad calls:

```ts
revalidatePath("/dashboard");
revalidatePath("/projects");
revalidatePath(`/projects/${projectId}`);
```

Revalidation should occur at the mutation boundary, where the application knows which views were affected.

Do not indiscriminately revalidate the entire application after every mutation. Broad invalidation can remove the performance benefits of caching.

As LaunchPad’s cache policy becomes more sophisticated, cache tags may offer more targeted invalidation.

---

# Part 7 Reference I: Redirects in Server Actions

A successful create operation commonly redirects to the new resource:

```ts
redirect(`/projects/${project.id}`);
```

Next.js implements `redirect` through framework control flow.

Avoid catching it accidentally:

```ts
try {
  redirect("/projects");
} catch {
  return {
    status: "error",
  };
}
```

The catch block would intercept the redirect signal.

Instead:

```ts
let projectId: string;

try {
  const project = await createProject(input);
  projectId = project.id;
} catch {
  return {
    status: "error",
  };
}

redirect(`/projects/${projectId}`);
```

---

# Part 7 Reference J: Pending Form State

React’s `useActionState` returns:

```tsx
const [state, formAction, isPending] =
  useActionState(action, initialState);
```

- `state` contains the latest action result.
- `formAction` is supplied to the form.
- `isPending` indicates an in-progress submission.

Example:

```tsx
<button disabled={isPending}>
  {isPending ? "Saving…" : "Save"}
</button>
```

Pending state helps prevent accidental repeated submission and communicates that work is occurring.

The database must still tolerate duplicate requests safely where business requirements demand it. A disabled button alone is not a concurrency guarantee.

---

# Part 7 Reference K: API Error Design

A useful API error should be:

- Predictable
- Machine-readable
- Safe
- Actionable
- Consistent across endpoints

LaunchPad uses:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The project input is invalid.",
    "details": [
      {
        "path": "name",
        "message": "Enter a project name."
      }
    ]
  }
}
```

Do not expose:

```json
{
  "error": "password authentication failed for user launchpad"
}
```

Raw internal errors can reveal implementation and infrastructure details.

Log diagnostic information server-side and return a safe public response.

---

# Part 7 Reference L: Health Checks

A health check answers whether an application instance can perform essential work.

A shallow check might only prove that the process is running.

A dependency-aware check can verify:

- Database connectivity
- Required service availability
- Critical configuration

Health checks should be:

- Fast
- Dynamic
- Safe to expose to infrastructure
- Free of secrets
- Conservative about declaring success

Avoid expensive full-table scans or third-party operations in a frequently requested health endpoint.

Production platforms may distinguish:

- **Liveness:** Is the process alive?
- **Readiness:** Is it ready to receive traffic?

LaunchPad currently provides one simple dependency-aware endpoint. Part 10 will revisit operational readiness.

---

# Part 7 Reference M: Database Transactions

A transaction groups mutations into one atomic unit:

```ts
await database.begin(async (transaction) => {
  await transaction`
    INSERT INTO projects (...)
    VALUES (...)
  `;

  await transaction`
    INSERT INTO tasks (...)
    VALUES (...)
  `;
});
```

**Atomic** means either all grouped changes succeed or none of them are committed.

Use a transaction when several writes must remain consistent together.

LaunchPad’s current mutations generally perform one primary write followed by a noncritical parent timestamp update. As workflows become more complex, those related writes should be reviewed for transaction boundaries.

Do not use transactions around slow network calls. Holding a database transaction open while waiting on external services can increase contention and failure risk.

---

# Part 7 Reference N: Mutation Concurrency

Two users or requests may update the same record at nearly the same time.

The current status update uses last-write-wins behavior:

```sql
UPDATE tasks
SET status = ...
WHERE id = ...
```

More demanding workflows may require **optimistic concurrency control**.

That pattern can compare an expected version or timestamp:

```sql
UPDATE tasks
SET
  status = $new_status,
  updated_at = CURRENT_TIMESTAMP
WHERE id = $task_id
  AND updated_at = $expected_updated_at
```

If no row updates, the client knows the record changed since it was read.

LaunchPad does not add version control yet because task status conflicts are low-risk in the current single-user development phase.

---

# Part 7 Reference O: Current Full-Stack Request Flows

## Project creation form

```text
CreateProjectForm
    ↓ FormData
createProjectAction
    ↓ Zod validation
createProject
    ↓ parameterized SQL
PostgreSQL
    ↓
revalidatePath
    ↓
redirect to project
```

## Project creation API

```text
POST /api/projects
    ↓ JSON parsing
createProjectInputSchema
    ↓
createProject
    ↓
PostgreSQL
    ↓
201 JSON response
```

## Task creation form

```text
CreateTaskForm
    ↓
createTaskAction
    ↓ project ID and field validation
createTask
    ↓
PostgreSQL
    ↓
route revalidation
    ↓
updated task list
```

## Health check

```text
GET /api/health
    ↓
SELECT 1
    ↓
200 ok or 503 degraded
```

---

# Part 7 Reference P: Security Limitations Before Part 8

At this point, the APIs and Server Actions validate input but do not authenticate callers.

That means anyone able to reach the application can currently:

- Create projects
- Update projects through the API
- Delete projects through the API
- Create tasks through rendered forms
- Change task statuses

This is not acceptable for a public production deployment.

Do not expose the Part 7 application publicly as a finished system.

Part 8 will add:

- User records
- Password hashing
- Session management
- Protected workspace routes
- API authentication
- Server Action authentication
- Project ownership
- Authorization conditions in SQL

Validation answers:

> Is this input structurally acceptable?

Authentication answers:

> Who is making this request?

Authorization answers:

> May that user perform this operation?

All three are required.

---

# Part 7 Reference Q: Current Project Structure

After Part 7, the important additions are:

```text
src/
├── app/
│   ├── (workspace)/
│   │   └── projects/
│   │       ├── [projectId]/
│   │       │   ├── actions.ts
│   │       │   └── page.tsx
│   │       ├── new/
│   │       │   └── page.tsx
│   │       ├── actions.ts
│   │       └── page.tsx
│   └── api/
│       ├── health/
│       │   └── route.ts
│       └── projects/
│           ├── [projectId]/
│           │   └── route.ts
│           └── route.ts
├── components/
│   ├── create-project-form.tsx
│   ├── create-task-form.tsx
│   ├── task-list.tsx
│   └── ...
└── lib/
    ├── database/
    │   ├── health.ts
    │   ├── project-mutations.ts
    │   ├── project-queries.ts
    │   └── schemas.ts
    ├── action-state.ts
    ├── api-response.ts
    ├── project-inputs.ts
    └── task-types.ts
```

---

# Part 7 Reference R: Common Full-Stack Mistakes

## Mistake 1: Trusting form controls

Browser constraints can be bypassed. Validate again on the server.

## Mistake 2: Duplicating mutation SQL

Server Actions and Route Handlers should call shared mutation functions.

## Mistake 3: Returning raw exceptions

Log technical details server-side and return safe API messages.

## Mistake 4: Using `200` for every response

Use status codes that accurately describe the outcome.

## Mistake 5: Catching `redirect()`

Keep redirects outside ordinary mutation `try/catch` blocks.

## Mistake 6: Forgetting revalidation

A successful database write can leave rendered interfaces stale.

## Mistake 7: Treating Server Actions as private functions

They are server entry points and require validation, authentication, and authorization.

## Mistake 8: Building a health endpoint that is cached

A cached health response can report obsolete success.

## Mistake 9: Sending a body with `204`

A `204 No Content` response must not contain response content.

## Mistake 10: Assuming validation provides authorization

Valid input can still describe an operation the caller has no right to perform.

---

# Part 7 Completion Checklist

Before continuing, confirm every item:

- [ ] Shared Zod schemas validate project and task inputs.
- [ ] Validation lengths match database constraints.
- [ ] Task types define supported statuses and priorities.
- [ ] Database result schemas validate task rows.
- [ ] Task queries remain server-only.
- [ ] Mutation queries remain server-only.
- [ ] SQL values are parameterized.
- [ ] `GET /api/projects` returns project JSON.
- [ ] API status filtering works.
- [ ] `POST /api/projects` returns `201`.
- [ ] Invalid project JSON returns a structured error.
- [ ] Incorrect content types return `400`.
- [ ] Malformed JSON returns `400`.
- [ ] Invalid project fields return `422`.
- [ ] `GET /api/projects/:id` returns one project.
- [ ] `PATCH /api/projects/:id` updates supplied fields.
- [ ] `DELETE /api/projects/:id` returns `204`.
- [ ] Invalid API UUIDs return `400`.
- [ ] Missing API resources return `404`.
- [ ] `/api/health` returns `200` with PostgreSQL available.
- [ ] `/api/health` returns `503` when PostgreSQL is unavailable.
- [ ] `/projects/new` renders an accessible creation form.
- [ ] The project Server Action validates input.
- [ ] Successful project creation redirects to its detail page.
- [ ] Project creation revalidates affected routes.
- [ ] Project detail pages render database-backed tasks.
- [ ] Task creation validates form input.
- [ ] Successful task creation resets the form.
- [ ] Task status updates require both project and task IDs.
- [ ] Task mutations refresh counts and progress.
- [ ] Form feedback is communicated with text.
- [ ] Pending buttons are disabled and readable.
- [ ] Task interfaces remain usable on narrow screens.
- [ ] Print output hides mutation controls.
- [ ] The seed restores 4 projects and 12 tasks.
- [ ] `npm run typecheck` succeeds.
- [ ] `npm run lint` succeeds.
- [ ] `npm run build` succeeds.
- [ ] Production API and page verification succeeds.
- [ ] Git contains the Part 7 checkpoint.
- [ ] `git status` reports a clean working tree.

LaunchPad is now a full-stack application. It can expose JSON APIs, execute form-backed Server Actions, validate untrusted input, mutate PostgreSQL safely, revalidate affected routes, and communicate pending, success, validation, and failure states.

The application is not yet safe for public multi-user deployment because it lacks authentication and record ownership. Those security boundaries are the focus of Part 8.
