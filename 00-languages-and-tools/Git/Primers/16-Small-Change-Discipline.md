# Primer 16: Branch Naming, Commit Scope, and Small-Change Discipline

Git makes it possible to put many unrelated changes into one branch or commit.

That does not mean you should.

Professional repository history is easier to review, test, revert, and maintain when changes are **small, focused, and clearly named**.

This primer explains how to keep work understandable from the moment you create a branch until the pull request merges.

You will learn:

- Why one branch should usually represent one work item.
- How to choose useful branch names.
- What makes a commit focused.
- How to avoid mixing unrelated changes.
- When to split work into separate commits or pull requests.
- How small changes improve review and recovery.

---

# P16.1 Understand Change Scope

## The Target

Understand what it means for a branch, commit, or pull request to have a focused scope.

## The Concept

**Scope** means the specific purpose and boundaries of a change.

A focused change solves one clear problem.

For example:

```text
Add formatter support for a Security section.
```

An unfocused change might combine:

```text
Add Security section
Fix a README typo
Upgrade Node.js
Rename unrelated files
Reformat all source files
Change CI permissions
```

All of those changes may be valid individually. Combining them makes the result difficult to review.

Think of a pull request like a package delivery:

```text
Focused package:
One clearly labeled item.

Unfocused package:
Several unrelated items mixed into one box.
```

If something goes wrong with the mixed package, it is harder to identify, approve, revert, or safely deliver only the needed item.

## The Implementation

Read these examples.

### Focused branch

```text
feature/add-security-release-section
```

Likely changes:

```text
src/releaseNotes.js
src/releaseNotes.test.js
README.md
RELEASE_NOTES.md
```

All files support one feature.

### Unfocused branch

```text
feature/misc-updates
```

Likely changes:

```text
src/releaseNotes.js
README.md
package.json
.github/workflows/ci.yml
.gitignore
```

The name does not explain the purpose, and the files may represent unrelated work.

## The Verification

Before beginning work, complete this sentence:

```text
This branch exists to ______________________________.
```

If you cannot describe the purpose in one sentence, split the work into multiple branches or issues.

---

# P16.2 Name Branches by Intent

## The Target

Create branch names that explain the work without requiring someone to inspect the diff.

## The Concept

A good branch name answers:

```text
What kind of work is this?
What does it change?
Which issue does it relate to, if applicable?
```

A useful format is:

```text
<category>/<issue-number>-<short-description>
```

Examples:

```text
feature/42-add-security-section
fix/57-reject-empty-version
docs/63-add-export-example
ci/71-run-tests-on-node-22
chore/75-update-ignore-rules
refactor/81-simplify-section-formatting
```

Use lowercase letters and hyphens.

Avoid spaces, vague names, and personal names:

```text
new-branch
fixes
updates
johns-work
test123
final-final
```

## The Implementation

Start from updated `main`:

```bash
git switch main
git pull --ff-only
```

Create a descriptive practice branch:

```bash
git switch -c feature/add-security-section
```

Confirm the name:

```bash
git branch --show-current
```

Return to `main` and delete the branch if it was only for practice:

```bash
git switch main
git branch -d feature/add-security-section
```

## The Verification

Expected branch output:

```text
feature/add-security-section
```

Confirm that the branch name communicates:

```text
Category:
feature

Purpose:
add security section
```

---

# P16.3 Keep Commits Focused

## The Target

Create commits that represent one meaningful step.

## The Concept

A focused commit should answer:

> “What changed, and why, if I read only this commit?”

Good examples:

```text
feat(formatter): add security release section
test(formatter): cover empty security entries
docs(readme): explain security release notes
```

Each commit has one purpose.

A less useful commit:

```text
update formatter and docs and workflow
```

This is hard to review because it combines code behavior, documentation, and CI configuration.

A focused commit is easier to:

- Review.
- Revert.
- Cherry-pick.
- Understand in history.
- Investigate with `git bisect`.
- Include in release notes.

## The Implementation

Before committing, inspect staged files:

```bash
git status
git diff --staged --stat
git diff --staged
```

Ask:

```text
Do all staged files belong to one meaningful change?
```

If yes, commit them:

```bash
git commit -m "feat(formatter): add security release section"
```

If no, unstage unrelated files:

```bash
git restore --staged <unrelated-file-path>
```

Then inspect again:

```bash
git diff --staged
```

## The Verification

A focused commit should have a clear summary.

For example:

```bash
git show --stat HEAD
```

Expected output might resemble:

```text
src/releaseNotes.js      | 15 +++++++++++++++
src/releaseNotes.test.js | 24 ++++++++++++++++++++++++
2 files changed, 39 insertions(+)
```

