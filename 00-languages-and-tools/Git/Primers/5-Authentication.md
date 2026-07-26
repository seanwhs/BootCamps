# Primer 5: GitHub Accounts, Authentication, and Remote Repository Basics

Git and GitHub are related, but they are not the same thing.

```text
Git
= Version-control software running on your computer.

GitHub
= A hosted collaboration platform for Git repositories.
```

You can use Git without GitHub:

```text
Edit files
    ↓
Create commits
    ↓
Create branches
    ↓
Merge work
```

You need GitHub when you want to:

- Store a repository remotely.
- Collaborate with other contributors.
- Open pull requests.
- Review code.
- Track issues.
- Run GitHub Actions.
- Publish releases.

This primer explains the minimum GitHub account and authentication knowledge needed before connecting a local repository to GitHub.

---

# P5.1 Understand Local and Remote Repositories

## The Target

Understand the difference between a repository on your computer and a repository hosted on GitHub.

## The Concept

A **local repository** lives on your computer.

```text
Your computer
└── release-notes-manager/
    ├── .git/
    ├── README.md
    └── src/
```

A **remote repository** lives somewhere else, usually on GitHub.

```text
GitHub
└── YOUR_GITHUB_USERNAME/release-notes-manager
```

Git lets the two repositories exchange commits.

```text
Your computer                         GitHub
─────────────                         ──────
Local main branch                     Remote main branch
       │                                      │
       ├──────────── git push ───────────────►│
       │                                      │
       ◄─────────── git fetch ────────────────┤
       │                                      │
       ◄──────────── git pull ────────────────┤
```

The normal remote name is:

```text
origin
```

For example:

```text
origin = git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
```

`origin` is only a convenient local nickname. It usually refers to the main GitHub repository for a project.

## The Implementation

From an existing Git repository, inspect configured remotes:

```bash
git remote -v
```

If you have not connected the repository to GitHub yet, the command may produce no output. That is normal.

Inspect local branches:

```bash
git branch
```

## The Verification

You should be able to explain:

```text
Local repository:
The project history currently stored on my computer.

Remote repository:
A hosted copy of the project history, usually on GitHub.

origin:
The local nickname for the primary remote repository.
```

---

# P5.2 Create a GitHub Account

## The Target

Create a GitHub account and choose an appropriate username.

## The Concept

Your GitHub username becomes part of repository URLs.

For example, if your username is:

```text
jordanlee
```

a repository URL may be:

```text
https://github.com/jordanlee/release-notes-manager
```

Choose a username that is professional and easy to recognize, especially if you plan to use GitHub for a portfolio, open-source contributions, or work collaboration.

## The Implementation

Open:

```text
https://github.com/signup
```

Create an account.

Recommended account-security steps:

1. Use an email address you control.
2. Use a unique password stored in a password manager.
3. Enable two-factor authentication.
4. Verify your email address.
5. Save recovery codes in a secure location.

Enable two-factor authentication through:

```text
https://github.com/settings/security
```

## The Verification

After signing in, open your profile:

```text
https://github.com/YOUR_GITHUB_USERNAME
```

Confirm that:

- Your username appears correctly.
- Your email is verified.
- Two-factor authentication is enabled.
- You can access GitHub account settings.

---

# P5.3 Understand Public and Private Repositories

## The Target

Choose appropriate repository visibility.

## The Concept

GitHub repositories can usually be **public** or **private**.

| Visibility | Who can see it | Appropriate use |
|---|---|---|
| Public | Anyone on the internet | Open-source work, portfolio projects, public documentation |
| Private | Only you and invited collaborators | Internal tools, prototypes, client work, confidential projects |

A public repository is not a safe place for:

- Passwords.
- API keys.
- Access tokens.
- Private certificates.
- Customer data.
- Internal business documents.
- Production configuration containing secrets.

Making a repository private does not make committing secrets acceptable. Collaborators, backups, logs, forks, and accidental sharing can still expose sensitive data.

