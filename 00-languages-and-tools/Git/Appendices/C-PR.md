# Appendix C: Pull Request, Issue, and Code Review Templates

This appendix provides copy-pasteable templates for the collaboration work introduced in Part 4.

Templates reduce avoidable ambiguity. They are like standardized forms at a hospital: the form does not replace professional judgment, but it makes sure important information is not forgotten.

Use these templates as a starting point, then adapt them to your repository’s needs.

---

## C.1 Why Use GitHub Templates?

### The Target

Understand why issue forms, issue templates, pull request templates, and review checklists improve team collaboration.

### The Concept

A pull request without context forces reviewers to guess:

```text
What problem does this solve?
Why was this approach chosen?
How was it tested?
Are there risks?
What should I look at closely?
```

An issue without acceptance criteria creates a similar problem:

```text
What does “done” mean?
Which edge cases matter?
Is this a bug, a feature, or a question?
```

Templates make the important questions visible every time.

They help contributors write better requests and help reviewers provide better feedback.

---

# C.2 Add a Pull Request Template

## The Target

Create a repository-wide pull request template that GitHub preloads for new pull requests.

## The Concept

A pull request template is a reusable checklist and context form.

GitHub recognizes this file location:

```text
.github/pull_request_template.md
```

When someone opens a pull request, GitHub inserts the file contents into the PR description automatically.

The template should encourage clear communication without becoming so long that contributors delete it.

## The Implementation

Create the template directory if it does not already exist.

### macOS, Linux, or Git Bash

```bash
mkdir -p .github
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path .github -Force
```

Create the following file.

### `release-notes-manager/.github/pull_request_template.md`

```md
## Summary

Describe the user-visible or developer-visible outcome of this pull request.

Closes #ISSUE_NUMBER

## Changes

- Describe the first meaningful change.
- Describe the second meaningful change.
- Describe any documentation, test, or configuration updates.

## Verification

List the exact commands or manual checks used to verify this change.

```bash
npm test
```

## Review Focus

Tell reviewers where you would like extra attention.

- [ ] Input validation and error handling
- [ ] Tests and edge cases
- [ ] Documentation accuracy
- [ ] Security and secret handling
- [ ] Backward compatibility

## Checklist

- [ ] I kept this pull request focused on one purpose.
- [ ] I reviewed my own diff.
- [ ] I added or updated tests where behavior changed.
- [ ] All relevant tests pass locally.
- [ ] I updated documentation where needed.
- [ ] I did not include secrets, generated files, or unrelated changes.
```

Review the new template:

```bash
git diff -- .github/pull_request_template.md
```

Run the existing test suite:

```bash
npm test
```

Commit the template:

```bash
git add .github/pull_request_template.md
git commit -m "Add pull request template"
```

Push the branch if you are working on a feature branch:

```bash
git push
```

If you are currently on `main`, use a feature branch and pull request instead:

```bash
git switch -c docs/add-pull-request-template
git push -u origin docs/add-pull-request-template
```

Then open a pull request and merge through the protected-branch workflow.

## The Verification

On GitHub:

1. Open **Pull requests**.
2. Select **New pull request**.
3. Choose any temporary compare branch.
4. Confirm the description field is prefilled with the template sections.

Do not create a meaningless PR merely for verification. If no branch is available, confirm the file exists at:

```text
.github/pull_request_template.md
```

GitHub will use it for the next real pull request.

---

# C.3 Add a Bug Report Issue Template

## The Target

Create a structured bug-report template.

## The Concept

A bug report should help another person reproduce the problem.

“Something is broken” is not enough information to diagnose a problem. A useful report explains what happened, what should have happened, and how to repeat the behavior.

GitHub recognizes issue templates in:

```text
.github/ISSUE_TEMPLATE/
```

## The Implementation

Create the template directory.

### macOS, Linux, or Git Bash

```bash
mkdir -p .github/ISSUE_TEMPLATE
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path ".github\ISSUE_TEMPLATE" -Force
```

Create the following file.

### `release-notes-manager/.github/ISSUE_TEMPLATE/bug_report.md`

