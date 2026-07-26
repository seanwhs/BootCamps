# Appendix T: Repository Templates, Bootstrap Scripts, and Repeatable Project Setup

Once you have built a well-configured repository, you should not need to recreate every quality and collaboration feature from memory for the next project.

A mature starter repository can include:

```text
Git configuration
├── .gitignore
├── .gitattributes
├── .githooks/
└── CODEOWNERS

Collaboration guidance
├── CONTRIBUTING.md
├── CODE_REVIEW.md
├── GOVERNANCE.md
├── SECURITY.md
└── GitHub issue and pull request templates

Automation
├── GitHub Actions CI
├── Dependency review
├── Dependabot configuration
└── Release preview workflow

Project setup
├── package.json
├── scripts/
└── README.md
```

This appendix shows how to turn those practices into a reusable repository template.

---

# T.1 Understand Repository Templates

## The Target

Understand how a GitHub template repository helps create new projects with consistent structure and standards.

## The Concept

A **template repository** is a GitHub repository intended to be copied when starting new projects.

Think of it as a prebuilt workshop.

Instead of beginning every project with an empty room, you begin with:

- Safety equipment.
- Tool labels.
- Basic workflow instructions.
- A clean workbench.
- A repeatable startup checklist.

A template repository differs from a fork:

| Approach | Relationship to source repository | Best use |
|---|---|---|
| Template repository | Creates a new independent repository | Starting a new project from shared standards |
| Fork | Retains a relationship to the original project | Contributing to or experimenting with another project |
| Clone | Creates a local copy | Working on an existing repository |

A template repository should contain generic, reusable defaults. It should not contain:

- Real secrets.
- Production credentials.
- Personal identifiers that new projects should not inherit.
- Old release tags.
- Old issue history.
- Project-specific deployment configuration.

---

# T.2 Decide What Belongs in a Template

## The Target

Separate reusable project infrastructure from project-specific implementation.

## The Concept

A template should give a project a safe beginning without pretending to know its full future.

Use this decision table.

| File or feature | Usually include in template? | Why |
|---|---:|---|
| `.gitignore` | Yes | Prevents common accidental commits |
| `.gitattributes` | Yes | Defines cross-platform file behavior |
| `.github/workflows/ci.yml` | Yes | Establishes CI baseline |
| `.github/pull_request_template.md` | Yes | Improves pull request quality |
| `.github/ISSUE_TEMPLATE/` | Yes | Standardizes incoming work |
| `CODE_REVIEW.md` | Yes | Defines review expectations |
| `CONTRIBUTING.md` | Yes, with placeholders | Explains collaboration workflow |
| `SECURITY.md` | Yes, with reporting placeholders | Defines security reporting expectations |
| `GOVERNANCE.md` | Usually | Documents maintainer responsibilities |
| `.githooks/` | Usually | Provides optional local safeguards |
| `package.json` | Depends | Include if the template targets Node.js projects |
| Application source code | Depends | Include only minimal starter code |
| Real production URLs | No | Project-specific and potentially sensitive |
| Tokens, credentials, `.env` | Never | Secrets must not enter templates |
| Release tags | No | Each new project starts its own release history |

---

# T.3 Create a Template Repository Folder Locally

## The Target

Create a clean local repository that will become a reusable GitHub template.

## The Concept

You will create a small Node.js-oriented template named:

```text
release-notes-manager-template
```

It will include:

- A minimal tested module.
- GitHub Actions CI.
- Secure ignore rules.
- A basic contributor workflow.
- GitHub collaboration templates.
- A bootstrap script for local hooks.

This is not a copy of the full Release Notes Manager project. It is a starting point for future projects.

## The Implementation

Create the project folder.

### macOS, Linux, or Git Bash

```bash
mkdir -p ~/projects/release-notes-manager-template
cd ~/projects/release-notes-manager-template
git init
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path "$HOME\projects\release-notes-manager-template" -Force
Set-Location "$HOME\projects\release-notes-manager-template"
git init
```

