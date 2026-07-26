# LaunchPad: Student Workbook

## From Zero to Production with Next.js 16

This workbook is designed to help you track your progress, reinforce key concepts, and reflect on what you've learned as you build LaunchPad.

---

## Workbook Instructions

For each part, you'll find:

1. **Concept Check Questions** – Test your understanding of key ideas
2. **Code Implementation Tracker** – Track which files you've created/modified
3. **Verification Log** – Record successful verification outputs
4. **Reflection Questions** – Connect concepts to your own understanding

Fill this out as you progress through the series. Use it as a reference when you need to recall how something works.

---

## Part 1: Introduction to Next.js

### Concept Check Questions

1. What is the difference between React and Next.js?

```
[Your answer here]
```

2. What command creates a new Next.js application with the App Router and TypeScript?

```
[Your answer here]
```

3. What does the `layout.tsx` file do in the App Router?

```
[Your answer here]
```

4. What is the difference between `npm run dev` and `npm run build` followed by `npm run start`?

```
[Your answer here]
```

5. What is a Server Component and why is it the default in the App Router?

```
[Your answer here]
```

### Files Created/Modified

| File | Action |
|------|--------|
| `src/app/layout.tsx` | [Created / Replaced / Modified] |
| `src/app/page.tsx` | [Created / Replaced / Modified] |
| `src/app/globals.css` | [Created / Replaced / Modified] |

### Verification Results

| Command | Expected | Actual |
|---------|----------|--------|
| `node --version` | v20.9.0+ | |
| `npm --version` | Any valid version | |
| `npx tsc --noEmit` | No errors | |
| `npm run lint` | No errors | |
| `npm run build` | Build succeeds | |
| `curl http://localhost:3000` | Status 200 | |

### Reflections

What was the most surprising thing you learned in Part 1?

```
[Your answer here]
```

---

## Part 2: Routing and Pages

### Concept Check Questions

1. How does file-based routing work in Next.js?

```
[Your answer here]
```

2. What is the difference between a path parameter and a search parameter? Give an example of each.

```
[Your answer here]
```

3. What is a dynamic route segment and how is it defined in the file system?

```
[Your answer here]
```

4. Why should URL values be validated rather than trusted?

```
[Your answer here]
```

5. What does `generateStaticParams()` do and when is it useful?

```
[Your answer here]
```

### Files Created/Modified

| File | Action |
|------|--------|
| `src/app/about/page.tsx` | [Created / Replaced] |
| `src/app/features/page.tsx` | [Created / Replaced] |
| `src/app/projects/page.tsx` | [Created / Replaced] |
| `src/app/projects/[projectId]/page.tsx` | [Created / Replaced] |
| `src/app/not-found.tsx` | [Created / Replaced] |
| `src/components/site-header.tsx` | [Created / Replaced] |
| `src/lib/project-catalog.ts` | [Created / Replaced] |

### Verification Results

| Route | Expected Status | Actual |
|-------|-----------------|--------|
| `/` | 200 | |
| `/about` | 200 | |
| `/features` | 200 | |
| `/projects` | 200 | |
| `/projects?status=ACTIVE` | 200 | |
| `/projects/website-redesign` | 200 | |
| `/projects/not-a-real-project` | 404 | |
| `/does-not-exist` | 404 | |

### Reflections

What was the most challenging part of understanding Next.js routing?

```
[Your answer here]
```

---

## Part 3: Layouts and UI Composition

### Concept Check Questions

1. What is a route group and why would you use one?

```
[Your answer here]
```

2. How does a nested layout work in the App Router?

```
[Your answer here]
```

3. What is the purpose of the `children` prop in a layout component?

```
[Your answer here]
```

4. How does metadata composition work when you have metadata at multiple levels?

```
[Your answer here]
```

5. What is the difference between a layout and a template?

```
[Your answer here]
```

### Files Created/Modified

