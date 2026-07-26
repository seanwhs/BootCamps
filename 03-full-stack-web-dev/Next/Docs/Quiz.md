# LaunchPad: Quiz and Test Bank

## From Zero to Production with Next.js 16

---

## Part 1: Introduction to Next.js

### Quiz 1.1: Multiple Choice

**1. What is the primary difference between React and Next.js?**

A) React is a framework, Next.js is a library  
B) React handles UI components, Next.js adds routing, rendering, and optimization  
C) Next.js only works with TypeScript, React works with JavaScript  
D) There is no difference; they are the same thing

**Answer: B**

---

**2. Which command creates a new Next.js 16 application with the App Router and TypeScript?**

A) `npx create-next-app launchpad`  
B) `npx create-next-app@16 launchpad --typescript --eslint --app --src-dir --no-tailwind`  
C) `npm init next-app launchpad --ts`  
D) `next create launchpad --app --ts`

**Answer: B**

---

**3. What is the purpose of `layout.tsx` in the App Router?**

A) It defines the page content for a specific route  
B) It provides shared UI around child routes and defines document structure  
C) It handles API requests for the application  
D) It stores CSS styles for the application

**Answer: B**

---

**4. Which file should you use to create a custom 404 page?**

A) `404.tsx`  
B) `error.tsx`  
C) `not-found.tsx`  
D) `missing.tsx`

**Answer: C**

---

**5. What does the `"use client"` directive indicate?**

A) The component should only run on the server  
B) The component needs browser-side JavaScript and can use React hooks  
C) The component is a legacy React component  
D) The component should be rendered on the client only after hydration

**Answer: B**

---

### Quiz 1.2: True/False

**1. Server Components can use `useState` and `useEffect`.**

**Answer: False**

---

**2. The root layout must contain both `<html>` and `<body>` elements.**

**Answer: True**

---

**3. `npm run build` runs the application in development mode.**

**Answer: False** (It creates a production build)

---

**4. TypeScript types are enforced at runtime in Next.js applications.**

**Answer: False** (Types are only checked during compilation)

---

**5. In Next.js 16, `searchParams` is a Promise that must be awaited.**

**Answer: True**

---

### Quiz 1.3: Short Answer

**1. Explain the difference between `npm run dev` and `npm run start`.**

**Answer:** `npm run dev` starts the development server with Fast Refresh, detailed error messages, and file watching. `npm run start` serves an already-built production version of the application that has been optimized for performance and deployment.

---

**2. What are three responsibilities of the root layout file?**

**Answer:**
1. Defines the document structure (`<html>`, `<body>`)
2. Sets default metadata (title template, description)
3. Wraps all pages with shared UI elements (if any at root level)

---

**3. What is Fast Refresh and why is it useful?**

**Answer:** Fast Refresh is Next.js's development feature that updates changed React components while preserving component state when possible. It provides immediate feedback when editing code without requiring a full page reload or losing the current application state.

---

## Part 2: Routing and Pages

### Quiz 2.1: Multiple Choice

**1. Which URL will `src/app/projects/[projectId]/page.tsx` match?**

A) `/projects`  
B) `/projects/list`  
C) `/projects/website-redesign`  
D) `/project/123`

**Answer: C**

---

**2. How do you access query parameters (search parameters) in a Next.js 16 page?**

A) `useRouter().query`  
B) `window.location.search`  
C) `searchParams` prop passed to the page as a Promise  
D) `params` prop passed to the page

**Answer: C**

---

**3. What does `generateStaticParams()` do?**

A) Generates dynamic routes at request time  
B) Tells Next.js which dynamic route values to pre-render at build time  
C) Creates static assets for the application  
D) Generates static metadata for SEO

**Answer: B**

---

**4. Which import is used for client-side navigation between routes?**

A) `import { useRouter } from "react-router"`  
B) `import Link from "next/link"`  
C) `import { navigate } from "next/navigation"`  
D) `import { useNavigate } from "next/router"`

**Answer: B**

