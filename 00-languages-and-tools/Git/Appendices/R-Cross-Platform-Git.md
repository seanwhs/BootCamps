# Appendix R: Cross-Platform Git — Line Endings, File Modes, and `.gitattributes`

Git repositories are often used across macOS, Linux, and Windows.

That sounds ordinary, but operating systems differ in ways that can create noisy diffs, broken scripts, and confusing “every line changed” pull requests.

This appendix explains how to keep a repository consistent across platforms by managing:

- Text-file line endings.
- Executable file permissions.
- Binary-file behavior.
- Diff and merge attributes.
- Generated-file handling.
- `.gitattributes` rules.

The key file is:

```text
.gitattributes
```

Think of `.gitattributes` as a handling label for files in a repository:

```text
Text file         → normalize line endings
Shell script      → preserve executable behavior
Binary asset      → do not attempt text diffs
Generated file    → optionally mark as generated in reviews
```

---

# R.1 Understand the Line-Ending Problem

## The Target

Understand why the same text file can appear changed on one operating system but unchanged on another.

## The Concept

Text files separate lines using invisible characters.

The two common line-ending styles are:

| Name | Characters | Common platform |
|---|---|---|
| LF | Line Feed: `\n` | Linux and macOS |
| CRLF | Carriage Return + Line Feed: `\r\n` | Windows |

A file can display identically in an editor while storing different line-ending bytes.

For example, this Markdown file:

```md
# Release Notes
```

might end its lines as:

```text
# Release Notes\n
```

or:

```text
# Release Notes\r\n
```

Without a repository policy, one contributor may save a file with LF while another saves it with CRLF. Git may then show an enormous diff even though the visible words did not change.

That creates noise:

```diff
- Every old line appears removed
+ Every new line appears added
```

The actual content may be identical. Only invisible line endings changed.

---

# R.2 Understand `core.autocrlf`

## The Target

Understand Git’s local line-ending configuration before defining repository rules.

## The Concept

Git has a local or global setting named:

```text
core.autocrlf
```

It controls how Git may convert line endings between repository storage and the working directory.

Common values:

| Value | Typical use | Behavior |
|---|---|---|
| `true` | Some Windows environments | Converts LF in Git to CRLF in working files and converts CRLF back to LF when committing |
| `input` | macOS and Linux | Converts CRLF to LF when committing but does not convert LF to CRLF when checking out |
| `false` | Explicit repository attribute strategy | Does not automatically convert based only on this setting |

Modern teams should prefer committed `.gitattributes` rules because they travel with the repository and apply consistently to every contributor.

## The Implementation

Inspect your active setting:

```bash
git config --show-origin --get core.autocrlf
```

If no output appears, Git is using its default behavior or relying on attributes.

Recommended local defaults:

### macOS or Linux

```bash
git config --global core.autocrlf input
```

### Windows

```bash
git config --global core.autocrlf true
```

If your organization provides a specific setup policy, follow that policy instead.

## The Verification

Check the configured value:

```bash
git config --global core.autocrlf
```

Expected output on macOS or Linux:

```text
input
```

Expected output on Windows:

```text
true
```

Remember: this is a local developer preference. The repository-level `.gitattributes` file is the shared source of truth.

---

# R.3 Add a Repository-Wide `.gitattributes` File

## The Target

Create a committed `.gitattributes` file that defines predictable handling for text, scripts, binaries, and generated files.

## The Concept

A `.gitattributes` file tells Git how to treat matching file paths.

The most important baseline rule is:

```gitattributes
* text=auto
```

This tells Git:

> “Detect normal text files and normalize their stored line endings.”

Then you can specify rules for known file types.

For example:

```gitattributes
*.sh text eol=lf
```

This ensures shell scripts use LF endings. That matters because CRLF line endings can break scripts on Linux runners with errors such as:

```text
/usr/bin/env: 'sh\r': No such file or directory
```

## The Implementation

Create this file in the repository root.

### `release-notes-manager/.gitattributes`

