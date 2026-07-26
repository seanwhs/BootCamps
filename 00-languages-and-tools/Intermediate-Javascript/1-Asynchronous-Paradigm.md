# Part 1: The Asynchronous Paradigm

In this part, we will build the first working version of the **Async Task Manager**.

The application will begin with a small synchronous task list. We will then introduce delayed work and callbacks so the application can load starter tasks without freezing the page.

By the end of this part, you will understand:

- Synchronous execution.
- Blocking code.
- Non-blocking code.
- The call stack.
- Browser Web APIs.
- The event loop.
- Queues.
- Callback functions.
- How asynchronous results return to JavaScript.
- Why asynchronous output may appear in a different order from the source code.

We will use browser-native JavaScript without a framework.

---

# Part 1 Overview

We will build the application in these steps:

1. Create the initial project.
2. Create the HTML page.
3. Create the stylesheet.
4. Add synchronous task rendering.
5. Add a blocking operation to observe the problem.
6. Replace blocking work with a non-blocking timer.
7. Build a callback-based asynchronous task loader.
8. Add loading and error states.
9. Connect the loader to the task list.
10. Verify the complete Part 1 application.

The code in this part intentionally uses callbacks. In Part 2, we will replace this callback-based design with Promises and `async`/`await`.

---

# Step 1: Create the Project

## The Target

Create the initial project directory and its subdirectories.

We need a directory because the browser application will contain multiple files. Separating files early makes the relationship between code organization and application behavior easier to understand.

## The Concept

A project directory is like a workshop.

- HTML is the physical layout.
- CSS is the paint and decoration.
- JavaScript is the machinery.
- The `js` directory is where the application’s behavior lives.

We will begin with only one JavaScript file. Later parts will split that file into modules.

## The Implementation

Run the following commands in a terminal.

### macOS or Linux

```bash
mkdir -p async-task-manager/js
cd async-task-manager
touch index.html styles.css js/main.js
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Path async-task-manager
Set-Location async-task-manager
New-Item -ItemType Directory -Path js
New-Item -ItemType File -Path index.html
New-Item -ItemType File -Path styles.css
New-Item -ItemType File -Path js/main.js
```

Your directory should now look like this:

```text
async-task-manager/
├── index.html
├── styles.css
└── js/
    └── main.js
```

## The Verification

Run:

```bash
pwd
```

On Windows PowerShell, run:

```powershell
Get-Location
```

Then list the project contents.

### macOS or Linux

```bash
find . -maxdepth 3 -type f
```

### Windows PowerShell

```powershell
Get-ChildItem -Recurse -File
```

You should see:

```text
index.html
styles.css
js/main.js
```

[COMPLETED: Step 1 — Project directory created]  
[STARTING: Step 2 — Building the HTML page]

---

# Step 2: Build the HTML Page

## The Target

Create the page structure in `index.html`.

The page needs:

- A heading.
- A form for adding tasks.
- A button for loading example tasks.
- A status area.
- A task list.

The HTML will provide stable elements that JavaScript can find and update.

## The Concept

HTML is the application’s frame.

JavaScript should not need to create every element from nothing. Instead, we give the application important locations in advance:

- The form is where users submit tasks.
- The status area is where the application reports what is happening.
- The task list is where tasks appear.

JavaScript will later act like a stage manager, updating these locations as events occur.

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
      content="A beginner-friendly asynchronous JavaScript task manager"
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
          Learn how JavaScript handles delayed work without freezing the page.
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
                placeholder="For example: Study the event loop"
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
              The example loader waits before returning starter tasks.
            </p>
          </div>

          <button id="load-tasks-button" type="button">
            Load example tasks
          </button>
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
          Ready.
        </p>
      </section>

      <section class="panel" aria-labelledby="tasks-heading">
        <div class="section-heading">
          <div>
            <h2 id="tasks-heading">Tasks</h2>
            <p id="task-count">0 tasks</p>
          </div>
        </div>

        <ul id="task-list" class="task-list"></ul>
      </section>
    </main>

    <script src="./js/main.js"></script>
  </body>
