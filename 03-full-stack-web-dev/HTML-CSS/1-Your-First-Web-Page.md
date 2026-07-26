# Part 1: Your First Web Page (Personal Bio Card)

### What You're Building

By the end of this part, you'll have a single, real web page: a **Personal Bio Card** — your name, a photo, a short introduction, a couple of links to places like GitHub or LinkedIn, a "Fun Facts" list, and a favorite quote — all styled with actual color and typography, not just black text on a white background.

More importantly, this page isn't a throwaway exercise. In Part 9, this exact bio card gets refined and dropped directly into your capstone portfolio as the "About" page. Everything you type today gets reused later. So type carefully — future-you will thank present-you.

### The "Aha" Moment for This Part

Here's the moment I want to engineer for you: the instant you realize **HTML is just labeled content, and the browser's only job is to read those labels and lay things out accordingly.**

Most beginners' fear of code comes from imagining it's like math or logic — full of rules that must be "solved" correctly. HTML has almost none of that. When you write `<h1>My Name</h1>`, you're doing the exact same thing as clicking the "Heading 1" style in a Google Doc — you're just doing it by typing a label instead of clicking a button. There is no calculation, no "right answer" being computed. You're describing what something *is* (a heading, a paragraph, an image), and the browser handles the visual part.

We're going to make this click hard by doing something slightly unusual: building the *exact same content* three different ways in this part — first totally unstyled, then with one quick inline style, then with a proper internal stylesheet. Watching the same words on your screen visually transform with each step, without you ever touching the actual sentences, is what will make CSS "click" as a separate, additive layer rather than a mysterious black box.

---

## Step 1: Setting Up the Project Folder

**The Target:** A dedicated folder for this project, `part-1-bio-card/`, inside your main `build-as-you-learn` folder.

**The Concept:** Think of your `build-as-you-learn` folder as a bookshelf, and each part of this series as its own labeled book. Keeping every project in its own folder means nothing from Part 1 will ever accidentally overwrite or interfere with Part 2, Part 3, and so on — and it mirrors exactly how real developers organize multi-project workspaces.

**The Implementation:**

In VS Code's file explorer (make sure you have `build-as-you-learn` open as your workspace folder from Part 0), create this structure:

```
build-as-you-learn/
└── part-1-bio-card/
    ├── index.html
    └── images/
        └── profile.jpg
```

To create it:
1. Right-click in the file explorer → **New Folder** → name it `part-1-bio-card`.
2. Inside that folder, right-click → **New Folder** → name it `images`.
3. Drop any photo of yourself (or a placeholder image — even a plain square PNG works for now) into `images/`, and rename it exactly `profile.jpg`.
4. Inside `part-1-bio-card/`, right-click → **New File** → name it `index.html`.

> **Why `index.html` specifically?** Every web server (and Live Server) treats a file named `index.html` as the default page to show when someone visits a folder — like how a book's front cover is the default thing you see before flipping to any specific chapter. We'll use this name for the main page of every project in this series.

**The Verification:**

Confirm the structure by looking at your VS Code file explorer sidebar — you should see:

```
part-1-bio-card
  ├── images
  │     └── profile.jpg
  └── index.html
```

If `index.html` and the `images` folder both appear nested correctly under `part-1-bio-card`, you're ready for Step 2.

---

## Step 2: The Bare-Bones HTML Skeleton

**The Target:** `part-1-bio-card/index.html` — the minimum valid HTML document structure.

**The Concept:** Every HTML page follows the same basic "skeleton," the same way every formal letter has a date, a greeting, a body, and a signature in a predictable order. This skeleton tells the browser three things: *"This is HTML"* (the doctype), *"here is invisible information about the page"* (the head), and *"here is everything a visitor actually sees"* (the body).

Let's define each new term as it appears:

- **`<!DOCTYPE html>`** — Not a tag, technically a "declaration." It tells the browser "interpret everything below using modern HTML rules." Every HTML file starts with this, exactly as written, no exceptions.
- **`<html>`** — The root container. Everything else lives inside it.
- **`<head>`** — Metadata: information *about* the page (its title, character encoding, linked files) that isn't directly displayed as page content.
- **`<body>`** — Everything a visitor actually sees rendered on screen.

**The Implementation:**

```html
<!-- part-1-bio-card/index.html -->
<!DOCTYPE html>
<html lang="en">
  <!-- lang="en" tells screen readers and search engines the page's language -->
  <head>
    <meta charset="UTF-8" />
    <!-- charset UTF-8 lets the page correctly display virtually any character, -->
    <!-- including accented letters, emoji, and symbols like ✓ or — -->

    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <!-- This line tells mobile browsers "don't zoom out to fake a desktop view; -->
    <!-- use the phone's actual screen width." Without it, your page looks tiny on phones. -->

    <title>Alex Rivera — Bio Card</title>
    <!-- The <title> text appears in the browser tab, not on the page itself -->
  </head>
  <body>
    <!-- Content goes here in the next step -->
  </body>
</html>
```

> **Note on the name:** Throughout this part, I'll use a placeholder person, "Alex Rivera." Replace every instance of that name with your own as you type — this is your bio card, not mine.

**The Verification:**

1. Save the file.
2. Right-click `index.html` in VS Code → **Open with Live Server**.
3. Your browser should open a blank white page.
4. Look at the **browser tab** at the top — it should read "Alex Rivera — Bio Card". That confirms your `<head>` and `<title>` are working, even though the `<body>` is still empty.

---

## Step 3: Adding a Heading and Introduction Paragraph

**The Target:** Populate `<body>` with your name as a heading and a short intro as a paragraph.

**The Concept:** HTML has six levels of headings, `<h1>` through `<h6>`, ranked by importance — like a book's title (biggest, most important) versus a chapter subheading (smaller, less important). `<h1>` should be used **once per page**, for the single most important piece of text — almost always your main title. Everything else is a `<p>` (paragraph), which is just a normal block of text.

**The Implementation:**

```html
<!-- part-1-bio-card/index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Alex Rivera — Bio Card</title>
  </head>
  <body>
    <h1>Alex Rivera</h1>
    <!-- The single, most important heading on the page: my name -->

    <p>
      Hi, I'm Alex — a curious front-end developer who loves turning
      ideas into clean, usable interfaces. I'm currently learning
      HTML and CSS from scratch, one project at a time.
    </p>
  </body>
</html>
```

**The Verification:**

Save and check your browser (it should auto-refresh thanks to Live Server). You should now see, in plain black default browser text:

> # Alex Rivera
> Hi, I'm Alex — a curious front-end developer who loves turning ideas into clean, usable interfaces. I'm currently learning HTML and CSS from scratch, one project at a time.

Notice the heading is large and bold by default, and there's automatic spacing between it and the paragraph — you didn't write any CSS yet, but the browser has built-in "default styles" for every tag. We're about to start overriding them.

---

## Step 4: Adding Your Photo

**The Target:** Insert the `profile.jpg` image between the heading and the paragraph.

**The Concept:** The `<img>` tag is a **self-closing tag** — unlike `<h1>...</h1>`, it has no separate closing tag, because it doesn't wrap around any text content; it just points to an external file and says "draw this picture here." It needs two things at minimum:

- `src` (source) — the file path to the image.
- `alt` (alternative text) — a written description of the image, used by screen readers for visually impaired visitors, and shown if the image fails to load. **This is not optional in professional code** — a missing `alt` attribute is one of the most common accessibility mistakes on the web.

**The Implementation:**

```html
<!-- part-1-bio-card/index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Alex Rivera — Bio Card</title>
  </head>
  <body>
    <h1>Alex Rivera</h1>

    <img src="images/profile.jpg" alt="Portrait photo of Alex Rivera smiling outdoors" />
    <!-- src is a relative path: "look inside the images folder, next to this HTML file" -->

    <p>
      Hi, I'm Alex — a curious front-end developer who loves turning
      ideas into clean, usable interfaces. I'm currently learning
      HTML and CSS from scratch, one project at a time.
    </p>
  </body>
</html>
```