```gitattributes
# Detect text files automatically and normalize their line endings in Git.
* text=auto

# Keep source code, configuration, and documentation as LF in every checkout.
*.js text eol=lf
*.json text eol=lf
*.md text eol=lf
*.yml text eol=lf
*.yaml text eol=lf
*.sh text eol=lf
*.txt text eol=lf
*.env.example text eol=lf

# Windows command scripts need CRLF endings when they are intentionally added.
*.bat text eol=crlf
*.cmd text eol=crlf

# Treat common binary assets as binary data. Git should not attempt line-ending
# normalization or text diff behavior for these file types.
*.png binary
*.jpg binary
*.jpeg binary
*.gif binary
*.webp binary
*.ico binary
*.pdf binary
*.zip binary
*.gz binary
*.mp4 binary
*.mov binary
*.psd binary

# Git LFS-managed assets are binary and should not be treated as text.
*.mp4 filter=lfs diff=lfs merge=lfs -text
*.psd filter=lfs diff=lfs merge=lfs -text

# Mark generated dependency lockfiles as generated for GitHub language analysis
# and review tooling. Keep them tracked because reproducible installs depend on them.
package-lock.json linguist-generated=true
```

Create a branch:

```bash
git switch main
git pull --ff-only
git switch -c chore/add-gitattributes
```

Inspect the file:

```bash
git diff -- .gitattributes
```

Stage it:

```bash
git add .gitattributes
```

Review staged content:

```bash
git diff --staged -- .gitattributes
```

Run tests:

```bash
npm test
```

Commit and push:

```bash
git commit -m "chore(git): define cross-platform file attributes"
git push -u origin chore/add-gitattributes
```

## The Verification

Inspect Git’s attributes for representative files:

```bash
git check-attr text eol -- README.md
git check-attr text eol -- src/releaseNotes.js
git check-attr text eol -- scripts/install-hooks.sh
git check-attr binary -- example.png
```

Expected results resemble:

```text
README.md: text: set
README.md: eol: lf
src/releaseNotes.js: text: set
src/releaseNotes.js: eol: lf
scripts/install-hooks.sh: text: set
scripts/install-hooks.sh: eol: lf
example.png: binary: set
```

Open a pull request and merge the `.gitattributes` change through the normal review process.

---

# R.4 Renormalize Existing Text Files Safely

## The Target

Apply newly added line-ending rules to existing tracked files without mixing this change with functional edits.

## The Concept

Adding `.gitattributes` affects how Git handles files going forward. Existing tracked files may still have older line-ending representations in the index.

The command:

```bash
git add --renormalize .
```

asks Git to re-evaluate tracked files using the new attribute rules.

This can produce many changed files. That is expected if the repository previously had inconsistent line endings.

Because normalization changes can make a pull request noisy, perform them in a dedicated commit. Do not combine them with feature work.

## The Implementation

First, ensure the `.gitattributes` pull request has merged and local `main` is current:

```bash
git switch main
git pull --ff-only
git status
```

Create a dedicated branch:

```bash
git switch -c chore/renormalize-line-endings
```

Run:

```bash
git add --renormalize .
```

Inspect the staged summary:

```bash
git diff --staged --stat
```

Inspect the staged patch without whitespace noise:

```bash
git diff --staged --ignore-space-at-eol
```

If the change set contains only line-ending normalization and no accidental content edits, commit it:

```bash
git commit -m "chore(git): normalize text file line endings"
```

Push the branch:

```bash
git push -u origin chore/renormalize-line-endings
```

## The Verification

Review the pull request carefully.

Expected characteristics:

```text
[ ] No functional code behavior changed.
[ ] No text content changed unintentionally.
[ ] The diff is limited to line-ending normalization.
[ ] Tests still pass.
[ ] The normalization commit is separate from feature commits.
```

Run tests:

```bash
npm test
```

If the diff is unexpectedly large or includes unwanted files, do not merge yet. Reset the staged normalization and investigate:

```bash
git restore --staged .
git status
```

---

# R.5 Understand Executable File Modes

## The Target

Understand why a script may work on one computer but fail in CI or on another operating system.

## The Concept

On macOS and Linux, files can have an executable permission bit.

For example:

```text
100644 = ordinary file
100755 = executable file
```

A shell script may need executable mode to run directly:

```bash
./scripts/install-hooks.sh
```

If the file is not executable, users may see:

```text
Permission denied
```

Git tracks the executable bit for files. It does not track every operating-system permission.

Windows handles executable behavior differently, so scripts should remain runnable through an explicit interpreter when appropriate:

```powershell
bash ./scripts/install-hooks.sh
```

## The Implementation

Inspect the mode of the hook installation script:

```bash
git ls-files --stage scripts/install-hooks.sh
```

Expected mode for an executable script:

```text
100755 <hash> 0    scripts/install-hooks.sh
```

If the mode is `100644`, make the file executable.

### macOS, Linux, or Git Bash

```bash
chmod +x scripts/install-hooks.sh
git add scripts/install-hooks.sh
git diff --staged --summary
```

Git should show:

```text
mode change 100644 => 100755 scripts/install-hooks.sh
```

On Windows, use Git Bash when you need to modify executable mode:

```bash
chmod +x scripts/install-hooks.sh
git add scripts/install-hooks.sh
```

## The Verification

Run:

```bash
git diff --staged --summary
```

Expected output resembles:

```text
mode change 100644 => 100755 scripts/install-hooks.sh
```

Test the script:

### macOS, Linux, or Git Bash

```bash
./scripts/install-hooks.sh
```

### Windows PowerShell

```powershell
bash ./scripts/install-hooks.sh
```

If you changed the mode, commit it as a focused maintenance commit:

```bash
git commit -m "chore(scripts): mark hook installer executable"
```

---

# R.6 Prevent Incorrect File-Mode Diffs

## The Target

Avoid noisy executable-bit changes caused by filesystems or development environments that do not preserve Unix-style file modes reliably.

## The Concept

Some Windows filesystems and mounted drives may report file-mode changes inconsistently.

Git may show unexpected modifications such as:

```text
old mode 100644
new mode 100755
```

even when you did not intentionally make a script executable.

If your environment cannot reliably track file modes, you can configure Git locally:

```bash
git config core.fileMode false
```

This tells Git to ignore executable-bit differences in that repository.

Use this only if the project does not rely heavily on executable scripts or if your team has agreed on this configuration.

Do not set it blindly in a repository where scripts must retain executable permissions for Linux CI or deployment systems.

## The Implementation

Inspect the current setting:

```bash
git config --show-origin --get core.fileMode
```

If your environment repeatedly produces false mode changes and your team has approved ignoring them, set:

```bash
git config core.fileMode false
```

Inspect the setting:

```bash
git config --get core.fileMode
```

## The Verification

Expected output:

```text
false
```

Before using this setting permanently, confirm whether the repository needs executable scripts:

```bash
git ls-files --stage | grep '^100755'
```

On Windows PowerShell:

```powershell
git ls-files --stage | Select-String '^100755'
```

If executable scripts are important, prefer fixing the environment rather than globally ignoring file mode changes.

---

# R.7 Mark Generated Files Clearly

## The Target

Use attributes to identify generated files that should not dominate code review or language statistics.

## The Concept

Some files are tracked because they are needed for reproducible builds, but humans should not edit them manually.

Examples include:

```text
package-lock.json
Generated API clients
Bundled JavaScript
Compiled documentation output
```

GitHub recognizes some `.gitattributes` metadata, including:

```gitattributes
linguist-generated=true
```

This can reduce noise in GitHub language statistics and code views.

It does not prevent Git from tracking the file.

## The Implementation

Suppose the project later generates files into:

```text
generated/
```

Add this rule:

### `release-notes-manager/.gitattributes` — optional future addition

