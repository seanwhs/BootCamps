# Part 2: Navigating Parallel Universes — Branching and Merging

In Part 1, you created a clean local Git repository and learned how to record history with commits.

In this part, you will learn how to work on multiple changes at the same time without destabilizing the main version of the project.

You will create branches, make independent changes, merge completed work, intentionally create a merge conflict, resolve it safely, and compare merging with rebasing.

No GitHub is required yet. Everything happens locally.

---

## Part 2 Roadmap

You will learn how to:

1. Understand branches as lightweight pointers to commits.
2. Create, list, switch, and delete branches.
3. Merge a branch through a fast-forward merge.
4. Merge diverging histories with a three-way merge commit.
5. Understand why merge conflicts occur.
6. Read and resolve conflict markers.
7. Use `git rebase` to create a linear history.
8. Know when merging is safer than rebasing.

---

# Step 1: Understand What a Git Branch Actually Is

## The Target

Build a correct mental model of Git branches before creating one.

## The Concept

A branch is not a full copy of your project.

It is a lightweight label—technically, a **pointer**—that identifies one particular commit.

At the end of Part 1, your local history resembles this:

```text
* E (HEAD -> main) Add local development guidance
* D Clarify project status
* C Add release notes template
* B Document contribution guidelines
* A Add initial project documentation
```

The names `A` through `E` are simplified labels for illustration. Your real commits use hashes such as:

```text
e7f8a9b
```

The important relationship is:

```text
main → E
HEAD → main
```

`HEAD` means “where you are currently working.” Since `HEAD` points to `main`, you are currently working on the `main` branch.

Now imagine creating a branch named `add-release-checklist`:

```text
                    add-release-checklist
                              │
                              ▼
* E (HEAD -> main) Add local development guidance
* D Clarify project status
* C Add release notes template
* B Document contribution guidelines
* A Add initial project documentation
```

Initially, both branch names point to the same commit. When you make a new commit while working on `add-release-checklist`, only that branch moves forward:

```text
* F (HEAD -> add-release-checklist) Add release checklist
* E (main) Add local development guidance
* D Clarify project status
* C Add release notes template
* B Document contribution guidelines
* A Add initial project documentation
```

`main` remains stable at commit `E`. Your feature work exists safely on the new branch.

This is why branches are useful: they let you explore, build, test, and revise a feature without changing the stable line of work.

## The Implementation

Inspect your current history:

```bash
git log --oneline --decorate --graph --all
```

Inspect your active branch:

```bash
git branch --show-current
```

List branches:

```bash
git branch
```

## The Verification

Expected output from:

```bash
git branch --show-current
```

```text
main
```

Expected output from:

```bash
git branch
```

```text
* main
```

The asterisk (`*`) marks the branch currently checked out.

Before moving on, confirm your working tree is clean:

```bash
git status
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

---

# Step 2: Create and Switch to a Feature Branch

## The Target

Create a branch named `add-release-checklist` and make it your active branch.

## The Concept

A feature branch is a branch dedicated to one focused piece of work.

Good branch names communicate intent. Prefer names such as:

```text
add-release-checklist
fix-release-date-validation
update-contribution-guide
```

Avoid vague names such as:

```text
new-stuff
test
changes
branch-2
```

Git provides two common workflows for creating and moving to a branch.

Older syntax:

```bash
git checkout -b add-release-checklist
```

Modern, clearer syntax:

```bash
git switch -c add-release-checklist
```

The `-c` means “create.” This command:

1. Creates the branch.
2. Switches your working directory to that branch.

We will use `git switch` because it is designed specifically for branch navigation.

## The Implementation

From the clean `main` branch, run:

```bash
git switch -c add-release-checklist
```

List branches:

```bash
git branch
```

Inspect the graph:

```bash
git log --oneline --decorate --graph --all
```

## The Verification

Expected branch output:

```text
* add-release-checklist
  main
