# Appendix G: Exercises and Challenges

This appendix provides practice tasks that build on the JavaScript application created in the series.

The exercises are arranged from beginner to advanced. Complete them in order when possible because later challenges depend on earlier concepts.

Each exercise includes:

- **The Goal**
- **The Concepts**
- **The Implementation**
- **The Verification**

Use the current project structure:

```text
javascript-foundations/
├── index.html
├── styles.css
└── src/
    └── part-4.js
```

Before beginning, make a copy of the working project:

```text
javascript-foundations/
└── javascript-foundations-backup/
```

That way, you can experiment without losing the verified version.

[COMPLETED: Appendix G introduction]  
[STARTING: Beginner exercises]

---

# G.1 Beginner Exercise: Display the Completed-Task Count

## The Goal

Display both:

```text
3 tasks
1 completed
```

The count should update whenever a task is completed, reopened, added, or removed.

## The Concepts

This exercise practices:

- Arrays.
- Loops.
- Conditions.
- DOM updates.
- Reusable functions.

## The Implementation

Add this element to `index.html` inside the task-list section:

### `index.html`

```html
<p id="completed-task-count">
  0 completed
</p>
```

Add this DOM reference near the other references in `src/part-4.js`:

### `src/part-4.js`

```js
const completedTaskCountElement =
  document.querySelector("#completed-task-count");

if (completedTaskCountElement === null) {
  throw new Error(
    "Could not find #completed-task-count."
  );
}
```

Create this function:

```js
function countCompletedTasks(tasks) {
  let completedCount = 0;

  for (const task of tasks) {
    if (task.completed) {
      completedCount += 1;
    }
  }

  return completedCount;
}
```

Update `renderTasks`:

```js
function renderTasks(tasks) {
  taskListElement.replaceChildren();

  for (const task of tasks) {
    taskListElement.append(
      createTaskElement(task)
    );
  }

  emptyStateElement.hidden = tasks.length > 0;

  taskCountElement.textContent =
    `${tasks.length} ${
      getTaskLabel(tasks.length)
    }`;

  const completedCount =
    countCompletedTasks(tasks);

  completedTaskCountElement.textContent =
    `${completedCount} completed`;
}
```

## The Verification

Refresh the page.

Initially, if two tasks exist and neither is complete, you should see:

```text
2 tasks
0 completed
```

Complete one task:

```text
2 tasks
1 completed
```

Complete the second task:

```text
2 tasks
2 completed
```

Undo one task:

```text
2 tasks
1 completed
```

Remove a completed task. The completed count should decrease.

[COMPLETED: Completed-task count exercise]  
[NEXT: Add a clear-completed action]

---

# G.2 Beginner Exercise: Clear Completed Tasks

## The Goal

Add a button that removes every completed task.

## The Concepts

This exercise practices:

- Filtering arrays.
- Reassigning array contents.
- Button events.
- Empty-state updates.
- Confirmation messages.

## The Implementation

Add this button beneath the task count in `index.html`:

### `index.html`

```html
<button
  id="clear-completed-button"
  type="button"
>
  Clear completed
</button>
```

Select and validate the button:

### `src/part-4.js`

```js
const clearCompletedButtonElement =
  document.querySelector(
    "#clear-completed-button"
  );

if (clearCompletedButtonElement === null) {
  throw new Error(
    "Could not find #clear-completed-button."
  );
}
```

Use `splice` to remove completed tasks safely:

```js
function removeCompletedTasks(tasks) {
  let removedCount = 0;

  for (
    let index = tasks.length - 1;
    index >= 0;
    index -= 1
  ) {
    if (tasks[index].completed) {
      tasks.splice(index, 1);
      removedCount += 1;
    }
  }

  return removedCount;
}
```

The reverse loop is important. Removing from the end toward the beginning prevents indexes from shifting before they are inspected.

Add the event listener:

```js
clearCompletedButtonElement.addEventListener(
  "click",
  () => {
    const removedCount =
      removeCompletedTasks(tasks);

    renderTasks(tasks);

    if (removedCount === 0) {
      showFormMessage(
        "There were no completed tasks to clear.",
        "normal"
      );

      return;
    }

    showFormMessage(
      `Cleared ${removedCount} completed ${
        removedCount === 1
          ? "task"
          : "tasks"
      }.`,
      "success"
    );
  }
);
```

## The Verification

Create three tasks.

Complete two tasks.

Click:

```text
Clear completed
```

