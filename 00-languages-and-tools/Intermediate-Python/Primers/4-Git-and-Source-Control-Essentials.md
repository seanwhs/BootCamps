# Primer 4: Git and Source-Control Essentials

Git is a **version-control system**: it records changes to files over time.

Think of Git as a detailed project history:

- You make a useful change.
- You save a named checkpoint called a **commit**.
- Later, you can inspect what changed, compare versions, or safely return to an earlier state.

Git is essential for professional software development because code changes constantly. It helps you work safely alone and collaborate with others.

By the end of this primer, you will be able to:

- Check whether Git is installed.
- Initialize a Git repository.
- Inspect project changes.
- Understand tracked, untracked, staged, and committed files.
- Create a first commit.
- Review commit history.
- Create a branch.
- Make and inspect changes.
- Avoid committing virtual environments and secrets.

---

## What You Will Build

You will turn the current learning project into a Git repository.

Expected structure:

```text
pythonic-craftsmanship/
├── .git/
├── .gitignore
├── .venv/
├── hello_python.py
├── notes/
│   └── terminal_practice.txt
└── scripts/
    ├── import_demo.py
    ├── path_demo.py
    └── syntax_refresh.py
```

The `.git/` directory stores Git’s internal history. Do not edit files inside `.git/` manually.

---

# Step 1: Confirm That Git Is Installed

## The Target

We are confirming that Git is available on your computer.

## The Concept

Git is a command-line program, similar to Python.

When you run:

```bash
git --version
```

you are asking Git to identify itself.

## The Implementation

From any terminal location, run:

```bash
git --version
```

If Git is not installed, download it from:

```text
https://git-scm.com/downloads
```

On macOS, you may also be prompted to install Apple’s Command Line Tools. Accepting that prompt generally installs Git.

## The Verification

Expected output resembles:

```text
git version 2.45.2
```

The exact version is not important.

---

# Step 2: Configure Your Git Identity

## The Target

We are configuring the name and email Git attaches to your commits.

## The Concept

Each commit records who created it.

A commit is like signing a change request:

```text
Author: Your Name <you@example.com>
```

Use an identity appropriate for your work:

- A personal name and email for personal projects.
- A work-approved name and email for company projects.
- A Git-hosting-provider privacy email if you do not want to publish your real email address.

## The Implementation

Set your global Git identity:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Replace the example values with your own.

To inspect the configured values:

```bash
git config --global --list
```

## The Verification

Expected output includes:

```text
user.name=Your Name
user.email=you@example.com
```

Do not use an email address you do not control if you plan to publish commits publicly.

---

# Step 3: Initialize the Repository

## The Target

We are creating a Git repository in:

```text
pythonic-craftsmanship/
```

## The Concept

A **repository**, often shortened to **repo**, is a project folder managed by Git.

Initializing Git creates a hidden `.git/` directory. This directory stores:

- Commit history
- Branch information
- Staging information
- Repository configuration

## The Implementation

Move to your project root if needed.

### macOS or Linux

```bash
cd ~/projects/pythonic-craftsmanship
```

### Windows PowerShell

```powershell
cd $HOME\projects\pythonic-craftsmanship
```

Initialize Git:

```bash
git init
```

## The Verification

Expected output resembles:

```text
Initialized empty Git repository in .../pythonic-craftsmanship/.git/
```

Run:

```bash
git status
```

Expected output resembles:

```text
On branch main

No commits yet

Untracked files:
  ...
```

Some Git versions may use `master` instead of `main`. We will normalize the branch name in the next step.

---

# Step 4: Set the Default Branch Name to `main`

## The Target

We are naming the primary branch:

```text
main
```

## The Concept

A **branch** is an independent line of development.

The primary branch is usually named:

```text
main
```

Later, you can create feature branches for work such as:

```text
feature/add-pagination
feature/improve-tests
fix/retry-timeout
```

Using a branch lets you make focused changes without immediately altering the primary version of the project.

## The Implementation

Run:

```bash
git branch -M main
```

The `-M` option renames the current branch, replacing an existing branch name if required.

## The Verification

Run:

```bash
git branch --show-current
```

