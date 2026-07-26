# Appendix G: Extending LaunchPad Safely

This appendix explains how to add common production features to LaunchPad without breaking its architecture.

Use it when you want to add:

- Project editing
- Project archiving
- Project deletion from the UI
- Task deletion
- Pagination
- Sorting
- Search
- User profiles
- Audit logs
- File uploads
- Team workspaces
- Roles and permissions
- Notifications

The central principle is:

> Add each feature at the narrowest correct boundary, while preserving validation, authentication, authorization, and ownership checks.

---

# G.1 Safe Extension Workflow

Every new feature should follow this sequence:

```text
Define product rule
      ↓
Choose data model change
      ↓
Create migration
      ↓
Update runtime types and schemas
      ↓
Add owner-scoped query or mutation
      ↓
Add Server Action or Route Handler
      ↓
Add UI
      ↓
Revalidate affected routes
      ↓
Verify positive and negative cases
      ↓
Build, smoke test, and commit
```

For example, adding project archiving should not begin by adding a button.

It should begin with the product rule:

```text
A project owner can archive a project.
Archived projects should not appear in normal active lists.
Archived projects remain recoverable.
```

---

# G.2 Add Project Editing

## Product rule

A project owner may change:

- Project name
- Description
- Status

Only the owner may edit the project.

## Existing architecture support

LaunchPad already has:

```text
PATCH /api/projects/:projectId
updateProject(...)
updateProjectInputSchema
owner-scoped SQL
```

The missing layer is a browser form.

## Recommended route

Create:

```text
src/app/(workspace)/projects/[projectId]/edit/page.tsx
```

This creates:

```text
/projects/:projectId/edit
```

The page should:

1. Require a user.
2. Validate the project UUID.
3. Query the project with `getProjectById(user.id, projectId)`.
4. Call `notFound()` if unavailable.
5. Render a Client Component form with current values.

## Recommended Server Action shape

```ts
"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { z } from "zod";

import { requireUser } from "@/lib/auth/session";
import { updateProject } from "@/lib/database/project-mutations";
import { updateProjectInputSchema } from "@/lib/project-inputs";

const projectIdSchema = z.string().uuid();

export async function updateProjectAction(
  projectId: string,
  formData: FormData,
): Promise<void> {
  const user = await requireUser();

  const parsedProjectId = projectIdSchema.safeParse(projectId);

  if (!parsedProjectId.success) {
    throw new Error("The project identifier is invalid.");
  }

  const parsedInput = updateProjectInputSchema.safeParse({
    name: formData.get("name"),
    description: formData.get("description"),
    status: formData.get("status"),
  });

  if (!parsedInput.success) {
    throw new Error("The project update is invalid.");
  }

  const project = await updateProject(
    user.id,
    parsedProjectId.data,
    parsedInput.data,
  );

  if (!project) {
    throw new Error("The project could not be found.");
  }

  revalidatePath("/dashboard");
  revalidatePath("/projects");
  revalidatePath(`/projects/${project.id}`);

  redirect(`/projects/${project.id}`);
}
```

## Required verification

Test as the project owner:

```text
- Edit project name
- Edit description
- Change status
- Confirm dashboard and project list update
```

Test as another user:

```text
- Request /projects/:projectId/edit
- Confirm not-found behavior
- Attempt PATCH API request
- Confirm 404 response
```

---

# G.3 Add Project Archiving Instead of Immediate Deletion

## Why archive?

Permanent deletion is sometimes appropriate, but many business applications should preserve historical project information.

An archive feature is safer because it supports recovery.

## Suggested schema migration

### `database/migrations/003_add_project_archiving.sql`

```sql
BEGIN;

ALTER TABLE projects
  ADD COLUMN archived_at TIMESTAMPTZ;

CREATE INDEX projects_owner_archived_at_index
  ON projects(owner_id, archived_at);

COMMIT;
```

## Product rule

```text
- Only project owners can archive or restore projects.
- Archived projects do not appear in normal project lists.
- Archived projects remain visible in an explicit archived view.
- Tasks remain attached to archived projects.
```

