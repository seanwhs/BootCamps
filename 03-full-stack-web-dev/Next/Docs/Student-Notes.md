# LaunchPad: Student Notes

## From Zero to Production with Next.js 16

---

## Part 1: Introduction to Next.js

### Key Concepts

**React vs Next.js**
- React = UI library (components, state, props)
- Next.js = React framework (routing, server rendering, data fetching, optimization)

**App Router File Conventions**
| File | Purpose |
|------|---------|
| `page.tsx` | Creates a route |
| `layout.tsx` | Shared UI around child routes |
| `loading.tsx` | Loading UI for a route segment |
| `error.tsx` | Error UI for a route segment |
| `not-found.tsx` | 404 page |
| `route.ts` | API endpoint |

**Important npm Commands**
- `npm run dev` – Development server with Fast Refresh
- `npm run build` – Production build
- `npm run start` – Serve production build
- `npm run lint` – Run ESLint
- `npx tsc --noEmit` – Type check without compiling

**Key Takeaway:** Server Components are the default. They render on the server, reduce client JavaScript, and can be `async`.

---

## Part 2: Routing and Pages

### Route Types

**Static Routes**
```
src/app/about/page.tsx → /about
src/app/features/page.tsx → /features
```

**Dynamic Routes**
```
src/app/projects/[projectId]/page.tsx → /projects/website-redesign
```

**Search Parameters**
```
/projects?status=ACTIVE
```
- Server receives via `searchParams`
- Must be validated at runtime

**Key Points**
- Route parameters are **untrusted** – validate them
- `notFound()` triggers nearest `not-found.tsx`
- `generateStaticParams()` pre-builds dynamic routes
- Use `next/link` for client-side navigation

---

## Part 3: Layouts and UI Composition

### Route Groups

Directory name in parentheses: `(marketing)`

```
src/app/(marketing)/about/page.tsx → /about (NOT /marketing/about)
```

**Why use route groups?**
- Organize routes by purpose
- Apply different layouts
- Keep URLs clean

**Layout Hierarchy**
```
RootLayout (html, body, global metadata)
├── MarketingLayout (header, footer)
│   ├── /
│   ├── /about
│   └── /features
└── WorkspaceLayout (sidebar navigation)
    ├── /dashboard
    ├── /projects
    └── /projects/[projectId]
```

**Metadata Inheritance**
- Root layout defines template: `%s | LaunchPad`
- Child pages define `title: "About"`
- Result: `About | LaunchPad`

---

## Part 4: Server and Client Components

### Server Components (Default)

**Can:**
- Use `async`/`await`
- Read databases directly
- Access server-only environment variables
- Import server-only modules

**Cannot:**
- Use `useState`, `useEffect`
- Use browser APIs (window, document)
- Handle click events directly

### Client Components

**Mark with `"use client"` at top of file**

**Can:**
- Use React hooks (useState, useEffect, useMemo)
- Handle events (onClick, onChange)
- Use browser APIs
- Use `usePathname()`, `useRouter()`

**Cannot:**
- Import server-only modules (with `server-only` package)

### Passing Data Across Boundary

```tsx
// Server Component
<ClientComponent 
  data={serializableData}  // Must be serializable
/>
```

### Key Patterns

1. **Keep client boundaries small**
2. **Use `server-only` to prevent unsafe imports**
3. **Composition over adding `"use client"` everywhere**

---

## Part 5: Data Fetching in Next.js 16

### Architecture Layers

```
Browser → Server Component → Query Function → Database Client → PostgreSQL
```

### Key Concepts

**Environment Validation**
```ts
// src/lib/environment.ts
const schema = z.object({
  DATABASE_URL: z.string().url()
});
```
- Validate at startup
- Fail fast on misconfiguration
- Never expose secrets to browser

**Parameterized SQL**
```ts
// SAFE - values are parameters
await database`
  SELECT * FROM projects 
  WHERE id = ${projectId}
`

// UNSAFE - string concatenation
await database.unsafe(
  `SELECT * FROM projects WHERE id = '${projectId}'`
)
```

**Runtime Validation with Zod**
- TypeScript types disappear at runtime
- Zod validates actual data from database
- Use at query boundaries

**Streaming with Suspense**
```tsx
<Suspense fallback={<Loading />}>
  <DashboardMetrics />
</Suspense>
```
- Send completed sections independently
- Improves perceived performance

**Request Memoization**
```ts
export const getProjectById = cache(async (id) => {
  // Query once per request, reuse results
})
```

---

## Part 6: Styling Your Application

### CSS Organization

