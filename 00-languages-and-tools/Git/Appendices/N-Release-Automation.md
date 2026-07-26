# Appendix N: Conventional Commits, Changelogs, and Release Automation

As a project grows, manually reading every commit to prepare release notes becomes slow and inconsistent.

A commit convention gives each commit a predictable structure:

```text
type(scope): short description
```

For example:

```text
feat(formatter): add security release section
fix(validation): reject impossible leap-day dates
docs(readme): explain formatter input shape
ci(actions): run tests on Node.js 20
```

This structure helps humans understand history quickly. It can also help tools automatically:

- Generate changelogs.
- Decide whether a release is a patch, minor, or major version.
- Build release notes.
- Create release tags.
- Publish packages or release artifacts.

This appendix introduces **Conventional Commits** and shows how to add a practical, dependency-free local validator for commit messages.

---

# N.1 Understand Conventional Commit Messages

## The Target

Learn the standard structure of a Conventional Commit message.

## The Concept

A Conventional Commit message is a small structured sentence.

Think of it as a package label:

```text
What kind of package is this?
Which area does it affect?
What changed?
```

The general format is:

```text
type(optional-scope): description
```

Examples:

```text
feat: add release note formatter
fix: reject invalid release dates
docs: add contributor setup instructions
test: cover empty release sections
ci: add GitHub Actions workflow
chore: update repository ignore rules
```

A scoped example:

```text
feat(formatter): add security section
```

Here:

| Part | Meaning |
|---|---|
| `feat` | The category of change |
| `(formatter)` | The affected area |
| `add security section` | The concise outcome |

The goal is not to make commits bureaucratic. The goal is to make history easier to understand and automate.

---

# N.2 Common Conventional Commit Types

## The Target

Choose a meaningful type for each commit.

## The Concept

The type should describe the nature of the change, not the file extension or the developer’s mood.

Use these common types:

| Type | Use when |
|---|---|
| `feat` | Adding a user-visible capability |
| `fix` | Correcting broken behavior |
| `docs` | Changing documentation only |
| `test` | Adding or changing tests only |
| `refactor` | Restructuring code without intended behavior changes |
| `perf` | Improving performance |
| `build` | Changing build tooling or dependencies |
| `ci` | Changing continuous integration or automation |
| `chore` | Maintenance that does not fit another type |
| `revert` | Reverting a prior commit |

Examples for this project:

```text
feat(formatter): add security release section
fix(validation): reject invalid calendar dates
docs(contributing): explain local hook installation
test(formatter): cover whitespace-only section entries
ci(actions): add Node.js version matrix
chore(git): configure LFS asset tracking
```

Avoid vague messages:

```text
update
fix stuff
changes
wip
final
```

---

# N.3 Describe Breaking Changes

## The Target

Mark commits that introduce a breaking change.

## The Concept

A breaking change requires users to alter existing code or workflow.

Conventional Commits can mark a breaking change with an exclamation point after the type or scope:

```text
feat!: change formatter input contract
```

Or:

```text
feat(formatter)!: rename releaseDate to date
```

You should also explain the break in the commit body or footer.

Example:

```text
feat(formatter)!: rename releaseDate to date

BREAKING CHANGE: formatReleaseNotes now expects the date property
instead of releaseDate.
```

This format helps release tools determine that the next release should be a major version:

```text
1.4.0 → 2.0.0
```

## The Implementation

No file changes are required in this step.

Use this decision guide before making a commit:

```text
Does existing user code continue to work unchanged?
    │
    ├── Yes → Use feat, fix, docs, or another appropriate type.
    │
    └── No → Mark the commit as breaking with ! and explain the migration.
```

## The Verification

Confirm you can classify these examples:

| Change | Suggested message |
|---|---|
| Add optional `security` array | `feat(formatter): add security section` |
| Correct invalid date handling | `fix(validation): reject impossible dates` |
| Rename required `releaseDate` property | `feat(formatter)!: rename releaseDate to date` |
| Add README explanation | `docs(readme): explain release date rules` |

---

# N.4 Add a Conventional Commit Message Hook

## The Target

Replace the basic commit-message hook with one that validates Conventional Commit format.

## The Concept

In Appendix I, you created a `commit-msg` hook that rejects empty or vague messages.

Now you will use a more specific rule.

The hook will accept messages such as:

```text
feat: add release note export
fix(formatter): reject empty versions
docs(readme): improve setup guidance
```

