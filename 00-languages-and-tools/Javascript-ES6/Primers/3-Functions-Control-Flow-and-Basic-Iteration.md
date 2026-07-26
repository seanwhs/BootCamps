# Primer 3: Functions, Control Flow, and Basic Iteration

Before using arrow functions, generators, and async iteration in the main series, you need a comfortable understanding of ordinary functions, decisions, and loops.

This primer covers:

- Function declarations
- Parameters and arguments
- Return values
- `if`, `else if`, and `else`
- Comparison and logical operators
- `for...of` loops
- Basic array methods: `.map()`, `.filter()`, `.find()`, and `.reduce()`
- Writing small, focused functions
- Returning predictable results

Think of these concepts as the basic machinery inside an application:

- **Functions** are reusable machines.
- **Conditions** are decision gates.
- **Loops** are conveyor belts.
- **Array methods** are specialized conveyor belts that filter, transform, locate, or summarize items.

---

## Step 1: Create and Call Functions

### The Target

Create a module that demonstrates function declarations, parameters, arguments, and return values.

### The Concept

A **function** is a named, reusable group of instructions.

For example, instead of repeatedly writing code that formats a task label, you can create one function:

```js
function createTaskLabel(taskTitle) {
  return `Task: ${taskTitle}`;
}
```

A **parameter** is the variable written in the function definition:

```js
function createTaskLabel(taskTitle) {
```

An **argument** is the actual value supplied when calling it:

```js
createTaskLabel('Review documentation');
```

A **return value** is the result sent back by a function:

```js
return `Task: ${taskTitle}`;
```

### The Implementation

Create this file.

### `src/primers/functions.js`

```js
/**
 * Primer 3: Function declarations, parameters, and return values.
 *
 * Run with:
 * node src/primers/functions.js
 */

/**
 * Prints a readable section heading.
 *
 * @param {string} title - Heading to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

/**
 * Creates a readable task label.
 *
 * @param {string} taskTitle - Title to include in the label.
 * @returns {string} Formatted task label.
 */
function createTaskLabel(taskTitle) {
  return `Task: ${taskTitle}`;
}

/**
 * Adds two numeric values.
 *
 * @param {number} firstValue - First number.
 * @param {number} secondValue - Second number.
 * @returns {number} Sum of both values.
 */
function add(firstValue, secondValue) {
  return firstValue + secondValue;
}

/**
 * Creates a task record.
 *
 * @param {string} id - Task identifier.
 * @param {string} title - Task title.
 * @param {boolean} completed - Completion state.
 * @returns {{ id: string, title: string, completed: boolean }} Task record.
 */
function createTask(id, title, completed) {
  return {
    id,
    title,
    completed
  };
}

printSection('Calling functions');

const taskLabel = createTaskLabel('Review JavaScript functions');
const total = add(12, 8);

console.log({
  taskLabel,
  total
});

printSection('Functions can return objects');

const task = createTask(
  'task_1',
  'Create a reusable function',
  false
);

console.log(task);

printSection('Functions can call other functions');

/**
 * Creates a summary sentence for a task.
 *
 * @param {{ id: string, title: string, completed: boolean }} taskRecord - Task to summarize.
 * @returns {string} Task summary.
 */
function createTaskSummary(taskRecord) {
  const status = taskRecord.completed ? 'completed' : 'pending';
  const label = createTaskLabel(taskRecord.title);

  return `${label} has ID ${taskRecord.id} and is ${status}.`;
}

console.log(createTaskSummary(task));

printSection('A function without return produces undefined');

/**
 * Prints a message but intentionally returns no value.
 *
 * @param {string} message - Message to print.
 * @returns {void}
 */
function printMessage(message) {
  console.log(message);
}

const printResult = printMessage('This message was printed by a function.');

console.log({
  printResult,
  explanation:
    'Functions that do not use return produce undefined.'
});

console.log('\nFunction examples completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/functions.js
```

