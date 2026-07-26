# Appendix L: LaunchPad Code Review and Architecture Checklist

Use this appendix during pull-request reviews, feature reviews, or before merging substantial changes.

The goal is not to enforce style mechanically. The goal is to catch mistakes at the boundary where they are cheapest to fix.

---

# L.1 General Change Review

Before reviewing implementation details, confirm the change has a clear purpose.

- [ ] The change solves a specific product or engineering problem.
- [ ] The pull request description explains expected behavior.
- [ ] New routes, APIs, or environment variables are documented.
- [ ] The change does not include unrelated refactoring.
- [ ] New dependencies have a clear justification.
- [ ] The change has been tested in development and production build modes.
- [ ] `git status` is clean after verification.

Useful review commands:

```bash
git diff main...HEAD
git diff --stat main...HEAD
npm run typecheck
npm run lint
npm run build
```

---

# L.2 Route and Layout Review

When adding or changing an App Router route:

- [ ] The file uses the correct Next.js convention: `page.tsx`, `layout.tsx`, `route.ts`, `loading.tsx`, or `error.tsx`.
- [ ] The route is placed in the correct route group.
- [ ] Route-group directory names do not accidentally change public URLs.
- [ ] The page exports route-specific metadata where useful.
- [ ] The route has a meaningful heading.
- [ ] The route has an appropriate loading, empty, error, or not-found state.
- [ ] The page does not create duplicate `<main>` landmarks.
- [ ] The page remains server-rendered unless browser behavior is necessary.

Example route structure:

```text
src/app/(workspace)/projects/[projectId]/
├── actions.ts
└── page.tsx
```

Expected responsibility split:

```text
page.tsx
├── Validate route parameter
├── Require authenticated user
├── Fetch authorized data
├── Render UI
└── Compose focused Client Components

actions.ts
├── Validate submitted data
├── Require authenticated user
├── Run authorized mutation
└── Revalidate affected paths
```

---

# L.3 Server and Client Component Review

For every new `"use client"` directive, ask:

> Does this component actually need a browser-only capability?

Valid reasons include:

```text
- useState
- useEffect
- useActionState
- Event handlers
- Clipboard API
- window or document
- usePathname
- Browser-only library
```

Review checklist:

- [ ] The Client Component has a specific browser-side responsibility.
- [ ] The `"use client"` boundary is as small as practical.
- [ ] A parent layout or page was not marked client-side unnecessarily.
- [ ] Client Components do not import database modules.
- [ ] Client Components do not import authentication session modules.
- [ ] Client Components do not import environment configuration.
- [ ] Client Components receive only serializable, safe props.
- [ ] No password hash, cookie token, secret, or unauthorized record crosses into the browser.

Search all client boundaries:

```bash
grep -R -l \
  '"use client"' \
  src \
  --include="*.tsx" |
  sort
```

Search for unsafe imports:

```bash
for file in $(grep -R -l '"use client"' src --include="*.tsx"); do
  if grep -E \
    'database/|auth/session|environment|server-only' \
    "${file}"; then
    echo "Review server-only import in ${file}"
  fi
done
```

---

# L.4 Input-Validation Review

Every external value is untrusted.

Review:

- [ ] URL parameters are validated.
- [ ] Search parameters are validated.
- [ ] Form data is validated with a server-side schema.
- [ ] JSON request bodies are validated.
- [ ] Enum values come from controlled schemas.
- [ ] Input lengths match database constraints.
- [ ] Errors are useful to users without exposing internals.
- [ ] Browser validation is treated as usability support, not security.

Unsafe:

```ts
const status = searchParams.status as ProjectStatus;
```

Safe:

```ts
const parsedStatus = projectStatusSchema.safeParse(
  searchParams.status,
);
```

Unsafe:

```ts
const projectId = params.projectId;
await getProjectById(user.id, projectId);
```

Safer:

```ts
const parsedProjectId = z.string().uuid().safeParse(
  projectId,
);

if (!parsedProjectId.success) {
  notFound();
}

await getProjectById(
  user.id,
  parsedProjectId.data,
);
```

---

# L.5 Authentication Review

For protected operations:

- [ ] The caller is authenticated on the server.
- [ ] The user identity comes from the session, not request input.
- [ ] Sign-in failures do not expose whether an email exists.
- [ ] Passwords are hashed with bcrypt or another appropriate password algorithm.
- [ ] Raw session tokens are not stored in PostgreSQL.
- [ ] Session cookies are HTTP-only.
- [ ] Production session cookies are Secure.
- [ ] Session expiration is checked server-side.
- [ ] Sign-out revokes the database session.
- [ ] Authentication code remains server-only.

Correct ownership source:

```ts
const user = await requireUser();

await createProject(
  user.id,
  parsedInput.data,
);
```

Incorrect ownership source:

```ts
await createProject(
  String(formData.get("ownerId")),
  parsedInput.data,
);
```

---

# L.6 Authorization Review

Authentication is not enough.

For each private read or mutation:

- [ ] SQL includes the authenticated user’s ownership scope.
- [ ] The server does not fetch all records and filter them in the browser.
- [ ] Route Handlers authenticate independently of page layouts.
- [ ] Server Actions authenticate independently of page layouts.
- [ ] Task operations verify project ownership.
- [ ] Unauthorized private resources do not reveal sensitive existence information.
- [ ] Cross-user negative tests exist or are added.

Correct project query:

```sql
SELECT
  id,
  name,
  description
FROM projects
WHERE id = ${projectId}
  AND owner_id = ${userId};
```

Correct task update:

```sql
UPDATE tasks AS t
SET status = ${status}
FROM projects AS p
WHERE t.id = ${taskId}
  AND t.project_id = ${projectId}
  AND p.id = t.project_id
  AND p.owner_id = ${userId};
```

Critical review question:

> Could User B obtain, update, delete, or infer User A’s private project by changing a UUID, request body, cookie, or query parameter?

If the answer is uncertain, the change is not ready to merge.

---

# L.7 Database and Migration Review

For every database change:

- [ ] The change is in a new numbered migration.
- [ ] No already-applied migration file was edited.
- [ ] The migration is backward-compatible where practical.
- [ ] New foreign keys and deletion behavior are intentional.
- [ ] New input constraints match application validation.
- [ ] Required indexes exist for expected query patterns.
- [ ] Migration runs successfully from a fresh database.
- [ ] Migration runner completes a second time with no new changes.
- [ ] Development seed data still works after the migration.
- [ ] Production seed commands are not introduced.

Check migration status:

```bash
npm run db:migrate
npm run db:migrate
```

Inspect history:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      filename,
      checksum,
      applied_at
    FROM schema_migrations
    ORDER BY filename;
  "
```

---

# L.8 API Review

For every Route Handler:

- [ ] Supported HTTP methods are intentional.
- [ ] Status codes accurately describe the outcome.
- [ ] JSON bodies require `application/json`.
- [ ] Malformed JSON returns `400`.
- [ ] Structurally invalid values return `422`.
- [ ] Unauthenticated private requests return `401`.
- [ ] Missing or undiscoverable private resources return `404`.
- [ ] Successful creates return `201`.
- [ ] Successful deletions return `204` without a response body.
- [ ] Errors use the standard API envelope.
- [ ] Raw exceptions do not reach clients.
- [ ] Private API responses use `private, no-store`.
- [ ] Private API responses include `Vary: Cookie`.

Expected private API cache policy:

```http
Cache-Control: private, no-store
Vary: Cookie
```

Expected public health policy:

```http
Cache-Control: no-store
```

---

# L.9 Server Action Review

For every Server Action:

- [ ] The action begins with `"use server"`.
- [ ] The authenticated user is required before protected work.
- [ ] Bound identifiers are validated.
- [ ] `FormData` fields are validated through Zod.
- [ ] Owner-scoped mutations receive `user.id`.
- [ ] Expected validation failures return safe form state.
- [ ] Unexpected failures are logged safely.
- [ ] `redirect()` is outside ordinary `try/catch` handling.
- [ ] Affected route paths are revalidated.
- [ ] Duplicate submissions are considered.
- [ ] Pending state is visible in the form interface.

Correct redirect placement:

```ts
let projectId: string;

