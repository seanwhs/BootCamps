# Part 2: Routing and Pages

In Part 1, we created and verified the initial LaunchPad application. It currently has one route:

```text
/
```

In this part, we will turn that single page into a small, navigable website.

By the end of Part 2, LaunchPad will include:

- File-based routes
- Shared navigation using `next/link`
- An About page
- A Features page
- A filterable project-preview page
- Dynamic project-detail routes
- Route parameters
- Search parameters
- Route-specific metadata
- A custom not-found page
- Build-time generation for known project routes

The database will not arrive until Part 5. For now, we will use a typed, in-memory project catalog. This lets us learn routing without introducing database complexity too early.

---

# Step 1: Understand the App Router’s URL Mapping

## The Target

Understand how directories and special files inside `src/app` become browser URLs before creating additional routes.

## The Concept

The App Router uses **file-based routing**. This means the directory structure is part of the application’s routing configuration.

Think of the `app` directory as a building directory:

- Each folder is a hallway segment.
- A `page.tsx` file opens that hallway to visitors.
- A dynamic folder acts like a labeled storage slot that can hold different values.
- A `layout.tsx` file provides shared surroundings for everything below it.

Our current structure is:

```text
src/app/
├── globals.css
├── layout.tsx
└── page.tsx
```

The root `page.tsx` creates this route:

```text
src/app/page.tsx → /
```

A new About page will use:

```text
src/app/about/page.tsx → /about
```

A project list will use:

```text
src/app/projects/page.tsx → /projects
```

A dynamic project page will use square brackets:

```text
src/app/projects/[projectId]/page.tsx
```

That one file can match many URLs:

```text
/projects/website-redesign
/projects/mobile-application
/projects/documentation-hub
```

The value occupying `[projectId]` becomes a route parameter available to the page.

## The Implementation

No files need to change yet.

The routing structure we will build during this part is:

```text
src/
├── app/
│   ├── about/
│   │   └── page.tsx
│   ├── features/
│   │   └── page.tsx
│   ├── projects/
│   │   ├── [projectId]/
│   │   │   └── page.tsx
│   │   └── page.tsx
│   ├── globals.css
│   ├── layout.tsx
│   ├── not-found.tsx
│   └── page.tsx
├── components/
│   └── site-header.tsx
└── lib/
    └── project-catalog.ts
```

Notice that ordinary helper modules live outside `src/app`.

That is an organizational choice, not a strict Next.js requirement. Keeping reusable components and application data outside the route tree makes their responsibilities easier to recognize:

- `src/app` contains route-related files.
- `src/components` contains reusable interface components.
- `src/lib` contains non-visual application utilities and data access.

Later, database operations and validation utilities will also live behind clear module boundaries.

## The Verification

Inspect the current route files:

```bash
find src/app -type f | sort
```

PowerShell:

```powershell
Get-ChildItem src/app -Recurse -File |
  ForEach-Object {
    $_.FullName.Replace((Get-Location).Path + '\', '')
  }
```

At this stage, only `src/app/page.tsx` exposes a page route.

Start the development server if it is not already running:

```bash
npm run dev
```

Open:

```text
http://localhost:3000/about
```

Because we have not created that route yet, Next.js should return a not-found response.

Verify the status directly:

```bash
curl --silent --output /dev/null --write-out "%{http_code}\n" \
  http://localhost:3000/about
```

Expected output:

```text
404
```

This confirms that directories do not become routes until the required route file exists.

[GENERATED: Part 2, Step 1: App Router URL Mapping] [STARTING: Part 2, Step 2: Typed Project Catalog]

---

# Step 2: Create a Typed Project Catalog

## The Target

Create a server-safe module containing temporary project data and reusable project lookup functions.

## The Concept

We need realistic data for the project routes, but adding a database now would mix two major concepts: routing and persistence.

Instead, we will create an **in-memory catalog**. In-memory data lives directly in application code rather than in a database.

Think of it as using labeled sample products while designing a store. The shelves and navigation can be built before the warehouse connection is ready.

We will keep the data in a separate module so pages do not duplicate lookup logic.

The module will also define TypeScript types. A type acts like a written contract describing the allowed shape of a value.

Our project status will allow only:

```text
PLANNED
ACTIVE
COMPLETED
```

A misspelling such as `COMPELTED` will therefore produce a type error instead of silently entering the application.

## The Implementation

Create the library directory:

```bash
mkdir -p src/lib
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force src/lib | Out-Null
```

Create the following file.

### `src/lib/project-catalog.ts`

```ts
export const PROJECT_STATUSES = [
  "PLANNED",
  "ACTIVE",
  "COMPLETED",
] as const;

/**
 * Taking the union of the array's values produces:
 *
 * "PLANNED" | "ACTIVE" | "COMPLETED"
 *
 * This ensures that every project status is one of the supported values.
 */
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
 * This catalog is temporary application data.
 *
 * In Part 5, database queries will replace these in-memory records while the
 * route and component interfaces remain largely unchanged.
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

/**
 * Return a readonly view of every project.
 *
 * Readonly data prevents callers from accidentally changing this shared
 * catalog. Database-backed operations will later use explicit mutation
 * functions instead of modifying query results.
 */
export function getAllProjects(): readonly ProjectSummary[] {
  return PROJECT_CATALOG;
}

/**
 * Find one project by the stable identifier used in its URL.
 */
export function getProjectById(
  projectId: string,
): ProjectSummary | undefined {
  return PROJECT_CATALOG.find((project) => project.id === projectId);
}

/**
 * Return every project with the requested status.
 */
export function getProjectsByStatus(
  status: ProjectStatus,
): readonly ProjectSummary[] {
  return PROJECT_CATALOG.filter((project) => project.status === status);
}

/**
 * Values from URLs are untrusted strings. This type guard checks whether a
 * string is one of our supported project statuses and narrows its type when
 * the check succeeds.
 */
export function isProjectStatus(value: string): value is ProjectStatus {
  return PROJECT_STATUSES.some((status) => status === value);
}

/**
 * Convert an internal value such as "COMPLETED" into the user-facing label
 * "Completed".
 */
export function formatProjectStatus(status: ProjectStatus): string {
  return `${status.charAt(0)}${status.slice(1).toLowerCase()}`;
}

/**
 * Calculate a whole-number completion percentage.
 *
 * A project with no tasks returns zero rather than attempting division by
 * zero, which would otherwise produce an invalid numeric result.
 */
export function calculateProjectProgress(project: ProjectSummary): number {
  if (project.taskCount === 0) {
    return 0;
  }

  return Math.round(
    (project.completedTaskCount / project.taskCount) * 100,
  );
}
```

### Why `satisfies` is useful

This expression combines two useful behaviors:

```ts
as const satisfies readonly ProjectSummary[]
```

- `as const` preserves narrow literal values such as `"ACTIVE"`.
- `satisfies` checks that every item follows the `ProjectSummary` contract.

Unlike a broad type assertion, `satisfies` validates the data without discarding its precise inferred types.

### Why URL values still need validation

A user can manually enter any query string:

```text
/projects?status=NOT_A_REAL_STATUS
```

TypeScript cannot guarantee the contents of an external URL at runtime. TypeScript checks our source code; it does not control what users send over the network.

The `isProjectStatus` function performs a runtime check and also acts as a **type guard**. A type guard is a function that proves a value has a more specific type after a successful check.

## The Verification

Run the type checker:

```bash
npx tsc --noEmit
```

Run ESLint:

```bash
npm run lint
```

Both commands should succeed.

Confirm the module contains all four projects:

```bash
grep -E 'id: "(website-redesign|mobile-application|documentation-hub|analytics-dashboard)"' \
  src/lib/project-catalog.ts
```

PowerShell:

```powershell
Select-String `
  -Path src/lib/project-catalog.ts `
  -Pattern 'id: "(website-redesign|mobile-application|documentation-hub|analytics-dashboard)"'
```

The output should identify four matching lines.

[GENERATED: Part 2, Step 2: Typed Project Catalog] [STARTING: Part 2, Step 3: Shared Navigation]

---

# Step 3: Build Navigation with `next/link`

## The Target

Create a reusable site header that links to the Home, About, Features, and Projects routes.

## The Concept

A normal HTML anchor can navigate to another page:

```html
<a href="/about">About</a>
```

However, Next.js provides a `Link` component for internal application navigation:

```tsx
<Link href="/about">About</Link>
```

