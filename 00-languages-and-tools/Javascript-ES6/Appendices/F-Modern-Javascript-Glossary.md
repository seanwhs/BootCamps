# Appendix F: Modern JavaScript Glossary

This glossary defines important terms from the series in plain language.

Use it as a reference when you encounter a term such as *iterable*, *shallow copy*, *lexical `this`*, or *nullish value* and want a quick explanation without rereading an entire part.

---

## F.1: Add a Runnable Glossary Demo

### The Target

Create a small runnable module that demonstrates selected glossary terms in code.

### The Concept

Definitions are easier to retain when paired with evidence. Instead of only reading that a `Set` keeps unique values or that a shallow copy shares nested data, you can run examples and observe those behaviors.

### The Implementation

Add this script to your existing `package.json` `"scripts"` object:

### `package.json` — scripts addition

```json
{
  "scripts": {
    "appendix:f:glossary": "node src/appendices/appendix-f-glossary.js"
  }
}
```

Create the following file.

### `src/appendices/appendix-f-glossary.js`

```js
/**
 * Appendix F: Modern JavaScript glossary examples.
 *
 * Run with:
 * npm run appendix:f:glossary
 */

/**
 * Prints a readable console section heading.
 *
 * @param {string} title - Heading to print.
 * @returns {void}
 */
function printSection(title) {
  console.log(`\n--- ${title} ---`);
}

printSection('Binding and reassignment');

const projectName = 'Modern JavaScript Toolkit';

console.log({
  projectName,
  explanation:
    'A binding connects the variable name projectName to this string value.'
});

printSection('Destructuring');

const user = {
  id: 'user_1001',
  displayName: 'Ava Patel'
};

const {
  id: userId,
  displayName
} = user;

console.log({
  userId,
  displayName,
  explanation:
    'Destructuring extracts selected values from an object.'
});

printSection('Rest and spread');

const tags = ['javascript', 'es2024', 'learning'];

const [firstTag, ...remainingTags] = tags;

const expandedTags = [
  'reference',
  ...tags
];

console.log({
  firstTag,
  remainingTags,
  expandedTags,
  explanation:
    'Rest gathers values. Spread expands values.'
});

printSection('Reference identity');

const firstTask = {
  id: 'task_1'
};

const sameLookingTask = {
  id: 'task_1'
};

console.log({
  sameObjectReference: firstTask === firstTask,
  differentObjectReferences: firstTask === sameLookingTask,
  explanation:
    'Objects with matching contents are still different when created separately.'
});

printSection('Shallow copy');

const originalProject = {
  metadata: {
    priority: 'high'
  }
};

const shallowProjectCopy = {
  ...originalProject
};

shallowProjectCopy.metadata.priority = 'urgent';

console.log({
  originalProject,
  shallowProjectCopy,
  nestedObjectIsShared:
    originalProject.metadata === shallowProjectCopy.metadata
});

printSection('Deep copy');

const projectForDeepCopy = {
  metadata: {
    priority: 'high'
  }
};

const deepProjectCopy = structuredClone(projectForDeepCopy);

deepProjectCopy.metadata.priority = 'urgent';

console.log({
  projectForDeepCopy,
  deepProjectCopy,
  nestedObjectIsIndependent:
    projectForDeepCopy.metadata !== deepProjectCopy.metadata
});

printSection('Set and Map');

const uniqueTags = new Set([
  'javascript',
  'javascript',
  'learning'
]);

const taskCountByOwner = new Map([
  ['user_1001', 2]
]);

console.log({
  uniqueTags: [...uniqueTags],
  avaTaskCount: taskCountByOwner.get('user_1001')
});

printSection('Optional chaining and nullish coalescing');

const incompleteSettings = {
  pageSize: 0
};

const colorScheme =
  incompleteSettings.preferences?.colorScheme ?? 'system';

const pageSize = incompleteSettings.pageSize ?? 25;

console.log({
  colorScheme,
  pageSize,
  explanation:
    'Optional chaining avoids unsafe property access; ?? supplies a fallback only for null or undefined.'
});

printSection('Generator and iterable');

/**
 * Produces task IDs lazily.
 *
 * @returns {Generator<string, void, unknown>} Task ID generator.
 */
function* generateTaskIds() {
  yield 'task_1';
  yield 'task_2';
}

console.log({
  generatedTaskIds: [...generateTaskIds()],
  explanation:
    'A generator creates an iterable that produces values one at a time.'
});

console.log('\nAppendix F glossary examples completed successfully.');
```

