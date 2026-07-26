# Primer 5: Web Requests, Rendering, State, and Application Boundaries

This primer connects the ideas from the previous primers into one practical web-application mental model.

You will learn:

- What happens when a browser visits a URL
- Client-side versus server-side work
- Rendering and hydration
- Request, response, and state lifecycles
- Trusted versus untrusted boundaries
- Public versus private data
- Static versus dynamic content
- Loading, empty, error, and not-found states
- Why state belongs in different places

This primer prepares you for the architectural decisions made throughout the Next.js series.

---

## 1. What Happens When You Visit a URL?

Suppose you enter this address into a browser:

```text
https://launchpad.example.com/projects
```

At a high level, this happens:

```text
Browser
   ↓
DNS finds the server address
   ↓
Browser opens HTTPS connection
   ↓
Browser sends HTTP request
   ↓
Server receives request
   ↓
Application decides what to render
   ↓
Server sends HTTP response
   ↓
Browser displays response
```

A browser request conceptually contains:

```http
GET /projects HTTP/1.1
Host: launchpad.example.com
Cookie: launchpad_session=...
```

The server response might contain:

```http
HTTP/1.1 200 OK
Content-Type: text/html
```

followed by HTML, CSS references, JavaScript references, and application data.

---

## 2. Request and Response

A web request is a message sent from a client to a server.

A response is the server’s answer.

```text
Browser request
      ↓
Server processing
      ↓
Server response
```

Example:

```text
GET /about
```

The server may respond with:

```text
200 OK
```

Example private route:

```text
GET /dashboard
```

If no valid session exists, the server may respond with:

```text
307 Temporary Redirect
Location: /sign-in
```

Example missing private project:

```text
GET /projects/unknown-id
```

The server may respond with:

```text
404 Not Found
```

The status code communicates the broad result, while the response body provides browser-visible content or JSON.

---

## 3. Browser, Server, and Database Responsibilities

A production application has several environments with different responsibilities.

```text
Browser
    ↓
Next.js server
    ↓
Database
```

### Browser responsibilities

The browser is responsible for:

```text
- Displaying HTML and CSS
- Receiving user input
- Running Client Component JavaScript
- Managing browser history
- Sending cookies with matching requests
- Calling browser APIs
```

Examples:

```text
- Button click
- Search text input
- Opening a disclosure
- Copying a project URL
- Browser viewport changes
```

### Server responsibilities

The server is responsible for:

```text
- Rendering trusted initial content
- Reading session cookies
- Validating inputs
- Checking authorization
- Calling the database
- Returning pages, redirects, or JSON
- Reading private environment variables
```

Examples:

```text
- Load user-owned projects
- Create a task
- Verify a password
- Create a session
- Return API error response
```

### Database responsibilities

The database is responsible for:

```text
- Persistent storage
- Relationships
- Constraints
- Indexes
- Owner-scoped data selection
- Atomic writes
```

Examples:

```text
- Store users
- Store projects
- Store tasks
- Store session token hashes
- Reject invalid project status values
```

---

## 4. Trusted and Untrusted Boundaries

The browser is not a trusted security boundary.

A user can:

```text
- Edit browser form values
- Call APIs directly
- Change URLs
- Inspect JavaScript
- Replay requests
- Modify request bodies
- Disable browser-side validation
```

This means you must treat browser input as untrusted.

Example browser form:

```tsx
<input
  name="status"
  value="ACTIVE"
/>
```

A malicious caller can still send:

```json
{
  "status": "NOT_A_REAL_STATUS"
}
```

The server must validate it.

```text
Browser input
      ↓
Server validation
      ↓
Database operation
```

Never reverse the order.

---

## 5. Server Rendering

**Server rendering** means the server creates interface output before sending it to the browser.

Example Server Component:

```tsx
export default async function ProjectsPage() {
  const user = await requireUser();
  const projects = await getProjects(user.id);

  return (
    <main>
      <h1>Projects</h1>

      <p>
        {projects.length} projects found.
      </p>
    </main>
  );
}
```

The server can:

1. Read the session.
2. Query PostgreSQL.
3. Render project count.
4. Send useful output to the browser.

The browser does not need to wait for a client-side JavaScript request before seeing the initial page content.

---

## 6. Client Rendering

**Client rendering** means JavaScript running in the browser creates or updates an interface.

Example:

```tsx
"use client";

import { useState } from "react";

export function SearchExample() {
  const [query, setQuery] = useState("");

  return (
    <>
      <label htmlFor="search">
        Search
      </label>

      <input
        id="search"
        value={query}
        onChange={(event) => {
          setQuery(event.target.value);
        }}
      />

      <p>Current query: {query}</p>
    </>
  );
}
```

The browser updates the displayed query immediately as the user types.

This is useful for temporary interaction state.

It is not the right place to perform sensitive operations such as:

```text
- Database access
- Password verification
- Session creation
- Ownership checks
- Reading secrets
```

---

## 7. Hydration

A Client Component can appear in server-rendered output, then become interactive in the browser.

This process is called **hydration**.

```text
Server renders initial page
      ↓
Browser receives HTML
      ↓
Browser downloads required Client Component JavaScript
      ↓
React attaches event behavior
      ↓
Interactive controls work
```

For example, the project page can render task content from the server while a small copy-link button becomes interactive after hydration.

```text
Server page
├── Project title
├── Project description
├── Task list
└── Client copy-link button
```

This approach avoids sending the entire project page as browser JavaScript merely because one control needs an event handler.

---

## 8. Static Rendering

Static rendering prepares content before individual users request it.

A static page is useful when everyone sees the same content.

Examples:

```text
/
/about
/features
```

Conceptually:

```text
Build time
   ↓
Generate page output
   ↓
Reuse output for many visitors
```

Benefits:

```text
- Fast delivery
- Less server work per request
- CDN-friendly content
```

Static output is not suitable for a page that depends on a particular user’s session.

---

## 9. Dynamic Rendering

Dynamic rendering creates output using current request information.

Examples:

```text
/dashboard
/projects
/projects/:projectId
```

These routes depend on:

```text
- Session cookie
- Authenticated user
- User-owned PostgreSQL records
```

Conceptually:

```text
User request
   ↓
Read cookie
   ↓
Find session
   ↓
Authorize user
   ↓
Query owned data
   ↓
Render current response
```

Private user data should remain dynamic unless a carefully designed identity-aware cache policy exists.

---

## 10. Loading States

A loading state means the application is still waiting for work to finish.

Example:

```text
Loading projects…
```

In Next.js, a route can define:

```text
loading.tsx
```

Example conceptual loading component:

```tsx
export default function ProjectsLoading() {
  return (
    <main aria-busy="true">
      <h1>Loading projects…</h1>
    </main>
  );
}
```

A loading state should not pretend that work succeeded.

Good:

```text
Loading dashboard…
```

Misleading:

```text
0 projects
```

when the database query has not finished yet.

---

## 11. Empty States

An empty state means the request succeeded, but no matching data exists.

Example:

```text
No projects yet.
Create your first project to begin planning work.
```

Example component:

```tsx
export function EmptyProjects() {
  return (
    <section>
      <h2>No projects yet</h2>
      <p>
        Create your first project to begin tracking work.
      </p>
    </section>
  );
}
```

An empty state is not an error.

```text
Loading
→ Work is pending.

Empty
→ Work succeeded and returned no records.

Error
→ Work could not complete.
```

---

## 12. Error States

An error state means unexpected work failed.

Possible causes:

```text
- PostgreSQL unavailable
- Invalid server configuration
- Network failure
- Bug in application code
- External dependency outage
```

Users should receive a safe explanation:

```text
LaunchPad could not load this information.
Please try again.
```

