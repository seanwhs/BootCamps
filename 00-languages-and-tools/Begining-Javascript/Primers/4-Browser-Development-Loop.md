# Primer 4: The Browser Development Loop

Writing code is only one part of programming. The other essential part is repeatedly running the code, observing what happened, and improving it.

This repeated process is the **development loop**:

```text
Plan
    ↓
Edit
    ↓
Save
    ↓
Run
    ↓
Observe
    ↓
Debug
    ↓
Repeat
```

Beginners often expect to write a large amount of code and get everything right on the first attempt. Professional developers usually work in smaller cycles. They make one focused change, test it immediately, and use the result to guide the next change.

This primer teaches that workflow.

---

# 1. The Basic Development Loop

## The Target

Understand the sequence used to develop a browser application.

## The Concept

Suppose you want to add a button that changes a message.

You should not immediately build the entire feature. Instead:

```text
1. Create the HTML button.
2. Confirm it appears.
3. Select it with JavaScript.
4. Confirm the selection.
5. Add the event listener.
6. Confirm the event fires.
7. Change the message.
8. Confirm the visible result.
```

Each step creates a small checkpoint.

## The Implementation

### `development-loop.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Development Loop</title>
  </head>

  <body>
    <main>
      <h1>Development loop</h1>

      <button
        id="action-button"
        type="button"
      >
        Run action
      </button>

      <p id="message">
        No action has run yet.
      </p>
    </main>

    <script
      src="./development-loop.js"
      defer
    ></script>
  </body>
</html>
```

### `development-loop.js`

```js
"use strict";

const actionButtonElement =
  document.querySelector("#action-button");

const messageElement =
  document.querySelector("#message");

if (actionButtonElement === null) {
  throw new Error(
    "Could not find #action-button."
  );
}

if (messageElement === null) {
  throw new Error(
    "Could not find #message."
  );
}

console.log("Step 1: JavaScript loaded.");

actionButtonElement.addEventListener(
  "click",
  () => {
    console.log("Step 2: Button click received.");

    messageElement.textContent =
      "The development loop works.";
  }
);
```

## The Verification

Follow this sequence:

1. Open the page.
2. Confirm the button appears.
3. Open the browser console.
4. Confirm:

```text
Step 1: JavaScript loaded.
```

5. Click the button.
6. Confirm:

```text
Step 2: Button click received.
```

7. Confirm the page displays:

```text
The development loop works.
```

The feature is complete because you verified both:

```text
Console behavior
Visible page behavior
```

[COMPLETED: Basic browser development loop verified]  
[NEXT: Make a small change]

---

# 2. Make One Focused Change

## The Target

Change the button’s message without changing unrelated code.

## The Concept

A focused change modifies one behavior at a time.

Avoid changing:

- HTML structure.
- CSS layout.
- JavaScript event handling.
- Data structures.
- Error handling.

all in one edit.

If something breaks, you will not know which change caused it.

## The Implementation

Change only this line:

### `development-loop.js`

```js
messageElement.textContent =
  "The button was clicked successfully.";
```

The complete relevant handler is:

```js
actionButtonElement.addEventListener(
  "click",
  () => {
    console.log("Step 2: Button click received.");

    messageElement.textContent =
      "The button was clicked successfully.";
  }
);
```

## The Verification

Save the file.

Refresh the browser.

Click the button.

Expected page output:

```text
The button was clicked successfully.
```

If the old message remains:

1. Confirm the file was saved.
2. Refresh the page.
3. Confirm the browser is loading the expected file.
4. Inspect the Network panel if necessary.

[COMPLETED: Focused change verified]  
[NEXT: Verify syntax before behavior]

---

# 3. Verify Syntax First

## The Target

Learn to identify syntax problems before investigating application behavior.

## The Concept

If JavaScript contains invalid syntax, the browser may stop reading the entire file.

For example:

```js
const message = "Hello;
```

The browser cannot determine where the string ends.

This is different from a logic error. With a syntax error, the intended behavior may never begin.

## The Implementation

Temporarily replace the JavaScript file with:

### `development-loop.js`

```js
"use strict";