---

**5. What status code does `notFound()` return?**

A) 200  
B) 400  
C) 404  
D) 500

**Answer: C**

---

### Quiz 2.2: True/False

**1. A route group directory name appears in the URL.**

**Answer: False**

---

**2. Search parameters should be validated on the server because users can modify them.**

**Answer: True**

---

**3. `generateStaticParams()` is required for all dynamic routes.**

**Answer: False** (It's optional but recommended for known dynamic routes)

---

**4. `next/link` causes a full page reload when navigating.**

**Answer: False** (It enables client-side transitions)

---

**5. The `params` prop is only available in dynamic routes.**

**Answer: True**

---

### Quiz 2.3: Short Answer

**1. What is the difference between a path parameter and a search parameter? Give examples.**

**Answer:** Path parameters identify a specific resource and are part of the URL path (e.g., `/projects/website-redesign` where `website-redesign` is the path parameter). Search parameters provide optional filtering or view state and appear after the `?` (e.g., `/projects?status=ACTIVE` where `status=ACTIVE` is the search parameter).

---

**2. Why should you validate URL parameters even when TypeScript types are defined?**

**Answer:** TypeScript types only exist during development. At runtime, users can manually enter any value in the URL. Without validation, an attacker could cause the application to crash, produce unexpected behavior, or potentially create security vulnerabilities.

---

**3. What does the following route structure produce?** `src/app/(marketing)/about/page.tsx`

**Answer:** This creates the URL `/about`. The `(marketing)` group name does not appear in the URL but allows the route to use a specific layout.

---

## Part 3: Layouts and UI Composition

### Quiz 3.1: Multiple Choice

**1. What is the purpose of a route group (e.g., `(marketing)`)?**

A) To create a URL segment named "marketing"  
B) To organize routes without affecting the URL  
C) To create a separate application for marketing pages  
D) To apply authentication to all routes in the group

**Answer: B**

---

**2. How does a nested layout affect child routes?**

A) It replaces the root layout for those routes  
B) It wraps child pages while preserving the root layout  
C) It only applies to API routes  
D) It must be re-imported on every page

**Answer: B**

---

**3. What is the `children` prop in a layout component?**

A) The component's child elements passed from the parent  
B) The active route content that should be rendered inside the layout  
C) The application's metadata configuration  
D) The layout's CSS classes

**Answer: B**

---

**4. Which metadata field prevents search engines from indexing workspace routes?**

A) `noindex: true`  
B) `robots: { index: false, follow: false }`  
C) `search: false`  
D) `disallow: "/workspace"`

**Answer: B**

---

**5. What is the difference between a layout and a template?**

A) Layouts persist across navigation; templates remount  
B) Templates are faster than layouts  
C) Layouts can't use `children`; templates can  
D) There is no difference

**Answer: A**

---

### Quiz 3.2: True/False

**1. Route groups are a security feature that prevents unauthorized access.**

**Answer: False** (They are only for organization and layout boundaries)

---

**2. The root layout must be the only file containing `<html>` and `<body>` elements.**

**Answer: True**

---

**3. Child route metadata completely replaces parent metadata.**

**Answer: False** (It can override specific fields but merges with parent metadata)

---

**4. Nested layouts require the route group to be named the same as the layout.**

**Answer: False** (They are independent)

---

**5. `layout.tsx` can be placed inside route groups to apply different shells to different route sets.**

**Answer: True**

---

### Quiz 3.3: Short Answer

**1. Explain the layout hierarchy for a route at `/dashboard/projects` if we have a marketing layout and a workspace layout.**

**Answer:** The layout hierarchy would be: Root Layout → Workspace Layout → Dashboard Layout (if present) → Projects Page. The Marketing Layout would not apply because `/dashboard/projects` is under the Workspace route group.

---

**2. What is the difference between `aria-label` and `aria-labelledby` in navigation elements?**

