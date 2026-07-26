# Appendix Q: Repository Governance, CODEOWNERS, and Team Access Control

As a repository gains contributors, technical quality depends on more than Git commands and automated tests.

Teams also need clear answers to questions such as:

- Who can merge into `main`?
- Who must review changes to CI workflows?
- Who owns security-sensitive files?
- Who can create releases?
- Who can administer repository settings?
- What happens when a maintainer leaves the team?

This is **repository governance**: the practical rules, ownership boundaries, and access controls that keep a project safe and maintainable.

Think of a repository as a building:

```text
Repository contributors    = people allowed to enter and work
Pull request reviewers     = people who inspect proposed changes
Code owners                = people responsible for specific rooms
Maintainers                = people who manage project operations
Administrators             = people who control building-wide settings
```

GitHub provides tools for this through:

- Repository roles.
- Organizations and teams.
- Branch protection or rulesets.
- Required reviews.
- `CODEOWNERS`.
- Security reporting settings.
- Environment protection rules.

---

# Q.1 Understand GitHub Repository Roles

## The Target

Understand the common levels of repository access before inviting collaborators.

## The Concept

Not every contributor needs the same permissions.

Giving every person administrator access is like handing every employee the master key to a building. It is convenient at first, but risky over time.

GitHub roles can vary slightly by repository type and organization settings, but the common model is:

| Role | Typical capabilities | Appropriate for |
|---|---|---|
| Read | View and clone repository content | Stakeholders, observers, auditors |
| Triage | Manage issues and pull requests without writing code | Project coordinators, support contributors |
| Write | Push branches and collaborate on code | Active developers |
| Maintain | Manage repository workflows without full ownership control | Senior maintainers |
| Admin | Manage settings, access, rules, and dangerous operations | Very limited trusted owners |

Use the minimum role required for each person.

A contributor who only needs to open pull requests usually needs:

```text
Write
```

A contributor who manages issue labels and project planning may need:

```text
Triage
```

Only a small number of trusted maintainers should receive:

```text
Admin
```

## The Implementation

On GitHub:

1. Open the repository.
2. Select **Settings**.
3. Open **Collaborators and teams** or **Manage access**.
4. Review every user with access.
5. Confirm each person has the lowest role appropriate to their responsibilities.

For an organization repository:

1. Open the GitHub organization.
2. Open **Teams**.
3. Create role-based teams, such as:

   ```text
   release-notes-maintainers
   release-notes-reviewers
   release-notes-security
   ```

4. Grant repository access to teams instead of assigning access individually when possible.

## The Verification

Review repository access and confirm:

```text
[ ] Active contributors have appropriate access.
[ ] Former contributors no longer have access.
[ ] Admin access is limited.
[ ] Team access is used where an organization supports it.
[ ] At least two trusted people can administer a production repository.
```

---

# Q.2 Create a `CODEOWNERS` File

## The Target

Create a `CODEOWNERS` file that identifies reviewers responsible for important project areas.

## The Concept

A `CODEOWNERS` file maps file paths to GitHub users or teams.

For example:

```text
.github/workflows/  @release-notes-maintainers
src/                @release-notes-reviewers
SECURITY.md         @release-notes-security
```

When a pull request changes a matching path, GitHub can automatically request review from the relevant owners.

Think of it as a routing system in a company:

```text
Documentation change      → documentation owner
CI workflow change        → automation owner
Security policy change    → security owner
Core formatter change     → application owner
```

For code-owner review requirements to be enforceable:

1. The `CODEOWNERS` file must exist on the base branch, usually `main`.
2. Branch rules must require code-owner approval.
3. The listed users or teams must have sufficient repository access.

## The Implementation

Create this file.

### `release-notes-manager/.github/CODEOWNERS`

```text
# Repository-wide fallback owner.
# Replace YOUR_GITHUB_USERNAME with the repository maintainer's GitHub username.
* @YOUR_GITHUB_USERNAME

# Core application logic and automated tests.
# Replace the placeholder with an individual maintainer or GitHub team.
src/ @YOUR_GITHUB_USERNAME

# CI workflows and automation guidance are security-sensitive.
.github/workflows/ @YOUR_GITHUB_USERNAME
.github/WORKFLOW_SECURITY.md @YOUR_GITHUB_USERNAME
.githooks/ @YOUR_GITHUB_USERNAME
scripts/ @YOUR_GITHUB_USERNAME

# Project governance and security documentation.
SECURITY.md @YOUR_GITHUB_USERNAME
CODE_REVIEW.md @YOUR_GITHUB_USERNAME
CONTRIBUTING.md @YOUR_GITHUB_USERNAME

# Release process and release documentation.
RELEASE_CHECKLIST.md @YOUR_GITHUB_USERNAME
RELEASE_NOTES.md @YOUR_GITHUB_USERNAME
```

