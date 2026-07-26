# Appendix I: Git Hooks, Local Quality Gates, and Commit Automation

Git hooks are local scripts that Git runs automatically at specific points in a workflow.

For example, a hook can:

- Run tests before a commit is created.
- Prevent commits containing likely secrets.
- Check formatting before code is pushed.
- Validate commit-message structure.
- Run custom project checks before a push.

Think of hooks as a safety checkpoint at the entrance to a warehouse. Before a package leaves, the checkpoint verifies that it meets basic rules.

GitHub Actions performs checks after code reaches GitHub. Git hooks perform checks on your computer before code leaves it.

```text
Local development
    │
    ├── Git hooks: quick local safeguards
    │
    ├── git commit
    │
    ├── git push
    │
    ▼
GitHub
    │
    └── GitHub Actions: shared, enforceable CI checks
```

Important:

> Local hooks are helpful, but they are not a security boundary.

A contributor can skip hooks with certain Git options, use another machine without hooks, or modify hook files locally. Critical checks must also run in CI and be required by branch protection.

---

# I.1 Understand Hook Locations and Limitations

## The Target

Learn where Git hooks live and why they must not be your only quality-control mechanism.

## The Concept

For a standard local repository, Git hooks live in:

```text
.git/hooks/
```

Git installs sample hook files when you initialize a repository. Sample hooks usually end with `.sample`, so Git does not run them.

Typical hook names include:

```text
pre-commit
commit-msg
pre-push
post-commit
```

Their purpose is determined by the filename.

| Hook | Runs when | Typical use |
|---|---|---|
| `pre-commit` | Before a commit is created | Tests, formatting, secret scanning |
| `commit-msg` | After Git creates a commit-message file but before committing | Commit-message validation |
| `pre-push` | Before commits are pushed | Tests, branch checks, protected-branch reminders |
| `post-commit` | After a commit completes | Local notifications or logging |

The `.git` directory is not normally committed to GitHub. Therefore, a hook located only in `.git/hooks/` is not automatically shared with other contributors.

Later in this appendix, you will create version-controlled hook scripts in:

```text
.githooks/
```

Then configure Git to use that directory.

## The Implementation

Inspect the current hook directory.

### macOS, Linux, or Git Bash

```bash
ls -la .git/hooks
```

### Windows PowerShell

```powershell
Get-ChildItem -Force .git\hooks
```

Inspect your configured hooks path:

```bash
git config --get core.hooksPath
```

## The Verification

You will likely see sample files such as:

```text
pre-commit.sample
pre-push.sample
commit-msg.sample
```

The configuration command may produce no output. That means Git uses the default location:

```text
.git/hooks
```

---

# I.2 Create a Version-Controlled Hooks Directory

## The Target

Create a `.githooks` directory that can be committed and shared with contributors.

## The Concept

Instead of placing custom hooks directly into `.git/hooks`, keep the hook scripts in the project itself:

```text
release-notes-manager/
├── .githooks/
│   ├── pre-commit
│   ├── commit-msg
│   └── pre-push
├── .github/
├── src/
└── ...
```

This means hook logic can be:

- Reviewed in pull requests.
- Versioned alongside code.
- Updated consistently.
- Documented for contributors.

Each developer still must configure their local Git installation to use `.githooks`.

## The Implementation

From the repository root, create the directory.

### macOS, Linux, or Git Bash

```bash
mkdir -p .githooks
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path .githooks -Force
```

Create a small README describing the setup.

### `release-notes-manager/.githooks/README.md`

```md
# Local Git Hooks

This directory contains version-controlled local Git hook scripts for Release Notes Manager.

## Enable Hooks

From the repository root, run:

```bash
git config core.hooksPath .githooks
```

This configures the current local repository to use `.githooks` instead of the default `.git/hooks` directory.

## Important Notes

- Hooks run locally on each contributor's machine.
- Hooks are helpful quality checks, but they can be bypassed.
- GitHub Actions remains the shared source of truth for required automated checks.
- On macOS and Linux, hook scripts must be executable.
```

