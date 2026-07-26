# Appendix S: GitHub CLI (`gh`) — Terminal-Based Pull Requests, Issues, Releases, and Actions

The **GitHub CLI**, invoked with the `gh` command, lets you work with GitHub from the terminal.

Git handles local repository history:

```bash
git status
git commit
git push
```

GitHub CLI handles GitHub platform features:

```bash
gh pr create
gh issue create
gh run list
gh release create
```

Think of the relationship this way:

```text
Git
├── Tracks files and commits
├── Creates branches
├── Merges local history
└── Pushes and fetches repository data

GitHub CLI
├── Opens pull requests
├── Creates issues
├── Reads CI workflow runs
├── Creates releases
└── Manages GitHub-hosted collaboration features
```

The GitHub web interface remains useful, especially for visual review. The CLI is useful when you want a fast, scriptable, keyboard-focused workflow.

---

# S.1 Install GitHub CLI

## The Target

Install the `gh` command and verify that it runs.

## The Concept

GitHub CLI is separate from Git.

Installing Git does not automatically install:

```bash
gh
```

The CLI communicates with GitHub’s API and uses an authenticated GitHub account.

## The Implementation

First, check whether GitHub CLI is already installed:

```bash
gh --version
```

If it is not installed, use the appropriate installation method.

### macOS with Homebrew

```bash
brew install gh
```

### Windows with winget

```powershell
winget install --id GitHub.cli
```

### Windows with Chocolatey

```powershell
choco install gh
```

### Ubuntu or Debian Linux

```bash
sudo apt update
sudo apt install gh
```

For other operating systems, use GitHub’s official installation documentation:

```text
https://cli.github.com/
```

## The Verification

Run:

```bash
gh --version
```

Expected output resembles:

```text
gh version 2.x.x
https://github.com/cli/cli/releases/tag/v2.x.x
```

The exact version will vary.

---

# S.2 Authenticate GitHub CLI Securely

## The Target

Authenticate the CLI with your GitHub account.

## The Concept

The CLI needs authorization to create issues, open pull requests, inspect private repositories, and manage releases.

`gh auth login` guides you through secure authentication.

For most developers, choose:

```text
GitHub.com
HTTPS
Login with a web browser
```

This does not require you to manually paste a token into a command.

If you already configured Git authentication with SSH, you can still use SSH for Git remotes while GitHub CLI uses its own API authentication.

## The Implementation

Run:

```bash
gh auth login
```

Choose options similar to:

```text
What account do you want to log into? GitHub.com
What is your preferred protocol for Git operations? SSH
Authenticate Git with your GitHub credentials? Yes
How would you like to authenticate GitHub CLI? Login with a web browser
```

Follow the displayed browser code flow.

After authentication, inspect the active account:

```bash
gh auth status
```

## The Verification

Expected output resembles:

```text
github.com
  ✓ Logged in to github.com account YOUR_GITHUB_USERNAME
  - Active account: true
  - Git operations protocol: ssh
  - Token: ghp_********
  - Token scopes: 'gist', 'read:org', 'repo', 'workflow'
```

Do not share the displayed token information, screenshots of authentication output, or browser authorization codes.

---

# S.3 Inspect the Current Repository with `gh repo view`

## The Target

Confirm that the current local folder is connected to the expected GitHub repository.

## The Concept

Before creating GitHub resources from the terminal, confirm that you are in the intended repository.

This is especially important if you work with multiple projects, personal forks, work repositories, or clones.

## The Implementation

Move to the repository root:

```bash
cd ~/projects/release-notes-manager
```

On Windows PowerShell:

```powershell
Set-Location "$HOME\projects\release-notes-manager"
```

Inspect Git remotes:

```bash
git remote -v
```

Inspect the GitHub repository through `gh`:

```bash
gh repo view
```

To view the repository in a browser:

```bash
gh repo view --web
```

To print selected metadata as JSON:

```bash
gh repo view --json name,owner,url,visibility,defaultBranchRef
```

## The Verification

Expected output resembles:

```text
YOUR_GITHUB_USERNAME/release-notes-manager
A hands-on project for learning Git and GitHub workflows.
```

The JSON command should identify:

- Repository name.
- Owner.
- URL.
- Visibility.
- Default branch.

Confirm the URL matches the `origin` remote shown by:

```bash
git remote -v
```

---

# S.4 Create an Issue from the Terminal

## The Target

Create a well-structured GitHub Issue without leaving the terminal.

## The Concept

An issue is a work record, not merely a reminder.

Creating issues from the terminal is useful when you discover work while coding, testing, reviewing a diff, or investigating CI output.

The command structure is:

```bash
gh issue create --title "..." --body "..."
```

For longer issue descriptions, use a Markdown file instead of placing large text directly into shell arguments.

That approach avoids quoting mistakes and keeps the issue body easy to review before submission.

## The Implementation

Create a temporary issue-body file.

### `release-notes-manager/.github/issue-body-export-example.md`

```md
## Summary

Add a documented example showing how formatted Markdown can be saved to a release-note file.

## Why

Contributors can generate Markdown today, but the README does not demonstrate how to write the output to a file for review or publishing.

## Acceptance Criteria

- [ ] Add a README example using Node.js file output.
- [ ] Keep the example compatible with Node.js 18 or newer.
- [ ] Explain that generated release notes should be reviewed before publishing.
- [ ] Add tests if application behavior changes.

## Labels

Suggested labels:

- documentation
- enhancement
- priority: low
```

Review the body:

```bash
cat .github/issue-body-export-example.md
```

On Windows PowerShell:

```powershell
Get-Content .github\issue-body-export-example.md
```

Create the issue:

```bash
gh issue create \
  --title "Document release note file export example" \
  --body-file .github/issue-body-export-example.md \
  --label documentation \
  --label enhancement \
  --label "priority: low"
```

On Windows PowerShell:

```powershell
gh issue create `
  --title "Document release note file export example" `
  --body-file ".github\issue-body-export-example.md" `
  --label documentation `
  --label enhancement `
  --label "priority: low"
```

After GitHub creates the issue, remove the temporary body file because it is only an authoring aid:

### macOS, Linux, or Git Bash

```bash
rm .github/issue-body-export-example.md
```

### Windows PowerShell

```powershell
Remove-Item .github\issue-body-export-example.md
```

## The Verification

The command prints a GitHub Issue URL resembling:

```text
https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager/issues/12
```

List open issues:

```bash
gh issue list
```

View the created issue:

```bash
gh issue view ISSUE_NUMBER
```

Replace `ISSUE_NUMBER` with the number GitHub assigned.

---

# S.5 Create a Feature Branch for an Issue

## The Target

Create a branch whose name makes its issue relationship clear.

## The Concept

A branch name should identify both the type of work and its purpose.

When an issue number exists, including it can make the relationship visible in terminal output, pull requests, and branch lists.

For example:

```text
docs/12-add-export-example
```

This means:

```text
docs  → documentation work
12    → GitHub Issue #12
add-export-example → short description
```

## The Implementation

Update local `main`:

```bash
git switch main
git pull --ff-only
```

Create the branch:

```bash
git switch -c docs/ISSUE_NUMBER-add-export-example
```

For example, if GitHub assigned issue `#12`:

```bash
git switch -c docs/12-add-export-example
```

Confirm the active branch:

```bash
git branch --show-current
```

## The Verification

Expected output resembles:

```text
docs/12-add-export-example
```

Confirm the branch began from current `main`:

```bash
git log --oneline main..HEAD
```

Expected output: no output, because the branch has no unique commits yet.

---

# S.6 Open a Pull Request from the Terminal

## The Target

Push a branch and create a pull request using `gh pr create`.

## The Concept

A pull request connects a branch to a proposed merge target.