```md
---
name: Bug report
about: Report behavior that does not work as expected
title: "[Bug]: "
labels: bug, needs triage
assignees: ""
---

## Summary

Provide a short description of the problem.

## Steps to Reproduce

1. Start from this project state:
2. Run this command or perform this action:
3. Provide this input:
4. Observe the result:

## Expected Behavior

Describe what should have happened.

## Actual Behavior

Describe what happened instead.

## Relevant Output

Paste errors, test output, or screenshots here.

```text
Paste relevant output here.
```

## Environment

- Operating system:
- Node.js version:
- npm version:
- Git version:
- Branch or commit hash:

## Additional Context

Add any other information that could help reproduce or diagnose the problem.

## Checklist

- [ ] I searched existing issues before creating this report.
- [ ] I removed passwords, API keys, tokens, and other secrets from logs or screenshots.
- [ ] I included enough detail for another contributor to reproduce the issue.
```

Commit the template:

```bash
git add .github/ISSUE_TEMPLATE/bug_report.md
git commit -m "Add bug report template"
```

## The Verification

On GitHub:

1. Open the **Issues** tab.
2. Select **New issue**.
3. Confirm that **Bug report** appears as a selectable template.
4. Select it.
5. Confirm the issue body is prefilled with the structured sections.

If GitHub does not show the template immediately, confirm the file is committed and pushed to the repository’s default branch.

---

# C.4 Add a Feature Request Issue Template

## The Target

Create a feature-request template that captures user value and acceptance criteria.

## The Concept

A feature request should not begin and end with a solution.

For example, this request is too narrow:

```text
Add a blue export button.
```

A better request explains the desired outcome:

```text
Users need a reliable way to export release notes for publishing outside GitHub.
```

Once the problem is clear, the team can choose the best solution.

## The Implementation

Create this file.

### `release-notes-manager/.github/ISSUE_TEMPLATE/feature_request.md`

```md
---
name: Feature request
about: Suggest a new capability or improvement
title: "[Feature]: "
labels: enhancement, needs triage
assignees: ""
---

## Problem

What user, contributor, or project problem should this feature solve?

## Proposed Outcome

Describe the intended result without assuming one specific technical implementation.

## Example Workflow

Describe how someone would use the feature.

1. A user does this:
2. The application or project responds:
3. The user receives this outcome:

## Acceptance Criteria

- [ ] Describe one observable requirement.
- [ ] Describe another observable requirement.
- [ ] Include validation or error behavior when relevant.
- [ ] Include documentation updates when relevant.
- [ ] Include test expectations when behavior changes.

## Alternatives Considered

Describe any other approaches, workarounds, or existing tools considered.

## Additional Context

Add mockups, examples, links, or implementation constraints.

## Checklist

- [ ] I searched existing issues before requesting this feature.
- [ ] I described the problem and desired outcome.
- [ ] I included clear acceptance criteria.
```

Commit it:

```bash
git add .github/ISSUE_TEMPLATE/feature_request.md
git commit -m "Add feature request template"
```

## The Verification

On GitHub:

1. Select **Issues**.
2. Select **New issue**.
3. Confirm **Feature request** appears as a selectable template.
4. Confirm selecting it preloads the expected sections.

---

# C.5 Add a Documentation Issue Template

## The Target

Create a focused issue template for documentation work.

## The Concept

Documentation issues are often small and approachable for new contributors. A dedicated template helps contributors identify:

- Which document needs improvement.
- Who the document is for.
- What knowledge is missing or unclear.
- How to verify the improved explanation.

## The Implementation

Create this file.

### `release-notes-manager/.github/ISSUE_TEMPLATE/documentation.md`

```md
---
name: Documentation improvement
about: Report missing, unclear, incorrect, or outdated documentation
title: "[Docs]: "
labels: documentation, needs triage
assignees: ""
---

## Documentation Location

Identify the file, page, section, or URL that needs attention.

## Current Problem

Explain what is missing, unclear, incorrect, or outdated.

## Intended Audience

Who needs this documentation?

Examples:

- New contributors
- Project maintainers
- Release managers
- Application users

## Suggested Improvement

Describe the information, example, or clarification that should be added.

## Acceptance Criteria

- [ ] The documentation explains the relevant concept or workflow clearly.
- [ ] Commands and code examples are accurate.
- [ ] The change is appropriate for the intended audience.
- [ ] Links and file paths are valid.

## Additional Context

Add screenshots, links, or examples from similar documentation.
```

