# Primer 4: Modules, Files, and Debugging Basics

The main tutorial uses multiple JavaScript files instead of placing every function in one large file.

This primer explains how those files work together and how to debug them when something goes wrong.

You will learn:

- What a module is
- How `export` and `import` work
- Why relative file paths use `./` and `../`
- Why ES modules require `.js` in local import paths
- How to organize a small project
- How to read a stack trace
- How to use `console.log()`, `console.table()`, and `console.error()`
- How to use `node --watch`
- How to use Node.js’s built-in debugger

Think of modules as labeled rooms in a workshop:

- One room validates data.
- One room creates task records.
- One room formats output.
- One room runs the application.

Instead of searching through one enormous room, you know where each responsibility belongs.

---

## Step 1: Create a Small Module Structure

### The Target

Create directories for reusable modules and a small module-based task application.

### The Concept

A **module** is a JavaScript file with a focused responsibility.

In this primer:

- `validation.js` will validate required text.
- `task.js` will create task records.
- `task-formatting.js` will format tasks for display.
- `module-demo.js` will import and use the other modules.

This separation makes code easier to read, test, reuse, and change.

### The Implementation

Create these directories:

```bash
mkdir -p src/primers/module-demo/domain
mkdir -p src/primers/module-demo/utilities
```

> On Windows PowerShell:

```powershell
mkdir src\primers\module-demo\domain
mkdir src\primers\module-demo\utilities
```

Your folder structure should become:

```text
src/
└── primers/
    └── module-demo/
        ├── domain/
        ├── utilities/
        └── module-demo.js
```

### The Verification

On macOS, Linux, Git Bash, or Windows Subsystem for Linux:

```bash
find src/primers/module-demo -maxdepth 2 -type d
```

On Windows PowerShell:

```powershell
Get-ChildItem src\primers\module-demo -Directory -Recurse
```

Expected directories include:

```text
src/primers/module-demo
src/primers/module-demo/domain
src/primers/module-demo/utilities
```

---

## Step 2: Export a Validation Function

### The Target

Create a reusable module that validates required non-empty text.

### The Concept

An **export** makes a value available to other modules.

This module will export one named function:

```js
export function requireNonEmptyString() {}
```

A **named export** is useful when a module provides one or more clearly named utilities.

Think of exporting as placing a labeled tool in the checkout area of a workshop. Other rooms can use the tool only because it was explicitly made available.

### The Implementation

Create this file.

### `src/primers/module-demo/utilities/validation.js`

```js
/**
 * Validates and normalizes a required text value.
 *
 * @param {unknown} value - Candidate text value.
 * @param {string} fieldName - Field name used in error messages.
 * @returns {string} Trimmed non-empty text.
 * @throws {TypeError} When value is not a string.
 * @throws {RangeError} When value is blank after trimming.
 */
export function requireNonEmptyString(value, fieldName) {
  if (typeof value !== 'string') {
    throw new TypeError(`${fieldName} must be a string.`);
  }

  const normalizedValue = value.trim();

  if (normalizedValue.length === 0) {
    throw new RangeError(`${fieldName} must not be blank.`);
  }

  return normalizedValue;
}
```

### The Verification

This file exports a function but does not run any code itself. It will be verified after another module imports it in the next step.

For now, confirm the file exists:

```bash
node --check src/primers/module-demo/utilities/validation.js
```

No output means Node.js successfully parsed the file.

---

## Step 3: Import Validation and Export a Task Factory

### The Target

Create a task module that imports the validation function and exports a task-creation function.

### The Concept

An **import** receives an exported value from another module.

This syntax:

```js
import { requireNonEmptyString } from '../utilities/validation.js';
```

means:

- Import the named export `requireNonEmptyString`.
- Look for it in the file at `../utilities/validation.js`.

The `..` means “go up one directory.”

From this file:

```text
src/primers/module-demo/domain/task.js
```

this path:

```text
../utilities/validation.js
```

means:

1. Start in `domain`.
2. Go up to `module-demo`.
3. Enter `utilities`.
4. Load `validation.js`.

In Node.js ES modules, local file imports should include the `.js` extension.

### The Implementation

Create this file.

### `src/primers/module-demo/domain/task.js`

