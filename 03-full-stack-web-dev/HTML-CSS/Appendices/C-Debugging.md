# Appendix C: Debugging Common Beginner Bugs

### Why This Appendix Exists

Every single bug you will ever encounter in plain HTML/CSS falls into a small, finite set of recurring categories — far smaller than it feels like in the moment of frustration. This appendix is organized as a **symptom → likely cause → fix** troubleshooting guide, structured the way an experienced developer actually thinks when something looks wrong: *what does it look like, what usually causes that, and how do I confirm it.*

Pair this appendix directly with **Appendix A (DevTools)** — nearly every fix below starts with "open DevTools and check X," because DevTools is what turns a guess into a confirmed diagnosis.

---

## C.1 — "My CSS isn't applying at all"

**Symptom:** You've written CSS rules, saved the file, refreshed the browser — and the page looks completely unstyled, as if the stylesheet doesn't exist.

**Likely Causes, in order of probability:**

1. **The `<link>` path is wrong.** The single most common cause, by far.
2. **You forgot `rel="stylesheet"`.**
3. **The CSS file wasn't actually saved.**
4. **You're looking at the wrong file in the browser** (an old cached copy, or a duplicate file in a different folder).

**How to Diagnose:**

Open DevTools (Appendix A) → **Network** tab → refresh the page. Look for your `.css` file in the list.

- If it shows a **404** status → your path is wrong. Check that `href="css/style.css"` in your HTML exactly matches the real folder/file name and casing, relative to the HTML file's own location.
- If it **doesn't appear in the list at all** → your `<link>` tag itself is likely malformed (missing `href`, or missing the whole tag) — go back to your HTML `<head>` and check it exists and is spelled correctly.
- If it shows **200 (success)** but styles still aren't applying → the file loaded correctly, but your *selectors* inside it don't match your HTML (see C.2 below).

**The Fix:**

```html
<!-- Common mistake -->
<link rel="stylesheet" href="styles.css" />
<!-- but your actual file is named style.css (singular) -->

<!-- Corrected -->
<link rel="stylesheet" href="style.css" />
```

Also double check folder nesting:

```html
<!-- If your file structure is: -->
<!-- project/index.html -->
<!-- project/css/style.css -->

<!-- This is WRONG (missing the css/ folder in the path): -->
<link rel="stylesheet" href="style.css" />

<!-- This is CORRECT: -->
<link rel="stylesheet" href="css/style.css" />
```

---

## C.2 — "My CSS file loads fine, but this one specific rule isn't working"

**Symptom:** Most of your styling works, but one particular property on one particular element seems to be ignored.

**Likely Causes:**

1. **A typo in the class name**, mismatched between HTML and CSS (`class="recipe-tital"` vs `.recipe-title`).
2. **A more specific rule elsewhere is overriding it** (this is the "cascading" part of Cascading Style Sheets).
3. **A typo inside the CSS rule itself** — a missing colon, missing semicolon, or misspelled property name silently breaks just that one declaration.

**How to Diagnose:**

Open DevTools → click the misbehaving element → look at the **Styles** pane (Appendix A.3). You will see one of these situations:

- **Your rule doesn't appear in the list at all** → this confirms it's a class-name mismatch. Check both the HTML `class="..."` attribute and your CSS `.classname { }` selector character-by-character.
- **Your rule appears, but is crossed out (strikethrough)** → this confirms something else is winning. Look at which rule sits above it *without* a strikethrough — that's the actual winning rule, and its file/line reference tells you exactly where to go fix it.
- **Your rule appears in the list, not crossed out, but the property you expected isn't there** → this confirms a typo inside your CSS declaration itself.

**The Fix, for a specificity conflict:**

```css
/* If a tag selector and a class selector conflict, CLASS always wins over TAG, regardless of order: */

p {
  color: black;
}

.intro {
  color: blue;
}
```

```html
<p class="intro">This text will be BLUE, because class selectors are more specific than tag selectors.</p>
```

If you specifically want a particular rule to win, prefer making its selector *more specific* (e.g., `.form-card .intro` instead of just `.intro`) rather than reaching for `!important` — using `!important` to force a win is considered a last resort in professional CSS, because it makes future overrides much harder to reason about.

---

## C.3 — "My image shows a broken icon instead of the picture"

**Symptom:** Instead of your photo, you see a small broken-image placeholder icon (often with the `alt` text displayed next to it).

**Likely Causes:**

1. **Wrong filename or extension** (`profile.jpg` vs `profile.JPG` vs `profile.jpeg` vs `profile.png`) — file extensions matter and are case-sensitive on some operating systems (notably, when deployed to a real web server, even if your local Windows machine was forgiving about it).
2. **Wrong relative path** — the `images/` folder isn't where the HTML expects it.
3. **The file was moved or renamed** after you wrote the `src` attribute.

