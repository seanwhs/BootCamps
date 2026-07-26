# Part 3: Next-Generation Collections & Iteration Protocols

Arrays and plain objects are useful, but they are not the best tool for every data problem.

In this part, you will learn modern collection types and the protocols that let JavaScript process values one at a time:

- `Set` for unique values
- `Map` for key-value data with reliable key types
- `WeakSet` and `WeakMap` for object-related metadata that should not prevent garbage collection
- Iterators
- Generator functions with `function*` and `yield`
- Asynchronous iteration with `for await...of`

The central idea is simple:

> Choose the container that matches the data’s rules.

For example, if duplicate permissions are invalid, use a `Set`. If keys are not always strings, use a `Map`. If you need to process a large or ongoing sequence without creating one giant array, use an iterator or generator.

---

## Step 1: Extend the Project Scripts and Directory Structure

### The Target

Add commands for the Part 3 examples and create the directory that will contain them.

### The Concept

Each runnable module gets its own named script. This keeps learning experiments isolated: if one example behaves unexpectedly, you can run only that file instead of scanning output from the entire application.

Think of the project as a toolbox. A named npm script is the label on a drawer telling you exactly where to find one tool.

### The Implementation

Create the Part 3 directory:

```bash
mkdir -p src/part-3-collections-iteration
```

> On Windows PowerShell:

```powershell
mkdir src\part-3-collections-iteration
```

Replace `package.json` with this complete version.

### `package.json`

```json
{
  "name": "modern-javascript-toolkit",
  "version": "1.0.0",
  "private": true,
  "description": "Runnable examples for learning modern ECMAScript features.",
  "type": "module",
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
    "part:3:iteration": "node src/part-3-collections-iteration/iterators-generators.js"
  },
  "engines": {
    "node": ">=22.0.0"
  }
}
```

### The Verification

Run:

```bash
npm run
```

Confirm the output includes:

```text
part:3:sets-maps
part:3:weak-collections
part:3:iteration
```

The commands will become runnable after you create their files in the next steps.

---

## Step 2: Store Unique Values and Flexible Keys with `Set` and `Map`

### The Target

Create `sets-and-maps.js`, which compares Arrays and Objects with `Set` and `Map`.

### The Concept

A `Set` is a collection that stores each value at most once.

Imagine a conference check-in list. A person may try to scan their badge twice, but the attendee list should still contain them only once. That is a `Set`.

```js
const permissions = new Set(['read', 'write', 'read']);

console.log(permissions);
// Set(2) { 'read', 'write' }
```

A `Map` stores key-value pairs, like an object, but its keys can be **any JavaScript value**, including objects, functions, numbers, and `NaN`.

A plain object is most suitable for simple record-like data:

```js
const user = {
  displayName: 'Ava Patel',
  role: 'editor'
};
```

A `Map` is useful when the relationship itself is the focus and keys are dynamic or non-string values:

```js
const sessionByUser = new Map();

sessionByUser.set(userObject, 'session_123');
```

### The Implementation

Create this file.

### `src/part-3-collections-iteration/sets-and-maps.js`

