# Primer 2: Files, Folders, and Paths — The Language Your Computer Uses to Find Things

### Why This Primer Exists

Since Part 0, you've been typing things like `src="images/profile.jpg"` and `href="../part-1-bio-card/index.html"` and trusting they'd work — and mostly, they have. But Appendix C's single most common bug category was broken paths, and the fix always came down to "make the text match the real location exactly." This primer explains **why that's true at all** — what a "path" fundamentally *is* to a computer, so that reasoning about file locations stops being pattern-matching and becomes genuine understanding.

---

## P2.1 — Files and Folders: The Actual Model, Not Just the Icons

**The Concept:** Every file on your computer — an HTML document, a photo, this very tutorial if you saved it — is just a named chunk of stored data, sitting inside a **file system**: a structured, tree-shaped organization scheme your operating system uses to keep track of where everything is. A **folder** (also called a **directory**) is simply a named container that can hold files *and other folders* — which is why you can nest folders inside folders inside folders, exactly as you did back in Part 0.

Analogy: think of your file system as a single giant tree, upside down, with roots at the top. The trunk is your computer's main drive. Branches are folders. Leaves are individual files. Every single item — file or folder — has exactly one "parent" branch it hangs from, and can be reached by a specific, describable route down from the trunk.

**Why this matters:** a "path" is nothing more than **written directions for that route** — a sequence of folder names, separated by slashes, telling the computer exactly which branches to follow to reach a specific leaf.

---

## P2.2 — Absolute Paths: Directions From the Very Top

**The Concept:** An **absolute path** describes a file's location starting from the very root of the file system — the trunk of the tree — with no ambiguity about starting point. On Windows, this typically looks like:

```
C:\Users\Alex\Desktop\build-as-you-learn\part-1-bio-card\index.html
```

On Mac or Linux, it looks like:

```
/Users/alex/Desktop/build-as-you-learn/part-1-bio-card/index.html
```

Every one of these path segments (`Users`, `Alex`, `Desktop`, `build-as-you-learn`, `part-1-bio-card`) is a folder you'd have to open, one inside the next, to physically arrive at `index.html` by clicking through Finder or File Explorer.

**Why we never used these in HTML:** an absolute path baked into your HTML would only work on *your specific computer*, with *your specific username* and *your specific folder structure*. The moment you deployed to GitHub Pages (Appendix D), that exact path wouldn't exist anywhere on GitHub's servers — there is no `C:\Users\Alex\...` there. This is precisely why every `src` and `href` throughout this entire series used a **relative path** instead.

---

## P2.3 — Relative Paths: Directions From "Wherever I Currently Am"

