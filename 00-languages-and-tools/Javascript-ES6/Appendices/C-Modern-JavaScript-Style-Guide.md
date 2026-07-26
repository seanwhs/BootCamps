# Appendix C: Modern JavaScript Style Guide

A style guide is a shared set of decisions about how code should look and behave.

It is not primarily about personal preference. It is about making code predictable. When every file follows the same rules, readers spend less time decoding formatting and more time understanding the program.

Think of a style guide as road signage. Roads can still work without consistent signs, but consistent signs make every journey faster and safer.

This appendix defines practical conventions for the tutorial project and for modern JavaScript applications:

- Naming
- Variables and reassignment
- Functions
- Objects and arrays
- Immutability
- Conditions and defensive access
- Errors
- Modules
- Collections
- Asynchronous code
- Comments and documentation
- Formatting and linting

---

## C.1: Add a Runnable Style Guide Example

### The Target

Create one complete runnable file that demonstrates the conventions in this appendix.

### The Concept

Style rules are easier to remember when they appear in realistic code rather than a list of isolated instructions.

This file models a small task-management service. It validates input, normalizes data, creates immutable updates, groups tasks, and handles an asynchronous task source.

### The Implementation

Create this file.

### `src/appendices/appendix-c-style-guide.js`

```js
/**
 * Appendix C: Modern JavaScript Style Guide examples.
 *
 * Run with:
 * node src/appendices/appendix-c-style-guide.js
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
 * Pauses for a selected duration.
 *
 * @param {number} milliseconds - Duration to wait.
 * @returns {Promise<void>} A promise resolved after the delay.
 */
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

/**
 * Ensures that an incoming value is a non-empty string.
 *
 * @param {unknown} value - Value to validate.
 * @param {string} fieldName - Human-readable field name for errors.
 * @returns {string} Trimmed non-empty string.
 * @throws {TypeError} When value is not a string.
 * @throws {RangeError} When value is empty after trimming.
 */
function requireNonEmptyString(value, fieldName) {
  if (typeof value !== 'string') {
    throw new TypeError(`${fieldName} must be a string.`);
  }

  const normalizedValue = value.trim();

  if (normalizedValue.length === 0) {
    throw new RangeError(`${fieldName} must not be empty.`);
  }

  return normalizedValue;
}

/**
 * Converts an unknown value into a normalized array of unique text tags.
 *
 * @param {unknown} value - Candidate tag collection.
 * @returns {string[]} Unique, trimmed, non-empty tags.
 */
function normalizeTags(value) {
  if (!Array.isArray(value)) {
    return [];
  }

  const normalizedTags = value
    .filter((tag) => typeof tag === 'string')
    .map((tag) => tag.trim())
    .filter((tag) => tag.length > 0);

  return [...new Set(normalizedTags)];
}

/**
 * Creates a normalized task record from external input.
 *
 * @param {{
 *   id: unknown,
 *   title: unknown,
 *   ownerId?: unknown,
 *   completed?: unknown,
 *   priority?: unknown,
 *   tags?: unknown
 * }} input - Untrusted task-like input.
 * @returns {{
 *   id: string,
 *   title: string,
 *   ownerId: string | null,
 *   completed: boolean,
 *   priority: number,
 *   tags: string[]
 * }} Normalized task.
 */
function createTask(input) {
  const id = requireNonEmptyString(input.id, 'Task id');
  const title = requireNonEmptyString(input.title, 'Task title');

  const ownerId =
    typeof input.ownerId === 'string' && input.ownerId.trim().length > 0
      ? input.ownerId.trim()
      : null;

  const priority =
    typeof input.priority === 'number' && Number.isInteger(input.priority)
      ? input.priority
      : 3;

  return {
    id,
    title,
    ownerId,
    completed: input.completed === true,
    priority,
    tags: normalizeTags(input.tags)
  };
}

/**
 * Returns a new task with caller-provided changes applied.
 *
 * This function does not mutate the existing task.
 *
 * @param {{
 *   id: string,
 *   title: string,
 *   ownerId: string | null,
 *   completed: boolean,
 *   priority: number,
 *   tags: string[]
 * }} task - Existing task.
 * @param {Partial<{
 *   title: string,
 *   ownerId: string | null,
 *   completed: boolean,
 *   priority: number,
 *   tags: string[]
 * }>} changes - Validated changes.
 * @returns {{
 *   id: string,
 *   title: string,
 *   ownerId: string | null,
 *   completed: boolean,
 *   priority: number,
 *   tags: string[]
 * }} Updated task.
 */
function updateTask(task, changes) {
  const updatedTask = {
    ...task,
    ...changes
  };

  return {
    ...updatedTask,
    title: requireNonEmptyString(updatedTask.title, 'Task title'),
    tags: normalizeTags(updatedTask.tags)
  };
}

/**
 * Returns an immutable copy of tasks with one task updated by ID.
 *
 * @param {Array<{
 *   id: string,
 *   title: string,
 *   ownerId: string | null,
 *   completed: boolean,
 *   priority: number,
 *   tags: string[]
 * }>} tasks - Existing tasks.
 * @param {string} taskId - ID of the task to update.
 * @param {Partial<{
 *   title: string,
 *   ownerId: string | null,
 *   completed: boolean,
 *   priority: number,
 *   tags: string[]
 * }>} changes - Changes to apply.
 * @returns {Array<{
 *   id: string,
 *   title: string,
 *   ownerId: string | null,
 *   completed: boolean,
 *   priority: number,
 *   tags: string[]
 * }>} Updated task collection.
 * @throws {RangeError} When no task has taskId.
 */
function updateTaskById(tasks, taskId, changes) {
  const taskIndex = tasks.findIndex((task) => task.id === taskId);

  if (taskIndex === -1) {
    throw new RangeError(`Task "${taskId}" does not exist.`);
  }

  const existingTask = tasks.at(taskIndex);
  const revisedTask = updateTask(existingTask, changes);

  return tasks.with(taskIndex, revisedTask);
}

/**
 * Groups tasks by owner ID.
 *
 * Unassigned tasks use the stable "unassigned" group key.
 *
 * @param {Array<{
 *   ownerId: string | null
 * }>} tasks - Tasks to group.
 * @returns {Map<string, number>} Count of tasks for each owner.
 */
function countTasksByOwner(tasks) {
  const taskCountByOwner = new Map();

  for (const task of tasks) {
    const ownerKey = task.ownerId ?? 'unassigned';
    const currentCount = taskCountByOwner.get(ownerKey) ?? 0;

    taskCountByOwner.set(ownerKey, currentCount + 1);
  }

  return taskCountByOwner;
}

/**
 * Returns display models in priority order without changing source tasks.
 *
 * @param {Array<{
 *   id: string,
 *   title: string,
 *   completed: boolean,
 *   priority: number
 * }>} tasks - Tasks to display.
 * @returns {Array<{
 *   id: string,
 *   title: string,
 *   status: string,
 *   priority: number
 * }>} Display-ready tasks.
 */
function createTaskDisplayRows(tasks) {
  return tasks
    .toSorted((firstTask, secondTask) => {
      const priorityDifference = firstTask.priority - secondTask.priority;

      if (priorityDifference !== 0) {
        return priorityDifference;
      }

      return firstTask.title.localeCompare(secondTask.title);
    })
    .map(({ id, title, completed, priority }) => ({
      id,
      title,
      status: completed ? 'completed' : 'pending',
      priority
    }));
}

/**
 * Simulates a paginated external task source.
 *
 * @returns {AsyncGenerator<unknown[], void, unknown>} Pages of raw task input.
 */
async function* fetchRawTaskPages() {
  await delay(5);

  yield [
    {
      id: 'task_1',
      title: ' Create style guide ',
      ownerId: 'user_1001',
      completed: true,
      priority: 1,
      tags: ['javascript', 'style', 'javascript', '']
    },
    {
      id: 'task_2',
      title: 'Review examples',
      ownerId: 'user_1002',
      completed: false,
      priority: 2,
      tags: ['review', 'documentation']
    }
  ];

  await delay(5);

  yield [
    {
      id: 'task_3',
      title: 'Publish appendix',
      completed: false,
      priority: 1,
      tags: ['documentation', 'release']
    }
  ];
}

/**
 * Loads, validates, and normalizes all pages from an async task source.
 *
 * @returns {Promise<Array<{
 *   id: string,
 *   title: string,
 *   ownerId: string | null,
 *   completed: boolean,
 *   priority: number,
 *   tags: string[]
 * }>>} Normalized tasks.
 */
async function loadTasks() {
  const tasks = [];

  for await (const rawTaskPage of fetchRawTaskPages()) {
    for (const rawTask of rawTaskPage) {
      tasks.push(createTask(rawTask));
    }
  }

  return tasks;
}

printSection('Constants describe values that are not reassigned');

const applicationName = 'Modern JavaScript Toolkit';
const maximumRecommendedPriority = 5;

console.log({
  applicationName,
  maximumRecommendedPriority
});

printSection('Load and normalize asynchronous data');

const tasks = await loadTasks();

console.log(tasks);

printSection('Create immutable updates');

const updatedTasks = updateTaskById(tasks, 'task_2', {
  completed: true,
  tags: ['review', 'documentation', 'completed']
});

console.log({
  originalTask: tasks.find((task) => task.id === 'task_2'),
  updatedTask: updatedTasks.find((task) => task.id === 'task_2'),
  sourceArrayWasPreserved: tasks !== updatedTasks
});

printSection('Use Map when key-value grouping is the central requirement');

const taskCountByOwner = countTasksByOwner(updatedTasks);

console.log(Object.fromEntries(taskCountByOwner));

printSection('Create sorted display data without mutating source data');

const taskDisplayRows = createTaskDisplayRows(updatedTasks);

console.table(taskDisplayRows);

printSection('Use explicit and useful error messages');

try {
  createTask({
    id: 'task_invalid',
    title: '   '
  });
} catch (error) {
  console.log({
    errorName: error.name,
    message: error.message
  });
}

console.log('\nAppendix C style guide examples completed successfully.');
```

