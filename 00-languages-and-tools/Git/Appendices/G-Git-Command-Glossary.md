# Appendix G: Git Command Glossary and Workflow Cheat Sheets

This appendix is a compact reference for the commands used throughout the series.

It is organized around real tasks rather than Git’s internal terminology. When you need to perform an action, find the matching workflow and copy the commands carefully.

> Safety habit: before any unfamiliar or potentially destructive command, run:
>
> ```bash
> git status
> ```

---

# G.1 Essential Command Glossary

## Repository Setup

| Command | Purpose |
|---|---|
| `git init` | Create a new Git repository in the current directory. |
| `git clone <url>` | Download a local working copy of an existing repository. |
| `git config --global user.name "Name"` | Set the default commit author name. |
| `git config --global user.email "email"` | Set the default commit author email. |
| `git config --list` | Display Git configuration values. |

### Example

```bash
git config --global user.name "Jordan Lee"
git config --global user.email "jordan.lee@example.com"
git config --global init.defaultBranch main
```

---

## Inspecting State

| Command | Purpose |
|---|---|
| `git status` | Show current branch, untracked files, staged files, and synchronization state. |
| `git diff` | Show unstaged changes. |
| `git diff --staged` | Show changes prepared for the next commit. |
| `git log --oneline` | Show compact commit history. |
| `git show HEAD` | Show the latest commit and its patch. |
| `git branch` | List local branches. |
| `git remote -v` | List configured remote repositories. |

### Everyday Inspection Sequence

```bash
git status
git diff
git diff --staged
git log --oneline --decorate --graph --all -10
```

---

## Staging and Committing

| Command | Purpose |
|---|---|
| `git add <file>` | Stage one file for the next commit. |
| `git add .` | Stage changes under the current directory. Use carefully. |
| `git commit -m "message"` | Create a commit from staged changes. |
| `git commit --amend` | Replace the latest commit with a corrected version. |
| `git restore --staged <file>` | Unstage a file while keeping its working-directory edits. |

### Focused Commit Workflow

```bash
git status
git diff
git add src/releaseNotes.js src/releaseNotes.test.js
git diff --staged
npm test
git commit -m "Add release note validation"
```

---

## Branching

| Command | Purpose |
|---|---|
| `git branch` | List local branches. |
| `git branch <name>` | Create a branch without switching to it. |
| `git switch <name>` | Switch to an existing branch. |
| `git switch -c <name>` | Create and switch to a new branch. |
| `git branch -d <name>` | Safely delete a merged local branch. |
| `git branch -D <name>` | Force-delete a local branch with unmerged commits. |

### Start New Feature Work

```bash
git switch main
git pull --ff-only
git switch -c feature/add-release-export
```

---

## Remote Synchronization

| Command | Purpose |
|---|---|
| `git fetch origin` | Download remote information without changing current files. |
| `git pull` | Fetch and integrate remote changes. |
| `git pull --ff-only` | Update only if Git can fast-forward safely. |
| `git push` | Push commits to the configured upstream branch. |
| `git push -u origin <branch>` | Push a new branch and set upstream tracking. |
| `git fetch --prune` | Remove stale remote-tracking branch references. |

### Safely Update `main`

```bash
git switch main
git fetch origin
git log --oneline main..origin/main
git pull --ff-only
```

### Publish a New Feature Branch

```bash
git push -u origin feature/add-release-export
```

---

# G.2 Common Workflows

## Workflow: Start a New Feature

### The Target

Create a focused branch from the latest `main`.

### The Implementation

```bash
git switch main
git pull --ff-only
git status
git switch -c feature/short-description
```

### The Verification

```bash
git branch --show-current
```

Expected output:

```text
feature/short-description
```

---

## Workflow: Finish and Publish a Feature

### The Target

Create a clean commit, push the branch, and prepare for a pull request.

### The Implementation

```bash
git status
git diff
git add <intended-file-paths>
git diff --staged
npm test
git commit -m "Describe the completed feature"
git push -u origin feature/short-description
```

### The Verification

```bash
git status
```

Expected output resembles:

```text
On branch feature/short-description
Your branch is up to date with 'origin/feature/short-description'.

nothing to commit, working tree clean
```

Open a pull request from the branch into `main`.

---

## Workflow: Update a Feature Branch After `main` Changes

### The Target

Bring the latest `main` work into an open pull-request branch.

### The Concept

Use merging as the safer default for a shared feature branch.

### The Implementation

```bash
git switch feature/short-description
git fetch origin
git merge origin/main
npm test
git push
```

If Git reports a conflict:

```bash
git status
```

