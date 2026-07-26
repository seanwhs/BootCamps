# Quiz Bank with Answer Keys  
## Mastering Version Control from Local to Production

Use this bank for quizzes, workshops, review sessions, or assessments.

---

# Section 1: Multiple Choice

## Q1. What is Git?

A. A cloud hosting website only  
B. A local version-control system  
C. A code editor  
D. A programming language  

**Answer:** B

---

## Q2. What does GitHub primarily provide?

A. A replacement for Git  
B. A hosted collaboration platform for Git repositories  
C. A local text editor  
D. An operating system terminal  

**Answer:** B

---

## Q3. Which Git area contains files currently being edited?

A. Remote repository  
B. Staging area  
C. Working directory  
D. Reflog  

**Answer:** C

---

## Q4. Which command moves file changes into the staging area?

A. `git commit`  
B. `git push`  
C. `git add`  
D. `git merge`  

**Answer:** C

---

## Q5. Which command creates a commit from staged changes?

A. `git commit -m "message"`  
B. `git stage`  
C. `git save`  
D. `git publish`  

**Answer:** A

---

## Q6. What does `git diff` normally show?

A. Differences between staging area and latest commit  
B. Differences between working directory and staging area  
C. Differences between local branch and GitHub  
D. A list of branches  

**Answer:** B

---

## Q7. What does `git diff --staged` show?

A. Changes that will be included in the next commit  
B. Changes on GitHub only  
C. All repository history  
D. Untracked files only  

**Answer:** A

---

## Q8. What does `git status` help you identify?

A. Only commit messages  
B. Current branch and file-change state  
C. GitHub Actions workflow results only  
D. Node.js version only  

**Answer:** B

---

## Q9. What is a Git branch?

A. A separate full copy of every project file  
B. A lightweight pointer to a commit  
C. A GitHub Issue  
D. A backup archive  

**Answer:** B

---

## Q10. Which command creates and switches to a new branch?

A. `git merge -c branch-name`  
B. `git switch -c branch-name`  
C. `git branch --delete branch-name`  
D. `git commit -c branch-name`  

**Answer:** B

---

## Q11. What is a fast-forward merge?

A. A merge that deletes all old commits  
B. A merge where Git moves a branch pointer forward without creating a merge commit  
C. A merge conflict resolution strategy  
D. A forced remote push  

**Answer:** B

---

## Q12. What does a merge conflict mean?

A. Git is permanently broken  
B. Git detected two edits it cannot safely combine automatically  
C. GitHub is offline  
D. A branch was deleted  

**Answer:** B

---

## Q13. Which command cancels an unfinished merge?

A. `git merge --stop`  
B. `git merge --abort`  
C. `git merge --delete`  
D. `git merge --reset`  

**Answer:** B

---

## Q14. Why can rebasing be risky on shared branches?

A. It deletes GitHub repositories  
B. It rewrites commit hashes and can disrupt collaborators  
C. It always removes tests  
D. It disables pull requests  

**Answer:** B

---

## Q15. What is the conventional name for a repository’s primary remote?

A. `main`  
B. `upstream`  
C. `origin`  
D. `remote`  

**Answer:** C

---

## Q16. What does `origin/main` represent?

A. The actual GitHub branch directly  
B. A local remote-tracking reference for the last known remote `main` state  
C. A local uncommitted branch  
D. A GitHub Issue label  

**Answer:** B

---

## Q17. What does `git fetch origin` do?

A. Downloads remote information without integrating it into the current branch  
B. Deletes remote branches  
C. Pushes commits to GitHub  
D. Creates a release tag  

**Answer:** A

---

## Q18. What does `git pull` generally do?

A. Creates a new repository  
B. Fetches remote changes and integrates them  
C. Deletes all untracked files  
D. Creates a GitHub Issue  

**Answer:** B

---

## Q19. What should you use before changing `main` locally?

A. `git reset --hard`  
B. `git pull --ff-only`  
C. `git push --force`  
D. `git clean -fdx`  

**Answer:** B

---

## Q20. What is `.gitignore` used for?

A. Encrypting repository files  
B. Preventing matching untracked files from being added accidentally  
C. Deleting tracked secrets from history  
D. Creating GitHub Actions workflows  

**Answer:** B

---

## Q21. Which file should usually be ignored?

