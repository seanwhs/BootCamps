# Build As You Learn: HTML & CSS from Zero to Portfolio
## The Official Quiz Bank

---

### How to Use This Quiz Bank

Each Part, Appendix, and Primer has its own quiz below, mixing multiple choice, true/false, fill-in-the-blank, code output prediction, and short answer questions. **Answer keys immediately follow each quiz.** Cover the key with your hand (or a sheet of paper) before attempting the questions — treat this like a real assessment, not a read-through.

Suggested use: take a quiz *after* finishing the corresponding Part/Appendix/Primer, and again a week later to test retention.

---
---

# QUIZ 0 — Introduction

1. **(MC)** What is the primary role of CSS in the HTML/CSS relationship taught in this series?
 a) CSS defines the meaning of content
 b) CSS defines the appearance of content
 c) CSS defines the logic of a page
 d) CSS replaces the need for HTML

2. **(T/F)** Live Server requires you to manually refresh the browser every time you save a file.

3. **(Fill-in)** Every project folder in this series' capstone lives as a __________ of every other project folder inside `build-as-you-learn/`.

4. **(Short Answer)** Name the file that every project in this series uses as its main entry page, and explain why that specific name matters.

5. **(MC)** According to Part 0, what is the very first proof that your development environment works end-to-end?
 a) Deploying to GitHub Pages
 b) Successfully installing VS Code
 c) Watching a saved change auto-refresh in the browser
 d) Writing your first CSS selector

6. **(T/F)** This series intends for projects built in early parts to be deleted once later parts are completed.

7. **(Fill-in)** The three CSS files planned for the capstone's architecture are `style.css`, `__________.css`, and `__________.css`.

### Answer Key — Quiz 0
1. b
2. False — Live Server auto-refreshes on save.
3. sibling
4. `index.html` — servers and browsers treat it as the default file shown for a folder, with no need to specify a filename in the URL.
5. c
6. False — nothing is thrown away; every project is reused later.
7. `layout.css`, `components.css`

---
---

# QUIZ 1 — Personal Bio Card

1. **(MC)** Which tag should appear only once per page, reserved for the single most important heading?
 a) `<head>`
 b) `<h1>`
 c) `<title>`
 d) `<strong>`

2. **(Fill-in)** The `<img>` tag is called a __________ tag because it has no separate closing tag.

3. **(T/F)** `alt` text is optional and only matters for decorative flourish.

4. **(Code Output)** What color will this paragraph render as?
```html
<style> p { color: blue; } </style>
<p style="color: red;">Text</p>
```
 a) blue b) red c) black d) no color renders

5. **(MC)** Which of the following correctly and safely opens a link in a new tab?
 a) `<a href="site.com" newtab="true">`
 b) `<a href="https://site.com" target="_blank" rel="noopener noreferrer">`
 c) `<a src="https://site.com" blank>`
 d) `<a link="https://site.com" open="new">`

6. **(Short Answer)** Explain the difference between an inline style and a `<style>` block in terms of *how many elements* each affects.

7. **(Fill-in)** A CSS rule has two parts: the __________, which decides *which* elements are targeted, and the __________, containing property-value pairs.

8. **(T/F)** `<!DOCTYPE html>` is itself an HTML tag.

9. **(MC)** What does `<meta name="viewport" content="width=device-width, initial-scale=1.0" />` primarily prevent?
 a) Slow loading images
 b) Mobile browsers zooming out to fake a desktop view
 c) Broken links
 d) Missing fonts

10. **(Short Answer)** Why does professional practice recommend `alt=""` (empty but present) for a purely decorative image, rather than omitting `alt` entirely?

### Answer Key — Quiz 1
1. b
2. self-closing
3. False — `alt` is essential for screen readers and for what displays if the image fails to load.
4. b (inline styles override same-element tag-selector styles due to specificity)
5. b
6. Inline style affects only the single element it's written on; a `<style>` block's selector-based rules affect every matching element on the page.
7. selector; declaration block
8. False — it's a declaration, not a tag; it has no closing counterpart and isn't an element.
9. b
10. Omitting `alt` entirely can cause screen readers to announce the image's filename or "unlabeled image," which is worse than nothing; `alt=""` explicitly tells assistive tech to skip it.

