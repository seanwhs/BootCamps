# Appendix L: Debugging History with Git Bisect, Blame, and File History

Git does more than save work and coordinate collaboration. It also helps answer investigative questions:

- When did a bug first appear?
- Which commit introduced a regression?
- Why was this line written this way?
- What did this file look like before a refactor?
- Which pull request or commit changed a behavior?

This appendix focuses on Git’s history-debugging tools:

- `git log`
- `git show`
- `git blame`
- `git bisect`
- `git log -S`
- `git log -G`
- `git log --follow`

These commands are especially useful for **regressions**: problems where something worked in an earlier version but no longer works in a newer version.

---

# L.1 The History Investigation Mindset

## The Target

Learn a disciplined way to investigate a bug using repository history.

## The Concept

Imagine a light switch worked last week but does not work today.

You could inspect every change ever made to the electrical system. That would be slow.

A better approach is:

1. Confirm the current version is broken.
2. Find a known older version where it worked.
3. Narrow the range of commits between those points.
4. Identify the exact commit that changed the behavior.
5. Read the commit, issue, pull request, and tests for context.

Git gives you tools for every step.

```text
Known good commit                    Known bad commit
       │                                     │
       ▼                                     ▼
A ── B ── C ── D ── E ── F ── G ── H ── I ── J
                 ▲
                 │
         Bug introduced here
```

Instead of checking every commit one at a time, `git bisect` uses a binary-search strategy to narrow the range quickly.

---

# L.2 Start Every Investigation from a Clean State

## The Target

Protect unfinished work before checking out old commits or running a bisection.

## The Concept

History investigation often switches commits repeatedly.

If your working directory contains uncommitted changes, Git may prevent branch switching—or worse, you may confuse your current work with historical versions.

Before investigating, either:

- Commit work that is ready.
- Create a temporary branch.
- Stash unfinished changes.

## The Implementation

Inspect the current repository state:

```bash
git status
```

If the working tree is clean, continue.

If unfinished changes need to be preserved, stash them:

```bash
git stash push --include-untracked -m "Work in progress before history investigation"
```

Verify the stash:

```bash
git stash list
```

Confirm your recent history:

```bash
git log --oneline --decorate --graph -15
```

## The Verification

A clean working tree should report:

```text
nothing to commit, working tree clean
```

If you created a stash, output should resemble:

```text
stash@{0}: On main: Work in progress before history investigation
```

Do not begin a bisection with work you cannot afford to lose.

---

# L.3 Inspect a Specific Commit with `git show`

## The Target

Inspect what one commit changed and why it may be related to a bug.

## The Concept

A commit is a historical snapshot plus a description.

The command:

```bash
git show <commit-hash>
```

displays:

- Commit hash.
- Author.
- Date.
- Commit message.
- File changes.
- Added and removed lines.

Think of it as opening one entry in the project’s change journal.

## The Implementation

Inspect the latest commit:

```bash
git show HEAD
```

Inspect only a summary of changed files:

```bash
git show --stat HEAD
```

Inspect a specific historical commit:

```bash
git log --oneline -10
git show <commit-hash>
```

For example:

```bash
git show a1b2c3d
```

Inspect only changes to the formatter file in the latest commit:

```bash
git show HEAD -- src/releaseNotes.js
```

## The Verification

A successful `git show` output resembles:

```text
commit a1b2c3d...
Author: Your Name <you@example.com>
Date:   ...

    Add release note formatter

diff --git a/src/releaseNotes.js b/src/releaseNotes.js
...
```

Use the commit message to understand intent, then inspect the patch to understand implementation details.

---

# L.4 View the History of One File

## The Target

See every commit that changed a specific file.

## The Concept

A project can contain hundreds or thousands of commits. Most are irrelevant when investigating one file.

The command:

```bash
git log -- <file-path>
```

filters history to commits that changed that file.

For example:

```bash
git log -- src/releaseNotes.js
```

answers:

> “Which commits changed the release-note formatter?”

## The Implementation

Inspect the history of the formatter:

```bash
git log --oneline -- src/releaseNotes.js
```

Inspect the history of tests:

```bash
git log --oneline -- src/releaseNotes.test.js
```

Inspect the history of release documentation:

```bash
git log --oneline -- RELEASE_NOTES.md
```

View patches for file-specific history:

```bash
git log -p -- src/releaseNotes.js
```

Limit output to the last five relevant commits:

```bash
git log -p -5 -- src/releaseNotes.js
```

## The Verification

Expected output resembles:

```text
a1b2c3d Add release note formatter
d4e5f6a Test release note formatter
...
```

The `-p` version should display the exact changes from each relevant commit.

---

# L.5 Follow a Renamed File

## The Target

Track a file’s history across a rename.

## The Concept

If a file changes names, a normal file-history command may stop at the rename point.

For example:

```text
src/formatter.js
```

becomes:

```text
src/releaseNotes.js
```

Use:

```bash
git log --follow -- <file-path>
```

This tells Git to attempt to follow the file backward through renames.

`--follow` works with one file path at a time.

## The Implementation

If your repository has renamed files, inspect one:

```bash
git log --follow --oneline -- src/releaseNotes.js
```

To see patches across the file history:

```bash
git log --follow -p -- src/releaseNotes.js
```

To test this safely, do not rename an important file solely for the exercise. Instead, use the command when a real rename exists.

## The Verification

If the file has never been renamed, the command still shows ordinary file history.

If a historical rename exists, Git output may include a rename summary similar to:

```text
rename from src/formatter.js
rename to src/releaseNotes.js
```

---

# L.6 Understand `git blame`

## The Target

Identify the last commit that changed each line of a file.

## The Concept

Despite its name, `git blame` should not be used to blame a person.

Use it to understand history:

> “What change introduced this line, and what was the reason?”

Each output line identifies:

- A commit hash.
- The author.
- The timestamp.
- The source line number.
- The line’s current content.

Think of it as a document’s revision margin notes.

## The Implementation

Inspect line history for the formatter:

```bash
git blame src/releaseNotes.js
```

Inspect a limited line range:

```bash
git blame -L 1,80 src/releaseNotes.js
```

Inspect the date-validation area. First, find the line number:

### macOS, Linux, or Git Bash

```bash
grep -n "isValidReleaseDate" src/releaseNotes.js
```

### Windows PowerShell

```powershell
Select-String -Path src\releaseNotes.js -Pattern "isValidReleaseDate"
```

Then use the relevant range. For example:

```bash
git blame -L 12,45 src/releaseNotes.js
```

Ignore whitespace-only changes while blaming:

```bash
git blame -w src/releaseNotes.js
```

## The Verification

Output resembles:

```text
a1b2c3d4 (Jordan Lee 2026-07-25 12:00:00 +0000  18) function isValidReleaseDate(value) {
```

Copy the short commit hash and inspect its full context:

```bash
git show a1b2c3d
```

This is the intended `git blame` workflow:

```text
Find a surprising line
    ↓
Use git blame
    ↓
Find the commit
    ↓
Use git show
    ↓
Read the implementation context and commit message
```

---

# L.7 Search History for Added or Removed Text with `git log -S`

## The Target

Find commits where a specific text string was added or removed.

## The Concept

The `-S` option is sometimes called the **pickaxe** search.

It finds commits where the number of occurrences of a string changed.

For example:

```bash
git log -S "release.releaseDate"
```

asks:

> “Which commits added or removed this exact text?”

This is useful when you know a symbol, variable name, error message, or feature phrase but do not know which file or commit changed it.

## The Implementation

Search for the date-validation error message:

```bash
git log --oneline -S "release.releaseDate must be a valid date" --all
```

Show patches for matching commits:

```bash
git log -p -S "release.releaseDate must be a valid date" --all
```

Search for when the formatter export was introduced:

```bash
git log --oneline -S "formatReleaseNotes" --all
```

Search only within the formatter file:

```bash
git log -p -S "formatReleaseNotes" -- src/releaseNotes.js
```

## The Verification

Git should list commits where the exact string count changed.

If there are no matches, Git prints no output. Check spelling, capitalization, or use the regex-based search described next.

---

# L.8 Search History with a Regular Expression Using `git log -G`

## The Target

Find commits whose patch contains lines matching a regular expression.

## The Concept

`git log -G` searches patch content using a regular expression.

Unlike `-S`, which checks whether a string’s count changed, `-G` searches for lines that match a pattern in a diff.

