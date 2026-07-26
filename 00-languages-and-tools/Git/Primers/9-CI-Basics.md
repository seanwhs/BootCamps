# Primer 9: YAML, GitHub Actions Workflow Files, and CI Basics

Later in the series, you will create GitHub Actions workflows such as:

```text
.github/workflows/ci.yml
```

These files use **YAML**, a human-readable configuration format.

YAML is used to describe structured information:

```text
Workflow name
    ↓
Trigger events
    ↓
Permissions
    ↓
Jobs
    ↓
Steps
    ↓
Commands
```

This primer teaches the minimum YAML and continuous-integration knowledge needed to read and safely edit GitHub Actions workflows.

You will learn:

- What Continuous Integration (CI) means.
- How YAML uses indentation.
- How lists and key-value pairs work.
- How GitHub Actions workflow files are organized.
- How to recognize common workflow mistakes.
- Why workflow files deserve careful review.

---

# P9.1 Understand Continuous Integration

## The Target

Understand why projects run automated checks after code changes.

## The Concept

**Continuous Integration**, often shortened to **CI**, means automatically checking software whenever changes are proposed or merged.

Think of CI as a quality-inspection station on a production line.

Without CI:

```text
Developer changes code
    ↓
Developer forgets to run tests
    ↓
Broken change reaches main
```

With CI:

```text
Developer changes code
    ↓
Pull request opens
    ↓
CI starts automatically
    ↓
Tests run in a clean environment
    ↓
Pull request cannot merge until required checks pass
```

For this project, CI runs:

```bash
npm test
```

The same command should work:

- On your computer.
- On another contributor’s computer.
- In GitHub Actions.

## The Implementation

Run the project test command locally:

```bash
npm test
```

If you are still working only with documentation and the project does not yet contain `package.json`, this command will not work yet. That is expected. You will add it during Part 4.

For the rest of this primer, focus on understanding the workflow structure.

## The Verification

You should be able to explain:

```text
Local tests:
Fast feedback while I work.

CI tests:
Independent verification before shared code merges.
```

---

# P9.2 Understand YAML Key-Value Pairs

## The Target

Read basic YAML configuration entries.

## The Concept

YAML commonly uses this format:

```yaml
key: value
```

For example:

```yaml
name: Continuous Integration
```

This means:

```text
The value of the "name" setting is "Continuous Integration".
```

Another example:

```yaml
runs-on: ubuntu-latest
```

This means:

```text
Run this job on GitHub's latest supported Ubuntu runner image.
```

YAML is sensitive to indentation. Spaces define nesting.

## The Implementation

Read this simple YAML example:

```yaml
project:
  name: Release Notes Manager
  language: JavaScript
  version: 1.0.0
```

It represents this structure:

```text
project
├── name: Release Notes Manager
├── language: JavaScript
└── version: 1.0.0
```

Notice that `name`, `language`, and `version` have two spaces before them.

## The Verification

Confirm you can identify:

| YAML text | Meaning |
|---|---|
| `project:` | Start a group named `project`. |
| `name: Release Notes Manager` | Set `name` inside that group. |
| Two spaces before `name` | `name` belongs inside `project`. |

---

# P9.3 Understand YAML Lists

## The Target

Recognize a YAML list.

## The Concept

A YAML list uses a dash followed by a space:

```yaml
tools:
  - Git
  - Node.js
  - npm
```

This represents:

```text
tools
├── Git
├── Node.js
└── npm
```

GitHub Actions uses lists for:

- Branches.
- Workflow steps.
- Matrix values.
- Event types.

## The Implementation

Read this example:

```yaml
branches:
  - main
  - release
```

This means:

```text
Apply this setting to:
- main
- release
```

Now inspect this GitHub Actions trigger:

```yaml
on:
  push:
    branches:
      - main
```

It means:

```text
Run this workflow when commits are pushed to main.
```

## The Verification

Confirm that this is a list:

```yaml
- main
- release
```

And this is not a list:

```yaml
branch: main
```

The first contains multiple values. The second contains one value.

---

# P9.4 Understand YAML Indentation

## The Target

Understand why YAML spacing is part of the configuration.

## The Concept

In JavaScript, braces define nesting:

```js
const workflow = {
  push: {
    branches: ["main"]
  }
};
```

In YAML, indentation defines nesting:

```yaml
push:
  branches:
    - main
```

The spaces tell YAML:

```text
branches belongs to push.
main belongs to branches.
```

A missing or incorrect indentation level can make a workflow invalid or change its meaning.

Correct:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
```

Incorrect:

```yaml
jobs:
test:
runs-on: ubuntu-latest
```

The second example loses the parent-child relationship.

## The Implementation

Read this workflow outline:

```yaml
jobs:
  test:
    name: Run tests
    runs-on: ubuntu-latest
```

Its structure is:

```text
jobs
└── test
    ├── name
    └── runs-on
```

Use spaces, not tabs, for YAML indentation.

A common convention is two spaces per nesting level.

## The Verification

Confirm the indentation levels:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
```

| Line | Indentation | Meaning |
|---|---:|---|
| `jobs:` | 0 spaces | Top-level setting |
| `test:` | 2 spaces | Job inside `jobs` |
| `runs-on:` | 4 spaces | Setting inside `test` |

---

# P9.5 Understand a Minimal GitHub Actions Workflow

## The Target

Read the main sections of a basic CI workflow.

## The Concept

A GitHub Actions workflow generally has this shape:

```yaml
name: Friendly workflow name

on:
  Event triggers

permissions:
  GitHub token permissions

jobs:
  One or more jobs
```

A job contains:

```yaml
runs-on:
steps:
```

And each step either:

```yaml
uses:
```

a reusable Action, or:

```yaml
run:
```

a shell command.

## The Implementation

Read this complete workflow.

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

      - name: Run test suite
        run: npm test
```

## The Verification

Identify each section:

| YAML section | Meaning |
|---|---|
| `name` | Name shown in GitHub Actions. |
| `on` | Events that start the workflow. |
| `permissions` | Access granted to the GitHub token. |
| `jobs` | Work units GitHub Actions runs. |
| `test` | Identifier for one job. |
| `runs-on` | Operating system for the job runner. |
| `steps` | Ordered actions and commands in the job. |
| `uses` | Run a reusable Action. |
| `run` | Run a shell command. |

---

# P9.6 Understand Workflow Triggers

## The Target

Understand when a GitHub Actions workflow starts.

## The Concept

The `on` section defines workflow triggers.

This workflow runs in two situations:

```yaml
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
```

In plain language:

```text
Run when:
1. A commit is pushed directly to main.
2. A pull request targeting main is opened or updated.
```

This is a sensible baseline because it checks:

- Code that reaches the stable branch.
- Code proposed for the stable branch.

## The Implementation

Read these trigger examples.

### Push Trigger

```yaml
on:
  push:
    branches:
      - main
```

### Pull Request Trigger

```yaml
on:
  pull_request:
    branches:
      - main
```

### Manual Trigger

```yaml
on:
  workflow_dispatch:
```

`workflow_dispatch` allows someone to start the workflow manually from GitHub’s Actions page.

## The Verification

Match each trigger to its purpose:

| Trigger | Purpose |
|---|---|
| `push` | Run after commits are pushed. |
| `pull_request` | Run when a PR is opened, updated, or otherwise relevant. |
| `workflow_dispatch` | Run manually through GitHub. |

---

# P9.7 Understand Jobs and Steps

## The Target

Understand the difference between a job and a step.

## The Concept

A workflow can contain one or more **jobs**.

A job is a unit of work that runs on a runner, which is a temporary hosted virtual machine.

Inside each job are **steps**.

Think of it this way:

```text
Workflow
└── Job: Run Node.js tests
    ├── Step: Check out repository
    ├── Step: Set up Node.js
    ├── Step: Install dependencies
    └── Step: Run tests
