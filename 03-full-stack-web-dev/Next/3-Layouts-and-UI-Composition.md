# Part 3: Layouts and UI Composition

In Part 2, we added several routes, but every page directly renders its own header and footer.

That repetition creates architectural problems:

- A navigation change must be repeated across several files.
- Pages control application-wide chrome they should not own.
- Marketing pages and workspace pages cannot easily use different shells.
- Repeated markup can drift into inconsistent versions.

In this part, we will use layouts, route groups, and component composition to solve those problems.

By the end of Part 3, LaunchPad will have:

- A minimal root layout
- A marketing route group
- A workspace route group
- Separate marketing and workspace layouts
- Shared headers and footers
- Nested workspace navigation
- A new `/dashboard` route
- Reusable page-heading composition
- URL paths unchanged by route groups
- Route-level metadata composed with root metadata

---

# Step 1: Plan the Layout Hierarchy

## The Target

Understand the new route and layout hierarchy before moving files.

## The Concept

A layout surrounds every page beneath its directory.

Think of layouts as nested picture frames:

- The root layout is the outside frame around the entire application.
- The marketing layout adds the public website header and footer.
- The workspace layout adds project-management navigation.
- The page supplies the route-specific picture.

Next.js composes these layers automatically.

Our current route tree is flat:

```text
src/app/
├── about/
├── features/
├── projects/
├── layout.tsx
└── page.tsx
```

We will reorganize it with **route groups**:

```text
src/app/
├── (marketing)/
│   ├── about/
│   ├── features/
│   ├── layout.tsx
│   └── page.tsx
├── (workspace)/
│   ├── dashboard/
│   ├── projects/
│   └── layout.tsx
├── globals.css
├── layout.tsx
└── not-found.tsx
```

A route group is a directory enclosed in parentheses:

```text
(marketing)
(workspace)
```

Route-group names organize source code but do not appear in URLs.

Therefore:

```text
src/app/(marketing)/about/page.tsx
```

still maps to:

```text
/about
```

It does **not** map to:

```text
/marketing/about
```

Similarly:

```text
src/app/(workspace)/projects/page.tsx
```

still maps to:

```text
/projects
```

Route groups let us organize routes according to application concerns without changing public addresses.

## The Implementation

No files change in this planning step.

The intended layout composition is:

```text
RootLayout
├── MarketingLayout
│   ├── /
│   ├── /about
│   └── /features
│
└── WorkspaceLayout
    ├── /dashboard
    ├── /projects
    └── /projects/[projectId]
```

For `/about`, Next.js will conceptually render:

```tsx
<RootLayout>
  <MarketingLayout>
    <AboutPage />
  </MarketingLayout>
</RootLayout>
```

For `/projects/website-redesign`, it will conceptually render:

```tsx
<RootLayout>
  <WorkspaceLayout>
    <ProjectPage />
  </WorkspaceLayout>
</RootLayout>
```

We never manually write those compositions. The directory hierarchy establishes them.

## The Verification

Start the development server if necessary:

```bash
npm run dev
```

Confirm the current routes before restructuring:

```bash
for path in "/" "/about" "/features" "/projects"; do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000${path}"
  )"

  printf "%-20s %s\n" "${path}" "${status_code}"
done
```

Expected output:

```text
/                    200
/about               200
/features            200
/projects            200
```

These same URLs must continue working after the files move.

[GENERATED: Part 3, Step 1: Layout Hierarchy Plan] [STARTING: Part 3, Step 2: Route Groups]

---

# Step 2: Create Route Groups and Move Existing Routes

## The Target

Move the existing pages into marketing and workspace route groups without changing their URLs.

## The Concept

Moving a route into an ordinary directory changes its URL:

```text
src/app/marketing/about/page.tsx → /marketing/about
```

Moving it into a route group does not:

```text
src/app/(marketing)/about/page.tsx → /about
```

The parentheses tell Next.js:

> Use this directory for organization and layout boundaries, but leave its name out of the URL.

This is useful when two sets of pages need different visual shells.

## The Implementation

Stop the development server before moving several route files:

```text
Ctrl+C
```

Create the route groups.

### macOS, Linux, or Git Bash

```bash
mkdir -p 'src/app/(marketing)'
mkdir -p 'src/app/(workspace)'
```

Move the routes:

```bash
mv src/app/page.tsx 'src/app/(marketing)/page.tsx'
mv src/app/about 'src/app/(marketing)/about'
mv src/app/features 'src/app/(marketing)/features'
mv src/app/projects 'src/app/(workspace)/projects'
```

### PowerShell

```powershell
New-Item -ItemType Directory -Force 'src/app/(marketing)' |
  Out-Null

New-Item -ItemType Directory -Force 'src/app/(workspace)' |
  Out-Null

Move-Item 'src/app/page.tsx' 'src/app/(marketing)/page.tsx'
Move-Item 'src/app/about' 'src/app/(marketing)/about'
Move-Item 'src/app/features' 'src/app/(marketing)/features'
Move-Item 'src/app/projects' 'src/app/(workspace)/projects'
```

The source tree should now resemble:

```text
src/app/
├── (marketing)/
│   ├── about/
│   │   └── page.tsx
│   ├── features/
│   │   └── page.tsx
│   └── page.tsx
├── (workspace)/
│   └── projects/
│       ├── [projectId]/
│       │   └── page.tsx
│       └── page.tsx
├── globals.css
├── layout.tsx
└── not-found.tsx
```

Do not create the group layouts yet. Until those files exist, the root layout continues to wrap every page directly.

## The Verification

Restart the development server:

```bash
npm run dev
```

Verify that moving the files did not change their URLs:

```bash
for path in \
  "/" \
  "/about" \
  "/features" \
  "/projects" \
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
/projects/website-redesign               200
```

Verify that route-group names are not public URL segments:

```bash
curl --silent \
  --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000/marketing/about
```

Expected output:

```text
404
```

Run:

```bash
npx tsc --noEmit
npm run lint
```

Both commands should succeed.

[GENERATED: Part 3, Step 2: Route Groups] [STARTING: Part 3, Step 3: Reusable Footer]

---

# Step 3: Extract the Shared Footer

## The Target

Create one reusable footer component that layouts can render around their child pages.

## The Concept

A shared component is useful when the same interface and responsibility appear in several places.

Our pages currently contain nearly identical footer markup. A footer belongs to the surrounding application shell rather than to an individual page.

Think of a shopping center: every store has unique contents, but the building directory and exits belong to the center itself. Pages are the stores; layouts own the shared building structure.

We will give the footer an optional `message` property. A **property**, commonly called a prop, is input passed from one component to another.

## The Implementation

Create the footer component.

### `src/components/site-footer.tsx`

