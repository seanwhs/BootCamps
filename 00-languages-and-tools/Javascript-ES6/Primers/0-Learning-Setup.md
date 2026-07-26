# Primer 0: Learning Setup and How to Use This Series

Before writing modern JavaScript, set up a reliable learning environment.

This primer explains:

- What you need installed
- How the project files fit together
- How to run examples
- How to verify your work
- How to approach errors without getting stuck
- How the primer, parts, and appendices relate to one another

This is not yet a JavaScript language lesson. Think of it as preparing your workbench before beginning a woodworking project. You want your tools, materials, and safety checks ready before cutting anything.

---

## Step 1: Confirm the Required Tools

### The Target

Verify that your computer has the tools needed for this tutorial series:

- A terminal
- Node.js
- npm
- A code editor

### The Concept

A **terminal** is a text-based application for running commands.

**Node.js** is a JavaScript runtime. A runtime is software that can execute JavaScript outside a web browser.

**npm** is Node.js’s package manager. It installs packages and runs project scripts.

Node.js installs npm automatically, so you normally install one package to receive both tools.

### The Implementation

Open a terminal and run:

```bash
node --version
```

Then run:

```bash
npm --version
```

For this series, use Node.js **22 or newer**.

If Node.js is not installed, download a current Long-Term Support release from:

```text
https://nodejs.org/
```

After installing it, close and reopen your terminal before rerunning the version commands.

Recommended code editors include:

- Visual Studio Code
- WebStorm
- Sublime Text
- Zed
- Vim or Neovim

Visual Studio Code is a practical beginner-friendly choice because it provides syntax highlighting, an integrated terminal, and JavaScript debugging tools.

### The Verification

Expected version output will resemble:

```text
v22.0.0
```

And:

```text
10.x.x
```

Your exact versions may be newer.

If `node` is not recognized, Node.js either is not installed or is not available in your system’s command path. Reinstall Node.js and ensure its installer adds it to your PATH.

---

## Step 2: Create a Dedicated Project Folder

### The Target

Create a directory named `modern-javascript-toolkit` for every source file in this series.

### The Concept

A project folder is like a labeled binder. Every related document belongs in one predictable place.

Keeping tutorial files in one folder prevents common beginner problems:

- Running commands from the wrong location
- Creating duplicate files in unrelated folders
- Losing track of project configuration
- Importing files with incorrect paths

### The Implementation

In macOS, Linux, Git Bash, or Windows Subsystem for Linux, run:

```bash
mkdir modern-javascript-toolkit
cd modern-javascript-toolkit
```

In Windows PowerShell, run:

```powershell
mkdir modern-javascript-toolkit
cd modern-javascript-toolkit
```

Confirm your current directory.

On macOS, Linux, Git Bash, or Windows Subsystem for Linux:

```bash
pwd
```

On Windows PowerShell:

```powershell
Get-Location
```

Create the initial source folder:

```bash
mkdir src
```

Create a minimal entry file.

### `src/index.js`

```js
console.log('Modern JavaScript Toolkit is ready.');
```

### The Verification

Run:

```bash
node src/index.js
```

Expected output:

```text
Modern JavaScript Toolkit is ready.
```

If Node.js reports that it cannot find `src/index.js`, confirm that:

1. You are inside `modern-javascript-toolkit`.
2. The file is named exactly `index.js`.
3. The file is inside the `src` folder.

---

## Step 3: Create `package.json`

### The Target

Create the project configuration file that identifies the project as an ES module project and provides convenient commands.

### The Concept

`package.json` is a JSON configuration file used by Node.js projects.

It is similar to a project information card. It can define:

- The project’s name
- The supported Node.js version
- Whether the project uses ES modules
- Scripts you can run with npm
- Dependencies and development tools added later

The `"type": "module"` setting is important because this series uses modern module syntax:

```js
import { createTask } from './task.js';
export function createTask() {}
```

Without `"type": "module"`, Node.js treats `.js` files as CommonJS by default in many project setups, and `import` / `export` statements may fail.

### The Implementation

Create the following complete file.

### `package.json`

