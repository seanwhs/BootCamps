# Part 4: Server and Client Components

In Part 3, we organized LaunchPad around server-rendered layouts and pages. The application currently navigates correctly, but it has very little browser-side interactivity.

In this part, we will introduce Client Components without turning the entire application into a client-rendered application.

By the end of Part 4, LaunchPad will include:

- Explicit server-only modules
- Shared, environment-neutral types
- Active workspace navigation
- Immediate client-side project searching
- Server-rendered status filtering
- A reusable interactive disclosure
- A copy-link control using a browser API
- Accessible interaction feedback
- Small, intentional client boundaries
- A verified production build

---

# Step 1: Establish the Server-First Mental Model

## The Target

Understand which components should run on the server, which components require the browser, and where the boundary belongs.

## The Concept

In the App Router, components are Server Components by default.

A Server Component can:

- Read from a database
- Read private environment variables
- Call server-side services
- Perform sensitive authorization checks
- Render HTML without adding its component code to the browser bundle
- Pass serializable data to Client Components

A Client Component can:

- Use React state
- Use effects
- Handle browser events
- Read the current browser pathname
- Access APIs such as `navigator`, `window`, and `localStorage`

A component becomes a client entry point when its file begins with:

```tsx
"use client";
```

Think of a theater:

- Server Components work backstage to prepare scenery and content.
- Client Components are the controls available to the audience.
- The audience does not need access to the entire backstage area merely to press one button.

The architectural goal is not to avoid Client Components. The goal is to place them around the smallest useful interactive region.

## The Implementation

No files change in this conceptual step.

We will preserve these components as Server Components:

```text
src/app/(marketing)/...
src/app/(workspace)/layout.tsx
src/app/(workspace)/dashboard/page.tsx
src/app/(workspace)/projects/page.tsx
src/app/(workspace)/projects/[projectId]/page.tsx
src/components/site-header.tsx
src/components/site-footer.tsx
```

We will create focused Client Components for:

```text
src/components/workspace-navigation.tsx
src/components/project-list.tsx
src/components/interactive-disclosure.tsx
src/components/copy-project-link.tsx
```

The resulting boundary will resemble:

```text
Server: ProjectsPage
├── Server-rendered heading
├── Server-rendered status form
└── Client: ProjectList
    ├── Search state
    ├── Input event handling
    └── Filtered project cards
```

The project page remains responsible for validating URL data and selecting projects on the server. Only immediate text searching moves into the browser.

## The Verification

Inspect the current source files for existing Client Component directives:

```bash
grep -R '"use client"' src --include="*.tsx" || true
```

At this stage, the command should produce no matches.

Run:

```bash
npx tsc --noEmit
npm run lint
```

Both commands should succeed.

[GENERATED: Part 4, Step 1: Server-First Mental Model] [STARTING: Part 4, Step 2: Server-Only Data Boundary]

---

# Step 2: Protect the Server-Only Project Catalog

## The Target

Mark the temporary project catalog as server-only while moving reusable types and pure calculations into an environment-neutral module.

## The Concept

Some modules must never enter a browser bundle.

A future data module may contain:

- Database clients
- Private credentials
- Server-only environment variables
- Internal service calls
- Authorization logic

We can protect such a module with:

```ts
import "server-only";
```

If a Client Component imports that module, Next.js reports an error instead of quietly bundling unsafe code.

However, types and pure calculations can often be used safely in both environments.

A **pure function** produces a result from its arguments without accessing a database, browser, network, or mutable external state.

For example:

```ts
calculateProjectProgress(project)
```

only performs arithmetic. It can safely run on either the server or client.

We will therefore divide responsibilities:

```text
project-types.ts
├── Shared TypeScript types
├── Shared constants
└── Pure formatting and calculation functions

project-catalog.ts
├── Server-only project records
└── Server-only data lookup functions
```

This resembles a secure office:

- General forms and blank templates can leave the records room.
- The filing cabinets and confidential records remain inside.

## The Implementation

Install the small boundary package:

```bash
npm install server-only
```

Create the shared project module.

### `src/lib/project-types.ts`

```ts
export const PROJECT_STATUSES = [
  "PLANNED",
  "ACTIVE",
  "COMPLETED",
] as const;

export type ProjectStatus = (typeof PROJECT_STATUSES)[number];

export type ProjectSummary = {
  id: string;
  name: string;
  description: string;
  status: ProjectStatus;
  taskCount: number;
  completedTaskCount: number;
};

/**
 * Values arriving from URLs, forms, and APIs are ordinary strings at
 * runtime. This type guard checks whether a string is a supported status.
 */
export function isProjectStatus(value: string): value is ProjectStatus {
  return PROJECT_STATUSES.some((status) => status === value);
}

/**
 * Convert an internal status such as "COMPLETED" into "Completed".
 */
export function formatProjectStatus(status: ProjectStatus): string {
  return `${status.charAt(0)}${status.slice(1).toLowerCase()}`;
}

/**
 * Return a whole-number completion percentage.
 *
 * The zero-task check avoids division by zero.
 */
export function calculateProjectProgress(
  project: ProjectSummary,
): number {
  if (project.taskCount === 0) {
    return 0;
  }

  return Math.round(
    (project.completedTaskCount / project.taskCount) * 100,
  );
}
```

Now completely replace the catalog module.

### `src/lib/project-catalog.ts`

```ts
import "server-only";

import type {
  ProjectStatus,
  ProjectSummary,
} from "@/lib/project-types";

/**
 * Re-exporting these environment-neutral utilities preserves the server-side
 * imports used by existing pages. Client Components must import them directly
 * from project-types.ts rather than from this protected catalog.
 */
export {
  calculateProjectProgress,
  formatProjectStatus,
  isProjectStatus,
  PROJECT_STATUSES,
} from "@/lib/project-types";

export type {
  ProjectStatus,
  ProjectSummary,
} from "@/lib/project-types";

/**
 * This catalog represents server-owned data.
 *
 * In Part 5, database queries will replace these in-memory records. Marking
 * the module server-only now prevents later database code from accidentally
 * entering the browser dependency graph.
 */
const PROJECT_CATALOG = [
  {
    id: "website-redesign",
    name: "Website redesign",
    description:
      "Refresh the marketing website with clearer messaging, faster pages, and an accessible component system.",
    status: "ACTIVE",
    taskCount: 12,
    completedTaskCount: 5,
  },
  {
    id: "mobile-application",
    name: "Mobile application",
    description:
      "Plan and deliver the first mobile experience for customers who manage work away from their desks.",
    status: "PLANNED",
    taskCount: 8,
    completedTaskCount: 0,
  },
  {
    id: "documentation-hub",
    name: "Documentation hub",
    description:
      "Create a searchable home for product guides, engineering standards, and onboarding material.",
    status: "COMPLETED",
    taskCount: 16,
    completedTaskCount: 16,
  },
  {
    id: "analytics-dashboard",
    name: "Analytics dashboard",
    description:
      "Build a shared dashboard that turns product activity into clear and actionable insights.",
    status: "ACTIVE",
    taskCount: 10,
    completedTaskCount: 3,
  },
] as const satisfies readonly ProjectSummary[];

export function getAllProjects(): readonly ProjectSummary[] {
  return PROJECT_CATALOG;
}

export function getProjectById(
  projectId: string,
): ProjectSummary | undefined {
  return PROJECT_CATALOG.find((project) => project.id === projectId);
}

export function getProjectsByStatus(
  status: ProjectStatus,
): readonly ProjectSummary[] {
  return PROJECT_CATALOG.filter((project) => project.status === status);
}
```