</html>
```

## The Verification

Open `index.html` directly in your browser.

You should see:

- The page heading.
- A task input field.
- An “Add task” button.
- A “Load example tasks” button.
- A status message showing `Ready.`
- An empty task section.

The buttons will not work yet because `main.js` is still empty. That is expected.

[COMPLETED: Step 2 — HTML structure created]  
[STARTING: Step 3 — Styling the application]

---

# Step 3: Add the Stylesheet

## The Target

Create the visual design in `styles.css`.

The application needs styles for:

- The page layout.
- Panels.
- Forms.
- Buttons.
- Task items.
- Status messages.
- Loading and error states.

## The Concept

CSS is separate from JavaScript because appearance and behavior are different responsibilities.

JavaScript will add CSS classes such as:

```javascript
statusMessage.className = "status-message status-loading";
```

CSS will decide what that class looks like.

This gives JavaScript a simple control panel. It only announces the state; CSS handles the visual result.

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
input {
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

.input-row input {
  min-width: 0;
  flex: 1;
  border: 1px solid #bcc7d8;
  border-radius: 0.55rem;
  padding: 0.7rem 0.8rem;
  color: #172033;
  background: #ffffff;
}

.input-row input:focus {
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

.task-action {
  flex: 0 0 auto;
  padding: 0.5rem 0.7rem;
  color: #172033;
  background: #e5ebf5;
  font-size: 0.85rem;
}

.task-action:hover {
  background: #d4deef;
}

.empty-state {
  margin: 0;
  color: #66728a;
  text-align: center;
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

  .input-row,
  .section-heading {
    display: flex;
  }

  .task-item {
    align-items: flex-start;
    flex-direction: column;
  }

  .task-action {
    width: 100%;
  }
}
```

## The Verification

Refresh the browser page.

You should now see:

- A centered application layout.
- White panels.
- Styled buttons.
- A styled input field.
- An empty task area.
- A blue status message.

No JavaScript behavior is expected yet.

[COMPLETED: Step 3 — Base styling created]  
[STARTING: Step 4 — Understanding synchronous execution]

---

# Step 4: Add Synchronous Task Rendering

## The Target

Create the first version of `js/main.js`.

This version will:

- Store tasks in an array.
- Read the form input.
- Add tasks synchronously.
- Render tasks into the page.
- Mark tasks as completed.
- Update the task count.

## The Concept

**Synchronous** means work happens one operation at a time, in order.

Imagine a person standing in a checkout line:

1. The first customer is served.
2. The second customer waits.
3. The third customer waits.
4. The cashier cannot move to the next customer until the current transaction finishes.

JavaScript normally executes synchronous code in this same sequential way.

When a function is called, JavaScript runs its statements from top to bottom before moving to the next piece of work.

## The Implementation

### `js/main.js`

```javascript
"use strict";

const taskForm = document.querySelector("#task-form");
const taskTitleInput = document.querySelector("#task-title");
const taskList = document.querySelector("#task-list");
const taskCount = document.querySelector("#task-count");
const statusMessage = document.querySelector("#status-message");
const loadTasksButton = document.querySelector("#load-tasks-button");

/*
 * This array is temporary application memory.
 *
 * It will be replaced by browser storage in Part 4.
 * For now, keeping the data in memory lets us focus on execution flow.
 */
let tasks = [
  {
    id: 1,
    title: "Understand synchronous JavaScript",
    completed: false,
  },
  {
    id: 2,
    title: "Practice reading the event loop",
    completed: false,
  },
];

function createTaskId() {
  /*
   * Date.now() returns the current time in milliseconds.
   * Combining it with a random number makes collisions unlikely
   * for this small browser application.
   */
  return Date.now() + Math.floor(Math.random() * 1000);
}

function updateStatus(message, state = "default") {
  statusMessage.textContent = message;
  statusMessage.className = "status-message";

  if (state === "loading") {
    statusMessage.classList.add("status-loading");
  }

  if (state === "success") {
    statusMessage.classList.add("status-success");
  }

  if (state === "error") {
    statusMessage.classList.add("status-error");
  }
}

function updateTaskCount() {
  const taskTotal = tasks.length;
  const completedTotal = tasks.filter((task) => task.completed).length;

  taskCount.textContent =
    `${taskTotal} ${taskTotal === 1 ? "task" : "tasks"} · ` +
    `${completedTotal} completed`;
}

function renderTasks() {
  taskList.replaceChildren();

  if (tasks.length === 0) {
    const emptyMessage = document.createElement("p");
    emptyMessage.className = "empty-state";
    emptyMessage.textContent = "No tasks yet.";
    taskList.append(emptyMessage);
    updateTaskCount();
    return;
  }

  tasks.forEach((task) => {
    const listItem = document.createElement("li");
    listItem.className = "task-item";

    if (task.completed) {
      listItem.classList.add("task-completed");
    }

    const textContainer = document.createElement("div");

    const title = document.createElement("p");
    title.className = "task-title";
    title.textContent = task.title;

    const metadata = document.createElement("p");
    metadata.className = "task-meta";
    metadata.textContent = task.completed ? "Completed" : "Not completed";

    textContainer.append(title, metadata);

    const completionButton = document.createElement("button");
    completionButton.className = "task-action";
    completionButton.type = "button";
    completionButton.dataset.taskId = String(task.id);
    completionButton.textContent = task.completed
      ? "Mark as incomplete"
      : "Mark as complete";

    completionButton.addEventListener("click", () => {
      toggleTaskCompletion(task.id);
    });

    listItem.append(textContainer, completionButton);
    taskList.append(listItem);
  });

  updateTaskCount();
}

function addTask(title) {
  const normalizedTitle = title.trim();

  if (normalizedTitle.length === 0) {
    updateStatus("Enter a task title before adding a task.", "error");
    return;
  }

  const newTask = {
    id: createTaskId(),
    title: normalizedTitle,
    completed: false,
  };

  tasks.push(newTask);
  renderTasks();
  updateStatus(`Added task: ${normalizedTitle}`, "success");
}

function toggleTaskCompletion(taskId) {
  tasks = tasks.map((task) => {
    if (task.id !== taskId) {
      return task;
    }

    return {
      ...task,
      completed: !task.completed,
    };
  });

  renderTasks();
  updateStatus("Task status updated.", "success");
}

taskForm.addEventListener("submit", (event) => {
  event.preventDefault();

  addTask(taskTitleInput.value);
  taskTitleInput.value = "";
  taskTitleInput.focus();
});

renderTasks();
updateStatus("Ready. Tasks are currently stored only in memory.");
```

