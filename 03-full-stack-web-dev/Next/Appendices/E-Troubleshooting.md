# Appendix E: Testing, Debugging, and Troubleshooting Reference

This appendix provides a practical process for diagnosing LaunchPad problems.

Use it when:

- A route returns an unexpected status
- PostgreSQL does not connect
- Authentication redirects unexpectedly
- A migration fails
- A Server Action does not update the interface
- A Client Component causes a build error
- Production behaves differently from development
- A build fails in CI or Docker

The most reliable debugging habit is:

```text
Observe the failure
      ↓
Reduce the affected boundary
      ↓
Verify inputs and configuration
      ↓
Inspect the first useful error
      ↓
Make one change
      ↓
Re-run the smallest relevant verification
```

---

# E.1 The Standard Debugging Checklist

Before changing code, identify the category of failure.

| Symptom | Likely boundary |
|---|---|
| Browser page is blank or shows an error overlay | Route, component, or render error |
| Browser route redirects unexpectedly | Authentication or layout guard |
| API returns `401` | Missing, invalid, or expired session |
| API returns `404` for an expected record | Missing resource or ownership check |
| API returns `422` | Validation schema rejected input |
| API returns `500` | Unexpected server, database, or application error |
| API returns `503` from `/api/health` | PostgreSQL or configuration problem |
| Build fails | TypeScript, lint, framework convention, or environment issue |
| Docker image fails at startup | Runtime environment variable or network issue |
| Data does not update after a form | Mutation, revalidation, or authorization issue |
| Client Component import fails | Server/client module boundary issue |

Start with:

```bash
npm run typecheck
npm run lint
```

Then check the current Git state:

```bash
git status
```

A clean working tree helps confirm whether the error comes from the current committed code or uncommitted local changes.

---

# E.2 Route Troubleshooting

## A route returns `404`

First inspect the route structure:

```bash
find src/app -type f | sort
```

Check that the route uses the correct App Router convention.

For example, this creates `/projects`:

```text
src/app/(workspace)/projects/page.tsx
```

This does **not** create a route:

```text
src/app/(workspace)/projects/projects.tsx
```

A route requires:

```text
page.tsx
```

### Check route status

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/projects
```

Expected status for an authenticated route without a session may be a redirect rather than `200`.

Inspect the redirect:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code} %{redirect_url}\n" \
  http://localhost:3000/projects
```

Expected anonymous result resembles:

```text
307 http://localhost:3000/sign-in
```

### Dynamic project routes

A valid project route uses a UUID:

```text
/projects/10000000-0000-4000-8000-000000000001
```

An old slug-style route from earlier tutorial parts no longer works:

```text
/projects/website-redesign
```

Expected result:

```text
404
```

---

# E.3 Authentication Troubleshooting

## Protected pages always redirect to `/sign-in`

Check whether the browser has a `launchpad_session` cookie.

In browser developer tools:

1. Open **Application** or **Storage**.
2. Open **Cookies**.
3. Select the LaunchPad origin.
4. Find:

   ```text
   launchpad_session
   ```

If it is missing, sign in again.

If it exists, inspect server-side session validity:

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
      s.expires_at > CURRENT_TIMESTAMP AS is_active
    FROM sessions AS s
    INNER JOIN users AS u
      ON u.id = s.user_id
    ORDER BY s.created_at DESC;
  "
```

Possible causes:

| Cause | Resolution |
|---|---|
| Session table is empty | Sign in again |
| Session expired | Sign in again |
| Database seed was run | The seed intentionally deletes all sessions |
| Cookie belongs to an old database | Clear cookies and sign in again |
| `DATABASE_URL` points to another database | Verify environment configuration |
| Secure cookie on plain HTTP | Test authentication through HTTPS deployment |

---

## Sign-in always reports invalid credentials

Verify the development user exists:

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

Verify the password hash:

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

Expected result:

```text
t
```

If no row appears or the password does not match, reset the local development database:

```bash
npm run db:reset
npm run db:migrate
npm run db:seed
```

Then sign in with:

```text
Email: demo@launchpad.local
Password: LaunchPadDemo123!
```

---

## Sign-in works locally but fails in production

Check production environment values:

```text
APP_URL=https://your-production-domain.example.com
DATABASE_SSL=true
LOG_LEVEL=info
APP_VERSION=<release identifier>
```

Common causes:

| Cause | Resolution |
|---|---|
| `APP_URL` uses HTTP | Use the final HTTPS origin |
| PostgreSQL TLS is required | Set `DATABASE_SSL=true` |
| Database URL is invalid | Update secret-store value |
| Database network access is blocked | Allow application access through provider configuration |
| Old deployment lacks migration | Apply migrations before deployment |
| Cookie domain/origin changed | Clear old browser cookies and sign in again |

---

# E.4 Authorization Troubleshooting

## A signed-in user receives `404` for their own project

First confirm the project exists and identify its owner:

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
    WHERE p.id = 'PROJECT_UUID_HERE';
  "
```