Add this script to your existing `package.json` `"scripts"` object:

```json
"appendix:c:style": "node src/appendices/appendix-c-style-guide.js"
```

### The Verification

Run:

```bash
node src/appendices/appendix-c-style-guide.js
```

Expected output includes:

```text
--- Constants describe values that are not reassigned ---
{
  applicationName: 'Modern JavaScript Toolkit',
  maximumRecommendedPriority: 5
}

--- Create immutable updates ---
{
  originalTask: {
    id: 'task_2',
    title: 'Review examples',
    ownerId: 'user_1002',
    completed: false,
    priority: 2,
    tags: [ 'review', 'documentation' ]
  },
  updatedTask: {
    id: 'task_2',
    title: 'Review examples',
    ownerId: 'user_1002',
    completed: true,
    priority: 2,
    tags: [ 'review', 'documentation', 'completed' ]
  },
  sourceArrayWasPreserved: true
}

Appendix C style guide examples completed successfully.
```

---

# C.2: Variables and Reassignment

## The Target

Use variable declarations that communicate whether reassignment is intended.

## The Concept

A reader should know whether a value can be replaced just by looking at its declaration.

Use `const` as the default. Use `let` only when the variable must point to a different value later. Do not use `var` in new application code.

## The Implementation

### Prefer `const`