`Link` renders an accessible anchor while allowing Next.js to perform **client-side transitions** between routes.

A client-side transition means Next.js can request and replace the route content without forcing the browser to discard and reload the entire document.

Think of the difference this way:

- A full document reload is like leaving a building and entering again through the front door.
- A client-side transition is like walking through an interior doorway.

Next.js may also **prefetch** linked routes when appropriate. Prefetching means preparing route data before the user clicks so navigation can feel faster.

The `Link` component does not require our header to become a Client Component. It can remain server-rendered.

## The Implementation

Create the components directory:

```bash
mkdir -p src/components
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force src/components | Out-Null
```

Create the header.

### `src/components/site-header.tsx`

```tsx
import Link from "next/link";

const navigationItems = [
  {
    href: "/",
    label: "Home",
  },
  {
    href: "/about",
    label: "About",
  },
  {
    href: "/features",
    label: "Features",
  },
  {
    href: "/projects",
    label: "Projects",
  },
] as const;

export function SiteHeader() {
  return (
    <header className="site-header">
      <div className="site-header__inner">
        <Link className="brand-link" href="/">
          LaunchPad
        </Link>

        <nav aria-label="Primary navigation">
          <ul className="navigation-list">
            {navigationItems.map((item) => (
              <li key={item.href}>
                <Link className="navigation-link" href={item.href}>
                  {item.label}
                </Link>
              </li>
            ))}
          </ul>
        </nav>
      </div>
    </header>
  );
}
```

### Why navigation uses a list

Navigation is a collection of related destinations. A list communicates that relationship to assistive technologies and gives the markup a meaningful structure:

```tsx
<nav aria-label="Primary navigation">
  <ul>
    <li>
      <Link href="/">Home</Link>
    </li>
  </ul>
</nav>
```

The `aria-label` distinguishes this navigation region from other navigation regions we may add later, such as dashboard or footer navigation.

### Add the header to the home page

Completely replace the home page.

### `src/app/page.tsx`

```tsx
import Link from "next/link";

import { SiteHeader } from "@/components/site-header";

const plannedFeatures = [
  {
    title: "Organize projects",
    description:
      "Create focused project spaces with clear descriptions, statuses, and ownership.",
  },
  {
    title: "Track meaningful work",
    description:
      "Break projects into tasks, set priorities, and follow progress from one dashboard.",
  },
  {
    title: "Work securely",
    description:
      "Protect private data with server-side authentication, authorization, and validation.",
  },
] as const;

export default function HomePage() {
  return (
    <>
      <SiteHeader />

      <main className="site-shell">
        <section className="hero" aria-labelledby="hero-heading">
          <p className="eyebrow">Built with Next.js 16</p>

          <h1 id="hero-heading">Turn ambitious ideas into organized work.</h1>

          <p className="hero-description">
            LaunchPad is a secure project and task management application.
            Over this series, this simple website will grow into a complete
            full-stack product.
          </p>

          <div className="hero-actions">
            <Link className="primary-link" href="/projects">
              Explore projects
            </Link>

            <Link className="secondary-link" href="/about">
              Learn how we are building it
            </Link>
          </div>
        </section>

        <section
          className="feature-section"
          id="planned-features"
          aria-labelledby="features-heading"
        >
          <div className="section-heading">
            <p className="eyebrow">Our destination</p>
            <h2 id="features-heading">
              Everything needed to move work forward
            </h2>
            <p>
              We will implement and verify these capabilities one layer at a
              time throughout the series.
            </p>
          </div>

          <div className="feature-grid">
            {plannedFeatures.map((feature) => (
              <article className="feature-card" key={feature.title}>
                <h3>{feature.title}</h3>
                <p>{feature.description}</p>
              </article>
            ))}
          </div>
        </section>
      </main>

      <footer className="site-footer">
        <div className="site-shell">
          <p>LaunchPad · From Zero to Production with Next.js 16</p>
        </div>
      </footer>
    </>
  );
}
```

The header is currently imported directly by the home page. Other pages will do the same temporarily.

This repetition is deliberate. In Part 3, we will move shared interface elements into nested layouts. Seeing the repetition first will make the purpose of layouts concrete rather than theoretical.

## The Verification

Run:

```bash
npx tsc --noEmit
npm run lint
```

Both commands should succeed.

Open:

```text
http://localhost:3000
```

The header should appear above the page.

The links to `/about`, `/features`, and `/projects` will still lead to not-found responses because those pages do not exist yet. That is expected.

Inspect the rendered HTML for internal links:

```bash
curl --silent http://localhost:3000 |
  grep -o 'href="/[^"]*"'
```

Expected output should include:

```text
href="/"
href="/about"
href="/features"
href="/projects"
```

Clicking **Home** should keep you on the root page.

[GENERATED: Part 2, Step 3: Shared Navigation] [STARTING: Part 2, Step 4: Static Pages]

---

# Step 4: Create Static About and Features Pages

## The Target

Create `/about` and `/features` as static routes with route-specific metadata.

## The Concept

A **static route** is a route whose rendered result does not depend on request-specific information.

Our About and Features pages contain the same information for every visitor, so Next.js can prepare them ahead of requests during the production build.

Creating each route requires a directory containing `page.tsx`:

```text
src/app/about/page.tsx
src/app/features/page.tsx
```

A page can also export a `metadata` object. The root layout’s title template will combine route-specific titles with the application name.

For example:

```tsx
export const metadata = {
  title: "About",
};
```

will produce:

```text
About | LaunchPad
```

## The Implementation

Create both route directories:

```bash
mkdir -p src/app/about src/app/features
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force src/app/about | Out-Null
New-Item -ItemType Directory -Force src/app/features | Out-Null
```

### Create the About page

### `src/app/about/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";

import { SiteHeader } from "@/components/site-header";

export const metadata: Metadata = {
  title: "About",
  description:
    "Learn how LaunchPad is being built from first principles with Next.js 16.",
};

const engineeringPrinciples = [
  {
    title: "Server first",
    description:
      "We keep rendering and sensitive operations on the server unless browser interactivity provides a clear benefit.",
  },
  {
    title: "Secure boundaries",
    description:
      "Every untrusted value is validated, and protected operations enforce both identity and permission.",
  },
  {
    title: "Measurable progress",
    description:
      "Each feature includes a specific verification step so correctness is demonstrated rather than assumed.",
  },
] as const;

export default function AboutPage() {
  return (
    <>
      <SiteHeader />

      <main className="site-shell page-content">
        <header className="page-heading">
          <p className="eyebrow">About the project</p>
          <h1>Learning production engineering by building a real product</h1>
          <p>
            LaunchPad begins as a small collection of pages and grows into a
            secure project-management application with a database,
            authentication, server-side mutations, caching, monitoring, and a
            repeatable deployment process.
          </p>
        </header>

        <section
          className="content-section"
          aria-labelledby="principles-heading"
        >
          <div className="section-heading">
            <p className="eyebrow">Engineering principles</p>
            <h2 id="principles-heading">How we will make decisions</h2>
          </div>

          <div className="feature-grid">
            {engineeringPrinciples.map((principle) => (
              <article className="feature-card" key={principle.title}>
                <h3>{principle.title}</h3>
                <p>{principle.description}</p>
              </article>
            ))}
          </div>
        </section>

        <aside className="callout" aria-labelledby="next-stop-heading">
          <div>
            <p className="eyebrow">Next stop</p>
            <h2 id="next-stop-heading">See the planned capabilities</h2>
            <p>
              The feature map shows how the application will evolve across
              the remainder of the series.
            </p>
          </div>

          <Link className="primary-link" href="/features">
            View features
          </Link>
        </aside>
      </main>

      <footer className="site-footer">
        <div className="site-shell">
          <p>LaunchPad · Built one verified layer at a time</p>
        </div>
      </footer>
    </>
  );
}
```

### Create the Features page

### `src/app/features/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";

import { SiteHeader } from "@/components/site-header";

export const metadata: Metadata = {
  title: "Features",
  description:
    "Explore the product and engineering capabilities planned for LaunchPad.",
};

const featureGroups = [
  {
    title: "Project planning",
    items: [
      "Create and update projects",
      "Track project status",
      "Organize tasks by priority",
      "Measure completion progress",
    ],
  },
  {
    title: "Secure accounts",
    items: [
      "Register and sign in",
      "Protect private routes",
      "Enforce record ownership",
      "Manage secure sessions",
    ],
  },
  {
    title: "Production foundations",
    items: [
      "Validate server configuration",
      "Cache data intentionally",
      "Monitor application health",
      "Deploy repeatable builds",
    ],
  },
] as const;