---
---

# QUIZ 2 — Recipe Page

1. **(Fill-in)** List the box model's four layers, from innermost to outermost: __________, __________, __________, __________.

2. **(MC)** Which attribute is required on `<link>` for the browser to correctly recognize a stylesheet?
 a) `type="css"`
 b) `rel="stylesheet"`
 c) `format="css"`
 d) `stylesheet="true"`

3. **(T/F)** A class selector can be applied to multiple different elements on the same page.

4. **(Code Output)** Given `box-sizing: border-box;`, `width: 200px;`, `padding: 20px;`, `border: 5px solid black;` — what is the width of the actual content area?
 a) 200px b) 150px c) 250px d) 170px

5. **(Short Answer)** In your own words, using an analogy, explain the difference between padding and margin.

6. **(Fill-in)** An ID selector is written with a __________ prefix in CSS, and should be used no more than __________ time(s) per page.

7. **(MC)** What does `margin: 0 auto;` accomplish on an element with a set `max-width`?
 a) Removes all spacing
 b) Horizontally centers the element
 c) Vertically centers the element
 d) Adds a border

8. **(T/F)** Without `box-sizing: border-box`, setting `width: 300px` on an element with padding will make the element's total rendered width larger than 300px.

9. **(Short Answer)** Two developers both write `.title { color: red; }` and `<h1 style="color: blue;">`. Which color wins for that heading, and why?

10. **(MC)** What is the primary reason this series moved from an inline `<style>` block (Part 1) to an external `.css` file (Part 2)?
 a) External files load faster
 b) One external file can style unlimited pages, avoiding repetitive maintenance
 c) Inline styles are deprecated
 d) Browsers require external files for images to work

### Answer Key — Quiz 2
1. content, padding, border, margin
2. b
3. True
4. b (200px total minus 2×20px padding minus 2×5px border = 150px content width remains)
5. Example: padding is the foam cushioning inside a shipping box (between the box and its contents); margin is the gap of air left between two boxes stacked next to each other.
6. `#`; one
7. b
8. True — this is `content-box` behavior, the default without `border-box`.
9. Blue wins — inline styles have higher specificity than external/internal class-based (or in this case even tag-based) stylesheet rules.
10. b

---
---

# QUIZ 3 — Multi-Section Landing Page

1. **(Fill-in)** `<nav>` should be reserved specifically for __________________________________.

2. **(MC)** Which semantic tag represents a self-contained, thematic grouping of content, typically with its own heading?
 a) `<div>`
 b) `<section>`
 c) `<span>`
 d) `<aside>`

3. **(T/F)** `<section>` renders visually differently from a `<div>` by default.

4. **(Code Output)** Given `<a href="#pricing">` and `<section id="Pricing">`, will clicking the link scroll to the section?
 a) Yes b) No — IDs are case-sensitive and `pricing` ≠ `Pricing`

5. **(Short Answer)** Explain what specifically breaks if `max-width` and `margin: 0 auto` are applied directly to a full-width colored `<section>`, instead of to an inner wrapper `<div>`.

6. **(Fill-in)** IDs must be __________ per page, while classes can repeat any number of times.

7. **(MC)** Which tag should wrap the single primary content region of a page, and appear only once per page?
 a) `<header>`
 b) `<main>`
 c) `<section>`
 d) `<footer>`

8. **(T/F)** Semantic tags provide zero built-in visual styling of their own — you still write every CSS rule yourself.

9. **(Short Answer)** Give one concrete benefit of using `<footer>` instead of `<div class="footer">`, beyond just "it looks organized."

### Answer Key — Quiz 3
1. the site's primary navigation links
2. b
3. False — identical rendering by default; the difference is semantic meaning for machines/assistive tech.
4. b
5. The full-width background color gets constrained too, so it no longer stretches edge-to-edge — you lose the "full-bleed background, centered content" effect entirely.
6. unique
7. b
8. True
9. Screen readers and other assistive technology can recognize `<footer>` as a distinct landmark region, letting users jump directly to it; a generic `<div>` offers no such landmark regardless of its class name.

---
---