Use `-G` when you want flexible matching.

For example:

```bash
git log -G "releaseDate|datePattern" -p -- src/releaseNotes.js
```

asks:

> “Show commits that changed lines involving either `releaseDate` or `datePattern`.”

## The Implementation

Search formatter history for date-related changes:

```bash
git log -G "releaseDate|datePattern|parsedDate" -p -- src/releaseNotes.js
```

Search test history for invalid-date scenarios:

```bash
git log -G "2026-02-31|invalid.*date" -p -- src/releaseNotes.test.js
```

Search all history for changes involving `GitHub Actions`:

```bash
git log -G "GitHub Actions|Continuous Integration" -p --all
```

## The Verification

Git displays commits and patches containing matching changed lines.

Use `q` to exit if Git opens the output in a pager.

---

# L.9 Compare a File Between Two Versions

## The Target

Compare one file between two commits, branches, or tags.

## The Concept

When a bug is a regression, comparing the known-good version with the known-bad version can reveal the cause immediately.

The command format is:

```bash
git diff <older-reference> <newer-reference> -- <file-path>
```

References can be:

- Commit hashes.
- Branch names.
- Tags.
- Relative references such as `HEAD~1`.

## The Implementation

Compare the current formatter with the prior commit:

```bash
git diff HEAD~1 HEAD -- src/releaseNotes.js
```

Compare `main` with release tag `v1.0.0`:

```bash
git diff v1.0.0..main -- src/releaseNotes.js
```

Compare the current branch against remote `main`:

```bash
git diff origin/main...HEAD -- src/releaseNotes.js
```

The three-dot form finds the common ancestor and compares it against the current branch. It is especially useful before opening a pull request.

## The Verification

Git displays a patch such as:

```diff
- old line
+ new line
```

Review each change and ask:

- Did this alter the relevant behavior?
- Is there a test covering it?
- Does the commit message explain why it changed?

---

# L.10 Introduce a Controlled Regression for Bisect Practice

## The Target

Create a disposable branch containing a known good commit, a regression commit, and a later unrelated commit.

## The Concept

`git bisect` is most useful when a project has many commits between a known good state and a known bad state.

You will create a safe practice branch. It will not be pushed or merged.

The branch history will look like:

```text
A ── B ── C
     │    │
     │    └── Unrelated documentation change
     └────── Regression introduced here
```

The formatter normally produces:

```md
# Release 1.0.0
```

The regression will incorrectly change it to:

```md
# Version 1.0.0
```

The existing tests will detect the problem.

## The Implementation

Start from a clean `main` branch:

```bash
git switch main
git pull --ff-only
git status
```

Create a practice branch:

```bash
git switch -c practice/git-bisect
```

Confirm tests pass in the known-good state:

```bash
npm test
```

Now edit the formatter.

In `src/releaseNotes.js`, find this line:

```js
`# Release ${release.version.trim()}`,
```

Replace it with this intentionally incorrect line:

```js
`# Version ${release.version.trim()}`,
```

Stage and commit the regression:

```bash
git add src/releaseNotes.js
git commit -m "Change release heading format"
```

Run tests:

```bash
npm test
```

The tests should fail.

Now add an unrelated documentation commit so the regression is not simply the latest commit.

Create this file:

### `release-notes-manager/BISECT_PRACTICE.md`

```md
# Git Bisect Practice