| File | Action |
|------|--------|
| `src/app/(marketing)/layout.tsx` | [Created / Replaced] |
| `src/app/(marketing)/page.tsx` | [Created / Replaced] |
| `src/app/(marketing)/about/page.tsx` | [Created / Replaced] |
| `src/app/(marketing)/features/page.tsx` | [Created / Replaced] |
| `src/app/(workspace)/layout.tsx` | [Created / Replaced] |
| `src/app/(workspace)/dashboard/page.tsx` | [Created / Replaced] |
| `src/app/(workspace)/projects/page.tsx` | [Created / Replaced] |
| `src/app/(workspace)/projects/[projectId]/page.tsx` | [Created / Replaced] |
| `src/components/site-footer.tsx` | [Created / Replaced] |
| `src/components/workspace-navigation.tsx` | [Created / Replaced] |

### Verification Results

| Route | Layout Applied | Public URL Correct? |
|-------|---------------|---------------------|
| `/` | Marketing | Yes / No |
| `/about` | Marketing | Yes / No |
| `/features` | Marketing | Yes / No |
| `/dashboard` | Workspace | Yes / No |
| `/projects` | Workspace | Yes / No |
| `/projects/[id]` | Workspace | Yes / No |

### Reflections

Why is it better to use layouts instead of repeating header and footer code on every page?

```
[Your answer here]
```

---

## Part 4: Server and Client Components

### Concept Check Questions

1. What makes a component a Server Component versus a Client Component?

```
[Your answer here]
```

2. What is the `"use client"` directive and when should you use it?

```
[Your answer here]
```

3. What is the `server-only` package used for?

```
[Your answer here]
```

4. Why should Client Components be kept small and focused?

```
[Your answer here]
```

5. What is hydration and why is it important?

```
[Your answer here]
```

### Files Created/Modified

| File | Action | Server or Client? |
|------|--------|-------------------|
| `src/lib/project-types.ts` | [Created] | |
| `src/lib/project-catalog.ts` | [Replaced] | Server-only |
| `src/components/workspace-navigation.tsx` | [Replaced] | |
| `src/components/project-list.tsx` | [Created] | |
| `src/components/interactive-disclosure.tsx` | [Created] | |
| `src/components/copy-project-link.tsx` | [Created] | |

### Verification Results

| Check | Pass/Fail |
|-------|-----------|
| Client Components don't import `project-catalog.ts` | |
| Active navigation works for all routes | |
| Project search updates immediately | |
| Refresh preserves URL status filter | |
| Disclosure controls work with keyboard | |
| Copy button handles success and failure | |

### Reflections

What would happen if you marked the entire workspace layout as a Client Component?

```
[Your answer here]
```

---

## Part 5: Data Fetching in Next.js 16

### Concept Check Questions

1. Why should browser code never connect directly to the database?

```
[Your answer here]
```

2. What is the purpose of Zod in data fetching?

```
[Your answer here]
```

3. What is parameterized SQL and why is it important?

```
[Your answer here]
```

4. What is Suspense and how does streaming improve perceived performance?

```
[Your answer here]
```

5. What is request memoization and when is it useful?

```
[Your answer here]
```

### Files Created/Modified

| File | Action |
|------|--------|
| `compose.yaml` | [Created] |
| `database/migrations/001_create_projects_and_tasks.sql` | [Created] |
| `database/seeds/development.sql` | [Created] |
| `.env.example` | [Created] |
| `.env.local` | [Created] |
| `src/lib/environment.ts` | [Created] |
| `src/lib/database/client.ts` | [Created] |
| `src/lib/database/schemas.ts` | [Created] |
| `src/lib/database/project-queries.ts` | [Created] |
| `src/app/(workspace)/projects/page.tsx` | [Replaced] |
| `src/app/(workspace)/projects/[projectId]/page.tsx` | [Replaced] |
| `src/components/dashboard-metrics.tsx` | [Created] |
| `src/components/dashboard-active-projects.tsx` | [Created] |
| `src/components/dashboard-skeletons.tsx` | [Created] |
| `src/app/(workspace)/dashboard/page.tsx` | [Replaced] |
| `src/app/(workspace)/error.tsx` | [Created] |