**Global CSS** (`globals.css`)
- Resets, body styles, design tokens
- Application shells

**Design Tokens** (`design-tokens.css`)
- Colors, spacing, fonts, radii
- Shared visual decisions

**CSS Modules** (`*.module.css`)
- Locally scoped class names
- Component-specific styles

**Accessibility Styles** (`accessibility.css`)
- Skip link, focus states, print styles
- Reduced motion support

### Key Patterns

**Skip Link**
```tsx
<a className="skip-link" href="#main-content">
  Skip to main content
</a>
<div id="main-content" tabIndex={-1}>
  {children}
</div>
```

**CSS Module Variants**
```tsx
const variantMap = {
  ACTIVE: styles.active,
  PLANNED: styles.planned,
} satisfies Record<Status, string>;
```

**Responsive Design**
- Media queries for breakpoints
- `clamp()` for fluid typography
- `prefers-reduced-motion`
- Print styles

---

## Part 7: Building APIs and Full-Stack Features

### Route Handlers

```ts
// src/app/api/projects/route.ts
export async function GET(request: Request) {
  // Query database
  return NextResponse.json({ data: projects })
}

export async function POST(request: Request) {
  const body = await request.json()
  // Validate, create, return 201
}
```

### Server Actions

```ts
"use server"

export async function createProjectAction(
  prevState: FormState,
  formData: FormData
): Promise<FormState> {
  const parsed = schema.safeParse({
    name: formData.get("name")
  })
  // Validate, mutate, revalidate, redirect
}
```

### Form Integration

```tsx
const [state, formAction, isPending] = useActionState(
  action,
  initialState
)

<form action={formAction}>
  <button disabled={isPending}>
    {isPending ? "Saving..." : "Save"}
  </button>
</form>
```

### Key HTTP Status Codes

| Status | Meaning |
|--------|---------|
| 200 | OK |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 404 | Not Found |
| 422 | Validation Error |
| 503 | Service Unavailable |

---

## Part 8: Authentication and State Management

### Authentication Flow

```
User submits credentials
    ↓
Server verifies credentials (bcrypt compare)
    ↓
Server creates random session token
    ↓
Database stores SHA-256 hash of token
    ↓
Browser receives token in HTTP-only cookie
    ↓
Future requests send cookie
    ↓
Server hashes cookie value, finds session
    ↓
Server loads authenticated user
```

### Password Hashing vs Session Hashing

**Passwords** → bcrypt (slow, salted)
**Session tokens** → SHA-256 (fast, high-entropy input)

### Cookie Attributes

```ts
{
  httpOnly: true,    // Not readable by JavaScript
  secure: true,      // Only over HTTPS
  sameSite: "lax",   // CSRF protection
  path: "/",         // Available everywhere
  expires: expiresAt // Persistent cookie
}
```

### Authorization in SQL

```sql
-- Read
SELECT * FROM projects
WHERE id = $projectId
  AND owner_id = $userId

-- Update
UPDATE projects
SET status = $status
WHERE id = $projectId
  AND owner_id = $userId

-- Task through project ownership
UPDATE tasks AS t
SET status = $status
FROM projects AS p
WHERE t.id = $taskId
  AND t.project_id = $projectId
  AND p.id = t.project_id
  AND p.owner_id = $userId
```

### Key Pattern: Return 404 for Unauthorized

```
If project doesn't exist: 404
If project belongs to another user: 404
```
This prevents confirming existence of private records.

---

## Part 9: Performance and Optimization

### Performance Cycle

```
Measure → Identify Bottleneck → Make Change → Measure Again
```

### Core Web Vitals

| Metric | Measures |
|--------|----------|
| LCP | Largest Contentful Paint (loading) |
| CLS | Cumulative Layout Shift (stability) |
| INP | Interaction to Next Paint (responsiveness) |

### `next/image` Best Practices

```tsx
<Image
  src="/image.png"
  alt="Description"
  width={1600}
  height={900}
  sizes="(max-width: 56rem) 100vw, 50vw"
  priority // Only for above-the-fold
/>
```

### Code Splitting

```tsx
const HeavyComponent = dynamic(
  () => import("./heavy-component"),
  { ssr: false }
)
```

- Only load optional features when needed
- Don't split critical components

### Cache Headers

| Header | Use Case |
|--------|----------|
| `Cache-Control: private, no-store` | Authenticated data |
| `Cache-Control: no-store` | Health checks |
| `Cache-Control: public, max-age=3600` | Public marketing content |

### Key Optimization Principles

1. **Measure before optimizing**
2. **Priority only for above-the-fold**
3. **Client Components only when necessary**
4. **Private data never shared in caches**

