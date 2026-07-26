# Student Notes  
## Intermediate JavaScript: Asynchronous Flow & Code Organization

These notes provide a concise reference for the complete series. Use them while coding, debugging, and reviewing the final application.

---

# 1. Series Goal

Build a browser-based **Async Task Manager** using:

- Modern JavaScript.
- Callbacks.
- Promises.
- `async`/`await`.
- Prototypes.
- Classes.
- Inheritance.
- ES modules.
- Browser storage.
- DOM events.
- Error handling.
- Accessibility and security practices.

Final architecture:

```text
User interaction
      ↓
UI modules
      ↓
Application coordinator
      ↓
Business services
      ↓
Models, API, and storage
```

---

# 2. Required Tools

- Modern browser.
- Code editor.
- Terminal.
- Python or another local HTTP server.
- Optional: Git.

Start the server from the project root:

```bash
python3 -m http.server 8000
```

Windows:

```powershell
python -m http.server 8000
```

Open:

```text
http://localhost:8000
```

Stop the server:

```text
Ctrl + C
```

---

# 3. Browser Application Layers

## HTML

Defines structure:

```html
<form id="task-form">
  <label for="task-title">Task title</label>
  <input id="task-title" name="taskTitle" />
  <button type="submit">Add task</button>
</form>
```

## CSS

Defines presentation:

```css
.task-completed {
  color: #66728a;
  text-decoration: line-through;
}
```

## JavaScript

Defines behavior:

```javascript
form.addEventListener("submit", (event) => {
  event.preventDefault();
});
```

---

# 4. JavaScript Essentials

## Variables

Use `const` unless reassignment is required:

```javascript
const applicationName = "Async Task Manager";

let currentFilter = "all";
currentFilter = "completed";
```

## Strict Equality

Prefer:

```javascript
value === expected;
value !== unexpected;
```

Avoid relying on loose equality:

```javascript
value == expected;
```

## Functions

```javascript
function add(first, second) {
  return first + second;
}
```

Arrow function:

```javascript
const add = (first, second) => first + second;
```

## Objects

```javascript
const task = {
  id: 1,
  title: "Learn objects",
  completed: false,
};
```

## Arrays

```javascript
const tasks = [];

tasks.push(task);
```

## Common Array Methods

```javascript
const titles = tasks.map(
  (task) => task.title
);

const activeTasks = tasks.filter(
  (task) => !task.completed
);

const task = tasks.find(
  (candidate) => candidate.id === taskId
);
```

## Destructuring

```javascript
const {
  title,
  completed,
} = task;
```

## Spread Syntax

```javascript
const completedTask = {
  ...task,
  completed: true,
};
```

## Optional Chaining

```javascript
const title = response?.data?.task?.title;
```

## Nullish Coalescing

```javascript
const filter = savedFilter ?? "all";
```

---

# 5. DOM Fundamentals

## Select Elements

```javascript
const form = document.querySelector("#task-form");
const taskList = document.querySelector("#task-list");
```

## Validate Required Elements

```javascript
if (!(form instanceof HTMLFormElement)) {
  throw new Error("Task form was not found.");
}
```

## Create Elements

```javascript
const listItem = document.createElement("li");
```

## Set Text Safely

```javascript
listItem.textContent = task.title;
```

Avoid rendering untrusted input with:

```javascript
listItem.innerHTML = task.title;
```

## Add Classes

```javascript
listItem.classList.add("task-completed");
```

## Append Elements

```javascript
taskList.append(listItem);
```

## Clear Children

```javascript
taskList.replaceChildren();
```

---

# 6. Events and Forms

## Event Listener

```javascript
button.addEventListener("click", () => {
  console.log("Clicked");
});
```

## Form Submission

```javascript
form.addEventListener("submit", (event) => {
  event.preventDefault();

  const title = input.value.trim();
});
```

`preventDefault()` stops the browser’s normal form navigation or reload.

## Button Types

Submit button:

```html
<button type="submit">Add task</button>
```

Non-submit action:

```html
<button type="button">Load tasks</button>
```

---

# 7. Synchronous JavaScript

Synchronous code runs in order:

```javascript
console.log("A");
console.log("B");
console.log("C");
```