Configure this repository to use the directory:

```bash
git config core.hooksPath .githooks
```

Verify the setting:

```bash
git config --get core.hooksPath
```

## The Verification

Expected output:

```text
.githooks
```

Check the directory exists.

### macOS, Linux, or Git Bash

```bash
ls -la .githooks
```

### Windows PowerShell

```powershell
Get-ChildItem -Force .githooks
```

You should see:

```text
README.md
```

---

# I.3 Create a Pre-Commit Hook That Runs Tests

## The Target

Create a `pre-commit` hook that prevents a commit when the Node.js tests fail.

## The Concept

A `pre-commit` hook runs after files are staged but before Git creates the commit.

This is useful because it catches broken changes before they enter local history.

The hook will:

1. Confirm that Node.js and npm are available.
2. Run `npm test`.
3. Stop the commit if tests fail.
4. Allow the commit if tests pass.

A hook exits with a numeric status code:

```text
0      Success
nonzero Failure
```

When a hook exits with a nonzero status, Git cancels the operation.

## The Implementation

Create this hook file.

### `release-notes-manager/.githooks/pre-commit`

```sh
#!/usr/bin/env sh

# Exit immediately if any command fails.
set -eu

echo "Running pre-commit checks..."

# Confirm that npm is available before trying to run project tests.
if ! command -v npm >/dev/null 2>&1; then
  echo "ERROR: npm is required to run pre-commit checks."
  echo "Install Node.js and npm, then try the commit again."
  exit 1
fi

# Run the repository's standard test command. Keeping this command identical
# to CI makes local and remote validation behavior easier to understand.
npm test

echo "Pre-commit checks passed."
```

On macOS, Linux, or Git Bash, make it executable:

```bash
chmod +x .githooks/pre-commit
```

On Windows, Git for Windows generally executes hook scripts through its included shell when the script has a valid shebang line, such as:

```sh
#!/usr/bin/env sh
```

Test the hook without creating a real commit:

```bash
.githooks/pre-commit
```

On Windows PowerShell, invoke it through Git Bash if direct execution does not work:

```powershell
bash .githooks/pre-commit
```

Commit the hook files through a feature branch and pull request rather than directly to protected `main`:

```bash
git switch -c ci/add-local-git-hooks
git add .githooks/README.md .githooks/pre-commit
git commit -m "Add pre-commit test hook"
git push -u origin ci/add-local-git-hooks
```

## The Verification

The manual hook run should include passing test output:

```text
Running pre-commit checks...
...
# fail 0
Pre-commit checks passed.
```

After committing, check the history:

```bash
git log --oneline -1
```

Expected output:

```text
<hash> Add pre-commit test hook
```

The fact that the commit succeeded also verifies that Git executed the `pre-commit` hook successfully.

---

# I.4 Create a Commit-Message Hook

## The Target

Create a `commit-msg` hook that rejects empty or vague commit messages.

## The Concept

A commit message is part of the project’s long-term documentation.

A `commit-msg` hook receives the path to Git’s temporary commit-message file as its first argument:

```sh
$1
```

The hook will reject messages that are:

- Empty.
- Too short.
- Generic messages such as `update`, `changes`, `fix`, or `wip`.

This is not meant to enforce perfect prose. It is meant to prevent the most unhelpful messages from entering history.

## The Implementation

Create this file.

### `release-notes-manager/.githooks/commit-msg`

