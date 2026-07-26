# Primer 9: Reading Existing Code and Navigating a Next.js Codebase

As applications grow, an important engineering skill is reading existing code before changing it.

You will rarely begin every project from an empty folder. More often, you will need to answer questions like:

- Where is this route implemented?
- Which component renders this button?
- Where does this data come from?
- Which Server Action handles this form?
- Is this module safe to import into a Client Component?
- Where is authorization enforced?
- Which files need to change for a new feature?

This primer teaches a practical method for navigating a Next.js codebase such as LaunchPad.

---

## 1. Start with the User-Facing URL

When investigating a page, begin with its URL.

Suppose the browser displays:

```text
/projects/10000000-0000-4000-8000-000000000001
```

Break it into segments:

```text
/projects/:projectId
```

Then look for the matching App Router path:

```text
src/app/(workspace)/projects/[projectId]/page.tsx
```

The route-group name:

```text
(workspace)
```

does not appear in the browser URL.

The mapping is:

```text
Browser URL
    ↓
/projects/:projectId
    ↓
App Router file
    ↓
src/app/(workspace)/projects/[projectId]/page.tsx
```

---

## 2. Read Routes from the Outside In

A route is often wrapped by several layouts.

For this route:

```text
/projects/:projectId
```

the relevant files may be:

```text
src/app/layout.tsx
src/app/(workspace)/layout.tsx
src/app/(workspace)/projects/[projectId]/page.tsx
```

Read them in this order:

```text
1. Root layout
2. Route-group layout
3. Route page
4. Child components
5. Server queries and actions
```

This helps you understand what each layer owns.

For example:

```text
Root layout
├── Global fonts
├── Global CSS
├── Skip link
└── Web Vitals reporter

Workspace layout
├── Requires authenticated user
├── Shows account bar
├── Shows workspace navigation
└── Defines workspace shell

Project page
├── Validates project ID
├── Loads owned project
├── Loads tasks
└── Renders project-specific content
```

---

## 3. Find a Component from Visible Text

Suppose you see this browser text:

```text
Load project insights
```

Search the source tree.

macOS, Linux, or Git Bash:

```bash
grep -R \
  "Load project insights" \
  src \
  --include="*.tsx"
```

PowerShell:

```powershell
Get-ChildItem src -Recurse -Filter "*.tsx" |
  Select-String -Pattern "Load project insights"
```

Expected result:

```text
src/components/project-insights-loader.tsx
```

From there, inspect imports and usage.

For example:

```tsx
import dynamic from "next/dynamic";
import { useState } from "react";
```

These imports indicate that the component is browser-interactive and likely a Client Component.

---

## 4. Follow Imports Downward

Imports reveal dependencies.

Example:

```tsx
import { ProjectCard } from "@/components/project-card";
import { getProjects } from "@/lib/database/project-queries";
import { requireUser } from "@/lib/auth/session";
```

This tells you the route:

```text
- Renders a reusable ProjectCard
- Queries PostgreSQL
- Requires an authenticated user
```

The import graph is:

```text
Projects page
├── requireUser()
├── getProjects()
└── ProjectCard
```

You can search for a function’s definition:

```bash
grep -R \
  "export async function getProjects" \
  src \
  --include="*.ts"
```

Expected result:

```text
src/lib/database/project-queries.ts
```

---

## 5. Follow Data from the Database to the Browser

When a project name appears on a page, trace it through layers.

```text
PostgreSQL row
    ↓
Owner-scoped SQL query
    ↓
Validated query result
    ↓
Server Component prop
    ↓
Reusable ProjectCard
    ↓
Browser-rendered text
```

Example query:

```ts
export async function getProjects(
  userId: string,
): Promise<ProjectSummary[]> {
  const rows = await database`
    SELECT
      p.id,
      p.name,
      p.description,
      p.status
    FROM projects AS p
    WHERE p.owner_id = ${userId}
  `;

  return projectSummaryListSchema.parse(rows);
}
```

Example page:

```tsx
const user = await requireUser();
const projects = await getProjects(user.id);

return <ProjectList projects={projects} />;
```

Example component:

```tsx
<ProjectCard
  key={project.id}
  project={project}
/>
```

Example card:

```tsx
<h3>{project.name}</h3>
```

This tracing method is useful when data is:

```text
- Missing
- Incorrect
- Stale
- Visible to the wrong user
- Rendered with unexpected formatting
```

---

