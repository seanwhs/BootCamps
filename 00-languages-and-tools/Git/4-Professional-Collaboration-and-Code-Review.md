# Part 4: Professional Collaboration and Code Review

In the earlier parts, you learned how Git records changes locally, how branches isolate work, and how GitHub stores a shared remote repository.

Now you will use those tools the way professional teams do:

- Keep `main` stable.
- Create one branch per focused work item.
- Open pull requests instead of pushing unfinished work directly to `main`.
- Ask for review.
- Resolve branch drift and conflicts.
- Track work with GitHub Issues, labels, milestones, and Projects.

The technical work in this part will add a small JavaScript release-note formatter to your repository. The code is intentionally modest; the focus is the collaboration workflow around it.

---

## Part 4 Roadmap

You will learn how to:

1. Protect the `main` branch.
2. Create a GitHub Issue for a focused work item.
3. Create a feature branch linked to that issue.
4. Add a small, testable application module.
5. Open a draft pull request.
6. Write a useful pull request description.
7. Review a pull request.
8. Handle branch drift and conflicts locally or through GitHub.
9. Merge a reviewed pull request safely.
10. Use labels, milestones, and Projects to organize team work.

---

# Step 1: Understand GitHub Flow

## The Target

Learn the collaboration model you will use throughout the rest of the series.

## The Concept

**GitHub Flow** is a lightweight team workflow built around a stable default branch, usually named `main`.

Think of `main` as the version of a document currently published to customers. You do not scribble experimental changes directly onto that published copy. Instead, you create a draft, get it reviewed, and publish it only after it is ready.

The workflow is:

```text
main is stable
   ↓
Create a focused feature branch
   ↓
Make commits and push the branch
   ↓
Open a pull request
   ↓
Review, discuss, test, and update
   ↓
Merge into main
   ↓
Delete the completed feature branch
```

A typical branch lifecycle looks like this:

```text
main
  │
  ├── feature/add-release-formatter
  │       │
  │       ├── Add formatter module
  │       ├── Add formatter tests
  │       └── Update documentation
  │
  └── Merge pull request
          │
          ▼
        main
```

The core rules are:

1. `main` should be deployable or releasable.
2. Each feature branch should have one understandable purpose.
3. Pull requests should be small enough to review carefully.
4. Review feedback belongs in the pull request, not scattered across private messages.
5. Merge only after required checks and approvals pass.

## The Implementation

No files change in this step.

Inspect your current local state:

```bash
git status
git branch --show-current
git log --oneline --decorate -5
```

## The Verification

Expected state:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Your active branch must be:

```text
main
```

Do not start feature work until the working tree is clean and synchronized.

---

# Step 2: Protect the `main` Branch

## The Target

Configure GitHub branch protection so `main` cannot be changed casually.

## The Concept

A protected branch is like a building’s main electrical panel: access is controlled because mistakes affect everyone.

Without protection, a contributor with write access might:

- Push unreviewed code directly to `main`.
- Force-push and rewrite shared history.
- Merge a pull request with failing checks.
- Delete the branch accidentally.

GitHub branch protection can require:

- Pull requests before merging.
- Review approval.
- Passing automated checks.
- Up-to-date branches before merging.
- Linear history.
- No force pushes.
- No branch deletion.

GitHub’s interface and exact options can vary by account type and repository visibility. Enable every available protection setting that fits this tutorial.

## The Implementation

On GitHub:

1. Open your `release-notes-manager` repository.
2. Select **Settings**.
3. Select **Branches** or **Rules**, depending on the GitHub interface shown.
4. Select **Add branch protection rule** or **New ruleset**.
5. Target the branch:

   ```text
   main
   ```

6. Enable these options when available:

   - **Require a pull request before merging**
   - **Require approvals**
   - Set required approvals to:

     ```text
     1
     ```

   - **Dismiss stale pull request approvals when new commits are pushed**
   - **Require conversation resolution before merging**
   - **Require status checks to pass before merging**
   - **Require branches to be up to date before merging**
   - **Block force pushes**
   - **Block deletions**

7. Save the rule or ruleset.

If you are the only contributor, GitHub may let repository administrators bypass some rules. For learning purposes, avoid bypassing them except when GitHub requires it because there is no second reviewer available.

## The Verification

Return to the repository’s main page.

Attempting to edit a file directly on `main` through GitHub should either be blocked or guide you toward creating a branch and pull request.

Locally, inspect the remote’s default branch:

```bash
git remote show origin
```

You should see a line similar to:

```text
HEAD branch: main
```

Branch protection is enforced by GitHub, not by your local Git installation. Local commands alone cannot fully display every rule.

---

# Step 3: Create a GitHub Issue for the Formatter Feature

## The Target

Create a GitHub Issue that explains the release-note formatter work before writing code.

## The Concept

An **issue** is a shared record of a problem, task, improvement, or question.

Think of an issue as a work ticket. It should give enough context that another developer can understand:

- What needs to happen.
- Why it matters.
- What “done” means.
- Which constraints or edge cases apply.

