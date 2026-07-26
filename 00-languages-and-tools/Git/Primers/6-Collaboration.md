# Primer 6: Collaboration Vocabulary, Issues, Pull Requests, and Reviews

Git lets you track and combine changes. GitHub adds a shared workspace where people can plan, discuss, review, and approve those changes.

Before using team workflows, it helps to understand the vocabulary.

A professional software workflow is not:

```text
Edit main directly
    ↓
Push whenever finished
```

It is usually:

```text
Identify work
    ↓
Create an issue
    ↓
Create a branch
    ↓
Make and test changes
    ↓
Open a pull request
    ↓
Review and improve
    ↓
Merge into main
```

This primer explains the ideas behind that flow before you use them in Part 4.

---

# P6.1 Understand the Main Collaboration Objects

## The Target

Learn the difference between an issue, branch, pull request, review, label, milestone, and project.

## The Concept

A software team uses several related tools to organize work.

| Tool | Purpose | Everyday analogy |
|---|---|---|
| Issue | Records a problem, idea, task, or question | A work ticket |
| Branch | Isolated line of code changes | A private draft |
| Pull Request | Proposal to merge one branch into another | A submitted draft for review |
| Review | Feedback or approval on a pull request | Editorial feedback |
| Label | Categorizes work | A colored filing tab |
| Milestone | Groups work toward a release or deadline | A project checkpoint |
| Project | Visualizes work status | A shared task board |

These tools connect together:

```text
Issue #12
    │
    ├── Branch: feature/12-add-export
    │
    └── Pull Request: Add release export
             │
             ├── Review comments
             ├── CI checks
             └── Merge into main
```

## The Implementation

No repository change is required.

Open your GitHub repository and identify these tabs:

```text
Code
Issues
Pull requests
Actions
Projects
Security
Insights
Settings
```

## The Verification

Confirm that you can explain:

```text
Issue:
Why work is needed.

Branch:
Where focused work happens.

Pull request:
Where proposed work is reviewed before merge.
```

---

# P6.2 Understand the Stable `main` Branch

## The Target

Understand why teams protect `main`.

## The Concept

The `main` branch is normally the project’s stable shared line of development.

Think of `main` as the published edition of a book. You do not write rough notes directly into the published edition. You create a draft elsewhere, review it, then include it when it is ready.

A healthy branch model looks like this:

```text
main
  │
  ├── feature/add-release-export
  │       ├── Add export function
  │       ├── Add tests
  │       └── Update README
  │
  └── Merge reviewed pull request
          │
          ▼
        main
```

Teams often protect `main` with rules such as:

```text
[ ] Pull requests required before merge.
[ ] At least one approval required.
[ ] CI tests must pass.
[ ] Conversations must be resolved.
[ ] Force pushes blocked.
```

## The Implementation

Inspect your current local branch:

```bash
git branch --show-current
```

Inspect the remote default branch:

```bash
git remote show origin
```

If your repository has a remote, look for:

```text
HEAD branch: main
```

## The Verification

Your normal stable branch should be:

```text
main
```

Before starting work, verify it is clean and current:

```bash
git switch main
git pull --ff-only
git status
```

Expected output resembles:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

---

# P6.3 Write a Useful Issue

## The Target

Create an issue that explains a problem and defines what “done” means.

## The Concept

An issue should not merely say:

```text
Add export feature.
```

That leaves too many unanswered questions:

```text
Export what?
In which format?
Who needs it?
What errors should happen?
How do we know it is complete?
```

A useful issue is like a clear work order. It explains the problem, desired outcome, and acceptance criteria.

## The Implementation

Use this issue structure for a real task.

```md
## Summary

Describe the problem or desired outcome in one or two sentences.

## Why

Explain why this work matters to users, maintainers, or the project.

## Acceptance Criteria

- [ ] Describe one observable required behavior.
- [ ] Describe another required behavior.
- [ ] Include expected validation or error behavior.
- [ ] Include test expectations.
- [ ] Include documentation expectations when relevant.

## Example

Show example input, output, workflow, or user behavior.

## Additional Context

Add links, screenshots, constraints, or related issues.
```

Example issue:

```md
## Summary

Add an example showing how formatted release-note Markdown can be saved to a file.

## Why

Contributors can generate release-note Markdown, but they need a clear example of how to save it for review before publishing.

## Acceptance Criteria

- [ ] Add a Node.js example that writes generated Markdown to a file.
- [ ] Explain that generated output must be reviewed before publication.
- [ ] Keep the example compatible with supported Node.js versions.
- [ ] Update README documentation.
- [ ] Run `npm test`.

## Example

A contributor should be able to run an example command and inspect a generated `release-notes.md` file.

## Additional Context

This is documentation-focused work and should not change formatter behavior.
```

## The Verification

Before creating an issue, check:

```text
[ ] Is the problem clear?
[ ] Does the issue explain why the work matters?
[ ] Are acceptance criteria observable and testable?
[ ] Does it avoid secrets or sensitive data?
[ ] Did I search for an existing issue first?
```

---

# P6.4 Turn an Issue into a Branch Name

