# Appendix K: Git Submodules, External Dependencies, and Repository Composition

A Git **submodule** lets one repository include another repository at a specific commit.

This is useful when your project depends on a separate codebase that must retain its own history and release cycle.

For example:

```text
release-notes-manager/
├── src/
├── package.json
└── vendor/
    └── release-note-theme/     # Separate Git repository as a submodule
```

A submodule is not copied into your repository as ordinary files. Instead, the parent repository stores:

1. The external repository URL.
2. The exact commit of that external repository that should be used.

This appendix explains:

- What submodules are.
- When to use them.
- When not to use them.
- How to add, clone, update, and remove them.
- How to avoid common submodule mistakes.

---

# K.1 Understand the Submodule Model

## The Target

Understand what Git stores when a repository contains a submodule.

## The Concept

Imagine your project is a book and another repository is a separate reference manual.

You do not copy every page of the reference manual into your book. Instead, your book records:

```text
Use Reference Manual edition 4, page set identified by commit abc123.
```

A Git submodule works similarly.

The parent repository records a pointer called a **gitlink**:

```text
Parent repository commit
    │
    ├── src/releaseNotes.js
    ├── README.md
    └── vendor/release-note-theme → external repository commit abc123
```

The parent repository does **not** automatically follow the latest commit of the external repository.

That behavior is intentional. It makes builds reproducible.

If your project points to:

```text
release-note-theme commit abc123
```

every contributor gets that exact version rather than whichever version happens to be newest today.

---

# K.2 When to Use a Submodule

## The Target

Decide whether a submodule is the right dependency strategy.

## The Concept

Submodules solve a specific problem:

> “This project needs another Git repository, and we need to pin it to an exact commit while preserving that repository’s independent history.”

Use a submodule when:

- The dependency is maintained as an independent repository.
- The dependency has its own release cycle.
- You need to pin an exact source version.
- You need to make changes to the dependency separately.
- You cannot or should not publish the dependency through a package manager.

Examples:

```text
A private shared configuration repository
A reusable documentation theme
A hardware firmware repository
A shared internal library with separate ownership
```

Avoid submodules when:

- The dependency is available through a package manager such as npm.
- You only need a few files; copying them with attribution may be simpler.
- The dependency should always be updated automatically.
- Contributors are new to Git and cannot support the extra workflow.
- You need to combine two repositories permanently.

For JavaScript dependencies, prefer npm packages when possible:

```bash
npm install package-name
```

For example, do not use a Git submodule for a common library such as a date utility if npm provides it.

---

# K.3 Compare Submodules, Packages, Forks, and Copies

## The Target

Choose the correct relationship between repositories.

## The Concept

Several tools can look similar at first, but they solve different problems.

| Approach | Best for | Example |
|---|---|---|
| npm package | Reusable JavaScript dependency | `npm install lodash` |
| Git submodule | Independent repository pinned to exact commit | Shared internal documentation theme |
| Fork | Contributing to a repository without direct write access | Forking an open-source project |
| Clone | Local working copy of a repository | `git clone <url>` |
| Copy files | Small, stable snippets with appropriate license compliance | A small template file |
| Monorepo | Multiple tightly related projects developed together | App, shared library, and docs in one repository |

For Release Notes Manager:

```text
Use npm for JavaScript packages.
Use a submodule only for a separately maintained source repository that truly belongs beside this project.
```

---

# K.4 Create a Safe Demonstration Repository

## The Target

Create a tiny local repository that can be used as a submodule without depending on an external project.

## The Concept

Using a local demonstration repository lets you learn the mechanics safely.

You will create a separate repository named:

```text
release-note-theme
```

It will contain a Markdown template file.

Later, Release Notes Manager will include this repository as a submodule.

## The Implementation

Move to your projects directory.

### macOS, Linux, or Git Bash

```bash
cd ~/projects
mkdir -p release-note-theme
cd release-note-theme
git init
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects"
New-Item -ItemType Directory -Path release-note-theme -Force
Set-Location "$HOME\projects\release-note-theme"
git init
```

