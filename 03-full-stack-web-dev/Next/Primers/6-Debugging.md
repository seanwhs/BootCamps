# Primer 6: Debugging, Errors, and Problem-Solving Foundations

This primer prepares you to diagnose problems while building Next.js applications.

You will learn:

- How to read errors
- How to separate symptoms from causes
- How to debug terminal, browser, database, and API failures
- How to use small verification steps
- How to avoid changing too many things at once
- How to report useful bugs
- How to protect secrets while debugging

---

## 1. Errors Are Information

An error is not always a sign that you are doing something wrong.

It is information that tells you:

```text
Something expected by the application is missing, invalid, unavailable, or inconsistent.
```

For example:

```text
Cannot find module '@/components/project-card'
```

usually means one of these:

- The file does not exist.
- The import path is misspelled.
- The file was renamed.
- The path alias is not configured.
- File-name capitalization differs from the import.

The best debugging habit is:

> Read the first relevant error completely before changing code.

---

## 2. Symptoms Versus Causes

A **symptom** is what you observe.

Examples:

```text
- The page shows an error.
- The browser redirects to sign-in.
- The API returns 500.
- The build fails.
```

A **cause** is the underlying reason.

Examples:

```text
- PostgreSQL is not running.
- The session expired.
- A required environment variable is missing.
- A Client Component imported a server-only module.
```

One cause can create many symptoms.

Example:

```text
PostgreSQL stopped
    ↓
/api/health returns 503
    ↓
Workspace page error boundary appears
    ↓
Project API returns 500
```

Do not fix only the visible page error if the actual cause is a missing database connection.

---

## 3. The Standard Debugging Loop

Use this sequence:

```text
Observe
   ↓
Read the first useful error
   ↓
Identify the boundary
   ↓
Verify assumptions
   ↓
Make one small change
   ↓
Run the smallest relevant test
   ↓
Repeat
```

Example:

```text
Project page returns 404
   ↓
Check whether the UUID is valid
   ↓
Check whether the project exists
   ↓
Check project owner
   ↓
Check signed-in session user
   ↓
Confirm owner-scoped query receives correct user ID
```

Avoid this approach:

```text
Change many files
Restart everything
Hope the error disappears
```

That makes it difficult to know which change helped or caused a new problem.

---

## 4. Identify the Failing Boundary

LaunchPad has several major boundaries.

| Symptom | First boundary to inspect |
|---|---|
| Page does not load | Next.js route or rendering |
| Build fails | TypeScript, ESLint, imports, configuration |
| API fails | Route Handler, validation, authentication |
| Form fails | Server Action, form field names, validation |
| Project missing | UUID validation, ownership query, database |
| Readiness fails | PostgreSQL or environment configuration |
| Sign-in fails | User record, bcrypt hash, session creation |
| Client component error | Browser-only hook or server-only import |
| Docker runtime failure | Environment variables, network, database URL |

Ask:

> Which layer is the first one that could have produced this result?

---

## 5. Read Terminal Errors from the Top

A terminal can produce many lines of output.

The first useful error often contains the root cause.

Example:

```text
Error: Invalid server environment configuration:
APP_URL: APP_URL must be a valid absolute URL.
```

The root cause is:

```text
APP_URL is invalid.
```

Later messages may be consequences:

```text
Failed to compile.
Server terminated.
Build failed.
```

Fix the earliest meaningful error first.

---

## 6. Common TypeScript Errors

### Cannot find module

Example:

```text
Cannot find module '@/components/project-card'
```

Check the path:

```bash
find src/components -maxdepth 1 -type f | sort
```

Confirm the import:

```tsx
import { ProjectCard } from "@/components/project-card";
```

Check file capitalization:

```text
project-card.tsx
```

is different from:

```text
Project-Card.tsx
```

on case-sensitive file systems.

---

### Property does not exist

Example:

```text
Property 'ownerId' does not exist on type 'ProjectSummary'.
```

This means code expects a property that the type does not declare.

Inspect the type:

```bash
grep -n "type ProjectSummary" \
  src/lib/project-types.ts
```

Then decide whether:

- The code should use an existing property.
- The type should be updated.
- The database query should return the missing field.
- The property should remain private and not cross into the component.

