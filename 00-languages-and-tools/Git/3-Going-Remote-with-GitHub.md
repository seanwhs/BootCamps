# Part 3: Going Remote with GitHub

So far, every commit exists only on your computer.

That is useful, but it has limitations:

- Your work is not automatically available on another computer.
- A teammate cannot access your repository.
- You cannot use GitHub pull requests, issues, or Actions yet.
- A hardware failure could remove your local Git history if you do not have an independent backup.

In this part, you will connect the local `release-notes-manager` repository to GitHub. You will authenticate securely, publish your `main` branch, understand remote-tracking branches, practice fetching and pulling changes, clone a repository, understand forks, and add a robust `.gitignore`.

---

## Part 3 Roadmap

You will learn how to:

1. Understand the relationship between a local repository and a GitHub repository.
2. Authenticate with GitHub using SSH or HTTPS with a Personal Access Token.
3. Create a remote repository on GitHub.
4. Connect your local repository using `git remote add`.
5. Publish the local `main` branch with `git push -u`.
6. Inspect remote and remote-tracking branches.
7. Understand `git fetch` versus `git pull`.
8. Clone a repository to a second local folder.
9. Understand the difference between cloning and forking.
10. Create a production-quality `.gitignore`.
11. Verify that ignored files and secrets are not accidentally staged.

---

# Step 1: Understand Local Repositories, Remotes, and Remote-Tracking Branches

## The Target

Build a mental model for how your local repository will communicate with GitHub.

## The Concept

Your current repository lives on your computer:

```text
Your computer
└── release-notes-manager/
    ├── .git/
    ├── README.md
    ├── RELEASE_CHECKLIST.md
    ├── RELEASE_NOTES.md
    └── GLOSSARY.md
```

GitHub will host another copy of the repository on the internet.

```text
Your computer                             GitHub
─────────────                             ──────
Local repository                          Remote repository
main                                      main
commits                                   commits
branches                                  branches
```

Git calls a connection to another repository a **remote**.

The conventional name for the primary remote is:

```text
origin
```

The name is just a local shortcut. It does not have special technical powers, but almost every Git project uses it for the primary hosted repository.

For example:

```text
origin = git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
```

Git also creates **remote-tracking branches** after it communicates with GitHub.

A remote-tracking branch is your local Git record of where a branch was the last time you communicated with the remote.

For example:

```text
origin/main
```

means:

> “The last known state of the `main` branch on the remote named `origin`.”

It is not the same as your local `main` branch.

```text
Local branch:             main
Remote-tracking branch:   origin/main
Actual GitHub branch:     main on GitHub
```

A simplified relationship looks like this:

```text
Your local Git repository

main         → your current local main commit
origin/main  → the last GitHub main commit you fetched or pushed

GitHub

main         → the actual GitHub main commit
```

## The Implementation

Inspect the current local branches and remotes:

```bash
git branch
git remote
```

Inspect the current repository state:

```bash
git status
```

## The Verification

At this point, you should see:

```text
* main
```

from:

```bash
git branch
```

The following command should produce no output because no remote has been added yet:

```bash
git remote
```

Your status should be clean:

```text
On branch main
nothing to commit, working tree clean
```

---

# Step 2: Choose a Secure GitHub Authentication Method

## The Target

Choose and configure either SSH authentication or HTTPS authentication using a GitHub Personal Access Token.

## The Concept

GitHub must verify that you are allowed to push changes to a repository.

There are two recommended methods:

| Method | Best for | How it works |
|---|---|---|
| SSH key | Regular development from a personal computer | Your computer proves its identity using a cryptographic key pair. |
| HTTPS + Personal Access Token | Environments where SSH is unavailable or restricted | Git prompts for a username and token instead of a password. |

Do **not** use your GitHub account password for command-line Git authentication. GitHub no longer accepts account passwords for Git operations over HTTPS.

### Option A: SSH

SSH uses two related files:

```text
Private key: stays only on your computer.
Public key:  added to your GitHub account.
```

Think of the private key as a key that must remain in your pocket. The public key is like a special lock you give GitHub. GitHub can verify that you possess the matching private key without ever receiving it.

Never share, commit, email, upload, or paste your private key into a repository.

### Option B: HTTPS with a Personal Access Token

A **Personal Access Token**, usually called a PAT, is a generated credential with controlled permissions.

Treat a PAT like a password:

- Do not commit it.
- Do not paste it into source code.
- Do not share it in screenshots or chat messages.
- Revoke it immediately if exposed.

For this tutorial, choose one method and follow its implementation section.

---

## The Implementation: Option A — Configure SSH Authentication

First, check whether you already have SSH keys:

### macOS, Linux, or Git Bash

```bash
ls -al ~/.ssh
```

