# Appendix G: Migrating Older JavaScript to Modern JavaScript

This appendix helps you update older JavaScript patterns into clearer, safer modern alternatives.

The goal is not to rewrite every old file merely because newer syntax exists. A good migration improves readability, correctness, testability, security, or maintainability while preserving behavior.

Modernization is like renovating a house while people still live in it:

- Do not remove a wall until you know what it supports.
- Make one contained improvement at a time.
- Verify the building still works after each change.
- Prefer clear upgrades over fashionable but unnecessary changes.

This guide covers common migrations:

- `var` to `const` and `let`
- Traditional function expressions to arrow functions
- String concatenation to template literals
- Manual property access to destructuring
- Manual null checks to optional chaining and nullish coalescing
- Object-as-dictionary patterns to `Map`
- Duplicate filtering to `Set`
- Mutating array methods to immutable array methods
- JSON cloning to `structuredClone()`
- Callback-heavy asynchronous code to `async` / `await`
- CommonJS modules to ES modules

---

## G.1: Create a Migration Demonstration Module

### The Target

Create a runnable module that contains side-by-side legacy and modern implementations.

### The Concept

A migration is easier to understand when you can compare the before and after versions directly.

The legacy version is not necessarily “wrong.” It may have been the best available approach when written. The modern version aims to make the same intention more obvious and reduce common bugs.

### The Implementation

Add this script to the existing `"scripts"` object in `package.json`:

### `package.json` — scripts addition

```json
{
  "scripts": {
    "appendix:g:migration": "node src/appendices/appendix-g-migration.js"
  }
}
```

Create the following file.

### `src/appendices/appendix-g-migration.js`