```js
/**
 * Part 3: Set and Map collections.
 *
 * Run directly:
 * node src/part-3-collections-iteration/sets-and-maps.js
 */

/**
 * Prints a readable console section heading.
 *
 * @param {string} title - The heading to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

printSection('Set automatically removes duplicate primitive values');

const requestedTags = [
  'javascript',
  'es2024',
  'learning',
  'javascript',
  'learning'
];

const uniqueTags = new Set(requestedTags);

console.log({
  requestedTags,
  uniqueTags: [...uniqueTags],
  uniqueTagCount: uniqueTags.size
});

printSection('Set membership checks');

const projectPermissions = new Set(['read', 'comment']);

console.log({
  canRead: projectPermissions.has('read'),
  canWriteBeforeAddition: projectPermissions.has('write')
});

projectPermissions.add('write');
projectPermissions.add('write'); // Adding the same primitive twice changes nothing.

console.log({
  permissionsAfterAddition: [...projectPermissions],
  canWriteAfterAddition: projectPermissions.has('write')
});

projectPermissions.delete('comment');

console.log({
  permissionsAfterDeletion: [...projectPermissions],
  hasCommentPermission: projectPermissions.has('comment')
});

printSection('Set iteration preserves insertion order');

const deploymentStages = new Set([
  'validate',
  'build',
  'test',
  'deploy'
]);

for (const stage of deploymentStages) {
  console.log(`Running stage: ${stage}`);
}

printSection('Set equality for objects uses reference identity');

const firstTask = {
  id: 'task_1',
  title: 'Write documentation'
};

const sameLookingTask = {
  id: 'task_1',
  title: 'Write documentation'
};

const taskSet = new Set([firstTask]);

console.log({
  hasFirstTask: taskSet.has(firstTask),
  hasSameLookingTask: taskSet.has(sameLookingTask),
  setSize: taskSet.size
});

// The objects contain matching properties, but they are different objects
// in memory, so Set treats them as different values.
taskSet.add(sameLookingTask);

console.log({
  setSizeAfterAddingSameLookingTask: taskSet.size
});

printSection('deduplicating objects by a meaningful property');

/**
 * Returns unique records based on one chosen property.
 *
 * @param {Array<Record<string, unknown>>} records - Records to deduplicate.
 * @param {string} key - Property used as the uniqueness identifier.
 * @returns {Array<Record<string, unknown>>} Records with duplicate key values removed.
 */
function getUniqueRecordsByKey(records, key) {
  const seenKeys = new Set();

  return records.filter((record) => {
    const value = record[key];

    if (seenKeys.has(value)) {
      return false;
    }

    seenKeys.add(value);

    return true;
  });
}

const taskRecords = [
  {
    id: 'task_1',
    title: 'Plan tutorial'
  },
  {
    id: 'task_2',
    title: 'Write examples'
  },
  {
    id: 'task_1',
    title: 'Plan tutorial duplicate'
  }
];

console.log(getUniqueRecordsByKey(taskRecords, 'id'));

printSection('Map supports reliable key-value relationships');

const userRoleById = new Map();

userRoleById.set('user_1001', 'editor');
userRoleById.set('user_1002', 'reader');

console.log({
  editorRole: userRoleById.get('user_1001'),
  unknownRole: userRoleById.get('user_9999'),
  hasReader: userRoleById.has('user_1002'),
  size: userRoleById.size
});

printSection('Map keys can be objects');

const ava = {
  id: 'user_1001',
  displayName: 'Ava Patel'
};

const mina = {
  id: 'user_1002',
  displayName: 'Mina Chen'
};

const activeSessionByUser = new Map([
  [ava, { sessionId: 'session_abc', startedAt: '2026-07-24T09:00:00.000Z' }],
  [mina, { sessionId: 'session_def', startedAt: '2026-07-24T09:10:00.000Z' }]
]);

console.log(activeSessionByUser.get(ava));

console.log({
  hasAvaSession: activeSessionByUser.has(ava),

  // A new object is not the same key as ava, even if its properties match.
  hasSessionForEquivalentNewObject: activeSessionByUser.has({
    id: 'user_1001',
    displayName: 'Ava Patel'
  })
});

printSection('Map iteration gives [key, value] pairs');

const projectStatusById = new Map([
  ['project_3001', 'active'],
  ['project_3002', 'archived'],
  ['project_3003', 'planning']
]);

for (const [projectId, status] of projectStatusById) {
  console.log(`${projectId}: ${status}`);
}

printSection('converting between Maps and plain objects');

const featureFlagByName = new Map([
  ['newDashboard', true],
  ['compactNavigation', false]
]);

const featureFlagObject = Object.fromEntries(featureFlagByName);
const restoredFeatureFlagMap = new Map(Object.entries(featureFlagObject));

console.log({
  featureFlagObject,
  restoredFeatureFlagEntries: [...restoredFeatureFlagMap.entries()]
});

printSection('practical Map example: grouping tasks by owner');

/**
 * Groups tasks into a Map whose keys are owner IDs.
 *
 * @param {Array<{ id: string, ownerId: string, title: string }>} tasks - Tasks to group.
 * @returns {Map<string, Array<{ id: string, ownerId: string, title: string }>>}
 * A map of owner IDs to their tasks.
 */
function groupTasksByOwner(tasks) {
  const tasksByOwner = new Map();

  for (const task of tasks) {
    const ownerTasks = tasksByOwner.get(task.ownerId) ?? [];

    tasksByOwner.set(task.ownerId, [...ownerTasks, task]);
  }

  return tasksByOwner;
}

const assignedTasks = [
  {
    id: 'task_1',
    ownerId: 'user_1001',
    title: 'Review architecture'
  },
  {
    id: 'task_2',
    ownerId: 'user_1002',
    title: 'Write unit tests'
  },
  {
    id: 'task_3',
    ownerId: 'user_1001',
    title: 'Publish documentation'
  }
];

const tasksByOwner = groupTasksByOwner(assignedTasks);

for (const [ownerId, ownerTasks] of tasksByOwner) {
  console.log(`${ownerId} owns ${ownerTasks.length} task(s):`);

  for (const task of ownerTasks) {
    console.log(`- ${task.title}`);
  }
}

console.log('\nSet and Map examples completed successfully.');
```

