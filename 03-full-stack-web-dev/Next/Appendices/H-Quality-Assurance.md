# Appendix H: Testing Strategy and Quality Assurance Reference

LaunchPad currently includes:

- Type checking
- Linting
- Database migrations
- Smoke tests
- Manual browser verification
- Production build checks
- Cross-user authorization checks

As the application grows, these checks should evolve into a layered automated test strategy.

This appendix explains what to test, where each kind of test belongs, and how to avoid testing only happy paths.

---

# H.1 The Testing Pyramid

A healthy test suite usually contains more fast, focused tests than slow browser tests.

```text
                 Browser tests
              ─────────────────
             Integration tests
          ───────────────────────
              Unit tests
       ───────────────────────────
     Type checking, linting, build
────────────────────────────────────
```

Each layer answers different questions.

| Layer | Main question |
|---|---|
| Type checking | Does the source code follow declared contracts? |
| Linting | Does the code follow quality and framework rules? |
| Unit tests | Does one focused function behave correctly? |
| Integration tests | Do several modules work together correctly? |
| Browser tests | Does a real user workflow succeed? |
| Smoke tests | Is the deployed system alive and reachable? |

No single layer replaces the others.

For example:

- TypeScript cannot prove SQL authorization is correct.
- A browser test cannot efficiently cover every input-validation edge case.
- A unit test cannot prove that a deployment has valid environment variables.
- A smoke test cannot prove that a user cannot access another user’s data in every mutation path.

---

# H.2 Recommended Test Categories

## Unit tests

Use unit tests for pure logic that does not need a database, browser, or server.

Good candidates include:

```text
calculateProjectProgress
formatProjectStatus
formatTaskStatus
formatTaskPriority
URL filter parsing
Pagination calculations
Zod validation schemas
Logger redaction
```

A unit test should be:

- Fast
- Isolated
- Deterministic
- Easy to understand

Example conceptual test cases for progress calculation:

```text
0 completed of 0 tasks → 0%
0 completed of 5 tasks → 0%
2 completed of 4 tasks → 50%
5 completed of 5 tasks → 100%
1 completed of 3 tasks → 33%
```

---

## Integration tests

Use integration tests when multiple application layers must work together.

Good candidates include:

```text
PostgreSQL queries
Database migrations
Owner-scoped project lookup
Session creation and lookup
Route Handler request and response behavior
Server Action validation and mutation behavior
```

Integration tests should use a dedicated test database.

Do not point automated tests at:

```text
- Local development data you care about
- Shared staging data
- Production databases
```

---

## Browser end-to-end tests

Use browser tests for complete user journeys.

Important LaunchPad workflows include:

```text
Register account
Sign in
Create project
Create task
Update task status
Sign out
Attempt protected navigation after sign-out
Attempt cross-user project access
```

Browser testing is especially valuable for:

- Form submission behavior
- Redirects
- Cookie behavior
- Loading interfaces
- Keyboard navigation
- Real browser interactions
- Browser-specific regressions

---

## Smoke tests

Use smoke tests after deployment.

LaunchPad’s smoke test checks:

```text
- Public routes return 200
- Liveness endpoint returns 200
- Readiness endpoint returns 200
- Private API rejects anonymous callers
- Protected routes redirect anonymous callers
- Private API cache headers are present
```

Smoke tests should be:

- Fast
- Stable
- Small in scope
- Safe to run repeatedly
- Run against preview and production origins

---

# H.3 Suggested Tooling

The tutorial intentionally did not lock the project to one testing framework. A common modern stack is:

| Concern | Possible tool |
|---|---|
| Unit and integration tests | Vitest |
| Browser tests | Playwright |
| Accessibility checks | Axe with Playwright |
| API tests | Vitest, `fetch`, or `curl` |
| Load tests | k6, Artillery, or provider tooling |
| Dependency scanning | Dependabot, npm audit, Snyk, or equivalent |
| Container scanning | Trivy, Docker Scout, or equivalent |

Choose tools based on team conventions, maintenance status, and CI compatibility.

---

# H.4 Unit-Test Candidates

## Project progress

The implementation:

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

Test cases should cover:

```text
- Zero tasks
- No completed tasks
- Fully completed tasks
- Rounding behavior
- Partial completion
```

---

## Input validation

Test Zod schemas with valid and invalid inputs.

### Project creation

Valid example:

```ts
{
  name: "Website redesign",
  description: "Improve performance and accessibility.",
  status: "ACTIVE",
}
```

Invalid examples:

```ts
{
  name: "",
  description: "",
  status: "UNKNOWN",
}
```

```ts
{
  name: "x".repeat(121),
  description: "Valid description",
  status: "PLANNED",
}
```

```ts
{
  name: "Valid project",
  description: "x".repeat(2001),
  status: "PLANNED",
}
```

---

## Authentication input validation

Test that registration rejects:

