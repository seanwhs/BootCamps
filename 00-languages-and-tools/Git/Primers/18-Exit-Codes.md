# Primer 18: Exit Codes, Shell Scripts, and Automation Reliability

Git hooks, npm scripts, and GitHub Actions all rely on a simple operating-system convention:

```text
Exit code 0
    = Success

Nonzero exit code
    = Failure
```

This convention is what allows automation to decide whether a command passed or failed.

For example:

```bash
npm test
```

If tests pass, the command exits successfully.

If tests fail, the command returns a nonzero exit code. GitHub Actions detects that failure and marks the workflow run as failed.

This primer explains the basic shell and automation behavior behind:

- Git hooks.
- npm scripts.
- GitHub Actions.
- Test commands.
- CI checks.
- Shell-script safety settings.

---

# P18.1 Understand Exit Codes

## The Target

Understand how terminal commands report success or failure.

## The Concept

A terminal command does not only print text. It also returns a numeric result called an **exit code**.

The standard meaning is:

| Exit code | Meaning |
|---:|---|
| `0` | Success |
| Any nonzero value | Failure |

For example:

```bash
node --version
```

normally succeeds and returns:

```text
0
```

A command that cannot find a file may fail and return a nonzero value.

Automation tools do not need to understand every printed message. They can make decisions based on the exit code.

```text
Run tests
    ↓
Exit code 0
    ↓
Mark check as successful

Run tests
    ↓
Exit code 1
    ↓
Mark check as failed
```

## The Implementation

Run a command that should succeed:

```bash
node --version
```

Then inspect its exit code.

### macOS, Linux, or Git Bash

```bash
echo $?
```

### Windows PowerShell

```powershell
$LASTEXITCODE
```

Now run a command that should fail because the file does not exist:

### macOS, Linux, or Git Bash

```bash
cat file-that-does-not-exist.txt
echo $?
```

### Windows PowerShell

```powershell
Get-Content file-that-does-not-exist.txt
$LASTEXITCODE
```

## The Verification

After `node --version`, the exit code should be:

```text
0
```

After attempting to read a nonexistent file, the command should report an error.

On PowerShell, some built-in command failures may behave differently from external program exit codes. For Git, Node.js, npm, and shell scripts, `$LASTEXITCODE` is especially useful after external commands.

---

# P18.2 Understand Why Tests Control CI Status

## The Target

Connect test results to command exit codes and GitHub Actions workflow outcomes.

## The Concept

A test runner evaluates assertions.

If every assertion passes:

```text
Tests pass
    ↓
npm test exits with 0
    ↓
GitHub Actions marks the job successful
```

If one or more assertions fail:

```text
Tests fail
    ↓
npm test exits with a nonzero code
    ↓
GitHub Actions marks the job failed
```

This is why a GitHub Actions workflow can be simple:

```yaml
- name: Run test suite
  run: npm test
```

GitHub Actions does not need special JavaScript knowledge. It only needs to know whether the command succeeded.

## The Implementation

Run tests:

```bash
npm test
```

Inspect the exit code afterward.

### macOS, Linux, or Git Bash

```bash
echo $?
```

### Windows PowerShell

```powershell
$LASTEXITCODE
```

## The Verification

When tests pass, expected exit code:

```text
0
```

When a test fails, expected exit code:

```text
1
```

or another nonzero value.

This is the core link between local verification and CI enforcement.

---

# P18.3 Understand Shell Scripts

## The Target

Understand why repositories use shell scripts for repeatable automation.

## The Concept

A shell script is a text file containing terminal commands.

Instead of asking contributors to remember several commands:

```bash
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
chmod +x .githooks/pre-push
```

a repository can provide one script:

```bash
./scripts/install-hooks.sh
```

Scripts make workflows:

- Repeatable.
- Easier to document.
- Easier to review.
- Less dependent on memory.
- More consistent across contributors.

Think of a script as a written checklist that the computer executes consistently.

## The Implementation

Inspect the hook-installation script if it exists:

```bash
cat scripts/install-hooks.sh
```

On Windows PowerShell:

```powershell
Get-Content scripts\install-hooks.sh
```

A safe shell-script structure resembles:

### `scripts/example.sh`

