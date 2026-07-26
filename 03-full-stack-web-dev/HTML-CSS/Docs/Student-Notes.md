# Build As You Learn: HTML & CSS from Zero to Portfolio
## Student Notes — Condensed Reference

*Quick-review notes for each Part, Appendix, and Primer. Use this alongside the workbook — the workbook tests you; these notes remind you. Keep this open in a side tab while building.*

---

## PART 0 — Introduction

**One-line takeaway:** HTML = structure/content. CSS = appearance. Browser = the thing that reads both and draws pixels.

- Environment: VS Code + Live Server extension + any modern browser.
- Live Server watches files → auto-refreshes browser on save. No install/compile step for HTML/CSS.
- Project root: `build-as-you-learn/`, one subfolder per part, all siblings.
- Every project's main page is named `index.html` — browsers/servers treat this as the default file for a folder.
- Capstone (Part 9) final structure to keep in mind:

```
my-portfolio/
├── index.html / about.html / projects.html / contact.html / recipe.html
├── css/style.css, layout.css, components.css
└── images/
```

- The whole series' promise: **nothing built gets thrown away** — every part feeds Part 9.

---

## PART 1 — Personal Bio Card

**One-line takeaway:** Tags label content; CSS decorates it. Same content, endless appearances.

**Skeleton every HTML file needs:**
```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Page Title</title>
  </head>
  <body>
    <!-- visible content -->
  </body>
</html>
```

| Tag | Notes |
|---|---|
| `<h1>`–`<h6>` | One `<h1>` per page; descending order, don't skip levels |
| `<p>` | Paragraph |
| `<img src="" alt="" />` | Self-closing; `alt` is mandatory, describes content/function |
| `<a href="" target="_blank" rel="noopener noreferrer">` | `target="_blank"` opens new tab; always pair with `rel="noopener noreferrer"` for security |
| `<ul>`/`<ol>`/`<li>` | Unordered vs ordered lists |
| `<blockquote>` | Quoted block |

**CSS basics:**
- Inline: `style="color: blue;"` — sticky-note on one element, avoid at scale.
- Internal: `<style>` block in `<head>` — one rule applies to every matching tag on the page.
- Selector anatomy: `selector { property: value; }`
- `:hover` = pseudo-class, applies only during that state.

**Gotcha:** unclosed tags (`<p>text<p>` instead of `</p>`) — browsers are forgiving but layout can still break subtly.

---

## PART 2 — Recipe Page

**One-line takeaway:** External CSS = reusable across unlimited pages. Box model = content → padding → border → margin.

**Linking external CSS:**
```html
<link rel="stylesheet" href="style.css" />
```
- `rel="stylesheet"` is mandatory.
- `href` is a relative path from the HTML file's own location.

**Selectors:**
| Type | HTML | CSS | Reusable? |
|---|---|---|---|
| Tag | — | `p { }` | Every instance, no exceptions |
| Class | `class="name"` | `.name { }` | Yes, many elements |
| ID | `id="name"` | `#name { }` | No — one per page |

**Box model (memorize this order): content → padding → border → margin**
- Padding = space between content and border (frame around a photo).
- Margin = space between an element's border and its neighbors (space between two frames on a wall).

**Universal reset used going forward:**
```css
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box; /* width/height now INCLUDE padding+border, not add on top */
}
```

**Centering pattern:**
```css
.card {
  max-width: 640px;
  margin: 0 auto; /* auto left/right = horizontal centering */
}
```

**Gotcha:** forgetting the `.` on class selectors in CSS (`recipe-title` instead of `.recipe-title`).

---

## PART 3 — Multi-Section Landing Page

**One-line takeaway:** Semantic tags = boxes with labels printed on the outside. Same rendering as `<div>`, but machines (screen readers, search engines) understand meaning.

| Tag | Meaning |
|---|---|
| `<header>` | Top banner: logo + nav |
| `<nav>` | Primary navigation links only |
| `<section>` | Thematic content grouping, usually with its own heading |
| `<footer>` | Closing content: copyright, contact, secondary links |
| `<main>` | The single primary content region (one per page) |
| `<div>` | Still correct for pure layout grouping with no semantic identity |

