# Primer 14: Backups, Synchronization, and Data-Loss Prevention

Git is powerful because it preserves project history. But Git is not automatically a complete backup strategy.

A local Git repository can be lost if:

- Your computer fails.
- A disk is damaged.
- A folder is deleted.
- A ransomware attack affects local files.
- You never pushed important commits anywhere else.
- You accidentally discard uncommitted work.

Likewise, GitHub is not a replacement for every kind of backup:

- A bad force-push can affect a shared remote branch.
- A repository can be deleted or made inaccessible.
- A compromised account can change repository settings.
- A secret pushed to GitHub remains a security incident even if the repository is backed up.

This primer explains the practical habits that protect your work before you rely on Git for serious projects.

---

# P14.1 Understand the Difference Between Git History and Backup

## The Target

Understand why commits, remotes, and backups solve related but different problems.

## The Concept

A local Git commit protects you from some mistakes:

```text
You edit a file incorrectly
    ↓
You can inspect or restore an earlier committed version
```

But a local commit does not help if the entire computer and its local repository are lost.

A remote push adds another copy:

```text
Your computer
    ↓ git push
GitHub
```

That protects against loss of one local machine, but it may not protect against every remote problem.

A broader backup strategy can include:

```text
Local Git repository
    +
GitHub remote repository
    +
Computer backup service
    +
Periodic mirror backup for important repositories
```

Think of the layers this way:

| Layer | Protects against |
|---|---|
| Working file copy | Small accidental local edits before save |
| Git commit | Reverting tracked project history |
| GitHub push | Loss of your local computer or local repository |
| Mirror backup | Remote mistakes, migration safety, retention requirements |
| Credential rotation | Exposure of passwords, keys, or tokens |

## The Implementation

Inspect whether your current branch has local commits that are not on GitHub:

```bash
git status
git log --oneline origin/main..main
```

If your project uses a feature branch, replace `main` with the relevant branch names:

```bash
git log --oneline origin/feature/short-description..feature/short-description
```

## The Verification

Interpret the results:

| Output | Meaning |
|---|---|
| No output from `git log origin/main..main` | Local `main` has no commits waiting to be pushed. |
| One or more commits appear | Local commits exist only on your computer and should be pushed when ready. |
| `git status` says branch is ahead | The same situation: local commits have not reached GitHub. |

---

# P14.2 Understand the Risk of Uncommitted Work

## The Target

Recognize why uncommitted changes are the most fragile kind of work.

## The Concept

Git can reliably help you recover committed work.

Uncommitted changes are different.

```text
Working directory only
    ↓
Not necessarily in Git history
    ↓
Not necessarily on GitHub
    ↓
May be lost through restore, reset, deletion, or disk failure
```

Think of uncommitted work as notes written on a whiteboard. It may be useful, but it is not yet in the project record.

Use this practical rule:

> If work matters and you are about to stop, switch context, perform a risky command, or close a long-running task, preserve it with a commit or stash.

A commit is better for meaningful progress.

A stash is useful for short-term unfinished work.

## The Implementation

Inspect uncommitted work:

```bash
git status
git diff
git diff --staged
```

If work is ready to preserve as a meaningful checkpoint:

```bash
git add <intended-file-paths>
git diff --staged
git commit -m "type(scope): save work in progress"
```

If work is incomplete but needs temporary protection:

```bash
git stash push --include-untracked -m "Temporary safety snapshot"
```

## The Verification

After committing:

```bash
git status
git log --oneline -1
```

After stashing:

```bash
git status
git stash list
```

In either case, the working tree should normally become clean.

---

# P14.3 Use Commits as Checkpoints, Not as Random Backups

## The Target

Create meaningful commit checkpoints without filling project history with vague or unusable messages.

## The Concept

A commit can serve as a checkpoint, but commit messages still matter.

Weak checkpoint:

```text
WIP
```

Better checkpoint:

```text
feat(formatter): add initial security section support
```

If the work is truly incomplete, make that clear while describing what exists:

```text
wip(formatter): add initial security section parsing
```

Whether `wip` is accepted depends on your project’s commit-message policy. Many teams avoid pushing incomplete work to shared branches and prefer draft pull requests instead.

A good checkpoint commit should answer:

```text
What state did this save?
What can a future developer expect from it?
```

## The Implementation

Use this safe checkpoint pattern when a meaningful slice of work is complete:

```bash
git status
git diff
git add <intended-file-paths>
git diff --staged
npm test
git commit -m "feat(scope): describe completed checkpoint"
```

If tests cannot pass yet because work is intentionally incomplete, do not falsely claim they pass. Instead:

1. Keep the work on a private local branch.
2. Record the known limitation in the commit message or draft pull request.
3. Complete tests before requesting merge.

## The Verification

Inspect the latest checkpoint:

```bash
git show --stat HEAD
git log -1 --format=full
```