```json
{
  "name": "modern-javascript-toolkit",
  "version": "1.0.0",
  "private": true,
  "description": "Hands-on examples for learning modern JavaScript.",
  "type": "module",
  "scripts": {
    "start": "node src/index.js",
    "check:node": "node --version"
  },
  "engines": {
    "node": ">=22.0.0"
  }
}
```

### The Verification

Run:

```bash
npm run check:node
```

Expected output resembles:

```text
> modern-javascript-toolkit@1.0.0 check:node
> node --version

v22.0.0
```

Then run the named start script:

```bash
npm start
```

Expected output:

```text
Modern JavaScript Toolkit is ready.
```

---

## Step 4: Understand the Core Project Structure

### The Target

Create the initial folder layout used by the primer and the main series.

### The Concept

Folders divide a project into understandable areas.

At the beginning, the structure will be small:

```text
modern-javascript-toolkit/
├── package.json
└── src/
    └── index.js
```

As you progress, the project grows in a predictable way:

```text
modern-javascript-toolkit/
├── package.json
├── src/
│   ├── index.js
│   ├── primers/
│   ├── part-1-syntax-ergonomics/
│   ├── part-2-expressive-syntax/
│   ├── part-3-collections-iteration/
│   ├── part-4-defensive-modern-apis/
│   └── appendices/
└── tests/
```

Each directory has one purpose:

| Directory | Purpose |
|---|---|
| `src/` | Application and tutorial source code |
| `src/primers/` | Foundational setup and JavaScript preparation exercises |
| `src/part-*` | Main tutorial modules |
| `src/appendices/` | Reference material, exercises, and compatibility tools |
| `tests/` | Automated verification code, when used |
| `package.json` | Project metadata and npm scripts |

### The Implementation

Create the initial primer directory:

```bash
mkdir -p src/primers
```

> On Windows PowerShell:

```powershell
mkdir src\primers
```

Create a simple project-information module.

### `src/primers/project-info.js`

```js
/**
 * Primer 0: Basic project information.
 *
 * Run with:
 * node src/primers/project-info.js
 */

const projectInformation = {
  name: 'Modern JavaScript Toolkit',
  runtime: 'Node.js',
  moduleSystem: 'ES modules',
  minimumNodeVersion: 22
};

console.log(projectInformation);
```

### The Verification

Run:

```bash
node src/primers/project-info.js
```

Expected output:

```text
{
  name: 'Modern JavaScript Toolkit',
  runtime: 'Node.js',
  moduleSystem: 'ES modules',
  minimumNodeVersion: 22
}
```

---

## Step 5: Learn the Basic Terminal Workflow

### The Target

Practice the commands you will repeatedly use throughout the series.

### The Concept

The terminal is a conversation with your computer.

You type an instruction:

```bash
node src/index.js
```

The computer runs it and returns output.

Most tutorial steps follow this cycle:

1. Create or edit a file.
2. Run a command.
3. Read the output.
4. Fix any issue before continuing.

### The Implementation

Use these commands from the project root.

### Show files and directories

macOS, Linux, Git Bash, or Windows Subsystem for Linux:

```bash
ls
```

Windows PowerShell:

```powershell
Get-ChildItem
```

Expected entries include:

```text
package.json
src
```

### Show the contents of `src`

macOS, Linux, Git Bash, or Windows Subsystem for Linux:

```bash
ls src
```

Windows PowerShell:

```powershell
Get-ChildItem src
```

### Run a JavaScript file directly

```bash
node src/index.js
```

### Run a named npm script

```bash
npm start
```

### List all available npm scripts

```bash
npm run
```

### Clear the terminal screen

macOS, Linux, Git Bash, or Windows Subsystem for Linux:

```bash
clear
```

Windows PowerShell:

```powershell
Clear-Host
```

### The Verification

Run:

```bash
npm run
```

Expected output includes:

```text
Scripts available in modern-javascript-toolkit:
  start
    node src/index.js
  check:node
    node --version
```

The exact formatting can differ by npm version.

---

## Step 6: Practice Reading Console Output

### The Target

Use `console.log()` and `console.table()` to inspect program values.

### The Concept

Console output is your first debugging tool.

`console.log()` prints a value. It is useful for strings, numbers, objects, arrays, and intermediate calculations.

`console.table()` displays an array of similar objects as a table. It is especially useful for lists of tasks, users, products, or records.

