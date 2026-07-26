# Primer 5: Just Enough Command Line to Get By

### Why This Primer Exists

Appendix D asked you to open a terminal and type commands like `git init` and `git push -u origin main` — trusting you'd copy them correctly without necessarily understanding *what a terminal even is*, or what was happening when you pressed Enter. This primer fills that gap directly: what the command line fundamentally is, how to navigate your file system with it (directly connecting back to Primer 2's paths), and precisely what each Git command from Appendix D actually does — so that deployment stops being "a magic incantation that worked" and becomes a sequence of understood steps.

---

## P5.1 — What a Terminal Actually Is

**The Concept:** Every interaction you've had with your computer so far in this series has been through a **GUI** (Graphical User Interface) — icons, windows, buttons you click with a mouse. A **terminal** (also called a **command line** or **shell**) is an alternate way of controlling your computer entirely through **typed text commands** instead of clicks.

Analogy: think of a GUI as ordering food by pointing at pictures on a menu board. A terminal is like calling in your order verbally, using precise, specific words the kitchen has been trained to understand exactly. Neither is "better" universally — pointing is faster for browsing options you don't know the names of; speaking precisely is faster once you already know exactly what you want, and it's far easier to write down and repeat exactly (which is precisely why deployment workflows, and much of professional software development generally, rely on typed commands rather than clicking).

**Why this matters for you specifically:** Live Server (Part 0) and GitHub's website (Appendix D.3, steps 1 and 3) are GUI tools — you clicked through them. But *uploading* your files in Appendix D.3, step 2, required the terminal, because Git — the version control tool underneath GitHub — is fundamentally a command-line program at its core (GitHub Desktop and similar GUI wrappers exist, but understanding the actual typed commands is what this primer is for, and what Appendix D used directly).

---

## P5.2 — Opening a Terminal

**The Implementation:**

- **Windows:** Search for "Git Bash" in your Start menu (installed automatically alongside Git, per Appendix D.2) — this is the friendliest option for following Git commands exactly as written in this series, since it behaves consistently with Mac/Linux syntax. Alternatively, "Command Prompt" or "PowerShell" are built in, but use slightly different syntax for some non-Git commands.
- **Mac:** Open "Terminal" via Spotlight search (`Cmd+Space`, then type "Terminal").
- **VS Code (any OS):** Every project you've built already opens in VS Code — and VS Code has a built-in terminal panel, reachable via **Terminal → New Terminal** in the top menu, or the shortcut `` Ctrl+` ``. This is genuinely the most convenient option throughout this series, since it opens already located inside whatever project folder you have open — no navigation required at all.

**The Verification:** Open VS Code, open your `build-as-you-learn` folder (as you've had open since Part 0), and press `` Ctrl+` ``. A panel should appear at the bottom of the window with a blinking text cursor, ready to accept typed commands — this is your terminal, already correctly positioned inside your project.

---

## P5.3 — The Core Idea: You're Always "Standing" Somewhere

**The Concept:** This is the single most important mental model for the terminal, and it connects directly back to Primer 2's file system tree: **at every moment, your terminal is "standing" inside one specific folder** — called your **current working directory** — exactly the same concept as "the folder currently open in File Explorer/Finder," just without a visible window showing you where that is. Every command you type either asks a question about *this current folder*, or moves you to a *different* folder to stand in instead.

**The Implementation — seeing your current location:**

```bash
pwd
```

*(`pwd` stands for "print working directory" — it simply asks the terminal "where am I currently standing?" and prints the absolute path, exactly the kind of path described in Primer 2.2.)*

**The Verification:** Run this in your VS Code terminal (opened with `build-as-you-learn` as your workspace). You should see output like:

```
/Users/alex/Desktop/build-as-you-learn
```

or, on Windows:

```
C:\Users\Alex\Desktop\build-as-you-learn
```

This confirms the terminal is currently "standing" exactly inside your main project folder — precisely why Appendix D's `cd build-as-you-learn/my-portfolio` command (next section) made sense as a *relative* move from here.

---

## P5.4 — Moving Around: `cd`

**The Concept:** `cd` ("change directory") moves your terminal's current standing position to a different folder — the typed-command equivalent of double-clicking a folder in File Explorer to open it. Crucially, `cd` accepts **relative paths**, using exactly the same syntax you learned in Primer 2 for HTML: a folder name to go *into* a subfolder, or `..` to go *up* one level (note: no trailing slash needed here, unlike HTML's `../`).

**The Implementation:**

```bash
cd my-portfolio
```
*(Moves from `build-as-you-learn` down into `build-as-you-learn/my-portfolio` — exactly the relative-path reasoning from Primer 2.4, just executed by a command instead of resolved by a browser.)*