**Fragment links (in-page navigation, no JS):**
```html
<a href="#about">About</a>
...
<section id="about">...</section>
```
- IDs must be unique and exact-case-matching.

**Content-wrap pattern (reused constantly for the rest of the series):**
```css
.section {
  background-color: #whatever; /* stretches full width */
  padding: 80px 24px;
}
.container {
  max-width: 1000px;
  margin: 0 auto; /* caps AND centers the inner content only */
}
```

**Gotcha:** applying `max-width`/`margin:auto` directly to the full-width colored section instead of an inner wrapper — kills the full-bleed background effect.

---

## PART 4 — Flexbox Photo Gallery

**One-line takeaway:** `display: flex` on the PARENT turns children into a row that can wrap, align, and grow/shrink.

```css
.gallery {
  display: flex;        /* parent = flex container */
  flex-wrap: wrap;      /* allow wrapping instead of overflow/squeeze */
  gap: 20px;            /* spacing between items, both axes */
  justify-content: flex-start; /* main-axis alignment */
  align-items: stretch;        /* cross-axis alignment */
}
.gallery-card {
  flex: 1 1 260px; /* grow shrink basis */
}
```

**Axes:**
- Main axis = direction of flow (default: left→right, i.e. `row`)
- Cross axis = perpendicular to main axis
- `flex-direction: column` **swaps** which axis `justify-content` vs `align-items` controls.

**`flex: grow shrink basis` cheat sheet:**
- `grow` (0 or 1+): willing to expand into leftover space?
- `shrink` (0 or 1+): willing to shrink under pressure?
- `basis` (px value): starting/ideal width before growing/shrinking

**Gotcha:** `display: flex` on the child instead of the parent → nothing visibly changes.

---

## PART 5 — Responsive Navbar (Positioning)

**One-line takeaway:** `absolute` is never truly absolute — it's relative to the nearest ancestor with `position` ≠ `static`. `relative` on a parent = the fix.

| Value | Stays in flow? | Anchored to |
|---|---|---|
| `static` (default) | Yes | N/A — offsets ignored |
| `relative` | Yes | Its own normal spot |
| `absolute` | No | Nearest non-static ancestor (or whole page if none) |
| `fixed` | No | Browser viewport; ignores scroll |
| `sticky` | Yes, until threshold | Then behaves like `fixed`, bounded by parent |

**The critical pairing:**
```css
.parent { position: relative; }   /* anchor point, no offset needed */
.child   { position: absolute; top: 0; right: 0; }  /* now anchored correctly */
```

**Media query syntax:**
```css
@media (max-width: 768px) {
  /* rules apply only at/below 768px width */
}
```

**Checkbox-hack mobile menu (pure CSS, no JS):**
```html
<input type="checkbox" id="menu-toggle" class="menu-toggle-checkbox" />
<label for="menu-toggle" class="hamburger-icon">...</label>
<ul class="navbar-links">...</ul> <!-- must come AFTER the checkbox -->
```
```css
.menu-toggle-checkbox { display: none; }
.menu-toggle-checkbox:checked ~ .navbar-links {
  max-height: 300px; /* ~ = general sibling combinator, selects AFTER only */
}
```

**Gotchas:** forgetting `relative` on the anchor parent; checkbox placed after the menu in HTML (sibling combinator only looks forward); forgetting top padding to compensate for a `fixed` navbar covering content.

---

## PART 6 — Grid Blog Layout

**One-line takeaway:** Flexbox = one dimension (a line that wraps). Grid = two dimensions (rows AND columns, defined upfront).

```css
.layout {
  display: grid;
  grid-template-columns: 2fr 1fr; /* fr = fraction of available space */
  gap: 32px;
}
.sidebar {
  grid-column: 2 / 3; /* start line 2, end line 3 */
  grid-row: 1 / 3;    /* spans across 2 rows */
}
```

**Responsive grid with zero media queries:**
```css
.grid-auto {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 24px;
}
```
- `auto-fit`: fit as many columns as comfortably possible
- `minmax(220px, 1fr)`: never narrower than 220px; grow to fill equally otherwise

