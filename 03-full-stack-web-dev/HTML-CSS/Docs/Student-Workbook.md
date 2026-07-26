# Build As You Learn: HTML & CSS from Zero to Portfolio
## The Official Student Workbook

---

### How to Use This Workbook

This workbook is your companion to the full tutorial series — it does not replace it. Keep it open **next to** the series, not instead of it. For every Part, Appendix, and Primer, you'll find:

- **Learning Objectives** — a checklist to mark off as you go, so progress feels visible.
- **Key Vocabulary** — fill-in-the-blank definitions, in your own words, using the series' analogies as a starting point.
- **Concept Check Questions** — short answer and multiple choice, testing understanding, not memorization.
- **Code Tracing Exercises** — you read code and predict what happens *before* running it. This is the single best habit for becoming a confident developer.
- **Debug It!** — a broken snippet from that Part's project. Find the bug, explain it, fix it.
- **Hands-On Build Checklist** — a condensed checklist mirroring that Part's actual steps, for you to tick off in your own project folder.
- **Self-Assessment** — a short rubric to rate your own confidence honestly before moving on.
- **Reflection Prompt** — one open-ended question connecting the new skill to something you already know.

Answers to Concept Check and Debug It! exercises are collected in the **Answer Key** at the very end of this workbook. Resist the urge to check early — struggling productively with a wrong answer teaches you more than reading a right one.

Grab a pencil. Let's begin.

---
---

# PART 0 WORKBOOK — Introduction

### Learning Objectives
- [ ] I can explain, in one sentence, what HTML does versus what CSS does.
- [ ] I have VS Code, a browser, and Live Server installed and working.
- [ ] I successfully completed the sanity-check exercise and saw a live-reload happen.
- [ ] I can describe the final capstone's folder structure from memory, roughly.

### Key Vocabulary — Fill in the Blank
1. A **code editor** is a smarter version of ______________ that understands code well enough to color it and auto-complete it.
2. **Syntax highlighting** means ______________________________________________.
3. **Live Server** solves the problem of having to ______________ every time you make a change.
4. The **feedback loop** this series relies on is: edit → ______________ → ______________ → look.

### Concept Check
1. True or False: HTML requires you to understand logic, branching, and math the way "real programming" does.
2. In your own words (2–3 sentences), why does the series insist you build a full page every single part, instead of isolated exercises?
3. What is the very first proof, mentioned in Part 0, that your entire environment works end-to-end?

### Hands-On Build Checklist
- [ ] Installed VS Code
- [ ] Installed the Live Server extension
- [ ] Created the `build-as-you-learn` folder
- [ ] Created and ran `sanity-check.html`
- [ ] Watched the color change from blue to red live, without manually refreshing

### Self-Assessment
Rate 1 (not at all) to 5 (very confident): I understand what will be built by the end of this series and roughly how each part contributes to it. ___ / 5

### Reflection Prompt
Think of something else you've learned by building small, complete things first (cooking, an instrument, a sport). How is that similar to this series' teaching approach?

---
---

# PART 1 WORKBOOK — Your First Web Page (Personal Bio Card)

### Learning Objectives
- [ ] I can name the four core parts of an HTML skeleton and what each is for.
- [ ] I can write a heading, paragraph, image, and link from memory.
- [ ] I understand the difference between inline styles and a `<style>` block.
- [ ] I can explain why `alt` text matters, beyond "it's required."

### Key Vocabulary — Fill in the Blank
1. `<!DOCTYPE html>` tells the browser to ____________________________________.
2. The `<head>` contains information ________ the page, while the `<body>` contains everything a visitor _______________.
3. `<img>` is called a ________________ tag because it has no separate closing tag.
4. A CSS **selector** answers the question "________________?" and the declaration block answers "________________?"

### Concept Check
1. Why should a page generally only have one `<h1>`?
2. What are the two required pieces of information an `<img>` tag needs at minimum?
3. What problem does moving CSS from an inline `style=""` attribute into a `<style>` block in `<head>` actually solve?
4. Multiple choice: Which of these correctly opens a link in a new tab safely?
   - a) `<a href="site.com" newtab="true">`
   - b) `<a href="https://site.com" target="_blank" rel="noopener noreferrer">`
   - c) `<a src="https://site.com" blank>`

