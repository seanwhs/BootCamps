# Primer 4: Color, Units, and Measurement — Hex Codes, RGB, and px/em/rem Demystified

### Why This Primer Exists

Since Part 1, you've been typing values like `#2563eb`, `rgba(0, 0, 0, 0.15)`, `16px`, and `2rem` — and trusting they worked, without ever stopping to ask *what these values actually represent to a computer.* This primer answers that directly: how color is actually encoded as data, and what each CSS measurement unit is truly measuring *relative to*. Once these click, you'll be able to look at any color code or size value in this series (or any CSS you encounter afterward) and know exactly what it means, rather than pattern-matching against examples you've memorized.

---

## P4.1 — How Computers Actually Represent Color

**The Concept:** A computer screen is made of millions of tiny individual light sources called **pixels**, and every single pixel produces color by mixing exactly three colors of light: **red, green, and blue** — this is why you'll constantly see the abbreviation **RGB**. Each of those three colors can be dialed to a specific *intensity*, and mixing different intensities of red, green, and blue light together produces every color your screen can display.

Analogy: think of three stage spotlights — one red, one green, one blue — all aimed at the same spot on a wall, each with its own dimmer switch. Turn all three all the way up, and you get white light. Turn all three all the way down, and you get black (no light at all). Turn up only the red dimmer, and you get pure red. Somewhere in between, you get every other color imaginable — that's genuinely, physically, exactly how your monitor works, at the level of each individual pixel.

**Why this matters for CSS:** every color value you've ever written in this series — hex codes, `rgb()`, `rgba()` — is fundamentally just **three numbers, specifying the intensity of red, green, and blue light**, expressed in different notations.

---

## P4.2 — RGB Notation: The Most Direct Representation

**The Concept:** `rgb()` notation writes those three intensities out directly, as plain numbers from `0` (completely off) to `255` (completely maxed out) — `255` being the highest value a single byte of computer memory can conveniently represent, which is why this specific range was chosen decades ago and has stuck ever since.

**The Implementation, as a direct experiment:**

```css
/* Pure red: red fully on, green and blue fully off */
.swatch-red {
  background-color: rgb(255, 0, 0);
}

/* Pure green */
.swatch-green {
  background-color: rgb(0, 255, 0);
}

/* Pure blue */
.swatch-blue {
  background-color: rgb(0, 0, 255);
}

/* All three fully on = white */
.swatch-white {
  background-color: rgb(255, 255, 255);
}

/* All three fully off = black */
.swatch-black {
  background-color: rgb(0, 0, 0);
}

/* Equal parts red and green, no blue = yellow */
.swatch-yellow {
  background-color: rgb(255, 255, 0);
}
```

**The Verification:** Create a quick throwaway HTML file with six `<div>`s, one per class above, each given `width: 100px; height: 100px;`, and open it in your browser. You should see red, green, blue, white, black, and yellow squares — directly, visually confirming that these three numbers are genuinely just dimmer-switch settings for red, green, and blue light, exactly as described.

---

## P4.3 — Hex Codes: The Same Three Numbers, Just Written Differently

**The Concept:** A **hex code** (like `#2563eb`, used constantly throughout this series starting in Part 1) is simply **the exact same red/green/blue information as `rgb()`**, just written using a different counting system — **hexadecimal** (base 16) instead of the decimal (base 10) numbers you're used to.

Here's the piece that makes it click: our normal counting system (decimal) only has ten digits — `0` through `9` — before we have to start combining digits together (`10`, `11`, etc.). Hexadecimal has **sixteen** digits available at each position, so after `9`, it keeps going: `A`, `B`, `C`, `D`, `E`, `F` represent `10` through `15`. This means a *single pair* of hex digits (like `2b`) can represent any value from `0` to `255` — the exact same range `rgb()` uses — using only two characters instead of up to three.

A hex color code breaks into exactly three pairs, in the same red-green-blue order as `rgb()`:

```
 #  25    63    eb
    └─┬─┘ └─┬─┘ └─┬─┘
     red  green  blue
```

- `25` in hex = `37` in decimal (red intensity: fairly low)
- `63` in hex = `99` in decimal (green intensity: moderate)
- `eb` in hex = `235` in decimal (blue intensity: very high)

So `#2563eb` and `rgb(37, 99, 235)` are **exactly, literally the same color** — just two different notations for identical underlying red/green/blue intensities. This is directly verifiable: open DevTools (Appendix A) on any project, click an element with a background or text color, and in the Styles pane, click the small colored swatch next to the value — most browsers let you toggle between hex and `rgb()` notation right there, showing you the same color, freely convertible between both forms.

**Why hex codes are so common in professional CSS despite `rgb()` being more "readable":** they're shorter to type, and design tools (like Figma or Photoshop) conventionally display and export colors in hex format, making it the natural copy-paste bridge between a designer's color palette and your CSS.

---

## P4.4 — Alpha Transparency: The Fourth Number

**The Concept:** Recall `rgba(0, 0, 0, 0.15)` from Part 7's box-shadows and Part 8's focus rings. The fourth value — **alpha** — controls transparency, on a scale from `0` (completely invisible) to `1` (completely solid/opaque). Analogy: think of alpha as how much you've diluted a paint color with water — `1` is full-strength, undiluted paint; `0.15` is mostly water, with just a faint tint of color remaining; `0` is pure water, no pigment at all.

**Why this specific pattern showed up constantly in shadows and glows throughout the series:**

```css
/* Part 7 -- a soft, subtle shadow */
box-shadow: 0 16px 32px rgba(0, 0, 0, 0.15);

/* Part 8 -- a soft, subtle focus glow */
box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
```

A shadow or glow effect needs to *blend* softly with whatever's behind it, rather than sitting as a harsh, solid block of color — which is exactly what a low alpha value (`0.15`, meaning "85% see-through") accomplishes. A solid, fully-opaque black shadow (`rgba(0, 0, 0, 1)`) would look like a harsh black smear rather than a soft, natural-looking shadow.

---

## P4.5 — Absolute Units: `px`, the Fixed Ruler

**The Concept:** A **pixel (`px`)** is the most fundamental, literal unit in CSS — it refers directly to actual physical pixels on the display (roughly; modern high-resolution screens do some internal scaling, but conceptually, treat `px` as "an exact, fixed-size measurement that never changes based on context"). Analogy: `px` is like specifying a measurement in exact centimeters with a rigid ruler — `20px` means the same physical size everywhere you use it, regardless of what element it's applied to or what its parent looks like.

**Why this matters for how you reason about your own CSS:** every `px` value in this series (`padding: 32px`, `border-radius: 8px`) is an **absolute, non-relative** measurement — it doesn't scale up or down based on anything else on the page. This is exactly why it's a perfectly reasonable, predictable default for borders, shadows, and small fixed spacing — but, as you'll see next, it's the *wrong* tool for text sizing on a genuinely accessible, flexible site.

---

## P4.6 — Relative Units: `em` and `rem`, and Why They Exist At All

**The Concept:** Unlike `px`, `rem` (introduced in Part 2, used for `font-size` throughout) is a **relative unit** — its actual size *depends on* another value, rather than being fixed. Specifically:

- **`rem`** ("root em") is always relative to the **root element's font size** — the `<html>` tag's font size, which defaults to `16px` in virtually every browser unless you explicitly change it. So `2rem` always means "2 × the root font size" — by default, `32px` — **no matter where in your page's nesting it's used.**
- **`em`** is relative to the **current element's own parent's font size** instead — meaning its actual pixel value can change depending on how deeply nested it is, since each nested `em` compounds on top of its parent's `em`-derived size. This compounding behavior is powerful in specific scenarios but can also cause confusing, hard-to-predict sizing in deeply nested structures — which is exactly why this series consistently chose `rem` over `em` for font sizing, favoring predictability.