```js
/**
 * Appendix G: Migrating older JavaScript patterns to modern JavaScript.
 *
 * Run with:
 * npm run appendix:g:migration
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
 * Waits for a selected duration.
 *
 * @param {number} milliseconds - Time to wait.
 * @returns {Promise<void>} A promise resolved after the delay.
 */
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

printSection('var to const and let');

var legacyProjectName = 'Modern JavaScript Toolkit';
var legacyCompletedCount = 0;

legacyCompletedCount = legacyCompletedCount + 1;

const projectName = 'Modern JavaScript Toolkit';
let completedCount = 0;

completedCount += 1;

console.log({
  legacyProjectName,
  legacyCompletedCount,
  projectName,
  completedCount
});

printSection('string concatenation to template literals');

var legacyUserName = 'Ava Patel';
var legacyTaskCount = 3;

var legacyMessage =
  'Welcome, ' +
  legacyUserName +
  '. You have ' +
  legacyTaskCount +
  ' tasks.';

const userName = 'Ava Patel';
const taskCount = 3;

const modernMessage =
  `Welcome, ${userName}. You have ${taskCount} tasks.`;

console.log({
  legacyMessage,
  modernMessage,
  messagesMatch: legacyMessage === modernMessage
});

printSection('manual property access to destructuring');

const project = {
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit',
  owner: {
    displayName: 'Ava Patel'
  }
};

const legacyProjectId = project.id;
const legacyProjectNameFromObject = project.name;
const legacyOwnerName = project.owner.displayName;

const {
  id: projectId,
  name,
  owner: {
    displayName: ownerName
  }
} = project;

console.log({
  legacyProjectId,
  legacyProjectNameFromObject,
  legacyOwnerName,
  projectId,
  name,
  ownerName
});

printSection('manual null checks to optional chaining');

const projectWithoutOwner = {
  id: 'project_3002',
  name: 'Incomplete project'
};

const legacyOwnerLabel =
  projectWithoutOwner &&
  projectWithoutOwner.owner &&
  projectWithoutOwner.owner.displayName
    ? projectWithoutOwner.owner.displayName
    : 'Unassigned owner';

const modernOwnerLabel =
  projectWithoutOwner.owner?.displayName ?? 'Unassigned owner';

console.log({
  legacyOwnerLabel,
  modernOwnerLabel,
  labelsMatch: legacyOwnerLabel === modernOwnerLabel
});

printSection('duplicate filtering to Set');

const requestedTags = [
  'javascript',
  'learning',
  'javascript',
  'es2024',
  'learning'
];

const legacyUniqueTags = requestedTags.filter(
  (tag, index, tags) => tags.indexOf(tag) === index
);

const modernUniqueTags = [...new Set(requestedTags)];

console.log({
  requestedTags,
  legacyUniqueTags,
  modernUniqueTags
});

printSection('object dictionary to Map');

const legacyTaskCountByOwner = {
  user_1001: 2,
  user_1002: 1
};

const modernTaskCountByOwner = new Map([
  ['user_1001', 2],
  ['user_1002', 1]
]);

console.log({
  legacyAvaTaskCount: legacyTaskCountByOwner.user_1001,
  modernAvaTaskCount: modernTaskCountByOwner.get('user_1001'),
  modernEntries: [...modernTaskCountByOwner.entries()]
});

printSection('mutating sort to immutable toSorted');

const legacyPriorities = [3, 1, 2];

const legacySortedPriorities = legacyPriorities.sort(
  (firstPriority, secondPriority) => firstPriority - secondPriority
);

const modernPriorities = [3, 1, 2];

const modernSortedPriorities = modernPriorities.toSorted(
  (firstPriority, secondPriority) => firstPriority - secondPriority
);

console.log({
  legacyPrioritiesAfterSort: legacyPriorities,
  legacySortedPriorities,
  modernPrioritiesAfterToSorted: modernPriorities,
  modernSortedPriorities
});

printSection('JSON cloning to structuredClone');

const originalProject = {
  id: 'project_3003',
  createdAt: new Date('2026-07-24T10:00:00.000Z'),
  tags: new Set(['javascript', 'migration'])
};

const legacyJsonCopy = JSON.parse(JSON.stringify(originalProject));
const modernStructuredCopy = structuredClone(originalProject);

console.log({
  originalCreatedAtIsDate: originalProject.createdAt instanceof Date,
  legacyCreatedAtIsDate: legacyJsonCopy.createdAt instanceof Date,
  modernCreatedAtIsDate: modernStructuredCopy.createdAt instanceof Date,
  originalTagsAreSet: originalProject.tags instanceof Set,
  legacyTagsAreSet: legacyJsonCopy.tags instanceof Set,
  modernTagsAreSet: modernStructuredCopy.tags instanceof Set
});

printSection('callback style to async and await');

/**
 * Simulates an older callback-based API.
 *
 * @param {string} projectId - Project identifier.
 * @param {(error: Error | null, project: { id: string, name: string } | null) => void} callback
 * Completion callback.
 * @returns {void}
 */
function loadProjectWithCallback(projectId, callback) {
  setTimeout(() => {
    if (projectId.length === 0) {
      callback(new RangeError('projectId must not be blank.'), null);

      return;
    }

    callback(null, {
      id: projectId,
      name: 'Modern JavaScript Toolkit'
    });
  }, 5);
}

/**
 * Simulates a modern Promise-based API.
 *
 * @param {string} projectId - Project identifier.
 * @returns {Promise<{ id: string, name: string }>} Loaded project.
 */
async function loadProject(projectId) {
  await delay(5);

  if (projectId.length === 0) {
    throw new RangeError('projectId must not be blank.');
  }

  return {
    id: projectId,
    name: 'Modern JavaScript Toolkit'
  };
}

const callbackProject = await new Promise((resolve, reject) => {
  loadProjectWithCallback('project_3004', (error, loadedProject) => {
    if (error) {
      reject(error);

      return;
    }

    resolve(loadedProject);
  });
});

const awaitedProject = await loadProject('project_3004');

console.log({
  callbackProject,
  awaitedProject,
  projectsMatch:
    JSON.stringify(callbackProject) === JSON.stringify(awaitedProject)
});

console.log('\nAppendix G migration examples completed successfully.');
```

