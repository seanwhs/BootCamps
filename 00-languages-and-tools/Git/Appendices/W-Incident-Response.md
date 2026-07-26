# Appendix W: Incident Response, Rollbacks, and Emergency Recovery

Version control is not only for normal feature development. It is also one of the most important tools for responding to incidents.

An **incident** is an unexpected problem that affects users, security, availability, data, releases, or team operations.

Examples:

- A release introduces a production-breaking bug.
- A secret is accidentally pushed.
- A GitHub Actions workflow gains unsafe permissions.
- A bad dependency version is merged.
- A release tag points to the wrong commit.
- A protected branch is changed incorrectly.
- A deployment must be rolled back quickly.

The most important incident principle is:

> Restore safety first. Investigate deeply second. Improve the process third.

This appendix provides practical Git and GitHub recovery patterns. It does not replace your organization’s legal, security, compliance, or incident-management procedures.

---

# W.1 Understand the Incident Response Lifecycle

## The Target

Learn a simple, repeatable sequence for responding to repository and release incidents.

## The Concept

When something goes wrong, people often rush directly into editing files. That can make the problem harder to understand and recover from.

A safer response sequence is:

```text
Detect
  ↓
Contain
  ↓
Preserve evidence
  ↓
Restore service or safety
  ↓
Verify
  ↓
Communicate
  ↓
Learn and prevent recurrence
```

Think of a water leak:

```text
First: stop the water.
Second: protect important items.
Third: repair the pipe.
Fourth: determine why the leak happened.
```

For a software incident:

| Phase | Main question |
|---|---|
| Detect | What is failing or exposed? |
| Contain | How do we stop further damage? |
| Preserve | What evidence and state must be recorded? |
| Restore | What is the smallest safe path back to working behavior? |
| Verify | Did the fix actually solve the problem? |
| Communicate | Who needs to know what happened? |
| Prevent | Which test, review, alert, or policy should improve? |

---

# W.2 Create an Incident Record

## The Target

Create a GitHub Issue or private security advisory that records the incident without exposing sensitive details.

## The Concept

An incident record gives the team one place to coordinate.

For ordinary operational problems, use a GitHub Issue.

For security-sensitive problems, such as leaked credentials or vulnerabilities, use a private GitHub Security Advisory or your organization’s private incident system.

Do not place secrets, access tokens, private customer data, or exploit instructions in a public issue.

## The Implementation

For a non-security incident, create a GitHub Issue with this title format:

```text
[Incident] Short description of the problem
```

Example:

```text
[Incident] Release formatter generates incorrect heading
```

Use this issue body:

```md
## Incident Summary

Describe the observed problem in non-sensitive terms.

## Impact

- Who or what is affected?
- Is the impact ongoing?
- Which release, branch, environment, or commit is involved?

## Detection

- How was the problem discovered?
- When was it first observed?

## Immediate Containment

- [ ] Stop affected deployment or release process.
- [ ] Disable unsafe automation if needed.
- [ ] Preserve relevant logs and commit hashes.
- [ ] Notify maintainers.

## Recovery Plan

- [ ] Identify known-good commit or release tag.
- [ ] Create focused hotfix or rollback branch.
- [ ] Add or update regression tests.
- [ ] Run CI and review.
- [ ] Verify restored behavior.

## Follow-Up

- [ ] Create a root-cause analysis.
- [ ] Add preventive test, alert, documentation, or review rule.
- [ ] Review whether access, permissions, or release process should change.
```

For a security incident, use GitHub’s private advisory flow:

```text
Repository → Security → Advisories → New draft security advisory
```

## The Verification

Confirm the incident record includes:

```text
[ ] A clear summary.
[ ] Impact.
[ ] Detection time or context.
[ ] Containment actions.
[ ] Recovery plan.
[ ] Follow-up work.
```

Do not continue with a risky recovery operation until the team has recorded the relevant commit hashes and current branch state.

---

# W.3 Capture the Current Repository State