**Why relative units matter, concretely, using a real accessibility scenario:** imagine a visually impaired visitor sets their *browser's* default font size larger, in their own settings, specifically because they find `16px` text too small to read comfortably. If your entire site used fixed `px` values for every font size, **nothing on your page would respond to that preference at all** — you'd have effectively overridden their accessibility setting, silently. Because `rem` values are calculated *relative to* the root font size, when a user increases their browser's base font size, **every single `rem`-based measurement on your page scales up proportionally, automatically** — headings, body text, even padding and spacing if you'd used `rem` there too — without you writing a single additional line of code.

**The Implementation, as a direct experiment:**

```css
/* If the root font-size is the default 16px: */
h1 {
  font-size: 2rem; /* renders as 32px (2 × 16px) */
}

p {
  font-size: 1rem; /* renders as 16px (1 × 16px, i.e., unchanged) */
}
```

**The Verification:** Open your Part 1 bio card. In your browser's settings, find the font size preference (in Chrome: Settings → Appearance → Font size; try "Very Large") and refresh the page. Your `h1` and `p` text (styled in `rem` back in Part 1) should visibly grow larger, proportionally — a direct, hands-on demonstration of exactly the accessibility behavior just described. Compare this against re-checking any element you might have accidentally sized using raw `px` for font-size — it would stay exactly the same size, unaffected by that same browser setting.

---

## P4.7 — `%` and `vh`/`vw`: Relative to a Different Kind of Parent

**The Concept:** Two more relative units you've used, each relative to something slightly different from `rem`/`em`:

- **`%`** is relative to the corresponding dimension of the element's own **parent container**. `width: 100%` (used constantly for images throughout this series) means "exactly as wide as my parent's content area" — if the parent resizes, the child resizes proportionally, automatically.
- **`vh`/`vw`** ("viewport height/width," introduced in Part 7's `.page-wrap`) are relative to the **entire browser window's** visible dimensions, regardless of any parent element. `min-height: 100vh` means "at least as tall as the full visible browser window," which is precisely why it was the right tool for vertically centering a single card on the page in Part 7 and Part 8 — no parent element needed to already have a defined height for this to work, since it bypasses the parent chain entirely and refers directly to the browser window itself.

---

## Quick Reference: Every Unit and Notation From This Series, Compared

| Notation/Unit | Relative To | Typical Use in This Series |
|---|---|---|
| `rgb(r, g, b)` | Absolute (0–255 per channel) | Understanding/debugging colors in DevTools |
| `#rrggbb` (hex) | Absolute — same values as `rgb()`, different notation | Nearly every color value throughout the series |
| `rgba(r, g, b, a)` | Absolute color + relative transparency (0–1) | Shadows, glows, subtle overlays |
| `px` | Nothing — a fixed, literal measurement | Borders, shadows, fixed small spacing |
| `rem` | The root (`<html>`) element's font size | Font sizes, and often spacing, for accessibility-friendly scaling |
| `em` | The current element's parent's font size (compounds when nested) | Rarely used deliberately in this series, in favor of `rem`'s predictability |
| `%` | The element's own parent's corresponding dimension | Image widths, flexible box sizing |
| `vh` / `vw` | The entire browser viewport's height/width | Full-screen vertical centering (Parts 7–8) |

---

## What This Unlocks Going Forward

Every color code and every measurement you write from now on can be reasoned about precisely, rather than copy-pasted on faith: a hex code is just RGB intensities in a more compact notation, alpha values are a dilution/transparency control, `px` is a fixed ruler, and `rem` deliberately scales *with* your users' own accessibility preferences rather than ignoring them. That last point especially — the `rem`-vs-`px` accessibility distinction — is exactly the kind of "beginner-friendly outside, expert inside" judgment call this entire series has modeled from Part 1 onward, now fully explained rather than simply demonstrated.
