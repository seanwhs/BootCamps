# Primer 13: Environment Variables, Configuration Files, and Local Development Setup

Software often needs values that differ between computers or environments.

Examples:

```text
Development API URL
Logging level
Database connection string
Feature flags
Deployment region
Authentication token
```

These values are called **configuration**.

Some configuration is safe to commit:

```text
RELEASE_NOTES_LOG_LEVEL=info
```

Other configuration is sensitive:

```text
DATABASE_PASSWORD=super-secret-value
```

This primer explains how projects separate reusable configuration examples from private local values.

You will learn:

- What environment variables are.
- Why configuration differs from source code.
- The difference between `.env` and `.env.example`.
- How Node.js reads environment variables.
- How to avoid committing secrets.
- How configuration works in local development and GitHub Actions.

---

# P13.1 Understand Environment Variables

## The Target

Understand what an environment variable is and why applications use it.

## The Concept

An **environment variable** is a named value supplied to a program from outside its source code.

For example:

```text
RELEASE_NOTES_LOG_LEVEL=debug
```

The variable name is:

```text
RELEASE_NOTES_LOG_LEVEL
```

Its value is:

```text
debug
```

Think of source code as a coffee machine’s permanent instructions. Environment variables are the settings chosen for one particular cup:

```text
Source code:
How to make coffee.

Environment variables:
Small, large, decaf, extra hot.
```

The same code can behave differently in different environments without editing source files.

For example:

```text
Local development:
API_URL=http://localhost:3000

Production:
API_URL=https://api.example.com
```

---

# P13.2 Read Environment Variables in Node.js

## The Target

Access environment variables through Node.js.

## The Concept

Node.js exposes environment variables through:

```js
process.env
```

For example:

```js
process.env.RELEASE_NOTES_LOG_LEVEL
```

This reads the value of:

```text
RELEASE_NOTES_LOG_LEVEL
```

If the variable does not exist, Node.js returns:

```js
undefined
```

A safe application usually provides a non-sensitive default for optional configuration.

## The Implementation

Create a disposable practice folder.

### macOS, Linux, or Git Bash

```bash
mkdir -p ~/projects/environment-practice
cd ~/projects/environment-practice
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path "$HOME\projects\environment-practice" -Force
Set-Location "$HOME\projects\environment-practice"
```

Create this file.

### `environment-practice/readEnvironment.js`

```js
const logLevel = process.env.RELEASE_NOTES_LOG_LEVEL ?? "info";

console.log(`Configured log level: ${logLevel}`);
```

Run it without setting a variable:

```bash
node readEnvironment.js
```

Run it with a temporary variable.

### macOS, Linux, or Git Bash

```bash
RELEASE_NOTES_LOG_LEVEL=debug node readEnvironment.js
```

### Windows PowerShell

```powershell
$env:RELEASE_NOTES_LOG_LEVEL = "debug"
node readEnvironment.js
Remove-Item Env:RELEASE_NOTES_LOG_LEVEL
```

## The Verification

Without the variable, expected output:

```text
Configured log level: info
```

With the temporary variable, expected output:

```text
Configured log level: debug
```

---

# P13.3 Understand `.env` Files

## The Target

Understand the role of a local `.env` file.

## The Concept

A `.env` file is a plain-text file that commonly stores local environment-variable values.

Example:

```dotenv
RELEASE_NOTES_LOG_LEVEL=debug
RELEASE_NOTES_API_URL=http://localhost:3000
```

Many frameworks and packages can load `.env` files automatically or through configuration code.

However, Node.js does not automatically load `.env` files merely because they exist. A project must deliberately load them, often with:

- Node.js environment-file support.
- A framework feature.
- A package such as `dotenv`.

For this series, you do not need external packages. Modern Node.js can load an environment file with:

```bash
node --env-file=.env readEnvironment.js
```

## The Implementation

Create this local file.

### `environment-practice/.env`

```dotenv
RELEASE_NOTES_LOG_LEVEL=debug
```

Run the script using the environment file:

```bash
node --env-file=.env readEnvironment.js
```

## The Verification

Expected output:

```text
Configured log level: debug
```

Confirm the file exists:

### macOS, Linux, or Git Bash

```bash
ls -la
```

### Windows PowerShell

```powershell
Get-ChildItem -Force
```

You should see:

```text
.env
readEnvironment.js
```

---

# P13.4 Understand Why `.env` Must Usually Be Ignored

## The Target

Prevent local environment files from entering Git history.

## The Concept

