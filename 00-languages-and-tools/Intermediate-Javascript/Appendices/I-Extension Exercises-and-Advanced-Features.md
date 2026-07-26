# Appendix I: Extension Exercises and Advanced Features

The completed Async Task Manager is a working foundation. This appendix provides progressively more difficult exercises for extending it.

Each exercise includes:

- **The Target**
- **The Concept**
- **The Implementation**
- **The Verification**

The exercises are ordered from simpler interface improvements to larger architectural changes.

---

# Exercise 1: Add Task Priorities

## The Target

Add a priority to every task:

```text
Low
Normal
High
```

The priority should:

- Be validated.
- Appear in the interface.
- Persist in `localStorage`.
- Be restored through `Task.fromJSON()`.

## The Concept

A task currently has:

```javascript
id
title
completed
createdAt
```

We will add:

```javascript
priority
```

The model remains responsible for enforcing valid values. The UI may display a priority selector, but it must not be the only place where validation occurs.

---

## The Implementation

### `js/models/task.js`

Replace the complete file with:

```javascript
"use strict";

export const TASK_PRIORITIES = Object.freeze([
  "low",
  "normal",
  "high",
]);

function isValidPriority(priority) {
  return TASK_PRIORITIES.includes(priority);
}

export class Task {
  constructor({
    id = Task.createId(),
    title,
    completed = false,
    priority = "normal",
    createdAt = new Date(),
  }) {
    if (!Number.isInteger(id) || id < 0) {
      throw new TypeError("Task id must be a non-negative integer.");
    }

    if (typeof title !== "string") {
      throw new TypeError("Task title must be a string.");
    }

    const normalizedTitle = title.trim();

    if (normalizedTitle.length === 0) {
      throw new Error("Task title cannot be empty.");
    }

    if (normalizedTitle.length > 120) {
      throw new Error("Task title cannot exceed 120 characters.");
    }

    if (typeof completed !== "boolean") {
      throw new TypeError("Task completed state must be a boolean.");
    }

    if (!isValidPriority(priority)) {
      throw new Error(
        `Task priority must be one of: ${TASK_PRIORITIES.join(", ")}.`
      );
    }

    const normalizedCreatedAt =
      createdAt instanceof Date ? createdAt : new Date(createdAt);

    if (Number.isNaN(normalizedCreatedAt.getTime())) {
      throw new TypeError("Task createdAt must be a valid date.");
    }

    this.id = id;
    this.title = normalizedTitle;
    this.completed = completed;
    this.priority = priority;
    this.createdAt = normalizedCreatedAt;
  }

  static createId() {
    return Date.now() + Math.floor(Math.random() * 100000);
  }

  static fromJSON(value) {
    if (typeof value !== "object" || value === null) {
      throw new TypeError("Stored task must be an object.");
    }

    return new Task({
      id: value.id,
      title: value.title,
      completed: value.completed,
      priority: value.priority ?? "normal",
      createdAt: value.createdAt,
    });
  }

  complete() {
    this.completed = true;
  }

  reopen() {
    this.completed = false;
  }

  toggleCompletion() {
    this.completed = !this.completed;
  }

  isCompleted() {
    return this.completed;
  }

  getPriorityLabel() {
    return this.priority[0].toUpperCase() + this.priority.slice(1);
  }

  getStatusLabel() {
    return this.completed ? "Completed" : "Not completed";
  }

  toJSON() {
    return {
      id: this.id,
      title: this.title,
      completed: this.completed,
      priority: this.priority,
      createdAt: this.createdAt.toISOString(),
    };
  }
}
```

### `index.html`

Inside the task form, add a priority selector:

```html
<div class="form-row">
  <label for="task-priority">Priority</label>

  <select id="task-priority" name="taskPriority">
    <option value="low">Low</option>
    <option value="normal" selected>Normal</option>
    <option value="high">High</option>
  </select>
</div>
```

### `js/ui/task-form.js`

Replace the file:

```javascript
"use strict";

export function bindTaskForm(formElement, onSubmit) {
  if (!(formElement instanceof HTMLFormElement)) {
    throw new TypeError("A form element is required.");
  }

  if (typeof onSubmit !== "function") {
    throw new TypeError("onSubmit must be a function.");
  }

  const titleInput = formElement.elements.namedItem("taskTitle");
  const priorityInput = formElement.elements.namedItem("taskPriority");

  if (!(titleInput instanceof HTMLInputElement)) {
    throw new Error("The task title input could not be found.");
  }

  if (!(priorityInput instanceof HTMLSelectElement)) {
    throw new Error("The task priority input could not be found.");
  }

  formElement.addEventListener("submit", (event) => {
    event.preventDefault();

    onSubmit({
      title: titleInput.value,
      priority: priorityInput.value,
    });

    titleInput.value = "";
    priorityInput.value = "normal";
    titleInput.focus();
  });
}
```

### `js/services/task-service.js`

Update the `add()` method:

```javascript
add({ title, priority = "normal" }) {
  const normalizedTitle = validateTaskTitle(title);

  const task = new Task({
    title: normalizedTitle,
    priority,
  });

  this.tasks.push(task);

  return task;
}
```

### `js/app.js`

Update the form binding:

```javascript
bindTaskForm(this.taskForm, (taskInput) => {
  this.handleAddTask(taskInput);
});
```

Update `handleAddTask()`:

```javascript
handleAddTask(taskInput) {
  try {
    const task = this.taskService.add(taskInput);

    this.persistTasks();
    this.render();

    this.status.show(
      `Added ${task.getPriorityLabel().toLowerCase()} priority task: ${task.title}`,
      "success"
    );
  } catch (error) {
    const normalizedError = normalizeError(error);
    this.status.show(normalizedError.message, "error");
  }
}
```

### `js/ui/task-list.js`

Add priority metadata:

```javascript
const priority = document.createElement("p");
priority.className = `task-meta task-priority-${task.priority}`;
priority.textContent = `Priority: ${task.getPriorityLabel()}`;

textContainer.append(title, metadata, priority);
```

### `styles.css`

```css
.task-priority-high {
  color: #8c1f2d;
  font-weight: 700;
}

.task-priority-normal {
  color: #536078;
}

.task-priority-low {
  color: #28734f;
}
```

## The Verification

1. Add a high-priority task.
2. Confirm that `Priority: High` appears.
3. Refresh the page.
4. Confirm that the priority remains.
5. Inspect storage:

```javascript
JSON.parse(
  localStorage.getItem(
    "async-task-manager.tasks.v1"
  )
);
```

Each task should contain:

```javascript
{
  priority: "high"
}
```

Test invalid data:

```javascript
new Task({
  title: "Invalid priority",
  priority: "urgent",
});
```

The constructor should throw an error.

[COMPLETED: Exercise 1 — Task priorities added]  
[STARTING: Exercise 2 — Add task editing]

---

# Exercise 2: Add Task Editing

## The Target

Allow users to edit an existing task title.

The feature should:

- Show an edit button.
- Replace the title with an input.
- Save the updated title.
- Cancel editing.
- Validate the new title.
- Persist the change.

## The Concept

Editing temporarily changes a display-only task row into an input interface.

The task service should own the actual title update. The UI should only collect the new value.