A. `README.md`  
B. `src/releaseNotes.js`  
C. `.env`  
D. `package.json`  

**Answer:** C

---

## Q22. Which statement about `.gitignore` is true?

A. It deletes already committed files from history  
B. It prevents GitHub from seeing secrets already pushed  
C. It only affects files Git is not already tracking  
D. It automatically rotates leaked tokens  

**Answer:** C

---

## Q23. What should happen first if a real API token is committed?

A. Delete the repository  
B. Rotate or revoke the token  
C. Run `git gc --aggressive`  
D. Rename the branch  

**Answer:** B

---

## Q24. What is a pull request?

A. A request to download a repository  
B. A proposal to merge one branch into another  
C. A local Git backup  
D. A type of Git tag  

**Answer:** B

---

## Q25. What should a good GitHub Issue include?

A. Only a title  
B. A password for testing  
C. Problem context and acceptance criteria  
D. A force-push command  

**Answer:** C

---

## Q26. Which review label usually means work must be changed before merging?

A. `praise:`  
B. `nit:`  
C. `suggestion:`  
D. `blocking:`  

**Answer:** D

---

## Q27. What does CI stand for?

A. Code Index  
B. Continuous Integration  
C. Commit Interface  
D. Collaborative Issue  

**Answer:** B

---

## Q28. Why does CI run tests in a fresh environment?

A. To hide errors  
B. To ensure the project does not depend on uncommitted local setup  
C. To delete branches  
D. To replace GitHub Issues  

**Answer:** B

---

## Q29. What is the safest default permission for a test-only GitHub Actions workflow?

A. `permissions: write-all`  
B. `permissions: admin`  
C. `permissions: contents: read`  
D. No permissions section and broad defaults  

**Answer:** C

---

## Q30. What does `git stash` do?

A. Deletes a branch  
B. Temporarily shelves unfinished work  
C. Publishes a release  
D. Renames a remote  

**Answer:** B

---

## Q31. What does `git reflog` help you inspect?

A. Current GitHub labels  
B. Recent reference movements, including previous HEAD positions  
C. Only remote repository permissions  
D. npm package versions  

**Answer:** B

---

## Q32. What does `git cherry-pick <hash>` do?

A. Deletes a commit  
B. Applies one selected commit onto the current branch  
C. Creates a new GitHub repository  
D. Squashes all branch commits  

**Answer:** B

---

## Q33. Which reset mode keeps changes staged?

A. `git reset --hard`  
B. `git reset --mixed`  
C. `git reset --soft`  
D. `git reset --delete`  

**Answer:** C

---

## Q34. Which reset mode is most dangerous?

A. `git reset --soft`  
B. `git reset --mixed`  
C. `git reset --hard`  
D. `git reset --safe`  

**Answer:** C

---

## Q35. What is an annotated tag commonly used for?

A. Ignoring files  
B. Marking a release commit with metadata and a message  
C. Deleting old commits  
D. Creating a merge conflict  

**Answer:** B

---

## Q36. What does Semantic Versioning format look like?

A. `release-2026-final`  
B. `MAJOR.MINOR.PATCH`  
C. `branch/feature/name`  
D. `commit-hash-date`  

**Answer:** B

---

## Q37. Which change normally requires a MAJOR version increase?

A. A typo fix  
B. A backward-compatible bug fix  
C. A breaking API change  
D. Documentation-only changes  

**Answer:** C

---

## Q38. What does `git revert <hash>` do?

A. Erases the commit from all history  
B. Creates a new commit that undoes the target commit’s changes  
C. Deletes the remote repository  
D. Changes the default branch  

**Answer:** B

---

## Q39. What is the first command to run when Git state is confusing?

A. `git push --force`  
B. `git reset --hard`  
C. `git status`  
D. `git clean -fdx`  

**Answer:** C

---

## Q40. What is the primary purpose of `CODEOWNERS`?

A. Store passwords for owners  
B. Route reviews for selected paths to responsible users or teams  
C. Replace branch protection  
D. Automatically merge pull requests  

**Answer:** B

---

# Section 2: True or False

## Q41. GitHub is required to use Git locally.

**Answer:** False

---

## Q42. A commit automatically includes every changed file in the working directory.

**Answer:** False

---

