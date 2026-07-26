# Part 6: Styling Your Application

LaunchPad already has a functional visual foundation, but most styles currently live in one large global stylesheet.

That approach helped us move quickly while learning routing and data fetching. As the application grows, however, one global file becomes difficult to maintain:

- Component selectors can accidentally affect unrelated elements.
- Class names must remain globally unique.
- Reusable components duplicate markup and styling decisions.
- Colors, spacing, and typography can drift.
- Developers have difficulty discovering which styles belong to which component.

In this part, we will evolve the styling architecture without rewriting the application or adding an unnecessary dependency.

By the end of Part 6, LaunchPad will include:

- Optimized typography with `next/font`
- Centralized design tokens
- Accessibility utilities
- A keyboard-accessible skip link
- Locally scoped CSS Modules
- Reusable status badges
- Reusable project cards
- Responsive component styles
- Consistent print behavior
- Reduced-motion support
- A documented styling strategy
- A verified production build

---

# Step 1: Define the Styling Architecture

## The Target

Establish which styling technique will own each category of LaunchPad’s CSS.

## The Concept

CSS can be organized in several ways. No single approach is automatically correct for every responsibility.

Think of styling like organizing tools in a workshop:

- Frequently shared tools belong on a central wall.
- Tools for one machine belong beside that machine.
- Safety rules apply throughout the workshop.
- Raw materials should use consistent labels.

LaunchPad will use three complementary layers.

### Global foundation

Global CSS will continue to own:

- Browser normalization
- Document typography
- Application shells
- Shared page layouts
- Existing utility-like interface patterns

### Design tokens

Design tokens give meaningful names to reusable visual decisions:

```css
--color-primary: #3457d5;
--space-4: 1rem;
--radius-medium: 0.75rem;
```

A token is similar to a named variable in TypeScript. Components use the name rather than repeating the raw value.

### CSS Modules

CSS Modules will own styles that belong to one reusable component:

```text
project-card.module.css
status-badge.module.css
```

Next.js transforms their class names into locally scoped identifiers. A `.card` class in one module will not accidentally style `.card` in another module.

Our architecture will become:

```text
src/
├── app/
│   └── globals.css
├── components/
│   ├── project-card.module.css
│   ├── project-card.tsx
│   ├── status-badge.module.css
│   └── status-badge.tsx
└── styles/
    ├── accessibility.css
    └── design-tokens.css
```

## The Implementation

No files change in this planning step.

We will follow these ownership rules:

| Styling concern | Location |
|---|---|
| Colors, spacing, shadows, typography tokens | `src/styles/design-tokens.css` |
| Focus, skip links, print, reduced motion | `src/styles/accessibility.css` |
| Existing application shells and page layouts | `src/app/globals.css` |
| Status badge implementation | `status-badge.module.css` |
| Project card implementation | `project-card.module.css` |
| Component markup and variants | Corresponding `.tsx` component |

## The Verification

Inspect the current stylesheets:

```bash
find src -type f -name "*.css" | sort
```

At this point, the primary stylesheet should be:

```text
src/app/globals.css
```

Run the current quality gate before restructuring:

```bash
npm run typecheck
npm run lint
npm run build
```

All commands must succeed.

[GENERATED: Part 6, Step 1: Styling Architecture] [STARTING: Part 6, Step 2: Optimized Typography]

---

# Step 2: Add Optimized Fonts with `next/font`

## The Target

Configure Geist Sans and Geist Mono through Next.js’s built-in font system.

## The Concept

A web font is a font file delivered with a website instead of relying entirely on fonts installed on the user’s device.

Loading fonts carelessly can cause:

- Text to appear late
- Layout to shift when the font arrives
- Additional external network requests
- Privacy concerns
- Inconsistent typography

Next.js provides `next/font`, which integrates fonts into the build and automatically creates the required CSS.

We will configure:

- **Geist Sans** for ordinary interface text
- **Geist Mono** for code and technical identifiers

The `variable` option exposes each font through a CSS custom property:

```css
--font-geist-sans
--font-geist-mono
```

## The Implementation

Completely replace the root layout.

### `src/app/layout.tsx`

```tsx
import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import type { ReactNode } from "react";

import "./globals.css";
import "@/styles/design-tokens.css";
import "@/styles/accessibility.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
  display: "swap",
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "LaunchPad",
    template: "%s | LaunchPad",
  },
  description:
    "A production-ready project and task management application built with Next.js 16.",
};

type RootLayoutProps = Readonly<{
  children: ReactNode;
}>;

export default function RootLayout({
  children,
}: RootLayoutProps) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable}`}
      >
        <a className="skip-link" href="#main-content">
          Skip to main content
        </a>

        {children}
      </body>
    </html>
  );
}
```

The imported design-token and accessibility files do not exist yet. Create their directory now:

```bash
mkdir -p src/styles
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force src/styles | Out-Null
```

Create temporary empty files so the application can resolve the imports:

```bash
touch src/styles/design-tokens.css
touch src/styles/accessibility.css
```

PowerShell:

```powershell
New-Item -ItemType File -Force src/styles/design-tokens.css |
  Out-Null

New-Item -ItemType File -Force src/styles/accessibility.css |
  Out-Null
```

### Why `display: "swap"` is used

The font configuration includes:

```tsx
display: "swap"
```

This allows the browser to show text using an available fallback font while the preferred font becomes ready.

Users see content instead of waiting for a blank area.

### Why font variables are placed on `<body>`

The generated classes define the custom properties:

```tsx
className={`${geistSans.variable} ${geistMono.variable}`}
```

Any descendant can then use:

```css
font-family: var(--font-geist-sans);
```

### Why the skip link is in the root layout

The skip link should be available on every visual page:

```tsx
<a className="skip-link" href="#main-content">
  Skip to main content
</a>
```

Keyboard users can activate it to bypass repeated navigation and move directly to the route content.

We will create the corresponding target and styles shortly.

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

Start the development server:

```bash
npm run dev
```

Open:

```text
http://localhost:3000
```

The application should still render.

Inspect the document body:

```bash
curl --silent http://localhost:3000 |
  grep -o 'class="[^"]*geist[^"]*"'