### The Verification

Run:

```bash
npm run appendix:g:migration
```

Expected output includes:

```text
--- manual null checks to optional chaining ---
{
  legacyOwnerLabel: 'Unassigned owner',
  modernOwnerLabel: 'Unassigned owner',
  labelsMatch: true
}

--- mutating sort to immutable toSorted ---
{
  legacyPrioritiesAfterSort: [ 1, 2, 3 ],
  legacySortedPriorities: [ 1, 2, 3 ],
  modernPrioritiesAfterToSorted: [ 3, 1, 2 ],
  modernSortedPriorities: [ 1, 2, 3 ]
}

--- JSON cloning to structuredClone ---
{
  originalCreatedAtIsDate: true,
  legacyCreatedAtIsDate: false,
  modernCreatedAtIsDate: true,
  originalTagsAreSet: true,
  legacyTagsAreSet: false,
  modernTagsAreSet: true
}

Appendix G migration examples completed successfully.
```

---

# G.2: Migrate `var` to `const` and `let`

## The Target

Replace `var` declarations with modern block-scoped declarations.

## The Concept

`var` has function scope rather than block scope. This can allow values declared inside loops or conditions to remain available outside those blocks.

Use:

- `const` when the variable binding will not be reassigned.
- `let` when reassignment is intentional.

## The Implementation

### Older style

```js
var projectName = 'Modern JavaScript Toolkit';
var completedTaskCount = 0;

completedTaskCount = completedTaskCount + 1;
```

### Modern style

```js
const projectName = 'Modern JavaScript Toolkit';
let completedTaskCount = 0;

completedTaskCount += 1;
```

### Migration procedure

1. Change `var` to `const`.
2. Run linting or tests.
3. If the variable is reassigned, change only that declaration from `const` to `let`.
4. Verify block-scoping behavior if the value was declared in a loop or conditional.

### Example: loop scope

```js
for (let index = 0; index < 3; index += 1) {
  console.log(index);
}

// console.log(index);
// ReferenceError: index is not defined.
```

## The Verification

```bash
node --input-type=module -e "
const projectName = 'Modern JavaScript Toolkit';
let completedTaskCount = 0;

completedTaskCount += 1;

console.log({
  projectName,
  completedTaskCount
});
"
```

Expected output:

```text
{
  projectName: 'Modern JavaScript Toolkit',
  completedTaskCount: 1
}
```

---

# G.3: Migrate Manual Extraction to Destructuring

## The Target

Replace repeated property reads with destructuring where it improves clarity.

## The Concept

Destructuring is especially useful when a function needs several values from one object.

It is less useful when you need only one property once:

```js
console.log(project.name);
```

Do not destructure simply to use modern syntax. Use it when it improves readability.

## The Implementation

### Older style

```js
function createProjectLabel(project) {
  var projectId = project.id;
  var projectName = project.name;
  var ownerName = project.owner.displayName;

  return projectId + ': ' + projectName + ' (' + ownerName + ')';
}
```

### Modern style

```js
function createProjectLabel({
  id,
  name,
  owner: {
    displayName: ownerName
  }
}) {
  return `${id}: ${name} (${ownerName})`;
}
```

### Defensive nested destructuring

If `owner` may be absent, provide a parent fallback:

```js
function createSafeProjectLabel({
  id,
  name,
  owner: {
    displayName: ownerName = 'Unassigned owner'
  } = {}
}) {
  return `${id}: ${name} (${ownerName})`;
}
```

## The Verification

```bash
node --input-type=module -e "
function createSafeProjectLabel({
  id,
  name,
  owner: {
    displayName: ownerName = 'Unassigned owner'
  } = {}
}) {
  return \`\${id}: \${name} (\${ownerName})\`;
}

console.log(
  createSafeProjectLabel({
    id: 'project_3001',
    name: 'Modern JavaScript Toolkit'
  })
);
"
```

