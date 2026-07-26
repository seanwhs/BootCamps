# Primer 13: Caching, Performance, and Rendering Strategy Foundations

This primer explains how to make web applications faster without accidentally exposing private data or making interfaces stale.

You will learn:

- What caching is
- Static versus dynamic rendering
- Request memoization
- Public versus private cache rules
- Why authenticated data needs special care
- Parallel data loading
- Streaming and Suspense
- Code splitting
- Image and font optimization
- How to measure before optimizing

---

## 1. Performance Is Not One Number

“Fast” can mean several different things.

| Metric or experience | Question |
|---|---|
| Server response time | How long until the server begins responding? |
| Page render time | How soon does useful content appear? |
| JavaScript cost | How much browser code must download and execute? |
| Interaction responsiveness | How quickly does the page react to a click or key press? |
| Layout stability | Does content move unexpectedly while loading? |
| Database latency | How quickly do queries return? |

A fast production application balances all of these without weakening correctness or security.

---

## 2. Measure Before Optimizing

Do not optimize based only on intuition.

Start with a baseline:

```bash
npm run build
npm run start
```

Then measure routes:

```bash
./scripts/measure-routes.sh
```

Example output:

```text
route=/ status=200 first_byte=0.012s total=0.014s bytes=12345
route=/about status=200 first_byte=0.005s total=0.006s bytes=6789
```

This does not prove absolute production performance, but it creates a comparison point.

A useful optimization cycle:

```text
Measure
   ↓
Identify a bottleneck
   ↓
Make one deliberate change
   ↓
Measure again
   ↓
Keep, revise, or remove the change
```

---

## 3. Static Rendering

A route can be rendered ahead of requests when its output is the same for every visitor.

Examples:

```text
/
/about
/features
```

Conceptually:

```text
Build time
    ↓
Next.js renders page
    ↓
Output is reused for visitors
```

Static rendering is suitable for public content because it does not depend on:

```text
- Session cookies
- Authenticated users
- Private database records
- Request-specific values
```

Benefits include:

```text
- Fast delivery
- Less runtime server work
- Easy CDN distribution
```

---

## 4. Dynamic Rendering

A route must render dynamically when its output depends on the current request.

LaunchPad workspace routes are dynamic because they depend on:

```text
- Session cookie
- Authenticated user
- Owner-scoped PostgreSQL queries
```

Examples:

```text
/dashboard
/projects
/projects/:projectId
```

Conceptually:

```text
Request arrives
    ↓
Read cookie
    ↓
Find session
    ↓
Identify user
    ↓
Query owned records
    ↓
Render response
```

Dynamic rendering is not a failure of optimization. It is the correct strategy for secure private data.

---

## 5. Caching

A cache stores a reusable result.

Without caching:

```text
Request 1 → run work
Request 2 → run same work again
Request 3 → run same work again
```

With safe caching:

```text
Request 1 → run work and store result
Request 2 → reuse result
Request 3 → reuse result
```

Caching can reduce:

```text
- Database load
- Server CPU
- Network requests
- Page response time
```

But a cached answer is only useful when it remains safe and sufficiently fresh.

---

## 6. Public and Private Cache Rules

Public content may often be shared.

Example:

```text
/about
```

Every visitor sees the same explanation.

Private content must not be shared blindly.

Example:

```text
/api/projects
```

User A’s response may be:

```json
{
  "data": [
    {
      "name": "User A private project"
    }
  ]
}
```

User B must never receive that response.

LaunchPad private API responses use:

```http
Cache-Control: private, no-store
Vary: Cookie
```

This means:

```text
private
→ Shared caches should not reuse response broadly.

no-store
→ Do not retain response.

Vary: Cookie
→ Response behavior depends on cookies.
```

---

## 7. Why Private Data Is Dangerous to Cache

Imagine an unsafe cache key:

```text
/api/projects
```

The cache stores:

```text
User A project list
```

Then User B requests:

```text
/api/projects
```

If the cache ignores identity:

```text
User B receives User A data
```

That is a data exposure incident.

Before caching private data, answer:

```text
1. Does user identity affect this result?
2. Is identity part of the cache key?
3. Can two users safely share this result?
4. How long may it remain stale?
5. Which mutation invalidates it?
```

If answers are unclear, do not add shared caching.

---

## 8. Request Memoization

Request memoization is safer and narrower than a shared long-lived cache.