Do not add properties to types only to silence errors unless the underlying runtime data truly contains them.

---

### Expected arguments but got fewer

Example:

```text
Expected 2 arguments, but got 1.
```

After Part 8, project queries require `userId`.

Outdated call:

```ts
const projects = await getProjects();
```

Correct call:

```ts
const user = await requireUser();

const projects = await getProjects(user.id);
```

TypeScript is protecting the ownership boundary by ensuring the user ID is passed.

---

## 7. Common Next.js Errors

### Server-only module imported by a Client Component

Example:

```text
You're importing a component that needs server-only code.
```

Cause:

A file with `"use client"` imported something like:

```text
src/lib/database/project-queries.ts
src/lib/auth/session.ts
src/lib/environment.ts
```

Correct design:

```text
Server Component
    ↓
Loads authorized data
    ↓
Passes safe serializable props
    ↓
Client Component
```

Example:

```tsx
export default async function ProjectsPage() {
  const user = await requireUser();
  const projects = await getProjects(user.id);

  return <ProjectList projects={projects} />;
}
```

The Client Component receives the projects. It does not query PostgreSQL directly.

---

### Dynamic route does not work

Check file placement:

```text
src/app/(workspace)/projects/[projectId]/page.tsx
```

Check route URL:

```text
/projects/10000000-0000-4000-8000-000000000001
```

Check parameter usage:

```tsx
const { projectId } = await params;
```

Validate the UUID before querying.

---

### `notFound()` does not display expected UI

Confirm the page imports:

```tsx
import { notFound } from "next/navigation";
```

Confirm the code calls it:

```tsx
if (!project) {
  notFound();
}
```

Confirm `src/app/not-found.tsx` exists.

Remember: an owner-scoped query can return no row because:

```text
- Project does not exist
- User does not own project
```

Both should use not-found behavior.

---

## 8. Debugging Form and Server Action Failures

A form submission has several layers:

```text
Browser control
   ↓
FormData name
   ↓
Server Action
   ↓
Zod schema
   ↓
Authentication
   ↓
Authorization
   ↓
Database mutation
   ↓
Revalidation or redirect
```

Check them in that order.

### Step 1: Inspect the form field name

Example input:

```tsx
<input
  id="project-name"
  name="name"
  type="text"
/>
```

Action must read the same name:

```ts
formData.get("name");
```

This fails:

```tsx
<input name="projectName" />
```

combined with:

```ts
formData.get("name");
```

The action receives:

```text
null
```

for `name`.

---

### Step 2: Inspect validation errors

If the form shows:

```text
Correct the highlighted project fields.
```

check field-level errors and compare input requirements with the schema.

For project creation:

```ts
name: z.string().trim().min(1).max(120)
```

means the value cannot be:

```text
- missing
- empty after whitespace trim
- longer than 120 characters
```

---

### Step 3: Confirm authentication

A protected action should begin with:

```ts
const user = await requireUser();
```

If it redirects unexpectedly, inspect the session and cookie.

---

### Step 4: Confirm database mutation

Inspect PostgreSQL after a supposed successful mutation.

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      id,
      name,
      status,
      created_at
    FROM projects
    ORDER BY created_at DESC
    LIMIT 10;
  "
```

If the database changed but the browser appears stale, inspect route revalidation.

---

## 9. Debugging API Failures

Use `curl` to isolate API behavior from browser UI.

### Inspect status and response body

```bash
curl --silent \
  --write-out "\nStatus: %{http_code}\n" \
  http://localhost:3000/api/projects
```

Anonymous expected result:

```text
Status: 401
```

### Inspect headers

```bash
curl --silent \
  --dump-header - \
  --output /dev/null \
  http://localhost:3000/api/projects
```

Expected private API headers include:

```text
Cache-Control: private, no-store
Vary: Cookie
```

### Test authenticated API requests

```bash
SESSION_TOKEN='paste-session-cookie-value-here'

curl --fail --silent \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  http://localhost:3000/api/projects |
  python -m json.tool