### Verification Results

| Check | Pass/Fail |
|-------|-----------|
| PostgreSQL container runs with health check | |
| Migration creates projects and tasks tables | |
| Seed creates 4 projects and 12 tasks | |
| `.env.local` is ignored by Git | |
| `/projects` reads from PostgreSQL | |
| Status filtering works | |
| Dynamic project routes return correct data | |
| Dashboard streams with Suspense | |
| Error boundary displays for database failures | |

### Reflections

What did you learn about the relationship between the database, query layer, and presentation layer?

```
[Your answer here]
```

---

## Part 6: Styling Your Application

### Concept Check Questions

1. What are design tokens and why are they useful?

```
[Your answer here]
```

2. How do CSS Modules differ from global CSS?

```
[Your answer here]
```

3. What is the purpose of `next/font`?

```
[Your answer here]
```

4. What is a skip link and why is it important for accessibility?

```
[Your answer here]
```

5. How do you handle prefers-reduced-motion in CSS?

```
[Your answer here]
```

### Files Created/Modified

| File | Action |
|------|--------|
| `src/app/layout.tsx` | [Replaced] |
| `src/styles/design-tokens.css` | [Created] |
| `src/styles/accessibility.css` | [Created] |
| `src/components/status-badge.module.css` | [Created] |
| `src/components/status-badge.tsx` | [Created] |
| `src/components/project-card.module.css` | [Created] |
| `src/components/project-card.tsx` | [Created] |
| `src/components/project-list.tsx` | [Replaced] |
| `src/components/dashboard-active-projects.tsx` | [Replaced] |
| `src/app/(workspace)/projects/[projectId]/page.tsx` | [Replaced] |

### Verification Results

| Check | Pass/Fail |
|-------|-----------|
| Geist fonts load correctly | |
| Design tokens are available | |
| Skip link works with Tab | |
| Status badges use CSS Modules | |
| Project cards use CSS Modules | |
| Print view hides navigation | |
| Reduced motion disables animations | |
| Responsive layout works | |
| Production build succeeds | |

### Reflections

What styling approach did you find most valuable, and why?

```
[Your answer here]
```

---

## Part 7: Building APIs and Full-Stack Features

### Concept Check Questions

1. What is a Route Handler and when would you use one versus a Server Action?

```
[Your answer here]
```

2. Why should input be validated on the server even when it's already validated in the browser?

```
[Your answer here]
```

3. What is revalidation and why is it needed after mutations?

```
[Your answer here]
```

4. What is the purpose of `useActionState`?

```
[Your answer here]
```

5. What is a transaction in SQL and when should you use one?

```
[Your answer here]
```

### Files Created/Modified

| File | Action |
|------|--------|
| `src/lib/task-types.ts` | [Created] |
| `src/lib/project-inputs.ts` | [Created] |
| `src/lib/database/schemas.ts` | [Replaced] |
| `src/lib/database/project-mutations.ts` | [Created] |
| `src/lib/database/health.ts` | [Created] |
| `src/lib/api-response.ts` | [Created] |
| `src/lib/action-state.ts` | [Created] |
| `src/app/api/projects/route.ts` | [Created] |
| `src/app/api/projects/[projectId]/route.ts` | [Created] |
| `src/app/api/health/route.ts` | [Created] |
| `src/app/(workspace)/projects/actions.ts` | [Created] |
| `src/app/(workspace)/projects/new/page.tsx` | [Created] |
| `src/components/create-project-form.tsx` | [Created] |
| `src/app/(workspace)/projects/[projectId]/actions.ts` | [Created] |
| `src/components/create-task-form.tsx` | [Created] |
| `src/components/task-list.tsx` | [Created] |
| `src/app/(workspace)/projects/[projectId]/page.tsx` | [Replaced] |

### Verification Results