const message = "This string is not closed;

console.log(message);
```

## The Verification

Refresh the page.

The Console should show a syntax error similar to:

```text
SyntaxError: Invalid or unexpected token
```

The button will not work because the browser could not parse the script.

Restore the valid file:

### `development-loop.js`

```js
"use strict";

const actionButtonElement =
  document.querySelector("#action-button");

const messageElement =
  document.querySelector("#message");

if (actionButtonElement === null) {
  throw new Error(
    "Could not find #action-button."
  );
}

if (messageElement === null) {
  throw new Error(
    "Could not find #message."
  );
}

console.log("JavaScript loaded.");

actionButtonElement.addEventListener(
  "click",
  () => {
    messageElement.textContent =
      "The button works.";
  }
);
```

Refresh again.

The button should work.

[COMPLETED: Syntax-error behavior verified]  
[NEXT: Read runtime errors]

---

# 4. Verify Runtime Assumptions

## The Target

Understand runtime errors caused by invalid values or missing elements.

## The Concept

A runtime error occurs after JavaScript successfully starts running.

Example:

```js
const missingElement =
  document.querySelector("#does-not-exist");

missingElement.textContent = "Hello";
```

The syntax is valid, but `missingElement` is `null`.

The program’s assumption was:

```text
An element with this selector exists.
```

The page did not satisfy that assumption.

## The Implementation

Temporarily use this file:

### `development-loop.js`

```js
"use strict";

const missingElement =
  document.querySelector("#does-not-exist");

console.log("Selected element:", missingElement);

missingElement.textContent =
  "This will not run.";
```

## The Verification

Refresh the page.

The console should show:

```text
Selected element: null
```

followed by a TypeError similar to:

```text
Cannot set properties of null
```

The fix is to either:

1. Correct the selector.
2. Add the missing HTML element.
3. Validate the result before using it.

Corrected version:

```js
"use strict";

const messageElement =
  document.querySelector("#message");

if (messageElement === null) {
  throw new Error(
    "Could not find #message."
  );
}

messageElement.textContent =
  "The element exists.";
```

[COMPLETED: Runtime-assumption debugging verified]  
[NEXT: Identify logic errors]

---

# 5. Identify Logic Errors

## The Target

Learn to detect programs that run but produce the wrong result.

## The Concept

A logic error does not necessarily produce a console error.

Consider:

```js
const completedTasks = tasks.filter(
  (task) => !task.completed
);
```

This code is valid, but it selects incomplete tasks instead of completed tasks.

The program runs. The result is simply wrong.

## The Implementation

### `logic-error.js`

```js
"use strict";

const tasks = [
  {
    id: 1,
    title: "Learn logic errors",
    completed: true
  },
  {
    id: 2,
    title: "Practice testing",
    completed: false
  }
];

const completedTasks = tasks.filter(
  (task) => task.completed
);

console.log("Completed tasks:", completedTasks);
```

## The Verification

Expected result:

```text
Completed tasks:
[
  {
    id: 1,
    title: "Learn logic errors",
    completed: true
  }
]
```

Now intentionally introduce the logic error:

```js
const completedTasks = tasks.filter(
  (task) => !task.completed
);
```

The result will contain task `2`, even though its `completed` value is `false`.

Ask:

```text
What result did I expect?
What result did I receive?
Which condition produced the difference?
```

[COMPLETED: Logic-error diagnosis demonstrated]  
[NEXT: Use checkpoints]

---

# 6. Use Checkpoints

## The Target

Use logging to identify where an operation stops or changes unexpectedly.

## The Concept

A checkpoint is a message or value recorded at a known point in the program.

```text
Checkpoint 1 → input received
Checkpoint 2 → input cleaned
Checkpoint 3 → data created
Checkpoint 4 → state updated
Checkpoint 5 → interface rendered
```

If the output stops at checkpoint `2`, the problem is after checkpoint `2`.

## The Implementation

### `checkpoints.js`

```js
"use strict";

const tasks = [];

