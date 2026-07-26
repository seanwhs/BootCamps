# Appendix Q: Learning and Review Plan

This appendix helps readers revisit the series after completing the full build.

A large full-stack project contains many moving parts. You do not need to memorize every file or API immediately. The goal is to repeatedly practice the architectural decisions until they become natural.

---

## Q.1 Recommended Review Order

Review the series in this order:

```text
1. Routing and layouts
2. Server and Client Component boundaries
3. Database reads
4. Mutations and APIs
5. Authentication and authorization
6. Performance and caching
7. Deployment and operations
```

This order follows the application’s dependency chain.

```text
Routes
  ↓
Rendering boundaries
  ↓
Data access
  ↓
Data mutation
  ↓
Security
  ↓
Optimization
  ↓
Operations
```

---

## Q.2 First Review: Routing and Layouts

Revisit:

```text
Part 2: Routing and Pages
Part 3: Layouts and UI Composition
```

Practice tasks:

- Add a public `/privacy` page.
- Add a public `/terms` page.
- Add a workspace `/settings` page.
- Add route metadata for each page.
- Confirm public routes use the marketing layout.
- Confirm workspace routes use the workspace layout.
- Confirm route-group names do not appear in URLs.

Expected route structure:

```text
src/app/
├── (marketing)/
│   ├── privacy/
│   │   └── page.tsx
│   └── terms/
│       └── page.tsx
└── (workspace)/
    └── settings/
        └── page.tsx
```

---

## Q.3 Second Review: Server and Client Boundaries

Revisit:

```text
Part 4: Server and Client Components
```

Practice tasks:

- Add a small Client Component that toggles a compact display mode.
- Keep the surrounding page as a Server Component.
- Pass only serializable properties into the Client Component.
- Confirm no Client Component imports database or session modules.

Ask this question for each component:

```text
Does this code need browser state, browser APIs, or event handlers?
```

If the answer is no, keep it server-compatible.

---

## Q.4 Third Review: Database and Queries

Revisit:

```text
Part 5: Data Fetching in Next.js 16
```

Practice tasks:

- Add a new project field such as `target_date`.
- Create a new migration.
- Update seed data.
- Update Zod database-result schemas.
- Update project types.
- Update owner-scoped queries.
- Render the value in project details.

Do not edit an existing migration. Create a new one:

```text
003_add_project_target_date.sql
```

Then run:

```bash
npm run db:migrate
npm run db:seed
npm run typecheck
npm run lint
npm run build
```

---

## Q.5 Fourth Review: Mutations

Revisit:

```text
Part 7: Building APIs and Full-Stack Features
```

Practice tasks:

- Add a Server Action for editing a project.
- Add an authenticated `PATCH` API operation.
- Validate all fields with Zod.
- Revalidate dashboard, project-list, and project-detail routes.
- Test malformed JSON and invalid values.
- Test owner and non-owner behavior.

Every mutation should follow this sequence:

```text
Authenticate
    ↓
Validate
    ↓
Authorize in SQL
    ↓
Mutate
    ↓
Revalidate
    ↓
Return safe feedback
```

---

## Q.6 Fifth Review: Authentication and Authorization

Revisit:

```text
Part 8: Authentication and State Management
```

Practice tasks:

- Create two test users.
- Create one project for each user.
- Attempt cross-user reads.
- Attempt cross-user updates.
- Attempt cross-user deletes.
- Confirm all unauthorized private-resource operations return `404`.

The most important authorization rule remains:

```text
Never trust client-provided ownership.
```

Ownership comes from:

```text
HTTP-only cookie
    ↓
Session lookup
    ↓
Authenticated user ID
    ↓
Owner-scoped SQL
```

---

## Q.7 Sixth Review: Performance

Revisit:

```text
Part 9: Performance and Optimization
```

Practice tasks:

- Run the route timing script.
- Run the bundle analyzer.
- Inspect client bundles.
- Add one optional dynamically imported component.
- Verify it does not contain essential page content.
- Inspect query plans before adding indexes.
- Confirm private APIs remain:

```http
Cache-Control: private, no-store
Vary: Cookie
```

Do not optimize merely because a technique exists.

Use this sequence:

```text
Measure
    ↓
Identify
    ↓
Change one thing
    ↓
Measure again
```

---

## Q.8 Seventh Review: Production Operations

Revisit:

```text
Part 10: Deployment and Production Readiness
```

Practice tasks:

- Build the Docker image.
- Run it against local PostgreSQL.
- Verify liveness and readiness.
- Run smoke tests.
- Review CI workflow logs.
- Read the production runbook.
- Perform a local database restore rehearsal if your tooling supports it.

Core production commands:

```bash
npm ci
npm run typecheck
npm run lint
npm run build
npm run smoke
```

---

## Q.9 Suggested Capstone Extensions

Once the foundation is comfortable, build one of these extensions.

### Option 1: Project archiving

Learn:

```text
- Additive migrations
- Query filtering
- Restore workflows
- Archive UI
- Audit events
```

### Option 2: Project editing

Learn:

```text
- Prefilled forms
- Server Actions
- Partial updates
- Revalidation
- Owner-scoped mutations
```

### Option 3: Pagination and server-side search

Learn:

```text
- URL state
- Query validation
- Stable database ordering
- Limits and offsets
- Search indexes
```

### Option 4: Team workspaces

Learn:

```text
- Membership tables
- Roles
- Organization-scoped queries
- Invitation flows
- Role-based authorization
```

### Option 5: Attachments

Learn:

```text
- Object storage
- Upload authorization
- File metadata
- Download authorization
- Content-type validation
```

---

## Q.10 Final Self-Assessment

You are ready to adapt this architecture to another production project when you can confidently answer:

1. Why is a Server Component the default?
2. When should a component become a Client Component?
3. Why are URL parameters validated?
4. Why must database queries include ownership conditions?
5. Why does authentication not replace authorization?
6. Why are session cookies HTTP-only?
7. Why are raw session tokens not stored in PostgreSQL?
8. When should you use a Server Action?
9. When should you use a Route Handler?
10. Why are private API responses `private, no-store`?
11. Why do migrations require checksums?
12. Why should production deploy an immutable artifact?
13. Why do liveness and readiness checks differ?
14. Why is a backup insufficient until restoration is tested?
15. Why should performance changes begin with measurement?

If you can explain those decisions and apply them consistently, you have moved beyond following a tutorial—you are making architecture decisions.
