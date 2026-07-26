# Appendix D: Debugging Guide

Debugging is the process of finding and correcting problems in a program.

A bug is not evidence that you are bad at programming. It is usually evidence that the program’s actual behavior differs from your assumption.

A productive debugging process looks like this:

```text
Observe the symptom
    ↓
Read the error message
    ↓
Find the first failing line
    ↓
Inspect relevant values
    ↓
Form one hypothesis
    ↓
Test the hypothesis
    ↓
Apply the smallest fix
    ↓
Run the verification again
```

Do not randomly change many lines at once. That makes it difficult to know which change solved or caused the problem.

---

# D.1 The Three Main Error Categories

JavaScript errors generally fall into three broad categories:

1. Syntax errors.
2. Runtime errors.
3. Logic errors.

---

## Syntax Errors

A **syntax error** means JavaScript cannot understand the structure of your code.

Example:

```js
const message = "Hello;
```

The string never closes, so the browser cannot parse the file.

Common causes:

- Missing quotation marks.
- Missing parentheses.
- Missing braces.
- Missing square brackets.
- Extra punctuation.
- Incorrect keywords.
- Invalid object or array syntax.

Typical message:

```text
SyntaxError: Invalid or unexpected token
```

When a syntax error occurs, the browser may stop executing the entire script.

---

## Runtime Errors

A **runtime error** occurs while JavaScript is executing.

Example:

```js
const task = null;

console.log(task.title);
```

The code is syntactically valid, but `null` has no `title` property.

Typical message:

```text
TypeError: Cannot read properties of null
```

Runtime errors usually identify a line where execution failed.

---

## Logic Errors

A **logic error** occurs when the program runs but produces the wrong result.

Example:

```js
const completedTasks = tasks.filter(
  (task) => !task.completed
);
```

If the goal was to find completed tasks, the condition is reversed. The browser may show no error because the syntax and runtime behavior are valid.

Logic errors require comparing:

```text
Expected result
    versus
Actual result
```

---

# D.2 The Browser Console

## Target

Use the browser console to inspect output and errors.

## Concept

The Console is a diagnostic window. It shows:

- Errors.
- Warnings.
- Debug messages.
- Values printed with `console.log`.
- Results of expressions you type manually.

## Implementation

Create this temporary file:

### `debug-console.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Console Debugging</title>
  </head>

  <body>
    <h1>Console Debugging</h1>

    <script>
      "use strict";

      const applicationName = "Debugging Practice";
      const taskCount = 3;

      console.log("Application:", applicationName);
      console.log("Task count:", taskCount);
      console.log("Application state:", {
        applicationName,
        taskCount
      });
    </script>
  </body>
</html>
```

## Verification

Open the file in a browser and open Developer Tools.

The Console should show:

```text
Application: Debugging Practice
Task count: 3
Application state: { ... }
```

Expand the object to inspect its properties.

Use separate logs for important values:

```js
console.log("Raw title:", rawTitle);
console.log("Clean title:", cleanTitle);
console.log("Task:", task);
```

This helps locate where an unexpected value first appears.

---

# D.3 `console.log` Debugging

## Target

Inspect values at key points in an operation.

## Concept

Logging is like placing checkpoints along a route. If the program reaches checkpoint one but not checkpoint two, the failure is between those locations.

## Implementation

```js
"use strict";

function createTask(rawTitle, id) {
  console.log("1. Raw title received:", rawTitle);
  console.log("2. ID received:", id);

  const title = rawTitle.trim();

  console.log("3. Clean title:", title);

  const task = {
    id,
    title,
    completed: false
  };

  console.log("4. Task created:", task);

  return task;
}

const task = createTask(
  "  Learn debugging  ",
  1
);

console.log("5. Final task:", task);
```

## Verification

Run the file.

Expected output should contain five checkpoints:

```text
1. Raw title received:   Learn debugging
2. ID received: 1
3. Clean title: Learn debugging
4. Task created: ...
5. Final task: ...
```

If the output stops before checkpoint four, the problem occurred while creating the object.

---

# D.4 `console.table`

## Target

Inspect arrays of objects in a readable table.

## Implementation

```js
"use strict";

