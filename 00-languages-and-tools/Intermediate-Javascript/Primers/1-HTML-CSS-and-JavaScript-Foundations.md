# Primer 1: HTML, CSS, and JavaScript Foundations

This primer reviews the browser fundamentals required for the main tutorial series.

You will learn how:

- HTML defines page structure.
- CSS controls presentation.
- JavaScript changes page behavior.
- JavaScript selects DOM elements.
- Events connect user actions to code.
- Forms submit data.
- Arrays and objects represent application state.
- Functions organize behavior.

The goal is not to become an HTML, CSS, or JavaScript expert before starting the series. The goal is to understand the basic building blocks well enough to follow the asynchronous and modular code later.

---

# 1. The Browser’s Three Main Layers

A browser application usually combines three technologies:

```text
HTML       → Structure
CSS        → Appearance
JavaScript → Behavior
```

A useful analogy is a house:

- HTML is the walls, doors, and rooms.
- CSS is the paint, furniture, and layout.
- JavaScript is the electrical system and automation.

The three technologies work together, but they have different jobs.

---

# 2. HTML Document Structure

## The Target

Create a basic HTML page.

## The Concept

HTML uses elements to describe the meaning and structure of content.

A basic document contains:

- `<!DOCTYPE html>` — tells the browser to use modern HTML behavior.
- `<html>` — wraps the complete document.
- `<head>` — contains metadata and linked resources.
- `<body>` — contains visible page content.

## The Implementation

Create:

### `foundations.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />

    <title>HTML Foundations</title>
  </head>

  <body>
    <h1>HTML Foundations</h1>

    <p>
      HTML gives the browser the structure of the page.
    </p>
  </body>
</html>
```

## The Verification

Open the file in your browser.

You should see:

```text
HTML Foundations
HTML gives the browser the structure of the page.
```

Open Developer Tools and inspect the page.

You should see the document structure:

```text
html
├── head
└── body
    ├── h1
    └── p
```

[COMPLETED: Step 1 — Basic HTML document created]  
[STARTING: Step 2 — Use semantic HTML elements]

---

# 3. Semantic HTML

## The Target

Add meaningful sections to the page.

## The Concept

Semantic HTML describes what content means, not merely how it looks.

For example:

```html
<header>
```

communicates that content belongs to the page or section header.

This is better than:

```html
<div class="header">
```

because browsers and assistive technologies understand the semantic element directly.

Common semantic elements include:

| Element | Purpose |
|---|---|
| `header` | Introductory or navigation content |
| `main` | Primary page content |
| `section` | Thematic grouping of content |
| `article` | Self-contained content |
| `footer` | Closing or supporting content |
| `nav` | Navigation links |
| `form` | User input and submission |
| `ul` | Unordered list |
| `ol` | Ordered list |
| `li` | List item |

## The Implementation

Replace `foundations.html` with:

### `foundations.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />

    <title>HTML Foundations</title>
  </head>

  <body>
    <header>
      <p>Intermediate JavaScript</p>
      <h1>HTML Foundations</h1>

      <p>
        This page demonstrates semantic HTML structure.
      </p>
    </header>

    <main>
      <section aria-labelledby="tasks-heading">
        <h2 id="tasks-heading">Tasks</h2>

        <ul>
          <li>Learn HTML structure</li>
          <li>Learn CSS selectors</li>
          <li>Learn JavaScript events</li>
        </ul>
      </section>
    </main>

    <footer>
      <p>Built for JavaScript practice.</p>
    </footer>
  </body>
</html>
```

## The Verification

Refresh the page.

You should see:

- A header.
- A main section.
- A list of three tasks.
- A footer.

In Developer Tools, inspect the structure:

```text
body
├── header
├── main
│   └── section
│       ├── h2
│       └── ul
└── footer
```

[COMPLETED: Step 2 — Semantic HTML added]  
[STARTING: Step 3 — Add forms and accessible labels]

---

# 4. Forms, Inputs, and Labels

## The Target

Add a form that accepts a task title.

## The Concept

A form collects user input.

The important elements are:

- `form` — groups the input operation.
- `label` — tells users what an input means.
- `input` — collects a value.
- `button` — performs an action.

A label should be explicitly connected to its input:

```html
<label for="task-title">Task title</label>

<input id="task-title" />
```

The `for` value and `id` value must match.

## The Implementation

Replace the `<section>` inside `<main>` with:

```html
<section aria-labelledby="add-task-heading">
  <h2 id="add-task-heading">Add a task</h2>

  <form id="task-form">
    <div>
      <label for="task-title">Task title</label>

      <input
        id="task-title"
        name="taskTitle"
        type="text"
        maxlength="120"
        autocomplete="off"
        placeholder="For example: Study JavaScript"
        required
      />
    </div>

    <button type="submit">Add task</button>
  </form>