Output:

```text
A
B
C
```

A long synchronous operation blocks the JavaScript thread:

```javascript
function blockForMilliseconds(duration) {
  const start = Date.now();

  while (Date.now() - start < duration) {
  }
}
```

Blocking work can prevent:

- Clicks.
- Keyboard input.
- DOM updates.
- Screen painting.

---

# 8. Call Stack

The call stack tracks currently executing functions.

```javascript
function first() {
  second();
}

function second() {
  console.log("Inside second");
}

first();
```

Execution conceptually:

```text
first()
  ↓
second()
  ↓
console.log()
```

The last function called is the first function to finish.

---

# 9. Event Loop

The browser coordinates asynchronous work using:

- Call stack.
- Web APIs.
- Task queues.
- Microtask queues.
- Event loop.

Example:

```javascript
console.log("A");

setTimeout(() => {
  console.log("B");
}, 0);

console.log("C");
```

Output:

```text
A
C
B
```

A timer callback cannot interrupt currently executing synchronous code.

---

# 10. Callbacks

A callback is a function passed to another function.

```javascript
function runLater(callback) {
  setTimeout(() => {
    callback("Finished");
  }, 1000);
}

runLater((message) => {
  console.log(message);
});
```

## Error-First Callback Pattern

```javascript
loadTask((error, task) => {
  if (error) {
    console.error(error);
    return;
  }

  renderTask(task);
});
```

Success:

```javascript
callback(null, result);
```

Failure:

```javascript
callback(error, undefined);
```

Always stop after handling an error:

```javascript
if (error) {
  handleError(error);
  return;
}
```

---

# 11. Promises

A Promise represents a future result.

States:

```text
Pending
  ↓
Fulfilled
```

or:

```text
Pending
  ↓
Rejected
```

Create a Promise:

```javascript
function loadTask() {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve({
        id: 1,
        title: "Learn Promises",
      });
    }, 500);
  });
}
```

## Promise Handlers

```javascript
loadTask()
  .then((task) => {
    renderTask(task);
  })
  .catch((error) => {
    showError(error);
  })
  .finally(() => {
    enableButton();
  });
```

## Promise Chain Rule

Return the next Promise:

```javascript
getUser()
  .then((user) => {
    return getProjects(user.id);
  })
  .then((projects) => {
    console.log(projects);
  });
```

Not:

```javascript
getUser()
  .then((user) => {
    getProjects(user.id);
  });
```

---

# 12. `async` and `await`

An `async` function always returns a Promise:

```javascript
async function getMessage() {
  return "Hello";
}
```

Use `await` inside an async function:

```javascript
async function loadTasks() {
  const tasks = await fetchTasks();
  renderTasks(tasks);
}
```

Handle errors:

```javascript
async function loadTasks() {
  try {
    const tasks = await fetchTasks();
    renderTasks(tasks);
  } catch (error) {
    showError(error);
  } finally {
    restoreInterface();
  }
}
```

`await` pauses only the current async function. It does not block the browser.

---

# 13. Promise Composition

## Sequential Work

Use when the second operation depends on the first:

```javascript
const user = await loadUser();
const projects = await loadProjects(user.id);
```

## Parallel Work

Use when operations are independent:

```javascript
const [tasks, users] = await Promise.all([
  loadTasks(),
  loadUsers(),
]);
```

## `Promise.allSettled()`

Use when every operation should report independently:

```javascript
const results = await Promise.allSettled([
  loadTasks(),
  loadNotifications(),
]);
```

## Cancellation

```javascript
const controller = new AbortController();

fetch(url, {
  signal: controller.signal,
});

controller.abort();
```

Handle cancellation:

```javascript
catch (error) {
  if (error.name === "AbortError") {
    return;
  }

  showError(error);
}
```

---

# 14. Error Handling

Throw proper `Error` objects:

```javascript
throw new Error("Task title is required.");
```

Use custom errors when useful:

```javascript
class StorageError extends Error {
  constructor(message, options = {}) {
    super(message, options);
    this.name = "StorageError";
  }
}
```

Normalize unknown thrown values:

```javascript
function normalizeError(value) {
  if (value instanceof Error) {
    return value;
  }

  if (typeof value === "string") {
    return new Error(value);
  }

  return new Error("Unknown error.");
}
```

Always use cleanup:

```javascript
try {
  await operation();
} catch (error) {
  handleError(error);
} finally {
  restoreInterface();
}
```

---

# 15. Prototypes

JavaScript uses prototype-based inheritance.

If a property is not found directly on an object, JavaScript searches its prototype chain.

```javascript
Object.getPrototypeOf(task);
```

For a class instance:

```javascript
Object.getPrototypeOf(task) === Task.prototype;
```

Shared methods generally live on the prototype rather than being copied into every instance.

---

# 16. Factory Functions

A factory function creates and returns an object:

```javascript
function createTask(title) {
  return {
    id: Date.now(),
    title,
    completed: false,
  };
}
```

Use:

```javascript
const task = createTask("Learn factories");
```

Factory functions do not require `new`.

---

# 17. Constructor Functions

Older object-oriented JavaScript commonly used constructor functions:

```javascript
function Task(title) {
  this.title = title;
  this.completed = false;
}

Task.prototype.complete = function () {
  this.completed = true;
};

const task = new Task("Learn constructors");
```

`new`:

1. Creates an object.
2. Connects it to the constructor prototype.
3. Binds `this`.
4. Returns the new object.

---

# 18. Classes

```javascript
class Task {
  constructor({
    id,
    title,
    completed = false,
  }) {
    this.id = id;
    this.title = title;
    this.completed = completed;
  }

  complete() {
    this.completed = true;
  }

  reopen() {
    this.completed = false;
  }

  isCompleted() {
    return this.completed;
  }
}
```

Create an instance:

```javascript
const task = new Task({
  id: 1,
  title: "Learn classes",
});
```

Check its type:

```javascript
task instanceof Task;
```

---

# 19. Static Methods

Static methods belong to the class:

```javascript
class Task {
  static fromJSON(value) {
    return new Task(value);
  }
}
```

Use:

```javascript
const task = Task.fromJSON(value);
```

Do not use:

```javascript
task.fromJSON(value);
```

unless the method is an instance method.

---

# 20. Inheritance

```javascript
class ImportedTask extends Task {
  constructor({
    source,
    ...taskData
  }) {
    super(taskData);
    this.source = source;
  }

  getStatusLabel() {
    return `${super.getStatusLabel()} · ` +
      `Imported from ${this.source}`;
  }
}
```

Important rules:

- `extends` creates inheritance.
- `super()` calls the parent constructor.
- `super.method()` calls the parent method.
- `this` cannot be used before `super()` in a subclass constructor.

---

# 21. Task Model

A domain model represents application data and rules.

```javascript
export class Task {
  constructor({
    id = Task.createId(),
    title,
    completed = false,
    createdAt = new Date(),
  }) {
    if (!Number.isInteger(id) || id < 0) {
      throw new TypeError("Invalid task ID.");
    }

    const normalizedTitle = title.trim();

    if (normalizedTitle.length === 0) {
      throw new Error("Task title cannot be empty.");
    }

    if (normalizedTitle.length > 120) {
      throw new Error("Task title is too long.");
    }

    this.id = id;
    this.title = normalizedTitle;
    this.completed = completed;
    this.createdAt = new Date(createdAt);
  }

  complete() {
    this.completed = true;
  }

  toggleCompletion() {
    this.completed = !this.completed;
  }

  toJSON() {
    return {
      id: this.id,
      title: this.title,
      completed: this.completed,
      createdAt: this.createdAt.toISOString(),
    };
  }

  static fromJSON(value) {
    return new Task({
      id: value.id,
      title: value.title,
      completed: value.completed,
      createdAt: value.createdAt,
    });
  }
}
```

---

# 22. Modules

Enable browser modules:

```html
<script
  type="module"
  src="./js/main.js"
></script>
```

Export:

```javascript
export class Task {
}
```

Import:

```javascript
import { Task } from "./models/task.js";
```

From `js/services/` to `js/models/`:

```javascript
import { Task } from "../models/task.js";
```

Include `.js` in browser import paths.

---

# 23. Module Responsibilities

