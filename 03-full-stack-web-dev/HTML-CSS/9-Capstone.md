# Part 9: Putting It All Together (Capstone Portfolio Site)

### What You're Building

This is it — the payoff for everything since Part 0. We're going to construct a real, cohesive, multi-page **portfolio website**:

- **`index.html`** — Home page, with a hero (Part 3) and animated highlight cards (Part 7)
- **`projects.html`** — A project showcase using the grid/gallery patterns from Parts 4 & 6, linking out to your actual built projects
- **`about.html`** — Your refined Part 1 bio card
- **`contact.html`** — Your Part 8 contact form
- **`recipe.html`** — A bonus page proving your design system works even on unrelated content
- A shared, three-file CSS architecture (`style.css`, `layout.css`, `components.css`) used identically across every page
- Consistent navigation, a favicon, proper meta tags, and a final responsiveness/accessibility pass

Nothing here is new content to learn from scratch. Every technique below is something you've already built once, in isolation. Your job in this part is **organization and refinement** — the exact skill that separates "someone who followed some tutorials" from "someone who can architect a real small website."

### The "Aha" Moment for This Part

Here's what I want you to feel, concretely: after building `:root` design variables in Step 2, you're going to change **one single line of code** — your primary brand color — and watch the navbar, buttons, links, hero background, and card accents across **all five pages** update simultaneously. That's the moment scattered CSS knowledge becomes a genuine **design system** — a small, personal one, but built on the exact same principle real product teams use at scale.

---

## Step 1: Consolidating the Project Structure

**The Target:** A new folder, `my-portfolio/`, sitting alongside your `part-1` through `part-8` folders inside `build-as-you-learn/`, with all image assets gathered in one place.

**The Concept:** Up to now, each part lived in total isolation. A real site needs everything living together, referencing a shared set of styles and assets. We're also going to do something intentional: the Projects page will **link out to your original, still-live Part 2/4/6/7/8 project folders** as real, working demos — your capstone becomes a hub that showcases the actual working projects you built along the way, not just screenshots of them.

**The Implementation:**

Create this structure:

```
build-as-you-learn/
├── part-1-bio-card/            (already exists)
├── part-2-recipe-page/          (already exists)
├── part-3-landing-page/          (already exists)
├── part-4-photo-gallery/          (already exists)
├── part-5-navbar/                  (already exists)
├── part-6-blog-layout/              (already exists)
├── part-7-product-card/              (already exists)
├── part-8-contact-form/                (already exists)
└── my-portfolio/                          (NEW — the capstone)
    ├── index.html
    ├── about.html
    ├── projects.html
    ├── contact.html
    ├── recipe.html
    ├── css/
    │   ├── style.css
    │   ├── layout.css
    │   └── components.css
    └── images/
        ├── profile.jpg              (copy from part-1-bio-card/images/)
        ├── project-1.jpg              (copy/rename from part-4's photo-1.jpg)
        ├── project-2.jpg              (copy/rename from part-6's post-1.jpg)
        ├── project-3.jpg              (copy/rename from part-7's product.jpg)
        ├── pancakes.jpg               (copy from part-2-recipe-page/images/)
        └── tacos.jpg                   (copy from part-2-recipe-page/images/)
```

Copy the actual image files across using your operating system's file explorer, or drag-and-drop directly within VS Code's sidebar. Renaming is just for clarity — the pixels inside are identical to your originals.

**The Verification:**

Confirm in VS Code's file explorer that `my-portfolio/images/` contains all six files listed above, and that `my-portfolio/css/` exists but is currently empty (we populate it next). Nothing will run yet — this step is purely organizational plumbing.

---

## Step 2: The Design System — CSS Custom Properties in `:root`

**The Target:** `css/style.css` — a foundation file containing a **design token system** using CSS custom properties (variables), plus your reset, base typography, navbar, and footer styles.

**The Concept:** Across Parts 1–8, every time you wanted a specific blue, you typed its hex code (`#2563eb`, `#1e3a8a`, etc.) fresh, by hand, in every file. That's fine for isolated projects, but fragile for a real multi-page site — change your mind about your brand color, and you'd need to hunt down and replace that hex code in five different files, hoping you don't miss one.

**CSS custom properties** solve this. You declare a named variable once — conventionally inside a `:root` selector, which targets the top-level `<html>` element, making the variable available *everywhere* on the page — and then reference that name anywhere you'd normally write a raw value. Analogy: think of `:root` variables as the master color-mixing recipe kept in one binder at a paint shop. Every can of paint mixed from that recipe stays identical, and if the shop owner decides to slightly adjust the recipe, *every future can* reflects the change automatically — without repainting anything already mixed.

**The Implementation:**

