# From Zero to Production with Next.js 16

## Part 0: Introduction

> **Series project:** We will build **LaunchPad**, a production-ready project management application in which authenticated users can create, organize, update, and track projects and tasks.

---

## 0.1 Welcome to the Series

React makes it possible to build interactive user interfaces from reusable components. However, a real production application needs much more than interface components.

It usually also needs:

- URLs and page navigation
- Server-side data access
- Database operations
- Authentication and authorization
- Loading and error interfaces
- API endpoints
- Form validation
- Secure configuration
- Image and font optimization
- Caching
- Logging and monitoring
- A reliable deployment process

You can assemble those capabilities yourself by combining React with many independent libraries and build tools. Next.js takes a different approach: it provides a structured React framework in which these concerns are designed to work together.

A **framework** is a collection of tools, conventions, and architectural rules that gives an application a dependable structure. Think of React as a powerful set of construction materials. Next.js is the building plan, electrical system, plumbing, and safety code that helps turn those materials into a complete building.

Throughout this series, you will learn Next.js by building one application from an empty directory to a production deployment. We will not treat features as isolated demonstrations. Every new concept will become part of the same evolving codebase.

You will learn both:

1. **How** to implement each feature.
2. **Why** that feature belongs in a particular architectural layer.

The goal is not to produce an application that merely works on a developer’s laptop. The goal is to develop the engineering judgment needed to build software that remains understandable, secure, testable, and maintainable as it grows.

---

## 0.2 What We Will Build

Our application is called **LaunchPad**.

LaunchPad will allow a signed-in user to:

- View a personal dashboard
- Create projects
- Edit project details
- Archive projects
- Add tasks to projects
- Change task status
- Filter and organize project data
- Navigate between public and protected pages
- Receive clear loading, success, empty, and error states
- Manage application data through forms and server-side operations
- Use the application comfortably across desktop and mobile screens

The finished application will include far more than visible pages. It will also contain the less visible systems that make a web application production-ready:

- A relational database
- Type-safe database access
- Authentication
- Authorization checks
- Server-side validation
- Secure environment variables
- Route Handlers for HTTP endpoints
- Server Actions for controlled mutations
- Static and dynamic rendering strategies
- Streaming interfaces
- Cache management
- Optimized images and fonts
- Structured error handling
- Security headers
- Health checks
- Logging and monitoring foundations
- Automated quality checks
- A repeatable deployment process

This is intentionally more ambitious than a traditional beginner project. You will begin with basic pages and gradually assemble the architecture one layer at a time.

---

## 0.3 The Final User Experience

LaunchPad will contain two broad areas.

### Public area

Visitors who are not signed in will be able to access:

- A landing page
- An about page
- A features page
- Sign-in and registration experiences

These pages will introduce routing, layouts, navigation, metadata, optimized assets, and static rendering.

### Authenticated application area

Signed-in users will be able to access:

- A dashboard
- A project list
- Individual project pages
- Project creation and editing forms
- Task-management interfaces
- Account controls

These pages will introduce dynamic rendering, database access, authentication, authorization, validation, server-side mutations, cache invalidation, and interactive Client Components.

A user will only be allowed to read or change records they own. That requirement is called **authorization**.

Authentication and authorization are related, but they answer different questions:

- **Authentication:** Who is making this request?
- **Authorization:** Is that person allowed to perform this action?

Imagine an office building. Authentication checks the name on your identity badge. Authorization determines which rooms that badge may unlock.

We will implement both checks rather than assuming that hiding a link in the browser is sufficient security.

---

## 0.4 The Architecture We Are Working Toward

The final application will use a layered architecture.

```text
┌──────────────────────────────────────────────────────────────┐
│                         Web Browser                          │
│                                                              │
│  HTML and Server Component output                           │
│  Interactive Client Components                              │
│  Forms, navigation, optimistic feedback, and local state     │
└─────────────────────────────┬────────────────────────────────┘
                              │ HTTPS
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                       Next.js 16 App                         │
│                                                              │
│  App Router                                                  │
│  ├── Pages                                                   │
│  ├── Layouts                                                 │
│  ├── Loading boundaries                                     │
│  ├── Error boundaries                                       │
│  └── Route groups and dynamic segments                       │
│                                                              │
│  Server Layer                                                │
│  ├── React Server Components                                │
│  ├── Server Actions                                          │
│  ├── Route Handlers                                          │
│  ├── Authentication                                          │
│  ├── Authorization                                           │
│  └── Input validation                                        │
│                                                              │
│  Application Layer                                           │
│  ├── Project operations                                      │
│  ├── Task operations                                         │
│  ├── Cache policy                                            │
│  └── Domain rules                                            │
└─────────────────────────────┬────────────────────────────────┘
                              │ Type-safe queries
                              ▼
┌──────────────────────────────────────────────────────────────┐
│                    Relational Database                       │
│                                                              │
│  Users                                                       │
│  Projects                                                    │
│  Tasks                                                       │
│  Authentication-related records                              │
└──────────────────────────────────────────────────────────────┘
```

