# Appendix J: File-by-File Project Reference

This appendix explains the purpose of the most important files in the completed LaunchPad project.

Use it when you need to answer:

- Which file owns this behavior?
- Where should I add a new route?
- Where are database queries located?
- Where is authentication handled?
- Which files are safe to import into Client Components?
- Which files should remain server-only?

---

# J.1 Top-Level Project Structure

```text
launchpad/
├── .github/
├── database/
├── docs/
├── public/
├── scripts/
├── src/
├── .dockerignore
├── .env.example
├── .env.local
├── compose.yaml
├── Dockerfile
├── eslint.config.mjs
├── next.config.ts
├── package.json
└── tsconfig.json
```

| Path | Responsibility |
|---|---|
| `.github/` | Continuous integration workflow configuration |
| `database/` | SQL migrations and local development seed data |
| `docs/` | Operations documentation and deployment checklists |
| `public/` | Static public assets |
| `scripts/` | Automation for migrations, smoke tests, measurements, and asset generation |
| `src/` | Next.js application source |
| `.env.example` | Safe documentation for required environment variables |
| `.env.local` | Local private configuration; never commit it |
| `compose.yaml` | Local PostgreSQL Docker service |
| `Dockerfile` | Multi-stage production container build |
| `next.config.ts` | Next.js output, image, bundle-analysis, and security-header configuration |
| `package.json` | Dependencies and project scripts |
| `tsconfig.json` | TypeScript configuration and import aliases |

---

# J.2 `src/app`: Routes and Framework Conventions

```text
src/app/
├── (auth)/
├── (marketing)/
├── (workspace)/
├── api/
├── globals.css
├── layout.tsx
└── not-found.tsx
```

The `app` directory owns route behavior.

Do not place general database utilities, validation schemas, or reusable non-route-specific logic directly in `src/app`.

---

## Root Layout

### `src/app/layout.tsx`

This file owns application-wide document structure.

Responsibilities include:

```text
- <html lang="en">
- <body>
- Global CSS imports
- Design token imports
- Accessibility utility imports
- Font configuration
- Skip link
- Web Vitals reporter
- Default metadata
```

It should not own:

```text
- Workspace-only navigation
- Authentication logic for only one route group
- Database queries
- Project-specific UI
```

---

## Global Not-Found Interface

### `src/app/not-found.tsx`

This file renders when:

```text
- A route does not exist
- A dynamic page calls notFound()
- A private project cannot be discovered by the current user
```

It includes its own:

```text
id="main-content"
```

because it lives outside the normal marketing and workspace layout targets.

---

## Global Stylesheet

### `src/app/globals.css`

This file owns global application styles and broad layout patterns.

Responsibilities include:

```text
- Application shell
- Site header
- Workspace layout
- Shared page layouts
- Forms
- Dashboard layout
- Task-management styles
- Loading skeletons
- Responsive layout rules
```

Reusable component-specific styling should prefer CSS Modules.

Examples:

```text
src/components/project-card.module.css
src/components/status-badge.module.css
```

---

# J.3 Marketing Route Group

```text
src/app/(marketing)/
├── about/
├── features/
├── layout.tsx
└── page.tsx
```

The `(marketing)` directory does not appear in the browser URL.

---

## Marketing Layout

### `src/app/(marketing)/layout.tsx`

This layout owns public-page chrome:

```text
- Site header
- Shared content wrapper
- Main-content skip-link target
- Footer
```

It wraps:

```text
/
/about
/features
```

---

## Marketing Home

### `src/app/(marketing)/page.tsx`

Route:

```text
/
```

Responsibilities:

```text
- Hero content
- Optimized dashboard illustration
- Public calls to action
- Feature preview
```

It uses:

```tsx
import Image from "next/image";
```

for the responsive hero illustration.

---

## About Page

### `src/app/(marketing)/about/page.tsx`

Route:

```text
/about
```

Responsibilities:

```text
- Explain LaunchPad architecture
- Explain engineering principles
- Provide public product context
```

---

## Features Page

### `src/app/(marketing)/features/page.tsx`

Route:

```text
/features
```

Responsibilities:

```text
- Describe LaunchPad capabilities
- Explain product and production foundations
```

