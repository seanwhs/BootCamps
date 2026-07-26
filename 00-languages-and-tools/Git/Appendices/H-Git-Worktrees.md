# Appendix H: Git Worktrees, Multiple Working Copies, and Parallel Task Management

A Git **worktree** lets one local repository have multiple checked-out branches in separate folders at the same time.

This is useful when you need to:

- Keep working on a feature while reviewing or fixing something on `main`.
- Compare two branches side by side.
- Prepare a hotfix without stashing unfinished work.
- Run a long test process on one branch while editing another.
- Avoid repeatedly switching branches in one working directory.

Instead of this repeated cycle:

```text
Edit feature branch
    ↓
Stash changes
    ↓
Switch to main
    ↓
Fix urgent problem
    ↓
Switch back
    ↓
Restore stash
```

You can use two folders:

```text
projects/
├── release-notes-manager/             # main branch
└── release-notes-manager-hotfix/      # hotfix branch
```

Both folders use the same underlying Git repository history, but each has its own checked-out files.

---

# H.1 Understand the Worktree Model

## The Target

Understand how worktrees differ from cloning a repository multiple times.

## The Concept

A normal Git repository has one working directory:

```text
release-notes-manager/
├── .git/
├── README.md
├── package.json
└── src/
```

When you switch branches, Git changes the files in that one working directory.

A worktree adds another working directory connected to the same repository:

```text
projects/
├── release-notes-manager/              # Existing worktree: main
│   ├── .git/
│   ├── README.md
│   └── src/
│
└── release-notes-manager-hotfix/       # Additional worktree: hotfix branch
    ├── .git                            # Points back to shared Git metadata
    ├── README.md
    └── src/
```

A worktree is not the same as a full clone.

| Capability | Separate clone | Git worktree |
|---|---|---|
| Separate working files | Yes | Yes |
| Separate branch checkout | Yes | Yes |
| Separate `.git` object database | Yes | No; shared |
| Separate remote configuration | Yes | No; shared |
| Requires downloading repository history again | Usually | No |
| Best for independent machines | Yes | No |
| Best for parallel local tasks | Can work | Usually better |

Think of a clone as a separate copy of a library. Think of worktrees as multiple reading desks connected to the same library archive.

---

# H.2 Inspect Current Worktrees

## The Target

List every working directory attached to the current repository.

## The Concept

Before creating another worktree, inspect the worktrees Git already knows about.

The command:

```bash
git worktree list
```

shows:

- The folder path.
- The commit checked out there.
- The branch attached to that folder.

## The Implementation

From the original repository:

```bash
cd ~/projects/release-notes-manager
```

On Windows PowerShell:

```powershell
Set-Location "$HOME\projects\release-notes-manager"
```

Run:

```bash
git status
git worktree list
```

## The Verification

Expected output resembles:

```text
/Users/your-name/projects/release-notes-manager  a1b2c3d [main]
```

On Windows, the path format differs:

```text
C:/Users/your-name/projects/release-notes-manager  a1b2c3d [main]
```

The important part is:

```text
[main]
```

Your original project folder is the first worktree.

---

# H.3 Create a Hotfix Worktree

## The Target

Create a second working directory on a new hotfix branch.

## The Concept

Imagine you are working on a future feature when an urgent production problem is reported.

Without worktrees, you may need to stash unfinished work before switching branches. With worktrees, you can leave your feature folder untouched and create a separate folder for the urgent fix.

The general command format is:

```bash
git worktree add -b <new-branch-name> <new-folder-path> <starting-point>
```

For this tutorial:

```text
New branch:    hotfix/review-release-date-guidance
New folder:    ../release-notes-manager-hotfix
Starting point: main
```

## The Implementation

First, ensure the original worktree is clean:

```bash
git status
```

Create the new worktree:

```bash
git worktree add -b hotfix/review-release-date-guidance ../release-notes-manager-hotfix main
```

Git will:

1. Create the branch `hotfix/review-release-date-guidance`.
2. Create the `release-notes-manager-hotfix` directory beside the original project directory.
3. Check out the new branch into that directory.

