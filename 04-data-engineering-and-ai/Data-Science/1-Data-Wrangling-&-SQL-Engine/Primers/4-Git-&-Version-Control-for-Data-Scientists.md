# PRIMER 4: Git & Version Control for Data Scientists

## A Complete Git Refresher for the Data Engineering Series

---

## Introduction

This primer provides a comprehensive foundation in Git and version control, tailored specifically for data scientists and data engineers. While the main series assumes you can use basic Git commands, this primer ensures you have the skills needed to manage code, collaborate effectively, and maintain reproducible data science projects.

**What This Primer Covers:**
- Git fundamentals and core concepts
- Essential Git commands for daily work
- Branching and merging strategies
- Collaboration workflows
- Managing large files and data
- Best practices for data science projects

**What This Primer Does NOT Cover:**
- Advanced Git internals
- Complex merge conflict resolution
- Git server administration
- CI/CD pipelines (covered elsewhere)

---

## P4.1: Git Fundamentals

### What is Git?

Git is a distributed version control system that tracks changes to files and coordinates work among multiple people. Think of it as a time machine for your code that also enables collaboration.

**Key Concepts:**
- **Repository (Repo):** A directory containing your project and its version history
- **Commit:** A snapshot of your files at a specific point in time
- **Branch:** An independent line of development
- **Remote:** A copy of the repository stored elsewhere (e.g., GitHub)
- **Staging Area:** A place to prepare changes before committing

### Git Workflow Visualization

```
Working Directory → Staging Area → Local Repository → Remote Repository
     (Files)          (git add)       (git commit)      (git push)
```

### Initial Setup

```bash
# Configure your identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set default editor
git config --global core.editor "vim"  # or "code" for VS Code

# View configuration
git config --list

# Set default branch name
git config --global init.defaultBranch main
```

---

## P4.2: Essential Git Commands

### Starting a Project

```bash
# Initialize a new repository
git init

# Clone an existing repository
git clone https://github.com/username/repository.git

# Clone with specific branch
git clone -b branch-name https://github.com/username/repository.git
```

### Basic Workflow

```bash
# Check status of your working directory
git status

# Add files to staging area
git add filename.py        # Add specific file
git add .                  # Add all files in directory
git add *.py               # Add all Python files

# Commit changes
git commit -m "Descriptive commit message"

# Commit with detailed message (opens editor)
git commit

# Add and commit in one step (only for tracked files)
git commit -am "Updated data processing script"

# View commit history
git log                    # Full history
git log --oneline          # Compact view
git log --graph --oneline  # Visual branch view
git log -p                 # Show changes

# View changes
git diff                   # Changes not staged
git diff --staged          # Changes staged but not committed
git diff HEAD              # Changes since last commit
```

### Undoing Changes

```bash
# Unstage a file (keep changes)
git reset HEAD filename.py

# Discard changes in working directory (careful!)
git checkout -- filename.py

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Revert a commit (creates new commit that undoes changes)
git revert commit_hash

# Amend last commit (change message or add more changes)
git commit --amend -m "New commit message"
```

---

## P4.3: Branching and Merging

### Understanding Branches

Branches allow you to work on different features independently. Think of them as parallel universes for your code.

```
main → ● → ● → ● → ● → ●
         \
feature → ● → ● → ●
```

### Branch Commands

```bash
# List branches
git branch                 # Local branches
git branch -a              # All branches (including remote)
git branch -v              # Branches with last commit

# Create a new branch
git branch feature-name

# Create and switch to new branch
git checkout -b feature-name

# Switch to existing branch
git checkout branch-name

# Switch using new syntax (Git 2.23+)
git switch branch-name
git switch -c new-branch   # Create and switch

# Delete a branch
git branch -d branch-name   # Safe delete (merged)
git branch -D branch-name   # Force delete

# Rename current branch
git branch -m new-name
```

### Merging

