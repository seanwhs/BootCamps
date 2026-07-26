# Primer 1: How the Web Works

Before writing JavaScript, it helps to understand the environment where JavaScript runs.

A web application is not one language or one file. It is usually a combination of:

```text
HTML       → structure
CSS        → appearance
JavaScript → behavior
Browser    → loads, interprets, and displays everything
```

This primer explains how those pieces work together.

---

## 1. The Three Main Web Technologies

### HTML: Structure

HTML defines what exists on the page.

```html
<h1>Task List</h1>

<p>Complete your JavaScript practice.</p>

<button type="button">
  Mark complete
</button>
```

HTML answers:

```text
What elements are on the page?
```

Examples of HTML elements:

- Headings.
- Paragraphs.
- Buttons.
- Forms.
- Inputs.
- Lists.
- Links.
- Images.

You can compare HTML to the frame of a building. It defines the rooms, doors, and windows.

---

### CSS: Presentation

CSS controls how HTML looks.

```css
button {
  padding: 0.75rem 1rem;
  color: white;
  background: #2457a6;
  border: 0;
  border-radius: 0.5rem;
}
```

CSS answers:

```text
How should the elements look?
```

CSS controls:

- Colors.
- Fonts.
- Spacing.
- Borders.
- Layout.
- Responsive behavior.
- Hover states.
- Focus states.
- Completed-task styles.

CSS is similar to painting, decorating, and arranging a building.

---

### JavaScript: Behavior

JavaScript makes the page respond to actions.

```js
const buttonElement =
  document.querySelector("#complete-button");

if (buttonElement === null) {
  throw new Error(
    "Could not find #complete-button."
  );
}

buttonElement.addEventListener(
  "click",
  () => {
    buttonElement.textContent = "Completed";
  }
);
```

JavaScript answers:

```text
What should happen when something changes?
```

JavaScript can:

- Read input values.
- Respond to clicks.
- Add elements.
- Remove elements.
- Change text.
- Toggle CSS classes.
- Validate data.
- Fetch data from a server.
- Store data in the browser.

JavaScript is the behavior and control system of the building.

---

# 2. How the Browser Loads a Page

When you open a web page, the browser performs several major steps.

```text
Request a resource
    ↓
Receive HTML
    ↓
Parse HTML
    ↓
Request CSS and JavaScript
    ↓
Build the DOM and CSSOM
    ↓
Calculate layout
    ↓
Paint pixels
    ↓
Run JavaScript behavior
```

You do not need to memorize every internal browser phase yet. The important idea is that the browser transforms source files into a visible, interactive page.

---

## Step 1: The Browser Requests a Page

When you visit:

```text
https://example.com
```

the browser sends a request to a server.

The server sends files back, commonly including:

```text
index.html
styles.css
app.js
```

For a local project, the request may look like:

```text
http://localhost:5500/index.html
```

In this case, a local development server is sending files from your computer.

---

## Step 2: The Browser Reads HTML

The browser reads:

```html
<h1>Task List</h1>
```

and creates an internal representation of that element.

The browser builds a tree:

```text
document
└── html
    ├── head
    └── body
        └── h1
            └── "Task List"
```

This tree is called the **DOM**, or Document Object Model.

---

## Step 3: The Browser Loads CSS

When HTML contains:

```html
<link
  rel="stylesheet"
  href="./styles.css"
/>
```

the browser requests `styles.css`.

It reads rules such as:

```css
h1 {
  color: #2457a6;
}
```

Then it determines how the heading should appear.

---

## Step 4: The Browser Loads JavaScript

When HTML contains:

```html
<script
  src="./src/app.js"
  defer
></script>
```

the browser requests and executes `app.js`.

The script can access the DOM:

```js
const headingElement =
  document.querySelector("h1");
```

It can then modify the page:

```js
headingElement.textContent =
  "JavaScript changed this heading.";
```

---

# 3. The Browser as a Runtime