# QUIZ 4 — Flexbox Photo Gallery

1. **(Fill-in)** The parent element with `display: flex` is called the flex __________; its direct children automatically become flex __________.

2. **(MC)** Which property allows flex items to move onto a new line instead of shrinking or overflowing?
 a) `flex-direction`
 b) `flex-wrap`
 c) `justify-content`
 d) `gap`

3. **(T/F)** `justify-content` and `align-items` control the same axis regardless of `flex-direction`.

4. **(Code Output)** In `flex: 1 1 260px;`, what does the middle `1` represent?
 a) grow b) shrink c) basis d) gap

5. **(Short Answer)** A developer sets `display: flex` on `.gallery-card` instead of `.gallery`. What visibly happens, and why?

6. **(Fill-in)** The __________ axis is the primary direction items flow in; the __________ axis is perpendicular to it.

7. **(MC)** Which value of `justify-content` pins the first and last items to the edges, distributing leftover space between the rest?
 a) `center`
 b) `flex-start`
 c) `space-between`
 d) `stretch`

8. **(T/F)** Using `margin` on flex items instead of `gap` can require extra math to avoid uneven edge spacing.

### Answer Key — Quiz 4
1. container; items
2. b
3. False — they swap meaning when `flex-direction` changes from `row` to `column`.
4. b (grow, shrink, basis — order matters; middle value is shrink)
5. Nothing visibly changes to the *layout of the gallery's siblings* — `display: flex` only affects an element's own direct children, so applying it to `.gallery-card` only would affect anything nested inside each individual card, not how the cards themselves are arranged.
6. main; cross
7. c
8. True

---
---

# QUIZ 5 — Responsive Navbar (Positioning)

1. **(Fill-in)** `position: absolute` positions an element relative to its nearest ancestor with a position value other than __________.

2. **(MC)** Which position value removes an element from flow but anchors it to the browser viewport, ignoring scroll?
 a) `relative`
 b) `absolute`
 c) `fixed`
 d) `sticky`

3. **(T/F)** `position: relative` on an element with no `top`/`left` offset visually does nothing at all, and therefore serves no purpose.

4. **(Code Output)** Given:
```css
.parent { position: static; }
.child { position: absolute; top: 0; right: 0; }
```
Where does `.child` end up positioned?
 a) Top-right of `.parent`
 b) Top-right of the entire page/`<html>`
 c) It doesn't render
 d) Top-right of `<body>` only, never further

5. **(Short Answer)** Explain the mechanism of the checkbox-hack mobile menu using the terms `:checked` and the `~` combinator.

6. **(Fill-in)** The `~` symbol is called the __________ combinator, and only selects elements that appear __________ the reference element in the HTML.

7. **(MC)** Which position value behaves like `relative` until a scroll threshold, then behaves like `fixed`, bounded by its parent?
 a) `static`
 b) `absolute`
 c) `sticky`
 d) `fixed`

8. **(T/F)** A `fixed` navbar can require you to add compensating top padding to the content below it, since fixed elements are removed from normal document flow.

### Answer Key — Quiz 5
1. `static`
2. c
3. False — even with no offset, `position: relative` still establishes a positioning anchor for any absolutely-positioned children, which is its most important use in this series.
4. b (no ancestor has a non-static position, so it falls back to the whole page)
5. Clicking the label toggles the hidden checkbox's `:checked` state; the CSS rule `.checkbox:checked ~ .menu { ... }` uses the general sibling combinator to select the menu *only* when the checkbox (appearing earlier in the HTML) is currently checked, revealing it without any JavaScript.
6. general sibling; after
7. c
8. True

---
---

# QUIZ 6 — Grid Blog Layout

1. **(Fill-in)** The `fr` unit stands conceptually for "__________" — it divides available space proportionally.

2. **(MC)** For a grid with `grid-template-columns: 2fr 1fr;`, how many vertical grid lines exist?
 a) 2 b) 3 c) 4 d) 1

3. **(T/F)** `grid-column: 1 / 3` means "span exactly 3 columns."

4. **(Code Output)** What does `repeat(auto-fit, minmax(220px, 1fr))` achieve?
 a) A fixed 3-column grid
 b) A grid where columns are never narrower than 220px but grow to fill space, automatically adjusting column count
 c) A single-column grid on all screen sizes
 d) Requires a media query to work responsively