```bash
# Merge a branch into current branch
git merge feature-name

# Fast-forward merge (no merge commit)
git merge --ff feature-name

# Create merge commit even if fast-forward possible
git merge --no-ff feature-name

# Abort merge in case of conflicts
git merge --abort
```

### Resolving Merge Conflicts

```bash
# When merge conflicts occur, Git marks the conflicts:
# <<<<<<< HEAD
# Your changes
# =======
# Changes from the branch being merged
# >>>>>>> feature-name

# Steps to resolve:
# 1. Open the conflicted files
# 2. Edit to resolve conflicts
# 3. Remove conflict markers
# 4. git add resolved_file
# 5. git commit -m "Resolved merge conflicts"

# View conflict status
git status
git diff

# Use merge tools
git mergetool  # Opens configured merge tool
```

---

## P4.4: Working with Remotes

### Remote Commands

```bash
# Add a remote
git remote add origin https://github.com/username/repository.git

# View remotes
git remote -v

# Remove a remote
git remote remove origin

# Rename a remote
git remote rename origin upstream
```

### Pushing and Pulling

```bash
# Push to remote
git push origin main       # Push main to origin
git push -u origin main    # Set upstream and push

# Pull from remote
git pull origin main       # Fetch and merge

# Fetch only (download changes without merging)
git fetch origin

# Fetch and rebase (alternative to merge)
git pull --rebase origin main

# Push a branch to remote
git push origin branch-name

# Delete remote branch
git push origin --delete branch-name

# Push tags
git push --tags
```

### Working with Upstream

```bash
# Add upstream for forked repositories
git remote add upstream https://github.com/original/repository.git

# Fetch upstream changes
git fetch upstream

# Merge upstream changes
git checkout main
git merge upstream/main

# Rebase on upstream
git rebase upstream/main
```

---

## P4.5: Stashing and Tags

### Stashing Changes

```bash
# Save uncommitted changes
git stash                # Save with default message
git stash push -m "WIP: feature implementation"

# List stashes
git stash list

# Apply latest stash (keep in stash list)
git stash apply

# Apply and remove from stash list
git stash pop

# Apply specific stash
git stash apply stash@{2}

# Show stash contents
git stash show -p stash@{0}

# Remove a stash
git stash drop stash@{0}

# Clear all stashes
git stash clear
```

### Tags

```bash
# Create lightweight tag
git tag v1.0.0

# Create annotated tag (with message)
git tag -a v1.0.0 -m "Release version 1.0.0"

# List tags
git tag -l

# Push tags
git push origin v1.0.0
git push origin --tags    # Push all tags

# Delete tag
git tag -d v1.0.0
git push origin --delete v1.0.0

# Checkout tag
git checkout v1.0.0
```

---

## P4.6: Advanced Git Techniques

### Interactive Rebase

```bash
# Rebase last 3 commits interactively
git rebase -i HEAD~3

# Interactive rebase options:
# pick: Use commit as-is
# reword: Change commit message
# edit: Modify commit content
# squash: Combine with previous commit
# fixup: Combine with previous commit (discard message)
# drop: Remove commit

# Example: Squash commits
# pick abc1234 First commit
# squash def5678 Second commit
# ghi9012 Third commit
# → Squashes three commits into one
```

### Cherry-Picking

```bash
# Apply a specific commit to current branch
git cherry-pick commit_hash

# Cherry-pick with edit
git cherry-pick -e commit_hash

# Cherry-pick range of commits
git cherry-pick start_hash..end_hash
```

### Bisect (Finding Bugs)

```bash
# Start bisect session
git bisect start

# Mark current commit as bad
git bisect bad

# Mark known good commit
git bisect good commit_hash

# Git will check out commits between good and bad
# After each checkout, test the code and mark:
git bisect good   # If this commit works
git bisect bad    # If this commit is broken

# End bisect session
git bisect reset
```

### Reflog (Recovery)

