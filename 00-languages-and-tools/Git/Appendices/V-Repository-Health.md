# Appendix V: Repository Health, Git Maintenance, and Storage Diagnostics

Git repositories usually maintain themselves well. Most developers never need to run maintenance commands manually.

However, long-lived repositories can accumulate:

- Unreachable objects from rebases, resets, and deleted branches.
- Large pack files.
- Stale remote-tracking references.
- Excess local LFS cache data.
- Corrupt objects after disk, filesystem, or hardware problems.
- Slow operations caused by a very large history.

This appendix explains how to inspect repository health safely before attempting maintenance.

The core rule is:

> Diagnose first. Back up before destructive cleanup. Do not run maintenance commands merely because they exist.

---

# V.1 Understand Git Object Storage

## The Target

Understand why Git repositories can grow even when the current project files are small.

## The Concept

Your current working directory contains only the current project version.

Git also stores history:

```text
Current files
    +
Previous commits
    +
Prior versions of files
    +
Branches
    +
Tags
    +
Reflog entries
    +
Potentially unreachable recent objects
```

For example:

```text
release-notes-manager/
├── src/releaseNotes.js
├── README.md
└── .git/
    ├── objects/
    ├── refs/
    ├── logs/
    └── ...
```

The `.git/objects/` directory contains Git’s stored commits, trees, and blobs.

Git eventually groups many objects into compressed **packfiles** for efficient storage and transfer.

Think of Git object storage like a document archive:

```text
Loose objects
= individual pages in separate folders

Packfiles
= compressed archive boxes containing many pages
```

---

# V.2 Inspect Repository Size

## The Target

Measure the size of the working directory, Git history, and Git LFS cache.

## The Concept

A repository may feel slow because of:

- Large source files.
- Large binary history.
- Git LFS objects.
- Many branches and tags.
- Large generated files committed accidentally.
- A large `.git` directory.

Before changing anything, measure what is actually large.

## The Implementation

From the repository root:

```bash
git status
```

Inspect Git’s internal storage summary:

```bash
git count-objects -vH
```

Example output:

```text
count: 0
size: 0 bytes
in-pack: 125
packs: 1
size-pack: 42.13 KiB
prune-packable: 0
garbage: 0
size-garbage: 0 bytes
```

Important fields:

| Field | Meaning |
|---|---|
| `count` | Number of loose Git objects |
| `size` | Disk usage of loose objects |
| `in-pack` | Number of objects stored in packfiles |
| `packs` | Number of packfiles |
| `size-pack` | Total compressed packfile size |
| `garbage` | Unexpected files in `.git/objects` |
| `size-garbage` | Disk size of unexpected object-storage files |

Inspect the overall `.git` size.

### macOS or Linux

```bash
du -sh .git
du -sh .git/objects
du -sh .git/lfs 2>/dev/null || true
```

### Windows PowerShell

```powershell
$gitSize = (Get-ChildItem -Recurse -Force .git | Measure-Object -Property Length -Sum).Sum
Write-Output ".git size in bytes: $gitSize"

$objectsSize = (Get-ChildItem -Recurse -Force .git\objects | Measure-Object -Property Length -Sum).Sum
Write-Output ".git\objects size in bytes: $objectsSize"

if (Test-Path .git\lfs) {
  $lfsSize = (Get-ChildItem -Recurse -Force .git\lfs | Measure-Object -Property Length -Sum).Sum
  Write-Output ".git\lfs size in bytes: $lfsSize"
}
```

## The Verification

For the small tutorial repository, Git storage should be small.

If `.git` is much larger than expected, investigate before cleanup:

```bash
git count-objects -vH
git lfs ls-files
git log --all --stat
```

---

# V.3 Check Repository Integrity with `git fsck`

## The Target

Verify that Git objects and references are internally consistent.

## The Concept

`git fsck` means “file system check.”

It inspects Git’s object database and references for problems such as:

- Missing objects.
- Broken references.
- Dangling commits.
- Corrupt object data.
- Invalid links between commits, trees, and blobs.

A **dangling object** is not automatically a problem. It may simply be a commit that became unreachable after:

- Deleting a branch.
- Amending a commit.
- Resetting history.
- Rebasing.
- Stashing work.

Some dangling objects may still be recoverable through reflog.

## The Implementation

Run a safe integrity check:

```bash
git fsck --full
```

To inspect unreachable objects without considering reflog references:

```bash
git fsck --no-reflogs --unreachable
```