export default function FeaturesPage() {
  return (
    <>
      <SiteHeader />

      <main className="site-shell page-content">
        <header className="page-heading">
          <p className="eyebrow">Feature map</p>
          <h1>A small interface backed by serious engineering</h1>
          <p>
            LaunchPad will combine an approachable project-management
            experience with the security, performance, and operational
            practices expected from a production application.
          </p>
        </header>

        <section
          className="feature-group-grid"
          aria-label="LaunchPad feature groups"
        >
          {featureGroups.map((group) => (
            <article className="feature-group" key={group.title}>
              <h2>{group.title}</h2>

              <ul className="check-list">
                {group.items.map((item) => (
                  <li key={item}>{item}</li>
                ))}
              </ul>
            </article>
          ))}
        </section>

        <aside className="callout" aria-labelledby="preview-heading">
          <div>
            <p className="eyebrow">Live preview</p>
            <h2 id="preview-heading">Explore the temporary project catalog</h2>
            <p>
              Our next route uses typed sample data to demonstrate list,
              filter, and detail navigation.
            </p>
          </div>

          <Link className="primary-link" href="/projects">
            Browse projects
          </Link>
        </aside>
      </main>

      <footer className="site-footer">
        <div className="site-shell">
          <p>LaunchPad · Product capabilities and production foundations</p>
        </div>
      </footer>
    </>
  );
}
```

## The Verification

Run:

```bash
npx tsc --noEmit
npm run lint
```

Visit both routes:

```text
http://localhost:3000/about
http://localhost:3000/features
```

Confirm that both pages render and that navigation between them works.

Verify the HTTP statuses:

```bash
curl --silent --output /dev/null --write-out "About: %{http_code}\n" \
  http://localhost:3000/about

curl --silent --output /dev/null --write-out "Features: %{http_code}\n" \
  http://localhost:3000/features
```

Expected output:

```text
About: 200
Features: 200
```

Verify the generated titles:

```bash
curl --silent http://localhost:3000/about |
  grep -o "<title>[^<]*</title>"

curl --silent http://localhost:3000/features |
  grep -o "<title>[^<]*</title>"
```

Expected output:

```html
<title>About | LaunchPad</title>
<title>Features | LaunchPad</title>
```

The root metadata template is supplying `| LaunchPad`; the page exports only the route-specific portion.

[GENERATED: Part 2, Step 4: Static About and Features Pages] [STARTING: Part 2, Step 5: Search Parameters and Project List]

---

# Step 5: Build a Filterable Project List with Search Parameters

## The Target

Create `/projects` and allow users to filter the temporary project catalog through the URL.

Supported URLs will include:

```text
/projects
/projects?status=ACTIVE
/projects?status=PLANNED
/projects?status=COMPLETED
```

## The Concept

A URL can contain a **query string** after a question mark:

```text
/projects?status=ACTIVE
```

The `status` portion is a **search parameter**.

Search parameters are useful for interface state that should be:

- Bookmarkable
- Shareable
- Preserved during refresh
- Compatible with browser history
- Visible to the server during rendering

Think of a URL as a written delivery address. The path identifies the building, while the search parameters include additional instructions.

In Next.js 16, the App Router provides `searchParams` to pages as a promise. We will await that promise inside an async Server Component.

Search parameters come from an external request and must be validated. We will not cast an arbitrary string to `ProjectStatus`.

## The Implementation

Create the projects route:

```bash
mkdir -p src/app/projects
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force src/app/projects | Out-Null
```

Create the page.

### `src/app/projects/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";

import { SiteHeader } from "@/components/site-header";
import {
  calculateProjectProgress,
  formatProjectStatus,
  getAllProjects,
  getProjectsByStatus,
  isProjectStatus,
  PROJECT_STATUSES,
  type ProjectStatus,
} from "@/lib/project-catalog";

export const metadata: Metadata = {
  title: "Projects",
  description:
    "Browse and filter the temporary LaunchPad project catalog.",
};

type ProjectsPageProps = {
  searchParams: Promise<{
    status?: string | string[];
  }>;
};

