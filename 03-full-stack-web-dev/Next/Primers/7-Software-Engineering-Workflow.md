# Primer 7: Software Engineering Workflow, Quality, and Production Mindset

This primer prepares you to think beyond “the code works on my machine.”

A production application is not only a collection of pages and functions. It is a system that must remain:

- Understandable
- Secure
- Testable
- Deployable
- Observable
- Recoverable
- Safe to change

You will learn:

- How to break work into safe steps
- Why small commits matter
- What verification means
- How development differs from production
- Why environment configuration matters
- What monitoring, backups, and rollback mean
- How to make engineering decisions based on risk

---

## 1. “Working” Has Several Meanings

When someone says a feature “works,” clarify what they mean.

A project creation feature may work in several increasingly complete ways.

### Level 1: Visual success

```text
The form appears in the browser.
```

### Level 2: Functional success

```text
Submitting the form creates a database record.
```

### Level 3: Secure success

```text
Only an authenticated user can create a project.
The project is owned by that user.
```

### Level 4: Reliable success

```text
Invalid input is handled.
Database failure is handled.
The page refreshes correctly.
The production build succeeds.
```

### Level 5: Operational success

```text
The deployed application can be monitored.
Errors are logged safely.
Database backups exist.
Rollback is understood.
```

Production engineering aims for all five levels.

---

## 2. Build Features in Vertical Slices

A **vertical slice** is a small feature that passes through every required layer.

For example, “create a project” crosses:

```text
Browser form
    ↓
Server Action
    ↓
Validation
    ↓
Authentication
    ↓
Authorization
    ↓
PostgreSQL mutation
    ↓
Route revalidation
    ↓
Updated interface
```

A poor workflow is to build every form first, then every API, then every database query.

That can leave a large amount of disconnected, unverified code.

A better workflow:

```text
1. Define one small feature.
2. Add the required schema change.
3. Add validation.
4. Add server logic.
5. Add interface.
6. Verify positive and negative cases.
7. Commit.
```

This is how LaunchPad evolved throughout the series.

---

## 3. Define the Product Rule Before Writing Code

Before adding a feature, write one or two plain-language rules.

Example: task creation.

```text
A signed-in project owner can create a task for one of their projects.
A task title is required.
A task begins with the TODO status.
A user cannot add a task to another user’s project.
```

These rules lead directly to implementation decisions.

| Product rule | Implementation consequence |
|---|---|
| Signed-in owner only | `requireUser()` |
| Task belongs to a project | `project_id` foreign key |
| Title required | Zod schema and database check |
| Default status is TODO | Database default and UI behavior |
| Other users denied | Owner-scoped SQL |

Writing the rule first prevents building a UI without deciding what the server is allowed to do.

---

## 4. Make One Change at a Time

When several things are failing, avoid changing everything at once.

Risky workflow:

```text
- Rename several files
- Upgrade packages
- Change database schema
- Rewrite page
- Add a Client Component
- Change environment variables
- Run build once
```

If the build fails, it is difficult to identify the cause.

Better workflow:

```text
1. Add one migration.
2. Apply it.
3. Verify database schema.
4. Add one type.
5. Type-check.
6. Add one query.
7. Verify query.
8. Add one page change.
9. Verify browser behavior.
```

Small steps make debugging cheaper.

---

## 5. Verification Is Part of Implementation

Verification is not optional cleanup at the end.

Every feature should have a specific test.

| Feature | Verification |
|---|---|
| New page | Open browser URL and check status code |
| New API route | Send `curl` request |
| New migration | Apply migration twice |
| New form | Submit valid and invalid values |
| New authorization rule | Test with two users |
| New image | Inspect responsive image request |
| New Client Component | Test browser interaction |
| New Docker build | Run container and hit health endpoint |
| New deployment | Run smoke tests over HTTPS |

A useful rule:

> If you cannot describe how to verify a feature, you have not fully designed it.

---

## 6. Positive and Negative Tests

A positive test verifies expected success.

Example:

```text
Authenticated project owner creates a task.
```

A negative test verifies safe failure.

Examples:

```text
Anonymous user attempts task creation.
User B attempts to update User A’s task.
Invalid task status is submitted.
Database is unavailable.
```

Production defects often happen in negative paths because developers naturally test happy paths first.

For every new feature, ask:

```text
What should happen if:
- Input is missing?
- Input is invalid?
- User is signed out?
- User does not own the record?
- Record does not exist?
- Database is unavailable?
- Request is repeated?
```

---

## 7. Git Commits as Engineering Checkpoints

