# Build As You Learn: HTML & CSS from Zero to Portfolio
## The Official Lab Book

---

### How to Use This Lab Book

A workbook tests what you know. A **lab book** records what you *did* — in the same spirit as a science lab notebook. You write a prediction **before** you run your code, you log what actually happened, you record real numbers pulled from DevTools, and you keep a running troubleshooting log of every bug you hit and how you fixed it.

The discipline here matters more than it looks like it does: **predicting before verifying** is what separates someone who's memorizing syntax from someone who's building an actual mental model of how the browser behaves. If your prediction is wrong, that's not a failure — that's the most valuable line in the whole lab book, because it shows you exactly where your mental model needs correcting.

Fill this in with a pen, in real time, as you work through each Part. Don't fill it in afterward from memory.

**Every lab session follows the same six-part structure:**
1. **Setup** — what you need before starting
2. **Pre-Lab Prediction** — guess the outcome before you test it
3. **Procedure Log** — the actual build steps, with checkboxes and space to note deviations
4. **Observation & Measurement Table** — what you actually saw, including real DevTools numbers
5. **Anomaly & Debug Log** — every bug encountered, logged like a real incident report
6. **Lab Conclusion** — what you actually learned, in your own words

---
---

## LAB 0 — Environment Verification

**Date:** ______________ **Start Time:** ______________ **End Time:** ______________

**Objective:** Confirm the entire toolchain (editor, browser, live-reload) functions end-to-end before any real build begins.

### Setup
- [ ] VS Code installed
- [ ] Live Server extension installed
- [ ] `build-as-you-learn/` folder created
- [ ] `sanity-check.html` created inside it

### Pre-Lab Prediction
Before opening `sanity-check.html` with Live Server, predict: what will the browser tab title show, and what color will the paragraph text be?

Prediction: ___________________________________________________

### Procedure Log
- [ ] Wrote the sanity-check HTML skeleton with a blue-styled paragraph
- [ ] Opened the file with Live Server
- [ ] Changed `color: blue` to `color: red` in the saved file, without closing the browser
- [ ] Observed the browser's behavior without manually pressing refresh

### Observation & Measurement Table

| Check | Expected | Actual Observed | Match? (Y/N) |
|---|---|---|---|
| Browser tab title | "Sanity Check" | | |
| Initial paragraph color | Blue | | |
| Color after edit (no manual refresh) | Red, auto-updated | | |
| Time elapsed between save and visible change | < 2 sec | | |

### Anomaly & Debug Log

| Symptom | Suspected Cause | Fix Applied | Resolved? |
|---|---|---|---|
| | | | |
| | | | |

### Lab Conclusion
In your own words, what does "Live Server auto-refreshing" actually prove about how your editor, file system, and browser relate to each other?

_____________________________________________________________________

Confidence this toolchain works reliably going forward (1–5): ___

---
---

## LAB 1 — Personal Bio Card

**Date:** ______________ **Start Time:** ______________ **End Time:** ______________

**Objective:** Build a styled single-page bio card; observe the effect of CSS layered on top of unchanged HTML content.

### Setup
- [ ] `part-1-bio-card/` folder created with `index.html` and `images/profile.jpg`

### Pre-Lab Prediction
Before writing any CSS at all (just the bare HTML skeleton + heading + paragraph), predict what font, size, and color the heading will render in by default.

Prediction: ___________________________________________________

### Procedure Log
- [ ] Step 1: Built bare skeleton, verified browser tab title
- [ ] Step 2: Added `<h1>` name and intro `<p>`
- [ ] Step 3: Added `<img>` with `src` + `alt`
- [ ] Step 4: Added GitHub/LinkedIn links with `target="_blank"` + `rel="noopener noreferrer"`
- [ ] Step 5: Applied one inline `style=""` to the paragraph
- [ ] Step 6: Removed inline style, added a `<style>` block styling `body`, `h1`, `img`, `p`, `a`, `a:hover`
- [ ] Challenge: Added Fun Facts `<ul>` and styled `<blockquote>`

### Observation & Measurement Table

| Element | Property Checked | Expected Value | Actual Observed |
|---|---|---|---|
| Default `<h1>` (before any CSS) | Font/size/weight | Browser default (large, bold, serif or sans) | |
| `<img>` after CSS | Rendered shape | Perfect circle | |
| `<img>` after CSS | Border color | Matches `h1` blue | |
| Link, mouse NOT hovering | `text-decoration` | none | |
| Link, mouse hovering | `text-decoration` | underline | |
| Body content | Horizontal position | Centered via `margin: 0 auto` | |

