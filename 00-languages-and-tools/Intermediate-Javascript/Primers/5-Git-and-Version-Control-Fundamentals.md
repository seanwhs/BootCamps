# Primer 5: Git and Version Control Fundamentals

Git is a version-control system.

It records changes to files over time so you can:

- Create checkpoints.
- Compare versions.
- Undo mistakes.
- Experiment safely.
- Work on features in branches.
- Collaborate with other developers.
- Understand how a project evolved.

Git is optional for following the main tutorial, but it is one of the most useful tools in professional software development.

---

# 1. What Git Does

## The Target

Understand the role of Git.

## The Concept

Git is like a timeline of project snapshots.

Without Git:

```text
project-final/
project-final-2/
project-final-really-final/
project-final-fixed/
project-final-fixed-new/
```

With Git:

```text
One project directory
        ↓
Commit 1
        ↓
Commit 2
        ↓
Commit 3
```

Each commit records a meaningful point in the project’s history.

A commit is not automatically a backup of every file on your computer. It records the files and changes you explicitly stage and commit.

## The Implementation

Move into the project directory:

```bash
cd path/to/async-task-manager
```

Verify:

### macOS/Linux

```bash
pwd
```

### Windows PowerShell

```powershell
Get-Location
```

## The Verification

The current directory should end with:

```text
async-task-manager
```

[COMPLETED: Step 1 — Project directory selected]  
[STARTING: Step 2 — Check whether Git is installed]

---

# 2. Check Git Installation

## The Target

Verify that Git is available.

## The Concept

Git is installed as a command-line program. The `git` command gives you access to its features.

## The Implementation

Run:

```bash
git --version
```

Expected output resembles:

```text
git version 2.45.0
```

If Git is not installed, download it from:

```text
https://git-scm.com/downloads
```

On macOS, Git may also be installed through:

```bash
xcode-select --install
```

On Windows, install Git for Windows. This usually includes Git Bash and command-line Git support.

## The Verification

Run again:

```bash
git --version
```

A version number confirms that Git is available.

[COMPLETED: Step 2 — Git installation verified]  
[STARTING: Step 3 — Configure Git identity]

---

# 3. Configure Your Git Identity

## The Target

Configure the name and email Git records in commits.

## The Concept

Each commit records who created it.

The email does not have to be the email used for your computer account, but it should be an address you are comfortable associating with your commits.

## The Implementation

Set your global name:

```bash
git config --global user.name "Your Name"
```

Set your global email:

```bash
git config --global user.email "you@example.com"
```

Inspect the configuration:

```bash
git config --global --list
```

You can configure identity only for the current project by omitting `--global`:

```bash
git config user.name "Project Name"
git config user.email "project@example.com"
```

## The Verification

Run:

```bash
git config user.name
git config user.email
```

Git should print the configured values.

Do not commit passwords, access tokens, or other secrets into a repository.

[COMPLETED: Step 3 — Git identity configured]  
[STARTING: Step 4 — Initialize a repository]

---

# 4. Initialize a Repository

## The Target

Create a Git repository inside the project.

## The Concept

A repository is the project directory plus a hidden `.git` directory containing version history.

Initializing Git does not upload anything to the internet. It creates local version control only.

## The Implementation

From the project root, run:

```bash
git init
```

Git should report something similar to:

```text
Initialized empty Git repository
```

List hidden files.

### macOS/Linux

```bash
ls -la
```

### Windows PowerShell

```powershell
Get-ChildItem -Force
```

You should see:

```text
.git
```

## The Verification

Run:

```bash
git status
```

You should see a message similar to:

```text
On branch main

No commits yet

Untracked files:
```

The exact branch name may be `main` or `master`, depending on your Git configuration.

[COMPLETED: Step 4 — Local Git repository initialized]  
[STARTING: Step 5 — Create a `.gitignore` file]

---

# 5. Create `.gitignore`

## The Target

Create a file that tells Git which files not to track.

## The Concept

Some files should not be committed because they are:

- Operating-system metadata.
- Editor settings.
- Logs.
- Generated output.
- Dependencies.
- Secret configuration.
- Temporary files.

A `.gitignore` file is a filter list.

## The Implementation

Create:

### `.gitignore`