Then inspect the authenticated session user:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      u.id,
      u.email
    FROM sessions AS s
    INNER JOIN users AS u
      ON u.id = s.user_id
    WHERE s.expires_at > CURRENT_TIMESTAMP
    ORDER BY s.created_at DESC;
  "
```

The session user ID must match the project’s `owner_id`.

If they differ, the `404` is correct. Sign in with the correct account.

---

## A user can see another user’s project

This is a critical authorization defect.

Immediately inspect every project query:

```bash
grep -R \
  'FROM projects' \
  src/lib/database \
  --include="*.ts"
```

Every private project query must include:

```sql
owner_id = ${userId}
```

Inspect every task query:

```bash
grep -R \
  'FROM tasks\|UPDATE tasks\|INSERT INTO tasks' \
  src/lib/database \
  --include="*.ts"
```

Task operations must authorize through the parent project’s owner.

Example required task-read condition:

```sql
INNER JOIN projects AS p
  ON p.id = t.project_id
WHERE t.project_id = ${projectId}
  AND p.owner_id = ${userId}
```

Do not rely on:

```text
- Client-side filtering
- Hidden navigation
- Client-provided owner IDs
- A project page layout alone
```

---

# E.5 Database Troubleshooting

## PostgreSQL container does not start

Inspect Docker Compose:

```bash
docker compose ps
docker compose logs db
```

Check Docker itself:

```bash
docker --version
docker compose version
```

Common causes:

| Cause | Resolution |
|---|---|
| Docker Desktop is not running | Start Docker Desktop |
| Port `5432` is in use | Stop conflicting PostgreSQL instance or change the Compose port |
| Corrupted local volume | Reset only disposable development data |
| Invalid Compose YAML | Validate `compose.yaml` indentation and values |

To reset the development database completely:

```bash
npm run db:reset
npm run db:migrate
npm run db:seed
```

> This deletes local database records.

---

## `/api/health` returns `503`

Check liveness first:

```bash
curl --silent \
  --output /dev/null \
  --write-out "Liveness: %{http_code}\n" \
  http://localhost:3000/api/live
```

Then readiness:

```bash
curl --silent \
  --output /dev/null \
  --write-out "Readiness: %{http_code}\n" \
  http://localhost:3000/api/health
```

Expected during a database outage:

```text
Liveness: 200
Readiness: 503
```

Check PostgreSQL:

```bash
npm run db:status
```

Then:

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

Check configuration:

```bash
cat .env.local
```

Expected local values resemble:

```dotenv
APP_URL=http://localhost:3000
DATABASE_URL=postgresql://launchpad:launchpad-development-password@localhost:5432/launchpad
DATABASE_SSL=false
LOG_LEVEL=debug
APP_VERSION=development
```

Restart the service:

```bash
npm run db:start
```

---

## Migration runner fails

Run:

```bash
npm run db:migrate
```

Then inspect migration history:

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

### “Migration was changed after it was applied”

Example:

```text
Migration 001_create_projects_and_tasks.sql was changed after it was applied.
```

Cause:

```text
An applied migration file was edited.
```

Resolution:

1. Restore the migration file from Git.
2. Create a new migration for the new schema change.
3. Do not alter historical migration files.

For a disposable local database only, you may reset:

```bash
npm run db:reset
npm run db:migrate
npm run db:seed
```

Never reset production as a shortcut.

---

### Migration lock waits indefinitely

The migration runner uses a PostgreSQL advisory lock.

Inspect database activity:

```sql
SELECT
  pid,
  usename,
  application_name,
  state,
  query,
  query_start