function addTask(rawTitle) {
  console.log("Checkpoint 1: received input.", {
    rawTitle
  });

  const title = rawTitle.trim();

  console.log("Checkpoint 2: cleaned input.", {
    title
  });

  if (title.length === 0) {
    console.log(
      "Checkpoint 3: validation failed."
    );

    return false;
  }

  const task = {
    id: tasks.length + 1,
    title,
    completed: false
  };

  console.log("Checkpoint 4: created task.", {
    task
  });

  tasks.push(task);

  console.log("Checkpoint 5: updated state.", {
    tasks
  });

  return true;
}

const added = addTask(
  "  Learn debugging checkpoints  "
);

console.log("Checkpoint 6: completed.", {
  added
});
```

## The Verification

Expected output should contain all checkpoints:

```text
Checkpoint 1: received input.
Checkpoint 2: cleaned input.
Checkpoint 4: created task.
Checkpoint 5: updated state.
Checkpoint 6: completed.
```

Notice that checkpoint `3` does not appear on the successful path.

Test invalid input:

```js
const added = addTask("   ");
```

Expected output should include:

```text
Checkpoint 3: validation failed.
```

The function returns before creating or storing a task.

[COMPLETED: Checkpoint debugging verified]  
[NEXT: Use the Network and Sources panels]

---

# 7. Use Developer Tools Deliberately

## The Target

Learn which browser tool to use for each problem.

## The Concept

Different problems belong in different Developer Tools panels.

| Problem | Useful panel |
|---|---|
| JavaScript error | Console |
| Missing file | Network |
| Wrong DOM structure | Elements |
| Incorrect execution path | Sources/Debugger |
| Browser storage | Application/Storage |

## Console

Use the Console to inspect:

```js
console.log(tasks);
console.table(tasks);
console.error(error);
```

## Elements

Use Elements to inspect:

- Whether an element exists.
- Whether a class was added.
- Whether text changed.
- Whether a `data-*` attribute exists.

## Sources

Use Sources to:

- Add breakpoints.
- Pause code.
- Inspect variables.
- Step through statements.

## Network

Use Network to inspect:

- JavaScript files.
- CSS files.
- Images.
- API requests.
- HTTP status codes.

## Application

Use Application to inspect:

- `localStorage`.
- Cookies.
- IndexedDB.
- Cache storage.

## Verification

Open your task application and deliberately inspect one state change:

1. Open Elements.
2. Click **Complete** on a task.
3. Watch the task element.
4. Confirm its class changes.
5. Open the Console.
6. Log the task state.
7. Compare the object and DOM.

This trains you to inspect both sides of the application:

```text
Data state
Visible DOM
```

[COMPLETED: Developer Tools workflow verified]  
[NEXT: Use breakpoints]

---

# 8. Pause Execution with Breakpoints

## The Target

Pause JavaScript at a specific line and inspect its state.

## The Concept

A breakpoint temporarily stops execution. This lets you inspect the program at the exact moment a function is running.

This is more powerful than logging every value because you can inspect:

- Local variables.
- Function parameters.
- Outer-scope variables.
- The call stack.
- The DOM.

## The Implementation

### `breakpoint-example.js`

```js
"use strict";

function createTask(title, id) {
  const task = {
    id,
    title,
    completed: false
  };

  debugger;

  return task;
}

const task = createTask(
  "Inspect this task",
  1
);

console.log(task);
```

## The Verification

Open the file through a browser page.

When `createTask()` runs, the browser should pause at:

```js
debugger;
```

In Developer Tools:

1. Inspect `title`.
2. Inspect `id`.
3. Inspect `task`.
4. Continue execution.

The console should eventually show the created task.

Remove the `debugger` statement afterward.

[COMPLETED: Breakpoint debugging verified]  
[NEXT: Make safe changes]

---

# 9. Make Changes in Small Increments

## The Target

Practice adding a feature in multiple verified steps.

## The Concept

Suppose the requirement is:

> Add a button that clears all tasks.

Do not start with a complete implementation. Use incremental steps.

```text
Step 1: Add the button to HTML.
Step 2: Confirm it appears.
Step 3: Select the button.
Step 4: Confirm the selection.
Step 5: Add a click listener.
Step 6: Confirm the click fires.
Step 7: Clear the data.
Step 8: Render the empty state.
Step 9: Verify repeated use.
```

## Implementation: Step 1

Add:

### `index.html`

```html
<button
  id="clear-button"
  type="button"