To inspect only connectivity problems:

```bash
git fsck --connectivity-only
```

## The Verification

A healthy repository may produce no output from:

```bash
git fsck --full
```

That is normal.

If you see dangling commits such as:

```text
dangling commit a1b2c3d...
```

inspect them before cleanup:

```bash
git show --stat a1b2c3d
```

If the commit contains valuable work, recover it:

```bash
git switch -c recovery/dangling-work a1b2c3d
```

If `git fsck` reports missing or corrupt objects, stop destructive maintenance and restore from a known-good clone, mirror backup, or remote repository.

---

# V.4 Create a Backup Before Manual Maintenance

## The Target

Create a local mirror backup before running cleanup commands.

## The Concept

Maintenance is usually safe, but backup is cheap insurance.

A mirror clone preserves all refs:

```text
Branches
Tags
Remote-tracking refs
Notes
Other references
```

This is more complete than copying only the working directory.

## The Implementation

Move to a backup directory.

### macOS, Linux, or Git Bash

```bash
mkdir -p ~/repository-backups
cd ~/repository-backups
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path "$HOME\repository-backups" -Force
Set-Location "$HOME\repository-backups"
```

Create a mirror backup of the GitHub repository:

```bash
git clone --mirror git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
```

Inspect the backup:

```bash
cd release-notes-manager.git
git show-ref
```

Return to the working repository.

### macOS, Linux, or Git Bash

```bash
cd ~/projects/release-notes-manager
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects\release-notes-manager"
```

## The Verification

Confirm the backup includes `main` and tags:

```bash
cd ~/repository-backups/release-notes-manager.git
git show-ref --heads
git show-ref --tags
```

Return to your working repository before continuing.

---

# V.5 Run Safe Git Maintenance

## The Target

Use Git’s built-in maintenance command without deleting valuable recent recovery data.

## The Concept

Modern Git can perform maintenance tasks such as:

- Packing loose objects.
- Writing commit graphs.
- Cleaning stale metadata.
- Optimizing references.

The recommended first command is:

```bash
git maintenance run
```

This is generally safer and more targeted than immediately running aggressive garbage collection.

Think of it as routine housekeeping rather than a demolition crew.

## The Implementation

Ensure the working tree is clean:

```bash
git status
```

Run maintenance:

```bash
git maintenance run
```

Inspect storage afterward:

```bash
git count-objects -vH
```

Inspect repository status:

```bash
git status
```

## The Verification

Expected output from `git status`:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

The exact storage numbers may change slightly after maintenance.

---

# V.6 Understand `git gc`

## The Target

Understand when Git garbage collection is appropriate.

## The Concept

`git gc` means **garbage collect**.

Git garbage collection can:

- Pack loose objects.
- Compress repository storage.
- Remove objects Git considers safely expired.
- Prune old metadata.

A normal command is:

```bash
git gc
```

An aggressive command is:

```bash
git gc --aggressive
```

Avoid `--aggressive` unless you have a measured reason. It can take much longer and rarely provides a meaningful benefit for ordinary repositories.

Do not use aggressive cleanup while:

- You are recovering lost work.
- You have recently deleted branches you may need.
- You have not backed up important local-only commits.
- The repository is shared through unusual filesystem arrangements.

## The Implementation

Inspect recent reflog entries first:

```bash
git reflog --date=local -20
```

Run ordinary garbage collection only after confirming you do not need to recover recent discarded work:

```bash
git gc
```

Inspect repository storage:

```bash
git count-objects -vH
```

## The Verification

Git may print no output. That is normal.

Confirm the repository still works:

```bash
git status
git log --oneline -5
npm test
```

Expected test result:

```text
# fail 0
```

---

# V.7 Clean Stale Remote-Tracking Branches

## The Target

Remove local references to branches that no longer exist on GitHub.

## The Concept

When a branch is deleted on GitHub, your local repository may still remember it:

```text
remotes/origin/feature/old-branch
```

These stale references do not usually harm the repository, but they can clutter branch lists and confuse contributors.

Use:

```bash
git fetch --prune
```

This contacts the remote and removes remote-tracking refs that no longer exist there.

## The Implementation

Inspect all branches:

```bash
git branch --all
```

Fetch and prune:

```bash
git fetch origin --prune
```

Inspect branches again:

```bash
git branch --all
```

You can also prune explicitly:

```bash
git remote prune origin
```

