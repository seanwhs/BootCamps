# Appendix E: Debugging Guide

Debugging is the process of finding and correcting problems in software.

A bug is not always caused by a typo. It may come from:

- Incorrect assumptions.
- Data with an unexpected shape.
- An asynchronous operation finishing later than expected.
- A missing DOM element.
- An incorrect module path.
- Browser storage containing invalid data.
- A state update that was not followed by rendering.
- A failure that was caught but not displayed clearly.

This appendix provides a systematic debugging process for the Async Task Manager and similar browser applications.

---

# 1. A Reliable Debugging Process

When something does not work, use this sequence:

```text
1. Reproduce the problem.
2. Describe the expected behavior.
3. Describe the actual behavior.
4. Read the first console error.
5. Find the file and line number.
6. Inspect the values involved.
7. Form one specific hypothesis.
8. Make one focused change.
9. Test again.
10. Confirm that you did not create a new problem.
```

Avoid changing many unrelated lines at once. If five changes are made together, it becomes difficult to know which change fixed or caused the behavior.

---

# 2. Open Developer Tools

Most browser debugging happens in Developer Tools.

## Chrome, Edge, or Firefox

Common shortcuts:

```text
Windows/Linux: F12 or Ctrl + Shift + I
macOS: Cmd + Option + I
```

Open these tabs:

- **Console** — JavaScript errors and logs.
- **Sources** or **Debugger** — inspect and pause code.
- **Network** — inspect requests and responses.
- **Application** or **Storage** — inspect browser storage.
- **Elements** or **Inspector** — inspect the DOM and CSS.

---

# 3. Read Console Errors

A console error often contains:

1. Error type.
2. Error message.
3. File name.
4. Line and column number.
5. A stack trace.

Example:

```text
Uncaught TypeError: Cannot read properties of null
    at main.js:12:19
```

Interpret it as:

```text
TypeError
The code attempted to use a property on null.
File: main.js
Line: 12
Column: 19
```

Open the referenced file and inspect the exact line.

The first error is usually the most important. Later errors may be consequences of the first failure.

---

# 4. Add Diagnostic Logging

Use `console.log()` to inspect values:

```javascript
console.log("Current tasks:", tasks);
console.log("Current filter:", currentFilter);
console.log("Loading state:", isLoading);
```

Include labels so output is easy to understand:

```javascript
console.log({
  tasks,
  currentFilter,
  isLoading,
});
```

This is usually clearer than:

```javascript
console.log(tasks, currentFilter, isLoading);
```

## Log Function Boundaries

```javascript
function addTask(title) {
  console.log("addTask received:", title);

  const task = taskService.add(title);

  console.log("Created task:", task);

  saveTasks(taskService.getAll());

  console.log("Tasks saved.");
}
```

This helps determine where the expected behavior stops.

## Use `console.table()`

Arrays of objects are often easier to inspect as tables:

```javascript
console.table(tasks);
```

Example output:

```text
┌─────────┬────┬──────────────────────┬───────────┐
│ (index) │ id │ title                │ completed │
├─────────┼────┼──────────────────────┼───────────┤
│ 0       │ 1  │ 'Learn modules'      │ false     │
│ 1       │ 2  │ 'Learn storage'      │ true      │
└─────────┴────┴──────────────────────┴───────────┘
```

---

# 5. Use Assertions

Assertions report when an assumption is false.

```javascript
console.assert(
  Array.isArray(tasks),
  "tasks should be an array"
);
```

Another example:

```javascript
console.assert(
  task instanceof Task,
  "task should be a Task instance"
);
```

Assertions are useful for checking assumptions at module boundaries.

---

# 6. Use `debugger`

The `debugger` statement pauses execution when Developer Tools are open.

```javascript
function handleAddTask(title) {
  debugger;

  const task = taskService.add(title);

  saveTasks(taskService.getAll());
}
```

When execution pauses, inspect:

- Local variables.
- Function arguments.
- The call stack.
- Scope variables.
- The current DOM state.

Remove temporary `debugger` statements after debugging.

---

# 7. Breakpoints

Instead of adding `debugger`, click a line number in the Sources or Debugger panel.

A breakpoint pauses execution before that line runs.

Useful breakpoint locations include:

- Event handlers.
- Before calling a service.
- After receiving asynchronous data.
- Before saving storage.
- Before rendering.
- Inside error handlers.

Use conditional breakpoints for specific cases:

```javascript
task.id === 12345
```

This prevents the debugger from pausing for every task.

---

# 8. Inspect the Call Stack

When execution pauses, the call stack shows how the current function was reached.

Example:

```text
handleAddTask
App.bindEvents callback
HTMLFormElement.dispatchEvent
```

This answers questions such as:

- Which event triggered this?
- Which function called the failing function?
- Did the application reach the expected layer?
- Was the function called more than once?

The call stack is especially valuable for duplicate event handlers and unexpected asynchronous callbacks.

---

# 9. Common Error: `Cannot Read Properties of Null`

## The Error

```text
TypeError: Cannot read properties of null
```

## The Cause

A DOM query returned `null`:

```javascript
const button = document.querySelector("#missing-button");

button.addEventListener("click", handleClick);
```

The element does not exist, so `button` is `null`.

## The Fix

Check that the HTML contains the matching ID:

```html
<button id="missing-button" type="button">
  Click me
</button>
```

The selector must match exactly:

```javascript
document.querySelector("#missing-button");
```

IDs are case-sensitive.

## Diagnostic Version

```javascript
const loadTasksButton = document.querySelector(
  "#load-tasks-button"
);

if (!loadTasksButton) {
  throw new Error(
    "The load tasks button was not found."
  );
}
```

This produces a clearer error than allowing a later method call to fail.

---

# 10. Common Error: `querySelector` Returns the Wrong Element

## The Problem

```javascript
const input = document.querySelector("input");
```

If the page has multiple inputs, the first one is returned, which may not be the intended input.

## The Fix

Use a specific selector:

```javascript
const titleInput = document.querySelector(
  "#task-title"
);
```

Or:

```javascript
const titleInput = document.querySelector(
  'input[name="taskTitle"]'
);
```

Prefer stable, meaningful selectors.

---

# 11. Common Error: `Cannot Use Import Statement Outside a Module`

## The Error

```text
Uncaught SyntaxError:
Cannot use import statement outside a module
```

## The Cause

The browser is loading a file as a classic script:

```html
<script src="./js/main.js"></script>
```

But `main.js` contains:

```javascript
import { App } from "./app.js";
```

## The Fix

Mark the script as a module:

```html
<script type="module" src="./js/main.js"></script>
```

## Verification

Refresh the page and confirm that the import error disappears.

---

# 12. Common Error: Failed to Resolve Module Specifier

## The Error

```text
Failed to resolve module specifier
```

## Common Causes

- Missing `./` or `../`.
- Incorrect directory name.
- Incorrect filename.
- Missing `.js` extension.
- Incorrect capitalization.

Incorrect:

```javascript
import { Task } from "models/task";
```

Correct:

```javascript
import { Task } from "./models/task.js";
```

From a service directory:

```javascript
import { Task } from "../models/task.js";
```

## Verify the Relative Path

If the importing file is:

```text
js/services/task-service.js
```

and the target is:

```text
js/models/task.js
```

the path is:

```text
../models/task.js
```

The path starts from the importing file’s directory.

---

# 13. Common Error: The Page Works with `file://` but Modules Fail

## The Problem

Opening the file directly may produce module or CORS errors:

```text
file:///path/to/async-task-manager/index.html
```

## The Fix

Use a local server.

From the project root:

```bash
python3 -m http.server 8000
```

Windows PowerShell:

```powershell
python -m http.server 8000
```