## `main.js`

Starts the application:

```javascript
const app = new App(elements);
app.start();
```

## `app.js`

Coordinates workflows:

```text
UI event → service → persistence → render
```

## `models/task.js`

Defines task data and behavior.

## `services/task-service.js`

Manages task operations.

## `services/storage-service.js`

Saves and restores data.

## `api/task-api.js`

Loads asynchronous external or simulated data.

## `ui/`

Renders the page and binds browser events.

## `utils/`

Contains reusable validation and error helpers.

---

# 24. Browser Storage

## `localStorage`

Persistent key-value storage:

```javascript
localStorage.setItem("theme", "dark");

const theme = localStorage.getItem("theme");

localStorage.removeItem("theme");
```

## `sessionStorage`

Temporary tab-session storage:

```javascript
sessionStorage.setItem(
  "filter",
  "completed"
);
```

## JSON Storage

```javascript
localStorage.setItem(
  "tasks",
  JSON.stringify(tasks)
);
```

Restore:

```javascript
const rawTasks =
  localStorage.getItem("tasks");

const tasks = rawTasks === null
  ? []
  : JSON.parse(rawTasks);
```

Storage values are strings only.

---

# 25. Storage Safety

Stored data can be:

- Missing.
- Malformed.
- Outdated.
- Manually changed.
- Created by an older application version.

Safe pattern:

```javascript
function loadTasks() {
  const rawValue = localStorage.getItem(
    "async-task-manager.tasks.v1"
  );

  if (rawValue === null) {
    return [];
  }

  let parsedValue;

  try {
    parsedValue = JSON.parse(rawValue);
  } catch (error) {
    throw new StorageError(
      "Stored tasks are not valid JSON.",
      { cause: error }
    );
  }

  if (!Array.isArray(parsedValue)) {
    throw new StorageError(
      "Stored tasks must be an array."
    );
  }

  return parsedValue.map(Task.fromJSON);
}
```

---

# 26. API Requests

Basic request:

```javascript
const response = await fetch("/api/tasks");
```

Check status:

```javascript
if (!response.ok) {
  throw new Error(
    `HTTP ${response.status}`
  );
}
```

Read JSON:

```javascript
const data = await response.json();
```

Send JSON:

```javascript
await fetch("/api/tasks", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    Accept: "application/json",
  },
  body: JSON.stringify({
    title: "Learn APIs",
  }),
});
```

---

# 27. API Validation

Valid JSON is not automatically valid task data.

Validate:

```javascript
function validateTaskRecord(value) {
  if (
    typeof value !== "object" ||
    value === null ||
    !Number.isInteger(value.id) ||
    typeof value.title !== "string" ||
    typeof value.completed !== "boolean"
  ) {
    throw new Error(
      "Invalid task record."
    );
  }

  return value;
}
```

Validate arrays:

```javascript
if (!Array.isArray(responseData)) {
  throw new Error(
    "Expected a task array."
  );
}
```

---

# 28. Debugging

## Console

```javascript
console.log(value);
console.warn(message);
console.error(error);
console.table(tasks);
```

## Breakpoint

```javascript
debugger;
```

## Common Debugging Sequence

```text
Reproduce
  ↓
Read first error
  ↓
Inspect value
  ↓
Set breakpoint
  ↓
Inspect call stack
  ↓
Check DOM, network, or storage
  ↓
Make one change
  ↓
Verify
```

## Inspect Storage

```javascript
localStorage.getItem(
  "async-task-manager.tasks.v1"
);
```

## Inspect Current Origin

```javascript
location.origin;
```

---

# 29. Testing

## Arrange, Act, Assert

```javascript
function testAddingTask() {
  // Arrange
  const service = new TaskService();

  // Act
  const task = service.add("Test task");

  // Assert
  console.assert(
    task.title === "Test task",
    "Title should be stored"
  );
}
```

## Important Test Categories

- Valid input.
- Invalid input.
- Success path.
- Failure path.
- Persistence.
- Malformed data.
- Loading cleanup.
- Duplicate operations.
- Keyboard access.
- Unsafe HTML input.

## Async Test

