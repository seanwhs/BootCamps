# Primer 2: Markdown, Code Editors, and Documentation Basics

Git tracks every kind of file, but software repositories commonly contain plain-text documentation files.

You have already seen names such as:

```text
README.md
CONTRIBUTING.md
SECURITY.md
RELEASE_NOTES.md
```

The `.md` extension means **Markdown**.

Markdown is a simple text format for writing documentation with headings, lists, links, code blocks, tables, and checklists. GitHub automatically renders Markdown files as formatted web pages.

Think of Markdown as a set of lightweight formatting hints:

```md
# Main heading
```

becomes:

# Main heading

And:

```md
- First item
- Second item
```

becomes:

- First item
- Second item

This primer gives you the documentation skills needed for repository READMEs, issues, pull requests, release notes, and contribution guides.

---

# P2.1 Understand Plain Text and Markdown

## The Target

Understand why repositories use Markdown rather than word-processing documents for project documentation.

## The Concept

A Word document, PDF, or presentation file may look polished, but it is difficult for Git to compare and merge when multiple people edit it.

Markdown is plain text.

That means Git can clearly show changes:

```diff
- Install Node.js version 18.
+ Install Node.js version 20.
```

Markdown is useful because it is:

- Easy to read without special software.
- Easy to edit in any code editor.
- Easy for Git to compare line by line.
- Automatically rendered by GitHub.
- Portable across operating systems.

A Markdown file is still a normal text file. You can open it with:

```bash
cat README.md
```

or in an editor such as Visual Studio Code.

## The Implementation

Create a temporary Markdown practice folder.

### macOS, Linux, or Git Bash

```bash
mkdir -p ~/projects/markdown-practice
cd ~/projects/markdown-practice
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path "$HOME\projects\markdown-practice" -Force
Set-Location "$HOME\projects\markdown-practice"
```

Create this file.

### `markdown-practice/README.md`

```md
# Markdown Practice

This file is written in plain text using Markdown formatting.

Markdown is useful because it is readable in an editor and easy for Git to track.
```

Open the folder in Visual Studio Code:

```bash
code .
```

## The Verification

Display the file in the terminal.

### macOS, Linux, or Git Bash

```bash
cat README.md
```

### Windows PowerShell

```powershell
Get-Content README.md
```

You should see the Markdown characters exactly as written:

```text
# Markdown Practice
```

In Visual Studio Code, open the preview:

- Use **Ctrl+Shift+V** on Windows or Linux.
- Use **Cmd+Shift+V** on macOS.

The preview should display a large heading:

```text
Markdown Practice
```

without the `#` symbol.

---

# P2.2 Create Headings

## The Target

Use Markdown headings to organize a document into clear sections.

## The Concept

Headings are like signs in a building. They help readers understand where they are and find the section they need.

Markdown uses one or more `#` characters:

| Markdown | Meaning |
|---|---|
| `# Heading` | Main page title |
| `## Heading` | Main section |
| `### Heading` | Subsection |
| `#### Heading` | Smaller subsection |

Use one level-one heading (`#`) as the document title. Then use `##` for major sections.

## The Implementation

Replace `README.md` with this complete content.

### `markdown-practice/README.md`

```md
# Markdown Practice

This file is written in plain text using Markdown formatting.

## Purpose

Markdown is useful because it is readable in an editor and easy for Git to track.

## Topics

### Headings

Headings organize documentation into readable sections.

### Lists

Lists group related information.

### Code Blocks

Code blocks preserve command and source-code formatting.
```

Save the file.

## The Verification

Open the Markdown preview in Visual Studio Code.

You should see this structure:

```text
Markdown Practice
    Purpose
    Topics
        Headings
        Lists
        Code Blocks
```

The indentation above illustrates heading hierarchy; the rendered preview will show headings at different text sizes.

---

# P2.3 Create Ordered and Unordered Lists

## The Target

Use lists to describe related steps, rules, or features.

## The Concept

Lists are easier to scan than dense paragraphs.

Use an unordered list when item order does not matter:

```md
- Git
- Node.js
- Visual Studio Code
```

Use an ordered list when readers must follow steps in order:

```md
1. Create a branch.
2. Make changes.
3. Run tests.
```

GitHub renders both formats automatically.

## The Implementation

Add the following sections to the end of `README.md`.

### `markdown-practice/README.md` — append this content

```md
## Required Tools

- Git
- Node.js
- npm
- A code editor
- A GitHub account

## Basic Workflow

1. Start from an updated `main` branch.
2. Create a focused feature branch.
3. Make and test changes.
4. Commit the intended files.
5. Push the branch.
6. Open a pull request.
```

Your complete file should now be:

### `markdown-practice/README.md`

