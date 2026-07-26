# Primer 15: Dependency Management, Lockfiles, and Reproducible Installs

Most real software projects depend on code written by other people.

For a Node.js project, those external libraries are called **dependencies**.

Examples include:

```text
A testing library
A date utility
A web framework
A database client
A code formatter
A security scanner
```

Dependencies save time, but they also introduce responsibility.

A dependency can affect:

- Application behavior.
- Security.
- Build reliability.
- License obligations.
- CI performance.
- Reproducibility.

This primer explains the difference between `package.json`, `package-lock.json`, and `node_modules`, plus the safe commands used to install and update dependencies.

---

# P15.1 Understand What a Dependency Is

## The Target

Understand why projects use dependencies and why they must be managed carefully.

## The Concept

A dependency is code your project needs but does not maintain directly.

Think of building a house:

```text
Your project code
= the house you are building.

Dependencies
= materials and tools supplied by other companies.
```

For example, a project might use a package named:

```text
dotenv
```

to load local environment variables.

It might use:

```text
eslint
```

to check code style and common mistakes.

Or it might use:

```text
express
```

to create an HTTP server.

The Release Notes Manager tutorial intentionally starts without external dependencies. Node.js includes enough built-in features for:

- JavaScript execution.
- Basic assertions.
- Automated tests.

This keeps the project easier to inspect and reduces supply-chain risk while learning.

---

# P15.2 Understand `package.json`

## The Target

Understand why `package.json` is committed to Git.

## The Concept

`package.json` is the project manifest.

It tells npm and contributors:

```text
What the project is called.
Which version it has.
Which Node.js versions it supports.
Which scripts can run.
Which dependencies it requires.
```

A dependency section might look like this:

```json
{
  "dependencies": {
    "dotenv": "16.4.5"
  }
}
```

A development-only dependency section might look like:

```json
{
  "devDependencies": {
    "eslint": "9.8.0"
  }
}
```

The difference is:

| Section | Used for |
|---|---|
| `dependencies` | Required when the application runs in production |
| `devDependencies` | Required for development, testing, linting, or building |

## The Implementation

Inspect the current project manifest:

```bash
cat package.json
```

On Windows PowerShell:

```powershell
Get-Content package.json
```

The Release Notes Manager project begins with a dependency-free manifest similar to:

### `release-notes-manager/package.json`

```json
{
  "name": "release-notes-manager",
  "version": "1.0.0",
  "private": true,
  "description": "A small project for learning professional Git and GitHub workflows.",
  "type": "module",
  "scripts": {
    "test": "node --test",
    "test:watch": "node --test --watch"
  },
  "engines": {
    "node": ">=18"
  }
}
```

## The Verification

List direct installed dependencies:

```bash
npm ls --depth=0
```

For the dependency-free starter project, expected output resembles:

```text
release-notes-manager@1.0.0
└── (empty)
```

---

# P15.3 Understand `node_modules`

## The Target

Understand why `node_modules/` should not be committed.

## The Concept

When npm installs dependencies, it creates:

```text
node_modules/
```

This folder contains downloaded copies of packages and their own dependencies.

It can become very large:

```text
node_modules/
├── package-a/
├── package-b/
├── package-c/
└── hundreds of nested dependency folders
```

Do not commit `node_modules/`.

Reasons:

- It can be recreated from project metadata.
- It may contain thousands of files.
- It makes Git history unnecessarily large.
- Different operating systems may install platform-specific files.
- It creates noisy pull requests.

Instead, commit the dependency instructions:

```text
package.json
package-lock.json
```

Then each contributor runs:

```bash
npm install
```

or, in CI:

```bash
npm ci
```

## The Implementation

Confirm the project ignores `node_modules/`:

```bash
git check-ignore -v node_modules/example-package/index.js
```

Inspect `.gitignore`:

```bash
git show HEAD:.gitignore
```

Look for:

```gitignore
node_modules/
```

## The Verification

Expected output from `git check-ignore -v` resembles:

```text
.gitignore:<line-number>:node_modules/    node_modules/example-package/index.js
```

Confirm that Git does not track the folder:

```bash
git ls-files node_modules
```

Expected output: no output.

---

# P15.4 Understand `package-lock.json`

## The Target

Understand why Node.js applications usually commit the npm lockfile.

## The Concept

`package.json` may specify a version range.

For example:

```json
{
  "dependencies": {
    "example-package": "^1.2.0"
  }
}
```

The caret (`^`) generally allows compatible newer versions:

```text
1.2.0
1.2.1
1.3.0
```

That flexibility can cause different developers to install slightly different dependency versions at different times.

A lockfile records the exact dependency tree resolved at installation time.

```text
package.json
    → desired dependency ranges

package-lock.json
    → exact resolved package versions and integrity hashes
```

Think of the difference:

```text
package.json:
“Use this brand and model range of part.”

package-lock.json:
“Use exactly these specific serial-numbered parts.”
```

