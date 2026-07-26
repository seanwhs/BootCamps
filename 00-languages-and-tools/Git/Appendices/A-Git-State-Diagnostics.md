# Appendix A: Git State Diagnostics and Everyday Command Reference

This appendix is a practical “what do I run now?” guide.

When Git feels confusing, do not guess. Start with:

```bash
git status
```

Then use the sections below to identify your repository state and choose the safest next command.

---

## A.1 The Three-State Model

Git manages changes across three local areas:

```text
Working Directory → Staging Area → Local Repository
```

| Area | Everyday analogy | Git command that moves changes |
|---|---|---|
| Working Directory | Your desk, where you edit files | You edit files normally |
| Staging Area | A packing table for the next shipment | `git add` |
| Local Repository | The permanent project record | `git commit` |

```text
Edit a file
    │
    ▼
Working Directory
    │ git add <file>
    ▼
Staging Area
    │ git commit -m "message"
    ▼
Local Repository
    │ git push
    ▼
GitHub repository
```

---

## A.2 Start Every Investigation with `git status`

### The Target

Identify the exact current Git state before making a decision.

### The Concept

`git status` is your dashboard. It tells you:

- Which branch you are on.
- Whether local work differs from the latest commit.
- Whether files are staged.
- Whether the branch is ahead of or behind GitHub.
- Whether a merge, rebase, or cherry-pick is in progress.

### The Implementation

```bash
git status
```

For a compact version:

```bash
git status --short
```

### The Verification

A healthy, synchronized repository normally reports:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

---

## A.3 Common `git status` Outputs and Safe Next Actions

### State: Clean Working Tree

```text
nothing to commit, working tree clean
```

Meaning:

```text
Working Directory = Staging Area = Latest Commit
```

Safe next actions:

```bash
git pull --ff-only
git switch -c feature/short-description
git log --oneline --decorate -10
```

---

### State: Untracked File

```text
Untracked files:
  new-file.md
```

Meaning:

```text
The file exists on disk, but Git is not tracking it.
```

Inspect it:

```bash
cat new-file.md
```

On PowerShell:

```powershell
Get-Content new-file.md
```

Track it:

```bash
git add new-file.md
```

Ignore it if it is local-only or generated:

```bash
printf "new-file.md\n" >> .gitignore
git add .gitignore
git commit -m "Ignore local generated file"
```

Do not blindly ignore a file just because it is untracked. First determine whether it belongs in the repository.

---

### State: Modified but Not Staged

```text
Changes not staged for commit:
  modified: README.md
```

Meaning:

```text
You changed README.md in the working directory.
The staging area still contains the old version.
```

Inspect the change:

```bash
git diff -- README.md
```

Stage it if intended:

```bash
git add README.md
```

Discard it if it is definitely unwanted:

```bash
git restore README.md
```

> Warning: `git restore README.md` discards uncommitted changes in that file.

---

### State: Changes Staged for Commit

```text
Changes to be committed:
  modified: README.md
```

Meaning:

```text
The next commit will include the staged version of README.md.
```

Inspect exactly what will be committed:

```bash
git diff --staged
```

Create the commit:

```bash
git commit -m "Describe the completed change"
```

Unstage while keeping the file edits:

```bash
git restore --staged README.md
```

---

### State: Local Branch Ahead of GitHub

```text
Your branch is ahead of 'origin/main' by 1 commit.
```

Meaning:

```text
You created a local commit that GitHub does not have yet.
```

Inspect the local-only commit:

```bash
git log --oneline origin/main..HEAD
```

Push it:

```bash
git push
```

---

### State: Local Branch Behind GitHub

```text
Your branch is behind 'origin/main' by 1 commit.
```

Meaning:

```text
GitHub has commits that your local branch does not have.
```

Inspect the incoming commits:

```bash
git fetch origin
git log --oneline main..origin/main
```

Inspect incoming file differences:

```bash
git diff main..origin/main
```

Integrate the changes when ready:

```bash
git pull --ff-only
```

`--ff-only` is a safe default on `main`. It refuses to create an unexpected merge commit.

---

### State: Local and Remote Branches Have Diverged

```text
Your branch and 'origin/main' have diverged,
and have 1 and 1 different commits each, respectively.
```

Meaning:

```text
You have local commits.
GitHub also has commits you do not have.
Neither branch is simply “ahead” of the other.
```

Inspect both sides:

```bash
git fetch origin
git log --oneline origin/main..main
git log --oneline main..origin/main
git log --oneline --decorate --graph --all
```

On a personal feature branch, you may rebase:

```bash
git rebase origin/main
```

On a shared branch or `main`, coordinate with the team. Do not force-push blindly.

---

### State: Merge Conflict

```text
You have unmerged paths.
```

Meaning:

```text
Git could not automatically combine competing edits.
```

Inspect the situation:

```bash
git status
git diff
```

Resolve the conflicting file, then:

```bash
git add <resolved-file>
git commit
```

Cancel the in-progress merge if necessary:

```bash
git merge --abort
```

---

### State: Rebase Conflict

```text
You are currently rebasing branch ...
```

Meaning:

```text
Git paused while replaying commits because it found a conflict.
```

Resolve the file, then:

```bash
git add <resolved-file>
git rebase --continue
```

Other recovery options:

```bash
git rebase --skip
git rebase --abort
```

---

## A.4 Everyday Local Workflow

Use this sequence for an ordinary focused change.

```bash
git switch main
git pull --ff-only
git switch -c feature/short-description
```

Make edits, then inspect them:

```bash
git status
git diff
```