A **runtime** is an environment that executes code.

For this series:

```text
Browser runtime
├── JavaScript engine
├── DOM APIs
├── Events
├── Web storage
└── Network APIs
```

The browser does more than execute basic JavaScript. It also provides browser-specific APIs.

Examples:

```js
document.querySelector("#task-list");
```

The `document` object is provided by the browser.

```js
localStorage.setItem("theme", "dark");
```

`localStorage` is provided by the browser.

```js
fetch("/api/tasks");
```

`fetch` is provided by the browser.

These are not ordinary JavaScript language features. They are Web APIs supplied by the browser.

---

## JavaScript Language Versus Browser APIs

### JavaScript language features

```js
const task = {
  title: "Learn JavaScript",
  completed: false
};

function createTask(title) {
  return {
    title,
    completed: false
  };
}
```

These language features can run in multiple environments, including:

- Browsers.
- Node.js.
- Deno.
- Bun.

### Browser APIs

```js
document.querySelector("#task-list");
window.setTimeout(() => {
  console.log("Finished");
}, 1000);
localStorage.setItem("tasks", "[]");
```

These depend on the browser environment.

A useful distinction is:

```text
JavaScript      → language
Browser APIs    → environment capabilities
```

---

# 4. The DOM

## The Target

Understand how JavaScript sees HTML.

## Concept

The DOM is a live object tree representing the document.

Given this HTML:

```html
<main id="app">
  <h1>Task List</h1>

  <ul id="task-list">
    <li>Learn JavaScript</li>
  </ul>
</main>
```

the browser creates a structure conceptually similar to:

```text
document
└── main#app
    ├── h1
    │   └── "Task List"
    └── ul#task-list
        └── li
            └── "Learn JavaScript"
```

JavaScript can select and change these nodes.

## Implementation

### `dom-primer.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>DOM Primer</title>
  </head>

  <body>
    <main id="app">
      <h1 id="page-heading">
        Original heading
      </h1>

      <p id="status-message">
        Original status
      </p>

      <ul id="task-list">
        <li>Learn HTML</li>
        <li>Learn CSS</li>
      </ul>
    </main>

    <script src="./dom-primer.js" defer></script>
  </body>
</html>
```

### `dom-primer.js`

```js
"use strict";

const headingElement =
  document.querySelector("#page-heading");

const statusMessageElement =
  document.querySelector("#status-message");

const taskListElement =
  document.querySelector("#task-list");

if (headingElement === null) {
  throw new Error(
    "Could not find #page-heading."
  );
}

if (statusMessageElement === null) {
  throw new Error(
    "Could not find #status-message."
  );
}

if (taskListElement === null) {
  throw new Error(
    "Could not find #task-list."
  );
}

headingElement.textContent =
  "JavaScript changed the heading.";

statusMessageElement.textContent =
  "JavaScript found and updated the DOM.";

const newTaskElement =
  document.createElement("li");

newTaskElement.textContent =
  "Learn the DOM";

taskListElement.append(newTaskElement);

