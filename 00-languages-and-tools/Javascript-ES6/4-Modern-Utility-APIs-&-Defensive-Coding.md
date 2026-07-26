# Part 4: Modern Utility APIs & Defensive Coding

The earlier parts focused on writing concise, expressive code and choosing useful data structures. This final part focuses on writing code that stays reliable when real-world data is incomplete, nested, shared, or unexpectedly shaped.

You will build examples for:

- Optional chaining: `?.`
- Nullish coalescing: `??`
- Logical assignment operators: `&&=`, `||=`, and `??=`
- `structuredClone()` for deep copies
- Modern immutable array methods:
  - `.at()`
  - `.toSorted()`
  - `.toSpliced()`
  - `.with()`

The central production principle is:

> Do not assume data exists, and do not accidentally alter data you do not own.

---

## Step 1: Extend the Project Scripts and Directory Structure

### The Target

Add a directory and runnable npm scripts for the Part 4 modules.

### The Concept

Each module demonstrates one focused tool. Keeping them separate is like using separate safety stations in a workshop: one station checks for missing parts, another safely duplicates materials, and another changes a design without damaging the original.

### The Implementation

Create the Part 4 directory:

```bash
mkdir -p src/part-4-defensive-modern-apis
```

> On Windows PowerShell:

```powershell
mkdir src\part-4-defensive-modern-apis
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
    "part:3:iteration": "node src/part-3-collections-iteration/iterators-generators.js",
    "part:4:safe-access": "node src/part-4-defensive-modern-apis/safe-access.js",
    "part:4:structured-clone": "node src/part-4-defensive-modern-apis/structured-clone.js",
    "part:4:immutable-arrays": "node src/part-4-defensive-modern-apis/immutable-arrays.js"
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

Confirm that the output includes:

```text
part:4:safe-access
part:4:structured-clone
part:4:immutable-arrays
```

---

## Step 2: Safely Read and Initialize Uncertain Data

### The Target

Create `safe-access.js` to demonstrate optional chaining, nullish coalescing, and logical assignment operators.

### The Concept

Real data is often incomplete.

An API response may not include a profile. A profile may not include preferences. Preferences may not include a selected theme.

Older JavaScript often handles this with a long chain of checks:

```js
const theme =
  user &&
  user.preferences &&
  user.preferences.theme;
```

Optional chaining makes this safer and easier to read:

```js
const theme = user?.preferences?.theme;
```

It means:

> “Continue only if the value before this point exists. Otherwise, safely stop and return `undefined`.”

Nullish coalescing, `??`, provides a fallback only when a value is `null` or `undefined`:

```js
const theme = user?.preferences?.theme ?? 'system';
```

This differs from `||`. Logical OR treats all falsy values as absent, including `0`, `false`, and empty strings. Those values can be meaningful and should often be preserved.

Think of `??` as a backup generator that starts only when the main power source is actually disconnected—not merely because it is operating at a low value.

### The Implementation

Create this file.

### `src/part-4-defensive-modern-apis/safe-access.js`

```js
/**
 * Part 4: Optional chaining, nullish coalescing, and logical assignment.
 *
 * Run directly:
 * node src/part-4-defensive-modern-apis/safe-access.js
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

printSection('optional chaining safely reads nested properties');

const userWithPreferences = {
  id: 'user_1001',
  displayName: 'Ava Patel',
  preferences: {
    colorScheme: 'dark'
  }
};

const userWithoutPreferences = {
  id: 'user_1002',
  displayName: 'Mina Chen'
};

console.log({
  configuredTheme: userWithPreferences?.preferences?.colorScheme,
  missingTheme: userWithoutPreferences?.preferences?.colorScheme,
  missingUserTheme: undefined?.preferences?.colorScheme
});

printSection('optional chaining safely accesses array items');

const project = {
  id: 'project_3001',
  members: [
    {
      id: 'user_1001',
      displayName: 'Ava Patel'
    }
  ]
};

console.log({
  firstMemberName: project.members?.[0]?.displayName,
  secondMemberName: project.members?.[1]?.displayName,
  missingProjectMemberName: undefined?.members?.[0]?.displayName
});

printSection('optional chaining safely calls optional methods');

const notificationService = {
  send(message) {
    return `Sent notification: ${message}`;
  }
};

const incompleteNotificationService = {};

console.log(
  notificationService.send?.('Deployment completed successfully.')
);

console.log(
  incompleteNotificationService.send?.('This call is safely skipped.')
);

printSection('optional chaining does not hide unrelated errors');

const invalidService = {
  send: 'not a function'
};

try {
  // ?. only prevents errors when send is null or undefined.
  // A present non-function value still cannot be called.
  invalidService.send?.('This still fails because send is a string.');
} catch (error) {
  console.log({
    errorName: error.name,
    message: error.message
  });
}

printSection('nullish coalescing provides defaults for null and undefined');

const apiSettings = {
  colorScheme: null,
  pageSize: 0,
  compactMode: false,
  displayName: ''
};

const resolvedSettings = {
  colorScheme: apiSettings.colorScheme ?? 'system',
  pageSize: apiSettings.pageSize ?? 25,
  compactMode: apiSettings.compactMode ?? true,
  displayName: apiSettings.displayName ?? 'Anonymous'
};

console.log(resolvedSettings);

printSection('why ?? differs from ||');

console.log({
  zeroWithNullishCoalescing: 0 ?? 25,
  zeroWithLogicalOr: 0 || 25,
  falseWithNullishCoalescing: false ?? true,
  falseWithLogicalOr: false || true,
  emptyStringWithNullishCoalescing: '' ?? 'Anonymous',
  emptyStringWithLogicalOr: '' || 'Anonymous',
  nullWithNullishCoalescing: null ?? 'Fallback',
  undefinedWithNullishCoalescing: undefined ?? 'Fallback'
});

printSection('combining optional chaining with nullish coalescing');

/**
 * Produces a safe display label from incomplete user-like input.
 *
 * @param {{
 *   profile?: {
 *     displayName?: string | null
 *   } | null
 * } | null | undefined} user - Possibly incomplete user data.
 * @returns {string} A display label.
 */