### Why `server-only` appears first

This line acts as an import-time protection marker:

```ts
import "server-only";
```

Any Client Component attempting to import `project-catalog.ts` will cause a build error.

The marker does not perform authentication or authorization. It protects module placement, not data ownership.

### Why shared types use another file

Client Components need the `ProjectSummary` type and pure display helpers, but they must not import the server catalog.

They can safely use:

```ts
import type { ProjectSummary } from "@/lib/project-types";
```

They must not use:

```ts
import { getAllProjects } from "@/lib/project-catalog";
```

The page will fetch or select data on the server and pass the safe result downward.

## The Verification

Run:

```bash
npm ls server-only
npx tsc --noEmit
npm run lint
npm run build
```

All commands should succeed.

Confirm that the protection marker exists:

```bash
head -n 1 src/lib/project-catalog.ts
```

Expected output:

```ts
import "server-only";
```

Confirm that the package was recorded:

```bash
grep '"server-only"' package.json
```

Expected output contains a version declaration for `server-only`.

[GENERATED: Part 4, Step 2: Server-Only Data Boundary] [STARTING: Part 4, Step 3: Active Workspace Navigation]

---

# Step 3: Add Active-Route Navigation

## The Target

Convert the workspace navigation into a focused Client Component that identifies the currently active route.

## The Concept

The server knows which route it is rendering, but our reusable navigation component does not receive that information as a prop.

Next.js provides the `usePathname` hook:

```tsx
const pathname = usePathname();
```

A **hook** is a React function that lets a component use capabilities such as state, lifecycle behavior, or router information.

`usePathname` reads the current browser pathname, so it requires a Client Component.

We will make only the workspace navigation client-side. The workspace layout remains a Server Component.

The boundary becomes:

```text
Server: WorkspaceLayout
├── Server: SiteHeader
├── Client: WorkspaceNavigation
├── Server: Active page
└── Server: SiteFooter
```

## The Implementation

Completely replace the workspace navigation.

### `src/components/workspace-navigation.tsx`

```tsx
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const workspaceLinks = [
  {
    href: "/dashboard",
    label: "Overview",
    description: "Workspace summary",
  },
  {
    href: "/projects",
    label: "Projects",
    description: "Browse current work",
  },
] as const;

function isLinkActive(pathname: string, href: string): boolean {
  if (href === "/dashboard") {
    return pathname === href;
  }

  /**
   * Projects should remain active for both the list and detail routes:
   *
   * /projects
   * /projects/website-redesign
   *
   * Requiring a slash after the base path avoids accidental matches such as
   * /projects-archive.
   */
  return pathname === href || pathname.startsWith(`${href}/`);
}

export function WorkspaceNavigation() {
  const pathname = usePathname();

  return (
    <nav
      className="workspace-navigation"
      aria-label="Workspace navigation"
    >
      <p className="workspace-navigation__label">Workspace</p>

      <ul>
        {workspaceLinks.map((link) => {
          const isActive = isLinkActive(pathname, link.href);

          return (
            <li key={link.href}>
              <Link
                className={
                  isActive
                    ? "workspace-navigation__link workspace-navigation__link--active"
                    : "workspace-navigation__link"
                }
                href={link.href}
                aria-current={isActive ? "page" : undefined}
              >
                <span>{link.label}</span>
                <small>{link.description}</small>
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
```

### Why `"use client"` must be first

The directive establishes a client entry point:

```tsx
"use client";
```

It must appear before imports and other executable declarations.

Files imported by this Client Component become part of its client dependency graph. That is why we must not import `project-catalog.ts` here.

### Why `aria-current` matters

The active link receives:

```tsx
aria-current="page"
```

This communicates the current destination to assistive technology. Visual highlighting alone would not provide that information to every user.

### Why nested project routes stay active

This route:

```text
/projects/website-redesign
```

does not equal:

```text
/projects
```

The prefix check handles both list and detail pages:

```ts
pathname === href || pathname.startsWith(`${href}/`)
```

## The Verification

Start the development server:

```bash
npm run dev
```

Open:

```text
http://localhost:3000/dashboard
```

The **Overview** workspace link should appear active.

Open:

```text
http://localhost:3000/projects
```

The **Projects** link should appear active.

Open:

```text
http://localhost:3000/projects/website-redesign
```

The **Projects** link should remain active.

Inspect the rendered active attribute:

```bash
curl --silent http://localhost:3000/dashboard |
  grep -o 'aria-current="page"'
```

Expected output:

```text
aria-current="page"
```

Run:

```bash
npx tsc --noEmit
npm run lint
```

The active state may not yet have distinctive styling. We will add that after implementing the remaining Client Components.

[GENERATED: Part 4, Step 3: Active Workspace Navigation] [STARTING: Part 4, Step 4: Interactive Project Search]

---

# Step 4: Build Immediate Client-Side Project Search

## The Target

Create a Client Component that immediately filters the server-selected project list as the user types.

## The Concept

LaunchPad now needs two related filters:

### Status filter

```text
/projects?status=ACTIVE
```

The status belongs in the URL because it should be:

- Bookmarkable
- Shareable
- Preserved on refresh
- Available during server rendering

### Text search

The text search will provide immediate, temporary filtering while the user types.

This is suitable for local client state because:

- The project list is currently small.
- The search value does not need to be shared.
- No database request is required.
- Immediate feedback improves the experience.

The server remains responsible for choosing the allowed project records. It passes those records to the Client Component.

This is a key security principle:

> A Client Component may filter data it has received, but it must not receive records the user was never authorized to see.

Later, authentication and authorization will ensure the server only returns the current user’s projects.

## The Implementation

Create the interactive project list.

### `src/components/project-list.tsx`