Let us unpack each layer.

### Browser layer

The browser displays the application and handles interactions such as button clicks, menu toggles, and form input.

Not every component needs to run JavaScript in the browser. Next.js lets us keep most components on the server and send browser-side JavaScript only where interactivity requires it.

This reduces unnecessary work for the user’s device.

### Routing and presentation layer

The App Router maps files and directories to URLs. It also provides conventions for shared layouts, loading interfaces, errors, and missing pages.

For example, a directory structure will eventually resemble this:

```text
app/
├── (marketing)/
│   ├── about/
│   │   └── page.tsx
│   ├── features/
│   │   └── page.tsx
│   └── page.tsx
├── (auth)/
│   ├── sign-in/
│   │   └── page.tsx
│   └── sign-up/
│       └── page.tsx
├── dashboard/
│   ├── projects/
│   │   ├── [projectId]/
│   │   │   └── page.tsx
│   │   └── page.tsx
│   ├── layout.tsx
│   ├── loading.tsx
│   └── page.tsx
├── api/
│   └── health/
│       └── route.ts
├── error.tsx
├── layout.tsx
├── not-found.tsx
└── globals.css
```

You do not need to understand this tree yet. Each convention will be introduced before we use it.

### Server layer

The server layer performs work that should not be trusted to the browser, including:

- Reading protected data
- Writing to the database
- Validating submitted input
- Verifying user identity
- Checking record ownership
- Reading private environment variables
- Returning safe responses

Code running in the browser is visible to the user and can be manipulated. The browser should therefore be treated as an untrusted caller—not as a security boundary.

### Application layer

The application layer contains the rules of our product.

For example:

- A project must have a valid name.
- A user may only edit their own projects.
- A completed task must use an allowed status.
- A request for a nonexistent project should produce a not-found result.

Keeping these rules organized prevents pages and HTTP endpoints from becoming collections of duplicated database instructions.

### Data layer

The data layer communicates with a relational database.

A **relational database** stores structured records in tables and connects related records using identifiers. For example, every task can store the identifier of the project to which it belongs.

Our application’s conceptual data model will look like this:

```text
User
├── id
├── name
├── email
└── projects

Project
├── id
├── name
├── description
├── status
├── ownerId
├── createdAt
├── updatedAt
└── tasks

Task
├── id
├── title
├── description
├── status
├── priority
├── dueDate
├── projectId
├── createdAt
└── updatedAt
```

The implementation will enforce these relationships rather than relying only on assumptions in application code.

---

## 0.5 The Request Lifecycle

To understand Next.js, it helps to follow one ordinary request through the finished system.

Suppose a signed-in user visits:

```text
/dashboard/projects/abc123
```

The application will conceptually perform these steps:

1. The App Router matches the URL to the corresponding route.
2. The route receives `abc123` as a dynamic project identifier.
3. The server verifies the user’s session.
4. The data layer requests the project from the database.
5. The authorization layer checks that the project belongs to the user.
6. The Server Component renders the project data.
7. Interactive controls are composed into the page where needed.
8. Next.js sends the rendered response to the browser.
9. The browser activates the JavaScript required by interactive Client Components.

If the project does not exist, the user receives a not-found interface.

If the database request fails unexpectedly, the user receives an error interface while the server records useful diagnostic information.

If the user is not signed in, the request is redirected to the sign-in flow.

If the project belongs to someone else, the application refuses access even if the user manually typed the URL.

A production architecture accounts for all of these outcomes. It does not design only for the successful path.

---

## 0.6 Server Components and Client Components

One of the most important ideas in modern Next.js is the distinction between **Server Components** and **Client Components**.

### Server Components

A Server Component renders on the server. In the App Router, components are Server Components by default unless they cross a Client Component boundary.