```bash
# View reflog (all HEAD changes)
git reflog

# Recover lost commit
git checkout HEAD@{2}     # Go to specific reflog entry

# Create branch from lost commit
git branch recovered-branch HEAD@{2}
```

---

## P4.7: Data Science-Specific Git Practices

### .gitignore for Data Science Projects

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so

# Virtual Environments
venv/
env/
.env/
.venv/

# Data files (large)
*.csv
*.parquet
*.feather
*.h5
*.pickle
*.pkl
*.joblib

# Data directories
data/raw/
data/processed/
data/external/
*.db
*.sqlite3

# Models
models/
*.h5
*.pt
*.pth
*.onnx

# Jupyter Notebooks (optional - sometimes you want to track these)
# *.ipynb
.ipynb_checkpoints/

# Logs
logs/
*.log

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Environment variables
.env
.env.local

# Reports and figures
reports/
figures/
*.png
*.jpg
*.jpeg
*.pdf

# Build artifacts
dist/
build/
*.egg-info/

# Testing
.pytest_cache/
.coverage
htmlcov/
.tox/

# Secret keys
secrets.yaml
config/local.yaml
```

### .gitattributes for Data Science

```gitignore
# Ensure line endings are consistent
* text=auto

# Mark large files as binary to avoid unnecessary diffs
*.parquet binary
*.feather binary
*.h5 binary
*.pickle binary
*.pkl binary
*.joblib binary
*.png binary
*.jpg binary
*.jpeg binary
*.pdf binary

# Handle Jupyter notebooks
*.ipynb diff=ipynb

# Set language for syntax highlighting
*.py linguist-language=Python
*.ipynb linguist-language=Jupyter Notebook
*.R linguist-language=R
```

### Data Version Control with DVC

```bash
# Install DVC
pip install dvc

# Initialize DVC
dvc init

# Add data to DVC
dvc add data/raw/dataset.csv

# Track DVC files in Git
git add data/raw/dataset.csv.dvc .gitignore
git commit -m "Added dataset to DVC"

# Push data to remote storage
dvc remote add -d myremote s3://mybucket/dvc-store
dvc push

# Pull data
dvc pull
```

---

## P4.8: Collaboration Workflows

### Feature Branch Workflow

```
main ────────────────────────────────────────────
        \                                        /
feature  ●──●──●──●──●──●──●──●──●──●──●──●──●
```

```bash
# 1. Start a new feature
git checkout -b feature/new-feature

# 2. Work on the feature (multiple commits)
git add .
git commit -m "Implemented feature part 1"
git commit -m "Implemented feature part 2"

# 3. Push feature branch
git push -u origin feature/new-feature

# 4. Create Pull Request on GitHub/GitLab

# 5. After review and approval
git checkout main
git pull origin main
git merge --no-ff feature/new-feature
git push origin main

# 6. Delete feature branch
git branch -d feature/new-feature
git push origin --delete feature/new-feature
```

### Git Flow Workflow

```
master ←───●───●───●───●───●
            \   \   \   \   \
develop     ●───●───●───●───●
              \   \   \   \
feature       ●───●───●───●
              /   /   /   /
release       ●───●───●
```

### Squash Merging

```bash
# Squash commits when merging (cleaner history)
git checkout main
git merge --squash feature/new-feature
git commit -m "Added new feature"

# Or use GitHub's "Squash and Merge" button
```

### Rebase vs Merge

```bash
# Rebase (cleaner history, linear)
git checkout feature
git rebase main
# Resolve conflicts if any
git push --force-with-lease

# Merge (preserves history)
git checkout main
git merge --no-ff feature
```

---

## P4.9: Common Git Workflows

### Daily Development Workflow

```bash
# Start of day
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/update-processing

# Work throughout the day
git add src/processing.py
git commit -m "Added new processing logic"
git add tests/test_processing.py
git commit -m "Added tests for processing"

# End of day - push changes
git push -u origin feature/update-processing