**Answer:** `aria-label` directly provides a label string to assistive technology (e.g., `aria-label="Primary navigation"`). `aria-labelledby` references another element's ID that contains the label text (e.g., `aria-labelledby="nav-heading"`). `aria-labelledby` is preferred when the label is visible on the page.

---

## Part 4: Server and Client Components

### Quiz 4.1: Multiple Choice

**1. What is the default component type in the Next.js App Router?**

A) Client Component  
B) Server Component  
C) Static Component  
D) Hybrid Component

**Answer: B**

---

**2. What does `import "server-only"` do?**

A) Installs the server-only package  
B) Prevents the module from being imported by Client Components  
C) Makes the module available only in serverless environments  
D) Optimizes the module for server-side rendering

**Answer: B**

---

**3. Which of the following CAN be used in a Server Component?**

A) `useState`  
B) `useEffect`  
C) `async/await`  
D) `onClick` event handlers

**Answer: C**

---

**4. What is the purpose of `usePathname()` hook?**

A) To get the current URL pathname in a Client Component  
B) To set the page title dynamically  
C) To navigate to a different route  
D) To get query parameters from the URL

**Answer: A**

---

**5. What does hydration refer to in React/Next.js?**

A) Adding water to CSS styles  
B) Attaching JavaScript event handlers to server-rendered HTML  
C) Loading the database connection  
D) Building the production bundle

**Answer: B**

---

### Quiz 4.2: True/False

**1. A Client Component cannot import any Server Components.**

**Answer: False** (Server Components can be passed as children to Client Components)

---

**2. `window` and `document` are available in Server Components.**

**Answer: False**

---

**3. `useId()` works in both Server and Client Components.**

**Answer: True**

---

**4. All props passed from Server to Client Components must be serializable.**

**Answer: True**

---

**5. Adding `"use client"` to a layout means all its child components become Client Components.**

**Answer: True** (They become part of the client component tree)

---

### Quiz 4.3: Short Answer

**1. What is the "interactive island" pattern and why is it useful?**

**Answer:** The interactive island pattern places small, focused Client Components inside a mostly server-rendered page. This is useful because it keeps most of the page on the server (reducing bundle size and improving performance) while providing interactivity only where needed (e.g., search bars, disclosures, copy buttons).

---

**2. Why should you keep Client Components small and focused?**

**Answer:** Smaller Client Components reduce the amount of JavaScript sent to the browser, improve load times, reduce parsing and execution time, and make the code more maintainable. Only the parts that need browser interactivity should become Client Components.

---

**3. What would happen if a Client Component imported a module containing database code?**

**Answer:** The build would fail because the database module likely imports `server-only` or uses Node.js APIs that aren't available in the browser. Even if it didn't fail, database credentials would be exposed in the browser bundle, creating a severe security vulnerability.

---

## Part 5: Data Fetching in Next.js 16

### Quiz 5.1: Multiple Choice

**1. Why should browser code never connect directly to the database?**

A) It would be too slow  
B) Database credentials would be exposed in the browser  
C) The browser doesn't support SQL  
D) It would create too many connections

**Answer: B**

---

**2. What is the purpose of Zod in Next.js data fetching?**

A) To connect to the database  
B) To validate data at runtime  
C) To generate TypeScript types  
D) To handle authentication

**Answer: B**

---

**3. What is a parameterized query?**

A) A query that uses parameters for filtering  
B) A query where values are sent separately from SQL instructions to prevent injection  
C) A query that returns parameters from the database  
D) A query that only runs with user parameters

**Answer: B**

---

**4. What does Suspense enable in Next.js?**

A) Lazy loading of images  
B) Streaming of server-rendered content  
C) Authentication for routes  
D) Database migrations

**Answer: B**

---

**5. What is request memoization with React's `cache()`?**

A) Caching data across all users  
B) Caching data between deployment builds  
C) Deduplicating identical queries during one server request  
D) Caching static assets in the browser

**Answer: C**

---

### Quiz 5.2: True/False

**1. PostgreSQL migrations should be applied manually to production databases.**

**Answer: False** (They should be part of a repeatable deployment process)

