# Primer 2: Values, Types, Objects, and Arrays

Modern JavaScript features such as destructuring, spread syntax, `Set`, `Map`, optional chaining, and `structuredClone()` make more sense once you understand the data they operate on.

This primer introduces the essential building blocks:

- Primitive values
- `null` and `undefined`
- Strings, numbers, and booleans
- Objects and property access
- Arrays and indexes
- Reference values versus copied primitive values
- Basic type checking
- Safe data inspection

Think of values as the materials in a workshop:

- A string is text written on a label.
- A number is a measurable quantity.
- A boolean is a yes-or-no switch.
- An object is a labeled container with related information.
- An array is an ordered shelf of items.

---

## Step 1: Identify JavaScript Value Types

### The Target

Create a module that prints the type of common JavaScript values.

### The Concept

Every value in JavaScript has a type. A type tells JavaScript what operations make sense.

For example:

- You can combine strings into text.
- You can add numbers.
- You can use booleans in conditions.
- You can read properties from objects.
- You can access items in arrays by index.

The `typeof` operator reports the broad type of a value.

### The Implementation

Create this file.

### `src/primers/value-types.js`

```js
/**
 * Primer 2: JavaScript value types.
 *
 * Run with:
 * node src/primers/value-types.js
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
 * Creates a report for a named value.
 *
 * @param {string} name - Human-readable value name.
 * @param {unknown} value - Value to inspect.
 * @returns {{
 *   name: string,
 *   value: unknown,
 *   type: string,
 *   isArray: boolean,
 *   isNull: boolean
 * }} Value-type report.
 */
function describeValue(name, value) {
  return {
    name,
    value,
    type: typeof value,
    isArray: Array.isArray(value),
    isNull: value === null
  };
}

printSection('Primitive values');

const projectName = 'Modern JavaScript Toolkit';
const taskCount = 3;
const isComplete = false;
const unknownValue = undefined;
const intentionallyEmptyValue = null;
const largeIdentifier = 9_007_199_254_740_993n;
const uniqueMarker = Symbol('project-marker');

console.table([
  describeValue('projectName', projectName),
  describeValue('taskCount', taskCount),
  describeValue('isComplete', isComplete),
  describeValue('unknownValue', unknownValue),
  describeValue('intentionallyEmptyValue', intentionallyEmptyValue),
  describeValue('largeIdentifier', largeIdentifier),
  describeValue('uniqueMarker', uniqueMarker)
]);

printSection('Objects and arrays');

const task = {
  id: 'task_1',
  title: 'Learn JavaScript values',
  completed: false
};

const taskIds = ['task_1', 'task_2', 'task_3'];

console.table([
  describeValue('task', task),
  describeValue('taskIds', taskIds)
]);

console.log('\nValue-type examples completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/value-types.js
```

Expected output includes a table where:

- Strings report `type: 'string'`
- Numbers report `type: 'number'`
- Booleans report `type: 'boolean'`
- `undefined` reports `type: 'undefined'`
- `null` reports `type: 'object'`
- Objects report `type: 'object'`
- Arrays report `type: 'object'` and `isArray: true`

The `typeof null === 'object'` result is a long-standing JavaScript language quirk. Use this check when you specifically need to detect `null`:

```js
value === null;
```

---

## Step 2: Work with Strings, Numbers, and Booleans

### The Target

Create a module that demonstrates the three most common primitive value types.

### The Concept

Most application data begins as strings, numbers, and booleans.

| Type | Represents | Examples |
|---|---|---|
| String | Text | `'Ava Patel'`, `'task_1'` |
| Number | Numeric values | `42`, `19.99`, `-1` |
| Boolean | Yes/no state | `true`, `false` |

A value’s type matters. For example, the string `'3'` is text, while the number `3` can be used in arithmetic.

### The Implementation

Create this file.

### `src/primers/primitive-values.js`

