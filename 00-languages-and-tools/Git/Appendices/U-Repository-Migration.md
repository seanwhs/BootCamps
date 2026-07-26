# Appendix U: Repository Migration, Default-Branch Renaming, and History Preservation

Repositories change over time.

Common changes include:

- Moving a repository to a different GitHub organization.
- Renaming a repository.
- Renaming the default branch from `master` to `main`.
- Importing an existing project into Git.
- Combining repositories.
- Moving a project directory while preserving its Git history.
- Archiving a retired project safely.

These operations affect more than files. They affect:

- Remote URLs.
- Branch protections.
- GitHub Actions secrets and environments.
- Badges and documentation links.
- Local clones.
- Forks.
- Deployments and integrations.

This appendix provides a cautious migration approach:

```text
Plan
  ↓
Back up
  ↓
Perform one controlled change
  ↓
Verify Git history and GitHub settings
  ↓
Communicate the new workflow
```

> **Safety rule:** Do not begin a repository migration with uncommitted work or without a backup plan.

---

# U.1 Build a Migration Inventory

## The Target

Identify every repository setting, integration, and user workflow affected by a migration.

## The Concept

Moving a repository is like moving an office. The desks may arrive at the new address, but the phone numbers, door keys, mailing address, security system, and delivery instructions must also be updated.

Before changing anything, write down what currently depends on the repository.

## The Implementation

Create a migration checklist file before performing a real migration.

### `repository-migration-checklist.md`

```md
# Repository Migration Checklist

## Repository Identity

- [ ] Current GitHub owner or organization:
- [ ] Current repository name:
- [ ] New GitHub owner or organization:
- [ ] New repository name:
- [ ] Current default branch:
- [ ] Intended default branch:

## Git and GitHub Settings

- [ ] Branch protection rules or rulesets.
- [ ] Required status checks.
- [ ] GitHub Actions workflows.
- [ ] Repository and environment secrets.
- [ ] GitHub Environments.
- [ ] Deploy keys.
- [ ] GitHub Apps and webhooks.
- [ ] CODEOWNERS.
- [ ] Collaborators and organization teams.
- [ ] Issue labels, milestones, and Projects.
- [ ] Releases and tags.

## External References

- [ ] README links.
- [ ] Documentation links.
- [ ] GitHub Actions badges.
- [ ] Package metadata repository URL.
- [ ] Deployment configuration.
- [ ] CI badges.
- [ ] Issue templates.
- [ ] Security advisory links.
- [ ] External dashboards and webhooks.
- [ ] Local clone instructions.

## Communication

- [ ] Notify contributors before migration.
- [ ] Publish new clone URL.
- [ ] Explain default-branch changes.
- [ ] Explain whether old URLs redirect.
- [ ] Document required local Git commands.
```

Do not commit this file to the project unless the migration is part of the project’s permanent documentation. For one-time migration planning, keep it in a secure project-management location.

## The Verification

Before continuing, confirm that you can answer:

```text
[ ] Which GitHub URL will change?
[ ] Which branch will become the default?
[ ] Which people need access after the migration?
[ ] Which CI, deployment, or webhook integrations depend on the repository?
[ ] Which documentation pages contain the old URL?
```

---

# U.2 Create a Local Backup Before a Migration

## The Target

Create a local mirror backup that preserves all branches, tags, and reachable Git objects.

## The Concept

A normal clone typically checks out the default branch and configures remote tracking.

A **mirror clone** copies all refs, including:

- Local branches.
- Remote branches.
- Tags.
- Notes.
- Other repository references.

Think of it as packing the entire archive before moving a library.

## The Implementation

Move to a safe backup location.

### macOS, Linux, or Git Bash

```bash
mkdir -p ~/repository-backups
cd ~/repository-backups
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path "$HOME\repository-backups" -Force
Set-Location "$HOME\repository-backups"
```

Create a mirror clone. Replace the URL with the current repository URL:

```bash
git clone --mirror git@github.com:CURRENT_OWNER/release-notes-manager.git
```

This creates a bare repository folder:

```text
release-notes-manager.git/
```

Inspect refs in the backup:

```bash
cd release-notes-manager.git
git show-ref
```

Create an archive of the backup if your migration policy requires an offline copy.

### macOS or Linux

```bash
cd ..
tar -czf release-notes-manager-mirror-backup.tar.gz release-notes-manager.git
```

### Windows PowerShell

```powershell
Set-Location ..
Compress-Archive -Path release-notes-manager.git -DestinationPath release-notes-manager-mirror-backup.zip
```

## The Verification

Confirm that the mirror includes branches and tags:

```bash
cd release-notes-manager.git
git show-ref --heads
git show-ref --tags
```