```

Expected history shape:

```text
* <hash> (HEAD -> add-release-checklist, main) Add local development guidance
* <hash> Clarify project status
* <hash> Add release notes template
* <hash> Document contribution guidelines
* <hash> Add initial project documentation
```

Both branches point to the same latest commit right now.

Confirm the active branch:

```bash
git status
```

Expected first line:

```text
On branch add-release-checklist
```

---

# Step 3: Build a Release Checklist on the Feature Branch

## The Target

Create a focused `RELEASE_CHECKLIST.md` file and commit it on the `add-release-checklist` branch.

## The Concept

A branch becomes useful when it gets its own commits.

You will add a release checklist: a practical document developers can follow before publishing release notes. This change belongs only to the feature branch until it is reviewed and merged.

At this point, the relationship is:

```text
main → E
add-release-checklist → E
HEAD → add-release-checklist
```

After your commit:

```text
add-release-checklist → F
main → E
HEAD → add-release-checklist
```

The project files on `main` will not include the new checklist until you merge the branch.

## The Implementation

Create the following file.

### `release-notes-manager/RELEASE_CHECKLIST.md`

```md
# Release Checklist

Use this checklist before publishing a software release.

## Before Creating the Release

- [ ] Confirm that the working tree is clean with `git status`.
- [ ] Confirm that all intended changes are committed.
- [ ] Review the release notes for accuracy.
- [ ] Verify that the release version follows the project versioning policy.
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
```

Review the uncommitted file:

```bash
git status
git diff -- RELEASE_CHECKLIST.md
```

Because the file is untracked, `git diff` does not display it by default. Use this command to read it directly:

```bash
cat RELEASE_CHECKLIST.md
```

On Windows PowerShell, use:

```powershell
Get-Content RELEASE_CHECKLIST.md
```

Stage and commit the file:

```bash
git add RELEASE_CHECKLIST.md
git diff --staged
git commit -m "Add release checklist"
```

## The Verification

Run:

```bash
git status
git log --oneline --decorate --graph --all
```

Expected history shape:

```text
* <hash> (HEAD -> add-release-checklist) Add release checklist
* <hash> (main) Add local development guidance
* <hash> Clarify project status
* <hash> Add release notes template
* <hash> Document contribution guidelines
* <hash> Add initial project documentation
```

The important observation is that `main` still points to the earlier commit.

Switch temporarily to `main`:

```bash
git switch main
```

List files.

### macOS, Linux, or Git Bash

```bash
ls
```

### Windows PowerShell

```powershell
Get-ChildItem
```

`RELEASE_CHECKLIST.md` should not exist on `main`.

Switch back to the feature branch:

```bash
git switch add-release-checklist
```

List files again:

### macOS, Linux, or Git Bash

```bash
ls
```

### Windows PowerShell

```powershell
Get-ChildItem
```

`RELEASE_CHECKLIST.md` should exist again.

This demonstrates that branches can provide different versions of the project files.

---

# Step 4: Merge the Feature with a Fast-Forward Merge

## The Target

Merge `add-release-checklist` into `main` using a fast-forward merge.

## The Concept

A **fast-forward merge** happens when `main` has not changed since the feature branch was created.

Your current history looks like this:

```text
* F (add-release-checklist) Add release checklist
* E (main) Add local development guidance
```

Since `main` is directly behind the feature branch, Git does not need to combine two independent lines of history. It simply moves the `main` label forward from `E` to `F`.

Before:

```text
main → E
add-release-checklist → F
```

After:

```text
main → F
add-release-checklist → F
```

This is called “fast-forward” because Git advances the `main` pointer without creating an extra merge commit.

Important rule:

> You merge *into the branch you currently have checked out.*

To merge a feature into `main`:

1. Switch to `main`.
2. Run `git merge <feature-branch-name>`.

## The Implementation

Switch to `main`:

```bash
git switch main
```

Confirm that `main` does not yet contain the checklist:

```bash
git status
```

Merge the feature branch:

```bash
git merge add-release-checklist
```

## The Verification

Git should print output similar to:

```text
Updating <old-hash>..<new-hash>
Fast-forward
 RELEASE_CHECKLIST.md | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)
 create mode 100644 RELEASE_CHECKLIST.md
