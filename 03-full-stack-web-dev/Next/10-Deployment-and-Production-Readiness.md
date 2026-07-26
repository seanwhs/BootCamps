# Part 10: Deployment and Production Readiness

LaunchPad now has routing, layouts, Server and Client Components, PostgreSQL persistence, forms, APIs, authentication, authorization, optimized assets, and deliberate cache boundaries.

A successful production build is not the end of production engineering.

A deployed application also needs:

- Validated runtime configuration
- Repeatable database migrations
- Security-focused response headers
- Liveness and readiness checks
- Structured logs
- Automated CI checks
- Reproducible container builds
- Managed secrets
- Backups and restoration procedures
- Monitoring and alerting
- Deployment verification
- Rollback and incident procedures

By the end of Part 10, LaunchPad will include:

- Production environment validation
- SSL-aware PostgreSQL configuration
- Tracked, checksummed migrations
- Structured server logging
- Separate liveness and readiness endpoints
- Production security headers
- A standalone Next.js build
- A multi-stage Docker image
- Automated smoke tests
- A GitHub Actions pipeline
- A deployment workflow
- A production operations runbook
- Backup, rollback, monitoring, and scaling guidance
- Final production verification

---

# Step 1: Define the Production Architecture

## The Target

Understand the infrastructure LaunchPad requires in production and establish the deployment flow.

## The Concept

A local application can depend on one laptop. A production application must survive process restarts, deployment changes, and infrastructure failures.

The final architecture will be:

```text
                           Internet
                              │
                              ▼
                  ┌─────────────────────┐
                  │ HTTPS / Edge Layer  │
                  │                     │
                  │ TLS termination     │
                  │ Compression         │
                  │ Request filtering   │
                  │ Optional rate limit │
                  └──────────┬──────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ Next.js 16 App      │
                  │                     │
                  │ Server Components   │
                  │ Route Handlers      │
                  │ Server Actions      │
                  │ Session validation  │
                  │ Authorization       │
                  │ Structured logging  │
                  └──────────┬──────────┘
                             │ TLS
                             ▼
                  ┌─────────────────────┐
                  │ Managed PostgreSQL  │
                  │                     │
                  │ Users and sessions  │
                  │ Projects and tasks  │
                  │ Automated backups   │
                  │ Connection limits   │
                  └─────────────────────┘
```

The deployment sequence will be:

```text
Commit source
     ↓
Continuous integration
     ├── Install exact dependencies
     ├── Start PostgreSQL
     ├── Apply migrations
     ├── Type-check
     ├── Lint
     ├── Build
     └── Run smoke tests
     ↓
Build immutable artifact
     ↓
Apply production migration
     ↓
Deploy application
     ↓
Verify health and behavior
     ↓
Monitor
```

An **immutable artifact** is a build that is created once and promoted without changing its contents. This avoids different servers receiving subtly different application code.

## The Implementation

No source files change in this planning step.

LaunchPad’s production dependencies are:

| Dependency | Production responsibility |
|---|---|
| Next.js application | Render pages and handle server operations |
| Managed PostgreSQL | Persist users, sessions, projects, and tasks |
| HTTPS edge or proxy | Encrypt browser traffic |
| Secret store | Supply private environment variables |
| CI platform | Validate every proposed change |
| Monitoring platform | Record errors, logs, health, and performance |
| Backup system | Protect recoverable database history |

## The Verification

Confirm the local production build still succeeds:

```bash
npm run db:start
npm run typecheck
npm run lint
npm run build
```

Confirm Git begins this part cleanly:

```bash
git status
```

Expected output:

```text
nothing to commit, working tree clean
```

[GENERATED: Part 10, Step 1: Production Architecture] [STARTING: Part 10, Step 2: Runtime Environment Validation]

---

# Step 2: Strengthen Runtime Environment Validation

## The Target

Validate the production application URL, database TLS policy, log level, and application version in addition to `DATABASE_URL`.

## The Concept

Configuration errors should stop an application during startup rather than appearing later as confusing request failures.

For example, production must not silently use:

- An invalid database URL
- A non-HTTPS public application URL
- An unsupported log level
- An incorrect database TLS policy

This principle is called **failing fast**: detect unsafe configuration before serving user requests.

## The Implementation

Update the documented environment file.

### `.env.example`

```dotenv
# Local application URL.
# Production must use the public HTTPS origin.
APP_URL=http://localhost:3000

# Local PostgreSQL connection.
# Production must use a managed credential from a secret store.
DATABASE_URL=postgresql://launchpad:launchpad-development-password@localhost:5432/launchpad

# Local Docker PostgreSQL does not require TLS.
# Set this to true for managed production PostgreSQL unless the provider
# explicitly supplies a different secure connection mechanism.
DATABASE_SSL=false

# Supported values: debug, info, warn, error
LOG_LEVEL=info

# A deployment identifier such as a Git commit SHA or release number.
APP_VERSION=development
```

Update your local file.

### `.env.local`

```dotenv
APP_URL=http://localhost:3000
DATABASE_URL=postgresql://launchpad:launchpad-development-password@localhost:5432/launchpad
DATABASE_SSL=false
LOG_LEVEL=debug
APP_VERSION=development
```

Completely replace the environment module.

### `src/lib/environment.ts`

```ts
import "server-only";

import { z } from "zod";

const logLevels = [
  "debug",
  "info",
  "warn",
  "error",
] as const;

const rawEnvironmentSchema = z.object({
  APP_URL: z
    .string()
    .url("APP_URL must be a valid absolute URL."),

  DATABASE_URL: z
    .string()
    .min(1, "DATABASE_URL is required.")
    .refine(
      (value) =>
        value.startsWith("postgres://") ||
        value.startsWith("postgresql://"),
      "DATABASE_URL must use postgres:// or postgresql://.",
    ),

  DATABASE_SSL: z
    .enum(["true", "false"])
    .default("false"),

  LOG_LEVEL: z
    .enum(logLevels)
    .default("info"),

  APP_VERSION: z
    .string()
    .trim()
    .min(1, "APP_VERSION must not be empty.")
    .default("development"),

  NODE_ENV: z
    .enum([
      "development",
      "test",
      "production",
    ])
    .default("development"),
});

const parsedEnvironment = rawEnvironmentSchema.safeParse({
  APP_URL: process.env.APP_URL,
  DATABASE_URL: process.env.DATABASE_URL,
  DATABASE_SSL: process.env.DATABASE_SSL,
  LOG_LEVEL: process.env.LOG_LEVEL,
  APP_VERSION: process.env.APP_VERSION,
  NODE_ENV: process.env.NODE_ENV,
});

if (!parsedEnvironment.success) {
  const formattedErrors = parsedEnvironment.error.issues
    .map((issue) => {
      const path = issue.path.join(".") || "environment";
      return `${path}: ${issue.message}`;
    })
    .join("\n");

  throw new Error(
    `Invalid server environment configuration:\n${formattedErrors}`,
  );
}

const rawEnvironment = parsedEnvironment.data;

if (
  rawEnvironment.NODE_ENV === "production" &&
  !rawEnvironment.APP_URL.startsWith("https://")
) {
  throw new Error(
    "APP_URL must use HTTPS when NODE_ENV is production.",
  );
}

export const serverEnvironment = Object.freeze({
  appUrl: rawEnvironment.APP_URL,
  databaseUrl: rawEnvironment.DATABASE_URL,
  databaseSsl: rawEnvironment.DATABASE_SSL === "true",
  logLevel: rawEnvironment.LOG_LEVEL,
  appVersion: rawEnvironment.APP_VERSION,
  nodeEnvironment: rawEnvironment.NODE_ENV,
});
```

Update the database client to use the renamed validated properties and TLS policy.

### `src/lib/database/client.ts`

```ts
import "server-only";

import postgres from "postgres";

import { serverEnvironment } from "@/lib/environment";

type DatabaseClient = ReturnType<typeof postgres>;

const globalForDatabase = globalThis as typeof globalThis & {
  launchpadDatabase?: DatabaseClient;
};

function createDatabaseClient(): DatabaseClient {
  return postgres(serverEnvironment.databaseUrl, {
    max: 10,
    idle_timeout: 20,
    connect_timeout: 10,

    /**
     * Managed PostgreSQL services commonly require TLS. The production
     * environment explicitly enables it through DATABASE_SSL=true.
     */
    ssl: serverEnvironment.databaseSsl
      ? "require"
      : false,

    onnotice: () => undefined,
  });
}

export const database =
  globalForDatabase.launchpadDatabase ??
  createDatabaseClient();

if (process.env.NODE_ENV !== "production") {
  globalForDatabase.launchpadDatabase = database;
}

/**
 * Long-running container processes can call this during graceful shutdown.
 * Serverless platforms usually manage connection lifecycle themselves.
 */
export async function closeDatabase(): Promise<void> {
  await database.end({
    timeout: 5,
  });
}
```

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

Test invalid production configuration:

```bash
NODE_ENV=production \
APP_URL=http://insecure.example.com \
DATABASE_URL=postgresql://example:example@localhost:5432/example \
DATABASE_SSL=false \
LOG_LEVEL=info \
APP_VERSION=test \
npm run build
```

Expected result:

```text
Build failure explaining that production APP_URL must use HTTPS
```

Run the build again with local development configuration:

```bash
npm run build
```

It should succeed.

[GENERATED: Part 10, Step 2: Runtime Environment Validation] [STARTING: Part 10, Step 3: Tracked Database Migrations]

---

# Step 3: Create a Tracked Migration Runner

## The Target

Replace manually chained SQL commands with a migration runner that records filenames and checksums in PostgreSQL.

## The Concept

A production migration system must answer:

- Which migrations have been applied?
- In what order were they applied?
- Has an applied migration file been changed?
- Did the migration complete atomically?

A checksum is a deterministic fingerprint of file contents.

