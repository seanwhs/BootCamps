# Part 3: Get Organized (Multi-Section Landing Page)

### What You're Building

A one-page **landing site** for a fictional product, service, or personal brand — with a hero section (big headline + call-to-action button), an about/features section, and a footer with contact info and social links. This is the part where your project stops feeling like "a page with some content on it" and starts feeling like "a real website" — the kind of thing you'd see for an actual startup or freelancer.

This page is also structurally important for the series: in Part 9, this exact landing page becomes your capstone's **home page**.

### The "Aha" Moment for This Part

Up to now, you've used `<div>` for grouping (our `.recipe-card` wrapper in Part 2). The moment I want to land here is this: **HTML5 gives us tags that describe *what a section of the page means*, not just *that it's a box*.** A `<div>` is like an unlabeled cardboard box — perfectly functional, but you have to open it to know what's inside. A `<header>`, `<nav>`, `<section>`, and `<footer>` are like boxes with printed labels on the outside — a browser, a search engine, or a screen reader can understand your page's structure at a glance, without guessing. You'll feel this the moment you inspect your own page structure in the browser's dev tools and it reads almost like a table of contents.

---

## Step 1: Project Setup and Planning the Sections

**The Target:** A new project folder, `part-3-landing-page/`, with a folder structure that separates CSS into its own subfolder for the first time — matching the capstone's eventual layout from Part 0.

**The Concept:** As projects grow, dumping every file loose into one folder gets messy fast — imagine a filing cabinet with no drawers, everything in one pile. We're introducing a `css/` subfolder now, a small step that pays off hugely by Part 9 when we have three separate stylesheets working together.

**The Implementation:**

Create this structure inside `build-as-you-learn/`:

```
part-3-landing-page/
├── index.html
├── css/
│   └── style.css
└── images/
    └── hero-bg.jpg
```

(A hero background image is optional for this part — we'll primarily use a solid/gradient color background, but feel free to add one if you'd like a photo-backed hero section.)

**The Verification:**

Confirm the nested `css/` folder appears correctly in VS Code's explorer, with `style.css` inside it — this path (`css/style.css`, relative to `index.html`) is what we'll reference in our `<link>` tag next.

---

## Step 2: Semantic Structure — `<header>`, `<nav>`, `<section>`, `<footer>`

**The Target:** The full skeletal structure of `index.html`, using semantic tags instead of generic `<div>`s for every major region.

**The Concept:** Let's define each new tag with a real-world analogy, since this is the conceptual core of this part:

- **`<header>`** — the top banner of the page, typically containing a logo/site name and navigation. Think of it like a newspaper's masthead — the same recognizable strip at the top of every single page.
- **`<nav>`** — specifically wraps navigation links. Not every group of links needs `<nav>` — reserve it for your *primary* site navigation, like the tabs at the top of a physical binder.
- **`<section>`** — a thematic grouping of content, usually with its own heading — like a chapter in a book. Our page will have a hero section and a features section, each wrapped in its own `<section>`.
- **`<footer>`** — the bottom strip of the page: copyright, contact info, secondary links — like the small print at the bottom of a printed flyer.

Why does this matter beyond just looking organized? Two concrete, beginner-relevant reasons:

1. **Accessibility** — screen readers (software that reads a page aloud for visually impaired users) let users jump directly to "navigation," "main content," or "footer" as landmarks, the same way you'd flip straight to a book's table of contents instead of reading every page front to back. Generic `<div>`s offer no such landmarks.
2. **SEO (Search Engine Optimization)** — search engines like Google parse your semantic tags to better understand what's actually *important* on your page versus decorative wrapper content. A `<nav>` full of links is understood differently than a `<section>` full of prose. You don't need to become an SEO expert for this series, but know that "using the right tag for the right job" is free SEO credit you get just by writing correct HTML — no extra effort required beyond what you're already learning.

**The Implementation:**