Expected output:

```text
main
```

---

# Step 5: Understand `git status`

## The Target

We are inspecting the repository’s current state.

## The Concept

`git status` is the most useful Git command for day-to-day work.

Run it whenever you are unsure what Git sees.

Git files generally move through these states:

```text
Untracked
    ↓ git add
Staged
    ↓ git commit
Committed
    ↓ edit file
Modified
    ↓ git add
Staged again
```

Definitions:

| State | Meaning |
|---|---|
| Untracked | Git has not started tracking the file |
| Modified | Git tracks the file, but it changed since the last commit |
| Staged | The next commit will include the current version |
| Committed | The change is safely stored in Git history |

## The Implementation

Run:

```bash
git status
```

## The Verification

You should see your source files listed as untracked, such as:

```text
Untracked files:
  .gitignore
  hello_python.py
  notes/
  scripts/
```

You should **not** see `.venv/` listed because `.gitignore` excludes it.

If `.venv/` appears, confirm that `.gitignore` contains:

```gitignore
.venv/
```

Then run:

```bash
git status
```

again.

---

# Step 6: Inspect What `.gitignore` Excludes

## The Target

We are verifying that Git ignores the virtual environment.

## The Concept

Git can report why a file is ignored.

This is useful when:

- A file should be ignored but appears in `git status`.
- A file should be tracked but Git ignores it unexpectedly.
- You need to verify a `.gitignore` rule.

## The Implementation

### macOS or Linux

```bash
git check-ignore -v .venv/bin/python
```

### Windows PowerShell

```powershell
git check-ignore -v .venv\Scripts\python.exe
```

## The Verification

Expected output resembles:

```text
.gitignore:2:.venv/    .venv/bin/python
```

This means:

- `.gitignore`
- line `2`
- rule `.venv/`

caused Git to ignore the virtual-environment file.

---

# Step 7: Stage Your Initial Project Files

## The Target

We are adding the current source files to Git’s staging area.

## The Concept

The **staging area** is a deliberate list of changes for the next commit.

It lets you choose exactly what belongs in a checkpoint.

For a first project commit, staging all intended project files is appropriate.

Use:

```bash
git add .
```

The dot means:

> Add changes below the current directory.

Before using it in an established project, always inspect `git status` first. You do not want to accidentally stage credentials, generated output, or unrelated files.

## The Implementation

First, inspect the status:

```bash
git status
```

Then stage the project files:

```bash
git add .
```

## The Verification

Run:

```bash
git status
```

Expected output resembles:

```text
Changes to be committed:
  new file:   .gitignore
  new file:   hello_python.py
  new file:   notes/terminal_practice.txt
  new file:   scripts/import_demo.py
  new file:   scripts/path_demo.py
  new file:   scripts/syntax_refresh.py
```

You should not see:

```text
.venv/
```

---

# Step 8: Review Staged Changes Before Committing

## The Target

We are reviewing exactly what will enter Git history.

## The Concept

Before creating a commit, inspect the staged change set.

This is a professional habit that prevents accidental commits of:

- API tokens
- Debug output
- Large generated files
- Unfinished code
- Unrelated changes

## The Implementation

Run:

```bash
git diff --staged
```

You may also use:

```bash
git diff --cached
```

These commands are equivalent.

## The Verification

You should see the contents of newly staged text files.

For example, the `.gitignore` section should include:

```diff
+.venv/
+__pycache__/
+*.py[cod]
```

The `+` symbol means the line is being added.

Confirm that no secret values, such as real API tokens, appear in the output.

---

# Step 9: Create Your First Commit

## The Target

We are creating the repository’s first named checkpoint.

## The Concept

A **commit** stores a snapshot of staged changes with a message.

A useful commit message describes the result, not merely the action.

Less useful:

```text
changed files
```

Better:

```text
Set up Python learning project
```

Commit messages commonly use the imperative voice:

```text
Add project configuration
Create API transport layer
Fix pagination validation
```

Read them as commands:

> Add project configuration.

## The Implementation

Run:

```bash
git commit -m "Set up Python learning project"
```

## The Verification

Expected output resembles:

```text
[main abc1234] Set up Python learning project
 6 files changed, ...
```

Run:

```bash
git status
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

A **clean working tree** means every current tracked change is committed.

---

# Step 10: Review Commit History

## The Target

We are viewing repository history.

## The Concept

Git history is a sequence of commits.

Each commit has:

- A unique identifier called a **commit hash**
- An author
- A timestamp
- A message
- A snapshot of changes

## The Implementation

Run:

```bash
git log --oneline
```

## The Verification

Expected output resembles:

```text
abc1234 Set up Python learning project
```

The first seven characters of the commit hash are usually enough for normal command-line use.

For a richer history display:

```bash
git log --oneline --decorate --graph
```

Expected output resembles:

```text
* abc1234 (HEAD -> main) Set up Python learning project
```

`HEAD` means:

> The currently checked-out commit and branch position.

---

# Step 11: Make a Small Change and Inspect It

## The Target

We are practicing the modified-file workflow.

## The Concept

Most Git work follows this cycle:

```text
Edit
    ↓
git status
    ↓
git diff
    ↓
git add
    ↓
git diff --staged
    ↓
git commit
```

`git diff` shows changes that are not staged yet.

## The Implementation

Open `hello_python.py` and replace its complete contents with this version.

### `hello_python.py`

```python
"""Verify that the Pythonic Craftsmanship development environment works."""

from __future__ import annotations

import sys


def main() -> None:
    """Print a friendly setup confirmation and Python version."""
    print("Pythonic Craftsmanship environment is ready.")
    print(f"Active Python version: {sys.version.split()[0]}")
    print("Git repository setup is complete.")


if __name__ == "__main__":
    main()
```

Run:

```bash
git status
```

Then inspect the unstaged change:

```bash
git diff
```

## The Verification

Expected `git status` output includes:

```text
modified:   hello_python.py
```

Expected `git diff` output includes:

```diff
+    print("Git repository setup is complete.")
```

Run the program too:

```bash
python hello_python.py
```

Expected output includes:

```text
Git repository setup is complete.
```

---

# Step 12: Stage and Commit the Change

## The Target

We are creating a second commit.

## The Concept

Git does not automatically include modified files in a commit. You must stage the exact version you want.

This separation is valuable because you may have several changes in progress but only want to commit one logical feature.

## The Implementation

Stage the updated file:

```bash
git add hello_python.py
```

Review staged changes:

```bash
git diff --staged
```

Create the commit:

```bash
git commit -m "Add Git setup confirmation"
```

## The Verification

Run:

```bash
git log --oneline --decorate --graph
```

Expected output resembles:

```text
* def5678 (HEAD -> main) Add Git setup confirmation
* abc1234 Set up Python learning project
```

Run:

```bash
git status
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

---

# Step 13: Create and Use a Feature Branch

## The Target

We are creating a branch named:

```text
feature/add-project-note
```

## The Concept

A branch gives a change its own workspace.

Instead of changing `main` directly, create a branch for a focused feature:

```text
main
  \
   feature/add-project-note
```

This is especially important when working with other people, code review, pull requests, and release branches.

## The Implementation

Create and switch to a new branch:

```bash
git switch -c feature/add-project-note
```

Older Git versions may not support `switch`. In that case, use:

```bash
git checkout -b feature/add-project-note
```

Confirm the active branch:

```bash
git branch
```

## The Verification

Expected output:

```text
* feature/add-project-note
  main
```

The asterisk marks the active branch.

---

# Step 14: Make and Commit a Branch-Specific Change

## The Target

We are adding a project note on the feature branch.

## The Concept

A branch should contain a focused, understandable change.

We will add one documentation file that belongs specifically to this feature.

## The Implementation

Create this file.

### `notes/project_workflow.txt`

```text
Pythonic Craftsmanship workflow:

1. Activate the virtual environment.
2. Make one focused change.
3. Run the relevant Python program or tests.
4. Inspect Git status and diffs.
5. Commit the completed change with a clear message.
```

Stage it:

```bash
git add notes/project_workflow.txt
```

Review it:

```bash
git diff --staged
```

Commit it:

```bash
git commit -m "Add project workflow note"
```