```gitattributes
# Generated files remain versioned when builds require them, but GitHub should
# identify them as generated rather than primary handwritten source code.
generated/** linguist-generated=true
```

If a file should never be committed, use `.gitignore` instead of `.gitattributes`.

For example:

```gitignore
dist/
coverage/
```

## The Verification

Use this decision table:

| File behavior | Use |
|---|---|
| Must be committed, but generated | `.gitattributes` with `linguist-generated=true` |
| Must not be committed | `.gitignore` |
| Must use Git LFS | `.gitattributes` with LFS filters |
| Must use consistent line endings | `.gitattributes` with `text` and `eol` rules |

---

# R.8 Configure a Custom Diff Driver for Markdown Documentation

## The Target

Improve readability when reviewing Markdown documentation changes.

## The Concept

Git supports custom **diff drivers**: rules that affect how it compares certain file types.

For Markdown files, a word-level diff is often easier to read than a line-level diff, especially when a paragraph changes slightly.

Git has built-in word-diff support:

```bash
git diff --word-diff README.md
```

You can also define a Markdown diff driver in `.gitattributes` and local Git config.

## The Implementation

Add this rule to `.gitattributes`:

### `release-notes-manager/.gitattributes` — add this line

```gitattributes
*.md diff=markdown
```

Configure the local diff driver:

```bash
git config diff.markdown.xfuncname '^(#{1,6}[[:space:]].*)$'
```

This configuration helps Git identify Markdown headings as useful function-like context in diffs.

Inspect a Markdown diff:

```bash
git diff --word-diff README.md
```

If no Markdown file has changes, create a temporary local edit, inspect it, then restore it.

For example, append this temporary line to `README.md`:

```md
This temporary sentence is used to inspect word-level Markdown diffs.
```

Run:

```bash
git diff --word-diff README.md
```

Restore the file afterward:

```bash
git restore README.md
```

## The Verification

Word-level output uses visible markers similar to:

```text
[-old words-]{+new words+}
```

The exact display can vary by terminal and Git configuration.

Confirm the repository is clean after restoring the temporary edit:

```bash
git status
```

---

# R.9 Use `.gitattributes` to Resolve or Avoid Merge Noise

## The Target

Understand when attributes can help Git handle difficult file types.

## The Concept

Some files should not use ordinary line-by-line merging.

For example:

- Binary files cannot be meaningfully auto-merged.
- Generated files should often be regenerated instead of manually merged.
- Lockfiles need careful review because they represent dependency resolution.

You can declare merge behavior in `.gitattributes`.

For a binary file:

```gitattributes
*.png binary
```

Git treats it as binary and will not attempt text conflict markers.

For a generated file, you might use a merge strategy only if your team has a well-tested reason. Do not add custom merge drivers casually; a wrong merge driver can silently lose changes.

The safe default is:

```text
Resolve source conflicts manually.
Regenerate generated output after the source is merged.
Review dependency lockfile changes carefully.
```

## The Implementation

No new merge driver is required for this tutorial.

Inspect binary treatment:

```bash
git check-attr -a -- example.png
```

Inspect Markdown treatment:

```bash
git check-attr -a -- README.md
```

## The Verification

Expected output for a binary asset resembles:

```text
example.png: binary: set
example.png: diff: unset
example.png: merge: unset
example.png: text: unset
```

The exact values depend on Git version and configured attributes.

---

# R.10 Cross-Platform Script Checklist

## The Target

Write scripts that run consistently on Linux, macOS, Git Bash, and CI.

## The Concept

Shell scripts are especially sensitive to:

- LF versus CRLF line endings.
- Executable mode.
- Shell availability.
- Path separators.
- Quoting behavior.
- Operating-system-specific utilities.

A script that works in one terminal can fail in CI if it assumes the wrong shell or line endings.

## The Implementation

Use this baseline shell-script structure.

### `release-notes-manager/scripts/example-portable-script.sh`