```tsx
"use client";

import Link from "next/link";
import { useMemo, useState } from "react";

import {
  calculateProjectProgress,
  formatProjectStatus,
  type ProjectSummary,
} from "@/lib/project-types";

type ProjectListProps = {
  projects: readonly ProjectSummary[];
  heading: string;
};

export function ProjectList({
  projects,
  heading,
}: ProjectListProps) {
  const [query, setQuery] = useState("");

  const normalizedQuery = query.trim().toLocaleLowerCase();

  const visibleProjects = useMemo(() => {
    if (normalizedQuery.length === 0) {
      return projects;
    }

    return projects.filter((project) => {
      const searchableText = [
        project.name,
        project.description,
        formatProjectStatus(project.status),
      ]
        .join(" ")
        .toLocaleLowerCase();

      return searchableText.includes(normalizedQuery);
    });
  }, [normalizedQuery, projects]);

  return (
    <section aria-labelledby="project-results-heading">
      <div className="client-search">
        <div>
          <label htmlFor="project-search">Search visible projects</label>
          <p>
            Search updates immediately without requesting another page.
          </p>
        </div>

        <div className="client-search__control">
          <input
            id="project-search"
            type="search"
            value={query}
            onChange={(event) => {
              setQuery(event.target.value);
            }}
            placeholder="Search by name or description"
            autoComplete="off"
          />

          {query.length > 0 ? (
            <button
              className="clear-button"
              type="button"
              onClick={() => {
                setQuery("");
              }}
            >
              Clear
            </button>
          ) : null}
        </div>
      </div>

      <div className="results-heading">
        <div>
          <p className="eyebrow">Results</p>
          <h2 id="project-results-heading">{heading}</h2>
        </div>

        <p aria-live="polite" aria-atomic="true">
          {visibleProjects.length}{" "}
          {visibleProjects.length === 1 ? "project" : "projects"}
        </p>
      </div>

      {visibleProjects.length > 0 ? (
        <div className="project-grid">
          {visibleProjects.map((project) => {
            const progress = calculateProjectProgress(project);

            return (
              <article className="project-card" key={project.id}>
                <div className="project-card__heading">
                  <h3>
                    <Link href={`/projects/${project.id}`}>
                      {project.name}
                    </Link>
                  </h3>

                  <span
                    className={`status-badge status-badge--${project.status.toLowerCase()}`}
                  >
                    {formatProjectStatus(project.status)}
                  </span>
                </div>

                <p>{project.description}</p>

                <div className="progress-summary">
                  <div className="progress-summary__labels">
                    <span>Task progress</span>
                    <span>{progress}%</span>
                  </div>

                  <progress
                    max={100}
                    value={progress}
                    aria-label={`${project.name} task completion`}
                  >
                    {progress}%
                  </progress>

                  <p>
                    {project.completedTaskCount} of {project.taskCount} tasks
                    completed
                  </p>
                </div>

                <Link
                  className="text-link"
                  href={`/projects/${project.id}`}
                >
                  View project details
                  <span aria-hidden="true"> →</span>
                </Link>
              </article>
            );
          })}
        </div>
      ) : (
        <div className="empty-state">
          <h3>No projects matched your search</h3>
          <p>
            Try another project name, description, or status.
          </p>

          <button
            className="secondary-button"
            type="button"
            onClick={() => {
              setQuery("");
            }}
          >
            Clear search
          </button>
        </div>
      )}
    </section>
  );
}
```

### Why the prop data is serializable

Server Components can pass serializable values to Client Components.

Our projects contain only:

- Strings
- Numbers
- Plain object properties
- Arrays

These values can cross the server-to-client boundary.

Avoid passing values such as:

- Database client instances
- Open file handles
- Arbitrary class instances
- Server-only functions
- Sensitive credentials

### Why `useState` is necessary

This state stores the current input value:

```tsx
const [query, setQuery] = useState("");
```

When the user types, the event handler updates the value:

```tsx
onChange={(event) => {
  setQuery(event.target.value);
}}
```

React renders the component again with the new search result.

### Why `useMemo` is used

`useMemo` remembers the filtered calculation until one of its dependencies changes:

```tsx
useMemo(() => {
  // Filter projects.
}, [normalizedQuery, projects]);
```

The current catalog is small enough that this optimization is not required for speed. We use it here to demonstrate how a calculated value can be tied explicitly to its inputs.

Do not add `useMemo` automatically to every calculation. It has its own complexity and should serve a clear purpose.

### Why the result count uses `aria-live`

This element announces changes without moving keyboard focus:

```tsx
<p aria-live="polite" aria-atomic="true">
```

A screen-reader user can hear that the result count changed after entering a search.

## The Verification

Run:

```bash
npx tsc --noEmit
npm run lint
```

The new component compiles but is not visible yet. We will connect it to the server-rendered page next.

[GENERATED: Part 4, Step 4: Interactive Project Search] [STARTING: Part 4, Step 5: Server and Client Project Composition]

---

# Step 5: Compose the Server Project Page with the Client List

## The Target

Keep status validation and server-side data selection in the page while delegating immediate text searching to the Client Component.

## The Concept

The server page and client list have different responsibilities.

### Server page

- Reads the URL
- Validates the status
- Selects the allowed records
- Produces the status form
- Passes safe data to the browser

### Client list

- Stores temporary search state
- Handles input events
- Filters records already supplied by the server
- Updates the visible interface immediately

This architecture avoids two extremes:

- Making the whole page a Client Component
- Refusing useful browser interactivity

## The Implementation

Completely replace the project list page.

### `src/app/(workspace)/projects/page.tsx`

```tsx
import type { Metadata } from "next";

import { ProjectList } from "@/components/project-list";
import {
  getAllProjects,
  getProjectsByStatus,
} from "@/lib/project-catalog";
import {
  formatProjectStatus,
  isProjectStatus,
  PROJECT_STATUSES,
  type ProjectStatus,
} from "@/lib/project-types";

export const metadata: Metadata = {
  title: "Projects",
  description:
    "Browse, filter, and search the temporary LaunchPad project catalog.",
};

type ProjectsPageProps = {
  searchParams: Promise<{
    status?: string | string[];
  }>;
};

function readStatusFilter(
  value: string | string[] | undefined,
): ProjectStatus | undefined {
  if (typeof value !== "string") {
    return undefined;
  }

  const normalizedValue = value.toUpperCase();

  return isProjectStatus(normalizedValue)
    ? normalizedValue
    : undefined;
}

export default async function ProjectsPage({
  searchParams,
}: ProjectsPageProps) {
  const query = await searchParams;
  const requestedStatus = query.status;
  const selectedStatus = readStatusFilter(requestedStatus);
  const hasInvalidStatus =
    requestedStatus !== undefined && selectedStatus === undefined;

  /**
   * This selection happens on the server. In Part 8, the same layer will
   * select only records the authenticated user is allowed to access.
   */
  const projects = selectedStatus
    ? getProjectsByStatus(selectedStatus)
    : getAllProjects();

  const resultsHeading = selectedStatus
    ? `${formatProjectStatus(selectedStatus)} projects`
    : "All projects";

  return (
    <main className="site-shell page-content">
      <header className="page-heading">
        <p className="eyebrow">Project workspace</p>
        <h1>Explore the work already on the LaunchPad</h1>
        <p>
          Status filtering runs on the server and remains shareable through
          the URL. Text searching runs in a focused Client Component for
          immediate feedback.
        </p>
      </header>

      <section className="filter-panel" aria-labelledby="filter-heading">
        <div>
          <h2 id="filter-heading">Filter projects by status</h2>
          <p>
            The selected status is stored in the URL so this view can be
            bookmarked or shared.
          </p>
        </div>

        <form action="/projects" method="get" className="filter-form">
          <label htmlFor="status">Project status</label>

          <div className="filter-controls">
            <select
              id="status"
              name="status"
              defaultValue={selectedStatus ?? ""}
            >
              <option value="">All statuses</option>

              {PROJECT_STATUSES.map((status) => (
                <option key={status} value={status}>
                  {formatProjectStatus(status)}
                </option>
              ))}
            </select>

            <button className="primary-button" type="submit">
              Apply filter
            </button>
          </div>
        </form>
      </section>

      {hasInvalidStatus ? (
        <div className="notice notice--warning" role="status">
          <p>
            The requested status is not supported. Showing all projects
            instead.
          </p>
        </div>
      ) : null}

      <ProjectList
        heading={resultsHeading}
        projects={projects}
      />
    </main>
  );
}
```