## Q43. `git diff --staged` is useful before committing.

**Answer:** True

---

## Q44. A branch is a full duplicate copy of the repository.

**Answer:** False

---

## Q45. Merge conflicts must always be solved by keeping the current branch version.

**Answer:** False

---

## Q46. `git fetch` changes the current working files immediately.

**Answer:** False

---

## Q47. `.gitignore` can remove a secret from a commit already pushed to GitHub.

**Answer:** False

---

## Q48. A Personal Access Token should be treated like a password.

**Answer:** True

---

## Q49. Pull requests are only useful for large code changes.

**Answer:** False

---

## Q50. A passing CI workflow proves that a change has no possible defects.

**Answer:** False

---

## Q51. It is generally safe to use `git push --force` on shared `main`.

**Answer:** False

---

## Q52. `git stash` is a good long-term archive for important work.

**Answer:** False

---

## Q53. Reflog can help recover commits after some resets or branch deletions.

**Answer:** True

---

## Q54. `git reset --hard` can discard uncommitted working-directory changes.

**Answer:** True

---

## Q55. Release tags should normally point to a tested, intentional release commit.

**Answer:** True

---

## Q56. GitHub Actions workflow files should be reviewed like executable code.

**Answer:** True

---

## Q57. A private repository is an appropriate place to commit production secrets.

**Answer:** False

---

## Q58. A GitHub Environment can protect deployment secrets and require approval.

**Answer:** True

---

## Q59. `git revert` is usually safer than rewriting shared history after a bad commit reaches `main`.

**Answer:** True

---

## Q60. A mirror clone is useful before major migrations or history rewrites.

**Answer:** True

---

# Section 3: Fill in the Blank

## Q61. Git’s three local areas are the working directory, the staging area, and the ____________________.

**Answer:** local repository

---

## Q62. The command used to inspect repository state is:

```bash
git ____________________
```

**Answer:** `status`

---

## Q63. The command that stages a file is:

```bash
git ____________________ README.md
```

**Answer:** `add`

---

## Q64. The command that creates a commit is:

```bash
git commit -m "____________________"
```

**Answer:** a meaningful commit message, such as `Add initial documentation`

---

## Q65. The conventional name for the primary remote is:

```text
____________________
```

**Answer:** `origin`

---

## Q66. The remote-tracking branch for the remote main branch is usually:

```text
____________________
```

**Answer:** `origin/main`

---

## Q67. The command that downloads remote information without changing local files is:

```bash
git ____________________ origin
```

**Answer:** `fetch`

---

## Q68. The command used to create and switch to a branch is:

```bash
git switch ____________________ feature/add-export
```

**Answer:** `-c`

---

## Q69. The command used to inspect recent reference movements is:

```bash
git ____________________
```

**Answer:** `reflog`

---

## Q70. The file used to define ignored paths is:

```text
____________________
```

**Answer:** `.gitignore`

---

## Q71. The Git command that safely removes an unwanted unstaged file change is:

```bash
git ____________________ README.md
```

**Answer:** `restore`

---

## Q72. The command that unstages a file but keeps its local edits is:

```bash
git restore ____________________ README.md
```

**Answer:** `--staged`

---

## Q73. A GitHub-hosted proposal to merge a branch is called a:

```text
____________________
```

**Answer:** Pull Request / PR

---

## Q74. The GitHub automation platform used for CI is:

```text
GitHub ____________________
```

**Answer:** Actions

---

## Q75. The standard test command for the tutorial Node.js project is:

```bash
____________________
```

**Answer:** `npm test`

---

## Q76. A release version commonly follows:

```text
____________________ . ____________________ . ____________________
```

**Answer:** MAJOR, MINOR, PATCH

---

## Q77. The Git command that creates an annotated tag is:

```bash
git tag ____________________ v1.0.0 -m "Release version 1.0.0"
```

**Answer:** `-a`

---

## Q78. The command that creates a new commit undoing a bad shared commit is:

```bash
git ____________________ <commit-hash>
```

**Answer:** `revert`

---

## Q79. The first response to an exposed secret should be to:

```text
____________________ or ____________________ the credential.
```

**Answer:** revoke, rotate

---

## Q80. The GitHub file that can assign review responsibility by path is:

```text
____________________
```

**Answer:** `CODEOWNERS`

