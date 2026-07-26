# Appendix F: Next.js 16 Glossary and Concept Reference

This appendix defines the core Next.js, React, database, security, and deployment terms used throughout the LaunchPad series.

Use it as a quick reference when you encounter an unfamiliar term in a later project.

---

# F.1 Next.js and React Fundamentals

## App Router

The **App Router** is Next.js’s route system based on directories and specially named files in the `app` directory.

Example:

```text
src/app/projects/page.tsx
```

creates:

```text
/projects
```

The App Router supports:

- File-based routing
- Layouts
- Loading interfaces
- Error boundaries
- Route Handlers
- Server Components
- Streaming
- Metadata
- Dynamic route segments

---

## Route

A **route** is an application destination identified by a URL.

Examples:

```text
/
 /about
 /projects
 /projects/10000000-0000-4000-8000-000000000001
```

A route may render a page, return JSON, redirect, or provide another HTTP response.

---

## Route Segment

A **route segment** is one part of a URL path.

For this URL:

```text
/projects/10000000-0000-4000-8000-000000000001
```

the segments are:

```text
projects
10000000-0000-4000-8000-000000000001
```

The matching source path is:

```text
src/app/(workspace)/projects/[projectId]/page.tsx
```

---

## Dynamic Route Segment

A **dynamic route segment** captures part of the URL.

Example directory:

```text
[projectId]
```

Example route:

```text
src/app/projects/[projectId]/page.tsx
```

Example URL:

```text
/projects/10000000-0000-4000-8000-000000000001
```

The dynamic value is available through `params`.

```tsx
type PageProps = {
  params: Promise<{
    projectId: string;
  }>;
};

export default async function ProjectPage({
  params,
}: PageProps) {
  const { projectId } = await params;

  return <p>{projectId}</p>;
}
```

---

## Search Parameters

**Search parameters**, sometimes called query parameters, appear after `?` in a URL.

Example:

```text
/projects?status=ACTIVE
```

In this URL:

```text
status
```

is the parameter name, and:

```text
ACTIVE
```

is its value.

Use search parameters for shareable view state such as:

- Filters
- Sorting
- Pagination
- Search terms
- Selected tabs representing navigation

LaunchPad uses:

```text
/projects?status=ACTIVE
```

for a project-status filter.

---

## Route Group

A **route group** is a directory wrapped in parentheses.

Example:

```text
(marketing)
```

or:

```text
(workspace)
```

Route groups organize application files and can apply layouts without changing the URL.

Example:

```text
src/app/(marketing)/about/page.tsx
```

still creates:

```text
/about
```

not:

```text
/marketing/about
```

---

## Root Layout

The **root layout** is the top-level layout in:

```text
src/app/layout.tsx
```

It must define:

```tsx
<html>
<body>
```

It commonly imports:

- Global styles
- Design tokens
- Accessibility styles
- Global providers
- Font variables

---

## Nested Layout

A **nested layout** wraps only routes beneath its directory.

Example:

```text
src/app/(workspace)/layout.tsx
```

wraps workspace routes such as:

```text
/dashboard
/projects
/projects/:projectId
```

LaunchPad’s workspace layout:

- Requires authentication
- Displays workspace navigation
- Displays account information
- Supplies a shared footer

---

## `page.tsx`

A `page.tsx` file makes a route publicly reachable.

Example:

```text
src/app/(marketing)/features/page.tsx
```

maps to:

```text
/features
```

---

## `layout.tsx`

A `layout.tsx` file supplies shared structure around child routes.

Example responsibilities:

- Navigation
- Sidebars
- Footers
- Providers
- Route-group protection
- Shared metadata

---

## `loading.tsx`

A `loading.tsx` file provides a route-level loading interface.

Example:

```text
src/app/(workspace)/projects/loading.tsx
```

It appears while the route segment is waiting on server work.

LaunchPad uses loading interfaces for:

- Dashboard metrics
- Project pages
- Streaming boundaries

---

## `error.tsx`

An `error.tsx` file creates an error boundary for a route segment.

It must be a Client Component because it receives a retry function.

Example:

```tsx
"use client";

export default function WorkspaceError({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <button
      type="button"
      onClick={() => {
        reset();
      }}
    >
      Try again
    </button>
  );
}
```

---

## `not-found.tsx`

A `not-found.tsx` file defines UI for missing resources.

It is shown when:

- A route does not exist
- A dynamic record does not exist
- A private record cannot be discovered by the current user

LaunchPad uses `notFound()` for missing or unauthorized project records.