The CLI can infer much of the context from your repository and current branch, but you should still explicitly review:

- The base branch.
- The branch being proposed.
- The title.
- The issue link.
- The verification steps.

The safest flow remains:

```text
Edit files
    ↓
Run tests
    ↓
Review Git diff
    ↓
Commit
    ↓
Push
    ↓
Create pull request
```

## The Implementation

For this appendix, do not invent a fake implementation merely to create a pull request. Use this command pattern for a real completed branch.

First, review your branch:

```bash
git status
git diff main...HEAD
npm test
git log --oneline main..HEAD
```

Push the branch:

```bash
git push -u origin docs/ISSUE_NUMBER-add-export-example
```

Create the pull request:

```bash
gh pr create \
  --base main \
  --head docs/ISSUE_NUMBER-add-export-example \
  --title "docs(readme): add release note export example" \
  --body "$(cat <<'EOF'
## Summary

Documents how to save generated release-note Markdown to a file.

Closes #ISSUE_NUMBER

## Changes

- Add a file-export example to the README.
- Explain that generated release notes require human review before publication.

## Verification

```bash
npm test
```

## Review Focus

Please verify that the example is compatible with supported Node.js versions and that it does not imply generated notes can be published without review.
EOF
)"
```

Replace every `ISSUE_NUMBER` occurrence with the actual issue number.

If multiline shell quoting is inconvenient, create a body file instead:

### `release-notes-manager/.github/pr-body.md`

```md
## Summary

Documents how to save generated release-note Markdown to a file.

Closes #ISSUE_NUMBER

## Changes

- Add a file-export example to the README.
- Explain that generated release notes require human review before publication.

## Verification

```bash
npm test
```

## Review Focus

Please verify that the example is compatible with supported Node.js versions and that it does not imply generated notes can be published without review.
```

Then run:

```bash
gh pr create \
  --base main \
  --head docs/ISSUE_NUMBER-add-export-example \
  --title "docs(readme): add release note export example" \
  --body-file .github/pr-body.md
```

Remove the temporary body file afterward if it is not meant to be committed:

```bash
rm .github/pr-body.md
```

## The Verification

GitHub CLI prints the pull request URL.

List open pull requests:

```bash
gh pr list
```

View the pull request:

```bash
gh pr view --web
```

Inspect changed files from the terminal:

```bash
gh pr diff
```

---

# S.7 Review Pull Requests from the Terminal

## The Target

Inspect, comment on, and approve pull requests through GitHub CLI.

## The Concept

Terminal-based review is useful when:

- You prefer local editor and terminal tools.
- You need to inspect a pull request while debugging locally.
- You want to check CI status quickly.
- You are reviewing many small changes.

The GitHub web interface remains better for some tasks, especially inline code discussions and visual file comparisons. Use the tool that makes your review more accurate.

## The Implementation

List open pull requests:

```bash
gh pr list
```

View pull request details:

```bash
gh pr view PR_NUMBER
```

View the pull request in a browser:

```bash
gh pr view PR_NUMBER --web
```

Inspect the full patch:

```bash
gh pr diff PR_NUMBER
```

Check PR status, including reviews and checks:

```bash
gh pr status
```

Leave a general comment:

```bash
gh pr comment PR_NUMBER --body "The verification steps are clear. Please also confirm the example works on Node.js 18."
```

Approve a pull request only after reviewing it:

```bash
gh pr review PR_NUMBER --approve --body "Approved after reviewing the documentation change and passing CI results."
```

Request changes when a blocking concern remains:

```bash
gh pr review PR_NUMBER --request-changes --body "Please add a verification step showing that the generated file can be reviewed before publication."
```

## The Verification

Run:

```bash
gh pr view PR_NUMBER --json reviewDecision,statusCheckRollup
```

Expected information includes:

- Review decision.
- CI check status.
- Whether checks passed or failed.