**Flexbox vs Grid decision table:**
| Need | Use |
|---|---|
| One direction, wrapping | Flexbox |
| Deliberate rows + columns together | Grid |
| An item spanning multiple rows/cols precisely | Grid |
| Simple internal stacking inside one card | Flexbox |
| Overall page skeleton (header/sidebar/main/footer) | Grid |

**Gotcha:** `grid-column: 1 / 3` means "line 1 to line 3" (spans 2 columns), NOT "span 3 columns" — line numbers ≠ column counts.

---

## PART 7 — Animated Product Card

**One-line takeaway:** `transform` moves visuals without disturbing layout. `transition` = smooth 2-state animation. `@keyframes` = multi-step choreography.

```css
.card {
  transition: transform 0.25s ease, box-shadow 0.25s ease; /* MUST be on base state */
}
.card:hover {
  transform: translateY(-8px);
  box-shadow: 0 16px 32px rgba(0,0,0,0.15);
}
```

```css
@keyframes fadeSlideIn {
  from { opacity: 0; transform: translateY(-10px); }
  to   { opacity: 1; transform: translateY(0); }
}
.badge { opacity: 0; }
.card:hover .badge {
  animation: fadeSlideIn 0.4s ease forwards; /* forwards = keep final state after finishing */
}
```

**Transform functions:** `translateX/Y()`, `scale()`, `rotate()`
**Prefer animating:** `transform`, `opacity` (cheap for browser) — avoid animating `width`/`top`/`left` (expensive, causes jank)

**UX rules for motion:**
1. Motion should communicate interactivity/hierarchy, not just decorate.
2. Keep durations 150–350ms.
3. Don't animate everything at once.
4. Respect `prefers-reduced-motion`:
```css
@media (prefers-reduced-motion: reduce) {
  * { transition: none !important; animation: none !important; }
}
```

**Gotcha:** `transition` written inside `:hover` instead of base state → entry/exit animate inconsistently. Missing `forwards` → animated element snaps back after finishing.

---

## PART 8 — Contact Form

**One-line takeaway:** Browsers have free, built-in validation — `required` and `type="email"` do real work with zero JavaScript.

```html
<label for="email">Email</label>
<input type="email" id="email" name="email" placeholder="you@example.com" required />
```
- `for`/`id` must match exactly — clicking label focuses input.
- `name` is required for the field's data to be submitted at all.
- `required` blocks submission until filled.
- `type="email"` = built-in format validation + better mobile keyboard.

**Focus styling (never remove without replacing):**
```css
input:focus {
  outline: none;
  border-color: blue;
  box-shadow: 0 0 0 3px rgba(37,99,235,0.15);
}
```

**Live validation feedback, safely:**
```css
input:invalid:not(:placeholder-shown) { border-color: red; }  /* only once user typed something */
input:valid:not(:placeholder-shown)   { border-color: green; }
```

**Custom error message reveal:**
```css
.error-message { display: none; }
input:invalid:not(:placeholder-shown) ~ .error-message { display: block; }
```

**`GET` vs `POST`:** `GET` puts data in the URL (fine for simple retrieval); `POST` (used for forms) sends data hidden in the request body.

**CSS-only validation CANNOT:** custom-word the native tooltip, validate cross-field logic (password match), or submit without a page reload — that's JavaScript's job.

**Gotcha:** styling `:invalid` without `:not(:placeholder-shown)` → every empty required field looks broken on page load.

---

## PART 9 — Capstone Portfolio

**One-line takeaway:** A design system = change one variable, update the whole site.

**CSS custom properties:**
```css
:root {
  --color-primary: #2563eb;
  --radius-md: 8px;
}
.btn { background-color: var(--color-primary); }
```
- Declared in `:root` → available everywhere.
- Change the `:root` value once → every `var()` reference updates automatically.

**Three-file CSS architecture:**
| File | Job |
|---|---|
| `style.css` | Design tokens, resets, global base (navbar, footer) |
| `layout.css` | Structural patterns (`.container`, `.grid-auto`, `.hero`) |
| `components.css` | Reusable UI pieces (`.btn`, `.card`, `.form-group`) |

**Manual "current page" convention (HTML/CSS has no built-in concept of this):**
```html
<a href="about.html" class="active">About</a>
```

