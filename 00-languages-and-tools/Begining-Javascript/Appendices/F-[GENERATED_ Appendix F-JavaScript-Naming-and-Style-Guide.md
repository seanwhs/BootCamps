# Appendix F: JavaScript Naming and Style Guide

A style guide is a shared set of rules for writing code consistently.

Style does not change what JavaScript can execute, but consistent style makes code:

- Easier to read.
- Easier to review.
- Easier to debug.
- Easier to maintain.
- Easier for another developer to extend.

This appendix focuses on practical conventions used in the task application.

---

# F.1 General Formatting Rules

## Use two spaces for indentation

```js
function createTask(title) {
  const task = {
    title,
    completed: false
  };

  return task;
}
```

Avoid mixing tabs and spaces within the same project.

## Use semicolons consistently

```js
const taskTitle = "Learn JavaScript";

console.log(taskTitle);
```

Although JavaScript can often insert semicolons automatically, writing them explicitly makes statement boundaries clear.

## Use one statement per line

Prefer:

```js
const title = "Learn JavaScript";
const completed = false;
```

Avoid:

```js
const title = "Learn JavaScript"; const completed = false;
```

## Use spaces around operators

Readable:

```js
const total = firstNumber + secondNumber;
```

Less readable:

```js
const total=firstNumber+secondNumber;
```

## Put spaces after commas

Readable:

```js
const task = {
  id: 1,
  title: "Read",
  completed: false
};
```

Avoid:

```js
const task={id:1,title:"Read",completed:false};
```

---

# F.2 Use Strict Mode

## Target

Make unsafe accidental behavior fail clearly.

## Implementation

Place this at the beginning of traditional script files:

### `src/app.js`

```js
"use strict";

const applicationName = "Task List";

console.log(applicationName);
```

## Verification

Temporarily add:

```js
undeclaredValue = 10;
```

The browser should report a `ReferenceError`.

Remove the invalid line afterward.

[COMPLETED: Strict mode convention documented]  
[NEXT: Naming variables]

---

# F.3 Variable Naming

## Target

Use descriptive names that explain what a value represents.

## Concept

A variable name is a label for information. Good labels reduce the amount of code a reader must mentally decode.

Prefer:

```js
const taskTitle = "Learn JavaScript";
const taskCount = 3;
const selectedTask = null;
```

Avoid:

```js
const x = "Learn JavaScript";
const n = 3;
const data = null;
```

Short names are acceptable for very small, obvious scopes, such as a loop index:

```js
for (let index = 0; index < tasks.length; index += 1) {
  console.log(tasks[index]);
}
```

## Naming style: camelCase

JavaScript variables and functions generally use `camelCase`:

```js
const taskTitleInput = "...";
const completedTaskCount = 2;
function renderTaskList() {}
```

The first word begins with a lowercase letter. Each following word begins with an uppercase letter.

Correct:

```js
taskTitle
completedTask
maximumTitleLength
```

Avoid:

```js
task_title
completed-task
MaximumTitleLength
```

## Boolean names

Boolean variables should sound like questions.

Use:

```js
const isCompleted = false;
const hasTasks = true;
const canSubmit = false;
const shouldRender = true;
```

Avoid vague names:

```js
const completed = false;
const tasks = true;
const submit = false;
```

The clearer versions make conditions easier to read:

```js
if (isCompleted) {
  markTaskAsComplete();
}

if (hasTasks) {
  renderTasks();
}
```

[COMPLETED: Variable naming conventions documented]  
[NEXT: Function naming]

---

# F.4 Function Naming

## Target

Name functions after the action they perform.

## Concept

Functions usually perform an operation, so their names should begin with a verb.

Good examples:

```js
createTask();
renderTasks();
removeTask();
validateTaskTitle();
calculateTotal();
findTaskById();
```

Poor examples:

```js
task();
thing();
process();
handle();
data();
```

A function name should answer:

> What does this function do?

## Examples

```js
function cleanTaskTitle(rawTitle) {
  return rawTitle.trim();
}

function isValidTaskTitle(title) {
  return title.length > 0;
}

function renderTask(task) {
  // Render one task.
}
```

Boolean-returning functions often begin with:

```text
is...
has...
can...
should...
```

Examples:

```js
function isValidTaskTitle(title) {
  return title.trim().length > 0;
}

function hasCompletedTasks(tasks) {
  return tasks.some((task) => task.completed);
}

function canRemoveTask(task, user) {
  return task.ownerId === user.id;
}
```

## Avoid misleading names

This function does not only validate. It also modifies the task:

```js
function validateTask(task) {
  task.completed = false;
  return true;
}
```

The name suggests inspection, but the function mutates data.

Use a name that describes both behavior:

```js
function resetTaskCompletion(task) {
  task.completed = false;
  return task;
}
```

[COMPLETED: Function naming conventions documented]  
[NEXT: DOM element names]

---

# F.5 Naming DOM Elements

## Target

Make it clear when a variable contains a DOM element.

## Implementation

Use an `Element` suffix:

```js
const taskFormElement =
  document.querySelector("#task-form");

const taskListElement =
  document.querySelector("#task-list");

const taskTitleInputElement =
  document.querySelector("#task-title");

const submitButtonElement =
  document.querySelector("button[type='submit']");
```

This distinguishes DOM elements from data values:

```js
const taskTitleInputElement =
  document.querySelector("#task-title");

const taskTitle =
  taskTitleInputElement.value.trim();
```

Without clear names, this is confusing:

```js
const taskTitle =
  document.querySelector("#task-title");

const taskTitleValue =
  taskTitle.value;
```

The first variable is not a title. It is an input element.

## Other useful suffixes

```js
const taskId = 1;
const taskElement = document.createElement("li");
const taskListElement = document.querySelector("#task-list");
const taskCountText = "3 tasks";
const taskData = {
  id: 1,
  title: "Read",
  completed: false
};
```

Use names that communicate both the type and role when helpful.

[COMPLETED: DOM naming conventions documented]  
[NEXT: Constants and magic values]

---

# F.6 Constants and Magic Values

## Target

Give important fixed values meaningful names.

## Concept

A **magic value** is a literal whose meaning is not obvious from its location.

Avoid:

```js
if (title.length > 120) {
  // ...
}
```

Prefer:

```js
const maximumTaskTitleLength = 120;

if (title.length > maximumTaskTitleLength) {
  // ...
}
```

The named constant explains the number.

## Implementation

### `src/constants.js`

```js
"use strict";

const maximumTaskTitleLength = 120;
const initialTaskId = 1;
const emptyTaskCount = 0;

console.log({
  maximumTaskTitleLength,
  initialTaskId,
  emptyTaskCount
});
```

Constants should generally use `camelCase` in JavaScript:

```js
const maximumTaskTitleLength = 120;
```

Some teams use uppercase names for configuration values:

```js
const MAXIMUM_TASK_TITLE_LENGTH = 120;
```

Either convention can work. Choose one convention and use it consistently.

For this series, ordinary `camelCase` is preferred.

[COMPLETED: Named constants documented]  
[NEXT: Function size and responsibility]

---

# F.7 One Function, One Main Responsibility

## Target

Keep each function focused.

## Concept

A function should usually answer one main question or perform one main operation.

Avoid a function that:

1. Reads form input.
2. Validates input.
3. Creates task data.
4. Saves data.
5. Creates DOM elements.
6. Displays an error.
7. Sends a network request.

That function becomes difficult to test and change.

## Less focused example

```js
function handleSubmit(event) {
  event.preventDefault();

  const title = taskTitleInputElement.value.trim();

  if (title.length === 0) {
    formMessageElement.textContent =
      "Enter a title.";

    return;
  }

  const task = {
    id: Date.now(),
    title,
    completed: false
  };

  tasks.push(task);

  const itemElement =
    document.createElement("li");

  itemElement.textContent = task.title;
  taskListElement.append(itemElement);

  localStorage.setItem(
    "tasks",
    JSON.stringify(tasks)
  );
}
```

This may work, but it combines many responsibilities.

## More focused version

```js
function getTaskTitleFromForm() {
  return taskTitleInputElement.value.trim();
}

function validateTaskTitle(title) {
  if (title.length === 0) {
    return {
      valid: false,
      message: "Enter a title."
    };
  }

  return {
    valid: true,
    message: ""
  };
}

function createTask(title, id) {
  return {
    id,
    title,
    completed: false
  };
}

function addTask(task) {
  tasks.push(task);
}

function handleSubmit(event) {
  event.preventDefault();

  const title = getTaskTitleFromForm();
  const validation = validateTaskTitle(title);

  if (!validation.valid) {
    showFormMessage(validation.message, "error");
    return;
  }

  const task = createTask(title, nextTaskId);
  nextTaskId += 1;

  addTask(task);
  renderTasks(tasks);
  saveTasks(tasks);
}
```

The handler still coordinates the operation, but the individual jobs are named and reusable.

[COMPLETED: Function responsibility guidance documented]  
[NEXT: Parameters and return values]

---

# F.8 Parameters and Return Values

## Target

Make functions explicit about their inputs and outputs.

## Implementation

Prefer:

```js
function calculateTotal(price, quantity) {
  return price * quantity;
}

const total = calculateTotal(12, 3);
```

Avoid hidden dependencies:

```js
let currentPrice = 12;
let currentQuantity = 3;

function calculateTotal() {
  return currentPrice * currentQuantity;
}
```

The second function depends on variables outside itself. That makes it harder to reuse and test.

## Return useful values

Prefer:

```js
function cleanTaskTitle(rawTitle) {
  return rawTitle.trim();
}
```

Then:

```js
const title = cleanTaskTitle(rawTitle);
```

Avoid making a utility function silently modify unrelated state:

```js
function cleanTaskTitle(rawTitle) {
  cleanedTitleElement.textContent =
    rawTitle.trim();
}
```

This function both cleans data and updates the DOM, which gives it two responsibilities.

[COMPLETED: Function inputs and outputs documented]  
[NEXT: Avoiding excessive nesting]

---

# F.9 Avoid Excessive Nesting

## Target

Keep conditional code readable.

## Less readable example

```js
function processTask(task, user) {
  if (task !== null) {
    if (user !== null) {
      if (user.isActive) {
        if (task.ownerId === user.id) {
          return "Allowed";
        }
      }
    }
  }

  return "Denied";
}
```

## Improved example

Use early returns:

```js
function canUserProcessTask(task, user) {
  if (task === null) {
    return false;
  }

  if (user === null) {
    return false;
  }

  if (!user.isActive) {
    return false;
  }

  return task.ownerId === user.id;
}

function processTask(task, user) {
  if (!canUserProcessTask(task, user)) {
    return "Denied";
  }

  return "Allowed";
}
```

The second version makes each rejection condition visible.

[COMPLETED: Nesting and early-return guidance documented]  
[NEXT: Data mutation conventions]

---

# F.10 Mutation and State Changes

## Target

Make data changes intentional and easy to identify.

## Concept

**Mutation** means changing an existing object or array.

This changes the original array:

```js
tasks.push(task);
```

This changes the original object:

```js
task.completed = true;
```

Mutation is not automatically bad. It becomes difficult when changes happen unexpectedly in many places.

## Make mutation explicit

Good:

```js
function completeTask(task) {
  task.completed = true;
}
```

The function name tells the reader that a change occurs.

Less clear:

```js
function getTask(task) {
  task.completed = true;
  return task;
}
```

The name suggests reading, but the function mutates.

## Immutable-style update

Instead of changing the original object:

```js
const updatedTask = {
  ...task,
  completed: true
};
```

Instead of mutating an array:

```js
const updatedTasks = tasks.map((currentTask) => {
  if (currentTask.id !== taskId) {
    return currentTask;
  }

  return {
    ...currentTask,
    completed: true
  };
});
```

Both styles are valid. The important rule is consistency.

[COMPLETED: Mutation conventions documented]  
[NEXT: Comments and documentation]

---

# F.11 Writing Useful Comments

## Target

Use comments to explain decisions, not obvious syntax.

## Weak comments

```js
// Create a task.
const task = createTask(title);

// Push the task.
tasks.push(task);
```

These comments repeat the code.

## Better comments

```js
/*
  The array is the source of truth for the interface.
  Rendering after this update keeps the DOM synchronized
  with the current application state.
*/
tasks.push(task);
renderTasks(tasks);
```

## Explain surprising behavior

```js
/*
  dataset values are always strings, so convert the task ID
  before comparing it with numeric task IDs.
*/
const taskId = Number(
  taskElement.dataset.taskId
);
```

## Explain security decisions

```js
/*
  Use textContent so user-entered titles are treated as text,
  not interpreted as HTML markup.
*/
titleElement.textContent = task.title;
```

## Keep comments current

Outdated comments are worse than no comments.

Incorrect:

```js
// The task ID is generated by the database.
const taskId = Date.now();
```

If the code changes, update the comment:

```js
/*
  This browser-only example generates an ID locally.
  A server-backed application should normally generate IDs
  in a trusted backend or database.
*/
const taskId = Date.now();
```

[COMPLETED: Commenting guidance documented]  
[NEXT: File organization]

---

# F.12 File and Directory Organization

## Target

Separate files by responsibility.

## Recommended structure

```text
javascript-foundations/
├── index.html
├── styles.css
└── src/
    ├── app.js
    ├── dom.js
    ├── tasks.js
    ├── validation.js
    └── storage.js
```

Possible responsibilities:

### `app.js`

Coordinates startup and event handling.

### `dom.js`

Contains DOM selection and rendering functions.

### `tasks.js`

Contains task creation and task-state operations.

### `validation.js`

Contains input-validation functions.

### `storage.js`

Contains persistence functions.

## Avoid one enormous file

A single file is acceptable for a small lesson. As the application grows, separate unrelated concerns.

Avoid:

```text
app.js
├── 1,500 lines of DOM logic
├── task validation
├── storage
├── API requests
└── unrelated utility functions
```

Separate files make the boundaries visible.

[COMPLETED: File organization guidance documented]  
[NEXT: Example modular style]

---

# F.13 Example Modular Style

## Target

Separate task logic from DOM logic.

## Implementation

### `src/tasks.js`

```js
"use strict";

export function createTask(title, id) {
  const cleanedTitle = title.trim();

  if (cleanedTitle.length === 0) {
    throw new Error(
      "Task title cannot be empty."
    );
  }

  return {
    id,
    title: cleanedTitle,
    completed: false
  };
}

export function findTaskById(tasks, taskId) {
  return tasks.find(
    (task) => task.id === taskId
  );
}

export function removeTaskById(tasks, taskId) {
  const taskIndex = tasks.findIndex(
    (task) => task.id === taskId
  );

  if (taskIndex === -1) {
    return false;
  }

  tasks.splice(taskIndex, 1);
  return true;
}
```

### `src/dom.js`

```js
"use strict";

export function createTaskElement(task) {
  const element =
    document.createElement("li");

  element.className = "task-item";
  element.dataset.taskId =
    String(task.id);

  element.textContent = task.title;

  return element;
}

export function renderTasks(
  taskListElement,
  tasks
) {
  taskListElement.replaceChildren();

  for (const task of tasks) {
    taskListElement.append(
      createTaskElement(task)
    );
  }
}
```

### `src/app.js`

```js
"use strict";

import {
  createTask,
  removeTaskById
} from "./tasks.js";

import {
  renderTasks
} from "./dom.js";

const taskListElement =
  document.querySelector("#task-list");

if (taskListElement === null) {
  throw new Error(
    "Task list element was not found."
  );
}

const tasks = [
  createTask("Learn modules", 1)
];

renderTasks(
  taskListElement,
  tasks
);

console.log("Application initialized.");
```

### `index.html`

```html
<script
  type="module"
  src="./src/app.js"
></script>
```

## Verification

Start the application with a local server.

The task should appear in the page.

A module should be served through a local server rather than opened directly with a `file://` URL, because browsers apply module security rules.

[COMPLETED: Modular code style demonstrated]  
[NEXT: Error-handling conventions]

---

# F.14 Error-Handling Style

## Target

Use errors for exceptional situations and return values for expected outcomes.

## Throw when the input violates a required contract

```js
function createTask(title) {
  if (typeof title !== "string") {
    throw new TypeError(
      "Task title must be a string."
    );
  }

  if (title.trim().length === 0) {
    throw new Error(
      "Task title cannot be empty."
    );
  }

  return {
    title: title.trim(),
    completed: false
  };
}
```

## Return a result when absence is expected

A search may reasonably fail to find an item:

```js
function findTaskById(tasks, taskId) {
  return tasks.find(
    (task) => task.id === taskId
  );
}

const task = findTaskById(tasks, taskId);

if (task === undefined) {
  showMessage("Task not found.", "error");
}
```

Do not throw for every expected condition.

## Include useful error messages

Weak:

```js
throw new Error("Invalid.");
```

Better:

```js
throw new Error(
  "Task title cannot exceed 120 characters."
);
```

An error message should help identify the invalid condition.

[COMPLETED: Error-handling conventions documented]  
[NEXT: Formatting tools]

---

# F.15 Automated Formatting with Prettier

## Target

Use a formatter to apply consistent spacing and line breaks.

## Concept

A formatter rewrites code according to a defined style. It does not decide whether your program is logically correct.

## Implementation

Install the **Prettier - Code formatter** extension in Visual Studio Code.

Create:

### `.prettierrc`

```json
{
  "semi": true,
  "singleQuote": false,
  "trailingComma": "none",
  "tabWidth": 2,
  "useTabs": false,
  "printWidth": 80
}
```

Example source:

```js
const task={id:1,title:"Read",completed:false};
```

After formatting:

```js
const task = {
  id: 1,
  title: "Read",
  completed: false
};
```

## Verification

Open a JavaScript file.

Use the editor’s format command:

- Windows/Linux:

```text
Shift + Alt + F
```

- macOS:

```text
Shift + Option + F
```

Save the file if Format on Save is enabled.

Review the changes before committing them. Formatting tools should not be used as a substitute for understanding the code.

[COMPLETED: Prettier formatting convention documented]  
[NEXT: Static analysis with ESLint]

---

# F.16 Static Analysis with ESLint

## Target

Use a linter to detect likely mistakes and inconsistent patterns.

## Concept

A **linter** analyzes code without running it. It can find issues such as:

- Undefined variables.
- Unused variables.
- Suspicious syntax.
- Inconsistent style.
- Some common programming errors.

A formatter changes appearance. A linter analyzes code quality.

## Implementation

For a Node.js project, initialize a package:

```bash
npm init -y
```

Install ESLint:

```bash
npm install --save-dev eslint
```

Create:

### `eslint.config.js`

```js
import eslint from "@eslint/js";

export default [
  {
    files: ["**/*.js"],
    ignores: [
      "node_modules/**"
    ],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module"
    },
    rules: {
      ...eslint.configs.recommended.rules,
      "no-console": "off"
    }
  }
];
```

Add a script to `package.json`:

```json
{
  "scripts": {
    "lint": "eslint ."
  }
}
```

## Verification

Run:

```bash
npm run lint
```

If there are no problems, ESLint exits successfully.

Introduce an unused variable:

```js
const unusedValue = 42;
```

Run the linter again. It should report the issue.

[COMPLETED: ESLint overview completed]  
[NEXT: Practical style checklist]

---

# F.17 Practical Style Checklist

Before considering a file complete, inspect it for:

## Naming

- [ ] Variables use descriptive `camelCase` names.
- [ ] Functions begin with action verbs.
- [ ] Boolean values use `is`, `has`, `can`, or `should`.
- [ ] DOM elements use an `Element` suffix where helpful.
- [ ] Constants explain important fixed values.

## Structure

- [ ] The file has a clear top-to-bottom organization.
- [ ] Functions have focused responsibilities.
- [ ] Related functions are grouped together.
- [ ] Event handlers are not unnecessarily large.
- [ ] State changes are easy to identify.

## Formatting

- [ ] Indentation is consistent.
- [ ] Semicolons are used consistently.
- [ ] Operators have spacing.
- [ ] Long expressions are readable.
- [ ] Formatting is handled consistently.

## Comments

- [ ] Comments explain architectural or non-obvious decisions.
- [ ] Security-sensitive operations have explanatory comments.
- [ ] Comments match the current implementation.
- [ ] Obvious code is not overloaded with unnecessary comments.

## Error handling

- [ ] Required DOM elements are validated.
- [ ] Invalid input is rejected.
- [ ] Errors contain useful messages.
- [ ] Expected missing data is handled without unnecessary exceptions.

[COMPLETED: Style checklist documented]  
[NEXT: Final style example]

---

# F.18 Complete Style Example

The following file applies the conventions from this appendix.

### `src/style-example.js`

```js
"use strict";

const maximumTaskTitleLength = 120;

const tasks = [];
let nextTaskId = 1;

function validateTaskTitle(rawTitle) {
  if (typeof rawTitle !== "string") {
    return {
      valid: false,
      message: "Task title must be text."
    };
  }

  const title = rawTitle.trim();

  if (title.length === 0) {
    return {
      valid: false,
      message: "Task title cannot be empty."
    };
  }

  if (title.length > maximumTaskTitleLength) {
    return {
      valid: false,
      message:
        "Task title cannot exceed 120 characters."
    };
  }

  return {
    valid: true,
    message: "",
    title
  };
}

function createTask(title) {
  const task = {
    id: nextTaskId,
    title,
    completed: false
  };

  nextTaskId += 1;

  return task;
}

function addTask(rawTitle) {
  const validation =
    validateTaskTitle(rawTitle);

  if (!validation.valid) {
    return {
      success: false,
      message: validation.message
    };
  }

  const task = createTask(validation.title);

  tasks.push(task);

  return {
    success: true,
    message: `Added task: ${task.title}`,
    task
  };
}

function describeTask(task) {
  const stateLabel = task.completed
    ? "complete"
    : "incomplete";

  return `${task.id}: ${task.title} (${stateLabel})`;
}

const firstResult =
  addTask("  Learn naming conventions  ");

const secondResult =
  addTask("Practice focused functions");

const invalidResult =
  addTask("   ");

console.log(firstResult);
console.log(secondResult);
console.log(invalidResult);

for (const task of tasks) {
  console.log(describeTask(task));
}
```

## Verification

Run the file in the browser console or through a local page.

Expected output should include:

```text
Added task: Learn naming conventions
Added task: Practice focused functions
Task title cannot be empty.
1: Learn naming conventions (incomplete)
2: Practice focused functions (incomplete)
```