Server Components are well suited to:

- Fetching data near its source
- Reading server-only configuration
- Accessing a database through protected server modules
- Reducing browser-side JavaScript
- Rendering content that does not require browser interaction

A simplified example looks like this:

```tsx
export default async function ProjectsPage() {
  const projects = await getProjects();

  return (
    <main>
      <h1>Projects</h1>

      <ul>
        {projects.map((project) => (
          <li key={project.id}>{project.name}</li>
        ))}
      </ul>
    </main>
  );
}
```

This example is only a preview. `getProjects` has not been implemented yet and should not be copied into the project at this stage.

### Client Components

A Client Component can use browser-side capabilities such as state, event handlers, effects, and browser APIs.

A file becomes a Client Component entry point by placing the `"use client"` directive at the top:

```tsx
"use client";

import { useState } from "react";

export function ProjectFilters() {
  const [query, setQuery] = useState("");

  return (
    <label>
      Search projects
      <input
        type="search"
        value={query}
        onChange={(event) => setQuery(event.target.value)}
      />
    </label>
  );
}
```

This is also a conceptual preview rather than a file to create now.

A useful analogy is a restaurant:

- A **Server Component** is work performed in the kitchen before the meal reaches the table.
- A **Client Component** is an action the diner performs at the table, such as adjusting a control or making an interactive selection.

We do not move the entire kitchen onto every table simply because one interaction must happen there. Similarly, we will not mark whole pages as Client Components merely because one small control needs browser state.

---

## 0.7 The Rendering Strategies We Will Learn

A page can be produced using different rendering and caching strategies. Choosing among them is an architectural decision, not a contest in which one method is always best.

### Static rendering

Static output can be prepared ahead of requests and reused.

This is a good fit for content that is shared among visitors and does not change for every request, such as a public marketing page.

Analogy: a bakery prepares popular loaves before customers arrive.

### Dynamic rendering

Dynamic output is generated when request-specific information is required.

This is appropriate when content depends on information such as a user’s authenticated session.

Analogy: a restaurant prepares a meal after receiving a customer’s specific order.

### Streaming

Streaming allows the server to send ready portions of an interface while slower portions are still being prepared.

Analogy: instead of waiting for every dish in a large order, the server brings completed dishes to the table as they become ready.

We will use loading boundaries so the page can remain responsive while slower work completes.

### Caching and revalidation

A **cache** stores a reusable result so the same work does not always need to be repeated.

**Revalidation** determines when cached information should be refreshed or invalidated.

Caching is not simply an “on” or “off” performance switch. Different information has different freshness requirements:

- Marketing content may be reused broadly.
- A user’s private dashboard needs stricter boundaries.
- A project list should be refreshed after a project is created.
- Authentication and authorization checks must never be replaced by unsafe shared results.

We will define caching behavior intentionally rather than relying on accidental defaults.

---

## 0.8 How Full-Stack Features Fit Together

Next.js lets one codebase contain both user interfaces and server-side functionality. That does not mean all code should be mixed together.

We will use several distinct mechanisms.

### Pages

Pages render route-specific interfaces.

```text
app/dashboard/projects/page.tsx
```

The preceding path maps to a projects page within the dashboard.

### Layouts

Layouts provide shared user interface around multiple pages.

Examples include:

- The application header
- Dashboard navigation
- Account controls
- Consistent page spacing

A layout remains shared as users move among its child routes.

### Route Handlers

Route Handlers implement HTTP endpoints using standard request and response concepts.

We will use them for features such as:

- A health-check endpoint
- Integration-friendly API responses
- Cases in which an explicit HTTP interface is appropriate

A route file has a shape similar to this:

```text
app/api/health/route.ts
```

### Server Actions

Server Actions are server-side functions that can be connected to forms and mutations.

A **mutation** is an operation that changes data, such as creating a project or updating a task.

We will use Server Actions where they provide a clear, secure path between a Next.js interface and server-side application logic.

### Shared validation

Submitting a form does not make its data trustworthy. Every server-side mutation must validate its input.

Client-side validation improves the user experience by providing fast feedback. Server-side validation protects the application.

We will use both, but security will never depend solely on browser checks.

---

## 0.9 Target Audience

This series is designed for developers who are new to Next.js.

You are in the right place if you:

- Understand basic HTML and CSS
- Have introductory JavaScript knowledge
- Have seen React components before
- Know how to open a terminal
- Can edit files in a code editor
- Want to understand full-stack application architecture
- Prefer building a real application over reading disconnected examples

You do **not** need prior experience with:

- Next.js
- The App Router
- Server Components
- TypeScript
- Relational databases
- Object-relational mapping tools
- Authentication systems
- Caching strategies
- Production deployment

TypeScript will be used throughout the series. TypeScript extends JavaScript with static type checking, which helps detect many mistakes before the application runs.

TypeScript may look unfamiliar at first, but every important type will be explained when introduced.

---

## 0.10 Expected Prerequisite Knowledge

You will benefit from recognizing basic JavaScript ideas such as:

```ts
const projectName = "LaunchPad";

const project = {
  id: "project-1",
  name: projectName,
};

function formatProjectName(name: string) {
  return name.trim();
}

const projectNames = ["Website", "Mobile app", "Documentation"];

const formattedNames = projectNames.map((name) =>
  formatProjectName(name),
);
```

You do not need to understand every symbol yet.

At a high level, this example demonstrates:

- A constant value
- An object
- A function
- A TypeScript parameter type
- An array
- An array transformation
- An arrow function

We will explain framework-specific syntax and patterns as they appear.

You should also recognize the basic shape of a React component:

```tsx
type GreetingProps = {
  name: string;
};

export function Greeting({ name }: GreetingProps) {
  return <p>Hello, {name}!</p>;
}
```

This component receives a property named `name` and returns interface markup.

If React components are completely new to you, you can still follow the series, but reviewing JavaScript functions, objects, arrays, modules, and basic React components will make the journey smoother.

---

## 0.11 The Engineering Standards We Will Follow

Tutorial code is often optimized for brevity. Production code must instead be optimized for correctness, clarity, and safe change.

Our implementation will follow these principles.

### Type safety

We will avoid weakening the type system merely to silence errors.

Types will be used at system boundaries, including:

- Component properties
- Form input
- Environment variables
- Database results
- API responses
- Authentication data

Generated or inferred types will be reused when doing so prevents duplication.

### Server-side validation

All untrusted input will be validated on the server before it reaches important application operations.

Untrusted input includes:

- Form fields
- URL parameters
- Query-string values
- JSON request bodies
- Request headers
- Cookies
- Data supplied by external services

### Authentication and authorization

Protected operations will verify both identity and permission.

We will not rely on:

- Hidden buttons
- Disabled controls
- Client-side redirects
- Unverified record identifiers

Those mechanisms can improve the interface, but they do not secure server-side data.

### Least privilege

**Least privilege** means giving code and users only the access they need.

For example:

- Browser code will not receive database credentials.
- Private environment variables will remain server-side.
- Users will only access their own project data.
- Public endpoints will expose only necessary information.

### Clear boundaries

Browser-only code, server-only code, database code, validation logic, and domain operations will be separated.

Boundaries make it easier to answer questions such as:

- Can this module safely be imported by a Client Component?
- Does this function validate its arguments?
- Does this operation enforce ownership?
- Is this value safe to send to the browser?

### Explicit error handling

Expected failures and unexpected failures require different treatment.

Expected failures include:

- Invalid form input
- Missing records
- Expired sessions
- Duplicate values
- Unauthorized operations

Unexpected failures include:

- Database outages
- Broken assumptions
- Infrastructure errors
- Programming defects

Users should receive useful, safe messages. Developers should receive enough diagnostic information to investigate the underlying problem.

### Accessibility

Accessibility will be part of implementation rather than a final decoration.

We will use:

- Semantic HTML
- Connected labels and controls
- Keyboard-friendly interactions
- Visible focus states
- Useful page titles
- Clear error messages
- Appropriate status announcements
- Sufficient color contrast

### Progressive enhancement

Where practical, important workflows will begin with standard web capabilities such as links and forms. JavaScript will enhance those workflows rather than unnecessarily replacing them.

### Maintainable duplication policy

We will avoid premature abstraction.

Two pieces of code that look similar are not always governed by the same rule. We will extract reusable units when doing so gives the code a clearer responsibility—not simply to reduce the number of lines.

---

## 0.12 The Complete Learning Path

The series is divided into ten implementation parts after this introduction.

### Part 1: Introduction to Next.js

We will:

- Explain how Next.js differs from a client-only React application
- Verify the local development environment
- Create the application
- Examine the generated project structure
- Run development and production builds
- Replace the starter interface with our first LaunchPad page

