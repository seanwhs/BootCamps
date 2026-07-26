# Part 1: The Foundations of Local Version Control

In this part, you will use Git entirely on your own computer. There is no GitHub account, remote repository, or collaboration workflow yet.

The goal is to understand what Git records, where it records it, and how to safely inspect or discard changes before they become permanent commits.

By the end of this part, you will have a local repository for the **Release Notes Manager** project with a clear commit history.

---

## Part 1 Roadmap

You will learn how to:

1. Understand why version control is different from making backups.
2. Understand Git’s three local states:
   - Working Directory
   - Staging Area
   - Local Repository
3. Configure Git identity settings.
4. Create and initialize a repository.
5. Create, stage, and commit files.
6. Inspect repository status and history.
7. Compare file versions with `git diff`.
8. Safely undo uncommitted changes using `git restore` and `git checkout`.

---

# Step 1: Understand the Problem Git Solves

## The Target

Understand why Git exists before using any command.

## The Concept

Imagine writing a school report without version control. Your folder might eventually look like this:

```text
project/
├── report.docx
├── report_final.docx
├── report_final_v2.docx
├── report_final_v2_really_final.docx
└── report_final_v2_really_final_USE_THIS_ONE.docx
```

This approach creates several problems:

- You cannot easily tell what changed between files.
- You may accidentally edit the wrong version.
- You may lose useful work while copying files.
- Multiple people editing copies creates confusion.
- File names become your only history system.

A normal backup is useful, but it answers a different question:

> “Can I restore my files if my computer fails?”

Git answers questions such as:

> “What changed in this file last Tuesday?”  
> “Who added this line?”  
> “Can I return to the version before this feature?”  
> “Can I work on an experiment without breaking the stable project?”  
> “Can I combine my work with someone else’s work?”

Git records a sequence of **commits**. Each commit is a labeled snapshot of selected project changes.

Instead of creating this:

```text
README-final-v3.md
```

You keep one file:

```text
README.md
```

And Git records its history:

```text
Commit A: Create initial project documentation
Commit B: Add installation instructions
Commit C: Correct command examples
Commit D: Document release-note format
```

The current file stays clean, while the repository preserves its history.

## The Implementation

No command is needed in this step.

## The Verification

Confirm that you can explain the difference:

- A **backup** preserves copies in case files are lost.
- **Version control** preserves a structured history of meaningful changes.

---

# Step 2: Learn Git’s Three Local Areas

## The Target

Understand the three places where Git-related changes can exist on your computer.

## The Concept

Git is easiest to understand when you picture a three-stage delivery system:

```text
Working Directory → Staging Area → Local Repository
```

### 1. Working Directory

The **working directory** is the ordinary project folder you edit.

This is where you create files, write code, delete text, and make mistakes.

For example:

```text
release-notes-manager/
└── README.md
```

If you open `README.md` in your editor and type a new sentence, that change exists only in your working directory.

### 2. Staging Area

The **staging area** is a preparation area for the next commit.

Another name for it is the **index**.

Think of it as a packing table before shipping a box. You may have changed ten files in your working directory, but perhaps only two belong in the next commit. `git add` chooses which file changes go onto the packing table.

```text
Working Directory
  ├── README.md changed       ← selected with git add
  ├── notes.md changed        ← not selected yet
  └── draft.txt changed       ← not selected yet

Staging Area
  └── README.md changed
```

### 3. Local Repository

The **local repository** is Git’s permanent local history database. It is stored in a hidden folder named `.git`.

When you run `git commit`, Git takes the exact contents currently in the staging area and creates a commit in the local repository.

```text
Working Directory
  ├── README.md changed again after staging
  └── notes.md changed

Staging Area
  └── README.md version selected for the commit

Local Repository
  └── Previous commits plus the newly created commit
```

A critical rule follows:

> `git commit` records what is staged, not automatically every change in your project folder.

## The Implementation

The commands you will use throughout the part are:

```bash
git status
git add <file-name>
git commit -m "Describe the change"
```

Their roles are:

```text
git status
    Shows the current state of the working directory and staging area.

git add <file-name>
    Moves a file’s current changes from the working directory into the staging area.

git commit -m "message"
    Saves the staged snapshot into the local repository.
```