```js
/**
 * Primer 2: Strings, numbers, and booleans.
 *
 * Run with:
 * node src/primers/primitive-values.js
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

printSection('Strings');

const firstName = 'Ava';
const lastName = 'Patel';
const fullName = `${firstName} ${lastName}`;
const normalizedName = '  Ava Patel  '.trim();

console.log({
  firstName,
  lastName,
  fullName,
  normalizedName,
  nameLength: normalizedName.length
});

printSection('Numbers');

const taskCount = 4;
const completedTaskCount = 3;
const remainingTaskCount = taskCount - completedTaskCount;

const itemPriceCents = 4_999;
const formattedPrice = `$${(itemPriceCents / 100).toFixed(2)}`;

console.log({
  taskCount,
  completedTaskCount,
  remainingTaskCount,
  itemPriceCents,
  formattedPrice
});

printSection('Numeric conversion');

/**
 * Converts a text value into a finite number.
 *
 * @param {string} value - Text that should contain a number.
 * @returns {number} Parsed number.
 * @throws {TypeError} When the value does not contain a finite number.
 */
function parseFiniteNumber(value) {
  const parsedValue = Number(value);

  if (!Number.isFinite(parsedValue)) {
    throw new TypeError(`Expected a finite number, received "${value}".`);
  }

  return parsedValue;
}

const taskCountFromText = parseFiniteNumber('12');

console.log({
  sourceValue: '12',
  sourceType: typeof '12',
  parsedValue: taskCountFromText,
  parsedType: typeof taskCountFromText
});

printSection('Booleans');

const hasWritePermission = true;
const isArchived = false;

console.log({
  hasWritePermission,
  isArchived,
  canEditProject: hasWritePermission && !isArchived
});

printSection('Comparison operators');

const expectedTaskCount = 3;
const receivedTaskCount = '3';

console.log({
  strictEquality: expectedTaskCount === receivedTaskCount,
  looseEquality: expectedTaskCount == receivedTaskCount,
  recommendedComparison: 'Use === and !== in modern JavaScript.'
});

console.log('\nPrimitive value examples completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/primitive-values.js
```

Expected output includes:

```text
--- Numeric conversion ---
{
  sourceValue: '12',
  sourceType: 'string',
  parsedValue: 12,
  parsedType: 'number'
}

--- Comparison operators ---
{
  strictEquality: false,
  looseEquality: true,
  recommendedComparison: 'Use === and !== in modern JavaScript.'
}
```

Use strict equality (`===`) and strict inequality (`!==`) by default. They compare both value and type.

---

## Step 3: Create and Read Object Records

### The Target

Create objects containing related properties and safely read their values.

### The Concept

An **object** groups related data under named properties.

Think of an object as a labeled form. Instead of storing a project’s name, ID, status, and owner separately, you store them together:

```js
const project = {
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit',
  status: 'active'
};
```

You can read properties in two common ways:

```js
project.name;
project['name'];
```

Dot notation is generally clearer when the property name is known in advance. Bracket notation is useful when the property name is stored in a variable.

### The Implementation

Create this file.

### `src/primers/objects.js`

```js
/**
 * Primer 2: Object records and property access.
 *
 * Run with:
 * node src/primers/objects.js
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

printSection('Creating an object');

const project = {
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit',
  status: 'active',
  taskCount: 4
};

console.log(project);

printSection('Reading known properties with dot notation');

console.log({
  projectId: project.id,
  projectName: project.name,
  projectStatus: project.status
});

printSection('Reading dynamic properties with bracket notation');

const propertyToRead = 'taskCount';

console.log({
  propertyToRead,
  value: project[propertyToRead]
});

printSection('Adding and updating properties');

const projectDraft = {
  ...project
};

projectDraft.status = 'review';
projectDraft.ownerName = 'Ava Patel';

console.log({
  originalProject: project,
  projectDraft,
  objectsAreDifferent: project !== projectDraft
});

printSection('Nested objects');

const projectWithOwner = {
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit',
  owner: {
    id: 'user_1001',
    displayName: 'Ava Patel',
    email: 'ava@example.com'
  }
};

console.log({
  projectName: projectWithOwner.name,
  ownerName: projectWithOwner.owner.displayName,
  ownerEmail: projectWithOwner.owner.email
});

printSection('Safe access to optional nested properties');

const incompleteProject = {
  id: 'project_3002',
  name: 'Project without an owner'
};

console.log({
  directOwnerAccessWouldFail:
    'incompleteProject.owner.displayName would throw an error.',
  safeOwnerName:
    incompleteProject.owner?.displayName ?? 'Unassigned owner'
});

console.log('\nObject examples completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/objects.js
```

