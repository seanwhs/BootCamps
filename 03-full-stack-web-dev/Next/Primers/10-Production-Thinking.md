# Primer 10: Production Thinking—Security, Reliability, and Operations

This primer introduces the mindset required to move from a working local application to a responsibly operated production system.

You will learn:

- What production readiness means
- Why deployment is not the finish line
- How secrets, backups, monitoring, and recovery fit together
- Why security is a system property
- How to think about failures before they happen
- How LaunchPad’s operational components work together

---

## 1. Production Is More Than “It Deployed”

An application is not production-ready merely because this command succeeds:

```bash
npm run build
```

A production-ready application needs to answer questions such as:

```text
- Where are secrets stored?
- What happens if PostgreSQL fails?
- How do users sign in securely?
- How do we know the application is unhealthy?
- How do we restore deleted or corrupted data?
- How do we deploy schema changes safely?
- How do we roll back a bad release?
- What happens if traffic increases?
```

Production readiness is a collection of technical and operational practices.

---

## 2. The Production System

LaunchPad’s application is one part of a larger system.

```text
User browser
      ↓ HTTPS
Hosting platform or reverse proxy
      ↓
Next.js application
      ↓
Managed PostgreSQL
      ↓
Backups, logs, metrics, and alerts
```

Each part has a distinct responsibility.

| Layer | Responsibility |
|---|---|
| Browser | Displays UI and stores HTTP-only cookie |
| HTTPS edge | Encrypts traffic and routes requests |
| Next.js | Renders pages, validates input, authenticates users |
| PostgreSQL | Stores application records and sessions |
| Secret store | Supplies private runtime configuration |
| Monitoring | Detects errors, latency, and outages |
| Backup system | Enables recovery from data loss |

---

## 3. HTTPS Is Required in Production

HTTPS encrypts traffic between browser and server.

Without HTTPS, attackers on a network may be able to inspect or alter requests.

HTTPS is especially important for:

```text
- Password submission
- Session cookies
- Private project data
- API requests
- Account actions
```

LaunchPad requires production `APP_URL` values to use HTTPS:

```dotenv
APP_URL=https://launchpad.example.com
```

This is invalid in production:

```dotenv
APP_URL=http://launchpad.example.com
```

---

## 4. Secrets Must Stay Outside Source Control

A secret grants access or reveals protected information.

Examples:

```text
DATABASE_URL
Email provider API key
Monitoring token
Object-storage credential
Webhook signing key
```

Secrets belong in a deployment platform or secret manager.

They do not belong in:

```text
Git repositories
Client Components
Browser localStorage
API responses
Structured logs
Screenshots
Documentation examples
```

A production secret should be configured like this:

```text
Hosting platform secret store
        ↓
Runtime environment variable
        ↓
Server-only environment validation
        ↓
Server-only module usage
```

Never pass a secret into a Client Component.

---

## 5. Fail Fast on Invalid Configuration

A bad configuration should prevent startup.

For example, production should fail when:

```text
APP_URL uses HTTP
DATABASE_URL is missing
DATABASE_SSL is invalid
LOG_LEVEL is unsupported
```

LaunchPad validates configuration in:

```text
src/lib/environment.ts
```

This is better than allowing the server to start and later fail every database request.

Bad outcome:

```text
Deployment succeeds
    ↓
First user opens dashboard
    ↓
Database connection fails
```

Better outcome:

```text
Build or startup fails
    ↓
Deployment is stopped
    ↓
Configuration is corrected before traffic reaches users
```

---

## 6. Health Checks

LaunchPad exposes two health endpoints.

### Liveness

```text
GET /api/live
```

Question answered:

```text
Is the application process responding?
```

Expected status:

```text
200
```

### Readiness

```text
GET /api/health
```

Question answered:

```text
Can the application serve dependency-backed traffic?
```

Expected statuses:

```text
200 → PostgreSQL reachable
503 → PostgreSQL unavailable
```

A useful failure pattern:

```text
/api/live   → 200
/api/health → 503
```

This means:

```text
The application process is alive.
The database dependency is not ready.
```

---

## 7. Monitoring Is How You Learn About Failure

Without monitoring, users often become the first people to discover problems.

Monitoring should include:

```text
- Uptime checks
- Readiness checks
- Application errors
- Response latency
- Database pressure
- Deployment failures
- Backup failures
- Sign-in failure spikes
```

Useful signals include:

| Signal | Why it matters |
|---|---|
| 5xx error rate | Detects server failures |
| Readiness failure | Detects database or dependency outage |
| p95 latency | Detects slow experience for many users |
| Connection count | Detects database pool pressure |
| Database storage | Prevents unexpected storage exhaustion |
| Failed sign-ins | May indicate abuse or user friction |
| Crash loops | Indicates deployment or runtime failure |

---

## 8. Structured Logs

A log should be useful to humans and tools.

Weak log:

```text
Something failed
```

Structured log:

```json
{
  "timestamp": "2026-07-26T12:00:00.000Z",
  "level": "error",
  "event": "readiness_check_failed",
  "version": "abc123",
  "requestId": "request-id"
}
```

Structured logs support filtering by:

```text
level
event
version
requestId
environment
```

