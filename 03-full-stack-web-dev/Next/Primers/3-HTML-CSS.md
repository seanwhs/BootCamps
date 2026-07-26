# Primer 3: HTML, CSS, Accessibility, and Responsive Design Foundations

This primer prepares you for the markup and styling patterns used throughout LaunchPad.

You will learn:

- Semantic HTML
- Headings and document structure
- Forms and labels
- Links versus buttons
- CSS selectors
- Box model
- Flexbox and Grid
- Responsive design
- Focus styles
- Accessible status and error messages
- CSS custom properties
- CSS Modules

---

## 1. HTML Gives Content Meaning

HTML is not only visual structure. It tells browsers and assistive technology what content means.

Compare these two examples.

Less meaningful:

```html
<div class="title">Projects</div>
<div class="content">
  <div class="card">Website redesign</div>
</div>
```

More meaningful:

```html
<main>
  <h1>Projects</h1>

  <article>
    <h2>Website redesign</h2>
  </article>
</main>
```

The second version tells a screen reader:

```text
- This is the main content.
- This is the primary page heading.
- This is a self-contained project item.
- This project has its own heading.
```

LaunchPad uses semantic HTML wherever possible.

---

## 2. Core Semantic Elements

### `<main>`

Use `<main>` for the primary content of a page.

```tsx
export default function ProjectsPage() {
  return (
    <main>
      <h1>Projects</h1>
    </main>
  );
}
```

A document should generally contain one primary main-content landmark.

---

### `<header>`

Use `<header>` for introductory content or navigation.

```tsx
<header>
  <h1>Projects</h1>
  <p>Manage your current work.</p>
</header>
```

A page may have more than one `<header>` when each one belongs to a meaningful section or article.

---

### `<nav>`

Use `<nav>` for a collection of navigation links.

```tsx
<nav aria-label="Primary navigation">
  <ul>
    <li>
      <a href="/">Home</a>
    </li>
    <li>
      <a href="/projects">Projects</a>
    </li>
  </ul>
</nav>
```

The `aria-label` distinguishes one navigation area from another.

LaunchPad uses labels such as:

```text
Primary navigation
Workspace navigation
Breadcrumb
```

---

### `<section>`

Use `<section>` for a meaningful thematic group of content.

```tsx
<section aria-labelledby="active-projects-heading">
  <h2 id="active-projects-heading">
    Active projects
  </h2>

  <p>Projects currently in progress.</p>
</section>
```

A section should normally have a heading.

---

### `<article>`

Use `<article>` for a self-contained item that could make sense independently.

Examples include:

```text
Project card
Task card
Blog post
Documentation article
Notification item
```

Example:

```tsx
<article>
  <h3>Website redesign</h3>
  <p>Improve performance and accessibility.</p>
</article>
```

---

### `<aside>`

Use `<aside>` for supporting information related to surrounding content.

LaunchPad uses an aside for workspace navigation:

```tsx
<aside className="workspace-sidebar">
  <WorkspaceNavigation />
</aside>
```

---

### `<footer>`

Use `<footer>` for closing information about a page, section, or application.

```tsx
<footer>
  <p>LaunchPad · Private project workspace</p>
</footer>
```

---

## 3. Heading Hierarchy

Headings create the outline of a page.

```tsx
<main>
  <h1>Projects</h1>

  <section>
    <h2>Active projects</h2>

    <article>
      <h3>Website redesign</h3>
    </article>
  </section>
</main>
```

The hierarchy is:

```text
h1: Projects
└── h2: Active projects
    └── h3: Website redesign
```

Avoid choosing headings only for visual size.

Incorrect:

```tsx
<h1>Projects</h1>
<h4>Active projects</h4>
```

Use CSS to control visual size:

```css
.section-heading {
  font-size: 2rem;
}
```

rather than skipping heading levels.

---

## 4. Links Versus Buttons

This distinction is essential.

### Use a link for navigation

A link changes location.