```text
- Empty names
- Invalid email addresses
- Passwords shorter than 12 characters
- Passwords without uppercase letters
- Passwords without lowercase letters
- Passwords without numbers
- Passwords without symbols
- Mismatched confirmation passwords
```

Test that email normalization works:

```text
DEMO@LAUNCHPAD.LOCAL
```

should become:

```text
demo@launchpad.local
```

---

## Logger redaction

Test that sensitive keys become:

```text
[REDACTED]
```

Examples:

```ts
{
  password: "secret",
  sessionToken: "token",
  cookie: "cookie-value",
  authorization: "Bearer value",
  databaseUrl: "postgresql://...",
}
```

Expected log-safe representation:

```ts
{
  password: "[REDACTED]",
  sessionToken: "[REDACTED]",
  cookie: "[REDACTED]",
  authorization: "[REDACTED]",
  databaseUrl: "[REDACTED]",
}
```

---

# H.5 Authorization Regression Tests

Authorization is too important to test only once manually.

Every private resource should have permanent negative tests.

For a project owned by User A and a session belonging to User B, test:

| Operation | Expected result |
|---|---|
| Read project page | Not-found interface |
| Read project API | `404` |
| Update project API | `404` |
| Delete project API | `404` |
| Create task | Rejected or not found |
| Update task status | Rejected or not found |
| Load task list | No unauthorized tasks returned |

The core assertion is:

```text
User B must never receive User A's project data.
```

Do not test only that User B cannot click a button.

Test direct URLs and direct API calls.

---

# H.6 Database Integration-Test Rules

Use a dedicated test database.

Suggested environment values:

```dotenv
APP_URL=http://localhost:3000
DATABASE_URL=postgresql://launchpad:launchpad-test-password@localhost:5433/launchpad_test
DATABASE_SSL=false
LOG_LEVEL=error
APP_VERSION=test
```

A test database should be:

- Separate from development
- Resettable
- Seeded predictably
- Never production
- Used only by automated tests

## Recommended database lifecycle

```text
Start PostgreSQL test service
      ↓
Create fresh test database
      ↓
Apply migrations
      ↓
Seed required fixtures
      ↓
Run tests
      ↓
Destroy or reset test data
```

## Isolation strategies

### Transaction rollback

Wrap each test in a transaction and roll it back afterward.

Useful for fast focused database tests.

### Truncate tables

Clear data between tests:

```sql
TRUNCATE TABLE
  sessions,
  tasks,
  projects,
  users
RESTART IDENTITY CASCADE;
```

### Fresh database per CI job

Useful for strong isolation and migration testing.

---

# H.7 Browser Test Workflows

A minimal browser test suite should include these workflows.

## Registration workflow

```text
1. Visit /sign-up.
2. Enter valid registration details.
3. Submit.
4. Confirm redirect to /dashboard.
5. Confirm authenticated account UI appears.
```

## Sign-in workflow

```text
1. Visit /sign-in.
2. Enter valid credentials.
3. Submit.
4. Confirm redirect to /dashboard.
5. Refresh.
6. Confirm session persists.
```

## Invalid sign-in workflow

```text
1. Visit /sign-in.
2. Submit wrong password.
3. Confirm generic failure message.
4. Confirm the message does not reveal account existence.
```

## Project workflow

```text
1. Sign in.
2. Visit /projects/new.
3. Create project.
4. Confirm redirect to project detail.
5. Confirm project appears in list.
6. Confirm dashboard count changes.
```

## Task workflow

```text
1. Open owned project.
2. Create task.
3. Confirm task appears.
4. Change task status.
5. Confirm completion percentage updates.
```

## Sign-out workflow

```text
1. Sign in.
2. Select Sign out.
3. Confirm redirect to /sign-in.
4. Attempt /dashboard.
5. Confirm redirect to /sign-in.
```

## Cross-user workflow

```text
1. Create project as User A.
2. Sign out.
3. Sign in as User B.
4. Request User A project URL.
5. Confirm not-found interface.
6. Call User A project API endpoint.
7. Confirm 404.
```

---

# H.8 Accessibility Test Coverage

Automated accessibility testing is useful, but manual testing remains necessary.

## Automated checks

Run an accessibility scanner against:

```text
/
/sign-in
/sign-up
/dashboard
/projects
/projects/new
/projects/:projectId
```

Look for:

- Missing labels
- Missing image alternative text
- Invalid ARIA usage
- Insufficient contrast
- Duplicate IDs
- Heading-order issues
- Missing document titles

## Manual keyboard checks

Verify:

```text
- Skip link appears first.
- Focus remains visible.
- Navigation can be reached.
- Forms can be completed.
- Select controls work.
- Disclosure controls open and close.
- Copy-link control works.
- Dialogs or confirmations, if added, trap and restore focus correctly.
```

## Screen-reader checks

At minimum, verify:

```text
- Main landmarks are present.
- Navigation regions have names.
- Validation errors are announced.
- Search result counts are announced.
- Expanded/collapsed disclosure state is announced.
- Status badges include readable text.
```

---

# H.9 Load and Performance Test Strategy

Do not load-test production casually.

Use:

```text
- A staging environment
- A dedicated load-testing window
- Provider-approved limits
- Monitoring dashboards
- A rollback plan
```

## Useful load-test scenarios

### Public routes

```text
GET /
GET /about
GET /features
```

Measure:

```text
- Response time
- CDN/cache behavior
- Error rate
- Image throughput
```

### Authenticated reads

```text
GET /dashboard
GET /projects
GET /projects/:projectId
```

Measure:

```text
- Database connection use
- Query latency
- Session lookup cost
- p95 and p99 latency
```

### Mutations

```text
POST project creation
POST task creation
Task status updates
```

Measure:

```text
- Database write latency
- Lock behavior
- Revalidation behavior
- Error rate
```

## Watch for

```text
- Connection-pool exhaustion
- Slow queries
- Increased database CPU
- High memory usage
- Lock waits
- Increased 5xx responses
- Session lookup bottlenecks
```

---

# H.10 CI Quality Gates

A mature CI pipeline can have several stages.

```text
Fast checks
├── npm ci
├── typecheck
├── lint
└── unit tests

Integration checks
├── PostgreSQL service
├── migrations
├── integration tests
└── API tests

Build checks
├── next build
├── bundle analysis when needed
└── Docker build

Browser checks
├── Playwright workflow tests
└── accessibility scans

Deployment checks
├── preview smoke test
└── production smoke test
```

Not every pull request needs every expensive test immediately.

A practical approach is:

| Trigger | Checks |
|---|---|
| Local developer change | Typecheck, lint, focused tests |
| Pull request | Typecheck, lint, unit, integration, build |
| Main branch | Full browser suite and preview smoke tests |
| Production deployment | Smoke tests, health checks, monitoring verification |
| Scheduled job | Dependency scan, full browser suite, backup restore drill |

---

# H.11 Test Data Rules

Test data should be:

- Synthetic
- Non-sensitive
- Reproducible
- Clearly labeled
- Easy to delete
- Separate from production data

Good test email:

```text
user-a@test.launchpad.local
```

Bad test email:

```text
real-person@example.com
```

Good project name:

```text
Authorization test project
```

Bad project name:

```text
Customer confidential project plan
```

Never place real customer data, passwords, session cookies, or production secrets into fixtures.

---

# H.12 Failure-Case Checklist

For every new mutation, test more than the successful path.

| Category | Example |
|---|---|
| Missing input | Empty project name |
| Invalid format | Invalid UUID |
| Unsupported enum | Invalid project status |
| Too-long input | 121-character project name |
| Unauthenticated caller | No session cookie |
| Expired session | Expired database session |
| Unauthorized caller | User B accesses User A record |
| Missing resource | Valid but nonexistent UUID |
| Dependency failure | PostgreSQL unavailable |
| Duplicate request | Repeated creation request |
| Concurrent update | Two clients update same task |
| Stale UI | Mutation succeeds but page does not refresh |

A feature is not fully tested until its expected failures are intentional and understandable.

---

# H.13 Recommended Future Test Scripts

As testing grows, `package.json` may eventually include scripts like:

```json
{
  "scripts": {
    "test": "vitest run",
    "test:watch": "vitest",
    "test:integration": "vitest run --config vitest.integration.config.ts",
    "test:e2e": "playwright test",
    "test:a11y": "playwright test --grep @a11y",
    "test:smoke": "node scripts/smoke-test.mjs",
    "test:all": "npm run typecheck && npm run lint && npm run test && npm run build"
  }
}
```

Do not add commands until the corresponding tools and configuration are actually implemented.

A script should always perform real work.

---

# H.14 Test Review Checklist

Before merging a substantial feature, ask:

- [ ] Which pure functions need unit tests?
- [ ] Which database behaviors need integration tests?
- [ ] Which user journey needs a browser test?
- [ ] Which authorization-negative case must be permanent?
- [ ] Which validation errors should be tested?
- [ ] Does the feature affect cache behavior?
- [ ] Does the feature affect migration behavior?
- [ ] Does the feature need accessibility verification?
- [ ] Does the feature need a smoke-test update?
- [ ] Does the feature require runbook or deployment-checklist updates?

---

# H.15 Final Testing Principles

Keep these principles in mind:

1. **Test behavior, not implementation details.**
2. **Test authorization from the attacker’s perspective.**
3. **Use a separate database for automated tests.**
4. **Keep tests deterministic and independent.**
5. **Make negative cases first-class test cases.**
6. **Use browser tests for real workflows, not every function.**
7. **Keep smoke tests fast enough to run after every deployment.**
8. **Never use production credentials or real user data in tests.**
9. **A passing build is necessary but not sufficient.**
10. **Production monitoring completes the testing loop.**