/**
 * Search parameters can technically appear more than once:
 *
 * /projects?status=ACTIVE&status=PLANNED
 *
 * Next.js represents that form as an array. LaunchPad accepts one status, so
 * duplicate status values are treated as invalid rather than choosing one
 * silently.
 */
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

  const projects = selectedStatus
    ? getProjectsByStatus(selectedStatus)
    : getAllProjects();

  return (
    <>
      <SiteHeader />

      <main className="site-shell page-content">
        <header className="page-heading">
          <p className="eyebrow">Project preview</p>
          <h1>Explore the work already on the LaunchPad</h1>
          <p>
            These records currently live in a typed in-memory catalog. In Part
            5, the same routes will read real records from a relational
            database.
          </p>
        </header>

        <section
          className="filter-panel"
          aria-labelledby="filter-heading"
        >
          <div>
            <h2 id="filter-heading">Filter projects</h2>
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

        <section aria-labelledby="project-results-heading">
          <div className="results-heading">
            <div>
              <p className="eyebrow">Results</p>
              <h2 id="project-results-heading">
                {selectedStatus
                  ? `${formatProjectStatus(selectedStatus)} projects`
                  : "All projects"}
              </h2>
            </div>

            <p>
              {projects.length}{" "}
              {projects.length === 1 ? "project" : "projects"}
            </p>
          </div>

          {projects.length > 0 ? (
            <div className="project-grid">
              {projects.map((project) => {
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
                        {project.completedTaskCount} of {project.taskCount}{" "}
                        tasks completed
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
              <h3>No projects matched this filter</h3>
              <p>Choose another status to see available projects.</p>
              <Link className="secondary-link" href="/projects">
                Clear filter
              </Link>
            </div>
          )}
        </section>
      </main>

      <footer className="site-footer">
        <div className="site-shell">
          <p>LaunchPad · Temporary project catalog</p>
        </div>
      </footer>
    </>
  );
}
```

### Why the component is async

The page receives `searchParams` as a promise:

```tsx
type ProjectsPageProps = {
  searchParams: Promise<{
    status?: string | string[];
  }>;
};
```

We resolve it with:

```tsx
const query = await searchParams;
```

Using the asynchronous API is important in Next.js 16. It also prepares us for later pages that await database and authentication operations.

### Why the form uses `GET`

The filter does not change server data. It only requests another representation of the project list.

HTTP `GET` is appropriate for read-only navigation:

```tsx
<form action="/projects" method="get">
```

Submitting the form produces a URL similar to:

```text
/projects?status=ACTIVE
```

This works even before adding client-side JavaScript. It is an example of **progressive enhancement**: standard browser behavior provides the core function.

### Why `defaultValue` is used

The server determines the selected status from the URL and renders it as the select element’s initial value:

```tsx
defaultValue={selectedStatus ?? ""}
```

This form is not managed with React client state, so `defaultValue` is the appropriate property.

## The Verification

Run:

```bash
npx tsc --noEmit
npm run lint
```

Open:

```text
http://localhost:3000/projects
```

Confirm that four project cards appear.

Now choose **Active** and submit the filter. The URL should become:

```text
http://localhost:3000/projects?status=ACTIVE
```

Only these projects should remain:

- Website redesign
- Analytics dashboard

Verify from the terminal:

```bash
curl --silent "http://localhost:3000/projects?status=ACTIVE" |
  grep -o "Website redesign\|Analytics dashboard\|Mobile application"
```

Expected matches:

```text
Website redesign
Analytics dashboard
```

`Mobile application` should not appear.

Test a lowercase valid value:

```text
http://localhost:3000/projects?status=completed
```

The page should normalize it and display the completed project.

Test an invalid status:

```text
http://localhost:3000/projects?status=UNKNOWN
```

The page should:

- Display the warning notice
- Show all projects
- Avoid crashing

Verify that response:

```bash
curl --silent "http://localhost:3000/projects?status=UNKNOWN" |
  grep "The requested status is not supported"
```

Expected output contains:

```text
The requested status is not supported
```

[GENERATED: Part 2, Step 5: Search Parameters and Project List] [STARTING: Part 2, Step 6: Dynamic Project Routes]

---

# Step 6: Build Dynamic Project Detail Routes

## The Target

Create a dynamic route that displays one project based on the `projectId` URL segment.

The route will support:

```text
/projects/website-redesign
/projects/mobile-application
/projects/documentation-hub
/projects/analytics-dashboard
```

## The Concept

A **dynamic segment** is a route segment whose value is not fixed in the source directory name.

We create one using square brackets:

```text
[projectId]
```

The route:

```text
src/app/projects/[projectId]/page.tsx
```

matches URLs such as:

```text
/projects/website-redesign
/projects/anything-else
```

Next.js provides the dynamic value through `params`.

In Next.js 16, `params` is asynchronous and must be awaited:

```tsx
const { projectId } = await params;
```

A dynamic route is like a reusable address label. The building layout remains the same, but the identifier tells the application which record belongs inside it.

## The Implementation

Create the dynamic route directory.

The square brackets should be quoted in shell commands so the shell treats them as literal characters:

```bash
mkdir -p 'src/app/projects/[projectId]'
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force 'src/app/projects/[projectId]' |
  Out-Null
```

Create the page.

### `src/app/projects/[projectId]/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";

import { SiteHeader } from "@/components/site-header";
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

/**
 * Tell Next.js which known project paths can be prepared during the
 * production build. New database-backed records will later use a different
 * rendering and caching strategy.
 */
export function generateStaticParams() {
  return getAllProjects().map((project) => ({
    projectId: project.id,
  }));
}

/**
 * Generate metadata from the selected project.
 *
 * Metadata generation receives the same dynamic route parameters as the
 * page. Returning a safe fallback avoids placing an untrusted URL value into
 * the document title when no matching project exists.
 */
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

  /**
   * notFound() stops rendering this page and asks the closest not-found
   * boundary to render instead. It has a TypeScript return type of never, so
   * TypeScript knows that project is defined after this condition.
   */
  if (!project) {
    notFound();
  }

  const progress = calculateProjectProgress(project);
  const remainingTaskCount =
    project.taskCount - project.completedTaskCount;

  return (
    <>
      <SiteHeader />

      <main className="site-shell page-content">
        <nav className="breadcrumb" aria-label="Breadcrumb">
          <ol>
            <li>
              <Link href="/">Home</Link>
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

          <aside className="notice" aria-labelledby="temporary-data-heading">
            <h2 id="temporary-data-heading">Temporary project data</h2>
            <p>
              This page currently reads from an in-memory TypeScript module.
              Database-backed project and task records will replace it in Part
              5.
            </p>
          </aside>
        </article>

        <Link className="secondary-link" href="/projects">
          <span aria-hidden="true">← </span>
          Return to all projects
        </Link>
      </main>

      <footer className="site-footer">
        <div className="site-shell">
          <p>LaunchPad · {project.name}</p>
        </div>
      </footer>
    </>
  );
}
```

### Why `notFound()` is better than returning an error paragraph

We could return:

```tsx
<p>Project not found.</p>
```

However, the response might still be treated as a successful page.

Calling:

```tsx
notFound();
```

allows Next.js to:

- Stop rendering the current page
- Render the nearest not-found interface
- Return not-found semantics
- Avoid presenting a missing resource as a normal successful route

### Why route parameters are untrusted

The directory name says the parameter is called `projectId`, but it does not restrict its value.

A visitor may request:

```text
/projects/not-real
/projects/%20
/projects/anything-they-want
```

We therefore look up the identifier and handle the missing result.

## The Verification

Run:

```bash
npx tsc --noEmit
npm run lint
```

Open:

```text
http://localhost:3000/projects/website-redesign
```

Confirm that the page displays:

- Website redesign
- Active status
- 12 total tasks
- 5 completed tasks
- 7 remaining tasks
- 42% progress

The percentage is rounded from:

```text
5 ÷ 12 × 100 = 41.666...
```

Verify the page title:

```bash
curl --silent http://localhost:3000/projects/website-redesign |
  grep -o "<title>[^<]*</title>"
```

Expected output:

```html
<title>Website redesign | LaunchPad</title>
```

Verify a second project:

```bash
curl --silent http://localhost:3000/projects/documentation-hub |
  grep "Documentation hub"
```

The output should contain the project name.

Do not test an invalid project yet. We will first create a custom not-found interface.

[GENERATED: Part 2, Step 6: Dynamic Project Routes] [STARTING: Part 2, Step 7: Not-Found Handling]

---

# Step 7: Create a Custom Not-Found Page

## The Target

Create an application-wide not-found interface and verify it for both unknown routes and missing dynamic projects.

## The Concept

A not-found interface handles requests for resources that do not exist.

There are two common ways to reach it:

1. The URL does not match any route:

   ```text
   /this-route-does-not-exist
   ```

2. A dynamic route matches structurally, but its requested resource does not exist:

   ```text
   /projects/not-a-real-project
   ```

The first case is discovered by routing. The second is discovered by our project lookup and signaled with `notFound()`.

Think of a hotel:

- An unknown route asks for a floor that the hotel does not have.
- A missing dynamic resource reaches the correct floor but asks for a room that does not exist.

Both need a useful response that helps the visitor recover.

## The Implementation

Create the root not-found file.

### `src/app/not-found.tsx`

```tsx
import Link from "next/link";

import { SiteHeader } from "@/components/site-header";

export default function NotFoundPage() {
  return (
    <>
      <SiteHeader />

      <main className="site-shell not-found-page">
        <div className="not-found-content">
          <p className="error-code" aria-hidden="true">
            404
          </p>

          <p className="eyebrow">Page not found</p>

          <h1>We could not find that destination.</h1>

          <p>
            The address may be incorrect, or the requested resource may no
            longer exist. Use one of the links below to continue.
          </p>

          <div className="hero-actions">
            <Link className="primary-link" href="/">
              Return home
            </Link>

            <Link className="secondary-link" href="/projects">
              Browse projects
            </Link>
          </div>
        </div>
      </main>

      <footer className="site-footer">
        <div className="site-shell">
          <p>LaunchPad · Let us help you find the right route</p>
        </div>
      </footer>
    </>
  );
}
```

The page contains recovery actions rather than leaving the user at a dead end.

## The Verification

Open an unknown route:

```text
http://localhost:3000/does-not-exist
```

The custom not-found page should appear.

Check its status:

```bash
curl --silent --output /dev/null --write-out "%{http_code}\n" \
  http://localhost:3000/does-not-exist
```

Expected output:

```text
404
```

Now test a missing dynamic project:

```text
http://localhost:3000/projects/not-a-real-project
```

It should display the same not-found interface.

Verify the status:

```bash
curl --silent --output /dev/null --write-out "%{http_code}\n" \
  http://localhost:3000/projects/not-a-real-project
```

Expected output:

```text
404
```

Verify the recovery text:

```bash
curl --silent http://localhost:3000/projects/not-a-real-project |
  grep "We could not find that destination"
```

Expected output contains:

```text
We could not find that destination
```

[GENERATED: Part 2, Step 7: Not-Found Handling] [STARTING: Part 2, Step 8: Routing Styles]

---

# Step 8: Add the Complete Routing Interface Styles

## The Target

Update the global stylesheet so every route built in this part has a responsive, accessible interface.

## The Concept

The new pages introduce interface patterns that did not exist in Part 1:

- Site navigation
- Page headings
- Filter forms
- Status badges
- Project cards
- Progress indicators
- Breadcrumbs
- Statistical summaries
- Notices
- Not-found content

These are visual patterns, but they also carry meaning.

For example:

- A focus style shows keyboard users where they are.
- A status badge needs readable text instead of relying only on color.
- A form label tells users what a select control changes.
- A progress element provides machine-readable completion information.
- Responsive rules prevent navigation and card grids from breaking on narrow screens.

We will replace the stylesheet completely so the result is deterministic and copy-pasteable.

## The Implementation

Completely replace the global stylesheet.

### `src/app/globals.css`

```css
:root {
  --color-background: #f6f8fc;
  --color-surface: #ffffff;
  --color-surface-subtle: #eef2f8;
  --color-text: #172033;
  --color-text-muted: #59657a;
  --color-border: #dce2ec;
  --color-primary: #3457d5;
  --color-primary-hover: #2946ad;
  --color-primary-soft: #e9edff;
  --color-focus: #ffbf47;
  --color-success: #176b45;
  --color-success-soft: #def7e9;
  --color-warning: #8a5300;
  --color-warning-soft: #fff1cf;
  --color-planned: #5e4bb6;
  --color-planned-soft: #eeeaff;
  --shadow-card: 0 1rem 2.5rem rgb(23 32 51 / 8%);
  --content-width: 72rem;
}

*,
*::before,
*::after {
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
}

body {
  min-height: 100vh;
  margin: 0;
  background:
    radial-gradient(
      circle at top left,
      rgb(52 87 213 / 10%),
      transparent 32rem
    ),
    var(--color-background);
  color: var(--color-text);
  font-family:
    Arial,
    Helvetica,
    sans-serif;
  line-height: 1.6;
  text-rendering: optimizeLegibility;
}

a {
  color: inherit;
}

button,
input,
select,
textarea {
  font: inherit;
}

a:focus-visible,
button:focus-visible,
input:focus-visible,
select:focus-visible,
textarea:focus-visible {
  outline: 0.2rem solid var(--color-focus);
  outline-offset: 0.2rem;
}

.site-shell {
  width: min(100% - 2rem, var(--content-width));
  margin-inline: auto;
}

.site-header {
  position: sticky;
  z-index: 10;
  top: 0;
  border-bottom: 0.0625rem solid rgb(220 226 236 / 85%);
  background: rgb(246 248 252 / 92%);
  backdrop-filter: blur(1rem);
}

.site-header__inner {
  display: flex;
  width: min(100% - 2rem, var(--content-width));
  min-height: 4.5rem;
  margin-inline: auto;
  align-items: center;
  justify-content: space-between;
  gap: 2rem;
}

.brand-link {
  color: var(--color-text);
  font-size: 1.25rem;
  font-weight: 800;
  letter-spacing: -0.03em;
  text-decoration: none;
}

.brand-link:hover {
  color: var(--color-primary);
}

.navigation-list {
  display: flex;
  margin: 0;
  padding: 0;
  align-items: center;
  gap: 0.25rem;
  list-style: none;
}

.navigation-link {
  display: inline-flex;
  min-height: 2.5rem;
  padding-inline: 0.8rem;
  align-items: center;
  border-radius: 0.5rem;
  color: var(--color-text-muted);
  font-size: 0.95rem;
  font-weight: 700;
  text-decoration: none;
}

.navigation-link:hover {
  background: var(--color-primary-soft);
  color: var(--color-primary);
}

.hero {
  display: grid;
  min-height: calc(70vh - 4.5rem);
  padding-block: 5rem;
  align-content: center;
  justify-items: start;
}

.eyebrow {
  margin: 0 0 0.75rem;
  color: var(--color-primary);
  font-size: 0.875rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.hero h1,
.page-heading h1,
.project-detail-heading h1,
.not-found-content h1 {
  margin: 0;
  line-height: 1;
  letter-spacing: -0.05em;
}

.hero h1 {
  max-width: 15ch;
  font-size: clamp(2.75rem, 8vw, 5.75rem);
}

.hero-description {
  max-width: 42rem;
  margin: 1.5rem 0 0;
  color: var(--color-text-muted);
  font-size: clamp(1.05rem, 2vw, 1.25rem);
}

.hero-actions {
  display: flex;
  margin-top: 2rem;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.75rem;
}

.primary-link,
.secondary-link,
.primary-button {
  display: inline-flex;
  min-height: 2.75rem;
  padding: 0.65rem 1.1rem;
  border-radius: 0.65rem;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  line-height: 1.2;
  text-decoration: none;
  cursor: pointer;
  transition:
    background-color 160ms ease,
    border-color 160ms ease,
    color 160ms ease,
    transform 160ms ease;
}

.primary-link,
.primary-button {
  border: 0.0625rem solid var(--color-primary);
  background: var(--color-primary);
  color: #ffffff;
}

.primary-link:hover,
.primary-button:hover {
  border-color: var(--color-primary-hover);
  background: var(--color-primary-hover);
  transform: translateY(-0.125rem);
}

.secondary-link {
  border: 0.0625rem solid var(--color-border);
  background: var(--color-surface);
  color: var(--color-primary);
}

.secondary-link:hover {
  border-color: var(--color-primary);
  background: var(--color-primary-soft);
  transform: translateY(-0.125rem);
}

.text-link {
  color: var(--color-primary);
  font-weight: 700;
  text-underline-offset: 0.2rem;
}

.text-link:hover {
  color: var(--color-primary-hover);
}

.feature-section,
.content-section {
  padding-block: 5rem;
  border-top: 0.0625rem solid var(--color-border);
}

.section-heading {
  max-width: 45rem;
}

.section-heading h2 {
  margin: 0;
  font-size: clamp(2rem, 5vw, 3.25rem);
  line-height: 1.1;
  letter-spacing: -0.035em;
}

.section-heading > p:last-child {
  margin: 1rem 0 0;
  color: var(--color-text-muted);
  font-size: 1.05rem;
}

.feature-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 1.25rem;
  margin-top: 2.5rem;
}

.feature-card,
.feature-group,
.project-card,
.stat-card {
  border: 0.0625rem solid var(--color-border);
  background: var(--color-surface);
  box-shadow: var(--shadow-card);
}

.feature-card {
  padding: 1.5rem;
  border-radius: 1rem;
}

.feature-card h3 {
  margin: 0;
  font-size: 1.2rem;
}

.feature-card p {
  margin: 0.75rem 0 0;
  color: var(--color-text-muted);
}

.site-footer {
  margin-top: 4rem;
  padding-block: 2rem;
  border-top: 0.0625rem solid var(--color-border);
  color: var(--color-text-muted);
  font-size: 0.9rem;
}

.site-footer p {
  margin: 0;
}

.page-content {
  padding-block: 5rem;
}

.page-heading {
  max-width: 52rem;
  margin-bottom: 4rem;
}

.page-heading h1 {
  font-size: clamp(2.5rem, 7vw, 4.75rem);
}

.page-heading > p:last-child {
  max-width: 45rem;
  margin: 1.5rem 0 0;
  color: var(--color-text-muted);
  font-size: 1.15rem;
}

.callout {
  display: flex;
  margin-top: 4rem;
  padding: 2rem;
  border: 0.0625rem solid var(--color-border);
  border-radius: 1rem;
  background: var(--color-primary-soft);
  align-items: center;
  justify-content: space-between;
  gap: 2rem;
}

.callout h2 {
  margin: 0;
  line-height: 1.2;
}

.callout p:last-child {
  max-width: 42rem;
  margin: 0.75rem 0 0;
  color: var(--color-text-muted);
}

.callout .primary-link {
  flex: 0 0 auto;
}

.feature-group-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 1.25rem;
}