If an already-applied migration changes, its checksum changes. The runner will stop rather than pretending that production history still matches source control.

Applied migrations should be immutable. To change the schema, add a new migration.

## The Implementation

Create the migration runner.

### `scripts/migrate.mjs`

```js
#!/usr/bin/env node

import { createHash } from "node:crypto";
import {
  readdir,
  readFile,
} from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import postgres from "postgres";

const migrationsDirectory = path.resolve(
  process.cwd(),
  "database",
  "migrations",
);

const databaseUrl = process.env.DATABASE_URL;
const databaseSsl = process.env.DATABASE_SSL === "true";

if (!databaseUrl) {
  console.error("DATABASE_URL is required.");
  process.exit(1);
}

function calculateChecksum(contents) {
  return createHash("sha256")
    .update(contents)
    .digest("hex");
}

/**
 * Existing migration files include their own BEGIN and COMMIT statements.
 * The runner owns the transaction so it removes those outer statements
 * before executing the migration.
 */
function removeOuterTransaction(contents) {
  return contents
    .replace(/^\s*BEGIN;\s*/i, "")
    .replace(/\s*COMMIT;\s*$/i, "")
    .trim();
}

const database = postgres(databaseUrl, {
  max: 1,
  connect_timeout: 10,
  idle_timeout: 5,
  ssl: databaseSsl ? "require" : false,
  onnotice: () => undefined,
});

async function createMigrationTable() {
  await database`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      filename TEXT PRIMARY KEY,
      checksum CHAR(64) NOT NULL,
      applied_at TIMESTAMPTZ NOT NULL
        DEFAULT CURRENT_TIMESTAMP
    )
  `;
}

async function acquireMigrationLock() {
  /**
   * PostgreSQL advisory locks prevent two deployment processes from applying
   * migrations concurrently. The numeric value is an application-specific
   * stable lock identifier.
   */
  await database`
    SELECT pg_advisory_lock(7102026)
  `;
}

async function releaseMigrationLock() {
  await database`
    SELECT pg_advisory_unlock(7102026)
  `;
}

async function readAppliedMigrations() {
  const rows = await database`
    SELECT
      filename,
      checksum
    FROM schema_migrations
    ORDER BY filename
  `;

  return new Map(
    rows.map((row) => [
      row.filename,
      row.checksum,
    ]),
  );
}

async function applyMigration(
  filename,
  contents,
  checksum,
) {
  const migrationSql = removeOuterTransaction(contents);

  await database.begin(async (transaction) => {
    await transaction.unsafe(migrationSql);

    await transaction`
      INSERT INTO schema_migrations (
        filename,
        checksum
      )
      VALUES (
        ${filename},
        ${checksum}
      )
    `;
  });
}

async function main() {
  const filenames = (await readdir(migrationsDirectory))
    .filter((filename) => filename.endsWith(".sql"))
    .sort();

  if (filenames.length === 0) {
    console.log("No migration files were found.");
    return;
  }

  await createMigrationTable();
  await acquireMigrationLock();

  try {
    const appliedMigrations =
      await readAppliedMigrations();

    let appliedCount = 0;

    for (const filename of filenames) {
      const fullPath = path.join(
        migrationsDirectory,
        filename,
      );

      const contents = await readFile(
        fullPath,
        "utf8",
      );

      const checksum = calculateChecksum(contents);
      const appliedChecksum =
        appliedMigrations.get(filename);

      if (appliedChecksum) {
        if (appliedChecksum !== checksum) {
          throw new Error(
            `Migration ${filename} was changed after it was applied.`,
          );
        }

        console.log(`Already applied: ${filename}`);
        continue;
      }

      console.log(`Applying: ${filename}`);

      await applyMigration(
        filename,
        contents,
        checksum,
      );

      appliedCount += 1;
      console.log(`Applied: ${filename}`);
    }

    console.log(
      `Migration complete. ${appliedCount} migration(s) applied.`,
    );
  } finally {
    await releaseMigrationLock();
  }
}

try {
  await main();
} catch (error) {
  console.error("Migration failed.");

  if (error instanceof Error) {
    console.error(error.message);
  }

  process.exitCode = 1;
} finally {
  await database.end({
    timeout: 5,
  });
}
```

Make the script executable:

```bash
chmod +x scripts/migrate.mjs
```

Update the relevant `package.json` scripts.

### `package.json` — updated scripts

```json
{
  "scripts": {
    "dev": "next dev --turbopack",
    "build": "next build",
    "start": "next start",
    "lint": "eslint",
    "typecheck": "tsc --noEmit",
    "analyze": "ANALYZE=true next build",
    "db:start": "docker compose up --detach db",
    "db:stop": "docker compose stop db",
    "db:status": "docker compose ps",
    "db:migrate": "node scripts/migrate.mjs",
    "db:seed": "docker compose exec -T db psql --username=launchpad --dbname=launchpad --set=ON_ERROR_STOP=1 < database/seeds/development.sql",
    "db:shell": "docker compose exec db psql --username=launchpad --dbname=launchpad",
    "db:reset": "docker compose down --volumes && docker compose up --detach db"
  }
}
```

Keep all dependencies and other `package.json` fields unchanged.

### Reset the local development database once

The current local database received migrations before migration tracking existed. Recreate only the disposable development database:

```bash
npm run db:reset
```

Wait until it is healthy:

```bash
npm run db:status
```

Apply tracked migrations:

```bash
npm run db:migrate
```

Seed development data:

```bash
npm run db:seed
```

## The Verification

Inspect migration history:

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

Expected rows:

```text
001_create_projects_and_tasks.sql
002_add_users_sessions_and_ownership.sql
```

Run migrations again:

```bash
npm run db:migrate
```

Expected output includes:

```text
Already applied: 001_create_projects_and_tasks.sql
Already applied: 002_add_users_sessions_and_ownership.sql
Migration complete. 0 migration(s) applied.
```

Confirm the seed:

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      (SELECT COUNT(*) FROM users) AS users,
      (SELECT COUNT(*) FROM projects) AS projects,
      (SELECT COUNT(*) FROM tasks) AS tasks;
  "
```

Expected output:

```text
1 | 4 | 12
```

[GENERATED: Part 10, Step 3: Tracked Database Migrations] [STARTING: Part 10, Step 4: Structured Server Logging]

---

# Step 4: Add Structured Server Logging

## The Target

Create a JSON logger with log levels, safe error serialization, request identifiers, and sensitive-field redaction.

## The Concept

Plain text such as:

```text
Something failed
```

is difficult to search across many production instances.

Structured logging emits machine-readable records:

```json
{
  "timestamp": "2026-07-26T12:00:00.000Z",
  "level": "error",
  "event": "health_check_failed",
  "version": "abc123",
  "error": {
    "name": "Error",
    "message": "Connection failed"
  }
}
```

Logs must not contain:

- Passwords
- Raw session cookies
- Session tokens
- Database connection strings
- Authorization headers

## The Implementation

Create the logger.

### `src/lib/logger.ts`

```ts
import "server-only";

import { randomUUID } from "node:crypto";

import { serverEnvironment } from "@/lib/environment";

type LogLevel =
  | "debug"
  | "info"
  | "warn"
  | "error";

type LogContext = Record<string, unknown>;

const logLevelPriorities: Record<LogLevel, number> = {
  debug: 10,
  info: 20,
  warn: 30,
  error: 40,
};

const sensitiveKeyPattern =
  /password|secret|token|cookie|authorization|database_url/i;

function redactValue(
  key: string,
  value: unknown,
): unknown {
  if (sensitiveKeyPattern.test(key)) {
    return "[REDACTED]";
  }

  if (Array.isArray(value)) {
    return value.map((item) =>
      sanitizeContextValue("item", item),
    );
  }

  if (
    value !== null &&
    typeof value === "object"
  ) {
    return sanitizeContext(
      value as Record<string, unknown>,
    );
  }

  return value;
}

function sanitizeContextValue(
  key: string,
  value: unknown,
): unknown {
  if (value instanceof Error) {
    return serializeError(value);
  }

  return redactValue(key, value);
}

function sanitizeContext(
  context: LogContext,
): LogContext {
  return Object.fromEntries(
    Object.entries(context).map(([key, value]) => [
      key,
      sanitizeContextValue(key, value),
    ]),
  );
}

function serializeError(error: Error) {
  return {
    name: error.name,
    message: error.message,

    /**
     * Stack traces are useful in nonproduction environments. Production
     * monitoring should retain stack data through a restricted backend rather
     * than exposing it in user responses.
     */
    ...(serverEnvironment.nodeEnvironment === "production"
      ? {}
      : { stack: error.stack }),
  };
}

function shouldLog(level: LogLevel): boolean {
  return (
    logLevelPriorities[level] >=
    logLevelPriorities[serverEnvironment.logLevel]
  );
}

function writeLog(
  level: LogLevel,
  event: string,
  context: LogContext = {},
): void {
  if (!shouldLog(level)) {
    return;
  }

  const record = {
    timestamp: new Date().toISOString(),
    level,
    event,
    version: serverEnvironment.appVersion,
    environment: serverEnvironment.nodeEnvironment,
    ...sanitizeContext(context),
  };

  const serializedRecord = JSON.stringify(record);

  if (level === "error") {
    console.error(serializedRecord);
    return;
  }

  if (level === "warn") {
    console.warn(serializedRecord);
    return;
  }

  console.log(serializedRecord);
}

export function createRequestId(
  request: Request,
): string {
  return (
    request.headers.get("x-request-id") ??
    randomUUID()
  );
}

export function logDebug(
  event: string,
  context?: LogContext,
): void {
  writeLog("debug", event, context);
}

export function logInfo(
  event: string,
  context?: LogContext,
): void {
  writeLog("info", event, context);
}

export function logWarn(
  event: string,
  context?: LogContext,
): void {
  writeLog("warn", event, context);
}

