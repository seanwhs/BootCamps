# Appendix B: The Complete HTML Tag & CSS Property Glossary

### Why This Appendix Exists

Across nine parts, you've accumulated a real, working vocabulary — but it arrived in pieces, spread across different projects, weeks (or hours) apart. This appendix collects **every HTML tag, attribute, CSS property, selector, and unit used anywhere in this series** into one alphabetized, scannable reference — so that six months from now, when you're staring at your own old code wondering "wait, what does `flex-basis` actually do again?", you have one place to look instead of hunting back through nine parts.

Each entry includes **where it was first taught** in this series, so you can always jump back to the full explanation and analogy if a one-line definition isn't enough.

---

## B.1 — HTML Tags, A–Z

| Tag | Purpose | First Appeared |
|---|---|---|
| `<a>` | Hyperlink; requires `href` | Part 1 |
| `<article>` | A self-contained piece of content (e.g., a blog post preview) | Part 6 |
| `<aside>` | Content tangentially related to the main content (e.g., a sidebar) | Part 6 |
| `<blockquote>` | A block of quoted text | Part 1 |
| `<body>` | Container for all visible page content | Part 1 |
| `<button>` | A clickable control, typically inside a `<form>` | Part 8 |
| `<div>` | A generic, meaning-free grouping container, used purely for layout/styling | Part 2 |
| `<footer>` | Closing content: copyright, contact info, secondary links | Part 3 |
| `<form>` | Wraps a group of input controls submitted together | Part 8 |
| `<h1>`–`<h6>` | Headings, ranked by importance (`<h1>` = most important, one per page) | Part 1 |
| `<head>` | Container for metadata not directly displayed on the page | Part 1 |
| `<header>` | Introductory content, typically top-of-page or top-of-section | Part 3 |
| `<html>` | The root element wrapping the entire document | Part 1 |
| `<img>` | Embeds an image; self-closing; requires `src` and `alt` | Part 1 |
| `<input>` | A single form field; behavior controlled by its `type` attribute | Part 8 |
| `<label>` | Text description linked to a form control via matching `for`/`id` | Part 5 (checkbox hack), formalized in Part 8 |
| `<li>` | A single list item, used inside `<ul>` or `<ol>` | Part 1 |
| `<link>` | Connects an external resource (stylesheet, favicon) to the document | Part 2 |
| `<main>` | Wraps the single primary content region of a page (one per page) | Part 4 |
| `<meta>` | A single piece of page metadata (character encoding, viewport, description) | Part 1 |
| `<nav>` | Wraps a block of primary navigation links | Part 3 |
| `<ol>` | An ordered (numbered) list | Part 2 |
| `<option>` | A single choice inside a `<select>` dropdown | Part 8 |
| `<p>` | A paragraph of text | Part 1 |
| `<section>` | A distinct thematic grouping of content, usually with its own heading | Part 3 |
| `<select>` | A dropdown control offering a constrained set of choices | Part 8 |
| `<span>` | A generic, meaning-free inline container, used for styling a small piece of text/content | Part 5 (hamburger bars, badges) |
| `<style>` | Container for CSS rules, placed in `<head>` | Part 1 |
| `<textarea>` | A multi-line free-text form field | Part 8 |
| `<title>` | Text shown in the browser tab; also used by search engines | Part 1 |
| `<ul>` | An unordered (bulleted) list | Part 1 |
| `<!DOCTYPE html>` | Declaration (not a tag) telling the browser to use modern HTML rules | Part 1 |

### Key HTML Attributes, A–Z

