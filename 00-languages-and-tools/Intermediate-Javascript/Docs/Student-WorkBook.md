# Student Workbook  
## Intermediate JavaScript: Asynchronous Flow & Code Organization

This workbook accompanies the tutorial series and the minimalist slide deck.

Use it to:

- Record predictions before running code.
- Complete guided exercises.
- Track project milestones.
- Write explanations in your own words.
- Record errors and fixes.
- Test the final application.
- Plan extensions.

This workbook intentionally leaves space for your answers. Do not read the reference explanation first when a section asks you to predict behavior. Prediction is part of learning.

---

# How to Use This Workbook

For every exercise:

1. Read the question.
2. Write your prediction.
3. Run the code.
4. Record the actual result.
5. Explain the difference, if any.
6. Commit the working change if using Git.

Use this basic record:

```text
Prediction:
Actual result:
Difference:
What I learned:
```

---

# Student Information

```text
Name: _______________________________________________

Start date: __________________________________________

Computer / operating system: __________________________

Browser: _____________________________________________

Code editor: _________________________________________

Python or local server version: _______________________
```

---

# Learning Goals

By the end of the series, I want to be able to:

- [ ] Explain synchronous and asynchronous JavaScript.
- [ ] Explain the call stack and event loop.
- [ ] Write callback-based asynchronous code.
- [ ] Create and consume Promises.
- [ ] Use `async`/`await`.
- [ ] Handle asynchronous errors.
- [ ] Explain prototypes.
- [ ] Create and use classes.
- [ ] Use inheritance with `extends` and `super`.
- [ ] Organize code into ES modules.
- [ ] Persist data with `localStorage`.
- [ ] Use `sessionStorage` appropriately.
- [ ] Serialize and restore JSON data.
- [ ] Validate external and stored data.
- [ ] Debug browser applications.
- [ ] Test application behavior.
- [ ] Apply basic accessibility and security practices.

---

# Project Setup Worksheet

## Project Name

```text
async-task-manager
```

## Initial Directory

Write the directory where you will create the project:

```text
_______________________________________________________
```

## Local Server Command

```bash
_______________________________________________________
```

## Local Application URL

```text
_______________________________________________________
```

## Browser Developer Tools Shortcut

```text
_______________________________________________________
```

## Git Repository

Will you use Git?

```text
[ ] Yes
[ ] No
```

Repository path:

```text
_______________________________________________________
```

---

# Project Architecture Worksheet

Complete this table as the series progresses.

| File or directory | Responsibility |
|---|---|
| `index.html` | __________________________________________ |
| `styles.css` | __________________________________________ |
| `js/main.js` | __________________________________________ |
| `js/app.js` | __________________________________________ |
| `js/models/` | __________________________________________ |
| `js/services/` | _______________________________________ |
| `js/api/` | _____________________________________________ |
| `js/ui/` | ______________________________________________ |
| `js/utils/` | ___________________________________________ |

---

# Primer 0 Worksheet: Prerequisites and Workflow

## Exercise P0-1: Tool Verification

Check each item after verifying it.

- [ ] Modern browser opens.
- [ ] Code editor opens.
- [ ] Terminal opens.
- [ ] Python or another local server is installed.
- [ ] Project directory can be created.
- [ ] Browser console can be opened.
- [ ] A local HTML file can be served.
- [ ] A JavaScript file can be loaded.

## Exercise P0-2: Local Server

Write the command you used:

```bash
_______________________________________________________
```

Write the URL you opened:

```text
_______________________________________________________
```

What did the browser display?

```text
_______________________________________________________
_______________________________________________________
```

## Exercise P0-3: Development Workflow

Complete the sequence:

```text
____________________
        ↓
____________________
        ↓
____________________
        ↓
____________________
        ↓
____________________
```

Expected sequence:

```text
Edit → Save → Serve → Refresh → Verify
```

Write the sequence in your own words:

```text
_______________________________________________________
_______________________________________________________
```

## Exercise P0-4: Debugging Agreement

Before continuing after a failed verification, I will:

```text
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

---

# Primer 1 Worksheet: HTML, CSS, and JavaScript Foundations

## Exercise P1-1: Three-Layer Model

Complete the table.

| Technology | Main responsibility | Example |
|---|---|---|
| HTML | __________________ | __________________ |
| CSS | ___________________ | __________________ |
| JavaScript | _____________ | __________________ |

## Exercise P1-2: Semantic HTML

Write a semantic element for each purpose.

| Purpose | Element |
|---|---|
| Primary content | __________________ |
| A thematic group | __________________ |
| A form | __________________ |
| An unordered collection | __________________ |
| One item in a collection | __________________ |
| The page introduction | __________________ |

## Exercise P1-3: Label Association

Given:

```html
<label for="task-title">Task title</label>

<input
  id="task-title"
  name="taskTitle"
  type="text"
/>
```

Why must the `for` and `id` values match?

```text
_______________________________________________________
_______________________________________________________
```

## Exercise P1-4: CSS Selectors

Write the selector for each target.

```html
<h1 id="page-title">Title</h1>
<p class="status-message">Ready</p>
<button>Save</button>
```

| Target | Selector |
|---|---|
| The `h1` by ID | __________________ |
| The paragraph by class | __________________ |
| The button by element | __________________ |

## Exercise P1-5: DOM Selection

Write JavaScript that selects the following:

```javascript
const taskList = ______________________________________;

const form = __________________________________________;

const statusMessage = __________________________________;
```

## Exercise P1-6: Event Handling

Complete the code:

```javascript
const button = document.querySelector("#save-button");

button.addEventListener("__________", () => {
  console.log("The button was activated.");
});
```

## Exercise P1-7: Form Submission Prediction

What happens if `preventDefault()` is omitted?

```javascript
form.addEventListener("submit", (event) => {
  // event.preventDefault();

  console.log("Submitted");
});
```

Prediction:

```text
_______________________________________________________
```

## Exercise P1-8: State and Rendering

Complete the workflow:

```text
Update application __________
        ↓
Call __________
        ↓
Update the visible __________
```

## Exercise P1-9: Safe Text Rendering

Which is safer for user-entered task titles?

```javascript
element.innerHTML = task.title;
```

or:

```javascript
element.textContent = task.title;
```

Answer:

```text
_______________________________________________________
```

Why?

```text
_______________________________________________________
_______________________________________________________
```

---

# Primer 2 Worksheet: Developer Tools

## Exercise P2-1: Panel Matching

Match each problem to the best Developer Tools panel.

| Problem | Panel |
|---|---|
| Inspect current HTML | __________________ |
| Read a JavaScript error | __________________ |
| Set a breakpoint | __________________ |
| Inspect an API response | __________________ |
| Inspect `localStorage` | __________________ |
| Check CSS rules | __________________ |

## Exercise P2-2: Console Experiment

Run:

```javascript
[1, 2, 3].map((number) => number * 2);
```

Prediction:

```text
_______________________________________________________
```

Actual result:

```text
_______________________________________________________
```

## Exercise P2-3: DOM Inspection

Run:

```javascript
document.querySelector("#task-list");
```

What did the console return?

```text
_______________________________________________________
```

If it returned `null`, what might that mean?

```text
_______________________________________________________
```

## Exercise P2-4: Structured Logging

Write a structured log for these values:

```javascript
tasks
currentFilter
isLoading
```

```javascript
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

## Exercise P2-5: Breakpoint Observation

Place a breakpoint inside:

```javascript
function addTask(title) {
  // breakpoint here
}
```

When execution pauses, record:

```text
Function name: ________________________________________

Argument values: ______________________________________

Current task count: ___________________________________

Current filter: _______________________________________
```

## Exercise P2-6: Debugging Report

Describe one deliberate or accidental bug.

```text
Problem:
_______________________________________________________

Steps to reproduce:
_______________________________________________________
_______________________________________________________

Expected result:
_______________________________________________________

Actual result:
_______________________________________________________

Console error:
_______________________________________________________

Fix:
_______________________________________________________
```

---

# Primer 3 Worksheet: Terminal and Local Development

## Exercise P3-1: Commands

Write the command for each task.

| Task | Command |
|---|---|
| Show current directory | __________________ |
| List files | __________________ |
| Enter a directory | __________________ |
| Move up one directory | __________________ |
| Create a directory | __________________ |
| Start a local server | __________________ |
| Stop a local server | __________________ |

## Exercise P3-2: Relative Paths

Given:

```text
project/
├── index.html
└── js/
    ├── main.js
    └── models/
        └── task.js
```

What path should `index.html` use to load `main.js`?

```text
_______________________________________________________
```

What path should `main.js` use to import `task.js`?

```text
_______________________________________________________
```