Open:

```text
http://localhost:8000
```

## Verification

The address bar should begin with:

```text
http://localhost:8000
```

not:

```text
file://
```

---

# 14. Common Error: `is Not a Function`

## The Error

```text
TypeError: task.complete is not a function
```

## Possible Cause

The value is an ordinary object rather than a `Task` instance:

```javascript
const task = JSON.parse(rawTask);
task.complete();
```

JSON parsing does not restore class methods.

## The Fix

Use the model’s restoration method:

```javascript
const value = JSON.parse(rawTask);
const task = Task.fromJSON(value);

task.complete();
```

## Diagnose the Value

```javascript
console.log(task);
console.log(task instanceof Task);
console.log(typeof task.complete);
```

Expected output for a valid instance:

```text
true
function
```

---

# 15. Common Error: `task.isCompleted is Not a Function`

## The Cause

The task service expects `Task` instances, but it received plain objects.

Incorrect:

```javascript
taskService.replaceAll([
  {
    id: 1,
    title: "Plain object",
    completed: false,
  },
]);
```

The service later calls:

```javascript
task.isCompleted();
```

That method does not exist on the plain object.

## The Fix

Create a `Task` instance:

```javascript
taskService.replaceAll([
  new Task({
    id: 1,
    title: "Task instance",
    completed: false,
  }),
]);
```

Or reconstruct stored values:

```javascript
const tasks = storedValues.map((value) => {
  return Task.fromJSON(value);
});
```

---

# 16. Common Error: `Unexpected Token` from JSON

## The Error

```text
SyntaxError: Unexpected token ...
```

## The Cause

Stored text is not valid JSON:

```javascript
const rawValue = localStorage.getItem("tasks");

const tasks = JSON.parse(rawValue);
```

The storage may contain:

```text
{invalid json
```

## Diagnose the Raw Value

```javascript
const rawValue = localStorage.getItem(
  "async-task-manager.tasks.v1"
);

console.log(rawValue);
```

## Clean Up Invalid Data

```javascript
localStorage.removeItem(
  "async-task-manager.tasks.v1"
);
```

Refresh the page afterward.

## Better Application Handling

```javascript
try {
  const tasks = JSON.parse(rawValue);
} catch (error) {
  console.error("Stored task data is invalid:", error);
}
```

---

# 17. Common Error: Tasks Disappear After Refresh

## Check 1: Was `saveTasks()` called?

After adding:

```javascript
const task = taskService.add(title);

saveTasks(taskService.getAll());
```

After toggling:

```javascript
taskService.toggle(taskId);

saveTasks(taskService.getAll());
```

After deleting:

```javascript
taskService.remove(taskId);

saveTasks(taskService.getAll());
```

## Check 2: Is the correct origin being used?

These have separate storage:

```text
http://localhost:8000
http://127.0.0.1:8000
```

Use one consistently.

## Check 3: Inspect storage

```javascript
localStorage.getItem(
  "async-task-manager.tasks.v1"
);
```

If it returns `null`, no data was saved.

## Check 4: Is loading happening after saving?

A startup function may accidentally overwrite restored tasks:

```javascript
loadTasks();
taskService.replaceAll([]);
```

Make sure default tasks are not applied after restoration.

---

# 18. Common Error: Tasks Save but Do Not Restore

## Possible Cause 1: Invalid JSON Shape

The stored value may be an object instead of an array:

```json
{
  "tasks": []
}
```

But the loader expects:

```json
[]
```

Check:

```javascript
const parsed = JSON.parse(rawValue);

console.log(Array.isArray(parsed));
```

## Possible Cause 2: Invalid Task Records

A task may fail model validation:

```javascript
{
  "id": "wrong",
  "title": "",
  "completed": "false"
}
```

Inspect each record:

```javascript
for (const value of parsed) {
  try {
    console.log(Task.fromJSON(value));
  } catch (error) {
    console.warn("Invalid task:", value, error);
  }
}
```