Confirm that:

```text
[ ] The commit message explains the saved work.
[ ] The commit contains only intended files.
[ ] Test status is understood and documented.
[ ] The commit is on the correct branch.
```

---

# P14.4 Push Important Work Before Changing Computers

## The Target

Synchronize committed work to GitHub before moving to another computer or ending a work session.

## The Concept

A local commit exists only on the computer where it was created until you push it.

```text
Laptop
└── Local commit exists

GitHub
└── Local commit does not exist yet
```

After pushing:

```text
Laptop
└── Local commit exists

GitHub
└── Same commit exists remotely
```

This makes the work available from another authorized computer through cloning or pulling.

## The Implementation

Inspect whether the current branch is ahead:

```bash
git status
```

If Git reports something similar to:

```text
Your branch is ahead of 'origin/feature/short-description' by 2 commits.
```

push the branch:

```bash
git push
```

For a new branch without an upstream relationship:

```bash
git push -u origin feature/short-description
```

Inspect the updated state:

```bash
git status
```

## The Verification

Expected output resembles:

```text
On branch feature/short-description
Your branch is up to date with 'origin/feature/short-description'.

nothing to commit, working tree clean
```

This confirms the current branch’s commits are synchronized with GitHub.

---

# P14.5 Clone Rather Than Copy a Project Folder to Another Computer

## The Target

Use `git clone` to obtain a complete working copy on another computer.

## The Concept

When moving to a second computer, do not normally copy only the project folder through email, USB storage, or cloud sync.

A copied folder may omit hidden `.git` history or create confusing duplicate states.

Instead:

```text
Push current work to GitHub
    ↓
Use git clone on the second computer
    ↓
Get project files, history, and remote configuration
```

## The Implementation

On the first computer, confirm work is pushed:

```bash
git status
git push
```

On the second computer:

```bash
git clone git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
cd release-notes-manager
```

Or, if using HTTPS:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager.git
cd release-notes-manager
```

Inspect the clone:

```bash
git status
git log --oneline -5
git remote -v
```

## The Verification

Expected status:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Expected remote output identifies the GitHub repository as `origin`.

---

# P14.6 Understand Why Cloud-Synced Project Folders Can Be Risky

## The Target

Avoid using consumer file synchronization as the primary mechanism for synchronizing active Git repositories.

## The Concept

Cloud-sync folders such as Dropbox, OneDrive, iCloud Drive, or Google Drive are useful for ordinary documents.

They can be risky for actively changing Git repositories because Git itself manages many internal files in `.git/`.

Two synchronization systems may operate at the same time:

```text
Git updates .git metadata
    while
Cloud sync copies partially updated files
```

Possible results include:

- Conflicted copies of Git metadata.
- Incomplete object transfers.
- Corrupted or inconsistent repository state.
- Duplicate files.
- Confusing changes on multiple devices.

This does not mean cloud backup is always forbidden. It means you should not rely on active folder synchronization as a replacement for Git push and pull.

## The Implementation

Keep active repositories in a normal projects folder, such as:

```text
~/projects/
```

Use Git for repository synchronization:

```bash
git pull --ff-only
git push
```

If your computer backup service includes the projects folder, that can provide an additional backup layer. Avoid actively editing the same repository from multiple synchronized folder copies.

## The Verification

Confirm your project path is not intentionally duplicated across multiple cloud-synced folders.

Inspect the canonical remote:

```bash
git remote -v
```

Use this remote—not a file-sync folder—as the collaboration and synchronization path.

---

# P14.7 Create a Mirror Backup for Important Repositories

## The Target

Create a complete backup clone for an important repository before migrations, history rewrites, or major maintenance.

## The Concept

A normal clone is designed for development.

A **mirror clone** is designed to preserve all Git references.

It includes:

```text
Branches
Tags
Remote-tracking references
Notes
Other refs
```

Think of it as a sealed archive of the repository rather than a desk copy for active editing.

## The Implementation

Create a backup location.

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

Create a mirror backup:

```bash
git clone --mirror git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
```

Inspect backup references:

```bash
cd release-notes-manager.git
git show-ref
```

Return to the normal project folder after inspection.

### macOS, Linux, or Git Bash

```bash
cd ~/projects/release-notes-manager
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects\release-notes-manager"
```

## The Verification

Confirm the mirror contains branches and tags:

```bash
cd ~/repository-backups/release-notes-manager.git
git show-ref --heads
git show-ref --tags
```

Expected output includes references similar to:

```text
<hash> refs/heads/main
<hash> refs/tags/v1.0.0
```

---

# P14.8 Understand GitHub Availability Versus Your Own Backup Strategy

## The Target

Understand why an external hosted repository is helpful but should not be your only resilience plan.

## The Concept

GitHub provides highly reliable hosting, but responsible teams still plan for:

- Accidental deletion.
- Account compromise.
- Organization access changes.
- Repository migration.
- Compliance retention requirements.
- Offline or independent recovery needs.

For a personal learning project, this may be enough:

```text
Local repository
    +
