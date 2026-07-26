# Part 4: Modular Architecture and Browser Storage

In Part 3, the application began using a `Task` class. The application now has meaningful objects, but most of its behavior is still concentrated in `js/main.js`.

That structure will become difficult to maintain as features are added.

In this final part, we will reorganize the application into modules and add persistent browser storage.

By the end of this part, the application will support:

- Separate files for models, services, API communication, UI, and utilities.
- ES module `import` and `export` syntax.
- Persistent tasks using `localStorage`.
- Temporary UI preferences using `sessionStorage`.
- Safe JSON parsing.
- Validation of stored data.
- Adding tasks.
- Completing tasks.
- Deleting tasks.
- Filtering tasks.
- Loading example tasks asynchronously.
- Handling malformed stored data.
- Recovering from browser storage errors.

The final architecture will be:

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

[COMPLETED: Part 3 — Prototypes and Object-Oriented Patterns]  
[STARTING: Step 1 — Create the modular project structure]

---

# Step 1: Create the Modular Project Structure

## The Target

Create directories for each responsibility in the application.

## The Concept

A module is like a department in a company.

- The model department defines what a task is.
- The storage department saves and loads data.
- The UI department updates the page.
- The API department handles delayed external data.
- The service department applies business rules.

Each department has a narrow responsibility and communicates through exported functions.

## The Implementation

From the project root, run:

### macOS or Linux

```bash
mkdir -p js/api js/models js/services js/ui js/utils
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Force -Path js/api
New-Item -ItemType Directory -Force -Path js/models
New-Item -ItemType Directory -Force -Path js/services
New-Item -ItemType Directory -Force -Path js/ui
New-Item -ItemType Directory -Force -Path js/utils
```

The project should now contain:

```text
async-task-manager/
├── index.html
├── styles.css
└── js/
    ├── main.js
    ├── api/
    ├── models/
    ├── services/
    ├── ui/
    └── utils/
```

## The Verification

Run:

### macOS or Linux

```bash
find js -type d
```

### Windows PowerShell

```powershell
Get-ChildItem js -Directory -Recurse
```

Confirm that these directories exist:

```text
js/api
js/models
js/services
js/ui
js/utils
```

[COMPLETED: Step 1 — Modular directories created]  
[STARTING: Step 2 — Move the Task model into its model module]

---

# Step 2: Create the Task Model Module

## The Target

Create `js/models/task.js`.

The model will define:

- Task validation.
- Task behavior.
- JSON serialization.
- Safe reconstruction from stored data.
- Unique identifiers.

## The Concept

The model is the application’s rulebook for task objects.

Every task must satisfy the same rules:

- It must have a valid identifier.
- Its title must be a non-empty string.
- Its title cannot exceed 120 characters.
- Its completion state must be Boolean.
- Its creation date must be valid.

Centralizing these rules prevents different parts of the application from creating incompatible task objects.

## The Implementation

### `js/models/task.js`

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
     * This identifier is suitable for this browser-only project.
     * A server-backed production system would normally assign IDs
     * on the server or use crypto.randomUUID().
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
     * JSON cannot preserve a Date object or a class prototype.
     * Convert the date to a standard string before persistence.
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

## The Verification

Create a temporary module test.

### `js/test-task-module.js`

```javascript
import { Task } from "./models/task.js";

const task = new Task({
  title: "Test the modular Task model",
});

console.log(task instanceof Task);
console.log(task.getStatusLabel());
console.log(task.toJSON());
```

Temporarily change the script in `index.html` to:

```html
<script type="module" src="./js/test-task-module.js"></script>
```

Open the application through a local server:

```bash
python3 -m http.server 8000
```

Visit:

```text
http://localhost:8000
```

The console should show:

```text
true
Not completed
```

Restore the script tag later:

```html
<script type="module" src="./js/main.js"></script>
```

Delete:

```text
js/test-task-module.js
```

[COMPLETED: Step 2 — Task model moved into a module]  
[STARTING: Step 3 — Add shared error types and validation helpers]

---

# Step 3: Create Utility Modules

## The Target

Create:

- `js/utils/errors.js`
- `js/utils/validation.js`

## The Concept

Utility modules contain small pieces of logic that are useful in several places.