---

## The Implementation

### `js/models/task.js`

Add this method to the `Task` class:

```javascript
updateTitle(title) {
  if (typeof title !== "string") {
    throw new TypeError("Task title must be a string.");
  }

  const normalizedTitle = title.trim();

  if (normalizedTitle.length === 0) {
    throw new Error("Task title cannot be empty.");
  }

  if (normalizedTitle.length > 120) {
    throw new Error("Task title cannot exceed 120 characters.");
  }

  this.title = normalizedTitle;
}
```

### `js/services/task-service.js`

Add this method:

```javascript
updateTitle(taskId, title) {
  const task = this.findById(taskId);

  if (!task) {
    throw new Error("The selected task could not be found.");
  }

  task.updateTitle(title);

  return task;
}
```

### `js/ui/task-list.js`

Replace the title creation section:

```javascript
const title = document.createElement("p");
title.className = "task-title";
title.textContent = task.title;

textContainer.append(title);
```

with an editable title container:

```javascript
const title = document.createElement("p");
title.className = "task-title";
title.textContent = task.title;

textContainer.append(title);
```

Then add an edit button to the actions:

```javascript
const editButton = document.createElement("button");
editButton.type = "button";
editButton.className = "task-action";
editButton.textContent = "Edit";
editButton.setAttribute(
  "aria-label",
  `Edit task: ${task.title}`
);

editButton.addEventListener("click", () => {
  onEdit(task.id);
});
```

Update the function signature:

```javascript
export function renderTaskList(
  listElement,
  tasks,
  { onToggle, onDelete, onEdit }
) {
```

Validate the callback:

```javascript
if (typeof onEdit !== "function") {
  throw new TypeError("onEdit must be a function.");
}
```

Add the button:

```javascript
actions.append(
  editButton,
  toggleButton,
  deleteButton
);
```

### `js/app.js`

Add the handler when rendering:

```javascript
renderTaskList(this.taskList, visibleTasks, {
  onToggle: (taskId) => {
    this.handleToggleTask(taskId);
  },
  onDelete: (taskId) => {
    this.handleDeleteTask(taskId);
  },
  onEdit: (taskId) => {
    this.handleEditTask(taskId);
  },
});
```

Add this method:

```javascript
handleEditTask(taskId) {
  const task = this.taskService.findById(taskId);

  if (!task) {
    this.status.show(
      "The selected task could not be found.",
      "error"
    );
    return;
  }

  const updatedTitle = window.prompt(
    "Update the task title:",
    task.title
  );

  if (updatedTitle === null) {
    return;
  }

  try {
    this.taskService.updateTitle(
      taskId,
      updatedTitle
    );

    this.persistTasks();
    this.render();
    this.status.show("Task updated.", "success");
  } catch (error) {
    const normalizedError = normalizeError(error);
    this.status.show(normalizedError.message, "error");
  }
}
```

## The Verification

1. Add a task.
2. Click **Edit**.
3. Change the title.
4. Confirm the updated title appears.
5. Refresh the page.
6. Confirm the updated title persists.
7. Try changing the title to whitespace.
8. Confirm the validation error appears.
9. Cancel the prompt.
10. Confirm the original title remains.

[COMPLETED: Exercise 2 — Task editing added]  
[STARTING: Exercise 3 — Add task searching]

---

# Exercise 3: Add Task Search

## The Target

Add a search field that filters tasks by title.

The search should:

- Update as the user types.
- Work with the existing status filter.
- Be case-insensitive.
- Not modify stored data.
- Remain in memory while the page is open.

## The Concept

Filtering can be composed in stages:

```text
All tasks
    ↓
Search filter
    ↓
Status filter
    ↓
Visible tasks
```

The task service should expose separate operations so the application can combine them clearly.

---

## The Implementation

### `index.html`

Add this section:

```html
<section class="panel" aria-labelledby="search-heading">
  <h2 id="search-heading">Search tasks</h2>

  <label for="task-search">Search by title</label>

  <input
    id="task-search"
    type="search"
    autocomplete="off"
    placeholder="Type to search tasks"
  />
</section>
```

### `js/services/task-service.js`

Add this method:

```javascript
search(query) {
  const normalizedQuery = query.trim().toLowerCase();

  if (normalizedQuery.length === 0) {
    return this.getAll();
  }

  return this.tasks.filter((task) => {
    return task.title.toLowerCase().includes(normalizedQuery);
  });
}
```

### `js/app.js`

In the constructor, add:

```javascript
this.searchQuery = "";
```

Add `searchInput` to the constructor parameters:

```javascript
constructor({
  taskForm,
  taskList,
  taskCount,
  statusMessage,
  loadTasksButton,
  clearTasksButton,
  taskFilter,
  searchInput,
}) {
```

Store it:

```javascript
this.searchInput = searchInput;
```

In `main.js`, pass the element:

```javascript
searchInput: document.querySelector("#task-search"),
```

Add this event listener in `bindEvents()`:

```javascript
this.searchInput.addEventListener("input", () => {
  this.searchQuery = this.searchInput.value;
  this.render();
});
```

Replace the beginning of `render()`:

```javascript
const visibleTasks = this.taskService.getByFilter(
  this.currentFilter
);
```

with:

```javascript
const searchedTasks = this.taskService.search(
  this.searchQuery
);

const visibleTasks = searchedTasks.filter((task) => {
  if (this.currentFilter === "active") {
    return !task.isCompleted();
  }

  if (this.currentFilter === "completed") {
    return task.isCompleted();
  }

  return true;
});
```

## The Verification

1. Create these tasks:

```text
Study Promises
Study classes
Practice modules
```

2. Type:

```text
study
```

3. Confirm that only the first two tasks appear.
4. Select **Completed tasks**.
5. Confirm search and status filtering work together.
6. Clear the search.
7. Confirm the normal filtered list returns.
8. Refresh the page.
9. Confirm the search is cleared unless you intentionally persist it.

[COMPLETED: Exercise 3 — Task search added]  
[STARTING: Exercise 4 — Add due dates]

---

# Exercise 4: Add Due Dates

## The Target

Add optional due dates to tasks.

The application should:

- Allow a due date to be selected.
- Store it as an ISO string.
- Display it in a readable format.
- Detect overdue active tasks.
- Validate invalid dates.

## The Concept

Dates should be stored in a stable machine-readable format:

```text
2026-07-23T00:00:00.000Z
```

They should be formatted only when displayed.

Do not store localized display text such as:

```text
07/23/2026
```

because its meaning can vary by locale.

---

## The Implementation

### `js/models/task.js`

Add `dueDate` to the constructor:

```javascript
dueDate = null,
```

Validate it:

```javascript
let normalizedDueDate = null;

if (dueDate !== null) {
  normalizedDueDate =
    dueDate instanceof Date
      ? dueDate
      : new Date(dueDate);

  if (Number.isNaN(normalizedDueDate.getTime())) {
    throw new TypeError("Task dueDate must be valid.");
  }
}
```

Store it:

```javascript
this.dueDate = normalizedDueDate;
```

Add methods:

