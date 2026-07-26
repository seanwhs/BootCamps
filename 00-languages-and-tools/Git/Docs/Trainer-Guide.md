# Trainer Guide  
## Mastering Version Control from Local to Production

This guide supports instructors delivering the Git and GitHub tutorial series as a workshop, bootcamp module, internal engineering training, or self-paced cohort program.

---

## 1. Training Overview

### Course Title

**Mastering Version Control from Local to Production**

### Recommended Audience

- Developers new to Git and GitHub.
- Students learning collaborative software development.
- Engineers who know basic commands but lack a reliable mental model.
- Cross-functional contributors who need to participate in issues, pull requests, and reviews.
- Teams standardizing their Git and GitHub workflow.

### Recommended Delivery Formats

| Format | Suggested duration |
|---|---:|
| Intensive workshop | 2 full days |
| Cohort program | 5 sessions of 2–3 hours |
| Weekly course | 6–8 weeks |
| Self-paced | 15–25 hours of hands-on work |
| Team onboarding module | 1–2 days plus follow-up practice |

### Prerequisites

Learners should have:

- Git installed.
- A terminal available.
- A code editor, preferably Visual Studio Code.
- Node.js 18+ installed for the JavaScript and CI sections.
- A GitHub account for Parts 3–5.
- A basic understanding of files and folders.

Use the Primer modules before the main series when learners are unfamiliar with terminals, Markdown, Node.js, GitHub authentication, or shell commands.

---

## 2. Trainer Preparation Checklist

Before the session, confirm:

```text
[ ] Git is installed on trainer and learner devices.
[ ] Learners can open a terminal.
[ ] Learners have GitHub accounts.
[ ] Learners can authenticate through SSH or HTTPS/PAT.
[ ] Node.js and npm are installed.
[ ] Internet access allows GitHub and GitHub Actions.
[ ] A sample GitHub organization or classroom repository is available if needed.
[ ] Branch protection settings are prepared for collaboration exercises.
[ ] A backup repository or practice repository exists for destructive-command demonstrations.
[ ] Learners have access to the Student Workbook and Student Notes.
[ ] The trainer has a prepared merge-conflict example.
[ ] The trainer has a prepared CI failure example.
```

### Recommended Trainer Repository Setup

Prepare one demonstration repository with:

```text
release-notes-manager/
├── .github/
│   └── workflows/
│       └── ci.yml
├── src/
│   ├── releaseNotes.js
│   └── releaseNotes.test.js
├── .gitignore
├── README.md
├── RELEASE_NOTES.md
├── package.json
└── ...
```

Also prepare disposable branches:

```text
demo/merge-conflict
demo/rebase-practice
demo/broken-ci
demo/recovery-practice
demo/revert-practice
```

Never demonstrate `git reset --hard`, `git push --force`, branch deletion, or history rewriting on the only copy of important work.

---

## 3. Learning Outcomes

By the end of the series, learners should be able to:

### Local Git

- Explain working directory, staging area, and local repository.
- Initialize a Git repository.
- Stage and commit focused changes.
- Inspect diffs and commit history.
- Safely restore, unstage, stash, and recover work.

### Branching and History

- Create, switch, merge, and delete branches.
- Explain fast-forward and three-way merges.
- Resolve merge conflicts.
- Use rebase appropriately on personal branches.
- Understand commit hashes, `HEAD`, refs, and reflog.

### GitHub Collaboration

- Authenticate securely with SSH or HTTPS/PAT.
- Push, fetch, pull, clone, and fork repositories.
- Configure `.gitignore`.
- Use GitHub Issues, Pull Requests, labels, milestones, and Projects.
- Review pull requests constructively.

### Automation and Production Workflows

- Add a GitHub Actions CI workflow.
- Interpret CI failures.
- Use branch protection and required checks.
- Create release tags and GitHub Releases.
- Understand basic dependency, secret, and workflow security.
- Recover from bad commits using revert and reflog.
- Participate in incident response and repository governance.

---

## 4. Core Teaching Principles

### 4.1 Teach the State Model Repeatedly

The most important concept is:

```text
Working Directory → Staging Area → Local Repository → GitHub
```

Return to it whenever learners are confused.

Ask:

```text
Where does the change exist right now?
```

Expected answers:

```text
Working directory only
Staged for the next commit
Committed locally
Pushed to GitHub
```

### 4.2 Use “Inspect Before Change” as a Habit

Before learners use a risky command, require:

```bash
git status
git diff
git diff --staged
```

Say often:

> Git is usually not confusing; the repository state is simply not visible yet.

### 4.3 Demonstrate Mistakes Safely

Learners remember recovery when they see mistakes happen in a controlled environment.

Good demonstrations:

- Forgetting to stage a file.
- Staging the wrong file.
- Switching branches with uncommitted work.
- Creating a merge conflict.
- Making a failing test.
- Recovering a deleted branch with reflog.
- Reverting a bad commit.

Avoid using production repositories or personal sensitive credentials.

### 4.4 Keep Features Small

Every exercise should use one focused change.

Examples:

```text
Add a release checklist.
Add release-note writing guidance.
Add formatter validation.
Add one test.
Add one workflow.
```

Avoid broad exercises such as:

```text
Build a complete application.
```

The series is about version control and collaboration, not application complexity.

---

# 5. Suggested Course Agenda

## Option A: Two-Day Intensive Workshop

### Day 1

| Session | Topic | Duration |
|---|---|---:|
| 1 | Introduction and local Git mental model | 60 min |
| 2 | Initialize repository, stage, commit, inspect history | 90 min |
| 3 | Safe undo and selective staging | 45 min |
| 4 | Branching, merging, and conflict resolution | 120 min |
| 5 | Rebase basics and branch cleanup | 45 min |

### Day 2

| Session | Topic | Duration |
|---|---|---:|
| 6 | GitHub remotes, authentication, push/fetch/pull | 90 min |
| 7 | `.gitignore`, clones, and forks | 45 min |
| 8 | Issues, pull requests, and review workflow | 90 min |
| 9 | JavaScript formatter, tests, and CI | 90 min |
| 10 | Recovery, releases, governance, and final assessment | 75 min |

---

## Option B: Five-Session Cohort

| Session | Focus |
|---|---|
| Session 1 | Part 0 and Part 1: Local Git foundations |
| Session 2 | Part 2: Branching, merging, conflicts, rebase |
| Session 3 | Part 3: GitHub remotes, authentication, synchronization |
| Session 4 | Part 4: Pull requests, issues, reviews, Projects |
| Session 5 | Part 5: Recovery, CI, releases, production practices |

---

# 6. Part-by-Part Delivery Guide

# Part 0: Introduction

## Trainer Objective

Set expectations and establish the final architecture.

## Key Message

> Git is not only a backup tool. It is a deliberate system for recording, reviewing, sharing, releasing, and recovering software changes.

## Demonstration

Draw or display:

```text
Working Directory
      ↓ git add
Staging Area
      ↓ git commit
Local Repository
      ↓ git push
GitHub
```

## Discussion Questions

- What problems have learners experienced with file copies?
- Have learners seen names such as `final-final-v3.zip`?
- What would learners want to know about an old change six months later?

## Completion Check

Ask learners to explain the difference between:

```text
Backup
```

and:

```text
Version control
```

---

# Part 1: Foundations of Local Version Control

## Trainer Objective

Make the working directory, staging area, and local repository model concrete.

## Key Commands

```bash
git init
git status
git add README.md
git commit -m "Add initial project documentation"
git diff
git diff --staged
git log --oneline
git restore README.md
git restore --staged README.md
```

## Demonstration Sequence

1. Create a folder.
2. Run `git init`.
3. Create `README.md`.
4. Run `git status`.
5. Stage only `README.md`.
6. Show `git diff --staged`.
7. Commit it.
8. Edit the file again.
9. Show the difference between `git diff` and `git diff --staged`.
10. Restore an accidental edit.

## Trainer Prompts

Ask:

```text
Is this file currently untracked, unstaged, staged, or committed?
```

Ask before every command:

```text
What do you expect git status to show after this command?
```

## Common Learner Problems

| Problem | Trainer Response |
|---|---|
| Learner commits nothing | Explain staging and rerun `git status`. |
| Learner stages too many files with `git add .` | Use `git restore --staged <file>` and explain selective staging. |
| Learner worries about `git restore` | Emphasize diff inspection first. |
| Identity error appears | Configure `user.name` and `user.email`. |

---

# Part 2: Branching and Merging

## Trainer Objective

Teach branches as pointers and normalize merge conflicts as a collaborative decision point.

## Key Commands

```bash
git switch -c feature/short-description
git switch main
git merge feature/short-description
git branch -d feature/short-description
git rebase main
git merge --abort
git rebase --abort
```

## Recommended Conflict Exercise

Use one file, such as `README.md`.

1. Create a feature branch.
2. Change one sentence on the feature branch.
3. Switch to `main`.
4. Change the same sentence differently.
5. Merge the feature branch.
6. Let Git create conflict markers.
7. Resolve together.

## Trainer Language

Say:

> A conflict means Git refuses to guess. That is a safety feature.

Avoid saying:

> Git broke.

## Completion Check

Learners should explain:

```text
Fast-forward merge
Three-way merge
Merge conflict
Rebase
```

---

# Part 3: Going Remote with GitHub

## Trainer Objective

Connect local repositories to GitHub safely and explain remote-tracking branches.

## Key Commands