const tasks = [
  {
    id: 1,
    title: "Learn variables",
    completed: true
  },
  {
    id: 2,
    title: "Practice functions",
    completed: false
  },
  {
    id: 3,
    title: "Build a DOM feature",
    completed: false
  }
];

console.table(tasks);
```

## Verification

The Console should display columns similar to:

```text
(index) | id | title                 | completed
0       | 1  | Learn variables       | true
1       | 2  | Practice functions    | false
2       | 3  | Build a DOM feature   | false
```

`console.table()` is especially useful for task arrays.

---

# D.5 Reading Common Error Messages

## `ReferenceError`

Example:

```js
console.log(taskTitle);
```

If `taskTitle` was never declared, JavaScript reports:

```text
ReferenceError: taskTitle is not defined
```

### Meaning

JavaScript cannot find a variable with that name in the current scope.

### Check

- Is the variable declared?
- Is the spelling correct?
- Is capitalization correct?
- Is the variable inside another function or block?
- Are you using the variable before its declaration?

### Correct example

```js
const taskTitle = "Learn JavaScript";

console.log(taskTitle);
```

---

## `TypeError`

Example:

```js
const task = null;

console.log(task.title);
```

Typical message:

```text
TypeError: Cannot read properties of null
```

### Meaning

The value exists, but the requested operation is invalid for that value.

Another example:

```js
const title = "JavaScript";

title.push("!");
```

Strings do not have an array `push` method.

### Check

Log the value and type:

```js
console.log("Value:", task);
console.log("Type:", typeof task);
```

For arrays:

```js
console.log(Array.isArray(task));
```

---

## `SyntaxError`

Example:

```js
const message = "Hello;
```

### Meaning

The code is not valid JavaScript syntax.

### Check

- Matching quote marks.
- Matching parentheses.
- Matching braces.
- Matching brackets.
- Commas between object properties.
- Correct spelling of keywords.

Correct:

```js
const message = "Hello";
```

---

## `RangeError`

Example:

```js
function setTaskCount(count) {
  if (count < 0) {
    throw new RangeError(
      "Task count cannot be negative."
    );
  }

  return count;
}

setTaskCount(-1);
```

### Meaning

A value is outside an allowed range.

---

## `Cannot read properties of null`

Example:

```js
const buttonElement =
  document.querySelector("#missing-button");

buttonElement.addEventListener(
  "click",
  () => {
    console.log("Clicked");
  }
);
```

### Cause

The selector found no element.

### Fix

Check the HTML:

```html
<button id="missing-button">
  Click
</button>
```

Check the selector:

```js
document.querySelector("#missing-button");
```

Check whether the script runs after the HTML exists:

```html
<script
  src="./src/app.js"
  defer
></script>
```

---

# D.6 Debugging File-Loading Errors

## Target

Diagnose missing HTML, CSS, or JavaScript files.

## Concept

A browser requests files from the server. A `404` means the requested path was not found.

## Verification

Open Developer Tools and select the **Network** panel.

Refresh the page.

Look for red requests.

A missing JavaScript file may show:

```text
GET http://localhost:5500/src/app.js 404 (Not Found)
```

## Check the file path

HTML:

```html
<script
  src="./src/app.js"
  defer
></script>
```

Expected structure:

```text
project/
├── index.html
└── src/
    └── app.js
```

If the script is in the same directory as `index.html`, the correct path is:

```html
<script
  src="./app.js"
  defer
></script>
```

Paths are relative to the file containing the reference.

---

# D.7 Debugging Selector Problems

## Target

Find why `querySelector()` returns `null`.

## Implementation

```js
"use strict";

const taskListElement =
  document.querySelector("#task-list");

console.log("Selected task list:", taskListElement);

if (taskListElement === null) {
  throw new Error(
    "The #task-list element could not be found."
  );
}
```

## Verification

If the result is `null`, inspect the HTML.

The HTML must contain:

```html
<ul id="task-list"></ul>
```

Common mismatches:

```html
<ul id="tasks-list"></ul>
```

```html
<ul class="task-list"></ul>
```

```html
<div id="task-list"></div>
```

The last example has the correct ID but a different element type. Whether that matters depends on your code. If your code requires a `HTMLUListElement`, validate that explicitly:

```js
const taskListElement =
  document.querySelector("#task-list");