It will reject messages such as:

```text
update
Added a thing
fix stuff
```

The hook checks only the commit subject, which is the first line of the message. It allows bodies and footers below the first line.

## The Implementation

Replace the complete contents of the hook file.

### `release-notes-manager/.githooks/commit-msg`

```sh
#!/usr/bin/env sh

set -eu

COMMIT_MESSAGE_FILE="$1"

# Extract the first non-comment, non-empty line. Git may include comment lines
# when the user writes a commit message in an editor.
COMMIT_SUBJECT=$(
  grep -v '^[[:space:]]*#' "$COMMIT_MESSAGE_FILE" |
    sed '/^[[:space:]]*$/d' |
    head -n 1 |
    sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
)

if [ -z "$COMMIT_SUBJECT" ]; then
  echo "ERROR: Commit message cannot be empty."
  exit 1
fi

# Accepted examples:
#   feat: add formatter export
#   fix(validation): reject invalid dates
#   docs(readme)!: rename setup section
#
# Allowed types intentionally match the project workflow documented below.
CONVENTIONAL_COMMIT_PATTERN='^(feat|fix|docs|test|refactor|perf|build|ci|chore|revert)(\([a-z0-9._/-]+\))?!?: [a-z0-9][a-z0-9 .,_/:;()'"'"'`@+&-]*$'

if ! printf '%s\n' "$COMMIT_SUBJECT" | grep -E "$CONVENTIONAL_COMMIT_PATTERN" >/dev/null; then
  echo "ERROR: Commit subject does not follow Conventional Commit format."
  echo
  echo "Expected format:"
  echo "  type(optional-scope): short lowercase description"
  echo
  echo "Accepted types:"
  echo "  feat, fix, docs, test, refactor, perf, build, ci, chore, revert"
  echo
  echo "Examples:"
  echo "  feat: add release note formatter"
  echo "  fix(validation): reject invalid release dates"
  echo "  docs(readme): explain local setup"
  echo "  feat(formatter)!: rename releaseDate to date"
  exit 1
fi

