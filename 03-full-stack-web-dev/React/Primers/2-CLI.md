# Primer 2: Command Line Crash Course

## Why this primer exists

Starting in Phase 1, Part 1, this series asks you to open a "terminal" and type commands like `npm run dev`. If you've only ever used computers by clicking icons, this can feel intimidating — like being handed a car with no dashboard, just a blank black screen waiting for... something. This primer removes that intimidation entirely. By the end, you'll understand exactly what a terminal is, how to move around your computer's folders using only text, and how to read and recover from the inevitable typo, before this series ever asks you to use one for real.

---

## 1. What a terminal actually is

Every computer you've ever used has two ways to give it instructions: **pointing and clicking** (the graphical interface you're used to — icons, windows, buttons), and **typing commands** (a purely text-based interface). A **terminal** (also called a **command line**, **console**, or **shell**) is simply a window where you type instructions directly, as text, and the computer executes them and prints the result back as text.

Think of the difference this way: clicking a folder icon to open it is like pointing at a restaurant menu item and having a waiter bring it to you. Typing a command is like calling the kitchen directly and saying exactly what you want, in a precise, expected phrasing. It feels less friendly at first, but it's dramatically faster once you know the phrasing, and — crucially for this series — it's the only way to run the development tools (like Vite, from Phase 1) that power modern web development. There's no icon to double-click for "start my React app's live-reloading development server"; you type `npm run dev`, and the terminal does it.

### Opening a terminal on your operating system

* **Windows:** Press the Start button, type `Command Prompt` or `PowerShell`, and press Enter. (This series' instructions work with either; PowerShell is the more modern default on current Windows versions.)
* **macOS:** Press `Cmd + Space` to open Spotlight search, type `Terminal`, and press Enter.
* **Linux:** Varies by desktop environment, but commonly `Ctrl + Alt + T`, or search your applications menu for "Terminal."

Once open, you'll see a **prompt** — a line, often ending in `$`, `%`, or `>`, followed by a blinking cursor, waiting for you to type something.

---

## 2. The most important concept: "where am I?"

Every terminal is always "located" inside one specific folder on your computer at any given moment — exactly like how, in a file explorer window, you're always looking inside one specific folder, even if you can't currently see the ones above or below it. This current location is called your **working directory**.

**"Directory" is simply the command-line word for "folder."** They mean exactly the same thing — you'll hear both terms used interchangeably throughout this series and in the wider programming world.

### Checking your current location

| Command | Operating System | What it does |
|---|---|---|
| `pwd` | macOS / Linux | Prints the full path of your current folder ("**p**rint **w**orking **d**irectory") |
| `cd` (with no arguments) | Windows | Prints your current folder |

Try it right now: open a terminal and run the appropriate command above. You'll see something like:

```
/Users/yourname
```

on macOS/Linux, or:

```
C:\Users\yourname
```

on Windows. This is where your terminal currently "is" — almost always your **home folder** when you first open a terminal, the same folder your file explorer's sidebar usually calls "Home" or shows your username for.

---

## 3. Moving around: `cd`, `ls`/`dir`

### `cd` — Change Directory

This is the command you'll use constantly throughout this series, starting the moment you scaffold your project in Phase 1: `cd` moves your terminal's current location into a different folder.

```bash
cd Documents
```

This moves you *into* a folder named `Documents`, assuming one exists directly inside your current location. Note: this only works if `Documents` is directly inside the folder you're currently in — you can't `cd` into a folder that isn't visible from where you currently are (we'll cover paths that skip levels shortly).

```bash
cd task-habit-tracker
```

This is the exact command Phase 1, Part 1 asks you to run, right after creating your project — moving your terminal *into* the newly created project folder, so every subsequent command (`npm install`, `npm run dev`) runs in the correct place.

**Going back up a level:**

```bash
cd ..
```

`..` is special shorthand meaning "the folder that contains this one" (the **parent folder**). Running `cd ..` moves you one level up, exactly like clicking the "back" or "up" arrow in a file explorer.

**Jumping straight home, from anywhere:**

```bash
cd ~
```

`~` (tilde) is shorthand for your home folder, no matter where you currently are. This is a useful "reset button" if you ever get lost.

**Jumping multiple levels in one command, using a full path:**

```bash
cd Documents/Code/task-habit-tracker
```

