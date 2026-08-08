# Appendix H: Git Commands & Workflows

## Complete Git Reference Guide

Welcome to **Appendix H** of the Django REST Framework & Next.js 16 masterclass. This appendix provides a comprehensive reference for Git commands, workflows, and best practices used throughout the masterclass.

---

## Section 1: Git Commands Reference

### 1.1 Repository Setup

```bash
# Initialize a new repository
git init

# Clone a repository
git clone https://github.com/username/repository.git
git clone git@github.com:username/repository.git  # SSH

# Clone with specific branch
git clone -b develop https://github.com/username/repository.git

# Clone with depth (shallow clone)
git clone --depth 1 https://github.com/username/repository.git
```

### 1.2 Basic Commands

```bash
# Check status
git status

# Add files
git add file.txt
git add .              # Add all files
git add -A             # Add all changes (including deletions)
git add -p             # Interactive staging

# Commit changes
git commit -m "Commit message"
git commit -am "Commit message"  # Add and commit
git commit --amend     # Amend last commit
git commit -m "Message" --no-verify  # Skip hooks

# View commit history
git log
git log --oneline
git log --graph --oneline --decorate
git log -p             # Show changes
git log --stat         # Show file statistics

# Show changes
git diff               # Unstaged changes
git diff --staged      # Staged changes
git diff HEAD          # All changes
git diff commit1 commit2  # Between commits

# Show who changed what
git blame file.txt
```

### 1.3 Branch Commands

```bash
# List branches
git branch             # Local branches
git branch -r          # Remote branches
git branch -a          # All branches
git branch -v          # Branch with last commit

# Create branch
git branch feature/new-feature
git checkout -b feature/new-feature  # Create and switch

# Switch branch
git checkout branch-name
git switch branch-name

# Delete branch
git branch -d branch-name  # Safe delete (merged)
git branch -D branch-name  # Force delete

# Rename branch
git branch -m old-name new-name

# Merge branch
git merge branch-name
git merge --no-ff branch-name  # No fast-forward
git merge --squash branch-name # Squash commits

# Rebase branch
git rebase branch-name
git rebase --continue
git rebase --abort
git rebase --skip

# Cherry-pick commit
git cherry-pick commit-hash
git cherry-pick -n commit-hash  # No commit

# Compare branches
git diff branch1..branch2
git log branch1..branch2
```

### 1.4 Remote Commands

```bash
# List remotes
git remote -v

# Add remote
git remote add origin https://github.com/username/repository.git
git remote set-url origin git@github.com:username/repository.git

# Remove remote
git remote remove remote-name

# Rename remote
git remote rename old-name new-name

# Fetch from remote
git fetch
git fetch origin
git fetch --prune  # Remove deleted remote branches

# Pull from remote
git pull
git pull origin main
git pull --rebase  # Rebase instead of merge

# Push to remote
git push
git push origin main
git push -u origin main  # Set upstream
git push --force         # Force push (use with caution!)
git push --force-with-lease  # Safer force push
git push --tags           # Push tags

# Delete remote branch
git push origin --delete branch-name
git push origin :branch-name
```

### 1.5 Tag Commands

```bash
# List tags
git tag
git tag -l "v1.*"

# Create tag
git tag v1.0.0
git tag -a v1.0.0 -m "Version 1.0.0"
git tag -s v1.0.0 -m "Signed tag"  # GPG signed

# Push tags
git push --tags
git push origin v1.0.0

# Delete tag
git tag -d v1.0.0
git push origin --delete v1.0.0

# Checkout tag
git checkout v1.0.0
git checkout -b branch-from-tag v1.0.0
```

### 1.6 Stash Commands

```bash
# Stash changes
git stash
git stash save "Description"
git stash -u  # Include untracked files

# List stashes
git stash list

# Apply stash
git stash apply
git stash apply stash@{1}
git stash apply --index  # Restage changes

# Pop stash (apply and remove)
git stash pop
git stash pop stash@{1}

# Drop stash
git stash drop
git stash drop stash@{1}

# Clear all stashes
git stash clear

# Show stash content
git stash show
git stash show -p stash@{1}

# Create branch from stash
git stash branch new-branch stash@{1}
```

### 1.7 Reset and Revert

```bash
# Soft reset (keep changes staged)
git reset --soft HEAD~1
git reset --soft commit-hash

# Mixed reset (keep changes unstaged)
git reset --mixed HEAD~1
git reset commit-hash  # Same as --mixed

# Hard reset (discard all changes)
git reset --hard HEAD~1
git reset --hard commit-hash

# Undo commit and keep changes
git reset --soft HEAD~1
git reset HEAD~1

# Revert commit (safe undo)
git revert commit-hash
git revert HEAD
git revert -n commit-hash  # No auto-commit

# Undo a revert
git revert -m 1 commit-hash  # Revert a merge commit
```

