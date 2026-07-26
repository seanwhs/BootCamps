# Primer 2: Terminal, Git, npm, and Local Development Foundations

This primer prepares you to work comfortably with the command line and the project tools used throughout the LaunchPad series.

You will learn:

- How to navigate directories
- How to create, inspect, move, and remove files
- How npm manages project packages
- How Git records changes
- How environment files work
- How to read common command output
- How to avoid common local-development mistakes

---

## 1. What Is a Terminal?

A terminal is a text-based interface for interacting with your computer.

Instead of clicking folders and buttons, you type commands.

Example:

```bash
pwd
```

On macOS, Linux, and Git Bash, this prints the current directory.

Example output:

```text
/Users/your-name/projects/launchpad
```

On PowerShell, use:

```powershell
Get-Location
```

---

## 2. Important Directories

A directory is another name for a folder.

LaunchPad’s project root is the directory containing files such as:

```text
package.json
next.config.ts
src/
database/
scripts/
```

A typical location may look like:

```text
projects/
└── launchpad/
    ├── package.json
    ├── src/
    ├── database/
    └── scripts/
```

Before running commands, verify that you are in the project root.

macOS, Linux, or Git Bash:

```bash
pwd
```

PowerShell:

```powershell
Get-Location
```

---

## 3. Navigate Directories

### List directory contents

macOS, Linux, or Git Bash:

```bash
ls
```

PowerShell:

```powershell
Get-ChildItem
```

You should see project files such as:

```text
package.json
src
database
scripts
```

---

### Move into a directory

```bash
cd launchpad
```

Move into a nested path:

```bash
cd src/app
```

---

### Move up one directory

```bash
cd ..
```

If you are here:

```text
projects/launchpad
```

then:

```bash
cd ..
```

moves you to:

```text
projects
```

---

### Move to your home directory

macOS, Linux, or Git Bash:

```bash
cd ~
```

PowerShell:

```powershell
cd $HOME
```

---

## 4. Create Directories and Files

### Create a directory

macOS, Linux, or Git Bash:

```bash
mkdir docs
```

PowerShell:

```powershell
New-Item -ItemType Directory docs
```

---

### Create nested directories

macOS, Linux, or Git Bash:

```bash
mkdir -p src/components/forms
```

PowerShell:

```powershell
New-Item `
  -ItemType Directory `
  -Force `
  src/components/forms
```

The `-p` option creates missing parent directories automatically.

---

### Create an empty file

macOS, Linux, or Git Bash:

```bash
touch docs/notes.md
```

PowerShell:

```powershell
New-Item `
  -ItemType File `
  -Force `
  docs/notes.md
```

---

## 5. Read File Contents

### Read a small text file

macOS, Linux, or Git Bash:

```bash
cat package.json
```

PowerShell:

```powershell
Get-Content package.json
```

---

### Read a file with line numbers

macOS or Linux:

```bash
nl -ba src/app/page.tsx
```

PowerShell:

```powershell
Get-Content src/app/page.tsx |
  ForEach-Object -Begin {
    $lineNumber = 1
  } -Process {
    "{0,4}: {1}" -f $lineNumber, $_
    $lineNumber++
  }
```

Line numbers are useful when TypeScript, ESLint, or Next.js reports an error location.

---

### Search text in files

macOS, Linux, or Git Bash:

```bash
grep -R "requireUser" src
```

PowerShell:

```powershell
Get-ChildItem src -Recurse -File |
  Select-String -Pattern "requireUser"
```

This is useful when you need to find all places that call a function.

---

## 6. Copy, Move, and Remove Files

### Copy a file

macOS, Linux, or Git Bash:

```bash
cp .env.example .env.local
```

PowerShell:

```powershell
Copy-Item .env.example .env.local
```

This is a common first step when creating local configuration.

---

### Move or rename a file

macOS, Linux, or Git Bash:

```bash
mv old-name.ts new-name.ts
```

PowerShell:

```powershell
Move-Item old-name.ts new-name.ts
```

---