Create this file.

### `release-note-theme/RELEASE_TEMPLATE.md`

```md
# Release {{VERSION}}

**Release date:** {{RELEASE_DATE}}

## Summary

{{SUMMARY}}

## Added

{{ADDED}}

## Changed

{{CHANGED}}

## Fixed

{{FIXED}}
```

Create a README for the demonstration repository.

### `release-note-theme/README.md`

```md
# Release Note Theme

This repository contains a reusable Markdown template for software release notes.

## Template Placeholders

- `{{VERSION}}` — The release version.
- `{{RELEASE_DATE}}` — The publication date in `YYYY-MM-DD` format.
- `{{SUMMARY}}` — A short overview of the release.
- `{{ADDED}}` — New features or capabilities.
- `{{CHANGED}}` — Updated behavior.
- `{{FIXED}}` — Resolved defects.
```

Commit the repository:

```bash
git add README.md RELEASE_TEMPLATE.md
git commit -m "Add release note template"
```

## The Verification

Run:

```bash
git status
git log --oneline
```

Expected status:

```text
On branch main
nothing to commit, working tree clean
```

Expected history:

```text
<hash> Add release note template
```

---

# K.5 Add a Local Repository as a Submodule

## The Target

Add the demonstration repository to Release Notes Manager as a submodule.

## The Concept

The standard submodule command is:

```bash
git submodule add <repository-url-or-path> <destination-path>
```

For this local demonstration, the source is a path:

```text
../release-note-theme
```

The destination inside Release Notes Manager is:

```text
vendor/release-note-theme
```

Git creates two important things:

```text
.gitmodules
vendor/release-note-theme/
```

The `.gitmodules` file stores the submodule name, path, and source URL.

The parent repository stores a gitlink reference for the submodule directory.

## The Implementation

Move to the Release Notes Manager repository.

### macOS, Linux, or Git Bash

```bash
cd ~/projects/release-notes-manager
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects\release-notes-manager"
```

Ensure your working tree is clean:

```bash
git switch main
git pull --ff-only
git status
```

Create a feature branch:

```bash
git switch -c feature/add-release-template-submodule
```

Add the local repository as a submodule:

```bash
git -c protocol.file.allow=always submodule add ../release-note-theme vendor/release-note-theme
```

The configuration option is necessary in some Git installations because local file-protocol submodule URLs are restricted by default for security.

Inspect the resulting files:

```bash
git status
git diff -- .gitmodules
git submodule status
```

## The Verification

Expected `git status` output includes:

```text
new file:   .gitmodules
new file:   vendor/release-note-theme
```

Expected `.gitmodules` content resembles:

### `release-notes-manager/.gitmodules`

```ini
[submodule "vendor/release-note-theme"]
	path = vendor/release-note-theme
	url = ../release-note-theme
```

Expected submodule status resembles:

```text
<hash> vendor/release-note-theme (heads/main)
```

The hash is the exact commit currently selected from the submodule repository.

---

# K.6 Inspect the Parent Repository’s Submodule Pointer

## The Target

See how Git records a submodule differently from ordinary files.

## The Concept

An ordinary tracked file has a mode such as:

```text
100644
```

A submodule uses a special mode:

```text
160000
```

This indicates a gitlink: a pointer to a commit in another repository.

The parent repository does not store every file from the submodule as normal blobs. It stores the commit ID that the submodule should use.

## The Implementation

Inspect the index entry for the submodule:

```bash
git ls-files --stage vendor/release-note-theme
```

Inspect the current tree:

```bash
git ls-tree HEAD vendor
```

Because the submodule is not committed yet, inspect the staging area instead:

```bash
git diff --staged --summary
```

Now stage the generated files:

```bash
git add .gitmodules vendor/release-note-theme
```

Inspect again:

```bash
git diff --staged --summary
git ls-files --stage vendor/release-note-theme
```