```css
/* my-portfolio/css/style.css */

/* ============================================
   DESIGN TOKENS
   A single source of truth for colors, fonts,
   spacing, and other repeated values across
   every page of this site.
   ============================================ */
:root {
  /* Colors */
  --color-primary: #2563eb;
  --color-primary-dark: #1d4ed8;
  --color-accent: #facc15;
  --color-text: #1f2937;
  --color-text-muted: #6b7280;
  --color-bg: #ffffff;
  --color-bg-alt: #f9fafb;
  --color-border: #e5e7eb;
  --color-success: #16a34a;
  --color-danger: #dc2626;

  /* Typography */
  --font-body: "Segoe UI", Arial, sans-serif;
  --font-serif: Georgia, serif;

  /* Shape */
  --radius-sm: 6px;
  --radius-md: 8px;
  --radius-lg: 12px;

  /* Shadows */
  --shadow-sm: 0 2px 6px rgba(0, 0, 0, 0.06);
  --shadow-lg: 0 16px 32px rgba(0, 0, 0, 0.15);

  /* Motion */
  --transition-fast: 0.2s ease;
  --transition-medium: 0.3s ease;

  /* Layout */
  --max-width: 1100px;
}

/* ============================================
   RESET & BASE STYLES
   ============================================ */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: var(--font-body);
  /* var(--font-body) READS the token declared above -- change the token once, */
  /* every element using var(--font-body) updates automatically                */
  color: var(--color-text);
  background-color: var(--color-bg);
  line-height: 1.6;
}

a {
  color: var(--color-primary);
}

img {
  max-width: 100%;
  display: block;
}

/* Respect users who have requested reduced motion at the OS level */
@media (prefers-reduced-motion: reduce) {
  * {
    transition: none !important;
    animation: none !important;
  }
}

/* ============================================
   NAVBAR
   Reused, identically, across every page.
   ============================================ */
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 40px;
  background-color: var(--color-text);
  color: white;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  z-index: 100;
}

.navbar-logo {
  font-weight: bold;
  font-size: 1.2rem;
  color: white;
  text-decoration: none;
}

.navbar-links {
  display: flex;
  gap: 28px;
  list-style: none;
}

.navbar-links a {
  color: white;
  text-decoration: none;
  font-weight: 500;
  transition: color var(--transition-fast);
}

.navbar-links a:hover,
.navbar-links a.active {
  /* .active is a class we'll manually add to whichever nav link matches the CURRENT page -- */
  /* plain HTML has no built-in concept of "current page," so this small manual convention   */
  /* is how we simulate it: each page's own HTML marks its own matching link as active        */
  color: var(--color-accent);
}

.menu-toggle-checkbox {
  display: none;
}

.hamburger-icon {
  display: none;
  flex-direction: column;
  gap: 5px;
  cursor: pointer;
  padding: 6px;
}

.hamburger-icon span {
  width: 26px;
  height: 3px;
  background-color: white;
  border-radius: 2px;
}

@media (max-width: 768px) {
  .hamburger-icon {
    display: flex;
  }

  .navbar-links {
    flex-direction: column;
    position: absolute;
    top: 100%;
    left: 0;
    width: 100%;
    background-color: var(--color-text);
    gap: 0;
    max-height: 0;
    overflow: hidden;
    transition: max-height var(--transition-medium);
  }

  .navbar-links li {
    padding: 14px 40px;
    border-top: 1px solid rgba(255, 255, 255, 0.15);
  }

  .menu-toggle-checkbox:checked ~ .navbar-links {
    max-height: 300px;
  }
}

/* ============================================
   FOOTER
   Reused, identically, across every page.
   ============================================ */
.site-footer {
  background-color: var(--color-text);
  color: #d1d5db;
  text-align: center;
  padding: 40px 24px;
  margin-top: 80px;
}

.site-footer a {
  color: #93c5fd;
  text-decoration: none;
}

.site-footer a:hover {
  text-decoration: underline;
}

.site-footer .social-links {
  margin-top: 8px;
}
```

**The Verification:**

This file has no HTML to test against yet — but read back through it and confirm every color is expressed as `var(--token-name)` rather than a raw hex code, with the *only* raw hex values living inside the `:root` block at the top. This structural discipline is the entire point of this step.

---

## Step 3: The Layout File — Reusable Structural Patterns

**The Target:** `css/layout.css` — the content-wrap pattern, hero layout, and grid patterns from Parts 3, 4, and 6, generalized into reusable classes.