It reuses identical work during one server rendering request.

LaunchPad uses React `cache`:

```ts
import { cache } from "react";

export const getProjectById = cache(
  async (
    userId: string,
    projectId: string,
  ) => {
    // Owner-scoped database query.
  },
);
```

Suppose both metadata generation and page rendering need the same project.

```text
generateMetadata()
    ↓
getProjectById(userId, projectId)

ProjectPage()
    ↓
getProjectById(userId, projectId)
```

Request memoization can prevent duplicate query work during that one request.

The key includes:

```text
userId
projectId
```

The user ID is essential because authorization changes the permitted result.

---

## 9. Revalidation After Writes

A mutation changes the database source of truth.

Cached or rendered routes may now be outdated.

Example:

```text
User creates project
    ↓
Dashboard project count is stale
Project list is stale
```

LaunchPad revalidates relevant paths:

```ts
revalidatePath("/dashboard");
revalidatePath("/projects");
```

For task changes:

```ts
revalidatePath("/dashboard");
revalidatePath("/projects");
revalidatePath(`/projects/${projectId}`);
```

Revalidation is the connection between:

```text
Database write
    ↓
Fresh rendered application state
```

---

## 10. Parallel Data Loading

Independent asynchronous operations should begin together when possible.

Sequential version:

```ts
const project = await getProjectById(
  user.id,
  projectId,
);

const tasks = await getTasksForProject(
  user.id,
  projectId,
);
```

Timeline:

```text
Project query starts
    ↓
Project query finishes
    ↓
Task query starts
    ↓
Task query finishes
```

Parallel version:

```ts
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

Timeline:

```text
Project query starts ──────┐
                           ├── Wait for both
Task query starts ─────────┘
```

This can reduce total wait time.

Only use parallel loading when operations are genuinely independent.

---

## 11. Streaming and Suspense

Streaming sends completed sections before every section finishes.

LaunchPad dashboard example:

```tsx
<Suspense fallback={<DashboardMetricsSkeleton />}>
  <DashboardMetrics />
</Suspense>

<Suspense fallback={<ActiveProjectsSkeleton />}>
  <DashboardActiveProjects />
</Suspense>
```

Conceptually:

```text
Dashboard heading renders immediately
      ↓
Metrics query runs
Active projects query runs
      ↓
Metrics section streams when ready
      ↓
Active projects section streams when ready
```

This improves perceived responsiveness.

Streaming does not make a slow query intrinsically faster. It improves delivery of independently ready content.

---

## 12. Loading States

A loading state should tell the user that work is still in progress.

Example:

```tsx
export function DashboardMetricsSkeleton() {
  return (
    <section aria-busy="true">
      <p>Loading workspace statistics…</p>
    </section>
  );
}
```

Good loading states:

```text
- Preserve approximate layout
- Avoid large visual jumps
- Communicate pending work
- Respect reduced-motion preferences
```

LaunchPad skeletons disable shimmer animation for users who prefer reduced motion.

---

## 13. Code Splitting

Code splitting divides browser JavaScript into smaller pieces.

Route-level splitting happens automatically in Next.js.

Optional feature splitting can use:

```tsx
import dynamic from "next/dynamic";

const ProjectInsights = dynamic(
  () => import("@/components/project-insights"),
  {
    ssr: false,
    loading: () => <p>Loading insights…</p>,
  },
);
```

This means:

```text
Initial project page
    ↓
Does not download optional insights code yet
    ↓
User selects “Load project insights”
    ↓
Browser downloads the optional module
```

Good candidates:

```text
- Large charts
- Rich editors
- Map libraries
- Optional analysis panels
- Rare settings interfaces
- Complex modal tools
```

Poor candidates:

```text
- Main heading
- Essential navigation
- Required form field
- Primary project content
- Authentication controls
```

---

## 14. `next/image`

Images can affect performance and layout stability.

LaunchPad uses:

```tsx
import Image from "next/image";

<Image
  src="/launchpad-dashboard.png"
  alt="Illustration of the LaunchPad dashboard with project statistics and progress cards"
  width={1600}
  height={900}
  sizes="(max-width: 56rem) calc(100vw - 2rem), 50vw"
  priority