## Query rule

Normal list query:

```sql
WHERE p.owner_id = ${userId}
  AND p.archived_at IS NULL
```

Archived list query:

```sql
WHERE p.owner_id = ${userId}
  AND p.archived_at IS NOT NULL
```

## Archive mutation

```sql
UPDATE projects
SET
  archived_at = CURRENT_TIMESTAMP,
  updated_at = CURRENT_TIMESTAMP
WHERE id = ${projectId}
  AND owner_id = ${userId}
RETURNING id;
```

## Restore mutation

```sql
UPDATE projects
SET
  archived_at = NULL,
  updated_at = CURRENT_TIMESTAMP
WHERE id = ${projectId}
  AND owner_id = ${userId}
RETURNING id;
```

## Important design choice

Do not treat archive state as only a visual badge.

The database query must decide whether archived records belong in the current list.

---

# G.4 Add Project Deletion Through the Interface

LaunchPad already supports:

```text
DELETE /api/projects/:projectId
```

A browser interface should require deliberate confirmation.

## Recommended UI behavior

Use a form with an explicit confirmation value:

```text
Type the project name to confirm deletion.
```

Avoid a single destructive button without context.

## Recommended server validation

```ts
const deleteProjectInputSchema = z.object({
  confirmationName: z.string().trim().min(1),
});
```

Then compare the submitted name against the project loaded through an owner-scoped query.

```text
1. Require user.
2. Load project by owner and ID.
3. Return not-found if unavailable.
4. Validate confirmation text.
5. Compare exact project name.
6. Delete through owner-scoped SQL.
7. Revalidate project lists.
8. Redirect to /projects.
```

## Why confirmation belongs on the server

A browser-only confirmation can be bypassed.

The destructive operation must validate its confirmation server-side before deletion.

---

# G.5 Add Task Deletion

## Product rule

```text
Only the owner of the parent project may delete a task.
```

## Safe SQL pattern

```sql
DELETE FROM tasks AS t
USING projects AS p
WHERE t.id = ${taskId}
  AND t.project_id = ${projectId}
  AND p.id = t.project_id
  AND p.owner_id = ${userId}
RETURNING t.id;
```

The query verifies:

```text
- Task identity
- Parent project identity
- Parent project ownership
```

## Revalidate after deletion

```ts
revalidatePath("/dashboard");
revalidatePath("/projects");
revalidatePath(`/projects/${projectId}`);
```

## Verify

Positive case:

```text
Owner deletes a task.
Task disappears.
Task count updates.
Completion percentage updates.
```

Negative case:

```text
Another user attempts task deletion.
Response must not reveal task existence.
Use 404-style behavior.
```

---

# G.6 Add URL-Based Pagination

As the number of projects grows, rendering every project becomes expensive and difficult to navigate.

## Recommended URL shape

```text
/projects?page=2
```

With filtering:

```text
/projects?status=ACTIVE&page=2
```

## Validate query parameters

```ts
const pageSchema = z.coerce
  .number()
  .int()
  .min(1)
  .default(1);
```

A `z.coerce.number()` schema converts a string such as:

```text
"2"
```

into:

```text
2
```

## SQL pattern

```sql
SELECT
  p.id,
  p.name,
  p.description,
  p.status
FROM projects AS p
WHERE p.owner_id = ${userId}
ORDER BY p.updated_at DESC, p.id DESC
LIMIT ${pageSize}
OFFSET ${offset};
```

Calculate:

```ts
const pageSize = 20;
const offset = (page - 1) * pageSize;
```

## Important ordering rule

Pagination requires stable ordering.

Avoid:

```sql
ORDER BY updated_at DESC
```

alone if multiple records may share the same timestamp.

Prefer:

```sql
ORDER BY updated_at DESC, id DESC
```

The UUID provides a stable tie-breaker.

## Better future option: cursor pagination

For very large datasets, cursor pagination is often more efficient than large offsets.

Example URL:

```text
/projects?cursor=2026-07-26T12%3A00%3A00.000Z
```