## Exercise P3-3: Server Diagnosis

The browser shows the wrong project.

List three possible causes:

```text
1. ___________________________________________________

2. ___________________________________________________

3. ___________________________________________________
```

## Exercise P3-4: Module Loading

Complete the HTML:

```html
<script
  type="______"
  src="./js/main.js"
></script>
```

Why is this required?

```text
_______________________________________________________
_______________________________________________________
```

---

# Primer 4 Worksheet: Web, HTTP, JSON, and APIs

## Exercise P4-1: URL Anatomy

Break this URL into components:

```text
https://api.example.com:443/tasks?status=active#list
```

| Component | Value |
|---|---|
| Scheme | __________________ |
| Host | __________________ |
| Port | __________________ |
| Path | __________________ |
| Query string | __________________ |
| Fragment | __________________ |

## Exercise P4-2: HTTP Methods

Match the operation.

| Operation | Method |
|---|---|
| Read tasks | __________________ |
| Create a task | __________________ |
| Partially update a task | __________________ |
| Replace a task | __________________ |
| Delete a task | __________________ |

## Exercise P4-3: Status Codes

Explain each status code.

| Code | Meaning |
|---|---|
| `200` | __________________________________ |
| `201` | __________________________________ |
| `400` | __________________________________ |
| `401` | __________________________________ |
| `403` | __________________________________ |
| `404` | __________________________________ |
| `500` | __________________________________ |

## Exercise P4-4: Fetch Error Handling

Complete:

```javascript
const response = await fetch("/api/tasks");

if (!response.______) {
  throw new Error(
    `Request failed with HTTP ${response.________}`
  );
}

const tasks = await response.________();
```

## Exercise P4-5: JSON

Convert this JavaScript object to JSON text:

```javascript
const task = {
  id: 1,
  title: "Study JSON",
  completed: false,
};
```

```javascript
const text = __________________________________________;
```

Parse it again:

```javascript
const restored = _______________________________________;
```

## Exercise P4-6: Data Validation

Why is valid JSON not necessarily valid task data?

```text
_______________________________________________________
_______________________________________________________
```

Write one validation condition:

```javascript
_______________________________________________________
```

---

# Primer 5 Worksheet: Git

## Exercise P5-1: Git Workflow

Complete:

```text
Working directory
        ↓ git __________
Staging area
        ↓ git __________
Repository history
```

## Exercise P5-2: First Commit

Write the commands to initialize and commit a project:

```bash
_______________________________________________________
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

## Exercise P5-3: Commit Message

Write a useful commit message for adding Promise-based task loading:

```text
_______________________________________________________
```

## Exercise P5-4: Branching

Why use a feature branch?

```text
_______________________________________________________
_______________________________________________________
```

Create a branch named `add-search`:

```bash
_______________________________________________________
```

## Exercise P5-5: Git Safety

List three things that should not be committed:

```text
1. ___________________________________________________

2. ___________________________________________________

3. ___________________________________________________
```

## Exercise P5-6: Git Checkpoint

Create a checkpoint after completing the first working task manager.

Commit hash:

```text
_______________________________________________________
```

Commit message:

```text
_______________________________________________________
```

---

# Primer 6 Worksheet: JavaScript Essentials

## Exercise P6-1: Variables

Should each variable use `const` or `let`?

```javascript
const applicationName = "Task Manager";
```

Answer:

```text
_______________________________________________________
```

```javascript
let currentFilter = "all";
currentFilter = "completed";
```

Answer:

```text
_______________________________________________________
```

## Exercise P6-2: Array Methods

What does each method do?

| Method | Purpose |
|---|---|
| `map()` | __________________________________ |
| `filter()` | ______________________________ |
| `find()` | _______________________________ |
| `some()` | _______________________________ |
| `every()` | ______________________________ |

## Exercise P6-3: Object Destructuring

Rewrite this using destructuring:

```javascript
const title = task.title;
const completed = task.completed;
```

```javascript
_______________________________________________________
```

## Exercise P6-4: Spread Syntax

Create a completed copy without changing the original:

```javascript
const completedTask = _________________________________;
```

Given:

```javascript
const task = {
  id: 1,
  title: "Learn spread",
  completed: false,
};
```

## Exercise P6-5: Class Design

List three properties a `Task` class should contain:

```text
1. ___________________________________________________

2. ___________________________________________________