```

The generated class names can vary, but the response should contain font-related class identifiers.

Press `Tab` once in the browser. The skip link is present but may not yet have a useful visual style. We will correct that in Step 4.

> `next/font/google` downloads the selected font during the production build and self-hosts the resulting assets. The build machine therefore needs network access when the font is first resolved.

[GENERATED: Part 6, Step 2: Optimized Typography] [STARTING: Part 6, Step 3: Design Tokens]

---

# Step 3: Create the Design-Token Foundation

## The Target

Centralize LaunchPad’s colors, typography, spacing, radii, shadows, transitions, and content widths.

## The Concept

A raw CSS value answers a mechanical question:

```css
color: #3457d5;
```

A design token answers a design question:

```css
color: var(--color-primary);
```

The token name explains the value’s responsibility.

Tokens make coordinated changes safer. If the primary brand color changes, we can update one token instead of searching every component for a hexadecimal value.

Token categories in LaunchPad will include:

- Colors
- Fonts
- Font sizes
- Spacing
- Border radii
- Shadows
- Content widths
- Transition timing

## The Implementation

Completely replace the temporary design-token file.

### `src/styles/design-tokens.css`

```css
:root {
  /*
   * Typography
   */
  --font-sans:
    var(--font-geist-sans),
    Arial,
    Helvetica,
    sans-serif;

  --font-mono:
    var(--font-geist-mono),
    "SFMono-Regular",
    Consolas,
    "Liberation Mono",
    monospace;

  --font-size-xs: 0.75rem;
  --font-size-small: 0.875rem;
  --font-size-body: 1rem;
  --font-size-lead: 1.125rem;
  --font-size-heading-small: 1.25rem;
  --font-size-heading-medium: 2rem;
  --font-size-heading-large: clamp(2.5rem, 7vw, 4.75rem);

  --line-height-tight: 1.1;
  --line-height-body: 1.6;

  /*
   * Color roles
   *
   * Components should generally use role-based names rather than raw color
   * names. For example, use --color-text-muted instead of --gray-600.
   */
  --color-background: #f6f8fc;
  --color-surface: #ffffff;
  --color-surface-subtle: #eef2f8;
  --color-surface-emphasis: #e9edff;

  --color-text: #172033;
  --color-text-muted: #59657a;
  --color-text-on-primary: #ffffff;

  --color-border: #dce2ec;
  --color-border-strong: #b8c2d3;

  --color-primary: #3457d5;
  --color-primary-hover: #2946ad;
  --color-primary-soft: #e9edff;

  --color-success: #176b45;
  --color-success-soft: #def7e9;

  --color-warning: #8a5300;
  --color-warning-soft: #fff1cf;

  --color-danger: #a32626;
  --color-danger-soft: #fff0f0;

  --color-planned: #5e4bb6;
  --color-planned-soft: #eeeaff;

  --color-focus: #ffbf47;

  /*
   * Spacing
   *
   * A shared scale helps unrelated components align visually.
   */
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-5: 1.25rem;
  --space-6: 1.5rem;
  --space-8: 2rem;
  --space-10: 2.5rem;
  --space-12: 3rem;
  --space-16: 4rem;
  --space-20: 5rem;

  /*
   * Shape and elevation
   */
  --radius-small: 0.5rem;
  --radius-medium: 0.75rem;
  --radius-large: 1rem;
  --radius-pill: 999rem;

  --shadow-small: 0 0.5rem 1.5rem rgb(23 32 51 / 6%);
  --shadow-card: 0 1rem 2.5rem rgb(23 32 51 / 8%);
  --shadow-raised: 0 1.25rem 3rem rgb(23 32 51 / 14%);

  /*
   * Layout
   */
  --content-width: 72rem;
  --reading-width: 46rem;

  /*
   * Motion
   */
  --duration-fast: 120ms;
  --duration-standard: 180ms;
  --easing-standard: ease;
}

html {
  color-scheme: light;
}

body {
  background-color: var(--color-background);
  color: var(--color-text);
  font-family: var(--font-sans);
  font-size: var(--font-size-body);
  line-height: var(--line-height-body);
}

code,
kbd,
pre,
samp {
  font-family: var(--font-mono);
}
```

### Why the tokens redefine some existing variables

The original global stylesheet already contains variables such as:

```css
--color-primary
--color-border
--shadow-card
```

The token stylesheet is imported after `globals.css`, so its declarations become the final source for those values.

This lets us improve the architecture incrementally instead of performing a risky, all-at-once rewrite of the entire stylesheet.

### Why spacing tokens use a scale

Instead of choosing unrelated values for every component, we use a consistent sequence:

```text
0.25rem
0.5rem
0.75rem
1rem
1.25rem
1.5rem
2rem
```

Not every space must use a token, but a shared scale reduces visual drift.

## The Verification

Open:

```text
http://localhost:3000
```

Inspect the `<body>` element in browser developer tools.

Its computed `font-family` should begin with a generated Geist font.

Inspect the root custom properties and confirm values such as:

```text
--space-4: 1rem
--radius-large: 1rem
--color-primary: #3457d5
```

Run:

```bash
npm run typecheck
npm run lint
```

CSS custom properties do not affect TypeScript, but these commands ensure the broader application remains healthy.

[GENERATED: Part 6, Step 3: Design Tokens] [STARTING: Part 6, Step 4: Accessibility Utilities]

---

# Step 4: Add Global Accessibility and Print Utilities

## The Target

Style the skip link, strengthen focus behavior, support text selection, respect motion preferences, and create sensible print output.

## The Concept

Accessibility styles are application-wide rules rather than component-specific decoration.

A skip link is normally hidden off-screen. When it receives keyboard focus, it becomes visible.

The interaction is:

```text
Load page
   ↓
Press Tab
   ↓
Skip link appears
   ↓
Press Enter
   ↓
Focus moves past repeated navigation
```

Print styles also belong globally. Printed pages should generally omit:

- Navigation
- Interactive buttons
- Decorative backgrounds
- Loading animations

## The Implementation

Completely replace the temporary accessibility stylesheet.

### `src/styles/accessibility.css`

```css
::selection {
  background: var(--color-primary);
  color: var(--color-text-on-primary);
}

/*
 * The skip link remains outside the visible viewport until keyboard focus
 * reaches it. A large z-index keeps it above sticky navigation.
 */
.skip-link {
  position: fixed;
  z-index: 1000;
  top: var(--space-3);
  left: var(--space-3);
  padding: var(--space-3) var(--space-4);
  border: 0.125rem solid var(--color-text);
  border-radius: var(--radius-small);
  background: var(--color-surface);
  color: var(--color-text);
  box-shadow: var(--shadow-raised);
  font-weight: 800;
  text-decoration: none;
  transform: translateY(calc(-100% - 2rem));
  transition: transform var(--duration-fast) var(--easing-standard);
}

.skip-link:focus {
  transform: translateY(0);
}

/*
 * :focus-visible usually displays focus for keyboard interaction without
 * forcing the same ring after an ordinary pointer click.
 */
:where(
  a,
  button,
  input,
  select,
  textarea,
  summary,
  [tabindex]
):focus-visible {
  outline: 0.2rem solid var(--color-focus);
  outline-offset: 0.2rem;
}

/*
 * This utility visually hides text while preserving it for assistive
 * technology. It can be used for labels that have a separate visual form.
 */
.visually-hidden {
  position: absolute !important;
  width: 0.0625rem !important;
  height: 0.0625rem !important;
  padding: 0 !important;
  overflow: hidden !important;
  border: 0 !important;
  margin: -0.0625rem !important;
  clip: rect(0 0 0 0) !important;
  white-space: nowrap !important;
}

/*
 * Ensure anchored content is not hidden beneath sticky navigation.
 */
:target {
  scroll-margin-top: 6rem;
}

@media (prefers-reduced-motion: reduce) {
  html {
    scroll-behavior: auto;
  }

  *,
  *::before,
  *::after {
    scroll-behavior: auto !important;
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }

  .skip-link {
    transition: none;
  }
}

