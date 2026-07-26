# Primer 7: Git History Graphs, Commit References, and Time Travel Basics

Git history can look intimidating at first:

```text
*   a1b2c3d Merge branch 'feature/add-export'
|\
| * d4e5f6a Add export documentation
| * e7f8a9b Add export tests
* | b2c3d4e Update release checklist
|/
* f6e7d8c Add release formatter
```

This is not random text. It is a map of project history.

This primer explains how to read that map before using advanced commands such as:

```bash
git log
git show
git diff
git revert
git reset
git rebase
git reflog
```

You will learn:

- What a commit is.
- Why commits have hashes.
- What `HEAD` means.
- How branches point to commits.
- How to refer to older commits.
- How Git graphs represent merges.
- How to inspect earlier versions safely.

---

# P7.1 Understand a Commit

## The Target

Understand what Git records when you create a commit.

## The Concept

A **commit** is a saved snapshot of staged project changes.

A commit contains:

```text
Project snapshot
Author information
Date and time
Commit message
Parent commit reference
Unique identifier
```

Think of a commit as a dated entry in a project journal:

```text
Entry 1:
Create the project documentation.

Entry 2:
Add release-note template.

Entry 3:
Add formatter tests.
```

Git history usually forms a chain:

```text
Commit A → Commit B → Commit C
```

Each newer commit remembers which commit came before it.

## The Implementation

Inspect recent commits:

```bash
git log --oneline -5
```

Example output:

```text
a1b2c3d Add continuous integration workflow
d4e5f6a Add security guidance
e7f8a9b Add release note formatter
```

Inspect the full latest commit:

```bash
git show HEAD
```

## The Verification

Confirm that `git show HEAD` includes:

```text
commit <hash>
Author: <name and email>
Date: <timestamp>

    <commit message>
```

It should also show the file changes included in the commit.

---

# P7.2 Understand Commit Hashes

## The Target

Understand why Git uses long identifiers for commits.

## The Concept

Each commit has a unique identifier called a **hash**.

A full hash resembles:

```text
a1b2c3d4e5f678901234567890abcdef12345678
```

Git usually lets you use a unique short version:

```text
a1b2c3d
```

A hash is based on commit content and metadata. If the commit changes, its hash changes.

This is why rewriting history creates new commit hashes.

For example:

```text
Original commit:
a1b2c3d Add documentation

Amended commit:
f4e5d6c Add documentation
```

The message or contents changed, so Git created a new commit with a different identity.

## The Implementation

Print the full hash for the current commit:

```bash
git rev-parse HEAD
```

Print a short form:

```bash
git rev-parse --short HEAD
```

View compact history:

```bash
git log --oneline -5
```

## The Verification

The short hash from:

```bash
git rev-parse --short HEAD
```

should match the beginning of the full hash from:

```bash
git rev-parse HEAD
```

And it should usually match the first column in:

```bash
git log --oneline
```

---

# P7.3 Understand `HEAD`

## The Target

Understand what `HEAD` means in everyday Git work.

## The Concept

`HEAD` is Git’s name for your current checkout position.

Normally, `HEAD` points to your active branch:

```text
HEAD → main → latest commit
```

If you are on a feature branch:

```text
HEAD → feature/add-export → latest feature commit
```

When you make a new commit, Git moves the active branch forward:

```text
Before commit:

HEAD → main → Commit A

After commit:

HEAD → main → Commit B
```

You can use `HEAD` in commands as a shortcut for “the current commit.”

## The Implementation

Display the active branch:

```bash
git branch --show-current
```

Display the current commit hash:

```bash
git rev-parse HEAD
```

Display the current commit summary:

```bash
git show --no-patch --oneline HEAD
```

## The Verification

Expected output resembles:

```text
a1b2c3d Add continuous integration workflow
```

This confirms that `HEAD` resolves to the latest commit on your current branch.

---

# P7.4 Refer to Older Commits with `HEAD~`

## The Target

Use relative commit references to inspect earlier commits safely.

## The Concept

Git provides relative references based on the current commit.

| Reference | Meaning |
|---|---|
| `HEAD` | Current commit |
| `HEAD~1` | One commit before current commit |
| `HEAD~2` | Two commits before current commit |
| `HEAD~3` | Three commits before current commit |