```sh
#!/usr/bin/env sh

set -eu

echo "Running project checks..."

npm test

echo "Project checks passed."
```

## The Verification

Identify each line:

| Script line | Meaning |
|---|---|
| `#!/usr/bin/env sh` | Run the script using a compatible shell. |
| `set -eu` | Stop on command failures and undefined variables. |
| `echo "..."` | Print a progress message. |
| `npm test` | Run the project test suite. |

---

# P18.4 Understand the Shebang Line

## The Target

Recognize the first line that tells an operating system how to run a script.

## The Concept

A **shebang** is the first line of many Unix-like scripts:

```sh
#!/usr/bin/env sh
```

It tells the operating system:

> “Use `sh` to interpret this file.”

For Node.js scripts, a shebang might be:

```js
#!/usr/bin/env node
```

For Python:

```python
#!/usr/bin/env python3
```

The `env` command finds the program using the current environment’s `PATH`.

This is more portable than assuming a program always lives at one fixed location.

## The Implementation

Inspect scripts in the repository.

### macOS, Linux, or Git Bash

```bash
find scripts .githooks -type f -maxdepth 2 -print -exec head -n 1 {} \;
```

### Windows PowerShell

```powershell
Get-ChildItem scripts, .githooks -Recurse -File -ErrorAction SilentlyContinue |
  ForEach-Object {
    Write-Output $_.FullName
    Get-Content $_.FullName -TotalCount 1
  }
```

## The Verification

Shell hooks and shell scripts should begin with a line similar to:

```sh
#!/usr/bin/env sh
```

This helps Git and operating systems know how to run them.

---

# P18.5 Use `set -eu` for Safer Shell Scripts

## The Target

Understand the basic shell safety settings used in repository scripts.

## The Concept

This line appears in many safe shell scripts:

```sh
set -eu
```

It combines two safeguards.

### `-e`

Stop the script if a command fails.

Without it:

```sh
npm test
echo "Tests passed."
```

might print:

```text
Tests passed.
```

even if `npm test` failed.

With `-e`, the script stops immediately after the failure.

### `-u`

Stop the script if it tries to use an undefined variable.

Without it:

```sh
echo "$DEPLOYMENT_TOKEN"
```

might quietly use an empty value if the variable was never configured.

With `-u`, the script stops and reports the missing variable.

## The Implementation

Create a temporary demonstration script.

### `shell-safety-practice.sh`

```sh
#!/usr/bin/env sh

set -eu

PROJECT_NAME="${PROJECT_NAME:-Release Notes Manager}"

printf 'Project: %s\n' "$PROJECT_NAME"
printf 'Running tests...\n'

npm test

printf 'Tests completed successfully.\n'
```

Run it.

### macOS, Linux, or Git Bash

```bash
chmod +x shell-safety-practice.sh
./shell-safety-practice.sh
```

### Windows PowerShell

```powershell
bash ./shell-safety-practice.sh
```

Remove it after the exercise.

### macOS, Linux, or Git Bash

```bash
rm shell-safety-practice.sh
```

### Windows PowerShell

```powershell
Remove-Item shell-safety-practice.sh
```

## The Verification

Expected output includes:

```text
Project: Release Notes Manager
Running tests...
```

Then the test output.

If tests pass, the final line is:

```text
Tests completed successfully.
```

If tests fail, the script stops before printing that final success message.

---

# P18.6 Understand Safe Default Values

## The Target

Use shell-variable defaults without hiding required configuration errors.

## The Concept

This syntax provides a default value:

```sh
"${PROJECT_NAME:-Release Notes Manager}"
```

It means:

> “Use `PROJECT_NAME` if it exists and is non-empty; otherwise use `Release Notes Manager`.”

This is appropriate for optional configuration.

For required configuration, do not silently use a potentially unsafe default.

Use:

```sh
"${DEPLOYMENT_TOKEN:?DEPLOYMENT_TOKEN must be set}"
```

This means:

> “Stop immediately with this message if `DEPLOYMENT_TOKEN` is missing or empty.”

## The Implementation

Read these examples.

Optional value with a safe default:

```sh
LOG_LEVEL="${LOG_LEVEL:-info}"
```

Required deployment credential:

```sh
DEPLOYMENT_TOKEN="${DEPLOYMENT_TOKEN:?DEPLOYMENT_TOKEN must be set}"
```

