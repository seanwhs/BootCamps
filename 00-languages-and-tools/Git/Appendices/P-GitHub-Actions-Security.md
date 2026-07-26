# Appendix P: GitHub Actions Security, Dependency Pinning, and Safe CI/CD Practices

GitHub Actions makes automation convenient, but every workflow is executable code with access to your repository and, sometimes, deployment credentials.

A workflow can:

- Read repository files.
- Run shell commands.
- Download dependencies.
- Access GitHub-provided tokens.
- Publish packages or release artifacts.
- Deploy software when explicitly configured to do so.

That power means workflows need the same engineering care as application code.

This appendix expands the CI workflow created earlier and teaches safe automation practices:

- Grant the minimum required permissions.
- Pin third-party Actions to immutable versions.
- Avoid exposing secrets in logs.
- Separate test workflows from deployment workflows.
- Use GitHub Environments for protected deployments.
- Understand risks from pull requests originating in forks.
- Add dependency caching safely.
- Review workflow changes through pull requests.

---

# P.1 Treat Workflow Files as Production Code

## The Target

Understand why files in `.github/workflows/` require careful review.

## The Concept

A GitHub Actions workflow is not passive configuration. It is executable automation.

For example, this line runs a shell command:

```yaml
run: npm test
```

This line downloads and executes a reusable Action:

```yaml
uses: actions/checkout@v4
```

And this line grants the workflow access to repository contents:

```yaml
permissions:
  contents: read
```

Think of a workflow as a robot with a checklist. The workflow file tells the robot:

1. When to wake up.
2. Which room to enter.
3. What tools it may use.
4. Which commands to execute.
5. Which credentials it may access.

If someone changes the robot’s instructions, they may also change what it can access. Therefore, workflow changes should receive focused pull-request review.

## The Implementation

Inspect every workflow in the repository:

```bash
find .github/workflows -type f -maxdepth 1 -print
```

On Windows PowerShell:

```powershell
Get-ChildItem -Path .github\workflows -File
```

Display the CI workflow:

```bash
cat .github/workflows/ci.yml
```

On Windows PowerShell:

```powershell
Get-Content .github\workflows\ci.yml
```

## The Verification

Confirm that every workflow file is understandable and intentionally present.

For each workflow, identify:

```text
[ ] Which events trigger it?
[ ] Which permissions does it receive?
[ ] Which third-party Actions does it use?
[ ] Which shell commands does it run?
[ ] Does it use secrets?
[ ] Can it write to the repository, publish, or deploy?
```

---

# P.2 Apply the Principle of Least Privilege

## The Target

Configure workflows with only the permissions they need.

## The Concept

The **principle of least privilege** means giving a person, application, or workflow only the access required for its specific job.

A test workflow needs to read source code and run tests. It does not need permission to:

- Push commits.
- Create releases.
- Modify pull requests.
- Change repository settings.
- Publish packages.

This is the right permission setting for a read-only test workflow:

```yaml
permissions:
  contents: read
```

Think of it as giving a maintenance worker a key to one utility closet rather than a master key for the entire building.

## The Implementation

Ensure the CI workflow contains this top-level permission block.

### `release-notes-manager/.github/workflows/ci.yml`

```yaml
permissions:
  contents: read
```

Your complete workflow should remain:

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

# This test-only workflow needs to read repository files, but it does not need
# permission to write commits, publish releases, or modify pull requests.
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

Inspect repository-level Actions permissions in GitHub:

1. Open the repository.
2. Select **Settings**.
3. Select **Actions**.
4. Select **General**.
5. Find **Workflow permissions**.
6. Select:

   ```text
   Read repository contents permission
   ```

7. Avoid enabling broad write permissions by default.
8. Save the setting.

## The Verification

Review the workflow:

```bash
grep -n "permissions" .github/workflows/ci.yml
```

On Windows PowerShell:

```powershell
Select-String -Path .github\workflows\ci.yml -Pattern "permissions"
```

Confirm the workflow has only:

```yaml
permissions:
  contents: read
```

---

# P.3 Pin GitHub Actions to Immutable Commit Hashes

## The Target

Understand why immutable Action pinning is more secure than floating version tags.

## The Concept

This workflow step is convenient:

```yaml
uses: actions/checkout@v4
```

