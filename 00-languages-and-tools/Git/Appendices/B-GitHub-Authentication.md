# Appendix B: GitHub Authentication, Secret Safety, and Repository Hygiene

This appendix is a security-focused reference for working with GitHub safely.

Git repositories are excellent at preserving history. That is precisely why accidentally committed secrets are dangerous: once a credential enters a commit and is pushed, it may remain in history even after you delete the file in a later commit.

This appendix covers:

- SSH authentication.
- HTTPS authentication with Personal Access Tokens.
- Secure `.gitignore` rules.
- Detecting tracked secrets.
- What to do after a secret is exposed.
- Repository hygiene practices for professional projects.

---

## B.1 Authentication Method Decision Guide

### The Target

Choose a secure, maintainable method for authenticating Git operations with GitHub.

### The Concept

GitHub must confirm your identity before allowing you to push changes.

The two recommended methods are:

| Method | Best use case | Main credential |
|---|---|---|
| SSH | Regular development on a trusted personal machine | SSH private key |
| HTTPS with PAT | Restricted networks, temporary environments, some enterprise policies | Personal Access Token |

Use **SSH** when:

- You regularly work from the same development machine.
- Your network allows SSH connections to GitHub.
- You want a low-friction workflow after setup.

Use **HTTPS with a PAT** when:

- Your organization blocks SSH.
- You are working in an environment where HTTPS is required.
- You need a short-lived token with tightly scoped permissions.

Never use your GitHub account password in place of a Personal Access Token.

---

## B.2 SSH Authentication Reference

### The Target

Create, protect, and test an SSH key for GitHub authentication.

### The Concept

SSH authentication uses a key pair:

```text
Private key  → stays only on your computer
Public key   → added to GitHub
```

The private key is like the physical key in your pocket. Anyone with it may be able to act as you, so it must never be committed, shared, or copied into a chat message.

The public key is safe to share. It allows GitHub to recognize the matching private key without receiving it.

### The Implementation

Check for existing keys.

#### macOS, Linux, or Git Bash

```bash
ls -al ~/.ssh
```

#### Windows PowerShell

```powershell
Get-ChildItem -Force "$HOME\.ssh"
```

Generate a modern Ed25519 key if necessary:

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

Accept the default location unless you intentionally manage multiple keys:

```text
~/.ssh/id_ed25519
```

Use a strong passphrase when prompted.

Start the SSH agent and add the key.

#### macOS, Linux, or Git Bash

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

#### Windows PowerShell

```powershell
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
ssh-add "$HOME\.ssh\id_ed25519"
```

Print the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Add the complete public-key value at:

```text
https://github.com/settings/keys
```

Then test the connection:

```bash
ssh -T git@github.com
```

### The Verification

Expected output resembles:

```text
Hi YOUR_GITHUB_USERNAME! You've successfully authenticated, but GitHub does not provide shell access.
```

Verify your remote uses SSH:

```bash
git remote -v
```

Expected format:

```text
origin  git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git (fetch)
origin  git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git (push)
```

---

## B.3 HTTPS and Personal Access Token Reference

### The Target

Use a Personal Access Token safely when accessing GitHub over HTTPS.

### The Concept

A Personal Access Token, or **PAT**, is a generated credential that acts like a password for command-line Git operations over HTTPS.

Unlike a normal password, a PAT can:

- Expire automatically.
- Be restricted to selected repositories.
- Have narrowly scoped permissions.
- Be revoked independently of your GitHub account.

Treat a PAT exactly like a password.

### The Implementation

Create a fine-grained token through:

```text
https://github.com/settings/personal-access-tokens
```

Use these safe baseline settings:

```text
Repository access: Only select repositories
Repository permissions:
  Contents: Read and write
Expiration: A short period appropriate for your workflow
```

Configure a secure credential helper.

#### macOS

```bash
git config --global credential.helper osxkeychain
```

#### Windows

```bash
git config --global credential.helper manager
```

#### Linux with Git Credential Manager installed

```bash
git config --global credential.helper manager
```

Verify the configured helper:

```bash
git config --global credential.helper
```

When Git requests credentials:

```text
Username: YOUR_GITHUB_USERNAME
Password: YOUR_PERSONAL_ACCESS_TOKEN
```

Paste the token when Git asks for a password.

### The Verification

Confirm your remote uses HTTPS:

```bash
git remote -v
```

Expected format:

```text
origin  https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager.git (fetch)
origin  https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager.git (push)
```

Confirm that a normal push works:

```bash
git push
```

Do not paste a PAT into a terminal command, source file, `.env.example`, issue, pull request, or commit message.

---

## B.4 Secure `.gitignore` Baseline

### The Target

Maintain ignore rules for secrets, dependencies, generated output, logs, and editor files.

### The Concept

`.gitignore` is a “do not add by accident” list.

It prevents Git from showing matching **untracked** files as candidates for staging. It does not remove files already committed.

### The Implementation