Only the incomplete task should remain.

Click the button again.

The message should say:

```text
There were no completed tasks to clear.
```

[COMPLETED: Clear-completed exercise]  
[NEXT: Add task filtering]

---

# G.3 Beginner Exercise: Filter Tasks

## The Goal

Allow users to view:

- All tasks.
- Active tasks.
- Completed tasks.

## The Concepts

This exercise practices:

- `filter`.
- Buttons.
- Application state.
- Rendering derived data.
- Active filter state.

## The Implementation

Add filter buttons to `index.html`:

### `index.html`

```html
<div
  class="task-filters"
  aria-label="Task filters"
>
  <button
    type="button"
    data-filter="all"
    aria-pressed="true"
  >
    All
  </button>

  <button
    type="button"
    data-filter="active"
    aria-pressed="false"
  >
    Active
  </button>

  <button
    type="button"
    data-filter="completed"
    aria-pressed="false"
  >
    Completed
  </button>
</div>
```

Select the controls:

### `src/part-4.js`

```js
const filterButtonElements =
  document.querySelectorAll(
    "[data-filter]"
  );

let activeFilter = "all";
```

Create a filtering function:

```js
function getVisibleTasks(tasks, filter) {
  if (filter === "active") {
    return tasks.filter(
      (task) => !task.completed
    );
  }

  if (filter === "completed") {
    return tasks.filter(
      (task) => task.completed
    );
  }

  return tasks;
}
```

Update rendering:

```js
function renderTasks(tasks) {
  const visibleTasks =
    getVisibleTasks(tasks, activeFilter);

  taskListElement.replaceChildren();

  for (const task of visibleTasks) {
    taskListElement.append(
      createTaskElement(task)
    );
  }

  emptyStateElement.hidden =
    visibleTasks.length > 0;

  taskCountElement.textContent =
    `${visibleTasks.length} ${
      getTaskLabel(visibleTasks.length)
    }`;
}
```

Add event listeners:

```js
for (const filterButtonElement of filterButtonElements) {
  filterButtonElement.addEventListener(
    "click",
    () => {
      const selectedFilter =
        filterButtonElement.dataset.filter;

      if (
        selectedFilter !== "all" &&
        selectedFilter !== "active" &&
        selectedFilter !== "completed"
      ) {
        return;
      }

      activeFilter = selectedFilter;

      for (
        const currentButtonElement
        of filterButtonElements
      ) {
        const isSelected =
          currentButtonElement ===
          filterButtonElement;

        currentButtonElement.setAttribute(
          "aria-pressed",
          String(isSelected)
        );
      }

      renderTasks(tasks);
    }
  );
}
```

## The Verification

Create:

```text
Task A — incomplete
Task B — complete
Task C — incomplete
```

Click **All**.

Expected:

```text
Task A
Task B
Task C
```

Click **Active**.

Expected:

```text
Task A
Task C
```

Click **Completed**.

Expected:

```text
Task B
```

The selected filter button should have:

```html
aria-pressed="true"
```

[COMPLETED: Task-filtering exercise]  
[NEXT: Add task editing]

---

# G.4 Intermediate Exercise: Edit Tasks

## The Goal

Allow users to edit an existing task title.

## The Concepts

This exercise practices:

- Event delegation.
- Dynamic DOM replacement.
- Form creation.
- Input validation.
- Object mutation.
- Focus management.

## The Implementation

Add an Edit button to `createTaskElement`:

```js
const editButtonElement =
  document.createElement("button");

editButtonElement.type = "button";
editButtonElement.textContent = "Edit";
editButtonElement.dataset.action = "edit";
editButtonElement.setAttribute(
  "aria-label",
  `Edit ${task.title}`
);
```

Append it before the complete and remove buttons:

```js
actionsElement.append(
  editButtonElement,
  completeButtonElement,
  removeButtonElement
);
```

Add this function:

```js
function createEditFormElement(task) {
  const formElement =
    document.createElement("form");

  formElement.className =
    "task-item__edit-form";

  const inputElement =
    document.createElement("input");

  inputElement.type = "text";
  inputElement.value = task.title;
  inputElement.maxLength = 120;
  inputElement.required = true;
  inputElement.setAttribute(
    "aria-label",
    `Edit ${task.title}`
  );

  const saveButtonElement =
    document.createElement("button");

  saveButtonElement.type = "submit";
  saveButtonElement.textContent = "Save";

  const cancelButtonElement =
    document.createElement("button");

  cancelButtonElement.type = "button";
  cancelButtonElement.textContent = "Cancel";
  cancelButtonElement.dataset.action = "cancel-edit";

  formElement.append(
    inputElement,
    saveButtonElement,
    cancelButtonElement
  );

  return formElement;
}
```

