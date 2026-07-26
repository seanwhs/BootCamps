# Primer 20: Repository Search, Navigation, and Finding Information Efficiently

As repositories grow, finding the right file, command, commit, issue, or configuration becomes an important engineering skill.

You should not need to manually open every folder or scroll through every file.

This primer teaches practical search habits for:

- Finding files.
- Finding text inside files.
- Searching Git history.
- Searching issues and pull requests.
- Searching GitHub Actions workflows.
- Searching safely without exposing secrets.

Think of repository search as using a library catalog:

```text
File search
    → Which book contains the information?

Text search
    → Which page contains this phrase?

Git history search
    → When was this phrase or behavior introduced?

GitHub search
    → Which issue, pull request, or discussion explains the decision?
```

---

# P20.1 Start with Repository Structure

## The Target

Inspect the project’s top-level structure before searching deeply.

## The Concept

Before searching for a file, understand the project’s basic layout.

For Release Notes Manager, important locations include:

```text
.github/              GitHub templates and workflows
.githooks/            Local Git hooks
scripts/              Project automation scripts
src/                  Application source code and tests
README.md             Project overview
CONTRIBUTING.md       Contributor workflow
SECURITY.md           Security guidance
package.json          Node.js scripts and metadata
```

A quick structure check often saves time.

## The Implementation

From the repository root, list top-level files and folders.

### macOS, Linux, or Git Bash

```bash
ls -la
```

To show a shallow tree without `.git` internals:

```bash
find . -maxdepth 2 -path './.git' -prune -o -print | sort
```

### Windows PowerShell

```powershell
Get-ChildItem -Force
```

For a shallow recursive view:

```powershell
Get-ChildItem -Recurse -Depth 2 -Force |
  Where-Object { $_.FullName -notmatch '\\.git' } |
  Select-Object -ExpandProperty FullName |
  Sort-Object
```

## The Verification

Confirm that you can identify where each type of information belongs:

| Information | Likely location |
|---|---|
| Test command | `package.json` |
| CI workflow | `.github/workflows/` |
| Pull request template | `.github/pull_request_template.md` |
| Formatter implementation | `src/releaseNotes.js` |
| Formatter tests | `src/releaseNotes.test.js` |
| Secret handling guidance | `SECURITY.md` and `.gitignore` |

---

# P20.2 Find Files by Name

## The Target

Locate files when you know all or part of the filename.

## The Concept

A file search answers:

> “Where is the file named something like this?”

For example, you may remember that a workflow file exists but not whether it is named:

```text
ci.yml
ci.yaml
continuous-integration.yml
```

Search by filename instead of guessing.

## The Implementation

### macOS, Linux, or Git Bash

Find files with “release” in the name:

```bash
find . -path './.git' -prune -o -iname '*release*' -print
```

Find workflow files:

```bash
find .github/workflows -type f -print
```

Find Markdown files:

```bash
find . -path './.git' -prune -o -name '*.md' -print | sort
```

### Windows PowerShell

Find files with “release” in the name:

```powershell
Get-ChildItem -Recurse -File -Force |
  Where-Object {
    $_.FullName -notmatch '\\.git\\' -and
    $_.Name -match 'release'
  } |
  Select-Object -ExpandProperty FullName
```

Find workflow files:

```powershell
Get-ChildItem .github\workflows -File
```

Find Markdown files:

```powershell
Get-ChildItem -Recurse -File -Filter *.md -Force |
  Where-Object { $_.FullName -notmatch '\\.git\\' } |
  Select-Object -ExpandProperty FullName |
  Sort-Object
```

## The Verification

You should be able to find files such as:

```text
RELEASE_NOTES.md
RELEASE_CHECKLIST.md
src/releaseNotes.js
src/releaseNotes.test.js
.github/workflows/ci.yml
```

---

# P20.3 Search Text Inside Tracked Files with `git grep`

## The Target

Find text inside files tracked by Git.

## The Concept

`git grep` searches only files Git tracks.

This is useful because it ignores untracked clutter such as:

```text
node_modules/
coverage/
temporary logs
editor backup files
```

For example:

```bash
git grep -n "formatReleaseNotes"
```

means:

> “Search tracked files for `formatReleaseNotes`, showing line numbers.”

The `-n` option means “show line numbers.”

## The Implementation

Search for the formatter function:

```bash
git grep -n "formatReleaseNotes"
```

Search for GitHub Actions references:

```bash
git grep -n "GitHub Actions"
```

Search case-insensitively for release notes:

```bash
git grep -ni "release notes"
```

Search only inside the source directory:

```bash
git grep -n "releaseDate" -- src
```

## The Verification

Expected results resemble:

```text
src/releaseNotes.js:92:export function formatReleaseNotes(release) {
src/releaseNotes.test.js:3:import { formatReleaseNotes } from "./releaseNotes.js";
README.md:...:import { formatReleaseNotes } from "./src/releaseNotes.js";
```

You should now know:

```text
git grep
    = Search tracked project content.

grep
    = General filesystem text search.
```

---

# P20.4 Search Filesystem Text Carefully

## The Target

Search all local files when Git-tracked-file search is not sufficient.

## The Concept

Sometimes you need to search files outside Git tracking, such as:

- A local configuration file.
- A generated report.
- A temporary diagnostic output.
- A file before it has been added to Git.

Use filesystem search carefully because it can include:

```text
node_modules/
.git/
large generated files
private local configuration
```

Avoid dumping secret-bearing files into terminal logs.

## The Implementation

### macOS, Linux, or Git Bash

Search text recursively while excluding `.git` and `node_modules`:

```bash
grep -RIn \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  "releaseDate" .
```

### Windows PowerShell

```powershell
Get-ChildItem -Recurse -File -Force |
  Where-Object {
    $_.FullName -notmatch '\\.git\\' -and
    $_.FullName -notmatch '\\node_modules\\'
  } |
  Select-String -Pattern "releaseDate"
```

## The Verification

Confirm that search output identifies:

```text
File path
Line number
Matching content
```

Before sharing search results, review them for secrets, local paths, and private configuration values.

---

# P20.5 Search Git History for a Commit Message

## The Target

Find historical commits using words from their commit messages.

## The Concept

A commit message is part of project documentation.

If you remember that a change involved “security” or “formatter,” search commit history instead of scrolling through every commit.

## The Implementation

Search commit messages for formatter-related work:

```bash
git log --oneline --grep="formatter"
```

Search case-insensitively:

```bash
git log --oneline --regexp-ignore-case --grep="security"
```

Search all branches:

```bash
git log --all --oneline --grep="continuous integration"
```

Show full patches for matching commits:

```bash
git log -p --grep="release note"
```

## The Verification

Expected output resembles:

```text
a1b2c3d Add release note formatter
d4e5f6a Test release note formatter
```

If Git returns no output, check spelling or use a broader search term.

---

# P20.6 Search History for Changed Content

## The Target

Find when a specific string was added, removed, or changed in project history.

## The Concept

Commit-message search answers:

> “Which commit message mentions this?”

Content-history search answers:

> “Which commit changed this text?”

Use:

```bash
git log -S "exact text"
```

This searches for commits where the number of occurrences of the text changed.

For example:

```bash
git log -S "formatReleaseNotes" --oneline --all
```

Use:

```bash
git log -G "regular expression"
```

when you need flexible pattern matching in patches.

## The Implementation

Find when the formatter function was introduced:

```bash
git log --oneline -S "formatReleaseNotes" --all
```

Find date-related changes in the formatter:

```bash
git log -p -G "releaseDate|datePattern|parsedDate" -- src/releaseNotes.js
```

Find changes to a specific error message:

```bash
git log -p -S "release.version must be a non-empty string." --all
```

## The Verification

You should be able to use the results to answer:

```text
Which commit changed this behavior?
Which files changed in that commit?
What did the code look like before and after?
```

Inspect any matching commit:

```bash
git show <commit-hash>
```

---

# P20.7 Search GitHub Issues and Pull Requests

## The Target

Find planning and review discussions related to a topic.

## The Concept

Important decisions may exist in GitHub Issues and pull requests rather than source code.

For example:

```text
Why was this validation rule added?
Why does CI use this Node.js version?
Why was a dependency rejected?
```

The answer may be in:

```text
Issue discussion
Pull request description
Review comment
Linked milestone
GitHub release notes
```

## The Implementation

Search issues with GitHub CLI:

```bash
gh issue list --search "formatter"
```

Search closed issues:

```bash
gh issue list --state closed --search "release export"
```

Search pull requests:

```bash
gh pr list --search "security"
```

Search merged pull requests:

```bash
gh pr list --state merged --search "continuous integration"
```

Use GitHub’s web search for broader repository searches:

```text
https://github.com/OWNER/REPOSITORY/issues?q=formatter
```

Replace `OWNER` and `REPOSITORY`.

## The Verification

Confirm that you can connect:

```text
Issue:
Why work was requested.

Branch and commits:
How work was implemented.

Pull request:
How work was reviewed and merged.
```

---

# P20.8 Search Workflow Configuration

## The Target

Find CI triggers, permissions, Actions, and shell commands quickly.

## The Concept

Workflow files are executable automation. When investigating CI behavior, search for:

```text
on:
permissions:
uses:
run:
secrets.
pull_request_target
workflow_dispatch
```

This helps answer:

```text
Which workflow runs npm test?
Which workflow has write permission?
Does any workflow reference a secret?
Which workflow can run manually?
```

## The Implementation

### macOS, Linux, or Git Bash

Search all workflow files for permissions:

```bash
grep -RIn "permissions:" .github/workflows
```

Search for secret references:

```bash
grep -RIn "secrets\." .github/workflows
```

Search for workflow triggers:

```bash
grep -RIn "pull_request:\|push:\|workflow_dispatch:\|pull_request_target:" .github/workflows
```

### Windows PowerShell

```powershell
Get-ChildItem .github\workflows -File |
  Select-String -Pattern "permissions:|secrets\.|pull_request:|push:|workflow_dispatch:|pull_request_target:"
```

## The Verification

Before changing a workflow, confirm:

```text
[ ] Which event triggers it?
[ ] Which permissions does it receive?
[ ] Which Actions and scripts does it run?
[ ] Does it access any secret?
[ ] Is it required by branch protection?
```

---

# P20.9 Search Without Exposing Secrets

## The Target

Avoid accidentally printing sensitive local configuration while searching.

## The Concept

Search commands can reveal contents of:

```text
.env
credentials files
private certificates
logs
deployment configuration
```

Avoid broad searches such as:

```bash
grep -RIn "token" .
```

if the current folder contains local secrets.

Prefer Git-tracked-file search when possible:

```bash
git grep -ni "token"
```

This avoids ignored local files such as `.env`.

If you must search local files, explicitly exclude sensitive paths:

```bash
grep -RIn \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude=".env" \
  --exclude=".env.*" \
  "search term" .
```

## The Implementation

Search tracked repository files for potentially unsafe text:

```bash
git grep -niE "password|api[_-]?key|secret|token|private[_-]?key" || true
```

Review any matches carefully.

A documentation reference such as:

```text
Do not commit API keys.
```

is safe.

A real credential value is not.

## The Verification

Confirm this rule:

```text
Search output is data.
Treat it with the same care as source code, logs, and configuration.
```

Do not paste raw search output into public issues or pull requests without reviewing it.

---

# P20.10 Efficient Investigation Routine

## The Target

Use a structured search sequence when investigating a behavior or configuration question.

## The Concept

When a question arises, search from the most specific and least risky source outward.

For example:

> “Why does the formatter reject invalid dates?”

Use this sequence:

```text
1. Search source code.
2. Search tests.
3. Search commit history.
4. Search linked pull requests and issues.
5. Read release notes or documentation.
```

This creates an evidence trail rather than relying on guesswork.

## The Implementation

Example investigation commands:

```bash
git grep -n "isValidReleaseDate" -- src
git grep -n "2026-02-31" -- src
git log --oneline -S "isValidReleaseDate" --all
git log -p -G "2026-02-31|invalid.*date" -- src/releaseNotes.test.js
gh pr list --state merged --search "date validation"
gh issue list --state all --search "date validation"
```

## The Verification

At the end of an investigation, you should be able to explain:

```text
What the code currently does.
Which tests define expected behavior.
Which commit introduced the behavior.
Why the behavior was likely chosen.
Whether an issue or pull request documented the decision.
```

---

# Primer 20 Reference: Search Command Cheat Sheet

## Find Files

### macOS, Linux, or Git Bash

```bash
find . -iname '*release*'
```

### Windows PowerShell

```powershell
Get-ChildItem -Recurse -File | Where-Object { $_.Name -match 'release' }
```

## Search Tracked Files

```bash
git grep -n "search text"
```

## Search Commit Messages

```bash
git log --oneline --grep="search text"
```

## Search Content History

```bash
git log -S "exact text" --all
```

## Search Patch History with a Pattern

```bash
git log -G "regular-expression" -p --all
```

## Search File History

```bash
git log --oneline -- <file-path>
```

## Search GitHub Issues

```bash
gh issue list --search "search text"
```

## Search GitHub Pull Requests

```bash
gh pr list --search "search text"
```

## Search Workflow Files

```bash
grep -RIn "permissions:" .github/workflows
```

---

# Primer 20 Completion Check

Before investigating project behavior, history, or automation, confirm that you can:

- [ ] Inspect repository structure before searching.
- [ ] Find files by name.
- [ ] Search Git-tracked files with `git grep`.
- [ ] Search local files while excluding ignored or sensitive paths.
- [ ] Search commit messages with `git log --grep`.
- [ ] Search history for changed content with `git log -S` and `git log -G`.
- [ ] Search GitHub Issues and pull requests with `gh`.
- [ ] Search workflow triggers, permissions, and secret references.
- [ ] Avoid exposing credentials through search output.
- [ ] Follow a source → tests → history → pull request → issue investigation routine.
