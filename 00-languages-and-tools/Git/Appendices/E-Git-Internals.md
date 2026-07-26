# Appendix E: Git Internals — Commits, Trees, Blobs, Refs, and HEAD

This appendix explains what Git stores internally and why commands such as branching, merging, rebasing, and recovering work behave the way they do.

You do not need to memorize every internal detail to use Git effectively. However, a basic understanding of Git’s object model removes much of the mystery behind:

- Why commits have hashes.
- Why branches are lightweight.
- Why rebasing creates new commit hashes.
- Why Git can recover deleted branches with reflog.
- Why `.git` matters.
- Why a merge commit can have two parents.

---

## E.1 Git Is a Content-Addressed Database

### The Target

Understand the core idea behind Git’s internal storage system.

### The Concept

Git is often described as a version-control tool, but internally it is a **content-addressed database**.

That phrase sounds complicated, but the idea is simple:

> Git stores data, calculates an identifier from that data, and uses the identifier as the object’s address.

Think of it like a warehouse where every box receives a unique label based on exactly what is inside the box.

If the contents change, the label changes.

Git traditionally uses SHA-1 hashes for object IDs, although newer Git installations can be configured to use SHA-256 repositories. In a typical SHA-1 repository, an object ID looks like this:

```text
7f6d8f0c84b4c9f2d0f9c8c0d4f1b8c6a8e4b123
```

You normally use a unique shortened prefix:

```text
7f6d8f0
```

Git uses hashes to identify:

- File content.
- Directory snapshots.
- Commits.
- Tags.

A hash is not a version number. It is an identifier derived from content and metadata.

---

## E.2 The `.git` Directory

### The Target

Inspect the hidden `.git` directory without manually changing its contents.

### The Concept

When you run:

```bash
git init
```

Git creates a hidden `.git` directory.

This is the local repository database.

Your project files are outside `.git`:

```text
release-notes-manager/
├── .git/                     # Git metadata and history
├── README.md                 # Your project files
├── package.json
└── src/
```

If you remove `.git`, the working files remain, but Git no longer recognizes the folder as a repository and local history is lost from that directory.

Do not edit files in `.git` casually. Use Git commands to manage Git data.

### The Implementation

From the project root, inspect the `.git` directory.

#### macOS, Linux, or Git Bash

```bash
ls -la .git
```

#### Windows PowerShell

```powershell
Get-ChildItem -Force .git
```

Common entries include:

```text
HEAD
config
description
hooks/
index
info/
logs/
objects/
refs/
```

Inspect the current `HEAD` file.

### macOS, Linux, or Git Bash

```bash
cat .git/HEAD
```

### Windows PowerShell

```powershell
Get-Content .git\HEAD
```

### The Verification

When you are on `main`, output commonly resembles:

```text
ref: refs/heads/main
```

This means:

```text
HEAD → refs/heads/main → latest commit on main
```

You are not seeing a commit hash directly because `HEAD` is attached to the `main` branch reference.

---

## E.3 Git Objects: Blob, Tree, Commit, and Tag

### The Target

Learn the four core object types Git can store.

### The Concept

Git stores repository history using a small set of object types.

| Object type | Stores | Everyday analogy |
|---|---|---|
| Blob | File contents | A printed page |
| Tree | Folder listing that maps names to blobs and other trees | A folder inventory sheet |
| Commit | A tree plus history metadata | A dated project snapshot record |
| Tag | A named annotation for an object, often a release commit | A signed release label |

Git does not store changes as a running sequence of line edits in the way many people imagine. Instead, a commit points to a complete project snapshot through a tree structure.

```text
Commit
  │
  ▼
Tree: project root
  ├── README.md → Blob
  ├── package.json → Blob
  ├── src/ → Tree
  │       ├── releaseNotes.js → Blob
  │       └── releaseNotes.test.js → Blob
  └── .github/ → Tree
          └── workflows/ → Tree
                  └── ci.yml → Blob
```

A blob stores file content but does not inherently know the filename. The tree gives the blob a filename and location.

---

## E.4 Inspect a Commit Object

### The Target

View raw commit metadata and identify its tree and parent references.

### The Concept

A commit object contains:

- A pointer to the project tree.
- One parent commit for ordinary commits.
- Two or more parents for merge commits.
- Author name, email, and timestamp.
- Committer name, email, and timestamp.
- Commit message.

A simplified commit object resembles:

```text
tree <tree-hash>
parent <parent-commit-hash>
author Jordan Lee <jordan@example.com> ...
committer Jordan Lee <jordan@example.com> ...

Add continuous integration workflow
```