>
  Clear tasks
</button>
```

## Verification

Refresh the page.

Confirm that the button appears before writing any JavaScript.

## Implementation: Step 2

Add:

### `app.js`

```js
const clearButtonElement =
  document.querySelector("#clear-button");

if (clearButtonElement === null) {
  throw new Error(
    "Could not find #clear-button."
  );
}

console.log(
  "Clear button selected:",
  clearButtonElement
);
```

## Verification

Refresh the page.

Confirm that the Console logs the button element.

## Implementation: Step 3

Add the event handler:

```js
clearButtonElement.addEventListener(
  "click",
  () => {
    console.log("Clear button clicked.");
  }
);
```

## Verification

Click the button.

Confirm that the Console logs:

```text
Clear button clicked.
```

This approach makes each failure easy to locate.

[COMPLETED: Incremental feature-development workflow demonstrated]  
[NEXT: Refreshing and caching]

---

# 10. Understand Refreshing and Caching

## The Target

Understand why the browser may appear not to show a recent change.

## The Concept

A browser can cache files to avoid downloading them repeatedly.

Usually, development tools and local servers handle this well, but occasionally you may see an older file.

## Verification

After editing a file:

1. Save it.
2. Refresh the page.
3. If necessary, perform a hard reload.
4. Inspect the Network panel.
5. Open the loaded JavaScript file in Sources.
6. Confirm it contains your latest change.

Common refresh shortcuts:

### Windows/Linux

```text
Ctrl + R
```

Hard reload:

```text
Ctrl + Shift + R
```

### macOS

```text
Cmd + R
```

Hard reload behavior varies by browser, but Developer Tools often provide:

```text
Empty Cache and Hard Reload
```

Do not immediately assume the JavaScript is wrong. First confirm that the browser loaded the file you edited.

[COMPLETED: Browser refresh and caching workflow documented]  
[NEXT: Write verification checks]

---

# 11. Verify Behavior with Assertions

## The Target

Use executable checks to confirm assumptions.

## The Concept

An assertion says:

> I expect this condition to be true.

If it is false, the Console reports a failed assertion.

## The Implementation

### `assertions.js`

```js
"use strict";

const tasks = [
  {
    id: 1,
    title: "Verify assumptions",
    completed: false
  }
];

console.assert(
  Array.isArray(tasks),
  "Tasks should be an array."
);

console.assert(
  tasks.length === 1,
  "There should be one task."
);

console.assert(
  tasks[0].id === 1,
  "The task ID should be 1."
);

console.assert(
  tasks[0].completed === false,
  "The task should begin incomplete."
);

console.log("Assertions finished.");
```

## The Verification

Run the file.

Expected output:

```text
Assertions finished.
```

Change:

```js
tasks[0].completed === false
```

to:

```js
tasks[0].completed === true
```

The Console should report a failed assertion.

Restore the correct assertion.

Assertions are useful for development checks, but ordinary user-facing validation is still required.

[COMPLETED: Assertion-based verification demonstrated]  
[NEXT: A complete feature workflow]

---

# 12. Complete Feature Workflow

## The Target

Use the entire development loop to build a small feature.

## The Feature

Add a task count that updates when tasks change.

## Step 1: Add the HTML target

### `feature-workflow.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Feature Workflow</title>
  </head>

  <body>
    <main>
      <h1>Feature workflow</h1>

      <p id="task-count">
        0 tasks
      </p>

      <button
        id="add-button"
        type="button"
      >
        Add task
      </button>

      <ul id="task-list"></ul>
    </main>

    <script
      src="./feature-workflow.js"
      defer
    ></script>
  </body>
</html>
```

Verify that the count and button appear.

## Step 2: Select and validate elements

### `feature-workflow.js`

```js
"use strict";

const taskCountElement =
  document.querySelector("#task-count");

const addButtonElement =
  document.querySelector("#add-button");

