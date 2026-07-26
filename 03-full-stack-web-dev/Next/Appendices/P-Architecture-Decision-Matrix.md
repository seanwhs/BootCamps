# Appendix P: LaunchPad Architecture Decision Matrix

This appendix helps you choose the correct Next.js pattern when several options appear possible.

Use it before adding a feature to avoid placing code in the wrong layer.

---

## P.1 Where Should Data Be Loaded?

| Requirement | Preferred location | Why |
|---|---|---|
| Render initial page data | Async Server Component | Keeps database access server-side |
| Load a private project | Server Component + owner-scoped query | Enforces authorization before rendering |
| Return JSON to another client | Route Handler | Provides explicit HTTP contract |
| Handle a Next.js form mutation | Server Action | Integrates with forms and revalidation |
| Load optional browser-only feature | Client Component with dynamic import | Avoids initial bundle cost |
| Load data after a browser-only interaction | Client Component calling a protected API | Use only when server rendering is not suitable |

Default rule:

```text
Start with a Server Component.
Move code into a Client Component only when browser behavior is required.
```

---

## P.2 Where Should State Live?

| State | Preferred owner | Example |
|---|---|---|
| Persistent project record | PostgreSQL | Project name and status |
| User identity | Server session | Current authenticated user |
| Shareable filter | URL | `?status=ACTIVE` |
| Temporary text search | Local component state | Search input value |
| Disclosure visibility | Local component state | Open or closed panel |
| Pending form submission | `useActionState` | Creating a project |
| Cached public content | Framework cache or static rendering | Marketing pages |
| Private user data | Server request path | Owned projects |

Decision rule:

```text
Should the state survive refresh and be shareable?
    └── Use URL state.

Is it authoritative application data?
    └── Store it in PostgreSQL.

Is it temporary browser interaction?
    └── Use local Client Component state.
```

---

## P.3 Server Action or Route Handler?

| Requirement | Use Server Action | Use Route Handler |
|---|---:|---:|
| Submitted by a LaunchPad form | Yes | Possible, but less direct |
| Needs JSON response for another client | No | Yes |
| Used by mobile application | No | Yes |
| Used by third-party integration | No | Yes |
| Needs explicit HTTP status contract | Usually no | Yes |
| Needs form pending state | Yes | Possible with custom fetch logic |
| Needs framework redirect after mutation | Yes | Possible, but manual |
| Needs webhook endpoint | No | Yes |

Examples:

```text
Create project from LaunchPad form
→ Server Action

GET /api/projects for another client
→ Route Handler

Receive payment-provider webhook
→ Route Handler

Sign out from LaunchPad account menu
→ Server Action
```

---

## P.4 Static or Dynamic Rendering?

| Route type | Preferred strategy | Reason |
|---|---|---|
| Marketing home | Static | Same public content for every visitor |
| About page | Static | No private request data |
| Features page | Static | No private request data |
| Sign-in page | Dynamic/request-aware | Redirect signed-in users |
| Dashboard | Dynamic | Depends on session and private data |
| Project list | Dynamic | Depends on user and URL filters |
| Project details | Dynamic | Depends on user ownership |
| Health endpoint | Dynamic, no-store | Must reflect current service status |
| Private project API | Dynamic, private no-store | User-specific data |

Never globally cache private project results without a deliberate identity-aware cache design.

---

## P.5 Which Error Outcome Is Correct?

| Situation | Correct behavior |
|---|---|
| Invalid form field | Field-level validation error |
| Invalid JSON body | `400 INVALID_JSON` |
| Valid JSON with invalid values | `422 VALIDATION_ERROR` |
| Missing session for private API | `401 UNAUTHORIZED` |
| Missing session for private page | Redirect to `/sign-in` |
| Missing project | Not-found UI or `404` |
| Another user’s private project | Not-found UI or `404` |
| PostgreSQL unavailable | Error boundary or `503` |
| Unknown programming failure | Safe error UI and structured log |
| Empty project list | Empty-state UI, not error UI |

A useful distinction:

```text
Loading
→ Work has not finished.

Empty
→ Work finished; there are no matching results.

Validation error
→ Caller supplied unsupported input.

Not found
→ Resource is absent or private.

Unexpected error
→ The system could not complete expected work.
```

---

## P.6 Which Component Type Should I Use?

| Requirement | Component type |
|---|---|
| Display database result | Server Component |
| Render static page content | Server Component |
| Use `useState` | Client Component |
| Handle `onClick` | Client Component |
| Use clipboard API | Client Component |
| Use `usePathname` | Client Component |
| Render reusable presentational card | Server-compatible component |
| Show a form with `useActionState` | Client Component |
| Query authenticated database record | Server Component or server-only function |
| Render Route Handler JSON | Not a component; use `route.ts` |

Example component boundary:

```text
Server Project Page
├── Authorized database query
├── Project heading
├── Task list
├── Client CopyLink button
├── Client disclosure
└── Client optional insights loader
```

---

## P.7 Validation and Security Decision Matrix

| Input source | Must validate? | Must authenticate? | Must authorize? |
|---|---:|---:|---:|
| Public search parameter | Yes | Usually no | Usually no |
| Protected route parameter | Yes | Yes | Yes |
| Project creation form | Yes | Yes | Ownership derives from user |
| Task status form | Yes | Yes | Yes |
| Public health request | No input body | No | No |
| Private API request | Yes | Yes | Yes |
| Webhook payload | Yes | Provider verification | Event-specific |
| Environment variable | Yes | Not applicable | Not applicable |

The complete protected-mutation sequence is:

```text
Receive request
    ↓
Authenticate user
    ↓
Validate IDs and input fields
    ↓
Run owner-scoped mutation
    ↓
Revalidate affected data
    ↓
Return safe response
```

---

## P.8 Cache Decision Matrix

| Data type | Suggested policy |
|---|---|
| Public marketing content | Static or revalidated cache |
| Optimized static image | Immutable asset cache |
| Public liveness response | `no-store` |
| Database readiness response | `no-store` |
| User project API response | `private, no-store` |
| Session lookup | Request memoization |
| Owned project lookup | Request memoization keyed by user and project |
| Form mutation response | Do not rely on shared cache |
| Browser local search result | Local derived state |

Before adding a cache, answer:

```text
Who may read this result?
How long may it remain stale?
What mutation invalidates it?
Does identity affect the result?
Could shared reuse expose private data?
```

If any answer is unclear, do not add a shared cache yet.

---

## P.9 Database Change Decision Matrix

| Change | Requires migration? | Requires seed update? | Requires query update? |
|---|---:|---:|---:|
| Add project field | Yes | Usually | Yes |
| Add project status | Usually | Yes | Yes |
| Add task priority | Usually | Yes | Yes |
| Add index | Yes | No | Usually no |
| Add user profile field | Yes | Usually | Yes |
| Change validation-only copy | No | No | No |
| Add client-side visual state | No | No | No |
| Add API response field | Maybe | No | Yes |
| Add archive behavior | Yes | Usually | Yes |

For database changes:

```text
Migration
    ↓
Database schema
    ↓
Seed update
    ↓
Zod schemas
    ↓
TypeScript types
    ↓
Queries and mutations
    ↓
UI and API response
    ↓
Verification
```

---

## P.10 Final Decision Rule

When uncertain, ask these questions in order:

1. **Is this data private or authoritative?**  
   Keep it on the server and in PostgreSQL.

2. **Does it need browser interactivity?**  
   Use the smallest possible Client Component.

3. **Should it be shareable or bookmarkable?**  
   Put it in the URL.

4. **Does it change persistent data?**  
   Use a Server Action or Route Handler with validation, authentication, and authorization.

5. **Could another user attempt this operation?**  
   Put ownership conditions in the SQL query or mutation.

6. **Can the result be reused safely?**  
   Define explicit cache policy—or avoid shared caching.

7. **Does it change production behavior?**  
   Update migrations, environment configuration, CI, monitoring, and runbooks as necessary.