## The Verification

Refresh the page.

Test the following:

1. Enter:

   ```text
   Learn synchronous execution
   ```

2. Click **Add task**.

You should see the new task appear.

3. Click **Mark as complete**.

The task should receive a strikethrough and its metadata should change to `Completed`.

4. Submit an empty form.

You should see:

```text
Enter a task title before adding a task.
```

The task count should update after every change.

[COMPLETED: Step 4 — Synchronous task application working]  
[STARTING: Step 5 — Observing blocking code]

---

# Step 5: Observe Blocking Code

## The Target

Add a temporary blocking function to `js/main.js`.

This function will deliberately pause JavaScript so we can observe what “blocking” means.

## The Concept

A blocking operation prevents JavaScript from doing other work.

Imagine a single cashier who begins counting a huge pile of coins. While the cashier is counting:

- No customer can pay.
- No new customer can be served.
- The checkout line appears frozen.

The browser’s main JavaScript thread behaves similarly. If JavaScript spends too long executing one synchronous function, the browser cannot immediately:

- Respond to clicks.
- Update visible content.
- Process other event handlers.
- Paint screen changes.

## The Implementation

Add this function to `js/main.js`, before the `renderTasks()` call at the bottom.

```javascript
function blockForMilliseconds(durationInMilliseconds) {
  const startTime = Date.now();

  /*
   * This loop intentionally does nothing until enough time has passed.
   *
   * It blocks the JavaScript thread because the current function
   * never gives control back to the browser during the loop.
   */
  while (Date.now() - startTime < durationInMilliseconds) {
    // Deliberately empty: this function demonstrates blocking work.
  }
}
```

Now temporarily replace the bottom of `js/main.js`:

```javascript
renderTasks();
updateStatus("Ready. Tasks are currently stored only in memory.");
```

with:

```javascript
renderTasks();
updateStatus("Ready. Tasks are currently stored only in memory.");

console.log("Before blocking work");
blockForMilliseconds(3000);
console.log("After blocking work");
```

## The Verification

Refresh the page and immediately open the browser developer tools.

Open the **Console** tab.

You should see:

```text
Before blocking work
```

Then the page may appear unresponsive for approximately three seconds.

After the pause, you should see:

```text
After blocking work
```

During the pause, try clicking the page or submitting the form. The browser will not respond until the blocking function completes.

This is the problem asynchronous programming helps us avoid.

Now remove the temporary test code:

```javascript
console.log("Before blocking work");
blockForMilliseconds(3000);
console.log("After blocking work");
```

Keep the `blockForMilliseconds` function for the next experiment.

[COMPLETED: Step 5 — Blocking behavior observed]  
[STARTING: Step 6 — Replacing blocking work with non-blocking scheduling]

---

# Step 6: Use a Non-Blocking Timer

## The Target

Add a non-blocking delayed operation using `setTimeout`.

## The Concept

The browser provides special features called **Web APIs**.

A Web API is a browser-provided capability that JavaScript can request, such as:

- Timers.
- Network requests.
- DOM events.
- Geolocation.
- File access.