Expected output:

```text
project_3001: Modern JavaScript Toolkit (Unassigned owner)
```

---

# G.4: Migrate String Concatenation to Template Literals

## The Target

Replace difficult-to-read string concatenation with template literals.

## The Concept

Template literals let you place variables and expressions directly inside a string.

They are especially valuable for:

- Human-readable messages
- URLs
- Log messages
- Multiline text
- Error messages

## The Implementation

### Older style

```js
var message =
  'Project "' +
  project.name +
  '" has ' +
  taskCount +
  ' pending tasks.';
```

### Modern style

```js
const message =
  `Project "${project.name}" has ${taskCount} pending tasks.`;
```

### Multiline migration

### Older style

```js
var releaseNotes =
  'Release 2.4.0\n' +
  '\n' +
  '- Added examples.\n' +
  '- Fixed validation.';
```

### Modern style

```js
const releaseNotes = `
Release 2.4.0

- Added examples.
- Fixed validation.
`.trim();
```

## The Verification

```bash
node --input-type=module -e "
const projectName = 'Modern JavaScript Toolkit';
const taskCount = 2;

console.log(
  \`Project \"\${projectName}\" has \${taskCount} pending tasks.\`
);
"
```

Expected output:

```text
Project "Modern JavaScript Toolkit" has 2 pending tasks.
```

---

# G.5: Migrate Manual Null Checks to `?.` and `??`

## The Target

Replace repetitive nested existence checks with optional chaining and nullish coalescing.

## The Concept

Older JavaScript often checks every level manually:

```js
const city =
  user &&
  user.address &&
  user.address.city;
```

Modern JavaScript expresses the same intention directly:

```js
const city = user?.address?.city;
```

Use `??` when a default should apply only if the result is `null` or `undefined`.

## The Implementation

### Older style

```js
function getOwnerName(project) {
  if (
    project &&
    project.owner &&
    project.owner.displayName
  ) {
    return project.owner.displayName;
  }

  return 'Unassigned owner';
}
```

### Modern style

```js
function getOwnerName(project) {
  return project?.owner?.displayName ?? 'Unassigned owner';
}
```

### Important migration warning: `||` is not always equivalent to `??`

### Older style

```js
const pageSize = settings.pageSize || 25;
```

This changes a valid `0` into `25`.

### Modern style

```js
const pageSize = settings.pageSize ?? 25;
```

This preserves `0`.

## The Verification

```bash
node --input-type=module -e "
const settings = {
  pageSize: 0
};

const pageSize = settings.pageSize ?? 25;
const ownerName =
  undefined?.owner?.displayName ?? 'Unassigned owner';

console.log({
  pageSize,
  ownerName
});
"
```

Expected output:

```text
{
  pageSize: 0,
  ownerName: 'Unassigned owner'
}
```

---

# G.6: Migrate Object Dictionaries to `Map` When Appropriate

## The Target

Replace plain-object dictionary patterns with `Map` when keys are dynamic, non-string, untrusted, or when Map APIs better describe the operation.

## The Concept

A plain object remains excellent for a known record:

```js
const user = {
  id: 'user_1001',
  displayName: 'Ava Patel'
};
```

Use `Map` when you are modeling a key-value relationship:

```js
const taskCountByOwner = new Map();
```

A Map provides explicit APIs:

```js
taskCountByOwner.set('user_1001', 2);
taskCountByOwner.get('user_1001');
taskCountByOwner.has('user_1001');
taskCountByOwner.delete('user_1001');
```

## The Implementation

### Older object-dictionary style

```js
const taskCountByOwner = {};

taskCountByOwner.user_1001 = 2;
taskCountByOwner.user_1002 = 1;

const avaCount = taskCountByOwner.user_1001;
```

### Modern Map style