Add an edit handler inside the task-list event delegation:

```js
if (action === "edit") {
  const editFormElement =
    createEditFormElement(task);

  taskElement.replaceChildren(editFormElement);

  const editInputElement =
    editFormElement.querySelector("input");

  if (editInputElement !== null) {
    editInputElement.focus();
    editInputElement.select();
  }

  return;
}
```

Handle the edit form’s submit event:

```js
taskListElement.addEventListener(
  "submit",
  (event) => {
    if (!(event.target instanceof HTMLFormElement)) {
      return;
    }

    event.preventDefault();

    const taskElement =
      event.target.closest("[data-task-id]");

    if (taskElement === null) {
      return;
    }

    const taskId = Number(
      taskElement.dataset.taskId
    );

    const task = findTaskById(tasks, taskId);

    if (task === undefined) {
      return;
    }

    const inputElement =
      event.target.querySelector("input");

    if (!(inputElement instanceof HTMLInputElement)) {
      return;
    }

    const newTitle = inputElement.value.trim();

    if (newTitle.length === 0) {
      showFormMessage(
        "Task title cannot be empty.",
        "error"
      );

      inputElement.focus();
      return;
    }

    task.title = newTitle;

    renderTasks(tasks);

    showFormMessage(
      `Updated task: ${task.title}`,
      "success"
    );
  }
);
```

## The Verification

1. Add a task.
2. Click **Edit**.
3. Confirm the title becomes an input.
4. Change the title.
5. Click **Save**.
6. Confirm the updated title appears.
7. Edit again.
8. Click **Cancel**.
9. Confirm the original title remains.

[COMPLETED: Task editing exercise]  
[NEXT: Add keyboard escape handling]

---

# G.5 Intermediate Exercise: Cancel Editing with Escape

## The Goal

Allow users to cancel task editing by pressing `Escape`.

## The Concepts

This exercise practices:

- Keyboard events.
- `event.key`.
- Event delegation.
- Restoring rendered state.

## The Implementation

Add a delegated keyboard listener:

### `src/part-4.js`

```js
taskListElement.addEventListener(
  "keydown",
  (event) => {
    if (event.key !== "Escape") {
      return;
    }

    if (!(event.target instanceof HTMLInputElement)) {
      return;
    }

    const taskElement =
      event.target.closest("[data-task-id]");

    if (taskElement === null) {
      return;
    }

    renderTasks(tasks);

    showFormMessage(
      "Editing cancelled.",
      "normal"
    );
  }
);
```

## The Verification

1. Click **Edit**.
2. Change the text.
3. Press `Escape`.
4. Confirm that the edit form disappears.
5. Confirm that the task returns to its saved title.

[COMPLETED: Escape-to-cancel exercise]  
[NEXT: Persist tasks with localStorage]

---

# G.6 Intermediate Exercise: Persist Tasks with `localStorage`

## The Goal

Keep tasks after the page reloads.

## The Concepts

`localStorage` stores text in the browser.

Because tasks are objects and arrays, convert them to JSON:

```js
JSON.stringify(tasks)
```

When reading them back:

```js
JSON.parse(savedTasks)
```

## The Implementation

Create:

### `src/storage.js`

```js
"use strict";

const storageKey = "javascript-foundations-tasks";

function saveTasks(tasks) {
  const serializedTasks =
    JSON.stringify(tasks);

  localStorage.setItem(
    storageKey,
    serializedTasks
  );
}

function loadTasks() {
  const serializedTasks =
    localStorage.getItem(storageKey);

  if (serializedTasks === null) {
    return [];
  }

  try {
    const parsedTasks =
      JSON.parse(serializedTasks);

    if (!Array.isArray(parsedTasks)) {
      return [];
    }

    return parsedTasks;
  } catch (error) {
    console.error(
      "Could not parse saved tasks:",
      error
    );

    return [];
  }
}
```

If using modules, export the functions:

```js
export {
  saveTasks,
  loadTasks
};
```

For a single-file version, place the functions directly in `part-4.js`.

Replace:

```js
const tasks = [
  createTask("Learn the DOM", 1),
  createTask("Practice element creation", 2)
];
```

with:

```js
const tasks = loadTasks();

let nextTaskId = tasks.reduce(
  (highestId, task) => {
    return Math.max(highestId, task.id);
  },
  0
) + 1;
```

After adding a task:

```js
tasks.push(task);
saveTasks(tasks);
renderTasks(tasks);
```

After completing a task:

```js
task.completed = !task.completed;
saveTasks(tasks);
renderTasks(tasks);
```

After removing a task:

```js
tasks.splice(taskIndex, 1);
saveTasks(tasks);
renderTasks(tasks);
```

## The Verification

1. Add a task.
2. Refresh the page.
3. Confirm that the task remains.
4. Complete a task.
5. Refresh again.
6. Confirm that it remains completed.
7. Remove a task.
8. Refresh.
9. Confirm that it remains removed.

Inspect storage in Developer Tools:

```text
Application → Local Storage → your local URL
```

The key should be:

```text
javascript-foundations-tasks
```

[COMPLETED: Local storage persistence exercise]  
[NEXT: Validate loaded storage data]

---

# G.7 Intermediate Exercise: Validate Stored Tasks

## The Goal

Prevent malformed stored data from breaking the application.

## The Concepts

Data in browser storage is external input. It may be:

- Missing.
- Corrupted.
- Edited manually.
- From an older application version.
- In the wrong shape.

Never assume parsed data is valid just because `JSON.parse` succeeded.

## The Implementation

Add:

```js
function isValidTask(value) {
  return (
    value !== null &&
    typeof value === "object" &&
    Number.isSafeInteger(value.id) &&
    value.id >= 0 &&
    typeof value.title === "string" &&
    value.title.trim().length > 0 &&
    value.title.length <= 120 &&
    typeof value.completed === "boolean"
  );
}
```

Update `loadTasks`:

```js
function loadTasks() {
  const serializedTasks =
    localStorage.getItem(storageKey);

  if (serializedTasks === null) {
    return [];
  }

  try {
    const parsedTasks =
      JSON.parse(serializedTasks);

    if (!Array.isArray(parsedTasks)) {
      return [];
    }

    return parsedTasks.filter(isValidTask);
  } catch (error) {
    console.error(
      "Could not parse saved tasks:",
      error
    );

    return [];
  }
}
```

## The Verification

Open the browser console and run:

```js
localStorage.setItem(
  "javascript-foundations-tasks",
  JSON.stringify([
    {
      id: 1,
      title: "Valid task",
      completed: false
    },
    {
      id: "bad-id",
      title: "Invalid task",
      completed: false
    }
  ])
);
```

Refresh the application.

Only the valid task should load.

Test malformed JSON:

```js
localStorage.setItem(
  "javascript-foundations-tasks",
  "not valid JSON"
);
```

Refresh the page.

The application should load with an empty task list rather than crashing.

[COMPLETED: Stored-data validation exercise]  
[NEXT: Add task statistics]

---

# G.8 Intermediate Exercise: Add Task Statistics

## The Goal

Display:

```text
Total: 5
Active: 3
Completed: 2
```

## The Concepts

This exercise practices:

- Derived state.
- `filter`.
- `length`.
- Rendering summary information.
- Keeping display calculations separate from mutation.

## The Implementation

Add this HTML:

### `index.html`

```html
<div
  id="task-statistics"
  aria-live="polite"
>
  Total: 0 | Active: 0 | Completed: 0
</div>
```

Add:

```js
const taskStatisticsElement =
  document.querySelector("#task-statistics");

if (taskStatisticsElement === null) {
  throw new Error(
    "Could not find #task-statistics."
  );
}
```

Create:

```js
function getTaskStatistics(tasks) {
  const completedTasks = tasks.filter(
    (task) => task.completed
  );

  return {
    total: tasks.length,
    active: tasks.length - completedTasks.length,
    completed: completedTasks.length
  };
}
```

Update rendering:

```js
function renderTaskStatistics(tasks) {
  const statistics =
    getTaskStatistics(tasks);

  taskStatisticsElement.textContent =
    `Total: ${statistics.total} | ` +
    `Active: ${statistics.active} | ` +
    `Completed: ${statistics.completed}`;
}
```

Call it from `renderTasks`:

```js
renderTaskStatistics(tasks);
```

## The Verification

Create five tasks.

Complete two.

Expected output:

```text
Total: 5 | Active: 3 | Completed: 2
```

Remove one completed task.

Expected output:

```text
Total: 4 | Active: 3 | Completed: 1
```

[COMPLETED: Task-statistics exercise]  
[NEXT: Advanced exercise — split into modules]

---

# G.9 Advanced Exercise: Split the Application into ES Modules

## The Goal

Separate task logic, storage, DOM logic, and application orchestration.

## The Concepts

An ES module is a JavaScript file with explicit imports and exports.

Benefits include:

- Smaller files.
- Clear dependencies.
- Easier testing.
- Better separation of responsibilities.

## The Implementation

Create this structure:

```text
src/
├── app.js
├── dom.js
├── storage.js
├── tasks.js
└── validation.js
```

### `src/validation.js`

```js
"use strict";

const maximumTaskTitleLength = 120;

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

export {
  validateTaskTitle
};
```

### `src/tasks.js`

```js
"use strict";

function createTask(title, id) {
  return {
    id,
    title,
    completed: false
  };
}

function findTaskById(tasks, taskId) {
  return tasks.find(
    (task) => task.id === taskId
  );
}

function removeTaskById(tasks, taskId) {
  const index = tasks.findIndex(
    (task) => task.id === taskId
  );

  if (index === -1) {
    return false;
  }

  tasks.splice(index, 1);
  return true;
}

export {
  createTask,
  findTaskById,
  removeTaskById
};
```

### `src/dom.js`

```js
"use strict";

function createTaskElement(task) {
  const listItemElement =
    document.createElement("li");

  listItemElement.className = "task-item";
  listItemElement.dataset.taskId =
    String(task.id);

  if (task.completed) {
    listItemElement.classList.add(
      "task-item--completed"
    );
  }

  const titleElement =
    document.createElement("p");

  titleElement.className =
    "task-item__title";

  titleElement.textContent = task.title;

  const completeButtonElement =
    document.createElement("button");

  completeButtonElement.type = "button";
  completeButtonElement.dataset.action =
    "toggle-complete";
  completeButtonElement.textContent =
    task.completed
      ? "Undo"
      : "Complete";

  const removeButtonElement =
    document.createElement("button");

  removeButtonElement.type = "button";
  removeButtonElement.dataset.action =
    "remove";
  removeButtonElement.textContent = "Remove";

  listItemElement.append(
    titleElement,
    completeButtonElement,
    removeButtonElement
  );

  return listItemElement;
}

function renderTasks(
  taskListElement,
  emptyStateElement,
  taskCountElement,
  tasks
) {
  taskListElement.replaceChildren();

  for (const task of tasks) {
    taskListElement.append(
      createTaskElement(task)
    );
  }

  emptyStateElement.hidden = tasks.length > 0;

  taskCountElement.textContent =
    `${tasks.length} ${
      tasks.length === 1
        ? "task"
        : "tasks"
    }`;
}

export {
  renderTasks
};
```

### `src/storage.js`

```js
"use strict";

const storageKey =
  "javascript-foundations-tasks";

function saveTasks(tasks) {
  localStorage.setItem(
    storageKey,
    JSON.stringify(tasks)
  );
}

function loadTasks() {
  const savedValue =
    localStorage.getItem(storageKey);

  if (savedValue === null) {
    return [];
  }

  try {
    const parsedValue =
      JSON.parse(savedValue);

    if (!Array.isArray(parsedValue)) {
      return [];
    }

    return parsedValue;
  } catch (error) {
    console.error(
      "Could not load tasks:",
      error
    );

    return [];
  }
}

export {
  saveTasks,
  loadTasks
};
```

### `src/app.js`

