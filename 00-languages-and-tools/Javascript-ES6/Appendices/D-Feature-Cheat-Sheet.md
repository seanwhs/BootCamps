# Appendix D: Modern JavaScript Feature Cheat Sheet

This appendix is a compact reference for the features used throughout the series. Use it when you remember that a modern feature exists but need a quick reminder of its syntax, behavior, and best use case.

It is organized by practical task rather than ECMAScript version.

---

## D.1: Add a Runnable Cheat Sheet Demo

### The Target

Create one runnable file that demonstrates the most important modern JavaScript features in one place.

### The Concept

A cheat sheet is like a mechanic’s wall chart: it does not replace learning how an engine works, but it helps you quickly find the right tool while working.

The main tutorial explained each feature in depth. This appendix is your short-form lookup guide.

### The Implementation

Create this file.

### `src/appendices/appendix-d-cheat-sheet.js`

```js
/**
 * Appendix D: Modern JavaScript feature cheat sheet.
 *
 * Run with:
 * node src/appendices/appendix-d-cheat-sheet.js
 */

/**
 * Prints a visible section heading.
 *
 * @param {string} title - Heading to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

printSection('Variables');

const applicationName = 'Modern JavaScript Toolkit';
let completedLessonCount = 0;

completedLessonCount += 1;

console.log({
  applicationName,
  completedLessonCount
});

printSection('Destructuring');

const user = {
  id: 'user_1001',
  displayName: 'Ava Patel',
  preferences: {
    colorScheme: 'dark'
  }
};

const {
  id: userId,
  displayName,
  preferences: {
    colorScheme
  }
} = user;

const taskTitles = [
  'Learn destructuring',
  'Learn spread syntax',
  'Learn collections'
];

const [firstTaskTitle, , thirdTaskTitle] = taskTitles;

console.log({
  userId,
  displayName,
  colorScheme,
  firstTaskTitle,
  thirdTaskTitle
});

printSection('Rest and spread');

const [firstTag, ...remainingTags] = [
  'javascript',
  'es2024',
  'learning'
];

const baseSettings = {
  colorScheme: 'light',
  compactMode: false
};

const revisedSettings = {
  ...baseSettings,
  colorScheme: 'dark'
};

console.log({
  firstTag,
  remainingTags,
  baseSettings,
  revisedSettings
});

printSection('Arrow functions and template literals');

const formatTaskLabel = ({ id, title, completed }) => {
  const status = completed ? 'completed' : 'pending';

  return `[${id}] ${title} (${status})`;
};

console.log(
  formatTaskLabel({
    id: 'task_1',
    title: 'Write cheat sheet',
    completed: false
  })
);

printSection('Set and Map');

const uniqueTags = new Set([
  'javascript',
  'collections',
  'javascript'
]);

const taskCountByOwner = new Map([
  ['user_1001', 2],
  ['user_1002', 1]
]);

console.log({
  tags: [...uniqueTags],
  avaTaskCount: taskCountByOwner.get('user_1001'),
  taskCountByOwner: Object.fromEntries(taskCountByOwner)
});

printSection('Optional chaining and nullish coalescing');

const incompleteProject = {
  settings: {
    pageSize: 0
  }
};

const projectTheme =
  incompleteProject.settings?.colorScheme ?? 'system';

const projectPageSize =
  incompleteProject.settings?.pageSize ?? 25;

console.log({
  projectTheme,
  projectPageSize
});

printSection('Immutable array methods');

const priorities = [3, 1, 2];
const sortedPriorities = priorities.toSorted(
  (firstPriority, secondPriority) => firstPriority - secondPriority
);

const revisedPriorities = priorities.with(0, 4);
const prioritiesWithoutMiddleValue = priorities.toSpliced(1, 1);

console.log({
  priorities,
  sortedPriorities,
  revisedPriorities,
  prioritiesWithoutMiddleValue,
  finalPriority: priorities.at(-1)
});

printSection('structuredClone');

const originalProject = {
  name: 'Modern JavaScript Toolkit',
  metadata: {
    priority: 'high'
  }
};

const projectDraft = structuredClone(originalProject);

projectDraft.metadata.priority = 'low';

console.log({
  originalProject,
  projectDraft,
  nestedObjectsAreIndependent:
    originalProject.metadata !== projectDraft.metadata
});

console.log('\nAppendix D cheat sheet examples completed successfully.');
```

