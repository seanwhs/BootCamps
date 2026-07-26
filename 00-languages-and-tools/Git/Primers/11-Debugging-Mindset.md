# Primer 11: Debugging Mindset, Error Messages, and Safe Recovery

Git is precise, but its output can feel intimidating when something goes wrong.

You may see messages such as:

```text
Your local changes would be overwritten by checkout.
```

```text
CONFLICT (content): Merge conflict in README.md
```

```text
error: failed to push some refs
```

These messages do not automatically mean your repository is broken.

Most Git problems are state problems:

```text
Git needs more information.
Git is protecting uncommitted work.
Git found two conflicting edits.
The remote has changed since you last checked.
```

This primer teaches a calm, repeatable approach to debugging before you use advanced recovery commands.

---

# P11.1 Use the “Stop, Inspect, Preserve” Rule

## The Target

Adopt a safe first response when Git reports an unfamiliar message.

## The Concept

When something unexpected happens, do not immediately type more commands until the error disappears.

Use this sequence:

```text
Stop
    ↓
Inspect
    ↓
Preserve
    ↓
Decide
```

Think of it like troubleshooting a strange noise in a car:

```text
Do not keep driving faster.
Check warning lights.
Preserve safety.
Understand the problem.
Choose the next action.
```

For Git:

```bash
git status
git diff
git diff --staged
git log --oneline --decorate --graph --all -10
```

These commands inspect the repository without changing it.

## The Implementation

Run this safe diagnostic sequence from a Git repository:

```bash
git status
git diff
git diff --staged
git log --oneline --decorate --graph --all -10
```

## The Verification

You should be able to answer:

```text
[ ] Which branch am I on?
[ ] Do I have uncommitted changes?
[ ] Are any changes staged?
[ ] Is a merge, rebase, or cherry-pick in progress?
[ ] What are the most recent commits and branches?
```

---

# P11.2 Read Git Error Messages as Instructions

## The Target

Recognize that Git error output often includes the safest next command.

## The Concept

Git error messages commonly provide guidance in parentheses.

For example:

```text
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
```

Git is telling you:

```text
Option 1:
Keep the change and stage it.

Option 2:
Discard the change.
```

Another example:

```text
Your branch is behind 'origin/main' by 1 commit,
and can be fast-forwarded.
  (use "git pull" to update your local branch)
```

Git is telling you:

```text
GitHub has newer work.
Your local branch can update safely.
```

## The Implementation

Run:

```bash
git status
```

Read every section of the output before running another command.

If the working tree is clean, Git may display:

```text
nothing to commit, working tree clean
```

If changes exist, identify whether they are:

```text
Untracked
Modified but unstaged
Staged
Ahead of remote
Behind remote
Diverged from remote
```

## The Verification

Confirm you understand these phrases:

| Git output | Meaning |
|---|---|
| `Untracked files` | Files exist locally but Git is not tracking them. |
| `Changes not staged for commit` | Files changed locally but are not in the next commit. |
| `Changes to be committed` | Files are staged for the next commit. |
| `working tree clean` | No local file changes remain. |
| `ahead of origin/main` | Local commits need pushing. |
| `behind origin/main` | GitHub has commits you need to fetch or pull. |

---

# P11.3 Preserve Unfinished Work Before Switching Context

## The Target

Avoid losing work when Git prevents a branch switch or pull.

## The Concept

Git may stop you with a message like:

```text
Your local changes to the following files would be overwritten by checkout.
```

This is Git protecting your work.

You have three choices:

```text
Commit it
    → The work is ready and belongs in project history.

Stash it
    → The work is unfinished but worth keeping temporarily.

Discard it
    → The work is definitely unwanted.
```

Do not discard work merely because Git is blocking a branch switch.

## The Implementation

Inspect pending changes:

```bash
git status
git diff
```

If work is ready, commit it:

```bash
git add <intended-file-paths>
git diff --staged
git commit -m "type(scope): describe the change"
```

If work is unfinished, stash it:

```bash
git stash push --include-untracked -m "Work in progress before branch switch"
```

