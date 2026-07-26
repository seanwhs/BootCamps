# Production-Grade Full-Stack Web Development Course Curriculum

A comprehensive, 6-phase curriculum designed to take students from core networking concepts and command-line basics to deploying production-ready SaaS applications built with **Next.js 16**, **TypeScript**, **PostgreSQL**, **Clerk**, **Sanity**, **Inngest**, and modern **DevOps workflows**.

---

## 🗺️ Master Curriculum Overview

| Phase | Core Theme | Core Stack | Capstone Milestone |
| --- | --- | --- | --- |
| **Phase 0** | **Web Mechanics, System Architecture & Networking** | DevTools, HTTP/REST, System Architecture Diagrams | API Inspection & System Architecture Report |
| **Phase 1** | **The Foundations** | Terminal/CLI, Git, HTML5, CSS3, Modern JS (ES6+) | Interactive Client-Side Dashboard |
| **Phase 2** | **Frontend Architecture** | React 19, TypeScript, State Management, UI Systems | Complex Single-Page Application (SPA) |
| **Phase 3** | **Backend & Databases** | Node.js, Express, PostgreSQL / MongoDB, ORMs | Secure Standalone REST / GraphQL API |
| **Phase 4** | **Next.js 16 & DevOps** | Next.js 16 (App Router), Turbopack, Docker, CI/CD | Modern Full-Stack Web Application |
| **Phase 5** | **Production Cloud & AI Services** | Clerk, Sanity, Inngest, Stripe, Serverless Cloud | Production-Grade AI Content / SaaS Engine |

---

## 📚 Phase-by-Phase Curriculum Breakdown

### Phase 0: Web Mechanics, Architecture & Network Fundamentals

> **Goal:** Build a crystal-clear mental model of web software anatomy, how frontend and backend responsibilities diverge, how computers communicate over networks, and how data moves across the web before writing code.

* **Part 1: Deconstructing Software Architecture: Frontend vs. Backend vs. Full Stack**
* **The Frontend (Client-Side):** User interfaces, visual presentation, user interaction handling, and browser-bound execution environments.
* **The Backend (Server-Side):** Business logic, authorization, data persistence, file storage, external API integration, and server execution environments.
* **The Full Stack:** How client and server layers communicate, share data models, and divide computational workloads.
* Architectural evolutions: Static websites vs. Single Page Applications (SPAs) vs. Server-Side Rendering (SSR) vs. Modern Full-Stack Frameworks.


* **Part 2: How the Internet & Web Work**
* The difference between the Internet (hardware infrastructure) and the Web (software protocol layer).
* IP addresses, domain names, and the DNS (Domain Name System) lookup lifecycle.
* Clients, servers, edge networks, data centers, and the Client-Server architectural model.