But `v4` is a mutable tag. It usually points to the latest compatible v4 release, but its exact commit can change over time.

For stronger supply-chain security, pin Actions to a full commit hash:

```yaml
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
```

The hash identifies one exact Action revision.

Think of the difference like this:

```text
@v4
= “Use the current book labeled fourth edition.”

@full-commit-hash
= “Use this exact printing, page for page.”
```

Pinned hashes improve reproducibility and reduce risk if a tag is unexpectedly moved or compromised.

The comment preserves readability by documenting the human-friendly release version.

## The Implementation

Create a security-focused branch:

```bash
git switch main
git pull --ff-only
git switch -c ci/pin-github-actions
```

Replace the workflow with this pinned version.

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
      # actions/checkout v4.2.2 pinned to an immutable commit hash.
      - name: Check out repository
        uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2

      # actions/setup-node v4.4.0 pinned to an immutable commit hash.
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

> **Important:** Action releases and commit hashes change over time. Before merging, verify each hash against the Action’s official GitHub release or a trusted dependency-update tool. The examples above illustrate the pinning format; use current verified hashes in a production repository.

Review the change:

```bash
git diff -- .github/workflows/ci.yml
```

Run tests locally:

```bash
npm test
```

Commit and push:

```bash
git add .github/workflows/ci.yml
git commit -m "ci(actions): pin GitHub Actions revisions"
git push -u origin ci/pin-github-actions
```

## The Verification

Open a pull request and ensure the workflow passes.

In the PR review, verify:

```text
[ ] Each `uses:` line is pinned to a full commit hash.
[ ] A comment identifies the intended Action release.
[ ] The Action comes from a trusted owner.
[ ] The workflow still uses minimum permissions.
```

---

# P.4 Avoid Script Injection from Pull Request Data

## The Target

Understand why untrusted pull-request text must not be inserted directly into shell commands.

## The Concept

GitHub event data can include text supplied by contributors:

- Pull request titles.
- Branch names.
- Issue titles.
- Commit messages.
- Usernames.
- Labels.

It may be tempting to use such values directly in shell commands:

```yaml
run: echo "${{ github.event.pull_request.title }}"
```

The safe pattern depends on context, but directly embedding untrusted expressions into shell scripts can create **script injection** risks.

For example, a malicious title may contain shell syntax.

Think of this like reading a note from a stranger aloud versus treating the note as a command for a robot. Text should remain text.

## The Implementation

Avoid this unsafe pattern:

### Unsafe workflow example — do not use

```yaml
- name: Print pull request title
  run: echo "${{ github.event.pull_request.title }}"
```

Use an environment variable instead:

### Safer workflow example

```yaml
- name: Print pull request title
  env:
    PULL_REQUEST_TITLE: ${{ github.event.pull_request.title }}
  run: |
    printf 'Pull request title: %s\n' "$PULL_REQUEST_TITLE"
```

The environment-variable approach keeps the GitHub expression outside the shell script itself.

Create a local reference file for reviewers.

### `release-notes-manager/.github/WORKFLOW_SECURITY.md`

```md
# GitHub Actions Security Guidance

## Treat Workflow Files as Executable Code

Review workflow changes with the same care used for application code.

## Use Least Privilege

Declare explicit `permissions` for every workflow. Test-only workflows should normally use:

```yaml
permissions:
  contents: read
```

## Pin Actions

Pin third-party Actions to immutable commit hashes and include a comment naming the reviewed release.

## Handle Pull Request Data Safely

Do not embed pull request titles, branch names, issue bodies, or other contributor-controlled data directly into shell commands.

Prefer environment variables:

```yaml
env:
  PULL_REQUEST_TITLE: ${{ github.event.pull_request.title }}
run: |
  printf 'Pull request title: %s\n' "$PULL_REQUEST_TITLE"
```

## Protect Secrets

Do not print secrets, tokens, or complete environment variables to logs. Do not expose deployment credentials to untrusted pull-request workflows.

## Review Trigger Changes Carefully

Changes to `pull_request_target`, `workflow_run`, `permissions`, `secrets`, `environment`, and `uses` deserve extra review.
```

Commit it on the same security branch:

```bash
git add .github/WORKFLOW_SECURITY.md
git commit -m "docs(actions): add workflow security guidance"
```

## The Verification