```js
"use strict";

import {
  createTask,
  findTaskById,
  removeTaskById
} from "./tasks.js";

import {
  validateTaskTitle
} from "./validation.js";

import {
  loadTasks,
  saveTasks
} from "./storage.js";

import {
  renderTasks
} from "./dom.js";

const taskFormElement =
  document.querySelector("#task-form");

const taskTitleInputElement =
  document.querySelector("#task-title");

const formMessageElement =
  document.querySelector("#form-message");

const taskListElement =
  document.querySelector("#task-list");

const emptyStateElement =
  document.querySelector("#empty-state");

const taskCountElement =
  document.querySelector("#task-count");

if (
  taskFormElement === null ||
  taskTitleInputElement === null ||
  formMessageElement === null ||
  taskListElement === null ||
  emptyStateElement === null ||
  taskCountElement === null
) {
  throw new Error(
    "Required application elements are missing."
  );
}

const tasks = loadTasks();

let nextTaskId = tasks.reduce(
  (highestId, task) => {
    return Math.max(highestId, task.id);
  },
  0
) + 1;

function showMessage(message) {
  formMessageElement.textContent = message;
}

function renderApplication() {
  renderTasks(
    taskListElement,
    emptyStateElement,
    taskCountElement,
    tasks
  );
}

taskFormElement.addEventListener(
  "submit",
  (event) => {
    event.preventDefault();

    const validation =
      validateTaskTitle(
        taskTitleInputElement.value
      );

    if (!validation.valid) {
      showMessage(validation.message);
      taskTitleInputElement.focus();
      return;
    }

    const task = createTask(
      validation.title,
      nextTaskId
    );

    nextTaskId += 1;
    tasks.push(task);
    saveTasks(tasks);
    renderApplication();

    taskFormElement.reset();

    showMessage(
      `Added task: ${task.title}`
    );
  }
);

taskListElement.addEventListener(
  "click",
  (event) => {
    if (!(event.target instanceof Element)) {
      return;
    }

    const buttonElement =
      event.target.closest("button");

    if (buttonElement === null) {
      return;
    }

    const taskElement =
      buttonElement.closest("[data-task-id]");

    if (taskElement === null) {
      return;
    }

    const taskId = Number(
      taskElement.dataset.taskId
    );

    const task = findTaskById(
      tasks,
      taskId
    );

    if (task === undefined) {
      return;
    }

    if (
      buttonElement.dataset.action ===
      "toggle-complete"
    ) {
      task.completed = !task.completed;
      saveTasks(tasks);
      renderApplication();

      showMessage(
        task.completed
          ? `Completed task: ${task.title}`
          : `Reopened task: ${task.title}`
      );

      return;
    }

    if (
      buttonElement.dataset.action ===
      "remove"
    ) {
      removeTaskById(tasks, taskId);
      saveTasks(tasks);
      renderApplication();

      showMessage(
        `Removed task: ${task.title}`
      );
    }
  }
);

renderApplication();
showMessage("Task application is ready.");
```

Update the script in HTML:

### `index.html`

```html
<script
  type="module"
  src="./src/app.js"
></script>
```

## The Verification

Start the application using Live Server.

Confirm:

- Tasks load.
- Tasks can be added.
- Tasks persist.
- Tasks can be completed.
- Tasks can be removed.
- The browser console has no module errors.

[COMPLETED: ES module architecture exercise]  
[NEXT: Advanced exercise — add automated tests]

---

# G.10 Advanced Exercise: Test the Task Logic

## The Goal

Test task functions independently from the browser interface.

## The Concepts

A unit test checks one small piece of behavior.

The test should answer:

```text
Given this input,
does the function produce the expected result?
```

## The Implementation

Create:

### `src/tasks.test.js`

```js
import {
  createTask,
  findTaskById,
  removeTaskById
} from "./tasks.js";

function assertEqual(
  actual,
  expected,
  message
) {
  if (actual !== expected) {
    throw new Error(
      `${message}: expected ${expected}, received ${actual}`
    );
  }
}

function assertTrue(value, message) {
  if (value !== true) {
    throw new Error(
      `${message}: expected true`
    );
  }
}

function assertFalse(value, message) {
  if (value !== false) {
    throw new Error(
      `${message}: expected false`
    );
  }
}

const task = createTask(
  "Learn testing",
  1
);

assertEqual(
  task.id,
  1,
  "Task ID should be 1"
);

assertEqual(
  task.title,
  "Learn testing",
  "Task title should be preserved"
);

assertFalse(
  task.completed,
  "New tasks should be incomplete"
);

const tasks = [
  task,
  createTask("Practice assertions", 2)
];

const foundTask =
  findTaskById(tasks, 2);

assertEqual(
  foundTask.title,
  "Practice assertions",
  "The task should be found by ID"
);

const removed =
  removeTaskById(tasks, 1);

assertTrue(
  removed,
  "Existing task should be removed"
);

assertEqual(
  tasks.length,
  1,
  "One task should remain"
);

console.log("All task tests passed.");
```

## Verification

Run the test file in an environment that supports ES modules.

For browser testing, create:

### `tests.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Task Tests</title>
  </head>

  <body>
    <p>
      Open the console to view test results.
    </p>

    <script
      type="module"
      src="./src/tasks.test.js"
    ></script>
  </body>