Think of console output as turning on a light inside a machine. You cannot fix a hidden value until you can see it.

### The Implementation

Create this file.

### `src/primers/console-output.js`

```js
/**
 * Primer 0: Console output examples.
 *
 * Run with:
 * node src/primers/console-output.js
 */

console.log('A plain text message.');

const project = {
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit',
  active: true
};

console.log('Project object:');
console.log(project);

const tasks = [
  {
    id: 'task_1',
    title: 'Install Node.js',
    completed: true
  },
  {
    id: 'task_2',
    title: 'Create project folder',
    completed: true
  },
  {
    id: 'task_3',
    title: 'Run the first JavaScript file',
    completed: false
  }
];

console.log('Task list:');
console.log(tasks);

console.log('Task table:');
console.table(tasks);

console.log({
  projectId: project.id,
  taskCount: tasks.length,
  firstTaskTitle: tasks[0].title
});
```

### The Verification

Run:

```bash
node src/primers/console-output.js
```

Expected output includes:

```text
A plain text message.
Project object:
{ id: 'project_3001', name: 'Modern JavaScript Toolkit', active: true }
```

You should also see a table containing three task rows.

---

## Step 7: Learn the Tutorial Execution Pattern

### The Target

Understand how to work through each technical module without skipping essential verification.

### The Concept

Every technical step in this series follows a repeatable four-part pattern:

1. **The Target**  
   Identifies the exact file, feature, or configuration being created.

2. **The Concept**  
   Explains why the feature exists using plain language.

3. **The Implementation**  
   Gives complete code and exact file paths.

4. **The Verification**  
   Gives a command and expected result.

Treat the verification step as part of the implementation, not as an optional extra.

A program that looks correct but has not been run is like a bridge design that has not been inspected. It may be correct, but you do not yet have evidence.

### The Implementation

Create a simple self-checking module.

### `src/primers/verification-pattern.js`

```js
/**
 * Primer 0: A tiny example of a self-verifying script.
 *
 * Run with:
 * node src/primers/verification-pattern.js
 */

/**
 * Adds two numbers.
 *
 * @param {number} firstValue - First value to add.
 * @param {number} secondValue - Second value to add.
 * @returns {number} Sum of both values.
 */
function add(firstValue, secondValue) {
  return firstValue + secondValue;
}

const expectedTotal = 5;
const actualTotal = add(2, 3);

if (actualTotal !== expectedTotal) {
  throw new Error(
    `Verification failed: expected ${expectedTotal}, received ${actualTotal}.`
  );
}

console.log({
  expectedTotal,
  actualTotal,
  verificationPassed: true
});
```

### The Verification

Run:

```bash
node src/primers/verification-pattern.js
```

Expected output:

```text
{
  expectedTotal: 5,
  actualTotal: 5,
  verificationPassed: true
}
```

If the check fails, Node.js stops with an error. This is useful: a failing check should be obvious rather than silently ignored.

---

## Step 8: Understand Errors Without Panic

### The Target

Learn the basic parts of a JavaScript error message.

### The Concept

An error is information. It means JavaScript reached a situation it could not handle according to the current code.

A typical error contains:

```text
TypeError: Cannot read properties of undefined
    at someFunction (src/example.js:12:20)
```

Important parts:

| Error part | Meaning |
|---|---|
| `TypeError` | The category of problem |
| `Cannot read properties...` | The immediate reason |
| `someFunction` | The function where it happened |
| `src/example.js:12:20` | File, line, and column location |

Do not read only the first line. The file and line number often tell you exactly where to look.

### The Implementation

Create this safe error-handling example.

### `src/primers/error-reading.js`

```js
/**
 * Primer 0: Reading and handling errors.
 *
 * Run with:
 * node src/primers/error-reading.js
 */

/**
 * Returns a required non-empty project identifier.
 *
 * @param {unknown} projectId - Candidate project identifier.
 * @returns {string} Valid project identifier.
 * @throws {TypeError} When projectId is not a string.
 * @throws {RangeError} When projectId is blank.
 */
function requireProjectId(projectId) {
  if (typeof projectId !== 'string') {
    throw new TypeError('projectId must be a string.');
  }

  const normalizedProjectId = projectId.trim();

  if (normalizedProjectId.length === 0) {
    throw new RangeError('projectId must not be blank.');
  }

  return normalizedProjectId;
}

const candidateProjectIds = [
  'project_3001',
  '   ',
  42
];

for (const candidateProjectId of candidateProjectIds) {
  try {
    const projectId = requireProjectId(candidateProjectId);

    console.log({
      candidateProjectId,
      projectId,
      valid: true
    });
  } catch (error) {
    console.log({
      candidateProjectId,
      valid: false,
      errorName: error.name,
      message: error.message
    });
  }
}
```