Add this script to the `"scripts"` object in your existing `package.json`:

```json
"appendix:d:cheat-sheet": "node src/appendices/appendix-d-cheat-sheet.js"
```

### The Verification

Run:

```bash
npm run appendix:d:cheat-sheet
```

Expected output includes:

```text
--- Optional chaining and nullish coalescing ---
{
  projectTheme: 'system',
  projectPageSize: 0
}

--- Immutable array methods ---
{
  priorities: [ 3, 1, 2 ],
  sortedPriorities: [ 1, 2, 3 ],
  revisedPriorities: [ 4, 1, 2 ],
  prioritiesWithoutMiddleValue: [ 3, 2 ],
  finalPriority: 2
}

Appendix D cheat sheet examples completed successfully.
```

---

# D.2: Variables and Scope

## The Target

Quickly choose between `const` and `let`.

## The Concept

Use `const` by default. Use `let` only when reassignment is required. Avoid `var` in modern code.

## The Implementation

```js
// Preferred: binding will not be reassigned.
const projectId = 'project_3001';

// Use let only when the binding must change.
let currentPage = 1;

currentPage += 1;

// Avoid in modern code.
// var legacyValue = 'legacy';
```

### `const` does not freeze an object

```js
const user = {
  name: 'Ava'
};

user.name = 'Mina'; // Allowed.

// user = {}; // TypeError: reassignment is not allowed.
```

### Block scope

```js
if (true) {
  const message = 'Available inside this block.';

  console.log(message);
}

// console.log(message); // ReferenceError.
```

## The Verification

```bash
node --input-type=module -e "
const projectId = 'project_3001';
let page = 1;
page += 1;
console.log({ projectId, page });
"
```

Expected output:

```text
{ projectId: 'project_3001', page: 2 }
```

---

# D.3: Destructuring

## The Target

Extract values from arrays and objects with less repetitive code.

## The Concept

Array destructuring uses position. Object destructuring uses property names.

## The Implementation

### Array destructuring

```js
const stages = ['validate', 'build', 'test', 'deploy'];

const [firstStage, secondStage] = stages;

console.log({
  firstStage,
  secondStage
});
```

### Skip values

```js
const rgbColor = [34, 139, 34];

const [red, , blue] = rgbColor;

console.log({
  red,
  blue
});
```

### Default values

```js
const coordinates = [48.8566];

const [latitude, longitude = 0] = coordinates;
```

### Object destructuring

```js
const user = {
  id: 'user_1001',
  displayName: 'Ava Patel',
  role: 'editor'
};

const {
  displayName,
  role
} = user;
```

### Rename a property during extraction

```js
const apiResponse = {
  request_id: 'req_1001'
};

const {
  request_id: requestId
} = apiResponse;
```

### Nested extraction with a safe parent fallback

```js
const order = {
  id: 'order_7001'
};

const {
  shippingAddress: {
    city = 'Not provided'
  } = {}
} = order;
```

### Destructure function parameters

```js
/**
 * Creates a greeting.
 *
 * @param {{ displayName: string, role?: string }} user - User data.
 * @returns {string} Greeting.
 */
function createGreeting({
  displayName,
  role = 'member'
}) {
  return `Welcome, ${displayName}. Your role is ${role}.`;
}
```

## The Verification

```bash
node --input-type=module -e "
const user = {
  id: 'user_1001',
  profile: {
    displayName: 'Ava Patel'
  }
};

const {
  id,
  profile: {
    displayName
  }
} = user;

console.log({ id, displayName });
"
```

Expected output:

```text
{ id: 'user_1001', displayName: 'Ava Patel' }
```

---

# D.4: Rest and Spread Syntax

## The Target

Know when `...` gathers values and when it expands them.

## The Concept

- **Rest** gathers remaining values into an array or object.
- **Spread** expands values from an array, iterable, or object.

## The Implementation

### Rest in arrays