export function logError(
  event: string,
  error: unknown,
  context: LogContext = {},
): void {
  writeLog("error", event, {
    ...context,
    error:
      error instanceof Error
        ? serializeError(error)
        : String(error),
  });
}
```

Update the health endpoint to use structured logging.

### `src/app/api/health/route.ts`

```ts
import {
  apiError,
  apiSuccess,
  PUBLIC_NO_STORE_HEADERS,
} from "@/lib/api-response";
import { checkDatabaseHealth } from "@/lib/database/health";
import { serverEnvironment } from "@/lib/environment";
import {
  createRequestId,
  logError,
} from "@/lib/logger";

export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  const checkedAt = new Date().toISOString();
  const requestId = createRequestId(request);

  try {
    await checkDatabaseHealth();

    return apiSuccess(
      {
        status: "ok",
        database: "reachable",
        checkedAt,
        version: serverEnvironment.appVersion,
      },
      {
        headers: {
          ...PUBLIC_NO_STORE_HEADERS,
          "X-Request-Id": requestId,
        },
      },
    );
  } catch (error) {
    logError(
      "readiness_check_failed",
      error,
      {
        requestId,
      },
    );

    return apiError(
      503,
      "SERVICE_UNAVAILABLE",
      "A required application service is unavailable.",
      {
        status: "degraded",
        checkedAt,
        version: serverEnvironment.appVersion,
      },
      {
        ...PUBLIC_NO_STORE_HEADERS,
        "X-Request-Id": requestId,
      },
    );
  }
}
```

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

Start the development server and stop PostgreSQL:

```bash
npm run dev
```

In another terminal:

```bash
npm run db:stop
curl --silent http://localhost:3000/api/health
```

The development terminal should print one JSON log record resembling:

```json
{
  "level": "error",
  "event": "readiness_check_failed",
  "requestId": "...",
  "version": "development"
}
```

It must not contain `DATABASE_URL` or a password.

Restart PostgreSQL:

```bash
npm run db:start
```

[GENERATED: Part 10, Step 4: Structured Server Logging] [STARTING: Part 10, Step 5: Liveness and Readiness Checks]

---

# Step 5: Separate Liveness and Readiness

## The Target

Create a lightweight liveness endpoint while retaining dependency-aware readiness checking.

## The Concept

Liveness and readiness answer different questions.

### Liveness

> Is the application process running and capable of answering HTTP requests?

A liveness endpoint should not depend on PostgreSQL. Otherwise, a temporary database outage could cause an orchestrator to repeatedly restart healthy application processes.

### Readiness

> Can this application instance currently serve dependency-backed traffic?

Readiness should verify PostgreSQL because most LaunchPad operations require it.

We will use:

```text
/api/live   → process liveness
/api/health → application readiness
```

## The Implementation

Create the liveness route:

```bash
mkdir -p src/app/api/live
```

### `src/app/api/live/route.ts`

```ts
import {
  apiSuccess,
  PUBLIC_NO_STORE_HEADERS,
} from "@/lib/api-response";
import { serverEnvironment } from "@/lib/environment";
import { createRequestId } from "@/lib/logger";

export const dynamic = "force-dynamic";

export async function GET(request: Request) {
  const requestId = createRequestId(request);

  return apiSuccess(
    {
      status: "alive",
      checkedAt: new Date().toISOString(),
      version: serverEnvironment.appVersion,
    },
    {
      headers: {
        ...PUBLIC_NO_STORE_HEADERS,
        "X-Request-Id": requestId,
      },
    },
  );
}
```

## The Verification

With PostgreSQL running:

```bash
curl --silent \
  --write-out "\nStatus: %{http_code}\n" \
  http://localhost:3000/api/live

curl --silent \
  --write-out "\nStatus: %{http_code}\n" \
  http://localhost:3000/api/health
```

Both should return:

```text
200
```

Stop PostgreSQL:

```bash
npm run db:stop
```

Test both endpoints:

```bash
curl --silent \
  --output /dev/null \
  --write-out "Liveness: %{http_code}\n" \
  http://localhost:3000/api/live

curl --silent \
  --output /dev/null \
  --write-out "Readiness: %{http_code}\n" \
  http://localhost:3000/api/health
```

Expected output:

```text
Liveness: 200
Readiness: 503
```

Restart PostgreSQL:

```bash
npm run db:start
```

[GENERATED: Part 10, Step 5: Liveness and Readiness] [STARTING: Part 10, Step 6: Security Headers]

---

# Step 6: Add Production Security Headers

## The Target

Configure application-wide headers that reduce common browser attack surfaces.

## The Concept

Security headers give browsers restrictions and behavioral instructions.

We will configure:

- `Content-Security-Policy`
- `Referrer-Policy`
- `X-Content-Type-Options`
- `X-Frame-Options`
- `Permissions-Policy`
- `Strict-Transport-Security`
- `Cross-Origin-Opener-Policy`

A Content Security Policy, or CSP, limits where resources may load from.

LaunchPad’s policy permits inline scripts because Next.js currently emits inline framework scripts. A stronger nonce-based CSP can remove that allowance, but it requires request-specific nonce propagation and should be implemented and tested as a dedicated security change.

## The Implementation

Completely replace the Next.js configuration.

### `next.config.ts`

```ts
import bundleAnalyzer from "@next/bundle-analyzer";
import type { NextConfig } from "next";

const withBundleAnalyzer = bundleAnalyzer({
  enabled: process.env.ANALYZE === "true",
});

const isProduction =
  process.env.NODE_ENV === "production";

const contentSecurityPolicy = [
  "default-src 'self'",
  "base-uri 'self'",
  "object-src 'none'",
  "frame-ancestors 'none'",
  "form-action 'self'",
  "img-src 'self' data: blob:",
  "font-src 'self'",
  "style-src 'self' 'unsafe-inline'",
  "script-src 'self' 'unsafe-inline'",
  "connect-src 'self'",
  "worker-src 'self' blob:",
  ...(isProduction
    ? ["upgrade-insecure-requests"]
    : []),
].join("; ");

const securityHeaders = [
  {
    key: "Content-Security-Policy",
    value: contentSecurityPolicy,
  },
  {
    key: "Referrer-Policy",
    value: "strict-origin-when-cross-origin",
  },
  {
    key: "X-Content-Type-Options",
    value: "nosniff",
  },
  {
    key: "X-Frame-Options",
    value: "DENY",
  },
  {
    key: "Permissions-Policy",
    value:
      "camera=(), microphone=(), geolocation=(), payment=(), usb=()",
  },
  {
    key: "Cross-Origin-Opener-Policy",
    value: "same-origin",
  },
  ...(isProduction
    ? [
        {
          key: "Strict-Transport-Security",
          value:
            "max-age=63072000; includeSubDomains; preload",
        },
      ]
    : []),
];

const nextConfig: NextConfig = {
  poweredByHeader: false,
  compress: true,

  /**
   * The standalone output contains the minimal server files required by the
   * production Docker image.
   */
  output: "standalone",

  images: {
    formats: [
      "image/avif",
      "image/webp",
    ],
    deviceSizes: [
      640,
      750,
      828,
      1080,
      1200,
      1600,
    ],
  },

  async headers() {
    return [
      {
        source: "/:path*",
        headers: securityHeaders,
      },
    ];
  },
};

export default withBundleAnalyzer(nextConfig);
```

## The Verification

Run:

```bash
npm run build
npm run start
```

Inspect headers:

```bash
curl --silent \
  --dump-header - \
  --output /dev/null \
  http://localhost:3000
```

Expected headers include:

```text
content-security-policy
referrer-policy
x-content-type-options: nosniff
x-frame-options: DENY
permissions-policy
cross-origin-opener-policy: same-origin
```

Confirm the framework header is absent:

```bash
curl --silent \
  --dump-header - \
  --output /dev/null \
  http://localhost:3000 |
  grep -i "x-powered-by" || true
```

Expected result:

```text
No match
```

Open the application and inspect the browser console. There should be no CSP errors preventing required scripts, styles, images, or fonts from loading.

Stop the production server:

```text
Ctrl+C
```

[GENERATED: Part 10, Step 6: Security Headers] [STARTING: Part 10, Step 7: Production Docker Image]

---

# Step 7: Build a Multi-Stage Production Container

## The Target

Create a small, non-root Docker image using Next.js standalone output.

## The Concept

A multi-stage Docker build separates responsibilities:

```text
Dependencies stage
    ↓
Build stage
    ↓
Runtime stage
```

The final runtime image does not need:

- Source-control metadata
- Development dependencies
- TypeScript source
- Build caches
- The full `node_modules` tree

The application will also run as an unprivileged user. If an attacker exploits the process, they should not automatically receive root privileges inside the container.

## The Implementation

Create the Docker ignore file.

### `.dockerignore`

```dockerignore
.git
.github
.next
node_modules
npm-debug.log*
.env
.env.*
!.env.example
coverage
dist
tmp
.DS_Store
```

Create the Dockerfile.

### `Dockerfile`

```dockerfile
# syntax=docker/dockerfile:1

FROM node:22-bookworm-slim AS dependencies

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm ci


FROM node:22-bookworm-slim AS builder

WORKDIR /app

ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build-time placeholders satisfy environment validation. Dynamic private
# routes do not query this database during the build.
ENV APP_URL=https://build.invalid
ENV DATABASE_URL=postgresql://build:build@127.0.0.1:5432/build
ENV DATABASE_SSL=false
ENV LOG_LEVEL=info
ENV APP_VERSION=container-build

COPY --from=dependencies /app/node_modules ./node_modules
COPY . .

RUN npm run build


FROM node:22-bookworm-slim AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
ENV PORT=3000
ENV HOSTNAME=0.0.0.0

RUN groupadd \
      --system \
      --gid 1001 \
      nodejs \
  && useradd \
      --system \
      --uid 1001 \
      --gid nodejs \
      nextjs