An error type gives the application a recognizable category of failure.

For example:

- A storage error means browser persistence failed.
- A validation error means input was invalid.
- An asynchronous API error means loading failed.

This is more useful than treating every failure as an anonymous string.

## The Implementation

### `js/utils/errors.js`

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

### `js/utils/validation.js`

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

## The Verification

Create this temporary file:

### `js/test-utils.js`

```javascript
import {
  normalizeError,
  StorageError,
} from "./utils/errors.js";
import { validateTaskTitle } from "./utils/validation.js";

console.log(validateTaskTitle("  Valid title  "));

try {
  validateTaskTitle("   ");
} catch (error) {
  console.log(error.name);
  console.log(error.message);
}

const storageError = new StorageError("Storage failed.");
console.log(storageError instanceof Error);
console.log(storageError.name);

console.log(normalizeError("Unexpected string failure").message);
```

Temporarily load it from `index.html`:

```html
<script type="module" src="./js/test-utils.js"></script>
```

Expected output includes:

```text
Valid title
ValidationError
Task title cannot be empty.
true
StorageError
Unexpected string failure
```

Restore the main script and delete `js/test-utils.js`.

[COMPLETED: Step 3 — Shared errors and validation created]  
[STARTING: Step 4 — Build the browser storage service]

---

# Step 4: Create the Storage Service

## The Target

Create `js/services/storage-service.js`.

This module will provide:

- `localStorage` persistence.
- `sessionStorage` persistence.
- Safe JSON parsing.
- Validation during restoration.
- Storage error handling.
- Clear operations.

## The Concept

`localStorage` is a filing cabinet that survives browser refreshes.

`sessionStorage` is a temporary desk drawer:

- It survives page navigation within the current browser tab.
- It is cleared when the tab or window session ends.

Both APIs store strings only.

Therefore, this object:

```javascript
[
  {
    title: "Learn storage"
  }
]
```

must be converted to text:

```javascript
JSON.stringify(tasks)
```

When reading it back, the text must become JavaScript data again:

```javascript
JSON.parse(storedText)
```

Stored data is external input. It may be missing, malformed, outdated, or manually edited. The service must validate it before returning it.

## The Implementation

### `js/services/storage-service.js`

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
  const rawValue = storage.getItem(TASKS_STORAGE_KEY);

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
       * One malformed task should not destroy every valid task.
       * Invalid records are ignored and reported to the console.
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

  try {
    return storage.getItem(FILTER_SESSION_KEY) ?? "all";
  } catch (error) {
    throw new StorageError(
      "Could not load the filter preference.",
      { cause: error }
    );
  }
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

## The Verification

Create a temporary file:

### `js/test-storage.js`

```javascript
import {
  clearTasks,
  loadTasks,
  saveTasks,
} from "./services/storage-service.js";
import { Task } from "./models/task.js";

const testTasks = [
  new Task({
    id: 500,
    title: "Verify localStorage",
  }),
];

saveTasks(testTasks);

const restoredTasks = loadTasks();

console.log(restoredTasks);
console.log(restoredTasks[0] instanceof Task);
console.log(restoredTasks[0].title);

clearTasks();

console.log(loadTasks());
```

Temporarily load it from `index.html`.

Expected output:

```text
true
Verify localStorage
[]
```

Open browser developer tools and inspect:

```text
Application → Local Storage → http://localhost:8000
```

You should see the task key while the test is running. It should disappear after `clearTasks()`.

Restore `index.html` and delete `js/test-storage.js`.

[COMPLETED: Step 4 — Safe local and session storage service created]  
[STARTING: Step 5 — Create the task service]

---

# Step 5: Create the Task Service

## The Target

Create `js/services/task-service.js`.

This module will manage task operations without knowing anything about HTML.

## The Concept

The task service is the application’s business layer.

It answers questions such as:

- How do we add a task?
- How do we toggle a task?
- How do we delete a task?
- Which tasks match the selected filter?

It does not:

- Query DOM elements.
- Set CSS classes.
- Display status messages.
- Read form fields.

That separation makes the business rules easier to test.

## The Implementation

### `js/services/task-service.js`

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

## The Verification

Create:

### `js/test-task-service.js`

```javascript
import { TaskService } from "./services/task-service.js";

const service = new TaskService();

const task = service.add("Use the task service");

console.log(service.getAll().length);
console.log(service.countCompleted());

service.toggle(task.id);

console.log(service.countCompleted());
console.log(service.getByFilter("completed").length);

service.remove(task.id);

console.log(service.getAll().length);
```

Expected output:

```text
1
0
1
1
0
```

Restore the main application script and delete the temporary test.

[COMPLETED: Step 5 — Task business service created]  
[STARTING: Step 6 — Create the asynchronous API module]

---

# Step 6: Create the Task API Module

## The Target

Create `js/api/task-api.js`.

## The Concept

The API module represents communication with a remote system.

The application should not need to know whether tasks came from:

- A real server.
- A test server.
- A local fixture.
- A delayed simulation.

It should call a stable function and receive a Promise.

## The Implementation

### `js/api/task-api.js`

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

## The Verification

Create:

### `js/test-api.js`

```javascript
import { fetchExampleTasks } from "./api/task-api.js";

const tasks = await fetchExampleTasks();

console.log(tasks);
console.log(tasks.length);
console.log(tasks[0].title);
```

Temporarily load the test module.

After approximately 1.2 seconds, the console should show three tasks.

To test failure, change the call:

```javascript
const tasks = await fetchExampleTasks({
  shouldFail: true,
});
```

The browser should report a rejected Promise. Wrap it to verify the expected error:

```javascript
try {
  await fetchExampleTasks({ shouldFail: true });
} catch (error) {
  console.log(error.message);
}
```

Expected output:

```text
The example task API could not load the tasks.
```

Restore the main script and delete `js/test-api.js`.

[COMPLETED: Step 6 — Promise-based API module created]  
[STARTING: Step 7 — Build the UI modules]

---

# Step 7: Create the UI Modules

## The Target

Create:

- `js/ui/status-message.js`
- `js/ui/task-form.js`
- `js/ui/task-list.js`

## The Concept

UI modules are responsible for displaying information and translating browser events into callbacks.

They should not decide how tasks are stored.

For example, the task list should ask the application:

> What should happen when this task’s completion button is clicked?

It should not directly modify `localStorage`.

## The Implementation

### `js/ui/status-message.js`

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

### `js/ui/task-form.js`

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

### `js/ui/task-list.js`

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

## The Verification

The UI modules will be verified through the complete application in the next steps.

For now, confirm that all three files exist:

```text
js/ui/status-message.js
js/ui/task-form.js
js/ui/task-list.js
```

[COMPLETED: Step 7 — UI modules created]  
[STARTING: Step 8 — Update the HTML for the final features]

---

# Step 8: Update `index.html`

## The Target

Add:

- A filter control.
- A clear-storage button.
- The final module entry point.

## The Concept

The HTML supplies controls and containers. Modules will attach behavior to them later.

The filter control stores the user’s current view preference in `sessionStorage`, while the actual tasks are stored in `localStorage`.

## The Implementation

### `index.html`

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
            <p>Load example tasks through a Promise-based API.</p>
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
            <p>The selected filter is remembered for this browser session.</p>
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

          <button id="clear-tasks-button" class="task-action" type="button">
            Clear saved tasks
          </button>
        </div>

        <ul id="task-list" class="task-list"></ul>
      </section>
    </main>

    <script type="module" src="./js/main.js"></script>
  </body>