```tsx
type SiteFooterProps = {
  message?: string;
};

export function SiteFooter({
  message = "From Zero to Production with Next.js 16",
}: SiteFooterProps) {
  return (
    <footer className="site-footer">
      <div className="site-shell">
        <p>
          LaunchPad
          <span aria-hidden="true"> · </span>
          {message}
        </p>
      </div>
    </footer>
  );
}
```

### Why the property is optional

The question mark makes `message` optional:

```tsx
type SiteFooterProps = {
  message?: string;
};
```

If a layout does not supply it, the component uses:

```tsx
"From Zero to Production with Next.js 16"
```

This is a default parameter value:

```tsx
{
  message = "From Zero to Production with Next.js 16",
}
```

### Why the separator is hidden

The centered dot is decorative punctuation:

```tsx
<span aria-hidden="true"> · </span>
```

`aria-hidden="true"` prevents assistive technology from unnecessarily announcing the decorative character.

## The Verification

The component is not rendered yet, but it must compile independently.

Run:

```bash
npx tsc --noEmit
npm run lint
```

Both commands should succeed.

Confirm that the component exports correctly:

```bash
grep "export function SiteFooter" src/components/site-footer.tsx
```

Expected output:

```tsx
export function SiteFooter({
```

[GENERATED: Part 3, Step 3: Shared Footer] [STARTING: Part 3, Step 4: Marketing Layout]

---

# Step 4: Create the Marketing Layout

## The Target

Create a nested layout that automatically surrounds the home, About, and Features pages with the public header and footer.

## The Concept

The marketing layout will receive a `children` property.

`children` represents whichever child route is active:

- `/`
- `/about`
- `/features`

The layout does not need to know which specific page it is wrapping. It provides the stable shell, and Next.js places the active route into `{children}`.

This pattern is called **composition**. Composition builds complex interfaces by placing smaller parts inside one another.

A lunchbox is a useful analogy:

- The lunchbox is the layout.
- The food placed inside is `children`.
- The container stays consistent even when its contents change.

## The Implementation

Create the marketing layout.

### `src/app/(marketing)/layout.tsx`

```tsx
import type { ReactNode } from "react";

import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";

type MarketingLayoutProps = Readonly<{
  children: ReactNode;
}>;

export default function MarketingLayout({
  children,
}: MarketingLayoutProps) {
  return (
    <div className="application-shell">
      <SiteHeader />

      <div className="application-shell__content">{children}</div>

      <SiteFooter message="Built one verified layer at a time" />
    </div>
  );
}
```

### Why the layout uses a wrapper

The wrapper allows CSS to keep the footer near the bottom of short pages:

```tsx
<div className="application-shell">
```

Its content area can grow:

```tsx
<div className="application-shell__content">{children}</div>
```

The footer then appears after the flexible content region.

### Why the root layout does not render this header

The root layout surrounds every route, including future authentication pages, API-related boundaries, and workspace pages.

Placing the public header in the root layout would force every route to use it. A nested marketing layout gives us a narrower and more accurate boundary.

## The Verification

Because the existing marketing pages still render their own headers and footers, they will temporarily show duplicates.

That temporary state proves the new layout is active before we remove old markup.

Open:

```text
http://localhost:3000/about
```

You should temporarily see:

- The layout header
- The page’s original header
- The page’s original footer
- The layout footer

This is expected only during the refactor.

Run:

```bash
npx tsc --noEmit
npm run lint
```

Both commands should succeed.

[GENERATED: Part 3, Step 4: Marketing Layout] [STARTING: Part 3, Step 5: Marketing Page Refactor]

---

# Step 5: Remove Shared Chrome from Marketing Pages

## The Target

Refactor the Home, About, and Features pages so they render only route-specific content.

## The Concept

A page should own what is unique to its route. A layout should own what is shared around multiple routes.

This division is called **separation of concerns**. A concern is a distinct responsibility.

After the refactor:

- The marketing layout owns the site header and footer.
- The Home page owns its hero and feature preview.
- The About page owns its engineering explanation.
- The Features page owns its capability map.

This makes each file easier to reason about.

## The Implementation

Completely replace all three marketing page files.

### `src/app/(marketing)/page.tsx`

```tsx
import Link from "next/link";

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
    <main className="site-shell">
      <section className="hero" aria-labelledby="hero-heading">
        <p className="eyebrow">Built with Next.js 16</p>

        <h1 id="hero-heading">
          Turn ambitious ideas into organized work.
        </h1>

        <p className="hero-description">
          LaunchPad is a secure project and task management application. Over
          this series, this website will grow into a complete full-stack
          product.
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
  );
}
```

### `src/app/(marketing)/about/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";

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
            The feature map shows how the application will evolve across the
            remainder of the series.
          </p>
        </div>

        <Link className="primary-link" href="/features">
          View features
        </Link>
      </aside>
    </main>
  );
}
```

### `src/app/(marketing)/features/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";

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
    <main className="site-shell page-content">
      <header className="page-heading">
        <p className="eyebrow">Feature map</p>
        <h1>A small interface backed by serious engineering</h1>
        <p>
          LaunchPad will combine an approachable project-management experience
          with the security, performance, and operational practices expected
          from a production application.
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
          <h2 id="preview-heading">
            Explore the temporary project catalog
          </h2>
          <p>
            The project routes use typed sample data to demonstrate list,
            filter, and detail navigation.
          </p>
        </div>

        <Link className="primary-link" href="/projects">
          Browse projects
        </Link>
      </aside>
    </main>
  );
}
```

## The Verification

Open:

```text
http://localhost:3000
http://localhost:3000/about
http://localhost:3000/features
```

Each page should now display exactly:

- One site header
- One main content region
- One site footer

Count headers in the About page’s HTML:

```bash
curl --silent http://localhost:3000/about |
  grep -o "<header" |
  wc -l
```

The output may be greater than one because the page contains a semantic page heading as well as the site header. Instead, verify the unique site-header class:

```bash
curl --silent http://localhost:3000/about |
  grep -o 'class="site-header"' |
  wc -l
```

Expected output:

```text
1
```

Verify one site footer:

```bash
curl --silent http://localhost:3000/about |
  grep -o 'class="site-footer"' |
  wc -l
```

Expected output:

```text
1
```

Run:

```bash
npx tsc --noEmit
npm run lint
```

Both commands should succeed.

[GENERATED: Part 3, Step 5: Marketing Page Refactor] [STARTING: Part 3, Step 6: Workspace Navigation]

---

# Step 6: Build Workspace Navigation

## The Target

Create navigation for the dashboard and project-management area.

## The Concept

The public header answers broad questions:

- What is LaunchPad?
- What features will it have?
- Where are the projects?

The workspace navigation answers task-focused questions:

- Where is my dashboard?
- Where is the project list?

These are different navigation responsibilities, so they should not be forced into one oversized component.

Our workspace navigation will remain a Server Component. It does not need browser state or event handlers.

In Part 4, we will add focused client-side behavior where it provides a real benefit.

## The Implementation

Create the workspace navigation component.

### `src/components/workspace-navigation.tsx`

```tsx
import Link from "next/link";

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