COPY --from=builder \
  --chown=nextjs:nodejs \
  /app/public \
  ./public

COPY --from=builder \
  --chown=nextjs:nodejs \
  /app/.next/standalone \
  ./

COPY --from=builder \
  --chown=nextjs:nodejs \
  /app/.next/static \
  ./.next/static

USER nextjs

EXPOSE 3000

HEALTHCHECK \
  --interval=30s \
  --timeout=5s \
  --start-period=20s \
  --retries=3 \
  CMD ["node", "-e", "fetch('http://127.0.0.1:3000/api/live').then((response) => { if (!response.ok) process.exit(1); }).catch(() => process.exit(1));"]

CMD ["node", "server.js"]
```

### Build the image

Run:

```bash
docker build \
  --tag launchpad:part-10 \
  .
```

Inspect the image:

```bash
docker image ls launchpad:part-10
```

## The Verification

The container needs to reach PostgreSQL running on the host.

On Docker Desktop, use:

```bash
docker run \
  --rm \
  --name launchpad-production \
  --publish 3000:3000 \
  --env APP_URL=https://localhost:3000 \
  --env DATABASE_URL=postgresql://launchpad:launchpad-development-password@host.docker.internal:5432/launchpad \
  --env DATABASE_SSL=false \
  --env LOG_LEVEL=info \
  --env APP_VERSION=part-10-local \
  launchpad:part-10
```

On Linux, add:

```text
--add-host=host.docker.internal:host-gateway
```

Complete Linux command:

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
  --env APP_VERSION=part-10-local \
  launchpad:part-10
```

In another terminal:

```bash
curl --fail --silent \
  http://localhost:3000/api/live |
  python -m json.tool

curl --fail --silent \
  http://localhost:3000/api/health |
  python -m json.tool
```

Stop the container with:

```text
Ctrl+C
```

Inspect its configured user:

```bash
docker run \
  --rm \
  --entrypoint id \
  launchpad:part-10
```

Expected output should identify UID `1001`, not root.

[GENERATED: Part 10, Step 7: Production Docker Image] [STARTING: Part 10, Step 8: Automated Smoke Tests]

---

# Step 8: Create Automated Production Smoke Tests

## The Target

Create a small test program that verifies critical public routes, health behavior, private API rejection, and protected-route redirects.

## The Concept

A smoke test answers:

> Is the most important functionality alive after deployment?

The name comes from hardware testing: power on the system and check whether smoke appears before performing deeper tests.

Smoke tests are not a replacement for unit, integration, accessibility, or browser tests. They provide a fast deployment gate.

## The Implementation

Create the test script.

### `scripts/smoke-test.mjs`

```js
#!/usr/bin/env node

import process from "node:process";

const baseUrl =
  process.env.BASE_URL ??
  "http://localhost:3000";

const publicRoutes = [
  "/",
  "/about",
  "/features",
  "/sign-in",
  "/sign-up",
  "/api/live",
  "/api/health",
];

async function expectStatus(
  path,
  expectedStatus,
  options = {},
) {
  const response = await fetch(
    new URL(path, baseUrl),
    {
      redirect: "manual",
      ...options,
    },
  );

  if (response.status !== expectedStatus) {
    const responseBody = await response.text();

    throw new Error(
      `${path} returned ${response.status}; ` +
        `expected ${expectedStatus}. ` +
        `Body: ${responseBody.slice(0, 300)}`,
    );
  }

  console.log(
    `PASS ${path} returned ${expectedStatus}`,
  );

  return response;
}

async function main() {
  console.log(`Smoke testing ${baseUrl}`);

  for (const route of publicRoutes) {
    await expectStatus(route, 200);
  }

  const privateApiResponse = await expectStatus(
    "/api/projects",
    401,
  );

  const privateApiBody =
    await privateApiResponse.json();

  if (
    privateApiBody?.error?.code !==
    "UNAUTHORIZED"
  ) {
    throw new Error(
      "The private API did not return UNAUTHORIZED.",
    );
  }

  const cacheControl =
    privateApiResponse.headers.get("cache-control");

  if (
    !cacheControl?.includes("private") ||
    !cacheControl.includes("no-store")
  ) {
    throw new Error(
      "The private API is missing its private no-store policy.",
    );
  }

  const protectedPageResponse =
    await expectStatus("/dashboard", 307);

  const location =
    protectedPageResponse.headers.get("location");

  if (
    !location ||
    !location.endsWith("/sign-in")
  ) {
    throw new Error(
      `Dashboard redirected to an unexpected location: ${location}`,
    );
  }

  console.log("All LaunchPad smoke tests passed.");
}

try {
  await main();
} catch (error) {
  console.error("Smoke tests failed.");

  if (error instanceof Error) {
    console.error(error.message);
  }

  process.exitCode = 1;
}
```

Make it executable:

```bash
chmod +x scripts/smoke-test.mjs
```

Add the script to `package.json`:

```json
"smoke": "node scripts/smoke-test.mjs"
```

> If your exact Next.js patch release uses a different redirect status for `redirect()`, update the expected protected-page status after verifying that the destination is still `/sign-in`. Do not weaken the destination check.

## The Verification

Build and start production mode:

```bash
npm run build
npm run start
```

In another terminal:

```bash
npm run smoke
```

Expected final output:

```text
All LaunchPad smoke tests passed.
```

Test against another origin by setting:

```bash
BASE_URL=https://your-preview.example.com \
npm run smoke
```

Stop the local server:

```text
Ctrl+C
```

[GENERATED: Part 10, Step 8: Automated Smoke Tests] [STARTING: Part 10, Step 9: Continuous Integration]

---

# Step 9: Create the Continuous Integration Pipeline

## The Target

Create a GitHub Actions workflow that installs exact dependencies, starts PostgreSQL, applies migrations, checks source, builds the application, and runs smoke tests.

## The Concept

**Continuous integration**, or CI, automatically verifies changes before they are merged or deployed.

The CI environment starts clean. That makes it valuable for detecting assumptions such as:

- A missing committed file
- An untracked migration
- A dependency installed locally but absent from `package.json`
- A build that depends on developer-specific configuration
- A migration that works only on an existing database

## The Implementation

Create the workflow directory:

```bash
mkdir -p .github/workflows
```

Create the workflow.

### `.github/workflows/ci.yml`

```yaml
name: Continuous Integration

on:
  pull_request:
  push:
    branches:
      - main

permissions:
  contents: read

jobs:
  validate:
    name: Validate LaunchPad
    runs-on: ubuntu-latest
    timeout-minutes: 20

    services:
      postgres:
        image: postgres:17-alpine
        env:
          POSTGRES_DB: launchpad
          POSTGRES_USER: launchpad
          POSTGRES_PASSWORD: launchpad-ci-password
        ports:
          - 5432:5432
        options: >-
          --health-cmd
          "pg_isready --username=launchpad --dbname=launchpad"
          --health-interval 5s
          --health-timeout 5s
          --health-retries 10

    env:
      APP_URL: https://ci.launchpad.invalid
      DATABASE_URL: postgresql://launchpad:launchpad-ci-password@127.0.0.1:5432/launchpad
      DATABASE_SSL: "false"
      LOG_LEVEL: info
      APP_VERSION: ${{ github.sha }}
      NEXT_TELEMETRY_DISABLED: "1"

    steps:
      - name: Check out source
        uses: actions/checkout@v4

      - name: Configure Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm

      - name: Install exact dependencies
        run: npm ci

      - name: Apply database migrations
        run: npm run db:migrate

      - name: Verify migration idempotency
        run: npm run db:migrate

      - name: Type-check
        run: npm run typecheck

      - name: Lint
        run: npm run lint

      - name: Build production application
        run: npm run build

      - name: Start production server
        run: |
          npm run start > /tmp/launchpad-server.log 2>&1 &
          echo $! > /tmp/launchpad-server.pid

      - name: Wait for liveness
        run: |
          for attempt in $(seq 1 30); do
            if curl \
              --fail \
              --silent \
              http://127.0.0.1:3000/api/live \
              > /dev/null; then
              echo "LaunchPad is alive."
              exit 0
            fi

            echo "Waiting for LaunchPad (${attempt}/30)..."
            sleep 1
          done

          cat /tmp/launchpad-server.log
          exit 1

      - name: Run smoke tests
        env:
          BASE_URL: http://127.0.0.1:3000
        run: npm run smoke

      - name: Print server log after failure
        if: failure()
        run: cat /tmp/launchpad-server.log || true
```

### Why CI does not run the development seed

The production application must handle a valid empty database.

CI applies migrations but does not require tutorial sample records. This verifies that public routes, authentication pages, health checks, and authorization behavior do not depend on seeded demo data.

## The Verification

Validate YAML indentation visually.

Commit the workflow to a branch and push it to GitHub:

```bash
git add .github/workflows/ci.yml
git commit -m "ci: validate production build and migrations"
git push
```

Open the repository’s **Actions** tab.

Confirm the job successfully completes:

- Dependency installation
- Migration application
- Second no-op migration pass
- Type check
- Lint
- Build
- Liveness wait
- Smoke tests

If you do not use GitHub, translate the same sequence into your CI provider. Preserve the order and clean PostgreSQL environment.

[GENERATED: Part 10, Step 9: Continuous Integration] [STARTING: Part 10, Step 10: Production Runbook]

---

# Step 10: Create the Production Operations Runbook

## The Target

Document deployment, monitoring, rollback, database, and incident procedures in the repository.

## The Concept

A **runbook** is a practical operations guide.

During an incident, engineers should not have to reconstruct ordinary recovery procedures from memory.

A useful runbook answers:

- How is the service checked?
- How are migrations applied?
- Where are logs found?
- What is the rollback procedure?
- How are sessions revoked?
- How is the database restored?
- Which symptoms require immediate escalation?

## The Implementation

Create the documentation directory:

```bash
mkdir -p docs
```

Create the runbook.

### `docs/production-runbook.md`