Those files logically belong together because tests verify the implementation change.

---

# P16.4 Separate Code, Tests, and Documentation Intentionally

## The Target

Understand when implementation, tests, and documentation should be in one commit or separate commits.

## The Concept

There is no single perfect answer. The decision depends on whether the files represent one inseparable change.

### Keep them together when they are inseparable

For example:

```text
Add formatter feature
    +
Add tests proving behavior
```

A feature without its tests is incomplete, so one commit can be reasonable:

```text
feat(formatter): add security release section
```

### Separate them when they are independently meaningful

For example:

```text
Commit 1:
feat(formatter): add security release section

Commit 2:
docs(readme): explain security release section
```

This can be useful when documentation is substantial or when the implementation must be reviewed independently.

The important rule is not “always one file per commit” or “always combine everything.”

The rule is:

> Group changes by logical purpose.

## The Implementation

Use this decision table before staging.

| Change type | Usually same commit? | Reason |
|---|---:|---|
| Feature implementation and direct regression tests | Yes | Tests prove the feature works. |
| README usage example for the feature | Often yes or next focused commit | Depends on documentation size and review preference. |
| Unrelated typo fix | No | It does not belong to the feature. |
| Dependency upgrade | No | It has separate risk and review needs. |
| CI permission change | No | It is security-sensitive and deserves focused review. |
| Broad formatting cleanup | No | It creates noisy diffs and obscures functional changes. |

## The Verification

Before committing, explain the grouping:

```text
These files belong together because __________________________.
```

If the explanation is unclear, split the staged files.

---

# P16.5 Avoid Drive-By Changes

## The Target

Avoid adding unrelated “while I am here” changes to a focused branch.

## The Concept

A **drive-by change** is a small unrelated edit made while working on something else.

For example:

```text
You are adding a formatter feature.
While editing README.md, you notice a typo.
You also update the typo.
```

The typo fix is valid, but it does not belong in the formatter feature pull request unless it is directly related.

Why separate it?

```text
Focused PR:
Reviewers can focus on formatter behavior.

Mixed PR:
Reviewers must decide whether documentation typo, feature logic,
tests, and other changes are all correct at once.
```

## The Implementation

When you notice unrelated work, create an issue or note it separately.

Use GitHub CLI if available:

```bash
gh issue create \
  --title "Fix typo in README installation section" \
  --body "The README contains a documentation typo discovered while reviewing the formatter workflow." \
  --label documentation
```

Or create an issue through the GitHub web interface.

Keep the current branch focused on its original task.

## The Verification

Before opening a pull request, inspect:

```bash
git diff main...HEAD
```

Ask:

```text
Does every changed line support this PR title?
```

If not, remove unrelated changes or move them to another branch.

---

# P16.6 Use Small Pull Requests

## The Target

Understand why smaller pull requests are easier and safer to review.

## The Concept

A pull request should be large enough to complete one meaningful piece of work, but small enough that a reviewer can understand it.

Small pull requests tend to have:

```text
Clearer purpose
Faster reviews
Fewer merge conflicts
More accurate feedback
Simpler rollback
Simpler release notes
```

Large pull requests tend to create:

```text
Reviewer fatigue
Missed edge cases
Long-lived branch drift
Harder merge conflicts
Unclear release impact
```

A rough guideline:

```text
If a reviewer cannot explain the PR’s goal after reading its title,
summary, and changed files, the PR may be too broad.
```

## The Implementation

Before opening a pull request, inspect its size:

```bash
git diff --stat main...HEAD
git log --oneline main..HEAD
```

Inspect changed file names:

```bash
git diff --name-status main...HEAD
```

Use the output to decide whether to split work.

For example:

```text
M  src/releaseNotes.js
M  src/releaseNotes.test.js
M  README.md
```

may be a healthy small feature.

But:

```text
M  src/releaseNotes.js
M  src/releaseNotes.test.js
M  README.md
M  package.json
M  package-lock.json
M  .github/workflows/ci.yml
M  SECURITY.md
M  GOVERNANCE.md
```

may indicate several separate concerns.

## The Verification

Before opening the pull request, complete:

```text
This pull request changes ________________________________
so that _________________________________________________.
```

If you need several unrelated “and” clauses, split the pull request.

---

# P16.7 Split Work Without Losing Progress

## The Target

Move unrelated changes into separate commits or branches safely.

## The Concept

Sometimes you discover too late that one branch contains multiple concerns.

You do not need to throw work away. You can separate it.

One common approach:

```text
1. Commit the first focused change.
2. Create another branch for the second change.
3. Move the relevant commit with cherry-pick.
4. Open separate pull requests.
```

Another approach is selective staging:

```text
Stage only files for the first change.
Commit.
Stage remaining files.
Commit separately.
```

