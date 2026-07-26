# Appendix K: Production Configuration and Deployment Reference

This appendix collects LaunchPad’s deployment configuration in one place.

Use it when preparing a staging or production environment, reviewing deployment settings, or diagnosing configuration failures.

---

# K.1 Required Environment Variables

LaunchPad requires these server-side environment variables.

| Variable | Example development value | Production requirement |
|---|---|---|
| `APP_URL` | `http://localhost:3000` | Final HTTPS application URL |
| `DATABASE_URL` | Local PostgreSQL URL | Secret managed PostgreSQL connection URL |
| `DATABASE_SSL` | `false` | Usually `true` |
| `LOG_LEVEL` | `debug` | Usually `info` |
| `APP_VERSION` | `development` | Commit SHA or release identifier |

Example local file:

### `.env.local`

```dotenv
APP_URL=http://localhost:3000
DATABASE_URL=postgresql://launchpad:launchpad-development-password@localhost:5432/launchpad
DATABASE_SSL=false
LOG_LEVEL=debug
APP_VERSION=development
```

Example production configuration:

```dotenv
APP_URL=https://launchpad.example.com
DATABASE_URL=postgresql://production-user:production-password@production-host:5432/launchpad
DATABASE_SSL=true
LOG_LEVEL=info
APP_VERSION=abc123def456
```

> Do not commit `.env.local` or a production `.env` file.

---

# K.2 Configuration Validation Rules

LaunchPad validates environment configuration in:

```text
src/lib/environment.ts
```

The application fails fast when:

- `APP_URL` is missing or not an absolute URL.
- `DATABASE_URL` is missing or does not use PostgreSQL.
- `DATABASE_SSL` is not `true` or `false`.
- `LOG_LEVEL` is unsupported.
- `APP_VERSION` is empty.
- Production `APP_URL` does not begin with `https://`.

Production must not start with:

```dotenv
APP_URL=http://launchpad.example.com
```

It must use:

```dotenv
APP_URL=https://launchpad.example.com
```

---

# K.3 Local Development Setup

Start from a clean checkout:

```bash
npm ci
cp .env.example .env.local
npm run db:start
npm run db:migrate
npm run db:seed
npm run dev
```

Open:

```text
http://localhost:3000
```

Use the deterministic local development account:

```text
Email: demo@launchpad.local
Password: LaunchPadDemo123!
```

Do not use these credentials in staging or production.

---

# K.4 Fresh Local Database Setup

To delete the disposable Docker database and recreate it:

```bash
npm run db:reset
npm run db:migrate
npm run db:seed
```

Verify records:

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

Expected development result:

```text
1 | 0 | 4 | 12
```

---

# K.5 Staging Environment Rules

A staging environment should resemble production as closely as practical.

Recommended staging configuration:

```text
- Separate managed PostgreSQL database
- Separate environment variables
- HTTPS enabled
- DATABASE_SSL=true
- Unique staging database credentials
- APP_URL set to staging domain
- APP_VERSION set to tested commit SHA
- External readiness monitoring
- Automated migrations
```

Staging must not share:

```text
- Production database
- Production users
- Production session table
- Production secrets
- Production object storage
```

A useful staging URL might be:

```text
https://staging.launchpad.example.com
```

Then:

```dotenv
APP_URL=https://staging.launchpad.example.com
DATABASE_SSL=true
LOG_LEVEL=info
APP_VERSION=<commit-sha>
```

---

# K.6 Production Deployment Order

Use this order for a normal release:

```text
1. Confirm CI passes.
2. Review migrations.
3. Confirm backups are healthy.
4. Apply production migrations.
5. Deploy the immutable artifact.
6. Verify /api/live.
7. Verify /api/health.
8. Run smoke tests.
9. Verify HTTPS session cookies.
10. Monitor logs, errors, and latency.
```

Command sequence from a secure administrative environment:

```bash
npm ci
npm run typecheck
npm run lint
npm run build
npm run db:migrate
```

Deploy using the chosen platform after migrations are successful.

Then verify:

```bash
BASE_URL=https://your-production-domain.example.com \
npm run smoke
```

---

# K.7 Migration Deployment Rules

Run:

```bash
npm run db:migrate
```

The migration runner:

```text
- Uses DATABASE_URL.
- Uses DATABASE_SSL.
- Creates schema_migrations if needed.
- Acquires an advisory lock.
- Checks checksums.
- Applies migrations in filename order.
- Records successful migration history.
```

## Safe migration pattern

Prefer additive changes first.

```text
Release 1:
- Add new nullable field.
- Deploy code that supports old and new behavior.

Release 2:
- Backfill existing records.
- Make new field required if necessary.

Release 3:
- Remove obsolete reads.
- Remove old field only after old application versions are gone.
```