```gitignore
# Operating-system files
.DS_Store
Thumbs.db

# Editor settings
.vscode/
.idea/

# Logs
*.log

# Dependency directories
node_modules/

# Build output
dist/
build/
coverage/

# Environment files that may contain secrets
.env
.env.*
!.env.example

# Temporary tutorial files
*-demo.html
*-test.js
*-test.html
```

The exception:

```gitignore
!.env.example
```

means:

> Ignore environment files, except the safe example template.

## The Verification

Run:

```bash
git status
```

The `.gitignore` file should appear as an untracked file.

If you create a file named:

```text
debug.log
```

run:

```bash
git status
```

The log should not appear as an untracked file.

Remove the temporary log:

```bash
rm debug.log
```

On Windows PowerShell:

```powershell
Remove-Item debug.log
```

[COMPLETED: Step 5 — Ignore rules created]  
[STARTING: Step 6 — Understand Git status]

---

# 6. Read Git Status

## The Target

Understand the current state of the repository.

## The Concept

`git status` is one of the most important Git commands.

It tells you:

- Which branch you are on.
- Which files are untracked.
- Which tracked files changed.
- Which files are staged.
- Whether the working tree is clean.

Think of the project as having three areas:

```text
Working directory
        ↓ git add
Staging area
        ↓ git commit
Repository history
```

## The Implementation

Run:

```bash
git status
```

Create a temporary file:

### `status-demo.txt`

```text
This file demonstrates Git status.
```

Run:

```bash
git status
```

The file should appear as untracked.

## The Verification

You should see a section similar to:

```text
Untracked files:
  status-demo.txt
```

Git knows that the file exists, but it is not yet included in the next commit.

Remove the temporary file after testing:

```bash
rm status-demo.txt
```

Windows PowerShell:

```powershell
Remove-Item status-demo.txt
```

[COMPLETED: Step 6 — Repository status inspected]  
[STARTING: Step 7 — Stage files]

---

# 7. Stage Files

## The Target

Move project files into the staging area.

## The Concept

Staging is like preparing a package before sealing it.

You choose exactly which changes belong in the next commit.

Stage one file:

```bash
git add index.html
```

Stage several files:

```bash
git add index.html styles.css
```

Stage all non-ignored changes:

```bash
git add .
```

The dot means:

> Use the current directory.

## The Implementation

Run:

```bash
git add .
```

Then inspect:

```bash
git status
```

## The Verification

Files should appear under a section similar to:

```text
Changes to be committed:
```

This means they are staged and ready for a commit.

To inspect staged differences:

```bash
git diff --staged
```

Review this output before committing.

[COMPLETED: Step 7 — Project files staged]  
[STARTING: Step 8 — Create the first commit]

---

# 8. Create a Commit

## The Target

Create the first project checkpoint.

## The Concept

A commit records the staged state with a message.

A good commit message describes the completed change:

```text
Create initial task manager structure
```

A weak message:

```text
stuff
```

Commit messages should make the project history understandable later.

## The Implementation

Run:

```bash
git commit -m "Create initial task manager structure"
```

Git should report the number of files and changes committed.

Inspect status:

```bash
git status
```

## The Verification

You should see something similar to:

```text
nothing to commit, working tree clean
```

Inspect the history:

```bash
git log --oneline
```

Expected output resembles:

```text
abc1234 Create initial task manager structure
```

The hash will be different on your computer.

[COMPLETED: Step 8 — First Git commit created]  
[STARTING: Step 9 — Modify a tracked file]

---

# 9. Modify a Tracked File

## The Target

Observe how Git detects changes after a commit.

## The Implementation

Edit `index.html` and change:

```html
<title>Local Development Test</title>
```

to:

```html
<title>Async Task Manager</title>
```

Save the file.

Run:

```bash
git status
```

Inspect the unstaged difference:

```bash
git diff
```

## The Verification

`git status` should show:

```text
Changes not staged for commit
```

`git diff` should show the changed line.

A typical diff looks like:

```diff
-<title>Local Development Test</title>
+<title>Async Task Manager</title>
```

This is useful because it lets you review exactly what changed before staging it.

[COMPLETED: Step 9 — File modification inspected]  
[STARTING: Step 10 — Stage and commit a feature]

---

# 10. Stage and Commit a Feature

## The Target

Commit the title change.

## The Concept