console.log("Heading:", headingElement);
console.log("Task list:", taskListElement);
```

## Verification

Open `dom-primer.html` with a local development server.

The page should display:

```text
JavaScript changed the heading.
JavaScript found and updated the DOM.
```

The list should contain:

```text
Learn HTML
Learn CSS
Learn the DOM
```

Open Developer Tools and inspect the Elements panel. You should see the newly created `<li>` element.

[COMPLETED: DOM mental model demonstrated]  
[NEXT: CSS and visual state]

---

# 5. CSS Classes as Visual State

## The Target

Understand how JavaScript and CSS cooperate.

## Concept

JavaScript should usually describe a state by adding or removing a class. CSS decides how that state looks.

For example:

```text
JavaScript: task is completed
CSS:       completed tasks use a strikethrough
```

This separates behavior from presentation.

## Implementation

### `state-primer.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Visual State Primer</title>

    <style>
      .task-title {
        color: #172033;
        font-weight: 700;
      }

      .task-title--completed {
        color: #667085;
        text-decoration: line-through;
      }
    </style>
  </head>

  <body>
    <main>
      <h1>Visual state</h1>

      <p
        id="task-title"
        class="task-title"
      >
        Practice CSS classes
      </p>

      <button
        id="toggle-button"
        type="button"
      >
        Toggle complete
      </button>
    </main>

    <script>
      "use strict";

      const taskTitleElement =
        document.querySelector("#task-title");

      const toggleButtonElement =
        document.querySelector("#toggle-button");

      if (taskTitleElement === null) {
        throw new Error(
          "Could not find #task-title."
        );
      }

      if (toggleButtonElement === null) {
        throw new Error(
          "Could not find #toggle-button."
        );
      }

      let isCompleted = false;

      toggleButtonElement.addEventListener(
        "click",
        () => {
          isCompleted = !isCompleted;

          taskTitleElement.classList.toggle(
            "task-title--completed",
            isCompleted
          );

          toggleButtonElement.textContent =
            isCompleted
              ? "Mark incomplete"
              : "Toggle complete";
        }
      );
    </script>
  </body>
</html>
```

## Verification

Open the page.

Click **Toggle complete**.

Confirm:

- The text receives a strikethrough.
- The text color changes.
- The button label changes.

Click again.

Confirm the visual state returns to incomplete.

The important architecture is:

```text
JavaScript state
    ↓
CSS class
    ↓
Visual appearance
```

[COMPLETED: JavaScript and CSS state relationship demonstrated]  
[NEXT: Events and user interaction]

---

# 6. Events: Things That Happen

## The Target

Understand how a browser application reacts to user actions.

## Concept

An event is a notification that something happened.

Examples:

```text
click
submit
input
change
keydown
focus
```

JavaScript listens for events with `addEventListener`.

## Implementation

### `event-primer.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Event Primer</title>
  </head>

  <body>
    <main>
      <h1>Events</h1>

      <label for="name-input">
        Your name
      </label>

      <input
        id="name-input"
        type="text"
      />

      <button
        id="greet-button"
        type="button"
      >
        Greet
      </button>

      <p id="message"></p>
    </main>

    <script>
      "use strict";

      const nameInputElement =
        document.querySelector("#name-input");

      const greetButtonElement =
        document.querySelector("#greet-button");

      const messageElement =
        document.querySelector("#message");

      if (nameInputElement === null) {
        throw new Error(
          "Could not find #name-input."
        );
      }

      if (greetButtonElement === null) {
        throw new Error(
          "Could not find #greet-button."
        );
      }

      if (messageElement === null) {
        throw new Error(
          "Could not find #message."
        );
      }

      greetButtonElement.addEventListener(
        "click",
        () => {
          const name =
            nameInputElement.value.trim();

          if (name.length === 0) {
            messageElement.textContent =
              "Enter your name first.";

            nameInputElement.focus();
            return;
          }

          messageElement.textContent =
            `Hello, ${name}!`;
        }
      );
    </script>
  </body>
</html>
```

## Verification

Open the page.

Click **Greet** without entering a name.

Expected:

```text
Enter your name first.
```

Enter:

```text
Amina
```

Click **Greet**.

Expected:

```text
Hello, Amina!
```

This is the basic interactive pattern:

```text
User action
    ↓
Event listener
    ↓
Read DOM data
    ↓
Validate data
    ↓
