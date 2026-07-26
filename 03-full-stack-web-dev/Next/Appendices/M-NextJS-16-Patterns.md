# Appendix M: Common Next.js 16 Patterns Cookbook

This appendix provides short, practical patterns you can reuse when extending LaunchPad.

Each recipe includes:

- When to use it
- The key idea
- A complete implementation example
- Important safety notes

---

# M.1 Require Authentication in a Server Page

## Use when

A page should only be visible to signed-in users.

## Pattern

```tsx
import { requireUser } from "@/lib/auth/session";

export default async function PrivatePage() {
  const user = await requireUser();

  return (
    <main>
      <h1>Welcome, {user.name}</h1>
    </main>
  );
}
```

## How it works

`requireUser()`:

1. Reads the HTTP-only session cookie.
2. Hashes the token.
3. Looks up the session in PostgreSQL.
4. Loads the current user.
5. Redirects to `/sign-in` if no valid session exists.

## Important note

This protects page rendering, but it does not replace authorization inside APIs, Server Actions, or database mutations.

---

# M.2 Return `404` for a Missing or Unauthorized Private Record

## Use when

A private resource should not reveal whether it exists to someone who does not own it.

## Pattern

```tsx
import { notFound } from "next/navigation";
import { z } from "zod";

import { requireUser } from "@/lib/auth/session";
import { getProjectById } from "@/lib/database/project-queries";

const projectIdSchema = z.string().uuid();

type ProjectPageProps = {
  params: Promise<{
    projectId: string;
  }>;
};

export default async function ProjectPage({
  params,
}: ProjectPageProps) {
  const user = await requireUser();
  const { projectId } = await params;

  const parsedProjectId = projectIdSchema.safeParse(projectId);

  if (!parsedProjectId.success) {
    notFound();
  }

  const project = await getProjectById(
    user.id,
    parsedProjectId.data,
  );

  if (!project) {
    notFound();
  }

  return (
    <main>
      <h1>{project.name}</h1>
      <p>{project.description}</p>
    </main>
  );
}
```

## Important note

The database query must include:

```sql
owner_id = ${userId}
```

Calling `notFound()` after an unrestricted query is weaker because unauthorized data may already have been retrieved.

---

# M.3 Validate a UUID Route Parameter

## Use when

A dynamic route receives a database UUID.

## Pattern

```ts
import { z } from "zod";

const identifierSchema = z.string().uuid();

export function parseUuid(
  value: string,
): string | null {
  const result = identifierSchema.safeParse(value);

  return result.success
    ? result.data
    : null;
}
```

Usage:

```tsx
const parsedProjectId = parseUuid(projectId);

if (!parsedProjectId) {
  notFound();
}
```

## Why validate first

Sending arbitrary invalid strings to a PostgreSQL UUID comparison can create avoidable database errors.

Validation also makes missing-resource behavior consistent.

---

# M.4 Validate URL Search Parameters

## Use when

A route supports filters, sorting, pagination, or search terms.

## Pattern

```ts
import { z } from "zod";

const projectListSearchParamsSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  query: z.string().trim().max(100).default(""),
  status: z
    .enum([
      "PLANNED",
      "ACTIVE",
      "COMPLETED",
    ])
    .optional(),
});

type ProjectListSearchParams = z.infer<
  typeof projectListSearchParamsSchema
>;

export function parseProjectListSearchParams(
  input: Record<string, string | string[] | undefined>,
): ProjectListSearchParams {
  return projectListSearchParamsSchema.parse({
    page:
      typeof input.page === "string"
        ? input.page
        : undefined,
    query:
      typeof input.query === "string"
        ? input.query
        : undefined,
    status:
      typeof input.status === "string"
        ? input.status.toUpperCase()
        : undefined,
  });
}
```

## Example page usage

```tsx
type ProjectsPageProps = {
  searchParams: Promise<{
    page?: string | string[];
    query?: string | string[];
    status?: string | string[];
  }>;
};

export default async function ProjectsPage({
  searchParams,
}: ProjectsPageProps) {
  const rawSearchParams = await searchParams;

  const filters = parseProjectListSearchParams(
    rawSearchParams,
  );

  return (
    <main>
      <h1>Projects</h1>
      <p>Current page: {filters.page}</p>
    </main>
  );
}
```

---

# M.5 Create an Owner-Scoped Query

## Use when

A user should only read their own records.

## Pattern

```ts
import "server-only";

import { database } from "@/lib/database/client";

export async function getOwnedProject(
  userId: string,
  projectId: string,
) {
  const rows = await database`
    SELECT
      id,
      name,
      description,
      status
    FROM projects
    WHERE id = ${projectId}
      AND owner_id = ${userId}
    LIMIT 1
  `;

  return rows[0] ?? null;
}
```

