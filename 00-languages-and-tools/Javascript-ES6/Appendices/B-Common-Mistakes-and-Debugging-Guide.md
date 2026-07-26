# Appendix B: Common Mistakes and Debugging Guide

Modern JavaScript makes many tasks clearer, but concise syntax can also hide important behavior. This appendix covers common mistakes from Parts 1–4 and shows how to identify, reproduce, and correct them.

The goal is not to avoid mistakes completely. Every developer makes them. The goal is to make mistakes:

- Easy to notice
- Easy to explain
- Easy to fix
- Less likely to return

---

## B.1: Add a Debugging Script

### The Target

Add a runnable script for the debugging examples in this appendix.

### The Concept

A debugging script is a controlled practice area. Instead of waiting for a bug to appear in a large application, you can reproduce one small behavior at a time.

Think of it like a flight simulator: you safely practice responding to difficult situations before they affect a real journey.

### The Implementation

Create this directory if it does not already exist:

```bash
mkdir -p src/appendices
```

> On Windows PowerShell:

```powershell
mkdir src\appendices
```

Add this script to the existing `"scripts"` object in `package.json`:

```json
"appendix:b:debugging": "node src/appendices/appendix-b-debugging.js"
```

For example, the relevant portion of your `package.json` should look like this:

### `package.json` — scripts excerpt

```json
{
  "scripts": {
    "start": "node src/index.js",
    "part:1:variables": "node src/part-1-syntax-ergonomics/variables.js",
    "part:1:destructuring": "node src/part-1-syntax-ergonomics/destructuring.js",
    "part:1:rest-spread": "node src/part-1-syntax-ergonomics/rest-spread.js",
    "part:2:arrows": "node src/part-2-expressive-syntax/arrow-functions.js",
    "part:2:templates": "node src/part-2-expressive-syntax/template-literals.js",
    "part:2:objects": "node src/part-2-expressive-syntax/enhanced-objects.js",
    "part:3:sets-maps": "node src/part-3-collections-iteration/sets-and-maps.js",
    "part:3:weak-collections": "node src/part-3-collections-iteration/weak-collections.js",
    "part:3:iteration": "node src/part-3-collections-iteration/iterators-generators.js",
    "part:4:safe-access": "node src/part-4-defensive-modern-apis/safe-access.js",
    "part:4:structured-clone": "node src/part-4-defensive-modern-apis/structured-clone.js",
    "part:4:immutable-arrays": "node src/part-4-defensive-modern-apis/immutable-arrays.js",
    "compatibility:node": "node src/appendices/appendix-a-compatibility-check.js",
    "appendix:b:debugging": "node src/appendices/appendix-b-debugging.js"
  }
}
```

### The Verification

Run:

```bash
npm run
```

Confirm that the output includes:

```text
appendix:b:debugging
```

The command will run successfully after you create the debugging file in the next steps.

---

## B.2: Mistake — Using `var` When Block Scope Is Required

### The Target

Understand why `var` can leak values outside blocks and why `const` and `let` are safer defaults.

### The Concept

A block is code surrounded by braces:

```js
if (condition) {
  // This is a block.
}
```

`let` and `const` keep variables inside their block. `var` does not. It is function-scoped, which means a value declared inside a loop or condition can unexpectedly remain available outside it.

Think of a block-scoped variable as a note kept inside one room. A `var` variable is more like an announcement over the whole floor: it travels farther than you may expect.

### The Implementation

Create this file.

### `src/appendices/appendix-b-debugging.js`

```js
/**
 * Appendix B: Common modern JavaScript mistakes and debugging examples.
 *
 * Run with:
 * npm run appendix:b:debugging
 */

/**
 * Prints a section heading.
 *
 * @param {string} title - The heading to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

/**
 * Runs an operation and prints a normalized error when it fails.
 *
 * @param {string} label - Description of the operation.
 * @param {() => unknown} operation - Operation to execute.
 * @returns {void}
 */
function runSafely(label, operation) {
  try {
    const result = operation();

    console.log({
      label,
      result
    });
  } catch (error) {
    console.log({
      label,
      errorName: error.name,
      message: error.message
    });
  }
}

printSection('1. var escapes block scope');

if (true) {
  var legacyStatus = 'available';
}

console.log({
  legacyStatus,
  explanation:
    'var is function-scoped, so it remains available outside the if block.'
});

printSection('2. let and const stay inside their block');

if (true) {
  const secureStatus = 'available';

  console.log({
    secureStatus,
    explanation: 'secureStatus is usable inside this block.'
  });
}

runSafely('Reading a block-scoped variable outside its block', () => {
  return secureStatus;
});

console.log('\nInitial block-scope examples completed successfully.');
```