function getDisplayLabel(user) {
  return user?.profile?.displayName ?? 'Anonymous user';
}

console.log({
  namedUser: getDisplayLabel({
    profile: {
      displayName: 'Ava Patel'
    }
  }),
  nullNameUser: getDisplayLabel({
    profile: {
      displayName: null
    }
  }),
  missingProfileUser: getDisplayLabel({}),
  absentUser: getDisplayLabel(undefined)
});

printSection('||= assigns only when the current value is falsy');

const featureConfiguration = {
  retryCount: 0,
  endpoint: '',
  verboseLogging: false
};

featureConfiguration.retryCount ||= 3;
featureConfiguration.endpoint ||= 'https://api.example.test';
featureConfiguration.verboseLogging ||= true;

console.log(featureConfiguration);

printSection('&&= assigns only when the current value is truthy');

const deployment = {
  status: 'running',
  errorMessage: '',
  startedAt: '2026-07-24T10:00:00.000Z'
};

deployment.status &&= deployment.status.toUpperCase();
deployment.errorMessage &&= deployment.errorMessage.trim();
deployment.startedAt &&= new Date(deployment.startedAt).toISOString();

console.log(deployment);

printSection('??= assigns only when the current value is null or undefined');

const userPreferences = {
  colorScheme: null,
  pageSize: 0,
  compactMode: false,
  language: undefined
};

userPreferences.colorScheme ??= 'system';
userPreferences.pageSize ??= 25;
userPreferences.compactMode ??= true;
userPreferences.language ??= 'en';

console.log(userPreferences);

printSection('practical configuration normalization');

/**
 * Applies safe defaults while preserving meaningful false, zero, and empty
 * string values supplied by the caller.
 *
 * @param {{
 *   apiUrl?: string | null,
 *   timeoutMilliseconds?: number | null,
 *   retryCount?: number | null,
 *   enableTelemetry?: boolean | null
 * }} configuration - Partial configuration from an external source.
 * @returns {{
 *   apiUrl: string,
 *   timeoutMilliseconds: number,
 *   retryCount: number,
 *   enableTelemetry: boolean
 * }} Fully initialized configuration.
 */
function normalizeConfiguration(configuration) {
  const normalized = {
    ...configuration
  };

  normalized.apiUrl ??= 'https://api.example.test';
  normalized.timeoutMilliseconds ??= 5_000;
  normalized.retryCount ??= 3;
  normalized.enableTelemetry ??= true;

  return normalized;
}

console.log(
  normalizeConfiguration({
    apiUrl: '',
    timeoutMilliseconds: 0,
    retryCount: null,
    enableTelemetry: false
  })
);

console.log('\nSafe access and defensive operator examples completed successfully.');
```

### The Verification

Run:

```bash
npm run part:4:safe-access
```

Expected output includes:

```text
--- optional chaining safely reads nested properties ---
{
  configuredTheme: 'dark',
  missingTheme: undefined,
  missingUserTheme: undefined
}

--- why ?? differs from || ---
{
  zeroWithNullishCoalescing: 0,
  zeroWithLogicalOr: 25,
  falseWithNullishCoalescing: false,
  falseWithLogicalOr: true,
  emptyStringWithNullishCoalescing: '',
  emptyStringWithLogicalOr: 'Anonymous',
  nullWithNullishCoalescing: 'Fallback',
  undefinedWithNullishCoalescing: 'Fallback'
}

--- ??= assigns only when the current value is null or undefined ---
{
  colorScheme: 'system',
  pageSize: 0,
  compactMode: false,
  language: 'en'
}

