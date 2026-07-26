# Appendix M: Multiple Git Identities, Conditional Configuration, and Signed Commits

Many developers use Git in more than one context:

- Personal projects.
- Work repositories.
- Open-source contributions.
- Client projects.
- School or training repositories.

These contexts may require different names, email addresses, SSH keys, and signing settings.

This appendix explains how to manage those identities safely without accidentally creating a work commit with a personal email address—or publishing a personal commit under a work identity.

You will learn how to:

- Inspect Git configuration and discover where values come from.
- Set repository-specific identity values.
- Use conditional Git configuration for separate project folders.
- Use separate SSH keys for different GitHub accounts.
- Sign commits and tags using SSH signing.
- Verify commit signatures locally and on GitHub.

---

# M.1 Understand Git Configuration Precedence

## The Target

Understand why Git may use different names, email addresses, and settings in different repositories.

## The Concept

Git configuration can exist at several levels.

Think of these levels as increasingly specific instructions:

```text
System configuration
    ↓
Global user configuration
    ↓
Repository-local configuration
    ↓
Command-specific configuration
```

The more specific setting wins.

| Configuration level | Typical location | Applies to |
|---|---|---|
| System | Git installation configuration | Every user and repository on a machine |
| Global | `~/.gitconfig` | Every repository for your user account |
| Local | `.git/config` | One repository only |
| Command-specific | Command-line `-c` option | One command invocation only |

For example:

```bash
git config --global user.email "personal@example.com"
```

sets a default personal email.

Inside a work repository, you can override it:

```bash
git config user.email "developer@company.example"
```

The work repository then uses the work email while all other repositories continue using the global personal email.

## The Implementation

Inspect all configured values and their origins:

```bash
git config --list --show-origin
```

Inspect your effective author identity:

```bash
git config user.name
git config user.email
```

Inspect global identity settings:

```bash
git config --global user.name
git config --global user.email
```

Inspect repository-local identity settings:

```bash
git config --local user.name
git config --local user.email
```

If a local value does not exist, Git may report no output and return a nonzero exit code. That simply means the repository is using a less-specific setting.

## The Verification

Output from this command:

```bash
git config --list --show-origin
```

resembles:

```text
file:/Users/your-name/.gitconfig    user.name=Jordan Lee
file:/Users/your-name/.gitconfig    user.email=jordan@example.com
file:.git/config                    core.repositoryformatversion=0
file:.git/config                    remote.origin.url=git@github.com:...
```

You should be able to identify whether your active `user.name` and `user.email` values come from global or repository-local configuration.

---

# M.2 Set a Repository-Specific Identity

## The Target

Configure a different author identity for one repository without changing your global Git identity.

## The Concept

A repository-local identity is useful when a project needs a specific email address.

For example:

```text
Personal projects:
Jordan Lee <jordan.personal@example.com>

Work projects:
Jordan Lee <jordan.lee@company.example>
```

A repository-local setting is stored inside:

```text
.git/config
```

It affects only that repository.

## The Implementation

From the repository requiring a different identity, run:

```bash
git config user.name "Your Work Name"
git config user.email "you@company.example"
```

For example:

```bash
git config user.name "Jordan Lee"
git config user.email "jordan.lee@company.example"
```

Inspect the effective values:

```bash
git config user.name
git config user.email
```

Inspect where the settings are stored:

```bash
git config --list --show-origin | grep -E 'user\.(name|email)'
```

On Windows PowerShell:

```powershell
git config --list --show-origin | Select-String 'user\.(name|email)'
```

## The Verification

Expected output should show the repository configuration source:

```text
file:.git/config    user.name=Jordan Lee
file:.git/config    user.email=jordan.lee@company.example
```

Create a test commit only if you have a meaningful file change ready. Then inspect its author:

```bash
git log -1 --format=full
```

Expected author format:

```text
Author: Jordan Lee <jordan.lee@company.example>
```

---

# M.3 Remove a Repository-Specific Override

## The Target

Return a repository to its global Git identity.

## The Concept

If a repository-local identity is no longer needed, remove only the local override.

Git then falls back to the global configuration.

This is safer than changing your global identity repeatedly when moving between repositories.

## The Implementation

Remove the local name override:

```bash
git config --unset --local user.name
```

Remove the local email override:

```bash
git config --unset --local user.email
```

Check the effective values again:

```bash
git config user.name
git config user.email
```

