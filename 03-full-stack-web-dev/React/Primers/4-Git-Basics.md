# Primer 4: Git & Version Control Basics

## Why this primer exists

Phase 9, Part 2 of this series asks you to run commands like `git init`, `git commit`, and `git push` — the entire mechanism Vercel relies on to detect your code and deploy it automatically. Rather than introducing Git for the first time in the series' final stretch, with a deployment deadline looming, this primer builds a calm, solid understanding of what Git actually is and does, well ahead of time — so that by Phase 9, the commands feel familiar rather than like a brand-new subject bolted onto the end of the series.

This primer is also worth adopting **early**, starting right from Phase 1 — saving a "snapshot" of your project after each part is a genuinely good habit, and gives you something Primer 2's terminal skills alone can't: the ability to undo a mistake by going back in time.

---

## 1. The problem Git solves

Imagine writing a long essay in a single document, with no way to undo past a certain point, and no way to see what it looked like an hour ago. If you delete a paragraph by mistake and don't notice for a while, it's simply gone. Now imagine two people trying to write that same essay together, at the same time, without stepping on each other's changes.

**Git** is a **version control system** — a tool that solves both of these problems for code. It keeps a complete, permanent history of every change ever made to a project, lets you "rewind" to any previous point, and lets multiple people (or multiple versions of yourself, working on different features) work on the same project without overwriting each other's work by accident.

Think of Git like the "track changes" and "version history" features you may have seen in Google Docs or Microsoft Word — except far more powerful, working across an entire project's worth of files at once, and fundamentally built for code specifically.

A useful distinction worth being precise about, since the two terms get used almost interchangeably in casual conversation:

* **Git** is the actual tool/software that tracks changes — it runs entirely on your own computer, and doesn't require the internet at all for its core functionality.
* **GitHub** is a *website* that hosts a copy of your Git history online, adding collaboration features (pull requests, issues) on top. You could use Git your entire life without ever touching GitHub — but GitHub is specifically what Phase 9, Part 2 uses, because it's what Vercel connects to for automatic deployments.

---

## 2. The core mental model: snapshots, not just "saving"

When you save a file in a normal application, you overwrite the previous version — the old content is simply gone. Git works completely differently: it takes **snapshots** — called **commits** — of your entire project at a specific moment in time, and *keeps every single one of them, forever*, unless you explicitly go out of your way to remove them.

Picture a photo album where every single page is a complete photograph of your entire project folder, taken at a specific moment. Flipping backward through the album shows you exactly what your project looked like at any earlier point. That's fundamentally what Git's commit history is — a chronological photo album of your project, and you (the photographer) decide exactly when to take each picture.

---

## 3. Installing Git

Git is often already installed on macOS and many Linux distributions. Check first:

```bash
git --version
```

**Expected output**, if already installed:
```
git version 2.43.0
```

If you see `command not found`, install it:

* **Windows:** Download and run the installer from **[git-scm.com](https://git-scm.com)**, accepting the default options throughout.
* **macOS:** If not already installed, running `git --version` for the first time typically prompts you to install Apple's Command Line Developer Tools, which include Git — follow the on-screen prompt.
* **Linux:** `sudo apt install git` (Debian/Ubuntu-based) or the equivalent command for your distribution's package manager.

### ✅ The Verification

Re-run `git --version` after installing, and confirm it now prints a real version number rather than a "command not found" error.

---

## 4. One-time setup: telling Git who you are

Before your first commit anywhere, Git needs to know your name and email — this information gets permanently attached to every snapshot you ever take, so that (especially once collaborating with others) it's always clear who made which change.

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

The `--global` flag means this setting applies to *every* Git project on your computer, not just one specific project — you only need to run these two commands once, ever, on a given machine.

### ✅ The Verification

```bash
git config --global user.name
git config --global user.email
```

**Expected output:** the exact name and email you just set, printed back to you.

---

## 5. The core workflow: `init`, `add`, `commit`

This three-step rhythm is the heart of using Git day-to-day, and it's exactly what Phase 9, Part 2 walks through for real, on our actual project.

### Step 1 — `git init`: starting the photo album

```bash
git init
```

Run once, inside your project's root folder. This creates a hidden `.git` folder — invisible in a normal file listing, but this is where Git actually stores the entire history of "photographs" going forward. Everything from this point on is being tracked.

### Step 2 — `git add`: choosing what goes in the next photo

```bash
git add .
```

Before taking a snapshot, you tell Git exactly *which* changed files should be included in it — this is called **staging**. The `.` means "everything in and under the current folder." Think of this as laying out every document you want included on the table before the photographer takes the picture — you're deciding what's *in frame* for this particular snapshot.

You can also stage specific files individually, rather than everything at once:

```bash
git add src/App.jsx
```

### Step 3 — `git commit`: actually taking the photo

```bash
git commit -m "Add task toggle functionality"
```

This takes the actual snapshot of everything you staged in Step 2, permanently, into the project's history. The `-m` flag lets you attach a **commit message** — a short, human-readable description of what changed and why. Writing a clear, specific message (not just "updates" or "fix") is a genuinely valuable habit — future-you, scrolling back through history months later, will be very grateful for a message like `"Add task toggle functionality"` instead of `"stuff"`.

### ✅ The Verification

After running these three commands in sequence inside any folder, run:

```bash
git log
```

**Expected output:** a listing of your commit, showing its unique ID, your name/email, the timestamp, and the message you wrote:

```
commit 8f3a9b2c1e4d5f6a7b8c9d0e1f2a3b4c5d6e7f8a
Author: Your Name <your.email@example.com>
Date:   Sat Jul 25 10:00:00 2026 -0400

    Add task toggle functionality
```

Press `q` to exit the log view if your terminal doesn't return to a normal prompt automatically.

---

## 6. Checking your status — the command you'll run constantly

```bash
git status
```

This is, in practice, the single most frequently run Git command — it tells you, at any moment: which files you've changed since your last commit, which changes are currently staged (ready for the next commit) versus unstaged, and which files Git isn't tracking at all yet. Running this liberally, any time you're unsure what state your project is in, is a genuinely good habit to build from day one.

**Typical output after changing a file but before staging it:**
```
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
        modified:   src/App.jsx

no changes added to commit (use "git add" and/or "git commit -a")
```

**After running `git add .`:**
```
On branch main
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   src/App.jsx
```

---

## 7. `.gitignore` — telling Git what *not* to photograph

Not everything in a project folder should be tracked by Git. Recall from Phase 1, Part 1: `node_modules/` can contain thousands of downloaded files — re-downloadable at any time via `npm install`, and far too large and unnecessary to include in your project's permanent history. A `.gitignore` file tells Git exactly which files/folders to always skip, entirely:

```
node_modules
dist
.env
```

Each line is a pattern describing something to ignore. This series builds up its `.gitignore` incrementally — starting with `node_modules` (present from Vite's initial scaffold in Phase 1, Part 1) and eventually including `dist` and every `.env*` variant by Phase 9. Anything listed here will never show up in `git status`, never get staged by `git add .`, and never appear in a commit — even though the actual files still exist normally on your computer.

### ✅ The Verification

Create a `.gitignore` file containing `node_modules` (assuming a `node_modules` folder already exists in your project, e.g., after running `npm install`), then run `git status`. Confirm `node_modules` does **not** appear anywhere in the output — proof Git is correctly ignoring it.

---

## 8. Branches — working on something without touching the main version

A **branch** is an independent line of history, allowing you to work on a change in isolation, without affecting your project's main, working version until you're ready. This is the exact mechanism Phase 9, Part 2 uses to demonstrate Vercel's Preview Deployments.

```bash
git branch
```

Lists all branches in your project, with a `*` marking which one you're currently "on." By default, most new repositories start with a single branch, conventionally named `main`.

```bash
git checkout -b add-footer-credit
```

Creates a **new** branch named `add-footer-credit`, and immediately switches your working folder onto it — `-b` here means "and create it as a new branch," as opposed to switching to one that already exists. From this point, any commits you make are recorded onto *this* branch specifically, leaving `main` completely untouched.

```bash
git checkout main
```

Switches back to the `main` branch at any time. Switching branches actually changes the real files in your project folder to match that branch's latest commit — this is genuinely how Git lets you move between different versions of your project instantly.

Think of branches like alternate timelines in a choose-your-own-adventure book: you can explore one path (a new feature, a risky experiment) fully, and if it doesn't work out, simply abandon that branch entirely — `main` was never affected. If it *does* work out, you **merge** it back into `main`, bringing those changes into the primary timeline — exactly what happens when a pull request gets merged on GitHub, as covered in Phase 9, Part 2.

---

## 9. Connecting to GitHub: `remote`, `push`, `pull`

Everything covered so far happens entirely on your own computer. To share your history with GitHub (and, by extension, let Vercel see it), you need a few more pieces of vocabulary:

* **Remote** — a saved reference to a copy of your repository hosted elsewhere (like on GitHub). Conventionally named `origin`.
* **Push** — uploading your local commits to a remote.
* **Pull** — downloading commits from a remote that you don't yet have locally (important once collaborating with others, or working across multiple of your own machines).

```bash
git remote add origin https://github.com/your-username/task-habit-tracker.git
```

Registers a remote named `origin`, pointing at a specific GitHub repository's URL. Run once per project, typically right after creating an empty repository on GitHub's website.

```bash
git push -u origin main
```

Uploads your local `main` branch's commits to the `origin` remote. The `-u` flag (short for `--set-upstream`) tells Git to *remember* this pairing, so that in the future, you can simply run `git push` with no extra arguments and Git will know exactly where to send it.

### ✅ The Verification (a preview of Phase 9, Part 2's real usage)

After genuinely running these commands against a real GitHub repository, refreshing that repository's page in your browser should show every file from your local project, now hosted online — exactly the state Phase 9, Part 2 verifies in detail, once we're deploying the real Task & Habit Tracker.

---

## 10. A calm word about mistakes

Git is specifically designed so that almost nothing is ever truly, unrecoverably lost, once it's been committed at least once. A few reassuring facts worth knowing before you ever need them:

* If you haven't committed a change yet, and you want to completely discard it and go back to your last commit, `git restore <filename>` reverts that one file back to how it looked at your last commit.
* `git log` always shows your complete history — nothing is hidden or silently deleted just because time has passed.
* The commands in this primer (`init`, `add`, `commit`, `status`, `branch`, `checkout`, `push`) cover the entire practical surface area this series ever asks you to use — you are not expected to become a Git expert, only comfortable enough to follow Phase 9, Part 2's deployment workflow with confidence.

---

## Quick-reference summary

| Command | Meaning |
|---|---|
| `git init` | Start tracking a project with Git |
| `git status` | See what's changed since your last commit |
| `git add .` | Stage all changes, ready for the next commit |
| `git commit -m "message"` | Save a permanent snapshot of staged changes |
| `git log` | View the full commit history |
| `.gitignore` | A file listing what Git should never track |
| `git branch` | List branches / see which one you're on |
| `git checkout -b name` | Create and switch to a new branch |
| `git checkout main` | Switch back to the main branch |
| `git remote add origin <url>` | Link your project to a GitHub repository |
| `git push -u origin main` | Upload your commits to GitHub |

---

With this foundation, Phase 9, Part 2's deployment workflow — `git init`, committing your finished project, pushing to GitHub, creating a branch to demonstrate Preview Deployments — will read as a natural continuation of habits you've been quietly building since Phase 1, rather than a new subject introduced under deployment pressure. A genuinely good habit worth starting immediately: commit your project after finishing each Part of this series, using a message that names what you just built (e.g., `"Complete Phase 2, Part 1: useState toggling"`) — by the time you reach Phase 9, you'll have a complete, meaningful history of your entire learning journey, ready to push to GitHub in one step.