### The Verification

Run:

```bash
npm run appendix:f:glossary
```

Expected output includes:

```text
--- Shallow copy ---
{
  originalProject: { metadata: { priority: 'urgent' } },
  shallowProjectCopy: { metadata: { priority: 'urgent' } },
  nestedObjectIsShared: true
}

--- Deep copy ---
{
  projectForDeepCopy: { metadata: { priority: 'high' } },
  deepProjectCopy: { metadata: { priority: 'urgent' } },
  nestedObjectIsIndependent: true
}

Appendix F glossary examples completed successfully.
```

---

# F.2: Core Language Terms

## The Target

Define the foundational terms used when writing modern JavaScript.

## The Concept

These words describe how JavaScript stores, evaluates, and organizes values.

## The Implementation

| Term | Definition | Example |
|---|---|---|
| **ECMAScript** | The official language standard that JavaScript implementations follow. | ES6, ES2024 |
| **JavaScript engine** | Software that reads and executes JavaScript. V8 is used by Node.js and Chromium-based browsers. | Node.js uses V8. |
| **Runtime** | The environment where JavaScript executes, including its engine and available APIs. | Node.js, Chrome, Firefox, Safari |
| **Expression** | Code that produces a value. | `price * quantity` |
| **Statement** | An instruction that performs an action. | `if (isReady) { start(); }` |
| **Value** | A piece of data JavaScript can work with. | `'Ava'`, `42`, `true`, `{}` |
| **Primitive** | A non-object value such as a string, number, boolean, bigint, symbol, `null`, or `undefined`. | `'task_1'` |
| **Object** | A collection of properties and methods. | `{ id: 'task_1' }` |
| **Property** | A named value stored on an object. | `task.title` |
| **Method** | A function stored as an object property. | `task.complete()` |
| **Binding** | The connection between a variable name and a value. | `const name = 'Ava';` |
| **Reassignment** | Pointing a `let` variable at a new value. | `page = 2;` |
| **Mutation** | Changing an existing object, array, Map, Set, or other mutable value in place. | `tasks.push(task)` |
| **Scope** | The region of code where a name can be accessed. | A `const` inside an `if` block is block-scoped. |
| **Block scope** | Scope limited to `{ ... }`, used by `const` and `let`. | `if (...) { const value = 1; }` |
| **Hoisting** | JavaScript’s behavior of processing declarations before executing surrounding code. Its details differ for `var`, `let`, `const`, functions, and classes. | Avoid relying on it for unclear code. |
| **Temporal Dead Zone** | The period before a `let` or `const` declaration is initialized, where accessing it throws a `ReferenceError`. | `console.log(name); const name = 'Ava';` |

### The Verification

```bash
node --input-type=module -e "
const projectId = 'project_3001';
let currentPage = 1;

currentPage += 1;

console.log({
  projectId,
  currentPage,
  projectIdType: typeof projectId
});
"
```

Expected output:

```text
{
  projectId: 'project_3001',
  currentPage: 2,
  projectIdType: 'string'
}
```

---

# F.3: Function Terms

## The Target

Define terms related to functions, callbacks, arrow functions, and `this`.

## The Concept

Functions package reusable behavior. Modern JavaScript offers several function forms because different jobs need different behavior.

## The Implementation

| Term | Definition | Example |
|---|---|---|
| **Function declaration** | A named function declared with `function`. | `function formatName() {}` |
| **Function expression** | A function used as a value, often assigned to a variable. | `const formatName = function () {};` |
| **Arrow function** | Concise function syntax that inherits surrounding `this`. | `const double = (value) => value * 2;` |
| **Callback** | A function given to another function to be called later. | `tasks.map((task) => task.title)` |
| **Implicit return** | Automatic return from a one-expression arrow function body without braces. | `const square = (n) => n ** 2;` |
| **Explicit return** | A `return` statement used in a function body. | `return total;` |
| **Parameter** | A named input in a function definition. | `function add(first, second) {}` |
| **Argument** | A value passed when calling a function. | `add(2, 3)` |
| **Rest parameter** | A parameter using `...` that gathers remaining arguments into an array. | `function sum(...values) {}` |
| **Lexical `this`** | Arrow functions inherit `this` from the surrounding scope instead of receiving it from the caller. | `setTimeout(() => this.save(), 100);` |
| **Method receiver** | The object before `.` when a method is called; it often becomes `this` for normal methods. | In `project.getName()`, `project` is the receiver. |
| **Closure** | A function’s ability to retain access to variables from its surrounding scope. | A callback using `projectId` after its outer function returns. |