---

# Section 4: Short Answer Questions

## Q81. Explain the difference between `git diff` and `git diff --staged`.

**Answer key:**  
`git diff` compares the working directory with the staging area, showing unstaged changes. `git diff --staged` compares the staging area with the latest commit, showing what the next commit will contain.

---

## Q82. Why should a developer use feature branches instead of committing directly to `main`?

**Answer key:**  
Feature branches isolate work, protect stable `main`, make review easier, reduce risk, allow CI and discussion before merge, and make it easier to abandon or revise incomplete work.

---

## Q83. Describe the safe workflow for resolving a merge conflict.

**Answer key:**  
Run `git status`, inspect conflicting files and markers, edit the file to the intended final content, remove all markers, run validation such as `git diff --check` and tests, stage resolved files with `git add`, then complete the merge using `git commit` or continue the rebase with `git rebase --continue`.

---

## Q84. What is the difference between `git fetch` and `git pull`?

**Answer key:**  
`git fetch` downloads commits and updates remote-tracking references without changing the current local branch or working files. `git pull` fetches and then integrates remote changes into the current branch, typically by merge or rebase depending on configuration.

---

## Q85. Why is `git push --force-with-lease` safer than `git push --force`?

**Answer key:**  
`--force-with-lease` checks that the remote branch is still in the expected state before overwriting it. It helps prevent overwriting commits pushed by someone else that are not present locally. It should still only be used on personal or coordinated branches.

---

## Q86. Why does `.gitignore` not solve a secret that was already committed?

**Answer key:**  
`.gitignore` affects future untracked files. A previously committed file remains in Git tracking and may remain in history. The secret must be revoked or rotated first, removed from current files, and possibly removed from history through a coordinated rewrite if required.

---

## Q87. What should a good pull request description include?

**Answer key:**  
A clear summary, linked issue if applicable, meaningful list of changes, verification commands or manual checks, risk notes, and review focus for complex or sensitive areas.

---

## Q88. What is the difference between a commit, a tag, and a GitHub Release?

**Answer key:**  
A commit is a Git snapshot. A tag is a stable Git reference pointing to a commit, often used for releases. A GitHub Release is a GitHub publication page built around a tag, with release notes and optional downloadable assets.

---

## Q89. When should `git revert` be preferred over `git reset --hard`?

**Answer key:**  
Use `git revert` for bad commits already shared or pushed to a shared branch such as `main`. It creates a new auditable commit that undoes changes without rewriting history. `git reset --hard` is primarily for disposable local history and can discard work.

---

## Q90. What does a code review provide that CI does not?

**Answer key:**  
CI validates configured automated checks. Code review provides human judgment about requirements, design, clarity, maintainability, security implications, scope, user impact, and project conventions.

---

# Section 5: Scenario Questions

## Q91. Scenario: You edited `README.md`, then tried `git switch main`. Git says your local changes would be overwritten. What should you do?

**Answer key:**  
Do not discard work immediately. Run `git status` and `git diff`. If the work is ready, stage and commit it. If unfinished but valuable, stash it using `git stash push --include-untracked -m "message"`. If definitely unwanted, inspect it first and then use `git restore README.md`.

---

## Q92. Scenario: You pushed a Personal Access Token to GitHub. What is the correct first action?

**Answer key:**  
Immediately revoke or rotate the token in GitHub or the relevant provider. Then contain affected systems, remove the token from current files, add ignore rules if appropriate, create a private incident record, and determine whether history cleanup is required.

---

## Q93. Scenario: Your feature branch is behind `main`, and GitHub requires branches to be up to date before merge. What is a safe default workflow?

**Answer key:**  

```bash
git switch feature/short-description
git fetch origin
git merge origin/main
npm test
git push
```

For a personal branch, rebasing may be appropriate if team policy allows it:

```bash
git rebase origin/main
git push --force-with-lease
```

---

## Q94. Scenario: CI fails because a test expects `# Release 9.9.9`, but the formatter returns `# Release 1.0.0`. What should you do?

**Answer key:**  
Inspect the test and intended behavior. If the formatter’s output is correct and the test expectation is intentionally wrong, restore the correct expected value. Do not change production code merely to satisfy a broken test. Run tests locally, commit the correction, and push.

---