```html
<!-- part-3-landing-page/index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Brightpath Studio — Web Design That Grows With You</title>
    <link rel="stylesheet" href="css/style.css" />
  </head>
  <body>
    <header class="site-header">
      <div class="logo">Brightpath Studio</div>
      <nav class="main-nav">
        <a href="#about">About</a>
        <a href="#features">Features</a>
        <a href="#contact">Contact</a>
      </nav>
    </header>

    <section class="hero">
      <h1>Websites That Feel as Good as They Look</h1>
      <p class="hero-subheading">
        We design and build fast, beautiful websites for small businesses
        and independent creators — no bloated templates, no jargon.
      </p>
      <a href="#contact" class="cta-button">Get Started</a>
    </section>

    <section id="about" class="about">
      <h2>About Brightpath</h2>
      <p>
        Brightpath Studio is a two-person design shop obsessed with clean
        code and even cleaner design. We believe your website should load
        fast, read clearly, and represent your brand honestly — not hide
        behind trends that will look dated in a year.
      </p>
    </section>

    <section id="features" class="features">
      <h2>What We Offer</h2>
      <div class="feature-grid">
        <div class="feature-card">
          <h3>Custom Design</h3>
          <p>Every site is designed from scratch around your brand, not a recycled template.</p>
        </div>
        <div class="feature-card">
          <h3>Fast Performance</h3>
          <p>Hand-written HTML and CSS means your site loads in a blink, on any device.</p>
        </div>
        <div class="feature-card">
          <h3>Ongoing Support</h3>
          <p>We don't disappear after launch — you get a real point of contact for updates.</p>
        </div>
      </div>
    </section>

    <footer id="contact" class="site-footer">
      <p>&copy; 2024 Brightpath Studio. All rights reserved.</p>
      <p>
        <a href="mailto:hello@brightpathstudio.example">hello@brightpathstudio.example</a>
      </p>
      <p class="social-links">
        <a href="https://github.com/" target="_blank" rel="noopener noreferrer">GitHub</a>
        &nbsp;|&nbsp;
        <a href="https://www.linkedin.com/" target="_blank" rel="noopener noreferrer">LinkedIn</a>
      </p>
    </footer>
  </body>
</html>
```

A few new details worth calling out explicitly:

- `<nav>` links like `<a href="#about">` use a **fragment link** — the `#` followed by an ID (`id="about"` on our `<section>`) tells the browser "scroll down to the element with this exact ID," entirely without JavaScript. This is the "unique landmark" use case for IDs we flagged back in Part 2's reference section.
- `&copy;` is another **HTML entity** (like `&nbsp;` from Part 1) — it renders the © symbol.
- `<a href="mailto:...">` is a special link type: clicking it opens the visitor's default email application with that address pre-filled in the "To" field.

**The Verification:**

Open with Live Server. You won't have any styling yet, but you should see all sections present in order: header with logo and three nav links, a hero heading/subheading/button, an about paragraph, three feature blocks, and a footer with copyright, email link, and social links. Click each nav link — the page should jump down to the corresponding section (About, Features/that same anchor, or the footer/Contact), confirming your fragment links and IDs are correctly wired.

---

## Step 3: Layout Fundamentals — Margins, Padding, and `max-width` to Avoid Stretching

**The Target:** `css/style.css` — base resets and a content-width constraint applied consistently across every section.

**The Concept:** Recall Part 2's lesson: an unconstrained page stretches its text edge-to-edge on a wide monitor, producing painfully long line lengths that are hard to read (imagine a newspaper column stretched across an entire table — your eyes get lost finding the start of the next line). The professional fix is a **content wrapper pattern**: give each section's *inner content* a `max-width` and center it with `margin: 0 auto`, while the section's *background* is allowed to stretch full-width behind it. This is exactly how nearly every real marketing site on the internet is built.

**The Implementation:**