```markdown
# LaunchPad Production Runbook

## 1. Service Overview

LaunchPad is a Next.js 16 application backed by PostgreSQL.

Critical dependencies:

1. Next.js application runtime
2. PostgreSQL
3. HTTPS ingress or hosting edge
4. Secret and environment configuration
5. Log and error-monitoring platform

## 2. Health Endpoints

### Liveness

```text
GET /api/live
```

Expected status:

```text
200
```

Liveness proves that the application process can answer HTTP requests.

### Readiness

```text
GET /api/health
```

Expected healthy status:

```text
200
```

Expected dependency-failure status:

```text
503
```

Readiness checks PostgreSQL connectivity.

## 3. Required Environment Variables

```text
APP_URL
DATABASE_URL
DATABASE_SSL
LOG_LEVEL
APP_VERSION
```

Production requirements:

- `APP_URL` must use HTTPS.
- `DATABASE_URL` must come from the secret store.
- `DATABASE_SSL` should normally be `true`.
- `LOG_LEVEL` should normally be `info`.
- `APP_VERSION` should identify the deployed commit or release.

Never log or display `DATABASE_URL`.

## 4. Standard Deployment Procedure

1. Confirm CI is green.
2. Confirm the database backup policy is healthy.
3. Review new SQL migrations.
4. Apply migrations with the production `DATABASE_URL`.
5. Deploy the immutable application artifact.
6. Verify `/api/live`.
7. Verify `/api/health`.
8. Run `npm run smoke` against the deployed origin.
9. Verify sign-in over HTTPS.
10. Verify one authenticated project read and write.
11. Monitor errors and latency after release.

## 5. Migration Procedure

Run:

```bash
npm run db:migrate
```

The migration runner:

- Acquires a PostgreSQL advisory lock.
- Verifies checksums for applied migrations.
- Applies pending files in filename order.
- Records each applied filename and checksum.
- Executes each migration transactionally.

Never edit an applied migration. Add a new numbered migration.

## 6. Rollback Procedure

Application rollback:

1. Stop routing new traffic to the faulty release when supported.
2. Redeploy the previously known-good artifact.
3. Verify liveness and readiness.
4. Run smoke tests.
5. Confirm authentication and owner authorization.
6. Monitor error rate.

Database rollback:

- Do not automatically reverse schema migrations.
- Prefer forward-compatible migrations and corrective forward migrations.
- Restore from backup only when data integrity requires it.
- Test restoration in an isolated environment first.

An older application release may not be compatible with a newer schema. Review compatibility before application rollback.

## 7. Database Backup Requirements

Production PostgreSQL must provide:

- Automated backups
- Point-in-time recovery where available
- Encrypted backup storage
- Defined retention period
- Regular restore tests
- Backup failure alerts

A backup is not proven until restoration has been tested.

## 8. Database Outage

Symptoms:

- `/api/live` returns `200`
- `/api/health` returns `503`
- Workspace requests fail
- Structured logs contain `readiness_check_failed`

Response:

1. Check managed PostgreSQL status.
2. Check connection limits.
3. Check network and TLS configuration.
4. Check database storage and CPU.
5. Check recent migrations.
6. Do not restart healthy application instances repeatedly.
7. Restore readiness before returning traffic.

## 9. Authentication Incident

To revoke all sessions:

```sql
DELETE FROM sessions;
```

To revoke one user's sessions:

```sql
DELETE FROM sessions
WHERE user_id = '<user UUID>';
```

After a suspected token leak:

1. Revoke affected sessions.
2. Rotate relevant secrets.
3. Review logs.
4. Investigate the source of exposure.
5. Notify affected users when required.
6. Document the timeline and corrective action.

## 10. Monitoring Signals

Alert on:

- Sustained readiness failures
- Elevated HTTP 500 response rate
- Elevated sign-in failure rate
- Increased database latency
- Database connection exhaustion
- High application memory
- Crash loops
- Migration failure
- Backup failure
- Increased p95 or p99 response latency
- Unexpected authorization failures

## 11. Log Safety

Logs must not contain:

- Passwords
- Raw session cookies
- Session tokens
- Authorization headers
- Database URLs
- Private encryption keys

Use request IDs and deployment versions for correlation.

## 12. Scaling Considerations

When increasing application instances:

- Recalculate total database pool capacity.
- Keep private data uncached by shared public caches.
- Use a distributed sign-in rate limiter.
- Keep session state in PostgreSQL or another shared session store.
- Verify migrations run once through advisory locking.
- Test shutdown and deployment behavior under traffic.

## 13. Security Follow-Up

Before a high-risk public launch, add or verify:

- Distributed sign-in rate limiting
- Email verification
- Password reset and account recovery
- Multi-factor authentication where required
- Dependency and container scanning
- External penetration testing
- CSP tightening with per-request nonces
- Security contact and disclosure policy
- Data-retention and privacy requirements
```

## The Verification

Read the runbook:

```bash
sed -n '1,240p' docs/production-runbook.md
```

Confirm it contains no real production credential or session token:

```bash
grep -E \
  'postgresql://[^<]|launchpad_session=' \
  docs/production-runbook.md || true
```

No real secret should appear.

[GENERATED: Part 10, Step 10: Production Runbook] [STARTING: Part 10, Step 11: Managed PostgreSQL Preparation]

---

# Step 11: Prepare Managed PostgreSQL

## The Target

Provision a production database, configure TLS, apply migrations, and verify backup settings.

## The Concept

The local Docker database is not a production database.

A managed PostgreSQL provider typically supplies:

- Persistent storage
- Automated backups
- TLS
- Monitoring
- Maintenance
- Connection limits
- Optional point-in-time recovery
- High-availability options

The application and migration runner need a production connection string, but that string must remain in a secret manager rather than source control.

## The Implementation

Provision PostgreSQL through your selected provider.

Examples include:

- Neon
- Supabase
- Amazon RDS
- Google Cloud SQL
- Azure Database for PostgreSQL
- Railway PostgreSQL
- Render PostgreSQL
- Crunchy Bridge

Record the provider-supplied connection string only in your password manager or deployment secret store.

Set temporary shell variables for migration from a secure administrative environment:

```bash
export DATABASE_URL='postgresql://production-user:production-password@production-host:5432/production-database'
export DATABASE_SSL='true'
```

Apply migrations:

```bash
npm run db:migrate
```

Verify migration history with the provider’s SQL console:

```sql
SELECT
  filename,
  checksum,
  applied_at
FROM schema_migrations
ORDER BY filename;
```

Verify required tables:

```sql
SELECT
  tablename
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;
```

Expected tables include:

```text
projects
schema_migrations
sessions
tasks
users
```

### Do not run the development seed

The development seed:

- Deletes sessions
- Deletes projects
- Deletes tasks
- Removes non-demo users
- Creates documented demo credentials

It must never run in production.

Do not execute:

```bash
npm run db:seed
```

against production.

## The Verification

Confirm with the provider:

- TLS is enabled.
- Automated backups are enabled.
- Backup retention is configured.
- A restore procedure is documented.
- Connection limits are known.
- Network access is restricted where supported.
- Production uses unique credentials.
- Development credentials are absent.

Remove the shell variable when finished:

```bash
unset DATABASE_URL
unset DATABASE_SSL
```

Shell history can retain commands. Prefer a secure CI secret or secret-manager injection rather than typing credentials directly where possible.

[GENERATED: Part 10, Step 11: Managed PostgreSQL Preparation] [STARTING: Part 10, Step 12: Deploy to Vercel]

---

# Step 12: Deploy LaunchPad to Vercel

## The Target

Deploy the Next.js application over HTTPS with managed environment variables and connect it to production PostgreSQL.

## The Concept

Vercel provides a managed deployment path for Next.js, including:

- HTTPS
- Build infrastructure
- Preview deployments
- Production deployments
- Environment-variable management
- Runtime logs
- Rollbacks
- Edge delivery for static assets

The database remains an independent managed service.

The same application can also be deployed through the Docker image to platforms such as Railway, Fly.io, Google Cloud Run, Azure Container Apps, or Amazon ECS.

## The Implementation

Install or invoke the Vercel CLI:

```bash
npx vercel@latest login
```

Link the project:

```bash
npx vercel@latest link
```

Add production environment variables.

```bash
npx vercel@latest env add APP_URL production
```

Enter:

```text
https://your-production-domain.example.com
```

Add the database URL:

```bash
npx vercel@latest env add DATABASE_URL production
```

Paste the managed PostgreSQL connection string.

Add TLS policy:

```bash
npx vercel@latest env add DATABASE_SSL production
```

Enter:

```text
true
```

Add logging:

```bash
npx vercel@latest env add LOG_LEVEL production
```

Enter:

```text
info
```

Add a deployment version value:

```bash
npx vercel@latest env add APP_VERSION production
```

Enter the current Git commit:

```bash
git rev-parse HEAD
```

Deploy a preview first:

```bash
npx vercel@latest
```

Verify the preview URL’s public routes.

When ready, deploy production:

```bash
npx vercel@latest --prod
```

If using a custom domain, configure it in the Vercel project and update `APP_URL` to the final HTTPS origin.

Redeploy after changing `APP_URL`.

### Important migration order

Use this deployment order:

```text
1. Apply backward-compatible migration
2. Deploy compatible application
3. Verify application
4. Remove obsolete schema only in a later migration
```

Avoid a migration that immediately removes a column still used by the currently running application.

## The Verification

Set the deployed origin:

```bash
export BASE_URL='https://your-production-domain.example.com'
```

Run smoke tests:

```bash
npm run smoke
```

Verify liveness:

```bash
curl --fail --silent \
  "${BASE_URL}/api/live" |
  python -m json.tool
```

Verify readiness:

```bash
curl --fail --silent \
  "${BASE_URL}/api/health" |
  python -m json.tool
```

Verify production security headers:

```bash
curl --silent \
  --dump-header - \
  --output /dev/null \
  "${BASE_URL}"
```

Confirm:

- HTTPS is used.
- HSTS is present.
- CSP is present.
- `X-Powered-By` is absent.
- Public routes return `200`.
- Protected routes redirect to `/sign-in`.
- Private APIs return `401` without a session.

[GENERATED: Part 10, Step 12: Vercel Deployment] [STARTING: Part 10, Step 13: Production Authentication Verification]

---

# Step 13: Verify Production Authentication and Authorization

## The Target

Test account creation, secure cookies, session persistence, project ownership, cross-user isolation, and sign-out on the deployed HTTPS application.

## The Concept

Local production mode cannot fully represent secure-cookie behavior over HTTPS.

The deployed system is where we must confirm:

```text
Secure cookie
HTTP-only cookie
SameSite policy
Database session
Owner-scoped project access
Session revocation
```

Authentication tests must use disposable test accounts—not real user accounts or production customer data.

## The Implementation

Open:

```text
https://your-production-domain.example.com/sign-up
```

Create a disposable account using a controlled test email.

Confirm registration redirects to:

```text
/dashboard
```

In browser developer tools, inspect `launchpad_session`.

It must have:

- `Secure`
- `HttpOnly`
- `SameSite=Lax`
- Path `/`
- An expiration date

Create a disposable project and task.

Record the project UUID.

Sign out.

Create a second disposable test account.

Attempt to open the first account’s project URL:

```text
https://your-production-domain.example.com/projects/<first-project-id>
```

Expected result:

```text
404 not-found interface
```

The second account must not see the first account’s project in:

```text
/projects
```

## The Verification

Confirm the following:

- Refreshing preserves a valid session.
- Signing out removes server access.
- A signed-out private API request returns `401`.
- A non-owner API request returns `404`.
- A non-owner page request returns the not-found interface.
- Creating a project derives ownership from the session.
- No API accepts a client-supplied owner ID.
- Session cookies are never readable through `document.cookie`.

In the browser console:

```js
document.cookie
```

The `launchpad_session` cookie must not appear.

Delete disposable test accounts and records according to your administrative procedure after verification.

[GENERATED: Part 10, Step 13: Production Authentication Verification] [STARTING: Part 10, Step 14: Monitoring and Alerting]

---

# Step 14: Configure Monitoring and Alerting

## The Target

Establish production signals for availability, errors, latency, database health, and authentication abuse.

## The Concept

Monitoring answers:

> What is happening now?

Alerting answers:

> Which condition requires a human response?

Useful monitoring has several dimensions.

### Logs

Individual structured events:

```json
{
  "level": "error",
  "event": "readiness_check_failed"
}
```

### Metrics

Numeric measurements over time:

```text
HTTP 500 rate
p95 response latency
database connection count
memory usage
```

### Traces

The path of one request through several operations.

### Real-user monitoring

Performance experienced by actual visitors.

## The Implementation

Configure your hosting platform or monitoring provider to collect standard output and standard error from the Next.js process.

Create these minimum alerts:

| Signal | Suggested initial alert |
|---|---|
| Readiness | `/api/health` fails for 2–5 minutes |
| HTTP errors | Elevated 5xx rate over 5 minutes |
| Latency | p95 exceeds agreed threshold |
| Database | Connection use approaches provider limit |
| Database | CPU or storage remains elevated |
| Process | Repeated crashes or restarts |
| Deployment | Smoke test fails |
| Backup | Scheduled backup fails |
| Auth | Sharp increase in failed sign-ins |

Configure an external uptime monitor to request:

```text
GET https://your-domain.example.com/api/health
```

Use:

```text
GET /api/live
```

for process liveness and:

```text
GET /api/health
```

for public readiness.

### Add Web Vitals reporting

Create a small Client Component.

### `src/components/web-vitals-reporter.tsx`

```tsx
"use client";

import { useReportWebVitals } from "next/web-vitals";

export function WebVitalsReporter() {
  useReportWebVitals((metric) => {
    /**
     * In production, replace this console event with an approved analytics or
     * observability endpoint. Do not attach user email, project content, or
     * session identifiers to performance metrics.
     */
    if (process.env.NODE_ENV !== "production") {
      console.info(
        JSON.stringify({
          event: "web_vital",
          id: metric.id,
          name: metric.name,
          value: metric.value,
          rating: metric.rating,
        }),
      );
    }
  });

  return null;
}
```

Add it to the root layout.

### `src/app/layout.tsx`

```tsx
import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import type { ReactNode } from "react";

import { WebVitalsReporter } from "@/components/web-vitals-reporter";

import "./globals.css";
import "@/styles/design-tokens.css";
import "@/styles/accessibility.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
  display: "swap",
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "LaunchPad",
    template: "%s | LaunchPad",
  },
  description:
    "A production-ready project and task management application built with Next.js 16.",
};

type RootLayoutProps = Readonly<{
  children: ReactNode;
}>;

export default function RootLayout({
  children,
}: RootLayoutProps) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable}`}
      >
        <a className="skip-link" href="#main-content">
          Skip to main content
        </a>

        {children}

        <WebVitalsReporter />
      </body>
    </html>
  );
}
```

## The Verification

Run locally:

```bash
npm run dev
```

Open browser developer tools and load the home page.

The console should eventually contain development events for metrics such as:

```text
LCP
CLS
INP
FCP
TTFB
```

Production currently suppresses console-based Web Vitals output because production performance data should go to an approved backend.

Verify the external uptime monitor reports the deployment as healthy.

Trigger a controlled readiness failure only in a nonproduction environment and confirm the configured alert is delivered.

[GENERATED: Part 10, Step 14: Monitoring and Alerting] [STARTING: Part 10, Step 15: Scaling and Connection Planning]

---

# Step 15: Plan Scaling and Database Capacity

## The Target

Calculate database connection risk and define safe horizontal-scaling rules.

## The Concept

Horizontal scaling means running several application instances.

The database client currently allows:

```text
10 connections per process
```

If the platform runs 30 application instances:

```text
30 × 10 = 300 possible connections
```

A managed database may allow far fewer.

Serverless systems can create many short-lived runtime instances, making direct connection multiplication especially important.

## The Implementation

Record these production values before launch:

```text
Database maximum connections: __________
Reserved administrative connections: ___
Application connection budget: _________
Maximum application instances: _________
Pool size per instance: ________________
```

Use this formula:

```text
pool size per instance
≤
application connection budget ÷ maximum instances
```

For example:

```text
Database maximum: 100
Reserved: 20
Application budget: 80
Maximum instances: 20

Pool size:
80 ÷ 20 = 4
```

In that environment, update:

```ts
max: 10
```

in `src/lib/database/client.ts` to:

```ts
max: 4
```

A serverless deployment may benefit from a provider-managed connection pooler.

Examples include:

- PgBouncer
- Provider-specific pooled connection endpoints
- Transaction pooling
- Managed database proxies

Do not increase connection limits merely to hide slow queries or leaked connections.

## The Verification

Inspect PostgreSQL connection activity:

```sql
SELECT
  state,
  COUNT(*) AS connection_count
FROM pg_stat_activity
WHERE datname = current_database()
GROUP BY state
ORDER BY state;
```

Inspect the configured maximum:

```sql
SHOW max_connections;
```

Load-test only in a controlled environment. During a test, monitor:

- Application instance count
- Database connection count
- Query latency
- HTTP p95 and p99 latency
- Error rate
- CPU and memory
- Lock waits

Confirm the estimated maximum application connections remain below the provider’s safe budget.

[GENERATED: Part 10, Step 15: Scaling and Connection Planning] [STARTING: Part 10, Step 16: Final Production Quality Gate]

---

# Step 16: Run the Final Production Quality Gate

## The Target

Verify the complete application from source validation through container execution and deployed HTTPS behavior.

## The Concept

The final quality gate combines all previous boundaries:

```text
Source
Database schema
Build
Runtime
Security
Authentication
Authorization
Performance
Operations
Deployment
```

One successful command cannot prove production readiness. The application must pass a collection of independent checks.

## The Implementation

### Local source and database gate

Reset the disposable development database:

```bash
npm run db:reset
```

Wait for PostgreSQL:

```bash
for attempt in $(seq 1 30); do
  if docker compose exec -T db \
    pg_isready \
    --username=launchpad \
    --dbname=launchpad \
    > /dev/null 2>&1; then
    echo "PostgreSQL is ready."
    break
  fi

  echo "Waiting for PostgreSQL (${attempt}/30)..."
  sleep 1
done
```

Apply migrations twice:

```bash
npm run db:migrate
npm run db:migrate
```

Seed development data:

```bash
npm run db:seed
```

Run source checks:

```bash
npm ci
npm run typecheck
npm run lint
npm run build
```

### Local production-server gate

Start production mode:

```bash
npm run start
```

In another terminal:

```bash
npm run smoke
```

Inspect security headers:

```bash
curl --silent \
  --dump-header - \
  --output /dev/null \
  http://localhost:3000
```

Inspect readiness:

```bash
curl --fail --silent \
  http://localhost:3000/api/api/health |
  python -m json.tool
```

Verify liveness:

```bash
curl --fail --silent \
  http://localhost:3000/api/live |
  python -m json.tool
```

Verify anonymous security behavior:

```bash
curl --silent \
  --output /dev/null \
  --write-out "Private API: %{http_code}\n" \
  http://localhost:3000/api/projects

curl --silent \
  --output /dev/null \
  --write-out "Protected page: %{http_code} %{redirect_url}\n" \
  http://localhost:3000/dashboard
```

Expected:

```text
Private API: 401
Protected page: 307 http://localhost:3000/sign-in
```

Stop the local server:

```text
Ctrl+C
```

### Local Docker gate

Build the image:

```bash
docker build \
  --tag launchpad:final \
  .