Replace every occurrence of:

```text
YOUR_GITHUB_USERNAME
```

with your actual GitHub username.

For an organization, use team handles instead:

```text
src/ @YOUR_ORGANIZATION/release-notes-maintainers
.github/workflows/ @YOUR_ORGANIZATION/platform-security
```

Create a branch:

```bash
git switch main
git pull --ff-only
git switch -c docs/add-codeowners
```

Review the file:

```bash
git diff -- .github/CODEOWNERS
```

Run tests:

```bash
npm test
```

Commit and push:

```bash
git add .github/CODEOWNERS
git commit -m "docs(governance): define code owners"
git push -u origin docs/add-codeowners
```

Open a pull request targeting `main`.

## The Verification

On GitHub, review the pull request.

Confirm that:

- GitHub recognizes `.github/CODEOWNERS`.
- The listed GitHub username or team exists.
- The code owner is requested as a reviewer when applicable.
- The pull request passes CI.

After merging, open an additional pull request that changes a matching file, such as `README.md` or `src/releaseNotes.js`, and confirm GitHub automatically requests the appropriate owner review.

---

# Q.3 Require Code Owner Approval

## The Target

Require approval from relevant code owners before protected changes merge into `main`.

## The Concept

A `CODEOWNERS` file alone suggests reviewers. It does not necessarily block a merge.

To enforce ownership, enable the branch-protection setting that requires code-owner approval.

This is especially valuable for sensitive paths:

```text
.github/workflows/
.githooks/
scripts/
SECURITY.md
package.json
```

A change to CI automation can alter what code runs, what permissions workflows receive, and whether secrets are accessible. It deserves review from someone responsible for automation security.

## The Implementation

On GitHub:

1. Open repository **Settings**.
2. Open **Branches** or **Rules**.
3. Edit the protection rule or ruleset for:

   ```text
   main
   ```

4. Confirm that pull requests are required before merging.
5. Enable:

   ```text
   Require review from Code Owners
   ```

6. Keep or enable:

   ```text
   Require at least 1 approval
   Dismiss stale approvals when new commits are pushed
   Require conversation resolution before merging
   Require status checks to pass
   Require branches to be up to date before merging
   ```

7. Save the rule.

## The Verification

Create a test pull request that changes a code-owned file, such as a README clarification.

On the pull request page, confirm that GitHub displays a requested code-owner review.

The exact display varies, but it commonly shows:

```text
Review required
```

or:

```text
Code owner review required
```

Do not bypass the rule just because you are testing it. For a solo repository, administrative bypass may be unavoidable, but document that the bypass was used only because no second reviewer exists.

---

# Q.4 Add a Repository Governance Document

## The Target

Document how the project makes decisions, reviews changes, and manages access.

## The Concept

Technical rules are stronger when contributors can find them in the repository.

A governance document does not need to be legalistic. It should answer practical questions:

```text
Who maintains this project?
How are decisions made?
How are pull requests reviewed?
Who can merge?
How are security concerns reported?
How are inactive maintainers handled?
```

## The Implementation

Create this file.

### `release-notes-manager/GOVERNANCE.md`

