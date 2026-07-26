# Appendix J: Large Files, Git LFS, and Binary Asset Management

Git works best with source code and text files.

Examples:

```text
.js
.json
.md
.yml
.txt
.css
.html
```

These files are usually small, easy to compare, and easy to merge.

Git is less suited to large binary files, such as:

```text
.psd
.ai
.mov
.mp4
.zip
.pdf
.sqlite
.exe
```

A **binary file** is a file whose contents are not meaningful plain text to Git’s line-by-line comparison tools.

This appendix explains:

- Why large binary files can make Git repositories slow.
- When Git LFS is appropriate.
- How to install and configure Git LFS.
- How to track selected file types safely.
- How to verify Git LFS behavior.
- When not to use Git LFS.

---

# J.1 Why Large Files Are a Git Problem

## The Target

Understand why ordinary Git repositories should avoid large or frequently changing binary files.

## The Concept

Git stores snapshots of project content over time.

For source code, this is efficient because files are usually small and Git can compare lines effectively.

For example, a JavaScript change may be tiny:

```diff
- return false;
+ return true;
```

But a binary file such as a video or Photoshop document cannot be compared in the same useful line-by-line way.

If you commit a 300 MB video file, then modify it slightly and commit it again, Git may need to store substantial new binary data for the new version.

Over time, the repository can become very large:

```text
Repository history
├── Initial video: 300 MB
├── Edited video: 310 MB
├── Revised video: 315 MB
└── Final video: 320 MB
```

Even if the current project folder looks manageable, every clone may need to download historical object data.

Large repository history causes:

- Slow clones.
- Slow fetches and pushes.
- Large backups.
- Difficult onboarding for contributors.
- Hosting limits or rejected pushes.

GitHub has size limits and strongly discourages large files in ordinary Git history. Repository policies can change, so review GitHub’s current documentation before committing large assets.

---

# J.2 Understand Git LFS

## The Target

Understand how Git Large File Storage, usually called Git LFS, changes large-file handling.

## The Concept

**Git LFS** stores a small text pointer file in ordinary Git history while storing the large file content in separate LFS storage.

Without Git LFS:

```text
Git repository
└── product-demo.mp4
    └── Large binary content stored directly in Git history
```

With Git LFS:

```text
Git repository
└── product-demo.mp4
    └── Small pointer file

Git LFS storage
└── Actual large binary content
```

A Git LFS pointer looks similar to this:

```text
version https://git-lfs.github.com/spec/v1
oid sha256:0123456789abcdef...
size 123456789
```

Normally, Git LFS automatically downloads the actual file when you clone or check out the repository.

Think of ordinary Git as a project filing cabinet. Git LFS is an attached storage room for oversized items. The filing cabinet stores a reference card, while the storage room holds the actual large object.

---

# J.3 Decide Whether a File Belongs in Git, Git LFS, or External Storage

## The Target

Choose the correct storage strategy before committing a large asset.

## The Concept

Not every large file should use Git LFS.

Use this decision table.

| File type or situation | Recommended location |
|---|---|
| Source code and Markdown documentation | Ordinary Git |
| Small project icons or screenshots | Ordinary Git, when reasonably sized |
| Large design files needed by contributors | Git LFS |
| Large videos needed for project development | Git LFS or external asset storage |
| Generated build archives | Release assets or artifact storage |
| Database backups | External backup storage |
| Production logs | Logging platform or external storage |
| Secrets and certificates | Secret manager, never Git or Git LFS |
| Huge machine-learning datasets | Dataset storage or specialized data platform |
| Dependency folders such as `node_modules` | Do not commit; use package metadata |

The key question is:

> Does this file need to be versioned with the source code, and do contributors need it when working on the project?

If the answer is “no,” external storage is often better.

---

# J.4 Install Git LFS

## The Target

Install Git LFS and enable it for your user account.

## The Concept

Git LFS is an extension to Git. Installing Git alone does not always install Git LFS.

After installation, the command:

```bash
git lfs install
```

configures Git LFS hooks for your user account so that Git can upload and download tracked LFS files automatically.

