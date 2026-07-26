# Appendix E: Exercises and Complete Solutions

This appendix provides hands-on exercises covering the complete modern JavaScript series.

Each exercise includes:

1. **The Target** — what you will build.
2. **The Concept** — the language features being practiced.
3. **The Challenge** — requirements to solve independently.
4. **The Solution** — complete working code.
5. **The Verification** — a repeatable command or automated test.

Try each challenge before reading its solution. The complete exercise runner at the end of the first section verifies every solution automatically.

---

## E.1: Create the Exercise Runner

### The Target

Create a single runnable module containing all exercise solutions and automated tests.

### The Concept

Automated tests are repeatable checks that compare actual program behavior with expected behavior.

Think of a test as a checklist for a completed task. Instead of visually inspecting every output by hand, the program verifies important facts for you:

- Did sensitive data stay private?
- Did duplicate values get removed?
- Did an immutable update leave the source data unchanged?
- Did an async pipeline process every page in order?

### The Implementation

Add this npm script to the existing `"scripts"` object in `package.json`:

### `package.json` — scripts addition

```json
{
  "scripts": {
    "appendix:e:exercises": "node src/appendices/appendix-e-exercises.js"
  }
}
```

> Keep your existing scripts. Add only the new `appendix:e:exercises` property inside the existing `"scripts"` object.

Create the following complete file.

### `src/appendices/appendix-e-exercises.js`