</section>
```

The full file should now be:

### `foundations.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />

    <title>HTML Foundations</title>
  </head>

  <body>
    <header>
      <p>Intermediate JavaScript</p>
      <h1>HTML Foundations</h1>

      <p>
        This page demonstrates semantic HTML structure.
      </p>
    </header>

    <main>
      <section aria-labelledby="add-task-heading">
        <h2 id="add-task-heading">Add a task</h2>

        <form id="task-form">
          <div>
            <label for="task-title">Task title</label>

            <input
              id="task-title"
              name="taskTitle"
              type="text"
              maxlength="120"
              autocomplete="off"
              placeholder="For example: Study JavaScript"
              required
            />
          </div>

          <button type="submit">Add task</button>
        </form>
      </section>

      <section aria-labelledby="tasks-heading">
        <h2 id="tasks-heading">Tasks</h2>

        <ul id="task-list">
          <li>Learn HTML structure</li>
          <li>Learn CSS selectors</li>
          <li>Learn JavaScript events</li>
        </ul>
      </section>
    </main>

    <footer>
      <p>Built for JavaScript practice.</p>
    </footer>
  </body>
</html>
```

## The Verification

Test the form manually:

1. Click the label `Task title`.
2. Confirm that the input receives focus.
3. Enter a task title.
4. Click **Add task**.
5. Leave the input empty.
6. Click **Add task** again.

The browser should prevent submission because the input is required.

The form does not add tasks yet. JavaScript will provide that behavior later.

[COMPLETED: Step 3 — Accessible form created]  
[STARTING: Step 4 — Add CSS styles]

---

# 5. CSS Files and Selectors

## The Target

Create a separate stylesheet and connect it to the HTML page.

## The Concept

CSS uses selectors to choose elements and declarations to style them.

Example:

```css
h1 {
  color: blue;
}
```

This means:

> Find every `h1` element and set its text color to blue.

Common selectors include:

### Element Selector

```css
p {
  color: #536078;
}
```

### Class Selector

```css
.panel {
  padding: 1rem;
}
```

HTML:

```html
<section class="panel">
```

### ID Selector

```css
#task-list {
  list-style: none;
}
```

IDs should normally be unique within a page.

## The Implementation

Create:

### `foundations.css`

```css
:root {
  font-family:
    Inter, ui-sans-serif, system-ui, -apple-system,
    BlinkMacSystemFont, "Segoe UI", sans-serif;
  color: #172033;
  background: #eef2f7;
  line-height: 1.5;
}

* {
  box-sizing: border-box;
}

body {
  min-width: 320px;
  max-width: 52rem;
  margin: 0 auto;
  padding: 2rem 1rem;
  background: #ffffff;
}

header {
  margin-bottom: 2rem;
}

header p:first-child {
  color: #2457d6;
  font-size: 0.8rem;
  font-weight: 800;
  letter-spacing: 0.1em;
  text-transform: uppercase;
}

h1,
h2,
p {
  margin-top: 0;
}

h1 {
  margin-bottom: 0.5rem;
}

h2 {
  margin-bottom: 0.75rem;
}

section {
  margin-bottom: 1.5rem;
  border: 1px solid #dce2eb;
  border-radius: 0.75rem;
  padding: 1.25rem;
  background: #ffffff;
}

form {
  display: grid;
  gap: 1rem;
}

label {
  display: block;
  margin-bottom: 0.4rem;
  color: #536078;
  font-weight: 700;
}

input {
  width: 100%;
  border: 1px solid #bcc7d8;
  border-radius: 0.5rem;
  padding: 0.7rem 0.8rem;
  font: inherit;
}

input:focus {
  outline: 3px solid rgba(36, 87, 214, 0.2);
  border-color: #2457d6;
}

button {
  width: fit-content;
  border: 0;
  border-radius: 0.5rem;
  padding: 0.7rem 1rem;
  color: #ffffff;
  background: #2457d6;
  font: inherit;
  cursor: pointer;
}

button:hover {
  background: #1c43a8;
}

ul {
  margin: 0;
  padding-left: 1.25rem;
}

footer {
  color: #66728a;
  font-size: 0.9rem;
}
```

Add this line inside the `<head>` of `foundations.html`:

```html
<link rel="stylesheet" href="./foundations.css" />
```

The head should now contain:

```html
<head>
  <meta charset="UTF-8" />

  <meta
    name="viewport"
    content="width=device-width, initial-scale=1.0"
  />

  <title>HTML Foundations</title>

  <link rel="stylesheet" href="./foundations.css" />