## The Verification

Memorize this flow:

```text
Edit a file
   ↓
git status
   ↓
git add <file>
   ↓
git status
   ↓
git commit -m "Meaningful message"
   ↓
git log
```

You will perform this exact flow shortly.

---

# Step 3: Configure Your Git Identity

## The Target

Configure the name and email address Git attaches to commits you create.

## The Concept

Every commit contains author information.

Think of a commit as a signed entry in a project logbook. The commit message explains what happened, and the author information says who recorded it.

A commit contains data similar to:

```text
Author: Ada Developer <ada@example.com>
Date:   2026-07-25
Message: Add initial project documentation
```

Git uses configuration settings to determine this information.

There are three common configuration scopes:

| Scope | Command flag | Applies to |
|---|---|---|
| System | `--system` | Every user on the computer |
| Global | `--global` | Every repository for your user account |
| Local | No flag, while inside a repository | Only the current repository |

For a personal computer, use `--global`. This applies your identity to repositories you create or use under your account.

If you use Git for work and personal projects with different email addresses, you can later override the global setting inside a particular repository.

## The Implementation

Run the following commands in a terminal. Replace the example values with your own name and email address.

```bash
git config --global user.name "Your Full Name"
git config --global user.email "you@example.com"
```

For example:

```bash
git config --global user.name "Jordan Lee"
git config --global user.email "jordan.lee@example.com"
```

Set Git’s preferred initial branch name to `main`:

```bash
git config --global init.defaultBranch main
```

Set your default editor for commit messages. If you use Visual Studio Code and its `code` command works, run:

```bash
git config --global core.editor "code --wait"
```

The `--wait` option means Git waits until you close the commit-message file in Visual Studio Code before continuing.

If you do not use Visual Studio Code, skip that command. Git will use your operating system’s configured default editor when needed.

Now inspect your global Git configuration:

```bash
git config --global --list
```

## The Verification

Check the individual identity settings:

```bash
git config --global user.name
git config --global user.email
git config --global init.defaultBranch
```

Expected output resembles:

```text
Jordan Lee
jordan.lee@example.com
main
```

Do not continue until the displayed name and email are correct. These values will be attached to the commits you create.

---

# Step 4: Create the Project Folder and Initialize Git

## The Target

Create the `release-notes-manager` project folder and turn it into a Git repository.

## The Concept

At this moment, a folder is just a folder. Git does not automatically track every file on your computer.

The command:

```bash
git init
```

tells Git:

> “Start tracking history for this directory.”

Git creates a hidden `.git` directory inside the project. This hidden directory contains the repository database: commits, branches, configuration, and other Git metadata.

Your project will look conceptually like this:

```text
release-notes-manager/
├── .git/                 # Git’s internal repository data
└── README.md             # Your project files
```

Important: do not manually edit, rename, move, or delete files inside `.git` unless you specifically understand the Git internals involved. Git manages this directory for you.

If `.git` is deleted, your files may remain, but their Git history disappears from that folder.

## The Implementation

Choose a location where you keep development projects.

### macOS or Linux

Run:

```bash
mkdir -p ~/projects/release-notes-manager
cd ~/projects/release-notes-manager
git init
```

### Windows Git Bash

Run:

```bash
mkdir -p ~/projects/release-notes-manager
cd ~/projects/release-notes-manager
git init
```

### Windows PowerShell

Run:

```powershell
New-Item -ItemType Directory -Path "$HOME\projects\release-notes-manager" -Force
Set-Location "$HOME\projects\release-notes-manager"
git init
```

Git should display output similar to:

```text
Initialized empty Git repository in /your/path/release-notes-manager/.git/
```

Now inspect the directory, including hidden files.

### macOS, Linux, or Git Bash

```bash
ls -la
```

### Windows PowerShell

```powershell
Get-ChildItem -Force
```

You should see a `.git` directory.

Finally, ask Git for the repository state:

```bash
git status
```

## The Verification

Expected `git status` output is similar to:

```text
On branch main

No commits yet

nothing to commit (create/copy files and use "git add" to track)
```

The exact wording can vary slightly by Git version.