### The Verification

```bash
node --input-type=module -e "
const createLabel = (name) => \`Welcome, \${name}.\`;

function createCounter() {
  let count = 0;

  return () => {
    count += 1;

    return count;
  };
}

const nextCount = createCounter();

console.log(createLabel('Ava Patel'));
console.log(nextCount());
console.log(nextCount());
"
```

Expected output:

```text
Welcome, Ava Patel.
1
2
```

The returned arrow function is a closure because it retains access to `count`.

---

# F.4: Data Extraction and Copying Terms

## The Target

Define destructuring, rest, spread, shallow copies, deep copies, and immutability.

## The Concept

These terms describe how data moves through an application. Understanding them prevents accidental data leaks and mutation bugs.

## The Implementation

| Term | Definition | Example |
|---|---|---|
| **Destructuring** | Extracting values from arrays or objects into variables. | `const { id } = task;` |
| **Default destructuring value** | A fallback used when the extracted value is `undefined`. | `const { role = 'reader' } = user;` |
| **Renaming during destructuring** | Extracting a property into a differently named local variable. | `const { request_id: requestId } = response;` |
| **Nested destructuring** | Extracting from an object or array inside another object or array. | `const { owner: { name } } = project;` |
| **Rest syntax** | `...` gathering remaining values into a new array or object. | `const [first, ...rest] = values;` |
| **Spread syntax** | `...` expanding an iterable or object into another structure. | `const copy = [...values];` |
| **Shallow copy** | A new outer container that still shares nested object references. | `{ ...project }` |
| **Deep copy** | A new independent copy of nested compatible data. | `structuredClone(project)` |
| **Reference** | An internal link to an object or other non-primitive value. | Two variables can reference the same object. |
| **Reference identity** | Whether two references point to the exact same object. | `firstTask === secondTask` |
| **Immutable update** | Returning a changed copy rather than changing the source value. | `tasks.with(index, updatedTask)` |
| **Structural sharing** | Reusing unchanged nested references while copying only changed paths. | `{ ...project, settings: { ...project.settings, theme: 'dark' } }` |

### The Verification

```bash
node --input-type=module -e "
const source = {
  settings: {
    theme: 'light'
  }
};

const shallowCopy = {
  ...source
};

const deepCopy = structuredClone(source);

console.log({
  shallowNestedReferenceIsShared:
    source.settings === shallowCopy.settings,
  deepNestedReferenceIsShared:
    source.settings === deepCopy.settings
});
"
```

Expected output:

```text
{
  shallowNestedReferenceIsShared: true,
  deepNestedReferenceIsShared: false
}
```

---

# F.5: Collection Terms

## The Target

Define arrays, objects, Maps, Sets, and weak collections.

## The Concept

Collections are storage tools. Choosing the correct one makes your program’s rules clearer.

## The Implementation

| Term | Definition | Example |
|---|---|---|
| **Array** | An ordered collection accessed by numeric index. Duplicates are allowed. | `['task_1', 'task_2']` |
| **Plain object** | A record-like collection of named properties. | `{ id: 'task_1', completed: false }` |
| **Set** | A collection of unique values. | `new Set(['read', 'write'])` |
| **Map** | A collection of key-value pairs whose keys may be any valid key type. | `new Map([['user_1', 2]])` |
| **Key** | A value used to retrieve a Map value. | `'user_1001'` in `map.get('user_1001')` |
| **Value** | The data associated with a Map key. | `2` in `['user_1001', 2]` |
| **WeakSet** | A non-enumerable collection of object-like values that does not strongly retain them. | `new WeakSet()` |
| **WeakMap** | A non-enumerable object-keyed map that does not strongly retain its keys. | `new WeakMap()` |
| **Garbage collection** | Automatic memory recovery for unreachable objects. | Weak collections cooperate with this process. |
| **Enumeration** | Listing every value or entry in a collection. | `[...map.entries()]` |
| **Insertion order** | The order in which values were added. Modern `Set` and `Map` iteration preserves it. | `for (const value of set) {}` |

### The Verification

```bash
node --input-type=module -e "
const tags = new Set(['javascript', 'javascript', 'learning']);
const countByOwner = new Map([
  ['user_1001', 2],
  ['user_1002', 1]
]);

console.log({
  tags: [...tags],
  ownerEntries: [...countByOwner.entries()]
});
"
```

Expected output:

```text
{
  tags: [ 'javascript', 'learning' ],
  ownerEntries: [ [ 'user_1001', 2 ], [ 'user_1002', 1 ] ]
}
```

---

# F.6: Iteration and Generator Terms

## The Target

Define iterable, iterator, generator, `yield`, and asynchronous iteration.

## The Concept

Iteration is the process of handling a sequence one item at a time.

## The Implementation

| Term | Definition | Example |
|---|---|---|
| **Iteration** | Repeatedly processing sequence values. | `for (const task of tasks) {}` |
| **Iterable** | A value that can provide an iterator through `Symbol.iterator`. | Arrays, Sets, Maps, strings, generators |
| **Iterator** | An object with a `.next()` method that returns `{ value, done }`. | `tasks[Symbol.iterator]()` |
| **Iterator result** | The object returned by `.next()`. | `{ value: 'task_1', done: false }` |
| **Generator function** | A function declared with `function*` that creates a generator. | `function* ids() { yield 1; }` |
| **Generator** | The iterable iterator returned by calling a generator function. | `const ids = generateIds();` |
| **`yield`** | Pauses a generator and provides a value to its consumer. | `yield 'task_1';` |
| **Lazy evaluation** | Delaying work until a value is requested. | Generator body begins at `.next()`. |
| **Async iterable** | An object that provides an async iterator through `Symbol.asyncIterator`. | Async generators are async iterables. |
| **Async iterator** | An iterator whose `.next()` operation resolves asynchronously. | Used by `for await...of`. |
| **Async generator** | A generator declared with `async function*`. | `async function* fetchPages() {}` |
| **`for await...of`** | A loop that waits for values from an async iterable. | `for await (const page of pages) {}` |

### The Verification

```bash
node --input-type=module -e "
function* generateTaskIds() {
  yield 'task_1';
  yield 'task_2';
}

const taskIds = generateTaskIds();

console.log(taskIds.next());
console.log(taskIds.next());
console.log(taskIds.next());
"
```

Expected output:

```text
{ value: 'task_1', done: false }
{ value: 'task_2', done: false }
{ value: undefined, done: true }
```

---

# F.7: Defensive Coding Terms

## The Target

Define operators and patterns for handling incomplete or uncertain data safely.

## The Concept

External data is often incomplete. Defensive code clearly distinguishes between:

- Missing values
- Valid falsy values
- Invalid values that should cause errors

## The Implementation

| Term | Definition | Example |
|---|---|---|
| **Optional chaining** | `?.` safely stops a property access or call when the preceding value is `null` or `undefined`. | `user?.profile?.name` |
| **Nullish value** | A value that is specifically `null` or `undefined`. | `null ?? 'fallback'` |
| **Nullish coalescing** | `??` supplies a fallback only for nullish values. | `pageSize ?? 25` |
| **Logical OR** | `||` supplies a fallback for all falsy values. | `name || 'Anonymous'` |
| **Logical assignment** | Assignment shorthand using `&&=`, `||=`, or `??=`. | `theme ??= 'system'` |
| **Falsy value** | A value treated as false in a boolean context. | `false`, `0`, `''`, `NaN`, `null`, `undefined` |
| **Truthy value** | A value treated as true in a boolean context. | Objects, non-empty strings, non-zero numbers |
| **Guard clause** | An early check that exits a function when required conditions are not met. | `if (!task) throw new Error(...);` |
| **Validation** | Checking whether input meets expected rules. | Confirming an ID is a non-empty string. |
| **Normalization** | Converting valid but inconsistent input into a standard form. | Trimming names and deduplicating tags. |
| **Fallback** | A value used when the preferred value is absent. | `theme ?? 'system'` |

### The Verification

```bash
node --input-type=module -e "
const settings = {
  pageSize: 0,
  enabled: false,
  theme: null
};

console.log({
  pageSize: settings.pageSize ?? 25,
  enabled: settings.enabled ?? true,
  theme: settings.theme ?? 'system',
  missingCity: settings.profile?.address?.city ?? 'Unknown'
});
"
```

Expected output:

```text
{
  pageSize: 0,
  enabled: false,
  theme: 'system',
  missingCity: 'Unknown'
}
```

---

# F.8: Array API Terms

## The Target

Define modern immutable array methods and their mutating older counterparts.

## The Concept

Modern array APIs let you derive new arrays without changing the original. This makes shared data easier to manage.

## The Implementation

