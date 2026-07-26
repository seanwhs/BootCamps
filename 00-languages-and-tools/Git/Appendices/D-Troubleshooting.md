# Appendix D: Git Troubleshooting Playbook

This appendix is for the moments when Git output looks unfamiliar, a command fails, or you are worried about losing work.

The most important rule is:

> Stop changing things until you understand the current state.

Start with these commands:

```bash
git status
git log --oneline --decorate --graph --all -15
git reflog -15
```

They answer three different questions:

| Command | Question answered |
|---|---|
| `git status` | What is happening right now? |
| `git log --all` | What branches and commits are visible? |
| `git reflog` | Where did `HEAD` and branches point recently? |

---

# D.1 Before You Fix Anything: Create a Safety Snapshot

## The Target

Preserve current work before attempting a risky recovery operation.

## The Concept

When your workspace is confusing, think of your files as a room after a storm. Do not begin throwing things away while trying to clean it. First, take photographs.

In Git, a temporary branch or stash can preserve current work before you attempt a reset, rebase, merge, or conflict resolution.

## The Implementation

First inspect your repository:

```bash
git status
```

If you have valuable uncommitted work, use a stash:

```bash
git stash push --include-untracked -m "Safety snapshot before Git recovery"
```

If your current branch has commits you want to preserve before rewriting history, create a backup branch:

```bash
git branch backup/before-recovery
```

Inspect the backup branch:

```bash
git branch --verbose
```

## The Verification

Confirm the stash exists:

```bash
git stash list
```

Or confirm the backup branch exists:

```bash
git branch
```

Expected output resembles:

```text
  backup/before-recovery
* feature/current-work
  main
```

You can now investigate with less risk.

---

# D.2 Error: “Your Local Changes Would Be Overwritten”

## The Target

Safely switch branches or pull remote work when Git refuses because of uncommitted changes.

## The Concept

Git protects you when switching branches or pulling would replace files you have modified.

An error may look like:

```text
error: Your local changes to the following files would be overwritten by checkout:
        README.md
Please commit your changes or stash them before you switch branches.
```

Git is saying:

> “You have work on your desk. I cannot safely replace it with another branch’s version.”

You have three choices:

1. Commit the work if it is ready.
2. Stash the work if it is unfinished but worth keeping.
3. Discard the work only if you are certain it is unwanted.

## The Implementation

### Option A: Commit the work

```bash
git status
git diff
git add README.md
git commit -m "Update project documentation"
git switch main
```

### Option B: Stash the work

```bash
git stash push --include-untracked -m "Work in progress before branch switch"
git switch main
```

Restore it later:

```bash
git switch <original-branch>
git stash pop
```

### Option C: Discard the work

Only after reviewing it:

```bash
git diff
git restore README.md
git switch main
```

## The Verification

After committing, stashing, or intentionally discarding the changes, run:

```bash
git status
```

Then switch branches:

```bash
git switch main
```

Expected output:

```text
Switched to branch 'main'
Your branch is up to date with 'origin/main'.
```

---

# D.3 Error: “Failed to Push Some Refs”

## The Target

Resolve a rejected push without overwriting someone else’s work.

## The Concept

A rejected push often means GitHub has commits that your local branch does not have.

Example:

```text
! [rejected]        main -> main (fetch first)
error: failed to push some refs
hint: Updates were rejected because the remote contains work that you do not have locally.
```

This often happens when:

- A teammate pushed a commit.
- You edited a file directly on GitHub.
- Another machine pushed a commit.
- A pull request was merged while you were working.

Do not immediately run:

```bash
git push --force
```

That could overwrite shared remote history.

## The Implementation

Inspect your current state:

```bash
git status
```

Fetch remote information:

```bash
git fetch origin
```

Inspect incoming commits:

```bash
git log --oneline HEAD..origin/main
```

Inspect your local-only commits:

```bash
git log --oneline origin/main..HEAD
```

If you are on `main` and have no local-only commits, update safely:

```bash
git pull --ff-only
git push
```

If you are on a personal feature branch with local commits, rebase onto the remote branch:

```bash
git pull --rebase
git push
```

If a rebase was needed after you had already pushed the feature branch, Git may require:

```bash
git push --force-with-lease
```

Use `--force-with-lease`, not plain `--force`, and only for a branch you own.

## The Verification

Run:

```bash
git status
```

Expected result:

```text
Your branch is up to date with 'origin/<branch-name>'.
nothing to commit, working tree clean
```

---

# D.4 Error: “Merge Conflict”

## The Target

Resolve a standard merge conflict safely.

## The Concept

A merge conflict means Git found competing edits it cannot combine automatically.

Conflict markers look like this:

```text
<<<<<<< HEAD
Text from your current branch.
=======
Text from the branch being merged.
>>>>>>> origin/main
```

These markers are not valid final content. You must choose or write the intended version.

## The Implementation

Inspect all conflicts:

```bash
git status
```

Open each file listed as unmerged.

For example, after resolving `README.md`, stage it:

```bash
git add README.md
```

Check that no markers remain.

### macOS, Linux, or Git Bash

```bash
grep -nE '^(<<<<<<<|=======|>>>>>>>)' README.md
```

### Windows PowerShell

```powershell
Select-String -Path README.md -Pattern '^(<<<<<<<|=======|>>>>>>>)'
```

Then validate whitespace:

```bash
git diff --check
```

Run project tests:

```bash
npm test
```

Complete the merge:

```bash
git commit
```

## The Verification

Run:

```bash
git status
```

Expected output:

```text
On branch <branch-name>
nothing to commit, working tree clean
```

If the merge should not continue, cancel it before committing:

```bash
git merge --abort
```

---

# D.5 Error: “You Have Diverged Branches”

## The Target

Choose a pull strategy when local and remote branches both have unique commits.

## The Concept

A branch has **diverged** when both sides moved independently.

```text
Your local branch:  A → B → C
Remote branch:      A → D → E
```

Git needs instructions about how to combine them.

Options:

| Strategy | Command | Result |
|---|---|---|
| Merge | `git pull --no-rebase` | Creates a merge commit when needed |
| Rebase | `git pull --rebase` | Replays local commits after remote commits |
| Fast-forward only | `git pull --ff-only` | Refuses if history is not linear |

For shared branches such as `main`, prefer team-approved merge behavior or coordinate with maintainers. For your own feature branch, rebasing is commonly appropriate.

## The Implementation

Inspect the graph first:

```bash
git fetch origin
git log --oneline --decorate --graph --all -15
```

On a personal feature branch:

```bash
git pull --rebase
```

If conflicts occur:

```bash
git status
```

Resolve files, then:

```bash
git add <resolved-file>
git rebase --continue
```

If you need to cancel:

```bash
git rebase --abort
```

## The Verification

Inspect the final graph:

```bash
git log --oneline --decorate --graph --all -15
```

Confirm tests pass:

```bash
npm test
```

Then publish updates if needed:

```bash
git push
```

If rebasing rewrote already-pushed feature commits:

```bash
git push --force-with-lease
```

---

# D.6 Error: “Detached HEAD”

## The Target

Recover from detached `HEAD` state and preserve any work created there.

## The Concept

Normally, `HEAD` points to a branch:

```text
HEAD → main → latest commit
```

A detached `HEAD` means Git points directly to a commit instead:

```text
HEAD → specific commit
main → another commit
```

This can happen when checking out a commit hash:

```bash
git checkout a1b2c3d
```

or:

```bash
git switch --detach a1b2c3d
```

Detached HEAD is useful for inspecting historical versions. The danger is making commits there and then switching away without creating a branch.

## The Implementation

Check your state:

```bash
git status
```

Git may report:

```text
HEAD detached at a1b2c3d
```

If you only inspected the old commit and made no changes, return to `main`:

```bash
git switch main
```

If you made commits while detached, preserve them first:

```bash
git switch -c recovery/detached-head-work
```

Then inspect your recovered work:

```bash
git log --oneline main..HEAD
```

## The Verification

Run:

```bash
git branch
```

Expected output resembles:

```text
* recovery/detached-head-work
  main
```

Your work is now anchored to a named branch and will not disappear when you switch branches.

---

# D.7 Error: “Pathspec Did Not Match Any Files”

## The Target

Diagnose a Git command that cannot find the file or branch you named.

## The Concept

A **pathspec** is Git’s term for a file path or pattern supplied to a command.

For example:

```text
error: pathspec 'releaseNotes.js' did not match any file(s) known to git
```

Common causes:

- Typo in a filename.
- Incorrect capitalization.
- Running the command from the wrong directory.
- File exists but is untracked.
- You meant a branch name but typed a file path, or the reverse.

Git is case-sensitive for paths in many environments, even if your operating system is less strict.

## The Implementation

Check the current directory:

### macOS, Linux, or Git Bash

```bash
pwd
ls
```

### Windows PowerShell

```powershell
Get-Location
Get-ChildItem
```

List tracked files:

```bash
git ls-files
```

Find matching files:

### macOS, Linux, or Git Bash

```bash
find . -iname "*release*"
```

### Windows PowerShell

```powershell
Get-ChildItem -Recurse -File | Where-Object { $_.Name -match "release" }
```

Then rerun the Git command with the exact path, for example:

```bash
git add src/releaseNotes.js
```

## The Verification

Run:

```bash
git status
```

The intended file should now appear in the correct section: untracked, modified, or staged.

---

# D.8 Error: “Author Identity Unknown”

## The Target

Configure Git author information when Git refuses to create a commit.

## The Concept

Every Git commit records an author name and email address.

If Git cannot find one, it may print:

```text
Author identity unknown

*** Please tell me who you are.
```

This commonly happens on a new computer, in a new container, or after a fresh Git installation.

## The Implementation

Set your global Git identity:

```bash
git config --global user.name "Your Full Name"
git config --global user.email "you@example.com"
```

Verify the settings:

```bash
git config --global user.name
git config --global user.email
```

For a repository-specific identity, run these commands from inside that repository without `--global`:

```bash
git config user.name "Work Name"
git config user.email "work@example.com"
```

## The Verification

Retry the commit:

```bash
git commit -m "Describe the completed change"
```

Git should create the commit successfully.

Inspect its author:

```bash
git log -1 --format=full
```

---

# D.9 Error: GitHub Authentication Failed

## The Target

Diagnose a failed SSH or HTTPS connection to GitHub.

## The Concept

Authentication failures occur for different reasons depending on the remote URL.

First, determine whether the repository uses SSH or HTTPS:

```bash
git remote -v
```

SSH remote example:

```text
git@github.com:ACCOUNT/repository.git
```

HTTPS remote example:

```text
https://github.com/ACCOUNT/repository.git
```

## The Implementation

### SSH Troubleshooting

Test GitHub authentication:

```bash
ssh -T git@github.com
```

Show detailed connection diagnostics:

```bash
ssh -vT git@github.com
```

Confirm an SSH key is loaded:

```bash
ssh-add -l
```

If no identities are listed, add your private key:

```bash
ssh-add ~/.ssh/id_ed25519
```

Do not run this command with a public key:

```text
id_ed25519.pub
```

Only the private key should be added to the SSH agent.

### HTTPS Troubleshooting

Confirm the remote URL:

```bash
git remote -v
```

Confirm Git Credential Manager or your operating-system helper is configured:

```bash
git config --global credential.helper
```

If Git prompts for a password, use a Personal Access Token, not your GitHub account password.

To remove an old cached credential, use your operating system’s credential manager:

- **macOS:** Keychain Access
- **Windows:** Credential Manager
- **Linux:** Git Credential Manager or your desktop keyring

Then retry:

```bash
git fetch origin
```

## The Verification

A successful SSH test says:

```text
You've successfully authenticated
```

A successful HTTPS test is typically a successful fetch:

```bash
git fetch origin
```

No authentication error should appear.

---

# D.10 Error: “Refusing to Merge Unrelated Histories”

## The Target

Understand why Git refuses to merge repositories with no shared starting commit.

## The Concept

This error often happens when:

1. You created a local repository with `git init`.
2. You created a GitHub repository with a README or license.
3. Both sides have their own first commit.
4. You try to pull or merge them.

Git sees two separate project histories and refuses to join them automatically.

The best prevention is to create an empty GitHub repository before pushing an existing local repository.

## The Implementation

Inspect both histories:

```bash
git log --oneline --decorate --graph --all
```

If you intentionally want to combine the two repositories:

```bash
git pull origin main --allow-unrelated-histories
```

Resolve conflicts if Git reports them:

```bash
git status
```

Then stage the resolution:

```bash
git add <resolved-file>
git commit
```

## The Verification

Inspect the resulting graph:

```bash
git log --oneline --decorate --graph --all
```

You should see a merge commit joining the two histories.

Use this only when you intentionally need to combine independent histories.

---

# D.11 Error: Accidentally Committed to `main`

## The Target

Move an accidental local commit from `main` to a feature branch before pushing it.

## The Concept

A common mistake is creating a commit on `main` when the work should have been on a feature branch.

If the commit has not been pushed, it is easy to relocate:

```text
main: A → B accidental commit
```

Create a feature branch at `B`, then reset `main` back to `A`:

```text
feature/my-work: A → B
main: A
```

## The Implementation

First, confirm the accidental commit is local only:

```bash
git status
git log --oneline origin/main..main
```

Create a feature branch at the current commit:

```bash
git branch feature/move-accidental-main-commit
```

Reset `main` back one commit:

```bash
git reset --hard HEAD~1
```

Switch to the feature branch:

```bash
git switch feature/move-accidental-main-commit
```

Push the feature branch:

```bash
git push -u origin feature/move-accidental-main-commit
```

## The Verification

Inspect `main`:

```bash
git switch main
git log --oneline -2
```

The accidental commit should not appear.

Inspect the feature branch:

```bash
git switch feature/move-accidental-main-commit
git log --oneline -2
```