Check their origins:

```bash
git config --list --show-origin | grep -E 'user\.(name|email)'
```

On Windows PowerShell:

```powershell
git config --list --show-origin | Select-String 'user\.(name|email)'
```

## The Verification

The effective values should now come from your global configuration file, commonly:

```text
file:/Users/your-name/.gitconfig
```

or on Windows:

```text
file:C:/Users/your-name/.gitconfig
```

---

# M.4 Use Conditional Includes for Personal and Work Folders

## The Target

Automatically apply different Git identities depending on the folder containing a repository.

## The Concept

Manually configuring each repository works, but becomes repetitive if you use many repositories.

Git supports **conditional includes**. This feature says:

> “When a repository is inside this folder, load this additional configuration file.”

For example:

```text
~/projects/personal/
    └── personal repositories use personal identity

~/projects/work/
    └── work repositories use work identity
```

Your main Git configuration can include another file only when the repository path matches a folder.

This is like setting separate mail rules for two inboxes. Messages arriving in the work inbox receive work-specific handling automatically.

## The Implementation

Create separate top-level folders.

### macOS, Linux, or Git Bash

```bash
mkdir -p ~/projects/personal
mkdir -p ~/projects/work
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path "$HOME\projects\personal" -Force
New-Item -ItemType Directory -Path "$HOME\projects\work" -Force
```

Create a personal identity configuration file.

### `~/.gitconfig-personal`

```ini
[user]
    name = Your Personal Name
    email = personal@example.com
```

Create a work identity configuration file.

### `~/.gitconfig-work`

```ini
[user]
    name = Your Work Name
    email = you@company.example
```

Replace the placeholder names and email addresses before saving.

Now add conditional includes to your global Git configuration.

### macOS, Linux, or Git Bash

```bash
git config --global includeIf."gitdir:~/projects/personal/".path ~/.gitconfig-personal
git config --global includeIf."gitdir:~/projects/work/".path ~/.gitconfig-work
```

### Windows PowerShell

Use forward slashes in the Git directory pattern:

```powershell
git config --global 'includeIf.gitdir:~/projects/personal/.path' '~/.gitconfig-personal'
git config --global 'includeIf.gitdir:~/projects/work/.path' '~/.gitconfig-work'
```

Inspect the relevant global settings:

```bash
git config --global --list --show-origin
```

## The Verification

Create a temporary personal repository.

### macOS, Linux, or Git Bash

```bash
mkdir -p ~/projects/personal/identity-test
cd ~/projects/personal/identity-test
git init
git config user.name
git config user.email
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path "$HOME\projects\personal\identity-test" -Force
Set-Location "$HOME\projects\personal\identity-test"
git init
git config user.name
git config user.email
```

The output should match the values in `.gitconfig-personal`.

Repeat inside a work folder:

### macOS, Linux, or Git Bash

```bash
mkdir -p ~/projects/work/identity-test
cd ~/projects/work/identity-test
git init
git config user.name
git config user.email
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path "$HOME\projects\work\identity-test" -Force
Set-Location "$HOME\projects\work\identity-test"
git init
git config user.name
git config user.email
```

The output should match `.gitconfig-work`.

Clean up the temporary repositories when finished.

### macOS, Linux, or Git Bash

```bash
rm -rf ~/projects/personal/identity-test
rm -rf ~/projects/work/identity-test
```

### Windows PowerShell

```powershell
Remove-Item -Recurse -Force "$HOME\projects\personal\identity-test"
Remove-Item -Recurse -Force "$HOME\projects\work\identity-test"
```

---

# M.5 Create Separate SSH Keys for Multiple GitHub Accounts

## The Target

Use distinct SSH keys when personal and work GitHub accounts require separate authentication.

## The Concept

One SSH key can be associated with one or more services depending on provider rules and organization policies. However, separate keys are cleaner when you use separate GitHub accounts.

Example:

```text
Personal account:
~/.ssh/id_ed25519_personal

Work account:
~/.ssh/id_ed25519_work
```

An SSH configuration file tells your computer which key to use for each GitHub alias.

```text
github-personal → GitHub using personal key
github-work     → GitHub using work key
```

The repository remote URL then chooses the alias.

## The Implementation

Generate a personal key if needed:

```bash
ssh-keygen -t ed25519 -C "personal@example.com" -f ~/.ssh/id_ed25519_personal
```