5. **(Short Answer)** Give one layout scenario where Grid is clearly the better tool over Flexbox, and explain why.

6. **(Fill-in)** In this series' blog layout, __________ was used for the overall page skeleton, while __________ was used for simple internal stacking inside individual post cards.

7. **(MC)** What genuinely happens if you add a redundant media query on top of an already-responsive `auto-fit`/`minmax()` grid?
 a) It breaks the layout
 b) It's simply unnecessary — the grid was already responsive without it
 c) It's required for cross-browser support
 d) It only works in old browsers

### Answer Key — Quiz 6
1. "fraction"
2. b (a 2-column grid always has exactly 3 grid lines)
3. False — it means "from grid line 1 to grid line 3," which spans 2 columns, not 3; line numbers are not the same as column counts.
4. b
5. Example: a layout needing a sidebar to span multiple rows alongside a featured post and a card grid simultaneously — Grid can place an item precisely across specific row/column lines in one declaration, which Flexbox cannot cleanly express.
6. Grid; Flexbox
7. b

---
---

# QUIZ 7 — Animated Product Card

1. **(Fill-in)** `transform` changes an element's appearance __________ affecting the layout flow of its neighbors.

2. **(MC)** Where must `transition` be declared for a hover effect to animate smoothly in both directions (entering and leaving hover)?
 a) Inside the `:hover` rule only
 b) On the element's base/normal state
 c) Inside a `@keyframes` block
 d) It doesn't matter where it's declared

3. **(T/F)** `transition` can animate between any number of defined steps, just like `@keyframes`.

4. **(Code Output)** 
```css
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
.el { animation: fadeIn 0.4s ease; }
```
After the animation completes, what state will `.el` be in?
 a) Stays at `opacity: 1`
 b) Snaps back to `opacity: 0` (the `from` state), since `forwards` is missing
 c) Stays at whatever it was mid-animation
 d) Errors out

5. **(Short Answer)** Give two of the four UX guidelines from this series for keeping animation tasteful rather than excessive.

6. **(Fill-in)** Animating `transform` and `opacity` is preferred over animating `width`/`top`/`left` because the latter can trigger expensive __________ recalculations, causing visible jank.

7. **(MC)** What does the media query `@media (prefers-reduced-motion: reduce)` accomplish?
 a) Speeds up all animations
 b) Respects a user's OS-level request to minimize motion, typically by disabling transitions/animations
 c) Disables CSS entirely
 d) Only applies on mobile devices

### Answer Key — Quiz 7
1. without
2. b
3. False — `transition` only animates between exactly two states (start/end); `@keyframes` supports any number of steps.
4. b
5. Any two of: motion should communicate interactivity/hierarchy, not just decorate; keep durations short (150–350ms); avoid animating too many elements/properties simultaneously; respect `prefers-reduced-motion`.
6. layout
7. b

---
---

# QUIZ 8 — Contact Form

1. **(Fill-in)** A `<label for="email">` is correctly linked to `<input id="email">` by matching these two values __________.

2. **(MC)** What does the `required` attribute do?
 a) Makes the field read-only
 b) Blocks form submission until the field has a value
 c) Automatically formats the input
 d) Hides the field until clicked

3. **(T/F)** `placeholder` text is an acceptable full substitute for a real `<label>`.

4. **(Code Output)**
```css
input:invalid { border-color: red; }
```
What visible problem occurs on page load, before the user types anything, for a `required` empty field?
 a) No problem — it stays neutral until interacted with
 b) The field immediately shows a red border, even though the user hasn't done anything wrong yet
 c) The page fails to load
 d) The browser throws a JavaScript error

5. **(Short Answer)** What CSS addition fixes the problem in question 4, and how does it work?

6. **(Fill-in)** The `~` sibling selector is used in this series' custom error message pattern to select `.error-message` only when it follows an __________ and __________ input.

7. **(MC)** Which HTTP method did this series' forms use, and why?
 a) `GET`, because it's simpler
 b) `POST`, because form data shouldn't be exposed in the URL
 c) `PUT`, because it updates a resource
 d) `DELETE`, because it clears the form

