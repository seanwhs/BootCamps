# Appendix O: Dependency and Configuration Reference

This appendix explains the major packages, configuration files, and runtime tools used by LaunchPad.

Use it when you need to answer:

- Why is this package installed?
- Is this dependency server-only or browser-safe?
- Which dependencies are required in production?
- What does this configuration file control?
- Which package should I update carefully?

---

# O.1 Core Runtime Dependencies

Inspect installed dependencies with:

```bash
npm ls --depth=0
```

LaunchPad’s important runtime dependencies include the following.

| Package | Purpose | Browser-safe? |
|---|---|---|
| `next` | Framework, routing, rendering, build tooling | Framework-managed |
| `react` | Component rendering model | Yes |
| `react-dom` | Browser and server React rendering | Yes |
| `postgres` | PostgreSQL driver and query client | No — server-only |
| `zod` | Runtime validation schemas | Yes, when schemas contain no server imports |
| `bcryptjs` | Password hashing and comparison | No — server-only |
| `server-only` | Build-time guard for server modules | No — server-only |

---

## `next`

Next.js provides:

```text
- App Router
- Server Components
- Route Handlers
- Server Actions
- next/image
- next/font
- Metadata
- Production builds
- Static optimization
- Streaming
```

Useful version inspection:

```bash
npm ls next
```

Start development mode:

```bash
npm run dev
```

Create production output:

```bash
npm run build
```

Run production output:

```bash
npm run start
```

---

## `react` and `react-dom`

React provides:

```text
- Components
- JSX
- State hooks
- Suspense
- Client-side hydration
```

LaunchPad uses React hooks only inside Client Components.

Example:

```tsx
"use client";

import { useState } from "react";

export function Example() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <button
      type="button"
      onClick={() => {
        setIsOpen((currentValue) => !currentValue);
      }}
    >
      {isOpen ? "Close" : "Open"}
    </button>
  );
}
```

---

## `postgres`

The `postgres` package is LaunchPad’s PostgreSQL driver.

Example:

```ts
import postgres from "postgres";

const database = postgres(databaseUrl);

const rows = await database`
  SELECT
    id,
    name
  FROM projects
  WHERE owner_id = ${userId}
`;
```

It must remain server-only.

Correct module shape:

```ts
import "server-only";

import postgres from "postgres";
```

Never import it from a Client Component.

---

## `zod`

Zod validates values at runtime.

Example:

```ts
import { z } from "zod";

const projectSchema = z.object({
  name: z.string().trim().min(1).max(120),
  description: z.string().trim().min(1).max(2_000),
});
```

Use it for:

```text
- FormData
- JSON APIs
- Search parameters
- Dynamic route IDs
- Environment variables
- Database result shapes
```

Zod schemas can be browser-safe when they do not import server-only code.

---

## `bcryptjs`

LaunchPad uses `bcryptjs` to hash and verify passwords.

```ts
import { compare, hash } from "bcryptjs";

const passwordHash = await hash(password, 12);

const matches = await compare(
  submittedPassword,
  passwordHash,
);
```

It must remain server-only because password processing belongs on the server.

Do not:

```text
- Hash passwords in a Client Component
- Send a password hash to the browser
- Store passwords in localStorage
- Log submitted passwords
```

---

## `server-only`

The `server-only` package prevents protected modules from entering a Client Component graph.

Example:

```ts
import "server-only";

import { database } from "@/lib/database/client";
```

Use it in modules containing:

```text
- PostgreSQL access
- Session access
- Password handling
- Private environment variables
- Node.js crypto
- Authorization queries
```

---

# O.2 Development Dependencies

LaunchPad also uses development-only tooling.

| Package | Purpose |
|---|---|
| `typescript` | Static type checking |
| `eslint` | Source-quality checks |
| `@next/bundle-analyzer` | Optional client/server bundle visualization |
| Type definitions packages | TypeScript support for libraries |

Inspect dev dependencies:

```bash
npm ls --depth=0 --include=dev
```

---

## `@next/bundle-analyzer`