```sh
#!/usr/bin/env sh

set -eu

COMMIT_MESSAGE_FILE="$1"

# Remove comment lines that Git may add when opening an editor.
COMMIT_MESSAGE=$(grep -v '^[[:space:]]*#' "$COMMIT_MESSAGE_FILE" | sed '/^[[:space:]]*$/d' | tr '\n' ' ' | sed 's/[[:space:]][[:space:]]*/ /g' | sed 's/^ //; s/ $//')

if [ -z "$COMMIT_MESSAGE" ]; then
  echo "ERROR: Commit message cannot be empty."
  exit 1
fi

MESSAGE_LENGTH=${#COMMIT_MESSAGE}

if [ "$MESSAGE_LENGTH" -lt 12 ]; then
  echo "ERROR: Commit message must contain at least 12 characters."
  echo "Write a concise action-oriented message, such as:"
  echo "  Add release note formatter tests"
  exit 1
fi

NORMALIZED_MESSAGE=$(printf '%s' "$COMMIT_MESSAGE" | tr '[:upper:]' '[:lower:]')

case "$NORMALIZED_MESSAGE" in
  update|updates|change|changes|fix|fixed|wip|test|testing|stuff)
    echo "ERROR: Commit message is too vague: \"$COMMIT_MESSAGE\""
    echo "Describe the actual change, such as:"
    echo "  Fix invalid release date handling"
    exit 1
    ;;
esac

echo "Commit message check passed."
```

On macOS, Linux, or Git Bash:

```bash
chmod +x .githooks/commit-msg
```

Test the hook manually with a temporary message file.

### macOS, Linux, or Git Bash

```bash
printf "Add local hook documentation\n" > /tmp/git-commit-message-test.txt
.githooks/commit-msg /tmp/git-commit-message-test.txt
rm /tmp/git-commit-message-test.txt
```

### Windows PowerShell

```powershell
'Add local hook documentation' | Set-Content -Path "$env:TEMP\git-commit-message-test.txt"
bash .githooks/commit-msg "$env:TEMP\git-commit-message-test.txt"
Remove-Item "$env:TEMP\git-commit-message-test.txt"
```

Test a rejected message.

### macOS, Linux, or Git Bash

```bash
printf "update\n" > /tmp/git-commit-message-test.txt
.githooks/commit-msg /tmp/git-commit-message-test.txt
rm /tmp/git-commit-message-test.txt
```

### Windows PowerShell

```powershell
'update' | Set-Content -Path "$env:TEMP\git-commit-message-test.txt"
bash .githooks/commit-msg "$env:TEMP\git-commit-message-test.txt"
Remove-Item "$env:TEMP\git-commit-message-test.txt"
```

The rejected test intentionally exits with an error. That is expected.

Stage and commit the hook:

```bash
git add .githooks/commit-msg
git commit -m "Validate local commit messages"
```

## The Verification

The valid manual test should print:

```text
Commit message check passed.
```

The invalid manual test should print an error similar to:

```text
ERROR: Commit message is too vague: "update"
```

After committing the hook, verify:

```bash
git show --stat HEAD
```

Expected output includes:

```text
.githooks/commit-msg | ...
```

---

# I.5 Create a Pre-Push Hook That Runs Tests

## The Target

Create a `pre-push` hook that runs tests before sending commits to GitHub.

## The Concept

A `pre-push` hook runs after you type:

```bash
git push
```

but before Git sends the commits to the remote.

This creates a last local quality gate.

The hook will:

- Skip tests if no `package.json` exists.
- Run `npm test` for this Node.js project.
- Cancel the push if tests fail.

There is intentional overlap with `pre-commit` and GitHub Actions:

```text
pre-commit  → catches broken code before local history
pre-push    → catches broken code before network publication
CI          → validates independently on GitHub for every contributor
```

Redundancy is useful when each layer serves a different point in the workflow.

## The Implementation

Create this file.

### `release-notes-manager/.githooks/pre-push`

```sh
#!/usr/bin/env sh

set -eu

echo "Running pre-push checks..."

# This hook is reusable in repositories without Node.js. If package.json does
# not exist, there is no npm test command to run, so the hook exits safely.
if [ ! -f "package.json" ]; then
  echo "No package.json found. Skipping npm test."
  exit 0
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "ERROR: npm is required to run pre-push checks."
  exit 1
fi

npm test

echo "Pre-push checks passed."
```

