# Student Notes  
## Mastering Version Control from Local to Production

**Name:** ______________________________  
**GitHub username:** ____________________  
**Repository URL:** _____________________  
**Date:** ______________________________  

---

# Part 0: Introduction

## Key Ideas

- Git is: _________________________________________________
- GitHub is: ______________________________________________
- Version control helps me: _________________________________
- My project is called: _____________________________________

## Architecture

```text
Working Directory
      ↓
Staging Area
      ↓
Local Repository
      ↓
GitHub Remote Repository
```

## Notes

__________________________________________________________________

__________________________________________________________________

__________________________________________________________________

---

# Part 1: Local Git Foundations

## The Three States

| State | My Notes |
|---|---|
| Working Directory | __________________________________________ |
| Staging Area | __________________________________________ |
| Local Repository | __________________________________________ |

## Essential Commands

```bash
git status
git add <file>
git commit -m "message"
git diff
git diff --staged
git log --oneline
```

## Commands I Need to Remember

| Command | What It Does |
|---|---|
| `git status` | __________________________________________ |
| `git diff` | __________________________________________ |
| `git add <file>` | __________________________________________ |
| `git commit -m "message"` | __________________________________________ |
| `git restore <file>` | __________________________________________ |
| `git restore --staged <file>` | __________________________________________ |

## Notes

__________________________________________________________________

__________________________________________________________________

__________________________________________________________________

---

# Part 2: Branching and Merging

## Branch Mental Model

A branch is:

__________________________________________________________________

```text
main → ____________________

feature/my-work → ____________________
```

## Essential Commands

```bash
git branch
git switch main
git switch -c feature/short-description
git merge feature/short-description
git branch -d feature/short-description
```

## Merge Notes

| Concept | My Notes |
|---|---|
| Fast-forward merge | __________________________________________ |
| Three-way merge | __________________________________________ |
| Merge conflict | __________________________________________ |
| Rebase | __________________________________________ |

## Conflict Markers

```text
<<<<<<< HEAD
Current branch version
=======
Incoming branch version
>>>>>>> branch-name
```

Resolution process:

```text
1. __________________________________________
2. __________________________________________
3. __________________________________________
4. __________________________________________
```

## Notes

__________________________________________________________________

__________________________________________________________________

__________________________________________________________________

---

# Part 3: GitHub Remotes

## Remote Concepts

| Term | My Notes |
|---|---|
| `origin` | __________________________________________ |
| `origin/main` | __________________________________________ |
| Upstream branch | __________________________________________ |
| Clone | __________________________________________ |
| Fork | __________________________________________ |

## Essential Commands

```bash
git remote -v
git remote add origin <url>
git push -u origin main
git fetch origin
git pull --ff-only
git clone <url>
```

## Fetch vs Pull

```text
git fetch:
____________________________________________________________

git pull:
____________________________________________________________
```

## Authentication

```text
My authentication method:
[ ] SSH
[ ] HTTPS with PAT
```

**Important security note:**

__________________________________________________________________

## `.gitignore` Notes

```text
Files that should not be committed:

1. __________________________________________
2. __________________________________________
3. __________________________________________
4. __________________________________________
```

---

# Part 4: Collaboration and Code Review

## GitHub Flow

```text
Issue
  ↓
Feature Branch
  ↓
Code + Tests + Documentation
  ↓
Pull Request
  ↓
CI + Review
  ↓
Merge into main
```

## Issue Notes

A useful issue contains:

```text
[ ] Summary
[ ] Why it matters
[ ] Acceptance criteria
[ ] Example or context
[ ] __________________________________________
```

## Pull Request Checklist

```text
[ ] Focused purpose
[ ] Linked issue
[ ] Tests pass
[ ] Documentation updated
[ ] Diff reviewed
[ ] CI passes
[ ] Required approval received
```

## Review Feedback Labels

| Label | Meaning |
|---|---|
| `blocking:` | __________________________________________ |
| `question:` | __________________________________________ |
| `suggestion:` | __________________________________________ |
| `nit:` | __________________________________________ |
| `praise:` | __________________________________________ |

## Notes

__________________________________________________________________

__________________________________________________________________

__________________________________________________________________

---

# Part 5: Advanced Git and Automation

## Amend and Rebase

```bash
git commit --amend
git commit --amend --no-edit
git rebase -i HEAD~3
```

My notes:

__________________________________________________________________

## Stash

```bash
git stash push -m "message"
git stash push --include-untracked -m "message"
git stash list
git stash apply
git stash pop
```

Difference between `apply` and `pop`:

__________________________________________________________________

## Recovery

```bash
git reflog
git switch -c recovery/lost-work <commit-hash>
```

My recovery notes:

__________________________________________________________________

## Reset Modes

| Command | What It Does |
|---|---|
| `git reset --soft HEAD~1` | __________________________________________ |
| `git reset --mixed HEAD~1` | __________________________________________ |
| `git reset --hard HEAD~1` | __________________________________________ |

## CI Notes

```text
GitHub Actions workflow location:

____________________________________________________________
```

```text
Main CI command:

____________________________________________________________
```

---

# Security Notes

## Never Commit

```text
[ ] Passwords
[ ] API keys
[ ] Tokens
[ ] Private keys
[ ] Real .env files
[ ] Production credentials
```

## If a Secret Is Exposed

```text
1. __________________________________________
2. __________________________________________
3. __________________________________________
4. __________________________________________
```

## Important Commands

```bash
git check-ignore -v .env
git ls-files .env
git diff --staged
```

---

# Release Notes

## Semantic Versioning

```text
MAJOR.MINOR.PATCH
```

| Change Type | Version Change |
|---|---|
| Bug fix | __________________________________________ |
| New compatible feature | __________________________________________ |
| Breaking change | __________________________________________ |

## Release Commands

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
gh release create v1.0.0 --generate-notes
```

## My Release Notes

__________________________________________________________________

__________________________________________________________________

---

# Troubleshooting Notes

## First Commands to Run When Confused

```bash
git status
git diff
git diff --staged
git log --oneline --decorate --graph --all -10
git reflog -20
```

## Abort Commands

| Situation | Command |
|---|---|
| Merge in progress | `git merge --abort` |
| Rebase in progress | `git rebase --abort` |
| Cherry-pick in progress | `git cherry-pick --abort` |
| Revert in progress | `git revert --abort` |

## My Common Errors and Fixes

| Error or Situation | Fix |
|---|---|
| __________________________________ | __________________________________ |
| __________________________________ | __________________________________ |
| __________________________________ | __________________________________ |
| __________________________________ | __________________________________ |

---

# Personal Git Workflow

## Before Starting Work

```bash
git switch main
git pull --ff-only
git status
git switch -c feature/short-description
```

## Before Committing

```bash
git status
git diff
git add <files>
git diff --staged
npm test
git commit -m "type(scope): describe change"
```

## Before Opening a Pull Request

```bash
git diff main...HEAD
git log --oneline main..HEAD
npm test
git push -u origin feature/short-description
```

## After Merging

```bash
git switch main
git pull --ff-only
git fetch --prune
git branch -d feature/short-description
```

---

# Final Notes

## Most Important Things I Learned

1. __________________________________________________________

2. __________________________________________________________

3. __________________________________________________________

4. __________________________________________________________

5. __________________________________________________________

## Commands I Want to Practice More

```text
1. __________________________________________
2. __________________________________________
3. __________________________________________
```

## Questions to Ask Later

__________________________________________________________________

__________________________________________________________________

__________________________________________________________________
