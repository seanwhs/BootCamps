# Primer 13: Git & Version Control Workflow

## Your Complete Guide to Professional Git Practices

Welcome to the Git & Version Control Primer! This guide covers everything you need to know about using Git effectively in a professional mobile development environment. Version control is the foundation of collaborative development—it tracks changes, enables teamwork, and provides a safety net for your code.

---

## G.1 Understanding Git Fundamentals

### The Concept: Your Code's Time Machine

Git is a distributed version control system that tracks changes to your code over time. Think of it as a time machine for your project—you can travel back to any point in history, see who changed what, and collaborate with others without conflicts.

**Simple Analogy:** Git is like a journal for your code. Every time you save a checkpoint (commit), you record what changed and why. You can flip back to any previous page (commit), create alternate storylines (branches), and merge them back into the main story (main branch).

### Core Concepts

```bash
# 1. Repository - Your project's complete history
git init                    # Create a new repository
git clone <url>             # Copy an existing repository

# 2. Commit - A snapshot of your code at a point in time
git add <file>              # Stage changes
git commit -m "message"     # Save changes with a message
git commit -a -m "message"  # Add and commit all tracked files

# 3. Branch - An independent line of development
git branch <name>           # Create a branch
git checkout <name>         # Switch to a branch
git switch <name>           # Switch to a branch (modern)
git merge <branch>          # Merge a branch into current

# 4. Remote - A copy of the repository on a server
git remote add origin <url> # Add a remote
git push origin <branch>    # Push to remote
git pull origin <branch>    # Pull from remote
git fetch origin            # Fetch from remote without merging

# 5. History - All previous commits
git log                     # View commit history
git log --oneline          # Compact history view
git log --graph            # Visual branch history
git diff <commit1> <commit2> # Compare commits
```

---

## G.2 Branching Strategy

### The Concept: Organized Collaboration

A good branching strategy keeps your codebase organized and enables parallel development.

### Complete Branching Guide

```bash
# 1. Git Flow Strategy
# Main branch: Production-ready code
# Develop branch: Integration branch
# Feature branches: New features
# Release branches: Preparing releases
# Hotfix branches: Emergency fixes

# Create a feature branch
git checkout develop
git pull origin develop
git checkout -b feature/authentication

# Work on feature
git add .
git commit -m "Add login screen"
git commit -m "Add registration flow"

# Push feature branch
git push origin feature/authentication

# Create pull request
# Merge to develop when ready

# Create a release branch
git checkout develop
git checkout -b release/1.0.0

# Fix release issues
git commit -m "Fix version number"

# Merge to main
git checkout main
git merge --no-ff release/1.0.0
git tag -a v1.0.0 -m "Release version 1.0.0"

# Merge back to develop
git checkout develop
git merge --no-ff release/1.0.0

# Create hotfix
git checkout main
git checkout -b hotfix/critical-bug

# Fix bug
git commit -m "Fix critical bug"

# Merge to main and develop
git checkout main
git merge --no-ff hotfix/critical-bug
git tag -a v1.0.1 -m "Hotfix version 1.0.1"

git checkout develop
git merge --no-ff hotfix/critical-bug

# 2. GitHub Flow (Simpler)
# Main branch is always deployable
# Feature branches for everything else

# Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/new-feature

# Work on feature
git commit -m "Add new feature"

# Push and create pull request
git push origin feature/new-feature

# 3. Feature Branch Naming
# feature/authentication
# feature/user-profile
# bugfix/login-error
# hotfix/critical-crash
# chore/update-dependencies
# docs/readme-update

# 4. Branch Protection Rules
# Require pull request reviews
# Require status checks to pass
# Require up-to-date branches
# Require signed commits
# No direct pushes to main
```

---

## G.3 Commit Best Practices

### The Concept: Meaningful History

Good commits make your project history easy to understand and debug.

### Complete Commit Guide