```javascript
async function testLoading() {
  const tasks = await fetchExampleTasks();

  console.assert(
    tasks.length === 3,
    "Expected three tasks"
  );
}
```

---

# 30. Accessibility

## Semantic HTML

```html
<main>
  <section>
    <h2>Tasks</h2>
  </section>
</main>
```

## Labels

```html
<label for="task-title">Task title</label>
<input id="task-title" />
```

## Status Updates

```html
<p
  role="status"
  aria-live="polite"
>
  Loading tasks...
</p>
```

## Visible Focus

```css
button:focus-visible,
input:focus-visible,
select:focus-visible {
  outline: 3px solid #173f9f;
  outline-offset: 3px;
}
```

## Keyboard Requirements

- Every control is reachable with Tab.
- Buttons activate with Enter or Space.
- Focus remains visible.
- Dynamic updates do not unexpectedly lose focus.
- Color is not the only status signal.

---

# 31. Security

## Safe Rendering

Use:

```javascript
element.textContent = userInput;
```

Avoid:

```javascript
element.innerHTML = userInput;
```

## Do Not Store Secrets

Never place these in browser storage:

- Passwords.
- Private API keys.
- Database credentials.
- Sensitive tokens.
- Encryption keys.

## Validate External Data

Validate:

- Form input.
- API responses.
- Imported files.
- Browser storage.
- URL parameters.

## Production

Use:

- HTTPS.
- Content Security Policy.
- Secure headers.
- Server-side authorization.
- Controlled logging.
- Dependency review.

Client-side validation improves user experience. It does not enforce authorization.

---

# 32. Git Workflow

Initialize:

```bash
git init
```

Check:

```bash
git status
```

Stage:

```bash
git add .
```

Review:

```bash
git diff --staged
```

Commit:

```bash
git commit -m "Add task persistence"
```

Create branch:

```bash
git switch -c add-search
```

Switch:

```bash
git switch main
```

Merge:

```bash
git merge add-search
```

View history:

```bash
git log --oneline --decorate --graph --all
```

Never commit:

```text
.env
passwords
API keys
private certificates
access tokens
```

---

# 33. Final Architecture

```text
index.html
    ↓
main.js
    ↓
app.js
    ├── task-api.js
    ├── task-service.js
    ├── storage-service.js
    ├── status-message.js
    ├── task-form.js
    ├── task-list.js
    ├── errors.js
    └── validation.js
```

Adding a task:

```text
Submit form
    ↓
Form module reads title
    ↓
App receives input
    ↓
TaskService validates and creates Task
    ↓
StorageService saves JSON
    ↓
App renders task list
```

Loading tasks:

```text
Click load
    ↓
Disable button
    ↓
API returns Promise
    ↓
Await response
    ↓
Validate Task instances
    ↓
Save tasks
    ↓
Render list
    ↓
Restore button in finally
```

Restoring tasks:

```text
Read localStorage
    ↓
Parse JSON
    ↓
Validate array
    ↓
Task.fromJSON()
    ↓
TaskService receives instances
    ↓
Render visible tasks
```

---

# 34. Final Completion Checklist

- [ ] Project runs through a local server.
- [ ] HTML structure is semantic.
- [ ] CSS is separated from JavaScript.
- [ ] DOM elements are selected safely.
- [ ] Form submission is handled.
- [ ] User input is validated.
- [ ] User text is rendered with `textContent`.
- [ ] Synchronous execution is understood.
- [ ] Blocking behavior is understood.
- [ ] Event loop behavior is understood.
- [ ] Callbacks are understood.
- [ ] Promises are understood.
- [ ] `async`/`await` is understood.
- [ ] Errors are handled.
- [ ] Cleanup uses `finally`.
- [ ] Prototypes are understood.
- [ ] Classes are implemented.
- [ ] Inheritance is understood.
- [ ] Modules are used.
- [ ] Tasks persist in `localStorage`.
- [ ] Filter preferences use `sessionStorage`.
- [ ] Stored JSON is validated.
- [ ] API responses are validated.
- [ ] Developer Tools are used for debugging.
- [ ] Core behavior is tested.
- [ ] Accessibility has been reviewed.
- [ ] Security risks have been reviewed.
- [ ] Git checkpoints have been created.
