# Part 4: Connecting JavaScript to the DOM & Events

So far, JavaScript has worked with data and printed results into a `<pre>` element. Now we will connect the data to an interactive browser interface.

This is where the application begins to feel like a real web application.

The user will be able to:

- Type a task title.
- Submit a form.
- See the task appear immediately.
- Mark a task complete.
- Remove a task.
- See the task count update.
- Receive validation messages.
- Use buttons generated dynamically by JavaScript.

The central application cycle is:

```text
User interaction
    ↓
Event listener
    ↓
Read input
    ↓
Validate input
    ↓
Update task data
    ↓
Render task data into the DOM
```

The **DOM**, or Document Object Model, is the browser’s object-based representation of the HTML document.

For this page:

```text
HTML document
│
└── main
    ├── heading
    ├── form
    │   ├── label
    │   ├── input
    │   └── submit button
    │
    ├── status message
    └── task list
```

JavaScript will find those elements and update them.

[COMPLETED: Part 4 introduction]  
[STARTING: Step 1 — Create the interactive page structure]

---

# Step 1: Create the Interactive HTML Page

## The Target

We will replace the previous demonstration page with the structure for the task application.

The file remains:

```text
index.html
```

## The Concept

HTML defines the interface’s permanent structure. JavaScript will later create individual task items inside the empty `<ul>` element.

The form gives users a standard browser interaction:

```text
label + input + submit button
```

The task list begins empty because the JavaScript data will be the source used to render it.

## The Implementation

### `index.html`

Replace the complete file with:

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>JavaScript Task List</title>

    <link rel="stylesheet" href="./styles.css" />
  </head>

  <body>
    <main class="app-shell">
      <header class="app-header">
        <p class="eyebrow">JavaScript Foundations</p>

        <h1>Task List</h1>

        <p>
          Add tasks, mark them complete, and remove them without
          refreshing the page.
        </p>
      </header>

      <section
        class="task-panel"
        aria-labelledby="task-form-heading"
      >
        <h2 id="task-form-heading">Add a task</h2>

        <form id="task-form">
          <div class="form-row">
            <label for="task-title">Task title</label>

            <input
              id="task-title"
              name="title"
              type="text"
              maxlength="120"
              autocomplete="off"
              placeholder="For example, Practice DOM events"
              required
            />

            <button type="submit">
              Add task
            </button>
          </div>

          <p
            id="form-message"
            class="form-message"
            role="status"
            aria-live="polite"
          ></p>
        </form>
      </section>

      <section
        class="task-panel"
        aria-labelledby="task-list-heading"
      >
        <div class="section-heading">
          <h2 id="task-list-heading">Your tasks</h2>

          <p id="task-count">0 tasks</p>
        </div>

        <ul
          id="task-list"
          class="task-list"
          aria-live="polite"
        ></ul>

        <p id="empty-state" class="empty-state">
          No tasks yet. Add your first task above.
        </p>
      </section>
    </main>

    <script src="./src/part-4.js" defer></script>
  </body>