### The Implementation

Inspect the raw `HEAD` commit:

```bash
git cat-file -p HEAD
```

Determine its object type:

```bash
git cat-file -t HEAD
```

Inspect its size:

```bash
git cat-file -s HEAD
```

### The Verification

Expected object type:

```text
commit
```

The raw output should contain a line beginning with:

```text
tree
```

Most non-merge commits also contain one line beginning with:

```text
parent
```

A merge commit contains multiple `parent` lines.

---

## E.5 Inspect a Tree Object

### The Target

Inspect the directory snapshot connected to the current commit.

### The Concept

The current commit points to a root tree. That tree records file names, file modes, and object IDs.

A tree is like a project folder’s table of contents at one exact point in history.

### The Implementation

Print the root tree from the current commit:

```bash
git ls-tree HEAD
```

List every tracked file recursively:

```bash
git ls-tree -r HEAD
```

Inspect the `src` directory tree specifically:

```bash
git ls-tree HEAD:src
```

Inspect the workflow directory:

```bash
git ls-tree HEAD:.github/workflows
```

### The Verification

Output resembles:

```text
100644 blob <hash>    README.md
100644 blob <hash>    package.json
040000 tree <hash>    src
```

The number at the beginning is a file mode:

| Mode | Meaning |
|---|---|
| `100644` | Normal non-executable file |
| `100755` | Executable file |
| `040000` | Directory tree |
| `120000` | Symbolic link |

---

## E.6 Inspect a Blob Object

### The Target

View the exact file content stored by Git in a commit.

### The Concept

A blob represents file content at a specific point in history.

The same file path can point to different blob objects in different commits because the file content changed.

For example:

```text
Commit A:
README.md → Blob 111

Commit B:
README.md → Blob 222
```

If `README.md` did not change between commits, both trees can point to the same blob. This is one reason Git can store history efficiently.

### The Implementation

Display the current committed version of `README.md`:

```bash
git show HEAD:README.md
```

Find the blob hash for the file:

```bash
git ls-tree HEAD README.md
```

The output includes a blob hash. Copy it and replace `README_BLOB_HASH` below:

```bash
git cat-file -t README_BLOB_HASH
git cat-file -p README_BLOB_HASH
```

### The Verification

The object type should be:

```text
blob
```

The printed blob content should match:

```bash
git show HEAD:README.md
```

---

## E.7 Why Branches Are Lightweight

### The Target

Understand why creating a Git branch is fast and inexpensive.

### The Concept

A branch is usually just a file containing one commit hash.

For example:

```text
refs/heads/main
```

might contain:

```text
a1b2c3d4e5f6...
```

Creating a branch does not duplicate all project files or all commits. Git simply creates another named pointer to an existing commit.

Before branch creation:

```text
main → Commit E
```

After:

```text
main → Commit E
feature/add-export → Commit E
```

After committing on the feature branch:

```text
main → Commit E
feature/add-export → Commit F
```

The project history is shared until the branches differ.

### The Implementation

List local branch references:

```bash
git show-ref --heads
```

Inspect the current branch name:

```bash
git branch --show-current
```

Inspect the current branch’s commit hash:

```bash
git rev-parse HEAD
```

Create a temporary branch:

```bash
git branch practice/inspect-refs
```

List branch references again:

```bash
git show-ref --heads
```

Delete the temporary branch:

```bash
git branch -d practice/inspect-refs
```

### The Verification

After creating the temporary branch, `git show-ref --heads` should show two lines that initially point to the same commit hash:

```text
<hash> refs/heads/main
<hash> refs/heads/practice/inspect-refs
```

This proves a new branch begins as another name for the current commit.

---

## E.8 HEAD, Attached HEAD, and Detached HEAD

### The Target

Understand what `HEAD` points to in normal and detached states.

### The Concept

`HEAD` identifies your current checkout position.

In the usual attached state:

```text
HEAD → main → Commit E
```

When you make a commit, Git moves `main` forward:

```text
HEAD → main → Commit F
```

In detached HEAD state:

```text
HEAD → Commit C
main → Commit F
```

Detached HEAD is useful for inspecting old versions, but any new commit you make is not attached to a named branch until you create one.

### The Implementation

Inspect the current symbolic reference:

```bash
git symbolic-ref --short HEAD
```

This works only when `HEAD` is attached to a branch.

Inspect the resolved commit ID:

```bash
git rev-parse HEAD
```

Safely inspect an earlier commit without switching branches:

```bash
git show HEAD~1 --stat
```