</html>
```

Open `tests.html` with Live Server.

Expected console output:

```text
All task tests passed.
```

Change the expected ID from:

```js
assertEqual(task.id, 1, ...)
```

to:

```js
assertEqual(task.id, 99, ...)
```

Refresh the page.

The test should throw an error. Restore the correct expectation afterward.

[COMPLETED: Task logic testing exercise]  
[NEXT: Advanced exercise — performance and rendering]

---

# G.11 Advanced Exercise: Avoid Unnecessary Rendering

## The Goal

Understand when to update one DOM element and when to render the whole list.

## The Concepts

The current application often calls:

```js
renderTasks(tasks);
```

after every change. This is simple and reliable, but it rebuilds every task element.

For small lists, this is usually acceptable.

For larger lists, you may update only the changed element.

## The Implementation

A direct update might look like:

```js
function updateTaskElement(
  taskElement,
  task,
  completeButtonElement
) {
  taskElement.classList.toggle(
    "task-item--completed",
    task.completed
  );

  completeButtonElement.textContent =
    task.completed
      ? "Undo"
      : "Complete";
}
```

Use it after changing the task:

```js
task.completed = !task.completed;

updateTaskElement(
  taskElement,
  task,
  actionButton
);
```

## Verification

Complete a task.

Inspect the DOM before and after.

Only the selected task’s classes and button text should change.

For the current beginner application, full rendering remains a reasonable default because it keeps state synchronization easy to understand.

[COMPLETED: Rendering-performance exercise]  
[NEXT: Challenge projects]

---

# G.12 Challenge Project: Task Priority

## Goal

Add task priority:

```text
low
medium
high
```

## Requirements

Each task should contain:

```js
{
  id: 1,
  title: "Study",
  completed: false,
  priority: "high"
}
```

Add:

- A priority `<select>`.
- Priority display in each task.
- Filtering by priority.
- Validation for allowed priority values.

## Suggested validation

```js
const allowedPriorities = [
  "low",
  "medium",
  "high"
];

function isValidPriority(priority) {
  return allowedPriorities.includes(priority);
}
```

## Verification

Confirm that:

- Invalid priority values are rejected.
- The selected priority is stored.
- The priority appears in the DOM.
- Filtering shows only matching tasks.

[COMPLETED: Task-priority challenge defined]  
[NEXT: Due dates and sorting]

---

# G.13 Challenge Project: Due Dates

## Goal

Add an optional due date.

## Requirements

Each task may contain:

```js
{
  id: 1,
  title: "Submit assignment",
  completed: false,
  dueDate: "2026-08-15"
}
```

Use an HTML date input:

```html
<input
  id="task-due-date"
  name="dueDate"
  type="date"
/>
```

Validate date values:

```js
function isValidDateString(value) {
  if (typeof value !== "string") {
    return false;
  }

  const date = new Date(`${value}T00:00:00`);

  return !Number.isNaN(date.getTime());
}
```

## Verification

Test:

- A task without a date.
- A task with a valid date.
- An invalid date.
- Sorting tasks by due date.
- Identifying overdue incomplete tasks.

[COMPLETED: Due-date challenge defined]  
[NEXT: Search and filtering]

---

# G.14 Challenge Project: Search Tasks

## Goal

Allow users to search tasks by title.

## Implementation

Add:

```html
<label for="task-search">
  Search tasks
</label>

<input
  id="task-search"
  type="search"
  autocomplete="off"
/>
```

Track the search value:

```js
let searchQuery = "";
```

Filter tasks:

```js
function getTasksMatchingSearch(
  tasks,
  searchQuery
) {
  const normalizedQuery =
    searchQuery.trim().toLowerCase();

  if (normalizedQuery.length === 0) {
    return tasks;
  }

  return tasks.filter((task) => {
    return task.title
      .toLowerCase()
      .includes(normalizedQuery);
  });
}
```

Handle input:

```js
taskSearchInputElement.addEventListener(
  "input",
  () => {
    searchQuery =
      taskSearchInputElement.value;

    renderTasks(tasks);
  }
);
```

Combine search filtering with status filtering:

```js
function getVisibleTasks(
  tasks,
  activeFilter,
  searchQuery
) {
  let visibleTasks = getTasksByFilter(
    tasks,
    activeFilter
  );

  visibleTasks =
    getTasksMatchingSearch(
      visibleTasks,
      searchQuery
    );

  return visibleTasks;
}
```

## Verification

Create tasks:

```text
Learn JavaScript
Practice CSS
Review DOM events
```

Search for:

```text
dom
```

Only:

```text
Review DOM events
```

should remain visible.

[COMPLETED: Search challenge defined]  
[NEXT: Final challenge roadmap]

---

# G.15 Challenge Project: Full Task Manager

Combine the previous challenges into one application with:

- Task creation.
- Task editing.
- Task removal.
- Completion toggling.
- Status filtering.
- Priority filtering.
- Search.
- Due dates.
- Task statistics.
- `localStorage` persistence.
- Keyboard support.
- Accessible status messages.
- Modular source files.
- Automated task-logic tests.

Recommended structure:

```text
javascript-foundations/
├── index.html
├── styles.css
├── package.json
├── eslint.config.js
├── src/
│   ├── app.js
│   ├── dom.js
│   ├── storage.js
│   ├── tasks.js
│   ├── validation.js
│   └── filters.js
└── tests/
    └── tasks.test.js
