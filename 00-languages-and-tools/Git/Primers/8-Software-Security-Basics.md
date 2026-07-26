# Primer 8: Software Security Basics for Git and GitHub

Git and GitHub make it easy to preserve and share project history. That is valuable—but it creates an important responsibility:

> Do not commit sensitive information.

A Git commit is designed to be copied:

```text
Your computer
    ↓ git push
GitHub
    ↓ clone, fork, cache, backup, review, release
Other locations
```

If a password, token, private key, or customer record enters a commit, deleting it from a later version does not automatically make it safe.

This primer explains the security basics you need before working with remotes, collaboration, automation, and releases.

You will learn:

- What counts as a secret.
- Why Git history makes secret exposure serious.
- How `.gitignore` helps.
- Why `.gitignore` is not enough after a file is tracked.
- How to use `.env.example` safely.
- What to do immediately when a secret is exposed.
- How to review changes before committing.

---

# P8.1 Understand What Counts as a Secret

## The Target

Recognize information that must not be committed to a repository.

## The Concept

A **secret** is information that grants access, identifies a person, exposes private data, or should not be broadly shared.

Common secrets include:

```text
Passwords
API keys
Personal Access Tokens
Cloud access keys
Database connection strings
Private SSH keys
Private certificates
Session cookies
Webhook signing secrets
Production credentials
```

Examples of dangerous content:

```dotenv
DATABASE_PASSWORD=correct-horse-battery-staple
```

```text
github_pat_1234567890...
```

```text
-----BEGIN OPENSSH PRIVATE KEY-----
```

```text
aws_access_key_id = AKIA...
```

A file does not need to be named `.env` to contain a secret. A secret can appear in:

```text
config.json
settings.js
deployment.yml
README.md
issue comments
pull request descriptions
terminal screenshots
GitHub Actions logs
```

## The Implementation

No secret should be created or committed for this exercise.

Instead, inspect the project’s ignore rules:

```bash
git show HEAD:.gitignore
```

Look for patterns similar to:

```gitignore
.env
.env.*
!.env.example
```

## The Verification

Confirm you can classify these examples:

| Value | Safe to commit? | Why |
|---|---:|---|
| `NODE_ENV=development` in `.env.example` | Usually yes | It is a non-sensitive example value. |
| `DATABASE_PASSWORD=...` in `.env` | No | It is a credential. |
| Public GitHub repository URL | Usually yes | It is intended to be public. |
| Private SSH key | Never | It can authenticate as you. |
| A fake placeholder such as `YOUR_API_KEY_HERE` | Yes | It is not a real credential. |

---

# P8.2 Understand Why Git History Makes Exposure Persistent

## The Target

Understand why deleting a secret in a later commit does not solve the original exposure.

## The Concept

Imagine this history:

```text
Commit A:
Add .env with a real token

Commit B:
Delete .env
```

The current project files may no longer contain `.env`, but Commit A still does.

```text
main
  │
  ▼
Commit A → Commit B
   │
   └── Secret remains visible in historical content
```

Anyone with access to repository history may be able to inspect Commit A.

That is why the first response to a leaked credential is:

```text
Revoke or rotate it.
```

Do not begin by assuming history cleanup alone makes the secret safe.

## The Implementation

Inspect historical versions of a safe tracked file:

```bash
git log --oneline -- README.md
```

Then inspect an older version:

```bash
git show HEAD~1:README.md
```

This demonstrates the key idea: Git can retrieve earlier file contents.

Do not use this exercise with a real secret.

## The Verification

Confirm you understand:

```text
Removing a file now
    is different from
removing its historical contents everywhere.
```

If a real secret is exposed, rotate it first.

---

# P8.3 Use `.gitignore` as a Prevention Layer

## The Target

Use `.gitignore` to prevent common local-only files from being staged accidentally.

## The Concept

`.gitignore` is a set of patterns telling Git:

> “Do not show matching untracked files as files to add.”

A practical `.gitignore` commonly excludes:

```text
.env
node_modules/
coverage/
dist/
*.log
.vscode/
.DS_Store
```

Think of `.gitignore` as a packing checklist:

```text
Source code            → pack
Documentation          → pack
Environment secrets    → do not pack
Installed dependencies → do not pack
Generated logs         → do not pack
```

## The Implementation

Inspect the current `.gitignore` file:

```bash
git show HEAD:.gitignore
```

Test the `.env` rule with a fake local value.

### macOS, Linux, or Git Bash

```bash
printf 'DEMO_TOKEN=not-a-real-secret\n' > .env
```

### Windows PowerShell

```powershell
'DEMO_TOKEN=not-a-real-secret' | Set-Content -Path .env
```

Check status:

```bash
git status --short
```

Ask Git why the file is ignored:

```bash
git check-ignore -v .env
```

Delete the temporary file.

### macOS, Linux, or Git Bash

```bash
rm .env
```

### Windows PowerShell

```powershell
Remove-Item .env
```

## The Verification