The output should list references such as:

```text
<hash> refs/heads/main
<hash> refs/tags/v1.0.0
```

Do not store backup archives containing confidential repository history in public cloud folders or public repositories.

---

# U.3 Rename the Default Branch from `master` to `main`

## The Target

Rename an older default branch safely while preserving history.

## The Concept

Many repositories historically used:

```text
master
```

Modern repositories commonly use:

```text
main
```

Renaming a branch does not rewrite commit history. It changes the branch reference name.

Before:

```text
master → Commit A
```

After:

```text
main → Commit A
```

The commit is unchanged. Only the label changes.

However, GitHub configuration and local clones may still refer to the old branch name.

## The Implementation

If your repository already uses `main`, do not perform this migration.

For a repository currently using `master`, first ensure it is clean:

```bash
git switch master
git pull --ff-only
git status
```

Rename the local branch:

```bash
git branch -m master main
```

Push the new branch and establish upstream tracking:

```bash
git push -u origin main
```

On GitHub:

1. Open repository **Settings**.
2. Open **Branches** or **General**, depending on the interface.
3. Change the default branch from:

   ```text
   master
   ```

   to:

   ```text
   main
   ```

4. Update branch protection or rulesets to target `main`.
5. Verify GitHub Actions workflow triggers reference `main`.
6. Update badges, documentation, and deployment settings.

After confirming the new default branch works, delete the old remote branch:

```bash
git push origin --delete master
```

## The Verification

Confirm the active local branch:

```bash
git branch --show-current
```

Expected output:

```text
main
```

Confirm tracking:

```bash
git branch -vv
```

Expected output resembles:

```text
* main <hash> [origin/main] Latest commit message
```

Confirm GitHub’s default branch is `main` through the repository page and settings.

---

# U.4 Update Existing Local Clones After a Branch Rename

## The Target

Update a contributor’s local repository after the remote default branch changed.

## The Concept

After a remote branch rename, existing clones may still have:

```text
master
origin/master
```

GitHub may redirect some links, but local Git references need deliberate updates.

## The Implementation

From an existing clone:

```bash
git fetch origin --prune
```

Rename the local branch if needed:

```bash
git branch -m master main
```

Set the correct upstream:

```bash
git branch -u origin/main main
```

Update the symbolic remote HEAD:

```bash
git remote set-head origin -a
```

Delete the stale remote-tracking reference if it remains:

```bash
git remote prune origin
```

Confirm state:

```bash
git branch --all
git branch -vv
```

## The Verification

Expected branch listing:

```text
* main
  remotes/origin/HEAD -> origin/main
  remotes/origin/main
```

No stale `origin/master` reference should remain.

---

# U.5 Rename a GitHub Repository

## The Target

Rename a repository and update local remote URLs.

## The Concept

GitHub generally redirects old repository URLs after a rename, but you should not depend on redirects forever.

A repository rename can affect:

- Clone URLs.
- Documentation links.
- GitHub Actions badges.
- Package metadata.
- Submodule URLs.
- Webhooks.
- External deployment integrations.

## The Implementation

On GitHub:

1. Open the repository.
2. Select **Settings**.
3. Select **General**.
4. Under **Repository name**, enter the new name.
5. Confirm the rename.

For example:

```text
release-notes-manager
```

becomes:

```text
release-notes-toolkit
```

Update the local remote URL:

### SSH

```bash
git remote set-url origin git@github.com:YOUR_GITHUB_USERNAME/release-notes-toolkit.git
```

### HTTPS

```bash
git remote set-url origin https://github.com/YOUR_GITHUB_USERNAME/release-notes-toolkit.git
```

Inspect the updated remote:

```bash
git remote -v
```

Search project files for old repository references.

### macOS, Linux, or Git Bash

```bash
git grep -n "release-notes-manager"
```

### Windows PowerShell

```powershell
git grep -n "release-notes-manager"
```

Update references in files such as:

```text
README.md
CONTRIBUTING.md
SECURITY.md
.github/ISSUE_TEMPLATE/config.yml
package.json
```

## The Verification

Test remote access:

```bash
git fetch origin
git remote show origin
```

Expected output should identify the renamed repository.

Open the new GitHub URL in a browser and confirm repository history, issues, pull requests, releases, and tags still exist.

---

# U.6 Transfer a Repository to Another User or Organization

## The Target

Move repository ownership while preserving GitHub history and settings where supported.

## The Concept

A repository transfer changes ownership:

```text
Before:
your-personal-account/release-notes-manager

After:
your-organization/release-notes-manager
```

The Git history remains intact, but access settings, teams, billing, secrets, environments, and integrations require careful verification.