## Possible Cause 3: Dates

A stored date is text. The model must convert it:

```javascript
const normalizedCreatedAt =
  createdAt instanceof Date
    ? createdAt
    : new Date(createdAt);
```

---

# 19. Common Error: `localStorage` Is Empty

## Check the Current Origin

In the console:

```javascript
location.origin;
```

Then inspect storage for that exact origin in Developer Tools.

## Check the Key

```javascript
Object.keys(localStorage);
```

The expected key is:

```text
async-task-manager.tasks.v1
```

## Check Whether Another Function Removed It

Search the code for:

```javascript
removeItem
clear()
```

A broad call can remove more than intended:

```javascript
localStorage.clear();
```

Prefer:

```javascript
localStorage.removeItem(
  "async-task-manager.tasks.v1"
);
```

---

# 20. Common Error: Button Does Nothing

## Step 1: Confirm the Event Listener Is Bound

Add a temporary log:

```javascript
loadTasksButton.addEventListener("click", () => {
  console.log("Load button clicked.");
  this.handleLoadExampleTasks();
});
```

If the log does not appear:

- The selector may be wrong.
- The listener may not be bound.
- Another element may cover the button.
- The script may have failed before reaching the binding.

## Step 2: Check the Button Type

Inside a form, a button defaults to submit behavior.

Use:

```html
<button type="button">
  Load tasks
</button>
```

For a form submission button, use:

```html
<button type="submit">
  Add task
</button>
```

## Step 3: Check Earlier Errors

If module initialization failed, later event listeners may never be registered.

Fix the first console error before investigating the button.

---

# 21. Common Error: Form Reloads the Page

## The Problem

The browser’s default form behavior reloads or navigates the page.

## The Fix

Prevent the default event:

```javascript
form.addEventListener("submit", (event) => {
  event.preventDefault();

  handleSubmit();
});
```

## Verification

Submit the form and confirm:

- The URL does not change.
- The page does not reload.
- The task is added through JavaScript.

---

# 22. Common Error: Empty Input Is Accepted

## The Problem

Whitespace is technically a string:

```javascript
"   "
```

Checking only the type is insufficient:

```javascript
typeof title === "string";
```

## The Fix

Normalize first:

```javascript
const normalizedTitle = title.trim();

if (normalizedTitle.length === 0) {
  throw new Error("Task title cannot be empty.");
}
```

Also enforce a maximum length:

```javascript
if (normalizedTitle.length > 120) {
  throw new Error(
    "Task title cannot exceed 120 characters."
  );
}
```

---

# 23. Common Error: User Input Appears as HTML

## The Problem

Using `innerHTML` with user input can create a cross-site scripting vulnerability.

Unsafe:

```javascript
element.innerHTML = task.title;
```

## The Fix

Use `textContent`:

```javascript
element.textContent = task.title;
```

For the final task manager:

```javascript
title.textContent = task.title;
```

This displays the input as text.

---

# 24. Common Error: Loading Button Stays Disabled

## The Cause

The button is re-enabled only in the success path:

```javascript
try {
  await loadTasks();
  loadButton.disabled = false;
} catch (error) {
  showError(error);
}
```

If loading fails, the reset line is skipped.

## The Fix

Use `finally`:

```javascript
try {
  await loadTasks();
} catch (error) {
  showError(error);
} finally {
  loadButton.disabled = false;
}
```

If a loading guard is used, reset it too:

```javascript
finally {
  this.isLoading = false;
  this.loadTasksButton.disabled = false;
}
```

---

# 25. Common Error: Unhandled Promise Rejection

## The Problem

A Promise rejects without a handler:

```javascript
loadTasks();
```

## The Fix with `.catch()`

```javascript
loadTasks().catch((error) => {
  console.error(error);
});
```

## The Fix with `try`/`catch`