Then switch branches:

```bash
git switch main
```

Restore the work later:

```bash
git switch <original-branch>
git stash pop
```

## The Verification

After stashing, run:

```bash
git status
git stash list
```

Expected status:

```text
nothing to commit, working tree clean
```

Expected stash listing resembles:

```text
stash@{0}: On feature/short-description: Work in progress before branch switch
```

---

# P11.4 Understand Merge Conflicts Without Panic

## The Target

Recognize a merge conflict and understand why Git pauses.

## The Concept

A merge conflict does not mean Git failed completely.

It means Git found two different edits to the same area and refuses to guess which one is correct.

For example:

```text
Original line:
The project is in development.

Branch A:
The project is in active development.

Branch B:
The project is in active testing.
```

Git cannot know whether the final result should use one sentence or combine both.

It marks the conflict:

```text
<<<<<<< HEAD
The project is in active development.
=======
The project is in active testing.
>>>>>>> feature/testing-status
```

The markers mean:

| Marker | Meaning |
|---|---|
| `<<<<<<< HEAD` | Content from your current branch |
| `=======` | Divider between competing versions |
| `>>>>>>> branch-name` | Content from the branch being merged |

## The Implementation

When Git reports a conflict, begin with:

```bash
git status
git diff
```

Open the conflicted file and replace the marked section with the intended final content.

Then verify that conflict markers are gone.

### macOS, Linux, or Git Bash

```bash
grep -nE '^(<<<<<<<|=======|>>>>>>>)' <file-path>
```

### Windows PowerShell

```powershell
Select-String -Path <file-path> -Pattern '^(<<<<<<<|=======|>>>>>>>)'
```

Stage the resolved file:

```bash
git add <file-path>
```

Complete a merge:

```bash
git commit
```

Or continue a rebase:

```bash
git rebase --continue
```

## The Verification

After resolving every conflict, run:

```bash
git status
git diff --check
npm test
```

Expected result after a completed merge:

```text
nothing to commit, working tree clean
```

---

# P11.5 Know How to Abort an In-Progress Operation

## The Target

Cancel a merge, rebase, or cherry-pick when you need to return to the prior state.

## The Concept

Git operations that combine or replay history may pause for a conflict.

If you decide the operation should not continue, use the matching abort command.

| Operation | Abort command |
|---|---|
| Merge | `git merge --abort` |
| Rebase | `git rebase --abort` |
| Cherry-pick | `git cherry-pick --abort` |
| Revert | `git revert --abort` |

Think of aborting as canceling an unfinished assembly process before finalizing it.

Do not use an abort command after the operation is complete. It only applies while Git reports that the operation is in progress.

## The Implementation

Inspect state first:

```bash
git status
```

If Git reports an active merge that you intentionally want to cancel:

```bash
git merge --abort
```

If it reports an active rebase:

```bash
git rebase --abort
```

If it reports an active cherry-pick:

```bash
git cherry-pick --abort
```

## The Verification

After aborting, run:

```bash
git status
```

Git should report the repository state that existed before the unfinished operation began.

---

# P11.6 Understand “Rejected Push” Errors

## The Target

Respond safely when GitHub rejects a push.

## The Concept

A rejected push commonly means the remote branch has newer commits:

```text
Your local main:
A → B

GitHub main:
A → C
```

Git refuses to overwrite GitHub’s commit `C` with your local commit `B`.

A typical error looks like:

```text
! [rejected] main -> main (fetch first)
error: failed to push some refs
```

The safe response is not:

```bash
git push --force
```

Instead:

```text
Fetch remote changes.
Inspect them.
Integrate them safely.
Push afterward.
```

## The Implementation

Inspect state:

```bash
git status
```

Fetch remote updates:

```bash
git fetch origin
```

Inspect incoming commits:

```bash
git log --oneline HEAD..origin/main
```

Inspect local-only commits:

```bash
git log --oneline origin/main..HEAD
```

If you are on `main` and have no local commits to preserve:

```bash
git pull --ff-only
git push
```

If you are on your own feature branch with local commits:

```bash
git pull --rebase
git push
```

## The Verification

After synchronizing, run:

```bash
git status
```

Expected output resembles:

```text
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

---

# P11.7 Use Reflog as a Recovery Map

## The Target

Understand that Git often remembers recently moved or deleted commits.

## The Concept

Normal history shows commits currently reachable from branches and tags.

```bash
git log
```

Reflog shows where references such as `HEAD` pointed recently.

```bash
git reflog
```

Think of reflog as a travel record:

```text
HEAD was here.
Then it moved here.
Then a branch was deleted.
Then a rebase replaced commits.
```

This makes reflog useful after:

```text
Accidental reset
Deleted branch
Amended commit
Rebase mistake
Detached HEAD commit
```

## The Implementation

Inspect recent reflog entries:

```bash
git reflog --date=local -20
```

Output resembles:

```text
a1b2c3d HEAD@{0}: switch: moving from feature/example to main
d4e5f6a HEAD@{1}: commit: Add export example
e7f8a9b HEAD@{2}: switch: moving from main to feature/example
```

If you find a commit that needs recovery, create a branch pointing to it:

```bash
git switch -c recovery/lost-work <commit-hash>
```

## The Verification

Confirm the recovery branch contains the expected work:

```bash
git log --oneline main..HEAD
git show --stat HEAD
```

Do not run destructive cleanup commands such as aggressive garbage collection while you are still recovering work.

---

# P11.8 Know When to Ask for Help

## The Target

Recognize when a Git problem requires coordination rather than more local commands.

## The Concept

Some problems affect shared history, production releases, credentials, or deployment systems.

Pause and ask a maintainer or teammate for help when:

```text
[ ] A secret was committed or pushed.
[ ] You are considering git push --force on a shared branch.
[ ] A protected branch was changed incorrectly.
[ ] A release tag points to the wrong commit.
[ ] A deployment is failing in production.
[ ] You do not understand a merge or rebase conflict.
[ ] A repository appears corrupt.
[ ] You are about to rewrite history that other people use.
```

Asking early is a professional safety practice, not a failure.

## The Implementation

Before escalating, collect useful non-sensitive information:

```bash
git status
git branch --show-current
git log --oneline --decorate --graph --all -20
git reflog -20
```

Then explain:

```text
What command you ran.
What output or error appeared.
What branch you are on.
Whether work is committed, staged, or unstaged.
What outcome you were trying to achieve.
```

Do not paste secrets, tokens, private keys, or customer data into issue comments or chat.

## The Verification

A good help request looks like this:

```text
I am on feature/42-add-export. I ran `git fetch origin` and then
`git rebase origin/main`. Git reports a conflict in README.md. I have not
edited the conflict yet. `git status` says one file is both modified. I need
help deciding whether to keep the feature wording, the main wording, or combine them.
```

---

# Primer 11 Reference: First Commands for Safe Recovery

```bash
git status
git diff
git diff --staged
git log --oneline --decorate --graph --all -10
git reflog -20
```

## Preserve Work

```bash
git stash push --include-untracked -m "Safety snapshot"
```

## Abort In-Progress Operations

```bash
git merge --abort
git rebase --abort
git cherry-pick --abort
git revert --abort
```

## Recover a Commit

```bash
git switch -c recovery/lost-work <commit-hash>
```

---

# Primer 11 Completion Check

Before using advanced recovery commands, confirm that you can:

- [ ] Follow the stop, inspect, preserve, decide rule.
- [ ] Read Git status output as guidance.
- [ ] Commit, stash, or intentionally discard work before switching branches.
- [ ] Recognize merge conflict markers.
- [ ] Resolve a conflict by editing, staging, testing, and completing the operation.
- [ ] Abort an in-progress merge, rebase, cherry-pick, or revert.
- [ ] Respond to a rejected push without force-pushing shared history.
- [ ] Use reflog to locate recently moved or deleted commits.
- [ ] Know when a shared-history, security, or production issue requires help.
- [ ] Collect non-sensitive diagnostic information before asking for assistance.