```

Inspect the graph:

```bash
git log --oneline --decorate --graph --all
```

Expected shape:

```text
* <hash> (HEAD -> main, add-release-checklist) Add release checklist
* <hash> Add local development guidance
* <hash> Clarify project status
* <hash> Add release notes template
* <hash> Document contribution guidelines
* <hash> Add initial project documentation
```

Confirm that the file exists on `main`:

```bash
git show HEAD:RELEASE_CHECKLIST.md
```

Confirm the repository is clean:

```bash
git status
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

---

# Step 5: Delete the Merged Feature Branch

## The Target

Delete the local `add-release-checklist` branch after merging it.

## The Concept

Once a feature branch has been merged, keeping it usually provides no value. Its commits remain safely available through `main`.

Deleting the branch deletes only the branch label, not the commits that are now part of `main`.

Use:

```bash
git branch -d <branch-name>
```

The lowercase `-d` is a safe deletion mode. Git refuses to delete the branch if its changes have not been merged into your current branch.

There is also a force deletion option:

```bash
git branch -D <branch-name>
```

The uppercase `-D` can delete a branch even if it contains unmerged work. Do not use it casually. We will not need it in this tutorial.

## The Implementation

Ensure you are on `main`:

```bash
git branch --show-current
```

Delete the merged branch:

```bash
git branch -d add-release-checklist
```

List remaining branches:

```bash
git branch
```

## The Verification

Expected output resembles:

```text
Deleted branch add-release-checklist (was <hash>).
```

Then:

```bash
git branch
```

should show:

```text
* main
```

Inspect history:

```bash
git log --oneline --decorate --graph --all
```

The `Add release checklist` commit remains in history because `main` contains it.

---

# Step 6: Create Two Parallel Lines of Work

## The Target

Create a feature branch and make a separate commit on `main` so that the histories diverge.

## The Concept

A fast-forward merge works only when `main` has not moved ahead independently.

In real projects, other work often lands on `main` while you are developing a feature. This produces a diverging history.

You will create this situation intentionally:

```text
          * G (main) Add project terminology
         /
* F ----
         \
          * H (improve-release-template) Expand release template
```

Both branches start from commit `F`, then each receives a different commit.

When you merge later, Git will need a **three-way merge**.

The three inputs are:

1. The common ancestor commit (`F`).
2. The current branch tip (`G`).
3. The branch being merged (`H`).

Git compares both branch tips against their common ancestor, then attempts to combine their independent changes.

## The Implementation

Create and switch to a new feature branch:

```bash
git switch -c improve-release-template
```

Update `RELEASE_NOTES.md` to the complete content below.

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

## Writing Guidelines

- Write release notes in clear language for the intended audience.
- Group changes under Added, Changed, Fixed, Deprecated, Removed, or Security headings when applicable.
- Include issue or pull request references when the project uses them.
- Describe user-facing impact instead of only internal implementation details.
```

Stage and commit this feature change:

```bash
git add RELEASE_NOTES.md
git commit -m "Add release note writing guidelines"
```

Now switch back to `main`:

```bash
git switch main
```

Create the following file.

### `release-notes-manager/GLOSSARY.md`

```md
# Project Glossary

## Branch

A named line of development that points to a specific commit.

## Commit

A recorded snapshot of staged project changes.

## Merge

The process of combining changes from one branch into another branch.

## Repository

A project directory that Git tracks, including its history and configuration.

## Staging Area

