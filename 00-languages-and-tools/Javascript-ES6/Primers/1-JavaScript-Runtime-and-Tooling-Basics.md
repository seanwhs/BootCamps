# Primer 1: JavaScript Runtime and Tooling Basics

This primer explains what happens when you run JavaScript with Node.js and how to use Node’s basic development tools.

You will learn:

- What Node.js does
- The difference between Node.js and browser JavaScript
- How Node executes a file
- How to read command-line arguments
- How to use environment variables safely
- How to use the Node.js REPL
- How npm scripts simplify commands
- How to inspect the current runtime

---

## Step 1: Inspect the Active Node.js Runtime

### The Target

Create a script that reports the Node.js environment currently running your code.

### The Concept

Node.js is a **runtime**: software that loads and executes JavaScript outside a browser.

When you run:

```bash
node src/index.js
```

Node.js:

1. Finds the specified JavaScript file.
2. Reads the code.
3. Executes the instructions.
4. Prints console output.
5. Ends when no work remains.

The `process` object is a Node.js-provided global object. It contains information about the currently running program, including:

- Node.js version
- Operating system platform
- Current working directory
- Command-line arguments
- Environment variables

Think of `process` as the program’s dashboard. It tells your code where and how it is currently running.

### The Implementation

Create this file.

### `src/primers/runtime-inspector.js`

```js
/**
 * Primer 1: Inspect the active Node.js runtime.
 *
 * Run with:
 * node src/primers/runtime-inspector.js
 */

/**
 * Returns a readable description of the current runtime.
 *
 * @returns {{
 *   nodeVersion: string,
 *   platform: string,
 *   architecture: string,
 *   currentWorkingDirectory: string,
 *   moduleSystem: string
 * }} Runtime information.
 */
function getRuntimeInformation() {
  return {
    nodeVersion: process.version,
    platform: process.platform,
    architecture: process.arch,
    currentWorkingDirectory: process.cwd(),
    moduleSystem: 'ES modules'
  };
}

console.log('Node.js runtime information:');
console.table(getRuntimeInformation());

console.log('\nRuntime inspection completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/runtime-inspector.js
```

Expected output resembles:

```text
Node.js runtime information:
┌─────────────────────────┬─────────────────────────────────────┐
│ (index)                 │ Values                              │
├─────────────────────────┼─────────────────────────────────────┤
│ nodeVersion             │ v22.x.x                             │
│ platform                │ darwin, linux, or win32             │
│ architecture            │ arm64 or x64                        │
│ currentWorkingDirectory │ /path/to/modern-javascript-toolkit  │
│ moduleSystem            │ ES modules                          │
└─────────────────────────┴─────────────────────────────────────┘

Runtime inspection completed successfully.
```

Your version, platform, architecture, and path will differ.

---

## Step 2: Understand Node.js and Browser JavaScript

### The Target

Recognize that JavaScript is the language, while Node.js and browsers are different environments that provide different built-in capabilities.

### The Concept

JavaScript is like a shared language. Node.js and web browsers are different places where that language can be spoken.

Both environments understand language features such as:

```js
const userName = 'Ava Patel';
const greeting = `Welcome, ${userName}.`;
```

But each environment provides different extra tools.

| Capability | Node.js | Browser |
|---|---:|---:|
| Run JavaScript files from a terminal | Yes | No |
| Read command-line arguments | Yes | No |
| Access `process` | Yes | No |
| Access the webpage `document` | No | Yes |
| Display browser dialogs with `alert()` | No | Yes |
| Read files from the local server environment | Yes | Not directly |
| Use `console.log()` | Yes | Yes |
| Use modern JavaScript syntax | Yes, with current Node.js | Yes, in current browsers |

For example, this works in Node.js:

```js
console.log(process.version);
```

This browser-specific code does not:

```js
document.querySelector('h1');
```

Node.js has no web page and therefore no `document`.

### The Implementation

Create this runtime-safe example.

### `src/primers/runtime-boundaries.js`