# Next day - incorporate main changes
git fetch origin
git rebase origin/main
# Resolve conflicts if any
git push --force-with-lease
```

### Hotfix Workflow

```bash
# Critical bug fix needed
git checkout main
git pull origin main

# Create hotfix branch
git checkout -b hotfix/critical-bug

# Fix the bug
git add src/buggy_file.py
git commit -m "Fixed critical bug in data ingestion"

# Deploy hotfix
git checkout main
git merge --no-ff hotfix/critical-bug
git push origin main

# Also merge into develop if using Git Flow
git checkout develop
git merge hotfix/critical-bug

# Clean up
git branch -d hotfix/critical-bug
```

### Release Workflow

```bash
# Create release branch
git checkout -b release/v1.2.0 develop

# Final preparations (version bumps, documentation)
git add VERSION
git commit -m "Bumped version to 1.2.0"

# Merge to main
git checkout main
git merge --no-ff release/v1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main --tags

# Merge back to develop
git checkout develop
git merge --no-ff release/v1.2.0
git push origin develop

# Clean up
git branch -d release/v1.2.0
```

---

## P4.10: Best Practices

### Commit Message Guidelines

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- style: Formatting, no code change
- refactor: Code restructuring
- test: Adding tests
- chore: Maintenance tasks

Example:
feat(etl): Add data validation step

Implement Pandera validation for sales data
- Added schema definition
- Added validation tests
- Added error handling

Closes #123
```

### Common Rules

```bash
# 1. Commit early, commit often
# 2. Write meaningful commit messages
# 3. Keep commits focused (single concern)
# 4. Don't commit large files (use DVC or Git LFS)
# 5. Pull before pushing
# 6. Never force push to main/master
# 7. Use branches for features and fixes
# 8. Review code before merging
# 9. Keep your fork/repo up to date
# 10. Use .gitignore properly
```

---

## P4.11: Git LFS (Large File Storage)

### Installation

```bash
# Install Git LFS
# Ubuntu/Debian
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt-get install git-lfs

# macOS
brew install git-lfs

# Initialize Git LFS
git lfs install
```

### Using Git LFS

```bash
# Track specific file types
git lfs track "*.h5"
git lfs track "*.parquet"
git lfs track "*.pickle"

# Track specific files
git lfs track "data/large_file.csv"

# Track folder
git lfs track "models/*"

# View tracked patterns
git lfs track

# Push LFS files
git add .gitattributes
git add data/large_file.csv
git commit -m "Added large file with LFS"
git push origin main

# Pull LFS files
git lfs pull
```

---

## P4.12: Git Aliases (Time Savers)

```bash
# Create aliases for common commands
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'

# Advanced aliases
git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.wip "commit -m 'WIP: $(date +%Y-%m-%d)'"

# Usage
git st          # git status
git co feature  # git checkout feature
git lg          # Pretty log
```

---

## P4.13: Troubleshooting

### Common Errors and Solutions

```bash
# Error: "Please make sure you have the correct access rights"
# Solution: Check SSH keys
ssh -T git@github.com

# Error: "Updates were rejected because the remote contains work"
# Solution: Pull first
git pull origin main --rebase

# Error: "You have divergent branches"
# Solution: Merge or rebase
git pull origin main
git merge origin/main  # or git rebase origin/main

# Error: "Cannot delete branch (not fully merged)"
# Solution: Force delete
git branch -D branch-name

# Error: "Detached HEAD state"
# Solution: Create branch or switch back
git checkout main
git branch temp-branch  # Save work if needed

# Lost commits? Check reflog
git reflog
git checkout HEAD@{2}

# Undo git push
git reset --hard HEAD~1
git push origin main --force  # Use with caution!
```

---

## P4.14: Practice Exercises

### Exercise 1: Basic Workflow