## The Target

Create descriptive branch names that connect implementation work to an issue.

## The Concept

A branch name should make the purpose visible without opening the branch.

This is useful:

```text
docs/12-add-export-example
```

This is unclear:

```text
new-work
```

A useful branch-name pattern is:

```text
<category>/<issue-number>-<short-description>
```

Examples:

```text
feature/18-add-markdown-export
fix/22-reject-empty-version
docs/12-add-export-example
ci/30-add-node-version-matrix
chore/31-update-ignore-rules
```

## The Implementation

Start from updated `main`:

```bash
git switch main
git pull --ff-only
```

Create a branch for issue `#12`:

```bash
git switch -c docs/12-add-export-example
```

Confirm it:

```bash
git branch --show-current
```

## The Verification

Expected output:

```text
docs/12-add-export-example
```

Confirm the new branch has no unique commits yet:

```bash
git log --oneline main..HEAD
```

Expected output: no output.

---

# P6.5 Understand a Pull Request

## The Target

Understand what a pull request proposes and what reviewers inspect.

## The Concept

A pull request, often called a **PR**, is a request to merge work from one branch into another.

For example:

```text
Source branch:
docs/12-add-export-example

Target branch:
main
```

The pull request says:

> “Please review the changes on this branch and merge them into `main` if they are correct.”

A pull request contains:

```text
Title
Description
Linked issues
Commits
Changed files
Review comments
Approvals
CI checks
Merge controls
```

The PR is not simply a merge button. It is the project’s review record.

## The Implementation

Use this pull request description structure:

```md
## Summary

Explain the user-visible or developer-visible outcome.

Closes #ISSUE_NUMBER

## Changes

- Describe the important implementation or documentation change.
- Describe relevant tests.
- Describe relevant documentation updates.

## Verification

```bash
npm test
```

Describe any manual verification steps.

## Review Focus

Tell reviewers where extra attention would be useful.
```

Example:

```md
## Summary

Documents how contributors can save generated release-note Markdown to a file.

Closes #12

## Changes

- Add a Node.js file-output example to the README.
- Explain that generated release notes require review before publication.

## Verification

```bash
npm test
```

Reviewed the example command in Node.js 20.

## Review Focus

Please verify that the example does not imply that generated content can bypass human release review.
```

## The Verification

Before opening a pull request, run:

```bash
git status
git diff main...HEAD
git log --oneline main..HEAD
npm test
```

Confirm:

```text
[ ] The branch has one focused purpose.
[ ] The diff contains only intended changes.
[ ] Tests pass.
[ ] The PR description explains why and how the change was verified.
```

---

# P6.6 Understand Pull Request Review States

## The Target

Recognize the most common review outcomes.

## The Concept

A reviewer can usually submit one of three outcomes:

| Review state | Meaning |
|---|---|
| Comment | Feedback without approval or merge block |
| Approve | The reviewer believes the PR is ready to merge |
| Request changes | The reviewer identified a blocking concern |

A review comment should focus on code and behavior—not the person who wrote it.

Helpful:

```text
blocking: This path accepts an empty version string. Please validate the value and add a test for whitespace-only input.
```

Unhelpful:

```text
This is wrong.
```

Useful review prefixes:

| Prefix | Meaning |
|---|---|
| `blocking:` | Must be addressed before merge |
| `question:` | Clarification needed |
| `suggestion:` | Optional improvement |
| `nit:` | Small non-blocking detail |
| `praise:` | Positive feedback worth preserving |

## The Implementation

Use this review checklist:

```text
Purpose
[ ] Does the PR solve the linked issue?

Correctness
[ ] Does the behavior match the acceptance criteria?
[ ] Are important edge cases handled?

Tests
[ ] Do tests pass?
[ ] Does new behavior have test coverage?

Security
[ ] Are there secrets, unsafe permissions, or unsafe shell behavior?

Scope
[ ] Are unrelated changes excluded?

Documentation
[ ] Do README and user-facing instructions match behavior?
```

## The Verification

Before submitting review feedback, confirm each comment:

```text
[ ] Identifies a specific concern or positive observation.
[ ] Explains why it matters.
[ ] Clearly indicates whether it blocks merge.
[ ] Uses respectful, actionable language.
```

---

# P6.7 Understand CI Checks in Pull Requests

## The Target

Understand why a passing pull request check matters before merging.

## The Concept

A pull request can look correct in a code review but still fail when automated checks run.

For example:

```text
Code looks correct
    ↓
CI runs npm test
    ↓
Test fails on a clean machine
    ↓
Merge is blocked
```

A CI check is an independent verification step.

For this project, the important command is:

```bash
npm test
```

GitHub Actions runs that command in a fresh environment.

A green check means:

```text
The workflow completed successfully for this commit.
```

It does not mean the change is perfect. It means the configured automated checks passed.

## The Implementation

Run tests locally before pushing:

```bash
npm test
```

Inspect workflow status on GitHub with GitHub CLI:

```bash
gh run list
```

Watch the newest workflow run:

```bash
gh run watch
```