```js
/**
 * Primer 1: Node.js runtime boundaries.
 *
 * Run with:
 * node src/primers/runtime-boundaries.js
 */

/**
 * Reports whether a global API exists in the current runtime.
 *
 * @param {string} apiName - Human-readable API name.
 * @param {unknown} apiValue - API value to inspect.
 * @returns {{ apiName: string, available: boolean }} Availability report.
 */
function checkApiAvailability(apiName, apiValue) {
  return {
    apiName,
    available: typeof apiValue !== 'undefined'
  };
}

const runtimeCapabilities = [
  checkApiAvailability('Node.js process object', globalThis.process),
  checkApiAvailability('Browser document object', globalThis.document),
  checkApiAvailability('Browser window object', globalThis.window),
  checkApiAvailability('setTimeout()', globalThis.setTimeout),
  checkApiAvailability('structuredClone()', globalThis.structuredClone),
  checkApiAvailability('console.log()', globalThis.console?.log)
];

console.table(runtimeCapabilities);

console.log(
  '\nThis file is designed for Node.js, so process should be available while document and window should be unavailable.'
);
```

### The Verification

Run:

```bash
node src/primers/runtime-boundaries.js
```

Expected output includes values similar to:

```text
┌─────────┬──────────────────────────────┬───────────┐
│ (index) │ apiName                      │ available │
├─────────┼──────────────────────────────┼───────────┤
│ 0       │ Node.js process object       │ true      │
│ 1       │ Browser document object      │ false     │
│ 2       │ Browser window object        │ false     │
│ 3       │ setTimeout()                 │ true      │
│ 4       │ structuredClone()            │ true      │
│ 5       │ console.log()                │ true      │
└─────────┴──────────────────────────────┴───────────┘
```

---

## Step 3: Pass Information Through Command-Line Arguments

### The Target

Create a JavaScript program that receives a project name and optional task count from the terminal.

### The Concept

A **command-line argument** is extra information supplied after a command.

For example:

```bash
node src/primers/command-line-report.js "Documentation Refresh" 4
```

In this command:

- `node` starts Node.js.
- `src/primers/command-line-report.js` is the file to execute.
- `"Documentation Refresh"` is the first custom argument.
- `4` is the second custom argument.

Node.js stores command-line values in `process.argv`.

The first two values are usually:

1. The path to Node.js.
2. The path to the current JavaScript file.

Your custom values begin at index `2`.

### The Implementation

Create this file.

### `src/primers/command-line-report.js`

```js
/**
 * Primer 1: Reading command-line arguments.
 *
 * Run with:
 * node src/primers/command-line-report.js "Documentation Refresh" 4
 */

/**
 * Converts a task count argument into a safe non-negative integer.
 *
 * @param {string | undefined} value - Raw argument from the terminal.
 * @returns {number} Valid task count.
 * @throws {RangeError} When the supplied value is not a non-negative integer.
 */
function parseTaskCount(value) {
  if (typeof value === 'undefined') {
    return 0;
  }

  const taskCount = Number(value);

  if (!Number.isInteger(taskCount) || taskCount < 0) {
    throw new RangeError(
      'Task count must be a non-negative whole number.'
    );
  }

  return taskCount;
}

const [
  projectName = 'Untitled project',
  taskCountArgument
] = process.argv.slice(2);

const taskCount = parseTaskCount(taskCountArgument);

const taskWord = taskCount === 1 ? 'task' : 'tasks';

console.log({
  projectName,
  taskCount,
  summary: `${projectName} has ${taskCount} ${taskWord}.`
});
```

### The Verification

Run:

```bash
node src/primers/command-line-report.js "Documentation Refresh" 4
```

Expected output:

```text
{
  projectName: 'Documentation Refresh',
  taskCount: 4,
  summary: 'Documentation Refresh has 4 tasks.'
}
```

Now test the default project name and task count:

```bash
node src/primers/command-line-report.js
```

Expected output:

```text
{
  projectName: 'Untitled project',
  taskCount: 0,
  summary: 'Untitled project has 0 tasks.'
}
```

Finally, test invalid input:

```bash
node src/primers/command-line-report.js "Documentation Refresh" invalid
```

Expected result includes:

```text
RangeError: Task count must be a non-negative whole number.
```

This uncaught error is intentional for invalid command-line input.

---

## Step 4: Use Environment Variables for Configuration

### The Target

