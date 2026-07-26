# ES6+ Modern JavaScript  
## Student Workbook

**Series:** *The Contemporary Developer Kit*  
**Recommended runtime:** Node.js 22+  
**Project folder:** `modern-javascript-toolkit`

---

## How to Use This Workbook

For every module:

1. Read the related tutorial part.
2. Complete the prediction before running code.
3. Write or adapt the code yourself.
4. Run the verification command.
5. Record what happened.
6. Complete the reflection prompts.

Use this workbook as a personal record of your progress and a practical review guide.

---

# Student Profile

| Field | Your Answer |
|---|---|
| Name |  |
| Start date |  |
| Node.js version |  |
| Code editor |  |
| Operating system |  |
| Main learning goal |  |
| Final completion date |  |

Run this command and record the result:

```bash
node --version
```

**My Node.js version:**

```text

```

---

# Primer 0: Learning Setup and Workflow

## Learning Objectives

By the end of this primer, you should be able to:

- Run JavaScript with Node.js.
- Create a project directory.
- Use `package.json`.
- Run npm scripts.
- Read basic console output and errors.

## Environment Checklist

Mark each completed item.

- [ ] Node.js is installed.
- [ ] npm is installed.
- [ ] I created `modern-javascript-toolkit`.
- [ ] I created `src/index.js`.
- [ ] I created `package.json`.
- [ ] I ran `npm start`.
- [ ] I can open a terminal in the project root.

## Command Practice

| Command | What it does | Result |
|---|---|---|
| `node --version` | Shows Node.js version |  |
| `npm --version` | Shows npm version |  |
| `pwd` or `Get-Location` | Shows current folder |  |
| `npm start` | Runs the project entry point |  |
| `npm run` | Lists scripts |  |

## Reflection

1. What is the difference between Node.js and npm?

```text

```

2. Why should you run verification commands after each implementation step?

```text

```

3. What is the project root directory?

```text

```

---

# Primer 1: Runtime and Tooling Basics

## Learning Objectives

- Explain what a runtime is.
- Read command-line arguments.
- Read environment variables.
- Use the Node.js REPL.
- Distinguish Node.js APIs from browser APIs.

## Quick Knowledge Check

### 1. What does this command do?

```bash
node src/index.js
```

```text

```

### 2. What is `process.argv` used for?

```text

```

### 3. What is `process.env` used for?

```text

```

### 4. Which runtime normally provides `document`?

- [ ] Node.js
- [ ] Web browser
- [ ] npm
- [ ] `package.json`

## Command-Line Argument Exercise

Run:

```bash
node src/primers/command-line-report.js "Workbook Practice" 5
```

Record the output:

```text

```

Change the count to `1`. What changes in the output?

```text

```

Try invalid input:

```bash
node src/primers/command-line-report.js "Workbook Practice" invalid
```

What error type appears?

```text

```

## Environment Variable Exercise

Run without environment variables:

```bash
node src/primers/environment-configuration.js
```

Then run with values.

macOS, Linux, Git Bash, or WSL:

```bash
APP_ENV=production PROJECT_PAGE_SIZE=50 node src/primers/environment-configuration.js
```

Windows PowerShell:

```powershell
$env:APP_ENV='production'
$env:PROJECT_PAGE_SIZE='50'
node src/primers/environment-configuration.js
```

| Setting | Default value | Custom value |
|---|---:|---:|
| `APP_ENV` |  |  |
| `PROJECT_PAGE_SIZE` |  |  |

## Reflection

Why should real passwords, API tokens, and private keys not be written directly in source files?

```text

```

---

# Primer 2: Values, Types, Objects, and Arrays

## Learning Objectives

- Identify common JavaScript types.
- Create and read objects.
- Create and transform arrays.
- Explain reference identity.
- Distinguish shallow copies from deep copies.

## Type Classification

Fill in the expected result of `typeof`.

| Value | `typeof` result |
|---|---|
| `'Ava'` |  |
| `42` |  |
| `false` |  |
| `undefined` |  |
| `null` |  |
| `{}` |  |
| `[]` |  |

## Object Practice

Given:

```js
const project = {
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit',
  owner: {
    displayName: 'Ava Patel'
  }
};
```

