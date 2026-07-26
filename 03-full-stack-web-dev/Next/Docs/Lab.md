# LaunchPad: Lab Book

## From Zero to Production with Next.js 16

---

## Lab 1: Project Setup and Initial Application

### Objectives
- Create a Next.js 16 application
- Understand the project structure
- Replace the starter page with LaunchPad's home page
- Configure global CSS
- Verify development and production builds

### Setup Commands

```bash
# Verify prerequisites
node --version  # Should be v20.9.0+
npm --version
git --version

# Create project
npx create-next-app@16 launchpad --typescript --eslint --app --src-dir --no-tailwind --turbopack --import-alias "@/*" --use-npm --yes

# Navigate to project
cd launchpad

# Start development server
npm run dev
```

### Lab Tasks

**Task 1.1: Examine Project Structure**
```bash
# List all files (excluding node_modules and .git)
find . -maxdepth 3 -type f -not -path "./node_modules/*" -not -path "./.git/*" | sort
```

**Task 1.2: Replace Root Layout**

Create `src/app/layout.tsx`:

```tsx
import type { Metadata } from "next";
import type { ReactNode } from "react";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "LaunchPad",
    template: "%s | LaunchPad",
  },
  description: "A production-ready project and task management application built with Next.js 16.",
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

**Task 1.3: Create the Home Page**

Create `src/app/page.tsx`:

```tsx
const plannedFeatures = [
  {
    title: "Organize projects",
    description: "Create focused project spaces with clear descriptions, statuses, and ownership.",
  },
  {
    title: "Track meaningful work",
    description: "Break projects into tasks, set priorities, and follow progress from one dashboard.",
  },
  {
    title: "Work securely",
    description: "Protect private data with server-side authentication, authorization, and validation.",
  },
] as const;

export default function HomePage() {
  return (
    <main className="site-shell">
      <section className="hero" aria-labelledby="hero-heading">
        <p className="eyebrow">Built with Next.js 16</p>
        <h1 id="hero-heading">Turn ambitious ideas into organized work.</h1>
        <p className="hero-description">
          LaunchPad is a secure project and task management application. Over
          this series, this simple page will grow into a complete full-stack
          product.
        </p>
        <a className="primary-link" href="#planned-features">
          Explore the plan
        </a>
      </section>

      <section
        className="feature-section"
        id="planned-features"
        aria-labelledby="features-heading"
      >
        <div className="section-heading">
          <p className="eyebrow">Our destination</p>
          <h2 id="features-heading">Everything needed to move work forward</h2>
          <p>
            These features are not active yet. We will implement and verify
            them one layer at a time throughout the series.
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

      <footer className="site-footer">
        <p>LaunchPad · From Zero to Production with Next.js 16</p>
      </footer>
    </main>
  );
}
```

**Task 1.4: Configure Global CSS**

Replace `src/app/globals.css` with the complete styles from the tutorial.

**Task 1.5: Verify the Application**

```bash
# Type check
npx tsc --noEmit

# Lint
npm run lint

# Build
npm run build

# Start production server
npm run start
```

### Lab Verification Checklist

- [ ] `npm run dev` starts without errors
- [ ] `http://localhost:3000` shows LaunchPad page
- [ ] Browser title is "LaunchPad"
- [ ] Page is responsive on narrow screens
- [ ] Keyboard focus is visible
- [ ] `npx tsc --noEmit` succeeds
- [ ] `npm run lint` succeeds
- [ ] `npm run build` succeeds
- [ ] `npm run start` serves the production build
- [ ] Git commit created

### Lab Results

```
[Document your observations here]
```

---

## Lab 2: Routing and Pages

### Objectives
- Create static and dynamic routes
- Implement navigation with `next/link`
- Handle search parameters
- Create dynamic project detail pages
- Implement custom not-found handling

### Lab Tasks

**Task 2.1: Create the Project Catalog**

Create `src/lib/project-catalog.ts`:

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

const PROJECT_CATALOG = [
  {
    id: "website-redesign",
    name: "Website redesign",
    description: "Refresh the marketing website with clearer messaging, faster pages, and an accessible component system.",
    status: "ACTIVE",
    taskCount: 12,
    completedTaskCount: 5,
  },
  {
    id: "mobile-application",
    name: "Mobile application",
    description: "Plan and deliver the first mobile experience for customers who manage work away from their desks.",
    status: "PLANNED",
    taskCount: 8,
    completedTaskCount: 0,
  },
  {
    id: "documentation-hub",
    name: "Documentation hub",
    description: "Create a searchable home for product guides, engineering standards, and onboarding material.",
    status: "COMPLETED",
    taskCount: 16,
    completedTaskCount: 16,
  },
  {
    id: "analytics-dashboard",
    name: "Analytics dashboard",
    description: "Build a shared dashboard that turns product activity into clear and actionable insights.",
    status: "ACTIVE",
    taskCount: 10,
    completedTaskCount: 3,
  },
] as const satisfies readonly ProjectSummary[];