```js
const projectName = 'Modern JavaScript Toolkit';
const taskIds = ['task_1', 'task_2'];
const user = {
  id: 'user_1001'
};
```

### Use `let` for deliberate reassignment

```js
let currentPage = 1;

currentPage += 1;
```

### Avoid `var`

```js
// Avoid in modern JavaScript:
var status = 'legacy';
```

### Prefer immutable replacement over mutation when practical

```js
const originalSettings = {
  theme: 'light',
  compactMode: false
};

const revisedSettings = {
  ...originalSettings,
  theme: 'dark'
};
```

## The Verification

Run this command:

```bash
node --input-type=module -e "
const initial = { theme: 'light' };
const revised = { ...initial, theme: 'dark' };
console.log({ initial, revised, differentObjects: initial !== revised });
"
```

Expected result:

```text
{
  initial: { theme: 'light' },
  revised: { theme: 'dark' },
  differentObjects: true
}
```

---

# C.3: Names Should Explain Intent

## The Target

Choose names that reveal what a value represents, including its unit, state, or collection type when helpful.

## The Concept

Names are the labels on the storage boxes in your program. A label such as `data` or `result` forces the reader to open the box before knowing what it contains.

A name such as `responseTimesInMilliseconds` explains both contents and unit.

## The Implementation

### Prefer specific nouns