## The Implementation

When creating a GitHub repository, choose visibility intentionally:

```text
Public
```

Use for a portfolio-quality learning project you want others to inspect.

```text
Private
```

Use for work that should remain visible only to you and invited collaborators.

## The Verification

On a repository page, inspect its visibility label near the repository name:

```text
Public
```

or:

```text
Private
```

Confirm that the chosen visibility matches the project’s intended audience.

---

# P5.4 Understand SSH Authentication

## The Target

Understand why SSH keys are commonly used for GitHub authentication.

## The Concept

When you push code to GitHub, GitHub must confirm that you are allowed to change the repository.

SSH authentication uses a key pair:

```text
Private key
    → stays on your computer

Public key
    → added to your GitHub account
```

Think of it like a lock and key:

```text
Public key = lock registered with GitHub
Private key = key that remains only with you
```

GitHub checks that your computer holds the private key corresponding to the public key you registered.

Never share the private key.

Private key examples:

```text
~/.ssh/id_ed25519
~/.ssh/id_ed25519_personal
```

Public key examples:

```text
~/.ssh/id_ed25519.pub
~/.ssh/id_ed25519_personal.pub
```

The `.pub` file is public. The file without `.pub` is private.

## The Implementation

Check whether an SSH directory exists.

### macOS, Linux, or Git Bash

```bash
ls -la ~/.ssh
```

### Windows PowerShell

```powershell
Get-ChildItem -Force "$HOME\.ssh"
```

If you see:

```text
id_ed25519
id_ed25519.pub
```

you may already have a usable key pair.

Do not delete existing keys simply because you are unsure what they are. They may be used by other repositories, servers, or services.

## The Verification

Confirm you understand this safety rule:

```text
Safe to share:
id_ed25519.pub

Never share:
id_ed25519
```

---

# P5.5 Generate an SSH Key

## The Target

Generate a modern SSH key pair for GitHub if you do not already have one you intend to use.

## The Concept

The preferred modern key type is:

```text
ed25519
```

The command creates two files:

```text
id_ed25519
id_ed25519.pub
```

The optional email comment helps you recognize the key later. It does not grant access by itself.

## The Implementation

Replace the email address with the email associated with your GitHub account:

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

When prompted for a file location, press Enter to accept the default unless you intentionally manage separate keys:

```text
Enter file in which to save the key (/Users/your-name/.ssh/id_ed25519):
```

When prompted for a passphrase:

```text
Enter passphrase:
```

use a strong passphrase.

A passphrase protects the private key if someone copies the private-key file from your computer.

## The Verification

Check the key files.

### macOS, Linux, or Git Bash

```bash
ls -la ~/.ssh
```

### Windows PowerShell

```powershell
Get-ChildItem -Force "$HOME\.ssh"
```

Expected files include:

```text
id_ed25519
id_ed25519.pub
```

Do not open or copy the private key.

---

# P5.6 Add the SSH Key to the SSH Agent

## The Target

Load the private SSH key into the local SSH agent.

## The Concept

An SSH agent is a local helper process that remembers your unlocked private key during a session.

Without an agent, Git may repeatedly ask for your key passphrase.

The SSH agent holds the key in memory so Git can use it when connecting to GitHub.

## The Implementation

### macOS, Linux, or Git Bash

Start the SSH agent:

```bash
eval "$(ssh-agent -s)"
```

Add the private key:

```bash
ssh-add ~/.ssh/id_ed25519
```

### Windows PowerShell

Start the SSH agent service:

```powershell
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
```

Add the key:

```powershell
ssh-add "$HOME\.ssh\id_ed25519"
```

List keys currently loaded in the agent:

```bash
ssh-add -l
```

## The Verification

Expected output resembles:

```text
256 SHA256:... you@example.com (ED25519)
```

The fingerprint value will differ on your computer.

If the command says no identities are loaded, rerun the `ssh-add` command with the path to your private key.

---