On macOS, Linux, or Git Bash:

```bash
chmod +x .githooks/pre-push
```

Test the hook manually:

```bash
.githooks/pre-push
```

On Windows PowerShell:

```powershell
bash .githooks/pre-push
```

Commit it:

```bash
git add .githooks/pre-push
git commit -m "Add pre-push test hook"
```

Push your hook branch:

```bash
git push
```

The pre-push hook should execute before Git uploads the branch.

## The Verification

When pushing, output should include:

```text
Running pre-push checks...
...
# fail 0
Pre-push checks passed.
```

Then Git should proceed with the normal push output.

On GitHub, open a pull request for `ci/add-local-git-hooks` and merge it after CI and review succeed.

After merge, update local `main`:

```bash
git switch main
git pull --ff-only
git fetch --prune
```

---

# I.6 Add a Hook Installation Script

## The Target

Create a copy-pasteable setup script that enables project hooks for contributors.

## The Concept

Version-controlled hook scripts do not run until each contributor configures:

```bash
git config core.hooksPath .githooks
```

A setup script makes that one-time step easy and reduces onboarding mistakes.

The script will:

1. Confirm it runs from a Git repository.
2. Configure `.githooks` as the local hooks path.
3. Ensure hooks are executable on Unix-like systems.
4. Print the resulting configuration.

## The Implementation

Create a scripts directory.

### macOS, Linux, or Git Bash

```bash
mkdir -p scripts
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path scripts -Force
```

Create this file.

### `release-notes-manager/scripts/install-hooks.sh`

```sh
#!/usr/bin/env sh

set -eu

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: Run this script from inside a Git repository."
  exit 1
fi

if [ ! -d ".githooks" ]; then
  echo "ERROR: .githooks directory does not exist."
  exit 1
fi

git config core.hooksPath .githooks

# chmod is available in macOS, Linux, and Git Bash. If it is unavailable,
# Git for Windows can still run shell hooks through Git Bash when appropriate.
if command -v chmod >/dev/null 2>&1; then
  chmod +x .githooks/pre-commit .githooks/commit-msg .githooks/pre-push
fi

echo "Git hooks are enabled for this repository."
echo "Configured hooks path: $(git config --get core.hooksPath)"
```

On macOS, Linux, or Git Bash:

```bash
chmod +x scripts/install-hooks.sh
```

Update `CONTRIBUTING.md` by adding this section after the **Set Up the Project** section.

### `release-notes-manager/CONTRIBUTING.md` — add this section

```md
## Enable Local Git Hooks

Enable the repository's local quality checks after cloning:

```bash
./scripts/install-hooks.sh
```

On Windows PowerShell, run the script through Git Bash:

```powershell
bash ./scripts/install-hooks.sh
```

The hooks run tests before commits and pushes, and they reject empty or overly vague commit messages. GitHub Actions still runs the shared CI checks for every pull request.
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

Run tests:

```bash
npm test
```

Create a feature branch, then commit the installer and documentation:

```bash
git switch -c docs/document-local-hook-installation
git add scripts/install-hooks.sh CONTRIBUTING.md
git commit -m "Document local hook installation"
git push -u origin docs/document-local-hook-installation
```

## The Verification

The installation script should print:

```text
Git hooks are enabled for this repository.
Configured hooks path: .githooks
```

Confirm the configuration:

```bash
git config --get core.hooksPath
```

Expected output:

```text
.githooks
```

Open a pull request, verify CI passes, then merge it through the normal protected-branch workflow.

---

# I.7 Test Hook Failure Behavior Safely

## The Target

Verify that a failing test prevents commits and pushes.

## The Concept

A safety gate is only useful if it actually blocks unsafe work.

You will create a temporary failing test expectation, attempt a commit, observe the hook stop it, then fix the test before committing.

The intended sequence is:

```text
Introduce temporary failure
    ↓
Attempt commit
    ↓