Update DOM
```

[COMPLETED: Basic event interaction demonstrated]  
[NEXT: Forms and default browser behavior]

---

# 7. Forms and Default Browser Behavior

## The Target

Understand why JavaScript uses `preventDefault()` for client-side forms.

## Concept

A browser form normally submits its data. In a traditional application, that may navigate to another page or reload the current page.

A JavaScript application often handles the form itself:

```js
event.preventDefault();
```

This means:

> Do not perform the browser’s normal submission action. Let my JavaScript handler process it.

## Implementation

### `form-primer.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Form Primer</title>
  </head>

  <body>
    <main>
      <h1>Add a task</h1>

      <form id="task-form">
        <label for="task-title">
          Task title
        </label>

        <input
          id="task-title"
          name="title"
          type="text"
          required
        />

        <button type="submit">
          Add task
        </button>
      </form>

      <p id="message"></p>
    </main>

    <script>
      "use strict";

      const taskFormElement =
        document.querySelector("#task-form");

      const taskTitleInputElement =
        document.querySelector("#task-title");

      const messageElement =
        document.querySelector("#message");

      if (
        !(taskFormElement instanceof HTMLFormElement)
      ) {
        throw new Error(
          "Could not find the task form."
        );
      }

      if (
        !(taskTitleInputElement
          instanceof HTMLInputElement)
      ) {
        throw new Error(
          "Could not find the task input."
        );
      }

      if (messageElement === null) {
        throw new Error(
          "Could not find the message element."
        );
      }

      taskFormElement.addEventListener(
        "submit",
        (event) => {
          event.preventDefault();

          const title =
            taskTitleInputElement.value.trim();

          if (title.length === 0) {
            messageElement.textContent =
              "Enter a task title.";

            taskTitleInputElement.focus();
            return;
          }

          messageElement.textContent =
            `Accepted task: ${title}`;

          taskFormElement.reset();
          taskTitleInputElement.focus();
        }
      );
    </script>
  </body>
</html>
```

## Verification

Submit an empty form.

The browser should prevent submission because the input is required.

Enter:

```text
Practice form events
```

Submit the form.

Expected:

```text
Accepted task: Practice form events
```

The page should not reload, and the input should clear.

[COMPLETED: Form behavior demonstrated]  
[NEXT: The complete web-application mental model]

---

# 8. The Complete Mental Model

A simple interactive web application contains three connected layers.

## Layer 1: Structure

HTML defines the available elements:

```html
<form id="task-form">
  <input id="task-title" />
  <button type="submit">Add task</button>
</form>

<ul id="task-list"></ul>
```

## Layer 2: State

JavaScript stores what the application knows:

```js
const tasks = [
  {
    id: 1,
    title: "Learn how the web works",
    completed: false
  }
];
```

## Layer 3: Behavior

JavaScript responds to user actions:

```js
taskFormElement.addEventListener(
  "submit",
  (event) => {
    event.preventDefault();

    const task = {
      id: 2,
      title: taskTitleInputElement.value.trim(),
      completed: false
    };

    tasks.push(task);
    renderTasks(tasks);
  }
);
```

## Layer 4: Presentation

CSS determines how the result appears:

```css
.task-item--completed {
  text-decoration: line-through;
  color: #667085;
}
```

The full cycle is:

```text
HTML provides structure
    ↓
JavaScript selects structure
    ↓
User performs an action
    ↓
JavaScript receives an event
    ↓
JavaScript updates state
    ↓
JavaScript renders state
    ↓