Create the required directories.

### macOS, Linux, or Git Bash

```bash
mkdir -p .github/ISSUE_TEMPLATE
mkdir -p .github/workflows
mkdir -p .githooks
mkdir -p scripts
mkdir -p src
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Force -Path ".github\ISSUE_TEMPLATE"
New-Item -ItemType Directory -Force -Path ".github\workflows"
New-Item -ItemType Directory -Force -Path ".githooks"
New-Item -ItemType Directory -Force -Path scripts
New-Item -ItemType Directory -Force -Path src
```

## The Verification

Run:

```bash
git status
```

Expected output resembles:

```text
On branch main

No commits yet

nothing to commit
```

List directories.

### macOS, Linux, or Git Bash

```bash
find . -type d -not -path './.git*' | sort
```

### Windows PowerShell

```powershell
Get-ChildItem -Recurse -Directory -Force |
  Where-Object { $_.FullName -notmatch '\\.git' } |
  Select-Object -ExpandProperty FullName
```

---

# T.4 Add a Safe `.gitignore`

## The Target

Prevent environment files, dependencies, generated files, logs, and editor settings from entering future repositories accidentally.

## The Concept

A template’s `.gitignore` is like a default packing policy:

> “Do not include temporary items, local credentials, generated output, or machine-specific clutter.”

## The Implementation

### `release-notes-manager-template/.gitignore`

```gitignore
# Local environment configuration may contain secrets.
.env
.env.*
!.env.example

# Dependencies are restored from package metadata.
node_modules/

# Generated output and test reports.
dist/
build/
coverage/
.nyc_output/

# Logs.
*.log
logs/

# Operating-system metadata.
.DS_Store
Thumbs.db
Desktop.ini

# Editor and IDE settings.
.vscode/
.idea/
*.suo
*.user
*.userossc
*.sln.docstates

# Temporary files.
*.tmp
*.temp
*.swp
*.swo
*~
```

## The Verification

Create a harmless local `.env` test file.

### macOS, Linux, or Git Bash

```bash
printf 'DEMO_VALUE=not-a-secret\n' > .env
```

### Windows PowerShell

```powershell
'DEMO_VALUE=not-a-secret' | Set-Content -Path .env
```

Verify that Git ignores it:

```bash
git check-ignore -v .env
git status --short
```

Remove the test file.

### macOS, Linux, or Git Bash

```bash
rm .env
```

### Windows PowerShell

```powershell
Remove-Item .env
```

---

# T.5 Add Cross-Platform File Attributes

## The Target

Establish consistent line-ending and binary-file behavior for every project created from the template.

## The Concept

`.gitattributes` is the repository’s file-handling policy.

It ensures shell scripts use Unix line endings, text files remain consistent, and binary files are not treated as text.

## The Implementation

### `release-notes-manager-template/.gitattributes`

```gitattributes
# Normalize text files in Git.
* text=auto

# Keep source code, documentation, and YAML configuration on LF endings.
*.js text eol=lf
*.json text eol=lf
*.md text eol=lf
*.sh text eol=lf
*.yml text eol=lf
*.yaml text eol=lf

# Windows batch files intentionally use CRLF.
*.bat text eol=crlf
*.cmd text eol=crlf

# Common binary files.
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.pdf binary
*.zip binary
*.mp4 binary
*.mov binary
```

## The Verification

Run:

```bash
git check-attr text eol -- .gitattributes
git check-attr text eol -- README.md
```

`README.md` does not exist yet, so the second command may still report attributes based on the path pattern. That is expected.

---

# T.6 Add Minimal Node.js Configuration and Tests

## The Target

Provide a small working test setup so CI verifies something meaningful from the first commit.

## The Concept

A template should not include a CI workflow that always passes because there are no tests.

You will add one tiny utility function and one test. Future projects can replace them with real application code, but the initial test proves that:

- Node.js is configured.
- The test command works.
- GitHub Actions can validate the repository.