Commit it:

```bash
git add .github/ISSUE_TEMPLATE/documentation.md
git commit -m "Add documentation issue template"
```

## The Verification

Open the GitHub issue creation page and confirm the documentation template appears.

---

# C.6 Add an Issue Template Config File

## The Target

Add an issue-template configuration file that gives contributors a clear path for security concerns and general questions.

## The Concept

Not every report belongs in a public issue.

Security vulnerabilities should not be disclosed publicly before maintainers can investigate and respond. A configuration file lets you show links outside the standard issue templates.

## The Implementation

Create this file.

### `release-notes-manager/.github/ISSUE_TEMPLATE/config.yml`

```yaml
blank_issues_enabled: false
contact_links:
  - name: Security vulnerability report
    url: https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager/security/advisories/new
    about: Please report potential security vulnerabilities privately through GitHub Security Advisories.
  - name: Project documentation
    url: https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager/blob/main/README.md
    about: Read the project documentation before opening a general question.
```

Replace:

```text
YOUR_GITHUB_USERNAME
```

with your actual GitHub username.

Commit the configuration:

```bash
git add .github/ISSUE_TEMPLATE/config.yml
git commit -m "Configure issue templates"
```

## The Verification

On GitHub:

1. Select **Issues**.
2. Select **New issue**.
3. Confirm that blank issues are unavailable.
4. Confirm the available templates include:
   - Bug report
   - Feature request
   - Documentation improvement
5. Confirm that the page includes links for:
   - Security vulnerability reporting
   - Project documentation

---

# C.7 Add a Code Review Checklist

## The Target

Extend `CODE_REVIEW.md` with a practical checklist for reviewers and authors.

## The Concept

A review checklist keeps attention on high-impact concerns.

It does not mean every change requires an exhaustive security audit. A one-line documentation correction needs less scrutiny than authentication or payment code. Still, every pull request benefits from consistent review habits.

## The Implementation

Replace the complete contents of `CODE_REVIEW.md` with the following version.

### `release-notes-manager/CODE_REVIEW.md`

```md
# Code Review Guidelines

Use these guidelines when reviewing a pull request.

## Review Checklist

### Purpose and Scope

- [ ] The pull request has a clear purpose.
- [ ] The pull request is focused and avoids unrelated changes.
- [ ] The linked issue acceptance criteria are met.

### Correctness

- [ ] The implementation handles expected input correctly.
- [ ] Error messages are accurate and useful.
- [ ] Edge cases are considered where relevant.
- [ ] Existing behavior is not unintentionally changed.

### Tests

- [ ] Automated tests pass.
- [ ] New behavior has appropriate test coverage.
- [ ] Important failure paths are tested.
- [ ] Tests are deterministic and do not depend on local machine state.

### Security and Privacy

- [ ] No passwords, API keys, tokens, private keys, or `.env` files are included.
- [ ] Input validation is appropriate for the feature.
- [ ] The change does not introduce unnecessary permissions or unsafe defaults.
- [ ] Logs and error messages do not expose sensitive information.

### Maintainability

- [ ] Names explain intent.
- [ ] Complex logic has comments explaining why it exists.
- [ ] The code avoids unnecessary duplication.
- [ ] Documentation reflects user-visible behavior.

### Collaboration

- [ ] Feedback is specific, respectful, and actionable.
- [ ] Blocking feedback is clearly identified.
- [ ] Optional suggestions are marked as non-blocking.
- [ ] Required continuous integration checks pass before merging.

## Feedback Style

- Ask questions when intent is unclear.
- Explain the reason for requested changes.
- Distinguish blocking issues from optional suggestions.
- Focus feedback on the code and outcome, not the person.
- Assume positive intent and use respectful language.

## Suggested Review Labels

Use these prefixes when writing review comments:

- `blocking:` A change is required before merge.
- `question:` Clarification is needed.
- `suggestion:` An optional improvement.
- `nit:` A minor non-blocking style detail.
- `praise:` Acknowledge a strong implementation or useful decision.
```