### Code Tracing Exercise
Predict what will visually appear when this renders, **before** running it:

```html
<h1>Hello</h1>
<p style="color: red;">One</p>
<p>Two</p>
<style>
  p { color: blue; }
</style>
```

Your prediction: What color is "One"? _______ What color is "Two"? _______ Why do they differ, given that the `<style>` block appears *after* the paragraphs in the file?

### Debug It!
This code is supposed to show a photo followed by a caption paragraph. It's broken. Find and fix the bug(s).

```html
<div>
  <img src="images/profile.jpg">
  <p>My photo<p>
</div>
```

Bug(s) found: _________________________________________________

Fixed version:
```html



```

### Hands-On Build Checklist
- [ ] Created `part-1-bio-card/` with `index.html` and `images/profile.jpg`
- [ ] Built the bare HTML skeleton and confirmed the browser tab title
- [ ] Added heading + intro paragraph
- [ ] Added photo with proper `alt` text
- [ ] Added GitHub/LinkedIn links with `target="_blank"` and `rel="noopener noreferrer"`
- [ ] Applied one inline style, then removed it in favor of a `<style>` block
- [ ] Completed the Fun Facts list + styled blockquote challenge

### Self-Assessment
I could rebuild this bio card from a blank file, without looking at the tutorial: ___ / 5