## The Implementation

### `release-notes-manager-template/package.json`

```json
{
  "name": "replace-with-project-name",
  "version": "0.1.0",
  "private": true,
  "description": "A starter repository for Node.js projects using GitHub collaboration and CI practices.",
  "type": "module",
  "scripts": {
    "test": "node --test"
  },
  "engines": {
    "node": ">=20"
  }
}
```

### `release-notes-manager-template/src/example.js`

```js
/**
 * Returns a normalized project title.
 *
 * This intentionally small example gives the template a real behavior and
 * test target. Replace it when the new project gains its own application code.
 *
 * @param {string} title - A project title to normalize.
 * @returns {string} The trimmed title.
 * @throws {TypeError} When title is not a string.
 */
export function normalizeProjectTitle(title) {
  if (typeof title !== "string") {
    throw new TypeError("title must be a string.");
  }

  return title.trim();
}
```

### `release-notes-manager-template/src/example.test.js`

```js
import assert from "node:assert/strict";
import test from "node:test";
import { normalizeProjectTitle } from "./example.js";

test("normalizes surrounding whitespace in a project title", () => {
  assert.equal(
    normalizeProjectTitle("  Release Notes Manager  "),
    "Release Notes Manager"
  );
});

test("rejects non-string project titles", () => {
  assert.throws(
    () => normalizeProjectTitle(42),
    {
      name: "TypeError",
      message: "title must be a string."
    }
  );
});
```

Run the tests:

```bash
npm test
```

## The Verification

Expected output includes:

```text
# tests 2
# pass 2
# fail 0
```

---

# T.7 Add a Secure GitHub Actions CI Workflow

## The Target

Add read-only CI that tests pushes and pull requests targeting `main`.

## The Concept

The template should establish a quality gate early.

This workflow uses:

- `contents: read` permissions.
- A supported Node.js version.
- A full immutable pin for third-party Actions.
- The standard `npm test` command.

> Action commit hashes must be reviewed and updated over time. Use verified current hashes before using this template in production.

## The Implementation

### `release-notes-manager-template/.github/workflows/ci.yml`

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
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      - name: Set up Node.js
        uses: actions/setup-node@1e60f620b9541d4f48b7f6d1859ad8c90f8d9c5b # v4.4.0
        with:
          node-version: "20"
          cache: "npm"

      - name: Install dependencies
        run: npm install

      - name: Run test suite
        run: npm test
```

## The Verification

Validate local project behavior:

```bash
npm test
```

Review workflow settings:

```bash
git diff -- .github/workflows/ci.yml
```

Confirm the workflow:

- Runs only for pushes to `main` and PRs targeting `main`.
- Has read-only permissions.
- Runs tests.

---

# T.8 Add Pull Request and Issue Templates

## The Target

Give every future project a consistent starting point for collaboration.

## The Concept

Templates reduce omissions. They make common questions visible every time.

## The Implementation

### `release-notes-manager-template/.github/pull_request_template.md`

```md
## Summary

Explain the outcome of this pull request.

Closes #ISSUE_NUMBER

## Changes

- Describe the first meaningful change.
- Describe test or documentation updates.

## Verification

```bash
npm test
```

## Review Focus

Tell reviewers where extra attention would be useful.

## Checklist

- [ ] This pull request has one focused purpose.
- [ ] I reviewed my own diff.
- [ ] Tests pass locally.
- [ ] Documentation is updated when needed.
- [ ] No secrets, generated files, or unrelated changes are included.
```

### `release-notes-manager-template/.github/ISSUE_TEMPLATE/bug_report.md`

```md
---
name: Bug report
about: Report behavior that does not work as expected
title: "[Bug]: "
labels: bug, needs triage
assignees: ""
---

## Summary

Describe the problem clearly.

## Steps to Reproduce

1. 
2. 
3. 

## Expected Behavior

Describe what should happen.

## Actual Behavior

Describe what happened.

## Environment