## The Implementation

Suppose you changed:

```text
src/releaseNotes.js
src/releaseNotes.test.js
README.md
.github/workflows/ci.yml
```

You want:

```text
Commit 1:
feat(formatter): add security section

Commit 2:
docs(readme): document security section

Separate branch:
ci(actions): update workflow
```

Stage only feature files:

```bash
git add src/releaseNotes.js src/releaseNotes.test.js
git commit -m "feat(formatter): add security section"
```

Stage documentation separately:

```bash
git add README.md
git commit -m "docs(readme): document security section"
```

Leave the workflow change unstaged:

```bash
git status
```

Then either restore it or move it to a dedicated branch.

To preserve it temporarily:

```bash
git stash push -m "CI workflow change for separate branch"
```

Create a dedicated branch:

```bash
git switch main
git switch -c ci/update-workflow
git stash pop
```

## The Verification

Inspect branch-specific commits:

```bash
git log --oneline main..HEAD
```

Inspect the final diff:

```bash
git diff main...HEAD
```

Confirm that each branch now has one understandable purpose.

---

# P16.8 Understand Why Small Changes Improve Recovery

## The Target

Connect focused commits to safer rollback and debugging.

## The Concept

Small, focused commits improve recovery.

Suppose this commit is bad:

```text
feat(formatter): add security release section
```

A focused revert is straightforward:

```bash
git revert <commit-hash>
```

But if the same commit also changed CI permissions, upgraded dependencies, and rewrote the README, reverting it may remove unrelated useful work.

Focused commits also improve `git bisect`.

If each commit changes one behavior, the commit that introduces a bug is easier to identify and understand.

```text
Good history:
A → Add formatter
B → Add security section
C → Fix validation

Hard-to-debug history:
A → Huge update
B → More changes
C → Final fixes
```

## The Implementation

Inspect recent commit scope:

```bash
git log --oneline -10
git show --stat HEAD
```

Ask:

```text
Could I revert this commit without removing unrelated work?
```

## The Verification

A well-scoped commit should be easy to describe:

```text
This commit can be reverted if needed because it changes only
_____________________________________________.
```

---

# P16.9 Branch and Commit Discipline Checklist

## The Target

Use a repeatable checklist before committing and opening pull requests.

## The Concept

Small habits prevent large messy branches.

## The Implementation

### Before Creating a Branch

```text
[ ] Start from updated main.
[ ] Read the issue and acceptance criteria.
[ ] Describe the work in one sentence.
[ ] Choose a category and clear branch name.
```

### Before Each Commit

```text
[ ] Run git status.
[ ] Review git diff.
[ ] Stage only related files.
[ ] Review git diff --staged.
[ ] Run relevant tests.
[ ] Write a clear commit message.
```

### Before Opening a Pull Request

```text
[ ] Run git diff main...HEAD.
[ ] Review git log main..HEAD.
[ ] Confirm every changed file supports the PR purpose.
[ ] Remove unrelated changes.
[ ] Explain verification steps.
[ ] Link the related issue.
```

## The Verification

Run this final pre-PR sequence:

```bash
git status
git diff --stat main...HEAD
git diff main...HEAD
git log --oneline main..HEAD
npm test
```

Only open the pull request after you understand every result.

---

# Primer 16 Reference: Focused Change Commands

## Create a Focused Branch

```bash
git switch main
git pull --ff-only
git switch -c feature/short-description
```

## Inspect Unstaged Changes

```bash
git diff
```

## Stage Only Intended Files

```bash
git add src/releaseNotes.js src/releaseNotes.test.js
```

## Inspect the Next Commit

```bash
git diff --staged
```

## Compare a Branch with Main

```bash
git diff main...HEAD
```

## Show Branch-Only Commits

```bash
git log --oneline main..HEAD
```

## Unstage an Unrelated File

```bash
git restore --staged <file-path>
```

## Temporarily Save Unrelated Work

```bash
git stash push -m "Move this work to a separate branch"
```

---

# Primer 16 Completion Check

Before creating feature branches and pull requests, confirm that you can:

- [ ] Explain what focused scope means.
- [ ] Create branch names that describe category and purpose.
- [ ] Keep commits limited to one logical change.
- [ ] Decide when implementation, tests, and documentation belong together.
- [ ] Recognize and avoid drive-by changes.
- [ ] Use `git diff main...HEAD` to inspect a pull request’s real scope.
- [ ] Split unrelated changes using selective staging, separate commits, stashes, or branches.
- [ ] Explain why small pull requests are easier to review.
- [ ] Explain why focused commits are easier to revert and debug.
- [ ] Follow a pre-commit and pre-pull-request scope checklist.