LaunchPad enables bundle analysis when:

```bash
npm run analyze
```

The script sets:

```text
ANALYZE=true
```

and runs a production build.

Review the browser report for accidental inclusion of:

```text
postgres
bcryptjs
database query modules
session modules
environment modules
```

Those packages should remain outside browser bundles.

---

# O.3 Important Configuration Files

## `package.json`

`package.json` describes the project.

It contains:

```text
- Project name
- npm scripts
- Dependencies
- Development dependencies
- Package metadata
```

Important scripts include:

```json
{
  "scripts": {
    "dev": "next dev --turbopack",
    "build": "next build",
    "start": "next start",
    "lint": "eslint",
    "typecheck": "tsc --noEmit",
    "analyze": "ANALYZE=true next build",
    "db:migrate": "node scripts/migrate.mjs",
    "db:seed": "docker compose exec -T db psql --username=launchpad --dbname=launchpad --set=ON_ERROR_STOP=1 < database/seeds/development.sql",
    "smoke": "node scripts/smoke-test.mjs"
  }
}
```

Use:

```bash
npm run
```

to list scripts available in the current project.

---

## `package-lock.json`

The lock file records the exact dependency tree.

Use:

```bash
npm ci
```

in CI and clean environments.

`npm ci` ensures installed versions match `package-lock.json`.

Do not manually edit the lock file.

---

## `tsconfig.json`

TypeScript configuration controls:

```text
- Strictness
- Module behavior
- JSX behavior
- Import aliases
- Included files
```

LaunchPad uses the alias:

```text
@/*
```

Example:

```tsx
import { ProjectCard } from "@/components/project-card";
```

This refers to:

```text
src/components/project-card
```

rather than requiring fragile long relative imports.

---

## `next.config.ts`

LaunchPad’s Next.js configuration controls:

```text
- Standalone output
- Security headers
- Compression
- Image formats and sizes
- Bundle analyzer activation
- Powered-by header removal
```

Important configuration excerpt:

```ts
const nextConfig: NextConfig = {
  poweredByHeader: false,
  compress: true,
  output: "standalone",
};
```

After changing `next.config.ts`, restart development mode or run a fresh production build.

---

## `eslint.config.mjs`

This configures ESLint.

Run:

```bash
npm run lint
```

ESLint catches issues such as:

```text
- Unused variables
- Invalid React patterns
- Unsafe or inconsistent code style
- Framework-specific mistakes
```

Linting is not a replacement for TypeScript, testing, or security review.

---

## `.env.example`

This file documents required configuration safely.

It may include local example values:

```dotenv
APP_URL=http://localhost:3000
DATABASE_SSL=false
LOG_LEVEL=info
APP_VERSION=development
```

It must not contain:

```text
- Production passwords
- Production database URLs
- API tokens
- Session tokens
- Email-provider credentials
```

---

## `.env.local`

This file stores local private configuration.

Example:

```dotenv
APP_URL=http://localhost:3000
DATABASE_URL=postgresql://launchpad:launchpad-development-password@localhost:5432/launchpad
DATABASE_SSL=false
LOG_LEVEL=debug
APP_VERSION=development
```

It must be ignored by Git:

```bash
git check-ignore .env.local
```

Expected output:

```text
.env.local
```

---

## `compose.yaml`

This defines local PostgreSQL development infrastructure.

It controls:

```text
- PostgreSQL image
- Database name
- Local username
- Local password
- Port mapping
- Persistent Docker volume
- Health check
```

LaunchPad commands:

```bash
npm run db:start
npm run db:status
npm run db:stop
```

This configuration is for local development, not production.

---

## `Dockerfile`

The Dockerfile creates a production container.

Its stages are:

```text
dependencies
    ↓
builder
    ↓
runner
```

The final container:

```text
- Uses standalone Next.js output
- Runs as non-root user
- Exposes port 3000
- Has a liveness health check
- Requires runtime environment variables
```

Build it:

```bash
docker build \
  --tag launchpad:latest \
  .
```

---

# O.4 Package Installation Rules

## Add a production dependency

