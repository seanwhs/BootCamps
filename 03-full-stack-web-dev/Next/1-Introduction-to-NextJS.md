# Part 1: Introduction to Next.js

In this part, we will create the LaunchPad application, examine the generated project, replace the starter screen, and verify both development and production execution.

By the end of Part 1, you will have:

- A Next.js 16 application using the App Router
- TypeScript and ESLint configured
- A clean initial LaunchPad landing page
- Global metadata and baseline CSS
- A verified development build
- A verified optimized production build
- A clear understanding of the most important generated files

---

## 1.1 What Next.js Adds to React

React is a library for constructing user interfaces from components. A traditional React application still needs decisions and supporting tools for concerns such as:

- Routing
- Server rendering
- Data fetching
- Backend endpoints
- Code splitting
- Asset optimization
- Metadata
- Production builds
- Deployment

Next.js is a React framework that supplies conventions and integrated tools for these concerns.

A useful comparison is a restaurant kitchen:

- **React** gives us ingredients and cooking techniques.
- **Next.js** gives us the kitchen layout, service workflow, storage rules, and order-delivery system.

Next.js does not replace React. Next.js applications are React applications with additional framework capabilities.

### A traditional browser-rendered React flow

A client-rendered React application commonly follows this process:

```text
1. Browser requests the site
2. Server sends a small HTML document
3. Browser downloads JavaScript
4. JavaScript starts React
5. React requests application data
6. React constructs the visible interface
```

That architecture can work well, but the user may depend on a significant amount of JavaScript before seeing useful content.

### A modern Next.js flow

Next.js can perform more work on the server:

```text
1. Browser requests a route
2. Next.js matches the route
3. Server Components fetch required data
4. Next.js renders the initial interface
5. Browser receives useful output
6. JavaScript activates only the interactive Client Components
```

The exact behavior depends on the route’s rendering and caching strategy. We will control those decisions as LaunchPad develops.

---

# Step 1: Prepare the Development Environment

## The Target

Verify that your computer has a supported Node.js release, npm, Git, and a terminal capable of running the project commands.

## The Concept

A Next.js project depends on a toolchain.

A **toolchain** is the collection of programs used to create, check, build, and run an application. It is similar to preparing a workshop before building furniture: even a perfect blueprint will not help if the required tools are missing or incompatible.

We will use:

- **Node.js** to execute JavaScript outside the browser
- **npm** to install packages and run project scripts
- **Git** to record source-code history
- **Next.js 16** as the application framework
- **TypeScript** for static type checking
- **ESLint** for automated code-quality checks

Next.js 16 requires Node.js 20.9 or newer. For this series, a current Node.js 22 LTS release is a safe choice.

**LTS** means “Long-Term Support.” LTS releases receive stability and security maintenance for an extended period.

## The Implementation

Open a terminal and inspect your installed versions:

```bash
node --version
npm --version
git --version
```

Expected output will resemble:

```text
v22.x.x
10.x.x
git version 2.x.x
```

Exact patch versions will differ.

### If Node.js is missing or too old

Install a current Node.js 22 LTS release from:

```text
https://nodejs.org/
```

Alternatively, if you already use a Node version manager such as `nvm`, run:

```bash
nvm install 22
nvm use 22
node --version
```

A version manager allows multiple Node.js versions to coexist on one computer. This is useful when different projects require different Node releases.

> Windows users should note that the Unix/macOS `nvm` project and `nvm-windows` are separate tools. If you do not already use a version manager, the official Node.js installer is the simplest path.

### If Git is missing

Install Git from:

```text
https://git-scm.com/downloads
```

Then close and reopen your terminal so the new executable is available.

## The Verification

Run:

```bash
node --version
npm --version
git --version
```

Confirm all of the following:

- The Node.js version is `20.9.0` or newer.
- npm prints a version without an error.
- Git prints a version without an error.

You can also confirm that Node executes JavaScript:

```bash
node -e "console.log('The LaunchPad toolchain is ready.')"
```

Expected output:

```text
The LaunchPad toolchain is ready.
```

Do not continue until these commands work.

[GENERATED: Part 1, Step 1: Development Environment] [STARTING: Part 1, Step 2: Project Creation]

---

# Step 2: Create the Next.js 16 Application

## The Target

Generate a new Next.js 16 project named `launchpad` with:

- The App Router
- TypeScript
- ESLint
- A `src` directory
- The `@/*` import alias
- npm as the package manager
- No Tailwind CSS yet

## The Concept