```javascript
async function start() {
  try {
    await loadTasks();
  } catch (error) {
    console.error(error);
  }
}

start();
```

## Global Diagnostic Handler

During development, you can listen for unhandled rejections:

```javascript
window.addEventListener(
  "unhandledrejection",
  (event) => {
    console.error(
      "Unhandled Promise rejection:",
      event.reason
    );
  }
);
```

This is useful for finding forgotten error handlers, but individual operations should still handle errors intentionally.

---

# 26. Common Error: `fetch()` Does Not Report a Server Error

## The Problem

`fetch()` generally rejects for network failures, but not for ordinary HTTP error statuses.

This may fulfill:

```javascript
const response = await fetch("/missing-page");
```

## The Fix

Check `response.ok`:

```javascript
const response = await fetch("/api/tasks");

if (!response.ok) {
  throw new Error(
    `Request failed with HTTP ${response.status}.`
  );
}
```

Then parse the body:

```javascript
const data = await response.json();
```

---

# 27. Common Error: Asynchronous Results Arrive Out of Order

## The Problem

Two operations start:

```javascript
searchTasks("java");
searchTasks("javascript");
```

The first request may finish after the second and overwrite the newer results.

## Fix with Request IDs

```javascript
let latestRequestId = 0;

async function search(query) {
  const requestId = ++latestRequestId;
  const results = await fetchSearchResults(query);

  if (requestId !== latestRequestId) {
    return;
  }

  renderResults(results);
}
```

## Fix with `AbortController`

```javascript
let activeController;

async function search(query) {
  activeController?.abort();

  activeController = new AbortController();

  try {
    const response = await fetch(
      `/api/search?q=${encodeURIComponent(query)}`,
      {
        signal: activeController.signal,
      }
    );

    const results = await response.json();
    renderResults(results);
  } catch (error) {
    if (error.name === "AbortError") {
      return;
    }

    showError(error);
  }
}
```

---

# 28. Common Error: `this` Is Undefined

## The Problem

A method loses its object context when passed as a callback:

```javascript
class TaskController {
  constructor() {
    this.name = "Controller";
  }

  handleClick() {
    console.log(this.name);
  }
}

const controller = new TaskController();

button.addEventListener(
  "click",
  controller.handleClick
);
```

Depending on the environment, `this` may not refer to `controller`.

## Fix with an Arrow Function

```javascript
button.addEventListener("click", () => {
  controller.handleClick();
});
```

## Fix with `bind`

```javascript
button.addEventListener(
  "click",
  controller.handleClick.bind(controller)
);
```

---

# 29. Common Error: Duplicate Event Listeners

## The Problem

An initialization function runs twice:

```javascript
app.start();
app.start();
```

Each call may register another listener.

One click can then add two tasks or start two requests.

## Diagnose

Add a log:

```javascript
console.log("Binding application events.");
```

If it appears multiple times, startup may be running more than once.

## Prevent Repeated Startup

```javascript
class App {
  constructor() {
    this.hasStarted = false;
  }

  start() {
    if (this.hasStarted) {
      return;
    }

    this.hasStarted = true;

    this.bindEvents();
    this.render();
  }
}
```

---

# 30. Common Error: The UI State and Data State Differ

## The Problem

The data changes but the DOM does not:

```javascript
taskService.toggle(taskId);

// Missing render call.
```

## The Fix

Render after state changes:

```javascript
taskService.toggle(taskId);
saveTasks(taskService.getAll());
render();
```

A useful architecture treats the data as the source of truth:

```text
Update application state
        ↓
Persist state if needed
        ↓
Render visible state
```

Do not make independent DOM changes that contradict the task data.

---

# 31. Common Error: Filtered List Does Not Update

## The Problem

The filter changes, but the application continues rendering all tasks:

```javascript
renderTaskList(
  taskList,
  taskService.getAll(),
  handlers
);
```

## The Fix

Apply the current filter:

```javascript
const visibleTasks =
  taskService.getByFilter(currentFilter);

renderTaskList(
  taskList,
  visibleTasks,
  handlers
);
```

Also ensure that `currentFilter` is updated before rendering:

```javascript
currentFilter = selectedFilter;
render();
```

---

# 32. Common Error: Delete Appears to Work but Returns After Refresh

## The Problem

The task is removed from the service but not from storage.

```javascript
taskService.remove(taskId);
render();
```

## The Fix

Persist after deletion:

```javascript
taskService.remove(taskId);
saveTasks(taskService.getAll());
render();
```

The order should generally be:

```text
Modify service state
        ↓
Save updated state
        ↓
Render updated state
```

If saving fails, decide whether the UI should still display the change or roll back the state.

---

# 33. Common Error: A Failed Save Leaves the Application Inconsistent

Suppose this happens:

```javascript
taskService.add(title);
saveTasks(taskService.getAll());
render();
```

If `saveTasks()` throws, the service has changed but the browser storage has not.

A more deliberate approach:

```javascript
handleAddTask(title) {
  const previousTasks =
    this.taskService.getAll();

  try {
    const task = this.taskService.add(title);

    this.persistTasks();
    this.render();

    this.status.show(
      `Added task: ${task.title}`,
      "success"
    );
  } catch (error) {
    this.taskService.replaceAll(previousTasks);

    this.status.show(
      "The task could not be saved.",
      "error"
    );
  }
}
```

This restores the previous state if persistence fails.

Whether rollback is required depends on the application’s consistency requirements.

---

# 34. Network Debugging

Open the **Network** tab before performing the operation.

Inspect:

- Request URL.
- Request method.
- Request headers.
- Request payload.
- Response status.
- Response headers.
- Response body.
- Timing.
- Whether the request was cancelled.

Useful filters:

```text
Fetch/XHR
```

If no request appears:

- The function may not have run.
- The URL may be constructed incorrectly.
- A validation guard may have returned early.
- The code may have failed before calling `fetch()`.

If the request appears but fails:

- Inspect the status.
- Inspect the response body.
- Check the server logs.
- Verify CORS configuration.
- Verify authentication requirements.

---

# 35. Debugging Network Request URLs

Log the final URL:

```javascript
const url = `/api/tasks?filter=${encodeURIComponent(
  filter
)}`;

console.log("Request URL:", url);

const response = await fetch(url);
```

Always encode user-provided query values:

```javascript
const query = encodeURIComponent(
  searchInput.value
);

const response = await fetch(
  `/api/tasks?search=${query}`
);
```

This prevents spaces and special characters from producing malformed URLs.

---

# 36. Debugging Storage

Inspect all keys:

```javascript
console.log(Object.keys(localStorage));
console.log(Object.keys(sessionStorage));
```

Inspect the application task value:

```javascript
const rawTasks = localStorage.getItem(
  "async-task-manager.tasks.v1"
);

console.log(rawTasks);
```

Inspect the parsed value:

```javascript
try {
  const parsedTasks = JSON.parse(rawTasks);
  console.table(parsedTasks);
} catch (error) {
  console.error(
    "Could not parse stored tasks:",
    error
  );
}
```

Inspect the origin:

```javascript
console.log(location.origin);
```

This is useful when storage seems to be missing unexpectedly.

---

# 37. Resetting Application State

During development, reset all task data:

```javascript
localStorage.removeItem(
  "async-task-manager.tasks.v1"
);

sessionStorage.removeItem(
  "async-task-manager.filter.v1"
);

location.reload();
```

Avoid using:

```javascript
localStorage.clear();
```

unless you intentionally want to remove every local-storage key for the current origin.

---

# 38. Debugging with a Minimal Reproduction

If the complete application is difficult to diagnose, reduce the problem.

For example, test storage independently:

```javascript
localStorage.setItem("debug", "value");

console.log(
  localStorage.getItem("debug")
);
```

