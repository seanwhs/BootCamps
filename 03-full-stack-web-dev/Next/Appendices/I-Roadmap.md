# Appendix I: Suggested Production Improvements Roadmap

LaunchPad is production-oriented at the end of the series, but real applications continue evolving after their first deployment.

This appendix provides a prioritized roadmap for extending LaunchPad responsibly.

The goal is not to add every feature immediately. The goal is to choose improvements based on risk, user value, and operational evidence.

---

# I.1 Priority Levels

Use these categories to decide what to build next.

| Priority | Meaning |
|---|---|
| P0 | Required before broad or high-risk public launch |
| P1 | High-value improvement soon after launch |
| P2 | Important when product usage justifies it |
| P3 | Useful future enhancement |

---

# I.2 P0: Security and Reliability Before Broad Launch

These improvements should be strongly considered before inviting many public users.

## Distributed sign-in rate limiting

### Why it matters

Without rate limiting, attackers can repeatedly attempt passwords.

### Recommended controls

```text
- Limit attempts per IP address
- Limit attempts per email address
- Add progressive delays
- Monitor failed sign-in spikes
- Alert on suspicious activity
```

### Architecture requirement

Do not use a local in-memory map:

```ts
const attempts = new Map();
```

That fails when multiple application instances handle requests.

Use shared infrastructure such as:

```text
Redis
Managed rate-limit service
Edge rate limiting
API gateway controls
Web application firewall
```

---

## Email verification

### Why it matters

An account should not be treated as fully verified merely because someone typed an email address.

### Recommended flow

```text
User signs up
      ↓
Server creates random verification token
      ↓
Database stores only token hash
      ↓
Email contains original token in HTTPS link
      ↓
User opens link
      ↓
Server validates hash, expiry, and one-time use
      ↓
Account becomes verified
```

### Suggested user field

```sql
ALTER TABLE users
  ADD COLUMN email_verified_at TIMESTAMPTZ;
```

---

## Password reset

### Why it matters

Users forget passwords, and support must not handle passwords directly.

### Required controls

```text
- Short-lived random reset token
- Token hash stored in database
- Single-use token
- Rate limiting
- Generic response to avoid account enumeration
- Session revocation after password reset
- Audit log entry
```

---

## Error-monitoring backend

### Why it matters

Console logs are useful locally but insufficient for production incident response.

### Recommended capabilities

```text
- Error grouping
- Stack traces in restricted dashboard
- Release/version association
- Request IDs
- Alerting rules
- Source-map support
- User privacy controls
```

Do not send passwords, session values, database URLs, or full private content to an error-monitoring provider.

---

## Backup restoration drill

### Why it matters

A backup is not proven until it is restored successfully.

### Minimum drill

```text
1. Restore a production-like backup into an isolated database.
2. Confirm migration history.
3. Start a temporary application instance.
4. Verify readiness.
5. Verify sign-in.
6. Verify project ownership.
7. Record restoration duration.
8. Compare result against RPO and RTO targets.
```

---

# I.3 P1: Product Safety and Maintainability

## Audit logging

Record sensitive actions such as:

```text
- Account registration
- Sign-in success or failure
- Password reset
- Project deletion
- Project archive or restore
- Role change
- Session revocation
```

Suggested event structure:

```json
{
  "actorUserId": "user UUID",
  "eventType": "project.deleted",
  "entityType": "project",
  "entityId": "project UUID",
  "createdAt": "timestamp"
}
```

Avoid storing:

```text
passwords
raw session tokens
authorization headers
unnecessary private content
```

---

## Project archiving

Prefer archive behavior before permanent deletion for normal workflows.

Suggested field:

```sql
ALTER TABLE projects
  ADD COLUMN archived_at TIMESTAMPTZ;
```

Normal project queries should include:

```sql
AND archived_at IS NULL
```

An archive view can explicitly query:

```sql
AND archived_at IS NOT NULL
```

---

## Browser end-to-end tests

Automate the highest-value flows:

```text
- Register
- Sign in
- Create project
- Create task
- Update task
- Sign out
- Cross-user project denial
```

The cross-user test should remain permanent because authorization regressions are severe.

---

## Accessibility automation

Run accessibility checks in CI against public and private routes.

Review:

```text
- Labels
- Heading hierarchy
- Focus visibility
- Landmark structure
- Color contrast
- Error messages
- ARIA relationships
```

Automation supplements manual keyboard and screen-reader testing.

---

# I.4 P2: Scale and Collaboration

## Team workspaces

Move from:

```text
User → Projects
```

to:

```text
User → Organization membership → Workspace → Projects
```

Suggested role system:

```text
OWNER
ADMIN
MEMBER
VIEWER
```

Before implementing roles, define exactly who may:

```text
- Invite users
- Remove users
- Create projects
- Archive projects
- Delete projects
- Create tasks
- Change task status
- View reports
```