**The Concept:** A **relative path** describes a file's location *relative to the file currently referencing it* — not from the very top of the tree, but from wherever you're already standing. This is the entire reason relative paths survive being moved to a completely different computer (your laptop → GitHub's servers) without needing a single character changed: as long as the *relationship* between files stays the same (the HTML file and its `images` folder remain siblings, for instance), the relative path describing that relationship remains correct, regardless of where the whole structure physically lives.

Analogy: an absolute path is like saying "the coffee shop is at 42 Elm Street, Springfield, Ohio, USA, Earth." A relative path is like saying "it's two blocks down from wherever you're currently standing." The second instruction only works if you actually know your current starting point — but it has a huge advantage: it stays correct even if the *entire city* gets picked up and moved somewhere else, as long as your relative position to the coffee shop doesn't change.

**Three relative path building blocks you've used throughout this series, formalized:**

| Syntax | Meaning | Example From the Series |
|---|---|---|
| `filename.ext` | A file sitting in the *same* folder as the current file | `href="style.css"` (Part 2) |
| `foldername/filename.ext` | A file inside a *subfolder* of the current file's folder | `src="images/profile.jpg"` (Part 1) |
| `../` | "Go **up** one folder level" (to the current folder's parent), before continuing | `href="../part-1-bio-card/index.html"` (Part 3) |

You can chain `../` multiple times (`../../` means "go up two levels") — though in this series's structure, one level up was always sufficient, since every project folder sat as a direct sibling inside `build-as-you-learn/`.

---

## P2.4 — Tracing an Exact Example, Step by Step

**The Concept:** Let's fully trace one real relative path from this series, resolving it the exact way a browser does, one segment at a time — the same reasoning you'd apply anytime Appendix C.1 or C.3 has you double-checking a path.

Recall this line from Part 3's end-of-part challenge:

```html
<!-- Located in: build-as-you-learn/part-3-landing-page/index.html -->
<a href="../part-1-bio-card/index.html" class="cta-button">Learn more about me</a>
```

**Resolving it:**

1. **Start at the location of the file containing this link**: `build-as-you-learn/part-3-landing-page/index.html`. The browser's "current folder" is therefore `build-as-you-learn/part-3-landing-page/`.
2. **Read the first path segment**: `../` — "go up one level." That takes us from `part-3-landing-page/` up to its parent, `build-as-you-learn/`.
3. **Read the next segment**: `part-1-bio-card/` — "now go down into this specific subfolder." That takes us to `build-as-you-learn/part-1-bio-card/`.
4. **Read the final segment**: `index.html` — "the specific file we're looking for, inside that folder."
5. **Final resolved location**: `build-as-you-learn/part-1-bio-card/index.html`.

This is exactly why Appendix C.4 (and Part 3's original verification step) told you to double-check that `part-1-bio-card` and `part-3-landing-page` are **siblings** — folders that share the same immediate parent. If they weren't (say, `part-1-bio-card` was accidentally nested a level deeper), this exact path would resolve to the wrong location, or nowhere at all, producing the `404` you now know how to recognize from Primer 1's status code table.

---

## P2.5 — Why Filenames and Casing Actually Matter

**The Concept:** Recall Appendix C.3's and C.10's warnings about filename casing (`profile.jpg` vs. `Profile.JPG`) and Part 1's insistence on exact filenames. Here's the underlying reason, made explicit: **a file path is compared as literal text**, character by character, against what's actually stored in the file system. There's no "close enough" — to the browser, `profile.jpg` and `Profile.jpg` are two completely different strings of text, exactly as different as `cat` and `dog` would be.

**Why this sometimes "worked anyway" during local development:** Windows and (by default) macOS file systems are commonly **case-insensitive** — they'll forgive a mismatched case and find the file anyway, as a convenience. Most real web servers (including the Linux-based infrastructure behind GitHub Pages) are **case-sensitive** — no such forgiveness. This is precisely why Appendix C.10 called out "works locally, breaks once deployed" as a distinct bug category, and why this series consistently modeled lowercase, hyphenated filenames (`profile-photo.jpg`, `part-1-bio-card`) as a defensive habit from the very first project, rather than a rule introduced only once it caused a problem.

---

## P2.6 — Why the Series Insisted on Consistent Project Structure From Part 0

**The Concept:** Every relative path is fundamentally a *bet* that the relationship between two files won't change. Part 0's insistence on a specific folder structure — every project as a sibling folder inside `build-as-you-learn/`, each with its own `images/` subfolder — wasn't arbitrary tidiness. It was **establishing a fixed, predictable "map"** so that every relative path written throughout the entire series (Part 3's link to Part 1, Part 6's link to Part 2, Part 9's links to nearly everything) could be trusted to keep working, together, as one coherent system.

This is also exactly why Appendix D's deployment section required extra care (D.4) — moving your capstone project into its *own* isolated GitHub repository silently broke the sibling relationship those `../` paths depended on, since the repository itself became the new "top of the tree" as far as the deployed site was concerned. Understanding paths as *relationships*, not just *text you type*, is what makes that whole appendix's troubleshooting make sense as cause-and-effect, rather than a checklist to memorize.

---

## Quick Reference: Path Syntax Cheat Sheet

| You Want To... | Syntax | Example |
|---|---|---|
| Reference a file in the same folder | `filename.ext` | `style.css` |
| Reference a file in a subfolder | `subfolder/filename.ext` | `images/profile.jpg` |
| Go up one folder level | `../` | `../part-1-bio-card/index.html` |
| Go up two folder levels | `../../` | `../../some-other-project/index.html` |
| Reference the site's absolute root (used sparingly; not used in this series) | `/filename.ext` | `/favicon.ico` |

---

## What This Unlocks Going Forward

Every "why did my image break" or "why did my link 404" moment from Appendix C now has a genuine mechanical explanation: a relative path is a *relationship* between two specific files, resolved as literal, case-sensitive text, one folder-step at a time. When you restructure a project, add a new page, or deploy to a new host, you now know exactly what question to ask: *"has the relationship between these two files changed?"* — rather than treating a broken link as a mysterious, one-off failure.