Review the new file:

```bash
git show --stat HEAD
git show HEAD:.github/WORKFLOW_SECURITY.md
```

Confirm you can identify the safer pattern:

```yaml
env:
  VALUE: ${{ github.event.some_untrusted_value }}
run: |
  printf '%s\n' "$VALUE"
```

---

# P.5 Understand `pull_request` Versus `pull_request_target`

## The Target

Choose the correct GitHub Actions trigger for pull-request workflows.

## The Concept

These two triggers look similar but have very different security behavior.

| Trigger | Typical purpose | Security model |
|---|---|---|
| `pull_request` | Run tests and checks against PR code | Safer default for untrusted PR code |
| `pull_request_target` | Perform trusted repository actions related to a PR | Runs in the base repository context and can access broader permissions/secrets |

For ordinary testing, use:

```yaml
on:
  pull_request:
    branches:
      - main
```

Do **not** switch to `pull_request_target` merely to make secrets available to a pull request.

A dangerous pattern is:

```yaml
on:
  pull_request_target:

steps:
  - uses: actions/checkout@...
    with:
      ref: ${{ github.event.pull_request.head.sha }}

  - run: npm test
```

If the pull request comes from an untrusted fork, this can check out and execute attacker-controlled code while the workflow has access to trusted repository context or secrets.

## The Implementation

Inspect workflow triggers:

```bash
grep -RIn "pull_request_target\|pull_request:" .github/workflows
```

On Windows PowerShell:

```powershell
Get-ChildItem .github\workflows -File |
  Select-String -Pattern "pull_request_target|pull_request:"
```

For the CI workflow, retain this safe trigger:

### `release-notes-manager/.github/workflows/ci.yml`

```yaml
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
```

## The Verification

Confirm that no normal test workflow uses:

```yaml
pull_request_target:
```

If you later need trusted automation for labels, comments, or issue management, design it separately and ensure it does not check out or execute untrusted PR code.

---

# P.6 Use GitHub Environments for Protected Deployments

## The Target

Understand how GitHub Environments protect deployment credentials and approval flows.

## The Concept

A GitHub **Environment** represents a deployment destination, such as:

```text
staging
production
```

An environment can require:

- Manual approval before deployment.
- Restricted branch access.
- Environment-specific secrets.
- Environment-specific variables.
- Deployment history.

Think of an environment as a locked release gate. CI may validate code automatically, but production deployment requires an additional controlled step.

For a simple project, you may only need a `production` environment later. Do not create deployment secrets until the project actually deploys something.

## The Implementation

On GitHub:

1. Open the repository.
2. Select **Settings**.
3. Select **Environments**.
4. Select **New environment**.
5. Create:

   ```text
   production
   ```

6. Enable **Required reviewers** if your account or plan supports it.
7. Add yourself or authorized maintainers as reviewers.
8. Optionally restrict deployments to:

   ```text
   main
   ```

9. Save the protection rules.

Do not add fake or real deployment credentials for this tutorial.

A future deployment workflow would reference the environment like this:

```yaml
jobs:
  deploy:
    name: Deploy production release
    runs-on: ubuntu-latest
    environment:
      name: production

    steps:
      - name: Deploy
        run: ./scripts/deploy.sh
```

## The Verification

On GitHub, confirm the repository has an environment named:

```text
production
```

Confirm that protection rules are visible.

Remember:

```text
Environment protection is useful only when deployment workflows explicitly use that environment.
```

---

# P.7 Store Deployment Credentials as Environment Secrets

## The Target

Learn the correct location for sensitive deployment credentials.

## The Concept

Secrets should never appear in:

- Source files.
- Workflow YAML.
- Commit messages.
- Issue comments.
- Pull-request descriptions.
- `.env.example`.
- Terminal screenshots.

GitHub Actions secrets are encrypted values made available to workflows only when explicitly referenced.

For deployment credentials, prefer **environment secrets** rather than repository-wide secrets.

Why?

```text
Repository secret:
Potentially available to many workflows.

Environment secret:
Available only to workflows targeting that protected environment.
```

## The Implementation

When a real deployment integration exists:

1. Open repository **Settings**.
2. Select **Environments**.
3. Select:

   ```text
   production
   ```