```js
import {
  requireNonEmptyString
} from '../utilities/validation.js';

/**
 * Creates a normalized task record.
 *
 * @param {{
 *   id: unknown,
 *   title: unknown,
 *   completed?: unknown,
 *   priority?: unknown
 * }} input - Task-like input.
 * @returns {{
 *   id: string,
 *   title: string,
 *   completed: boolean,
 *   priority: number
 * }} Normalized task.
 * @throws {RangeError} When priority is invalid.
 */
export function createTask(input) {
  const id = requireNonEmptyString(input.id, 'Task id');
  const title = requireNonEmptyString(input.title, 'Task title');

  const priority =
    typeof input.priority === 'number'
      ? input.priority
      : 3;

  if (!Number.isInteger(priority) || priority < 1 || priority > 5) {
    throw new RangeError(
      'Task priority must be a whole number from 1 through 5.'
    );
  }

  return {
    id,
    title,
    completed: input.completed === true,
    priority
  };
}
```

### The Verification

Check that Node.js can parse the module:

```bash
node --check src/primers/module-demo/domain/task.js
```

No output means the module syntax is valid.

---

## Step 4: Export a Formatting Module

### The Target

Create a separate module for formatting task records into display-friendly values.

### The Concept

Formatting is a different responsibility from validation or task creation.

A task factory decides what a valid task looks like. A formatting function decides how a task should appear in console output or a user interface.

Keeping these responsibilities separate makes each module simpler.

### The Implementation

Create this file.

### `src/primers/module-demo/utilities/task-formatting.js`

```js
/**
 * Returns a readable status label for a task.
 *
 * @param {{ completed: boolean }} task - Task whose status should be formatted.
 * @returns {string} Status label.
 */
export function getTaskStatus(task) {
  return task.completed ? 'completed' : 'pending';
}

/**
 * Creates a readable one-line task label.
 *
 * @param {{
 *   id: string,
 *   title: string,
 *   completed: boolean,
 *   priority: number
 * }} task - Task to format.
 * @returns {string} Readable task label.
 */
export function formatTask(task) {
  const status = getTaskStatus(task);

  return `[${task.id}] ${task.title} — ${status}, priority ${task.priority}`;
}

/**
 * Converts tasks into display-friendly table rows.
 *
 * @param {Array<{
 *   id: string,
 *   title: string,
 *   completed: boolean,
 *   priority: number
 * }>} tasks - Tasks to format.
 * @returns {Array<{
 *   id: string,
 *   title: string,
 *   status: string,
 *   priority: number
 * }>} Display rows.
 */
export function createTaskTableRows(tasks) {
  return tasks.map((task) => ({
    id: task.id,
    title: task.title,
    status: getTaskStatus(task),
    priority: task.priority
  }));
}
```

### The Verification

Run:

```bash
node --check src/primers/module-demo/utilities/task-formatting.js
```

No output means the file has valid syntax.

---

## Step 5: Create the Module Demo Entry Point

### The Target

Create a runnable entry module that imports functions from the other files.

### The Concept

An entry point is the module that starts a small program.

This file acts as the project coordinator:

1. It imports the task factory.
2. It imports formatting utilities.
3. It creates task records.
4. It displays formatted output.

Think of it as the front desk of a workshop. It does not manufacture every tool itself; it asks the correct specialized room for each task.

### The Implementation

Create this file.

### `src/primers/module-demo/module-demo.js`

```js
/**
 * Primer 4: ES module import and export demonstration.
 *
 * Run with:
 * node src/primers/module-demo/module-demo.js
 */

import {
  createTask
} from './domain/task.js';

import {
  createTaskTableRows,
  formatTask
} from './utilities/task-formatting.js';

const tasks = [
  createTask({
    id: 'task_1',
    title: 'Create validation module',
    completed: true,
    priority: 1
  }),
  createTask({
    id: 'task_2',
    title: 'Create task domain module',
    completed: true,
    priority: 2
  }),
  createTask({
    id: 'task_3',
    title: 'Run module entry point',
    completed: false,
    priority: 2
  })
];

console.log('Formatted task labels:');

for (const task of tasks) {
  console.log(formatTask(task));
}

console.log('\nTask table:');
console.table(createTaskTableRows(tasks));

console.log('\nModule demo completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/module-demo/module-demo.js
```

Expected output includes:

```text
Formatted task labels:
[task_1] Create validation module — completed, priority 1
[task_2] Create task domain module — completed, priority 2
[task_3] Run module entry point — pending, priority 2
```