Write code that reads the project name:

```js

```

Write code that reads the owner display name:

```js

```

Write code that safely reads a missing city:

```js

```

## Array Practice

Given:

```js
const stages = ['validate', 'build', 'test', 'deploy'];
```

Write code to get:

| Requirement | Your Code |
|---|---|
| First stage |  |
| Last stage |  |
| Number of stages |  |
| A new array with an added `'monitor'` stage |  |

## Reference Prediction

Predict the output:

```js
const firstProject = {
  name: 'Toolkit'
};

const secondProject = firstProject;

secondProject.name = 'Updated Toolkit';

console.log(firstProject.name);
```

**Prediction:**

```text

```

**Actual result:**

```text

```

Why did this happen?

```text

```

## Copying Practice

Complete the table.

| Technique | Copies only outer container? | Nested values independent? |
|---|---:|---:|
| `{ ...object }` |  |  |
| `[...array]` |  |  |
| `structuredClone(value)` |  |  |

---

# Primer 3: Functions, Control Flow, and Basic Iteration

## Learning Objectives

- Define and call functions.
- Explain parameters and arguments.
- Use conditions.
- Use `for...of`.
- Use `.map()`, `.filter()`, `.find()`, and `.reduce()`.

## Functions

Given:

```js
function add(firstValue, secondValue) {
  return firstValue + secondValue;
}
```

| Term | Example |
|---|---|
| Function name |  |
| Parameters |  |
| Arguments in `add(2, 3)` |  |
| Return value of `add(2, 3)` |  |

## Condition Practice

Write a function that returns `'completed'` when `completed` is true and `'pending'` otherwise.

```js

```

## Loop Practice

Given:

```js
const taskTitles = [
  'Install Node.js',
  'Create project files',
  'Run verification'
];
```

Write a `for...of` loop that prints every title.

```js

```

## Array Method Matching

| Requirement | Best method |
|---|---|
| Create an array of only task titles |  |
| Keep only incomplete tasks |  |
| Find one task by ID |  |
| Count completed tasks |  |

## Array Method Practice

Given:

```js
const tasks = [
  {
    id: 'task_1',
    title: 'Write examples',
    completed: true
  },
  {
    id: 'task_2',
    title: 'Review examples',
    completed: false
  }
];
```

Write code to create `pendingTaskTitles`.

```js

```

Write code to count completed tasks.

```js

```

---

# Primer 4: Modules, Files, and Debugging Basics

## Learning Objectives

- Use `import` and `export`.
- Understand relative paths.
- Read stack traces.
- Use structured logging.
- Use watch mode and the debugger.

## Module Vocabulary

| Term | Definition |
|---|---|
| Export |  |
| Import |  |
| Named export |  |
| Relative path |  |
| Entry point |  |
| Stack trace |  |

## Import Path Practice

Given this structure:

```text
src/
└── primers/
    └── module-demo/
        ├── module-demo.js
        ├── domain/
        │   └── task.js
        └── utilities/
            └── validation.js
```

What import path should `domain/task.js` use to import `requireNonEmptyString` from `utilities/validation.js`?

```js

```

What import path should `module-demo.js` use to import `createTask` from `domain/task.js`?

```js

```

## Debugging Checklist

When code fails, check each item:

- [ ] Read the error name.
- [ ] Read the complete error message.
- [ ] Open the referenced file and line number.
- [ ] Confirm the file was saved.
- [ ] Confirm the terminal is in the project root.
- [ ] Inspect relevant values with `console.log()`.
- [ ] Check import and export names.
- [ ] Make one change at a time.
- [ ] Rerun the exact verification command.

---

# Part 0: Introduction

## Series Architecture

Draw or describe the toolkit architecture:

```text
modern-javascript-toolkit/
├── package.json
├── src/
│   ├── index.js
│   ├── primers/
│   ├── part-1-syntax-ergonomics/
│   ├── part-2-expressive-syntax/
│   ├── part-3-collections-iteration/
│   ├── part-4-defensive-modern-apis/
│   └── appendices/
```

What is the role of `package.json`?

```text

```

What does `"type": "module"` enable?

```text

```

What Node.js version does the series recommend?

