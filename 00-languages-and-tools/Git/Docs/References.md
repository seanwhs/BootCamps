# References and Resources Guide  
## Mastering Version Control from Local to Production

Use this guide alongside the tutorial series, workbook, lab book, quiz bank, and trainer guide.

---

# 1. Core Official References

## Git Documentation

| Resource | Link | Best for |
|---|---|---|
| Official Git documentation | https://git-scm.com/doc | Command reference and conceptual documentation |
| Git Reference Book | https://git-scm.com/book/en/v2 | Free full-length Git book |
| Git Downloads | https://git-scm.com/downloads | Installing Git |
| Git command list | https://git-scm.com/docs | Looking up a specific command |
| Git branching documentation | https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell | Understanding branches |
| Git merge documentation | https://git-scm.com/docs/git-merge | Merge options and conflict handling |
| Git rebase documentation | https://git-scm.com/docs/git-rebase | Rebasing and interactive rebase |
| Git reflog documentation | https://git-scm.com/docs/git-reflog | Recovering moved or lost commits |
| Git reset documentation | https://git-scm.com/docs/git-reset | Soft, mixed, and hard resets |
| Git restore documentation | https://git-scm.com/docs/git-restore | Restoring file changes |
| Git worktree documentation | https://git-scm.com/docs/git-worktree | Multiple local working directories |

---

## GitHub Documentation

| Resource | Link | Best for |
|---|---|---|
| GitHub Docs home | https://docs.github.com/ | General GitHub guidance |
| GitHub Skills | https://skills.github.com/ | Interactive GitHub learning exercises |
| GitHub Flow | https://docs.github.com/get-started/using-github/github-flow | Feature branch and PR workflow |
| Pull requests | https://docs.github.com/pull-requests | Creating, reviewing, and merging PRs |
| GitHub Issues | https://docs.github.com/issues | Issues, labels, milestones, and Projects |
| GitHub Projects | https://docs.github.com/issues/planning-and-tracking-with-projects | Planning and project boards |
| Branch protection | https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository | Protected branches and rulesets |
| CODEOWNERS | https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners | Path-based review ownership |
| GitHub Releases | https://docs.github.com/repositories/releasing-projects-on-github | Releases, tags, and release assets |
| Repository visibility | https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/managing-repository-settings/setting-repository-visibility | Public versus private repositories |

---

# 2. Authentication and Account Security

## SSH

| Resource | Link |
|---|---|
| GitHub SSH connection guide | https://docs.github.com/authentication/connecting-to-github-with-ssh |
| Generating a new SSH key | https://docs.github.com/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent |
| Adding SSH key to GitHub | https://docs.github.com/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account |
| GitHub SSH key fingerprints | https://docs.github.com/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints |

Useful local test:

```bash
ssh -T git@github.com
```

---

## Personal Access Tokens

| Resource | Link |
|---|---|
| Fine-grained Personal Access Tokens | https://docs.github.com/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens |
| GitHub token settings | https://github.com/settings/personal-access-tokens |
| Git Credential Manager | https://github.com/git-ecosystem/git-credential-manager |

Security reminders:

```text
[ ] Use fine-grained tokens where possible.
[ ] Use short expiration periods.
[ ] Grant minimum permissions.
[ ] Store tokens in a password manager or credential manager.
[ ] Revoke exposed tokens immediately.
```

---

# 3. GitHub Actions and CI/CD Resources

| Resource | Link | Best for |
|---|---|---|
| GitHub Actions documentation | https://docs.github.com/actions | Workflow basics |
| Workflow syntax | https://docs.github.com/actions/writing-workflows/workflow-syntax-for-github-actions | YAML workflow structure |
| Actions security hardening | https://docs.github.com/actions/security-for-github-actions/security-guides/security-hardening-your-deployments | Secure workflow design |
| GitHub Environments | https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment | Protected deployment environments |
| Dependency Review Action | https://github.com/actions/dependency-review-action | Dependency-change checks |
| Dependabot documentation | https://docs.github.com/code-security/dependabot | Automated dependency updates |
| GitHub Actions marketplace | https://github.com/marketplace?type=actions | Discovering reusable Actions |

Useful commands:

```bash
gh run list
gh run watch
gh run view RUN_ID --log-failed
```

