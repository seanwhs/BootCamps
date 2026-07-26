# Primer 12: APIs, Forms, and Data Mutation Foundations

This primer explains how user actions become secure persistent changes.

You will learn:

- What a mutation is
- How forms submit data
- What Server Actions do
- What Route Handlers do
- When to use each
- How validation, authentication, and authorization work together
- Why revalidation is necessary after writes
- How to return useful success and error feedback

---

## 1. Reads Versus Mutations

Applications perform two broad types of data work.

### Reads

A read retrieves data without intentionally changing it.

Examples:

```text
View dashboard
List projects
Open a project
Load tasks
```

Typical SQL:

```sql
SELECT
  id,
  name,
  status
FROM projects
WHERE owner_id = $user_id;
```

### Mutations

A mutation changes persistent data.

Examples:

```text
Create project
Edit project
Archive project
Create task
Update task status
Delete project
```

Typical SQL:

```sql
UPDATE tasks
SET
  status = 'COMPLETED',
  updated_at = CURRENT_TIMESTAMP
WHERE id = $task_id;
```

LaunchPad uses:

- **Server Components** primarily for reads.
- **Server Actions** for browser form mutations.
- **Route Handlers** for explicit JSON API mutations.

---

## 2. The Secure Mutation Pipeline

A secure mutation follows this order:

```text
Browser input
      ↓
Authenticate caller
      ↓
Validate input
      ↓
Authorize operation
      ↓
Run parameterized database mutation
      ↓
Revalidate affected routes
      ↓
Return safe result, redirect, or JSON response
```

Each step answers a different question.

| Step | Question |
|---|---|
| Authentication | Who is making this request? |
| Validation | Is the submitted value structurally acceptable? |
| Authorization | May this user perform this operation? |
| Database mutation | Can the persistent change be applied safely? |
| Revalidation | Which rendered views are now stale? |

Skipping any step creates a different category of defect.

---

## 3. HTML Forms

A form groups controls that collect input.

```tsx
<form>
  <label htmlFor="project-name">
    Project name
  </label>

  <input
    id="project-name"
    name="name"
    type="text"
    required
  />

  <button type="submit">
    Create project
  </button>
</form>
```

The critical property is:

```tsx
name="name"
```

When submitted, the browser sends data conceptually like:

```text
name=Website+redesign
```

A server-side action reads it with:

```ts
formData.get("name");
```

The input `name` and server lookup key must match exactly.

---

## 4. `FormData`

`FormData` represents submitted form values.

Example form:

```tsx
<form>
  <input name="name" value="Website redesign" />
  <textarea
    name="description"
  >
    Improve accessibility.
  </textarea>
  <select name="status">
    <option value="ACTIVE">Active</option>
  </select>
</form>
```

Conceptual server access:

```ts
const name = formData.get("name");
const description = formData.get("description");
const status = formData.get("status");
```

Each value may be:

```text
string
File
null
```

That is why raw `FormData` values must be validated before use.

---

## 5. Browser Validation Versus Server Validation

Browser validation improves user experience.

```tsx
<input
  name="name"
  required
  maxLength={120}
/>
```

The browser may prevent an empty submission.

But callers can bypass browser rules by:

```text
- Calling an API directly
- Modifying requests
- Disabling JavaScript
- Editing browser values
- Writing another client
```

Server validation remains required.

```ts
const parsedInput = createProjectInputSchema.safeParse({
  name: formData.get("name"),
  description: formData.get("description"),
  status: formData.get("status"),
});
```

The server is the final authority.

---

## 6. Zod Mutation Validation

A Zod schema describes valid input.

```ts
import { z } from "zod";

export const createProjectInputSchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, "Enter a project name.")
    .max(
      120,
      "Project names must contain at most 120 characters.",
    ),
  description: z
    .string()
    .trim()
    .min(1, "Enter a project description.")
    .max(
      2_000,
      "Project descriptions must contain at most 2,000 characters.",
    ),
  status: z.enum([
    "PLANNED",
    "ACTIVE",
    "COMPLETED",
  ]),
});
```