Inspect all worktrees:

```bash
git worktree list
```

## The Verification

Expected output resembles:

```text
/Users/your-name/projects/release-notes-manager         a1b2c3d [main]
/Users/your-name/projects/release-notes-manager-hotfix  a1b2c3d [hotfix/review-release-date-guidance]
```

Confirm that the two folders exist.

### macOS, Linux, or Git Bash

```bash
ls ..
```

### Windows PowerShell

```powershell
Get-ChildItem ..
```

You should see both directories:

```text
release-notes-manager
release-notes-manager-hotfix
```

---

# H.4 Make an Isolated Change in the New Worktree

## The Target

Make and commit a documentation correction in the hotfix worktree without affecting the original working directory.

## The Concept

Each worktree has its own checked-out files.

The two folders share Git history, but modifying a file in one folder does not alter the file currently on disk in the other folder.

You will update `RELEASE_CHECKLIST.md` in the hotfix worktree. This is a documentation-only example, but the same approach works for urgent code fixes.

## The Implementation

Move into the hotfix worktree.

### macOS, Linux, or Git Bash

```bash
cd ~/projects/release-notes-manager-hotfix
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects\release-notes-manager-hotfix"
```

Confirm the branch:

```bash
git branch --show-current
git status
```

Expected branch:

```text
hotfix/review-release-date-guidance
```

Replace the complete contents of `RELEASE_CHECKLIST.md` with the following version.

### `release-notes-manager-hotfix/RELEASE_CHECKLIST.md`

```md
# Release Checklist

Use this checklist before publishing a software release.

## Before Creating the Release

- [ ] Confirm that the working tree is clean with `git status`.
- [ ] Confirm that all intended changes are committed.
- [ ] Review the release notes for accuracy.
- [ ] Verify that the release version follows the project versioning policy.
- [ ] Verify that every release date is a real calendar date in `YYYY-MM-DD` format.
- [ ] Run the project test suite when one is available.

## Before Publishing

- [ ] Confirm the target branch is `main`.
- [ ] Review the commit history with `git log --oneline`.
- [ ] Verify that no secrets, local environment files, or build artifacts are included.
- [ ] Confirm that the release date is correct.
- [ ] Ask another contributor to review significant changes.

## After Publishing

- [ ] Update the release status.
- [ ] Announce the release to affected users.
- [ ] Create follow-up issues for known limitations or deferred work.

## Release Ownership

- [ ] Assign one person to coordinate the release.
- [ ] Identify a backup owner for urgent release questions.
- [ ] Record the release owner in the pull request or issue that tracks the release.
```

Review and commit the change:

```bash
git diff -- RELEASE_CHECKLIST.md
git add RELEASE_CHECKLIST.md
git diff --staged
git commit -m "Clarify release date validation checklist"
```

Run tests:

```bash
npm test
```

## The Verification

Check the hotfix worktree status:

```bash
git status
```

Expected output:

```text
On branch hotfix/review-release-date-guidance
nothing to commit, working tree clean
```

Now inspect the original worktree without switching branches in the hotfix folder.

### macOS, Linux, or Git Bash

```bash
cd ~/projects/release-notes-manager
git status
git branch --show-current
git diff -- RELEASE_CHECKLIST.md
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects\release-notes-manager"
git status
git branch --show-current
git diff -- RELEASE_CHECKLIST.md
```

Expected result:

```text
main
```

And the diff command should produce no output. The original `main` worktree has not changed on disk.

---

# H.5 Push and Merge the Hotfix Through a Pull Request

## The Target

Publish the hotfix branch and merge it using the protected-branch workflow.

## The Concept

A worktree changes how you organize local folders. It does not replace code review, pull requests, CI, or branch protection.

The hotfix should still follow the same delivery process:

```text
Hotfix worktree
    ↓
Commit
    ↓
Push branch
    ↓
Pull request
    ↓
CI and review
    ↓
Merge to main
```

## The Implementation

Return to the hotfix worktree.