---

# 4. Security and Secret Management Resources

| Resource | Link |
|---|---|
| GitHub security documentation | https://docs.github.com/code-security |
| GitHub secret scanning | https://docs.github.com/code-security/secret-scanning |
| Push protection for secrets | https://docs.github.com/code-security/secret-scanning/pushing-a-branch-blocked-by-push-protection |
| Removing sensitive data from a repository | https://docs.github.com/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository |
| GitHub Security Advisories | https://docs.github.com/code-security/security-advisories |
| OWASP Top 10 | https://owasp.org/www-project-top-ten/ |
| OWASP Cheat Sheet Series | https://cheatsheetseries.owasp.org/ |

If a secret is committed:

```text
1. Revoke or rotate the credential.
2. Contain affected systems.
3. Remove the secret from current files.
4. Record the incident privately.
5. Decide whether history cleanup is required.
6. Add prevention controls.
```

---

# 5. Node.js and npm Resources

| Resource | Link | Best for |
|---|---|---|
| Node.js official site | https://nodejs.org/ | Installation and releases |
| Node.js documentation | https://nodejs.org/docs/latest/api/ | Node APIs |
| Node.js test runner | https://nodejs.org/api/test.html | Built-in testing |
| npm documentation | https://docs.npmjs.com/ | npm commands and package management |
| npm CLI documentation | https://docs.npmjs.com/cli | Command reference |
| npm audit | https://docs.npmjs.com/cli/commands/npm-audit | Dependency vulnerability checks |
| package-lock documentation | https://docs.npmjs.com/cli/configuring-npm/package-lock-json | Lockfile behavior |

Useful commands:

```bash
node --version
npm --version
npm install
npm ci
npm test
npm audit
npm ls --depth=0
```

---

# 6. GitHub CLI Resources

| Resource | Link |
|---|---|
| GitHub CLI homepage | https://cli.github.com/ |
| GitHub CLI manual | https://cli.github.com/manual/ |
| GitHub CLI installation | https://github.com/cli/cli#installation |
| GitHub CLI API command documentation | https://cli.github.com/manual/gh_api |
| GitHub CLI Pull Request commands | https://cli.github.com/manual/gh_pr |
| GitHub CLI Issue commands | https://cli.github.com/manual/gh_issue |
| GitHub CLI Release commands | https://cli.github.com/manual/gh_release |
| GitHub CLI Actions commands | https://cli.github.com/manual/gh_run |

High-value commands:

```bash
gh auth login
gh auth status
gh repo view
gh issue list
gh pr list
gh pr create
gh pr view --web
gh run list
gh release list
```

---

# 7. Releases, Versioning, and Changelogs

| Resource | Link |
|---|---|
| Semantic Versioning | https://semver.org/ |
| Keep a Changelog | https://keepachangelog.com/ |
| Conventional Commits | https://www.conventionalcommits.org/ |
| Git tagging documentation | https://git-scm.com/book/en/v2/Git-Basics-Tagging |
| GitHub Releases documentation | https://docs.github.com/repositories/releasing-projects-on-github |

Recommended release references:

```text
Semantic Version:
MAJOR.MINOR.PATCH

Git tag:
v1.0.0

Release notes:
RELEASE_NOTES.md

GitHub release:
Created from an annotated tag
```

---

# 8. Git Recovery and Troubleshooting Resources

| Resource | Link |
|---|---|
| Git reflog docs | https://git-scm.com/docs/git-reflog |
| Git revert docs | https://git-scm.com/docs/git-revert |
| Git reset docs | https://git-scm.com/docs/git-reset |
| Git stash docs | https://git-scm.com/docs/git-stash |
| Git bisect docs | https://git-scm.com/docs/git-bisect |
| Git blame docs | https://git-scm.com/docs/git-blame |
| Git fsck docs | https://git-scm.com/docs/git-fsck |
| Git maintenance docs | https://git-scm.com/docs/git-maintenance |
| GitHub repository restoration guidance | https://docs.github.com/repositories/creating-and-managing-repositories/restoring-a-deleted-repository |

First-response command set:

```bash
git status
git diff
git diff --staged
git log --oneline --decorate --graph --all -20
git reflog --date=local -20
```

---