Do not approve your own pull request unless your repository policy explicitly permits it and there is no independent reviewer available.

---

# S.8 Check GitHub Actions from the Terminal

## The Target

Inspect, watch, and troubleshoot GitHub Actions workflow runs using `gh`.

## The Concept

A workflow failure should be investigated from the first meaningful error, not fixed by guessing.

GitHub CLI lets you view Actions activity without opening a browser.

Useful commands include:

```bash
gh run list
gh run view
gh run watch
```

## The Implementation

List recent workflow runs:

```bash
gh run list
```

List only failed runs:

```bash
gh run list --status failure
```

List runs for the CI workflow:

```bash
gh run list --workflow "Continuous Integration"
```

Inspect one run:

```bash
gh run view RUN_ID
```

View failed logs only:

```bash
gh run view RUN_ID --log-failed
```

Watch the most recent run until it completes:

```bash
gh run watch
```

Re-run failed jobs only when you understand why the original run failed:

```bash
gh run rerun RUN_ID --failed
```

## The Verification

A successful workflow run reports a conclusion similar to:

```text
✓ main Continuous Integration ... completed successfully
```

For a failed test run:

```bash
gh run view RUN_ID --log-failed
```

should show the failing test assertion or failed command.

Reproduce test failures locally when possible:

```bash
npm test
```

---

# S.9 Create and Manage Releases with GitHub CLI

## The Target

Create a GitHub Release from an existing annotated Git tag.

## The Concept

A release should be based on an intentional tag such as:

```text
v1.0.0
```

The correct release sequence is:

```text
Merge tested work to main
    ↓
Update version and release notes
    ↓
Create annotated Git tag
    ↓
Push tag
    ↓
Create GitHub Release from tag
```

GitHub CLI can create the GitHub Release after the tag exists.

## The Implementation

Confirm the intended release tag exists:

```bash
git tag --list v1.0.0
git show v1.0.0
```

Confirm it exists on GitHub:

```bash
git ls-remote --tags origin v1.0.0
```

Create a release-notes file.

### `release-notes-manager/.github/release-v1.0.0.md`

```md
## First Stable Release

Release Notes Manager v1.0.0 provides a validated Markdown formatter and a complete GitHub collaboration workflow.

### Highlights

- Validated `formatReleaseNotes` API.
- Node.js automated tests.
- GitHub Actions continuous integration.
- Pull request and issue templates.
- Security and repository-governance documentation.
- Release-management guidance using annotated Git tags.

### Verification

```bash
npm test
```

For complete details, see `RELEASE_NOTES.md`.
```

Create the release:

```bash
gh release create v1.0.0 \
  --title "Release Notes Manager v1.0.0" \
  --notes-file .github/release-v1.0.0.md
```

Remove the temporary notes file if release notes are already permanently stored in `RELEASE_NOTES.md`:

```bash
rm .github/release-v1.0.0.md
```

List releases:

```bash
gh release list
```

View the release:

```bash
gh release view v1.0.0 --web
```

## The Verification

Expected `gh release list` output includes:

```text
Release Notes Manager v1.0.0    Latest    v1.0.0
```

Confirm on GitHub that:

- The release is attached to tag `v1.0.0`.
- The release notes render correctly.
- Source-code archives are available.
- The release is marked as latest when appropriate.

---

# S.10 Download Release Assets

## The Target

Download release assets or source archives from a GitHub Release.

## The Concept

A GitHub Release may contain:

- Generated source ZIP archives.
- Generated TAR.GZ archives.
- Uploaded binaries.
- Documentation bundles.
- Checksums.
- Installation packages.

GitHub CLI can download selected assets without manually navigating the browser.

## The Implementation

List release assets:

```bash
gh release view v1.0.0
```

Download all release assets:

```bash
gh release download v1.0.0
```

Download a matching asset only:

```bash
gh release download v1.0.0 --pattern "*.zip"
```

Download to a specific directory:

```bash
mkdir -p ./downloads/v1.0.0
gh release download v1.0.0 --dir ./downloads/v1.0.0
```

On Windows PowerShell:

```powershell
New-Item -ItemType Directory -Path ".\downloads\v1.0.0" -Force
gh release download v1.0.0 --dir ".\downloads\v1.0.0"
```

## The Verification

List downloaded files.

### macOS, Linux, or Git Bash

```bash
find ./downloads/v1.0.0 -maxdepth 1 -type f -print
```

### Windows PowerShell

```powershell
Get-ChildItem ".\downloads\v1.0.0" -File
```

Verify that each downloaded asset is expected before executing or distributing it.

---

# S.11 Use `gh api` Carefully

## The Target

Understand when GitHub CLI’s API command is useful and why it deserves caution.

## The Concept

`gh api` sends requests directly to GitHub’s API.

It is powerful for querying or automating GitHub features not covered by a dedicated `gh` subcommand.

For example, inspect repository metadata:

```bash
gh api repos/OWNER/REPOSITORY
```

Or inspect branch-protection information where your permissions allow it.

However, API commands can create, modify, or delete GitHub resources. Review endpoint paths and request methods carefully.

Think of `gh api` as a maintenance control panel, not a command to run from copied snippets without understanding.

## The Implementation

Read-only repository query:

```bash
gh api repos/YOUR_GITHUB_USERNAME/release-notes-manager \
  --jq '{name: .name, visibility: .visibility, default_branch: .default_branch}'
```

Read-only query for open pull requests:

```bash
gh api repos/YOUR_GITHUB_USERNAME/release-notes-manager/pulls \
  --jq '.[] | {number: .number, title: .title, state: .state}'
```

Inspect repository topics:

```bash
gh api repos/YOUR_GITHUB_USERNAME/release-notes-manager/topics \
  --jq '.names'
```

## The Verification

Expected output resembles:

```json
{
  "default_branch": "main",
  "name": "release-notes-manager",
  "visibility": "public"
}
```

Do not use API `POST`, `PATCH`, `PUT`, or `DELETE` requests until you understand exactly which resource they modify.

---

# S.12 GitHub CLI Daily Workflow Cheat Sheet

## Start Work

```bash
git switch main
git pull --ff-only
git switch -c feature/short-description
gh issue list
```

## Create an Issue

```bash
gh issue create \
  --title "Add release export example" \
  --body-file .github/issue-body.md \
  --label documentation
```

## Push a Feature Branch

```bash
git status
git diff
npm test
git add <files>
git commit -m "docs(readme): add release export example"
git push -u origin feature/short-description
```

## Open a Pull Request

```bash
gh pr create \
  --base main \
  --title "docs(readme): add release export example" \
  --body-file .github/pr-body.md
```

## Inspect Pull Request Status

```bash
gh pr status
gh pr view --web
gh pr diff
```

## Inspect CI

```bash
gh run list
gh run watch
```

## Merge an Approved Pull Request

Use GitHub’s protected-branch requirements first. When permitted:

```bash
gh pr merge PR_NUMBER --squash --delete-branch
```

Then update local state:

```bash
git switch main
git pull --ff-only
git fetch --prune
```

Do not use CLI merge commands to bypass review, branch protection, required checks, or code-owner requirements.

---

# Appendix S Completion Check

You should now be able to:

- [ ] Install and authenticate GitHub CLI securely.
- [ ] Confirm the current repository with `gh repo view`.
- [ ] Create and inspect GitHub Issues from the terminal.
- [ ] Create pull requests using `gh pr create`.
- [ ] Review pull request details, diffs, comments, and checks.
- [ ] Inspect GitHub Actions workflow runs with `gh run`.
- [ ] Create GitHub Releases from existing Git tags.
- [ ] Download release assets safely.
- [ ] Use read-only `gh api` queries.
- [ ] Combine Git commands and GitHub CLI commands in one practical terminal workflow.