8. **(T/F)** CSS-only validation can fully replace JavaScript for cross-field validation, like confirming a password matches a "confirm password" field.

### Answer Key — Quiz 8
1. `for` and `id` (must match exactly)
2. b
3. False — placeholder text disappears once typing begins and isn't reliably announced by all assistive tech the same way; a real `<label>` is required for proper accessibility.
4. b
5. Add `:not(:placeholder-shown)` — e.g. `input:invalid:not(:placeholder-shown) { border-color: red; }` — so the rule only applies once the field actually has content, since a placeholder is only shown while a field is empty.
6. invalid; touched (i.e., `:invalid:not(:placeholder-shown)`)
7. b
8. False — CSS alone cannot compare two separate field values; that requires JavaScript.

---
---

# QUIZ 9 — Capstone Portfolio Site

1. **(Fill-in)** CSS custom properties declared inside `:root` are available __________ on the page.

2. **(MC)** What does `var(--color-primary)` do?
 a) Declares a new custom property
 b) Reads/reuses the value stored in that custom property
 c) Deletes a custom property
 d) Only works inside `:root`

3. **(T/F)** In the three-file CSS architecture used in this series, `components.css` is responsible for page-level structural patterns like the hero section's overall layout.

4. **(Short Answer)** Explain, mechanically, why changing one `--color-primary` value in `:root` can update the navbar, buttons, and card borders all at once.

5. **(Fill-in)** Since plain HTML/CSS has no built-in concept of "the current page," this series simulates it using a manually-added __________ class on the matching nav link.

6. **(MC)** Why do the Projects page's "View Project" links use relative paths like `../part-4-photo-gallery/index.html` instead of copying that project's code directly into the capstone folder?
 a) It's required by HTML syntax
 b) It reuses the actual, already-built, standalone project as a live linked demo, avoiding duplication
 c) Copying code is not allowed in HTML
 d) Relative paths are faster to load

7. **(T/F)** Deploying the capstone into its own separate GitHub repository can break the `../part-X` sibling-folder relative links, since the repository itself becomes a new "top of the tree."

8. **(Short Answer)** Match each capstone page to its originating Part(s): `about.html`, `contact.html`, `projects.html`'s grid pattern, the site-wide navbar, the card hover-lift animation.

### Answer Key — Quiz 9
1. everywhere / globally
2. b
3. False — that's `layout.css`'s job; `components.css` handles reusable UI pieces like buttons, cards, and forms.
4. Every element referencing `var(--color-primary)` (navbar, buttons, card borders, etc.) doesn't store its own independent color value — it looks up the current value of that one shared variable every time it's rendered, so updating the variable once updates every reference to it simultaneously.
5. `.active`
6. b
7. True
8. `about.html` ← Part 1; `contact.html` ← Part 8; `projects.html` grid ← Part 4 + Part 6; navbar ← Part 5; card hover animation ← Part 7

---
---

# QUIZ A — DevTools

1. **(Fill-in)** In the Styles pane, a rule shown with a __________ indicates it lost the CSS cascade to another rule.

2. **(MC)** What happens to a live-edited value made directly in DevTools' Styles pane after the page is refreshed?
 a) It's permanently saved to the file
 b) It reverts, since DevTools edits are never saved to disk
 c) It prompts a save dialog
 d) It causes an error

3. **(T/F)** The Network tab shows the HTTP status code for every file the page requested.

4. **(Short Answer)** What is the fastest way to identify exactly which element on a page corresponds to a specific line in the Elements tree, without clicking anything?

5. **(MC)** Which DevTools feature specifically lets you simulate a precise screen width, like exactly 768px, without manually resizing the browser window?
 a) The Console tab
 b) The device toolbar
 c) The Network tab
 d) The Elements tree

### Answer Key — Quiz A
1. strikethrough
2. b
3. True
4. Hover (without clicking) over a line in the Elements tree — the browser highlights the corresponding element directly on the page.
5. b

---
---

# QUIZ B — Glossary Skills Check