Use this baseline `.gitignore` for the Release Notes Manager project.

### `release-notes-manager/.gitignore`

```gitignore
# Environment files can contain credentials and machine-specific configuration.
.env
.env.*
!.env.example

# Node.js dependencies are recreated from package metadata.
node_modules/

# Build output, generated reports, and test coverage.
dist/
build/
coverage/
.nyc_output/

# Log files may contain request details, file paths, or error output.
*.log
logs/

# Operating-system metadata.
.DS_Store
Thumbs.db
Desktop.ini

# Editor and IDE workspace files.
.vscode/
.idea/
*.suo
*.user
*.userossc
*.sln.docstates

# Temporary and backup files.
*.tmp
*.temp
*.swp
*.swo
*~
```

Test whether a path is ignored:

```bash
git check-ignore -v .env
```

Test a dependency path:

```bash
git check-ignore -v node_modules/example-package/index.js
```

### The Verification

Expected output identifies the matching ignore rule:

```text
.gitignore:2:.env    .env
```

Check that Git does not list ignored paths:

```bash
git status --short
```

Ignored files should not appear.

---

## B.5 Understand `.gitignore` Limitations

### The Target

Recognize when `.gitignore` does not protect a file.

### The Concept

`.gitignore` applies only to files Git does not already track.

If `.env` was committed before you added this rule:

```gitignore
.env
```

Git continues tracking `.env`.

Think of `.gitignore` as a sign on a door saying “do not bring new boxes inside.” It does not automatically remove a box that is already in the building.

### The Implementation

Check whether Git currently tracks a file:

```bash
git ls-files .env
```

If the file appears, stop tracking it while preserving your local copy:

```bash
git rm --cached .env
```

Then commit the removal and ignore rule:

```bash
git add .gitignore
git commit -m "Stop tracking environment configuration"
git push
```

### The Verification

Confirm `.env` is no longer tracked:

```bash
git ls-files .env
```

Expected output: no output.

Confirm Git ignores it:

```bash
git check-ignore -v .env
```

---

## B.6 Safe Environment Configuration Pattern

### The Target

Provide developers with documented configuration keys without exposing real values.

### The Concept

Applications often need configuration, such as an API endpoint or optional logging level.

A safe pattern is:

```text
.env.example  → committed; contains key names and safe example values
.env          → ignored; contains local real values
```

### The Implementation

Create the committed example file.

### `release-notes-manager/.env.example`

```dotenv
# Copy this file to .env for local development.
# Do not commit the real .env file.

RELEASE_NOTES_LOG_LEVEL=info
RELEASE_NOTES_API_URL=https://api.example.test
```

Do **not** add real tokens, passwords, or production URLs containing credentials.

Stage and commit it:

```bash
git add .env.example
git commit -m "Add environment configuration example"
```

Create a local `.env` file only if the project needs one:

### `release-notes-manager/.env`

```dotenv
RELEASE_NOTES_LOG_LEVEL=debug
RELEASE_NOTES_API_URL=http://localhost:3000
```

### The Verification

Confirm the example file is tracked:

```bash
git ls-files .env.example
```

Confirm the actual local file is ignored:

```bash
git check-ignore -v .env
```

---

## B.7 Pre-Commit Secret Inspection

### The Target

Check staged files for likely secrets before committing.

### The Concept

Before sending a package, inspect what is inside. The equivalent Git habit is reviewing the staging area:

```bash
git diff --staged
```

Do this before every commit, especially when adding configuration, deployment, CI, or integration files.

### The Implementation

Review all staged changes:

```bash
git diff --staged
```

Search tracked files for common secret-like names:

```bash
git grep -nEi '(api[_-]?key|secret|password|token|private[_-]?key)'
```

Search staged changes only:

### macOS, Linux, or Git Bash

```bash
git diff --staged | grep -Ei '(api[_-]?key|secret|password|token|private[_-]?key)'
```

### Windows PowerShell

```powershell
git diff --staged | Select-String -Pattern '(api[_-]?key|secret|password|token|private[_-]?key)'
```

These searches are not perfect. A variable named `token` is not automatically a secret, and a secret may not use an obvious name. They are a reminder to review carefully, not a complete security solution.

### The Verification

Before committing, ensure:

```bash
git diff --staged
```

contains no real credentials, private key blocks, or sensitive URLs.

Never assume an ignored file is safe to commit just because its name looks harmless.

---

## B.8 What To Do If You Commit a Secret Locally but Have Not Pushed

### The Target

Remove a secret from local unpushed history and rotate it if necessary.

### The Concept

If a secret entered a commit but has **not** been pushed, the situation is easier—but you should still treat the credential cautiously.

If you amend or reset the commit, the secret may remain temporarily recoverable through local reflog entries. If anyone else accessed the machine or repository clone, rotating the secret is still prudent.

### The Implementation

First, revoke or rotate the credential if it is real.

If the secret is in the latest commit, remove it from the file, then amend:

```bash
git add <corrected-file>
git commit --amend --no-edit
```