Repository transfer is not the same as cloning to a new repository and pushing code there. Transfer preserves more GitHub-level history, such as:

- Issues.
- Pull requests.
- Releases.
- Stars and watchers, where applicable.
- Commit history.
- Tags.

## The Implementation

Before transfer:

1. Create the mirror backup from Step U.2.
2. Record current collaborators, teams, rulesets, environments, secrets, and integrations.
3. Confirm the destination organization accepts repository transfers.
4. Confirm the destination organization has the required plan and policies.

On GitHub:

1. Open repository **Settings**.
2. Open **General**.
3. Scroll to **Danger Zone**.
4. Select **Transfer ownership**.
5. Enter the destination owner or organization.
6. Confirm the repository name and transfer instructions.
7. Complete the transfer.

After transfer, update local remotes:

```bash
git remote set-url origin git@github.com:NEW_OWNER/release-notes-manager.git
git fetch origin
```

## The Verification

Confirm the remote URL:

```bash
git remote -v
```

Confirm history remains available:

```bash
git log --oneline --decorate -10
git tag --list
```

On GitHub, verify:

```text
[ ] Issues remain available.
[ ] Pull requests remain available.
[ ] Releases and tags remain available.
[ ] Required teams have access.
[ ] Branch protections or rulesets are present.
[ ] GitHub Actions workflows still run.
[ ] Environments and environment protection rules are correct.
[ ] Deployment integrations and webhooks still work.
```

---

# U.7 Preserve History When Moving a Directory into a New Repository

## The Target

Extract a project subdirectory into a separate repository while preserving its relevant commit history.

## The Concept

Sometimes a monorepo contains a project that needs to become independent.

For example:

```text
platform/
├── apps/
├── docs/
└── packages/
    └── release-notes-manager/
```

You want:

```text
release-notes-manager/
```

as a standalone repository.

A simple copy preserves current files but loses history.

To preserve only the relevant folder history, use a history-rewriting tool such as:

```text
git filter-repo
```

This is an advanced operation. It creates rewritten commits and should be performed on a disposable clone or backup—not the active shared repository.

## The Implementation

Install `git-filter-repo` using its official documentation:

```text
https://github.com/newren/git-filter-repo
```

Create a mirror clone of the source repository:

```bash
git clone --mirror git@github.com:YOUR_ORGANIZATION/platform.git platform-release-notes-manager.git
cd platform-release-notes-manager.git
```

Filter history so only the desired folder remains:

```bash
git filter-repo --path packages/release-notes-manager/ --path-rename packages/release-notes-manager/:
```

This means:

```text
Keep:
packages/release-notes-manager/

Then rename it to:
repository root
```

Inspect the rewritten repository:

```bash
git log --oneline --all
git ls-tree -r HEAD
```

Create an empty destination repository on GitHub, then add it as a remote:

```bash
git remote add new-origin git@github.com:YOUR_ORGANIZATION/release-notes-manager.git
```

Push all rewritten branches and tags intentionally:

```bash
git push new-origin --all
git push new-origin --tags
```

## The Verification

Clone the new repository into a separate folder:

```bash
git clone git@github.com:YOUR_ORGANIZATION/release-notes-manager.git release-notes-manager-extracted
cd release-notes-manager-extracted
```

Verify the root contains the extracted project files:

```bash
git ls-files
```

Verify relevant old commits exist:

```bash
git log --oneline
```

Do not delete the source directory from the original monorepo until the new repository has been reviewed, tested, and adopted.

---

# U.8 Combine Two Repositories Carefully

## The Target

Understand options for combining repositories while preserving history.

## The Concept

Combining repositories is the reverse of extracting one.

Suppose you have:

```text
release-notes-manager/
release-note-theme/
```

and want:

```text
release-platform/
├── app/
└── theme/
```

There are several approaches:

| Approach | Preserves history? | Complexity |
|---|---:|---:|
| Copy current files | No | Low |
| Git subtree | Yes | Medium |
| `git filter-repo` + merge | Yes | High |
| Git submodule | Keeps repositories separate | Medium |

For tightly integrated projects, a monorepo may be appropriate. For independently versioned projects, submodules or packages may be better.

## The Implementation

A safe history-preserving approach uses `git filter-repo` in a disposable clone.

For the repository that will become the `theme/` folder:

```bash
git clone --mirror git@github.com:YOUR_ORGANIZATION/release-note-theme.git release-note-theme-rewrite.git
cd release-note-theme-rewrite.git
git filter-repo --path-rename :theme/
```

For the repository that will become the `app/` folder:

```bash
git clone --mirror git@github.com:YOUR_ORGANIZATION/release-notes-manager.git release-notes-manager-rewrite.git
cd release-notes-manager-rewrite.git
git filter-repo --path-rename :app/
```