```tsx
import Link from "next/link";

<Link href="/projects">
  View projects
</Link>
```

Use links for:

```text
- Open a page
- Navigate to a project
- Move to another route
- Jump to a page section
- Download a file
```

---

### Use a button for an action

A button performs an operation.

```tsx
<button
  type="button"
  onClick={() => {
    setIsOpen(true);
  }}
>
  Open details
</button>
```

Use buttons for:

```text
- Submit a form
- Open a disclosure
- Copy a link
- Delete a record
- Change interface state
- Start a mutation
```

Incorrect:

```tsx
<a
  href="#"
  onClick={() => {
    deleteProject();
  }}
>
  Delete project
</a>
```

A destructive operation should be a button or a form submission, not a fake link.

---

## 5. Forms and Labels

Every form control needs a label.

Correct:

```tsx
<div>
  <label htmlFor="project-name">
    Project name
  </label>

  <input
    id="project-name"
    name="name"
    type="text"
  />
</div>
```

The relationship is:

```text
label htmlFor="project-name"
        ↓
input id="project-name"
```

Clicking the label focuses the input. Screen readers announce the label when the input receives focus.

---

### Placeholder text is not a label

Weak:

```tsx
<input placeholder="Project name" />
```

Better:

```tsx
<label htmlFor="project-name">
  Project name
</label>

<input
  id="project-name"
  placeholder="Website redesign"
/>
```

The placeholder can provide an example, but the label names the control.

---

### Required fields

Use browser validation to improve usability:

```tsx
<input
  id="project-name"
  name="name"
  required
  maxLength={120}
/>
```

But browser validation is not security. Server-side Zod validation remains necessary.

---

## 6. Accessible Form Errors

When a field fails validation, communicate the problem with text.

```tsx
<input
  id="project-name"
  name="name"
  aria-invalid={true}
  aria-describedby="project-name-error"
/>

<p
  id="project-name-error"
  className="field-error"
>
  Enter a project name.
</p>
```

This communicates:

```text
- The field is invalid.
- The error text explains why.
- The field references the relevant error message.
```

LaunchPad also uses form-level messages:

```tsx
<p role="alert">
  Correct the highlighted project fields.
</p>
```

Use `role="alert"` for urgent failures that should be announced immediately.

---

## 7. The CSS Box Model

Every HTML element is a box.

```text
┌───────────────────────────────┐
│            Margin             │
│  ┌─────────────────────────┐  │
│  │         Border          │  │
│  │  ┌───────────────────┐  │  │
│  │  │      Padding      │  │  │
│  │  │  ┌─────────────┐  │  │  │
│  │  │  │   Content   │  │  │  │
│  │  │  └─────────────┘  │  │  │
│  │  └───────────────────┘  │  │
│  └─────────────────────────┘  │
└───────────────────────────────┘
```

Example:

```css
.project-card {
  margin: 1rem;
  padding: 1.5rem;
  border: 1px solid #dce2ec;
}
```

- `margin` creates space outside the element.
- `border` draws the element edge.
- `padding` creates space inside the element.
- Content is the text, image, or child elements.

---

## 8. `box-sizing: border-box`

LaunchPad applies this global rule:

```css
*,
*::before,
*::after {
  box-sizing: border-box;
}
```

Without `border-box`, this CSS:

```css
width: 20rem;
padding: 1rem;
border: 1px solid;
```

creates an element wider than `20rem`.

With `border-box`, the declared width includes padding and border.

This makes layout sizing more predictable.

---

## 9. CSS Selectors

A selector chooses which elements receive a style.

### Element selector

```css
body {
  margin: 0;
}
```

Targets every `<body>` element.

---

### Class selector

```css
.project-card {
  padding: 1rem;
}
```

Targets elements with:

```tsx
<div className="project-card" />
```

---

### ID selector

```css
#main-content {
  scroll-margin-top: 6rem;
}
```

Targets:

```tsx
<div id="main-content" />
```