The accidental commit should appear there.

> If the commit was already pushed to protected `main`, do not reset and force-push. Create a corrective commit or coordinate with maintainers.

---

# D.12 Error: Accidentally Deleted a Branch

## The Target

Recover a deleted branch using reflog.

## The Concept

Deleting a branch removes its label, not necessarily its commits.

Git’s reflog often remembers where the branch pointed recently.

## The Implementation

Search the reflog:

```bash
git reflog --all --oneline -50
```

Find the commit associated with the deleted branch.

Create a new branch at that commit:

```bash
git switch -c recovery/deleted-branch <commit-hash>
```

Inspect it:

```bash
git log --oneline main..HEAD
```

## The Verification

Run:

```bash
git branch
```

Expected output includes:

```text
* recovery/deleted-branch
```

Once confirmed, rename it if desired:

```bash
git branch -m feature/original-branch-name
```

---

# D.13 Error: Accidentally Ran `git reset --hard`

## The Target

Attempt recovery after a hard reset.

## The Concept

A hard reset can remove commits from the current branch and overwrite tracked working files.

If the lost work was committed before the reset, reflog can often recover it.

If the work was never committed or stashed, Git may not be able to recover it.

## The Implementation

Immediately inspect reflog:

```bash
git reflog --date=local -30
```

Find the commit before the hard reset.

Create a recovery branch:

```bash
git switch -c recovery/before-hard-reset <commit-hash>
```

Inspect the recovered files:

```bash
git status
git log --oneline main..HEAD
```

If the recovery branch contains the needed work, preserve it by committing any additional changes and pushing it:

```bash
git push -u origin recovery/before-hard-reset
```

## The Verification

Confirm the expected files exist:

### macOS, Linux, or Git Bash

```bash
ls
```

### Windows PowerShell

```powershell
Get-ChildItem
```

Confirm the expected commit exists:

```bash
git log --oneline -5
```

---

# D.14 Error: “Cannot Delete Branch Checked Out”

## The Target

Delete a local branch after switching away from it.

## The Concept

Git does not let you delete the branch you are currently using.

Example error:

```text
error: Cannot delete branch 'feature/example' checked out at '/path/to/repository'
```

You must first switch to another branch.

## The Implementation

Check the active branch:

```bash
git branch --show-current
```

Switch to `main`:

```bash
git switch main
```

Delete a merged branch safely:

```bash
git branch -d feature/example
```

Delete an intentionally discarded unmerged branch:

```bash
git branch -D feature/example
```

## The Verification

Run:

```bash
git branch
```

The deleted branch should no longer appear.

---

# D.15 Error: GitHub Shows an Old Branch After Deletion

## The Target

Clean stale remote-tracking branch references.

## The Concept

A branch may be deleted on GitHub, but your local Git repository can still remember it until you prune stale references.

## The Implementation

Fetch and prune:

```bash
git fetch --prune
```

Or prune a specific remote:

```bash
git remote prune origin
```

List all branches:

```bash
git branch --all
```

## The Verification

Deleted remote references such as:

```text
remotes/origin/feature/old-branch
```

should no longer appear.

---

# D.16 Troubleshooting Decision Tree

Use this decision tree when you are unsure what to do.

```text
Run git status
│
├── Working tree clean?
│   │
│   ├── Yes
│   │   ├── Need remote changes? → git fetch origin
│   │   ├── Need to update main? → git pull --ff-only
│   │   └── Need a feature? → git switch -c feature/name
│   │
│   └── No
│       ├── Changes ready? → git add → git diff --staged → git commit
│       ├── Changes unfinished? → git stash push -u -m "message"
│       ├── Changes unwanted? → git restore <file>
│       └── Not sure? → create backup branch or stash before proceeding
│
├── Merge/rebase/cherry-pick in progress?
│   │
│   ├── Yes
│   │   ├── Resolve files → git add <file>
│   │   ├── Merge → git commit
│   │   ├── Rebase → git rebase --continue
│   │   ├── Cherry-pick → git cherry-pick --continue
│   │   └── Need to stop? → corresponding --abort command
│   │
│   └── No
│       └── Commit appears lost? → git reflog → git switch -c recovery/name <hash>
```

---

# Appendix D Completion Check

You should now be able to respond methodically when Git reports a problem:

- [ ] Start with `git status`.
- [ ] Preserve valuable work with a stash or backup branch.
- [ ] Resolve rejected pushes without force-pushing shared branches.
- [ ] Resolve or abort merges, rebases, and cherry-picks.
- [ ] Recover deleted branches and reset commits with reflog.
- [ ] Diagnose authentication, identity, path, and remote-history errors.
- [ ] Use `git fetch --prune` to remove stale remote branch references.