A good issue reduces confusion before code exists.

For this feature, you will create a formatter that turns a structured release object into Markdown.

## The Implementation

On GitHub:

1. Open the **Issues** tab.
2. Select **New issue**.
3. Use this title:

   ```text
   Add a release note formatter
   ```

4. Use this complete issue body:

   ```md
   ## Summary

   Add a small JavaScript module that converts structured release information into Markdown release notes.

   ## Why

   Release notes should follow a consistent format. A formatter reduces manual editing and gives future automation a predictable output shape.

   ## Acceptance Criteria

   - [ ] Create `src/releaseNotes.js`.
   - [ ] Export a `formatReleaseNotes` function.
   - [ ] Require a non-empty `version` string.
   - [ ] Require a valid `releaseDate` string in `YYYY-MM-DD` format.
   - [ ] Support optional `added`, `changed`, and `fixed` arrays.
   - [ ] Omit empty sections from generated Markdown.
   - [ ] Add tests in `src/releaseNotes.test.js`.
   - [ ] Update `README.md` with a usage example.

   ## Example Input

   ```js
   {
     version: "1.0.0",
     releaseDate: "2026-07-25",
     added: ["Create formatted release notes."],
     changed: [],
     fixed: ["Correct release date validation."]
   }
   ```

   ## Expected Output

   ```md
   # Release 1.0.0

   **Release date:** 2026-07-25

   ## Added

   - Create formatted release notes.

   ## Fixed

   - Correct release date validation.
   ```
   ```

5. Add a label if it exists:

   ```text
   enhancement
   ```

6. Assign the issue to yourself.
7. Submit the issue.

GitHub will assign an issue number. In later commands, replace `ISSUE_NUMBER` with that number.

## The Verification

Confirm the issue page includes:

- A clear title.
- The acceptance criteria checklist.
- The example input and expected output.
- An issue number, such as:

  ```text
  #1
  ```

Copy the issue number for the next step.

---

# Step 4: Create a Feature Branch Linked to the Issue

## The Target

Create a focused branch named `feature/add-release-formatter` from the latest remote `main`.

## The Concept

Before creating a feature branch, update local `main`.

This is like starting a new document draft from the latest approved version, rather than from an old copy someone emailed last week.

The safe sequence is:

```bash
git switch main
git pull --ff-only
git switch -c feature/add-release-formatter
```

The `--ff-only` option means:

> “Update only if Git can fast-forward without creating an unexpected merge commit.”

If it cannot fast-forward, Git stops and lets you inspect the situation rather than silently creating a merge commit.

## The Implementation

In your original `release-notes-manager` repository, run:

```bash
git switch main
git pull --ff-only
git switch -c feature/add-release-formatter
```

Confirm the branch:

```bash
git branch --show-current
```

## The Verification

Expected output:

```text
feature/add-release-formatter
```

Check repository state:

```bash
git status
```

Expected output resembles:

```text
On branch feature/add-release-formatter
nothing to commit, working tree clean
```

Your branch now begins at the latest `main` commit.

---

# Step 5: Add a Node.js Project Configuration

## The Target

Create `package.json` so the project can run JavaScript tests through a standard command.

## The Concept

A `package.json` file is a Node.js project manifest: a small configuration file that identifies the project and defines scripts.

Think of it as the project’s control panel. Instead of remembering a long test command, contributors can run:

```bash
npm test
```

For this tutorial, use Node.js’s built-in test runner. This avoids adding third-party dependencies and keeps the project easy to clone and run.

You need Node.js version 18 or newer.

## The Implementation

First, confirm Node.js and npm are installed:

```bash
node --version
npm --version
```

Create the following file.

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

Why these settings matter:

- `"private": true` prevents accidental publication to the public npm package registry.
- `"type": "module"` enables modern JavaScript `import` and `export` syntax.
- `"test": "node --test"` uses Node’s built-in test runner.
- `"engines"` documents the supported Node.js version.

Review the new file:

```bash
git status
git diff -- package.json
```

Stage and commit it:

```bash
git add package.json
git commit -m "Add Node.js test configuration"
```

## The Verification

Run:

```bash
npm test
```

Expected output resembles:

```text
> release-notes-manager@1.0.0 test
> node --test

1..0
# tests 0
# suites 0
# pass 0
# fail 0
```

Zero tests is expected for now.

Confirm your commit:

```bash
git log --oneline -1
```

Expected output:

```text
<hash> Add Node.js test configuration
```

---

# Step 6: Implement the Release Note Formatter

## The Target

Create a robust `formatReleaseNotes` function in `src/releaseNotes.js`.

## The Concept

The formatter accepts structured data and returns a Markdown string.

Think of it like a mail-merge template:

```text
Structured release data
        ↓
Formatter rules
        ↓
Consistent Markdown document
```

The function will validate its input before producing output. Validation means checking that incoming data follows the contract expected by the function.

This protects callers from generating misleading release notes with missing versions, malformed dates, or invalid section data.

## The Implementation

Create the `src` directory.

### macOS, Linux, or Git Bash

