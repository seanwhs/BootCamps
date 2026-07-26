# Trainer Guide  
## ES6+ Modern JavaScript: The Contemporary Developer Kit

**Audience:** Beginner to intermediate JavaScript developers  
**Recommended delivery format:** Instructor-led workshop, bootcamp module, or blended self-paced course  
**Recommended duration:** 16–24 instructional hours  
**Runtime requirement:** Node.js 22+  
**Primary project:** `modern-javascript-toolkit`

---

# 1. Guide Purpose

This trainer guide helps instructors deliver the **ES6+ Modern JavaScript: The Contemporary Developer Kit** series consistently.

It provides:

- Learning outcomes
- Recommended teaching sequence
- Suggested timing
- Demonstration guidance
- Lab facilitation notes
- Common learner mistakes
- Assessment ideas
- Troubleshooting guidance
- Discussion prompts
- Adaptation options for different audiences

The series teaches modern ECMAScript features through runnable Node.js examples. It emphasizes practical skill, readable code, defensive programming, and safe data handling.

---

# 2. Course Outcomes

By the end of the course, learners should be able to:

1. Use `const` and `let` appropriately.
2. Explain block scope and avoid `var` in new code.
3. Use array and object destructuring.
4. Use rest and spread syntax safely.
5. Write and evaluate arrow functions.
6. Explain lexical `this` and identify when arrow functions should not be used.
7. Use template literals and enhanced object literals.
8. Select appropriate collection types:
   - Array
   - Plain object
   - `Set`
   - `Map`
   - `WeakSet`
   - `WeakMap`
9. Build and consume generators and async generators.
10. Use optional chaining, nullish coalescing, and logical assignment.
11. Explain shallow copying, deep copying, and `structuredClone()`.
12. Use modern immutable array APIs:
   - `.at()`
   - `.toSorted()`
   - `.toSpliced()`
   - `.with()`
13. Create small ES module-based Node.js programs.
14. Debug common modern JavaScript issues.
15. Modernize selected older JavaScript patterns safely.

---

# 3. Recommended Delivery Models

## Option A: Two-Day Workshop

| Day | Topics | Approximate Time |
|---|---|---:|
| Day 1 | Primers, Part 0, Part 1, Part 2 | 7–8 hours |
| Day 2 | Part 3, Part 4, exercises, assessment | 7–8 hours |

Best for:

- Corporate training
- Intensive bootcamps
- Developer upskilling sessions
- Teams migrating older JavaScript code

---

## Option B: Four-Session Course

| Session | Topics | Approximate Time |
|---|---|---:|
| Session 1 | Primers, setup, Part 1 | 3–4 hours |
| Session 2 | Part 2 | 3–4 hours |
| Session 3 | Part 3 | 3–4 hours |
| Session 4 | Part 4, capstone, review | 3–4 hours |

Best for:

- Evening courses
- Internal engineering enablement
- University extension programs
- Weekly study groups

---

## Option C: Eight Short Sessions

| Session | Topics |
|---|---|
| 1 | Primer 0 and Primer 1 |
| 2 | Primer 2 and Primer 3 |
| 3 | Primer 4 and Part 0 |
| 4 | Part 1 |
| 5 | Part 2 |
| 6 | Part 3 |
| 7 | Part 4 |
| 8 | Exercises, capstone, migration guide, assessment |

Best for:

- Beginner learners
- Teams with limited training time
- Programs where learners need time between sessions to practice

---

# 4. Required Trainer Preparation

Before teaching, complete the following.

## Environment Checklist

- [ ] Install Node.js 22 or newer.
- [ ] Verify Node.js:

```bash
node --version
```

- [ ] Verify npm:

```bash
npm --version
```

- [ ] Clone or prepare the `modern-javascript-toolkit` project.
- [ ] Run every module at least once.
- [ ] Confirm learner machines can access a terminal.
- [ ] Confirm learners can create files and folders.
- [ ] Prepare a code editor recommendation, preferably Visual Studio Code.
- [ ] Prepare a backup copy of the completed project.
- [ ] Prepare a browser-free teaching plan; the core course runs in Node.js.

## Full Verification Before Delivery