**How to Diagnose:**

Open DevTools → **Console** tab → refresh. Look for a red error line similar to:

```
GET file:///.../images/profile.jpg net::ERR_FILE_NOT_FOUND
```

This tells you the **exact path the browser actually tried** — compare it character-by-character against your real file location in your file explorer.

**The Fix:**

```html
<!-- If your actual file is named "Profile.JPG" but your HTML says: -->
<img src="images/profile.jpg" alt="..." />

<!-- Either rename the actual file to match your HTML exactly (recommended, lowercase, no spaces): -->
<!-- images/profile.jpg -->

<!-- Or update the HTML to match the real filename precisely: -->
<img src="images/Profile.JPG" alt="..." />
```

**Best practice going forward:** always name image files lowercase, with hyphens instead of spaces (`profile-photo.jpg`, not `Profile Photo.JPG`) — this sidesteps case-sensitivity and space-encoding issues entirely, on every operating system and every web host.

---

## C.4 — "My Flexbox items aren't lining up the way I expect"

**Symptom:** You added `display: flex`, but items are stacking vertically, or ignoring `justify-content`/`align-items`, or not wrapping.

**Likely Causes:**

1. **`display: flex` was applied to the wrong element** (often the child instead of the parent).
2. **`flex-wrap: wrap` was forgotten**, so items are being forced onto one line and shrinking/overflowing instead of wrapping.
3. **You're confusing `justify-content` and `align-items`** — remember, they swap meaning when `flex-direction` changes.

**How to Diagnose:**

Open DevTools → click the *parent* container → in the Styles pane, confirm `display: flex` actually appears there (not crossed out). Chrome and Firefox DevTools also show a small "flex" badge directly next to elements that are active flex containers in the Elements tree — a fast visual confirmation.

**The Fix:**

```css
/* WRONG: display: flex applied to the ITEM, not the container */
.gallery-card {
  display: flex; /* this only affects gallery-card's OWN children, not its siblings */
}

/* CORRECT: display: flex applied to the CONTAINER */
.gallery {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
}
```

Refer back to Part 4's reference section for the full `justify-content` vs `align-items` axis table if the alignment still doesn't match your expectation after confirming the container is correct.

---

## C.5 — "My absolutely positioned element jumped to a weird corner of the whole page"

**Symptom:** You gave a child element `position: absolute; top: 0; right: 0;` expecting it to sit in the corner of its immediate parent, but it instead flew to the corner of the entire browser window.

**Likely Cause:** This is Part 5's core lesson, restated as a bug: **no ancestor of this element has a `position` value other than `static`**, so the browser fell back to positioning it relative to the whole page.

**How to Diagnose:**

Open DevTools → click the absolutely positioned element → then click upward through its ancestors in the Elements tree, checking each one's Styles pane for a `position` value. The first ancestor you find with `position: static` (or no `position` declared at all, which defaults to `static`) — going all the way up — confirms there's no anchor.

**The Fix:**

```css
/* Add position: relative to the DIRECT parent you actually want as the anchor */
.navbar-logo {
  position: relative; /* <-- the missing piece */
}

.new-badge {
  position: absolute;
  top: 0;
  right: 0; /* now correctly anchored to .navbar-logo, not the whole page */
}
```

---

## C.6 — "My fixed navbar is covering up the top of my page content"

**Symptom:** After setting `position: fixed` on a navbar, the first heading or paragraph on the page is partially or fully hidden underneath it.

**Likely Cause:** `position: fixed` removes the element from normal document flow entirely — the browser no longer reserves any space for it, so content that used to sit safely below it now flows up underneath it instead.

**The Fix:**

Add top padding (or margin) to the very next element after the navbar, at least equal to the navbar's rendered height:

```css
.navbar {
  position: fixed;
  top: 0;
  height: 70px; /* for example */
}

.page-content {
  padding-top: 90px; /* navbar height + a little extra breathing room */
}
```

**How to find the exact right number:** Open DevTools → click your navbar element → check the box model diagram (Appendix A.4) for its actual rendered height, then set your compensating padding slightly larger than that number.

---

## C.7 — "My media query doesn't seem to be doing anything"

**Symptom:** You wrote a `@media (max-width: 768px) { ... }` block, but resizing the browser doesn't trigger the expected changes.

**Likely Causes:**

1. **Missing the viewport meta tag** (`<meta name="viewport" content="width=device-width, initial-scale=1.0" />`) — without it, mobile browsers report a fake, zoomed-out width, and your breakpoint math gets thrown off entirely.
2. **A typo in the media query syntax** (missing parentheses, wrong property name).
3. **A more specific selector outside the media query is overriding the rules inside it.**

**How to Diagnose:**