### The Verification

Run:

```bash
npm run appendix:b:debugging
```

Expected output includes:

```text
--- 1. var escapes block scope ---
{
  legacyStatus: 'available',
  explanation: 'var is function-scoped, so it remains available outside the if block.'
}

--- 2. let and const stay inside their block ---
{
  secureStatus: 'available',
  explanation: 'secureStatus is usable inside this block.'
}
{
  label: 'Reading a block-scoped variable outside its block',
  errorName: 'ReferenceError',
  message: 'secureStatus is not defined'
}
```

The exact `ReferenceError` message can vary by runtime.

---

## B.3: Mistake — Assuming `const` Makes an Object Immutable

### The Target

Learn the difference between a constant variable binding and an immutable object.

### The Concept

`const` prevents reassignment of the variable itself:

```js
const user = {
  name: 'Ava'
};

// user = {}; // Not allowed.
```

But it does not prevent changes inside the object:

```js
user.name = 'Mina'; // Allowed.
```

Think of `const` as bolting a label to one specific folder. You cannot attach the label to a new folder, but you can still edit papers inside the existing folder.

### The Implementation

Append the following code to `src/appendices/appendix-b-debugging.js`.

### `src/appendices/appendix-b-debugging.js` — append

```js
printSection('3. const prevents reassignment, not object mutation');

const userProfile = {
  id: 'user_1001',
  displayName: 'Ava Patel',
  role: 'reader'
};

userProfile.role = 'editor';

console.log({
  userProfile,
  explanation:
    'Changing a property is allowed because the userProfile variable still refers to the same object.'
});

runSafely('Reassigning a const variable', () => {
  userProfile = {
    id: 'user_1002',
    displayName: 'Mina Chen',
    role: 'admin'
  };

  return userProfile;
});

printSection('4. immutable update creates a new object');

const updatedUserProfile = {
  ...userProfile,
  role: 'admin'
};

console.log({
  originalUserProfile: userProfile,
  updatedUserProfile,
  objectsAreDifferent: userProfile !== updatedUserProfile
});
```

### The Verification

Run:

```bash
npm run appendix:b:debugging
```

Expected output includes:

```text
--- 3. const prevents reassignment, not object mutation ---
{
  userProfile: {
    id: 'user_1001',
    displayName: 'Ava Patel',
    role: 'editor'
  },
  explanation: 'Changing a property is allowed because the userProfile variable still refers to the same object.'
}

--- 4. immutable update creates a new object ---
{
  originalUserProfile: {
    id: 'user_1001',
    displayName: 'Ava Patel',
    role: 'editor'
  },
  updatedUserProfile: {
    id: 'user_1001',
    displayName: 'Ava Patel',
    role: 'admin'
  },
  objectsAreDifferent: true
}
```

---

## B.4: Mistake — Destructuring a Missing Nested Object

### The Target

Safely destructure data whose parent property may not exist.

### The Concept

Destructuring is convenient, but it expects the container being unpacked to exist.

This works:

```js
const order = {
  shippingAddress: {
    city: 'Lisbon'
  }
};

const {
  shippingAddress: { city }
} = order;
```

But this throws if `shippingAddress` is missing:

```js
const order = {};

// Throws because JavaScript cannot unpack city from undefined.
const {
  shippingAddress: { city }
} = order;
```

The fix is to provide an empty-object fallback for the parent property.

### The Implementation

Append the following code to `src/appendices/appendix-b-debugging.js`.

### `src/appendices/appendix-b-debugging.js` — append