```javascript
isOverdue(now = new Date()) {
  return (
    !this.completed &&
    this.dueDate instanceof Date &&
    this.dueDate.getTime() < now.getTime()
  );
}

getDueDateLabel(locale = undefined) {
  if (!(this.dueDate instanceof Date)) {
    return "No due date";
  }

  return this.dueDate.toLocaleDateString(locale, {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}
```

Update `toJSON()`:

```javascript
toJSON() {
  return {
    id: this.id,
    title: this.title,
    completed: this.completed,
    priority: this.priority,
    dueDate: this.dueDate?.toISOString() ?? null,
    createdAt: this.createdAt.toISOString(),
  };
}
```

Update `fromJSON()`:

```javascript
dueDate: value.dueDate ?? null,
```

### `index.html`

Add inside the task form:

```html
<div class="form-row">
  <label for="task-due-date">Due date</label>

  <input
    id="task-due-date"
    name="taskDueDate"
    type="date"
  />
</div>
```

### `js/ui/task-form.js`

Read the field:

```javascript
const dueDateInput =
  formElement.elements.namedItem("taskDueDate");
```

Validate it:

```javascript
if (!(dueDateInput instanceof HTMLInputElement)) {
  throw new Error("The due date input could not be found.");
}
```

Pass it to the callback:

```javascript
onSubmit({
  title: titleInput.value,
  priority: priorityInput.value,
  dueDate: dueDateInput.value || null,
});
```

Reset it:

```javascript
dueDateInput.value = "";
```

### `js/services/task-service.js`

Update `add()`:

```javascript
add({
  title,
  priority = "normal",
  dueDate = null,
}) {
  const normalizedTitle = validateTaskTitle(title);

  const task = new Task({
    title: normalizedTitle,
    priority,
    dueDate: dueDate || null,
  });

  this.tasks.push(task);

  return task;
}
```

### `js/ui/task-list.js`

Add due-date metadata:

```javascript
const dueDate = document.createElement("p");
dueDate.className = "task-meta";
dueDate.textContent = `Due: ${task.getDueDateLabel()}`;

if (task.isOverdue()) {
  dueDate.classList.add("task-overdue");
  dueDate.textContent += " · Overdue";
}

textContainer.append(
  title,
  metadata,
  priority,
  dueDate
);
```

### `styles.css`

```css
.task-overdue {
  color: #8c1f2d;
  font-weight: 800;
}
```

## The Verification

1. Add a task with a future due date.
2. Confirm the due date appears.
3. Add a task with yesterday’s date.
4. Confirm `Overdue` appears.
5. Complete the overdue task.
6. Confirm it no longer appears as overdue.
7. Refresh the page.
8. Confirm the due date persists.

[COMPLETED: Exercise 4 — Due dates added]  
[STARTING: Exercise 5 — Add sorting]

---

# Exercise 5: Add Task Sorting

## The Target

Allow users to sort tasks by:

- Newest.
- Oldest.
- Priority.
- Due date.

## The Concept

Sorting should not mutate the service’s internal task array accidentally.

Always sort a copy:

```javascript
const sortedTasks = [...tasks].sort(...);
```

If the original array is sorted directly, other parts of the application may unexpectedly observe a changed order.

---

## The Implementation

### `index.html`

Add:

```html
<div class="sort-control">
  <label for="task-sort">Sort by</label>

  <select id="task-sort">
    <option value="newest">Newest</option>
    <option value="oldest">Oldest</option>
    <option value="priority">Priority</option>
    <option value="due-date">Due date</option>
  </select>
</div>
```

### `js/services/task-service.js`

Add:

```javascript
sort(tasks, sortOrder) {
  const sortedTasks = [...tasks];

  if (sortOrder === "oldest") {
    return sortedTasks.sort((first, second) => {
      return (
        first.createdAt.getTime() -
        second.createdAt.getTime()
      );
    });
  }

  if (sortOrder === "priority") {
    const priorityOrder = {
      high: 1,
      normal: 2,
      low: 3,
    };

    return sortedTasks.sort((first, second) => {
      return (
        priorityOrder[first.priority] -
        priorityOrder[second.priority]
      );
    });
  }

  if (sortOrder === "due-date") {
    return sortedTasks.sort((first, second) => {
      if (!first.dueDate && !second.dueDate) {
        return 0;
      }

      if (!first.dueDate) {
        return 1;
      }

      if (!second.dueDate) {
        return -1;
      }

      return (
        first.dueDate.getTime() -
        second.dueDate.getTime()
      );
    });
  }

  return sortedTasks.sort((first, second) => {
    return (
      second.createdAt.getTime() -
      first.createdAt.getTime()
    );
  });
}
```

### `js/app.js`

In the constructor:

```javascript
this.sortOrder = "newest";
```

Add `taskSort` to the constructor:

```javascript
taskSort,
```

Store it:

```javascript
this.taskSort = taskSort;
```

In `main.js`:

```javascript
taskSort: document.querySelector("#task-sort"),
```

Bind the event:

```javascript
this.taskSort.addEventListener("change", () => {
  this.sortOrder = this.taskSort.value;
  this.render();
});
```

Update `render()`:

```javascript
const searchedTasks = this.taskService.search(
  this.searchQuery
);

const filteredTasks = searchedTasks.filter((task) => {
  if (this.currentFilter === "active") {
    return !task.isCompleted();
  }

  if (this.currentFilter === "completed") {
    return task.isCompleted();
  }

  return true;
});

const visibleTasks = this.taskService.sort(
  filteredTasks,
  this.sortOrder
);
```

## The Verification

1. Create several tasks.
2. Select **Oldest**.
3. Confirm the oldest task appears first.
4. Select **Newest**.
5. Confirm the newest task appears first.
6. Select **Priority**.
7. Confirm high-priority tasks appear first.
8. Select **Due date**.
9. Confirm tasks with due dates appear before tasks without dates.

[COMPLETED: Exercise 5 — Task sorting added]  
[STARTING: Exercise 6 — Add undo for deletion]

---

# Exercise 6: Add Undo for Deletion

## The Target

Add an undo action after deleting a task.

The user should be able to:

1. Delete a task.
2. See a confirmation message.
3. Click **Undo**.
4. Restore the deleted task.

## The Concept

Undo requires temporary state.

After deletion, retain the removed task in memory:

```javascript
this.lastDeletedTask = task;
```

This is not permanent storage. It represents a short-lived recovery action.

---

## The Implementation

### `js/services/task-service.js`

Add:

```javascript
removeAndReturn(taskId) {
  const task = this.findById(taskId);

  if (!task) {
    throw new Error("The selected task could not be found.");
  }

  this.tasks = this.tasks.filter(
    (candidate) => candidate.id !== taskId
  );

  return task;
}

restore(task) {
  if (!(task instanceof Task)) {
    throw new TypeError(
      "restore expects a Task instance."
    );
  }

  if (this.findById(task.id)) {
    throw new Error(
      "A task with this ID already exists."
    );
  }

  this.tasks.push(task);
}
```

### `js/app.js`

In the constructor:

```javascript
this.lastDeletedTask = null;
```

Replace `handleDeleteTask()`:

```javascript
handleDeleteTask(taskId) {
  try {
    const deletedTask =
      this.taskService.removeAndReturn(taskId);

    this.lastDeletedTask = deletedTask;

    this.persistTasks();
    this.render();

    this.status.show(
      `Deleted "${deletedTask.title}". Click Undo to restore it.`,
      "success"
    );
  } catch (error) {
    const normalizedError = normalizeError(error);
    this.status.show(normalizedError.message, "error");
  }
}
```

Add:

```javascript
handleUndoDelete() {
  if (!this.lastDeletedTask) {
    this.status.show(
      "There is no task to restore.",
      "error"
    );
    return;
  }

  try {
    this.taskService.restore(this.lastDeletedTask);
    this.persistTasks();
    this.render();

    this.status.show(
      `Restored "${this.lastDeletedTask.title}".`,
      "success"
    );

    this.lastDeletedTask = null;
  } catch (error) {
    const normalizedError = normalizeError(error);
    this.status.show(normalizedError.message, "error");
  }
}
```

### `index.html`

Add:

```html
<button
  id="undo-delete-button"
  class="task-action"
  type="button"
  disabled
>
  Undo last deletion
</button>
```

### `js/main.js`

Pass the element:

```javascript
undoDeleteButton: document.querySelector(
  "#undo-delete-button"
),
```

### `js/app.js`

Add `undoDeleteButton` to the constructor parameters and store it:

```javascript
this.undoDeleteButton = undoDeleteButton;
```

Bind it:

```javascript
this.undoDeleteButton.addEventListener("click", () => {
  this.handleUndoDelete();
});
```

Enable it after deletion:

```javascript
this.undoDeleteButton.disabled = false;
```

Disable it after restoration:

```javascript
this.undoDeleteButton.disabled = true;
```

## The Verification

1. Create a task.
2. Delete it.
3. Confirm the undo button becomes enabled.
4. Click **Undo last deletion**.
5. Confirm the task returns.
6. Refresh the page.
7. Confirm the restored task persists.
8. Click undo again.
9. Confirm the application explains that there is no deletion to undo.

[COMPLETED: Exercise 6 — Undo deletion added]  
[STARTING: Exercise 7 — Replace the simulated API with fetch]

---

# Exercise 7: Replace the Simulated API with `fetch()`

## The Target

Replace the timer-based API simulation with a real HTTP request.

## The Concept

A real API introduces additional failure modes:

- Network failure.
- HTTP errors.
- Invalid JSON.
- Unexpected data shapes.
- Slow responses.
- Cancellation.

The API module should hide those details from the application coordinator.

---

## The Implementation

### `js/api/task-api.js`

```javascript
"use strict";

import { Task } from "../models/task.js";

function validateApiTask(value) {
  if (
    typeof value !== "object" ||
    value === null ||
    typeof value.title !== "string" ||
    typeof value.completed !== "boolean"
  ) {
    throw new Error(
      "The API returned an invalid task record."
    );
  }

  return new Task({
    id: Number.isInteger(value.id)
      ? value.id
      : Task.createId(),
    title: value.title,
    completed: value.completed,
    priority: value.priority ?? "normal",
    createdAt: value.createdAt ?? new Date(),
  });
}

export async function fetchExampleTasks({
  endpoint = "/api/example-tasks",
  signal,
} = {}) {
  let response;

  try {
    response = await fetch(endpoint, {
      method: "GET",
      signal,
      headers: {
        Accept: "application/json",
      },
    });
  } catch (error) {
    if (error.name === "AbortError") {
      throw error;
    }

    throw new Error(
      "The example task API could not be reached.",
      { cause: error }
    );
  }

  if (!response.ok) {
    throw new Error(
      `The example task API returned HTTP ${response.status}.`
    );
  }

  const contentType =
    response.headers.get("content-type") ?? "";

  if (!contentType.includes("application/json")) {
    throw new Error(
      "The example task API returned a non-JSON response."
    );
  }

  let responseData;

  try {
    responseData = await response.json();
  } catch (error) {
    throw new Error(
      "The example task API returned invalid JSON.",
      { cause: error }
    );
  }

  if (!Array.isArray(responseData)) {
    throw new Error(
      "The example task API must return an array."
    );
  }

  return responseData.map(validateApiTask);
}
```

## Example API Response

The endpoint should return:

```json
[
  {
    "id": 1,
    "title": "Read about ES modules",
    "completed": false,
    "priority": "normal",
    "createdAt": "2026-07-23T12:00:00.000Z"
  }
]
```

## Verification

Use the browser Network panel.

Verify:

- The request is sent.
- The response status is successful.
- The response has JSON content.
- Tasks render after the response.
- HTTP failures produce an error message.
- Invalid JSON produces an error message.
- Invalid task records are rejected.

[COMPLETED: Exercise 7 — Real API request layer added]  
[STARTING: Exercise 8 — Add request cancellation]

---

# Exercise 8: Add Request Cancellation

## The Target

Allow an in-progress task request to be cancelled.

## The Concept

`AbortController` sends a cancellation signal to APIs that support it.

This is useful when:

- The user navigates away.
- A newer request replaces an older one.
- A request exceeds a timeout.
- The user explicitly chooses Cancel.

---

## The Implementation

### `js/app.js`

In the constructor:

```javascript
this.loadController = null;
```

Update `handleLoadExampleTasks()`:

```javascript
async handleLoadExampleTasks() {
  if (this.isLoading) {
    return;
  }

  this.isLoading = true;
  this.loadController = new AbortController();

  this.loadTasksButton.disabled = true;
  this.status.show("Loading example tasks...", "loading");

  try {
    const exampleTasks = await fetchExampleTasks({
      signal: this.loadController.signal,
    });

    this.taskService.replaceAll(exampleTasks);
    this.persistTasks();
    this.render();

    this.status.show(
      `Loaded and saved ${exampleTasks.length} example tasks.`,
      "success"
    );
  } catch (error) {
    if (error.name === "AbortError") {
      this.status.show(
        "Example task loading was cancelled.",
        "error"
      );
      return;
    }

    const normalizedError = normalizeError(error);

    console.error(
      "Could not load example tasks:",
      normalizedError
    );

    this.status.show(
      `Could not load example tasks: ${normalizedError.message}`,
      "error"
    );
  } finally {
    this.isLoading = false;
    this.loadController = null;
    this.loadTasksButton.disabled = false;
  }
}
```

Add a cancellation method:

```javascript
cancelLoadingExampleTasks() {
  this.loadController?.abort();
}
```

Add a cancel button to `index.html`:

```html
<button
  id="cancel-load-button"
  class="task-action"
  type="button"
  disabled
>
  Cancel loading
</button>
```

Store it in the constructor:

```javascript
this.cancelLoadButton = cancelLoadButton;
```

Pass it from `main.js`:

```javascript
cancelLoadButton: document.querySelector(
  "#cancel-load-button"
),
```

Bind it:

```javascript
this.cancelLoadButton.addEventListener("click", () => {
  this.cancelLoadingExampleTasks();
});
```

Update loading state:

```javascript
this.cancelLoadButton.disabled = false;
```

Update cleanup:

```javascript
this.cancelLoadButton.disabled = true;
```

## The Verification

1. Click **Load example tasks**.
2. Click **Cancel loading** before the request completes.
3. Confirm:
   - The request is cancelled.
   - The status explains cancellation.
   - The buttons return to their normal states.
   - Existing tasks are not replaced.