| Check | Pass/Fail |
|-------|-----------|
| GET /api/projects returns projects | |
| POST /api/projects creates a project | |
| Invalid status returns 400 | |
| Invalid JSON returns 400 | |
| Project creation form works | |
| Task creation works | |
| Task status update works | |
| Health endpoint returns 200 | |
| Production build succeeds | |

### Reflections

What's the difference between a Route Handler and a Server Action? When would you choose one over the other?

```
[Your answer here]
```

---

## Part 8: Authentication and State Management

### Concept Check Questions

1. What is the difference between authentication and authorization?

```
[Your answer here]
```

2. Why are passwords hashed with bcrypt instead of stored as plaintext?

```
[Your answer here]
```

3. Why is the session token stored as a hash in the database?

```
[Your answer here]
```

4. What are the important cookie attributes for security and why?

```
[Your answer here]
```

5. Why should database queries include `owner_id` conditions?

```
[Your answer here]
```

### Files Created/Modified

| File | Action |
|------|--------|
| `database/migrations/002_add_users_sessions_and_ownership.sql` | [Created] |
| `database/seeds/development.sql` | [Replaced] |
| `src/lib/auth-types.ts` | [Created] |
| `src/lib/auth-inputs.ts` | [Created] |
| `src/lib/auth/accounts.ts` | [Created] |
| `src/lib/auth/session-store.ts` | [Created] |
| `src/lib/auth/session.ts` | [Created] |
| `src/app/(auth)/actions.ts` | [Created] |
| `src/components/sign-in-form.tsx` | [Created] |
| `src/components/sign-up-form.tsx` | [Created] |
| `src/app/(auth)/layout.tsx` | [Created] |
| `src/app/(auth)/sign-in/page.tsx` | [Created] |
| `src/app/(auth)/sign-up/page.tsx` | [Created] |
| `src/components/account-menu.tsx` | [Created] |
| `src/app/(workspace)/layout.tsx` | [Replaced] |
| `src/lib/database/project-queries.ts` | [Replaced] |
| `src/lib/database/project-mutations.ts` | [Replaced] |
| `src/app/api/projects/route.ts` | [Replaced] |
| `src/app/api/projects/[projectId]/route.ts` | [Replaced] |

### Verification Results