1. **(MC)** Which tag represents a self-contained piece of content that could reasonably be syndicated elsewhere on its own, like an RSS feed entry?
 a) `<div>`
 b) `<article>`
 c) `<aside>`
 d) `<span>`

2. **(Fill-in)** `object-fit: cover` makes an image __________ to fill its box neatly, rather than stretching or squashing it.

3. **(T/F)** `A > B` (child combinator) selects any `B` nested anywhere inside `A`, at any depth.

4. **(MC)** Which unit is relative to the root `<html>` element's font size?
 a) `px`
 b) `em`
 c) `rem`
 d) `vh`

### Answer Key — Quiz B
1. b
2. crop
3. False — `A > B` selects only *direct* children; `A B` (descendant combinator, no `>`) selects nested at any depth.
4. c

---
---

# QUIZ C — Debugging

1. **(Short Answer)** List, in order, the first three questions in this series' debugging decision tree.

2. **(MC)** A CSS file is linked but styles aren't applying anywhere on the page. What should you check first?
 a) Whether your images have `alt` text
 b) The Network tab, for a 404 status on the CSS file
 c) Whether you used classes instead of IDs
 d) Whether your HTML has a `<title>`

3. **(T/F)** File paths that work locally via Live Server are guaranteed to work identically once deployed to a real server.

4. **(Fill-in)** The most common root cause of "my CSS isn't applying at all" is a wrong __________ in the `<link>` tag.

### Answer Key — Quiz C
1. (1) Is the file even loading? (2) Is my selector matching the right element? (3) Is something else overriding my rule?
2. b
3. False — real servers are typically case-sensitive; local file systems are often forgiving about case, causing "works locally, breaks deployed" bugs.
4. path (`href` value)

---
---

# QUIZ D — Deployment

1. **(Fill-in)** `git init` turns the current folder into a __________-tracked project.

2. **(MC)** What does `git push -u origin main` actually do?
 a) Saves a local snapshot only
 b) Uploads your committed snapshots to the remote repository
 c) Deletes the remote repository
 d) Downloads files from GitHub

3. **(T/F)** GitHub Pages requires a paid account for a public repository.

4. **(Short Answer)** Why can moving a capstone project into its own isolated GitHub repository break links like `../part-4-photo-gallery/index.html`?

### Answer Key — Quiz D
1. Git
2. b
3. False — free for public repositories.
4. The repository becomes the new "top of the tree" once deployed — there is no folder "above" it to go up into via `../`, since the sibling project folders don't exist inside that same deployed repository unless explicitly included.

---
---

# QUIZ E — Where to Go Next

1. **(MC)** According to this series' recommended learning order, what should generally be learned before diving into React?
 a) A CSS preprocessor
 b) JavaScript fundamentals
 c) A build tool like Webpack
 d) Nothing — React should be learned first

2. **(T/F)** Learning React eliminates the need for solid HTML/CSS fundamentals.

3. **(Short Answer)** Name one free tool mentioned for auditing accessibility on a finished site.

### Answer Key — Quiz E
1. b
2. False — React generates HTML dynamically and still relies on CSS for styling; fundamentals transfer directly, they don't get replaced.
3. Lighthouse (built into Chrome DevTools) or the WAVE browser extension

---
---

# QUIZ P1 — How the Web Actually Works

1. **(Fill-in)** In the client-server model, the __________ requests data, and the __________ stores and provides it.

2. **(MC)** What does DNS do?
 a) Encrypts web traffic
 b) Translates human-readable domain names into IP addresses
 c) Compresses images
 d) Validates HTML syntax

3. **(T/F)** `127.0.0.1` always refers to a specific fixed computer somewhere on the internet.

4. **(Short Answer)** Why do web forms typically use `POST` instead of `GET`?

5. **(MC)** A `404` status code means:
 a) Success
 b) Server error
 c) The requested file was not found
 d) Redirection

### Answer Key — Quiz P1
1. client; server
2. b
3. False — it's a reserved "loopback" address always meaning "this same computer," regardless of which computer runs it.
4. So form data (which can be sensitive or lengthy) is sent in the request body rather than exposed directly in the URL, unlike `GET`.
5. c

---
---

# QUIZ P2 — Files, Folders, and Paths