[COMPLETED: Exercise 8 — Request cancellation added]  
[STARTING: Exercise 9 — Add an application theme]

---

# Exercise 9: Add Light and Dark Themes

## The Target

Allow users to switch between light and dark themes.

The selected theme should:

- Apply immediately.
- Persist across refreshes.
- Use `localStorage`.
- Respect the system preference initially.

## The Concept

Theme state is UI preference data, not task data.

It belongs in a separate storage key:

```javascript
async-task-manager.theme.v1
```

Do not mix unrelated preferences into the task array.

---

## The Implementation

### `index.html`

Add a theme button:

```html
<button
  id="theme-toggle-button"
  class="task-action"
  type="button"
>
  Use dark theme
</button>
```

### `js/services/theme-service.js`

Create:

```javascript
"use strict";

const THEME_KEY = "async-task-manager.theme.v1";

export function getStoredTheme() {
  const storedTheme = localStorage.getItem(THEME_KEY);

  if (storedTheme === "light" || storedTheme === "dark") {
    return storedTheme;
  }

  const prefersDark =
    window.matchMedia &&
    window.matchMedia("(prefers-color-scheme: dark)").matches;

  return prefersDark ? "dark" : "light";
}

export function saveTheme(theme) {
  if (theme !== "light" && theme !== "dark") {
    throw new Error("Theme must be light or dark.");
  }

  localStorage.setItem(THEME_KEY, theme);
}

export function applyTheme(theme) {
  document.documentElement.dataset.theme = theme;
}
```

### `styles.css`

Add:

```css
:root[data-theme="dark"] {
  color-scheme: dark;
  color: #edf2fb;
  background: #101522;
}

:root[data-theme="dark"] body {
  background:
    radial-gradient(circle at top left, #202d49 0, transparent 32rem),
    #101522;
}

:root[data-theme="dark"] .panel,
:root[data-theme="dark"] .task-item {
  border-color: #34435d;
  background: #192236;
}

:root[data-theme="dark"] .intro,
:root[data-theme="dark"] .section-heading p,
:root[data-theme="dark"] .task-meta {
  color: #aebbd0;
}

:root[data-theme="dark"] .input-row input,
:root[data-theme="dark"] select {
  color: #edf2fb;
  border-color: #536581;
  background: #101522;
}

:root[data-theme="dark"] .task-action {
  color: #edf2fb;
  background: #34435d;
}

:root[data-theme="dark"] .task-action:hover {
  background: #465a7c;
}
```

### `js/app.js`

Import:

```javascript
import {
  applyTheme,
  getStoredTheme,
  saveTheme,
} from "./services/theme-service.js";
```

In the constructor:

```javascript
this.themeToggleButton = themeToggleButton;
this.currentTheme = "light";
```

In `main.js`:

```javascript
themeToggleButton: document.querySelector(
  "#theme-toggle-button"
),
```

In `start()`:

```javascript
this.currentTheme = getStoredTheme();
applyTheme(this.currentTheme);
this.updateThemeButton();
```

Add:

```javascript
updateThemeButton() {
  this.themeToggleButton.textContent =
    this.currentTheme === "dark"
      ? "Use light theme"
      : "Use dark theme";

  this.themeToggleButton.setAttribute(
    "aria-pressed",
    String(this.currentTheme === "dark")
  );
}
```

Bind the button:

```javascript
this.themeToggleButton.addEventListener("click", () => {
  this.currentTheme =
    this.currentTheme === "dark"
      ? "light"
      : "dark";

  applyTheme(this.currentTheme);
  saveTheme(this.currentTheme);
  this.updateThemeButton();
});
```

## The Verification

1. Click the theme button.
2. Confirm the theme changes immediately.
3. Refresh the page.
4. Confirm the selected theme persists.
5. Open a new tab and test the system preference behavior after removing the saved theme:

```javascript
localStorage.removeItem(
  "async-task-manager.theme.v1"
);
```

[COMPLETED: Exercise 9 — Theme preference added]  
[STARTING: Exercise 10 — Add task statistics]

---

# Exercise 10: Add Task Statistics

## The Target

Display:

- Total tasks.
- Completed tasks.
- Active tasks.
- High-priority tasks.
- Overdue tasks.

## The Concept

Statistics are derived data. They should be calculated from the task collection rather than stored independently.

If both of these are stored:

```javascript
tasks
completedCount
```

they can become inconsistent.

Prefer:

```javascript
const completedCount = tasks.filter(
  (task) => task.isCompleted()
).length;
```

---

## The Implementation

### `js/services/task-service.js`

Add:

```javascript
getStatistics(now = new Date()) {
  const allTasks = this.getAll();

  return {
    total: allTasks.length,
    completed: allTasks.filter(
      (task) => task.isCompleted()
    ).length,
    active: allTasks.filter(
      (task) => !task.isCompleted()
    ).length,
    highPriority: allTasks.filter(
      (task) => task.priority === "high"
    ).length,
    overdue: allTasks.filter(
      (task) => task.isOverdue(now)
    ).length,
  };
}
```

### `index.html`

Add:

```html
<section
  class="panel"
  aria-labelledby="statistics-heading"
>
  <h2 id="statistics-heading">Statistics</h2>

  <dl id="task-statistics" class="statistics">
    <div>
      <dt>Total</dt>
      <dd id="total-task-statistic">0</dd>
    </div>

    <div>
      <dt>Active</dt>
      <dd id="active-task-statistic">0</dd>
    </div>

    <div>
      <dt>Completed</dt>
      <dd id="completed-task-statistic">0</dd>
    </div>

    <div>
      <dt>High priority</dt>
      <dd id="high-priority-task-statistic">0</dd>
    </div>

    <div>
      <dt>Overdue</dt>
      <dd id="overdue-task-statistic">0</dd>
    </div>
  </dl>
</section>
```

### `js/app.js`

Add elements to the constructor:

```javascript
statistics: {
  total: document.querySelector(
    "#total-task-statistic"
  ),
  active: document.querySelector(
    "#active-task-statistic"
  ),
  completed: document.querySelector(
    "#completed-task-statistic"
  ),
  highPriority: document.querySelector(
    "#high-priority-task-statistic"
  ),
  overdue: document.querySelector(
    "#overdue-task-statistic"
  ),
},
```

Store:

```javascript
this.statistics = statistics;
```

Add:

```javascript
renderStatistics() {
  const values = this.taskService.getStatistics();

  this.statistics.total.textContent = values.total;
  this.statistics.active.textContent = values.active;
  this.statistics.completed.textContent =
    values.completed;
  this.statistics.highPriority.textContent =
    values.highPriority;
  this.statistics.overdue.textContent =
    values.overdue;
}
```

Call it inside `render()`:

```javascript
this.renderStatistics();
```

### `styles.css`

```css
.statistics {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 0.75rem;
  margin: 0;
}

.statistics div {
  border-radius: 0.6rem;
  padding: 0.8rem;
  background: #eef2f7;
  text-align: center;
}

.statistics dt {
  color: #66728a;
  font-size: 0.8rem;
}

.statistics dd {
  margin: 0.2rem 0 0;
  font-size: 1.5rem;
  font-weight: 800;
}

@media (max-width: 600px) {
  .statistics {
    grid-template-columns: repeat(2, 1fr);
  }
}
```