Open DevTools → device toolbar (Appendix A.5) → set the width to something clearly inside your intended breakpoint (e.g., 400px for a `max-width: 768px` query) → check the Styles pane for the element in question. If your media query rule appears in the list (even if crossed out), the media query itself is being recognized correctly, and the bug is a specificity conflict (see C.2). If it doesn't appear in the list at all, double-check your media query's syntax character-by-character.

**The Fix — Syntax Checklist:**

```css
/* CORRECT syntax -- note the parentheses and colon */
@media (max-width: 768px) {
  .navbar-links {
    flex-direction: column;
  }
}

/* Common typo mistakes to check for: */
/* @media max-width: 768px { }        <-- missing parentheses      */
/* @media (max-width 768px) { }       <-- missing colon             */
/* @media (max-width: 768) { }        <-- missing "px" unit         */
```

---

## C.8 — "My checkbox-hack mobile menu won't open"

**Symptom:** Clicking the hamburger icon does nothing — the mobile dropdown menu never appears.

**Likely Causes:**

1. **Mismatched `id`/`for` values** between the checkbox and its label.
2. **The checkbox is placed *after* `.navbar-links` in the HTML** instead of before it — the `~` sibling selector only looks forward.
3. **The label doesn't actually wrap/reference the checkbox correctly.**

**How to Diagnose:**

Open DevTools → Elements tab → click your checkbox in the tree, then manually toggle its `checked` attribute (many browsers let you tick a checkbox visual indicator directly in the Elements tree, or you can use the Console — see below). If toggling it directly still doesn't reveal the menu, the CSS selector itself is broken (check C.8.2 below). If toggling it via DevTools *does* reveal the menu, but clicking the actual hamburger icon doesn't — the `for`/`id` pairing between your `<label>` and `<input>` is mismatched.

**The Fix:**

```html
<!-- Double-check these two values are IDENTICAL, character for character -->
<input type="checkbox" id="menu-toggle" class="menu-toggle-checkbox" />
<label for="menu-toggle" class="hamburger-icon">
  <span></span><span></span><span></span>
</label>

<!-- And confirm the checkbox comes BEFORE .navbar-links in the HTML source order -->
<ul class="navbar-links">...</ul>
```

```css
/* Confirm the sibling selector matches your actual class names exactly */
.menu-toggle-checkbox:checked ~ .navbar-links {
  max-height: 300px;
}
```

---

## C.9 — "My form submits even when a required field is empty"

**Symptom:** You added `required` to an input, but clicking submit doesn't block anything or show a warning.

**Likely Causes:**

1. **The `required` attribute is misspelled or misplaced** (must be on the `<input>`/`<select>`/`<textarea>` itself).
2. **The button isn't actually of `type="submit"`** — a `<button>` with no `type` attribute defaults to `submit` in most contexts, but it's easy to accidentally set `type="button"`, which explicitly disables the native submit/validation behavior.
3. **JavaScript elsewhere on the page is intercepting the submit event** (not a concern for this series, since we wrote no JS, but worth knowing as a future cause).

**The Fix:**

```html
<!-- Confirm required is spelled correctly and present -->
<input type="email" id="email" name="email" required />

<!-- Confirm the button type is exactly "submit" -->
<button type="submit">Send Message</button>
```

---

## C.10 — "Everything looks fine on my computer but broken when I open it a different way"

**Symptom:** Your page looks perfect via Live Server, but broken (missing images, missing styles) when opened by double-clicking the HTML file directly, or after uploading to GitHub Pages.

**Likely Cause:** Relative paths are interpreted differently depending on *how* a file is opened. Double-clicking a file opens it via a `file://` URL, which behaves slightly differently than Live Server's `http://127.0.0.1:5500/...` — and case-sensitivity rules genuinely change once deployed to most real web servers (which are typically Linux-based and case-sensitive), even if your Windows machine silently tolerated a mismatched case locally.

**The Fix:** Always test with Live Server (or an equivalent local server) rather than double-clicking files directly, and always use **exact, lowercase, hyphenated filenames** for every asset (`profile-photo.jpg`, not `Profile Photo.jpg`) to guarantee identical behavior locally and once deployed.

---

## Quick Reference: The Debugging Decision Tree

When *anything* looks wrong, work through these questions in order:

1. **Is the file even loading?** → Check Network tab for 404s.
2. **Is my selector matching the right element?** → Check Styles pane for missing/crossed-out rules.
3. **Is something else overriding my rule?** → Check for strikethrough rules above it in the Styles pane.
4. **Is the element positioned/sized the way I think?** → Check the box model diagram.
5. **Does this only break at certain screen widths?** → Check with the device toolbar.
6. **Are there any red errors in the Console?** → Check for broken file references.

Internalizing this six-question sequence — always starting with DevTools, never starting with guesswork — is, more than any single tag or property in this whole series, the actual difference between "someone who copies code" and "someone who can build and fix real websites."