@media print {
  :root {
    --color-background: #ffffff;
    --color-surface: #ffffff;
    --color-text: #000000;
    --color-text-muted: #333333;
    --color-border: #999999;
  }

  body {
    background: #ffffff !important;
    color: #000000;
    font-size: 11pt;
  }

  .skip-link,
  .site-header,
  .site-footer,
  .workspace-sidebar,
  .hero-actions,
  .project-detail-actions,
  .filter-panel,
  .client-search,
  button {
    display: none !important;
  }

  .workspace-shell {
    display: block !important;
  }

  .workspace-main > .site-shell,
  .site-shell {
    width: 100% !important;
    max-width: none !important;
  }

  a {
    color: inherit;
    text-decoration: underline;
  }

  .project-card,
  .feature-card,
  .stat-card,
  .dashboard-stat {
    break-inside: avoid;
    box-shadow: none !important;
  }
}
```

### Add the skip-link target to the marketing layout

Completely replace the marketing layout.

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

      <div
        className="application-shell__content"
        id="main-content"
        tabIndex={-1}
      >
        {children}
      </div>

      <SiteFooter message="Built one verified layer at a time" />
    </div>
  );
}
```

### Add the target to the workspace layout

Completely replace the workspace layout.

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

        <div
          className="workspace-main"
          id="main-content"
          tabIndex={-1}
        >
          {children}
        </div>
      </div>

      <SiteFooter message="Project workspace" />
    </div>
  );
}
```

### Update the root not-found page

The root not-found route is outside both route-group layouts, so it needs its own target.

### `src/app/not-found.tsx`

```tsx
import Link from "next/link";

import { SiteHeader } from "@/components/site-header";