3. ___________________________________________________
```

List three methods it should provide:

```text
1. ___________________________________________________

2. ___________________________________________________

3. ___________________________________________________
```

## Exercise P6-6: Error Handling

Complete:

```javascript
try {
  const tasks = await loadTasks();
} ________ (error) {
  showError(error);
} ________ {
  enableButton();
}
```

---

# Part 0 Workbook: Series Introduction

## Learning Contract

What do you expect to learn from this series?

```text
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

What part of JavaScript currently feels most difficult?

```text
_______________________________________________________
_______________________________________________________
```

What would make the final application feel complete to you?

```text
_______________________________________________________
_______________________________________________________
```

## Final Architecture Prediction

Before seeing the complete project, predict what each layer will do.

| Layer | Prediction |
|---|---|
| Model | __________________________________ |
| Service | _______________________________ |
| API | __________________________________ |
| UI | ___________________________________ |
| Storage | ______________________________ |
| Application coordinator | ______________ |

## Project Feature Checklist

- [ ] Add task.
- [ ] Complete task.
- [ ] Delete task.
- [ ] Filter tasks.
- [ ] Load example tasks.
- [ ] Show loading state.
- [ ] Show error state.
- [ ] Persist tasks.
- [ ] Use modules.
- [ ] Use classes.

---

# Part 1 Workbook: The Asynchronous Paradigm

## Exercise 1-1: Predict the Output

```javascript
console.log("A");

console.log("B");

console.log("C");
```

Prediction:

```text
_______________________________________________________
```

Actual result:

```text
_______________________________________________________
```

## Exercise 1-2: Blocking Work

What happens while this function runs?

```javascript
function blockForMilliseconds(duration) {
  const start = Date.now();

  while (Date.now() - start < duration) {
  }
}
```

Prediction:

```text
_______________________________________________________
_______________________________________________________
```

What user actions may be delayed?

```text
_______________________________________________________
```

## Exercise 1-3: Timer Output

Predict the output:

```javascript
console.log("Start");

setTimeout(() => {
  console.log("Timer");
}, 0);

console.log("End");
```

Prediction:

```text
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
```

Actual result:

```text
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
```

Why?

```text
_______________________________________________________
_______________________________________________________
```

## Exercise 1-4: Call Stack

Describe the likely call-stack sequence:

```javascript
function first() {
  second();
}

function second() {
  console.log("Inside second");
}

first();
```

```text
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

## Exercise 1-5: Callback Definition

Explain a callback in your own words:

```text
_______________________________________________________
_______________________________________________________
```

Write a callback example:

```javascript
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

## Exercise 1-6: Error-First Callback

Complete:

```javascript
loadTask((__________, __________) => {
  if (__________) {
    console.error(__________);
    return;
  }

  renderTask(__________);
});
```

## Exercise 1-7: Asynchronous UI States

Design the three messages for loading tasks.

| State | Message |
|---|---|
| Loading | __________________________________ |
| Success | __________________________________ |
| Failure | __________________________________ |

## Part 1 Checkpoint

- [ ] I can explain blocking code.
- [ ] I can explain non-blocking timers.
- [ ] I can predict simple event-loop output.
- [ ] I can write an error-first callback.
- [ ] I can implement loading and error UI states.

Checkpoint commit:

```text
_______________________________________________________
```

---

# Part 2 Workbook: Promises and `async`/`await`

## Exercise 2-1: Promise States

Complete the state sequence:

```text
________________
      ↓
________________
```

or:

```text
________________
      ↓
________________
```

## Exercise 2-2: Promise Creation

Write a function that resolves after one second:

```javascript
function waitOneSecond() {
  return new Promise((resolve) => {
    _________________________________________________
  });
}
```

## Exercise 2-3: Promise Consumption

Complete:

```javascript
loadTasks()
  .________((tasks) => {
    renderTasks(tasks);
  })
  .________((error) => {
    showError(error);
  })
  .________(() => {
    enableButton();
  });
```

## Exercise 2-4: Chain Values

Predict the output:

```javascript
Promise.resolve(5)
  .then((number) => number * 2)
  .then((number) => number + 1)
  .then((result) => console.log(result));
```

Prediction:

```text
_______________________________________________________
```

## Exercise 2-5: Missing Return

What is wrong?

```javascript
getUser()
  .then((user) => {
    getTasks(user.id);
  })
  .then((tasks) => {
    console.log(tasks);
  });
```