- Operating system:
- Node.js version:
- Git version:
- Branch or commit hash:

## Relevant Output

```text
Paste errors or logs here after removing secrets.
```

## Checklist

- [ ] I searched existing issues.
- [ ] I removed secrets from logs and screenshots.
- [ ] Another contributor can reproduce the issue from this report.
```

### `release-notes-manager-template/.github/ISSUE_TEMPLATE/feature_request.md`

```md
---
name: Feature request
about: Suggest a capability or improvement
title: "[Feature]: "
labels: enhancement, needs triage
assignees: ""
---

## Problem

What problem should this feature solve?

## Proposed Outcome

What should users or contributors be able to do?

## Acceptance Criteria

- [ ] 
- [ ] 
- [ ] 

## Alternatives Considered

Describe relevant alternatives or workarounds.

## Additional Context

Add examples, links, or constraints.
```

### `release-notes-manager-template/.github/ISSUE_TEMPLATE/config.yml`

```yaml
blank_issues_enabled: false
contact_links:
  - name: Security vulnerability report
    url: https://github.com/OWNER/REPOSITORY/security/advisories/new
    about: Report security concerns privately through GitHub Security Advisories.
```

The `OWNER/REPOSITORY` placeholder must be replaced after creating a real repository from the template.

## The Verification

Check all files exist.

### macOS, Linux, or Git Bash

```bash
find .github -type f | sort
```

### Windows PowerShell

```powershell
Get-ChildItem .github -Recurse -File | Select-Object -ExpandProperty FullName
```

---

# T.9 Add Contributor and Security Documentation

## The Target

Provide basic collaboration and security expectations without embedding project-specific details.

## The Concept

Future contributors need guidance from the first day. The template should establish a baseline, then each project can customize it.

## The Implementation

### `release-notes-manager-template/CONTRIBUTING.md`

```md
# Contributing

Thank you for contributing.

## Set Up

Install a supported Node.js version, Git, and npm.

Run tests:

```bash
npm test
```

## Create a Branch

Start from updated `main`:

```bash
git switch main
git pull --ff-only
```

Create a focused branch:

```bash
git switch -c feature/short-description
```

## Before Opening a Pull Request

Run:

```bash
git status
git diff main...HEAD
npm test
```

Keep each pull request focused. Update tests and documentation when behavior changes.

## Commit Messages

Use a clear action-oriented message:

```text
Add input validation
Fix invalid date handling
Document local setup
```

## Security

Do not commit passwords, API keys, tokens, private keys, or real `.env` files.

See [SECURITY.md](SECURITY.md) for reporting guidance.
```

### `release-notes-manager-template/SECURITY.md`

```md
# Security Policy

## Reporting a Vulnerability

Do not report security vulnerabilities through public GitHub Issues.

Use GitHub Security Advisories for private reporting:

```text
https://github.com/OWNER/REPOSITORY/security/advisories/new
```

Replace `OWNER/REPOSITORY` after creating a repository from this template.

## Secret Safety

Do not commit:

- Passwords
- API keys
- Personal Access Tokens
- Private keys
- Real `.env` files
- Production credentials

If a secret is committed or pushed, revoke or rotate it immediately.
```

### `release-notes-manager-template/CODE_REVIEW.md`

```md
# Code Review Checklist

## Correctness

- [ ] The change meets its acceptance criteria.
- [ ] Important inputs and failure cases are handled.
- [ ] Existing behavior is not unintentionally changed.

## Tests

- [ ] Automated tests pass.
- [ ] New behavior has appropriate coverage.

## Security

- [ ] No secrets or private credentials are included.
- [ ] Workflow changes use least-privilege permissions.
- [ ] Untrusted input is not inserted directly into shell commands.

## Collaboration