Users should not receive raw internal errors:

```text
password authentication failed for user launchpad
```

or:

```text
TypeError: Cannot read properties of undefined
```

The server may log technical details safely for developers, while the interface displays a useful recovery action.

---

## 13. Not-Found States

A not-found state means the requested resource is absent or intentionally undiscoverable.

Examples:

```text
- URL route does not exist
- Project UUID does not exist
- Project belongs to another user
```

In private applications, these two conditions may intentionally produce the same result:

```text
Project does not exist.
Project exists but belongs to someone else.
```

Both return:

```text
404 Not Found
```

This avoids revealing private resource existence.

---

## 14. State: What Changes Over Time?

**State** is any value that can change while an application runs.

Examples:

```text
- Current user
- Current project list
- Search query
- Selected filter
- Open disclosure
- Form pending status
- Task completion state
```

Different state belongs in different places.

---

## 15. Server State

Server state is authoritative data owned outside the browser.

LaunchPad server state includes:

```text
- Users
- Sessions
- Projects
- Tasks
- Project ownership
- Task status
```

The database is the primary source of truth.

Example:

```ts
const projects = await getProjects(user.id);
```

The browser may display these records, but the browser does not become their authoritative owner.

---

## 16. URL State

URL state is shareable navigation state stored in the browser address.

Example:

```text
/projects?status=ACTIVE
```

The selected status survives:

```text
- Refresh
- Browser back button
- Browser forward button
- Copying the URL
- Bookmarking
```

Use URL state for:

```text
- Filters
- Sort order
- Pagination
- Shareable searches
- Tabs representing navigation
```

Do not use local `useState` for a filter that users need to share or bookmark.

---

## 17. Local Client State

Local Client Component state is temporary browser behavior.

Examples:

```text
- Current text in a search box
- Whether a disclosure is open
- Copy-link success message
- Form pending state
- Temporary dropdown visibility
```

Example:

```tsx
"use client";

import { useState } from "react";

export function ExampleDisclosure() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <button
        type="button"
        onClick={() => {
          setIsOpen((currentValue) => !currentValue);
        }}
      >
        {isOpen ? "Hide details" : "Show details"}
      </button>

      {isOpen ? (
        <p>Extra project details.</p>
      ) : null}
    </>
  );
}
```

This state does not need to survive a refresh.

---

## 18. Derived State

**Derived state** is a value calculated from other values.

Example:

```ts
const taskCount = 4;
const completedTaskCount = 2;

const progress =
  Math.round(
    (completedTaskCount / taskCount) * 100,
  );
```

Result:

```text
50
```

Avoid storing derived state separately unless necessary.

Less desirable:

```ts
const [taskCount, setTaskCount] = useState(4);
const [completedTaskCount, setCompletedTaskCount] = useState(2);
const [progress, setProgress] = useState(50);
```

Now all three values can become inconsistent.

Prefer calculating progress when needed:

```ts
const progress =
  taskCount === 0
    ? 0
    : Math.round(
        (completedTaskCount / taskCount) * 100,
      );
```

---

## 19. The Source of Truth

A **source of truth** is the authoritative place where a value is stored.

LaunchPad examples:

| Value | Source of truth |
|---|---|
| User account | `users` table |
| Session validity | `sessions` table |
| Project ownership | `projects.owner_id` |
| Task status | `tasks.status` |
| Current URL filter | Browser URL |
| Search input text | Local Client Component state |
| Form pending state | React action state |

When two locations both claim to be authoritative, bugs often follow.

Example problem:

```text
Database says task is TODO.
Browser local state says task is COMPLETED.
```

After a refresh, the database result wins.

For persistent changes, mutate the server and database rather than only changing local browser state.

---

## 20. Mutation Lifecycle

A mutation changes persistent application data.

Example: create a task.