## 6. Find the Server Action Behind a Form

Suppose you see a form button:

```text
Create project
```

Start with the form component.

Search:

```bash
grep -R \
  "Create project" \
  src \
  --include="*.tsx"
```

You may find:

```tsx
<button
  className="primary-button"
  type="submit"
>
  Create project
</button>
```

Then inspect the nearest `<form>`:

```tsx
<form action={formAction}>
```

Then inspect where `formAction` came from:

```tsx
const [state, formAction, isPending] = useActionState(
  createProjectAction,
  INITIAL_FORM_ACTION_STATE,
);
```

Then find the action:

```bash
grep -R \
  "createProjectAction" \
  src \
  --include="*.ts" \
  --include="*.tsx"
```

Expected location:

```text
src/app/(workspace)/projects/actions.ts
```

Then follow the action:

```text
createProjectAction
    ↓
requireUser()
    ↓
createProjectInputSchema.safeParse()
    ↓
createProject(user.id, input)
    ↓
revalidatePath()
    ↓
redirect()
```

This shows the complete mutation lifecycle.

---

## 7. Find Authorization Enforcement

When reviewing private data access, do not stop at the page or Server Action.

Find the database query or mutation.

For example, search for:

```bash
grep -R \
  "getProjectById" \
  src \
  --include="*.ts" \
  --include="*.tsx"
```

Then inspect the query implementation.

Safe query:

```ts
export const getProjectById = cache(
  async (
    userId: string,
    projectId: string,
  ) => {
    const rows = await database`
      SELECT
        p.id,
        p.name,
        p.description,
        p.status
      FROM projects AS p
      WHERE p.id = ${projectId}
        AND p.owner_id = ${userId}
      LIMIT 1
    `;

    return rows[0] ?? null;
  },
);
```

The security-critical line is:

```sql
AND p.owner_id = ${userId}
```

Without that condition, one user might retrieve another user’s project by changing the UUID in the URL.

---

## 8. Identify Server-Only Modules

Server-only files usually begin with:

```ts
import "server-only";
```

Search for them:

```bash
grep -R \
  'import "server-only"' \
  src \
  --include="*.ts" \
  --include="*.tsx"
```

Expected examples:

```text
src/lib/auth/accounts.ts
src/lib/auth/session.ts
src/lib/database/client.ts
src/lib/database/project-queries.ts
src/lib/database/project-mutations.ts
src/lib/environment.ts
src/lib/logger.ts
```

These modules must not be imported by Client Components.

They commonly contain:

```text
- PostgreSQL access
- Session handling
- Password hashing
- Environment variables
- Node.js crypto
- Authorization logic
```

---

## 9. Identify Client Components

Search for the client directive:

```bash
grep -R -l \
  '"use client"' \
  src \
  --include="*.tsx" |
  sort
```

A Client Component may include:

```tsx
"use client";

import { useState } from "react";
```

or:

```tsx
"use client";

import { useActionState } from "react";
```

or browser API code:

```tsx
navigator.clipboard.writeText(
  window.location.href,
);
```

Before changing a Client Component, inspect all its imports.

Ask:

```text
Does any import lead to:
- PostgreSQL?
- Session utilities?
- Environment variables?
- Password handling?
- Server-only code?
```

If yes, the component boundary is unsafe.

---

## 10. Use File Names to Predict Responsibilities

LaunchPad uses consistent naming patterns.

| File pattern | Likely responsibility |
|---|---|
| `page.tsx` | Route UI |
| `layout.tsx` | Shared route structure |
| `loading.tsx` | Loading UI |
| `error.tsx` | Error boundary |
| `route.ts` | HTTP endpoint |
| `actions.ts` | Server Actions |
| `*-inputs.ts` | Zod input schemas |
| `*-types.ts` | Shared types and pure helpers |
| `*-queries.ts` | Database reads |
| `*-mutations.ts` | Database writes |
| `*.module.css` | Component-local styles |
| `*.test.ts` | Future automated tests |
| `migrations/*.sql` | Database schema history |

Names are not a security feature, but consistent naming reduces cognitive load.

---

## 11. Read a Feature as a Vertical Slice

Suppose you want to understand task status updates.

Do not read only the button.

Trace the full slice:

```text
TaskList component
    ↓
Status update form
    ↓
updateTaskStatusAction
    ↓
requireUser()
    ↓
Task status Zod schema
    ↓
updateTaskStatus(user.id, projectId, taskId, input)
    ↓
Owner-scoped SQL UPDATE
    ↓
revalidatePath()
    ↓
Updated task list
```