- [ ] The pull request is focused.
- [ ] Documentation is accurate.
- [ ] Review conversations are resolved.
```

## The Verification

Run:

```bash
npm test
git diff --check
```

Expected test output includes:

```text
# fail 0
```

`git diff --check` should produce no output.

---

# T.10 Add a Local Hook Installation Script

## The Target

Make it easy for future projects to enable version-controlled local hooks.

## The Concept

Hooks improve local feedback, but each contributor must enable them.

A bootstrap script prevents contributors from needing to remember Git configuration commands.

## The Implementation

### `release-notes-manager-template/.githooks/pre-commit`

```sh
#!/usr/bin/env sh

set -eu

echo "Running pre-commit checks..."

if ! command -v npm >/dev/null 2>&1; then
  echo "ERROR: npm is required to run pre-commit checks."
  exit 1
fi

npm test

echo "Pre-commit checks passed."
```

### `release-notes-manager-template/scripts/install-hooks.sh`

```sh
#!/usr/bin/env sh

set -eu

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: Run this script from inside a Git repository."
  exit 1
fi

if [ ! -d ".githooks" ]; then
  echo "ERROR: .githooks directory was not found."
  exit 1
fi

git config core.hooksPath .githooks

if command -v chmod >/dev/null 2>&1; then
  chmod +x .githooks/pre-commit
fi

echo "Local hooks are enabled."
echo "Configured hooks path: $(git config --get core.hooksPath)"
```

On macOS, Linux, or Git Bash:

```bash
chmod +x .githooks/pre-commit
chmod +x scripts/install-hooks.sh
```

Run the installer:

### macOS, Linux, or Git Bash

```bash
./scripts/install-hooks.sh
```

### Windows PowerShell

```powershell
bash ./scripts/install-hooks.sh
```

## The Verification

Expected output:

```text
Local hooks are enabled.
Configured hooks path: .githooks
```

Run the hook manually:

### macOS, Linux, or Git Bash

```bash
.githooks/pre-commit
```

### Windows PowerShell

```powershell
bash .githooks/pre-commit
```

Expected output includes:

```text
Pre-commit checks passed.
```

---

# T.11 Add a Bootstrap Checklist

## The Target

Create a file that explains what must be customized after generating a new repository from the template.

## The Concept

A template is intentionally generic. A new repository must replace placeholders and make project-specific choices.

A bootstrap checklist prevents generic defaults from accidentally reaching production unchanged.

## The Implementation

### `release-notes-manager-template/BOOTSTRAP_CHECKLIST.md`

```md
# New Repository Bootstrap Checklist

Complete this checklist after creating a repository from this template.

## Identity

- [ ] Update `package.json` name, description, and version.
- [ ] Update `README.md` with the real project purpose.
- [ ] Replace placeholder repository URLs.
- [ ] Replace `OWNER/REPOSITORY` in `SECURITY.md`.
- [ ] Replace placeholders in GitHub issue-template configuration.

## Access and Governance

- [ ] Add active maintainers.
- [ ] Configure branch protection or a ruleset for `main`.
- [ ] Require pull requests before merging.
- [ ] Require passing CI checks.
- [ ] Configure `CODEOWNERS` if the project has multiple maintainers.
- [ ] Create a GitHub Project, labels, and milestones if needed.

## Security

- [ ] Confirm `.gitignore` excludes local secrets.
- [ ] Configure GitHub Actions permissions as read-only by default.
- [ ] Review every workflow before enabling write permissions.
- [ ] Configure private security reporting.
- [ ] Enable dependency alerts and Dependabot where appropriate.

## Quality

- [ ] Replace example source code and tests with real project behavior.
- [ ] Confirm `npm test` passes.
- [ ] Confirm GitHub Actions passes on a pull request.
- [ ] Enable local hooks with `./scripts/install-hooks.sh`.
- [ ] Add formatting, linting, type-checking, or build scripts as needed.

## Releases