```md
# Repository Governance

This document describes how Release Notes Manager is maintained.

## Maintainer Responsibilities

Maintainers are responsible for:

- Protecting the `main` branch.
- Reviewing pull requests or assigning appropriate reviewers.
- Maintaining continuous integration and repository security settings.
- Managing releases, tags, and GitHub Releases.
- Managing repository access using the principle of least privilege.
- Responding to security reports according to `SECURITY.md`.

## Contributor Responsibilities

Contributors are expected to:

- Follow `CONTRIBUTING.md`.
- Create focused branches and pull requests.
- Run relevant tests before requesting review.
- Avoid committing secrets, generated files, or unrelated changes.
- Respond constructively to review feedback.
- Respect code-owner review requirements.

## Pull Request Requirements

Pull requests targeting `main` should:

- Have a clear purpose.
- Link to an issue when appropriate.
- Pass required continuous integration checks.
- Receive required approvals.
- Resolve review conversations.
- Be current with `main` when branch rules require it.

## Code Ownership

The `.github/CODEOWNERS` file identifies the people or teams responsible for reviewing changes to specific paths.

Changes to automation, security, release configuration, and core application code may require review from designated owners.

## Access Management

Repository access should follow the principle of least privilege.

- Contributors receive only the access level needed for their role.
- Administrator access is limited to trusted maintainers.
- Access is reviewed when contributors join, change responsibilities, or leave.
- Organization teams should be used when available.

## Decision Making

For routine changes, maintainers make decisions through pull request review.

For significant changes, such as breaking API changes, security policy updates, release-process changes, or workflow permission changes:

1. Create or link a GitHub Issue.
2. Document the problem and proposed outcome.
3. Request review from relevant code owners.
4. Record important decisions in the issue or pull request discussion.
5. Merge only after required checks and approvals pass.

## Security Reports

Do not report vulnerabilities in public issues.

Follow the private reporting guidance in `SECURITY.md` and the repository security settings.

## Maintainer Continuity

A production repository should have at least two trusted maintainers with appropriate administrative access.

When a maintainer becomes inactive:

1. Review their repository and organization access.
2. Transfer responsibilities to an active maintainer.
3. Rotate credentials or tokens if needed.
4. Update `CODEOWNERS`, documentation, and release contacts.
```

Create a branch:

```bash
git switch main
git pull --ff-only
git switch -c docs/add-governance-guide
```

Run tests:

```bash
npm test
```

Commit and push:

```bash
git add GOVERNANCE.md
git commit -m "docs(governance): add repository governance guide"
git push -u origin docs/add-governance-guide
```

## The Verification

Open a pull request and confirm:

- The document is readable in GitHub’s Markdown preview.
- It links correctly to `CONTRIBUTING.md` and `SECURITY.md`.
- It reflects the branch rules currently configured in GitHub.
- It does not claim that reviews are mandatory if your repository has not enabled them.

Merge through the normal protected-branch workflow.

---

# Q.5 Protect Security-Sensitive Paths

## The Target

Identify files that deserve additional review and restricted modification.

## The Concept

Not all files carry the same risk.

A typo in a Markdown heading is usually low risk. A workflow change can change what commands run on GitHub-hosted infrastructure.

Review these paths with extra care:

| Path | Why it is sensitive |
|---|---|
| `.github/workflows/` | Executes automation and may access permissions or secrets |
| `.github/dependabot.yml` | Controls dependency-update automation |
| `.githooks/` | Alters local contributor workflow behavior |
| `scripts/` | May execute locally or in CI |
| `package.json` | Changes scripts, dependencies, and package behavior |
| `package-lock.json` | Changes resolved dependency versions |
| `.gitignore` | Can accidentally hide or expose important files |
| `SECURITY.md` | Defines vulnerability-reporting expectations |
| `CODEOWNERS` | Changes review routing and ownership |
| `GOVERNANCE.md` | Changes project decision and access process |

## The Implementation

Expand the `CODEOWNERS` file if needed.

### `release-notes-manager/.github/CODEOWNERS`

```text
# Repository-wide fallback owner.
* @YOUR_GITHUB_USERNAME

# Core application behavior.
src/ @YOUR_GITHUB_USERNAME
package.json @YOUR_GITHUB_USERNAME
package-lock.json @YOUR_GITHUB_USERNAME

# CI, hooks, scripts, and automation configuration.
.github/workflows/ @YOUR_GITHUB_USERNAME
.github/dependabot.yml @YOUR_GITHUB_USERNAME
.github/WORKFLOW_SECURITY.md @YOUR_GITHUB_USERNAME
.githooks/ @YOUR_GITHUB_USERNAME
scripts/ @YOUR_GITHUB_USERNAME

# Repository governance and security.
.github/CODEOWNERS @YOUR_GITHUB_USERNAME
SECURITY.md @YOUR_GITHUB_USERNAME
GOVERNANCE.md @YOUR_GITHUB_USERNAME
CODE_REVIEW.md @YOUR_GITHUB_USERNAME
CONTRIBUTING.md @YOUR_GITHUB_USERNAME

# Release management.
RELEASE_CHECKLIST.md @YOUR_GITHUB_USERNAME
RELEASE_NOTES.md @YOUR_GITHUB_USERNAME
```

Replace the username placeholder before committing.

Review the effect of a `CODEOWNERS` change:

```bash
git diff -- .github/CODEOWNERS
```

## The Verification

Before merging changes to ownership rules, confirm:

```text
[ ] The listed account or team exists.
[ ] The owner has repository access.
[ ] The owner understands their review responsibility.
[ ] No sensitive path is unintentionally left without ownership.
[ ] The fallback owner is an active maintainer.
```