Expected output includes:

```text
--- Calling functions ---
{
  taskLabel: 'Task: Review JavaScript functions',
  total: 20
}

--- A function without return produces undefined ---
This message was printed by a function.
{
  printResult: undefined,
  explanation: 'Functions that do not use return produce undefined.'
}
```

---

## Step 2: Make Decisions with Conditional Statements

### The Target

Create a module that uses `if`, `else if`, and `else` to make decisions.

### The Concept

A conditional statement lets the program choose between paths.

Think of it as a decision gate in a warehouse:

- If the package is urgent, send it to the priority lane.
- Otherwise, if it is normal, send it to the standard lane.
- Otherwise, send it to the low-priority lane.

JavaScript conditions evaluate to either `true` or `false`.

### The Implementation

Create this file.

### `src/primers/control-flow.js`

```js
/**
 * Primer 3: Conditional statements and logical operators.
 *
 * Run with:
 * node src/primers/control-flow.js
 */

/**
 * Prints a readable section heading.
 *
 * @param {string} title - Heading to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

/**
 * Converts a numeric priority into a readable label.
 *
 * @param {number} priority - Priority value from 1 through 5.
 * @returns {string} Priority label.
 * @throws {RangeError} When priority is outside the valid range.
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

  if (priority === 5) {
    return 'lowest';
  }

  throw new RangeError('Priority must be a whole number from 1 through 5.');
}

/**
 * Determines whether a task can be edited.
 *
 * @param {{
 *   completed: boolean,
 *   archived: boolean
 * }} task - Task state.
 * @param {{ hasWritePermission: boolean }} user - User permission state.
 * @returns {boolean} Whether editing is allowed.
 */
function canEditTask(task, user) {
  return user.hasWritePermission && !task.archived && !task.completed;
}

printSection('if and else if');

for (const priority of [1, 2, 3, 4, 5]) {
  console.log({
    priority,
    label: getPriorityLabel(priority)
  });
}

printSection('Logical AND, OR, and NOT');

const editor = {
  hasWritePermission: true
};

const reader = {
  hasWritePermission: false
};

const pendingTask = {
  completed: false,
  archived: false
};

const completedTask = {
  completed: true,
  archived: false
};

console.log({
  editorCanEditPendingTask: canEditTask(pendingTask, editor),
  readerCanEditPendingTask: canEditTask(pendingTask, reader),
  editorCanEditCompletedTask: canEditTask(completedTask, editor)
});

printSection('Guard clauses');

/**
 * Returns a task title only when it is valid.
 *
 * @param {unknown} title - Candidate task title.
 * @returns {string} Trimmed task title.
 * @throws {TypeError} When title is not text.
 * @throws {RangeError} When title is blank.
 */
function requireTaskTitle(title) {
  if (typeof title !== 'string') {
    throw new TypeError('Task title must be a string.');
  }

  const normalizedTitle = title.trim();

  if (normalizedTitle.length === 0) {
    throw new RangeError('Task title must not be blank.');
  }

  return normalizedTitle;
}

console.log({
  normalizedTitle: requireTaskTitle('  Review control flow  ')
});

console.log('\nControl-flow examples completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/control-flow.js
```

Expected output includes:

```text
--- Logical AND, OR, and NOT ---
{
  editorCanEditPendingTask: true,
  readerCanEditPendingTask: false,
  editorCanEditCompletedTask: false
}
```

---

## Step 3: Repeat Work with `for...of`

### The Target

Use `for...of` to process every value in an array.

### The Concept

A loop repeats a task.

`for...of` is the clearest modern loop when you want to process each value in an iterable collection, such as an array or `Set`.

Think of it as taking one item at a time from a conveyor belt:

```js
for (const task of tasks) {
  console.log(task.title);
}
```

The loop ends after it has processed every item.

### The Implementation

Create this file.

### `src/primers/basic-iteration.js`