### Part 2: Routing and Pages

We will:

- Learn file-system routing
- Create public pages
- Add navigation with Next.js links
- Use dynamic route segments
- Handle missing pages
- Work with route parameters and search parameters

### Part 3: Layouts and UI Composition

We will:

- Build a root layout
- Create separate marketing and dashboard experiences
- Introduce route groups
- Add nested layouts
- Compose reusable navigation and page-shell components
- Configure route metadata

### Part 4: Server and Client Components

We will:

- Establish the default server-first mental model
- Identify browser-only requirements
- Create focused Client Component boundaries
- Pass serializable data across boundaries
- Avoid accidental client-side bundles
- Implement interactive controls without moving entire pages to the browser

### Part 5: Data Fetching in Next.js 16

We will:

- Introduce the database
- Define the application data model
- Seed development data
- Query data from Server Components
- Compare static and dynamic behavior
- Add loading states
- Stream slower interface sections
- Handle database and rendering failures
- Introduce explicit cache decisions

### Part 6: Styling Your Application

We will:

- Establish a global design foundation
- Use locally scoped component styles where appropriate
- Build responsive layouts
- Style reusable components
- Add accessible interaction states
- Integrate optimized fonts
- Create consistent empty, loading, success, and error interfaces

### Part 7: Building APIs and Full-Stack Features

We will:

- Create Route Handlers
- Validate request bodies
- Return typed JSON responses
- Implement project and task operations
- Build forms backed by Server Actions
- Handle mutation errors
- Invalidate affected cached data
- Add a health-check endpoint

### Part 8: Authentication and State Management

We will:

- Add user authentication
- Protect application routes
- Enforce authorization in server operations
- Separate server state from client state
- Use URL state for shareable filters
- Use local state for temporary interface behavior
- Prevent cross-user data access

### Part 9: Performance and Optimization

We will:

- Measure before optimizing
- Reduce unnecessary client-side JavaScript
- Use optimized images and fonts
- Apply deliberate caching and revalidation
- Introduce code splitting where it has measurable value
- Analyze application output
- Improve loading behavior and perceived performance

### Part 10: Deployment and Production Readiness

We will:

- Validate environment configuration
- Prepare production database workflows
- Add security-focused configuration
- Add health and observability foundations
- Run production checks locally
- Deploy the application
- Verify the deployed system
- Discuss scaling, migrations, backups, monitoring, and incident readiness

Each part depends on the application produced by the previous part. Skipping implementation steps may leave later code without the files, packages, or concepts it expects.

---

## 0.13 How Each Technical Step Will Work

Every implementation step will use the same four-part structure.

### 1. The Target

This identifies exactly what we are about to build.

For example:

> Create the root layout that surrounds every route in the application.

### 2. The Concept

This explains why the feature exists before introducing its syntax.

For example:

> A layout works like the permanent frame around a whiteboard. The writing can change, but the frame does not need to be rebuilt for every update.

### 3. The Implementation

This provides:

- The exact relative file path
- Complete file contents
- Required terminal commands
- Explanations for critical lines
- No omitted implementation sections
- No placeholder comments

When a file must be completely replaced, the tutorial will say so explicitly.

When only a small, safe edit is appropriate, the surrounding context will make the location unambiguous.

### 4. The Verification

Every technical step will include a concrete test before proceeding.

Verification may involve:

- Starting the development server
- Opening a specific browser URL
- Running a production build
- Executing a type check
- Running a lint command
- Sending an HTTP request with `curl`
- Inspecting an expected response
- Confirming a database record
- Testing both successful and unsuccessful paths

A feature is not complete merely because its code looks plausible. We will verify observable behavior.

---

## 0.14 How to Use the Tutorial

For the most reliable experience, follow these working habits.

### Type or copy each file carefully

Paths are part of the Next.js programming model. A correct file in the wrong directory may create a different route—or no route at all.

Pay close attention to names such as:

```text
page.tsx
layout.tsx
loading.tsx
error.tsx
not-found.tsx
route.ts
```

On case-sensitive systems, capitalization also matters.

### Run every verification step

Do not wait until the end of a part to discover that an earlier change failed.

Verification creates small checkpoints. If the current checkpoint works, any later problem is likely related to a smaller set of recent changes.

### Read errors from the beginning

The first useful error often explains the root cause. Later errors may simply be consequences.

