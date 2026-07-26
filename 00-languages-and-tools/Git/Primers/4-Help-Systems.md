# Primer 4: Reading Commands, Command Safety, and Help Systems

Git tutorials often show commands like this:

```bash
git commit -m "Add release note formatter"
```

Beginners may copy the command successfully without knowing which parts are fixed, which parts must be changed, and which options are potentially risky.

This primer teaches you how to read command syntax safely.

You will learn:

- How to identify a command, option, argument, and placeholder.
- How quotes affect command input.
- How to use Git’s help system.
- How to preview potentially destructive commands.
- How to stop a running terminal command.
- How to distinguish safe inspection commands from commands that modify or delete data.

The goal is not to memorize every command. The goal is to avoid running commands blindly.

---

# P4.1 Understand Command Structure

## The Target

Identify the main parts of a terminal command.

## The Concept

Most commands follow this general shape:

```text
command option argument
```

For example:

```bash
git commit -m "Add release note formatter"
```

Break it into parts:

| Part | Value | Meaning |
|---|---|---|
| Command | `git` | Run the Git program. |
| Subcommand | `commit` | Ask Git to create a commit. |
| Option | `-m` | Provide a commit message directly. |
| Argument | `"Add release note formatter"` | The commit message value. |

Another example:

```bash
git switch -c feature/add-export
```

| Part | Value | Meaning |
|---|---|---|
| Command | `git` | Run Git. |
| Subcommand | `switch` | Change the active branch. |
| Option | `-c` | Create a branch before switching to it. |
| Argument | `feature/add-export` | The new branch name. |

Think of a command as a sentence:

```text
Git, create a commit, with this message.
Git, switch branches, while creating this new branch name.
```

## The Implementation

Run these safe commands:

```bash
git --version
git status
git branch --show-current
```

## The Verification

You should be able to identify:

```text
git             → command
--version        → option

git             → command
status          → subcommand

git             → command
branch          → subcommand
--show-current  → option
```

---

# P4.2 Understand Placeholders

## The Target

Recognize which text in documentation must be replaced before running a command.

## The Concept

Tutorials often use placeholders to represent values that differ for each reader.

For example:

```bash
git switch -c feature/short-description
```

The text:

```text
short-description
```

is not a literal requirement. Replace it with a meaningful branch purpose:

```bash
git switch -c feature/add-release-export
```

Common placeholder styles include:

```text
<file-path>
<branch-name>
<commit-hash>
YOUR_GITHUB_USERNAME
ISSUE_NUMBER
```

Never type angle brackets when the documentation uses them as placeholders.

Incorrect:

```bash
git add <file-path>
```

Correct:

```bash
git add README.md
```

## The Implementation

Read these command patterns and their concrete equivalents.

| Pattern | Replace with | Concrete example |
|---|---|---|
| `git add <file-path>` | A real file path | `git add README.md` |
| `git switch <branch-name>` | A real branch name | `git switch main` |
| `git show <commit-hash>` | A real commit hash | `git show a1b2c3d` |
| `git push -u origin <branch-name>` | The current branch | `git push -u origin feature/add-export` |
| `git remote add origin <repository-url>` | A GitHub clone URL | `git remote add origin git@github.com:octocat/project.git` |

Run this harmless command to inspect your current branch:

```bash
git branch --show-current
```

## The Verification

Confirm you can explain why this is invalid:

```bash
git switch <branch-name>
```

And why this is valid:

```bash
git switch main
```

---

# P4.3 Understand Quotes

## The Target

Use quotes correctly when an argument contains spaces or special characters.

## The Concept

The terminal usually separates arguments at spaces.

Without quotes:

```bash
git commit -m Add release note formatter
```

the terminal interprets the words separately:

```text
Add
release
note
formatter
```

With quotes:

```bash
git commit -m "Add release note formatter"
```

the full phrase becomes one argument.

Quotes are especially important for:

- Commit messages.
- Folder names containing spaces.
- Search strings.
- Text passed to scripts.
- URLs containing special characters.

Use double quotes for ordinary text:

```bash
git commit -m "Fix invalid release date validation"
```

## The Implementation

Run this safe command:

```bash
echo "A quoted sentence stays together."
```

Then run:

```bash
echo A sentence without quotes has separate words.
```

Both commands print readable output, but the terminal receives their arguments differently.

Use Git to inspect the last commit message:

```bash
git log -1 --format="%s"
```

The `%s` tells Git to print the commit subject line.

## The Verification

Expected output from the Git command resembles:

```text
Add release note formatter
```

You should understand why commit messages use quotes:

```bash
git commit -m "Describe one focused change"
```