## The Verification

A successful workflow should show a conclusion such as:

```text
success
```

If it fails, inspect logs:

```bash
gh run view RUN_ID --log-failed
```

Then reproduce the failure locally when possible:

```bash
npm test
```

---

# P6.8 Understand Merge Strategies

## The Target

Recognize the main ways GitHub can merge a pull request.

## The Concept

GitHub usually offers one or more merge strategies.

| Strategy | What happens to commit history |
|---|---|
| Merge commit | Preserves branch commits and adds a merge commit |
| Squash and merge | Combines PR commits into one new commit on `main` |
| Rebase and merge | Replays PR commits on top of `main` without a merge commit |

Example feature branch history:

```text
main:    A
feature: A → B → C → D
```

### Merge Commit

```text
A → B → C → D
 \          /
  └─── M ──
```

### Squash and Merge

```text
A → S
```

Where `S` contains the combined changes from `B`, `C`, and `D`.

### Rebase and Merge

```text
A → B' → C' → D'
```

The commits become new versions with new hashes.

For small, focused PRs, squash merging often keeps `main` history easy to read.

## The Implementation

No merge is required in this primer.

Inspect repository history:

```bash
git log --oneline --decorate --graph --all -15
```

Inspect merge commits:

```bash
git log --merges --oneline
```

## The Verification

Confirm you can explain:

```text
Squash merge:
Useful when a PR has several work-in-progress commits but main should contain one clean summary commit.

Merge commit:
Useful when preserving explicit branch integration history matters.

Rebase and merge:
Useful when a team wants linear history and understands rewritten commit hashes.
```

---

# P6.9 Understand Labels, Milestones, and Projects

## The Target

Learn how GitHub organizes work beyond individual issues and pull requests.

## The Concept

Issues and pull requests can become difficult to manage when a project grows.

GitHub provides organization tools.

### Labels

Labels categorize work:

```text
bug
enhancement
documentation
priority: high
needs triage
blocked
```

### Milestones

Milestones group work toward an outcome:

```text
v1.1.0 — Export workflow
```

### Projects

Projects visualize work status:

```text
Backlog → Ready → In Progress → In Review → Done
```

Think of the relationship:

```text
Label:
What kind of work is this?

Milestone:
Which release or delivery goal does it belong to?

Project:
Where is it in the workflow right now?
```

## The Implementation

For a real project, create these labels:

```text
bug
enhancement
documentation
priority: high
priority: medium
priority: low
needs triage
blocked
```

Create a milestone:

```text
v1.1.0 — Release note export
```

Create a Project board with columns:

```text
Backlog
Ready
In Progress
In Review
Done
```

## The Verification

Confirm each work item can answer:

```text
What is it?
    → Labels

When should it be delivered?
    → Milestone

What is its current state?
    → Project board
```

---

# P6.10 Collaboration Safety Rules

## The Target

Adopt habits that prevent common collaboration problems.

## The Concept

Collaboration is smoother when teams follow a few predictable rules.

## The Implementation

Use this checklist:

```text
Before work
[ ] Start from updated main.
[ ] Read the linked issue and acceptance criteria.
[ ] Create a focused branch.

During work
[ ] Commit focused changes.
[ ] Run tests.
[ ] Avoid unrelated refactoring.
[ ] Do not commit secrets.

Before pull request
[ ] Review git diff main...HEAD.
[ ] Run tests locally.
[ ] Write a clear PR description.
[ ] Link the issue.

Before merge
[ ] Required checks pass.
[ ] Required approvals exist.
[ ] Conversations are resolved.
[ ] The branch is current with main if required.
[ ] Final diff contains only intended work.

After merge
[ ] Update local main.
[ ] Delete the completed branch.
[ ] Confirm the linked issue closes.
[ ] Move the work item to Done.
```

## The Verification

Use this command sequence after a pull request merges:

```bash
git switch main
git pull --ff-only
git fetch --prune
git branch -d feature/short-description
git status
```

Expected final output:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

---

# Primer 6 Reference: Collaboration Flow

```text
1. Create or select an issue.
2. Update local main.
3. Create a focused branch.
4. Make changes.
5. Run tests.
6. Commit focused work.
7. Push the branch.
8. Open a pull request.
9. Review, discuss, and update.
10. Confirm CI passes.
11. Merge through protected rules.
12. Delete the branch and update local main.
```

---

# Primer 6 Completion Check

Before beginning professional collaboration workflows, confirm that you can:

- [ ] Explain the difference between an issue, branch, pull request, and review.
- [ ] Explain why `main` should remain stable and protected.
- [ ] Write an issue with clear acceptance criteria.
- [ ] Name a branch using a category, issue number, and short description.
- [ ] Write a pull request description with summary and verification steps.
- [ ] Distinguish review comments, approvals, and requested changes.
- [ ] Explain why CI checks are required before merge.
- [ ] Describe merge commit, squash merge, and rebase-and-merge strategies.
- [ ] Explain the role of labels, milestones, and Projects.
- [ ] Follow the basic issue-to-branch-to-PR-to-merge workflow.