The intermediate area where selected changes are prepared before creating a commit.
```

Stage and commit the `main` branch change:

```bash
git add GLOSSARY.md
git commit -m "Add project terminology glossary"
```

## The Verification

Run:

```bash
git log --oneline --decorate --graph --all
```

Expected shape:

```text
* <hash> (HEAD -> main) Add project terminology glossary
| * <hash> (improve-release-template) Add release note writing guidelines
|/
* <hash> Add release checklist
* <hash> Add local development guidance
...
```

The graph proves that both branches made separate progress after the same shared commit.

---

# Step 7: Merge Diverging Histories with a Three-Way Merge Commit

## The Target

Merge `improve-release-template` into `main` after both branches have independent commits.

## The Concept

This merge cannot fast-forward because `main` and `improve-release-template` each have work the other branch does not contain.

Current shape:

```text
* G (HEAD -> main) Add project terminology glossary
| * H (improve-release-template) Add release note writing guidelines
|/
* F Add release checklist
```

When you merge the feature into `main`, Git creates a new merge commit:

```text
*   I (HEAD -> main) Merge branch 'improve-release-template'
|\
| * H (improve-release-template) Add release note writing guidelines
* | G Add project terminology glossary
|/
* F Add release checklist
```

The merge commit `I` has two parents:

- The previous `main` commit.
- The feature branch commit.

This graph records the fact that independent lines of work were intentionally combined.

## The Implementation

Confirm you are on `main`:

```bash
git branch --show-current
```

Merge the feature branch:

```bash
git merge improve-release-template
```

Git may open your configured editor for a merge commit message. If it does, keep the default message:

```text
Merge branch 'improve-release-template'
```

Save and close the editor.

If Git completes the merge without opening an editor, that is also normal.

## The Verification

Run:

```bash
git status
git log --oneline --decorate --graph --all
```

Expected graph shape:

```text
*   <hash> (HEAD -> main) Merge branch 'improve-release-template'
|\
| * <hash> (improve-release-template) Add release note writing guidelines
* | <hash> Add project terminology glossary
|/
* <hash> Add release checklist
...
```

Verify both changes are present:

```bash
git show HEAD:GLOSSARY.md
git show HEAD:RELEASE_NOTES.md
```

Confirm the merge commit has two parent commits:

```bash
git show --no-patch --format=raw HEAD
```

You should see two lines beginning with `parent`, similar to:

```text
parent <main-parent-hash>
parent <feature-parent-hash>
```

Now delete the merged feature branch:

```bash
git branch -d improve-release-template
```

---

# Step 8: Create an Intentional Merge Conflict

## The Target

Create two branches that modify the same lines differently, then trigger a merge conflict.

## The Concept

A merge conflict is not a Git failure. It means Git detected two valid but incompatible instructions and needs a human decision.

For example, imagine two editors changing the same sentence:

```text
Original:
The project is in its initial documentation and planning phase.
```

One branch changes it to:

```text
The project is in its active documentation and planning phase.
```

Another branch changes it to:

```text
The project is in its active development phase.
```

Git cannot safely guess which wording you want. It pauses the merge and marks the conflict in the file.

A conflict is most likely when branches:

- Edit the same lines differently.
- Delete and edit the same content.
- Rename or move files in incompatible ways.
- Apply changes that depend on different project structures.

You will deliberately create a small, controlled conflict in `README.md`.

## The Implementation

First, inspect the current status:

```bash
git status
```

Create a branch for documentation wording:

```bash
git switch -c clarify-project-status
```

In `README.md`, replace this existing line:

```md
The project is in its initial documentation and planning phase.
```

with:

```md
The project is in its active documentation and planning phase.
```

The complete `README.md` on this branch should be:

### `release-notes-manager/README.md` — `clarify-project-status` branch version

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

The project is in its active documentation and planning phase.

## Contribution Guidelines

Keep each change focused on one purpose. Before committing, review the Git diff to confirm that only intended changes are included.

## Local Development

Use Git status frequently to understand whether changes are untracked, unstaged, staged, or committed.
```

Commit this change:

```bash
git add README.md
git commit -m "Clarify documentation project status"
```

Switch back to `main`:

```bash
git switch main
```

Edit the same status line in `README.md`. Replace:

```md
The project is in its initial documentation and planning phase.
```

with:

```md
The project is in its active development phase.
```

The complete `README.md` on `main` should now be:

### `release-notes-manager/README.md` — `main` branch version before the conflict

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

The project is in its active development phase.

## Contribution Guidelines

Keep each change focused on one purpose. Before committing, review the Git diff to confirm that only intended changes are included.

## Local Development