```js
/**
 * Appendix E: Exercises and complete solutions.
 *
 * Run with:
 * npm run appendix:e:exercises
 */

import assert from 'node:assert/strict';

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
 * Runs a synchronous or asynchronous test and reports success.
 *
 * @param {string} description - Test description.
 * @param {() => void | Promise<void>} test - Test operation.
 * @returns {Promise<void>} Completion promise.
 */
async function runTest(description, test) {
  await test();

  console.log(`✓ ${description}`);
}

/**
 * Waits for a chosen duration.
 *
 * @param {number} milliseconds - Number of milliseconds to wait.
 * @returns {Promise<void>} Promise resolved after the delay.
 */
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

/**
 * Exercise 1 solution:
 * Creates a safe public profile that excludes sensitive data.
 *
 * @param {{
 *   id: string,
 *   displayName: string,
 *   email: string,
 *   passwordHash: string,
 *   roles?: string[]
 * }} user - Complete internal user record.
 * @returns {{
 *   id: string,
 *   displayName: string,
 *   email: string,
 *   roles: string[],
 *   label: string
 * }} Public user profile.
 */
function createPublicProfile({
  passwordHash,
  roles = [],
  ...publicUser
}) {
  return {
    ...publicUser,
    roles: [...new Set(roles)],
    label: `${publicUser.displayName} <${publicUser.email}>`
  };
}

/**
 * Exercise 2 solution:
 * Creates a concise task summary using expressive modern syntax.
 *
 * @param {{
 *   id: string,
 *   title: string,
 *   completed: boolean,
 *   priority: number
 * }} task - Task to summarize.
 * @returns {{
 *   id: string,
 *   title: string,
 *   status: string,
 *   priority: number,
 *   [key: string]: string | number
 * }} Task summary.
 */
const createTaskSummary = ({
  id,
  title,
  completed,
  priority
}) => {
  const status = completed ? 'completed' : 'pending';
  const priorityKey = `priority_${priority}`;

  return {
    id,
    title,
    status,
    priority,
    [priorityKey]: `${title} is ${status}.`
  };
};

/**
 * Exercise 3 solution:
 * Groups unique task IDs by owner.
 *
 * @param {Array<{
 *   id: string,
 *   ownerId: string,
 *   title: string
 * }>} tasks - Tasks to group.
 * @returns {Map<string, string[]>} Owner IDs mapped to unique task IDs.
 */
function groupUniqueTaskIdsByOwner(tasks) {
  const seenTaskIds = new Set();
  const taskIdsByOwner = new Map();

  for (const { id, ownerId } of tasks) {
    if (seenTaskIds.has(id)) {
      continue;
    }

    seenTaskIds.add(id);

    const ownerTaskIds = taskIdsByOwner.get(ownerId) ?? [];

    taskIdsByOwner.set(ownerId, [...ownerTaskIds, id]);
  }

  return taskIdsByOwner;
}

/**
 * Exercise 4 solution:
 * Produces task pages lazily.
 *
 * @param {Array<{
 *   id: string,
 *   title: string
 * }>} tasks - Tasks to split into pages.
 * @param {number} pageSize - Maximum number of tasks per page.
 * @returns {Generator<Array<{
 *   id: string,
 *   title: string
 * }>, void, unknown>} Generator of task pages.
 * @throws {RangeError} When pageSize is not a positive integer.
 */
function* generateTaskPages(tasks, pageSize) {
  if (!Number.isInteger(pageSize) || pageSize <= 0) {
    throw new RangeError('pageSize must be a positive integer.');
  }

  for (
    let startIndex = 0;
    startIndex < tasks.length;
    startIndex += pageSize
  ) {
    yield tasks.slice(startIndex, startIndex + pageSize);
  }
}

/**
 * Exercise 5 solution:
 * Asynchronously yields task pages in their original order.
 *
 * @param {Array<Array<{
 *   id: string,
 *   title: string
 * }>>} taskPages - Pages to stream.
 * @returns {AsyncGenerator<Array<{
 *   id: string,
 *   title: string
 * }>, void, unknown>} Async generator of task pages.
 */
async function* streamTaskPages(taskPages) {
  for (const taskPage of taskPages) {
    await delay(1);

    yield taskPage;
  }
}

/**
 * Exercise 6 solution:
 * Applies defaults only when values are null or undefined.
 *
 * @param {{
 *   colorScheme?: string | null,
 *   pageSize?: number | null,
 *   showCompletedTasks?: boolean | null,
 *   timezone?: string | null
 * }} settings - Partial settings.
 * @returns {{
 *   colorScheme: string,
 *   pageSize: number,
 *   showCompletedTasks: boolean,
 *   timezone: string
 * }} Normalized settings.
 */
function normalizeSettings(settings = {}) {
  const normalizedSettings = {
    ...settings
  };

  normalizedSettings.colorScheme ??= 'system';
  normalizedSettings.pageSize ??= 25;
  normalizedSettings.showCompletedTasks ??= true;
  normalizedSettings.timezone ??= 'UTC';

  return normalizedSettings;
}

/**
 * Exercise 7 solution:
 * Returns a revised task array with one task marked complete.
 *
 * @param {Array<{
 *   id: string,
 *   title: string,
 *   completed: boolean,
 *   priority: number
 * }>} tasks - Source tasks.
 * @param {string} taskId - ID of task to complete.
 * @returns {Array<{
 *   id: string,
 *   title: string,
 *   completed: boolean,
 *   priority: number
 * }>} Revised task array.
 * @throws {RangeError} When taskId does not exist.
 */
function completeTaskById(tasks, taskId) {
  const taskIndex = tasks.findIndex((task) => task.id === taskId);

  if (taskIndex === -1) {
    throw new RangeError(`Task "${taskId}" does not exist.`);
  }

  const existingTask = tasks.at(taskIndex);

  return tasks.with(taskIndex, {
    ...existingTask,
    completed: true
  });
}

/**
 * Exercise 8 solution:
 * Creates a dashboard from incomplete project data and async task pages.
 *
 * @param {{
 *   id?: string,
 *   name?: string,
 *   owner?: {
 *     displayName?: string | null
 *   } | null,
 *   tags?: string[] | null,
 *   settings?: {
 *     pageSize?: number | null
 *   } | null
 * }} project - Potentially incomplete project data.
 * @param {AsyncIterable<Array<{
 *   id: string,
 *   ownerId: string,
 *   title: string,
 *   completed: boolean,
 *   priority: number,
 *   tags?: string[]
 * }>>} taskPages - Asynchronously delivered task pages.
 * @returns {Promise<{
 *   id: string,
 *   label: string,
 *   settings: { pageSize: number },
 *   tags: string[],
 *   completedTaskCount: number,
 *   pendingTaskTitles: string[],
 *   taskCountByOwner: Map<string, number>,
 *   tasksByPriority: Array<{
 *     id: string,
 *     ownerId: string,
 *     title: string,
 *     completed: boolean,
 *     priority: number,
 *     tags?: string[]
 *   }>
 * }>} Dashboard data.
 */
async function createDashboard(project, taskPages) {
  const {
    id = 'unknown-project',
    name = 'Untitled project',
    owner = null,
    tags: projectTags = [],
    settings = {}
  } = project;

  const uniqueTags = new Set(projectTags ?? []);
  const taskCountByOwner = new Map();
  const tasks = [];

  for await (const taskPage of taskPages) {
    for (const task of taskPage) {
      tasks.push(task);

      for (const tag of task.tags ?? []) {
        uniqueTags.add(tag);
      }

      const currentOwnerTaskCount =
        taskCountByOwner.get(task.ownerId) ?? 0;

      taskCountByOwner.set(
        task.ownerId,
        currentOwnerTaskCount + 1
      );
    }
  }

  const completedTaskCount = tasks.filter((task) => {
    return task.completed;
  }).length;

  const pendingTaskTitles = tasks
    .filter((task) => !task.completed)
    .map((task) => task.title);

  const tasksByPriority = tasks.toSorted((firstTask, secondTask) => {
    const priorityDifference =
      firstTask.priority - secondTask.priority;

    if (priorityDifference !== 0) {
      return priorityDifference;
    }

    return firstTask.title.localeCompare(secondTask.title);
  });

  return {
    id,
    label: `${name} — owned by ${
      owner?.displayName ?? 'Unassigned owner'
    }`,
    settings: {
      pageSize: settings?.pageSize ?? 25
    },
    tags: [...uniqueTags],
    completedTaskCount,
    pendingTaskTitles,
    taskCountByOwner,
    tasksByPriority
  };
}

printSection('Exercise 1: Public profile');

await runTest(
  'Removes passwordHash and preserves unique roles',
  () => {
    const profile = createPublicProfile({
      id: 'user_1001',
      displayName: 'Ava Patel',
      email: 'ava@example.com',
      passwordHash: 'do-not-expose',
      roles: ['reader', 'editor', 'reader']
    });

    assert.deepEqual(profile, {
      id: 'user_1001',
      displayName: 'Ava Patel',
      email: 'ava@example.com',
      roles: ['reader', 'editor'],
      label: 'Ava Patel <ava@example.com>'
    });

    assert.equal('passwordHash' in profile, false);
  }
);

printSection('Exercise 2: Expressive task summary');

await runTest(
  'Creates a status and computed priority message',
  () => {
    const summary = createTaskSummary({
      id: 'task_1',
      title: 'Write documentation',
      completed: false,
      priority: 2
    });

    assert.deepEqual(summary, {
      id: 'task_1',
      title: 'Write documentation',
      status: 'pending',
      priority: 2,
      priority_2: 'Write documentation is pending.'
    });
  }
);

printSection('Exercise 3: Set and Map collections');

await runTest(
  'Groups only unique task IDs by owner',
  () => {
    const groupedTaskIds = groupUniqueTaskIdsByOwner([
      {
        id: 'task_1',
        ownerId: 'user_1001',
        title: 'Write examples'
      },
      {
        id: 'task_2',
        ownerId: 'user_1002',
        title: 'Review examples'
      },
      {
        id: 'task_1',
        ownerId: 'user_1001',
        title: 'Duplicate task record'
      }
    ]);

    assert.deepEqual(
      [...groupedTaskIds.entries()],
      [
        ['user_1001', ['task_1']],
        ['user_1002', ['task_2']]
      ]
    );
  }
);

printSection('Exercise 4: Generator pagination');

await runTest(
  'Creates synchronous task pages',
  () => {
    const pages = [
      ...generateTaskPages(
        [
          {
            id: 'task_1',
            title: 'First'
          },
          {
            id: 'task_2',
            title: 'Second'
          },
          {
            id: 'task_3',
            title: 'Third'
          }
        ],
        2
      )
    ];

    assert.deepEqual(pages, [
      [
        {
          id: 'task_1',
          title: 'First'
        },
        {
          id: 'task_2',
          title: 'Second'
        }
      ],
      [
        {
          id: 'task_3',
          title: 'Third'
        }
      ]
    ]);
  }
);

await runTest(
  'Rejects an invalid page size',
  () => {
    assert.throws(
      () => [...generateTaskPages([], 0)],
      {
        name: 'RangeError',
        message: 'pageSize must be a positive integer.'
      }
    );
  }
);

printSection('Exercise 5: Async iteration');

await runTest(
  'Consumes asynchronously streamed task pages',
  async () => {
    const receivedTaskIds = [];

    for await (const taskPage of streamTaskPages([
      [
        {
          id: 'task_1',
          title: 'First'
        }
      ],
      [
        {
          id: 'task_2',
          title: 'Second'
        }
      ]
    ])) {
      receivedTaskIds.push(
        ...taskPage.map((task) => task.id)
      );
    }

    assert.deepEqual(receivedTaskIds, ['task_1', 'task_2']);
  }
);

printSection('Exercise 6: Defensive configuration');

await runTest(
  'Preserves meaningful falsy settings values',
  () => {
    const settings = normalizeSettings({
      colorScheme: null,
      pageSize: 0,
      showCompletedTasks: false,
      timezone: ''
    });

    assert.deepEqual(settings, {
      colorScheme: 'system',
      pageSize: 0,
      showCompletedTasks: false,
      timezone: ''
    });
  }
);

printSection('Exercise 7: Immutable task completion');

await runTest(
  'Completes a task without mutating the source array',
  () => {
    const tasks = [
      {
        id: 'task_1',
        title: 'Write examples',
        completed: false,
        priority: 1
      },
      {
        id: 'task_2',
        title: 'Review examples',
        completed: false,
        priority: 2
      }
    ];

    const revisedTasks = completeTaskById(tasks, 'task_2');

    assert.equal(tasks.at(1).completed, false);
    assert.equal(revisedTasks.at(1).completed, true);
    assert.notEqual(tasks, revisedTasks);
    assert.notEqual(tasks.at(1), revisedTasks.at(1));
  }
);

printSection('Exercise 8: Integrated async dashboard');

await runTest(
  'Builds a safe, sorted dashboard from async pages',
  async () => {
    const dashboard = await createDashboard(
      {
        id: 'project_3001',
        name: 'Modern JavaScript Toolkit',
        owner: {
          displayName: 'Ava Patel'
        },
        tags: ['learning', 'javascript', 'javascript'],
        settings: {
          pageSize: 0
        }
      },
      streamTaskPages([
        [
          {
            id: 'task_1',
            ownerId: 'user_1001',
            title: 'Write examples',
            completed: true,
            priority: 2,
            tags: ['syntax', 'javascript']
          }
        ],
        [
          {
            id: 'task_2',
            ownerId: 'user_1002',
            title: 'Review examples',
            completed: false,
            priority: 1,
            tags: ['review']
          }
        ]
      ])
    );

    assert.equal(
      dashboard.label,
      'Modern JavaScript Toolkit — owned by Ava Patel'
    );

    assert.deepEqual(dashboard.settings, {
      pageSize: 0
    });

    assert.deepEqual(dashboard.tags, [
      'learning',
      'javascript',
      'syntax',
      'review'
    ]);

    assert.equal(dashboard.completedTaskCount, 1);

    assert.deepEqual(dashboard.pendingTaskTitles, [
      'Review examples'
    ]);

    assert.deepEqual(
      [...dashboard.taskCountByOwner.entries()],
      [
        ['user_1001', 1],
        ['user_1002', 1]
      ]
    );

    assert.deepEqual(
      dashboard.tasksByPriority.map((task) => task.id),
      ['task_2', 'task_1']
    );
  }
);

console.log('\nAll Appendix E exercise solutions passed successfully.');
```