```js
const tags = ['javascript', 'es2024', 'learning'];

const [firstTag, ...remainingTags] = tags;

console.log({
  firstTag,
  remainingTags
});
```

### Rest in objects

```js
const user = {
  id: 'user_1001',
  displayName: 'Ava Patel',
  passwordHash: 'sensitive-value'
};

const {
  passwordHash,
  ...publicUser
} = user;

console.log(publicUser);
```

### Rest parameters

```js
/**
 * Adds any number of values.
 *
 * @param {...number} values - Values to add.
 * @returns {number} Total.
 */
function sum(...values) {
  return values.reduce(
    (total, value) => total + value,
    0
  );
}

console.log(sum(10, 20, 30));
```

### Spread arrays

```js
const defaultPermissions = ['read'];

const editorPermissions = [
  ...defaultPermissions,
  'write'
];
```

### Spread objects

```js
const originalSettings = {
  colorScheme: 'light',
  compactMode: false
};

const revisedSettings = {
  ...originalSettings,
  colorScheme: 'dark'
};
```

### Spread function arguments

```js
const responseTimes = [240, 125, 310];

const fastestResponse = Math.min(...responseTimes);
```

### Important: spread is shallow

```js
const original = {
  metadata: {
    priority: 'high'
  }
};

const copied = {
  ...original
};

copied.metadata.priority = 'urgent';

console.log(original.metadata.priority);
// 'urgent'
```

## The Verification

```bash
node --input-type=module -e "
const original = ['read'];
const revised = [...original, 'write'];
console.log({
  original,
  revised,
  arraysAreDifferent: original !== revised
});
"
```

Expected output:

```text
{
  original: [ 'read' ],
  revised: [ 'read', 'write' ],
  arraysAreDifferent: true
}
```

---

# D.5: Arrow Functions and `this`

## The Target

Choose the correct arrow function form and avoid incorrect `this` behavior.

## The Concept

Arrow functions are concise and work especially well for transformations and callbacks. They do not create their own `this`.

## The Implementation

### Implicit return

```js
const square = (value) => value ** 2;
```

### Block body and explicit return

```js
const calculateTotal = (price, quantity) => {
  const subtotal = price * quantity;
  const tax = subtotal * 0.2;

  return subtotal + tax;
};
```

### Returning an object implicitly

```js
const createTask = (title) => ({
  id: crypto.randomUUID(),
  title,
  completed: false
});
```

### Array callback

```js
const tasks = [
  {
    title: 'Write examples',
    completed: true
  },
  {
    title: 'Review examples',
    completed: false
  }
];

const completedTaskTitles = tasks
  .filter((task) => task.completed)
  .map((task) => task.title);
```

### Correct method syntax when `this` is needed

```js
const project = {
  name: 'Modern JavaScript Toolkit',

  getLabel() {
    return `Project: ${this.name}`;
  }
};
```

### Avoid arrow methods that need `this`

```js
const incorrectProject = {
  name: 'Modern JavaScript Toolkit',

  getLabel: () => `Project: ${this?.name ?? 'unknown'}`
};
```

### Arrow callback preserving class `this`

```js
class Counter {
  constructor() {
    this.value = 0;
  }

  incrementLater() {
    setTimeout(() => {
      this.value += 1;
    }, 100);
  }
}
```

## The Verification

```bash
node --input-type=module -e "
const createLabel = (name, count) => \`\${name}: \${count} task(s)\`;
console.log(createLabel('Ava Patel', 3));
"
```

Expected output:

```text
Ava Patel: 3 task(s)
```

---

# D.6: Template Literals

## The Target

Build readable dynamic and multiline strings.

## The Concept

Template literals use backticks and interpolate values with `${...}`.

## The Implementation

### Interpolation

```js
const displayName = 'Ava Patel';
const taskCount = 3;

const message =
  `Welcome, ${displayName}. You have ${taskCount} tasks.`;
```

### Expressions

```js
const priceCents = 4_999;
const formattedPrice = `$${(priceCents / 100).toFixed(2)}`;
```

### Multiline strings

```js
const releaseNotes = `
Release 2.4.0