## The Verification

Run:

```bash
git log --oneline --decorate --graph --all
```

Expected output resembles:

```text
* 123abcd (HEAD -> feature/add-project-note) Add project workflow note
* def5678 (main) Add Git setup confirmation
* abc1234 Set up Python learning project
```

The feature branch now contains one commit that `main` does not yet contain.

---

# Step 15: Merge the Feature Branch into `main`

## The Target

We are merging the completed feature branch into `main`.

## The Concept

A **merge** brings changes from one branch into another.

The normal workflow is:

```text
Create branch
    ↓
Make focused changes
    ↓
Test changes
    ↓
Commit changes
    ↓
Merge into main
```

In team projects, a pull request usually provides review before the merge. For this local practice project, we will merge directly.

## The Implementation

Switch back to `main`:

```bash
git switch main
```

Merge the feature branch:

```bash
git merge feature/add-project-note
```

## The Verification

Expected output resembles:

```text
Updating def5678..123abcd
Fast-forward
 notes/project_workflow.txt | 6 ++++++
 1 file changed, 6 insertions(+)
```

Run:

```bash
git status
git log --oneline --decorate --graph --all
```

Expected output resembles:

```text
* 123abcd (HEAD -> main, feature/add-project-note) Add project workflow note
* def5678 Add Git setup confirmation
* abc1234 Set up Python learning project
```

Both branch names may point to the same commit after a fast-forward merge.

---

# Step 16: Delete the Merged Feature Branch

## The Target

We are cleaning up the merged feature branch.

## The Concept

After a branch is merged, it is usually safe to delete the local branch name.

Deleting the branch name does **not** delete the commit history that was merged into `main`.

Think of it as removing a completed task label after the work is incorporated into the main plan.

## The Implementation

Run:

```bash
git branch -d feature/add-project-note
```

## The Verification

Run:

```bash
git branch
```

Expected output:

```text
* main
```

The project note remains available:

### macOS or Linux

```bash
cat notes/project_workflow.txt
```

### Windows PowerShell

```powershell
Get-Content notes\project_workflow.txt
```

---

# Primer 4 Reference: Essential Git Commands

| Command | Purpose |
|---|---|
| `git init` | Create a repository |
| `git status` | Show file and staging state |
| `git add file.py` | Stage one file |
| `git add .` | Stage changes under current folder |
| `git diff` | Show unstaged changes |
| `git diff --staged` | Show staged changes |
| `git commit -m "Message"` | Create a commit |
| `git log --oneline` | Show concise history |
| `git branch` | List branches |
| `git switch branch-name` | Move to an existing branch |
| `git switch -c branch-name` | Create and move to a branch |
| `git merge branch-name` | Merge another branch into current branch |
| `git branch -d branch-name` | Delete merged local branch |

---

# Primer 4 Reference: Commit Message Guidance

Good commit messages describe one completed outcome.

Examples:

```text
Set up Python learning project
Add project workflow note
Create immutable API configuration
Add project pagination tests
Fix retry policy validation
Document environment configuration
```

Avoid vague messages:

```text
updates
fix
stuff
changes
work in progress
```

A useful format for many projects is:

```text
<Verb> <specific outcome>
```

For example:

```text
Add API response validation
Fix project identifier encoding
Refactor transport error handling
```

---

# Primer 4 Reference: Git Safety Rules

## Do Not Commit Secrets

Never commit:

```text
.env
API tokens
passwords
private keys
database credentials
authorization headers
```

Use `.gitignore` and environment variables.

---

## Review Before Committing

Run:

```bash
git status
git diff
git diff --staged
```

This catches accidental files and unintended edits.

---

## Do Not Force-Push Shared Branches

Later, if you use a remote host such as GitHub, avoid force-pushing shared branches unless your team explicitly agrees.

Dangerous command:

```bash
git push --force
```

It can overwrite remote history.

---

## Commit Small Logical Changes

Prefer:

```text
Add project validation
Add validation tests
Document validation behavior
```

over one giant commit containing unrelated code, formatting, dependency updates, and documentation changes.

Small commits are easier to review, understand, revert, and merge.