# P5.7 Add the Public Key to GitHub

## The Target

Register your public SSH key with GitHub.

## The Concept

GitHub needs the public half of your key pair.

The public key typically begins with:

```text
ssh-ed25519
```

and ends with the email comment you used while creating the key.

A public key resembles:

```text
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... you@example.com
```

This full line is safe to add to GitHub.

## The Implementation

Copy the public key.

### macOS

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

### Linux

If `xclip` is installed:

```bash
xclip -selection clipboard < ~/.ssh/id_ed25519.pub
```

Otherwise, display it and copy it manually:

```bash
cat ~/.ssh/id_ed25519.pub
```

### Windows Git Bash

```bash
cat ~/.ssh/id_ed25519.pub | clip
```

### Windows PowerShell

```powershell
Get-Content "$HOME\.ssh\id_ed25519.pub" | Set-Clipboard
```

Then:

1. Open:

   ```text
   https://github.com/settings/keys
   ```

2. Select **New SSH key**.
3. Enter a descriptive title, such as:

   ```text
   Personal laptop
   ```

4. Select key type:

   ```text
   Authentication Key
   ```

5. Paste the full public-key value.
6. Select **Add SSH key**.
7. Confirm with your GitHub password or two-factor authentication if prompted.

## The Verification

GitHub should list the new key under:

```text
SSH keys
```

The key title should help you identify the device later.

For example:

```text
Personal laptop
Added on 2026-07-25
```

---

# P5.8 Test GitHub SSH Authentication

## The Target

Verify that your computer can authenticate with GitHub over SSH.

## The Concept

The SSH test checks whether GitHub recognizes your key.

GitHub does not provide a shell account, so a successful result says authentication worked while shell access remains unavailable.

That is expected.

## The Implementation

Run:

```bash
ssh -T git@github.com
```

The first time, SSH may ask whether you trust GitHub’s host key:

```text
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Verify the fingerprint against GitHub’s current SSH key fingerprints documentation:

```text
https://docs.github.com/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
```

If it matches, type:

```text
yes
```

## The Verification

Expected output resembles:

```text
Hi YOUR_GITHUB_USERNAME! You've successfully authenticated, but GitHub does not provide shell access.
```

That message confirms the SSH connection is correctly configured.

---

# P5.9 Understand HTTPS and Personal Access Tokens

## The Target

Understand the alternative authentication method used when SSH is unavailable.

## The Concept

HTTPS remotes look like this:

```text
https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager.git
```

When pushing through HTTPS, GitHub requires:

```text
Username: YOUR_GITHUB_USERNAME
Password: Personal Access Token
```

A **Personal Access Token**, or PAT, replaces your GitHub password for command-line Git operations.

Never use your normal GitHub password in a Git prompt.

Treat a PAT like a password:

```text
Do not commit it.
Do not paste it into code.
Do not include it in screenshots.
Do not send it in chat messages.
Revoke it if exposed.
```

## The Implementation

If SSH is not suitable for your environment, create a fine-grained token at:

```text
https://github.com/settings/personal-access-tokens
```

Use a descriptive token name:

```text
Personal development machine
```

Use an expiration date.

Grant only required access, usually:

```text
Repository permissions:
Contents: Read and write
```

Configure a credential helper.

### macOS

```bash
git config --global credential.helper osxkeychain
```

### Windows

```bash
git config --global credential.helper manager
```

### Linux

Install Git Credential Manager, then configure:

```bash
git config --global credential.helper manager
```

## The Verification

Confirm your credential helper:

```bash
git config --global credential.helper
```

Expected output may be:

```text
manager
```

or:

```text
osxkeychain
```

Do not use this insecure configuration for a real account:

```bash
git config --global credential.helper store
```

It can store credentials in plain text.

---

# P5.10 Understand GitHub URLs

## The Target

Recognize common GitHub repository URL formats.

## The Concept

GitHub commonly provides two clone URL formats.

### SSH URL

```text
git@github.com:OWNER/REPOSITORY.git
```

Example:

```text
git@github.com:octocat/release-notes-manager.git
```

Use this when SSH authentication is configured.

### HTTPS URL

```text
https://github.com/OWNER/REPOSITORY.git
```

Example:

```text
https://github.com/octocat/release-notes-manager.git
```

Use this when HTTPS and PAT authentication is configured.

### Browser URL

```text
https://github.com/OWNER/REPOSITORY
```

This is the normal web page address. It is not usually the URL you copy for `git clone`, although Git can often infer the `.git` form.

## The Implementation

Inspect the current repository remote if one exists:

```bash
git remote -v
```

Example SSH output:

```text
origin  git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git (fetch)
origin  git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git (push)
```

Example HTTPS output:

```text
origin  https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager.git (fetch)
origin  https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager.git (push)
```

## The Verification

You should be able to identify whether the repository uses SSH or HTTPS by reading the URL:

| URL begins with | Authentication type |
|---|---|
| `git@github.com:` | SSH |
| `https://github.com/` | HTTPS with credential helper and PAT when needed |