Cursor design must include a stable tie-breaker such as:

```text
updated_at + id
```

Do not add cursor pagination until measured scale makes it useful.

---

# G.7 Add URL-Based Sorting

## Recommended URL shape

```text
/projects?sort=updated
/projects?sort=name
/projects?sort=created
```

Do not place SQL column names directly in the URL and interpolate them into SQL.

Unsafe:

```ts
const sort = url.searchParams.get("sort");

database.unsafe(`
  SELECT *
  FROM projects
  ORDER BY ${sort}
`);
```

## Safe mapping pattern

```ts
const sortOptions = {
  updated: "updated_at DESC, id DESC",
  created: "created_at DESC, id DESC",
  name: "name ASC, id ASC",
} as const;
```

Then choose only from known internal SQL fragments:

```ts
const orderBy =
  sortOptions[selectedSort] ??
  sortOptions.updated;
```

The user selects a controlled option. They do not provide arbitrary SQL.

---

# G.8 Add Full-Text Search

For a small project list, current browser-side search is acceptable because the server already returns only authorized records.

For larger datasets, move search into PostgreSQL.

## Product rule

```text
Search only projects owned by the current user.
```

## Basic PostgreSQL search query

```sql
SELECT
  p.id,
  p.name,
  p.description,
  p.status
FROM projects AS p
WHERE p.owner_id = ${userId}
  AND (
    p.name ILIKE ${`%${query}%`}
    OR p.description ILIKE ${`%${query}%`}
  )
ORDER BY p.updated_at DESC
LIMIT 50;
```

For larger data, use PostgreSQL full-text search.

## Suggested migration

```sql
BEGIN;

ALTER TABLE projects
  ADD COLUMN search_document TSVECTOR
  GENERATED ALWAYS AS (
    to_tsvector(
      'english',
      coalesce(name, '') || ' ' ||
      coalesce(description, '')
    )
  ) STORED;

CREATE INDEX projects_search_document_index
  ON projects
  USING GIN(search_document);

COMMIT;
```

## Query pattern

```sql
SELECT
  p.id,
  p.name,
  p.description,
  p.status
FROM projects AS p
WHERE p.owner_id = ${userId}
  AND p.search_document @@
    websearch_to_tsquery(
      'english',
      ${query}
    )
ORDER BY
  ts_rank(
    p.search_document,
    websearch_to_tsquery(
      'english',
      ${query}
    )
  ) DESC;
```

## Security rule

Search text is untrusted. Use parameterized SQL.

Ownership remains a mandatory SQL condition:

```sql
p.owner_id = ${userId}
```

---

# G.9 Add Project Search to the URL

The current project text search is local state:

```text
User types → Client Component filters supplied records
```

To make search shareable, use the URL:

```text
/projects?query=website
```

## When to move search into URL state

Move it when users need to:

- Bookmark searches
- Share search results
- Refresh without losing search
- Search records not currently sent to the browser
- Combine search with pagination

## Recommended approach

Use a GET form:

```tsx
<form action="/projects" method="get">
  <label htmlFor="query">Search projects</label>

  <input
    id="query"
    name="query"
    type="search"
    defaultValue={query}
  />

  <button type="submit">
    Search
  </button>
</form>
```

The server validates:

```ts
const projectSearchSchema = z
  .string()
  .trim()
  .max(100)
  .default("");
```

Do not put unlimited query strings into database searches.

---

# G.10 Add User Profile Management

## Suggested fields

```text
users
├── name
├── email
├── avatar_url
├── timezone
└── updated_at
```

## Suggested migration

```sql
BEGIN;

ALTER TABLE users
  ADD COLUMN timezone VARCHAR(100)
  NOT NULL DEFAULT 'UTC';

COMMIT;
```

## Authorization rule

Users may update only their own account.

Because account identity comes from the session, the mutation should not accept an arbitrary target user ID.

Correct:

```ts
const user = await requireUser();

await updateProfile(
  user.id,
  parsedInput.data,
);
```

Incorrect:

```ts
const targetUserId = formData.get("userId");

await updateProfile(
  String(targetUserId),
  parsedInput.data,
);
```

