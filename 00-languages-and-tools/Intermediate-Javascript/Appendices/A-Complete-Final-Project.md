# Appendix A: Complete Final Project

This appendix contains the complete final version of the **Async Task Manager**.

Every file is included in full so you can:

- Rebuild the project from scratch.
- Compare your implementation with the finished version.
- Copy the project into a new directory.
- Use it as a reference while extending the application.

---

# Final Project Features

The completed application supports:

- Adding tasks.
- Validating task titles.
- Marking tasks as complete or incomplete.
- Deleting tasks.
- Filtering tasks.
- Loading example tasks asynchronously.
- Displaying loading, success, and error states.
- Persisting tasks in `localStorage`.
- Persisting the selected filter in `sessionStorage`.
- Reconstructing `Task` class instances from JSON.
- Handling malformed storage data.
- Organizing behavior into ES modules.

---

# Final Directory Structure

```text
async-task-manager/
├── index.html
├── styles.css
└── js/
    ├── main.js
    ├── app.js
    ├── api/
    │   └── task-api.js
    ├── models/
    │   └── task.js
    ├── services/
    │   ├── storage-service.js
    │   └── task-service.js
    ├── ui/
    │   ├── status-message.js
    │   ├── task-form.js
    │   └── task-list.js
    └── utils/
        ├── errors.js
        └── validation.js
```

---

# Project Setup

Create the project directories.

## macOS or Linux

```bash
mkdir -p async-task-manager/js/api
mkdir -p async-task-manager/js/models
mkdir -p async-task-manager/js/services
mkdir -p async-task-manager/js/ui
mkdir -p async-task-manager/js/utils
cd async-task-manager
```

## Windows PowerShell

```powershell
New-Item -ItemType Directory -Force -Path async-task-manager
Set-Location async-task-manager

New-Item -ItemType Directory -Force -Path js/api
New-Item -ItemType Directory -Force -Path js/models
New-Item -ItemType Directory -Force -Path js/services
New-Item -ItemType Directory -Force -Path js/ui
New-Item -ItemType Directory -Force -Path js/utils
```

Create these files:

```text
index.html
styles.css
js/main.js
js/app.js
js/api/task-api.js
js/models/task.js
js/services/storage-service.js
js/services/task-service.js
js/ui/status-message.js
js/ui/task-form.js
js/ui/task-list.js
js/utils/errors.js
js/utils/validation.js
```

---

# File 1: `index.html`

This file defines the page structure.

It contains:

- The task form.
- The asynchronous loading button.
- The task filter.
- The status message area.
- The task list.
- The clear-storage button.

## `index.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <meta
      name="description"
      content="A modular asynchronous JavaScript task manager"
    />
    <title>Async Task Manager</title>
    <link rel="stylesheet" href="./styles.css" />
  </head>

  <body>
    <main class="app-shell">
      <header class="app-header">
        <p class="eyebrow">Intermediate JavaScript</p>

        <h1>Async Task Manager</h1>

        <p class="intro">
          A modular task application using asynchronous JavaScript,
          classes, browser storage, and ES modules.
        </p>
      </header>

      <section class="panel" aria-labelledby="add-task-heading">
        <h2 id="add-task-heading">Add a task</h2>

        <form id="task-form">
          <div class="form-row">
            <label for="task-title">Task title</label>

            <div class="input-row">
              <input
                id="task-title"
                name="taskTitle"
                type="text"
                maxlength="120"
                autocomplete="off"
                placeholder="For example: Study browser storage"
                required
              />

              <button type="submit">Add task</button>
            </div>
          </div>
        </form>
      </section>

      <section class="panel" aria-labelledby="async-heading">
        <div class="section-heading">
          <div>
            <h2 id="async-heading">Asynchronous loading</h2>

            <p>
              Load example tasks through a Promise-based API.
            </p>
          </div>

          <button id="load-tasks-button" type="button">
            Load example tasks
          </button>
        </div>
      </section>

      <section class="panel" aria-labelledby="filter-heading">
        <div class="section-heading">
          <div>
            <h2 id="filter-heading">Task filter</h2>

            <p>
              The selected filter is remembered for this browser session.
            </p>
          </div>

          <label class="filter-control">
            <span class="visually-hidden">Filter tasks</span>

            <select id="task-filter">
              <option value="all">All tasks</option>
              <option value="active">Active tasks</option>
              <option value="completed">Completed tasks</option>
            </select>
          </label>
        </div>
      </section>

      <section class="panel" aria-labelledby="status-heading">
        <h2 id="status-heading">Application status</h2>

        <p
          id="status-message"
          class="status-message"
          role="status"
          aria-live="polite"
        >
          Starting application...
        </p>
      </section>

      <section class="panel" aria-labelledby="tasks-heading">
        <div class="section-heading">
          <div>
            <h2 id="tasks-heading">Tasks</h2>

            <p id="task-count">0 tasks</p>
          </div>

          <button
            id="clear-tasks-button"
            class="task-action"
            type="button"
          >
            Clear saved tasks
          </button>
        </div>

        <ul id="task-list" class="task-list"></ul>
      </section>
    </main>

    <!--
      type="module" enables import/export syntax and causes the browser
      to load the dependency graph beginning at js/main.js.
    -->
    <script type="module" src="./js/main.js"></script>
  </body>