Test the model independently:

```javascript
const task = new Task({
  title: "Debug model",
});

console.log(task);
```

Test the API independently:

```javascript
try {
  const tasks = await fetchExampleTasks();
  console.table(tasks);
} catch (error) {
  console.error(error);
}
```

Test the DOM independently:

```javascript
const taskList =
  document.querySelector("#task-list");

console.log(taskList);
```

This isolates the failing layer.

---

# 39. Debugging Checklist by Layer

## HTML

Check:

- Required IDs exist.
- Button types are correct.
- Form input names match JavaScript selectors.
- Script path is correct.
- Script uses `type="module"`.

## CSS

Check:

- Expected classes are added.
- A more specific selector is not overriding the style.
- The element is not hidden.
- The browser is not applying a media query unexpectedly.

## Entry Point

Check:

- `main.js` loads.
- Imports resolve.
- The application is constructed.
- `app.start()` executes.

## UI Modules

Check:

- DOM elements are valid.
- Event listeners are registered.
- Callbacks are invoked with expected values.
- User content uses `textContent`.

## Service Layer

Check:

- Task operations modify the correct collection.
- IDs are compared using the correct type.
- Filters return the expected tasks.
- Errors are thrown for missing tasks.

## Model Layer

Check:

- Constructor validation passes.
- Restored data has the expected shape.
- Date values are valid.
- Methods are available on instances.

## Storage Layer

Check:

- The key is correct.
- Data is serialized.
- Data is parsed safely.
- Storage is available.
- Writes do not throw.
- The current origin is correct.

## Asynchronous Layer

Check:

- The Promise is returned.
- Rejections are handled.
- Loading state begins.
- Cleanup runs in `finally`.
- Duplicate requests are prevented.
- Stale results cannot overwrite newer results.

---

# 40. Add a Temporary Debug Mode

A small debug utility can make logs easy to disable.

### `js/utils/debug.js`

```javascript
"use strict";

const DEBUG_ENABLED = true;

export function debugLog(...values) {
  if (!DEBUG_ENABLED) {
    return;
  }

  console.log("[DEBUG]", ...values);
}

export function debugWarn(...values) {
  if (!DEBUG_ENABLED) {
    return;
  }

  console.warn("[DEBUG]", ...values);
}
```

Use it:

```javascript
import {
  debugLog,
  debugWarn,
} from "./utils/debug.js";

debugLog("Rendering tasks:", tasks);
debugWarn("Ignoring invalid task:", value);
```

For production builds, set:

```javascript
const DEBUG_ENABLED = false;
```

A real build system can remove debug code entirely, but this simple pattern is useful in a native browser project.

---

# 41. Add Structured Debug Context

Instead of logging many unrelated values:

```javascript
console.log(tasks, filter, loading);
```

use a structured object:

```javascript
console.log("Application state", {
  taskCount: tasks.length,
  currentFilter: filter,
  isLoading: loading,
});
```

For errors:

```javascript
console.error("Task loading failed", {
  error,
  currentFilter,
  timestamp: new Date().toISOString(),
});
```

Structured logs are easier to inspect and search.

---

# 42. Preserve Original Error Causes

When wrapping an error, preserve the cause:

```javascript
try {
  localStorage.setItem(key, value);
} catch (error) {
  throw new StorageError(
    "Could not save tasks.",
    { cause: error }
  );
}
```

Inspect it:

```javascript
try {
  saveTasks(tasks);
} catch (error) {
  console.error(error.message);
  console.error("Original cause:", error.cause);
}
```

This lets the application show a friendly message while retaining technical detail for debugging.

---

# 43. Manual Regression Test

After fixing a bug, repeat a standard test sequence.

## Startup

- Load the application.
- Check the console.
- Confirm the status message.
- Confirm saved tasks restore.

## Add