export default function NotFoundPage() {
  return (
    <>
      <SiteHeader />

      <main
        className="site-shell not-found-page"
        id="main-content"
        tabIndex={-1}
      >
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

### Why `tabIndex={-1}` is used

A normal `<div>` cannot receive programmatic or fragment-navigation focus consistently.

This property allows the target to receive focus without adding it to the ordinary Tab sequence:

```tsx
tabIndex={-1}
```

The user can skip to the content, but repeated Tab presses will not stop on the wrapper unnecessarily.

## The Verification

Open:

```text
http://localhost:3000/projects
```

Reload the page and press `Tab`.

Confirm:

1. **Skip to main content** appears visibly.
2. The link has a strong focus outline.
3. Pressing `Enter` moves past the public and workspace navigation.
4. Pressing `Tab` again reaches the first interactive element in the route content.

Repeat on:

```text
http://localhost:3000/about
http://localhost:3000/does-not-exist
```

Inspect duplicate IDs:

```bash
for path in "/" "/about" "/dashboard" "/projects" "/does-not-exist"; do
  count="$(
    curl --silent "http://localhost:3000${path}" |
      grep -o 'id="main-content"' |
      wc -l |
      tr -d " "
  )"

  printf "%-30s main-content count: %s\n" "${path}" "${count}"
done
```

Every page should report:

```text
main-content count: 1
```

Test print preview:

1. Open `/projects`.
2. Open the browser’s Print dialog.
3. Confirm navigation and interactive controls are absent.
4. Confirm project content remains readable.
5. Cancel printing.

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 6, Step 4: Accessibility Utilities] [STARTING: Part 6, Step 5: Status Badge CSS Module]

---

# Step 5: Create a Reusable Status Badge

## The Target

Extract project status presentation into a typed component with locally scoped CSS.

## The Concept

LaunchPad currently repeats this pattern:

```tsx
<span
  className={`status-badge status-badge--${project.status.toLowerCase()}`}
>
  {formatProjectStatus(project.status)}
</span>
```

The pattern contains three responsibilities:

- Converting internal status to a readable label
- Choosing the correct visual variant
- Producing consistent badge markup

A reusable component can own all three.

Its CSS Module will keep classes local to the component.

## The Implementation

Create the CSS Module.

### `src/components/status-badge.module.css`

```css
.badge {
  display: inline-flex;
  min-height: 1.75rem;
  padding: var(--space-1) var(--space-3);
  border: 0.0625rem solid transparent;
  border-radius: var(--radius-pill);
  align-items: center;
  flex: 0 0 auto;
  font-size: var(--font-size-xs);
  font-weight: 800;
  letter-spacing: 0.04em;
  line-height: 1;
  text-transform: uppercase;
}

.active {
  border-color: rgb(52 87 213 / 18%);
  background: var(--color-primary-soft);
  color: var(--color-primary-hover);
}

.planned {
  border-color: rgb(94 75 182 / 18%);
  background: var(--color-planned-soft);
  color: var(--color-planned);
}

.completed {
  border-color: rgb(23 107 69 / 18%);
  background: var(--color-success-soft);
  color: var(--color-success);
}
```

Create the component.

### `src/components/status-badge.tsx`

```tsx
import styles from "@/components/status-badge.module.css";
import {
  formatProjectStatus,
  type ProjectStatus,
} from "@/lib/project-types";

type StatusBadgeProps = {
  status: ProjectStatus;
};

const statusClassNames = {
  ACTIVE: styles.active,
  PLANNED: styles.planned,
  COMPLETED: styles.completed,
} satisfies Record<ProjectStatus, string>;

export function StatusBadge({
  status,
}: StatusBadgeProps) {
  return (
    <span className={`${styles.badge} ${statusClassNames[status]}`}>
      {formatProjectStatus(status)}
    </span>
  );
}
```

### Why the variant map uses `satisfies`

This declaration requires one CSS class for every project status:

```tsx
satisfies Record<ProjectStatus, string>
```

If we later add:

```text
ARCHIVED
```

to `ProjectStatus` but forget to style it, TypeScript reports the missing map entry.

This connects the visual variants to the domain type.

### Why no runtime string is used as a CSS property lookup

We avoid logic such as:

```tsx
styles[status.toLowerCase()]
```

A typed explicit map is easier to verify and refactor.

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

Both commands should succeed.

Confirm that CSS Module classes are imported:

```bash
grep "status-badge.module.css" \
  src/components/status-badge.tsx
```

Expected output:

```tsx
import styles from "@/components/status-badge.module.css";
```

The component is not visible yet. We will use it inside a reusable project card next.

[GENERATED: Part 6, Step 5: Status Badge Component] [STARTING: Part 6, Step 6: Project Card CSS Module]

---

# Step 6: Create a Reusable Project Card

## The Target

Extract repeated project-card markup into a typed reusable component with a locally scoped stylesheet.

## The Concept

The project list and dashboard both display nearly identical project summaries.

Repeated markup can drift:

- One page may forget progress text.
- One page may use a different heading level.
- One page may style status differently.
- Accessibility fixes may be applied in only one location.

A reusable `ProjectCard` will own:

- Project title and URL
- Description
- Status badge
- Progress calculation
- Progress element
- Optional detail link

## The Implementation

Create the component stylesheet.

### `src/components/project-card.module.css`

```css
.card {
  display: flex;
  min-width: 0;
  padding: var(--space-6);
  border: 0.0625rem solid var(--color-border);
  border-radius: var(--radius-large);
  background: var(--color-surface);
  box-shadow: var(--shadow-card);
  flex-direction: column;
  transition:
    border-color var(--duration-standard) var(--easing-standard),
    box-shadow var(--duration-standard) var(--easing-standard),
    transform var(--duration-standard) var(--easing-standard);
}

.card:hover {
  border-color: var(--color-border-strong);
  box-shadow: var(--shadow-raised);
  transform: translateY(-0.125rem);
}

.heading {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: var(--space-4);
}

.title {
  margin: 0;
  font-size: var(--font-size-heading-small);
  line-height: 1.25;
}

.titleLink {
  color: var(--color-text);
  text-decoration: none;
  text-underline-offset: 0.2rem;
}

.titleLink:hover {
  color: var(--color-primary);
  text-decoration: underline;
}

.description {
  margin: var(--space-4) 0;
  color: var(--color-text-muted);
}

.progress {
  padding-top: var(--space-4);
  border-top: 0.0625rem solid var(--color-border);
}

.progressLabels {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
  font-size: var(--font-size-small);
  font-weight: 700;
}

.progressElement {
  display: block;
  width: 100%;
  height: 0.75rem;
  margin-top: var(--space-3);
  overflow: hidden;
  border: 0;
  border-radius: var(--radius-pill);
  appearance: none;
  background: var(--color-surface-subtle);
}

.progressElement::-webkit-progress-bar {
  border-radius: var(--radius-pill);
  background: var(--color-surface-subtle);
}

.progressElement::-webkit-progress-value {
  border-radius: var(--radius-pill);
  background: var(--color-primary);
}

.progressElement::-moz-progress-bar {
  border-radius: var(--radius-pill);
  background: var(--color-primary);
}

.progressDescription {
  margin: var(--space-2) 0 0;
  color: var(--color-text-muted);
  font-size: var(--font-size-small);
}

.detailLink {
  margin-top: auto;
  padding-top: var(--space-5);
  color: var(--color-primary);
  font-weight: 700;
  text-decoration: underline;
  text-decoration-thickness: 0.0625rem;
  text-underline-offset: 0.2rem;
}

.detailLink:hover {
  color: var(--color-primary-hover);
  text-decoration-thickness: 0.125rem;
}

@media (max-width: 30rem) {
  .heading {
    flex-direction: column;
  }
}

@media (prefers-reduced-motion: reduce) {
  .card {
    transition: none;
  }

  .card:hover {
    transform: none;
  }
}

@media print {
  .card {
    break-inside: avoid;
    box-shadow: none;
  }

  .detailLink {
    display: none;
  }
}
```

Create the component.

### `src/components/project-card.tsx`

```tsx
import Link from "next/link";

import styles from "@/components/project-card.module.css";
import { StatusBadge } from "@/components/status-badge";
import {
  calculateProjectProgress,
  type ProjectSummary,
} from "@/lib/project-types";

type ProjectCardProps = {
  project: ProjectSummary;
  showDetailLink?: boolean;
};

export function ProjectCard({
  project,
  showDetailLink = true,
}: ProjectCardProps) {
  const progress = calculateProjectProgress(project);
  const projectUrl = `/projects/${project.id}`;

  return (
    <article className={styles.card}>
      <div className={styles.heading}>
        <h3 className={styles.title}>
          <Link className={styles.titleLink} href={projectUrl}>
            {project.name}
          </Link>
        </h3>

        <StatusBadge status={project.status} />
      </div>

      <p className={styles.description}>{project.description}</p>

      <div className={styles.progress}>
        <div className={styles.progressLabels}>
          <span>Task progress</span>
          <span>{progress}%</span>
        </div>

        <progress
          className={styles.progressElement}
          max={100}
          value={progress}
          aria-label={`${project.name} task completion`}
        >
          {progress}%
        </progress>

        <p className={styles.progressDescription}>
          {project.completedTaskCount} of {project.taskCount} tasks completed
        </p>
      </div>

      {showDetailLink ? (
        <Link className={styles.detailLink} href={projectUrl}>
          View project details
          <span aria-hidden="true"> →</span>
        </Link>
      ) : null}
    </article>
  );
}
```

### Why the component accepts a complete project

The component’s contract is:

```tsx
project: ProjectSummary
```

That is clearer than passing six independent properties:

```tsx
<ProjectCard
  id={project.id}
  name={project.name}
  description={project.description}
  status={project.status}
  taskCount={project.taskCount}
  completedTaskCount={project.completedTaskCount}
/>
```

The project summary is already a well-defined application value.

### Why the detail link is optional

The full project list benefits from an explicit action link.

The dashboard cards already sit under a section with a route to the filtered list. We can omit the secondary detail action there while keeping the title link available.

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

Confirm the new files exist:

```bash
find src/components \
  -maxdepth 1 \
  -type f \
  \( -name "project-card*" -o -name "status-badge*" \) |
  sort
```

Expected output:

```text
src/components/project-card.module.css
src/components/project-card.tsx
src/components/status-badge.module.css
src/components/status-badge.tsx
```

[GENERATED: Part 6, Step 6: Project Card Component] [STARTING: Part 6, Step 7: Refactor the Interactive Project List]

---

# Step 7: Use the Reusable Card in the Client Project List

## The Target

Replace duplicated project-card markup in `ProjectList` with the reusable component.

## The Concept

A Client Component may import an environment-neutral component.

Because `ProjectList` is a Client Component, its runtime imports become part of the client dependency graph. `ProjectCard` is safe because it imports only:

- `next/link`
- CSS Modules
- Shared types and pure calculations
- Another environment-neutral component

It does not import:

- The database client
- Server environment variables
- Server-only query functions

## The Implementation

Completely replace the project-list component.

### `src/components/project-list.tsx`

```tsx
"use client";

import { useMemo, useState } from "react";

import { ProjectCard } from "@/components/project-card";
import {
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
          <label htmlFor="project-search">
            Search visible projects
          </label>
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
          {visibleProjects.length === 1
            ? "project"
            : "projects"}
        </p>
      </div>

      {visibleProjects.length > 0 ? (
        <div className="project-grid">
          {visibleProjects.map((project) => (
            <ProjectCard
              key={project.id}
              project={project}
            />
          ))}
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

### Why the interactive parent remains client-side

`ProjectList` still needs:

```tsx
useState
useMemo
onChange
onClick
```

The reusable card itself does not declare `"use client"`, but when imported by a Client Component it participates in that client component graph.

The same card can also be imported by a Server Component, as we will do next.

## The Verification

Open:

```text
http://localhost:3000/projects
```

Confirm:

- Project cards retain their content.
- Status badges render correctly.
- Cards have a subtle raised hover state.
- Text search still filters immediately.
- Clear search still works.
- Detail links still open UUID-based routes.

Search for:

```text
documentation
```

Only Documentation hub should remain.

Clear the search and apply:

```text
Completed
```

through the status form. The server should return one project, using the same card component.

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 6, Step 7: Project List Refactor] [STARTING: Part 6, Step 8: Refactor Dashboard Cards]

---

# Step 8: Reuse the Card in the Server-Rendered Dashboard

## The Target

Replace the dashboard’s duplicated project markup with the same `ProjectCard` component.

## The Concept

A reusable component can appear in both server and client component trees if its own dependencies are compatible with both environments.

The dashboard component is server-rendered:

```text
DashboardActiveProjects
    ↓
PostgreSQL query
    ↓
ProjectCard
```

The project list uses the same card under a client boundary:

```text
ProjectList
    ↓
Browser search state
    ↓
ProjectCard
```

One visual component now supports both rendering contexts.

## The Implementation

Completely replace the dashboard active-project component.

### `src/components/dashboard-active-projects.tsx`

```tsx
import Link from "next/link";

import { ProjectCard } from "@/components/project-card";
import { getActiveProjects } from "@/lib/database/project-queries";

export async function DashboardActiveProjects() {
  const activeProjects = await getActiveProjects(4);

  return (
    <section
      className="dashboard-section"
      aria-labelledby="active-projects-heading"
    >
      <div className="results-heading">
        <div>
          <p className="eyebrow">Current focus</p>
          <h2 id="active-projects-heading">
            Active projects
          </h2>
        </div>

        <Link className="text-link" href="/projects?status=ACTIVE">
          View filtered list
          <span aria-hidden="true"> →</span>
        </Link>
      </div>

      {activeProjects.length > 0 ? (
        <div className="project-grid">
          {activeProjects.map((project) => (
            <ProjectCard
              key={project.id}
              project={project}
              showDetailLink={false}
            />
          ))}
        </div>
      ) : (
        <div className="empty-state">
          <h3>No active projects</h3>
          <p>
            Active projects will appear here when work begins.
          </p>
        </div>
      )}
    </section>
  );
}
```

### Why this remains a Server Component

The file does not contain:

```tsx
"use client";
```

It can still call:

```tsx
getActiveProjects(4)
```

from the protected server-only query layer.

The reusable card does not force its parent to become a Client Component.

## The Verification

Open:

```text
http://localhost:3000/dashboard
```

Confirm that:

- Website redesign appears.
- Analytics dashboard appears.
- Both use the new card design.
- Status badges match the project-list badges.
- Project titles remain links.
- The dashboard omits the additional “View project details” links.
- Task progress remains accurate.

Verify server-rendered content:

```bash
dashboard_page="$(
  curl --fail --silent http://localhost:3000/dashboard
)"