### Remove a file

macOS, Linux, or Git Bash:

```bash
rm temporary-file.txt
```

PowerShell:

```powershell
Remove-Item temporary-file.txt
```

Be careful: terminal deletion usually does not move files to a graphical recycle bin.

---

## 7. Node.js and npm

### Node.js

Node.js runs JavaScript outside the browser.

Next.js uses Node.js to:

- Start the development server
- Build production output
- Run scripts
- Connect to PostgreSQL
- Run migration and smoke-test scripts

Check your version:

```bash
node --version
```

---

### npm

npm is the Node Package Manager.

It installs packages and runs commands declared in:

```text
package.json
```

Check its version:

```bash
npm --version
```

---

## 8. `package.json`

The `package.json` file describes the project.

Example scripts:

```json
{
  "scripts": {
    "dev": "next dev --turbopack",
    "build": "next build",
    "start": "next start",
    "lint": "eslint",
    "typecheck": "tsc --noEmit"
  }
}
```

Run a script with:

```bash
npm run script-name
```

Examples:

```bash
npm run dev
npm run lint
npm run build
```

List available scripts:

```bash
npm run
```

---

## 9. Install Dependencies

### Install packages from `package.json`

```bash
npm install
```

This installs dependencies and may update:

```text
package-lock.json
```

Use it during ordinary local development when dependencies changed.

---

### Install exactly from the lock file

```bash
npm ci
```

Use `npm ci` when:

- Starting from a clean checkout
- Running CI
- Preparing a reproducible build
- Diagnosing dependency inconsistencies

`npm ci` removes the current `node_modules` directory and installs exactly what `package-lock.json` specifies.

---

### Add a production dependency

```bash
npm install zod
```

This records the package in:

```text
dependencies
```

---

### Add a development-only dependency

```bash
npm install --save-dev @next/bundle-analyzer
```

This records the package in:

```text
devDependencies
```

---

## 10. `node_modules` and `.next`

Two directories are generated locally.

### `node_modules`

Contains installed npm packages.

```text
node_modules/
```

Do not commit it to Git.

Recreate it with:

```bash
npm install
```

or:

```bash
npm ci
```

---

### `.next`

Contains generated Next.js build output.

```text
.next/
```

Do not commit it to Git.

Recreate it with:

```bash
npm run build
```

---

## 11. Common npm Workflow

A normal LaunchPad development session may look like:

```bash
npm run db:start
npm run dev
```

In another terminal:

```bash
npm run typecheck
npm run lint
```

Before a commit:

```bash
npm run typecheck
npm run lint
npm run build
```

Before a deployment:

```bash
npm ci
npm run typecheck
npm run lint
npm run build
npm run smoke
```

---

## 12. Git Fundamentals

Git records source-code history.

Think of Git as a timeline of deliberate project snapshots.

Useful Git concepts:

| Term | Meaning |
|---|---|
| Repository | A project tracked by Git |
| Working tree | Current local files |
| Staged changes | Files selected for the next commit |
| Commit | Saved snapshot with a message |
| Branch | Separate line of development |
| Remote | Hosted copy, often GitHub |
| Push | Send commits to remote |
| Pull | Download remote changes |

---

## 13. Check Repository Status

Run:

```bash
git status
```

Example output:

```text
On branch main
nothing to commit, working tree clean
```

This means:

- You are on the `main` branch.
- No files changed since the latest commit.

Example changed output:

```text
Changes not staged for commit:
  modified: src/app/page.tsx

Untracked files:
  docs/new-note.md
```

This means:

- `page.tsx` changed but is not staged.
- `docs/new-note.md` exists but Git is not tracking it yet.

---

## 14. Inspect Changes Before Committing

Show unstaged changes:

```bash
git diff
```

Show a short summary:

```bash
git diff --stat
```

Stage files:

```bash
git add src/app/page.tsx
```

Stage several paths:

```bash
git add src database scripts
```

Stage everything carefully:

```bash
git add .
```

Inspect staged changes:

```bash
git diff --cached
```