Use:

```bash
npm install package-name
```

Example:

```bash
npm install zod
```

This updates:

```text
package.json
package-lock.json
```

---

## Add a development-only dependency

Use:

```bash
npm install --save-dev package-name
```

Example:

```bash
npm install --save-dev @next/bundle-analyzer
```

---

## Remove a package

Use:

```bash
npm uninstall package-name
```

Then verify:

```bash
npm run typecheck
npm run lint
npm run build
```

A package may be imported indirectly from several files. Do not remove it only because it appears unused in one location.

---

# O.5 Dependency Review Checklist

Before adding a package, ask:

- [ ] Does the framework already provide this capability?
- [ ] Is the package actively maintained?
- [ ] Does it support Next.js App Router and Server Components?
- [ ] Does it require browser JavaScript?
- [ ] Does it increase the initial client bundle?
- [ ] Does it handle secrets or user data?
- [ ] Does it have a clear license?
- [ ] Does it have known security issues?
- [ ] Can it be replaced with a small standard-library solution?
- [ ] Is the feature valuable enough to justify the dependency?

Examples:

| Need | First choice |
|---|---|
| Form validation | Zod |
| Database access | Existing `postgres` driver |
| Routing | Next.js App Router |
| Image optimization | `next/image` |
| Font optimization | `next/font` |
| Dynamic import | `next/dynamic` |
| Client state | Local React state before global state library |
| UUID validation | Zod `z.string().uuid()` |
| Password hashing | bcrypt or maintained equivalent |
| Secure random bytes | Node.js `crypto` |

---

# O.6 Dependency Security Commands

Inspect direct dependencies:

```bash
npm ls --depth=0
```

Check outdated packages:

```bash
npm outdated
```

Inspect package metadata:

```bash
npm view package-name
```

Check npm’s advisory database:

```bash
npm audit
```

Attempt automatic fixes cautiously:

```bash
npm audit fix
```

Do not run:

```bash
npm audit fix --force
```

without reviewing the proposed major-version changes. It can upgrade packages in incompatible ways.

After every dependency change:

```bash
npm run typecheck
npm run lint
npm run build
npm run smoke
```

---

# O.7 Upgrade Workflow

When upgrading Next.js, React, PostgreSQL driver, authentication packages, or validation packages:

```text
1. Read the release notes.
2. Review breaking changes.
3. Create a branch.
4. Update one dependency family at a time.
5. Run npm install.
6. Run typecheck.
7. Run lint.
8. Run production build.
9. Run smoke tests.
10. Test authentication and authorization manually.
11. Inspect bundle output if client-related dependencies changed.
12. Deploy to staging before production.
```

For framework upgrades, also verify:

```text
- Route behavior
- Metadata behavior
- Server Action behavior
- Cookie behavior
- Image optimization
- Security headers
- Docker build
- CI workflow
```

---

# O.8 Browser Versus Server Dependency Map

## Server-only dependencies

These must remain outside Client Component imports:

```text
postgres
bcryptjs
server-only
node:crypto
database client
database queries
database mutations
environment validation
session management
logger
```

## Browser-compatible dependencies

These may appear in Client Components when justified:

```text
react
react-dom
zod schemas without server imports
next/link
next/navigation client hooks
next/dynamic
```

## Framework-managed boundaries

Some Next.js modules can be imported only in specific contexts.

Examples:

```text
next/headers
  → Server Components, Route Handlers, Server Actions

next/cache
  → Server Actions and server modules

next/navigation
  → Some exports server-side, some hooks client-side

next/server
  → Route Handlers and middleware-related server code
```

Always check whether a Next.js API is intended for server, client, or both before importing it.

---

# O.9 Final Dependency Rule

A dependency is not free merely because installation is easy.

Every package adds some combination of:

```text
- Security update responsibility
- Bundle size
- Runtime behavior
- Upgrade work
- Documentation burden
- License obligations
- Potential framework compatibility risk
```

Prefer the smallest well-maintained solution that preserves LaunchPad’s existing security and rendering boundaries.