</html>
```

---

# File 2: `styles.css`

This file controls the presentation of the application.

The JavaScript assigns state classes such as:

```text
status-loading
status-success
status-error
task-completed
```

The stylesheet determines how those states appear.

## `styles.css`

```css
:root {
  color-scheme: light;
  font-family:
    Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont,
    "Segoe UI", sans-serif;
  color: #172033;
  background: #eef2f7;
  line-height: 1.5;
  font-weight: 400;
}

* {
  box-sizing: border-box;
}

body {
  min-width: 320px;
  min-height: 100vh;
  margin: 0;
  background:
    radial-gradient(circle at top left, #dcecff 0, transparent 32rem),
    #eef2f7;
}

button,
input,
select {
  font: inherit;
}

button {
  border: 0;
  border-radius: 0.55rem;
  padding: 0.7rem 1rem;
  color: #ffffff;
  background: #2457d6;
  cursor: pointer;
  transition:
    background 150ms ease,
    transform 150ms ease,
    opacity 150ms ease;
}

button:hover {
  background: #1c43a8;
}

button:active {
  transform: translateY(1px);
}

button:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

.app-shell {
  width: min(100% - 2rem, 52rem);
  margin: 0 auto;
  padding: 3rem 0 5rem;
}

.app-header {
  margin-bottom: 2rem;
}

.eyebrow {
  margin: 0 0 0.35rem;
  color: #2457d6;
  font-size: 0.8rem;
  font-weight: 800;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

h1,
h2,
p {
  margin-top: 0;
}

h1 {
  margin-bottom: 0.7rem;
  font-size: clamp(2rem, 5vw, 3.5rem);
  line-height: 1.05;
}

h2 {
  margin-bottom: 0.5rem;
  font-size: 1.25rem;
}

.intro {
  max-width: 42rem;
  margin-bottom: 0;
  color: #536078;
  font-size: 1.05rem;
}

.panel {
  margin-bottom: 1rem;
  padding: 1.25rem;
  border: 1px solid #dce2eb;
  border-radius: 0.9rem;
  background: rgba(255, 255, 255, 0.92);
  box-shadow: 0 0.8rem 2rem rgba(42, 55, 82, 0.07);
}

.form-row {
  display: grid;
  gap: 0.5rem;
}

.form-row label {
  color: #536078;
  font-size: 0.9rem;
  font-weight: 700;
}

.input-row {
  display: flex;
  gap: 0.7rem;
}

.input-row input,
select {
  min-width: 0;
  border: 1px solid #bcc7d8;
  border-radius: 0.55rem;
  padding: 0.7rem 0.8rem;
  color: #172033;
  background: #ffffff;
}

.input-row input {
  flex: 1;
}

.input-row input:focus,
select:focus {
  outline: 3px solid rgba(36, 87, 214, 0.2);
  border-color: #2457d6;
}

.section-heading {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1rem;
}

.section-heading p {
  margin-bottom: 0;
  color: #66728a;
}

.status-message {
  margin-bottom: 0;
  border-radius: 0.55rem;
  padding: 0.75rem 0.9rem;
  color: #25406b;
  background: #eaf1ff;
}

.status-loading {
  color: #704b00;
  background: #fff5d8;
}

.status-success {
  color: #145c39;
  background: #e4f7ec;
}

.status-error {
  color: #8c1f2d;
  background: #ffebee;
}

.task-list {
  display: grid;
  gap: 0.7rem;
  margin: 0;
  padding: 0;
  list-style: none;
}

.task-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  border: 1px solid #dce2eb;
  border-radius: 0.7rem;
  padding: 0.85rem 1rem;
  background: #ffffff;
}

.task-title {
  margin: 0;
  overflow-wrap: anywhere;
}

.task-meta {
  margin: 0.2rem 0 0;
  color: #66728a;
  font-size: 0.85rem;
}

.task-completed .task-title {
  color: #66728a;
  text-decoration: line-through;
}

.task-completed {
  background: #f6f8fb;
}

.task-actions {
  display: flex;
  flex: 0 0 auto;
  gap: 0.5rem;
}

.task-action {
  padding: 0.5rem 0.7rem;
  color: #172033;
  background: #e5ebf5;
  font-size: 0.85rem;
}

.task-action:hover {
  background: #d4deef;
}

.task-delete-action {
  color: #8c1f2d;
  background: #ffebee;
}

.task-delete-action:hover {
  background: #ffd8de;
}

.empty-state {
  margin: 0;
  color: #66728a;
  text-align: center;
}

.visually-hidden {
  position: absolute;
  width: 1px;
  height: 1px;
  overflow: hidden;
  clip: rect(0 0 0 0);
  clip-path: inset(50%);
  white-space: nowrap;
}

@media (max-width: 600px) {
  .app-shell {
    width: min(100% - 1rem, 52rem);
    padding-top: 1.5rem;
  }

  .input-row,
  .section-heading {
    align-items: stretch;
    flex-direction: column;
  }

  .task-item {
    align-items: flex-start;
    flex-direction: column;
  }

  .task-actions {
    width: 100%;
  }

  .task-actions button {
    flex: 1;
  }
}
```

---

# File 3: `js/models/task.js`

This module defines the `Task` class.

It is responsible for:

- Validating task data.
- Managing completion state.
- Generating identifiers.
- Serializing tasks.
- Restoring tasks from JSON-compatible objects.

## `js/models/task.js`

```javascript
"use strict";

export class Task {
  constructor({
    id = Task.createId(),
    title,
    completed = false,
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

    const normalizedCreatedAt =
      createdAt instanceof Date ? createdAt : new Date(createdAt);

    if (Number.isNaN(normalizedCreatedAt.getTime())) {
      throw new TypeError("Task createdAt must be a valid date.");
    }

    this.id = id;
    this.title = normalizedTitle;
    this.completed = completed;
    this.createdAt = normalizedCreatedAt;
  }

  static createId() {
    /*
     * This is appropriate for this browser-only demonstration.
     *
     * In a server-backed application, identifiers should normally
     * be generated by the server or with crypto.randomUUID().
     */
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

  getStatusLabel() {
    return this.completed ? "Completed" : "Not completed";
  }

  toJSON() {
    /*
     * JSON does not preserve class prototypes or Date instances.
     * Convert the date to an ISO string before persistence.
     */
    return {
      id: this.id,
      title: this.title,
      completed: this.completed,
      createdAt: this.createdAt.toISOString(),
    };
  }
}
```

---

# File 4: `js/utils/errors.js`

This module defines application-specific error classes and a helper for converting unknown thrown values into normal `Error` objects.

## `js/utils/errors.js`

```javascript
"use strict";

export class StorageError extends Error {
  constructor(message, options = {}) {
    super(message, options);
    this.name = "StorageError";
  }
}

export class ValidationError extends Error {
  constructor(message, options = {}) {
    super(message, options);
    this.name = "ValidationError";
  }
}

export function normalizeError(value) {
  if (value instanceof Error) {
    return value;
  }

  if (typeof value === "string" && value.trim().length > 0) {
    return new Error(value);
  }

  return new Error("An unknown error occurred.");
}
```

---

# File 5: `js/utils/validation.js`

This module validates reusable input rules.

## `js/utils/validation.js`

```javascript
"use strict";

import { ValidationError } from "./errors.js";

export function validateTaskTitle(title) {
  if (typeof title !== "string") {
    throw new ValidationError("Task title must be text.");
  }

  const normalizedTitle = title.trim();

  if (normalizedTitle.length === 0) {
    throw new ValidationError("Task title cannot be empty.");
  }

  if (normalizedTitle.length > 120) {
    throw new ValidationError(
      "Task title cannot contain more than 120 characters."
    );
  }

  return normalizedTitle;
}

export function isValidFilter(value) {
  return value === "all" || value === "active" || value === "completed";
}
```

---

# File 6: `js/services/storage-service.js`

This module handles browser storage.

It uses:

- `localStorage` for tasks.
- `sessionStorage` for the selected filter.
- JSON serialization.
- JSON parsing.
- Validation during task restoration.
- Storage-specific errors.

## `js/services/storage-service.js`

```javascript
"use strict";

import { Task } from "../models/task.js";
import { StorageError } from "../utils/errors.js";

const TASKS_STORAGE_KEY = "async-task-manager.tasks.v1";
const FILTER_SESSION_KEY = "async-task-manager.filter.v1";

function getStorage(storageName) {
  try {
    const storage = window[storageName];

    if (!storage) {
      throw new Error(`${storageName} is unavailable.`);
    }

    return storage;
  } catch (error) {
    throw new StorageError(
      `Could not access ${storageName}.`,
      { cause: error }
    );
  }
}

function readStorageValue(storage, key, storageName) {
  try {
    return storage.getItem(key);
  } catch (error) {
    throw new StorageError(
      `Could not read data from ${storageName}.`,
      { cause: error }
    );
  }
}

function parseStoredJSON(rawValue, storageName) {
  if (rawValue === null) {
    return null;
  }

  try {
    return JSON.parse(rawValue);
  } catch (error) {
    throw new StorageError(
      `Data in ${storageName} is not valid JSON.`,
      { cause: error }
    );
  }
}

export function loadTasks() {
  const storage = getStorage("localStorage");
  const rawValue = readStorageValue(
    storage,
    TASKS_STORAGE_KEY,
    "localStorage"
  );

  if (rawValue === null) {
    return [];
  }

  const parsedValue = parseStoredJSON(rawValue, "localStorage");

  if (!Array.isArray(parsedValue)) {
    throw new StorageError("Stored tasks must be an array.");
  }

  const restoredTasks = [];

  for (const storedTask of parsedValue) {
    try {
      restoredTasks.push(Task.fromJSON(storedTask));
    } catch (error) {
      /*
       * One malformed record should not destroy all valid records.
       * Invalid records are ignored and reported for debugging.
       */
      console.warn("Ignoring malformed stored task:", error);
    }
  }

  return restoredTasks;
}

export function saveTasks(tasks) {
  if (!Array.isArray(tasks)) {
    throw new TypeError("saveTasks expects an array.");
  }

  const storage = getStorage("localStorage");

  try {
    const serializedTasks = JSON.stringify(
      tasks.map((task) => task.toJSON())
    );

    storage.setItem(TASKS_STORAGE_KEY, serializedTasks);
  } catch (error) {
    throw new StorageError(
      "Could not save tasks to localStorage.",
      { cause: error }
    );
  }
}

export function clearTasks() {
  const storage = getStorage("localStorage");

  try {
    storage.removeItem(TASKS_STORAGE_KEY);
  } catch (error) {
    throw new StorageError(
      "Could not clear saved tasks.",
      { cause: error }
    );
  }
}

export function loadFilterPreference() {
  const storage = getStorage("sessionStorage");
  const rawValue = readStorageValue(
    storage,
    FILTER_SESSION_KEY,
    "sessionStorage"
  );

  return rawValue ?? "all";
}

export function saveFilterPreference(filter) {
  const storage = getStorage("sessionStorage");

  try {
    storage.setItem(FILTER_SESSION_KEY, filter);
  } catch (error) {
    throw new StorageError(
      "Could not save the filter preference.",
      { cause: error }
    );
  }
}
```

---

# File 7: `js/services/task-service.js`

This module contains task business operations.

It does not know about:

- HTML.
- Buttons.
- CSS.
- `localStorage`.
- Browser events.

## `js/services/task-service.js`

```javascript
"use strict";

import { Task } from "../models/task.js";
import { validateTaskTitle } from "../utils/validation.js";

export class TaskService {
  constructor(initialTasks = []) {
    if (!Array.isArray(initialTasks)) {
      throw new TypeError("TaskService expects an array.");
    }

    this.tasks = [...initialTasks];
  }

  getAll() {
    return [...this.tasks];
  }

  getByFilter(filter) {
    if (filter === "active") {
      return this.tasks.filter((task) => !task.isCompleted());
    }

    if (filter === "completed") {
      return this.tasks.filter((task) => task.isCompleted());
    }

    return this.getAll();
  }

  add(title) {
    const normalizedTitle = validateTaskTitle(title);

    const task = new Task({
      title: normalizedTitle,
    });

    this.tasks.push(task);

    return task;
  }

  toggle(taskId) {
    const task = this.findById(taskId);

    if (!task) {
      throw new Error("The selected task could not be found.");
    }

    task.toggleCompletion();

    return task;
  }

  remove(taskId) {
    const originalLength = this.tasks.length;

    this.tasks = this.tasks.filter((task) => task.id !== taskId);

    if (this.tasks.length === originalLength) {
      throw new Error("The selected task could not be found.");
    }
  }

  replaceAll(tasks) {
    if (!Array.isArray(tasks)) {
      throw new TypeError("replaceAll expects an array.");
    }

    this.tasks = [...tasks];
  }

  findById(taskId) {
    return this.tasks.find((task) => task.id === taskId);
  }

  countCompleted() {
    return this.tasks.filter((task) => task.isCompleted()).length;
  }
}
```

---

# File 8: `js/api/task-api.js`

This module simulates an asynchronous API.

It returns a Promise that:

- Resolves with example `Task` objects.
- Rejects if the simulated request fails.

## `js/api/task-api.js`

```javascript
"use strict";

import { Task } from "../models/task.js";

export function fetchExampleTasks({ shouldFail = false } = {}) {
  return new Promise((resolve, reject) => {
    window.setTimeout(() => {
      if (shouldFail) {
        reject(
          new Error("The example task API could not load the tasks.")
        );
        return;
      }

      resolve([
        new Task({
          title: "Read about ES modules",
        }),
        new Task({
          title: "Compare localStorage and sessionStorage",
        }),
        new Task({
          title: "Verify safe JSON parsing",
          completed: true,
        }),
      ]);
    }, 1200);
  });
}
```

---

# File 9: `js/ui/status-message.js`

This module controls the status message area.

It knows how to:

- Display text.
- Apply loading styling.
- Apply success styling.
- Apply error styling.

## `js/ui/status-message.js`

```javascript
"use strict";

export function createStatusController(element) {
  if (!(element instanceof HTMLElement)) {
    throw new TypeError("A status HTMLElement is required.");
  }

  function show(message, state = "default") {
    element.textContent = message;
    element.className = "status-message";

    if (state === "loading") {
      element.classList.add("status-loading");
    }

    if (state === "success") {
      element.classList.add("status-success");
    }

    if (state === "error") {
      element.classList.add("status-error");
    }
  }

  return {
    show,
  };
}
```

---

# File 10: `js/ui/task-form.js`

This module handles form submission.

It does not create tasks directly. Instead, it passes the submitted title to a callback supplied by the application coordinator.

## `js/ui/task-form.js`

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

  if (!(titleInput instanceof HTMLInputElement)) {
    throw new Error("The task title input could not be found.");
  }

  formElement.addEventListener("submit", (event) => {
    event.preventDefault();

    onSubmit(titleInput.value);

    titleInput.value = "";
    titleInput.focus();
  });
}
```

---

# File 11: `js/ui/task-list.js`

This module renders tasks and creates task action buttons.

User-entered task titles are placed into the DOM with `textContent`, not `innerHTML`.

That prevents a task title from being interpreted as HTML.

## `js/ui/task-list.js`

```javascript
"use strict";

export function renderTaskList(
  listElement,
  tasks,
  { onToggle, onDelete }
) {
  if (!(listElement instanceof HTMLElement)) {
    throw new TypeError("A task list element is required.");
  }

  if (!Array.isArray(tasks)) {
    throw new TypeError("renderTaskList expects an array.");
  }

  if (typeof onToggle !== "function") {
    throw new TypeError("onToggle must be a function.");
  }

  if (typeof onDelete !== "function") {
    throw new TypeError("onDelete must be a function.");
  }

  listElement.replaceChildren();

  if (tasks.length === 0) {
    const emptyMessage = document.createElement("p");
    emptyMessage.className = "empty-state";
    emptyMessage.textContent = "No tasks match the selected filter.";
    listElement.append(emptyMessage);
    return;
  }

  for (const task of tasks) {
    const listItem = document.createElement("li");
    listItem.className = "task-item";

    if (task.isCompleted()) {
      listItem.classList.add("task-completed");
    }

    const textContainer = document.createElement("div");

    const title = document.createElement("p");
    title.className = "task-title";

    /*
     * textContent inserts user data as text.
     * It does not parse the content as HTML.
     */
    title.textContent = task.title;

    const metadata = document.createElement("p");
    metadata.className = "task-meta";
    metadata.textContent = task.getStatusLabel();

    textContainer.append(title, metadata);

    const actions = document.createElement("div");
    actions.className = "task-actions";

    const toggleButton = document.createElement("button");
    toggleButton.type = "button";
    toggleButton.className = "task-action";
    toggleButton.textContent = task.isCompleted()
      ? "Mark as incomplete"
      : "Mark as complete";

    toggleButton.addEventListener("click", () => {
      onToggle(task.id);
    });

    const deleteButton = document.createElement("button");
    deleteButton.type = "button";
    deleteButton.className = "task-action task-delete-action";
    deleteButton.textContent = "Delete";

    deleteButton.addEventListener("click", () => {
      onDelete(task.id);
    });

    actions.append(toggleButton, deleteButton);
    listItem.append(textContainer, actions);
    listElement.append(listItem);
  }
}
```

---

# File 12: `js/app.js`

This is the application coordinator.

It connects:

- The task form.
- The task service.
- The API.
- Browser storage.
- The task list.
- The status controller.

## `js/app.js`

```javascript
"use strict";

import { fetchExampleTasks } from "./api/task-api.js";
import { TaskService } from "./services/task-service.js";
import {
  clearTasks,
  loadFilterPreference,
  loadTasks,
  saveFilterPreference,
  saveTasks,
} from "./services/storage-service.js";
import { createStatusController } from "./ui/status-message.js";
import { bindTaskForm } from "./ui/task-form.js";
import { renderTaskList } from "./ui/task-list.js";
import { normalizeError } from "./utils/errors.js";
import { isValidFilter } from "./utils/validation.js";

export class App {
  constructor({
    taskForm,
    taskList,
    taskCount,
    statusMessage,
    loadTasksButton,
    clearTasksButton,
    taskFilter,
  }) {
    this.taskForm = taskForm;
    this.taskList = taskList;
    this.taskCount = taskCount;
    this.loadTasksButton = loadTasksButton;
    this.clearTasksButton = clearTasksButton;
    this.taskFilter = taskFilter;

    this.status = createStatusController(statusMessage);
    this.taskService = new TaskService();
    this.currentFilter = "all";
    this.isLoading = false;
  }

  start() {
    this.restoreState();
    this.bindEvents();
    this.render();

    /*
     * This message intentionally appears only if restoreState()
     * did not display a storage error.
     */
    if (this.taskService.getAll().length > 0) {
      this.status.show(
        "Ready. Saved tasks were restored from localStorage.",
        "success"
      );
    } else {
      this.status.show(
        "Ready. Tasks are saved in localStorage.",
        "success"
      );
    }
  }

  restoreState() {
    try {
      const storedTasks = loadTasks();
      this.taskService.replaceAll(storedTasks);

      const storedFilter = loadFilterPreference();

      if (isValidFilter(storedFilter)) {
        this.currentFilter = storedFilter;
        this.taskFilter.value = storedFilter;
      }
    } catch (error) {
      const normalizedError = normalizeError(error);

      console.error("Could not restore application state:", normalizedError);

      this.status.show(
        `Some saved data could not be restored: ${normalizedError.message}`,
        "error"
      );
    }
  }

  bindEvents() {
    bindTaskForm(this.taskForm, (title) => {
      this.handleAddTask(title);
    });

    this.loadTasksButton.addEventListener("click", () => {
      this.handleLoadExampleTasks();
    });

    this.clearTasksButton.addEventListener("click", () => {
      this.handleClearTasks();
    });

    this.taskFilter.addEventListener("change", () => {
      this.handleFilterChange(this.taskFilter.value);
    });
  }

  render() {
    const visibleTasks = this.taskService.getByFilter(
      this.currentFilter
    );

    renderTaskList(this.taskList, visibleTasks, {
      onToggle: (taskId) => {
        this.handleToggleTask(taskId);
      },
      onDelete: (taskId) => {
        this.handleDeleteTask(taskId);
      },
    });

    const totalTasks = this.taskService.getAll().length;
    const completedTasks = this.taskService.countCompleted();

    this.taskCount.textContent =
      `${totalTasks} ${totalTasks === 1 ? "task" : "tasks"} · ` +
      `${completedTasks} completed`;
  }

  persistTasks() {
    saveTasks(this.taskService.getAll());
  }

  handleAddTask(title) {
    try {
      const task = this.taskService.add(title);

      this.persistTasks();
      this.render();
      this.status.show(`Added task: ${task.title}`, "success");
    } catch (error) {
      const normalizedError = normalizeError(error);

      this.status.show(normalizedError.message, "error");
    }
  }

  handleToggleTask(taskId) {
    try {
      const task = this.taskService.toggle(taskId);

      this.persistTasks();
      this.render();

      this.status.show(
        `${task.title}: ${task.getStatusLabel()}.`,
        "success"
      );
    } catch (error) {
      const normalizedError = normalizeError(error);

      this.status.show(normalizedError.message, "error");
    }
  }

  handleDeleteTask(taskId) {
    try {
      this.taskService.remove(taskId);

      this.persistTasks();
      this.render();
      this.status.show("Task deleted.", "success");
    } catch (error) {
      const normalizedError = normalizeError(error);

      this.status.show(normalizedError.message, "error");
    }
  }

  handleFilterChange(filter) {
    if (!isValidFilter(filter)) {
      this.status.show("The selected filter is invalid.", "error");
      return;
    }

    this.currentFilter = filter;

    try {
      saveFilterPreference(filter);
    } catch (error) {
      /*
       * A filter preference is helpful but not essential.
       * If sessionStorage fails, the current filter still works.
       */
      console.warn("Could not save filter preference:", error);
    }

    this.render();
  }

  handleClearTasks() {
    try {
      clearTasks();
      this.taskService.replaceAll([]);
      this.render();
      this.status.show("All saved tasks were cleared.", "success");
    } catch (error) {
      const normalizedError = normalizeError(error);

      this.status.show(normalizedError.message, "error");
    }
  }

  async handleLoadExampleTasks() {
    if (this.isLoading) {
      return;
    }

    this.isLoading = true;
    this.loadTasksButton.disabled = true;
    this.status.show("Loading example tasks...", "loading");

    try {
      const exampleTasks = await fetchExampleTasks();

      this.taskService.replaceAll(exampleTasks);
      this.persistTasks();
      this.render();

      this.status.show(
        `Loaded and saved ${exampleTasks.length} example tasks.`,
        "success"
      );
    } catch (error) {
      const normalizedError = normalizeError(error);

      console.error("Could not load example tasks:", normalizedError);

      this.status.show(
        `Could not load example tasks: ${normalizedError.message}`,
        "error"
      );
    } finally {
      this.isLoading = false;
      this.loadTasksButton.disabled = false;
    }
  }
}
```

> **Note:** The `start()` method above displays the final ready message after `restoreState()`. If you want storage errors to remain visible instead of being replaced by the ready message, use the improved version below.

### Improved `js/app.js` `start()` method

Replace only the `start()` method with this version:

```javascript
start() {
  const restorationSucceeded = this.restoreState();

  this.bindEvents();
  this.render();

  if (restorationSucceeded) {
    if (this.taskService.getAll().length > 0) {
      this.status.show(
        "Ready. Saved tasks were restored from localStorage.",
        "success"
      );
    } else {
      this.status.show(
        "Ready. Tasks are saved in localStorage.",
        "success"
      );
    }
  }
}
```

Then replace `restoreState()` with this version:

```javascript
restoreState() {
  try {
    const storedTasks = loadTasks();
    this.taskService.replaceAll(storedTasks);

    const storedFilter = loadFilterPreference();

    if (isValidFilter(storedFilter)) {
      this.currentFilter = storedFilter;
      this.taskFilter.value = storedFilter;
    }

    return true;
  } catch (error) {
    const normalizedError = normalizeError(error);

    console.error("Could not restore application state:", normalizedError);

    this.status.show(
      `Some saved data could not be restored: ${normalizedError.message}`,
      "error"
    );

    return false;
  }
}
```

Use the improved versions in the final project.

---

# File 13: `js/main.js`

This is the browser entry point.

It finds the required page elements, constructs the application, and starts it.

## `js/main.js`

```javascript
"use strict";

import { App } from "./app.js";

const app = new App({
  taskForm: document.querySelector("#task-form"),
  taskList: document.querySelector("#task-list"),
  taskCount: document.querySelector("#task-count"),
  statusMessage: document.querySelector("#status-message"),
  loadTasksButton: document.querySelector("#load-tasks-button"),
  clearTasksButton: document.querySelector("#clear-tasks-button"),
  taskFilter: document.querySelector("#task-filter"),
});

app.start();
```

---

# Running the Complete Application

Do not open `index.html` directly with a `file://` URL.

Start a local HTTP server from the project root.

## Python

### macOS or Linux

```bash
python3 -m http.server 8000
```

### Windows

```powershell
python -m http.server 8000
```

Open:

```text
http://localhost:8000
```

---

# Complete Verification Checklist

## 1. Initial startup

Open:

```text
http://localhost:8000
```

Verify:

- The page loads without a module error.
- The status message appears.
- The task list is visible.
- The browser console has no uncaught errors.

## 2. Add a task

Enter:

```text
Practice modular JavaScript
```

Click **Add task**.

Verify:

- The task appears.
- The task count increases.
- A success message appears.

## 3. Validate an empty task

Submit an empty input.

Verify:

```text
Task title cannot be empty.
```

## 4. Complete a task

Click **Mark as complete**.

Verify:

- The task title receives a strikethrough.
- The label changes to `Completed`.
- The completed count increases.

## 5. Persist the task

Refresh the page.

Verify:

- The task still exists.
- Its completion state remains unchanged.

## 6. Filter tasks

Select:

```text
Completed tasks
```

Verify that only completed tasks appear.

Select:

```text
Active tasks
```

Verify that only incomplete tasks appear.

## 7. Persist the filter

Select a filter and refresh the page.

Verify that the same filter remains selected.

## 8. Delete a task

Click **Delete**.

Verify:

- The task disappears.
- The status message confirms deletion.
- Refreshing the page does not restore the deleted task.

## 9. Load example tasks

Click **Load example tasks**.

Verify:

- The button becomes disabled.
- The loading message appears.
- The page remains responsive.
- Three tasks appear after approximately 1.2 seconds.
- The button becomes enabled.
- The loaded tasks remain after refresh.

## 10. Clear saved tasks

Click **Clear saved tasks**.

Verify:

- The task list becomes empty.
- The status confirms that tasks were cleared.
- Refreshing the page does not restore them.

---

# Inspecting Browser Storage

Open developer tools.

In Chromium-based browsers:

```text
Developer Tools → Application → Storage
```

Inspect:

```text
Local Storage → http://localhost:8000
```

The task data is stored under:

```text
async-task-manager.tasks.v1
```

Inspect:

```text
Session Storage → http://localhost:8000
```

The filter preference is stored under:

```text
async-task-manager.filter.v1
```

You can inspect the task JSON from the console:

```javascript
localStorage.getItem("async-task-manager.tasks.v1");
```

You can inspect the filter:

```javascript
sessionStorage.getItem("async-task-manager.filter.v1");
```

---

# Storage Failure Test

To test malformed JSON, run this in the browser console:

```javascript
localStorage.setItem(
  "async-task-manager.tasks.v1",
  "{invalid json"
);
```

Refresh the page.

The application should:

- Continue loading.
- Display an error status.
- Log a storage-related error in the console.
- Avoid crashing with an unhandled exception.

Remove the invalid value:

```javascript
localStorage.removeItem("async-task-manager.tasks.v1");
```

Refresh again.

---

# Malformed Task Test

Run:

```javascript
localStorage.setItem(
  "async-task-manager.tasks.v1",
  JSON.stringify([
    {
      id: 1,
      title: "Valid task",
      completed: false,
      createdAt: new Date().toISOString()
    },
    {
      id: "invalid-id",
      title: "",
      completed: "invalid-state",
      createdAt: "not-a-date"
    }
  ])
);
```

Refresh the page.

Expected behavior:

- `Valid task` loads.
- The malformed task is ignored.
- A warning appears in the browser console.

Clean up:

```javascript
localStorage.removeItem("async-task-manager.tasks.v1");
```

---

# Final Dependency Map

The application’s dependency direction is:

```text
main.js
  ↓
app.js
  ├── api/task-api.js
  ├── services/task-service.js
  ├── services/storage-service.js
  ├── ui/status-message.js
  ├── ui/task-form.js
  ├── ui/task-list.js
  └── utils/*
```

The lower-level modules do not import `app.js`.

This prevents circular dependencies and keeps the application easier to reason about.

---

# Final Request Flow: Adding a Task

```text
User submits form
        ↓
task-form.js captures the event
        ↓
app.js receives the title
        ↓
task-service.js validates the title
        ↓
Task model creates a valid Task instance
        ↓
storage-service.js serializes the task
        ↓
localStorage stores the JSON string
        ↓
task-list.js renders the updated task list
```

---

# Final Request Flow: Loading Example Tasks

```text
User clicks Load example tasks
        ↓
app.js disables the button
        ↓
task-api.js returns a Promise
        ↓
The browser waits without blocking the page
        ↓
The Promise fulfills or rejects
        ↓
app.js handles the result
        ↓
TaskService receives Task instances
        ↓
storage-service.js persists the tasks
        ↓
task-list.js renders the tasks
        ↓
app.js restores the button in finally
```

---

# Final Request Flow: Restoring Saved Tasks

```text
Application starts
        ↓
storage-service.js reads localStorage
        ↓
JSON.parse() converts text into values
        ↓
Task.fromJSON() validates each record
        ↓
Valid Task instances are returned
        ↓
TaskService receives the tasks
        ↓
app.js applies the active filter
        ↓
task-list.js renders the result
```