Resolve the file, then:

```bash
git add <resolved-file>
npm test
git commit
git push
```

### The Verification

```bash
git log --oneline --decorate --graph --all -10
git status
```

Your feature branch should include the latest `origin/main` commit.

---

## Workflow: Rebase a Personal Feature Branch

### The Target

Create a linear feature history on top of current `main`.

### The Concept

Use rebase only when the branch is yours to rewrite and collaborators are not building on its current commits.

### The Implementation

```bash
git switch feature/short-description
git fetch origin
git rebase origin/main
npm test
git push --force-with-lease
```

If conflicts occur:

```bash
git status
git add <resolved-file>
git rebase --continue
```

To abandon the rebase:

```bash
git rebase --abort
```

### The Verification

```bash
git status
git log --oneline --decorate --graph --all -10
```

---

## Workflow: Undo an Unstaged File Edit

### The Target

Discard a file change that has not been staged or committed.

### The Implementation

Inspect the change first:

```bash
git diff -- README.md
```

Discard it:

```bash
git restore README.md
```

### The Verification

```bash
git diff -- README.md
```

Expected result: no output.

> Warning: this discards uncommitted work in the file.

---

## Workflow: Unstage a File Without Losing Changes

### The Target

Remove a file from the next commit while keeping its edits.

### The Implementation

```bash
git restore --staged README.md
```

### The Verification

```bash
git status
```

Expected output places `README.md` under:

```text
Changes not staged for commit
```

---

## Workflow: Temporarily Set Aside Work

### The Target

Clean the working tree without committing unfinished work.

### The Implementation

```bash
git stash push --include-untracked -m "Describe unfinished work"
```

Inspect stashes:

```bash
git stash list
git stash show --patch stash@{0}
```

Restore safely:

```bash
git stash apply stash@{0}
```

Or restore and remove:

```bash
git stash pop
```

### The Verification

After stashing:

```bash
git status
```

Expected result:

```text
nothing to commit, working tree clean
```

---

## Workflow: Recover a Lost Commit

### The Target

Find a commit after deleting a branch, resetting incorrectly, or amending history.

### The Implementation

```bash
git reflog --date=local -30
```

Find the desired commit hash, then preserve it:

```bash
git switch -c recovery/lost-work <commit-hash>
```

### The Verification

```bash
git log --oneline main..HEAD
```

The recovered commit should appear in the output.

---

## Workflow: Move One Commit to Another Branch

### The Target

Apply one focused change without merging an entire branch.

### The Implementation

Find the source commit:

```bash
git log --oneline feature/source-branch
```

Switch to the target branch:

```bash
git switch main
git pull --ff-only
```

Apply the commit:

```bash
git cherry-pick <commit-hash>
```

### The Verification

```bash
git show --stat HEAD
```

The latest commit should contain the selected change.

---

# G.3 Merge, Rebase, and Cherry-Pick Decision Table

| Situation | Preferred tool | Why |
|---|---|---|
| Merge a completed shared feature into `main` | Pull request merge | Preserves review and CI workflow. |
| Update a shared feature branch with `main` | `git merge origin/main` | Does not rewrite pushed commit history. |
| Update your private feature branch before PR | `git rebase origin/main` | Produces a linear personal branch history. |
| Apply one hotfix from another branch | `git cherry-pick <hash>` | Copies only the required commit. |
| Undo an unpushed commit but keep its changes | `git reset --soft HEAD~1` | Keeps changes staged. |
| Recover accidentally moved or deleted work | `git reflog` | Finds recent reference locations. |

---

# G.4 Reset Quick Reference

| Command | Commit history | Staging area | Working files | Typical use |
|---|---|---|---|---|
| `git reset --soft HEAD~1` | Moves back | Keeps staged | Keeps unchanged | Redo latest commit cleanly |
| `git reset --mixed HEAD~1` | Moves back | Unstages | Keeps unchanged | Re-select changes for commits |
| `git reset --hard HEAD~1` | Moves back | Resets | Overwrites | Discard disposable local work |

Before any reset:

```bash
git status
git log --oneline --decorate -5
```

Before `--hard`, preserve work if needed:

```bash
git branch backup/before-hard-reset
```

or:

```bash
git stash push --include-untracked -m "Backup before hard reset"
```

---

# G.5 GitHub Pull Request Workflow Cheat Sheet

## Before Opening the Pull Request

```bash
git status
git diff main...HEAD
npm test
git log --oneline main..HEAD
```

Confirm:

```text
[ ] Branch has one focused purpose.
[ ] Tests pass.
[ ] Documentation is updated.
[ ] No secrets or generated files are included.
[ ] Commit messages are meaningful.
```