```bash
git remote add origin <url>
git push -u origin main
git fetch origin
git pull --ff-only
git remote -v
git branch --all
git clone <url>
```

## Authentication Guidance

Encourage SSH for regular personal development:

```bash
ssh -T git@github.com
```

Use HTTPS/PAT when SSH is restricted.

Do not ask learners to share:

```text
Private keys
Tokens
Passwords
Recovery codes
```

## Demonstration: Fetch vs Pull

1. Make a small GitHub web edit.
2. Show that local Git does not know immediately.
3. Run:

   ```bash
   git fetch origin
   ```

4. Compare:

   ```bash
   git log --oneline main..origin/main
   ```

5. Integrate:

   ```bash
   git pull --ff-only
   ```

## Completion Check

Ask learners:

```text
What is the difference between main and origin/main?
```

Expected answer:

```text
main is the local branch.
origin/main is the local record of the remote branch's last known state.
```

---

# Part 4: Professional Collaboration and Code Review

## Trainer Objective

Move learners from individual Git usage to a team workflow.

## Key Concepts

```text
Issue
Feature branch
Pull request
Review
CI
Branch protection
Merge
```

## Suggested Group Exercise

Assign small teams:

| Role | Responsibility |
|---|---|
| Author | Creates branch and pull request |
| Reviewer | Reviews diff and leaves feedback |
| Maintainer | Checks CI and merge requirements |
| Observer | Records workflow decisions |

Rotate roles after one pull request.

## Review Rubric

Reviewers should inspect:

```text
[ ] Scope
[ ] Acceptance criteria
[ ] Tests
[ ] Documentation
[ ] Secrets
[ ] CI status
[ ] Error handling
```

## Trainer Prompt

Ask reviewers:

```text
What evidence shows this behavior is correct?
```

Do not accept:

```text
Looks good.
```

without supporting evidence.

---

# Part 5: Advanced Git and Automation

## Trainer Objective

Teach recovery and automation as confidence-building tools, not dangerous magic.

## Key Commands

```bash
git commit --amend
git rebase -i HEAD~3
git stash push
git reflog
git cherry-pick <commit>
git reset --soft HEAD~1
git reset --mixed HEAD~1
git revert <commit>
```

## Safe Teaching Order

1. Amend a local commit.
2. Squash local commits.
3. Stash unfinished work.
4. Recover a branch using reflog.
5. Cherry-pick one focused commit.
6. Explain reset modes.
7. Create CI.
8. Intentionally fail CI.
9. Restore CI.
10. Demonstrate revert.

## Critical Trainer Warning

Do not encourage learners to use:

```bash
git reset --hard
git push --force
```

without first explaining:

```text
Current branch
Current commit
Working tree status
Recovery branch or stash
Shared versus personal history
```

---

# 7. Lab Exercises

## Lab 1: Local Commit Workflow

**Goal:** Create a local repository and make focused commits.

Required outcomes:

```text
[ ] README.md committed.
[ ] RELEASE_NOTES.md committed.
[ ] At least one selective staging exercise completed.
[ ] One accidental edit restored safely.
```

---

## Lab 2: Branch and Merge

**Goal:** Create a feature branch and merge it.

Required outcomes:

```text
[ ] Feature branch created.
[ ] Feature commit created.
[ ] Fast-forward merge completed.
[ ] Merged branch deleted.
```

---

## Lab 3: Merge Conflict

**Goal:** Resolve a controlled conflict.

Required outcomes:

```text
[ ] Conflict markers observed.
[ ] Intended final text selected.
[ ] Markers removed.
[ ] Resolved file staged.
[ ] Tests run.
[ ] Merge completed.
```

---

## Lab 4: GitHub Remote Workflow

**Goal:** Publish a local repository and synchronize changes.

Required outcomes:

```text
[ ] GitHub repository created.
[ ] origin remote configured.
[ ] main pushed.
[ ] Web edit created.
[ ] git fetch used before pull.
[ ] git pull --ff-only completed.
```

---

## Lab 5: Pull Request Workflow

**Goal:** Deliver a feature through an issue and pull request.

Required outcomes:

```text
[ ] Issue created with acceptance criteria.
[ ] Feature branch named clearly.
[ ] Tests added or updated.
[ ] Pull request opened.
[ ] Review feedback provided.
[ ] CI passes.
[ ] Pull request merged.
```

---

## Lab 6: Recovery

**Goal:** Recover work safely.

Required outcomes:

```text
[ ] Stash created and restored.
[ ] Practice branch deleted.
[ ] Reflog inspected.
[ ] Recovery branch created from reflog commit.
[ ] Bad commit reverted or explained.
```

---

# 8. Assessment Rubric

## Beginner Competency