| Check | Pass/Fail |
|-------|-----------|
| Users table created with bcrypt hashed passwords | |
| Sessions table stores token hashes | |
| Sign-up creates a user account | |
| Sign-in creates a session and cookie | |
| Cookie is HttpOnly and Secure | |
| Protected routes redirect unauthenticated users | |
| Owner-scoped queries work | |
| Cross-user isolation works (404 for other users' projects) | |
| Sign-out deletes the session | |
| Production build succeeds | |

### Reflections

What is the most important security concept you learned in this part?

```
[Your answer here]
```

---

## Part 9: Performance and Optimization

### Concept Check Questions

1. Why should you measure performance before optimizing?

```
[Your answer here]
```

2. What is the purpose of `next/image` and what problem does it solve?

```
[Your answer here]
```

3. What is code splitting and when should you use it?

```
[Your answer here]
```

4. What is the difference between `Cache-Control: private, no-store` and `Cache-Control: no-store`?

```
[Your answer here]
```

5. What are Core Web Vitals and why are they important?

```
[Your answer here]
```

### Files Created/Modified

| File | Action |
|------|--------|
| `scripts/measure-routes.sh` | [Created] |
| `scripts/generate-launchpad-image.py` | [Created] |
| `public/launchpad-dashboard.png` | [Created] |
| `src/app/(marketing)/page.tsx` | [Replaced] |
| `src/components/project-insights.tsx` | [Created] |
| `src/components/project-insights-loader.tsx` | [Created] |
| `src/app/(workspace)/projects/[projectId]/page.tsx` | [Replaced] |
| `src/lib/api-response.ts` | [Replaced] |
| `src/app/api/projects/route.ts` | [Replaced] |
| `src/app/api/projects/[projectId]/route.ts` | [Replaced] |
| `src/app/api/health/route.ts` | [Replaced] |
| `next.config.ts` | [Replaced] |

### Verification Results

| Check | Pass/Fail |
|-------|-----------|
| Baseline performance measured | |
| Image generation works | |
| `next/image` used on home page | |
| Image has width, height, and sizes | |
| Priority only used on hero image | |
| Optional insights load on demand | |
| Private APIs use `private, no-store` | |
| Health endpoint uses `no-store` | |
| Bundle analyzer runs | |
| Client Component audit passes | |
| Lighthouse audit shows no major issues | |
| Production timing after optimization | |

### Reflections

Which optimization made the biggest impact on performance or user experience?

```
[Your answer here]
```

---

## Part 10: Deployment and Production Readiness

### Concept Check Questions

1. Why should environment variables be validated at startup?

```
[Your answer here]
```

2. What is a tracked migration system and why is it important?

```
[Your answer here]
```

3. What is the difference between liveness and readiness?

```
[Your answer here]
```

4. Why is structured logging preferable to plain text logs?

```
[Your answer here]
```

5. What should a production runbook contain?

```
[Your answer here]
```

### Files Created/Modified

| File | Action |
|------|--------|
| `src/lib/environment.ts` | [Replaced] |
| `src/lib/database/client.ts` | [Replaced] |
| `scripts/migrate.mjs` | [Created] |
| `src/lib/logger.ts` | [Created] |
| `src/app/api/live/route.ts` | [Created] |
| `src/app/api/health/route.ts` | [Replaced] |
| `next.config.ts` | [Replaced] |
| `Dockerfile` | [Created] |
| `.dockerignore` | [Created] |
| `scripts/smoke-test.mjs` | [Created] |
| `.github/workflows/ci.yml` | [Created] |
| `src/components/web-vitals-reporter.tsx` | [Created] |
| `src/app/layout.tsx` | [Replaced] |
| `docs/production-runbook.md` | [Created] |
| `docs/deployment-checklist.md` | [Created] |

### Verification Results

| Check | Pass/Fail |
|-------|-----------|
| Environment validation works | |
| Migration tracking works | |
| Structured logging works | |
| `/api/live` returns 200 without DB | |
| `/api/health` returns 503 without DB | |
| Security headers are present | |
| Docker image builds and runs | |
| Smoke tests pass | |
| CI pipeline works | |
| Production deployment succeeds | |
| Authentication works in production | |

### Reflections

What was the most valuable lesson about deployment and production readiness?

```
[Your answer here]
```

---

## Final Project Review

### Architecture Summary

Draw a diagram of the final application architecture:

```
[Your diagram here]
```

### Key Files Reference

List the most important files and what they do:

| File | Purpose |
|------|---------|
| `src/app/layout.tsx` | |
| `src/app/(workspace)/layout.tsx` | |
| `src/lib/auth/session.ts` | |
| `src/lib/database/client.ts` | |
| `src/lib/database/project-queries.ts` | |
| `src/lib/database/project-mutations.ts` | |
| `src/lib/api-response.ts` | |
| `next.config.ts` | |

### What You Learned

List the top 5 most important concepts you learned:

1. 
2. 
3. 
4. 
5. 

### What You Want to Learn Next

What would you like to explore further after completing this series?

```
[Your answer here]
```

---

## Troubleshooting Log

Use this section to track any issues you encountered and how you resolved them:

| Issue | Error | Solution |
|-------|-------|----------|
| | | |
| | | |
| | | |
| | | |
| | | |

---

## Command Reference

Keep a reference of the most useful commands:

| Command | Purpose |
|---------|---------|
| `npm run dev` | |
| `npm run build` | |
| `npm run start` | |
| `npm run typecheck` | |
| `npm run lint` | |
| `npm run db:migrate` | |
| `npm run db:seed` | |
| `npm run analyze` | |

---

## Final Thoughts

What will you take away from building LaunchPad?

```
[Your answer here]
```