You should also see a table with `id`, `title`, `status`, and `priority` columns.

---

## Step 6: Understand Relative Import Paths

### The Target

Learn how to choose the correct import path between project files.

### The Concept

A relative import path starts from the file containing the import statement.

| Path prefix | Meaning |
|---|---|
| `./` | Current directory |
| `../` | Parent directory |
| `../../` | Parent directory twice |
| `/` | Usually an absolute filesystem path; do not use for local project imports |
| Package name | A package installed in `node_modules` or built into Node.js |

Given this structure:

```text
module-demo/
├── module-demo.js
├── domain/
│   └── task.js
└── utilities/
    ├── task-formatting.js
    └── validation.js
```

Examples:

```js
// From module-demo.js:
import { createTask } from './domain/task.js';

// From domain/task.js:
import { requireNonEmptyString } from '../utilities/validation.js';

// From utilities/task-formatting.js:
import { createTask } from '../domain/task.js';
```

### The Implementation

Create an import-path reference file.

### `src/primers/module-demo/import-path-reference.js`

```js
/**
 * Primer 4: Relative import path reference.
 *
 * Run with:
 * node src/primers/module-demo/import-path-reference.js
 */

import {
  createTask
} from './domain/task.js';

import {
  formatTask
} from './utilities/task-formatting.js';

const task = createTask({
  id: 'task_path_1',
  title: 'Understand relative import paths',
  completed: false,
  priority: 1
});

console.log({
  formattedTask: formatTask(task),
  explanation:
    'This file uses ./ because domain and utilities are inside the same module-demo directory.'
});
```

### The Verification

Run:

```bash
node src/primers/module-demo/import-path-reference.js
```

Expected output:

```text
{
  formattedTask: '[task_path_1] Understand relative import paths — pending, priority 1',
  explanation: 'This file uses ./ because domain and utilities are inside the same module-demo directory.'
}
```

---

## Step 7: Read and Use Stack Traces

### The Target

Create a controlled error that demonstrates a Node.js stack trace.

### The Concept

A **stack trace** is the path JavaScript followed through functions before an error occurred.

A stack trace usually includes:

- The error category, such as `TypeError` or `RangeError`
- The error message
- The function where the error happened
- The file, line, and column number
- Earlier function calls that led to the error

Think of it as a breadcrumb trail from the application entry point to the problem.

### The Implementation

Create this file.

### `src/primers/stack-traces.js`

```js
/**
 * Primer 4: Reading stack traces.
 *
 * Run with:
 * node src/primers/stack-traces.js
 */

/**
 * Validates a priority value.
 *
 * @param {number} priority - Priority to validate.
 * @returns {number} Validated priority.
 * @throws {RangeError} When priority is outside 1 through 5.
 */
function requirePriority(priority) {
  if (!Number.isInteger(priority) || priority < 1 || priority > 5) {
    throw new RangeError(
      `Priority "${priority}" must be a whole number from 1 through 5.`
    );
  }

  return priority;
}

/**
 * Creates a task priority label.
 *
 * @param {number} priority - Task priority.
 * @returns {string} Formatted priority label.
 */
function createPriorityLabel(priority) {
  const validatedPriority = requirePriority(priority);

  return `Priority ${validatedPriority}`;
}

/**
 * Demonstrates a controlled error and prints its stack trace.
 *
 * @returns {void}
 */
function demonstrateStackTrace() {
  try {
    createPriorityLabel(9);
  } catch (error) {
    console.error('A controlled error occurred.');
    console.error(`Error name: ${error.name}`);
    console.error(`Error message: ${error.message}`);
    console.error('\nStack trace:');
    console.error(error.stack);
  }
}

demonstrateStackTrace();

console.log('\nStack-trace example completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/stack-traces.js
```

Expected output includes:

```text
A controlled error occurred.
Error name: RangeError
Error message: Priority "9" must be a whole number from 1 through 5.

Stack trace:
RangeError: Priority "9" must be a whole number from 1 through 5.
    at requirePriority (...)
    at createPriorityLabel (...)
    at demonstrateStackTrace (...)
```

The exact line numbers and path formatting will vary.

---

## Step 8: Use Intentional Debug Logging

### The Target

Use structured logs to inspect values without producing confusing output.

### The Concept

Debugging is the process of finding why actual behavior differs from expected behavior.

A useful log answers a specific question.