```text

```

---

# Part 1: Syntax Ergonomics and Destructuring

## Learning Objectives

- Use `const` and `let`.
- Extract array values with destructuring.
- Extract object values with destructuring.
- Use rest and spread syntax.
- Create immutable updates.

---

## 1. Variables and Scope

### Choose the Correct Declaration

| Scenario | `const` or `let`? | Why? |
|---|---|---|
| Project ID never changes |  |  |
| Current page increments |  |  |
| Array reference remains stable |  |  |
| Retry counter increases |  |  |

### Predict the Result

```js
if (true) {
  const status = 'active';
}

// console.log(status);
```

What happens if the final line is uncommented?

```text

```

### Practice

Rewrite this using modern declarations:

```js
var projectName = 'Toolkit';
var taskCount = 0;

taskCount = taskCount + 1;
```

```js

```

---

## 2. Array Destructuring

Given:

```js
const stages = ['validate', 'build', 'test', 'deploy'];
```

Write code to extract:

| Requirement | Your Code |
|---|---|
| First stage |  |
| First and second stages |  |
| First and last stage using a rest value |  |
| Skip `'build'` and extract `'test'` |  |

### Default Value Practice

Given:

```js
const coordinates = [48.8566];
```

Write destructuring code so longitude becomes `0` when absent.

```js

```

---

## 3. Object Destructuring

Given:

```js
const user = {
  id: 'user_1001',
  displayName: 'Ava Patel',
  role: 'editor'
};
```

Write destructuring code to extract `displayName` and `role`.

```js

```

Rename `id` to `userId`.

```js

```

### Nested Default Practice

Given:

```js
const order = {
  id: 'order_7001'
};
```

Write destructuring code that safely produces:

```js
const city = 'Not provided';
```

when `shippingAddress` is absent.

```js

```

---

## 4. Rest and Spread

### Rest Syntax

Given:

```js
const roles = ['admin', 'editor', 'reader', 'guest'];
```

Extract the first role and store all remaining roles in `remainingRoles`.

```js

```

### Spread Syntax

Given:

```js
const defaultPermissions = ['read'];
```

Create a new array containing `'read'` and `'write'`.

```js

```

Given:

```js
const user = {
  id: 'user_1001',
  role: 'reader'
};
```

Create a new user object whose role is `'editor'`.

```js

```

### Reflection

Why is this only a shallow copy?

```js
const copied = {
  ...project
};
```

```text

```

---

# Part 2: Arrow Functions, Templates, and Expressive Syntax

## Learning Objectives

- Write arrow functions.
- Use implicit returns.
- Understand lexical `this`.
- Use template literals.
- Use shorthand object properties and computed keys.

---

## 1. Arrow Function Conversion

Convert this function declaration:

```js
function double(value) {
  return value * 2;
}
```

Into an arrow function with an implicit return:

```js

```

Convert this function so it returns an object:

```js
function createTask(title) {
  return {
    title,
    completed: false
  };
}
```

```js

```

Why are parentheses required around the returned object?

```text

```

---

## 2. `this` Decision

For each scenario, choose the best function style.

| Scenario | Arrow function? | Method syntax? |
|---|---:|---:|
| `.map()` callback |  |  |
| Object method using `this.name` |  |  |
| `setTimeout()` callback inside a class method |  |  |
| Utility that formats a string |  |  |

---

## 3. Template Literal Practice

Write a template literal that creates:

```text
Project "Modern JavaScript Toolkit" has 3 pending tasks.
```

Variables:

```js
const projectName = 'Modern JavaScript Toolkit';
const pendingTaskCount = 3;
```

```js

```

Write a multiline release note:

```js

```

---

## 4. Enhanced Object Literal Practice

Given:

```js
const id = 'task_1';
const title = 'Write workbook';
const propertyName = 'priority';
```

Create an object using:

- Shorthand properties
- A computed property name
- A concise method named `getLabel`

```js

```

Expected shape:

```js
{
  id: 'task_1',
  title: 'Write workbook',
  priority: 1,
  getLabel() {
    // ...
  }
}
```

---

# Part 3: Collections and Iteration Protocols

## Learning Objectives