`git status --short` should not list `.env`.

`git check-ignore -v .env` should show the matching rule, similar to:

```text
.gitignore:2:.env    .env
```

---

# P8.4 Understand Why `.gitignore` Cannot Remove Tracked Files

## The Target

Recognize when an ignore rule does not protect a file.

## The Concept

`.gitignore` only affects untracked files.

Suppose `.env` was already committed:

```text
Git is tracking .env
```

Later, you add this rule:

```gitignore
.env
```

Git continues tracking the file because it is already part of repository history.

Think of `.gitignore` as a sign that says:

```text
Do not bring new boxes into this room.
```

It does not remove a box that is already inside.

## The Implementation

Check whether Git tracks a file:

```bash
git ls-files .env
```

If no output appears, Git does not currently track `.env`.

For reference only, if a local configuration file was accidentally tracked, you would stop tracking it while leaving the local file in place:

```bash
git rm --cached .env
```

Then add or confirm the ignore rule:

```bash
git add .gitignore
git commit -m "Stop tracking local environment configuration"
```

Do not run `git rm --cached .env` unless `.env` is actually tracked and you understand the impact.

## The Verification

Confirm this distinction:

| Command | Result |
|---|---|
| `git check-ignore -v .env` | Checks whether an untracked `.env` would be ignored. |
| `git ls-files .env` | Checks whether Git currently tracks `.env`. |
| `git rm --cached .env` | Stops tracking `.env` but leaves its local file on disk. |

---

# P8.5 Use `.env.example` Safely

## The Target

Document required environment variables without publishing real values.

## The Concept

Projects often need local configuration.

A safe pattern is:

```text
.env.example
    ↓ committed
    ↓ contains variable names and harmless sample values

.env
    ↓ ignored
    ↓ contains real local values
```

The example file tells contributors what they need to configure without exposing credentials.

## The Implementation

Create this safe example file if your repository does not already have one.

### `release-notes-manager/.env.example`

```dotenv
# Copy this file to .env for local development.
# Do not commit the real .env file.

RELEASE_NOTES_LOG_LEVEL=info
RELEASE_NOTES_API_URL=https://api.example.test
```

Do not include real tokens, passwords, internal URLs with credentials, or production secrets.

If you add this file to the project, use a feature branch:

```bash
git switch main
git pull --ff-only
git switch -c docs/add-environment-example
```

Review the file:

```bash
git diff -- .env.example
```

Stage and commit:

```bash
git add .env.example
git commit -m "docs(config): add environment configuration example"
git push -u origin docs/add-environment-example
```

## The Verification

Confirm the example file is tracked:

```bash
git ls-files .env.example
```

Confirm a real local `.env` file would be ignored:

```bash
git check-ignore -v .env
```

---

# P8.6 Review Staged Changes for Secrets

## The Target

Make staged-diff review a security habit before every commit.

## The Concept

The staging area is the exact package Git will commit.

Before committing, inspect it:

```bash
git diff --staged
```

This is one of the most effective low-cost security habits in Git.

It helps catch:

- A copied token.
- A local config file.
- A debug log.
- A private URL.
- An unrelated generated file.
- A change you did not mean to commit.

## The Implementation

Run:

```bash
git status
git diff
git diff --staged
```

Search staged additions for common secret-like patterns.

### macOS, Linux, or Git Bash

```bash
git diff --staged |
  grep -Ei '(api[_-]?key|secret|password|token|private[_-]?key)' || true
```

### Windows PowerShell

```powershell
git diff --staged |
  Select-String -Pattern '(api[_-]?key|secret|password|token|private[_-]?key)'
```

A match is not always an actual secret. Documentation may legitimately contain terms such as `API_KEY`.

Use the result as a prompt to inspect the diff carefully.

## The Verification

Before committing, confirm:

```text
[ ] I know every file in git status.
[ ] I reviewed every staged line in git diff --staged.
[ ] No real credentials, private keys, or sensitive data are present.
[ ] No local `.env`, dependency folder, log, or generated output was staged accidentally.
```

---

# P8.7 Recognize Private-Key Material

## The Target

Recognize private keys and understand why they must never enter a repository.

## The Concept

Private keys often begin with a recognizable header:

```text
-----BEGIN PRIVATE KEY-----
```

or:

```text
-----BEGIN OPENSSH PRIVATE KEY-----
```

A private key can grant access to systems, cloud accounts, deployment targets, or source repositories.

Public keys are different. They often begin with:

```text
ssh-ed25519
```

and are intended to be registered with services such as GitHub.

| Key type | Safe to share? |
|---|---:|
| SSH public key ending in `.pub` | Yes |
| SSH private key without `.pub` | Never |
| Public certificate | Usually, depending on policy |
| Private certificate key | Never |

## The Implementation

Inspect only the filenames in your SSH directory.

### macOS, Linux, or Git Bash

```bash
ls -la ~/.ssh
```

### Windows PowerShell

```powershell
Get-ChildItem -Force "$HOME\.ssh"
```

