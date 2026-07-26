# Primer 3: How to Read JavaScript

Writing JavaScript becomes much easier when you can read existing code confidently.

Many beginners try to understand every symbol at once. That often makes a small statement look more complicated than it is.

Instead, read code in layers:

```text
1. Identify the values.
2. Identify the variables.
3. Identify the operation.
4. Identify the result.
5. Identify what happens next.
```

This primer teaches you how to break JavaScript into understandable pieces.

---

# 1. Read Code from the Outside In

## The Target

Learn to analyze a statement by identifying its major parts.

## Concept

Consider this line:

```js
const taskTitle = "Learn JavaScript";
```

Read it from left to right:

```text
const       → declaration keyword
taskTitle   → variable name
=           → assignment operator
"Learn..."  → string value
;           → statement terminator
```

The entire line means:

> Create a variable named `taskTitle` and assign it the text `"Learn JavaScript"`.

## Implementation

### `reading-basics.js`

```js
"use strict";

const taskTitle = "Learn JavaScript";
const estimatedMinutes = 30;
const isCompleted = false;

console.log(taskTitle);
console.log(estimatedMinutes);
console.log(isCompleted);
```

## Verification

Run the file in a browser console or local page.

Expected output:

```text
Learn JavaScript
30
false
```

When reading a variable declaration, ask:

```text
What is being declared?
What is its name?
What value is assigned?
What type is that value?
```

[COMPLETED: Basic statement-reading model introduced]  
[NEXT: Read expressions]

---

# 2. Read Expressions as Value-Producing Operations

## The Target

Understand how expressions produce values.

## Concept

An expression is a piece of code that produces a result.

```js
4 + 6
```

produces:

```text
10
```

This expression:

```js
task.title
```

produces the value stored in the `title` property of `task`.

This expression:

```js
title.trim()
```

produces a new string with surrounding whitespace removed.

## Implementation

### `expressions-reading.js`

```js
"use strict";

const firstNumber = 4;
const secondNumber = 6;

const total = firstNumber + secondNumber;

const task = {
  title: "  Learn expressions  ",
  completed: false
};

const rawTitle = task.title;
const cleanTitle = task.title.trim();
const titleLength = cleanTitle.length;
const isEmpty = cleanTitle.length === 0;

console.log("Total:", total);
console.log("Raw title:", rawTitle);
console.log("Clean title:", cleanTitle);
console.log("Title length:", titleLength);
console.log("Is empty:", isEmpty);
```

## Verification

Expected output:

```text
Total: 10
Raw title:   Learn expressions
Clean title: Learn expressions
Title length: 18
Is empty: false
```

Identify each expression:

```js
firstNumber + secondNumber
task.title
task.title.trim()
cleanTitle.length
cleanTitle.length === 0
```

Their results are:

```text
10
"  Learn expressions  "
"Learn expressions"
18
false
```

A helpful question is:

> What value does this part of the code produce?

[COMPLETED: Expression-reading model verified]  
[NEXT: Read function calls]

---

# 3. Read Function Calls

## The Target

Understand how to read a function call.

## Concept

A function call asks a function to perform its operation.

```js
createTask("Learn functions", 1);
```

Break it apart:

```text
createTask      → function name
(...)           → call operator
"Learn..."      → first argument
1               → second argument
```

The function receives the arguments through its parameters.

## Implementation

### `function-calls-reading.js`

```js
"use strict";

function createTask(title, id) {
  return {
    id,
    title,
    completed: false
  };
}

const task = createTask(
  "Learn function calls",
  1
);

console.log(task);
```

## Verification

Expected output:

```text
{
  id: 1,
  title: "Learn function calls",
  completed: false
}
```

Read the call as:

```text
Call createTask with:
- title = "Learn function calls"
- id = 1
```

The returned object is assigned to:

```js
const task = ...
```

When reading a function call, ask:

1. What function is being called?
2. What arguments are supplied?
3. What does the function return?
4. Where is the returned value stored or used?

[COMPLETED: Function-call reading model verified]  
[NEXT: Read function definitions]

---