- Choose between Array, Object, Set, and Map.
- Understand WeakMap and WeakSet use cases.
- Use iterators and generators.
- Use async iteration.

---

## 1. Collection Selection

Choose the most appropriate collection.

| Requirement | Best Collection | Why? |
|---|---|---|
| Ordered task list |  |  |
| Unique tags |  |  |
| Project record with known fields |  |  |
| Task count by owner ID |  |  |
| Private metadata attached to object instances |  |  |
| Track whether a request object was validated |  |  |

---

## 2. Set Practice

Given:

```js
const rawTags = [
  'javascript',
  'collections',
  'javascript',
  'learning'
];
```

Create `uniqueTags` as an array with duplicates removed.

```js

```

Expected result:

```js
['javascript', 'collections', 'learning'];
```

---

## 3. Map Practice

Create a `Map` named `taskCountByOwner` containing:

```text
user_1001 -> 2
user_1002 -> 1
```

```js

```

Write code to increment the count for `user_1001`.

```js

```

Convert the Map to a plain object.

```js

```

---

## 4. Object Reference Identity

Predict the result:

```js
const firstTask = {
  id: 'task_1'
};

const secondTask = {
  id: 'task_1'
};

const tasks = new Set([firstTask]);

console.log(tasks.has(secondTask));
```

**Prediction:**

```text

```

Why?

```text

```

---

## 5. Generator Practice

Write a generator that yields:

```text
validate
build
test
deploy
```

```js

```

Write code that consumes it with `for...of`.

```js

```

---

## 6. Async Iteration Practice

Write an async generator that yields two task pages.

```js

```

Write a `for await...of` loop that collects all task IDs.

```js

```

---

# Part 4: Modern Utility APIs and Defensive Coding

## Learning Objectives

- Use optional chaining.
- Use nullish coalescing.
- Use logical assignment.
- Use `structuredClone()`.
- Use immutable array methods.

---

## 1. Optional Chaining

Given:

```js
const project = {
  owner: null
};
```

Write code that safely reads the owner display name.

```js

```

Use `'Unassigned owner'` as the fallback.

```js

```

---

## 2. `??` Versus `||`

Complete the expected output.

| Expression | Result |
|---|---|
| `0 ?? 25` |  |
| `0 || 25` |  |
| `false ?? true` |  |
| `false || true` |  |
| `'' ?? 'Anonymous'` |  |
| `'' || 'Anonymous'` |  |

When should you prefer `??`?

```text

```

---

## 3. Logical Assignment

Given:

```js
const settings = {
  theme: null,
  pageSize: 0,
  enabled: false
};
```

Write code that defaults:

- `theme` to `'system'`
- `pageSize` to `25` only if missing
- `enabled` to `true` only if missing

```js

```

What should the final object contain?

```text

```

---

## 4. Structured Cloning

Given:

```js
const project = {
  metadata: {
    priority: 'high'
  }
};
```

Write code that creates an independent copy and changes the copy’s priority to `'low'`.

```js

```

What should the original priority remain?

```text

```

---

## 5. Immutable Arrays

Given:

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
```

Write code that creates a new array where `task_2` is completed.

```js

```

Write code that returns task IDs sorted alphabetically without mutating the source array.

```js

```

Write code that gets the final task with `.at()`.

```js

```

---

# Final Capstone Workbook Project

## Project: Build a Safe Async Project Dashboard

Create a dashboard function that accepts:

- A project record
- Asynchronously delivered task pages

The function should return:

- A project label
- Normalized settings
- Unique tags
- Completed task count
- Pending task titles
- A `Map` of owner task counts
- Tasks sorted by priority

## Input Example

```js
const project = {
  id: 'project_3001',
  name: 'Modern JavaScript Toolkit',
  owner: {
    displayName: 'Ava Patel'
  },
  tags: ['learning', 'javascript', 'javascript'],
  settings: {
    pageSize: 0
  }
};
```

## Required Features Checklist

- [ ] Destructure project input.
- [ ] Use defaults for missing values.
- [ ] Use `?.` for optional nested values.
- [ ] Use `??` to preserve a valid page size of `0`.
- [ ] Use a `Set` for unique tags.
- [ ] Use a `Map` for owner task counts.
- [ ] Use `for await...of` to process pages.
- [ ] Use `.toSorted()` to create sorted display tasks.
- [ ] Do not mutate source project data.
- [ ] Verify results with assertions or structured console output.

## My Design Notes

### Function signature

```js