```

Steps run in order within one job.

Different jobs can often run in parallel.

## The Implementation

Read this job:

```yaml
jobs:
  test:
    name: Run Node.js tests
    runs-on: ubuntu-latest

    steps:
      - name: Check out repository
        uses: actions/checkout@v4

      - name: Run test suite
        run: npm test
```

The job identifier is:

```text
test
```

The visible job name is:

```text
Run Node.js tests
```

## The Verification

Confirm:

```text
Workflow:
Continuous Integration

Job:
Run Node.js tests

Steps:
Check out repository
Run test suite
```

---

# P9.8 Understand `uses` Versus `run`

## The Target

Know when a workflow uses a reusable Action and when it runs a shell command.

## The Concept

GitHub Actions steps commonly use one of two patterns.

### Reusable Action

```yaml
uses: actions/checkout@v4
```

This runs a reusable automation component.

For example, `actions/checkout` downloads repository files into the temporary runner workspace.

### Shell Command

```yaml
run: npm test
```

This runs a command in the runner’s shell.

Think of the difference:

```text
uses:
Use a packaged tool.

run:
Type a command into the runner terminal.
```

## The Implementation

Read these examples:

```yaml
- name: Check out repository
  uses: actions/checkout@v4
```

```yaml
- name: Run test suite
  run: npm test
```

A multi-line command uses a pipe:

```yaml
- name: Inspect environment
  run: |
    node --version
    npm --version
    npm test
```

The `|` means:

> “The following indented lines are one multi-line text value.”

## The Verification

Confirm:

| Step content | Type |
|---|---|
| `uses: actions/checkout@v4` | Reusable Action |
| `run: npm test` | Shell command |
| `run: \|` followed by commands | Multi-line shell command |

---

# P9.9 Understand Workflow Permissions

## The Target

Understand why test workflows should use minimal GitHub permissions.

## The Concept

GitHub provides workflows with a token called:

```text
GITHUB_TOKEN
```

This token can receive different permissions.

A test-only workflow should normally need only:

```yaml
permissions:
  contents: read
```

That means:

```text
The workflow may read repository files.
It may not write commits, create releases, or modify pull requests.
```

This follows the **principle of least privilege**:

> Give automation only the access it needs for its job.

## The Implementation

Read this permission block:

```yaml
permissions:
  contents: read
```

Avoid broad permissions in ordinary CI workflows:

```yaml
permissions: write-all
```

Do not use `write-all` unless you understand exactly why a workflow needs broad write access and have reviewed the security impact.

## The Verification

Confirm this rule:

| Workflow purpose | Typical permission |
|---|---|
| Run tests | `contents: read` |
| Create GitHub Release | May require narrowly scoped write permission |
| Deploy to production | Use protected environment and only required secrets |
| Comment on pull requests | May require `pull-requests: write` |

---

# P9.10 Understand the Fresh-Environment Principle

## The Target

Understand why CI may fail even when tests pass locally.

## The Concept

GitHub Actions starts from a clean temporary machine.

That means it does not have:

- Your local files.
- Your uncommitted changes.
- Your editor configuration.
- Your saved credentials.
- Your globally installed packages.
- Your local environment variables unless explicitly configured.

This is useful because it exposes hidden assumptions.

For example:

```text
Works on my computer
    ↓
Fails in CI
    ↓
The project depended on something not documented or committed
```

CI should be treated as a clean-room verification environment.

## The Implementation

A normal Node.js CI sequence is:

```yaml
steps:
  - name: Check out repository
    uses: actions/checkout@v4

  - name: Set up Node.js
    uses: actions/setup-node@v4
    with:
      node-version: "20"

  - name: Install dependencies
    run: npm install

  - name: Run tests
    run: npm test
```

Each step prepares something required by the next:

```text
Check out code
    ↓
Install runtime
    ↓
Install dependencies
    ↓