- [ ] Define versioning policy.
- [ ] Define release-note format.
- [ ] Decide whether release tags and signed commits are required.
- [ ] Document deployment process if the project deploys software.
```

## The Verification

Review the file:

```bash
cat BOOTSTRAP_CHECKLIST.md
```

On Windows PowerShell:

```powershell
Get-Content BOOTSTRAP_CHECKLIST.md
```

Confirm the checklist contains no credentials and no project-specific claims.

---

# T.12 Commit the Template Baseline

## The Target

Create a clean initial commit for the template repository.

## The Concept

The first commit should establish the template’s baseline.

Keep it focused:

```text
Create project template baseline
```

Do not split the initial template into many tiny commits unless you have a specific reason. Future projects benefit more from a clean starting snapshot than from a long history of template assembly.

## The Implementation

Review all untracked files:

```bash
git status
```

Review the complete file list:

```bash
git ls-files --others --exclude-standard
```

Stage the intended template files:

```bash
git add \
  .gitattributes \
  .github \
  .githooks \
  .gitignore \
  BOOTSTRAP_CHECKLIST.md \
  CODE_REVIEW.md \
  CONTRIBUTING.md \
  SECURITY.md \
  package.json \
  scripts \
  src
```

On Windows PowerShell:

```powershell
git add `
  .gitattributes `
  .github `
  .githooks `
  .gitignore `
  BOOTSTRAP_CHECKLIST.md `
  CODE_REVIEW.md `
  CONTRIBUTING.md `
  SECURITY.md `
  package.json `
  scripts `
  src
```

Review the staged files:

```bash
git diff --staged --stat
git diff --staged
```

Run tests:

```bash
npm test
```

Commit:

```bash
git commit -m "Create project template baseline"
```

## The Verification

Run:

```bash
git status
git log --oneline -1
```

Expected output:

```text
On branch main
nothing to commit, working tree clean
```

And:

```text
<hash> Create project template baseline
```

---

# T.13 Publish the Template Repository on GitHub

## The Target

Create and publish a GitHub repository that others can use as a template.

## The Concept

The repository should be empty on GitHub before your first push, just as in Part 3.

After pushing, GitHub can mark it as a template repository.

## The Implementation

On GitHub:

1. Open:

   ```text
   https://github.com/new
   ```

2. Create a repository named:

   ```text
   release-notes-manager-template
   ```

3. Do not initialize it with a README, `.gitignore`, or license.
4. Copy the SSH or HTTPS URL.

Add the remote:

```bash
git remote add origin git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager-template.git
```

Push `main`:

```bash
git push -u origin main
```

On GitHub:

1. Open the repository.
2. Select **Settings**.
3. Open **General**.
4. Enable:

   ```text
   Template repository
   ```

5. Save the setting.

## The Verification

Open the repository’s main page.

GitHub should display a button similar to:

```text
Use this template
```

Confirm the repository contains:

```text
.github/
.githooks/
scripts/
src/
BOOTSTRAP_CHECKLIST.md
CONTRIBUTING.md
SECURITY.md
package.json
```

---

# T.14 Create a New Repository from the Template

## The Target

Generate a new independent repository using the template.

## The Concept

Using a template creates a new project with copied files but independent Git history.

The new repository does not remain linked to the template as a fork would.

This is appropriate for a new project such as:

```text
product-release-dashboard
```

## The Implementation

On GitHub:

1. Open `release-notes-manager-template`.
2. Select **Use this template**.
3. Select **Create a new repository**.
4. Choose a repository name, for example:

   ```text
   product-release-dashboard
   ```

5. Choose visibility.
6. Select **Create repository from template**.

Clone the new repository:

```bash
git clone git@github.com:YOUR_GITHUB_USERNAME/product-release-dashboard.git
cd product-release-dashboard
```

Run the bootstrap script:

### macOS, Linux, or Git Bash

```bash
./scripts/install-hooks.sh
```

### Windows PowerShell

```powershell
bash ./scripts/install-hooks.sh
```

Run tests:

```bash
npm test
```

## The Verification

Confirm the generated repository has independent history:

```bash
git log --oneline
git remote -v
```

The remote should point to:

```text
product-release-dashboard
```

not:

```text
release-notes-manager-template
```

Confirm the test suite passes:

```bash
npm test
```

---

# T.15 Customize the New Project Immediately

## The Target

Replace template placeholders before real development begins.

## The Concept

A template gives you structure, not a finished identity.

Before adding application features, update the project’s public metadata and security links.

## The Implementation

Update `package.json`.

### `product-release-dashboard/package.json`

```json
{
  "name": "product-release-dashboard",
  "version": "0.1.0",
  "private": true,
  "description": "A dashboard for organizing and reviewing product release information.",
  "type": "module",
  "scripts": {
    "test": "node --test"
  },
  "engines": {
    "node": ">=20"
  }
}
```

Update `README.md` by creating it if the template does not yet include one.

### `product-release-dashboard/README.md`

```md
# Product Release Dashboard

Product Release Dashboard helps teams organize release information before publication.

## Development

Install a supported Node.js version, then run:

```bash
npm test
```

## Repository Setup

Read [BOOTSTRAP_CHECKLIST.md](BOOTSTRAP_CHECKLIST.md) before beginning feature development.

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## Security

Read [SECURITY.md](SECURITY.md) for private vulnerability-reporting guidance.
```

Update `SECURITY.md` and `.github/ISSUE_TEMPLATE/config.yml` with the real owner and repository path.

Run:

```bash
git status
git diff
npm test
```

Commit the bootstrap customization:

```bash
git add package.json README.md SECURITY.md .github/ISSUE_TEMPLATE/config.yml
git commit -m "Customize project template metadata"
git push
```

## The Verification

Confirm that no placeholder remains:

### macOS, Linux, or Git Bash

```bash
grep -RInE 'OWNER/REPOSITORY|YOUR_GITHUB_USERNAME|replace-with-project-name' \
  --exclude-dir=.git .
```

### Windows PowerShell

```powershell
Get-ChildItem -Recurse -File -Force |
  Where-Object { $_.FullName -notmatch '\\.git\\' } |
  Select-String -Pattern 'OWNER/REPOSITORY|YOUR_GITHUB_USERNAME|replace-with-project-name'
```

Expected result: no output.

---

# T.16 Template Maintenance Workflow

## The Target

Keep the template current without breaking projects already created from it.

## The Concept

Template repositories do not automatically update repositories that were created from them.

That is intentional. A new project owns its own history and configuration.

When you improve the template:

1. Open an issue in the template repository.
2. Create a feature branch.
3. Make the improvement.
4. Run tests.
5. Open a pull request.
6. Merge through CI and review.
7. Consider creating a template release tag.

Existing projects can adopt relevant improvements manually through normal pull requests.

## The Implementation

Example template-maintenance branch:

```bash
git switch main
git pull --ff-only
git switch -c docs/improve-bootstrap-checklist
```

After making a focused improvement:

```bash
npm test
git add BOOTSTRAP_CHECKLIST.md
git commit -m "Improve repository bootstrap checklist"
git push -u origin docs/improve-bootstrap-checklist
```

Open a pull request and merge it through the template repository’s standard workflow.

## The Verification

Tag meaningful template milestones:

```bash
git tag -a template-v1.0.0 -m "Template baseline version 1.0.0"
git push origin template-v1.0.0
```

This helps maintainers identify which template version a project originally used.

---

# Appendix T Completion Check

You should now be able to:

- [ ] Explain the difference between a template repository, fork, and clone.
- [ ] Decide which files belong in a reusable starter repository.
- [ ] Create a secure Node.js project template.
- [ ] Include `.gitignore`, `.gitattributes`, CI, hooks, and collaboration templates.
- [ ] Add a bootstrap checklist for project-specific setup.
- [ ] Publish and enable a GitHub template repository.
- [ ] Create an independent repository from a template.
- [ ] Replace placeholders before beginning real development.
- [ ] Maintain template improvements through the same pull-request workflow used by normal projects.
