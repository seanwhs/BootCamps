# ES6+ Modern JavaScript: Student Notes

## 1. Core Setup

### Node.js and npm

- **Node.js** runs JavaScript outside the browser.
- **npm** runs project scripts and installs packages.
- Check versions:

```bash
node --version
npm --version
```

- Run the project:

```bash
npm start
```

- Run a named script:

```bash
npm run part:1:variables
```

### ES Modules

Use this in `package.json`:

```json
{
  "type": "module"
}
```

Then use modern imports and exports:

```js
export function createTask(title) {
  return {
    title,
    completed: false
  };
}
```

```js
import { createTask } from './task.js';
```

Local ES module imports in Node.js should include `.js`.

---

# 2. Variables and Scope

## `const`

Use `const` by default.

```js
const projectName = 'Modern JavaScript Toolkit';
```

- Prevents reassignment of the variable binding.
- Does **not** make an object immutable.

```js
const user = {
  role: 'reader'
};

user.role = 'editor'; // Allowed.

// user = {}; // Not allowed.
```

## `let`

Use `let` only when reassignment is required.

```js
let completedTaskCount = 0;

completedTaskCount += 1;
```

## Avoid `var`

```js
// Avoid in modern code.
var legacyValue = 'old pattern';
```

`var` is function-scoped. `const` and `let` are block-scoped.

```js
if (true) {
  const status = 'active';
}

// status is unavailable here.
```

---

# 3. Values and Types

## Common Types

```js
const text = 'Ava Patel';      // string
const count = 3;               // number
const enabled = true;          // boolean
const absent = undefined;      // undefined
const intentionallyEmpty = null;
const task = {};               // object
const tasks = [];              // object, specifically an array
```

## Type Checks

```js
typeof 'text';       // 'string'
typeof 42;           // 'number'
typeof true;         // 'boolean'
typeof undefined;    // 'undefined'
typeof {};           // 'object'
typeof [];           // 'object'
typeof null;         // 'object' - historic JavaScript quirk
```

Check arrays:

```js
Array.isArray(value);
```

Check `null`:

```js
value === null;
```

## Strict Equality

Prefer:

```js
value === expectedValue;
value !== expectedValue;
```

Avoid loose equality unless you fully understand coercion:

```js
3 === '3'; // false
3 == '3';  // true
```

---

# 4. Objects and Arrays

## Objects

Objects group named values.

```js
const project = {
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit',
  status: 'active'
};
```

Read known properties:

```js
project.name;
```

Read dynamic properties:

```js
const key = 'status';

project[key];
```

## Arrays

Arrays store ordered values.

```js
const stages = [
  'validate',
  'build',
  'test',
  'deploy'
];
```

```js
stages[0];     // 'validate'
stages.at(0);  // 'validate'
stages.at(-1); // 'deploy'
stages.length; // 4
```

---

# 5. Primitive Copies and References

## Primitive Values Copy Independently

```js
let firstCount = 1;
let secondCount = firstCount;

secondCount = 2;

console.log(firstCount); // 1
```

## Objects Share References

```js
const firstProject = {
  name: 'Toolkit'
};

const secondProject = firstProject;

secondProject.name = 'Updated Toolkit';

console.log(firstProject.name);
// 'Updated Toolkit'
```

Both variables point to the same object.

---

# 6. Destructuring

## Array Destructuring

```js
const stages = ['validate', 'build', 'test'];

const [firstStage, secondStage] = stages;
```

Skip values:

```js
const rgb = [255, 165, 0];

const [red, , blue] = rgb;
```

Defaults:

```js
const coordinates = [48.8566];

const [latitude, longitude = 0] = coordinates;
```

## Object Destructuring

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

Rename properties:

```js
const {
  id: userId
} = user;
```

Nested values:

```js
const project = {
  owner: {
    displayName: 'Ava Patel'
  }
};

const {
  owner: {
    displayName: ownerName
  }
} = project;
```

Safe nested defaults:

```js
const order = {};

const {
  shippingAddress: {
    city = 'Not provided'
  } = {}
} = order;
```

---

# 7. Rest and Spread Syntax

## Rest Syntax: Gather Remaining Values