</html>
```

## The Verification

Refresh the browser.

You should see:

- The filter control.
- The clear button.
- The task list.
- The asynchronous loading button.

The controls will become active after `app.js` is created.

[COMPLETED: Step 8 — Final HTML structure created]  
[STARTING: Step 9 — Create the application coordinator]

---

# Step 9: Create `app.js`

## The Target

Create `js/app.js`.

This module will coordinate the other modules.

## The Concept

The application coordinator is like an orchestra conductor.

It does not play every instrument. Instead, it:

- Connects the form to the task service.
- Connects the task service to storage.
- Connects buttons to application actions.
- Tells the UI when to render.
- Handles asynchronous loading.

This is the correct place for workflow logic because it understands how the modules cooperate.

## The Implementation

### `js/app.js`

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
    this.status.show("Ready. Tasks are saved in localStorage.", "success");
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
    const visibleTasks = this.taskService.getByFilter(this.currentFilter);

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

## The Verification

The file should exist at:

```text
js/app.js
```

Check that its imports refer to the correct relative paths:

```javascript
"./api/task-api.js"
"./services/task-service.js"
"./services/storage-service.js"
"./ui/status-message.js"
"./ui/task-form.js"
"./ui/task-list.js"
"./utils/errors.js"
"./utils/validation.js"
```

[COMPLETED: Step 9 — Application coordinator created]  
[STARTING: Step 10 — Create the browser entry point]

---

# Step 10: Create `main.js`

## The Target

Create the small browser entry point.

## The Concept

The entry point should do very little.

Its job is to:

1. Find the page elements.
2. Construct the application.
3. Start it.

Keeping startup small makes it easy to understand where the application begins.

## The Implementation

### `js/main.js`

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

## The Verification

Start the local server:

```bash
python3 -m http.server 8000
```

Or on Windows:

```powershell
python -m http.server 8000
```

Open:

```text
http://localhost:8000
```

The application should now start.

If the page does not work, open the browser console. Common errors at this stage are:

- Incorrect import paths.
- Missing `.js` extensions.
- Opening the page with `file://` instead of a local server.
- A missing HTML element ID.
- A syntax error in one module.

[COMPLETED: Step 10 — Modular application startup connected]  
[STARTING: Step 11 — Update the stylesheet for the new controls]

---

# Step 11: Complete the Stylesheet

## The Target

Replace `styles.css` with a final version supporting the filter and delete controls.

## The Implementation

### `styles.css`

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

## The Verification

Refresh the application.

Verify that:

- The filter control is styled.
- The delete button is visible.
- The task action buttons align correctly.
- The layout remains usable on a narrow browser window.

[COMPLETED: Step 11 — Final styling applied]  
[STARTING: Step 12 — Verify the complete application]

---

# Step 12: Verify the Complete Application

## The Target

Run a complete end-to-end test of the final modular application.

## The Verification

Start the server:

```bash
python3 -m http.server 8000
```

Open:

```text
http://localhost:8000
```

## Test 1: Initial application startup

The status should say:

```text
Ready. Tasks are saved in localStorage.
```

If no saved tasks exist, the list should show:

```text
No tasks match the selected filter.
```

## Test 2: Add a task

Enter:

```text
Practice modular JavaScript
```

Click **Add task**.

Verify:

- The task appears.
- A success message appears.
- The task count changes.
- The task is saved.

Refresh the page.

The task should still exist.

This proves that `localStorage` persistence works.

## Test 3: Complete a task

Click **Mark as complete**.

Verify:

- The title receives a strikethrough.
- The status changes to `Completed`.
- The completed count increases.

Refresh the page.

The completed state should remain.

## Test 4: Filter tasks

Select:

```text
Completed tasks
```

Only completed tasks should appear.

Select:

```text
Active tasks
```

Only incomplete tasks should appear.

Refresh the page.

The selected filter should remain because it is stored in `sessionStorage`.

## Test 5: Delete a task

Click **Delete** on a task.

Verify:

- The task disappears.
- A success message appears.
- Refreshing the page does not restore the deleted task.

## Test 6: Load example tasks asynchronously

Click **Load example tasks**.

Immediately verify:

- The button becomes disabled.
- The status shows a loading message.
- The page remains responsive.

After approximately 1.2 seconds:

- Three example tasks appear.
- They are saved to `localStorage`.
- The button becomes enabled.
- A success message appears.

Refresh the page.

The loaded tasks should remain.

## Test 7: Clear saved tasks

Click **Clear saved tasks**.

Verify:

- The task list becomes empty.
- The status confirms that tasks were cleared.
- Refreshing the page does not restore them.

## Test 8: Test malformed storage

Open browser developer tools and run:

```javascript
localStorage.setItem(
  "async-task-manager.tasks.v1",
  "{invalid json"
);
```

Refresh the page.

The application should display an error status instead of crashing silently.

Now remove the invalid value:

```javascript
localStorage.removeItem("async-task-manager.tasks.v1");
```