Expected output includes:

```text
--- Reading dynamic properties with bracket notation ---
{ propertyToRead: 'taskCount', value: 4 }

--- Safe access to optional nested properties ---
{
  directOwnerAccessWouldFail: 'incompleteProject.owner.displayName would throw an error.',
  safeOwnerName: 'Unassigned owner'
}
```

---

## Step 4: Work with Ordered Collections Using Arrays

### The Target

Create arrays, read values by index, and use common non-mutating array operations.

### The Concept

An **array** stores ordered values.

Think of an array as a numbered shelf:

```js
const stages = ['validate', 'build', 'test'];
```

Each position has an index:

| Value | Index |
|---|---:|
| `'validate'` | `0` |
| `'build'` | `1` |
| `'test'` | `2` |

JavaScript arrays begin at index `0`, not index `1`.

### The Implementation

Create this file.

### `src/primers/arrays.js`

```js
/**
 * Primer 2: Arrays and ordered collections.
 *
 * Run with:
 * node src/primers/arrays.js
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

printSection('Creating and reading arrays');

const deploymentStages = [
  'validate',
  'build',
  'test',
  'deploy'
];

console.log({
  deploymentStages,
  stageCount: deploymentStages.length,
  firstStage: deploymentStages[0],
  finalStage: deploymentStages.at(-1),
  missingStage: deploymentStages.at(99)
});

printSection('Arrays can contain objects');

const tasks = [
  {
    id: 'task_1',
    title: 'Install Node.js',
    completed: true
  },
  {
    id: 'task_2',
    title: 'Create the project folder',
    completed: true
  },
  {
    id: 'task_3',
    title: 'Run the first module',
    completed: false
  }
];

console.table(tasks);

printSection('Reading an item from an array');

const firstTask = tasks.at(0);
const finalTask = tasks.at(-1);

console.log({
  firstTaskTitle: firstTask.title,
  finalTaskTitle: finalTask.title
});

printSection('Creating derived arrays');

const taskTitles = tasks.map((task) => task.title);

const incompleteTaskTitles = tasks
  .filter((task) => !task.completed)
  .map((task) => task.title);

console.log({
  taskTitles,
  incompleteTaskTitles
});

printSection('Non-mutating array updates');

const revisedTasks = tasks.with(2, {
  ...tasks.at(2),
  completed: true
});

console.log({
  originalFinalTask: tasks.at(-1),
  revisedFinalTask: revisedTasks.at(-1),
  sourceArrayWasPreserved: tasks !== revisedTasks,
  sourceTaskWasPreserved: tasks.at(-1) !== revisedTasks.at(-1)
});

console.log('\nArray examples completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/arrays.js
```

Expected output includes:

```text
--- Creating and reading arrays ---
{
  deploymentStages: [ 'validate', 'build', 'test', 'deploy' ],
  stageCount: 4,
  firstStage: 'validate',
  finalStage: 'deploy',
  missingStage: undefined
}
```

And later:

```text
sourceArrayWasPreserved: true
sourceTaskWasPreserved: true
```

The `.with()` method returns a new array. It does not change the source array.

---

## Step 5: Understand Primitive Values and Object References

### The Target

Observe the difference between copying primitive values and sharing object references.

### The Concept

Primitive values, such as strings and numbers, are copied as independent values:

```js
let firstCount = 1;
let secondCount = firstCount;

secondCount = 2;
```

Changing `secondCount` does not change `firstCount`.

Objects and arrays behave differently. Assigning an object to another variable copies the **reference**—an internal link to the same object.

```js
const firstProject = {
  name: 'Toolkit'
};

const secondProject = firstProject;

secondProject.name = 'Updated Toolkit';
```

Now both variables see the changed name because both point to the same object.

Think of this as two people holding the same house address. Changing the paint on the house affects what both people see. They do not each own an independent house.

### The Implementation

Create this file.

### `src/primers/references.js`