Run all available project scripts before teaching:

```bash
npm run primer:0:project-info
npm run primer:0:console
npm run primer:0:verification
npm run primer:0:errors

npm run primer:1:runtime
npm run primer:1:boundaries
npm run primer:1:arguments -- "Trainer Check" 2
npm run primer:1:environment
npm run primer:1:task-report -- "Verify environment" 1

npm run primer:2:types
npm run primer:2:primitives
npm run primer:2:objects
npm run primer:2:arrays
npm run primer:2:references
npm run primer:2:tasks

npm run primer:3:functions
npm run primer:3:control-flow
npm run primer:3:iteration
npm run primer:3:array-methods
npm run primer:3:task-service

npm run primer:4:modules
npm run primer:4:paths
npm run primer:4:stack-traces
npm run primer:4:logging

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

If the project includes appendices:

```bash
npm run appendix:e:exercises
npm run appendix:f:glossary
npm run appendix:g:migration
```

---

# 5. Core Teaching Principles

## 5.1 Teach Intent Before Syntax

Do not begin by saying:

> “Today we will learn `??=`.”

Instead begin with the problem:

> “Sometimes configuration is missing, but `false` and `0` are valid settings. How can we apply a default without overwriting valid values?”

Then introduce:

```js
settings.pageSize ??= 25;
```

This helps learners connect syntax with a real programming decision.

---

## 5.2 Predict Before Running

Before executing code, ask learners to predict output.

Example:

```js
const settings = {
  pageSize: 0
};

console.log(settings.pageSize || 25);
console.log(settings.pageSize ?? 25);
```

Ask:

1. What will the first line print?
2. What will the second line print?
3. Which is appropriate for a valid page size of `0`?

Prediction creates productive tension and exposes misunderstandings early.

---

## 5.3 Use Small Experiments

When learners struggle, reduce the code to the smallest runnable example.

Instead of debugging an entire dashboard, isolate the question:

```js
const project = {};

console.log(project.owner?.displayName ?? 'Unassigned owner');
```

Small examples make language behavior visible.

---

## 5.4 Separate “Works” from “Is Appropriate”

Many older patterns still work:

```js
var count = 0;
```

```js
const result = value || 'fallback';
```

```js
tasks.sort();
```

The training goal is not to claim these are always invalid. The goal is to explain when modern alternatives communicate intent better or prevent bugs.

---

# 6. Suggested Opening Script

Use or adapt this introduction:

> JavaScript is not one frozen language. It is a living standardized language called ECMAScript. Modern JavaScript gives us clearer ways to manage data, functions, asynchronous work, collections, and defensive behavior.
>
> In this course, we will not learn syntax as isolated symbols. We will learn what problems each feature solves. We will run every example, inspect real output, and build a small toolkit that combines the features into realistic code.
>
> The rule for the course is simple: do not only read the code. Run it, change it, and verify what happens.

---

# 7. Primer Series Facilitation Guide

# Primer 0: Learning Setup and Workflow

## Recommended Time

45–60 minutes

## Learning Goal

Ensure every learner can:

- Run Node.js
- Use npm scripts
- Create project files
- Read basic output
- Understand the tutorial workflow

## Trainer Demonstration

Demonstrate:

```bash
node --version
npm --version
mkdir modern-javascript-toolkit
cd modern-javascript-toolkit
npm start
```

Explain:

- Node.js executes JavaScript.
- npm runs named project commands.
- `package.json` stores project configuration.
- `"type": "module"` enables ES module syntax.

## Checkpoint Questions

1. What command displays the Node.js version?
2. What command runs the `start` script?
3. What is the purpose of `package.json`?
4. Why should every code change be verified by running it?

## Common Problems

| Problem | Likely Cause | Trainer Response |
|---|---|---|
| `node: command not found` | Node.js missing or not in PATH | Reinstall Node.js; restart terminal |
| `Cannot find module` | Learner is in wrong folder or file path is wrong | Use `pwd` / `Get-Location`; inspect folders |
| `npm start` fails | Missing or incorrect script | Check `package.json` syntax and `"scripts"` |
| `import` syntax error | Missing `"type": "module"` | Add `"type": "module"` to `package.json` |

---

# Primer 1: Runtime and Tooling Basics

## Recommended Time

60–75 minutes

## Learning Goal

Learners understand:

- Node.js runtime basics
- `process`
- `process.argv`
- `process.env`
- npm scripts
- REPL use

## Trainer Demonstration

Show:

```bash
node
```

Then enter:

```js
const tags = ['javascript', 'es2024', 'javascript'];
[...new Set(tags)];
```

Then explain command-line arguments:

```bash
node src/primers/command-line-report.js "Documentation Refresh" 4
```

Explain the meaning of:

```js
process.argv.slice(2);
```

## Important Teaching Note

Clarify that command-line arguments are received as strings.

```js
const taskCount = process.argv[3];
```

Even when the terminal command contains `4`, the runtime initially receives `'4'`.

Use:

```js
Number(value);
```

and validate the result.

## Discussion Prompt

> What configuration should belong in source code, and what configuration should come from the environment?

Expected answers:

- Source code: application logic, defaults, algorithms.
- Environment variables: secrets, environment names, deployment-specific URLs, ports, credentials.

---

# Primer 2: Values, Types, Objects, and Arrays

## Recommended Time

75–90 minutes

## Learning Goal

Learners understand:

- Primitives
- Objects
- Arrays
- References
- Shallow and deep copying

## High-Value Demonstration

Write this live:

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

Ask learners to predict output.

Then show:

```js
const deepCopied = structuredClone(original);
```

Explain that object spread creates a new outer object but shares nested references.

## Key Clarification

Do not describe primitives as “passed by value” and objects as “passed by reference” without context. A clearer statement is:

> JavaScript variables hold values. For objects and arrays, the value held by a variable is a reference to the object. Assigning that reference to another variable means both variables refer to the same object.

## Common Misconception

> “`const` makes an object unchangeable.”

Correct it with:

```js
const user = {
  role: 'reader'
};

