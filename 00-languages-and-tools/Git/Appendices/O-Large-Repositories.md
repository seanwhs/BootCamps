# Appendix O: Sparse Checkout, Partial Clones, and Working with Large Repositories

As repositories grow, contributors may not need every file locally.

For example, a large repository might contain:

```text
company-platform/
├── apps/
│   ├── web/
│   ├── mobile/
│   └── admin/
├── docs/
├── infrastructure/
├── packages/
│   ├── release-notes-manager/
│   ├── shared-ui/
│   └── shared-config/
└── scripts/
```

A developer working only on `packages/release-notes-manager` may not need to check out every application, document, infrastructure file, and package.

Git provides tools for reducing the amount of working-directory content:

- **Sparse checkout**: checks out only selected paths into your working directory.
- **Partial clone**: delays downloading some Git objects until they are needed.
- **Shallow clone**: downloads limited history depth.

These tools are helpful for large repositories, but they add complexity. For small repositories like the current Release Notes Manager project, a normal clone is usually best.

This appendix teaches the concepts using safe local examples.

---

# O.1 Understand the Three “Smaller Clone” Strategies

## The Target

Understand the difference between sparse checkout, partial clone, and shallow clone.

## The Concept

These tools solve different problems.

| Tool | Reduces | Does it keep full history? | Best for |
|---|---|---|---|
| Sparse checkout | Files visible in the working directory | Usually yes | Monorepos where you only edit one folder |
| Partial clone | Initial object download amount | Yes, but objects may download later | Very large repositories with large file history |
| Shallow clone | Commit history depth | No | CI jobs or quick temporary checkouts |

Think of a repository as a giant archive:

```text
Full clone:
Download the entire archive and unpack everything.

Sparse checkout:
Download archive history, but unpack only the folders you need.

Partial clone:
Download the archive catalog first; retrieve some contents only when needed.

Shallow clone:
Download only the newest chapters of the archive.
```

---

# O.2 When Sparse Checkout Is Appropriate

## The Target

Decide whether sparse checkout is worth using.

## The Concept

Sparse checkout is useful when:

- A repository is a monorepo with many unrelated folders.
- You work in one package most of the time.
- You want fewer files in your editor and file explorer.
- You want to reduce checkout time or disk use for working files.
- Your build and test workflow can operate with the selected folders.

Sparse checkout is less useful when:

- The repository is small.
- Your work regularly touches many directories.
- Build scripts require files from across the repository.
- You are new to the project and need to explore its full layout.
- You are debugging tooling that may rely on hidden paths.

For `release-notes-manager`, the repository is intentionally small. Treat the following exercise as preparation for larger real-world repositories.

## The Implementation

Inspect the current project size.

### macOS or Linux

```bash
find . -path './.git' -prune -o -type f -print | sort
```

### Windows PowerShell

```powershell
Get-ChildItem -Recurse -File -Force |
  Where-Object { $_.FullName -notmatch '\\.git\\' } |
  Select-Object -ExpandProperty FullName
```

## The Verification

Confirm that this project has a small, understandable structure.

A normal clone remains the best option for the current repository.

---

# O.3 Create a Safe Sparse-Checkout Demonstration Repository

## The Target

Create a local demonstration repository with several independent folders.

## The Concept

Sparse checkout becomes meaningful only when a repository has multiple areas.

You will create a temporary local repository named:

```text
platform-demo
```

It will simulate a monorepo:

```text
platform-demo/
├── apps/
│   ├── dashboard/
│   └── portal/
├── docs/
├── infrastructure/
└── packages/
    └── release-notes-manager/
```

The repository is intentionally tiny, but its folder shape demonstrates how sparse checkout behaves.

## The Implementation

Move to your projects directory.

### macOS, Linux, or Git Bash

```bash
cd ~/projects
mkdir -p platform-demo
cd platform-demo
git init
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects"
New-Item -ItemType Directory -Path platform-demo -Force
Set-Location "$HOME\projects\platform-demo"
git init
```

Create the directory structure.

### macOS, Linux, or Git Bash

```bash
mkdir -p apps/dashboard
mkdir -p apps/portal
mkdir -p docs
mkdir -p infrastructure
mkdir -p packages/release-notes-manager
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Force -Path "apps\dashboard"
New-Item -ItemType Directory -Force -Path "apps\portal"
New-Item -ItemType Directory -Force -Path docs
New-Item -ItemType Directory -Force -Path infrastructure
New-Item -ItemType Directory -Force -Path "packages\release-notes-manager"
```