| Attribute | Used On | Purpose | First Appeared |
|---|---|---|---|
| `action` | `<form>` | The destination URL the form's data is submitted to | Part 8 |
| `alt` | `<img>` | Text description for screen readers / failed image loads | Part 1 |
| `charset` | `<meta>` | Declares the document's character encoding (always `UTF-8`) | Part 1 |
| `checked` | `<input type="checkbox">` | Whether a checkbox starts in the "on" state | Part 5 |
| `class` | any element | Attaches one or more reusable CSS class hooks | Part 2 |
| `content` | `<meta>` | The actual value paired with a `name` attribute | Part 1 |
| `disabled` | `<option>`, form controls | Makes an element unselectable/uninteractive | Part 8 |
| `for` | `<label>` | Matches a `<label>` to its controlled input via that input's `id` | Part 5, Part 8 |
| `href` | `<a>`, `<link>` | The destination URL or linked file path | Part 1 |
| `id` | any element | A unique, one-per-page identifier hook | Part 2 |
| `lang` | `<html>` | Declares the page's language for accessibility/SEO | Part 1 |
| `max-width` (as inline style) | any element | (see CSS section — occasionally used inline for quick fixes) | Part 3 |
| `method` | `<form>` | How form data is submitted (`post` vs `get`) | Part 8 |
| `name` | `<meta>`, form controls | For `<meta>`: identifies which metadata type; for inputs: identifies the field's submitted value | Part 1, Part 8 |
| `placeholder` | `<input>`, `<textarea>` | Grayed-out hint text shown only while empty | Part 8 |
| `rel` | `<link>`, `<a>` | Describes the relationship of a linked resource (`stylesheet`, `noopener noreferrer`) | Part 1, Part 2 |
| `required` | form controls | Blocks form submission until the field has a value | Part 8 |
| `rows` | `<textarea>` | Sets the visible height in text lines | Part 8 |
| `selected` | `<option>` | Marks an option as the default chosen value | Part 8 |
| `src` | `<img>` | The file path to the image being embedded | Part 1 |
| `target="_blank"` | `<a>` | Opens the link in a new browser tab | Part 1 |
| `type` | `<input>`, `<button>` | Determines input behavior (`text`, `email`, etc.) or button role (`submit`) | Part 8 |
| `value` | `<option>` | The actual data submitted when that option is chosen | Part 8 |
| `viewport` (via `<meta name="viewport">`) | `<meta>` | Controls how the page scales on mobile devices | Part 1 |

---

## B.2 — CSS Properties, A–Z

| Property | Purpose | First Appeared |
|---|---|---|
| `align-content` | Controls vertical packing of grid rows when there's leftover container height | Part 6 |
| `align-items` | Alignment along the cross axis in Flexbox (or Grid) | Part 4 |
| `animation` | Applies a named `@keyframes` sequence to an element | Part 7 |
| `background-color` | Sets an element's background fill color | Part 1 |
| `border` | Shorthand for width, style, and color of an element's edge | Part 2 |
| `border-radius` | Rounds an element's corners | Part 1 |
| `box-shadow` | Adds a drop shadow around an element's box | Part 2 |
| `box-sizing` | Determines whether `width`/`height` include padding+border (`border-box`) or not (`content-box`) | Part 2 |
| `color` | Sets an element's text color | Part 1 |
| `cursor` | Controls the mouse pointer's appearance over an element (e.g., `pointer`) | Part 5 |
| `display` | Sets an element's layout mode (`block`, `flex`, `grid`, `none`, `inline-block`) | Part 1 (implicitly), Part 4/6 (explicitly) |
| `flex` | Shorthand for `flex-grow`, `flex-shrink`, `flex-basis` on a flex item | Part 3, formalized Part 4 |
| `flex-direction` | Sets the main axis direction of a flex container (`row` or `column`) | Part 4 |
| `flex-wrap` | Allows flex items to wrap onto multiple lines | Part 4 |
| `font-family` | Sets the typeface used for text | Part 1 |
| `font-size` | Sets text size | Part 1 |
| `font-style` | Sets italic/normal text styling | Part 1 |
| `font-weight` | Sets text boldness | Part 1 |
| `gap` | Sets spacing between flex or grid items, both axes | Part 4 |
| `grid-column` | Sets which column line(s) a grid item starts/ends at | Part 6 |
| `grid-row` | Sets which row line(s) a grid item starts/ends at | Part 6 |
| `grid-template-columns` | Defines a grid container's column tracks | Part 6 |
| `height` | Sets an element's height | Part 2 |
| `justify-content` | Alignment along the main axis in Flexbox | Part 4 |
| `left` | Offsets a positioned element from the left | Part 5 |
| `line-height` | Sets spacing between lines of wrapped text | Part 1 |
| `list-style-type` / `list-style` | Controls or removes bullet/number markers on list items | Part 2, Part 5 (`none`) |
| `margin` | Space outside an element's border, pushing neighbors away | Part 2 |
| `max-width` | Caps an element's maximum width, allowing it to shrink but not grow beyond it | Part 2 |
| `object-fit` | Controls how an image fills its box (`cover` crops to fill neatly) | Part 1 |
| `opacity` | Sets an element's transparency, from `0` (invisible) to `1` (fully visible) | Part 7 |
| `outline` | Draws a focus ring around an element (often overridden and replaced in Part 8) | Part 8 |
| `overflow` | Controls what happens to content that exceeds its box (`hidden` clips it) | Part 4 |
| `padding` | Space inside an element's border, cushioning its content | Part 2 |
| `position` | Sets an element's positioning mode (`static`, `relative`, `absolute`, `fixed`, `sticky`) | Part 5 |
| `resize` | Controls whether/how a user can manually resize an element (e.g., a `<textarea>`) | Part 8 |
| `text-align` | Horizontally aligns text within its container | Part 1 |
| `text-decoration` | Controls underlines/strikethroughs on text | Part 1 |
| `text-transform` | Changes text casing (e.g., `uppercase`) without altering the actual HTML content | Part 6 |
| `top` | Offsets a positioned element from the top | Part 5 |
| `transform` | Visually moves, scales, or rotates an element without affecting layout flow | Part 7 |
| `transition` | Animates a property change smoothly over time | Part 7 |
| `width` | Sets an element's width | Part 2 |
| `z-index` | Controls stacking order when elements overlap | Part 5 |

