# Appendix D: Security and Authentication Reference

This appendix collects LaunchPad’s security model in one place.

Use it when you need to answer questions such as:

- How are passwords protected?
- Where is the session stored?
- Why is the session token hashed?
- How does the application prevent one user from accessing another user’s project?
- What is the difference between `401`, `403`, and `404`?
- Which security controls are already implemented?
- Which controls should be added before a high-risk public launch?

---

## D.1 Security Model Overview

LaunchPad applies multiple layers of protection.

```text
Browser
│
├── HTTPS in production
├── HTTP-only session cookie
├── SameSite cookie policy
├── Client-side validation for usability
└── No credentials in localStorage
        │
        ▼
Next.js Server
│
├── Environment validation
├── Server Action validation
├── Route Handler validation
├── Session lookup
├── Authentication
├── Authorization
├── Structured logging with redaction
└── Security headers
        │
        ▼
PostgreSQL
│
├── Foreign keys
├── Check constraints
├── Unique email constraint
├── Owner-scoped queries
├── Owner-scoped mutations
└── Session expiration
```

No one layer is sufficient by itself.

For example:

- An HTTP-only cookie does not replace authorization.
- A hidden button does not replace server checks.
- Zod validation does not replace database constraints.
- A database foreign key does not replace authentication.
- HTTPS does not replace password hashing.

This is called **defense in depth**.

---

# D.2 Threat Model

A **threat model** identifies what could go wrong, who might cause it, and which controls reduce the risk.

LaunchPad’s basic threat model includes:

| Threat | Example | Primary defenses |
|---|---|---|
| Unauthorized project access | User B guesses User A’s project UUID | Owner-scoped SQL |
| Session theft | Script reads session token | HTTP-only cookies |
| Password exposure | Database dump contains credentials | bcrypt password hashes |
| Session-table exposure | Database dump contains session rows | Token hashes, not raw tokens |
| SQL injection | Attacker manipulates a project ID | Parameterized SQL, validation |
| Invalid form data | Caller bypasses HTML validation | Zod server validation |
| Cross-site request forgery | Another site submits an authenticated mutation | SameSite cookies, JSON-only APIs, server checks |
| Clickjacking | Malicious page frames LaunchPad | CSP frame policy, `X-Frame-Options` |
| MIME confusion | Browser interprets content unexpectedly | `X-Content-Type-Options: nosniff` |
| Secret leakage | Logs contain a database URL | Structured logger redaction |
| Stale private data | Shared cache returns another user’s API response | `private, no-store`, `Vary: Cookie` |
| Brute-force sign-in attempts | Repeated password guesses | Not yet complete: add distributed rate limiting |

The final row is important: LaunchPad has foundational authentication controls, but production systems should add rate limiting before a broad public launch.

---

# D.3 Password Protection

## Passwords are never stored as plaintext

Unsafe storage:

```text
email: demo@launchpad.local
password: LaunchPadDemo123!
```

Safe storage conceptually looks like:

```text
email: demo@launchpad.local
password_hash: $2b$12$...
```

LaunchPad uses `bcryptjs`:

```ts
import { compare, hash } from "bcryptjs";
```

During registration:

```ts
const passwordHash = await hash(input.password, 12);
```

During sign-in:

```ts
const passwordMatches = await compare(
  password,
  account.passwordHash,
);
```

The plaintext password is used only briefly in memory during validation and comparison.

## Why bcrypt is appropriate

bcrypt is designed for passwords.

It is:

- Salted
- One-way
- Deliberately slow
- Configurable through a work factor

LaunchPad uses a work factor of:

```text
12
```

Higher values increase resistance to offline password guessing but also require more server CPU during legitimate registration and sign-in.

Production teams should periodically benchmark and increase the cost as hardware improves.

## Password requirements

LaunchPad registration requires:

- At least 12 characters
- At least one lowercase character
- At least one uppercase character
- At least one digit
- At least one symbol
- No more than 128 characters

The server schema enforces these requirements:

```ts
const passwordSchema = z
  .string()
  .min(12)
  .max(128)
  .regex(/[a-z]/)
  .regex(/[A-Z]/)
  .regex(/\d/)
  .regex(/[^A-Za-z0-9]/);
```

Client-side attributes such as `minLength={12}` improve usability, but the schema remains authoritative.

---

# D.4 Session Architecture

LaunchPad uses database-backed sessions.

```text
Browser cookie
      ↓
Raw random token
      ↓ SHA-256
Token hash
      ↓
sessions table
      ↓
User record
```

