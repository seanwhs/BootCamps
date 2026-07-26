# Primer 17: Code Review Mindset, Constructive Feedback, and Review Readiness

A pull request is not only a technical merge request. It is a communication tool.

Code review helps a team catch problems, share knowledge, improve maintainability, and make decisions visible.

A healthy review process is not:

```text
Reviewer tries to prove the author made mistakes.
```

It is:

```text
Author and reviewer work together to make the change safe, understandable,
and ready for the project.
```

This primer prepares you for the pull-request workflows in Part 4.

You will learn:

- Why code review exists.
- What authors should do before requesting review.
- What reviewers should check.
- How to write respectful, actionable feedback.
- How to distinguish blocking concerns from suggestions.
- How to respond to review comments professionally.
- When a pull request is ready to merge.

---

# P17.1 Understand the Purpose of Code Review

## The Target

Understand why professional teams review changes before merging them.

## The Concept

A reviewer is not just checking for syntax errors. Automated tests and linters can catch many mechanical problems.

Human review focuses on questions such as:

```text
Does this solve the intended problem?
Is the behavior safe and understandable?
Are important edge cases considered?
Will future contributors understand this code?
Does the change fit the project architecture?
```

Think of a code review like checking a map before a group trip.

The driver may know the route, but another person can notice:

```text
This road is closed.
This route misses the destination.
This turn adds unnecessary risk.
This instruction is unclear.
```

A good review improves both the change and the shared understanding of the project.

## The Implementation

No file changes are required.

Read this review flow:

```text
Issue
    ↓
Feature branch
    ↓
Code, tests, and documentation
    ↓
Author self-review
    ↓
Pull request
    ↓
Automated CI checks
    ↓
Human review
    ↓
Discussion and updates
    ↓
Approval and merge
```

## The Verification

Confirm you can explain these separate safeguards:

| Safeguard | Main purpose |
|---|---|
| Local tests | Fast feedback while developing |
| CI checks | Independent automated verification |
| Code review | Human judgment, design discussion, maintainability, and risk assessment |
| Branch protection | Enforces project merge requirements |

---

# P17.2 Prepare a Pull Request for Review

## The Target

Perform author self-review before asking another person to inspect a pull request.

## The Concept

The first reviewer of a pull request should be its author.

Self-review catches obvious mistakes and respects reviewers’ time.

Think of it as proofreading an email before sending it. You would not ask someone else to correct spelling, remove accidental attachments, and explain your own message before you have read it once.

## The Implementation

Before opening a pull request, run:

```bash
git status
git diff main...HEAD
git diff --check
git log --oneline main..HEAD
npm test
```

Review each command’s purpose:

| Command | Why run it? |
|---|---|
| `git status` | Confirm current branch and clean or expected working state |
| `git diff main...HEAD` | Review every change proposed against `main` |
| `git diff --check` | Detect whitespace errors |
| `git log --oneline main..HEAD` | Review commits unique to the branch |
| `npm test` | Confirm automated tests pass locally |

Use this author checklist:

```text
Purpose
[ ] The pull request has one clear purpose.
[ ] The title describes the outcome.
[ ] A linked issue explains the problem and acceptance criteria.

Scope
[ ] No unrelated edits are included.
[ ] No generated files, logs, dependencies, or local configuration are included accidentally.
[ ] No secrets or private data appear in the diff.

Quality
[ ] Relevant tests pass.
[ ] New behavior has tests.
[ ] Documentation matches behavior.
[ ] Error messages and edge cases are understandable.

Communication
[ ] The PR description explains what changed and why.
[ ] Verification steps are documented.
[ ] Risky or uncertain areas are called out for reviewers.
```

## The Verification

Before requesting review, answer:

```text
If I were seeing this pull request for the first time,
could I understand its purpose from the title, summary, changed files,
and verification steps?
```

If the answer is no, improve the pull request description before requesting review.

---

# P17.3 Review for Correctness Before Style

## The Target

Prioritize meaningful risks over minor formatting preferences.

## The Concept

Not all review comments have equal importance.

A useful review order is:

```text
1. Correctness
2. Security and data safety
3. Tests and failure behavior
4. Maintainability
5. Documentation
6. Style and minor preferences
```

For example, this is important:

```text
The validator accepts an impossible date such as 2026-02-31.
```

This is less important:

```text
Could this variable name be one word shorter?
```

Style comments matter eventually, but they should not distract from defects that could break the application or expose data.

## The Implementation

Use this review priority table.

| Priority | Review question | Example |
|---|---|---|
| Critical | Could this expose secrets, corrupt data, or create a security problem? | Workflow grants unnecessary write permissions |
| High | Does the feature behave incorrectly? | Empty version values are accepted |
| Medium | Is important test coverage missing? | Invalid date input has no regression test |
| Medium | Is the design difficult to maintain? | Same validation logic appears in three places |
| Low | Is documentation unclear? | README example does not explain optional fields |
| Optional | Is there a non-blocking style improvement? | Variable name could be clearer |

## The Verification

Before writing a comment, classify it:

```text
Is this blocking?
    ↓
Could it cause incorrect behavior, security risk, data loss,
broken CI, or a requirement failure?
    ↓
If yes:
Use blocking feedback.

If no:
Use question, suggestion, nit, or praise.
```

---

# P17.4 Write Constructive Review Comments

## The Target

Write feedback that is respectful, specific, and actionable.

## The Concept

A useful review comment contains three parts:

```text
Observation
    ↓
Why it matters
    ↓
Requested outcome or question
```

Weak comment:

```text
This is bad.
```

Constructive comment:

```text
blocking: This accepts whitespace-only version values, which produces an
invalid release heading. Please reject empty trimmed versions and add a
regression test.
```

The second comment tells the author:

- What the problem is.
- Why it matters.
- What a correct result should include.

## The Implementation

Use these reusable comment patterns.

### Blocking Concern

```text
blocking: This change allows ____________________. That can cause ____________________.
Please ____________________ and add or update a test that verifies the expected behavior.
```

Example:

```text
blocking: This workflow uses `contents: write` even though it only runs tests.
That grants unnecessary repository access. Please reduce permissions to
`contents: read`.
```

### Clarifying Question

```text
question: What happens when ____________________? Should we document or test
that behavior before merging?
```

Example:

```text
question: What happens when the `security` section contains an empty string?
Should the formatter reject it or omit it?
```

### Optional Suggestion

```text
suggestion: Consider ____________________ because ____________________.
This is non-blocking.
```

Example:

```text
suggestion: Consider extracting this repeated validation message into a helper
because the same wording appears in multiple branches. This is non-blocking.
```

### Minor Detail

```text
nit: Could we ____________________ for consistency with ____________________?
```

Example:

```text
nit: Could we use `releaseDate` in this README example for consistency with
the public formatter API?
```

### Positive Feedback

```text
praise: ____________________.
```

Example:

```text
praise: The impossible-date test clearly documents why the normalized date
comparison is necessary.
```

## The Verification

Before submitting feedback, confirm:

```text
[ ] The comment describes a specific line, behavior, or design decision.
[ ] The reason is clear.
[ ] The author knows whether it blocks merge.
[ ] The tone focuses on the change, not the person.
[ ] The requested outcome is realistic and testable.
```

---

# P17.5 Respond to Review Feedback Professionally

## The Target

Handle review comments as part of collaborative problem solving.

## The Concept

A review comment is not automatically a command and not automatically a criticism of you.

It is a request to think together about a change.

A productive response can be:

```text
I agree. I updated validation to reject whitespace-only values and added
a test covering that case.
```

Or:

```text
I considered that approach. I kept the current design because the helper is
used only once, but I added a comment explaining the decision. Does that
address the concern?
```

Or:

```text
I am not sure I understand the failure scenario. Could you provide an example
input that should behave differently?
```

Avoid defensive responses:

```text
It works on my machine.
```

```text
That was intentional.
```

without explaining why.

## The Implementation

Use this response pattern:

```text
1. Acknowledge the comment.
2. State what you changed or why you chose a different approach.
3. Provide verification evidence.
4. Ask a clarifying question if needed.
```

Example:

```text
Thanks. I updated `normalizeSection` to reject whitespace-only entries and
added a test for `["valid entry", "   "]`.

Verification:

```bash
npm test
```

All tests pass. Please let me know if you would also like this validation
documented in the README.
```

## The Verification

Before resolving a review conversation, confirm:

```text
[ ] The requested change was made, or the reviewer agreed on an alternative.
[ ] Relevant tests were added or updated.
[ ] The response explains what changed.
[ ] The reviewer has enough information to verify the resolution.
```

Do not resolve a conversation merely because you replied to it.

---

# P17.6 Review Tests as Behavior Documentation

## The Target

Use tests to understand and review expected behavior.

## The Concept

Tests do more than catch regressions. They document what the project promises.

For example:

```js
test("rejects malformed and impossible release dates", () => {
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

This test communicates:

```text
The formatter must reject impossible calendar dates.
The error should be a TypeError.
The error message is part of the expected developer experience.
```

When reviewing tests, ask:

```text
Does this test prove the required behavior?
Would it fail if the feature broke?
Does it cover meaningful edge cases?
Is it deterministic?
```

## The Implementation

Inspect test changes in a feature branch:

```bash
git diff main...HEAD -- src/releaseNotes.test.js
```

Run tests:

```bash
npm test
```

Inspect test names:

```bash
grep -n "test(" src/releaseNotes.test.js
```

On Windows PowerShell:

```powershell
Select-String -Path src\releaseNotes.test.js -Pattern 'test\('
```

## The Verification

A useful test name should read like a behavior statement:

```text
formats release notes with populated sections
omits empty and missing sections
rejects malformed and impossible release dates
```

Avoid vague test names:

```text
works
test formatter
handles input
```

---

# P17.7 Understand Approval and Merge Readiness

## The Target

Know when a pull request is ready to merge.

## The Concept

Approval means a reviewer believes the pull request meets the project’s requirements.

It does not mean:

```text
No future bug is possible.
```

It means:

```text
The change is understood.
The requirements appear satisfied.
The required tests and checks passed.
Known risks are acceptable.
```

A typical merge-ready pull request has:

```text
[ ] Clear title and description.
[ ] Linked issue or documented purpose.
[ ] Focused diff.
[ ] Passing CI.
[ ] Required approvals.
[ ] Resolved conversations.
[ ] Current branch state, if required by rules.
[ ] No secrets or unintended files.
```

## The Implementation

Inspect pull request state using GitHub CLI:

```bash
gh pr status
```

Inspect a specific pull request:

```bash
gh pr view PR_NUMBER --json title,reviewDecision,statusCheckRollup,mergeStateStatus
```

Replace `PR_NUMBER` with the real pull request number.

## The Verification

Expected healthy information includes:

```text
Review decision:
APPROVED

