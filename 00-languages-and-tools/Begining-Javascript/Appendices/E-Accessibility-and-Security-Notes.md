# Appendix E: Accessibility and Security Notes

A working interface is not automatically an accessible or secure interface.

**Accessibility** means people with different abilities can use the application, including people who:

- Navigate with a keyboard.
- Use screen readers.
- Have limited vision.
- Have limited motor control.
- Need larger text or higher contrast.
- Use alternative input devices.

**Security** means protecting the application and its users from harmful or unauthorized behavior.

For the browser-only task application, the most important concerns are:

- Safe handling of user-entered text.
- Correct form labels.
- Keyboard access.
- Focus management.
- Meaningful buttons.
- Status announcements.
- Predictable error messages.
- Avoiding unsafe HTML injection.

This appendix focuses on practical habits you can apply immediately.

---

# E.1 Accessibility Starts with Semantic HTML

## The Target

Use HTML elements according to their meaning.

## The Concept

Semantic HTML is like labeling rooms in a building. A heading tells everyone, including assistive technology, that a new section begins. A button tells the browser that the user can activate an action.

Prefer:

```html
<button type="button">Remove</button>
```

over:

```html
<div class="remove-button">Remove</div>
```

A real button automatically supports:

- Keyboard activation.
- Focus behavior.
- Button semantics.
- Browser accessibility information.

## The Implementation

### `semantic-example.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Semantic HTML Example</title>
  </head>

  <body>
    <header>
      <h1>Task application</h1>
    </header>

    <main>
      <section aria-labelledby="tasks-heading">
        <h2 id="tasks-heading">Tasks</h2>

        <ul>
          <li>
            <span>Learn semantic HTML</span>

            <button
              type="button"
              aria-label="Mark Learn semantic HTML complete"
            >
              Complete
            </button>
          </li>
        </ul>
      </section>
    </main>
  </body>
</html>
```

## The Verification

Open the file in a browser.

Use the keyboard:

1. Press `Tab`.
2. Confirm that the button receives visible focus.
3. Press `Enter` or `Space`.
4. Confirm that the browser recognizes it as a button.

Inspect the page with Developer Tools. The task section should have a heading associated with it through:

```html
aria-labelledby="tasks-heading"
```

[COMPLETED: Semantic HTML example created]  
[NEXT: Labels and form controls]

---

# E.2 Labels and Form Controls

## The Target

Associate every form control with a visible label.

## The Concept

A label tells users what an input is for. It also gives screen readers a name for the control.

Correct association:

```html
<label for="task-title">Task title</label>
<input id="task-title" />
```

The label’s `for` value must match the input’s `id`.

## The Implementation

### `form-example.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Accessible Form</title>
  </head>

  <body>
    <main>
      <h1>Add a task</h1>

      <form id="task-form">
        <div>
          <label for="task-title">
            Task title
          </label>

          <input
            id="task-title"
            name="title"
            type="text"
            maxlength="120"
            required
          />
        </div>

        <button type="submit">
          Add task
        </button>
      </form>
    </main>
  </body>
</html>
```

## The Verification

Click the visible label text:

```text
Task title
```

The input should receive focus.

Using the keyboard, press `Tab` until the input receives focus. Type a title.

Submit the empty form. The browser should show its built-in required-field validation.

[COMPLETED: Accessible form labels verified]  
[NEXT: Keyboard navigation and focus]

---

# E.3 Keyboard Accessibility

## The Target

Ensure that users can operate the application without a mouse.

## The Concept

Keyboard users move through interactive elements with `Tab`, activate buttons with `Enter` or `Space`, and use `Shift+Tab` to move backward.

A control that works only on `mousedown` or custom mouse events is not fully accessible.

Use native controls whenever possible:

```html
<button type="button">Complete</button>
```

Do not recreate buttons with generic elements unless you also reproduce all required keyboard and accessibility behavior.

## The Implementation

Add this CSS to the application stylesheet:

### `styles.css`

```css
button:focus-visible,
input:focus-visible {
  outline: 3px solid #8bb8ff;
  outline-offset: 3px;
}
```

The `:focus-visible` pseudo-class displays a focus indicator when keyboard-style focus is appropriate.

## Verification

Open the task application.

Press `Tab` repeatedly.

Confirm:

- The input receives a visible outline.
- The Add task button receives a visible outline.
- Task action buttons receive visible outlines.
- The focus order follows a logical sequence.

Do not remove outlines without replacing them:

```css
/* Avoid this unless an accessible replacement is provided. */
button {
  outline: none;
}
```

A missing focus indicator makes keyboard navigation difficult.

[COMPLETED: Keyboard focus behavior verified]  
[NEXT: Accessible names for buttons]

---

# E.4 Accessible Names for Buttons

## The Target

Give every button a clear accessible name.

## The Concept

A visible button label is usually its accessible name:

```html
<button type="button">Remove</button>
```

If a button contains only an icon, it needs an explicit label:

```html
<button
  type="button"
  aria-label="Remove task"