When an error occurs:

1. Read the complete terminal output.
2. Find the first relevant error.
3. Note the file path and line number.
4. Compare the local file against the tutorial.
5. Confirm that dependencies and environment variables are present.
6. Restart the development server if configuration changed.

### Keep secrets out of source control

Environment files may contain database credentials and authentication secrets.

We will configure the repository so local secrets are not committed, but you should still inspect staged changes before every commit.

A secret committed to Git should be considered compromised even if it is removed in a later commit. Git retains history.

### Commit at meaningful checkpoints

A useful Git history might eventually contain commits such as:

```text
feat: create initial LaunchPad application
feat: add marketing routes and navigation
feat: add dashboard layout
feat: configure project database
feat: add project creation workflow
feat: add authentication
perf: optimize project dashboard
chore: prepare production deployment
```

Small, meaningful commits make failures easier to isolate and changes easier to review.

---

## 0.15 What “Production-Ready” Means Here

“Production-ready” does not mean that an application can never fail. No honest engineering process can make that promise.

It means the application has been designed to operate responsibly outside a tutorial environment.

For this series, production readiness includes:

- Reproducible installation
- A successful optimized build
- Type checking
- Linting and code-quality checks
- Validated environment configuration
- Database migration practices
- Secure authentication
- Server-enforced authorization
- Input validation
- Safe error responses
- Deliberate caching
- Accessible interfaces
- Responsive layouts
- Health checks
- Logging and monitoring foundations
- Deployment verification
- Backup and rollback considerations
- Clear operational documentation

Production readiness is a system property. It cannot be created by adding one package or setting one configuration flag.

A fast page with insecure authorization is not production-ready. A secure application with no migration strategy is not production-ready. A successful deployment with no way to detect failures is not production-ready.

We will treat all of these concerns as parts of the same engineering problem.

---

## 0.16 What We Will Not Hide

This series will not pretend that production engineering is effortless.

You will encounter trade-offs such as:

- Static speed versus request-specific freshness
- Server simplicity versus browser interactivity
- Convenient abstraction versus visible control
- Cache reuse versus invalidation complexity
- Fast iteration versus safe database migrations
- Helpful error detail versus sensitive information exposure
- Reusable components versus over-engineering

When multiple valid approaches exist, the tutorial will explain the reason for the selected approach and identify the conditions under which another option might be better.

We will also distinguish among three categories:

1. **Framework requirements**  
   Rules imposed by Next.js or React.

2. **Project conventions**  
   Organizational choices selected for LaunchPad.

3. **Security requirements**  
   Controls that protect users and data.

This distinction matters. A folder structure may be a flexible convention, while an authorization check is a non-negotiable security boundary.

---

## 0.17 Our Definition of Success

By the end of the series, you should be able to explain and implement the following without treating Next.js as magic:

- How a URL maps to a route
- Why layouts are separate from pages
- Why Server Components are the default
- When a Client Component is necessary
- Where database access should occur
- Why browser-side validation is insufficient
- How authentication differs from authorization
- How loading and error boundaries improve resilience
- When data may be cached
- How mutations refresh affected interfaces
- Why environment variables need validation
- How to test an optimized production build
- What must be monitored after deployment

You will also have a complete application whose structure can serve as a starting point for future projects.

The most important outcome is not memorizing file names. Framework APIs change over time. Durable engineering judgment comes from understanding responsibilities, boundaries, and trade-offs.

---

## 0.18 Part 0 Completion Check

No project files have been created yet. Part 0 establishes the product, architecture, vocabulary, and working method we will use throughout the implementation.

Before beginning Part 1, you should be able to answer these questions:

1. **What are we building?**  
   A production-oriented project and task management application named LaunchPad.

2. **Why use Next.js instead of React alone?**  
   React provides the component model, while Next.js supplies an integrated framework for routing, rendering, server behavior, optimization, and production delivery.

3. **Where will sensitive operations run?**  
   On the server, behind validation, authentication, and authorization boundaries.

4. **Will every component run in the browser?**  
   No. Components will remain server-side by default, and focused Client Components will be introduced only when browser interactivity is required.

5. **How will progress be verified?**  
   Every technical step will conclude with explicit commands or observable browser, server, API, or database results.

6. **What does production-ready mean?**  
   More than deployment: it includes correctness, security, validation, observability, performance, maintainability, and operational preparation.