### 1.8 Clean and Maintenance

```bash
# Remove untracked files
git clean -n  # Dry run
git clean -f  # Force remove
git clean -fd # Remove directories
git clean -fx # Include ignored files

# Remove ignored files
git rm -r --cached .  # Unstage all
git rm -r --cached .idea/  # Remove from index

# Garbage collection
git gc
git gc --aggressive
git gc --auto

# Prune references
git remote prune origin
git reflog expire --expire=now --all
```

---

## Section 2: Git Workflows

### 2.1 Feature Branch Workflow

```bash
# Start a new feature
git checkout main
git pull origin main
git checkout -b feature/user-authentication

# Work on the feature
git add .
git commit -m "Add login form"
git commit -m "Add JWT authentication"

# Push feature branch
git push -u origin feature/user-authentication

# Create pull request on GitHub/GitLab

# Merge feature after review
git checkout main
git pull origin main
git merge --no-ff feature/user-authentication
git push origin main

# Delete feature branch
git branch -d feature/user-authentication
git push origin --delete feature/user-authentication
```

### 2.2 Hotfix Workflow

```bash
# Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug

# Fix the bug
git add .
git commit -m "Fix critical bug in production"

# Merge to main
git checkout main
git merge --no-ff hotfix/critical-bug
git push origin main

# Merge to develop
git checkout develop
git merge --no-ff hotfix/critical-bug
git push origin develop

# Delete hotfix branch
git branch -d hotfix/critical-bug
git push origin --delete hotfix/critical-bug

# Create version tag
git tag -a v1.0.1 -m "Hotfix version 1.0.1"
git push --tags
```

### 2.3 Release Workflow

```bash
# Create release branch
git checkout develop
git pull origin develop
git checkout -b release/v1.1.0

# Prepare release
git add .
git commit -m "Bump version to 1.1.0"
git commit -m "Update CHANGELOG.md"

# Finalize release
git checkout main
git merge --no-ff release/v1.1.0
git tag -a v1.1.0 -m "Version 1.1.0"
git push origin main --tags

# Merge back to develop
git checkout develop
git merge --no-ff release/v1.1.0
git push origin develop

# Delete release branch
git branch -d release/v1.1.0
git push origin --delete release/v1.1.0
```

### 2.4 CI/CD Workflow

```bash
# Automated workflow in CI/CD

# On pull request
# 1. Run tests
git checkout pr-branch
npm test
pytest

# 2. Build application
npm run build
docker build -t app:pr-$PR_NUMBER .

# 3. Deploy to staging
docker-compose -f docker-compose.staging.yml up -d

# On merge to main
# 1. Build production image
docker build -t app:latest .

# 2. Tag and push
docker tag app:latest registry.example.com/app:latest
docker push registry.example.com/app:latest

# 3. Deploy
kubectl set image deployment/app app=registry.example.com/app:latest
kubectl rollout status deployment/app
```

---

## Section 3: Git Hooks

### 3.1 Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/bin/sh

# Run linting
npm run lint

# Run tests
npm run test

# Run security scan
npm audit

# Check for secrets
git diff --cached | grep -E "(password|secret|key)" && exit 1

# Format code
npm run format
git add .

# Prevent commit on test failure
if [ $? -ne 0 ]; then
    echo "Tests failed. Commit aborted."
    exit 1
fi
```

### 3.2 Pre-push Hook

```bash
# .git/hooks/pre-push
#!/bin/sh

# Run full test suite
npm run test:ci

# Build to ensure it works
npm run build

# Check for breaking changes
npm run check:breaking

# Validate package versions
npm outdated --no-exit-code
```

---

## Section 4: Git Configuration

### 4.1 Global Configuration

```bash
# Set user information
git config --global user.name "John Doe"
git config --global user.email "john@example.com"

# Set editor
git config --global core.editor "code --wait"
git config --global core.editor "vim"

# Set merge tool
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd "code --wait $MERGED"

# Set diff tool
git config --global diff.tool vscode
git config --global difftool.vscode.cmd "code --wait --diff $LOCAL $REMOTE"

# Aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD"
git config --global alias.visual "!gitk"
git config --global alias.lg "log --graph --oneline --decorate"

# Credentials
git config --global credential.helper store
git config --global credential.helper 'cache --timeout=3600'