---

# Q.6 Use Organization Teams Instead of Individual Accounts

## The Target

Use GitHub teams for durable ownership in organization repositories.

## The Concept

Individual usernames work for a personal project, but teams scale better in organizations.

Compare:

```text
src/ @alex @sam @taylor
```

with:

```text
src/ @acme/release-notes-maintainers
```

The team-based version is easier to maintain. When a person joins or leaves, update team membership rather than editing repository files.

Recommended team structure:

```text
Organization
├── release-notes-maintainers
├── release-notes-reviewers
├── platform-security
└── release-managers
```

Example `CODEOWNERS` entries:

```text
src/ @acme/release-notes-maintainers
.github/workflows/ @acme/platform-security
RELEASE_NOTES.md @acme/release-managers
```

## The Implementation

In a GitHub organization:

1. Open the organization page.
2. Select **Teams**.
3. Create teams with clear responsibilities.
4. Add members based on their actual responsibilities.
5. Grant teams repository access with the minimum appropriate role.
6. Replace individual `CODEOWNERS` entries with team handles.

Example:

### `release-notes-manager/.github/CODEOWNERS`

```text
* @acme/release-notes-maintainers

src/ @acme/release-notes-maintainers
.github/workflows/ @acme/platform-security
.githooks/ @acme/platform-security
scripts/ @acme/platform-security
SECURITY.md @acme/platform-security
RELEASE_NOTES.md @acme/release-managers
RELEASE_CHECKLIST.md @acme/release-managers
```

## The Verification

On GitHub, open the `CODEOWNERS` file.

GitHub should recognize team mentions as links.

Open a pull request touching:

```text
.github/workflows/ci.yml
```

Confirm GitHub requests review from:

```text
@acme/platform-security
```

---

# Q.7 Establish an Access Review Routine

## The Target

Create a recurring process for reviewing repository access and security settings.

## The Concept

Access control is not a one-time setup task.

Over time:

- Contributors change roles.
- Contractors finish work.
- Team members leave.
- Tokens expire.
- SSH keys become unused.
- Automation changes.
- New environments gain secrets.

A periodic access review is like checking who still has keys to an office.

## The Implementation

Create a GitHub Issue template for access reviews, or create a recurring issue manually.

Use this issue title:

```text
Quarterly repository access review
```

Use this body:

```md
## Purpose

Review repository access, ownership, automation permissions, and security settings.

## Access Review

- [ ] Review collaborators and organization teams.
- [ ] Remove inactive contributors and former contractors.
- [ ] Confirm administrator access is limited to active maintainers.
- [ ] Confirm at least two trusted maintainers can administer the repository.
- [ ] Review deploy keys and GitHub Apps.
- [ ] Review personal access tokens used by automation where applicable.

## Ownership Review

- [ ] Confirm `.github/CODEOWNERS` lists active owners.
- [ ] Confirm code-owner teams have appropriate repository access.
- [ ] Confirm automation and security paths have explicit owners.
- [ ] Confirm release-management paths have active owners.

## Automation Review

- [ ] Review GitHub Actions workflow permissions.
- [ ] Review environment protection rules.
- [ ] Review repository and environment secrets.
- [ ] Confirm no unused deployment secrets remain.

## Branch and Release Review

- [ ] Confirm `main` remains protected.
- [ ] Confirm required CI checks still exist.
- [ ] Confirm release tags and GitHub Releases follow project policy.

## Outcome

Document completed actions, removed access, changed owners, and follow-up work below.
```

Add the issue to your project board and assign it to maintainers.

## The Verification

Confirm the issue includes concrete review tasks rather than a vague instruction such as:

```text
Check security.
```

A completed review should leave an auditable record of:

- When it happened.
- Who performed it.
- What changed.
- What follow-up work remains.

---

# Q.8 Governance Checklist for Pull Requests

## The Target

Add a practical governance review layer to pull requests affecting repository control files.

## The Concept

Some pull requests change the project’s “rules of the road.”

For example:

```text
.github/CODEOWNERS
GOVERNANCE.md
SECURITY.md
.github/workflows/
```

These changes may affect review requirements, access boundaries, security reporting, or deployment behavior.

They deserve deliberate review.

## The Implementation

Append this section to `CODE_REVIEW.md`.

### `release-notes-manager/CODE_REVIEW.md` — append this section

