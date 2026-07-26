# Primer 11: Testing and Verification Foundations

This primer explains how to verify that a feature works correctly before moving on.

You will learn:

- Why testing is more than clicking through a page
- The difference between unit, integration, browser, and smoke tests
- Happy-path and failure-path testing
- How to test authorization
- How to verify database changes
- How to choose the smallest useful test
- How LaunchPad’s quality checks fit together

---

## 1. Why Verification Matters

Code can look correct and still fail.

For example, a project-creation form may:

```text
- Render correctly
- Accept text
- Show a submit button
```

but still fail because:

```text
- The Server Action reads the wrong FormData field name
- PostgreSQL is unavailable
- The session expired
- The project is created without an owner
- The page is not revalidated
- The production build cannot compile the route
```

Verification asks:

> Can we demonstrate the feature works under expected and unexpected conditions?

---

## 2. The Smallest Useful Test

Start with the smallest test that proves the behavior you changed.

| Change | Smallest useful verification |
|---|---|
| Pure formatting function | Unit test or direct function call |
| New route | Browser URL and `curl` status |
| New form validation | Submit valid and invalid values |
| New database query | SQL query or integration test |
| New API route | `curl` request |
| New authorization rule | Two-user negative test |
| New health endpoint | Stop PostgreSQL and inspect status |
| New Docker support | Run image and call liveness endpoint |
| New deployment | Smoke test against HTTPS origin |

Do not run a full deployment test every time you change a button label.

Do not skip production checks after changing authentication, migrations, or deployment configuration.

---

## 3. Testing Layers

LaunchPad uses several testing layers.

```text
Type checking
      ↓
Linting
      ↓
Manual and script verification
      ↓
Database integration checks
      ↓
Browser workflow checks
      ↓
Production smoke tests
```

Each layer finds different failures.

---

## 4. Type Checking

TypeScript checks whether source code follows declared contracts.

Run:

```bash
npm run typecheck
```

Example type error:

```ts
const status: ProjectStatus = "STARTED";
```

If supported values are:

```ts
type ProjectStatus =
  | "PLANNED"
  | "ACTIVE"
  | "COMPLETED";
```

then TypeScript rejects:

```text
STARTED
```

Type checking does **not** prove:

```text
- PostgreSQL is running
- A user owns a project
- An API returns correct JSON
- A browser form works
- A deployment has valid secrets
```

It is necessary, but not sufficient.

---

## 5. Linting

Linting checks source-quality rules.

Run:

```bash
npm run lint
```

Linting can identify:

```text
- Unused variables
- Invalid React patterns
- Suspicious hooks usage
- Style and consistency problems
- Framework-specific issues
```

Like type checking, linting does not prove user behavior or database correctness.

---

## 6. Unit Tests

A **unit test** verifies one focused piece of logic.

Good unit-test candidate:

```ts
calculateProjectProgress()
```

Example function:

```ts
export function calculateProjectProgress(
  project: ProjectSummary,
): number {
  if (project.taskCount === 0) {
    return 0;
  }

  return Math.round(
    (project.completedTaskCount / project.taskCount) * 100,
  );
}
```

Expected cases:

| Completed | Total | Expected |
|---:|---:|---:|
| 0 | 0 | `0` |
| 0 | 4 | `0` |
| 2 | 4 | `50` |
| 1 | 3 | `33` |
| 4 | 4 | `100` |

Unit tests should be:

```text
Fast
Deterministic
Focused
Independent of browser and database
```

---

## 7. Integration Tests

An **integration test** verifies that several pieces work together.

Examples:

```text
- Database query + PostgreSQL schema
- Session cookie + session table lookup
- Route Handler + validation schema + database mutation
- Server Action + owner-scoped database update
```

Example integration question:

> Does `getProjectById(userId, projectId)` return a project only when that project belongs to that user?

This cannot be proven by testing a pure formatting function.

It needs:

```text
User A
User B
Project owned by User A
Actual query execution
```

---

## 8. Browser End-to-End Tests

A browser end-to-end test simulates a real user journey.

Example workflow:

```text
1. Visit /sign-up
2. Create account
3. Confirm redirect to /dashboard
4. Create project
5. Add task
6. Mark task complete
7. Sign out
8. Confirm /dashboard redirects to /sign-in
```

Browser tests are valuable because they verify several systems together:

```text
HTML
CSS
JavaScript
Forms
Cookies
Redirects
Server Actions
Database changes
```

They are slower than unit tests, so reserve them for important workflows.

---

## 9. Smoke Tests

A **smoke test** verifies that the most critical deployed behavior is alive.

Run:

```bash
npm run smoke
```

LaunchPad smoke tests verify:

```text
- Public routes return 200
- Liveness endpoint returns 200
- Readiness endpoint returns 200
- Private API rejects anonymous callers
- Protected page redirects anonymous callers
- Private API uses correct cache headers
```

Smoke tests are intentionally small.

They answer:

> Did the deployment start successfully and preserve critical boundaries?

They do not replace deeper tests.

---

## 10. Happy Paths and Failure Paths

A **happy path** is expected successful behavior.

Example:

```text
Authenticated owner creates a project.
```

A **failure path** tests safe handling of problems.

Examples:

```text
- Project name is empty
- Status value is invalid
- User is signed out
- User does not own project
- UUID is malformed
- Project does not exist
- PostgreSQL is unavailable
```

Every important feature needs both.

Example matrix for project creation:

| Case | Expected outcome |
|---|---|
| Valid owner submission | Project created and redirect occurs |
| Empty project name | Field validation error |
| Invalid status | Validation error |
| Signed-out caller | Redirect to sign-in or `401` |
| PostgreSQL unavailable | Safe server error or error boundary |
| Duplicate form submission | Defined and safe behavior |

---

## 11. Authorization Tests Are Security Tests

Authorization is one of the most important negative test categories.

Create:

```text
User A
User B
Project A owned by User A
```

Then test User B.

| Action attempted by User B | Expected result |
|---|---|
| Open Project A page | Not-found interface |
| Read Project A API route | `404` |
| Update Project A API route | `404` |
| Delete Project A API route | `404` |
| Create task in Project A | Safe failure |
| Update Project A task | Safe failure |

The important rule:

> Test authorization by changing the resource identifier directly, not only by looking at the visible UI.

A hidden edit button does not prove the server rejects unauthorized writes.

---

## 12. Database Verification

When a mutation succeeds, inspect PostgreSQL when necessary.

Example: verify a created project.

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      p.id,
      p.name,
      p.status,
      u.email AS owner_email
    FROM projects AS p
    INNER JOIN users AS u
      ON u.id = p.owner_id
    ORDER BY p.created_at DESC
    LIMIT 5;
  "
```

This verifies:

```text
- The record exists
- The fields are correct
- Ownership is correct
```

Example: verify a task status update.

```bash
docker compose exec db \
  psql \
  --username=launchpad \
  --dbname=launchpad \
  --command="
    SELECT
      id,
      title,
      status,
      updated_at
    FROM tasks
    WHERE id = 'TASK_UUID_HERE';
  "
```

The database is the source of truth for persistent state.

---

## 13. API Verification with `curl`

Test a public endpoint:

```bash
curl --fail --silent \
  http://localhost:3000/api/live |
  python -m json.tool
```

Test anonymous private API behavior:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/api/projects
```

Expected:

```text
401
```

Test authenticated API behavior:

```bash
SESSION_TOKEN='paste-cookie-value-here'

curl --fail --silent \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  http://localhost:3000/api/projects |
  python -m json.tool
```

Never commit or share real session-token values.

---

## 14. Production Build Verification

Development mode is not the final test.

Run:

```bash
npm run build
```

Then run the optimized application:

```bash
npm run start
```

Verify:

```bash
npm run smoke
```

Production verification catches issues such as:

```text
- Missing environment variables
- Invalid Next.js configuration
- Server/client boundary errors
- Broken route conventions
- Missing production assets
- Build-only framework failures
```

---

## 15. CI Verification

Continuous integration repeats important checks in a clean environment.

LaunchPad CI runs:

```text
npm ci
    ↓
Apply migrations
    ↓
Verify migrations are idempotent
    ↓
Type-check
    ↓
Lint
    ↓
Build
    ↓
Start production server
    ↓
Run smoke tests
```

CI catches local assumptions such as:

```text
- Dependency installed locally but missing from package.json
- Migration not committed
- Environment variable not documented
- Build depends on stale local artifacts
```

---

## 16. Test Naming and Clarity

A good test name explains behavior.

Weak:

```text
works
test project
should pass
```

Better:

```text
returns 404 when authenticated user does not own project
creates a task owned by the selected project owner
returns 422 when project name is blank
redirects anonymous dashboard request to sign-in
```

A future reader should understand what failed from the test name alone.

---

## 17. Verification Checklist for New Features

Before considering a feature complete, verify:

- [ ] TypeScript accepts the source.
- [ ] ESLint accepts the source.
- [ ] The production build succeeds.
- [ ] The happy path works.
- [ ] Invalid input fails safely.
- [ ] Anonymous access fails safely if authentication is required.
- [ ] Non-owner access fails safely if data is private.
- [ ] Database state matches expected result.
- [ ] Related views update after mutation.
- [ ] Loading, empty, error, and not-found states are sensible.
- [ ] Keyboard behavior works.
- [ ] Narrow viewport behavior works.
- [ ] Smoke tests still pass.
- [ ] Documentation changes were considered.

---

## 18. Primer Completion Checklist

Before returning to the main series, you should understand:

- [ ] Why type checking is necessary but insufficient.
- [ ] Why linting is necessary but insufficient.
- [ ] What unit tests verify.
- [ ] What integration tests verify.
- [ ] What browser tests verify.
- [ ] What smoke tests verify.
- [ ] Why every feature needs happy and failure-path tests.
- [ ] Why authorization requires cross-user negative tests.
- [ ] How to inspect persistent results in PostgreSQL.
- [ ] How to verify APIs with `curl`.
- [ ] Why production builds must be tested.
- [ ] Why CI uses clean environments.
- [ ] How to define a complete verification checklist.