## The Verification

Expected output resembles:

```text
160000 <submodule-commit-hash> 0	vendor/release-note-theme
```

The `160000` mode proves the entry is a submodule pointer, not a normal directory full of parent-repository files.

---

# K.7 Commit and Publish the Submodule Reference

## The Target

Commit the submodule configuration and pointer through the normal pull-request workflow.

## The Concept

Adding a submodule changes project structure. It should be reviewed like any other dependency addition.

The pull request should explain:

- Why the external repository is needed.
- Which commit is pinned.
- How contributors initialize it.
- Whether the source is public, private, or local-only.

For this tutorial, the local path is only for learning. A real shared submodule should use a GitHub SSH or HTTPS URL accessible to every contributor.

## The Implementation

Commit the submodule addition:

```bash
git commit -m "Add release note theme submodule"
```

Add a README section explaining initialization. Append this section to `README.md`.

### `release-notes-manager/README.md` — append this section

```md
## Repository Submodules

This repository includes a reusable release-note template as a Git submodule in `vendor/release-note-theme`.

After cloning the repository, initialize submodules with:

```bash
git submodule update --init --recursive
```

To clone the repository and initialize submodules in one command:

```bash
git clone --recurse-submodules git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
```

Replace `YOUR_GITHUB_USERNAME` with the repository owner name.
```

Stage and commit the documentation:

```bash
git add README.md
git commit -m "Document submodule setup"
```

Run tests:

```bash
npm test
```

Push the branch:

```bash
git push -u origin feature/add-release-template-submodule
```

Open a pull request titled:

```text
Add release note theme submodule
```

Use this pull request body:

```md
## Summary

Adds a Git submodule for a reusable release-note Markdown template.

## Changes

- Add `vendor/release-note-theme` as a pinned submodule.
- Add `.gitmodules` configuration.
- Document how contributors initialize submodules after cloning.

## Verification

```bash
git submodule status
git submodule update --init --recursive
npm test
```

## Notes

The demonstration uses a local repository path. In a shared repository, the submodule URL must be replaced with an accessible GitHub SSH or HTTPS URL before merging.
```

## The Verification

Before merging, confirm:

```bash
git submodule status
```

shows the expected submodule commit.

Confirm the submodule files are accessible:

```bash
cat vendor/release-note-theme/RELEASE_TEMPLATE.md
```

On PowerShell:

```powershell
Get-Content vendor\release-note-theme\RELEASE_TEMPLATE.md
```

---

# K.8 Clone a Repository with Submodules

## The Target

Learn the two correct ways to clone a repository that uses submodules.

## The Concept

A normal clone may create the submodule directory but leave it empty or uninitialized.

The preferred clone command is:

```bash
git clone --recurse-submodules <repository-url>
```

This does both jobs:

1. Clones the parent repository.
2. Initializes and checks out all submodules.

If you already cloned without the flag, run:

```bash
git submodule update --init --recursive
```

The `--recursive` option also initializes nested submodules, if any exist.

## The Implementation

For a real GitHub-hosted repository:

```bash
git clone --recurse-submodules git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
```

If you already cloned the project:

```bash
cd release-notes-manager
git submodule update --init --recursive
```

Inspect submodule state:

```bash
git submodule status
```

## The Verification

Expected output resembles:

```text
<hash> vendor/release-note-theme (heads/main)
```

If the line begins with a hyphen:

```text
-<hash> vendor/release-note-theme
```

the submodule is not initialized.

Run:

```bash
git submodule update --init --recursive
```

Then check again.

---

# K.9 Update a Submodule to a New Commit

## The Target

Update the parent repository to use a newer commit from a submodule repository.

## The Concept

A submodule does not automatically move when the external repository changes.

Suppose the submodule currently points to:

```text
Template repository commit A
```

A contributor makes a new template commit:

```text
Template repository commit B
```

The parent repository still points to `A` until you intentionally update and commit the new pointer.