```js
const roles = ['admin', 'editor', 'reader'];

const [primaryRole, ...remainingRoles] = roles;
```

```js
const user = {
  id: 'user_1001',
  displayName: 'Ava Patel',
  passwordHash: 'private'
};

const {
  passwordHash,
  ...publicUser
} = user;
```

Rest parameters gather function arguments:

```js
function sum(...values) {
  return values.reduce(
    (total, value) => total + value,
    0
  );
}
```

## Spread Syntax: Expand Values

Copy an array:

```js
const original = ['read'];
const copied = [...original];
```

Add to an array immutably:

```js
const permissions = [
  ...original,
  'write'
];
```

Copy and update an object:

```js
const updatedUser = {
  ...user,
  role: 'editor'
};
```

## Shallow Copy Warning

Spread only copies the outer layer.

```js
const original = {
  settings: {
    theme: 'light'
  }
};

const copied = {
  ...original
};

copied.settings.theme = 'dark';

console.log(original.settings.theme);
// 'dark'
```

---

# 8. Functions

## Function Declaration

```js
function add(firstValue, secondValue) {
  return firstValue + secondValue;
}
```

- **Parameters:** `firstValue`, `secondValue`
- **Arguments:** values passed during the call

```js
add(2, 3);
```

## Functions Without `return`

```js
function printMessage(message) {
  console.log(message);
}

const result = printMessage('Hello');

console.log(result);
// undefined
```

## Guard Clauses

Validate early and exit clearly.

```js
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
```

---

# 9. Conditions and Logical Operators

## `if`, `else if`, and `else`

```js
if (priority === 1) {
  return 'critical';
} else if (priority === 2) {
  return 'high';
}

return 'normal';
```

## Logical Operators

```js
const canEdit =
  hasWritePermission &&
  !isArchived &&
  !isCompleted;
```

| Operator | Meaning |
|---|---|
| `&&` | Both sides must be truthy |
| `||` | At least one side must be truthy |
| `!` | Reverses a boolean value |

---

# 10. Iteration and Array Methods

## `for...of`

Use when processing every value.

```js
for (const task of tasks) {
  console.log(task.title);
}
```

## `.map()`

Transform every item.

```js
const titles = tasks.map((task) => task.title);
```

## `.filter()`

Keep matching items.

```js
const pendingTasks = tasks.filter(
  (task) => !task.completed
);
```

## `.find()`

Find the first match.

```js
const task = tasks.find(
  (task) => task.id === 'task_1'
);
```

Returns `undefined` if no match exists.

## `.findIndex()`

Find the index of the first match.

```js
const taskIndex = tasks.findIndex(
  (task) => task.id === 'task_1'
);
```

Returns `-1` if no match exists.

## `.reduce()`

Combine values into one result.

```js
const completedTaskCount = tasks.reduce(
  (count, task) => task.completed ? count + 1 : count,
  0
);
```

---

# 11. Arrow Functions

## Basic Arrow Function

```js
const double = (value) => {
  return value * 2;
};
```

## Implicit Return

```js
const double = (value) => value * 2;
```

## Returning an Object

Wrap an implicitly returned object in parentheses.

```js
const createTask = (title) => ({
  id: crypto.randomUUID(),
  title,
  completed: false
});
```

## Arrow Functions and `this`

Arrow functions inherit `this` from their surrounding location.

Good callback use:

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

Avoid arrows for object methods that need the receiving object as `this`:

```js
const project = {
  name: 'Toolkit',

  getLabel() {
    return `Project: ${this.name}`;
  }
};
```

---

# 12. Template Literals

Use backticks.

```js
const userName = 'Ava Patel';
const taskCount = 3;

const message =
  `Welcome, ${userName}. You have ${taskCount} tasks.`;
```

Expressions work inside `${...}`:

```js
const priceCents = 4999;

const label = `$${(priceCents / 100).toFixed(2)}`;
```

Multiline strings:

```js
const releaseNotes = `
Release 2.4.0

- Added modern array methods.
- Added compatibility checks.
`.trim();
```

---

# 13. Enhanced Object Literals

## Shorthand Properties