### Why the page remains a Server Component

The file does not contain:

```tsx
"use client";
```

It can therefore continue importing the protected catalog:

```tsx
import {
  getAllProjects,
  getProjectsByStatus,
} from "@/lib/project-catalog";
```

The Client Component receives only the selected records:

```tsx
<ProjectList projects={projects} />
```

### Why the server and client filters work together

If the user visits:

```text
/projects?status=ACTIVE
```

the server sends only active projects to `ProjectList`.

The client search then searches within those active projects.

The flow is:

```text
URL status
    ↓
Server validation
    ↓
Server-selected project array
    ↓
Client text search
    ↓
Visible cards
```

## The Verification

Open:

```text
http://localhost:3000/projects
```

Confirm that four projects appear.

Type:

```text
website
```

Only **Website redesign** should remain.

Click **Clear**. All four projects should return.

Now open:

```text
http://localhost:3000/projects?status=ACTIVE
```

Only two projects should initially appear.

Type:

```text
analytics
```

Only **Analytics dashboard** should remain.

Refresh the browser. The status filter should remain because it is in the URL, while the temporary text search should reset.

This difference is intentional.

### Verify without browser JavaScript execution

`curl` does not run browser-side React, but the initial server response should still contain the server-selected records:

```bash
active_page="$(
  curl --fail --silent \
    "http://localhost:3000/projects?status=ACTIVE"
)"

printf "%s" "${active_page}" |
  grep --quiet "Website redesign"

printf "%s" "${active_page}" |
  grep --quiet "Analytics dashboard"

if printf "%s" "${active_page}" |
  grep --quiet "Mobile application"; then
  echo "Unexpected planned project in the active server result."
  exit 1
fi

echo "The server supplied only active projects."
```

Expected output:

```text
The server supplied only active projects.
```

Run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 4, Step 5: Server and Client Project Composition] [STARTING: Part 4, Step 6: Interactive Disclosure]

---

# Step 6: Pass Server-Rendered Content into a Client Component

## The Target

Create an interactive disclosure that controls visibility while accepting content composed by a Server Component.

## The Concept

A Client Component cannot directly import a Server Component.

This is invalid architecture:

```tsx
"use client";

import { ServerOnlyProjectDetails } from "./server-only-project-details";
```

That import attempts to pull a server module into the client dependency graph.

However, a Server Component can import a Client Component and pass server-rendered content through `children`:

```tsx
<InteractiveDisclosure>
  <ServerRenderedContent />
</InteractiveDisclosure>
```

The Client Component controls the interactive container. The server supplies the content placed inside it.

Think of a display cabinet:

- The browser controls whether the cabinet door is open.
- The server prepares the item placed inside.
- The cabinet does not need to know how the item was produced.

## The Implementation

Create the disclosure component.

### `src/components/interactive-disclosure.tsx`

```tsx
"use client";

import {
  useId,
  useState,
  type ReactNode,
} from "react";

type InteractiveDisclosureProps = {
  children: ReactNode;
  title: string;
  initiallyOpen?: boolean;
};

export function InteractiveDisclosure({
  children,
  title,
  initiallyOpen = false,
}: InteractiveDisclosureProps) {
  const [isOpen, setIsOpen] = useState(initiallyOpen);
  const contentId = useId();

  return (
    <section className="disclosure">
      <button
        className="disclosure__trigger"
        type="button"
        aria-expanded={isOpen}
        aria-controls={contentId}
        onClick={() => {
          setIsOpen((currentValue) => !currentValue);
        }}
      >
        <span>{title}</span>

        <span aria-hidden="true">
          {isOpen ? "−" : "+"}
        </span>
      </button>

      <div
        className="disclosure__content"
        id={contentId}
        hidden={!isOpen}
      >
        {children}
      </div>
    </section>
  );
}
```

### Why `useId` is used

The button needs to identify the region it controls:

```tsx
aria-controls={contentId}
```

The controlled region receives the same ID:

```tsx
id={contentId}
```

`useId` creates a stable identifier that works with server rendering and hydration.

Do not generate render-time IDs with:

```ts
Math.random()
```

The server and browser could generate different values, causing hydration mismatches.

### Why `hidden` is appropriate

The content remains part of the component structure but is not displayed while closed:

```tsx
hidden={!isOpen}
```

The button communicates the same state with:

```tsx
aria-expanded={isOpen}
```

## The Verification

Run:

```bash
npx tsc --noEmit
npm run lint
```

The component is not visible yet. We will add it to the project-detail page alongside another focused Client Component.

[GENERATED: Part 4, Step 6: Interactive Disclosure] [STARTING: Part 4, Step 7: Browser API Component]

---

# Step 7: Build a Copy-Link Client Component

## The Target

Create an accessible button that copies the current project URL using the browser Clipboard API.

## The Concept

Server Components cannot access:

```ts
window
navigator
document
localStorage
```

These objects exist in the browser, not in the server rendering environment.

The Clipboard API is available through:

```ts
navigator.clipboard
```

Our copy control therefore needs to be a Client Component.

The component will also provide explicit feedback for:

- Successful copying
- Unsupported browser behavior
- Clipboard permission failure

Production-grade interaction should handle failure rather than assuming every browser API call succeeds.

## The Implementation

Create the copy button.

### `src/components/copy-project-link.tsx`

```tsx
"use client";

import { useState } from "react";

type CopyStatus = "idle" | "success" | "error";

type CopyProjectLinkProps = {
  projectName: string;
};

export function CopyProjectLink({
  projectName,
}: CopyProjectLinkProps) {
  const [status, setStatus] = useState<CopyStatus>("idle");

  async function copyCurrentUrl(): Promise<void> {
    try {
      if (!navigator.clipboard) {
        throw new Error("The Clipboard API is unavailable.");
      }

      await navigator.clipboard.writeText(window.location.href);
      setStatus("success");
    } catch {
      /**
       * Browser permissions and security policies can reject clipboard
       * access. The user receives safe feedback without exposing internal
       * exception details.
       */
      setStatus("error");
    }
  }

  return (
    <div className="copy-link-control">
      <button
        className="secondary-button"
        type="button"
        onClick={copyCurrentUrl}
      >
        Copy project link
      </button>

      <p
        className={
          status === "error"
            ? "copy-link-control__status copy-link-control__status--error"
            : "copy-link-control__status"
        }
        role="status"
        aria-live="polite"
      >
        {status === "success"
          ? `Link to ${projectName} copied.`
          : null}

        {status === "error"
          ? "The link could not be copied. Copy it from the address bar instead."
          : null}
      </p>
    </div>
  );
}
```

### Why the URL is read inside the click handler

This is safe:

```ts
window.location.href
```

inside `copyCurrentUrl`, because the function runs after a browser click.