# 9. Large Repositories and Advanced Git Resources

| Topic | Resource |
|---|---|
| Git LFS | https://git-lfs.com/ |
| Git LFS documentation | https://docs.github.com/repositories/working-with-files/managing-large-files |
| Git worktrees | https://git-scm.com/docs/git-worktree |
| Git submodules | https://git-scm.com/book/en/v2/Git-Tools-Submodules |
| Sparse checkout | https://git-scm.com/docs/git-sparse-checkout |
| Partial clone | https://git-scm.com/docs/partial-clone |
| Git filter-repo | https://github.com/newren/git-filter-repo |
| Git subtree documentation | https://git-scm.com/docs/git-subtree |

---

# 10. Governance, Licensing, and Open Source Resources

| Resource | Link |
|---|---|
| SPDX License List | https://spdx.org/licenses/ |
| Choose a License | https://choosealicense.com/ |
| GitHub licensing guidance | https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository |
| Contributor Covenant | https://www.contributor-covenant.org/ |
| Developer Certificate of Origin | https://developercertificate.org/ |
| GitHub CODEOWNERS documentation | https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners |
| GitHub organization teams | https://docs.github.com/organizations/organizing-members-into-teams |

> Licensing and ownership can have legal consequences. Consult qualified legal counsel for commercial, client-owned, regulated, or high-risk projects.

---

# 11. Recommended Repository Files

Use this checklist when creating a production-oriented repository.

```text
[ ] README.md
[ ] LICENSE
[ ] CONTRIBUTING.md
[ ] SECURITY.md
[ ] CODE_REVIEW.md
[ ] GOVERNANCE.md
[ ] .gitignore
[ ] .gitattributes
[ ] package.json
[ ] package-lock.json
[ ] .github/pull_request_template.md
[ ] .github/ISSUE_TEMPLATE/
[ ] .github/workflows/ci.yml
[ ] .github/CODEOWNERS
[ ] .github/dependabot.yml
[ ] .githooks/
[ ] scripts/install-hooks.sh
```

Not every project needs every file immediately. Add files intentionally and keep them accurate.

---

# 12. Recommended Learning Path

## Beginner

1. Git installation and terminal basics.
2. `git status`, `git add`, `git commit`.
3. `git diff` and `git log`.
4. Branches and simple merges.
5. GitHub account and SSH setup.
6. Push, fetch, pull, clone.

## Intermediate

1. Merge conflicts.
2. Rebase basics.
3. Pull requests and code review.
4. `.gitignore` and secret safety.
5. GitHub Actions CI.
6. Issues, labels, milestones, and Projects.

## Advanced

1. Interactive rebase and amend.
2. Reflog, cherry-pick, reset, and revert.
3. Signed commits and tags.
4. Release automation and Conventional Commits.
5. CODEOWNERS and repository governance.
6. Incident response and repository migrations.

---

# 13. Quick Command Reference

## Daily Workflow

```bash
git switch main
git pull --ff-only
git switch -c feature/short-description
```

```bash
git status
git diff
git add <files>
git diff --staged
npm test
git commit -m "type(scope): describe change"
```

```bash
git push -u origin feature/short-description
```

## Pull Request Inspection

```bash
git diff main...HEAD
git log --oneline main..HEAD
gh pr create
gh pr status
```

## Recovery

```bash
git stash push --include-untracked -m "Safety snapshot"
git reflog
git switch -c recovery/lost-work <commit-hash>
git revert <commit-hash>
```

## Release

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
gh release create v1.0.0 --generate-notes
```

---

# 14. Suggested Practice Repositories

Use disposable repositories when learning risky commands:

```text
git-practice-local/
git-merge-conflict-practice/
git-rebase-practice/
git-recovery-practice/
git-actions-practice/
git-release-practice/
```

Recommended rule:

> Never learn destructive commands on the only copy of important work.

---

# 15. Final Resource Reminder

When uncertain, use official documentation and inspect current state before acting:

```bash
git status
git <command> -h
git help <command>
```

For example:

```bash
git help rebase
git help merge
git help reflog
git help reset
git help restore
```

Core operating principle:

```text
Inspect first.
Preserve work before risky operations.
Review before sharing.
Verify before merging.
Release intentionally.
Recover calmly.
```