---

# J.4 Authentication Route Group

```text
src/app/(auth)/
├── actions.ts
├── layout.tsx
├── sign-in/
│   └── page.tsx
└── sign-up/
    └── page.tsx
```

The `(auth)` directory does not appear in the browser URL.

---

## Authentication Actions

### `src/app/(auth)/actions.ts`

This file contains Server Actions for:

```text
- Sign in
- Sign up
- Sign out
```

It should:

```text
- Validate form fields
- Verify or create accounts
- Create or destroy sessions
- Return safe errors
- Redirect after successful authentication changes
```

It should not:

```text
- Return password hashes
- Return session tokens
- Trust client-provided user IDs
- Expose raw database exceptions
```

---

## Authentication Layout

### `src/app/(auth)/layout.tsx`

This layout owns the simplified authentication shell.

Responsibilities:

```text
- LaunchPad brand link
- Main-content skip-link target
- Minimal page structure
```

It intentionally does not render workspace navigation.

---

## Sign-In Page

### `src/app/(auth)/sign-in/page.tsx`

Route:

```text
/sign-in
```

Responsibilities:

```text
- Redirect already authenticated users to /dashboard
- Render SignInForm
- Present the local development account details
```

The demo credentials must never be presented in a real public production environment.

---

## Sign-Up Page

### `src/app/(auth)/sign-up/page.tsx`

Route:

```text
/sign-up
```

Responsibilities:

```text
- Redirect already authenticated users to /dashboard
- Render SignUpForm
- Explain account and ownership behavior
```

---

# J.5 Workspace Route Group

```text
src/app/(workspace)/
├── dashboard/
├── projects/
├── error.tsx
└── layout.tsx
```

The workspace route group contains private, authenticated pages.

---

## Workspace Layout

### `src/app/(workspace)/layout.tsx`

This is one of the most important security-adjacent files.

It calls:

```ts
const user = await requireUser();
```

Responsibilities:

```text
- Require a valid authenticated user
- Render shared site header
- Render account bar
- Render workspace navigation
- Render main-content skip-link target
- Render workspace footer
- Apply noindex metadata
```

Important limitation:

```text
This protects normal page navigation, but APIs, Server Actions,
queries, and mutations still require their own authentication and
authorization checks.
```

---

## Workspace Error Boundary

### `src/app/(workspace)/error.tsx`

This Client Component handles unexpected workspace failures.

Responsibilities:

```text
- Display safe user-facing failure UI
- Offer retry behavior through reset()
- Log errors for development diagnostics
```

It should not display raw database or stack-trace information to users.

---

## Dashboard

```text
src/app/(workspace)/dashboard/
├── loading.tsx
└── page.tsx
```

### `page.tsx`

Route:

```text
/dashboard
```

Responsibilities:

```text
- Render dashboard shell
- Stream dashboard metrics
- Stream active project cards
```

### `loading.tsx`

Provides a route-level dashboard loading interface.

---

# J.6 Project Routes

```text
src/app/(workspace)/projects/
├── [projectId]/
├── new/
├── actions.ts
├── loading.tsx
└── page.tsx
```

---

## Project Collection Page

### `src/app/(workspace)/projects/page.tsx`

Route:

```text
/projects
```

Responsibilities:

```text
- Require authenticated user
- Validate URL status filter
- Query only current user's projects
- Render server-side status form
- Pass authorized project data to ProjectList
```

The Client Component receives only projects already filtered by the server.

---

## Project Creation Action

### `src/app/(workspace)/projects/actions.ts`

This Server Action creates new projects.

Responsibilities:

```text
- Require authenticated user
- Validate FormData
- Create project with authenticated user as owner
- Revalidate dashboard and project list
- Redirect to created project
```

Ownership is derived from:

```ts
user.id
```

not from form input.

---

## Project Creation Page

### `src/app/(workspace)/projects/new/page.tsx`

Route:

```text
/projects/new
```

Responsibilities:

```text
- Render the project-creation page
- Render CreateProjectForm
- Provide route-specific metadata
```

---

## Dynamic Project Page

```text
src/app/(workspace)/projects/[projectId]/
├── actions.ts
└── page.tsx
```