Use Git status frequently to understand whether changes are untracked, unstaged, staged, or committed.
```

Commit the `main` branch change:

```bash
git add README.md
git commit -m "Update project status for development"
```

Now attempt to merge the feature branch into `main`:

```bash
git merge clarify-project-status
```

## The Verification

Git should report a conflict similar to:

```text
Auto-merging README.md
CONFLICT (content): Merge conflict in README.md
Automatic merge failed; fix conflicts and then commit the result.
```

Run:

```bash
git status
```

Expected output resembles:

```text
On branch main
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")
```

Do not run `git merge --abort`; you will resolve the conflict in the next step.

---

# Step 9: Read and Resolve the Merge Conflict

## The Target

Resolve the `README.md` conflict, stage the resolved file, and complete the merge.

## The Concept

Git adds conflict markers directly into the conflicting file.

You will see content similar to:

```text
<<<<<<< HEAD
The project is in its active development phase.
=======
The project is in its active documentation and planning phase.
>>>>>>> clarify-project-status
```

The sections mean:

| Marker | Meaning |
|---|---|
| `<<<<<<< HEAD` | The version from the branch currently checked out: `main` |
| `=======` | Separates the two competing versions |
| `>>>>>>> clarify-project-status` | The version from the branch being merged |

You must decide the final content. You can:

- Keep the `HEAD` version.
- Keep the incoming branch version.
- Write a new combined version.

For this tutorial, use a combined version that is more accurate than either isolated sentence:

```md
The project is in its active development, documentation, and planning phase.
```

A conflict is resolved only when all of these are true:

1. The file contains the intended final text.
2. All conflict markers are removed.
3. The resolved file is staged with `git add`.
4. A merge commit is created with `git commit`.

## The Implementation

Open `README.md`. Replace its entire contents with the resolved version below.

### `release-notes-manager/README.md` — resolved merge-conflict version

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

The project is in its active development, documentation, and planning phase.

## Contribution Guidelines

Keep each change focused on one purpose. Before committing, review the Git diff to confirm that only intended changes are included.

## Local Development

Use Git status frequently to understand whether changes are untracked, unstaged, staged, or committed.
```

Confirm that no conflict markers remain:

```bash
git diff --check
```

`git diff --check` reports whitespace problems and helps you catch accidental marker leftovers. You can also explicitly search for conflict markers.

### macOS, Linux, or Git Bash

```bash
grep -nE '^(<<<<<<<|=======|>>>>>>>)' README.md
```

### Windows PowerShell

```powershell
Select-String -Path README.md -Pattern '^(<<<<<<<|=======|>>>>>>>)'
```

These commands should return no output.

Stage the resolved file:

```bash
git add README.md
```

Inspect the merge state:

```bash
git status
```

Complete the merge:

```bash
git commit -m "Merge branch 'clarify-project-status'"
```

## The Verification

Run:

```bash
git status
git log --oneline --decorate --graph --all
```

Expected status:

```text
On branch main
nothing to commit, working tree clean
```

Expected history shape:

```text
*   <hash> (HEAD -> main) Merge branch 'clarify-project-status'
|\
| * <hash> (clarify-project-status) Clarify documentation project status
* | <hash> Update project status for development
|/
*   <hash> Merge branch 'improve-release-template'
...
```

Confirm the final sentence:

```bash
git show HEAD:README.md
```

It should contain:

```md
The project is in its active development, documentation, and planning phase.
```

Delete the merged branch:

```bash
git branch -d clarify-project-status
```

---

# Step 10: Learn How to Abort a Merge Safely

## The Target

Understand how to exit an in-progress merge if you realize it should not continue.

## The Concept

During the previous conflict, Git suggested:

```bash
git merge --abort
```

This command cancels an unfinished merge and attempts to restore the repository to the exact state it had before the merge started.

Use it when:

- You began merging the wrong branch.
- You are not ready to resolve a complex conflict.
- You need to inspect the branches or ask for help before deciding.
- You recognize that the merge should happen later.

Do not run it now because your merge is already complete. This is a reference command, not an action required for the current repository state.

A typical recovery sequence looks like this:

```bash
git status
git merge --abort
git status
```

## The Implementation

No repository change is required in this step.

Run this safe informational command:

```bash
git status
```

Then inspect the merge command help:

```bash
git merge --help
```

If your terminal opens a manual page, press `q` to exit.

## The Verification

Confirm your current repository remains clean:

```bash
git status
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

Remember:

```bash
git merge --abort
```

is only valid while a merge is actively in progress.

---

# Step 11: Create a Branch for a Rebase Exercise

## The Target

Create a branch with two commits, then add a separate commit to `main` so you can rebase the branch.

## The Concept

A rebase changes the base commit of a branch.

Suppose you create a branch from `main`:

```text
* A (main)
```

Then make two commits:

```text
* C (format-release-notes) Add formatting guidelines
* B Add release note audience section
* A (main)
```

Meanwhile, `main` receives another commit:

```text
* D (main) Add release ownership guidance
| * C (format-release-notes) Add formatting guidelines
| * B Add release note audience section
|/
* A
```

A merge would preserve the diverging structure by creating a merge commit.

A rebase takes branch commits `B` and `C`, then replays them on top of the latest `main` commit `D`:

```text
* C' (format-release-notes) Add formatting guidelines
* B' Add release note audience section
* D (main) Add release ownership guidance
* A
```

Notice that `B'` and `C'` are new commits. Even if their file changes are identical, their parent relationships are different, so they have new hashes.

This leads to the most important rebase rule:

> Rebase commits only when they exist on a branch you control and have not been shared for other people to build upon.

For personal local branches, rebasing is usually safe. For shared branches, coordinate first.

## The Implementation

Create a feature branch from the current `main`:

```bash
git switch -c format-release-notes
```

Update `RELEASE_NOTES.md` to this complete content.

### `release-notes-manager/RELEASE_NOTES.md` — first rebase-exercise commit

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

## Writing Guidelines

- Write release notes in clear language for the intended audience.
- Group changes under Added, Changed, Fixed, Deprecated, Removed, or Security headings when applicable.
- Include issue or pull request references when the project uses them.
- Describe user-facing impact instead of only internal implementation details.

## Audience

Release notes should help users, support teams, and other developers understand the impact of a release.
```

Commit the first feature change:

```bash
git add RELEASE_NOTES.md
git commit -m "Document release note audience"
```

Now add a second focused change. Append this section to the end of `RELEASE_NOTES.md`:

```md
## Formatting Rules

- Use sentence case for headings.
- Use complete sentences for user-facing changes.
- Keep each bullet focused on one observable change.
- Use backticks around commands, file names, branch names, and version identifiers.
```

The complete file should now be:

### `release-notes-manager/RELEASE_NOTES.md` — second rebase-exercise commit

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

## Writing Guidelines

- Write release notes in clear language for the intended audience.
- Group changes under Added, Changed, Fixed, Deprecated, Removed, or Security headings when applicable.
- Include issue or pull request references when the project uses them.
- Describe user-facing impact instead of only internal implementation details.

## Audience

Release notes should help users, support teams, and other developers understand the impact of a release.

## Formatting Rules

- Use sentence case for headings.
- Use complete sentences for user-facing changes.
- Keep each bullet focused on one observable change.
- Use backticks around commands, file names, branch names, and version identifiers.
```

Commit it:

```bash
git add RELEASE_NOTES.md
git commit -m "Add release note formatting rules"
```

Switch to `main`:

```bash
git switch main
```

Append this section to `RELEASE_CHECKLIST.md`:

```md
## Release Ownership

- [ ] Assign one person to coordinate the release.
- [ ] Identify a backup owner for urgent release questions.
- [ ] Record the release owner in the pull request or issue that tracks the release.
```

The complete file should now be:

### `release-notes-manager/RELEASE_CHECKLIST.md` — updated `main` version

```md
# Release Checklist

Use this checklist before publishing a software release.

## Before Creating the Release

- [ ] Confirm that the working tree is clean with `git status`.
- [ ] Confirm that all intended changes are committed.
- [ ] Review the release notes for accuracy.
- [ ] Verify that the release version follows the project versioning policy.
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

Commit the change on `main`:

```bash
git add RELEASE_CHECKLIST.md
git commit -m "Document release ownership"
```

## The Verification

Run:

```bash
git log --oneline --decorate --graph --all
```

Expected shape:

```text
* <hash> (HEAD -> main) Document release ownership
| * <hash> (format-release-notes) Add release note formatting rules
| * <hash> Document release note audience
|/
* <hash> Merge branch 'clarify-project-status'
...
```