This file is an unrelated commit used to practice identifying a regression with Git bisect.
```

Commit it even though tests remain broken because this branch is intentionally disposable:

```bash
git add BISECT_PRACTICE.md
git commit -m "Add bisect practice notes"
```

## The Verification

Inspect the practice branch history:

```bash
git log --oneline --decorate --graph -5
```

Expected shape:

```text
* <hash> (HEAD -> practice/git-bisect) Add bisect practice notes
* <hash> Change release heading format
* <hash> (main) <previous main commit>
```

Confirm the current branch is bad:

```bash
npm test
```

Expected output includes at least one test failure.

---

# L.11 Find the Regression Manually

## The Target

Identify the regression commit using direct history inspection before automating the search.

## The Concept

For a very small commit range, manual inspection may be faster than `git bisect`.

You know:

- `main` is good.
- `practice/git-bisect` is bad.

Inspect the commits between them:

```bash
git log --oneline main..HEAD
```

Then inspect each candidate:

```bash
git show <commit-hash>
```

## The Implementation

List branch-only commits:

```bash
git log --oneline main..HEAD
```

Inspect the suspected heading-change commit:

```bash
git show <heading-change-commit-hash> -- src/releaseNotes.js
```

## The Verification

You should find the incorrect line:

```js
`# Version ${release.version.trim()}`,
```

The commit that changed `Release` to `Version` is the regression.

For a large history range, use `git bisect` instead.

---

# L.12 Start a Manual Git Bisect Session

## The Target

Use `git bisect` to locate the first bad commit.

## The Concept

Git bisect performs a binary search.

If there are 1,024 commits between good and bad states, checking commits one at a time may require up to 1,024 checks.

Binary search cuts the remaining range in half each step:

```text
1,024
  ↓
512
  ↓
256
  ↓
128
...
```

In the best practical case, Git can identify the first bad commit in roughly 10 checks.

The manual workflow is:

```bash
git bisect start
git bisect bad
git bisect good <known-good-commit>
```

Git checks out a midpoint commit.

You test it, then mark it:

```bash
git bisect good
```

or:

```bash
git bisect bad
```

Git continues until it identifies the first bad commit.

## The Implementation

Ensure you are on the bad practice branch:

```bash
git switch practice/git-bisect
```

Start bisect:

```bash
git bisect start
```

Mark the current commit as bad:

```bash
git bisect bad
```

Mark `main` as the known good reference:

```bash
git bisect good main
```

Git checks out a commit in the middle of the range.

Check its behavior:

```bash
npm test
```

If tests pass, mark it good:

```bash
git bisect good
```

If tests fail, mark it bad:

```bash
git bisect bad
```

Continue running:

```bash
npm test
```

and marking each tested commit as good or bad until Git reports the first bad commit.

## The Verification

Git eventually prints output resembling:

```text
<hash> is the first bad commit
commit <hash>
Author: ...
Date: ...

    Change release heading format