user.role = 'editor';
```

`const` prevents rebinding the variable, not mutation of the object.

---

# Primer 3: Functions, Control Flow, and Basic Iteration

## Recommended Time

90 minutes

## Learning Goal

Learners can:

- Write functions
- Use return values
- Use conditions
- Loop through arrays
- Use common array methods

## Trainer Demonstration Sequence

1. Start with a plain function:

```js
function add(firstValue, secondValue) {
  return firstValue + secondValue;
}
```

2. Show condition logic:

```js
function getStatus(completed) {
  if (completed) {
    return 'completed';
  }

  return 'pending';
}
```

3. Show `for...of`:

```js
for (const task of tasks) {
  console.log(task.title);
}
```

4. Replace selected loops with array methods:

```js
const pendingTasks = tasks.filter((task) => !task.completed);
```

## Teaching Note: `.reduce()`

Do not rush `.reduce()`. Many beginners find it abstract.

Start with a visual question:

> “What single result are we trying to build from this whole array?”

Examples:

- A count
- A total
- A grouped object
- A Map
- A combined summary

Use a count first:

```js
const completedTaskCount = tasks.reduce((count, task) => {
  return task.completed ? count + 1 : count;
}, 0);
```

Explain:

- `count` begins at `0`.
- Each task is examined.
- The callback returns the next accumulator value.
- The final accumulator becomes the result.

---

# Primer 4: Modules, Files, and Debugging Basics

## Recommended Time

90 minutes

## Learning Goal

Learners can:

- Import and export modules
- Read relative paths
- Use stack traces
- Log structured debug information
- Use watch mode

## Key Demonstration

Show a deliberate incorrect import:

```js
import {
  createTask
} from './domain/tasks.js';
```

when the actual file is:

```text
task.js
```

Run it and inspect the error.

Then correct it:

```js
import {
  createTask
} from './domain/task.js';
```

This reinforces that import paths are exact.

## Debugging Emphasis

Teach learners to use logs that answer questions.

Avoid:

```js
console.log('here');
```

Prefer:

```js
console.log({
  taskId,
  taskIndex,
  taskWasFound: taskIndex !== -1
});
```

---

# 8. Main Series Facilitation Guide

# Part 0: Introduction

## Recommended Time

20–30 minutes

## Trainer Goals

Establish:

- Scope
- Architecture
- Expectations
- Required runtime
- Series progression

## Core Message

> The course is not about memorizing every modern feature. It is about recognizing the problem each feature solves and choosing the clearest safe tool.

## Discussion Prompt

Ask learners:

> What JavaScript patterns do you currently find repetitive, unclear, or error-prone?

Capture responses. Common examples:

- Long nested null checks
- Manual copying
- Confusing `this`
- Duplicate values
- Mutating arrays accidentally
- Callback-heavy async code

Refer back to these responses throughout the course.

---

# Part 1: Syntax Ergonomics and Destructuring

## Recommended Time

2–3 hours

## Learning Outcomes

Learners can:

- Use `const` and `let`
- Explain block scope
- Destructure arrays and objects
- Use defaults and renaming
- Use rest and spread
- Explain shallow copying

## Suggested Agenda

| Segment | Time |
|---|---:|
| `const`, `let`, and block scope | 30 min |
| Array destructuring | 25 min |
| Object destructuring | 35 min |
| Rest syntax | 20 min |
| Spread syntax and immutable updates | 35 min |
| Lab and review | 30 min |

## Important Demonstrations

### `const` Does Not Freeze Objects

```js
const project = {
  status: 'active'
};