### Anomaly & Debug Log

| Symptom | Suspected Cause | Fix Applied | Resolved? |
|---|---|---|---|
| | | | |
| | | | |
| | | | |

### Lab Conclusion
Describe, using your own actual before/after observations above, the exact moment the page went from "plain browser defaults" to "intentionally styled." What single change had the biggest visual impact?

_____________________________________________________________________

Confidence I could rebuild this unaided (1–5): ___

---
---

## LAB 2 — Recipe Page

**Date:** ______________ **Start Time:** ______________ **End Time:** ______________

**Objective:** Verify external CSS reusability and directly measure box-model spacing using DevTools.

### Setup
- [ ] `part-2-recipe-page/` with `index.html`, `style.css`, `images/`

### Pre-Lab Prediction
Before linking `style.css`, predict: will the "wall of text" starting page have any visual spacing between the ingredients list items and the instructions list at all?

Prediction: ___________________________________________________

### Procedure Log
- [ ] Built unstyled "wall of text" version first
- [ ] Created `style.css`, linked with `<link rel="stylesheet">`, confirmed light-yellow test background applied
- [ ] Refactored HTML to use classes (`.recipe-card`, `.recipe-title`, etc.)
- [ ] Applied global reset + `box-sizing: border-box`
- [ ] Styled box model on `.recipe-card` (padding, border, shadow, `margin: 0 auto`)
- [ ] Built typography hierarchy (title, description, section headings)
- [ ] Styled ingredient/instruction lists
- [ ] Built second recipe page (`recipe-2.html`) reusing the same CSS with zero new rules

### Observation & Measurement Table
*Use DevTools (Appendix A) → click `.recipe-card` → read the box model diagram → record actual pixel numbers:*

| Box Model Layer | Value Set in CSS | Actual Value Shown in DevTools |
|---|---|---|
| Padding (all sides) | 32px | |
| Border width | 1px | |
| Margin (left/right) | auto | |
| Total rendered width of `.recipe-card` | max 640px | |

| Test | Result |
|---|---|
| Did `recipe-2.html` render fully styled using zero new CSS? (Y/N) | |
| Number of new CSS rules written for `recipe-2.html` | |

### Anomaly & Debug Log

| Symptom | Suspected Cause | Fix Applied | Resolved? |
|---|---|---|---|
| | | | |
| | | | |
| | | | |