Think of it as walking backward through a journal:

```text
HEAD     = newest entry
HEAD~1   = previous entry
HEAD~2   = entry before that
```

These references are useful for inspection and comparison.

## The Implementation

Inspect the current commit:

```bash
git show --no-patch --oneline HEAD
```

Inspect the parent commit:

```bash
git show --no-patch --oneline HEAD~1
```

Inspect two commits earlier:

```bash
git show --no-patch --oneline HEAD~2
```

Compare the current commit against its parent:

```bash
git diff HEAD~1 HEAD
```

## The Verification

The command:

```bash
git diff HEAD~1 HEAD
```

should show only changes introduced by the latest commit.

If your repository has fewer than three commits, `HEAD~2` may fail. That is normal; use only references that exist in your history.

---

# P7.5 Understand Branches as Commit Pointers

## The Target

Understand why branches are lightweight and why switching branches changes visible files.

## The Concept

A branch is a named pointer to a commit.

For example:

```text
main → Commit C
```

Creating a feature branch does not copy the project:

```text
main                 → Commit C
feature/add-export   → Commit C
```

After making a commit on the feature branch:

```text
main                 → Commit C
feature/add-export   → Commit D
HEAD                 → feature/add-export
```

The branches now point to different commits.

This is why switching branches may change files in your working directory. Git checks out the snapshot associated with the branch’s current commit.

## The Implementation

List branches:

```bash
git branch
```

Show branches with their latest commits:

```bash
git branch -v
```

Show all branches and the commit graph:

```bash
git log --oneline --decorate --graph --all -15
```

## The Verification

Look for output resembling:

```text
* main a1b2c3d Add continuous integration workflow
```

The asterisk marks the active branch.

When multiple branches exist, graph output may resemble:

```text
* a1b2c3d (HEAD -> main) Add continuous integration workflow
| * d4e5f6a (feature/add-export) Add export documentation
|/
* e7f8a9b Add release note formatter
```

---

# P7.6 Read a Merge Graph

## The Target

Understand the graph symbols Git uses to show parallel work and merges.

## The Concept

Git’s graph output uses:

```text
*
|
\
/
```

to show commit relationships.

A simple straight history:

```text
* C
* B
* A
```

A branch that has not merged:

```text
* C (main)
| * D (feature)
|/
* B
* A
```

A merge commit:

```text
*   E (main)
|\
| * D (feature)
* | C
|/
* B
* A
```

The merge commit `E` joins work from `main` and `feature`.

## The Implementation

Run:

```bash
git log --oneline --decorate --graph --all -20
```

Find merge commits:

```bash
git log --merges --oneline
```

Inspect one merge commit, replacing `MERGE_COMMIT_HASH`:

```bash
git show --no-patch --format=raw MERGE_COMMIT_HASH
```

## The Verification

A merge commit contains more than one `parent` line:

```text
parent <first-parent-hash>
parent <second-parent-hash>
```

A squash merge may not appear as a merge commit because it creates one ordinary commit on `main`.

---

# P7.7 Compare Branches Before Opening a Pull Request

## The Target

Inspect exactly what your branch proposes to add to `main`.

## The Concept

A pull request is a comparison between a feature branch and a base branch.

Locally, the clearest comparison command is:

```bash
git diff main...HEAD
```

The three dots mean:

> “Find the common ancestor of `main` and the current branch, then show changes from that shared starting point to the current branch.”

This avoids including changes that arrived on `main` after your branch began.

## The Implementation

From a feature branch:

```bash
git status
git diff --stat main...HEAD
git diff main...HEAD
git log --oneline main..HEAD
```

If you are currently on `main`, create no fake change. Instead, understand the command for future feature branches.

## The Verification

On a feature branch:

```bash
git log --oneline main..HEAD
```

shows commits unique to the feature branch.

And:

```bash
git diff main...HEAD
```

shows the file differences the pull request would propose.

On `main`, these commands may produce no output because there are no feature-only commits.

---

# P7.8 Safely Inspect an Earlier File Version

## The Target

View a file as it existed at an earlier commit without changing your current files.

## The Concept

