# Part 5: Advanced Git and Automation

This final part teaches the tools developers use when ordinary commit-and-push workflows are not enough.

You will learn to:

- Clean up local commit history before review.
- Amend a commit message or include a forgotten file.
- Temporarily set unfinished work aside with stashing.
- Recover commits that appear lost.
- Move a specific commit to another branch with cherry-picking.
- Understand safe reset modes.
- Create GitHub Actions continuous integration (CI) that runs tests automatically.

These commands are powerful. The guiding safety rule is:

> Inspect first, preserve work when uncertain, and rewrite only history that you own.

---

## Part 5 Roadmap

```text
Clean local history
    ↓
Amend and interactive rebase
    ↓
Temporarily save unfinished work
    ↓
Recover from mistakes
    ↓
Move focused commits between branches
    ↓
Reset with intention
    ↓
Automate quality checks with GitHub Actions
```

---

# Step 1: Establish a Safe Starting Point

## The Target

Confirm that local `main` is clean, synchronized, and tested before practicing advanced operations.

## The Concept

Advanced Git commands are like performing maintenance on a car engine. You should start from a known, stable state—not while the car is moving and parts are scattered on the floor.

Before rebasing, resetting, or cherry-picking, inspect:

- Your active branch.
- Uncommitted changes.
- Local-only commits.
- Remote-only commits.
- Recent history.

## The Implementation

From your original repository directory:

```bash
cd ~/projects/release-notes-manager
```

On Windows PowerShell:

```powershell
Set-Location "$HOME\projects\release-notes-manager"
```

Run:

```bash
git switch main
git pull --ff-only
git status
git log --oneline --decorate --graph -10
npm test
```

## The Verification

Expected status:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Expected test result includes:

```text
# fail 0
```

Do not continue until `main` is clean and tests pass.

---

# Step 2: Understand Commit Amendments

## The Target

Learn when and how to amend the most recent local commit.

## The Concept

`git commit --amend` replaces the most recent commit with a new commit.

Think of it as replacing the latest page in a notebook before anyone else has received a copy. The older page is no longer the current version, and Git writes a corrected replacement.

You can amend:

- The commit message.
- The files included in the commit.
- Both the message and the files.

Because amendment creates a new commit hash, avoid amending commits that have already been pushed and shared unless your team explicitly agrees and you understand how to update the remote safely.

## The Implementation

Create a temporary local practice branch:

```bash
git switch -c practice/amend-commit
```

Create a file:

### `release-notes-manager/AMENDMENT_PRACTICE.md`

```md
# Amendment Practice

This file exists only to demonstrate how Git commit amendments work.
```

Commit it with an intentionally imperfect message:

```bash
git add AMENDMENT_PRACTICE.md
git commit -m "Add amendment practce file"
```

Inspect the latest commit:

```bash
git log --oneline -1
```

Now correct the typo in the commit message:

```bash
git commit --amend -m "Add amendment practice file"
```

## The Verification

Run:

```bash
git log --oneline -1
```

Expected output:

```text
<new-hash> Add amendment practice file
```

Notice that the hash changed. Compare it with the hash printed before amendment.

Inspect the file in the latest commit:

```bash
git show --stat HEAD
```

---

# Step 3: Amend a Commit to Include a Forgotten File

## The Target

Add a forgotten file to the latest commit without creating a separate cleanup commit.

## The Concept

Sometimes you make a commit and immediately realize you forgot one file that belongs to the same logical change.

Instead of producing history like this:

```text
Add release formatter documentation
Oops add missing example
```

you can amend the first commit before it is shared:

```text
Add release formatter documentation
```

This is appropriate only when the forgotten file is truly part of the same focused change.

## The Implementation

Create a second file on the practice branch.

### `release-notes-manager/AMENDMENT_NOTES.md`

```md
# Amendment Notes

A commit amendment replaces the latest commit with a new version of that commit.

Use amendments for local, unshared history when the correction belongs to the same logical change.
```

Stage the file:

```bash
git add AMENDMENT_NOTES.md
```

Amend the previous commit without changing its message:

```bash
git commit --amend --no-edit
```

The `--no-edit` flag means:

> “Keep the existing commit message.”

## The Verification

Run:

```bash
git show --stat HEAD
```

Expected output includes both files:

```text
 AMENDMENT_NOTES.md    | ...
 AMENDMENT_PRACTICE.md | ...
```

Confirm the message remains correct:

```bash
git log --oneline -1
```

---

# Step 4: Clean Up Local History with Interactive Rebase

## The Target

Use interactive rebase to squash two local commits into one clean commit.

## The Concept

An **interactive rebase** lets you rewrite a sequence of local commits.

Think of it as editing a draft before publication. You can reorder, rename, combine, or remove draft paragraphs before sending the final document.

The command:

```bash
git rebase -i HEAD~2
```

means:

> “Interactively rewrite the two commits before the current commit.”

Common interactive rebase actions:

| Action | Meaning |
|---|---|
| `pick` | Keep the commit unchanged. |
| `reword` | Keep the commit but edit its message. |
| `edit` | Pause at the commit so you can modify it. |
| `squash` | Combine this commit with the previous commit and edit the message. |
| `fixup` | Combine with the previous commit and discard this commit’s message. |
| `drop` | Remove the commit. |

Never use interactive rebase casually on a branch others are already using. It rewrites commit hashes.

## The Implementation

Your practice branch has two commits only if you intentionally created a second commit. Currently, the two amendment files are in one amended commit, so create a second focused practice commit.

Create this file:

### `release-notes-manager/INTERACTIVE_REBASE.md`

```md
# Interactive Rebase Practice

Interactive rebase can combine small local commits before a pull request is opened.
```

Commit it:

```bash
git add INTERACTIVE_REBASE.md
git commit -m "Add interactive rebase notes"
```

Now create another small related file:

### `release-notes-manager/REBASE_COMMANDS.md`

```md
# Rebase Commands

Use `git rebase -i HEAD~2` to interactively rewrite the latest two commits.

Use `squash` to combine a commit with the commit directly above it.
```

Commit it:

```bash
git add REBASE_COMMANDS.md
git commit -m "Add rebase command reference"
```

Inspect the branch-only history:

```bash
git log --oneline main..HEAD
```

Start an interactive rebase of the latest two commits:

```bash
git rebase -i HEAD~2
```

Your configured editor opens with content similar to:

```text
pick <hash-1> Add interactive rebase notes
pick <hash-2> Add rebase command reference
```

Change it to:

```text
pick <hash-1> Add interactive rebase notes
squash <hash-2> Add rebase command reference
```

Save and close the editor.

Git opens another editor for the combined commit message. Replace all content with:

```text
Add interactive rebase documentation
```

Save and close the editor.

## The Verification

Run:

```bash
git log --oneline main..HEAD
```

Expected output now has one combined commit for the two rebase documentation files:

```text
<hash> Add interactive rebase documentation
<hash> Add amendment practice file
```

Inspect the files included in the combined commit:

```bash
git show --stat HEAD
```

Expected output includes:

```text
 INTERACTIVE_REBASE.md | ...
 REBASE_COMMANDS.md    | ...
```

---

# Step 5: Handle an Interactive Rebase Conflict

## The Target

Understand the controls used if interactive rebase pauses because of a conflict.

## The Concept

Interactive rebase replays commits one by one. If a replayed commit conflicts with the new base, Git pauses and asks you to decide what the final file should contain.

The recovery process is nearly identical to normal rebase conflict resolution:

```text
Inspect conflict
    ↓
Edit file and remove markers
    ↓
Stage resolved file
    ↓
Continue rebase
```

## The Implementation

Do not intentionally create another conflict in your repository.

Use these commands as your operational reference:

```bash
git status
```

Inspect the conflict.

```bash
git diff
```

Read the conflicting regions.

Edit the affected file and remove all markers:

```text
<<<<<<<
=======
>>>>>>>
```

Stage the resolved file:

```bash
git add <resolved-file-path>
```

Continue:

```bash
git rebase --continue
```

Skip the current commit only if you intentionally do not want its changes:

```bash
git rebase --skip
```

Cancel the full rebase and restore the pre-rebase branch state:

```bash
git rebase --abort
```

## The Verification

Your current practice branch should remain clean:

```bash
git status
```

Expected output:

```text
On branch practice/amend-commit
nothing to commit, working tree clean
```

---

# Step 6: Delete the Local Practice Branch

## The Target

Remove the temporary history-rewriting practice branch without affecting `main`.

## The Concept

The practice branch contains local-only educational commits. It should not be merged or pushed.