```js
const activeProjectIds = ['project_1', 'project_2'];
const taskCountByOwner = new Map();
const pendingTaskTitles = ['Review architecture'];
```

### Include units when numbers have units

```js
const timeoutMilliseconds = 5_000;
const taxRate = 0.2;
const priceCents = 4_999;
```

### Boolean names should read like yes/no questions

```js
const isAuthenticated = true;
const hasWritePermission = false;
const shouldSendEmail = true;
```

### Functions should usually use verbs

```js
function createTask() {}
function normalizeTags() {}
function calculateTotal() {}
function fetchProjectPages() {}
```

### Avoid unclear abbreviations

```js
// Avoid:
const usr = {};
const cfg = {};
const arr = [];

// Prefer:
const user = {};
const configuration = {};
const taskIds = [];
```

## The Verification

Use this quick review checklist on a file:

```bash
grep -nE '\b(data|result|item|thing|temp|obj|arr|cfg|usr)\b' src/index.js
```

If the command finds names, inspect each one. Some generic names are acceptable in very small scopes, but names at module or function boundaries should communicate intent.

---

# C.4: Functions Should Do One Understandable Job

## The Target

Write functions that have clear inputs, predictable outputs, and focused responsibilities.

## The Concept

A function is like a tool. A screwdriver is easier to use and test than a tool that sometimes tightens screws, sometimes cuts wood, and sometimes measures temperature.

A focused function:

- Has a name that describes one job.
- Accepts clearly defined inputs.
- Returns a predictable value.
- Throws an informative error when it cannot fulfill its contract.

## The Implementation

### Prefer a focused function

```js
/**
 * Returns only completed tasks.
 *
 * @param {{ completed: boolean }[]} tasks - Tasks to filter.
 * @returns {{ completed: boolean }[]} Completed tasks.
 */
function getCompletedTasks(tasks) {
  return tasks.filter((task) => task.completed);
}
```

### Avoid a function with unrelated responsibilities

```js
// Avoid functions that validate, fetch, transform, log, mutate,
// render, and send notifications all at once.
function processEverything() {
  // Hard to understand and hard to test.
}
```

### Use early returns to reduce nesting

```js
/**
 * Returns a task when its ID exists.
 *
 * @param {{ id: string }[]} tasks - Searchable tasks.
 * @param {string} taskId - ID to find.
 * @returns {{ id: string } | undefined} Matching task, if present.
 */
function findTaskById(tasks, taskId) {
  if (taskId.length === 0) {
    return undefined;
  }

  return tasks.find((task) => task.id === taskId);
}
```

### Validate public boundaries

```js
/**
 * Creates a task title.
 *
 * @param {unknown} value - Candidate title.
 * @returns {string} Validated title.
 * @throws {TypeError} When value is not a string.
 * @throws {RangeError} When title is blank.
 */
function normalizeTaskTitle(value) {
  if (typeof value !== 'string') {
    throw new TypeError('Task title must be a string.');
  }

  const title = value.trim();

  if (title.length === 0) {
    throw new RangeError('Task title must not be blank.');
  }

  return title;
}
```

## The Verification

```bash
node --input-type=module -e "
function normalizeTaskTitle(value) {
  if (typeof value !== 'string') {
    throw new TypeError('Task title must be a string.');
  }

  const title = value.trim();

  if (title.length === 0) {
    throw new RangeError('Task title must not be blank.');
  }

  return title;
}

console.log(normalizeTaskTitle('  Review pull request  '));

try {
  normalizeTaskTitle('   ');
} catch (error) {
  console.log(error.name + ': ' + error.message);
}
"
```

Expected output:

```text
Review pull request
RangeError: Task title must not be blank.
```

---

# C.5: Prefer Immutable Updates for Shared Application State

## The Target

Avoid unexpected changes to data used elsewhere in an application.

## The Concept

Mutation means changing an existing value in place.

```js
task.completed = true;
```

Mutation is not always wrong. Local, private mutation can be efficient and simple. The danger appears when multiple parts of a program share the same object or array.

An immutable update returns a revised value while preserving the original:

```js
const revisedTask = {
  ...task,
  completed: true
};
```

This is easier to reason about because the before and after states both remain available.

## The Implementation

### Update an object immutably

```js
const task = {
  id: 'task_1',
  completed: false
};

const completedTask = {
  ...task,
  completed: true
};
```