export function WorkspaceNavigation() {
  return (
    <nav
      className="workspace-navigation"
      aria-label="Workspace navigation"
    >
      <p className="workspace-navigation__label">Workspace</p>

      <ul>
        {workspaceLinks.map((link) => (
          <li key={link.href}>
            <Link href={link.href}>
              <span>{link.label}</span>
              <small>{link.description}</small>
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  );
}
```

### Why this component does not highlight the active route yet

Determining the current browser pathname with `usePathname` requires a Client Component.

We could add `"use client"` now, but doing so would introduce the server/client boundary before Part 4 explains it properly.

For this part, semantic navigation and working links are enough. We will enhance active-route feedback after introducing Client Components deliberately.

## The Verification

Run:

```bash
npx tsc --noEmit
npm run lint
```

Both commands should succeed.

The component is not visible yet because the workspace layout has not been created.

Confirm its links:

```bash
grep -E 'href: "/(dashboard|projects)"' \
  src/components/workspace-navigation.tsx
```

Expected output includes:

```text
href: "/dashboard",
href: "/projects",
```

[GENERATED: Part 3, Step 6: Workspace Navigation] [STARTING: Part 3, Step 7: Workspace Layout]

---

# Step 7: Create the Workspace Layout

## The Target

Create a nested layout for `/dashboard`, `/projects`, and all project-detail routes.

## The Concept

Nested layouts let one part of an application have a different structure from another part.

The marketing layout resembles a public website:

```text
Header
Content
Footer
```

The workspace layout resembles an application:

```text
Header
Sidebar navigation | Workspace content
Footer
```

The project-detail route is nested below the project route directory, but it still inherits the workspace layout because both are inside `(workspace)`.

Layouts apply through the directory tree, not through URL naming guesses.

## The Implementation

Create the workspace layout.

### `src/app/(workspace)/layout.tsx`

```tsx
import type { Metadata } from "next";
import type { ReactNode } from "react";

import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { WorkspaceNavigation } from "@/components/workspace-navigation";

export const metadata: Metadata = {
  robots: {
    index: false,
    follow: false,
  },
};

type WorkspaceLayoutProps = Readonly<{
  children: ReactNode;
}>;

export default function WorkspaceLayout({
  children,
}: WorkspaceLayoutProps) {
  return (
    <div className="application-shell">
      <SiteHeader />

      <div className="workspace-shell">
        <aside className="workspace-sidebar">
          <WorkspaceNavigation />
        </aside>

        <div className="workspace-main">{children}</div>
      </div>

      <SiteFooter message="Project workspace" />
    </div>
  );
}
```

### Why workspace pages use `noindex`

The metadata includes:

```tsx
robots: {
  index: false,
  follow: false,
},
```

This asks search-engine crawlers not to index workspace routes or follow links from them.

The project catalog is still public in this tutorial phase, but the workspace is moving toward authenticated, user-specific content. Private application screens generally should not appear in search results.

This metadata is not a security control. Search-engine instructions do not prevent access. Authentication and authorization will provide the real security boundary in Part 8.

### Why the sidebar is an `<aside>`

The sidebar contains supporting navigation adjacent to the primary route content:

```tsx
<aside className="workspace-sidebar">
```

The navigation itself still uses `<nav>`, which explicitly communicates its purpose.

## The Verification

Open:

```text
http://localhost:3000/projects
```

The page will temporarily contain duplicated headers and footers because its own old markup remains.

You should also see the new workspace navigation.

Inspect the workspace metadata:

```bash
curl --silent http://localhost:3000/projects |
  grep -o '<meta name="robots"[^>]*>'
```

Expected output contains directives equivalent to:

```html
<meta name="robots" content="noindex, nofollow"/>
```

Exact attribute order may differ.

Run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 3, Step 7: Workspace Layout] [STARTING: Part 3, Step 8: Workspace Page Refactor]

---

# Step 8: Refactor the Project Pages for the Workspace Layout

## The Target

Remove repeated site headers and footers from both project pages while preserving their routing and data behavior.

## The Concept

A nested page does not need to know how the full workspace is assembled.

It only needs to provide the content that belongs in the layout’s `{children}` position.

The workspace layout now owns:

- Public site header
- Workspace sidebar
- Footer
- Overall workspace shell

The project pages still own:

- Filtering
- Project cards
- Dynamic project lookup
- Breadcrumbs
- Project statistics
- Not-found behavior

## The Implementation

Completely replace both project page files.

### `src/app/(workspace)/projects/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";

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
    <main className="site-shell page-content">
      <header className="page-heading">
        <p className="eyebrow">Project workspace</p>
        <h1>Explore the work already on the LaunchPad</h1>
        <p>
          These records currently live in a typed in-memory catalog. In Part
          5, the same routes will read records from a relational database.
        </p>
      </header>

      <section className="filter-panel" aria-labelledby="filter-heading">
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
            <h3>No projects matched this filter</h3>
            <p>Choose another status to see available projects.</p>
            <Link className="secondary-link" href="/projects">
              Clear filter
            </Link>
          </div>
        )}
      </section>
    </main>
  );
}
```

### `src/app/(workspace)/projects/[projectId]/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";

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
  );
}
```

## The Verification

Open:

```text
http://localhost:3000/projects
http://localhost:3000/projects/website-redesign
```

Each route should have:

- One site header
- One workspace sidebar
- One footer
- Its route-specific content

Verify the number of shared shell elements:

```bash
project_page="$(
  curl --fail --silent \
    http://localhost:3000/projects/website-redesign
)"

printf "%s" "${project_page}" |
  grep -o 'class="site-header"' |
  wc -l

printf "%s" "${project_page}" |
  grep -o 'class="workspace-sidebar"' |
  wc -l

printf "%s" "${project_page}" |
  grep -o 'class="site-footer"' |
  wc -l
```

Each command should print:

```text
1
```

Verify that filtering still works:

```bash
curl --fail --silent \
  "http://localhost:3000/projects?status=COMPLETED" |
  grep --quiet "Documentation hub"

echo "Workspace project filtering works."
```

Expected output:

```text
Workspace project filtering works.
```

Run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 3, Step 8: Workspace Project Refactor] [STARTING: Part 3, Step 9: Dashboard Page]

---

# Step 9: Create the Dashboard Page

## The Target

Create `/dashboard` as the workspace’s overview route.

## The Concept

The dashboard should summarize data rather than duplicate the full project list.

It will compose existing project-catalog functions into:

- Total project count
- Active project count
- Total task count
- Completed task count
- Overall completion percentage
- A short list of active projects

This demonstrates that several pages can use the same application data module without copying its source data.

The page remains a Server Component. All calculations happen during server rendering, and no browser-side state is required.

## The Implementation

Create the dashboard directory.

### macOS, Linux, or Git Bash

```bash
mkdir -p 'src/app/(workspace)/dashboard'
```

### PowerShell

```powershell
New-Item `
  -ItemType Directory `
  -Force `
  'src/app/(workspace)/dashboard' |
  Out-Null
```