```bash
# 1. Commit Message Structure
# <type>(<scope>): <subject>
# <body>
# <footer>

# Example:
# feat(auth): add biometric authentication
# 
# Implement Face ID and Touch ID for secure login
# 
# Closes #123

# 2. Commit Types
# feat: New feature
# fix: Bug fix
# docs: Documentation changes
# style: Code style changes (formatting, semicolons)
# refactor: Code refactoring
# perf: Performance improvements
# test: Adding/updating tests
# chore: Build/dependency changes
# ci: CI configuration changes
# revert: Revert a previous commit
# release: Release version

# 3. Good Commit Messages
# ✅ Good:
# feat(auth): add biometric authentication
# fix(login): handle network timeout errors
# refactor(api): extract api client to separate module
# docs(readme): update installation instructions

# ❌ Bad:
# Fixed stuff
# Added code
# Work in progress
# Updated
# fixed bug

# 4. Atomic Commits
# Each commit should be a single logical change
# ✅ Good: One commit per feature
# ❌ Bad: One commit for multiple unrelated changes

# 5. Commit Frequently
# Commit early and often
# Each commit should build successfully
# Each commit should pass tests

# 6. Amending Commits
# Amend last commit
git commit --amend -m "Updated commit message"

# Add forgotten files to last commit
git add forgotten-file.js
git commit --amend --no-edit

# 7. Interactive Rebase (Squash commits)
git rebase -i HEAD~3  # Squash last 3 commits
# In editor:
# pick abc123 First commit
# squash def456 Second commit
# squash ghi789 Third commit
# Then write a combined commit message
```

---

## G.4 Working with Teams

### The Concept: Collaborative Development

Git enables teams to work together efficiently.

### Complete Team Collaboration Guide

```bash
# 1. Pull Request Workflow
# 1. Create feature branch
git checkout -b feature/new-feature

# 2. Work on changes
git commit -m "feat: add new feature"

# 3. Push to remote
git push origin feature/new-feature

# 4. Create pull request on GitHub/GitLab

# 5. Address review feedback
git commit -m "fix: address review feedback"
git push origin feature/new-feature

# 6. Merge when approved

# 2. Keeping Your Branch Updated
# Pull latest changes from main
git checkout main
git pull origin main
git checkout feature/new-feature
git rebase main

# Or merge
git merge main

# 3. Resolving Merge Conflicts
# Identify conflicts
git status

# Open conflicted files and resolve
# <======= marks your changes
# ======== separates versions
# >>>>>>> marks incoming changes

# After resolving
git add .
git commit -m "Merge: resolve conflicts"

# 4. Code Review Best Practices
# Review for:
# - Correctness
# - Test coverage
# - Performance
# - Security
# - Code style
# - Documentation

# 5. PR Template
# ### Description
# Briefly describe the changes
# 
# ### Type of Change
# - [ ] Feature
# - [ ] Bug fix
# - [ ] Refactor
# - [ ] Documentation
# 
# ### Test Plan
# Steps to test the changes
# 
# ### Screenshots (if applicable)

# 6. Branch Protection Rules
# - Require pull requests
# - Require approvals (2)
# - Require status checks
# - Require conversation resolution
# - Restrict who can push
```

---

## G.5 Advanced Git Commands

### The Concept: Powerful Git Techniques

Advanced Git commands help you recover from mistakes and manage complex situations.

### Complete Advanced Guide

```bash
# 1. Undoing Changes
# Unstage changes (keep file changes)
git reset HEAD <file>

# Discard changes in working directory
git checkout -- <file>
git restore <file>  # Modern syntax

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Revert a commit (create new commit that undoes)
git revert <commit-hash>

# 2. Stashing Changes
# Save uncommitted changes temporarily
git stash
git stash push -m "WIP: authentication feature"

# List stashes
git stash list

# Apply latest stash
git stash pop

# Apply specific stash
git stash apply stash@{2}

# Drop a stash
git stash drop stash@{2}

# 3. Cherry-Picking
# Apply a specific commit to current branch
git cherry-pick <commit-hash>

# Cherry-pick multiple commits
git cherry-pick <hash1> <hash2> <hash3>

# 4. Interactive Rebase
# Reorder, squash, edit, or drop commits
git rebase -i HEAD~5

# Commands in rebase:
# pick - Use commit
# reword - Change commit message
# edit - Stop to amend
# squash - Combine with previous
# fixup - Like squash but discard message
# drop - Remove commit

# 5. Bisect - Find the commit that introduced a bug
git bisect start
git bisect bad HEAD  # Current commit is bad
git bisect good <commit>  # Known good commit

# Git will check out commits for you to test
# After testing:
git bisect good  # If commit is good
git bisect bad   # If commit is bad

# Finish bisect
git bisect reset

# 6. Recovering Lost Commits
# Show all commits (including dangling)
git reflog

# Reset to a previous state
git reset --hard HEAD@{2}

# 7. Submodules
# Add a submodule
git submodule add <url> path

# Initialize submodules
git submodule update --init --recursive

# Update submodules
git submodule update --remote
```