### The Verification

Run:

```bash
npm run appendix:e:exercises
```

Expected output:

```text
--- Exercise 1: Public profile ---
✓ Removes passwordHash and preserves unique roles

--- Exercise 2: Expressive task summary ---
✓ Creates a status and computed priority message

--- Exercise 3: Set and Map collections ---
✓ Groups only unique task IDs by owner

--- Exercise 4: Generator pagination ---
✓ Creates synchronous task pages
✓ Rejects an invalid page size

--- Exercise 5: Async iteration ---
✓ Consumes asynchronously streamed task pages

--- Exercise 6: Defensive configuration ---
✓ Preserves meaningful falsy settings values

--- Exercise 7: Immutable task completion ---
✓ Completes a task without mutating the source array

--- Exercise 8: Integrated async dashboard ---
✓ Builds a safe, sorted dashboard from async pages

All Appendix E exercise solutions passed successfully.
```

---

# E.2: Exercise 1 — Build a Safe Public Profile

## The Target

Create a function that removes a sensitive password hash, deduplicates user roles, and creates a readable label.

## The Concept

This exercise combines:

- Object destructuring
- Object rest syntax
- Default values
- `Set`
- Array spread syntax
- Template literals

A public profile is like a customer-facing shipping label. It includes shareable information but excludes private internal information.