SUBJECT_LENGTH=${#COMMIT_SUBJECT}

if [ "$SUBJECT_LENGTH" -gt 100 ]; then
  echo "ERROR: Commit subject must be 100 characters or fewer."
  echo "Keep the summary concise. Put additional context in the commit body."
  exit 1
fi

echo "Conventional Commit message check passed."
```

On macOS, Linux, or Git Bash, ensure the hook is executable:

```bash
chmod +x .githooks/commit-msg
```

Test a valid message.

### macOS, Linux, or Git Bash

```bash
printf "feat(formatter): add security section\n" > /tmp/commit-message.txt
.githooks/commit-msg /tmp/commit-message.txt
rm /tmp/commit-message.txt
```

### Windows PowerShell

```powershell
'feat(formatter): add security section' | Set-Content -Path "$env:TEMP\commit-message.txt"
bash .githooks/commit-msg "$env:TEMP\commit-message.txt"
Remove-Item "$env:TEMP\commit-message.txt"
```

Test an invalid message.

### macOS, Linux, or Git Bash

```bash
printf "update formatter\n" > /tmp/commit-message.txt
.githooks/commit-msg /tmp/commit-message.txt
rm /tmp/commit-message.txt
```

### Windows PowerShell

```powershell
'update formatter' | Set-Content -Path "$env:TEMP\commit-message.txt"
bash .githooks/commit-msg "$env:TEMP\commit-message.txt"
Remove-Item "$env:TEMP\commit-message.txt"
```

## The Verification

The valid test should print:

```text
Conventional Commit message check passed.
```

The invalid test should print:

```text
ERROR: Commit subject does not follow Conventional Commit format.
```

Before committing this hook change, ensure hooks are enabled:

```bash
git config --get core.hooksPath
```

Expected output:

```text
.githooks
```

Create a branch:

```bash
git switch main
git pull --ff-only
git switch -c ci/validate-conventional-commits
```

Commit the hook using the new required format:

```bash
git add .githooks/commit-msg
git commit -m "ci(hooks): validate conventional commits"
git push -u origin ci/validate-conventional-commits
```

Open a pull request and merge it through the normal review and CI process.

---

# N.5 Add Conventional Commit Documentation

## The Target

Document the commit convention in `CONTRIBUTING.md`.

## The Concept

A rule that exists only in a hook error message can feel arbitrary.

Contributor documentation should explain:

- Why the rule exists.
- Which types are available.
- How to write a normal commit.
- How to mark breaking changes.
- How to use a multi-line commit message.

## The Implementation

Add the following complete section to `CONTRIBUTING.md`.

### `release-notes-manager/CONTRIBUTING.md` — add this section

```md
## Commit Message Convention

This project uses Conventional Commit subjects:

```text
type(optional-scope): short lowercase description
```

Examples:

```text
feat(formatter): add security section
fix(validation): reject impossible dates
docs(readme): explain formatter usage
test(formatter): cover empty security entries
ci(actions): run tests on supported Node.js versions
```

Available types:

| Type | Use for |
|---|---|
| `feat` | New user-visible capability |
| `fix` | Bug fix |
| `docs` | Documentation-only changes |
| `test` | Test-only changes |
| `refactor` | Internal restructuring without intended behavior changes |
| `perf` | Performance improvements |
| `build` | Build tooling or dependency changes |
| `ci` | Continuous integration or automation |
| `chore` | General maintenance |
| `revert` | Reverting a previous change |

Mark breaking changes with `!`:

```text
feat(formatter)!: rename releaseDate to date
```

For a detailed commit message, use an editor:

```bash
git commit
```

Write the subject on the first line, leave the second line blank, then add explanatory body text below it.
```

Run tests:

```bash
npm test
```

Create a branch:

```bash
git switch main
git pull --ff-only
git switch -c docs/document-conventional-commits
```

Commit using the convention:

```bash
git add CONTRIBUTING.md
git commit -m "docs(contributing): document commit conventions"
git push -u origin docs/document-conventional-commits
```

## The Verification

Confirm the new documentation renders correctly on GitHub after merging.

Test the hook with a normal commit in a disposable branch if desired:

```bash
git switch -c practice/conventional-commit
```

Create a small temporary file:

### `release-notes-manager/CONVENTIONAL_COMMIT_PRACTICE.md`

```md
# Conventional Commit Practice

This file verifies that a valid Conventional Commit message is accepted.
```

Commit it:

```bash
git add CONVENTIONAL_COMMIT_PRACTICE.md
git commit -m "docs: add commit convention practice"
```

Then remove the disposable branch:

```bash
git switch main
git branch -D practice/conventional-commit
```

---

# N.6 Generate a Human-Friendly Changelog Manually

## The Target

Use Git history to prepare a changelog section from Conventional Commit messages.

## The Concept

A changelog is a user-facing summary of meaningful project changes.

It should not simply copy every commit. For example, these maintenance commits may not need to appear in public release notes:

```text
ci(actions): update cache configuration
chore(git): refresh ignore rules
```

But these likely should:

```text
feat(formatter): add security section
fix(validation): reject impossible dates
```

A basic release-note workflow is:

```text
Find commits since previous tag
    ↓
Group by type
    ↓
Rewrite technical commit subjects for users
    ↓
Add version and date
    ↓
Review against merged pull requests
```

## The Implementation

Inspect commits since the latest release tag:

```bash
git log --oneline v1.0.0..main
```

Filter feature commits:

### macOS, Linux, or Git Bash

```bash
git log --oneline v1.0.0..main --grep='^feat'
```

### Windows PowerShell

```powershell
git log --oneline v1.0.0..main | Select-String '^[a-f0-9]+ feat'
```

Filter fixes:

### macOS, Linux, or Git Bash

```bash
git log --oneline v1.0.0..main --grep='^fix'
```

### Windows PowerShell

```powershell
git log --oneline v1.0.0..main | Select-String '^[a-f0-9]+ fix'
```

Use the findings to prepare a release note entry in this pattern:

```md
## [1.1.0] - YYYY-MM-DD

### Added

- Add a Security section to formatted release notes.

### Fixed

- Reject impossible calendar dates before generating release notes.
```

## The Verification

Confirm that every public release-note bullet corresponds to a meaningful merged change.

Before publishing release notes, inspect the full compare range:

```bash
git log --oneline v1.0.0..main
git diff --stat v1.0.0..main
```

---

# N.7 Understand Automated Release Version Decisions

## The Target

Learn how Conventional Commit types can map to Semantic Versioning changes.

## The Concept

Release automation tools commonly use these rules:

| Commit pattern | Version impact |
|---|---|
| `fix:` | Patch release |
| `feat:` | Minor release |
| `feat!:` or `BREAKING CHANGE:` | Major release |
| `docs:`, `test:`, `ci:`, `chore:` | Often no release by themselves |

For example, if the latest release is:

```text
1.4.2
```

and new commits are:

```text
fix(validation): reject invalid dates
docs(readme): clarify input format
```

the next version is typically:

```text
1.4.3
```

If there is also:

```text
feat(formatter): add deprecated section
```

the next version is typically:

```text
1.5.0
```

If there is:

```text
feat(formatter)!: rename releaseDate to date
```

the next version is typically:

```text
2.0.0
```

## The Implementation

No repository change is required in this step.

Classify this commit set:

```text
docs(readme): explain release tags
fix(validation): reject impossible dates
feat(formatter): add security section
```

The correct next-version impact is:

```text
Minor release
```

because `feat` is present.

Classify this set:

```text
fix(formatter): trim release version
test(formatter): cover version trimming
```

The correct impact is:

```text
Patch release
```

## The Verification

Use this priority order:

```text
Breaking change → Major
Feature → Minor
Fix → Patch
No release-worthy change → No version increment
```

---

# N.8 Add a Release-Draft GitHub Actions Workflow

## The Target

Create a workflow that prepares release-note drafts when changes merge into `main`.

## The Concept

A release-draft workflow does not automatically publish a release. Instead, it helps maintainers prepare one.

This is a cautious automation layer:

```text
Merge pull request into main
    ↓
Workflow analyzes commits
    ↓
Draft release is updated
    ↓
Maintainer reviews notes and publishes intentionally
```

For production projects, tools such as Release Please, semantic-release, or Changesets can manage this workflow. Each has different assumptions and setup requirements.

For this beginner-friendly repository, you will add a minimal workflow that can be manually triggered and prints the commits since the latest tag. It does not require a third-party release tool or write permissions.

## The Implementation

Create this workflow file.

### `release-notes-manager/.github/workflows/release-preview.yml`

```yaml
name: Release Preview

on:
  workflow_dispatch:

permissions:
  contents: read

jobs:
  preview:
    name: Preview changes since latest tag
    runs-on: ubuntu-latest

    steps:
      - name: Check out full history
        uses: actions/checkout@v4
        with:
          # A full fetch is required because shallow history may not include tags.
          fetch-depth: 0

      - name: Find latest version tag and show changes
        shell: bash
        run: |
          set -euo pipefail

          latest_tag="$(git tag --list 'v*' --sort=-version:refname | head -n 1)"

          if [ -z "$latest_tag" ]; then
            echo "No v-prefixed release tag exists yet."
            echo "Showing all commits:"
            git log --oneline
            exit 0
          fi

          echo "Latest release tag: $latest_tag"
          echo
          echo "Commits since $latest_tag:"
          git log --oneline "${latest_tag}..HEAD"

          echo
          echo "Feature commits:"
          git log --oneline "${latest_tag}..HEAD" --grep='^feat' || true

          echo
          echo "Fix commits:"
          git log --oneline "${latest_tag}..HEAD" --grep='^fix' || true

          echo
          echo "Potential breaking changes:"
          git log --oneline "${latest_tag}..HEAD" --grep='!' || true
```

Create a feature branch:

```bash
git switch main
git pull --ff-only
git switch -c ci/add-release-preview-workflow
```

Run project tests:

```bash
npm test
```

Commit using the project convention:

```bash
git add .github/workflows/release-preview.yml
git commit -m "ci(actions): add release preview workflow"
git push -u origin ci/add-release-preview-workflow
```

Open a pull request and merge it through the usual CI and review process.

## The Verification

After merging, open GitHub:

1. Select the **Actions** tab.
2. Select **Release Preview**.
3. Select **Run workflow**.
4. Select the `main` branch.
5. Select **Run workflow**.

Open the workflow run and inspect the **Preview changes since latest tag** job.

Expected output includes either:

```text
Latest release tag: v1.0.0
Commits since v1.0.0:
```

or:

```text
No v-prefixed release tag exists yet.
```

The workflow does not modify repository history or create releases. It only produces a reviewable release preview.

---

# N.9 Add a Pull Request Title Convention

## The Target

Encourage pull request titles to follow the same structure as final squash-merge commit messages.

## The Concept

If your repository uses **Squash and merge**, the pull request title often becomes the final commit subject on `main`.

Using Conventional Commit format in PR titles keeps `main` history consistent.

Example pull request titles:

```text
feat(formatter): add security section
fix(validation): reject invalid dates
docs(contributing): explain commit conventions
ci(actions): add release preview workflow
```

GitHub does not enforce this automatically without additional configuration or an action. Start with documentation and review expectations before adding stricter automation.

## The Implementation

Add this section to the pull request template.

### `release-notes-manager/.github/pull_request_template.md` — add near the top

```md
## Pull Request Title

Use a Conventional Commit-style title because squash merges may use this title as the final commit message.

Examples:

```text
feat(formatter): add security section
fix(validation): reject invalid dates
docs(readme): clarify setup instructions
```
```

Commit through a branch:

```bash
git switch main
git pull --ff-only
git switch -c docs/document-pr-title-convention
git add .github/pull_request_template.md
git commit -m "docs(pr): document pull request title convention"
git push -u origin docs/document-pr-title-convention
```

## The Verification

Open a new pull request and confirm the template contains the title guidance.

Before merging a PR, check that the title:

- Uses a recognized type.
- Describes the final user or developer outcome.
- Is suitable as a permanent commit message on `main`.

---

# N.10 Conventional Commit Troubleshooting

## Problem: A Commit Is Rejected by the Hook

### Example Error

```text
ERROR: Commit subject does not follow Conventional Commit format.
```

### Inspect

Check the first line of the proposed message.

Invalid:

```text
Add a release formatter
```

Valid:

```text
feat(formatter): add release formatter
```

### Fix

Use this structure:

```text
type(optional-scope): lowercase outcome
```

Then retry:

```bash
git commit -m "feat(formatter): add release formatter"
```

---

## Problem: The Hook Rejects a Valid-Looking Scope

### Cause

The hook permits lowercase scope values containing:

```text
a-z
0-9
.
_
/
-
```

Invalid scope:

```text
feat(Release Formatter): add security section
```

Valid scope:

```text
feat(release-formatter): add security section
```

### Fix

Use lowercase, hyphenated scope names:

```bash
git commit -m "feat(release-formatter): add security section"
```

---

## Problem: You Need a Capitalized Product Name

### Cause

The example hook intentionally requires a lowercase description for consistency.

### Fix

Write a lowercased action-oriented summary:

```text
docs(readme): explain github actions workflow
```

Use the commit body for proper product-name capitalization if needed:

```bash
git commit
```

Then write:

```text
docs(readme): explain github actions workflow

Document how GitHub Actions runs continuous integration checks for pull requests.
```

---

## Problem: You Need to Reword the Latest Commit

### Implementation

If the commit is local and unshared:

```bash
git commit --amend -m "fix(validation): reject impossible dates"
```

If it was already pushed to your personal feature branch:

```bash
git push --force-with-lease
```

Do not rewrite shared or merged history casually.

---

# N.11 Conventional Commit Reference

## Standard Message Shapes

```text
feat: add release export
fix: reject invalid release dates
docs: explain repository setup
test: cover empty release sections
refactor: simplify section normalization
perf: reduce repeated date parsing
build: update package metadata
ci: add release preview workflow
chore: refresh ignore rules
revert: remove unsupported export command
```

## Scoped Message Shapes

```text
feat(formatter): add security section
fix(validation): reject invalid dates
docs(readme): explain formatter API
test(formatter): cover missing sections
ci(actions): run release preview
chore(git): configure LFS tracking
```

## Breaking Change Shape

```text
feat(formatter)!: rename releaseDate to date
```

Optional body/footer:

```text
BREAKING CHANGE: formatReleaseNotes now expects date instead of releaseDate.
```

## Release Impact

| Commit type | Typical SemVer impact |
|---|---|
| `fix` | Patch |
| `feat` | Minor |
| `!` or `BREAKING CHANGE` | Major |
| `docs`, `test`, `ci`, `chore` | Usually no release alone |

---

# Appendix N Completion Check

You should now be able to:

- [ ] Write Conventional Commit messages using `type(scope): description`.
- [ ] Select appropriate commit types.
- [ ] Mark breaking changes with `!` and a migration explanation.
- [ ] Configure a local hook to validate Conventional Commit subjects.
- [ ] Document commit conventions for contributors.
- [ ] Prepare release notes by filtering commits since a Git tag.
- [ ] Explain how commit types can drive Semantic Versioning decisions.
- [ ] Run a GitHub Actions release-preview workflow.
- [ ] Use PR titles that remain meaningful after squash merging.