---

## Route Handler

A **Route Handler** is a server-side HTTP endpoint implemented in `route.ts`.

Example:

```text
src/app/api/projects/route.ts
```

supports:

```text
GET /api/projects
POST /api/projects
```

Example:

```ts
export async function GET() {
  return Response.json({
    data: [],
  });
}
```

Route Handlers are useful for:

- JSON APIs
- Health checks
- Integrations
- Webhooks
- Mobile clients
- Automation scripts

---

## Server Action

A **Server Action** is a server-side function called from a Next.js form or client interaction.

It begins with:

```ts
"use server";
```

Example:

```ts
"use server";

export async function createProjectAction(
  formData: FormData,
) {
  // Validate, authorize, and mutate on the server.
}
```

LaunchPad uses Server Actions for:

- Registration
- Sign-in
- Sign-out
- Project creation
- Task creation
- Task status updates

---

# F.2 Server and Client Components

## Server Component

A **Server Component** renders in the server environment.

In the App Router, components are Server Components by default.

Server Components can:

- Query PostgreSQL
- Read private environment variables
- Authenticate users
- Authorize requests
- Render HTML
- Fetch server-only data
- Pass safe serializable values to Client Components

Example:

```tsx
export default async function ProjectsPage() {
  const user = await requireUser();
  const projects = await getProjects(user.id);

  return <ProjectList projects={projects} />;
}
```

---

## Client Component

A **Client Component** runs in the browser after hydration and can use browser-specific React features.

It begins with:

```tsx
"use client";
```

Client Components can use:

- `useState`
- `useEffect`
- `useActionState`
- Event handlers
- Browser APIs
- `window`
- `navigator`
- Clipboard APIs
- Client router hooks

Example:

```tsx
"use client";

import { useState } from "react";

export function Disclosure() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <button
      type="button"
      onClick={() => {
        setIsOpen((currentValue) => !currentValue);
      }}
    >
      {isOpen ? "Close" : "Open"}
    </button>
  );
}
```

---

## Client Boundary

A **Client Component boundary** begins where a file uses:

```tsx
"use client";
```

Its runtime imports become eligible for browser bundling.

This is why Client Components must not import:

```text
database query modules
server-only modules
password hashing
session utilities
private environment modules
```

Keep the boundary small.

Good:

```text
Server page
└── Client search component
```

Less desirable:

```text
Client page
└── Entire route, including static content and data composition
```

---

## Hydration

**Hydration** is the process in which React attaches browser-side behavior to server-rendered output.

Conceptually:

```text
Server renders initial interface
       ↓
Browser receives HTML
       ↓
Browser downloads Client Component JavaScript
       ↓
React attaches event handling
       ↓
Interactive controls work
```

Hydration mismatches can occur when server and browser output differ.

Avoid unstable render-time values such as:

```tsx
Math.random()
new Date().toISOString()
window.innerWidth
```

Use stable server data, `useId`, event handlers, or effects instead.

---

## Serializable Props

Values passed from Server Components to Client Components must be serializable.

Good examples:

```tsx
<ClientComponent
  name="Website redesign"
  taskCount={4}
  active={true}
  tags={["design", "performance"]}
/>
```

Unsafe examples:

```tsx
<ClientComponent database={database} />
<ClientComponent passwordHash={user.passwordHash} />
<ClientComponent sessionToken={sessionToken} />
```

A value being serializable does not mean it is safe to send to the browser.

---

## `server-only`

The `server-only` package marks a module as unsafe for browser imports.

Example:

```ts
import "server-only";

import { database } from "@/lib/database/client";
```

If a Client Component imports this module, Next.js reports an architecture error.

Use it for:

- Database access
- Private environment variables
- Session logic
- Password hashing
- Authorization functions
- Server-only integrations

---

# F.3 Rendering and Data Fetching

## Static Rendering

**Static rendering** prepares route output ahead of requests.

Good candidates:

- Marketing pages
- Documentation
- Shared public content

LaunchPad examples:

```text
/
/about
/features
```

Benefits:

- Fast delivery
- Reduced server work
- Easy CDN distribution

---

## Dynamic Rendering

**Dynamic rendering** generates output using request-time data.

Good candidates:

- Authenticated dashboards
- User-owned projects
- Session-dependent routes
- Frequently changing private records

LaunchPad examples:

```text
/dashboard
/projects
/projects/:projectId
```

These routes depend on:

```text
- cookies
- user identity
- owner-scoped database queries
```

---

## Streaming