## Security rule

Never write a private query like this:

```ts
WHERE id = ${projectId}
```

without ownership or role-aware authorization conditions.

---

# M.6 Create a Project Through a Server Action

## Use when

A Next.js form creates a record.

## Pattern

### `src/app/(workspace)/projects/actions.ts`

```ts
"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

import {
  createFieldErrors,
  type FormActionState,
} from "@/lib/action-state";
import { requireUser } from "@/lib/auth/session";
import { createProject } from "@/lib/database/project-mutations";
import { createProjectInputSchema } from "@/lib/project-inputs";

export async function createProjectAction(
  _previousState: FormActionState,
  formData: FormData,
): Promise<FormActionState> {
  const user = await requireUser();

  const parsedInput = createProjectInputSchema.safeParse({
    name: formData.get("name"),
    description: formData.get("description"),
    status: formData.get("status"),
  });

  if (!parsedInput.success) {
    return {
      status: "error",
      message: "Correct the highlighted project fields.",
      fieldErrors: createFieldErrors(
        parsedInput.error.issues,
      ),
    };
  }

  let projectId: string;

  try {
    const project = await createProject(
      user.id,
      parsedInput.data,
    );

    projectId = project.id;
  } catch (error) {
    console.error("Project creation failed.", error);

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

## Important note

Do not wrap `redirect()` inside the mutation `try/catch`.

---

# M.7 Build a Form with Pending State

## Use when

A form calls a Server Action and needs client-side pending and validation feedback.

## Pattern

```tsx
"use client";

import { useActionState } from "react";

import { createProjectAction } from "@/app/(workspace)/projects/actions";
import { INITIAL_FORM_ACTION_STATE } from "@/lib/action-state";

export function ExampleProjectForm() {
  const [state, formAction, isPending] = useActionState(
    createProjectAction,
    INITIAL_FORM_ACTION_STATE,
  );

  return (
    <form action={formAction}>
      <label htmlFor="name">Project name</label>

      <input
        id="name"
        name="name"
        required
        aria-invalid={
          state.fieldErrors?.name ? true : undefined
        }
      />

      {state.fieldErrors?.name?.map((message) => (
        <p key={message} role="alert">
          {message}
        </p>
      ))}

      <button type="submit" disabled={isPending}>
        {isPending ? "Creating…" : "Create project"}
      </button>
    </form>
  );
}
```

## Important note

Disabling a submit button improves user experience, but it does not guarantee idempotency. The server still needs to tolerate duplicate requests according to business requirements.

---

# M.8 Return a Private JSON API Response

## Use when

A Route Handler returns user-specific data.

## Pattern

```ts
import {
  apiError,
  apiSuccess,
  PRIVATE_NO_STORE_HEADERS,
} from "@/lib/api-response";
import { requireApiUser } from "@/lib/auth/session";
import { getProjects } from "@/lib/database/project-queries";

export const dynamic = "force-dynamic";

export async function GET() {
  const user = await requireApiUser();

  if (!user) {
    return apiError(
      401,
      "UNAUTHORIZED",
      "Authentication is required.",
      undefined,
      PRIVATE_NO_STORE_HEADERS,
    );
  }

  const projects = await getProjects(user.id);

  return apiSuccess(projects, {
    headers: PRIVATE_NO_STORE_HEADERS,
  });
}
```

## Required response policy

```http
Cache-Control: private, no-store
Vary: Cookie
```

Never use a public shared cache for user-specific API data unless identity is deliberately included in a safe cache design.

---

# M.9 Create a Public No-Store Health Endpoint

## Use when

Infrastructure needs to verify process or dependency availability.

## Pattern

```ts
import {
  apiSuccess,
  PUBLIC_NO_STORE_HEADERS,
} from "@/lib/api-response";
import { serverEnvironment } from "@/lib/environment";

export const dynamic = "force-dynamic";

export async function GET() {
  return apiSuccess(
    {
      status: "alive",
      checkedAt: new Date().toISOString(),
      version: serverEnvironment.appVersion,
    },
    {
      headers: PUBLIC_NO_STORE_HEADERS,
    },
  );
}
```

## Important note

Health responses must not be cached as successful results.

Use:

```http
Cache-Control: no-store
```

---

# M.10 Load Independent Server Data in Parallel

## Use when

Two queries do not depend on one another.

## Pattern

```tsx
const projectPromise = getProjectById(
  user.id,
  projectId,
);

const tasksPromise = getTasksForProject(
  user.id,
  projectId,
);