Do not print your private key with `cat`.

It is acceptable to print a public key when you need to add it to GitHub:

```bash
cat ~/.ssh/id_ed25519.pub
```

## The Verification

Confirm you can identify the difference:

```text
id_ed25519
    → private key
    → never commit or share

id_ed25519.pub
    → public key
    → safe to register with GitHub
```

---

# P8.8 Respond to a Secret Exposure

## The Target

Know the correct first actions when a real secret is committed or pushed.

## The Concept

When a secret is exposed, the critical order is:

```text
1. Revoke or rotate the credential.
2. Contain affected systems.
3. Remove the secret from current files.
4. Record the incident privately.
5. Decide whether history cleanup is required.
6. Add prevention controls.
```

The first action is not:

```bash
git reset
```

The first action is:

```text
Make the credential unusable.
```

A deleted token is safer than a token that remains active in hidden Git history.

## The Implementation

Do not simulate a real secret exposure.

Memorize this response pattern:

```text
If an API key is committed:
    1. Disable or rotate the API key in the provider dashboard.
    2. Remove it from the current source file.
    3. Add the relevant file to .gitignore if appropriate.
    4. Commit and push the removal.
    5. Create a private security advisory or incident record.
    6. Follow organizational guidance for history cleanup.
```

For a file that was accidentally tracked:

```bash
git rm --cached .env
git add .gitignore
git commit -m "Remove local environment configuration"
git push
```

Again: rotate the real credential first.

## The Verification

You should be able to state this rule without hesitation:

```text
A secret that reaches Git history is treated as compromised.
Rotate or revoke it before attempting cleanup.
```

---

# P8.9 Understand Repository Visibility and Security

## The Target

Understand why private repositories still need careful secret handling.

## The Concept

A private repository is visible only to authorized people, but it is not a secret-management system.

Secrets in private repositories can still be exposed through:

- Collaborator access.
- Accidental public forks or copies.
- CI logs.
- Screenshots.
- Backups.
- Support bundles.
- Misconfigured deployments.
- Compromised accounts.
- Future access changes.

Use dedicated secret storage for real production credentials:

```text
GitHub Actions secrets
Cloud secret manager
Password manager
Environment-specific secret store
Deployment platform configuration
```

## The Implementation

Inspect your repository visibility:

```bash
gh repo view --json visibility
```

If GitHub CLI is unavailable, inspect the repository label in the browser.

Review repository security settings:

```text
Repository → Settings → Code security and analysis
```

Enable appropriate features when available:

```text
Dependency graph
Dependabot alerts
Secret scanning
Push protection
```

## The Verification

Confirm you understand:

```text
Public repository:
Assume everyone can see all committed history.

Private repository:
Still do not commit secrets.
```

---

# P8.10 Security-First Git Routine

## The Target

Add security checks to your ordinary development workflow.

## The Concept

Security is most effective when it is routine rather than exceptional.

Use this sequence before every commit:

```text
Edit files
    ↓
git status
    ↓
git diff
    ↓
git add intended files
    ↓
git diff --staged
    ↓
Run tests
    ↓
Commit
```

Before every push:

```text
git status
    ↓
Confirm branch and remote destination
    ↓
git push
```

## The Implementation

Use this safe workflow:

```bash
git status
git diff
git add <intended-file-paths>
git diff --staged
npm test
git commit -m "type(scope): describe the change"
git status
git push
```

## The Verification

Before committing, you should be able to answer:

```text
[ ] What files am I committing?
[ ] What exact lines am I committing?
[ ] Do any lines contain credentials, private data, or local-only configuration?
[ ] Did I run relevant tests?
[ ] Is this the correct branch?
```

---

# Primer 8 Reference: Secret-Safety Commands

## Check Whether a File Is Ignored

```bash
git check-ignore -v .env
```

## Check Whether a File Is Tracked

```bash
git ls-files .env
```

## Review Unstaged Changes

```bash
git diff
```

## Review Staged Changes

```bash
git diff --staged
```

## Stop Tracking a File but Keep It Locally

```bash
git rm --cached .env
```

## List SSH Key Filenames

```bash
ls -la ~/.ssh
```

## Check Repository Visibility with GitHub CLI

```bash
gh repo view --json visibility
```

---

# Primer 8 Completion Check

Before working with remote repositories and automation, confirm that you can:

- [ ] Recognize passwords, tokens, API keys, and private keys as secrets.
- [ ] Explain why deleting a secret in a later commit does not erase historical exposure.
- [ ] Use `.gitignore` to prevent untracked local configuration files from being added.
- [ ] Explain why `.gitignore` does not stop tracking a file already committed.
- [ ] Use `.env.example` to document safe configuration keys.
- [ ] Review staged changes with `git diff --staged`.
- [ ] Recognize private-key headers and filenames.
- [ ] State that exposed secrets must be revoked or rotated immediately.
- [ ] Explain why private repositories are not secret-management systems.
- [ ] Follow a security-first commit routine.