Avoid reading browser globals during server rendering:

```tsx
const currentUrl = window.location.href;
```

That would fail when the component’s initial output is prepared outside the browser.

### Why errors are not displayed directly

The caught error might contain browser-specific or implementation-specific information.

Instead, users receive an actionable message:

```text
The link could not be copied. Copy it from the address bar instead.
```

Detailed diagnostics can later be sent to an approved monitoring system where appropriate.

## The Verification

Run:

```bash
npx tsc --noEmit
npm run lint
```

The component should compile successfully.

It will be rendered in the next step.

[GENERATED: Part 4, Step 7: Browser API Component] [STARTING: Part 4, Step 8: Project Detail Composition]

---

# Step 8: Add Interactive Islands to the Server Project Page

## The Target

Add the disclosure and copy-link Client Components to the server-rendered dynamic project page.

## The Concept

An **interactive island** is a small interactive region inside a mostly server-rendered page.

Our project page will remain a Server Component and continue to own:

- Dynamic route parameters
- Project lookup
- Missing-resource handling
- Metadata
- Project calculations
- Server-rendered content

It will embed two client islands:

- `CopyProjectLink`
- `InteractiveDisclosure`

This gives the page browser behavior without moving its data access into the browser.

## The Implementation

Completely replace the project-detail page.

### `src/app/(workspace)/projects/[projectId]/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";

import { CopyProjectLink } from "@/components/copy-project-link";
import { InteractiveDisclosure } from "@/components/interactive-disclosure";
import {
  calculateProjectProgress,
  formatProjectStatus,
  getAllProjects,
  getProjectById,
} from "@/lib/project-catalog";

type ProjectPageProps = {
  params: Promise<{
    projectId: string;
  }>;
};

export function generateStaticParams() {
  return getAllProjects().map((project) => ({
    projectId: project.id,
  }));
}

export async function generateMetadata({
  params,
}: ProjectPageProps): Promise<Metadata> {
  const { projectId } = await params;
  const project = getProjectById(projectId);

  if (!project) {
    return {
      title: "Project not found",
      description: "The requested LaunchPad project could not be found.",
    };
  }

  return {
    title: project.name,
    description: project.description,
  };
}

export default async function ProjectPage({
  params,
}: ProjectPageProps) {
  const { projectId } = await params;
  const project = getProjectById(projectId);

  if (!project) {
    notFound();
  }

  const progress = calculateProjectProgress(project);
  const remainingTaskCount =
    project.taskCount - project.completedTaskCount;

  return (
    <main className="site-shell page-content">
      <nav className="breadcrumb" aria-label="Breadcrumb">
        <ol>
          <li>
            <Link href="/dashboard">Dashboard</Link>
          </li>
          <li aria-hidden="true">/</li>
          <li>
            <Link href="/projects">Projects</Link>
          </li>
          <li aria-hidden="true">/</li>
          <li aria-current="page">{project.name}</li>
        </ol>
      </nav>

      <article>
        <header className="project-detail-heading">
          <div>
            <p className="eyebrow">Project details</p>
            <h1>{project.name}</h1>
            <p>{project.description}</p>
          </div>

          <span
            className={`status-badge status-badge--${project.status.toLowerCase()}`}
          >
            {formatProjectStatus(project.status)}
          </span>
        </header>

        <div className="project-detail-actions">
          <CopyProjectLink projectName={project.name} />
        </div>

        <section
          className="project-stat-grid"
          aria-label="Project statistics"
        >
          <div className="stat-card">
            <span className="stat-card__label">Total tasks</span>
            <strong>{project.taskCount}</strong>
          </div>

          <div className="stat-card">
            <span className="stat-card__label">Completed</span>
            <strong>{project.completedTaskCount}</strong>
          </div>

          <div className="stat-card">
            <span className="stat-card__label">Remaining</span>
            <strong>{remainingTaskCount}</strong>
          </div>

          <div className="stat-card">
            <span className="stat-card__label">Progress</span>
            <strong>{progress}%</strong>
          </div>
        </section>

        <section
          className="detail-progress"
          aria-labelledby="progress-heading"
        >
          <div className="progress-summary__labels">
            <h2 id="progress-heading">Task completion</h2>
            <span>{progress}%</span>
          </div>

          <progress
            max={100}
            value={progress}
            aria-label={`${project.name} task completion`}
          >
            {progress}%
          </progress>

          <p>
            {project.completedTaskCount} of {project.taskCount} tasks are
            complete.
          </p>
        </section>

        <div className="project-disclosures">
          <InteractiveDisclosure title="How this page is rendered">
            <div className="prose-content">
              <p>
                The project route, metadata, record lookup, and calculations
                are rendered on the server. Only the disclosure control and
                copy-link button require browser-side JavaScript.
              </p>

              <p>
                Keeping the client boundary small reduces unnecessary browser
                code while preserving useful interaction.
              </p>
            </div>
          </InteractiveDisclosure>

          <InteractiveDisclosure title="Current data source">
            <div className="prose-content">
              <p>
                This project currently comes from a protected, server-only
                TypeScript catalog.
              </p>

              <p>
                In Part 5, a relational database will replace the temporary
                records without moving data access into the browser.
              </p>
            </div>
          </InteractiveDisclosure>
        </div>
      </article>

      <Link className="secondary-link" href="/projects">
        <span aria-hidden="true">← </span>
        Return to all projects
      </Link>
    </main>
  );
}
```

### What crosses the client boundary

The copy control receives one serializable string:

```tsx
<CopyProjectLink projectName={project.name} />
```

The disclosure receives:

- A string title
- A boolean default
- Renderable child content

The server-only project lookup function does not cross the boundary.

### What remains server-only

This call stays in the Server Component:

```tsx
const project = getProjectById(projectId);
```

The Client Components do not import or call `getProjectById`.

## The Verification

Open:

```text
http://localhost:3000/projects/website-redesign
```

### Test the disclosure

1. Find **How this page is rendered**.
2. Confirm its content is initially hidden.
3. Activate the button.
4. Confirm the content appears.
5. Confirm the button’s `aria-expanded` value changes to `true`.
6. Activate it again.
7. Confirm the content is hidden.

### Test keyboard operation

1. Press `Tab` until the disclosure button receives focus.
2. Press `Enter` or `Space`.
3. Confirm the content opens.
4. Continue to the copy-link button.
5. Confirm visible focus remains available.

### Test the copy button

Click:

```text
Copy project link
```

On a browser that permits clipboard access, the status should become:

```text
Link to Website redesign copied.
```

Paste into a text editor and confirm the copied value resembles:

```text
http://localhost:3000/projects/website-redesign
```

### Verify the server response still contains disclosure content

Even though the content is controlled by a Client Component, it is supplied during server rendering:

```bash
curl --silent \
  http://localhost:3000/projects/website-redesign |
  grep "The project route, metadata, record lookup"