## The Challenge

Implement:

```js
function createPublicProfile(user) {}
```

Given:

```js
const user = {
  id: 'user_1001',
  displayName: 'Ava Patel',
  email: 'ava@example.com',
  passwordHash: 'do-not-expose',
  roles: ['reader', 'editor', 'reader']
};
```

Return:

```js
{
  id: 'user_1001',
  displayName: 'Ava Patel',
  email: 'ava@example.com',
  roles: ['reader', 'editor'],
  label: 'Ava Patel <ava@example.com>'
}
```

Requirements:

1. Do not expose `passwordHash`.
2. Use an empty array when `roles` is absent.
3. Preserve role insertion order while removing duplicates.
4. Do not mutate the input object or its roles array.

## The Solution

```js
function createPublicProfile({
  passwordHash,
  roles = [],
  ...publicUser
}) {
  return {
    ...publicUser,
    roles: [...new Set(roles)],
    label: `${publicUser.displayName} <${publicUser.email}>`
  };
}
```

## The Verification

```bash
npm run appendix:e:exercises
```

Look for:

```text
✓ Removes passwordHash and preserves unique roles
```

---

# E.3: Exercise 2 — Create an Expressive Task Summary

## The Target

Create an arrow function that returns a summary containing a computed property name.

## The Concept