# 4. Read Function Definitions

## The Target

Understand the structure and responsibility of a function.

## Concept

A function definition describes an operation before it is used.

```js
function createTask(title, id) {
  return {
    id,
    title,
    completed: false
  };
}
```

Read it as:

```text
function       → function declaration keyword
createTask     → function name
(title, id)    → parameters
{ ... }        → function body
return         → sends a result back
```

The function has one clear responsibility:

> Create and return a task object.

## Implementation

### `function-definition-reading.js`

```js
"use strict";

function cleanTaskTitle(rawTitle) {
  const title = rawTitle.trim();

  return title;
}

function isValidTaskTitle(title) {
  return title.length > 0;
}

function createTask(title, id) {
  return {
    id,
    title,
    completed: false
  };
}

const rawTitle =
  "  Read function definitions  ";

const cleanedTitle =
  cleanTaskTitle(rawTitle);

if (!isValidTaskTitle(cleanedTitle)) {
  throw new Error(
    "The task title cannot be empty."
  );
}

const task = createTask(
  cleanedTitle,
  1
);

console.log(task);
```

## Verification

Expected output:

```text
{
  id: 1,
  title: "Read function definitions",
  completed: false
}
```

Read each function by answering:

```text
What input does it accept?
What work does it perform?
What does it return?
Does it change anything outside itself?
```

[COMPLETED: Function-definition reading model verified]  
[NEXT: Read conditional logic]

---

# 5. Read Conditional Logic

## The Target

Learn how to follow an `if` statement.

## Concept

A conditional has:

```js
if (condition) {
  // runs when condition is true
} else {
  // runs when condition is false
}
```

Read it in two stages:

1. Evaluate the condition.
2. Follow the branch matching the result.

## Implementation

### `conditions-reading.js`

```js
"use strict";

function describeTask(task) {
  if (task.completed) {
    return `${task.title} is complete.`;
  }

  return `${task.title} is incomplete.`;
}

const firstTask = {
  title: "Read conditions",
  completed: true
};

const secondTask = {
  title: "Practice conditions",
  completed: false
};

console.log(describeTask(firstTask));
console.log(describeTask(secondTask));
```

## Verification

Expected output:

```text
Read conditions is complete.
Practice conditions is incomplete.
```

Read the first call:

```js
describeTask(firstTask);
```

The function evaluates:

```js
firstTask.completed
```

which is:

```text
true
```

Therefore, it returns:

```text
"Read conditions is complete."
```

Read the second call:

```js
describeTask(secondTask);
```

The condition is:

```text
false
```

Therefore, execution reaches the second return statement.

[COMPLETED: Conditional-reading model verified]  
[NEXT: Read loops]

---

# 6. Read Loops One Iteration at a Time

## The Target

Learn how to trace a loop manually.

## Concept

Do not try to understand every loop iteration at once. Create a small table.

Given:

```js
const topics = [
  "variables",
  "functions",
  "arrays"
];

for (const topic of topics) {
  console.log(topic);
}
```

Trace it as:

| Iteration | `topic` |
|---:|---|
| 1 | `"variables"` |
| 2 | `"functions"` |
| 3 | `"arrays"` |

## Implementation

### `loops-reading.js`

```js
"use strict";

const topics = [
  "variables",
  "functions",
  "arrays"
];

const output = [];

for (const topic of topics) {
  output.push(`Topic: ${topic}`);
}

console.log(output.join("\n"));
```

## Verification

Expected output:

```text
Topic: variables
Topic: functions
Topic: arrays
```

For each iteration, ask:

```text
What value is the loop variable holding?
What instructions run?
What changes?
```

A traditional loop can be traced similarly:

```js
const numbers = [10, 20, 30];

for (
  let index = 0;
  index < numbers.length;
  index += 1
) {
  console.log(index, numbers[index]);
}
```

Trace:

| Iteration | `index` | Condition | Value |
|---:|---:|---|---:|
| 1 | 0 | `0 < 3` | 10 |
| 2 | 1 | `1 < 3` | 20 |
| 3 | 2 | `2 < 3` | 30 |
| 4 | 3 | `3 < 3` false | stops |