---

## B.3 — CSS Selectors and Pseudo-Classes, A–Z

| Selector | Matches | First Appeared |
|---|---|---|
| `*` | Every element on the page (universal selector) | Part 2 |
| `.classname` | Any element carrying `class="classname"` | Part 2 |
| `#idname` | The single element carrying `id="idname"` | Part 3 |
| `element` (e.g. `p`, `h1`) | Every instance of that tag | Part 1 |
| `A B` (descendant combinator) | Any `B` nested anywhere inside an `A` | Part 4 (`.gallery-card img`) |
| `A > B` (child combinator) | Any `B` that is a *direct* child of `A` | Part 8 (implied structure) |
| `A ~ B` (general sibling combinator) | Any `B` sharing a parent with `A`, appearing after it in the HTML | Part 5 (checkbox hack), Part 8 (error messages) |
| `:hover` | An element while the mouse is over it | Part 1 |
| `:focus` | An element that currently has keyboard/click focus | Part 1 (link), formalized Part 8 |
| `:active` | An element during the brief moment it's being clicked | Part 7 |
| `:checked` | A checkbox/radio input currently in the "on" state | Part 5 |
| `:valid` / `:invalid` | A form field whose current value passes/fails native validation | Part 8 |
| `:not(...)` | Excludes elements matching the inner selector | Part 8 (`:not(:placeholder-shown)`) |
| `:placeholder-shown` | An input currently displaying its placeholder (i.e., currently empty) | Part 8 |
| `:last-child` | The final child element among its siblings | Part 6 |

---

## B.4 — CSS Units, A–Z

| Unit | Meaning | First Appeared |
|---|---|---|
| `%` | Percentage relative to a parent's corresponding dimension | Part 1 (`border-radius: 50%`) |
| `deg` | Degrees, used for `rotate()` transforms | Part 7 (reference section) |
| `fr` | A "fraction" unit unique to Grid — divides available space proportionally | Part 6 |
| `px` | Pixels — an absolute, fixed-size unit | Part 1 |
| `rem` | Relative to the root (`<html>`) element's font size | Part 2 |
| `s` / `ms` | Seconds / milliseconds, used for `transition`/`animation` durations | Part 7 |
| `vh` | Percentage of the browser viewport's height (`100vh` = full screen height) | Part 7 |

---

## B.5 — Special Values and Keywords Worth Remembering

| Value | Context | Meaning |
|---|---|---|
| `auto` (in `margin`) | `margin: 0 auto` | Horizontally centers a block element with a set `max-width` | Part 2 |
| `border-box` | `box-sizing` | Width/height calculations include padding and border | Part 2 |
| `forwards` | `animation` shorthand | Keeps an animation's final keyframe state after it completes | Part 7 |
| `none` (`display`) | Hides an element entirely, removing it from layout | Part 5 (`.menu-toggle-checkbox`) |
| `repeat(auto-fit, minmax(...))` | `grid-template-columns` | Creates a fully responsive column count with zero media queries | Part 6 |
| `space-between` | `justify-content` | Distributes leftover space between items, pinning first/last to the edges | Part 4 (reference) |

---

## How to Use This Appendix Going Forward

Treat this as a living lookup table, not required reading. The realistic workflow: you're deep in a new project, you vaguely remember there's a property for "making text uppercase without retyping it," you scan the CSS Properties table, spot `text-transform`, and jump back to Part 6 if you need the fuller explanation. That's the entire job of this appendix — fast recall, backed by a pointer to the real lesson whenever you need more than a one-line reminder.