Test a form submission:

```ts
const result = createProjectInputSchema.safeParse({
  name: "Website redesign",
  description: "Improve accessibility and performance.",
  status: "ACTIVE",
});
```

When valid:

```ts
result.success === true
```

When invalid:

```ts
result.success === false
```

The error includes structured issue details such as:

```text
path: name
message: Enter a project name.
```

---

## 7. Server Actions

A Server Action is a function that runs on the server and can be connected to a Next.js form.

It begins with:

```ts
"use server";
```

Example:

```ts
"use server";

import { redirect } from "next/navigation";

export async function exampleAction(
  formData: FormData,
): Promise<void> {
  const name = formData.get("name");

  console.log(name);

  redirect("/projects");
}
```

A form can use it directly:

```tsx
<form action={exampleAction}>
  <input name="name" />
  <button type="submit">
    Submit
  </button>
</form>
```

Server Actions are useful when the mutation belongs to the Next.js application interface.

---

## 8. A Secure Project Creation Action

LaunchPad project creation follows this pattern.

```ts
"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";

import {
  createFieldErrors,
  type FormActionState,
} from "@/lib/action-state";
import { requireUser } from "@/lib/auth/session";
import { createProject } from "@/lib/database/project-mutations";
import { createProjectInputSchema } from "@/lib/project-inputs";

export async function createProjectAction(
  _previousState: FormActionState,
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
      fieldErrors: createFieldErrors(
        parsedInput.error.issues,
      ),
    };
  }

  let projectId: string;

  try {
    const project = await createProject(
      user.id,
      parsedInput.data,
    );

    projectId = project.id;
  } catch (error) {
    console.error(
      "Project creation action failed.",
      error,
    );

    return {
      status: "error",
      message:
        "The project could not be created. Please try again.",
    };
  }

  revalidatePath("/dashboard");
  revalidatePath("/projects");

  redirect(`/projects/${projectId}`);
}
```

This action:

1. Requires a signed-in user.
2. Validates raw `FormData`.
3. Creates the project with the authenticated user’s ID.
4. Revalidates affected routes.
5. Redirects to the newly created project.

---

## 9. Why Ownership Must Come from the Session

Unsafe design:

```ts
const ownerId = formData.get("ownerId");

await createProject(
  String(ownerId),
  parsedInput.data,
);
```

An attacker can change the browser-submitted `ownerId`.

Correct design:

```ts
const user = await requireUser();

await createProject(
  user.id,
  parsedInput.data,
);
```

The current authenticated session determines ownership.

The browser never decides:

```text
Which user owns a newly created project.
```

---

## 10. `useActionState`

A Client Component can use `useActionState` to receive validation feedback and pending state from a Server Action.

```tsx
"use client";

import { useActionState } from "react";

import { createProjectAction } from "@/app/(workspace)/projects/actions";
import { INITIAL_FORM_ACTION_STATE } from "@/lib/action-state";

export function ExampleProjectForm() {
  const [state, formAction, isPending] = useActionState(
    createProjectAction,
    INITIAL_FORM_ACTION_STATE,
  );

  return (
    <form action={formAction}>
      <label htmlFor="name">
        Project name
      </label>

      <input
        id="name"
        name="name"
        aria-invalid={
          state.fieldErrors?.name ? true : undefined
        }
      />

      {state.fieldErrors?.name?.map((message) => (
        <p key={message} role="alert">
          {message}
        </p>
      ))}

      <button type="submit" disabled={isPending}>
        {isPending
          ? "Creating project…"
          : "Create project"}
      </button>
    </form>
  );
}
```

The returned values are:

| Value | Meaning |
|---|---|
| `state` | Latest action result |
| `formAction` | Function attached to `<form action>` |
| `isPending` | Whether submission is currently in progress |

---

## 11. Pending State

Pending state communicates that the server is processing an action.