Starting a framework application requires more than creating a single JavaScript file. The project needs a package manifest, compiler settings, framework configuration, source directories, development scripts, and dependencies.

The `create-next-app` utility is a **scaffolding tool**. Scaffolding means generating the initial structural pieces of an application, much like builders erect temporary supports and establish a building’s frame before adding finished rooms.

We are explicitly choosing the App Router. The **App Router** is Next.js’s modern routing system based on directories and special files inside the `app` directory.

We will not enable Tailwind CSS during project creation. Part 6 will examine styling choices deliberately instead of accepting one without context.

## The Implementation

Move to the parent directory in which you store development projects.

For example:

```bash
cd ~/projects
```

On Windows PowerShell, an example could be:

```powershell
cd C:\Users\YourName\Projects
```

Now generate the application:

```bash
npx create-next-app@16 launchpad --typescript --eslint --app --src-dir --no-tailwind --turbopack --import-alias "@/*" --use-npm --yes
```

Here is what each option means:

| Option | Purpose |
|---|---|
| `create-next-app@16` | Uses the Next.js 16 generation tool |
| `launchpad` | Creates a directory named `launchpad` |
| `--typescript` | Configures TypeScript |
| `--eslint` | Configures ESLint |
| `--app` | Uses the App Router |
| `--src-dir` | Places application source code inside `src` |
| `--no-tailwind` | Does not configure Tailwind CSS |
| `--turbopack` | Uses Next.js’s high-performance development bundler |
| `--import-alias "@/*"` | Lets imports use `@/` instead of long relative paths |
| `--use-npm` | Uses npm instead of another package manager |
| `--yes` | Accepts defaults for any remaining generator questions |

Enter the generated project:

```bash
cd launchpad
```

Installations performed by `create-next-app` are recorded in:

```text
package.json
package-lock.json
```

The `package.json` file describes the project and declares its direct dependencies. The lock file records the complete resolved dependency tree so future installations are reproducible.

## The Verification

First, confirm your current directory.

On macOS, Linux, or Git Bash:

```bash
pwd
```

On PowerShell:

```powershell
Get-Location
```

The path should end in:

```text
launchpad
```

Confirm that Next.js 16 was installed:

```bash
npm ls next react react-dom
```

The output should include a Next.js version beginning with `16`, similar to:

```text
launchpad@0.1.0
├── next@16.x.x
├── react@19.x.x
└── react-dom@19.x.x
```

Now list the project files.

On macOS or Linux:

```bash
find . -maxdepth 3 -type f \
  -not -path "./node_modules/*" \
  -not -path "./.git/*" \
  | sort
```

On PowerShell:

```powershell
Get-ChildItem -Recurse -File |
  Where-Object {
    $_.FullName -notmatch '\\node_modules\\' -and
    $_.FullName -notmatch '\\.git\\'
  } |
  ForEach-Object {
    $_.FullName.Replace((Get-Location).Path + '\', '')
  }
```

You should find files including:

```text
eslint.config.mjs
next-env.d.ts
next.config.ts
package-lock.json
package.json
public/...
src/app/favicon.ico
src/app/globals.css
src/app/layout.tsx
src/app/page.tsx
tsconfig.json
```

The generator may include additional image or configuration files. That is normal.

[GENERATED: Part 1, Step 2: Next.js 16 Project] [STARTING: Part 1, Step 3: Generated Project Inspection]

---

# Step 3: Understand the Generated Project

## The Target

Inspect the generated files and understand which responsibilities belong to each project area.

## The Concept

A new framework project can resemble a room full of labeled boxes. Opening every box immediately would be overwhelming. Instead, we will first identify the boxes that matter most.

The generated project separates several responsibilities:

```text
launchpad/
├── public/                 Static public files
├── src/
│   └── app/                Routes, layouts, and route-related UI
├── eslint.config.mjs       Code-quality configuration
├── next-env.d.ts           Next.js TypeScript declarations
├── next.config.ts          Next.js configuration
├── package.json            Dependencies and scripts
├── package-lock.json       Exact installed dependency versions
└── tsconfig.json           TypeScript configuration
```

## The Implementation

No files need to be changed in this step. We will inspect the existing project.

### Inspect `package.json`

Run:

```bash
cat package.json
```

PowerShell users can run:

```powershell
Get-Content package.json
```

The scripts section should contain commands similar to:

```json
{
  "scripts": {
    "dev": "next dev --turbopack",
    "build": "next build",
    "start": "next start",
    "lint": "eslint"
  }
}
```