Safe access and defensive operator examples completed successfully.
```

---

## Step 3: Deep-Copy Compatible Data with `structuredClone()`

### The Target

Create `structured-clone.js`, which compares shallow copies with deep copies and explains when `structuredClone()` is appropriate.

### The Concept

A shallow copy is like copying the cover of a binder while the pages inside remain shared.

Object spread creates a new top-level object:

```js
const copiedProject = {
  ...originalProject
};
```

But nested objects are still the same shared objects.

`structuredClone()` creates a new, independent copy of supported values. It is like photocopying the binder, including the pages inside, rather than only replacing its cover.

```js
const copiedProject = structuredClone(originalProject);
```

This is useful when you must safely modify a complex data snapshot without changing the original.

However, cloning is not always the best strategy. Often, a targeted immutable update is more efficient and clearer. Use deep cloning when you genuinely need an independent copy of a compatible data graph.

### The Implementation

Create this file.

### `src/part-4-defensive-modern-apis/structured-clone.js`

```js
/**
 * Part 4: structuredClone() and deep-copy behavior.
 *
 * Run directly:
 * node src/part-4-defensive-modern-apis/structured-clone.js
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

printSection('spread syntax creates a shallow copy');

const originalProject = {
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit',
  metadata: {
    owner: 'Ava Patel',
    priority: 'high'
  },
  tags: ['javascript', 'learning']
};

const shallowCopy = {
  ...originalProject
};

shallowCopy.metadata.priority = 'urgent';
shallowCopy.tags.push('shared-reference');

console.log({
  originalProject,
  shallowCopy,
  topLevelObjectsAreDifferent: originalProject !== shallowCopy,
  nestedMetadataIsShared:
    originalProject.metadata === shallowCopy.metadata,
  nestedTagsArrayIsShared:
    originalProject.tags === shallowCopy.tags
});

printSection('structuredClone creates independent nested values');

const sourceProject = {
  id: 'project_3002',
  name: 'Defensive Coding Examples',
  metadata: {
    owner: 'Mina Chen',
    priority: 'medium'
  },
  tags: ['javascript', 'reliability']
};

const deepCopy = structuredClone(sourceProject);

deepCopy.metadata.priority = 'low';
deepCopy.tags.push('independent-copy');

console.log({
  sourceProject,
  deepCopy,
  topLevelObjectsAreDifferent: sourceProject !== deepCopy,
  nestedMetadataIsDifferent:
    sourceProject.metadata !== deepCopy.metadata,
  nestedTagsArrayIsDifferent:
    sourceProject.tags !== deepCopy.tags
});

printSection('structuredClone supports common built-in data types');

const originalState = {
  createdAt: new Date('2026-07-24T10:00:00.000Z'),
  roles: new Set(['reader', 'editor']),
  taskStatusById: new Map([
    ['task_1', 'completed'],
    ['task_2', 'pending']
  ]),
  binaryData: new Uint8Array([10, 20, 30])
};

const clonedState = structuredClone(originalState);

clonedState.createdAt.setUTCFullYear(2030);
clonedState.roles.add('admin');
clonedState.taskStatusById.set('task_3', 'blocked');
clonedState.binaryData[0] = 99;

console.log({
  originalDate: originalState.createdAt.toISOString(),
  clonedDate: clonedState.createdAt.toISOString(),
  originalRoles: [...originalState.roles],
  clonedRoles: [...clonedState.roles],
  originalTaskStatuses: [...originalState.taskStatusById.entries()],
  clonedTaskStatuses: [...clonedState.taskStatusById.entries()],
  originalBinaryData: [...originalState.binaryData],
  clonedBinaryData: [...clonedState.binaryData]
});

printSection('structuredClone supports circular references');

const circularRecord = {
  id: 'record_1',
  label: 'Circular record'
};

circularRecord.self = circularRecord;

const clonedCircularRecord = structuredClone(circularRecord);

console.log({
  cloneIsDifferentObject: clonedCircularRecord !== circularRecord,
  clonePointsToItself: clonedCircularRecord.self === clonedCircularRecord,
  cloneLabel: clonedCircularRecord.label
});

printSection('structuredClone rejects unsupported values');

const unsupportedExamples = [
  {
    label: 'function',
    value: {
      transform() {
        return 'Cannot be cloned.';
      }
    }
  },
  {
    label: 'symbol',
    value: {
      key: Symbol('private-key')
    }
  }
];

for (const example of unsupportedExamples) {
  try {
    structuredClone(example.value);
  } catch (error) {
    console.log({
      label: example.label,
      errorName: error.name,
      message: error.message
    });
  }
}

printSection('targeted immutable updates are often preferable');

/**
 * Returns a project with one nested priority field updated.
 *
 * This is more focused than cloning the entire project when only one
 * known nested field needs to change.
 *
 * @param {{
 *   id: string,
 *   metadata: {
 *     owner: string,
 *     priority: string
 *   }
 * }} project - Project to update.
 * @param {string} priority - New priority.
 * @returns {{
 *   id: string,
 *   metadata: {
 *     owner: string,
 *     priority: string
 *   }
 * }} Updated project.
 */
function updateProjectPriority(project, priority) {
  return {
    ...project,
    metadata: {
      ...project.metadata,
      priority
    }
  };
}

const projectBeforeTargetedUpdate = {
  id: 'project_3003',
  metadata: {
    owner: 'Noah Kim',
    priority: 'low'
  }
};

const projectAfterTargetedUpdate = updateProjectPriority(
  projectBeforeTargetedUpdate,
  'high'
);

console.log({
  projectBeforeTargetedUpdate,
  projectAfterTargetedUpdate,
  metadataObjectsAreDifferent:
    projectBeforeTargetedUpdate.metadata !==
    projectAfterTargetedUpdate.metadata
});