FROM pg_stat_activity
WHERE datname = current_database()
ORDER BY query_start;
```

Possible causes:

- Another migration process is running.
- A deployment was interrupted.
- An administrative session holds a lock.

Do not terminate production sessions without understanding the consequence.

---

## Seed fails after a schema change

The development seed expects the current schema.

Apply migrations first:

```bash
npm run db:migrate
npm run db:seed
```

If the local database was created before tracked migrations existed, recreate it:

```bash
npm run db:reset
npm run db:migrate
npm run db:seed
```

---

# E.6 Build and TypeScript Troubleshooting

## `npm run typecheck` fails

Run:

```bash
npm run typecheck
```

Read the first error carefully.

Common categories:

| Error pattern | Likely cause |
|---|---|
| “Expected 2 arguments, but got 1” | Query or mutation signature changed |
| “Property does not exist” | Type and runtime shape disagree |
| “Cannot find module” | Wrong path, missing file, or missing package |
| “Type is not assignable” | Invalid prop or schema mismatch |
| “Object is possibly null” | Missing not-found or null handling |

After authentication was added, query functions require `userId`.

For example, this is outdated:

```ts
const projects = await getProjects();
```

Correct:

```ts
const user = await requireUser();

const projects = await getProjects(user.id);
```

---

## `npm run build` fails but development mode works

Development mode can compile routes on demand. Production build checks the entire application.

Run:

```bash
npm run build
```

Common causes:

| Cause | Resolution |
|---|---|
| Missing environment variable | Update `.env.local` or deployment secret |
| Server-only module imported into client graph | Move import behind Server Component boundary |
| Invalid route convention | Check `page.tsx`, `layout.tsx`, or `route.ts` placement |
| Font download unavailable | Ensure build environment has network access for `next/font/google` |
| CSP or config syntax error | Check `next.config.ts` |
| Migration-dependent build logic | Avoid querying private database data during build |

---

## Build fails because of `APP_URL`

The environment module requires an absolute URL.

Invalid:

```dotenv
APP_URL=localhost:3000
```

Valid:

```dotenv
APP_URL=http://localhost:3000
```

Production valid:

```dotenv
APP_URL=https://launchpad.example.com
```

---

# E.7 Server and Client Component Troubleshooting

## “You’re importing a component that needs `useState`”

Cause:

A Server Component imported a module that requires a Client Component boundary.

Resolution:

Move the interactive logic into a focused Client Component:

```tsx
"use client";

import { useState } from "react";
```

Then render that component from the server-rendered page.

---

## “This module cannot be imported from a Client Component”

Cause:

A Client Component imported a protected module containing:

```ts
import "server-only";
```

Common prohibited imports:

```text
src/lib/database/client.ts
src/lib/database/project-queries.ts
src/lib/auth/session.ts
src/lib/environment.ts
```

Correct architecture:

```text
Server Component
    ↓ fetches safe authorized data
Client Component
    ↓ receives serializable props
Browser interaction
```

Example:

```tsx
export default async function ProjectsPage() {
  const user = await requireUser();
  const projects = await getProjects(user.id);

  return <ProjectList projects={projects} />;
}
```

The Client Component receives:

```tsx
projects
```

It does not import the database query.

---

## Hydration mismatch warnings

A hydration mismatch means the initial browser render differs from the server-rendered output.

Avoid unstable render-time code:

```tsx
const value = Math.random();
const now = new Date().toISOString();
const width = window.innerWidth;
```

Prefer:

- Server-provided values
- `useId`
- Browser APIs in event handlers
- Effects for post-mount behavior

Incorrect:

```tsx
const url = window.location.href;
```

during render.

Correct:

```tsx
async function copyCurrentUrl() {
  await navigator.clipboard.writeText(
    window.location.href,
  );
}
```

inside a browser event handler.

---

# E.8 Form and Server Action Troubleshooting

## Form submits but no database record appears

Check the browser Network panel and server terminal.

Then verify database state:

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

Possible causes:

| Cause | Resolution |
|---|---|
| Browser validation blocked submission | Fill required fields |
| Zod schema rejected fields | Read displayed field errors |
| User is not authenticated | Sign in again |
| Session expired | Sign in again |
| Ownership condition does not match | Verify project owner and session user |
| PostgreSQL unavailable | Check `/api/health` |
| Server Action threw | Inspect server log |

---

## Form data is missing or invalid

Server Actions receive `FormData`.

Check that input `name` attributes match the action:

```tsx
<input name="name" />
<textarea name="description" />
<select name="status" />
```

Then verify server parsing:

```ts
const parsedInput = createProjectInputSchema.safeParse({
  name: formData.get("name"),
  description: formData.get("description"),
  status: formData.get("status"),
});
```

A mismatch such as this fails:

```tsx
<input name="projectName" />
```

combined with:

```ts
formData.get("name")
```

---

## A mutation succeeds but the page looks stale

Check that the affected route is revalidated:

```ts
revalidatePath("/dashboard");
revalidatePath("/projects");
revalidatePath(`/projects/${projectId}`);
```

Then refresh the browser once to distinguish:

- A revalidation problem
- A local Client Component state issue
- A database mutation issue

Inspect the database directly to determine the source of truth.

For example:

```sql
SELECT
  title,
  status,
  updated_at