## The Verification

1. Create active and completed tasks.
2. Add high-priority tasks.
3. Add an overdue task.
4. Confirm statistics update after:
   - Adding.
   - Completing.
   - Reopening.
   - Deleting.
   - Loading example tasks.
   - Clearing tasks.

[COMPLETED: Exercise 10 — Task statistics added]  
[STARTING: Exercise 11 — Add import and export]

---

# Exercise 11: Add Task Import and Export

## The Target

Allow users to:

- Download their tasks as a JSON file.
- Import a previously exported JSON file.
- Validate imported data.
- Replace or merge existing tasks.

## The Concept

Exporting creates a portable representation:

```json
{
  "version": 1,
  "exportedAt": "...",
  "tasks": []
}
```

Importing is an untrusted-data boundary. Every imported task must be passed through `Task.fromJSON()`.

---

## The Implementation

### `js/services/export-service.js`

Create:

```javascript
"use strict";

import { Task } from "../models/task.js";

export function createTaskExport(tasks) {
  if (!Array.isArray(tasks)) {
    throw new TypeError(
      "createTaskExport expects an array."
    );
  }

  return {
    version: 1,
    exportedAt: new Date().toISOString(),
    tasks: tasks.map((task) => task.toJSON()),
  };
}

export function parseTaskExport(rawText) {
  let parsedValue;

  try {
    parsedValue = JSON.parse(rawText);
  } catch (error) {
    throw new Error(
      "The selected file is not valid JSON.",
      { cause: error }
    );
  }

  if (
    typeof parsedValue !== "object" ||
    parsedValue === null ||
    parsedValue.version !== 1 ||
    !Array.isArray(parsedValue.tasks)
  ) {
    throw new Error(
      "The selected file is not a valid task export."
    );
  }

  return parsedValue.tasks.map((value) => {
    return Task.fromJSON(value);
  });
}

export function downloadTaskExport(tasks) {
  const exportValue = createTaskExport(tasks);

  const blob = new Blob(
    [JSON.stringify(exportValue, null, 2)],
    {
      type: "application/json",
    }
  );

  const objectUrl = URL.createObjectURL(blob);
  const link = document.createElement("a");

  link.href = objectUrl;
  link.download = "async-task-manager-export.json";
  link.click();

  URL.revokeObjectURL(objectUrl);
}
```

### `index.html`

Add:

```html
<section class="panel" aria-labelledby="data-heading">
  <h2 id="data-heading">Task data</h2>

  <div class="data-actions">
    <button
      id="export-tasks-button"
      type="button"
    >
      Export tasks
    </button>

    <label for="import-tasks-input">
      Import tasks
    </label>

    <input
      id="import-tasks-input"
      type="file"
      accept="application/json,.json"
    />
  </div>
</section>
```

### `js/app.js`

Import:

```javascript
import {
  downloadTaskExport,
  parseTaskExport,
} from "./services/export-service.js";
```

Add elements to the constructor:

```javascript
this.exportTasksButton = exportTasksButton;
this.importTasksInput = importTasksInput;
```

Pass them from `main.js`:

```javascript
exportTasksButton: document.querySelector(
  "#export-tasks-button"
),

importTasksInput: document.querySelector(
  "#import-tasks-input"
),
```

Bind events:

```javascript
this.exportTasksButton.addEventListener("click", () => {
  try {
    downloadTaskExport(this.taskService.getAll());
    this.status.show(
      "Tasks exported successfully.",
      "success"
    );
  } catch (error) {
    const normalizedError = normalizeError(error);
    this.status.show(normalizedError.message, "error");
  }
});

this.importTasksInput.addEventListener(
  "change",
  () => {
    this.handleImportTasks();
  }
);
```

Add the handler:

```javascript
async handleImportTasks() {
  const file = this.importTasksInput.files?.[0];

  if (!file) {
    return;
  }

  try {
    const rawText = await file.text();
    const importedTasks = parseTaskExport(rawText);

    this.taskService.replaceAll(importedTasks);
    this.persistTasks();
    this.render();

    this.status.show(
      `Imported ${importedTasks.length} tasks.`,
      "success"
    );
  } catch (error) {
    const normalizedError = normalizeError(error);
    this.status.show(normalizedError.message, "error");
  } finally {
    this.importTasksInput.value = "";
  }
}
```

## The Verification

1. Create several tasks.
2. Click **Export tasks**.
3. Confirm a JSON file downloads.
4. Clear the application.
5. Select the exported file.
6. Confirm tasks are restored.
7. Create a malformed JSON file.
8. Import it.
9. Confirm the application displays an error.
10. Verify that invalid imports do not silently replace valid data.

[COMPLETED: Exercise 11 — Import and export added]  
[STARTING: Exercise 12 — Add automated test coverage for extensions]

---

# Exercise 12: Test the Extensions

## The Target

Add tests for priorities, due dates, search, sorting, and statistics.

## The Implementation

### `js/extensions.test.js`

```javascript
import { Task } from "./models/task.js";
import { TaskService } from "./services/task-service.js";
import {
  assert,
  assertEqual,
  assertThrows,
} from "./test-utils/assert.js";

function testPriorities() {
  const highPriorityTask = new Task({
    title: "Important task",
    priority: "high",
  });

  assertEqual(
    highPriorityTask.priority,
    "high",
    "High priority is stored"
  );

  assertEqual(
    highPriorityTask.getPriorityLabel(),
    "High",
    "Priority label is formatted"
  );

  assertThrows(
    () =>
      new Task({
        title: "Invalid priority",
        priority: "urgent",
      }),
    "Invalid priority is rejected"
  );
}

function testDueDates() {
  const dueDate = new Date("2030-01-01T00:00:00.000Z");

  const task = new Task({
    title: "Future task",
    dueDate,
  });

  assert(
    task.dueDate instanceof Date,
    "Due date is stored as a Date"
  );

  assert(
    !task.isOverdue(
      new Date("2029-12-01T00:00:00.000Z")
    ),
    "Future task is not overdue"
  );

  assert(
    task.isOverdue(
      new Date("2030-02-01T00:00:00.000Z")
    ),
    "Past task is overdue"
  );
}

function testSearch() {
  const service = new TaskService();

  service.add({ title: "Study Promises" });
  service.add({ title: "Study modules" });
  service.add({ title: "Practice classes" });

  const results = service.search("study");

  assertEqual(
    results.length,
    2,
    "Search is case-insensitive"
  );
}

function testStatistics() {
  const service = new TaskService();

  service.add({
    title: "Active high task",
    priority: "high",
  });

  const completedTask = service.add({
    title: "Completed task",
  });

  service.toggle(completedTask.id);

  const values = service.getStatistics();

  assertEqual(
    values.total,
    2,
    "Statistics count all tasks"
  );

  assertEqual(
    values.active,
    1,
    "Statistics count active tasks"
  );

  assertEqual(
    values.completed,
    1,
    "Statistics count completed tasks"
  );

  assertEqual(
    values.highPriority,
    1,
    "Statistics count high-priority tasks"
  );
}

function runTests() {
  testPriorities();
  testDueDates();
  testSearch();
  testStatistics();

  console.log("Extension tests passed.");
}

runTests();
```