**The Concept:** This file answers "how are things arranged in space?" — separate from `style.css`'s job of "what do things look like?" (colors, fonts) and `components.css`'s job (which we'll write next) of "what are the reusable UI pieces?" This three-way split is a real, professional CSS organization pattern: **base/tokens, layout, components** — each file has one clear responsibility, which is exactly why a future you (or a teammate) can find any given rule quickly without hunting through one giant file.

**The Implementation:**

```css
/* my-portfolio/css/layout.css */

/* ============================================
   CONTENT WRAPPER
   The reusable "constrain and center" pattern
   from Part 3, used on every section that needs
   readable line lengths on wide screens.
   ============================================ */
.container {
  max-width: var(--max-width);
  margin: 0 auto;
  padding: 0 24px;
}

.section {
  padding: 80px 24px;
}

.section--alt {
  background-color: var(--color-bg-alt);
}

.section-heading {
  font-size: 1.8rem;
  color: var(--color-text);
  margin-bottom: 40px;
  text-align: center;
}

/* ============================================
   HERO LAYOUT (Part 3)
   ============================================ */
.hero {
  background-color: var(--color-primary);
  color: white;
  text-align: center;
  padding: 140px 24px 100px 24px;
  /* extra top padding compensates for the fixed navbar overlapping the page content */
}

.hero h1 {
  font-size: 2.5rem;
  max-width: 700px;
  margin: 0 auto 16px auto;
}

.hero p {
  font-size: 1.15rem;
  max-width: 550px;
  margin: 0 auto 32px auto;
  color: #dbeafe;
}

/* ============================================
   FLEX ROW PATTERN (Part 4)
   For simple wrapping rows of equally-sized items
   ============================================ */
.flex-row {
  display: flex;
  flex-wrap: wrap;
  gap: 24px;
}

.flex-row > * {
  flex: 1 1 260px;
}

/* ============================================
   RESPONSIVE GRID PATTERN (Part 6)
   For card grids that need zero media queries
   ============================================ */
.grid-auto {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 24px;
}

/* ============================================
   TWO-COLUMN LAYOUT (Part 6)
   For content + sidebar style structures
   ============================================ */
.grid-2col {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 32px;
}

@media (max-width: 768px) {
  .grid-2col {
    grid-template-columns: 1fr;
    /* on small screens, collapse to a single stacked column instead of a squeezed 2-column grid */
  }
}
```

**The Verification:**

Again, no HTML yet to visually check — but note how each rule maps directly back to a pattern you already built by hand once in an earlier part. That mapping (recognizing "oh, this is that thing from Part 6") is exactly the payoff of this whole series' structure.

---

## Step 4: The Components File — Buttons, Cards, and Forms

**The Target:** `css/components.css` — reusable, self-contained UI pieces: buttons, cards (with Part 7's hover animation baked in), badges, and the complete form styling from Part 8.

**The Concept:** A "component" in this context is any small, reusable chunk of UI that you'll drop onto multiple pages verbatim — a button, a card, a form field. Keeping these separate from layout rules means you can use a `.btn` inside a hero, inside a card, or inside a form, and it always looks and behaves identically, regardless of where it's placed.

**The Implementation:**

```css
/* my-portfolio/css/components.css */

/* ============================================
   BUTTONS
   ============================================ */
.btn {
  display: inline-block;
  padding: 12px 28px;
  border-radius: var(--radius-sm);
  font-weight: bold;
  text-decoration: none;
  border: none;
  cursor: pointer;
  font-size: 1rem;
  transition: background-color var(--transition-fast), transform var(--transition-fast);
}

.btn:active {
  transform: scale(0.97);
}

.btn-primary {
  background-color: var(--color-accent);
  color: var(--color-text);
}

.btn-primary:hover {
  background-color: #eab308;
}

.btn-secondary {
  background-color: var(--color-primary);
  color: white;
}

.btn-secondary:hover {
  background-color: var(--color-primary-dark);
}

/* ============================================
   CARDS
   Base card style, plus the hover-lift animation
   from Part 7, applied consistently everywhere
   a "card" appears across the whole site.
   ============================================ */
.card {
  background-color: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  transition: transform var(--transition-medium), box-shadow var(--transition-medium);
}

.card:hover {
  transform: translateY(-8px);
  box-shadow: var(--shadow-lg);
}

.card-body {
  padding: 20px;
}

.card img {
  width: 100%;
  height: 200px;
  object-fit: cover;
}

.card h3 {
  color: var(--color-text);
  margin-bottom: 8px;
}

.card p {
  color: var(--color-text-muted);
  font-size: 0.95rem;
  margin-bottom: 14px;
}

/* Featured variant -- reused concept from Part 4's "featured card" challenge */
.card--featured {
  border: 2px solid var(--color-primary);
  box-shadow: 0 4px 14px rgba(37, 99, 235, 0.2);
}

/* ============================================
   BADGE
   ============================================ */
.badge {
  display: inline-block;
  background-color: var(--color-accent);
  color: var(--color-text);
  font-size: 0.7rem;
  font-weight: bold;
  text-transform: uppercase;
  padding: 4px 10px;
  border-radius: 4px;
}

/* ============================================
   FORMS (Part 8)
   ============================================ */
.form-card {
  background-color: var(--color-bg);
  max-width: 480px;
  width: 100%;
  padding: 40px;
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  margin: 0 auto;
}

.form-card h1,
.form-card h2 {
  margin-bottom: 10px;
}

.form-intro {
  color: var(--color-text-muted);
  margin-bottom: 28px;
}

.form-group {
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
}

.form-group label {
  font-weight: 600;
  font-size: 0.9rem;
  margin-bottom: 6px;
  color: var(--color-text);
}

.form-group input,
.form-group textarea,
.form-group select {
  padding: 10px 12px;
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  font-size: 1rem;
  font-family: inherit;
  color: var(--color-text);
  background-color: white;
}

.form-group textarea {
  resize: vertical;
}

.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
}

.form-group input:invalid:not(:placeholder-shown),
.form-group textarea:invalid:not(:placeholder-shown) {
  border-color: var(--color-danger);
  background-color: #fef2f2;
}

.form-group input:valid:not(:placeholder-shown),
.form-group textarea:valid:not(:placeholder-shown) {
  border-color: var(--color-success);
  background-color: #f0fdf4;
}

.error-message {
  display: none;
  color: var(--color-danger);
  font-size: 0.82rem;
  margin-top: 6px;
}

.form-group input:invalid:not(:placeholder-shown) ~ .error-message {
  display: block;
}

.btn-submit {
  width: 100%;
  padding: 12px;
  background-color: var(--color-primary);
  color: white;
  font-weight: bold;
  font-size: 1rem;
  border: none;
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: background-color var(--transition-fast);
}

.btn-submit:hover {
  background-color: var(--color-primary-dark);
}

/* ============================================
   BIO CARD (Part 1)
   ============================================ */
.bio-card {
  max-width: 600px;
  margin: 0 auto;
  text-align: center;
}

.bio-photo {
  width: 160px;
  height: 160px;
  object-fit: cover;
  border-radius: 50%;
  border: 4px solid var(--color-primary);
  margin: 0 auto 16px auto;
}

.bio-quote {
  text-align: left;
  font-style: italic;
  color: #1e3a8a;
  background-color: #e0e7ff;
  border-left: 5px solid var(--color-primary);
  padding: 12px 20px;
  margin: 24px 0;
  border-radius: 4px;
}

.bio-facts {
  text-align: left;
  line-height: 1.9;
  padding-left: 24px;
  color: var(--color-text-muted);
}

/* ============================================
   RECIPE CARD (Part 2)
   ============================================ */
.recipe-card {
  max-width: 640px;
  margin: 0 auto;
}

.recipe-card .ingredients-list,
.recipe-card .instructions-list {
  padding-left: 24px;
  margin-bottom: 20px;
  line-height: 1.9;
}
```

**The Verification:**

Skim through and confirm every color, radius, shadow, and transition duration references a `var(--token)` rather than a raw value — the entire component library is now wired into the same design system from Step 2.

---

## Step 5: The Home Page

**The Target:** `index.html` — hero section, three animated highlight cards, and a teaser linking to the About page.

**The Implementation:**

```html
<!-- my-portfolio/index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta
      name="description"
      content="The personal portfolio of Alex Rivera — front-end developer, built entirely with hand-written HTML and CSS."
    />
    <title>Alex Rivera — Portfolio</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>%F0%9F%9A%80</text></svg>" />
    <link rel="stylesheet" href="css/style.css" />
    <link rel="stylesheet" href="css/layout.css" />
    <link rel="stylesheet" href="css/components.css" />
  </head>
  <body>
    <nav class="navbar">
      <a href="index.html" class="navbar-logo">Alex Rivera</a>
      <input type="checkbox" id="menu-toggle" class="menu-toggle-checkbox" />
      <label for="menu-toggle" class="hamburger-icon">
        <span></span><span></span><span></span>
      </label>
      <ul class="navbar-links">
        <li><a href="index.html" class="active">Home</a></li>
        <li><a href="about.html">About</a></li>
        <li><a href="projects.html">Projects</a></li>
        <li><a href="contact.html">Contact</a></li>
      </ul>
    </nav>

    <section class="hero">
      <h1>Front-End Developer, Building Clean Interfaces One Project at a Time</h1>
      <p>
        I'm Alex — I design and build fast, accessible, hand-crafted websites.
        Everything on this site was written from scratch, no templates.
      </p>
      <a href="projects.html" class="btn btn-primary">View My Work</a>
    </section>

    <section class="section">
      <div class="container">
        <h2 class="section-heading">What I Focus On</h2>
        <div class="grid-auto">
          <div class="card">
            <div class="card-body">
              <h3>Clean, Semantic Code</h3>
              <p>Every page is built with meaningful HTML — accessible, readable, and easy to maintain.</p>
            </div>
          </div>
          <div class="card">
            <div class="card-body">
              <h3>Thoughtful Layout</h3>
              <p>Flexbox and Grid, used deliberately — the right layout tool for each specific problem.</p>
            </div>
          </div>
          <div class="card">
            <div class="card-body">
              <h3>Subtle, Purposeful Motion</h3>
              <p>Animations that clarify interactivity, never distract from it.</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="section section--alt">
      <div class="container" style="text-align: center;">
        <h2 class="section-heading">Want to Know More About Me?</h2>
        <a href="about.html" class="btn btn-secondary">Learn more about me</a>
      </div>
    </section>

    <footer class="site-footer">
      <p>&copy; 2024 Alex Rivera. All rights reserved.</p>
      <p class="social-links">
        <a href="https://github.com/" target="_blank" rel="noopener noreferrer">GitHub</a>
        &nbsp;|&nbsp;
        <a href="https://www.linkedin.com/" target="_blank" rel="noopener noreferrer">LinkedIn</a>
      </p>
    </footer>
  </body>
</html>
```

A few things worth calling out: the `<link rel="icon">` uses an inline SVG **data URI** — a way of embedding a tiny image file's content directly inside the HTML itself, no separate file needed. `%F0%9F%9A%80` is just a URL-encoded rocket emoji (🚀); feel free to swap it for any emoji you like. And notice `class="active"` on the Home link — since plain HTML/CSS has no built-in way to know "what page am I currently on," we manually mark the matching link on each page ourselves, a small but honest convention worth understanding rather than glossing over.

**The Verification:**

Open with Live Server. You should see: a fixed navbar with "Home" highlighted in yellow (the `.active` state), a bold blue hero with heading/subheading/button, three highlight cards that lift on hover, a "Learn more about me" CTA section, and a footer. Click "View My Work" and "Learn more about me" — both should currently 404 (since we haven't built those pages yet) — that's expected; we build them next.

---

## Step 6: The About Page

**The Target:** `about.html` — your Part 1 bio card, refined to use the shared design system and navbar.

**The Implementation:**

```html
<!-- my-portfolio/about.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Learn more about Alex Rivera, front-end developer." />
    <title>About — Alex Rivera</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>%F0%9F%9A%80</text></svg>" />
    <link rel="stylesheet" href="css/style.css" />
    <link rel="stylesheet" href="css/layout.css" />
    <link rel="stylesheet" href="css/components.css" />
  </head>
  <body>
    <nav class="navbar">
      <a href="index.html" class="navbar-logo">Alex Rivera</a>
      <input type="checkbox" id="menu-toggle" class="menu-toggle-checkbox" />
      <label for="menu-toggle" class="hamburger-icon">
        <span></span><span></span><span></span>
      </label>
      <ul class="navbar-links">
        <li><a href="index.html">Home</a></li>
        <li><a href="about.html" class="active">About</a></li>
        <li><a href="projects.html">Projects</a></li>
        <li><a href="contact.html">Contact</a></li>
      </ul>
    </nav>

    <section class="section" style="padding-top: 140px;">
      <div class="container bio-card">
        <h1>Alex Rivera</h1>

        <img
          src="images/profile.jpg"
          alt="Portrait photo of Alex Rivera smiling outdoors"
          class="bio-photo"
        />

        <p>
          Hi, I'm Alex — a curious front-end developer who loves turning
          ideas into clean, usable interfaces. I built this entire site
          by hand, one HTML/CSS concept at a time, and this page is where
          that journey started.
        </p>

        <p style="margin-top: 20px;">
          <a href="https://github.com/" target="_blank" rel="noopener noreferrer">GitHub</a>
          &nbsp;|&nbsp;
          <a href="https://www.linkedin.com/" target="_blank" rel="noopener noreferrer">LinkedIn</a>
        </p>

        <h2 style="margin-top: 32px; text-align: left;">Fun Facts About Me</h2>
        <ul class="bio-facts">
          <li>I've visited 12 countries and counting.</li>
          <li>I taught myself to solve a Rubik's Cube in a weekend.</li>
          <li>My first "real" program was a to-do list app that never actually saved anything.</li>
          <li>I can't function before my morning coffee.</li>
        </ul>

        <blockquote class="bio-quote">
          "The best way to predict the future is to invent it." — Alan Kay
        </blockquote>
      </div>
    </section>

    <footer class="site-footer">
      <p>&copy; 2024 Alex Rivera. All rights reserved.</p>
      <p class="social-links">
        <a href="https://github.com/" target="_blank" rel="noopener noreferrer">GitHub</a>
        &nbsp;|&nbsp;
        <a href="https://www.linkedin.com/" target="_blank" rel="noopener noreferrer">LinkedIn</a>
      </p>
    </footer>
  </body>
</html>
```

**The Verification:**

Open with Live Server. Confirm your photo, intro, links, fun facts, and quote all appear correctly styled, "About" is highlighted yellow in the navbar, and the page uses the exact same navbar/footer look as the home page — proof that `css/style.css` is doing consistent, shared work across pages.

---

## Step 7: The Projects Page

**The Target:** `projects.html` — a responsive card grid showcasing your actual built projects, each linking to its real, working folder.

**The Implementation:**

```html
<!-- my-portfolio/projects.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="A showcase of HTML/CSS projects built by Alex Rivera." />
    <title>Projects — Alex Rivera</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>%F0%9F%9A%80</text></svg>" />
    <link rel="stylesheet" href="css/style.css" />
    <link rel="stylesheet" href="css/layout.css" />
    <link rel="stylesheet" href="css/components.css" />
  </head>
  <body>
    <nav class="navbar">
      <a href="index.html" class="navbar-logo">Alex Rivera</a>
      <input type="checkbox" id="menu-toggle" class="menu-toggle-checkbox" />
      <label for="menu-toggle" class="hamburger-icon">
        <span></span><span></span><span></span>
      </label>
      <ul class="navbar-links">
        <li><a href="index.html">Home</a></li>
        <li><a href="about.html">About</a></li>
        <li><a href="projects.html" class="active">Projects</a></li>
        <li><a href="contact.html">Contact</a></li>
      </ul>
    </nav>

    <section class="section" style="padding-top: 140px;">
      <div class="container">
        <h1 class="section-heading">My Projects</h1>

        <div class="grid-auto">
          <article class="card card--featured">
            <img src="images/project-3.jpg" alt="Product card UI with hover animation" />
            <div class="card-body">
              <span class="badge">Featured</span>
              <h3>Animated Product Card</h3>
              <p>An e-commerce-style card with pure-CSS hover transitions, transforms, and keyframe animation.</p>
              <a href="../part-7-product-card/index.html" class="btn btn-secondary">View Project</a>
            </div>
          </article>

          <article class="card">
            <img src="images/project-1.jpg" alt="Photo gallery built with Flexbox" />
            <div class="card-body">
              <h3>Flexbox Photo Gallery</h3>
              <p>A responsive image gallery that wraps gracefully using Flexbox, with a featured card variant.</p>
              <a href="../part-4-photo-gallery/index.html" class="btn btn-secondary">View Project</a>
            </div>
          </article>

          <article class="card">
            <img src="images/project-2.jpg" alt="Blog homepage layout built with CSS Grid" />
            <div class="card-body">
              <h3>Grid Blog Layout</h3>
              <p>A blog homepage with a featured post, sidebar, and responsive card grid, built with CSS Grid.</p>
              <a href="../part-6-blog-layout/index.html" class="btn btn-secondary">View Project</a>
            </div>
          </article>

          <article class="card">
            <img src="images/pancakes.jpg" alt="Recipe page for buttermilk pancakes" />
            <div class="card-body">
              <h3>Recipe Page</h3>
              <p>A clean, reusable content page pattern, styled entirely with an external stylesheet.</p>
              <a href="recipe.html" class="btn btn-secondary">View Project</a>
            </div>
          </article>
        </div>
      </div>
    </section>

    <footer class="site-footer">
      <p>&copy; 2024 Alex Rivera. All rights reserved.</p>
      <p class="social-links">
        <a href="https://github.com/" target="_blank" rel="noopener noreferrer">GitHub</a>
        &nbsp;|&nbsp;
        <a href="https://www.linkedin.com/" target="_blank" rel="noopener noreferrer">LinkedIn</a>
      </p>
    </footer>
  </body>
</html>
```

**The Verification:**

Open with Live Server. You should see four project cards in a responsive grid, the first one visibly distinguished with a blue "Featured" border and badge. Hover over any card — it should lift with a deepening shadow (Part 7's animation, now reused here for free via `.card`). Click each "View Project" button and confirm it correctly navigates to the corresponding standalone project you built earlier in the series (the relative `../part-X-.../` paths depend on your folder structure from Step 1 being correct), except "Recipe Page," which points to the `recipe.html` we build next, inside this same portfolio.

---

## Step 8: The Contact Page

**The Target:** `contact.html` — your Part 8 form, restyled entirely through the shared design system.

**The Implementation:**

```html
<!-- my-portfolio/contact.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Get in touch with Alex Rivera." />
    <title>Contact — Alex Rivera</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>%F0%9F%9A%80</text></svg>" />
    <link rel="stylesheet" href="css/style.css" />
    <link rel="stylesheet" href="css/layout.css" />
    <link rel="stylesheet" href="css/components.css" />
  </head>
  <body>
    <nav class="navbar">
      <a href="index.html" class="navbar-logo">Alex Rivera</a>
      <input type="checkbox" id="menu-toggle" class="menu-toggle-checkbox" />
      <label for="menu-toggle" class="hamburger-icon">
        <span></span><span></span><span></span>
      </label>
      <ul class="navbar-links">
        <li><a href="index.html">Home</a></li>
        <li><a href="about.html">About</a></li>
        <li><a href="projects.html">Projects</a></li>
        <li><a href="contact.html" class="active">Contact</a></li>
      </ul>
    </nav>

    <section class="section" style="padding-top: 140px; display: flex; flex-direction: column; align-items: center; gap: 24px;">
      <div class="form-card">
        <h1>Get In Touch</h1>
        <p class="form-intro">
          Have a question or just want to say hi? Fill out the form below
          and I'll get back to you as soon as I can.
        </p>

        <form action="#" method="post">
          <div class="form-group">
            <label for="name">Name</label>
            <input type="text" id="name" name="name" placeholder="Your full name" required />
          </div>

          <div class="form-group">
            <label for="email">Email</label>
            <input type="email" id="email" name="email" placeholder="you@example.com" required />
            <span class="error-message">Please enter a valid email address.</span>
          </div>

          <div class="form-group">
            <label for="subject">Subject</label>
            <select id="subject" name="subject" required>
              <option value="" disabled selected>Choose a topic&hellip;</option>
              <option value="general">General Inquiry</option>
              <option value="support">Support Request</option>
              <option value="feedback">Feedback</option>
            </select>
          </div>

          <div class="form-group">
            <label for="message">Message</label>
            <textarea
              id="message"
              name="message"
              rows="5"
              placeholder="What would you like to say?"
              required
            ></textarea>
          </div>

          <button type="submit" class="btn-submit">Send Message</button>
        </form>
      </div>

      <div class="form-card">
        <h2>Subscribe to the Newsletter</h2>
        <p class="form-intro">Occasional updates. No spam, ever.</p>

        <form action="#" method="post">
          <div class="form-group">
            <label for="newsletter-email">Email Address</label>
            <input
              type="email"
              id="newsletter-email"
              name="newsletter-email"
              placeholder="you@example.com"
              required
            />
            <span class="error-message">Please enter a valid email address.</span>
          </div>
          <button type="submit" class="btn-submit" style="background-color: var(--color-success);">
            Subscribe
          </button>
        </form>
      </div>
    </section>

    <footer class="site-footer">
      <p>&copy; 2024 Alex Rivera. All rights reserved.</p>
      <p class="social-links">
        <a href="https://github.com/" target="_blank" rel="noopener noreferrer">GitHub</a>
        &nbsp;|&nbsp;
        <a href="https://www.linkedin.com/" target="_blank" rel="noopener noreferrer">LinkedIn</a>
      </p>
    </footer>
  </body>
</html>
```

**The Verification:**

Open with Live Server. Confirm both forms render with consistent spacing and styling, "Contact" is highlighted in the navbar, and repeat the validation tests from Part 8 (typing an invalid email should show a red border/background/error message; a valid one should turn green) on both forms independently.

---

## Step 9: The Bonus Recipe Page — Proving Full Reuse

**The Target:** `recipe.html` — your Part 2 recipe, now dressed entirely in the capstone's shared design system, proving your three-file CSS architecture works even on completely unrelated content types.

**The Implementation:**

```html
<!-- my-portfolio/recipe.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="Fluffy buttermilk pancakes recipe." />
    <title>Recipe — Alex Rivera</title>
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>%F0%9F%9A%80</text></svg>" />
    <link rel="stylesheet" href="css/style.css" />
    <link rel="stylesheet" href="css/layout.css" />
    <link rel="stylesheet" href="css/components.css" />
  </head>
  <body>
    <nav class="navbar">
      <a href="index.html" class="navbar-logo">Alex Rivera</a>
      <input type="checkbox" id="menu-toggle" class="menu-toggle-checkbox" />
      <label for="menu-toggle" class="hamburger-icon">
        <span></span><span></span><span></span>
      </label>
      <ul class="navbar-links">
        <li><a href="index.html">Home</a></li>
        <li><a href="about.html">About</a></li>
        <li><a href="projects.html" class="active">Projects</a></li>
        <li><a href="contact.html">Contact</a></li>
      </ul>
    </nav>

    <section class="section" style="padding-top: 140px;">
      <div class="container recipe-card card">
        <div class="card-body">
          <h1>Fluffy Buttermilk Pancakes</h1>
          <img src="images/pancakes.jpg" alt="A stack of golden buttermilk pancakes topped with syrup and butter" />
          <p style="margin: 16px 0;">
            These pancakes are light, fluffy, and ready in under 20 minutes.
            A weekend breakfast favorite that never fails.
          </p>

          <h2>Ingredients</h2>
          <ul class="ingredients-list">
            <li>1 1/2 cups all-purpose flour</li>
            <li>3 1/2 teaspoons baking powder</li>
            <li>1 teaspoon salt</li>
            <li>1 tablespoon sugar</li>
            <li>1 1/4 cups buttermilk</li>
            <li>1 egg</li>
            <li>3 tablespoons melted butter</li>
          </ul>

          <h2>Instructions</h2>
          <ol class="instructions-list">
            <li>In a large bowl, whisk together flour, baking powder, salt, and sugar.</li>
            <li>In a separate bowl, whisk buttermilk, egg, and melted butter.</li>
            <li>Pour the wet ingredients into the dry ingredients and stir until just combined.</li>
            <li>Heat a lightly oiled griddle over medium heat.</li>
            <li>Pour 1/4 cup of batter per pancake and cook until bubbles form, then flip.</li>
            <li>Cook the other side until golden brown. Serve warm.</li>
          </ol>

          <a href="projects.html" class="btn btn-secondary">&larr; Back to Projects</a>
        </div>
      </div>
    </section>

    <footer class="site-footer">
      <p>&copy; 2024 Alex Rivera. All rights reserved.</p>
    </footer>
  </body>
</html>
```

**The Verification:**

Open with Live Server. The recipe should render inside a proper `.card` component (border, radius, shadow, hover lift), with lists correctly styled by the shared `components.css` rules, and the navbar/footer identical to every other page. Click "Back to Projects" to confirm the round-trip navigation works.

---

## Step 10: The One-Line Proof — Changing the Whole Site's Brand Color

**The Target:** Directly trigger this part's promised "aha" moment.

**The Implementation:**

Open `css/style.css` and change just this one line:

```css
:root {
  --color-primary: #16a34a;
  /* changed from #2563eb (blue) to a green -- everything else in this file, */
  /* layout.css, and components.css stays completely untouched               */
  ...
}
```

**The Verification:**

Save, and refresh **every single page** — `index.html`, `about.html`, `projects.html`, `contact.html`, `recipe.html`. On every page, you should see the hero background, buttons, form focus rings, bio photo border, and featured card border **all shift to green simultaneously** — despite you having touched exactly one line, in exactly one file. Change it back to `#2563eb` (or keep the green, if you prefer it!) once you've confirmed the effect. This is the concrete, undeniable proof that your design system works exactly as intended.

---

## Step 11: Final Production Polish Checklist

**The Target:** A last pass over the whole site for real-world launch readiness.

Work through this checklist manually across all five pages:

1. **Responsive check:** Resize your browser (or use dev tools' device toolbar) down to a phone width (~375px) on every page. Confirm the navbar collapses to a hamburger menu, card grids reflow to a single column, and no text overflows its container.
2. **Contrast check:** Glance at every text/background combination — your dark navbar with white text, your yellow accent button with dark text, your muted gray body text on white — all should be comfortably readable. As a rule of thumb, avoid light gray text on white backgrounds, and avoid colored text on similarly-colored backgrounds.
3. **Focus check:** Tab through each page using only your keyboard (no mouse). Confirm every link, button, and form field shows a clear focus indicator, and that the tab order matches the visual reading order top-to-bottom.
4. **Consistent navigation check:** Confirm the navbar's `.active` class correctly matches the current page on all five files, and that every nav link correctly resolves (no typos in relative paths).
5. **Meta tags check:** Confirm every page has a `<title>` and a `<meta name="description">` — both matter for search engines and for how your page appears when shared as a link on social media or messaging apps.
6. **Reduced motion check:** In your OS accessibility settings, enable "reduce motion" (on macOS: System Settings → Accessibility → Display → Reduce Motion; on Windows: Settings → Accessibility → Visual Effects → Animation Effects, off), refresh a page, and confirm hover animations no longer play, respecting our `@media (prefers-reduced-motion: reduce)` rule from Step 2.

---

## End-of-Part Challenge: Add a New Section on Your Own

**Your task:** Using only patterns you've already learned across this entire series, add **one new page or section** to your portfolio — a Blog page (reusing Part 6's grid pattern), a Services section, or a Testimonials page (reusing Part 3's challenge). Build it using the same three-file CSS architecture (`style.css` variables, `layout.css` structural classes, `components.css` reusable pieces), the same shared navbar/footer markup, and add its link into the navbar across **all** pages.

There's no reference solution provided for this one deliberately — by this point in the series, you have every single tool required to do this entirely on your own: semantic HTML (Part 3), Flexbox and Grid (Parts 4 & 6), positioning and navigation (Part 5), motion (Part 7), and forms (Part 8), all unified under the design token system you just built in this part. This is the exact moment the series has been building toward — you are no longer following instructions; you are architecting.

---

## Reference Section: Deep Dive for Part 9

### CSS Custom Properties — Full Syntax Reference

```css
:root {
  --my-variable: 16px;
}

.some-element {
  padding: var(--my-variable);
  /* fallback: var(--my-variable, 12px) uses 12px if --my-variable is undefined */
}
```

Custom properties can be redeclared inside any selector, not just `:root`, to create scoped overrides:

```css
.dark-section {
  --color-text: white;
  /* any element inside .dark-section that uses var(--color-text) now gets white, */
  /* while everything OUTSIDE .dark-section still gets the original :root value  */
}
```

This scoping behavior is genuinely powerful for building themed sections or dark-mode variants later — worth knowing exists, even though our project didn't need it.

### The Three-File CSS Architecture, Generalized

| File | Responsibility | Example Rules |
|---|---|---|
| `style.css` | Design tokens, resets, global base styles, and truly global components (navbar, footer) | `:root` variables, `body`, `.navbar` |
| `layout.css` | Structural/spatial patterns — how regions of a page are arranged | `.container`, `.grid-auto`, `.hero` |
| `components.css` | Reusable, self-contained UI pieces | `.btn`, `.card`, `.form-group` |

This isn't a rigid law — some real projects split things differently, or use even more files as they grow. But the underlying principle — **separate "what it looks like" from "how it's arranged" from "what it is"** — will serve you well in any CSS codebase you touch going forward, including if you move on to component-based frameworks like React later, where this separation becomes even more explicit.

### Deploying Your Capstone for Real

To make this genuinely live on the internet:

1. Create a free account at [github.com](https://github.com/) if you haven't already.
2. Create a new repository (e.g., `my-portfolio`).
3. Upload the entire contents of your `my-portfolio/` folder to it (via the GitHub website's upload interface, or `git` commands if you're comfortable with them).
4. Go to the repository's **Settings → Pages**, set the source branch to `main` and folder to `/ (root)`, and save.
5. Within a minute or two, GitHub will provide a live URL in the form `https://yourusername.github.io/my-portfolio/`.

Since all your project folders (`part-4-photo-gallery`, etc.) live as *siblings* to `my-portfolio` on your computer, and your Projects page links to them with relative `../` paths, you'd need to upload those sibling folders to the same repository (or separate repositories, updating the links accordingly) for those specific "View Project" links to resolve correctly once deployed. This is a great, real opportunity to practice exactly the kind of folder-structure reasoning you built throughout this series.

### A Note on What Comes Next

You've now completed a full front-end fundamentals arc: document structure, styling, the box model, semantic HTML, Flexbox, positioning, Grid, motion, forms, and finally, design systems and CSS architecture. If you continue toward JavaScript next, you'll find an enormous amount of what you learn there is really about *adding behavior* on top of exactly this kind of solid HTML/CSS foundation — form validation beyond what CSS alone can do, dynamic content updates, and interactivity beyond hover states. You are not starting over when you get there; you're building directly on top of everything you just did.

---

## Series Conclusion

Look back at where you started: a sanity-check file with one blue line of text. You now have a five-page, responsively designed, accessibly built, animation-polished, form-validated, design-system-driven portfolio website — and every single piece of it, you built and understood, one deliberate step at a time, with nothing abstracted away.

That bio card from Part 1 is now your About page. That recipe page from Part 2 proved CSS reuse and is now a showcased project. That landing page from Part 3 taught you semantic structure. That gallery from Part 4 taught you Flexbox, and now lives as a linked project. That navbar from Part 5 is on every single page you just built. That blog layout from Part 6 taught you Grid, and is showcased too. That product card from Part 7 taught you motion, and its hover animation is now baked into every card on your entire site. That contact form from Part 8 is your live Contact page.

Nothing was wasted. That was the promise back in Part 0, and it's now sitting in your `my-portfolio` folder as proof.