You have now created a local repository. It contains no commits and no tracked project files yet.

---

# Step 5: Create the Initial Project Documentation

## The Target

Create the first version of the project’s `README.md` file.

## The Concept

A `README.md` file is the front door of a repository. It tells future readers what the project is, why it exists, and how to use it.

The `.md` extension means **Markdown**, a lightweight text format for headings, lists, links, code blocks, and other documentation features.

For now, the project does not need application code. We are deliberately beginning with a simple text file so the Git concepts remain visible without programming complexity.

You will first create the file in the working directory. At this point, Git will notice it, but will not track it until you explicitly stage it.

## The Implementation

Create a file named `README.md` in the project root.

### `release-notes-manager/README.md`

```md
# Release Notes Manager

Release Notes Manager is a small project for organizing and publishing clear software release notes.

## Purpose

This repository is used to learn professional Git and GitHub workflows from local development through automated quality checks.

## Initial Release Note Format

Each release note should include:

1. A version number.
2. A release date.
3. A summary of important changes.
4. A list of fixes, features, and known limitations.

## Status

The project is in its initial documentation phase.
```

You can create the file in Visual Studio Code by opening the current folder:

```bash
code .
```

Then:

1. Create a new file named `README.md`.
2. Paste the complete content above.
3. Save the file.

If you prefer to use the terminal, run the following command from the repository root.

### macOS, Linux, or Git Bash

```bash
cat > README.md <<'EOF'
# Release Notes Manager

Release Notes Manager is a small project for organizing and publishing clear software release notes.

## Purpose

This repository is used to learn professional Git and GitHub workflows from local development through automated quality checks.

## Initial Release Note Format

Each release note should include:

1. A version number.
2. A release date.
3. A summary of important changes.
4. A list of fixes, features, and known limitations.

## Status

The project is in its initial documentation phase.
EOF
```

### Windows PowerShell

```powershell
@'
# Release Notes Manager

Release Notes Manager is a small project for organizing and publishing clear software release notes.

## Purpose

This repository is used to learn professional Git and GitHub workflows from local development through automated quality checks.

## Initial Release Note Format

Each release note should include:

1. A version number.
2. A release date.
3. A summary of important changes.
4. A list of fixes, features, and known limitations.

## Status

The project is in its initial documentation phase.
'@ | Set-Content -Path README.md
```

## The Verification

Run:

```bash
git status
```

Expected output resembles:

```text
On branch main

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        README.md

nothing added to commit but untracked files present (use "git add" to track)
```

The term **untracked** means the file exists in your working directory, but Git has not been instructed to include it in version history.

Git can see the file, but it is not yet part of a commit.

---

# Step 6: Stage and Commit the Initial Documentation

## The Target

Add `README.md` to the staging area and create the repository’s first commit.

## The Concept

Before this step, Git knows that `README.md` exists, but it is untracked.

The command:

```bash
git add README.md
```

places the current version of the file into the staging area.

Then:

```bash
git commit -m "Add initial project documentation"
```

creates a permanent snapshot from the staging area.

Think of it as publishing the first official entry in the project’s logbook.

A good commit message:

- Uses an action verb.
- Describes one clear change.
- Is short but meaningful.
- Does not merely say “update” or “changes.”

Good:

```text
Add initial project documentation
```

Less useful:

```text
stuff
```

## The Implementation

First, stage the file:

```bash
git add README.md
```

Check Git’s state before committing:

```bash
git status
```

Then create the commit:

```bash
git commit -m "Add initial project documentation"
```

## The Verification

First, before the commit, `git status` should resemble:

```text
On branch main

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
        new file:   README.md
```

The phrase **Changes to be committed** means the file is in the staging area.

After committing, run:

```bash
git status
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

Now inspect the history:

```bash
git log
```

Expected output resembles:

```text
commit 7f6d8f0c84b4c9f2d0f9c8c0d4f1b8c6a8e4b123 (HEAD -> main)
Author: Jordan Lee <jordan.lee@example.com>
Date:   Fri Jul 25 12:00:00 2026 +0000

    Add initial project documentation
