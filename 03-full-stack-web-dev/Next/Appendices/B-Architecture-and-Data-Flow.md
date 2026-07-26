# Appendix B: LaunchPad Architecture and Data-Flow Reference

This appendix provides a compact but complete map of how LaunchPad’s layers work together.

Use it when you need to answer questions such as:

- Where should this code live?
- Can this component access the database?
- Should this state live in the URL or `useState`?
- Where is authorization enforced?
- How does a browser request become a database query?
- Which layer should handle an error?

---

## B.1 The High-Level Architecture

```text
┌───────────────────────────────────────────────────────────┐
│                         Browser                           │
│                                                           │
│  Public pages                                              │
│  Auth forms                                                │
│  Interactive Client Components                             │
│  HTTP-only session cookie                                  │
└─────────────────────────────┬─────────────────────────────┘
                              │ HTTPS
                              ▼
┌───────────────────────────────────────────────────────────┐
│                       Next.js 16 App                      │
│                                                           │
│  App Router                                                │
│  ├── Marketing routes                                      │
│  ├── Authentication routes                                 │
│  ├── Protected workspace routes                            │
│  └── API Route Handlers                                    │
│                                                           │
│  Server Layer                                              │
│  ├── Server Components                                     │
│  ├── Server Actions                                        │
│  ├── Session validation                                    │
│  ├── Input validation                                      │
│  ├── Authorization                                         │
│  └── Structured logging                                    │
└─────────────────────────────┬─────────────────────────────┘
                              │ Parameterized SQL
                              ▼
┌───────────────────────────────────────────────────────────┐
│                       PostgreSQL                           │
│                                                           │
│  users                                                     │
│  sessions                                                  │
│  projects                                                  │
│  tasks                                                     │
│  schema_migrations                                         │
└───────────────────────────────────────────────────────────┘
```

---

## B.2 Request Flows

### Public marketing page

Example route:

```text
/
```

```text
Browser requests /
       ↓
Next.js matches the marketing route
       ↓
Server Component renders static content
       ↓
Next.js sends HTML and required assets
       ↓
Browser displays page
```

This route can be statically optimized because it does not depend on an authenticated user or private database data.

---

### Protected workspace page

Example route:

```text
/projects
```

```text
Browser requests /projects
       ↓
Workspace layout runs requireUser()
       ↓
Server reads HTTP-only session cookie
       ↓
Server hashes session token
       ↓
PostgreSQL finds active session and user
       ↓
Server Component validates URL filter
       ↓
Owner-scoped query loads only the user's projects
       ↓
Next.js renders the page
       ↓
Browser receives authorized project data
```

The browser never receives:

```text
- database credentials
- raw session-token hashes
- other users' project records
- password hashes
```

---

### Project creation form

```text
Browser submits form
       ↓
CreateProjectForm sends FormData
       ↓
createProjectAction Server Action runs
       ↓
requireUser() identifies caller
       ↓
Zod validates project fields
       ↓
createProject(user.id, input)
       ↓
PostgreSQL inserts project with owner_id = authenticated user
       ↓
Affected paths are revalidated
       ↓
Next.js redirects to the new project page
```

---

### Authenticated project API request

Example request:

```text
GET /api/projects
```

```text
HTTP request includes session cookie
       ↓
Route Handler calls requireApiUser()
       ↓
Session cookie is validated
       ↓
getProjects(user.id)
       ↓
SQL includes owner_id = user.id
       ↓
Route Handler returns JSON
       ↓
Response includes:
Cache-Control: private, no-store
Vary: Cookie
```

---

### Task status update

```text
Browser submits task status form
       ↓
updateTaskStatusAction runs on server
       ↓
requireUser() identifies caller
       ↓
Project ID, task ID, and status are validated
       ↓
Owner-scoped UPDATE runs
       ↓
SQL verifies:
task ID
project ID
project owner ID
       ↓
Affected pages are revalidated
       ↓
Updated task state renders
```

---

## B.3 Route Map