A local `.env` file often contains secrets or machine-specific values.

For example:

```dotenv
DATABASE_PASSWORD=real-password
DEPLOYMENT_TOKEN=real-token
```

Even if your current `.env` contains only harmless values, a future version might contain real credentials.

The standard safe policy is:

```gitignore
.env
.env.*
!.env.example
```

This means:

```text
Ignore:
.env
.env.local
.env.production

Do not ignore:
.env.example
```

The `!` means “make an exception to the ignore rule.”

## The Implementation

Create this `.gitignore` file in the practice folder.

### `environment-practice/.gitignore`

```gitignore
# Local environment files may contain secrets or machine-specific settings.
.env
.env.*
!.env.example
```

Check whether `.env` is ignored:

```bash
git init
git check-ignore -v .env
```

## The Verification

Expected output resembles:

```text
.gitignore:2:.env    .env
```

Run:

```bash
git status --short
```

`.env` should not appear as an untracked file.

---

# P13.5 Create a Safe `.env.example` File

## The Target

Document required configuration keys without exposing local values or credentials.

## The Concept

A `.env.example` file is a safe configuration template.

It tells contributors:

```text
These variables may be required.
These are acceptable non-secret sample values.
Copy this file to .env and customize it locally.
```

It must never contain a real secret.

## The Implementation

Create this file.

### `environment-practice/.env.example`

```dotenv
# Copy this file to .env and customize values for your local environment.
# Do not commit the real .env file.

RELEASE_NOTES_LOG_LEVEL=info
RELEASE_NOTES_API_URL=https://api.example.test
```

Check Git status:

```bash
git status --short
```

Stage the safe files:

```bash
git add .gitignore .env.example readEnvironment.js
```

Inspect what would be committed:

```bash
git diff --staged
```

## The Verification

Expected staged files:

```text
.env.example
.gitignore
readEnvironment.js
```

The real local `.env` file should not appear.

Confirm:

```bash
git ls-files .env
```

Expected output: no output.

---

# P13.6 Validate Required Configuration Safely

## The Target

Fail clearly when a required environment variable is missing.

## The Concept

Some settings are optional and can use defaults:

```js
const logLevel = process.env.RELEASE_NOTES_LOG_LEVEL ?? "info";
```

Other settings are required.

For example, a production integration might require:

```text
RELEASE_NOTES_API_URL
```

A clear error is better than silently using an incorrect or unsafe fallback.

Think of it like checking that a delivery address exists before sending a package.

## The Implementation

Replace `readEnvironment.js` with this complete version.

### `environment-practice/readEnvironment.js`

```js
/**
 * Reads a required environment variable and throws a clear error when it is
 * absent or contains only whitespace.
 *
 * @param {string} name - The environment-variable name.
 * @returns {string} The trimmed configuration value.
 * @throws {Error} When the variable is missing or empty.
 */
function getRequiredEnvironmentVariable(name) {
  const value = process.env[name];

  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return value.trim();
}

const logLevel = process.env.RELEASE_NOTES_LOG_LEVEL?.trim() || "info";
const apiUrl = getRequiredEnvironmentVariable("RELEASE_NOTES_API_URL");

console.log(`Configured log level: ${logLevel}`);
console.log(`Configured API URL: ${apiUrl}`);
```

Update the local `.env` file.

### `environment-practice/.env`

```dotenv
RELEASE_NOTES_LOG_LEVEL=debug
RELEASE_NOTES_API_URL=http://localhost:3000
```

Run:

```bash
node --env-file=.env readEnvironment.js
```

Then intentionally test missing configuration by running without `.env`:

```bash
node readEnvironment.js
```

## The Verification

With `.env`, expected output:

```text
Configured log level: debug
Configured API URL: http://localhost:3000
```

Without `.env`, expected output includes:

```text
Error: Missing required environment variable: RELEASE_NOTES_API_URL
```

This clear failure is safer than silently connecting to an unintended service.

---

# P13.7 Keep Secrets Out of Logs

## The Target

Avoid exposing credentials through terminal output, application logs, tests, or CI.

## The Concept

A secret can leak even if it is never committed.

Dangerous examples:

```js
console.log(process.env.DEPLOYMENT_TOKEN);
```

```yaml
- run: echo "${{ secrets.DEPLOYMENT_TOKEN }}"
```

```text
Error connecting with password: actual-password
```

Logs may be copied into:

- CI output.
- Pull request comments.
- Issue reports.
- Support tickets.
- Screenshots.
- Monitoring systems.