---

**2. TypeScript types protect against invalid database data at runtime.**

**Answer: False** (Zod or similar runtime validation is needed)

---

**3. `server-only` ensures a module is never imported by client code.**

**Answer: True**

---

**4. Streaming makes database queries faster.**

**Answer: False** (It changes delivery behavior, not query speed)

---

**5. The database client should be created once and reused across requests.**

**Answer: True** (Connection pooling is more efficient)

---

### Quiz 5.3: Short Answer

**1. What is the difference between request memoization and persistent caching?**

**Answer:** Request memoization (using `cache()`) deduplicates identical queries during a single server rendering request. The cached result is discarded after the request completes. Persistent caching stores results across requests and can serve stale data. Persistent caching requires explicit policy about expiration and invalidation.

---

**2. Explain the data flow from a Next.js page to PostgreSQL and back.**

**Answer:** 
1. Browser requests a route
2. Server Component receives the request
3. Server Component calls a server-only query function
4. Query function uses the database client (connection pool)
5. Database client executes parameterized SQL on PostgreSQL
6. Database returns rows
7. Query function validates rows with Zod schemas
8. Server Component renders the validated data
9. Rendered HTML is sent to the browser

---

**3. Why is runtime validation important even when using TypeScript?**

**Answer:** TypeScript types are removed during compilation and don't exist at runtime. The actual data from the database, API, or user input might not match the TypeScript types. Runtime validation ensures the data is correct before being used by the application, preventing crashes and security issues.

---

## Part 6: Styling Your Application

### Quiz 6.1: Multiple Choice

**1. What are design tokens?**

A) Pre-written CSS classes  
B) Named visual decisions (colors, spacing, typography) stored as CSS variables  
C) React components for styling  
D) Design system documentation

**Answer: B**

---

**2. How do CSS Modules differ from global CSS?**

A) CSS Modules are faster than global CSS  
B) CSS Modules automatically scope class names to the component  
C) CSS Modules only work with Tailwind CSS  
D) There is no functional difference

**Answer: B**

---

**3. What does `next/font` provide?**

A) CDN-hosted fonts  
B) Self-hosted, optimized fonts with automatic fallback handling  
C) Font weight presets  
D) Font-size responsive utilities

**Answer: B**

---

**4. What is the purpose of a skip link?**

A) To skip CSS animations  
B) To allow keyboard users to bypass repeated navigation and go to main content  
C) To skip to the next page in a paginated list  
D) To skip loading images

**Answer: B**

---

**5. How do you apply CSS Module styles in a component?**

A) `import "./component.module.css"` and use as regular classes  
B) `import styles from "./component.module.css"` and use `className={styles.className}`  
C) Use the `style` prop directly  
D) Apply them in a `<style>` tag in the component

**Answer: B**

---

### Quiz 6.2: True/False

**1. CSS Modules scoping only works when using the `className` attribute.**

**Answer: True**

---

**2. `next/font` downloads fonts at runtime from Google's CDN.**

**Answer: False** (Fonts are downloaded during build and self-hosted)

---

**3. `prefers-reduced-motion` is a CSS media feature that detects user motion preferences.**

**Answer: True**

---

**4. Global CSS should be used for component-specific styles.**

**Answer: False** (CSS Modules are better for component-specific styles)

---

**5. The `satisfies` keyword in TypeScript validates that values match a type without changing their inferred type.**

**Answer: True**

---

### Quiz 6.3: Short Answer

**1. Why would you use CSS Modules instead of global CSS for component styles?**

**Answer:** CSS Modules provide local scoping, preventing class name collisions between components. They make it clear which styles belong to which component, improve maintainability, and reduce the risk of unintended side effects from global styles.

---

**2. What is the purpose of the `satisfies` operator in a status badge variant map?**

```tsx
const statusClassNames = {
  ACTIVE: styles.active,
  PLANNED: styles.planned,
  COMPLETED: styles.completed,
} satisfies Record<ProjectStatus, string>;
```