```tsx
<button type="submit" disabled={isPending}>
  {isPending ? "Saving…" : "Save"}
</button>
```

Benefits:

```text
- Reduces accidental repeat clicks
- Shows the application received the request
- Makes slow network or database work less confusing
```

However, disabling the button is not a complete duplicate-submission defense.

Users may still:

```text
- Open two browser tabs
- Replay requests
- Submit through an API client
- Retry after a network interruption
```

Critical operations may need idempotency rules or database uniqueness constraints.

---

## 12. Revalidation After Mutations

A database mutation changes the source of truth.

Previously rendered pages may now be stale.

Example:

```text
User creates project
     ↓
Project list is old
Dashboard count is old
```

LaunchPad revalidates:

```ts
revalidatePath("/dashboard");
revalidatePath("/projects");
```

For a task update:

```ts
revalidatePath("/dashboard");
revalidatePath("/projects");
revalidatePath(`/projects/${projectId}`);
```

Ask after every mutation:

> Which user-visible routes now represent outdated data?

---

## 13. Redirects After Actions

After creating a project, redirecting to its detail page provides a clear workflow.

```ts
redirect(`/projects/${projectId}`);
```

Important rule:

```text
Do not catch redirect() inside an ordinary try/catch.
```

Incorrect:

```ts
try {
  redirect("/projects");
} catch {
  return {
    status: "error",
  };
}
```

Correct:

```ts
let projectId: string;

try {
  const project = await createProject(
    user.id,
    input,
  );

  projectId = project.id;
} catch {
  return {
    status: "error",
  };
}

redirect(`/projects/${projectId}`);
```

Next.js uses a framework control-flow mechanism to implement redirects.

---

## 14. Route Handlers

A Route Handler provides an explicit HTTP endpoint.

Example file:

```text
src/app/api/projects/route.ts
```

Example handler:

```ts
import { NextResponse } from "next/server";

export async function GET() {
  return NextResponse.json({
    data: [],
  });
}
```

This creates:

```text
GET /api/projects
```

Route Handlers are appropriate for:

```text
- JSON APIs
- Mobile clients
- Third-party integrations
- Webhooks
- Automation scripts
- Health endpoints
```

---

## 15. Server Action or Route Handler?

Use a Server Action when:

```text
- A LaunchPad form submits the mutation
- The action belongs closely to one rendered workflow
- You want built-in form integration
- You want direct route revalidation and redirect behavior
```

Use a Route Handler when:

```text
- Another application needs a stable HTTP endpoint
- You need JSON responses
- You need explicit HTTP status codes
- You receive webhooks
- A mobile or third-party client uses the operation
```

Both should call shared validation and database modules.

Do not duplicate project-creation SQL in both places.

---

## 16. Secure Route Handler Example

```ts
import {
  apiError,
  apiSuccess,
  PRIVATE_NO_STORE_HEADERS,
  readJsonBody,
  zodErrorDetails,
} from "@/lib/api-response";
import { requireApiUser } from "@/lib/auth/session";
import { createProject } from "@/lib/database/project-mutations";
import { createProjectInputSchema } from "@/lib/project-inputs";

export const dynamic = "force-dynamic";

export async function POST(request: Request) {
  const user = await requireApiUser();

  if (!user) {
    return apiError(
      401,
      "UNAUTHORIZED",
      "Authentication is required.",
      undefined,
      PRIVATE_NO_STORE_HEADERS,
    );
  }

  const body = await readJsonBody(request);

  if (!body.success) {
    return body.response;
  }

  const parsedInput = createProjectInputSchema.safeParse(
    body.data,
  );

  if (!parsedInput.success) {
    return apiError(
      422,
      "VALIDATION_ERROR",
      "The project input is invalid.",
      zodErrorDetails(parsedInput.error),
      PRIVATE_NO_STORE_HEADERS,
    );
  }

  const project = await createProject(
    user.id,
    parsedInput.data,
  );

  return apiSuccess(project, {
    status: 201,
    headers: PRIVATE_NO_STORE_HEADERS,
  });
}
```