**The Verification:**

Save and check the browser. Your photo should now appear above the paragraph, likely at its full original resolution (possibly huge — we'll fix sizing with CSS soon). If you instead see a small broken-image icon, double-check:
- The file is named exactly `profile.jpg` (case matters on some systems).
- It's inside the `images` folder, which sits next to `index.html`.

---

## Step 5: Adding Links to GitHub and LinkedIn

**The Target:** Two clickable links at the bottom of the page.

**The Concept:** The **anchor tag**, `<a>`, is how HTML creates hyperlinks. It needs an `href` attribute (hypertext reference) — the destination URL. Since these links point to *other websites entirely* (not another page in your own project), we'll also add `target="_blank"` (open in a new tab) and `rel="noopener noreferrer"` — a security best practice that prevents the new tab from gaining unsafe access back to your original page.

**The Implementation:**

```html
<!-- part-1-bio-card/index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Alex Rivera — Bio Card</title>
  </head>
  <body>
    <h1>Alex Rivera</h1>

    <img src="images/profile.jpg" alt="Portrait photo of Alex Rivera smiling outdoors" />

    <p>
      Hi, I'm Alex — a curious front-end developer who loves turning
      ideas into clean, usable interfaces. I'm currently learning
      HTML and CSS from scratch, one project at a time.
    </p>

    <p>
      <a href="https://github.com/" target="_blank" rel="noopener noreferrer">GitHub</a>
      &nbsp;|&nbsp;
      <!-- &nbsp; is a "non-breaking space" -- a way to insert a plain space -->
      <!-- character in HTML, since multiple regular spaces get collapsed to one -->
      <a href="https://www.linkedin.com/" target="_blank" rel="noopener noreferrer">LinkedIn</a>
    </p>
  </body>
</html>
```

> Replace the placeholder URLs (`https://github.com/`, `https://www.linkedin.com/`) with your actual profile links.

**The Verification:**

Save, refresh, and click each link — both should open in a **new browser tab**. Hover over each link without clicking; your browser's status bar (bottom-left corner) should preview the destination URL, confirming the `href` is set correctly.

---

## Step 6: A First Taste of CSS — the Inline `style` Attribute

**The Target:** Make the paragraph text a distinct color using an inline style, as our very first CSS experiment.

**The Concept:** So far, everything on your page looks like default browser styling — black text, blue links, a certain default font. **CSS (Cascading Style Sheets)** is the language that changes *how* HTML content looks, without changing *what* it is. The word "cascading" hints at something important we'll explore more later: styles can come from multiple places, and there are rules for which one "wins." For now, the simplest possible way to apply CSS is the `style` attribute, written directly on a tag — like scribbling a sticky note directly onto one specific object, rather than writing a rule that applies to a whole category of things.

**The Implementation:**

```html
<!-- part-1-bio-card/index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Alex Rivera — Bio Card</title>
  </head>
  <body>
    <h1>Alex Rivera</h1>

    <img src="images/profile.jpg" alt="Portrait photo of Alex Rivera smiling outdoors" />

    <p style="color: #4b5563; font-family: Georgia, serif;">
      Hi, I'm Alex — a curious front-end developer who loves turning
      ideas into clean, usable interfaces. I'm currently learning
      HTML and CSS from scratch, one project at a time.
    </p>

    <p>
      <a href="https://github.com/" target="_blank" rel="noopener noreferrer">GitHub</a>
      &nbsp;|&nbsp;
      <a href="https://www.linkedin.com/" target="_blank" rel="noopener noreferrer">LinkedIn</a>
    </p>
  </body>
</html>
```

**The Verification:**

Save and refresh. Your intro paragraph should now render in a dark slate-gray color, using a serif font (one with small decorative strokes, like Georgia), while the rest of the page stays in the browser's default black sans-serif font. This proves CSS changes *appearance only* — the words, their meaning, and their order in the HTML are completely untouched.

---

## Step 7: Leveling Up — the `<style>` Block in `<head>`

**The Target:** Refactor away from the inline style, and instead style the *entire page* consistently using a `<style>` block.

**The Concept:** Inline styles have a big problem: if you wanted every paragraph on a big page styled the same way, you'd have to copy that `style="..."` text onto every single tag by hand — messy, repetitive, and a nightmare to update later (imagine having to change one color in fifty different places). The `<style>` element, placed in `<head>`, solves this by letting you write a **rule** once that applies to every matching element on the page automatically.

A CSS rule has this anatomy:

```
selector {
  property: value;
}
```

- The **selector** says *which* elements to style (right now, we'll target elements by their tag name — every `<p>`, every `<h1>`, etc.).
- The **declaration block** (inside `{ }`) is a list of `property: value;` pairs — each one a specific visual instruction.

**The Implementation:**

```html
<!-- part-1-bio-card/index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Alex Rivera — Bio Card</title>

    <style>
      /* Selecting the <body> tag styles the entire page's background and base font */
      body {
        font-family: "Segoe UI", Arial, sans-serif;
        background-color: #f3f4f6;
        color: #1f2937;
        max-width: 600px;
        /* max-width keeps the content from stretching edge-to-edge on wide screens */
        margin: 40px auto;
        /* "auto" left/right margin, combined with max-width, horizontally centers the page */
        padding: 0 20px;
        text-align: center;
      }

      h1 {
        color: #2563eb;
        margin-bottom: 4px;
      }

      img {
        width: 160px;
        height: 160px;
        object-fit: cover;
        /* object-fit: cover crops the image to fill the box neatly instead of stretching it */
        border-radius: 50%;
        /* 50% border-radius on an equal width/height image makes it a perfect circle */
        border: 4px solid #2563eb;
        margin: 16px 0;
      }

      p {
        line-height: 1.6;
        /* line-height adds breathing room between lines of wrapped text, aiding readability */
        font-family: Georgia, serif;
        color: #4b5563;
      }

      a {
        color: #2563eb;
        font-weight: bold;
        text-decoration: none;
      }

      a:hover {
        text-decoration: underline;
        /* :hover is our first "pseudo-class" -- a state-based selector meaning */
        /* "only apply this rule while the user's mouse is over the element" */
      }
    </style>
  </head>
  <body>
    <h1>Alex Rivera</h1>

    <img src="images/profile.jpg" alt="Portrait photo of Alex Rivera smiling outdoors" />

    <p>
      Hi, I'm Alex — a curious front-end developer who loves turning
      ideas into clean, usable interfaces. I'm currently learning
      HTML and CSS from scratch, one project at a time.
    </p>

    <p>
      <a href="https://github.com/" target="_blank" rel="noopener noreferrer">GitHub</a>
      &nbsp;|&nbsp;
      <a href="https://www.linkedin.com/" target="_blank" rel="noopener noreferrer">LinkedIn</a>
    </p>
  </body>
</html>
```

Notice we removed the inline `style="..."` from the `<p>` tag entirely — the tag-based rule in `<style>` now handles every paragraph on the page automatically, which is exactly the repetition problem we just solved.

**The Verification:**

Save and refresh. You should now see a fully transformed page:
- A centered content column (not stretched across your whole screen).
- A light gray page background.
- Your name in blue, bold.
- Your photo rendered as a neat circle with a blue border.
- Your intro paragraph in dark gray serif text.
- Links in blue that underline only when you hover your mouse over them.

This is the exact same HTML content as Step 3 — only the *presentation layer* changed. That separation — content in HTML, appearance in CSS — is the single most important idea in this entire part.

---

## End-of-Part Challenge: Fun Facts List + Favorite Quote

Now it's your turn to extend the page using only what you've learned so far — new HTML tags, styled using new tag-selector CSS rules (no classes or IDs yet — that's Part 2's territory).

**Your task:**
1. Add an **unordered list** (`<ul>`, with `<li>` items) titled "Fun Facts About Me," containing 3–4 short facts.
2. Add a **`<blockquote>`** containing your favorite quote, styled *visibly differently* from your intro paragraph (different font style, color, or a left border, for example).

Try it yourself first. Here's a complete reference solution to check your work against once you've attempted it:

### Reference Solution

```html
<!-- part-1-bio-card/index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Alex Rivera — Bio Card</title>

    <style>
      body {
        font-family: "Segoe UI", Arial, sans-serif;
        background-color: #f3f4f6;
        color: #1f2937;
        max-width: 600px;
        margin: 40px auto;
        padding: 0 20px;
        text-align: center;
      }

      h1 {
        color: #2563eb;
        margin-bottom: 4px;
      }

      h2 {
        color: #1f2937;
        font-size: 1.2rem;
        margin-top: 32px;
        text-align: left;
      }

      img {
        width: 160px;
        height: 160px;
        object-fit: cover;
        border-radius: 50%;
        border: 4px solid #2563eb;
        margin: 16px 0;
      }

      p {
        line-height: 1.6;
        font-family: Georgia, serif;
        color: #4b5563;
      }

      a {
        color: #2563eb;
        font-weight: bold;
        text-decoration: none;
      }

      a:hover {
        text-decoration: underline;
      }

      ul {
        text-align: left;
        /* overriding the body's center alignment so list items read naturally left-to-right */
        line-height: 1.8;
        color: #374151;
      }

      blockquote {
        text-align: left;
        font-style: italic;
        color: #1e3a8a;
        background-color: #e0e7ff;
        border-left: 5px solid #2563eb;
        padding: 12px 20px;
        margin: 24px 0;
        border-radius: 4px;
      }
    </style>
  </head>
  <body>
    <h1>Alex Rivera</h1>

    <img src="images/profile.jpg" alt="Portrait photo of Alex Rivera smiling outdoors" />

    <p>
      Hi, I'm Alex — a curious front-end developer who loves turning
      ideas into clean, usable interfaces. I'm currently learning
      HTML and CSS from scratch, one project at a time.
    </p>

    <p>
      <a href="https://github.com/" target="_blank" rel="noopener noreferrer">GitHub</a>
      &nbsp;|&nbsp;
      <a href="https://www.linkedin.com/" target="_blank" rel="noopener noreferrer">LinkedIn</a>
    </p>

    <h2>Fun Facts About Me</h2>
    <ul>
      <li>I've visited 12 countries and counting.</li>
      <li>I taught myself to solve a Rubik's Cube in a weekend.</li>
      <li>My first "real" program was a to-do list app that never actually saved anything.</li>
      <li>I can't function before my morning coffee.</li>
    </ul>

    <blockquote>
      "The best way to predict the future is to invent it." — Alan Kay
    </blockquote>
  </body>
</html>
```

**Verification for the challenge:**

Save and refresh. You should see your fun facts as a left-aligned bulleted list beneath a small "Fun Facts About Me" subheading, and your quote in an italicized box with a colored left border and tinted background — visually distinct from the intro paragraph above it, exactly as the challenge asked.

---

### Optional Bonus: Put It on the Actual Internet

Everything so far has lived only on your computer, viewed through Live Server. If you want the "I'm officially on the web" feeling right now rather than waiting for the capstone, here's a two-minute option: create a free account at [github.com](https://github.com/), create a new repository, upload your `part-1-bio-card` folder's contents, then enable **Settings → Pages** for that repository. GitHub will give you a public URL like `https://yourname.github.io/reponame/` where anyone in the world can view your bio card. This is entirely optional — we'll cover deployment in more depth later in the series — but it's a nice reward if you want it now.

---

## Reference Section: Deep Dive for Part 1

*(This section is for whenever you want to go deeper — it's not required reading to move on to Part 2.)*

### Every Tag Introduced in This Part

| Tag | Purpose | Self-closing? |
|---|---|---|
| `<!DOCTYPE html>` | Declares the document as modern HTML | N/A (not a tag) |
| `<html>` | Root element wrapping the entire page | No |
| `<head>` | Container for metadata (not visible content) | No |
| `<meta>` | A single piece of metadata (charset, viewport, etc.) | Yes |
| `<title>` | Text shown in the browser tab | No |
| `<style>` | Container for CSS rules | No |
| `<body>` | Container for all visible page content | No |
| `<h1>`–`<h6>` | Headings, ranked by importance | No |
| `<p>` | A paragraph of text | No |
| `<img>` | Embeds an image | Yes |
| `<a>` | A hyperlink | No |
| `<ul>` | An unordered (bulleted) list | No |
| `<li>` | A list item, inside `<ul>` or `<ol>` | No |
| `<blockquote>` | A block of quoted text | No |

### Why the `<meta viewport>` Tag Matters So Much

Without `<meta name="viewport" content="width=device-width, initial-scale=1.0" />`, mobile browsers assume your page was designed for a desktop screen (typically simulating a width around 980px) and shrink the entire page to fit, forcing users to pinch-zoom to read anything. Adding this single line is what allows your later CSS (media queries in Part 5, responsive grids in Part 6) to actually respond to real device widths. It costs nothing to include now and prevents a confusing bug later.

### Understanding `alt` Text Properly

Good `alt` text describes the *content and function* of an image concisely, as if describing it to someone on the phone who can't see your screen. Compare:

- ❌ `alt="image1.jpg"` (useless — just repeats the filename)
- ❌ `alt="photo"` (too vague)
- ✅ `alt="Portrait photo of Alex Rivera smiling outdoors"` (specific, useful, concise)

If an image is purely decorative (contributes no information — e.g., a background swirl graphic), the professional convention is `alt=""` (empty, but still present) — this explicitly tells screen readers to skip it, rather than describe it uselessly.

### Element Selectors, Recap

In this part, every CSS selector we wrote targeted a *tag name directly* — `body`, `h1`, `img`, `p`, `a`, `ul`, `blockquote`. This means the rule applies to **every single instance of that tag on the page**, with no exceptions. That's perfectly fine for a one-page project like this bio card. But imagine a page with ten paragraphs where you want just *one* of them styled differently (like our quote-styled paragraph vs. regular paragraphs) — tag selectors alone can't express "this specific one, but not the others." That exact problem is what Part 2 solves with **class selectors** and **ID selectors** — so if you found yourself wanting more precision in this challenge, you're already primed for what's coming next.

### Common Beginner Mistakes to Watch For

1. **Forgetting a closing tag**, e.g. `<p>Hello` with no `</p>`. Browsers are forgiving and will often auto-close it for you silently, but it can cause unpredictable layout issues on more complex pages. Get in the habit of closing every non-self-closing tag immediately after typing the opening one.
2. **Mismatched image paths.** `src="images/profile.jpg"` only works if `index.html` and the `images` folder are siblings in the same directory. Moving files around later is a top cause of "broken image" bugs.
3. **Multiple `<h1>` tags.** Technically legal, but not semantically correct — treat `<h1>` as reserved for the single main title of the page.
4. **Using `<br>` tags to fake spacing** instead of CSS `margin`/`padding`. It works visually but mixes structure with presentation — exactly the tangle we're trying to avoid by using a `<style>` block.

---

## What's Next

You now have a complete, styled, single-page site, and you've directly witnessed HTML (structure) and CSS (appearance) working as two separate, cooperating layers. In Part 2, we'll stop writing CSS inside the HTML file altogether — moving it into its own external `.css` file — and build a second, completely different project (a Recipe Page) to prove that a stylesheet isn't chained to one single page. You'll also meet **class and ID selectors**, and get hands-on with the **box model** (margin, border, padding) that governs spacing for literally every element on every page you'll ever build.