### The Verification

Run:

```bash
npm run part:3:sets-maps
```

Expected output includes:

```text
--- Set automatically removes duplicate primitive values ---
{
  requestedTags: [ 'javascript', 'es2024', 'learning', 'javascript', 'learning' ],
  uniqueTags: [ 'javascript', 'es2024', 'learning' ],
  uniqueTagCount: 3
}

--- Set equality for objects uses reference identity ---
{ hasFirstTask: true, hasSameLookingTask: false, setSize: 1 }

--- Map iteration gives [key, value] pairs ---
project_3001: active
project_3002: archived
project_3003: planning

--- practical Map example: grouping tasks by owner ---
user_1001 owns 2 task(s):
- Review architecture
- Publish documentation
user_1002 owns 1 task(s):
- Write unit tests

Set and Map examples completed successfully.
```

---

## Step 3: Associate Temporary Metadata with `WeakSet` and `WeakMap`

### The Target

Create `weak-collections.js`, demonstrating when `WeakSet` and `WeakMap` are safer choices than ordinary `Set` and `Map`.

### The Concept

JavaScript automatically reclaims memory occupied by objects that are no longer reachable by the program. This process is called **garbage collection**.

A normal `Map` keeps a strong reference to every key. If the Map still knows an object, that object cannot be garbage-collected.

A `WeakMap` is different: its object keys are held weakly. If the rest of the application no longer needs a key object, JavaScript may reclaim that object and its associated `WeakMap` value.

Think of a `Map` as a guest list that keeps everyone’s contact details forever. A `WeakMap` is a temporary sticky note attached to a guest: when the guest leaves and no one else remembers them, the note disappears too.

Important limits:

- `WeakMap` keys must be objects or non-registered symbols.
- `WeakSet` values must be objects or non-registered symbols.
- Weak collections are not iterable.
- Weak collections do not expose `.size`.
- You cannot inspect their entire contents because JavaScript needs freedom to garbage-collect entries at unpredictable times.

### The Implementation

Create this file.

### `src/part-3-collections-iteration/weak-collections.js`