| URL | Route responsibility | Access |
|---|---|---|
| `/` | Marketing home page | Public |
| `/about` | Architecture explanation | Public |
| `/features` | Product and engineering features | Public |
| `/sign-in` | Authentication form | Public; redirects signed-in users |
| `/sign-up` | Registration form | Public; redirects signed-in users |
| `/dashboard` | Private user dashboard | Authenticated |
| `/projects` | Private project list | Authenticated |
| `/projects/new` | New-project form | Authenticated |
| `/projects/:projectId` | Private project detail and tasks | Authenticated owner |
| `/api/live` | Process liveness | Public |
| `/api/health` | Database-aware readiness | Public |
| `/api/projects` | Project collection API | Authenticated |
| `/api/projects/:projectId` | Individual project API | Authenticated owner |

---

## B.4 Server Components Versus Client Components

### Server Components

Server Components are the default in the App Router.

Use them for:

- Database reads
- Authentication checks
- Authorization checks
- Metadata
- Static content
- Server-side rendering
- Rendering initial page content

Examples:

```text
src/app/(workspace)/projects/page.tsx
src/app/(workspace)/dashboard/page.tsx
src/components/dashboard-metrics.tsx
src/components/task-list.tsx
```

A Server Component can import:

```text
database query modules
server-only modules
environment configuration
authentication helpers
```

---

### Client Components

A Client Component begins with:

```tsx
"use client";
```

Use it only when browser-specific behavior is needed.

Examples:

```text
src/components/project-list.tsx
src/components/create-project-form.tsx
src/components/sign-in-form.tsx
src/components/copy-project-link.tsx
src/components/workspace-navigation.tsx
```

Client Component capabilities include:

- `useState`
- `useEffect`
- `useActionState`
- Event handlers
- Clipboard APIs
- Browser router hooks
- Local interaction state

Client Components must not import:

```text
database clients
server-only modules
environment configuration
password hashing code
session-storage modules
```

---

## B.5 Data Ownership Map

| Data or state | Authoritative owner | Example |
|---|---|---|
| User account | PostgreSQL | `users` table |
| Session validity | PostgreSQL | `sessions` table |
| Project ownership | PostgreSQL | `projects.owner_id` |
| Task status | PostgreSQL | `tasks.status` |
| Current authenticated identity | Server session lookup | `getCurrentUser()` |
| Project status filter | URL | `?status=ACTIVE` |
| Project text search | Local Client Component state | `useState("")` |
| Disclosure open state | Local Client Component state | `useState(false)` |
| Form pending state | React action state | `useActionState(...)` |
| Copy-link feedback | Local Client Component state | `"idle" | "success" | "error"` |

A useful rule is:

> Keep state with the closest trustworthy owner that needs to preserve it.

---

## B.6 Database Relationship Diagram

```text
users
├── id
├── name
├── email
├── password_hash
├── created_at
└── updated_at
    │
    ├─────────────── owns ───────────────┐
    │                                    │
    ▼                                    ▼
sessions                             projects
├── id                               ├── id
├── user_id                          ├── owner_id
├── token_hash                       ├── name
├── expires_at                       ├── description
└── created_at                       ├── status
                                     ├── created_at
                                     └── updated_at
                                          │
                                          │ has many
                                          ▼
                                       tasks
                                       ├── id
                                       ├── project_id
                                       ├── title
                                       ├── description
                                       ├── status
                                       ├── priority
                                       ├── due_date
                                       ├── created_at
                                       └── updated_at
```

Key foreign-key behavior:

```text
Delete user
  → delete sessions
  → delete owned projects
  → delete project tasks

Delete project
  → delete related tasks
```

---

## B.7 Security Boundaries

### Boundary 1: Browser to server

The browser is untrusted.

Validate:

- Form input
- JSON bodies
- URL parameters
- Query strings
- Cookie values
- Request headers

Never trust a hidden button, disabled control, or client-side conditional rendering as a security control.

---

### Boundary 2: Server Action or Route Handler

Every mutation entry point must:

1. Authenticate the caller.
2. Validate submitted data.
3. Validate resource identifiers.
4. Authorize the requested operation.
5. Call owner-scoped database mutations.
6. Return or render safe feedback.

---

### Boundary 3: Database query

Owner checks belong in SQL.

Correct pattern:

```sql
SELECT
  id,
  name,
  description
FROM projects
WHERE id = $project_id
  AND owner_id = $user_id;
```

Incorrect pattern:

```sql
SELECT *
FROM projects
WHERE id = $project_id;
```

followed by an optional client-side ownership check.