**Streaming** sends completed interface sections while slower sections continue loading.

LaunchPad dashboard example:

```tsx
<Suspense fallback={<DashboardMetricsSkeleton />}>
  <DashboardMetrics />
</Suspense>

<Suspense fallback={<ActiveProjectsSkeleton />}>
  <DashboardActiveProjects />
</Suspense>
```

The metrics and active-project sections can appear independently.

---

## Suspense

**Suspense** defines a fallback while a child is waiting.

Example:

```tsx
import { Suspense } from "react";

<Suspense fallback={<p>Loading…</p>}>
  <SlowServerComponent />
</Suspense>
```

Suspense improves perceived performance. It does not make a slow database query itself faster.

---

## Request Memoization

**Request memoization** reuses identical work during one server rendering request.

LaunchPad uses React `cache`:

```ts
export const getProjectById = cache(
  async (
    userId: string,
    projectId: string,
  ) => {
    // Query the database.
  },
);
```

The cache key includes both:

```text
userId
projectId
```

The user ID is essential because authorization changes the result.

---

## Persistent Cache

A **persistent cache** can reuse values across multiple requests.

Private data requires careful cache design.

Questions to answer before caching private data:

- Does the cache key include user identity?
- May different users share this result?
- How is stale data invalidated?
- What happens after ownership changes?
- What happens after sign-out?
- Which mutation invalidates the entry?

LaunchPad avoids globally shared persistent caching for private project data.

---

## Revalidation

**Revalidation** marks rendered route data as stale after a mutation.

Example:

```ts
revalidatePath("/dashboard");
revalidatePath("/projects");
revalidatePath(`/projects/${projectId}`);
```

LaunchPad calls revalidation after project and task mutations.

---

# F.4 Authentication and Authorization

## Authentication

**Authentication** verifies identity.

LaunchPad authentication flow:

```text
Email and password
      ↓
bcrypt password verification
      ↓
Random session token
      ↓
HTTP-only cookie
      ↓
Database session lookup
      ↓
Authenticated user
```

---

## Authorization

**Authorization** verifies permission.

LaunchPad authorizes project access through:

```sql
WHERE project_id = $project_id
  AND owner_id = $user_id
```

A user can be authenticated but still not authorized to access another user’s project.

---

## Session

A **session** represents an authenticated browser relationship with the server.

LaunchPad sessions are stored in PostgreSQL:

```text
sessions
├── user_id
├── token_hash
└── expires_at
```

The browser stores only the raw random token in an HTTP-only cookie.

---

## HTTP-Only Cookie

An **HTTP-only cookie** cannot be accessed by ordinary browser JavaScript.

Example policy:

```ts
{
  httpOnly: true,
  secure: true,
  sameSite: "lax",
}
```

HTTP-only cookies reduce direct token theft through JavaScript but do not eliminate all XSS risk.

---

## bcrypt

**bcrypt** is a password-hashing algorithm designed to be slow and salted.

LaunchPad uses bcrypt for passwords because user-created passwords may have limited entropy.

Do not use SHA-256 alone for password storage.

---

## SHA-256 Token Hash

LaunchPad uses SHA-256 for random session-token lookup hashes.

Why this is different from password hashing:

```text
Passwords:
- Human-created
- Low or uncertain entropy
- Need slow hashing

Session tokens:
- Cryptographically random
- High entropy
- Need safe database lookup storage
```

---

## `401 Unauthorized`

In HTTP terminology, `401` means authentication is missing or invalid.

LaunchPad returns it for anonymous private API requests:

```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Authentication is required."
  }
}
```

---

## `403 Forbidden`

`403` means the caller is authenticated but not permitted.

LaunchPad defines the error code but typically returns `404` for unauthorized private project resources so it does not reveal their existence.

---

## `404 Not Found` for Private Resources

For a private project, `404` can mean:

```text
- The project does not exist.
- The project belongs to another user.
```

This prevents unauthorized callers from learning whether a private UUID is valid.

---

# F.5 Database Terms

## PostgreSQL

**PostgreSQL** is an open-source relational database.

LaunchPad uses it to store:

- Users
- Sessions
- Projects
- Tasks
- Migration history

---

## Relational Database

A **relational database** stores data in tables connected through relationships.

LaunchPad relationship:

```text
User
  └── owns Projects
        └── contain Tasks
```

---

## Primary Key

A **primary key** uniquely identifies each row.

Example:

```sql
id UUID PRIMARY KEY
```

LaunchPad uses UUID primary keys.

---

## Foreign Key