### macOS, Linux, or Git Bash

```bash
cd ~/projects/release-notes-manager-hotfix
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects\release-notes-manager-hotfix"
```

Push the branch:

```bash
git push -u origin hotfix/review-release-date-guidance
```

Open a pull request on GitHub with:

```text
Clarify release date validation checklist
```

Use this PR description:

```md
## Summary

Clarifies that release dates must be real calendar dates in `YYYY-MM-DD` format before a release is published.

## Changes

- Add a release checklist item requiring validation of real calendar dates.

## Verification

```bash
npm test
```

## Risk

Low. This is a documentation-only clarification that matches the formatter's existing date-validation behavior.
```

Allow CI to run, complete review, and merge the pull request into `main`.

## The Verification

On GitHub, confirm:

- The pull request targets `main`.
- GitHub Actions passes.
- The final diff contains only `RELEASE_CHECKLIST.md`.
- The pull request is merged.

---

# H.6 Update the Original `main` Worktree

## The Target

Update the original worktree after the hotfix pull request merges.

## The Concept

Each worktree has its own branch checkout and working files.

Merging the pull request changes `origin/main` on GitHub, but your original local `main` folder still needs to pull the new commit.

## The Implementation

Move to the original worktree.

### macOS, Linux, or Git Bash

```bash
cd ~/projects/release-notes-manager
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects\release-notes-manager"
```

Update it:

```bash
git pull --ff-only
npm test
```

Inspect the latest checklist content:

```bash
git show HEAD:RELEASE_CHECKLIST.md
```

## The Verification

Confirm the new line appears:

```md
- [ ] Verify that every release date is a real calendar date in `YYYY-MM-DD` format.
```

Confirm the original worktree is clean:

```bash
git status
```

Expected output:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

---

# H.7 Remove a Completed Worktree

## The Target

Remove the completed hotfix worktree and delete its merged branch.

## The Concept

When a worktree is no longer needed, remove it through Git instead of deleting the directory manually.

The command:

```bash
git worktree remove <path>
```

removes the working directory and cleans up Git’s internal worktree records.

Before removing it, ensure the worktree is clean. Git protects worktrees with uncommitted changes unless you use `--force`.

## The Implementation

From the original worktree:

```bash
cd ~/projects/release-notes-manager
```

List worktrees:

```bash
git worktree list
```

Remove the completed hotfix worktree:

```bash
git worktree remove ../release-notes-manager-hotfix
```

Delete the merged branch:

```bash
git branch -d hotfix/review-release-date-guidance
```

Prune stale internal worktree metadata:

```bash
git worktree prune
```

## The Verification

Run:

```bash
git worktree list
git branch
```

Expected result:

```text
/Users/your-name/projects/release-notes-manager  <hash> [main]
```

And branch output should include only your active branches, without:

```text
hotfix/review-release-date-guidance
```

Confirm the hotfix folder was removed.

### macOS, Linux, or Git Bash

```bash
test ! -d ../release-notes-manager-hotfix && echo "Hotfix worktree removed."
```

### Windows PowerShell

```powershell
if (-not (Test-Path "..\release-notes-manager-hotfix")) {
  Write-Output "Hotfix worktree removed."
}
```

---

# H.8 Add an Existing Branch as a Worktree

## The Target

Create a worktree for an existing branch rather than creating a new branch.

## The Concept

Sometimes the branch already exists:

```text
feature/add-export-command
```

You can check it out into a new worktree with:

```bash
git worktree add <directory> <existing-branch>
```

Git prevents one branch from being checked out in two worktrees simultaneously. This safety rule prevents two folders from independently modifying the same branch state.

## The Implementation

Assume an existing branch named:

```text
feature/add-export-command
```

Create a new worktree:

```bash
git worktree add ../release-notes-manager-export feature/add-export-command
```

If you only want to practice the command structure and that branch does not exist, create a temporary branch:

```bash
git branch practice/worktree-existing-branch main
git worktree add ../release-notes-manager-practice practice/worktree-existing-branch
```