```md
# Markdown Practice

This file is written in plain text using Markdown formatting.

## Purpose

Markdown is useful because it is readable in an editor and easy for Git to track.

## Topics

### Headings

Headings organize documentation into readable sections.

### Lists

Lists group related information.

### Code Blocks

Code blocks preserve command and source-code formatting.

## Required Tools

- Git
- Node.js
- npm
- A code editor
- A GitHub account

## Basic Workflow

1. Start from an updated `main` branch.
2. Create a focused feature branch.
3. Make and test changes.
4. Commit the intended files.
5. Push the branch.
6. Open a pull request.
```

## The Verification

View the Markdown preview.

Confirm that:

- **Required Tools** shows bullet points.
- **Basic Workflow** shows numbered steps.
- Inline code formatting renders `main` and `npm` in a fixed-width font style.

---

# P2.4 Format Inline Code, Emphasis, and Links

## The Target

Use inline formatting to make commands, file names, warnings, and links easier to understand.

## The Concept

Inline formatting highlights important details without creating a new section.

| Purpose | Markdown syntax | Example result |
|---|---|---|
| Inline code | `` `git status` `` | `git status` |
| Bold text | `**important**` | **important** |
| Italic text | `*note*` | *note* |
| Link | `[text](URL)` | [GitHub](https://github.com) |

Use inline code for technical names:

```md
Run `npm test` before opening a pull request.
```

Use bold sparingly for important warnings:

```md
**Do not commit secrets.**
```

## The Implementation

Append this section to `README.md`.

### `markdown-practice/README.md` — append this content

```md
## Important Rules

Run `git status` before using an unfamiliar Git command.

**Do not commit passwords, API keys, tokens, private keys, or real `.env` files.**

Use *focused* commits so each commit has one clear purpose.

Learn more at [GitHub Docs](https://docs.github.com/).
```

## The Verification

In the rendered preview, confirm that:

- `git status` appears as inline code.
- The warning appears in bold.
- The word *focused* appears in italic text.
- **GitHub Docs** is a clickable link.

Do not use bold formatting for every sentence. If everything is emphasized, nothing stands out.

---

# P2.5 Create Code Blocks

## The Target

Document terminal commands and source code without Markdown changing their formatting.

## The Concept

A code block preserves spaces, indentation, and symbols.

Use triple backticks before and after the code:

````md
```bash
git status
npm test
```
````

The word after the opening backticks is an optional **language identifier**. It enables syntax highlighting on GitHub and in many editors.

Common identifiers include:

```text
bash
powershell
js
json
yaml
md
text
```

## The Implementation

Append this section to `README.md`.

### `markdown-practice/README.md` — append this content

````md
## Verification Commands

Run these commands before opening a pull request:

```bash
git status
git diff main...HEAD
npm test
```

PowerShell users can inspect the current location with:

```powershell
Get-Location
```

The formatter API uses JavaScript:

```js
const release = {
  version: "1.0.0",
  releaseDate: "2026-07-25"
};
```
````

## The Verification

In the Markdown preview, confirm:

- Commands appear in separate fixed-width blocks.
- JavaScript appears as a separate code block.
- Quotes, braces, and indentation are preserved.
- Markdown does not render commands as ordinary paragraphs.

---

# P2.6 Create Task Lists

## The Target

Use Markdown checklists for acceptance criteria, reviews, releases, and project planning.

## The Concept

A task list makes work visible and measurable.

Unchecked item:

```md
- [ ] Run tests.
```

Checked item:

```md
- [x] Run tests.
```

GitHub renders these as interactive checkboxes in issues and pull requests. In ordinary repository files, they are visual checklists.

Use task lists for outcomes that can be verified.

Good checklist item:

```md
- [ ] Add regression tests for invalid dates.
```

Weak checklist item:

```md
- [ ] Make it better.
```

## The Implementation

Append this section to `README.md`.

### `markdown-practice/README.md` — append this content

```md
## Pull Request Checklist

- [x] Review the local Git diff.
- [x] Run `npm test`.
- [ ] Request pull request review.
- [ ] Confirm required CI checks pass.
- [ ] Merge only after required approvals are present.
```

## The Verification

View the rendered Markdown preview.

You should see:

- Two checked checkboxes.
- Three unchecked checkboxes.
- Inline code formatting around `npm test`.

---

# P2.7 Create a Simple Table

## The Target

Use a table when readers need to compare structured information.

## The Concept

Tables are useful for small comparison grids.

For example, this Markdown:

```md
| Command | Purpose |
|---|---|
| `git status` | Inspect repository state |
```

renders as:

| Command | Purpose |
|---|---|
| `git status` | Inspect repository state |

Tables are best for concise data. Avoid putting long paragraphs inside cells.

## The Implementation

Append this section to `README.md`.

### `markdown-practice/README.md` — append this content

```md
## Common Commands

| Command | Purpose |
|---|---|
| `git status` | Show repository state. |
| `git diff` | Show unstaged changes. |
| `git diff --staged` | Show the next commit's contents. |
| `git log --oneline` | Show compact commit history. |
| `npm test` | Run automated tests. |
```

## The Verification

Open the Markdown preview.

Confirm the table has:

- A header row.
- Two columns.
- One row for each command.
- Inline code formatting in the command column.

---

# P2.8 Write a Useful README Structure

## The Target

Learn the minimum structure of a useful project README.

## The Concept

A README is the front door of a repository.

A new visitor should be able to answer:

```text
What is this project?
Why does it exist?
How do I set it up?
How do I verify it works?
Where can I find contribution and security guidance?
```

A simple README structure is:

```text
# Project Name
Short description

## Purpose
Why the project exists

## Requirements
What someone needs before using it

## Setup
How to install or prepare it

## Usage
How to use it

## Verification
How to run tests or checks

## Contributing
Where contribution guidance lives

## Security
Where to report vulnerabilities
```

## The Implementation

Replace `README.md` with this complete final practice version.

### `markdown-practice/README.md`

````md
# Markdown Practice

Markdown Practice is a small documentation exercise for learning how repository files render on GitHub.

## Purpose

This project demonstrates headings, lists, code blocks, links, task lists, and tables.

## Requirements

- Git
- A terminal
- A text editor such as Visual Studio Code
- Optional: a GitHub account for rendered Markdown previews

## Setup

Clone or create the project folder, then open it in a code editor:

```bash
code .
```

## Usage

Read and edit `README.md` using Markdown syntax.

Use `#` for headings, backticks for inline code, and triple backticks for code blocks.

## Verification

Inspect the document in a terminal:

```bash
cat README.md
```

Open the Markdown preview in Visual Studio Code:

```text
Ctrl+Shift+V on Windows or Linux
Cmd+Shift+V on macOS
```

## Pull Request Checklist

- [x] Review the local Git diff.
- [x] Run `npm test` when the project has tests.
- [ ] Request pull request review.
- [ ] Confirm required CI checks pass.
- [ ] Merge only after required approvals are present.

## Common Commands

| Command | Purpose |
|---|---|
| `git status` | Show repository state. |
| `git diff` | Show unstaged changes. |
| `git diff --staged` | Show the next commit's contents. |
| `git log --oneline` | Show compact commit history. |
| `npm test` | Run automated tests. |

## Contributing

Keep documentation clear, use focused commits, and review changes before committing them.

## Security

**Do not commit passwords, API keys, tokens, private keys, or real `.env` files.**

Read [GitHub Security Documentation](https://docs.github.com/code-security) for more information.
````

## The Verification

Open the preview and confirm it contains:

- A title.
- Multiple headings.
- Bullet lists.
- A code block.
- A task list.
- A table.
- A hyperlink.
- A security warning.

---

# P2.9 Clean Up the Markdown Practice Folder

## The Target

Remove the disposable Markdown practice folder before beginning or continuing repository work.

## The Concept

This folder exists only for practice. It is not part of the Release Notes Manager repository.

Deleting it now keeps your `projects` folder organized.

### The Implementation

Move to the parent projects folder.

```bash
cd ..
```

Delete the practice folder.

### macOS, Linux, or Git Bash

```bash
rm -rf markdown-practice
```

### Windows PowerShell

```powershell
Remove-Item -Recurse -Force markdown-practice
```

### The Verification

List the projects folder.

### macOS, Linux, or Git Bash

```bash
ls
```

### Windows PowerShell

```powershell
Get-ChildItem
```

Confirm that:

```text
markdown-practice
```

no longer appears.

---

# Primer 2 Reference: Markdown Cheat Sheet

## Headings

```md
# Title
## Section
### Subsection
```

## Unordered List

```md
- First item
- Second item
```

## Ordered List

```md
1. First step
2. Second step
```

## Inline Code

```md
Run `git status`.
```

## Bold and Italic

```md
**Important warning**
*Helpful note*
```

## Link

```md
[GitHub](https://github.com)
```

## Code Block

````md
```bash
git status
```
````

## Task List

```md
- [ ] Incomplete task
- [x] Completed task
```

## Table

```md
| Name | Purpose |
|---|---|
| `git status` | Inspect state |
```

---

# Primer 2 Completion Check

Before continuing with the main series, confirm that you can:

- [ ] Explain why Markdown is useful in Git repositories.
- [ ] Create headings with `#`, `##`, and `###`.
- [ ] Write ordered and unordered lists.
- [ ] Format commands and filenames with inline code.
- [ ] Add links, bold text, and italic text.
- [ ] Write fenced code blocks with language identifiers.
- [ ] Create task lists for acceptance criteria.
- [ ] Create a small Markdown table.
- [ ] Read and preview a `README.md` file in Visual Studio Code.
- [ ] Recognize the basic structure of a useful repository README.