```

The output should contain the text.

Run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 4, Step 8: Project Detail Interactive Islands] [STARTING: Part 4, Step 9: Client Component Styles]

---

# Step 9: Style the Interactive Components

## The Target

Add accessible styles for active navigation, project searching, buttons, disclosure controls, and copy feedback.

## The Concept

Interactive states need visual communication.

Users should be able to distinguish:

- The active navigation route
- A focused control
- A clickable disclosure
- A successful operation
- A failed operation
- An empty search result

Color should support meaning, not carry all meaning by itself. We also use text, structure, and ARIA attributes.

## The Implementation

Append the following section to the end of:

### `src/app/globals.css`

```css
/* Part 4: focused Client Component boundaries */

.workspace-navigation__link--active {
  border-color: var(--color-primary);
  background: var(--color-primary-soft);
}

.workspace-navigation__link--active span {
  color: var(--color-primary-hover);
}

.client-search {
  display: grid;
  margin-bottom: 2rem;
  padding: 1.5rem;
  border: 0.0625rem solid var(--color-border);
  border-radius: 1rem;
  background: var(--color-surface);
  grid-template-columns: minmax(0, 1fr) minmax(18rem, 0.8fr);
  align-items: end;
  gap: 2rem;
}

.client-search label {
  display: block;
  font-weight: 800;
}

.client-search p {
  margin: 0.4rem 0 0;
  color: var(--color-text-muted);
}

.client-search__control {
  display: flex;
  gap: 0.75rem;
}

.client-search input {
  width: 100%;
  min-width: 0;
  min-height: 2.75rem;
  padding-inline: 0.75rem;
  border: 0.0625rem solid var(--color-border);
  border-radius: 0.65rem;
  background: var(--color-surface);
  color: var(--color-text);
}

.client-search input::placeholder {
  color: var(--color-text-muted);
}

.clear-button,
.secondary-button {
  display: inline-flex;
  min-height: 2.75rem;
  padding: 0.65rem 1rem;
  border: 0.0625rem solid var(--color-border);
  border-radius: 0.65rem;
  background: var(--color-surface);
  color: var(--color-primary);
  align-items: center;
  justify-content: center;
  font-weight: 800;
  line-height: 1.2;
  cursor: pointer;
}

.clear-button {
  flex: 0 0 auto;
}

.clear-button:hover,
.secondary-button:hover {
  border-color: var(--color-primary);
  background: var(--color-primary-soft);
}

.project-detail-actions {
  display: flex;
  margin-top: 1.5rem;
  justify-content: flex-end;
}

.copy-link-control {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.copy-link-control__status {
  min-height: 1.5rem;
  margin: 0;
  color: var(--color-success);
  font-size: 0.9rem;
  font-weight: 700;
}

.copy-link-control__status--error {
  color: #a32626;
}

.project-disclosures {
  display: grid;
  margin-block: 2rem;
  gap: 1rem;
}

.disclosure {
  overflow: hidden;
  border: 0.0625rem solid var(--color-border);
  border-radius: 0.85rem;
  background: var(--color-surface);
}

.disclosure__trigger {
  display: flex;
  width: 100%;
  min-height: 3.5rem;
  padding: 1rem 1.25rem;
  border: 0;
  background: transparent;
  color: var(--color-text);
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  font-weight: 800;
  text-align: left;
  cursor: pointer;
}

.disclosure__trigger:hover {
  background: var(--color-primary-soft);
  color: var(--color-primary-hover);
}

.disclosure__trigger[aria-expanded="true"] {
  border-bottom: 0.0625rem solid var(--color-border);
  background: var(--color-primary-soft);
}

.disclosure__trigger > span:last-child {
  font-size: 1.5rem;
  font-weight: 400;
  line-height: 1;
}

.disclosure__content {
  padding: 1.25rem;
}

.prose-content {
  max-width: 48rem;
}

.prose-content p {
  margin: 0;
  color: var(--color-text-muted);
}

.prose-content p + p {
  margin-top: 1rem;
}

@media (max-width: 48rem) {
  .client-search {
    grid-template-columns: 1fr;
    align-items: stretch;
  }

  .client-search__control {
    align-items: stretch;
    flex-direction: column;
  }

  .project-detail-actions {
    justify-content: flex-start;
  }

  .copy-link-control {
    align-items: flex-start;
    flex-direction: column;
  }
}
```

## The Verification

Visit:

```text
http://localhost:3000/dashboard
```

Confirm the Overview link has an active visual treatment.

Visit:

```text
http://localhost:3000/projects
```

Confirm:

- The Projects link is active.
- The search control aligns beside its explanation on a wide screen.
- The search controls stack on a narrow screen.
- Clear buttons have hover and focus states.

Visit:

```text
http://localhost:3000/projects/website-redesign
```

Confirm:

- Disclosure buttons fill their containers.
- Expanded disclosures display a distinct state.
- Copy feedback appears beside or below the button.
- Controls remain usable on a narrow screen.

Run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 4, Step 9: Client Component Styles] [STARTING: Part 4, Step 10: Boundary Verification]

---

# Step 10: Verify Server and Client Boundaries

## The Target

Verify that server-only data remains protected, interactive controls work, and server-rendered content remains available before hydration.

## The Concept

**Hydration** is the process through which React attaches browser behavior to server-rendered Client Component output.

The general flow is:

```text
Server renders initial output
        ↓
Browser receives HTML and component data
        ↓
Client JavaScript loads
        ↓
React attaches event behavior
        ↓
Controls become interactive
```

A good server/client composition provides useful initial content before interaction activates.

We should verify:

- Project data appears in the initial response.
- Client Components do not fetch the protected catalog.
- Client search updates after hydration.
- Dynamic route behavior remains correct.
- Unknown projects remain server-handled 404 responses.

## The Implementation

Ensure the development server is running:

```bash
npm run dev
```

### Verify server-rendered project content

```bash
curl --fail --silent http://localhost:3000/projects |
  grep --quiet "Website redesign"

echo "Initial project content was server-rendered."
```

Expected output:

```text
Initial project content was server-rendered.
```

### Verify disclosure content exists in the initial response

```bash
curl --fail --silent \
  http://localhost:3000/projects/website-redesign |
  grep --quiet "Keeping the client boundary small"

echo "Disclosure content was supplied by the server."
```

Expected output:

```text
Disclosure content was supplied by the server.
```

### Verify invalid projects still return 404

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/projects/not-real
```

Expected output:

```text
404
```

### Inspect the source boundary declarations

```bash
grep -R '"use client"' src/components --include="*.tsx"
```

Expected matching files:

```text
src/components/copy-project-link.tsx
src/components/interactive-disclosure.tsx
src/components/project-list.tsx
src/components/workspace-navigation.tsx
```

Confirm that pages and layouts did not become Client Components:

```bash
if grep -R '"use client"' src/app --include="*.tsx"; then
  echo "Unexpected Client Component directive in the route tree."
  exit 1
else
  echo "All route pages and layouts remain server-first."
fi
```

Expected output:

```text
All route pages and layouts remain server-first.
```

### Confirm Client Components do not import the catalog

```bash
if grep -R \
  'project-catalog' \
  src/components \
  --include="*.tsx"; then
  echo "A component imported the protected project catalog."
  exit 1
else
  echo "No Client Component imports the protected catalog."
fi
```

Expected output:

```text
No Client Component imports the protected catalog.
```

## The Verification

Complete these browser checks:

1. Open `/projects`.
2. Search for `documentation`.
3. Confirm one result appears immediately.
4. Clear the search.
5. Select `Completed` in the server form.
6. Confirm the URL becomes `?status=COMPLETED`.
7. Confirm one project is supplied by the server.
8. Search for `website`.
9. Confirm the client list displays no matches.
10. Clear the search.
11. Confirm Documentation hub returns.
12. Open the project.
13. Open and close both disclosures.
14. Copy the project link.
15. Confirm visible status feedback appears.

Finally, run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 4, Step 10: Boundary Verification] [STARTING: Part 4, Step 11: Production Build]