```js
const taskCountByOwner = new Map();

taskCountByOwner.set('user_1001', 2);
taskCountByOwner.set('user_1002', 1);

const avaCount = taskCountByOwner.get('user_1001');
```

### Migration for dynamic count updates

### Older style

```js
const ownerId = 'user_1001';

taskCountByOwner[ownerId] =
  (taskCountByOwner[ownerId] || 0) + 1;
```

### Modern style

```js
const ownerId = 'user_1001';

const currentCount = taskCountByOwner.get(ownerId) ?? 0;

taskCountByOwner.set(ownerId, currentCount + 1);
```

### Convert a string-keyed Map for JSON output

```js
const serializableCounts = Object.fromEntries(taskCountByOwner);

console.log(JSON.stringify(serializableCounts));
```

## The Verification

```bash
node --input-type=module -e "
const taskCountByOwner = new Map();

for (const ownerId of ['user_1001', 'user_1002', 'user_1001']) {
  const currentCount = taskCountByOwner.get(ownerId) ?? 0;

  taskCountByOwner.set(ownerId, currentCount + 1);
}

console.log(Object.fromEntries(taskCountByOwner));
"
```

Expected output:

```text
{ user_1001: 2, user_1002: 1 }
```

---

# G.7: Migrate Duplicate Filtering to `Set`

## The Target

Replace manual uniqueness logic with `Set` when values should occur only once.

## The Concept

Older code often uses `.filter()` and `.indexOf()` to remove duplicates. That works for primitive values, but a `Set` states the rule more clearly: each value appears once.

## The Implementation

### Older style

```js
const tags = [
  'javascript',
  'learning',
  'javascript'
];

const uniqueTags = tags.filter((tag, index, allTags) => {
  return allTags.indexOf(tag) === index;
});
```

### Modern style

```js
const tags = [
  'javascript',
  'learning',
  'javascript'
];

const uniqueTags = [...new Set(tags)];
```

### Add a value only if absent

```js
const permissions = new Set(['read']);

permissions.add('write');
permissions.add('write');

console.log([...permissions]);
// ['read', 'write']
```

### Important object-reference reminder

```js
const firstTask = {
  id: 'task_1'
};

const secondTask = {
  id: 'task_1'
};

const tasks = new Set([firstTask]);

console.log(tasks.has(secondTask));
// false
```

If uniqueness should be based on `id`, explicitly track IDs:

```js
const seenTaskIds = new Set();

const uniqueTasks = taskRecords.filter((task) => {
  if (seenTaskIds.has(task.id)) {
    return false;
  }

  seenTaskIds.add(task.id);

  return true;
});
```

## The Verification

```bash
node --input-type=module -e "
const tags = [
  'javascript',
  'learning',
  'javascript',
  'es2024'
];

console.log([...new Set(tags)]);
"
```

Expected output:

```text
[ 'javascript', 'learning', 'es2024' ]
```

---

# G.8: Migrate Mutating Array Code to Immutable Array APIs

## The Target

Replace array updates that modify the source array when the original must remain available.

## The Concept

Older methods such as `.sort()` and `.splice()` mutate their receiver.

That can cause bugs when:

- The array is shared between components.
- The original order is meaningful.
- Change detection depends on new references.
- You need to compare before and after states.

Modern APIs create a revised array instead.

## The Implementation

| Legacy operation | Mutates source? | Modern replacement |
|---|---:|---|
| `items.sort()` | Yes | `items.toSorted()` |
| `items.splice(...)` | Yes | `items.toSpliced(...)` |
| `items[index] = value` | Yes | `items.with(index, value)` |
| `items[items.length - 1]` | No | `items.at(-1)` for readability |

### Sort migration

```js
const tasks = [
  {
    id: 'task_2',
    priority: 2
  },
  {
    id: 'task_1',
    priority: 1
  }
];

const tasksByPriority = tasks.toSorted((firstTask, secondTask) => {
  return firstTask.priority - secondTask.priority;
});
```