### The Verification

Run:

```bash
node src/primers/error-reading.js
```

Expected output includes:

```text
{
  candidateProjectId: 'project_3001',
  projectId: 'project_3001',
  valid: true
}
```

It should also report controlled errors:

```text
{
  candidateProjectId: '   ',
  valid: false,
  errorName: 'RangeError',
  message: 'projectId must not be blank.'
}
```

And:

```text
{
  candidateProjectId: 42,
  valid: false,
  errorName: 'TypeError',
  message: 'projectId must be a string.'
}
```

The script completes successfully because it handles expected invalid input intentionally.

---

## Step 9: Add Primer Scripts to `package.json`

### The Target

Add convenient npm commands for the Primer 0 files.

### The Concept

A named npm script removes the need to remember long commands.

Instead of this:

```bash
node src/primers/console-output.js
```

You can write this:

```bash
npm run primer:0:console
```

The name describes the task, which makes the project easier to navigate later.

### The Implementation

Replace `package.json` with this complete version.

### `package.json`

```json
{
  "name": "modern-javascript-toolkit",
  "version": "1.0.0",
  "private": true,
  "description": "Hands-on examples for learning modern JavaScript.",
  "type": "module",
  "scripts": {
    "start": "node src/index.js",
    "check:node": "node --version",
    "primer:0:project-info": "node src/primers/project-info.js",
    "primer:0:console": "node src/primers/console-output.js",
    "primer:0:verification": "node src/primers/verification-pattern.js",
    "primer:0:errors": "node src/primers/error-reading.js"
  },
  "engines": {
    "node": ">=22.0.0"
  }
}
```

### The Verification

Run all Primer 0 scripts:

```bash
npm run primer:0:project-info
npm run primer:0:console
npm run primer:0:verification
npm run primer:0:errors
```

Each command should complete without an uncaught error.

Then list scripts:

```bash
npm run
```

Expected script names include:

```text
primer:0:project-info
primer:0:console
primer:0:verification
primer:0:errors
```

---

# Primer 0: Learning Habits That Work

## Make One Change at a Time

When an example fails, avoid changing five things at once.

Instead:

1. Read the error.
2. Check the referenced file and line.
3. Compare the code with the tutorial.
4. Make one correction.
5. Run the same verification command again.

This makes it clear which change solved the problem.

---

## Keep the Terminal in the Project Root

Before running most commands, confirm you are in the right directory.

macOS, Linux, Git Bash, or Windows Subsystem for Linux:

```bash
pwd
```

Windows PowerShell:

```powershell
Get-Location
```

You should see a path ending in:

```text
modern-javascript-toolkit
```

---

## Save Files Before Running Commands

Most code editors indicate unsaved files with a dot or special marker in the tab.

If your output does not reflect the code you just wrote:

1. Save the file.
2. Rerun the command.
3. Confirm you are running the expected file path.

---

## Prefer Exact File Names

These are different files on many systems:

```text
index.js
Index.js
index.JS
```

Use the tutorial file paths exactly as written.

---

## Read Output as Evidence

When a verification step expects:

```text
verificationPassed: true
```

do not only confirm that “something printed.” Confirm that the expected values are present.

Output is evidence of the program’s current behavior.

---

# Primer 0 Completion Checklist

Confirm all of the following work:

```bash
node --version
npm --version
npm start
npm run primer:0:project-info
npm run primer:0:console
npm run primer:0:verification
npm run primer:0:errors
```

Your project should now contain:

```text
modern-javascript-toolkit/
├── package.json
└── src/
    ├── index.js
    └── primers/
        ├── console-output.js
        ├── error-reading.js
        ├── project-info.js
        └── verification-pattern.js
```

You are now ready to begin the JavaScript foundations that the main series builds upon.