project.status = 'archived';

console.log(project);
```

### Array Destructuring

```js
const stages = ['validate', 'build', 'test'];

const [firstStage, secondStage] = stages;
```

### Object Renaming

```js
const response = {
  request_id: 'req_1001'
};

const {
  request_id: requestId
} = response;
```

### Nested Defaults

```js
const order = {};

const {
  shippingAddress: {
    city = 'Not provided'
  } = {}
} = order;
```

## Lab Activity

Ask learners to create:

```js
function createPublicProfile(user) {}
```

Requirements:

- Remove `passwordHash`.
- Default absent roles to `[]`.
- Deduplicate roles.
- Add a display label.
- Do not mutate the original user.

Expected concepts:

- Destructuring
- Rest syntax
- `Set`
- Spread
- Template literals

## Common Errors

| Error | Cause | Fix |
|---|---|---|
| `TypeError` during nested destructuring | Parent object missing | Add `= {}` fallback |
| Original object changed unexpectedly | Nested object shared through shallow copy | Use targeted nested copy or `structuredClone()` |
| Learner uses `var` | Habit from older JavaScript | Explain block scope; replace with `const`/`let` |
| Spread syntax used as a deep copy | Misunderstanding | Demonstrate nested reference sharing |

---

# Part 2: Arrow Functions, Templates, and Expressive Syntax

## Recommended Time

2–2.5 hours

## Learning Outcomes

Learners can:

- Write arrow functions
- Use implicit returns
- Return object literals correctly
- Explain arrow-function `this`
- Use template literals
- Use concise object syntax

## Suggested Agenda

| Segment | Time |
|---|---:|
| Arrow syntax and implicit returns | 35 min |
| Arrow functions and lexical `this` | 35 min |
| Template literals | 30 min |
| Enhanced object literals | 25 min |
| Lab and review | 30 min |

## Critical Teaching Point: Object Literal Returns

Show the incorrect version:

```js
const createTask = (title) => {
  id: crypto.randomUUID(),
  title
};
```

Explain that this is a function body without a `return`.

Show the correct implicit-return form:

```js
const createTask = (title) => ({
  id: crypto.randomUUID(),
  title
});
```

Or the explicit-return form:

```js
const createTask = (title) => {
  return {
    id: crypto.randomUUID(),
    title
  };
};
```

## Critical Teaching Point: `this`

Use this rule:

> Use arrow functions for callbacks and short transformations. Use method syntax for object methods that need the receiving object as `this`.

Correct method:

```js
const project = {
  name: 'Modern JavaScript Toolkit',

  getLabel() {
    return `Project: ${this.name}`;
  }
};
```

Potentially incorrect arrow method:

```js
const project = {
  name: 'Modern JavaScript Toolkit',

  getLabel: () => `Project: ${this.name}`
};
```

## Lab Activity

Create a task formatter that:

- Receives a task object.
- Returns a template-literal label.
- Uses an arrow function.
- Includes a computed property name based on priority.
- Uses a concise object method for a status summary.

---

# Part 3: Collections and Iteration Protocols

## Recommended Time

2.5–3 hours

## Learning Outcomes

Learners can:

- Select between Array, Object, Set, Map, WeakSet, and WeakMap
- Explain object identity
- Create generators
- Consume async generators

## Suggested Agenda

| Segment | Time |
|---|---:|
| Collection selection | 25 min |
| Set | 25 min |
| Map | 35 min |
| Weak collections | 25 min |
| Iterators and generators | 40 min |
| Async iteration | 30 min |
| Lab and review | 30 min |

## Collection Decision Explanation

Use this metaphor:

| Collection | Analogy |
|---|---|
| Array | Ordered shelf |
| Object | Form with known labeled fields |
| Set | Guest list with no duplicates |
| Map | Filing system connecting keys to values |
| WeakMap | Temporary sticky note attached to an object |
| WeakSet | Temporary “already processed” stamp on an object |

## Key Demonstration: Object Identity

```js
const firstTask = {
  id: 'task_1'
};