### Replace-one-item migration

### Older style

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

tasks[1] = {
  ...tasks[1],
  completed: true
};
```

### Modern style

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

const completedTasks = tasks.with(1, {
  ...tasks.at(1),
  completed: true
});
```

### Insert migration

```js
const taskIds = ['task_1', 'task_3'];

const revisedTaskIds = taskIds.toSpliced(
  1,
  0,
  'task_2'
);
```

## The Verification

```bash
node --input-type=module -e "
const values = [3, 1, 2];

const sortedValues = values.toSorted(
  (firstValue, secondValue) => firstValue - secondValue
);

const revisedValues = values.with(1, 99);

console.log({
  sourceValues: values,
  sortedValues,
  revisedValues
});
"
```

Expected output:

```text
{
  sourceValues: [ 3, 1, 2 ],
  sortedValues: [ 1, 2, 3 ],
  revisedValues: [ 3, 99, 2 ]
}
```

---

# G.9: Migrate JSON Copying to `structuredClone()`

## The Target

Replace JSON-based deep-copy techniques when your data includes supported non-JSON types or circular references.

## The Concept

This older copying pattern is common:

```js
const copy = JSON.parse(JSON.stringify(value));
```

It can work for simple JSON-compatible data, but it changes or loses important values:

- `Date` becomes a string.
- `Set` becomes `{}`.
- `Map` becomes `{}`.
- `undefined` properties disappear.
- `BigInt` throws.
- Circular references throw.
- Functions are omitted or otherwise unsupported.

`structuredClone()` is a better choice for many modern data structures.

## The Implementation

### Older style

```js
const original = {
  createdAt: new Date(),
  roles: new Set(['reader'])
};

const copied = JSON.parse(JSON.stringify(original));
```

### Modern style

```js
const original = {
  createdAt: new Date(),
  roles: new Set(['reader'])
};

const copied = structuredClone(original);
```

### Use targeted updates when you know exactly what changes

Do not deep-clone a large object only to change one known nested value.

```js
const revisedProject = {
  ...project,
  settings: {
    ...project.settings,
    colorScheme: 'dark'
  }
};
```

## The Verification

```bash
node --input-type=module -e "
const source = {
  createdAt: new Date('2026-07-24T10:00:00.000Z'),
  roles: new Set(['reader'])
};

const jsonCopy = JSON.parse(JSON.stringify(source));
const structuredCopy = structuredClone(source);

console.log({
  sourceDateIsDate: source.createdAt instanceof Date,
  jsonDateIsDate: jsonCopy.createdAt instanceof Date,
  structuredDateIsDate: structuredCopy.createdAt instanceof Date,
  sourceRolesAreSet: source.roles instanceof Set,
  jsonRolesAreSet: jsonCopy.roles instanceof Set,
  structuredRolesAreSet: structuredCopy.roles instanceof Set
});
"
```

Expected output:

```text
{
  sourceDateIsDate: true,
  jsonDateIsDate: false,
  structuredDateIsDate: true,
  sourceRolesAreSet: true,
  jsonRolesAreSet: false,
  structuredRolesAreSet: true
}
```

---

# G.10: Migrate Callback-Based Async Code to `async` and `await`

## The Target

Convert callback-based asynchronous code into Promise-based functions that can be read with `async` and `await`.

## The Concept

Older Node.js code often uses error-first callbacks:

```js
loadProject('project_1', (error, project) => {
  if (error) {
    // Handle error.
    return;
  }

  // Use project.
});
```

Promise-based APIs allow a flatter, more readable flow:

```js
try {
  const project = await loadProject('project_1');

  // Use project.
} catch (error) {
  // Handle error.
}
```

Do not mix styles arbitrarily. At an API boundary, convert a callback API into a Promise once, then use the Promise form internally.

## The Implementation

### Callback-based function