Depending on the exact Next.js 16 generator release, the `dev` command may be `next dev` because Turbopack is already the standard development bundler. Either form is valid.

The scripts have distinct purposes:

- `npm run dev` starts a development server.
- `npm run build` creates an optimized production build.
- `npm run start` serves an existing production build.
- `npm run lint` checks source files using ESLint.

### Inspect `src/app`

Run:

```bash
ls src/app
```

PowerShell:

```powershell
Get-ChildItem src/app
```

The most important generated files are:

```text
src/app/layout.tsx
src/app/page.tsx
src/app/globals.css
```

### `src/app/page.tsx`

A `page.tsx` file supplies the page shown for a route.

Because this file sits directly inside `src/app`, it represents the root URL:

```text
/
```

Later, this file structure:

```text
src/app/about/page.tsx
```

will represent:

```text
/about
```

### `src/app/layout.tsx`

A `layout.tsx` file provides shared UI around pages beneath it.

The root layout is special. It must provide the application’s outer HTML structure, including the `<html>` and `<body>` elements.

### `src/app/globals.css`

This file contains styles that apply globally. Global styles are useful for:

- Color variables
- Basic element normalization
- Body defaults
- Shared typography
- Application-wide accessibility behavior

### `public`

Files in `public` are served from the application’s root URL.

For example:

```text
public/logo.svg
```

would be available at:

```text
/logo.svg
```

The URL does not contain `/public`.

### `next.config.ts`

This is the framework configuration file. It will eventually hold application-level settings such as security headers or remote image rules.

### `tsconfig.json`

This configures TypeScript’s compiler and defines the `@/*` alias.

An import such as:

```ts
import { Button } from "@/components/button";
```

will eventually refer to:

```text
src/components/button
```

Without the alias, a deeply nested file might require a fragile path such as:

```ts
import { Button } from "../../../../components/button";
```

### `next-env.d.ts`

This file connects the project to Next.js’s generated TypeScript definitions.

Do not manually edit `next-env.d.ts`. Next.js manages it.

## The Verification

Ask Next.js to perform a TypeScript check without generating JavaScript output:

```bash
npx tsc --noEmit
```

Expected result:

```text
No terminal output and exit code 0
```

A silent successful command is normal.

Now run ESLint:

```bash
npm run lint
```

Expected result:

```text
No linting errors
```

The exact successful output depends on the installed ESLint release. The important result is that the command exits without reporting an error.

[GENERATED: Part 1, Step 3: Project Structure Inspection] [STARTING: Part 1, Step 4: Initial Development Server]

---

# Step 4: Run the Generated Application

## The Target

Start the Next.js development server and verify the generated application in both a browser and the terminal.

## The Concept

A **development server** runs the application with features intended to make programming faster:

- Detailed error messages
- Automatic source rebuilding
- Fast Refresh
- Source maps
- File watching

**Fast Refresh** updates changed React components while preserving browser state when possible. It is similar to replacing one panel in a machine while the rest of the machine remains assembled.

The development server is not the optimized production server. We will test that separately.

## The Implementation

From the project root, start the development server:

```bash
npm run dev
```

Expected terminal output will resemble:

```text
▲ Next.js 16.x.x
- Local:        http://localhost:3000
- Network:      http://192.168.x.x:3000

✓ Starting...
✓ Ready
```

Do not close this terminal while using the development server.

Open the following URL in a browser:

```text
http://localhost:3000
```

You should see the generated Next.js starter page.

### Verify the HTTP response directly

Open a second terminal, return to the project directory, and run:

```bash
curl --fail --silent --show-error --output /dev/null \
  --write-out "%{http_code}\n" \
  http://localhost:3000
```

Expected output:

```text
200
```

A `200` status means the request succeeded.

PowerShell users can run:

```powershell
(Invoke-WebRequest -Uri http://localhost:3000).StatusCode
```

Expected output:

```text
200
```

## The Verification

Confirm all four conditions:

1. The terminal reports that Next.js is ready.
2. `http://localhost:3000` loads in the browser.
3. The browser displays the generated starter page.
4. The direct HTTP request returns status `200`.

Leave the development server running for the next step. When files change, Next.js will rebuild the affected route automatically.

[GENERATED: Part 1, Step 4: Initial Development Server] [STARTING: Part 1, Step 5: Root Metadata and Layout]

---

# Step 5: Build the Root Layout and Metadata

## The Target

Replace the generated root layout with a clean LaunchPad layout that defines:

- The document language
- Global CSS
- Default metadata
- A reusable title template
- The application description
- A stable body structure

## The Concept