```bash
mkdir -p src
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path src -Force
```

Create this file.

### `release-notes-manager/src/releaseNotes.js`

```js
/**
 * Returns true when a value is a non-empty string after trimming whitespace.
 *
 * @param {unknown} value - The value to validate.
 * @returns {boolean} Whether the value is a usable string.
 */
function isNonEmptyString(value) {
  return typeof value === "string" && value.trim().length > 0;
}

/**
 * Validates a date string in YYYY-MM-DD format and confirms that it is a real
 * calendar date. A regular expression alone would accept invalid dates such as
 * 2026-02-31, so the Date check is required as a second safeguard.
 *
 * @param {unknown} value - The date value to validate.
 * @returns {boolean} Whether the value is a valid ISO-like calendar date.
 */
function isValidReleaseDate(value) {
  if (!isNonEmptyString(value)) {
    return false;
  }

  const datePattern = /^\d{4}-\d{2}-\d{2}$/;

  if (!datePattern.test(value)) {
    return false;
  }

  const parsedDate = new Date(`${value}T00:00:00.000Z`);

  // Invalid dates become NaN when converted to a timestamp.
  if (Number.isNaN(parsedDate.getTime())) {
    return false;
  }

  // Rebuild the date in UTC to reject rollover values such as 2026-02-31,
  // which JavaScript would otherwise normalize into a date in March.
  return parsedDate.toISOString().slice(0, 10) === value;
}

/**
 * Validates a release-note section.
 *
 * A missing section is valid because sections are optional. When provided,
 * every entry must be a non-empty string so generated Markdown never contains
 * empty bullet points or non-text values.
 *
 * @param {unknown} value - The candidate section value.
 * @param {string} sectionName - A human-readable section name for errors.
 * @returns {string[]} A trimmed copy of the valid section entries.
 * @throws {TypeError} When the section is not an array of non-empty strings.
 */
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

/**
 * Formats one Markdown section when it contains at least one item.
 *
 * @param {string} heading - The Markdown heading for the section.
 * @param {string[]} entries - The already validated release-note entries.
 * @returns {string[]} Markdown lines for the section, or an empty array.
 */
function formatSection(heading, entries) {
  if (entries.length === 0) {
    return [];
  }

  return [
    `## ${heading}`,
    "",
    ...entries.map((entry) => `- ${entry}`)
  ];
}

/**
 * Converts structured release information into a consistent Markdown document.
 *
 * @param {object} release - The release data to format.
 * @param {string} release.version - A non-empty release version.
 * @param {string} release.releaseDate - A valid date in YYYY-MM-DD format.
 * @param {string[]} [release.added] - New user-visible capabilities.
 * @param {string[]} [release.changed] - Changed existing behavior.
 * @param {string[]} [release.fixed] - Bug fixes.
 * @returns {string} Complete Markdown release notes ending with one newline.
 * @throws {TypeError} When release data does not satisfy the contract.
 */
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

  const sections = [
    formatSection("Added", added),
    formatSection("Changed", changed),
    formatSection("Fixed", fixed)
  ];

  for (const sectionLines of sections) {
    if (sectionLines.length > 0) {
      lines.push("", ...sectionLines);
    }
  }

  return `${lines.join("\n")}\n`;
}
```

Review the file:

```bash
git diff -- src/releaseNotes.js
```

Stage and commit it:

```bash
git add src/releaseNotes.js
git commit -m "Add release note formatter"
```

## The Verification

Run this one-time command from the repository root:

```bash
node --input-type=module --eval "import { formatReleaseNotes } from './src/releaseNotes.js'; console.log(formatReleaseNotes({ version: '1.0.0', releaseDate: '2026-07-25', added: ['Create formatted release notes.'], fixed: ['Correct release date validation.'] }));"
```

Expected output:

```md
# Release 1.0.0

**Release date:** 2026-07-25

## Added

- Create formatted release notes.

## Fixed

- Correct release date validation.
```

Also verify a validation error:

```bash
node --input-type=module --eval "import { formatReleaseNotes } from './src/releaseNotes.js'; formatReleaseNotes({ version: '', releaseDate: '2026-07-25' });"
```

Expected output includes:

```text
TypeError: release.version must be a non-empty string.
```

---

# Step 7: Add Automated Tests

## The Target

Create unit tests for successful formatting and invalid input handling.

## The Concept

A **unit test** checks one small unit of behavior automatically.

Think of a test as a repeatable checklist. Instead of manually checking the formatter every time someone changes it, the test runner checks the expected behavior in seconds.

Your tests will verify that the formatter:

- Includes populated sections.
- Omits empty sections.
- Rejects missing or malformed values.
- Rejects invalid calendar dates.
- Rejects invalid section entries.

## The Implementation

Create this file.

### `release-notes-manager/src/releaseNotes.test.js`

```js
import assert from "node:assert/strict";
import test from "node:test";
import { formatReleaseNotes } from "./releaseNotes.js";