## Q95. Scenario: You deleted a local branch containing unmerged work. How can you attempt recovery?

**Answer key:**  

```bash
git reflog --all --oneline
git switch -c recovery/lost-work <commit-hash>
git log --oneline main..HEAD
```

Find the branch’s last commit in reflog, create a recovery branch pointing to it, then inspect and preserve the work.

---

## Q96. Scenario: A teammate force-pushed incorrect history to `main`. What should happen first?

**Answer key:**  
Stop further pushes, capture current state, inspect reflog, mirror backups, and other clones for the last known-good commit. Coordinate recovery with maintainers. Do not immediately force-push another guess. Restore only after identifying the correct commit and communicating with contributors.

---

## Q97. Scenario: A workflow only runs tests but uses `permissions: write-all`. What review feedback is appropriate?

**Answer key:**  
A blocking security comment. The workflow should use least privilege, typically:

```yaml
permissions:
  contents: read
```

Explain that broad write access is unnecessary and increases risk.

---

## Q98. Scenario: A pull request changes formatter logic, documentation, CI permissions, a dependency, and unrelated formatting. What should the reviewer recommend?

**Answer key:**  
Request that unrelated concerns be split into focused commits or separate pull requests. Formatter logic and tests may belong together; CI permission changes, dependency updates, and broad formatting should receive focused review because they have different risk profiles.

---

## Q99. Scenario: You need to inspect an older version of `README.md` without changing current files. What command can you use?

**Answer key:**  

```bash
git show HEAD~1:README.md
```

Or replace `HEAD~1` with a specific commit hash or tag.

---

## Q100. Scenario: A project is moving to a new GitHub organization. What preparation is recommended?

**Answer key:**  
Create a migration inventory, create a mirror backup, record remotes, branch rules, workflows, secrets, environments, integrations, access, tags, releases, and documentation links. Perform the transfer, update remotes, verify history and settings, test CI, and communicate local update instructions to contributors.

---

# Section 6: Practical Command Tasks

## Q101. Write commands to create a feature branch named `feature/add-export`.

**Answer key:**

```bash
git switch main
git pull --ff-only
git switch -c feature/add-export
```

---

## Q102. Write commands to inspect a feature branch before opening a pull request.

**Answer key:**

```bash
git status
git diff main...HEAD
git diff --check
git log --oneline main..HEAD
npm test
```

---

## Q103. Write commands to safely update local `main`.

**Answer key:**

```bash
git switch main
git pull --ff-only
git status
```

---

## Q104. Write commands to inspect incoming changes before integrating them.

**Answer key:**

```bash
git fetch origin
git log --oneline main..origin/main
git diff main..origin/main
```

---

## Q105. Write commands to create and inspect a stash.

**Answer key:**

```bash
git stash push --include-untracked -m "Temporary safety snapshot"
git stash list
git stash show --patch stash@{0}
```

---

## Q106. Write commands to restore a stash but keep the stash entry.

**Answer key:**

```bash
git stash apply stash@{0}
```

---

## Q107. Write commands to restore a stash and remove the stash entry.

**Answer key:**

```bash
git stash pop
```

---

## Q108. Write commands to create a recovery branch from a reflog commit.

**Answer key:**

```bash
git reflog --date=local -20
git switch -c recovery/lost-work <commit-hash>
```

---

## Q109. Write commands to create and push an annotated release tag.

**Answer key:**

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

---

## Q110. Write a minimal safe GitHub Actions permissions block for a test-only workflow.

**Answer key:**

```yaml
permissions:
  contents: read
```

---

# Section 7: Instructor Scoring Guide

| Section | Suggested points |
|---|---:|
| Multiple choice: Q1–Q40 | 40 points |
| True/False: Q41–Q60 | 20 points |
| Fill in blank: Q61–Q80 | 20 points |
| Short answer: Q81–Q90 | 20 points |
| Scenarios: Q91–Q100 | 30 points |
| Practical commands: Q101–Q110 | 20 points |
| **Total** | **150 points** |

## Suggested Performance Levels

| Score | Level |
|---:|---|
| 135–150 | Advanced / Ready for production workflows |
| 115–134 | Proficient / Ready for team collaboration |
| 90–114 | Developing / Needs more guided practice |
| Below 90 | Beginner / Repeat local Git and branching labs |