Highlights:
- Added immutable array examples.
- Added compatibility documentation.
`.trim();
```

### Conditional text

```js
const isVerified = true;

const accountStatus = `Account status: ${
  isVerified ? 'Verified' : 'Verification required'
}.`;
```

### Tagged templates

```js
/**
 * Formats diagnostic messages.
 *
 * @param {TemplateStringsArray} strings - Static segments.
 * @param {...unknown} values - Interpolated values.
 * @returns {string} Diagnostic message.
 */
function diagnostic(strings, ...values) {
  return strings.reduce((message, segment, index) => {
    const value = index < values.length
      ? JSON.stringify(values[index])
      : '';

    return `${message}${segment}${value}`;
  }, '[diagnostic] ');
}

const taskId = 'task_1';

console.log(diagnostic`Processing task ${taskId}.`);
```

## The Verification

```bash
node --input-type=module -e "
const user = 'Ava Patel';
const count = 2;
console.log(\`Welcome, \${user}. You have \${count} tasks.\`);
"
```

Expected output:

```text
Welcome, Ava Patel. You have 2 tasks.
```

---

# D.7: Enhanced Object Literals

## The Target

Create clear objects with shorthand fields, computed names, and concise methods.

## The Concept

Modern object literal syntax removes repeated text and makes dynamic keys explicit.

## The Implementation

### Shorthand properties

```js
const id = 'user_1001';
const displayName = 'Ava Patel';

const user = {
  id,
  displayName
};
```

### Computed property names

```js
const preferenceKey = 'colorScheme';

const preferences = {
  [preferenceKey]: 'dark'
};
```

### Concise methods

```js
const task = {
  id: 'task_1',
  completed: false,

  complete() {
    this.completed = true;
  }
};
```

### Computed method names

```js
const actionName = 'archive';

const documentRecord = {
  isArchived: false,

  [actionName]() {
    this.isArchived = true;
  }
};
```

## The Verification

```bash
node --input-type=module -e "
const key = 'theme';
const value = 'dark';

const settings = {
  [key]: value,
  getSummary() {
    return \`Theme: \${this.theme}\`;
  }
};

console.log(settings.getSummary());
"
```

Expected output:

```text
Theme: dark
```

---

# D.8: `Set`, `Map`, `WeakSet`, and `WeakMap`

## The Target

Choose the correct collection type quickly.

## The Concept

Different collections solve different storage problems.

## The Implementation

| Requirement | Use |
|---|---|
| Ordered values; duplicates allowed | `Array` |
| Known named fields | Plain object |
| Unique values | `Set` |
| Key-value pairs with any key type | `Map` |
| Temporary object membership | `WeakSet` |
| Metadata linked to object lifetime | `WeakMap` |

### `Set`

```js
const uniqueTags = new Set([
  'javascript',
  'learning',
  'javascript'
]);

uniqueTags.add('es2024');

console.log([...uniqueTags]);
console.log(uniqueTags.has('learning'));
```

### `Map`

```js
const taskCountByOwner = new Map();

taskCountByOwner.set('user_1001', 2);
taskCountByOwner.set('user_1002', 1);

console.log(taskCountByOwner.get('user_1001'));
console.log(Object.fromEntries(taskCountByOwner));
```

### Object key in a Map

```js
const user = {
  id: 'user_1001'
};

const sessionByUser = new Map();

sessionByUser.set(user, {
  sessionId: 'session_abc'
});

console.log(sessionByUser.get(user));
```

### `WeakSet`

```js
const validatedRequests = new WeakSet();

const request = {
  id: 'request_1001'
};

validatedRequests.add(request);

console.log(validatedRequests.has(request));
```

### `WeakMap`

```js
const metadataByRequest = new WeakMap();

const request = {
  id: 'request_1001'
};

metadataByRequest.set(request, {
  validated: true
});

console.log(metadataByRequest.get(request));
```

### Weak collection limitations

```js
const metadataByObject = new WeakMap();

// metadataByObject.size; // undefined
// [...metadataByObject]; // TypeError
```

## The Verification