test("formats release notes with populated sections", () => {
  const markdown = formatReleaseNotes({
    version: "1.0.0",
    releaseDate: "2026-07-25",
    added: ["Create formatted release notes."],
    changed: ["Improve documentation structure."],
    fixed: ["Correct release date validation."]
  });

  assert.equal(
    markdown,
    `# Release 1.0.0

**Release date:** 2026-07-25

## Added

- Create formatted release notes.

## Changed

- Improve documentation structure.

## Fixed

- Correct release date validation.
`
  );
});

test("omits empty and missing sections", () => {
  const markdown = formatReleaseNotes({
    version: "1.1.0",
    releaseDate: "2026-08-01",
    added: [],
    fixed: ["Correct a formatting issue."]
  });

  assert.equal(
    markdown,
    `# Release 1.1.0

**Release date:** 2026-08-01

## Fixed

- Correct a formatting issue.
`
  );

  assert.doesNotMatch(markdown, /## Added/);
  assert.doesNotMatch(markdown, /## Changed/);
});

test("trims version and section entries", () => {
  const markdown = formatReleaseNotes({
    version: " 2.0.0 ",
    releaseDate: "2026-09-15",
    added: ["  Add a trimmed entry.  "]
  });

  assert.match(markdown, /^# Release 2\.0\.0$/m);
  assert.match(markdown, /- Add a trimmed entry\./);
});

test("rejects a missing release object", () => {
  assert.throws(
    () => formatReleaseNotes(null),
    {
      name: "TypeError",
      message: "release must be an object."
    }
  );
});

test("rejects an empty version", () => {
  assert.throws(
    () =>
      formatReleaseNotes({
        version: "   ",
        releaseDate: "2026-07-25"
      }),
    {
      name: "TypeError",
      message: "release.version must be a non-empty string."
    }
  );
});

test("rejects malformed and impossible release dates", () => {
  assert.throws(
    () =>
      formatReleaseNotes({
        version: "1.0.0",
        releaseDate: "07-25-2026"
      }),
    {
      name: "TypeError",
      message:
        "release.releaseDate must be a valid date in YYYY-MM-DD format."
    }
  );

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

test("rejects invalid section values", () => {
  assert.throws(
    () =>
      formatReleaseNotes({
        version: "1.0.0",
        releaseDate: "2026-07-25",
        added: "This should be an array."
      }),
    {
      name: "TypeError",
      message: "release.added must be an array of non-empty strings."
    }
  );

  assert.throws(
    () =>
      formatReleaseNotes({
        version: "1.0.0",
        releaseDate: "2026-07-25",
        fixed: ["A valid entry.", ""]
      }),
    {
      name: "TypeError",
      message: "release.fixed[1] must be a non-empty string."
    }
  );
});
```

Run the tests:

```bash
npm test
```

Stage and commit the tests:

```bash
git add src/releaseNotes.test.js
git commit -m "Test release note formatter"
```

## The Verification

Expected test output resembles:

```text
# tests 6
# pass 6
# fail 0
```

Run:

```bash
git status
```

Expected output:

```text
On branch feature/add-release-formatter
nothing to commit, working tree clean
```

---

# Step 8: Document Formatter Usage

## The Target

Add a clear usage section to `README.md`.

## The Concept

Code without usage documentation is like a tool without instructions. The formatter’s contract should be visible to future contributors without requiring them to read the implementation.

You will document:

- How to run tests.
- How to import the formatter.
- The input shape.
- The expected Markdown result.

## The Implementation

Append this complete section to `README.md`:

### `release-notes-manager/README.md` — append this section

```md
## Release Note Formatter

The project includes a small JavaScript formatter that converts structured release data into Markdown.

### Run Tests

Install Node.js 18 or newer, then run:

```bash
npm test
```

### Usage

```js
import { formatReleaseNotes } from "./src/releaseNotes.js";

const markdown = formatReleaseNotes({
  version: "1.0.0",
  releaseDate: "2026-07-25",
  added: ["Create formatted release notes."],
  changed: ["Improve documentation structure."],
  fixed: ["Correct release date validation."]
});

console.log(markdown);
```

The formatter requires a non-empty `version` and a real calendar date in `YYYY-MM-DD` format. The `added`, `changed`, and `fixed` arrays are optional. Empty sections are omitted from the generated Markdown.
```

Review the change:

```bash
git diff -- README.md
```

Run tests again:

```bash
npm test
```

Stage and commit:

```bash
git add README.md
git commit -m "Document release note formatter"
```

## The Verification

Confirm the branch history contains focused commits:

```bash
git log --oneline main..HEAD
```

Expected output resembles:

```text
<hash> Document release note formatter
<hash> Test release note formatter
<hash> Add release note formatter
<hash> Add Node.js test configuration
```

Run:

```bash
npm test
git status
```

Tests must pass and the working tree must be clean before opening the pull request.

---

# Step 9: Push the Feature Branch and Open a Draft Pull Request

## The Target

Publish the feature branch and create a draft pull request linked to the issue.

## The Concept

A **pull request** is a request to merge changes from one branch into another.

It is not merely a button to merge code. It is a shared workspace for:

- Explaining why a change exists.
- Reviewing code.
- Running automated checks.
- Asking questions.
- Recording decisions.
- Linking related issues.

A **draft pull request** communicates:

> “This work is visible and ready for early feedback, but it is not ready to merge yet.”

Draft PRs are useful when you want design feedback before finishing documentation, tests, or edge cases.

## The Implementation

Push the branch and create its upstream relationship:

```bash
git push -u origin feature/add-release-formatter
```

On GitHub, open your repository. GitHub should display a **Compare & pull request** prompt. Select it.

If it does not appear:

1. Open the **Pull requests** tab.
2. Select **New pull request**.
3. Set the base branch to:

   ```text
   main
   ```

4. Set the compare branch to:

   ```text
   feature/add-release-formatter
   ```

5. Select **Create draft pull request**.

Use this title:

```text
Add release note formatter
```

Use this complete pull request body. Replace `ISSUE_NUMBER` with your real issue number.

```md
## Summary

Adds a validated JavaScript formatter for converting structured release data into consistent Markdown release notes.

Closes #ISSUE_NUMBER

## Changes

- Add Node.js test configuration.
- Add `formatReleaseNotes` in `src/releaseNotes.js`.
- Validate required version and release-date values.
- Support optional Added, Changed, and Fixed sections.
- Add unit tests for expected output and invalid inputs.
- Document formatter usage in `README.md`.

## Verification

```bash
npm test
```

Expected result:

```text
# pass 6
# fail 0
```

## Review Notes

Please pay particular attention to:

- Date validation behavior.
- Error-message clarity.
- Whether the Markdown output format is easy to read.
```

Request a review from a collaborator if you have one.

## The Verification

On the pull request page, confirm:

- Base branch is `main`.
- Compare branch is `feature/add-release-formatter`.
- The PR is marked **Draft**.
- The issue link appears as:

  ```text
  Closes #ISSUE_NUMBER
  ```

- The **Files changed** tab includes:
  - `package.json`
  - `src/releaseNotes.js`
  - `src/releaseNotes.test.js`
  - `README.md`

---

# Step 10: Review the Pull Request

## The Target

Perform a structured review of the formatter pull request.

## The Concept

A useful review is not a vague “looks good.” It checks whether the change meets its requirements and whether it creates avoidable risk.

Think of code review as inspecting a bridge before it opens. You are not only checking whether the paint looks good; you are checking whether the design fulfills the purpose safely.

A practical review checks:

1. **Correctness** — Does it satisfy the issue’s acceptance criteria?
2. **Tests** — Do tests cover normal behavior and important failures?
3. **Clarity** — Can another developer understand it later?
4. **Scope** — Does the PR avoid unrelated changes?
5. **Security** — Does it expose secrets or unsafe behavior?
6. **Maintainability** — Are names, errors, and boundaries clear?

## The Implementation

On GitHub, open the pull request’s **Files changed** tab.

Review these areas:

### Review `package.json`

Confirm:

- The project is private.
- The test command is deterministic.
- No unnecessary dependencies were added.

### Review `src/releaseNotes.js`

Confirm:

- `release` must be an object.
- `version` must be a non-empty string.
- `releaseDate` requires `YYYY-MM-DD`.
- Impossible dates such as `2026-02-31` are rejected.
- Optional sections are omitted when absent or empty.
- No user-provided value is executed as code.

### Review `src/releaseNotes.test.js`

Confirm tests cover:

- Standard formatting.
- Missing sections.
- Trimming.
- Missing input.
- Empty version.
- Invalid date format.
- Impossible calendar date.
- Invalid section types and entries.

Add at least one review comment as practice. For example, select the line in `releaseNotes.js` containing:

```js
return parsedDate.toISOString().slice(0, 10) === value;
```

Then leave this comment:

```text
Good safeguard: this prevents JavaScript date rollover from accepting impossible calendar dates such as 2026-02-31.
```

If you have a collaborator, ask them to submit a real approval. If you are working alone, self-review every checklist item and use GitHub’s available administrative bypass only if required by your branch-protection configuration.

## The Verification

Confirm the pull request shows:

- At least one review comment or review note.
- All acceptance criteria are visibly satisfied.
- No unrelated files changed.
- `npm test` succeeded locally.

If you requested review from another account, wait for or obtain an approval before continuing.

---

# Step 11: Simulate Branch Drift from `main`

## The Target

Create a new commit on `main` after the pull request branch was created, then update the feature branch.

## The Concept

**Branch drift** happens when `main` moves forward while your feature branch is still open.

This is normal on active teams.

Before drift:

```text
main → A
feature/add-release-formatter → B → C → D
```

After someone merges another change into `main`:

```text
main → A → E
feature/add-release-formatter → B → C → D
```

Your pull request is now behind `main`. GitHub may show a message such as:

```text
This branch is out-of-date with the base branch.
```

You should update the feature branch before merging, especially when branch protection requires it.

## The Implementation

To simulate another teammate’s change, create a branch from current `main`.

First, in your terminal, preserve the PR branch state and switch to `main`:

```bash
git switch main
git pull --ff-only
git switch -c docs/add-review-guidelines
```

Create this file.

### `release-notes-manager/CODE_REVIEW.md`

```md
# Code Review Guidelines

Use these guidelines when reviewing a pull request.

## Review Checklist

- [ ] The pull request has a clear purpose.
- [ ] The implementation meets the linked issue acceptance criteria.
- [ ] Automated tests pass.
- [ ] New behavior has appropriate test coverage.
- [ ] Error handling is clear and safe.
- [ ] No secrets, generated files, or unrelated changes are included.
- [ ] Documentation reflects user-visible behavior.

## Feedback Style

- Ask questions when intent is unclear.
- Explain the reason for requested changes.
- Distinguish blocking issues from optional suggestions.
- Focus feedback on the code and outcome, not the person.
```

Commit and push the branch:

```bash
git add CODE_REVIEW.md
git commit -m "Add code review guidelines"
git push -u origin docs/add-review-guidelines
```

Open a pull request from `docs/add-review-guidelines` into `main`.

Use:

```text
Add code review guidelines
```

as the title, and this body:

```md
## Summary

Adds a lightweight review checklist and feedback guidance for contributors.

## Verification

Reviewed the Markdown file for complete checklist items and clear language.
```

Merge this documentation PR into `main` through GitHub.

After it is merged, delete the `docs/add-review-guidelines` branch through GitHub if offered.

Now return locally to the formatter branch:

```bash
git fetch origin
git switch feature/add-release-formatter
git status
```

## The Verification

Your status should indicate that the branch is behind or has diverged from `origin/main`, depending on your exact merge method:

```bash
git log --oneline --decorate --graph --all -10
```

You should see a newer `origin/main` commit similar to:

```text
Add code review guidelines
```

---

# Step 12: Update the Pull Request Branch with the Latest `main`

## The Target

Integrate the latest `main` changes into the feature branch safely.

## The Concept

There are two common ways to update a feature branch:

### Option A: Merge `main` into the feature branch

```bash
git merge origin/main
```

This preserves historical branch structure and does not rewrite existing feature commits.

### Option B: Rebase the feature branch onto `main`

```bash
git rebase origin/main
```

This creates new versions of the feature commits on top of the latest `main`.

For a branch already pushed to GitHub, rebasing requires a force push afterward because the commit hashes change:

```bash
git push --force-with-lease
```

`--force-with-lease` is safer than plain `--force`. It refuses to overwrite remote commits you do not have locally.

For this tutorial, use a merge because it is the safer default for a shared pull-request branch.

## The Implementation

Ensure you are on the feature branch:

```bash
git branch --show-current
```

Expected:

```text
feature/add-release-formatter
```

Fetch GitHub state:

```bash
git fetch origin
```

Merge the current remote `main` into your feature branch:

```bash
git merge origin/main
```

If Git opens an editor, keep the default merge message, save, and close.

Run tests:

```bash
npm test
```

Push the updated feature branch:

```bash
git push
```

## The Verification

Inspect the graph:

```bash
git log --oneline --decorate --graph --all -12
```

You should see both the release formatter commits and the `Add code review guidelines` commit reachable from the feature branch.

Confirm tests still pass:

```bash
npm test
```

On GitHub, refresh the formatter PR. The “out-of-date” warning should be gone.

---

# Step 13: Resolve a Pull Request Conflict Locally

## The Target

Learn the full local resolution workflow for a pull-request merge conflict.

## The Concept

A pull request conflict occurs when GitHub cannot automatically combine the PR branch and the base branch.

The safest general process is:

```text
Fetch the latest remote state
   ↓
Switch to the feature branch
   ↓
Merge or rebase the latest main
   ↓
Resolve conflict markers
   ↓
Test
   ↓
Commit resolution if merging
   ↓
Push branch
```

GitHub can resolve simple conflicts in the web interface, but local resolution is usually better when:

- The conflict is complex.
- You need to run tests.
- Multiple files are involved.
- You need editor support.
- You need to understand broader application context.

## The Implementation

Your formatter PR should not conflict because the drift change added a different file. Therefore, do not manufacture another conflict in the repository.

Use this exact workflow if Git reports a conflict during a future merge of `origin/main`:

```bash
git fetch origin
git switch feature/add-release-formatter
git merge origin/main
```

If Git reports conflicts:

```bash
git status
```

Open each conflicted file. Git will include markers similar to:

```text
<<<<<<< HEAD
Content from the feature branch.
=======
Content from main.
>>>>>>> origin/main
```

Replace the marked region with the intended final content and remove all markers.

Then run:

```bash
git diff --check
git add <resolved-file-path>
git status
npm test
git commit
git push
```

If you started the merge by mistake and need to return to the pre-merge state:

```bash
git merge --abort
```

## The Verification

For your actual repository, verify it remains healthy:

```bash
git status
npm test
```

Expected output:

```text
On branch feature/add-release-formatter
nothing to commit, working tree clean
```

And test results should show:

```text
# fail 0
```

---

# Step 14: Mark the Pull Request Ready and Merge It

## The Target

Move the draft pull request to ready status, ensure requirements pass, and merge it into `main`.

## The Concept

A pull request should become ready only when:

- Its intended implementation is complete.
- Tests pass.
- Documentation is updated.
- The branch is current enough for project rules.
- Review comments are resolved.
- Required approvals are present.

GitHub offers several merge strategies:

| Strategy | Result |
|---|---|
| Merge commit | Preserves every commit and adds a merge commit. |
| Squash and merge | Combines PR commits into one commit on `main`. |
| Rebase and merge | Replays each PR commit onto `main` without a merge commit. |

For small, focused PRs, **Squash and merge** is commonly used because it keeps `main` history concise.

For this tutorial, use **Squash and merge** if the option is available and aligns with your repository settings.

## The Implementation

On GitHub:

1. Open the formatter pull request.
2. Select **Ready for review**.
3. Confirm:
   - All conversations are resolved.
   - Required checks pass.
   - The branch is up to date.
   - Required approvals are present or administrative rules have been satisfied.
4. Select the merge dropdown.
5. Choose **Squash and merge**.
6. Use this final commit title:

   ```text
   Add release note formatter
   ```

7. Use this commit message body:

   ```text
   Add validated Markdown release-note formatting, unit tests, Node.js test configuration, and usage documentation.
   ```

8. Confirm the squash merge.
9. Select **Delete branch** when GitHub offers it.

Because the PR description included:

```md
Closes #ISSUE_NUMBER
```

GitHub should close the linked issue automatically after merge.

## The Verification

On GitHub, confirm:

- The pull request shows **Merged**.
- The linked issue is closed.
- The feature branch is deleted from GitHub.
- `main` includes:
  - `package.json`
  - `src/releaseNotes.js`
  - `src/releaseNotes.test.js`
  - Updated `README.md`

Update local `main`:

```bash
git switch main
git pull --ff-only
git branch -d feature/add-release-formatter
git fetch --prune
```

`git fetch --prune` removes stale remote-tracking references for branches deleted on GitHub.

Verify:

```bash
git status
git branch --all
npm test
git log --oneline --decorate -5
```

Expected status:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

---

# Step 15: Create Labels for Work Classification

## The Target

Create a consistent label system for categorizing GitHub Issues and pull requests.

## The Concept

Labels are like colored filing tabs. They make it easier to answer questions such as:

- Which issues are bugs?
- Which items are ready for contributors?
- Which tasks affect documentation?
- Which work is urgent?
- Which issues need clarification?

A small, consistent label system is better than dozens of overlapping labels.

## The Implementation

On GitHub:

1. Open the **Issues** tab.
2. Select **Labels**.
3. Create these labels.

| Name | Suggested color | Description |
|---|---:|---|
| `bug` | `D73A4A` | Something is not working as intended. |
| `enhancement` | `A2EEEF` | A new capability or improvement. |
| `documentation` | `0075CA` | Documentation-only work. |
| `good first issue` | `7057FF` | A scoped task suitable for a new contributor. |
| `help wanted` | `008672` | Additional contributor help is welcome. |
| `priority: high` | `B60205` | Important work that needs prompt attention. |
| `priority: medium` | `FBCA04` | Important but not urgent work. |
| `priority: low` | `0E8A16` | Useful work that can wait. |
| `needs triage` | `EDEDED` | Needs initial classification or clarification. |
| `blocked` | `5319E7` | Cannot proceed until a dependency or decision is resolved. |

Apply labels to existing work:

- Apply `enhancement` and `documentation` to the formatter issue if it remains visible in issue history.
- Apply `documentation` to the code-review-guidelines PR or issue if you created one.

## The Verification

Open the **Labels** page and confirm all labels exist.

Open an issue and verify that labels appear beside its title.

---

# Step 16: Create a Milestone

## The Target

Create a milestone to group work planned for the project’s first release.

## The Concept

A **milestone** groups related issues and pull requests toward a shared deadline or release goal.

Think of it as a project checkpoint. Labels describe the type of work; milestones describe the larger delivery target.

For this tutorial, create a milestone for version `1.0.0`.

## The Implementation

On GitHub:

1. Open **Issues**.
2. Select **Milestones**.
3. Select **New milestone**.
4. Enter this title:

   ```text
   v1.0.0 — First formatter release
   ```

5. Use this description:

   ```md
   Deliver the first stable version of Release Notes Manager with documented release-note formatting, automated tests, code review guidance, and continuous integration.
   ```

6. Set a due date if you want to practice scheduling. Choose a realistic date in the future.
7. Create the milestone.

Create these issues and assign each to the milestone:

### Issue 1

Title:

```text
Add continuous integration for tests
```

Body:

```md
## Summary

Run the Node.js test suite automatically for pull requests and pushes to `main`.

## Acceptance Criteria

- [ ] Add a GitHub Actions workflow.
- [ ] Run `npm test`.
- [ ] Use a supported Node.js version.
- [ ] Run for pull requests targeting `main`.
- [ ] Run for pushes to `main`.
```

Labels:

```text
enhancement
priority: high
```

### Issue 2

Title:

```text
Add formatter examples for empty sections
```

Body:

```md
## Summary

Document expected formatter output when optional Added, Changed, or Fixed sections are empty.

## Acceptance Criteria

- [ ] Add an example to `README.md`.
- [ ] Explain that empty sections are omitted.
- [ ] Verify examples match the formatter behavior.
```

Labels:

```text
documentation
priority: medium
good first issue
```

### Issue 3

Title:

```text
Document project contribution workflow
```

Body:

```md
## Summary

Create contribution documentation explaining branch naming, pull requests, tests, and review expectations.

## Acceptance Criteria

- [ ] Add `CONTRIBUTING.md`.
- [ ] Explain how to create a feature branch.
- [ ] Explain how to run tests.
- [ ] Explain pull request expectations.
- [ ] Link to `CODE_REVIEW.md`.
```

Labels:

```text
documentation
priority: medium
```

## The Verification

Open the milestone page.

Confirm it lists the issues you created and displays a progress indicator.

---

# Step 17: Create a GitHub Project Board

## The Target

Create a GitHub Project to visualize and manage work status.

## The Concept

GitHub Projects provides a board or table view over issues and pull requests.

Think of it as a shared whiteboard with columns for the lifecycle of work:

```text
Backlog → Ready → In Progress → In Review → Done
```

Issues explain the work. Pull requests contain implementation and review. A Project shows where each piece of work is in the overall process.

## The Implementation

On GitHub:

1. Open your profile or organization’s **Projects** area.
2. Select **New project**.
3. Choose the **Board** template.
4. Name it:

   ```text
   Release Notes Manager Roadmap
   ```

5. Add or rename columns to exactly these names:

   ```text
   Backlog
   Ready
   In Progress
   In Review
   Done
   ```

6. Add the three milestone issues from the previous step.
7. Move them into columns:

   | Issue | Initial status |
   |---|---|
   | Add continuous integration for tests | Ready |
   | Add formatter examples for empty sections | Backlog |
   | Document project contribution workflow | Backlog |

8. Add the merged formatter issue or PR to **Done** if GitHub allows it.

## The Verification

Confirm the board displays cards in the intended columns.

Your board should resemble:

```text
Backlog
├── Add formatter examples for empty sections
└── Document project contribution workflow

Ready
└── Add continuous integration for tests

In Progress
└── (empty)

In Review
└── (empty)

Done
└── Add release note formatter
```

---

# Part 4 Reference: Pull Request Quality Checklist

Before requesting review, confirm:

```text
Scope
[ ] The branch solves one focused problem.
[ ] The PR title describes the outcome.
[ ] Unrelated formatting or refactoring changes are excluded.

Implementation
[ ] The linked issue acceptance criteria are met.
[ ] Input validation and error handling are appropriate.
[ ] No secrets or generated files are included.

Testing
[ ] Automated tests pass locally.
[ ] New behavior has tests.
[ ] Important failure cases have tests.

Documentation
[ ] README or user documentation is updated when behavior changes.
[ ] The PR description explains why the change exists.
[ ] Verification steps are included.

Collaboration
[ ] The branch is reasonably current with main.
[ ] Review comments are resolved.
[ ] Required approvals are present.
```

---

# Part 4 Reference: Common Collaboration Commands

```bash
git switch main
git pull --ff-only
```

Update local `main` safely before starting work.

```bash
git switch -c feature/short-description
```

Create a focused feature branch.

```bash
git push -u origin feature/short-description
```

Publish a new branch and set its upstream.

```bash
git fetch origin
```

Download remote state without modifying local files.

```bash
git merge origin/main
```

Merge the latest remote `main` into the current feature branch.

```bash
git merge --abort
```

Cancel a merge that is currently in progress.

```bash
git push --force-with-lease
```

Safely force-push rewritten history only when necessary, such as after rebasing your own feature branch. Never substitute this casually with `git push --force`.

```bash
git fetch --prune
```

Refresh remote references and remove references to remote branches that no longer exist.

---

# Part 4 Completion Checklist

Before continuing to advanced Git and automation, confirm all of the following:

- [ ] You understand GitHub Flow.
- [ ] `main` is protected through GitHub rules or branch protection.
- [ ] You created an issue with acceptance criteria.
- [ ] You created a feature branch from an updated `main`.
- [ ] You added `package.json`, formatter code, tests, and documentation.
- [ ] `npm test` passes.
- [ ] You opened a draft pull request linked to an issue.
- [ ] You reviewed changed files and left useful review feedback.
- [ ] You updated a feature branch after `main` moved forward.
- [ ] You understand when local conflict resolution is preferable to web-based resolution.
- [ ] You merged a reviewed pull request and deleted its branch.
- [ ] You created labels, a milestone, and a Project board.
- [ ] Your local `main` is clean and synchronized with `origin/main`.