FROM tasks
WHERE id = 'TASK_UUID_HERE';
```

---

## `redirect()` behaves like an error

In Server Actions, `redirect()` uses framework control flow.

Incorrect:

```ts
try {
  redirect("/dashboard");
} catch {
  return {
    status: "error",
  };
}
```

Correct:

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
  };
}

redirect(`/projects/${projectId}`);
```

Keep the redirect outside the ordinary mutation `try/catch`.

---

# E.9 API Troubleshooting

## Inspect private API status and headers

```bash
curl --silent \
  --dump-header - \
  --output /tmp/launchpad-api-response.json \
  http://localhost:3000/api/projects

cat /tmp/launchpad-api-response.json
```

Anonymous expected status:

```text
401
```

Expected cache policy:

```text
Cache-Control: private, no-store
Vary: Cookie
```

---

## Test authenticated APIs with a browser cookie

1. Sign in through the browser.
2. Copy the `launchpad_session` cookie value.
3. Assign it temporarily:

```bash
SESSION_TOKEN='paste-cookie-value-here'
```

4. Send it:

```bash
curl --fail --silent \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  http://localhost:3000/api/projects |
  python -m json.tool
```

Do not place the session token in:

```text
- source files
- shell scripts
- Git commits
- screenshots
- shared chat logs
```

---

## API returns `500`

Inspect the Next.js server output first.

Then verify:

```bash
curl --silent \
  http://localhost:3000/api/health |
  python -m json.tool
```

If health is degraded, fix PostgreSQL before investigating the API route.

If health is healthy, check:

- Input schema assumptions
- Database query result schema
- Ownership conditions
- Environment variables
- Server logs and request IDs

---

# E.10 CSS and Image Troubleshooting

## CSS Module styles do not appear

Check the file name:

```text
project-card.module.css
```

Check the import:

```tsx
import styles from "@/components/project-card.module.css";
```

Check class usage:

```tsx
<article className={styles.card}>
```

Incorrect global-style usage:

```tsx
<article className="card">
```

A CSS Module class is not a global class name.

---

## Image does not load

Check the local file:

```bash
ls -lh public/launchpad-dashboard.png
```

Check its URL:

```text
http://localhost:3000/launchpad-dashboard.png
```

Check the `Image` component:

```tsx
<Image
  src="/launchpad-dashboard.png"
  alt="..."
  width={1600}
  height={900}
/>
```

For local public files, do not write:

```tsx
src="/public/launchpad-dashboard.png"
```

The `/public` directory maps to the application root URL.

---

## Image optimizer endpoint returns an error

Test directly:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  "http://localhost:3000/_next/image?url=%2Flaunchpad-dashboard.png&w=1080&q=75"
```

Expected output:

```text
200
```

Check:

- The source file exists.
- `next.config.ts` is valid.
- Production build completed.
- The requested width is supported by configured image sizes.

---

# E.11 Docker Troubleshooting

## Docker build fails

Start with:

```bash
docker build \
  --no-cache \
  --tag launchpad:debug \
  .
```

Common causes:

| Cause | Resolution |
|---|---|
| `npm ci` fails | Ensure `package-lock.json` matches `package.json` |
| Font download fails | Ensure builder has network access |
| Environment validation fails | Check Dockerfile build-time placeholder variables |
| Standalone output missing | Confirm `output: "standalone"` in `next.config.ts` |
| File missing from context | Check `.dockerignore` is not excluding required source |

---

## Container starts but readiness fails

Check logs:

```bash
docker logs launchpad-production
```

Check liveness inside the container:

```bash
docker exec launchpad-production \
  node \
  -e "fetch('http://127.0.0.1:3000/api/live').then((response) => console.log(response.status))"