printSection('transferable ArrayBuffers can be moved instead of copied');

const sourceBuffer = new ArrayBuffer(4);
const sourceBytes = new Uint8Array(sourceBuffer);

sourceBytes.set([1, 2, 3, 4]);

const movedBuffer = structuredClone(sourceBuffer, {
  transfer: [sourceBuffer]
});

console.log({
  originalBufferByteLengthAfterTransfer: sourceBuffer.byteLength,
  movedBufferByteLength: movedBuffer.byteLength,
  movedBytes: [...new Uint8Array(movedBuffer)]
});

console.log('\nstructuredClone examples completed successfully.');
```

### The Verification

Run:

```bash
npm run part:4:structured-clone
```

Expected output includes:

```text
--- spread syntax creates a shallow copy ---
{
  originalProject: {
    id: 'project_3001',
    name: 'Modern JavaScript Toolkit',
    metadata: { owner: 'Ava Patel', priority: 'urgent' },
    tags: [ 'javascript', 'learning', 'shared-reference' ]
  },
  shallowCopy: {
    id: 'project_3001',
    name: 'Modern JavaScript Toolkit',
    metadata: { owner: 'Ava Patel', priority: 'urgent' },
    tags: [ 'javascript', 'learning', 'shared-reference' ]
  },
  topLevelObjectsAreDifferent: true,
  nestedMetadataIsShared: true,
  nestedTagsArrayIsShared: true
}

--- structuredClone creates independent nested values ---
{
  sourceProject: {
    id: 'project_3002',
    name: 'Defensive Coding Examples',
    metadata: { owner: 'Mina Chen', priority: 'medium' },
    tags: [ 'javascript', 'reliability' ]
  },
  deepCopy: {
    id: 'project_3002',
    name: 'Defensive Coding Examples',
    metadata: { owner: 'Mina Chen', priority: 'low' },
    tags: [ 'javascript', 'reliability', 'independent-copy' ]
  },
  topLevelObjectsAreDifferent: true,
  nestedMetadataIsDifferent: true,
  nestedTagsArrayIsDifferent: true
}

--- transferable ArrayBuffers can be moved instead of copied ---
{
  originalBufferByteLengthAfterTransfer: 0,
  movedBufferByteLength: 4,
  movedBytes: [ 1, 2, 3, 4 ]
}

structuredClone examples completed successfully.
```

For unsupported values, the exact `DataCloneError` message may vary by runtime. The essential behavior is that cloning functions and symbol values throws an error.

---

## Step 4: Transform Arrays Without Mutating the Original

### The Target

Create `immutable-arrays.js` to use `.at()`, `.toSorted()`, `.toSpliced()`, and `.with()`.

### The Concept

Many familiar array methods change the original array:

```js
tasks.sort();
tasks.splice(1, 1);
```

This can create difficult bugs when another part of the program still expects the original ordering or contents.

Modern JavaScript provides non-mutating alternatives:

| Older mutating method | Modern non-mutating alternative |
|---|---|
| `.sort()` | `.toSorted()` |
| `.splice()` | `.toSpliced()` |
| Direct assignment such as `items[0] = value` | `.with(0, value)` |

These methods return a new array and preserve the original.

Think of the original array as a master document. Instead of writing corrections directly on it, you create a revised copy and leave the master intact.

### The Implementation

Create this file.

### `src/part-4-defensive-modern-apis/immutable-arrays.js`

```js
/**
 * Part 4: Modern immutable array methods.
 *
 * Run directly:
 * node src/part-4-defensive-modern-apis/immutable-arrays.js
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

printSection('Array.prototype.at() supports negative indexes');

const deploymentStages = ['validate', 'build', 'test', 'deploy'];

console.log({
  firstStage: deploymentStages.at(0),
  secondStage: deploymentStages.at(1),
  finalStage: deploymentStages.at(-1),
  secondToLastStage: deploymentStages.at(-2),
  outsideArray: deploymentStages.at(99)
});

printSection('at() is clearer than manual last-index math');

const latestRelease = {
  version: '2.4.0',
  publishedAt: '2026-07-24T10:00:00.000Z'
};

const releases = [
  {
    version: '2.2.0',
    publishedAt: '2026-05-01T10:00:00.000Z'
  },
  {
    version: '2.3.0',
    publishedAt: '2026-06-15T10:00:00.000Z'
  },
  latestRelease
];

console.log({
  oldStyleLastRelease: releases[releases.length - 1],
  modernLastRelease: releases.at(-1)
});

printSection('toSorted() returns a sorted copy');

const priorities = ['high', 'low', 'medium'];
const alphabeticallySortedPriorities = priorities.toSorted();

console.log({
  priorities,
  alphabeticallySortedPriorities,
  arraysAreDifferent: priorities !== alphabeticallySortedPriorities
});

printSection('toSorted() with a numeric comparison function');

const responseTimesInMilliseconds = [250, 18, 100, 4, 75];

// Without this comparison function, numbers are converted to strings before
// comparison, which produces incorrect numeric ordering.
const sortedResponseTimes = responseTimesInMilliseconds.toSorted(
  (firstTime, secondTime) => firstTime - secondTime
);

console.log({
  responseTimesInMilliseconds,
  sortedResponseTimes
});

printSection('toSorted() for objects');

/**
 * Compares task titles alphabetically using a locale-aware comparison.
 *
 * @param {{ title: string }} firstTask - First task.
 * @param {{ title: string }} secondTask - Second task.
 * @returns {number} Sort-order result.
 */