```

Never commit the session value.

---

## 10. API Status Code Debugging

| Status | Meaning | First thing to inspect |
|---:|---|---|
| `200` | Request succeeded | Response data correctness |
| `201` | Resource created | Database row and ownership |
| `204` | Deletion succeeded | Record removal and cascade behavior |
| `400` | Invalid request structure | JSON, content type, UUID |
| `401` | Missing or invalid session | Cookie and session table |
| `404` | Missing or unauthorized resource | Resource and owner ID |
| `422` | Schema validation failed | Zod error details |
| `500` | Unexpected server failure | Server logs and database health |
| `503` | Dependency unavailable | PostgreSQL and environment config |

---

## 11. Debugging PostgreSQL

### Check database status

```bash
npm run db:status
```

### Start database

```bash
npm run db:start
```

### Check readiness directly

```bash
docker compose exec db \
  pg_isready \
  --username=launchpad \
  --dbname=launchpad
```

Expected output:

```text
accepting connections
```

### Open SQL shell

```bash
npm run db:shell
```

Then run:

```sql
\dt
```

List tables.

```sql
SELECT COUNT(*) FROM projects;
```

Count projects.

```sql
\q
```

Exit.

---

## 12. Debugging Health Failures

Check liveness:

```bash
curl --silent \
  --output /dev/null \
  --write-out "Liveness: %{http_code}\n" \
  http://localhost:3000/api/live
```

Check readiness:

```bash
curl --silent \
  --output /dev/null \
  --write-out "Readiness: %{http_code}\n" \
  http://localhost:3000/api/health
```

Interpretation:

| Liveness | Readiness | Likely meaning |
|---:|---:|---|
| `200` | `200` | Application and database available |
| `200` | `503` | Application works, database unavailable |
| Non-`200` | Non-`200` | Application, proxy, or deployment issue |

If readiness returns `503`:

```bash
npm run db:start
npm run db:status
```

Then inspect `.env.local`:

```bash
cat .env.local
```

Expected local database configuration:

```dotenv
DATABASE_URL=postgresql://launchpad:launchpad-development-password@localhost:5432/launchpad
DATABASE_SSL=false
```

---

## 13. Debugging Authentication

### Verify demo user exists

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      id,
      name,
      email
    FROM users
    WHERE email = 'demo@launchpad.local';
  "
```

### Verify development password

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      password_hash = crypt(
        'LaunchPadDemo123!',
        password_hash
      ) AS password_matches
    FROM users
    WHERE email = 'demo@launchpad.local';
  "
```

Expected:

```text
t
```

### Inspect sessions

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      u.email,
      s.created_at,
      s.expires_at,
      s.expires_at > CURRENT_TIMESTAMP AS active
    FROM sessions AS s
    INNER JOIN users AS u
      ON u.id = s.user_id
    ORDER BY s.created_at DESC;
  "
```

If the seed was run, it intentionally deletes sessions.

Sign in again after:

```bash
npm run db:seed
```

---

## 14. Debugging Ownership Problems

Suppose User A owns this project:

```text
10000000-0000-4000-8000-000000000001
```

Inspect ownership:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      p.id,
      p.name,
      u.email AS owner_email
    FROM projects AS p
    INNER JOIN users AS u
      ON u.id = p.owner_id
    WHERE p.id =
      '10000000-0000-4000-8000-000000000001';
  "
```

If another user receives `404`, that may be correct.

Remember:

```text
404 can mean:
- Record does not exist
- Record exists but is owned by another user
```

This is intentional privacy behavior.

---

## 15. Debugging Migrations

### Apply migrations

```bash
npm run db:migrate
```

### Run again to verify idempotency

```bash
npm run db:migrate
```

Expected second result:

```text
Already applied: ...
Migration complete. 0 migration(s) applied.
```

### Inspect history

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

### Changed migration checksum error

If you see:

```text
Migration 001_create_projects_and_tasks.sql was changed after it was applied.
```

Do not edit the migration again.

Correct response:

```text
1. Restore historical file from Git.
2. Create a new migration.
3. Apply new migration.
```

For disposable local development only, reset the database:

```bash
npm run db:reset
npm run db:migrate
npm run db:seed
```

Never use this as a production fix.

---

## 16. Debugging Production Builds

Run:

```bash
npm run build
```

If it fails, check:

```text
- First error message
- Missing environment variables
- TypeScript errors
- Server/client boundary errors
- next.config.ts syntax
- Font download availability
```

Then run:

```bash
npm run typecheck
npm run lint
```

A successful development server does not guarantee a successful production build.

---

## 17. Debugging Docker

### Build image

```bash
docker build \
  --tag launchpad:debug \
  .