```sh
#!/usr/bin/env sh

# Exit when a command fails, when an unset variable is used, or when a pipeline
# fails. This makes script failures visible instead of silently continuing.
set -eu

PROJECT_ROOT=$(git rev-parse --show-toplevel)

printf 'Project root: %s\n' "$PROJECT_ROOT"

if [ ! -f "$PROJECT_ROOT/package.json" ]; then
  echo "ERROR: package.json was not found at the repository root."
  exit 1
fi

printf 'Node.js version: '
node --version

printf 'Running tests...\n'
cd "$PROJECT_ROOT"
npm test
```

Important portability decisions:

- `#!/usr/bin/env sh` uses a POSIX-compatible shell where available.
- `printf` is more portable and predictable than some `echo` behaviors.
- Variables are quoted:

  ```sh
  "$PROJECT_ROOT"
  ```

- `git rev-parse --show-toplevel` finds the repository root instead of assuming the current directory.

Do not commit this example file unless your project needs it. Remove it after reading:

### macOS, Linux, or Git Bash

```bash
rm scripts/example-portable-script.sh
```

### Windows PowerShell

```powershell
Remove-Item scripts\example-portable-script.sh
```

## The Verification

Confirm no temporary file remains:

```bash
git status
```

Expected output:

```text
nothing to commit, working tree clean
```

---

# R.11 Cross-Platform Repository Setup Checklist

## The Target

Ensure contributors on different operating systems can work without generating avoidable diffs.

## The Concept

A reliable cross-platform repository establishes shared rules once and avoids making each developer discover them through failure.

## The Implementation

Use this checklist:

```text
Text and line endings
[ ] .gitattributes exists at the repository root.
[ ] Text source files use LF through repository attributes.
[ ] Shell scripts use LF.
[ ] Windows command scripts use CRLF only when intentionally added.
[ ] Line-ending normalization is committed separately from functional changes.

Scripts
[ ] Required shell scripts have executable mode 100755.
[ ] Scripts use portable shebangs where possible.
[ ] Scripts quote file paths and variables.
[ ] CI runs on at least one Linux environment.
[ ] Windows-specific instructions use PowerShell or Git Bash explicitly.

Binary and generated files
[ ] Binary assets are marked binary.
[ ] Large binaries use Git LFS or external storage when appropriate.
[ ] Generated files are ignored or clearly marked generated.
[ ] Lockfiles are tracked when required for reproducibility.
```

## The Verification

Run:

```bash
git status
git diff --check
npm test
```

Expected results:

```text
nothing to commit, working tree clean
```

And:

```text
# fail 0
```

---

# R.12 `.gitattributes` Command Reference

## Inspect Attributes for One File

```bash
git check-attr -a -- README.md
```

## Inspect Text and End-of-Line Attributes

```bash
git check-attr text eol -- src/releaseNotes.js
```

## Renormalize Tracked Files

```bash
git add --renormalize .
```

## Inspect Executable Mode

```bash
git ls-files --stage scripts/install-hooks.sh
```

## Mark a File Executable

```bash
chmod +x scripts/install-hooks.sh
git add scripts/install-hooks.sh
```

## Ignore File-Mode Differences Locally

Use only when appropriate:

```bash
git config core.fileMode false
```

## Show Word-Level Documentation Diff

```bash
git diff --word-diff README.md
```

## Validate Whitespace Errors

```bash
git diff --check
```

---

# Appendix R Completion Check

You should now be able to:

- [ ] Explain LF and CRLF line-ending differences.
- [ ] Use `.gitattributes` as the repository-wide source of truth for text-file handling.
- [ ] Normalize existing text files in a dedicated maintenance commit.
- [ ] Inspect and manage executable file modes.
- [ ] Decide when `core.fileMode false` is appropriate.
- [ ] Mark binary and Git LFS-managed assets correctly.
- [ ] Distinguish `.gitattributes` from `.gitignore`.
- [ ] Use generated-file metadata without hiding required files.
- [ ] Write more portable shell scripts.
- [ ] Keep cross-platform diffs focused on real content changes.