```

Run it with local PostgreSQL:

```bash
docker run \
  --rm \
  --name launchpad-final \
  --add-host=host.docker.internal:host-gateway \
  --publish 3000:3000 \
  --env APP_URL=https://localhost:3000 \
  --env DATABASE_URL=postgresql://launchpad:launchpad-development-password@host.docker.internal:5432/launchpad \
  --env DATABASE_SSL=false \
  --env LOG_LEVEL=info \
  --env APP_VERSION=final-local \
  launchpad:final
```

> On Docker Desktop for macOS or Windows, the `--add-host` option is typically unnecessary but harmless. On Linux, it enables `host.docker.internal`.

In another terminal, run:

```bash
BASE_URL=http://localhost:3000 \
npm run smoke
```

Stop the container:

```text
Ctrl+C
```

### Deployed HTTPS gate

Set your deployed domain:

```bash
export BASE_URL='https://your-production-domain.example.com'
```

Run:

```bash
npm run smoke
```

Inspect headers:

```bash
curl --silent \
  --dump-header - \
  --output /dev/null \
  "${BASE_URL}"
```

Verify readiness:

```bash
curl --fail --silent \
  "${BASE_URL}/api/health" |
  python -m json.tool
```

## The Verification

The final quality gate passes when all of the following are true:

- Local migrations run successfully on a fresh database.
- Running migrations a second time applies no additional changes.
- The seed creates exactly the expected development records.
- Type checking, linting, and production build all succeed.
- Smoke tests pass against local production mode.
- The Docker image runs as a non-root user.
- Docker liveness and readiness endpoints work.
- Public routes return `200`.
- Anonymous project API requests return `401`.
- Protected pages redirect to `/sign-in`.
- Security headers are present.
- Production smoke tests pass over HTTPS.
- Sign-in, sign-out, and ownership isolation work in the deployed application.
- Monitoring and backup procedures are configured.

[GENERATED: Part 10, Step 16: Final Production Quality Gate] [STARTING: Part 10, Step 17: Production Deployment Checklist]

---

# Step 17: Production Deployment Checklist

## The Target

Create a repeatable pre-deployment and post-deployment checklist.

## The Concept

A deployment checklist prevents avoidable omissions during releases.

It is not bureaucracy for its own sake. It is a short, repeatable memory aid for tasks that matter under pressure.

## The Implementation

Create the checklist.

### `docs/deployment-checklist.md`

```markdown
# LaunchPad Deployment Checklist

## Before Deployment

- [ ] CI is green for the commit being deployed.
- [ ] `npm ci` succeeds from a clean checkout.
- [ ] `npm run typecheck` succeeds.
- [ ] `npm run lint` succeeds.
- [ ] `npm run build` succeeds.
- [ ] The migration runner completes on a staging or preview database.
- [ ] New migrations were reviewed and are backward-compatible.
- [ ] Applied migration files were not edited.
- [ ] Production secrets are configured in the hosting platform.
- [ ] `APP_URL` uses the final HTTPS production domain.
- [ ] `DATABASE_SSL=true` is configured for managed PostgreSQL.
- [ ] `APP_VERSION` identifies the release commit.
- [ ] Database backups and restore procedures are confirmed.
- [ ] Database connection-pool capacity was reviewed.
- [ ] Monitoring and readiness alerts are active.
- [ ] No development seed command will run in production.

## During Deployment

- [ ] Apply migrations once using production secrets.
- [ ] Deploy the immutable application artifact.
- [ ] Confirm the deployment reports a healthy application process.
- [ ] Confirm `/api/live` returns `200`.
- [ ] Confirm `/api/health` returns `200`.
- [ ] Run smoke tests against the deployed HTTPS origin.

## After Deployment

- [ ] Confirm public pages return `200`.
- [ ] Confirm security headers are present.
- [ ] Confirm `X-Powered-By` is absent.
- [ ] Confirm anonymous project API access returns `401`.
- [ ] Confirm protected pages redirect to `/sign-in`.
- [ ] Confirm a test user can sign in over HTTPS.
- [ ] Confirm `launchpad_session` is Secure and HttpOnly.
- [ ] Confirm owner-scoped project access.
- [ ] Confirm sign-out revokes access.
- [ ] Review application logs for errors.
- [ ] Review database metrics and connection count.
- [ ] Confirm external uptime monitoring is healthy.
- [ ] Record deployment time, version, and operator.
```

## The Verification

Read the checklist:

```bash
cat docs/deployment-checklist.md
```

Confirm no credential, session token, or production database URL appears:

```bash
grep -E \
  'postgresql://[^<]|launchpad_session=[A-Za-z0-9]' \
  docs/deployment-checklist.md || true
```

Expected result:

```text
No output
```

[GENERATED: Part 10, Step 17: Deployment Checklist] [STARTING: Part 10, Step 18: Final Git Checkpoint]

---

# Step 18: Create the Final Git Checkpoint

## The Target

Commit the production-readiness layer and verify that the repository contains no secrets.

## The Concept

This commit marks the transition from a locally functional application to one with documented deployment and operational practices.

It should include:

- Runtime environment validation
- Migration tracking
- Structured logging
- Liveness and readiness endpoints
- Security headers
- Docker support
- Smoke tests
- CI workflow
- Production runbook
- Deployment checklist
- Web Vitals reporting

It must not include:

- `.env.local`
- Production database URLs
- Session cookie values
- Any passwords other than the intentionally documented local development credential

## The Implementation

Inspect repository status:

```bash
git status
git diff --stat
git diff
```

Verify ignored secrets:

```bash
git check-ignore .env.local
```

Search tracked files for obvious accidental secrets:

```bash
git grep -nE \
  'DATABASE_URL=postgresql://[^l]|launchpad_session=[A-Za-z0-9_-]{20,}' \
  || true
```

Review all staged changes before committing:

```bash
git add \
  .dockerignore \
  .github \
  Dockerfile \
  docs \
  next.config.ts \
  package.json \
  package-lock.json \
  scripts \
  src \
  .env.example

git diff --cached --stat
git diff --cached
```

Run the final local source gate:

```bash
npm run typecheck
npm run lint
npm run build
```

Create the commit:

```bash
git commit -m "chore: prepare LaunchPad for production deployment"
```

## The Verification

Inspect the commit:

```bash
git log -1 --oneline
```

Expected output resembles:

```text
a7b8c9d chore: prepare LaunchPad for production deployment
```

Confirm the working tree is clean:

```bash
git status
```

Expected output:

```text
nothing to commit, working tree clean
```

[GENERATED: Part 10, Step 18: Final Git Checkpoint] [STARTING: Part 10 Reference Sections]

---

# Part 10 Reference A: Production Environment Variables

LaunchPad requires these server-only values:

| Variable | Purpose | Production expectation |
|---|---|---|
| `APP_URL` | Canonical application origin | HTTPS URL |
| `DATABASE_URL` | PostgreSQL connection string | Secret-store value |
| `DATABASE_SSL` | Enables PostgreSQL TLS | Usually `true` |
| `LOG_LEVEL` | Minimum structured log level | Usually `info` |
| `APP_VERSION` | Release identifier | Commit SHA or release version |

Never prefix these values with:

```text
NEXT_PUBLIC_
```

That prefix makes a value eligible for browser exposure.

A production secret belongs in:

- Vercel environment variables
- GitHub Actions secrets
- A cloud secret manager
- A managed-platform secret store

It does not belong in:

- Git
- Browser local storage
- Client Component props
- Public API responses
- Log context

---

# Part 10 Reference B: Migration Safety

Production migrations should favor compatibility.

A safe phased migration typically looks like this:

```text
Release 1
├── Add nullable column
├── Deploy code that can read old and new shapes
└── Backfill data

Release 2
├── Make column required if appropriate
└── Remove obsolete application reads

Release 3
└── Remove obsolete old column
```

Avoid this risky sequence:

```text
1. Delete a column
2. Discover the currently deployed application still reads it
3. Production requests fail
```

Applied migration files are historical records. Never edit them. Add another numbered file instead:

```text
003_add_project_archived_at.sql
```

The tracked runner intentionally fails if the checksum of an applied migration changes.

---

# Part 10 Reference C: Docker Build Stages

The Dockerfile uses three stages.

## Dependencies stage

```dockerfile
FROM node:22-bookworm-slim AS dependencies
```

Installs exact dependencies using:

```dockerfile
RUN npm ci
```

## Builder stage

```dockerfile
FROM node:22-bookworm-slim AS builder
```

Copies source and generates the optimized Next.js standalone output.

## Runner stage

```dockerfile
FROM node:22-bookworm-slim AS runner
```

Copies only:

- `public`
- `.next/standalone`
- `.next/static`

The runtime stage omits source files and development tooling where possible.

The process runs under:

```dockerfile
USER nextjs
```

rather than root.

---

# Part 10 Reference D: Security Headers

## Content Security Policy

LaunchPad starts with a restrictive same-origin policy:

```text
default-src 'self'
object-src 'none'
frame-ancestors 'none'
```

The policy still allows inline scripts and styles for framework compatibility:

```text
script-src 'self' 'unsafe-inline'
style-src 'self' 'unsafe-inline'
```

A mature production hardening step can replace inline script permission with nonce-based CSP. That requires careful testing because a broken CSP can prevent the application from loading.

## Strict Transport Security

HSTS instructs browsers to prefer HTTPS after receiving the header:

```text
Strict-Transport-Security:
max-age=63072000; includeSubDomains; preload
```

Enable it only after confirming HTTPS works correctly for the production domain and any included subdomains.

## Frame protection

```text
X-Frame-Options: DENY
frame-ancestors 'none'
```

These reduce clickjacking risk by preventing embedding inside another site’s frame.

## Permissions Policy

This disables unused browser capabilities such as:

```text
camera
microphone
geolocation
payment
usb
```

Review and loosen it only when the product genuinely needs a capability.

---

# Part 10 Reference E: Logging Rules

Structured logs should include useful operational context:

```json
{
  "event": "readiness_check_failed",
  "level": "error",
  "requestId": "…",
  "version": "…",
  "environment": "production"
}
```

Useful fields include:

- Event name
- Request identifier
- Deployment version
- Route name
- HTTP status
- Duration
- Safe resource identifiers where justified

Never log:

- Passwords
- Raw cookies
- Session tokens
- Authorization headers
- Full database URLs
- Sensitive project content unless policy explicitly permits it
- Personally identifiable information without a clear retention and access policy

A request ID can be returned in response headers and attached to logs so support staff can correlate a user report with backend events.

---

# Part 10 Reference F: Health Endpoints

LaunchPad provides:

```text
GET /api/live
GET /api/health
```

## `/api/live`

Answers whether the process can return a response.

It should remain lightweight and dependency-independent.

## `/api/health`

Checks PostgreSQL reachability.

It may return:

```text
200
```

when ready, or:

```text
503
```

when a critical dependency fails.

Neither endpoint should reveal:

- Database hostnames
- Passwords
- Stack traces
- Internal topology
- Session information

---

# Part 10 Reference G: CI Pipeline Design

The CI pipeline intentionally runs against a clean PostgreSQL instance.

It verifies:

```text
npm ci
    ↓