### Reflection Prompt
Where else in life do you see the same "structure vs. appearance" separation that HTML and CSS represent (e.g., a document's content vs. its formatting template)?

---
---

# PART 2 WORKBOOK — Style It Up (Recipe Page)

### Learning Objectives
- [ ] I can link an external CSS file correctly using `<link>`.
- [ ] I can explain the box model in my own words, without looking it up.
- [ ] I know when to use a class selector versus an ID selector.
- [ ] I understand what `box-sizing: border-box` actually fixes.

### Key Vocabulary — Fill in the Blank
1. The four layers of the box model, from innermost to outermost: ________, ________, ________, ________.
2. A class selector is written as ________ in CSS and ________ in HTML.
3. An ID is meant to be used ________ time(s) per page, while a class can be used ________ times.
4. `margin` affects the relationship between an element and its ________, while `padding` affects the relationship between an element and its own ________.

### Concept Check
1. What specifically breaks (or doesn't work as expected) if you forget `rel="stylesheet"` on a `<link>` tag?
2. Why is `box-sizing: border-box` considered close to a professional default, rather than optional polish?
3. Give one real example of when you'd choose an ID over a class, and explain why.

### Code Tracing Exercise
Given this CSS:
```css
* { box-sizing: border-box; }
.box {
  width: 200px;
  padding: 20px;
  border: 5px solid black;
}
```
What is the actual rendered width of `.box`'s content area? _______px
(Hint: with `border-box`, the 200px includes padding and border — subtract them out to find what's left for content.)

Now, if `box-sizing` were `content-box` instead, what would the *total visible width* of the box be? _______px

### Debug It!
This CSS is supposed to style every ingredient list on the page, but nothing is happening. Find the bug.

```html
<ul class="ingredients">
  <li>Flour</li>
</ul>
```
```css
ingredients {
  list-style-type: square;
}
```

Bug found: _________________________________________________

Fixed CSS:
```css

```

### Hands-On Build Checklist
- [ ] Built the unstyled "wall of text" recipe page first
- [ ] Created `style.css` and linked it via `<link rel="stylesheet">`
- [ ] Refactored tag selectors into class selectors (`.recipe-card`, `.recipe-title`, etc.)
- [ ] Applied `* { box-sizing: border-box; }` globally
- [ ] Styled the box model on `.recipe-card` (padding, border, shadow, centered via `margin: 0 auto`)
- [ ] Built typography hierarchy across title, description, and section headings
- [ ] Created a second recipe page reusing the same `style.css` with zero new CSS

### Self-Assessment
I can explain to someone else why padding and margin look/behave differently, using an analogy: ___ / 5

### Reflection Prompt
Describe, in your own words, the exact moment in this Part where you *felt* the difference between padding and margin, rather than just reading about it.

---
---

# PART 3 WORKBOOK — Get Organized (Multi-Section Landing Page)

### Learning Objectives
- [ ] I can list the four core semantic HTML5 tags and what each communicates.
- [ ] I understand why semantic tags matter for accessibility and SEO, concretely.
- [ ] I can build the "content-wrap" pattern (full-width background + centered constrained content) from memory.
- [ ] I understand how fragment links (`#id`) work.

### Key Vocabulary — Fill in the Blank
1. `<nav>` should be reserved specifically for ________________________________.
2. A `<section>` is appropriate when a chunk of content represents its own ________________, usually with a heading — otherwise, a plain `<div>` is the honest choice.
3. In `<a href="#about">`, the `#about` portion means: "search the current page for an element with ________________ and scroll to it."
4. The content-wrap pattern uses `max-width` on the ________ content, while the full-width background color lives on the ________ wrapping it.

### Concept Check
1. Functionally, does a `<section>` render any differently than a `<div>` with the same CSS applied? What's the actual difference then?
2. Why must an element's `id` be unique per page, but a `class` doesn't have that restriction?
3. What specifically goes wrong if you apply `max-width` directly to a full-width colored section, instead of to an inner wrapper `<div>`?

### Code Tracing Exercise
```html
<nav>
  <a href="#pricing">Pricing</a>
</nav>
<section id="Pricing">
  <h2>Our Prices</h2>
</section>
```
Will clicking the "Pricing" link successfully scroll to the section? _______ Why or why not?

### Debug It!
```css
.hero-section {
  max-width: 1000px;
  margin: 0 auto;
  background-color: navy;
  padding: 100px 0;
}
```
The developer wanted a full-width navy background with only the *inner text* constrained to 1000px. Instead, the entire navy block itself is only 1000px wide, floating in the middle of the page. Explain the bug and rewrite the CSS/HTML correctly.

Explanation: _________________________________________________

Fixed approach:
```css


```

### Hands-On Build Checklist
- [ ] Built the semantic skeleton: `<header>`, `<nav>`, hero `<section>`, about `<section>`, features `<section>`, `<footer>`
- [ ] Verified nav fragment links scroll correctly to matching IDs
- [ ] Applied the content-wrap pattern across every section
- [ ] Built the feature-card row using an early preview of Flexbox
- [ ] Added the Testimonials section (end-of-part challenge)
- [ ] Linked the hero CTA button to the Part 1 bio card using a relative `../` path

### Self-Assessment
I can decide, without hesitation, whether a given chunk of content should be a `<section>` or a `<div>`: ___ / 5

### Reflection Prompt
Find a real website you use often. Open DevTools (Appendix A) and check whether it actually uses semantic tags correctly. What did you find?

---
---

# PART 4 WORKBOOK — Making It Flexible (Flexbox Photo Gallery)

### Learning Objectives
- [ ] I can state which property turns a container into a flex container.
- [ ] I understand the difference between the main axis and the cross axis.
- [ ] I can explain `flex: grow shrink basis` in my own words.
- [ ] I know when `justify-content` and `align-items` swap meaning.

### Key Vocabulary — Fill in the Blank
1. The parent that gets `display: flex` is called the flex ________, and its direct children automatically become flex ________.
2. `flex-wrap: wrap` allows items to ________________ instead of shrinking to fit one line.
3. `justify-content` controls alignment along the ________ axis; `align-items` controls alignment along the ________ axis.
4. In `flex: 1 1 260px`, the three values in order represent: ________, ________, ________.

### Concept Check
1. If you set `display: flex` on the wrong element (a child instead of the parent), what visibly happens — or doesn't happen?
2. Why does `justify-content` visually seem to "swap jobs" with `align-items` once you set `flex-direction: column`?
3. What is the actual difference between using `margin` for spacing between flex items versus using `gap`?

### Code Tracing Exercise
```css
.row {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}
.item {
  flex: 1 1 300px;
}
```
If `.row` is exactly 620px wide and contains three `.item` children, how many items fit per row before wrapping? _______
(Hint: account for the two 10px gaps between three items, and each item's 300px basis.)

### Debug It!
```css
.gallery-card {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}
```
The developer wants the *cards inside* `.gallery` (the parent) to wrap into rows. Instead, nothing changed about the layout at all. What's wrong?

Explanation: _________________________________________________

Fixed CSS:
```css

```

### Hands-On Build Checklist
- [ ] Built the unstyled vertical stack of gallery cards first
- [ ] Applied `display: flex` to `.gallery` and observed the "snap" into a single overflowing row
- [ ] Added `flex-wrap: wrap` and `gap` for clean wrapping
- [ ] Experimented with `justify-content` and `align-items` deliberately
- [ ] Built a `.featured` card using a combined class (`class="gallery-card featured"`)
- [ ] Built the "Gallery, Stacked" `flex-direction: column` challenge variant

### Self-Assessment
I could confidently decide between Flexbox and "just more margins" for a new layout problem: ___ / 5

### Reflection Prompt
Describe the "snap" moment from Step 2 in your own words — what did the layout look like right before, and right after, adding `display: flex`?

---
---

# PART 5 WORKBOOK — Navigating Like a Pro (Responsive Navbar)

### Learning Objectives
- [ ] I can list all five `position` values and what each does.
- [ ] I understand why `position: relative` on a parent matters for `position: absolute` children.
- [ ] I can explain the checkbox-hack mobile menu mechanism end-to-end.
- [ ] I can write a basic media query correctly.

### Key Vocabulary — Fill in the Blank
1. `position: static` is the ________ value, and ignores `top`/`left`/`right`/`bottom` entirely.
2. `position: relative` keeps an element in normal flow but allows it to be ________, and — more importantly — establishes an ________ for absolutely positioned children.
3. `position: absolute` positions relative to the nearest ancestor with a position other than ________.
4. `position: fixed` anchors to the ________, and ignores ________ entirely.
5. The `~` symbol in CSS is called the ________ combinator, and only selects elements that come ________ the reference element in the HTML.

### Concept Check
1. Why did the badge in Part 5, Step 3 "escape" to the corner of the whole page before the fix — walk through the exact reasoning.
2. What is the key behavioral difference between `position: sticky` and `position: fixed`?
3. In the checkbox hack, why must the `<input type="checkbox">` appear *before* `.navbar-links` in the HTML source order?

### Code Tracing Exercise
```html
<div class="card">
  <span class="tag">New</span>
</div>
```
```css
.card { position: static; }
.tag {
  position: absolute;
  top: 0;
  right: 0;
}
```
Where will `.tag` actually end up positioned? Why? _________________________________________________

What single CSS change would anchor it correctly to `.card` instead?

### Debug It!
```html
<ul class="navbar-links">...</ul>
<input type="checkbox" id="menu-toggle" class="menu-toggle-checkbox" />
<label for="menu-toggle" class="hamburger-icon">...</label>
```
```css
.menu-toggle-checkbox:checked ~ .navbar-links {
  max-height: 300px;
}
```
This mobile menu will never open. Explain exactly why, and describe the fix (no need to rewrite all the HTML — just describe what must change).

Explanation: _________________________________________________

### Hands-On Build Checklist
- [ ] Demonstrated `static` vs `relative` with a temporary offset experiment
- [ ] Deliberately broke, then fixed, an `absolute`-positioned badge using `relative` on its parent
- [ ] Built a `position: fixed` navbar and compensated with top padding on the page content
- [ ] Demonstrated `position: sticky` on a secondary element
- [ ] Built the full checkbox-hack mobile menu with a media query
- [ ] Integrated the finished navbar into the Part 3 landing page and Part 2 recipe page

### Self-Assessment
I can predict, without testing, where an `absolute`-positioned element will land given a specific set of ancestors: ___ / 5

### Reflection Prompt
Which of the five `position` values gave you the most trouble, and what finally made it click?

---
---

# PART 6 WORKBOOK — Grid Power (Blog Layout)

### Learning Objectives
- [ ] I can explain, concretely, when to reach for Grid instead of Flexbox.
- [ ] I can define a grid container with columns using `fr` units.
- [ ] I can place a specific item using `grid-column`/`grid-row` line numbers.
- [ ] I understand how `repeat(auto-fit, minmax(...))` creates responsiveness with zero media queries.

### Key Vocabulary — Fill in the Blank
1. Flexbox arranges items along ________ dimension; Grid arranges items along ________ dimensions simultaneously.
2. The `fr` unit means "________" — it divides available space proportionally.
3. For a 2-column grid, there are always exactly ________ vertical grid lines.
4. `minmax(220px, 1fr)` means each column is at least ________ wide, but can grow up to ________.

### Concept Check
1. Give one layout problem where Flexbox would genuinely struggle, and Grid is the clearly better tool. Explain why.
2. What does `grid-column: 1 / 3` actually mean — and why is it a common beginner mistake to assume it means "span 2 columns" as a literal count?
3. Why did the blog layout project use *both* Grid and Flexbox, at different scales, in the same page?

### Code Tracing Exercise
```css
.layout {
  display: grid;
  grid-template-columns: 2fr 1fr;
}
.sidebar {
  grid-column: 2 / 3;
  grid-row: 1 / 3;
}
```
If `.layout` is 900px wide (ignoring gaps for simplicity), how wide is the sidebar's column, roughly? _______px
How many rows does the sidebar visually span? _______

### Debug It!
```css
.post-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
}
```
```css
@media (max-width: 600px) {
  .post-grid {
    grid-template-columns: 1fr;
  }
}
```
A developer added this media query "just to be safe," assuming `auto-fit`/`minmax()` alone wouldn't handle small screens. Is this media query actually necessary? Explain your reasoning.

Explanation: _________________________________________________

### Hands-On Build Checklist
- [ ] Briefly attempted the layout with Flexbox-only to feel the friction
- [ ] Built the full semantic HTML (featured post, `<aside>` sidebar, post-grid articles)
- [ ] Defined the outer 2-column grid with `fr` units
- [ ] Explicitly placed featured/sidebar/grid regions using `grid-column`/`grid-row`
- [ ] Nested a responsive `repeat(auto-fit, minmax())` grid inside `.post-grid`
- [ ] Used Flexbox for the internal stacking within each individual `.post-card`
- [ ] Linked one post card to an earlier project (Part 2 recipe)

### Self-Assessment
I can decide, in under 10 seconds, whether a new layout problem calls for Flexbox, Grid, or both: ___ / 5

### Reflection Prompt
Write your own one-sentence rule of thumb for "Flexbox vs. Grid" in language you'd explain to a friend.

---
---

# PART 7 WORKBOOK — Bringing It to Life (Animated Product Card)

### Learning Objectives
- [ ] I understand why `transition` must be declared on the base state, not the `:hover` state.
- [ ] I can explain why `transform` doesn't disturb surrounding layout.
- [ ] I can write a basic `@keyframes` animation and trigger it with `animation`.
- [ ] I can articulate at least two UX guidelines for tasteful motion.

### Key Vocabulary — Fill in the Blank
1. `transform` changes an element's appearance ________ affecting the normal document flow of its neighbors.
2. `transition` only animates between ________ states (before and after); `@keyframes` can define ________ states.
3. The `forwards` keyword in an `animation` shorthand means: after finishing, ________________________________.
4. Animating `transform` and `opacity` is preferred over animating `width`/`top`/`left` because ________________________________.

### Concept Check
1. Why did Part 7 deliberately show the card lifting *without* a transition first, before adding one?
2. What specifically goes wrong if you put your `transition` property inside the `:hover` rule instead of the base rule?
3. Give two of the four UX guidelines from Part 7's reference section for keeping motion tasteful rather than excessive.

### Code Tracing Exercise
```css
.box {
  transform: translateY(0);
}
.box:hover {
  transform: translateY(-10px);
}
```
Will this hover effect animate smoothly, or snap instantly? _______ What single line is missing to make it smooth?

### Debug It!
```css
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
.badge {
  opacity: 0;
}
.card:hover .badge {
  animation: fadeIn 0.4s ease;
}
```
After hovering and then moving the mouse away, the badge should stay visible per the intended design, but instead it snaps back to invisible. What's missing?

Explanation: _________________________________________________

Fixed line:
```css

```

### Hands-On Build Checklist
- [ ] Built the static card first and confirmed hover currently does nothing
- [ ] Added `transform: translateY()` on `:hover` and observed the instant "snap"
- [ ] Added `transition` on the base state and observed the smooth "glide"
- [ ] Animated `box-shadow` alongside the transform for a lift illusion
- [ ] Added button `scale()` on hover and `:active` press feedback
- [ ] Built the `@keyframes fadeSlideIn` badge animation with `forwards`
- [ ] Applied the same hover-lift pattern to Part 4's gallery cards and Part 6's blog cards

### Self-Assessment
I understand exactly why `transform`/`opacity` are safer to animate than `width`/`top`/`left`: ___ / 5

### Reflection Prompt
Describe a real app or website where you think animation was used *too much*. What would you remove or tone down, using this Part's guidelines?

---
---

# PART 8 WORKBOOK — Forms That Feel Good (Contact Form)

### Learning Objectives
- [ ] I can correctly pair a `<label>` with its input using `for`/`id`.
- [ ] I understand what native, JavaScript-free validation CSS/HTML can and cannot do.
- [ ] I can explain why styling `:invalid` without `:not(:placeholder-shown)` is a common mistake.
- [ ] I understand the difference between `GET` and `POST`.

### Key Vocabulary — Fill in the Blank
1. A `<label for="email">` is linked to `<input id="email">` by matching ________ values exactly.
2. The `required` attribute blocks form ________ until the field has a ________.
3. `:invalid:not(:placeholder-shown)` specifically targets fields that are invalid **and** ________________.
4. Removing the default focus outline is only acceptable if you ________________________________.

### Concept Check
1. Why is `placeholder` text not a valid substitute for a real `<label>`?
2. What happens, specifically, if you forget the `name` attribute on a form input?
3. Name one thing CSS-only validation *cannot* do, that would require JavaScript.

### Code Tracing Exercise
```html
<label for="username">Username</label>
<input type="text" id="user-name" name="username" required />
```
Will clicking the label "Username" correctly focus the input? _______ Why or why not?

### Debug It!
```css
.form-group input:invalid {
  border-color: red;
  background-color: #fef2f2;
}
```
The moment the page loads, every required field already looks like an error, even though the user hasn't typed anything yet. What's the fix?

Explanation: _________________________________________________

Fixed CSS:
```css

```

### Hands-On Build Checklist
- [ ] Built the bare `<form>` skeleton with a placeholder submit button
- [ ] Added Name, Email, Message fields with correctly paired labels
- [ ] Confirmed native browser validation blocks submission on empty required fields
- [ ] Styled `:focus` states with a visible custom ring
- [ ] Styled `:valid`/`:invalid` live feedback, guarded with `:not(:placeholder-shown)`
- [ ] Added a custom `.error-message` revealed via the `~` sibling selector
- [ ] Added a `<select>` Subject dropdown with a disabled placeholder option
- [ ] Built the newsletter signup variant reusing the same `.form-group` styles

### Self-Assessment
I could build a fully accessible, validated contact form from a blank file without referencing the tutorial: ___ / 5

### Reflection Prompt
Think of a form you've filled out recently online that felt frustrating. Which specific technique from this Part would have fixed it?

---
---

# PART 9 WORKBOOK — Putting It All Together (Capstone Portfolio Site)

### Learning Objectives
- [ ] I can explain what a CSS custom property (`--variable`) is and why it's useful at scale.
- [ ] I can describe the three-file CSS architecture and each file's single responsibility.
- [ ] I can explain the `.active` nav-link convention and why plain HTML/CSS needs it at all.
- [ ] I can identify which earlier Part contributed which piece of the final capstone.

### Key Vocabulary — Fill in the Blank
1. `:root` targets the ________ element, making custom properties declared there available ________.
2. `var(--color-primary)` ________ the value stored in that custom property.
3. In the three-file architecture: `style.css` handles ________, `layout.css` handles ________, and `components.css` handles ________.
4. Since plain HTML/CSS has no built-in concept of "current page," this series simulates it by manually adding a ________ class to the matching nav link on each page.

### Concept Check
1. Explain the exact mechanism by which changing one `--color-primary` value updates the navbar, buttons, and card borders simultaneously.
2. Why does the Projects page link to sibling project folders using `../` instead of copying the projects' code directly into the capstone?
3. Match each capstone page to the Part(s) it originated from:
   - `about.html` → Part ______
   - `contact.html` → Part ______
   - `projects.html` (grid pattern) → Part ______ and ______
   - navbar (every page) → Part ______
   - card hover animation (every card) → Part ______

### Code Tracing Exercise
```css
:root {
  --color-primary: blue;
}
.btn {
  background-color: var(--color-primary);
}
.card {
  border-color: var(--color-primary);
}
```
If you change only `--color-primary` to `green`, which elements update? _______________________________
What is NOT true: that you'd need to also update `.btn` and `.card` individually — why not?

### Debug It!
```css
.hero {
  background-color: var(--color-primary);
}
```
This is included in `components.css`, but nothing renders — the background stays the browser's default. `style.css` (which declares `:root { --color-primary: ...; }`) is linked correctly. What's the likely bug?

Explanation: _________________________________________________
(Hint: think about `<link>` order in the `<head>`, and whether `:root` variables need to be *declared* before they're *used* in terms of file load order for this to work reliably in every browser.)

### Hands-On Build Checklist
- [ ] Consolidated all project images into `my-portfolio/images/`
- [ ] Built `:root` design tokens in `style.css` (colors, fonts, radii, shadows, transitions)
- [ ] Built the shared navbar/footer once, in `style.css`
- [ ] Built `layout.css` with the container/hero/grid patterns
- [ ] Built `components.css` with buttons, cards, forms, badges
- [ ] Built all five pages: `index.html`, `about.html`, `projects.html`, `contact.html`, `recipe.html`
- [ ] Performed the one-line brand color swap and confirmed the site-wide update
- [ ] Completed the full production polish checklist (responsive, contrast, focus, meta tags, reduced motion)
- [ ] Attempted the end-of-part challenge: added one new section/page independently

### Self-Assessment
I could explain this entire capstone's file architecture to another beginner, from memory: ___ / 5

### Reflection Prompt
Look back at your Part 1 bio card and your finished `about.html`. Write two sentences on what specifically changed, and what stayed exactly the same.

---
---

# APPENDICES WORKBOOK — Quick-Reference Skill Checks

## Appendix A: DevTools
- [ ] I can open DevTools and inspect any element in under 5 seconds.
- [ ] I can find which CSS file/line a rule is coming from.
- [ ] I can identify a "losing" (crossed-out) CSS rule and explain why it lost.
- [ ] I can test a specific screen width using the device toolbar.

**Quick Check:** In the Styles pane, a crossed-out rule means: _________________________________________________

## Appendix B: Glossary
- [ ] I can locate any tag/property from Parts 1–9 in under 15 seconds using this glossary.

**Quick Check:** Without looking, write the purpose of `object-fit: cover`: _________________________________________________

## Appendix C: Debugging
- [ ] I can work through the six-question debugging decision tree without prompting.

**Quick Check:** List the six questions in the debugging decision tree, in order:
1. _________________________ 2. _________________________ 3. _________________________
4. _________________________ 5. _________________________ 6. _________________________

## Appendix D: Deployment
- [ ] I have successfully deployed at least one project to GitHub Pages or Netlify.
- [ ] I can explain why sibling-folder relative links break after deployment into a separate repository.

**Quick Check:** What does `git push -u origin main` actually do, in plain language? _________________________________________________

## Appendix E: Where to Go Next
- [ ] I have a personal, ordered plan for what to learn after this series.

**Quick Check:** Write your own personal order for E.1–E.5, based on your own goals, and one sentence why:
1. _________________________ because _________________________________________________

---
---

# PRIMERS WORKBOOK — Foundational Concept Checks

## Primer 1: How the Web Actually Works
**Quick Check:** Fill in the request/response cycle in order: browser sends a ______ request → DNS resolves the ______ → server sends back an HTTP ______ with a status code → browser ______ and ______ the HTML.

## Primer 2: Files, Folders, and Paths
**Quick Check:** Trace this path manually. A file at `projects/site-a/index.html` links to `href="../site-b/about.html"`. What is the fully resolved path? _________________________________________________

## Primer 3: Reading Code Like a Sentence
**Quick Check:** Name the four universal syntax patterns covered in this primer:
1. _________________ 2. _________________ 3. _________________ 4. _________________

## Primer 4: Color, Units, and Measurement
**Quick Check:** Convert: `#FFFFFF` in `rgb()` notation is: rgb(___, ___, ___). Why is `rem` generally preferred over `px` for font sizing, for accessibility reasons? _________________________________________________

## Primer 5: Just Enough Command Line to Get By
**Quick Check:** Match the command to its meaning:
`pwd` → _______________ `cd ..` → _______________ `ls` → _______________ `git status` → _______________

---
---

# FINAL SERIES SELF-ASSESSMENT

Before considering the series complete, rate yourself honestly (1–5) on each:

| Skill | Rating |
|---|---|
| I can build a semantic HTML page from a blank file, unaided | ___ |
| I can explain the box model to someone else, with an analogy | ___ |
| I can choose correctly between Flexbox and Grid for a new layout | ___ |
| I can build a mobile-responsive navbar using positioning and media queries | ___ |
| I can add tasteful, non-excessive CSS animation to a UI element | ___ |
| I can build an accessible, validated form without JavaScript | ___ |
| I can organize CSS into a scalable, token-driven architecture | ___ |
| I can deploy a static site to a live public URL | ___ |
| I can debug a broken layout using DevTools, systematically | ___ |
| I understand what's happening "underneath" HTML/CSS (Primers 1–5) | ___ |

**Total score: ___ / 50**

- **40–50:** You're ready to move confidently into Appendix E's next steps — particularly JavaScript fundamentals.
- **25–39:** Revisit the specific Parts tied to your lowest-scoring rows above before moving on — don't rush past a shaky foundation.
- **Below 25:** That's completely fine — rebuild one or two projects from this series *without* looking at the tutorial text, using only this workbook's checklists as your guide, then reassess.

---

# ANSWER KEY

*(Answers to Concept Check and Debug It! exercises, by Part. Code Tracing and Fill-in-the-Blank answers are intentionally left for self/peer verification against the original series text, to encourage returning to the source material rather than passively checking answers.)*

**Part 1** — Concept Check 4: (b). Debug It: missing closing slash/quote on `<img>` is optional (self-closing is fine either way) but `<p>My photo<p>` is missing a `/` — should be `</p>`.

**Part 2** — Debug It: selector missing the dot — should be `.ingredients { list-style-type: square; }`.

**Part 3** — Debug It: `max-width`/`margin: auto` applied to the section itself instead of an inner wrapper `<div>`; fix by moving those two properties to a nested `.container` div while keeping `background-color`/`padding` on the outer section.

**Part 4** — Debug It: `display: flex` was applied to `.gallery-card` (the item) instead of `.gallery` (the parent/container).

**Part 5** — Debug It: the checkbox's `id` and label's `for` may match, but the actual bug pattern to check is HTML source order — the checkbox must appear before `.navbar-links` for the `~` sibling combinator to work.

**Part 6** — Debug It: the media query is redundant; `auto-fit`/`minmax(220px, 1fr)` already collapses to a single column once the container is too narrow for even one 220px column plus its minimum, with zero additional media query needed.

**Part 7** — Debug It: missing the `forwards` keyword in the `animation` shorthand, causing the badge to revert to its `from` (invisible) state once the animation completes.

**Part 8** — Debug It: missing `:not(:placeholder-shown)` guard, causing every empty required field to appear invalid before the user interacts with it.

**Part 9** — Debug It: most likely cause is that `style.css` (declaring `:root`) is linked *after* `components.css` in the `<head>`, or `components.css` was accidentally opened/tested as a standalone file without `style.css` also linked — custom properties must be declared somewhere the browser has already parsed before (or within the same cascade as) their usage; always double-check all three CSS files are linked, in a sensible order, on every single page.