## Session creation

```ts
const token = randomBytes(32).toString("base64url");
```

This creates 32 random bytes, or 256 bits of entropy.

The application hashes the token:

```ts
const tokenHash = createHash("sha256")
  .update(token)
  .digest("hex");
```

Then it stores only the hash:

```ts
await insertSession(userId, tokenHash, expiresAt);
```

The browser receives the raw token through a cookie.

## Why store a token hash

Suppose an attacker gains read access to the `sessions` table.

Unsafe session storage:

```text
token: actual-browser-cookie-value
```

The attacker could copy the value into a browser cookie and impersonate the user.

LaunchPad stores:

```text
token_hash: SHA-256(actual-browser-cookie-value)
```

The hash cannot practically be converted back into the original random token.

---

# D.5 Session Cookie Configuration

LaunchPad writes the cookie with this policy:

```ts
cookieStore.set("launchpad_session", token, {
  httpOnly: true,
  secure: process.env.NODE_ENV === "production",
  sameSite: "lax",
  path: "/",
  expires: expiresAt,
});
```

## `httpOnly: true`

JavaScript running in the browser cannot read the cookie through:

```js
document.cookie
```

That reduces some session-token theft risk from cross-site scripting.

It does **not** make XSS harmless. Malicious JavaScript on an authenticated page may still issue requests as the current user.

## `secure: true` in production

Secure cookies are sent only over HTTPS.

Production environments must use HTTPS.

## `sameSite: "lax"`

SameSite Lax reduces cookie sending during many cross-site requests while allowing ordinary top-level navigation.

It contributes to CSRF defense but is not a complete substitute for careful mutation design.

## `path: "/"`

The cookie applies throughout the application:

```text
/dashboard
/projects
/api/projects
```

## Expiration

LaunchPad sessions expire after seven days.

The database expiration is authoritative:

```sql
WHERE expires_at > CURRENT_TIMESTAMP
```

A browser may still contain an old cookie, but the server rejects it when its database session has expired.

---

# D.6 Authentication Flow

```text
1. User submits email and password
             ↓
2. Server validates input format
             ↓
3. Server looks up normalized email
             ↓
4. bcrypt compares password to stored hash
             ↓
5. Server creates random session token
             ↓
6. Server stores SHA-256 token hash
             ↓
7. Browser receives HTTP-only cookie
             ↓
8. Future request includes cookie
             ↓
9. Server hashes cookie value
             ↓
10. Server finds non-expired session
             ↓
11. Server loads authenticated user
```

The main server helper is:

```ts
const user = await getCurrentUser();
```

Protected routes use:

```ts
const user = await requireUser();
```

If no valid session exists:

```ts
redirect("/sign-in");
```

Private JSON API routes use:

```ts
const user = await requireApiUser();

if (!user) {
  return apiError(
    401,
    "UNAUTHORIZED",
    "Authentication is required.",
  );
}
```

---

# D.7 Authentication Versus Authorization

These are different checks.

## Authentication

Authentication asks:

```text
Who is making this request?
```

Example:

```ts
const user = await requireUser();
```

## Authorization

Authorization asks:

```text
May this user access this specific resource?
```

Example:

```ts
const project = await getProjectById(
  user.id,
  projectId,
);
```

The SQL query includes both values:

```sql
WHERE p.id = $project_id
  AND p.owner_id = $user_id
```

A valid session does not automatically grant access to every project.

---

# D.8 Owner-Scoped Database Access

Private projects must always be queried through the authenticated owner.

## Read one project

Correct:

```sql
SELECT
  p.id,
  p.name,
  p.description,
  p.status
FROM projects AS p
WHERE p.id = $project_id
  AND p.owner_id = $user_id;
```

Incorrect:

```sql
SELECT *
FROM projects
WHERE id = $project_id;
```

The incorrect query retrieves a project before deciding whether the user should see it.

## Update a project

Correct:

```sql
UPDATE projects
SET
  status = $status,
  updated_at = CURRENT_TIMESTAMP
WHERE id = $project_id
  AND owner_id = $user_id;
```

## Delete a project

Correct:

```sql
DELETE FROM projects
WHERE id = $project_id
  AND owner_id = $user_id;
```

## Update a task through project ownership

Correct:

```sql
UPDATE tasks AS t
SET
  status = $status,
  updated_at = CURRENT_TIMESTAMP
FROM projects AS p
WHERE t.id = $task_id
  AND t.project_id = $project_id
  AND p.id = t.project_id
  AND p.owner_id = $user_id;
```