---

# P4.4 Read Options Carefully

## The Target

Recognize short options, long options, and options that require values.

## The Concept

An **option**, sometimes called a flag, changes how a command behaves.

Short options use one dash:

```bash
git commit -m "Message"
```

Long options use two dashes:

```bash
git commit --amend
```

Some options require a value:

```bash
git commit -m "Message"
```

Here:

```text
-m
```

requires the next argument to be the message.

Another example:

```bash
git switch -c feature/add-export
```

Here:

```text
-c
```

requires the next argument to be a branch name.

## The Implementation

Inspect help for `git commit`:

```bash
git commit -h
```

Look for options such as:

```text
-m, --message <message>
    use the given <message> as the commit message

--amend
    amend the tip of the current branch
```

Exit the help output if it opens in a pager by pressing:

```text
q
```

## The Verification

Confirm that you can identify:

| Option | Meaning |
|---|---|
| `-m` | Supply a commit message. |
| `--amend` | Replace the latest commit with a new version. |
| `-a` | Stage modifications to already tracked files before committing. |
| `--no-verify` | Skip local commit hooks; use only for understood exceptions. |

Do not use an option merely because it appears in help output. Read what it does first.

---

# P4.5 Use Git Help Safely

## The Target

Find official built-in documentation for Git commands.

## The Concept

Git has several help formats.

Quick summary:

```bash
git <command> -h
```

Full manual:

```bash
git help <command>
```

For example:

```bash
git help rebase
```

Git may open a terminal manual viewer. Press:

```text
q
```

to exit.

You can also use:

```bash
git <command> --help
```

For example:

```bash
git merge --help
```

Think of help output as the instruction manual packaged with Git itself.

## The Implementation

Run:

```bash
git status -h
```

Then run:

```bash
git help log
```

If the manual viewer opens, press:

```text
q
```

Finally, search Git help topics:

```bash
git help -a
```

This lists available Git commands.

## The Verification

Confirm you can find help for these commands:

```bash
git help status
git help switch
git help restore
git help merge
git help rebase
git help reflog
```

---

# P4.6 Classify Commands by Risk

## The Target

Distinguish inspection commands from commands that modify history or discard work.

## The Concept

Not all Git commands carry the same risk.

A useful classification is:

| Category | What it does | Examples |
|---|---|---|
| Inspection | Reads state without changing it | `git status`, `git log`, `git diff` |
| Local modification | Changes working files, staging, or local history | `git add`, `git commit`, `git restore` |
| Remote modification | Changes GitHub branches or tags | `git push`, `git push --force-with-lease` |
| Destructive or history-rewriting | Can discard work or replace commit history | `git reset --hard`, `git rebase`, `git branch -D` |

Inspection commands are generally safe to run anytime:

```bash
git status
git diff
git diff --staged
git log --oneline --decorate --graph --all
```

Commands that remove or rewrite work require deliberate review first.

## The Implementation

Run these inspection commands:

```bash
git status
git log --oneline -5
git diff
git diff --staged
```

Do not run destructive commands as an exercise.

Read these examples instead:

```bash
git restore README.md
```

Discards unstaged changes in `README.md`.

```bash
git reset --hard HEAD~1
```

Moves back one commit and overwrites staging plus working files.

```bash
git branch -D feature/old-work
```

Deletes a branch even if it contains unmerged commits.

## The Verification

Before running a command that changes or removes work, ask:

```text
1. What state am I currently in?
2. What exactly will this command change?
3. Have I inspected the relevant diff or history?
4. Do I have a commit, stash, branch, or backup if recovery is needed?
```

---

# P4.7 Preview Changes Before Committing

## The Target

Use Git’s inspection commands to understand what a commit will contain.

## The Concept

A commit should never be a surprise package.

The safe review flow is:

```text
Working directory changes
    ↓
git diff
    ↓
Stage intended files
    ↓
git diff --staged
    ↓
Commit
```

This matters because Git commits staged content—not necessarily every file you changed.

## The Implementation

From a Git repository with no important pending work, inspect the state:

```bash
git status
git diff
git diff --staged
```

If your repository has changes you intend to commit:

```bash
git add <intended-file-path>
git diff --staged
```

Do not stage unrelated files.

## The Verification

Interpret the results:

| Command | Meaning |
|---|---|
| `git status` | Which files are untracked, unstaged, staged, or clean? |
| `git diff` | What differs between working files and staging? |
| `git diff --staged` | What will differ between the next commit and the latest commit? |

A safe commit starts only after you understand the final `git diff --staged` output.

---

# P4.8 Preview Deletion Commands with Dry Runs

