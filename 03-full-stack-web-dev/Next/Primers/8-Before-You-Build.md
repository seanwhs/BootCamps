# Primer 8: Before You Build—Planning a Feature from Idea to Implementation

This primer teaches a practical way to turn a feature request into a safe implementation plan.

Before writing code, you should be able to answer:

- What should the feature do?
- Who may use it?
- What data does it need?
- Which route displays it?
- Which state belongs in the URL, browser, server, or database?
- What can fail?
- How will you verify it?

---

## 1. Start with a Plain-Language Requirement

Avoid starting with:

```text
I need a button.
```

Start with the user outcome.

Example:

```text
A signed-in project owner can archive one of their projects.
Archived projects do not appear in the normal project list.
Archived projects can be restored later.
```

This gives the feature a product definition before it has a UI.

---

## 2. Identify Actors

An **actor** is someone or something that interacts with a feature.

For project archiving:

| Actor | Allowed behavior |
|---|---|
| Project owner | Archive and restore their project |
| Other signed-in user | Cannot view or archive the project |
| Anonymous visitor | Cannot access project workspace |
| Database | Stores archive state |
| Background job | Not required yet |

This prevents a common mistake:

```text
Build the owner experience but forget to define non-owner behavior.
```

---

## 3. Define the Data Change

Ask:

> Does the feature require persistent data?

For archiving, yes.

A migration may add:

```sql
ALTER TABLE projects
  ADD COLUMN archived_at TIMESTAMPTZ;
```

This value means:

```text
NULL
→ Project is active or not archived.

Timestamp
→ Project was archived at that time.
```

This is often better than a boolean:

```sql
is_archived BOOLEAN
```

because the timestamp also tells us when the archive action occurred.

---

## 4. Define the Authorization Rule

For every private feature, write the authorization rule in plain language.

```text
Only the current owner of a project may archive or restore it.
```

Then translate it into SQL conditions:

```sql
UPDATE projects
SET
  archived_at = CURRENT_TIMESTAMP,
  updated_at = CURRENT_TIMESTAMP
WHERE id = ${projectId}
  AND owner_id = ${userId}
RETURNING id;
```

The `owner_id` condition is not optional.

A button hidden from non-owners is not authorization.

---

## 5. Choose the Correct Server Entry Point

Ask how the feature is triggered.

| Trigger | Recommended approach |
|---|---|
| LaunchPad form submission | Server Action |
| External JSON client | Route Handler |
| Scheduled maintenance | Background job |
| Initial page rendering | Server Component |
| Temporary browser interaction | Client Component |

For a project archive button in LaunchPad, use a Server Action.

```text
Browser form
    ↓
Server Action
    ↓
requireUser()
    ↓
Owner-scoped mutation
    ↓
revalidatePath()
    ↓
Updated page
```

---

## 6. Decide Which State Belongs Where

Project archiving has several possible state values.

| Value | Correct owner |
|---|---|
| `archived_at` timestamp | PostgreSQL |
| Current user identity | Server session |
| “Show archived projects” filter | URL |
| Confirmation dialog open/closed | Local Client Component state |
| Form pending status | React action state |

Example shareable archive filter:

```text
/projects?view=archived
```

Example local-only confirmation state:

```tsx
const [isConfirming, setIsConfirming] = useState(false);
```

---

## 7. Plan the Route Behavior

Write expected route behavior before implementation.

| Route | Expected behavior |
|---|---|
| `/projects` | Shows active projects by default |
| `/projects?view=archived` | Shows only archived projects |
| `/projects/:projectId` | Shows owned project if visible |
| `/projects/:projectId` for another user | Returns not found |
| `/projects/:projectId` for archived project | Depends on explicit product rule |

You must decide whether archived projects remain directly accessible.

Possible rule:

```text
Owners may access archived project detail routes.
Archived projects show an archive status and restoration action.
```

---

## 8. Plan Every Outcome

A feature is not only its happy path.

For archive behavior, define all outcomes.

| Situation | Expected result |
|---|---|
| Owner archives active project | Project archived successfully |
| Owner restores archived project | Project restored successfully |
| Anonymous user submits archive request | Redirect or `401` |
| Non-owner submits archive request | `404` or safe failure |
| Invalid project ID | Not found |
| Missing project | Not found |
| Database unavailable | Error boundary or safe form error |
| Archive action submitted twice | Second request safely changes nothing or returns consistent state |

---

## 9. Plan Revalidation

Ask:

> Which visible routes become stale after this mutation?

Archiving a project may affect:

```text
/dashboard
/projects
/projects?view=archived
/projects/:projectId
```

The Server Action should revalidate relevant paths:

```ts
revalidatePath("/dashboard");
revalidatePath("/projects");
revalidatePath(`/projects/${projectId}`);
```

If cached route behavior becomes more advanced later, this may evolve into tag-based invalidation.

---

## 10. Plan Verification Before Writing Code

Define concrete checks.

### Database verification

```sql
SELECT
  id,
  name,
  archived_at
FROM projects
WHERE id = 'PROJECT_UUID_HERE';
```

### Browser verification

```text
1. Sign in as project owner.
2. Archive project.
3. Confirm project disappears from active list.
4. Open archived filter.
5. Confirm project appears.
6. Restore project.
7. Confirm it returns to active list.
```

### Authorization verification

```text
1. Sign in as User A.
2. Create project.
3. Sign out.
4. Sign in as User B.
5. Attempt archive through direct URL or API.
6. Confirm User B receives no project information.
```

### Production verification

```bash
npm run typecheck
npm run lint
npm run build
npm run smoke
```

---

## 11. Feature Planning Template

Use this template for any substantial LaunchPad feature.

```markdown
# Feature: [Name]

## Product rule

[Describe what should happen in plain language.]

## Actors

- [Actor]: [Allowed behavior]
- [Actor]: [Denied behavior]

## Data model

- New migration required: [yes/no]
- Tables affected: [list]
- New fields: [list]
- Constraints: [list]
- Indexes: [list]

## Authentication

- Is a signed-in user required?
- Which server entry points require authentication?

## Authorization

- Who may read this data?
- Who may create it?
- Who may update it?
- Who may delete it?
- Which SQL conditions enforce this?

## Routes and UI

- New route: [yes/no]
- Existing route changes: [list]
- Client interaction required: [yes/no]
- URL state required: [yes/no]

## Server behavior

- Server Component queries: [list]
- Server Actions: [list]
- Route Handlers: [list]
- Revalidation paths: [list]

## Failure states

- Invalid input:
- Missing record:
- Unauthorized user:
- Database failure:
- Duplicate request:

## Verification

- Browser tests:
- API tests:
- SQL verification:
- Authorization-negative tests:
- Production checks:
```

---

## 12. Primer Completion Checklist

Before returning to the main series, confirm that you can:

- [ ] Write a feature requirement in plain language.
- [ ] Identify users and system actors.
- [ ] Decide whether a feature needs persistent data.
- [ ] Identify when a migration is required.
- [ ] Write an authorization rule before implementation.
- [ ] Choose Server Component, Server Action, Route Handler, or Client Component appropriately.
- [ ] Decide whether state belongs in PostgreSQL, the URL, or local browser state.
- [ ] Define happy-path and failure outcomes.
- [ ] Identify routes requiring revalidation.
- [ ] Design verification steps before writing code.
- [ ] Explain why a button is not the feature—the full vertical slice is the feature.