Create the page.

### `src/app/(workspace)/dashboard/page.tsx`

```tsx
import type { Metadata } from "next";
import Link from "next/link";

import {
  calculateProjectProgress,
  formatProjectStatus,
  getAllProjects,
  getProjectsByStatus,
} from "@/lib/project-catalog";

export const metadata: Metadata = {
  title: "Dashboard",
  description:
    "View a summary of projects and task progress in the LaunchPad workspace.",
};

export default function DashboardPage() {
  const projects = getAllProjects();
  const activeProjects = getProjectsByStatus("ACTIVE");

  const totalTaskCount = projects.reduce(
    (total, project) => total + project.taskCount,
    0,
  );

  const completedTaskCount = projects.reduce(
    (total, project) => total + project.completedTaskCount,
    0,
  );

  const overallProgress =
    totalTaskCount === 0
      ? 0
      : Math.round((completedTaskCount / totalTaskCount) * 100);

  return (
    <main className="site-shell page-content">
      <header className="page-heading dashboard-heading">
        <div>
          <p className="eyebrow">Workspace overview</p>
          <h1>Good work starts with a clear view.</h1>
          <p>
            This dashboard summarizes the temporary project catalog. Later,
            it will display authenticated, database-backed information for the
            current user.
          </p>
        </div>

        <Link className="primary-link" href="/projects">
          View all projects
        </Link>
      </header>

      <section
        className="dashboard-stat-grid"
        aria-label="Workspace statistics"
      >
        <article className="dashboard-stat">
          <span>Projects</span>
          <strong>{projects.length}</strong>
          <p>{activeProjects.length} currently active</p>
        </article>

        <article className="dashboard-stat">
          <span>Total tasks</span>
          <strong>{totalTaskCount}</strong>
          <p>Across every project</p>
        </article>

        <article className="dashboard-stat">
          <span>Completed tasks</span>
          <strong>{completedTaskCount}</strong>
          <p>{overallProgress}% overall progress</p>
        </article>
      </section>

      <section
        className="dashboard-section"
        aria-labelledby="active-projects-heading"
      >
        <div className="results-heading">
          <div>
            <p className="eyebrow">Current focus</p>
            <h2 id="active-projects-heading">Active projects</h2>
          </div>

          <Link className="text-link" href="/projects?status=ACTIVE">
            View filtered list
            <span aria-hidden="true"> →</span>
          </Link>
        </div>

        <div className="project-grid">
          {activeProjects.map((project) => {
            const progress = calculateProjectProgress(project);

            return (
              <article className="project-card" key={project.id}>
                <div className="project-card__heading">
                  <h3>
                    <Link href={`/projects/${project.id}`}>
                      {project.name}
                    </Link>
                  </h3>

                  <span className="status-badge status-badge--active">
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
              </article>
            );
          })}
        </div>
      </section>
    </main>
  );
}
```

### How `reduce` works

`reduce` combines an array into one value:

```tsx
const totalTaskCount = projects.reduce(
  (total, project) => total + project.taskCount,
  0,
);
```

The second argument, `0`, is the starting total.

For each project:

1. Read the current total.
2. Add the project’s task count.
3. Return the updated total.

The catalog contains task counts of:

```text
12 + 8 + 16 + 10 = 46
```

Completed tasks total:

```text
5 + 0 + 16 + 3 = 24
```

Overall completion is:

```text
24 ÷ 46 × 100 ≈ 52%
```

## The Verification

Open:

```text
http://localhost:3000/dashboard
```

Confirm that the page displays:

- 4 projects
- 2 active projects
- 46 total tasks
- 24 completed tasks
- 52% overall progress
- Website redesign
- Analytics dashboard

Verify the route:

```bash
curl --fail --silent http://localhost:3000/dashboard |
  grep --quiet "Good work starts with a clear view"

echo "Dashboard content found."
```

Expected output:

```text
Dashboard content found.
```

Verify its title:

```bash
curl --silent http://localhost:3000/dashboard |
  grep -o "<title>[^<]*</title>"
```

Expected output:

```html
<title>Dashboard | LaunchPad</title>
```

Verify the workspace sidebar appears:

```bash
curl --silent http://localhost:3000/dashboard |
  grep --quiet "Workspace summary"

echo "Workspace layout found."
```

Expected output:

```text
Workspace layout found.
```

Run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 3, Step 9: Dashboard Page] [STARTING: Part 3, Step 10: Layout Styles]

---

# Step 10: Add Layout and Workspace Styles

## The Target

Extend the global stylesheet with styles for the application shell, workspace sidebar, dashboard, and responsive layout behavior.

## The Concept

The route hierarchy defines structural composition. CSS makes that structure visually usable.

The workspace uses a two-column grid:

```text
Sidebar | Main content
```

On narrow screens, it becomes:

```text
Sidebar navigation
Main content
```

This is an important responsive principle: preserve access to functionality rather than merely shrinking everything.

## The Implementation

Append the following complete section to the end of:

### `src/app/globals.css`