```css
/* part-3-landing-page/css/style.css */

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: "Segoe UI", Arial, sans-serif;
  color: #1f2937;
  line-height: 1.6;
}

/* --- Reusable content wrapper pattern --- */
/* Any section that needs constrained, centered content gets this class */
.content-wrap {
  max-width: 1000px;
  margin: 0 auto;
  padding: 0 24px;
}

/* --- Header --- */
.site-header {
  display: flex;
  /* Flexbox gets a proper deep-dive in Part 4 -- for now, just know it lets us */
  /* place the logo and nav side-by-side in one row instead of stacked vertically */
  justify-content: space-between;
  align-items: center;
  padding: 20px 40px;
  background-color: #ffffff;
  border-bottom: 1px solid #e5e7eb;
}

.logo {
  font-weight: bold;
  font-size: 1.3rem;
  color: #1e3a8a;
}

.main-nav a {
  margin-left: 24px;
  text-decoration: none;
  color: #374151;
  font-weight: 500;
}

.main-nav a:hover {
  color: #1e3a8a;
}

/* --- Hero section --- */
.hero {
  background-color: #1e3a8a;
  color: #ffffff;
  text-align: center;
  padding: 100px 24px;
}

.hero h1 {
  font-size: 2.5rem;
  max-width: 700px;
  margin: 0 auto 16px auto;
  /* shorthand margin: top right bottom left -- here, 0 top, auto sides (centers it), 16px bottom */
}

.hero-subheading {
  font-size: 1.15rem;
  max-width: 550px;
  margin: 0 auto 32px auto;
  color: #dbeafe;
}

.cta-button {
  display: inline-block;
  background-color: #facc15;
  color: #1f2937;
  font-weight: bold;
  padding: 14px 32px;
  border-radius: 6px;
  text-decoration: none;
}

.cta-button:hover {
  background-color: #eab308;
}

/* --- About section --- */
.about {
  max-width: 700px;
  margin: 0 auto;
  padding: 80px 24px;
  text-align: center;
}

.about h2 {
  font-size: 1.8rem;
  color: #1e3a8a;
  margin-bottom: 20px;
}

/* --- Features section --- */
.features {
  background-color: #f9fafb;
  padding: 80px 24px;
  text-align: center;
}

.features h2 {
  font-size: 1.8rem;
  color: #1e3a8a;
  margin-bottom: 40px;
}

.feature-grid {
  max-width: 1000px;
  margin: 0 auto;
  display: flex;
  /* another early preview of Flexbox -- three cards placed in a row, evenly spaced */
  gap: 24px;
  flex-wrap: wrap;
  justify-content: center;
}

.feature-card {
  background-color: #ffffff;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  padding: 28px;
  flex: 1 1 260px;
  /* flex: 1 1 260px means "grow and shrink freely, but prefer a 260px base width" */
  text-align: left;
}

.feature-card h3 {
  color: #1e3a8a;
  margin-bottom: 10px;
}

/* --- Footer --- */
.site-footer {
  background-color: #111827;
  color: #d1d5db;
  text-align: center;
  padding: 40px 24px;
}

.site-footer a {
  color: #93c5fd;
  text-decoration: none;
}

.site-footer a:hover {
  text-decoration: underline;
}

.social-links {
  margin-top: 8px;
}
```

**The Verification:**

Save and refresh. You should now see a genuinely polished-looking one-page site: a clean white header with logo left / nav right, a bold blue hero section with a centered headline, subheading, and yellow call-to-action button, a centered About paragraph, three evenly spaced feature cards on a light gray background, and a dark footer with working contact links. Resize your browser window narrower — notice the feature cards should wrap onto new lines rather than squeezing painfully thin (thanks to `flex-wrap: wrap`), a small preview of the responsive behavior Part 4 covers in full depth.

---

## End-of-Part Challenge: Add a Section + Link Back to Part 1

**Your task:**
1. Add one new section — a **Testimonials** section — between Features and the Footer, using the same `content-wrap`/section-padding patterns you've already learned.
2. Change the hero's CTA button so it links to your **Part 1 bio card** instead of `#contact`, with the text "Learn more about me."

**Reference Solution (relevant excerpt — insert this `<section>` between `.features` and `<footer>` in the HTML, and update the hero button):**

```html
<!-- Updated hero CTA, inside the .hero section -->
<a href="../part-1-bio-card/index.html" class="cta-button">Learn more about me</a>
<!-- ../ means "go up one folder level" -- from part-3-landing-page/, that reaches -->
<!-- build-as-you-learn/, then back down into part-1-bio-card/ -->
```

```html
<!-- New section, placed after </section> (features) and before <footer> -->
<section class="testimonials">
  <h2>What Clients Say</h2>
  <div class="testimonial-grid">
    <div class="testimonial-card">
      <p>"Brightpath turned our outdated site into something we're actually proud to share."</p>
      <p class="testimonial-author">— Jordan M., Small Business Owner</p>
    </div>
    <div class="testimonial-card">
      <p>"Fast, communicative, and the final result loaded instantly. Highly recommend."</p>
      <p class="testimonial-author">— Priya S., Freelance Illustrator</p>
    </div>
  </div>
</section>
```

```css
/* Additions to css/style.css */

.testimonials {
  padding: 80px 24px;
  text-align: center;
}

.testimonials h2 {
  font-size: 1.8rem;
  color: #1e3a8a;
  margin-bottom: 40px;
}

.testimonial-grid {
  max-width: 900px;
  margin: 0 auto;
  display: flex;
  gap: 24px;
  flex-wrap: wrap;
  justify-content: center;
}

.testimonial-card {
  background-color: #f9fafb;
  border-left: 4px solid #1e3a8a;
  padding: 24px;
  flex: 1 1 300px;
  text-align: left;
  font-style: italic;
}

.testimonial-author {
  margin-top: 12px;
  font-style: normal;
  font-weight: bold;
  color: #374151;
}
```

**Verification for the challenge:**