```js
const id = 'task_1';
const title = 'Write notes';

const task = {
  id,
  title
};
```

## Computed Property Names

```js
const settingName = 'colorScheme';

const settings = {
  [settingName]: 'dark'
};
```

## Concise Methods

```js
const task = {
  title: 'Write notes',
  completed: false,

  complete() {
    this.completed = true;
  }
};
```

---

# 14. `Set` and `Map`

## `Set`

Use for unique values.

```js
const tags = new Set([
  'javascript',
  'learning',
  'javascript'
]);

console.log([...tags]);
// ['javascript', 'learning']
```

Common APIs:

```js
tags.add('es2024');
tags.has('learning');
tags.delete('learning');
tags.size;
```

## `Map`

Use for intentional key-value relationships.

```js
const taskCountByOwner = new Map();

taskCountByOwner.set('user_1001', 2);
taskCountByOwner.set('user_1002', 1);

taskCountByOwner.get('user_1001');
```

Convert a Map to a plain object:

```js
Object.fromEntries(taskCountByOwner);
```

## Object Identity Reminder

```js
const firstTask = {
  id: 'task_1'
};

const secondTask = {
  id: 'task_1'
};

firstTask === secondTask;
// false
```

Objects are compared by reference, not by matching contents.

---

# 15. `WeakMap` and `WeakSet`

## `WeakSet`

Tracks object membership without strongly retaining objects.

```js
const validatedRequests = new WeakSet();

const request = {
  id: 'request_1001'
};

validatedRequests.add(request);
validatedRequests.has(request);
```

## `WeakMap`

Associates metadata with object keys.

```js
const metadataByRequest = new WeakMap();

metadataByRequest.set(request, {
  validated: true
});
```

## Important Limits

Weak collections:

- Require object-like values or keys.
- Cannot be enumerated.
- Do not have `.size`.
- Are useful for temporary object metadata.

Use `Map` or `Set` if you need to list, count, or serialize entries.

---

# 16. Iterators and Generators

## Iterable

An iterable can be used with `for...of`.

```js
for (const value of ['a', 'b', 'c']) {
  console.log(value);
}
```

## Iterator

An iterator has `.next()`.

```js
const iterator = ['a', 'b'][Symbol.iterator]();

iterator.next();
// { value: 'a', done: false }
```

## Generator Function

```js
function* generateStages() {
  yield 'validate';
  yield 'build';
  yield 'test';
}
```

Consume it:

```js
for (const stage of generateStages()) {
  console.log(stage);
}
```

Generators are lazy: their body starts when values are requested.

---

# 17. Async Iteration

## Async Function

An `async` function always returns a Promise.

```js
async function loadProject() {
  return {
    id: 'project_3001'
  };
}
```

Use `await`:

```js
const project = await loadProject();
```

## Async Generator

```js
async function* fetchTaskPages() {
  yield ['task_1', 'task_2'];
  yield ['task_3'];
}
```

Consume it:

```js
for await (const page of fetchTaskPages()) {
  console.log(page);
}
```

Use async iteration for:

- Paginated APIs
- Database cursors
- Streams
- Queue messages
- Incrementally arriving data

---

# 18. Optional Chaining and Nullish Coalescing

## Optional Chaining: `?.`

Safely access data that may not exist.

```js
const city = user?.address?.city;
```

Optional array access:

```js
const firstTask = tasks?.[0];
```

Optional method call:

```js
logger?.info?.('Application started.');
```

## Nullish Coalescing: `??`

Use a fallback only for `null` or `undefined`.

```js
const pageSize = settings.pageSize ?? 25;
```

This preserves valid falsy values:

```js
0 ?? 25;       // 0
false ?? true; // false
'' ?? 'Text';  // ''
```

## `??` Versus `||`

```js
0 || 25; // 25
0 ?? 25; // 0
```

Use `??` for most configuration defaults.

---

# 19. Logical Assignment

## `??=`

Assign only if missing.

```js
settings.theme ??= 'system';
```

## `||=`

Assign when the current value is falsy.

```js
let endpoint = '';

endpoint ||= 'https://api.example.test';
```

## `&&=`

Assign only when the current value is truthy.