GitHub remote
    +
Computer backup
```

For an important production project, consider:

```text
Primary GitHub repository
    +
Scheduled mirror backup
    +
Organization access controls
    +
Protected branches
    +
Documented recovery procedure
```

## The Implementation

Create a simple backup policy for yourself or your team:

```md
# Repository Backup Policy

- Push completed work to GitHub at the end of each work session.
- Keep device backups enabled for the local projects directory.
- Create a mirror backup before migrations, history rewrites, or major repository maintenance.
- Store mirror backups in a secure location.
- Test restoration procedures for critical repositories.
- Review repository access and backup ownership periodically.
```

Keep this policy in internal documentation or add an adapted version to `GOVERNANCE.md` if it is relevant to the project.

## The Verification

Confirm you can answer:

```text
[ ] Where does the authoritative shared repository live?
[ ] Which work is currently local only?
[ ] Where is the latest independent backup?
[ ] Who can restore the repository if one maintainer loses access?
```

---

# P14.9 Practice Safe Recovery from a Local File Mistake

## The Target

Use a low-risk workflow to recover from an accidental local file edit.

## The Concept

Not every problem requires reflog, reset, or emergency recovery.

For a simple unstaged mistake:

```text
Edit file accidentally
    ↓
Inspect difference
    ↓
Restore file
```

The correct command is:

```bash
git restore <file>
```

But always inspect the change first.

## The Implementation

Create a temporary local edit in `README.md`:

```md
This temporary sentence should not be kept.
```

Inspect the change:

```bash
git status
git diff -- README.md
```

Discard it only after confirming it is unwanted:

```bash
git restore README.md
```

## The Verification

Run:

```bash
git status
git diff -- README.md
```

Expected result:

```text
nothing to commit, working tree clean
```

And the diff command should produce no output.

---

# P14.10 Backup and Synchronization Checklist

## The Target

Use a practical routine that prevents common forms of lost work.

## The Concept

The best recovery strategy is avoiding avoidable loss.

## The Implementation

Use this checklist.

```text
Before ending work
[ ] Run git status.
[ ] Commit meaningful completed work.
[ ] Stash unfinished work only if needed.
[ ] Push important commits to GitHub.
[ ] Confirm the branch is up to date with its upstream.

Before risky operations
[ ] Run git status.
[ ] Review git diff and git diff --staged.
[ ] Create a backup branch or stash if work matters.
[ ] Create a mirror backup before migrations or history rewriting.
[ ] Record important commit hashes and release tags.

When changing computers
[ ] Push from the first computer.
[ ] Clone from GitHub on the second computer.
[ ] Avoid copying active repository folders through file-sync services.

When recovering
[ ] Stop and inspect.
[ ] Use git status first.
[ ] Preserve current work before reset or restore operations.
[ ] Use reflog for apparently lost committed work.
[ ] Ask for help before force-pushing or rewriting shared history.
```

## The Verification

Run this end-of-session sequence:

```bash
git status
git log --oneline origin/main..main
git push
git status
```

For a feature branch, use the corresponding upstream branch.

Expected final output:

```text
Your branch is up to date with 'origin/<branch-name>'.

nothing to commit, working tree clean
```

---

# Primer 14 Reference: Backup and Synchronization Commands

## Inspect Local-Only Commits

```bash
git log --oneline origin/main..main
```

## Push Current Branch

```bash
git push
```

## Push New Branch and Configure Upstream

```bash
git push -u origin feature/short-description
```

## Clone a Repository

```bash
git clone git@github.com:OWNER/REPOSITORY.git
```

## Create a Mirror Backup

```bash
git clone --mirror git@github.com:OWNER/REPOSITORY.git
```

## List References in a Mirror Backup

```bash
git show-ref
```

## Preserve Unfinished Work Temporarily

```bash
git stash push --include-untracked -m "Temporary safety snapshot"
```

## Restore an Unwanted Unstaged Edit

```bash
git restore <file-path>
```

---

# Primer 14 Completion Check

Before relying on Git for important work, confirm that you can:

- [ ] Explain the difference between Git history, GitHub synchronization, and backups.
- [ ] Identify local commits that have not been pushed.
- [ ] Explain why uncommitted work is fragile.
- [ ] Use commits as meaningful checkpoints.
- [ ] Push important work before ending a session or changing computers.
- [ ] Clone repositories rather than copying active project folders manually.
- [ ] Explain why cloud-sync folders are risky as the primary Git synchronization method.
- [ ] Create a mirror backup before migration or history rewrite work.
- [ ] Restore a simple unstaged file mistake safely.
- [ ] Follow an end-of-session synchronization routine.