```js
/**
 * Part 3: WeakSet and WeakMap collections.
 *
 * Run directly:
 * node src/part-3-collections-iteration/weak-collections.js
 */

/**
 * Prints a readable console section heading.
 *
 * @param {string} title - The heading to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

printSection('WeakSet tracks object membership');

const validatedRequests = new WeakSet();

const firstRequest = {
  requestId: 'req_1001',
  body: {
    displayName: 'Ava Patel'
  }
};

const secondRequest = {
  requestId: 'req_1002',
  body: {
    displayName: 'Mina Chen'
  }
};

validatedRequests.add(firstRequest);

console.log({
  firstRequestWasValidated: validatedRequests.has(firstRequest),
  secondRequestWasValidated: validatedRequests.has(secondRequest)
});

validatedRequests.add(secondRequest);
validatedRequests.delete(firstRequest);

console.log({
  firstRequestWasValidatedAfterDeletion: validatedRequests.has(firstRequest),
  secondRequestWasValidatedAfterAddition: validatedRequests.has(secondRequest)
});

printSection('WeakSet only accepts object-like values');

try {
  validatedRequests.add('req_1003');
} catch (error) {
  console.log({
    errorName: error.name,
    message: error.message
  });
}

printSection('WeakMap stores metadata about objects');

const requestMetadata = new WeakMap();

const incomingRequest = {
  requestId: 'req_2001',
  path: '/api/projects'
};

requestMetadata.set(incomingRequest, {
  receivedAt: '2026-07-24T10:00:00.000Z',
  authenticatedUserId: 'user_1001',
  isRateLimited: false
});

console.log(requestMetadata.get(incomingRequest));

requestMetadata.set(incomingRequest, {
  ...requestMetadata.get(incomingRequest),
  isRateLimited: true
});

console.log(requestMetadata.get(incomingRequest));

printSection('WeakMap does not add fields to the original object');

console.log({
  requestObject: incomingRequest,
  metadataExists: requestMetadata.has(incomingRequest)
});

printSection('a practical private metadata pattern');

const privateProjectState = new WeakMap();

class Project {
  /**
   * @param {string} id - Stable project identifier.
   * @param {string} name - Human-readable project name.
   */
  constructor(id, name) {
    this.id = id;
    this.name = name;

    // Metadata is associated with this exact instance without exposing it
    // as a public property on the instance.
    privateProjectState.set(this, {
      completedTaskCount: 0,
      lastUpdatedAt: null
    });
  }

  /**
   * Records one completed task for this project.
   *
   * @returns {void}
   */
  completeTask() {
    const currentState = privateProjectState.get(this);

    privateProjectState.set(this, {
      completedTaskCount: currentState.completedTaskCount + 1,
      lastUpdatedAt: new Date().toISOString()
    });
  }

  /**
   * Returns a controlled public summary.
   *
   * @returns {{ id: string, name: string, completedTaskCount: number, lastUpdatedAt: string | null }}
   */
  getSummary() {
    const state = privateProjectState.get(this);

    return {
      id: this.id,
      name: this.name,
      completedTaskCount: state.completedTaskCount,
      lastUpdatedAt: state.lastUpdatedAt
    };
  }
}

const project = new Project('project_3001', 'Modern JavaScript Toolkit');

console.log(project.getSummary());

project.completeTask();
project.completeTask();

console.log(project.getSummary());

// The internal state is not a normal property of the instance.
console.log({
  publicProperties: Object.keys(project),
  exposesPrivateStateAsProperty: 'privateProjectState' in project
});

printSection('why WeakMap is intentionally not iterable');

console.log({
  hasSizeProperty: 'size' in requestMetadata,
  hasIteratorMethod: Symbol.iterator in requestMetadata,
  explanation:
    'WeakMap entries cannot be enumerated because their keys may be garbage-collected at any time.'
});

printSection('when a normal Map is the correct choice');

const activeConnectionById = new Map([
  ['connection_1', { userId: 'user_1001', status: 'connected' }],
  ['connection_2', { userId: 'user_1002', status: 'connected' }]
]);

console.log({
  connectionCount: activeConnectionById.size,
  connectionIds: [...activeConnectionById.keys()]
});

console.log('\nWeakSet and WeakMap examples completed successfully.');
```

### The Verification

Run:

```bash
npm run part:3:weak-collections
```

Expected output includes:

```text
--- WeakSet tracks object membership ---
{
  firstRequestWasValidated: true,
  secondRequestWasValidated: false
}

--- WeakSet only accepts object-like values ---
{
  errorName: 'TypeError',
  message: 'Invalid value used in weak set'
}

--- WeakMap does not add fields to the original object ---
{
  requestObject: { requestId: 'req_2001', path: '/api/projects' },
  metadataExists: true
}

--- why WeakMap is intentionally not iterable ---
{
  hasSizeProperty: false,
  hasIteratorMethod: false,
  explanation: 'WeakMap entries cannot be enumerated because their keys may be garbage-collected at any time.'
}

WeakSet and WeakMap examples completed successfully.
```

The precise TypeError message can vary between JavaScript runtimes. The important result is that a `TypeError` is reported.

---

## Step 4: Process Values One at a Time with Iterators, Generators, and Async Iteration

### The Target

Create `iterators-generators.js`, which demonstrates:

- The iterable protocol
- The iterator protocol
- Custom iterables
- Generator functions
- `yield`
- Generator cleanup with `finally`
- Async generators
- `for await...of`

### The Concept

An **iterable** is a value that JavaScript can loop through with `for...of`.

Arrays are iterable:

```js
for (const value of ['a', 'b', 'c']) {
  console.log(value);
}
```

An iterable provides an **iterator**. An iterator is an object with a `.next()` method. Every call to `.next()` asks:

> “Do you have another item?”

The result has this shape:

```js
{
  value: 'next item',
  done: false
}
```

When the sequence ends:

```js
{
  value: undefined,
  done: true
}
```

A **generator function** is a simpler way to create an iterator. It uses `function*` and `yield`.

Think of a generator as a bakery counter. Instead of baking and placing 10,000 loaves on the counter at once, it provides one loaf each time a customer asks.

