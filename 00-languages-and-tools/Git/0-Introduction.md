# Part 0: Introduction

Welcome to **Mastering Version Control from Local to Production**.

This is a hands-on tutorial series about Git and GitHub: the tools developers use to safely track code changes, work on multiple features at once, collaborate with other people, review code, recover from mistakes, and automate quality checks before code reaches production.

You do **not** need prior Git experience. We will begin with plain folders and text files on your own computer, then gradually build toward the same workflows used by professional software teams.

---

## What You Will Build Throughout This Series

Rather than practicing Git commands in disconnected examples, you will use a small but realistic project called **Release Notes Manager**.

It will begin as a local text-based project and grow into a repository managed through GitHub collaboration and automation.

By the end, your project repository will include:

```text
release-notes-manager/
├── .github/
│   └── workflows/
│       └── ci.yml                # Automated GitHub Actions quality checks
├── src/
│   ├── releaseNotes.js           # Application logic
│   └── releaseNotes.test.js      # Automated tests
├── .gitignore                    # Rules for files Git must not track
├── LICENSE                       # Project license
├── README.md                     # Project documentation
├── package.json                  # JavaScript project configuration
└── ...
```

More importantly, you will build a reliable mental model for how Git works.

Git is not only a collection of commands. It is a system for recording meaningful snapshots of a project over time.

Think of it like a highly organized time machine for your files:

- You make a meaningful change.
- You save a labeled snapshot called a **commit**.
- Git remembers exactly what changed, when it changed, and why.
- You can compare snapshots, move between them, combine work from different features, or recover after a mistake.

GitHub adds a collaboration layer around Git. It is a hosted platform where teams can store repositories, review proposed changes, discuss work, run automated checks, and coordinate releases.

---

## The Final Architecture

By the end of the series, you will understand and use the full development flow below.