`setTimeout` is one of these browser capabilities.

When JavaScript calls `setTimeout`, it does not sit and wait. Instead, it tells the browser:

> Run this callback after at least this much time has passed.

JavaScript can then continue with other work.

## The Implementation

Add this function to `js/main.js`:

```javascript
function demonstrateNonBlockingWork() {
  console.log("Non-blocking example: start");

  setTimeout(() => {
    console.log("Non-blocking example: delayed callback");
  }, 3000);

  console.log("Non-blocking example: end");
}
```

Then call it temporarily at the bottom of the file:

```javascript
renderTasks();
updateStatus("Ready. Tasks are currently stored only in memory.");

demonstrateNonBlockingWork();
```

## The Verification

Refresh the page and inspect the browser console.

You should see this immediately:

```text
Non-blocking example: start
Non-blocking example: end
```

Approximately three seconds later, you should see:

```text
Non-blocking example: delayed callback
```

The important detail is the order:

```text
start
end
delayed callback
```

The delayed callback was written between the two `console.log` calls, but it ran afterward.

This happened because `setTimeout` registered the callback with the browser and allowed the current JavaScript code to finish.

Remove the temporary demonstration call:

```javascript
demonstrateNonBlockingWork();
```

You may leave the function in the file for now, although the next step will introduce a more useful callback example.

[COMPLETED: Step 6 — Non-blocking scheduling observed]  
[STARTING: Step 7 — Building a callback-based asynchronous loader]

---

# Step 7: Build an Asynchronous Task Loader

## The Target

Create a callback-based function that simulates loading tasks from a server.

The function will:

- Wait for a short period.
- Return sample tasks when successful.
- Return an error when requested.
- Use a callback to notify the caller.

## The Concept

A **callback** is a function passed to another function as an argument.

The receiving function calls the callback later, usually after an operation completes.

Imagine leaving your phone number with a repair shop:

1. You submit the repair.
2. The shop works on the device.
3. You do not stand inside the shop waiting.
4. The shop calls you when the work is complete.

Your phone number is similar to a callback. It tells the repair shop what route to use when the delayed work finishes.

A callback-based function often follows this pattern:

```javascript
function performWork(callback) {
  // Start delayed work.

  // Later:
  callback(error, result);
}
```

A common convention is **error-first callbacks**:

```javascript
callback(error, result);
```

- The first argument is an error or `null`.
- The second argument is the successful result or `undefined`.

## The Implementation

Add this function to `js/main.js`:

```javascript
function loadExampleTasks(shouldFail, callback) {
  /*
   * The browser starts the timer and immediately returns control
   * to the rest of the application.
   */
  setTimeout(() => {
    if (shouldFail) {
      const error = new Error(
        "The example task service could not load the tasks."
      );

      callback(error, undefined);
      return;
    }

    const exampleTasks = [
      {
        id: createTaskId(),
        title: "Read about the call stack",
        completed: false,
      },
      {
        id: createTaskId(),
        title: "Trace a timer through the event loop",
        completed: false,
      },
      {
        id: createTaskId(),
        title: "Explain why callbacks run later",
        completed: true,
      },
    ];

    callback(null, exampleTasks);
  }, 1500);
}
```

This function does not directly update the page. That is intentional.

The loader’s responsibility is to provide data or an error. The caller will decide what to do with that result.

## The Verification

Add this temporary test at the bottom of `js/main.js`:

```javascript
loadExampleTasks(false, (error, loadedTasks) => {
  if (error) {
    console.error("Loader test failed:", error);
    return;
  }

  console.log("Loader test succeeded:", loadedTasks);
});
```

Refresh the page.

Immediately, the normal page should remain responsive.

After approximately 1.5 seconds, the console should contain an array with three tasks.

Now replace:

```javascript
loadExampleTasks(false, (error, loadedTasks) => {
  if (error) {
    console.error("Loader test failed:", error);
    return;
  }

  console.log("Loader test succeeded:", loadedTasks);
});
```

with:

```javascript
loadExampleTasks(true, (error, loadedTasks) => {
  if (error) {
    console.error("Loader test failed as expected:", error.message);
    return;
  }

  console.log("Unexpected success:", loadedTasks);
});
```

Refresh the page.

After approximately 1.5 seconds, the console should show:

```text
Loader test failed as expected: The example task service could not load the tasks.
```

Remove this temporary test before continuing.

[COMPLETED: Step 7 — Callback-based asynchronous loader created]  
[STARTING: Step 8 — Connecting asynchronous loading to the user interface]

---

# Step 8: Add Loading and Error States