An **async generator** does the same thing for values that arrive over time, such as paginated API data, file chunks, or messages from a stream.

### The Implementation

Create this file.

### `src/part-3-collections-iteration/iterators-generators.js`

```js
/**
 * Part 3: Iterators, generators, and asynchronous iteration.
 *
 * Run directly:
 * node src/part-3-collections-iteration/iterators-generators.js
 */

/**
 * Prints a readable console section heading.
 *
 * @param {string} title - The heading to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

printSection('built-in arrays are iterable');

const releaseStages = ['validate', 'build', 'test', 'deploy'];

for (const stage of releaseStages) {
  console.log(`Stage: ${stage}`);
}

printSection('manually using an array iterator');

const stageIterator = releaseStages[Symbol.iterator]();

console.log(stageIterator.next());
console.log(stageIterator.next());
console.log(stageIterator.next());
console.log(stageIterator.next());
console.log(stageIterator.next());

printSection('custom iterable: a paginated collection');

/**
 * Creates an iterable that yields pages of items.
 *
 * @param {unknown[]} items - Items to split into pages.
 * @param {number} pageSize - Positive number of items per page.
 * @returns {{ [Symbol.iterator]: () => Iterator<unknown[]> }} An iterable page source.
 * @throws {RangeError} When pageSize is not a positive integer.
 */
function createPaginatedIterable(items, pageSize) {
  if (!Number.isInteger(pageSize) || pageSize <= 0) {
    throw new RangeError('pageSize must be a positive integer.');
  }

  return {
    [Symbol.iterator]() {
      let currentStartIndex = 0;

      return {
        next() {
          if (currentStartIndex >= items.length) {
            return {
              value: undefined,
              done: true
            };
          }

          const page = items.slice(
            currentStartIndex,
            currentStartIndex + pageSize
          );

          currentStartIndex += pageSize;

          return {
            value: page,
            done: false
          };
        }
      };
    }
  };
}

const taskPages = createPaginatedIterable(
  [
    'Write introduction',
    'Create examples',
    'Run verification',
    'Review content',
    'Publish tutorial'
  ],
  2
);

for (const page of taskPages) {
  console.log(page);
}

printSection('generator function basics');

/**
 * Yields each deployment stage in order.
 *
 * @returns {Generator<string, void, unknown>} A stage generator.
 */
function* generateDeploymentStages() {
  yield 'validate';
  yield 'build';
  yield 'test';
  yield 'deploy';
}

const deploymentStageGenerator = generateDeploymentStages();

console.log(deploymentStageGenerator.next());
console.log(deploymentStageGenerator.next());

for (const remainingStage of deploymentStageGenerator) {
  console.log(`Remaining stage: ${remainingStage}`);
}

printSection('generators can produce values lazily');

/**
 * Produces sequential ticket numbers without building an infinite array.
 *
 * @param {number} startAt - First ticket number.
 * @returns {Generator<number, void, unknown>} An unbounded number generator.
 */
function* generateTicketNumbers(startAt = 1) {
  let currentTicketNumber = startAt;

  while (true) {
    yield currentTicketNumber;
    currentTicketNumber += 1;
  }
}

const ticketNumbers = generateTicketNumbers(500);

console.log({
  firstTicket: ticketNumbers.next().value,
  secondTicket: ticketNumbers.next().value,
  thirdTicket: ticketNumbers.next().value
});

printSection('yield can receive values from next()');

/**
 * Tracks a running total based on values sent through next().
 *
 * @returns {Generator<number, void, number>} A running-total generator.
 */
function* createRunningTotal() {
  let total = 0;

  while (true) {
    const valueToAdd = yield total;

    if (typeof valueToAdd === 'number' && Number.isFinite(valueToAdd)) {
      total += valueToAdd;
    }
  }
}

const runningTotal = createRunningTotal();

console.log(runningTotal.next());
console.log(runningTotal.next(5));
console.log(runningTotal.next(12));
console.log(runningTotal.next(-2));

printSection('finally runs when a generator is closed early');

/**
 * Simulates a resource-backed sequence that needs cleanup.
 *
 * @returns {Generator<string, void, unknown>} A generator with cleanup.
 */
function* generateResourceSteps() {
  console.log('Resource opened.');

  try {
    yield 'Read configuration';
    yield 'Process records';
    yield 'Write results';
  } finally {
    // This runs if the generator finishes naturally or if return() closes it.
    console.log('Resource cleanup completed.');
  }
}

const resourceSteps = generateResourceSteps();

console.log(resourceSteps.next());
console.log(resourceSteps.return());

printSection('async generator and for await...of');

/**
 * Pauses for a chosen duration.
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
 * Simulates pages arriving from an asynchronous data source.
 *
 * In a production system, each yield could represent a database cursor page,
 * a paginated HTTP API response, or messages from a streaming service.
 *
 * @returns {AsyncGenerator<Array<{ id: string, title: string }>, void, unknown>}
 * An async sequence of task pages.
 */
async function* fetchTaskPages() {
  await delay(10);

  yield [
    {
      id: 'task_1',
      title: 'Validate input'
    },
    {
      id: 'task_2',
      title: 'Transform data'
    }
  ];

  await delay(10);

  yield [
    {
      id: 'task_3',
      title: 'Persist results'
    }
  ];
}

const receivedTaskTitles = [];

for await (const taskPage of fetchTaskPages()) {
  console.log(`Received page with ${taskPage.length} task(s).`);

  for (const task of taskPage) {
    receivedTaskTitles.push(task.title);
  }
}

console.log({
  receivedTaskTitles,
  receivedTaskCount: receivedTaskTitles.length
});

printSection('async iteration can stop early');

/**
 * Produces events over time.
 *
 * @returns {AsyncGenerator<{ id: string, type: string }, void, unknown>}
 * A generated stream of events.
 */
async function* generateEvents() {
  const events = [
    {
      id: 'event_1',
      type: 'project.created'
    },
    {
      id: 'event_2',
      type: 'task.completed'
    },
    {
      id: 'event_3',
      type: 'project.archived'
    }
  ];

  for (const event of events) {
    await delay(5);
    yield event;
  }
}

for await (const event of generateEvents()) {
  console.log(`Received event: ${event.type}`);

  if (event.type === 'task.completed') {
    console.log('Stopping after the target event.');
    break;
  }
}

console.log('\nIterator and generator examples completed successfully.');
```