```

### View image

```bash
docker image ls launchpad:debug
```

### Run image

```bash
docker run \
  --rm \
  --name launchpad-debug \
  --add-host=host.docker.internal:host-gateway \
  --publish 3000:3000 \
  --env APP_URL=https://localhost:3000 \
  --env DATABASE_URL=postgresql://launchpad:launchpad-development-password@host.docker.internal:5432/launchpad \
  --env DATABASE_SSL=false \
  --env LOG_LEVEL=debug \
  --env APP_VERSION=debug \
  launchpad:debug
```

### Check container logs

If running detached:

```bash
docker logs launchpad-debug
```

### Important networking rule

Inside a container:

```text
localhost
```

means:

```text
the container itself
```

To reach PostgreSQL running on your host machine, use:

```text
host.docker.internal
```

On Linux, add:

```bash
--add-host=host.docker.internal:host-gateway
```

---

## 18. Debugging Client-Side Interaction

Use browser developer tools.

### Console

Check for:

```text
- JavaScript errors
- Hydration warnings
- CSP violations
- Failed dynamic imports
```

### Network panel

Check:

```text
- API requests
- Status codes
- Failed image requests
- Optional JavaScript chunks
- Slow resources
```

### Application or Storage panel

Check:

```text
- Session cookie exists
- Cookie is HTTP-only
- Cookie is Secure in production
- Cookie expiration is reasonable
```

### React DevTools

Useful for inspecting:

```text
- Component tree
- Props
- Local state
- Rerenders
```

Do not use browser tools to treat client state as authoritative application state.

---

## 19. Debugging Performance

Start with measurement:

```bash
npm run build
npm run start
./scripts/measure-routes.sh
```

Then inspect:

```bash
npm run analyze
```

Before optimizing, identify:

```text
- Slow route response
- Large image
- Large JavaScript dependency
- Slow database query
- Excessive client rendering
- Repeated query
```

For database performance, inspect query plan:

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

Do not add indexes only because a query exists. Use real query evidence.

---

## 20. Debugging Safety Rules

Never paste these into:

```text
- Git commits
- Screenshots
- Public issue trackers
- Chat messages
- Source files
- Browser console logs
```

Sensitive values include:

```text
- DATABASE_URL
- Production passwords
- Session cookie tokens
- Authorization headers
- API keys
- Email provider credentials
- Monitoring tokens
```

If a secret is exposed:

```text
1. Treat it as compromised.
2. Rotate it.
3. Remove active access.
4. Review logs and access.
5. Prevent recurrence.
```

---

## 21. Useful Debug Command Sequence

When LaunchPad behaves unexpectedly, run:

```bash
git status

npm run db:status

npm run typecheck

npm run lint

npm run build
```

Then start production mode:

```bash
npm run start
```

In another terminal:

```bash
npm run smoke
```

Then inspect health:

```bash
curl --fail --silent \
  http://localhost:3000/api/live |
  python -m json.tool

curl --fail --silent \
  http://localhost:3000/api/health |
  python -m json.tool
```

This sequence checks:

```text
Source state
Database status
Type correctness
Code quality
Production compilation
Critical route behavior
Process liveness
Database readiness
```

---

## 22. Primer Completion Checklist

Before returning to the main series, confirm that you can:

- [ ] Distinguish symptoms from root causes.
- [ ] Read the first useful error in terminal output.
- [ ] Identify whether a problem belongs to browser, route, server, database, or deployment boundaries.
- [ ] Use `curl` to inspect API status codes and headers.
- [ ] Check PostgreSQL status and inspect records.
- [ ] Diagnose missing sessions.
- [ ] Understand why a private-resource `404` may be correct.
- [ ] Diagnose common TypeScript import and type errors.
- [ ] Diagnose server-only and Client Component boundary errors.
- [ ] Verify form field names match Server Action reads.
- [ ] Verify migration state and checksum history.
- [ ] Build and run production mode locally.
- [ ] Inspect Docker logs and container networking.
- [ ] Avoid exposing secrets while debugging.
- [ ] Make one controlled change at a time.