Required project file:

```sh
if [ ! -f "package.json" ]; then
  echo "ERROR: package.json was not found."
  exit 1
fi
```

## The Verification

Classify each configuration value:

| Value | Optional or required? | Suitable behavior |
|---|---|---|
| Local log level | Usually optional | Default to `info` |
| Release version in a release script | Usually required | Stop with a clear error |
| Deployment token | Required | Stop with a clear error |
| Test command | Required for CI | Fail if unavailable |

---

# P18.7 Use `printf` for Predictable Output

## The Target

Understand why portable shell scripts often use `printf` instead of `echo`.

## The Concept

`echo` is simple:

```sh
echo "Running tests"
```

But `echo` behavior can vary across shells when text contains escape-like values or option-looking content.

`printf` is more predictable:

```sh
printf 'Running tests\n'
```

For variables:

```sh
printf 'Current branch: %s\n' "$BRANCH_NAME"
```

This explicitly states the expected output format.

## The Implementation

Compare these commands:

```bash
echo "Release Notes Manager"
printf 'Release Notes Manager\n'
```

Now print a variable safely:

```bash
PROJECT_NAME="Release Notes Manager"
printf 'Project: %s\n' "$PROJECT_NAME"
```

## The Verification

Expected output:

```text
Release Notes Manager
Project: Release Notes Manager
```

For simple messages, both commands may look identical. `printf` is preferred in portability-focused scripts because its behavior is more explicit.

---

# P18.8 Understand Quoting in Shell Scripts

## The Target

Prevent shell scripts from misreading paths and values containing spaces or special characters.

## The Concept

Always quote variable expansions unless you explicitly need splitting behavior.

Unsafe:

```sh
cd $PROJECT_PATH
```

If the path is:

```text
/Users/jordan/My Projects/release-notes-manager
```

the shell may treat it as multiple arguments.

Safe:

```sh
cd "$PROJECT_PATH"
```

Likewise:

```sh
git add "$FILE_PATH"
```

is safer than:

```sh
git add $FILE_PATH
```

Think of quotes as a box around a value:

```text
Without quotes:
The shell may break this value apart.

With quotes:
Treat the full value as one item.
```

## The Implementation

Run:

```bash
PROJECT_PATH="Release Notes Manager"
printf 'Project path: %s\n' "$PROJECT_PATH"
```

Do not rely on unquoted variables in scripts.

Use this safe script pattern:

```sh
PROJECT_ROOT="$(git rev-parse --show-toplevel)"

cd "$PROJECT_ROOT"

if [ ! -f "$PROJECT_ROOT/package.json" ]; then
  echo "ERROR: package.json is missing."
  exit 1
fi
```

## The Verification

Confirm that every variable in a shell command is quoted unless there is a documented reason not to quote it:

```sh
"$PROJECT_ROOT"
"$FILE_PATH"
"$BRANCH_NAME"
```

---

# P18.9 Understand Git Hook Failure Behavior

## The Target

Understand how Git uses hook exit codes to allow or block commands.

## The Concept

A Git hook is a script run automatically by Git at a specific point.

For example:

```text
pre-commit
    ↓
Runs before Git creates a commit.
```

If the hook exits with:

```text
0
```

Git continues.

If the hook exits with a nonzero code:

```text
1
```

Git cancels the commit.

Example pre-commit hook:

### `.githooks/pre-commit`

```sh
#!/usr/bin/env sh

set -eu

npm test
```

If tests pass:

```text
Hook exits 0
    ↓
Commit continues
```

If tests fail:

```text
Hook exits nonzero
    ↓
Commit stops
```

## The Implementation

Inspect the active hook path:

```bash
git config --get core.hooksPath
```

Expected output when repository hooks are enabled:

```text
.githooks
```

Inspect the pre-commit hook:

```bash
cat .githooks/pre-commit
```

On Windows PowerShell:

```powershell
Get-Content .githooks\pre-commit
```

Run it manually.

### macOS, Linux, or Git Bash

```bash
.githooks/pre-commit
```

### Windows PowerShell

```powershell
bash .githooks/pre-commit
```

## The Verification

Expected output includes passing tests and a success message such as:

```text
Pre-commit checks passed.
```