Answer:

```text
_______________________________________________________
_______________________________________________________
```

Correct it:

```javascript
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

## Exercise 2-6: Convert to `async`/`await`

Convert:

```javascript
loadTasks()
  .then((tasks) => {
    renderTasks(tasks);
  })
  .catch((error) => {
    showError(error);
  });
```

```javascript
_______________________________________________________
_______________________________________________________
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

## Exercise 2-7: Cleanup

Where should the button be re-enabled?

```text
[ ] try
[ ] catch
[ ] finally
```

Why?

```text
_______________________________________________________
_______________________________________________________
```

## Exercise 2-8: Sequential or Parallel?

Should these operations be sequential or parallel?

### Case A

```text
Load user → use user ID to load projects
```

Answer:

```text
_______________________________________________________
```

### Case B

```text
Load tasks and load notifications independently
```

Answer:

```text
_______________________________________________________
```

## Exercise 2-9: Promise Error Normalization

Write a helper that turns unknown values into `Error` objects:

```javascript
function normalizeError(value) {
  if (value instanceof Error) {
    return value;
  }

  return ______________________________________________;
}
```

## Part 2 Checkpoint

- [ ] I can describe Promise states.
- [ ] I can create a Promise.
- [ ] I can chain Promise handlers.
- [ ] I can use `.catch()`.
- [ ] I can use `.finally()`.
- [ ] I can write `async`/`await`.
- [ ] I can use `try`/`catch`/`finally`.
- [ ] I can distinguish sequential and parallel operations.
- [ ] I can prevent duplicate requests.

Checkpoint commit:

```text
_______________________________________________________
```

---

# Part 3 Workbook: Prototypes and Object-Oriented Patterns

## Exercise 3-1: Prototype Lookup

What does JavaScript do when a property is not found directly on an object?

```text
_______________________________________________________
_______________________________________________________
```

## Exercise 3-2: Factory Function

Write a factory function that creates an incomplete task:

```javascript
function createTask(title) {
  return {
    id: _______________________________________________,
    title: ____________________________________________,
    completed: ________________________________________,
  };
}
```

## Exercise 3-3: Constructor Function

Complete:

```javascript
function Task(title) {
  this.title = ____________;
  this.completed = _________;
}

const task = new ______________________("Learn constructors");
```

## Exercise 3-4: Class Conversion

Convert this constructor function to a class:

```javascript
function Task(title) {
  this.title = title;
  this.completed = false;
}

Task.prototype.complete = function () {
  this.completed = true;
};
```

Your class:

```javascript
_______________________________________________________
_______________________________________________________
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

## Exercise 3-5: Static Method

What is the difference between these calls?

```javascript
Task.fromJSON(value);
```

```javascript
task.fromJSON(value);
```

```text
_______________________________________________________
_______________________________________________________
```

## Exercise 3-6: Inheritance

Complete:

```javascript
class ImportedTask ________ Task {
  constructor(data) {
    ________(data);
    this.source = data.source;
  }
}
```

## Exercise 3-7: Model Invariants

List rules the `Task` constructor should enforce:

```text
1. ___________________________________________________

2. ___________________________________________________

3. ___________________________________________________

4. ___________________________________________________
```

## Exercise 3-8: JSON Restoration

Why is this not enough?

```javascript
const task = JSON.parse(rawJSON);
```

```text
_______________________________________________________
_______________________________________________________
```

What should be used instead?

```javascript
_______________________________________________________
```

## Part 3 Checkpoint

- [ ] I can explain a prototype chain.
- [ ] I can write a factory function.
- [ ] I understand constructor functions.
- [ ] I understand `new`.
- [ ] I can write a class.
- [ ] I can write a static method.
- [ ] I can use `extends`.
- [ ] I can use `super`.
- [ ] I can restore a class instance from JSON.

Checkpoint commit:

```text
_______________________________________________________
```

---

# Part 4 Workbook: Modules and Browser Storage

## Exercise 4-1: Module Responsibilities

Assign each responsibility to a module.

| Responsibility | Module |
|---|---|
| Define `Task` | __________________ |
| Save tasks | __________________ |
| Render task list | __________________ |
| Load remote tasks | __________________ |
| Coordinate application behavior | __________________ |
| Normalize errors | __________________ |

## Exercise 4-2: Named Exports

Write a named export:

```javascript
_______________________________________________________
```

Write the matching import:

```javascript
_______________________________________________________
```

## Exercise 4-3: Relative Import Paths

Given:

```text
js/services/task-service.js
js/models/task.js
```

Write the import:

```javascript
_______________________________________________________
```

## Exercise 4-4: localStorage

Write code that saves an array of tasks:

```javascript
localStorage.setItem(
  "async-task-manager.tasks.v1",
  _________________________________________________
);
```

## Exercise 4-5: Safe Loading

Complete:

```javascript
const rawValue = localStorage.getItem("tasks");