| Skill | Evidence |
|---|---|
| Can inspect Git state | Uses `git status` before changes |
| Can make commits | Uses `git add` and meaningful commit messages |
| Can inspect diffs | Uses `git diff` and `git diff --staged` |
| Can use branches | Creates and switches branches safely |
| Can use GitHub | Pushes, fetches, and pulls correctly |

## Intermediate Competency

| Skill | Evidence |
|---|---|
| Can resolve conflicts | Removes markers, stages resolution, tests result |
| Can use pull requests | Creates focused PRs with verification steps |
| Can review code | Gives actionable feedback |
| Can use CI | Reads workflow output and fixes test failures |
| Can recover work | Uses stash and reflog appropriately |

## Advanced Competency

| Skill | Evidence |
|---|---|
| Can manage history carefully | Uses amend and interactive rebase on private branches |
| Can manage releases | Creates annotated tags and GitHub Releases |
| Can secure workflows | Uses least privilege and protected environments |
| Can handle incidents | Uses revert, recovery branches, and documented response |
| Can govern repositories | Uses CODEOWNERS, branch rules, and access review routines |

---

# 9. Common Misconceptions to Correct

| Misconception | Correct explanation |
|---|---|
| “Git and GitHub are the same.” | Git is local version-control software; GitHub is a hosted collaboration platform. |
| “Commit saves everything automatically.” | Commit records only staged changes. |
| “A branch is a full copy of the project.” | A branch is a lightweight pointer to a commit. |
| “Merge conflicts mean Git failed.” | Git paused because a human decision is needed. |
| “git pull is always safe.” | Pull integrates remote work; inspect and use `--ff-only` when appropriate. |
| “.gitignore removes secrets from history.” | It only prevents future untracked files from being added. |
| “Private repositories can contain secrets safely.” | Secrets still require secure storage and rotation procedures. |
| “A green CI check proves everything is correct.” | It proves configured checks passed, not that all possible defects are absent. |
| “Force push fixes remote problems.” | It can overwrite shared history and requires caution. |
| “Rebase is always better than merge.” | The correct choice depends on team policy and whether history is shared. |

---

# 10. Trainer Demo Scripts

## Demo: Safe Inspection

```bash
git status
git diff
git diff --staged
git log --oneline --decorate --graph --all -10
```

Trainer message:

> These commands inspect. They do not change project history or delete files.

---

## Demo: Before a Commit

```bash
git status
git diff
git add README.md
git diff --staged
npm test
git commit -m "docs(readme): clarify setup steps"
```

Trainer message:

> A commit should never be a surprise package.

---

## Demo: Safe Feature Branch

```bash
git switch main
git pull --ff-only
git switch -c feature/add-export-example
```

Trainer message:

> Start from updated main, then isolate one work item.

---

## Demo: Pull Request Preparation

```bash
git diff main...HEAD
git log --oneline main..HEAD
npm test
git push -u origin feature/add-export-example
```

Trainer message:

> A pull request is a proposal with evidence: clear scope, tests, and documentation.

---

## Demo: Recovery

```bash
git reflog --date=local -20
git switch -c recovery/lost-work <commit-hash>
git show --stat HEAD
```

Trainer message:

> Reflog is a recovery map. Preserve work by creating a branch before experimenting further.

---

# 11. Suggested Trainer Debrief Questions

After each module, ask:

### Local Git

- What does `git status` tell you?
- What is the difference between staged and unstaged work?
- Why inspect `git diff --staged` before committing?

### Branching

- Why create a branch instead of editing `main`?
- When does Git create a merge conflict?
- When would you merge instead of rebase?

### GitHub

- What is the difference between `fetch` and `pull`?
- Why is `.gitignore` important?
- Why does a private repository still need secret safety?

### Collaboration

- What makes a good issue?
- What makes a pull request easy to review?
- What should a reviewer verify before approving?

### Recovery

- When should you use revert instead of reset?
- What can reflog recover?
- Why should secret rotation happen before history cleanup?

---

# 12. Final Trainer Checklist

Before declaring the training complete, verify that learners can:

```text
[ ] Explain the Git state model.
[ ] Create, inspect, and commit focused changes.
[ ] Create and merge branches.
[ ] Resolve a merge conflict.
[ ] Push to and pull from GitHub.
[ ] Use .gitignore and protect secrets.
[ ] Open and review a pull request.
[ ] Read GitHub Actions results.
[ ] Create a release tag.
[ ] Use stash and reflog.
[ ] Revert a bad shared commit.
[ ] Follow a safe end-of-session workflow.
```

---

# 13. Trainer Closing Message

Use this closing message:

> Git is not about memorizing commands. It is about understanding state, recording meaningful changes, collaborating safely, and recovering confidently.  
>
> When uncertain: inspect first.  
> When sharing: review first.  
> When releasing: verify first.  
> When recovering: preserve work first.