export function getAllProjects(): readonly ProjectSummary[] {
  return PROJECT_CATALOG;
}

export function getProjectById(projectId: string): ProjectSummary | undefined {
  return PROJECT_CATALOG.find((project) => project.id === projectId);
}

export function getProjectsByStatus(status: ProjectStatus): readonly ProjectSummary[] {
  return PROJECT_CATALOG.filter((project) => project.status === status);
}

export function isProjectStatus(value: string): value is ProjectStatus {
  return PROJECT_STATUSES.some((status) => status === value);
}

export function formatProjectStatus(status: ProjectStatus): string {
  return `${status.charAt(0)}${status.slice(1).toLowerCase()}`;
}

export function calculateProjectProgress(project: ProjectSummary): number {
  if (project.taskCount === 0) {
    return 0;
  }
  return Math.round((project.completedTaskCount / project.taskCount) * 100);
}
```

**Task 2.2: Create the Site Header**

Create `src/components/site-header.tsx`:

```tsx
import Link from "next/link";

const navigationItems = [
  { href: "/", label: "Home" },
  { href: "/about", label: "About" },
  { href: "/features", label: "Features" },
  { href: "/projects", label: "Projects" },
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

**Task 2.3: Create Static Pages**

Create `src/app/about/page.tsx` and `src/app/features/page.tsx` using the tutorial content.

**Task 2.4: Create the Project List Page**

Create `src/app/projects/page.tsx`:

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
  description: "Browse and filter the temporary LaunchPad project catalog.",
};

type ProjectsPageProps = {
  searchParams: Promise<{
    status?: string | string[];
  }>;
};

function readStatusFilter(value: string | string[] | undefined): ProjectStatus | undefined {
  if (typeof value !== "string") return undefined;
  const normalizedValue = value.toUpperCase();
  return isProjectStatus(normalizedValue) ? normalizedValue : undefined;
}