Run project tests
```

## The Verification

Before expecting CI to pass, confirm locally:

```bash
npm test
```

Then confirm that all required source files, package configuration, and test files are committed:

```bash
git status
git diff --staged
```

---

# P9.11 Recognize Common YAML and Workflow Mistakes

## The Target

Identify common workflow problems before pushing them.

## The Concept

YAML errors are often small but important.

### Mistake: Using Tabs

Incorrect:

```yaml
jobs:
	test:
```

Correct:

```yaml
jobs:
  test:
```

Use spaces, not tabs.

### Mistake: Incorrect Indentation

Incorrect:

```yaml
jobs:
  test:
  runs-on: ubuntu-latest
```

Correct:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
```

### Mistake: Running Tests Before Checking Out Code

Incorrect:

```yaml
steps:
  - name: Run tests
    run: npm test
```

Correct:

```yaml
steps:
  - name: Check out repository
    uses: actions/checkout@v4

  - name: Run tests
    run: npm test
```

### Mistake: Giving Test Workflows Broad Permissions

Incorrect:

```yaml
permissions: write-all
```

Better baseline:

```yaml
permissions:
  contents: read
```

## The Implementation

Before committing a workflow change, inspect it:

```bash
git diff -- .github/workflows/ci.yml
```

Check for tabs.

### macOS, Linux, or Git Bash

```bash
grep -nP '\t' .github/workflows/ci.yml
```

### Windows PowerShell

```powershell
Select-String -Path .github\workflows\ci.yml -Pattern "`t"
```

No output means no tabs were found.

## The Verification

Review every workflow change with this checklist:

```text
[ ] YAML uses spaces, not tabs.
[ ] Indentation correctly reflects nested structure.
[ ] The trigger is intentional.
[ ] The workflow has only required permissions.
[ ] Repository checkout happens before project commands.
[ ] Runtime setup happens before tests.
[ ] Commands match the project’s documented local commands.
[ ] No secrets are printed or embedded in workflow YAML.
```

---

# P9.12 Inspect GitHub Actions Results

## The Target

Know where to find CI results after pushing a branch or opening a pull request.

## The Concept

GitHub displays workflow results in several places:

```text
Pull request → Checks tab
Repository → Actions tab
Commit page → Status checks
```

A successful workflow appears as a green check.

A failed workflow appears as a red X.

When a workflow fails, inspect the first meaningful error rather than changing random files until it passes.

## The Implementation

Using GitHub CLI, list recent workflow runs:

```bash
gh run list
```

Watch the newest run:

```bash
gh run watch
```

View a failed run’s failed logs:

```bash
gh run view RUN_ID --log-failed
```

Replace `RUN_ID` with the workflow run identifier.

Without GitHub CLI:

1. Open the repository on GitHub.
2. Select **Actions**.
3. Open the workflow run.
4. Select the failed job.
5. Expand the failed step.
6. Read the error output.

## The Verification

A successful workflow should show:

```text
Run Node.js tests
✓ Success
```

If it fails:

```text
[ ] Identify the failed step.
[ ] Read the command output.
[ ] Reproduce the error locally when possible.
[ ] Fix the underlying problem.
[ ] Run tests locally.
[ ] Commit and push the fix.
```

---

# Primer 9 Reference: Minimal Safe Node.js CI Workflow

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

      - name: Install dependencies
        run: npm install

      - name: Run test suite
        run: npm test
```

---

# Primer 9 Completion Check

Before creating or editing GitHub Actions workflows, confirm that you can:

- [ ] Explain why CI runs tests automatically.
- [ ] Read YAML key-value pairs.
- [ ] Read YAML lists.
- [ ] Explain why YAML indentation matters.
- [ ] Identify workflow triggers, jobs, and steps.
- [ ] Explain `uses` versus `run`.
- [ ] Explain why a test workflow should use `contents: read`.
- [ ] Explain why CI runs in a fresh environment.
- [ ] Identify common YAML indentation and permission mistakes.
- [ ] Find and inspect workflow results on GitHub or with `gh run`.
