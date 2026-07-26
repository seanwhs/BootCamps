# Part 4: Making It Flexible (Flexbox Photo Gallery)

### What You're Building

A **photo/gallery page** where a set of image cards line up neatly in rows and automatically wrap onto new lines as the screen gets narrower — instead of the awkward, uneven stacking you'd get without a real layout system. This gallery pattern isn't a one-off either: the card-grid structure you build here gets reused almost verbatim for your capstone's Projects page in Part 9.

### The "Aha" Moment for This Part

In Part 3, you saw `display: flex` used three times (header, feature grid, testimonials) but I asked you to treat it as a "black box" tool for the moment. The "aha" I'm engineering here is this: **the instant you toggle `display: flex` on and off on a group of boxes and watch them snap from an awkward vertical stack into a clean, evenly-spaced row, Flexbox stops being magic and becomes a tool you control on purpose.** We'll do exactly that toggle, live, in Step 2.

---

## Step 1: Project Setup and the "Before" State

**The Target:** A new project folder, `part-4-photo-gallery/`, with a deliberately un-flexed starting layout.

**The Implementation:**

```
part-4-photo-gallery/
├── index.html
├── css/
│   └── style.css
└── images/
    ├── photo-1.jpg
    ├── photo-2.jpg
    ├── photo-3.jpg
    ├── photo-4.jpg
    ├── photo-5.jpg
    └── photo-6.jpg
```

Drop six photos of any kind into `images/` (landscapes, food, travel — whatever you like), named exactly `photo-1.jpg` through `photo-6.jpg`.

```html
<!-- part-4-photo-gallery/index.html -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Photo Gallery</title>
    <link rel="stylesheet" href="css/style.css" />
  </head>
  <body>
    <header class="gallery-header">
      <h1>My Photo Gallery</h1>
      <p>A small collection of shots I'm proud of.</p>
    </header>

    <main class="gallery-wrap">
      <div class="gallery">
        <div class="gallery-card">
          <img src="images/photo-1.jpg" alt="Photo 1 from my collection" />
          <p class="caption">Morning Hike</p>
        </div>
        <div class="gallery-card">
          <img src="images/photo-2.jpg" alt="Photo 2 from my collection" />
          <p class="caption">City Lights</p>
        </div>
        <div class="gallery-card">
          <img src="images/photo-3.jpg" alt="Photo 3 from my collection" />
          <p class="caption">Coastal Drive</p>
        </div>
        <div class="gallery-card">
          <img src="images/photo-4.jpg" alt="Photo 4 from my collection" />
          <p class="caption">Quiet Forest</p>
        </div>
        <div class="gallery-card">
          <img src="images/photo-5.jpg" alt="Photo 5 from my collection" />
          <p class="caption">Street Market</p>
        </div>
        <div class="gallery-card">
          <img src="images/photo-6.jpg" alt="Photo 6 from my collection" />
          <p class="caption">Sunset Point</p>
        </div>
      </div>
    </main>
  </body>
</html>
```

Notice `<main>` makes its first appearance here — briefly mentioned in Part 3's reference table. It wraps the single primary content region of the page (as opposed to the `<header>` above it), and there should only ever be one `<main>` per page.

```css
/* part-4-photo-gallery/css/style.css */

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: "Segoe UI", Arial, sans-serif;
  color: #1f2937;
}

.gallery-header {
  text-align: center;
  padding: 40px 24px;
  background-color: #111827;
  color: white;
}

.gallery-wrap {
  max-width: 1000px;
  margin: 0 auto;
  padding: 40px 24px;
}

.gallery-card {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  overflow: hidden;
  /* overflow: hidden clips the image's corners to match the rounded border-radius */
  margin-bottom: 20px;
  /* this is our ONLY spacing tool right now -- notice it only creates vertical gaps */
}

.gallery-card img {
  width: 100%;
  height: 220px;
  object-fit: cover;
  display: block;
  /* display: block removes a few pixels of mystery gap that images have by default */
  /* (images are "inline" by default, which reserves a little space for descenders like 'g' or 'y') */
}

.caption {
  padding: 12px;
  font-weight: 500;
  text-align: center;
}
```

**The Verification:**

Open with Live Server. Every image should appear, but as a **single vertical column**, stacked one below another, taking up a huge amount of vertical scroll for what should be a compact gallery. This is the "before" — an unstyled *layout*, even though the individual cards themselves look fine. This is the exact problem Flexbox exists to solve.

---