if (!(taskListElement instanceof HTMLUListElement)) {
  throw new Error(
    "#task-list must be an unordered list."
  );
}
```

---

# D.8 Debugging Form Submission

## Target

Confirm that a form listener receives a submission and prevents a reload.

## Implementation

```js
"use strict";

const formElement =
  document.querySelector("#task-form");

if (!(formElement instanceof HTMLFormElement)) {
  throw new Error("Task form was not found.");
}

formElement.addEventListener(
  "submit",
  (event) => {
    console.log("Submit event received.");
    event.preventDefault();
    console.log("Default submission prevented.");
  }
);
```

## Verification

Submit the form.

The Console should show:

```text
Submit event received.
Default submission prevented.
```

The page should not reload.

If the page reloads:

- Confirm the listener is attached.
- Confirm the event type is `"submit"`.
- Confirm `event.preventDefault()` is inside the handler.
- Confirm the script loaded successfully.

---

# D.9 Debugging Event Delegation

## Target

Inspect the difference between `event.target` and `event.currentTarget`.

## Implementation

```js
"use strict";

const taskListElement =
  document.querySelector("#task-list");

if (taskListElement === null) {
  throw new Error("Task list was not found.");
}

taskListElement.addEventListener(
  "click",
  (event) => {
    console.log("Target:", event.target);
    console.log(
      "Current target:",
      event.currentTarget
    );
  }
);
```

## Verification

If the list contains a button, click the button.

The target should be the clicked button or a nested element.

The current target should be:

```html
<ul id="task-list"></ul>
```

This is why event delegation can handle child buttons from a parent listener.

---

# D.10 Debugging Data Types

## Target

Find bugs caused by strings and numbers being confused.

## Implementation

```js
"use strict";

const taskElement =
  document.createElement("li");

taskElement.dataset.taskId = "12";

const rawTaskId = taskElement.dataset.taskId;
const numericTaskId = Number(rawTaskId);

console.log("Raw ID:", rawTaskId);
console.log("Raw ID type:", typeof rawTaskId);
console.log("Numeric ID:", numericTaskId);
console.log(
  "Numeric ID type:",
  typeof numericTaskId
);
```

## Verification

Expected output:

```text
Raw ID: 12
Raw ID type: string
Numeric ID: 12
Numeric ID type: number
```

This comparison is false:

```js
rawTaskId === 12
```

This comparison is true:

```js
numericTaskId === 12
```

Convert and validate values at the boundary where they enter your application.

---

# D.11 Debugging Array Indexes

## Target

Find off-by-one errors.

## Concept

An off-by-one error occurs when a loop starts or stops one position too early or too late.

## Implementation

```js
"use strict";

const topics = [
  "variables",
  "functions",
  "arrays"
];

for (
  let index = 0;
  index < topics.length;
  index += 1
) {
  console.log({
    index,
    value: topics[index]
  });
}
```

## Verification

Expected indexes:

```text
0
1
2
```

The condition should be:

```js
index < topics.length
```

not:

```js
index <= topics.length
```

With `<=`, the loop attempts to read:

```js
topics[3]
```

which is `undefined`.

---

# D.12 Debugging State and DOM Mismatches

## Target

Determine whether the data or the DOM is incorrect.

## Concept

In the task application, the `tasks` array is the application state. The visible DOM should represent that state.

If the array says:

```js
completed: true
```

but the page does not show a completed style, the rendering logic is incorrect.

## Implementation

```js
function logApplicationState(tasks) {
  console.log("State snapshot:", {
    taskCount: tasks.length,
    tasks: structuredClone(tasks)
  });
}
```

Use it after each state change:

```js
tasks.push(task);
logApplicationState(tasks);
renderTasks(tasks);
```

For older browsers that do not support `structuredClone`, use:

```js
console.log(
  "State snapshot:",
  JSON.parse(JSON.stringify(tasks))
);
```

Do not rely on this for complex values such as functions, dates, or circular references.

## Verification

After adding a task, verify:

1. The task exists in the array.
2. `renderTasks(tasks)` runs.
3. The list contains the expected number of children.

```js
console.log(
  "Data count:",
  tasks.length
);