```js
/**
 * Primer 3: Basic iteration with for...of.
 *
 * Run with:
 * node src/primers/basic-iteration.js
 */

/**
 * Prints a readable section heading.
 *
 * @param {string} title - Heading to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

const tasks = [
  {
    id: 'task_1',
    title: 'Learn function declarations',
    completed: true
  },
  {
    id: 'task_2',
    title: 'Practice conditional statements',
    completed: true
  },
  {
    id: 'task_3',
    title: 'Learn array iteration',
    completed: false
  }
];

printSection('Process each task');

for (const task of tasks) {
  console.log(`${task.id}: ${task.title}`);
}

printSection('Count completed tasks');

let completedTaskCount = 0;

for (const task of tasks) {
  if (task.completed) {
    completedTaskCount += 1;
  }
}

console.log({
  taskCount: tasks.length,
  completedTaskCount,
  pendingTaskCount: tasks.length - completedTaskCount
});

printSection('Stop a loop early with break');

for (const task of tasks) {
  if (!task.completed) {
    console.log(`Found first pending task: ${task.title}`);
    break;
  }
}

printSection('Skip one loop item with continue');

for (const task of tasks) {
  if (task.completed) {
    continue;
  }

  console.log(`Pending task: ${task.title}`);
}

console.log('\nBasic iteration examples completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/basic-iteration.js
```

Expected output includes:

```text
--- Count completed tasks ---
{
  taskCount: 3,
  completedTaskCount: 2,
  pendingTaskCount: 1
}

--- Stop a loop early with break ---
Found first pending task: Learn array iteration
```

---

## Step 4: Transform, Filter, Find, and Summarize Arrays

### The Target

Use common array methods to work with collections declaratively.

### The Concept

Array methods let you describe *what* result you need instead of manually managing every loop detail.

| Method | Purpose | Real-world analogy |
|---|---|---|
| `.map()` | Transform every item | Rewrite every shipping label |
| `.filter()` | Keep matching items | Keep only packages for one destination |
| `.find()` | Return the first match | Find the first package with a specific ID |
| `.reduce()` | Combine items into one result | Add every item price into one total |

These methods do not mutate the original array.

### The Implementation

Create this file.

### `src/primers/array-methods.js`

```js
/**
 * Primer 3: map, filter, find, and reduce.
 *
 * Run with:
 * node src/primers/array-methods.js
 */

/**
 * Prints a readable section heading.
 *
 * @param {string} title - Heading to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

const tasks = [
  {
    id: 'task_1',
    title: 'Install Node.js',
    completed: true,
    priority: 1
  },
  {
    id: 'task_2',
    title: 'Create project files',
    completed: true,
    priority: 2
  },
  {
    id: 'task_3',
    title: 'Practice array methods',
    completed: false,
    priority: 2
  },
  {
    id: 'task_4',
    title: 'Review primer output',
    completed: false,
    priority: 3
  }
];

printSection('map transforms every item');

const taskTitles = tasks.map((task) => task.title);

const taskLabels = tasks.map((task) => {
  const status = task.completed ? 'completed' : 'pending';

  return `[${task.id}] ${task.title} (${status})`;
});

console.log({
  taskTitles,
  taskLabels
});

printSection('filter keeps matching items');

const completedTasks = tasks.filter((task) => task.completed);

const highPriorityTasks = tasks.filter((task) => {
  return task.priority <= 2;
});

console.log({
  completedTaskIds: completedTasks.map((task) => task.id),
  highPriorityTaskIds: highPriorityTasks.map((task) => task.id)
});

printSection('find returns the first matching item');

const targetTask = tasks.find((task) => task.id === 'task_3');
const missingTask = tasks.find((task) => task.id === 'task_9999');

console.log({
  targetTask,
  missingTask
});

printSection('reduce combines items into one value');

const completedTaskCount = tasks.reduce((count, task) => {
  return task.completed ? count + 1 : count;
}, 0);

const taskCountByPriority = tasks.reduce((counts, task) => {
  const priorityKey = String(task.priority);
  const currentCount = counts[priorityKey] ?? 0;

  return {
    ...counts,
    [priorityKey]: currentCount + 1
  };
}, {});

console.log({
  completedTaskCount,
  taskCountByPriority
});

printSection('The original array is preserved');

console.log({
  originalTaskIds: tasks.map((task) => task.id),
  originalTaskCount: tasks.length
});

console.log('\nArray method examples completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/array-methods.js
```