| Method | Definition | Mutates source? | Example |
|---|---|---:|---|
| `.at(index)` | Reads an item by index; supports negative indexes. | No | `tasks.at(-1)` |
| `.toSorted(compareFn)` | Returns a sorted copy. | No | `tasks.toSorted(compareTasks)` |
| `.toSpliced(start, deleteCount, ...items)` | Returns a copy with items inserted, removed, or replaced. | No | `tasks.toSpliced(1, 1)` |
| `.with(index, value)` | Returns a copy with one position replaced. | No | `tasks.with(0, task)` |
| `.sort(compareFn)` | Sorts the source array in place. | Yes | `tasks.sort(compareTasks)` |
| `.splice(start, deleteCount, ...items)` | Inserts, removes, or replaces in the source array. | Yes | `tasks.splice(1, 1)` |
| `.push(...items)` | Adds items to the source array. | Yes | `tasks.push(task)` |
| `.pop()` | Removes the last source item. | Yes | `tasks.pop()` |

### The Verification

```bash
node --input-type=module -e "
const values = [3, 1, 2];

console.log({
  source: values,
  last: values.at(-1),
  sorted: values.toSorted((first, second) => first - second),
  replaced: values.with(0, 4),
  removedMiddle: values.toSpliced(1, 1)
});
"
```

Expected output:

```text
{
  source: [ 3, 1, 2 ],
  last: 2,
  sorted: [ 1, 2, 3 ],
  replaced: [ 4, 1, 2 ],
  removedMiddle: [ 3, 2 ]
}
```

---

# F.9: Module and Asynchronous Terms

## The Target

Define module boundaries, Promises, and async control flow.

## The Concept

Modules organize code into files with explicit imports and exports. Promises and async functions represent work that completes later.

## The Implementation

| Term | Definition | Example |
|---|---|---|
| **ES module** | A JavaScript file using `import` and `export`. | `export function createTask() {}` |
| **Named export** | An explicitly exported value imported by the same name. | `export { createTask };` |
| **Default export** | One primary module export imported with a caller-chosen name. | `export default createTask;` |
| **Dependency** | A module, package, or service another module needs. | `import assert from 'node:assert/strict';` |
| **Promise** | An object representing a future completion value or failure. | `fetchProject()` |
| **Resolved Promise** | A Promise that completed successfully. | `Promise.resolve('done')` |
| **Rejected Promise** | A Promise that completed with failure. | `Promise.reject(new Error())` |
| **`async` function** | A function that always returns a Promise. | `async function load() {}` |
| **`await`** | Pauses an async function until a Promise settles. | `const user = await loadUser();` |
| **Concurrency** | Managing multiple in-progress tasks during overlapping time periods. | `await Promise.all([...])` |
| **Sequential execution** | Waiting for one operation before starting the next. | `await first(); await second();` |
| **Error propagation** | A rejected Promise or thrown error moving outward until handled. | `try { await save(); } catch (error) {}` |

### The Verification

```bash
node --input-type=module -e "
async function loadProjectName() {
  return 'Modern JavaScript Toolkit';
}

const projectName = await loadProjectName();

console.log({
  projectName,
  valueType: typeof projectName
});
"
```

Expected output:

```text
{
  projectName: 'Modern JavaScript Toolkit',
  valueType: 'string'
}
```

---

# F.10: Quick Glossary Review

## The Target

Use the glossary to identify the correct feature for common problems.

## The Concept

The fastest way to retain terminology is to connect it with a real decision.

## The Implementation

| If you need to… | Use or remember… |
|---|---|
| Prevent variable reassignment | `const` |
| Reassign a variable intentionally | `let` |
| Extract `name` from an object | Object destructuring |
| Copy an array’s outer container | Array spread: `[...items]` |
| Safely read a missing nested property | Optional chaining: `?.` |
| Use a default only for `null` or `undefined` | Nullish coalescing: `??` |
| Keep only unique tags | `Set` |
| Associate counts with owner IDs | `Map` |
| Associate temporary metadata with an object | `WeakMap` |
| Create a safe independent copy of compatible nested data | `structuredClone()` |
| Sort without changing the source array | `.toSorted()` |
| Replace one array item without mutation | `.with()` |
| Produce values one at a time | Generator function |
| Process values arriving over time | Async generator and `for await...of` |
| Preserve an input while returning a revised version | Immutable update |

### The Verification

Run the glossary demo again:

```bash
npm run appendix:f:glossary
```

Confirm it ends with:

```text
Appendix F glossary examples completed successfully.
```