## Step 2: The Flexbox "Snap" — Container vs. Items

**The Target:** Turn `.gallery` into a **flex container**, and watch its children (the `.gallery-card` divs, now called **flex items**) instantly rearrange.

**The Concept:** Here's the core mental model for the rest of this part, using a real-world analogy: **imagine a row of books on a shelf.** Before Flexbox, your `<div>`s behave like books stacked in a pile on the floor — each one just sits directly below the previous one, full width, with no concept of "sharing a row." `display: flex` on the *parent* container is like picking that pile up and placing the books upright, side-by-side, on an actual shelf. Suddenly they have a *direction* (left-to-right, by default), they can be pushed together or spread apart, and you get powerful new commands for how to arrange them.

Two vocabulary terms to nail down immediately:
- The **flex container** is the parent element you apply `display: flex` to (our `.gallery` div).
- The **flex items** are its direct children (our six `.gallery-card` divs) — they automatically gain new behaviors the instant their parent becomes a flex container, with zero changes needed on the items themselves.

**The Implementation:**

```css
/* part-4-photo-gallery/css/style.css (add this new rule) */

.gallery {
  display: flex;
  /* This ONE line turns every direct child of .gallery into a flex item, */
  /* automatically arranged left-to-right in a row instead of stacked vertically */
}
```

**The Verification:**

Save and refresh. Your six cards should **snap instantly** from a vertical stack into a horizontal row — likely squeezed together tightly, and possibly overflowing off the right edge of the screen if there isn't room. That's fine and expected; we haven't told Flexbox how to *wrap* or *space* things yet — we've only told it "arrange these in a row." This raw, slightly-broken-looking row is the exact "snap" moment I promised — take a second to genuinely notice how dramatically one property changed the entire layout.

---

## Step 3: Wrapping Gracefully with `flex-wrap` and `gap`

**The Target:** Make the row wrap onto multiple lines instead of overflowing, and add clean, even spacing between cards.

**The Concept:** By default, Flexbox tries to cram every item into a *single* row, shrinking items if needed rather than wrapping — like insisting every book fit on one shelf, squeezing them thinner and thinner rather than adding a second shelf. `flex-wrap: wrap` gives Flexbox permission to start a new row once the current one runs out of space — exactly like adding as many shelves as needed, so books never get uncomfortably squeezed.

`gap` is the modern, clean way to add spacing *between* flex items — both horizontally and vertically — without the old hacky trick of adding margin to every item and then subtracting it back out on the container's edges.

**The Implementation:**

```css
/* part-4-photo-gallery/css/style.css (update the .gallery rule) */

.gallery {
  display: flex;
  flex-wrap: wrap;
  /* now, once a row runs out of horizontal space, items wrap onto a new line */
  gap: 20px;
  /* consistent 20px spacing between every card, in both directions */
}

.gallery-card {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  overflow: hidden;
  flex: 1 1 260px;
  /* flex: grow shrink basis                                             */
  /* grow(1): if there's extra space in the row, share it among cards    */
  /* shrink(1): if space is tight, cards are allowed to shrink           */
  /* basis(260px): each card's "ideal" starting width before growing/shrinking */
  margin-bottom: 0;
  /* we no longer need bottom margin -- gap now handles ALL spacing, both axes */
}
```

**The Verification:**

Save and refresh. Your cards should now arrange themselves into a clean multi-row grid — likely 3 per row on a wide screen — with even 20px gaps both between columns and between rows. Resize your browser window narrower and watch the cards reflow in real time: 3 per row, then 2 per row, then down to 1 per row on a narrow (phone-sized) screen — all without writing a single media query. This is Flexbox's wrapping doing exactly the job it's designed for.

---

## Step 4: `justify-content` and `align-items` — Controlling Alignment

**The Target:** Deliberately experiment with the two most important Flexbox alignment properties so you understand each one's axis.

**The Concept:** Flexbox thinks in terms of two axes:
- The **main axis** — the primary direction items flow in (left-to-right by default, since `flex-direction` defaults to `row`).
- The **cross axis** — perpendicular to the main axis (top-to-bottom, when the main axis is horizontal).

`justify-content` controls alignment **along the main axis** (how items are spread out left-to-right). `align-items` controls alignment **along the cross axis** (how items line up top-to-bottom, within their row).

Real-world analogy: think of the row of books on a shelf again. `justify-content` answers "should the books be pushed to the left, spread evenly across the whole shelf, or centered?" `align-items` answers "if the books are different heights, should they all line up along the bottom (like standing on the shelf floor), the top, or the middle?"

