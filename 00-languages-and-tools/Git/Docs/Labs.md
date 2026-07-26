# Git and GitHub Lab Book  
## Mastering Version Control from Local to Production

**Student name:** ________________________________  
**GitHub username:** ______________________________  
**Repository URL:** _______________________________  
**Start date:** ___________________________________  

---

## Lab Rules

Before every lab:

```bash
git status
```

Before every commit:

```bash
git diff
git diff --staged
```

Before every risky command:

```bash
git status
git log --oneline --decorate -10
```

> Do not commit real passwords, API keys, tokens, private keys, or `.env` files.

---

# Lab 0: Environment Readiness

## Goal

Confirm that required tools are available.

## Commands

```bash
git --version
node --version
npm --version
```

Optional GitHub CLI check:

```bash
gh --version
```

## Record Results

| Tool | Version |
|---|---|
| Git | ______________________________ |
| Node.js | ______________________________ |
| npm | ______________________________ |
| GitHub CLI | ______________________________ |

## Completion Check

```text
[ ] Git works.
[ ] Node.js version is 18 or newer.
[ ] npm works.
[ ] GitHub account is available.
[ ] Terminal and code editor are available.
```

---

# Lab 1: Create a Local Repository

## Goal

Create the `release-notes-manager` project and initialize Git.

## Commands

### macOS, Linux, or Git Bash

```bash
mkdir -p ~/projects/release-notes-manager
cd ~/projects/release-notes-manager
git init
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path "$HOME\projects\release-notes-manager" -Force
Set-Location "$HOME\projects\release-notes-manager"
git init
```

## Verification

```bash
git status
```

Expected result:

```text
On branch main
No commits yet
nothing to commit
```

## Notes

**Repository path:**  
__________________________________________________________________

**What does `.git` store?**  
__________________________________________________________________

---

# Lab 2: Create and Commit Project Documentation

## Goal

Create the first tracked file and first commit.

## File

### `README.md`

```md
# Release Notes Manager

Release Notes Manager is a small project for organizing and publishing clear software release notes.

## Purpose

This repository is used to learn professional Git and GitHub workflows.

## Status

The project is in its initial documentation phase.
```

## Commands

```bash
git status
git add README.md
git diff --staged
git commit -m "Add initial project documentation"
git log --oneline
```

## Verification

```bash
git status
```

Expected result:

```text
nothing to commit, working tree clean
```

## Record

**First commit hash:** ________________________________

---

# Lab 3: Inspect and Stage Changes Selectively

## Goal

Practice the difference between unstaged and staged changes.

## Instructions

1. Add this section to `README.md`:

```md
## Contribution Guidelines

Keep each change focused on one purpose. Review the Git diff before committing.
```

2. Create a second file.

### `RELEASE_NOTES.md`

```md
# Release Notes

## Unreleased

### Added

- Initial release-note template.
```

## Commands

```bash
git status
git diff
git add RELEASE_NOTES.md
git diff --staged
git diff
git commit -m "Add release notes template"
```

## Verification

```bash
git status
```

Expected result: `README.md` remains modified but uncommitted.

## Reflection

Why was `README.md` not included in the commit?

__________________________________________________________________

---

# Lab 4: Restore and Unstage Safely

## Goal

Practice undoing an unwanted edit and unstaging without deleting work.

## Instructions

Add this temporary line to `README.md`:

```md
This sentence should be discarded.
```

## Commands

```bash
git diff -- README.md
git restore README.md
git status
```

Now add this intended section:

```md
## Local Development

Use Git status frequently to understand whether changes are untracked, unstaged, staged, or committed.
```

Stage it:

```bash
git add README.md
git diff --staged
```

Unstage it without losing the text:

```bash
git restore --staged README.md
git status
git diff
```

Finally commit it:

```bash
git add README.md
git commit -m "Add local development guidance"
```

## Completion Check

```text
[ ] I used git restore to discard an unwanted unstaged edit.
[ ] I used git restore --staged to unstage without losing edits.
[ ] I understand the difference.
```

---

# Lab 5: Create and Merge a Feature Branch

## Goal

Create a branch, make a feature commit, merge it into `main`, and delete the branch.

## Commands

```bash
git switch main
git switch -c feature/add-release-checklist
```

Create:

### `RELEASE_CHECKLIST.md`