Run tests to ensure no unrelated project behavior changed:

```bash
npm test
```

Commit the update:

```bash
git add CODE_REVIEW.md
git commit -m "Expand code review checklist"
```

## The Verification

Review the rendered Markdown file on GitHub.

Confirm that it has separate sections for:

- Purpose and scope.
- Correctness.
- Tests.
- Security and privacy.
- Maintainability.
- Collaboration.
- Feedback style.

---

# C.8 Pull Request Description Examples

## The Target

Learn how to write useful PR descriptions for common types of changes.

## The Concept

Different changes need different context. A bug fix should explain reproduction and regression coverage. A feature should explain the outcome and acceptance criteria. A refactor should explain what behavior intentionally remains unchanged.

---

## Example: Feature Pull Request

```md
## Summary

Adds CSV export support for formatted release notes.

Closes #42

## Changes

- Add `exportReleaseNotesCsv` utility.
- Validate release-note rows before export.
- Add tests for empty sections and CSV escaping.
- Document CSV export usage in `README.md`.

## Verification

```bash
npm test
```

Manual check:

```bash
node --input-type=module --eval "import { exportReleaseNotesCsv } from './src/exportReleaseNotes.js'; console.log(exportReleaseNotesCsv([{ version: '1.0.0', releaseDate: '2026-07-25' }]));"
```

## Review Focus

Please review CSV escaping behavior for commas, quotes, and line breaks.
```

---

## Example: Bug-Fix Pull Request

```md
## Summary

Fixes invalid leap-day validation for release dates.

Closes #58

## Root Cause

The date validator accepted a calendar rollover in one edge case instead of confirming that the parsed date matched the original input.

## Changes

- Compare the normalized UTC date against the original `YYYY-MM-DD` value.
- Add regression tests for valid and invalid leap-day dates.

## Verification

```bash
npm test
```

## Risk

Low. The change is limited to date validation and adds coverage for existing behavior.
```

---

## Example: Documentation Pull Request

```md
## Summary

Documents how contributors should update feature branches when `main` changes.

Closes #63

## Changes

- Add merge-based update workflow to `CONTRIBUTING.md`.
- Explain when `git rebase origin/main` is appropriate.
- Link to the pull request and review checklist.

## Verification

- Reviewed Markdown rendering on GitHub.
- Verified all referenced commands use existing branch names and files.
```

---

## Example: CI Pull Request

```md
## Summary

Adds a Node.js matrix to continuous integration.

Closes #71

## Changes

- Run tests on Node.js 20 and Node.js 22.
- Preserve minimal GitHub token permissions.
- Keep CI limited to pushes and pull requests targeting `main`.

## Verification

- Confirmed the workflow runs successfully in GitHub Actions.
- Confirmed tests pass locally:

```bash
npm test
```

## Review Focus

Please verify that the selected Node.js versions match the project support policy.
```

---

# C.9 Review Comment Examples

## The Target

Write review comments that are clear, respectful, and actionable.

## The Concept

Code review comments should improve the code and help the author understand why a change matters.

Avoid comments that only state a preference without context:

```text
I do not like this.
```

Prefer comments that identify the concern and desired outcome.

## The Implementation

Use these examples when reviewing a pull request.

### Blocking Comment

```text
blocking: This accepts an empty version string, which produces an invalid release heading. Please validate `version` before generating Markdown and add a regression test for whitespace-only input.
```

### Clarifying Question

```text
question: Is this helper intended to support sections beyond Added, Changed, and Fixed in the future? If so, a data-driven section list may make that extension easier.
```

### Optional Suggestion

```text
suggestion: Consider extracting this repeated error-message construction into a small helper. The current implementation works, so this is non-blocking.
```

### Minor Style Observation

```text
nit: Could we keep the parameter names aligned with the names used in the README example? It may make the public API easier to follow.
```

### Positive Feedback