>
  ×
</button>
```

The label should describe the action, not the appearance.

Less useful:

```html
aria-label="Red button"
```

Better:

```html
aria-label="Remove Practice DOM events"
```

## The Implementation

In the task-rendering function, use task-specific labels:

### `src/part-4.js`

```js
const removeButtonElement =
  document.createElement("button");

removeButtonElement.type = "button";
removeButtonElement.textContent = "Remove";
removeButtonElement.setAttribute(
  "aria-label",
  `Remove ${task.title}`
);
```

For completion:

```js
const completeButtonElement =
  document.createElement("button");

completeButtonElement.type = "button";
completeButtonElement.textContent = task.completed
  ? "Undo"
  : "Complete";

completeButtonElement.setAttribute(
  "aria-label",
  task.completed
    ? `Mark ${task.title} incomplete`
    : `Mark ${task.title} complete`
);
```

## The Verification

Inspect a generated button in Developer Tools.

It should have a readable label such as:

```text
Remove Learn the DOM
```

If you use a screen reader, the action should be distinguishable from the actions for other tasks.

[COMPLETED: Accessible button names added]  
[NEXT: Status and error announcements]

---

# E.5 Status Messages and `aria-live`

## The Target

Announce important dynamic changes without forcing the user to search the page.

## The Concept

When JavaScript changes the page, a screen reader user may not automatically know that something changed.

An `aria-live` region tells assistive technology to monitor updates.

Use:

```html
<p
  id="form-message"
  role="status"
  aria-live="polite"
></p>
```

`polite` means the message should be announced when the user is not being interrupted.

For urgent errors, use:

```html
<div
  role="alert"
  aria-live="assertive"
></div>
```

Use assertive announcements sparingly because they interrupt the user.

## The Implementation

### `index.html`

```html
<p
  id="form-message"
  class="form-message"
  role="status"
  aria-live="polite"