**The Implementation:**

Let's briefly experiment by adding `justify-content: space-between` and `align-items: flex-start`, so you can see both properties acting independently:

```css
/* part-4-photo-gallery/css/style.css (update the .gallery rule) */

.gallery {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  justify-content: space-between;
  /* space-between pushes the first item to the far left, last item to the far right, */
  /* and distributes any leftover space evenly BETWEEN items in each row */
  align-items: flex-start;
  /* flex-start aligns each row's items to the TOP of the row -- relevant if */
  /* captions of different lengths make some cards taller than others */
}
```

**The Verification:**

Save and refresh. Since our cards use `flex: 1 1 260px` (they grow to fill space), `justify-content` won't create dramatic visible gaps here — but temporarily change one card's caption text to something much longer (like "This is a very long caption that wraps onto two full lines to test alignment") and refresh. You should see that specific card's box grow slightly taller than its neighbors, while `align-items: flex-start` keeps every card's *top edge* aligned in a straight line across the row, even though their bottom edges no longer match. Revert the caption text back afterward — this was just a diagnostic experiment.

For our actual gallery, `justify-content: flex-start` (the default) combined with our `flex: grow` values already produces the cleanest, most even-looking grid, so let's lock that in as our final choice:

```css
/* part-4-photo-gallery/css/style.css (final .gallery rule for this project) */

.gallery {
  display: flex;
  flex-wrap: wrap;
  gap: 20px;
  justify-content: flex-start;
  align-items: stretch;
  /* stretch (the default) makes every card in a row match the row's TALLEST card's height, */
  /* which keeps our image-card bottoms visually aligned -- generally the cleanest look for a grid */
}
```

**The Verification:**

Save and refresh one more time. You should now have a clean, evenly gapped, left-aligned grid of image cards, wrapping responsively as the window resizes — this is your finished gallery layout.

---

## Step 5: A Special "Featured" Card

**The Target:** Style one specific card to stand out as a "featured" item, using an additional class alongside `.gallery-card`.

**The Concept:** This is our first real demonstration of **combining multiple classes on one element** — recall from Part 2's reference table that classes can be combined (`class="card featured"`). The element gets *all* the styling rules from *both* classes simultaneously — like layering two stickers on the same box: one sticker says "this is a gallery card" (shared, common styling), and a second sticker says "and also, this one is featured" (an addition, layered on top).

**The Implementation:**

```html
<!-- part-4-photo-gallery/index.html (update just the second gallery-card div) -->
<div class="gallery-card featured">
  <img src="images/photo-2.jpg" alt="Photo 2 from my collection" />
  <p class="caption">City Lights</p>
</div>
```

```css
/* part-4-photo-gallery/css/style.css (add this new rule) */

.featured {
  flex: 1 1 400px;
  /* a larger basis width than the standard 260px cards, so it claims more space in its row */
  border: 3px solid #2563eb;
  box-shadow: 0 6px 16px rgba(37, 99, 235, 0.25);
}

.featured .caption {
  color: #2563eb;
  font-weight: bold;
}
```

**The Verification:**

Save and refresh. The "City Lights" card should now appear visibly larger and more prominent than its neighbors — a thicker blue border, a soft blue-tinted shadow, and a bold blue caption — while still participating correctly in the same wrapping flex layout as every other card.

---

## End-of-Part Challenge: A Vertical Column Variant

**Your task:** Beneath the existing gallery, add a small second section titled "Gallery, Stacked" that uses `flex-direction: column` to intentionally arrange the *same six images* in a single vertical column instead — proving you understand that Flexbox's "row" behavior is a default, not a law of nature.

**Reference Solution:**

```html
<!-- Add below the existing </div> that closes .gallery, still inside <main> -->
<h2 class="section-heading">Gallery, Stacked</h2>
<div class="gallery gallery--column">
  <div class="gallery-card">
    <img src="images/photo-1.jpg" alt="Photo 1 from my collection" />
    <p class="caption">Morning Hike</p>
  </div>
  <div class="gallery-card">
    <img src="images/photo-2.jpg" alt="Photo 2 from my collection" />
    <p class="caption">City Lights</p>
  </div>
</div>
<!-- (only 2 sample images shown here for brevity of demonstration; feel free to add all 6) -->
```