**Answer:** The `satisfies` operator ensures that every possible project status has a corresponding CSS class defined. If a new status is added to `ProjectStatus` but not to `statusClassNames`, TypeScript will report an error, preventing runtime bugs.

---

**3. What does `tabIndex={-1}` do on a `#main-content` element?**

**Answer:** It allows the element to receive programmatic focus (via the skip link) without adding it to the normal Tab order of the page. Keyboard users can tab to the skip link, press Enter, and focus moves to the main content without the main content itself being in the tab order for regular navigation.

---

## Part 7: Building APIs and Full-Stack Features

### Quiz 7.1: Multiple Choice

**1. What is the difference between a Route Handler and a Server Action?**

A) Route Handlers are for APIs, Server Actions are for form submissions  
B) There is no difference  
C) Route Handlers run on the client, Server Actions run on the server  
D) Server Actions are for GET requests, Route Handlers for POST

**Answer: A**

---

**2. Why should input be validated on the server even when it's already validated in the browser?**

A) Server validation is faster  
B) Browser validation can be bypassed; server validation ensures security  
C) It's a Next.js requirement  
D) To reduce database load

**Answer: B**

---

**3. What is the purpose of `revalidatePath()` after a mutation?**

A) To restart the server  
B) To refresh the browser cache  
C) To invalidate cached data for the specified routes  
D) To reconnect to the database

**Answer: C**

---

**4. What HTTP status code is appropriate for a successful POST request that creates a resource?**

A) 200 OK  
B) 201 Created  
C) 204 No Content  
D) 202 Accepted

**Answer: B**

---

**5. What does `useActionState` provide when used with a Server Action?**

A) The current state, a form action function, and a pending status  
B) Database connection status  
C) The user's authentication state  
D) Route parameter information

**Answer: A**

---

### Quiz 7.2: True/False

**1. Route Handlers are only for public APIs, not for authenticated endpoints.**

**Answer: False** (They can be used for both public and authenticated endpoints)

---

**2. Server Actions are only accessible from the application, not from external clients.**

**Answer: True** (They are designed for form submissions within the Next.js app)

---

**3. A 204 No Content response should not include a response body.**

**Answer: True**

---

**4. `revalidatePath` should be called after every server-side rendering.**

**Answer: False** (It should only be called after mutations that change data)

---

**5. Input validation should use the same schemas for both Route Handlers and Server Actions.**

**Answer: True** (Shared schemas prevent duplication and ensure consistency)

---

### Quiz 7.3: Short Answer

**1. When would you choose a Route Handler over a Server Action?**

**Answer:** Choose a Route Handler when you need: an explicit HTTP API for external clients, mobile applications, third-party integrations, webhooks, or health checks. Choose a Server Action when the mutation is triggered by a Next.js form or UI element and doesn't need to be exposed as a public API.

---

**2. What is the purpose of the `readJsonBody` helper function?**

**Answer:** `readJsonBody` safely parses JSON from a request body, validates the `Content-Type` header, and returns either the parsed data or an appropriate error response. It centralizes error handling for malformed JSON and missing content types.

---

**3. Why should database mutations use `INSERT ... SELECT` for task creation?**

**Answer:** Using `INSERT ... SELECT` ensures a task is only inserted if the referenced project exists. If the project doesn't exist, no task is inserted and the function returns `null`. This prevents orphaned tasks and provides atomic validation at the database level.

---

## Part 8: Authentication and State Management

### Quiz 8.1: Multiple Choice

**1. What is the difference between authentication and authorization?**

A) Authentication is for users, authorization is for APIs  
B) Authentication verifies identity, authorization determines permissions  
C) Authorization is done in the browser, authentication on the server  
D) There is no difference

**Answer: B**

---

**2. Why are passwords hashed with bcrypt instead of stored as plaintext?**

A) bcrypt is faster than plaintext storage  
B) bcrypt creates a one-way hash that's computationally expensive to reverse  
C) bcrypt encrypts passwords for transmission  
D) bcrypt compresses passwords to save storage

