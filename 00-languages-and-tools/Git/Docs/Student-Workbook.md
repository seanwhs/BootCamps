# Student Workbook  
## Mastering Version Control from Local to Production

**Student name:** ________________________________  
**Date started:** _________________________________  
**GitHub username:** ______________________________  
**Repository URL:** _______________________________  

---

## How to Use This Workbook

For each module:

1. Read the tutorial section.
2. Complete the hands-on commands.
3. Record observations and answers here.
4. Check off verification steps before continuing.
5. Keep this workbook with your project repository or learning notes.

> **Safety habit:** When uncertain, run:
>
> ```bash
> git status
> ```

---

# Part 0: Introduction

## Learning Goals

By the end of this series, I will be able to:

- [ ] Explain the difference between Git and GitHub.
- [ ] Create and manage local Git repositories.
- [ ] Use branches, merges, and rebases safely.
- [ ] Collaborate through GitHub Issues and Pull Requests.
- [ ] Use CI with GitHub Actions.
- [ ] Create releases and recover from mistakes.

## My Project

**Project name:** ____________________________________________

**Project purpose:**  
__________________________________________________________________  
__________________________________________________________________  

## Core Mental Model

Complete the flow:

```text
Working Directory
        │
        │ ______________________
        ▼
Staging Area
        │
        │ ______________________
        ▼
Local Repository
        │
        │ ______________________
        ▼
GitHub Remote Repository
```

## Reflection

Why is Git more useful than creating folders such as `final-v2-final.zip`?

__________________________________________________________________  
__________________________________________________________________  
__________________________________________________________________  

---

# Part 1: Foundations of Local Version Control

## 1.1 Git Identity

Record your Git identity settings:

```bash
git config --global user.name
git config --global user.email
```

**Configured name:** _____________________________________________  
**Configured email:** ____________________________________________  

- [ ] My Git identity is correct.
- [ ] My initial branch defaults to `main`.

---

## 1.2 Repository Setup

**Repository folder path:**  
__________________________________________________________________

Commands completed:

```bash
mkdir -p ~/projects/release-notes-manager
cd ~/projects/release-notes-manager
git init
git status
```

What does Git store inside the `.git` directory?

__________________________________________________________________  
__________________________________________________________________  

---

## 1.3 The Three Local States

Match the concept to the explanation.

| Git area | Explanation |
|---|---|
| Working Directory | ______________________________________________ |
| Staging Area | ______________________________________________ |
| Local Repository | ______________________________________________ |

Write the normal workflow:

```text
Edit file
    ↓
________________________
    ↓
________________________
    ↓
________________________
```

---

## 1.4 First Commit

**First commit message:**  
__________________________________________________________________

Commands used:

```bash
git add README.md
git commit -m "Add initial project documentation"
```

Record the first commit hash:

```bash
git log --oneline -1
```

**Commit hash:** ________________________________

- [ ] I created a first commit.
- [ ] `git status` reports a clean working tree.

---

## 1.5 Inspecting Changes

Fill in the purpose of each command.

| Command | Purpose |
|---|---|
| `git status` | ______________________________________________ |
| `git diff` | ______________________________________________ |
| `git diff --staged` | ______________________________________________ |
| `git log --oneline` | ______________________________________________ |
| `git show HEAD` | ______________________________________________ |

Practice note: What difference did you inspect before your latest commit?

__________________________________________________________________  
__________________________________________________________________  

---

## 1.6 Safe Undo

Complete the table.

| Situation | Command |
|---|---|
| Discard unstaged edits in one file | ______________________________ |
| Unstage a file but keep its edits | ______________________________ |
| Inspect current repository state | ______________________________ |

> Warning: `git restore <file>` can discard uncommitted work.

- [ ] I practiced restoring an unwanted unstaged file edit.
- [ ] I practiced unstaging without deleting file changes.

---

# Part 2: Branching and Merging

## 2.1 Branching Mental Model

A branch is best described as:

```text
[ ] A complete copy of every project file.
[ ] A lightweight pointer to a commit.
[ ] A GitHub-only feature.
[ ] A backup archive.
```