```js
printSection('5. nested destructuring can fail when a parent is missing');

const orderWithoutShippingAddress = {
  id: 'order_7001'
};

runSafely('Destructuring a missing nested object', () => {
  const {
    shippingAddress: {
      city
    }
  } = orderWithoutShippingAddress;

  return city;
});

printSection('6. nested defaults prevent destructuring failures');

const {
  shippingAddress: {
    city: safeShippingCity = 'Not provided',
    country: safeShippingCountry = 'Not provided'
  } = {}
} = orderWithoutShippingAddress;

console.log({
  safeShippingCity,
  safeShippingCountry
});

/**
 * Returns a normalized shipping summary.
 *
 * @param {{
 *   shippingAddress?: {
 *     city?: string,
 *     country?: string
 *   }
 * }} order - Order-like data.
 * @returns {{ city: string, country: string }} Shipping summary.
 */
function getShippingSummary(order) {
  const {
    shippingAddress: {
      city = 'Not provided',
      country = 'Not provided'
    } = {}
  } = order;

  return {
    city,
    country
  };
}

console.log({
  completeAddress: getShippingSummary({
    shippingAddress: {
      city: 'Lisbon',
      country: 'Portugal'
    }
  }),
  incompleteAddress: getShippingSummary({
    shippingAddress: {
      country: 'Canada'
    }
  }),
  missingAddress: getShippingSummary({})
});
```

### The Verification

Run:

```bash
npm run appendix:b:debugging
```

Expected output includes:

```text
--- 5. nested destructuring can fail when a parent is missing ---
{
  label: 'Destructuring a missing nested object',
  errorName: 'TypeError'
}

--- 6. nested defaults prevent destructuring failures ---
{
  safeShippingCity: 'Not provided',
  safeShippingCountry: 'Not provided'
}
{
  completeAddress: { city: 'Lisbon', country: 'Portugal' },
  incompleteAddress: { city: 'Not provided', country: 'Canada' },
  missingAddress: { city: 'Not provided', country: 'Not provided' }
}
```

---

## B.5: Mistake — Forgetting Parentheses When Returning an Object from an Arrow Function

### The Target

Learn why an arrow function returning an object needs parentheses when using an implicit return.

### The Concept

Arrow functions with braces use a function body:

```js
const createUser = () => {
  return {
    role: 'reader'
  };
};
```

An implicit return has no function-body braces:

```js
const createUser = () => ({
  role: 'reader'
});
```

Without parentheses, JavaScript reads the object braces as the function body, not as an object value.

### The Implementation

Append the following code.

### `src/appendices/appendix-b-debugging.js` — append

```js
printSection('7. arrow functions can accidentally return undefined');

const createIncorrectUser = (displayName) => {
  id: crypto.randomUUID(),
  displayName;
};

const createCorrectUser = (displayName) => ({
  id: crypto.randomUUID(),
  displayName
});

console.log({
  incorrectResult: createIncorrectUser('Ava Patel'),
  correctResult: createCorrectUser('Ava Patel'),
  explanation:
    'The incorrect function has a block body with no return statement.'
});

printSection('8. explicit returns are valid and often clearer');

const createExplicitUser = (displayName) => {
  return {
    id: crypto.randomUUID(),
    displayName
  };
};

console.log(createExplicitUser('Mina Chen'));
```

### The Verification

Run:

```bash
npm run appendix:b:debugging
```

Expected output includes:

```text
--- 7. arrow functions can accidentally return undefined ---
{
  incorrectResult: undefined,
  correctResult: {
    id: '...',
    displayName: 'Ava Patel'
  },
  explanation: 'The incorrect function has a block body with no return statement.'
}
```

The generated UUID differs every run.

---

## B.6: Mistake — Using an Arrow Function as an Object Method That Needs `this`

### The Target

Recognize when arrow functions should not be used as methods.

### The Concept

Arrow functions inherit `this` from where they are created. They do not receive `this` from the object that calls them.

That makes arrows excellent for callbacks, especially callbacks nested inside class methods. But it makes them unsuitable for most object methods that need to access the object’s properties.

### The Implementation

Append the following code.

### `src/appendices/appendix-b-debugging.js` — append

```js
printSection('9. arrow methods do not receive object this');

const incorrectProject = {
  name: 'Modern JavaScript Toolkit',

  getLabel: () => {
    return `Project: ${this?.name ?? 'unknown'}`;
  }
};

const correctProject = {
  name: 'Modern JavaScript Toolkit',

  getLabel() {
    return `Project: ${this.name}`;
  }
};

console.log({
  incorrectArrowMethodResult: incorrectProject.getLabel(),
  correctMethodResult: correctProject.getLabel()
});

printSection('10. arrow callbacks preserve class instance this');

class ProgressTracker {
  /**
   * @param {string} projectName - Project being tracked.
   */
  constructor(projectName) {
    this.projectName = projectName;
    this.completedSteps = 0;
  }

  /**
   * Returns a callback that safely retains access to this instance.
   *
   * @returns {() => string} Completion callback.
   */
  createCompletionCallback() {
    return () => {
      this.completedSteps += 1;

      return `${this.projectName}: ${this.completedSteps} completed step(s).`;
    };
  }
}

const progressTracker = new ProgressTracker('Modern JavaScript Toolkit');
const recordCompletion = progressTracker.createCompletionCallback();

console.log(recordCompletion());
console.log(recordCompletion());
```