```

## Suggested development order

```text
1. Add priority.
2. Add due dates.
3. Add search.
4. Add filters.
5. Add localStorage.
6. Split into modules.
7. Add tests.
8. Add accessibility checks.
9. Add linting and formatting.
10. Review security boundaries.
```

Do not implement every feature in one giant change. Add one feature, verify it, then continue.

[COMPLETED: Full task-manager challenge roadmap]  
[STARTING: Exercise-solving strategy]

---

# G.16 How to Solve an Exercise

Use this process for every new feature.

## 1. Describe the behavior in plain language

Example:

```text
When the user clicks Completed,
only completed tasks should be displayed.
```

## 2. Identify the data change

Ask:

```text
Do I need a new property?
Do I need a new variable?
Do I need derived data?
```

For filtering:

```js
let activeFilter = "all";
```

## 3. Identify the UI change

Ask:

```text
Do I need a new input?
A button?
A status message?
A new task element?
```

## 4. Write a small function

Example:

```js
function getVisibleTasks(tasks, filter) {
  // ...
}
```

## 5. Connect the event

```js
button.addEventListener(
  "click",
  handleFilterClick
);
```

## 6. Render the result

```js
renderTasks(tasks);
```

## 7. Verify each state

Test:

- Empty data.
- One item.
- Multiple items.
- Invalid input.
- Repeated actions.
- Removal of the last item.
- Refresh behavior if persistence is enabled.

[COMPLETED: Exercise-solving strategy documented]  
[NEXT: Final exercise checklist]

---

# G.17 Exercise Verification Checklist

For each challenge, verify:

## Initial state

- [ ] The page loads without console errors.
- [ ] The expected empty state appears.
- [ ] Counts are correct.

## Valid input

- [ ] Valid data is accepted.
- [ ] The new item appears.
- [ ] The count updates.
- [ ] The form resets if appropriate.

## Invalid input

- [ ] Empty input is rejected.
- [ ] Whitespace-only input is rejected.
- [ ] Excessively long input is rejected.
- [ ] Error text explains the correction.

## State changes

- [ ] Completing an item updates its display.
- [ ] Undoing an item restores its display.
- [ ] Removing an item updates the count.
- [ ] Removing the last item restores the empty state.

## Dynamic behavior

- [ ] Newly created elements work.
- [ ] Event delegation still works.
- [ ] Keyboard interaction works.
- [ ] Focus remains logical.

## Persistence

- [ ] Data survives refresh.
- [ ] Malformed stored data does not crash the application.
- [ ] Removed data stays removed after refresh.

## Security

- [ ] HTML-looking input remains text.
- [ ] No user input is executed.
- [ ] URLs are validated if introduced.
- [ ] Data is validated after loading.

[COMPLETED: Exercise verification checklist documented]  
[NEXT: Appendix G completion]

---

# Appendix G Completion

You now have a progression of exercises covering:

- Completed-task counts.
- Clearing completed tasks.
- Filtering.
- Editing.
- Keyboard cancellation.
- `localStorage`.
- Stored-data validation.
- Statistics.
- ES modules.
- Automated tests.
- Rendering performance.
- Priority.
- Due dates.
- Search.
- Full task-manager architecture.

The most important habit is to grow the application incrementally:

```text
One feature
    ↓
One implementation
    ↓
One verification
    ↓
One refinement
```

Do not measure progress only by the number of features. Measure it by whether each feature is:

- Understandable.
- Tested.
- Accessible.
- Securely implemented.
- Consistent with the project’s architecture.