## The Target

Preserve the current state before changing history, reverting code, or changing release configuration.

## The Concept

During an incident, the current state may contain evidence needed later.

Before changing branches or rewriting anything, capture:

- Current branch.
- Current commit hash.
- Remote state.
- Recent history.
- Workflow status.
- Release tag references.

This is like photographing an accident scene before moving vehicles.

## The Implementation

From the repository root, run:

```bash
git status
git branch --show-current
git rev-parse HEAD
git log --oneline --decorate --graph --all -20
git remote -v
git tag --contains HEAD
```

Save the output to an incident file if your process allows it.

### macOS, Linux, or Git Bash

```bash
{
  echo "=== Git Status ==="
  git status
  echo
  echo "=== Current Branch ==="
  git branch --show-current
  echo
  echo "=== Current Commit ==="
  git rev-parse HEAD
  echo
  echo "=== Recent History ==="
  git log --oneline --decorate --graph --all -20
  echo
  echo "=== Remotes ==="
  git remote -v
  echo
  echo "=== Tags Containing HEAD ==="
  git tag --contains HEAD
} > incident-git-state.txt
```

### Windows PowerShell

```powershell
@(
  "=== Git Status ==="
  git status
  ""
  "=== Current Branch ==="
  git branch --show-current
  ""
  "=== Current Commit ==="
  git rev-parse HEAD
  ""
  "=== Recent History ==="
  git log --oneline --decorate --graph --all -20
  ""
  "=== Remotes ==="
  git remote -v
  ""
  "=== Tags Containing HEAD ==="
  git tag --contains HEAD
) | Set-Content -Path incident-git-state.txt
```

Do not commit `incident-git-state.txt` unless it contains no sensitive operational details and your project intentionally tracks incident records.

## The Verification

Inspect the saved state file:

### macOS, Linux, or Git Bash

```bash
cat incident-git-state.txt
```

### Windows PowerShell

```powershell
Get-Content incident-git-state.txt
```

Confirm that you know:

```text
[ ] Which commit is currently deployed or affected.
[ ] Which branch contains it.
[ ] Which tags point to known releases.
[ ] Whether local work exists.
[ ] Whether the local repository is synchronized with GitHub.
```

Remove the temporary file when it is no longer needed:

### macOS, Linux, or Git Bash

```bash
rm incident-git-state.txt
```

### Windows PowerShell

```powershell
Remove-Item incident-git-state.txt
```

---

# W.4 Roll Back a Bad Release by Reverting a Commit

## The Target

Create a safe rollback commit that undoes a bad change without rewriting shared history.

## The Concept

When a bad change has already reached `main`, the safest response is often:

```bash
git revert <bad-commit-hash>
```

`git revert` does not erase history.

Instead, it creates a new commit that applies the opposite change.

Before:

```text
A → B → C
        ↑
     bad change
```

After reverting `C`:

```text
A → B → C → R
            ↑
      revert commit
```

This is safer than `git reset --hard` followed by a force push because shared history remains intact.

Use revert when:

- The bad commit is already pushed.
- The bad commit is on a shared branch.
- You need a visible, auditable rollback.
- Other contributors may already have the bad commit.

## The Implementation

Start from updated `main`:

```bash
git switch main
git pull --ff-only
git status
```

Identify the bad commit:

```bash
git log --oneline --decorate -20
```

Create a rollback branch:

```bash
git switch -c revert/short-description
```

Revert the bad commit:

```bash
git revert BAD_COMMIT_HASH
```

Replace `BAD_COMMIT_HASH` with the real commit hash.

If Git opens an editor, keep or improve the default message:

```text
Revert "Original commit message"
```

Run tests:

```bash
npm test
```

Push the rollback branch:

```bash
git push -u origin revert/short-description
```

Open an emergency pull request into `main`.

## The Verification

Inspect the rollback:

```bash
git show --stat HEAD
git show HEAD
```

Confirm the latest commit message begins with:

```text
Revert
```