Poor log:

```js
console.log('Here');
```

Better log:

```js
console.log({
  taskId,
  taskIndex,
  taskWasFound: taskIndex !== -1
});
```

Structured logs are easier to scan because each value has a label.

### The Implementation

Create this file.

### `src/primers/debug-logging.js`

```js
/**
 * Primer 4: Structured debug logging.
 *
 * Run with:
 * node src/primers/debug-logging.js
 */

/**
 * Finds a task and prints useful diagnostic information.
 *
 * @param {Array<{ id: string, title: string }>} tasks - Tasks to search.
 * @param {string} taskId - ID to find.
 * @returns {{ id: string, title: string } | null} Matching task or null.
 */
function findTaskWithDebugInformation(tasks, taskId) {
  const taskIndex = tasks.findIndex((task) => task.id === taskId);
  const task = tasks.at(taskIndex) ?? null;

  console.log({
    event: 'task.lookup',
    taskId,
    taskIndex,
    taskWasFound: task !== null,
    availableTaskIds: tasks.map((candidateTask) => candidateTask.id)
  });

  return task;
}

const tasks = [
  {
    id: 'task_1',
    title: 'Inspect console output'
  },
  {
    id: 'task_2',
    title: 'Read a stack trace'
  }
];

const existingTask = findTaskWithDebugInformation(tasks, 'task_2');
const missingTask = findTaskWithDebugInformation(tasks, 'task_9999');

console.log({
  existingTask,
  missingTask
});

console.log('\nDebug logging example completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/debug-logging.js
```

Expected output includes:

```text
{
  event: 'task.lookup',
  taskId: 'task_2',
  taskIndex: 1,
  taskWasFound: true,
  availableTaskIds: [ 'task_1', 'task_2' ]
}
```

And for the missing task:

```text
{
  event: 'task.lookup',
  taskId: 'task_9999',
  taskIndex: -1,
  taskWasFound: false,
  availableTaskIds: [ 'task_1', 'task_2' ]
}
```

---

## Step 9: Automatically Rerun Code with `node --watch`

### The Target

Use Node.js watch mode to rerun a file whenever you save a relevant file.

### The Concept

During active development, manually rerunning the same command after every edit can be repetitive.

Node.js watch mode observes project files. When a watched file changes, Node.js restarts the program.

Think of watch mode as an assistant who presses the “run” button whenever you save your work.

### The Implementation

Start the module demo in watch mode:

```bash
node --watch src/primers/module-demo/module-demo.js
```

Now edit this line in `src/primers/module-demo/module-demo.js`:

```js
title: 'Run module entry point',
```

Change it to:

```js
title: 'Verify automatic reruns with watch mode',
```

Save the file.

### The Verification

After saving, Node.js should rerun the file automatically. Output should include:

```text
[task_3] Verify automatic reruns with watch mode — pending, priority 2
```

Stop watch mode with:

```text
Ctrl+C
```

If watch mode is unavailable, verify your Node.js version:

```bash
node --version
```

Use a current Node.js LTS version.

---

## Step 10: Use the Node.js Debugger

### The Target

Pause a running program with `debugger;` and inspect variables using Node.js’s built-in debugger.

### The Concept

A debugger lets you pause execution and inspect program state before the next line runs.

`console.log()` is useful for simple questions. A debugger is useful when you need to:

- Pause at a specific line
- Inspect many values
- Step through code one statement at a time
- Observe how a variable changes through a function

The `debugger;` statement is a breakpoint written directly in JavaScript.

### The Implementation

Create this file.

### `src/primers/debugger-basics.js`

```js
/**
 * Primer 4: Node.js debugger basics.
 *
 * Run with:
 * node inspect src/primers/debugger-basics.js
 */

/**
 * Calculates a task progress percentage.
 *
 * @param {number} completedTaskCount - Number of completed tasks.
 * @param {number} totalTaskCount - Total number of tasks.
 * @returns {number} Rounded completion percentage.
 * @throws {RangeError} When totalTaskCount is not positive.
 */
function calculateCompletionPercentage(
  completedTaskCount,
  totalTaskCount
) {
  if (!Number.isInteger(totalTaskCount) || totalTaskCount <= 0) {
    throw new RangeError('totalTaskCount must be a positive integer.');
  }

  debugger;

  return Math.round(
    (completedTaskCount / totalTaskCount) * 100
  );
}

const completionPercentage = calculateCompletionPercentage(3, 4);

console.log({
  completionPercentage
});

console.log('\nDebugger example completed successfully.');
```