Deleting a branch removes its branch label. The commits may still be recoverable temporarily through the reflog, but do not rely on that as a storage strategy.

## The Implementation

Switch back to `main`:

```bash
git switch main
```

Delete the practice branch:

```bash
git branch -D practice/amend-commit
```

The uppercase `-D` is intentional here because the branch contains unmerged practice commits that you deliberately want to discard.

## The Verification

Run:

```bash
git branch
git status
```

Expected branch output:

```text
* main
```

Expected status:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

---

# Step 7: Temporarily Save Work with Git Stash

## The Target

Use `git stash` to set unfinished changes aside without committing them.

## The Concept

A **stash** is a temporary shelf for unfinished work.

Imagine you are painting a room when an urgent maintenance task appears. You do not want to throw away the paint or claim the room is finished. You put the supplies on a labeled shelf, handle the urgent task, then return and restore the supplies.

Use stashing when:

- You need to switch branches quickly.
- You need to pull or inspect a hotfix.
- Your current work is incomplete and should not become a commit.
- You need a clean working tree temporarily.

Do not use stashes as permanent storage. A branch and commit are safer for work you need to keep.

## The Implementation

Create a temporary unfinished change in `README.md` by appending this section:

```md
## Temporary Draft Note

This unfinished documentation note is used to demonstrate Git stashing.
```

Do not stage or commit it.

Inspect the change:

```bash
git status
git diff -- README.md
```

Create a named stash:

```bash
git stash push -m "Draft README note for stash practice"
```

## The Verification

Run:

```bash
git status
git stash list
```

Expected status:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Expected stash output resembles:

```text
stash@{0}: On main: Draft README note for stash practice
```

Confirm that the temporary section is absent from the working copy:

```bash
git diff -- README.md
```

The command should produce no output.

---

# Step 8: Inspect and Restore Stashed Work

## The Target

Inspect a stash, restore it, then cleanly remove it.

## The Concept

A stash has its own reference, such as:

```text
stash@{0}
```

You can inspect it before restoring:

```bash
git stash show --patch stash@{0}
```

There are two common restore commands:

```bash
git stash apply
```

Restores changes but keeps the stash entry.

```bash
git stash pop
```

Restores changes and removes the stash entry if restoration succeeds.

Use `apply` when you want the safer option first. Use `pop` when you are confident you no longer need the stored copy.

## The Implementation

Inspect the latest stash:

```bash
git stash show --patch stash@{0}
```

Restore it while keeping the stash:

```bash
git stash apply stash@{0}
```

Inspect the restored change:

```bash
git status
git diff -- README.md
```

Now discard the temporary demonstration change:

```bash
git restore README.md
```

Remove the stash entry:

```bash
git stash drop stash@{0}
```

## The Verification

Run:

```bash
git status
git stash list
```

Expected status:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

`git stash list` should produce no output.

---

# Step 9: Include Untracked Files in a Stash

## The Target

Learn how to stash a newly created untracked file.

## The Concept

By default, `git stash` saves changes to tracked files but does not include untracked files.

If you create a new file and need to stash it too, use:

```bash
git stash push --include-untracked -m "message"
```

The short form is:

```bash
git stash -u
```

Be careful: ignored files are still excluded. To include ignored files as well, Git supports `--all`, but that can capture large directories such as `node_modules`, so avoid it unless you have a specific reason.

## The Implementation

Create an untracked temporary file:

### `release-notes-manager/STASHED_DRAFT.md`

```md
# Stashed Draft

This untracked file is used to demonstrate stashing untracked files.
```

Confirm it is untracked:

```bash
git status
```

Stash it with untracked-file support:

```bash
git stash push --include-untracked -m "Stash untracked draft file"
```

## The Verification

Run:

```bash
git status
git stash list
```

Expected stash output resembles:

```text
stash@{0}: On main: Stash untracked draft file
```

Confirm the file is absent:

### macOS, Linux, or Git Bash

```bash
test ! -f STASHED_DRAFT.md && echo "File is stashed."
```

### Windows PowerShell

```powershell
if (-not (Test-Path STASHED_DRAFT.md)) { Write-Output "File is stashed." }
```

Restore and remove the stash:

```bash
git stash pop
```

Then remove the demonstration file:

### macOS, Linux, or Git Bash