></p>
```

### `src/part-4.js`

```js
function showFormMessage(message, type = "normal") {
  formMessageElement.textContent = message;

  formMessageElement.className =
    "form-message";

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
```

## The Verification

Add a task.

Confirm that the message changes to:

```text
Added task: ...
```

Remove a task.

Confirm that the message changes to:

```text
Removed task: ...
```

Submit an empty form.

Confirm that an error message appears.

The message should be visible and should not be communicated only by color.

[COMPLETED: Dynamic status messages configured]  
[NEXT: Accessible error handling]

---

# E.6 Accessible Validation Errors

## The Target

Make validation failures understandable and connected to the relevant input.

## The Concept

An error should tell the user:

1. What went wrong.
2. How to fix it.
3. Which control needs attention.

A color-only error is insufficient:

```css
input {
  border: 2px solid red;
}
```

Some users cannot distinguish colors easily, and screen readers do not receive the meaning of the color.

## The Implementation

### `index.html`

Update the input and message:

```html
<input
  id="task-title"
  name="title"
  type="text"
  maxlength="120"
  aria-describedby="task-title-help form-message"
  required
/>

<p id="task-title-help">
  Enter between 1 and 120 characters.
</p>

<p
  id="form-message"
  class="form-message"
  role="status"
  aria-live="polite"
></p>
```

### `src/part-4.js`

```js
function showTitleError(message) {
  taskTitleInputElement.setAttribute(
    "aria-invalid",
    "true"
  );

  showFormMessage(message, "error");

  taskTitleInputElement.focus();
}

function clearTitleError() {
  taskTitleInputElement.setAttribute(
    "aria-invalid",
    "false"
  );
}
```

Use these functions during submission:

```js
taskFormElement.addEventListener(
  "submit",
  (event) => {
    event.preventDefault();

    const title =
      taskTitleInputElement.value.trim();

    if (title.length === 0) {
      showTitleError(
        "Enter a task title before submitting."
      );

      return;
    }

    if (title.length > 120) {
      showTitleError(
        "Task titles cannot exceed 120 characters."
      );

      return;
    }

    clearTitleError();

    // Continue creating the task.
  }
);
```

## The Verification

Submit an empty form.

Confirm:

- The message explains the problem.
- The input receives focus.
- The input has:

```html
aria-invalid="true"
```

Enter a valid title and submit.

Confirm:

```html
aria-invalid="false"
```

[COMPLETED: Accessible validation behavior added]  
[NEXT: Safe text rendering]

---

# E.7 Safe Text Rendering

## The Target

Prevent user-entered task titles from being interpreted as HTML.

## The Concept

User input is data, not markup.

Suppose a user enters:

```html
<img src="invalid" onerror="alert('unexpected code')">
```

If inserted with `innerHTML`, the browser parses it as HTML. If inserted with `textContent`, the browser displays it as ordinary text.

## The Implementation

### Safe rendering

```js
const titleElement =
  document.createElement("p");

titleElement.textContent = userProvidedTitle;
```

### Unsafe rendering

```js
const titleElement =
  document.createElement("p");

titleElement.innerHTML = userProvidedTitle;
```

Always use the safe version for task titles.

## Verification

Enter this title into the task application:

```html
<strong>Do not interpret this as HTML</strong>
```

The page should display the exact characters:

```text
<strong>Do not interpret this as HTML</strong>
```

The text should not become bold.

Test another value:

```html
<img src="missing" onerror="alert('test')">
```

No alert should appear. The text should be displayed literally.

[COMPLETED: Safe user-input rendering verified]  
[NEXT: Security boundaries and validation]

---

# E.8 Client-Side Validation Is Not Security

## The Target

Understand the limits of browser-side validation.

## The Concept

Client-side validation improves usability, but users can bypass it by:

- Editing the page in Developer Tools.
- Sending requests manually.
- Disabling JavaScript.
- Calling application functions from the console.
- Modifying network requests.

Therefore:

```text
Client validation → user experience
Server validation  → security boundary
```

For the current browser-only application, there is no server. The application still validates input for correctness, but a future backend must validate all received data independently.

## The Implementation

Client-side validation:

```js
function validateTaskTitle(title) {
  if (typeof title !== "string") {
    return {
      valid: false,
      message: "Task title must be text."
    };
  }

  const cleanedTitle = title.trim();

  if (cleanedTitle.length === 0) {
    return {
      valid: false,
      message: "Task title cannot be empty."
    };
  }

  if (cleanedTitle.length > 120) {
    return {
      valid: false,
      message:
        "Task title cannot exceed 120 characters."
    };
  }

  return {
    valid: true,
    message: ""
  };
}
```

## Verification

Run:

```js
console.log(
  validateTaskTitle("Learn JavaScript")
);

console.log(
  validateTaskTitle("   ")
);

console.log(
  validateTaskTitle("a".repeat(121))
);
```

Expected results should distinguish valid and invalid input.

[COMPLETED: Client-side validation boundaries documented]  
[NEXT: Avoid unsafe URL handling]

---

# E.9 Safe URL Handling

## The Target

Handle user-provided URLs carefully.

The current task application does not use URLs, but future applications may display links entered by users.

## The Concept

A link can be dangerous if an application blindly accepts arbitrary schemes.

Potentially unsafe example:

```text
javascript:alert("unexpected code")
```

A safe URL policy should allow only expected schemes, such as:

```text
https:
http:
```

## The Implementation

```js
function getSafeHttpUrl(rawValue) {
  if (typeof rawValue !== "string") {
    return null;
  }

  try {
    const url = new URL(rawValue);

    if (
      url.protocol !== "https:" &&
      url.protocol !== "http:"
    ) {
      return null;
    }

    return url.href;
  } catch {
    return null;
  }
}

const safeUrl = getSafeHttpUrl(
  "https://example.com"
);

console.log(safeUrl);
```

Use the validated result:

```js
if (safeUrl !== null) {
  const linkElement =
    document.createElement("a");

  linkElement.href = safeUrl;
  linkElement.textContent = "Open link";
  linkElement.target = "_blank";
  linkElement.rel = "noopener noreferrer";

  document.body.append(linkElement);
}
```

`rel="noopener noreferrer"` reduces risks when opening a new tab.

## Verification

Test:

```js
console.log(
  getSafeHttpUrl("https://example.com")
);
```

Expected: a valid URL.

Test:

```js
console.log(
  getSafeHttpUrl("javascript:alert(1)")
);
```

Expected:

```text
null
```

---

# E.10 Avoiding Dangerous Dynamic Code

## The Target

Avoid APIs that execute strings as JavaScript.

## Concept

Never treat user input as executable code.

Avoid:

```js
eval(userInput);
```

and:

```js
new Function(userInput);
```

These allow strings to become code and create serious security problems.

Use data structures and explicit functions instead:

```js
const actions = {
  complete: completeTask,
  remove: removeTask
};

const actionHandler = actions[actionName];

if (typeof actionHandler === "function") {
  actionHandler(taskId);
}
```

This approach still requires validating `actionName`, but it does not execute arbitrary JavaScript.

## Verification

Do not run `eval` with untrusted data. The safe action-map approach should use known function references only.

[COMPLETED: Dynamic code execution risks documented]  
[NEXT: Content Security Policy]

---

# E.11 Content Security Policy

## The Target

Understand the purpose of a Content Security Policy, or CSP.

## The Concept

A CSP is a browser security policy that restricts where resources may load from and whether certain types of code may execute.

A strong policy can reduce the impact of cross-site scripting vulnerabilities.

For a simple application, a policy might look like:

```text
default-src 'self';
script-src 'self';
style-src 'self';
img-src 'self' data:;
connect-src 'self';
object-src 'none';
base-uri 'self';
form-action 'self';
```

## The Implementation

For a deployed site, the preferred method is an HTTP response header:

```text
Content-Security-Policy:
  default-src 'self';
  script-src 'self';
  style-src 'self';
  img-src 'self' data:;
  connect-src 'self';
  object-src 'none';
  base-uri 'self';
  form-action 'self';
```

A temporary HTML-based version can use:

### `index.html`

```html
<meta
  http-equiv="Content-Security-Policy"
  content="
    default-src 'self';
    script-src 'self';
    style-src 'self';
    img-src 'self' data:;
    connect-src 'self';
    object-src 'none';
    base-uri 'self';
    form-action 'self';
  "
/>
```

Avoid inline scripts when using:

```text
script-src 'self'
```

Use external files:

```html
<script
  src="./src/part-4.js"
  defer
></script>
```

## Verification

Open Developer Tools and inspect the Console and Network panels.

If a resource violates the policy, the browser reports that it was blocked.

For production applications, configure CSP through server headers and test it carefully before enforcing a restrictive policy.

[COMPLETED: Content Security Policy overview completed]  
[NEXT: Accessibility testing]

---

# E.12 Accessibility Testing

## Target

Test the application with multiple methods.

## Keyboard test

1. Reload the page.
2. Press `Tab`.
3. Track the focus indicator.
4. Submit a task with the keyboard.
5. Complete a task with the keyboard.
6. Remove a task with the keyboard.
7. Confirm that no action requires a mouse.

## Screen-reader-oriented test

Inspect:

- Heading structure.
- Form label.
- Button names.
- Status messages.
- Error descriptions.
- Task count.

On many systems, built-in screen readers include:

- VoiceOver on macOS.
- Narrator on Windows.
- Orca on Linux.

## Automated tools

Useful tools include:

- Lighthouse in Chrome DevTools.
- axe DevTools.
- WAVE.
- Accessibility Insights.

Automated tools help find common problems, but they do not replace keyboard and human testing.

## Color and contrast

Do not communicate state using color alone.

Insufficient:

```text
Green means complete.
Red means incomplete.
```

Better:

- Use text such as “Complete.”
- Use a visible strikethrough.
- Use a meaningful button label.
- Use color as an additional signal.

[COMPLETED: Accessibility testing plan completed]  
[NEXT: Security review checklist]

---

# E.13 Security Review Checklist

Before considering the browser application complete, verify:

## User input

- [ ] Task titles are trimmed.
- [ ] Empty titles are rejected.
- [ ] Maximum title length is enforced.
- [ ] User text is inserted with `textContent`.
- [ ] User text is not inserted directly into `innerHTML`.
- [ ] No user input is passed to `eval`.
- [ ] No user input is passed to `new Function`.

## DOM behavior

- [ ] Required selectors are validated.
- [ ] Dynamic IDs are parsed and validated.
- [ ] Action names are compared against known values.
- [ ] Unexpected task IDs are handled safely.
- [ ] Buttons use explicit `type` attributes.

## Future server integration

- [ ] Validate all data on the server.
- [ ] Authenticate protected operations.
- [ ] Authorize access to individual records.
- [ ] Use parameterized database queries.
- [ ] Configure HTTPS.
- [ ] Add security headers.
- [ ] Avoid exposing sensitive information in client-side code.

[COMPLETED: Security review checklist completed]  
[NEXT: Accessibility review checklist]

---

# E.14 Accessibility Review Checklist

## Structure

- [ ] The page has one clear primary heading.
- [ ] Sections have meaningful headings.
- [ ] Lists use `<ul>` or `<ol>`.
- [ ] Buttons use `<button>`.
- [ ] Links use `<a>` with valid destinations.
- [ ] The document language is specified.

## Forms

- [ ] Every input has a visible label.
- [ ] Labels are connected with `for` and `id`.
- [ ] Required fields are marked.
- [ ] Errors explain how to fix the problem.
- [ ] Invalid fields use `aria-invalid`.
- [ ] Error or status messages are announced appropriately.

## Keyboard

- [ ] Every action can be completed with the keyboard.
- [ ] Focus indicators are visible.
- [ ] Focus order is logical.
- [ ] No keyboard trap exists.
- [ ] Buttons have meaningful labels.

## Dynamic content

- [ ] Task additions are announced or otherwise discoverable.
- [ ] Task removals are communicated.
- [ ] Task completion state is visible through more than color.
- [ ] Status regions use appropriate live-region behavior.

[COMPLETED: Accessibility review checklist completed]  
[NEXT: Final combined example]

---

# E.15 Final Accessible and Safe Task Markup

The following example combines the most important practices.

### `index.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Accessible Task List</title>
  </head>

  <body>
    <main>
      <header>
        <h1>Accessible Task List</h1>

        <p>
          Add and manage tasks using the keyboard or a pointer.
        </p>
      </header>

      <section aria-labelledby="add-task-heading">
        <h2 id="add-task-heading">Add a task</h2>

        <form id="task-form">
          <label for="task-title">
            Task title
          </label>

          <input
            id="task-title"
            name="title"
            type="text"
            maxlength="120"
            aria-describedby="task-help form-message"
            required
          />

          <p id="task-help">
            Enter between 1 and 120 characters.
          </p>

          <button type="submit">
            Add task
          </button>

          <p
            id="form-message"
            role="status"
            aria-live="polite"
          ></p>
        </form>
      </section>

      <section aria-labelledby="tasks-heading">
        <h2 id="tasks-heading">Your tasks</h2>

        <p id="task-count">0 tasks</p>

        <ul
          id="task-list"
          aria-live="polite"
        ></ul>

        <p id="empty-state">
          No tasks yet.
        </p>
      </section>
    </main>

    <script
      src="./src/accessible-task-example.js"
      defer
    ></script>
  </body>
</html>
```

### `src/accessible-task-example.js`

```js
"use strict";

const taskFormElement =
  document.querySelector("#task-form");

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

if (!(taskFormElement instanceof HTMLFormElement)) {
  throw new Error("Task form was not found.");
}

if (!(taskTitleInputElement instanceof HTMLInputElement)) {
  throw new Error("Task title input was not found.");
}

if (!(formMessageElement instanceof HTMLElement)) {
  throw new Error("Form message was not found.");
}

if (!(taskListElement instanceof HTMLUListElement)) {
  throw new Error("Task list was not found.");
}

if (!(emptyStateElement instanceof HTMLElement)) {
  throw new Error("Empty state was not found.");
}

if (!(taskCountElement instanceof HTMLElement)) {
  throw new Error("Task count was not found.");
}

const tasks = [];
let nextTaskId = 1;

function showMessage(message, type = "normal") {
  formMessageElement.textContent = message;
  formMessageElement.className = "";

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

function validateTitle(rawTitle) {
  if (typeof rawTitle !== "string") {
    return {
      valid: false,
      message: "Task title must be text."
    };
  }

  const title = rawTitle.trim();

  if (title.length === 0) {
    return {
      valid: false,
      message: "Enter a task title."
    };
  }

  if (title.length > 120) {
    return {
      valid: false,
      message:
        "Task titles cannot exceed 120 characters."
    };
  }

  return {
    valid: true,
    message: "",
    title
  };
}

function createTask(title) {
  const task = {
    id: nextTaskId,
    title,
    completed: false
  };

  nextTaskId += 1;

  return task;
}

function createTaskElement(task) {
  const listItemElement =
    document.createElement("li");

  listItemElement.dataset.taskId =
    String(task.id);

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

  completeButtonElement.dataset.action =
    "toggle-complete";

  completeButtonElement.setAttribute(
    "aria-label",
    task.completed
      ? `Mark ${task.title} incomplete`
      : `Mark ${task.title} complete`
  );

  const removeButtonElement =
    document.createElement("button");

  removeButtonElement.type = "button";
  removeButtonElement.textContent = "Remove";
  removeButtonElement.dataset.action = "remove";
  removeButtonElement.setAttribute(
    "aria-label",
    `Remove ${task.title}`
  );

  listItemElement.append(
    titleElement,
    completeButtonElement,
    removeButtonElement
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

  emptyStateElement.hidden = tasks.length > 0;

  const label = tasks.length === 1
    ? "task"
    : "tasks";

  taskCountElement.textContent =
    `${tasks.length} ${label}`;
}

taskFormElement.addEventListener(
  "submit",
  (event) => {
    event.preventDefault();

    const validation =
      validateTitle(
        taskTitleInputElement.value
      );

    if (!validation.valid) {
      taskTitleInputElement.setAttribute(
        "aria-invalid",
        "true"
      );

      showMessage(
        validation.message,
        "error"
      );

      taskTitleInputElement.focus();
      return;
    }

    taskTitleInputElement.setAttribute(
      "aria-invalid",
      "false"
    );

    const task = createTask(validation.title);

    tasks.push(task);
    renderTasks();

    taskFormElement.reset();
    taskTitleInputElement.focus();

    showMessage(
      `Added task: ${task.title}`,
      "success"
    );
  }
);

taskListElement.addEventListener(
  "click",
  (event) => {
    if (!(event.target instanceof Element)) {
      return;
    }

    const buttonElement =
      event.target.closest("button");

    if (buttonElement === null) {
      return;
    }

    const taskElement =
      buttonElement.closest("[data-task-id]");

    if (taskElement === null) {
      return;
    }

    const taskId = Number(
      taskElement.dataset.taskId
    );

    const task = tasks.find(
      (item) => item.id === taskId
    );

    if (task === undefined) {
      showMessage(
        "The selected task could not be found.",
        "error"
      );

      return;
    }

    const action =
      buttonElement.dataset.action;

    if (action === "toggle-complete") {
      task.completed = !task.completed;
      renderTasks();

      showMessage(
        task.completed
          ? `Completed task: ${task.title}`
          : `Reopened task: ${task.title}`,
        "success"
      );

      return;
    }

    if (action === "remove") {
      const taskIndex = tasks.findIndex(
        (item) => item.id === taskId
      );

      if (taskIndex === -1) {
        showMessage(
          "The selected task could not be removed.",
          "error"
        );

        return;
      }

      tasks.splice(taskIndex, 1);
      renderTasks();

      showMessage(
        `Removed task: ${task.title}`,
        "success"
      );
    }
  }
);

renderTasks();
showMessage(
  "The task application is ready.",
  "success"
);
```

## The Verification

Test the complete example:

- Navigate through the page with `Tab`.
- Add a valid task.
- Submit an empty task.
- Submit whitespace-only input.
- Complete a task.
- Undo a task.
- Remove a task.
- Enter HTML-looking text.
- Confirm the text remains text.
- Confirm status messages appear.
- Confirm focus returns to the input after submission.

[COMPLETED: Final accessible and safe task example verified]  
[STARTING: Appendix E final checklist]

---

# E.16 Final Checklist

Before publishing a browser application, ask:

## Accessibility

- Can the entire application be used with only a keyboard?
- Are all interactive elements real buttons or links?
- Does every input have a visible label?
- Are headings organized logically?
- Are dynamic updates communicated?
- Are errors connected to the relevant control?
- Is focus visible?
- Is information conveyed by more than color?
- Do buttons have meaningful names?

## Security

- Is user input treated as data?
- Is `textContent` used for untrusted text?
- Is unsafe `innerHTML` avoided?
- Is `eval` avoided?
- Are IDs and action values validated?
- Are URL schemes checked before creating links?
- Would a future server validate all incoming data?
- Would a future server use authentication and authorization?
- Are security headers configured for deployment?