### Update nested data immutably

```js
const project = {
  id: 'project_1',
  settings: {
    colorScheme: 'light',
    compactMode: false
  }
};

const darkProject = {
  ...project,
  settings: {
    ...project.settings,
    colorScheme: 'dark'
  }
};
```

### Update an array immutably

```js
const taskIds = ['task_1', 'task_2', 'task_3'];

const revisedTaskIds = taskIds.with(1, 'task_2_revised');
```

### Insert or remove without mutation

```js
const taskIds = ['task_1', 'task_2', 'task_3'];

const insertedTaskIds = taskIds.toSpliced(1, 0, 'task_1_5');
const removedTaskIds = taskIds.toSpliced(1, 1);
```

### Sort without mutation

```js
const tasks = [
  { id: 'task_2', priority: 2 },
  { id: 'task_1', priority: 1 }
];

const tasksByPriority = tasks.toSorted(
  (firstTask, secondTask) => firstTask.priority - secondTask.priority
);
```

## The Verification

```bash
node --input-type=module -e "
const tasks = [
  { id: 'task_1', completed: false },
  { id: 'task_2', completed: false }
];

const revisedTasks = tasks.with(1, {
  ...tasks.at(1),
  completed: true
});

console.log({
  original: tasks,
  revised: revisedTasks,
  originalSecondTaskUnchanged: tasks.at(1).completed === false
});
"
```

Expected result:

```text
{
  original: [
    { id: 'task_1', completed: false },
    { id: 'task_2', completed: false }
  ],
  revised: [
    { id: 'task_1', completed: false },
    { id: 'task_2', completed: true }
  ],
  originalSecondTaskUnchanged: true
}
```

---

# C.6: Use Optional Chaining and Nullish Coalescing Deliberately

## The Target

Safely handle absent values without hiding invalid assumptions.

## The Concept

Optional chaining answers:

> “Can I safely continue down this property path if the preceding value exists?”

Nullish coalescing answers:

> “If this value is truly missing (`null` or `undefined`), what default should I use?”

These tools are excellent for external inputs, optional configuration, API responses, and UI data. They should not be used to hide a situation that should be treated as an error.

## The Implementation

### Safely read optional data

```js
const city = user?.address?.city;
```

### Use a default only for absent values

```js
const colorScheme = user?.preferences?.colorScheme ?? 'system';
```

### Preserve `false`, `0`, and empty strings

```js
const pageSize = settings.pageSize ?? 25;
const showCompletedTasks = settings.showCompletedTasks ?? true;
```

### Do not use optional chaining for required values

```js
/**
 * Returns the required project ID.
 *
 * @param {{ id?: unknown }} project - Project-like input.
 * @returns {string} Project ID.
 * @throws {TypeError} When the ID is invalid.
 */
function getRequiredProjectId(project) {
  if (typeof project?.id !== 'string' || project.id.length === 0) {
    throw new TypeError('Project id is required.');
  }

  return project.id;
}
```

## The Verification

```bash
node --input-type=module -e "
const settings = {
  pageSize: 0,
  showCompletedTasks: false
};

console.log({
  pageSize: settings.pageSize ?? 25,
  showCompletedTasks: settings.showCompletedTasks ?? true,
  missingTheme: settings.preferences?.theme ?? 'system'
});
"
```

Expected output:

```text
{
  pageSize: 0,
  showCompletedTasks: false,
  missingTheme: 'system'
}
```

---

# C.7: Choose Objects, Maps, Sets, and Arrays Intentionally

## The Target

Use the collection type that best represents the rules of your data.

## The Concept

Choosing a data structure is like choosing storage:

- Use an **array** for ordered sequences.
- Use an **object** for a known record with named fields.
- Use a **Set** for unique values.
- Use a **Map** for key-value relationships, especially dynamic or non-string keys.
- Use a **WeakMap** for object-specific metadata that should not extend object lifetime.

## The Implementation

### Use an object for known record fields

```js
const user = {
  id: 'user_1001',
  displayName: 'Ava Patel',
  role: 'editor'
};
```

### Use an array for ordered tasks

```js
const tasks = [
  {
    id: 'task_1',
    title: 'Review code'
  },
  {
    id: 'task_2',
    title: 'Publish release'
  }
];
```

### Use a Set for unique tags