const taskListElement =
  document.querySelector("#task-list");

if (taskCountElement === null) {
  throw new Error(
    "Could not find #task-count."
  );
}

if (addButtonElement === null) {
  throw new Error(
    "Could not find #add-button."
  );
}

if (taskListElement === null) {
  throw new Error(
    "Could not find #task-list."
  );
}

console.log("DOM references selected.");
```

Refresh and verify the Console message.

## Step 3: Add state

```js
const tasks = [];
let nextTaskId = 1;

console.log("Initial task state:", tasks);
```

Refresh and verify:

```text
Initial task state: []
```

## Step 4: Add rendering

```js
function renderTasks() {
  taskListElement.replaceChildren();

  for (const task of tasks) {
    const itemElement =
      document.createElement("li");

    itemElement.textContent = task.title;

    taskListElement.append(itemElement);
  }

  taskCountElement.textContent =
    `${tasks.length} ${
      tasks.length === 1
        ? "task"
        : "tasks"
    }`;
}

renderTasks();
```

Verify:

```text
0 tasks
```

## Step 5: Add the event

```js
addButtonElement.addEventListener(
  "click",
  () => {
    const task = {
      id: nextTaskId,
      title: `Task ${nextTaskId}`,
      completed: false
    };

    nextTaskId += 1;
    tasks.push(task);

    renderTasks();

    console.log("Updated state:", tasks);
  }
);
```

## Verification

Click **Add task** repeatedly.

Expected sequence:

```text
0 tasks
1 task
2 tasks
3 tasks
```

The visible list should contain:

```text
Task 1
Task 2
Task 3
```

This feature was built through small verified steps rather than one large untested block.

[COMPLETED: Complete feature-development workflow verified]  
[NEXT: Browser development checklist]

---

# 13. Development Checklist

Before moving to the next implementation step, verify:

## File and server

- [ ] The file is saved.
- [ ] The file path is correct.
- [ ] The local server is running.
- [ ] The browser loaded the latest version.

## JavaScript

- [ ] The Console has no syntax errors.
- [ ] Required elements were found.
- [ ] The event handler runs.
- [ ] Input values are what you expect.
- [ ] State changes as intended.
- [ ] The rendering function runs.

## Interface

- [ ] The expected text appears.
- [ ] Classes change correctly.
- [ ] Counts update.
- [ ] Empty states appear when needed.
- [ ] Keyboard interaction works.
- [ ] Error messages are understandable.

## Cleanup

- [ ] Temporary logs were removed or made purposeful.
- [ ] Temporary `debugger` statements were removed.
- [ ] Test-only invalid code was restored.
- [ ] The final code remains readable.

---

# 14. What to Do When You Are Stuck

Use this sequence:

```text
1. Stop changing code.
2. Read the first Console error.
3. Open the referenced file and line.
4. Inspect the values involved.
5. Confirm selectors and file paths.
6. Add one focused log or breakpoint.
7. Form one hypothesis.
8. Make one change.
9. Refresh and test again.
```

Ask precise questions:

```text
Was the script loaded?
Was the event handler called?
What is the input value?
What is the input type?
Did the array change?
Did rendering run?
Does the DOM match the state?
```

Avoid vague questions such as:

```text
Why does nothing work?
```

Replace them with:

```text
The submit handler runs, but the task array remains empty.
Why is tasks.push(task) not being reached?
```

Precise questions lead to faster debugging.

---

# 15. Primer 4 Summary

The browser development loop is:

```text
Plan
    ↓
Edit
    ↓
Save
    ↓
Run
    ↓
Observe
    ↓
Debug
    ↓
Repeat
```

Use small increments:

```text
One file
    ↓
One feature
    ↓
One verification
```

Use the right tool:

```text
Console      → logs and errors
Elements     → current DOM
Sources      → breakpoints and execution
Network      → loaded files and requests
Application  → browser storage
```

Distinguish the three major error types:

```text
Syntax error  → code cannot be parsed
Runtime error → code fails while running
Logic error   → code runs but gives the wrong result
```

The most important professional habit is:

> Do not build on an unverified step.