```css
/* Additions to css/style.css */

.section-heading {
  text-align: center;
  margin: 40px 0 20px 0;
  color: #111827;
}

.gallery--column {
  flex-direction: column;
  /* overrides the default 'row' -- now items flow top-to-bottom instead of left-to-right */
  align-items: center;
  /* with a column direction, align-items now controls HORIZONTAL centering instead */
  max-width: 400px;
  margin: 0 auto;
}
```

**Verification for the challenge:**

Refresh and scroll down — you should see a second, smaller "Gallery, Stacked" section where the same photo cards now sit in a single centered vertical column, one directly above the next. This proves `flex-direction` is the single switch controlling row-vs-column behavior, and that `justify-content`/`align-items` genuinely swap which axis they each control once that direction flips.

---

## Reference Section: Deep Dive for Part 4

### The Full Flexbox Property Reference

**Container properties** (applied to the parent, i.e., `.gallery`):

| Property | Values Used in This Part | What It Controls |
|---|---|---|
| `display` | `flex` | Activates Flexbox on this element's direct children |
| `flex-direction` | `row` (default), `column` | Which axis is the "main axis": horizontal or vertical |
| `flex-wrap` | `nowrap` (default), `wrap` | Whether items are forced onto one line or allowed to wrap |
| `justify-content` | `flex-start`, `space-between`, `center` | Alignment along the main axis |
| `align-items` | `stretch` (default), `flex-start`, `center` | Alignment along the cross axis |
| `gap` | `20px` | Spacing between items, both rows and columns |

**Item properties** (applied to the children, i.e., `.gallery-card`):

| Property | Values Used in This Part | What It Controls |
|---|---|---|
| `flex` | `1 1 260px` (shorthand for grow, shrink, basis) | How an individual item grows/shrinks relative to its siblings |

### `justify-content` Values, Visualized in Words

- `flex-start` (default): items packed toward the start of the row.
- `flex-end`: items packed toward the end.
- `center`: items bunched together in the middle.
- `space-between`: first/last items pinned to the edges, remaining space distributed *between* items.
- `space-around`: equal space around *each* item (including outer edges, which get "half" gaps).
- `space-evenly`: perfectly equal space everywhere, including outer edges.

### `flex: grow shrink basis`, Unpacked

`flex: 1 1 260px` is shorthand for three separate properties:
- `flex-grow: 1` — "if there's leftover space in the row, this item is willing to expand to help fill it." A value of `0` means "never grow."
- `flex-shrink: 1` — "if the row is too tight, this item is willing to shrink." A value of `0` means "never shrink, even if it causes overflow."
- `flex-basis: 260px` — "before growing or shrinking happens, start by assuming this item wants to be 260px wide."

This is why our `.featured` card, with `flex: 1 1 400px`, claims visibly more space than its `260px`-basis siblings — they're all equally willing to grow or shrink (both have grow/shrink of `1`), but the featured card simply starts from a bigger baseline.

### Common Beginner Mistakes to Watch For

1. **Applying `display: flex` to the wrong element.** It must go on the *parent* (the container), not on the items you want arranged. A common typo is putting `display: flex` on `.gallery-card` instead of `.gallery` — nothing visibly changes because a flex item's own `display` property doesn't affect how its siblings are arranged.
2. **Forgetting `flex-wrap: wrap`** and being confused why items overflow or shrink painfully thin on smaller screens — remember, wrapping is opt-in, not automatic.
3. **Mixing up `justify-content` and `align-items`.** A quick trick: `justify-content` = main axis = (usually) left-right. `align-items` = cross axis = (usually) top-bottom. This flips when you set `flex-direction: column`, exactly as your end-of-part challenge demonstrated.
4. **Using `margin` for gaps between flex items instead of `gap`.** It technically works, but requires careful math to avoid uneven edge spacing (e.g., extra margin on the outermost items). Modern CSS's `gap` property solves this cleanly and is the professional standard today.

---

## What's Next

You now have real, hands-on command of Flexbox — container versus items, wrapping, the two alignment axes, and per-item growth control — plus a reusable card-grid pattern that will resurface in your capstone's Projects page. In Part 5, we shift focus to **navigation and positioning**: you'll build a navbar that sticks to the top of the screen while scrolling, learn the four CSS positioning modes (`static`, `relative`, `absolute`, `fixed`, `sticky`) in a carefully sequenced way so `absolute` versus `relative` doesn't become a confusing tangle, and introduce your first **media query** to collapse the navbar into a mobile-friendly layout at smaller screen widths.