If the secret was an accidentally committed file:

```bash
git rm --cached <secret-file>
printf "<secret-file>\n" >> .gitignore
git add .gitignore
git commit --amend --no-edit
```

If the secret exists in an older local-only commit, use interactive rebase:

```bash
git rebase -i <commit-before-the-secret>
```

Mark the problematic commit as:

```text
edit
```

When Git pauses:

```bash
git rm --cached <secret-file>
git add .gitignore
git commit --amend --no-edit
git rebase --continue
```

### The Verification

Check the current branch content:

```bash
git grep -nEi '(api[_-]?key|secret|password|token|private[_-]?key)'
```

Inspect the rewritten history:

```bash
git log --oneline --decorate -10
```

Do not push until you have reviewed the commit diff:

```bash
git show --stat HEAD
```

---

## B.9 What To Do If You Push a Secret

### The Target

Respond correctly when a secret has reached GitHub.

### The Concept

Once a secret is pushed, assume it is compromised.

Deleting the file in a later commit does **not** make the secret safe because it may remain:

- In Git history.
- In GitHub caches.
- In cloned repositories.
- In forks.
- In pull request diffs.
- In logs or notifications.
- In someone else’s local copy.

The first priority is not cleaning Git history. The first priority is stopping the credential from working.

### The Implementation

Follow this incident sequence:

1. **Revoke or rotate the credential immediately.**

   Examples:
   - Delete and regenerate an API key.
   - Revoke a Personal Access Token.
   - Change a leaked password.
   - Replace a cloud access key.
   - Reissue a private certificate.

2. **Remove the secret from the current version of the project.**

   ```bash
   git rm --cached <secret-file>
   ```

   Or edit the file to remove the secret:

   ```bash
   git add <corrected-file>
   git commit -m "Remove exposed credential"
   git push
   ```

3. **Add an ignore rule if appropriate.**

   ```bash
   printf "<secret-file>\n" >> .gitignore
   git add .gitignore
   git commit -m "Ignore local secret configuration"
   git push
   ```

4. **Notify the project owner or security team.**

5. **Follow GitHub’s current sensitive-data removal guidance** if history cleanup is required:

   ```text
   https://docs.github.com/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository
   ```

6. **Coordinate before rewriting shared history.**

   History rewriting affects every clone and contributor.

### The Verification

Verify the revoked credential no longer works using the provider’s security dashboard.

Verify the current project tree no longer includes the file:

```bash
git ls-files <secret-file>
```

Remember: an empty result proves the file is not currently tracked. It does **not** prove that old history no longer contains it.

---

## B.10 Repository Hygiene Checklist

### The Target

Maintain a repository that is easy to clone, review, and safely contribute to.

### The Concept

Repository hygiene is the set of small habits that keep a project understandable over time.

A clean repository is like a well-organized workshop: tools are labeled, dangerous materials are secured, and unnecessary clutter is removed.

### The Implementation

Use this checklist before major releases or when onboarding contributors:

```text
Repository files
[ ] README.md explains the project purpose and basic usage.
[ ] .gitignore excludes secrets, dependencies, generated output, and logs.
[ ] .env.example exists when local configuration is required.
[ ] package.json defines reliable scripts.
[ ] LICENSE exists if the repository is intended for reuse.
[ ] CONTRIBUTING.md exists when external contributions are welcome.
[ ] SECURITY.md explains how to report vulnerabilities.

Git history
[ ] Commit messages explain meaningful changes.
[ ] Feature branches are deleted after merging.
[ ] main is protected.
[ ] Pull requests are reviewed before merging.
[ ] CI checks run on pull requests.

Secrets and access
[ ] Real secrets are not committed.
[ ] Personal Access Tokens have minimal scope and expiration dates.
[ ] Unused SSH keys are removed from GitHub.
[ ] Former collaborators no longer have repository access.
[ ] GitHub two-factor authentication is enabled.
```

Check your GitHub SSH keys:

```text
https://github.com/settings/keys
```

Check Personal Access Tokens:

```text
https://github.com/settings/personal-access-tokens
```

Check repository collaborators and access:

```text
Repository → Settings → Collaborators and teams
```

### The Verification

Run this local health check:

```bash
git status
git remote -v
git log --oneline --decorate -10
git ls-files
```

Then inspect the GitHub repository settings for:

- Protected `main` branch or ruleset.
- Required CI checks.
- Current collaborators.
- Active deploy keys, SSH keys, and tokens relevant to your workflow.

---

# Appendix B Completion Check

You should now be able to:

- [ ] Choose SSH or HTTPS/PAT authentication intentionally.
- [ ] Protect private keys and tokens.
- [ ] Explain why `.gitignore` does not remove tracked files.
- [ ] Use `.env.example` without committing a real `.env`.
- [ ] Review staged changes before committing.
- [ ] Revoke or rotate a secret immediately after exposure.
- [ ] Maintain a clean, secure GitHub repository.