**Answer: B**

---

**3. How should session tokens be stored in the database?**

A) As plain text for easy lookup  
B) As an encrypted string  
C) As a SHA-256 hash of the original token  
D) As a bcrypt hash

**Answer: C**

---

**4. Which cookie attribute prevents JavaScript from reading the cookie?**

A) `Secure`  
B) `SameSite`  
C) `HttpOnly`  
D) `Path`

**Answer: C**

---

**5. Why should unauthorized requests for private resources return 404 instead of 403?**

A) 404 is easier to implement  
B) It prevents attackers from knowing whether a private resource exists  
C) 403 is only for authentication errors  
D) Browsers handle 404 better

**Answer: B**

---

### Quiz 8.2: True/False

**1. Password hashing and session hashing should use the same algorithm.**

**Answer: False** (Passwords use bcrypt; session tokens use SHA-256)

---

**2. `SameSite=Lax` prevents cross-site request forgery for all requests.**

**Answer: False** (It provides defense in depth but isn't complete protection)

---

**3. A valid session cookie guarantees the user is authorized for all resources.**

**Answer: False** (Authorization must be checked for each resource individually)

---

**4. `deleteExpiredSessions()` should be called on every request.**

**Answer: False** (Expired sessions should be cleaned up by a scheduled job)

---

**5. The workspace layout's `requireUser()` function is sufficient to protect all workspace routes.**

**Answer: False** (APIs and Server Actions must also enforce authentication independently)

---

### Quiz 8.3: Short Answer

**1. Explain the full authentication flow from user sign-in to authenticated request.**

**Answer:**
1. User submits email and password
2. Server verifies credentials with bcrypt
3. Server creates a cryptographically random session token
4. Database stores a SHA-256 hash of the token with user ID and expiration
5. Browser receives the original token in an HttpOnly, Secure cookie
6. Future requests send the cookie automatically
7. Server hashes the cookie value and looks up the session
8. If valid, the server loads the authenticated user
9. Authorization checks determine if the user can perform the requested operation

---

**2. Why should both `password` and `confirmPassword` be validated on the server?**

**Answer:** Client-side validation provides a better user experience, but it can be bypassed by tools like browser devtools, API clients, or automated scripts. Server validation is the authoritative check and prevents registration with mismatched passwords even if the client validation is bypassed.

---

**3. What is the purpose of the `Vary: Cookie` header in API responses?**

**Answer:** The `Vary: Cookie` header tells caches that the response varies based on the `Cookie` header. This prevents a cached response for one user from being served to another user, which could leak private data. It ensures authenticated responses are not served to anonymous requests.

---

## Part 9: Performance and Optimization

### Quiz 9.1: Multiple Choice

**1. What is the first step in the performance optimization cycle?**

A) Make a change  
B) Optimize the database  
C) Measure the current performance  
D) Remove unused dependencies

**Answer: C**

---

**2. What is the primary benefit of `next/image`?**

A) It automatically resizes images  
B) It provides responsive, optimized images with built-in lazy loading and layout stability  
C) It hosts images on a CDN  
D) It converts images to WebP format

**Answer: B**

---

**3. When should you use the `priority` attribute on an image?**

A) On every image in the application  
B) On above-the-fold images that are likely the Largest Contentful Paint element  
C) On images that are below the fold  
D) Only on decorative images

**Answer: B**

---

**4. What is code splitting?**

A) Splitting code into multiple files for better organization  
B) Dividing JavaScript bundles so optional features load only when needed  
C) Separating server and client code  
D) Breaking up CSS into multiple files

**Answer: B**

---

**5. What cache policy should be used for authenticated project APIs?**

A) `Cache-Control: public, max-age=3600`  
B) `Cache-Control: private, no-store`  
C) `Cache-Control: no-cache`  
D) `Cache-Control: must-revalidate`

**Answer: B**

---

### Quiz 9.2: True/False

**1. Client Components are always faster than Server Components.**