Read optional configuration from environment variables without placing environment-specific values directly in source code.

### The Concept

An **environment variable** is a named value supplied by the operating system or deployment environment.

Environment variables are useful for settings that vary by machine or deployment, such as:

- Application environment: development, test, production
- Network port
- External service URL
- Feature flags
- Credentials and secrets

Do **not** hard-code secrets in source code:

```js
// Never commit real secrets like this.
const databasePassword = 'my-secret-password';
```

Instead, read secrets from environment variables in real applications:

```js
const databasePassword = process.env.DATABASE_PASSWORD;
```

For this primer, you will use non-sensitive demonstration variables.

### The Implementation

Create this file.

### `src/primers/environment-configuration.js`

```js
/**
 * Primer 1: Reading environment variables.
 *
 * macOS, Linux, Git Bash, or WSL:
 * APP_ENV=development PROJECT_PAGE_SIZE=10 node src/primers/environment-configuration.js
 *
 * Windows PowerShell:
 * $env:APP_ENV='development'
 * $env:PROJECT_PAGE_SIZE='10'
 * node src/primers/environment-configuration.js
 */

/**
 * Reads a positive integer environment variable or returns a fallback.
 *
 * @param {string | undefined} value - Raw environment variable value.
 * @param {number} fallback - Value to return when no value was supplied.
 * @returns {number} Parsed positive integer or fallback.
 * @throws {RangeError} When a supplied value is invalid.
 */
function getPositiveIntegerSetting(value, fallback) {
  if (typeof value === 'undefined') {
    return fallback;
  }

  const parsedValue = Number(value);

  if (!Number.isInteger(parsedValue) || parsedValue <= 0) {
    throw new RangeError(
      'PROJECT_PAGE_SIZE must be a positive whole number.'
    );
  }

  return parsedValue;
}

const applicationEnvironment = process.env.APP_ENV ?? 'development';
const projectPageSize = getPositiveIntegerSetting(
  process.env.PROJECT_PAGE_SIZE,
  25
);

console.log({
  applicationEnvironment,
  projectPageSize,
  message:
    `Running in ${applicationEnvironment} mode with a page size of ${projectPageSize}.`
});

console.log(
  '\nDo not print real credentials, tokens, passwords, or private keys in production logs.'
);
```

### The Verification

First, run without any environment variables:

```bash
node src/primers/environment-configuration.js
```

Expected output:

```text
{
  applicationEnvironment: 'development',
  projectPageSize: 25,
  message: 'Running in development mode with a page size of 25.'
}
```

On macOS, Linux, Git Bash, or Windows Subsystem for Linux, run:

```bash
APP_ENV=production PROJECT_PAGE_SIZE=50 node src/primers/environment-configuration.js
```

Expected output:

```text
{
  applicationEnvironment: 'production',
  projectPageSize: 50,
  message: 'Running in production mode with a page size of 50.'
}
```

On Windows PowerShell, run:

```powershell
$env:APP_ENV='production'
$env:PROJECT_PAGE_SIZE='50'
node src/primers/environment-configuration.js
```

When finished, remove the temporary values:

```powershell
Remove-Item Env:APP_ENV
Remove-Item Env:PROJECT_PAGE_SIZE
```

---

## Step 5: Use the Node.js REPL for Quick Experiments

### The Target

Use the Node.js REPL to test small JavaScript expressions without creating a file.

### The Concept

**REPL** means:

- **R**ead
- **E**valuate
- **P**rint
- **L**oop

The Node.js REPL is an interactive JavaScript prompt. It is useful for quickly checking syntax, testing an API, or inspecting a value.

It is not a replacement for source files. Use files for code you want to keep. Use the REPL for experiments.

### The Implementation

Start the REPL:

```bash
node
```

You should see a prompt resembling:

```text
>
```

Enter each of these expressions one at a time:

```js
const tags = ['javascript', 'es2024', 'javascript'];
```

```js
[...new Set(tags)];
```

```js
const settings = { pageSize: 0 };
```

```js
settings.pageSize ?? 25;
```

```js
['validate', 'build', 'test'].at(-1);
```

Exit the REPL by entering:

```js
.exit
```

You can also press `Ctrl+C` twice.

### The Verification