.feature-group {
  padding: 1.5rem;
  border-radius: 1rem;
}

.feature-group h2 {
  margin: 0;
  font-size: 1.3rem;
}

.check-list {
  display: grid;
  margin: 1.25rem 0 0;
  padding: 0;
  gap: 0.75rem;
  list-style: none;
}

.check-list li {
  position: relative;
  padding-left: 1.75rem;
  color: var(--color-text-muted);
}

.check-list li::before {
  position: absolute;
  top: 0;
  left: 0;
  color: var(--color-success);
  content: "✓";
  font-weight: 800;
}

.filter-panel {
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

.filter-panel h2 {
  margin: 0;
  font-size: 1.25rem;
}

.filter-panel p {
  margin: 0.5rem 0 0;
  color: var(--color-text-muted);
}

.filter-form {
  display: grid;
  gap: 0.5rem;
}

.filter-form label {
  font-weight: 700;
}

.filter-controls {
  display: flex;
  gap: 0.75rem;
}

.filter-controls select {
  min-width: 0;
  min-height: 2.75rem;
  flex: 1;
  border: 0.0625rem solid var(--color-border);
  border-radius: 0.65rem;
  background: var(--color-surface);
  color: var(--color-text);
  padding-inline: 0.75rem;
}

.primary-button {
  flex: 0 0 auto;
}

.notice {
  margin-block: 2rem;
  padding: 1.25rem;
  border: 0.0625rem solid var(--color-border);
  border-left: 0.3rem solid var(--color-primary);
  border-radius: 0.75rem;
  background: var(--color-primary-soft);
}

.notice h2 {
  margin: 0;
  font-size: 1.15rem;
}

.notice p {
  margin: 0.5rem 0 0;
  color: var(--color-text-muted);
}

.notice > p:only-child {
  margin: 0;
}

.notice--warning {
  border-color: #efd69c;
  border-left-color: var(--color-warning);
  background: var(--color-warning-soft);
  color: var(--color-warning);
}

.notice--warning p {
  color: inherit;
}

.results-heading {
  display: flex;
  margin-bottom: 1.5rem;
  align-items: end;
  justify-content: space-between;
  gap: 1rem;
}

.results-heading h2 {
  margin: 0;
  font-size: clamp(1.75rem, 4vw, 2.5rem);
  line-height: 1.1;
}

.results-heading > p {
  margin: 0;
  color: var(--color-text-muted);
  white-space: nowrap;
}

.project-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1.25rem;
}