## The Implementation

First, check whether Git LFS is already installed:

```bash
git lfs version
```

If the command is not found, install Git LFS.

### macOS with Homebrew

```bash
brew install git-lfs
```

### Windows with winget

```powershell
winget install GitHub.GitLFS
```

### Windows with Chocolatey

```powershell
choco install git-lfs
```

### Ubuntu or Debian Linux

```bash
sudo apt update
sudo apt install git-lfs
```

For other operating systems, use the official installation instructions:

```text
https://git-lfs.com/
```

After installation, enable Git LFS:

```bash
git lfs install
```

## The Verification

Run:

```bash
git lfs version
git lfs install
```

Expected output resembles:

```text
git-lfs/3.x.x ...
Git LFS initialized.
```

---

# J.5 Track a Large File Type with Git LFS

## The Target

Configure the repository to track selected file extensions through Git LFS.

## The Concept

The command:

```bash
git lfs track "*.psd"
```

creates or updates a file named:

```text
.gitattributes
```

This file tells Git which files should use LFS behavior.

For example:

```gitattributes
*.psd filter=lfs diff=lfs merge=lfs -text
```

The `-text` setting prevents Git from treating the binary file as a normal text file.

For this tutorial, you will demonstrate LFS configuration using `.mp4` files. You do not need to commit a real large video.

## The Implementation

From the repository root:

```bash
git lfs track "*.mp4"
```

Also track Photoshop files as an example of a large design asset:

```bash
git lfs track "*.psd"
```

Inspect the generated attributes file.

### `release-notes-manager/.gitattributes`

```gitattributes
*.mp4 filter=lfs diff=lfs merge=lfs -text
*.psd filter=lfs diff=lfs merge=lfs -text
```

Check Git status:

```bash
git status
```

Stage the attributes file:

```bash
git add .gitattributes
```

Review it:

```bash
git diff --staged -- .gitattributes
```

Create a focused branch:

```bash
git switch -c chore/configure-git-lfs
```

Commit the configuration:

```bash
git commit -m "Configure Git LFS for binary assets"
```

Push the branch:

```bash
git push -u origin chore/configure-git-lfs
```

Open a pull request with this title:

```text
Configure Git LFS for binary assets
```

Use this pull request description:

```md
## Summary

Configures Git LFS for large video and Photoshop asset files.

## Changes

- Track `*.mp4` files with Git LFS.
- Track `*.psd` files with Git LFS.
- Commit `.gitattributes` so all contributors use the same LFS rules.

## Verification

```bash
git lfs track
git check-attr filter -- example.mp4
git check-attr filter -- design.psd
```

## Notes

No binary assets are added in this pull request. This change only establishes repository-wide tracking rules.
```

## The Verification

Run:

```bash
git lfs track
```

Expected output resembles:

```text
Listing tracked patterns
    *.mp4 (.gitattributes)
    *.psd (.gitattributes)
```

Confirm Git attributes apply to the relevant paths:

```bash
git check-attr filter -- example.mp4
git check-attr filter -- design.psd
```

Expected output:

```text
example.mp4: filter: lfs
design.psd: filter: lfs
```

Merge the pull request through the normal protected-branch workflow, then update local `main`:

```bash
git switch main
git pull --ff-only
git fetch --prune
```

---

# J.6 Add and Verify a Sample LFS-Tracked File

## The Target

Confirm that Git LFS tracks a file based on its extension.

## The Concept

Once `.gitattributes` is committed, Git LFS automatically handles new matching files.

You will create a tiny placeholder file with an `.mp4` extension. It is not a valid video, but it is enough to verify LFS tracking behavior without uploading a large asset.

## The Implementation

Create a temporary branch:

```bash
git switch -c practice/verify-git-lfs
```

Create a demonstration file.

### macOS, Linux, or Git Bash

```bash
printf 'This is a small Git LFS tracking demonstration file.\n' > release-demo.mp4
```

### Windows PowerShell

```powershell
'This is a small Git LFS tracking demonstration file.' | Set-Content -Path release-demo.mp4
```