Expected output includes:

```text
--- find returns the first matching item ---
{
  targetTask: {
    id: 'task_3',
    title: 'Practice array methods',
    completed: false,
    priority: 2
  },
  missingTask: undefined
}
```

And:

```text
--- reduce combines items into one value ---
{
  completedTaskCount: 2,
  taskCountByPriority: { '1': 1, '2': 2, '3': 1 }
}
```

---

## Step 5: Build a Basic Task Service

### The Target

Create a small module that combines functions, conditions, loops, and array methods.

### The Concept

This step builds a simple task service: a group of functions that manage task records.

It will:

- Validate a task title
- Create a task
- Find a task by ID
- Complete a task immutably
- Produce a task summary

This is the kind of foundation you will extend with modern syntax in later parts.

### The Implementation

Create this file.

### `src/primers/task-service.js`

```js
/**
 * Primer 3: Basic task service.
 *
 * Run with:
 * node src/primers/task-service.js
 */

/**
 * Validates and normalizes required task text.
 *
 * @param {unknown} value - Candidate task title.
 * @returns {string} Trimmed title.
 * @throws {TypeError} When value is not a string.
 * @throws {RangeError} When value is blank.
 */
function requireTaskTitle(value) {
  if (typeof value !== 'string') {
    throw new TypeError('Task title must be a string.');
  }

  const title = value.trim();

  if (title.length === 0) {
    throw new RangeError('Task title must not be blank.');
  }

  return title;
}

/**
 * Creates a normalized task.
 *
 * @param {string} id - Task identifier.
 * @param {unknown} title - Candidate title.
 * @param {number} priority - Numeric priority.
 * @returns {{
 *   id: string,
 *   title: string,
 *   priority: number,
 *   completed: boolean
 * }} Task record.
 * @throws {RangeError} When priority is invalid.
 */
function createTask(id, title, priority = 3) {
  if (!Number.isInteger(priority) || priority < 1 || priority > 5) {
    throw new RangeError('Priority must be a whole number from 1 through 5.');
  }

  return {
    id,
    title: requireTaskTitle(title),
    priority,
    completed: false
  };
}

/**
 * Finds a task by ID.
 *
 * @param {Array<{ id: string }>} tasks - Tasks to search.
 * @param {string} taskId - ID to find.
 * @returns {object | undefined} Matching task or undefined.
 */
function findTaskById(tasks, taskId) {
  return tasks.find((task) => task.id === taskId);
}

/**
 * Returns a revised task array with one task marked complete.
 *
 * @param {Array<{
 *   id: string,
 *   title: string,
 *   priority: number,
 *   completed: boolean
 * }>} tasks - Source task list.
 * @param {string} taskId - Task to complete.
 * @returns {Array<{
 *   id: string,
 *   title: string,
 *   priority: number,
 *   completed: boolean
 * }>} Updated task list.
 * @throws {RangeError} When no matching task exists.
 */
function completeTask(tasks, taskId) {
  const taskIndex = tasks.findIndex((task) => task.id === taskId);

  if (taskIndex === -1) {
    throw new RangeError(`Task "${taskId}" does not exist.`);
  }

  return tasks.with(taskIndex, {
    ...tasks.at(taskIndex),
    completed: true
  });
}

/**
 * Creates a dashboard-ready task summary.
 *
 * @param {Array<{ completed: boolean }>} tasks - Task collection.
 * @returns {{
 *   total: number,
 *   completed: number,
 *   pending: number
 * }} Summary values.
 */
function summarizeTasks(tasks) {
  const completed = tasks.filter((task) => task.completed).length;

  return {
    total: tasks.length,
    completed,
    pending: tasks.length - completed
  };
}

const initialTasks = [
  createTask('task_1', 'Install Node.js', 1),
  createTask('task_2', 'Create the project folder', 2),
  createTask('task_3', 'Practice basic iteration', 2)
];

const completedTasks = completeTask(initialTasks, 'task_2');

console.log('Initial tasks:');
console.table(initialTasks);

console.log('\nCompleted-task revision:');
console.table(completedTasks);

console.log('\nTask summary:');
console.log(summarizeTasks(completedTasks));

console.log('\nTask lookup:');
console.log(findTaskById(completedTasks, 'task_2'));

console.log('\nTask service examples completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/task-service.js
```