---

## Part 10: Deployment and Production Readiness

### Environment Validation

```ts
// Fail fast on invalid config
const schema = z.object({
  APP_URL: z.string().url(),
  DATABASE_URL: z.string().min(1),
  DATABASE_SSL: z.boolean(),
  LOG_LEVEL: z.enum(["debug", "info", "warn", "error"])
})
```

### Tracked Migrations

**Migration Table**
```sql
CREATE TABLE schema_migrations (
  filename TEXT PRIMARY KEY,
  checksum CHAR(64) NOT NULL,
  applied_at TIMESTAMPTZ NOT NULL
)
```

**Important:** Never edit an applied migration. Add new files.

### Health Checks

| Endpoint | Purpose |
|----------|---------|
| `/api/live` | Process is running (no dependencies) |
| `/api/health` | Can serve traffic (checks database) |

### Security Headers

| Header | Purpose |
|--------|---------|
| `Content-Security-Policy` | Restrict resource loading |
| `Strict-Transport-Security` | Enforce HTTPS |
| `X-Frame-Options: DENY` | Prevent clickjacking |
| `X-Content-Type-Options: nosniff` | Prevent MIME sniffing |

### Docker Multi-Stage Build

```
Dependencies Stage → Build Stage → Runtime Stage
```

Runtime image:
- Only `public` and `.next/standalone`
- Non-root user (`nextjs`)
- Minimal dependencies

### CI Pipeline Order

```
1. Install dependencies (`npm ci`)
2. Apply migrations
3. Verify idempotency
4. Type-check
5. Lint
6. Build
7. Start server
8. Liveness check
9. Smoke tests
```

### Deployment Order

1. Apply migration (backward-compatible)
2. Deploy application
3. Verify health
4. Run smoke tests
5. Remove obsolete schema later

---

## Important Patterns

### Security Checklist

- [ ] `server-only` on server modules
- [ ] No `NEXT_PUBLIC_` for secrets
- [ ] `.env.local` in `.gitignore`
- [ ] `owner_id` in all queries
- [ ] 404 for unauthorized resources
- [ ] Cookie: HttpOnly, Secure, SameSite
- [ ] Session tokens stored as hashes
- [ ] Passwords hashed with bcrypt

### Performance Checklist

- [ ] `next/image` with width, height, sizes
- [ ] Priority only for hero images
- [ ] Dynamic imports for optional features
- [ ] Private APIs: `Cache-Control: private, no-store`
- [ ] Client Components only when needed
- [ ] Measure before and after changes

### Deployment Checklist

- [ ] Environment variables validated
- [ ] Migrations tracked and checksummed
- [ ] Health endpoints working
- [ ] Security headers present
- [ ] Docker image minimal (standalone)
- [ ] CI passes all checks
- [ ] Smoke tests pass
- [ ] Backups configured

---

## Common Mistakes to Avoid

1. **Trusting client-side validation**
   - Always validate on the server

2. **Storing secrets in source control**
   - Use `.env.local` and secret managers

3. **Marking everything as Client Component**
   - Keep server-first as default

4. **Forgetting `owner_id` in queries**
   - Every query must check ownership

5. **Using `any` type**
   - Use specific types or `unknown`

6. **Catching `redirect()`**
   - Keep redirect outside try/catch

7. **Caching private data**
   - Use `private, no-store`

8. **Skipping production build test**
   - Development ≠ Production

9. **No `sizes` on images**
   - Causes layout shift, larger downloads

10. **Trusting URL parameters**
    - Always validate at runtime

---

## Quick Reference: Important Imports

```ts
// Router
import Link from "next/link"
import { redirect, notFound } from "next/navigation"

// Database
import postgres from "postgres"

// Validation
import { z } from "zod"

// Framework
import type { Metadata } from "next"
import { cache } from "react"

// Fonts
import { Geist, Geist_Mono } from "next/font/google"

// Images
import Image from "next/image"

// Dynamic Imports
import dynamic from "next/dynamic"

// Server-only
import "server-only"
```

---

## Final Architecture Overview

```
Browser
  ↓
Next.js 16 App
  ├── App Router (Pages, Layouts, Loading, Error)
  ├── Server Components (Data fetching, rendering)
  ├── Client Components (Interactivity, state)
  ├── Server Actions (Mutations from forms)
  ├── Route Handlers (API endpoints)
  ├── Authentication (Sessions, cookies)
  └── Authorization (Owner-scoped queries)
  ↓
PostgreSQL
  ├── users
  ├── sessions  
  ├── projects
  └── tasks
```
