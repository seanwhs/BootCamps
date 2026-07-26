# LaunchPad: Trainer Guide

## From Zero to Production with Next.js 16

---

## Table of Contents

1. [Course Overview](#course-overview)
2. [Trainer Preparation](#trainer-preparation)
3. [Session Structure](#session-structure)
4. [Day-by-Day Lesson Plans](#day-by-day-lesson-plans)
5. [Common Issues and Solutions](#common-issues-and-solutions)
6. [Assessment Guide](#assessment-guide)
7. [Extension Activities](#extension-activities)
8. [Resources and References](#resources-and-references)

---

## Course Overview

### Course Description

This course guides students through building a production-ready Next.js 16 application called "LaunchPad" – a project and task management tool with authentication, database persistence, and full-stack features. Students learn by doing, implementing each feature layer by layer while understanding the architectural decisions behind each choice.

### Learning Objectives

By the end of this course, students will be able to:

**Fundamental Skills**
- Create and configure a Next.js 16 application with TypeScript
- Implement file-based routing with static and dynamic routes
- Build nested layouts with route groups
- Distinguish between Server and Client Components and use each appropriately
- Fetch data from PostgreSQL in Server Components
- Style applications with global CSS, design tokens, and CSS Modules

**Full-Stack Skills**
- Build API endpoints with Route Handlers
- Implement Server Actions for form mutations
- Validate input with Zod schemas
- Create authentication with database-backed sessions
- Enforce authorization with owner-scoped queries
- Manage server, URL, and client state appropriately

**Production Skills**
- Optimize performance with `next/image` and code splitting
- Configure security headers and cache policies
- Build and deploy with Docker
- Implement health checks and structured logging
- Set up continuous integration
- Document production operations

### Prerequisites for Students

Students should have:
- Basic HTML and CSS knowledge
- Introductory JavaScript experience
- Familiarity with React components (basic understanding of props and state)
- Ability to use a terminal and code editor
- Node.js 20.9+ and Git installed

### Target Audience

- Junior to mid-level web developers transitioning to Next.js
- Frontend developers expanding into full-stack development
- Backend developers learning modern frontend frameworks
- Bootcamp graduates building portfolio projects

---

## Trainer Preparation

### Technical Requirements

**Hardware**
- Modern laptop with 16GB+ RAM (8GB minimum)
- Docker Desktop installed
- 20GB+ free disk space for Docker images and node_modules
- Stable internet connection

**Software Requirements**
- Node.js 22 LTS or newer
- npm 10.x or newer
- Git
- Docker Desktop (with Docker Compose)
- Code editor (VS Code recommended with ESLint and TypeScript extensions)
- PostgreSQL client (optional, for debugging)
- Python 3 (for image generation in Part 9)
- Modern browser (Chrome or Firefox recommended)

### Pre-Course Checklist

- [ ] Verify Node.js version: `node --version` (should be v20.9.0+)
- [ ] Verify npm version: `npm --version`
- [ ] Verify Git: `git --version`
- [ ] Docker Desktop installed and running
- [ ] VS Code with ESLint and TypeScript extensions
- [ ] Clone or prepare the starter repository (if using)
- [ ] Test all commands on your machine
- [ ] Prepare backup solutions for Windows vs macOS/Linux differences
- [ ] Set up screen sharing/projector
- [ ] Prepare slides or visual aids

### Recommended Trainer Knowledge

Before teaching, you should be comfortable with:
- Next.js 16 App Router architecture
- Server and Client Component patterns
- PostgreSQL and SQL basics
- TypeScript fundamentals
- Authentication patterns (sessions, cookies, bcrypt)
- Docker containerization
- GitHub Actions or similar CI/CD
- Production deployment practices

---

## Session Structure

### Suggested Schedule (10 Sessions × 3 Hours = 30 Hours Total)

| Session | Part | Focus | Duration |
|---------|------|-------|----------|
| 1 | Part 1-2 | Introduction, Routing Basics | 3 hours |
| 2 | Part 3 | Layouts and UI Composition | 3 hours |
| 3 | Part 4 | Server and Client Components | 3 hours |
| 4 | Part 5 | Data Fetching (Part 1) | 3 hours |
| 5 | Part 5-6 | Data Fetching (Part 2), Styling | 3 hours |
| 6 | Part 7 | APIs and Full-Stack Features | 3 hours |
| 7 | Part 8 | Authentication (Part 1) | 3 hours |
| 8 | Part 8-9 | Authentication (Part 2), Performance | 3 hours |
| 9 | Part 9-10 | Performance, Deployment Prep | 3 hours |
| 10 | Part 10 | Deployment and Production | 3 hours |

### Session Format

Each 3-hour session follows this structure:

| Time | Activity | Description |
|------|----------|-------------|
| 15 min | Opening/Review | Recap previous session, Q&A |
| 30 min | Concept Introduction | New concepts with slides/demo |
| 90 min | Hands-on Lab | Students implement guided steps |
| 15 min | Mid-Session Check | Address common issues |
| 20 min | Independent Practice | Students explore/extend |
| 10 min | Closing/Preview | Review key takeaways, preview next |

### Teaching Methods

1. **Live Coding**: Demonstrate key concepts on screen
2. **Guided Labs**: Students follow step-by-step instructions
3. **Pair Programming**: Students work in pairs on complex sections
4. **Code Reviews**: Review completed sections as a group
5. **Discussion**: Explain architectural trade-offs and "why"
6. **Self-Directed**: Students extend features independently

---

## Day-by-Day Lesson Plans

---

### Session 1: Introduction and Routing (Parts 1-2)

#### Session Objectives
- Set up Next.js 16 development environment
- Understand App Router file conventions
- Create static and dynamic routes
- Implement navigation with `next/link`
- Handle route parameters and search parameters

#### Agenda

| Time | Activity | Materials |
|------|----------|-----------|
| 15 min | Welcome, course overview | Slides, course outline |
| 20 min | Live demo: Create Next.js app, explore structure | Code editor, terminal |
| 30 min | Concept: File-based routing, dynamic routes | Slides with diagrams |
| 60 min | Lab: Create routes, navigation, project list | Lab 2 instructions |
| 15 min | Check-in: Review common issues | Projector, code review |
| 25 min | Lab: Dynamic routes and not-found | Lab 2 instructions |
| 15 min | Closing: Key takeaways, preview | Slides |

#### Key Talking Points

1. **React vs Next.js**: Use the restaurant kitchen analogy
2. **Server vs Client**: Emphasize that pages are Server Components by default
3. **Route Groups**: Explain that parentheses don't appear in URLs
4. **Dynamic Segments**: Show how `[projectId]` captures URL values
5. **Security**: Always validate URL parameters

#### Demonstration Code

```bash
# Create project
npx create-next-app@16 launchpad --typescript --eslint --app --src-dir --no-tailwind --turbopack --import-alias "@/*" --use-npm --yes

# Start development
npm run dev
```

#### Common Student Questions

**Q: Why do we use `as const` on the feature data?**
A: It tells TypeScript the values are exact literals (not just strings), enabling better type inference.

**Q: Why do we need to await `searchParams`?**
A: In Next.js 16, `searchParams` is a Promise to support streaming and async routing.

**Q: Why can't I just use `<a>` for navigation?**
A: `<a>` causes full page reloads. `next/link` enables client-side transitions and prefetching.

---

### Session 2: Layouts and UI Composition (Part 3)

#### Session Objectives
- Understand nested layouts and route groups
- Build shared navigation and footer components
- Create marketing and workspace layouts
- Implement responsive workspace sidebar
- Understand metadata inheritance

#### Agenda

| Time | Activity | Materials |
|------|----------|-----------|
| 15 min | Review: Routing concepts, Q&A | Slides |
| 25 min | Concept: Layouts, route groups, composition | Diagrams |
| 60 min | Lab: Create route groups, marketing layout | Lab 3 instructions |
| 15 min | Break/Check-in | |
| 30 min | Concept: Workspace layout, metadata | Slides |
| 45 min | Lab: Workspace layout, dashboard page | Lab 3 instructions |
| 20 min | Closing: Review, preview | Slides |

#### Key Talking Points

1. **Layouts as Frames**: Layouts surround pages like picture frames
2. **Route Groups**: Organize without affecting URLs
3. **Metadata Inheritance**: Child routes override specific fields
4. **`noindex`**: Workspace pages should not appear in search results
5. **Responsive Sidebar**: Use CSS Grid, media queries

#### Demonstration: Layout Hierarchy

```
RootLayout
├── MarketingLayout
│   ├── /
│   ├── /about
│   └── /features
└── WorkspaceLayout
    ├── /dashboard
    ├── /projects
    └── /projects/[projectId]
```

#### Common Student Questions

**Q: Why do marketing and workspace routes need different layouts?**
A: Marketing pages need a public header/footer; workspace pages need sidebar navigation.

**Q: What's the difference between `layout.tsx` and `template.tsx`?**
A: Layouts persist across navigation; templates remount, resetting state.

**Q: Can I have multiple root layouts?**
A: Yes, with multiple route groups, but it can cause full page reloads on navigation.

---

### Session 3: Server and Client Components (Part 4)

#### Session Objectives
- Understand Server vs Client Component responsibilities
- Use `server-only` to protect server code
- Create focused Client Components for interactivity
- Pass data across the server/client boundary
- Build interactive UI (search, disclosure, clipboard)

#### Agenda

| Time | Activity | Materials |
|------|----------|-----------|
| 15 min | Review: Layouts, Q&A | Slides |
| 30 min | Concept: Server/Client components, hydration | Diagrams |
| 60 min | Lab: Create shared types, server-only catalog | Lab 4 instructions |
| 15 min | Break/Check-in | |
| 30 min | Concept: Client patterns (search, disclosure) | Demo |
| 60 min | Lab: Interactive components, active navigation | Lab 4 instructions |
| 10 min | Closing: Review, preview | Slides |

#### Key Talking Points

1. **Server Components are Default**: Start with server, add `"use client"` only when needed
2. **Theater Analogy**: Backstage (server) vs audience (client)
3. **`server-only`**: Prevents unsafe imports into client bundles
4. **Serializable Props**: Only plain data can cross the boundary
5. **`usePathname`**: Client hook for active navigation

#### Component Boundary Map

```
Server: ProjectsPage
├── Server-rendered heading
├── Server-rendered status form
└── Client: ProjectList
    ├── Search state
    ├── Input event handling
    └── Filtered project cards
```

#### Common Student Questions

**Q: How do I know if a component should be server or client?**
A: Ask: "Does this need browser APIs, state, or event handlers?" If no, keep it server.

**Q: Why can't I import a server module in a Client Component?**
A: Server modules may contain database code, secrets, or Node.js APIs that don't work in the browser.

**Q: What's hydration and why does it matter?**
A: Hydration attaches JavaScript behavior to server-rendered HTML. Mismatches cause errors.

---

### Session 4: Data Fetching (Part 5 - Part 1)

#### Session Objectives
- Set up PostgreSQL with Docker
- Understand database schema design
- Create migrations and seed data
- Validate environment variables
- Build a database client and query functions

#### Agenda

| Time | Activity | Materials |
|------|----------|-----------|
| 15 min | Review: Server/Client, Q&A | Slides |
| 30 min | Concept: Database architecture, Docker | Diagrams |
| 60 min | Lab: PostgreSQL setup, migrations, seed | Lab 5 instructions |
| 15 min | Break/Check-in | |
| 30 min | Concept: Environment, client, queries | Demo |
| 45 min | Lab: Database client, queries | Lab 5 instructions |
| 15 min | Closing: Review, preview | Slides |

#### Key Talking Points

1. **Browser ≠ Database**: Never expose database credentials to the browser
2. **Parameterized SQL**: Always use tagged templates, never string concatenation
3. **Runtime Validation**: TypeScript types disappear at runtime; use Zod
4. **Request Memoization**: `cache()` deduplicates identical queries per request

#### Database Architecture Flow

```
Browser
   ↓
Server Component
   ↓
Query Function (server-only)
   ↓
Database Client (server-only)
   ↓
PostgreSQL
```

#### Common Student Questions

**Q: Why Docker for PostgreSQL?**
A: Docker provides a repeatable development environment that works the same on any machine.

**Q: What's the difference between `npm install` and `npm ci`?**
A: `npm ci` installs exactly from the lock file; used in CI environments.

**Q: Why use Zod for validation?**
A: TypeScript types don't exist at runtime; Zod validates actual data.

---

### Session 5: Data Fetching (Part 5 - Part 2) and Styling (Part 6)

#### Session Objectives
- Replace catalog data with database queries
- Implement streaming with Suspense
- Add loading and error boundaries
- Configure optimized fonts
- Create design tokens and CSS Modules

#### Agenda

| Time | Activity | Materials |
|------|----------|-----------|
| 15 min | Review: Database setup, Q&A | Slides |
| 45 min | Lab: Replace catalog with database | Lab 5 instructions |
| 30 min | Concept: Streaming, Suspense, boundaries | Demo |
| 45 min | Lab: Streaming dashboard, error boundary | Lab 5 instructions |
| 15 min | Break | |
| 45 min | Concept: `next/font`, tokens, CSS Modules | Demo |
| 25 min | Lab: Styling foundation | Lab 6 instructions |
| 15 min | Closing: Review, preview | Slides |

#### Key Talking Points

1. **Streaming**: Send ready parts of the page while others load
2. **Suspense Boundaries**: Place at meaningful component boundaries
3. **Loading vs Error**: Different states for different situations
4. **`next/font`**: Self-hosted, optimized fonts with zero external requests
5. **CSS Modules**: Locally scoped styles for components

#### Suspense Boundary Placement

```tsx
<Suspense fallback={<MetricsSkeleton />}>
  <DashboardMetrics />
</Suspense>

<Suspense fallback={<ProjectsSkeleton />}>
  <ActiveProjects />
</Suspense>
```

#### Common Student Questions

**Q: Does streaming make database queries faster?**
A: No, it changes delivery behavior. It sends completed sections earlier.

**Q: When should I use `loading.tsx` vs Suspense?**
A: `loading.tsx` is route-level; Suspense is component-level for more granular control.

**Q: Why use CSS Modules instead of global CSS?**
A: CSS Modules prevent class name collisions and make style ownership clear.

---

### Session 6: APIs and Full-Stack Features (Part 7)

#### Session Objectives
- Build Route Handlers for JSON APIs
- Create Server Actions for form mutations
- Implement shared validation schemas
- Build project and task creation
- Handle mutation feedback and revalidation

#### Agenda

| Time | Activity | Materials |
|------|----------|-----------|
| 15 min | Review: Data fetching, styling, Q&A | Slides |
| 30 min | Concept: API architecture, Route Handlers | Slides |
| 45 min | Lab: Route Handlers, API responses | Lab 7 instructions |
| 15 min | Break/Check-in | |
| 30 min | Concept: Server Actions, forms | Demo |
| 60 min | Lab: Server Actions, forms, tasks | Lab 7 instructions |
| 15 min | Closing: Review, preview | Slides |

#### Key Talking Points

1. **Route Handlers vs Server Actions**: HTTP APIs vs form-integrated mutations
2. **Validation**: Browser validation is UX; server validation is security
3. **Revalidation**: Mutations must refresh affected routes
4. **`useActionState`**: Connects forms to Server Actions with pending state

#### Request Flow Comparison

**Server Action**
```
Form submit → Server Action → Validation → Database → Revalidation → Redirect
```

**Route Handler**
```
HTTP request → Route Handler → Validation → Database → JSON Response
```

#### Common Student Questions

**Q: When should I use a Route Handler vs Server Action?**
A: Use Route Handlers for external APIs, mobile clients, or explicit HTTP endpoints. Use Server Actions for Next.js forms.

**Q: Why do we need both client and server validation?**
A: Client validation provides immediate feedback; server validation ensures security.

**Q: What's `revalidatePath` doing?**
A: It invalidates cached data for the specified routes so they reflect the new state.

---

### Session 7: Authentication (Part 8 - Part 1)

#### Session Objectives
- Understand authentication vs authorization
- Create user and session tables
- Implement password hashing with bcrypt
- Build session management with cookies
- Create sign-in and sign-up flows

#### Agenda

| Time | Activity | Materials |
|------|----------|-----------|
| 15 min | Review: Full-stack features, Q&A | Slides |
| 30 min | Concept: Authentication architecture | Slides, diagrams |
| 60 min | Lab: User and session migrations | Lab 8 instructions |
| 15 min | Break/Check-in | |
| 30 min | Concept: Password hashing, sessions, cookies | Demo |
| 60 min | Lab: Authentication actions, forms | Lab 8 instructions |
| 15 min | Closing: Review, preview | Slides |

#### Key Talking Points

1. **Authentication vs Authorization**: Identity vs permissions
2. **Password Hashing**: bcrypt is intentionally slow to resist brute force
3. **Session Tokens**: Random + hashed for database storage
4. **Cookie Security**: HttpOnly, Secure, SameSite
5. **Generic Error Messages**: Don't reveal whether an email exists

#### Authentication Flow

```
User submits credentials
    ↓
Server verifies with bcrypt
    ↓
Server creates random token
    ↓
Database stores SHA-256 hash
    ↓
Browser receives HTTP-only cookie
    ↓
Future requests: cookie → hash → session → user
```

#### Common Student Questions

**Q: Why bcrypt for passwords but SHA-256 for session tokens?**
A: Passwords are low-entropy; bcrypt is slow and salted. Session tokens are high-entropy random data; SHA-256 is sufficient.

**Q: What's the difference between HttpOnly and Secure cookies?**
A: HttpOnly prevents JavaScript access; Secure requires HTTPS. Both are important.

**Q: Why return 404 for unauthorized resources?**
A: Returning 403 would confirm the resource exists. 404 doesn't distinguish.

---

### Session 8: Authentication (Part 8 - Part 2) and Performance (Part 9 - Part 1)

#### Session Objectives
- Protect workspace routes and APIs
- Implement owner-scoped queries
- Enforce cross-user isolation
- Establish performance baseline
- Generate and optimize images
- Implement code splitting

#### Agenda

| Time | Activity | Materials |
|------|----------|-----------|
| 15 min | Review: Authentication basics, Q&A | Slides |
| 45 min | Lab: Protect routes, owner-scoped queries | Lab 8 instructions |
| 30 min | Concept: Authorization patterns | Slides |
| 15 min | Break/Check-in | |
| 30 min | Lab: Cross-user isolation verification | Lab 8 instructions |
| 45 min | Concept: Performance measurement, optimization | Slides |
| 30 min | Lab: Image generation, code splitting | Lab 9 instructions |
| 15 min | Closing: Review, preview | Slides |

#### Key Talking Points

1. **Authorization in SQL**: Every query includes `owner_id` condition
2. **Defense in Depth**: Pages, APIs, and database all enforce authorization
3. **Performance Measurement**: Always measure before optimizing
4. **`next/image`**: Automatic optimization, responsive images
5. **Code Splitting**: Load optional code only when needed

#### Authorization SQL Pattern

```sql
-- Safe read
SELECT * FROM projects
WHERE id = $projectId AND owner_id = $userId

-- Safe update
UPDATE projects
SET status = $status
WHERE id = $projectId AND owner_id = $userId
```

#### Common Student Questions

**Q: Why check ownership in SQL instead of just in page code?**
A: Attackers can bypass page code. SQL is the final security boundary.

**Q: How do I know what to optimize?**
A: Measure first. Optimize what's actually slow, not what you think might be slow.

**Q: When should I use code splitting?**
A: For optional, non-critical features that users may not need immediately.

---

### Session 9: Performance (Part 9 - Part 2) and Deployment (Part 10 - Part 1)

#### Session Objectives
- Configure cache policies
- Run bundle analysis
- Audit with Lighthouse
- Validate environment configuration
- Set up tracked migrations
- Add structured logging

#### Agenda

| Time | Activity | Materials |
|------|----------|-----------|
| 15 min | Review: Performance basics, Q&A | Slides |
| 45 min | Lab: Cache policies, bundle analysis | Lab 9 instructions |
| 30 min | Concept: Lighthouse, Core Web Vitals | Slides |
| 15 min | Break/Check-in | |
| 30 min | Concept: Production readiness, environment | Slides |
| 60 min | Lab: Migration runner, logging | Lab 10 instructions |
| 15 min | Closing: Review, preview | Slides |

#### Key Talking Points

1. **Cache Policies**: `private, no-store` for auth data; `no-store` for health
2. **Bundle Analysis**: Identify large dependencies, accidental client bundles
3. **Core Web Vitals**: LCP, CLS, INP
4. **Environment Validation**: Fail fast on invalid config
5. **Tracked Migrations**: Checksum verification prevents tampering
6. **Structured Logging**: Machine-readable, safe, searchable

#### Cache Headers Guide

| Header | Use Case |
|--------|----------|
| `Cache-Control: private, no-store` | Authenticated data |
| `Cache-Control: no-store` | Health checks |
| `Cache-Control: public, max-age=3600` | Public marketing content |

#### Common Student Questions

**Q: Why is `private, no-store` important for private data?**
A: `private` prevents shared caches; `no-store` prevents caching altogether.

**Q: What's a checksum and why does it matter?**
A: A checksum verifies migration files haven't changed after being applied.

**Q: Why structured logs over plain text?**
A: Structured logs are machine-parsable and searchable across systems.

---

### Session 10: Deployment and Production Readiness (Part 10 - Part 2)

#### Session Objectives
- Build Docker image for deployment
- Create smoke tests
- Set up continuous integration
- Deploy to production (Vercel)
- Verify production behavior
- Document operations

#### Agenda

| Time | Activity | Materials |
|------|----------|-----------|
| 15 min | Review: Production prep, Q&A | Slides |
| 30 min | Concept: Docker, CI/CD | Slides |
| 45 min | Lab: Docker image, smoke tests | Lab 10 instructions |
| 15 min | Break/Check-in | |
| 30 min | Concept: Deployment, monitoring | Slides |
| 45 min | Lab: Deploy to Vercel, verify | Lab 10 instructions |
| 30 min | Closing: Final review, course wrap-up | Slides, celebration |

#### Key Talking Points

1. **Docker Multi-Stage**: Separate build, dependencies, and runtime
2. **Smoke Tests**: Fast verification of critical functionality
3. **CI Pipeline**: Automate validation on every commit
4. **Deployment Order**: Migrations → Application → Verification
5. **Production Runbook**: Document operations and incident procedures
6. **Security Headers**: CSP, HSTS, X-Frame-Options

#### Deployment Architecture

```
Source → CI → Build → Deploy → Verify → Monitor
              ↓
         Migrations
```

#### Common Student Questions

**Q: Why use Docker for deployment?**
A: Docker ensures the application runs the same way in any environment.

**Q: What's the difference between smoke tests and full tests?**
A: Smoke tests are fast and check critical paths; full tests are comprehensive but slower.

**Q: Why do we need a runbook?**
A: During incidents, teams shouldn't have to reconstruct procedures from memory.

---

## Common Issues and Solutions

### Environment Setup Issues

| Issue | Solution |
|-------|----------|
| Node.js version too old | Use `nvm` or install Node.js 22 LTS |
| Docker not running | Start Docker Desktop |
| Port 5432 in use | Stop other PostgreSQL services or change port |
| Port 3000 in use | Change port with `npm run dev -- -p 3001` |
| ESLint not found | `npm install` to install dependencies |

### Database Issues

| Issue | Solution |
|-------|----------|
| PostgreSQL not accepting connections | Wait for health check to pass |
| Migration fails | Check SQL syntax, ensure container is running |
| Seed duplicates | Use `DELETE` before `INSERT` in seed |
| Connection refused | Check `DATABASE_URL` format |
| Missing tables | Run migrations: `npm run db:migrate` |

### TypeScript Issues

| Issue | Solution |
|-------|----------|
| Cannot find module | Check import path uses `@/` correctly |
| Type mismatch | Verify runtime data matches schemas |
| Server-only import in client | Move import to server component or use `server-only` |
| Metadata not exported | Check the `export const metadata` syntax |

### Deployment Issues

| Issue | Solution |
|-------|----------|
| Build fails | Check environment variables during build |
| Database connection | Verify `DATABASE_URL` in production |
| Migrations not applied | Run migration before deploying new version |
| 404 errors | Check route structure and dynamic segments |
| Cookie not secure | Verify `APP_URL` uses HTTPS in production |

### Performance Issues

| Issue | Solution |
|-------|----------|
| Large bundle | Use bundle analyzer, code splitting |
| Slow page load | Add loading boundaries, optimize images |
| Layout shift | Set `width` and `height` on images |
| Long INP | Move heavy JavaScript off the main thread |
| Cache issues | Verify `Cache-Control` headers are appropriate |

---

## Assessment Guide

### Formative Assessment Opportunities

**Daily Checkpoints**
- End of each lab: Students verify their implementation
- Code review: Students share screenshots of working features
- Quick quizzes: 5-minute multiple choice questions

**Lab Completion Checks**
- Verify command outputs
- Review key file contents
- Test the application manually

### Summative Assessment Options

**Option A: Project Portfolio**
Students submit their completed LaunchPad application with:
- Working development environment
- All routes and features functional
- Production build successful
- Deployment URL
- Reflections on learning

**Option B: Feature Extension**
Students add one new feature independently:
- Customize the application (e.g., add comments, tags, or teams)
- Document the implementation
- Present to the class

**Option C: Technical Interview**
- One-on-one discussion of architecture decisions
- Code walkthrough of a specific feature
- Explanation of server/client boundaries

### Grading Rubric

| Criteria | Excellent (90-100%) | Good (70-89%) | Needs Improvement (<70%) |
|----------|---------------------|---------------|--------------------------|
| Code Quality | Clean, typed, follows patterns | Mostly clean, few type issues | Inconsistent, many type issues |
| Architecture | Correct boundaries, separation | Mostly correct, some mixing | Poor boundaries, mixing concerns |
| Functionality | All features work | Most features work | Several features broken |
| Deployment | Deployed, verified, secure | Deployed, some verification missing | Not deployed or insecure |
| Documentation | Clear, complete | Adequate | Missing or unclear |

---

## Extension Activities

### For Advanced Students

1. **Add Multi-Factor Authentication**
   - Implement TOTP using `speakeasy`
   - Add QR code display with `qrcode`

2. **Add Team Collaboration**
   - Create team membership model
   - Add project sharing between users
   - Implement invitation system

3. **Add File Uploads**
   - Configure storage (local or S3)
   - Add file attachments to tasks
   - Validate file types and sizes

4. **Add Real-Time Features**
   - Implement WebSockets with Socket.io
   - Add live task updates
   - Show online users

5. **Add Full-Text Search**
   - Configure PostgreSQL full-text search
   - Add search across projects and tasks
   - Implement search highlighting

### Class Projects

1. **Group Deployment Exercise**
   - Teams deploy to different platforms (Vercel, Railway, Docker)
   - Compare performance and costs
   - Present findings

2. **Performance Competition**
   - Who can get the best Lighthouse scores?
   - Who can reduce bundle size the most?
   - Document optimization strategies

3. **Security Audit**
   - Review authentication and authorization
   - Identify potential vulnerabilities
   - Propose improvements

---

## Resources and References

### Documentation

- [Next.js Documentation](https://nextjs.org/docs)
- [React Documentation](https://react.dev)
- [TypeScript Documentation](https://www.typescriptlang.org/docs/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Documentation](https://docs.docker.com/)

### Tools

- [VS Code with Next.js Extension](https://marketplace.visualstudio.com/items?itemName=NextJSwizards.nextjs)
- [ESLint](https://eslint.org/)
- [Prettier](https://prettier.io/)
- [Vercel CLI](https://vercel.com/docs/cli)
- [Lighthouse](https://developer.chrome.com/docs/lighthouse/)

### Sample Solutions

- Complete repository (ask trainer for access)
- Deployment URLs from previous cohorts
- Architecture diagrams and slides

### Trainer Resources

**Slides Template**: [Link to provided slides]

**Key Diagrams**:
- Architecture overview
- Request lifecycle
- Authentication flow
- Authorization SQL patterns
- Component boundary map

**Cheat Sheets**:
- [Next.js Cheat Sheet](https://nextjs.org/learn/foundations/from-javascript-to-react/next-js-basics)
- [TypeScript Cheat Sheet](https://www.typescriptlang.org/cheatsheets/)
- [SQL Cheat Sheet](https://www.postgresqltutorial.com/postgresql-cheat-sheet/)

---

## Course Completion Checklist

After the final session, ensure all students have:

- [ ] Completed all 10 parts of the tutorial
- [ ] Successfully run `npm run build`
- [ ] Deployed to a production environment
- [ ] Run and passed smoke tests
- [ ] Security headers verified
- [ ] Authentication working in production
- [ ] Authorization enforced
- [ ] Performance optimizations applied
- [ ] Documentation reviewed
- [ ] Final project submitted

### Graduation Ceremony Ideas

1. **Showcase**: Students present their deployed applications
2. **Reflection**: Share biggest learning moments
3. **Next Steps**: Discuss career pathways using these skills
4. **Certificates**: Provide completion certificates

---

## Feedback Form

### Trainer Self-Reflection

After each session, reflect on:
- What went well?
- What could be improved?
- Which concepts were most challenging for students?
- Which activities were most engaging?

### Student Feedback Questions

1. What was the most valuable concept you learned?
2. Which part was most challenging?
3. What would you like more practice with?
4. How confident do you feel building Next.js applications?
5. What would you change about the course?

---

*This trainer guide is designed to be flexible. Adjust the pace and content based on your students' experience levels and interests. The most important outcome is understanding the architecture, not completing every single step perfectly.*