---

## G.6 Git Hooks

### The Concept: Automating Git Workflows

Git hooks run scripts at key points in the Git workflow, enabling automation.

### Complete Git Hooks Guide

```bash
# 1. Client-Side Hooks (.git/hooks/)
# pre-commit - Run before commit
# prepare-commit-msg - Edit commit message
# commit-msg - Validate commit message
# post-commit - Run after commit
# pre-rebase - Run before rebase
# post-checkout - Run after checkout
# post-merge - Run after merge

# 2. Pre-commit Hook Example
# .git/hooks/pre-commit
#!/bin/sh
npm run lint
npm run type-check

# 3. Commit Message Hook
# .git/hooks/commit-msg
#!/bin/sh
# Validate commit message format
# Ensure message follows conventional commits

# 4. Using Husky (for project-wide hooks)
# Install husky
npm install -D husky

# Enable husky
npx husky install

# Add pre-commit hook
npx husky add .husky/pre-commit "npm run lint"

# Add commit-msg hook
npx husky add .husky/commit-msg 'npx --no-install commitlint --edit "$1"'

# 5. Lint-Staged Configuration
# package.json
{
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md}": [
      "prettier --write"
    ]
  }
}

# 6. Commit Lint Configuration
# commitlint.config.js
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'chore', 'ci', 'revert']
    ],
    'subject-case': [1, 'always', 'sentence-case'],
    'header-max-length': [2, 'always', 72],
  },
};
```

---

## G.7 Git Configuration

### The Concept: Setting Up Git

Proper Git configuration makes your workflow smoother.

### Complete Configuration Guide

```bash
# 1. Global Configuration
# Set user name and email
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default editor
git config --global core.editor "code --wait"

# Set default branch name
git config --global init.defaultBranch main

# Set useful aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD"

# 2. Git Ignore Patterns
# .gitignore
# Dependencies
node_modules/
.vscode/
.idea/
*.iml

# Build
dist/
build/
*.apk
*.ipa
*.aab

# Environment
.env
.env.*
!.env.example

# System
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.*

# IDE
.expo/
.expo-shared/

# Coverage
coverage/
.nyc_output/

# 3. Global Git Ignore
# ~/.gitignore_global
.DS_Store
Thumbs.db
*.swp
*.swo
*.tmp
```

---

## G.8 Quick Reference

### Common Commands

| Command | Description |
|---------|-------------|
| `git init` | Initialize a repository |
| `git clone <url>` | Clone a repository |
| `git status` | View changed files |
| `git add <file>` | Stage changes |
| `git commit -m "msg"` | Commit changes |
| `git push origin <branch>` | Push to remote |
| `git pull origin <branch>` | Pull from remote |
| `git fetch` | Fetch remote changes |
| `git branch` | List branches |
| `git checkout <branch>` | Switch branch |
| `git merge <branch>` | Merge branch |
| `git rebase <branch>` | Rebase branch |
| `git log` | View history |
| `git diff` | View changes |
| `git reset` | Undo changes |
| `git stash` | Stash changes |
| `git cherry-pick` | Apply commits |

### Git Workflow Checklist

| Step | Command |
|------|---------|
| Start feature | `git checkout -b feature/name` |
| Work on feature | `git add . && git commit -m "feat: ..."` |
| Update from main | `git rebase main` |
| Push feature | `git push origin feature/name` |
| Create PR | ✓ |
| Review PR | ✓ |
| Merge PR | ✓ |

---

**Ready to master Git? Let's build NexusCollect!**