```js
const uniqueTags = new Set([
  'javascript',
  'documentation',
  'javascript'
]);

const tags = [...uniqueTags];
```

### Use a Map for counts by dynamic key

```js
const taskCountByOwner = new Map();

taskCountByOwner.set('user_1001', 2);
taskCountByOwner.set('user_1002', 1);
```

### Do not use plain objects as unsafe dictionaries for external keys

If keys come from untrusted external input, `Map` avoids special-property concerns such as `__proto__`.

```js
const valuesByExternalKey = new Map();

valuesByExternalKey.set('__proto__', 'safe Map value');
valuesByExternalKey.set('constructor', 'another safe Map value');

console.log(valuesByExternalKey.get('__proto__'));
```

## The Verification

```bash
node --input-type=module -e "
const tags = [...new Set(['javascript', 'es2024', 'javascript'])];
const countByOwner = new Map([
  ['user_1001', 2],
  ['user_1002', 1]
]);

console.log({
  tags,
  countByOwner: Object.fromEntries(countByOwner)
});
"
```

Expected output:

```text
{
  tags: [ 'javascript', 'es2024' ],
  countByOwner: { user_1001: 2, user_1002: 1 }
}
```

---

# C.8: Handle Errors with Context

## The Target

Throw errors only when a function cannot fulfill its contract, and include useful context in the message.

## The Concept

An error message should help the next developer answer:

- What failed?
- Why did it fail?
- Which value or operation caused it?
- Where should they investigate?

“Error occurred” is not useful. “Task `task_42` does not exist” is useful.

## The Implementation

### Throw meaningful errors

```js
/**
 * Returns a task with a required ID.
 *
 * @param {{ id: string }[]} tasks - Tasks to search.
 * @param {string} taskId - Required task ID.
 * @returns {{ id: string }} Matching task.
 * @throws {RangeError} When the task does not exist.
 */
function getTaskById(tasks, taskId) {
  const task = tasks.find((candidateTask) => candidateTask.id === taskId);

  if (!task) {
    throw new RangeError(`Task "${taskId}" does not exist.`);
  }

  return task;
}
```

### Catch errors only where recovery is possible

```js
try {
  const task = getTaskById([], 'task_404');

  console.log(task);
} catch (error) {
  console.error(`Unable to open task: ${error.message}`);
}
```

### Do not silently ignore errors

```js
// Avoid:
try {
  performImportantOperation();
} catch {
  // The application now hides an important failure.
}
```

### Preserve context when wrapping an error

```js
/**
 * Saves a project after validating its required fields.
 *
 * @param {{ id: string, name: string }} project - Project to save.
 * @returns {Promise<{ id: string, name: string }>} Saved project.
 */
async function saveProject(project) {
  try {
    if (project.name.trim().length === 0) {
      throw new RangeError('Project name must not be blank.');
    }

    return project;
  } catch (error) {
    throw new Error(
      `Could not save project "${project.id}": ${error.message}`,
      {
        cause: error
      }
    );
  }
}
```

## The Verification

```bash
node --input-type=module -e "
function getTaskById(tasks, taskId) {
  const task = tasks.find((candidateTask) => candidateTask.id === taskId);

  if (!task) {
    throw new RangeError(\`Task \"\${taskId}\" does not exist.\`);
  }

  return task;
}

try {
  getTaskById([], 'task_404');
} catch (error) {
  console.log(error.name + ': ' + error.message);
}
"
```

Expected output:

```text
RangeError: Task "task_404" does not exist.
```

---

# C.9: Keep Modules Small and Explicit

## The Target

Use ES modules to make dependencies visible and avoid one oversized file.

## The Concept

A module is a file with a clear responsibility. Imports show what a module needs; exports show what it provides.

Think of module boundaries as labeled rooms in a workshop. A room marked “validation” should not secretly contain deployment logic, user-interface rendering, and database storage.

## The Implementation

Example module structure:

```text
src/
├── domain/
│   ├── task.js
│   └── project.js
├── services/
│   └── task-service.js
├── utilities/
│   ├── validation.js
│   └── time.js
└── index.js
```

### `src/utilities/validation.js`

