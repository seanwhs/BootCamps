# Appendix C: Database Schema, SQL, and API Reference

This appendix is a practical reference for LaunchPad’s PostgreSQL schema and HTTP API.

Use it when you need to:

- Inspect or troubleshoot database records
- Understand table relationships
- Write a new query safely
- Add a migration
- Call an API endpoint from another client
- Interpret API status codes and error envelopes

---

## C.1 Database Tables

LaunchPad uses five important PostgreSQL tables:

```text
users
sessions
projects
tasks
schema_migrations
```

Their relationships are:

```text
users
├── owns many projects
└── owns many sessions

projects
└── owns many tasks

schema_migrations
└── records applied database migrations
```

---

## C.2 `users` Table

The `users` table stores account identities.

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(100) NOT NULL,
  email VARCHAR(320) NOT NULL,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Important columns

| Column | Type | Purpose |
|---|---|---|
| `id` | UUID | Stable user identifier |
| `name` | VARCHAR(100) | Display name |
| `email` | VARCHAR(320) | Normalized account email |
| `password_hash` | TEXT | bcrypt password hash |
| `created_at` | TIMESTAMPTZ | Account creation timestamp |
| `updated_at` | TIMESTAMPTZ | Last account update timestamp |

### Security rules

Never return:

```text
password_hash
```

to:

- Client Components
- Browser JSON responses
- Logs
- Error messages
- Monitoring events

### Useful user queries

List safe user information:

```sql
SELECT
  id,
  name,
  email,
  created_at
FROM users
ORDER BY created_at DESC;
```

Find a user by email:

```sql
SELECT
  id,
  name,
  email
FROM users
WHERE email = lower(trim('demo@launchpad.local'));
```

Count projects by user:

```sql
SELECT
  u.email,
  COUNT(p.id) AS project_count
FROM users AS u
LEFT JOIN projects AS p
  ON p.owner_id = u.id
GROUP BY u.id
ORDER BY u.email;
```

---

## C.3 `sessions` Table

The `sessions` table stores revocable server-side authentication sessions.

```sql
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Important columns

| Column | Type | Purpose |
|---|---|---|
| `id` | UUID | Session record identifier |
| `user_id` | UUID | User who owns the session |
| `token_hash` | CHAR(64) | SHA-256 hash of the raw cookie token |
| `expires_at` | TIMESTAMPTZ | Server-side expiration |
| `created_at` | TIMESTAMPTZ | Session creation time |

### Why `token_hash` is 64 characters

A SHA-256 digest encoded as hexadecimal contains:

```text
64 characters
```

Example shape:

```text
a3f8d2...64-total-hex-characters...
```

The raw session token is stored only in the browser’s HTTP-only cookie.

### Useful session queries

List active sessions without exposing hashes:

```sql
SELECT
  u.email,
  s.created_at,
  s.expires_at
FROM sessions AS s
INNER JOIN users AS u
  ON u.id = s.user_id
WHERE s.expires_at > CURRENT_TIMESTAMP
ORDER BY s.created_at DESC;
```

Count active sessions per user:

```sql
SELECT
  u.email,
  COUNT(s.id) AS active_session_count
FROM users AS u
LEFT JOIN sessions AS s
  ON s.user_id = u.id
  AND s.expires_at > CURRENT_TIMESTAMP
GROUP BY u.id
ORDER BY u.email;
```

Delete expired sessions:

```sql
DELETE FROM sessions
WHERE expires_at <= CURRENT_TIMESTAMP;
```

Revoke every session for one user:

```sql
DELETE FROM sessions
WHERE user_id = 'USER_UUID_HERE';
```

Revoke every session in an emergency:

```sql
DELETE FROM sessions;
```

> This signs out every user.

---

## C.4 `projects` Table

The `projects` table stores user-owned project records.

```sql
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id UUID NOT NULL,
  name VARCHAR(120) NOT NULL,
  description TEXT NOT NULL,
  status VARCHAR(20) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Supported project statuses