## Never do this

```text
1. Edit an already applied migration.
2. Run the development seed in production.
3. Drop a column still used by the currently deployed application.
4. Run migrations from multiple deployment processes without locking.
```

---

# K.8 Docker Runtime Configuration

Build the image:

```bash
docker build \
  --tag launchpad:latest \
  .
```

Run it:

```bash
docker run \
  --rm \
  --name launchpad-production \
  --publish 3000:3000 \
  --env APP_URL=https://localhost:3000 \
  --env DATABASE_URL=postgresql://launchpad:launchpad-development-password@host.docker.internal:5432/launchpad \
  --env DATABASE_SSL=false \
  --env LOG_LEVEL=info \
  --env APP_VERSION=local-container \
  launchpad:latest
```

On Linux, add:

```bash
--add-host=host.docker.internal:host-gateway
```

Verify:

```bash
curl --fail --silent \
  http://localhost:3000/api/live |
  python -m json.tool

curl --fail --silent \
  http://localhost:3000/api/health |
  python -m json.tool
```

---

# K.9 Vercel Environment Setup

For Vercel production, configure:

```text
APP_URL
DATABASE_URL
DATABASE_SSL
LOG_LEVEL
APP_VERSION
```

Example CLI sequence:

```bash
npx vercel@latest env add APP_URL production
npx vercel@latest env add DATABASE_URL production
npx vercel@latest env add DATABASE_SSL production
npx vercel@latest env add LOG_LEVEL production
npx vercel@latest env add APP_VERSION production
```

Recommended values:

```text
APP_URL=https://your-production-domain.example.com
DATABASE_SSL=true
LOG_LEVEL=info
APP_VERSION=<Git commit SHA>
```

After environment changes, redeploy:

```bash
npx vercel@latest --prod
```

Then run:

```bash
BASE_URL=https://your-production-domain.example.com \
npm run smoke
```

---

# K.10 Production Readiness Commands

Run locally before deployment:

```bash
npm ci
npm run typecheck
npm run lint
npm run build
```

Start local production mode:

```bash
npm run start
```

In another terminal:

```bash
npm run smoke
```

Inspect headers:

```bash
curl --silent \
  --dump-header - \
  --output /dev/null \
  http://localhost:3000
```

Check readiness:

```bash
curl --fail --silent \
  http://localhost:3000/api/health |
  python -m json.tool
```

Check anonymous private API behavior:

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

---

# K.11 Production Secret Rules

Production secrets include:

```text
DATABASE_URL
Database passwords
Provider API tokens
Monitoring DSNs
Email provider credentials
Object-storage credentials
Webhook signing keys
Encryption keys
```

They must not appear in:

```text
- Git commits
- .env.example
- Browser JavaScript
- Client Component props
- API responses
- Logs
- Screenshots
- Documentation examples
```

If a production secret is committed accidentally:

1. Treat it as compromised.
2. Rotate it immediately.
3. Remove it from active configuration.
4. Review access logs if possible.
5. Remove it from Git history if organizational policy requires it.
6. Add prevention controls such as secret scanning.

Deleting the secret from a later commit does not make the original exposure safe.

---

# K.12 Deployment Failure Decision Table

| Symptom | Likely cause | First response |
|---|---|---|
| Build fails | Missing config, source error, font network issue | Read first build error |
| Container exits immediately | Invalid runtime environment | Inspect container logs |
| `/api/live` fails | Application or proxy issue | Check deployment logs and process health |
| `/api/live` works but `/api/health` is `503` | Database connectivity issue | Check database status, TLS, network, limits |
| Private APIs return `401` after deployment | Missing or invalid session | Verify HTTPS cookie attributes and database sessions |
| Private pages redirect after sign-in | Cookie not sent or session lookup fails | Verify `APP_URL`, HTTPS, session table, database URL |
| Migration fails | Changed migration or SQL incompatibility | Stop deployment, inspect schema_migrations |
| High database connections | Pool size × instance count too high | Reduce pool or use a pooler |
| Increased 5xx after release | Runtime error or incompatible migration | Inspect structured logs and rollback compatibility |

---

# K.13 Final Deployment Rule

The application should be considered deployable only when all of these are true:

```text
- Environment configuration is validated.
- Production uses HTTPS.
- Secrets are outside Git.
- PostgreSQL uses TLS where required.
- Migrations are applied and checksum tracked.
- CI passes.
- Docker or platform build succeeds.
- Liveness and readiness checks pass.
- Smoke tests pass.
- Authentication works over HTTPS.
- Cross-user authorization remains enforced.
- Monitoring and backups are configured.
```