## The Target

Connect the **Load example tasks** button to the asynchronous loader.

The application will:

1. Disable the button.
2. Display a loading message.
3. Wait for the callback.
4. Display an error or success message.
5. Re-enable the button.

## The Concept

A user should not have to guess what the application is doing.

Without a loading state, a delayed button can look broken. Without an error state, a failed operation can look like silence.

A good asynchronous interface behaves like a delivery tracker:

- `Loading...` means the request is active.
- `Loaded successfully.` means the request finished.
- `Loading failed.` means the request finished unsuccessfully.

The button is disabled during the operation to prevent accidental duplicate requests.

## The Implementation

Add this function to `js/main.js`:

```javascript
function loadTasksIntoApplication() {
  loadTasksButton.disabled = true;
  updateStatus("Loading example tasks...", "loading");

  /*
   * Set this to true temporarily if you want to test
   * the failure path in the browser.
   */
  const shouldFail = false;

  loadExampleTasks(shouldFail, (error, loadedTasks) => {
    loadTasksButton.disabled = false;

    if (error) {
      console.error("Could not load example tasks:", error);
      updateStatus(
        `Could not load example tasks: ${error.message}`,
        "error"
      );
      return;
    }

    tasks = loadedTasks;
    renderTasks();
    updateStatus(
      `Loaded ${loadedTasks.length} example tasks successfully.`,
      "success"
    );
  });
}
```

Now add this event listener:

```javascript
loadTasksButton.addEventListener("click", () => {
  loadTasksIntoApplication();
});
```

Your file should still contain the functions and event listeners from the previous steps.

## The Verification

Refresh the page.

Click **Load example tasks**.

Immediately verify:

- The button becomes disabled.
- The status changes to `Loading example tasks...`.
- The task list remains responsive during the delay.

After approximately 1.5 seconds, verify:

- The button becomes enabled again.
- Three example tasks appear.
- The status changes to:

```text
Loaded 3 example tasks successfully.
```

Now test the failure path.

Change:

```javascript
const shouldFail = false;
```

to:

```javascript
const shouldFail = true;
```

Refresh the page and click **Load example tasks**.

You should see:

```text
Could not load example tasks: The example task service could not load the tasks.
```

The button should become enabled again after the failure.

Change the value back to:

```javascript
const shouldFail = false;
```

[COMPLETED: Step 8 — Loading and error states connected]  
[STARTING: Step 9 — Finalizing the complete Part 1 implementation]

---

# Step 9: Complete `main.js`

## The Target

Replace `js/main.js` with the complete Part 1 implementation.

The previous steps added code incrementally. This final file includes all required behavior in one copy-pasteable version.

## The Concept

A complete file prevents accidental omissions.

During development, adding small snippets is useful for learning. Before moving to the next part, it is also useful to establish a clean known-good version.

This file still intentionally uses:

- One application file.
- In-memory task data.
- Callback-based asynchronous loading.

Part 2 will modernize the asynchronous section.

## The Implementation

### `js/main.js`