This exercise combines:

- Arrow functions
- Destructured function parameters
- Template literals
- Ternary conditions
- Enhanced object literals
- Computed property names

A computed property is useful when the property name depends on runtime information.

## The Challenge

Implement:

```js
const createTaskSummary = (task) => {};
```

For this input:

```js
{
  id: 'task_1',
  title: 'Write documentation',
  completed: false,
  priority: 2
}
```

Return:

```js
{
  id: 'task_1',
  title: 'Write documentation',
  status: 'pending',
  priority: 2,
  priority_2: 'Write documentation is pending.'
}
```

## The Solution

```js
const createTaskSummary = ({
  id,
  title,
  completed,
  priority
}) => {
  const status = completed ? 'completed' : 'pending';
  const priorityKey = `priority_${priority}`;

  return {
    id,
    title,
    status,
    priority,
    [priorityKey]: `${title} is ${status}.`
  };
};
```

## The Verification

```bash
npm run appendix:e:exercises
```

Look for:

```text
✓ Creates a status and computed priority message
```

---

# E.4: Exercise 3 — Group Unique Task IDs with `Set` and `Map`

## The Target

Group task IDs by owner while ignoring duplicate task records.

## The Concept

Use a `Set` to track which task IDs have already appeared. Use a `Map` to associate each owner with a list of unique task IDs.