printf "%s" "${dashboard_page}" |
  grep --quiet "Website redesign"

printf "%s" "${dashboard_page}" |
  grep --quiet "Analytics dashboard"

echo "Reusable server-rendered project cards verified."
```

Expected output:

```text
Reusable server-rendered project cards verified.
```

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 6, Step 8: Dashboard Card Refactor] [STARTING: Part 6, Step 9: Refactor Project Detail Status]

---

# Step 9: Use the Shared Status Badge on Project Details

## The Target

Replace the final repeated project-status markup on the project-detail page.

## The Concept

A reusable component only provides consistency if all equivalent interfaces use it.

The project-detail page currently maintains a separate status-badge implementation. We will replace that implementation while preserving the page’s server-side data behavior.

## The Implementation

Open:

```text
src/app/(workspace)/projects/[projectId]/page.tsx
```

Add this import beside the other component imports:

```tsx
import { StatusBadge } from "@/components/status-badge";
```

Change the project-type utility import from:

```tsx
import {
  calculateProjectProgress,
  formatProjectStatus,
} from "@/lib/project-types";
```

to:

```tsx
import {
  calculateProjectProgress,
} from "@/lib/project-types";
```

Replace this block:

```tsx
<span
  className={`status-badge status-badge--${project.status.toLowerCase()}`}
>
  {formatProjectStatus(project.status)}
</span>
```

with:

```tsx
<StatusBadge status={project.status} />
```

The surrounding heading must now look exactly like this:

```tsx
<header className="project-detail-heading">
  <div>
    <p className="eyebrow">Project details</p>
    <h1>{project.name}</h1>
    <p>{project.description}</p>
  </div>

  <StatusBadge status={project.status} />
</header>
```

No other part of the file changes.

## The Verification

Run:

```bash
npm run typecheck
npm run lint
```

Open:

```text
http://localhost:3000/projects/10000000-0000-4000-8000-000000000001
```

Confirm the Active badge matches the badge used on project cards.

Open the completed project:

```text
http://localhost:3000/projects/10000000-0000-4000-8000-000000000003
```

Confirm its badge displays:

```text
Completed
```

Search for old status-badge markup:

```bash
grep -R \
  'status-badge--' \
  src \
  --include="*.tsx" || true
```

Expected result:

```text
No matches
```

The old global CSS may still contain `.status-badge` selectors, but no component should use them now. We will discuss incremental CSS cleanup in the reference sections.

[GENERATED: Part 6, Step 9: Shared Detail Status] [STARTING: Part 6, Step 10: Responsive Content and Reading Styles]

---

# Step 10: Strengthen Responsive Typography and Content Flow

## The Target

Add final global refinements for readable text, overflow prevention, touch targets, and responsive media.

## The Concept

Responsive design is not only about media queries.

A resilient interface also needs:

- Text that wraps instead of overflowing
- Images that stay within their containers
- Controls large enough to activate
- Long identifiers that do not break layouts
- Comfortable reading widths
- Consistent heading balance

We will append a small set of global resilience rules.

## The Implementation

Append the following section to the end of:

### `src/app/globals.css`

```css
/* Part 6: responsive typography and layout resilience */

img,
svg,
video,
canvas {
  max-width: 100%;
  height: auto;
}

p,
li,
dd {
  overflow-wrap: break-word;
}

h1,
h2,
h3 {
  text-wrap: balance;
}

p {
  text-wrap: pretty;
}

button,
select,
input,
textarea {
  min-height: 2.75rem;
}

.page-heading > p:last-child,
.hero-description,
.prose-content {
  max-width: var(--reading-width);
}

.project-grid {
  align-items: stretch;
}

.project-grid > * {
  min-width: 0;
}