```css
/* Part 3: shared layout and workspace composition */

.application-shell {
  display: flex;
  min-height: 100vh;
  flex-direction: column;
}

.application-shell__content {
  flex: 1;
}

.application-shell > .site-footer {
  margin-top: auto;
}

.workspace-shell {
  display: grid;
  width: 100%;
  flex: 1;
  grid-template-columns: 16rem minmax(0, 1fr);
}

.workspace-sidebar {
  padding: 2rem 1rem;
  border-right: 0.0625rem solid var(--color-border);
  background: rgb(255 255 255 / 65%);
}

.workspace-navigation {
  position: sticky;
  top: 6.5rem;
}

.workspace-navigation__label {
  margin: 0 0 0.75rem;
  padding-inline: 0.75rem;
  color: var(--color-text-muted);
  font-size: 0.75rem;
  font-weight: 800;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.workspace-navigation ul {
  display: grid;
  margin: 0;
  padding: 0;
  gap: 0.5rem;
  list-style: none;
}

.workspace-navigation a {
  display: grid;
  padding: 0.75rem;
  border: 0.0625rem solid transparent;
  border-radius: 0.75rem;
  text-decoration: none;
}

.workspace-navigation a:hover {
  border-color: var(--color-border);
  background: var(--color-surface);
  box-shadow: 0 0.5rem 1.5rem rgb(23 32 51 / 6%);
}

.workspace-navigation a span {
  color: var(--color-text);
  font-weight: 800;
}

.workspace-navigation a small {
  color: var(--color-text-muted);
  font-size: 0.8rem;
}

.workspace-main {
  min-width: 0;
}

.workspace-main > .site-shell {
  width: min(100% - 3rem, var(--content-width));
}

.dashboard-heading {
  display: flex;
  max-width: none;
  align-items: end;
  justify-content: space-between;
  gap: 2rem;
}

.dashboard-heading > div {
  max-width: 52rem;
}

.dashboard-heading .primary-link {
  flex: 0 0 auto;
}

.dashboard-stat-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 1rem;
}

.dashboard-stat {
  padding: 1.5rem;
  border: 0.0625rem solid var(--color-border);
  border-radius: 1rem;
  background: var(--color-surface);
  box-shadow: var(--shadow-card);
}

.dashboard-stat > span {
  color: var(--color-text-muted);
  font-size: 0.9rem;
  font-weight: 700;
}

.dashboard-stat strong {
  display: block;
  margin-top: 1rem;
  font-size: clamp(2.5rem, 5vw, 4rem);
  letter-spacing: -0.05em;
  line-height: 1;
}

.dashboard-stat p {
  margin: 0.75rem 0 0;
  color: var(--color-text-muted);
}

.dashboard-section {
  margin-top: 4rem;
  padding-top: 3rem;
  border-top: 0.0625rem solid var(--color-border);
}

@media (max-width: 68rem) {
  .workspace-shell {
    grid-template-columns: 12rem minmax(0, 1fr);
  }

  .dashboard-heading {
    align-items: flex-start;
    flex-direction: column;
  }
}

@media (max-width: 48rem) {
  .workspace-shell {
    display: block;
  }

  .workspace-sidebar {
    padding: 0.75rem 1rem;
    border-right: 0;
    border-bottom: 0.0625rem solid var(--color-border);
  }

  .workspace-navigation {
    position: static;
  }

  .workspace-navigation__label {
    padding-inline: 0;
  }

  .workspace-navigation ul {
    display: flex;
    overflow-x: auto;
  }

  .workspace-navigation li {
    flex: 0 0 auto;
  }

  .workspace-navigation a {
    min-width: 10rem;
  }

  .workspace-main > .site-shell {
    width: min(100% - 2rem, var(--content-width));
  }

  .dashboard-stat-grid {
    grid-template-columns: 1fr;
  }
}
```

### Why `minmax(0, 1fr)` matters

This grid definition uses:

```css
grid-template-columns: 16rem minmax(0, 1fr);
```

The first column is a fixed-width sidebar.

The second column fills remaining space but may shrink below the width of its contents. Without `minmax(0, 1fr)`, long content can force the grid wider than the viewport and cause horizontal overflow.

### Why the workspace navigation is sticky

On wide screens:

```css
.workspace-navigation {
  position: sticky;
  top: 6.5rem;
}
```

The navigation remains visible while the workspace content scrolls.

On small screens, sticky positioning is removed:

```css
.workspace-navigation {
  position: static;
}
```

The navigation becomes a horizontal list above the content, preserving more screen width for the page.

## The Verification

Open:

```text
http://localhost:3000/dashboard
```

On a wide screen, confirm:

- Workspace navigation appears in a left sidebar.
- Dashboard content appears to its right.
- Three statistics appear in one row.
- Active projects appear below the statistics.
- The footer spans the page beneath the workspace.

Open:

```text
http://localhost:3000/projects
```

Confirm that existing project cards fit inside the workspace content area.

Reduce the viewport below approximately `768px`.

Confirm:

- The sidebar moves above the content.
- Workspace links become horizontally arranged.
- Dashboard statistics become one column.
- Content does not cause horizontal page overflow.

Test keyboard navigation:

1. Press `Tab`.
2. Move through the public header links.
3. Continue into workspace navigation.
4. Confirm each focused link has a visible focus outline.
5. Press `Enter` on Projects.
6. Confirm `/projects` loads.

Run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 3, Step 10: Layout and Workspace Styles] [STARTING: Part 3, Step 11: Nested Layout Verification]

---

# Step 11: Verify Layout Composition and Metadata

## The Target

Systematically verify that each route receives the correct layout and metadata without URL changes.

## The Concept

A layout refactor can appear correct while accidentally applying the wrong shell.

We need to verify three distinct properties:

1. Marketing routes receive the marketing shell.
2. Workspace routes receive the workspace shell.
3. Route groups remain absent from public URLs.

We will inspect rendered HTML because layout composition is visible in the final server response.

## The Implementation

Ensure the development server is running:

```bash
npm run dev
```

In another terminal, run this Bash verification script:

```bash
bash -c '
  set -euo pipefail

  base_url="http://localhost:3000"

  marketing_paths=(
    "/"
    "/about"
    "/features"
  )

  workspace_paths=(
    "/dashboard"
    "/projects"
    "/projects/website-redesign"
  )

  for path in "${marketing_paths[@]}"; do
    html="$(curl --fail --silent "${base_url}${path}")"

    printf "%s" "${html}" |
      grep --quiet "site-header"

    printf "%s" "${html}" |
      grep --quiet "site-footer"

    if printf "%s" "${html}" |
      grep --quiet "workspace-sidebar"; then
      echo "Unexpected workspace layout on ${path}"
      exit 1
    fi

    echo "Marketing layout verified: ${path}"
  done

  for path in "${workspace_paths[@]}"; do
    html="$(curl --fail --silent "${base_url}${path}")"

    printf "%s" "${html}" |
      grep --quiet "site-header"

    printf "%s" "${html}" |
      grep --quiet "site-footer"

    printf "%s" "${html}" |
      grep --quiet "workspace-sidebar"

    echo "Workspace layout verified: ${path}"
  done

  echo "All nested layouts were verified."
'
```

Expected output:

```text
Marketing layout verified: /
Marketing layout verified: /about
Marketing layout verified: /features
Workspace layout verified: /dashboard
Workspace layout verified: /projects
Workspace layout verified: /projects/website-redesign
All nested layouts were verified.
```

### PowerShell verification

```powershell
$baseUrl = "http://localhost:3000"

$marketingPaths = @(
  "/",
  "/about",
  "/features"
)

$workspacePaths = @(
  "/dashboard",
  "/projects",
  "/projects/website-redesign"
)

foreach ($path in $marketingPaths) {
  $response = Invoke-WebRequest `
    -Uri "$baseUrl$path" `
    -UseBasicParsing

  if ($response.Content -notmatch "site-header") {
    throw "Site header missing from $path"
  }

  if ($response.Content -notmatch "site-footer") {
    throw "Site footer missing from $path"
  }

  if ($response.Content -match "workspace-sidebar") {
    throw "Unexpected workspace layout on $path"
  }

  Write-Output "Marketing layout verified: $path"
}

foreach ($path in $workspacePaths) {
  $response = Invoke-WebRequest `
    -Uri "$baseUrl$path" `
    -UseBasicParsing

  if ($response.Content -notmatch "workspace-sidebar") {
    throw "Workspace layout missing from $path"
  }

  Write-Output "Workspace layout verified: $path"
}
```