Confirm tests pass:

```bash
npm test
```

After merge, verify that `main` contains both:

```text
The original bad commit
The new revert commit
```

---

# W.5 Revert a Merge Commit

## The Target

Safely revert a pull request that was merged with a merge commit.

## The Concept

A merge commit has two parents.

When reverting a merge commit, Git needs to know which parent should be treated as the mainline.

For a pull request merged into `main`, the first parent is usually the previous `main` branch state.

The command is:

```bash
git revert -m 1 MERGE_COMMIT_HASH
```

The `-m 1` means:

> “Treat parent 1 as the mainline and undo the changes introduced by the other merged branch.”

Do not guess the mainline parent. Inspect the merge commit first.

## The Implementation

Inspect the merge commit:

```bash
git show --no-patch --format=raw MERGE_COMMIT_HASH
```

You should see two parent lines:

```text
parent <main-parent-hash>
parent <feature-parent-hash>
```

Create a rollback branch:

```bash
git switch main
git pull --ff-only
git switch -c revert/merged-feature
```

Revert the merge:

```bash
git revert -m 1 MERGE_COMMIT_HASH
```

Run tests:

```bash
npm test
```

Push the branch:

```bash
git push -u origin revert/merged-feature
```

## The Verification

Inspect the revert commit:

```bash
git show --stat HEAD
```

Confirm that files changed by the original pull request are restored to the intended pre-merge behavior.

Do not merge the rollback until CI and an appropriate reviewer confirm that reverting the full pull request is the correct response.

---

# W.6 Revert a Squash-Merged Pull Request

## The Target

Roll back a pull request merged using squash merge.

## The Concept

A squash merge creates one ordinary commit on `main`.

That makes rollback simpler because there is no multi-parent merge commit.

Use:

```bash
git revert SQUASH_COMMIT_HASH
```

This is one reason squash merging is operationally convenient for small focused pull requests.

## The Implementation

Find the squash merge commit:

```bash
git log --oneline --decorate -20
```

Create a rollback branch:

```bash
git switch main
git pull --ff-only
git switch -c revert/squashed-feature
```

Revert it:

```bash
git revert SQUASH_COMMIT_HASH
```

Run tests:

```bash
npm test
```

Push:

```bash
git push -u origin revert/squashed-feature
```

## The Verification

Confirm the revert is a single new commit:

```bash
git log --oneline -3
```

Expected shape:

```text
<revert-hash> Revert "Original squash commit title"
<bad-hash> Original squash commit title
<previous-hash> Earlier main commit
```

---

# W.7 Restore a Known-Good Release with a Hotfix Branch

## The Target

Use a known-good release tag as the starting point for an emergency hotfix.

## The Concept

Sometimes the current `main` branch contains several unrelated changes, but production must be stabilized from a known-good release.

For example:

```text
v1.0.0 → known good release
main   → contains later incomplete or problematic changes
```

Create a hotfix branch from the known-good tag:

```bash
git switch -c hotfix/critical-fix v1.0.0
```

Then apply only the necessary fix and release it as a patch version.

This is especially useful when a production release must be repaired without including unrelated future work.

## The Implementation

Fetch tags:

```bash
git fetch origin --tags
```

Inspect available tags:

```bash
git tag --list --sort=-version:refname
```

Create a hotfix branch from a known-good tag:

```bash
git switch -c hotfix/critical-release-fix v1.0.0
```

Confirm the starting commit:

```bash
git describe --tags --exact-match HEAD
```

Expected output:

```text
v1.0.0
```

Implement the smallest safe fix, then:

```bash
npm test
git add <intended-files>
git commit -m "fix: correct critical release behavior"
git push -u origin hotfix/critical-release-fix
```

Open an emergency pull request.

## The Verification

Confirm the hotfix branch started from the intended tag:

```bash
git merge-base --is-ancestor v1.0.0 hotfix/critical-release-fix
```

On macOS, Linux, or Git Bash:

```bash
echo $?
```