### The Verification

Run:

```bash
npm run part:3:iteration
```

Expected output includes:

```text
--- manually using an array iterator ---
{ value: 'validate', done: false }
{ value: 'build', done: false }
{ value: 'test', done: false }
{ value: 'deploy', done: false }
{ value: undefined, done: true }

--- generator function basics ---
{ value: 'validate', done: false }
{ value: 'build', done: false }
Remaining stage: test
Remaining stage: deploy

--- async generator and for await...of ---
Received page with 2 task(s).
Received page with 1 task(s).
{
  receivedTaskTitles: [ 'Validate input', 'Transform data', 'Persist results' ],
  receivedTaskCount: 3
}

--- async iteration can stop early ---
Received event: project.created
Received event: task.completed
Stopping after the target event.

Iterator and generator examples completed successfully.
```

---

## Step 5: Integrate Collections and Iteration into the Toolkit Entry Point

### The Target

Update `src/index.js` so the central toolkit uses:

- `Set` to deduplicate tags
- `Map` to group tasks by owner
- An async generator to process task pages incrementally

### The Concept

Real applications often receive data in batches rather than all at once. A server may return paginated data; a queue may deliver messages over time.

This step treats incoming task pages like packages arriving at a warehouse. The async generator delivers one package at a time. The dashboard processes each package, tracks unique tags with a `Set`, and organizes tasks into owner-specific bins with a `Map`.

### The Implementation

Replace `src/index.js` with the following complete version.

### `src/index.js`