```text
PLANNED
ACTIVE
COMPLETED
```

### Important constraints

```sql
CHECK (length(trim(name)) > 0)
CHECK (length(trim(description)) > 0)
CHECK (status IN ('PLANNED', 'ACTIVE', 'COMPLETED'))
```

### Important ownership relationship

```sql
FOREIGN KEY (owner_id)
REFERENCES users(id)
ON DELETE CASCADE
```

Deleting a user deletes that user’s projects. Project deletion cascades into task deletion.

### Useful project queries

List a user’s projects:

```sql
SELECT
  id,
  name,
  description,
  status,
  created_at,
  updated_at
FROM projects
WHERE owner_id = 'USER_UUID_HERE'
ORDER BY updated_at DESC;
```

List active projects for one user:

```sql
SELECT
  id,
  name,
  status,
  updated_at
FROM projects
WHERE owner_id = 'USER_UUID_HERE'
  AND status = 'ACTIVE'
ORDER BY updated_at DESC;
```

Read one project safely:

```sql
SELECT
  id,
  name,
  description,
  status
FROM projects
WHERE id = 'PROJECT_UUID_HERE'
  AND owner_id = 'USER_UUID_HERE';
```

This query should return zero rows when:

- The project does not exist.
- The project belongs to another user.

That is the intended privacy behavior.

---

## C.5 `tasks` Table

The `tasks` table stores project work items.

```sql
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL,
  title VARCHAR(160) NOT NULL,
  description TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'TODO',
  priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
  due_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

### Supported task statuses

```text
TODO
IN_PROGRESS
COMPLETED
```

### Supported task priorities

```text
LOW
MEDIUM
HIGH
```

### Important relationship

```sql
FOREIGN KEY (project_id)
REFERENCES projects(id)
ON DELETE CASCADE
```

Deleting a project deletes its tasks.

### Useful task queries

List tasks for an owned project:

```sql
SELECT
  t.id,
  t.title,
  t.status,
  t.priority,
  t.due_date
FROM tasks AS t
INNER JOIN projects AS p
  ON p.id = t.project_id
WHERE t.project_id = 'PROJECT_UUID_HERE'
  AND p.owner_id = 'USER_UUID_HERE'
ORDER BY
  CASE t.status
    WHEN 'IN_PROGRESS' THEN 1
    WHEN 'TODO' THEN 2
    WHEN 'COMPLETED' THEN 3
  END,
  t.due_date ASC NULLS LAST,
  t.created_at ASC;
```

Count task completion per project:

```sql
SELECT
  p.id,
  p.name,
  COUNT(t.id) AS task_count,
  COUNT(t.id) FILTER (
    WHERE t.status = 'COMPLETED'
  ) AS completed_task_count
FROM projects AS p
LEFT JOIN tasks AS t
  ON t.project_id = p.id
WHERE p.owner_id = 'USER_UUID_HERE'
GROUP BY p.id
ORDER BY p.updated_at DESC;
```

---

## C.6 `schema_migrations` Table

The migration runner creates this table automatically.

```sql
CREATE TABLE schema_migrations (
  filename TEXT PRIMARY KEY,
  checksum CHAR(64) NOT NULL,
  applied_at TIMESTAMPTZ NOT NULL
    DEFAULT CURRENT_TIMESTAMP
);
```

### Purpose

It records:

- Which migration filename was applied
- The SHA-256 checksum of that migration
- When it was applied

Example:

```sql
SELECT
  filename,
  checksum,
  applied_at