const secondTask = {
  id: 'task_1'
};

console.log(firstTask === secondTask);
// false
```

Then:

```js
const tasks = new Set([firstTask]);

console.log(tasks.has(secondTask));
// false
```

Explain:

> Objects may look the same, but they are different values unless they are the same object reference.

## Key Demonstration: Generator Laziness

```js
function* generateTaskIds() {
  console.log('Generator started.');

  yield 'task_1';
  yield 'task_2';
}

const taskIds = generateTaskIds();

console.log('Generator created.');
console.log(taskIds.next());
```

Ask learners when `"Generator started."` will print.

## Lab Activity

Build an async task-page processor that:

- Receives pages from an async generator.
- Adds tags to a `Set`.
- Counts owners in a `Map`.
- Collects pending task titles.
- Prints final results.

---

# Part 4: Modern Utility APIs and Defensive Coding

## Recommended Time

2.5–3 hours

## Learning Outcomes

Learners can:

- Use optional chaining
- Use nullish coalescing
- Use logical assignment
- Explain shallow and deep copying
- Use `structuredClone()`
- Use immutable array APIs

## Suggested Agenda

| Segment | Time |
|---|---:|
| Optional chaining | 25 min |
| `??` versus `||` | 30 min |
| Logical assignment | 20 min |
| `structuredClone()` | 35 min |
| Immutable arrays | 40 min |
| Final integration lab | 40 min |

## Critical Demonstration: `||` Versus `??`

```js
const settings = {
  pageSize: 0,
  showCompletedTasks: false,
  displayName: ''
};

console.log(settings.pageSize || 25);
console.log(settings.pageSize ?? 25);
```

Expected explanation:

| Operator | Result for `0` | Why |
|---|---:|---|
| `||` | `25` | `0` is falsy |
| `??` | `0` | `0` is not nullish |

## Critical Demonstration: Immutable Arrays

Show mutation:

```js
const priorities = [3, 1, 2];

priorities.sort((first, second) => first - second);

console.log(priorities);
// [1, 2, 3]
```

Then show non-mutation:

```js
const priorities = [3, 1, 2];

const sortedPriorities = priorities.toSorted(
  (first, second) => first - second
);

console.log(priorities);
// [3, 1, 2]