try {
  const project = await createProject(
    user.id,
    input,
  );

  projectId = project.id;
} catch {
  return {
    status: "error",
    message: "The project could not be created.",
  };
}

redirect(`/projects/${projectId}`);
```

---

# L.10 Performance Review

Before accepting a performance-related change:

- [ ] A baseline measurement exists.
- [ ] The optimization addresses an observed cost.
- [ ] Public and private cache policies remain correct.
- [ ] Private data is not globally cached.
- [ ] Client JavaScript is not increased unnecessarily.
- [ ] Large optional features are split only when justified.
- [ ] Images have dimensions and accurate `sizes`.
- [ ] `priority` is used only for important above-the-fold images.
- [ ] Database indexes are based on query patterns or evidence.
- [ ] Performance changes do not weaken authorization or accessibility.
- [ ] Production build and bundle analysis are checked when relevant.

Useful commands:

```bash
npm run analyze
./scripts/measure-routes.sh
npm run build
```

---

# L.11 Accessibility Review

For user-interface changes:

- [ ] Every interactive control has an accessible name.
- [ ] Labels are connected to form controls.
- [ ] Keyboard focus remains visible.
- [ ] The Tab order is logical.
- [ ] Errors use text, not color only.
- [ ] Status is communicated with text, not color only.
- [ ] Loading status is announced where needed.
- [ ] Dynamic disclosures use `aria-expanded`.
- [ ] Navigation regions have useful labels.
- [ ] There is exactly one `main-content` target.
- [ ] New images have appropriate `alt` text.
- [ ] The page remains usable at narrow widths and 200% zoom.
- [ ] Reduced-motion preference is respected.
- [ ] Print behavior remains reasonable.

Keyboard verification minimum:

```text
Tab → skip link
Enter → main content
Tab → primary navigation
Tab → form controls
Enter/Space → interactive controls
```

---

# L.12 Observability and Operations Review

For production-impacting changes:

- [ ] Errors are logged through structured logging where appropriate.
- [ ] Sensitive fields are not added to logs.
- [ ] Health behavior remains accurate.
- [ ] New critical dependencies affect readiness deliberately.
- [ ] New environment variables are added to `.env.example`.
- [ ] Environment variables are validated.
- [ ] Runbook documentation is updated.
- [ ] Deployment checklist is updated if needed.
- [ ] New background jobs have retry and monitoring plans.
- [ ] Database connection impact is understood.
- [ ] New external services have timeout and failure behavior.

---

# L.13 Final Merge Gate

Before merging to `main`, verify:

```bash
npm ci
npm run typecheck
npm run lint
npm run build
```

If PostgreSQL-backed behavior changed:

```bash
npm run db:start
npm run db:migrate
npm run db:seed
```

If the production server is running:

```bash
npm run smoke
```

Then confirm:

```bash
git status
```

Expected result:

```text
nothing to commit, working tree clean
```

---

# L.14 Reviewer’s Final Questions

Before approving a LaunchPad change, ask:

1. What data enters this feature?
2. Where is that data validated?
3. Who is the authenticated caller?
4. Where is authorization enforced?
5. Could another user access this record?
6. Which route or API response becomes stale after mutation?
7. What happens if PostgreSQL is unavailable?
8. What does the user see on validation failure?
9. What does the user see on unexpected failure?
10. Does the feature work with keyboard navigation?
11. Does it increase client JavaScript?
12. Does it affect production configuration, migrations, monitoring, or backups?

If these questions have clear answers, the change is usually being added at the correct architectural boundary.