Refresh and confirm: a new Testimonials section appears between Features and the Footer with two styled quote cards, and clicking the hero's "Learn more about me" button navigates to your Part 1 bio card page. If the link 404s (shows a "file not found" error), double-check your relative path — it depends on `part-1-bio-card` and `part-3-landing-page` being sibling folders inside `build-as-you-learn/`, exactly as we set up back in Part 0.

---

## Reference Section: Deep Dive for Part 3

### Every Semantic Tag Introduced, Compared to `<div>`

| Tag | Meaning | Roughly Equivalent Non-Semantic Version |
|---|---|---|
| `<header>` | Introductory content, typically top-of-page (or top-of-section) | `<div class="header">` |
| `<nav>` | A block of primary navigation links | `<div class="nav">` |
| `<section>` | A distinct thematic grouping of content, usually with a heading | `<div class="section">` |
| `<footer>` | Closing content: copyright, contact, secondary links | `<div class="footer">` |
| `<main>` | (Not used yet, but worth knowing) wraps the single primary content region of a page, excluding repeated header/nav/footer | `<div class="main">` |

The functional/visual result is *identical* either way — semantic tags carry zero built-in styling of their own (you still had to write every CSS rule). The difference is entirely about *meaning conveyed to machines* (browsers, screen readers, search engines) and *clarity conveyed to future-you* re-reading this code in six months.

### SEO and Accessibility, Without the Overwhelm

You don't need to memorize SEO rulebooks. Just internalize these two habits, both of which you've already practiced in this part:

1. **Use exactly one `<h1>` per page**, and use `<h2>`/`<h3>` in properly descending order for subsections — never skip from `<h1>` straight to `<h3>` just because it "looks" the right size (use CSS for sizing, not heading level).
2. **Wrap your real navigation in `<nav>`, your real page footer in `<footer>`**, and prefer `<section>` over generic `<div>` whenever a chunk of content represents its own distinct "chapter" of the page with a heading. If it's just a layout helper (like our `.feature-grid` wrapper, which has no heading of its own and exists purely to arrange cards), a plain `<div>` is the *correct*, honest choice — semantic tags are not meant to replace every single `<div>` on your page.

### Fragment Links (`#id`) In Depth

```html
<a href="#features">Features</a>
```

```html
<section id="features">...</section>
```

When the `href` starts with `#`, the browser doesn't navigate to a new page at all — it searches the *current* page for an element whose `id` matches the text after the `#`, and scrolls it into view. This only works if:
- The target element actually has that exact `id` (case-sensitive, no `#` in the HTML attribute itself — only in the link).
- IDs are unique per page — if two elements accidentally shared `id="features"`, the browser would jump to whichever one appears first in the HTML, and it's considered invalid HTML to have duplicates at all.

### The Content-Wrap Pattern, Generalized

The pattern we used repeatedly in this part:

```css
.some-section {
  background-color: #whatever;  /* stretches full browser width */
  padding: 80px 24px;            /* vertical breathing room + minimum side padding on small screens */
}

.some-section-inner-content {
  max-width: 1000px;   /* caps how wide the actual text/cards can get */
  margin: 0 auto;       /* centers that capped-width content within the full-width section */
}
```

is arguably the single most reused CSS pattern in professional web design. You'll see it again, verbatim in spirit, in Part 6's blog layout and Part 9's capstone. It's worth typing it enough times in this series that it becomes automatic.

### Common Beginner Mistakes to Watch For

1. **Using `<section>` for every single `<div>`-like grouping**, even ones with no heading or thematic identity (like our `.feature-grid` card wrapper). If it's purely a layout container, use `<div>`.
2. **Forgetting that fragment links require exact, case-sensitive ID matches** — `href="#About"` will not scroll to `id="about"`.
3. **Applying `max-width` to the section itself instead of an inner wrapper**, which prevents the background color from stretching full-bleed across the browser — a subtle but common layout bug when first learning this pattern.
4. **Nesting `<nav>` inside `<nav>`, or putting non-navigational links (like a single "Skip to content" utility link, which is a different accessibility pattern) inside your main `<nav>`** — keep `<nav>` reserved cleanly for your primary site navigation links.

---

## What's Next

You now have a real, semantically structured, professionally laid-out landing page — and it's already linked to your Part 1 bio card, meaning your mini-portfolio has officially started stitching itself together. In Part 4, we go all-in on **Flexbox**: the layout system you've been previewing informally in the header, feature grid, and testimonials (`display: flex` has quietly been doing real work already) gets its own full, dedicated treatment as we build a photo gallery where cards line up, wrap gracefully, and respond to screen size — no more "just enough Flexbox to get by," but genuine command of `flex-direction`, `justify-content`, `align-items`, and `gap`.