4. Under **Environment secrets**, select **Add secret**.
5. Add only the required credential, such as:

   ```text
   DEPLOYMENT_API_TOKEN
   ```

6. In the deployment workflow, pass it only to the command that needs it:

```yaml
- name: Deploy release
  env:
    DEPLOYMENT_API_TOKEN: ${{ secrets.DEPLOYMENT_API_TOKEN }}
  run: ./scripts/deploy.sh
```

Do not print the variable:

```yaml
# Never do this.
- run: echo "$DEPLOYMENT_API_TOKEN"
```

## The Verification

For this tutorial, do not create a real secret.

Confirm you can recognize the safe pattern:

```yaml
env:
  DEPLOYMENT_API_TOKEN: ${{ secrets.DEPLOYMENT_API_TOKEN }}
```

And the unsafe pattern:

```yaml
run: echo "${{ secrets.DEPLOYMENT_API_TOKEN }}"
```

---

# P.8 Add a Dependency Review Workflow

## The Target

Add a GitHub Action that reviews dependency changes in pull requests.

## The Concept

A dependency update can change application behavior, licensing, security posture, and supply-chain risk.

GitHub’s Dependency Review Action can examine pull requests that modify dependency manifests or lockfiles.

For this project, there are currently no external npm dependencies. Still, adding the workflow establishes a professional safeguard for future dependency additions.

## The Implementation

Create a new workflow file.

### `release-notes-manager/.github/workflows/dependency-review.yml`

```yaml
name: Dependency Review

on:
  pull_request:
    branches:
      - main

permissions:
  contents: read

jobs:
  dependency-review:
    name: Review dependency changes
    runs-on: ubuntu-latest

    steps:
      # GitHub's official Dependency Review Action inspects dependency changes
      # introduced by this pull request. Pin to a reviewed immutable revision
      # in production after verifying the current official release hash.
      - name: Review dependencies
        uses: actions/dependency-review-action@v4
```

> For maximum supply-chain protection, replace `@v4` with a verified full commit hash, following the pinning approach in Step P.3.

Create a branch:

```bash
git switch main
git pull --ff-only
git switch -c ci/add-dependency-review
```

Add, test, commit, and push:

```bash
npm test
git add .github/workflows/dependency-review.yml
git commit -m "ci(actions): add dependency review"
git push -u origin ci/add-dependency-review
```

Open a pull request.

## The Verification

On the pull request, open the **Checks** tab.

Confirm a job named something similar to:

```text
Dependency Review / Review dependency changes
```

runs successfully.

Because the repository has no external dependencies, the workflow may report that no dependency changes require review. That is expected.

---

# P.9 Use Dependency Updates Carefully

## The Target

Understand how automated dependency-update tools fit into a secure workflow.

## The Concept

Tools such as Dependabot can open pull requests when dependencies or GitHub Actions versions have updates.

Automation helps, but it does not eliminate review responsibility.

A dependency-update pull request should still answer:

```text
What changed?
Is the update compatible?
Do tests pass?
Does the dependency introduce new permissions or behavior?
Is there a security advisory?
```

For GitHub Actions, Dependabot can also update pinned commit references and comments when configured correctly.

## The Implementation

On GitHub:

1. Open repository **Settings**.
2. Select **Code security and analysis**.
3. Enable available dependency graph and Dependabot features.
4. If the repository later gains npm dependencies, create this configuration.

### `release-notes-manager/.github/dependabot.yml`

```yaml
version: 2

updates:
  - package-ecosystem: npm
    directory: /
    schedule:
      interval: weekly

  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
```

Create the directory if necessary:

### macOS, Linux, or Git Bash

```bash
mkdir -p .github
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path .github -Force
```

Commit it through a pull request:

```bash
git switch main
git pull --ff-only
git switch -c ci/configure-dependabot
git add .github/dependabot.yml
git commit -m "ci(dependabot): schedule dependency updates"
git push -u origin ci/configure-dependabot
```

## The Verification

After the configuration reaches `main`, GitHub should recognize Dependabot configuration.

Depending on repository activity and available updates, pull requests may not appear immediately.

Confirm the configuration file is present:

```bash
git show HEAD:.github/dependabot.yml
```

---

# P.10 CI Security Review Checklist

## The Target

Use a repeatable checklist when reviewing workflow changes.

## The Concept