Roles should be enforced in server-side queries and mutations, not only in UI visibility.

---

## Pagination and server-side search

When a user can own hundreds or thousands of projects, avoid returning all records to the browser.

Add URL-backed state:

```text
/projects?status=ACTIVE&page=2&query=website
```

Use server-side validation and owner-scoped SQL.

Stable ordering is required:

```sql
ORDER BY updated_at DESC, id DESC
```

---

## Background jobs

Move slow or retryable work outside request lifecycles.

Examples:

```text
- Email delivery
- Notification processing
- Image scanning
- Report generation
- Session cleanup
- Search-index refresh
```

Recommended pattern:

```text
User mutation
      ↓
Database transaction commits
      ↓
Job record or event is written
      ↓
Worker processes event
      ↓
Retry policy handles transient failure
```

Do not hold a database transaction open while waiting for an email or external API.

---

## Connection pooling

As instance count grows, re-evaluate:

```ts
max: 10
```

in the PostgreSQL client.

Use:

```text
pool size per instance
≤
database connection budget ÷ maximum instances
```

Consider a managed pooler or PostgreSQL proxy when required.

---

# I.5 P3: Advanced Experience Improvements

## Optimistic task updates

Current task status updates wait for the server response.

An optimistic interface could update immediately, then reconcile with the server.

Use optimistic updates only when you can clearly handle:

```text
- Pending state
- Success
- Validation failure
- Authorization failure
- Network failure
- Reverting incorrect optimistic state
- Concurrent updates
```

Correctness is more important than a superficially instant interface.

---

## Rich text descriptions

If project or task descriptions require formatting:

```text
- Do not render arbitrary HTML directly.
- Sanitize all rich-text output.
- Define a small allowed element list.
- Prevent executable attributes and script URLs.
- Revisit CSP.
```

Plain text is safer and often sufficient.

---

## File attachments

Use object storage rather than the application filesystem.

A safe flow is:

```text
Authenticated user
      ↓
Server verifies project ownership
      ↓
Server creates short-lived upload authorization
      ↓
Browser uploads to object storage
      ↓
Server stores file metadata
      ↓
Download request checks authorization again
```

---

## Webhooks and integrations

If LaunchPad notifies external systems:

```text
- Sign outbound webhooks
- Include event ID and timestamp
- Retry with backoff
- Make delivery idempotent
- Record delivery attempts
- Provide safe replay tools
```

If LaunchPad receives webhooks:

```text
- Verify provider signatures
- Validate payload shape
- Enforce timestamp freshness
- Avoid duplicate processing
- Log safe event metadata
```

---

# I.6 Suggested 90-Day Plan

## Days 1–30

```text
- Add distributed rate limiting
- Add error-monitoring backend
- Add browser end-to-end tests
- Add dependency scanning
- Run backup restoration drill
- Add audit logging for sensitive operations
```

## Days 31–60

```text
- Add email verification
- Add password reset
- Add project archiving
- Add pagination and server-side search
- Add accessibility checks in CI
- Establish performance dashboards and alert thresholds
```

## Days 61–90

```text
- Add organizations and roles if collaboration is required
- Add background job infrastructure
- Add secure file uploads if required
- Add optimistic updates only where measured latency justifies them
- Tighten CSP toward nonce-based policy
- Perform external security review or penetration testing
```

---

# I.7 Decision Questions Before Adding a Feature

Before implementing a feature, answer these questions.

## Data

```text
- Does this require a migration?
- Which table owns the new data?
- Which records relate to it?
- What happens when a parent record is deleted?
- Which indexes will real queries need?
```

## Security

```text
- Who may read it?
- Who may create it?
- Who may change it?
- Who may delete it?
- Is resource existence private?
- Does this introduce a new secret or token?
```

## User experience

```text
- Is the state shareable?
- Should it live in the URL?
- Does the feature work without JavaScript?
- What loading, empty, validation, and error states exist?
- Is keyboard behavior clear?
```

## Operations

```text
- Does this need monitoring?
- Does this need a background job?
- Does this change backup needs?
- Does this affect migration safety?
- Does this require new alerts or runbook instructions?
```

## Testing

```text
- What is the positive path?
- What are the negative authorization cases?
- What input is invalid?
- What dependency can fail?
- What must be tested in a real browser?
```

---

# I.8 Final Engineering Principle

The safest way to extend LaunchPad is to preserve the boundaries that made it reliable:

```text
Browser
  → temporary interaction

URL
  → shareable navigation state

Server Components
  → trusted rendering and reads

Server Actions and Route Handlers
  → validated mutations

Database
  → persistence, integrity, and authorization conditions

Infrastructure
  → HTTPS, secrets, backups, monitoring, and scaling
```

When a new feature feels difficult to place, do not force it into an existing layer. Revisit the product rule, data ownership, trust boundary, and operational requirements first.