### `page.tsx`

Route:

```text
/projects/:projectId
```

Responsibilities:

```text
- Validate project UUID
- Require authenticated user
- Fetch owned project
- Fetch owned project tasks
- Return not-found behavior for missing or unauthorized records
- Render project details
- Render task list
- Render task-creation form
- Render optional client-loaded insights
```

### `actions.ts`

Contains task-related Server Actions:

```text
- Create task
- Update task status
```

Each action:

```text
- Requires the user
- Validates project ID and task ID
- Validates form values
- Calls owner-scoped mutation functions
- Revalidates affected routes
```

---

# J.7 API Routes

```text
src/app/api/
├── health/
│   └── route.ts
├── live/
│   └── route.ts
└── projects/
    ├── [projectId]/
    │   └── route.ts
    └── route.ts
```

---

## Liveness Endpoint

### `src/app/api/live/route.ts`

Route:

```text
GET /api/live
```

Responsibilities:

```text
- Confirm application process can answer requests
- Return current timestamp and release version
- Avoid PostgreSQL dependency
- Use no-store caching
- Return request ID header
```

---

## Readiness Endpoint

### `src/app/api/health/route.ts`

Route:

```text
GET /api/health
```

Responsibilities:

```text
- Check PostgreSQL reachability
- Return 200 when ready
- Return 503 when database is unavailable
- Emit structured errors when dependency checks fail
- Use no-store caching
```

---

## Project Collection API

### `src/app/api/projects/route.ts`

Routes:

```text
GET /api/projects
POST /api/projects
```

Responsibilities:

```text
- Require API user session
- Validate optional status filter
- Return only the caller's projects
- Create projects owned by the caller
- Use private no-store cache headers
```

---

## Individual Project API

### `src/app/api/projects/[projectId]/route.ts`

Routes:

```text
GET    /api/projects/:projectId
PATCH  /api/projects/:projectId
DELETE /api/projects/:projectId
```

Responsibilities:

```text
- Require API user session
- Validate project UUID
- Query and mutate only owned project records
- Return 404 for missing or undiscoverable private records
- Use private no-store headers
```

---

# J.8 Reusable Components

```text
src/components/
├── account-menu.tsx
├── copy-project-link.tsx
├── create-project-form.tsx
├── create-task-form.tsx
├── dashboard-active-projects.tsx
├── dashboard-metrics.tsx
├── dashboard-skeletons.tsx
├── interactive-disclosure.tsx
├── project-card.tsx
├── project-insights-loader.tsx
├── project-insights.tsx
├── project-list.tsx
├── sign-in-form.tsx
├── sign-up-form.tsx
├── site-footer.tsx
├── site-header.tsx
├── status-badge.tsx
├── task-list.tsx
├── web-vitals-reporter.tsx
└── workspace-navigation.tsx
```

---

## Server-Compatible Components

These components do not need browser hooks or browser APIs.

Examples:

```text
account-menu.tsx
dashboard-active-projects.tsx
dashboard-metrics.tsx
dashboard-skeletons.tsx
project-card.tsx
site-footer.tsx
site-header.tsx
status-badge.tsx
task-list.tsx
```

They may be rendered by Server Components.

Some may be included below a Client Component boundary, but they must not import server-only infrastructure if that is possible.

---

## Client Components

These files contain:

```tsx
"use client";
```

Examples:

```text
copy-project-link.tsx
create-project-form.tsx
create-task-form.tsx
interactive-disclosure.tsx
project-insights-loader.tsx
project-insights.tsx
project-list.tsx
sign-in-form.tsx
sign-up-form.tsx
web-vitals-reporter.tsx
workspace-navigation.tsx
```

Their client-side reasons include:

| Component | Browser capability |
|---|---|
| `copy-project-link.tsx` | Clipboard API |
| `create-project-form.tsx` | `useActionState` |
| `create-task-form.tsx` | `useActionState`, form reset |
| `interactive-disclosure.tsx` | Local open/closed state |
| `project-insights-loader.tsx` | Dynamic-module visibility state |
| `project-insights.tsx` | Optional browser-loaded feature |
| `project-list.tsx` | Immediate text search |
| `sign-in-form.tsx` | Pending and error state |
| `sign-up-form.tsx` | Pending and error state |
| `web-vitals-reporter.tsx` | Browser Web Vitals hook |
| `workspace-navigation.tsx` | Current pathname hook |