A **foreign key** connects one table to another.

Example:

```sql
FOREIGN KEY (owner_id)
REFERENCES users(id)
```

This ensures a project owner exists.

---

## `ON DELETE CASCADE`

`ON DELETE CASCADE` automatically deletes dependent records.

Examples:

```text
Delete user
  → delete projects
  → delete tasks

Delete project
  → delete tasks
```

---

## Index

An **index** improves lookup speed for selected query patterns.

Example:

```sql
CREATE INDEX projects_owner_status_index
  ON projects(owner_id, status);
```

This helps queries such as:

```sql
WHERE owner_id = $user_id
  AND status = 'ACTIVE'
```

Indexes improve reads but consume storage and add write overhead.

---

## Migration

A **migration** is a versioned database-schema change.

Example:

```text
001_create_projects_and_tasks.sql
002_add_users_sessions_and_ownership.sql
```

Migrations should be:

- Ordered
- Version controlled
- Reviewed
- Immutable after application
- Tested on a production-like database

---

## Migration Checksum

A **checksum** is a fingerprint of a migration file’s contents.

LaunchPad stores migration checksums in:

```text
schema_migrations
```

If a previously applied file changes, the migration runner fails.

---

## Advisory Lock

A PostgreSQL **advisory lock** is an application-controlled lock.

LaunchPad’s migration runner uses one so multiple deployment processes cannot apply migrations simultaneously.

---

# F.6 HTTP and API Terms

## HTTP Method

An **HTTP method** describes the kind of operation a request intends to perform.

| Method | Purpose |
|---|---|
| `GET` | Read data |
| `POST` | Create data or trigger non-idempotent work |
| `PATCH` | Partially update data |
| `PUT` | Replace a complete resource |
| `DELETE` | Remove data |

---

## JSON

**JSON**, or JavaScript Object Notation, is a text data format commonly used by APIs.

Example:

```json
{
  "name": "Website redesign",
  "status": "ACTIVE"
}
```

---

## API Envelope

An **API envelope** is a predictable wrapper around response data.

LaunchPad success:

```json
{
  "data": {
    "id": "..."
  }
}
```

LaunchPad error:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The project input is invalid."
  }
}
```

---

## Parameterized SQL

**Parameterized SQL** keeps SQL source separate from data values.

Safe:

```ts
database`
  SELECT *
  FROM projects
  WHERE id = ${projectId}
`;
```

Unsafe:

```ts
database.unsafe(
  `SELECT * FROM projects WHERE id = '${projectId}'`,
);
```

Parameterized SQL helps prevent SQL injection.

---

## `Cache-Control`

The `Cache-Control` header tells browsers and intermediary caches how to handle a response.

LaunchPad private API policy:

```http
Cache-Control: private, no-store
Vary: Cookie
```

LaunchPad health policy:

```http
Cache-Control: no-store
```

---

## `Vary: Cookie`

This response header tells caches that the response may vary based on the request cookie.

LaunchPad uses it for authenticated API responses:

```http
Vary: Cookie
```

Combined with `private, no-store`, it reinforces that private API data must not become shared cached content.

---

# F.7 Performance Terms

## Bundle

A **bundle** is a JavaScript file or group of files sent to the browser.

Large bundles can increase:

- Download time
- Parse time
- Execution time
- Hydration cost
- Input delay

---

## Code Splitting

**Code splitting** separates optional JavaScript into separate chunks.

LaunchPad example:

```tsx
const ProjectInsights = dynamic(
  () => import("@/components/project-insights"),
  {
    ssr: false,
  },
);
```

The insights code loads only after the user requests it.

---

## `next/image`

`next/image` is Next.js’s optimized image component.

It can provide:

- Responsive image candidates
- Layout stability through dimensions
- Lazy loading
- Format negotiation
- Image optimization endpoint integration

Example:

```tsx
<Image
  src="/launchpad-dashboard.png"
  alt="LaunchPad dashboard illustration"
  width={1600}
  height={900}
  sizes="(max-width: 56rem) calc(100vw - 2rem), 50vw"
  priority