Refresh again.

## Test 9: Test valid but malformed task data

Run:

```javascript
localStorage.setItem(
  "async-task-manager.tasks.v1",
  JSON.stringify([
    {
      id: 1,
      title: "Valid stored task",
      completed: false,
      createdAt: new Date().toISOString()
    },
    {
      id: "not-a-number",
      title: "",
      completed: "not-a-boolean",
      createdAt: "invalid-date"
    }
  ])
);
```

Refresh the page.

The valid task should load.

The malformed task should be ignored and reported in the console.

This demonstrates why stored data must be validated instead of trusted.

[COMPLETED: Step 12 — Complete modular application verified]  
[STARTING: Part 4 Reference — Modules and browser storage]

---

# Part 4 Reference: ES Modules

## Named Exports

A module can export a named value:

```javascript
export function add(a, b) {
  return a + b;
}
```

Import it with matching braces:

```javascript
import { add } from "./math.js";
```

The name must match.

---

## Multiple Named Exports

```javascript
export const applicationName = "Task Manager";

export function startApplication() {
  console.log("Started");
}
```

Import:

```javascript
import {
  applicationName,
  startApplication,
} from "./app.js";
```

---

## Default Exports

A module can have one default export:

```javascript
export default class TaskService {
}
```

Import without braces:

```javascript
import TaskService from "./task-service.js";
```

This series uses named exports because explicit names make dependencies easier to see.

---

## Relative Paths

Browser module imports must include the correct relative path and usually the `.js` extension:

```javascript
import { Task } from "../models/task.js";
```

The path is relative to the importing file, not the HTML file.

From:

```text
js/services/storage-service.js
```

to:

```text
js/models/task.js
```

the correct path is:

```javascript
"../models/task.js"
```

---

## Module Scope

Variables declared in one module are not automatically global:

```javascript
const secret = "private to this module";
```

Another module cannot access `secret` unless it is exported.

This reduces accidental coupling.

---

## Browser Module Rules

A module script must be loaded with:

```html
<script type="module" src="./js/main.js"></script>
```

Modules are automatically deferred, meaning the browser waits until the document has been parsed before executing the module.

Modules are also subject to origin rules. Run the project through a local HTTP server rather than opening `index.html` directly with `file://`.

---

# Part 4 Reference: `localStorage`

## Saving a String

```javascript
localStorage.setItem("name", "Ada");
```

## Reading a String

```javascript
const name = localStorage.getItem("name");
```

If the key does not exist, the result is:

```javascript
null
```

## Removing a Value

```javascript
localStorage.removeItem("name");
```

## Clearing Everything

```javascript
localStorage.clear();
```

Use `clear()` carefully. It removes every local-storage key for the current origin, including data belonging to other features.

---

# Part 4 Reference: JSON Serialization

## Convert JavaScript Data to JSON

```javascript
const task = {
  title: "Learn JSON",
  completed: false,
};

const text = JSON.stringify(task);
```

The result is a string:

```json
{"title":"Learn JSON","completed":false}
```

## Convert JSON to JavaScript Data

```javascript
const restoredTask = JSON.parse(text);
```

## JSON Limitations

JSON does not preserve:

- Class prototypes.
- Methods.
- `Date` objects.
- `undefined`.
- Functions.
- Symbols.

For example:

```javascript
const task = new Task({
  title: "Serialize a task",
});
```

After:

```javascript
const restored = JSON.parse(JSON.stringify(task));
```

`restored` is not a `Task` instance.

That is why the model defines:

```javascript
Task.fromJSON(value);
```

---

# Part 4 Reference: `sessionStorage`

Use `sessionStorage` for temporary session-level preferences:

```javascript
sessionStorage.setItem("filter", "completed");

const filter = sessionStorage.getItem("filter");
```

The data generally remains while the browser tab session remains, but it is not intended to be permanent application storage.

Good uses include:

- Current filter.
- Temporary wizard progress.
- Unsaved UI preferences.
- Current tab state.

Do not use it as a replacement for a database.

---

# Part 4 Reference: Storage Limitations

Browser storage is useful, but it is not a complete persistence system.

Important limitations include:

- Storage is synchronous.
- Storage capacity is limited.
- Users can clear it.
- Private browsing behavior varies.
- Data is scoped to the browser origin.
- Multiple tabs can modify the same data.
- It should not hold passwords, authentication tokens, or sensitive secrets.
- A browser extension or script running in the same origin may potentially access it.

For larger applications, use:

- A backend database.
- IndexedDB for larger client-side data.
- A server API.
- Authentication and authorization controls.

---

# Part 4 Troubleshooting

## Error: `Cannot use import statement outside a module`

Make sure `index.html` uses:

```html
<script type="module" src="./js/main.js"></script>
```

## Error: `Failed to resolve module specifier`

Check the import path and include `.js`:

```javascript
import { Task } from "../models/task.js";
```

## Error: CORS or `file://` Problems

Do not open the file directly.

Run:

```bash
python3 -m http.server 8000
```

Then open:

```text
http://localhost:8000
```

## Tasks Disappear After Refresh

Check:

1. That `saveTasks()` is called after adding, toggling, deleting, and loading.
2. That the browser is running from the same origin.
3. That `localStorage` was not cleared.
4. That the storage key is consistent:

```javascript
"async-task-manager.tasks.v1"
```

## Stored Data Causes an Error

Inspect the data:

```javascript
localStorage.getItem("async-task-manager.tasks.v1");
```

Remove invalid data:

```javascript
localStorage.removeItem("async-task-manager.tasks.v1");
```

## The Filter Resets

The filter is saved in `sessionStorage`, not `localStorage`.

Inspect it:

```javascript
sessionStorage.getItem("async-task-manager.filter.v1");
```

If the tab session was closed, the preference may have been removed.

---

# Final Architecture Review

The completed request path for adding a task is now:

```text
User submits the form
        ↓
task-form.js captures the event
        ↓
app.js receives the title
        ↓
task-service.js validates and creates a Task
        ↓
storage-service.js serializes and saves it
        ↓
app.js asks task-list.js to render
        ↓
The browser displays the task
```

The asynchronous loading path is:

```text
User clicks Load example tasks
        ↓
app.js starts the operation
        ↓
task-api.js returns a Promise
        ↓
The browser waits without blocking the page
        ↓
The Promise fulfills or rejects
        ↓
app.js updates the service and storage
        ↓
task-list.js renders the result
```

The restoration path is:

```text
Application starts
        ↓
storage-service.js reads localStorage
        ↓
JSON.parse() converts text to JavaScript data
        ↓
Task.fromJSON() validates and reconstructs instances
        ↓
TaskService receives valid Task objects
        ↓
The UI renders them
```

Each layer now has a clear responsibility.

---

# Complete Series Checklist

You have completed the entire series when you can explain the following.

## Part 1: Asynchronous Flow

- Synchronous code runs sequentially.
- Long-running synchronous work blocks the page.
- Browser Web APIs manage timers and other delayed capabilities.
- The event loop coordinates completed asynchronous work.
- Callbacks run after the current synchronous work finishes.
- Error-first callbacks commonly use `(error, result)`.

## Part 2: Promises

- Promises represent future results.
- Promises can be pending, fulfilled, or rejected.
- `.then()` handles success.
- `.catch()` handles failure.
- `.finally()` handles shared cleanup.
- `async` functions return Promises.
- `await` makes Promise workflows easier to read.
- `try`/`catch`/`finally` handles asynchronous control flow.

## Part 3: Objects and Classes

- Objects can inherit through prototypes.
- The prototype chain controls property lookup.
- Factory functions create objects.
- Constructor functions work with `new`.
- Classes provide clearer constructor and prototype syntax.
- Static methods belong to the class.
- `extends` creates subclasses.
- `super()` invokes parent behavior.
- JSON parsing does not restore class prototypes automatically.

## Part 4: Modules and Storage

- Modules expose explicit public dependencies.
- `import` consumes exports.
- `export` defines a module’s public API.
- `localStorage` persists string data across refreshes.
- `sessionStorage` stores temporary session data.
- JSON converts between JavaScript values and strings.
- Stored data must be treated as untrusted input.
- Storage failures require explicit error handling.
- UI, services, models, API code, and utilities should remain separate.