```

### Task page format

```js

```

### Data structures I will use

```text

```

### Expected output shape

```js

```

### Verification command

```bash

```

---

# Personal Progress Tracker

| Module | Started | Verified | Notes |
|---|---:|---:|---|
| Primer 0 | [ ] | [ ] |  |
| Primer 1 | [ ] | [ ] |  |
| Primer 2 | [ ] | [ ] |  |
| Primer 3 | [ ] | [ ] |  |
| Primer 4 | [ ] | [ ] |  |
| Part 0 | [ ] | [ ] |  |
| Part 1 | [ ] | [ ] |  |
| Part 2 | [ ] | [ ] |  |
| Part 3 | [ ] | [ ] |  |
| Part 4 | [ ] | [ ] |  |
| Appendix A | [ ] | [ ] |  |
| Appendix B | [ ] | [ ] |  |
| Appendix C | [ ] | [ ] |  |
| Appendix D | [ ] | [ ] |  |
| Appendix E | [ ] | [ ] |  |
| Appendix F | [ ] | [ ] |  |
| Appendix G | [ ] | [ ] |  |

---

# Final Reflection

## 1. Which modern JavaScript feature was most useful to you?

```text

```

## 2. Which feature was initially confusing but now makes sense?

```text

```

## 3. Which feature will you use first in a real project?

```text

```

## 4. What is one old JavaScript pattern you plan to replace?

```text

```

## 5. What is your next JavaScript learning goal?

```text

```

# Appendix A Workbook: ECMAScript Compatibility

## Compatibility Concepts

Match each concern with the correct solution.

| Concern | Best approach |
|---|---|
| An older runtime cannot parse optional chaining syntax |  |
| A runtime parses code but lacks `.toSorted()` |  |
| You need to know whether `structuredClone()` exists |  |
| You control the backend Node.js runtime |  |
| You need to support legacy browsers |  |

Choose from:

```text
Feature detection
Upgrade Node.js
Transpilation
Polyfill or compatibility helper
Build pipeline with transpilation and tested polyfills
```

## Feature Detection Practice

Write a check that reports whether `.toSorted()` is available.

```js

```

Write a check that reports whether `structuredClone()` is available.

```js

```

## Compatibility Reflection

Why is feature detection more reliable than browser user-agent detection?

```text

```

---

# Appendix B Workbook: Debugging Practice

## Debugging Scenario 1: Missing Nested Property

This code fails:

```js
const order = {
  id: 'order_7001'
};

const {
  shippingAddress: {
    city
  }
} = order;
```

### Questions

1. What error category is likely to occur?

```text

```

2. Why does the error occur?

```text

```

3. Rewrite the destructuring code safely.

```js

```

---

## Debugging Scenario 2: Incorrect Object Copy

Predict the result:

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
```

**Prediction:**

```text

```

Why?

```text

```

Write a safe deep-copy alternative:

```js

```

Write a targeted immutable-update alternative:

```js

```

---

## Debugging Scenario 3: `||` Replaces Valid Values

This code changes a valid page size of `0`:

```js
const pageSize = settings.pageSize || 25;
```

Rewrite it so that only `null` and `undefined` trigger the fallback.

```js

```

---

## Debugging Scenario 4: Array Mutation

This code changes the original array:

```js
const sortedTasks = tasks.sort(compareTasks);
```

Rewrite it without mutation.

```js

```

This code changes the original array:

```js
tasks.splice(1, 1);
```

Rewrite it without mutation.

```js

```

---

## Debugging Log Template

Use this template whenever a script fails.

| Question | Notes |
|---|---|
| What command did I run? |  |
| What error name appeared? |  |
| What is the full error message? |  |
| Which file and line are named? |  |
| What did I expect to happen? |  |
| What actually happened? |  |
| What value should I inspect? |  |
| What single change will I test next? |  |
| Did the verification pass afterward? |  |

---