Stage only the intended files:

```bash
git add src/releaseNotes.js src/releaseNotes.test.js
```

Review the future commit:

```bash
git diff --staged
```

Run tests:

```bash
npm test
```

Create a focused commit:

```bash
git commit -m "Add release note validation"
```

Push the branch:

```bash
git push -u origin feature/short-description
```

Then open a pull request on GitHub.

---

## A.5 History Inspection Commands

### Compact History

```bash
git log --oneline
```

Example:

```text
a1b2c3d Add continuous integration workflow
d4e5f6a Add security guidance
e7f8a9b Add release note formatter
```

---

### Branch Graph

```bash
git log --oneline --decorate --graph --all
```

Example:

```text
* a1b2c3d (HEAD -> main, origin/main) Add continuous integration workflow
* d4e5f6a Add security guidance
* e7f8a9b Add release note formatter
```

Use this when you need to understand merges, feature branches, or diverging history.

---

### Show the Latest Commit

```bash
git show HEAD
```

Show only a file summary:

```bash
git show --stat HEAD
```

Show a specific commit:

```bash
git show <commit-hash>
```

---

### Compare Two Commits

```bash
git diff <older-commit> <newer-commit>
```

Example:

```bash
git diff HEAD~1 HEAD
```

This compares the current commit with its immediate parent.

---

### View an Older Version of a File

```bash
git show <commit-hash>:README.md
```

Example:

```bash
git show HEAD~2:README.md
```

This prints `README.md` exactly as it existed two commits earlier.

---

## A.6 Safe Undo Decision Tree

Use this table before undoing anything.

| Situation | Safest command |
|---|---|
| Discard an unstaged change in one file | `git restore <file>` |
| Unstage a file but keep its edits | `git restore --staged <file>` |
| Undo the latest local commit but keep changes staged | `git reset --soft HEAD~1` |
| Undo the latest local commit but keep changes unstaged | `git reset --mixed HEAD~1` |
| Temporarily set aside unfinished work | `git stash push -m "message"` |
| Recover a commit that seems lost | `git reflog` |
| Cancel an in-progress merge | `git merge --abort` |
| Cancel an in-progress rebase | `git rebase --abort` |
| Cancel an in-progress cherry-pick | `git cherry-pick --abort` |

Avoid using this unless you are certain:

```bash
git reset --hard HEAD~1
```

It can permanently discard uncommitted work.

---

## A.7 Remote Synchronization Reference

### Inspect Remotes

```bash
git remote -v
```

Example:

```text
origin  git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git (fetch)
origin  git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git (push)
```

---

### Download Remote Information Only

```bash
git fetch origin
```

This updates remote-tracking branches such as:

```text
origin/main
```

It does not modify your current files.

---

### Inspect Incoming Changes

```bash
git log --oneline main..origin/main
```

Show remote commits missing from local `main`.

```bash
git diff main..origin/main
```

Show file differences between local `main` and remote `main`.

---

### Integrate Remote Changes

```bash
git pull --ff-only
```

Safely update if Git can fast-forward.

```bash
git pull
```

Fetch and merge using Git’s default pull strategy.

```bash
git pull --rebase
```

Fetch and replay local commits on top of incoming remote commits. Use this only when the branch is personal or your team expects rebasing.

---

### Publish Local Commits

```bash
git push
```

Push the current branch to its configured upstream.

For a new branch:

```bash
git push -u origin feature/short-description
```

---

## A.8 Branch Naming Reference

Use names that explain the work:

```text
feature/add-release-export
feature/improve-date-validation
fix/invalid-release-date
fix/empty-markdown-section
docs/add-contribution-guide
chore/update-node-version
ci/add-coverage-reporting
```

Avoid unclear names:

```text
test
updates
my-branch
new
stuff
changes
```

A useful format is:

```text
<category>/<short-action-oriented-description>
```

Common categories:

| Prefix | Use for |
|---|---|
| `feature/` | New user-visible capability |
| `fix/` | Bug fix |
| `docs/` | Documentation-only work |
| `chore/` | Maintenance work |
| `ci/` | Continuous integration or automation |
| `refactor/` | Internal structural improvement without behavior change |

---

## A.9 Commit Message Reference

Use an action-oriented summary:

```text
Add release note formatter
Fix invalid release date handling
Document pull request workflow
Update continuous integration workflow
Remove unused formatter helper
```

Avoid vague messages:

```text
Updates
Fix
Changes
WIP
Stuff
Final version
```

A good commit answers:

> “What changed if I read only this one line?”

For a more detailed commit message:

```bash
git commit
```

Use this structure in the editor:

```text
Add release note formatter

Validate required release metadata and optional release sections.
Generate consistent Markdown output for Added, Changed, and Fixed items.
Add tests for valid input, invalid dates, and invalid section entries.
```

---

## A.10 Emergency Recovery Checklist

If something looks wrong:

```bash
git status
git log --oneline --decorate --graph --all -20
git reflog --date=local -20
```

If you find a lost commit hash:

```bash
git switch -c recovery/my-lost-work <commit-hash>
```

Then inspect safely:

```bash
git status
git log --oneline main..HEAD
git show --stat HEAD
```

Do not rush into `reset --hard`, force pushes, or branch deletion while recovering work.

---

## Appendix A Completion Check

You should now be able to use this quick diagnostic sequence whenever you are uncertain:

```bash
git status
git diff
git diff --staged
git log --oneline --decorate --graph --all -10
```

Then decide whether you need to:

```bash
git add <file>
git commit -m "message"
git fetch origin
git pull --ff-only
git push
```