```md
# Release Checklist

## Before Publishing

- [ ] Confirm the working tree is clean.
- [ ] Review release notes for accuracy.
- [ ] Run the test suite.
- [ ] Confirm no secrets are included.
- [ ] Verify the target branch is `main`.
```

Commit:

```bash
git add RELEASE_CHECKLIST.md
git commit -m "Add release checklist"
```

Switch and merge:

```bash
git switch main
git merge feature/add-release-checklist
git branch -d feature/add-release-checklist
```

## Verification

```bash
git log --oneline --decorate --graph --all
git branch
```

## Reflection

What happened to the feature commit after deleting the branch?

__________________________________________________________________

---

# Lab 6: Resolve a Merge Conflict

## Goal

Create and resolve a controlled merge conflict.

## Instructions

Create a branch:

```bash
git switch -c docs/clarify-project-status
```

Change the README status line to:

```md
The project is in its active documentation and planning phase.
```

Commit it:

```bash
git add README.md
git commit -m "Clarify documentation project status"
```

Switch to `main`:

```bash
git switch main
```

Change the same status line to:

```md
The project is in its active development phase.
```

Commit:

```bash
git add README.md
git commit -m "Update project status for development"
```

Attempt the merge:

```bash
git merge docs/clarify-project-status
```

## Resolve

Replace the conflict section with:

```md
The project is in its active development, documentation, and planning phase.
```

Then run:

```bash
git diff --check
git add README.md
git commit -m "Merge branch 'docs/clarify-project-status'"
git branch -d docs/clarify-project-status
```

## Verification

```bash
git status
git log --oneline --decorate --graph --all
```

## Notes

What caused the conflict?

__________________________________________________________________

---

# Lab 7: Connect to GitHub

## Goal

Create a GitHub repository and push local `main`.

## Instructions

Create an empty GitHub repository named:

```text
release-notes-manager
```

Do not initialize it with a README or `.gitignore`.

## Commands

### SSH

```bash
git remote add origin git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
```

### HTTPS

```bash
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager.git
```

Push:

```bash
git remote -v
git push -u origin main
```

## Verification

```bash
git status
git branch --all
```

Expected result includes:

```text
Your branch is up to date with 'origin/main'.
```

## Record

**Remote URL:**  
__________________________________________________________________

---

# Lab 8: Fetch and Pull a Remote Change

## Goal

Understand remote changes without immediately integrating them.

## Instructions

On GitHub, edit `README.md` through the web interface and add:

```md
## Remote Workflow

Use `git fetch` to inspect remote changes before integrating them.
```

Commit directly to `main` on GitHub.

## Commands

Back locally:

```bash
git fetch origin
git log --oneline main..origin/main
git diff main..origin/main -- README.md
git pull --ff-only
```

## Verification

```bash
git status
git show HEAD:README.md
```

## Reflection

What changed after `git fetch` but before `git pull`?

__________________________________________________________________

---

# Lab 9: Add Secure Ignore Rules

## Goal

Create and test `.gitignore`.

## File

### `.gitignore`

```gitignore
.env
.env.*
!.env.example

node_modules/
coverage/
dist/
build/

*.log
.DS_Store
.vscode/
.idea/
```

## Commands

```bash
git add .gitignore
git commit -m "Add repository ignore rules"
```

Create a harmless test file:

### macOS, Linux, or Git Bash

```bash
printf 'DEMO_TOKEN=not-a-real-secret\n' > .env
```

### Windows PowerShell

```powershell
'DEMO_TOKEN=not-a-real-secret' | Set-Content -Path .env
```

Test it:

```bash
git status --short
git check-ignore -v .env
```

Clean up:

### macOS, Linux, or Git Bash

```bash
rm .env
```

### Windows PowerShell

```powershell
Remove-Item .env
```

## Completion Check

```text
[ ] .env is ignored.
[ ] node_modules is ignored.
[ ] I understand that .gitignore does not remove tracked secrets.
```

---

# Lab 10: Add the Formatter and Tests

## Goal

Add a tested JavaScript module on a feature branch.

## Commands

```bash
git switch main
git pull --ff-only
git switch -c feature/add-release-formatter
```

Create:

### `package.json`

```json
{
  "name": "release-notes-manager",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "test": "node --test"
  },
  "engines": {
    "node": ">=18"
  }
}
```

### `src/releaseNotes.js`