```bash
node --input-type=module -e "
const values = new Set(['a', 'b', 'a']);
const counts = new Map([['user_1001', 2]]);

console.log({
  values: [...values],
  count: counts.get('user_1001')
});
"
```

Expected output:

```text
{ values: [ 'a', 'b' ], count: 2 }
```

---

# D.9: Iterators, Generators, and Async Generators

## The Target

Process values one at a time, including values that arrive asynchronously.

## The Concept

- An **iterable** works with `for...of`.
- A **generator** produces values lazily with `yield`.
- An **async generator** produces values over time and works with `for await...of`.

## The Implementation

### Basic `for...of`

```js
const taskIds = ['task_1', 'task_2'];

for (const taskId of taskIds) {
  console.log(taskId);
}
```

### Generator

```js
/**
 * Produces deployment stages one at a time.
 *
 * @returns {Generator<string, void, unknown>} Deployment-stage generator.
 */
function* generateDeploymentStages() {
  yield 'validate';
  yield 'build';
  yield 'test';
  yield 'deploy';
}

for (const stage of generateDeploymentStages()) {
  console.log(stage);
}
```

### Infinite generator controlled by the consumer

```js
/**
 * Produces sequential IDs.
 *
 * @param {number} startAt - Initial value.
 * @returns {Generator<number, void, unknown>} ID generator.
 */
function* generateIds(startAt = 1) {
  let currentId = startAt;

  while (true) {
    yield currentId;
    currentId += 1;
  }
}

const ids = generateIds(100);

console.log(ids.next().value);
console.log(ids.next().value);
```

### Async generator

```js
/**
 * Produces task pages over time.
 *
 * @returns {AsyncGenerator<string[], void, unknown>} Task pages.
 */
async function* fetchTaskPages() {
  yield ['task_1', 'task_2'];
  yield ['task_3'];
}

for await (const taskPage of fetchTaskPages()) {
  console.log(taskPage);
}
```

## The Verification

```bash
node --input-type=module -e "
function* generateNumbers() {
  yield 1;
  yield 2;
  yield 3;
}

console.log([...generateNumbers()]);
"
```

Expected output:

```text
[ 1, 2, 3 ]
```

---

# D.10: Optional Chaining, Nullish Coalescing, and Logical Assignment

## The Target

Safely access optional data and set defaults without overwriting valid falsy values.

## The Concept

| Operator | Meaning |
|---|---|
| `?.` | Safely continue only if the preceding value is not `null` or `undefined` |
| `??` | Use fallback only for `null` or `undefined` |
| `||` | Use fallback for any falsy value |
| `??=` | Assign only if current value is `null` or `undefined` |
| `||=` | Assign only if current value is falsy |
| `&&=` | Assign only if current value is truthy |

## The Implementation

### Optional property access

```js
const city = user?.address?.city;
```

### Optional array access

```js
const firstTask = tasks?.[0];
```

### Optional method call

```js
logger?.info?.('Application started.');
```

### Nullish fallback

```js
const colorScheme = settings.colorScheme ?? 'system';
```

### Preserve meaningful falsy values

```js
const settings = {
  pageSize: 0,
  showCompletedTasks: false,
  displayName: ''
};

const pageSize = settings.pageSize ?? 25;
const showCompletedTasks = settings.showCompletedTasks ?? true;
const displayName = settings.displayName ?? 'Anonymous';
```

### Logical assignment

```js
const configuration = {
  colorScheme: null,
  pageSize: 0,
  enabled: false
};

configuration.colorScheme ??= 'system';
configuration.pageSize ??= 25;
configuration.enabled ??= true;
```

### `||=` example

```js
let endpoint = '';

endpoint ||= 'https://api.example.test';
```

### `&&=` example

```js
let status = 'running';

status &&= status.toUpperCase();
```

## The Verification

```bash
node --input-type=module -e "
const settings = {
  pageSize: 0,
  enabled: false,
  theme: null
};

settings.pageSize ??= 25;
settings.enabled ??= true;
settings.theme ??= 'system';

console.log(settings);
"
```

Expected output:

```text
{
  pageSize: 0,
  enabled: false,
  theme: 'system'
}
```

---

# D.11: `structuredClone()`

## The Target