```bash
rm STASHED_DRAFT.md
```

### Windows PowerShell

```powershell
Remove-Item STASHED_DRAFT.md
```

Confirm cleanliness:

```bash
git status
```

---

# Step 10: Understand the Reflog Safety Net

## The Target

Use `git reflog` to find commits that were moved, amended, reset, or otherwise made hard to find.

## The Concept

`git log` shows reachable commit history from your current branches.

`git reflog` shows where references such as `HEAD` and branches have pointed recently.

Think of `git log` as the official table of contents in a book. Think of `git reflog` as the security-camera record showing which pages you visited and when.

This makes reflog useful after:

- Accidentally deleting a branch.
- Resetting to the wrong commit.
- Amending a commit you need to recover.
- Completing a rebase you want to undo.
- Losing track of a commit hash.

Reflog entries usually expire eventually, so recover important work promptly.

## The Implementation

Run:

```bash
git reflog --date=local -15
```

You will see entries similar to:

```text
<hash> HEAD@{0}: switch: moving from practice/amend-commit to main
<hash> HEAD@{1}: rebase (finish): returning to refs/heads/practice/amend-commit
<hash> HEAD@{2}: rebase (squash): Add interactive rebase documentation
...
```

Do not reset anything yet.

## The Verification

Confirm that reflog output includes recent operations such as:

- `switch`
- `commit`
- `rebase`
- `reset` if you have used it
- `stash` activity in some Git versions

You now know where to look when a commit seems to have disappeared.

---

# Step 11: Recover a Deleted Branch from Reflog

## The Target

Recover the deleted practice branch as a demonstration, inspect it, then remove it again.

## The Concept

When you deleted `practice/amend-commit`, its commits were removed from normal branch listings but were likely still referenced in the reflog.

To recover, create a new branch pointing to the desired historical commit:

```bash
git switch -c recovered-practice <commit-hash>
```

This is like placing a new bookmark at a page you thought you had lost.

## The Implementation

Find the commit from the deleted practice branch:

```bash
git reflog --all --oneline | grep "Add interactive rebase documentation"
```

On Windows PowerShell:

```powershell
git reflog --all --oneline | Select-String "Add interactive rebase documentation"
```

Copy the hash at the beginning of that line.

Create a recovered branch, replacing `RECOVERY_HASH`:

```bash
git switch -c recovered-practice RECOVERY_HASH
```

Inspect the recovered branch:

```bash
git log --oneline main..HEAD
git status
```

## The Verification

You should see the practice commits again, including:

```text
Add interactive rebase documentation
Add amendment practice file
```

Return to `main` and delete the demonstration recovery branch:

```bash
git switch main
git branch -D recovered-practice
```

Confirm:

```bash
git branch
git status
```

---

# Step 12: Cherry-Pick a Specific Commit

## The Target

Create a focused commit on one branch and apply that exact commit to another branch with `git cherry-pick`.

## The Concept

A **cherry-pick** copies one existing commit onto your current branch.

Imagine selecting one ripe cherry from a tree rather than moving the entire tree.

Use cherry-pick when:

- A bug fix on one branch is also needed on another branch.
- You need one specific documentation change without merging a larger feature branch.
- You need to apply an emergency fix to a release branch.

Avoid cherry-picking blindly. It can duplicate changes if the target branch already contains equivalent work.

## The Implementation

Create a source branch:

```bash
git switch -c docs/add-security-guidance
```

Create this file.

### `release-notes-manager/SECURITY.md`

```md
# Security Guidance

## Secrets

Do not commit passwords, API keys, personal access tokens, private keys, or `.env` files.

If a secret is committed, revoke or rotate it immediately. Removing the file from a later commit does not make the exposed credential safe.

## Dependency Safety

Use trusted package sources. Review package changes before installation and keep Node.js updated with supported security releases.

## Pull Requests

Review pull requests for accidental secrets, unsafe input handling, and unexpected generated files.
```

Commit it:

```bash
git add SECURITY.md
git commit -m "Add security guidance"
```

Copy the commit hash:

```bash
git rev-parse HEAD
```

Now switch to `main`:

```bash
git switch main
```

Apply the specific commit, replacing `SECURITY_COMMIT_HASH` with the hash you copied:

```bash
git cherry-pick SECURITY_COMMIT_HASH
```

## The Verification

Run:

```bash
git log --oneline -3
git show --stat HEAD
```

Expected latest commit message:

```text
Add security guidance
```

The cherry-picked commit has a different hash from the original source-branch commit because it has a different parent commit.

Push the new `main` commit:

```bash
git push
```

Delete the now-unneeded source branch:

```bash
git branch -d docs/add-security-guidance
```

---

# Step 13: Handle Cherry-Pick Conflicts

## The Target

Understand the controls needed when cherry-picking conflicts.

## The Concept

A cherry-pick can conflict when the target branch has changed the same lines differently from the source commit.

The resolution pattern is:

```bash
git status
```

Inspect conflicting files.

Edit files and remove conflict markers.

```bash
git add <resolved-file>
git cherry-pick --continue
```

Continue applying the selected commit.

To cancel the operation:

```bash
git cherry-pick --abort
```

To skip the selected commit:

```bash
git cherry-pick --skip
```

## The Implementation

No conflict should occur in the security-guidance exercise because `SECURITY.md` is a new file.

Inspect Git’s help:

```bash
git cherry-pick -h
```

## The Verification

Confirm the repository remains clean:

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

# Step 14: Understand `git reset` Modes

## The Target

Learn the difference between soft, mixed, and hard reset modes before using them.

## The Concept

`git reset` moves the current branch pointer to another commit. Depending on the mode, it may also change the staging area and working directory.

Think of Git state as three layers:

```text
Commit history → Staging area → Working directory
```

Reset modes affect different layers:

| Command | Commit history | Staging area | Working directory |
|---|---|---|---|
| `git reset --soft <commit>` | Moves | Keeps changes staged | Keeps files unchanged |
| `git reset --mixed <commit>` | Moves | Unstages changes | Keeps files unchanged |
| `git reset --hard <commit>` | Moves | Resets | Replaces files with target commit |

The default mode is `--mixed`.

The dangerous command is:

```bash
git reset --hard <commit>
```

It can permanently discard uncommitted changes. Do not use it unless you have verified the target and do not need current work.

---

# Step 15: Practice Soft Reset Safely

## The Target

Create a local commit, then undo the commit while keeping its changes staged.

## The Concept

A soft reset is useful when you want to replace one commit with a better-organized commit.

For example:

```text
Current:
A → B

After git reset --soft HEAD~1:
A
```

But the changes from `B` remain staged, ready for a new commit.

## The Implementation

Create a temporary practice branch:

```bash
git switch -c practice/reset-modes
```

Create this file.

### `release-notes-manager/RESET_PRACTICE.md`

```md
# Reset Practice

This file is used to demonstrate safe reset modes.
```

Commit it:

```bash
git add RESET_PRACTICE.md
git commit -m "Add reset practice file"
```

Now perform a soft reset:

```bash
git reset --soft HEAD~1
```

## The Verification

Run:

```bash
git status
git log --oneline -2
```

Expected status includes:

```text
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   RESET_PRACTICE.md
```

The commit disappeared from branch history, but the file is still staged.

Restore the commit:

```bash
git commit -m "Add reset practice file"
```

---

# Step 16: Practice Mixed Reset Safely

## The Target

Undo the latest practice commit while keeping the file in the working directory but unstaged.

## The Concept

Mixed reset is Git’s default reset mode.

After:

```bash
git reset --mixed HEAD~1
```

the commit is removed from the current branch and its changes remain in your working directory—but not in the staging area.

This is useful when you want to re-select which changes belong in the next commit.

## The Implementation

Run:

```bash
git reset --mixed HEAD~1
```

## The Verification

Run:

```bash
git status
```

Expected output includes:

```text
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
        new file:   RESET_PRACTICE.md
```

The file exists but is unstaged.

Stage and recommit it:

```bash
git add RESET_PRACTICE.md
git commit -m "Add reset practice file"
```

---

# Step 17: Understand Hard Reset Without Destroying Work

## The Target

Learn a safe way to evaluate `git reset --hard` without using it on valuable changes.

## The Concept

Hard reset makes all three Git layers match the target commit:

```text
History:      reset
Staging area: reset
Working tree: reset
```

This is useful for disposable local branches or when you intentionally want to discard all local changes.

Before a hard reset, always run:

```bash
git status
git log --oneline --decorate -5
```

If the changes matter, create a backup branch first:

```bash
git branch backup/before-hard-reset
```

Or create a stash:

```bash
git stash push -u -m "Backup before hard reset"
```

## The Implementation

On the disposable `practice/reset-modes` branch, run:

```bash
git reset --hard HEAD~1
```

This removes the practice commit and its tracked file from the branch.

## The Verification

Check the file.

### macOS, Linux, or Git Bash

```bash
test ! -f RESET_PRACTICE.md && echo "Hard reset removed the practice file."
```

### Windows PowerShell

```powershell
if (-not (Test-Path RESET_PRACTICE.md)) { Write-Output "Hard reset removed the practice file." }
```

Inspect status:

```bash
git status
```

Expected output is clean.

Return to `main` and delete the disposable branch:

```bash
git switch main
git branch -D practice/reset-modes
```

---

# Step 18: Create a GitHub Actions CI Workflow

## The Target

Add a GitHub Actions workflow that runs the Node.js test suite on pushes and pull requests.

## The Concept

**Continuous Integration**, usually called **CI**, is automatic quality checking whenever code changes.

Think of CI as an always-available test technician. Each time a pull request is opened or updated, the technician:

1. Gets a fresh copy of the project.
2. Sets up the required runtime.
3. Runs the test suite.
4. Reports pass or fail status.

GitHub Actions is GitHub’s automation platform. Workflow files live in:

```text
.github/workflows/
```

and use YAML, a configuration format based on indentation.

Your workflow will run when:

- Code is pushed to `main`.
- A pull request targets `main`.

## The Implementation

Create the workflow directory.

### macOS, Linux, or Git Bash

```bash
mkdir -p .github/workflows
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path ".github\workflows" -Force
```

Create this file.

### `release-notes-manager/.github/workflows/ci.yml`

```yaml
name: Continuous Integration

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

# Use the minimum permissions required by this read-only test workflow.
permissions:
  contents: read

jobs:
  test:
    name: Run Node.js tests
    runs-on: ubuntu-latest

    steps:
      # Checks out the exact commit that triggered this workflow.
      - name: Check out repository
        uses: actions/checkout@v4

      # Installs the supported Node.js version declared for CI.
      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: "npm"

      # npm ci is intentionally not used yet because this project has no
      # package-lock.json or third-party dependencies. npm install validates
      # package metadata and remains safe for the current dependency-free app.
      - name: Install dependencies
        run: npm install

      - name: Run test suite
        run: npm test
```

Validate the YAML visually:

- Indentation uses spaces, not tabs.
- `jobs` is aligned with `on`.
- `steps` is nested under `test`.
- Each list item begins with `-`.

Run tests locally:

```bash
npm test
```

Commit the workflow:

```bash
git add .github/workflows/ci.yml
git commit -m "Add continuous integration workflow"
```

Push the change:

```bash
git push
```

## The Verification

Open your GitHub repository and select the **Actions** tab.

You should see a workflow named:

```text
Continuous Integration
```

Open the newest run.

Expected successful job steps:

```text
Check out repository
Set up Node.js
Install dependencies
Run test suite
```

The final status should be green and show:

```text
Success
```

---

# Step 19: Require the CI Check Before Merging

## The Target

Update branch protection so pull requests cannot merge until the CI workflow succeeds.

## The Concept

A passing local test is helpful, but it is not enough for a team process. Different machines can have different environments, and someone might forget to run tests.

Requiring a GitHub Actions check turns “please run tests” into an enforceable rule.

Think of it as an airport gate that does not open until the safety checklist is complete.

## The Implementation

On GitHub:

1. Open the repository **Settings**.
2. Open **Branches** or **Rules**.
3. Edit the rule or ruleset that protects `main`.
4. Enable:

   ```text
   Require status checks to pass before merging
   ```

5. Search for and select the check named:

   ```text
   Run Node.js tests
   ```

   Depending on GitHub’s interface, the check may appear as:

   ```text
   Continuous Integration / Run Node.js tests
   ```

6. Enable:

   ```text
   Require branches to be up to date before merging
   ```

7. Save the rule.

If the workflow check does not appear immediately, wait for at least one successful workflow run, refresh the settings page, and try again.

## The Verification

Create a temporary pull request branch:

```bash
git switch -c docs/verify-ci-protection
```

Append this line to `CODE_REVIEW.md`:

```md
- [ ] Required continuous integration checks pass before merging.
```

Commit and push:

```bash
git add CODE_REVIEW.md
git commit -m "Document required CI checks"
git push -u origin docs/verify-ci-protection
```

Open a pull request into `main`.

Confirm the PR checks section includes a successful check resembling:

```text
Continuous Integration / Run Node.js tests — Successful
```

Do not merge yet; you will use this pull request in the next step.

---

# Step 20: Verify CI Failure and Recovery

## The Target

Intentionally create a test failure in the pull request branch, observe GitHub Actions fail, then fix it.

## The Concept

A CI workflow is valuable only if it reliably blocks broken code.

You will make a deliberately incorrect expectation in a test. GitHub Actions should fail. Then you will restore the correct behavior and confirm that the workflow returns to green.

This is the same feedback loop teams depend on every day:

```text
Push change
   ↓
CI runs automatically
   ↓
Failure identifies a problem
   ↓
Fix and push
   ↓
CI passes
```

## The Implementation

You should still be on:

```text
docs/verify-ci-protection
```

In `src/releaseNotes.test.js`, locate this expected string:

```js
# Release 1.0.0
```

Change the first occurrence in the first test to this intentionally incorrect value:

```js
# Release 9.9.9
```

Run tests locally:

```bash
npm test
```

The test should fail.

Commit and push the intentionally broken test:

```bash
git add src/releaseNotes.test.js
git commit -m "Demonstrate CI test failure"
git push
```

Open the pull request’s **Checks** tab and wait for GitHub Actions to finish.

After observing the failure, restore the expected string:

```js
# Release 1.0.0
```

Run tests locally again:

```bash
npm test
```

Commit and push the fix:

```bash
git add src/releaseNotes.test.js
git commit -m "Restore formatter test expectation"
git push
```

## The Verification

The first workflow run should fail at:

```text
Run test suite
```

The log should show an assertion failure because the expected value used `9.9.9` while the formatter correctly generated `1.0.0`.

After restoring the expected value, the newest workflow run should pass.

Your pull request should show a green check for:

```text
Continuous Integration / Run Node.js tests
```

---

# Step 21: Merge the CI Verification Pull Request

## The Target

Merge the documentation-only pull request after the required CI check succeeds.

## The Concept

This final PR demonstrates the full production-quality path:

```text
Issue or planned work
    ↓
Feature branch
    ↓
Focused commits
    ↓
Pull request
    ↓
Automated CI
    ↓
Review and merge
    ↓
Stable main
```

The intentionally broken test commit is part of the branch history. If your repository uses squash merging, it will not clutter `main` with the intermediate failure demonstration.

## The Implementation

On GitHub:

1. Open the `docs/verify-ci-protection` pull request.
2. Confirm:
   - CI passes.
   - The final diff contains only the intended `CODE_REVIEW.md` checklist addition.
   - The incorrect test expectation has been restored.
3. Merge using **Squash and merge**.
4. Use this squash commit title:

   ```text
   Document required CI checks
   ```

5. Delete the branch on GitHub when prompted.

Update local `main`:

```bash
git switch main
git pull --ff-only
git fetch --prune
```

Run the final health checks:

```bash
git status
npm test
git log --oneline --decorate -8
```

## The Verification

Expected status:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Expected test result:

```text
# fail 0
```

Open GitHub Actions and confirm the most recent workflow run on `main` is green.

---

# Part 5 Reference: Advanced Git Command Guide

## Amend

```bash
git commit --amend -m "Correct commit message"
```

Replace the most recent commit with the same content and a new message.

```bash
git add <forgotten-file>
git commit --amend --no-edit
```

Add staged content to the most recent commit while preserving its message.

---

## Interactive Rebase

```bash
git rebase -i HEAD~3
```

Interactively rewrite the last three commits.

```text
pick
```

Keep the commit.

```text
reword
```

Keep the commit but change its message.

```text
squash
```

Combine with the previous commit and edit the combined message.

```text
fixup
```

Combine with the previous commit and discard this commit’s message.

```text
drop
```

Remove the commit.

```bash
git rebase --continue
```

Continue after resolving a conflict.

```bash
git rebase --abort
```

Cancel the rebase and restore the original branch state.

---

## Stash

```bash
git stash push -m "Describe unfinished work"
```

Stash tracked-file changes.