1. **(Fill-in)** `../` in a path means "go __________ one folder level."

2. **(MC)** Why does this series avoid absolute paths in HTML `href`/`src` attributes?
 a) They're slower
 b) They only work on the specific computer/structure they were written on
 c) Browsers don't support them
 d) They require quotes

3. **(T/F)** File paths are compared as literal text, and are case-sensitive on most real web servers.

4. **(Short Answer)** Trace this path: a file at `projects/site-a/index.html` links to `href="../site-b/about.html"`. What is the fully resolved path?

### Answer Key — Quiz P2
1. up
2. b
3. True
4. `projects/site-b/about.html`

---
---

# QUIZ P3 — Reading Code Like a Sentence

1. **(Fill-in)** The four universal syntax patterns covered in this primer are: __________, __________, __________, and __________.

2. **(MC)** In `color: blue;`, which part is the "key" and which is the "value"?
 a) `color` is the value, `blue` is the key
 b) `color` is the key, `blue` is the value
 c) Both are keys
 d) Neither — this is a delimiter pair

3. **(T/F)** Browsers require correct indentation to properly parse nested HTML.

### Answer Key — Quiz P3
1. delimiters (opening/closing pairs); key-value pairs; nesting; comments
2. b
3. False — indentation is purely a human-readability convention; browsers don't require or even notice it.

---
---

# QUIZ P4 — Color, Units, and Measurement

1. **(Fill-in)** Every color displayed on a screen is fundamentally composed of three intensities: __________, __________, and __________.

2. **(MC)** `#2563eb` and `rgb(37, 99, 235)` represent:
 a) Two different colors
 b) The exact same color, in two different notations
 c) A gradient
 d) An invalid combination

3. **(T/F)** `rem` is generally preferred over `px` for font sizing because it scales when users adjust their browser's base font size, an accessibility benefit.

4. **(Short Answer)** What does the fourth value in `rgba(0, 0, 0, 0.15)` control?

### Answer Key — Quiz P4
1. red; green; blue
2. b
3. True
4. Alpha (transparency) — `0.15` means the color is mostly see-through, useful for soft shadows/glows.

---
---

# QUIZ P5 — Just Enough Command Line to Get By

1. **(Fill-in)** `pwd` stands for "__________" and answers the question "where am I currently standing?"

2. **(MC)** Which command moves your terminal's current location up one folder level?
 a) `ls`
 b) `cd ..`
 c) `pwd`
 d) `mkdir`

3. **(T/F)** `git add .` saves a permanent snapshot of your project.

4. **(Short Answer)** What does `git commit -m "message"` actually do, distinct from `git add .`?

### Answer Key — Quiz P5
1. print working directory
2. b
3. False — `git add .` only *stages* files for the next snapshot; `git commit` is what actually creates the permanent snapshot.
4. It takes the currently staged files and creates an actual permanent recorded snapshot ("commit") of their state, with a descriptive message attached.

---
---

# MASTER CUMULATIVE FINAL EXAM (25 Questions, Mixed Sections)

1. **(MC)** Which pairing correctly establishes a positioning anchor for an absolutely-positioned child? (Part 5)
 a) `parent { position: static }`
 b) `parent { position: relative }`
 c) `child { position: static }`
 d) No pairing is needed

2. **(Fill-in)** `flex: 1 1 260px` breaks down into __________, __________, and __________. (Part 4)

3. **(T/F)** `grid-column: 1 / 3` spans exactly 3 columns. (Part 6)

4. **(MC)** What must be true for `:invalid` styling to avoid flagging empty required fields on page load? (Part 8)
 a) Pair it with `:hover`
 b) Pair it with `:not(:placeholder-shown)`
 c) Remove `required` entirely
 d) Use `!important`

5. **(Short Answer)** Explain why `transition` must be declared on an element's base state, not its `:hover` state. (Part 7)

6. **(Fill-in)** CSS custom properties are typically declared inside the __________ selector. (Part 9)

7. **(MC)** What HTTP status code range indicates client errors, like a missing file? (Primer 1)
 a) 200–299
 b) 300–399
 c) 400–499
 d) 500–599

8. **(T/F)** Relative paths break when the entire project structure is moved together to a new computer, as long as internal relationships stay the same. (Primer 2)