## The Target

Use dry-run options before deleting untracked files.

## The Concept

A **dry run** means:

> “Show what would happen, but do not change anything.”

For Git cleanup, use:

```bash
git clean -nd
```

Breakdown:

| Option | Meaning |
|---|---|
| `-n` | Dry run; do not delete anything |
| `-d` | Include untracked directories |

This command displays untracked files and folders Git would remove.

Only after reviewing the output should you consider:

```bash
git clean -fd
```

That command deletes untracked files and directories.

Do not use `git clean -fdx` casually. The `-x` option can remove ignored files too, including local `.env` files and dependency folders.

## The Implementation

Run the safe preview:

```bash
git clean -nd
```

If the output lists files, do not delete them unless you understand why they exist.

## The Verification

Expected output may be empty:

```text
```

That means Git found no untracked files or folders to show.

If output resembles:

```text
Would remove temporary-output.txt
```

Git is only previewing the deletion. No file has been removed.

---

# P4.9 Stop a Command That Is Still Running

## The Target

Safely interrupt a command that is taking too long or appears stuck.

## The Concept

Some commands take time:

```bash
npm install
git fetch
git gc
git bisect run npm test
```

If you need to stop a foreground terminal command, press:

```text
Ctrl+C
```

This sends an interrupt signal to the active process.

Do not repeatedly close terminal windows while Git is actively writing objects, rebasing, merging, or pushing. First try `Ctrl+C`, then inspect repository state.

After interrupting Git, run:

```bash
git status
```

Git usually explains whether an operation is in progress and what to do next.

## The Implementation

Do not interrupt an important command just for practice.

Instead, remember:

```text
Ctrl+C
```

Then inspect state after any interruption:

```bash
git status
```

If a merge is in progress and should be cancelled:

```bash
git merge --abort
```

If a rebase is in progress and should be cancelled:

```bash
git rebase --abort
```

If a cherry-pick is in progress and should be cancelled:

```bash
git cherry-pick --abort
```

## The Verification

You should be able to match the recovery command to the operation:

| In-progress operation | Abort command |
|---|---|
| Merge | `git merge --abort` |
| Rebase | `git rebase --abort` |
| Cherry-pick | `git cherry-pick --abort` |

Always start recovery by running:

```bash
git status
```

---

# P4.10 Use a Safe “Pause and Inspect” Routine

## The Target

Create a habit for responding safely when Git output is confusing.

## The Concept

Git is precise, but its messages can feel unfamiliar at first.

When uncertain, do not immediately try multiple commands until an error disappears.

Pause and run:

```bash
git status
git diff
git diff --staged
git log --oneline --decorate --graph --all -10
```

Then ask:

```text
What branch am I on?
Do I have uncommitted changes?
Is a merge, rebase, or cherry-pick active?
What is staged?
What changed recently?
```

This is the Git equivalent of checking a map before choosing a road.

## The Implementation

Run this complete safe diagnostic sequence:

```bash
git status
git diff
git diff --staged
git log --oneline --decorate --graph --all -10
```

## The Verification

You should now know where to begin when something feels unclear:

```text
Do not guess.
Do not force push.
Do not reset hard.
Inspect first.
```

---

# Primer 4 Reference: Safe Command Reading Checklist

Before running a command copied from documentation, ask:

```text
[ ] Which part is the command?
[ ] Which parts are options?
[ ] Which values are placeholders I must replace?
[ ] Does the command modify files, history, branches, or remotes?
[ ] Can I inspect the current state first with git status?
[ ] Is there a dry-run or help command available?
[ ] Do I understand how to abort or recover if the command pauses?
```

---

# Primer 4 Reference: First Commands to Run When Unsure

```bash
git status
git diff
git diff --staged
git log --oneline --decorate --graph --all -10
git reflog -10
```

Use help for a command:

```bash
git <command> -h
git help <command>
```

Preview untracked-file deletion:

```bash
git clean -nd
```

---

# Primer 4 Completion Check

Before continuing with advanced Git commands, confirm that you can:

- [ ] Identify commands, subcommands, options, and arguments.
- [ ] Replace documentation placeholders with real values.
- [ ] Use quotes for commit messages and text containing spaces.
- [ ] Read `git <command> -h` output.
- [ ] Distinguish inspection commands from modifying or destructive commands.
- [ ] Review staged changes before committing.
- [ ] Use `git clean -nd` as a safe deletion preview.
- [ ] Use `Ctrl+C` to interrupt a foreground command.
- [ ] Identify the correct abort command for merge, rebase, and cherry-pick operations.
- [ ] Start with `git status` when Git state is unclear.