### Windows PowerShell

```powershell
Get-ChildItem -Force "$HOME\.ssh"
```

Look for files such as:

```text
id_ed25519
id_ed25519.pub
```

The file without `.pub` is private. The file ending in `.pub` is public.

If you do not already have an `id_ed25519` key pair that you want to use, generate one. Replace the email address with the address associated with your GitHub account:

```bash
ssh-keygen -t ed25519 -C "you@example.com"
```

When prompted for the file location, press Enter to accept the default:

```text
~/.ssh/id_ed25519
```

When prompted for a passphrase, use a strong passphrase. A passphrase protects the private key if someone gains access to your computer.

Start the SSH agent.

### macOS, Linux, or Git Bash

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Windows PowerShell

Start the service in an elevated PowerShell window if needed:

```powershell
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
```

Then, in your normal PowerShell session:

```powershell
ssh-add "$HOME\.ssh\id_ed25519"
```

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

Otherwise, print the public key and copy it manually:

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

Now add the copied public key to GitHub:

1. Open [https://github.com/settings/keys](https://github.com/settings/keys).
2. Select **New SSH key**.
3. Enter a descriptive title, such as:

   ```text
   Jordan's personal laptop
   ```

4. Set the key type to **Authentication Key**.
5. Paste the complete public-key value.
6. Select **Add SSH key**.
7. Confirm with your GitHub password or multi-factor authentication if prompted.

Test the connection:

```bash
ssh -T git@github.com
```

---

## The Implementation: Option B — Configure HTTPS with a Personal Access Token

Open GitHub’s token settings page:

```text
https://github.com/settings/personal-access-tokens
```

GitHub may offer both **fine-grained** and **classic** tokens. Prefer a **fine-grained personal access token** when possible because it allows narrower permissions.

Create a token with these settings:

1. Select **Generate new token**.
2. Give it a descriptive name, such as:

   ```text
   Release Notes Manager development machine
   ```

3. Choose an expiration period appropriate for your security policy. Shorter-lived tokens reduce risk.
4. Limit repository access to:
   - **Only select repositories**, then select `release-notes-manager` after creating it, or
   - **All repositories** if you understand and accept the broader access.
5. Under repository permissions, set:

   ```text
   Contents: Read and write
   ```

6. Generate the token.
7. Copy it immediately and store it in a password manager.

GitHub displays a newly generated token only once.

When Git later asks for credentials over HTTPS:

```text
Username: your-github-username
Password: paste-your-personal-access-token
```

The token is used in place of a password.

To avoid repeatedly entering the token, configure a secure operating-system credential helper.

### macOS

```bash
git config --global credential.helper osxkeychain
```

### Windows

```bash
git config --global credential.helper manager
```

### Linux

Git Credential Manager is recommended. Follow its current installation instructions:

```text
https://github.com/git-ecosystem/git-credential-manager
```

After installation, configure it:

```bash
git config --global credential.helper manager
```

Do not use Git’s `store` credential helper for sensitive accounts:

```bash
git config --global credential.helper store
```

It can save credentials in plain text on disk.

---

## The Verification

### SSH verification

A successful SSH test usually prints a message similar to:

```text
Hi YOUR_GITHUB_USERNAME! You've successfully authenticated, but GitHub does not provide shell access.
```

That message is correct. GitHub allows Git operations but does not give you a remote shell.

### HTTPS verification

The token is not tested until you push or clone over HTTPS. Confirm that your credential helper configuration is set:

```bash
git config --global credential.helper
```

Expected output is platform-dependent, for example:

```text
manager
```

or:

```text
osxkeychain
```

---

# Step 3: Create an Empty GitHub Repository

## The Target

Create a new empty repository on GitHub that will become the remote home for your existing local project.

## The Concept

You already have a local Git repository with commits.

To connect it safely, create an **empty** GitHub repository. Do not initialize the GitHub repository with a README, `.gitignore`, or license yet.

Why?

If GitHub creates its own initial commit, your local and remote repositories begin with unrelated histories. You can still combine them, but there is no reason to create that complexity here.

Your local repository already contains the project history you want to publish.

## The Implementation

In your browser:

1. Open [https://github.com/new](https://github.com/new).
2. For **Repository name**, enter:

   ```text
   release-notes-manager
   ```

3. Optionally add this description:

   ```text
   A hands-on project for learning Git and GitHub workflows.
   ```

4. Choose **Public** if you want the project visible as a portfolio example, or **Private** if you want it visible only to you and explicitly invited collaborators.
5. Leave all initialization options unchecked:
   - Do not add a README.
   - Do not add a `.gitignore`.
   - Do not choose a license.
6. Select **Create repository**.

GitHub will display a “Quick setup” page with URLs similar to one of these.

### SSH URL

```text
git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
```

### HTTPS URL

```text
https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager.git
```

Copy the URL that matches the authentication method you chose.

## The Verification

The GitHub repository page should show an empty repository setup screen, not a README file or commit history.

The page should include instructions similar to:

```text
…or push an existing repository from the command line
```

You are ready to connect your local repository.

---

# Step 4: Add GitHub as the `origin` Remote

## The Target

Connect your local repository to the empty GitHub repository using the remote name `origin`.

## The Concept

The command structure is:

```bash
git remote add <remote-name> <repository-url>
```

For the primary GitHub repository, the standard remote name is:

```text
origin
```

For example:

```bash
git remote add origin git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
```

This command does not upload anything. It only saves a named destination in your local Git configuration.

You can inspect remote URLs with:

```bash
git remote -v
```

The `-v` flag means “verbose.” It displays separate fetch and push URLs.

## The Implementation

Make sure you are in your local project directory:

```bash
git status
```

Add the remote using **one** of the following forms.

### SSH remote URL

```bash
git remote add origin git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
```

### HTTPS remote URL

```bash
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager.git
```

Replace `YOUR_GITHUB_USERNAME` with your real GitHub username.

Inspect the result:

```bash
git remote -v
```

Inspect the detailed remote configuration:

```bash
git remote show origin
```

Because the remote is currently empty, some details may not be available until after the first push.

## The Verification

Expected `git remote -v` output resembles:

```text
origin  git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git (fetch)
origin  git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git (push)
```

Or, for HTTPS:

```text
origin  https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager.git (fetch)
origin  https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager.git (push)
```

If you accidentally used the wrong URL, replace it without deleting the repository:

```bash
git remote set-url origin <correct-repository-url>
```

Then verify again:

```bash
git remote -v
```

---

# Step 5: Create a Secure `.gitignore` Before Your First Push

## The Target

Add a `.gitignore` file that prevents common secrets, local configuration files, dependencies, logs, and build output from being committed.

## The Concept

A `.gitignore` file tells Git which untracked files and directories it should ignore.

Think of it as a “do not pack” list for files that do not belong in source control.

Common examples include:

- `.env` files that contain API keys or database passwords.
- `node_modules/`, which contains installed dependency copies.
- Test coverage and build output generated by tools.
- Log files.
- Editor-specific settings.
- Operating-system metadata files.

A `.gitignore` does **not** protect files that Git is already tracking.

If a secret was committed before you add it to `.gitignore`, Git continues tracking it. You must remove it from Git’s index and rotate the exposed secret.

This step matters before your first push because a public repository can expose mistakenly committed secrets immediately.

## The Implementation

Create the file below in the project root.

### `release-notes-manager/.gitignore`

```gitignore
# Environment files often contain passwords, API tokens, and service credentials.
.env
.env.*
!.env.example

# Node.js dependencies are installed locally and can be restored from package metadata.
node_modules/

# Generated build output and test coverage should be recreated by tools, not committed.
dist/
build/
coverage/
.nyc_output/

# Log files can contain noisy local diagnostics or sensitive request details.
*.log
logs/

# Operating-system metadata files.
.DS_Store
Thumbs.db
Desktop.ini

# Editor and IDE workspace settings that are specific to an individual machine.
.vscode/
.idea/
*.suo
*.user
*.userossc
*.sln.docstates

# Temporary and backup files created by editors or operating systems.
*.tmp
*.temp
*.swp
*.swo
*~
```

Stage the file:

```bash
git add .gitignore
```

Review the staged contents:

```bash
git diff --staged -- .gitignore
```

Commit it:

```bash
git commit -m "Add repository ignore rules"
```

## The Verification

Confirm the file is tracked:

```bash
git ls-files .gitignore
```

Expected output:

```text
.gitignore
```

Confirm the commit exists:

```bash
git log --oneline -1
```

Expected output resembles:

```text
<hash> Add repository ignore rules
```

Now test an ignored environment file without placing real credentials in it.

### macOS, Linux, or Git Bash

```bash
printf 'DEMO_API_KEY=not-a-real-secret\n' > .env
```

### Windows PowerShell

```powershell
'DEMO_API_KEY=not-a-real-secret' | Set-Content -Path .env
```

Check status:

```bash
git status --short
```

`.env` should not appear.

Ask Git why it ignores the file:

```bash
git check-ignore -v .env
```

Expected output resembles:

```text
.gitignore:2:.env    .env
```

Delete the demonstration file:

### macOS, Linux, or Git Bash

```bash
rm .env
```

### Windows PowerShell

```powershell
Remove-Item .env
```

---

# Step 6: Publish `main` to GitHub with `git push -u`

## The Target

Push the local `main` branch to GitHub and establish an upstream tracking relationship.

## The Concept

The command:

```bash
git push -u origin main
```

has three important pieces:

```text
git push    Upload commits and branch updates.
-u          Set the upstream branch relationship.
origin      The remote name.
main        The local branch to publish.
```

The `-u` option is short for `--set-upstream`.

It connects your local `main` branch to `origin/main`.

Afterward, Git understands that these branches correspond:

```text
Local branch:            main
Upstream remote branch:  origin/main
```

That means future commands can often be shorter:

```bash
git push
```

instead of:

```bash
git push origin main
```

And:

```bash
git pull
```

instead of:

```bash
git pull origin main
```

The first push uploads all commits reachable from `main`, including the entire history you built in Parts 1 and 2.

## The Implementation

Confirm you are on `main` and your work is clean:

```bash
git status
git branch --show-current
```

Push to GitHub:

```bash
git push -u origin main
```

If using HTTPS, Git may prompt for:

```text
Username:
Password:
```

Enter:

- Your GitHub username.
- Your GitHub Personal Access Token when asked for the password.

If using SSH and you configured a passphrase, your SSH agent may prompt for it.

## The Verification

A successful push resembles:

```text
Enumerating objects: ...
Counting objects: 100% ...
Writing objects: 100% ...
To github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

Run:

```bash
git status
```

Expected output resembles:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Inspect all local and remote-tracking branches:

```bash
git branch --all
```

Expected output:

```text
* main
  remotes/origin/main
```

Open your GitHub repository page in a browser and refresh it. You should see:

- `README.md`
- `RELEASE_NOTES.md`
- `RELEASE_CHECKLIST.md`
- `GLOSSARY.md`
- `.gitignore`
- Your complete commit history

---

# Step 7: Inspect the Remote Tracking Relationship

## The Target

Use Git commands to inspect what `origin`, `main`, and `origin/main` mean in your repository.

## The Concept

After the push, your branch structure looks conceptually like this:

```text
Your local repository

main ────────────────┐
                     │
origin/main ─────────┘
                     ▼
                 latest commit

GitHub repository

main ────────────────► latest commit
```

After other people push changes to GitHub, `origin/main` does not automatically move. Your local Git repository needs to contact GitHub using `git fetch` or `git pull` to learn about those changes.

Useful commands include:

```bash
git remote show origin
```

Displays remote configuration, tracked branches, and synchronization information.

```bash
git branch -vv
```

Displays local branches with their upstream branch and last commit.

```bash
git ls-remote origin
```

Asks the remote directly which refs it currently has.

## The Implementation

Run:

```bash
git remote show origin
```

Run:

```bash
git branch -vv
```

Run:

```bash
git ls-remote --heads origin
```

## The Verification

`git branch -vv` should resemble:

```text
* main <hash> [origin/main] Add repository ignore rules
```

The `[origin/main]` portion confirms the upstream relationship.

`git ls-remote --heads origin` should show a line similar to:

```text
<full-commit-hash>    refs/heads/main
```

---

# Step 8: Make a GitHub Web Edit to Simulate a Teammate Change

## The Target

Create a commit directly on GitHub so you can observe the difference between the remote repository and your local repository.

## The Concept

In real teams, other people can push commits while you are working.

To simulate that situation, you will create a small edit in GitHub’s web interface.

After the GitHub edit, the state will look like this:

```text
Your computer                              GitHub
─────────────                              ──────
main → A                                   main → B
origin/main → A

A = your latest known commit
B = new GitHub web commit
```

Your local repository does not automatically know about commit `B`.

You will use `git fetch` in the next step to update `origin/main` without changing your working files.

## The Implementation

In your GitHub repository page:

1. Open `GLOSSARY.md`.
2. Select the pencil icon labeled **Edit this file**.
3. Add the following section to the end of the file:

   ```md
   ## Remote

   A named connection from a local Git repository to another repository, commonly hosted on GitHub.
   ```

4. In the **Commit changes** area, use this commit message:

   ```text
   Define remote repositories
   ```

5. Select **Commit changes**.

GitHub may offer to commit directly to `main` or create a branch and pull request. For this controlled exercise, commit directly to `main`.

## The Verification

On GitHub, confirm the `GLOSSARY.md` file contains the new **Remote** definition.

Back in your terminal, do **not** fetch yet. Run:

```bash
git status
git log --oneline --decorate --graph --all
```

Your local repository may still report:

```text
Your branch is up to date with 'origin/main'.
```

This does not mean GitHub has no newer commit. It means your local remote-tracking information has not been refreshed yet.

---

# Step 9: Fetch Remote Changes Without Changing Your Working Files

## The Target

Use `git fetch` to download remote information and inspect the remote change before integrating it.

## The Concept

The command:

```bash
git fetch origin
```

contacts the remote named `origin` and downloads new commits, branches, and tags.

Crucially, `git fetch` does **not** merge those changes into your local branch and does **not** modify your working directory.

It updates remote-tracking references:

```text
Before fetch:
main         → A
origin/main  → A
GitHub main  → B

After fetch:
main         → A
origin/main  → B
GitHub main  → B
```

This makes fetch a safe “look before you combine” operation.

After fetching, you can inspect incoming changes before deciding whether to merge or rebase them.

## The Implementation

Fetch from GitHub:

```bash
git fetch origin
```

Inspect the graph:

```bash
git log --oneline --decorate --graph --all
```

Compare your local `main` with the updated `origin/main`:

```bash
git log --oneline main..origin/main
```

The notation:

```text
main..origin/main
```

means:

> “Show commits reachable from `origin/main` that are not reachable from local `main`.”

Inspect the exact incoming file change:

```bash
git diff main..origin/main -- GLOSSARY.md
```

## The Verification

After the fetch, `git status` should resemble:

```text
On branch main
Your branch is behind 'origin/main' by 1 commit, and can be fast-forwarded.
  (use "git pull" to update your local branch)

nothing to commit, working tree clean
```

Your graph should resemble:

```text
* <new-hash> (origin/main) Define remote repositories
* <previous-hash> (HEAD -> main) Add repository ignore rules
...
```

Notice:

- `origin/main` has moved forward.
- Your local `main` has not moved.
- Your working directory remains unchanged.

---

# Step 10: Integrate the Fetched Change with `git pull`

## The Target

Update local `main` by pulling the remote change from `origin/main`.

## The Concept

In its simplest form:

```bash
git pull
```

performs two operations:

```text
git fetch
then
git merge
```

Because you have already fetched and your local branch is directly behind `origin/main`, this pull will perform a fast-forward update.

You can think of `git pull` as “download and integrate.”

Git also supports a rebase-based pull:

```bash
git pull --rebase
```

That performs:

```text
git fetch
then
git rebase
```

For now, use the standard pull. In Part 4, you will apply team workflow rules that determine whether a project favors merge commits, squash merges, or rebased history.

## The Implementation

Confirm you have no local uncommitted work:

```bash
git status
```

Pull the remote change:

```bash
git pull
```

Inspect the updated file:

```bash
git show HEAD:GLOSSARY.md
```

## The Verification

Git should report a fast-forward operation similar to:

```text
Updating <old-hash>..<new-hash>
Fast-forward
 GLOSSARY.md | 4 ++++
 1 file changed, 4 insertions(+)
```

Run:

```bash
git status
```

Expected output:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Confirm the latest commit appears locally:

```bash
git log --oneline -3
```

One of the commits should be:

```text
Define remote repositories
```

---

# Step 11: Push a Local Commit to GitHub

## The Target

Make a local change, commit it, and publish it using the shorter `git push` command.

## The Concept

Because Step 6 set `origin/main` as the upstream branch for local `main`, Git now knows the default destination for `git push`.

You will add a section to the README documenting the project’s remote workflow.

The normal workflow is:

```text
Edit files
   ↓
git status
   ↓
git diff
   ↓
git add
   ↓
git diff --staged
   ↓
git commit
   ↓
git push
```

## The Implementation

Append this section to `README.md`:

```md
## Remote Workflow

The `main` branch is published to GitHub. Use `git fetch` to inspect remote changes without modifying local files, and use `git pull` only after confirming it is safe to integrate those changes.
```

The complete `README.md` should now be:

### `release-notes-manager/README.md`

```md
# Release Notes Manager

Release Notes Manager is a small project for organizing and publishing clear software release notes.

## Purpose

This repository is used to learn professional Git and GitHub workflows from local development through automated quality checks.

## Initial Release Note Format

Each release note should include:

1. A version number.
2. A release date.
3. A summary of important changes.
4. A list of fixes, features, and known limitations.

## Status

The project is in its active development, documentation, and planning phase.

## Contribution Guidelines

Keep each change focused on one purpose. Before committing, review the Git diff to confirm that only intended changes are included.

## Local Development

Use Git status frequently to understand whether changes are untracked, unstaged, staged, or committed.

## Remote Workflow

The `main` branch is published to GitHub. Use `git fetch` to inspect remote changes without modifying local files, and use `git pull` only after confirming it is safe to integrate those changes.
```

Review and commit the change:

```bash
git status
git diff -- README.md
git add README.md
git diff --staged -- README.md
git commit -m "Document remote workflow"
```

Push it:

```bash
git push
```

## The Verification

A successful push resembles:

```text
To github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
   <old-hash>..<new-hash>  main -> main
```

Run:

```bash
git status
```

Expected output:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Refresh the GitHub repository page. Confirm that:

- `README.md` includes the **Remote Workflow** section.
- The latest commit is `Document remote workflow`.

---

# Step 12: Clone the Repository into a Second Folder

## The Target

Create a second local copy of the GitHub repository with `git clone`.

## The Concept

`git clone` downloads a repository and sets it up for work in one command.

A clone includes:

- The working files.
- The complete commit history.
- The `origin` remote configuration.
- Remote-tracking branch references.

A clone is appropriate when you need a local working copy of a repository you already have access to.

For example:

```bash
git clone git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git
```

creates:

```text
release-notes-manager/
├── .git/
├── README.md
├── RELEASE_NOTES.md
└── ...
```

You already have one copy. To avoid confusion, clone into a different parent directory and give the second copy a clear name.

This second clone will simulate another computer or teammate workspace.

## The Implementation

Move to the parent folder that contains your original project.

### macOS, Linux, or Git Bash

```bash
cd ~/projects
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects"
```

Clone into a directory named `release-notes-manager-clone`.

### SSH

```bash
git clone git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git release-notes-manager-clone
```

### HTTPS

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/release-notes-manager.git release-notes-manager-clone
```

Move into the clone:

```bash
cd release-notes-manager-clone
```

Inspect its state:

```bash
git status
git remote -v
git branch --all
```

## The Verification

Expected status:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Expected remote output resembles:

```text
origin  git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git (fetch)
origin  git@github.com:YOUR_GITHUB_USERNAME/release-notes-manager.git (push)
```

Expected branch output resembles:

```text
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/main
```

You now have two independent local working directories:

```text
~/projects/
├── release-notes-manager/        # Original local repository
└── release-notes-manager-clone/  # New clone of the GitHub repository
```

Do not make the same change in both folders unless you deliberately want to practice a conflict.

---

# Step 13: Simulate Collaboration Between Two Clones

## The Target

Use the second clone to create and push a change, then fetch and pull it in the original repository.

## The Concept

This exercise simulates a teammate pushing work to GitHub.

The second clone represents a different working environment. You will make a small documentation addition there, push it, then return to the original repository to fetch and integrate it.

This reinforces the safe remote workflow:

```text
Someone else pushes
   ↓
git fetch
   ↓
Inspect incoming commits and diffs
   ↓
git pull
```

## The Implementation

You should currently be inside:

```text
release-notes-manager-clone/
```

Append this term to `GLOSSARY.md`:

```md
## Upstream Branch

The remote branch that a local branch uses as its default destination for push operations and default source for pull operations.
```

The complete `GLOSSARY.md` in the clone should be:

### `release-notes-manager-clone/GLOSSARY.md`

```md
# Project Glossary

## Branch

A named line of development that points to a specific commit.

## Commit

A recorded snapshot of staged project changes.

## Merge

The process of combining changes from one branch into another branch.

## Repository

A project directory that Git tracks, including its history and configuration.

## Staging Area

The intermediate area where selected changes are prepared before creating a commit.

## Remote

A named connection from a local Git repository to another repository, commonly hosted on GitHub.

## Upstream Branch

The remote branch that a local branch uses as its default destination for push operations and default source for pull operations.
```

Commit and push from the clone:

```bash
git add GLOSSARY.md
git commit -m "Define upstream branches"
git push
```

Now return to the original repository.

### macOS, Linux, or Git Bash

```bash
cd ~/projects/release-notes-manager
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects\release-notes-manager"
```

Fetch and inspect the incoming commit:

```bash
git fetch origin
git log --oneline main..origin/main
git diff main..origin/main -- GLOSSARY.md
```

Integrate it:

```bash
git pull
```

## The Verification

In the original repository, run:

```bash
git status
git log --oneline -3
```

Expected status:

```text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

Confirm the new glossary entry exists:

```bash
git show HEAD:GLOSSARY.md
```

You should see:

```md
## Upstream Branch

The remote branch that a local branch uses as its default destination for push operations and default source for pull operations.
```

---

# Step 14: Understand Cloning Versus Forking

## The Target

Understand when to clone a repository and when to fork one.

## The Concept

Cloning and forking are related but fundamentally different.

### Cloning

A **clone** is a local copy of a repository.

```text
GitHub repository
       │
       │ git clone
       ▼
Your computer
```

Use a clone when:

- You own the repository.
- You are a collaborator with write access.
- You need a working copy on a new computer.
- You are joining an existing team repository.

### Forking

A **fork** is a GitHub-hosted copy of someone else’s repository under your own GitHub account.

```text
Original repository (upstream)
       │
       │ GitHub fork
       ▼
Your GitHub repository (origin)
       │
       │ git clone
       ▼
Your computer
```

Use a fork when:

- You want to contribute to a repository where you do not have write access.
- You want to experiment independently with someone else’s project.
- You want your own hosted copy before proposing changes upstream.

The standard naming convention for a fork workflow is:

```text
origin    → your fork on GitHub
upstream  → the original project on GitHub
```

For example:

```bash
git remote -v
```

might show:

```text
origin    git@github.com:YOUR_GITHUB_USERNAME/original-project.git (fetch)
origin    git@github.com:YOUR_GITHUB_USERNAME/original-project.git (push)
upstream  git@github.com:ORIGINAL_OWNER/original-project.git (fetch)
upstream  git@github.com:ORIGINAL_OWNER/original-project.git (push)
```

Usually, you push to `origin` and fetch updates from `upstream`.

## The Implementation

No change is needed in your `release-notes-manager` repository because you own this repository.

For reference, the fork workflow is:

1. Open the original open-source repository on GitHub.
2. Select **Fork**.
3. Choose your account as the fork owner.
4. Clone your fork:

   ```bash
   git clone git@github.com:YOUR_GITHUB_USERNAME/original-project.git
   ```

5. Enter the cloned directory:

   ```bash
   cd original-project
   ```

6. Add the original repository as `upstream`:

   ```bash
   git remote add upstream git@github.com:ORIGINAL_OWNER/original-project.git
   ```

7. Confirm both remotes:

   ```bash
   git remote -v
   ```

8. Fetch original-project updates:

   ```bash
   git fetch upstream
   ```

9. Update your local main branch safely:

   ```bash
   git switch main
   git merge upstream/main
   ```

10. Push the synchronized branch to your fork:

   ```bash
   git push origin main
   ```

## The Verification

For your current owned repository, run:

```bash
git remote -v
```

You should see only `origin`.

Confirm you can explain the difference:

- **Clone:** a local copy of a repository.
- **Fork:** a GitHub-hosted copy of another GitHub repository under your account.

---

# Step 15: Verify `.gitignore` Rules for Common Generated Files

## The Target

Test `.gitignore` against environment files, Node.js dependencies, logs, and editor settings.

## The Concept

Ignore rules are only useful if they work as expected.

You will create harmless sample files and directories that match your ignore patterns. Git should not list them as untracked files.

This test proves that common local clutter and secret-bearing environment files stay out of commits.

Do not use real secrets in these test files.

## The Implementation

Ensure you are in the original repository:

### macOS, Linux, or Git Bash

```bash
cd ~/projects/release-notes-manager
```

### Windows PowerShell

```powershell
Set-Location "$HOME\projects\release-notes-manager"
```

Create sample ignored items.

### macOS, Linux, or Git Bash

```bash
mkdir -p node_modules/example-package
mkdir -p coverage
mkdir -p .vscode
printf 'temporary dependency content\n' > node_modules/example-package/index.js
printf 'temporary coverage content\n' > coverage/lcov.info
printf 'temporary log content\n' > application.log
printf 'DEMO_API_KEY=not-a-real-secret\n' > .env
printf '{"editor.formatOnSave": true}\n' > .vscode/settings.json
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Force -Path "node_modules\example-package"
New-Item -ItemType Directory -Force -Path "coverage"
New-Item -ItemType Directory -Force -Path ".vscode"
'temporary dependency content' | Set-Content -Path "node_modules\example-package\index.js"
'temporary coverage content' | Set-Content -Path "coverage\lcov.info"
'temporary log content' | Set-Content -Path "application.log"
'DEMO_API_KEY=not-a-real-secret' | Set-Content -Path ".env"
'{"editor.formatOnSave": true}' | Set-Content -Path ".vscode\settings.json"
```

Check status:

```bash
git status --short
```

Ask Git to explain each ignored file:

```bash
git check-ignore -v .env
git check-ignore -v application.log
git check-ignore -v node_modules/example-package/index.js
git check-ignore -v coverage/lcov.info
git check-ignore -v .vscode/settings.json
```

Clean up the sample files afterward.

### macOS, Linux, or Git Bash

```bash
rm -rf node_modules coverage .vscode .env application.log
```

### Windows PowerShell

```powershell
Remove-Item -Recurse -Force node_modules, coverage, .vscode
Remove-Item -Force .env, application.log
```

## The Verification

`git status --short` should produce no output while the sample files exist.

Each `git check-ignore -v` command should display the matching rule and the ignored path.

For example:

```text
.gitignore:2:.env    .env
```

After cleanup, confirm the repository is clean:

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

# Step 16: Learn What to Do If a Secret Was Already Committed

## The Target

Understand the immediate containment steps when a secret is accidentally committed.

## The Concept

A `.gitignore` file prevents future untracked files from being added. It cannot erase a secret that was already committed or pushed.

If you accidentally commit a real API key, password, private key, or access token:

1. **Revoke or rotate the secret immediately.**  
   This is the most important action. Assume the secret is compromised.

2. Remove the secret from the current version of the repository.

3. Add an appropriate `.gitignore` rule.

4. Remove the file from Git tracking while keeping a local copy if needed.

5. Commit and push the removal.

For example, if `.env` was already tracked:

```bash
git rm --cached .env
git add .gitignore
git commit -m "Stop tracking environment configuration"
git push
```

`--cached` means “remove from Git’s tracking index, but leave the local file on disk.”

However, the old secret may still exist in Git history and, if pushed, may have been copied elsewhere. Rotating the credential is mandatory.

Cleaning secrets from history requires specialized tools and coordination, especially for shared repositories. Common tools include:

- `git filter-repo`
- GitHub’s sensitive-data-removal guidance
- Organization security procedures

## The Implementation

Do not run secret-removal commands in this tutorial because your repository does not contain a real committed secret.

Instead, verify that your `.gitignore` includes environment-file rules:

```bash
git show HEAD:.gitignore
```

## The Verification

Confirm that the output includes:

```gitignore
.env
.env.*
!.env.example
```

You should now understand this safety rule:

> If a real secret reaches a commit, rotate or revoke it first; removing the file later is not enough.

---

# Part 3 Reference: Remote and GitHub Commands

## Remote Configuration

```bash
git remote
```

Lists configured remotes.

```bash
git remote -v
```

Lists configured remotes with fetch and push URLs.

```bash
git remote add origin <repository-url>
```

Adds a remote named `origin`.

```bash
git remote set-url origin <repository-url>
```

Changes an existing remote’s URL.

```bash
git remote show origin
```

Displays detailed information about the `origin` remote.

```bash
git ls-remote --heads origin
```

Lists branch references available directly on `origin`.

---

## Publishing and Synchronizing

```bash
git push -u origin main
```

Pushes local `main` to `origin` and establishes `origin/main` as its upstream branch.

```bash
git push
```

Pushes the current branch to its configured upstream branch.

```bash
git fetch origin
```

Downloads remote commits and updates remote-tracking branches without changing local branches or working files.

```bash
git pull
```

Fetches and integrates the upstream branch into the current local branch.

```bash
git pull --rebase
```

Fetches and rebases local unpushed commits onto the updated upstream branch.

Use it only when your team’s workflow supports rebasing.

---

## Inspecting Synchronization

```bash
git branch --all
```

Lists local branches and remote-tracking branches.

```bash
git branch -vv
```

Lists local branches, their upstreams, and their latest commits.

```bash
git log --oneline main..origin/main
```

Shows commits on `origin/main` that local `main` does not have.

```bash
git log --oneline origin/main..main
```

Shows local commits that `origin/main` does not have.

```bash
git diff main..origin/main
```

Shows file differences between local `main` and remote-tracking `origin/main`.

---

## Cloning and Forking

```bash
git clone <repository-url>
```

Creates a local copy of a repository.

```bash
git clone <repository-url> <folder-name>
```

Creates a clone in a specifically named folder.

```bash
git remote add upstream <original-repository-url>
```

Adds the original project as `upstream` in a fork-based workflow.

```bash
git fetch upstream
```

Downloads updates from the original project.

---

## Ignore Rules

```bash
git check-ignore -v <file-path>
```

Shows whether Git ignores a file and identifies the exact ignore rule responsible.

```bash
git ls-files
```

Lists files Git is already tracking.

```bash
git rm --cached <file-path>
```

Stops tracking a file while leaving the file in the working directory.

Use this only when a file was incorrectly committed before an ignore rule was added.

---

# Part 3 Completion Checklist

Before continuing to collaboration workflows, confirm all of the following:

- [ ] You understand the difference between local branches, remote branches, and remote-tracking branches.
- [ ] You configured SSH authentication or understand HTTPS authentication using a Personal Access Token.
- [ ] You created an empty GitHub repository.
- [ ] You added GitHub as `origin`.
- [ ] You pushed `main` with `git push -u origin main`.
- [ ] Your local `main` tracks `origin/main`.
- [ ] You used `git fetch` to inspect a remote change without modifying local files.
- [ ] You used `git pull` to integrate a remote change.
- [ ] You cloned the repository into a second folder.
- [ ] You understand the difference between cloning and forking.
- [ ] You added and tested a robust `.gitignore`.
- [ ] You understand that `.gitignore` does not remove already tracked secrets.
- [ ] `git status` reports a clean working tree and says `main` is up to date with `origin/main`.