```js
/**
 * Primer 2: Primitive copies and object references.
 *
 * Run with:
 * node src/primers/references.js
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

printSection('Primitive values are copied independently');

let originalTaskCount = 3;
let copiedTaskCount = originalTaskCount;

copiedTaskCount = 4;

console.log({
  originalTaskCount,
  copiedTaskCount,
  valuesAreEqual: originalTaskCount === copiedTaskCount
});

printSection('Object assignments share the same reference');

const originalProject = {
  id: 'project_3001',
  status: 'active'
};

const referencedProject = originalProject;

referencedProject.status = 'archived';

console.log({
  originalProject,
  referencedProject,
  sameObjectReference: originalProject === referencedProject
});

printSection('Object spread creates a new outer object');

const sourceProject = {
  id: 'project_3002',
  status: 'active'
};

const copiedProject = {
  ...sourceProject
};

copiedProject.status = 'review';

console.log({
  sourceProject,
  copiedProject,
  sameObjectReference: sourceProject === copiedProject
});

printSection('Object spread is shallow');

const projectWithNestedSettings = {
  id: 'project_3003',
  settings: {
    colorScheme: 'light',
    compactMode: false
  }
};

const shallowProjectCopy = {
  ...projectWithNestedSettings
};

shallowProjectCopy.settings.colorScheme = 'dark';

console.log({
  projectWithNestedSettings,
  shallowProjectCopy,
  nestedSettingsAreSameReference:
    projectWithNestedSettings.settings === shallowProjectCopy.settings
});

printSection('structuredClone creates independent supported nested data');

const projectForDeepCopy = {
  id: 'project_3004',
  settings: {
    colorScheme: 'light',
    compactMode: false
  }
};

const deepProjectCopy = structuredClone(projectForDeepCopy);

deepProjectCopy.settings.colorScheme = 'dark';

console.log({
  projectForDeepCopy,
  deepProjectCopy,
  nestedSettingsAreSameReference:
    projectForDeepCopy.settings === deepProjectCopy.settings
});

console.log('\nReference examples completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/references.js
```

Expected output includes:

```text
--- Object assignments share the same reference ---
{
  originalProject: { id: 'project_3001', status: 'archived' },
  referencedProject: { id: 'project_3001', status: 'archived' },
  sameObjectReference: true
}
```

And:

```text
--- structuredClone creates independent supported nested data ---
{
  projectForDeepCopy: {
    id: 'project_3004',
    settings: { colorScheme: 'light', compactMode: false }
  },
  deepProjectCopy: {
    id: 'project_3004',
    settings: { colorScheme: 'dark', compactMode: false }
  },
  nestedSettingsAreSameReference: false
}
```

---

## Step 6: Build a Basic Task Record Utility

### The Target

Create a small module that uses strings, numbers, booleans, objects, arrays, and validation together.

### The Concept

This is a practical foundation module. It receives task-like input, validates it, creates an object, and summarizes a task list.

This mirrors a common application pattern:

1. Receive data.
2. Validate essential fields.
3. Normalize the data into a predictable shape.
4. Return values without mutating the original input.

### The Implementation

Create this file.

### `src/primers/task-basics.js`

```js
/**
 * Primer 2: Basic task records.
 *
 * Run with:
 * node src/primers/task-basics.js
 */

/**
 * Validates and normalizes a required text field.
 *
 * @param {unknown} value - Candidate text value.
 * @param {string} fieldName - Field name shown in an error message.
 * @returns {string} Trimmed non-empty text.
 * @throws {TypeError} When the value is not a string.
 * @throws {RangeError} When the value is blank.
 */
function requireNonEmptyString(value, fieldName) {
  if (typeof value !== 'string') {
    throw new TypeError(`${fieldName} must be a string.`);
  }

  const normalizedValue = value.trim();

  if (normalizedValue.length === 0) {
    throw new RangeError(`${fieldName} must not be blank.`);
  }

  return normalizedValue;
}

/**
 * Creates a normalized task object.
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
 */
function createTask(input) {
  const id = requireNonEmptyString(input.id, 'Task id');
  const title = requireNonEmptyString(input.title, 'Task title');

  const priority =
    typeof input.priority === 'number' &&
    Number.isInteger(input.priority)
      ? input.priority
      : 3;

  return {
    id,
    title,
    completed: input.completed === true,
    priority
  };
}

/**
 * Creates a summary of a task array.
 *
 * @param {Array<{ completed: boolean }>} tasks - Tasks to summarize.
 * @returns {{
 *   taskCount: number,
 *   completedTaskCount: number,
 *   pendingTaskCount: number
 * }} Task summary.
 */
function createTaskSummary(tasks) {
  const completedTaskCount = tasks.filter((task) => {
    return task.completed;
  }).length;

  return {
    taskCount: tasks.length,
    completedTaskCount,
    pendingTaskCount: tasks.length - completedTaskCount
  };
}

const tasks = [
  createTask({
    id: 'task_1',
    title: ' Install Node.js ',
    completed: true,
    priority: 1
  }),
  createTask({
    id: 'task_2',
    title: 'Create primer files',
    completed: true
  }),
  createTask({
    id: 'task_3',
    title: 'Practice objects and arrays',
    completed: false,
    priority: 2
  })
];

console.table(tasks);

console.log(createTaskSummary(tasks));

console.log('\nTask basics completed successfully.');
```