console.log(
  "DOM count:",
  taskListElement.children.length
);
```

The counts should match.

---

# D.13 Breakpoints

## Target

Pause JavaScript execution at a specific line.

## Concept

A breakpoint is a deliberate pause. While paused, you can inspect:

- Variables.
- Function arguments.
- The call stack.
- The current line.
- The DOM.

## Implementation

Add a `debugger` statement:

```js
function completeTask(task) {
  debugger;

  task.completed = true;

  return task;
}
```

## Verification

Open Developer Tools and run the function.

The browser should pause at:

```js
debugger;
```

Inspect:

- `task`.
- `task.id`.
- `task.completed`.

Use the debugger controls:

- Continue.
- Step over.
- Step into.
- Step out.

Remove `debugger` statements after investigation.

Do not leave accidental breakpoints in production code.

---

# D.14 Conditional Breakpoints

A conditional breakpoint pauses only when a condition is true.

For example, pause only when:

```js
task.id === 5
```

This is useful when a loop processes many items but only one item is problematic.

In Developer Tools:

1. Open the Sources or Debugger panel.
2. Click the line number.
3. Right-click the breakpoint.
4. Choose **Add conditional breakpoint**.
5. Enter:

```js
task.id === 5
```

---

# D.15 Call Stack and Scope Inspection

When execution pauses, Developer Tools usually show a **call stack**.

The call stack shows the functions that led to the current line:

```text
handleSubmit
renderTasks
createTaskElement
```

This answers:

> How did the program get here?

The scope panel shows currently accessible variables:

```text
Local
Closure
Global
```

This helps explain why a variable is or is not available.

---

# D.16 Debugging Logic with Assertions

## Target

Fail early when an assumption is false.

## Implementation

```js
"use strict";

const tasks = [
  {
    id: 1,
    title: "Learn debugging",
    completed: false
  }
];

console.assert(
  Array.isArray(tasks),
  "Tasks should be an array."
);

console.assert(
  tasks.length === 1,
  "Tasks should contain one item."
);