Create independent copies of compatible nested data.

## The Concept

Spread syntax copies one level. `structuredClone()` copies supported nested data structures into a separate graph.

## The Implementation

### Shallow copy with spread

```js
const original = {
  metadata: {
    priority: 'high'
  }
};

const shallowCopy = {
  ...original
};

console.log(
  original.metadata === shallowCopy.metadata
);
// true
```

### Deep copy with `structuredClone()`

```js
const original = {
  metadata: {
    priority: 'high'
  }
};

const deepCopy = structuredClone(original);

console.log(
  original.metadata === deepCopy.metadata
);
// false
```

### Use targeted immutable updates for known changes

```js
const revisedProject = {
  ...project,
  metadata: {
    ...project.metadata,
    priority: 'urgent'
  }
};
```

### Supported examples

```js
const state = {
  createdAt: new Date(),
  roles: new Set(['reader']),
  taskStatusById: new Map([
    ['task_1', 'completed']
  ])
};

const copiedState = structuredClone(state);
```

### Unsupported examples

```js
const containsFunction = {
  transform() {
    return 'Cannot be cloned.';
  }
};

// structuredClone(containsFunction); // DataCloneError.
```

## The Verification

```bash
node --input-type=module -e "
const original = {
  metadata: {
    status: 'active'
  }
};

const copied = structuredClone(original);

copied.metadata.status = 'archived';

console.log({
  original,
  copied,
  nestedObjectsAreDifferent:
    original.metadata !== copied.metadata
});
"
```

Expected output:

```text
{
  original: { metadata: { status: 'active' } },
  copied: { metadata: { status: 'archived' } },
  nestedObjectsAreDifferent: true
}
```

---

# D.12: Modern Immutable Array Methods

## The Target

Transform arrays without changing the original.

## The Concept

| Need | Modern method | Older mutating alternative |
|---|---|---|
| Read from the end | `.at(-1)` | `array[array.length - 1]` |
| Sort copy | `.toSorted()` | `.sort()` |
| Insert/remove/replace copy | `.toSpliced()` | `.splice()` |
| Replace one index in a copy | `.with()` | `array[index] = value` |

## The Implementation

### `.at()`

```js
const stages = ['validate', 'build', 'test', 'deploy'];

const firstStage = stages.at(0);
const finalStage = stages.at(-1);
```

### `.toSorted()`

```js
const responseTimes = [250, 18, 100, 4];

const sortedResponseTimes = responseTimes.toSorted(
  (firstTime, secondTime) => firstTime - secondTime
);
```

### `.toSpliced()`

```js
const taskIds = ['task_1', 'task_2', 'task_3'];

const withoutSecondTask = taskIds.toSpliced(1, 1);

const withInsertedTask = taskIds.toSpliced(
  1,
  0,
  'task_1_5'
);
```

### `.with()`

```js
const statuses = ['pending', 'pending', 'completed'];

const revisedStatuses = statuses.with(1, 'in_progress');
```

### Update one object in an array

```js
const tasks = [
  {
    id: 'task_1',
    completed: false
  },
  {
    id: 'task_2',
    completed: false
  }
];

const taskIndex = tasks.findIndex(
  (task) => task.id === 'task_2'
);

const revisedTasks = tasks.with(taskIndex, {
  ...tasks.at(taskIndex),
  completed: true
});
```

## The Verification

```bash
node --input-type=module -e "
const values = [3, 1, 2];

console.log({
  values,
  last: values.at(-1),
  sorted: values.toSorted((a, b) => a - b),
  replaced: values.with(0, 4),
  removedMiddle: values.toSpliced(1, 1)
});
"
```

Expected output:

```text
{
  values: [ 3, 1, 2 ],
  last: 2,
  sorted: [ 1, 2, 3 ],
  replaced: [ 4, 1, 2 ],
  removedMiddle: [ 3, 2 ]
}
```

---

# D.13: Quick Decision Tables

## Variable declaration

| Situation | Choose |
|---|---|
| Default choice | `const` |
| Variable binding must be reassigned | `let` |
| New modern code | Avoid `var` |

## Fallback choice