```text
Your computer
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  Working directory                                             │
│  ├── You edit files                                            │
│  ├── You inspect changes                                       │
│  └── You prepare selected changes for a commit                 │
│                                                                │
│  Git staging area                                              │
│  └── A deliberate "next snapshot" selection area               │
│                                                                │
│  Local Git repository (.git/)                                  │
│  ├── Commit history                                            │
│  ├── Branches                                                  │
│  └── Tags and configuration                                    │
│                                                                │
└─────────────────────────────┬──────────────────────────────────┘
                              │ git push / git fetch / git pull
                              │
                              ▼
GitHub
┌────────────────────────────────────────────────────────────────┐
│                                                                │
│  Remote repository                                             │
│  ├── main branch                                               │
│  ├── Feature branches                                          │
│  ├── Pull requests                                             │
│  ├── Issues and project planning                               │
│  └── GitHub Actions continuous integration checks              │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

The journey starts entirely on your own computer. You will not need a GitHub account until Part 3.

---

## Who This Series Is For

This series is designed for:

- Beginners who have never used Git or GitHub.
- Developers who have copied commands from tutorials but do not yet understand what those commands do.
- Students building portfolio projects.
- Developers moving from solo work into team-based development.
- Engineers who want a practical reference for branching, merging, rebasing, recovery, pull requests, and GitHub Actions.

You should be comfortable with basic terminal navigation, such as opening a terminal and running a command. If you are new to terminals, do not worry: every required command will be shown exactly as you should enter it.

---

## What You Need Before Part 1

Install the following tools before beginning the technical work.

### 1. Git

Git is the version-control program that runs on your computer.

Verify whether it is installed:

```bash
git --version
```

A successful result looks similar to this:

```text
git version 2.45.2
```

If the command is not found, install Git from:

```text
https://git-scm.com/downloads
```

During installation, the default options are suitable for most beginners.

### 2. A Terminal

Use one of these terminal applications:

| Operating system | Recommended terminal |
|---|---|
| macOS | Terminal or iTerm2 |
| Windows | Git Bash, Windows Terminal, or PowerShell |
| Linux | Your distribution’s default terminal |

For the most consistent experience on Windows, use **Git Bash**, which is installed alongside Git when you select that option during Git installation.

### 3. A Code Editor

A code editor is an application for writing and editing project files.

We will use **Visual Studio Code** in examples because it is free, widely used, and includes excellent Git integration. You may use another editor if you prefer.

Download it here:

```text
https://code.visualstudio.com/
```

Verify its command-line launcher if available:

```bash
code --version
```

If this command does not work, you can still open Visual Studio Code manually through your operating system.

### 4. A GitHub Account

You will need this in Part 3, not immediately.

Create one at:

```text
https://github.com/signup
```

Use an email address you control. You will later configure Git so commits are associated with an appropriate name and email address.

---

## The Learning Path

Each part builds on the previous one.

| Part | Topic | Outcome |
|---|---|---|
| **Part 1** | Local Git foundations | Create repositories, stage changes, commit snapshots, inspect history, and safely undo uncommitted edits. |
| **Part 2** | Branching and merging | Build isolated features, merge parallel work, resolve conflicts, and understand rebasing. |
| **Part 3** | GitHub remotes | Authenticate securely, push repositories, fetch changes, clone projects, fork open-source repositories, and ignore sensitive files. |
| **Part 4** | Professional collaboration | Use feature branches, pull requests, reviews, issues, labels, milestones, and project planning. |
| **Part 5** | Advanced Git and automation | Clean up history, recover lost work, stash changes, cherry-pick commits, reset safely, and create GitHub Actions CI workflows. |

---

## How Every Technical Step Will Work

Each implementation step in this series follows the same format:

1. **The Target**  
   The exact file, command, configuration, or workflow you are building.

2. **The Concept**  
   A plain-language explanation of why that piece exists and how it works.

3. **The Implementation**  
   Complete commands and complete file contents. You will not be asked to fill in missing code or infer omitted steps.

4. **The Verification**  
   A concrete way to confirm the step worked before proceeding.

This structure matters because Git commands can be destructive when used without context. We will learn the safe path first, explain what state your repository is in, and verify results frequently.

---

## A Few Terms You Will See Often

### Repository

A **repository**, often shortened to **repo**, is a project folder that Git is tracking.

For example:

```text
release-notes-manager/
```

When Git is initialized in that folder, it records history for files inside it.

### Commit

A **commit** is a saved snapshot of selected changes.

A good commit is small, focused, and described with a message that explains its purpose.

For example:

```text
Add initial release notes document
```

### Branch

A **branch** is an independent line of work.

You might keep the stable version of your project on `main`, then create a branch called `add-search` to build search functionality without risking the stable version.

### Remote

A **remote** is a named connection to a repository stored somewhere else, usually GitHub.

The conventional name for the primary remote is:

```text
origin
```

### Pull Request

A **pull request**, commonly called a **PR**, is a proposal to merge one branch into another on GitHub.

It gives teammates a place to inspect code, leave comments, request changes, and run automated checks before merging.

---

## Important Safety Rules

Git is powerful because it can rewrite history, discard changes, and move your project to earlier points in time. We will learn those operations, but use these habits throughout the series:

1. Run this before any unfamiliar Git operation:

   ```bash
   git status
   ```

   It tells you what branch you are on, what has changed, and whether you have work that has not been committed.

2. Read command output carefully. Git often tells you exactly what to do next.

3. Commit working milestones frequently.

4. Do not commit secrets such as passwords, API keys, `.env` files, or private certificates.

5. Do not rewrite shared branch history without understanding the consequences. In particular, be cautious with:

   ```bash
   git push --force
   ```

   We will cover the safe, limited use of force-pushing later in the series.

6. When uncertain, preserve your work first. Creating a commit or copying a file before a risky operation is usually inexpensive and can prevent data loss.

---

## The Core Mental Model

The most important idea in this series is that Git has three local areas:

```text
Working Directory → Staging Area → Local Repository
```

Here is the same idea in everyday language:

- **Working Directory:** Your desk. You actively edit files here.
- **Staging Area:** A packing table. You choose exactly which changes go into the next shipment.
- **Local Repository:** The warehouse record. Once the shipment is finalized as a commit, Git permanently records that snapshot in your local history.

Later, GitHub becomes the shared distribution center where your team exchanges those recorded snapshots.

```text
Your edits
   │
   ▼
Working Directory
   │  git add
   ▼
Staging Area
   │  git commit
   ▼
Local Repository
   │  git push
   ▼
GitHub Remote Repository
```

Understanding this flow is more valuable than memorizing individual commands. Most Git confusion comes from not knowing which area currently contains a change. Part 1 focuses entirely on making this model feel natural.

---

## What “Production-Ready” Means Here

This series is about version control rather than deploying a specific web application. Still, the practices you will learn are production-grade:

- Meaningful commit history.
- Small, reviewable feature branches.
- Protected main branches.
- Pull-request-based change control.
- Automated linting and tests for every proposed change.
- Secrets excluded through `.gitignore`.
- Recovery techniques for mistakes and lost commits.
- Clear ownership and planning through GitHub Issues and Projects.

These practices are the foundation beneath reliable production software.

---

## Your Starting Point

At the beginning of Part 1, you will create this project folder:

```text
release-notes-manager/
```

Inside it, you will create your first project document, initialize Git, examine the hidden `.git` directory, and make the first commit.

No remote repository. No GitHub. No collaboration complexity.

Just you, a folder, and Git’s local history system.