```js
let status = 'running';

status &&= status.toUpperCase();
```

---

# 20. `structuredClone()`

Use `structuredClone()` when you need an independent copy of compatible nested data.

```js
const projectDraft = structuredClone(project);
```

Supported examples include:

- Objects
- Arrays
- Dates
- Sets
- Maps
- Typed arrays
- Circular references

Not supported:

- Functions
- Symbol values

For a known update, targeted immutable copying is often clearer:

```js
const updatedProject = {
  ...project,
  settings: {
    ...project.settings,
    theme: 'dark'
  }
};
```

---

# 21. Immutable Array Methods

## `.at()`

```js
tasks.at(0);  // First item.
tasks.at(-1); // Last item.
```

## `.toSorted()`

```js
const sortedTasks = tasks.toSorted(
  (firstTask, secondTask) => {
    return firstTask.priority - secondTask.priority;
  }
);
```

Does not mutate `tasks`.

## `.toSpliced()`

```js
const withoutSecondTask = tasks.toSpliced(1, 1);
```

Does not mutate `tasks`.

## `.with()`

```js
const updatedTasks = tasks.with(1, {
  ...tasks.at(1),
  completed: true
});
```

Does not mutate `tasks`.

---

# 22. Modules

## Named Export

```js
export function createTask(title) {
  return {
    title
  };
}
```

## Named Import

```js
import {
  createTask
} from './task.js';
```

## Relative Paths

```js
import { value } from './same-folder-file.js';
import { value } from '../parent-folder-file.js';
```

For Node.js ES modules, include the local `.js` extension.

---

# 23. Debugging Notes

## Read Errors Fully

A stack trace tells you:

- Error type
- Error message
- File
- Line number
- Function call path

Example:

```text
TypeError: Cannot read properties of undefined
    at getOwnerName (src/index.js:24:18)
```

## Good Debug Logs

```js
console.log({
  event: 'task.lookup',
  taskId,
  taskIndex,
  taskWasFound: taskIndex !== -1
});
```

## Useful Node Commands

```bash
node --check src/index.js
node --watch src/index.js
node inspect src/index.js
```

---

# 24. Compatibility Notes

- Use Node.js 22+ for this series.
- Syntax support and API support are different.
- A transpiler can rewrite syntax.
- A polyfill can provide missing APIs.
- Prefer feature detection:

```js
const supportsToSorted =
  typeof Array.prototype.toSorted === 'function';
```

- Do not rely on browser user-agent strings for important capability decisions.

---

# 25. Modern JavaScript Decision Guide

| Need | Use |
|---|---|
| Stable variable binding | `const` |
| Intentional reassignment | `let` |
| Ordered list | `Array` |
| Named record | Plain object |
| Unique values | `Set` |
| Key-value relationship | `Map` |
| Object-related temporary metadata | `WeakMap` |
| Extract selected object values | Destructuring |
| Copy or merge arrays/objects | Spread syntax |
| Remaining values | Rest syntax |
| Safe property path | Optional chaining |
| Missing-value fallback | Nullish coalescing |
| Deep compatible copy | `structuredClone()` |
| Non-mutating sorting | `.toSorted()` |
| Non-mutating item replacement | `.with()` |
| Lazy sequence | Generator |
| Async sequence | Async generator and `for await...of` |

---

# 26. Final Study Checklist

- [ ] I can explain `const` versus `let`.
- [ ] I can destructure arrays and objects.
- [ ] I can use rest and spread syntax.
- [ ] I can write arrow functions and template literals.
- [ ] I understand when arrow functions should not be object methods.
- [ ] I can choose between Array, Object, Set, and Map.
- [ ] I can explain object reference identity.
- [ ] I can create and consume a generator.
- [ ] I can use `for await...of`.
- [ ] I can safely read optional data with `?.`.
- [ ] I can choose `??` instead of `||` when needed.
- [ ] I can explain shallow copy versus deep copy.
- [ ] I can use `.at()`, `.toSorted()`, `.toSpliced()`, and `.with()`.
- [ ] I can create ES modules with `import` and `export`.
- [ ] I can read a JavaScript stack trace.
- [ ] I can run and verify Node.js scripts.