Verify metadata inheritance:

```bash
for path in \
  "/about" \
  "/features" \
  "/dashboard" \
  "/projects" \
  "/projects/website-redesign"
do
  title="$(
    curl --silent "http://localhost:3000${path}" |
      grep -o "<title>[^<]*</title>"
  )"

  printf "%-40s %s\n" "${path}" "${title}"
done
```

Expected output:

```text
/about                  <title>About | LaunchPad</title>
/features               <title>Features | LaunchPad</title>
/dashboard              <title>Dashboard | LaunchPad</title>
/projects               <title>Projects | LaunchPad</title>
/projects/website-redesign
                        <title>Website redesign | LaunchPad</title>
```

Formatting may differ, but the titles should match.

## The Verification

The preceding scripts are the primary verification.

Also confirm that route-group names remain inaccessible:

```bash
for path in \
  "/marketing" \
  "/marketing/about" \
  "/workspace/dashboard"
do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000${path}"
  )"

  printf "%-30s %s\n" "${path}" "${status_code}"
done
```

Expected output:

```text
/marketing                     404
/marketing/about               404
/workspace/dashboard           404
```

Finally, run:

```bash
npx tsc --noEmit
npm run lint
```

[GENERATED: Part 3, Step 11: Layout Composition Verification] [STARTING: Part 3, Step 12: Production Build]

---

# Step 12: Verify the Production Build

## The Target

Create and run a production build containing both nested layout trees.

## The Concept

The production build validates more than TypeScript syntax. Next.js analyzes:

- Route conflicts
- Layout hierarchy
- Metadata
- Static generation
- Dynamic route parameters
- Server and client module boundaries
- Production assets

Route groups can accidentally create conflicts if two pages resolve to the same URL.

For example, these two files would conflict:

```text
src/app/(first)/about/page.tsx
src/app/(second)/about/page.tsx
```

Both resolve to:

```text
/about
```

Our build confirms that every public URL has one unambiguous page.

## The Implementation

Stop the development server:

```text
Ctrl+C
```

Run the complete quality gate:

```bash
npx tsc --noEmit
npm run lint
npm run build
```

The build output should contain routes resembling:

```text
/
├ /about
├ /dashboard
├ /features
├ /projects
└ /projects/[projectId]
```

The route groups should not appear in the route output as URL segments.

Start the production server:

```bash
npm run start
```

## The Verification

In another terminal, run:

```bash
for path in \
  "/" \
  "/about" \
  "/features" \
  "/dashboard" \
  "/projects" \
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

Every route should return:

```text
200
```

Verify that the production dashboard receives the workspace layout:

```bash
curl --fail --silent http://localhost:3000/dashboard |
  grep --quiet "workspace-sidebar"

echo "Production workspace layout verified."
```

Expected output:

```text
Production workspace layout verified.
```

Verify that a marketing page does not receive that layout:

```bash
about_page="$(
  curl --fail --silent http://localhost:3000/about
)"

if printf "%s" "${about_page}" |
  grep --quiet "workspace-sidebar"; then
  echo "Verification failed: workspace layout appeared on /about."
  exit 1
fi

echo "Production marketing layout verified."
```

Expected output:

```text
Production marketing layout verified.
```

Stop the production server:

```text
Ctrl+C
```

[GENERATED: Part 3, Step 12: Production Build] [STARTING: Part 3, Step 13: Git Checkpoint]

---

# Step 13: Create the Part 3 Git Checkpoint

## The Target

Commit the route-group, nested-layout, and dashboard work as one verified architectural change.

## The Concept

Git may describe the route movements as deletions and additions before staging. After staging, it will often recognize them as renames.

The important result is not how Git initially displays the files. The important result is that:

- Public URLs remain stable.
- Route source files are organized by layout responsibility.
- Shared chrome is no longer duplicated.
- The project passes its production build.

## The Implementation

Inspect the working tree:

```bash
git status
```

Review the change summary:

```bash
git diff --stat
```

Review the source changes:

```bash
git diff
```

Run the final quality gate:

```bash
npx tsc --noEmit
npm run lint
npm run build
```

Stage all Part 3 changes:

```bash
git add src
```

Inspect the staged changes:

```bash
git diff --cached --stat
```

Create the commit:

```bash
git commit -m "feat: add nested marketing and workspace layouts"
```

## The Verification

Inspect the latest commit:

```bash
git log -1 --oneline
```

Expected output resembles:

```text
7a8b9c0 feat: add nested marketing and workspace layouts
```

Confirm a clean working tree:

```bash
git status
```

Expected output:

```text
nothing to commit, working tree clean
```

[GENERATED: Part 3, Step 13: Git Checkpoint] [STARTING: Part 3 Reference Sections]

---

# Part 3 Reference A: Root and Nested Layouts

The root layout is required and provides the document shell:

### `src/app/layout.tsx`

```tsx
import type { Metadata } from "next";
import type { ReactNode } from "react";

import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "LaunchPad",
    template: "%s | LaunchPad",
  },
  description:
    "A production-ready project and task management application built with Next.js 16.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
```

Only the root layout should define:

```tsx
<html>
<body>
```

Nested layouts return ordinary interface markup:

```tsx
export default function NestedLayout({
  children,
}: {
  children: ReactNode;
}) {
  return (
    <div>
      <nav>Shared navigation</nav>
      {children}
    </div>
  );
}
```

The child page must not add another `<html>` or `<body>`.

---

# Part 3 Reference B: Route Groups

A route group is a directory whose name is wrapped in parentheses:

```text
(marketing)
```

It can organize routes and apply layouts without adding a URL segment.

```text
src/app/(marketing)/about/page.tsx
```

maps to:

```text
/about
```

Route groups are useful for:

- Different layouts
- Product-area organization
- Separating public and private routes
- Organizing routes by team ownership
- Isolating loading and error boundaries

Route groups are not security boundaries.

Moving a page into:

```text
(authenticated)
```

does not authenticate it. The directory name is only an organizational and layout convention.

---

# Part 3 Reference C: Layout Persistence

During client-side navigation between pages sharing a layout, Next.js can preserve that layout instead of recreating the entire interface.

For example:

```text
/projects
/projects/website-redesign
```

share the workspace layout.

The persistent layout can retain interface state and avoid unnecessary work. This will matter more when we add interactive Client Components.

Pages represent route-specific content. Layouts represent persistent shared structure.

---

# Part 3 Reference D: Layouts Versus Templates

Layouts and templates are similar but have different lifecycle behavior.

## Layout

```text
layout.tsx
```

A layout persists across navigation among its child routes.

Use a layout for:

- Navigation
- Sidebars
- Application shells
- Persistent providers
- Shared route structure

## Template

```text
template.tsx
```

A template creates a new instance when navigation changes its child segment.

Use a template when you intentionally need:

- State reset on navigation
- Effects to rerun
- Route-transition behavior tied to remounting

LaunchPad currently needs persistent shells, so layouts are the appropriate tool.

Do not use a template merely because it resembles a layout. Choose based on lifecycle requirements.

---

# Part 3 Reference E: Component Composition

Composition means assembling components by placing one inside another.

The most common composition property is `children`:

```tsx
import type { ReactNode } from "react";