The task mutation proves all of these conditions in one statement:

```text
- The task exists.
- The task belongs to the specified project.
- The project belongs to the current user.
```

---

# D.9 Why Unauthorized Private Records Return `404`

When a signed-in user requests a project they do not own, LaunchPad returns:

```text
404 Not Found
```

instead of:

```text
403 Forbidden
```

This deliberately avoids confirming that another user’s private project exists.

For a private project ID, these outcomes should look the same to an unauthorized caller:

```text
- The project does not exist.
- The project exists but belongs to another user.
```

This pattern is appropriate when resource existence itself is private.

---

# D.10 API Security Rules

Private project API routes require a session:

```text
GET    /api/projects
POST   /api/projects
GET    /api/projects/:projectId
PATCH  /api/projects/:projectId
DELETE /api/projects/:projectId
```

Anonymous requests receive:

```http
401 Unauthorized
Cache-Control: private, no-store
Vary: Cookie
```

The API does not accept an ownership field:

```json
{
  "ownerId": "..."
}
```

Instead, ownership comes from the server session:

```ts
const user = await requireApiUser();

await createProject(user.id, parsedInput.data);
```

Never permit a client to decide who owns a new record.

---

# D.11 Server Action Security Rules

Server Actions are server entry points, not private helper functions.

Every protected action must:

1. Load the authenticated user.
2. Validate bound route IDs.
3. Validate submitted form values.
4. Call owner-scoped mutations.
5. Return safe user-facing errors.
6. Avoid returning secrets or raw exceptions.

Correct project creation action shape:

```ts
"use server";

export async function createProjectAction(
  previousState: FormActionState,
  formData: FormData,
): Promise<FormActionState> {
  const user = await requireUser();

  const parsedInput = createProjectInputSchema.safeParse({
    name: formData.get("name"),
    description: formData.get("description"),
    status: formData.get("status"),
  });

  if (!parsedInput.success) {
    return {
      status: "error",
      message: "Correct the highlighted project fields.",
    };
  }

  await createProject(user.id, parsedInput.data);

  return {
    status: "success",
  };
}
```

Unsafe action:

```ts
"use server";

export async function deleteProjectAction(
  projectId: string,
) {
  await deleteProject(projectId);
}
```

Problems:

```text
- No authentication
- No identifier validation
- No ownership condition
- No safe error handling
```

---

# D.12 Input Validation Layers

LaunchPad validates at several layers.

## Browser HTML validation

Example:

```tsx
<input
  required
  maxLength={120}
/>
```

Purpose:

```text
Fast user feedback
```

Limitation:

```text
Can be bypassed
```

## Zod server validation

Example:

```ts
createProjectInputSchema.safeParse(input);
```

Purpose:

```text
Validate all server entry-point input
```

## Database constraints

Example:

```sql
CHECK (length(trim(name)) > 0)
```

Purpose:

```text
Protect persistent data regardless of caller
```

## Owner-scoped SQL

Example:

```sql
WHERE owner_id = $user_id
```

Purpose:

```text
Authorize access at the data boundary
```

Each layer solves a distinct problem.

---

# D.13 SQL Injection Prevention

Never build SQL by concatenating input.

Unsafe:

```ts
const query = `
  SELECT *
  FROM projects
  WHERE id = '${projectId}'
`;
```

A malicious value could alter query syntax.

LaunchPad uses parameterized tagged templates:

```ts
const rows = await database`
  SELECT
    id,
    name
  FROM projects
  WHERE id = ${projectId}
    AND owner_id = ${userId}
`;
```

The driver sends values separately from the SQL program.

Validation still matters because parameterization prevents injection but does not enforce business rules.

---

# D.14 Cross-Site Request Forgery

**Cross-Site Request Forgery**, or CSRF, attempts to make a victim’s browser send an authenticated request from another website.

LaunchPad uses several protections:

```text
- SameSite=Lax session cookies
- No state-changing GET routes
- JSON content-type requirements for API mutations
- Server Action request handling
- Authentication and authorization at mutation boundaries
```

For higher-risk systems, evaluate additional controls:

```text
- Origin validation
- CSRF tokens
- Strict CORS policy
- Double-submit cookie patterns
- Step-up authentication for sensitive actions
```

Do not assume SameSite alone solves every CSRF risk.

---

# D.15 Cross-Site Scripting

**Cross-Site Scripting**, or XSS, occurs when untrusted content becomes executable browser code.

LaunchPad reduces XSS risk through:

- React’s default text escaping
- No raw HTML rendering of user project or task text
- Content Security Policy
- HTTP-only session cookies
- No session token in local storage

Avoid introducing unsafe rendering such as:

```tsx
<div
  dangerouslySetInnerHTML={{
    __html: userSuppliedContent,
  }}
/>
```

If rich text becomes a requirement, sanitize it with a mature, actively maintained sanitizer and define a strict allowed-content policy.

---

# D.16 Security Headers

LaunchPad configures these headers.

| Header | Purpose |
|---|---|
| `Content-Security-Policy` | Restricts allowed resource sources |
| `Strict-Transport-Security` | Instructs browsers to prefer HTTPS |
| `X-Content-Type-Options: nosniff` | Prevents MIME-type guessing |
| `X-Frame-Options: DENY` | Helps prevent clickjacking |
| `Referrer-Policy` | Restricts referrer-data sharing |
| `Permissions-Policy` | Disables unused browser capabilities |
| `Cross-Origin-Opener-Policy` | Isolates top-level browsing context |

Inspect them:

```bash
curl --silent \
  --dump-header - \
  --output /dev/null \
  https://your-production-domain.example.com
```

---

# D.17 Logging Safety

LaunchPad’s logger redacts context keys that resemble sensitive data:

```text
password
secret
token
cookie
authorization
database_url
```

Safe logging example:

```ts
logError(
  "project_creation_failed",
  error,
  {
    requestId,
    userId: user.id,
    projectId,
  },
);
```

Unsafe logging example:

```ts
console.error({
  password,
  sessionToken,
  databaseUrl: process.env.DATABASE_URL,
});
```

Avoid logging full project descriptions or other personal data unless your retention and privacy policy explicitly allows it.

---

# D.18 Session Incident Response

## Revoke one user’s sessions

```sql
DELETE FROM sessions
WHERE user_id = 'USER_UUID_HERE';
```

## Revoke all sessions

```sql
DELETE FROM sessions;
```

## Respond to suspected session exposure

1. Revoke affected sessions.
2. Review logs for suspicious activity.
3. Identify the exposure source.
4. Rotate relevant credentials.
5. Notify affected users where required.
6. Record timeline and corrective actions.
7. Add monitoring or controls that would detect recurrence.

---

# D.19 Required Security Follow-Up Before Broad Public Launch

LaunchPad’s current foundation is strong, but a high-risk or broad public deployment should add:

1. **Distributed sign-in rate limiting**  
   Limit repeated credential attempts across all instances.

2. **Password reset flow**  
   Use short-lived, single-use reset tokens.

3. **Email verification**  
   Verify users control their registration email.

4. **Multi-factor authentication**  
   Add when the risk profile requires it.

5. **Account recovery procedures**  
   Define support and identity-verification rules.

6. **Audit logging**  
   Record sensitive actions such as project deletion, account changes, and bulk session revocation.

7. **Security monitoring**  
   Alert on unusual sign-in failures, session behavior, and authorization anomalies.

8. **Dependency scanning**  
   Monitor package and container vulnerabilities.

9. **Penetration testing**  
   Test authentication, authorization, XSS, CSRF, injection, and infrastructure controls.

10. **Nonce-based Content Security Policy**  
    Reduce reliance on broad inline-script allowances after compatibility testing.

---

# D.20 Security Review Checklist

Before releasing a significant authentication or authorization change, verify:

- [ ] Passwords are bcrypt hashes, never plaintext.
- [ ] Raw session tokens are not stored in PostgreSQL.
- [ ] Session cookies are HTTP-only.
- [ ] Production cookies are Secure.
- [ ] Session expiration is validated server-side.
- [ ] Sign-out deletes the server-side session.
- [ ] API routes authenticate independently of page layouts.
- [ ] Server Actions authenticate independently of page layouts.
- [ ] Project reads include `owner_id`.
- [ ] Project updates include `owner_id`.
- [ ] Project deletes include `owner_id`.
- [ ] Task mutations authorize through the owning project.
- [ ] User identity is derived from the session, not request JSON.
- [ ] Unauthorized private resources return `404`.
- [ ] Private API responses use `private, no-store`.
- [ ] Logs do not include credentials or tokens.
- [ ] Security headers are present in production.
- [ ] Production is served over HTTPS.
- [ ] Cross-user isolation is tested with two real test accounts.
- [ ] Expired sessions are rejected.
- [ ] Development seed data is never run in production.
- [ ] Rate limiting is planned or implemented for public sign-in.