@media (pointer: coarse) {
  .navigation-link,
  .workspace-navigation a,
  .text-link {
    min-height: 2.75rem;
  }
}
```

### Why `min-width: 0` matters

Grid children can sometimes refuse to shrink below the width of their content.

This rule allows long project names or descriptions to remain inside the grid:

```css
.project-grid > * {
  min-width: 0;
}
```

### Why touch input receives larger targets

This media query detects a coarse pointing device such as a touchscreen:

```css
@media (pointer: coarse)
```

Interactive targets receive a minimum height that is easier to activate reliably.

### Why heading text uses balanced wrapping

This rule asks supporting browsers to distribute heading words more evenly:

```css
text-wrap: balance;
```

It is a progressive enhancement. Browsers that do not support it still display ordinary wrapped text.

## The Verification

Open browser developer tools and test these viewport widths:

```text
1440px
1024px
768px
390px
320px
```

Inspect:

```text
/
/about
/dashboard
/projects
/projects/10000000-0000-4000-8000-000000000001
```

Confirm:

- No route causes horizontal page scrolling.
- Navigation remains reachable.
- Project card headings wrap without escaping cards.
- Project card status badges remain readable.
- Forms stack correctly on narrow screens.
- Dashboard statistics become one column.
- Project detail statistics remain readable.
- Buttons remain comfortably sized.

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 6, Step 10: Responsive Refinements] [STARTING: Part 6, Step 11: Accessibility Verification]

---

# Step 11: Verify Styling Accessibility

## The Target

Test keyboard operation, focus visibility, color-independent meaning, motion preferences, zoom, and print output.

## The Concept

A visual interface is not complete merely because it looks polished at one desktop size.

Accessibility verification asks whether the interface remains usable when someone:

- Uses only a keyboard
- Zooms the page
- Requests reduced motion
- Uses a screen reader
- Has difficulty distinguishing colors
- Prints important information

Automated checks are helpful, but they cannot replace direct interaction testing.

## The Implementation

Make sure the database and development server are running:

```bash
npm run db:start
npm run dev
```

### Keyboard test

Open:

```text
http://localhost:3000/projects
```

Perform these actions without using a mouse:

1. Reload the page.
2. Press `Tab`.
3. Confirm the skip link appears.
4. Press `Enter`.
5. Continue pressing `Tab`.
6. Confirm the status select receives focus.
7. Confirm the Apply filter button receives focus.
8. Confirm the project search receives focus.
9. Enter `website`.
10. Continue to the Clear button.
11. Activate Clear with `Enter`.
12. Continue to a project title link.
13. Activate it.

Every focused control should have a clearly visible outline.

### Zoom test

Set browser zoom to:

```text
200%
```

Confirm:

- Text remains readable.
- Content does not overlap.
- Navigation can still be reached.
- Controls do not disappear.
- Horizontal scrolling is limited to intentionally scrollable navigation regions.

Return zoom to `100%` after the test.

### Reduced-motion test

In browser developer tools, emulate:

```text
prefers-reduced-motion: reduce
```

Confirm:

- Skeleton shimmer no longer animates.
- Card hover movement is disabled.
- Skip-link transitions are disabled.
- Smooth scrolling is disabled.

### Color-independent status test

Inspect project status badges.

Confirm each badge includes text:

```text
Active
Planned
Completed
```

The color is supplemental. Users do not need to distinguish colors to understand the status.

### Print test

Open:

```text
http://localhost:3000/projects/10000000-0000-4000-8000-000000000001
```

Open print preview.

Confirm:

- Site navigation is absent.
- Workspace navigation is absent.
- Copy and other action buttons are absent.
- Project name and statistics remain visible.
- Text is black on white.
- Cards do not use decorative shadows.

## The Verification

Run this route-status check:

```bash
for path in \
  "/" \
  "/about" \
  "/features" \
  "/dashboard" \
  "/projects" \
  "/projects/10000000-0000-4000-8000-000000000001"
do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000${path}"
  )"

  printf "%-70s %s\n" "${path}" "${status_code}"
done
```

Every route should return:

```text
200
```

Verify every representative route contains the skip link:

```bash
for path in "/" "/about" "/dashboard" "/projects"; do
  curl --fail --silent "http://localhost:3000${path}" |
    grep --quiet "Skip to main content"

  echo "Skip link found: ${path}"
done
```

Expected output lists all four routes.

Run:

```bash
npm run typecheck
npm run lint
```

[GENERATED: Part 6, Step 11: Accessibility Verification] [STARTING: Part 6, Step 12: CSS Boundary Verification]

---

# Step 12: Verify the Styling Boundaries

## The Target

Confirm that component CSS is locally scoped and that server-only modules have not crossed into the client styling refactor.

## The Concept

A styling refactor can accidentally become an architectural refactor.

For example, a reusable component imported by a Client Component must not import a database query function merely to calculate its display.

Our component chain is safe:

```text
Client ProjectList
    ↓
ProjectCard
    ↓
StatusBadge
    ↓
Shared project types and pure functions
```

There is no path to:

```text
Database client
Environment secrets
Server-only query layer
```

## The Implementation

Inspect client directives:

```bash
grep -R '"use client"' src/components --include="*.tsx"
```

Expected Client Components include:

```text
copy-project-link.tsx
interactive-disclosure.tsx
project-list.tsx
workspace-navigation.tsx
```

`project-card.tsx` and `status-badge.tsx` should not declare `"use client"`.

Confirm the reusable components do not import database code:

```bash
if grep -E \
  'database|environment|server-only' \
  src/components/project-card.tsx \
  src/components/status-badge.tsx; then
  echo "A reusable visual component imported server infrastructure."
  exit 1
else
  echo "Reusable visual components are environment-neutral."
fi
```

Expected output:

```text
Reusable visual components are environment-neutral.
```

Confirm the CSS Modules are used only through imports:

```bash
grep -R \
  'project-card.module.css\|status-badge.module.css' \
  src \
  --include="*.tsx"
```

Expected output identifies:

```text
src/components/project-card.tsx
src/components/status-badge.tsx
```

## The Verification

Run the full source quality gate:

```bash
npm run typecheck
npm run lint
```

Confirm that no Client Component imports the query layer:

```bash
for file in $(grep -Rl '"use client"' src --include="*.tsx"); do
  if grep -q 'database/project-queries' "${file}"; then
    echo "Unsafe server query import in ${file}"
    exit 1
  fi
done

echo "Client components do not import database queries."
```

Expected output:

```text
Client components do not import database queries.
```

[GENERATED: Part 6, Step 12: CSS Boundary Verification] [STARTING: Part 6, Step 13: Production Build]

---

# Step 13: Verify the Production Build

## The Target

Build the optimized application and verify fonts, CSS Modules, global styles, and database-backed routes in production mode.

## The Concept

Next.js processes CSS Modules during the production build.

It:

- Generates scoped class names
- Extracts and optimizes styles
- Connects styles to the routes that use them
- Processes font configuration
- Produces hashed asset files
- Validates server and client module graphs

Development mode working correctly does not guarantee that production CSS extraction or font processing will succeed.

## The Implementation

Stop the development server:

```text
Ctrl+C
```

Ensure PostgreSQL is available:

```bash
npm run db:start
npm run db:status
```

Run:

```bash
npm run typecheck
npm run lint
npm run build
```

After the build succeeds, start the production server:

```bash
npm run start
```

## The Verification

In a second terminal, run:

```bash
for path in \
  "/" \
  "/dashboard" \
  "/projects" \
  "/projects/10000000-0000-4000-8000-000000000001"
do
  status_code="$(
    curl --silent \
      --output /dev/null \
      --write-out "%{http_code}" \
      "http://localhost:3000${path}"
  )"

  printf "%-70s %s\n" "${path}" "${status_code}"
done
```

Every route should return:

```text
200
```

Confirm CSS assets are linked:

```bash
curl --silent http://localhost:3000/projects |
  grep -o '/_next/static/css/[^"]*' |
  sort -u
```

The response should list one or more generated CSS assets.

Confirm font assets are referenced:

```bash
curl --silent http://localhost:3000 |
  grep -o '/_next/static/media/[^"]*' |
  sort -u