Expected output includes a table where:

- `task_2` is `completed: false` in the initial table.
- `task_2` is `completed: true` in the revised table.

Expected summary:

```text
{
  total: 3,
  completed: 1,
  pending: 2
}
```

---

## Step 6: Add Primer 3 Scripts

### The Target

Add npm commands for the Primer 3 modules.

### The Concept

Each command gives you a quick way to rerun one learning area while reviewing or debugging.

### The Implementation

Add these entries to the existing `"scripts"` object in `package.json`.

### `package.json` — scripts additions

```json
{
  "scripts": {
    "primer:3:functions": "node src/primers/functions.js",
    "primer:3:control-flow": "node src/primers/control-flow.js",
    "primer:3:iteration": "node src/primers/basic-iteration.js",
    "primer:3:array-methods": "node src/primers/array-methods.js",
    "primer:3:task-service": "node src/primers/task-service.js"
  }
}
```

### The Verification

Run:

```bash
npm run primer:3:functions
npm run primer:3:control-flow
npm run primer:3:iteration
npm run primer:3:array-methods
npm run primer:3:task-service
```

Each command should complete without an uncaught error.

---

# Primer 3 Reference: Functions, Decisions, and Iteration

## Function declaration

```js
function add(firstValue, secondValue) {
  return firstValue + secondValue;
}
```

Call it:

```js
const total = add(2, 3);
```

---

## Conditional statement

```js
if (priority === 1) {
  console.log('Critical');
} else if (priority === 2) {
  console.log('High');
} else {
  console.log('Normal or lower');
}
```

---

## Logical operators

```js
const canEdit = hasWritePermission && !isArchived;
const canView = hasReadPermission || hasWritePermission;
const isPending = !task.completed;
```

| Operator | Meaning |
|---|---|
| `&&` | Both conditions must be true |
| `||` | At least one condition must be true |
| `!` | Reverses a boolean value |

---

## `for...of`

```js
for (const task of tasks) {
  console.log(task.title);
}
```

Use it when you need to process each value directly.

---

## Array methods

### Transform every item with `.map()`

```js
const titles = tasks.map((task) => task.title);
```

### Keep matching items with `.filter()`

```js
const pendingTasks = tasks.filter((task) => !task.completed);
```

### Find one item with `.find()`

```js
const task = tasks.find((task) => task.id === 'task_1');
```

### Combine values with `.reduce()`

```js
const totalPriority = tasks.reduce((total, task) => {
  return total + task.priority;
}, 0);
```

---

# Primer 3 Completion Checklist

Run:

```bash
npm run primer:3:functions
npm run primer:3:control-flow
npm run primer:3:iteration
npm run primer:3:array-methods
npm run primer:3:task-service
```

Confirm that you can explain:

- The difference between a parameter and an argument.
- What a function returns when it has no `return` statement.
- How `if`, `else if`, and `else` select a path.
- How `break` and `continue` affect a loop.
- When to use `.map()`, `.filter()`, `.find()`, and `.reduce()`.
- Why the task service returns a new array when completing a task.