This is a feature, not a bug. It gives the parent project control over dependency upgrades.

## The Implementation

First, make a new commit in the demonstration submodule repository.

### macOS, Linux, or Git Bash

```bash
cd ~/projects/release-note-theme
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects\release-note-theme"
```

Append this section to `RELEASE_TEMPLATE.md`:

### `release-note-theme/RELEASE_TEMPLATE.md` — append this section

```md
## Security

{{SECURITY}}
```

Commit the submodule change:

```bash
git add RELEASE_TEMPLATE.md
git commit -m "Add security release section"
```

Now return to Release Notes Manager:

### macOS, Linux, or Git Bash

```bash
cd ~/projects/release-notes-manager
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects\release-notes-manager"
```

Switch to a feature branch:

```bash
git switch -c chore/update-release-template-submodule
```

Enter the submodule directory:

```bash
cd vendor/release-note-theme
```

Fetch and update the checked-out submodule commit:

```bash
git fetch
git switch main
git pull --ff-only
```

Return to the parent repository root:

```bash
cd ../..
```

Inspect the parent status:

```bash
git status
git diff --submodule
```

Stage the updated pointer:

```bash
git add vendor/release-note-theme
git commit -m "Update release note theme submodule"
```

## The Verification

Run:

```bash
git submodule status
git log --oneline -1
```

The submodule hash should now differ from the one recorded before the update.

Inspect the new template content:

```bash
cat vendor/release-note-theme/RELEASE_TEMPLATE.md
```

You should see:

```md
## Security

{{SECURITY}}
```

---

# K.10 Understand Detached HEAD Inside a Submodule

## The Target

Understand why submodules often appear to be in detached HEAD state.

## The Concept

The parent repository pins the submodule to an exact commit.

When Git checks out the parent repository, it checks out that exact submodule commit. That often leaves the submodule in detached HEAD state.

For example:

```bash
cd vendor/release-note-theme
git status
```

may report:

```text
HEAD detached at abc1234
```

This is normal when you are only consuming the pinned dependency version.

If you need to develop the submodule itself:

1. Enter the submodule directory.
2. Switch to a named branch.
3. Make and push commits in the submodule repository.
4. Return to the parent repository.
5. Commit the updated submodule pointer.

## The Implementation

Inspect the submodule state:

```bash
cd vendor/release-note-theme
git status
git branch --show-current
```

If you are only inspecting the pinned version, do not change anything.

Return to the parent repository:

```bash
cd ../..
```

## The Verification

Confirm you understand:

```text
Detached HEAD in a submodule
    usually means
The parent repository has checked out the exact pinned dependency commit.
```

It is not automatically an error.

---

# K.11 Remove a Submodule Correctly

## The Target

Understand how to remove a submodule without leaving configuration behind.

## The Concept

Removing a submodule requires more than deleting its folder.

You must remove:

1. The gitlink from the parent repository.
2. The matching entry from `.gitmodules`.
3. The local module metadata under `.git/modules/`.

Modern Git can do most of this safely with:

```bash
git rm <submodule-path>
```

## The Implementation

Do not remove the tutorial submodule unless you intentionally no longer want it.

The correct removal process is:

```bash
git rm vendor/release-note-theme
git commit -m "Remove release note theme submodule"
```

Then inspect `.gitmodules`:

```bash
cat .gitmodules
```

On PowerShell:

```powershell
Get-Content .gitmodules
```

If `.gitmodules` becomes empty, remove it:

```bash
git rm .gitmodules
git commit -m "Remove empty submodule configuration"
```

Finally, remove stale local metadata if needed:

```bash
rm -rf .git/modules/vendor/release-note-theme
```

On Windows PowerShell:

```powershell
Remove-Item -Recurse -Force .git\modules\vendor\release-note-theme
```

Only run the metadata-removal command after confirming the submodule was intentionally removed from Git.

## The Verification

Run:

```bash
git submodule status
git status
```

The removed submodule should no longer appear.

---

# K.12 Common Submodule Problems