[COMPLETED: Loop-tracing model verified]  
[NEXT: Read arrays and objects together]

---

# 7. Read Nested Data Structures

## The Target

Understand property access inside arrays of objects.

## Concept

This expression:

```js
tasks[0].title
```

contains two operations:

```text
tasks[0]       → get the first object
.tasks.title   → get that object’s title
```

More precisely:

```text
tasks          → array
[0]            → first item
.title         → property on that item
```

## Implementation

### `nested-data-reading.js`

```js
"use strict";

const tasks = [
  {
    id: 1,
    title: "Read arrays",
    completed: true
  },
  {
    id: 2,
    title: "Read objects",
    completed: false
  }
];

const firstTask = tasks[0];
const firstTaskTitle = tasks[0].title;
const secondTaskCompleted =
  tasks[1].completed;

console.log("First task:", firstTask);
console.log("First title:", firstTaskTitle);
console.log(
  "Second task completed:",
  secondTaskCompleted
);
```

## Verification

Expected output:

```text
First task: { id: 1, title: "Read arrays", completed: true }
First title: Read arrays
Second task completed: false
```

When you see:

```js
tasks[index].completed
```

read it as:

```text
Get one task from the tasks array,
then read that task’s completed property.
```

[COMPLETED: Nested array-and-object reading verified]  
[NEXT: Read array methods]

---

# 8. Read Array Methods by Their Job

## The Target

Recognize the purpose of common array methods.

## Concept

Array methods usually describe an operation in their names.

```js
tasks.push(task);
```

means:

> Add `task` to the end of `tasks`.

```js
tasks.find(...)
```

means:

> Search for one matching item.

```js
tasks.filter(...)
```

means:

> Create a collection containing matching items.

## Implementation

### `array-methods-reading.js`

```js
"use strict";

const tasks = [
  {
    id: 1,
    title: "Read array methods",
    completed: true
  },
  {
    id: 2,
    title: "Practice filtering",
    completed: false
  }
];

const newTask = {
  id: 3,
  title: "Review the results",
  completed: false
};

tasks.push(newTask);

const completedTasks = tasks.filter(
  (task) => task.completed
);

const selectedTask = tasks.find(
  (task) => task.id === 2
);

const selectedTaskIndex = tasks.findIndex(
  (task) => task.id === 2
);

console.log("All tasks:", tasks);
console.log("Completed tasks:", completedTasks);
console.log("Selected task:", selectedTask);
console.log(
  "Selected task index:",
  selectedTaskIndex
);
```

## Verification

Expected facts:

```text
All tasks       → 3 items
Completed tasks → 1 item
Selected task   → task with id 2
Selected index  → 1
```

Read the callback:

```js
(task) => task.completed
```

as:

> For each task, keep it if its `completed` property is true.

Read:

```js
(task) => task.id === 2
```

as:

> Find the task whose ID strictly equals 2.

[COMPLETED: Array-method reading model verified]  
[NEXT: Read DOM code]

---

# 9. Read DOM Code as a Sequence

## The Target

Learn how to read browser code that connects data to the page.

## Concept

DOM code usually follows this sequence:

```text
Select an element
    ↓
Validate the selection
    ↓
Create or read data
    ↓
Change the element
    ↓
Attach the element or listener
```

## Implementation

### `dom-reading.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Reading DOM Code</title>
  </head>

  <body>
    <main>
      <h1 id="heading">Original heading</h1>

      <button
        id="button"
        type="button"
      >
        Change heading
      </button>
    </main>

    <script src="./dom-reading.js" defer></script>
  </body>
</html>
```

### `dom-reading.js`

```js
"use strict";

const headingElement =
  document.querySelector("#heading");

const buttonElement =
  document.querySelector("#button");

if (headingElement === null) {
  throw new Error(
    "Could not find the heading."
  );
}

if (buttonElement === null) {
  throw new Error(
    "Could not find the button."
  );
}