function compareTasksByTitle(firstTask, secondTask) {
  return firstTask.title.localeCompare(secondTask.title);
}

const tasks = [
  {
    id: 'task_3',
    title: 'Write documentation',
    priority: 2
  },
  {
    id: 'task_1',
    title: 'Analyze requirements',
    priority: 1
  },
  {
    id: 'task_2',
    title: 'Build prototype',
    priority: 3
  }
];

const tasksByTitle = tasks.toSorted(compareTasksByTitle);
const tasksByPriority = tasks.toSorted(
  (firstTask, secondTask) => firstTask.priority - secondTask.priority
);

console.log({
  originalTaskIds: tasks.map((task) => task.id),
  titleSortedTaskIds: tasksByTitle.map((task) => task.id),
  prioritySortedTaskIds: tasksByPriority.map((task) => task.id)
});

printSection('toSpliced() adds or removes items without mutation');

const initialTaskIds = ['task_1', 'task_2', 'task_3'];

const taskIdsWithoutSecondTask = initialTaskIds.toSpliced(1, 1);
const taskIdsWithInsertedTask = initialTaskIds.toSpliced(
  1,
  0,
  'task_1_5'
);
const taskIdsWithReplacement = initialTaskIds.toSpliced(
  1,
  1,
  'task_2_revised'
);

console.log({
  initialTaskIds,
  taskIdsWithoutSecondTask,
  taskIdsWithInsertedTask,
  taskIdsWithReplacement
});

printSection('with() replaces one item without mutation');

const taskStatuses = ['pending', 'pending', 'completed'];

const taskStatusesAfterUpdate = taskStatuses.with(1, 'in_progress');

console.log({
  taskStatuses,
  taskStatusesAfterUpdate,
  arraysAreDifferent: taskStatuses !== taskStatusesAfterUpdate
});

printSection('with() can use negative indexes');

const releaseChannels = ['alpha', 'beta', 'stable'];

const revisedReleaseChannels = releaseChannels.with(-1, 'production');

console.log({
  releaseChannels,
  revisedReleaseChannels
});

printSection('with() validates the replacement index');

try {
  releaseChannels.with(10, 'invalid');
} catch (error) {
  console.log({
    errorName: error.name,
    message: error.message
  });
}

printSection('a practical immutable task update');

/**
 * Returns a new tasks array with one task replaced.
 *
 * @param {Array<{
 *   id: string,
 *   title: string,
 *   completed: boolean
 * }>} currentTasks - Existing task list.
 * @param {string} taskId - ID of the task to update.
 * @param {Partial<{
 *   title: string,
 *   completed: boolean
 * }>} changes - Fields to replace.
 * @returns {Array<{
 *   id: string,
 *   title: string,
 *   completed: boolean
 * }>} Revised task list.
 * @throws {RangeError} When taskId does not exist.
 */
function updateTaskById(currentTasks, taskId, changes) {
  const taskIndex = currentTasks.findIndex((task) => task.id === taskId);

  if (taskIndex === -1) {
    throw new RangeError(`Task "${taskId}" does not exist.`);
  }

  const existingTask = currentTasks.at(taskIndex);

  return currentTasks.with(taskIndex, {
    ...existingTask,
    ...changes
  });
}

const initialTasks = [
  {
    id: 'task_1',
    title: 'Create examples',
    completed: true
  },
  {
    id: 'task_2',
    title: 'Write documentation',
    completed: false
  }
];

const completedTasks = updateTaskById(initialTasks, 'task_2', {
  completed: true
});

console.log({
  initialTasks,
  completedTasks,
  originalTaskWasNotChanged: initialTasks.at(1).completed === false,
  revisedTaskWasCompleted: completedTasks.at(1).completed === true
});

console.log('\nImmutable array method examples completed successfully.');
```

### The Verification

Run:

```bash
npm run part:4:immutable-arrays
```

Expected output includes:

```text
--- Array.prototype.at() supports negative indexes ---
{
  firstStage: 'validate',
  secondStage: 'build',
  finalStage: 'deploy',
  secondToLastStage: 'test',
  outsideArray: undefined
}

--- toSorted() with a numeric comparison function ---
{
  responseTimesInMilliseconds: [ 250, 18, 100, 4, 75 ],
  sortedResponseTimes: [ 4, 18, 75, 100, 250 ]
}

--- with() replaces one item without mutation ---
{
  taskStatuses: [ 'pending', 'pending', 'completed' ],
  taskStatusesAfterUpdate: [ 'pending', 'in_progress', 'completed' ],
  arraysAreDifferent: true
}