Why are branches useful?

__________________________________________________________________  
__________________________________________________________________  

---

## 2.2 Feature Branch Practice

**Feature branch name:**  
__________________________________________________________________

Commands completed:

```bash
git switch main
git switch -c feature/short-description
git branch
```

- [ ] I created a feature branch.
- [ ] I confirmed the active branch with `git branch --show-current`.
- [ ] I made at least one focused commit on the feature branch.

---

## 2.3 Merge Types

| Merge type | When it happens | Result |
|---|---|---|
| Fast-forward merge | __________________________ | __________________________ |
| Three-way merge | __________________________ | __________________________ |

Draw a simple branch graph:

```text
main:     ______________________________

feature:  ______________________________
```

---

## 2.4 Conflict Resolution Exercise

Conflict markers:

```text
<<<<<<< HEAD
Current branch content
=======
Incoming branch content
>>>>>>> feature/branch-name
```

What does each marker mean?

| Marker | Meaning |
|---|---|
| `<<<<<<< HEAD` | ______________________________________________ |
| `=======` | ______________________________________________ |
| `>>>>>>> branch-name` | ______________________________________________ |

Conflict resolution workflow:

```text
1. Run ______________________________
2. Edit the conflicted file.
3. Remove all conflict markers.
4. Run ______________________________
5. Stage the resolved file.
6. Complete the merge or rebase.
```

- [ ] I resolved a merge conflict.
- [ ] I ran tests after resolving it.
- [ ] I understand `git merge --abort`.

---

## 2.5 Rebase Reflection

When is rebasing generally appropriate?

__________________________________________________________________  
__________________________________________________________________  

Why can rebasing shared branches cause problems?

__________________________________________________________________  
__________________________________________________________________  

---

# Part 3: Going Remote with GitHub

## 3.1 Remote Repository Details

**GitHub repository URL:**  
__________________________________________________________________

**Authentication method used:**

```text
[ ] SSH
[ ] HTTPS with Personal Access Token
```

**Remote name:** ________________________________________________

Commands:

```bash
git remote -v
git remote show origin
```

---

## 3.2 SSH or PAT Safety

Complete the statements.

```text
My SSH private key should ________________________________________.

My SSH public key can ____________________________________________.

A Personal Access Token should never _____________________________.
```

- [ ] I enabled GitHub two-factor authentication.
- [ ] I tested SSH with `ssh -T git@github.com`, or configured HTTPS/PAT safely.
- [ ] I understand that tokens and private keys are secrets.

---

## 3.3 Push, Fetch, and Pull

| Command | What it does |
|---|---|
| `git push` | ______________________________________________ |
| `git fetch origin` | ______________________________________________ |
| `git pull` | ______________________________________________ |
| `git pull --ff-only` | ______________________________________________ |

Safe synchronization routine:

```bash
git fetch origin
git log --oneline main..origin/main
git diff main..origin/main
git pull --ff-only
```

What does `origin/main` represent?

__________________________________________________________________  
__________________________________________________________________  

---

## 3.4 `.gitignore`

List files or folders that should normally be ignored:

```text
1. ______________________________________________
2. ______________________________________________
3. ______________________________________________
4. ______________________________________________
5. ______________________________________________
```

Test command:

```bash
git check-ignore -v .env
```

Why does `.gitignore` not remove already tracked files?

__________________________________________________________________  
__________________________________________________________________  

---

# Part 4: Professional Collaboration and Code Review

## 4.1 GitHub Flow

Complete the workflow:

```text
Updated main
    ↓
Create ______________________________
    ↓
Make code, test, and documentation changes
    ↓
Push branch
    ↓
Open ______________________________
    ↓
Review and CI
    ↓
Merge into ______________________________
```

---

## 4.2 Issue Planning

**Issue number:** ________________________________  
**Issue title:** __________________________________  

Write acceptance criteria for a future change:

```text
[ ] ______________________________________________
[ ] ______________________________________________
[ ] ______________________________________________
[ ] ______________________________________________
```