| Requirement | Choose |
|---|---|
| Fallback for `null` and `undefined` only | `??` |
| Fallback for all falsy values | `||` |
| Set default only when missing | `??=` |
| Set default when falsy | `||=` |

## Copying choice

| Requirement | Choose |
|---|---|
| Copy top-level array or object | Spread syntax |
| Update one known nested path | Targeted object/array spread |
| Independent copy of compatible nested data | `structuredClone()` |
| Update one array position | `.with()` |
| Insert/remove items without mutation | `.toSpliced()` |

## Function choice

| Requirement | Choose |
|---|---|
| Short transformation or callback | Arrow function |
| Object/class method using `this` | Method syntax or `function` |
| Produce lazy synchronous values | Generator: `function*` |
| Produce lazy asynchronous values | Async generator: `async function*` |

## Collection choice

| Requirement | Choose |
|---|---|
| Ordered sequence | `Array` |
| Named record | Plain object |
| Unique values | `Set` |
| Arbitrary key-value mapping | `Map` |
| Non-enumerable object metadata | `WeakMap` |
| Non-enumerable object membership | `WeakSet` |

---

# D.14: Complete Feature Snapshot

```js
const rawProject = {
  id: 'project_3001',
  owner: {
    displayName: 'Ava Patel'
  },
  settings: {
    pageSize: 0
  },
  tags: ['javascript', 'es2024', 'javascript'],
  tasks: [
    {
      id: 'task_1',
      title: 'Write cheat sheet',
      completed: true,
      priority: 2
    },
    {
      id: 'task_2',
      title: 'Review cheat sheet',
      completed: false,
      priority: 1
    }
  ]
};

const {
  id: projectId,
  owner: {
    displayName: ownerName
  },
  settings,
  tags = [],
  tasks = []
} = rawProject;

const pageSize = settings?.pageSize ?? 25;

const uniqueTags = [...new Set(tags)];

const sortedTasks = tasks.toSorted(
  (firstTask, secondTask) => firstTask.priority - secondTask.priority
);

const completedTaskCount = tasks.filter(
  (task) => task.completed
).length;

const projectSummary = {
  projectId,
  ownerName,
  pageSize,
  uniqueTags,
  completedTaskCount,
  latestTaskTitle: tasks.at(-1)?.title ?? 'No tasks',
  label: `${projectId} — owned by ${ownerName}`,

  getStatusMessage() {
    return `${this.label}: ${this.completedTaskCount} completed task(s).`;
  }
};

const projectDraft = structuredClone(projectSummary);

projectDraft.uniqueTags = [
  ...projectDraft.uniqueTags,
  'reference'
];

console.log(projectSummary.getStatusMessage());
console.table(sortedTasks);
console.log({
  projectSummary,
  projectDraft
});
```

## The Verification

Save the snapshot as a temporary file or run it directly:

```bash
node --input-type=module -e "
const rawProject = {
  id: 'project_3001',
  owner: {
    displayName: 'Ava Patel'
  },
  settings: {
    pageSize: 0
  },
  tags: ['javascript', 'es2024', 'javascript'],
  tasks: [
    {
      id: 'task_1',
      title: 'Write cheat sheet',
      completed: true,
      priority: 2
    },
    {
      id: 'task_2',
      title: 'Review cheat sheet',
      completed: false,
      priority: 1
    }
  ]
};

const {
  id: projectId,
  owner: {
    displayName: ownerName
  },
  settings,
  tags = [],
  tasks = []
} = rawProject;

const pageSize = settings?.pageSize ?? 25;
const uniqueTags = [...new Set(tags)];
const sortedTasks = tasks.toSorted(
  (firstTask, secondTask) => firstTask.priority - secondTask.priority
);

console.log({
  projectId,
  ownerName,
  pageSize,
  uniqueTags,
  sortedTaskIds: sortedTasks.map((task) => task.id)
});
"
```

Expected output:

```text
{
  projectId: 'project_3001',
  ownerName: 'Ava Patel',
  pageSize: 0,
  uniqueTags: [ 'javascript', 'es2024' ],
  sortedTaskIds: [ 'task_2', 'task_1' ]
}
```