export default async function ProjectsPage({ searchParams }: ProjectsPageProps) {
  const query = await searchParams;
  const requestedStatus = query.status;
  const selectedStatus = readStatusFilter(requestedStatus);
  const hasInvalidStatus = requestedStatus !== undefined && selectedStatus === undefined;

  const projects = selectedStatus ? getProjectsByStatus(selectedStatus) : getAllProjects();

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

        <section className="filter-panel" aria-labelledby="filter-heading">
          <div>
            <h2 id="filter-heading">Filter projects</h2>
            <p>The selected status is stored in the URL so this view can be bookmarked or shared.</p>
          </div>
          <form action="/projects" method="get" className="filter-form">
            <label htmlFor="status">Project status</label>
            <div className="filter-controls">
              <select id="status" name="status" defaultValue={selectedStatus ?? ""}>
                <option value="">All statuses</option>
                {PROJECT_STATUSES.map((status) => (
                  <option key={status} value={status}>
                    {formatProjectStatus(status)}
                  </option>
                ))}
              </select>
              <button className="primary-button" type="submit">Apply filter</button>
            </div>
          </form>
        </section>

        {hasInvalidStatus ? (
          <div className="notice notice--warning" role="status">
            <p>The requested status is not supported. Showing all projects instead.</p>
          </div>
        ) : null}

        <section aria-labelledby="project-results-heading">
          <div className="results-heading">
            <div>
              <p className="eyebrow">Results</p>
              <h2 id="project-results-heading">
                {selectedStatus ? `${formatProjectStatus(selectedStatus)} projects` : "All projects"}
              </h2>
            </div>
            <p>{projects.length} {projects.length === 1 ? "project" : "projects"}</p>
          </div>

          {projects.length > 0 ? (
            <div className="project-grid">
              {projects.map((project) => {
                const progress = calculateProjectProgress(project);
                return (
                  <article className="project-card" key={project.id}>
                    <div className="project-card__heading">
                      <h3><Link href={`/projects/${project.id}`}>{project.name}</Link></h3>
                      <span className={`status-badge status-badge--${project.status.toLowerCase()}`}>
                        {formatProjectStatus(project.status)}
                      </span>
                    </div>
                    <p>{project.description}</p>
                    <div className="progress-summary">
                      <div className="progress-summary__labels">
                        <span>Task progress</span>
                        <span>{progress}%</span>
                      </div>
                      <progress max={100} value={progress} aria-label={`${project.name} task completion`}>
                        {progress}%
                      </progress>
                      <p>{project.completedTaskCount} of {project.taskCount} tasks completed</p>
                    </div>
                    <Link className="text-link" href={`/projects/${project.id}`}>
                      View project details <span aria-hidden="true">→</span>
                    </Link>
                  </article>
                );
              })}
            </div>
          ) : (
            <div className="empty-state">
              <h3>No projects matched this filter</h3>
              <p>Choose another status to see available projects.</p>
              <Link className="secondary-link" href="/projects">Clear filter</Link>
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

**Task 2.5: Create Dynamic Project Page**

Create `src/app/projects/[projectId]/page.tsx`:

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
  params: Promise<{ projectId: string }>;
};

export function generateStaticParams() {
  return getAllProjects().map((project) => ({
    projectId: project.id,
  }));
}

export async function generateMetadata({ params }: ProjectPageProps): Promise<Metadata> {
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

export default async function ProjectPage({ params }: ProjectPageProps) {
  const { projectId } = await params;
  const project = getProjectById(projectId);
  if (!project) notFound();

  const progress = calculateProjectProgress(project);
  const remainingTaskCount = project.taskCount - project.completedTaskCount;

  return (
    <>
      <SiteHeader />
      <main className="site-shell page-content">
        <nav className="breadcrumb" aria-label="Breadcrumb">
          <ol>
            <li><Link href="/">Home</Link></li>
            <li aria-hidden="true">/</li>
            <li><Link href="/projects">Projects</Link></li>
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
            <span className={`status-badge status-badge--${project.status.toLowerCase()}`}>
              {formatProjectStatus(project.status)}
            </span>
          </header>

          <section className="project-stat-grid" aria-label="Project statistics">
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

          <section className="detail-progress" aria-labelledby="progress-heading">
            <div className="progress-summary__labels">
              <h2 id="progress-heading">Task completion</h2>
              <span>{progress}%</span>
            </div>
            <progress max={100} value={progress} aria-label={`${project.name} task completion`}>
              {progress}%
            </progress>
            <p>{project.completedTaskCount} of {project.taskCount} tasks are complete.</p>
          </section>
        </article>
        <Link className="secondary-link" href="/projects">
          <span aria-hidden="true">← </span>Return to all projects
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

**Task 2.6: Create Not-Found Page**

Create `src/app/not-found.tsx`:

```tsx
import Link from "next/link";
import { SiteHeader } from "@/components/site-header";

export default function NotFoundPage() {
  return (
    <>
      <SiteHeader />
      <main className="site-shell not-found-page">
        <div className="not-found-content">
          <p className="error-code" aria-hidden="true">404</p>
          <p className="eyebrow">Page not found</p>
          <h1>We could not find that destination.</h1>
          <p>The address may be incorrect, or the requested resource may no longer exist.</p>
          <div className="hero-actions">
            <Link className="primary-link" href="/">Return home</Link>
            <Link className="secondary-link" href="/projects">Browse projects</Link>
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

### Lab Verification

```bash
# Test all routes
for path in "/" "/about" "/features" "/projects" "/projects?status=ACTIVE" "/projects/website-redesign"; do
  curl -s -o /dev/null -w "%{http_code} %{url}\n" "http://localhost:3000$path"
done

# Test 404
curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/does-not-exist

# Production build
npm run build && npm run start
```

### Lab Results

```
[Document your route testing results here]
```

---

## Lab 3: Layouts and UI Composition

### Objectives
- Create route groups for marketing and workspace areas
- Build nested layouts
- Extract reusable components
- Create the dashboard page
- Implement responsive workspace layout

### Lab Tasks

**Task 3.1: Create Route Groups**

```bash
mkdir -p src/app/\(marketing\)
mkdir -p src/app/\(workspace\)
mv src/app/page.tsx src/app/\(marketing\)/
mv src/app/about src/app/\(marketing\)/
mv src/app/features src/app/\(marketing\)/
mv src/app/projects src/app/\(workspace\)/
```

**Task 3.2: Create Shared Footer**

Create `src/components/site-footer.tsx`:

```tsx
type SiteFooterProps = {
  message?: string;
};

export function SiteFooter({ message = "From Zero to Production with Next.js 16" }: SiteFooterProps) {
  return (
    <footer className="site-footer">
      <div className="site-shell">
        <p>LaunchPad<span aria-hidden="true"> · </span>{message}</p>
      </div>
    </footer>
  );
}
```

**Task 3.3: Create Marketing Layout**

Create `src/app/(marketing)/layout.tsx`:

```tsx
import type { ReactNode } from "react";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";

type MarketingLayoutProps = Readonly<{ children: ReactNode }>;

export default function MarketingLayout({ children }: MarketingLayoutProps) {
  return (
    <div className="application-shell">
      <SiteHeader />
      <div className="application-shell__content">{children}</div>
      <SiteFooter message="Built one verified layer at a time" />
    </div>
  );
}
```

**Task 3.4: Create Workspace Navigation**

Create `src/components/workspace-navigation.tsx`:

```tsx
import Link from "next/link";

const workspaceLinks = [
  { href: "/dashboard", label: "Overview", description: "Workspace summary" },
  { href: "/projects", label: "Projects", description: "Browse current work" },
] as const;

export function WorkspaceNavigation() {
  return (
    <nav className="workspace-navigation" aria-label="Workspace navigation">
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

**Task 3.5: Create Workspace Layout**

Create `src/app/(workspace)/layout.tsx`:

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

type WorkspaceLayoutProps = Readonly<{ children: ReactNode }>;

export default function WorkspaceLayout({ children }: WorkspaceLayoutProps) {
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

**Task 3.6: Refactor Marketing Pages**

Replace each marketing page content to remove the duplicated header and footer. Keep only the route-specific content inside `<main>`.

**Task 3.7: Create Dashboard**

Create `src/app/(workspace)/dashboard/page.tsx`:

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
  description: "View a summary of projects and task progress in the LaunchPad workspace.",
};

export default function DashboardPage() {
  const projects = getAllProjects();
  const activeProjects = getProjectsByStatus("ACTIVE");

  const totalTaskCount = projects.reduce((total, project) => total + project.taskCount, 0);
  const completedTaskCount = projects.reduce((total, project) => total + project.completedTaskCount, 0);
  const overallProgress = totalTaskCount === 0 ? 0 : Math.round((completedTaskCount / totalTaskCount) * 100);

  return (
    <main className="site-shell page-content">
      <header className="page-heading dashboard-heading">
        <div>
          <p className="eyebrow">Workspace overview</p>
          <h1>Good work starts with a clear view.</h1>
          <p>This dashboard summarizes the temporary project catalog.</p>
        </div>
        <Link className="primary-link" href="/projects">View all projects</Link>
      </header>

      <section className="dashboard-stat-grid" aria-label="Workspace statistics">
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

      <section className="dashboard-section" aria-labelledby="active-projects-heading">
        <div className="results-heading">
          <div>
            <p className="eyebrow">Current focus</p>
            <h2 id="active-projects-heading">Active projects</h2>
          </div>
          <Link className="text-link" href="/projects?status=ACTIVE">
            View filtered list <span aria-hidden="true">→</span>
          </Link>
        </div>
        <div className="project-grid">
          {activeProjects.map((project) => {
            const progress = calculateProjectProgress(project);
            return (
              <article className="project-card" key={project.id}>
                <div className="project-card__heading">
                  <h3><Link href={`/projects/${project.id}`}>{project.name}</Link></h3>
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
                  <progress max={100} value={progress} aria-label={`${project.name} task completion`}>
                    {progress}%
                  </progress>
                  <p>{project.completedTaskCount} of {project.taskCount} tasks completed</p>
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

### Lab Verification

```bash
# Test layout hierarchy
for path in "/" "/about" "/features" "/dashboard" "/projects" "/projects/website-redesign"; do
  curl -s "http://localhost:3000$path" | grep -q "site-header" && echo "✓ $path has header"
  curl -s "http://localhost:3000$path" | grep -q "site-footer" && echo "✓ $path has footer"
done

# Verify workspace routes have sidebar
for path in "/dashboard" "/projects"; do
  curl -s "http://localhost:3000$path" | grep -q "workspace-sidebar" && echo "✓ $path has sidebar"
done

# Verify marketing routes don't have sidebar
for path in "/" "/about" "/features"; do
  curl -s "http://localhost:3000$path" | grep -q "workspace-sidebar" && echo "✗ $path has sidebar" || echo "✓ $path has no sidebar"
done
```

### Lab Results

```
[Document your layout verification results here]
```

---

## Lab 4: Server and Client Components

### Objectives
- Protect server-only modules
- Create shared types for cross-boundary use
- Implement active navigation with `usePathname`
- Build interactive project search
- Create disclosure components
- Implement clipboard copy functionality

### Lab Tasks

**Task 4.1: Install server-only Package**

```bash
npm install server-only
```

**Task 4.2: Create Shared Project Types**

Create `src/lib/project-types.ts`:

```ts
export const PROJECT_STATUSES = ["PLANNED", "ACTIVE", "COMPLETED"] as const;
export type ProjectStatus = (typeof PROJECT_STATUSES)[number];

export type ProjectSummary = {
  id: string;
  name: string;
  description: string;
  status: ProjectStatus;
  taskCount: number;
  completedTaskCount: number;
};

export function isProjectStatus(value: string): value is ProjectStatus {
  return PROJECT_STATUSES.some((status) => status === value);
}

export function formatProjectStatus(status: ProjectStatus): string {
  return `${status.charAt(0)}${status.slice(1).toLowerCase()}`;
}

export function calculateProjectProgress(project: ProjectSummary): number {
  if (project.taskCount === 0) return 0;
  return Math.round((project.completedTaskCount / project.taskCount) * 100);
}
```

**Task 4.3: Update Project Catalog to Server-Only**

Update `src/lib/project-catalog.ts` to import `server-only` and re-export types.

**Task 4.4: Create Active Workspace Navigation**

Update `src/components/workspace-navigation.tsx`:

```tsx
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const workspaceLinks = [
  { href: "/dashboard", label: "Overview", description: "Workspace summary" },
  { href: "/projects", label: "Projects", description: "Browse current work" },
] as const;

function isLinkActive(pathname: string, href: string): boolean {
  if (href === "/dashboard") return pathname === href;
  return pathname === href || pathname.startsWith(`${href}/`);
}

export function WorkspaceNavigation() {
  const pathname = usePathname();
  return (
    <nav className="workspace-navigation" aria-label="Workspace navigation">
      <p className="workspace-navigation__label">Workspace</p>
      <ul>
        {workspaceLinks.map((link) => {
          const isActive = isLinkActive(pathname, link.href);
          return (
            <li key={link.href}>
              <Link
                className={isActive ? "workspace-navigation__link workspace-navigation__link--active" : "workspace-navigation__link"}
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

**Task 4.5: Create Interactive Project List**

Create `src/components/project-list.tsx`:

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

export function ProjectList({ projects, heading }: ProjectListProps) {
  const [query, setQuery] = useState("");
  const normalizedQuery = query.trim().toLocaleLowerCase();

  const visibleProjects = useMemo(() => {
    if (normalizedQuery.length === 0) return projects;
    return projects.filter((project) => {
      const searchableText = [project.name, project.description, formatProjectStatus(project.status)]
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
          <p>Search updates immediately without requesting another page.</p>
        </div>
        <div className="client-search__control">
          <input
            id="project-search"
            type="search"
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Search by name or description"
            autoComplete="off"
          />
          {query.length > 0 ? (
            <button className="clear-button" type="button" onClick={() => setQuery("")}>
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
          {visibleProjects.length} {visibleProjects.length === 1 ? "project" : "projects"}
        </p>
      </div>

      {visibleProjects.length > 0 ? (
        <div className="project-grid">
          {visibleProjects.map((project) => {
            const progress = calculateProjectProgress(project);
            return (
              <article className="project-card" key={project.id}>
                <div className="project-card__heading">
                  <h3><Link href={`/projects/${project.id}`}>{project.name}</Link></h3>
                  <span className={`status-badge status-badge--${project.status.toLowerCase()}`}>
                    {formatProjectStatus(project.status)}
                  </span>
                </div>
                <p>{project.description}</p>
                <div className="progress-summary">
                  <div className="progress-summary__labels">
                    <span>Task progress</span>
                    <span>{progress}%</span>
                  </div>
                  <progress max={100} value={progress} aria-label={`${project.name} task completion`}>
                    {progress}%
                  </progress>
                  <p>{project.completedTaskCount} of {project.taskCount} tasks completed</p>
                </div>
                <Link className="text-link" href={`/projects/${project.id}`}>
                  View project details <span aria-hidden="true">→</span>
                </Link>
              </article>
            );
          })}
        </div>
      ) : (
        <div className="empty-state">
          <h3>No projects matched your search</h3>
          <p>Try another project name, description, or status.</p>
          <button className="secondary-button" type="button" onClick={() => setQuery("")}>
            Clear search
          </button>
        </div>
      )}
    </section>
  );
}
```

**Task 4.6: Create Interactive Disclosure**

Create `src/components/interactive-disclosure.tsx`:

```tsx
"use client";

import { useId, useState, type ReactNode } from "react";

type InteractiveDisclosureProps = {
  children: ReactNode;
  title: string;
  initiallyOpen?: boolean;
};

export function InteractiveDisclosure({ children, title, initiallyOpen = false }: InteractiveDisclosureProps) {
  const [isOpen, setIsOpen] = useState(initiallyOpen);
  const contentId = useId();

  return (
    <section className="disclosure">
      <button
        className="disclosure__trigger"
        type="button"
        aria-expanded={isOpen}
        aria-controls={contentId}
        onClick={() => setIsOpen((current) => !current)}
      >
        <span>{title}</span>
        <span aria-hidden="true">{isOpen ? "−" : "+"}</span>
      </button>
      <div className="disclosure__content" id={contentId} hidden={!isOpen}>
        {children}
      </div>
    </section>
  );
}
```

**Task 4.7: Create Copy Link Component**

Create `src/components/copy-project-link.tsx`:

```tsx
"use client";

import { useState } from "react";

type CopyStatus = "idle" | "success" | "error";

type CopyProjectLinkProps = {
  projectName: string;
};

export function CopyProjectLink({ projectName }: CopyProjectLinkProps) {
  const [status, setStatus] = useState<CopyStatus>("idle");

  async function copyCurrentUrl(): Promise<void> {
    try {
      if (!navigator.clipboard) throw new Error("The Clipboard API is unavailable.");
      await navigator.clipboard.writeText(window.location.href);
      setStatus("success");
    } catch {
      setStatus("error");
    }
  }

  return (
    <div className="copy-link-control">
      <button className="secondary-button" type="button" onClick={copyCurrentUrl}>
        Copy project link
      </button>
      <p
        className={status === "error" ? "copy-link-control__status copy-link-control__status--error" : "copy-link-control__status"}
        role="status"
        aria-live="polite"
      >
        {status === "success" ? `Link to ${projectName} copied.` : null}
        {status === "error" ? "The link could not be copied. Copy it from the address bar instead." : null}
      </p>
    </div>
  );
}
```

### Lab Verification

```bash
# Verify server-only protection
grep -R '"use client"' src/components --include="*.tsx"
# Expected: only client components have the directive

# Verify Client Components don't import catalog
grep -R 'project-catalog' src/components --include="*.tsx" || echo "✓ No client imports catalog"

# Verify active navigation works
curl -s http://localhost:3000/dashboard | grep -q "workspace-navigation__link--active" && echo "✓ Dashboard active"
curl -s http://localhost:3000/projects | grep -q "workspace-navigation__link--active" && echo "✓ Projects active"
```

### Lab Results

```
[Document your client component verification here]
```

---

## Lab 5: Data Fetching in Next.js 16

### Objectives
- Configure PostgreSQL with Docker
- Create database migrations
- Seed development data
- Validate environment variables
- Build a database client
- Create query functions
- Replace catalog data with database queries
- Implement streaming with Suspense
- Add loading and error boundaries

### Lab Tasks

**Task 5.1: Start PostgreSQL with Docker**

Create `compose.yaml`:

```yaml
services:
  db:
    image: postgres:17-alpine
    container_name: launchpad-postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: launchpad
      POSTGRES_USER: launchpad
      POSTGRES_PASSWORD: launchpad-development-password
    ports:
      - "5432:5432"
    volumes:
      - launchpad-postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready --username=launchpad --dbname=launchpad"]
      interval: 5s
      timeout: 5s
      retries: 10
      start_period: 5s

volumes:
  launchpad-postgres-data:
```

**Task 5.2: Install Database Dependencies**

```bash
npm install postgres zod
```

**Task 5.3: Create Database Migration**

Create `database/migrations/001_create_projects_and_tasks.sql`:

```sql
BEGIN;

CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(120) NOT NULL,
  description TEXT NOT NULL,
  status VARCHAR(20) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT projects_name_not_blank CHECK (length(trim(name)) > 0),
  CONSTRAINT projects_description_not_blank CHECK (length(trim(description)) > 0),
  CONSTRAINT projects_status_allowed CHECK (status IN ('PLANNED', 'ACTIVE', 'COMPLETED'))
);

CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL,
  title VARCHAR(160) NOT NULL,
  description TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'TODO',
  priority VARCHAR(20) NOT NULL DEFAULT 'MEDIUM',
  due_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT tasks_project_foreign_key FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
  CONSTRAINT tasks_title_not_blank CHECK (length(trim(title)) > 0),
  CONSTRAINT tasks_status_allowed CHECK (status IN ('TODO', 'IN_PROGRESS', 'COMPLETED')),
  CONSTRAINT tasks_priority_allowed CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH'))
);

CREATE INDEX projects_status_index ON projects(status);
CREATE INDEX projects_created_at_index ON projects(created_at DESC);
CREATE INDEX tasks_project_id_index ON tasks(project_id);
CREATE INDEX tasks_project_status_index ON tasks(project_id, status);

COMMIT;
```

**Task 5.4: Create Seed Data**

Create `database/seeds/development.sql` with 4 projects and 12 tasks.

**Task 5.5: Create Environment Configuration**

Create `.env.example` and `.env.local`:

```dotenv
DATABASE_URL=postgresql://launchpad:launchpad-development-password@localhost:5432/launchpad
```

Create `src/lib/environment.ts` for validation.

**Task 5.6: Create Database Client**

Create `src/lib/database/client.ts`.

**Task 5.7: Create Schema Validation**

Create `src/lib/database/schemas.ts`.

**Task 5.8: Create Query Functions**

Create `src/lib/database/project-queries.ts`.

**Task 5.9: Update Pages to Use Database**

Replace the project list and detail pages to use database queries.

**Task 5.10: Add Streaming Dashboard**

Create dashboard components with Suspense boundaries.

**Task 5.11: Add Loading and Error Boundaries**

Create `src/app/(workspace)/dashboard/loading.tsx`, `src/app/(workspace)/projects/loading.tsx`, and `src/app/(workspace)/error.tsx`.

### Lab Commands

```bash
# Start database
npm run db:start

# Apply migrations
npm run db:migrate

# Seed data
npm run db:seed

# Verify database
docker compose exec db psql --username=launchpad --dbname=launchpad --command="SELECT COUNT(*) FROM projects;"

# Run application
npm run dev

# Test with database failure
npm run db:stop
# Visit /projects - should show error boundary
npm run db:start
```

### Lab Results

```
[Document your database testing here]
```

---

## Lab 6: Styling Your Application

### Objectives
- Configure optimized fonts with `next/font`
- Create design tokens
- Add accessibility utilities
- Build CSS Modules for reusable components
- Extract StatusBadge and ProjectCard
- Implement responsive refinements

### Lab Tasks

**Task 6.1: Configure Fonts**

Update `src/app/layout.tsx` to use Geist fonts.

**Task 6.2: Create Design Tokens**

Create `src/styles/design-tokens.css` with color, spacing, and typography variables.

**Task 6.3: Create Accessibility Styles**

Create `src/styles/accessibility.css` with skip link, focus, and print styles.

**Task 6.4: Create Status Badge Component**

Create `src/components/status-badge.module.css` and `src/components/status-badge.tsx`.

**Task 6.5: Create Project Card Component**

Create `src/components/project-card.module.css` and `src/components/project-card.tsx`.

**Task 6.6: Refactor Components**

Update `ProjectList` and `DashboardActiveProjects` to use `ProjectCard`.

**Task 6.7: Add Responsive Styles**

Add responsive refinements to `globals.css`.

### Lab Commands

```bash
npm run dev
# Test at different viewport widths
# Test keyboard navigation with Tab
# Test print preview
# Test reduced motion preference
```

### Lab Results

```
[Document your styling verification here]
```

---

## Lab 7: Building APIs and Full-Stack Features

### Objectives
- Create shared input schemas
- Build database mutation functions
- Create API response utilities
- Implement Route Handlers
- Create Server Actions
- Build forms with validation
- Add task management features

### Lab Tasks

**Task 7.1: Create Task Types**

Create `src/lib/task-types.ts`:

```ts
export const TASK_STATUSES = ["TODO", "IN_PROGRESS", "COMPLETED"] as const;
export type TaskStatus = (typeof TASK_STATUSES)[number];

export const TASK_PRIORITIES = ["LOW", "MEDIUM", "HIGH"] as const;
export type TaskPriority = (typeof TASK_PRIORITIES)[number];

export type Task = {
  id: string;
  projectId: string;
  title: string;
  description: string | null;
  status: TaskStatus;
  priority: TaskPriority;
  dueDate: string | null;
  createdAt: string;
  updatedAt: string;
};

export function formatTaskStatus(status: TaskStatus): string {
  const labels: Record<TaskStatus, string> = {
    TODO: "To do",
    IN_PROGRESS: "In progress",
    COMPLETED: "Completed",
  };
  return labels[status];
}

export function formatTaskPriority(priority: TaskPriority): string {
  const labels: Record<TaskPriority, string> = {
    LOW: "Low",
    MEDIUM: "Medium",
    HIGH: "High",
  };
  return labels[priority];
}
```

**Task 7.2: Create Input Schemas**

Create `src/lib/project-inputs.ts` with Zod schemas.

**Task 7.3: Create Mutation Functions**

Create `src/lib/database/project-mutations.ts`.

**Task 7.4: Create API Response Utilities**

Create `src/lib/api-response.ts`.

**Task 7.5: Create Route Handlers**

Create:
- `src/app/api/projects/route.ts`
- `src/app/api/projects/[projectId]/route.ts`
- `src/app/api/health/route.ts`

**Task 7.6: Create Server Actions**

Create:
- `src/app/(workspace)/projects/actions.ts`
- `src/app/(workspace)/projects/[projectId]/actions.ts`

**Task 7.7: Create Forms**

Create:
- `src/components/create-project-form.tsx`
- `src/components/create-task-form.tsx`
- `src/components/task-list.tsx`

**Task 7.8: Update Project Detail Page**

Add task management to the project detail page.

### Lab Commands

```bash
# Test API endpoints
curl http://localhost:3000/api/projects
curl -X POST -H "Content-Type: application/json" -d '{"name":"Test","description":"Test","status":"PLANNED"}' http://localhost:3000/api/projects

# Test health endpoint
curl http://localhost:3000/api/health
```

### Lab Results

```
[Document your API and form testing here]
```

---

## Lab 8: Authentication and State Management

### Objectives
- Add user and session tables
- Implement password hashing
- Create sign-in and sign-up forms
- Build session management
- Protect workspace routes
- Implement owner-scoped queries
- Authorize API endpoints
- Verify cross-user isolation

### Lab Tasks

**Task 8.1: Install bcryptjs**

```bash
npm install bcryptjs
```

**Task 8.2: Create Migration**

Create `database/migrations/002_add_users_sessions_and_ownership.sql`.

**Task 8.3: Update Seed Data**

Update `database/seeds/development.sql` to include the demo user.

**Task 8.4: Create Authentication Types**

Create `src/lib/auth-types.ts` and `src/lib/auth-inputs.ts`.

**Task 8.5: Create Account and Session Database Layer**

Create `src/lib/auth/accounts.ts` and `src/lib/auth/session-store.ts`.

**Task 8.6: Create Session Utilities**

Create `src/lib/auth/session.ts`.

**Task 8.7: Create Authentication Actions**

Create `src/app/(auth)/actions.ts`.

**Task 8.8: Create Authentication Forms**

Create `src/components/sign-in-form.tsx` and `src/components/sign-up-form.tsx`.

**Task 8.9: Create Authentication Pages**

Create `src/app/(auth)/layout.tsx`, `src/app/(auth)/sign-in/page.tsx`, and `src/app/(auth)/sign-up/page.tsx`.

**Task 8.10: Protect Workspace**

Update `src/app/(workspace)/layout.tsx` to require authentication.

**Task 8.11: Update Queries and Mutations**

Update all query and mutation functions to require `userId`.

**Task 8.12: Authenticate APIs**

Update Route Handlers to require authentication.

**Task 8.13: Add Account Menu**

Create `src/components/account-menu.tsx` and add to workspace layout.

### Lab Commands

```bash
# Apply migration
npm run db:migrate

# Test sign-in
curl -X POST http://localhost:3000/api/auth/sign-in

# Test protected API without auth
curl http://localhost:3000/api/projects
# Expected: 401 Unauthorized

# Test cross-user isolation
# Create two users and verify they cannot access each other's projects
```

### Lab Results

```
[Document your authentication testing here]
```

---

## Lab 9: Performance and Optimization

### Objectives
- Establish performance baseline
- Generate and optimize images
- Implement code splitting
- Add parallel data loading
- Configure cache policies
- Run bundle analysis
- Audit with Lighthouse

### Lab Tasks

**Task 9.1: Measure Baseline Performance**

```bash
mkdir -p scripts
```

Create `scripts/measure-routes.sh`.

**Task 9.2: Generate Optimized Image**

Create `scripts/generate-launchpad-image.py` and generate `public/launchpad-dashboard.png`.

**Task 9.3: Add Optimized Image**

Update the home page to use `next/image`.

**Task 9.4: Create Optional Project Insights**

Create `src/components/project-insights.tsx` and `src/components/project-insights-loader.tsx`.

**Task 9.5: Add Cache Headers**

Update API responses with appropriate cache headers.

**Task 9.6: Add Bundle Analyzer**

```bash
npm install --save-dev @next/bundle-analyzer
```

Update `next.config.ts`.

**Task 9.7: Run Lighthouse Audit**

Build and run production, then run Lighthouse.

### Lab Commands

```bash
# Measure baseline
./scripts/measure-routes.sh

# Generate image
python3 scripts/generate-launchpad-image.py

# Build and analyze
npm run build
npm run analyze

# Run production
npm run start

# Run Lighthouse (in Chrome DevTools)
```

### Lab Results

```
[Document your performance measurements here]
```

---

## Lab 10: Deployment and Production Readiness

### Objectives
- Validate environment configuration
- Create tracked migrations
- Add structured logging
- Implement liveness and readiness
- Configure security headers
- Build Docker image
- Create smoke tests
- Set up CI pipeline
- Deploy to production

### Lab Tasks

**Task 10.1: Strengthen Environment Validation**

Update `src/lib/environment.ts` with more validation.

**Task 10.2: Create Migration Runner**

Create `scripts/migrate.mjs`:

```js
#!/usr/bin/env node
// Full migration runner code from tutorial
```

**Task 10.3: Add Structured Logging**

Create `src/lib/logger.ts`.

**Task 10.4: Add Liveness Endpoint**

Create `src/app/api/live/route.ts`.

**Task 10.5: Configure Security Headers**

Update `next.config.ts` with security headers.

**Task 10.6: Create Dockerfile**

Create `Dockerfile` and `.dockerignore`.

**Task 10.7: Create Smoke Tests**

Create `scripts/smoke-test.mjs`.

**Task 10.8: Set Up CI Pipeline**

Create `.github/workflows/ci.yml`.

**Task 10.9: Create Documentation**

Create `docs/production-runbook.md` and `docs/deployment-checklist.md`.

### Lab Commands

```bash
# Test migrations
npm run db:migrate
npm run db:migrate  # Should report already applied

# Build Docker image
docker build -t launchpad:latest .

# Run Docker container
docker run -p 3000:3000 launchpad:latest

# Run smoke tests
npm run smoke

# Deploy to Vercel
npx vercel --prod
```

### Lab Results

```
[Document your deployment verification here]
```

---

## Final Project Summary

### Application Features Checklist

- [ ] Home page with hero and feature preview
- [ ] About page
- [ ] Features page
- [ ] Dashboard with statistics
- [ ] Project list with filtering
- [ ] Project detail with tasks
- [ ] Project creation form
- [ ] Task creation form
- [ ] Task status updates
- [ ] User registration
- [ ] User sign-in
- [ ] User sign-out
- [ ] Protected routes
- [ ] Owner-scoped data
- [ ] Responsive design
- [ ] Accessible interface
- [ ] Optimized images
- [ ] Code splitting
- [ ] Health checks
- [ ] Security headers
- [ ] Docker deployment
- [ ] CI pipeline

### Architecture Diagram

```
[Draw your final architecture diagram here]
```

### Deployed URL

```
[Your production URL here]
```

### Final Reflections

What was the most valuable concept you learned in this series?

```
[Your answer here]
```

What would you do differently if you started again?

```
[Your answer here]
```

What will you build next?

```
[Your answer here]
```