```

Your commit identifier will be different. It is a unique hash, a long sequence of letters and numbers that identifies that exact commit.

To view a shorter, more readable history, run:

```bash
git log --oneline
```

Expected output resembles:

```text
7f6d8f0 Add initial project documentation
```

---

# Step 7: Make and Inspect an Unstaged Change

## The Target

Modify `README.md` and inspect the difference before staging it.

## The Concept

You now have a committed baseline. This makes Git especially useful: it can compare your current working directory with the most recent committed snapshot.

The command:

```bash
git diff
```

shows **unstaged differences**.

In plain terms, it answers:

> “What have I changed on my desk that I have not yet placed on the packing table?”

Git displays removed lines with `-` and added lines with `+`.

```diff
- Old line
+ New line
```

This does not mean Git is deleting or adding mathematical values. It is a visual notation for the difference between two versions.

## The Implementation

Open `README.md` and replace its complete contents with the following updated version.

### `release-notes-manager/README.md`

```md
# Release Notes Manager

Release Notes Manager is a small project for organizing and publishing clear software release notes.

## Purpose

This repository is used to learn professional Git and GitHub workflows from local development through automated quality checks.

## Initial Release Note Format

Each release note should include:

1. A version number.
2. A release date.
3. A summary of important changes.
4. A list of fixes, features, and known limitations.

## Status

The project is in its initial documentation phase.

## Contribution Guidelines

Keep each change focused on one purpose. Before committing, review the Git diff to confirm that only intended changes are included.
```

Do not stage the file yet.

Run:

```bash
git status
```

Then inspect the exact unstaged difference:

```bash
git diff
```

## The Verification

`git status` should show:

```text
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   README.md
```

`git diff` should show the new section, similar to:

```diff
diff --git a/README.md b/README.md
index 1234567..abcdef0 100644
--- a/README.md
+++ b/README.md
@@ -15,3 +15,7 @@ Each release note should include:
 ## Status

 The project is in its initial documentation phase.
+
+## Contribution Guidelines
+
+Keep each change focused on one purpose. Before committing, review the Git diff to confirm that only intended changes are included.
```

The line-number and hash values will differ on your computer.

At this point:

```text
Working Directory: README.md has changed.
Staging Area: unchanged.
Local Repository: unchanged.
```

---

# Step 8: Stage a Change and Compare Staged Content

## The Target

Stage the `README.md` change and compare the staging area to the last commit.

## The Concept

There are two related diff commands:

| Command | What it compares |
|---|---|
| `git diff` | Working directory versus staging area |
| `git diff --staged` | Staging area versus most recent commit |

Once you stage a file, regular `git diff` may show no output. That does not mean your change disappeared. It means the working directory and staging area now match for that file.

To inspect what the next commit will contain, use:

```bash
git diff --staged
```

You may also see this command written as:

```bash
git diff --cached
```

Both commands inspect staged changes. `--staged` is generally easier to understand as a beginner.

## The Implementation

Stage the updated README:

```bash
git add README.md
```

Run:

```bash
git status
```

Now inspect the next commit’s contents:

```bash
git diff --staged
```

Finally, create the commit:

```bash
git commit -m "Document contribution guidelines"
```

## The Verification

Before committing, `git status` should show:

```text
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   README.md
```

`git diff` should now produce no output because there are no differences between your working directory and staging area.

Run it to confirm:

```bash
git diff
```

Then run:

```bash
git diff --staged
```

This command should show the `Contribution Guidelines` section.

After committing, run:

```bash
git log --oneline
```

Expected output resembles:

```text
a1b2c3d Document contribution guidelines
7f6d8f0 Add initial project documentation
```

You now have two commits.

---

# Step 9: Add a Second File and Practice Selective Staging

## The Target

Create `RELEASE_NOTES.md`, then commit it independently from an unrelated README change.

## The Concept

Selective staging is one of Git’s most important habits.

Suppose you are working on two unrelated tasks:

1. Add a release-note template.
2. Correct a sentence in the README.

These changes should usually become separate commits. Separate commits are easier to review, easier to revert, and easier for future developers to understand.

The staging area lets you choose exactly which work belongs in the next commit.

Think of this like packing two different customer orders. Even if both orders sit on the same desk, you should not put their items into one box.

## The Implementation

Create the following file.

### `release-notes-manager/RELEASE_NOTES.md`

```md
# Release Notes