```javascript
"use strict";

/*
 * The DOM references are collected once when the script loads.
 *
 * The script tag is placed at the end of <body> in index.html,
 * so these elements already exist when querySelector runs.
 */
const taskForm = document.querySelector("#task-form");
const taskTitleInput = document.querySelector("#task-title");
const taskList = document.querySelector("#task-list");
const taskCount = document.querySelector("#task-count");
const statusMessage = document.querySelector("#status-message");
const loadTasksButton = document.querySelector("#load-tasks-button");

/*
 * This application state is temporary in-memory state.
 *
 * It disappears when the browser page is refreshed.
 * Part 4 will replace this limitation with localStorage.
 */
let tasks = [
  {
    id: 1,
    title: "Understand synchronous JavaScript",
    completed: false,
  },
  {
    id: 2,
    title: "Practice reading the event loop",
    completed: false,
  },
];

function createTaskId() {
  /*
   * Date.now() provides a time-based value.
   * The random component reduces the chance of duplicate IDs
   * when multiple tasks are created during the same millisecond.
   */
  return Date.now() + Math.floor(Math.random() * 1000);
}

function updateStatus(message, state = "default") {
  statusMessage.textContent = message;
  statusMessage.className = "status-message";

  if (state === "loading") {
    statusMessage.classList.add("status-loading");
  }

  if (state === "success") {
    statusMessage.classList.add("status-success");
  }

  if (state === "error") {
    statusMessage.classList.add("status-error");
  }
}

function updateTaskCount() {
  const taskTotal = tasks.length;
  const completedTotal = tasks.filter((task) => task.completed).length;

  taskCount.textContent =
    `${taskTotal} ${taskTotal === 1 ? "task" : "tasks"} · ` +
    `${completedTotal} completed`;
}

function renderTasks() {
  /*
   * Remove all previously rendered children.
   *
   * The task array is the source of truth. The DOM is rebuilt from
   * that source so the page always reflects the current state.
   */
  taskList.replaceChildren();

  if (tasks.length === 0) {
    const emptyMessage = document.createElement("p");
    emptyMessage.className = "empty-state";
    emptyMessage.textContent = "No tasks yet.";
    taskList.append(emptyMessage);
    updateTaskCount();
    return;
  }

  tasks.forEach((task) => {
    const listItem = document.createElement("li");
    listItem.className = "task-item";

    if (task.completed) {
      listItem.classList.add("task-completed");
    }

    const textContainer = document.createElement("div");

    const title = document.createElement("p");
    title.className = "task-title";

    /*
     * textContent treats the title as text rather than HTML.
     * This prevents a user-entered title from injecting markup
     * into the document.
     */
    title.textContent = task.title;

    const metadata = document.createElement("p");
    metadata.className = "task-meta";
    metadata.textContent = task.completed ? "Completed" : "Not completed";

    textContainer.append(title, metadata);

    const completionButton = document.createElement("button");
    completionButton.className = "task-action";
    completionButton.type = "button";
    completionButton.dataset.taskId = String(task.id);
    completionButton.textContent = task.completed
      ? "Mark as incomplete"
      : "Mark as complete";

    completionButton.addEventListener("click", () => {
      toggleTaskCompletion(task.id);
    });

    listItem.append(textContainer, completionButton);
    taskList.append(listItem);
  });

  updateTaskCount();
}

function addTask(title) {
  const normalizedTitle = title.trim();

  if (normalizedTitle.length === 0) {
    updateStatus("Enter a task title before adding a task.", "error");
    return;
  }

  const newTask = {
    id: createTaskId(),
    title: normalizedTitle,
    completed: false,
  };

  tasks.push(newTask);
  renderTasks();
  updateStatus(`Added task: ${normalizedTitle}`, "success");
}

function toggleTaskCompletion(taskId) {
  tasks = tasks.map((task) => {
    if (task.id !== taskId) {
      return task;
    }

    return {
      ...task,
      completed: !task.completed,
    };
  });

  renderTasks();
  updateStatus("Task status updated.", "success");
}

/*
 * This function simulates an asynchronous server request.
 *
 * The callback follows the error-first convention:
 *
 * callback(error, result)
 *
 * On success:
 * callback(null, exampleTasks)
 *
 * On failure:
 * callback(error, undefined)
 */
function loadExampleTasks(shouldFail, callback) {
  setTimeout(() => {
    if (shouldFail) {
      const error = new Error(
        "The example task service could not load the tasks."
      );

      callback(error, undefined);
      return;
    }

    const exampleTasks = [
      {
        id: createTaskId(),
        title: "Read about the call stack",
        completed: false,
      },
      {
        id: createTaskId(),
        title: "Trace a timer through the event loop",
        completed: false,
      },
      {
        id: createTaskId(),
        title: "Explain why callbacks run later",
        completed: true,
      },
    ];

    callback(null, exampleTasks);
  }, 1500);
}

function loadTasksIntoApplication() {
  loadTasksButton.disabled = true;
  updateStatus("Loading example tasks...", "loading");

  /*
   * Change this to true when testing the failure path.
   * Keep it false for normal application behavior.
   */
  const shouldFail = false;

  loadExampleTasks(shouldFail, (error, loadedTasks) => {
    /*
     * The button must be restored on both success and failure.
     * This line therefore runs before the error check.
     */
    loadTasksButton.disabled = false;

    if (error) {
      console.error("Could not load example tasks:", error);
      updateStatus(
        `Could not load example tasks: ${error.message}`,
        "error"
      );
      return;
    }

    tasks = loadedTasks;
    renderTasks();
    updateStatus(
      `Loaded ${loadedTasks.length} example tasks successfully.`,
      "success"
    );
  });
}

taskForm.addEventListener("submit", (event) => {
  /*
   * The browser normally reloads the page after a form submission.
   * preventDefault() keeps the interaction inside our application.
   */
  event.preventDefault();

  addTask(taskTitleInput.value);
  taskTitleInput.value = "";
  taskTitleInput.focus();
});

loadTasksButton.addEventListener("click", () => {
  loadTasksIntoApplication();
});

renderTasks();
updateStatus("Ready. Tasks are currently stored only in memory.");
```