FROM schema_migrations
ORDER BY filename;
```

Expected result:

```text
001_create_projects_and_tasks.sql
002_add_users_sessions_and_ownership.sql
```

### Rule: do not edit applied migrations

If this file was already applied:

```text
001_create_projects_and_tasks.sql
```

do not edit it.

Create a new migration instead:

```text
003_add_project_archived_at.sql
```

---

## C.7 Important Database Indexes

LaunchPad includes indexes for common authenticated operations.

| Index | Supports |
|---|---|
| `users_email_unique_index` | Account lookup by email |
| `sessions_token_hash_unique_index` | Session lookup from cookie token hash |
| `sessions_user_id_index` | Revoking sessions by user |
| `sessions_expires_at_index` | Expired-session cleanup |
| `projects_owner_id_index` | Listing a user’s projects |
| `projects_owner_status_index` | Filtering a user’s projects by status |
| `tasks_project_id_index` | Listing tasks for a project |
| `tasks_project_status_index` | Task status operations by project |

Inspect them:

```sql
SELECT
  tablename,
  indexname,
  indexdef
FROM pg_indexes
WHERE tablename IN (
  'users',
  'sessions',
  'projects',
  'tasks'
)
ORDER BY tablename, indexname;
```

---

# C.8 Migration Workflow

## Create a new migration

Use a sequential filename:

```text
003_add_project_archived_at.sql
```

Example:

### `database/migrations/003_add_project_archived_at.sql`

```sql
BEGIN;

ALTER TABLE projects
  ADD COLUMN archived_at TIMESTAMPTZ;

CREATE INDEX projects_owner_archived_at_index
  ON projects(owner_id, archived_at);

COMMIT;
```

Apply it:

```bash
npm run db:migrate
```

Verify it:

```bash
npm run db:migrate
```

The second run should report that it was already applied.

## Migration design rules

1. Make changes backward-compatible when possible.
2. Add columns before removing old ones.
3. Avoid destructive schema changes in the same release that changes application code.
4. Review locks and table size before changing large production tables.
5. Never edit an applied migration.
6. Test on a production-like staging database before production.

---

# C.9 HTTP API Overview

LaunchPad exposes these JSON endpoints.

| Method | Route | Authentication | Purpose |
|---|---|---|---|
| `GET` | `/api/live` | Public | Process liveness |
| `GET` | `/api/health` | Public | Database readiness |
| `GET` | `/api/projects` | Required | List current user’s projects |
| `POST` | `/api/projects` | Required | Create a project |
| `GET` | `/api/projects/:projectId` | Required owner | Read a project |
| `PATCH` | `/api/projects/:projectId` | Required owner | Partially update a project |
| `DELETE` | `/api/projects/:projectId` | Required owner | Delete a project |

Private project APIs send:

```http
Cache-Control: private, no-store
Vary: Cookie
```

This prevents shared caches from storing or reusing user-specific results.

---

## C.10 API Success Envelope

Successful JSON responses use:

```json
{
  "data": {}
}
```

Example project response:

```json
{
  "data": {
    "id": "10000000-0000-4000-8000-000000000001",
    "name": "Website redesign",
    "description": "Refresh the marketing website.",
    "status": "ACTIVE",
    "taskCount": 4,
    "completedTaskCount": 2
  }
}
```

---

## C.11 API Error Envelope

Errors use:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The project input is invalid.",
    "details": [
      {
        "path": "name",
        "message": "Enter a project name."
      }
    ]
  }
}
```

### Error codes

| Code | Meaning |
|---|---|
| `BAD_REQUEST` | Request content type or structure is invalid |
| `INVALID_JSON` | Request body cannot be parsed as JSON |
| `VALIDATION_ERROR` | Parsed request values violate validation rules |
| `UNAUTHORIZED` | No valid authenticated session |
| `FORBIDDEN` | Authenticated caller lacks permission where disclosure is acceptable |
| `NOT_FOUND` | Resource does not exist or may not be discovered |
| `INTERNAL_ERROR` | Unexpected server failure |
| `SERVICE_UNAVAILABLE` | Required dependency is unavailable |

---

## C.12 Public Health API

### Liveness

```http
GET /api/live
```

Example response:

```json
{
  "data": {
    "status": "alive",
    "checkedAt": "2026-07-26T12:00:00.000Z",
    "version": "development"
  }
}
```

Expected status:

```text
200
```