```js
function loadProjectWithCallback(projectId, callback) {
  setTimeout(() => {
    if (projectId.length === 0) {
      callback(
        new RangeError('projectId must not be blank.'),
        null
      );

      return;
    }

    callback(null, {
      id: projectId,
      name: 'Modern JavaScript Toolkit'
    });
  }, 10);
}
```

### Promise-based equivalent

```js
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

async function loadProject(projectId) {
  await delay(10);

  if (projectId.length === 0) {
    throw new RangeError('projectId must not be blank.');
  }

  return {
    id: projectId,
    name: 'Modern JavaScript Toolkit'
  };
}
```

### Wrap a callback API when replacement is not possible

```js
function loadLegacyProject(projectId) {
  return new Promise((resolve, reject) => {
    loadProjectWithCallback(projectId, (error, project) => {
      if (error) {
        reject(error);

        return;
      }

      resolve(project);
    });
  });
}
```

## The Verification

```bash
node --input-type=module -e "
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

async function loadProject(projectId) {
  await delay(1);

  if (projectId.length === 0) {
    throw new RangeError('projectId must not be blank.');
  }

  return {
    id: projectId,
    name: 'Modern JavaScript Toolkit'
  };
}

const project = await loadProject('project_3001');

console.log(project);
"
```

Expected output:

```text
{
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit'
}
```

---

# G.11: Migrate CommonJS Modules to ES Modules

## The Target

Move from CommonJS `require()` and `module.exports` to modern ES module `import` and `export` syntax.

## The Concept

CommonJS was historically the default module system in Node.js. ES modules are the standardized JavaScript module system used by modern browsers and Node.js.

ES modules make dependencies explicit and work naturally across modern JavaScript environments.

For this tutorial’s project, ES modules are enabled by:

```json
{
  "type": "module"
}
```

in `package.json`.

## The Implementation

### CommonJS export

```js
// task.js
function createTask(id, title) {
  return {
    id,
    title,
    completed: false
  };
}

module.exports = {
  createTask
};
```

### CommonJS import

```js
// index.js
const {
  createTask
} = require('./task');

console.log(createTask('task_1', 'Write migration guide'));
```

### ES module export

```js
// task.js
export function createTask(id, title) {
  return {
    id,
    title,
    completed: false
  };
}
```

### ES module import

```js
// index.js
import {
  createTask
} from './task.js';

console.log(createTask('task_1', 'Write migration guide'));
```

### Default export example

Use a default export when the module has one clearly primary value.

```js
// format-project.js
export default function formatProject(project) {
  return `${project.id}: ${project.name}`;
}
```

```js
// index.js
import formatProject from './format-project.js';
```

### Migration warning

Do not casually mix module systems in the same file:

```js
// Avoid mixing these forms:
// import { createTask } from './task.js';
// const utility = require('./utility');
```

When migrating an existing Node.js project, establish a clear boundary and convert modules deliberately.

## The Verification

Create the following temporary files.

### `src/appendices/module-demo/task.js`

```js
/**
 * Creates a task record.
 *
 * @param {string} id - Task identifier.
 * @param {string} title - Task title.
 * @returns {{ id: string, title: string, completed: boolean }} Task.
 */
export function createTask(id, title) {
  return {
    id,
    title,
    completed: false
  };
}
```

### `src/appendices/module-demo/index.js`

```js
import {
  createTask
} from './task.js';

console.log(
  createTask('task_1', 'Verify ES module imports')
);
```

Create the directory:

```bash
mkdir -p src/appendices/module-demo
```

Then run:

```bash
node src/appendices/module-demo/index.js
```

Expected output:

```text
{
  id: 'task_1',
  title: 'Verify ES module imports',
  completed: false
}
```

---

# G.12: Practical Incremental Migration Plan

## The Target

Modernize a real application without making an unsafe, all-at-once rewrite.

## The Concept