```

The exact generated filenames vary.

Open:

```text
http://localhost:3000/projects
```

Confirm:

- Geist typography is active.
- CSS Module card styles appear.
- Status badge variants appear.
- Search still works.
- Server filtering still works.
- Focus styles remain visible.
- Responsive behavior works.

Stop the production server:

```text
Ctrl+C
```

[GENERATED: Part 6, Step 13: Production Build] [STARTING: Part 6, Step 14: Git Checkpoint]

---

# Step 14: Create the Part 6 Git Checkpoint

## The Target

Commit the typography, token, accessibility, CSS Module, and component-refactoring work.

## The Concept

This commit captures a styling architecture rather than only a visual redesign.

Its important engineering changes include:

- Global and component style boundaries
- Typed visual variants
- Reusable project presentation
- Optimized fonts
- Keyboard navigation improvements
- Print and reduced-motion behavior

## The Implementation

Inspect the repository:

```bash
git status
git diff --stat
git diff
```

Run the final quality gate:

```bash
npm run typecheck
npm run lint
npm run build
```

Stage the changes:

```bash
git add src
```

Inspect staged files:

```bash
git diff --cached --stat
```

Create the commit:

```bash
git commit -m "feat: add scalable styling architecture"
```

## The Verification

Inspect the latest commit:

```bash
git log -1 --oneline
```

Expected output resembles:

```text
c3d4e5f feat: add scalable styling architecture
```

Confirm a clean working tree:

```bash
git status
```

Expected output:

```text
nothing to commit, working tree clean
```

[GENERATED: Part 6, Step 14: Git Checkpoint] [STARTING: Part 6 Reference Sections]

---

# Part 6 Reference A: Global CSS

Global CSS applies throughout the application.

Appropriate responsibilities include:

- Browser normalization
- Root design tokens
- Body typography
- Application shells
- Shared page-layout primitives
- Accessibility utilities
- Print behavior

Example:

```css
*,
*::before,
*::after {
  box-sizing: border-box;
}

body {
  margin: 0;
  color: var(--color-text);
  font-family: var(--font-sans);
}
```

Global CSS should be used intentionally because its selectors can affect every matching element.

Avoid vague global classes such as:

```css
.card {
  /* Which card does this control? */
}
```

A component-specific card is usually a better candidate for a CSS Module.

---

# Part 6 Reference B: CSS Modules

A CSS Module uses a filename ending in:

```text
.module.css
```

Example:

### `example-card.module.css`

```css
.card {
  padding: 1rem;
  border-radius: 0.75rem;
}
```

Import it into a component:

```tsx
import styles from "./example-card.module.css";

export function ExampleCard() {
  return <article className={styles.card}>Content</article>;
}
```

Next.js generates a scoped class name rather than exposing a plain global `.card` selector.

Benefits include:

- Local class-name scope
- Clear component ownership
- Safe reuse of ordinary names
- Route-aware CSS processing
- No runtime styling library required
- Familiar CSS syntax

CSS Modules do not scope:

- CSS custom properties inherited from ancestors
- Element styles applied through global stylesheets
- Explicit `:global(...)` selectors

---

# Part 6 Reference C: Design Tokens

Design tokens are named visual decisions.

## Primitive token

A primitive names the value itself:

```css
--blue-600: #3457d5;
```

## Semantic token

A semantic token names its role:

```css
--color-primary: #3457d5;
```

Semantic tokens make theme and brand changes easier because components depend on the role rather than a specific hue.

Prefer:

```css
.button {
  background: var(--color-primary);
}
```

over:

```css
.button {
  background: #3457d5;
}
```

Tokens are useful for:

- Colors
- Spacing
- Typography
- Border radii
- Shadows
- Motion
- Breakpoints
- Layering

Do not create a token for every unique CSS value. A token should represent a meaningful shared decision.

---

# Part 6 Reference D: Styling Approaches in Next.js

Next.js supports several styling approaches.

## Global CSS

Best for:

- Resets
- Document defaults
- Design tokens
- Application shells
- Third-party global styles

## CSS Modules

Best for:

- Reusable components
- Locally scoped class names
- Traditional CSS with build-time scoping

## Tailwind CSS

Tailwind provides utility classes such as:

```tsx
<div className="rounded-lg border bg-white p-6">
  Content
</div>
```

Benefits include:

- Fast composition
- Consistent configured scales
- Styles colocated with markup
- Strong ecosystem support

Trade-offs include:

- Longer class attributes
- A separate utility vocabulary
- Team conventions are required
- Complex repeated patterns still benefit from components

LaunchPad uses CSS and CSS Modules so beginners can see the underlying browser styling model directly. Tailwind would also be a valid production choice if selected intentionally.

## CSS-in-JS

Some libraries generate styles from JavaScript or TypeScript.

When choosing one for the App Router, verify:

- React Server Component support
- Streaming compatibility
- Runtime cost
- Server-side extraction behavior
- Maintenance status

Do not assume every older React styling library works optimally with modern server rendering.

## Inline styles

React supports:

```tsx
<div style={{ color: "red" }}>
  Warning
</div>
```

Inline styles are useful for genuinely dynamic values, but they do not naturally support:

- Media queries
- Pseudo-classes
- Reusable style rules
- Rich hover and focus behavior

They should not replace a maintainable stylesheet architecture.

---

# Part 6 Reference E: `next/font`

Next.js font integration can provide:

- Self-hosted font assets
- Generated fallback behavior
- Reduced external browser requests
- CSS variable integration
- Build-time optimization

Example:

```tsx
import { Geist } from "next/font/google";

const geist = Geist({
  subsets: ["latin"],
  variable: "--font-geist",
  display: "swap",
});
```

Apply the generated variable class:

```tsx
<body className={geist.variable}>
```

Use it in CSS:

```css
body {
  font-family:
    var(--font-geist),
    sans-serif;
}
```

## Local fonts

If your project owns licensed font files, use `next/font/local`:

```tsx
import localFont from "next/font/local";

const brandFont = localFont({
  src: "./fonts/brand-font.woff2",
  variable: "--font-brand",
});
```

Only commit font files when their license permits redistribution.

---

# Part 6 Reference F: Responsive Design

Responsive design adapts to available space and user capabilities.

It includes more than width-based media queries.

## Viewport width

```css
@media (max-width: 48rem) {
  .grid {
    grid-template-columns: 1fr;
  }
}
```

## Motion preference

```css
@media (prefers-reduced-motion: reduce) {
  .card {
    transition: none;
  }
}
```

## Pointer accuracy

```css
@media (pointer: coarse) {
  .button {
    min-height: 2.75rem;
  }
}
```

## Print output

```css
@media print {
  nav,
  button {
    display: none;
  }
}
```

## Flexible sizing

```css
font-size: clamp(2rem, 5vw, 4rem);
```

A resilient interface combines these techniques rather than assuming one desktop viewport.

---

# Part 6 Reference G: Focus Styles

Keyboard users need to know which element will receive an action.

Avoid removing outlines without replacing them:

```css
button:focus {
  outline: none;
}
```

Prefer:

```css
button:focus-visible {
  outline: 0.2rem solid var(--color-focus);
  outline-offset: 0.2rem;
}
```

The focus indicator should have sufficient contrast against surrounding colors.

Focus should also follow a logical document order. CSS can visually rearrange content, but excessive visual reordering may make keyboard navigation confusing.

---

# Part 6 Reference H: Skip Links

A skip link helps keyboard and assistive-technology users bypass repeated page chrome.

Markup:

```tsx
<a className="skip-link" href="#main-content">
  Skip to main content
</a>
```

Target:

```tsx
<div id="main-content" tabIndex={-1}>
  {children}