A layout is shared UI and configuration that surrounds pages.

Think of a picture frame. The picture inside may change, but the frame remains around it. The root layout is the outermost frame around every page in the application.

The root layout also defines **metadata**. Metadata describes a page to browsers, search engines, bookmarks, and link-preview systems.

Examples include:

- The browser-tab title
- The page description
- Search-engine hints
- Social-sharing information

Next.js can generate the document’s `<head>` elements from typed metadata objects. We do not need to manually write a `<head>` element in the layout.

## The Implementation

Completely replace the generated root layout.

### `src/app/layout.tsx`

```tsx
import type { Metadata } from "next";
import type { ReactNode } from "react";

import "./globals.css";

/**
 * Metadata declared in the root layout becomes the default metadata for the
 * application. Child routes can add to or override these values later.
 */
export const metadata: Metadata = {
  title: {
    default: "LaunchPad",
    template: "%s | LaunchPad",
  },
  description:
    "A production-ready project and task management application built with Next.js 16.",
};

/**
 * RootLayout wraps every route in the application.
 *
 * Next.js requires the root layout to render both the <html> and <body>
 * elements because this component defines the application's document shell.
 */
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

### Important details

This import gives TypeScript the official Next.js metadata type:

```tsx
import type { Metadata } from "next";
```

The `type` keyword tells TypeScript that the import is only needed during type checking. It does not need to become part of browser or server runtime code.

This title configuration establishes two behaviors:

```tsx
title: {
  default: "LaunchPad",
  template: "%s | LaunchPad",
},
```

The home page will use:

```text
LaunchPad
```

A future route could define the title `Projects`, causing Next.js to produce:

```text
Projects | LaunchPad
```

The `children` property represents the active page or nested layout:

```tsx
<body>{children}</body>
```

The `Readonly` utility type communicates that the component should not modify its properties:

```tsx
Readonly<{
  children: ReactNode;
}>
```

The `lang` attribute tells assistive technology and browsers that the document content is in English:

```tsx
<html lang="en">
```

## The Verification

Save the file and inspect the development-server terminal.

It should rebuild without an error.

Run the type checker in a second terminal:

```bash
npx tsc --noEmit
```

Then run ESLint:

```bash
npm run lint
```

Both commands should complete successfully.

Refresh:

```text
http://localhost:3000
```

The starter page should still render because the existing `page.tsx` remains the layout’s `children`.

Inspect the page’s title from the terminal:

```bash
curl --silent http://localhost:3000 | grep -o "<title>[^<]*</title>"
```

Expected output:

```html
<title>LaunchPad</title>
```

PowerShell users can run:

```powershell
$response = Invoke-WebRequest -Uri http://localhost:3000
$response.Content | Select-String -Pattern '<title>LaunchPad</title>'
```

The response should contain:

```html
<title>LaunchPad</title>
```

[GENERATED: Part 1, Step 5: Root Layout and Metadata] [STARTING: Part 1, Step 6: LaunchPad Home Page]

---

# Step 6: Replace the Starter Page

## The Target

Replace the generated starter page with the first real LaunchPad page.

The page will:

- Introduce the application
- Describe its future capabilities
- Use semantic HTML
- Remain a Server Component
- Avoid unnecessary browser-side JavaScript

## The Concept

In the App Router, a page is the interface associated with a route.

The file:

```text
src/app/page.tsx
```

represents:

```text
/
```

The page component does not contain a `"use client"` directive. It is therefore a Server Component.

A **Server Component** is rendered in the server environment and does not automatically add its component code to the browser’s JavaScript bundle. This is a good default for content that does not require browser event handlers, state, effects, or browser APIs.

Our first page is informational. It does not need client-side state, so keeping it as a Server Component is the correct architecture.

## The Implementation

Completely replace the generated page.

### `src/app/page.tsx`

```tsx
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

### Why the feature data lives outside the component

The feature descriptions are declared at module scope:

```tsx
const plannedFeatures = [
  // ...
] as const;
```

They do not depend on a request or component state, so there is no reason to recreate the array inside `HomePage` every time it renders.

The `as const` assertion tells TypeScript that these values are fixed and should be treated as readonly literal data.

### Why we map over the features

Instead of writing three nearly identical cards by hand, we transform the data into interface elements:

```tsx
{plannedFeatures.map((feature) => (
  <article className="feature-card" key={feature.title}>
    <h3>{feature.title}</h3>
    <p>{feature.description}</p>
  </article>
))}
```

The `key` helps React identify each item consistently.