</head>
```

## The Verification

Refresh the page.

You should see:

- A centered page.
- A styled input.
- A blue button.
- Bordered sections.
- Spacing between sections.
- A visible focus outline when the input is selected.

If the page remains unstyled, check:

1. The CSS file is named exactly `foundations.css`.
2. It is in the same directory as `foundations.html`.
3. The link is inside `<head>`.
4. The browser console has no loading error.

[COMPLETED: Step 4 — CSS stylesheet connected]  
[STARTING: Step 5 — Add JavaScript to select DOM elements]

---

# 6. The DOM

## The Target

Use JavaScript to find elements in the page.

## The Concept

The **Document Object Model**, or DOM, is the browser’s JavaScript representation of the HTML document.

HTML:

```html
<h1 id="page-title">My Page</h1>
```

JavaScript can find it:

```javascript
const pageTitle =
  document.querySelector("#page-title");
```

The result is a JavaScript object representing that HTML element.

## The Implementation

Create:

### `foundations.js`

```javascript
"use strict";

const pageTitle = document.querySelector("h1");
const taskForm = document.querySelector("#task-form");
const taskTitleInput = document.querySelector("#task-title");
const taskList = document.querySelector("#task-list");

console.log("Page title element:", pageTitle);
console.log("Task form element:", taskForm);
console.log("Task input element:", taskTitleInput);
console.log("Task list element:", taskList);
```

Add the script before the closing `</body>` tag:

```html
<script src="./foundations.js"></script>
```

The end of the body should look like:

```html
<footer>
  <p>Built for JavaScript practice.</p>
</footer>

<script src="./foundations.js"></script>
</body>
```

## The Verification

Refresh the page and open the browser console.

You should see four DOM elements logged.

Test:

```javascript
document.querySelector("#task-title");
```

The console should display the input element.

Test a selector that does not exist:

```javascript
document.querySelector("#does-not-exist");
```

The result is:

```javascript
null
```

This is why code should verify required elements before using them.

[COMPLETED: Step 5 — DOM elements selected with JavaScript]  
[STARTING: Step 6 — Update DOM content]

---

# 7. Updating the DOM

## The Target

Use JavaScript to change visible page content.

## The Concept

Selecting an element gives JavaScript a reference to the page. Properties and methods can then change it.

Use `textContent` for plain text:

```javascript
pageTitle.textContent = "Updated title";
```

`textContent` is safer than `innerHTML` when the value comes from a user.

## The Implementation

Replace `foundations.js` with:

### `foundations.js`

```javascript
"use strict";

const pageTitle = document.querySelector("h1");
const taskCount = document.querySelector("#tasks-heading");

if (!pageTitle) {
  throw new Error("The page title was not found.");
}

if (!taskCount) {
  throw new Error("The tasks heading was not found.");
}

pageTitle.textContent = "JavaScript Foundations";

taskCount.textContent = "Tasks: 3";
```

## The Verification

Refresh the page.

The heading should change to:

```text
JavaScript Foundations
```

The tasks heading should change to:

```text
Tasks: 3
```

Now change the code temporarily:

```javascript
pageTitle.innerHTML =
  "<span>Unsafe HTML Example</span>";
```

The browser will interpret the string as HTML.

Restore the safe version:

```javascript
pageTitle.textContent =
  "JavaScript Foundations";
```

[COMPLETED: Step 6 — DOM text updated]  
[STARTING: Step 7 — Handle browser events]

---

# 8. Events

## The Target

Respond to a button click.

## The Concept

An event is something that happens in the browser.

Examples include:

- A click.
- A form submission.
- Text input.
- A key press.
- A page load.
- A window resize.

JavaScript listens for events with:

```javascript
element.addEventListener(
  "event-name",
  callback
);
```

The callback runs later when the event occurs.

## The Implementation

Update `foundations.html` so the main section includes a button:

```html
<section aria-labelledby="interaction-heading">
  <h2 id="interaction-heading">Interaction</h2>

  <p id="interaction-message">
    The button has not been clicked.
  </p>

  <button
    id="interaction-button"
    type="button"
  >
    Click me
  </button>
</section>
```

Replace `foundations.js` with:

### `foundations.js`

```javascript
"use strict";

const interactionButton = document.querySelector(
  "#interaction-button"
);

const interactionMessage = document.querySelector(
  "#interaction-message"
);

if (!(interactionButton instanceof HTMLButtonElement)) {
  throw new Error(
    "The interaction button was not found."
  );
}