---

# Step 11: Verify the Production Build

## The Target

Create an optimized production build and verify that server-only boundaries and Client Components compile together correctly.

## The Concept

Development mode can delay compilation of routes until they are requested. A production build analyzes the complete application.

It can detect problems such as:

- A Client Component importing a server-only module
- Non-serializable values crossing a boundary
- Invalid route exports
- Server/client module conflicts
- Type errors
- Production rendering failures

This makes `npm run build` an essential architectural test.

## The Implementation

Stop the development server:

```text
Ctrl+C
```

Run:

```bash
npx tsc --noEmit
npm run lint
npm run build
```

After a successful build, start the production server:

```bash
npm run start
```

## The Verification

In a second terminal, verify the important routes:

```bash
for path in \
  "/" \
  "/dashboard" \
  "/projects" \
  "/projects?status=ACTIVE" \
  "/projects/website-redesign"
do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000${path}"
  )"

  printf "%-42s %s\n" "${path}" "${status_code}"
done
```

Every route should return:

```text
200
```

Verify that server-selected project content appears:

```bash
active_page="$(
  curl --fail --silent \
    "http://localhost:3000/projects?status=ACTIVE"
)"

printf "%s" "${active_page}" |
  grep --quiet "Website redesign"

printf "%s" "${active_page}" |
  grep --quiet "Analytics dashboard"

if printf "%s" "${active_page}" |
  grep --quiet "Documentation hub"; then
  echo "The active production filter included a completed project."
  exit 1
fi

echo "Production server filtering verified."
```

Expected output:

```text
Production server filtering verified.
```

Open the production application in a browser:

```text
http://localhost:3000/projects
```

Confirm that client-side searching still works.

Stop the production server:

```text
Ctrl+C
```

[GENERATED: Part 4, Step 11: Production Build] [STARTING: Part 4, Step 12: Git Checkpoint]

---

# Step 12: Create the Part 4 Git Checkpoint

## The Target

Commit the server/client boundary work after the complete production quality gate passes.

## The Concept

This checkpoint captures an important architectural transition.

LaunchPad is no longer purely static and server-rendered. It now contains browser interaction, but the interaction is deliberately isolated.

The commit should include:

- The `server-only` dependency
- Protected catalog boundaries
- Shared project types
- Active navigation
- Client-side searching
- Disclosure behavior
- Clipboard behavior
- Associated styles

## The Implementation

Inspect the repository:

```bash
git status
git diff --stat
git diff
```

Run the final quality gate:

```bash
npx tsc --noEmit
npm run lint
npm run build
```

Stage the changes:

```bash
git add package.json package-lock.json src
```

Inspect the staged summary:

```bash
git diff --cached --stat
```

Create the commit:

```bash
git commit -m "feat: add focused client component boundaries"
```

## The Verification

Inspect the latest commit:

```bash
git log -1 --oneline
```

Expected output resembles:

```text
a1b2c3d feat: add focused client component boundaries
```

Confirm a clean working tree:

```bash
git status
```

Expected output:

```text
nothing to commit, working tree clean
```

[GENERATED: Part 4, Step 12: Git Checkpoint] [STARTING: Part 4 Reference Sections]

---

# Part 4 Reference A: Server Component Capabilities

Server Components can perform server-side work directly:

```tsx
export default async function ProjectsPage() {
  const projects = await getProjects();

  return (
    <ul>
      {projects.map((project) => (
        <li key={project.id}>{project.name}</li>
      ))}
    </ul>
  );
}
```

Typical Server Component responsibilities include:

- Database queries
- Server-side service calls
- Authentication checks
- Authorization checks
- Private environment access
- Request-dependent rendering
- Metadata generation
- Data preparation for Client Components

Server Components cannot directly use browser-only behavior such as:

```tsx
useState
useEffect
onClick
window
document
navigator
localStorage
```

An event-handler property is browser behavior:

```tsx
<button onClick={() => alert("Hello")}>
  Click
</button>
```

The component declaring that handler must be within a client boundary.

---

# Part 4 Reference B: Client Component Capabilities

A Client Component begins with:

```tsx
"use client";
```

It can use:

- `useState`
- `useEffect`
- `useReducer`
- `useRef`
- `usePathname`
- `useRouter`
- Event handlers
- Browser APIs
- Interactive third-party libraries

Example:

```tsx
"use client";

import { useState } from "react";

export function Counter() {
  const [count, setCount] = useState(0);

  return (
    <button
      type="button"
      onClick={() => {
        setCount((currentCount) => currentCount + 1);
      }}
    >
      Count: {count}
    </button>
  );
}
```

Client Components are still involved in server rendering of the initial interface. `"use client"` does not mean “render nothing on the server.”

It establishes that the component also needs browser-side JavaScript and may use client-only React capabilities.

---

# Part 4 Reference C: The Client Boundary

The `"use client"` directive marks a module boundary.

Consider:

```text
client-panel.tsx
├── imports button.tsx
├── imports browser-chart.tsx
└── imports format-number.ts
```

If `client-panel.tsx` is a client entry point, its runtime imports become part of the client dependency graph.

This is why the directive should be placed as low as practical.

Avoid:

```tsx
"use client";

export default function EntireWorkspaceLayout() {
  // Everything imported beneath this layout is now affected by the boundary.
}
```

Prefer:

```tsx
export default function WorkspaceLayout({
  children,
}: {
  children: ReactNode;
}) {
  return (
    <>
      <ServerHeader />
      <SmallInteractiveNavigation />
      {children}
    </>
  );
}
```

The layout remains server-first while one focused component handles browser behavior.

---

# Part 4 Reference D: Serializable Props

Values passed from a Server Component to a Client Component must be serializable through React’s server-to-client transport.

Good boundary values include:

```tsx
<ClientComponent
  name="Website redesign"
  count={12}
  active={true}
  tags={["design", "accessibility"]}
  project={{
    id: "website-redesign",
    status: "ACTIVE",
  }}
/>
```

Avoid passing server resources:

```tsx
<ClientComponent database={databaseClient} />
```

Avoid arbitrary functions:

```tsx
<ClientComponent onSave={serverFunction} />
```

Ordinary functions cannot be serialized. Server Actions use a specific framework-supported mechanism and will be introduced later.

Also avoid passing secrets simply because they are technically strings:

```tsx
<ClientComponent databasePassword={process.env.DATABASE_PASSWORD} />
```

Serialization capability does not imply security suitability.

---

# Part 4 Reference E: Importing Server and Client Components

## Server importing Client

Supported:

```tsx
import { InteractiveButton } from "./interactive-button";

export function ServerPage() {
  return <InteractiveButton />;
}
```

## Client importing Server

Not supported:

```tsx
"use client";

import { ServerProjectList } from "./server-project-list";
```

The client module graph cannot pull arbitrary server implementation into the browser.

## Server passing content through `children`

Supported:

```tsx
import { InteractivePanel } from "./interactive-panel";
import { ServerProjectDetails } from "./server-project-details";

export function ServerPage() {
  return (
    <InteractivePanel>
      <ServerProjectDetails />
    </InteractivePanel>
  );
}
```

The server composes the tree. The Client Component receives the prepared child slot.

---

# Part 4 Reference F: `server-only`

A protected module begins with:

```ts
import "server-only";
```

Example:

```ts
import "server-only";

import { database } from "@/lib/database";

export async function getPrivateProjects(userId: string) {
  return database.project.findMany({
    where: {
      ownerId: userId,
    },
  });
}
```

If a Client Component imports it, Next.js reports an error.

Use `server-only` for modules containing or depending on:

- Database clients
- Private environment variables
- Authentication internals
- Authorization logic
- Secret-bearing service SDKs
- Server filesystem access

`server-only` is a build-time architecture guard. It does not replace runtime authorization.

---

# Part 4 Reference G: State Categories

Not every changing value belongs in `useState`.

## URL state

Use URL state when a value should be shareable or preserved:

```text
/projects?status=ACTIVE
```

Examples:

- Filters
- Sorting
- Pagination
- Selected tabs that represent navigation
- Search queries users may share

## Local client state

Use local state for temporary interface behavior:

```tsx
const [isOpen, setIsOpen] = useState(false);
```

Examples:

- Open or closed disclosure
- Temporary search text
- Menu visibility
- Copy feedback
- Unsaved interface preferences

## Server state

Server state is data owned outside the browser:

- Database records
- Authenticated user information
- Inventory
- Project ownership
- Task status

Do not treat authoritative server data as permanent local state. Mutations must return to the server and then refresh or reconcile the browser view.

---

# Part 4 Reference H: Hydration

Hydration connects browser-side React behavior to server-rendered output.

A mismatch occurs when the browser’s first render differs from the server output.

Risky render-time code includes:

```tsx
const randomValue = Math.random();
const currentTime = new Date().toISOString();
const browserWidth = window.innerWidth;
```

The server and browser can produce different results.

Prefer:

- Stable props from the server
- `useId` for component IDs
- Browser API access inside event handlers
- Effects for behavior that must occur after mounting
- Explicit server-provided timestamps when time matters

Our disclosure uses:

```tsx
const contentId = useId();
```

Our copy control reads:

```tsx
window.location.href
```

only after a click.

---

# Part 4 Reference I: Hooks Used in This Part

## `useState`

Stores local component state:

```tsx
const [query, setQuery] = useState("");
```

Use the callback form when the next value depends on the current one:

```tsx
setIsOpen((currentValue) => !currentValue);
```

## `useMemo`

Caches a calculated value between renders:

```tsx
const visibleProjects = useMemo(() => {
  return projects.filter(/* condition */);
}, [projects, query]);
```

Use it when calculation cost or stable identity provides measurable value. Do not treat it as mandatory.

## `useId`

Creates a stable ID suitable for accessibility relationships:

```tsx
const contentId = useId();
```

## `usePathname`

Reads the current pathname:

```tsx
const pathname = usePathname();
```

It is useful for:

- Active navigation
- Route-sensitive client behavior
- Client-side analytics integration

It requires a Client Component.

---

# Part 4 Reference J: Security Boundaries

A Client Component is not a security boundary.

Users can:

- Inspect browser JavaScript
- Change client state
- Modify requests
- Call endpoints directly
- Edit form values
- Bypass hidden or disabled controls

This means the following is insufficient:

```tsx
{isOwner ? <DeleteButton /> : null}
```

Hiding the button improves the interface, but the server-side delete operation must still verify ownership.

Similarly, client-side filtering does not secure data:

```tsx
const visibleProjects = projects.filter(
  (project) => project.ownerId === currentUserId,
);
```

If every project was sent to the browser, the unauthorized records were already exposed.

Correct architecture:

```text
Server authenticates user
        ↓
Server authorizes query
        ↓
Server selects allowed records
        ↓
Client receives only allowed records
```

We will implement those checks in Part 8.

---

# Part 4 Reference K: Current Project Structure

After Part 4, the relevant structure is:

```text
src/
├── app/
│   ├── (marketing)/
│   │   ├── about/
│   │   │   └── page.tsx
│   │   ├── features/
│   │   │   └── page.tsx
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── (workspace)/
│   │   ├── dashboard/
│   │   │   └── page.tsx
│   │   ├── projects/
│   │   │   ├── [projectId]/
│   │   │   │   └── page.tsx
│   │   │   └── page.tsx
│   │   └── layout.tsx
│   ├── globals.css
│   ├── layout.tsx
│   └── not-found.tsx
├── components/
│   ├── copy-project-link.tsx
│   ├── interactive-disclosure.tsx
│   ├── project-list.tsx
│   ├── site-footer.tsx
│   ├── site-header.tsx
│   └── workspace-navigation.tsx
└── lib/
    ├── project-catalog.ts
    └── project-types.ts
```

The boundary graph is:

```text
Server-only project catalog
        ↓
Server pages
        ↓ serializable project data
Client project list
        ↓
Browser interaction
```

The dynamic detail page uses:

```text
Server ProjectPage
├── Client CopyProjectLink
└── Client InteractiveDisclosure
    └── Server-composed children
```

---

# Part 4 Completion Checklist

Before continuing, confirm every item:

- [ ] `project-catalog.ts` imports `server-only`.
- [ ] Shared project types live outside the protected catalog.
- [ ] Server pages can still query the catalog.
- [ ] Client Components do not import the server-only catalog.
- [ ] Workspace navigation highlights the current route.
- [ ] Nested project routes keep Projects highlighted.
- [ ] Active navigation uses `aria-current="page"`.
- [ ] Status filtering remains in the URL.
- [ ] Status values are validated on the server.
- [ ] Text searching updates immediately in the browser.
- [ ] Refreshing resets temporary text search.
- [ ] Refreshing preserves the URL status filter.
- [ ] The result count announces changes.
- [ ] Project details remain server-rendered.
- [ ] Disclosure controls work with mouse and keyboard.
- [ ] Disclosure controls expose `aria-expanded`.
- [ ] The copy-link button handles success and failure.
- [ ] Server-rendered disclosure content appears in the initial response.
- [ ] Unknown projects still return `404`.
- [ ] Route pages and layouts remain Server Components.
- [ ] `npx tsc --noEmit` succeeds.
- [ ] `npm run lint` succeeds.
- [ ] `npm run build` succeeds.
- [ ] Client interaction works under `npm run start`.
- [ ] Git contains the Part 4 checkpoint.
- [ ] `git status` reports a clean working tree.

You now understand how to preserve a server-first architecture while adding focused browser interaction, how data crosses the server/client boundary, and how server-only modules prevent unsafe imports.