## Pull Request Description Structure

```md
## Summary

Explain the outcome.

Closes #ISSUE_NUMBER

## Changes

- Describe meaningful implementation changes.
- Describe test changes.
- Describe documentation changes.

## Verification

```bash
npm test
```

## Review Focus

Identify risky or complex areas where feedback is especially useful.
```

## Before Merging

```text
[ ] Required reviews are approved.
[ ] CI checks are green.
[ ] Conversations are resolved.
[ ] Branch is current with main if required.
[ ] Final diff contains only intended changes.
```

## After Merging

```bash
git switch main
git pull --ff-only
git fetch --prune
git branch -d feature/short-description
```

---

# G.6 GitHub Actions Workflow Cheat Sheet

## Minimal Node.js CI Workflow

### `.github/workflows/ci.yml`

```yaml
name: Continuous Integration

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

permissions:
  contents: read

jobs:
  test:
    name: Run Node.js tests
    runs-on: ubuntu-latest

    steps:
      - name: Check out repository
        uses: actions/checkout@v4

      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      - name: Install dependencies
        run: npm install

      - name: Run test suite
        run: npm test
```

## CI Failure Investigation Sequence

1. Open the pull request’s **Checks** tab.
2. Select the failed workflow run.
3. Expand the failed step.
4. Read the first meaningful error message.
5. Reproduce locally:

   ```bash
   npm test
   ```

6. Fix the underlying issue.
7. Run tests again.
8. Commit and push the fix.

Do not change tests merely to make CI green unless the test expectation is genuinely wrong.

---

# G.7 Git Alias Suggestions

## The Target

Create short, readable aliases for commonly used read-only commands.

## The Concept

Aliases reduce typing, but they should not hide dangerous behavior.

Good aliases shorten inspection commands. Avoid aliases that make destructive commands easy to run without thinking.

## The Implementation

Add these safe aliases:

```bash
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.last "log -1 --stat"
git config --global alias.lg "log --oneline --decorate --graph --all"
git config --global alias.unstage "restore --staged"
```

Use them:

```bash
git st
git lg
git last
```

## The Verification

List configured aliases:

```bash
git config --global --get-regexp '^alias\.'
```

Expected output resembles:

```text
alias.st status
alias.lg log --oneline --decorate --graph --all
```

> Note: `git co` maps to the older overloaded `git checkout`. Prefer `git switch` for branches and `git restore` for files when teaching or writing new documentation.

---

# G.8 Commands That Require Extra Caution

These commands are valid, but should never be run mechanically.

| Command | Risk | Safer habit |
|---|---|---|
| `git reset --hard` | Discards tracked uncommitted work. | Check `git status`; create a backup branch or stash first. |
| `git push --force` | Can overwrite shared remote history. | Prefer `git push --force-with-lease` on branches you own. |
| `git branch -D` | Deletes unmerged branch references. | Use `git branch -d` first. |
| `git clean -fd` | Deletes untracked files and folders. | Run `git clean -nd` as a dry run first. |
| `git rebase` | Rewrites commit hashes. | Rebase only personal or coordinated branches. |
| `git restore <file>` | Discards uncommitted file edits. | Inspect with `git diff` first. |

## Safe `git clean` Preview

Before removing untracked files:

```bash
git clean -nd
```

The `-n` means “dry run.” It shows what Git would delete.

Only if the preview is correct:

```bash
git clean -fd
```

Do not run `git clean -fdx` unless you fully understand that `-x` includes ignored files such as local `.env` files and dependency directories.

---

# G.9 Recommended Daily Git Routine

At the beginning of work:

```bash
git switch main
git pull --ff-only
git status
git switch -c feature/short-description
```

Before committing:

```bash
git status
git diff
git add <intended-files>
git diff --staged
npm test
```

Before opening a pull request:

```bash
git diff main...HEAD
git log --oneline main..HEAD
npm test
git push
```

After a pull request merges:

```bash
git switch main
git pull --ff-only
git fetch --prune
git branch -d feature/short-description
```

---

# Appendix G Completion Check

You should now have a compact reference for:

- [ ] Starting, publishing, and merging feature branches.
- [ ] Inspecting local and remote repository state.
- [ ] Safely staging, committing, restoring, and stashing work.
- [ ] Choosing between merge, rebase, and cherry-pick.
- [ ] Recovering from common mistakes.
- [ ] Preparing pull requests.
- [ ] Investigating CI failures.
- [ ] Using aliases and dry runs without hiding important Git behavior.