```js
/**
 * Modern JavaScript Toolkit entry point.
 *
 * Run with:
 * npm start
 */

/**
 * Pauses for a chosen duration.
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
 * Simulates asynchronously delivered pages of project tasks.
 *
 * @returns {AsyncGenerator<Array<{
 *   id: string,
 *   ownerId: string,
 *   title: string,
 *   completed: boolean,
 *   tags: string[]
 * }>, void, unknown>} Task pages.
 */
async function* fetchProjectTaskPages() {
  await delay(10);

  yield [
    {
      id: 'task_1',
      ownerId: 'user_1001',
      title: 'Create Part 1 examples',
      completed: true,
      tags: ['javascript', 'syntax']
    },
    {
      id: 'task_2',
      ownerId: 'user_1001',
      title: 'Create Part 2 examples',
      completed: true,
      tags: ['javascript', 'functions']
    }
  ];

  await delay(10);

  yield [
    {
      id: 'task_3',
      ownerId: 'user_1002',
      title: 'Document collection types',
      completed: false,
      tags: ['collections', 'javascript']
    }
  ];
}

/**
 * Builds a project dashboard by consuming asynchronous task pages.
 *
 * @param {{
 *   id: string,
 *   name: string,
 *   owner: { displayName: string },
 *   tags?: string[]
 * }} project - Core project data.
 * @returns {Promise<{
 *   id: string,
 *   name: string,
 *   ownerName: string,
 *   tags: string[],
 *   completedTaskCount: number,
 *   pendingTaskTitles: string[],
 *   taskCountByOwner: Map<string, number>,
 *   label: string
 * }>} Dashboard data.
 */
async function createProjectDashboard(project) {
  const {
    id,
    name,
    owner: {
      displayName: ownerName
    },
    tags: projectTags = []
  } = project;

  const uniqueTags = new Set(projectTags);
  const taskCountByOwner = new Map();
  const pendingTaskTitles = [];
  let completedTaskCount = 0;

  for await (const taskPage of fetchProjectTaskPages()) {
    for (const task of taskPage) {
      for (const tag of task.tags) {
        uniqueTags.add(tag);
      }

      const currentOwnerTaskCount = taskCountByOwner.get(task.ownerId) ?? 0;

      taskCountByOwner.set(task.ownerId, currentOwnerTaskCount + 1);

      if (task.completed) {
        completedTaskCount += 1;
      } else {
        pendingTaskTitles.push(task.title);
      }
    }
  }

  return {
    id,
    name,
    ownerName,
    tags: [...uniqueTags],
    completedTaskCount,
    pendingTaskTitles,
    taskCountByOwner,
    label: `${name} — owned by ${ownerName}`
  };
}

/**
 * Converts a Map to a plain object suitable for JSON-like console output.
 *
 * @param {Map<string, number>} taskCountByOwner - Owner task-count map.
 * @returns {Record<string, number>} A serializable task-count object.
 */
function serializeTaskCountByOwner(taskCountByOwner) {
  return Object.fromEntries(taskCountByOwner);
}

const project = {
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit',
  owner: {
    displayName: 'Ava Patel'
  },
  tags: ['learning', 'es2024']
};

console.log('\n=== Modern JavaScript Toolkit ===\n');
console.log('Loading asynchronous task pages...');

const dashboard = await createProjectDashboard(project);

console.log('\nProject dashboard:');
console.log({
  id: dashboard.id,
  label: dashboard.label,
  tags: dashboard.tags,
  completedTaskCount: dashboard.completedTaskCount,
  pendingTaskTitles: dashboard.pendingTaskTitles,
  taskCountByOwner: serializeTaskCountByOwner(dashboard.taskCountByOwner)
});

console.log('\nParts 1 through 3 are running successfully.');
```

### The Verification

Run:

```bash
npm start
```

Expected output:

```text
=== Modern JavaScript Toolkit ===

Loading asynchronous task pages...

Project dashboard:
{
  id: 'project_3001',
  label: 'Modern JavaScript Toolkit — owned by Ava Patel',
  tags: [ 'learning', 'es2024', 'javascript', 'syntax', 'functions', 'collections' ],
  completedTaskCount: 2,
  pendingTaskTitles: [ 'Document collection types' ],
  taskCountByOwner: { user_1001: 2, user_1002: 1 }
}

Parts 1 through 3 are running successfully.
```

---

# Part 3 Reference: Collections and Iteration Protocols

## Choosing the Right Collection

| Need | Recommended type | Why |
|---|---|---|
| Ordered list, possibly with duplicates | `Array` | Supports indexed access and common transformations |
| Simple record with known string property names | Plain object | Clear dot-property access such as `user.name` |
| Unique values | `Set` | Prevents duplicate values |
| Arbitrary key-value relationships | `Map` | Keys can be objects, functions, numbers, and more |
| Object membership that should not keep objects alive | `WeakSet` | Weakly references objects |
| Hidden metadata attached to object instances | `WeakMap` | Weakly associates values with object keys |
| Values produced one at a time | Iterator or generator | Avoids eagerly building a complete collection |
| Values produced asynchronously | Async iterator or async generator | Handles paginated or streamed data naturally |

---