--- a practical immutable task update ---
{
  initialTasks: [
    { id: 'task_1', title: 'Create examples', completed: true },
    { id: 'task_2', title: 'Write documentation', completed: false }
  ],
  completedTasks: [
    { id: 'task_1', title: 'Create examples', completed: true },
    { id: 'task_2', title: 'Write documentation', completed: true }
  ],
  originalTaskWasNotChanged: true,
  revisedTaskWasCompleted: true
}

Immutable array method examples completed successfully.
```

---

## Step 5: Build the Final Defensive Toolkit Entry Point

### The Target

Replace `src/index.js` with the final runnable application entry point. It combines concepts from all four parts:

- Destructuring and spread syntax
- Arrow functions and template literals
- `Set`, `Map`, and async generators
- Optional chaining and nullish defaults
- `structuredClone()`
- Immutable array updates

### The Concept

This is the final architecture: a miniature project-dashboard pipeline.

Imagine an operations desk receiving batches of task records:

1. An async generator delivers pages of tasks.
2. The dashboard safely reads project configuration, even if fields are absent.
3. A `Set` ensures tags stay unique.
4. A `Map` counts work assigned to each owner.
5. `structuredClone()` creates a safe editable draft.
6. `.with()` updates a task without rewriting the source task array.
7. `.toSorted()` creates a display order without changing the stored order.

This is not a framework or a full web application. It is a compact, production-minded example of how modern JavaScript features cooperate in an application boundary.

### The Implementation

Replace `src/index.js` with this complete version.

### `src/index.js`

```js
/**
 * Modern JavaScript Toolkit: final integrated entry point.
 *
 * Run with:
 * npm start
 */

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
 * Simulates pages of tasks arriving from an asynchronous external source.
 *
 * @returns {AsyncGenerator<Array<{
 *   id: string,
 *   ownerId: string,
 *   title: string,
 *   completed: boolean,
 *   priority: number,
 *   tags?: string[]
 * }>, void, unknown>} An async sequence of task pages.
 */
async function* fetchProjectTaskPages() {
  await delay(10);

  yield [
    {
      id: 'task_1',
      ownerId: 'user_1001',
      title: 'Create Part 1 examples',
      completed: true,
      priority: 1,
      tags: ['javascript', 'syntax']
    },
    {
      id: 'task_2',
      ownerId: 'user_1001',
      title: 'Create Part 2 examples',
      completed: true,
      priority: 2,
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
      priority: 1,
      tags: ['collections', 'javascript']
    },
    {
      id: 'task_4',
      ownerId: 'user_1002',
      title: 'Review defensive coding examples',
      completed: false,
      priority: 3
    }
  ];
}

/**
 * Creates a normalized dashboard snapshot from raw project data.
 *
 * @param {{
 *   id?: string,
 *   name?: string,
 *   owner?: {
 *     displayName?: string | null
 *   } | null,
 *   tags?: string[] | null,
 *   settings?: {
 *     colorScheme?: string | null,
 *     pageSize?: number | null,
 *     showCompletedTasks?: boolean | null
 *   } | null
 * }} project - Potentially incomplete project data.
 * @returns {Promise<{
 *   id: string,
 *   name: string,
 *   ownerName: string,
 *   label: string,
 *   tags: string[],
 *   settings: {
 *     colorScheme: string,
 *     pageSize: number,
 *     showCompletedTasks: boolean
 *   },
 *   tasks: Array<{
 *     id: string,
 *     ownerId: string,
 *     title: string,
 *     completed: boolean,
 *     priority: number,
 *     tags?: string[]
 *   }>,
 *   completedTaskCount: number,
 *   pendingTaskCount: number,
 *   taskCountByOwner: Map<string, number>
 * }>} A complete dashboard snapshot.
 */
async function createProjectDashboard(project) {
  const {
    id = 'unknown-project',
    name = 'Untitled project',
    owner = null,
    tags: initialTags = [],
    settings: inputSettings = null
  } = project;

  const settings = {
    colorScheme: inputSettings?.colorScheme ?? 'system',
    pageSize: inputSettings?.pageSize ?? 25,
    showCompletedTasks: inputSettings?.showCompletedTasks ?? true
  };

  const uniqueTags = new Set(initialTags ?? []);
  const taskCountByOwner = new Map();
  const tasks = [];

  for await (const taskPage of fetchProjectTaskPages()) {
    for (const task of taskPage) {
      tasks.push(task);

      for (const tag of task.tags ?? []) {
        uniqueTags.add(tag);
      }

      const currentCount = taskCountByOwner.get(task.ownerId) ?? 0;

      taskCountByOwner.set(task.ownerId, currentCount + 1);
    }
  }

  const completedTaskCount = tasks.filter((task) => task.completed).length;
  const pendingTaskCount = tasks.length - completedTaskCount;
  const ownerName = owner?.displayName ?? 'Unassigned owner';

  return {
    id,
    name,
    ownerName,
    label: `${name} — owned by ${ownerName}`,
    tags: [...uniqueTags],
    settings,
    tasks,
    completedTaskCount,
    pendingTaskCount,
    taskCountByOwner
  };
}

