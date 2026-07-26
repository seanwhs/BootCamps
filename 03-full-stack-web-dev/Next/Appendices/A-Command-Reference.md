# Appendix A: Complete LaunchPad Command Reference

This appendix collects the commands used throughout the series in one place.

---

## A.1 Application Commands

Run these from the project root:

```bash
cd launchpad
```

### Start development mode

```bash
npm run dev
```

Open:

```text
http://localhost:3000
```

Development mode includes Fast Refresh and detailed errors.

---

### Type-check the application

```bash
npm run typecheck
```

Equivalent command:

```bash
npx tsc --noEmit
```

This checks TypeScript without creating compiled files.

---

### Lint the application

```bash
npm run lint
```

This runs ESLint against the project source.

---

### Create a production build

```bash
npm run build
```

This creates optimized output in:

```text
.next/
```

---

### Run the production build locally

First build:

```bash
npm run build
```

Then start:

```bash
npm run start
```

Open:

```text
http://localhost:3000
```

---

### Run all local source checks

```bash
npm run typecheck
npm run lint
npm run build
```

---

## A.2 Database Commands

LaunchPad uses PostgreSQL through Docker Compose.

### Start PostgreSQL

```bash
npm run db:start
```

Equivalent Docker command:

```bash
docker compose up --detach db
```

---

### Check database status

```bash
npm run db:status
```

Expected healthy output includes:

```text
healthy
```

---

### Stop PostgreSQL without deleting data

```bash
npm run db:stop
```

Equivalent command:

```bash
docker compose stop db
```

The Docker volume remains, so database records persist.

---

### Reset the local database completely

```bash
npm run db:reset
```

This removes the Docker volume and therefore deletes all local data.

After reset, recreate the schema and sample data:

```bash
npm run db:migrate
npm run db:seed
```

---

### Apply tracked migrations

```bash
npm run db:migrate
```

The migration runner:

1. Creates the migration-history table if needed.
2. Acquires a PostgreSQL advisory lock.
3. Verifies checksums for existing migrations.
4. Applies new migrations in filename order.
5. Records their filename and checksum.

---

### Seed deterministic development data

```bash
npm run db:seed
```

> This command is destructive for the local development database. Never run it against production.

The expected seeded state is:

```text
Users:    1
Sessions: 0
Projects: 4
Tasks:    12
```

---

### Open a PostgreSQL shell

```bash
npm run db:shell
```

Useful PostgreSQL commands:

```sql
\dt
```

List tables.

```sql
\d projects
```

Describe the `projects` table.

```sql
SELECT * FROM schema_migrations;
```

Inspect applied migrations.

```sql
\q
```

Exit the PostgreSQL shell.

---

## A.3 Health and Smoke-Test Commands

### Check process liveness

```bash
curl --fail --silent \
  http://localhost:3000/api/live |
  python -m json.tool
```

Expected response shape:

```json
{
  "data": {
    "status": "alive",
    "checkedAt": "2026-07-26T00:00:00.000Z",
    "version": "development"
  }
}
```

---

### Check application readiness

```bash
curl --fail --silent \
  http://localhost:3000/api/health |
  python -m json.tool
```

A healthy application returns:

```text
200
```

If PostgreSQL is unavailable, readiness should return:

```text
503
```

while liveness remains:

```text
200
```

---

### Run production smoke tests

Start production mode:

```bash
npm run build
npm run start
```

In another terminal:

```bash
npm run smoke
```

To test another deployment:

```bash
BASE_URL=https://your-production-domain.example.com \
npm run smoke
```

---

## A.4 Performance Commands

### Measure public-route timings

```bash
./scripts/measure-routes.sh
```

To point it at a deployed environment:

```bash
BASE_URL=https://your-production-domain.example.com \
./scripts/measure-routes.sh
```

---

### Run the bundle analyzer

```bash
npm run analyze
```

This creates a production build and opens or generates bundle reports.

Review the browser bundle for accidental inclusion of server-only dependencies such as:

```text
postgres
bcryptjs
database query modules
session modules
```

---

### Generate the home-page image asset

```bash
python3 scripts/generate-launchpad-image.py
```

PowerShell:

```powershell
python scripts/generate-launchpad-image.py
```

Generated file:

```text
public/launchpad-dashboard.png
```

---

## A.5 Docker Commands

### Build the production image

```bash
docker build \
  --tag launchpad:latest \
  .
```

---

### Run the container with local PostgreSQL

Docker Desktop for macOS or Windows:

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

Linux:

```bash
docker run \
  --rm \
  --name launchpad-production \
  --add-host=host.docker.internal:host-gateway \
  --publish 3000:3000 \
  --env APP_URL=https://localhost:3000 \
  --env DATABASE_URL=postgresql://launchpad:launchpad-development-password@host.docker.internal:5432/launchpad \
  --env DATABASE_SSL=false \
  --env LOG_LEVEL=info \
  --env APP_VERSION=local-container \
  launchpad:latest
```

---

### Verify the container user is not root

```bash
docker run \
  --rm \
  --entrypoint id \
  launchpad:latest
```

Expected output includes:

```text
uid=1001(nextjs)
```

It should not show:

```text
uid=0(root)
```

---

## A.6 Git Commands

### Inspect changes

```bash
git status
git diff
```

---

### Stage changes

```bash
git add src
```

For a wider change:

```bash
git add .
```

Always inspect staged files before committing:

```bash
git diff --cached --stat
git diff --cached
```

---

### Create a commit

```bash
git commit -m "feat: describe the change"
```

---

### Confirm a clean repository

```bash
git status
```

Expected output:

```text
nothing to commit, working tree clean
```

---

### Confirm local secrets are ignored

```bash
git check-ignore .env.local
```

Expected output:

```text
.env.local
```

---

## A.7 Final Release Gate

Run this sequence before creating a release candidate:

```bash
npm run db:start
npm run db:migrate
npm run db:seed

npm ci
npm run typecheck
npm run lint
npm run build
```

Start the optimized app:

```bash
npm run start
```

Then, in another terminal:

```bash
npm run smoke
```

Finally, inspect Git:

```bash
git status
```

A release candidate should have:

```text
- successful migration run
- successful type check
- successful lint
- successful production build
- successful smoke test
- no uncommitted changes
- no committed secrets
```