Create these files.

### `platform-demo/README.md`

```md
# Platform Demo

This temporary repository exists to demonstrate sparse checkout behavior.
```

### `platform-demo/apps/dashboard/README.md`

```md
# Dashboard Application

This folder represents a dashboard application.
```

### `platform-demo/apps/portal/README.md`

```md
# Portal Application

This folder represents a customer portal application.
```

### `platform-demo/docs/ARCHITECTURE.md`

```md
# Architecture

This folder represents shared platform documentation.
```

### `platform-demo/infrastructure/README.md`

```md
# Infrastructure

This folder represents deployment and infrastructure configuration.
```

### `platform-demo/packages/release-notes-manager/README.md`

```md
# Release Notes Manager Package

This folder represents the package currently being developed.
```

Commit the initial structure:

```bash
git add .
git commit -m "Create platform demo repository"
```

## The Verification

Run:

```bash
git status
git log --oneline
```

Expected output includes:

```text
<hash> Create platform demo repository
```

List tracked files:

```bash
git ls-files
```

You should see files from every simulated project area.

---

# O.4 Clone the Demonstration Repository with Sparse Checkout

## The Target

Create a clone that checks out only the Release Notes Manager package folder.

## The Concept

A sparse clone still has repository history, but its working directory contains only selected paths.

You will clone the temporary repository with:

```bash
git clone --no-checkout <source> <destination>
```

The `--no-checkout` option prevents Git from immediately populating all project files.

Then you will configure sparse checkout before checking out `main`.

## The Implementation

Move to the parent projects directory.

### macOS, Linux, or Git Bash

```bash
cd ~/projects
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects"
```

Clone without checking out files.

### macOS, Linux, or Git Bash

```bash
git clone --no-checkout ./platform-demo platform-demo-sparse
cd platform-demo-sparse
```

### Windows PowerShell

```powershell
git clone --no-checkout "$HOME\projects\platform-demo" platform-demo-sparse
Set-Location "$HOME\projects\platform-demo-sparse"
```

Enable sparse checkout in cone mode:

```bash
git sparse-checkout init --cone
```

Cone mode is the recommended simpler mode for selecting complete directories.

Select the package directory:

```bash
git sparse-checkout set packages/release-notes-manager
```

Check out the default branch:

```bash
git checkout main
```

## The Verification

List files in the sparse clone.

### macOS, Linux, or Git Bash

```bash
find . -path './.git' -prune -o -type f -print | sort
```

### Windows PowerShell

```powershell
Get-ChildItem -Recurse -File -Force |
  Where-Object { $_.FullName -notmatch '\\.git\\' } |
  Select-Object -ExpandProperty FullName
```

Expected visible working files include:

```text
./README.md
./packages/release-notes-manager/README.md
```

The root `README.md` remains visible because cone-mode sparse checkout includes top-level files.

You should not see:

```text
apps/dashboard/README.md
apps/portal/README.md
docs/ARCHITECTURE.md
infrastructure/README.md
```

---

# O.5 Inspect Sparse Checkout Configuration

## The Target

See how Git records sparse-checkout path selections.

## The Concept

Sparse checkout is repository-local configuration. It does not change the repository for other contributors.

Git records the selected paths in an internal sparse-checkout file.

You should generally use Git commands to modify this configuration, but inspecting it helps explain what Git is doing.

## The Implementation

List selected sparse-checkout paths:

```bash
git sparse-checkout list
```

Inspect sparse-checkout status:

```bash
git sparse-checkout reapply
```

Inspect the internal file.

### macOS, Linux, or Git Bash

```bash
cat .git/info/sparse-checkout
```

### Windows PowerShell

```powershell
Get-Content .git\info\sparse-checkout
```

## The Verification

The selected directory should appear:

```text
packages/release-notes-manager
```

The internal file may contain generated patterns similar to:

```text
/*
!/*/
/packages/
!/packages/*/
/packages/release-notes-manager/
```

Do not manually edit this file unless you understand sparse-checkout pattern behavior. Prefer:

```bash
git sparse-checkout set <directories>
```

---

# O.6 Add Another Directory to the Sparse Checkout

## The Target

Expand the working directory to include project documentation.

## The Concept

Sparse checkout selections can change as your task changes.

Suppose you are working on Release Notes Manager but need to read shared architecture documentation. Add `docs` to the sparse set.

This does not create a commit or modify the remote repository. It changes only your local checkout view.

## The Implementation

Add the `docs` directory:

```bash
git sparse-checkout add docs
```

List the current selection:

```bash
git sparse-checkout list
```

Inspect visible files.

### macOS, Linux, or Git Bash

```bash
find . -path './.git' -prune -o -type f -print | sort
```

### Windows PowerShell

```powershell
Get-ChildItem -Recurse -File -Force |
  Where-Object { $_.FullName -notmatch '\\.git\\' } |
  Select-Object -ExpandProperty FullName
```

## The Verification

You should now see:

```text
./docs/ARCHITECTURE.md
./packages/release-notes-manager/README.md
./README.md
```

The application and infrastructure folders should remain absent from the working directory.

---

# O.7 Temporarily Return to a Full Checkout

## The Target

Disable sparse checkout and restore all repository files.

## The Concept

Sparse checkout is reversible.

If you need the full project layout, disable sparse checkout:

```bash
git sparse-checkout disable
```

Git restores all tracked files for the current branch.

## The Implementation

Disable sparse checkout:

```bash
git sparse-checkout disable
```

List files.

### macOS, Linux, or Git Bash

```bash
find . -path './.git' -prune -o -type f -print | sort
```

### Windows PowerShell

```powershell
Get-ChildItem -Recurse -File -Force |
  Where-Object { $_.FullName -notmatch '\\.git\\' } |
  Select-Object -ExpandProperty FullName
```

## The Verification

All files should now be visible, including:

```text
apps/dashboard/README.md
apps/portal/README.md
docs/ARCHITECTURE.md
infrastructure/README.md
packages/release-notes-manager/README.md
```

---

# O.8 Understand Partial Clone

## The Target

Understand how partial clone delays downloading some Git objects.

## The Concept

A normal clone usually downloads all reachable Git objects.

A **partial clone** can tell Git:

> “Download commit and tree information now. Download file-content blobs only when I need them.”

A common command is:

```bash
git clone --filter=blob:none <repository-url>
```

The filter:

```text
blob:none
```

means Git initially avoids downloading ordinary file-content blob objects where possible.

When you later inspect or check out a file, Git retrieves the needed content from the remote automatically.

This is especially useful for repositories with very large histories or many large text files.

Partial clone requires server support. GitHub supports common partial-clone workflows.

## The Implementation

For a GitHub-hosted repository, the pattern is:

```bash
git clone --filter=blob:none git@github.com:OWNER/REPOSITORY.git
```

For example:

```bash
git clone --filter=blob:none git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git release-notes-manager-partial
```

Inspect the remote configuration:

```bash
git config --get remote.origin.promisor
git config --get remote.origin.partialclonefilter
```

## The Verification

Expected output commonly includes:

```text
true
blob:none
```

This indicates that:

- `origin` is a **promisor remote**, meaning it promises to provide omitted objects when Git requests them.
- The clone uses the `blob:none` filter.

For the small tutorial repository, partial clone will not offer a meaningful practical benefit. It is most valuable in large real-world repositories.

---

# O.9 Combine Partial Clone and Sparse Checkout

## The Target

Understand the efficient large-monorepo checkout pattern.

## The Concept

Sparse checkout reduces the files checked out locally.

Partial clone reduces initial object downloads.

Together, they can support a large repository workflow:

```text
Clone only essential Git metadata
    ↓
Select one project directory
    ↓
Check out only needed files
    ↓
Fetch additional data only when required
```

The combined command pattern is:

```bash
git clone --filter=blob:none --sparse <repository-url>
```

The `--sparse` option initializes a sparse checkout that initially includes root-level files.

Then select the folders you need.

## The Implementation

For a large GitHub-hosted repository, use:

```bash
git clone --filter=blob:none --sparse git@github.com:OWNER/REPOSITORY.git
cd REPOSITORY
git sparse-checkout set packages/release-notes-manager docs
```

Inspect selected folders:

```bash
git sparse-checkout list
```

Inspect partial clone settings:

```bash
git config --get remote.origin.promisor
git config --get remote.origin.partialclonefilter
```

## The Verification

Expected sparse paths:

```text
docs
packages/release-notes-manager
```

Expected partial clone configuration:

```text
true
blob:none
```

Use this pattern only after confirming that project tools can operate with the selected working-directory paths.

---

# O.10 Understand Shallow Clones

## The Target

Understand when `--depth` is useful and why shallow clones have limitations.

## The Concept

A shallow clone downloads only a limited number of recent commits.

Example:

```bash
git clone --depth 1 <repository-url>
```

This retrieves only the newest commit history.

Shallow clones are useful for:

- CI pipelines that only need the current source.
- Temporary build environments.
- Quick inspection of a large repository.
- Automated jobs where full history is unnecessary.

They are less suitable for normal development because history-based commands may not work as expected:

```bash
git log
git blame
git bisect
git describe
git merge-base
```

A shallow clone may not contain the commits those commands need.

## The Implementation

A shallow clone pattern:

```bash
git clone --depth 1 git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git release-notes-manager-shallow
```

Inspect whether the repository is shallow:

```bash
git rev-parse --is-shallow-repository
```

Fetch more history later:

```bash
git fetch --deepen=50
```

Convert to a full-history repository:

```bash
git fetch --unshallow
```

## The Verification

A shallow clone returns:

```text
true
```

from:

```bash
git rev-parse --is-shallow-repository
```

After:

```bash
git fetch --unshallow
```

it should return:

```text
false
```

---

# O.11 Sparse Checkout Safety Rules

## The Target

Avoid common sparse-checkout mistakes.

## The Concept

Sparse checkout changes what is present in your working directory, not what exists in the repository.

This can surprise tools and developers.

Follow these rules:

```text
1. Do not assume absent files were deleted from Git.
2. Do not commit deletion changes merely because files are not checked out.
3. Confirm build tools do not require omitted directories.
4. Disable sparse checkout before broad refactors or repository-wide searches.
5. Keep sparse path choices local and task-focused.
6. Use normal clones for small repositories and beginner onboarding.
```

A missing file in sparse checkout means:

```text
The file is not present in this local checkout view.
```

It does not mean:

```text
The file was deleted from the branch.
```

## The Implementation

Inspect whether sparse checkout is enabled:

```bash
git config --get core.sparseCheckout
```

List selected folders:

```bash
git sparse-checkout list
```

Return to a complete working tree when needed:

```bash
git sparse-checkout disable
```

## The Verification

Before making broad changes, run:

```bash
git status
git sparse-checkout list
```

If the task requires broad repository awareness, disable sparse checkout and inspect the full tree first.

---

# O.12 Clean Up the Demonstration Repositories

## The Target

Remove the temporary sparse-checkout exercise repositories.

## The Concept

The `platform-demo` and `platform-demo-sparse` repositories exist only for this appendix.

They should not be pushed or merged into Release Notes Manager.

## The Implementation

Move out of either demonstration repository.

### macOS, Linux, or Git Bash

```bash
cd ~/projects
rm -rf platform-demo platform-demo-sparse
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects"
Remove-Item -Recurse -Force platform-demo, platform-demo-sparse
```

Return to Release Notes Manager:

### macOS, Linux, or Git Bash

```bash
cd ~/projects/release-notes-manager
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects\release-notes-manager"
```

## The Verification

Confirm the main repository is still healthy:

```bash
git status
npm test
```

Expected output includes:

```text
nothing to commit, working tree clean
```

And:

```text
# fail 0
```

---

# O.13 Sparse Checkout, Partial Clone, and Shallow Clone Command Reference

## Enable Sparse Checkout

```bash
git sparse-checkout init --cone
```

## Select Directories

```bash
git sparse-checkout set packages/release-notes-manager docs
```

## Add a Directory

```bash
git sparse-checkout add infrastructure
```

## List Selected Directories

```bash
git sparse-checkout list
```

## Restore Full Checkout

```bash
git sparse-checkout disable
```

## Create a Partial Clone

```bash
git clone --filter=blob:none <repository-url>
```

## Create a Sparse Partial Clone

```bash
git clone --filter=blob:none --sparse <repository-url>
```

## Create a Shallow Clone

```bash
git clone --depth 1 <repository-url>
```

## Check Whether a Repository Is Shallow

```bash
git rev-parse --is-shallow-repository
```

## Download More History

```bash
git fetch --deepen=50
```

## Convert a Shallow Clone to Full History

```bash
git fetch --unshallow
```

---

# Appendix O Completion Check

You should now be able to:

- [ ] Explain the differences between sparse checkout, partial clone, and shallow clone.
- [ ] Decide when a normal clone is simpler and more appropriate.
- [ ] Create a sparse checkout that includes selected directories.
- [ ] Add and remove sparse-checkout directory selections.
- [ ] Restore a full checkout safely.
- [ ] Explain how partial clone delays downloading file objects.
- [ ] Explain why shallow clones are useful for CI but limited for history investigation.
- [ ] Combine sparse checkout and partial clone for large-monorepo workflows.
- [ ] Avoid mistaking omitted sparse-checkout files for deleted files.