type PanelProps = {
  children: ReactNode;
};

export function Panel({ children }: PanelProps) {
  return <section className="panel">{children}</section>;
}
```

Usage:

```tsx
<Panel>
  <h2>Project summary</h2>
  <p>Four active projects</p>
</Panel>
```

The component controls the container. Its caller supplies the contents.

Composition is often preferable to creating a component with dozens of specialized configuration properties.

For example, this can become difficult to maintain:

```tsx
<Card
  title="Project summary"
  description="Four active projects"
  showProgress
  showActions
  actionPosition="bottom"
/>
```

A compositional API may be clearer:

```tsx
<Card>
  <CardHeading>Project summary</CardHeading>
  <p>Four active projects</p>
  <ProjectProgress />
  <CardActions>
    <Link href="/projects">View projects</Link>
  </CardActions>
</Card>
```

Composition keeps the container reusable without requiring it to predict every possible content arrangement.

---

# Part 3 Reference F: Layout Metadata Composition

Metadata can be declared at multiple levels of the route tree.

LaunchPad currently uses:

```text
Root layout
├── Application title template
├── Default description
│
├── Marketing layout
│   └── No additional metadata yet
│
└── Workspace layout
    └── Search-engine crawler instructions
```

A project page adds project-specific metadata:

```tsx
return {
  title: project.name,
  description: project.description,
};
```

Next.js combines that page title with the root title template:

```text
Website redesign | LaunchPad
```

The workspace layout contributes:

```tsx
robots: {
  index: false,
  follow: false,
},
```

The final project page therefore receives metadata assembled from several levels.

## Metadata is merged by field rules

Metadata composition is not identical to deeply merging arbitrary JavaScript objects. Next.js applies metadata-specific behavior.

For example, a child route can override a title while still using the root title template:

```tsx
export const metadata: Metadata = {
  title: "Projects",
};
```

Some nested object fields may replace rather than merge with values from parent segments. When several levels configure the same metadata category, verify the resulting document output rather than assuming a generic object merge.

## Absolute titles

A child route can bypass the root template with an absolute title:

```tsx
export const metadata: Metadata = {
  title: {
    absolute: "LaunchPad Status",
  },
};
```

The resulting title is:

```text
LaunchPad Status
```

rather than:

```text
LaunchPad Status | LaunchPad
```

Use absolute titles sparingly. Consistent title templates usually provide a better user experience.

## Metadata is not authorization

This declaration:

```tsx
robots: {
  index: false,
  follow: false,
},
```

asks cooperative crawlers not to index workspace routes.

It does not:

- Require a user to sign in
- Hide the route from network requests
- Prevent direct URL access
- Protect project records
- Replace server-side authorization

In Part 8, protected routes and operations will verify user identity and permissions on the server.

---

# Part 3 Reference G: Shared UI Placement

A component should live at the narrowest shared boundary that accurately owns it.

## Root layout

Place an element in the root layout only when every route should receive it.

Appropriate examples include:

- `<html>` and `<body>`
- Global styles
- Truly application-wide providers
- Global accessibility infrastructure

Our root layout intentionally does not render the public header because future sign-in pages may need a different shell.

## Route-group layout

Use a route-group layout when one category of routes shares a shell.

Examples in LaunchPad:

```text
(marketing)/layout.tsx
```

owns:

- Public navigation
- Marketing footer
- Public application shell

```text
(workspace)/layout.tsx
```

owns:

- Workspace navigation
- Workspace grid
- Workspace footer
- Workspace crawler metadata

## Page

A page should own route-specific content.

Examples include:

- About-page copy
- Project filtering
- Dashboard statistics
- Project details

## Reusable component

Create a reusable component when a meaningful interface responsibility appears in several locations or deserves an isolated API.

Examples include:

```text
SiteHeader
SiteFooter
WorkspaceNavigation
```

Do not extract every small JSX fragment merely to reduce line count. Extraction should improve responsibility, reuse, testing, readability, or boundaries.

---

# Part 3 Reference H: Route Groups and URL Conflicts

Route groups do not participate in public URLs.

These files conflict:

```text
src/app/(marketing)/about/page.tsx
src/app/(workspace)/about/page.tsx
```

Both attempt to create:

```text
/about
```

The group names do not make the URLs distinct.

To create distinct URLs, add ordinary route segments:

```text
src/app/(marketing)/about/page.tsx
→ /about

src/app/(workspace)/settings/about/page.tsx
→ /settings/about
```

A production build is an important check because Next.js analyzes the complete route tree and can report ambiguous route definitions.

## Multiple root layouts

Advanced applications can define multiple root layouts by omitting a top-level root layout and placing root layouts inside separate route groups.

For example:

```text
app/
├── (marketing)/
│   ├── layout.tsx
│   └── page.tsx
└── (application)/
    ├── layout.tsx
    └── dashboard/
        └── page.tsx
```

Each root layout must include `<html>` and `<body>`.

Navigating between routes using different root layouts may trigger a full page load. LaunchPad does not need that architecture. One root document layout with nested group layouts is simpler and preserves a consistent application boundary.

---

# Part 3 Reference I: Why the Layouts Remain Server Components

None of our layout files contain:

```tsx
"use client";
```

They are Server Components by default.

That allows them to:

- Compose server-rendered child routes
- Export metadata
- Avoid adding layout implementation code to the browser bundle
- Safely grow to include server-side operations where appropriate
- Keep client-side JavaScript focused on interactive islands

The current navigation uses ordinary Next.js links and does not need browser hooks.

In Part 4, we will add a Client Component for active-route awareness. The interactive boundary will be placed around the navigation behavior that needs the current pathname rather than around the entire workspace layout.

That distinction matters because adding `"use client"` to a layout would pull its imported component tree into the client module graph and would prevent the layout from exporting static metadata.

---

# Part 3 Reference J: The `children` Property

The `children` property is supplied by React and represents content nested inside a component.

A layout type commonly looks like this:

```tsx
import type { ReactNode } from "react";