The secure sequence is:

```text
Authenticate
    ↓
Parse JSON
    ↓
Validate values
    ↓
Create project with session user ID
    ↓
Return private no-store response
```

---

## 17. JSON Content Types

A JSON API should require:

```http
Content-Type: application/json
```

Example request:

```bash
curl --fail --silent \
  --request POST \
  --header "Content-Type: application/json" \
  --header "Cookie: launchpad_session=${SESSION_TOKEN}" \
  --data '{
    "name": "API project",
    "description": "Created through JSON API.",
    "status": "PLANNED"
  }' \
  http://localhost:3000/api/projects
```

If the content type is missing or incorrect, LaunchPad returns:

```text
400 BAD_REQUEST
```

If JSON is malformed:

```text
400 INVALID_JSON
```

If JSON is valid but fields are invalid:

```text
422 VALIDATION_ERROR
```

---

## 18. Mutation Error Categories

| Situation | Expected behavior |
|---|---|
| Missing session | Redirect or `401` |
| Invalid UUID | `400` API error or not-found page |
| Missing record | `404` |
| Other user’s record | `404` |
| Invalid input | Field errors or `422` |
| Malformed JSON | `400` |
| Wrong content type | `400` |
| Database unavailable | Safe error or `503` readiness |
| Unexpected failure | `500` safe response and log |
| Successful create | `201` API response or redirect |
| Successful delete | `204` with no body |

---

## 19. Database Mutation Safety

A mutation should authorize in SQL.

Unsafe:

```sql
UPDATE projects
SET status = ${status}
WHERE id = ${projectId};
```

Safe:

```sql
UPDATE projects
SET
  status = ${status},
  updated_at = CURRENT_TIMESTAMP
WHERE id = ${projectId}
  AND owner_id = ${userId}
RETURNING id;
```

A task mutation must authorize through the parent project:

```sql
UPDATE tasks AS t
SET
  status = ${status},
  updated_at = CURRENT_TIMESTAMP
FROM projects AS p
WHERE t.id = ${taskId}
  AND t.project_id = ${projectId}
  AND p.id = t.project_id
  AND p.owner_id = ${userId}
RETURNING t.id;
```

The database itself confirms ownership while applying the write.

---

## 20. Mutation Verification Checklist

After adding a mutation, verify:

### Success path

```text
- Owner can perform operation.
- Database row changes correctly.
- Relevant route updates.
- API returns expected status.
- Form shows expected feedback.
```

### Validation path

```text
- Empty values fail.
- Oversized values fail.
- Unsupported enum values fail.
- Invalid IDs fail.
```

### Authentication path

```text
- Anonymous caller is rejected.
- Expired session is rejected.
```

### Authorization path

```text
- Another user cannot read changed data.
- Another user cannot mutate it.
- Another user cannot infer private record existence.
```

### Resilience path

```text
- Database failure produces safe feedback.
- Raw database errors are not exposed.
- Production build succeeds.
```

---

## 21. Primer Completion Checklist

Before returning to the main series, you should understand:

- [ ] The difference between reads and mutations.
- [ ] The secure mutation pipeline.
- [ ] How HTML forms produce `FormData`.
- [ ] Why input `name` attributes matter.
- [ ] Why browser validation does not replace server validation.
- [ ] What Server Actions do.
- [ ] What `useActionState` provides.
- [ ] Why pending state is useful but not complete duplicate protection.
- [ ] Why ownership comes from the authenticated session.
- [ ] Why mutations require route revalidation.
- [ ] Why `redirect()` belongs outside ordinary try/catch blocks.
- [ ] What Route Handlers are for.
- [ ] When to use Server Actions versus Route Handlers.
- [ ] Why private APIs require cache restrictions.
- [ ] Why SQL mutations must include ownership conditions.
- [ ] How to verify mutation success, validation, authentication, and authorization paths.
