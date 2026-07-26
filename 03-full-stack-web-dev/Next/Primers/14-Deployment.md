# Primer 14: Deployment, CI, and Production Operations Foundations

This primer explains how a completed application becomes a deployed service that can be operated safely.

You will learn:

- What happens during deployment
- Why CI matters
- What migrations do during release
- How Docker packages an application
- How health checks support infrastructure
- Why secrets and configuration differ
- How smoke tests protect releases
- What rollback means
- How monitoring closes the production loop

---

## 1. Deployment Is a Process, Not a Button

A deployment is the process of making a new application version available to users.

A safe deployment usually looks like:

```text
Source code change
      ↓
Continuous integration checks
      ↓
Production build artifact
      ↓
Database migration
      ↓
Application deployment
      ↓
Liveness and readiness verification
      ↓
Smoke tests
      ↓
Monitoring
```

If any step fails, the release should stop or be investigated before users are affected.

---

## 2. Continuous Integration

**Continuous Integration**, or CI, is automation that verifies source changes in a clean environment.

LaunchPad CI checks:

```text
npm ci
    ↓
Apply database migrations
    ↓
Run migrations again to verify idempotency
    ↓
Type-check
    ↓
Lint
    ↓
Build production output
    ↓
Start production server
    ↓
Wait for liveness
    ↓
Run smoke tests
```

CI catches problems that a local machine may hide:

```text
- Missing dependency in package.json
- Uncommitted migration file
- Build relying on stale local artifacts
- Missing environment variable
- Database migration that fails on a fresh database
```

---

## 3. Why `npm ci` Is Used in CI

Use:

```bash
npm ci
```

instead of:

```bash
npm install
```

in CI.

`npm ci`:

```text
- Uses package-lock.json exactly
- Removes existing node_modules
- Produces reproducible installations
- Fails if package.json and lock file disagree
```

This helps ensure CI installs the same dependency tree that developers intended.

---

## 4. Production Builds

A Next.js production build is created with:

```bash
npm run build
```

This process:

```text
- Compiles TypeScript and JSX
- Processes route conventions
- Optimizes assets
- Validates Server and Client Component boundaries
- Generates static output where appropriate
- Creates standalone server output when configured
```

Run the built application with:

```bash
npm run start
```

Do not use:

```bash
npm run dev
```

as a production runtime.

Development mode includes tooling that changes performance and behavior.

---

## 5. Immutable Artifacts

An **immutable artifact** is a build output created once and deployed without modification.

Examples:

```text
- Docker image tagged by Git commit SHA
- Hosting-platform deployment generated from one commit
- Build artifact produced by CI
```

Why this matters:

```text
Build once
    ↓
Test artifact
    ↓
Deploy same artifact
```

This is safer than rebuilding separately on several servers because dependencies, generated assets, and build behavior cannot drift between environments.

---

## 6. Database Migrations During Deployment

A migration changes database structure.

Example:

```sql
ALTER TABLE projects
  ADD COLUMN archived_at TIMESTAMPTZ;
```

A deployment often needs both:

```text
New database schema
New application code
```

The safe release order is usually:

```text
1. Apply backward-compatible migration.
2. Deploy application code compatible with old and new schema.
3. Verify application.
4. Remove obsolete schema only in a later release.
```

Do not deploy destructive database changes casually.

---

## 7. Migration Idempotency

A migration runner should safely identify already-applied migrations.

LaunchPad stores migration history in:

```text
schema_migrations
```

Run migrations:

```bash
npm run db:migrate
```

Run them again:

```bash
npm run db:migrate
```

Expected second result:

```text
Already applied: 001_create_projects_and_tasks.sql
Already applied: 002_add_users_sessions_and_ownership.sql
Migration complete. 0 migration(s) applied.
```

This is **idempotency** in this context: repeating the command does not reapply completed work.

---

## 8. Why Migration Checksums Matter

LaunchPad stores a checksum for each migration file.

A checksum is a fingerprint of file contents.

If this migration has already run:

```text
001_create_projects_and_tasks.sql
```

and someone edits it later, the migration runner should fail.

Why?

```text
Production database history says:
Migration version A was applied.

Source code now says:
Migration version B exists with same filename.
```

Those histories no longer match.

Correct solution:

```text
Do not edit applied migration.
Create a new migration.
```

Example:

```text
003_add_project_archived_at.sql
```

---

## 9. Docker Containers

A Docker container packages an application and its runtime environment.

A LaunchPad production container includes:

```text
- Node.js runtime
- Built Next.js standalone server
- Static assets
- Public assets
- Non-root user
```

Build it:

```bash
docker build \
  --tag launchpad:latest \
  .
```

Run it:

```bash
docker run \
  --rm \
  --publish 3000:3000 \
  --env APP_URL=https://localhost:3000 \
  --env DATABASE_URL=postgresql://... \
  --env DATABASE_SSL=false \
  --env LOG_LEVEL=info \
  --env APP_VERSION=local \
  launchpad:latest
```

A container does not remove the need for:

```text
- Secrets
- Database connectivity
- Monitoring
- Backups
- HTTPS
- Migration safety
```

It standardizes application packaging.

---

## 10. Multi-Stage Docker Builds

LaunchPad uses a multi-stage Dockerfile.

```text
Dependencies stage
      ↓
Builder stage
      ↓
Runtime stage
```

### Dependencies stage

Installs packages:

```dockerfile
RUN npm ci
```

### Builder stage

Builds Next.js output:

```dockerfile
RUN npm run build
```

### Runtime stage

Copies only the files required to run the application:

```text
public/
.next/standalone/
.next/static/
```

This keeps the final image smaller and reduces unnecessary runtime tooling.

---

## 11. Non-Root Containers

Containers often start as the root user.

Running the application as root is unnecessary and increases the impact of some security failures.

LaunchPad creates a dedicated runtime user:

```dockerfile
USER nextjs
```

Verify:

```bash
docker run \
  --rm \
  --entrypoint id \
  launchpad:latest
```

Expected output includes a non-root user such as:

```text
uid=1001(nextjs)
```

---

## 12. Health Checks in Deployment

Infrastructure needs a reliable way to check whether the application should receive traffic.

LaunchPad provides:

```text
/api/live
/api/health
```

### Liveness

```text
GET /api/live
```

Checks whether the application process can respond.

### Readiness

```text
GET /api/health
```

Checks whether PostgreSQL is reachable.

A container health check may use liveness:

```dockerfile
HEALTHCHECK \
  CMD [
    "node",
    "-e",
    "fetch('http://127.0.0.1:3000/api/live')..."
  ]
```

An external monitor should usually check readiness:

```text
https://your-domain.example.com/api/health
```

---

## 13. Smoke Tests After Deployment

A smoke test verifies the most important release behavior.

LaunchPad runs:

```bash
npm run smoke
```

Against local production mode:

```bash
npm run build
npm run start
npm run smoke
```

Or against a deployment:

```bash
BASE_URL=https://your-production-domain.example.com \
npm run smoke
```

The smoke test checks:

```text
- Public routes return 200
- Liveness returns 200
- Readiness returns 200
- Private API returns 401 anonymously
- Protected route redirects anonymous visitor
- Private cache headers are present
```

Smoke tests should be fast enough to run after every deployment.

---

## 14. Environment Variables in Deployment

Production values should be supplied through the hosting platform’s secret store.

LaunchPad requires:

```text
APP_URL
DATABASE_URL
DATABASE_SSL
LOG_LEVEL
APP_VERSION
```

Example production values:

```dotenv
APP_URL=https://launchpad.example.com
DATABASE_SSL=true
LOG_LEVEL=info
APP_VERSION=abc123def456
```

`DATABASE_URL` is secret and should never appear in source code.

A hosting platform might provide values through:

```text
Vercel environment variables
Cloud Run secrets
GitHub Actions secrets
AWS Secrets Manager
Google Secret Manager
Azure Key Vault
```

---

## 15. Deployment Versioning

`APP_VERSION` identifies the deployed release.

A useful value is the Git commit SHA:

```bash
git rev-parse HEAD
```

Example:

```text
abc123def456789...
```

Why versioning helps:

```text
User reports error
    ↓
Log includes APP_VERSION
    ↓
Engineer identifies deployed code version
    ↓
Engineer compares recent changes
```

Include deployment version in:

```text
- Structured logs
- Health responses
- Monitoring events
- Release records
```

Do not expose sensitive deployment metadata unnecessarily, but a commit identifier is usually safe and useful.

---

## 16. Rollback Basics

A rollback deploys a previous known-good application artifact.

Example:

```text
Version A works.
Version B is deployed.
Version B causes 5xx errors.
Deploy Version A again.
```

Before rolling back, ask:

```text
- Did Version B apply a schema migration?
- Is Version A compatible with the new schema?
- Did Version B alter database data?
- Is a corrective forward fix safer?
```

Application rollback can be easy.

Database rollback may require:

```text
- Corrective migration
- Data restoration
- Manual repair
- Downtime planning
```

That is why backward-compatible migrations matter.

---

## 17. Monitoring After Release

Deployment success is only the beginning.

Watch:

```text
- Readiness failures
- 5xx response rate
- p95 latency
- Database connection count
- Database CPU and storage
- Sign-in failure rate
- Application memory
- Crash loops
- Error-monitoring events
```

A release is healthier when you can answer:

```text
- Is traffic succeeding?
- Is the database healthy?
- Are users signing in?
- Is latency acceptable?
- Did the new version increase errors?
```

---

## 18. Production Release Checklist

Before deployment:

```text
- CI is green.
- Migrations are reviewed.
- Secrets are configured.
- APP_URL uses HTTPS.
- Database TLS policy is correct.
- Backups are healthy.
- Connection pool capacity is understood.
- Build succeeds.
```

During deployment:

```text
- Apply migration.
- Deploy immutable artifact.
- Confirm application starts.
- Confirm liveness.
- Confirm readiness.
- Run smoke tests.
```

After deployment:

```text
- Confirm security headers.
- Confirm private APIs reject anonymous callers.
- Confirm sign-in works over HTTPS.
- Confirm session cookie is Secure and HTTP-only.
- Confirm cross-user project isolation.
- Monitor logs and latency.
```

---

## 19. Primer Completion Checklist

Before returning to the main series, you should understand:

- [ ] Why deployment is a process rather than a button click.
- [ ] What CI verifies.
- [ ] Why `npm ci` is used in clean environments.
- [ ] What a production build does.
- [ ] What an immutable artifact is.
- [ ] Why migrations must be backward compatible.
- [ ] Why migration checksums matter.
- [ ] What Docker containers provide.
- [ ] Why multi-stage builds reduce runtime footprint.
- [ ] Why applications should run as non-root users.
- [ ] The difference between liveness and readiness checks.
- [ ] What smoke tests verify.
- [ ] Why production secrets belong in secret stores.
- [ ] Why deployment versions are useful.
- [ ] Why rollback planning includes database compatibility.
- [ ] Which signals should be monitored after release.