/>
```

Important properties:

| Property | Purpose |
|---|---|
| `src` | Image source |
| `alt` | Alternative text |
| `width` and `height` | Reserve layout space |
| `sizes` | Help browser select suitable responsive image |
| `priority` | Prioritize important above-the-fold image |

Do not use `priority` for every image.

Too many priority resources compete for network bandwidth.

---

## 15. Layout Shift

A layout shift happens when visible content moves unexpectedly.

Example problem:

```text
Page heading appears
    ↓
Large image loads without reserved height
    ↓
Image pushes content downward
```

This is disorienting.

Explicit dimensions help:

```tsx
<Image
  width={1600}
  height={900}
/>
```

The browser can reserve the correct aspect ratio before the image downloads.

---

## 16. `next/font`

Fonts can affect perceived speed and layout stability.

LaunchPad uses:

```tsx
import {
  Geist,
  Geist_Mono,
} from "next/font/google";
```

Example configuration:

```tsx
const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
  display: "swap",
});
```

`display: "swap"` means:

```text
Show fallback text first
    ↓
Use preferred font when ready
```

This is generally better than hiding text while a font loads.

---

## 17. Client JavaScript Cost

Client Components require browser JavaScript.

Every unnecessary Client Component can add:

```text
- Download bytes
- Parse work
- Execution work
- Hydration work
- Memory use
```

This is why LaunchPad keeps most page and data logic on the server.

Client Components are used only for browser behavior such as:

```text
- Local search
- Form pending state
- Clipboard copying
- Active navigation
- Expand/collapse disclosure
- Optional insights loader
```

Before adding `"use client"`, ask:

> Does this code need browser state, browser APIs, or event handlers?

If no, keep it server-compatible.

---

## 18. Bundle Analysis

A bundle analyzer shows what enters browser and server bundles.

Run:

```bash
npm run analyze
```

Inspect browser output for unexpected packages such as:

```text
postgres
bcryptjs
database query modules
session modules
```

These should never be in browser bundles.

A bundle analyzer helps answer:

```text
- Did an optional feature load eagerly?
- Did a server module accidentally cross a client boundary?
- Which dependency is largest?
- Did a new package add too much JavaScript?
```

---

## 19. Database Query Performance

A fast page can still have a slow database query.

Use PostgreSQL query plans:

```sql
EXPLAIN (
  ANALYZE,
  BUFFERS
)
SELECT
  id,
  name
FROM projects
WHERE owner_id = 'USER_UUID_HERE'
  AND status = 'ACTIVE';
```

Look for:

```text
- Execution time
- Rows scanned
- Rows returned
- Index scan or sequential scan
- Buffer reads
- Sorting
- Join behavior
```

A sequential scan on four development rows is normal.

Do not add indexes only because a sequential scan appears locally.

Use production-like data and measured evidence.

---

## 20. Performance Safety Rules

Performance changes must not weaken other system properties.

Never “optimize” by:

```text
- Removing authorization checks
- Sending every user’s data to the browser
- Caching private responses publicly
- Storing sessions in localStorage
- Disabling validation
- Removing loading or error feedback
- Removing accessibility labels
```

A fast data leak is still a data leak.

A fast inaccessible interface is still incomplete.

---

## 21. Primer Verification Exercise

Classify each item.

| Requirement | Best approach |
|---|---|
| Public About page | Static rendering |
| User dashboard | Dynamic server rendering |
| Project list status filter | URL state |
| Temporary text search | Local Client Component state |
| Project lookup used by metadata and page | Request memoization |
| Optional chart panel | Dynamic import |
| Project API response | `private, no-store` |
| Health endpoint | Dynamic `no-store` response |
| Hero image | `next/image` with dimensions |
| Password hashing | Server-only code |

---

## 22. Primer Completion Checklist

Before returning to the main series, you should understand:

- [ ] Why performance has several dimensions.
- [ ] Why optimization begins with measurement.
- [ ] The difference between static and dynamic rendering.
- [ ] What caching is and why private data is risky to cache.
- [ ] Why private APIs use `private, no-store`.
- [ ] What `Vary: Cookie` communicates.
- [ ] What request memoization does.
- [ ] Why revalidation follows mutations.
- [ ] When parallel async loading is appropriate.
- [ ] What streaming and Suspense improve.
- [ ] When to use dynamic imports.
- [ ] Why Client Components increase browser work.
- [ ] How `next/image` reduces layout shift.
- [ ] Why font loading affects user experience.
- [ ] Why query plans matter.
- [ ] Why security and accessibility remain requirements during optimization.