This is the correct level of understanding for a production feature.

---

## 12. Search Strategies

### Search for visible text

```bash
grep -R \
  "No tasks yet" \
  src \
  --include="*.tsx"
```

### Search for a function definition

```bash
grep -R \
  "export async function createTask" \
  src \
  --include="*.ts"
```

### Search for a database table

```bash
grep -R \
  "FROM projects\|INSERT INTO projects\|UPDATE projects" \
  src \
  --include="*.ts"
```

### Search for a route path

```bash
grep -R \
  '"/projects' \
  src \
  --include="*.ts" \
  --include="*.tsx"
```

### Search for client boundaries

```bash
grep -R \
  '"use client"' \
  src \
  --include="*.tsx"
```

### Search for ownership conditions

```bash
grep -R \
  'owner_id = \${userId}' \
  src/lib/database \
  --include="*.ts"
```

---

## 13. Read Configuration Before Changing Deployment Behavior

When working on deployment, inspect these files first:

```text
.env.example
src/lib/environment.ts
src/lib/database/client.ts
next.config.ts
Dockerfile
.github/workflows/ci.yml
docs/production-runbook.md
```

They answer different questions:

| File | Question answered |
|---|---|
| `.env.example` | Which values are required? |
| `environment.ts` | How are values validated? |
| `database/client.ts` | How does PostgreSQL connect? |
| `next.config.ts` | How does Next.js build and set headers? |
| `Dockerfile` | How is runtime packaged? |
| `ci.yml` | What does automation verify? |
| Runbook | How is the system operated? |

---

## 14. Avoid These Code-Reading Mistakes

### Mistake 1: Editing before understanding the data flow

Avoid opening a page and immediately changing JSX.

First identify:

```text
- Where data comes from
- Which user owns it
- Which query authorizes it
- Which components render it
```

---

### Mistake 2: Assuming route layouts provide all security

A workspace layout may require authentication, but Route Handlers and Server Actions still need their own checks.

Do not assume:

```text
“This code lives under (workspace), so it is safe.”
```

Check the actual server entry point.

---

### Mistake 3: Searching only for component names

A component may be re-exported, dynamically imported, or rendered through another wrapper.

Search for:

```text
- Visible text
- Function names
- File names
- Import paths
- Database table names
- Route URLs
```

---

### Mistake 4: Ignoring the database layer

A page can look secure while the query is unsafe.

Always inspect:

```text
Server Component
    ↓
Server Action or API
    ↓
Database query or mutation
```

---

### Mistake 5: Treating all `404` results as missing data

For private LaunchPad resources:

```text
404 may mean missing or unauthorized.
```

Inspect ownership before assuming the record was deleted.

---

## 15. Primer Verification Exercise

Trace project creation through LaunchPad.

Start from:

```text
/projects/new
```

Find and answer:

1. Which file renders the page?
2. Which component renders the form?
3. Which Server Action receives the submission?
4. Which Zod schema validates input?
5. Which mutation creates the database record?
6. Where does `owner_id` come from?
7. Which routes are revalidated?
8. Where does the browser redirect after success?

Expected flow:

```text
projects/new/page.tsx
    ↓
CreateProjectForm
    ↓
createProjectAction
    ↓
createProjectInputSchema
    ↓
createProject(user.id, input)
    ↓
authenticated server session
    ↓
revalidatePath("/dashboard")
revalidatePath("/projects")
    ↓
redirect(`/projects/${projectId}`)
```

---

## 16. Primer Completion Checklist

Before returning to the main series, confirm that you can:

- [ ] Map a URL to its App Router file.
- [ ] Identify layouts that wrap a route.
- [ ] Find a component from visible browser text.
- [ ] Follow imports from page to component to data layer.
- [ ] Trace database data into rendered UI.
- [ ] Find the Server Action behind a form.
- [ ] Find the Route Handler behind an API URL.
- [ ] Locate authorization conditions in SQL.
- [ ] Identify server-only modules.
- [ ] Identify Client Components.
- [ ] Explain why Client Components cannot import database code.
- [ ] Use `grep` or `Select-String` to search the source tree.
- [ ] Read a feature as a complete vertical slice.
- [ ] Identify the configuration files affecting a deployment.
- [ ] Avoid editing code before understanding its data and security flow.