if (rawValue === null) {
  return [];
}

try {
  const parsedValue = _______________________________;
  return parsedValue;
} catch (error) {
  throw new Error("____________________________________");
}
```

## Exercise 4-6: sessionStorage

What type of data belongs in `sessionStorage`?

```text
_______________________________________________________
_______________________________________________________
```

What type of data belongs in `localStorage`?

```text
_______________________________________________________
_______________________________________________________
```

## Exercise 4-7: Storage Security

Why should browser storage not hold passwords or private API keys?

```text
_______________________________________________________
_______________________________________________________
```

## Exercise 4-8: Storage Failure

List two reasons a storage operation might fail:

```text
1. ___________________________________________________

2. ___________________________________________________
```

## Part 4 Checkpoint

- [ ] I can create named exports.
- [ ] I can import from another module.
- [ ] I understand relative module paths.
- [ ] I can save JSON to `localStorage`.
- [ ] I can parse JSON safely.
- [ ] I can restore class instances.
- [ ] I understand `sessionStorage`.
- [ ] I understand browser-storage security limits.

Checkpoint commit:

```text
_______________________________________________________
```

---

# Complete Project Build Worksheet

## Initial Files

Check each file when created:

- [ ] `index.html`
- [ ] `styles.css`
- [ ] `js/main.js`

## First Application Features

- [ ] Initial tasks render.
- [ ] Form accepts a task title.
- [ ] Empty title is rejected.
- [ ] Tasks can be completed.
- [ ] Loading button exists.
- [ ] Callback loader works.
- [ ] Loading state appears.
- [ ] Failure state appears.

## Promise Migration

- [ ] Callback loader replaced by Promise.
- [ ] `.then()` works.
- [ ] `.catch()` works.
- [ ] `.finally()` re-enables controls.
- [ ] `async`/`await` works.
- [ ] Duplicate loading is prevented.

## Task Model

- [ ] `Task` class created.
- [ ] Constructor validates input.
- [ ] `complete()` works.
- [ ] `reopen()` works.
- [ ] `toggleCompletion()` works.
- [ ] `toJSON()` works.
- [ ] `fromJSON()` works.

## Modularization

- [ ] `js/app.js`
- [ ] `js/api/task-api.js`
- [ ] `js/models/task.js`
- [ ] `js/services/storage-service.js`
- [ ] `js/services/task-service.js`
- [ ] `js/ui/status-message.js`
- [ ] `js/ui/task-form.js`
- [ ] `js/ui/task-list.js`
- [ ] `js/utils/errors.js`
- [ ] `js/utils/validation.js`

## Persistence

- [ ] Tasks save to `localStorage`.
- [ ] Tasks restore after refresh.
- [ ] Filter saves to `sessionStorage`.
- [ ] Malformed JSON is handled.
- [ ] Malformed task records are handled.
- [ ] Clear saved tasks works.

---

# Architecture Reflection

## Before Modularization

Describe the problems with a single large `main.js` file:

```text
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

## After Modularization

What does each layer own?

### Model

```text
_______________________________________________________
```

### Service

```text
_______________________________________________________
```

### API

```text
_______________________________________________________
```

### UI

```text
_______________________________________________________
```

### Storage

```text
_______________________________________________________
```

### Coordinator

```text
_______________________________________________________
```

---

# Final Testing Workbook

## Manual Test Matrix

