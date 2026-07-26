# Primer 3: Node.js, npm, JavaScript Modules, and Automated Tests

The early Git lessons work with Markdown files only. Later, the Release Notes Manager project includes JavaScript code and automated tests.

This primer explains the minimum Node.js knowledge needed before that stage.

You will learn:

- What Node.js is.
- What npm is.
- How `package.json` defines a project.
- How JavaScript modules import and export code.
- How to run a test with Node’s built-in test runner.
- How to interpret passing and failing test output.

You do not need to become a JavaScript expert before learning Git. The goal is simply to understand the project files and commands used later in the series.

---

# P3.1 Understand Node.js and npm

## The Target

Understand what Node.js and npm do.

## The Concept

JavaScript is a programming language commonly associated with web browsers.

**Node.js** lets JavaScript run outside a browser, including in a terminal, on servers, and in automated workflows such as GitHub Actions.

For example, this command runs JavaScript directly:

```bash
node script.js
```

**npm** stands for Node Package Manager.

It is included with Node.js and helps projects:

- Define project metadata.
- Run named commands such as `npm test`.
- Install third-party packages when needed.
- Record dependency versions.

Think of the relationship like this:

```text
JavaScript code      → The instructions
Node.js              → The engine that runs those instructions
npm                  → The project toolbelt and command launcher
package.json         → The project configuration card
```

---

# P3.2 Install and Verify Node.js

## The Target

Install a supported Node.js version and verify that both Node.js and npm are available.

## The Concept

The tutorial project uses Node.js’s built-in test runner.

Use Node.js version 20 or newer when possible. Node.js 18 is sufficient for the main project, but Node.js 20 is a better modern baseline for new work.

## The Implementation

Check whether Node.js is installed:

```bash
node --version
```

Check npm:

```bash
npm --version
```

Expected output resembles:

```text
v20.15.1
10.7.0
```

If either command is unavailable, install the current **LTS** version from:

```text
https://nodejs.org/
```

Choose the LTS version rather than the “Current” release unless you have a specific reason to use the newest non-LTS release.

After installation, close and reopen the terminal, then run:

```bash
node --version
npm --version
```

## The Verification

Both commands should produce version numbers.

For example:

```text
v20.15.1
10.7.0
```

If your Node.js version is lower than 18, update Node.js before continuing.

---

# P3.3 Create a Disposable Node.js Practice Project

## The Target

Create a temporary folder containing a basic Node.js project.

## The Concept

A Node.js project usually has a `package.json` file at its root.

This file describes:

- The project name.
- The project version.
- Commands that contributors can run.
- Dependencies, if the project has any.
- Supported Node.js versions.

Think of `package.json` as a project menu:

```text
Project name
Project version
Available commands
Required tools
Dependencies
```

## The Implementation

Create a temporary project folder.

### macOS, Linux, or Git Bash

```bash
mkdir -p ~/projects/node-practice
cd ~/projects/node-practice
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path "$HOME\projects\node-practice" -Force
Set-Location "$HOME\projects\node-practice"
```

Create this file.

### `node-practice/package.json`

```json
{
  "name": "node-practice",
  "version": "1.0.0",
  "private": true,
  "description": "A disposable project for learning Node.js basics.",
  "type": "module",
  "scripts": {
    "test": "node --test",
    "start": "node src/greeting.js"
  },
  "engines": {
    "node": ">=20"
  }
}
```

Important fields:

| Field | Meaning |
|---|---|
| `name` | Project identifier, usually lowercase and hyphenated |
| `version` | Project version number |
| `private` | Prevents accidental publication to npm |
| `type` | Enables modern JavaScript module syntax |
| `scripts` | Defines reusable terminal commands |
| `engines` | Documents supported Node.js versions |

## The Verification

Run:

```bash
npm test
```

Expected output resembles:

```text
> node-practice@1.0.0 test
> node --test

1..0
# tests 0
# suites 0
# pass 0
# fail 0
```

Zero tests is correct at this point.

---

# P3.4 Create a JavaScript Module

## The Target

Create a JavaScript file that exports one reusable function.

## The Concept

A **function** is a named piece of reusable behavior.

For example:

```js
function formatGreeting(name) {
  return `Hello, ${name}!`;
}
```

The function accepts input:

```text
name
```

and returns output:

```text
Hello, Jordan!
```

A **module** is a JavaScript file that can export behavior for another file to import.

Think of a module as a small tool in a toolbox:

```text
greeting.js
    ↓
exports formatGreeting
    ↓
other files can import and use it
```

## The Implementation

Create a source directory.

### macOS, Linux, or Git Bash

```bash
mkdir -p src
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path src -Force
```

Create this file.

### `node-practice/src/greeting.js`

```js
/**
 * Creates a greeting for a non-empty name.
 *
 * @param {string} name - The name to include in the greeting.
 * @returns {string} A complete greeting message.
 * @throws {TypeError} When name is not a non-empty string.
 */
export function formatGreeting(name) {
  if (typeof name !== "string" || name.trim().length === 0) {
    throw new TypeError("name must be a non-empty string.");
  }

  return `Hello, ${name.trim()}!`;
}
```

Create a small executable script that imports the function.

### `node-practice/src/runGreeting.js`

```js
import { formatGreeting } from "./greeting.js";

const greeting = formatGreeting("Release Notes Manager");

console.log(greeting);
```

Run the script:

```bash
node src/runGreeting.js
```

## The Verification

Expected output:

```text
Hello, Release Notes Manager!
```

You have now:

1. Exported a function from one JavaScript file.
2. Imported it into another JavaScript file.
3. Executed the importing file with Node.js.

---

# P3.5 Understand `import` and `export`

## The Target

Understand the JavaScript module syntax used in the tutorial project.

## The Concept

In the previous step:

```js
export function formatGreeting(name) {
```

made the function available outside `greeting.js`.

Then:

```js
import { formatGreeting } from "./greeting.js";
```

made that exported function available inside `runGreeting.js`.

The braces matter:

```js
import { formatGreeting } from "./greeting.js";
```

This syntax imports a **named export**.

The file path begins with:

```text
./
```

which means:

> “Start from the current file’s folder.”

The `.js` extension is included because the project uses modern ECMAScript Modules through:

```json
"type": "module"
```

in `package.json`.

## The Implementation

Inspect the two files:

### `node-practice/src/greeting.js`

```js
export function formatGreeting(name) {
  if (typeof name !== "string" || name.trim().length === 0) {
    throw new TypeError("name must be a non-empty string.");
  }

  return `Hello, ${name.trim()}!`;
}
```

### `node-practice/src/runGreeting.js`

```js
import { formatGreeting } from "./greeting.js";

const greeting = formatGreeting("Release Notes Manager");

console.log(greeting);
```

Run the configured npm script:

```bash
npm run start
```

## The Verification

Expected output:

```text
Hello, Release Notes Manager!
```

The command:

```bash
npm run start
```

runs the command defined here:

```json
"start": "node src/greeting.js"
```

At this point, the configured `start` script points at `greeting.js`, which exports a function but does not print output by itself. Update `package.json` to point to `runGreeting.js`.

### `node-practice/package.json`

```json
{
  "name": "node-practice",
  "version": "1.0.0",
  "private": true,
  "description": "A disposable project for learning Node.js basics.",
  "type": "module",
  "scripts": {
    "test": "node --test",
    "start": "node src/runGreeting.js"
  },
  "engines": {
    "node": ">=20"
  }
}
```

Run again:

```bash
npm run start
```

Now it should print the greeting.

---

# P3.6 Create an Automated Test

## The Target

Write a test that checks whether `formatGreeting` behaves correctly.

## The Concept

An **automated test** is code that checks other code.

Think of it as a repeatable inspection checklist.

Instead of manually running the greeting function every time it changes, the test runner verifies the expected output automatically.

Your test will answer:

```text
Given the name "Jordan",
does formatGreeting return "Hello, Jordan!"?
```

Node.js includes a built-in test module:

```js
import test from "node:test";
```

And a built-in assertion module:

```js
import assert from "node:assert/strict";
```

An **assertion** is a statement that must be true for the test to pass.

## The Implementation

Create this test file.

### `node-practice/src/greeting.test.js`

```js
import assert from "node:assert/strict";
import test from "node:test";
import { formatGreeting } from "./greeting.js";

test("formats a greeting with a trimmed name", () => {
  const result = formatGreeting("  Jordan  ");

  assert.equal(result, "Hello, Jordan!");
});

test("rejects an empty name", () => {
  assert.throws(
    () => formatGreeting("   "),
    {
      name: "TypeError",
      message: "name must be a non-empty string."
    }
  );
});

test("rejects a non-string name", () => {
  assert.throws(
    () => formatGreeting(42),
    {
      name: "TypeError",
      message: "name must be a non-empty string."
    }
  );
});
```

Run the test suite:

```bash
npm test
```

## The Verification

Expected output resembles:

```text
# tests 3
# pass 3
# fail 0
```

The exact formatting depends on your Node.js version, but all three tests must pass.

---

# P3.7 Intentionally Observe a Failing Test

## The Target

Understand what failed test output looks like.

## The Concept

A test failure is useful information.

It means:

```text
Expected behavior and actual behavior do not match.
```

Failing tests are not something to hide. They help developers identify a problem before it reaches a pull request or release.

You will temporarily change one expected value, run the test, observe the failure, and restore the correct expectation.

## The Implementation

In `src/greeting.test.js`, change this line:

```js
assert.equal(result, "Hello, Jordan!");
```

to this intentionally incorrect expectation:

```js
assert.equal(result, "Hello, Taylor!");
```

Run:

```bash
npm test
```

After observing the failure, restore the correct line:

```js
assert.equal(result, "Hello, Jordan!");
```

Run tests again:

```bash
npm test
```

## The Verification

The failing run should include information similar to:

```text
Expected values to be strictly equal:
+ actual - expected

+ 'Hello, Jordan!'
- 'Hello, Taylor!'
```

After restoring the correct expectation, tests should return to:

```text
# pass 3
# fail 0
```

---

# P3.8 Understand Why Tests Matter to GitHub Actions

## The Target

Connect local `npm test` behavior to continuous integration.

## The Concept

Later in the series, GitHub Actions runs:

```bash
npm test
```

automatically whenever a pull request is opened or updated.

The same command runs in two places:

```text
Your computer
    ↓
npm test
    ↓
Fast feedback while developing

GitHub Actions
    ↓
npm test
    ↓
Independent confirmation before merge
```

This consistency is important.

If contributors use one command locally and CI uses a different command, a change may pass locally but fail after pushing.

## The Implementation

Inspect the test command in `package.json`:

```bash
node --input-type=module --eval "import packageJson from './package.json' with { type: 'json' }; console.log(packageJson.scripts.test);"
```

Expected output:

```text
node --test
```

Run the exact command directly:

```bash
node --test
```

Then run it through npm:

```bash
npm test
```

## The Verification

Both commands should pass.

The `npm test` command is a convenient standard entry point because it runs the configured script:

```json
"test": "node --test"
```

---

# P3.9 Clean Up the Disposable Node.js Practice Project

## The Target

Remove the temporary Node.js practice folder.

## The Concept

The `node-practice` folder is only for learning. It is not part of Release Notes Manager.

Later, the real project will receive its own `package.json`, source files, tests, and CI workflow through a feature branch and pull request.

## The Implementation

Move to the projects directory:

```bash
cd ..
```

Remove the practice project.

### macOS, Linux, or Git Bash

```bash
rm -rf node-practice
```

### Windows PowerShell

```powershell
Remove-Item -Recurse -Force node-practice
```

## The Verification

List your projects folder.

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
node-practice
```

no longer appears.

---

# Primer 3 Reference: Node.js and npm Commands

| Command | Purpose |
|---|---|
| `node --version` | Display installed Node.js version |
| `npm --version` | Display installed npm version |
| `node file.js` | Run a JavaScript file |
| `node --test` | Run Node.js test files |
| `npm test` | Run the project’s `test` script |
| `npm run <script>` | Run a named script from `package.json` |
| `npm install` | Install project dependencies when the project has them |

---

# Primer 3 Reference: JavaScript Module Basics

Export a named function:

```js
export function formatGreeting(name) {
  return `Hello, ${name}!`;
}
```

Import the named function:

```js
import { formatGreeting } from "./greeting.js";
```

Call the function:

```js
const message = formatGreeting("Jordan");

console.log(message);
```

Write a test:

```js
import assert from "node:assert/strict";
import test from "node:test";

test("describes expected behavior", () => {
  assert.equal("actual value", "expected value");
});
```

---

# Primer 3 Completion Check

Before beginning the JavaScript and CI work in Part 4, confirm that you can:

- [ ] Verify Node.js and npm versions.
- [ ] Explain the role of `package.json`.
- [ ] Run a JavaScript file with `node`.
- [ ] Define an npm script and run it with `npm run`.
- [ ] Export a function from one JavaScript module.
- [ ] Import a function into another module.
- [ ] Write a basic Node.js test.
- [ ] Run tests with `npm test`.
- [ ] Recognize passing and failing test output.
- [ ] Explain why the same test command should run locally and in GitHub Actions.