Expected REPL interaction resembles:

```text
> const tags = ['javascript', 'es2024', 'javascript'];
undefined
> [...new Set(tags)];
[ 'javascript', 'es2024' ]
> const settings = { pageSize: 0 };
undefined
> settings.pageSize ?? 25;
0
> ['validate', 'build', 'test'].at(-1);
'test'
> .exit
```

`undefined` after a `const` declaration is normal. Declarations create a binding but do not produce a separately displayed result.

---

## Step 6: Use npm Scripts as Reliable Shortcuts

### The Target

Add named npm scripts for the Primer 1 modules.

### The Concept

npm scripts are commands stored in `package.json`.

They make projects easier to use because everyone runs the same named command rather than manually typing a long command with a potentially incorrect file path.

For example, this script:

```json
"primer:1:runtime": "node src/primers/runtime-inspector.js"
```

can be run with:

```bash
npm run primer:1:runtime
```

### The Implementation

Add the following entries to the existing `"scripts"` object in `package.json`.

### `package.json` — scripts additions

```json
{
  "scripts": {
    "primer:1:runtime": "node src/primers/runtime-inspector.js",
    "primer:1:boundaries": "node src/primers/runtime-boundaries.js",
    "primer:1:arguments": "node src/primers/command-line-report.js",
    "primer:1:environment": "node src/primers/environment-configuration.js"
  }
}
```

Your existing scripts—including `start` and all Primer 0 scripts—must remain in the same `"scripts"` object.

For example, after merging the new scripts, this is a valid complete `scripts` object:

```json
{
  "scripts": {
    "start": "node src/index.js",
    "check:node": "node --version",
    "primer:0:project-info": "node src/primers/project-info.js",
    "primer:0:console": "node src/primers/console-output.js",
    "primer:0:verification": "node src/primers/verification-pattern.js",
    "primer:0:errors": "node src/primers/error-reading.js",
    "primer:1:runtime": "node src/primers/runtime-inspector.js",
    "primer:1:boundaries": "node src/primers/runtime-boundaries.js",
    "primer:1:arguments": "node src/primers/command-line-report.js",
    "primer:1:environment": "node src/primers/environment-configuration.js"
  }
}
```

### The Verification

Run:

```bash
npm run primer:1:runtime
npm run primer:1:boundaries
npm run primer:1:arguments -- "Tutorial Workspace" 3
npm run primer:1:environment
```

The extra `--` in this command:

```bash
npm run primer:1:arguments -- "Tutorial Workspace" 3
```

tells npm that the remaining values belong to the script rather than to npm itself.

Expected task-report output:

```text
{
  projectName: 'Tutorial Workspace',
  taskCount: 3,
  summary: 'Tutorial Workspace has 3 tasks.'
}
```

---

## Step 7: Build a Small Runtime-Aware Command-Line Tool

### The Target

Create a complete command-line tool that uses arguments, environment variables, validation, and runtime information together.

### The Concept

This is a miniature version of a real Node.js command-line application.

It will:

1. Read a task title from the terminal.
2. Read an optional priority from the terminal.
3. Read an environment name from `APP_ENV`.
4. Validate input.
5. Print a formatted task report.

The goal is not to build a production CLI framework. The goal is to connect the runtime concepts you have learned.

### The Implementation

Create this file.

### `src/primers/task-report-cli.js`