</div>
```

The target ID must:

- Exist on the page
- Be unique
- Represent the start of meaningful route content

Do not create multiple elements with:

```text
id="main-content"
```

on one page.

---

# Part 6 Reference I: Color and Meaning

Color should not be the only way an interface communicates meaning.

Insufficient:

```text
Green circle
Red circle
```

A user unable to distinguish the colors may not understand them.

Better:

```text
Completed
Blocked
```

with color used as additional reinforcement.

LaunchPad status badges always include readable text:

```tsx
<StatusBadge status="COMPLETED" />
```

Result:

```text
Completed
```

The green presentation supports the meaning but does not create it.

---

# Part 6 Reference J: Contrast

Text and controls need enough contrast against their backgrounds.

Common WCAG contrast targets include:

- `4.5:1` for ordinary text
- `3:1` for large text
- `3:1` for meaningful interface boundaries and states

Contrast must be tested for:

- Normal text
- Muted text
- Links
- Focus rings
- Status badges
- Disabled controls
- Hover states
- Error messages

Do not assume that darker-looking colors automatically pass.

Useful testing tools include:

- Browser accessibility inspectors
- Lighthouse
- Axe
- Standalone contrast checkers

Automated tools should supplement manual testing.

---

# Part 6 Reference K: Reduced Motion

Animation can cause discomfort for some users.

Operating systems expose a preference:

```css
@media (prefers-reduced-motion: reduce)
```

When that preference is active, remove or reduce nonessential:

- Parallax
- Shimmer effects
- Large movement
- Smooth scrolling
- Long transitions
- Repeating animation

Do not disable essential state communication. Replace motion with a stable visual state when necessary.

---

# Part 6 Reference L: CSS Module Component Variants

A component variant changes presentation within a defined component API.

Our status component uses:

```tsx
const statusClassNames = {
  ACTIVE: styles.active,
  PLANNED: styles.planned,
  COMPLETED: styles.completed,
} satisfies Record<ProjectStatus, string>;
```

This is preferable to exposing arbitrary styling strings:

```tsx
<StatusBadge className="whatever-the-caller-wants" />
```

A controlled variant API preserves consistency and makes allowed visual states discoverable.

Arbitrary `className` escape hatches can still be useful, but they should be added for a concrete requirement rather than by default.

---

# Part 6 Reference M: Incremental Global CSS Cleanup

After extracting project cards and status badges, the original global stylesheet still contains selectors such as:

```css
.project-card
.status-badge
```

They are now unused by application markup.

Removing them is safe only after confirming no templates still use those classes:

```bash
grep -R \
  'className="project-card\|status-badge--' \
  src \
  --include="*.tsx"
```

A production team may use tools such as:

- Browser coverage reports
- Static CSS analysis
- Visual regression tests
- Component tests

Unused CSS cleanup should be incremental and verified. Blindly deleting large global sections can remove selectors used by loading skeletons or related compound rules.

For this tutorial, leaving the inactive selectors temporarily is safer than performing an unrelated full stylesheet rewrite. The CSS Module definitions are the authoritative styles for the extracted components.

---

# Part 6 Reference N: Current Styling Structure

After Part 6, the relevant structure is:

```text
src/
├── app/
│   ├── globals.css
│   ├── layout.tsx
│   └── ...
├── components/
│   ├── project-card.module.css
│   ├── project-card.tsx
│   ├── status-badge.module.css
│   ├── status-badge.tsx
│   └── ...
└── styles/
    ├── accessibility.css
    └── design-tokens.css
```

The cascade is loaded in this order:

```tsx
import "./globals.css";
import "@/styles/design-tokens.css";
import "@/styles/accessibility.css";
```

Responsibilities are:

```text
globals.css
├── Existing application layout
├── Shared page patterns
└── Legacy global component styles

design-tokens.css
├── Final token values
├── Font families
└── Root typography

accessibility.css
├── Skip link
├── Focus behavior
├── Reduced motion
└── Print behavior

*.module.css
└── Locally scoped component implementation
```

---

# Part 6 Reference O: Common Styling Mistakes

## Mistake 1: Making every style global

Global selectors can affect unrelated components and become difficult to remove.

Use CSS Modules for component-owned styles.

## Mistake 2: Using raw values everywhere

Repeated values drift:

```css
padding: 15px;
padding: 16px;
padding: 17px;
```

Use a deliberate spacing system where consistency matters.

## Mistake 3: Removing focus outlines

A pointer user may not notice, but keyboard users lose their location.

## Mistake 4: Communicating state only through color

Always include text, structure, or another non-color indicator.

## Mistake 5: Designing only at one viewport

Test narrow, medium, wide, zoomed, print, and reduced-motion conditions.

## Mistake 6: Marking visual components as client-side unnecessarily

CSS Modules do not require:

```tsx
"use client";
```

A styled component can remain server-compatible unless it needs browser interaction.

## Mistake 7: Importing server code into a visual component

A reusable card should receive data through props rather than querying the database itself when it may appear below a client boundary.

## Mistake 8: Generating class names from untrusted input

Avoid passing arbitrary URL or user values directly into class-name construction.

Use typed variant maps.

## Mistake 9: Ignoring print output

Users may print project summaries for meetings, reviews, or offline reference. Interactive chrome should not consume the printed page.

## Mistake 10: Treating a design system as only a component library

A design system also includes:

- Tokens
- Accessibility rules
- Content patterns
- Interaction behavior
- Layout principles
- Documentation
- Governance

---

# Part 6 Completion Checklist

Before continuing, confirm every item:

- [ ] Geist Sans and Geist Mono are configured with `next/font`.
- [ ] Font variables are available through CSS.
- [ ] Design tokens define shared visual roles.
- [ ] Component styles use design tokens where practical.
- [ ] The skip link appears on keyboard focus.
- [ ] Marketing routes contain one `main-content` target.
- [ ] Workspace routes contain one `main-content` target.
- [ ] The not-found route contains one `main-content` target.
- [ ] Focus indicators remain visible.
- [ ] Reduced-motion preferences disable nonessential animation.
- [ ] Print output removes navigation and interactive controls.
- [ ] Status badges use a locally scoped CSS Module.
- [ ] Every project status has a typed visual variant.
- [ ] Status meaning does not depend on color alone.
- [ ] Project cards use a locally scoped CSS Module.
- [ ] The project list uses the reusable `ProjectCard`.
- [ ] The dashboard uses the same `ProjectCard`.
- [ ] Project details use the reusable `StatusBadge`.
- [ ] Project search still updates immediately.
- [ ] Server-side status filtering still works.
- [ ] Database queries remain server-only.
- [ ] Reusable visual components remain environment-neutral.
- [ ] Project routes remain usable at narrow viewport widths.
- [ ] The interface remains usable at 200% zoom.
- [ ] Interactive targets are comfortably sized.
- [ ] Project names and descriptions wrap without overflowing.
- [ ] CSS assets are generated in the production build.
- [ ] Font assets are self-hosted in the production build.
- [ ] `npm run typecheck` succeeds.
- [ ] `npm run lint` succeeds.
- [ ] `npm run build` succeeds.
- [ ] Production-mode routes return `200`.
- [ ] Git contains the Part 6 checkpoint.
- [ ] `git status` reports a clean working tree.

LaunchPad now has a scalable styling architecture. Global CSS owns the application foundation, design tokens centralize shared decisions, accessibility utilities handle application-wide behavior, and CSS Modules give reusable components local style ownership.

The styling layer remains compatible with both Server and Client Components, and the database boundary remains safely isolated from browser code.