- Add a valid task.
- Add whitespace-only input.
- Add a 120-character title.
- Try a 121-character title.

## Complete

- Complete an active task.
- Reopen a completed task.
- Refresh and verify persistence.

## Delete

- Delete a task.
- Refresh and verify it remains deleted.

## Filter

- Select all.
- Select active.
- Select completed.
- Refresh and verify the filter.

## Async Loading

- Start loading.
- Click repeatedly.
- Wait for success.
- Test failure.
- Confirm the button resets.

## Storage

- Clear saved tasks.
- Insert malformed JSON.
- Insert a malformed task.
- Restore normal storage.

A regression test confirms that a new change did not break an existing feature.

---

# 44. A Debugging Test Harness

Create a temporary module test file.

### `js/debug-test.js`

```javascript
import { Task } from "./models/task.js";
import { TaskService } from "./services/task-service.js";

function assert(condition, message) {
  if (!condition) {
    throw new Error(`FAILED: ${message}`);
  }

  console.log(`PASSED: ${message}`);
}

const taskService = new TaskService();

const task = taskService.add(
  "Run a debugging test"
);

assert(
  task instanceof Task,
  "The service creates Task instances"
);

assert(
  taskService.getAll().length === 1,
  "The service contains one task"
);

taskService.toggle(task.id);

assert(
  task.isCompleted(),
  "The task can be completed"
);

assert(
  taskService.getByFilter("completed").length === 1,
  "The completed filter returns the task"
);

taskService.remove(task.id);

assert(
  taskService.getAll().length === 0,
  "The task can be removed"
);

console.log("Debugging test harness passed.");
```

Temporarily load it from `index.html`:

```html
<script type="module" src="./js/debug-test.js"></script>
```

Expected output:

```text
PASSED: The service creates Task instances
PASSED: The service contains one task
PASSED: The task can be completed
PASSED: The completed filter returns the task
PASSED: The task can be removed
Debugging test harness passed.
```

Restore:

```html
<script type="module" src="./js/main.js"></script>
```

Delete `js/debug-test.js`.

---

# 45. Debugging Anti-Patterns

## Changing Everything at Once

Bad approach:

```text
Rewrite HTML, JavaScript, storage, and CSS simultaneously.
```

Better:

```text
Fix the first module error.
Verify.
Fix the next behavior.
Verify.
```

## Ignoring the First Error

Later errors may be consequences of an earlier failure.

Always investigate the earliest meaningful error first.

## Logging Without Labels

Less useful:

```javascript
console.log(value);
```

More useful:

```javascript
console.log("Restored task value:", value);
```

## Leaving Debug Code Permanently

Temporary code such as:

```javascript
debugger;
console.log("temporary");
```

should be removed or disabled when the feature is complete.

## Swallowing Errors

Avoid:

```javascript
try {
  performOperation();
} catch {
}
```

At minimum:

```javascript
try {
  performOperation();
} catch (error) {
  console.error("Operation failed:", error);
}
```

## Fixing Symptoms Instead of Causes

If `task.complete` is missing, do not merely add a fallback:

```javascript
if (task.complete) {
  task.complete();
}
```

First determine why the task is not a proper `Task` instance.

---

# 46. Final Debugging Checklist

When the application fails, ask:

1. What exact action reproduces the problem?
2. What did I expect to happen?
3. What actually happened?
4. Is there a console error?
5. What file and line does it identify?
6. Is a required DOM element missing?
7. Is the value `null` or `undefined`?
8. Is the object a plain object or a class instance?
9. Is the module path correct?
10. Is the page running through a local server?
11. Did the Promise reject?
12. Is the rejection handled?
13. Is cleanup in `finally`?
14. Did the state change?
15. Did the application re-render?
16. Was the updated state persisted?
17. Is stored JSON valid?
18. Is the current origin correct?
19. Could an older asynchronous response overwrite new state?
20. Can the problem be reproduced in a smaller test?