console.log(sortedPriorities);
// [1, 2, 3]
```

## Final Integration Lab

Learners should create or complete a function similar to:

```js
async function createDashboard(project, taskPages) {}
```

Required behavior:

- Read project defaults safely.
- Preserve `pageSize: 0`.
- Process async task pages.
- Deduplicate tags with `Set`.
- Count owner tasks with `Map`.
- Create sorted output with `.toSorted()`.
- Create a draft with `structuredClone()`.
- Update a task draft with `.with()`.

---

# 9. Facilitation Strategies for Different Learners

## Beginners

Use:

- More live coding
- Shorter labs
- Frequent prediction questions
- Pair programming
- Printed or visible cheat sheets
- More time on objects, arrays, functions, and references

Avoid:

- Introducing too many APIs in a single demonstration
- Assuming learners understand callbacks or Promises
- Rushing through `.reduce()`, `this`, or generators

---

## Intermediate Developers

Use:

- Legacy-to-modern migration exercises
- Code review exercises
- Refactoring labs
- Deep dives on shallow copies, `Map`, and async iteration
- Compatibility discussions

Challenge them to explain trade-offs:

- `Map` versus object
- `structuredClone()` versus targeted copying
- `??` versus `||`
- generator versus array creation
- mutation versus immutable updates

---

## Teams Migrating Older Code

Focus extra time on:

- `var` migration
- CommonJS to ES modules
- callback-to-Promise adapters
- JSON clone replacements
- mutation audits
- feature support and polyfills
- linting and formatting

Use Appendix G as a guided refactoring workshop.

---

# 10. Assessment Plan

## Formative Assessment

Use during instruction.

### Quick Checks

Ask learners to answer in chat, verbally, or on a shared document:

1. What does `const` prevent?
2. What is the difference between `??` and `||`?
3. Why can two matching-looking objects fail a `Set.has()` check?
4. What does `.with()` return?
5. When should you use `for await...of`?
6. Why is object spread shallow?

### Exit Ticket Example

At the end of a session, ask learners to write:

1. One feature they can now use confidently.
2. One feature they need to practice.
3. One code example they want reviewed.

---

## Summative Assessment

Use the final dashboard project.

### Minimum Requirements

| Requirement | Points |
|---|---:|
| Uses `const` and `let` appropriately | 5 |
| Uses destructuring with defaults | 10 |
| Uses optional chaining and `??` correctly | 10 |
| Uses `Set` for unique tags | 10 |
| Uses `Map` for owner counts | 10 |
| Processes async task pages with `for await...of` | 15 |
| Uses immutable array APIs | 10 |
| Uses `structuredClone()` or explains a targeted update choice | 10 |
| Includes useful validation or errors | 10 |
| Includes readable output and verification | 10 |
| **Total** | **100** |

---

## Rubric Levels

| Score | Interpretation |
|---:|---|
| 90–100 | Strong practical mastery; clear, idiomatic, defensive code |
| 75–89 | Competent use of most features; minor issues or missing explanations |
| 60–74 | Basic understanding; needs support with integration or defensive behavior |
| Below 60 | Needs guided review of prerequisites and core concepts |

---

# 11. Common Questions and Suggested Answers

## “Why not always use `let`?”

Use `const` when reassignment is not needed because it communicates intent and prevents accidental reassignment.

```js
const projectId = 'project_3001';
```

Use `let` only when the binding must point to a different value later.

```js
let currentPage = 1;
currentPage += 1;
```

---

## “Why not always use `structuredClone()`?”

Because a targeted update is often clearer and more efficient.

```js
const updatedProject = {
  ...project,
  settings: {
    ...project.settings,
    theme: 'dark'
  }
};
```

Use `structuredClone()` when you need an independent copy of a larger compatible data graph or a draft snapshot.

---

## “Why not always use a plain object instead of `Map`?”

Plain objects are excellent for known records:

```js
const user = {
  id: 'user_1001',
  displayName: 'Ava Patel'
};
```

Use `Map` when key-value relationships are central, keys are dynamic, keys may not be strings, or you need explicit APIs such as `.set()`, `.get()`, `.has()`, and `.size`.

---

## “Does optional chaining hide bugs?”

It can if used for values that should be required.

Appropriate:

```js
const city = user?.address?.city;
```

when address data is optional.

Less appropriate:

```js
const projectId = project?.id;
```

when a project ID is required for the operation. In that case, validate and throw a useful error.

---

## “Why does `typeof null` return `'object'`?”

It is a historical JavaScript behavior that remains for compatibility. Detect `null` directly:

```js
value === null;
```

---

## “Why does `Set` not remove duplicate objects with the same ID?”

Because objects are compared by reference identity.

```js
{ id: 'task_1' } === { id: 'task_1' };
// false
```

If uniqueness is based on IDs, track IDs in a `Set`.

---

# 12. Troubleshooting Guide

| Symptom | Likely Cause | Resolution |
|---|---|---|
| `SyntaxError: Cannot use import statement outside a module` | Missing ES module configuration | Add `"type": "module"` to `package.json` |
| `ERR_MODULE_NOT_FOUND` | Import path or filename is wrong | Check exact path, capitalization, and `.js` extension |
| `TypeError: Cannot read properties of undefined` | Unsafe nested property read | Use optional chaining or validate required parent value |
| `TypeError: values.toSorted is not a function` | Older Node.js runtime | Upgrade to Node.js 20+; series recommends Node.js 22+ |
| Original data changed after copying | Shallow copy shared nested values | Use targeted nested copying or `structuredClone()` |
| `Set.has()` returns false for matching-looking object | Different object reference | Reuse same object or compare primitive IDs |
| Promise printed instead of result | Missing `await` | Await the Promise in an async context |
| Script not found | Wrong current folder or script name | Run `npm run`; check current directory |
| Learner sees old output after edits | File was not saved | Save file; rerun command |
| `RangeError` from `.with()` | Invalid index | Confirm index exists before replacement |

---

# 13. Suggested Trainer Demonstration Files

Prepare these short snippets in advance for live instruction.

## `const` and Mutation

```js
const user = {
  role: 'reader'
};