## Problem: The Submodule Folder Is Empty

### Cause

The parent repository was cloned without initializing submodules.

### Fix

```bash
git submodule update --init --recursive
```

---

## Problem: Git Reports Modified Content in a Submodule

### Cause

The submodule working directory contains local changes or is checked out at a different commit from the one recorded by the parent.

### Inspect

```bash
git status
git diff --submodule
```

Then inspect inside the submodule:

```bash
cd vendor/release-note-theme
git status
```

### Fix Local Uncommitted Changes

If unwanted:

```bash
git restore .
git clean -fd
```

Use `git clean -fd` only after confirming the untracked files in the submodule are disposable.

### Restore the Parent-Pinned Commit

From the parent repository root:

```bash
git submodule update --checkout --recursive
```

---

## Problem: Contributors Cannot Access the Submodule Repository

### Cause

The submodule URL is private, invalid, or uses an authentication method the contributor has not configured.

### Inspect

```bash
git config --file .gitmodules --get-regexp '^submodule\..*\.url$'
```

### Fix

Update the URL:

```bash
git submodule set-url vendor/release-note-theme git@github.com:YOUR_ORGANIZATION/release-note-theme.git
```

Then commit `.gitmodules`:

```bash
git add .gitmodules
git commit -m "Update release template submodule URL"
```

Contributors synchronize their local configuration:

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

---

## Problem: The Parent Repository Shows a Different Submodule Commit

### Cause

The submodule repository moved to a newer commit, but the parent repository has not committed the updated pointer.

### Inspect

```bash
git status
git diff --submodule
```

### Fix

If the newer submodule version is intended:

```bash
git add vendor/release-note-theme
git commit -m "Update release note theme submodule"
```

If it is not intended:

```bash
git submodule update --checkout --recursive
```

---

# K.13 Submodule Command Reference

## Add a Submodule

```bash
git submodule add <repository-url> <destination-path>
```

## Inspect Submodule Status

```bash
git submodule status
```

## Clone With Submodules

```bash
git clone --recurse-submodules <repository-url>
```

## Initialize Submodules After Cloning

```bash
git submodule update --init --recursive
```

## Update a Submodule to Its Remote Branch

```bash
cd <submodule-path>
git switch main
git pull --ff-only
cd ..
git add <submodule-path>
git commit -m "Update submodule"
```

## Restore the Parent-Pinned Submodule Version

```bash
git submodule update --checkout --recursive
```

## Synchronize Changed URLs

```bash
git submodule sync --recursive
git submodule update --init --recursive
```

## Remove a Submodule

```bash
git rm <submodule-path>
git commit -m "Remove submodule"
```

---

# K.14 Submodule Safety Checklist

Before adding a submodule:

```text
[ ] The dependency truly needs independent repository history.
[ ] A package manager is not a better option.
[ ] Every contributor can access the submodule repository.
[ ] The submodule repository has clear ownership and maintenance expectations.
[ ] The parent README documents cloning and initialization commands.
[ ] The submodule commit is intentionally pinned.
```

Before updating a submodule pointer:

```text
[ ] The new external commit was reviewed.
[ ] The parent project remains compatible with the update.
[ ] Tests pass in the parent repository.
[ ] The pull request clearly identifies the dependency version change.
[ ] The updated pointer is committed in the parent repository.
```

---

# Appendix K Completion Check

You should now be able to:

- [ ] Explain that a submodule is a pointer to an exact commit in another repository.
- [ ] Decide when a package manager, fork, monorepo, or submodule is appropriate.
- [ ] Add and inspect a submodule.
- [ ] Recognize `.gitmodules` and gitlink mode `160000`.
- [ ] Clone repositories with submodules correctly.
- [ ] Update the parent repository’s pinned submodule commit.
- [ ] Understand detached HEAD state inside a submodule.
- [ ] Remove a submodule without leaving stale configuration.
- [ ] Troubleshoot common submodule initialization and access problems.