For production data, stable database identifiers are usually better keys. These static feature titles are unique and never edited, so they are sufficient here.

### Why this link is a standard anchor

The link points to another section on the same page:

```tsx
<a href="#planned-features">Explore the plan</a>
```

This is called a **fragment link**. It moves the browser to the element whose `id` is `planned-features`.

We do not need Next.js’s `Link` component for same-document navigation. In Part 2, we will use `Link` to navigate between application routes.

### Why semantic elements matter

The page uses:

- `<main>` for the page’s primary content
- `<section>` for meaningful content groups
- `<article>` for self-contained feature cards
- Heading levels that form a logical hierarchy
- `<footer>` for closing application information

Semantic elements communicate structure to browsers, search engines, and assistive technology.

## The Verification

Save the file and visit:

```text
http://localhost:3000
```

At this moment, the page may look visually unfinished because the generated CSS does not contain styles for our new classes. That is expected.

Confirm that the content appears:

- “Built with Next.js 16”
- “Turn ambitious ideas into organized work.”
- Three feature descriptions
- The LaunchPad footer

Run:

```bash
curl --silent http://localhost:3000 | grep "Turn ambitious ideas into organized work"
```

Expected output contains:

```text
Turn ambitious ideas into organized work
```

Run the type checker and linter:

```bash
npx tsc --noEmit
npm run lint
```

Both commands should succeed.

[GENERATED: Part 1, Step 6: LaunchPad Home Page] [STARTING: Part 1, Step 7: Global CSS Foundation]

---

# Step 7: Create the Global CSS Foundation

## The Target

Replace the generated global stylesheet with a complete baseline design for the initial LaunchPad page.

This stylesheet will provide:

- Predictable box sizing
- Global color variables
- Readable typography
- Responsive spacing
- Visible keyboard focus
- Feature-card layout
- Reduced-motion support

## The Concept

CSS controls presentation, but global CSS also establishes application-wide rules.

A **CSS custom property**, often called a CSS variable, gives a reusable name to a value:

```css
--color-text: #172033;
```

It works like labeling a paint container. Instead of remembering a color value everywhere, we refer to its meaningful name.

A **CSS reset** removes or normalizes inconsistent browser defaults. We will use a small, controlled baseline instead of a large reset package.

Part 6 will explore styling architecture in depth. For now, we need a clean and accessible foundation.

## The Implementation

Completely replace the generated global stylesheet.

### `src/app/globals.css`