**Capstone page → origin Part map:**
- `about.html` ← Part 1
- `contact.html` ← Part 8
- `projects.html` grid ← Part 4 + Part 6
- navbar (every page) ← Part 5
- card hover animation (every card) ← Part 7
- `recipe.html` ← Part 2

**Pre-launch checklist:** responsive at 375px, text contrast, full keyboard tab-through, `.active` nav state correct per page, `<title>` + `<meta description>` on every page, reduced-motion respected.

---

## APPENDIX A — DevTools

- Open: `F12` / `Ctrl+Shift+I` (`Cmd+Option+I` Mac), or right-click → Inspect.
- **Elements tab:** live HTML tree; hover a line → highlights on page.
- **Styles pane:** every CSS rule affecting selected element, with source file/line; **crossed-out = lost the cascade** to another rule above it.
- Click any value in Styles pane → live-edit (never saved to disk — refresh reverts it).
- **Box model diagram:** actual margin/border/padding/content numbers, visually.
- **Device toolbar** (`Ctrl+Shift+M`): simulate specific screen widths, test media queries precisely.
- **Console tab:** red errors = broken file references (404s, etc.).
- **Network tab:** every requested file + status code (200 = OK, 404 = not found).

**Debugging habit:** right-click → Inspect FIRST, before touching your editor, whenever something looks wrong.

---

## APPENDIX B — Glossary (Most-Referenced Items)

**Tags:** `<div>` (generic/no meaning) vs `<section>` (thematic, usually has heading) vs `<article>` (self-contained, syndication-worthy) vs `<aside>` (tangential content).

**Properties quick-hit list:**
- `box-sizing: border-box` — width/height include padding+border
- `object-fit: cover` — image crops to fill box neatly
- `z-index` — stacking order when elements overlap
- `overflow: hidden` — clips content exceeding its box

**Combinators:** `A B` (descendant, anywhere inside), `A > B` (direct child only), `A ~ B` (sibling, after only)

**Units:** `px` (fixed), `rem` (relative to root font-size, accessibility-friendly), `%` (relative to parent), `vh`/`vw` (relative to browser viewport)

---

## APPENDIX C — Debugging Decision Tree

1. Is the file even loading? → Network tab, check for 404s.
2. Is my selector matching the right element? → Styles pane, missing/crossed-out rules.
3. Is something else overriding my rule? → Look for strikethrough rule above it.
4. Is the element positioned/sized how I think? → Box model diagram.
5. Does this only break at certain widths? → Device toolbar.
6. Any red errors in Console? → Broken file references.

**Most common bugs ranked:** (1) wrong `<link>`/`src` path, (2) class name typo mismatch between HTML/CSS, (3) forgot `position: relative` on anchor parent, (4) `display: flex` on wrong element, (5) case-sensitivity breaking only after deployment.

---

## APPENDIX D — Deployment

**GitHub Pages flow:**
```bash
cd my-portfolio
git init
git add .
git commit -m "Initial upload"
git branch -M main
git remote add origin https://github.com/USERNAME/REPO.git
git push -u origin main
```
Then: Settings → Pages → Source: `main` branch, `/root` → live at `https://username.github.io/repo/`.

**Key gotcha:** sibling-folder relative links (`../part-4-...`) break once a project is deployed as its own isolated repo — either deploy each project separately and link full URLs, or nest everything in one repo.

**Netlify:** drag-and-drop folder → instant live URL, no Git required (but no auto-updates unless Git-connected).

---

## APPENDIX E — Where to Go Next

Suggested order: **1) JavaScript fundamentals → 2) Accessibility auditing (Lighthouse/WAVE) → 3) CSS naming (BEM) → 4) React/frameworks → 5) Build tools** (usually absorbed automatically once learning React).

Key mindset: frameworks don't replace HTML/CSS fundamentals — they relocate where that code lives and add JS-driven behavior on top.

---

## PRIMER 1 — How the Web Works

- Client (browser, asks) ↔ Server (stores/responds)
- URL = scheme (`https://`) + domain (translated via DNS) + path (specific file)
- Cycle: browser sends `GET` request → server responds with file + status code → browser parses/renders
- Status codes: `2xx` success, `4xx` client error (`404` = not found), `5xx` server error
- `GET` = data in URL; `POST` = data in request body (forms use this)
- `127.0.0.1` / `localhost` = "this same computer" (what Live Server uses)