Client Components must not import:

```text
src/lib/database/*
src/lib/auth/session.ts
src/lib/environment.ts
src/lib/logger.ts
```

---

# J.9 `src/lib`: Application and Server Logic

```text
src/lib/
├── auth/
├── database/
├── action-state.ts
├── api-response.ts
├── auth-inputs.ts
├── auth-types.ts
├── environment.ts
├── logger.ts
├── project-inputs.ts
├── project-types.ts
└── task-types.ts
```

---

## Environment Module

### `src/lib/environment.ts`

Responsibilities:

```text
- Validate required environment variables
- Require HTTPS APP_URL in production
- Parse DATABASE_SSL
- Parse LOG_LEVEL
- Expose immutable server configuration
```

Must remain server-only.

---

## Logger

### `src/lib/logger.ts`

Responsibilities:

```text
- Emit structured JSON logs
- Apply log-level filtering
- Create request IDs
- Redact sensitive context values
- Safely serialize errors
```

Must remain server-only.

---

## API Response Utilities

### `src/lib/api-response.ts`

Responsibilities:

```text
- Consistent JSON success envelope
- Consistent JSON error envelope
- Validation-error details
- JSON request-body parsing
- Private and public cache-control headers
```

This module is safe for Route Handlers. It should not contain database credentials or session secrets.

---

## Form Action State

### `src/lib/action-state.ts`

Responsibilities:

```text
- Form action status values
- Field error map types
- Zod issue transformation into field errors
```

This module is environment-neutral and can be imported by Client Components.

---

## Project Input Schemas

### `src/lib/project-inputs.ts`

Responsibilities:

```text
- Create project validation
- Update project validation
- Create task validation
- Update task status validation
```

This module is environment-neutral.

It validates input structure but does not authenticate or authorize callers.

---

## Project Types

### `src/lib/project-types.ts`

Responsibilities:

```text
- Project status values
- Project summary type
- Status labels
- Project-progress calculation
```

This module is safe for server and client use because it contains only types and pure functions.

---

## Task Types

### `src/lib/task-types.ts`

Responsibilities:

```text
- Task status values
- Task priority values
- Task type
- Human-readable labels
```

This module is safe for server and client use.

---

# J.10 Authentication Modules

```text
src/lib/auth/
├── accounts.ts
├── session-store.ts
└── session.ts
```

---

## Account Module

### `src/lib/auth/accounts.ts`

Responsibilities:

```text
- Look up account by normalized email
- Compare password against bcrypt hash
- Create account with bcrypt password hash
- Return safe public user data
```

Must remain server-only.

---

## Session Store

### `src/lib/auth/session-store.ts`

Responsibilities:

```text
- Insert database session
- Find active session user by token hash
- Delete one session
- Delete expired sessions
```

Must remain server-only.

---

## Session Utility

### `src/lib/auth/session.ts`

Responsibilities:

```text
- Generate cryptographically random session tokens
- SHA-256 hash tokens
- Write secure HTTP-only cookies
- Read current user from cookie and database
- Require authenticated user for pages/actions
- Require API user for Route Handlers
- Destroy session on sign-out
```

Must remain server-only.

---

# J.11 Database Modules

```text
src/lib/database/
├── client.ts
├── health.ts
├── project-mutations.ts
├── project-queries.ts
└── schemas.ts
```

---

## Database Client

### `src/lib/database/client.ts`

Responsibilities:

```text
- Create PostgreSQL client
- Configure connection pool
- Configure TLS behavior
- Reuse client during local development
- Support graceful shutdown
```

Must remain server-only.

---

## Health Query

### `src/lib/database/health.ts`

Responsibilities:

```text
- Execute minimal SELECT 1 query
- Support readiness endpoint
```

Must remain server-only.

---

## Project Queries

### `src/lib/database/project-queries.ts`

Responsibilities:

```text
- List owned projects
- Read owned project by ID
- Calculate owned dashboard metrics
- Load owned active projects
- Load tasks through owned project
```