## Unreleased

### Added

- Initial release-note template.

### Changed

- No changes recorded yet.

### Fixed

- No fixes recorded yet.

## Release Format

Each published release should use the following heading format:

```text
## [VERSION] - YYYY-MM-DD
```

Example:

```text
## [1.0.0] - 2026-07-25
```
```

Now make a separate, unrelated change to `README.md`.

Replace only this sentence:

```md
The project is in its initial documentation phase.
```

with:

```md
The project is in its initial documentation and planning phase.
```

Your complete `README.md` should now be:

### `release-notes-manager/README.md`

```md
# Release Notes Manager

Release Notes Manager is a small project for organizing and publishing clear software release notes.

## Purpose

This repository is used to learn professional Git and GitHub workflows from local development through automated quality checks.

## Initial Release Note Format

Each release note should include:

1. A version number.
2. A release date.
3. A summary of important changes.
4. A list of fixes, features, and known limitations.

## Status

The project is in its initial documentation and planning phase.

## Contribution Guidelines

Keep each change focused on one purpose. Before committing, review the Git diff to confirm that only intended changes are included.
```

Check the repository state:

```bash
git status
```

Stage only the release-note template:

```bash
git add RELEASE_NOTES.md
```

Inspect the staged content:

```bash
git diff --staged
```

Inspect the unstaged content:

```bash
git diff
```

Commit only the staged file:

```bash
git commit -m "Add release notes template"
```

## The Verification

Before committing, `git status` should show two separate sections:

```text
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   RELEASE_NOTES.md

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   README.md
```

This output proves that:

- `RELEASE_NOTES.md` is staged.
- `README.md` is still only an unstaged working-directory change.

After committing, run:

```bash
git status
```

Expected output:

```text
On branch main
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")
```

Now inspect history:

```bash
git log --oneline
```

Expected output resembles:

```text
d4e5f6a Add release notes template
a1b2c3d Document contribution guidelines
7f6d8f0 Add initial project documentation
```

The README change remains safely uncommitted.

---

# Step 10: Commit the Remaining README Change

## The Target

Stage and commit the outstanding README status update.

## The Concept

You already proved that Git can keep different pieces of work separate.

Now you will finish the second task as its own commit. This creates a history where every commit has one understandable purpose:

```text
Add initial project documentation
Document contribution guidelines
Add release notes template
Clarify project status
```

This is much more useful than one vague commit containing unrelated changes.

## The Implementation

First, review the pending change:

```bash
git diff
```

Stage the file:

```bash
git add README.md
```

Review the staged version:

```bash
git diff --staged
```

Create the commit:

```bash
git commit -m "Clarify project status"
```

## The Verification

Run:

```bash
git status
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

Inspect the complete history:

```bash
git log --oneline
```

Expected output resembles:

```text
e7f8a9b Clarify project status
d4e5f6a Add release notes template
a1b2c3d Document contribution guidelines
7f6d8f0 Add initial project documentation
```

To inspect the most recent commit in full, run:

```bash
git show --stat
```

Expected output resembles:

```text
commit e7f8a9b...
Author: Jordan Lee <jordan.lee@example.com>
Date:   ...

    Clarify project status

 README.md | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
```

`git show --stat` summarizes which files changed without printing every changed line.

To see the patch itself, run:

```bash
git show
```

---

# Step 11: Inspect History and Compare Commits

## The Target

Use `git log`, `git show`, and `git diff` to inspect project history and compare committed versions.

## The Concept

Git’s value grows as a project changes. You need ways to answer questions such as:

- What commits exist?
- What did this commit change?
- What changed between two points in history?
- What did a file look like in an older commit?

Git identifies each commit using a hash. You usually do not need the entire hash. A unique short prefix is enough.

For example:

```text
e7f8a9b Clarify project status
```

Here, `e7f8a9b` is a shortened commit ID.

The `HEAD` name refers to your current checked-out commit. At the end of this part, it points to the newest commit on `main`.

```text
main
  │
  ▼
[Commit 1] ← [Commit 2] ← [Commit 3] ← [Commit 4]
                                         ▲
                                         │
                                        HEAD
```