# Appendix C Workbook: Code Style Review

## Code Review Checklist

Use this checklist when reviewing your own JavaScript.

### Variables

- [ ] `const` is used when reassignment is not required.
- [ ] `let` is used only when reassignment is intentional.
- [ ] `var` is not used in new code.
- [ ] Names describe the data they hold.
- [ ] Numeric values include units where useful, such as `timeoutMilliseconds`.

### Functions

- [ ] Function names describe an action.
- [ ] Functions have one understandable responsibility.
- [ ] Public or reusable functions validate important inputs.
- [ ] Errors explain what failed and why.
- [ ] Functions return predictable values.

### Objects and Arrays

- [ ] Object and array updates avoid unnecessary mutation.
- [ ] `.toSorted()`, `.toSpliced()`, and `.with()` are used where immutable changes are needed.
- [ ] `Set` is used for unique values.
- [ ] `Map` is used for intentional key-value relationships.

### Defensive Code

- [ ] Optional chaining is used only for genuinely optional paths.
- [ ] `??` is used when `0`, `false`, and `''` must be preserved.
- [ ] Required values are validated rather than silently hidden with fallbacks.

### Modules and Comments

- [ ] Module names match their responsibilities.
- [ ] Import paths are correct and include `.js`.
- [ ] Comments explain decisions rather than obvious syntax.
- [ ] The code passes linting and formatting checks.

---

## Style Improvement Exercise

Improve this code:

```js
var d = [];
var x = 0;

function doStuff(items) {
  for (var i = 0; i < items.length; i++) {
    if (items[i].done == true) {
      d.push(items[i]);
      x = x + 1;
    }
  }

  return d;
}
```

### Problems I Notice

```text

```

### My Improved Version

```js

```

### Suggested Solution

```js
/**
 * Returns completed tasks without mutating the source task array.
 *
 * @param {Array<{ completed: boolean }>} tasks - Tasks to inspect.
 * @returns {Array<{ completed: boolean }>} Completed tasks.
 */
function getCompletedTasks(tasks) {
  return tasks.filter((task) => task.completed);
}
```

---

# Appendix D Workbook: Feature Recall Drill

Complete the following table without looking at the cheat sheet.

| Need | Modern JavaScript feature |
|---|---|
| Stable variable binding |  |
| Intentional reassignment |  |
| Extract object properties |  |
| Gather remaining function arguments |  |
| Copy an array |  |
| Merge object properties |  |
| Short callback function |  |
| Dynamic string interpolation |  |
| Unique values |  |
| Key-value relationship |  |
| Safe nested property read |  |
| Default only when null or undefined |  |
| Deep-copy compatible data |  |
| Read final array item |  |
| Sort without mutation |  |
| Replace one array item without mutation |  |
| Process async values one at a time |  |

## Syntax Recall

Write the syntax for each feature.

### Object destructuring

```js

```

### Array rest syntax

```js

```

### Object spread update

```js

```

### Optional chaining with fallback

```js

```

### Unique array values with `Set`

```js

```

### Immutable array replacement with `.with()`

```js

```

### Async iteration

```js

```

---

# Appendix E Workbook: Exercise Planning Sheets

Use these planning sheets before implementing the Appendix E exercises.

## Exercise 1: Safe Public Profile

### Inputs

```text

```

### Sensitive fields to exclude

```text

```

### Features to use

- [ ] Object destructuring
- [ ] Object rest syntax
- [ ] Default values
- [ ] `Set`
- [ ] Spread syntax
- [ ] Template literal

### Expected output

```js

```

---

## Exercise 2: Expressive Task Summary

### Input shape

```js

```

### Computed property name

```text

```

### Status rule

```text

```

### My implementation

```js

```

---

## Exercise 3: Group Unique Task IDs

### Why use a `Set`?

```text

```

### Why use a `Map`?

```text

```

### Algorithm steps

1. 

2. 

3. 

4. 

### My implementation

```js

```

---

## Exercise 4 and 5: Generator and Async Generator

### Synchronous generator use case

```text

```

### Async generator use case

```text

```

### What does `yield` do?

```text

```

### What does `for await...of` do?

```text

```

---

## Exercise 8: Dashboard Design