```js
function isNonEmptyString(value) {
  return typeof value === "string" && value.trim().length > 0;
}

function isValidReleaseDate(value) {
  if (!isNonEmptyString(value)) {
    return false;
  }

  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return false;
  }

  const date = new Date(`${value}T00:00:00.000Z`);

  return (
    !Number.isNaN(date.getTime()) &&
    date.toISOString().slice(0, 10) === value
  );
}

function normalizeSection(value, sectionName) {
  if (value === undefined) {
    return [];
  }

  if (!Array.isArray(value)) {
    throw new TypeError(`${sectionName} must be an array of non-empty strings.`);
  }

  return value.map((entry, index) => {
    if (!isNonEmptyString(entry)) {
      throw new TypeError(
        `${sectionName}[${index}] must be a non-empty string.`
      );
    }

    return entry.trim();
  });
}

function formatSection(title, entries) {
  if (entries.length === 0) {
    return [];
  }

  return [`## ${title}`, "", ...entries.map((entry) => `- ${entry}`)];
}

export function formatReleaseNotes(release) {
  if (release === null || typeof release !== "object" || Array.isArray(release)) {
    throw new TypeError("release must be an object.");
  }

  if (!isNonEmptyString(release.version)) {
    throw new TypeError("release.version must be a non-empty string.");
  }

  if (!isValidReleaseDate(release.releaseDate)) {
    throw new TypeError(
      "release.releaseDate must be a valid date in YYYY-MM-DD format."
    );
  }

  const added = normalizeSection(release.added, "release.added");
  const changed = normalizeSection(release.changed, "release.changed");
  const fixed = normalizeSection(release.fixed, "release.fixed");

  const lines = [
    `# Release ${release.version.trim()}`,
    "",
    `**Release date:** ${release.releaseDate}`
  ];

  for (const section of [
    formatSection("Added", added),
    formatSection("Changed", changed),
    formatSection("Fixed", fixed)
  ]) {
    if (section.length > 0) {
      lines.push("", ...section);
    }
  }

  return `${lines.join("\n")}\n`;
}
```

### `src/releaseNotes.test.js`

```js
import assert from "node:assert/strict";
import test from "node:test";
import { formatReleaseNotes } from "./releaseNotes.js";