if (!(interactionMessage instanceof HTMLElement)) {
  throw new Error(
    "The interaction message was not found."
  );
}

interactionButton.addEventListener("click", () => {
  interactionMessage.textContent =
    "The button was clicked.";
});
```

## The Verification

Refresh the page.

The message should initially say:

```text
The button has not been clicked.
```

Click **Click me**.

The message should change to:

```text
The button was clicked.
```

Open the console and click the button again. The callback runs each time.

[COMPLETED: Step 7 — Click event handled]  
[STARTING: Step 8 — Handle form submission]

---

# 9. Form Submission

## The Target

Read a task title when the form is submitted.

## The Concept

A browser normally reloads or navigates when a form is submitted.

JavaScript can prevent that default behavior:

```javascript
event.preventDefault();
```

Then the application can handle the form itself.

The submitted input value is available through:

```javascript
taskTitleInput.value;
```

## The Implementation

Replace `foundations.js` with:

### `foundations.js`

```javascript
"use strict";

const taskForm = document.querySelector("#task-form");
const taskTitleInput = document.querySelector("#task-title");
const taskList = document.querySelector("#task-list");

if (!(taskForm instanceof HTMLFormElement)) {
  throw new Error("The task form was not found.");
}

if (!(taskTitleInput instanceof HTMLInputElement)) {
  throw new Error("The task title input was not found.");
}

if (!(taskList instanceof HTMLElement)) {
  throw new Error("The task list was not found.");
}

taskForm.addEventListener("submit", (event) => {
  event.preventDefault();

  const title = taskTitleInput.value.trim();

  if (title.length === 0) {
    return;
  }

  const listItem = document.createElement("li");
  listItem.textContent = title;

  taskList.append(listItem);

  taskTitleInput.value = "";
  taskTitleInput.focus();
});
```

## The Verification

Refresh the page.

Enter:

```text
Practice form submission
```

Click **Add task**.

The new task should appear in the list.

Verify:

- The page does not reload.
- The input becomes empty.
- Focus returns to the input.
- The task appears as plain text.

Test with:

```html
<img src="invalid" onerror="alert('unexpected')">
```

The text should appear in the list without executing code.

[COMPLETED: Step 8 — Form submission handled]  
[STARTING: Step 9 — Store data in arrays]

---

# 10. Arrays as Application State

## The Target

Replace hard-coded list items with a JavaScript array.

## The Concept

Application state is the data that describes the current condition of the application.

For the task manager, state includes:

```javascript
const tasks = [];
```

The array becomes the source of truth. The DOM is rendered from it.

Instead of directly adding HTML and forgetting about the data, we:

1. Add a task to the array.
2. Render the array.
3. Keep the data and page synchronized.

## The Implementation

Replace the list in `foundations.html`:

```html
<ul id="task-list">
  <li>Learn HTML structure</li>
  <li>Learn CSS selectors</li>
  <li>Learn JavaScript events</li>
</ul>
```

with:

```html
<ul id="task-list"></ul>
```

Replace `foundations.js`:

### `foundations.js`

```javascript
"use strict";

const taskForm = document.querySelector("#task-form");
const taskTitleInput = document.querySelector("#task-title");
const taskList = document.querySelector("#task-list");

if (!(taskForm instanceof HTMLFormElement)) {
  throw new Error("The task form was not found.");
}

if (!(taskTitleInput instanceof HTMLInputElement)) {
  throw new Error("The task title input was not found.");
}

if (!(taskList instanceof HTMLElement)) {
  throw new Error("The task list was not found.");
}

let tasks = [
  {
    id: 1,
    title: "Learn HTML structure",
    completed: false,
  },
  {
    id: 2,
    title: "Learn CSS selectors",
    completed: false,
  },
  {
    id: 3,
    title: "Learn JavaScript events",
    completed: false,
  },
];

function renderTasks() {
  taskList.replaceChildren();

  for (const task of tasks) {
    const listItem = document.createElement("li");
    listItem.textContent = task.title;

    taskList.append(listItem);
  }
}

function addTask(title) {
  const normalizedTitle = title.trim();

  if (normalizedTitle.length === 0) {
    return;
  }

  tasks.push({
    id: Date.now(),
    title: normalizedTitle,
    completed: false,
  });

  renderTasks();
}

taskForm.addEventListener("submit", (event) => {
  event.preventDefault();

  addTask(taskTitleInput.value);

  taskTitleInput.value = "";
  taskTitleInput.focus();
});