**Answer: False** (Client Components require more JavaScript to download and execute)

---

**2. CSS Modules can help reduce unnecessary re-renders.**

**Answer: False** (CSS Modules affect styling, not component re-rendering)

---

**3. The `sizes` attribute on `next/image` helps the browser choose the right image size.**

**Answer: True**

---

**4. Code splitting should be used for every component in the application.**

**Answer: False** (It adds overhead; use it for optional features only)

---

**5. Bundle analysis is only useful for client-side JavaScript.**

**Answer: False** (It shows both server and client bundles)

---

### Quiz 9.3: Short Answer

**1. What is the difference between LCP, CLS, and INP?**

**Answer:**
- **LCP** (Largest Contentful Paint): Measures loading performance; when the largest visible element appears
- **CLS** (Cumulative Layout Shift): Measures visual stability; how much content shifts unexpectedly during loading
- **INP** (Interaction to Next Paint): Measures responsiveness; how quickly the page responds to user interactions

---

**2. Why is `ssr: false` used in the project insights dynamic import?**

**Answer:** The project insights feature is optional and not needed for initial page rendering. Using `ssr: false` prevents the component from rendering on the server, reducing the initial bundle size and server rendering time. The component is only loaded when the user explicitly requests it by clicking the "Load project insights" button.

---

**3. What is the purpose of the bundle analyzer and what should you look for in its report?**

**Answer:** The bundle analyzer visualizes the composition of JavaScript bundles. You should look for:
- Large unexpected dependencies
- Server-only packages (like `postgres` or `bcryptjs`) appearing in client bundles
- Duplicate versions of the same library
- Optional features that aren't properly split into their own chunks
- Overall bundle size growth from new dependencies

---

## Part 10: Deployment and Production Readiness

### Quiz 10.1: Multiple Choice

**1. Why should environment variables be validated at application startup?**

A) To make the application run faster  
B) To fail fast if configuration is invalid rather than failing at request time  
C) To log the variables for debugging  
D) To encrypt the variables

**Answer: B**

---

**2. What is a tracked migration system?**

A) A system that tracks changes to database schema and checksums applied migrations  
B) A system that tracks user activity in the database  
C) A system that tracks database query performance  
D) A system that tracks database connections

**Answer: A**

---

**3. What is the difference between liveness and readiness?**

A) Liveness checks if the process is running; readiness checks if it can serve traffic  
B) Liveness checks the database; readiness checks the application  
C) There is no difference  
D) Liveness is for development; readiness is for production

**Answer: A**

---

**4. Why is structured logging preferable to plain text logs?**

A) It's easier to read  
B) It's machine-parsable and searchable across systems  
C) It takes less storage space  
D) It's automatically encrypted

**Answer: B**

---

**5. What should a production runbook contain?**

A) Source code documentation  
B) Deployment procedures, health checks, rollback procedures, and incident response  
C) Marketing materials  
D) User documentation

**Answer: B**

---

### Quiz 10.2: True/False

**1. Applied migration files should never be edited; new migrations should be added instead.**

**Answer: True**

---

**2. The development seed should be run against production databases.**

**Answer: False** (The development seed deletes data and should never run in production)

---

**3. Health checks should expose detailed database error messages.**

**Answer: False** (They should return safe, generic messages)

---

**4. `X-Powered-By` should be removed from response headers for security.**

**Answer: True**

---

**5. SSL/TLS for database connections is optional in production.**

**Answer: False** (Database connections should use TLS in production)

---

### Quiz 10.3: Short Answer

**1. What is the correct order for applying a backward-compatible migration and deploying an application?**

**Answer:**
1. Apply the migration (must be backward-compatible)
2. Deploy the new application version
3. Verify the application works correctly
4. In a later migration, remove any obsolete schema (after confirming no application code uses it)

---

**2. Why is it important to calculate database connection limits before scaling horizontally?**