If tests fail, the hook should return a nonzero result and Git should block a normal commit.

---

# P18.10 Understand Workflow Job Failure Behavior

## The Target

Understand how a single failed GitHub Actions step affects a job.

## The Concept

In GitHub Actions, a step using:

```yaml
run: npm test
```

fails if `npm test` returns a nonzero exit code.

By default:

```text
Failed step
    ↓
Job fails
    ↓
Workflow may fail
    ↓
Required check blocks pull request merge
```

A workflow can deliberately allow a failure:

```yaml
continue-on-error: true
```

But this should be used carefully.

For a required test step, do **not** add:

```yaml
continue-on-error: true
```

That would allow failing tests to produce a workflow that may appear less severe than intended.

## The Implementation

Read this required test step:

```yaml
- name: Run test suite
  run: npm test
```

Read this risky pattern:

```yaml
- name: Run test suite
  run: npm test
  continue-on-error: true
```

The second pattern may be reasonable only for experimental, optional, or informational checks.

## The Verification

Confirm the rule:

| Check type | Should failure block merge? |
|---|---:|
| Unit tests | Usually yes |
| Security scan required by policy | Usually yes |
| Optional experimental test | Sometimes no |
| Informational report | Often no |
| Deployment smoke test | Depends on environment and release policy |

---

# P18.11 Automation Reliability Checklist

## The Target

Use practical rules when writing or reviewing scripts, hooks, and CI workflows.

## The Concept

Automation should fail clearly rather than silently reporting success after a hidden error.

## The Implementation

Use this checklist:

```text
Shell scripts
[ ] Script begins with an appropriate shebang.
[ ] Script uses `set -eu` unless there is a documented reason not to.
[ ] Variables are quoted.
[ ] Required configuration fails clearly if missing.
[ ] Optional configuration uses safe defaults.
[ ] Scripts do not print secrets.
[ ] Success messages appear only after required commands complete.

Git hooks
[ ] Hook scripts are executable where required.
[ ] Hooks run the same core commands used by CI when practical.
[ ] Hooks fail with nonzero status when checks fail.
[ ] Bypass options are used only for understood exceptions.

GitHub Actions
[ ] Required checks do not use `continue-on-error: true`.
[ ] Workflow permissions are minimal.
[ ] Commands run in the correct order.
[ ] CI uses deterministic dependency installation when lockfiles exist.
[ ] Workflow failures are investigated from the first meaningful error.
```

## The Verification

Inspect local scripts and workflow files:

```bash
git diff --check
grep -RIn "continue-on-error\|set -eu\|permissions:" .github .githooks scripts
```

On Windows PowerShell:

```powershell
Get-ChildItem .github, .githooks, scripts -Recurse -File -ErrorAction SilentlyContinue |
  Select-String -Pattern "continue-on-error|set -eu|permissions:"
```

Review any match in context before changing it.

---

# Primer 18 Reference: Exit Codes and Automation Commands

## Show the Last Exit Code

### macOS, Linux, or Git Bash

```bash
echo $?
```

### Windows PowerShell

```powershell
$LASTEXITCODE
```

## Run Tests

```bash
npm test
```

## Run a Shell Script

### macOS, Linux, or Git Bash

```bash
./scripts/install-hooks.sh
```

### Windows PowerShell

```powershell
bash ./scripts/install-hooks.sh
```

## Inspect Hook Configuration

```bash
git config --get core.hooksPath
```

## Inspect a Workflow Run

```bash
gh run list
gh run view RUN_ID --log-failed
```

---

# Primer 18 Completion Check

Before writing local automation or CI workflows, confirm that you can:

- [ ] Explain what exit code `0` means.
- [ ] Explain why nonzero exit codes fail hooks and CI steps.
- [ ] Connect `npm test` results to GitHub Actions check status.
- [ ] Recognize a shell-script shebang.
- [ ] Explain why `set -eu` improves shell-script safety.
- [ ] Use safe defaults for optional configuration and clear failures for required configuration.
- [ ] Quote shell variables safely.
- [ ] Explain how Git hooks block commits or pushes when they fail.
- [ ] Explain why required CI checks should not ignore test failures.
- [ ] Review scripts and workflows for clear, reliable failure behavior.