buttonElement.addEventListener(
  "click",
  () => {
    headingElement.textContent =
      "The heading changed.";
  }
);
```

## Verification

Read the file in this order:

1. Find the heading.
2. Find the button.
3. Stop if either is missing.
4. Register a click listener.
5. Change the heading when clicked.

Open the page and click the button.

Expected heading:

```text
The heading changed.
```

[COMPLETED: DOM-code reading sequence verified]  
[NEXT: Read event handlers]

---

# 10. Read Event Handlers as “When This Happens”

## The Target

Understand event-handler syntax.

## Concept

This code:

```js
buttonElement.addEventListener(
  "click",
  () => {
    // code
  }
);
```

means:

> When this button receives a click, run this function.

The first argument identifies the event:

```js
"click"
```

The second argument is the callback to run later.

The callback does not run when the listener is registered. It runs when the event occurs.

## Implementation

### `event-handler-reading.js`

```js
"use strict";

const buttonElement =
  document.querySelector("#button");

const messageElement =
  document.querySelector("#message");

if (buttonElement === null) {
  throw new Error(
    "Could not find the button."
  );
}

if (messageElement === null) {
  throw new Error(
    "Could not find the message."
  );
}

buttonElement.addEventListener(
  "click",
  (event) => {
    console.log(
      "Event type:",
      event.type
    );

    console.log(
      "Clicked element:",
      event.target
    );

    messageElement.textContent =
      "The event handler ran.";
  }
);
```

## Verification

Place this HTML before the script:

```html
<button
  id="button"
  type="button"
>
  Click me
</button>

<p id="message"></p>
```

Click the button.

The page should display:

```text
The event handler ran.
```

The console should show:

```text
Event type: click
Clicked element: ...
```

[COMPLETED: Event-handler reading model verified]  
[NEXT: Read form handlers]

---

# 11. Read Form Handlers as a Data Pipeline

## The Target

Understand a form handler as a sequence of transformations.

## Concept

A form handler commonly does this:

```text
Receive event
    ↓
Prevent browser default
    ↓
Read input
    ↓
Clean input
    ↓
Validate input
    ↓
Create data
    ↓
Store data
    ↓
Update interface
```

## Implementation

### `form-reading.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Reading Form Handlers</title>
  </head>

  <body>
    <main>
      <form id="task-form">
        <label for="task-title">
          Task title
        </label>

        <input
          id="task-title"
          name="title"
          type="text"
          required
        />

        <button type="submit">
          Add task
        </button>
      </form>

      <p
        id="message"
        role="status"
        aria-live="polite"
      ></p>

      <ul id="task-list"></ul>
    </main>

    <script src="./form-reading.js" defer></script>
  </body>
</html>
```

### `form-reading.js`

```js
"use strict";

const taskFormElement =
  document.querySelector("#task-form");

const taskTitleInputElement =
  document.querySelector("#task-title");

const messageElement =
  document.querySelector("#message");

const taskListElement =
  document.querySelector("#task-list");

if (
  !(taskFormElement instanceof HTMLFormElement)
) {
  throw new Error(
    "Could not find the form."
  );
}

if (
  !(taskTitleInputElement
    instanceof HTMLInputElement)
) {
  throw new Error(
    "Could not find the input."
  );
}

if (messageElement === null) {
  throw new Error(
    "Could not find the message."
  );
}

if (taskListElement === null) {
  throw new Error(
    "Could not find the task list."
  );
}

const tasks = [];
let nextTaskId = 1;

function renderTasks() {
  taskListElement.replaceChildren();

  for (const task of tasks) {
    const itemElement =
      document.createElement("li");

    itemElement.textContent = task.title;

    taskListElement.append(itemElement);
  }
}

taskFormElement.addEventListener(
  "submit",
  (event) => {
    event.preventDefault();

    const title =
      taskTitleInputElement.value.trim();

    if (title.length === 0) {
      messageElement.textContent =
        "Enter a task title.";

      return;
    }

    const task = {
      id: nextTaskId,
      title,
      completed: false
    };

    nextTaskId += 1;
    tasks.push(task);

    renderTasks();

    messageElement.textContent =
      `Added task: ${task.title}`;

    taskFormElement.reset();
  }
);