.project-card {
  display: flex;
  padding: 1.5rem;
  border-radius: 1rem;
  flex-direction: column;
}

.project-card__heading {
  display: flex;
  align-items: start;
  justify-content: space-between;
  gap: 1rem;
}

.project-card h3 {
  margin: 0;
  font-size: 1.3rem;
  line-height: 1.25;
}

.project-card h3 a {
  text-decoration: none;
}

.project-card h3 a:hover {
  color: var(--color-primary);
  text-decoration: underline;
  text-underline-offset: 0.2rem;
}

.project-card > p {
  margin: 1rem 0;
  color: var(--color-text-muted);
}

.project-card .text-link {
  margin-top: auto;
  padding-top: 1.25rem;
}

.status-badge {
  display: inline-flex;
  min-height: 1.75rem;
  padding: 0.2rem 0.6rem;
  border-radius: 999rem;
  align-items: center;
  flex: 0 0 auto;
  font-size: 0.75rem;
  font-weight: 800;
  letter-spacing: 0.04em;
  line-height: 1;
  text-transform: uppercase;
}

.status-badge--active {
  background: var(--color-primary-soft);
  color: var(--color-primary-hover);
}

.status-badge--planned {
  background: var(--color-planned-soft);
  color: var(--color-planned);
}

.status-badge--completed {
  background: var(--color-success-soft);
  color: var(--color-success);
}

.progress-summary {
  padding-top: 1rem;
  border-top: 0.0625rem solid var(--color-border);
}

.progress-summary__labels {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  font-weight: 700;
}

.progress-summary__labels h2 {
  margin: 0;
  font-size: 1.25rem;
}

.progress-summary progress,
.detail-progress progress {
  display: block;
  width: 100%;
  height: 0.75rem;
  margin-top: 0.65rem;
  overflow: hidden;
  border: 0;
  border-radius: 999rem;
  background: var(--color-surface-subtle);
}

progress::-webkit-progress-bar {
  border-radius: 999rem;
  background: var(--color-surface-subtle);
}

progress::-webkit-progress-value {
  border-radius: 999rem;
  background: var(--color-primary);
}

progress::-moz-progress-bar {
  border-radius: 999rem;
  background: var(--color-primary);
}

.progress-summary p,
.detail-progress p {
  margin: 0.5rem 0 0;
  color: var(--color-text-muted);
  font-size: 0.9rem;
}

.empty-state {
  padding: 3rem 1.5rem;
  border: 0.0625rem dashed var(--color-border);
  border-radius: 1rem;
  background: var(--color-surface);
  text-align: center;
}

.empty-state h3 {
  margin: 0;
  font-size: 1.35rem;
}

.empty-state p {
  margin: 0.5rem 0 1.5rem;
  color: var(--color-text-muted);
}

.breadcrumb {
  margin-bottom: 2rem;
  color: var(--color-text-muted);
  font-size: 0.9rem;
}

.breadcrumb ol {
  display: flex;
  margin: 0;
  padding: 0;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.5rem;
  list-style: none;
}

.breadcrumb a {
  color: var(--color-primary);
  text-underline-offset: 0.2rem;
}

.breadcrumb [aria-current="page"] {
  color: var(--color-text);
  font-weight: 700;
}

.project-detail-heading {
  display: flex;
  padding-bottom: 2rem;
  border-bottom: 0.0625rem solid var(--color-border);
  align-items: start;
  justify-content: space-between;
  gap: 2rem;
}

.project-detail-heading > div {
  max-width: 48rem;
}

.project-detail-heading h1 {
  font-size: clamp(2.5rem, 7vw, 4.75rem);
}

.project-detail-heading > div > p:last-child {
  margin: 1.25rem 0 0;
  color: var(--color-text-muted);
  font-size: 1.1rem;
}

.project-stat-grid {
  display: grid;
  margin-block: 2rem;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 1rem;
}

.stat-card {
  display: grid;
  min-height: 8rem;
  padding: 1.25rem;
  border-radius: 0.85rem;
  align-content: space-between;
}

.stat-card__label {
  color: var(--color-text-muted);
  font-size: 0.9rem;
  font-weight: 700;
}

.stat-card strong {
  font-size: 2rem;
  line-height: 1;
}

.detail-progress {
  padding: 1.5rem;
  border: 0.0625rem solid var(--color-border);
  border-radius: 1rem;
  background: var(--color-surface);
}

.not-found-page {
  display: grid;
  min-height: calc(100vh - 14rem);
  padding-block: 5rem;
  place-items: center;
  text-align: center;
}

.not-found-content {
  max-width: 44rem;
}

.error-code {
  margin: 0;
  color: var(--color-primary-soft);
  font-size: clamp(7rem, 25vw, 15rem);
  font-weight: 900;
  letter-spacing: -0.08em;
  line-height: 0.75;
  user-select: none;
}

.not-found-content .eyebrow {
  margin-top: 2rem;
}

.not-found-content h1 {
  font-size: clamp(2.25rem, 6vw, 4rem);
}

.not-found-content > p:not(.error-code, .eyebrow) {
  margin: 1.25rem auto 0;
  color: var(--color-text-muted);
  font-size: 1.1rem;
}

.not-found-content .hero-actions {
  justify-content: center;
}

@media (max-width: 56rem) {
  .feature-grid,
  .feature-group-grid {
    grid-template-columns: 1fr;
  }

  .project-grid {
    grid-template-columns: 1fr;
  }

  .filter-panel {
    grid-template-columns: 1fr;
    align-items: stretch;
  }

  .project-stat-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 42rem) {
  .site-header {
    position: static;
  }

  .site-header__inner {
    padding-block: 1rem;
    align-items: flex-start;
    flex-direction: column;
    gap: 0.75rem;
  }

  .navigation-list {
    width: 100%;
    overflow-x: auto;
    padding-bottom: 0.25rem;
  }

  .navigation-link {
    padding-inline: 0.65rem;
    white-space: nowrap;
  }

  .hero {
    min-height: auto;
    padding-block: 4rem;
  }

  .page-content {
    padding-block: 3.5rem;
  }

  .page-heading {
    margin-bottom: 3rem;
  }

  .callout,
  .project-detail-heading,
  .results-heading {
    align-items: stretch;
    flex-direction: column;
  }

  .callout .primary-link {
    align-self: flex-start;
  }

  .filter-controls {
    align-items: stretch;
    flex-direction: column;
  }

  .project-card__heading {
    flex-direction: column;
  }

  .project-stat-grid {
    grid-template-columns: 1fr;
  }
}