/**
 * Returns a new dashboard snapshot with a single task updated.
 *
 * @param {{
 *   tasks: Array<{
 *     id: string,
 *     ownerId: string,
 *     title: string,
 *     completed: boolean,
 *     priority: number,
 *     tags?: string[]
 *   }>
 * }} dashboard - Existing dashboard data.
 * @param {string} taskId - ID of the task to update.
 * @param {Partial<{
 *   title: string,
 *   completed: boolean,
 *   priority: number,
 *   tags: string[]
 * }>} changes - Task changes to apply.
 * @returns {object} A new dashboard object with an updated tasks array.
 * @throws {RangeError} When the task does not exist.
 */
function updateDashboardTask(dashboard, taskId, changes) {
  const taskIndex = dashboard.tasks.findIndex((task) => task.id === taskId);

  if (taskIndex === -1) {
    throw new RangeError(`Cannot update missing task "${taskId}".`);
  }

  const existingTask = dashboard.tasks.at(taskIndex);

  return {
    ...dashboard,
    tasks: dashboard.tasks.with(taskIndex, {
      ...existingTask,
      ...changes
    })
  };
}

/**
 * Produces a display-safe summary of owner task counts.
 *
 * @param {Map<string, number>} taskCountByOwner - Owner count map.
 * @returns {Record<string, number>} Plain-object representation.
 */
function serializeTaskCounts(taskCountByOwner) {
  return Object.fromEntries(taskCountByOwner);
}

/**
 * Creates a concise list of task display information sorted by priority.
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
 * }>} Sorted display tasks.
 */