---

# G.11 Add User Roles

LaunchPad currently has one authorization relationship:

```text
User owns Project
```

A role system can add organization-level permissions.

## Example roles

```text
OWNER
ADMIN
MEMBER
VIEWER
```

## Do not add roles prematurely

Roles add complexity:

- Permission definitions
- UI conditions
- SQL conditions
- Invitation workflows
- Audit requirements
- Role changes
- Edge cases around ownership transfer

Use roles when the product needs shared workspaces.

## Suggested future schema

```text
organizations
├── id
├── name
└── created_at

organization_members
├── organization_id
├── user_id
├── role
└── created_at

projects
├── id
├── organization_id
└── ...
```

The authorization query changes from:

```sql
WHERE p.owner_id = ${userId}
```

to something conceptually similar to:

```sql
WHERE p.organization_id IN (
  SELECT organization_id
  FROM organization_members
  WHERE user_id = ${userId}
)
```

A role-aware mutation must also verify that the current member role permits the requested operation.

---

# G.12 Add Team Workspaces

A team workspace changes the data model from:

```text
One user → many projects
```

to:

```text
Many users → one organization → many projects
```

## Suggested relationship

```text
users
  │
  └── organization_members
            │
            └── organizations
                    │
                    └── projects
                            │
                            └── tasks
```

## Important product decisions

Before writing migrations, decide:

- Can one user belong to multiple organizations?
- Which organization is active in the URL?
- Can owners transfer ownership?
- Can admins invite members?
- Can viewers create tasks?
- Can members delete projects?
- What happens when the final owner leaves?
- Are projects private inside an organization?

## Recommended route structure

```text
/workspaces/:workspaceId/dashboard
/workspaces/:workspaceId/projects
/workspaces/:workspaceId/projects/:projectId
```

The workspace ID becomes part of the authorization context.

---

# G.13 Add Audit Logs

An audit log records important security or business events.

Examples:

```text
- User signed in
- User signed out
- Project created
- Project archived
- Project deleted
- Task status changed
- Member invited
- Role changed
```

## Suggested schema

```sql
CREATE TABLE audit_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id UUID,
  event_type VARCHAR(100) NOT NULL,
  entity_type VARCHAR(100) NOT NULL,
  entity_id UUID,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

## Important audit-log rules

- Never store passwords.
- Never store raw session tokens.
- Avoid full sensitive content snapshots unless required.
- Make logs append-only for ordinary application flows.
- Define retention and access rules.
- Consider legal and privacy requirements.

## Mutation transaction example

For a sensitive action, write the data mutation and audit event in one transaction.

```ts
await database.begin(async (transaction) => {
  await transaction`
    DELETE FROM projects
    WHERE id = ${projectId}
      AND owner_id = ${userId}
  `;

  await transaction`
    INSERT INTO audit_events (
      actor_user_id,
      event_type,
      entity_type,
      entity_id
    )
    VALUES (
      ${userId},
      'project.deleted',
      'project',
      ${projectId}
    )
  `;
});
```

---

# G.14 Add File Uploads

File upload support introduces a new trust boundary.

Do not store arbitrary uploaded files directly in the Next.js application filesystem in a serverless or horizontally scaled environment.

Use object storage instead:

```text
Browser
   ↓
Server authorizes upload
   ↓
Short-lived upload URL
   ↓
Object storage
   ↓
Database stores metadata and object key
```

## Suggested upload metadata table

```sql
CREATE TABLE project_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL,
  uploaded_by_user_id UUID NOT NULL,
  storage_key TEXT NOT NULL UNIQUE,
  original_filename VARCHAR(255) NOT NULL,
  content_type VARCHAR(255) NOT NULL,
  byte_size BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (project_id)
    REFERENCES projects(id)
    ON DELETE CASCADE,

  FOREIGN KEY (uploaded_by_user_id)
    REFERENCES users(id)
    ON DELETE SET NULL
);
```

## Required upload controls

Validate:

- User authentication
- Project ownership
- File size
- Allowed MIME types
- File extension only as supplemental validation
- Storage key generation
- Download authorization
- Malware scanning where required

Never trust a browser-provided MIME type as the only file-type check.

---

# G.15 Add Notifications

Notifications can be:

```text
- In-app
- Email
- Push
- Webhook
```

## Recommended architecture

Do not send email synchronously inside a database transaction or Server Action if it can be avoided.

Prefer:

```text
Mutation succeeds
      ↓