@media (prefers-reduced-motion: reduce) {
  html {
    scroll-behavior: auto;
  }

  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

## The Verification

Save the stylesheet and inspect every route:

```text
http://localhost:3000
http://localhost:3000/about
http://localhost:3000/features
http://localhost:3000/projects
http://localhost:3000/projects?status=ACTIVE
http://localhost:3000/projects/website-redesign
http://localhost:3000/does-not-exist
```

Verify the following visual behavior:

- The header remains visible while scrolling on a wide screen.
- Navigation links have visible hover and keyboard-focus states.
- About-page cards form three columns on wide screens and one column on narrower screens.
- Project cards form two columns on wide screens and one column on narrower screens.
- Status badges use both text and color.
- Project progress bars display the correct percentage.
- The project-detail statistics collapse responsively.
- The not-found page provides two clear recovery links.
- Horizontal navigation remains usable on narrow screens.

Run the automated checks:

```bash
npx tsc --noEmit
npm run lint
```

Both commands should complete successfully.

[GENERATED: Part 2, Step 8: Routing Interface Styles] [STARTING: Part 2, Step 9: Route and Navigation Verification]

---

# Step 9: Verify Routes, Parameters, and Navigation

## The Target

Perform a systematic routing test covering successful pages, filtered URLs, dynamic parameters, metadata, and missing resources.

## The Concept

Testing only by clicking through a website can miss important behavior.

A route has several independently testable properties:

- Does it return the correct HTTP status?
- Does it display the expected content?
- Does it produce the expected metadata?
- Does a dynamic parameter select the correct record?
- Does invalid external input fail safely?
- Do internal links point to valid destinations?

This is similar to inspecting a bridge from several angles. A bridge may look correct from the road while still having structural problems underneath.

For now, we will use a shell script built from `curl`. Later parts can introduce more formal automated tests when the application’s behavior is sufficiently stable.

## The Implementation

Make sure the development server is running:

```bash
npm run dev
```

Open a second terminal in the project root.

### Verify successful status codes

Run:

```bash
for path in \
  "/" \
  "/about" \
  "/features" \
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

  printf "%-40s %s\n" "${path}" "${status_code}"
done
```

Expected output:

```text
/                                        200
/about                                   200
/features                                200
/projects                                200
/projects?status=ACTIVE                  200
/projects/website-redesign              200
```

### PowerShell equivalent

```powershell
$paths = @(
  "/",
  "/about",
  "/features",
  "/projects",
  "/projects?status=ACTIVE",
  "/projects/website-redesign"
)

foreach ($path in $paths) {
  try {
    $response = Invoke-WebRequest `
      -Uri "http://localhost:3000$path" `
      -UseBasicParsing

    "{0,-40} {1}" -f $path, $response.StatusCode
  }
  catch {
    "{0,-40} ERROR" -f $path
  }
}
```

### Verify missing-resource statuses

Run:

```bash
for path in \
  "/not-a-route" \
  "/projects/not-a-real-project"
do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000${path}"
  )"

  printf "%-40s %s\n" "${path}" "${status_code}"
done
```

Expected output:

```text
/not-a-route                             404
/projects/not-a-real-project             404
```

### Verify route content

Run:

```bash
curl --fail --silent http://localhost:3000/about |
  grep --quiet "Learning production engineering"

curl --fail --silent http://localhost:3000/features |
  grep --quiet "A small interface backed by serious engineering"

curl --fail --silent http://localhost:3000/projects |
  grep --quiet "Explore the work already on the LaunchPad"

curl --fail --silent \
  http://localhost:3000/projects/mobile-application |
  grep --quiet "Mobile application"

echo "All expected route content was found."
```

Expected output:

```text
All expected route content was found.
```

If any `grep --quiet` command fails, the shell will continue unless strict mode is enabled. To make the verification fail immediately, run it as a strict script:

```bash
bash -c '
  set -euo pipefail

  curl --fail --silent http://localhost:3000/about |
    grep --quiet "Learning production engineering"

  curl --fail --silent http://localhost:3000/features |
    grep --quiet "A small interface backed by serious engineering"

  curl --fail --silent http://localhost:3000/projects |
    grep --quiet "Explore the work already on the LaunchPad"

  curl --fail --silent \
    http://localhost:3000/projects/mobile-application |
    grep --quiet "Mobile application"

  echo "All expected route content was found."
'
```

### Verify filter behavior

Run:

```bash
active_page="$(
  curl --fail --silent \
    "http://localhost:3000/projects?status=ACTIVE"
)"

printf "%s" "${active_page}" | grep --quiet "Website redesign"
printf "%s" "${active_page}" | grep --quiet "Analytics dashboard"

if printf "%s" "${active_page}" | grep --quiet "Mobile application"; then
  echo "Verification failed: a planned project appeared in the active filter."
  exit 1
fi

echo "The ACTIVE filter returned only the expected project content."
```

Expected output:

```text
The ACTIVE filter returned only the expected project content.
```

## The Verification

The commands in this step are themselves the verification.

Before proceeding, ensure:

- Every known route returns `200`.
- Unknown resources return `404`.
- Each route contains its expected heading.
- Dynamic project IDs select the correct project.
- The Active filter includes active projects.
- The Active filter excludes the planned project.
- No command reports a connection, HTTP, or content error.

[GENERATED: Part 2, Step 9: Route Verification] [STARTING: Part 2, Step 10: Production Routing Build]

---

# Step 10: Verify the Production Route Build

## The Target

Build the expanded routing tree for production and verify that known dynamic project routes are generated correctly.

## The Concept

Development mode resolves routes as we work. The production build performs deeper analysis and optimization.

Our dynamic project page exports:

```tsx
generateStaticParams()
```

This function gives Next.js the known project IDs at build time. Next.js can then prepare those project routes in advance.

Think of a theater printing tickets for all scheduled performances. The route pattern describes the theater, while `generateStaticParams` supplies the scheduled dates for which tickets should be prepared.

When project data moves to a database and becomes user-specific, we will revisit this strategy. Private, user-owned project routes should not be globally generated from one shared catalog.

## The Implementation

Stop the development server:

```text
Ctrl+C
```

Create a production build:

```bash
npm run build
```

The route output should include entries resembling:

```text
/
├ /about
├ /features
├ /projects
└ /projects/[projectId]
  ├ /projects/website-redesign
  ├ /projects/mobile-application
  ├ /projects/documentation-hub
  └ /projects/analytics-dashboard
```

The exact symbols and formatting may vary by Next.js 16 patch version.

Start the production server:

```bash
npm run start
```

In a second terminal, verify each generated project route:

```bash
for project_id in \
  "website-redesign" \
  "mobile-application" \
  "documentation-hub" \
  "analytics-dashboard"
do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000/projects/${project_id}"
  )"

  printf "%-40s %s\n" \
    "/projects/${project_id}" \
    "${status_code}"
done
```

Expected output:

```text
/projects/website-redesign               200
/projects/mobile-application             200
/projects/documentation-hub              200
/projects/analytics-dashboard            200
```

## The Verification

Check one route’s title in production:

```bash
curl --silent http://localhost:3000/projects/analytics-dashboard |
  grep -o "<title>[^<]*</title>"
```

Expected output:

```html
<title>Analytics dashboard | LaunchPad</title>
```

Check the production not-found response:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/projects/missing
```

Expected output:

```text
404
```

Stop the production server after verification:

```text
Ctrl+C
```

[GENERATED: Part 2, Step 10: Production Routing Build] [STARTING: Part 2, Step 11: Git Checkpoint]

---

# Step 11: Create the Part 2 Git Checkpoint

## The Target

Commit the routing work after all development and production checks pass.

## The Concept

A useful Git commit should capture one coherent, verified change.

Part 2 introduced a complete routing layer:

- Public pages
- Navigation
- Search-parameter filtering
- Dynamic segments
- Metadata
- Not-found behavior
- Responsive route styles

Committing this work separately will make the later layout refactor easy to review. We will be able to see exactly which repeated page elements Part 3 moves into shared layouts.

## The Implementation

Inspect the changed files:

```bash
git status
```

Review the change summary:

```bash
git diff --stat
```

Review the actual changes:

```bash
git diff
```

Run the quality gate one final time:

```bash
npx tsc --noEmit
npm run lint
npm run build
```

If all commands succeed, stage the files:

```bash
git add src/app src/components src/lib
```

Inspect the staged change:

```bash
git diff --cached --stat
```

Create the commit:

```bash
git commit -m "feat: add public routes and project previews"
```

## The Verification

Inspect the latest commit:

```bash
git log -1 --oneline
```

Expected output resembles:

```text
d4e5f6a feat: add public routes and project previews
```

Check the working tree:

```bash
git status
```

Expected output:

```text
nothing to commit, working tree clean
```

[GENERATED: Part 2, Step 11: Git Checkpoint] [STARTING: Part 2 Reference Sections]

---

# Part 2 Reference A: Route Segments

A **route segment** is one portion of a URL path.

For this URL:

```text
/projects/website-redesign
```

the route segments are:

```text
projects
website-redesign
```

The matching source structure is:

```text
src/app/projects/[projectId]/page.tsx
```

The fixed segment is:

```text
projects
```

The dynamic segment is:

```text
[projectId]
```

## Static segments

A directory with an ordinary name creates a fixed segment:

```text
src/app/about/page.tsx → /about
```

## Dynamic segments

Square brackets capture one segment:

```text
src/app/projects/[projectId]/page.tsx
```

Examples:

```text
/projects/website-redesign
/projects/mobile-application
```

## Catch-all segments

A catch-all segment captures one or more segments:

```text
src/app/docs/[...slug]/page.tsx
```

It could match:

```text
/docs/getting-started
/docs/guides/routing
/docs/guides/routing/dynamic-segments
```

The `slug` value is an array.

## Optional catch-all segments

Double square brackets create an optional catch-all:

```text
src/app/docs/[[...slug]]/page.tsx
```

It can also match the route without additional segments:

```text
/docs
```

LaunchPad does not need catch-all routing yet. We will introduce route patterns only when the product requires them.

---

# Part 2 Reference B: Path Parameters Versus Search Parameters

Path parameters and search parameters serve different purposes.

## Path parameter

```text
/projects/website-redesign
```

Here, `website-redesign` identifies the primary resource.

A different value generally means a different project:

```text
/projects/mobile-application
```

## Search parameter

```text
/projects?status=ACTIVE
```

Here, `/projects` remains the primary resource. The search parameter changes how the list is filtered.

## Practical rule

Use path segments for resource identity and hierarchy:

```text
/projects/website-redesign
```

Use search parameters for optional view state:

```text
/projects?status=ACTIVE
/projects?sort=name
/projects?page=2
```

This is a design guideline rather than an unbreakable law, but following it usually produces understandable URLs.

---

# Part 2 Reference C: Async Route APIs in Next.js 16

In Next.js 16 App Router pages, route values such as `params` and `searchParams` are asynchronous.

A dynamic page uses:

```tsx
type PageProps = {
  params: Promise<{
    projectId: string;
  }>;
};

export default async function Page({ params }: PageProps) {
  const { projectId } = await params;

  return <p>{projectId}</p>;
}
```

A page using search parameters follows the same pattern:

```tsx
type PageProps = {
  searchParams: Promise<{
    status?: string | string[];
  }>;
};

export default async function Page({ searchParams }: PageProps) {
  const query = await searchParams;

  return <p>{query.status ?? "No status selected"}</p>;
}
```

Do not treat URL values as trusted merely because TypeScript describes their container.

This would be unsafe:

```tsx
const status = query.status as ProjectStatus;
```

A type assertion tells TypeScript to trust the programmer. It does not validate the runtime value.

Our implementation instead checks:

```tsx
isProjectStatus(normalizedValue)
```

---

# Part 2 Reference D: `Link` Versus `<a>`

Use `Link` for internal Next.js routes:

```tsx
import Link from "next/link";

<Link href="/projects">Projects</Link>
```

Use an ordinary anchor for external destinations:

```tsx
<a href="https://nextjs.org">Next.js documentation</a>
```

For a link opening a new browsing context, include protection against the new page accessing the original window:

```tsx
<a
  href="https://example.com"
  target="_blank"
  rel="noreferrer"
>
  External resource
</a>
```

An ordinary anchor is also appropriate for:

- Page fragments:

  ```tsx
  <a href="#features">Features</a>
  ```

- Email links:

  ```tsx
  <a href="mailto:support@example.com">Email support</a>
  ```

- Telephone links:

  ```tsx
  <a href="tel:+15550100">Call support</a>
  ```

Buttons are not substitutes for navigation.

Use a link when the action changes location. Use a button when the action performs an operation.

---

# Part 2 Reference E: Metadata

The root layout defines a title template:

```tsx
export const metadata: Metadata = {
  title: {
    default: "LaunchPad",
    template: "%s | LaunchPad",
  },
};
```

A static route can provide metadata directly:

```tsx
export const metadata: Metadata = {
  title: "About",
};
```

Result:

```text
About | LaunchPad
```

A dynamic route can generate metadata from route data:

```tsx
export async function generateMetadata({
  params,
}: ProjectPageProps): Promise<Metadata> {
  const { projectId } = await params;
  const project = getProjectById(projectId);

  return {
    title: project?.name ?? "Project not found",
  };
}
```

Metadata generation is server-side work. It should validate and safely handle missing data just like the page itself.

---

# Part 2 Reference F: `notFound()`

Import `notFound` from:

```tsx
import { notFound } from "next/navigation";
```

Call it when a requested resource does not exist:

```tsx
const project = getProjectById(projectId);

if (!project) {
  notFound();
}
```

This stops normal rendering and selects the closest available `not-found.tsx` boundary.

Use `notFound()` for an absent resource, not for every error.

Examples appropriate for `notFound()`:

- A project ID has no matching project.
- A public article slug does not exist.
- A requested catalog item was removed.

Examples requiring other handling:

- The database is unexpectedly unavailable.
- A programming error occurred.
- A user submitted invalid form data.
- A signed-in user lacks permission.

Those situations require error handling, validation feedback, authentication, or authorization—not a blanket 404 response.

---

# Part 2 Reference G: Static Generation of Dynamic Routes

A dynamic route does not automatically mean that every response must be rendered from scratch.

Our project-detail page exports:

```tsx
export function generateStaticParams() {
  return getAllProjects().map((project) => ({
    projectId: project.id,
  }));
}
```

This tells Next.js about known parameter values during the build.

The result is conceptually similar to generating:

```text
/projects/website-redesign
/projects/mobile-application
/projects/documentation-hub
/projects/analytics-dashboard
```

This strategy fits our current public, fixed catalog.

It will not fit every future route. Private dashboard records depend on authenticated users and changing database state. We will choose their rendering and caching behavior based on those requirements rather than copying this static strategy blindly.

---

# Part 2 Reference H: Server Components and URL State

Every page in Part 2 remains a Server Component.

We implemented project filtering without:

- `useState`
- `useEffect`
- Browser event handlers
- A `"use client"` directive

The browser submits this form:

```tsx
<form action="/projects" method="get">
```

The resulting URL contains:

```text
?status=ACTIVE
```

The server reads that value and renders the filtered page.

This approach has useful properties:

- It works without client-side React state.
- The filter can be bookmarked.
- The filter can be shared.
- Refreshing preserves the selection.
- Browser back and forward navigation work naturally.

In Part 4, we will introduce Client Components where immediate interactivity genuinely requires browser-side state.

---

# Part 2 Reference I: Current Project Structure

After Part 2, the important source structure is:

```text
src/
├── app/
│   ├── about/
│   │   └── page.tsx
│   ├── features/
│   │   └── page.tsx
│   ├── projects/
│   │   ├── [projectId]/
│   │   │   └── page.tsx
│   │   └── page.tsx
│   ├── favicon.ico
│   ├── globals.css
│   ├── layout.tsx
│   ├── not-found.tsx
│   └── page.tsx
├── components/
│   └── site-header.tsx
└── lib/
    └── project-catalog.ts
```

The URL map is:

```text
src/app/page.tsx
└── /

src/app/about/page.tsx
└── /about

src/app/features/page.tsx
└── /features

src/app/projects/page.tsx
└── /projects

src/app/projects/[projectId]/page.tsx
└── /projects/:projectId
```

The root layout wraps all of them:

```text
src/app/layout.tsx
├── /
├── /about
├── /features
├── /projects
└── /projects/:projectId
```

At present, each page also renders `SiteHeader` and a footer directly. That repetition is the architectural problem Part 3 will solve with route groups and nested layouts.

---

# Part 2 Completion Checklist

Before continuing, confirm every item:

- [ ] `/` displays the updated LaunchPad landing page.
- [ ] `/about` displays the About page.
- [ ] `/features` displays the Features page.
- [ ] `/projects` displays all four temporary projects.
- [ ] `/projects?status=ACTIVE` displays only active projects.
- [ ] A lowercase valid status is normalized correctly.
- [ ] An invalid status displays a warning and fails safely.
- [ ] `/projects/website-redesign` displays the correct project.
- [ ] Dynamic project pages produce route-specific titles.
- [ ] Unknown project IDs return `404`.
- [ ] Unknown routes return `404`.
- [ ] The custom not-found interface provides recovery links.
- [ ] Internal route navigation uses `next/link`.
- [ ] Navigation works with the keyboard.
- [ ] Layouts remain usable on narrow screens.
- [ ] `npx tsc --noEmit` succeeds.
- [ ] `npm run lint` succeeds.
- [ ] `npm run build` succeeds.
- [ ] All known project routes work under `npm run start`.
- [ ] Git contains the Part 2 checkpoint.
- [ ] `git status` reports a clean working tree.

You now understand how Next.js maps files to URLs, how routes receive path and search parameters, how dynamic resources produce metadata, and how missing resources are handled safely.