---

### Readiness

```http
GET /api/health
```

Healthy example:

```json
{
  "data": {
    "status": "ok",
    "database": "reachable",
    "checkedAt": "2026-07-26T12:00:00.000Z",
    "version": "development"
  }
}
```

Expected status:

```text
200
```

If PostgreSQL is unavailable:

```json
{
  "error": {
    "code": "SERVICE_UNAVAILABLE",
    "message": "A required application service is unavailable.",
    "details": {
      "status": "degraded",
      "checkedAt": "2026-07-26T12:00:00.000Z",
      "version": "development"
    }
  }
}
```

Expected status:

```text
503
```

---

# C.13 Project Collection API

## List projects

```http
GET /api/projects
```

Authentication is required.

Optional filter:

```http
GET /api/projects?status=ACTIVE
```

Example:

```bash
curl --fail --silent \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  "http://localhost:3000/api/projects?status=ACTIVE" |
  python -m json.tool
```

Expected status:

```text
200
```

---

## Create a project

```http
POST /api/projects
Content-Type: application/json
```

Request body:

```json
{
  "name": "Mobile release planning",
  "description": "Coordinate the first mobile launch.",
  "status": "PLANNED"
}
```

Example:

```bash
curl --fail --silent \
  --request POST \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  --header "Content-Type: application/json" \
  --data '{
    "name": "Mobile release planning",
    "description": "Coordinate the first mobile launch.",
    "status": "PLANNED"
  }' \
  http://localhost:3000/api/projects |
  python -m json.tool
```

Expected status:

```text
201
```

The server derives ownership from the authenticated session. The request body must not contain:

```json
{
  "ownerId": "..."
}
```

---

# C.14 Individual Project API

Assume:

```bash
PROJECT_ID='10000000-0000-4000-8000-000000000001'
```

## Read one project

```http
GET /api/projects/:projectId
```

```bash
curl --fail --silent \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  "http://localhost:3000/api/projects/${PROJECT_ID}" |
  python -m json.tool
```

Expected status:

```text
200
```

If the project belongs to another user:

```text
404
```

---

## Partially update a project

```http
PATCH /api/projects/:projectId
Content-Type: application/json
```

Example:

```bash
curl --fail --silent \
  --request PATCH \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  --header "Content-Type: application/json" \
  --data '{
    "status": "COMPLETED"
  }' \
  "http://localhost:3000/api/projects/${PROJECT_ID}" |
  python -m json.tool
```

Supported partial fields:

```json
{
  "name": "Updated project name",
  "description": "Updated description.",
  "status": "ACTIVE"
}
```

At least one field is required.

---

## Delete a project

```http
DELETE /api/projects/:projectId
```

```bash
curl --silent \
  --request DELETE \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  "http://localhost:3000/api/projects/${PROJECT_ID}"
```

Expected status:

```text
204
```

Deleting the project also deletes related tasks through:

```sql
ON DELETE CASCADE
```

---

# C.15 Common API Status Codes

| Status | Meaning in LaunchPad |
|---:|---|
| `200` | Successful read or update |
| `201` | Project successfully created |
| `204` | Project deleted successfully |
| `400` | Malformed JSON, invalid content type, or invalid identifier |
| `401` | Missing or invalid authenticated session |
| `404` | Missing resource or resource owned by another user |
| `422` | Valid JSON but invalid project fields |
| `500` | Unexpected server-side failure |
| `503` | PostgreSQL or another required dependency is unavailable |

---

# C.16 API Troubleshooting

## `401 UNAUTHORIZED`

Cause:

```text
No valid launchpad_session cookie was sent.
```

Check:

```bash
curl --silent \
  --dump-header - \
  --output /dev/null \
  http://localhost:3000/api/projects
```

Sign in through the browser, then provide the cookie when testing manually:

```bash
curl \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  http://localhost:3000/api/projects
```

---

## `404 NOT_FOUND` for a valid UUID

Possible causes:

- The project does not exist.
- The project belongs to another user.
- The session belongs to a different account.
- The project was deleted.

This ambiguity is intentional for private-resource protection.

---

## `422 VALIDATION_ERROR`

Example invalid payload:

```json
{
  "name": "",
  "description": "",
  "status": "UNKNOWN"
}
```

Inspect the `details` array in the API response.

Correct payload:

```json
{
  "name": "Valid name",
  "description": "A non-empty project description.",
  "status": "PLANNED"
}
```

---

## `503 SERVICE_UNAVAILABLE`

Cause:

```text
PostgreSQL is not reachable.
```

Check:

```bash
npm run db:status
```

Then:

```bash
npm run db:start
```

Verify:

```bash
curl --fail --silent \
  http://localhost:3000/api/health |
  python -m json.tool
```

---

# C.17 Safe Query Patterns

## Safe project lookup

```ts
const project = await getProjectById(
  user.id,
  projectId,
);
```

The query must include both user and project identity.

---

## Safe project creation

```ts
const project = await createProject(
  user.id,
  parsedInput.data,
);
```

The user ID comes from the authenticated server session, not the request body.

---

## Safe task update

```ts
const task = await updateTaskStatus(
  user.id,
  projectId,
  taskId,
  parsedInput.data,
);
```

The database statement verifies:

```text
- the user owns the project
- the project contains the task
- the requested task exists
```

---

# C.18 Unsafe Patterns to Avoid

## Trusting an owner ID from JSON

Unsafe:

```ts
const ownerId = body.ownerId;

await createProject(ownerId, input);
```

Correct:

```ts
const user = await requireApiUser();

if (!user) {
  return unauthorizedResponse;
}

await createProject(user.id, input);
```

---

## Concatenating SQL strings

Unsafe:

```ts
database.unsafe(
  `SELECT * FROM projects WHERE id = '${projectId}'`,
);
```

Correct:

```ts
database`
  SELECT *
  FROM projects
  WHERE id = ${projectId}
`;
```

---

## Fetching all projects and filtering in the browser

Unsafe:

```tsx
const visibleProjects = allProjects.filter(
  (project) => project.ownerId === currentUser.id,
);
```

By then, every project may already have reached the browser.

Correct:

```text
Server authenticates user
      ↓
Database query filters owner_id
      ↓
Browser receives only authorized records
```

---

# C.19 Database Inspection Cheat Sheet

### Count records

```sql
SELECT
  (SELECT COUNT(*) FROM users) AS users,
  (SELECT COUNT(*) FROM sessions) AS sessions,
  (SELECT COUNT(*) FROM projects) AS projects,
  (SELECT COUNT(*) FROM tasks) AS tasks;
```

### Find orphaned tasks

This should return zero rows because the foreign key prevents orphans:

```sql
SELECT
  t.id,
  t.title
FROM tasks AS t
LEFT JOIN projects AS p
  ON p.id = t.project_id
WHERE p.id IS NULL;
```

### Find projects without owners

This should return zero rows:

```sql
SELECT
  id,
  name
FROM projects
WHERE owner_id IS NULL;
```

### Find expired sessions

```sql
SELECT
  id,
  user_id,
  expires_at
FROM sessions
WHERE expires_at <= CURRENT_TIMESTAMP;
```

### Review project progress

```sql
SELECT
  p.name,
  COUNT(t.id) AS task_count,
  COUNT(t.id) FILTER (
    WHERE t.status = 'COMPLETED'
  ) AS completed_task_count,
  CASE
    WHEN COUNT(t.id) = 0 THEN 0
    ELSE ROUND(
      COUNT(t.id) FILTER (
        WHERE t.status = 'COMPLETED'
      )::numeric
      / COUNT(t.id)::numeric
      * 100
    )
  END AS completion_percentage
FROM projects AS p
LEFT JOIN tasks AS t
  ON t.project_id = p.id
GROUP BY p.id
ORDER BY p.updated_at DESC;
```