renderTasks();
```

## Verification

Read the handler from top to bottom:

```js
event.preventDefault();
```

The page will not reload.

```js
taskTitleInputElement.value.trim();
```

The input is read and cleaned.

```js
if (title.length === 0)
```

Empty input is rejected.

```js
const task = { ... };
```

A task object is created.

```js
tasks.push(task);
```

State changes.

```js
renderTasks();
```

The DOM is updated.

Submit:

```text
Read form handlers
```

Expected output:

```text
Added task: Read form handlers
```

[COMPLETED: Form-handler reading model verified]  
[NEXT: Read complete application flow]

---

# 12. Trace a Complete Application Flow

## The Target

Learn to follow one user action through the entire application.

## Concept

When debugging or studying code, trace one specific action instead of trying to understand the entire application at once.

For example:

```text
User clicks Add task
    ↓
submit event fires
    ↓
title is read
    ↓
title is trimmed
    ↓
task object is created
    ↓
task is pushed into array
    ↓
renderTasks runs
    ↓
new list item appears
```

## Implementation

Add diagnostic logging to the form handler:

### `trace-flow.js`

```js
"use strict";

const tasks = [];
let nextTaskId = 1;

function createTask(title) {
  console.log("Creating task with title:", title);

  return {
    id: nextTaskId,
    title,
    completed: false
  };
}

function addTask(rawTitle) {
  console.log("1. Raw input:", rawTitle);

  const title = rawTitle.trim();

  console.log("2. Clean input:", title);

  if (title.length === 0) {
    console.log("3. Validation failed.");
    return false;
  }

  const task = createTask(title);

  console.log("4. Created task:", task);

  nextTaskId += 1;
  tasks.push(task);

  console.log("5. Updated state:", tasks);

  return true;
}

const wasAdded = addTask(
  "  Trace one complete flow  "
);

console.log("6. Operation successful:", wasAdded);
```

## Verification

Expected console sequence:

```text
1. Raw input:   Trace one complete flow
2. Clean input: Trace one complete flow
Creating task with title: Trace one complete flow
4. Created task: ...
5. Updated state: ...
6. Operation successful: true
```

This technique is useful when an application behaves incorrectly. Add logs at the boundaries:

```text
input received
input transformed
data created
state changed
DOM rendered
```

[COMPLETED: Complete-flow tracing demonstrated]  
[NEXT: Read code by responsibility]

---

# 13. Read Code by Responsibility

## The Target

Identify what each function or section is responsible for.

## Concept

A well-organized application often has groups like:

```text
Validation
    → checks data

Data functions
    → create and update tasks

Rendering
    → updates the DOM

Event handlers
    → respond to user actions

Storage
    → saves and loads data
```

When reading code, label each function with its responsibility.

## Implementation

### `responsibility-reading.js`

```js
"use strict";

/*
  VALIDATION
*/
function isValidTitle(title) {
  return (
    typeof title === "string" &&
    title.trim().length > 0
  );
}

/*
  DATA CREATION
*/
function createTask(title, id) {
  return {
    id,
    title,
    completed: false
  };
}

/*
  DATA LOOKUP
*/
function findTaskById(tasks, id) {
  return tasks.find(
    (task) => task.id === id
  );
}

/*
  RENDERING
*/
function describeTask(task) {
  return task.completed
    ? `${task.title} (complete)`
    : `${task.title} (incomplete)`;
}

/*
  APPLICATION FLOW
*/
const rawTitle = "Learn responsibilities";

if (!isValidTitle(rawTitle)) {
  throw new Error("Invalid title.");
}

const task = createTask(
  rawTitle,
  1
);

const matchingTask = findTaskById(
  [task],
  1
);