user.role = 'editor';

console.log(user);
```

## Destructuring with Defaults

```js
const order = {};

const {
  shippingAddress: {
    city = 'Not provided'
  } = {}
} = order;

console.log(city);
```

## `??` Versus `||`

```js
const pageSize = 0;

console.log(pageSize || 25);
console.log(pageSize ?? 25);
```

## `Set` Identity

```js
const first = {
  id: 'task_1'
};

const second = {
  id: 'task_1'
};

console.log(new Set([first]).has(second));
```

## Immutable Array Update

```js
const tasks = [
  {
    id: 'task_1',
    completed: false
  }
];

const revisedTasks = tasks.with(0, {
  ...tasks.at(0),
  completed: true
});

console.log({
  tasks,
  revisedTasks
});
```

## Async Generator

```js
async function* generatePages() {
  yield ['task_1', 'task_2'];
  yield ['task_3'];
}

for await (const page of generatePages()) {
  console.log(page);
}
```

---

# 14. Trainer Delivery Checklist

## Before the Course

- [ ] Verify Node.js version requirements.
- [ ] Run all course scripts.
- [ ] Prepare project starter files.
- [ ] Prepare completed reference files.
- [ ] Confirm learners have editor and terminal access.
- [ ] Prepare the student workbook.
- [ ] Prepare the student notes.
- [ ] Prepare a shared communication channel for questions.
- [ ] Decide assessment and submission method.

## During the Course

- [ ] Explain the objective before each module.
- [ ] Demonstrate before assigning a complex lab.
- [ ] Ask learners to predict output.
- [ ] Require verification commands.
- [ ] Pause after each major concept for questions.
- [ ] Watch for copy-paste without understanding.
- [ ] Use errors as teaching opportunities.
- [ ] Encourage learners to change working examples safely.

## After the Course

- [ ] Collect final assessment submissions.
- [ ] Provide feedback against the rubric.
- [ ] Share completed source code.
- [ ] Share the compatibility and migration appendices.
- [ ] Recommend next learning paths:
  - TypeScript
  - Testing with Node.js test runner or Vitest
  - React, Vue, or Angular
  - Node.js APIs
  - Databases
  - Web security
  - Build tools and deployment

---

# 15. Final Trainer Closing Script

> Modern JavaScript is not about using the shortest possible syntax. It is about making intent visible.
>
> Use `const` to show stability. Use destructuring to extract data clearly. Use Sets and Maps when they match the rules of your data. Use optional chaining and nullish coalescing to handle incomplete input deliberately. Use immutable updates when shared state could otherwise change unexpectedly.
>
> The best next step is not memorizing every API. It is applying these tools to a real project, running the code, writing tests, and continuing to ask: “What does this line communicate to the next developer?”