You do not need to switch branches or check out old commits just to inspect historical content.

Use:

```bash
git show <reference>:<file-path>
```

For example:

```bash
git show HEAD~1:README.md
```

This means:

> “Print `README.md` as it existed one commit before the current commit.”

This is safe because it only displays historical content.

## The Implementation

View the current README:

```bash
git show HEAD:README.md
```

View the previous version:

```bash
git show HEAD~1:README.md
```

Compare the two versions:

```bash
git diff HEAD~1 HEAD -- README.md
```

## The Verification

Confirm that:

- `git show HEAD:README.md` prints the current committed README.
- `git show HEAD~1:README.md` prints the earlier committed README.
- `git diff HEAD~1 HEAD -- README.md` shows the lines that changed.

---

# P7.9 Understand Detached HEAD

## The Target

Recognize detached HEAD state and know how to leave it safely.

## The Concept

Normally:

```text
HEAD → branch → commit
```

A **detached HEAD** means:

```text
HEAD → commit
```

This commonly happens when you inspect an old commit directly:

```bash
git switch --detach HEAD~2
```

Detached HEAD is useful for temporary inspection. The risk is creating commits there and then switching away without creating a branch.

If you only inspect historical files, return to your normal branch:

```bash
git switch main
```

If you made valuable commits while detached, save them by creating a branch:

```bash
git switch -c recovery/detached-work
```

## The Implementation

Do not enter detached HEAD state unless you have a specific reason.

Inspect your current state safely:

```bash
git status
git branch --show-current
```

If Git reports detached HEAD in the future, preserve work if needed:

```bash
git switch -c recovery/detached-work
```

Or return to `main` if no work was created:

```bash
git switch main
```

## The Verification

A normal active branch reports:

```text
main
```

from:

```bash
git branch --show-current
```

In detached HEAD state, this command produces no branch name.

---

# P7.10 History Inspection Routine

## The Target

Use a repeatable sequence when you need to understand recent project changes.

## The Concept

Git history is most useful when you inspect it deliberately.

Use this routine:

```text
Current state
    ↓
Recent graph
    ↓
Specific commit
    ↓
Relevant file history
    ↓
Compare versions
```

## The Implementation

Run:

```bash
git status
git log --oneline --decorate --graph --all -15
git show --stat HEAD
git log --oneline -- src/releaseNotes.js
git diff HEAD~1 HEAD
```

If `src/releaseNotes.js` does not exist in your current project stage, use a tracked file such as:

```bash
git log --oneline -- README.md
```

## The Verification

You should be able to answer:

```text
[ ] Which branch am I on?
[ ] Which commit is HEAD?
[ ] What changed in the latest commit?
[ ] Which commits changed a particular file?
[ ] What differs between two recent commits?
```

---

# Primer 7 Reference: Commit and History Commands

| Command | Purpose |
|---|---|
| `git log --oneline` | Show compact commit history |
| `git log --graph --decorate --all` | Show branch and merge graph |
| `git show HEAD` | Show current commit and patch |
| `git show HEAD~1` | Show previous commit and patch |
| `git rev-parse HEAD` | Print full current commit hash |
| `git rev-parse --short HEAD` | Print short current commit hash |
| `git branch -v` | List branches and latest commits |
| `git diff HEAD~1 HEAD` | Compare current commit with parent |
| `git show HEAD:README.md` | Print a file from current commit |
| `git show HEAD~1:README.md` | Print a file from previous commit |
| `git log --oneline -- <file>` | Show history of one file |
| `git log --merges --oneline` | Show merge commits |

---

# Primer 7 Completion Check

Before using advanced history and recovery commands, confirm that you can:

- [ ] Explain what a commit stores.
- [ ] Identify a commit hash and its short form.
- [ ] Explain what `HEAD` means.
- [ ] Use `HEAD~1` and `HEAD~2` to inspect older commits.
- [ ] Explain branches as pointers to commits.
- [ ] Read a basic Git graph.
- [ ] Compare a feature branch against `main`.
- [ ] View an older file version without changing current files.
- [ ] Recognize detached HEAD state.
- [ ] Use `git log`, `git show`, and `git diff` to investigate history safely.