Every private function requires:

```text
userId
```

Must remain server-only.

---

## Project Mutations

### `src/lib/database/project-mutations.ts`

Responsibilities:

```text
- Create project with owner ID
- Update owned project
- Delete owned project
- Create task in owned project
- Update task in owned project
```

Every mutation requires:

```text
userId
```

Must remain server-only.

---

## Database Result Schemas

### `src/lib/database/schemas.ts`

Responsibilities:

```text
- Validate project query results
- Validate task query results
- Validate dashboard metric results
```

This protects the application from unexpected database-shape assumptions.

---

# J.12 Styling Files

```text
src/
├── app/
│   └── globals.css
├── components/
│   ├── project-card.module.css
│   └── status-badge.module.css
└── styles/
    ├── accessibility.css
    └── design-tokens.css
```

| File | Styling responsibility |
|---|---|
| `globals.css` | Shared layout, page, form, task, and responsive styles |
| `design-tokens.css` | Colors, typography, spacing, shadows, radii, motion |
| `accessibility.css` | Focus, skip link, reduced motion, print behavior |
| `project-card.module.css` | Locally scoped project-card styles |
| `status-badge.module.css` | Locally scoped status-badge variants |

---

# J.13 Operations Files

## Docker Compose

### `compose.yaml`

Responsibilities:

```text
- Run local PostgreSQL
- Persist local database volume
- Provide local credentials
- Expose port 5432
- Perform PostgreSQL health checks
```

This file is for local development.

It is not the production deployment architecture.

---

## Dockerfile

### `Dockerfile`

Responsibilities:

```text
- Install exact npm dependencies
- Build Next.js standalone output
- Create minimal runtime image
- Run application as non-root user
- Expose port 3000
- Define liveness health check
```

---

## Migration Runner

### `scripts/migrate.mjs`

Responsibilities:

```text
- Find migration SQL files
- Calculate SHA-256 checksums
- Create schema_migrations table
- Acquire advisory lock
- Verify historical migration checksums
- Apply pending migrations transactionally
- Record applied migration data
```

---

## Smoke Test

### `scripts/smoke-test.mjs`

Responsibilities:

```text
- Verify public routes
- Verify liveness
- Verify readiness
- Verify anonymous private API rejection
- Verify private API cache headers
- Verify protected page redirect
```

---

## CI Workflow

### `.github/workflows/ci.yml`

Responsibilities:

```text
- Install exact dependencies
- Start PostgreSQL service
- Apply migrations
- Verify migration idempotency
- Type-check source
- Lint source
- Build production output
- Start production application
- Run smoke tests
```

---

# J.14 File Placement Rules

Use these rules when adding new code.

| Requirement | Recommended location |
|---|---|
| New page route | `src/app/.../page.tsx` |
| New JSON endpoint | `src/app/api/.../route.ts` |
| New Server Action | Nearby `actions.ts` |
| New reusable UI | `src/components/` |
| New client interaction | Client Component in `src/components/` |
| New pure utility or type | `src/lib/` |
| New input validation schema | `src/lib/*-inputs.ts` |
| New database read/write | `src/lib/database/` |
| New auth capability | `src/lib/auth/` |
| New migration | `database/migrations/` |
| New development-only sample data | `database/seeds/` |
| New operational automation | `scripts/` |
| New runbook or checklist | `docs/` |
| New component-local styles | Adjacent `*.module.css` file |
| New global token | `src/styles/design-tokens.css` |

---

# J.15 Final File-Safety Rules

Before importing a module, ask:

```text
Does this code access:
- PostgreSQL?
- Private environment variables?
- Password hashes?
- Session tokens?
- Cookie storage?
- Node.js crypto?
```

If yes:

```text
It belongs in a server-only module.
```

Before creating a Client Component, ask:

```text
Does it need:
- useState?
- useEffect?
- useActionState?
- Browser APIs?
- Event handlers?
- usePathname?
```

If no:

```text
Keep it server-compatible.
```

Before adding a query, ask:

```text
Does the record belong to a user?
```

If yes:

```text
Require userId and include owner authorization in SQL.
```