You now have a feature branch that is behind `main` by one commit.

---

# Step 12: Rebase the Feature Branch onto `main`

## The Target

Rebase `format-release-notes` onto the latest `main` commit.

## The Concept

You must be on the branch you want to move before rebasing it.

The command:

```bash
git rebase main
```

means:

> “Take the commits unique to my current branch and replay them on top of the latest `main` commit.”

Before rebase:

```text
* D (main) Document release ownership
| * C (HEAD -> format-release-notes) Add release note formatting rules
| * B Document release note audience
|/
* A
```

After rebase:

```text
* C' (HEAD -> format-release-notes) Add release note formatting rules
* B' Document release note audience
* D (main) Document release ownership
* A
```

Unlike the earlier merge, the history becomes a straight line.

Because the feature branch and `main` modified different files in this exercise, the rebase should complete without conflict.

## The Implementation

Switch to the feature branch:

```bash
git switch format-release-notes
```

Confirm it is behind `main`:

```bash
git log --oneline --decorate --graph --all
```

Rebase onto `main`:

```bash
git rebase main
```

## The Verification

Git should print output similar to:

```text
Successfully rebased and updated refs/heads/format-release-notes.
```

Inspect the graph:

```bash
git log --oneline --decorate --graph --all
```

Expected shape:

```text
* <new-hash> (HEAD -> format-release-notes) Add release note formatting rules
* <new-hash> Document release note audience
* <hash> (main) Document release ownership
* <hash> Merge branch 'clarify-project-status'
...
```

Notice that the feature commits have new hashes after the rebase.

Confirm that both the feature changes and the latest `main` change are accessible from the branch:

```bash
git show HEAD:RELEASE_NOTES.md
git show HEAD:RELEASE_CHECKLIST.md
```

---

# Step 13: Understand Rebase Conflict Controls

## The Target

Learn the commands needed if a rebase encounters a conflict.

## The Concept

A rebase can conflict for the same reason a merge can conflict: Git may be unable to automatically combine different edits to the same lines.

When that happens, Git pauses and tells you which commit it was replaying.

The resolution flow is:

```bash
git status
```

Inspect which files conflict.

```bash
git diff
```

Read the conflict markers and choose the intended final content.

```bash
git add <resolved-file>
```

Mark the file as resolved.

```bash
git rebase --continue
```

Continue replaying the remaining commits.

If the current replayed commit should be skipped:

```bash
git rebase --skip
```

Use this only when you deliberately do not want that commit’s changes.

If you want to abandon the entire rebase and return the branch to its original pre-rebase state:

```bash
git rebase --abort
```

Think of rebase as moving a stack of cards onto a new table. If one card does not fit, Git pauses. You either adjust it and continue, omit it, or put the full stack back where it started.

## The Implementation

No rebase conflict exists in the current repository, so do not run `git rebase --continue`, `git rebase --skip`, or `git rebase --abort`.

Instead, inspect the repository state:

```bash
git status
```

View Git’s short rebase help:

```bash
git rebase -h
```

## The Verification

Expected status:

```text
On branch format-release-notes
nothing to commit, working tree clean
```

You should be able to identify the appropriate command for each situation:

| Situation | Command |
|---|---|
| A conflict was fixed and staged | `git rebase --continue` |
| The current commit should not be applied | `git rebase --skip` |
| The entire rebase should be cancelled | `git rebase --abort` |

---

# Step 14: Merge the Rebasing Exercise Branch into `main`

## The Target

Merge the rebased feature branch into `main`.

## The Concept

After rebasing, the feature branch sits directly on top of the latest `main` commit:

```text
* C' (format-release-notes) Add release note formatting rules
* B' Document release note audience
* D (main) Document release ownership
```

This makes a fast-forward merge possible. Git can move `main` forward to the feature branch tip without a merge commit.

This highlights the practical difference:

- A normal merge preserves a visible record of parallel development using a merge commit.
- A rebase rewrites a private branch so its commits appear as if they were created after the latest `main` changes.

Neither approach is universally “better.” Teams choose policies based on collaboration needs, history preferences, and repository conventions.

## The Implementation

Switch to `main`:

```bash
git switch main
```

Merge the rebased branch:

```bash
git merge format-release-notes
```

Delete the merged branch:

```bash
git branch -d format-release-notes
```

## The Verification

Git should report a fast-forward merge similar to:

```text
Updating <old-hash>..<new-hash>
Fast-forward
 RELEASE_NOTES.md | 11 +++++++++++
 1 file changed, 11 insertions(+)
```

Inspect the graph:

```bash
git log --oneline --decorate --graph --all
```

The top of the history should look similar to:

```text
* <hash> (HEAD -> main) Add release note formatting rules
* <hash> Document release note audience
* <hash> Document release ownership
* <hash> Merge branch 'clarify-project-status'
...
```

Confirm that only `main` remains:

```bash
git branch
```

Expected output:

```text
* main
```

Confirm the repository is clean:

```bash
git status
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

---

# Part 2 Reference: Branch, Merge, and Rebase Commands

## Branch Management

```bash
git branch
```

Lists local branches. The active branch has an asterisk.

```bash
git branch --show-current
```

Prints the active branch name only.

```bash
git branch <branch-name>
```

Creates a branch but does not switch to it.

Example:

```bash
git branch add-release-checklist
```

```bash
git switch <branch-name>
```

Switches to an existing branch.

Example:

```bash
git switch main
```

```bash
git switch -c <branch-name>
```

Creates a branch and switches to it.

Example:

```bash
git switch -c add-release-checklist
```

```bash
git branch -d <branch-name>
```

Safely deletes a merged local branch.

```bash
git branch -D <branch-name>
```

Force-deletes a local branch, including one with unmerged work. Use only when you intentionally want to discard that branch’s unmerged commits.

---

## Merging

```bash
git merge <branch-name>
```

Merges the named branch into the currently checked-out branch.

Example:

```bash
git switch main
git merge add-release-checklist
```

```bash
git merge --abort
```

Cancels a merge that is currently in progress and attempts to restore the pre-merge state.

```bash
git log --oneline --decorate --graph --all
```

Shows a readable graph of branches and merge commits.

---

## Resolving Merge Conflicts

When Git reports a conflict:

```bash
git status
```

Find affected files.

```bash
git diff
```

Inspect conflicts.

Edit the file until it contains the intended final content and no conflict markers.

```bash
git add <resolved-file>
git commit
```

Stage the resolution and create the merge commit.

---

## Rebasing

```bash
git rebase main
```

While on a feature branch, replays the feature branch’s unique commits onto the latest `main`.

```bash
git rebase --continue
```

Continues after resolving and staging a rebase conflict.

```bash
git rebase --skip
```

Skips the commit currently being replayed.

```bash
git rebase --abort
```

Cancels a rebase and restores the branch to its state before the rebase began.

---

# Merge Versus Rebase: Practical Guidance

Use a standard merge when:

- The branch is shared with other contributors.
- You want history to show that two lines of work were merged.
- Your team’s policy favors merge commits.
- You are uncertain whether history rewriting is safe.

Use rebase when:

- You are working on a local or personal feature branch.
- You want to update your branch with the latest `main` changes before opening a pull request.
- Your team expects a linear history.
- You understand that rebasing creates new commit hashes.

Avoid rebasing a branch that other people have already based work on unless the entire team agrees on the operation.

---

# Part 2 Completion Checklist

Before continuing to GitHub remotes, confirm all of the following:

- [ ] You understand that a branch is a lightweight pointer to a commit.
- [ ] You created and switched to branches with `git switch -c`.
- [ ] You verified that branch-specific files appear and disappear when switching branches.
- [ ] You completed a fast-forward merge.
- [ ] You completed a three-way merge that created a merge commit.
- [ ] You intentionally created and resolved a merge conflict.
- [ ] You removed conflict markers before staging the resolved file.
- [ ] You know `git merge --abort` can cancel an in-progress merge.
- [ ] You rebased a feature branch onto the latest `main`.
- [ ] You know the difference between `git rebase --continue`, `--skip`, and `--abort`.
- [ ] You know why rebasing shared branches can cause problems.
- [ ] `git status` reports a clean working tree on `main`.