# Pull behavior
git config --global pull.rebase false  # Merge
git config --global pull.rebase true   # Rebase
git config --global pull.ff only       # Fast-forward only

# Performance
git config --global core.preloadindex true
git config --global core.fscache true
git config --global core.untrackedCache true
```

### 4.2 .gitignore

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Django
*.log
*.pot
*.pyc
local_settings.py
db.sqlite3
db.sqlite3-journal
media/
staticfiles/
coverage/
htmlcov/

# Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*
.next/
out/
dist/
.vercel

# Environment
.env
.env.local
.env.*.local
*.secret

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Docker
*.pid
docker-compose.override.yml
.dockerignore

# Testing
.coverage
.pytest_cache/
.tox/
.mypy_cache/
.ruff_cache/
.cypress/
cypress/videos/
cypress/screenshots/

# Other
*.log
*.bak
*.tmp
```

---

## Section 5: Common Git Issues and Solutions

### 5.1 Undo Last Commit

```bash
# Keep changes staged
git reset --soft HEAD~1

# Keep changes unstaged
git reset --mixed HEAD~1

# Discard changes completely
git reset --hard HEAD~1

# Fix commit message
git commit --amend -m "New commit message"

# Add forgotten file
git add forgotten-file.txt
git commit --amend --no-edit
```

### 5.2 Recover Lost Commit

```bash
# Show reflog
git reflog

# Reset to commit
git reset --hard HEAD@{n}

# Cherry-pick from reflog
git cherry-pick commit-hash

# Create branch from lost commit
git branch recovered-branch commit-hash
```

### 5.3 Merge Conflicts

```bash
# View conflicts
git status
git diff

# Resolve conflict manually
# Edit files and remove conflict markers

# Mark as resolved
git add file.txt

# Continue merge
git merge --continue

# Abort merge
git merge --abort

# Use graphical merge tool
git mergetool

# Accept one version
git checkout --ours file.txt
git checkout --theirs file.txt
```

### 5.4 Force Push Safety

```bash
# Safe force push
git push --force-with-lease

# Force push to specific branch
git push --force-with-lease origin main

# Force push after pull
git pull --rebase
git push --force-with-lease

# Undo force push (if you know previous commit)
git reset --hard previous-commit-hash
git push --force-with-lease
```

---

## Section 6: Git Best Practices

### 6.1 Commit Message Guidelines

```
# Format
<type>(<scope>): <subject>

# Types
feat:     New feature
fix:      Bug fix
docs:     Documentation changes
style:    Code style (formatting, missing semicolons)
refactor: Code refactoring
perf:     Performance improvements
test:     Adding/updating tests
chore:    Maintenance tasks
ci:       CI/CD changes

# Examples
feat(auth): Add JWT authentication
fix(api): Fix task creation validation
docs(readme): Update installation instructions
refactor(serializers): Optimize task list serializer
perf(queries): Add database indexes for tasks
test(tasks): Add unit tests for task model
ci(github): Update CI workflow for Python 3.12
```

### 6.2 Branch Naming Conventions

```
# Branch naming
feature/user-authentication
feature/add-login-page
bugfix/fix-task-deletion
bugfix/validation-error
hotfix/security-patch
hotfix/database-migration
release/v1.2.0
release/v2.0.0-rc1
chore/update-dependencies
chore/docker-optimization
```

### 6.3 Development Workflow

```bash
# 1. Keep main stable
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/your-feature

# 3. Commit frequently
git add .
git commit -m "feat: Add new feature component"

# 4. Keep branch updated
git fetch origin
git rebase origin/main

# 5. Push and create PR
git push -u origin feature/your-feature

# 6. After PR approval
git checkout main
git pull origin main
git merge --no-ff feature/your-feature
git push origin main
```

---

## Quick Reference Cards

### Git Command Categories

| Category | Common Commands |
|----------|-----------------|
| **Setup** | init, clone, config |
| **Basic** | status, add, commit, diff |
| **Branches** | branch, checkout, switch, merge, rebase |
| **Remotes** | remote, fetch, pull, push |
| **History** | log, show, blame, reflog |
| **Undo** | reset, revert, stash, clean |
| **Tags** | tag, push --tags |
| **Maintenance** | gc, prune, clean |

### Common Git Aliases

```bash
# Setup aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --graph --oneline --decorate"
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD"
git config --global alias.visual "!gitk"
git config --global alias.s "status -s"
git config --global alias.a "!git add . && git status"

# Usage
git co main
git br
git st
git lg
```

---

*This concludes Appendix H. Use this Git reference to manage your code effectively throughout your development journey.*
