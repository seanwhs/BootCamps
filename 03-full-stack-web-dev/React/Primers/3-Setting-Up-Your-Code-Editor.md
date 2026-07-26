# Primer 3: Setting Up Your Code Editor

## Why this primer exists

Every file this series creates — from a two-line `App.jsx` in Phase 1 to a full production build configuration in Phase 9 — needs somewhere to be written and edited. That "somewhere" is a **code editor**: a text editor purpose-built for writing code, with features a general word processor doesn't have. This primer walks through installing the editor this series assumes you're using (VS Code), configuring the handful of settings that make following along dramatically smoother, and installing the small set of extensions that catch mistakes before you even run your code. By the end, your editor will be genuinely ready for Phase 1, Part 1.

---

## 1. What a code editor actually is, and why not just use Notepad

Technically, you *could* write every file in this series using something as basic as Windows Notepad or macOS TextEdit — code is, after all, just text. But a dedicated code editor adds capabilities that make an enormous practical difference once files start reaching dozens or hundreds of lines:

* **Syntax highlighting** — coloring different parts of your code (keywords, strings, comments) differently, so structure is visible at a glance rather than requiring you to read every character.
* **Error/warning squiggles** — red or yellow underlines appearing *while you type*, flagging likely mistakes before you ever run the code (a typo'd variable name, a missing closing brace).
* **Autocomplete** — suggesting the rest of a word, function name, or even an entire snippet as you type, both saving time and reducing typos.
* **Integrated terminal** — a terminal window built directly into the editor itself, so you never need to Alt-Tab between a separate terminal application and your code (genuinely useful starting in Phase 1, Part 1, and essential once Phase 4 has you juggling multiple simultaneous terminal tabs, as covered in Primer 2).
* **File tree / project explorer** — a sidebar showing your entire project's folder structure, letting you click between files instantly — critical once your project grows to the dozens of files this series builds by Phase 6 onward.

This series is written assuming **Visual Studio Code** (almost universally just called "VS Code") — it's free, extremely widely used in the professional React ecosystem, and has excellent built-in and extendable support for exactly the technologies this series uses (JavaScript, JSX, CSS).

---

## 2. Installing VS Code

1. Go to **[code.visualstudio.com](https://code.visualstudio.com)**.
2. Click the large download button — the site automatically detects your operating system (Windows, macOS, or Linux) and offers the right installer.
3. Run the downloaded installer, accepting the default options.

### ✅ Verifying the install

Open VS Code. You should see a **Welcome** tab with options like "Open Folder..." and "Clone Git Repository...". If you see this, the install succeeded.

A genuinely useful, optional extra step: VS Code can install a `code` command, letting you type `code .` in any terminal to instantly open the current folder in VS Code — this is exactly the shortcut Phase 1, Part 1 mentions when it's time to open your newly created project.

* **On macOS:** Open VS Code, press `Cmd+Shift+P` to open the **Command Palette** (a searchable list of every command VS Code can run), type `shell command`, and select **"Shell Command: Install 'code' command in PATH."**
* **On Windows:** This is typically enabled automatically during installation — look for a checkbox labeled something like "Add to PATH" during setup. If you skipped it, you can re-run the installer and select it.
* **On Linux:** Usually available automatically after installing via your distribution's package manager.

### ✅ The Verification

Open a terminal (per Primer 2), navigate to any folder, and run:

```bash
code .
```

**Expected result:** VS Code opens, showing that folder in its file explorer sidebar. This exact command is what Phase 1, Part 1 uses the moment your project folder is created.

---

## 3. Understanding VS Code's layout

When you first open a folder in VS Code, you'll see several distinct areas — worth knowing the names of, since this series will reference them directly ("open the Explorer sidebar," "check the integrated terminal"):

* **Activity Bar** — the thin, icon-only strip on the far left edge. Clicking each icon switches what the sidebar shows (files, search, source control, extensions, and more).
* **Explorer (sidebar)** — the file tree showing your project's folders and files, usually the default view when you open a folder. This is where you'll click between `App.jsx`, `index.css`, and every other file this series creates.
* **Editor area** — the large central area where an open file's actual contents appear for editing. You can have multiple files open in tabs across the top of this area, exactly like browser tabs.
* **Integrated Terminal** — a terminal panel that can be toggled open/closed at the bottom of the window, running the exact same shell (Command Prompt, PowerShell, zsh, bash) you learned about in Primer 2, just embedded directly in the editor.
* **Status Bar** — the thin strip along the very bottom, showing information like the current file's language mode, line/column position, and (once we install the ESLint extension below) any active linting errors.

### Opening the integrated terminal

Use the keyboard shortcut `` Ctrl+` `` (Windows/Linux) or `` Cmd+` `` (macOS) — that's the backtick key, usually located just above Tab. Alternatively, use the menu: **Terminal → New Terminal**.

### ✅ The Verification

With any folder open in VS Code, press `` Ctrl+` `` (or `` Cmd+` ``). Confirm a terminal panel appears at the bottom of the window, already positioned inside that folder (try running `pwd`/`cd` from Primer 2 to confirm). This is the exact terminal you'll use for every `npm run dev`, `npm run server`, and `npm test` command throughout this series — no separate terminal application ever strictly required, though you're welcome to use one if you prefer.

---

## 4. Installing essential extensions

**Extensions** are add-ons that give VS Code new capabilities beyond what it ships with by default. Click the **Extensions** icon in the Activity Bar (it looks like four small squares, one detached), or press `Ctrl+Shift+X` (Windows/Linux) / `Cmd+Shift+X` (macOS), to open the Extensions view, then search for and install each of the following.

### ESLint (essential)

**Search for:** `ESLint` (published by Microsoft)

Recall from Phase 1, Part 1: our project is scaffolded with `eslint` already included as a dependency, specifically to catch likely mistakes (like Rules of Hooks violations, covered in Phase 2, Part 1) as plain warnings in your terminal. This extension brings those exact same warnings **directly into your editor**, as red/yellow squiggly underlines under the problematic code, the moment you type it — rather than only discovering the issue later when you happen to glance at your terminal output.

### Prettier - Code formatter (strongly recommended)

**Search for:** `Prettier - Code formatter` (published by Prettier)

**Prettier** is an automatic code formatter — it doesn't check your code's *logic* (that's ESLint's job), it simply rewrites your code's *formatting* (indentation, spacing, quote style) to a single, consistent style, automatically, whenever you save a file. This means you never have to manually worry about whether you used two or four spaces of indentation, or single versus double quotes — Prettier makes that decision consistently, every time, for you.

### ES7+ React/Redux/React-Native snippets (optional, but a nice convenience)

**Search for:** `ES7+ React/Redux/React-Native snippets` (published by dsznajder)

This extension provides typing shortcuts (called **snippets**) for common React patterns — for instance, typing `rafce` and pressing Tab can scaffold an entire arrow-function component structure instantly. This series always shows you the **complete, exact code to type or paste** for every file, so this extension is never strictly required to follow along — but it's a popular, genuine time-saver worth knowing about once you're comfortable with the fundamentals and want to move faster.

### ✅ The Verification

After installing ESLint and Prettier, open the Extensions view again and confirm both show an **"Installed"** label (rather than an "Install" button) under their names. We'll do a fuller, functional verification of ESLint specifically once we reach Phase 1, Part 1's actual project — for now, confirming the install succeeded is enough.

---

## 5. Configuring "format on save"

Installing Prettier alone doesn't do anything automatically yet — we need to tell VS Code to actually *run* it every time you save a file. This is a genuinely worthwhile one-time setup, since it means every single file in this series will format itself correctly the moment you save it, without you ever needing to think about it.

1. Open VS Code's **Settings** — press `Ctrl+,` (Windows/Linux) or `Cmd+,` (macOS), or use the menu: **File → Preferences → Settings** (macOS: **Code → Settings → Settings**).
2. In the search box at the top of the Settings tab, type `format on save`.
3. Check the box next to **"Editor: Format On Save."**
4. Search again for `default formatter`.
5. Under **"Editor: Default Formatter,"** select **"Prettier - Code formatter"** from the dropdown.

### ✅ The Verification

Open (or create) any `.js` file, and deliberately type something messily formatted, such as:

```javascript
const x = {a:1,   b:2}
```

Save the file (`Ctrl+S` / `Cmd+S`). **Expected result:** the line should instantly reformat itself to something clean and consistent, such as:

```javascript
const x = { a: 1, b: 2 };
```

If this happens, "format on save" is correctly configured, and you'll benefit from it automatically for every single file across this entire series.

---

## 6. A few individual settings worth adjusting

Search for each of these in the same Settings tab (`Ctrl+,` / `Cmd+,`) and adjust as described. None of these are strictly mandatory, but each one smooths out a small friction point you'd otherwise hit while following this series.

| Setting to search for | Recommended value | Why it helps |
|---|---|---|
| `Editor: Font Size` | `14` or larger (personal preference) | Code should be comfortable to read for long stretches — don't strain your eyes on a default that's too small |
| `Files: Auto Save` | `afterDelay` | Automatically saves your file a moment after you stop typing, so Vite's Hot Module Replacement (Phase 1, Part 1) reflects your changes without you needing to remember to press `Ctrl+S` constantly |
| `Editor: Tab Size` | `2` | Matches the two-space indentation style used throughout every code sample in this series, keeping your files visually consistent with what's shown here |
| `Editor: Bracket Pair Colorization` | Enabled (default in modern VS Code) | Colors matching `{ }`, `( )`, and `[ ]` pairs the same color, making deeply nested JSX (common from Phase 2 onward) much easier to visually parse |

### ✅ The Verification

After enabling `Files: Auto Save`, type something into any open file and simply wait a second or two without pressing `Ctrl+S`. **Expected result:** the small dot/circle indicator on that file's tab (which VS Code shows for unsaved changes) should disappear on its own — confirming the file saved automatically.

---

## 7. A quick tour of essential keyboard shortcuts

You don't need to memorize all of these before starting — they'll become natural through repetition across the series — but having them listed once, up front, is useful:

| Shortcut (Win/Linux) | Shortcut (macOS) | Action |
|---|---|---|
| `Ctrl+S` | `Cmd+S` | Save the current file |
| `Ctrl+P` | `Cmd+P` | Quickly jump to any file in the project by typing part of its name |
| `Ctrl+Shift+P` | `Cmd+Shift+P` | Open the Command Palette (search for any VS Code command by name) |
| `` Ctrl+` `` | `` Cmd+` `` | Toggle the integrated terminal open/closed |
| `Ctrl+F` | `Cmd+F` | Find text within the current file |
| `Ctrl+Shift+F` | `Cmd+Shift+F` | Find text across your **entire project**, all files at once |
| `Ctrl+/` | `Cmd+/` | Comment/uncomment the current line |
| `Ctrl+Z` | `Cmd+Z` | Undo |

The `Ctrl+P` ("Quick Open") shortcut in particular becomes genuinely essential once this series' project reaches the dozens of files it has by Phase 6 — rather than clicking through nested folders in the Explorer sidebar, you can simply press `Ctrl+P`, type a few letters of a filename like `HabitCard`, and jump directly to it.

---

## Quick-reference summary

| Task | How |
|---|---|
| Open a folder in VS Code from the terminal | `code .` |
| Toggle the integrated terminal | `` Ctrl+` `` / `` Cmd+` `` |
| Open the Extensions view | `Ctrl+Shift+X` / `Cmd+Shift+X` |
| Open Settings | `Ctrl+,` / `Cmd+,` |
| Jump to any file by name | `Ctrl+P` / `Cmd+P` |
| Search across the whole project | `Ctrl+Shift+F` / `Cmd+Shift+F` |

---

With ESLint and Prettier installed, format-on-save configured, and the integrated terminal ready to go, your editor is now genuinely set up for everything this series will ask of it — from the very first `App.jsx` in Phase 1, all the way through the dozens of files and multiple simultaneous terminal tabs of Phase 9.