## The Verification

Load the test module temporarily.

Expected output:

```text
Extension tests passed.
```

[COMPLETED: Exercise 12 — Extension tests added]  
[STARTING: Exercise 13 — Add an offline-aware experience]

---

# Exercise 13: Add Offline Awareness

## The Target

Inform the user when the browser loses or regains network connectivity.

## The Concept

The application can listen for browser connectivity events:

```javascript
window.addEventListener("offline", ...)
window.addEventListener("online", ...)
```

This does not prove that a specific API is reachable, but it gives the user useful context.

Since tasks are stored locally, many operations can continue offline.

---

## The Implementation

### `js/app.js`

Add to `bindEvents()`:

```javascript
window.addEventListener("offline", () => {
  this.status.show(
    "You are offline. Saved task features remain available.",
    "error"
  );
});

window.addEventListener("online", () => {
  this.status.show(
    "You are back online.",
    "success"
  );
});
```

### `index.html`

Add a network status indicator:

```html
<p
  id="network-status"
  class="network-status"
  role="status"
  aria-live="polite"
></p>
```

### `js/app.js`

Store the element:

```javascript
this.networkStatus = networkStatus;
```

Pass it from `main.js`:

```javascript
networkStatus: document.querySelector(
  "#network-status"
),
```

Add:

```javascript
updateNetworkStatus() {
  if (navigator.onLine) {
    this.networkStatus.textContent = "Online";
    this.networkStatus.className =
      "network-status network-online";
  } else {
    this.networkStatus.textContent =
      "Offline — local features available";
    this.networkStatus.className =
      "network-status network-offline";
  }
}
```

Call it in `start()`:

```javascript
this.updateNetworkStatus();
```

Update it in the event handlers:

```javascript
window.addEventListener("offline", () => {
  this.updateNetworkStatus();

  this.status.show(
    "You are offline. Saved task features remain available.",
    "error"
  );
});

window.addEventListener("online", () => {
  this.updateNetworkStatus();

  this.status.show(
    "You are back online.",
    "success"
  );
});
```

### `styles.css`

```css
.network-status {
  margin: 0 0 1rem;
  font-size: 0.9rem;
  font-weight: 700;
}

.network-online {
  color: #28734f;
}

.network-offline {
  color: #8c1f2d;
}
```

## The Verification

In browser Developer Tools:

1. Open the Network panel.
2. Enable offline mode.
3. Verify the offline message appears.
4. Add and complete local tasks.
5. Re-enable the network.
6. Verify the online message appears.

[COMPLETED: Exercise 13 — Offline status added]  
[STARTING: Exercise 14 — Build a service worker cache]

---

# Exercise 14: Add a Service Worker

## The Target

Cache the application shell so it can load offline.

## The Concept

A service worker is a browser-controlled background script that can intercept requests.

It can:

- Cache application files.
- Serve cached files offline.
- Improve repeat-load performance.
- Support progressive web application behavior.

A service worker requires a secure context:

- HTTPS in production.
- `localhost` is allowed for development.

---

## The Implementation

### `sw.js`

Create this file in the project root:

```javascript
"use strict";

const CACHE_NAME = "async-task-manager-v1";

const APPLICATION_SHELL = [
  "./",
  "./index.html",
  "./styles.css",
  "./js/main.js",
  "./js/app.js",
  "./js/api/task-api.js",
  "./js/models/task.js",
  "./js/services/storage-service.js",
  "./js/services/task-service.js",
  "./js/ui/status-message.js",
  "./js/ui/task-form.js",
  "./js/ui/task-list.js",
  "./js/utils/errors.js",
  "./js/utils/validation.js",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(APPLICATION_SHELL);
    })
  );

  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((cacheName) => {
            return (
              cacheName !== CACHE_NAME &&
              cacheName.startsWith(
                "async-task-manager-"
              )
            );
          })
          .map((cacheName) => {
            return caches.delete(cacheName);
          })
      );
    })
  );

  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") {
    return;
  }

  event.respondWith(
    caches.match(event.request).then((cachedResponse) => {
      if (cachedResponse) {
        return cachedResponse;
      }

      return fetch(event.request);
    })
  );
});
```

### `js/main.js`

Register the service worker:

```javascript
import { App } from "./app.js";

const app = new App({
  taskForm: document.querySelector("#task-form"),
  taskList: document.querySelector("#task-list"),
  taskCount: document.querySelector("#task-count"),
  statusMessage: document.querySelector("#status-message"),
  loadTasksButton: document.querySelector(
    "#load-tasks-button"
  ),
  clearTasksButton: document.querySelector(
    "#clear-tasks-button"
  ),
  taskFilter: document.querySelector("#task-filter"),
});

app.start();

if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("./sw.js")
      .then((registration) => {
        console.log(
          "Service worker registered:",
          registration.scope
        );
      })
      .catch((error) => {
        console.error(
          "Service worker registration failed:",
          error
        );
      });
  });
}
```

## The Verification

1. Open the application at `http://localhost:8000`.
2. Open Developer Tools.
3. Inspect:
   - Application → Service Workers.
   - Application → Cache Storage.
4. Confirm the service worker is registered.
5. Reload once while online.
6. Enable offline mode.
7. Reload the page.
8. Confirm the application shell still loads.

## Important Caution

When files change, update:

```javascript
const CACHE_NAME = "async-task-manager-v2";
```

Otherwise, the browser may continue serving old cached files.

[COMPLETED: Exercise 14 — Offline application shell added]  
[STARTING: Exercise 15 — Convert the project to TypeScript]

---

# Exercise 15: Convert the Project to TypeScript

## The Target

Convert the task model and service layer to TypeScript.

## The Concept

TypeScript adds static type checking to JavaScript.

JavaScript discovers many mistakes at runtime:

```javascript
task.completed = "yes";
```

TypeScript can identify the mismatch before the application runs.

TypeScript does not remove the need for runtime validation. Data from users, APIs, and storage still requires runtime checks.

---

## The Implementation

### `src/models/task.ts`