---

## PRIMER 2 — Files, Folders, Paths

- File system = tree; folders = branches; files = leaves.
- Absolute path = full route from the very top (breaks when moved to another computer).
- Relative path = route from the current file's location (survives being moved, as long as relationships stay intact).
- `../` = go up one folder level.
- Paths are literal text comparisons — **case-sensitive on real servers**, even if forgiving locally.
- Best practice: lowercase, hyphenated filenames always (`profile-photo.jpg`).

---

## PRIMER 3 — Reading Code Like a Sentence

Four universal patterns in all structured code:
1. **Delimiters** — matching open/close pairs (`<tag></tag>`, `{ }`)
2. **Key-value pairs** — label + value (`src="..."` in HTML, `color: blue;` in CSS)
3. **Nesting** — containers inside containers (indentation is for humans only, browser doesn't care)
4. **Comments** — ignored by the machine, for humans (`<!-- -->` in HTML, `/* */` in CSS)

---

## PRIMER 4 — Color, Units, Measurement

- Every color = 3 numbers: Red, Green, Blue intensity (0–255 each).
- Hex code = same RGB numbers, written in base-16 (`#2563eb` = `rgb(37, 99, 235)`).
- `rgba(r,g,b,a)` — 4th value (alpha, 0–1) = transparency/dilution.
- `px` = fixed, absolute ruler.
- `rem` = relative to root (`<html>`) font-size — scales with user's accessibility font settings; **prefer over `px` for font-size**.
- `em` = relative to parent's font-size (compounds when nested — less predictable).
- `%` = relative to parent's own dimension.
- `vh`/`vw` = relative to the whole browser viewport, bypasses parent chain.

---

## PRIMER 5 — Command Line Basics

| Command | Meaning |
|---|---|
| `pwd` | Where am I standing? |
| `cd foldername` | Move into subfolder |
| `cd ..` | Move up one level |
| `ls` (Mac/Git Bash) / `dir` (Windows CMD) | List contents of current folder |
| `mkdir name` | Create new folder |
| `git init` | Start tracking this folder |
| `git add .` | Stage all files |
| `git commit -m "msg"` | Save a snapshot |
| `git push` | Upload snapshot to remote (GitHub) |
| `git status` | Check current tracked-file state |

---

## MASTER SYNTAX CHEAT SHEET (All Parts, One Page)

```css
/* Reset — use on every project */
* { margin: 0; padding: 0; box-sizing: border-box; }

/* Centering a constrained block */
.container { max-width: 1000px; margin: 0 auto; padding: 0 24px; }

/* Flexbox row that wraps */
.row { display: flex; flex-wrap: wrap; gap: 20px; justify-content: flex-start; align-items: stretch; }
.row > * { flex: 1 1 260px; }

/* Responsive grid, zero media queries */
.grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 24px; }

/* Explicit grid placement */
.item { grid-column: 1 / 2; grid-row: 1 / 3; }

/* Positioning anchor pair */
.parent { position: relative; }
.child  { position: absolute; top: 0; right: 0; }

/* Fixed navbar + compensating padding */
.navbar { position: fixed; top: 0; left: 0; width: 100%; z-index: 100; }
.content { padding-top: 90px; }

/* Media query */
@media (max-width: 768px) { /* mobile rules */ }

/* Smooth hover animation */
.card { transition: transform 0.25s ease, box-shadow 0.25s ease; }
.card:hover { transform: translateY(-8px); box-shadow: 0 16px 32px rgba(0,0,0,0.15); }

/* Keyframes */
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
.el { animation: fadeIn 0.4s ease forwards; }

/* Safe form validation styling */
input:focus { outline: none; border-color: blue; box-shadow: 0 0 0 3px rgba(37,99,235,0.15); }
input:invalid:not(:placeholder-shown) { border-color: red; }
input:valid:not(:placeholder-shown) { border-color: green; }

/* Design tokens */
:root { --color-primary: #2563eb; --radius-md: 8px; }
.btn { background-color: var(--color-primary); border-radius: var(--radius-md); }
```

---

*End of Student Notes. Pair with the Workbook for exercises and the full series text for complete explanations/analogies.*