## The Challenge

Implement:

```js
function groupUniqueTaskIdsByOwner(tasks) {}
```

Given:

```js
const tasks = [
  {
    id: 'task_1',
    ownerId: 'user_1001',
    title: 'Write examples'
  },
  {
    id: 'task_2',
    ownerId: 'user_1002',
    title: 'Review examples'
  },
  {
    id: 'task_1',
    ownerId: 'user_1001',
    title: 'Duplicate task record'
  }
];
```

Return:

```js
new Map([
  ['user_1001', ['task_1']],
  ['user_1002', ['task_2']]
]);
```

## The Solution

```js
function groupUniqueTaskIdsByOwner(tasks) {
  const seenTaskIds = new Set();
  const taskIdsByOwner = new Map();

  for (const { id, ownerId } of tasks) {
    if (seenTaskIds.has(id)) {
      continue;
    }

    seenTaskIds.add(id);

    const ownerTaskIds = taskIdsByOwner.get(ownerId) ?? [];

    taskIdsByOwner.set(ownerId, [...ownerTaskIds, id]);
  }

  return taskIdsByOwner;
}
```

## The Verification

```bash
npm run appendix:e:exercises
```

Look for:

```text
✓ Groups only unique task IDs by owner
```

---

# E.5: Exercise 4 — Paginate Tasks with a Generator

## The Target

Create a generator that yields pages of tasks one page at a time.

## The Concept

Generators are lazy. They provide a value only when the consumer asks for it.

This is useful for large data sets because you do not need to create every page in memory before processing the first page.

## The Challenge

Implement:

```js
function* generateTaskPages(tasks, pageSize) {}
```

Given:

```js
const tasks = [
  { id: 'task_1', title: 'First' },
  { id: 'task_2', title: 'Second' },
  { id: 'task_3', title: 'Third' }
];
```

This code:

```js
const pages = [...generateTaskPages(tasks, 2)];
```

must produce:

```js
[
  [
    { id: 'task_1', title: 'First' },
    { id: 'task_2', title: 'Second' }
  ],
  [
    { id: 'task_3', title: 'Third' }
  ]
]
```

Requirements:

1. `pageSize` must be a positive integer.
2. Throw a `RangeError` for invalid page sizes.
3. Do not mutate `tasks`.
4. Yield a final smaller page when needed.

## The Solution

```js
function* generateTaskPages(tasks, pageSize) {
  if (!Number.isInteger(pageSize) || pageSize <= 0) {
    throw new RangeError('pageSize must be a positive integer.');
  }

  for (
    let startIndex = 0;
    startIndex < tasks.length;
    startIndex += pageSize
  ) {
    yield tasks.slice(startIndex, startIndex + pageSize);
  }
}
```

## The Verification

```bash
npm run appendix:e:exercises
```

Look for:

```text
✓ Creates synchronous task pages
✓ Rejects an invalid page size
```

---

# E.6: Exercise 5 — Stream Task Pages Asynchronously

## The Target

Create an async generator and consume it using `for await...of`.

## The Concept

Async generators are useful when values arrive over time, such as from a paginated API, database cursor, event stream, or message queue.

A regular generator hands you items from a shelf. An async generator waits for the delivery truck to arrive with the next item.

## The Challenge

Implement:

```js
async function* streamTaskPages(taskPages) {}
```

Given:

```js
const taskPages = [
  [
    { id: 'task_1', title: 'First' }
  ],
  [
    { id: 'task_2', title: 'Second' }
  ]
];
```

Consume the stream and collect:

```js
['task_1', 'task_2']
```

Requirements:

1. Yield pages in source order.
2. Simulate an asynchronous wait before each page.
3. Consume the result using `for await...of`.
4. Do not mutate the source pages.