Generate a work key if needed:

```bash
ssh-keygen -t ed25519 -C "you@company.example" -f ~/.ssh/id_ed25519_work
```

Add both private keys to the SSH agent:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_personal
ssh-add ~/.ssh/id_ed25519_work
```

On Windows PowerShell:

```powershell
Start-Service ssh-agent
ssh-add "$HOME\.ssh\id_ed25519_personal"
ssh-add "$HOME\.ssh\id_ed25519_work"
```

Create or update the SSH configuration file.

### `~/.ssh/config`

```sshconfig
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes
```

On macOS, Linux, or Git Bash, restrict permissions:

```bash
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_ed25519_personal ~/.ssh/id_ed25519_work
```

Copy each public key and add it to the corresponding GitHub account.

Personal public key:

```bash
cat ~/.ssh/id_ed25519_personal.pub
```

Work public key:

```bash
cat ~/.ssh/id_ed25519_work.pub
```

Add keys through each account’s settings page:

```text
https://github.com/settings/keys
```

## The Verification

Test each identity:

```bash
ssh -T git@github-personal
ssh -T git@github-work
```

Each command should identify the expected GitHub account.

A personal repository remote should use:

```text
git@github-personal:PERSONAL_USERNAME/release-notes-manager.git
```

A work repository remote should use:

```text
git@github-work:WORK_ORGANIZATION/work-repository.git
```

Inspect the current remote:

```bash
git remote -v
```

Change a repository’s remote only if you intentionally need to use a different identity:

```bash
git remote set-url origin git@github-personal:PERSONAL_USERNAME/release-notes-manager.git
```

---

# M.6 Understand Commit Signing

## The Target

Understand what signed commits and signed tags prove.

## The Concept

A commit signature is cryptographic evidence that a particular key signed a commit.

It helps answer:

> “Was this commit created or approved by the holder of this signing key?”

A signature does **not** automatically prove that code is safe, reviewed, or free of bugs. It proves the signature matches a trusted public key.

Git supports several signing mechanisms, including:

- GPG keys.
- SSH keys.
- S/MIME certificates.

For beginners using GitHub, SSH signing is often simpler because you may already use an SSH key for Git authentication.

The concepts are separate:

```text
SSH authentication:
Can this computer push to the repository?

Commit signing:
Was this commit signed by a known cryptographic key?
```

You can use the same SSH key material for both purposes, but organizational policy may require separate signing keys.

---

# M.7 Configure SSH Commit Signing

## The Target

Configure Git to sign commits using an SSH key.

## The Concept

Git can use an SSH private key to create commit signatures.

GitHub can mark commits as **Verified** when it can match the signature to a public signing key associated with your GitHub account.

Before configuring signing, ensure your Git version supports SSH signing:

```bash
git --version
```

SSH commit signing requires a modern Git version. If your Git version is old, update Git before continuing.

## The Implementation

Use a dedicated signing key or your existing personal SSH key.

For a dedicated signing key:

```bash
ssh-keygen -t ed25519 -C "personal@example.com signing key" -f ~/.ssh/id_ed25519_signing
```

Add it to the SSH agent:

```bash
ssh-add ~/.ssh/id_ed25519_signing
```

Configure Git to use SSH signing:

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519_signing.pub
git config --global commit.gpgsign true
git config --global tag.gpgSign true
```

Important: Git expects the **public-key path** for `user.signingkey` in this SSH-signing configuration.

Print the public key:

```bash
cat ~/.ssh/id_ed25519_signing.pub
```

Add that public key to GitHub as a signing key:

1. Open:

   ```text
   https://github.com/settings/keys
   ```

2. Select **New SSH key**.
3. Give it a descriptive title:

   ```text
   Personal commit signing key
   ```

4. Choose the key type:

   ```text
   Signing Key
   ```

5. Paste the public key.
6. Save the key.

## The Verification

Inspect signing configuration:

```bash
git config --global gpg.format
git config --global user.signingkey
git config --global commit.gpgsign
git config --global tag.gpgSign
```

Expected output resembles:

```text
ssh
/Users/your-name/.ssh/id_ed25519_signing.pub
true
true
```

---

# M.8 Create and Verify a Signed Commit

## The Target

Create a signed commit and inspect its signature locally.

## The Concept

When `commit.gpgsign` is enabled, ordinary commits are signed automatically.