9. **(Short Answer)** Name the four universal syntax patterns from Primer 3.

10. **(MC)** `#ffffff` in RGB notation is: (Primer 4)
 a) rgb(0,0,0)
 b) rgb(255,255,255)
 c) rgb(255,0,0)
 d) rgb(0,255,255)

11. **(Fill-in)** `git push -u origin main` __________ your local commits to the remote repository. (Primer 5)

12. **(MC)** In DevTools, a crossed-out CSS rule means: (Appendix A)
 a) It has a typo
 b) It lost the cascade to a more specific/later rule
 c) It's invalid CSS
 d) It's disabled by the browser

13. **(T/F)** `<section>` renders visually different from `<div>` by default. (Part 3)

14. **(Short Answer)** Why does `box-sizing: border-box` matter for predictable sizing? (Part 2)

15. **(MC)** Which value keeps an element's final animated state after `@keyframes` completes? (Part 7)
 a) `infinite`
 b) `forwards`
 c) `ease`
 d) `reverse`

16. **(Fill-in)** The main axis and cross axis __________ meaning when `flex-direction` changes from `row` to `column`. (Part 4)

17. **(MC)** Which is the correct fix for a mobile menu that won't toggle via the checkbox hack? (Part 5)
 a) Add more `<div>`s
 b) Confirm matching `for`/`id` values and correct HTML source order (checkbox before menu)
 c) Add `!important` to every rule
 d) Switch to `position: fixed`

18. **(T/F)** `required` alone, with no JavaScript, is enough to block a form's submission when empty. (Part 8)

19. **(Short Answer)** What does `auto-fit` + `minmax()` together achieve, without any media query? (Part 6)

20. **(Fill-in)** Every relative path is resolved starting from the location of the __________ file referencing it. (Primer 2)

21. **(MC)** Which appendix specifically covers the symptom → cause → fix debugging format? 
 a) Appendix A
 b) Appendix C
 c) Appendix D
 d) Appendix E

22. **(T/F)** React removes the need to understand CSS layout. (Appendix E)

23. **(Short Answer)** Why did the capstone (Part 9) use `var(--color-primary)` instead of hardcoding hex codes throughout every file?

24. **(MC)** Which unit is relative to the entire browser viewport, bypassing the parent chain entirely? (Primer 4)
 a) `%`
 b) `em`
 c) `vh`
 d) `rem`

25. **(Short Answer)** In one or two sentences, explain the overall architectural philosophy behind this series' progression from Part 1 to Part 9.

### Answer Key — Master Cumulative Final Exam
1. b
2. grow; shrink; basis
3. False — spans from line 1 to line 3, meaning 2 columns, not 3.
4. b
5. Because `transition` must apply during both *entering and leaving* the hover state; declaring it only inside `:hover` means the transition rule disappears the moment hover ends, causing an inconsistent snap on exit even if entry animates smoothly.
6. `:root`
7. c
8. True — relative paths survive relocation as long as the relationships between files (siblings, subfolders) remain unchanged.
9. Delimiters (open/close pairs); key-value pairs; nesting; comments
10. b
11. uploads
12. b
13. False
14. It makes `width`/`height` include padding and border in the total size, rather than adding them on top — producing predictable, easier-to-reason-about element dimensions.
15. b
16. swap
17. b
18. True
19. It creates a fully responsive column count (columns that reflow as the container resizes) with zero manually written breakpoints.
20. HTML (or CSS)
21. b
22. False — React still requires CSS for styling; it doesn't remove that need, it just relocates where the code lives.
23. So changing a single design token value in one place updates every element referencing that variable simultaneously, across every page, rather than requiring manual hex-code hunting and replacing across many files.
24. c
25. Each part introduces a small, focused new skill wrapped in a complete, real, standalone project; every project built earlier gets reused as a literal component of the final capstone, so nothing is ever a throwaway exercise — by Part 9, the reader is assembling and refining work they already deeply understand rather than learning anything brand new.

---

*End of Quiz Bank. For spaced-repetition practice, retake the Master Cumulative Final Exam roughly one week after completing the series, without reviewing notes beforehand.*