A full rewrite is risky because it changes too many variables at once. Incremental migration lets you compare behavior continuously.

Treat modernization as a sequence of small pull requests or commits.

## The Implementation

Use this order for most projects.

### Phase 1: Establish safety rails

1. Add or improve automated tests around important behavior.
2. Add formatting and linting.
3. Record supported Node.js and browser versions.
4. Confirm the build and deployment pipeline works.
5. Create a baseline test run.

Commands:

```bash
npm run lint
npm run format:check
npm test
```

> Your project may use a different test script. Use the command that already runs its automated test suite.

### Phase 2: Low-risk syntax changes

Convert:

- `var` to `const` or `let`
- String concatenation to template literals
- Simple function expressions to named functions or arrows
- Repetitive property extraction to destructuring

These changes are usually easier to review because they should preserve behavior closely.

### Phase 3: Defensive access improvements

Convert:

- Manual null checks to optional chaining where missing data is acceptable
- `||` defaults to `??` where `0`, `false`, or `''` are valid
- Ambiguous errors to explicit validation and informative errors

### Phase 4: Collection and mutation improvements

Convert:

- Duplicate filtering to `Set`
- Dictionary-like dynamic lookups to `Map` where appropriate
- Shared-array `.sort()` operations to `.toSorted()`
- Shared-array `.splice()` operations to `.toSpliced()`
- Direct array index replacement to `.with()`

### Phase 5: Async and module boundaries

Convert:

- Callback wrappers to Promise-based adapters
- Internal async flows to `async` and `await`
- CommonJS modules to ES modules where supported by the project’s runtime strategy

### Phase 6: Deep-copy review

Search for JSON clone patterns:

```bash
grep -RIn "JSON.parse(JSON.stringify" src
```

For each result, decide whether to:

- Use `structuredClone()`
- Use a targeted immutable update
- Keep JSON serialization because JSON-compatible conversion is intentionally required

## The Verification

After every small migration:

```bash
npm run lint
npm run format:check
npm test
```

For this tutorial workspace, run:

```bash
npm run appendix:g:migration
npm run appendix:e:exercises
npm start
```

All commands should finish without uncaught errors.

---

# G.13: Migration Decision Table

| Legacy pattern | Modern alternative | Use it when | Watch out for |
|---|---|---|---|
| `var` | `const` / `let` | All new and maintained code | `const` does not freeze objects |
| `'Hello, ' + name` | `` `Hello, ${name}` `` | Building messages and strings | Backticks are required |
| `object && object.child` | `object?.child` | Data may be absent | Do not hide required-data errors |
| `value || fallback` | `value ?? fallback` | `0`, `false`, or `''` are valid | `??` only handles `null` / `undefined` |
| Array duplicate filter | `new Set(values)` | Primitive unique values | Objects compare by reference |
| Object dictionary | `Map` | Dynamic keys and key-value relationships | `Map` is not directly JSON serializable |
| `.sort()` | `.toSorted()` | Original order must remain unchanged | Requires modern runtime support |
| `.splice()` | `.toSpliced()` | Source array must remain unchanged | Arguments mirror `.splice()` |
| `items[index] = value` | `.with(index, value)` | Immutable replacement at one index | Throws for out-of-range index |
| JSON clone | `structuredClone()` | Compatible data needs an independent copy | Functions and symbols are unsupported |
| Callback nesting | `async` / `await` | Promise-based async workflows | Handle rejection with `try` / `catch` |
| `require()` / `module.exports` | `import` / `export` | Modern Node.js and browser modules | Configure module type and file extensions |

---

# Appendix G Completion Checklist

Run the migration demonstration:

```bash
npm run appendix:g:migration
```

Then run the project checks:

```bash
npm run appendix:e:exercises
npm run appendix:f:glossary
npm start
```

Confirm that each command completes successfully.

You should now be able to recognize common older JavaScript patterns and choose a modern replacement based on behavior—not merely shorter syntax.