A commit should represent a coherent unit of work.

For the main series, useful commits might be:

```text
Create synchronous task rendering
Add callback-based task loading
Replace callbacks with Promises
Add Task class
Create modular architecture
Persist tasks in localStorage
```

## The Implementation

Stage the changed file:

```bash
git add index.html
```

Review staged changes:

```bash
git diff --staged
```

Commit:

```bash
git commit -m "Update application page title"
```

Inspect history:

```bash
git log --oneline
```

## The Verification

You should now see two commits:

```text
<new-hash> Update application page title
<old-hash> Create initial task manager structure
```

Run:

```bash
git status
```

The working tree should be clean.

[COMPLETED: Step 10 — A feature commit created]  
[STARTING: Step 11 — Compare project history]

---

# 11. Inspect Git History

## The Target

Review previous commits.

## The Implementation

Show concise history:

```bash
git log --oneline
```

Show detailed history:

```bash
git log
```

Show the latest commit:

```bash
git show HEAD
```

Show a specific commit:

```bash
git show <commit-hash>
```

The special name `HEAD` means:

> The current commit.

Show the previous commit:

```bash
git show HEAD~1
```

## The Verification

Run:

```bash
git log --oneline --decorate --graph --all
```

You should see a small history graph.

For two linear commits, it may look like:

```text
* abc1234 (HEAD -> main) Update application page title
* def5678 Create initial task manager structure
```

[COMPLETED: Step 11 — Git history inspected]  
[STARTING: Step 12 — Revert an uncommitted change]

---

# 12. Discard an Uncommitted File Change

## The Target

Restore a tracked file to its last committed state.

## The Concept

Sometimes an experiment damages a file before it has been committed.

If you want to discard that uncommitted change, restore the file from the latest commit.

This permanently removes the uncommitted changes to that file, so inspect the diff first.

## The Implementation

Modify `index.html` temporarily:

```html
<h1>Temporary incorrect title</h1>
```

Run:

```bash
git diff
```

Confirm that the change is unwanted.

Restore the file:

```bash
git restore index.html
```

## The Verification

Run:

```bash
git diff
```

No output should appear for `index.html`.

Open the file and verify that it contains the last committed title.

[COMPLETED: Step 12 — Uncommitted changes restored]  
[STARTING: Step 13 — Unstage a file]

---

# 13. Unstage a File

## The Target

Remove a file from the staging area without discarding its contents.

## The Concept

Staging and editing are separate operations.

A file can be:

```text
Modified but unstaged
Modified and staged
```

If you staged a file too early, unstage it while keeping the changes in your working directory.

## The Implementation

Modify `styles.css`, for example by adding:

```css
body {
  background: #f5f7fb;
}
```

Stage it:

```bash
git add styles.css
```

Check:

```bash
git status
```

Unstage it:

```bash
git restore --staged styles.css
```

## The Verification

Run:

```bash
git status
```

The file should now appear under:

```text
Changes not staged for commit
```

The CSS change should still exist in the file.

To discard the change entirely:

```bash
git restore styles.css
```

Only run that second command if you intentionally want to remove the change.

[COMPLETED: Step 13 — Staging and unstaging practiced]  
[STARTING: Step 14 — Create a feature branch]

---

# 14. Create a Feature Branch

## The Target

Create an isolated branch for a new feature.

## The Concept

A branch is an independent line of development.

Imagine the main project as a road:

```text
main ────────────────●
                     │
                     └── feature branch
```

You can experiment on the feature branch without changing the main branch until the feature is ready.

## The Implementation

Ensure the working tree is clean:

```bash
git status
```

Create and switch to a branch:

```bash
git switch -c add-task-count
```

Older Git versions may use:

```bash
git checkout -b add-task-count
```

Inspect the current branch:

```bash
git branch
```

## The Verification

The active branch should have an asterisk:

```text
* add-task-count
  main
```

[COMPLETED: Step 14 — Feature branch created]  
[STARTING: Step 15 — Commit a feature branch change]

---

# 15. Develop on a Feature Branch

## The Target

Add a small feature on the branch.

## The Implementation

Add a count to `index.html`:

```html
<p id="task-count">0 tasks</p>
```

Add a temporary script update to `js/main.js`:

```javascript
const taskCount = document.querySelector(
  "#task-count"
);

if (taskCount) {
  taskCount.textContent = "Feature branch is active.";
}
```

Save the files.

Stage and commit:

```bash
git add index.html js/main.js
git commit -m "Add task count placeholder"
```

Inspect history:

```bash
git log --oneline --decorate --graph --all
```

## The Verification

The branch should contain the new commit.

Check:

```bash
git status
```

The working tree should be clean.

[COMPLETED: Step 15 — Feature branch change committed]  
[STARTING: Step 16 — Switch between branches]

---

# 16. Switch Between Branches

## The Target

Move between the feature branch and `main`.

## The Concept

Switching branches changes the files in the working directory to match that branch’s latest commit.

## The Implementation

Switch to `main`:

```bash
git switch main
```

Older Git:

```bash
git checkout main
```

Inspect `index.html`.

Then switch back:

```bash
git switch add-task-count
```

## The Verification

On `main`, the feature-branch changes should not be present.

On `add-task-count`, the changes should return.

Check the current branch:

```bash
git branch --show-current
```

Expected values:

```text
main
```

or:

```text
add-task-count
```

[COMPLETED: Step 16 — Branch switching verified]  
[STARTING: Step 17 — Merge a feature branch]

---

# 17. Merge a Feature Branch

## The Target

Merge the completed feature into `main`.

## The Concept

Merging combines one branch’s commits into another branch.

The usual workflow is:

```text
Create feature branch
        ↓
Develop and test feature
        ↓
Commit feature
        ↓
Switch to main
        ↓
Merge feature
```

## The Implementation

Switch to `main`:

```bash
git switch main
```

Merge the branch:

```bash
git merge add-task-count
```

## The Verification

Inspect the project files and confirm the feature is now present on `main`.

Inspect history:

```bash
git log --oneline --decorate --graph --all
```

If Git reports a fast-forward merge, the history may remain linear.

You can delete the merged local branch:

```bash
git branch -d add-task-count
```

Confirm:

```bash
git branch
```

[COMPLETED: Step 17 — Feature branch merged]  
[STARTING: Step 18 — Resolve a merge conflict]

---

# 18. Understand Merge Conflicts

## The Target

Understand what happens when two branches modify the same lines.

## The Concept

A merge conflict occurs when Git cannot safely decide which change to keep.

Git marks the conflict in the file:

```text
<<<<<<< HEAD
Current branch version
=======
Incoming branch version
>>>>>>> feature-branch
```

You must choose the correct final content and remove the markers.

## The Implementation

Create a branch:

```bash
git switch -c conflict-demo
```

Edit `index.html` and change the heading:

```html
<h1>Feature branch heading</h1>
```

Commit:

```bash
git add index.html
git commit -m "Change heading on feature branch"
```

Switch to `main`:

```bash
git switch main
```

Change the same heading differently:

```html
<h1>Main branch heading</h1>
```

Commit:

```bash
git add index.html
git commit -m "Change heading on main branch"
```

Attempt the merge:

```bash
git merge conflict-demo
```

## The Verification

Git should report a conflict.

Check:

```bash
git status
```

It should identify `index.html` as conflicted.

Open `index.html`.

You may see:

```html
<<<<<<< HEAD
<h1>Main branch heading</h1>
=======
<h1>Feature branch heading</h1>
>>>>>>> conflict-demo
```

Choose one version or write a combined final version:

```html
<h1>Async Task Manager</h1>
```

Delete all conflict markers:

```text
<<<<<<<
=======
>>>>>>>
```

Stage the resolved file:

```bash
git add index.html
```

Complete the merge:

```bash
git commit -m "Resolve heading merge conflict"
```

Delete the demonstration branch:

```bash
git branch -d conflict-demo
```

## Important Recovery Command

If you want to cancel an in-progress merge before resolving it:

```bash
git merge --abort
```

[COMPLETED: Step 18 — Merge conflict resolved]  
[STARTING: Step 19 — Use Git diff effectively]

---

# 19. Compare Changes with `git diff`

## The Target

Compare working files and commits.

## The Implementation

Unstaged changes:

```bash
git diff
```

Staged changes:

```bash
git diff --staged
```

Compare two commits:

```bash
git diff HEAD~1 HEAD
```

Compare a file to its last commit:

```bash
git diff HEAD -- index.html
```