```md
## Governance and Access-Control Review

Use this checklist when a pull request changes repository rules, ownership, security policy, or access-related configuration.

- [ ] The change has a clear documented reason.
- [ ] Relevant maintainers or code owners reviewed the change.
- [ ] `CODEOWNERS` entries refer to active users or teams.
- [ ] New owners have the required repository access.
- [ ] No ownership or review requirement is unintentionally weakened.
- [ ] Branch protection or ruleset changes are reflected in documentation.
- [ ] Security-reporting guidance remains private and accurate.
- [ ] Automation permission changes follow least privilege.
- [ ] The project retains at least two trusted maintainers where practical.
```

Create a branch:

```bash
git switch main
git pull --ff-only
git switch -c docs/add-governance-review-checklist
```

Run tests:

```bash
npm test
```

Commit and push:

```bash
git add CODE_REVIEW.md
git commit -m "docs(review): add governance review checklist"
git push -u origin docs/add-governance-review-checklist
```

## The Verification

On the pull request, confirm the checklist is appropriate for repository-governance changes.

After merging, reviewers should use it whenever a pull request affects:

```text
CODEOWNERS
GOVERNANCE.md
SECURITY.md
GitHub Actions workflows
Branch rules
GitHub Environments
```

---

# Q.9 Incident Ownership and Emergency Changes

## The Target

Define a safe approach for urgent changes when normal review timing is not possible.

## The Concept

Sometimes a critical security issue or production outage requires a faster response than the normal pull-request review cycle.

Emergency access should not mean “skip all safeguards.”

A practical emergency workflow is:

```text
Identify urgent problem
    ↓
Create incident issue or private security advisory
    ↓
Create focused hotfix branch
    ↓
Implement smallest safe fix
    ↓
Run tests and CI
    ↓
Obtain available maintainer review
    ↓
Merge using documented emergency authority
    ↓
Document follow-up review and prevention work
```

If an administrator bypasses a branch rule, the bypass should be rare and documented.

## The Implementation

Create an emergency pull request description template for maintainers.

```md
## Emergency Change

This pull request addresses an urgent production, availability, or security concern.

## Incident Reference

Link the incident issue, private advisory, or internal tracking reference.

## Risk Assessment

Describe:

- The risk of not merging immediately.
- The risk introduced by this change.
- Why normal review timing is not feasible.

## Verification

```bash
npm test
```

List any additional manual verification performed.

## Follow-Up Required

- [ ] Open a retrospective or follow-up issue.
- [ ] Review the emergency change after stabilization.
- [ ] Add tests, monitoring, documentation, or process improvements if needed.
- [ ] Confirm temporary access or credentials are removed if applicable.
```

Store this in maintainer documentation or use it manually for emergency changes.

## The Verification

Confirm the emergency process requires:

```text
[ ] A written reason.
[ ] A focused change.
[ ] Testing.
[ ] Available review.
[ ] A follow-up record.
```

An emergency should accelerate responsible work—not eliminate accountability.

---

# Q.10 Repository Governance Command and Configuration Reference

## Inspect Local Code Owners File

```bash
cat .github/CODEOWNERS
```

On Windows PowerShell:

```powershell
Get-Content .github\CODEOWNERS
```

## Check for Sensitive Repository Paths

```bash
find .github .githooks scripts -type f 2>/dev/null
```

On Windows PowerShell:

```powershell
Get-ChildItem .github, .githooks, scripts -Recurse -File -ErrorAction SilentlyContinue
```

## Inspect Recent Governance-Related Changes

```bash
git log --oneline -- \
  .github/CODEOWNERS \
  GOVERNANCE.md \
  SECURITY.md \
  CODE_REVIEW.md \
  .github/workflows
```

## Inspect Branch Protection Remotely

GitHub branch-protection details are normally managed and inspected through the GitHub web interface:

```text
Repository → Settings → Branches or Rules
```

For automated organization administration, GitHub’s API and `gh` CLI can be used, but access-control automation should be reviewed carefully and use least-privilege tokens.

---

# Appendix Q Completion Check

You should now be able to:

- [ ] Explain why repository governance matters alongside Git workflows.
- [ ] Assign GitHub roles using the principle of least privilege.
- [ ] Create a `CODEOWNERS` file.
- [ ] Require code-owner approval for protected changes.
- [ ] Identify automation, security, release, and governance files that need extra review.
- [ ] Use organization teams for durable ownership boundaries.
- [ ] Create a governance document for contributors and maintainers.
- [ ] Conduct periodic access reviews.
- [ ] Handle emergency changes with documented accountability.
- [ ] Keep at least two trusted maintainers responsible for production repository continuity.