## The Solution

```js
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

async function* streamTaskPages(taskPages) {
  for (const taskPage of taskPages) {
    await delay(1);

    yield taskPage;
  }
}
```

## The Verification

```bash
npm run appendix:e:exercises
```

Look for:

```text
✓ Consumes asynchronously streamed task pages
```

---

# E.7: Exercise 6 — Normalize Incomplete Settings

## The Target

Safely apply defaults to incomplete settings without overwriting valid `0`, `false`, or empty-string values.

## The Concept

Use `??=` when a fallback should apply only to `null` and `undefined`.

Do not use `||=` for these settings because `||=` would replace valid falsy values such as:

```js
0
false
''
```

## The Challenge

Implement:

```js
function normalizeSettings(settings = {}) {}
```

Given:

```js
{
  colorScheme: null,
  pageSize: 0,
  showCompletedTasks: false,
  timezone: ''
}
```

Return:

```js
{
  colorScheme: 'system',
  pageSize: 0,
  showCompletedTasks: false,
  timezone: ''
}
```

## The Solution

```js
function normalizeSettings(settings = {}) {
  const normalizedSettings = {
    ...settings
  };

  normalizedSettings.colorScheme ??= 'system';
  normalizedSettings.pageSize ??= 25;
  normalizedSettings.showCompletedTasks ??= true;
  normalizedSettings.timezone ??= 'UTC';

  return normalizedSettings;
}
```

## The Verification

```bash
npm run appendix:e:exercises
```

Look for:

```text
✓ Preserves meaningful falsy settings values
```

---

# E.8: Exercise 7 — Complete a Task Without Mutation

## The Target

Return a new task array with one matching task marked as complete.

## The Concept

This exercise combines:

- `.findIndex()`
- `.at()`
- `.with()`
- Object spread syntax
- Explicit error handling

The source array and source task must remain unchanged.

## The Challenge

Implement:

```js
function completeTaskById(tasks, taskId) {}
```

Requirements:

1. Locate the matching task by ID.
2. Throw a `RangeError` when no task matches.
3. Return a new array.
4. Return a new object for the updated task.
5. Preserve all existing task properties.

## The Solution

```js
function completeTaskById(tasks, taskId) {
  const taskIndex = tasks.findIndex((task) => task.id === taskId);

  if (taskIndex === -1) {
    throw new RangeError(`Task "${taskId}" does not exist.`);
  }

  const existingTask = tasks.at(taskIndex);

  return tasks.with(taskIndex, {
    ...existingTask,
    completed: true
  });
}
```

## The Verification

```bash
npm run appendix:e:exercises
```

Look for:

```text
✓ Completes a task without mutating the source array
```

---

# E.9: Exercise 8 — Build an Integrated Async Dashboard

## The Target

Build a safe project dashboard from potentially incomplete project data and asynchronously delivered task pages.

## The Concept

This capstone combines the series features into one data-processing pipeline:

- Destructuring with defaults
- Optional chaining
- Nullish coalescing
- `Set` for unique tags
- `Map` for owner task counts
- Async iteration
- Template literals
- Immutable sorting with `.toSorted()`

## The Challenge

Implement:

```js
async function createDashboard(project, taskPages) {}
```

Requirements:

1. Default missing IDs to `'unknown-project'`.
2. Default missing names to `'Untitled project'`.
3. Use `'Unassigned owner'` if `owner?.displayName` is missing.
4. Preserve a valid `pageSize` of `0`.
5. Combine project and task tags uniquely while preserving insertion order.
6. Count completed tasks.
7. Collect pending task titles.
8. Count tasks by owner in a `Map`.
9. Sort returned tasks by ascending priority, then title.
10. Do not mutate the source project or source task pages.

## The Solution