```

Inspect it:

```bash
git show --stat
git show -- src/releaseNotes.js
```

You should see the incorrect heading change.

---

# L.13 End a Bisect Session Safely

## The Target

Return to the branch you were on before starting the bisection.

## The Concept

During a bisect, Git checks out intermediate commits. This commonly puts you into detached HEAD state.

Always end the session with:

```bash
git bisect reset
```

This restores the branch that was checked out when `git bisect start` ran.

## The Implementation

End the bisection:

```bash
git bisect reset
```

Check your branch:

```bash
git branch --show-current
git status
```

## The Verification

Expected active branch:

```text
practice/git-bisect
```

Expected state:

```text
On branch practice/git-bisect
nothing to commit, working tree clean
```

Do not leave a bisect session active while doing unrelated work.

---

# L.14 Automate Bisect with a Test Command

## The Target

Use `git bisect run` to let Git execute tests and classify commits automatically.

## The Concept

If a command reliably returns:

```text
0 = good
nonzero = bad
```

Git can run it automatically at each midpoint.

For this project:

```bash
npm test
```

returns zero when tests pass and nonzero when tests fail.

This makes it ideal for:

```bash
git bisect run npm test
```

The full automatic flow is:

```bash
git bisect start
git bisect bad <bad-commit>
git bisect good <good-commit>
git bisect run npm test
```

## The Implementation

Make sure you are on the intentionally broken practice branch:

```bash
git switch practice/git-bisect
```

Start a new bisect:

```bash
git bisect start
git bisect bad
git bisect good main
```

Run the automated test command:

```bash
git bisect run npm test
```

Git runs tests at each selected commit and reports the first bad commit.

## The Verification

Expected final output resembles:

```text
<hash> is the first bad commit
```

The identified commit should be:

```text
Change release heading format
```

Reset the bisect session:

```bash
git bisect reset
```

---

# L.15 Repair the Regression and Add a Regression Test

## The Target

Fix the known regression on the practice branch and verify that tests prevent it from returning.

## The Concept

Finding the first bad commit is only the investigation step.

A complete fix should:

1. Correct the implementation.
2. Include or preserve a test that proves the expected behavior.
3. Explain the fix in a commit message.
4. Move through a pull request and CI in real work.

The existing formatter test already expects:

```md
# Release 1.0.0
```

That test is the regression guard.

## The Implementation

On `practice/git-bisect`, restore the correct formatter heading.

In `src/releaseNotes.js`, replace:

```js
`# Version ${release.version.trim()}`,
```

with:

```js
`# Release ${release.version.trim()}`,
```

Run tests:

```bash
npm test
```

Commit the repair:

```bash
git add src/releaseNotes.js
git commit -m "Restore release heading format"
```

Inspect the branch-only history:

```bash
git log --oneline main..HEAD
```

Because this branch is only for practice, do not push or merge it.

Delete it after confirming the lesson:

```bash
git switch main
git branch -D practice/git-bisect
```

## The Verification

Before deleting the branch, test output should include:

```text
# fail 0
```

After deleting it, confirm the repository is clean:

```bash
git status
git branch
```

---

# L.16 Mark a Commit as Unusable During Bisect

## The Target

Understand how to skip a commit that cannot be tested.

## The Concept

Sometimes a historical commit cannot be classified as good or bad because:

- It does not build due to an unrelated temporary problem.
- A required dependency no longer exists.
- A test command is incompatible with that old revision.
- The commit changes project structure too much to test quickly.

In that case, use:

```bash
git bisect skip
```

This tells Git:

> “I cannot classify this commit. Choose another candidate.”

Too many skipped commits may prevent Git from naming one exact first bad commit, but it can still narrow the range.

## The Implementation

Do not run this in the completed practice session.

Use this sequence in a real investigation:

```bash
git bisect start
git bisect bad <known-bad-commit>
git bisect good <known-good-commit>
```

When Git checks out an untestable commit:

```bash
git bisect skip
```

Inspect possible remaining candidates:

```bash
git bisect visualize
```

If your terminal does not launch a visual viewer, use:

```bash
git log --oneline --decorate --graph --all
```

## The Verification

Understand the classification choices:

| State | Command |
|---|---|
| The bug exists in this commit | `git bisect bad` |
| The bug does not exist in this commit | `git bisect good` |
| This commit cannot be tested | `git bisect skip` |
| Stop the full investigation | `git bisect reset` |

---

# L.17 Use `git bisect` with a Custom Script

## The Target

Create a test script suitable for automated regression searches.

## The Concept

Some bugs cannot be detected by `npm test` alone.

For example, you may want to verify that the formatter output contains a required heading.

A custom script can return:

```text
0   Good commit
1   Bad commit
125 Skip this commit because it cannot be tested
```

Git reserves exit code `125` as the conventional “skip this commit” result for `git bisect run`.

## The Implementation

Create a temporary script.

### `release-notes-manager/scripts/check-release-heading.sh`

```sh
#!/usr/bin/env sh

set -eu

OUTPUT=$(
  node --input-type=module --eval "
    import { formatReleaseNotes } from './src/releaseNotes.js';

    process.stdout.write(
      formatReleaseNotes({
        version: '1.0.0',
        releaseDate: '2026-07-25'
      })
    );
  "
)

EXPECTED_HEADING="# Release 1.0.0"

if printf '%s\n' "$OUTPUT" | grep -Fx "$EXPECTED_HEADING" >/dev/null; then
  echo "Release heading is correct."
  exit 0
fi