```js
/**
 * Validates and normalizes a required string.
 *
 * @param {unknown} value - Candidate value.
 * @param {string} fieldName - Field name for error messages.
 * @returns {string} Normalized string.
 * @throws {TypeError} When value is not a string.
 * @throws {RangeError} When the string is blank.
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

### `src/domain/task.js`

```js
import { requireNonEmptyString } from '../utilities/validation.js';

/**
 * Creates a normalized task.
 *
 * @param {{ id: unknown, title: unknown }} input - Raw task input.
 * @returns {{ id: string, title: string, completed: boolean }} Task.
 */
export function createTask(input) {
  return {
    id: requireNonEmptyString(input.id, 'Task id'),
    title: requireNonEmptyString(input.title, 'Task title'),
    completed: false
  };
}
```

### `src/index.js`

```js
import { createTask } from './domain/task.js';

const task = createTask({
  id: 'task_1',
  title: 'Review module boundaries'
});

console.log(task);
```

## The Verification

Create the three files above in a separate temporary directory or integrate them into your project, then run:

```bash
node src/index.js
```

Expected output:

```text
{
  id: 'task_1',
  title: 'Review module boundaries',
  completed: false
}
```

---

# C.10: Write Async Code That Makes Waiting Visible

## The Target

Use `async`, `await`, and async iteration in a way that makes asynchronous boundaries obvious.

## The Concept

Asynchronous work means the result is not available immediately. Network requests, timers, file reads, streams, and database queries are common examples.

Use `await` when a later operation needs the completed result. Avoid creating promises without deciding who will await, return, or intentionally handle them.

## The Implementation

### Prefer `await` for readable sequential work

```js
/**
 * Simulates loading project data.
 *
 * @returns {Promise<{ id: string, name: string }>} Loaded project.
 */
async function fetchProject() {
  return {
    id: 'project_1',
    name: 'Modern JavaScript Toolkit'
  };
}

/**
 * Formats a project after it is loaded.
 *
 * @returns {Promise<string>} Project label.
 */
async function getProjectLabel() {
  const project = await fetchProject();

  return `${project.id}: ${project.name}`;
}
```

### Use `Promise.all()` for independent work

```js
/**
 * Simulates loading a project.
 *
 * @returns {Promise<string>} Project result.
 */
async function fetchProjectName() {
  return 'Modern JavaScript Toolkit';
}

/**
 * Simulates loading task count.
 *
 * @returns {Promise<number>} Task-count result.
 */
async function fetchTaskCount() {
  return 3;
}

const [projectName, taskCount] = await Promise.all([
  fetchProjectName(),
  fetchTaskCount()
]);

console.log(`${projectName} has ${taskCount} tasks.`);
```

### Use `for await...of` for paginated or streamed values

```js
/**
 * Produces pages of task IDs.
 *
 * @returns {AsyncGenerator<string[], void, unknown>} Task pages.
 */
async function* fetchTaskIdPages() {
  yield ['task_1', 'task_2'];
  yield ['task_3'];
}

for await (const taskIdPage of fetchTaskIdPages()) {
  console.log(taskIdPage);
}
```

## The Verification

```bash
node --input-type=module -e "
async function fetchProjectName() {
  return 'Modern JavaScript Toolkit';
}

async function fetchTaskCount() {
  return 3;
}

const [projectName, taskCount] = await Promise.all([
  fetchProjectName(),
  fetchTaskCount()
]);