pre-commit blocks commit
    ↓
Fix failure
    ↓
Commit succeeds
```

## The Implementation

Create a temporary branch:

```bash
git switch main
git pull --ff-only
git switch -c practice/verify-hook-failure
```

In `src/releaseNotes.test.js`, change the first expected release heading:

```js
# Release 1.0.0
```

to:

```js
# Release 0.0.0
```

Stage the changed test:

```bash
git add src/releaseNotes.test.js
```

Attempt to commit:

```bash
git commit -m "Test local hook behavior"
```

The `pre-commit` hook should run and block the commit because the test fails.

Restore the correct expected heading:

```js
# Release 1.0.0
```

Stage the corrected test:

```bash
git add src/releaseNotes.test.js
```

Confirm there is no staged diff:

```bash
git diff --staged
```

Delete the practice branch after confirming no changes remain:

```bash
git switch main
git branch -D practice/verify-hook-failure
```

## The Verification

The attempted commit should fail with output including:

```text
Running pre-commit checks...
```

and a failing test assertion.

After restoring the expected test value, confirm:

```bash
git status
```

Expected output:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

---

# I.8 Bypassing Hooks: When It Is Possible and Why It Is Risky

## The Target

Understand how hooks can be bypassed and why CI must remain required.

## The Concept

Git allows hooks to be skipped in certain situations.

For example:

```bash
git commit --no-verify -m "Emergency commit"
```

This skips `pre-commit` and `commit-msg` hooks.

Likewise:

```bash
git push --no-verify
```

skips the `pre-push` hook.

There are rare legitimate reasons to bypass a local hook:

- The hook itself is broken.
- A known environment issue prevents a non-critical local check.
- An emergency fix requires immediate publication and CI will still validate the result.

However, bypassing hooks should be exceptional and documented.

Local hooks are convenience and feedback tools. GitHub Actions with protected branch rules is the enforceable shared control.

## The Implementation

Do not bypass hooks in this tutorial.

Instead, inspect Git’s command help:

```bash
git commit -h
git push -h
```

Look for:

```text
--no-verify
```

## The Verification

Confirm you understand:

```text
Local hook skipped
    does not mean
CI skipped
```

A protected `main` branch with required CI should still prevent a failing pull request from merging.

---

# I.9 Add a Basic Secret-Detection Hook

## The Target

Create a lightweight pre-commit check for common accidentally staged secret patterns.

## The Concept

This hook is a reminder system, not a complete security scanner.

It checks staged changes for common secret-related names and private-key headers, including:

```text
API_KEY
PASSWORD
SECRET
TOKEN
BEGIN PRIVATE KEY
```

A match does not always mean a real secret exists. For example, documentation may safely mention `API_KEY`.

Therefore, the hook will warn and stop the commit, asking the contributor to inspect the staged diff. If the match is safe and intentional, the contributor can revise the wording, add a narrowly documented exception, or—only when appropriate—use a deliberate bypass.

For serious projects, use dedicated secret-scanning tools in CI and repository hosting protections in addition to this simple hook.

## The Implementation

Replace the complete `pre-commit` hook with the following expanded version.

### `release-notes-manager/.githooks/pre-commit`

```sh
#!/usr/bin/env sh

set -eu

echo "Running pre-commit checks..."

if ! command -v npm >/dev/null 2>&1; then
  echo "ERROR: npm is required to run pre-commit checks."
  echo "Install Node.js and npm, then try the commit again."
  exit 1
fi

# Inspect only added lines in staged changes. This avoids reporting an old,
# already committed documentation phrase that is unrelated to the new commit.
STAGED_SECRET_MATCHES=$(
  git diff --cached --unified=0 |
    grep '^+' |
    grep -v '^+++' |
    grep -Ei '(BEGIN [A-Z ]*PRIVATE KEY|api[_-]?key[[:space:]]*[:=]|password[[:space:]]*[:=]|secret[[:space:]]*[:=]|token[[:space:]]*[:=])' ||
    true
)