## `Set` API Quick Reference

```js
const values = new Set(['a', 'b']);
```

Add:

```js
values.add('c');
```

Check membership:

```js
values.has('a'); // true
```

Delete:

```js
values.delete('b'); // true
```

Count values:

```js
values.size;
```

Convert to an array:

```js
const arrayValues = [...values];
```

Clear all values:

```js
values.clear();
```

A `Set` compares primitive values by value-like identity and objects by reference identity:

```js
const first = { id: 'task_1' };
const second = { id: 'task_1' };

const values = new Set([first]);

values.has(first); // true
values.has(second); // false
```

---

## `Map` API Quick Reference

```js
const values = new Map();
```

Set a value:

```js
values.set('user_1001', 'editor');
```

Read a value:

```js
values.get('user_1001'); // 'editor'
```

Check for a key:

```js
values.has('user_1001'); // true
```

Delete a key:

```js
values.delete('user_1001'); // true
```

Count entries:

```js
values.size;
```

Iterate entries:

```js
for (const [key, value] of values) {
  console.log(key, value);
}
```

Create an object from string-keyed map entries:

```js
const objectValue = Object.fromEntries(values);
```

Create a Map from object entries:

```js
const mapValue = new Map(Object.entries(objectValue));
```

Do not use `map.get(key) ?? defaultValue` if `undefined` is a meaningful stored value and you must distinguish “missing key” from “key mapped to `undefined`.” Use `.has()` first in that specific case:

```js
const settings = new Map([
  ['optionalSetting', undefined]
]);

const value = settings.has('optionalSetting')
  ? settings.get('optionalSetting')
  : 'default';
```

---

## `WeakSet` and `WeakMap` Rules

`WeakSet` accepts only object-like values:

```js
const processed = new WeakSet();
const request = {};

processed.add(request);
```

`WeakMap` accepts only object-like keys:

```js
const metadataByRequest = new WeakMap();
const request = {};

metadataByRequest.set(request, {
  validated: true
});
```

Weak collections cannot be enumerated:

```js
// [...metadataByRequest]; // TypeError
// metadataByRequest.size; // undefined
```

Use them when the object itself determines the metadata lifetime.

Do not use them when you need to:

- List all entries
- Count entries
- Serialize entries
- Query values by a primitive ID
- Retain the collection as a durable application data store

---

## Iterator Protocol

An iterator has a `next()` method returning:

```js
{
  value: 'some value',
  done: false
}
```

At the end:

```js
{
  value: undefined,
  done: true
}
```

An iterable provides a method at `Symbol.iterator` that returns an iterator:

```js
const iterable = {
  [Symbol.iterator]() {
    let value = 1;

    return {
      next() {
        if (value > 3) {
          return {
            value: undefined,
            done: true
          };
        }

        const currentValue = value;
        value += 1;

        return {
          value: currentValue,
          done: false
        };
      }
    };
  }
};
```

Because it is iterable, it works with `for...of`:

```js
for (const value of iterable) {
  console.log(value);
}
```

---

## Generator Function Quick Reference

Define a generator with `function*`:

```js
function* generateNumbers() {
  yield 1;
  yield 2;
  yield 3;
}
```

Consume it:

```js
for (const number of generateNumbers()) {
  console.log(number);
}
```

Generators are lazy. The body starts when `.next()` is first called, not when the generator is created:

```js
const numbers = generateNumbers();

numbers.next(); // Starts generator and receives 1.
```

An infinite generator is practical only when the consumer controls how much to read:

```js
function* generateIds() {
  let currentId = 1;

  while (true) {
    yield currentId;
    currentId += 1;
  }
}
```

Use a `finally` block when a generator manages a resource that needs cleanup:

```js
function* generateItems() {
  openResource();

  try {
    yield 'item';
  } finally {
    closeResource();
  }
}
```

---

## Async Iteration Quick Reference

Create an async generator with `async function*`:

```js
async function* fetchPages() {
  yield ['first page'];
  yield ['second page'];
}
```

Consume it with `for await...of`:

```js
for await (const page of fetchPages()) {
  console.log(page);
}
```

Use async iteration for:

- Paginated HTTP responses
- Database cursor results
- Streamed file data
- Queue messages
- WebSocket events
- Incremental processing pipelines

A `for await...of` loop can consume both async iterables and ordinary synchronous iterables, although use ordinary `for...of` when no asynchronous work is involved.