```text
praise: The impossible-date test is especially useful here. It documents why the extra normalized-date comparison exists.
```

## The Verification

Before submitting a review, confirm that each comment:

- Refers to a specific concern or positive observation.
- Explains why the comment matters.
- Clearly indicates whether it blocks the merge.
- Avoids personal language.

---

# C.10 Suggested `CONTRIBUTING.md` File

## The Target

Create contributor documentation that connects branches, tests, pull requests, and review expectations.

## The Concept

A `CONTRIBUTING.md` file is the project’s onboarding guide for contributors.

It answers:

```text
How do I set up the project?
How do I create work safely?
How do I run tests?
How should I name branches?
How do I submit a pull request?
```

GitHub may automatically surface this file when someone opens an issue or pull request.

## The Implementation

Create this file.

### `release-notes-manager/CONTRIBUTING.md`

```md
# Contributing to Release Notes Manager

Thank you for contributing.

## Prerequisites

Install:

- Git
- Node.js 18 or newer
- npm
- A GitHub account

## Set Up the Project

Clone the repository:

```bash
git clone git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
cd release-notes-manager
```

If you use HTTPS instead of SSH:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager.git
cd release-notes-manager
```

Run the test suite:

```bash
npm test
```

## Create a Branch

Start from an updated `main` branch:

```bash
git switch main
git pull --ff-only
```

Create a focused branch:

```bash
git switch -c feature/short-description
```

Use descriptive branch prefixes:

```text
feature/add-export-command
fix/reject-invalid-date
docs/improve-contribution-guide
ci/add-node-version-matrix
```

## Make and Test Changes

Inspect your work:

```bash
git status
git diff
```

Run tests:

```bash
npm test
```

Stage only intended files:

```bash
git add src/releaseNotes.js src/releaseNotes.test.js
```

Review staged changes:

```bash
git diff --staged
```

Create a focused commit:

```bash
git commit -m "Add release note export command"
```

## Open a Pull Request

Push your branch:

```bash
git push -u origin feature/short-description
```

Then open a pull request targeting `main`.

A pull request should:

- Link to an issue when applicable.
- Explain the problem and outcome.
- Include verification steps.
- Include tests for behavior changes.
- Update documentation for user-visible changes.
- Avoid secrets, generated files, and unrelated changes.

Use the pull request template as a checklist.

## Review Expectations

Read [CODE_REVIEW.md](CODE_REVIEW.md) before requesting review.

Authors should:

- Respond to feedback respectfully.
- Ask for clarification when needed.
- Keep review discussions in the pull request.
- Resolve conversations only after addressing the feedback.

Reviewers should:

- Focus on correctness, safety, tests, and maintainability.
- Explain why requested changes matter.
- Distinguish blocking concerns from suggestions.

## Security

Do not commit passwords, API keys, tokens, private keys, or real `.env` files.

Read [SECURITY.md](SECURITY.md) for security guidance.

## Code of Conduct

Be respectful, constructive, and inclusive. Focus discussions on the work and its technical outcomes.
```

Replace `YOUR_GITHUB_USERNAME` with your actual GitHub username.

Run tests:

```bash
npm test
```

Commit the documentation:

```bash
git add CONTRIBUTING.md
git commit -m "Add contributor guide"
```

## The Verification

Confirm the file exists:

```bash
git show HEAD:CONTRIBUTING.md
```

Push it through a pull request if `main` is protected.

On GitHub, verify that GitHub surfaces contribution guidance when a contributor opens a pull request or issue.

---

# Appendix C Completion Check

You should now have reusable collaboration assets for the repository:

```text
.github/
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   ├── config.yml
│   ├── documentation.md
│   └── feature_request.md
├── workflows/
│   └── ci.yml
└── pull_request_template.md

CODE_REVIEW.md
CONTRIBUTING.md
```

You should also be able to:

- [ ] Create a pull request template.
- [ ] Create bug, feature, and documentation issue templates.
- [ ] Configure private security-reporting guidance.
- [ ] Write useful PR descriptions.
- [ ] Leave clear blocking and non-blocking review comments.
- [ ] Document a contributor workflow that matches the repository’s GitHub Flow process.