You can also request signing explicitly:

```bash
git commit -S -m "Add signed commit demonstration"
```

The `-S` flag means:

> “Create a signed commit.”

For this exercise, create a disposable branch so the demonstration can be removed afterward.

## The Implementation

Return to your project repository:

```bash
cd ~/projects/release-notes-manager
```

On Windows PowerShell:

```powershell
Set-Location "$HOME\projects\release-notes-manager"
```

Ensure the working tree is clean:

```bash
git switch main
git pull --ff-only
git status
```

Create a practice branch:

```bash
git switch -c practice/signed-commit
```

Create this file.

### `release-notes-manager/SIGNED_COMMIT_PRACTICE.md`

```md
# Signed Commit Practice

This file demonstrates creating and verifying a signed Git commit.
```

Commit it:

```bash
git add SIGNED_COMMIT_PRACTICE.md
git commit -m "Add signed commit practice"
```

Verify the latest commit signature:

```bash
git log --show-signature -1
```

For a more direct verification command:

```bash
git verify-commit HEAD
```

## The Verification

`git log --show-signature -1` should show signature information.

Exact output varies by operating system and Git version. A successful SSH signature often includes information similar to:

```text
Good "git" signature for personal@example.com with ED25519 key SHA256:...
```

If verification fails locally, confirm:

```bash
git config --global gpg.format
git config --global user.signingkey
ssh-add -l
```

To remove the practice branch when finished:

```bash
git switch main
git branch -D practice/signed-commit
```

---

# M.9 Create and Verify a Signed Tag

## The Target

Create a signed annotated tag for a release candidate or stable release.

## The Concept

Tags are especially valuable to sign because they identify release points.

A signed annotated tag says:

> “The holder of this signing key marked this exact commit as this release.”

The command:

```bash
git tag -s v1.0.1 -m "Release version 1.0.1"
```

creates a signed tag.

If `tag.gpgSign` is enabled, standard annotated tags may be signed automatically. Use `-s` when you want to make the intent explicit.

## The Implementation

Do not create a fake release tag such as `v1.0.1` unless you are preparing a real release.

Instead, use a practice tag:

```bash
git switch main
git pull --ff-only
git tag -s practice-signed-tag -m "Practice signed tag"
```

Inspect the tag:

```bash
git show practice-signed-tag
```

Verify it:

```bash
git verify-tag practice-signed-tag
```

Delete the practice tag when finished:

```bash
git tag -d practice-signed-tag
```

## The Verification

A successful verification should report a good signature.

Confirm the temporary tag is removed:

```bash
git tag --list practice-signed-tag
```

Expected output: no output.

---

# M.10 Verify Signed Commits on GitHub

## The Target

Confirm that GitHub recognizes a signed commit as verified.

## The Concept

Local verification confirms that your local Git tooling recognizes the signature.

GitHub verification confirms that GitHub can associate the signing key with your account and display the signature status in the web interface.

A commit may be signed but not shown as verified on GitHub if:

- The signing public key was not added to your GitHub account.
- The commit email does not match an email associated with your GitHub account.
- The key was added as an authentication key instead of a signing key.
- The key or identity configuration is incorrect.
- The repository hosting platform has a policy or limitation affecting verification.

## The Implementation

Create a real, meaningful signed commit on a feature branch. For example, add a documentation clarification:

```bash
git switch -c docs/document-commit-signing
```

Append this section to `SECURITY.md`:

```md
## Commit Integrity

When project policy requires it, contributors should sign commits and annotated release tags with an approved signing key. A valid signature helps verify that a known key created the commit or tag, but it does not replace code review or automated testing.
```

Review and test:

```bash
git diff -- SECURITY.md
npm test
```

Commit and push:

```bash
git add SECURITY.md
git commit -m "Document commit signing guidance"
git push -u origin docs/document-commit-signing
```

Open a pull request and inspect the commit list.

## The Verification

On GitHub, open the pull request’s **Commits** tab.

A correctly recognized commit should show a badge similar to:

```text
Verified
```

Select the badge to inspect signature details.

Merge the pull request only if it is a meaningful project change and passes normal CI and review requirements.

---

# M.11 Temporarily Disable Automatic Signing

## The Target

Disable automatic commit or tag signing when working in an environment where the signing key is unavailable.

## The Concept

Automatic signing is useful, but it can be inconvenient in temporary environments such as:

- Disposable containers.
- Remote development machines.
- Emergency recovery systems.
- CI environments that should not possess personal signing keys.

You can disable it globally or for one command.

Do not disable a repository’s signing requirement if your organization requires signed commits. Follow the project’s contribution policy.

## The Implementation

Disable automatic commit signing globally:

```bash
git config --global commit.gpgsign false
```

Disable automatic tag signing globally:

```bash
git config --global tag.gpgSign false
```

Disable signing for one commit only:

```bash
git -c commit.gpgsign=false commit -m "Unsigned temporary commit"
```

Disable signing for one tag only:

```bash
git -c tag.gpgSign=false tag -a temporary-tag -m "Temporary unsigned tag"
```

Re-enable automatic signing:

```bash
git config --global commit.gpgsign true
git config --global tag.gpgSign true
```

## The Verification

Inspect the active settings:

```bash
git config --global commit.gpgsign
git config --global tag.gpgSign
```

Expected output after re-enabling:

```text
true
true
```

---

# M.12 Identity and Signing Troubleshooting

## Problem: Commit Uses the Wrong Email

### Inspect

```bash
git log -1 --format=full
git config user.email
git config --list --show-origin | grep user.email
```

On Windows PowerShell:

```powershell
git config --list --show-origin | Select-String 'user.email'
```

### Fix

Set a repository-local email:

```bash
git config user.email "correct@example.com"
```

Correct the most recent unpushed commit:

```bash
git commit --amend --reset-author --no-edit
```

The `--reset-author` option replaces the author information using your current Git identity.

---

## Problem: SSH Signing Fails Because No Key Is Available

### Inspect

```bash
ssh-add -l
git config --global user.signingkey
```

### Fix

Add the signing key:

```bash
ssh-add ~/.ssh/id_ed25519_signing
```

Confirm the configured public-key path exists:

```bash
cat ~/.ssh/id_ed25519_signing.pub
```

Then retry the commit.

---

## Problem: GitHub Does Not Show “Verified”

### Inspect

```bash
git log --show-signature -1
git log -1 --format=full
```

Confirm:

1. The commit is actually signed.
2. The signing public key is added to GitHub as a **Signing Key**.
3. The commit email is associated with the GitHub account.
4. The push reached the expected GitHub account and repository.

### Fix

Update the GitHub signing key or Git identity, then create a new signed commit. Existing commits cannot be retroactively re-signed without rewriting history.

---

## Problem: Conditional Includes Do Not Apply

### Inspect

From inside the repository:

```bash
git config --show-origin --get user.email
git rev-parse --show-toplevel
```

### Fix

Confirm that:

- The repository folder is under the configured path.
- The `gitdir:` condition ends with a trailing slash.
- The included configuration file exists.
- The included file uses valid INI syntax.

Review global include rules:

```bash
git config --global --get-regexp '^includeIf\.'
```

---

# M.13 Identity and Signing Command Reference

## Inspect Effective Identity

```bash
git config user.name
git config user.email
```

## Inspect Configuration Origins

```bash
git config --list --show-origin
```

## Set Repository-Local Identity

```bash
git config user.name "Your Name"
git config user.email "you@example.com"
```

## Remove Local Identity Override

```bash
git config --unset --local user.name
git config --unset --local user.email
```

## Configure SSH Signing

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519_signing.pub
git config --global commit.gpgsign true
git config --global tag.gpgSign true
```

## Verify a Commit

```bash
git verify-commit <commit-hash>
```

## Verify a Tag

```bash
git verify-tag <tag-name>
```

## Create an Explicitly Signed Commit

```bash
git commit -S -m "Describe signed change"
```

## Create an Explicitly Signed Tag

```bash
git tag -s v1.0.0 -m "Release version 1.0.0"
```

---

# Appendix M Completion Check

You should now be able to:

- [ ] Explain Git configuration precedence.
- [ ] Inspect the origin of Git configuration values.
- [ ] Set and remove repository-specific identities.
- [ ] Use conditional includes for personal and work project folders.
- [ ] Configure distinct SSH keys for separate GitHub identities.
- [ ] Explain the difference between SSH authentication and commit signing.
- [ ] Configure SSH commit signing.
- [ ] Verify signed commits and tags locally.
- [ ] Confirm signed commits on GitHub.
- [ ] Troubleshoot common identity, signing, and conditional-configuration issues.