### The Verification

Start Node’s debugger:

```bash
node inspect src/primers/debugger-basics.js
```

You should see output similar to:

```text
Debugger listening on ws://127.0.0.1:9229/...
For help, see: https://nodejs.org/en/docs/inspector
Break on start in src/primers/debugger-basics.js:...
```

At the debugger prompt, enter:

```text
cont
```

When execution reaches `debugger;`, inspect the values:

```text
repl
```

Then enter:

```js
completedTaskCount
```

Expected output:

```text
3
```

Enter:

```js
totalTaskCount
```

Expected output:

```text
4
```

Exit the REPL:

```text
.exit
```

Continue program execution:

```text
cont
```

Expected final output:

```text
{ completionPercentage: 75 }

Debugger example completed successfully.
```

> If you use Visual Studio Code, you can also place a breakpoint in the editor gutter and use the **Run and Debug** panel. The core idea is the same: pause execution, inspect values, then continue.

---

## Step 11: Add Primer 4 Scripts

### The Target

Add npm commands for the new Primer 4 modules.

### The Concept

Named scripts make it easier to return to a specific debugging or module example later.

### The Implementation

Add these entries to the existing `"scripts"` object in `package.json`.

### `package.json` — scripts additions

```json
{
  "scripts": {
    "primer:4:modules": "node src/primers/module-demo/module-demo.js",
    "primer:4:paths": "node src/primers/module-demo/import-path-reference.js",
    "primer:4:stack-traces": "node src/primers/stack-traces.js",
    "primer:4:logging": "node src/primers/debug-logging.js",
    "primer:4:watch": "node --watch src/primers/module-demo/module-demo.js",
    "primer:4:debugger": "node inspect src/primers/debugger-basics.js"
  }
}
```

### The Verification

Run:

```bash
npm run primer:4:modules
npm run primer:4:paths
npm run primer:4:stack-traces
npm run primer:4:logging
```

Each command should complete successfully.

To try watch mode:

```bash
npm run primer:4:watch
```

To try the debugger:

```bash
npm run primer:4:debugger
```

---

# Primer 4 Reference: ES Modules and Debugging

## Named exports

Export a named function:

```js
export function createTask() {
  return {
    id: 'task_1'
  };
}
```

Import it using the same name:

```js
import {
  createTask
} from './task.js';
```

---

## Default exports

Use a default export only when the module has one clear primary value.

```js
export default function formatTask(task) {
  return task.title;
}
```

Import it without braces:

```js
import formatTask from './format-task.js';
```

A module can have one default export and multiple named exports, but named exports are often easier to refactor and search in larger codebases.

---

## Relative import paths

```js
import { value } from './same-directory-file.js';
import { value } from '../parent-directory-file.js';
import { value } from '../../two-levels-up.js';
```

For Node.js ES modules, include `.js` for local JavaScript files:

```js
import { createTask } from './task.js';
```

---

## Useful debugging commands

Run a module:

```bash
node src/primers/module-demo/module-demo.js
```

Check syntax without running normal program logic:

```bash
node --check src/primers/module-demo/module-demo.js
```

Rerun automatically after saving:

```bash
node --watch src/primers/module-demo/module-demo.js
```

Start the terminal debugger:

```bash
node inspect src/primers/debugger-basics.js
```

---

## Error investigation checklist

When code fails:

1. Read the error type.
2. Read the message.
3. Open the file and line number named in the stack trace.
4. Inspect the values involved.
5. Confirm your import path is correct.
6. Confirm that the imported name matches an exported name.
7. Save files before rerunning.
8. Make one correction at a time.
9. Rerun the same verification command.

---

# Primer 4 Completion Checklist

Run:

```bash
npm run primer:4:modules
npm run primer:4:paths
npm run primer:4:stack-traces
npm run primer:4:logging
```

Confirm that you can explain:

- What `export` makes available from a module.
- What `import` receives from another module.
- Why `./` and `../` point to different locations.
- Why local ES module imports include `.js`.
- How a stack trace identifies the file and function where an error occurred.
- Why structured logging is more useful than vague messages.
- When to use `node --watch`.
- When a debugger is more useful than additional `console.log()` calls.