Write notification event
      ↓
Background worker processes event
      ↓
Email or push provider sends message
```

This prevents a slow email provider from delaying the core project mutation.

## Suggested notification table

```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  type VARCHAR(100) NOT NULL,
  payload JSONB NOT NULL,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE CASCADE
);
```

Authorization remains user-scoped:

```sql
WHERE user_id = ${authenticatedUserId}
```

---

# G.16 Add Rate Limiting

LaunchPad should add distributed rate limiting before a broad public launch.

## High-priority endpoints

Rate-limit:

```text
/sign-in
/sign-up
/api/projects
password-reset endpoints
email-verification endpoints
```

## Why in-memory rate limiting is insufficient

This is unreliable in multi-instance deployment:

```ts
const attempts = new Map();
```

Each instance has separate memory.

Use shared infrastructure:

```text
Redis
Managed rate-limit service
Edge platform rate limiting
API gateway
WAF
```

## Example policy

| Endpoint | Suggested starting policy |
|---|---|
| Sign in | 5 attempts per account and IP per 15 minutes |
| Sign up | 5 attempts per IP per hour |
| Password reset | 3 attempts per account per hour |
| Project API mutation | Depends on product workflow |

Tune policies with real traffic and support requirements.

---

# G.17 Add Email Verification and Password Reset

These features require short-lived, single-use tokens.

## Suggested table

```sql
CREATE TABLE verification_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  purpose VARCHAR(50) NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL,
  used_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE CASCADE
);
```

Purposes could include:

```text
EMAIL_VERIFICATION
PASSWORD_RESET
```

## Required controls

- Generate random tokens.
- Store only hashes.
- Expire quickly.
- Mark tokens used after successful use.
- Rate-limit requests.
- Avoid account enumeration.
- Revoke old tokens when a new one is created.
- Send links only over HTTPS.
- Audit sensitive account changes.

---

# G.18 Add Tests in Layers

A growing application needs more than smoke tests.

## Unit tests

Test pure functions:

```text
formatProjectStatus
calculateProjectProgress
input schema behavior
pagination calculations
```

## Integration tests

Test:

```text
query functions
migrations
owner-scoped SQL
session behavior
Route Handlers
```

## Browser end-to-end tests

Test realistic flows:

```text
sign up
sign in
create project
create task
sign out
cross-user access denial
```

## Security regression tests

Keep a test for:

```text
User B cannot read User A’s project.
User B cannot update User A’s project.
User B cannot delete User A’s project.
```

Authorization bugs are serious enough to deserve permanent regression tests.

---

# G.19 Feature Extension Checklist

Before merging a new LaunchPad feature, confirm:

- [ ] The product rule is written down.
- [ ] New data needs a versioned migration.
- [ ] The migration is backward-compatible where possible.
- [ ] Input schemas validate every new server entry point.
- [ ] Types match database constraints.
- [ ] Database queries are parameterized.
- [ ] Private reads include ownership conditions.
- [ ] Private writes include ownership conditions.
- [ ] Server Actions authenticate the caller.
- [ ] Route Handlers authenticate the caller.
- [ ] Client Components receive only safe serializable data.
- [ ] Revalidation includes affected routes.
- [ ] Loading, empty, validation, and error states are handled.
- [ ] Keyboard and screen-reader behavior are verified.
- [ ] Narrow viewport behavior is verified.
- [ ] Positive and negative authorization cases are tested.
- [ ] Type checking succeeds.
- [ ] Lint succeeds.
- [ ] Production build succeeds.
- [ ] Smoke tests continue to pass.
- [ ] Documentation and runbooks are updated if operations changed.