A result of:

```text
0
```

means the tag is an ancestor of the hotfix branch.

After review and merge, prepare a patch release such as:

```text
v1.0.1
```

---

# W.8 Roll Back a GitHub Release

## The Target

Understand the difference between rolling back code and changing GitHub Release visibility.

## The Concept

A GitHub Release is a publication record associated with a tag.

Rolling back an application deployment and deleting a GitHub Release are different actions.

| Action | What it changes |
|---|---|
| Revert commit | Changes source history going forward |
| Deploy prior version | Changes what users are running |
| Mark release as pre-release | Changes release visibility and expectations |
| Delete GitHub Release | Removes the GitHub release page, not necessarily the Git tag |
| Delete tag | Removes a release reference and can confuse users if already published |

Avoid deleting published tags unless the tag was created in error and all consequences are understood.

A safer approach is often:

```text
Keep v1.0.1 visible as a known bad release record.
Publish v1.0.2 with the fix.
Document the issue in release notes.
```

## The Implementation

Inspect releases with GitHub CLI:

```bash
gh release list
```

View one release:

```bash
gh release view v1.0.0
```

If a release was drafted but should not be published, delete the draft release only after confirming the tag policy:

```bash
gh release delete v1.0.0 --yes
```

Do not run this command against a real published release unless your incident response plan explicitly calls for it.

To create a corrective release after a fix:

```bash
git tag -a v1.0.1 -m "Release version 1.0.1"
git push origin v1.0.1
gh release create v1.0.1 --title "Release version 1.0.1" --generate-notes
```

## The Verification

Before changing release visibility or deleting anything, confirm:

```text
[ ] Which users may already depend on this tag?
[ ] Whether package managers, deployment systems, or documentation reference it.
[ ] Whether a corrective release is safer than deletion.
[ ] Whether the incident record explains the chosen action.
```

---

# W.9 Respond to an Exposed Secret

## The Target

Contain a leaked credential correctly and avoid relying only on Git history cleanup.

## The Concept

If a real secret is committed or pushed:

> Assume the secret is compromised immediately.

The first action is not `git revert`.

The first action is:

```text
Revoke or rotate the credential.
```

Examples:

- Revoke a GitHub Personal Access Token.
- Rotate a cloud API key.
- Replace a database password.
- Disable a leaked deploy key.
- Reissue a certificate.
- Invalidate a session or credential.

Removing a secret from Git history may still be necessary, but it is secondary to making the secret unusable.

## The Implementation

Use this incident sequence:

```text
1. Revoke or rotate the credential.
2. Stop affected deployment or integration if necessary.
3. Remove the secret from the current branch.
4. Add correct .gitignore rules.
5. Open a security advisory or private incident record.
6. Decide whether history rewriting is required.
7. Audit logs and access records where possible.
8. Add prevention controls.
```

For a secret in the latest unpushed commit:

```bash
git rm --cached .env
printf ".env\n" >> .gitignore
git add .gitignore
git commit --amend --no-edit
```

For a pushed secret, first rotate it, then remove it from current files:

```bash
git rm --cached .env
git add .gitignore
git commit -m "Remove exposed environment configuration"
git push
```

Use GitHub secret scanning and provider-specific incident guidance where available.

## The Verification

Confirm all of the following:

```text
[ ] The original credential is revoked, rotated, or disabled.
[ ] The secret does not exist in current tracked files.
[ ] The affected service no longer accepts the old credential.
[ ] A private incident record exists.
[ ] The team decided whether historical cleanup is required.
[ ] New prevention measures are documented.
```

---

# W.10 Disable Unsafe GitHub Actions Automation

## The Target

Contain a workflow incident by stopping unsafe or malfunctioning GitHub Actions execution.

## The Concept

If a workflow is:

- Deploying unexpectedly.
- Using too many permissions.
- Exposing sensitive output.
- Running on untrusted pull-request code.
- Triggering too frequently.
- Publishing incorrect artifacts.

