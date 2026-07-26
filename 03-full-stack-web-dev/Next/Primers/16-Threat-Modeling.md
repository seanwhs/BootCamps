# Primer 16: Production Security Threat Modeling Foundations

This primer teaches you how to think about security before writing a feature.

A threat model is not a list of scary attacks. It is a structured way to answer:

- What are we protecting?
- Who might try to access or change it?
- Which application boundaries are exposed?
- What happens if a control fails?
- Which defenses belong in the browser, server, database, and infrastructure?

---

## 1. What Are We Protecting?

LaunchPad contains several categories of assets.

| Asset | Why it matters |
|---|---|
| User passwords | Can grant account access |
| Session tokens | Can impersonate a signed-in user |
| Project records | May contain private work information |
| Task records | May reveal plans, deadlines, and priorities |
| Database credentials | Can grant broad database access |
| Deployment secrets | Can control infrastructure or third-party services |
| Audit and log data | May contain sensitive operational context |

A threat model begins by identifying these assets.

---

## 2. Who Might Act Against the System?

Not every attacker is a sophisticated external criminal.

Consider several actors.

| Actor | Example risk |
|---|---|
| Anonymous visitor | Calls private API directly |
| Signed-in user | Attempts to access another user’s project UUID |
| Malicious browser script | Attempts to read tokens or submit actions |
| Automated bot | Repeatedly guesses passwords |
| Developer mistake | Removes owner condition from SQL |
| Deployment mistake | Exposes a secret through environment configuration |
| Database compromise | Reveals stored sessions or password hashes |
| Third-party dependency | Introduces a security vulnerability |

The point is not to distrust everyone. The point is to design controls that still work when assumptions fail.

---

## 3. Trust Boundaries

A **trust boundary** is a place where data moves from a less trusted context to a more trusted one.

LaunchPad has several important boundaries.

```text
Browser
    ↓
Next.js server
    ↓
PostgreSQL
```

Additional boundaries include:

```text
Browser
    ↓
Third-party API

CI system
    ↓
Deployment platform

Application
    ↓
Monitoring provider

Application
    ↓
Object storage
```

At each boundary, ask:

```text
What input enters here?
Can it be manipulated?
What should validate it?
What information may leave this boundary?
```

---

## 4. The Browser Is Untrusted

Browser code can improve user experience, but it cannot enforce security.

A user can:

```text
- Edit form fields
- Modify URL parameters
- Send direct HTTP requests
- Change hidden form values
- Call APIs from scripts
- Replay old requests
- Inspect JavaScript
```

This browser condition:

```tsx
{isOwner ? (
  <button>Delete project</button>
) : null}
```

does not prove the server action is protected.

The real protection belongs in server and database code:

```sql
DELETE FROM projects
WHERE id = ${projectId}
  AND owner_id = ${userId};
```

---

## 5. Common Threat Categories

A useful mnemonic is to group risks by what they attempt to do.

| Threat | Example | Primary defense |
|---|---|---|
| Identity spoofing | Stolen session token | Secure cookies, session validation |
| Unauthorized access | User B reads User A project | Owner-scoped SQL |
| Data tampering | User changes task ID in request | Identifier validation and owner-scoped mutation |
| Information disclosure | Shared cache leaks private API response | `private, no-store` |
| Service abuse | Password guessing | Distributed rate limiting |
| Injection | SQL syntax in user input | Parameterized SQL |
| Cross-site request | External site triggers mutation | SameSite, origin/CSRF protections |
| Script injection | Untrusted HTML executes | React escaping, CSP, sanitization |
| Misconfiguration | Database URL exposed | Secret management and validation |

---

## 6. Threat Modeling a Feature

Suppose you add project deletion.

Start with the product behavior:

```text
A project owner can permanently delete one of their projects.
```

Then ask threat-model questions.

### What data is affected?

```text
Project record
Related tasks
Potential audit event
```

### Who may act?

```text
Only the project owner.
```

### What can go wrong?

```text
- Anonymous caller attempts deletion
- User B deletes User A project
- User accidentally deletes project
- Request is replayed
- Database error leaves partial state
- UI appears deleted but database mutation fails
```

### Controls

```text
- requireUser()
- Validate project UUID
- Owner-scoped DELETE SQL
- Confirmation workflow
- Database cascade rules reviewed
- Audit event in transaction if required
- Revalidate routes
- Safe user feedback
```

---

## 7. Authentication Controls

Authentication protects identity.

LaunchPad uses:

```text
Email and password
    ↓
bcrypt verification
    ↓
Random session token
    ↓
HTTP-only secure cookie
    ↓
Hashed session token in PostgreSQL
```

Security properties include:

| Control | Purpose |
|---|---|
| bcrypt hashing | Protect stored passwords |
| Random token | Prevent token guessing |
| Token hash in database | Prevent direct session replay from database dump |
| HTTP-only cookie | Prevent normal JavaScript token reading |
| Secure cookie | Require HTTPS in production |
| SameSite Lax | Reduce many cross-site cookie submissions |
| Session expiry | Limit credential lifetime |
| Server-side session table | Support sign-out and revocation |

Authentication answers only:

```text
Who is the caller?
```

It does not answer:

```text
May the caller access this project?
```

---

## 8. Authorization Controls

Authorization protects records and operations.

LaunchPad’s core rule is:

```text
Users may access only projects they own.
```

The correct enforcement point is SQL.