Stage the file:

```bash
git add release-demo.mp4
```

Inspect Git LFS-tracked files:

```bash
git lfs ls-files
```

Inspect staged content:

```bash
git diff --staged -- release-demo.mp4
```

Commit the demonstration:

```bash
git commit -m "Add Git LFS tracking demonstration"
```

Inspect the committed file through ordinary Git:

```bash
git show HEAD:release-demo.mp4
```

## The Verification

`git lfs ls-files` should include a line similar to:

```text
<short-object-id> * release-demo.mp4
```

The `git show` output should display an LFS pointer, not the original placeholder text:

```text
version https://git-lfs.github.com/spec/v1
oid sha256:...
size ...
```

This confirms that ordinary Git stores a pointer while Git LFS manages the file content.

Clean up the practice branch:

```bash
git switch main
git branch -D practice/verify-git-lfs
```

The local LFS object may remain in your local cache. That is normal.

---

# J.7 Clone a Repository That Uses Git LFS

## The Target

Understand what happens when contributors clone a repository containing LFS-tracked files.

## The Concept

When Git LFS is installed and configured, a normal clone usually downloads:

1. Ordinary Git history.
2. LFS pointer files.
3. The actual large LFS objects required for the checked-out revision.

The normal command remains:

```bash
git clone <repository-url>
```

After cloning, Git LFS should populate LFS-tracked files automatically.

If a repository clone contains pointer text instead of expected binary content, Git LFS may be missing or the LFS download may have failed.

## The Implementation

Clone into a test directory only if you want to verify the behavior with a real LFS-enabled repository:

```bash
git clone git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git release-notes-manager-lfs-clone
cd release-notes-manager-lfs-clone
```

Inspect tracked LFS files:

```bash
git lfs ls-files
```

Force a download of LFS objects if needed:

```bash
git lfs pull
```

Inspect the current LFS environment:

```bash
git lfs env
```

## The Verification

If the repository contains LFS-tracked assets, run:

```bash
git lfs ls-files
```

Expected output lists the assets.

If files appear as pointer text, run:

```bash
git lfs pull
```

Then inspect the file again.

When finished, remove the temporary clone.

### macOS, Linux, or Git Bash

```bash
cd ..
rm -rf release-notes-manager-lfs-clone
```

### Windows PowerShell

```powershell
Set-Location ..
Remove-Item -Recurse -Force release-notes-manager-lfs-clone
```

---

# J.8 Understand LFS Storage Limits and Costs

## The Target

Recognize that Git LFS uses hosted storage and bandwidth quotas.

## The Concept

Git LFS does not make large files free.

Hosted Git LFS storage may have:

- Storage quotas.
- Download bandwidth quotas.
- Organization-level billing controls.
- File-size limits.
- Repository policy restrictions.

Before committing large assets, check the current GitHub documentation and the billing settings for the relevant personal account or organization.

Relevant GitHub documentation:

```text
https://docs.github.com/repositories/working-with-files/managing-large-files/about-git-large-file-storage
```

For projects with very large assets, consider dedicated storage systems:

```text
Cloud object storage
Artifact repositories
Package registries
Media delivery platforms
Dataset storage platforms
```

## The Implementation

No repository file changes are required.

Inspect current LFS-tracked files:

```bash
git lfs ls-files
```

Inspect the size of your local Git repository and LFS objects.

### macOS or Linux

```bash
du -sh .git
du -sh .git/lfs 2>/dev/null || true
```

### Windows PowerShell

```powershell
$gitSize = (Get-ChildItem -Recurse -Force .git | Measure-Object -Property Length -Sum).Sum
Write-Output ".git size in bytes: $gitSize"

if (Test-Path .git\lfs) {
  $lfsSize = (Get-ChildItem -Recurse -Force .git\lfs | Measure-Object -Property Length -Sum).Sum
  Write-Output ".git\lfs size in bytes: $lfsSize"
}
```

## The Verification

Confirm you understand:

```text
Git LFS is a storage strategy, not an unlimited-storage strategy.
```