| ID | Test | Expected result | Passed |
|---|---|---|---|
| T-001 | Initial startup | Page loads without errors | [ ] |
| T-002 | Add valid task | Task appears | [ ] |
| T-003 | Submit empty task | Error appears | [ ] |
| T-004 | Submit whitespace | Error appears | [ ] |
| T-005 | Complete task | Task becomes completed | [ ] |
| T-006 | Reopen task | Task becomes active | [ ] |
| T-007 | Delete task | Task disappears | [ ] |
| T-008 | Filter active tasks | Only active tasks appear | [ ] |
| T-009 | Filter completed tasks | Only completed tasks appear | [ ] |
| T-010 | Load example tasks | Tasks load asynchronously | [ ] |
| T-011 | Load failure | Error is displayed | [ ] |
| T-012 | Duplicate load | Only one request starts | [ ] |
| T-013 | Refresh after add | Task remains | [ ] |
| T-014 | Refresh after completion | State remains | [ ] |
| T-015 | Clear saved tasks | Tasks are removed | [ ] |
| T-016 | Malformed JSON | Error is handled | [ ] |
| T-017 | Malformed record | Invalid record is ignored | [ ] |
| T-018 | HTML-like title | Text is not executed | [ ] |
| T-019 | Keyboard navigation | All controls reachable | [ ] |
| T-020 | Mobile width | Layout remains usable | [ ] |

---

# Error Log

Use this table while building.

| Date | Error | Cause | Fix | Lesson |
|---|---|---|---|---|
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |

---

# Debugging Worksheet

When something fails, complete this before changing code.

```text
What action caused the problem?
_______________________________________________________

What did I expect?
_______________________________________________________

What actually happened?
_______________________________________________________

What is the first console error?
_______________________________________________________

What file and line are identified?
_______________________________________________________

What values are involved?
_______________________________________________________

What is my current hypothesis?
_______________________________________________________

What one change will I test?
_______________________________________________________

Did the fix work?
_______________________________________________________

Did regression tests pass?
_______________________________________________________
```

---

# Accessibility Workbook

## Semantic Structure

- [ ] One meaningful `h1`.
- [ ] Major sections use headings.
- [ ] Main content uses `<main>`.
- [ ] Tasks use `<ul>` and `<li>`.
- [ ] Actions use `<button>`.

## Forms

- [ ] Every input has a label.
- [ ] Required inputs are identified.
- [ ] Error text explains recovery.
- [ ] Invalid input uses `aria-invalid`.
- [ ] Help text uses `aria-describedby`.

## Keyboard

- [ ] All controls are reachable with Tab.
- [ ] Focus is visible.
- [ ] Buttons work with keyboard activation.
- [ ] No positive `tabindex` values are used.
- [ ] Focus does not disappear after rendering.

## Dynamic Content

- [ ] Loading state is announced.
- [ ] Success state is announced.
- [ ] Error state is announced.
- [ ] Completed state is textual.
- [ ] Empty state explains why the list is empty.

## Visual Presentation

- [ ] Text contrast is readable.
- [ ] Focus contrast is readable.
- [ ] Color is not the only status signal.
- [ ] Layout works when zoomed.
- [ ] Layout works at narrow widths.
- [ ] Reduced-motion preferences are considered.

---

# Security Workbook

## Input and Output

- [ ] User titles use `textContent`.
- [ ] No unsafe user-controlled `innerHTML`.
- [ ] API responses are validated.
- [ ] Storage values are validated.
- [ ] Imported files are validated.
- [ ] Query parameters are encoded.

## Secrets

- [ ] No passwords in source code.
- [ ] No API keys in frontend code.
- [ ] No tokens in `localStorage`.
- [ ] No private credentials in Git.
- [ ] Sensitive logs are removed.

## Network

- [ ] Production uses HTTPS.
- [ ] `response.ok` is checked.
- [ ] Network failures are handled.
- [ ] Request cancellation is considered.
- [ ] CORS is configured server-side.
- [ ] Authentication is not confused with authorization.

## Deployment

- [ ] Debug files removed.
- [ ] Test files removed or isolated.
- [ ] Security headers planned.
- [ ] CSP considered.
- [ ] Dependencies reviewed.
- [ ] Production errors monitored.

---

# Appendix Reflection Worksheets

## Appendix A: Complete Project

Which file was most difficult to understand?

```text
_______________________________________________________
```

Which file has the clearest responsibility?

```text
_______________________________________________________
```

## Appendix B: Syntax

Which syntax feature do you still need to practice?

```text
_______________________________________________________
```

Write an example:

```javascript
_______________________________________________________
_______________________________________________________
```

## Appendix C: Asynchrony

Explain the difference between a Promise and its result:

```text
_______________________________________________________
_______________________________________________________
```

## Appendix D: Storage

Why does JSON need to be parsed?

```text
_______________________________________________________
```

## Appendix E: Debugging