Do not detach HEAD for this appendix unless you specifically want to practice it. If you do:

```bash
git switch --detach HEAD~1
```

Return safely:

```bash
git switch main
```

### The Verification

On a normal branch, this command prints:

```text
main
```

```bash
git symbolic-ref --short HEAD
```

In detached HEAD state, it exits with an error because there is no current branch reference.

---

## E.9 How Staging Works Internally

### The Target

Understand why staged and unstaged changes can differ for the same file.

### The Concept

The staging area is stored internally as the **index**.

It is not simply a list of filenames. It records the exact snapshot of each file that will be included in the next commit.

That means one file can exist in three different versions at once:

```text
HEAD version       → last committed version
Index version      → staged version for next commit
Working version    → current file on disk
```

Example:

```text
README.md in HEAD:
"Version A"

README.md in index:
"Version B"

README.md in working directory:
"Version C"
```

This is why these commands answer different questions:

```bash
git diff
```

Compares working directory to index.

```bash
git diff --staged
```

Compares index to `HEAD`.

### The Implementation

Inspect the index entries:

```bash
git ls-files --stage
```

Inspect one file’s staged metadata:

```bash
git ls-files --stage README.md
```

The output format is similar to:

```text
100644 <blob-hash> 0    README.md
```

The `0` is the normal index stage for a non-conflicted file.

### The Verification

Confirm that `README.md` appears with:

- A file mode.
- A blob hash.
- Index stage `0`.
- The file path.

During a merge conflict, Git may temporarily show multiple stages for one file:

| Index stage | Meaning |
|---|---|
| `1` | Common ancestor version |
| `2` | Current branch version (`HEAD`) |
| `3` | Incoming branch version |

This internal structure is why Git can present conflict markers and ask you to choose the final result.

---

## E.10 Why Rebasing Creates New Commit Hashes

### The Target

Understand why rebased commits are technically new commits even when their file changes look identical.

### The Concept

A commit hash depends on more than the changed files.

It includes metadata such as:

- The root tree hash.
- Parent commit hash or hashes.
- Author information.
- Committer information.
- Timestamps.
- Commit message.

Suppose you have:

```text
A → B → C
```

and rebase `B` and `C` onto a different base:

```text
A → D → B' → C'
```

Even if `B'` contains the same file changes as `B`, its parent is now `D` instead of `A`.

Because the parent is different, the commit data is different. Because the commit data is different, the hash is different.

```text
B ≠ B'
C ≠ C'
```

This is why rebasing a shared branch can disrupt collaborators: their branch points to the original commits, while yours points to rewritten replacements.

### The Implementation

Inspect a recent commit’s parent:

```bash
git cat-file -p HEAD
```

Inspect its parent directly:

```bash
git cat-file -p HEAD~1
```

Observe the different `tree` and `parent` lines.

### The Verification

You should see:

- `HEAD` points to a parent commit.
- `HEAD~1` points to an earlier parent commit.
- Each commit has a distinct object hash.

---

## E.11 Merge Commits Have Multiple Parents

### The Target

Inspect how Git records the joining of two histories.

### The Concept

A normal commit has one parent:

```text
A → B → C
```

A merge commit has two parents:

```text
A → B → D
     \   /
      C
```

Here, `D` is the merge commit. It records that two separate lines of work were combined.

Git can show first-parent history, which is useful when you want to see the main integration line:

```bash
git log --first-parent --oneline
```

### The Implementation

Find merge commits:

```bash
git log --merges --oneline
```

If your repository contains a merge commit, inspect one by replacing `MERGE_COMMIT_HASH`:

```bash
git cat-file -p MERGE_COMMIT_HASH
```

Count its parent lines:

### macOS, Linux, or Git Bash

```bash
git cat-file -p MERGE_COMMIT_HASH | grep '^parent '
```

### Windows PowerShell

```powershell
git cat-file -p MERGE_COMMIT_HASH | Select-String '^parent '
```

### The Verification

A merge commit has at least two lines such as:

```text
parent <first-parent-hash>
parent <second-parent-hash>
```

A squash merge behaves differently. It creates one ordinary commit with one parent, because the branch’s individual commits are combined into a new single commit.

---

## E.12 Refs, Remote-Tracking Refs, and Tags

### The Target

Distinguish local branch refs, remote-tracking refs, and tags.

### The Concept

A **ref** is a human-friendly name that points to a Git object, usually a commit.

Common ref namespaces:

| Ref | Meaning |
|---|---|
| `refs/heads/main` | Local `main` branch |
| `refs/remotes/origin/main` | Last known `main` commit on `origin` |
| `refs/tags/v1.0.0` | Tag named `v1.0.0` |