For an application, commit `package-lock.json` so local development and CI install the same dependency versions.

## The Implementation

A lockfile appears after npm installs dependencies.

For a dependency-free project, npm may create a minimal lockfile after:

```bash
npm install
```

Run:

```bash
npm install
```

Inspect whether npm created a lockfile:

### macOS, Linux, or Git Bash

```bash
ls package-lock.json
```

### Windows PowerShell

```powershell
Get-ChildItem package-lock.json
```

Inspect its beginning:

```bash
head -n 30 package-lock.json
```

On Windows PowerShell:

```powershell
Get-Content package-lock.json -TotalCount 30
```

## The Verification

A minimal lockfile resembles:

```json
{
  "name": "release-notes-manager",
  "version": "1.0.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
```

If `package-lock.json` was created, check Git status:

```bash
git status
```

If your project policy uses lockfiles, add it through a focused branch and pull request:

```bash
git add package-lock.json
git commit -m "chore(npm): add dependency lockfile"
```

---

# P15.5 Understand `npm install` Versus `npm ci`

## The Target

Choose the correct dependency-install command for local development and CI.

## The Concept

These commands are related but have different purposes.

| Command | Typical use | Behavior |
|---|---|---|
| `npm install` | Local development | Installs dependencies and may update `package-lock.json` |
| `npm ci` | CI and clean reproducible installs | Deletes existing `node_modules` and installs exactly from `package-lock.json` |

Use:

```bash
npm install
```

when you are developing locally or intentionally adding or updating a dependency.

Use:

```bash
npm ci
```

when you need a clean, deterministic installation—especially in GitHub Actions.

`npm ci` requires a valid lockfile.

## The Implementation

If `package-lock.json` exists, test a clean install.

First, ensure no important local dependency changes exist:

```bash
git status
```

Remove installed dependencies.

### macOS, Linux, or Git Bash

```bash
rm -rf node_modules
```

### Windows PowerShell

```powershell
Remove-Item -Recurse -Force node_modules
```

Run:

```bash
npm ci
```

Then run tests:

```bash
npm test
```

## The Verification

Expected test result:

```text
# fail 0
```

Confirm that `node_modules` remains ignored:

```bash
git status --short
```

It should not list `node_modules/`.

---

# P15.6 Update CI to Use `npm ci` When a Lockfile Exists

## The Target

Use deterministic dependency installation in GitHub Actions.

## The Concept

Once a repository commits `package-lock.json`, CI should usually use:

```bash
npm ci
```

This ensures the GitHub Actions runner installs exactly what the lockfile describes.

Before lockfile:

```yaml
- name: Install dependencies
  run: npm install
```

After lockfile:

```yaml
- name: Install dependencies
  run: npm ci
```

This makes CI more reproducible and often faster.

## The Implementation

If `package-lock.json` is committed to the project, update the CI workflow.

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

      # npm ci requires package-lock.json and installs the exact dependency
      # versions committed to the repository.
      - name: Install dependencies
        run: npm ci

      - name: Run test suite
        run: npm test
```

Create a branch before making the workflow change:

```bash
git switch main
git pull --ff-only
git switch -c ci/use-npm-ci
```

Run:

```bash
npm ci
npm test
```

Commit and push:

```bash
git add .github/workflows/ci.yml package-lock.json
git commit -m "ci(actions): use reproducible npm installs"
git push -u origin ci/use-npm-ci
```

## The Verification

Open a pull request.

Confirm GitHub Actions completes these steps successfully:

```text
Check out repository
Set up Node.js
Install dependencies
Run test suite
```

The installation step should run:

```text
npm ci
```

---

# P15.7 Add a Dependency Safely

## The Target

Understand the safe workflow for adding a new package.

## The Concept

Adding a dependency is a design decision, not just a command.

Before adding one, ask:

```text
Does Node.js already provide this capability?
Is the dependency actively maintained?
Is its license compatible with the project?
Does it have known security concerns?
Will it increase bundle size or operational complexity?
Can we explain why it is needed in the pull request?
```

For example, do not install a package merely to perform a one-line operation that plain JavaScript can handle.

## The Implementation

The general workflow is:

```bash
git switch main
git pull --ff-only
git switch -c feature/add-dependency-name
```

Install a production dependency:

```bash
npm install PACKAGE_NAME
```

Install a development dependency:

```bash
npm install --save-dev PACKAGE_NAME
```

Inspect what changed:

```bash
git status
git diff -- package.json package-lock.json
npm test
```

Commit both metadata files together:

```bash
git add package.json package-lock.json
git commit -m "build: add PACKAGE_NAME dependency"
```

Do not run an installation command with a real package merely for practice in this tutorial.

## The Verification

Before opening a dependency pull request, confirm:

```text
[ ] package.json changed as expected.
[ ] package-lock.json changed as expected.
[ ] No node_modules files are staged.
[ ] Tests pass.
[ ] The PR explains why the dependency is needed.
[ ] The dependency's license and maintenance status were reviewed.
```

---

# P15.8 Audit Dependencies

## The Target

Use npm tools to identify known dependency vulnerabilities.

## The Concept

Dependencies can have published security advisories.

npm can compare installed package versions with known vulnerability information:

```bash
npm audit
```

This is useful, but it is not a complete security program.

An audit result may include:

```text
Severity
Affected package
Vulnerable version range
Suggested update
```

Do not blindly run automatic fixes without reviewing their impact.

## The Implementation

Run:

```bash
npm audit
```

For a dependency-free project, expected output resembles:

```text
found 0 vulnerabilities
```

To inspect suggested changes without applying them:

```bash
npm audit --json
```

Avoid immediately running:

```bash
npm audit fix --force
```

The `--force` option can introduce breaking dependency changes.

## The Verification

Confirm you can interpret this safely:

```text
0 vulnerabilities
```

means npm found no known vulnerabilities in the installed dependency tree at that time.

It does not mean:

```text
The project has no security risk.
```

---

# P15.9 Understand Dependency Updates and Pull Requests

## The Target

Treat dependency updates as reviewable code changes.

## The Concept

A dependency update can change behavior even when you do not edit application source code.

For example:

```text
package-lock.json changed
    ↓