Which Developer Tools panel do you use most often?

```text
_______________________________________________________
```

Why?

```text
_______________________________________________________
```

## Appendix F: Testing

Which test is most important for this application?

```text
_______________________________________________________
```

Why?

```text
_______________________________________________________
```

## Appendix G: Accessibility

What would a keyboard-only user need to accomplish?

```text
_______________________________________________________
_______________________________________________________
```

## Appendix H: Security

What is the most important security rule in the project?

```text
_______________________________________________________
```

## Appendix I: Extensions

Which extension will you build next?

```text
_______________________________________________________
```

Plan:

```text
1. ___________________________________________________

2. ___________________________________________________

3. ___________________________________________________

4. ___________________________________________________
```

---

# Capstone Planning Worksheet

## Feature Name

```text
_______________________________________________________
```

## User Problem

What problem does this feature solve?

```text
_______________________________________________________
_______________________________________________________
```

## Target Users

```text
_______________________________________________________
```

## Data Changes

What new data is required?

```text
_______________________________________________________
_______________________________________________________
```

## Model Changes

What validation or methods are required?

```text
_______________________________________________________
_______________________________________________________
```

## Service Changes

What business operation is required?

```text
_______________________________________________________
_______________________________________________________
```

## UI Changes

What controls or visible output are required?

```text
_______________________________________________________
_______________________________________________________
```

## Storage Changes

Does the feature require persistence?

```text
[ ] Yes
[ ] No
```

If yes, what key or schema change is required?

```text
_______________________________________________________
```

## Error Cases

List possible failures:

```text
1. ___________________________________________________

2. ___________________________________________________

3. ___________________________________________________

4. ___________________________________________________
```

## Accessibility

How will keyboard and screen-reader users operate it?

```text
_______________________________________________________
_______________________________________________________
```

## Security

What input is untrusted?

```text
_______________________________________________________
```

How will it be validated or rendered safely?

```text
_______________________________________________________
```

## Verification Plan

```text
1. ___________________________________________________

2. ___________________________________________________

3. ___________________________________________________

4. ___________________________________________________
```

---

# Final Self-Assessment

Rate each skill from 1 to 5.

```text
1 = Need significant practice
2 = Can follow examples
3 = Can implement with some help
4 = Can implement independently
5 = Can explain and teach it
```

| Skill | Rating |
|---|---:|
| Synchronous execution | ____ |
| Blocking behavior | ____ |
| Call stack | ____ |
| Event loop | ____ |
| Callbacks | ____ |
| Promises | ____ |
| `async`/`await` | ____ |
| Error handling | ____ |
| Prototypes | ____ |
| Classes | ____ |
| Inheritance | ____ |
| Modules | ____ |
| `localStorage` | ____ |
| `sessionStorage` | ____ |
| JSON serialization | ____ |
| DOM rendering | ____ |
| Browser events | ____ |
| Debugging | ____ |
| Testing | ____ |
| Accessibility | ____ |
| Security | ____ |
| Git | ____ |

## Strongest Skill

```text
_______________________________________________________
```

## Skill Requiring More Practice

```text
_______________________________________________________
```

## Next Action

```text
_______________________________________________________
```

---

# Final Completion Checklist

- [ ] I completed the project setup.
- [ ] I ran the application through a local server.
- [ ] I can explain synchronous execution.
- [ ] I can explain the event loop.
- [ ] I replaced callbacks with Promises.
- [ ] I used `async`/`await`.
- [ ] I created a `Task` class.
- [ ] I used `extends` and `super`.
- [ ] I organized code into modules.
- [ ] I saved tasks to `localStorage`.
- [ ] I used `sessionStorage` for temporary preferences.
- [ ] I handled malformed JSON.
- [ ] I tested success and failure paths.
- [ ] I inspected the application with Developer Tools.
- [ ] I used Git checkpoints.
- [ ] I tested keyboard accessibility.
- [ ] I rendered user input safely.
- [ ] I reviewed production security considerations.
- [ ] I completed at least one extension exercise.
- [ ] I can explain the final architecture.

---

# Final Reflection

What did you understand at the beginning that now feels clearer?

```text
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

What changed most in the way you write JavaScript?

```text
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

What would you improve in the final application?

```text
_______________________________________________________
_______________________________________________________
_______________________________________________________
```

What will you build next?

```text
_______________________________________________________
_______________________________________________________
_______________________________________________________
```