Why are acceptance criteria useful?

__________________________________________________________________  
__________________________________________________________________  

---

## 4.3 Pull Request Readiness

Before opening a PR, run:

```bash
git status
git diff main...HEAD
git log --oneline main..HEAD
npm test
```

PR checklist:

```text
[ ] The branch has one focused purpose.
[ ] The PR links to an issue when appropriate.
[ ] Tests pass locally.
[ ] Documentation is updated.
[ ] The diff contains no secrets or generated files.
[ ] The PR description includes verification steps.
```

**PR title:**  
__________________________________________________________________

**PR URL:**  
__________________________________________________________________

---

## 4.4 Code Review Practice

Write one example of each kind of review comment.

**Blocking comment:**

__________________________________________________________________  
__________________________________________________________________  

**Question:**

__________________________________________________________________  
__________________________________________________________________  

**Suggestion:**

__________________________________________________________________  
__________________________________________________________________  

**Praise:**

__________________________________________________________________  
__________________________________________________________________  

---

## 4.5 Review Checklist

| Review area | Question |
|---|---|
| Correctness | Does the change meet acceptance criteria? |
| Tests | ______________________________________________ |
| Security | ______________________________________________ |
| Documentation | ______________________________________________ |
| Scope | ______________________________________________ |
| CI | ______________________________________________ |

- [ ] I reviewed a pull request diff.
- [ ] I checked test results.
- [ ] I understand approval versus requested changes.
- [ ] I understand why `main` should be protected.

---

# Part 5: Advanced Git and Automation

## 5.1 Amend and Interactive Rebase

| Command | Purpose |
|---|---|
| `git commit --amend` | ______________________________________________ |
| `git commit --amend --no-edit` | ______________________________________________ |
| `git rebase -i HEAD~3` | ______________________________________________ |

When should you avoid rewriting history?

__________________________________________________________________  
__________________________________________________________________  

---

## 5.2 Stash

Commands:

```bash
git stash push -m "Work in progress"
git stash push --include-untracked -m "Include new files"
git stash list
git stash apply
git stash pop
```

What is the difference between `apply` and `pop`?

__________________________________________________________________  
__________________________________________________________________  

- [ ] I created a stash.
- [ ] I inspected it with `git stash show --patch`.
- [ ] I restored it safely.

---

## 5.3 Reflog and Recovery

Command:

```bash
git reflog --date=local -20
```

What does reflog help you recover from?

```text
[ ] Deleted branches
[ ] Reset mistakes
[ ] Amended commits
[ ] Rebase mistakes
[ ] All of the above
```

Recovery pattern:

```bash
git switch -c recovery/lost-work <commit-hash>
```

**Recovered commit hash from practice:**  
__________________________________________________________________

---

## 5.4 Reset Modes

| Command | Commit history | Staging area | Working files |
|---|---|---|---|
| `git reset --soft HEAD~1` | __________________ | __________________ | __________________ |
| `git reset --mixed HEAD~1` | __________________ | __________________ | __________________ |
| `git reset --hard HEAD~1` | __________________ | __________________ | __________________ |

Why is `git reset --hard` dangerous?

__________________________________________________________________  
__________________________________________________________________  

---

## 5.5 GitHub Actions CI

Workflow file:

```text
.github/workflows/ci.yml
```

Complete the CI flow:

```text
Push or pull request
    ↓
GitHub Actions runner
    ↓
Check out ______________________________
    ↓
Set up ______________________________
    ↓
Install ______________________________
    ↓
Run ______________________________
```

Why should a test workflow use minimum permissions?

__________________________________________________________________  
__________________________________________________________________  

- [ ] I created or reviewed a CI workflow.
- [ ] I confirmed CI passes on a pull request.
- [ ] I understand how to inspect failed logs.

---

# Security Workbook

## Secret Safety

Never commit:

```text
[ ] Passwords
[ ] API keys
[ ] Personal Access Tokens
[ ] Private SSH keys
[ ] Production credentials
[ ] Real .env files
```