Separating folder names with `/` (macOS/Linux) or `\` (Windows) lets you specify a path through multiple nested folders in a single command, rather than running `cd` repeatedly.

### `ls` / `dir` — listing what's actually in your current folder

Before you can `cd` into something, it helps to see what's actually there.

| Command | Operating System | What it does |
|---|---|---|
| `ls` | macOS / Linux | Lists files and folders in the current directory |
| `dir` | Windows | Lists files and folders in the current directory |

Try running this right now, in your home folder, on whichever system you're using. You'll see a list of names — some are files, some are folders (subfolders are sometimes shown in a different color or with a trailing `/`, depending on your terminal's settings).

---

## 4. Creating things: `mkdir`, and the commands this series uses constantly

You'll see these exact commands recur throughout the series (for example, `mkdir src/components` in Phase 1, Part 2, or `mkdir -p api/habits api/tasks` in Phase 9, Part 2):

| Command | What it does |
|---|---|
| `mkdir foldername` | **M**a**k**es a new **dir**ectory (folder) named `foldername` inside your current location |
| `mkdir -p a/b/c` | Creates nested folders in one step — the `-p` flag tells it to create any missing parent folders along the way too, rather than failing if `a/b` doesn't already exist |

**Removing files** (used a handful of times in this series, to clean up default scaffolded files or temporary experiment files):

| Command | Operating System | What it does |
|---|---|---|
| `rm filename` | macOS / Linux | Deletes the specified file |
| `del filename` | Windows (Command Prompt) | Deletes the specified file |
| `rm -rf foldername` | macOS / Linux | Deletes an entire folder and everything inside it — **use with real caution**, this does not ask "are you sure?" and does not go to a recycle bin |

> ⚠️ A word of genuine caution, worth internalizing early: unlike deleting a file in a graphical file explorer, terminal deletions are typically **immediate and permanent** — there's no Recycle Bin/Trash safety net by default. Always double-check the exact filename/folder name before pressing Enter on a `rm` or `del` command.

---

## 5. Reading and recovering from mistakes

Typos in the terminal are completely normal and expected — every developer makes them constantly, including throughout the writing of this very series. Learning to read the terminal's response calmly is a genuinely important skill.

**If you mistype a command name entirely:**

```
$ nppm run dev
zsh: command not found: nppm
```

This means the terminal has no idea what `nppm` is (because you meant `npm`). This is not a crash or a broken computer — it's simply the terminal telling you, plainly, "I don't recognize that word." Check your spelling and try again.

**If you try to `cd` into something that doesn't exist:**

```
$ cd Dcouments
cd: no such file or directory: Dcouments
```

Again — not a broken system, just a precise, accurate report: nothing by that exact name (note the typo — `Dcouments` instead of `Documents`) exists in your current location. Run `ls`/`dir` to double check the exact, correct spelling of what's actually there, and try again.

**If a command seems to hang, doing nothing:**

Many of the tools in this series (`npm run dev`, `npm run server`, `npm test` in watch mode) are designed to **keep running indefinitely** — they aren't frozen; they're actively waiting, watching for file changes, ready to respond instantly. This is completely normal and expected — you'll intentionally leave several of these running simultaneously, in separate terminal tabs, throughout Phases 4 onward. To stop one of these long-running commands and get your prompt back, press:

```
Ctrl + C
```

(On some systems, this is written as `⌃C`; it works identically on Windows, macOS, and Linux terminals.) This is one of the single most useful things to know before starting this series — you will press this exact key combination many times throughout Phases 4–9.

---

## 6. Copy-pasting commands from this series safely

Every command in this series is written to be copied exactly as shown, and pasted directly into your terminal. A few practical notes:

* **Pasting into a terminal** usually works with the normal `Ctrl+V` (Windows/Linux) or `Cmd+V` (macOS) shortcut, though some older Windows terminal configurations instead use right-click to paste — if `Ctrl+V` doesn't seem to work, try right-clicking inside the terminal window.
* **After pasting, you still need to press Enter** to actually run the command — pasting only places the text at the prompt; it doesn't execute it automatically.
* **One command per line.** If you paste a multi-line block that's meant to be run as several separate commands (as several examples in this series show), make sure each line actually executes (often automatically, if your terminal treats each newline as an Enter press) — if a whole block appears to paste but nothing happens, try running each line individually instead.

---

## 7. Multiple terminals at once

Starting in Phase 4, this series routinely asks you to have **more than one terminal open simultaneously** — for instance, one running `npm run dev` (the frontend) and another running `npm run server` (the backend), both at the same time, both left running. This is completely normal, and something worth setting up comfortably *before* you reach that phase:

* Most terminal applications (and VS Code's built-in terminal, covered in the next primer) support **tabs**, exactly like a web browser — look for a "+" button or a keyboard shortcut like `Ctrl+Shift+T` / `Cmd+T` to open a new one.
* Each tab is its own, independent terminal session, with its own "current location," and can run its own long-lived command without interfering with the others.
* A helpful mental model going forward: **one tab per long-running process.** By Phase 8 of this series, it's common to have three tabs open simultaneously: one for `npm run dev`, one for `npm run server`, and one free for one-off commands like `npm test` or `git` commands.

---

## Quick-reference summary

| Command | Meaning |
|---|---|
| `pwd` (Mac/Linux) / `cd` (Windows, no args) | Show current folder |
| `cd foldername` | Move into a folder |
| `cd ..` | Move up one level |
| `cd ~` | Jump to your home folder |
| `ls` (Mac/Linux) / `dir` (Windows) | List what's in the current folder |
| `mkdir foldername` | Create a new folder |
| `mkdir -p a/b/c` | Create nested folders in one step |
| `rm filename` (Mac/Linux) / `del filename` (Windows) | Delete a file |
| `Ctrl + C` | Stop a currently running command |

---

With this foundation, every terminal instruction in Phase 1 onward will make sense as a specific, readable instruction — not an incantation. You now know what a "working directory" is, how to move into the project folder this series will have you create, how to safely stop a long-running dev server, and what to do (calmly) when you inevitably mistype something.