### The Verification

Run:

```bash
npm run appendix:b:debugging
```

Expected output includes:

```text
--- 9. arrow methods do not receive object this ---
{
  incorrectArrowMethodResult: 'Project: unknown',
  correctMethodResult: 'Project: Modern JavaScript Toolkit'
}

--- 10. arrow callbacks preserve class instance this ---
Modern JavaScript Toolkit: 1 completed step(s).
Modern JavaScript Toolkit: 2 completed step(s).
```

---

## B.7: Mistake — Using `||` When `??` Is Required

### The Target

Choose the correct fallback operator for values such as `0`, `false`, and empty strings.

### The Concept

Logical OR, `||`, treats every falsy value as absent:

- `false`
- `0`
- `''`
- `null`
- `undefined`
- `NaN`

Nullish coalescing, `??`, treats only `null` and `undefined` as absent.

This matters for settings. A page size of `0`, a disabled flag of `false`, or a deliberately empty display label may be valid values.

### The Implementation

Append the following code.

### `src/appendices/appendix-b-debugging.js` — append

```js
printSection('11. || can overwrite meaningful falsy values');

const incomingSettings = {
  pageSize: 0,
  showCompletedTasks: false,
  displayName: ''
};

const settingsUsingLogicalOr = {
  pageSize: incomingSettings.pageSize || 25,
  showCompletedTasks: incomingSettings.showCompletedTasks || true,
  displayName: incomingSettings.displayName || 'Anonymous'
};

const settingsUsingNullishCoalescing = {
  pageSize: incomingSettings.pageSize ?? 25,
  showCompletedTasks: incomingSettings.showCompletedTasks ?? true,
  displayName: incomingSettings.displayName ?? 'Anonymous'
};

console.log({
  settingsUsingLogicalOr,
  settingsUsingNullishCoalescing
});

printSection('12. ??= is appropriate for missing-value defaults');

const normalizedSettings = {
  pageSize: 0,
  showCompletedTasks: false,
  colorScheme: null,
  language: undefined
};

normalizedSettings.pageSize ??= 25;
normalizedSettings.showCompletedTasks ??= true;
normalizedSettings.colorScheme ??= 'system';
normalizedSettings.language ??= 'en';

console.log(normalizedSettings);
```

### The Verification

Run:

```bash
npm run appendix:b:debugging
```

Expected output includes:

```text
--- 11. || can overwrite meaningful falsy values ---
{
  settingsUsingLogicalOr: {
    pageSize: 25,
    showCompletedTasks: true,
    displayName: 'Anonymous'
  },
  settingsUsingNullishCoalescing: {
    pageSize: 0,
    showCompletedTasks: false,
    displayName: ''
  }
}

--- 12. ??= is appropriate for missing-value defaults ---
{
  pageSize: 0,
  showCompletedTasks: false,
  colorScheme: 'system',
  language: 'en'
}
```

---

## B.8: Mistake — Treating Spread Syntax as a Deep Copy

### The Target

Identify shallow-copy bugs caused by nested objects and arrays.

### The Concept

Object and array spread only copy the outer container.

```js
const copiedProject = {
  ...project
};
```

If `project` contains nested objects, both the original and copy still point to the same nested values.

Think of copying a filing cabinet’s label while continuing to share the drawers. The cabinets look separate, but changing a document in one drawer changes it for both.

### The Implementation

Append the following code.

### `src/appendices/appendix-b-debugging.js` — append