Inspect:

```bash
git worktree list
```

When done, remove it:

```bash
git worktree remove ../release-notes-manager-practice
git branch -d practice/worktree-existing-branch
git worktree prune
```

## The Verification

`git worktree list` should show the additional folder and its attached branch.

---

# H.9 Worktree Safety Rules

## The Target

Avoid common worktree mistakes.

## The Concept

Worktrees are straightforward once you remember that branches are still shared repository references.

Follow these rules:

```text
1. One branch can be checked out in only one worktree at a time.
2. Commit from the worktree that owns the branch.
3. Pull updates separately in each worktree when needed.
4. Remove completed worktrees with git worktree remove.
5. Do not manually edit .git files inside a linked worktree.
6. Do not use worktrees as a replacement for commits or backups.
```

### Important: Shared Repository Configuration

Worktrees share repository configuration and object storage.

If you run this in one worktree:

```bash
git remote set-url origin <new-url>
```

the remote URL changes for all worktrees belonging to that repository.

Likewise, local branches and tags are shared across worktrees.

### Important: Separate Working Files

Files on disk are separate per worktree.

This means:

```text
release-notes-manager/
└── README.md version from main

release-notes-manager-feature/
└── README.md version from feature branch
```

This separation is the primary benefit of worktrees.

## The Implementation

Inspect the active branch in each worktree:

```bash
git worktree list
```

Inspect branch checkout ownership:

```bash
git branch --verbose --verbose
```

A branch checked out in another worktree may show its worktree path in the output.

## The Verification

Confirm you can answer:

- Which worktree currently owns `main`?
- Which folder contains your feature branch?
- Which branches are safe to delete?
- Which worktrees are completed and ready to remove?

---

# H.10 Worktree Command Reference

## List Worktrees

```bash
git worktree list
```

## Create a New Branch in a New Worktree

```bash
git worktree add -b feature/short-description ../project-feature main
```

## Add an Existing Branch as a Worktree

```bash
git worktree add ../project-feature feature/short-description
```

## Create a Detached Worktree at a Tag or Commit

Useful for inspecting a release without modifying a branch:

```bash
git worktree add --detach ../project-v1.0.0 v1.0.0
```

Remove it when finished:

```bash
git worktree remove ../project-v1.0.0
```

## Remove a Worktree

```bash
git worktree remove ../project-feature
```

## Force Remove a Worktree

Use only when you intentionally want to discard its uncommitted work:

```bash
git worktree remove --force ../project-feature
```

## Remove Stale Metadata

```bash
git worktree prune
```

---

# H.11 When to Use Worktrees Instead of Stash

## The Target

Choose the right tool for unfinished work and parallel tasks.

## The Concept

Both stashes and worktrees can help when you need to change context, but they solve different problems.

| Situation | Better choice | Why |
|---|---|---|
| Briefly set aside a few unfinished edits | Stash | Fast temporary shelf for small work-in-progress changes |
| Work on a hotfix while preserving an active feature workspace | Worktree | Both branches stay available in separate folders |
| Compare two branch versions side by side | Worktree | No repeated checkout switching needed |
| Preserve work for days or weeks | Commit on a branch | A stash is not durable project history |
| Review a pull request locally while feature work continues | Worktree | Separate PR checkout avoids disrupting current files |
| Move to another branch for a few minutes | Stash or commit | Choose the simpler option based on work value |

A useful rule:

> If you expect to return to the work repeatedly or run tools in parallel, use a worktree.  
> If you only need to briefly clear your working directory, use a stash.

---

# Appendix H Completion Check

You should now be able to:

- [ ] Explain the difference between a clone and a worktree.
- [ ] List repository worktrees with `git worktree list`.
- [ ] Create a new branch in a separate worktree.
- [ ] Make changes in one worktree without changing files in another.
- [ ] Push and merge worktree changes through the usual pull-request workflow.
- [ ] Update the original `main` worktree after a merge.
- [ ] Remove completed worktrees safely.
- [ ] Choose between using a stash, a feature branch, and a worktree.