console.log(describeTask(matchingTask));
```

## Verification

Expected output:

```text
Learn responsibilities (incomplete)
```

When reading an unfamiliar file, create a quick map:

```text
isValidTitle    → validation
createTask      → data creation
findTaskById    → data lookup
describeTask   → display formatting
main code       → orchestration
```

[COMPLETED: Responsibility-based reading demonstrated]  
[NEXT: Read errors and debugging clues]

---

# 14. Read Errors as Information

## The Target

Use error messages to locate the broken assumption.

## Concept

An error message usually tells you:

1. What kind of problem occurred.
2. Where it occurred.
3. Sometimes what value caused it.

Example:

```text
ReferenceError: task is not defined
```

Interpretation:

```text
Problem type: missing variable
Likely cause: spelling, scope, or declaration issue
```

## Implementation

### `error-reading.js`

```js
"use strict";

function getTaskTitle(task) {
  if (
    task === null ||
    typeof task !== "object"
  ) {
    throw new TypeError(
      "getTaskTitle expected a task object."
    );
  }

  if (typeof task.title !== "string") {
    throw new TypeError(
      "Task title must be a string."
    );
  }

  return task.title;
}

try {
  const task = {
    id: 1,
    title: "Read error messages"
  };

  console.log(getTaskTitle(task));
  console.log(getTaskTitle(null));
} catch (error) {
  console.error(
    "Application error:",
    error.message
  );
}
```

## Verification

Expected output:

```text
Read error messages
Application error: getTaskTitle expected a task object.
```

Do not only read the final line of an error. Look at:

- Error type.
- Error message.
- File name.
- Line number.
- Call stack.

[COMPLETED: Error-reading model demonstrated]  
[NEXT: A repeatable code-reading process]

---

# 15. A Repeatable Code-Reading Process

When you open an unfamiliar JavaScript file, use this process.

## Step 1: Find the entry point

Look for:

```html
<script
  src="./src/app.js"
  defer
></script>
```

or:

```html
<script
  type="module"
  src="./src/app.js"
></script>
```

This identifies the file the browser starts with.

## Step 2: Find DOM references

Look for:

```js
document.querySelector(...)
```

These reveal which page elements the application depends on.

## Step 3: Find application state

Look for:

```js
const tasks = [];
let currentFilter = "all";
```

These values describe what the application knows.

## Step 4: Find functions

Group them by responsibility:

```text
create...
find...
remove...
validate...
render...
handle...
```

## Step 5: Find event listeners

Look for:

```js
addEventListener(...)
```

These are the points where user actions enter the application.

## Step 6: Find state changes

Look for:

```js
tasks.push(...)
task.completed = ...
tasks.splice(...)
```

These lines change application data.

## Step 7: Find DOM updates

Look for:

```js
textContent
classList
append
remove
replaceChildren
```

These lines change what the user sees.

## Step 8: Trace one scenario

Write a plain-language sequence:

```text
Click Remove
    ↓
List listener runs
    ↓
Task ID is read
    ↓
Task is found
    ↓
Task is removed from array
    ↓
List is rendered again
```

[COMPLETED: Code-reading workflow documented]  
[NEXT: Primer 3 summary]

---

# 16. Primer 3 Summary

When reading JavaScript, do not begin by memorizing every symbol. Begin by identifying the structure.

## Read declarations

```js
const taskTitle = "Read code";
```

means:

```text
Create a named variable and assign a value.
```

## Read expressions

```js
task.title
task.title.trim()
tasks.length
```

means:

```text
Produce a value from existing data.
```

## Read function calls

```js
createTask("Read", 1);
```

means:

```text
Run createTask with two arguments.
```

## Read conditionals

```js
if (task.completed) {
  // one path
} else {
  // another path
}
```

means:

```text
Evaluate a condition and choose a path.
```

## Read loops

```js
for (const task of tasks) {
  // repeat for each task
}
```

means:

```text
Perform the same operation for each value.
```

## Read DOM code

```js
const button =
  document.querySelector("#button");
```

means:

```text
Find an HTML element so JavaScript can work with it.
```

## Read event handlers

```js
button.addEventListener(
  "click",
  handler
);
```

means:

```text
When the button is clicked, run handler.
```

## Read application flow

```text
Input
    ↓
Validation
    ↓
State update
    ↓
Rendering
```

That pattern is the foundation of the task application.