```js
printSection('13. object spread creates a shallow copy');

const originalProject = {
  id: 'project_3001',
  metadata: {
    priority: 'high',
    owner: 'Ava Patel'
  },
  tags: ['javascript', 'learning']
};

const shallowProjectCopy = {
  ...originalProject
};

shallowProjectCopy.metadata.priority = 'urgent';
shallowProjectCopy.tags.push('shared');

console.log({
  originalProject,
  shallowProjectCopy,
  metadataIsShared:
    originalProject.metadata === shallowProjectCopy.metadata,
  tagsAreShared:
    originalProject.tags === shallowProjectCopy.tags
});

printSection('14. structuredClone creates independent nested data');

const independentlyCopiedProject = structuredClone(originalProject);

independentlyCopiedProject.metadata.priority = 'low';
independentlyCopiedProject.tags.push('independent');

console.log({
  originalProject,
  independentlyCopiedProject,
  metadataIsIndependent:
    originalProject.metadata !== independentlyCopiedProject.metadata,
  tagsAreIndependent:
    originalProject.tags !== independentlyCopiedProject.tags
});

printSection('15. targeted immutable updates are often the best option');

const priorityUpdatedProject = {
  ...originalProject,
  metadata: {
    ...originalProject.metadata,
    priority: 'medium'
  }
};

console.log({
  originalProject,
  priorityUpdatedProject,
  topLevelObjectsAreDifferent:
    originalProject !== priorityUpdatedProject,
  metadataObjectsAreDifferent:
    originalProject.metadata !== priorityUpdatedProject.metadata,
  tagsRemainSharedBecauseTheyWereNotUpdated:
    originalProject.tags === priorityUpdatedProject.tags
});
```

### The Verification

Run:

```bash
npm run appendix:b:debugging
```

Expected output includes:

```text
--- 13. object spread creates a shallow copy ---
{
  metadataIsShared: true,
  tagsAreShared: true
}

--- 14. structuredClone creates independent nested data ---
{
  metadataIsIndependent: true,
  tagsAreIndependent: true
}

--- 15. targeted immutable updates are often the best option ---
{
  topLevelObjectsAreDifferent: true,
  metadataObjectsAreDifferent: true,
  tagsRemainSharedBecauseTheyWereNotUpdated: true
}
```

The final shared `tags` reference is safe only if neither version mutates that array. If the tags need to change, create a new tags array as well.

---

## B.9: Mistake — Mutating an Array with `.sort()` or `.splice()`

### The Target

Avoid accidental array mutation by choosing immutable alternatives.

### The Concept

Some familiar array methods alter the original array:

```js
tasks.sort();
tasks.splice(1, 1);
```

This may break code elsewhere that relies on the original order or contents.

Modern immutable methods create revised copies:

```js
const sortedTasks = tasks.toSorted();
const tasksWithoutSecond = tasks.toSpliced(1, 1);
```

### The Implementation

Append the following code.

### `src/appendices/appendix-b-debugging.js` — append

```js
printSection('16. sort() mutates its original array');

const responseTimes = [250, 18, 100, 4];

const sortedResponseTimesWithSort = responseTimes.sort(
  (firstTime, secondTime) => firstTime - secondTime
);

console.log({
  responseTimes,
  sortedResponseTimesWithSort,
  sameArrayReference:
    responseTimes === sortedResponseTimesWithSort
});

printSection('17. toSorted() preserves its original array');

const originalResponseTimes = [250, 18, 100, 4];

const sortedResponseTimesWithToSorted = originalResponseTimes.toSorted(
  (firstTime, secondTime) => firstTime - secondTime
);

console.log({
  originalResponseTimes,
  sortedResponseTimesWithToSorted,
  arraysAreDifferent:
    originalResponseTimes !== sortedResponseTimesWithToSorted
});

printSection('18. splice() mutates and toSpliced() does not');

const taskIdsForSplice = ['task_1', 'task_2', 'task_3'];

const removedTaskIds = taskIdsForSplice.splice(1, 1);

console.log({
  taskIdsForSplice,
  removedTaskIds,
  explanation: 'splice() changed taskIdsForSplice.'
});

const taskIdsForToSpliced = ['task_1', 'task_2', 'task_3'];

const taskIdsWithoutSecondTask = taskIdsForToSpliced.toSpliced(1, 1);

console.log({
  taskIdsForToSpliced,
  taskIdsWithoutSecondTask,
  explanation: 'toSpliced() returned a changed copy.'
});

printSection('19. with() replaces an item without changing its source array');

const taskStatuses = ['pending', 'pending', 'completed'];

const revisedTaskStatuses = taskStatuses.with(1, 'in_progress');

console.log({
  taskStatuses,
  revisedTaskStatuses,
  arraysAreDifferent: taskStatuses !== revisedTaskStatuses
});
```