echo "Release heading is incorrect."
echo "Expected: $EXPECTED_HEADING"
echo "Actual output:"
printf '%s\n' "$OUTPUT"
exit 1
```

On macOS, Linux, or Git Bash:

```bash
chmod +x scripts/check-release-heading.sh
```

Run it on `main`:

### macOS, Linux, or Git Bash

```bash
./scripts/check-release-heading.sh
```

### Windows PowerShell

```powershell
bash ./scripts/check-release-heading.sh
```

Because this file is only a learning tool, remove it after verifying it:

### macOS, Linux, or Git Bash

```bash
rm scripts/check-release-heading.sh
```

### Windows PowerShell

```powershell
Remove-Item scripts\check-release-heading.sh
```

## The Verification

On a correct formatter version, expected output:

```text
Release heading is correct.
```

On the intentionally broken historical version, expected output:

```text
Release heading is incorrect.
```

A real project may keep such a script if it represents a meaningful reusable validation rule.

---

# L.18 Search Across All Branches and Tags

## The Target

Search complete reachable history, not only the currently checked-out branch.

## The Concept

By default, some Git log commands focus on the current branch’s reachable history.

When investigating a bug that may have appeared on another branch, release branch, or tag, use:

```bash
--all
```

This includes references from:

- Local branches.
- Remote-tracking branches.
- Tags.

## The Implementation

Search all reachable history for formatter-related commits:

```bash
git log --all --oneline -S "formatReleaseNotes"
```

Search all branches and tags for the date-validation error message:

```bash
git log --all -p -S "release.releaseDate must be a valid date"
```

Show all references containing a commit:

```bash
git branch --all --contains <commit-hash>
git tag --contains <commit-hash>
```

## The Verification

If a commit appears in multiple branches, `git branch --all --contains` lists each matching branch.

This is useful for answering:

> “Has this fix reached `main`?”  
> “Which release tags include this change?”

---

# L.19 File History and Blame Safety Rules

## The Target

Use history tools constructively and accurately.

## The Concept

History investigation can reveal who last changed a line, but it does not necessarily reveal:

- Who caused the underlying problem.
- Why the original requirement existed.
- Whether the line was moved during a refactor.
- Whether the change was reviewed or approved by others.
- Whether the current behavior was intentional at the time.

Use history to understand the code, not to assign personal fault.

Good language:

```text
This line was introduced in commit a1b2c3d. The commit message suggests it was intended to support stricter validation. Could we review whether that requirement still applies?
```

Unhelpful language:

```text
Jordan broke this line.
```

A healthy engineering culture treats regressions as process and system-learning opportunities:

```text
What changed?
Why did existing tests not catch it?
What test, review practice, or monitoring could prevent recurrence?
```

## The Implementation

When you find a relevant commit, inspect:

```bash
git show <commit-hash>
```

Then review related documentation and tests:

```bash
git show <commit-hash> -- src/releaseNotes.js src/releaseNotes.test.js README.md
```

If the commit came from a pull request, open the associated GitHub PR and read:

- Description.
- Review discussion.
- Linked issue.
- CI results.
- Follow-up commits.

## The Verification

Before acting on historical information, confirm you can answer:

```text
[ ] What behavior changed?
[ ] Which commit introduced or altered it?
[ ] Why did the change likely exist?
[ ] Is there a test covering the intended behavior?
[ ] Is the proposed correction safe and focused?
```

---

# L.20 History Debugging Command Reference

## Inspect History

```bash
git log --oneline --decorate --graph --all
```

## Inspect One Commit

```bash
git show <commit-hash>
```

## Show File History

```bash
git log --oneline -- <file-path>
```

## Show File History with Patches

```bash
git log -p -- <file-path>
```

## Follow a File Through Renames

```bash
git log --follow -- <file-path>
```

## Identify the Last Commit That Changed Each Line

```bash
git blame <file-path>
```

## Ignore Whitespace-Only Changes in Blame

```bash
git blame -w <file-path>
```

## Find Commits That Added or Removed a String

```bash
git log -S "exact text" -p --all
```

## Find Commits with Diff Lines Matching a Pattern

```bash
git log -G "regular-expression" -p --all
```

## Start a Bisect

```bash
git bisect start
git bisect bad <bad-reference>
git bisect good <good-reference>
```

## Classify a Bisect Commit

```bash
git bisect good
git bisect bad
git bisect skip
```

## Automate Bisect Testing

```bash
git bisect run npm test
```

## End a Bisect

```bash
git bisect reset
```

---

# Appendix L Completion Check

You should now be able to:

- [ ] Inspect commits and file-specific history.
- [ ] Follow a renamed file through its history.
- [ ] Use `git blame` to understand line context without assigning personal blame.
- [ ] Search history for exact text with `git log -S`.
- [ ] Search patch history with regular expressions using `git log -G`.
- [ ] Compare files between commits, branches, and tags.
- [ ] Use manual `git bisect` to identify a regression.
- [ ] Use `git bisect run` with an automated test command.
- [ ] Reset a bisect session safely.
- [ ] Add tests after fixing regressions so the same problem does not return.