Then create a new destination repository and merge the rewritten histories using a controlled migration plan.

Because this process is highly dependent on existing branches and release tags, perform it only after creating backups and testing in a non-production environment.

## The Verification

Before publishing a combined repository, confirm:

```text
[ ] Each project appears in its intended folder.
[ ] Important branch and tag history is preserved or intentionally documented.
[ ] Build scripts use the new paths.
[ ] CI workflows use the new paths.
[ ] Documentation references the new structure.
[ ] Tests pass from a clean clone.
```

---

# U.9 Archive a Retired Repository Safely

## The Target

Retire a repository without deleting useful history or confusing contributors.

## The Concept

A repository that is no longer maintained should usually be **archived**, not deleted.

Archiving communicates:

```text
This repository is read-only.
No new issues, pull requests, or pushes should occur.
History remains available for reference.
```

Deletion is appropriate only when the repository contains data that must be removed or when organizational policy requires it.

## The Implementation

Before archiving:

1. Confirm a replacement repository or final release is documented.
2. Update `README.md` with an archival notice.
3. Add a link to the replacement project if one exists.
4. Create a final tag if appropriate.
5. Ensure secrets and credentials are revoked or removed.

Add a README notice such as:

```md
> **Archived:** This repository is no longer actively maintained.
> Development continues at [NEW_REPOSITORY_URL](NEW_REPOSITORY_URL).
```

Commit and merge the notice.

On GitHub:

1. Open repository **Settings**.
2. Open **General**.
3. Scroll to **Danger Zone**.
4. Select **Archive this repository**.
5. Confirm the archival action.

## The Verification

Confirm the repository page displays an archive notice.

Confirm contributors cannot open new pull requests or push changes.

Keep the local mirror backup according to your organization’s retention policy.

---

# U.10 Migration Communication Template

## The Target

Prepare a clear message for contributors after a repository move, rename, or default-branch change.

## The Concept

A technically correct migration still causes friction if contributors do not know what changed.

A good announcement answers:

```text
What changed?
When did it change?
What do contributors need to do?
What URLs or branches should they use now?
Where should they ask questions?
```

## The Implementation

Use this template.

```md
# Repository Migration Notice

The repository has moved.

## What Changed

- Previous location: `https://github.com/OLD_OWNER/OLD_REPOSITORY`
- New location: `https://github.com/NEW_OWNER/NEW_REPOSITORY`
- Previous default branch: `master`
- New default branch: `main`

## Required Local Update

From an existing clone:

```bash
git remote set-url origin git@github.com:NEW_OWNER/NEW_REPOSITORY.git
git fetch origin --prune
git branch -m master main
git branch -u origin/main main
git remote set-head origin -a
```

## New Clone Command

```bash
git clone git@github.com:NEW_OWNER/NEW_REPOSITORY.git
```

## Notes

- Existing commit history, tags, releases, issues, and pull requests remain available.
- Please update local bookmarks, CI integrations, and documentation links.
- Report migration problems through the project issue tracker or maintainer contact channel.
```

Replace the placeholders before publishing the announcement.

## The Verification

Test the commands in a disposable clone before sending them to all contributors.

A migration announcement should not contain commands you have not verified.

---

# U.11 Repository Migration Command Reference

## Create a Mirror Backup

```bash
git clone --mirror <repository-url>
```

## List All Refs in a Mirror

```bash
git show-ref
```

## Rename a Local Branch

```bash
git branch -m master main
```

## Push a Renamed Branch

```bash
git push -u origin main
```

## Delete an Old Remote Branch

```bash
git push origin --delete master
```

## Update a Remote URL

```bash
git remote set-url origin <new-url>
```

## Remove Stale Remote References

```bash
git fetch origin --prune
```

## Update Remote Default-Branch Reference

```bash
git remote set-head origin -a
```

## Extract a Subdirectory with History

```bash
git filter-repo --path path/to/project/ --path-rename path/to/project/:
```

## Inspect Repository References

```bash
git branch --all
git tag --list
git show-ref
```

---

# Appendix U Completion Check

You should now be able to:

- [ ] Build a migration inventory before changing repository identity or ownership.
- [ ] Create a mirror backup containing branches and tags.
- [ ] Rename a default branch from `master` to `main`.
- [ ] Update existing local clones after a branch rename.
- [ ] Rename a GitHub repository and update remotes and documentation.
- [ ] Transfer a repository to another owner or organization safely.
- [ ] Extract a project directory into a new repository while preserving relevant history.
- [ ] Understand options for combining repositories.
- [ ] Archive a retired repository instead of deleting useful history.
- [ ] Communicate migration steps clearly and test instructions before publishing them.