### The Verification

Run:

```bash
npm run appendix:b:debugging
```

Expected output includes:

```text
--- 16. sort() mutates its original array ---
{
  responseTimes: [ 4, 18, 100, 250 ],
  sortedResponseTimesWithSort: [ 4, 18, 100, 250 ],
  sameArrayReference: true
}

--- 17. toSorted() preserves its original array ---
{
  originalResponseTimes: [ 250, 18, 100, 4 ],
  sortedResponseTimesWithToSorted: [ 4, 18, 100, 250 ],
  arraysAreDifferent: true
}

--- 18. splice() mutates and toSpliced() does not ---
{
  taskIdsForSplice: [ 'task_1', 'task_3' ],
  removedTaskIds: [ 'task_2' ]
}
```

---

## B.10: Mistake — Expecting Object Values in a `Set` or `Map` to Match by Contents

### The Target

Understand object reference identity in `Set` and `Map`.

### The Concept

Objects are compared by **reference identity**, not by matching property values.

These objects look identical:

```js
const first = { id: 'task_1' };
const second = { id: 'task_1' };
```

But they are separate objects:

```js
first === second; // false
```

A `Set` and `Map` treat them as distinct.

Think of two house keys cut from the same design. They may look alike, but they are still separate physical keys.

### The Implementation

Append the following code.

### `src/appendices/appendix-b-debugging.js` — append

```js
printSection('20. Set compares objects by reference');

const firstTask = {
  id: 'task_1',
  title: 'Write documentation'
};

const sameLookingTask = {
  id: 'task_1',
  title: 'Write documentation'
};

const tasksInSet = new Set([firstTask]);

console.log({
  firstTaskIsPresent: tasksInSet.has(firstTask),
  sameLookingTaskIsPresent: tasksInSet.has(sameLookingTask),
  firstTaskEqualsSameLookingTask: firstTask === sameLookingTask
});

printSection('21. Map also compares object keys by reference');

const taskStatusByTask = new Map([
  [firstTask, 'completed']
]);

console.log({
  statusForFirstTask: taskStatusByTask.get(firstTask),
  statusForSameLookingTask: taskStatusByTask.get(sameLookingTask)
});

printSection('22. use primitive identifiers for content-based lookup');

const taskStatusById = new Map([
  [firstTask.id, 'completed']
]);

console.log({
  statusForTaskId: taskStatusById.get('task_1'),
  hasTaskId: taskStatusById.has(sameLookingTask.id)
});
```

### The Verification

Run:

```bash
npm run appendix:b:debugging
```

Expected output includes:

```text
--- 20. Set compares objects by reference ---
{
  firstTaskIsPresent: true,
  sameLookingTaskIsPresent: false,
  firstTaskEqualsSameLookingTask: false
}

--- 21. Map also compares object keys by reference ---
{
  statusForFirstTask: 'completed',
  statusForSameLookingTask: undefined
}

--- 22. use primitive identifiers for content-based lookup ---
{
  statusForTaskId: 'completed',
  hasTaskId: true
}
```

---

## B.11: Mistake — Using `WeakMap` or `WeakSet` When Enumeration Is Required

### The Target

Avoid choosing weak collections when you need to list, count, serialize, or inspect entries.

### The Concept

Weak collections are designed for temporary metadata tied to object lifetimes.

They intentionally do not provide:

- `.size`
- `.keys()`
- `.values()`
- `.entries()`
- `for...of` iteration

JavaScript must be free to remove entries when key objects become unreachable. If enumeration were allowed, code could observe unpredictable garbage-collection timing.

Use a regular `Map` or `Set` when the application needs to inspect all stored values.

### The Implementation

Append the following code.

### `src/appendices/appendix-b-debugging.js` — append

```js
printSection('23. WeakMap cannot be enumerated');

const requestMetadata = new WeakMap();
const request = {
  id: 'request_1001'
};

requestMetadata.set(request, {
  validated: true
});

console.log({
  metadataForRequest: requestMetadata.get(request),
  hasSizeProperty: 'size' in requestMetadata,
  hasIterator: Symbol.iterator in requestMetadata
});

runSafely('Attempting to iterate over a WeakMap', () => {
  return [...requestMetadata];
});

printSection('24. use Map when entries must be listed');

const requestMetadataById = new Map([
  [
    'request_1001',
    {
      validated: true
    }
  ],
  [
    'request_1002',
    {
      validated: false
    }
  ]
]);

console.log({
  count: requestMetadataById.size,
  entries: [...requestMetadataById.entries()]
});
```