migration application
    ↓
migration idempotency
    ↓
type-check
    ↓
lint
    ↓
production build
    ↓
start server
    ↓
liveness
    ↓
smoke tests
```

A clean environment catches missing dependencies and uncommitted assumptions that local environments can hide.

Future CI improvements may include:

- Unit tests
- Browser end-to-end tests
- Accessibility scans
- Dependency vulnerability scanning
- Container image scanning
- SQL migration linting
- Preview-deployment smoke tests
- Load tests in staging

---

# Part 10 Reference H: Backup and Restore

A backup plan is incomplete until restoration has been tested.

Define:

- **RPO:** Recovery Point Objective — acceptable data loss window.
- **RTO:** Recovery Time Objective — acceptable service restoration time.

Example:

```text
RPO: 15 minutes
RTO: 2 hours
```

These are business decisions, not merely technical settings.

A mature restore drill should:

1. Restore a backup into an isolated database.
2. Verify schema migration history.
3. Verify row counts and application integrity.
4. Start a temporary application instance against the restored database.
5. Verify sign-in and owner-scoped queries.
6. Measure restoration time.
7. Record lessons and improve the procedure.

Never discover that backups are unusable during an actual outage.

---

# Part 10 Reference I: Scaling Sessions and Authentication

LaunchPad stores sessions in PostgreSQL, which supports multiple application instances because each instance queries shared session state.

As traffic grows, consider:

- Session lookup index health
- Database connection pool capacity
- Distributed sign-in rate limiting
- Session cleanup scheduling
- Sign-in anomaly monitoring
- Multi-factor authentication
- Password reset flow
- Email verification
- Account lockout policy
- Incident-driven bulk session revocation

Do not use per-process in-memory sessions when deploying multiple instances. A request may reach any instance.

---

# Part 10 Reference J: Deployment Alternatives

The tutorial used Vercel because it is a natural managed deployment target for Next.js.

The standalone Docker build supports other platforms.

## Cloud Run

Typical flow:

```text
Build container
→ push image
→ deploy Cloud Run service
→ configure secrets
→ set minimum and maximum instances
```

## Fly.io

Typical flow:

```text
Build container
→ deploy near the managed database region
→ configure secrets
→ verify health checks
```

## Railway or Render

Typical flow:

```text
Connect repository or container
→ configure managed PostgreSQL
→ configure environment variables
→ deploy
→ run migrations through release job or administrative command
```

## ECS or Kubernetes

Typical flow:

```text
Publish image
→ run migrations as a controlled job
→ deploy application service
→ configure load balancer health checks
→ configure autoscaling and secrets
```

The platform changes, but the requirements do not:

- HTTPS
- Secrets
- migration safety
- health checks
- logs
- monitoring
- backup
- rollback
- least privilege

---

# Part 10 Reference K: Production Limitations and Next Improvements

LaunchPad now has strong foundational production practices, but a real public product should continue improving.

Recommended next work:

1. **Rate limiting**  
   Add distributed sign-in and API abuse controls.

2. **Password recovery**  
   Implement secure reset tokens, expiry, throttling, and email delivery.

3. **Email verification**  
   Verify account ownership before enabling sensitive flows.

4. **Multi-factor authentication**  
   Add MFA if the threat model requires it.

5. **Audit logs**  
   Record security-sensitive mutations and access events.

6. **Automated test coverage**  
   Add unit, integration, and browser tests.

7. **Error-monitoring backend**  
   Send server exceptions to an approved monitoring provider.

8. **Nonce-based CSP**  
   Tighten `script-src` and remove broad inline allowances where compatible.

9. **Rate-aware session cleanup**  
   Schedule deletion of expired sessions.

10. **Database read replicas or pooling**  
    Consider only after measured production demand justifies them.

11. **Content delivery policy**  
    Define cache durations for public content and immutable assets.

12. **Privacy and compliance**  
    Establish retention, deletion, export, and legal requirements appropriate to users and jurisdiction.

---

# Part 10 Reference L: Final Project Structure

The important production-focused files are now:

```text
launchpad/
├── .github/
│   └── workflows/
│       └── ci.yml
├── database/
│   ├── migrations/
│   │   ├── 001_create_projects_and_tasks.sql
│   │   └── 002_add_users_sessions_and_ownership.sql
│   └── seeds/
│       └── development.sql
├── docs/
│   ├── deployment-checklist.md
│   └── production-runbook.md
├── public/
│   └── launchpad-dashboard.png
├── scripts/
│   ├── generate-launchpad-image.py
│   ├── measure-routes.sh
│   ├── migrate.mjs
│   └── smoke-test.mjs
├── src/
│   ├── app/
│   │   └── api/
│   │       ├── health/
│   │       │   └── route.ts
│   │       └── live/
│   │           └── route.ts
│   ├── components/
│   │   └── web-vitals-reporter.tsx
│   ├── lib/
│   │   ├── database/
│   │   │   └── client.ts
│   │   ├── environment.ts
│   │   └── logger.ts
│   └── ...
├── .dockerignore
├── .env.example
├── compose.yaml
├── Dockerfile
├── next.config.ts
├── package.json
└── package-lock.json
```

---

# Part 10 Completion Checklist

Before declaring LaunchPad ready for deployment, confirm every item:

- [ ] Environment variables are validated during startup.
- [ ] Production `APP_URL` requires HTTPS.
- [ ] PostgreSQL TLS is configurable and enabled in production.
- [ ] `.env.local` remains ignored by Git.
- [ ] Migration history is stored in `schema_migrations`.
- [ ] Applied migration files are checksum-verified.
- [ ] Migration execution uses an advisory lock.
- [ ] Migrations are idempotent when rerun.
- [ ] Development seeds are never run against production.
- [ ] Structured logs include safe event metadata.
- [ ] Logs redact passwords, tokens, cookies, and database URLs.
- [ ] `/api/live` remains available when PostgreSQL is unavailable.
- [ ] `/api/health` returns `503` when PostgreSQL is unavailable.
- [ ] Health responses are not cached.
- [ ] Security headers are present in production.
- [ ] `X-Powered-By` is absent.
- [ ] The app uses standalone output.
- [ ] The Docker image runs as a non-root user.
- [ ] Docker health checks use `/api/live`.
- [ ] Smoke tests pass against production mode.
- [ ] CI uses `npm ci`.
- [ ] CI starts clean PostgreSQL.
- [ ] CI applies migrations and checks idempotency.
- [ ] CI runs type-checking, linting, build, and smoke tests.
- [ ] The runbook documents incidents, rollback, and recovery.
- [ ] The deployment checklist is complete.
- [ ] Production PostgreSQL has backups and tested restoration.
- [ ] Production PostgreSQL uses unique credentials and TLS.
- [ ] Production database connection capacity is calculated.
- [ ] Production uses HTTPS.
- [ ] Production session cookies are Secure and HttpOnly.
- [ ] Production authentication and cross-user isolation are verified.
- [ ] External uptime monitoring checks readiness.
- [ ] Alerts exist for readiness, 5xx errors, latency, backups, and database pressure.
- [ ] Web Vitals reporting is ready for an approved observability backend.
- [ ] `npm run typecheck` succeeds.
- [ ] `npm run lint` succeeds.
- [ ] `npm run build` succeeds.
- [ ] `npm run smoke` succeeds.
- [ ] Git contains the final production-readiness checkpoint.
- [ ] `git status` reports a clean working tree.

---

# Series Completion: From Zero to Production with Next.js 16

You have built LaunchPad from a single Next.js page into a production-oriented full-stack application.

The final architecture includes:

```text
Next.js 16 App Router
├── File-based routing
├── Nested layouts and route groups
├── Server Components by default
├── Focused Client Components
├── Streaming and loading boundaries
├── Error boundaries
├── Optimized fonts and images
├── CSS Modules and design tokens
├── PostgreSQL persistence
├── Validated environment configuration
├── Parameterized SQL
├── Server Actions
├── JSON Route Handlers
├── Authentication and database sessions
├── Owner-scoped authorization
├── Private API cache policy
├── Security headers
├── Health checks
├── Structured logging
├── Docker deployment artifact
├── CI validation
└── Production operations documentation
```

The durable lesson is not a list of framework APIs. It is the habit of placing each responsibility at the correct boundary:

- **Browser:** interaction and temporary UI state
- **URL:** shareable navigation state
- **Server Components:** trusted rendering and data access
- **Server Actions and Route Handlers:** validated mutations
- **Database:** persistence, integrity, and ownership constraints
- **Infrastructure:** HTTPS, secrets, backups, monitoring, and scaling
- **CI and runbooks:** repeatability and operational safety