test("formats populated release note sections", () => {
  const result = formatReleaseNotes({
    version: "1.0.0",
    releaseDate: "2026-07-25",
    added: ["Create formatted release notes."],
    fixed: ["Correct release date validation."]
  });

  assert.match(result, /^# Release 1\.0\.0$/m);
  assert.match(result, /## Added/);
  assert.match(result, /## Fixed/);
});

test("omits empty sections", () => {
  const result = formatReleaseNotes({
    version: "1.0.1",
    releaseDate: "2026-07-26",
    added: [],
    fixed: ["Correct a formatting issue."]
  });

  assert.doesNotMatch(result, /## Added/);
  assert.doesNotMatch(result, /## Changed/);
  assert.match(result, /## Fixed/);
});

test("rejects invalid release dates", () => {
  assert.throws(
    () =>
      formatReleaseNotes({
        version: "1.0.0",
        releaseDate: "2026-02-31"
      }),
    {
      name: "TypeError",
      message:
        "release.releaseDate must be a valid date in YYYY-MM-DD format."
    }
  );
});
```

## Commands

```bash
npm test
git add package.json src/releaseNotes.js src/releaseNotes.test.js
git commit -m "Add release note formatter"
git push -u origin feature/add-release-formatter
```

## Verification

```bash
npm test
git status
```

---

# Lab 11: Open and Review a Pull Request

## Goal

Create a pull request and review it using a structured checklist.

## Pull Request Title

```text
Add release note formatter
```

## Pull Request Body

```md
## Summary

Adds a validated JavaScript formatter for structured release notes.

## Changes

- Add formatter implementation.
- Add automated tests.
- Add Node.js project configuration.

## Verification

```bash
npm test
```

## Review Focus

Please review date validation, error messages, and section formatting.
```

## Review Checklist

```text
[ ] The PR has one focused purpose.
[ ] Tests pass.
[ ] Invalid dates are covered.
[ ] Empty sections are omitted.
[ ] Error messages are clear.
[ ] No secrets are included.
[ ] CI passes.
```

## Review Comment Practice

Write one comment:

__________________________________________________________________

## Completion Check

```text
[ ] Pull request opened.
[ ] CI completed.
[ ] Review performed.
[ ] Feature branch merged through GitHub.
[ ] Local main updated afterward.
```

---

# Lab 12: Add GitHub Actions CI

## Goal

Create automated test execution for pull requests and pushes to `main`.

## File

### `.github/workflows/ci.yml`

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

      - name: Install dependencies
        run: npm install

      - name: Run test suite
        run: npm test
```

## Commands

```bash
git switch -c ci/add-test-workflow
git add .github/workflows/ci.yml
git commit -m "Add continuous integration workflow"
git push -u origin ci/add-test-workflow
```

## Verification

On GitHub:

```text
[ ] Workflow appears in Actions tab.
[ ] Pull request check runs.
[ ] Test job succeeds.
[ ] Branch protection can require the check.
```

---

# Lab 13: Stash and Recover Work

## Goal

Practice temporarily shelving work and recovering it.

## Instructions

Add a temporary line to `README.md`:

```md
Temporary stash practice note.
```

## Commands

```bash
git status
git stash push -m "README stash practice"
git status
git stash list
git stash show --patch stash@{0}
git stash apply stash@{0}
```

Discard the temporary line:

```bash
git restore README.md
git stash drop stash@{0}
```

## Verification

```bash
git status
git stash list
```

Expected result:

```text
nothing to commit, working tree clean
```

---

# Lab 14: Recover a Deleted Branch with Reflog

## Goal

Practice recovery from a deleted local branch.

## Commands

```bash
git switch -c practice/recovery
```

Create:

### `RECOVERY_PRACTICE.md`

```md
# Recovery Practice

This file exists to demonstrate reflog recovery.
```

Commit:

```bash
git add RECOVERY_PRACTICE.md
git commit -m "Add recovery practice file"
```

Switch and delete:

```bash
git switch main
git branch -D practice/recovery
```

Find the commit:

```bash
git reflog --all --oneline
```

Recover it:

```bash
git switch -c recovery/recovered-practice <commit-hash>
git log --oneline main..HEAD
```

Clean up:

```bash
git switch main
git branch -D recovery/recovered-practice
```

## Reflection

How did reflog help?

__________________________________________________________________

---

# Lab 15: Revert a Bad Shared Commit

## Goal

Practice the safe rollback method for shared history.

## Commands

Create a disposable branch:

```bash
git switch -c practice/revert
```

Create:

### `BAD_CHANGE.md`

```md
# Bad Change

This file represents a change that should be reverted.
```

Commit it:

```bash
git add BAD_CHANGE.md
git commit -m "Add bad practice change"
```

Copy the commit hash:

```bash
git rev-parse HEAD
```

Revert it:

```bash
git revert HEAD
```

## Verification

```bash
git log --oneline -3
git status
```

Expected result:

```text
Revert "Add bad practice change"
Add bad practice change
```

Clean up:

```bash
git switch main
git branch -D practice/revert
```

---

# Lab 16: Create a Release Tag

## Goal

Create an annotated release tag from tested `main`.

## Commands

```bash
git switch main
git pull --ff-only
git status
npm test
```

Create tag:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git show v1.0.0
git push origin v1.0.0
```

## Verification

```bash
git tag --list v1.0.0
git ls-remote --tags origin v1.0.0
```

## Record

**Release commit hash:** ________________________________  
**Release tag:** ________________________________________  

---

# Lab 17: Final Production Readiness Review

## Goal

Perform a complete repository audit.

## Commands

```bash
git status
git branch -vv
git remote -v
git fetch origin --prune
git log --oneline --decorate --graph --all -20
git fsck --full
git count-objects -vH
npm test
```

## GitHub Checklist

```text
[ ] main is protected.
[ ] Pull requests are required.
[ ] CI checks are required.
[ ] Force pushes are blocked.
[ ] Repository access is reviewed.
[ ] Secrets are not committed.
[ ] Actions permissions are minimal.
[ ] Release tags and notes are intentional.
[ ] CODEOWNERS is configured if needed.
[ ] Recovery procedure is documented.
```

## Final Reflection

What command will you use first whenever Git feels confusing?

```bash
______________________________________________
```

What is your personal Git workflow before opening a pull request?

__________________________________________________________________

__________________________________________________________________