const [project, tasks] = await Promise.all([
  projectPromise,
  tasksPromise,
]);
```

## Do not use when

The second query needs data from the first query.

Correct sequential example:

```tsx
const project = await getProjectBySlug(
  user.id,
  slug,
);

if (!project) {
  notFound();
}

const tasks = await getTasksForProject(
  user.id,
  project.id,
);
```

---

# M.11 Stream Independent Dashboard Sections

## Use when

A page has independent sections that can load separately.

## Pattern

```tsx
import { Suspense } from "react";

import { DashboardMetrics } from "@/components/dashboard-metrics";
import { DashboardMetricsSkeleton } from "@/components/dashboard-skeletons";

export default function DashboardPage() {
  return (
    <main>
      <h1>Dashboard</h1>

      <Suspense fallback={<DashboardMetricsSkeleton />}>
        <DashboardMetrics />
      </Suspense>
    </main>
  );
}
```

## Important note

Suspense improves delivery behavior. It does not fix slow SQL. Optimize queries, indexes, and database capacity separately.

---

# M.12 Add a Focused Client Search

## Use when

The server already supplied a small, authorized list and immediate browser filtering improves usability.

## Pattern

```tsx
"use client";

import { useMemo, useState } from "react";

type SearchableProject = {
  id: string;
  name: string;
  description: string;
};

type ProjectSearchProps = {
  projects: readonly SearchableProject[];
};

export function ProjectSearch({
  projects,
}: ProjectSearchProps) {
  const [query, setQuery] = useState("");

  const visibleProjects = useMemo(() => {
    const normalizedQuery = query
      .trim()
      .toLocaleLowerCase();

    if (normalizedQuery.length === 0) {
      return projects;
    }

    return projects.filter((project) => {
      const text = [
        project.name,
        project.description,
      ]
        .join(" ")
        .toLocaleLowerCase();

      return text.includes(normalizedQuery);
    });
  }, [projects, query]);

  return (
    <>
      <label htmlFor="project-search">
        Search visible projects
      </label>

      <input
        id="project-search"
        type="search"
        value={query}
        onChange={(event) => {
          setQuery(event.target.value);
        }}
      />

      <p aria-live="polite">
        {visibleProjects.length} results
      </p>
    </>
  );
}
```

## Important note

Do not use client-side filtering as authorization.

The server must already have selected only records the user may see.

---

# M.13 Use URL State for Shareable Filters

## Use when

A filter should survive refresh and be shareable.

## Pattern

```tsx
<form action="/projects" method="get">
  <label htmlFor="status">Project status</label>

  <select
    id="status"
    name="status"
    defaultValue={selectedStatus ?? ""}
  >
    <option value="">All statuses</option>
    <option value="PLANNED">Planned</option>
    <option value="ACTIVE">Active</option>
    <option value="COMPLETED">Completed</option>
  </select>

  <button type="submit">
    Apply filter
  </button>
</form>
```

The browser produces URLs like:

```text
/projects?status=ACTIVE
```

The server validates the value before using it in a query.

---

# M.14 Dynamically Load an Optional Browser Feature

## Use when

A feature is optional and does not contain essential initial content.

## Pattern

```tsx
"use client";

import dynamic from "next/dynamic";
import { useState } from "react";

const OptionalInsights = dynamic(
  () => import("@/components/project-insights"),
  {
    ssr: false,
    loading: () => <p>Loading insights…</p>,
  },
);

export function OptionalInsightsLoader() {
  const [isVisible, setIsVisible] = useState(false);

  if (!isVisible) {
    return (
      <button
        type="button"
        onClick={() => {
          setIsVisible(true);
        }}
      >
        Load insights
      </button>
    );
  }

  return <OptionalInsights />;
}
```

## Do not use for

```text
- Essential route content
- Important headings
- Navigation
- Primary form controls
- Security-critical information
```

---

# M.15 Create an Accessible Disclosure

## Use when

A region can be expanded or collapsed.

## Pattern

```tsx
"use client";

import { useId, useState } from "react";

type DisclosureProps = {
  title: string;
  children: React.ReactNode;
};

export function Disclosure({
  title,
  children,
}: DisclosureProps) {
  const [isOpen, setIsOpen] = useState(false);
  const contentId = useId();

  return (
    <section>
      <button
        type="button"
        aria-expanded={isOpen}
        aria-controls={contentId}
        onClick={() => {
          setIsOpen((currentValue) => !currentValue);
        }}
      >
        {title}
      </button>

      <div id={contentId} hidden={!isOpen}>
        {children}
      </div>
    </section>
  );
}
```

## Accessibility requirements

- Use a real `<button>`.
- Use `aria-expanded`.
- Connect button and content with `aria-controls`.
- Support keyboard activation through normal button behavior.
- Do not rely on color alone to show open state.

---

# M.16 Add Route Metadata from Database Data

## Use when

A dynamic page title or description depends on a resource.

## Pattern

```tsx
import type { Metadata } from "next";