Instead of logging a secret, log only safe context.

## The Implementation

Avoid this:

```js
console.log(`Using token: ${process.env.DEPLOYMENT_TOKEN}`);
```

Use this pattern:

```js
const token = process.env.DEPLOYMENT_TOKEN;

if (typeof token !== "string" || token.length === 0) {
  throw new Error("DEPLOYMENT_TOKEN is required.");
}

console.log("Deployment token is configured.");
```

The log confirms configuration exists without revealing its value.

## The Verification

Review terminal output and application logs before sharing them.

Confirm this rule:

```text
Safe:
"Deployment token is configured."

Unsafe:
"Deployment token is abc123..."
```

---

# P13.8 Understand Local Configuration Versus GitHub Actions Secrets

## The Target

Distinguish local `.env` configuration from GitHub-hosted workflow secrets.

## The Concept

Local development often uses:

```text
.env
```

GitHub Actions uses repository or environment secrets:

```yaml
${{ secrets.DEPLOYMENT_API_TOKEN }}
```

They solve similar configuration problems in different places.

```text
Your computer
    → .env, ignored by Git

GitHub Actions
    → GitHub repository or environment secrets
```

A GitHub Actions secret should be passed only to the step that needs it:

```yaml
- name: Deploy
  env:
    DEPLOYMENT_API_TOKEN: ${{ secrets.DEPLOYMENT_API_TOKEN }}
  run: ./scripts/deploy.sh
```

Avoid making secrets globally available to every workflow step unless necessary.

## The Implementation

Read this safe workflow pattern:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: production

    steps:
      - name: Deploy application
        env:
          DEPLOYMENT_API_TOKEN: ${{ secrets.DEPLOYMENT_API_TOKEN }}
        run: ./scripts/deploy.sh
```

This example assumes:

- A protected GitHub Environment named `production`.
- An environment secret named `DEPLOYMENT_API_TOKEN`.
- A deployment script that does not print the secret.

Do not add a fake secret for this exercise.

## The Verification

Confirm you understand:

| Location | Appropriate configuration |
|---|---|
| Local development | Ignored `.env` file |
| Shared variable names and examples | Tracked `.env.example` |
| GitHub CI without secrets | No secret configuration needed |
| Protected deployment workflow | Environment secrets |

---

# P13.9 Clean Up the Practice Folder

## The Target

Remove the disposable environment-variable practice project safely.

## The Concept

The practice folder includes a local `.env` file, which is exactly the type of file that should not accidentally move into another repository.

Deleting the disposable folder demonstrates that the configuration exercise is complete.

## The Implementation

First unstage any practice files if you staged them:

```bash
git restore --staged .
```

Move to the parent folder:

```bash
cd ..
```

Delete the practice folder.

### macOS, Linux, or Git Bash

```bash
rm -rf environment-practice
```

### Windows PowerShell

```powershell
Remove-Item -Recurse -Force environment-practice
```

## The Verification

List project folders.

### macOS, Linux, or Git Bash

```bash
ls
```

### Windows PowerShell

```powershell
Get-ChildItem
```

Confirm:

```text
environment-practice
```

no longer appears.

---

# Primer 13 Reference: Environment Configuration Commands

## Run Node.js with an Environment File

```bash
node --env-file=.env readEnvironment.js
```

## Set a Temporary Variable on macOS, Linux, or Git Bash

```bash
VARIABLE_NAME=value node script.js
```

## Set a Temporary Variable in PowerShell

```powershell
$env:VARIABLE_NAME = "value"
node script.js
Remove-Item Env:VARIABLE_NAME
```

## Check Why a File Is Ignored

```bash
git check-ignore -v .env
```

## Check Whether a File Is Already Tracked

```bash
git ls-files .env
```

## Review Staged Content Before Committing

```bash
git diff --staged
```

---

# Primer 13 Completion Check

Before adding configuration or deployment features to a project, confirm that you can:

- [ ] Explain what an environment variable is.
- [ ] Read environment values in Node.js with `process.env`.
- [ ] Explain why `.env` files are usually ignored.
- [ ] Create a safe `.env.example` file.
- [ ] Validate required configuration clearly.
- [ ] Avoid printing secrets in logs.
- [ ] Distinguish local `.env` files from GitHub Actions secrets.
- [ ] Pass GitHub secrets only to the workflow step that needs them.
- [ ] Review staged changes to ensure local configuration is not being committed.
- [ ] State that real secrets belong in a secret manager or protected environment configuration, not source control.