contain the automation first.

Possible containment actions include:

```text
Disable the workflow in GitHub.
Remove or restrict secrets.
Disable a compromised token.
Restrict branch triggers.
Revert unsafe workflow changes.
Pause environment deployments.
```

## The Implementation

On GitHub:

1. Open the repository **Actions** tab.
2. Select the affected workflow.
3. Open the workflow menu.
4. Select **Disable workflow** if immediate containment is needed.

Then create a fix branch:

```bash
git switch main
git pull --ff-only
git switch -c fix/contain-unsafe-workflow
```

For example, if a workflow has overly broad permissions, replace:

```yaml
permissions: write-all
```

with the minimum required permissions:

```yaml
permissions:
  contents: read
```

Commit the change:

```bash
git add .github/workflows/<workflow-file>.yml
git commit -m "fix(actions): restrict workflow permissions"
git push -u origin fix/contain-unsafe-workflow
```

Open an emergency pull request.

## The Verification

Confirm:

```text
[ ] The unsafe workflow is disabled or no longer receives sensitive access.
[ ] Relevant tokens or secrets are rotated if exposure is possible.
[ ] The corrected workflow uses least-privilege permissions.
[ ] The workflow is re-enabled only after review and verification.
```

Inspect workflow permissions locally:

```bash
grep -RIn "permissions:" .github/workflows
```

On Windows PowerShell:

```powershell
Get-ChildItem .github\workflows -File |
  Select-String -Pattern "permissions:"
```

---

# W.11 Recover from an Accidental Force Push

## The Target

Recover a branch after someone force-pushes the wrong history.

## The Concept

A force push can replace remote branch history.

For example:

```text
Before:
origin/main → A → B → C

After accidental force push:
origin/main → A → X
```

Commits `B` and `C` may no longer be reachable from the remote branch, but they may still exist:

- In another contributor’s clone.
- In a local reflog.
- In a mirror backup.
- In GitHub supportable recovery windows, depending on the situation.

The immediate goal is to identify the last correct commit and restore it safely.

## The Implementation

Do not force-push immediately in response.

First, capture state:

```bash
git fetch origin
git log --oneline --decorate --graph --all -30
git reflog --all --date=local -50
```

Ask other maintainers to avoid pushing until the situation is understood.

Find the last known-good commit hash.

Create a recovery branch locally:

```bash
git switch -c recovery/restore-main GOOD_COMMIT_HASH
```

Inspect it:

```bash
git log --oneline origin/main..HEAD
npm test
```

If the branch is confirmed correct and repository policy permits a coordinated restore, a maintainer may restore remote `main` with:

```bash
git push --force-with-lease origin recovery/restore-main:main
```

This is an exceptional operation. Coordinate it with all active contributors and document it in the incident record.

## The Verification

After restoration:

```bash
git fetch origin
git log --oneline --decorate --graph origin/main -20
```

Confirm the expected known-good commits are visible again.

Then instruct contributors to synchronize safely. In many cases, recloning is the clearest option. If they must preserve local work, they should create backup branches before resetting.

---

# W.12 Recover from a Deleted Remote Branch

## The Target

Restore a branch deleted from GitHub when its commits still exist locally or in backups.

## The Concept

Deleting a remote branch removes its remote reference, but it does not necessarily erase its commits everywhere.

A maintainer’s local clone may still have:

```text
feature/important-work
```

Or a reflog may identify the branch tip.

## The Implementation

List local branches:

```bash
git branch
```

Inspect reflog for the deleted branch:

```bash
git reflog --all --oneline | grep "feature/important-work"
```

On Windows PowerShell:

```powershell
git reflog --all --oneline | Select-String "feature/important-work"
```

If the branch still exists locally, restore it to GitHub:

```bash
git push -u origin feature/important-work
```

If only a commit hash remains, recreate the branch:

```bash
git switch -c feature/important-work RECOVERY_HASH
git push -u origin feature/important-work
```

## The Verification