renderTasks();
```

## The Verification

Refresh the page.

The three initial tasks should appear.

Add:

```text
Store tasks in an array
```

The task should appear.

Open the console and inspect:

```javascript
tasks;
```

Because `tasks` is inside a regular script, it may be globally accessible in some browser contexts. You should see the array containing four objects.

In the main series, modules will keep application state private to the module.

[COMPLETED: Step 9 — Array-based task state created]  
[STARTING: Step 10 — Use object properties and task state]

---

# 11. Objects as Structured State

## The Target

Use object properties to display task completion state.

## The Concept

An object groups related values.

A task object contains:

```javascript
{
  id,
  title,
  completed
}
```

The application can use the `completed` property to determine:

- Which text to show.
- Which CSS class to add.
- Which button label to display.

## The Implementation

Update `renderTasks()` in `foundations.js`:

```javascript
function renderTasks() {
  taskList.replaceChildren();

  for (const task of tasks) {
    const listItem = document.createElement("li");

    if (task.completed) {
      listItem.classList.add("task-completed");
    }

    const title = document.createElement("span");
    title.textContent = task.title;

    const status = document.createElement("span");
    status.textContent = task.completed
      ? "Completed"
      : "Not completed";

    const toggleButton = document.createElement("button");
    toggleButton.type = "button";
    toggleButton.textContent = task.completed
      ? "Mark as incomplete"
      : "Mark as complete";

    toggleButton.addEventListener("click", () => {
      task.completed = !task.completed;
      renderTasks();
    });

    listItem.append(
      title,
      " — ",
      status,
      " ",
      toggleButton
    );

    taskList.append(listItem);
  }
}
```

Add to `foundations.css`:

```css
.task-completed {
  color: #66728a;
  text-decoration: line-through;
}
```

## The Verification

Refresh the page.

Click **Mark as complete**.

Verify:

- The task receives a strikethrough.
- Its status changes to `Completed`.
- The button changes to `Mark as incomplete`.

Click the button again.

The task should become active again.

[COMPLETED: Step 10 — Object state controls rendering]  
[STARTING: Step 11 — Use array methods]

---

# 12. Array Methods

## The Target

Use `filter()` and `map()` to work with task arrays.

## The Concept

Array methods provide readable ways to transform and inspect collections.

### `filter()`

Keeps matching items:

```javascript
const completedTasks = tasks.filter(
  (task) => task.completed
);
```

### `map()`

Transforms every item:

```javascript
const titles = tasks.map(
  (task) => task.title
);
```

## The Implementation

Add this temporary code after the `tasks` declaration:

```javascript
const completedTasks = tasks.filter(
  (task) => task.completed
);

const taskTitles = tasks.map(
  (task) => task.title
);

console.log("Completed tasks:", completedTasks);
console.log("Task titles:", taskTitles);
```

Add a count element to `foundations.html` above the list:

```html
<p id="task-count">0 tasks</p>
```

Update `foundations.js` to select it:

```javascript
const taskCount = document.querySelector("#task-count");

if (!(taskCount instanceof HTMLElement)) {
  throw new Error("The task count element was not found.");
}
```

Update `renderTasks()`:

```javascript
function renderTasks() {
  taskList.replaceChildren();

  const completedTotal = tasks.filter(
    (task) => task.completed
  ).length;

  taskCount.textContent =
    `${tasks.length} tasks · ` +
    `${completedTotal} completed`;

  for (const task of tasks) {
    const listItem = document.createElement("li");

    if (task.completed) {
      listItem.classList.add("task-completed");
    }

    const title = document.createElement("span");
    title.textContent = task.title;

    const status = document.createElement("span");
    status.textContent = task.completed
      ? "Completed"
      : "Not completed";

    const toggleButton = document.createElement("button");
    toggleButton.type = "button";
    toggleButton.textContent = task.completed
      ? "Mark as incomplete"
      : "Mark as complete";

    toggleButton.addEventListener("click", () => {
      task.completed = !task.completed;
      renderTasks();
    });

    listItem.append(
      title,
      " — ",
      status,
      " ",
      toggleButton
    );

    taskList.append(listItem);
  }
}
```

## The Verification

Refresh the page.

Verify:

```text
3 tasks · 0 completed
```

Complete one task.

Verify:

```text
3 tasks · 1 completed
```

Add another task.

Verify:

```text
4 tasks · 1 completed
```

[COMPLETED: Step 11 — Array methods used for task calculations]  
[STARTING: Step 12 — Extract reusable functions]

---

# 13. Functions and Separation of Responsibilities

## The Target

Separate task operations into focused functions.

## The Concept

A function is a named unit of behavior.

Instead of putting all logic inside one event listener, create functions such as:

```javascript
addTask()
toggleTaskCompletion()
renderTasks()
```

Each function should have one clear responsibility.

This is the beginning of **separation of concerns**.

## The Implementation

Replace `foundations.js` with:

### `foundations.js`

```javascript
"use strict";