```bash
git stash push --include-untracked -m "Include new files"
```

Stash tracked and untracked changes.

```bash
git stash list
```

List saved stashes.

```bash
git stash show --patch stash@{0}
```

Inspect a stash.

```bash
git stash apply stash@{0}
```

Restore a stash while keeping the stash entry.

```bash
git stash pop
```

Restore and remove the newest stash.

```bash
git stash drop stash@{0}
```

Delete one stash entry.

---

## Recovery

```bash
git reflog
```

Show recent reference movements.

```bash
git switch -c recovered-work <commit-hash>
```

Create a recovery branch pointing to a reflog commit.

---

## Cherry-Pick

```bash
git cherry-pick <commit-hash>
```

Apply one commit from elsewhere onto the current branch.

```bash
git cherry-pick --continue
```

Continue after resolving a cherry-pick conflict.

```bash
git cherry-pick --abort
```

Cancel the cherry-pick.

---

## Reset

```bash
git reset --soft HEAD~1
```

Undo the latest commit while keeping its changes staged.

```bash
git reset --mixed HEAD~1
```

Undo the latest commit while keeping its changes unstaged in the working directory.

```bash
git reset --hard HEAD~1
```

Discard the latest commit and overwrite staging plus working files to match the earlier commit.

Use `--hard` only after confirming you do not need current work.

---

# Part 5 Reference: GitHub Actions Workflow Anatomy

This is the workflow added in this part:

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

Key terms:

| YAML element | Meaning |
|---|---|
| `name` | Friendly workflow or job name displayed in GitHub. |
| `on` | Events that trigger the workflow. |
| `permissions` | GitHub token permissions granted to the workflow. |
| `jobs` | Independent units of work GitHub Actions runs. |
| `runs-on` | Runner operating system image. |
| `steps` | Ordered commands or reusable actions in a job. |
| `uses` | Runs a reusable GitHub Action. |
| `run` | Runs a shell command. |

---

# Final Project Architecture

At the end of the series, the repository should resemble:

```text
release-notes-manager/
├── .github/
│   └── workflows/
│       └── ci.yml
├── src/
│   ├── releaseNotes.js
│   └── releaseNotes.test.js
├── .gitignore
├── CODE_REVIEW.md
├── GLOSSARY.md
├── README.md
├── RELEASE_CHECKLIST.md
├── RELEASE_NOTES.md
├── SECURITY.md
└── package.json
```

And your complete delivery workflow is now:

```text
Create or refine an issue
        ↓
Create a focused branch from updated main
        ↓
Write code, tests, and documentation
        ↓
Commit focused changes
        ↓
Push branch and open pull request
        ↓
Review code and resolve discussions
        ↓
GitHub Actions runs CI
        ↓
Update branch if main changes
        ↓
Merge only when reviews and checks pass
        ↓
Pull updated main locally
```

---

# Final Series Completion Checklist

## Local Git Foundations

- [ ] You understand working directory, staging area, and repository.
- [ ] You can inspect changes with `git status` and `git diff`.
- [ ] You can create focused commits.
- [ ] You can safely restore unstaged changes.

## Branching and History

- [ ] You can create, switch, merge, and delete branches.
- [ ] You understand fast-forward and three-way merges.
- [ ] You can resolve merge conflicts.
- [ ] You understand when rebasing is appropriate.

## GitHub Remotes

- [ ] You can authenticate using SSH or HTTPS with a PAT.
- [ ] You can push, fetch, pull, and clone.
- [ ] You understand remote-tracking branches.
- [ ] You can use `.gitignore` to avoid committing secrets and generated files.

## Collaboration

- [ ] You use feature branches and pull requests.
- [ ] You can write issues with clear acceptance criteria.
- [ ] You can review code systematically.
- [ ] You understand labels, milestones, and Projects.
- [ ] You can update a PR branch when `main` changes.

## Advanced Git and Automation

- [ ] You can amend local commits.
- [ ] You can squash local commits with interactive rebase.
- [ ] You can stash unfinished work safely.
- [ ] You can use reflog to recover apparently lost work.
- [ ] You can cherry-pick a specific commit.
- [ ] You understand soft, mixed, and hard reset modes.
- [ ] GitHub Actions automatically runs tests for `main` and pull requests.
- [ ] Protected-branch rules require CI before merging.