### Input assumptions

```text

```

### Defaults

| Property | Fallback |
|---|---|
| Project ID |  |
| Project name |  |
| Owner display name |  |
| Page size |  |

### Internal data structures

| Data | Structure | Reason |
|---|---|---|
| Unique tags |  |  |
| Owner task counts |  |  |
| Received tasks |  |  |
| Sorted display tasks |  |  |

### Verification criteria

- [ ] Project label is correct.
- [ ] A page size of `0` remains `0`.
- [ ] Tags contain no duplicates.
- [ ] Completed tasks are counted.
- [ ] Pending titles are collected.
- [ ] Owner counts are correct.
- [ ] Sorted tasks are in ascending priority order.
- [ ] Source data is not mutated.

---

# Appendix F Workbook: Glossary Flashcards

Cut these into cards, copy them into a flashcard application, or cover the definition column and test yourself.

| Term | My Definition |
|---|---|
| Binding |  |
| Reassignment |  |
| Mutation |  |
| Scope |  |
| Block scope |  |
| Primitive value |  |
| Reference value |  |
| Reference identity |  |
| Destructuring |  |
| Rest syntax |  |
| Spread syntax |  |
| Shallow copy |  |
| Deep copy |  |
| Iterable |  |
| Iterator |  |
| Generator |  |
| Async generator |  |
| Optional chaining |  |
| Nullish coalescing |  |
| Logical assignment |  |
| Set |  |
| Map |  |
| WeakMap |  |
| Garbage collection |  |
| ES module |  |
| Promise |  |
| `await` |  |

---

# Appendix G Workbook: Migration Planning

## Legacy-Code Inventory

Use this table when reviewing an older JavaScript project.

| Legacy Pattern Found | File and Line | Modern Alternative | Verified? |
|---|---|---|---:|
| `var` |  | `const` or `let` | [ ] |
| String concatenation |  | Template literals | [ ] |
| Manual null check |  | `?.` and `??` | [ ] |
| Duplicate filter |  | `Set` | [ ] |
| Object dictionary |  | `Map`, if appropriate | [ ] |
| `.sort()` mutation |  | `.toSorted()` | [ ] |
| `.splice()` mutation |  | `.toSpliced()` | [ ] |
| Direct index assignment |  | `.with()` | [ ] |
| JSON cloning |  | `structuredClone()` or targeted update | [ ] |
| Callback nesting |  | Promise / `async` / `await` | [ ] |
| CommonJS modules |  | ES modules | [ ] |

---

## Migration Safety Checklist

Before merging a modernization change:

- [ ] I understand the old code’s behavior.
- [ ] I changed one focused concern.
- [ ] Existing tests still pass.
- [ ] I added or updated a test when behavior was unclear.
- [ ] I checked whether mutation behavior changed.
- [ ] I checked runtime compatibility.
- [ ] I ran linting and formatting.
- [ ] I reviewed error handling.
- [ ] I documented any deliberate compatibility fallback.

---

# Answer Key

> Use this section after attempting the workbook exercises independently.

## Primer 2: Type Classification

| Value | `typeof` result |
|---|---|
| `'Ava'` | `'string'` |
| `42` | `'number'` |
| `false` | `'boolean'` |
| `undefined` | `'undefined'` |
| `null` | `'object'` |
| `{}` | `'object'` |
| `[]` | `'object'` |

To identify an array:

```js
Array.isArray(value);
```

To identify `null`:

```js
value === null;
```

---

## Primer 3: Array Method Matching

| Requirement | Best method |
|---|---|
| Create an array of only task titles | `.map()` |
| Keep only incomplete tasks | `.filter()` |
| Find one task by ID | `.find()` |
| Count completed tasks | `.reduce()` or `.filter().length` |

Example:

```js
const pendingTaskTitles = tasks
  .filter((task) => !task.completed)
  .map((task) => task.title);
```

---

## Part 1: Safe Nested Destructuring

```js
const {
  shippingAddress: {
    city = 'Not provided'
  } = {}
} = order;
```

---

## Part 1: Rest and Spread

```js
const [firstRole, ...remainingRoles] = roles;
```

```js
const editorPermissions = [
  ...defaultPermissions,
  'write'
];
```