```js
/**
 * Primer 1: A small runtime-aware command-line task reporter.
 *
 * Run with:
 * node src/primers/task-report-cli.js "Review JavaScript primer" 2
 *
 * macOS, Linux, Git Bash, or WSL:
 * APP_ENV=production node src/primers/task-report-cli.js "Review JavaScript primer" 2
 *
 * Windows PowerShell:
 * $env:APP_ENV='production'
 * node src/primers/task-report-cli.js "Review JavaScript primer" 2
 */

/**
 * Validates and normalizes a required text value.
 *
 * @param {string | undefined} value - Candidate text.
 * @param {string} fieldName - Field name used in error messages.
 * @returns {string} Trimmed text.
 * @throws {TypeError} When value is absent.
 * @throws {RangeError} When value is blank.
 */
function requireText(value, fieldName) {
  if (typeof value === 'undefined') {
    throw new TypeError(`${fieldName} is required.`);
  }

  const normalizedValue = value.trim();

  if (normalizedValue.length === 0) {
    throw new RangeError(`${fieldName} must not be blank.`);
  }

  return normalizedValue;
}

/**
 * Converts a priority argument into an integer from 1 through 5.
 *
 * @param {string | undefined} value - Raw priority argument.
 * @returns {number} Valid priority.
 * @throws {RangeError} When the supplied value is outside the supported range.
 */
function parsePriority(value) {
  if (typeof value === 'undefined') {
    return 3;
  }

  const priority = Number(value);

  if (!Number.isInteger(priority) || priority < 1 || priority > 5) {
    throw new RangeError(
      'Priority must be a whole number from 1 through 5.'
    );
  }

  return priority;
}

/**
 * Converts a numeric priority into a readable urgency label.
 *
 * @param {number} priority - Priority from 1 through 5.
 * @returns {string} Readable urgency label.
 */
function getPriorityLabel(priority) {
  if (priority === 1) {
    return 'critical';
  }

  if (priority === 2) {
    return 'high';
  }

  if (priority === 3) {
    return 'normal';
  }

  if (priority === 4) {
    return 'low';
  }

  return 'lowest';
}

const [
  taskTitleArgument,
  priorityArgument
] = process.argv.slice(2);

const taskTitle = requireText(taskTitleArgument, 'Task title');
const priority = parsePriority(priorityArgument);
const applicationEnvironment = process.env.APP_ENV ?? 'development';

const taskReport = {
  taskTitle,
  priority,
  priorityLabel: getPriorityLabel(priority),
  applicationEnvironment,
  nodeVersion: process.version,
  summary:
    `[${applicationEnvironment}] ${taskTitle} has ${getPriorityLabel(priority)} priority.`
};

console.log(taskReport);
```

Add this npm script:

### `package.json` — scripts addition

```json
{
  "scripts": {
    "primer:1:task-report": "node src/primers/task-report-cli.js"
  }
}
```

### The Verification

Run:

```bash
npm run primer:1:task-report -- "Review JavaScript primer" 2
```

Expected output resembles:

```text
{
  taskTitle: 'Review JavaScript primer',
  priority: 2,
  priorityLabel: 'high',
  applicationEnvironment: 'development',
  nodeVersion: 'v22.x.x',
  summary: '[development] Review JavaScript primer has high priority.'
}
```

Test invalid input:

```bash
npm run primer:1:task-report -- "Review JavaScript primer" 9
```

Expected output includes:

```text
RangeError: Priority must be a whole number from 1 through 5.
```

---

# Primer 1 Reference: Runtime and Tooling Commands

## Check installed versions

```bash
node --version
npm --version
```

## Run a JavaScript file

```bash
node src/index.js
```

## Run an npm script

```bash
npm run script-name
```

For example:

```bash
npm run primer:1:runtime
```

## Pass arguments through an npm script

```bash
npm run primer:1:arguments -- "Project Name" 5
```

## Start the Node.js REPL

```bash
node
```

## Exit the REPL

```js
.exit
```

## Read command-line arguments in Node.js

```js
const argumentsFromTerminal = process.argv.slice(2);
```

## Read an environment variable in Node.js

```js
const applicationEnvironment =
  process.env.APP_ENV ?? 'development';
```

## Set a temporary environment variable

macOS, Linux, Git Bash, or WSL:

```bash
APP_ENV=production node src/index.js
```

Windows PowerShell:

```powershell
$env:APP_ENV='production'
node src/index.js
Remove-Item Env:APP_ENV
```

---

# Primer 1 Completion Checklist

Run all Primer 1 modules:

```bash
npm run primer:1:runtime
npm run primer:1:boundaries
npm run primer:1:arguments -- "Primer Practice" 2
npm run primer:1:environment
npm run primer:1:task-report -- "Verify runtime tooling" 1
```

Confirm that:

- Node.js reports a supported version.
- The Node.js runtime reports `process` as available.
- Command-line arguments become JavaScript values.
- Environment variables provide configuration defaults.
- Invalid priority input produces a useful error.
- The task reporter produces a formatted task object.