/>
```

---

## `next/font`

`next/font` integrates optimized font loading into Next.js builds.

LaunchPad uses:

```tsx
import {
  Geist,
  Geist_Mono,
} from "next/font/google";
```

It provides self-hosted font assets and generated CSS variables.

---

## LCP

**Largest Contentful Paint**, or LCP, measures when the largest important visible element finishes rendering.

Common LCP contributors:

- Hero images
- Main headings
- Large content blocks

---

## CLS

**Cumulative Layout Shift**, or CLS, measures unexpected layout movement.

Using explicit image dimensions helps reduce CLS:

```tsx
width={1600}
height={900}
```

---

## INP

**Interaction to Next Paint**, or INP, measures how quickly an interface responds after user interaction.

Large client bundles and long JavaScript tasks can worsen INP.

---

# F.8 Production and Operations Terms

## Environment Variable

An **environment variable** supplies configuration outside source code.

LaunchPad examples:

```text
APP_URL
DATABASE_URL
DATABASE_SSL
LOG_LEVEL
APP_VERSION
```

Private values should not use:

```text
NEXT_PUBLIC_
```

because that prefix can expose values to browser code.

---

## Secret Store

A **secret store** is a managed location for sensitive configuration.

Examples:

- Hosting-platform environment variables
- Cloud secret managers
- CI secret storage
- Managed deployment secrets

Secrets do not belong in Git.

---

## Liveness Check

A **liveness check** answers:

> Is the application process alive?

LaunchPad endpoint:

```text
GET /api/live
```

It should not require PostgreSQL.

---

## Readiness Check

A **readiness check** answers:

> Can the application currently serve dependency-backed traffic?

LaunchPad endpoint:

```text
GET /api/health
```

It checks PostgreSQL availability.

---

## Structured Logging

**Structured logging** writes machine-readable event records, often JSON.

Example:

```json
{
  "timestamp": "2026-07-26T12:00:00.000Z",
  "level": "error",
  "event": "readiness_check_failed",
  "version": "abc123"
}
```

Structured logs are easier to search, filter, aggregate, and alert on.

---

## Request ID

A **request ID** is a unique identifier associated with one HTTP request.

It helps connect:

```text
Browser report
      ↓
Response header
      ↓
Application log
      ↓
Monitoring event
```

LaunchPad returns:

```http
X-Request-Id: ...
```

from health-related endpoints.

---

## Smoke Test

A **smoke test** checks critical behavior after a deployment.

LaunchPad smoke tests verify:

- Public routes
- Liveness
- Readiness
- Anonymous private API rejection
- Protected-page redirect behavior
- Private API cache policy

Run:

```bash
npm run smoke
```

---

## Continuous Integration

**Continuous Integration**, or CI, automatically validates source changes.

LaunchPad CI performs:

```text
npm ci
→ migrations
→ migration idempotency
→ type-check
→ lint
→ production build
→ start application
→ smoke tests
```

---

## Immutable Artifact

An **immutable artifact** is a build output that is created once and promoted without being changed.

Examples:

- A container image tagged by commit SHA
- A deployment artifact generated by CI
- A platform build tied to a Git commit

This reduces “works on one server but not another” problems.

---

## RPO

**Recovery Point Objective**, or RPO, defines acceptable data loss.

Example:

```text
RPO: 15 minutes
```

This means losing more than 15 minutes of data is unacceptable.

---

## RTO

**Recovery Time Objective**, or RTO, defines acceptable restoration time.

Example:

```text
RTO: 2 hours
```

This means the service should recover within two hours after a serious outage.

---

# F.9 Useful File-Conventions Table

| File name | Purpose |
|---|---|
| `page.tsx` | Route UI |
| `layout.tsx` | Shared persistent route UI |
| `loading.tsx` | Route-segment loading interface |
| `error.tsx` | Route-segment error boundary |
| `not-found.tsx` | Missing-resource UI |
| `route.ts` | HTTP Route Handler |
| `actions.ts` | Server Actions by project convention |
| `globals.css` | Global application styles |
| `*.module.css` | Locally scoped component styles |
| `next.config.ts` | Next.js configuration |
| `.env.example` | Safe environment-variable documentation |
| `.env.local` | Local private configuration |
| `compose.yaml` | Local Docker services |
| `Dockerfile` | Production container build |
| `scripts/migrate.mjs` | Migration runner |
| `scripts/smoke-test.mjs` | Deployment smoke tests |

---

# F.10 Core Rules to Remember

1. **Server Components are the default.**
2. **Client Components are for browser behavior, not general page rendering.**
3. **Every value from a request is untrusted.**
4. **Authentication identifies the user.**
5. **Authorization verifies what the user may do.**
6. **Owner checks belong in SQL.**
7. **Database credentials remain server-only.**
8. **Private API responses must not become shared cache entries.**
9. **Migrations are historical records; do not edit applied files.**
10. **Production readiness includes monitoring, backups, CI, and rollback—not only deployment.**