The database query must avoid retrieving unauthorized records in the first place.

---

### Boundary 4: Logs and observability

Logs are also a data boundary.

Never include:

```text
password
passwordHash
token
tokenHash
cookie
authorization
DATABASE_URL
```

LaunchPad’s logger redacts fields with sensitive names before writing structured records.

---

## B.8 Module Placement Guide

### Put code in `src/app`

Use `src/app` for routing and framework route conventions:

```text
page.tsx
layout.tsx
loading.tsx
error.tsx
not-found.tsx
route.ts
actions.ts
```

---

### Put code in `src/components`

Use `src/components` for reusable interface units:

```text
ProjectCard
StatusBadge
TaskList
CreateProjectForm
SignInForm
WorkspaceNavigation
```

A component may be server-compatible or client-side depending on its requirements.

---

### Put code in `src/lib`

Use `src/lib` for non-visual application capabilities:

```text
authentication
database clients
database queries
database mutations
validation schemas
environment validation
logging
shared type definitions
API response helpers
```

Server-only modules should begin with:

```ts
import "server-only";
```

---

### Put code in `database`

Use `database` for persistent schema and local-development data:

```text
database/migrations/
database/seeds/
```

Migration files are historical records. Never modify one after it has been applied in a shared environment.

---

### Put code in `scripts`

Use `scripts` for developer and operations automation:

```text
migrate.mjs
smoke-test.mjs
measure-routes.sh
generate-launchpad-image.py
```

---

## B.9 Error-Handling Matrix

| Situation | Correct response |
|---|---|
| Invalid status query parameter | Normal validation message |
| Invalid form input | Field-level form errors |
| Missing public route | `not-found.tsx` |
| Missing owned project | Not-found interface |
| Other user’s private project | Not-found interface |
| Unauthenticated page request | Redirect to `/sign-in` |
| Unauthenticated private API request | `401 UNAUTHORIZED` JSON |
| Database unavailable | Workspace error boundary or `503` readiness |
| Database row violates expected schema | Error boundary and diagnostic log |
| Failed project creation | Safe form error message |
| Health check database failure | `503` and structured error log |

---

## B.10 Cache and Rendering Policy

| Resource | Rendering/cache approach | Reason |
|---|---|---|
| Marketing home | Static where possible | Shared public content |
| About and features | Static where possible | Shared public content |
| Sign-in/sign-up | Request-aware | Redirect signed-in users |
| Dashboard | Dynamic | Depends on session and private data |
| Projects | Dynamic | Depends on session, owner, and URL filter |
| Project detail | Dynamic | Depends on session and owner |
| `/api/live` | Dynamic, `no-store` | Current process status |
| `/api/health` | Dynamic, `no-store` | Current database status |
| `/api/projects` | Dynamic, `private, no-store` | User-specific data |
| Optional project insights | Client-loaded on demand | Not required for initial route |

---

## B.11 “Where Should This Go?” Decision Tree

```text
Does it need a browser API, event handler, or React client hook?
│
├── Yes
│   └── Client Component
│       └── Does it need authoritative server data?
│           └── Receive safe serializable props from a Server Component.
│
└── No
    │
    ├── Does it read or write the database?
    │   └── Server-only lib module.
    │
    ├── Does it represent a route?
    │   └── app/.../page.tsx or app/api/.../route.ts.
    │
    ├── Does it mutate through a Next.js form?
    │   └── Server Action in an actions.ts module.
    │
    ├── Is it reusable visual UI?
    │   └── Component, server-compatible by default.
    │
    └── Is it validation, a type, or a pure helper?
        └── Environment-neutral src/lib module.
```

---

## B.12 Final Architecture Rules

Keep these rules visible while extending LaunchPad:

1. **Validate every untrusted value on the server.**
2. **Authenticate every protected server entry point.**
3. **Authorize every private database operation in SQL.**
4. **Keep database credentials and queries out of Client Components.**
5. **Use URL state for shareable navigation state.**
6. **Use local state for temporary browser interaction.**
7. **Keep Client Component boundaries small.**
8. **Do not globally cache private user data.**
9. **Return safe errors to users and useful details to protected logs.**
10. **Run migrations before deploying code that depends on them.**
11. **Measure performance before optimizing.**
12. **Treat backups, monitoring, and rollback as application features.**