Status checks:
SUCCESS

Merge state:
CLEAN
```

Exact field values can vary by GitHub configuration.

Do not merge when required checks are failing or required review is missing.

---

# P17.8 Use Review Checklists Proportionally

## The Target

Apply more review depth to higher-risk changes.

## The Concept

A one-line spelling correction and a workflow-permission change should not receive the same level of review.

Review effort should be proportional to risk.

| Change type | Typical review depth |
|---|---|
| Typo in README | Verify wording and links |
| New formatter feature | Review behavior, tests, docs, and edge cases |
| Dependency update | Review version, lockfile, advisories, CI |
| GitHub Actions permission change | Review triggers, permissions, secrets, and shell safety |
| Security or authentication change | Require specialist review and detailed testing |
| Production deployment workflow | Require environment protections, approvals, and rollback plan |

## The Implementation

Use this proportional review question:

```text
If this change is wrong, what could happen?
```

Then match review depth:

```text
Small inconvenience
    → Basic review.

Incorrect application behavior
    → Review implementation and tests.

Security, data loss, production deployment, or access control risk
    → Detailed review, code-owner review, CI verification, and documented rollback plan.
```

## The Verification

Before approving a high-risk change, confirm:

```text
[ ] Relevant code owners reviewed it.
[ ] Least-privilege permissions are used.
[ ] Tests cover expected and failure paths.
[ ] A rollback or recovery path is understood.
[ ] Sensitive values are not exposed.
```

---

# P17.9 Code Review Anti-Patterns

## The Target

Recognize review habits that reduce trust or let defects through.

## The Concept

Avoid these common anti-patterns.

### Rubber-Stamp Approval

```text
LGTM
```

without reading the diff or checks.

### Style-Only Review

Focusing only on naming or formatting while missing incorrect behavior.

### Endless Optional Feedback

Treating every suggestion as a blocker and delaying useful work unnecessarily.

### Hidden Requirements

Requesting changes based on undocumented expectations.

### Large Unfocused PRs

Combining many unrelated changes so reviewers cannot evaluate risk properly.

### Comment-Only Review Without Verification

Requesting code changes but not checking the updated diff or tests afterward.

## The Implementation

Use this replacement table.

| Anti-pattern | Better practice |
|---|---|
| “Looks good” without inspection | Review changed files, tests, and CI first |
| Vague criticism | State observation, impact, and requested outcome |
| Treating every preference as blocking | Label suggestions and nits clearly |
| Requesting undocumented behavior | Link issue, acceptance criteria, or project convention |
| Reviewing huge mixed PR | Ask author to split unrelated concerns |
| Resolving after reply only | Verify the actual updated code and test results |

## The Verification

Before approving, ask:

```text
What changed?
Why did it change?
How was it tested?
What could fail?
What evidence shows it is ready?
```

If you cannot answer these, request clarification rather than approving.

---

# P17.10 Review and Author Command Reference

## Author Self-Review

```bash
git status
git diff main...HEAD
git diff --check
git log --oneline main..HEAD
npm test
```

## Review Pull Request Details

```bash
gh pr view PR_NUMBER
gh pr diff PR_NUMBER
gh pr view PR_NUMBER --web
```

## Review Status Checks

```bash
gh pr view PR_NUMBER --json reviewDecision,statusCheckRollup,mergeStateStatus
```

## Add a General Pull Request Comment

```bash
gh pr comment PR_NUMBER --body "Please add a regression test for whitespace-only section entries."
```

## Approve a Pull Request

```bash
gh pr review PR_NUMBER --approve --body "Approved after reviewing the implementation, tests, and CI results."
```

## Request Changes

```bash
gh pr review PR_NUMBER --request-changes --body "Please validate empty versions and add a regression test before merging."
```

---

# Primer 17 Completion Check

Before participating in code review, confirm that you can:

- [ ] Explain why code review is different from automated testing.
- [ ] Self-review a pull request before requesting another reviewer.
- [ ] Prioritize correctness and security over style preferences.
- [ ] Write specific, respectful, actionable review comments.
- [ ] Distinguish blocking comments from questions, suggestions, and nits.
- [ ] Respond to feedback with changes, reasoning, and verification evidence.
- [ ] Review tests as behavior documentation.
- [ ] Identify when a pull request is ready to merge.
- [ ] Apply deeper review to higher-risk changes.
- [ ] Avoid rubber-stamp approvals and other review anti-patterns.