```bash
"""
Exercise: Create a repository and complete basic workflow
"""

# 1. Create a new directory and initialize git
mkdir data_analysis_project
cd data_analysis_project
git init

# 2. Create a Python script
echo "print('Hello, World!')" > main.py

# 3. Create a README
echo "# Data Analysis Project" > README.md

# 4. Stage and commit
git add main.py README.md
git commit -m "Initial commit: added main.py and README"

# 5. Make changes and commit
echo "print('Welcome to data analysis')" > main.py
git add main.py
git commit -m "Updated main.py with welcome message"

# 6. View history
git log --oneline
```

### Exercise 2: Branching

```bash
"""
Exercise: Work with branches
"""

# 1. Create and switch to a feature branch
git checkout -b feature/add-data-cleaning

# 2. Add a data cleaning module
echo "def clean_data(df): return df.dropna()" > cleaning.py
git add cleaning.py
git commit -m "feat: Added data cleaning function"

# 3. Add tests
echo "def test_clean_data(): pass" > test_cleaning.py
git add test_cleaning.py
git commit -m "test: Added tests for cleaning"

# 4. Merge back to main
git checkout main
git merge --no-ff feature/add-data-cleaning

# 5. Delete feature branch
git branch -d feature/add-data-cleaning
```

### Exercise 3: Collaboration Simulation

```bash
"""
Exercise: Simulate collaboration with remote
"""

# 1. Create a GitHub repository (or use local remote)
git remote add origin https://github.com/username/repo.git

# 2. Push main
git push -u origin main

# 3. Create a branch for a feature
git checkout -b feature/eda
git add analysis.ipynb
git commit -m "feat: Added EDA notebook"

# 4. Push branch
git push -u origin feature/eda

# 5. Simulate PR and merge
git checkout main
git merge --squash feature/eda
git commit -m "Added EDA notebook (squashed)"
git push origin main
```

---

## P4.15: Quick Reference

### Most Common Commands

| Command | Description |
|---------|-------------|
| `git init` | Initialize repository |
| `git clone URL` | Clone remote repository |
| `git status` | Show working directory status |
| `git add FILE` | Stage file for commit |
| `git commit -m "MSG"` | Commit staged changes |
| `git push origin BRANCH` | Push to remote |
| `git pull origin BRANCH` | Pull from remote |
| `git branch` | List branches |
| `git checkout BRANCH` | Switch branch |
| `git checkout -b BRANCH` | Create and switch branch |
| `git merge BRANCH` | Merge branch |
| `git log` | Show commit history |
| `git diff` | Show changes |
| `git stash` | Stash changes |
| `git reset HEAD~1` | Undo last commit |
| `git revert HASH` | Revert commit |

### Visual Cheat Sheet

```
         git add          git commit          git push
    [Working]  →  [Staging]  →  [Local]  →  [Remote]
         ↓                   ↓                  ↓
    git checkout        git reset          git pull
    (discard)           (unstage)          (fetch+merge)

    git branch → List/Create branches
    git checkout → Switch branches
    git merge → Combine branches
    git stash → Save temporary work
```

---

**[PRIMER 4 COMPLETE]**  
**[ALL PRIMERS COMPLETE]**

---

## 📚 Complete Primer Series Summary

| Primer | Topic | Status |
|--------|-------|--------|
| Primer 1 | SQL Fundamentals | ✅ Complete |
| Primer 2 | Python for Data Science | ✅ Complete |
| Primer 3 | Statistics Essentials | ✅ Complete |
| Primer 4 | Git & Version Control | ✅ Complete |

---

## 🎯 What's Next?

With all primers complete, you're ready to dive into the main series:

**Phase 1: Data Processing, Storage & Validation**  
→ Module 1.1: Modern DataFrame Engines & Vectorization

**Phase 2: Exploratory Data Analysis & Visualization**  
→ Module 2.1: Systematic EDA & Data Profiling

**Phase 3: Applied Statistics & Hypothesis Testing**  
→ Module 3.1: Descriptive & Inferential Foundations