```css
:root {
  --color-background: #f6f8fc;
  --color-surface: #ffffff;
  --color-text: #172033;
  --color-text-muted: #59657a;
  --color-border: #dce2ec;
  --color-primary: #3457d5;
  --color-primary-hover: #2946ad;
  --color-focus: #ffbf47;
  --color-accent-soft: #e9edff;
  --shadow-card: 0 1rem 2.5rem rgb(23 32 51 / 8%);
  --content-width: 72rem;
}

/*
 * Border-box sizing keeps an element's declared width predictable by
 * including its padding and border inside that width.
 */
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
    radial-gradient(circle at top left, rgb(52 87 213 / 10%), transparent 32rem),
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

/*
 * A visible focus indicator lets keyboard users identify the element that
 * will receive their next action.
 */
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

.hero {
  display: grid;
  min-height: 70vh;
  align-content: center;
  justify-items: start;
  padding-block: 5rem;
}

.eyebrow {
  margin: 0 0 0.75rem;
  color: var(--color-primary);
  font-size: 0.875rem;
  font-weight: 700;
  letter-spacing: 0.08em;
  text-transform: uppercase;
}

.hero h1 {
  max-width: 15ch;
  margin: 0;
  font-size: clamp(2.75rem, 8vw, 5.75rem);
  line-height: 0.98;
  letter-spacing: -0.055em;
}

.hero-description {
  max-width: 42rem;
  margin: 1.5rem 0 0;
  color: var(--color-text-muted);
  font-size: clamp(1.05rem, 2vw, 1.25rem);
}

.primary-link {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-height: 2.75rem;
  margin-top: 2rem;
  padding: 0.65rem 1.1rem;
  border-radius: 0.65rem;
  background: var(--color-primary);
  color: #ffffff;
  font-weight: 700;
  text-decoration: none;
  transition:
    background-color 160ms ease,
    transform 160ms ease;
}

.primary-link:hover {
  background: var(--color-primary-hover);
  transform: translateY(-0.125rem);
}

.feature-section {
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

.feature-card {
  padding: 1.5rem;
  border: 0.0625rem solid var(--color-border);
  border-radius: 1rem;
  background: var(--color-surface);
  box-shadow: var(--shadow-card);
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
  padding-block: 2rem;
  border-top: 0.0625rem solid var(--color-border);
  color: var(--color-text-muted);
  font-size: 0.9rem;
}

.site-footer p {
  margin: 0;
}

@media (max-width: 48rem) {
  .hero {
    min-height: auto;
    padding-block: 5rem;
  }

  .feature-grid {
    grid-template-columns: 1fr;
  }
}

/*
 * Users can request reduced motion through their operating system. Respecting
 * that setting prevents decorative animation from causing discomfort.
 */
@media (prefers-reduced-motion: reduce) {
  html {
    scroll-behavior: auto;
  }

  *,
  *::before,
  *::after {
    scroll-duration: 0.01ms;
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Remove unused generated CSS modules

Some versions of `create-next-app` generate:

```text
src/app/page.module.css
```

Our new page does not import that file. If it exists, remove it.

On macOS or Linux:

```bash
rm -f src/app/page.module.css
```

On PowerShell:

```powershell
if (Test-Path src/app/page.module.css) {
  Remove-Item src/app/page.module.css
}
```

### Why `width: min(...)` is useful

This declaration creates responsive horizontal spacing while preventing the content from becoming excessively wide:

```css
width: min(100% - 2rem, var(--content-width));
```

It chooses the smaller of:

- The viewport width minus two rems
- The maximum content width

### Why the layout uses CSS Grid

The cards use:

```css
grid-template-columns: repeat(3, minmax(0, 1fr));
```

This creates three equal columns.

On smaller screens, the media query changes them to one column:

```css
@media (max-width: 48rem) {
  .feature-grid {
    grid-template-columns: 1fr;
  }
}
```

This is **responsive design**: the interface adapts to the available screen size.

## The Verification

Refresh:

```text
http://localhost:3000
```

Confirm that:

- The page has a pale background.
- The main heading is large and responsive.
- The primary link appears as a blue button.
- The feature cards appear in three columns on a wide screen.
- The cards collapse to one column on a narrow screen.
- Selecting the primary link moves the page to the feature section.

### Verify keyboard focus

Press `Tab` until the “Explore the plan” link receives focus.

You should see a visible yellow focus outline.

Press `Enter`. The browser should move to the feature section.

### Verify the small-screen layout

Open browser developer tools and select a mobile viewport, or reduce the browser width below approximately `768px`.

The feature cards should appear in one vertical column.

### Run automated checks

```bash
npx tsc --noEmit
npm run lint
```

Both commands should complete successfully.

[GENERATED: Part 1, Step 7: Global CSS Foundation] [STARTING: Part 1, Step 8: Development Workflow Verification]

---

# Step 8: Verify Fast Refresh and Error Feedback

## The Target

Confirm that the development server detects source changes and updates the browser without requiring a manual server restart.

## The Concept

During development, Next.js watches the project’s source files. When a file changes, it rebuilds the affected portion of the application.

This feedback loop is important:

```text
Edit → Save → Rebuild → Inspect → Repeat
```

Fast feedback reduces the distance between making a change and learning whether that change worked.

We will make a controlled text edit, verify the result, and then restore the intended content.

## The Implementation

Open:

```text
src/app/page.tsx
```

Find:

```tsx
<p className="eyebrow">Built with Next.js 16</p>
```

Temporarily replace it with:

```tsx
<p className="eyebrow">Development server verified</p>
```

Save the file.

Observe the browser and development-server terminal. The page should update without restarting `npm run dev`.

After verifying the update, restore the original line:

```tsx
<p className="eyebrow">Built with Next.js 16</p>
```

Save the file again.

## The Verification

Confirm all of the following:

1. The browser changed after the first save.
2. The development server remained running.
3. Restoring the line returned the page to “Built with Next.js 16.”
4. No compiler error remains in the terminal.

Finally, run:

```bash
npx tsc --noEmit
npm run lint
```

Both commands must succeed.

[GENERATED: Part 1, Step 8: Development Workflow] [STARTING: Part 1, Step 9: Production Build]

---

# Step 9: Build and Run the Production Application

## The Target

Create an optimized production build and run it locally using the production server.

## The Concept

A development server prioritizes debugging speed and helpful feedback. A production build prioritizes:

- Optimized output
- Smaller assets
- Efficient execution
- Static generation where appropriate
- Production error behavior
- Deployment-compatible artifacts

A development server working successfully does not guarantee that a production build will succeed.

Think of development mode as rehearsing a play with the lights on and the director giving immediate notes. A production build is the actual performance: every required piece must be prepared correctly before the curtain rises.

## The Implementation

Return to the terminal running the development server and stop it by pressing:

```text
Ctrl+C
```

Now build the application:

```bash
npm run build
```

Next.js will:

1. Compile the source code.
2. Check framework-specific constraints.
3. Produce optimized assets.
4. Analyze routes.
5. Generate static output where appropriate.
6. Write production artifacts to `.next`.

The output should show the root route:

```text
/
```

Because the current home page has no request-specific data, it can be prepared as static output.

After the build succeeds, start the production server:

```bash
npm run start
```

Expected output resembles:

```text
▲ Next.js 16.x.x
- Local:        http://localhost:3000