```sql
SELECT
  p.id,
  p.name
FROM projects AS p
WHERE p.id = ${projectId}
  AND p.owner_id = ${userId};
```

For mutations:

```sql
UPDATE projects
SET
  status = ${status},
  updated_at = CURRENT_TIMESTAMP
WHERE id = ${projectId}
  AND owner_id = ${userId};
```

Do not rely on:

```text
- Hidden UI controls
- Client-provided owner IDs
- Route-group folder names
- Client-side project filtering
```

---

## 9. Input Validation Controls

Validation protects against malformed or unsupported input.

LaunchPad validates:

| Input source | Example |
|---|---|
| URL parameter | Project UUID |
| Search parameter | `status=ACTIVE` |
| FormData | Project name and task title |
| JSON body | API project creation |
| Environment variable | `DATABASE_URL` |
| Database row | Query result schema |

Validation does not replace authorization.

This may be structurally valid:

```json
{
  "status": "COMPLETED"
}
```

but the caller may still lack permission to change the selected project.

---

## 10. SQL Injection Controls

SQL injection occurs when untrusted input changes the meaning of SQL.

Unsafe:

```ts
const sql = `
  SELECT *
  FROM projects
  WHERE id = '${projectId}'
`;
```

Safe:

```ts
const rows = await database`
  SELECT *
  FROM projects
  WHERE id = ${projectId}
`;
```

Parameterized SQL separates instructions from values.

Use parameterization for:

```text
- IDs
- Text search
- Form values
- Status filters
- Pagination values
- Dates
```

Do not use parameterization as an excuse to skip validation. It prevents injection, not invalid product behavior.

---

## 11. Cross-Site Scripting Controls

Cross-Site Scripting, or XSS, happens when untrusted content becomes executable browser code.

React escapes ordinary text:

```tsx
<p>{project.description}</p>
```

If a project description contains:

```html
<script>alert("bad")</script>
```

React renders it as text rather than executing it.

Risk increases when using:

```tsx
dangerouslySetInnerHTML
```

Avoid:

```tsx
<div
  dangerouslySetInnerHTML={{
    __html: userSuppliedContent,
  }}
/>
```

unless content has been sanitized through a well-reviewed policy.

LaunchPad also uses a Content Security Policy to restrict resource origins.

---

## 12. Cross-Site Request Forgery Controls

Cross-Site Request Forgery, or CSRF, attempts to make an authenticated browser submit an unwanted request.

LaunchPad reduces risk with:

```text
- SameSite=Lax cookies
- No state-changing GET routes
- JSON content type requirements for APIs
- Server Action framework handling
- Authentication and authorization at every mutation
```

For high-risk actions, consider:

```text
- Explicit origin checks
- CSRF tokens
- Reauthentication before destructive operations
- Confirmation text
- Rate limiting
```

---

## 13. Sensitive Data in Logs

Logs are useful, but logging the wrong data creates another security incident.

Never log:

```text
- Passwords
- Password hashes
- Raw session tokens
- Cookie values
- Authorization headers
- Database URLs
- API keys
```

Safe log:

```ts
logError(
  "project_update_failed",
  error,
  {
    requestId,
    userId: user.id,
    projectId,
  },
);
```

Unsafe log:

```ts
console.error({
  password,
  sessionToken,
  authorization: request.headers.get("authorization"),
});
```

LaunchPad’s logger redacts suspicious key names automatically, but prevention is better than relying on redaction.

---

## 14. Security Testing Questions

For each private feature, test these cases.

### Anonymous caller

```text
Can a caller without a session access it?
```

Expected:

```text
Redirect for page or 401 for API.
```

### Authenticated non-owner

```text
Can User B access User A record by changing a UUID?
```

Expected:

```text
Not-found behavior.
```

### Malformed input

```text
Can invalid UUID, status, or JSON reach the database?
```

Expected:

```text
Validation failure.
```

### Replay and duplicate requests

```text
What happens if the same request is sent twice?
```

Expected:

```text
Defined behavior, ideally safe and understandable.
```

### Dependency failure

```text
What happens if PostgreSQL is unavailable?
```

Expected:

```text
Safe error behavior, readiness 503, structured log.
```

---

## 15. Security Review Questions Before Merge

Ask:

```text
1. What private data does this feature read or write?
2. Who is allowed to perform this action?
3. Where does identity come from?
4. Is ownership enforced in SQL?
5. Can the browser influence ownership?
6. Is every external value validated?
7. Does any secret reach browser code?
8. Does any sensitive value reach logs?
9. Does the feature introduce new cache behavior?
10. Can another user access this resource by changing an ID?
```

If any answer is unclear, the feature needs more design before merge.

---

## 16. Primer Completion Checklist

Before returning to the main series, you should understand:

- [ ] What a threat model is.
- [ ] What a trust boundary is.
- [ ] Why browser code is untrusted.
- [ ] Why authentication and authorization are different.
- [ ] Why authorization belongs in SQL.
- [ ] Why validation does not replace authorization.
- [ ] Why parameterized SQL matters.
- [ ] Why React escaping reduces XSS risk.
- [ ] Why raw HTML rendering is dangerous.
- [ ] How SameSite cookies contribute to CSRF defense.
- [ ] Why logs must redact secrets.
- [ ] How to test anonymous and cross-user access.
- [ ] How to threat-model a destructive feature.
- [ ] Which questions to ask during a security review.