Before adding a large file, review:

- File size.
- Whether every clone truly needs it.
- Current storage and bandwidth allowance.
- Whether external artifact or object storage is more appropriate.

---

# J.9 Remove a Large File That Was Added Incorrectly

## The Target

Understand the difference between removing a large file from the current project and removing it from history.

## The Concept

Suppose someone commits a 500 MB ZIP file directly into ordinary Git.

Deleting it in a later commit removes it from the current project tree:

```bash
git rm archive.zip
git commit -m "Remove large archive"
```

But the large file still exists in earlier Git history.

This means repository size may remain large even after the current branch no longer contains the file.

Removing a large file from history requires history rewriting and coordination. For shared repositories, this can affect every contributor’s clone.

Use specialized tools such as:

```text
git filter-repo
```

GitHub also provides current guidance for reducing repository size and removing large files from history.

## The Implementation

For a file that is currently tracked but should no longer be present:

```bash
git rm <large-file-path>
git commit -m "Remove oversized generated file"
git push
```

If the file should remain locally but stop being tracked:

```bash
git rm --cached <large-file-path>
printf "<large-file-path>\n" >> .gitignore
git add .gitignore
git commit -m "Stop tracking local generated asset"
git push
```

For history cleanup, do not run commands blindly on shared repositories. First:

```bash
git status
git branch backup/before-history-rewrite
git log --all -- <large-file-path>
```

Then follow the project’s coordinated migration plan.

## The Verification

Confirm the file is no longer tracked in the current commit:

```bash
git ls-files <large-file-path>
```

Expected output: no output.

Remember:

> No output from `git ls-files` means the current project does not track the file. It does not prove the file is absent from all historical commits.

---

# J.10 Git LFS Command Reference

## Install and Enable Git LFS

```bash
git lfs install
```

## Track a File Pattern

```bash
git lfs track "*.mp4"
```

## Stop Tracking a Pattern for Future Files

```bash
git lfs untrack "*.mp4"
```

Afterward, review and commit `.gitattributes`.

## List Tracked LFS Patterns

```bash
git lfs track
```

## List LFS Files in the Current Checkout

```bash
git lfs ls-files
```

## Download LFS Objects for the Current Checkout

```bash
git lfs pull
```

## Inspect Git LFS Configuration

```bash
git lfs env
```

## Fetch LFS Objects Without Checking Them Out

```bash
git lfs fetch
```

## Remove Unused Local LFS Objects

```bash
git lfs prune
```

Use `git lfs prune` only after understanding which local objects are safe to remove. It affects local cache data, not the remote repository.

---

# J.11 Git LFS Safety Checklist

Before adding a large binary asset:

```text
[ ] The asset is needed by contributors or project builds.
[ ] Ordinary Git is not a better fit.
[ ] Git LFS is installed locally.
[ ] The file pattern is tracked in committed .gitattributes.
[ ] Current GitHub LFS storage and bandwidth limits are understood.
[ ] The asset contains no secrets or confidential data.
[ ] The asset is not generated build output that belongs in release artifacts instead.
[ ] The pull request explains why the asset is versioned.
```

Before merging a pull request containing large assets:

```text
[ ] The file is actually managed by Git LFS.
[ ] The file size is reasonable for the project’s policy.
[ ] The change does not accidentally add duplicate binary assets.
[ ] Documentation explains how contributors obtain or update the asset if needed.
[ ] CI and any asset-validation checks pass.
```

---

# Appendix J Completion Check

You should now be able to:

- [ ] Explain why ordinary Git repositories should avoid large, frequently changing binary files.
- [ ] Decide whether a file belongs in Git, Git LFS, release assets, or external storage.
- [ ] Install and initialize Git LFS.
- [ ] Track file patterns through `.gitattributes`.
- [ ] Verify that Git LFS manages a matching file.
- [ ] Clone and troubleshoot repositories that use Git LFS.
- [ ] Understand that Git LFS storage has quotas and costs.
- [ ] Distinguish removing a file from the current tree from removing it from repository history.