✓ Starting...
✓ Ready
```

## The Verification

Open:

```text
http://localhost:3000
```

The same LaunchPad page should load.

In a second terminal, run:

```bash
curl --fail --silent --show-error \
  --output /dev/null \
  --write-out "Status: %{http_code}\nContent-Type: %{content_type}\n" \
  http://localhost:3000
```

Expected output resembles:

```text
Status: 200
Content-Type: text/html; charset=utf-8
```

Check the production HTML for the application title:

```bash
curl --silent http://localhost:3000 | grep -o "<title>[^<]*</title>"
```

Expected output:

```html
<title>LaunchPad</title>
```

Check for the page heading:

```bash
curl --silent http://localhost:3000 | grep "Turn ambitious ideas into organized work"
```

The response should contain the heading text.

Stop the production server when verification is complete:

```text
Ctrl+C
```

[GENERATED: Part 1, Step 9: Production Build] [STARTING: Part 1, Step 10: Git Checkpoint]

---

# Step 10: Create a Git Checkpoint

## The Target

Record the completed Part 1 application in Git so later work begins from a known-good state.

## The Concept

Git is a version-control system. It records meaningful snapshots of source code.

A commit is similar to a save point in a game. If a later change causes a problem, the commit gives us a known location from which to compare, diagnose, or recover.

A good commit should represent a coherent change that has already passed its checks.

## The Implementation

Check the repository status:

```bash
git status
```

If `create-next-app` initialized Git, the command will report changed files.

If Git reports:

```text
fatal: not a git repository
```

initialize it:

```bash
git init
```

Inspect ignored files:

```bash
cat .gitignore
```

PowerShell:

```powershell
Get-Content .gitignore
```

Confirm that generated and sensitive paths such as these are ignored:

```text
/node_modules
/.next
.env*
```

The generated `.gitignore` may make exceptions for documented example environment files later. That is acceptable.

Stage the current files:

```bash
git add .
```

Inspect exactly what will be committed:

```bash
git status
```

The staged files should not include:

```text
node_modules/
.next/
.env
.env.local
```

Create the commit:

```bash
git commit -m "feat: create initial LaunchPad application"
```

If Git asks you to configure an identity, run the following with your own information:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Then retry:

```bash
git commit -m "feat: create initial LaunchPad application"
```

## The Verification

Inspect the latest commit:

```bash
git log -1 --oneline
```

Expected output resembles:

```text
a1b2c3d feat: create initial LaunchPad application
```

Check repository status:

```bash
git status
```

Expected output:

```text
nothing to commit, working tree clean
```

Run the final Part 1 quality gate:

```bash
npx tsc --noEmit
npm run lint
npm run build
```

All three commands must succeed.

[GENERATED: Part 1, Step 10: Git Checkpoint] [STARTING: Part 1 Reference Sections]

---

# Part 1 Reference A: App Router File Conventions

Next.js uses specially named files to assign framework behavior.

We have used two of them so far:

```text
src/app/layout.tsx
src/app/page.tsx
```

Later, we will introduce additional conventions:

| File | Responsibility |
|---|---|
| `page.tsx` | Makes a route publicly accessible |
| `layout.tsx` | Provides shared UI around child routes |
| `loading.tsx` | Supplies a loading interface for a route segment |
| `error.tsx` | Catches unexpected rendering errors within a boundary |
| `not-found.tsx` | Displays a missing-resource interface |
| `route.ts` | Implements an HTTP Route Handler |
| `template.tsx` | Provides layout-like UI that remounts during navigation |
| `default.tsx` | Supplies fallback UI for certain parallel-route scenarios |

These names are framework conventions. A file named:

```text
projects.tsx
```

does not automatically create a `/projects` route.

The conventional route file is:

```text
app/projects/page.tsx
```

---

# Part 1 Reference B: Server-First Rendering

Our page does not contain:

```tsx
"use client";
```

That is intentional.

In the App Router, we begin with a server-first question:

> Can this component remain on the server?

A component normally needs to become a Client Component when it directly uses capabilities such as:

- `useState`
- `useEffect`
- Browser event handlers
- `window`
- `document`
- `localStorage`
- Browser-only third-party libraries

Our current page only renders static data. Making it a Client Component would add no useful capability.

Later, we will use focused Client Components for interactive elements while keeping surrounding pages and data access server-side.

---

# Part 1 Reference C: TypeScript Files

The project uses several common file extensions.

## `.ts`

A TypeScript file without JSX markup:

```text
src/lib/projects.ts
```

Example:

```ts
export function normalizeProjectName(name: string): string {
  return name.trim();
}
```

## `.tsx`

A TypeScript file that may contain JSX:

```text
src/app/page.tsx
```

Example:

```tsx
export function ProjectHeading() {
  return <h1>Projects</h1>;
}
```

## `.d.ts`

A TypeScript declaration file:

```text
next-env.d.ts
```

Declaration files describe types without providing ordinary runtime implementation.

## `.css`

A stylesheet:

```text
src/app/globals.css
```

## `.mjs`

An ECMAScript module interpreted as JavaScript:

```text
eslint.config.mjs
```

---

# Part 1 Reference D: Important npm Commands

## Install declared dependencies

```bash
npm install
```

This reads `package.json` and updates installed packages and the lock file when necessary.

## Perform a clean reproducible installation

```bash
npm ci
```

This installs exactly from `package-lock.json` and is commonly used in continuous-integration and deployment environments.

Unlike `npm install`, `npm ci` expects the package manifest and lock file to agree.

## Start development mode

```bash
npm run dev
```

## Run ESLint

```bash
npm run lint
```

## Check TypeScript

```bash
npx tsc --noEmit
```

The `--noEmit` option checks types without writing compiled JavaScript files.

## Create a production build

```bash
npm run build
```

## Serve a completed production build

```bash
npm run start
```

`npm run start` does not create the build. Run `npm run build` first.

## Inspect installed package versions

```bash
npm ls next react react-dom
```

---

# Part 1 Reference E: Development Versus Production

| Concern | Development | Production |
|---|---|---|
| Command | `npm run dev` | `npm run build` then `npm run start` |
| Goal | Fast feedback | Optimized execution |
| Error detail | Extensive | Safer and less verbose |
| Rebuilding | Automatic | Build performed in advance |
| Source maps | Developer-oriented | Controlled for deployment |
| Performance | Not representative | Closer to deployed behavior |
| Usage | Local development | Deployment or final local verification |

Never use development-mode performance as a production benchmark.

Development mode deliberately performs extra work to support file watching, diagnostics, and rapid rebuilding.

---

# Part 1 Reference F: Current Project Structure

After completing this part, the important project structure is:

```text
launchpad/
├── public/
├── src/
│   └── app/
│       ├── favicon.ico
│       ├── globals.css
│       ├── layout.tsx
│       └── page.tsx
├── .gitignore
├── eslint.config.mjs
├── next-env.d.ts
├── next.config.ts
├── package-lock.json
├── package.json
└── tsconfig.json
```

Some generator versions may include additional public assets. Those files do not affect the architecture introduced in this part.

The current routing tree contains one route:

```text
src/app/page.tsx → /
```

The root layout wraps that route:

```text
src/app/layout.tsx
└── src/app/page.tsx
```

Conceptually, Next.js composes them like this:

```tsx
<RootLayout>
  <HomePage />
</RootLayout>
```

We do not manually write that composition. The App Router performs it from the file structure.

---

# Part 1 Completion Checklist

Before continuing, confirm every item:

- [ ] Node.js 20.9 or newer is installed.
- [ ] `npm ls next` reports Next.js 16.
- [ ] `npm run dev` starts the development server.
- [ ] `http://localhost:3000` displays LaunchPad.
- [ ] The browser title is `LaunchPad`.
- [ ] The page is responsive on narrow screens.
- [ ] Keyboard focus is visible.
- [ ] `npx tsc --noEmit` succeeds.
- [ ] `npm run lint` succeeds.
- [ ] `npm run build` succeeds.
- [ ] `npm run start` serves the production build.
- [ ] Git contains the Part 1 checkpoint.
- [ ] `git status` reports a clean working tree.

You now have a verified Next.js 16 application and understand the foundational responsibilities of its generated files.