## The Verification

Refresh the page and run this complete test.

### Test 1: Initial rendering

Confirm that two tasks appear:

```text
Understand synchronous JavaScript
Practice reading the event loop
```

### Test 2: Add a task

Enter:

```text
Learn about callback functions
```

Click **Add task**.

Confirm that the new task appears.

### Test 3: Complete a task

Click **Mark as complete**.

Confirm that:

- The task receives a strikethrough.
- Its metadata changes to `Completed`.
- The completed count increases.

### Test 4: Successful asynchronous loading

Click **Load example tasks**.

Confirm that:

- The button disables immediately.
- The status shows a loading message.
- The page remains responsive.
- Three tasks replace the existing tasks after approximately 1.5 seconds.
- The button becomes enabled.

### Test 5: Failed asynchronous loading

Change:

```javascript
const shouldFail = false;
```

to:

```javascript
const shouldFail = true;
```

Refresh the page and click **Load example tasks**.

Confirm that:

- The button disables during loading.
- The error message appears.
- The button becomes enabled again.
- The browser console contains the error.

Restore the value:

```javascript
const shouldFail = false;
```

[COMPLETED: Step 9 — Complete Part 1 application implemented]  
[STARTING: Part 1 Reference — Asynchronous JavaScript concepts]

---

# Part 1 Reference: How JavaScript Handles Asynchronous Work

## Synchronous Execution

Consider this code:

```javascript
console.log("First");
console.log("Second");
console.log("Third");
```

JavaScript runs it in order:

```text
First
Second
Third
```

Each statement completes before the next statement begins.

A synchronous function call also blocks the current execution path:

```javascript
function greet() {
  console.log("Hello");
}

console.log("Before");
greet();
console.log("After");
```

Output:

```text
Before
Hello
After
```

The call to `greet()` must finish before JavaScript reaches the final `console.log`.

---

## The Call Stack

The **call stack** is the structure JavaScript uses to keep track of currently executing functions.

A stack behaves like a stack of plates:

- The last plate placed on top is the first plate removed.
- The last function called is the first function to finish.

Example:

```javascript
function first() {
  second();
}

function second() {
  console.log("Inside second");
}

first();
```

Execution conceptually proceeds like this:

1. `first()` is placed on the stack.
2. `second()` is placed on top of `first()`.
3. `console.log()` runs.
4. `second()` finishes and leaves the stack.
5. `first()` finishes and leaves the stack.

The stack must eventually become empty before queued asynchronous callbacks can run.

---

## Browser Web APIs

JavaScript itself does not directly wait inside `setTimeout`.

The browser provides timer functionality through a Web API.

When JavaScript executes:

```javascript
setTimeout(() => {
  console.log("Timer complete");
}, 1000);
```

the browser:

1. Receives the timer request.
2. Tracks the requested delay.
3. Allows the current JavaScript code to continue.
4. Places the callback into a queue after the delay has elapsed.
5. Waits for the JavaScript call stack to become empty.
6. Allows the callback to execute.

The timer specifies a minimum delay, not an exact execution time.

This does not mean:

> Run exactly one second from now.

It means:

> Do not make this callback eligible before one second has passed.

If the call stack is busy, the callback waits longer.

---

## The Event Loop

The **event loop** coordinates the call stack and callback queues.

A simplified model is:

```text
1. Is JavaScript currently executing?
2. If the call stack is empty, is there a callback ready?
3. Move a ready callback to the call stack.
4. Execute it.
5. Repeat.
```

For example:

```javascript
console.log("A");

setTimeout(() => {
  console.log("B");
}, 0);

console.log("C");
```

The result is:

```text
A
C
B
```

Even though the timer delay is `0`, the callback does not interrupt the current script.

The current synchronous code must finish first.

---

## Why `setTimeout(..., 0)` Is Not Immediate

This code:

```javascript
setTimeout(() => {
  console.log("Later");
}, 0);

console.log("Now");
```

prints:

```text
Now
Later
```

The `0` means the callback can become eligible as soon as possible. It does not mean the callback runs in the middle of the current code.

---

## Callback Functions

A callback is a function passed to another function:

```javascript
function runLater(callback) {
  setTimeout(() => {
    callback();
  }, 1000);
}

runLater(() => {
  console.log("The callback ran.");
});
```

The anonymous function is passed into `runLater`.

`runLater` calls it later.

Callbacks are not inherently bad. They are useful when:

- A function has one asynchronous operation.
- The callback contract is simple.
- The code does not require many dependent asynchronous steps.