**Answer:** Each application instance creates a pool of database connections. If you run 20 instances with 10 connections each, you could use 200 connections. If the database limit is 100, you'll exhaust connections and cause failures. The formula is: `max connections per instance ≤ (database limit - reserved admin connections) ÷ maximum instances`.

---

**3. What are three security headers that should be configured in production and what do they do?**

**Answer:**
1. **Content-Security-Policy**: Restricts what resources the browser can load (scripts, styles, images)
2. **X-Frame-Options: DENY**: Prevents the application from being embedded in iframes (clickjacking protection)
3. **Strict-Transport-Security**: Enforces HTTPS by telling browsers to only connect over HTTPS for a specified period

---

## Final Comprehensive Exam

### Section 1: Multiple Choice (40 questions, 60 minutes)

**1. What is the default rendering environment for components in the Next.js App Router?**

A) Client  
B) Server  
C) Static  
D) Hybrid

**Answer: B**

---

**2. Which file is used to define shared UI around multiple pages?**

A) `page.tsx`  
B) `layout.tsx`  
C) `app.tsx`  
D) `ui.tsx`

**Answer: B**

---

**3. How do you create a dynamic route in Next.js?**

A) Create a folder with `[param]` syntax  
B) Use the `useRouter` hook  
C) Create a file named `dynamic.tsx`  
D) Use the `getStaticProps` function

**Answer: A**

---

**4. What does the `"use client"` directive tell Next.js?**

A) The component should be a Server Component  
B) The component needs browser interactivity and React hooks  
C) The component should only be rendered on the client  
D) The component is a legacy class component

**Answer: B**

---

**5. Which package helps prevent server-only modules from being imported in Client Components?**

A) `server-only`  
B) `client-only`  
C) `react-only`  
D) `next-only`

**Answer: A**

---

**6. What is the purpose of Zod in Next.js?**

A) Database connection  
B) Runtime validation  
C) Authentication  
D) Styling

**Answer: B**

---

**7. What is a parameterized SQL query?**

A) A query with default parameters  
B) A query where values are sent separately from the SQL to prevent injection  
C) A query that returns parameters  
D) A query that uses stored procedures

**Answer: B**

---

**8. What does Suspense enable in Next.js?**

A) Lazy loading of components  
B) Streaming server-rendered content  
C) Automatic authentication  
D) Database migrations

**Answer: B**

---

**9. What is request memoization?**

A) Caching data across all users  
B) Deduplicating queries during one server request  
C) Caching between builds  
D) Caching in the browser

**Answer: B**

---

**10. What is the difference between authentication and authorization?**

A) Authentication verifies identity; authorization determines permissions  
B) Authentication is for login; authorization is for logout  
C) There is no difference  
D) Authentication is for APIs; authorization is for pages

**Answer: A**

---

**11. Why are passwords hashed with bcrypt?**

A) bcrypt is the fastest algorithm  
B) bcrypt creates a slow, salted one-way hash that resists brute-force attacks  
C) bcrypt encrypts passwords for transmission  
D) bcrypt compresses passwords

**Answer: B**

---

**12. How are session tokens stored in the database?**

A) As plain text  
B) As encrypted strings  
C) As SHA-256 hashes  
D) As bcrypt hashes

**Answer: C**

---

**13. Which cookie attribute prevents JavaScript access?**

A) `Secure`  
B) `SameSite`  
C) `HttpOnly`  
D) `Path`

**Answer: C**

---

**14. What is the difference between a Route Handler and a Server Action?**

A) Route Handlers are for HTTP APIs; Server Actions are for form mutations  
B) They are the same thing  
C) Route Handlers run on the client  
D) Server Actions are for GET requests

**Answer: A**

---

**15. Why should input be validated on the server?**

A) It's faster than client validation  
B) Client validation can be bypassed by attackers  
C) It's a Next.js requirement  
D) It reduces network traffic

**Answer: B**

---

**16. What does `revalidatePath` do?**

A) Restarts the server  
B) Invalidates cached data for specific routes  
C) Reconnects to the database  
D) Refreshes