type ProjectPageProps = {
  params: Promise<{
    projectId: string;
  }>;
};

export async function generateMetadata({
  params,
}: ProjectPageProps): Promise<Metadata> {
  const user = await requireUser();
  const { projectId } = await params;

  const project = await getProjectById(
    user.id,
    projectId,
  );

  if (!project) {
    return {
      title: "Project not found",
      description:
        "The requested project could not be found.",
    };
  }

  return {
    title: project.name,
    description: project.description,
  };
}
```

## Important note

Metadata generation is a server operation and must respect the same authentication and authorization rules as the page.

---

# M.17 Add a Request ID to a Route Handler

## Use when

An API endpoint should help support staff correlate browser reports with server logs.

## Pattern

```ts
import {
  createRequestId,
  logError,
} from "@/lib/logger";

export async function GET(request: Request) {
  const requestId = createRequestId(request);

  try {
    return Response.json(
      {
        data: {
          status: "ok",
        },
      },
      {
        headers: {
          "X-Request-Id": requestId,
        },
      },
    );
  } catch (error) {
    logError(
      "example_route_failed",
      error,
      {
        requestId,
      },
    );

    return Response.json(
      {
        error: {
          code: "INTERNAL_ERROR",
          message: "The request could not be completed.",
        },
      },
      {
        status: 500,
        headers: {
          "X-Request-Id": requestId,
        },
      },
    );
  }
}
```

## Important note

Do not include raw cookie values, passwords, tokens, or database URLs in log context.

---

# M.18 Add a New Environment Variable Safely

## Use when

The server needs new configuration.

## Required changes

1. Add safe documentation to `.env.example`.
2. Add the variable to `src/lib/environment.ts`.
3. Validate its type and format with Zod.
4. Add it to CI configuration if required.
5. Add it to deployment-platform secrets.
6. Update runbook or deployment checklist if operationally important.

Example schema addition:

```ts
EXTERNAL_API_URL: z
  .string()
  .url("EXTERNAL_API_URL must be a valid URL."),
```

Never access a required environment variable directly throughout the application:

```ts
process.env.EXTERNAL_API_URL
```

Prefer the validated configuration object:

```ts
serverEnvironment.externalApiUrl
```

---

# M.19 Add a New Migration Safely

## Use when

Persistent schema must change.

## Pattern

Create a new file:

```text
database/migrations/003_add_project_archived_at.sql
```

```sql
BEGIN;

ALTER TABLE projects
  ADD COLUMN archived_at TIMESTAMPTZ;

CREATE INDEX projects_owner_archived_at_index
  ON projects(owner_id, archived_at);

COMMIT;
```

Apply it:

```bash
npm run db:migrate
```

Verify history:

```bash
npm run db:migrate
```

The second run should apply nothing.

## Important note

Never edit:

```text
001_create_projects_and_tasks.sql
```

or:

```text
002_add_users_sessions_and_ownership.sql
```

after they are applied in a shared environment.

---

# M.20 Add a Production-Safe Error Boundary

## Use when

A route segment needs recovery UI for unexpected failures.

## Pattern

### `src/app/(workspace)/error.tsx`

```tsx
"use client";

import { useEffect } from "react";

type ErrorBoundaryProps = {
  error: Error & {
    digest?: string;
  };
  reset: () => void;
};

export default function WorkspaceError({
  error,
  reset,
}: ErrorBoundaryProps) {
  useEffect(() => {
    console.error(
      "Workspace rendering failed.",
      error,
    );
  }, [error]);

  return (
    <main>
      <h1>LaunchPad could not load this information.</h1>

      <p>
        Please try again. If the problem continues, contact support.
      </p>

      <button
        type="button"
        onClick={() => {
          reset();
        }}
      >
        Try again
      </button>

      {error.digest ? (
        <p>
          Error reference: <code>{error.digest}</code>
        </p>
      ) : null}
    </main>
  );
}
```

## Important note

Do not render:

```tsx
<p>{error.message}</p>
```

Raw exception messages can expose implementation details.

---

# M.21 Final Cookbook Rule

When copying a pattern, preserve its complete boundary:

```text
Validation
+ authentication
+ authorization
+ parameterized SQL
+ safe error handling
+ correct cache policy
+ revalidation
```

Copying only the visible JSX or only the database statement can create a feature that appears functional but is unsafe or unreliable.