You usually use short names:

```text
main
origin/main
v1.0.0
```

Remote-tracking branches such as `origin/main` are read-only local records. You do not normally commit directly “on” `origin/main`.

### The Implementation

List all references:

```bash
git show-ref
```

List only remote-tracking references:

```bash
git show-ref --remotes
```

List tags:

```bash
git tag --list
```

List local branches with commit hashes:

```bash
git show-ref --heads
```

### The Verification

You should see references similar to:

```text
<hash> refs/heads/main
<hash> refs/remotes/origin/main
```

If you have not created tags yet, `git tag --list` may produce no output.

---

## E.13 Create and Inspect a Release Tag

### The Target

Create an annotated tag for a stable release commit.

### The Concept

A Git tag gives a meaningful name to a specific point in history.

For example:

```text
v1.0.0
```

Tags are commonly used for releases.

An **annotated tag** stores extra metadata, including:

- Tagger name and email.
- Tag date.
- A message.
- The object it identifies.

A lightweight tag is just a named pointer. For important releases, prefer annotated tags.

### The Implementation

First, ensure `main` is clean and current:

```bash
git switch main
git pull --ff-only
git status
npm test
```

Create an annotated release tag:

```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
```

Inspect the tag:

```bash
git show v1.0.0
```

List tags:

```bash
git tag --list
```

Push the tag to GitHub:

```bash
git push origin v1.0.0
```

Or push all local tags intentionally:

```bash
git push origin --tags
```

Use `--tags` only when you have reviewed every local tag you intend to publish.

### The Verification

Confirm the tag exists locally:

```bash
git tag --list v1.0.0
```

Expected output:

```text
v1.0.0
```

Confirm GitHub has the tag:

```bash
git ls-remote --tags origin
```

On GitHub, open the repository’s **Releases** or **Tags** page and confirm `v1.0.0` appears.

---

## E.14 Garbage Collection and Why Deleted Commits Can Sometimes Be Recovered

### The Target

Understand why reflog can recover recently deleted work.

### The Concept

When you delete a branch, Git usually does not immediately erase its commits.

The commits may become **unreachable**, meaning no branch or tag currently points to them. However, reflog entries can still refer to them temporarily.

Eventually, Git’s garbage collection may remove unreachable objects.

Git runs maintenance automatically in many situations, and you can invoke it manually:

```bash
git gc
```

Do not rely on unreachable commits as storage. If work matters, create a branch, commit it, and push it when appropriate.

### The Implementation

Inspect unreachable objects without deleting anything:

```bash
git fsck --no-reflogs --unreachable
```

This command may produce no output in a healthy repository, and that is normal.

Inspect recent reflog records:

```bash
git reflog --date=local -20
```

### The Verification

You should understand the recovery relationship:

```text
Deleted branch
   ↓
Commit may become unreachable
   ↓
Reflog may still identify it
   ↓
Create a new branch at that hash
   ↓
Commit becomes reachable again
```

Recovery command:

```bash
git switch -c recovery/lost-work <commit-hash>
```

---

# Appendix E Reference: Internal Inspection Commands

```bash
git cat-file -t HEAD
```

Print the object type for `HEAD`.

```bash
git cat-file -p HEAD
```

Print the raw content of a commit, tree, blob, or tag object.

```bash
git ls-tree HEAD
```

List the root tree of the current commit.

```bash
git ls-tree -r HEAD
```

List every tracked file in the current commit.

```bash
git ls-files --stage
```

Inspect index entries and staged blob hashes.

```bash
git show-ref
```

List repository refs.

```bash
git rev-parse HEAD
```

Print the full current commit hash.

```bash
git symbolic-ref --short HEAD
```

Print the current branch name when `HEAD` is attached.

```bash
git reflog
```

Inspect recent reference movements.

```bash
git fsck --no-reflogs --unreachable
```

Inspect unreachable Git objects.

---

# Appendix E Completion Check

You should now be able to explain:

- [ ] Git stores blobs, trees, commits, and tags.
- [ ] A commit points to a complete project snapshot through a tree.
- [ ] A branch is a lightweight reference to a commit.
- [ ] `HEAD` normally points to a branch, which points to a commit.
- [ ] The staging area is Git’s index and can differ from both `HEAD` and working files.
- [ ] Rebasing creates new commit hashes because parent relationships change.
- [ ] Merge commits normally have multiple parents.
- [ ] Reflog can help recover work because it records recent ref movements.
- [ ] Annotated tags provide stable names for release commits.