Confirm the remote branch exists:

```bash
git ls-remote --heads origin feature/important-work
```

Expected output resembles:

```text
<hash>    refs/heads/feature/important-work
```

---

# W.13 Post-Incident Review Template

## The Target

Document what happened and improve the system without assigning personal blame.

## The Concept

A post-incident review is not a punishment document.

Its purpose is to improve systems, tests, documentation, review practices, automation, and communication.

A useful review asks:

```text
What happened?
What was the impact?
How was it detected?
Why did existing safeguards not prevent it?
What helped recovery?
What should change now?
```

## The Implementation

Use this template after stabilization.

```md
# Incident Review: Short Title

## Summary

Describe what happened in clear, non-blaming language.

## Impact

- User impact:
- Duration:
- Affected versions, branches, environments, or services:
- Data or security impact:

## Timeline

| Time | Event |
|---|---|
| YYYY-MM-DD HH:MM | Problem detected |
| YYYY-MM-DD HH:MM | Containment action taken |
| YYYY-MM-DD HH:MM | Fix or rollback merged |
| YYYY-MM-DD HH:MM | Recovery verified |

## Root Cause

Describe the technical and process conditions that allowed the incident.

Avoid individual blame. Focus on systems, assumptions, missing checks, and unclear ownership.

## What Went Well

- 
- 

## What Made Recovery Harder

- 
- 

## Corrective Actions

- [ ] Add or improve regression tests.
- [ ] Improve CI, branch protection, or workflow permissions.
- [ ] Update release checklist or documentation.
- [ ] Improve monitoring or alerting.
- [ ] Clarify ownership or escalation path.
- [ ] Create follow-up issues with owners and due dates.

## Lessons Learned

Summarize the changes that will make a similar incident less likely or easier to recover from.
```

## The Verification

A complete review should produce actionable follow-up work.

Confirm every corrective action has:

```text
[ ] An owner.
[ ] A tracking issue or task.
[ ] A clear completion condition.
[ ] A priority.
```

---

# W.14 Emergency Command Reference

## Inspect Current State

```bash
git status
git log --oneline --decorate --graph --all -20
git reflog --all --date=local -50
```

## Create a Rollback Branch

```bash
git switch main
git pull --ff-only
git switch -c revert/short-description
```

## Revert an Ordinary Commit

```bash
git revert <commit-hash>
```

## Revert a Merge Commit

```bash
git revert -m 1 <merge-commit-hash>
```

## Abort an Incomplete Revert

```bash
git revert --abort
```

## Continue a Revert After Conflict Resolution

```bash
git add <resolved-file>
git revert --continue
```

## Create a Hotfix from a Release Tag

```bash
git switch -c hotfix/short-description v1.0.0
```

## Restore a Deleted Branch

```bash
git switch -c recovery/branch-name <commit-hash>
git push -u origin recovery/branch-name
```

## Inspect GitHub Actions Runs

```bash
gh run list
gh run view RUN_ID --log-failed
```

## Disable a Workflow

Use GitHub’s Actions web interface:

```text
Repository → Actions → Workflow → Disable workflow
```

## Restore `main` After an Accidental Force Push

Only with coordination:

```bash
git push --force-with-lease origin recovery/restore-main:main
```

---

# Appendix W Completion Check

You should now be able to:

- [ ] Follow an incident lifecycle: detect, contain, preserve, restore, verify, communicate, prevent.
- [ ] Create an incident record without exposing sensitive information.
- [ ] Capture repository state before recovery operations.
- [ ] Use `git revert` instead of rewriting shared history.
- [ ] Revert ordinary, merge, and squash-merged commits appropriately.
- [ ] Create a hotfix branch from a known-good release tag.
- [ ] Respond correctly to exposed secrets by rotating or revoking first.
- [ ] Contain unsafe GitHub Actions workflows.
- [ ] Recover from accidental force pushes and deleted branches with coordination.
- [ ] Run a blameless post-incident review with actionable follow-up work.