```text
User submits task form
      ↓
Browser sends FormData
      ↓
Server Action receives it
      ↓
Server authenticates user
      ↓
Server validates fields
      ↓
Server authorizes project ownership
      ↓
Database inserts task
      ↓
Server revalidates affected routes
      ↓
Browser sees updated task list
```

The important order is:

```text
Authenticate
    ↓
Validate
    ↓
Authorize
    ↓
Mutate
    ↓
Refresh affected views
```

---

## 21. Why Client-Side Changes Are Not Enough

Suppose a user clicks a browser button and local state changes:

```tsx
setTaskStatus("COMPLETED");
```

The interface now looks complete, but PostgreSQL still contains:

```text
TODO
```

If the browser refreshes:

```text
Database returns TODO
```

The browser update disappears.

For persistent changes, use a Server Action or Route Handler that updates PostgreSQL.

```text
Browser state
→ temporary interaction

Database mutation
→ persistent application change
```

---

## 22. Public and Private Data

Public data can be shown to everyone.

Examples:

```text
Marketing copy
Feature descriptions
Public documentation
Health endpoint status
```

Private data must be scoped to an authenticated user.

Examples:

```text
Projects
Tasks
Account details
Sessions
Audit events
```

Private data flow:

```text
Browser cookie
      ↓
Server session lookup
      ↓
Authenticated user ID
      ↓
Owner-scoped SQL query
      ↓
Authorized response
```

The browser must never receive every user’s data and filter it afterward.

---

## 23. Caching Basics

A cache stores a result so the same work does not always run again.

Caching is useful only when reuse is safe.

### Public content

A marketing page can often be reused:

```text
Same page for every visitor
```

### Private content

A project list cannot be shared blindly:

```text
User A projects ≠ User B projects
```

LaunchPad private APIs use:

```http
Cache-Control: private, no-store
Vary: Cookie
```

This tells browsers and intermediaries not to store or share the private response.

---

## 24. Cache Safety Questions

Before caching data, ask:

```text
1. Who can read this result?
2. Does user identity change the result?
3. How long may the result be stale?
4. Which mutation invalidates it?
5. Could another user receive this result?
6. Is the result public, private, or mixed?
```

If you cannot answer these clearly, avoid shared caching.

---

## 25. Application Boundaries Summary

LaunchPad uses these main boundaries.

```text
Browser boundary
    ↓
Untrusted input

Server boundary
    ↓
Authentication and validation

Database boundary
    ↓
Persistence and authorization conditions

Cache boundary
    ↓
Public versus private reuse policy

Operations boundary
    ↓
Secrets, logs, monitoring, backups
```

A feature is safer when each boundary has a clear responsibility.

---

## 26. Primer Verification Exercise

Read this route flow:

```text
GET /projects?status=ACTIVE
```

Then answer:

```text
1. Where does status=ACTIVE live?
2. Where is the current user identified?
3. Where should project ownership be checked?
4. Where should immediate text search state live?
5. Where is the final persistent project list stored?
```

Expected answers:

```text
1. The URL.
2. Server-side session lookup.
3. In owner-scoped SQL.
4. Local Client Component state.
5. PostgreSQL.
```

---

## 27. Primer Completion Checklist

Before returning to the main series, you should understand:

- [ ] The difference between a request and a response.
- [ ] The browser, server, and database responsibilities.
- [ ] Why browser input is untrusted.
- [ ] What server rendering means.
- [ ] What hydration means.
- [ ] The difference between static and dynamic rendering.
- [ ] The difference between loading, empty, error, and not-found states.
- [ ] What server state is.
- [ ] What URL state is.
- [ ] What local Client Component state is.
- [ ] Why persistent changes must reach PostgreSQL.
- [ ] Why private data must be filtered before it reaches the browser.
- [ ] Why caching private data requires extra care.
- [ ] Why authentication, validation, and authorization occur on the server.
- [ ] The mutation lifecycle: authenticate, validate, authorize, mutate, revalidate.