Workflow reviews should cover normal correctness and automation-specific security concerns.

Use this checklist for every pull request that changes:

```text
.github/workflows/
.github/dependabot.yml
scripts/
package.json
package-lock.json
```

## The Implementation

Add this section to `CODE_REVIEW.md`.

### `release-notes-manager/CODE_REVIEW.md` — append this section

```md
## GitHub Actions and Automation Review

Review workflow and automation changes with extra care.

- [ ] Workflow permissions use the minimum required access.
- [ ] Test-only workflows use read-only permissions where possible.
- [ ] Third-party Actions come from trusted publishers.
- [ ] Actions are pinned to reviewed immutable commit hashes when project policy requires it.
- [ ] Pull request titles, branch names, issue text, and other untrusted values are not embedded directly into shell scripts.
- [ ] `pull_request_target` is not used to execute untrusted pull request code.
- [ ] Secrets are not printed, committed, or exposed to untrusted workflows.
- [ ] Deployment workflows use protected GitHub Environments.
- [ ] Workflow trigger changes are intentional and documented.
- [ ] CI still runs the required tests after the workflow change.
```

Create a documentation branch:

```bash
git switch main
git pull --ff-only
git switch -c docs/add-automation-review-checklist
```

Run tests:

```bash
npm test
```

Commit and push:

```bash
git add CODE_REVIEW.md
git commit -m "docs(review): add automation security checklist"
git push -u origin docs/add-automation-review-checklist
```

## The Verification

Open a pull request and confirm reviewers can see the new section.

Before merging any workflow change, confirm each checklist item has been considered.

---

# P.11 Safe CI/CD Architecture Reference

A mature repository separates testing from deployment.

```text
Pull Request
    │
    ▼
Read-only CI workflow
    ├── Check out code
    ├── Install dependencies
    ├── Run tests
    └── Report status
    │
    ▼
Merge to protected main
    │
    ▼
Release preparation
    ├── Generate release preview
    ├── Review changelog
    └── Create signed tag and GitHub Release
    │
    ▼
Protected deployment workflow
    ├── Runs only from approved branch or tag
    ├── Targets protected environment
    ├── Receives only environment-specific secrets
    ├── Requires approval when configured
    └── Records deployment result
```

A safe baseline is:

| Workflow type | Typical trigger | Typical permissions | Secrets |
|---|---|---|---|
| Unit test CI | `pull_request`, `push` | `contents: read` | None |
| Dependency review | `pull_request` | `contents: read` | None |
| Release preview | `workflow_dispatch` | `contents: read` | None |
| Release publishing | Protected tag or manual approval | Limited write permissions | Only required release credential |
| Production deployment | Protected tag, manual dispatch, or approved release | Limited deployment permissions | Environment secrets only |

---

# P.12 GitHub Actions Security Command and Review Reference

## Inspect Workflow Files

```bash
find .github/workflows -type f -maxdepth 1 -print
```

## Search for Broad Permissions

```bash
grep -RIn "write-all\|contents: write\|pull-requests: write" .github/workflows
```

## Search for High-Risk Triggers

```bash
grep -RIn "pull_request_target\|workflow_run" .github/workflows
```

## Search for Secret References

```bash
grep -RIn "secrets\." .github/workflows
```

## Search for Third-Party Actions

```bash
grep -RIn "uses:" .github/workflows
```

On Windows PowerShell, use:

```powershell
Get-ChildItem .github\workflows -File |
  Select-String -Pattern "write-all|contents: write|pull-requests: write|pull_request_target|workflow_run|secrets\.|uses:"
```

---

# Appendix P Completion Check

You should now be able to:

- [ ] Treat GitHub Actions workflows as executable production code.
- [ ] Apply least-privilege permissions to CI workflows.
- [ ] Explain why immutable Action pinning improves supply-chain security.
- [ ] Avoid inserting untrusted pull-request data directly into shell scripts.
- [ ] Explain the risk difference between `pull_request` and `pull_request_target`.
- [ ] Use GitHub Environments to protect deployments.
- [ ] Keep deployment secrets scoped to protected environments.
- [ ] Add dependency review and Dependabot configuration.
- [ ] Review automation changes with a dedicated CI/CD security checklist.
- [ ] Separate read-only testing workflows from privileged release and deployment workflows.