### Lab Conclusion
Based on your own DevTools measurements above, explain in your own words why the "total rendered width" matched (or didn't match) your expectation, given `box-sizing: border-box`.

_____________________________________________________________________

Confidence I understand padding vs. margin without re-reading the analogy (1–5): ___

---
---

## LAB 3 — Multi-Section Landing Page

**Date:** ______________ **Start Time:** ______________ **End Time:** ______________

**Objective:** Verify semantic structure renders correctly and fragment links (`#id`) navigate accurately.

### Setup
- [ ] `part-3-landing-page/` with `index.html`, `css/style.css`

### Pre-Lab Prediction
Before adding `id` attributes to any section, predict: what will happen when you click a `<nav>` link pointing to `#about` if no element on the page has `id="about"` yet?

Prediction: ___________________________________________________

### Procedure Log
- [ ] Built semantic skeleton: `<header>`, `<nav>`, hero `<section>`, about `<section id="about">`, features `<section id="features">`, `<footer id="contact">`
- [ ] Tested each nav link's scroll behavior
- [ ] Applied content-wrap pattern (`.content-wrap`/`.container` + section background/padding)
- [ ] Built hero, about, and feature-card sections
- [ ] Added Testimonials section (challenge)
- [ ] Updated hero CTA to link to `../part-1-bio-card/index.html`

### Observation & Measurement Table

| Nav Link Clicked | Target ID | Scrolled Correctly? (Y/N) |
|---|---|---|
| About | `#about` | |
| Features | `#features` | |
| Contact | `#contact` | |

| Test | Expected | Actual |
|---|---|---|
| Hero CTA click destination | Part 1 bio card page loads | |
| Browser window resized narrow | Feature cards wrap to new line | |

### Anomaly & Debug Log

| Symptom | Suspected Cause | Fix Applied | Resolved? |
|---|---|---|---|
| | | | |
| | | | |

### Lab Conclusion
Using Appendix A's Elements panel, inspect one `<section>` and one `<div>` on this page. Record one real, concrete difference (if any) in how they render vs. how they're announced to assistive tech (you can reason about this even without a screen reader, based on the tags themselves).

_____________________________________________________________________

Confidence I can decide `<section>` vs `<div>` instantly (1–5): ___

---
---

## LAB 4 — Flexbox Photo Gallery

**Date:** ______________ **Start Time:** ______________ **End Time:** ______________

**Objective:** Directly observe the Flexbox "snap" and measure exact wrapping breakpoints.

### Setup
- [ ] `part-4-photo-gallery/` with `index.html`, `css/style.css`, six images

### Pre-Lab Prediction
Before adding `display: flex` to `.gallery`, predict how the six cards will be arranged (stacked? side by side? overlapping?).

Prediction: ___________________________________________________

### Procedure Log
- [ ] Built unstyled vertical stack (confirmed "before" state)
- [ ] Added `display: flex` to `.gallery` — observed the "snap"
- [ ] Added `flex-wrap: wrap` + `gap: 20px`
- [ ] Experimented with `justify-content`/`align-items` values
- [ ] Built `.featured` card with combined class
- [ ] Built "Gallery, Stacked" `flex-direction: column` challenge

### Observation & Measurement Table

| Step | Layout Observed |
|---|---|
| Before `display: flex` | |
| Immediately after `display: flex` (no wrap yet) | |
| After adding `flex-wrap: wrap` | |

*Use the browser's device toolbar (Appendix A.5). Slowly narrow the width and record the exact pixel width where the gallery drops from N columns to N-1:*

| Column Count | Width Range Observed (px) |
|---|---|
| 3 → 2 columns | narrower than _______ px |
| 2 → 1 column | narrower than _______ px |

### Anomaly & Debug Log

| Symptom | Suspected Cause | Fix Applied | Resolved? |
|---|---|---|---|
| | | | |
| | | | |

### Lab Conclusion
Compare your predicted layout (before CSS) against the "snap" you actually observed. What surprised you most?

_____________________________________________________________________

Confidence in `flex: grow shrink basis` math (1–5): ___

---
---

## LAB 5 — Responsive Navbar (Positioning)

**Date:** ______________ **Start Time:** ______________ **End Time:** ______________

**Objective:** Directly witness the `absolute` "escape" bug and its `relative` fix; verify the mobile checkbox-hack menu.

### Setup
- [ ] `part-5-navbar/` with `index.html`, `css/style.css`

### Pre-Lab Prediction
Before adding `position: relative` to `.navbar-logo`, predict exactly where the "New" badge (`position: absolute; top: 0; right: 0;`) will visually appear on the page.

Prediction: ___________________________________________________

### Procedure Log
- [ ] Tested `static` (default) behavior
- [ ] Tested `relative` + offset on the logo (temporary experiment)
- [ ] Added absolute badge WITHOUT `relative` on parent — observed escape
- [ ] Added `position: relative` to `.navbar-logo` — observed fix
- [ ] Made navbar `position: fixed`, added compensating top padding
- [ ] Tested `position: sticky` on a secondary subheading
- [ ] Built full checkbox-hack mobile menu with media query
- [ ] Integrated navbar into Part 3 and Part 2 pages

### Observation & Measurement Table

| Test | Predicted Location | Actual Location Observed |
|---|---|---|
| Badge with NO relative parent | | |
| Badge WITH relative parent (`.navbar-logo`) | Top-right corner of logo | |

| Scroll Test | Expected Behavior | Observed |
|---|---|---|
| Scrolling with `position: fixed` navbar | Navbar stays glued to top | |
| Scrolling past `.sticky-subheading` | Sticks at `top: 90px`, then scrolls away with parent boundary | |

| Mobile Menu Test | Expected | Observed |
|---|---|---|
| Click hamburger icon (checkbox unchecked → checked) | Menu expands | |
| Click again (checked → unchecked) | Menu collapses | |
| Resize above 768px | Hamburger icon disappears, horizontal links return | |

### Anomaly & Debug Log

| Symptom | Suspected Cause | Fix Applied | Resolved? |
|---|---|---|---|
| | | | |
| | | | |
| | | | |

### Lab Conclusion
Write, in your own words, the exact rule for where an `absolute`-positioned element anchors itself, based on what you directly observed in this lab (not from memory of the text).

_____________________________________________________________________

Confidence distinguishing all 5 `position` values without a reference table (1–5): ___

---
---

## LAB 6 — Grid Blog Layout

**Date:** ______________ **Start Time:** ______________ **End Time:** ______________

**Objective:** Compare Flexbox-only vs. Grid-based layout attempts directly; measure grid line placement.

### Setup
- [ ] `part-6-blog-layout/` with `index.html`, `css/style.css`, images

### Pre-Lab Prediction
Before writing any Grid CSS, attempt the sidebar+main layout using only Flexbox (Step 1's experiment). Predict: will you be able to make the sidebar span the full height of both the featured post AND the grid below it, using Flexbox alone?

Prediction: ___________________________________________________

### Procedure Log
- [ ] Attempted Flexbox-only experiment, recorded friction points
- [ ] Built full semantic HTML (featured post, `<aside>` sidebar, post-grid articles)
- [ ] Defined outer grid: `grid-template-columns: 2fr 1fr`
- [ ] Placed featured/sidebar/grid regions with `grid-column`/`grid-row`
- [ ] Nested responsive `repeat(auto-fit, minmax())` grid inside `.post-grid`
- [ ] Styled featured post + sidebar content
- [ ] Linked one post card to Part 2 recipe page

### Observation & Measurement Table

| Question | Answer |
|---|---|
| Could Flexbox alone make the sidebar span both rows cleanly? (Y/N) | |
| Number of grid columns defined in `.blog-layout` | |
| Number of grid columns defined in nested `.post-grid` | |

*Use DevTools' Elements panel — many browsers show a "grid" badge on active grid containers, and clicking it overlays the actual grid lines directly on the page:*

| Grid Line Check | Observed Line Position (px from left) |
|---|---|
| Line 1 | |
| Line 2 | |
| Line 3 | |

### Anomaly & Debug Log

| Symptom | Suspected Cause | Fix Applied | Resolved? |
|---|---|---|---|
| | | | |
| | | | |

### Lab Conclusion
Based on your Flexbox-only attempt vs. your Grid-based result, write your own one-sentence rule for choosing between them.

_____________________________________________________________________

Confidence reading `grid-column: 1 / 3` correctly on first glance (1–5): ___

---
---

## LAB 7 — Animated Product Card

**Date:** ______________ **Start Time:** ______________ **End Time:** ______________

**Objective:** Directly compare an un-transitioned vs. transitioned hover effect; measure animation timing.

### Setup
- [ ] `part-7-product-card/` with `index.html`, `css/style.css`, `images/product.jpg`

### Pre-Lab Prediction
Before adding `transition` to `.product-card`, predict: will the `translateY(-8px)` hover effect look smooth or instant?

Prediction: ___________________________________________________

### Procedure Log
- [ ] Built static card, confirmed hover does nothing
- [ ] Added `transform: translateY(-8px)` on `:hover` only — observed instant snap
- [ ] Added `transition` on the BASE state — observed smooth glide
- [ ] Added animated `box-shadow` alongside transform
- [ ] Added button `scale()` hover + `:active` press feedback
- [ ] Built `@keyframes fadeSlideIn` badge animation with `forwards`
- [ ] Applied same pattern to Part 4 gallery cards and Part 6 blog cards

### Observation & Measurement Table

| Test | Predicted Feel | Actual Observed Feel |
|---|---|---|
| Hover, before `transition` added | | |
| Hover, after `transition` added | | |

| Element | Transition Duration Set | Felt Too Fast / Too Slow / Just Right |
|---|---|---|
| Card lift | 0.25s | |
| Button color | 0.2s | |
| Badge fade-in | 0.4s | |

| Reduced Motion Test | Expected | Observed |
|---|---|---|
| OS "reduce motion" enabled + refresh | No hover animation plays | |

### Anomaly & Debug Log

| Symptom | Suspected Cause | Fix Applied | Resolved? |
|---|---|---|---|
| | | | |
| | | | |

### Lab Conclusion
Describe the exact felt difference between the "snap" (Step 2) and the "glide" (Step 3), using your own words rather than the tutorial's.

_____________________________________________________________________

Confidence explaining why `transform`/`opacity` are safer to animate than `width`/`top` (1–5): ___

---
---

## LAB 8 — Contact Form

**Date:** ______________ **Start Time:** ______________ **End Time:** ______________

**Objective:** Verify native browser form validation behavior with real invalid/valid input tests.

### Setup
- [ ] `part-8-contact-form/` with `index.html`, `css/style.css`

### Pre-Lab Prediction
Before adding `required` to any field, predict: what happens when you click Submit on a completely empty form?

Prediction: ___________________________________________________

### Procedure Log
- [ ] Built bare `<form>` skeleton, confirmed submit button clickable
- [ ] Added Name/Email/Message with correctly paired `<label for>`/`<input id>`
- [ ] Tested native validation blocking on empty required fields
- [ ] Styled `:focus` ring
- [ ] Styled `:valid`/`:invalid` with `:not(:placeholder-shown)` guard
- [ ] Added custom `.error-message` via `~` sibling selector
- [ ] Added `<select>` Subject dropdown with disabled placeholder
- [ ] Built newsletter signup variant reusing shared classes

### Observation & Measurement Table

| Test Input | Field | Expected Behavior | Actual Observed |
|---|---|---|---|
| (empty) | Name | Submission blocked, native tooltip shown | |
| `not-an-email` | Email | Red border + custom error message shown | |
| `test@example.com` | Email | Green border, error message hidden | |
| Click label text "Name" directly | Name | Cursor jumps into input | |
| Tab key only, no mouse | All fields | Visible focus ring follows tab order | |
| Leave Subject on placeholder | Subject | Submission blocked | |

### Anomaly & Debug Log

| Symptom | Suspected Cause | Fix Applied | Resolved? |
|---|---|---|---|
| | | | |
| | | | |
| | | | |

### Lab Conclusion
Based on your own test inputs above, list one thing this form correctly validated with zero JavaScript, and one thing you suspect it could NOT validate without JavaScript.

_____________________________________________________________________

Confidence in the `:invalid:not(:placeholder-shown)` pattern (1–5): ___

---
---

## LAB 9 — Capstone Portfolio Site

**Date:** ______________ **Start Time:** ______________ **End Time:** ______________

**Objective:** Verify the design-token system by directly measuring the one-line brand color change across all five pages.

### Setup
- [ ] `my-portfolio/` with all 5 HTML files, `css/style.css`, `css/layout.css`, `css/components.css`, consolidated `images/`

### Pre-Lab Prediction
Before changing `--color-primary` in `:root`, predict: how many separate CSS rules would you have needed to edit, by hand, to achieve the same site-wide color change WITHOUT custom properties?

Prediction: ___________________________________________________

### Procedure Log
- [ ] Built `:root` design tokens in `style.css`
- [ ] Built shared navbar/footer once
- [ ] Built `layout.css` (container, hero, grid patterns)
- [ ] Built `components.css` (buttons, cards, forms, badges)
- [ ] Built `index.html`, `about.html`, `projects.html`, `contact.html`, `recipe.html`
- [ ] Changed `--color-primary` from blue to green, saved once
- [ ] Refreshed and checked all 5 pages
- [ ] Ran full production polish checklist

### Observation & Measurement Table

| Page | Elements That Changed Color After the One-Line Edit |
|---|---|
| `index.html` | |
| `about.html` | |
| `projects.html` | |
| `contact.html` | |
| `recipe.html` | |

| Polish Checklist Item | Pass/Fail |
|---|---|
| Navbar collapses to hamburger at 375px, all pages | |
| Text contrast comfortable on every page | |
| Full keyboard tab-through works, visible focus everywhere | |
| `.active` nav class correct on every page | |
| `<title>` + `<meta description>` present on every page | |
| Reduced-motion setting respected | |

### Anomaly & Debug Log

| Symptom | Suspected Cause | Fix Applied | Resolved? |
|---|---|---|---|
| | | | |
| | | | |
| | | | |

### Lab Conclusion
Compare your prediction (how many manual edits it would've taken) against reality (one line, one file). Write two sentences on why this matters for real, larger projects beyond this portfolio.

_____________________________________________________________________

Confidence I could explain this entire architecture to another beginner from memory (1–5): ___

---
---

## LAB A — DevTools Practicum

**Date:** ______________ **Start Time:** ______________ **End Time:** ______________

**Objective:** Build direct, hands-on fluency with the Elements, Styles, Console, and Network panels using a real project as the test subject.

### Setup
- [ ] Any completed project open in a browser (recommend Part 6 or Part 9)

### Pre-Lab Prediction
Before opening the Console tab, predict: will there be any red errors currently showing on a working, correctly-built page?

Prediction: ___________________________________________________

### Procedure Log
- [ ] Opened DevTools via right-click → Inspect
- [ ] Hovered elements in the tree, confirmed live highlight on page
- [ ] Clicked an element, found its rule + file/line in the Styles pane
- [ ] Live-edited a value in the Styles pane, confirmed it reverted on refresh
- [ ] Read the box model diagram for one element, recorded real numbers
- [ ] Opened device toolbar, tested 3 different widths
- [ ] Deliberately broke an image path, confirmed the red Console error
- [ ] Checked Network tab, confirmed status codes for CSS/image files

### Observation & Measurement Table

| Task | Result |
|---|---|
| Live-edited value reverted after refresh? (Y/N) | |
| Box model — padding (px) | |
| Box model — margin (px) | |
| Box model — border (px) | |
| Console error text after breaking an image path (copy exact text) | |
| Network status code for `style.css` | |
| Network status code for deliberately-broken image | |

### Anomaly & Debug Log

| Symptom | Suspected Cause | Fix Applied | Resolved? |
|---|---|---|---|
| | | | |

### Lab Conclusion
Write the exact Console error text you triggered, and explain in one sentence what it told you that simply looking at the broken page could not.

_____________________________________________________________________

Confidence using DevTools as my default first debugging step (1–5): ___

---
---

## LAB D — Deployment Practicum

**Date:** ______________ **Start Time:** ______________ **End Time:** ______________

**Objective:** Deploy the capstone to a live public URL and verify it end-to-end.

### Setup
- [ ] GitHub account created
- [ ] Git installed, confirmed via `git --version`
- [ ] `my-portfolio/` folder ready

### Pre-Lab Prediction
Before running `git push`, predict roughly how long it will take (in minutes) from finishing the push to seeing your live GitHub Pages URL actually work.

Prediction: ___________________________________________________

### Procedure Log
- [ ] Created empty `my-portfolio` repository on GitHub
- [ ] Ran `git init`, `git add .`, `git commit -m "..."`
- [ ] Ran `git branch -M main`, `git remote add origin ...`, `git push -u origin main`
- [ ] Enabled GitHub Pages in repo Settings
- [ ] Opened the live URL and clicked through all 5 pages
- [ ] Identified and fixed any broken cross-project relative links

### Observation & Measurement Table

| Command | Ran Successfully? (Y/N) | Notes/Errors |
|---|---|---|
| `git init` | | |
| `git add .` | | |
| `git commit -m "..."` | | |
| `git push -u origin main` | | |

| Verification | Result |
|---|---|
| Live URL loads home page | |
| Actual time elapsed until Pages went live (minutes) | |
| About/Projects/Contact/Recipe pages all load correctly | |
| "View Project" links to other Parts resolve correctly (Y/N — note fix used if N) | |

### Anomaly & Debug Log

| Symptom | Suspected Cause | Fix Applied | Resolved? |
|---|---|---|---|
| | | | |
| | | | |

### Lab Conclusion
Compare your predicted deploy time against the actual measured time. Write one sentence on what `git push` actually did, in your own words, using Primer 5's explanation as a starting point but phrased your own way.

_____________________________________________________________________

Confidence I could deploy a brand-new project unaided (1–5): ___

---
---

## END-OF-SERIES LAB SUMMARY

Tally your confidence ratings from every lab session above:

| Lab | Confidence Rating (1–5) |
|---|---|
| Lab 0 | ___ |
| Lab 1 | ___ |
| Lab 2 | ___ |
| Lab 3 | ___ |
| Lab 4 | ___ |
| Lab 5 | ___ |
| Lab 6 | ___ |
| Lab 7 | ___ |
| Lab 8 | ___ |
| Lab 9 | ___ |
| Lab A | ___ |
| Lab D | ___ |
| **Total** | ___ / 60 |

**Total Anomalies Logged Across All Labs:** ___ *(count every row you filled in across every Anomaly & Debug Log — a high count is not a bad sign; it's a record of real debugging reps, which is exactly how this skill is actually built)*

**Lowest-confidence lab, and why:** _____________________________________________________________________

**Plan to revisit it:** _____________________________________________________________________

---

*End of Lab Book. Every prediction, measurement, and anomaly recorded here is real evidence of your own hands-on experimentation — keep this document; it's a far more honest record of what you actually learned than any finished screenshot could be.*