console.assert(
  tasks[0].completed === false,
  "The task should begin incomplete."
);
```

## Verification

If an assertion is true, browsers normally show nothing.

Change:

```js
tasks[0].completed === false
```

to:

```js
tasks[0].completed === true
```

The console should report the failed assertion.

Assertions are useful for development checks, but they should not replace normal application validation.

---

# D.17 Debugging a Task Application

Use this systematic checklist.

## Step 1: Is the script loaded?

Add:

```js
console.log("Task application script loaded.");
```

If this does not appear, inspect the script path and Network panel.

## Step 2: Are the DOM elements available?

Log:

```js
console.log({
  taskFormElement,
  taskTitleInputElement,
  taskListElement
});
```

If any value is `null`, inspect the HTML and selector.

## Step 3: Is the event handler running?

At the beginning of the handler:

```js
console.log("Submit handler started.");
```

If the message does not appear, inspect the event listener.

## Step 4: Is the input correct?

```js
console.log({
  rawValue: taskTitleInputElement.value,
  cleanedValue: taskTitleInputElement.value.trim()
});
```

## Step 5: Is the task created correctly?

```js
console.log("Created task:", task);
```

## Step 6: Did state change?

```js
console.log("Tasks after update:", tasks);
```

## Step 7: Did rendering run?

At the beginning of `renderTasks`:

```js
console.log(
  "Rendering task count:",
  tasks.length
);
```

## Step 8: Does the DOM match state?

```js
console.log(
  "Rendered DOM items:",
  taskListElement.children.length
);
```

---

# D.18 Common Problems and Solutions

## Problem: Nothing happens when clicking a button

Check:

- The script loaded.
- The selector found the button.
- The listener uses the correct event name.
- The handler is not throwing an earlier error.
- The button is not disabled.
- The button has the expected `data-action`.

Add:

```js
console.log("Clicked element:", event.target);
```

---

## Problem: The page reloads on form submission

Add:

```js
event.preventDefault();
```

inside the submit handler.

Confirm the handler is attached to the form:

```js
formElement.addEventListener(
  "submit",
  handleSubmit
);
```

not only to the button.

---

## Problem: The task appears as `[object Object]`

Problem:

```js
messageElement.textContent = task;
```

An object is being converted to a string automatically.

Use a property:

```js
messageElement.textContent = task.title;
```

For debugging:

```js
console.log(task);
```

---

## Problem: The task appears twice

Possible causes:

- `renderTasks()` appends without clearing.
- The form handler is registered twice.
- The same task is pushed twice.
- Both a button handler and delegated handler perform the same action.

Before rendering:

```js
taskListElement.replaceChildren();
```

Check registration code and log each event:

```js
console.log("Submit handler called.");
```

---

## Problem: Removing one task removes the wrong task

Check:

- The `data-task-id` value.
- Numeric conversion.
- The `findIndex` condition.
- Whether IDs are unique.

Log:

```js
console.log({
  requestedId: taskId,
  availableIds: tasks.map(
    (task) => task.id
  )
});
```

---

## Problem: Completed styling does not appear

Check the data:

```js
console.log(task.completed);
```

Check the class:

```js
console.log(
  taskElement.classList.contains(
    "task-item--completed"
  )
);
```

Check the CSS selector:

```css
.task-item--completed .task-item__title {
  text-decoration: line-through;
}
```

The class name must match exactly.

---

# D.19 Debugging Workflow Summary

Use this order:

```text
1. Read the first error.
2. Open the file and line identified.
3. Inspect the values involved.
4. Confirm selectors and file paths.
5. Add a focused log or breakpoint.
6. Test one hypothesis.
7. Make the smallest correction.
8. Refresh and verify.
9. Remove temporary debugging code.
```

Avoid:

```text
- Changing many unrelated lines.
- Ignoring the first console error.
- Assuming a later symptom is the original cause.
- Copying a fix without understanding it.
- Leaving temporary logs everywhere.
```

---

# D.20 Final Debugging Exercise

Create this complete example:

### `debug-exercise.js`

```js
"use strict";

const tasks = [
  {
    id: 1,
    title: "Read the debugging guide",
    completed: false
  },
  {
    id: 2,
    title: "Use the browser console",
    completed: true
  }
];

function getCompletedTasks(tasks) {
  return tasks.filter(
    (task) => task.completed
  );
}

function describeTasks(tasks) {
  return tasks.map((task) => {
    const state = task.completed
      ? "complete"
      : "incomplete";

    return `${task.id}: ${task.title} (${state})`;
  });
}

console.log("All tasks:");
console.table(tasks);

const completedTasks =
  getCompletedTasks(tasks);

console.log("Completed tasks:");
console.table(completedTasks);

const descriptions =
  describeTasks(tasks);

console.log("Descriptions:");
console.log(descriptions.join("\n"));
```

Expected output:

```text
All tasks:
```

A table containing two tasks.

```text
Completed tasks:
```

A table containing only task `2`.

```text
Descriptions:
1: Read the debugging guide (incomplete)
2: Use the browser console (complete)
```

Change the filter temporarily to:

```js
(task) => !task.completed
```

Observe how the output changes. This is a logic change, not a syntax or runtime error.

Restore the original version afterward.

---

# Appendix D Completion Checklist

You should now be able to:

- Distinguish syntax, runtime, and logic errors.
- Read the first browser console error.
- Use `console.log`.
- Use `console.table`.
- Inspect values and types.
- Diagnose missing selectors.
- Diagnose missing files.
- Interpret `ReferenceError`.
- Interpret `TypeError`.
- Interpret `SyntaxError`.
- Debug form submission.
- Debug event delegation.
- Detect string-number mismatches.
- Find off-by-one errors.
- Compare application state with the DOM.
- Use breakpoints.
- Use `debugger`.
- Use assertions.
- Debug systematically instead of guessing.