## The Implementation

View the compact commit history:

```bash
git log --oneline
```

View a graph-style history:

```bash
git log --oneline --decorate --graph --all
```

At this stage, it should resemble a straight line:

```text
* e7f8a9b (HEAD -> main) Clarify project status
* d4e5f6a Add release notes template
* a1b2c3d Document contribution guidelines
* 7f6d8f0 Add initial project documentation
```

View the current commit:

```bash
git show HEAD
```

View the commit immediately before the current commit:

```bash
git show HEAD~1
```

In Git notation:

| Reference | Meaning |
|---|---|
| `HEAD` | Current commit |
| `HEAD~1` | Parent of the current commit, one commit earlier |
| `HEAD~2` | Two commits earlier |
| `main` | The latest commit on the local `main` branch |

Compare the latest commit with the commit before it:

```bash
git diff HEAD~1 HEAD
```

Compare the first commit with the current commit:

```bash
git diff HEAD~3 HEAD
```

Finally, view the version of `README.md` stored in the first commit. First, copy the short hash of your initial commit from `git log --oneline`, then use it in this pattern:

```bash
git show <initial-commit-hash>:README.md
```

For example, if your first commit begins with `7f6d8f0`:

```bash
git show 7f6d8f0:README.md
```

## The Verification

Confirm that:

1. `git log --oneline` shows four commits.
2. `git show HEAD` displays the commit named `Clarify project status`.
3. `git show HEAD~1` displays the commit named `Add release notes template`.
4. `git diff HEAD~1 HEAD` displays only the README status sentence change.
5. `git show <initial-commit-hash>:README.md` displays the original README without contribution guidelines or the revised status sentence.

You can now inspect both current work and historical versions without creating duplicate files.

---

# Step 12: Safely Discard an Unstaged Change with `git restore`

## The Target

Make an accidental working-directory change, inspect it, and discard it safely with `git restore`.

## The Concept

Sometimes you edit a file and decide the change is wrong. If the change is **not staged** and **not committed**, you can restore the file to match the staging area.

The modern command is:

```bash
git restore <file-name>
```

Think of it as saying:

> “Replace my current desk copy with the version prepared for the next commit.”

If nothing is staged for that file, Git restores it to the most recent commit.

Important warning:

```bash
git restore README.md
```

discards uncommitted changes in `README.md`. This is usually not recoverable with Git because Git only reliably records changes after they are staged or committed.

Always inspect the change first with:

```bash
git diff
```

## The Implementation

Open `README.md` and add this incorrect line directly below the main heading:

```md
This sentence was added by mistake and should not be kept.
```

Your temporary file should look like this:

### `release-notes-manager/README.md` — temporary incorrect version

```md
# Release Notes Manager

This sentence was added by mistake and should not be kept.

Release Notes Manager is a small project for organizing and publishing clear software release notes.

## Purpose

This repository is used to learn professional Git and GitHub workflows from local development through automated quality checks.

## Initial Release Note Format

Each release note should include:

1. A version number.
2. A release date.
3. A summary of important changes.
4. A list of fixes, features, and known limitations.

## Status

The project is in its initial documentation and planning phase.

## Contribution Guidelines

Keep each change focused on one purpose. Before committing, review the Git diff to confirm that only intended changes are included.
```

Inspect the change:

```bash
git status
git diff
```

Now discard that unstaged change:

```bash
git restore README.md
```

## The Verification

Run:

```bash
git status
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

Open `README.md` again. The accidental sentence should be gone.

Confirm Git sees no difference:

```bash
git diff
```

This command should produce no output.

---

# Step 13: Use the Older `git checkout -- <file>` Restore Syntax

## The Target

Understand and safely use the older `git checkout -- <file>` syntax for discarding an unstaged file change.

## The Concept

Before `git restore` was introduced, developers commonly used this command:

```bash
git checkout -- README.md
```

The `--` separator means:

> “Everything after this is a file path, not a branch name.”

This matters because `git checkout` historically handled both branches and files. It is a powerful but overloaded command.

Modern Git recommends clearer commands:

```bash
git switch <branch-name>
git restore <file-name>
```

However, you will still encounter `git checkout -- <file>` in older tutorials, scripts, Stack Overflow answers, and established codebases. You should recognize it.

For discarding unstaged changes, these commands have the same practical effect:

```bash
git restore README.md
```

```bash
git checkout -- README.md
```

Both overwrite the working-directory file with its staged version. If no staged version exists, that is normally the version from the latest commit.

## The Implementation

Open `RELEASE_NOTES.md` and add this temporary incorrect item under `### Added`:

```md
- This temporary line should be discarded.
```

The temporary version should be:

### `release-notes-manager/RELEASE_NOTES.md` — temporary incorrect version

```md
# Release Notes

## Unreleased

### Added

- Initial release-note template.
- This temporary line should be discarded.

### Changed

- No changes recorded yet.

### Fixed

- No fixes recorded yet.

## Release Format

Each published release should use the following heading format:

```text
## [VERSION] - YYYY-MM-DD
```

Example:

```text
## [1.0.0] - 2026-07-25
```
```

Inspect the difference:

```bash
git diff -- RELEASE_NOTES.md
```

Now discard the temporary line using the older syntax:

```bash
git checkout -- RELEASE_NOTES.md
```

## The Verification

Run:

```bash
git status
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

Confirm that the file no longer contains the temporary line:

```bash
git diff -- RELEASE_NOTES.md
```

The command should produce no output.

You now understand both syntaxes:

```bash
git restore RELEASE_NOTES.md
```

Preferred modern syntax.

```bash
git checkout -- RELEASE_NOTES.md
```

Older syntax you will still see in real projects.

---

# Step 14: Unstage a File Without Losing Its Changes

## The Target

Learn how to remove a file from the staging area while preserving its working-directory edits.

## The Concept

Staging is not irreversible. If you accidentally run:

```bash
git add README.md
```

you can remove the file from the staging area without deleting your edits.

Use:

```bash
git restore --staged README.md
```

Think of this as taking an item off the packing table and returning it to your desk. The item still exists; it is simply no longer selected for the next shipment.

This is different from:

```bash
git restore README.md
```

That command replaces your desk copy and can discard edits.

The distinction is important:

| Command | Effect |
|---|---|
| `git restore --staged README.md` | Unstages changes but keeps file edits |
| `git restore README.md` | Discards unstaged working-directory edits |
| `git restore --staged README.md` followed by `git restore README.md` | First unstage, then discard changes |

## The Implementation

Add the following section to the end of `README.md`:

```md
## Local Development

Use Git status frequently to understand whether changes are untracked, unstaged, staged, or committed.
```

Your complete file should be:

### `release-notes-manager/README.md` — temporary staging exercise version

```md
# Release Notes Manager

Release Notes Manager is a small project for organizing and publishing clear software release notes.

## Purpose

This repository is used to learn professional Git and GitHub workflows from local development through automated quality checks.

## Initial Release Note Format

Each release note should include:

1. A version number.
2. A release date.
3. A summary of important changes.
4. A list of fixes, features, and known limitations.

## Status

The project is in its initial documentation and planning phase.

## Contribution Guidelines

Keep each change focused on one purpose. Before committing, review the Git diff to confirm that only intended changes are included.

## Local Development

Use Git status frequently to understand whether changes are untracked, unstaged, staged, or committed.
```

Stage it:

```bash
git add README.md
```

Confirm it is staged:

```bash
git status
git diff --staged
```

Now unstage it while keeping the text in the file:

```bash
git restore --staged README.md
```

## The Verification

Run:

```bash
git status
```

Expected output:

```text
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")
```

Verify that the section still exists in `README.md`.

Then confirm the current state with both diff commands:

```bash
git diff
git diff --staged
```

Expected behavior:

- `git diff` displays the `Local Development` section because it is unstaged.
- `git diff --staged` displays no output because nothing is staged.

Now stage and commit the intended documentation improvement:

```bash
git add README.md
git commit -m "Add local development guidance"
```

Finally, confirm the repository is clean:

```bash
git status
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

---

# Step 15: Review the Completed Local Repository

## The Target

Perform a final health check on the local repository created in this part.

## The Concept

Before moving on to branches, confirm that the project has a clean working tree and a readable history.