Never include:

```text
password
session token
cookie value
authorization header
DATABASE_URL
```

---

## 9. Request IDs

A request ID identifies one request across systems.

```text
Browser report
      ↓
X-Request-Id response header
      ↓
Application log
      ↓
Monitoring event
```

Example response header:

```http
X-Request-Id: 7c7d2e89-8d8d-4f3f-9b2f-0ea4c3ef765d
```

If a user reports a failure, support can use the ID to find the matching structured log entry.

---

## 10. Backups and Restore Testing

Backups protect against:

```text
- Accidental deletion
- Database corruption
- Infrastructure failure
- Security incident
- Operator mistakes
```

But backup existence is not enough.

A backup is proven only after it has been restored successfully.

A restore drill should include:

```text
1. Restore backup into isolated database.
2. Confirm tables and migration history.
3. Check expected row counts.
4. Start a temporary application against restored data.
5. Test sign-in and project access.
6. Measure restoration time.
7. Document gaps.
```

---

## 11. RPO and RTO

### Recovery Point Objective

**RPO** defines acceptable data loss.

Example:

```text
RPO: 15 minutes
```

This means the organization accepts losing at most 15 minutes of recent data after a disaster.

### Recovery Time Objective

**RTO** defines acceptable downtime.

Example:

```text
RTO: 2 hours
```

This means the service should be restored within two hours.

These values determine technical requirements such as:

```text
Backup frequency
Backup retention
Restore automation
Database replication
Incident staffing
```

---

## 12. Safe Database Migrations

A migration changes database structure.

Production migrations must be planned because current and previous application versions may run at the same time during deployment.

Safer sequence:

```text
Release 1
- Add new nullable column
- Deploy code supporting old and new schema

Release 2
- Backfill data
- Begin using new column

Release 3
- Remove old code path
- Remove old column in later migration
```

Risky sequence:

```text
1. Remove column.
2. Deploy code.
3. Deployment fails.
4. Roll back to old code.
5. Old code requires removed column.
6. Application remains broken.
```

LaunchPad tracks migrations with:

```text
schema_migrations
```

and checksums.

Never edit an applied migration.

---

## 13. Deployment Rollback

A rollback returns application code to a known-good version.

Before rolling back, ask:

```text
- Is the previous artifact still compatible with the current database schema?
- Did the latest migration remove fields the old application needs?
- Is the failure isolated to the current deployment?
- Can a forward fix be deployed more safely?
```

Application rollback is often quick.

Database rollback can be complex and risky.

Prefer:

```text
Forward-compatible schema changes
Corrective forward migrations
Immutable deployment artifacts
```

---

## 14. Scaling and Database Connections

Every application instance may create database connections.

LaunchPad’s client configuration includes:

```ts
max: 10
```

That is per process.

If you run:

```text
20 application instances
```

then the theoretical maximum becomes:

```text
20 × 10 = 200 database connections
```

Your managed PostgreSQL provider may allow fewer.

Before scaling, calculate:

```text
available database connection budget
÷ maximum application instances
= safe pool size per instance
```

If the database allows 100 connections and 20 are reserved:

```text
80 available connections
÷ 20 instances
= 4 connections per instance
```

In that environment, configure:

```ts
max: 4
```

---

## 15. Incident Response Basics

An incident is an event that affects:

```text
Availability
Security
Data integrity
Performance
Users
```

Basic response flow:

```text
Detect
   ↓
Confirm impact
   ↓
Check liveness
   ↓
Check readiness
   ↓
Inspect logs and deployment version
   ↓
Mitigate
   ↓
Recover
   ↓
Document root cause and prevention
```

Example database outage:

```text
/api/live returns 200
/api/health returns 503
```

First actions:

```text
1. Check managed PostgreSQL status.
2. Check connection count.
3. Check database network and TLS configuration.
4. Check recent migration.
5. Check storage or CPU alerts.
6. Avoid repeatedly restarting healthy application instances.
```

---

## 16. Production Security Checklist

Before a broad public launch, verify:

```text
- HTTPS is enabled.
- Production session cookies are Secure and HTTP-only.
- Database TLS is enabled.
- Secrets are stored outside Git.
- Private APIs are not shared cached.
- User-owned queries are owner scoped.
- Sign-in is rate limited.
- Backups are enabled.
- Restore testing is documented.
- Security headers are configured.
- Error monitoring is active.
- Session revocation procedure exists.
```

---

## 17. Primer Completion Checklist

Before returning to the main series, you should understand:

- [ ] Why deployment alone is not production readiness.
- [ ] Why HTTPS is required for private applications.
- [ ] Why secrets stay outside Git and browser code.
- [ ] Why runtime configuration must be validated.
- [ ] The difference between liveness and readiness.
- [ ] Why structured logs need safe redaction.
- [ ] Why request IDs help troubleshoot production issues.
- [ ] Why backups require restore testing.
- [ ] What RPO and RTO mean.
- [ ] Why migrations must be backward compatible.
- [ ] Why database rollback is harder than application rollback.
- [ ] How application instance count affects database connections.
- [ ] What a basic incident response sequence looks like.
- [ ] Which controls should exist before broad public launch.