function createSortedTaskDisplay(tasks) {
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

const rawProjectInput = {
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit',
  owner: {
    displayName: 'Ava Patel'
  },
  tags: ['learning', 'es2024', 'javascript'],
  settings: {
    colorScheme: null,
    pageSize: 0,
    showCompletedTasks: false
  }
};

console.log('\n=== Modern JavaScript Toolkit ===\n');
console.log('Loading asynchronous task pages...');

const dashboard = await createProjectDashboard(rawProjectInput);

// Create an independent editable snapshot before applying draft-only changes.
const dashboardDraft = structuredClone(dashboard);

const revisedDashboardDraft = updateDashboardTask(
  dashboardDraft,
  'task_3',
  {
    completed: true,
    title: 'Document collection types and iteration protocols'
  }
);

const sortedOriginalTasks = createSortedTaskDisplay(dashboard.tasks);
const sortedRevisedTasks = createSortedTaskDisplay(revisedDashboardDraft.tasks);

console.log('\nNormalized configuration:');
console.log(dashboard.settings);

console.log('\nProject summary:');
console.log({
  id: dashboard.id,
  label: dashboard.label,
  tags: dashboard.tags,
  completedTaskCount: dashboard.completedTaskCount,
  pendingTaskCount: dashboard.pendingTaskCount,
  taskCountByOwner: serializeTaskCounts(dashboard.taskCountByOwner)
});

console.log('\nOriginal tasks, sorted for display without mutation:');
console.table(sortedOriginalTasks);

console.log('\nDraft task update:');
console.log({
  originalTask: dashboard.tasks.find((task) => task.id === 'task_3'),
  revisedDraftTask: revisedDashboardDraft.tasks.find(
    (task) => task.id === 'task_3'
  ),
  originalTasksArrayWasPreserved:
    dashboard.tasks !== revisedDashboardDraft.tasks,
  originalTaskWasPreserved:
    dashboard.tasks.find((task) => task.id === 'task_3').completed === false
});

console.log('\nRevised draft tasks, sorted for display:');
console.table(sortedRevisedTasks);

console.log('\nParts 1 through 4 are running successfully.');
```

### The Verification

Run:

```bash
npm start
```

Expected output includes the following sections:

```text
=== Modern JavaScript Toolkit ===

Loading asynchronous task pages...

Normalized configuration:
{
  colorScheme: 'system',
  pageSize: 0,
  showCompletedTasks: false
}

Project summary:
{
  id: 'project_3001',
  label: 'Modern JavaScript Toolkit — owned by Ava Patel',
  tags: [
    'learning',
    'es2024',
    'javascript',
    'syntax',
    'functions',
    'collections'
  ],
  completedTaskCount: 2,
  pendingTaskCount: 2,
  taskCountByOwner: { user_1001: 2, user_1002: 2 }
}

Draft task update:
{
  originalTask: {
    id: 'task_3',
    ownerId: 'user_1002',
    title: 'Document collection types',
    completed: false,
    priority: 1,
    tags: [ 'collections', 'javascript' ]
  },
  revisedDraftTask: {
    id: 'task_3',
    ownerId: 'user_1002',
    title: 'Document collection types and iteration protocols',
    completed: true,
    priority: 1,
    tags: [ 'collections', 'javascript' ]
  },
  originalTasksArrayWasPreserved: true,
  originalTaskWasPreserved: true
}

Parts 1 through 4 are running successfully.
```

The `console.table()` output varies slightly by terminal, but it should show task rows sorted by `priority`, then alphabetically by title.

---

# Part 4 Reference: Modern APIs and Defensive Coding

## Optional Chaining: `?.`

Use optional chaining when a value or property path may be `null` or `undefined`.

### Optional property access

```js
const city = user?.address?.city;
```

If `user` or `user.address` is absent, `city` becomes `undefined`.

### Optional array access

```js
const firstTask = tasks?.[0];
```

### Optional method call

```js
logger?.info?.('Application started.');
```

This safely skips the call if `logger` or `logger.info` is `null` or `undefined`.

### Important limitation

Optional chaining does not suppress every error:

```js
const service = {
  send: 'not a function'
};

// Throws TypeError because send exists but is not callable.
service.send?.('Hello');
```

It also does not protect variables that were never declared:

```js
// undeclaredVariable?.property;
// ReferenceError: undeclaredVariable is not defined.
```

---

## Nullish Coalescing: `??`

Use `??` to provide a fallback only for `null` and `undefined`.

```js
const pageSize = input.pageSize ?? 25;
```

This preserves meaningful values such as:

```js
0 ?? 25;       // 0
false ?? true; // false
'' ?? 'text';  // ''
```

Compare that with logical OR:

```js
0 || 25;       // 25
false || true; // true
'' || 'text';  // 'text'
```

Use `||` only when all falsy values should trigger a fallback. Use `??` when only missing values should trigger one.

### Parentheses rule

JavaScript does not allow mixing `??` directly with `&&` or `||` without explicit parentheses:

```js
const result = (firstValue ?? secondValue) || thirdValue;
```

This rule prevents ambiguous expressions.

---

## Logical Assignment Operators

### `||=`

Assign when the current value is falsy:

```js
let endpoint = '';
endpoint ||= 'https://api.example.test';
```

### `&&=`

Assign when the current value is truthy:

```js
let status = 'running';
status &&= status.toUpperCase();
```

### `??=`

Assign when the current value is `null` or `undefined`:

```js
let pageSize;
pageSize ??= 25;
```

For configuration defaults, `??=` is often safest because it preserves `0`, `false`, and empty strings.

---

## `structuredClone()`

Use `structuredClone()` for an independent copy of compatible data:

```js
const copy = structuredClone(original);
```

It supports many common types, including:

- Plain objects
- Arrays
- `Date`
- `Map`
- `Set`
- `ArrayBuffer`
- Typed arrays
- Circular references

It does not clone values such as:

- Functions
- Symbol values
- Some platform-specific objects
- DOM nodes in browser environments

For a known, limited update, prefer a focused immutable update:

```js
const updatedUser = {
  ...user,
  preferences: {
    ...user.preferences,
    colorScheme: 'dark'
  }
};
```

This communicates exactly what changed and avoids copying unrelated data.

---

## Modern Immutable Array APIs

### `.at(index)`

Supports positive and negative indexes:

```js
const items = ['first', 'second', 'third'];

items.at(0);  // 'first'
items.at(-1); // 'third'
```

Unlike bracket access, `.at()` makes last-item access expressive:

```js
const lastItem = items.at(-1);
```

### `.toSorted(compareFunction?)`

Returns a sorted copy:

```js
const numbers = [10, 2, 30];

const sortedNumbers = numbers.toSorted(
  (first, second) => first - second
);

console.log(numbers);       // [10, 2, 30]
console.log(sortedNumbers); // [2, 10, 30]
```

### `.toSpliced(start, deleteCount, ...items)`

Returns a copy with inserted, removed, or replaced items:

```js
const items = ['a', 'b', 'c'];

const removed = items.toSpliced(1, 1);
// ['a', 'c']

const inserted = items.toSpliced(1, 0, 'new');
// ['a', 'new', 'b', 'c']
```

### `.with(index, value)`

Returns a copy with one index replaced:

```js
const statuses = ['pending', 'pending'];

const updatedStatuses = statuses.with(1, 'completed');

// statuses remains ['pending', 'pending']
// updatedStatuses is ['pending', 'completed']
```

`.with()` throws a `RangeError` if the index is outside the array. This is useful because an invalid update is surfaced immediately instead of silently creating an unexpected sparse array.

---

# Final Project Verification

Run every module to confirm the complete tutorial workspace works:

```bash
npm run part:1:variables
npm run part:1:destructuring
npm run part:1:rest-spread
npm run part:2:arrows
npm run part:2:templates
npm run part:2:objects
npm run part:3:sets-maps
npm run part:3:weak-collections
npm run part:3:iteration
npm run part:4:safe-access
npm run part:4:structured-clone
npm run part:4:immutable-arrays
npm start
```

Each command should finish without an uncaught error and print its corresponding completion message.

Your completed project structure is now:

```text
modern-javascript-toolkit/
├── package.json
└── src/
    ├── index.js
    ├── part-1-syntax-ergonomics/
    │   ├── destructuring.js
    │   ├── rest-spread.js
    │   └── variables.js
    ├── part-2-expressive-syntax/
    │   ├── arrow-functions.js
    │   ├── enhanced-objects.js
    │   └── template-literals.js
    ├── part-3-collections-iteration/
    │   ├── iterators-generators.js
    │   ├── sets-and-maps.js
    │   └── weak-collections.js
    └── part-4-defensive-modern-apis/
        ├── immutable-arrays.js
        ├── safe-access.js
        └── structured-clone.js
```