```typescript
export type TaskPriority =
  | "low"
  | "normal"
  | "high";

export interface SerializedTask {
  id: number;
  title: string;
  completed: boolean;
  priority: TaskPriority;
  createdAt: string;
}

export interface TaskInput {
  id?: number;
  title: string;
  completed?: boolean;
  priority?: TaskPriority;
  createdAt?: Date | string;
}

export class Task {
  public readonly id: number;
  public title: string;
  public completed: boolean;
  public priority: TaskPriority;
  public readonly createdAt: Date;

  public constructor({
    id = Task.createId(),
    title,
    completed = false,
    priority = "normal",
    createdAt = new Date(),
  }: TaskInput) {
    if (!Number.isInteger(id) || id < 0) {
      throw new TypeError(
        "Task id must be a non-negative integer."
      );
    }

    const normalizedTitle = title.trim();

    if (normalizedTitle.length === 0) {
      throw new Error("Task title cannot be empty.");
    }

    if (normalizedTitle.length > 120) {
      throw new Error(
        "Task title cannot exceed 120 characters."
      );
    }

    const normalizedCreatedAt =
      createdAt instanceof Date
        ? createdAt
        : new Date(createdAt);

    if (Number.isNaN(normalizedCreatedAt.getTime())) {
      throw new TypeError(
        "Task createdAt must be a valid date."
      );
    }

    this.id = id;
    this.title = normalizedTitle;
    this.completed = completed;
    this.priority = priority;
    this.createdAt = normalizedCreatedAt;
  }

  public static createId(): number {
    return Date.now() + Math.floor(Math.random() * 100000);
  }

  public static fromJSON(value: SerializedTask): Task {
    return new Task({
      id: value.id,
      title: value.title,
      completed: value.completed,
      priority: value.priority,
      createdAt: value.createdAt,
    });
  }

  public toggleCompletion(): void {
    this.completed = !this.completed;
  }

  public isCompleted(): boolean {
    return this.completed;
  }

  public toJSON(): SerializedTask {
    return {
      id: this.id,
      title: this.title,
      completed: this.completed,
      priority: this.priority,
      createdAt: this.createdAt.toISOString(),
    };
  }
}
```

### `tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ES2022",
    "moduleResolution": "Bundler",
    "strict": true,
    "noImplicitAny": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"]
}
```

## The Verification

Install TypeScript in a separate project or use an existing TypeScript environment.

Run:

```bash
npx tsc --noEmit
```

The compiler should report no type errors.

Introduce a deliberate error:

```typescript
const invalidPriority: TaskPriority = "urgent";
```

Run the compiler again.

It should reject the value.

[COMPLETED: Exercise 15 — TypeScript migration introduced]  
[STARTING: Exercise 16 — Build a capstone version]

---

# Exercise 16: Capstone Challenge — Build a Production-Style Task Manager

## The Target

Combine the previous exercises into a more complete application.

The capstone version should include:

- Modular architecture.
- Task classes.
- Priorities.
- Due dates.
- Search.
- Sorting.
- Filtering.
- Editing.
- Deletion.
- Undo.
- Statistics.
- Import/export.
- Local persistence.
- API loading.
- Request cancellation.
- Theme switching.
- Accessibility support.
- Error handling.
- Automated tests.

## The Concept

This exercise requires architectural judgment.

Do not put every feature into `app.js`. Keep responsibilities separated:

```text
models/
  task.js

services/
  task-service.js
  storage-service.js
  export-service.js
  theme-service.js

api/
  task-api.js

ui/
  task-form.js
  task-list.js
  status-message.js
  statistics.js

utils/
  errors.js
  validation.js
```

The application coordinator should connect modules without implementing every detail itself.

## Suggested Acceptance Criteria

### Task Creation

- [ ] User can create a task.
- [ ] Empty titles are rejected.
- [ ] Titles over 120 characters are rejected.
- [ ] Priority is selectable.
- [ ] Due date is optional.

### Task Management

- [ ] Tasks can be completed.
- [ ] Tasks can be reopened.
- [ ] Tasks can be edited.
- [ ] Tasks can be deleted.
- [ ] Deletion can be undone.

### Task Discovery

- [ ] Users can search by title.
- [ ] Users can filter by status.
- [ ] Users can sort by date, priority, and due date.

### Persistence

- [ ] Tasks persist across reloads.
- [ ] Preferences persist appropriately.
- [ ] Malformed storage does not crash the application.
- [ ] Storage errors are communicated.

### Asynchrony

- [ ] Example tasks load asynchronously.
- [ ] The user sees a loading state.
- [ ] Duplicate loads are prevented.
- [ ] Requests can be cancelled.
- [ ] Failed requests are handled.
- [ ] Cleanup occurs after every request.

### Security

- [ ] User text uses `textContent`.
- [ ] Imported JSON is validated.
- [ ] No secrets are stored.
- [ ] API responses are validated.
- [ ] Dynamic URLs are encoded.
- [ ] Production CSP is planned.

### Accessibility

- [ ] Controls are keyboard accessible.
- [ ] Focus is visible.
- [ ] Inputs have labels.
- [ ] Errors are announced.
- [ ] Status updates are announced.
- [ ] Color is not the only status signal.
- [ ] The layout works at narrow widths.

## Verification

Perform a complete regression test after integrating all features.

Use the checklist:

```text
Startup
Add
Validate
Complete
Reopen
Edit
Delete
Undo
Search
Filter
Sort
Persist
Load asynchronously
Cancel loading
Handle failure
Export
Import
Switch theme
Use keyboard
Test malformed storage
Test malformed import
Test mobile layout
```

[COMPLETED: Exercise 16 — Capstone requirements defined]  
[STARTING: Appendix I Reference — Extension design principles]

---

# Extension Design Principles

## Keep the Model Authoritative

The `Task` class should enforce task invariants.

Do not rely only on the form:

```javascript
new Task({
  title: "",
});
```

must fail even if the task did not come from the form.

---

## Keep Services Independent of the DOM

This makes services easier to test:

```javascript
taskService.add({
  title: "Test task",
});
```

The service should not require:

```javascript
document.querySelector(...)
```

---

## Treat External Data as Untrusted

Validate:

- API responses.
- Imported files.
- Browser storage.
- URL parameters.
- User input.

---

## Derive Data Instead of Duplicating It

Prefer:

```javascript
const completed =
  tasks.filter((task) => task.isCompleted()).length;
```

over maintaining separate mutable counters that can become stale.

---

## Make Asynchronous Cleanup Guaranteed

Use:

```javascript
try {
  await operation();
} catch (error) {
  handleError(error);
} finally {
  restoreInterface();
}
```

Do not duplicate cleanup across only the success and failure branches.

---

## Preserve Public Interfaces

If the UI depends on:

```javascript
taskService.add(title);
```

avoid changing it unexpectedly throughout the application.

If a feature requires a new shape, update all callers deliberately and test them.

---

## Version Persistent Data

Use:

```text
async-task-manager.tasks.v1
```

rather than:

```text
tasks
```

Versioning creates a path for future migrations.

---

# Extension Difficulty Map

## Beginner Extensions

- Add a task count.
- Add a completed-task filter.
- Add a clear button.
- Add a theme toggle.
- Add an empty state.
- Add task priorities.

## Intermediate Extensions

- Add editing.
- Add search.
- Add sorting.
- Add due dates.
- Add statistics.
- Add undo.
- Add import/export.

## Advanced Extensions

- Add a real API.
- Add request cancellation.
- Add retries.
- Add offline support.
- Add service-worker caching.
- Add cross-tab synchronization.
- Add IndexedDB.
- Convert to TypeScript.
- Add authentication.
- Add a backend.
- Add automated browser tests.

---

# Final Extension Checklist

Before considering an extension complete:

- [ ] The feature has a clear responsibility.
- [ ] The data model validates new fields.
- [ ] Storage serialization is updated.
- [ ] Storage restoration is updated.
- [ ] UI controls are accessible.
- [ ] User content is rendered safely.
- [ ] Errors are handled.
- [ ] Loading state is handled if asynchronous.
- [ ] Existing features still work.
- [ ] The feature has a verification procedure.
- [ ] At least one automated test covers the core behavior.
- [ ] The browser console is free of unexpected errors.