CSS presents the new state
```

---

# 9. A Small Complete Example

The following example combines the concepts into one small application.

### `web-mental-model.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Web Mental Model</title>

    <style>
      body {
        margin: 2rem;
        font-family: system-ui, sans-serif;
      }

      .task-list {
        padding: 0;
        list-style: none;
      }

      .task-item {
        display: flex;
        gap: 1rem;
        align-items: center;
        margin-block: 0.5rem;
      }

      .task-item--completed {
        color: #667085;
        text-decoration: line-through;
      }
    </style>
  </head>

  <body>
    <main>
      <h1>Task List</h1>

      <form id="task-form">
        <label for="task-title">
          Task title
        </label>

        <input
          id="task-title"
          name="title"
          type="text"
          required
        />

        <button type="submit">
          Add task
        </button>
      </form>

      <p
        id="message"
        role="status"
        aria-live="polite"
      ></p>

      <ul
        id="task-list"
        class="task-list"
      ></ul>
    </main>

    <script>
      "use strict";

      const taskFormElement =
        document.querySelector("#task-form");

      const taskTitleInputElement =
        document.querySelector("#task-title");

      const messageElement =
        document.querySelector("#message");

      const taskListElement =
        document.querySelector("#task-list");

      if (
        !(taskFormElement instanceof HTMLFormElement)
      ) {
        throw new Error(
          "Task form was not found."
        );
      }

      if (
        !(taskTitleInputElement
          instanceof HTMLInputElement)
      ) {
        throw new Error(
          "Task title input was not found."
        );
      }

      if (messageElement === null) {
        throw new Error(
          "Message element was not found."
        );
      }

      if (taskListElement === null) {
        throw new Error(
          "Task list was not found."
        );
      }

      const tasks = [];
      let nextTaskId = 1;

      function createTask(title) {
        return {
          id: nextTaskId,
          title,
          completed: false
        };
      }

      function createTaskElement(task) {
        const listItemElement =
          document.createElement("li");

        listItemElement.className =
          "task-item";

        if (task.completed) {
          listItemElement.classList.add(
            "task-item--completed"
          );
        }

        const titleElement =
          document.createElement("span");

        titleElement.textContent = task.title;

        const completeButtonElement =
          document.createElement("button");

        completeButtonElement.type = "button";
        completeButtonElement.textContent =
          task.completed
            ? "Undo"
            : "Complete";

        completeButtonElement.addEventListener(
          "click",
          () => {
            task.completed = !task.completed;
            renderTasks();
          }
        );

        listItemElement.append(
          titleElement,
          completeButtonElement
        );

        return listItemElement;
      }

      function renderTasks() {
        taskListElement.replaceChildren();

        for (const task of tasks) {
          taskListElement.append(
            createTaskElement(task)
          );
        }
      }

      taskFormElement.addEventListener(
        "submit",
        (event) => {
          event.preventDefault();

          const title =
            taskTitleInputElement.value.trim();

          if (title.length === 0) {
            messageElement.textContent =
              "Enter a task title.";

            taskTitleInputElement.focus();
            return;
          }

          const task = createTask(title);

          nextTaskId += 1;
          tasks.push(task);

          renderTasks();

          messageElement.textContent =
            `Added task: ${task.title}`;

          taskFormElement.reset();
          taskTitleInputElement.focus();
        }
      );

      renderTasks();
    </script>
  </body>
</html>
```

## Verification

Open the file with a local server.

Confirm:

1. The page loads with an empty task list.
2. A task can be added.
3. The task appears in the list.
4. The task can be marked complete.
5. The completed style appears.
6. The task can be marked incomplete again.
7. The form does not reload the page.

[COMPLETED: Complete web mental model demonstrated]  
[NEXT: Primer 1 summary]

---

# 10. Primer 1 Summary

A web application is built from cooperating layers:

```text
HTML
    ↓
Page structure

CSS
    ↓
Visual presentation

JavaScript
    ↓
Behavior and state

Browser APIs
    ↓
DOM, events, storage, and networking
```

The browser loads those resources and creates a live page:

```text
Source files
    ↓
Browser parser and JavaScript engine
    ↓
DOM and styles
    ↓
Visible interface
```

The core interactive pattern is:

```text
User action
    ↓
Event handler
    ↓
Read input
    ↓
Validate data
    ↓
Update application state
    ↓
Render state into the DOM
    ↓
CSS displays the result
```

Keep these ideas in mind as you begin the technical parts:

- HTML defines structure.
- CSS defines presentation.
- JavaScript defines behavior.
- The DOM connects JavaScript to HTML.
- Events notify JavaScript that something happened.
- State represents what the application currently knows.
- Rendering converts state into visible page content.
- User input must be validated and safely rendered.