type LayoutProps = Readonly<{
  children: ReactNode;
}>;
```

`ReactNode` is broad enough to represent renderable React content, including:

- Elements
- Text
- Numbers
- Arrays of nodes
- `null`
- Nested component output

A layout renders it at the point where the active child route should appear:

```tsx
export default function Layout({ children }: LayoutProps) {
  return (
    <div>
      <header>Shared header</header>
      <main>{children}</main>
    </div>
  );
}
```

In LaunchPad, child pages already render their own semantic `<main>` elements. Therefore, our group layouts use ordinary `<div>` containers around `{children}` rather than adding another `<main>`.

A document should generally have one primary `<main>` landmark. Avoid wrapping a page’s `<main>` inside a second `<main>`.

---

# Part 3 Reference K: Semantic Landmarks

Semantic landmarks identify major regions of a page.

LaunchPad uses:

| Element | Purpose |
|---|---|
| `<header>` | Introductory or navigational content |
| `<nav>` | A collection of navigation links |
| `<main>` | The page’s primary content |
| `<aside>` | Supporting content adjacent to primary content |
| `<footer>` | Closing information for a page or application |
| `<section>` | A named thematic content group |
| `<article>` | A self-contained item |

Landmarks help assistive-technology users move between major regions.

## Labels distinguish repeated landmarks

A page can have multiple navigation regions. Each should have a useful accessible label:

```tsx
<nav aria-label="Primary navigation">
```

```tsx
<nav aria-label="Workspace navigation">
```

```tsx
<nav aria-label="Breadcrumb">
```

The labels let a screen-reader user distinguish among them.

## Headings name sections

A section should usually have an accessible name:

```tsx
<section aria-labelledby="active-projects-heading">
  <h2 id="active-projects-heading">Active projects</h2>
</section>
```

The `aria-labelledby` value refers to the heading’s `id`.

## Visual layout does not determine semantic structure

A CSS sidebar does not have to be an `<aside>`, and an `<aside>` does not have to appear visually on the side.

Choose semantic elements based on meaning. Use CSS for visual placement.

---

# Part 3 Reference L: Sticky Positioning

The workspace navigation uses:

```css
.workspace-navigation {
  position: sticky;
  top: 6.5rem;
}
```

Sticky positioning behaves like a combination of relative and fixed positioning:

1. The element begins in normal document flow.
2. It scrolls with its container.
3. When it reaches the specified offset, it remains at that position.
4. It stays constrained by its containing block.

Sticky positioning can fail to behave as expected when ancestor elements use certain overflow settings. If a sticky element does not stick, inspect parent containers for declarations such as:

```css
overflow: hidden;
overflow: auto;
overflow: scroll;
```

Our narrow-screen media query removes sticky behavior because the navigation becomes a horizontal row:

```css
@media (max-width: 48rem) {
  .workspace-navigation {
    position: static;
  }
}
```

Responsive design should change behavior when the wider-screen interaction no longer fits the available space.

---

# Part 3 Reference M: Current Project Structure

After Part 3, the important source structure is:

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
│   ├── favicon.ico
│   ├── globals.css
│   ├── layout.tsx
│   └── not-found.tsx
├── components/
│   ├── site-footer.tsx
│   ├── site-header.tsx
│   └── workspace-navigation.tsx
└── lib/
    └── project-catalog.ts
```

The source layout tree is:

```text
src/app/layout.tsx
├── src/app/(marketing)/layout.tsx
│   ├── src/app/(marketing)/page.tsx
│   ├── src/app/(marketing)/about/page.tsx
│   └── src/app/(marketing)/features/page.tsx
│
└── src/app/(workspace)/layout.tsx
    ├── src/app/(workspace)/dashboard/page.tsx
    ├── src/app/(workspace)/projects/page.tsx
    └── src/app/(workspace)/projects/[projectId]/page.tsx
```

The public URL tree remains:

```text
/
├── /about
├── /features
├── /dashboard
└── /projects
    └── /projects/:projectId
```

The names `(marketing)` and `(workspace)` never appear in those URLs.

---

# Part 3 Reference N: Common Layout Mistakes

## Mistake 1: Rendering `<html>` in a nested layout

Incorrect:

```tsx
export default function MarketingLayout({
  children,
}: {
  children: ReactNode;
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
```

Only the root layout in our architecture owns the document elements.

Correct:

```tsx
export default function MarketingLayout({
  children,
}: {
  children: ReactNode;
}) {
  return <div className="application-shell">{children}</div>;
}
```

## Mistake 2: Repeating shared UI in every page

Incorrect page structure:

```tsx
export default function AboutPage() {
  return (
    <>
      <SiteHeader />
      <main>About content</main>
      <SiteFooter />
    </>
  );
}
```

When the surrounding layout already supplies those elements, the page should return only its route-specific content:

```tsx
export default function AboutPage() {
  return <main>About content</main>;
}
```

## Mistake 3: Expecting route groups in the URL

This file:

```text
src/app/(workspace)/dashboard/page.tsx
```

does not create:

```text
/workspace/dashboard
```

It creates:

```text
/dashboard
```

## Mistake 4: Treating route groups as access control

A route group named:

```text
(private)
```

does not make its routes private.

Security requires server-side authentication and authorization.

## Mistake 5: Marking an entire layout as a Client Component

Avoid adding:

```tsx
"use client";
```

merely because one nested navigation item needs browser state.

Prefer a small Client Component boundary around the interactive portion. We will implement that architecture in Part 4.

## Mistake 6: Creating nested `<main>` landmarks

If a page already renders:

```tsx
<main>{/* route content */}</main>
```

the layout should not wrap it in another `<main>`.

Use a neutral container:

```tsx
<div>{children}</div>
```

## Mistake 7: Defining the same URL in two groups

These conflict:

```text
(marketing)/settings/page.tsx
(workspace)/settings/page.tsx
```

Both produce:

```text
/settings
```

Use ordinary segments when URLs must differ.

---

# Part 3 Completion Checklist

Before continuing, confirm every item:

- [ ] The root layout contains the shared document shell.
- [ ] Marketing routes live inside `(marketing)`.
- [ ] Workspace routes live inside `(workspace)`.
- [ ] Route-group names do not appear in public URLs.
- [ ] `/`, `/about`, and `/features` use the marketing layout.
- [ ] `/dashboard` and `/projects` use the workspace layout.
- [ ] Dynamic project pages inherit the workspace layout.
- [ ] Every route displays only one site header.
- [ ] Every route displays only one site footer.
- [ ] Marketing pages do not display workspace navigation.
- [ ] Workspace pages display workspace navigation.
- [ ] `/dashboard` displays the expected catalog totals.
- [ ] Existing project filtering still works.
- [ ] Existing dynamic project routes still work.
- [ ] Missing projects still return `404`.
- [ ] Workspace routes emit `noindex` and `nofollow` crawler metadata.
- [ ] The workspace becomes a single-column layout on narrow screens.
- [ ] Keyboard focus remains visible throughout navigation.
- [ ] `npx tsc --noEmit` succeeds.
- [ ] `npm run lint` succeeds.
- [ ] `npm run build` succeeds.
- [ ] Production route verification succeeds.
- [ ] Git contains the Part 3 checkpoint.
- [ ] `git status` reports a clean working tree.

You now understand how Next.js composes root and nested layouts, how route groups organize source code without changing URLs, and how shared components create clear interface boundaries.