console.log(\`\${projectName} has \${taskCount} tasks.\`);
"
```

Expected output:

```text
Modern JavaScript Toolkit has 3 tasks.
```

---

# C.11: Comment Decisions, Not Obvious Syntax

## The Target

Write comments that explain *why* a decision exists, not comments that merely repeat code.

## The Concept

Good code should explain most of the “what” through clear names and structure.

Comments are valuable when they explain:

- Why a fallback is necessary
- Why a special security or compatibility decision exists
- Why a non-obvious algorithm is correct
- Why a mutation is safe
- Why a workaround can eventually be removed

## The Implementation

### Avoid comments that repeat obvious code

```js
// Increment count by one.
count += 1;
```

### Prefer comments that explain a decision

```js
// Preserve zero because a caller may intentionally request no retries.
const retryCount = configuration.retryCount ?? 3;
```

### Document public function contracts

```js
/**
 * Returns a new array instead of mutating the caller's task collection.
 *
 * @param {{ id: string, completed: boolean }[]} tasks - Existing tasks.
 * @param {string} taskId - Task to complete.
 * @returns {{ id: string, completed: boolean }[]} Revised tasks.
 */
function completeTask(tasks, taskId) {
  const taskIndex = tasks.findIndex((task) => task.id === taskId);

  if (taskIndex === -1) {
    return tasks;
  }

  return tasks.with(taskIndex, {
    ...tasks.at(taskIndex),
    completed: true
  });
}
```

## The Verification

Review comments in the style guide example:

```bash
grep -n '/\*\|//' src/appendices/appendix-c-style-guide.js
```

For each comment or JSDoc block, ask:

1. Does it explain a contract or decision?
2. Would a clear function or variable name make the comment unnecessary?
3. Is the comment still accurate after the latest code change?

---

# C.12: Use Automated Formatting and Linting

## The Target

Set up tools that consistently format code and identify common mistakes before review or deployment.

## The Concept

A formatter removes debates about spaces, line wrapping, and punctuation. A linter checks for suspicious patterns, such as unused variables or accidental reassignment.

Think of them as automatic spell-check and grammar-check for code.

A formatter does not prove the code is correct. A linter does not replace tests. But both reduce avoidable mistakes.

## The Implementation

Install ESLint and Prettier:

```bash
npm install --save-dev eslint @eslint/js globals prettier
```

Create the ESLint configuration.

### `eslint.config.js`

```js
import js from '@eslint/js';
import globals from 'globals';

export default [
  {
    ignores: [
      'dist/',
      'node_modules/'
    ]
  },
  js.configs.recommended,
  {
    files: [
      '**/*.js'
    ],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.node
      }
    },
    rules: {
      'no-console': 'off',
      'no-var': 'error',
      'prefer-const': 'error',
      'object-shorthand': [
        'error',
        'always'
      ],
      'prefer-template': 'error',
      'prefer-arrow-callback': [
        'error',
        {
          allowNamedFunctions: true
        }
      ]
    }
  }
];
```

Create the Prettier configuration.

### `.prettierrc.json`

```json
{
  "singleQuote": true,
  "semi": true,
  "trailingComma": "none",
  "printWidth": 80,
  "arrowParens": "always"
}
```

Create a Prettier ignore file.

### `.prettierignore`

```text
dist/
node_modules/
package-lock.json
```

Add these scripts to your existing `package.json` `"scripts"` object:

```json
"lint": "eslint .",
"format:check": "prettier --check .",
"format": "prettier --write ."
```

### The Verification

Check source files:

```bash
npm run lint
npm run format:check
```

If Prettier reports formatting differences, apply formatting:

```bash
npm run format
```

Then rerun:

```bash
npm run lint
npm run format:check
```

Expected result:

```text
Checking formatting...
All matched files use Prettier code style!
```

---

# Appendix C Quick Reference

## Default rules

```js
// Use const unless reassignment is necessary.
const projectId = 'project_1';

let currentPage = 1;
currentPage += 1;

// Use descriptive names.
const timeoutMilliseconds = 5_000;
const isAuthenticated = true;

// Prefer immutable updates for shared state.
const revisedTask = {
  ...task,
  completed: true
};

// Preserve 0, false, and '' with ??.
const pageSize = settings.pageSize ?? 25;

// Use optional chaining for genuinely optional paths.
const city = user?.address?.city;

// Use modern immutable array methods.
const sortedTasks = tasks.toSorted(compareTasks);
const revisedTasks = tasks.with(index, revisedTask);
```

## Collection selection

| Data shape or requirement | Preferred collection |
|---|---|
| Ordered list | `Array` |
| Named record with known fields | Plain object |
| Unique values | `Set` |
| Key-value relationship | `Map` |
| Object metadata that should not extend object lifetime | `WeakMap` |
| Temporary object-membership tracking | `WeakSet` |

## Code review questions

Before approving a JavaScript change, ask:

1. Is `const` used by default?
2. Are names clear enough without extra explanation?
3. Does the function do one understandable job?
4. Is an input from outside the module validated?
5. Could a mutation affect a caller or another subsystem?
6. Is `??` more correct than `||` for this default?
7. Is the collection type appropriate?
8. Do errors include useful context?
9. Is asynchronous work awaited, returned, or intentionally handled?
10. Do comments explain decisions rather than restate syntax?
11. Do linting, formatting, and tests pass?