A clean working tree means your current files match the latest commit. It is a good checkpoint before beginning a new feature or switching branches.

Your repository should now have a history similar to:

```text
Add initial project documentation
Document contribution guidelines
Add release notes template
Clarify project status
Add local development guidance
```

The exact commit hashes will differ, but the messages should be recognizable.

## The Implementation

Run all of the following commands from the `release-notes-manager` directory:

```bash
git status
git log --oneline --decorate --graph --all
git ls-files
```

`git ls-files` lists files currently tracked by Git.

Inspect the final README:

```bash
git show HEAD:README.md
```

Inspect the final release-note template:

```bash
git show HEAD:RELEASE_NOTES.md
```

## The Verification

Expected `git status` output:

```text
On branch main
nothing to commit, working tree clean
```

Expected `git ls-files` output:

```text
README.md
RELEASE_NOTES.md
```

Expected history shape:

```text
* <hash> (HEAD -> main) Add local development guidance
* <hash> Clarify project status
* <hash> Add release notes template
* <hash> Document contribution guidelines
* <hash> Add initial project documentation
```

Your repository now contains:

```text
release-notes-manager/
├── .git/
├── README.md
└── RELEASE_NOTES.md
```

The `.git` directory holds Git’s internal history. The two Markdown files are your tracked project content.

---

# Part 1 Reference: Core Commands and Their Roles

This reference is intentionally separate from the hands-on steps. Return to it when you need a quick reminder.

## Repository Setup

```bash
git init
```

Creates a new local Git repository in the current directory.

```bash
git config --global user.name "Your Name"
```

Sets the author name used for your commits.

```bash
git config --global user.email "you@example.com"
```

Sets the author email used for your commits.

```bash
git config --global init.defaultBranch main
```

Makes newly initialized repositories start with a `main` branch.

---

## Inspecting State

```bash
git status
```

Shows:

- Current branch.
- Untracked files.
- Modified but unstaged files.
- Staged files.
- Whether the working tree is clean.

```bash
git diff
```

Shows unstaged changes:

```text
Working Directory versus Staging Area
```

```bash
git diff --staged
```

Shows staged changes:

```text
Staging Area versus Latest Commit
```

```bash
git log --oneline
```

Displays compact commit history.

```bash
git log --oneline --decorate --graph --all
```

Displays a compact graph of all known branches and commits.

```bash
git show HEAD
```

Displays the current commit and its changes.

```bash
git show <commit-hash>
```

Displays a specific commit.

```bash
git show <commit-hash>:<file-path>
```

Displays a file as it existed at a specific commit.

Example:

```bash
git show HEAD:README.md
```

---

## Creating History

```bash
git add README.md
```

Stages the current version of `README.md`.

```bash
git add RELEASE_NOTES.md
```

Stages the current version of `RELEASE_NOTES.md`.

```bash
git add .
```

Stages changes inside the current directory and its subdirectories.

Use this only after reviewing `git status` and `git diff`; it can stage more files than intended.

```bash
git commit -m "Add release notes template"
```

Creates a commit using the staging area’s exact contents.

---

## Correcting Local Mistakes

```bash
git restore README.md
```

Discards unstaged changes in `README.md`.

Use carefully: this can permanently remove uncommitted edits.

```bash
git checkout -- README.md
```

Older equivalent syntax for discarding unstaged changes.

```bash
git restore --staged README.md
```

Removes changes from the staging area but preserves them in the working directory.

---

# Part 1 Completion Checklist

Before continuing, confirm all of the following:

- [ ] Git is installed and `git --version` works.
- [ ] Your global Git name and email are configured correctly.
- [ ] You created the `release-notes-manager` repository.
- [ ] You understand the working directory, staging area, and local repository.
- [ ] You created and committed `README.md`.
- [ ] You created and committed `RELEASE_NOTES.md`.
- [ ] You used `git status`, `git diff`, `git diff --staged`, and `git log`.
- [ ] You selectively staged separate changes into separate commits.
- [ ] You safely discarded an unstaged change with `git restore`.
- [ ] You recognized the older `git checkout -- <file>` syntax.
- [ ] Your final `git status` reports a clean working tree.