A commit is more than a saved file version. It is a verified checkpoint.

Good commit:

```text
feat: add task creation workflow
```

This ideally means:

```text
- Database schema supports tasks
- Validation exists
- Server Action exists
- Ownership is enforced
- UI exists
- Positive and negative paths were verified
- Build passed
```

Weak commit:

```text
changes
```

A useful commit message describes intent.

Examples:

```text
feat: add owner-scoped project editing
fix: prevent stale task status after update
perf: split optional project insights bundle
docs: add database restore runbook
ci: add migration verification step
```

---

## 8. Development, CI, and Production Are Different Environments

### Development

Development optimizes for fast feedback.

```bash
npm run dev
```

Characteristics:

```text
- Fast Refresh
- Detailed errors
- Local environment variables
- Local PostgreSQL
- Extra development checks
```

### Continuous integration

CI optimizes for repeatability.

```text
npm ci
npm run typecheck
npm run lint
npm run build
npm run smoke
```

Characteristics:

```text
- Clean environment
- Exact dependency installation
- Fresh database service
- Automated checks
- No assumptions about a developer laptop
```

### Production

Production optimizes for users and reliability.

```bash
npm run build
npm run start
```

Characteristics:

```text
- Optimized assets
- HTTPS
- Managed secrets
- Managed PostgreSQL
- Monitoring
- Backups
- Deployment constraints
```

A feature that works in development but fails in CI or production is incomplete.

---

## 9. Configuration Is Part of the Application

Configuration determines how an application behaves outside source code.

Examples:

```text
APP_URL
DATABASE_URL
DATABASE_SSL
LOG_LEVEL
APP_VERSION
```

These values affect:

```text
- Database connection behavior
- Cookie security
- Logging verbosity
- Deployment identity
- HTTPS validation
```

Treat configuration like typed input.

LaunchPad validates it through:

```text
src/lib/environment.ts
```

A configuration failure should happen early:

```text
Invalid server environment configuration:
APP_URL must use HTTPS when NODE_ENV is production.
```

This is better than deploying successfully and discovering broken authentication later.

---

## 10. Secrets Are Different from Configuration

Some configuration values are safe to document publicly:

```dotenv
LOG_LEVEL=info
DATABASE_SSL=true
```

Some are secrets:

```dotenv
DATABASE_URL=postgresql://username:password@host/database
```

A secret can grant access or reveal sensitive information.

Examples:

```text
- Database credentials
- API keys
- Webhook signing keys
- Email-provider tokens
- Monitoring tokens
- Encryption keys
- Session secrets in other architectures
```

Rules:

```text
- Never commit secrets.
- Never put secrets in Client Components.
- Never log secrets.
- Never send secrets in API responses.
- Rotate secrets if exposure is suspected.
```

---

## 11. Observability: Knowing What the System Is Doing

**Observability** means being able to understand system behavior from its outputs.

LaunchPad uses several observability tools.

### Logs

Structured events:

```json
{
  "timestamp": "2026-07-26T12:00:00.000Z",
  "level": "error",
  "event": "readiness_check_failed",
  "version": "abc123"
}
```

### Health checks

```text
/api/live
/api/health
```

### Metrics

Examples:

```text
- HTTP error rate
- p95 response time
- Database connection count
- Database CPU
- Memory use
- Sign-in failure rate
```

### Traces

A trace follows one request through several services.

For LaunchPad’s current architecture, a future trace might show:

```text
GET /projects
    ↓
Session lookup
    ↓
Owner-scoped project query
    ↓
Render response
```

---

## 12. Liveness and Readiness

These checks answer different questions.

### Liveness

```text
Is the application process responding?
```

LaunchPad:

```text
GET /api/live
```

Expected result:

```text
200
```

Liveness should not fail only because PostgreSQL is unavailable.

### Readiness

```text
Can the application currently serve dependency-backed traffic?
```

LaunchPad:

```text
GET /api/health
```

Expected healthy result:

```text
200
```

Expected database failure result:

```text
503
```

Example:

```text
Application process is healthy
PostgreSQL is unavailable
```

Then:

```text
/api/live   → 200
/api/health → 503
```

This distinction prevents infrastructure from repeatedly restarting a healthy process during a database outage.

---

## 13. Backups and Recovery

A backup is a saved copy of data.

But a backup is useful only if it can be restored.

A production backup plan should define:

```text
- Backup frequency
- Retention period
- Encryption
- Restore procedure
- Restore testing schedule
- Responsible owner
```