const taskForm = document.querySelector("#task-form");
const taskTitleInput = document.querySelector("#task-title");
const taskList = document.querySelector("#task-list");
const taskCount = document.querySelector("#task-count");

if (!(taskForm instanceof HTMLFormElement)) {
  throw new Error("The task form was not found.");
}

if (!(taskTitleInput instanceof HTMLInputElement)) {
  throw new Error("The task title input was not found.");
}

if (!(taskList instanceof HTMLElement)) {
  throw new Error("The task list was not found.");
}

if (!(taskCount instanceof HTMLElement)) {
  throw new Error("The task count was not found.");
}

let tasks = [
  {
    id: 1,
    title: "Learn HTML structure",
    completed: false,
  },
  {
    id: 2,
    title: "Learn CSS selectors",
    completed: false,
  },
  {
    id: 3,
    title: "Learn JavaScript events",
    completed: false,
  },
];

function createTaskId() {
  return Date.now() + Math.floor(Math.random() * 1000);
}

function updateTaskCount() {
  const completedTotal = tasks.filter(
    (task) => task.completed
  ).length;

  const taskLabel = tasks.length === 1
    ? "task"
    : "tasks";

  taskCount.textContent =
    `${tasks.length} ${taskLabel} · ` +
    `${completedTotal} completed`;
}

function createTaskElement(task) {
  const listItem = document.createElement("li");

  if (task.completed) {
    listItem.classList.add("task-completed");
  }

  const title = document.createElement("span");
  title.textContent = task.title;

  const status = document.createElement("span");
  status.textContent = task.completed
    ? "Completed"
    : "Not completed";

  const toggleButton = document.createElement("button");
  toggleButton.type = "button";
  toggleButton.textContent = task.completed
    ? "Mark as incomplete"
    : "Mark as complete";

  toggleButton.addEventListener("click", () => {
    toggleTaskCompletion(task.id);
  });

  listItem.append(
    title,
    " — ",
    status,
    " ",
    toggleButton
  );

  return listItem;
}

function renderTasks() {
  taskList.replaceChildren();

  updateTaskCount();

  for (const task of tasks) {
    const taskElement = createTaskElement(task);
    taskList.append(taskElement);
  }
}

function addTask(title) {
  const normalizedTitle = title.trim();

  if (normalizedTitle.length === 0) {
    return;
  }

  tasks.push({
    id: createTaskId(),
    title: normalizedTitle,
    completed: false,
  });

  renderTasks();
}

function toggleTaskCompletion(taskId) {
  const task = tasks.find(
    (candidate) => candidate.id === taskId
  );

  if (!task) {
    return;
  }

  task.completed = !task.completed;
  renderTasks();
}

taskForm.addEventListener("submit", (event) => {
  event.preventDefault();

  addTask(taskTitleInput.value);

  taskTitleInput.value = "";
  taskTitleInput.focus();
});

renderTasks();
```

## The Verification

Refresh the page.

Verify that all previous behavior still works:

- Tasks appear.
- Tasks can be added.
- Tasks can be completed.
- Counts update.
- The page does not reload on form submission.

[COMPLETED: Step 12 — Behavior separated into reusable functions]  
[STARTING: Step 13 — Add a filter control]

---

# 14. Add Filtering

## The Target

Filter tasks by:

- All.
- Active.
- Completed.

## The Concept

Filtering creates a visible view of the underlying task collection.

The stored collection remains unchanged:

```javascript
tasks
```

The visible collection is calculated:

```javascript
visibleTasks
```

This distinction becomes important in the main series.

## The Implementation

Add this section to `foundations.html` above the task list:

```html
<div>
  <label for="task-filter">Show</label>

  <select id="task-filter">
    <option value="all">All tasks</option>
    <option value="active">Active tasks</option>
    <option value="completed">Completed tasks</option>
  </select>
</div>
```

In `foundations.js`, select the filter:

```javascript
const taskFilter = document.querySelector(
  "#task-filter"
);

if (!(taskFilter instanceof HTMLSelectElement)) {
  throw new Error("The task filter was not found.");
}

let currentFilter = "all";
```

Add:

```javascript
function getVisibleTasks() {
  if (currentFilter === "active") {
    return tasks.filter(
      (task) => !task.completed
    );
  }

  if (currentFilter === "completed") {
    return tasks.filter(
      (task) => task.completed
    );
  }

  return tasks;
}
```

Replace the loop inside `renderTasks()`:

```javascript
for (const task of tasks) {
  const taskElement = createTaskElement(task);
  taskList.append(taskElement);
}
```

with:

```javascript
const visibleTasks = getVisibleTasks();