if [ -n "$STAGED_SECRET_MATCHES" ]; then
  echo "ERROR: Staged changes contain text that may be a secret."
  echo "Review the matching added lines below:"
  echo
  printf '%s\n' "$STAGED_SECRET_MATCHES"
  echo
  echo "If this is documentation or an intentionally safe example, revise it"
  echo "to make that clear. Never commit real credentials or private keys."
  exit 1
fi

npm test

echo "Pre-commit checks passed."
```

On macOS, Linux, or Git Bash:

```bash
chmod +x .githooks/pre-commit
```

Test that normal project changes still pass:

```bash
.githooks/pre-commit
```

Create a temporary demonstration file with a safe but detectable pattern:

### `release-notes-manager/HOOK_SECRET_TEST.txt`

```text
API_KEY=example-value-for-hook-testing
```

Stage it:

```bash
git add HOOK_SECRET_TEST.txt
```

Run the hook manually:

```bash
.githooks/pre-commit
```

The hook should fail.

Unstage and remove the demonstration file:

```bash
git restore --staged HOOK_SECRET_TEST.txt
```

### macOS, Linux, or Git Bash

```bash
rm HOOK_SECRET_TEST.txt
```

### Windows PowerShell

```powershell
Remove-Item HOOK_SECRET_TEST.txt
```

Commit the hook update through a feature branch:

```bash
git switch -c ci/add-local-secret-check
git add .githooks/pre-commit
git commit -m "Check staged changes for likely secrets"
git push -u origin ci/add-local-secret-check
```

## The Verification

The demonstration hook failure should include:

```text
ERROR: Staged changes contain text that may be a secret.
```

After cleanup:

```bash
git status
```

should not list `HOOK_SECRET_TEST.txt`.

Open a pull request, ensure CI passes, and merge the hook update through the standard workflow.

---

# I.10 Hook Command Reference

## Enable Repository Hooks

```bash
git config core.hooksPath .githooks
```

## Inspect Active Hook Path

```bash
git config --get core.hooksPath
```

## Run a Hook Manually

### macOS, Linux, or Git Bash

```bash
.githooks/pre-commit
```

### Windows PowerShell

```powershell
bash .githooks/pre-commit
```

## Skip Commit Hooks Once

Use only for an understood exception:

```bash
git commit --no-verify -m "Emergency documentation correction"
```

## Skip Push Hooks Once

Use only for an understood exception:

```bash
git push --no-verify
```

## Restore the Default Hook Location

```bash
git config --unset core.hooksPath
```

After this command, Git returns to using:

```text
.git/hooks
```

---

# I.11 Local Hooks Versus GitHub Actions

| Capability | Local Git hooks | GitHub Actions |
|---|---|---|
| Runs before a local commit | Yes | No |
| Runs before a local push | Yes | No |
| Runs independently for every contributor | Only if each contributor installs hooks | Yes |
| Can be bypassed locally | Yes | Not by ordinary contributors if required checks are protected |
| Runs in a clean hosted environment | No | Yes |
| Best for fast feedback | Yes | Sometimes slower |
| Best for merge enforcement | No | Yes |

Use both:

```text
Hooks:
Fast feedback while writing code.

GitHub Actions:
Shared and enforceable verification before merge.
```

---

# Appendix I Completion Check

You should now be able to:

- [ ] Explain what Git hooks are and where they run.
- [ ] Configure Git to use a version-controlled `.githooks` directory.
- [ ] Create a `pre-commit` hook that runs tests.
- [ ] Create a `commit-msg` hook that rejects unhelpful messages.
- [ ] Create a `pre-push` hook that runs tests before publication.
- [ ] Install hooks with a contributor-friendly setup script.
- [ ] Test both passing and failing hook behavior.
- [ ] Understand why hooks can be bypassed and why CI remains essential.
- [ ] Add a basic local guard against accidentally staged secret-like content.