Two important terms:

### Recovery Point Objective

**RPO** answers:

```text
How much data can we afford to lose?
```

Example:

```text
RPO: 15 minutes
```

### Recovery Time Objective

**RTO** answers:

```text
How long can the service be unavailable?
```

Example:

```text
RTO: 2 hours
```

These are business decisions with technical consequences.

---

## 14. Rollback Is Not Always Simple

An application rollback means deploying an earlier version of code.

A database rollback is more difficult.

Example risky sequence:

```text
1. Migration deletes a database column.
2. New application deployment fails.
3. Team deploys old application.
4. Old application expects deleted column.
5. Old application fails too.
```

Prefer backward-compatible migrations.

Safer sequence:

```text
Release 1:
- Add new column.
- Deploy code that understands both old and new data.

Release 2:
- Backfill data.
- Stop using old column.

Release 3:
- Remove old column after old code is gone.
```

This is why database migrations need planning and review.

---

## 15. Production Incident Mindset

An incident is an unexpected event affecting users, security, availability, or data integrity.

Example symptoms:

```text
- Users cannot sign in.
- Dashboard returns errors.
- Readiness endpoint returns 503.
- Database connections are exhausted.
- Private data appears in wrong user account.
```

Basic incident sequence:

```text
1. Confirm impact.
2. Check liveness.
3. Check readiness.
4. Inspect logs and release version.
5. Compare recent deployments and migrations.
6. Mitigate immediate user impact.
7. Roll back safely if appropriate.
8. Investigate root cause.
9. Document corrective actions.
```

During an incident:

```text
- Avoid random configuration changes.
- Avoid destructive database commands.
- Preserve useful logs.
- Communicate clearly.
- Use the runbook.
```

---

## 16. Risk-Based Engineering

Not every feature needs the same level of controls.

A static public marketing paragraph has lower risk than:

```text
- Password reset
- Project deletion
- File upload
- Billing integration
- Team-role change
- Production schema migration
```

Higher-risk changes deserve:

```text
- More review
- More tests
- More logging
- More rollback planning
- More careful deployment
- More explicit authorization checks
```

A useful question:

> What is the worst realistic outcome if this feature is wrong?

Examples:

| Feature | Possible worst outcome |
|---|---|
| Typo on public page | Minor confusion |
| Broken project filter | Reduced usability |
| Broken project deletion | Data loss |
| Missing owner condition | Cross-user data exposure |
| Incorrect backup policy | Irrecoverable data loss |
| Exposed database secret | Unauthorized system access |

The risk should influence the engineering effort.

---

## 17. The Definition of Done

For LaunchPad, a feature is done when it has all relevant layers.

Example: “Add project archive.”

```text
Product behavior
├── Archive rule defined
├── Migration added
├── Query behavior updated
├── Validation added
├── Authorized mutation added
├── Interface added
├── Loading and error behavior considered
├── Revalidation added
├── Owner and non-owner behavior verified
├── Typecheck passes
├── Lint passes
├── Production build passes
├── Tests updated
└── Documentation updated if operations changed
```

“Button appears” is not the definition of done.

---

## 18. Primer Verification Exercise

Consider this proposed feature:

```text
Allow a user to archive one project.
```

Write the steps in order.

Expected answer:

```text
1. Define archive product rules.
2. Add archived_at migration.
3. Update seed data if necessary.
4. Add database query behavior for normal and archived lists.
5. Add owner-scoped archive mutation.
6. Add input validation if the action accepts values.
7. Add Server Action or Route Handler.
8. Add UI control.
9. Revalidate project list, dashboard, and project detail.
10. Test owner behavior.
11. Test non-owner behavior.
12. Test migration and production build.
13. Update documentation and audit logging if applicable.
```

---

## 19. Primer Completion Checklist

Before returning to the main series, you should understand:

- [ ] Why “working” has functional, security, reliability, and operational levels.
- [ ] What a vertical feature slice is.
- [ ] Why product rules should come before implementation.
- [ ] Why verification belongs in every implementation step.
- [ ] Why positive and negative tests are both necessary.
- [ ] Why small commits are useful checkpoints.
- [ ] The difference between development, CI, and production.
- [ ] Why environment validation matters.
- [ ] The difference between configuration and secrets.
- [ ] What structured logs, metrics, and health checks provide.
- [ ] The difference between liveness and readiness.
- [ ] Why backups require restore testing.
- [ ] Why database rollback requires extra care.
- [ ] How risk should influence engineering effort.
- [ ] What a complete definition of done includes.