```

Check database network access.

On Linux, include:

```bash
--add-host=host.docker.internal:host-gateway
```

The database URL must point to:

```text
host.docker.internal
```

not:

```text
localhost
```

Inside a container, `localhost` refers to the container itself.

---

## Container cannot connect to PostgreSQL

Verify the database is running:

```bash
npm run db:status
```

Then inspect the connection string passed to Docker without printing credentials in public logs.

For local Docker usage, the host should be:

```text
host.docker.internal
```

Example:

```text
postgresql://launchpad:launchpad-development-password@host.docker.internal:5432/launchpad
```

For production, use the managed provider hostname and:

```text
DATABASE_SSL=true
```

when TLS is required.

---

# E.12 CI Troubleshooting

## GitHub Actions fails during migration

Inspect the migration step logs.

Confirm CI environment variables include:

```text
DATABASE_URL
DATABASE_SSL=false
APP_URL
LOG_LEVEL
APP_VERSION
```

Check migration files are committed:

```bash
git status
git ls-files database/migrations
```

Ensure the migration runner is executable and referenced correctly:

```bash
node scripts/migrate.mjs
```

---

## CI fails at smoke tests

The server may not be ready yet.

Inspect server logs:

```text
/tmp/launchpad-server.log
```

Check:

- The production build exists.
- `npm run start` started successfully.
- `/api/live` becomes available.
- Environment variables are valid.
- The smoke script expects the correct redirect status.

Reproduce locally:

```bash
npm run build
npm run start
npm run smoke
```

---

# E.13 Production Incident Triage

When a deployed application has an incident, begin with this sequence.

## 1. Check liveness

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  https://your-domain.example.com/api/live
```

Interpretation:

| Status | Meaning |
|---:|---|
| `200` | Application process can respond |
| Non-`200` | Deployment, process, proxy, or platform issue |

## 2. Check readiness

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  https://your-domain.example.com/api/health
```

Interpretation:

| Status | Meaning |
|---:|---|
| `200` | Application and PostgreSQL appear reachable |
| `503` | Database or required dependency problem |

## 3. Check logs

Search structured logs by:

```text
requestId
version
event
level=error
```

Do not search logs by passwords or session tokens.

## 4. Check recent deployments

Compare:

```text
Current APP_VERSION
Previous known-good version
Recent migrations
Recent secret changes
```

## 5. Decide whether to rollback

Rollback application code if:

- The problem began immediately after deployment.
- The previous artifact is schema-compatible.
- A rollback restores known-good behavior.

Prefer a corrective forward migration rather than blindly reversing database changes.

---

# E.14 Useful One-Line Diagnostics

## Show all table counts

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      (SELECT COUNT(*) FROM users) AS users,
      (SELECT COUNT(*) FROM sessions) AS sessions,
      (SELECT COUNT(*) FROM projects) AS projects,
      (SELECT COUNT(*) FROM tasks) AS tasks;
  "
```

## List active sessions

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      u.email,
      s.expires_at
    FROM sessions AS s
    INNER JOIN users AS u
      ON u.id = s.user_id
    WHERE s.expires_at > CURRENT_TIMESTAMP
    ORDER BY s.created_at DESC;
  "
```

## Verify migration state

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      filename,
      applied_at
    FROM schema_migrations
    ORDER BY filename;
  "
```

## Verify security headers

```bash
curl --silent \
  --dump-header - \
  --output /dev/null \
  http://localhost:3000
```

## Verify anonymous API rejection

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/api/projects
```

Expected result:

```text
401
```

## Verify protected-route redirect

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code} %{redirect_url}\n" \
  http://localhost:3000/dashboard
```

Expected anonymous result:

```text
307 http://localhost:3000/sign-in
```

---

# E.15 Debugging Principles to Keep

When troubleshooting LaunchPad, remember:

1. **The first relevant error is usually the most useful one.**
2. **The database is the source of truth for persisted records.**
3. **A browser interface can be stale even when the database mutation succeeded.**
4. **A protected route redirect does not prove API authorization is correct.**
5. **A hidden control does not prove a server operation is protected.**
6. **A successful development run does not prove a production build works.**
7. **A successful production build does not prove deployment configuration is valid.**
8. **A `404` for a private record may mean “not owned,” not only “missing.”**
9. **Resetting a local development database is acceptable; resetting production is not.**
10. **Never paste real passwords, session tokens, or production URLs into source code or logs.**