A transitive dependency changed
    ↓
Tests still need to pass
    ↓
CI and review still matter
```

A dependency-update pull request should explain:

```text
What package changed?
Why was it updated?
Is this a security update, bug fix, or feature update?
Did the lockfile change as expected?
Did tests pass?
```

## The Implementation

Use this pull request body for a dependency update:

```md
## Summary

Updates `PACKAGE_NAME` from `OLD_VERSION` to `NEW_VERSION`.

## Why

Explain whether this is a security update, bug fix, compatibility update, or planned maintenance.

## Changes

- Update `package.json`.
- Update `package-lock.json`.

## Verification

```bash
npm ci
npm test
npm audit
```

## Review Focus

Please review the package release notes, license changes if any, and lockfile changes.
```

## The Verification

Before merging, confirm:

```text
[ ] CI passed with a clean install.
[ ] package and lockfile changes are both present.
[ ] The update is intentional.
[ ] No unexpected unrelated dependencies changed.
[ ] The package source is trusted.
```

---

# P15.10 Dependency Safety Checklist

## The Target

Use a practical checklist whenever the dependency tree changes.

## The Concept

Dependencies are part of your application’s supply chain.

## The Implementation

Use this checklist:

```text
Before adding a dependency
[ ] Confirm native Node.js features cannot solve the need simply.
[ ] Review package purpose, maintenance activity, and license.
[ ] Review package popularity and trusted ownership.
[ ] Check known security advisories.
[ ] Decide whether it belongs in dependencies or devDependencies.

After installing
[ ] Review package.json changes.
[ ] Review package-lock.json changes.
[ ] Confirm node_modules remains ignored.
[ ] Run npm ci.
[ ] Run npm test.
[ ] Run npm audit.

Before merging
[ ] Pull request explains the dependency decision.
[ ] CI passes from a clean install.
[ ] Dependency review workflow passes.
[ ] Required code-owner or security review is complete.
```

## The Verification

Run this practical sequence after an intentional dependency change:

```bash
git status
git diff -- package.json package-lock.json
npm ci
npm test
npm audit
git diff --staged
```

Only commit after you understand every metadata and lockfile change.

---

# Primer 15 Reference: Dependency Commands

## Install Dependencies for Development

```bash
npm install
```

## Install Exactly from the Lockfile

```bash
npm ci
```

## Add a Production Dependency

```bash
npm install PACKAGE_NAME
```

## Add a Development Dependency

```bash
npm install --save-dev PACKAGE_NAME
```

## List Direct Dependencies

```bash
npm ls --depth=0
```

## Inspect Package License

```bash
npm view PACKAGE_NAME license
```

## Check Known Vulnerabilities

```bash
npm audit
```

## Explain Why a Package Is Installed

```bash
npm explain PACKAGE_NAME
```

---

# Primer 15 Completion Check

Before adding external packages to a Node.js project, confirm that you can:

- [ ] Explain what a dependency is.
- [ ] Explain the difference between `dependencies` and `devDependencies`.
- [ ] Explain why `node_modules/` must not be committed.
- [ ] Explain why applications usually commit `package-lock.json`.
- [ ] Choose between `npm install` and `npm ci`.
- [ ] Update CI to use `npm ci` when a lockfile exists.
- [ ] Review package and lockfile changes before committing.
- [ ] Run `npm audit` without blindly applying breaking fixes.
- [ ] Explain why dependency updates need pull requests, CI, and review.
- [ ] Use a dependency safety checklist before merging supply-chain changes.