### The Verification

Run:

```bash
npm run appendix:b:debugging
```

Expected output includes:

```text
--- 23. WeakMap cannot be enumerated ---
{
  metadataForRequest: { validated: true },
  hasSizeProperty: false,
  hasIterator: false
}
{
  label: 'Attempting to iterate over a WeakMap',
  errorName: 'TypeError'
}

--- 24. use Map when entries must be listed ---
{
  count: 2,
  entries: [
    [ 'request_1001', { validated: true } ],
    [ 'request_1002', { validated: false } ]
  ]
}
```

---

## B.12: Mistake — Forgetting That Generators Are Lazy

### The Target

Understand when generator code runs and why calling a generator function does not immediately execute its body.

### The Concept

A normal function runs immediately when called:

```js
function greet() {
  console.log('Hello');
}

greet();
```

A generator function returns a generator object first. Its body begins when `.next()` is called or when it is consumed by `for...of`.

Think of a generator as a television series loaded into a streaming queue. Creating the queue does not begin episode one. Pressing play does.

### The Implementation

Append the following code.

### `src/appendices/appendix-b-debugging.js` — append

```js
printSection('25. generator bodies begin when consumed');

/**
 * Produces two task IDs.
 *
 * @returns {Generator<string, void, unknown>} Task ID generator.
 */
function* generateTaskIds() {
  console.log('Generator body started.');

  yield 'task_1';

  console.log('Generator resumed after first yield.');

  yield 'task_2';

  console.log('Generator completed.');
}

const taskIdGenerator = generateTaskIds();

console.log('Generator was created, but its body has not run yet.');

console.log(taskIdGenerator.next());
console.log(taskIdGenerator.next());
console.log(taskIdGenerator.next());
```

### The Verification

Run:

```bash
npm run appendix:b:debugging
```

Expected output includes this order:

```text
--- 25. generator bodies begin when consumed ---
Generator was created, but its body has not run yet.
Generator body started.
{ value: 'task_1', done: false }
Generator resumed after first yield.
{ value: 'task_2', done: false }
Generator completed.
{ value: undefined, done: true }
```

The order proves that generator code begins only when `.next()` requests the first value.

---

## B.13: Mistake — Forgetting `await` During Asynchronous Work

### The Target

Identify a common async bug: treating a Promise as though it were already the completed value.

### The Concept

An `async` function always returns a Promise.

A Promise is like a claim ticket for a future package. It is not the package itself.

```js
async function getProjectName() {
  return 'Modern JavaScript Toolkit';
}

const result = getProjectName();

// result is a Promise, not the final string.
```

Use `await` inside an `async` context to receive the completed value:

```js
const projectName = await getProjectName();
```

### The Implementation

Append the following code.

### `src/appendices/appendix-b-debugging.js` — append

```js
printSection('26. async functions return Promises');

/**
 * Simulates retrieving a project name.
 *
 * @returns {Promise<string>} Project name.
 */
async function getProjectName() {
  return 'Modern JavaScript Toolkit';
}

const unresolvedProjectName = getProjectName();

console.log({
  unresolvedProjectName,
  isPromise: unresolvedProjectName instanceof Promise
});

const resolvedProjectName = await getProjectName();

console.log({
  resolvedProjectName,
  isPromise: resolvedProjectName instanceof Promise
});

printSection('27. for...of does not await asynchronous values');

/**
 * Produces asynchronous task titles.
 *
 * @returns {AsyncGenerator<string, void, unknown>} Task title stream.
 */
async function* generateAsyncTaskTitles() {
  yield 'Validate input';
  yield 'Transform data';
  yield 'Persist result';
}

const receivedTitles = [];

for await (const title of generateAsyncTaskTitles()) {
  receivedTitles.push(title);
}

console.log({
  receivedTitles,
  explanation:
    'for await...of waits for each asynchronously produced value.'
});

console.log('\nAppendix B debugging examples completed successfully.');
```

### The Verification

Run:

```bash
npm run appendix:b:debugging
```

Expected output ends with:

```text
--- 26. async functions return Promises ---
{
  unresolvedProjectName: Promise { 'Modern JavaScript Toolkit' },
  isPromise: true
}
{
  resolvedProjectName: 'Modern JavaScript Toolkit',
  isPromise: false
}

--- 27. for...of does not await asynchronous values ---
{
  receivedTitles: [ 'Validate input', 'Transform data', 'Persist result' ],
  explanation: 'for await...of waits for each asynchronously produced value.'
}

Appendix B debugging examples completed successfully.
```

Promise formatting differs slightly between Node.js versions. The key fact is that `unresolvedProjectName` is a Promise and `resolvedProjectName` is a string.

---

# Appendix B: Debugging Workflow

When an example or application behaves unexpectedly, use this sequence.

## 1. Read the Full Error Message

Do not stop at:

```text
TypeError
```

Read the message and the file location:

```text
TypeError: Cannot read properties of undefined (reading 'city')
    at getShippingSummary (src/index.js:42:29)
```

This tells you:

- The error category: `TypeError`
- The operation that failed: reading `city`
- The likely missing value: something was `undefined`
- The location: `src/index.js`, line 42

---

## 2. Reduce the Problem

Create the smallest possible reproduction.

Instead of debugging an entire dashboard pipeline, isolate the failing behavior:

```js
const order = {};

const {
  shippingAddress: {
    city
  }
} = order;
```

Then apply one correction:

```js
const {
  shippingAddress: {
    city = 'Not provided'
  } = {}
} = order;
```

Small reproductions make cause and effect visible.

---

## 3. Inspect Values and Types

Use structured logging:

```js
console.log({
  user,
  userType: typeof user,
  hasPreferences: Boolean(user?.preferences)
});
```

For arrays:

```js
console.log({
  tasks,
  taskCount: tasks.length,
  firstTask: tasks.at(0),
  lastTask: tasks.at(-1)
});
```

For Maps:

```js
console.log({
  size: taskStatusById.size,
  entries: [...taskStatusById.entries()]
});
```

Avoid vague logging like:

```js
console.log('here');
```

A good log should answer a question.

---

## 4. Check Whether Mutation Happened

When data unexpectedly changes, compare references and values:

```js
console.log({
  sameArray: originalTasks === updatedTasks,
  sameFirstTask: originalTasks.at(0) === updatedTasks.at(0),
  originalTasks,
  updatedTasks
});
```

If an original collection should remain unchanged, prefer:

```js
const sortedTasks = tasks.toSorted(compareTasks);
const updatedTasks = tasks.with(index, revisedTask);
const reducedTasks = tasks.toSpliced(index, 1);
```

---

## 5. Confirm Runtime Support

When a method “is not a function,” confirm that the runtime supports it:

```js
console.log({
  nodeVersion: process.version,
  supportsToSorted: typeof Array.prototype.toSorted === 'function',
  supportsStructuredClone: typeof structuredClone === 'function'
});
```

Then run Appendix A’s compatibility checker:

```bash
node src/appendices/appendix-a-compatibility-check.js
```

---

# Appendix B Quick Reference

| Symptom | Likely cause | Typical correction |
|---|---|---|
| A variable is unexpectedly available outside an `if` or loop | `var` was used | Use `const` or `let` |
| A `const` object changed | A nested property was mutated | Create an immutable replacement object |
| `Cannot read properties of undefined` during destructuring | A nested parent object is missing | Use a nested `= {}` default or optional chaining |
| Arrow function returns `undefined` instead of an object | Object braces were interpreted as a function body | Use `() => ({ ... })` or explicit `return` |
| Object method reports `this.name` as missing | Arrow function was used as a method | Use concise method syntax |
| A page size of `0` becomes `25` | `||` was used for a fallback | Use `??` |
| Original nested data changes after object spread | Spread produced a shallow copy | Use targeted copying or `structuredClone()` |
| Original array changes after sorting | `.sort()` mutates | Use `.toSorted()` |
| A `Set` does not recognize a matching-looking object | Objects compare by reference | Reuse the same object or use a primitive ID |
| `WeakMap` cannot be looped over | Weak collections are intentionally non-enumerable | Use `Map` when enumeration is required |
| Generator logging does not run immediately | Generators are lazy | Call `.next()` or use `for...of` |
| Value appears as `Promise { ... }` | An async result was not awaited | Use `await` in an async context |