Prefer `git fetch origin --prune` because it both updates remote information and removes stale refs.

## The Verification

Deleted remote branches should no longer appear under:

```text
remotes/origin/
```

Confirm the remote remains healthy:

```bash
git remote show origin
```

---

# V.8 Clean Local Git LFS Cache Carefully

## The Target

Remove unneeded local Git LFS objects without deleting remote assets.

## The Concept

Git LFS may retain local copies of large objects after branches or files are removed.

The command:

```bash
git lfs prune
```

removes local LFS objects that are no longer needed by current references or recent activity.

This affects your local cache. It does not delete remote LFS files from GitHub.

Before pruning, inspect local LFS state:

```bash
git lfs ls-files
git lfs env
```

## The Implementation

Preview what Git LFS considers removable:

```bash
git lfs prune --dry-run
```

If the preview is acceptable:

```bash
git lfs prune
```

Inspect LFS storage afterward.

### macOS or Linux

```bash
du -sh .git/lfs 2>/dev/null || true
```

### Windows PowerShell

```powershell
if (Test-Path .git\lfs) {
  $lfsSize = (Get-ChildItem -Recurse -Force .git\lfs | Measure-Object -Property Length -Sum).Sum
  Write-Output ".git\lfs size in bytes: $lfsSize"
}
```

## The Verification

Confirm normal LFS files remain available:

```bash
git lfs ls-files
```

If Git LFS files are needed later, Git LFS can download them again from the configured remote:

```bash
git lfs pull
```

---

# V.9 Find Large Objects in Git History

## The Target

Identify files that made repository history unexpectedly large.

## The Concept

A file may be deleted from the current branch yet remain in old history.

For example:

```text
Current repository:
No large video file exists.

Historical repository:
A 400 MB video was committed six months ago.
```

The current working tree may look small, but clones remain large because Git history still contains the old object.

You can inspect large packed objects with `git verify-pack`.

## The Implementation

First, identify pack index files.

### macOS, Linux, or Git Bash

```bash
find .git/objects/pack -name '*.idx' -print
```

### Windows PowerShell

```powershell
Get-ChildItem .git\objects\pack -Filter *.idx |
  Select-Object -ExpandProperty FullName
```

For each `.idx` file, run this command. Replace `PACK_INDEX_PATH` with the actual path:

### macOS, Linux, or Git Bash

```bash
git verify-pack -v PACK_INDEX_PATH |
  sort -k 3 -n |
  tail -n 20
```

### Windows PowerShell

```powershell
git verify-pack -v PACK_INDEX_PATH |
  Sort-Object { [int64](($_ -split '\s+')[2]) } |
  Select-Object -Last 20
```

The output includes object IDs and sizes.

To map a large object ID to a file path, use:

```bash
git rev-list --objects --all | grep LARGE_OBJECT_HASH
```

On Windows PowerShell:

```powershell
git rev-list --objects --all | Select-String "LARGE_OBJECT_HASH"
```

## The Verification

You should be able to identify:

```text
Object hash
Object size
Associated file path
```

If a large object should be removed from all history, do not immediately rewrite the repository. Use a documented, coordinated history-cleanup process with backups and `git filter-repo`.

---

# V.10 Use `git filter-repo` for History Cleanup Only with a Plan

## The Target

Understand the safe process for removing files from history.

## The Concept

Removing a file from current project files is easy:

```bash
git rm large-file.zip
```

Removing it from all historical commits is different.

That requires rewriting history. Every affected commit receives a new hash.

This can disrupt:

- Existing clones.
- Open pull requests.
- Forks.
- Release references.
- External systems using commit hashes.

Use `git filter-repo` only when necessary, such as:

- Removing accidentally committed secrets.
- Removing very large files from history.
- Extracting a project from a monorepo.
- Repairing repository structure during a planned migration.

## The Implementation

Do not run this on your active production clone.

Safe process:

```text
1. Create a mirror backup.
2. Announce the planned rewrite.
3. Clone a disposable mirror.
4. Run filter-repo on the disposable mirror.
5. Verify branches, tags, and files.
6. Force-push only through a coordinated plan.
7. Require contributors to reclone or carefully reset.
```

Example command to remove a historical file:

```bash
git filter-repo --path large-file.zip --invert-paths
```

Example command to remove a directory:

```bash
git filter-repo --path archived-assets/ --invert-paths
```

After rewriting, inspect:

```bash
git log --oneline --all
git fsck --full
git count-objects -vH
```