Inspect staged summary:

```bash
git diff --cached --stat
```

---

## 15. Create a Commit

Create a commit after verification:

```bash
git commit -m "feat: add project archive workflow"
```

Useful conventional prefixes:

| Prefix | Meaning |
|---|---|
| `feat:` | New user-facing capability |
| `fix:` | Bug fix |
| `perf:` | Measurable performance improvement |
| `docs:` | Documentation change |
| `test:` | Test change |
| `ci:` | CI workflow change |
| `chore:` | Maintenance or configuration |
| `refactor:` | Internal restructuring without behavior change |

Inspect latest commit:

```bash
git log -1 --oneline
```

Example:

```text
abc1234 feat: add project archive workflow
```

---

## 16. Git Ignore Rules

The `.gitignore` file tells Git which generated or private files should not be committed.

Important ignored paths include:

```text
node_modules/
.next/
.env.local
```

Verify that a private local environment file is ignored:

```bash
git check-ignore .env.local
```

Expected output:

```text
.env.local
```

If Git already tracks a file, adding it to `.gitignore` does not automatically remove it from history.

---

## 17. Environment Files

### `.env.example`

Safe, committed configuration documentation.

Example:

```dotenv
APP_URL=http://localhost:3000
DATABASE_SSL=false
LOG_LEVEL=info
APP_VERSION=development
```

### `.env.local`

Private local configuration.

Example:

```dotenv
DATABASE_URL=postgresql://...
```

Rules:

```text
- Commit .env.example.
- Do not commit .env.local.
- Do not place production secrets in either source code or examples.
- Restart the development server after changing environment values.
```

---

## 18. Common Terminal Errors

### `command not found`

Example:

```text
npm: command not found
```

Cause:

```text
Node.js or npm is not installed, or terminal environment is stale.
```

Fix:

1. Install Node.js.
2. Close and reopen the terminal.
3. Run:

   ```bash
   node --version
   npm --version
   ```

---

### `No such file or directory`

Example:

```text
No such file or directory: package.json
```

Cause:

```text
You are in the wrong directory.
```

Fix:

```bash
pwd
ls
```

Then move to the project root:

```bash
cd path/to/launchpad
```

---

### `EADDRINUSE`

Example:

```text
Error: listen EADDRINUSE: address already in use :::3000
```

Cause:

```text
Another process already uses port 3000.
```

Fix options:

Stop the other Next.js server.

Or run on another port:

```bash
npm run dev -- --port 3001
```

Then open:

```text
http://localhost:3001
```

---

### `Cannot find module`

Cause:

```text
A package is missing, a path is wrong, or a file was renamed.
```

First try:

```bash
npm install
npm run typecheck
```

Then inspect the import path and file name.

---

## 19. Primer Verification Exercise

From the LaunchPad project root, run:

```bash
pwd
ls
git status
npm run typecheck
npm run lint
```

Then confirm the local environment file is ignored:

```bash
git check-ignore .env.local
```

Finally, list available project scripts:

```bash
npm run
```

You should now be able to identify commands for:

```text
Development server
Production build
Type checking
Linting
Database migration
Database seeding
Smoke tests
```

---

## 20. Primer Completion Checklist

Before returning to the main series, confirm that you can:

- [ ] Identify the LaunchPad project root.
- [ ] Use `cd`, `ls`, and `pwd`.
- [ ] Create directories with `mkdir`.
- [ ] Read files with `cat` or `Get-Content`.
- [ ] Search source files with `grep` or `Select-String`.
- [ ] Run npm scripts.
- [ ] Explain the difference between `npm install` and `npm ci`.
- [ ] Explain why `node_modules` is not committed.
- [ ] Run `git status`.
- [ ] Inspect changes with `git diff`.
- [ ] Stage changes with `git add`.
- [ ] Create a commit with `git commit`.
- [ ] Explain why `.env.local` must stay out of Git.
- [ ] Run type checking, linting, and production builds.
- [ ] Recognize common terminal and Next.js command errors.