### The Verification

Run:

```bash
node src/primers/task-basics.js
```

Expected output includes a table with three tasks and this summary:

```text
{
  taskCount: 3,
  completedTaskCount: 2,
  pendingTaskCount: 1
}
```

Notice that the first title becomes:

```text
Install Node.js
```

The leading and trailing spaces were removed by `.trim()` during normalization.

---

## Step 7: Add Primer 2 Scripts

### The Target

Add npm scripts for every Primer 2 module.

### The Concept

Scripts give each learning module a predictable, memorable command.

### The Implementation

Add the following entries to the existing `"scripts"` object in `package.json`.

### `package.json` — scripts additions

```json
{
  "scripts": {
    "primer:2:types": "node src/primers/value-types.js",
    "primer:2:primitives": "node src/primers/primitive-values.js",
    "primer:2:objects": "node src/primers/objects.js",
    "primer:2:arrays": "node src/primers/arrays.js",
    "primer:2:references": "node src/primers/references.js",
    "primer:2:tasks": "node src/primers/task-basics.js"
  }
}
```

### The Verification

Run every Primer 2 script:

```bash
npm run primer:2:types
npm run primer:2:primitives
npm run primer:2:objects
npm run primer:2:arrays
npm run primer:2:references
npm run primer:2:tasks
```

Each command should complete successfully.

---

# Primer 2 Reference: Essential Rules

## Primitive values

Common primitives:

```js
const text = 'Hello';
const count = 42;
const enabled = true;
const absent = undefined;
const intentionallyEmpty = null;
```

Primitives are copied independently:

```js
let firstValue = 1;
let secondValue = firstValue;

secondValue = 2;

console.log(firstValue);
// 1
```

---

## Objects

Objects group named values:

```js
const user = {
  id: 'user_1001',
  displayName: 'Ava Patel'
};
```

Read a known property:

```js
user.displayName;
```

Read a dynamic property name:

```js
const key = 'displayName';

user[key];
```

---

## Arrays

Arrays store ordered values:

```js
const taskIds = ['task_1', 'task_2'];
```

Read the first and last values:

```js
taskIds.at(0);
taskIds.at(-1);
```

Get the number of items:

```js
taskIds.length;
```

---

## References

Objects and arrays are reference values:

```js
const first = {
  name: 'Ava'
};

const second = first;

second.name = 'Mina';

console.log(first.name);
// 'Mina'
```

Create a new outer object with spread:

```js
const copied = {
  ...first
};
```

Create a deep copy of compatible data:

```js
const deepCopied = structuredClone(first);
```

---

## Type checking

```js
typeof 'text'; // 'string'
typeof 42; // 'number'
typeof true; // 'boolean'
typeof undefined; // 'undefined'
typeof {}; // 'object'
typeof []; // 'object'
```

Check arrays specifically:

```js
Array.isArray([]);
```

Check `null` specifically:

```js
value === null;
```

---

# Primer 2 Completion Checklist

Run:

```bash
npm run primer:2:types
npm run primer:2:primitives
npm run primer:2:objects
npm run primer:2:arrays
npm run primer:2:references
npm run primer:2:tasks
```

Confirm that you can explain:

- The difference between a string and a number.
- Why `===` is preferred over `==`.
- Why arrays begin at index `0`.
- How to read object properties with dot and bracket notation.
- Why two variables can point to the same object.
- Why object spread is shallow.
- When `structuredClone()` produces an independent nested copy.