```bash
cd ..
```
*(Moves back up one level, from `my-portfolio` back to `build-as-you-learn` — directly parallel to HTML's `../`.)*

```bash
cd part-4-photo-gallery
```
*(From `build-as-you-learn`, moves into a sibling project folder — exactly the same sibling relationship Primer 2.6 discussed.)*

**The Verification:** After each `cd` command, run `pwd` again — confirm the printed path actually changed to reflect where you expected to move. This pairing (`cd` to move, `pwd` to confirm) is the exact habit that makes terminal navigation feel safe rather than disorienting — you can always ask "where am I, actually?"

---

## P5.5 — Seeing What's Around You: `ls`

**The Concept:** `ls` ("list") shows you every file and folder inside your current working directory — the typed equivalent of simply looking at what's visible inside an open File Explorer/Finder window.

**The Implementation:**

```bash
ls
```

**The Verification:** Run this while standing inside `build-as-you-learn`. You should see a listing of every project folder from this series:

```
part-1-bio-card    part-4-photo-gallery    part-7-product-card
part-2-recipe-page  part-5-navbar          part-8-contact-form
part-3-landing-page  part-6-blog-layout    my-portfolio
```

*(On Windows Command Prompt specifically, the equivalent command is `dir` instead of `ls` — Git Bash, however, supports `ls` directly, which is another reason it's the recommended terminal for this series.)*

---

## P5.6 — Now, Rereading Appendix D's Git Commands With Real Understanding

**The Concept:** With `pwd`, `cd`, and `ls` established, let's revisit Appendix D.3's exact deployment sequence and genuinely explain each line — no longer just "copy this," but "here's precisely what's happening."

```bash
cd build-as-you-learn/my-portfolio
```
You now know exactly what this does: moves your terminal's standing position from wherever it currently is, down into your capstone project's folder — chaining two folder-steps in one command, exactly like a multi-segment relative path from Primer 2.

```bash
git init
```
This tells Git: "start tracking changes in *this current folder* from now on." It creates a hidden `.git` subfolder right here — invisible in normal file browsing, but present in your `ls` output if you add the `-a` flag (`ls -a`, which shows hidden files too) — which is where Git actually stores its entire history of tracked snapshots.

```bash
git add .
```
Recall Primer 3's key-value/command patterns: `git add` is the command, and `.` is an argument telling it *which* files to act on. In most shells, `.` conventionally means "the current folder, and everything inside it" — so this stages every single file inside `my-portfolio/` (all your HTML files, your `css/` folder, your `images/` folder) as things you intend to include in your next saved snapshot.

```bash
git commit -m "Initial capstone portfolio upload"
```
This actually creates the snapshot (a "commit"), permanently recording the current state of every staged file. The `-m` is a **flag** — a special argument prefixed with a dash that modifies how a command behaves — here, telling `commit` "the message describing this snapshot follows directly after this flag."

```bash
git branch -M main
```
Names your primary timeline of snapshots `main` — the `-M` flag specifically means "rename it to this, even if it already has some other default name" (older Git installations used `master` as a default; this command standardizes it).

```bash
git remote add origin https://github.com/YOUR-USERNAME/my-portfolio.git
```
This is a **key-value-style pairing** in spirit (Primer 3.3): it tells your local Git project "here's a nickname (`origin`) for a specific remote URL" — establishing a link between your local snapshots and an empty repository already waiting on GitHub's servers.

```bash
git push -u origin main
```
This is the actual upload step: "take my local `main` timeline of snapshots and send it to the remote named `origin`." This is the exact same request/response cycle from Primer 1 — your terminal, acting as a client, sends your files as data to GitHub's servers, which respond by storing them and (per Appendix D.3, step 3) making them available for GitHub Pages to serve to the world.

---

## P5.7 — A Few More Genuinely Useful Everyday Commands

**The Concept:** Beyond Git specifically, these commands round out enough terminal literacy to feel generally comfortable, without needing to memorize dozens more you won't use in this series.

```bash
mkdir new-folder-name
```
*("make directory")* — creates a new folder, the typed equivalent of right-click → New Folder, used identically to how you built every project's structure back in Part 0, just as an alternative to clicking.

```bash
clear
```
Wipes the visible terminal history from view (purely cosmetic — doesn't undo anything, doesn't affect your files, just cleans up visual clutter on your screen).

```bash
git status
```
Genuinely one of the most useful commands to run constantly — it reports which files have changed since your last commit, and whether they've been staged (via `git add`) yet. Running this liberally, anytime you're unsure "what state is my project actually in right now," is a strong habit to build.

---

## Quick Reference: Command Line Cheat Sheet

| Command | Plain-English Meaning |
|---|---|
| `pwd` | "Where am I currently standing?" |
| `cd foldername` | "Move into this subfolder." |
| `cd ..` | "Move up one folder level." |
| `ls` (or `dir` on Windows Command Prompt) | "What's inside my current folder?" |
| `mkdir foldername` | "Create a new folder here." |
| `git init` | "Start tracking this folder's changes." |
| `git add .` | "Stage every file for the next snapshot." |
| `git commit -m "message"` | "Save a permanent snapshot, with this description." |
| `git remote add origin <url>` | "Link this project to a remote location, nicknamed 'origin'." |
| `git push -u origin main` | "Upload my snapshots to that remote location." |
| `git status` | "What's the current state of my tracked files?" |

---

## What This Unlocks Going Forward

Appendix D's deployment steps are no longer a memorized ritual — you now understand that `cd` moves you using the exact same relative-path logic as your HTML links (Primer 2), that `git add`/`commit`/`push` are just staging, saving, and uploading a snapshot in sequence, and that the actual upload is the same client-server request/response cycle underlying everything in Primer 1. Any future terminal command you encounter — in a JavaScript tutorial, a build tool's setup instructions, or anywhere else in your development path from Appendix E — can now be approached the same way: identify the command, identify its arguments/flags, and reason about what it's actually doing, rather than typing it on faith.