</html>
```

## The Verification

Open or refresh `index.html`.

You should see:

- A “Task List” heading.
- A text input.
- An “Add task” button.
- An empty task message.
- A `0 tasks` count.

The task list itself should be empty.

The browser console may show an error because `styles.css` and `src/part-4.js` do not exist yet. That is expected.

[COMPLETED: Step 1 — Interactive HTML structure created]  
[STARTING: Step 2 — Add page styling]

---

# Step 2: Add the CSS

## The Target

We will create:

```text
styles.css
```

This file provides readable layout and visual states for completed tasks and messages.

## The Concept

CSS controls presentation, not application behavior.

The JavaScript will add or remove classes such as:

```text
.task-item--completed
.form-message--error
.form-message--success
```

CSS then decides how those states look.

This separation is useful:

```text
JavaScript: What state is this task in?
CSS:       How should that state look?
```

## The Implementation

### `styles.css`

```css
:root {
  color-scheme: light;
  font-family:
    Inter,
    ui-sans-serif,
    system-ui,
    -apple-system,
    BlinkMacSystemFont,
    "Segoe UI",
    sans-serif;
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
  margin: 0;
  background:
    linear-gradient(135deg, #eef2f7 0%, #dfe8f5 100%);
}

button,
input {
  font: inherit;
}

button {
  border: 0;
  border-radius: 0.5rem;
  cursor: pointer;
}

button:focus-visible,
input:focus-visible {
  outline: 3px solid #8bb8ff;
  outline-offset: 2px;
}

.app-shell {
  width: min(100% - 2rem, 760px);
  margin: 0 auto;
  padding: 3rem 0;
}

.app-header {
  margin-bottom: 1.5rem;
}

.app-header h1 {
  margin: 0.25rem 0 0.5rem;
  color: #101828;
  font-size: clamp(2rem, 5vw, 3rem);
  line-height: 1.1;
}

.app-header p {
  max-width: 60ch;
  margin: 0;
  color: #475467;
}

.eyebrow {
  color: #2457a6 !important;
  font-size: 0.8rem;
  font-weight: 800;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.task-panel {
  margin-top: 1rem;
  padding: 1.25rem;
  border: 1px solid #d0d5dd;
  border-radius: 0.875rem;
  background: #ffffff;
  box-shadow:
    0 0.5rem 1.5rem rgb(16 24 40 / 8%);
}

.task-panel h2 {
  margin: 0 0 1rem;
  color: #101828;
  font-size: 1.2rem;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 0.75rem;
  align-items: end;
}

.form-row label {
  grid-column: 1 / -1;
  color: #344054;
  font-weight: 700;
}

.form-row input {
  min-width: 0;
  padding: 0.75rem;
  border: 1px solid #98a2b3;
  border-radius: 0.5rem;
  color: #172033;
  background: #ffffff;
}

.form-row button {
  padding: 0.75rem 1rem;
  color: #ffffff;
  background: #2457a6;
  font-weight: 700;
}

.form-row button:hover {
  background: #1e4788;
}

.form-message {
  min-height: 1.5rem;
  margin: 0.75rem 0 0;
  color: #475467;
}

.form-message--error {
  color: #b42318;
}

.form-message--success {
  color: #067647;
}

.section-heading {
  display: flex;
  gap: 1rem;
  align-items: baseline;
  justify-content: space-between;
}

.section-heading h2 {
  margin-bottom: 0;
}

#task-count {
  margin: 0;
  color: #667085;
  font-size: 0.95rem;
  font-weight: 700;
}

.task-list {
  display: grid;
  gap: 0.75rem;
  margin: 0;
  padding: 0;
  list-style: none;
}

.task-item {
  display: flex;
  gap: 0.75rem;
  align-items: center;
  justify-content: space-between;
  padding: 0.875rem;
  border: 1px solid #d0d5dd;
  border-radius: 0.625rem;
  background: #fcfcfd;
}

.task-item__content {
  min-width: 0;
}

.task-item__title {
  margin: 0;
  overflow-wrap: anywhere;
  color: #172033;
  font-weight: 700;
}

.task-item__id {
  margin: 0.25rem 0 0;
  color: #667085;
  font-size: 0.8rem;
}

.task-item--completed .task-item__title {
  color: #667085;
  text-decoration: line-through;
}

.task-item__actions {
  display: flex;
  flex-shrink: 0;
  gap: 0.5rem;
}

.task-item__actions button {
  padding: 0.5rem 0.7rem;
  color: #ffffff;
  background: #475467;
  font-size: 0.85rem;
  font-weight: 700;
}

.task-item__actions button:hover {
  background: #344054;
}

.task-item__actions .task-item__remove {
  background: #b42318;
}

.task-item__actions .task-item__remove:hover {
  background: #912018;
}

.empty-state {
  margin: 1rem 0 0;
  color: #667085;
  text-align: center;
}

[hidden] {
  display: none !important;
}

@media (max-width: 560px) {
  .app-shell {
    width: min(100% - 1rem, 760px);
    padding: 1.5rem 0;
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .task-item {
    align-items: flex-start;
    flex-direction: column;
  }

  .task-item__actions {
    width: 100%;
  }

  .task-item__actions button {
    flex: 1;
  }
}
```

## The Verification

Refresh the browser.

The page should now have:

- A centered application layout.
- White task panels.
- A styled input and button.
- A responsive layout on narrow screens.
- Empty state text beneath the task section.

[COMPLETED: Step 2 — Interface styling added]  
[STARTING: Step 3 — Select DOM elements safely]

---

# Step 3: Create the JavaScript Entry Point and Select Elements

## The Target

We will create:

```text
src/part-4.js
```

The first version will select every DOM element the application needs.

## The Concept

`document.querySelector()` searches the current document using a CSS selector.

Examples:

```js
document.querySelector("#task-form");
document.querySelector(".task-list");
document.querySelector("button");
```

An ID selector beginning with `#` should identify one specific element.

We will validate every required element. If one is missing, the application should fail with a useful message instead of producing an unrelated error later.

## The Implementation

### `src/part-4.js`

```js
"use strict";

const taskFormElement = document.querySelector("#task-form");
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

if (taskFormElement === null) {
  throw new Error("Could not find the #task-form element.");
}

if (taskTitleInputElement === null) {
  throw new Error("Could not find the #task-title element.");
}

if (formMessageElement === null) {
  throw new Error("Could not find the #form-message element.");
}

if (taskListElement === null) {
  throw new Error("Could not find the #task-list element.");
}

if (emptyStateElement === null) {
  throw new Error("Could not find the #empty-state element.");
}

if (taskCountElement === null) {
  throw new Error("Could not find the #task-count element.");
}

formMessageElement.textContent =
  "The DOM elements were selected successfully.";

console.log("Selected DOM elements:", {
  taskFormElement,
  taskTitleInputElement,
  formMessageElement,
  taskListElement,
  emptyStateElement,
  taskCountElement
});
```

## The Verification

Refresh the browser.

You should see:

```text
The DOM elements were selected successfully.
```

Open the console and expand the logged object. Each property should reference a real HTML element.

[COMPLETED: Step 3 — DOM element selection verified]  
[STARTING: Step 4 — Build and render task data]

---

# Step 4: Create Task Data and Render the List

## The Target

We will add:

- A task array.
- A task creation function.
- A rendering function.
- DOM elements generated from task objects.

## The Concept

**Rendering** means converting data into visible interface elements.

The data:

```js
{
  id: 1,
  title: "Learn the DOM",
  completed: false
}
```

will become an HTML structure:

```html
<li>
  <p>Learn the DOM</p>
  <button>Complete</button>
  <button>Remove</button>
</li>
```

The rendering function will rebuild the visible list from the current array.

This approach is simple and reliable:

```text
Clear visible list
    ↓
Loop through current tasks
    ↓
Create one list item per task
    ↓
Append each item
```

For user-entered text, we will use `textContent`, not `innerHTML`. `textContent` treats the title as text rather than interpreting it as HTML, which prevents a user from injecting markup into the page.

## The Implementation

Replace `src/part-4.js` with:

### `src/part-4.js`

```js
"use strict";

const taskFormElement = document.querySelector("#task-form");
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

if (taskFormElement === null) {
  throw new Error("Could not find the #task-form element.");
}

if (taskTitleInputElement === null) {
  throw new Error("Could not find the #task-title element.");
}

if (formMessageElement === null) {
  throw new Error("Could not find the #form-message element.");
}

if (taskListElement === null) {
  throw new Error("Could not find the #task-list element.");
}

if (emptyStateElement === null) {
  throw new Error("Could not find the #empty-state element.");
}

if (taskCountElement === null) {
  throw new Error("Could not find the #task-count element.");
}

function createTask(title, id) {
  return {
    id,
    title,
    completed: false
  };
}

function createTaskElement(task) {
  const listItemElement = document.createElement("li");
  listItemElement.className = "task-item";

  if (task.completed) {
    listItemElement.classList.add("task-item--completed");
  }

  const contentElement = document.createElement("div");
  contentElement.className = "task-item__content";

  const titleElement = document.createElement("p");
  titleElement.className = "task-item__title";
  titleElement.textContent = task.title;

  const idElement = document.createElement("p");
  idElement.className = "task-item__id";
  idElement.textContent = `Task id: ${task.id}`;

  const actionsElement = document.createElement("div");
  actionsElement.className = "task-item__actions";

  const completeButtonElement =
    document.createElement("button");

  completeButtonElement.type = "button";
  completeButtonElement.className =
    "task-item__complete";
  completeButtonElement.textContent = task.completed
    ? "Undo"
    : "Complete";

  const removeButtonElement =
    document.createElement("button");

  removeButtonElement.type = "button";
  removeButtonElement.className =
    "task-item__remove";
  removeButtonElement.textContent = "Remove";

  contentElement.append(titleElement, idElement);

  actionsElement.append(
    completeButtonElement,
    removeButtonElement
  );

  listItemElement.append(
    contentElement,
    actionsElement
  );

  return listItemElement;
}

function renderTasks(tasks) {
  taskListElement.replaceChildren();

  for (const task of tasks) {
    const taskElement = createTaskElement(task);
    taskListElement.append(taskElement);
  }

  emptyStateElement.hidden = tasks.length > 0;

  const taskLabel = tasks.length === 1
    ? "task"
    : "tasks";

  taskCountElement.textContent =
    `${tasks.length} ${taskLabel}`;
}

const tasks = [
  createTask("Learn the DOM", 1),
  createTask("Practice element creation", 2)
];

renderTasks(tasks);

formMessageElement.textContent =
  "Tasks were rendered successfully.";

console.log("Initial tasks:", tasks);
```

## The Verification

Refresh the browser.

You should see:

```text
Learn the DOM
Task id: 1
Complete
Remove
```

and:

```text
Practice element creation
Task id: 2
Complete
Remove
```

The count should be:

```text
2 tasks
```

The empty-state message should be hidden.

Inspect one task in Developer Tools. Each task should be a real `<li>` element created by JavaScript.

[COMPLETED: Step 4 — Task rendering verified]  
[STARTING: Step 5 — Handle form submission]

---

# Step 5: Listen for Form Submission

## The Target

We will allow users to add tasks through the form.

## The Concept

A browser form normally tries to navigate or reload the page when submitted.

For a client-side application, we want to handle the submission ourselves. The event object provides:

```js
event.preventDefault();
```

This stops the browser’s default form behavior.

The submission sequence will be:

```text
Submit form
    ↓
Prevent page reload
    ↓
Read input value
    ↓
Trim whitespace
    ↓
Reject empty text
    ↓
Create task
    ↓
Add task to array
    ↓
Render tasks
    ↓
Clear input
```

## The Implementation

Replace `src/part-4.js` with:

### `src/part-4.js`

```js
"use strict";

const taskFormElement = document.querySelector("#task-form");
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

if (taskFormElement === null) {
  throw new Error("Could not find the #task-form element.");
}

if (taskTitleInputElement === null) {
  throw new Error("Could not find the #task-title element.");
}

if (formMessageElement === null) {
  throw new Error("Could not find the #form-message element.");
}

if (taskListElement === null) {
  throw new Error("Could not find the #task-list element.");
}

if (emptyStateElement === null) {
  throw new Error("Could not find the #empty-state element.");
}

if (taskCountElement === null) {
  throw new Error("Could not find the #task-count element.");
}

function createTask(title, id) {
  return {
    id,
    title,
    completed: false
  };
}

function createTaskElement(task) {
  const listItemElement = document.createElement("li");
  listItemElement.className = "task-item";

  if (task.completed) {
    listItemElement.classList.add("task-item--completed");
  }

  const contentElement = document.createElement("div");
  contentElement.className = "task-item__content";

  const titleElement = document.createElement("p");
  titleElement.className = "task-item__title";
  titleElement.textContent = task.title;

  const idElement = document.createElement("p");
  idElement.className = "task-item__id";
  idElement.textContent = `Task id: ${task.id}`;

  const actionsElement = document.createElement("div");
  actionsElement.className = "task-item__actions";

  const completeButtonElement =
    document.createElement("button");

  completeButtonElement.type = "button";
  completeButtonElement.className =
    "task-item__complete";
  completeButtonElement.textContent = task.completed
    ? "Undo"
    : "Complete";

  const removeButtonElement =
    document.createElement("button");

  removeButtonElement.type = "button";
  removeButtonElement.className =
    "task-item__remove";
  removeButtonElement.textContent = "Remove";

  contentElement.append(titleElement, idElement);

  actionsElement.append(
    completeButtonElement,
    removeButtonElement
  );

  listItemElement.append(
    contentElement,
    actionsElement
  );

  return listItemElement;
}

function renderTasks(tasks) {
  taskListElement.replaceChildren();

  for (const task of tasks) {
    taskListElement.append(createTaskElement(task));
  }

  emptyStateElement.hidden = tasks.length > 0;

  const taskLabel = tasks.length === 1
    ? "task"
    : "tasks";

  taskCountElement.textContent =
    `${tasks.length} ${taskLabel}`;
}

const tasks = [
  createTask("Learn the DOM", 1),
  createTask("Practice element creation", 2)
];

let nextTaskId = 3;

taskFormElement.addEventListener("submit", (event) => {
  event.preventDefault();

  const title = taskTitleInputElement.value.trim();

  if (title.length === 0) {
    formMessageElement.textContent =
      "Enter a task title before submitting.";

    formMessageElement.className =
      "form-message form-message--error";

    taskTitleInputElement.focus();
    return;
  }

  const task = createTask(title, nextTaskId);
  nextTaskId += 1;

  tasks.push(task);

  renderTasks(tasks);

  formMessageElement.textContent =
    `Added task: ${task.title}`;

  formMessageElement.className =
    "form-message form-message--success";

  taskFormElement.reset();
  taskTitleInputElement.focus();
});

renderTasks(tasks);

console.log("Form submission handler is ready.");
```

## The Verification

Refresh the browser.

Test a valid task:

1. Type:

```text
Practice form submission
```

2. Click **Add task**.

The new task should appear without a page reload.

The count should increase from:

```text
2 tasks
```

to:

```text
3 tasks
```

The message should say:

```text
Added task: Practice form submission
```

Test invalid input:

1. Leave the input empty.
2. Click **Add task**.

You should see:

```text
Enter a task title before submitting.
```

The task count should not change.

Test whitespace-only input:

```text
     
```

It should also be rejected because `.trim()` produces an empty string.

[COMPLETED: Step 5 — Form submission and validation verified]  
[STARTING: Step 6 — Handle dynamically created task buttons]

---

# Step 6: Event Bubbling and Event Delegation

## The Target

We will make the **Complete** and **Remove** buttons work.

The buttons are created dynamically inside `createTaskElement`, so we need an event strategy that works for elements added after the initial page load.

## The Concept

### Event bubbling

When an event happens on a child element, it travels upward through its ancestors.

```text
button click
    ↑
actions container
    ↑
task list item
    ↑
task list
    ↑
body
```

This upward travel is called **event bubbling**.

### Event delegation

Instead of adding a listener to every button, we add one listener to the stable parent:

```js
taskListElement.addEventListener("click", ...)
```

The parent examines `event.target` to determine which child was clicked.

This is useful because:

- It uses one event listener.
- It works for dynamically added tasks.
- It keeps related task actions in one place.

## The Implementation

Replace `src/part-4.js` with:

### `src/part-4.js`

```js
"use strict";

const taskFormElement = document.querySelector("#task-form");
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

if (taskFormElement === null) {
  throw new Error("Could not find the #task-form element.");
}

if (taskTitleInputElement === null) {
  throw new Error("Could not find the #task-title element.");
}

if (formMessageElement === null) {
  throw new Error("Could not find the #form-message element.");
}

if (taskListElement === null) {
  throw new Error("Could not find the #task-list element.");
}

if (emptyStateElement === null) {
  throw new Error("Could not find the #empty-state element.");
}

if (taskCountElement === null) {
  throw new Error("Could not find the #task-count element.");
}

function createTask(title, id) {
  return {
    id,
    title,
    completed: false
  };
}

function createTaskElement(task) {
  const listItemElement = document.createElement("li");
  listItemElement.className = "task-item";
  listItemElement.dataset.taskId = String(task.id);

  if (task.completed) {
    listItemElement.classList.add("task-item--completed");
  }

  const contentElement = document.createElement("div");
  contentElement.className = "task-item__content";

  const titleElement = document.createElement("p");
  titleElement.className = "task-item__title";
  titleElement.textContent = task.title;

  const idElement = document.createElement("p");
  idElement.className = "task-item__id";
  idElement.textContent = `Task id: ${task.id}`;

  const actionsElement = document.createElement("div");
  actionsElement.className = "task-item__actions";

  const completeButtonElement =
    document.createElement("button");

  completeButtonElement.type = "button";
  completeButtonElement.className =
    "task-item__complete";
  completeButtonElement.dataset.action = "toggle-complete";
  completeButtonElement.textContent = task.completed
    ? "Undo"
    : "Complete";

  const removeButtonElement =
    document.createElement("button");

  removeButtonElement.type = "button";
  removeButtonElement.className =
    "task-item__remove";
  removeButtonElement.dataset.action = "remove";
  removeButtonElement.textContent = "Remove";

  contentElement.append(titleElement, idElement);

  actionsElement.append(
    completeButtonElement,
    removeButtonElement
  );

  listItemElement.append(
    contentElement,
    actionsElement
  );

  return listItemElement;
}

function renderTasks(tasks) {
  taskListElement.replaceChildren();

  for (const task of tasks) {
    taskListElement.append(createTaskElement(task));
  }

  emptyStateElement.hidden = tasks.length > 0;

  const taskLabel = tasks.length === 1
    ? "task"
    : "tasks";

  taskCountElement.textContent =
    `${tasks.length} ${taskLabel}`;
}

function findTaskById(tasks, taskId) {
  return tasks.find((task) => task.id === taskId);
}

function removeTaskById(tasks, taskId) {
  const taskIndex = tasks.findIndex(
    (task) => task.id === taskId
  );

  if (taskIndex === -1) {
    return false;
  }

  tasks.splice(taskIndex, 1);
  return true;
}

const tasks = [
  createTask("Learn the DOM", 1),
  createTask("Practice element creation", 2)
];

let nextTaskId = 3;

taskFormElement.addEventListener("submit", (event) => {
  event.preventDefault();

  const title = taskTitleInputElement.value.trim();

  if (title.length === 0) {
    formMessageElement.textContent =
      "Enter a task title before submitting.";

    formMessageElement.className =
      "form-message form-message--error";

    taskTitleInputElement.focus();
    return;
  }

  const task = createTask(title, nextTaskId);
  nextTaskId += 1;

  tasks.push(task);
  renderTasks(tasks);

  formMessageElement.textContent =
    `Added task: ${task.title}`;

  formMessageElement.className =
    "form-message form-message--success";

  taskFormElement.reset();
  taskTitleInputElement.focus();
});

taskListElement.addEventListener("click", (event) => {
  /*
    event.target may be a nested element inside the button.
    closest() finds the nearest matching button ancestor.
  */
  if (!(event.target instanceof Element)) {
    return;
  }

  const actionButton = event.target.closest("button");

  if (actionButton === null) {
    return;
  }

  const taskElement = actionButton.closest("[data-task-id]");

  if (taskElement === null) {
    return;
  }

  const taskId = Number(taskElement.dataset.taskId);

  if (!Number.isSafeInteger(taskId)) {
    console.error("Invalid task id:", taskElement.dataset.taskId);
    return;
  }

  const action = actionButton.dataset.action;
  const task = findTaskById(tasks, taskId);

  if (task === undefined) {
    console.error("Task was not found:", taskId);
    return;
  }

  if (action === "toggle-complete") {
    task.completed = !task.completed;

    formMessageElement.textContent = task.completed
      ? `Completed task: ${task.title}`
      : `Reopened task: ${task.title}`;

    formMessageElement.className =
      "form-message form-message--success";

    renderTasks(tasks);
    return;
  }

  if (action === "remove") {
    const removed = removeTaskById(tasks, taskId);

    if (!removed) {
      console.error("Could not remove task:", taskId);
      return;
    }

    formMessageElement.textContent =
      `Removed task: ${task.title}`;

    formMessageElement.className =
      "form-message form-message--success";

    renderTasks(tasks);
  }
});

renderTasks(tasks);

console.log("Task action event delegation is ready.");
```

## The Verification

Refresh the browser.

Test completion:

1. Click **Complete** on the first task.
2. The task title should receive a strikethrough.
3. The button should change to **Undo**.
4. The message should say:

```text
Completed task: Learn the DOM
```

5. Click **Undo**.
6. The strikethrough should disappear.

Test removal:

1. Click **Remove** on a task.
2. The task should disappear.
3. The count should decrease.
4. When all tasks are removed, the empty-state message should return.

Test dynamically created tasks:

1. Add a new task.
2. Click **Complete** on that new task.
3. Click **Remove** on that new task.

Both actions should work even though the task buttons did not exist when the page first loaded.

[COMPLETED: Step 6 — Event bubbling and delegation verified]  
[STARTING: Step 7 — Class toggling and direct DOM updates]

---

# Step 7: Use `classList` and Direct DOM Updates

## The Target

We will explicitly practice:

- `textContent`.
- `classList.add`.
- `classList.remove`.
- `classList.toggle`.
- `classList.contains`.

## The Concept

A CSS class is a label describing an element’s state.

For a completed task:

```text
task-item
task-item--completed
```

`classList` is the browser API for managing those labels.

Useful methods include:

```js
element.classList.add("class-name");
element.classList.remove("class-name");
element.classList.toggle("class-name");
element.classList.contains("class-name");
```

A toggle is like a light switch:

- On becomes off.
- Off becomes on.

Although the final application will render from data, understanding direct class manipulation is essential for DOM programming.

## The Implementation

In `src/part-4.js`, replace the `taskListElement.addEventListener("click", ...)` handler with the following complete handler:

### `src/part-4.js`

```js
taskListElement.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) {
    return;
  }

  const actionButton = event.target.closest("button");

  if (actionButton === null) {
    return;
  }

  const taskElement = actionButton.closest("[data-task-id]");

  if (taskElement === null) {
    return;
  }

  const taskId = Number(taskElement.dataset.taskId);

  if (!Number.isSafeInteger(taskId)) {
    console.error("Invalid task id:", taskElement.dataset.taskId);
    return;
  }

  const task = findTaskById(tasks, taskId);

  if (task === undefined) {
    console.error("Task was not found:", taskId);
    return;
  }

  const action = actionButton.dataset.action;

  if (action === "toggle-complete") {
    task.completed = !task.completed;

    /*
      The data is the source of truth.
      The class is updated to reflect the new data state.
    */
    taskElement.classList.toggle(
      "task-item--completed",
      task.completed
    );

    actionButton.textContent = task.completed
      ? "Undo"
      : "Complete";

    formMessageElement.textContent = task.completed
      ? `Completed task: ${task.title}`
      : `Reopened task: ${task.title}`;

    formMessageElement.className =
      "form-message form-message--success";

    return;
  }

  if (action === "remove") {
    const removed = removeTaskById(tasks, taskId);

    if (!removed) {
      console.error("Could not remove task:", taskId);
      return;
    }

    taskElement.remove();

    emptyStateElement.hidden = tasks.length > 0;

    const taskLabel = tasks.length === 1
      ? "task"
      : "tasks";

    taskCountElement.textContent =
      `${tasks.length} ${taskLabel}`;

    formMessageElement.textContent =
      `Removed task: ${task.title}`;

    formMessageElement.className =
      "form-message form-message--success";
  }
});
```

## The Verification

Refresh the browser.

Confirm:

- Completing a task toggles `task-item--completed`.
- The button label changes.
- Removing a task calls `.remove()`.
- The count updates.
- The empty-state visibility updates.

In Developer Tools, inspect a completed task. Its class list should contain:

```text
task-item task-item--completed
```

[COMPLETED: Step 7 — Class manipulation and direct updates verified]  
[STARTING: Step 8 — Final production-quality browser implementation]

---

# Step 8: Complete Part 4 Application

## The Target

We will now replace the JavaScript file with the complete final implementation.

This version combines:

- DOM selection.
- Input validation.
- Task data.
- Safe DOM creation.
- Rendering.
- Form events.
- Event delegation.
- Event bubbling.
- Class toggling.
- Empty-state handling.
- Status messages.
- Defensive validation.

## The Concept

The final application uses a small, clear architecture:

```text
DOM references
    ↓
Data functions
    ↓
Rendering functions
    ↓
Event handlers
    ↓
Initial render
```

The `tasks` array is the current application state.

The DOM is a visible representation of that state.

When state changes, we render the interface again or update the affected element.

## The Implementation

### `src/part-4.js`

```js
"use strict";

/*
  Part 4: Connecting JavaScript to the DOM and events.

  Application architecture:

  1. Select required DOM elements.
  2. Define task-data functions.
  3. Define rendering functions.
  4. Define event handlers.
  5. Render the initial state.
*/

/*
  DOM ELEMENT REFERENCES
*/

const taskFormElement = document.querySelector("#task-form");
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

if (taskFormElement === null) {
  throw new Error("Could not find the #task-form element.");
}

if (taskTitleInputElement === null) {
  throw new Error("Could not find the #task-title element.");
}

if (formMessageElement === null) {
  throw new Error("Could not find the #form-message element.");
}

if (taskListElement === null) {
  throw new Error("Could not find the #task-list element.");
}

if (emptyStateElement === null) {
  throw new Error("Could not find the #empty-state element.");
}

if (taskCountElement === null) {
  throw new Error("Could not find the #task-count element.");
}

/*
  TASK DATA FUNCTIONS
*/

function createTask(title, id) {
  if (typeof title !== "string") {
    throw new TypeError("Task title must be a string.");
  }

  const cleanedTitle = title.trim();

  if (cleanedTitle.length === 0) {
    throw new Error("Task title cannot be empty.");
  }

  if (cleanedTitle.length > 120) {
    throw new Error(
      "Task title cannot be longer than 120 characters."
    );
  }

  if (!Number.isSafeInteger(id) || id < 0) {
    throw new RangeError(
      "Task id must be a non-negative safe integer."
    );
  }

  return {
    id,
    title: cleanedTitle,
    completed: false
  };
}

function findTaskById(tasks, taskId) {
  return tasks.find((task) => task.id === taskId);
}

function removeTaskById(tasks, taskId) {
  const taskIndex = tasks.findIndex(
    (task) => task.id === taskId
  );

  if (taskIndex === -1) {
    return false;
  }

  tasks.splice(taskIndex, 1);
  return true;
}

function getTaskLabel(taskCount) {
  return taskCount === 1
    ? "task"
    : "tasks";
}

/*
  DOM RENDERING FUNCTIONS
*/

function createTaskElement(task) {
  const listItemElement = document.createElement("li");

  listItemElement.className = "task-item";

  /*
    data-* attributes store small pieces of custom metadata
    on HTML elements. Values are strings in the DOM, so the
    event handler converts the task ID back into a number.
  */
  listItemElement.dataset.taskId = String(task.id);

  if (task.completed) {
    listItemElement.classList.add("task-item--completed");
  }

  const contentElement = document.createElement("div");
  contentElement.className = "task-item__content";

  const titleElement = document.createElement("p");
  titleElement.className = "task-item__title";

  /*
    textContent safely inserts user-provided text as text.
    Do not use innerHTML for untrusted task titles.
  */
  titleElement.textContent = task.title;

  const idElement = document.createElement("p");
  idElement.className = "task-item__id";
  idElement.textContent = `Task id: ${task.id}`;

  const actionsElement = document.createElement("div");
  actionsElement.className = "task-item__actions";

  const completeButtonElement =
    document.createElement("button");

  completeButtonElement.type = "button";
  completeButtonElement.className =
    "task-item__complete";
  completeButtonElement.dataset.action = "toggle-complete";
  completeButtonElement.textContent = task.completed
    ? "Undo"
    : "Complete";
  completeButtonElement.setAttribute(
    "aria-label",
    task.completed
      ? `Mark ${task.title} incomplete`
      : `Mark ${task.title} complete`
  );

  const removeButtonElement =
    document.createElement("button");

  removeButtonElement.type = "button";
  removeButtonElement.className =
    "task-item__remove";
  removeButtonElement.dataset.action = "remove";
  removeButtonElement.textContent = "Remove";
  removeButtonElement.setAttribute(
    "aria-label",
    `Remove ${task.title}`
  );

  contentElement.append(titleElement, idElement);

  actionsElement.append(
    completeButtonElement,
    removeButtonElement
  );

  listItemElement.append(
    contentElement,
    actionsElement
  );

  return listItemElement;
}

function renderTasks(tasks) {
  /*
    replaceChildren() removes all existing children safely.
    It avoids leaving stale task elements in the interface.
  */
  taskListElement.replaceChildren();

  for (const task of tasks) {
    const taskElement = createTaskElement(task);
    taskListElement.append(taskElement);
  }

  emptyStateElement.hidden = tasks.length > 0;

  taskCountElement.textContent =
    `${tasks.length} ${getTaskLabel(tasks.length)}`;
}

function showFormMessage(message, type = "normal") {
  formMessageElement.textContent = message;

  formMessageElement.className = "form-message";

  if (type === "error") {
    formMessageElement.classList.add(
      "form-message--error"
    );
  }

  if (type === "success") {
    formMessageElement.classList.add(
      "form-message--success"
    );
  }
}

/*
  APPLICATION STATE
*/

const tasks = [
  createTask("Learn the DOM", 1),
  createTask("Practice element creation", 2)
];

let nextTaskId = 3;

/*
  FORM EVENT HANDLER
*/

taskFormElement.addEventListener("submit", (event) => {
  /*
    Prevents the browser from reloading or navigating away
    after form submission.
  */
  event.preventDefault();

  const title = taskTitleInputElement.value.trim();

  if (title.length === 0) {
    showFormMessage(
      "Enter a task title before submitting.",
      "error"
    );

    taskTitleInputElement.focus();
    return;
  }

  if (title.length > 120) {
    showFormMessage(
      "Task titles cannot exceed 120 characters.",
      "error"
    );

    taskTitleInputElement.focus();
    return;
  }

  const task = createTask(title, nextTaskId);
  nextTaskId += 1;

  tasks.push(task);

  renderTasks(tasks);

  showFormMessage(`Added task: ${task.title}`, "success");

  /*
    reset() clears all form controls.
  */
  taskFormElement.reset();
  taskTitleInputElement.focus();
});

/*
  TASK-LIST EVENT DELEGATION
*/

taskListElement.addEventListener("click", (event) => {
  if (!(event.target instanceof Element)) {
    return;
  }

  /*
    closest() handles clicks on the button itself or on a
    future nested element inside that button.
  */
  const actionButton = event.target.closest("button");

  if (actionButton === null) {
    return;
  }

  const taskElement = actionButton.closest("[data-task-id]");

  if (taskElement === null) {
    return;
  }

  const taskId = Number(taskElement.dataset.taskId);

  if (!Number.isSafeInteger(taskId)) {
    console.error(
      "Task element contains an invalid id:",
      taskElement.dataset.taskId
    );

    showFormMessage(
      "Could not identify the selected task.",
      "error"
    );

    return;
  }

  const task = findTaskById(tasks, taskId);

  if (task === undefined) {
    console.error("Task was not found:", taskId);

    showFormMessage(
      "The selected task no longer exists.",
      "error"
    );

    return;
  }

  const action = actionButton.dataset.action;

  if (action === "toggle-complete") {
    task.completed = !task.completed;

    /*
      Re-rendering keeps the visible DOM consistent with the
      task array. The array remains the source of truth.
    */
    renderTasks(tasks);

    showFormMessage(
      task.completed
        ? `Completed task: ${task.title}`
        : `Reopened task: ${task.title}`,
      "success"
    );

    return;
  }

  if (action === "remove") {
    const removed = removeTaskById(tasks, taskId);

    if (!removed) {
      showFormMessage(
        "Could not remove the selected task.",
        "error"
      );

      return;
    }

    renderTasks(tasks);

    showFormMessage(
      `Removed task: ${task.title}`,
      "success"
    );
  }
});

/*
  INITIAL RENDER
*/

renderTasks(tasks);

showFormMessage(
  "The task application is ready.",
  "success"
);

console.log("Part 4 task application initialized.");
console.log("Initial application state:", tasks);
```

## The Verification

Refresh the browser and perform the complete test sequence.

### Test 1: Initial interface

Confirm:

```text
2 tasks
```

and two visible task rows.

### Test 2: Add a task

Enter:

```text
Review event bubbling
```

Click **Add task**.

Confirm:

- A third task appears.
- The count becomes `3 tasks`.
- The input clears.
- The success message appears.

### Test 3: Reject empty input

Submit with an empty input.

Confirm:

- No task is added.
- The count remains unchanged.
- An error message appears.
- Focus returns to the input.

### Test 4: Reject whitespace

Enter:

```text
       
```

Submit.

Confirm it is rejected.

### Test 5: Complete a task

Click **Complete**.

Confirm:

- The title receives a strikethrough.
- The button changes to **Undo**.
- The success message changes.
- The underlying task state changes.

### Test 6: Undo completion

Click **Undo**.

Confirm the task returns to its incomplete state.

### Test 7: Remove a task

Click **Remove**.

Confirm:

- The task disappears.
- The count decreases.
- The success message updates.

### Test 8: Remove all tasks

Remove every task.

Confirm:

```text
0 tasks
```

and:

```text
No tasks yet. Add your first task above.
```

### Test 9: Safe text rendering

Enter this exact title:

```html
<strong>This must remain text</strong>
```

The page should display the characters literally:

```text
<strong>This must remain text</strong>
```

It must not create a bold heading. This confirms that task titles are inserted with `textContent`.

[COMPLETED: Step 8 — Final interactive task application verified]  
[STARTING: Part 4 reference section]

---

# Part 4 Reference: DOM and Events

## `querySelector`

Selects the first element matching a CSS selector:

```js
const heading = document.querySelector("h1");
const form = document.querySelector("#task-form");
const button = document.querySelector(".submit-button");
```

If no element matches, it returns `null`.

Always account for that possibility when the element is required.

---

## `textContent`

Reads or replaces text:

```js
messageElement.textContent = "Task added.";
```

Use `textContent` for user-provided content.

Safer:

```js
titleElement.textContent = userProvidedTitle;
```

Riskier:

```js
titleElement.innerHTML = userProvidedTitle;
```

`innerHTML` interprets strings as HTML. If the string is untrusted, that can create a cross-site scripting vulnerability.

---

## `createElement`

Creates a new element in memory:

```js
const item = document.createElement("li");
```

The element does not appear on the page until appended:

```js
list.append(item);
```

---

## `append`

Adds one or more nodes:

```js
container.append(firstElement, secondElement);
```

It can also append text:

```js
container.append("Some text");
```

---

## `replaceChildren`

Removes all existing children and inserts the supplied children:

```js
list.replaceChildren();
```

This is useful when rendering a collection from scratch.

---

## `classList`

Manage CSS classes:

```js
element.classList.add("active");
element.classList.remove("active");
element.classList.toggle("active");
element.classList.contains("active");
```

`toggle` can receive a boolean force value:

```js
element.classList.toggle(
  "completed",
  task.completed
);
```

This means:

- Add the class when `task.completed` is true.
- Remove the class when `task.completed` is false.

---

## `dataset`

HTML custom data attributes use the `data-*` format:

```html
<li data-task-id="12"></li>
```

JavaScript accesses it through `dataset`:

```js
const idText = element.dataset.taskId;
```

Values are strings:

```js
typeof idText; // "string"
```

Convert numeric values explicitly:

```js
const id = Number(idText);
```

Validate the conversion before using it.

---

## Event Listeners

Register a function that runs when an event occurs:

```js
button.addEventListener("click", () => {
  console.log("Clicked");
});
```

Common events include:

```text
click
submit
input
change
keydown
focus
blur
```

---

## The Event Object

The browser passes an event object to the listener:

```js
button.addEventListener("click", (event) => {
  console.log(event);
});
```

Important properties include:

- `event.target`: the element where the event originated.
- `event.currentTarget`: the element whose listener is currently running.
- `event.type`: the event name.

---

## `preventDefault`

Stops the browser’s default action:

```js
form.addEventListener("submit", (event) => {
  event.preventDefault();
});
```

For a form, the default action commonly includes submitting and navigating or reloading the page.

---

## Event Bubbling

Events commonly travel from the original target toward ancestor elements:

```text
target
  ↑
parent
  ↑
grandparent
  ↑
document
```

This makes event delegation possible.

```js
list.addEventListener("click", (event) => {
  const button = event.target.closest("button");

  if (button === null) {
    return;
  }

  // Handle the button action.
});
```

---

## Event Delegation

Event delegation is especially useful for dynamically created elements.

Without delegation:

```js
for (const button of buttons) {
  button.addEventListener("click", handleClick);
}
```

This requires attaching listeners to every button.

With delegation:

```js
list.addEventListener("click", handleClick);
```

One stable parent handles events from current and future children.

---

## Form Input Values

Read an input’s current value:

```js
const title = input.value;
```

Clean it before validation:

```js
const title = input.value.trim();
```

Reset the form:

```js
form.reset();
```

Focus the input:

```js
input.focus();
```

---

## Accessibility Details Used in the Application

The page uses:

```html
<label for="task-title">Task title</label>
```

The `for` value matches the input ID, connecting the label to the input.

The status message uses:

```html
aria-live="polite"
```

This tells assistive technologies that changes may be announced without interrupting the user.

Buttons use explicit:

```html
type="button"
```

This prevents task action buttons from accidentally acting as form submission buttons if the markup changes later.

---

# Complete Project Structure

At the end of Part 4, your project should contain:

```text
javascript-foundations/
├── index.html
├── styles.css
└── src/
    ├── part-1.js
    ├── part-2.js
    ├── part-3.js
    └── part-4.js
```

Only `part-4.js` is currently loaded by `index.html`:

```html
<script src="./src/part-4.js" defer></script>
```

The earlier files remain as lesson references.

---

# Final Architecture

The completed browser application has this architecture:

```text
index.html
│
├── Form
│   ├── Input
│   └── Submit button
│
├── Status message
│
└── Task list
    └── JavaScript-generated task items

styles.css
│
├── Layout
├── Form appearance
├── Task appearance
├── Completed-task state
└── Responsive behavior

src/part-4.js
│
├── DOM references
├── Validation
├── Task creation
├── Task lookup
├── Task removal
├── Task rendering
├── Form submission handling
├── Event delegation
└── Application state
```

The main data flow is:

```text
tasks array
    ↓
renderTasks(tasks)
    ↓
DOM task elements
    ↓
user clicks a button
    ↓
event delegation handler
    ↓
tasks array changes
    ↓
renderTasks(tasks)
```

---

# Series Completion Checklist

You have now covered all four technical parts.

## Part 1: Foundations

You learned:

- Variables.
- Primitive values.
- Reference values.
- Operators.
- Conditions.
- `switch`.
- `for`.
- `while`.
- `for...of`.

## Part 2: Functions and Scope

You learned:

- Function declarations.
- Function expressions.
- Arrow functions.
- Parameters.
- Arguments.
- Return values.
- Global scope.
- Function scope.
- Block scope.
- `var`, `let`, and `const`.
- Callbacks.
- Closures.

## Part 3: Data Structures

You learned:

- Arrays.
- Indexing.
- `push`.
- `pop`.
- `shift`.
- `unshift`.
- `slice`.
- `indexOf`.
- Objects.
- Dot notation.
- Bracket notation.
- Dynamic keys.
- Arrays of objects.
- `find`.
- `findIndex`.
- `splice`.

## Part 4: Browser Interaction

You learned:

- `querySelector`.
- `textContent`.
- `createElement`.
- `append`.
- `replaceChildren`.
- `classList`.
- `dataset`.
- Form submission events.
- `preventDefault`.
- Event bubbling.
- Event delegation.
- Dynamic DOM rendering.
- Safe handling of user-entered text.