---

# P5.11 Account and Authentication Safety Checklist

## The Target

Establish secure GitHub account habits before collaborating or pushing code.

## The Concept

GitHub access is part of your software supply chain.

A compromised GitHub account can expose source code, secrets, releases, deployment workflows, and organization settings.

## The Implementation

Use this checklist:

```text
Account safety
[ ] My GitHub email address is verified.
[ ] Two-factor authentication is enabled.
[ ] I use a unique password stored in a password manager.
[ ] Recovery codes are stored securely.
[ ] I review active SSH keys and PATs periodically.

SSH safety
[ ] My private SSH key remains only on my computer.
[ ] My private key has a passphrase.
[ ] My public key is registered with the correct GitHub account.
[ ] I remove old device keys from GitHub when they are no longer used.

PAT safety
[ ] Tokens use the minimum required permissions.
[ ] Tokens have expiration dates.
[ ] Tokens are stored in an operating-system credential manager or password manager.
[ ] Tokens are revoked immediately if exposed.

Repository safety
[ ] I know whether a repository is public or private.
[ ] I do not commit secrets to either public or private repositories.
[ ] I use `.gitignore` for local environment files.
```

## The Verification

Review registered SSH keys:

```text
https://github.com/settings/keys
```

Review personal access tokens:

```text
https://github.com/settings/personal-access-tokens
```

Remove keys and tokens that belong to devices or workflows you no longer use.

---

# Primer 5 Reference: Authentication Commands

## Test SSH Authentication

```bash
ssh -T git@github.com
```

## List Loaded SSH Keys

```bash
ssh-add -l
```

## Add a Private Key to SSH Agent

```bash
ssh-add ~/.ssh/id_ed25519
```

## Display a Public Key

```bash
cat ~/.ssh/id_ed25519.pub
```

## Inspect GitHub CLI Authentication

```bash
gh auth status
```

## Inspect Current Repository Remote

```bash
git remote -v
```

## Add an SSH Remote

```bash
git remote add origin git@github.com:YOUR_GITHUB_USERNAME/REPOSITORY.git
```

## Add an HTTPS Remote

```bash
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/REPOSITORY.git
```

---

# Primer 5 Completion Check

Before beginning Part 3, confirm that you can:

- [ ] Explain the difference between Git and GitHub.
- [ ] Explain the difference between a local repository and a remote repository.
- [ ] Identify the role of `origin`.
- [ ] Choose public or private repository visibility intentionally.
- [ ] Create and secure a GitHub account with two-factor authentication.
- [ ] Explain the difference between an SSH private key and public key.
- [ ] Generate and register an SSH key, or understand HTTPS/PAT authentication.
- [ ] Test GitHub SSH authentication.
- [ ] Identify SSH and HTTPS remote URL formats.
- [ ] Treat Personal Access Tokens and private keys as sensitive credentials.