The difficulty appears when callbacks become deeply nested.

---

## Callback Nesting

Imagine three operations that must happen in order:

1. Load a user.
2. Load that user’s projects.
3. Load tasks for the selected project.

A callback-based version might look like this:

```javascript
loadUser((userError, user) => {
  if (userError) {
    console.error(userError);
    return;
  }

  loadProjects(user.id, (projectError, projects) => {
    if (projectError) {
      console.error(projectError);
      return;
    }

    loadTasks(projects[0].id, (taskError, tasks) => {
      if (taskError) {
        console.error(taskError);
        return;
      }

      console.log(tasks);
    });
  });
});
```

This style can become difficult to read because:

- Indentation grows.
- Error handling is repeated.
- The main workflow is buried inside callbacks.
- Changes become harder to make safely.

Part 2 will introduce Promises to improve this structure.

---

## Error-First Callback Conventions

A common callback contract looks like this:

```javascript
callback(error, result);
```

Success:

```javascript
callback(null, result);
```

Failure:

```javascript
callback(error, undefined);
```

The caller checks the error first:

```javascript
performAsyncOperation((error, result) => {
  if (error) {
    handleError(error);
    return;
  }

  useResult(result);
});
```

The early `return` is important. It prevents the success path from running after an error.

---

## The Importance of Returning After an Error

This is unsafe:

```javascript
performAsyncOperation((error, result) => {
  if (error) {
    console.error(error);
  }

  renderResult(result);
});
```

If an error occurs, `renderResult(result)` still runs. The result may be `undefined` or invalid.

This is safer:

```javascript
performAsyncOperation((error, result) => {
  if (error) {
    console.error(error);
    return;
  }

  renderResult(result);
});
```

The `return` exits the callback immediately.

---

## Event Callbacks

Browser events also use callbacks:

```javascript
button.addEventListener("click", () => {
  console.log("The button was clicked.");
});
```

The browser stores the callback and invokes it when the event occurs.

The callback does not execute when it is registered. It executes later, after the user clicks.

The same pattern appears in:

```javascript
input.addEventListener("input", handleInput);
window.addEventListener("resize", handleResize);
document.addEventListener("DOMContentLoaded", startApplication);
```

---

## Common Asynchronous Sources

Browser applications commonly perform asynchronous work when they:

- Wait for a timer.
- Make a network request.
- Read a file.
- Wait for a user event.
- Access certain browser APIs.
- Schedule animation work.

Examples:

```javascript
setTimeout(() => {
  console.log("Timer finished.");
}, 500);
```

```javascript
button.addEventListener("click", () => {
  console.log("Click received.");
});
```

```javascript
fetch("/api/tasks")
  .then((response) => {
    console.log("Response received.");
  });
```

The `fetch` example uses Promises, which we will study next.

---

# Part 1 Troubleshooting

## The Page Is Blank

Check the browser console for syntax errors.

Common causes include:

- A missing closing brace.
- A missing quote.
- A file saved in the wrong directory.
- A typo in the script path.

The script path in `index.html` must be:

```html
<script src="./js/main.js"></script>
```

## The Button Does Nothing

Verify that the button ID in `index.html` matches the selector in JavaScript:

```html
<button id="load-tasks-button" type="button">
  Load example tasks
</button>
```

```javascript
const loadTasksButton = document.querySelector("#load-tasks-button");
```

The IDs must match exactly.

## The Task List Does Not Update

Check that `renderTasks()` is called after changing the `tasks` array.

For example:

```javascript
tasks.push(newTask);
renderTasks();
```

Changing data alone does not automatically change the DOM. The application must explicitly render the updated state.

## The Loading Button Remains Disabled

Verify that this line runs inside the callback before the error check:

```javascript
loadTasksButton.disabled = false;
```

It must run on both successful and failed requests.

## The Error Path Never Appears

Confirm that the test value is:

```javascript
const shouldFail = true;
```

Then refresh the page before clicking the button.

Restore it to:

```javascript
const shouldFail = false;
```

after testing.

---

# Part 1 Completion Checklist

You have completed Part 1 when you can explain and demonstrate all of the following:

- Synchronous code runs one operation at a time.
- A long-running synchronous operation blocks the page.
- `setTimeout` schedules work without blocking the current script.
- A callback is a function passed to another function.
- The browser manages timers through Web APIs.
- A callback waits until the call stack is available.
- A zero-millisecond timer is still asynchronous.
- Error-first callbacks commonly use `(error, result)`.
- The caller should return immediately after handling an error.
- Loading, success, and failure states improve the user experience.
- The task application can load example data asynchronously.
