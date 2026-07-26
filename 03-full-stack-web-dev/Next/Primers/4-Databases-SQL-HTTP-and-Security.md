# Primer 4: Databases, SQL, HTTP, and Security Foundations

This primer prepares you for LaunchPad’s full-stack and security layers.

You will learn:

- What a relational database is
- Tables, rows, columns, primary keys, and foreign keys
- Basic SQL queries
- `SELECT`, `INSERT`, `UPDATE`, and `DELETE`
- Database constraints and indexes
- HTTP requests and responses
- API methods and status codes
- Authentication versus authorization
- Why validation and parameterized SQL matter
- Cookies and sessions
- Environment variables and secrets

---

## 1. What Is a Database?

A database stores information so it survives after an application restarts.

Without a database, this project array disappears whenever the server restarts:

```ts
const projects = [
  {
    id: "project-1",
    name: "Website redesign",
  },
];
```

A database stores the same information persistently:

```text
projects table
┌────────────┬────────────────────┐
│ id         │ name               │
├────────────┼────────────────────┤
│ project-1  │ Website redesign   │
└────────────┴────────────────────┘
```

LaunchPad uses PostgreSQL, a relational database.

---

## 2. Tables, Rows, and Columns

Think of a database table like a spreadsheet with strict rules.

### Table

A table groups related records.

```text
projects
tasks
users
sessions
```

### Column

A column describes one type of value.

```text
projects
├── id
├── owner_id
├── name
├── description
└── status
```

### Row

A row is one record.

```text
projects
┌──────────────────────────────────────┬──────────────────┬────────┐
│ id                                   │ name             │ status │
├──────────────────────────────────────┼──────────────────┼────────┤
│ 10000000-0000-4000-8000-000000000001 │ Website redesign │ ACTIVE │
└──────────────────────────────────────┴──────────────────┴────────┘
```

---

## 3. SQL

**SQL** means Structured Query Language.

SQL is the language used to:

```text
- Read records
- Create records
- Update records
- Delete records
- Create tables
- Add indexes
- Define constraints
```

SQL keywords are often written in uppercase for readability:

```sql
SELECT
  id,
  name
FROM projects;
```

PostgreSQL does not require uppercase keywords, but using them makes queries easier to scan.

---

## 4. Reading Data with `SELECT`

Read every project:

```sql
SELECT
  id,
  name,
  description,
  status
FROM projects;
```

Read selected columns only:

```sql
SELECT
  name,
  status
FROM projects;
```

Read one project by identifier:

```sql
SELECT
  id,
  name,
  description,
  status
FROM projects
WHERE id = '10000000-0000-4000-8000-000000000001';
```

The `WHERE` clause filters rows.

Without `WHERE`, a query may return every row in the table.

---

## 5. Creating Data with `INSERT`

Create a project:

```sql
INSERT INTO projects (
  owner_id,
  name,
  description,
  status
)
VALUES (
  '30000000-0000-4000-8000-000000000001',
  'Mobile release planning',
  'Coordinate the first mobile launch.',
  'PLANNED'
);
```

The column list explains exactly where each value belongs.

This is clearer and safer than relying on table column order:

```sql
INSERT INTO projects
VALUES (...);
```

---

## 6. Updating Data with `UPDATE`

Change a project status:

```sql
UPDATE projects
SET
  status = 'COMPLETED',
  updated_at = CURRENT_TIMESTAMP
WHERE id = '10000000-0000-4000-8000-000000000001';
```

Always inspect `WHERE` clauses carefully.

This query is dangerous:

```sql
UPDATE projects
SET status = 'COMPLETED';
```

It updates every project.

LaunchPad adds ownership to private mutations:

```sql
UPDATE projects
SET
  status = 'COMPLETED',
  updated_at = CURRENT_TIMESTAMP
WHERE id = '10000000-0000-4000-8000-000000000001'
  AND owner_id = '30000000-0000-4000-8000-000000000001';
```

That condition ensures one user cannot update another user’s project.

---

## 7. Deleting Data with `DELETE`

Delete one project:

```sql
DELETE FROM projects
WHERE id = '10000000-0000-4000-8000-000000000001';
```

LaunchPad uses a safer owner-scoped deletion:

```sql
DELETE FROM projects
WHERE id = '10000000-0000-4000-8000-000000000001'
  AND owner_id = '30000000-0000-4000-8000-000000000001';
```

A deletion returns no record unless you request one with:

```sql
RETURNING id;
```

Example:

```sql
DELETE FROM projects
WHERE id = '10000000-0000-4000-8000-000000000001'
  AND owner_id = '30000000-0000-4000-8000-000000000001'
RETURNING id;
```

If the query returns no row, the project may be missing or not owned by that user.

---

## 8. Primary Keys

A **primary key** uniquely identifies each row.

LaunchPad uses UUIDs:

```sql
id UUID PRIMARY KEY DEFAULT gen_random_uuid()
```

A UUID looks like:

```text
10000000-0000-4000-8000-000000000001
```

A primary key must be unique.

This is invalid if the ID already exists:

```sql
INSERT INTO projects (
  id,
  owner_id,
  name,
  description,
  status
)
VALUES (
  '10000000-0000-4000-8000-000000000001',
  '30000000-0000-4000-8000-000000000001',
  'Duplicate',
  'This attempts to reuse an existing ID.',
  'PLANNED'
);
```

PostgreSQL rejects the duplicate primary key.

---

## 9. Foreign Keys

A **foreign key** connects records across tables.

A task belongs to a project:

```sql
project_id UUID NOT NULL
```

The database enforces that relationship:

```sql
FOREIGN KEY (project_id)
REFERENCES projects(id)
ON DELETE CASCADE
```

This means:

```text
Task.project_id
    ↓
must reference
    ↓
Project.id
```

A task cannot reference a project that does not exist.

---

## 10. Cascade Deletion

LaunchPad uses:

```sql
ON DELETE CASCADE
```

When a project is deleted:

```text
Project deleted
    ↓
Related tasks deleted automatically
```

When a user is deleted:

```text
User deleted
    ↓
Owned projects deleted
    ↓
Project tasks deleted
```

Cascade behavior is powerful. Choose it deliberately.

Do not use it for relationships where records should remain for historical or legal reasons.

---

## 11. Database Constraints

A **constraint** is a database-enforced rule.

LaunchPad project status constraint:

```sql
CHECK (
  status IN (
    'PLANNED',
    'ACTIVE',
    'COMPLETED'
  )
)
```

This query fails:

```sql
INSERT INTO projects (
  owner_id,
  name,
  description,
  status
)
VALUES (
  '30000000-0000-4000-8000-000000000001',
  'Invalid status project',
  'This record has an unsupported status.',
  'STARTED'
);
```

The database protects its data even if a future application bug bypasses form validation.

---

## 12. Indexes

An **index** helps PostgreSQL find rows more efficiently.

Example:

```sql
CREATE INDEX projects_owner_status_index
  ON projects(owner_id, status);
```

This supports a query like:

```sql
SELECT
  id,
  name,
  status
FROM projects
WHERE owner_id = '30000000-0000-4000-8000-000000000001'
  AND status = 'ACTIVE';
```

An index is like the index at the back of a book:

```text
Without index:
Read many pages to find a topic.

With index:
Jump near the relevant page quickly.
```

Indexes have costs:

```text
- Use storage
- Slow inserts slightly
- Slow updates slightly
- Require maintenance
```

Add them for real query patterns, not every column automatically.

---

## 13. Joining Tables

A **join** combines related data from several tables.

List tasks with their project names:

```sql
SELECT
  t.title AS task_title,
  t.status AS task_status,
  p.name AS project_name
FROM tasks AS t
INNER JOIN projects AS p
  ON p.id = t.project_id;
```

The aliases:

```sql
tasks AS t
projects AS p
```

make longer queries easier to read.

LaunchPad uses joins to verify task access through project ownership:

```sql
SELECT
  t.id,
  t.title
FROM tasks AS t
INNER JOIN projects AS p
  ON p.id = t.project_id
WHERE t.project_id = 'PROJECT_UUID_HERE'
  AND p.owner_id = 'USER_UUID_HERE';
```

---

## 14. Aggregate Functions

Aggregate functions calculate a value from several rows.

Count tasks:

```sql
SELECT
  COUNT(*) AS task_count
FROM tasks;
```

Count completed tasks:

```sql
SELECT
  COUNT(*) AS completed_task_count
FROM tasks
WHERE status = 'COMPLETED';
```

LaunchPad calculates task totals per project:

```sql
SELECT
  p.name,
  COUNT(t.id) AS task_count,
  COUNT(t.id) FILTER (
    WHERE t.status = 'COMPLETED'
  ) AS completed_task_count
FROM projects AS p
LEFT JOIN tasks AS t
  ON t.project_id = p.id
GROUP BY p.id;
```

---

## 15. `INNER JOIN` Versus `LEFT JOIN`

### `INNER JOIN`

Returns only rows with matches on both sides.

```sql
SELECT
  t.title,
  p.name
FROM tasks AS t
INNER JOIN projects AS p
  ON p.id = t.project_id;
```

Every task must have a matching project.

### `LEFT JOIN`

Returns every row from the left table, even when no match exists.

```sql
SELECT
  p.name,
  t.title
FROM projects AS p
LEFT JOIN tasks AS t
  ON t.project_id = p.id;
```

A project with no tasks still appears.

LaunchPad uses `LEFT JOIN` when calculating project task counts because a new project with zero tasks should still be visible.

---

# 16. HTTP: Browser-to-Server Communication

**HTTP** is the protocol browsers and servers use to communicate.

A request includes:

```text
Method
URL
Headers
Optional body
```

A response includes:

```text
Status code
Headers
Optional body
```

Example:

```http
GET /api/projects HTTP/1.1
Host: localhost:3000
Cookie: launchpad_session=...
```

Example response:

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "data": []
}
```

---

## 17. HTTP Methods

### `GET`

Read information.

```http
GET /api/projects
```

Should not intentionally change data.

### `POST`

Create information or trigger non-idempotent work.

```http
POST /api/projects
```

### `PATCH`

Partially update information.

```http
PATCH /api/projects/:projectId
```

### `DELETE`

Remove information.

```http
DELETE /api/projects/:projectId
```

---

## 18. HTTP Status Codes

| Status | Meaning | LaunchPad example |
|---:|---|---|
| `200` | Success | Read project list |
| `201` | Created | New project created |
| `204` | Successful response with no body | Project deleted |
| `400` | Bad request | Invalid JSON or UUID |
| `401` | Authentication missing or invalid | Private API request without session |
| `404` | Resource absent or private | Missing or unowned project |
| `422` | Request values invalid | Empty project name |
| `500` | Unexpected server failure | Database mutation error |
| `503` | Required service unavailable | PostgreSQL unavailable |

---

## 19. JSON APIs

JSON is a text format for structured data.

Project example:

```json
{
  "id": "10000000-0000-4000-8000-000000000001",
  "name": "Website redesign",
  "status": "ACTIVE"
}
```

LaunchPad wraps successful API values:

```json
{
  "data": {
    "id": "10000000-0000-4000-8000-000000000001",
    "name": "Website redesign",
    "status": "ACTIVE"
  }
}
```

It wraps errors:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The project input is invalid."
  }
}
```

---

## 20. Authentication

Authentication answers:

```text
Who is making this request?
```

LaunchPad authenticates through this chain:

```text
Browser session cookie
      ↓
Raw session token
      ↓
SHA-256 token hash
      ↓
PostgreSQL session lookup
      ↓
User record
```

A valid session produces a user object:

```ts
{
  id: "30000000-0000-4000-8000-000000000001",
  name: "Demo User",
  email: "demo@launchpad.local",
}
```

---

## 21. Authorization

Authorization answers:

```text
May this user perform this operation?
```

A user may be authenticated but still not own a project.

Correct owner-scoped query:

```sql
SELECT
  id,
  name
FROM projects
WHERE id = ${projectId}
  AND owner_id = ${userId};
```

The user ID comes from the authenticated session.

It must not come from request JSON:

```json
{
  "ownerId": "someone-else-id"
}
```

---

## 22. Cookies

A cookie is a small browser value sent automatically with matching requests.

LaunchPad uses:

```text
launchpad_session
```

The cookie includes a random session token.

Important cookie properties:

```ts
{
  httpOnly: true,
  secure: true,
  sameSite: "lax",
  path: "/",
}
```

### HTTP-only

Browser JavaScript cannot read it through:

```js
document.cookie
```

### Secure

The browser sends it only over HTTPS.

### SameSite Lax

Reduces many cross-site request risks.

---

## 23. Sessions

A session represents a signed-in browser relationship.

LaunchPad stores session data in PostgreSQL:

```text
sessions
├── user_id
├── token_hash
├── expires_at
└── created_at
```

The browser stores the raw token in an HTTP-only cookie.

The database stores only the hash.

This means a database leak does not provide raw browser session tokens directly.

---

## 24. Password Hashing

Passwords are never stored directly.

Bad:

```text
password = LaunchPadDemo123!
```

Better:

```text
password_hash = bcrypt(password)
```

LaunchPad uses bcrypt:

```ts
const passwordHash = await hash(password, 12);
```

At sign-in:

```ts
const valid = await compare(
  submittedPassword,
  passwordHash,
);
```

A hash is one-way. The application verifies a password; it does not decrypt it.

---

## 25. Environment Variables

Environment variables provide configuration outside source code.

LaunchPad examples:

```text
APP_URL
DATABASE_URL
DATABASE_SSL
LOG_LEVEL
APP_VERSION
```

Local example:

```dotenv
APP_URL=http://localhost:3000
DATABASE_SSL=false
LOG_LEVEL=debug
APP_VERSION=development
```

Production example:

```dotenv
APP_URL=https://launchpad.example.com
DATABASE_SSL=true
LOG_LEVEL=info
APP_VERSION=release-abc123
```

Never expose secrets in Client Components.

Variables prefixed with:

```text
NEXT_PUBLIC_
```

may be exposed to browser code.

Do not name secrets this way:

```text
NEXT_PUBLIC_DATABASE_URL
NEXT_PUBLIC_SESSION_SECRET
```

---

## 26. Parameterized SQL

Never insert user-controlled values directly into SQL strings.

Unsafe:

```ts
const query = `
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

The database driver sends the value separately from the SQL statement.

Parameterized SQL helps prevent SQL injection.

---

## 27. Primer Verification Exercises

### Exercise 1: Read owned projects

Write a query that lists projects belonging to one user:

```sql
SELECT
  id,
  name,
  status
FROM projects
WHERE owner_id =
  '30000000-0000-4000-8000-000000000001'
ORDER BY updated_at DESC;
```

Run it:

```bash
npm run db:shell
```

Then paste the SQL and press Enter.

---

### Exercise 2: Count completed tasks

```sql
SELECT
  COUNT(*) AS completed_task_count
FROM tasks
WHERE status = 'COMPLETED';
```

Compare the result with the dashboard’s completed task total.

---

### Exercise 3: Explain authorization

Read this query:

```sql
SELECT
  p.id,
  p.name
FROM projects AS p
WHERE p.id = ${projectId}
  AND p.owner_id = ${userId};
```

Answer:

1. What happens if the project does not exist?
2. What happens if the project belongs to another user?
3. Why is this safer than filtering projects in the browser?

Expected answer:

```text
1. It returns no row.
2. It returns no row.
3. Unauthorized project data never reaches the browser.
```

---

## 28. Primer Completion Checklist

Before returning to the main series, confirm that you understand:

- [ ] What tables, rows, and columns are.
- [ ] What a primary key is.
- [ ] What a foreign key is.
- [ ] What `ON DELETE CASCADE` does.
- [ ] How `SELECT`, `INSERT`, `UPDATE`, and `DELETE` work.
- [ ] Why `WHERE` clauses matter.
- [ ] Why indexes are useful but not free.
- [ ] What `INNER JOIN` and `LEFT JOIN` do.
- [ ] What HTTP methods represent.
- [ ] What common HTTP status codes mean.
- [ ] The difference between authentication and authorization.
- [ ] Why user ownership must be checked in SQL.
- [ ] Why passwords are hashed.
- [ ] Why raw session tokens are not stored in PostgreSQL.
- [ ] Why HTTP-only cookies are useful.
- [ ] Why environment variables and secrets stay server-side.
- [ ] Why parameterized SQL prevents injection risks.