Use IDs carefully because they must be unique on a page.

---

### Descendant selector

```css
.project-card h3 {
  margin: 0;
}
```

Targets `<h3>` elements inside `.project-card`.

---

### Pseudo-class selector

```css
.primary-button:hover {
  background: var(--color-primary-hover);
}
```

Targets a button while a pointer hovers over it.

---

### Focus-visible selector

```css
button:focus-visible {
  outline: 0.2rem solid var(--color-focus);
}
```

Targets keyboard-visible focus without forcing an outline after every pointer click.

---

## 10. CSS Custom Properties

A CSS custom property is a reusable named value.

```css
:root {
  --color-primary: #3457d5;
  --space-4: 1rem;
}
```

Use it:

```css
.primary-button {
  padding: var(--space-4);
  background: var(--color-primary);
}
```

Benefits:

```text
- Centralized visual decisions
- Easier theme changes
- Consistent spacing and colors
- More meaningful CSS
```

LaunchPad stores core tokens in:

```text
src/styles/design-tokens.css
```

---

## 11. Flexbox

Flexbox arranges items in one dimension: a row or column.

Example navigation:

```css
.navigation-list {
  display: flex;
  align-items: center;
  gap: 1rem;
}
```

This creates a horizontal row of items.

Important properties:

| Property | Purpose |
|---|---|
| `display: flex` | Enable Flexbox |
| `flex-direction` | Choose row or column |
| `justify-content` | Align along main axis |
| `align-items` | Align along cross axis |
| `gap` | Add space between items |
| `flex-wrap` | Allow items to wrap |

Example:

```css
.hero-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
}
```

This allows action buttons to move to a new line when space is limited.

---

## 12. CSS Grid

Grid arranges content in rows and columns.

Example project cards:

```css
.project-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 1.25rem;
}
```

This creates two equal-width columns.

Breakdown:

```css
repeat(2, minmax(0, 1fr))
```

means:

```text
2 columns
Each column can shrink to 0
Each column receives one equal fraction of remaining width
```

The `minmax(0, 1fr)` pattern helps prevent long content from forcing horizontal overflow.

---

## 13. Responsive Design

Responsive design adapts the interface to available space and device capabilities.

LaunchPad uses media queries such as:

```css
@media (max-width: 48rem) {
  .project-grid {
    grid-template-columns: 1fr;
  }
}
```

At widths under approximately `768px`, project cards become one column.

A common pattern:

```css
.layout {
  display: grid;
  grid-template-columns: 16rem minmax(0, 1fr);
}

@media (max-width: 48rem) {
  .layout {
    grid-template-columns: 1fr;
  }
}
```

Wide screen:

```text
Sidebar | Main content
```

Narrow screen:

```text
Sidebar
Main content
```

---

## 14. Useful Responsive Units

### `rem`

A `rem` is based on the root font size.

```css
padding: 1rem;
```

Using `rem` supports user font-size preferences more naturally than hard-coded pixels.

---

### `%`

A percentage is relative to a containing element.

```css
width: 100%;
```

---

### `vw`

Viewport width units are relative to browser width.

```css
font-size: 5vw;
```

Use cautiously because viewport-only sizing can become too large or too small.

---

### `clamp`

`clamp` defines minimum, preferred, and maximum values.

```css
font-size: clamp(2rem, 5vw, 4rem);
```

This means:

```text
Never smaller than 2rem
Prefer 5vw when appropriate
Never larger than 4rem
```

LaunchPad uses `clamp` for responsive headings.

---

## 15. Focus Styles

Keyboard focus tells users which control receives the next action.

LaunchPad uses a global rule similar to:

```css
:where(
  a,
  button,
  input,
  select,
  textarea
):focus-visible {
  outline: 0.2rem solid var(--color-focus);
  outline-offset: 0.2rem;
}
```

Do not remove outlines without replacing them.

Bad:

```css
button:focus {
  outline: none;
}
```

Better:

```css
button:focus-visible {
  outline: 0.2rem solid #ffbf47;
  outline-offset: 0.2rem;
}
```

---

## 16. Skip Links

A skip link helps keyboard users bypass repeated navigation.

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

CSS:

```css
.skip-link {
  position: fixed;
  transform: translateY(-200%);
}

.skip-link:focus {
  transform: translateY(0);
}
```

The link remains visually hidden until keyboard focus reaches it.

---

## 17. Reduced Motion

Some users ask their operating system to reduce animation.

Respect that request:

```css
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

LaunchPad disables nonessential movement such as:

```text
- Skeleton shimmer
- Card hover movement
- Smooth scrolling
- Skip-link transitions
```

---

## 18. CSS Modules

A CSS Module scopes styles to one component.

File:

```text
project-card.module.css
```

Example:

```css
.card {
  padding: 1.5rem;
  border-radius: 1rem;
}
```

Component:

```tsx
import styles from "@/components/project-card.module.css";

export function ProjectCard() {
  return (
    <article className={styles.card}>
      Project content
    </article>
  );
}
```

Next.js generates a unique class name behind the scenes.

This avoids collisions with another component’s `.card` class.

---

## 19. Global CSS Versus CSS Modules

Use global CSS for shared foundations:

```text
- Tokens
- Typography
- Application shell
- Focus rules
- Skip links
- Print rules
- Shared layouts
```

Use CSS Modules for component-owned styles:

```text
- Project card
- Status badge
- Complex reusable control
- Component-specific variants
```

A useful question:

> Would this style make sense outside this one component?

If yes, it may belong in global shared CSS or a token layer.

If no, it likely belongs in a CSS Module.

---

## 20. Primer Verification Exercises

### Exercise 1: Semantic project card

Write this component:

```tsx
type ProjectCardProps = {
  name: string;
  description: string;
  status: string;
};

export function PrimerProjectCard({
  name,
  description,
  status,
}: ProjectCardProps) {
  return (
    <article>
      <header>
        <h2>{name}</h2>
        <p>{status}</p>
      </header>

      <p>{description}</p>

      <a href="/projects">View projects</a>
    </article>
  );
}
```

Check:

```text
- Uses <article>
- Uses heading structure
- Uses a link for navigation
- Does not use a clickable div
```

---

### Exercise 2: Accessible input

Write this form field:

```tsx
<div>
  <label htmlFor="task-title">
    Task title
  </label>

  <input
    id="task-title"
    name="title"
    type="text"
    required
    maxLength={160}
  />

  <p>
    Use a short action-oriented title.
  </p>
</div>
```

Check:

```text
- Label is visible
- Label and input ID match
- Required field is explicit
- Helper text is available
```

---

### Exercise 3: Responsive grid

Write this CSS:

```css
.primer-grid {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 1rem;
}

@media (max-width: 48rem) {
  .primer-grid {
    grid-template-columns: 1fr;
  }
}
```

Check in a browser:

```text
Wide viewport → 3 columns
Narrow viewport → 1 column
```

---

## 21. Primer Completion Checklist

Before returning to the main series, you should understand:

- [ ] Why semantic HTML matters.
- [ ] When to use `<main>`, `<section>`, `<article>`, `<nav>`, and `<aside>`.
- [ ] Why headings should follow a logical hierarchy.
- [ ] When to use a link versus a button.
- [ ] Why every form input needs a label.
- [ ] Why placeholder text is not a label.
- [ ] What `aria-invalid` communicates.
- [ ] How the CSS box model works.
- [ ] What Flexbox and Grid are used for.
- [ ] How media queries support responsive layouts.
- [ ] Why `minmax(0, 1fr)` prevents common grid overflow.
- [ ] Why focus styles are necessary.
- [ ] How skip links help keyboard users.
- [ ] Why color should not be the only source of meaning.
- [ ] How reduced-motion preferences affect animation.
- [ ] When global CSS versus CSS Modules is appropriate.