for (const task of visibleTasks) {
  const taskElement = createTaskElement(task);
  taskList.append(taskElement);
}
```

Add the event listener:

```javascript
taskFilter.addEventListener("change", () => {
  currentFilter = taskFilter.value;
  renderTasks();
});
```

## The Verification

1. Refresh the page.
2. Select **Active tasks**.
3. Confirm only incomplete tasks appear.
4. Complete a task.
5. Confirm it disappears from the active view.
6. Select **Completed tasks**.
7. Confirm the completed task appears.
8. Select **All tasks**.
9. Confirm all tasks appear.

[COMPLETED: Step 13 — Task filtering added]  
[STARTING: Step 14 — Understand the final primer example]

---

# 15. Complete Foundations Example

The following file combines the most important concepts from this primer:

- DOM selection.
- Form handling.
- Arrays.
- Objects.
- Functions.
- Events.
- Rendering.
- Filtering.
- Validation.
- Safe text rendering.

## The Implementation

### `foundations.js`

```javascript
"use strict";

const taskForm = document.querySelector("#task-form");
const taskTitleInput = document.querySelector("#task-title");
const taskList = document.querySelector("#task-list");
const taskCount = document.querySelector("#task-count");
const taskFilter = document.querySelector("#task-filter");

if (!(taskForm instanceof HTMLFormElement)) {
  throw new Error("The task form was not found.");
}

if (!(taskTitleInput instanceof HTMLInputElement)) {
  throw new Error("The task title input was not found.");
}

if (!(taskList instanceof HTMLElement)) {
  throw new Error("The task list was not found.");
}

if (!(taskCount instanceof HTMLElement)) {
  throw new Error("The task count was not found.");
}

if (!(taskFilter instanceof HTMLSelectElement)) {
  throw new Error("The task filter was not found.");
}

let tasks = [
  {
    id: 1,
    title: "Learn HTML structure",
    completed: false,
  },
  {
    id: 2,
    title: "Learn CSS selectors",
    completed: false,
  },
  {
    id: 3,
    title: "Learn JavaScript events",
    completed: false,
  },
];

let currentFilter = "all";

function createTaskId() {
  return Date.now() + Math.floor(Math.random() * 1000);
}

function updateTaskCount() {
  const completedTotal = tasks.filter(
    (task) => task.completed
  ).length;

  const taskLabel = tasks.length === 1
    ? "task"
    : "tasks";

  taskCount.textContent =
    `${tasks.length} ${taskLabel} · ` +
    `${completedTotal} completed`;
}

function getVisibleTasks() {
  if (currentFilter === "active") {
    return tasks.filter(
      (task) => !task.completed
    );
  }

  if (currentFilter === "completed") {
    return tasks.filter(
      (task) => task.completed
    );
  }

  return tasks;
}

function toggleTaskCompletion(taskId) {
  const task = tasks.find(
    (candidate) => candidate.id === taskId
  );

  if (!task) {
    return;
  }

  task.completed = !task.completed;
  renderTasks();
}

function createTaskElement(task) {
  const listItem = document.createElement("li");

  if (task.completed) {
    listItem.classList.add("task-completed");
  }

  const title = document.createElement("span");
  title.textContent = task.title;

  const status = document.createElement("span");
  status.textContent = task.completed
    ? "Completed"
    : "Not completed";

  const toggleButton = document.createElement("button");
  toggleButton.type = "button";
  toggleButton.textContent = task.completed
    ? "Mark as incomplete"
    : "Mark as complete";

  toggleButton.addEventListener("click", () => {
    toggleTaskCompletion(task.id);
  });

  listItem.append(
    title,
    " — ",
    status,
    " ",
    toggleButton
  );

  return listItem;
}

function renderTasks() {
  taskList.replaceChildren();

  updateTaskCount();

  const visibleTasks = getVisibleTasks();

  if (visibleTasks.length === 0) {
    const emptyMessage = document.createElement("li");
    emptyMessage.textContent =
      "No tasks match the selected filter.";
    taskList.append(emptyMessage);
    return;
  }

  for (const task of visibleTasks) {
    const taskElement = createTaskElement(task);
    taskList.append(taskElement);
  }
}

function addTask(title) {
  const normalizedTitle = title.trim();

  if (normalizedTitle.length === 0) {
    return;
  }

  if (normalizedTitle.length > 120) {
    return;
  }

  tasks.push({
    id: createTaskId(),
    title: normalizedTitle,
    completed: false,
  });

  renderTasks();
}