```js
async function createDashboard(project, taskPages) {
  const {
    id = 'unknown-project',
    name = 'Untitled project',
    owner = null,
    tags: projectTags = [],
    settings = {}
  } = project;

  const uniqueTags = new Set(projectTags ?? []);
  const taskCountByOwner = new Map();
  const tasks = [];

  for await (const taskPage of taskPages) {
    for (const task of taskPage) {
      tasks.push(task);

      for (const tag of task.tags ?? []) {
        uniqueTags.add(tag);
      }

      const currentOwnerTaskCount =
        taskCountByOwner.get(task.ownerId) ?? 0;

      taskCountByOwner.set(
        task.ownerId,
        currentOwnerTaskCount + 1
      );
    }
  }

  const completedTaskCount = tasks.filter((task) => {
    return task.completed;
  }).length;

  const pendingTaskTitles = tasks
    .filter((task) => !task.completed)
    .map((task) => task.title);

  const tasksByPriority = tasks.toSorted((firstTask, secondTask) => {
    const priorityDifference =
      firstTask.priority - secondTask.priority;

    if (priorityDifference !== 0) {
      return priorityDifference;
    }

    return firstTask.title.localeCompare(secondTask.title);
  });

  return {
    id,
    label: `${name} — owned by ${
      owner?.displayName ?? 'Unassigned owner'
    }`,
    settings: {
      pageSize: settings?.pageSize ?? 25
    },
    tags: [...uniqueTags],
    completedTaskCount,
    pendingTaskTitles,
    taskCountByOwner,
    tasksByPriority
  };
}
```

## The Verification

Run the full exercise suite:

```bash
npm run appendix:e:exercises
```

Expected final lines:

```text
--- Exercise 8: Integrated async dashboard ---
✓ Builds a safe, sorted dashboard from async pages

All Appendix E exercise solutions passed successfully.
```

---

# E.10: Independent Extension Challenges

After the automated exercises pass, try these extensions without looking up a solution first.

## Challenge 1: Reject Duplicate Task IDs

Modify `createDashboard()` to reject duplicate task IDs.

Hint: create a `Set` before the async loop:

```js
const receivedTaskIds = new Set();
```

Before adding a task:

```js
if (receivedTaskIds.has(task.id)) {
  throw new RangeError(`Duplicate task id "${task.id}" received.`);
}

receivedTaskIds.add(task.id);
```

---

## Challenge 2: Add a `completedTaskIds` Set

Return this additional dashboard property:

```js
completedTaskIds: new Set(['task_1', 'task_4'])
```

Build it from the final task collection.

Verification idea:

```js
assert.equal(dashboard.completedTaskIds.has('task_1'), true);
assert.equal(dashboard.completedTaskIds.has('task_2'), false);
```

---

## Challenge 3: Create an Immutable Dashboard Task Update

Implement:

```js
function updateDashboardTask(dashboard, taskId, changes) {}
```

Requirements:

- Use `.with()` to replace exactly one task.
- Use object spread to preserve unchanged fields.
- Return a new dashboard object.
- Recalculate `completedTaskCount`.
- Recalculate `pendingTaskTitles`.
- Keep the original dashboard untouched.

---

## Challenge 4: Add a Safe Task Lookup Method

Return a method from `createDashboard()`:

```js
getTaskById(taskId) {
  return this.tasksByPriority.find((task) => task.id === taskId) ?? null;
}
```

Verify both cases:

```js
assert.equal(dashboard.getTaskById('task_1')?.id, 'task_1');
assert.equal(dashboard.getTaskById('missing-task'), null);
```

---

## Challenge 5: Generate Dashboard Events

Create an async generator:

```js
async function* generateDashboardEvents(taskPages) {}
```

Yield an event as each task arrives:

```js
{
  type: 'task.received',
  taskId: 'task_1'
}
```

Consume it using:

```js
for await (const event of generateDashboardEvents(taskPages)) {
  console.log(event);
}
```

---

# Appendix E Completion Checklist

Run:

```bash
npm run appendix:e:exercises
```

Confirm that:

- Every test prints a `✓`.
- No assertion errors occur.
- The final message is:

```text
All Appendix E exercise solutions passed successfully.
```