* **Part 3: The HTTP/HTTPS Protocol & Request-Response Cycle**
* Anatomy of an HTTP Request: Methods (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`), headers, URL parameters, and request bodies.
* Anatomy of an HTTP Response: Status codes (`2xx`, `3xx`, `4xx`, `5xx`), response headers, and payloads (JSON, HTML).
* Transport layer security: HTTP vs. HTTPS, SSL/TLS handshake basics, and data encryption.


* **Part 4: RESTful Services & API Paradigms**
* Principles of REST (Representational State Transfer): statelessness, resource-based URLs, and standard verbs.
* Comparing API paradigms: REST vs. GraphQL vs. RPC (Remote Procedure Call).
* Data serialization formats: JSON, XML, and Form Data.


* **Part 5: Network Inspection with Browser DevTools & Postman/Bruno**
* Using the Chrome DevTools **Network Tab** to inspect HTTP requests, response headers, payloads, and timing bottlenecks.
* Testing third-party REST APIs using API clients (Postman/Bruno/curl) without writing code.



---

### Phase 1: Terminal, Version Control & Web Foundations

> **Goal:** Master foundational developer tooling, client-side rendering, semantic markup, and vanilla JavaScript fundamentals.

* **Part 6: The Command Line Interface (CLI) & Developer Environment**
* Navigating the filesystem (`cd`, `ls`, `mkdir`, `rm`) and managing files via terminal.
* Node/Package runners (`npm`, `pnpm`, `npx`), script execution, and environment variables (`.env`).


* **Part 7: Version Control with Git & GitHub**
* Core Git workflow: tracking changes (`init`, `add`, `commit`), history (`log`, `diff`), and remotes (`push`, `pull`).
* Branching strategies: feature branches, merging, pull requests (PRs), and resolving merge conflicts.


* **Part 8: Semantic HTML5 & Modern Responsive CSS**
* Semantic document structure, accessibility standards (a11y), and metadata.
* Responsive layouts using CSS Flexbox, Grid, container queries, and media rules.


* **Part 9: Modern JavaScript (ES6+) & Asynchronous DOM Manipulation**
* Variables (`const`/`let`), arrow functions, array methods (`map`, `filter`, `reduce`), and destructuring.
* DOM selection/manipulation, event listeners, the Event Loop, Promises, `async/await`, and `fetch()` integration.



---

### Phase 2: Modern Frontend Architecture & Type Safety

> **Goal:** Transition from imperative vanilla code to declarative, component-driven, type-safe frontend application architecture.

* **Part 10: Type-Safe Web Development with TypeScript**
* Type annotations, primitive types, interfaces, type aliases, union/intersection types, and generics.
* Integrating TypeScript with DOM events, APIs, and modern toolchains.


* **Part 11: React 19 Fundamentals & Declarative UI**
* JSX syntax, component hierarchy, props, and conditional rendering.
* State management with `useState`, handling user inputs, and controlled components.


* **Part 12: Side Effects & Global State Orchestration**
* Managing side effects and lifecycles with `useEffect`.
* Global state patterns using Context API or lightweight state libraries (e.g., Zustand).


* **Part 13: Client-Side Routing & React 19 Innovations**
* Multi-page SPA navigation using client-side routers.
* Understanding the React 19 Compiler, automatic memoization, and modern hook abstractions.



---

### Phase 3: Server Architecture, Databases & Security

> **Goal:** Build resilient, secure, and scalable server environments while designing structured database schemas.

* **Part 14: Node.js, Express & Server Infrastructure**
* The Node.js runtime environment, event-driven architecture, HTTP modules, and Express middleware.
* Designing RESTful API routing, status codes, and error handling middleware.


* **Part 15: Database Design & Schema Architecture**
* Relational (PostgreSQL) vs. Document-based (MongoDB) database paradigms.
* Database normalization, primary/foreign key constraints, indexing, and SQL CRUD queries.


* **Part 16: Type-Safe ORMs & Database Migrations**
* Connecting applications to data layers via modern ORMs (Prisma or Drizzle).
* Managing database migrations, schema synchronization, seeding, and execution via CLI.


* **Part 17: Authentication, Authorization & Security Best Practices**
* Password hashing (Bcrypt/Argon2) and stateless authentication with JWTs & HTTP-only cookies.
* Role-Based Access Control (RBAC), CORS, rate limiting, and input sanitization.



---

### Phase 4: Next.js 16 Architecture & DevOps

> **Goal:** Bridge frontend and backend using Next.js 16's App Router, automated builds, containerization, and cloud deployment.

* **Part 18: Next.js 16 App Router & Core Concepts**
* File-system routing, layouts, loading boundaries, and error components.
* Understanding Server Components vs. Client Component boundaries.


* **Part 19: Next.js 16 Data Architecture & Dynamic APIs**
* Handling mandatory Async Request APIs (`await params`, `await cookies()`, `await headers()`).
* Server Actions, mutation patterns, and proxy networking patterns (`proxy.ts`).


* **Part 20: Caching & Modern Performance Tooling**
* Explicit caching boundaries, `cacheLife` profiles, and tag-based revalidation (`revalidateTag`, `updateTag`).
* Optimizing development and build pipelines with Turbopack and DevTools MCP integration.


* **Part 21: Testing, Docker & Cloud CI/CD Pipelines**
* Unit and integration testing (Vitest/Playwright) for full-stack flows.
* Containerizing full-stack environments with Docker & Docker Compose.
* Automating CI/CD workflows using GitHub Actions and deploying to platforms like Vercel, Railway, or AWS.



---

### Phase 5: Production Cloud Services & Event-Driven Architecture

> **Goal:** Offload complex infrastructure (Auth, CMS, Queues) to cloud primitives to build scalable, event-driven SaaS products.

```
                                  ┌────────────────────────┐
                                  │      Next.js 16        │
                                  └───────────┬────────────┘
                                              │
         ┌────────────────────────────────────┼────────────────────────────────────┐
         │                                    │                                    │
┌────────▼────────┐                  ┌────────▼────────┐                  ┌────────▼────────┐
│     Clerk       │                  │     Sanity      │                  │     Inngest     │
├─────────────────┤                  ├─────────────────┤                  ├─────────────────┤
│ Auth & Users    │                  │ Headless Content│                  │ Background Jobs │
│ Middleware      │                  │ Live Preview    │                  │ Event Workflows │
│ Organization RBAC│                 │ Schema TypeGen  │                  │ Retries & Delay │
└─────────────────┘                  └─────────────────┘                  └─────────────────┘

```

* **Part 22: Identity & Auth Orchestration with Clerk**
* Protecting Next.js routes using Clerk middleware, handling session tokens, and public/private layout boundaries.
* Implementing Passkeys, OAuth providers, and organization-based multi-tenancy.
* Syncing user events (`user.created`, `user.updated`) via webhooks to primary PostgreSQL databases.


* **Part 23: Headless Content Architecture with Sanity CMS**
* Modeling schemas (`defineType`, `defineField`), setting up Sanity Studio, and executing GROQ queries.
* End-to-end type safety using Sanity TypeGen for automatic TypeScript integration.
* Connecting Sanity's Live Content API with Next.js revalidation tags for instant visual editing updates.


* **Part 24: Event-Driven Workflows & Background Processing with Inngest**
* Understanding serverless execution limits and why long-running background tasks need durable execution.
* Creating event-driven functions (`step.run`, `step.sleep`, `step.wait`) and hosting them via Next.js Route Handlers.
* Building fault-tolerant workflows (e.g., automated email sequences, background AI processing, video transformations).


* **Part 25: Monolithic Integration & SaaS Billing**
* Connecting Stripe webhooks with Clerk organization IDs and Inngest background event processing.
* Monitoring, observability, and debugging full-stack production environments.



---

## 🛠️ Phase 5 Capstone Specification: Event-Driven AI Publishing SaaS

To validate the entire stack, students complete an enterprise-grade capstone project integrating every layer:

1. **System Architecture Diagramming:** Students map out frontend UI, backend server actions, headless CMS endpoints, and background queue topologies before writing code.
2. **Authentication & Multi-Tenancy:** Users log in via **Clerk** (OAuth / Passkeys) with team-level organization roles.
3. **Content Management:** Authors draft content in **Sanity Studio**, leveraging live visual previews inside **Next.js 16**.
4. **Event Processing:** Publishing content triggers an **Inngest** workflow that asynchronously runs AI summarization, generates social media posts, sends batch newsletters, and handles API retries.
5. **Monetization & Database Sync:** **Stripe** subscription webhooks sync subscription status via **Inngest** directly to a **PostgreSQL** database.