## The Verification

Before publishing rewritten history, confirm:

```text
[ ] The unwanted file no longer appears in any relevant history.
[ ] Important branches and tags still exist or were intentionally replaced.
[ ] CI passes from a clean clone.
[ ] Contributors received migration instructions.
[ ] Secrets were revoked or rotated independently of history cleanup.
```

---

# V.11 Enable Background Maintenance

## The Target

Allow Git to perform lightweight maintenance automatically.

## The Concept

Modern Git can schedule background maintenance tasks.

This can improve performance in repositories that receive frequent updates.

The command:

```bash
git maintenance start
```

asks Git to register supported background maintenance for your user account.

Support depends on operating system, Git version, and available scheduling tools.

## The Implementation

Check current maintenance configuration:

```bash
git config --global --get-regexp '^maintenance\.'
```

Enable background maintenance:

```bash
git maintenance start
```

Inspect configuration again:

```bash
git config --global --get-regexp '^maintenance\.'
```

To stop background maintenance later:

```bash
git maintenance stop
```

## The Verification

Git may display a message indicating that scheduled maintenance was registered.

If your system does not support background scheduling, Git may explain that no scheduler is available. That is not a repository failure.

You can still run maintenance manually:

```bash
git maintenance run
```

---

# V.12 Repository Health Checklist

## The Target

Use a repeatable health check for long-lived repositories.

## The Concept

A repository health check is preventive maintenance.

Most teams do not need to run every command every week. Use this checklist when:

- Git operations become slow.
- Repository size grows unexpectedly.
- A migration is planned.
- Large files were removed.
- Storage limits are approached.
- A disk or filesystem problem occurred.
- A repository has many years of history.

## The Implementation

Run this baseline health check:

```bash
git status
git fetch origin --prune
git fsck --full
git count-objects -vH
git log --oneline --decorate -10
npm test
```

For Git LFS repositories, also run:

```bash
git lfs ls-files
git lfs prune --dry-run
```

Use this checklist:

```text
Repository state
[ ] Working tree is clean.
[ ] Local main is synchronized with origin/main.
[ ] Stale remote-tracking refs are pruned.

Integrity
[ ] git fsck --full reports no corruption.
[ ] Valuable dangling commits are recovered before cleanup.
[ ] Mirror backups exist before major maintenance.

Storage
[ ] git count-objects -vH is reviewed.
[ ] Large objects are understood.
[ ] Git LFS cache is pruned only after dry-run review.
[ ] Generated files and large binaries are not committed accidentally.

Quality
[ ] Automated tests pass.
[ ] CI remains green.
[ ] Recent release tags and branch references are intact.
```

## The Verification

A healthy repository should end with:

```bash
git status
```

Expected output:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

And:

```bash
npm test
```

Expected output includes:

```text
# fail 0
```

---

# V.13 Repository Maintenance Command Reference

## Inspect Git Storage

```bash
git count-objects -vH
```

## Check Object Integrity

```bash
git fsck --full
```

## Inspect Unreachable Objects

```bash
git fsck --no-reflogs --unreachable
```

## Run Routine Maintenance

```bash
git maintenance run
```

## Run Garbage Collection

```bash
git gc
```

## Enable Background Maintenance

```bash
git maintenance start
```

## Stop Background Maintenance

```bash
git maintenance stop
```

## Prune Stale Remote References

```bash
git fetch origin --prune
```

## Inspect LFS Cache Cleanup Candidates

```bash
git lfs prune --dry-run
```

## Prune Local LFS Cache

```bash
git lfs prune
```

## Search for Large Packed Objects

```bash
git verify-pack -v .git/objects/pack/<pack-index>.idx
```

## Create a Mirror Backup

```bash
git clone --mirror <repository-url>
```

---

# Appendix V Completion Check

You should now be able to:

- [ ] Explain why `.git` can grow larger than the current project files.
- [ ] Inspect repository storage with `git count-objects -vH`.
- [ ] Check repository integrity with `git fsck`.
- [ ] Recover valuable dangling commits before cleanup.
- [ ] Create a mirror backup before significant maintenance.
- [ ] Run routine maintenance safely.
- [ ] Prune stale remote-tracking branches.
- [ ] Clean local Git LFS cache only after reviewing a dry run.
- [ ] Identify large historical objects.
- [ ] Understand why history rewriting requires planning and coordination.
- [ ] Run a practical repository health check when performance or integrity concerns arise.