Compare branches:

```bash
git diff main..feature-branch
```

## The Verification

Make a small change to `styles.css`.

Run:

```bash
git diff
```

Review:

- Removed lines beginning with `-`.
- Added lines beginning with `+`.

Stage the change:

```bash
git add styles.css
```

Run:

```bash
git diff --staged
```

The same change should now appear in the staged diff.

[COMPLETED: Step 19 — Git differences inspected]  
[STARTING: Step 20 — Use tags for milestones]

---

# 20. Tag Tutorial Milestones

## The Target

Mark important project versions.

## The Concept

A tag is a permanent label attached to a commit.

Tags are useful for milestones such as:

```text
part-1-complete
part-2-complete
final-project
```

Unlike a branch, a tag generally identifies a fixed point rather than ongoing development.

## The Implementation

After ensuring the project is working:

```bash
git tag -a final-project -m "Complete final task manager"
```

List tags:

```bash
git tag
```

Inspect a tag:

```bash
git show final-project
```

## The Verification

The tag should appear:

```text
final-project
```

You can inspect the project at that commit:

```bash
git switch --detach final-project
```

Return to the main branch:

```bash
git switch main
```

Detached HEAD mode is useful for inspecting history. Do not create ongoing work there unless you know how to create a branch from it.

[COMPLETED: Step 20 — Project milestone tagged]  
[STARTING: Step 21 — Optional remote repository]

---

# 21. Connect a Remote Repository

## The Target

Understand how a local repository can connect to a hosting service.

## The Concept

A local Git repository exists on your computer.

A remote repository exists on a service such as:

- GitHub.
- GitLab.
- Bitbucket.
- A private company Git server.

A remote gives you:

- Off-device backup.
- Collaboration.
- Pull requests.
- Issue tracking.
- Continuous integration.
- A shareable project history.

Do not upload secrets or private data.

## The Implementation

Create an empty repository on your chosen Git hosting service.

Then add its URL:

```bash
git remote add origin https://github.com/your-name/async-task-manager.git
```

Inspect remotes:

```bash
git remote -v
```

Rename your current branch to `main` if necessary:

```bash
git branch -M main
```

Push the branch:

```bash
git push -u origin main
```

## The Verification

Refresh the remote repository page.

You should see:

- The project files.
- The commit history.
- The `README` if one exists.
- The `main` branch.

Do not place passwords or API keys in the repository.

[COMPLETED: Step 21 — Optional remote repository configured]  
[STARTING: Step 22 — Create a project README]

---

# 22. Create a `README.md`

## The Target

Document how to run the project.

## The Concept

A README is the project’s front door.

A good README explains:

- What the project does.
- How to run it.
- What tools are required.
- How the project is organized.
- How to test it.
- Important limitations.

## The Implementation

Create:

### `README.md`

```markdown
# Async Task Manager

A browser-based JavaScript task manager demonstrating:

- Callbacks
- Promises
- async/await
- Classes
- ES modules
- localStorage
- sessionStorage
- Error handling
- Separation of concerns

## Requirements

- A modern browser
- Python 3 or another local HTTP server

## Run locally

Start a server from the project root:

```bash
python3 -m http.server 8000
```

On Windows:

```powershell
python -m http.server 8000
```

Open:

```text
http://localhost:8000
```

## Project structure

```text
├── index.html
├── styles.css
└── js/
    ├── main.js
    ├── app.js
    ├── api/
    ├── models/
    ├── services/
    ├── ui/
    └── utils/
```

## Storage

Tasks are saved in localStorage.

The selected filter is saved in sessionStorage.

## Security notes

- User task titles are rendered with textContent.
- Browser storage is not used for secrets.
- External data should be validated before use.
```

Stage and commit:

```bash
git add README.md
git commit -m "Document local project setup"
```

## The Verification

Read the file:

```bash
cat README.md
```

Windows PowerShell:

```powershell
Get-Content README.md
```

A new developer should be able to follow the README and start the project.

[COMPLETED: Step 22 — Project documentation created]  
[STARTING: Step 23 — Use Git during the tutorial series]

---

# 23. Git Workflow for the Main Series

## The Target

Define a practical Git workflow for the tutorial.

## The Concept

Commit after each stable milestone.

Suggested workflow:

```text
Read a tutorial step
        ↓
Implement the step
        ↓
Run verification
        ↓
Fix problems
        ↓
Review git diff
        ↓
Commit the milestone
```

## Suggested Commits

```bash
git add .
git commit -m "Create initial project structure"
```

```bash
git add .
git commit -m "Add synchronous task rendering"
```

```bash
git add .
git commit -m "Add callback-based task loading"
```

```bash
git add .
git commit -m "Replace callbacks with Promises"
```

```bash
git add .
git commit -m "Add async await error handling"
```

```bash
git add .
git commit -m "Introduce Task class"
```

```bash
git add .
git commit -m "Split application into modules"
```

```bash
git add .
git commit -m "Persist tasks in localStorage"
```

## The Verification

After each commit, run:

```bash
git status
```

Aim for:

```text
working tree clean
```

Then run the application and confirm the milestone still works.

[COMPLETED: Step 23 — Git milestone workflow established]  
[STARTING: Primer 5 Reference — Git quick reference]

---

# Git Quick Reference

## Initialize

```bash
git init
```

## Check Status

```bash
git status
```

## Stage One File

```bash
git add filename
```

## Stage Everything

```bash
git add .
```

## Commit

```bash
git commit -m "Describe the change"
```

## Show History

```bash
git log --oneline
```

## Show Changes

```bash
git diff
git diff --staged
```

## Restore an Unstaged File

```bash
git restore filename
```

## Unstage a File

```bash
git restore --staged filename
```

## Create a Branch

```bash
git switch -c feature-name
```

## Switch Branches

```bash
git switch main
```

## Merge a Branch

```bash
git switch main
git merge feature-name
```

## Abort a Merge

```bash
git merge --abort
```

## List Branches

```bash
git branch
```

## Delete a Local Branch

```bash
git branch -d feature-name
```

## Add a Remote

```bash
git remote add origin URL
```

## Push a Branch

```bash
git push -u origin main
```

## Pull Remote Changes

```bash
git pull
```

## Create a Tag

```bash
git tag -a version-name -m "Description"
```

---

# Common Git Mistakes

## Mistake 1: Committing Without Reviewing

Before committing:

```bash
git diff
git diff --staged
```

Review the changes.

## Mistake 2: Committing Secrets

Never commit:

```text
.env
passwords
API keys
private certificates
access tokens
```

Add sensitive filenames to `.gitignore`.

If a secret was committed, deleting it in a later commit does not necessarily remove it from history. Rotate the secret immediately and remove it from history using an appropriate Git-history tool.

## Mistake 3: Using Vague Commit Messages

Weak:

```text
update
```

Better:

```text
Persist tasks in localStorage
```

## Mistake 4: Working on the Wrong Branch

Check:

```bash
git branch --show-current
```

before making a feature change.

## Mistake 5: Pulling with Uncommitted Changes

Before pulling:

```bash
git status
```

Commit or temporarily stash your work first.

## Mistake 6: Using `git reset --hard` Carelessly

This command can permanently discard uncommitted changes:

```bash
git reset --hard
```

Do not use it unless you understand exactly which changes will be removed.

## Mistake 7: Ignoring Merge Conflicts

Do not commit conflict markers:

```text
<<<<<<<
=======
>>>>>>>
```

Resolve them, stage the file, and complete the merge.

---

# Primer 5 Completion Checklist

Before beginning Part 0, confirm that you can:

- [ ] Explain what Git does.
- [ ] Check the Git version.
- [ ] Configure a Git identity.
- [ ] Initialize a repository.
- [ ] Create a `.gitignore` file.
- [ ] Read `git status`.
- [ ] Stage files.
- [ ] Review unstaged changes.
- [ ] Review staged changes.
- [ ] Create a commit.
- [ ] Inspect commit history.
- [ ] Restore an uncommitted file.
- [ ] Unstage a file without deleting its changes.
- [ ] Create a feature branch.
- [ ] Switch between branches.
- [ ] Merge a branch.
- [ ] Resolve a basic merge conflict.
- [ ] Abort an unfinished merge.
- [ ] Compare commits with `git diff`.
- [ ] Create a milestone tag.
- [ ] Understand local and remote repositories.
- [ ] Create a project README.
- [ ] Avoid committing secrets.
- [ ] Create milestone commits during the tutorial.