taskForm.addEventListener("submit", (event) => {
  event.preventDefault();

  addTask(taskTitleInput.value);

  taskTitleInput.value = "";
  taskTitleInput.focus();
});

taskFilter.addEventListener("change", () => {
  currentFilter = taskFilter.value;
  renderTasks();
});

renderTasks();
```

## The Verification

Refresh the page and perform the complete test:

1. Confirm the three initial tasks appear.
2. Add a valid task.
3. Submit an empty task.
4. Complete a task.
5. Reopen a task.
6. Select **Active tasks**.
7. Select **Completed tasks**.
8. Select **All tasks**.
9. Add a title longer than 120 characters.
10. Enter HTML-like text and verify it renders as text.

[COMPLETED: Step 14 — Complete HTML, CSS, and JavaScript foundations example verified]  
[STARTING: Primer 1 Reference — Foundational concepts]

---

# Primer 1 Reference: Important Concepts

## HTML Attributes

Attributes provide additional information:

```html
<input
  id="task-title"
  type="text"
  required
/>
```

Here:

- `id` identifies the element.
- `type` defines the input type.
- `required` enables native validation.

## Classes and IDs

Use IDs for unique elements:

```html
<p id="task-count"></p>
```

Use classes for reusable styling:

```html
<p class="status-message"></p>
```

## DOM Selection

```javascript
document.querySelector("#task-count");
document.querySelector(".task-item");
document.querySelector("button");
```

## DOM Creation

```javascript
const listItem = document.createElement("li");
```

## DOM Insertion

```javascript
taskList.append(listItem);
```

## DOM Removal

```javascript
taskList.replaceChildren();
```

## Event Registration

```javascript
button.addEventListener("click", handleClick);
```

## Form Submission

```javascript
form.addEventListener("submit", (event) => {
  event.preventDefault();
});
```

## State and Rendering

```javascript
tasks.push(newTask);
renderTasks();
```

The state changes first. The DOM is then rebuilt from the current state.

---

# Common Beginner Mistakes

## Mistake 1: Forgetting `#` for an ID Selector

Incorrect:

```javascript
document.querySelector("task-list");
```

Correct:

```javascript
document.querySelector("#task-list");
```

## Mistake 2: Forgetting `.` for a Class Selector

Incorrect:

```javascript
document.querySelector("task-item");
```

Correct:

```javascript
document.querySelector(".task-item");
```

## Mistake 3: Using the Wrong ID

HTML:

```html
<input id="task-title" />
```

JavaScript:

```javascript
document.querySelector("#task-name");
```

The selector returns `null` because the names do not match.

## Mistake 4: Forgetting `preventDefault()`

Without:

```javascript
event.preventDefault();
```

the browser may reload the page after form submission.

## Mistake 5: Updating Data Without Rendering

This changes the array:

```javascript
tasks.push(newTask);
```

but may not update the page until:

```javascript
renderTasks();
```

is called.

## Mistake 6: Rendering User Input with `innerHTML`

Avoid:

```javascript
element.innerHTML = task.title;
```

Use:

```javascript
element.textContent = task.title;
```

## Mistake 7: Forgetting `type="button"`

Inside forms, non-submit buttons should use:

```html
<button type="button">
```

## Mistake 8: Mutating the Wrong Task

Use the task identifier:

```javascript
const task = tasks.find(
  (candidate) => candidate.id === taskId
);
```

Do not assume array indexes remain stable after filtering or sorting.

---

# Primer 1 Completion Checklist

Before beginning Part 0, confirm that you can:

- [ ] Create a valid HTML document.
- [ ] Use semantic HTML elements.
- [ ] Associate labels with inputs.
- [ ] Create forms and buttons.
- [ ] Link a CSS file.
- [ ] Use element, class, and ID selectors.
- [ ] Create basic responsive styles.
- [ ] Select DOM elements with `querySelector`.
- [ ] Create elements with `document.createElement`.
- [ ] Add elements with `append`.
- [ ] Remove children with `replaceChildren`.
- [ ] Register event listeners.
- [ ] Prevent default form submission.
- [ ] Read input values.
- [ ] Use arrays for application state.
- [ ] Use objects for structured data.
- [ ] Use `map`, `filter`, and `find`.
- [ ] Separate behavior into functions.
- [ ] Render the DOM from application state.
- [ ] Use `textContent` for user-provided text.
- [ ] Add basic validation.
- [ ] Filter visible tasks without changing the stored collection.