If a secret is pushed, what happens first?

```text
1. ______________________________________________
2. ______________________________________________
3. ______________________________________________
4. ______________________________________________
```

Correct first answer:

```text
Rotate or revoke the exposed credential.
```

---

## Workflow Security

Review checklist:

```text
[ ] Workflow permissions use least privilege.
[ ] Test workflows use contents: read where possible.
[ ] Secrets are not printed in logs.
[ ] pull_request_target is not used to execute untrusted PR code.
[ ] Deployment secrets use protected GitHub Environments.
[ ] Third-party Actions are trusted and pinned according to policy.
```

---

# Release Workbook

## Semantic Versioning

| Change | Version impact |
|---|---|
| Backward-compatible bug fix | ______________________________ |
| Backward-compatible feature | ______________________________ |
| Breaking API change | ______________________________ |

Current version: ______________________________  
Next planned version: __________________________  

Reason:

__________________________________________________________________  
__________________________________________________________________  

---

## Release Checklist

```text
[ ] main is current and clean.
[ ] Tests pass locally.
[ ] CI passes on main.
[ ] Release notes are accurate.
[ ] package.json version is correct.
[ ] Tag version matches package version.
[ ] Annotated tag points to intended commit.
[ ] GitHub Release is created from the tag.
```

Release tag command:

```bash
git tag -a vX.Y.Z -m "Release version X.Y.Z"
git push origin vX.Y.Z
```

**Release tag created:** ______________________________  
**GitHub Release URL:** _______________________________  

---

# Incident and Recovery Workbook

## Incident Response Sequence

Complete the lifecycle:

```text
Detect
    ↓
________________________
    ↓
________________________
    ↓
Restore
    ↓
________________________
    ↓
Communicate
    ↓
________________________
```

Correct sequence:

```text
Detect → Contain → Preserve → Restore → Verify → Communicate → Prevent
```

---

## Safe Shared-Branch Rollback

Command:

```bash
git revert <bad-commit-hash>
```

Why is revert safer than force-pushing a reset on shared `main`?

__________________________________________________________________  
__________________________________________________________________  

For a merge commit:

```bash
git revert -m 1 <merge-commit-hash>
```

What does `-m 1` mean?

__________________________________________________________________  
__________________________________________________________________  

---

# Final Skills Assessment

Check every statement you can confidently perform.

## Local Git

```text
[ ] Initialize a repository.
[ ] Configure Git identity.
[ ] Create focused commits.
[ ] Inspect status, diff, staged diff, and history.
[ ] Restore unwanted unstaged edits.
[ ] Unstage files without deleting edits.
```

## Branching

```text
[ ] Create and switch branches.
[ ] Complete fast-forward and three-way merges.
[ ] Resolve merge conflicts.
[ ] Rebase a personal feature branch safely.
[ ] Delete merged branches.
```

## GitHub

```text
[ ] Configure SSH or HTTPS/PAT authentication.
[ ] Push, fetch, pull, clone, and inspect remotes.
[ ] Use .gitignore and .env.example safely.
[ ] Create issues and pull requests.
[ ] Review code and respond to feedback.
```

## Automation and Releases

```text
[ ] Create or read a GitHub Actions workflow.
[ ] Run and interpret npm tests.
[ ] Require CI before merge.
[ ] Create annotated tags.
[ ] Publish GitHub Releases.
```

## Recovery and Operations

```text
[ ] Use stash safely.
[ ] Use reflog to find lost work.
[ ] Cherry-pick a focused commit.
[ ] Explain reset modes.
[ ] Revert a bad shared commit.
[ ] Create a mirror backup before risky migration work.
```

---

# Final Reflection

What is the most important Git habit you will adopt?

__________________________________________________________________  
__________________________________________________________________  
__________________________________________________________________  

What Git or GitHub topic needs more practice?

__________________________________________________________________  
__________________________________________________________________  
__________________________________________________________________  

What workflow will you use before opening every pull request?

__________________________________________________________________  
__________________________________________________________________  
__________________________________________________________________