```js
const editorUser = {
  ...user,
  role: 'editor'
};
```

---

## Part 2: Arrow Returning an Object

```js
const createTask = (title) => ({
  title,
  completed: false
});
```

The parentheses are required because otherwise JavaScript reads `{}` as the arrow function’s block body rather than as an object literal.

---

## Part 3: Collection Selection

| Requirement | Best Collection |
|---|---|
| Ordered task list | `Array` |
| Unique tags | `Set` |
| Project record with known fields | Plain object |
| Task count by owner ID | `Map` |
| Private metadata attached to object instances | `WeakMap` |
| Track whether a request object was validated | `WeakSet` |

---

## Part 3: Generator Solution

```js
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

---

## Part 4: Safe Optional Access

```js
const ownerName =
  project.owner?.displayName ?? 'Unassigned owner';
```

---

## Part 4: `??` Versus `||`

| Expression | Result |
|---|---|
| `0 ?? 25` | `0` |
| `0 || 25` | `25` |
| `false ?? true` | `false` |
| `false || true` | `true` |
| `'' ?? 'Anonymous'` | `''` |
| `'' || 'Anonymous'` | `'Anonymous'` |

Prefer `??` when `0`, `false`, and empty strings are valid values that must be preserved.

---

## Part 4: Logical Assignment Solution

```js
settings.theme ??= 'system';
settings.pageSize ??= 25;
settings.enabled ??= true;
```

Final result:

```js
{
  theme: 'system',
  pageSize: 0,
  enabled: false
}
```

---

## Part 4: Deep Copy Solution

```js
const projectDraft = structuredClone(project);

projectDraft.metadata.priority = 'low';
```

The source value remains:

```text
high
```

---

## Part 4: Immutable Task Update

```js
const completedTasks = tasks.with(1, {
  ...tasks.at(1),
  completed: true
});
```

---

# Final Practical Assessment

Complete this assessment without copying code from earlier modules.

## Task

Create a file:

```text
src/assessment/final-assessment.js
```

The program must:

1. Create an array of at least four task objects.
2. Include duplicate tags across tasks.
3. Use a `Set` to create unique tags.
4. Use a `Map` to count tasks by owner.
5. Use `.filter()` to identify pending tasks.
6. Use `.toSorted()` to sort tasks by priority.
7. Use `structuredClone()` to create a draft.
8. Use `.with()` to mark one draft task complete.
9. Use template literals for a final summary.
10. Verify that the original task collection remains unchanged.

## Assessment Starter Template

### `src/assessment/final-assessment.js`

```js
/**
 * Final student assessment.
 *
 * Run with:
 * node src/assessment/final-assessment.js
 */

const tasks = [
  {
    id: 'task_1',
    ownerId: 'user_1001',
    title: 'Create assessment tasks',
    completed: true,
    priority: 1,
    tags: ['assessment', 'javascript']
  },
  {
    id: 'task_2',
    ownerId: 'user_1002',
    title: 'Build collection summary',
    completed: false,
    priority: 2,
    tags: ['collections', 'javascript']
  },
  {
    id: 'task_3',
    ownerId: 'user_1001',
    title: 'Create immutable draft',
    completed: false,
    priority: 1,
    tags: ['immutability', 'assessment']
  },
  {
    id: 'task_4',
    ownerId: 'user_1002',
    title: 'Verify output',
    completed: false,
    priority: 3,
    tags: ['verification']
  }
];

// 1. Create uniqueTags with Set.

// 2. Create taskCountByOwner with Map.

// 3. Create pendingTaskTitles.

// 4. Create tasksByPriority with toSorted().

// 5. Create a draft with structuredClone().

// 6. Update task_2 in the draft with .with().

// 7. Print a final summary.

// 8. Verify that the original task_2 remains incomplete.
```

## Assessment Submission Checklist

- [ ] My file runs without an uncaught error.
- [ ] My original `tasks` array remains unchanged.
- [ ] My draft task update is correct.
- [ ] My tags are unique.
- [ ] My owner counts are correct.
- [ ] My task sort is correct.
- [ ] My final summary is readable.
- [ ] I can explain every modern feature I used.

