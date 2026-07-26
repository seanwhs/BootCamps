# Appendix C: DOM API Reference

The **Document Object Model**, or DOM, is the browser’s live JavaScript representation of an HTML document.

When the browser reads:

```html
<h1>Task List</h1>
```

it creates an object representing that heading. JavaScript can then:

- Find the object.
- Read its content.
- Change its content.
- Add CSS classes.
- Create new elements.
- Remove elements.
- Listen for user interactions.

The DOM is the bridge between JavaScript logic and the visible page.

---

# C.1 Basic HTML Document

The following page provides a small DOM to inspect:

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

    <title>DOM Reference</title>
  </head>

  <body>
    <main id="app">
      <h1 id="page-heading">DOM Reference</h1>

      <p id="status-message">
        Waiting for JavaScript.
      </p>

      <button
        id="action-button"
        type="button"
      >
        Run action
      </button>

      <ul id="item-list">
        <li class="item">First item</li>
        <li class="item">Second item</li>
      </ul>
    </main>

    <script src="./dom-reference.js" defer></script>
  </body>
</html>
```

The page has this approximate DOM tree:

```text
document
└── html
    ├── head
    │   ├── meta
    │   ├── meta
    │   └── title
    │
    └── body
        └── main#app
            ├── h1#page-heading
            ├── p#status-message
            ├── button#action-button
            └── ul#item-list
                ├── li.item
                └── li.item
```

---

# C.2 Selecting One Element with `querySelector`

## Purpose

`document.querySelector()` returns the first element matching a CSS selector.

### Select by ID

```js
const headingElement =
  document.querySelector("#page-heading");
```

The `#` means an ID selector.

### Select by class

```js
const firstItemElement =
  document.querySelector(".item");
```

The `.` means a class selector.

### Select by tag name

```js
const firstButtonElement =
  document.querySelector("button");
```

### Select by attribute

```js
const actionButtonElement =
  document.querySelector(
    "button[type='button']"
  );
```

### Select a nested element

```js
const firstListItemElement =
  document.querySelector(
    "#item-list .item"
  );
```

## Important behavior

If no element matches, the result is `null`:

```js
const missingElement =
  document.querySelector("#does-not-exist");

console.log(missingElement);
```

Expected result:

```text
null
```

Always account for this when the element is required.

### Safe selection pattern

```js
const statusMessageElement =
  document.querySelector("#status-message");

if (statusMessageElement === null) {
  throw new Error(
    "Could not find #status-message."
  );
}

statusMessageElement.textContent =
  "The element was found.";
```

---

# C.3 Selecting Multiple Elements with `querySelectorAll`

## Purpose

`document.querySelectorAll()` returns all elements matching a CSS selector.

```js
const itemElements =
  document.querySelectorAll(".item");
```

The result is a `NodeList`.

Loop through it with `for...of`:

```js
for (const itemElement of itemElements) {
  console.log(itemElement.textContent);
}
```

Expected output:

```text
First item
Second item
```

You can also use `forEach`:

```js
itemElements.forEach((itemElement) => {
  console.log(itemElement.textContent);
});
```

## Convert to an array

A `NodeList` can be converted to an array:

```js
const itemArray = Array.from(itemElements);

console.log(Array.isArray(itemArray));
```

Expected result:

```text
true
```

The spread operator also works:

```js
const itemArray = [
  ...itemElements
];
```

---

# C.4 Reading and Writing Text with `textContent`

## Purpose

`textContent` reads or replaces the text inside an element.

### Read text

```js
const headingElement =
  document.querySelector("#page-heading");

if (headingElement === null) {
  throw new Error("Heading was not found.");
}

console.log(headingElement.textContent);
```

### Write text

```js
headingElement.textContent =
  "Updated heading";
```

The browser now displays:

```text
Updated heading
```

## Safe handling of user input

Use `textContent` for user-provided values:

```js
const userTitle =
  "<strong>Untrusted title</strong>";

const titleElement =
  document.createElement("p");

titleElement.textContent = userTitle;
```

The browser displays the literal characters:

```text
<strong>Untrusted title</strong>
```

It does not create a bold element.

This is safer than:

```js
titleElement.innerHTML = userTitle;
```

`innerHTML` parses the value as HTML and can create security problems when used with untrusted input.

---

# C.5 `innerHTML`

## Purpose

`innerHTML` reads or replaces an element’s HTML markup.

```js
const appElement =
  document.querySelector("#app");

if (appElement === null) {
  throw new Error("App element was not found.");
}

appElement.innerHTML =
  "<p>Generated paragraph</p>";
```

The browser interprets the string as markup.

## Security warning

Do not place untrusted values directly inside `innerHTML`:

```js
const userTitle = getUserInput();

appElement.innerHTML =
  `<p>${userTitle}</p>`;
```

A malicious value could insert unwanted elements or scripts.

Prefer DOM methods and `textContent`:

```js
const paragraphElement =
  document.createElement("p");

paragraphElement.textContent = userTitle;

appElement.replaceChildren(
  paragraphElement
);
```

## When `innerHTML` may be acceptable

`innerHTML` can be appropriate for fully static, trusted markup:

```js
const staticMarkup =
  "<strong>Loading...</strong>";

statusElement.innerHTML = staticMarkup;
```

However, `createElement`, `append`, and `textContent` make it easier to distinguish structure from data.

---

# C.6 Creating Elements with `createElement`

## Purpose

`document.createElement()` creates an element in memory.

```js
const listItemElement =
  document.createElement("li");
```

At this point, the element is not visible. It must be appended to the DOM.

### Complete example

```js
const listElement =
  document.querySelector("#item-list");

if (listElement === null) {
  throw new Error("List was not found.");
}

const newItemElement =
  document.createElement("li");

newItemElement.textContent =
  "Created with JavaScript";

listElement.append(newItemElement);
```

The new list item now appears on the page.

---

# C.7 Appending Elements

## `append`

`append()` adds nodes or text to the end of an element.

```js
const listElement =
  document.querySelector("#item-list");

if (listElement === null) {
  throw new Error("List was not found.");
}

const firstNewItem =
  document.createElement("li");

firstNewItem.textContent = "Third item";

const secondNewItem =
  document.createElement("li");

secondNewItem.textContent = "Fourth item";

listElement.append(
  firstNewItem,
  secondNewItem
);
```

## `appendChild`

`appendChild()` adds one node:

```js
listElement.appendChild(firstNewItem);
```

`append()` is generally more flexible because it accepts multiple nodes and text.

## Insert before another element

```js
listElement.prepend(firstNewItem);
```

`prepend()` inserts at the beginning.

---

# C.8 Removing Elements

## Remove an element directly

```js
const firstItemElement =
  document.querySelector(".item");

if (firstItemElement === null) {
  throw new Error("Item was not found.");
}

firstItemElement.remove();
```

The first matching item disappears from the page.

## Remove all children

```js
const listElement =
  document.querySelector("#item-list");

if (listElement === null) {
  throw new Error("List was not found.");
}

listElement.replaceChildren();
```

`replaceChildren()` clears the element safely.

This is useful when rendering a complete collection:

```js
function renderItems(items) {
  listElement.replaceChildren();

  for (const item of items) {
    const itemElement =
      document.createElement("li");

    itemElement.textContent = item;
    listElement.append(itemElement);
  }
}
```

---

# C.9 Classes with `className`

`className` reads or replaces the full class attribute.

```js
const itemElement =
  document.querySelector(".item");

if (itemElement === null) {
  throw new Error("Item was not found.");
}

itemElement.className =
  "item item--highlighted";
```

This replaces every existing class.

Use `className` when you intentionally want to replace the complete class list.

---

# C.10 Classes with `classList`

`classList` provides methods for managing individual classes.

### Add a class

```js
itemElement.classList.add(
  "item--highlighted"
);
```

### Remove a class

```js
itemElement.classList.remove(
  "item--highlighted"
);
```

### Toggle a class

```js
itemElement.classList.toggle(
  "item--highlighted"
);
```

If the class exists, it is removed. If it does not exist, it is added.

### Check for a class

```js
const isHighlighted =
  itemElement.classList.contains(
    "item--highlighted"
  );

console.log(isHighlighted);
```

### Force a known state

The second argument to `toggle` explicitly controls whether the class should exist:

```js
const isCompleted = true;

itemElement.classList.toggle(
  "task-item--completed",
  isCompleted
);
```

This is useful when the data is the source of truth.

---

# C.11 Attributes

## Set an attribute

```js
const buttonElement =
  document.querySelector("#action-button");

if (buttonElement === null) {
  throw new Error("Button was not found.");
}

buttonElement.setAttribute(
  "aria-label",
  "Run task action"
);
```

## Read an attribute

```js
const label =
  buttonElement.getAttribute("aria-label");

console.log(label);
```

## Check for an attribute

```js
const hasLabel =
  buttonElement.hasAttribute("aria-label");

console.log(hasLabel);
```

## Remove an attribute

```js
buttonElement.removeAttribute(
  "aria-label"
);
```

## Common direct properties

Many common attributes can be accessed as properties:

```js
buttonElement.type = "button";
buttonElement.disabled = true;
```

For an input:

```js
const inputElement =
  document.createElement("input");

inputElement.type = "text";
inputElement.name = "title";
inputElement.placeholder =
  "Enter a title";
inputElement.required = true;
```

---

# C.12 `data-*` Attributes and `dataset`

Custom metadata can be stored in `data-*` attributes.

### HTML

```html
<li
  class="task-item"
  data-task-id="42"
>
  Learn DOM events
</li>
```

### JavaScript

```js
const taskElement =
  document.querySelector(".task-item");

if (taskElement === null) {
  throw new Error("Task element was not found.");
}

console.log(taskElement.dataset.taskId);
```

Expected result:

```text
42
```

The DOM stores data attributes as strings:

```js
const taskId = Number(
  taskElement.dataset.taskId
);
```

Validate the conversion:

```js
if (!Number.isSafeInteger(taskId)) {
  throw new Error("Invalid task ID.");
}
```

### Create a data attribute

```js
taskElement.dataset.taskId = "43";
```

This produces:

```html
data-task-id="43"
```

### Naming conversion

HTML:

```html
data-user-name="Amina"
```

JavaScript:

```js
element.dataset.userName;
```

The hyphenated name becomes camelCase.

---

# C.13 Forms and Input Values

## Read an input value

```js
const inputElement =
  document.querySelector("#task-title");

if (!(inputElement instanceof HTMLInputElement)) {
  throw new Error("Task title input was not found.");
}

const rawTitle = inputElement.value;
const title = rawTitle.trim();

console.log(title);
```

## Set an input value

```js
inputElement.value =
  "Practice form inputs";
```

## Clear an input

```js
inputElement.value = "";
```

## Reset an entire form

```js
const formElement =
  document.querySelector("#task-form");

if (!(formElement instanceof HTMLFormElement)) {
  throw new Error("Task form was not found.");
}

formElement.reset();
```

## Focus an input

```js
inputElement.focus();
```

## Check validity

HTML validation:

```html
<input
  id="task-title"
  required
  maxlength="120"
/>
```

JavaScript:

```js
if (!formElement.checkValidity()) {
  console.log("The form is invalid.");
}
```

You can also inspect one input:

```js
if (!inputElement.checkValidity()) {
  console.log(
    inputElement.validationMessage
  );
}
```

Client-side validation improves user experience, but server-side applications must validate data again on the server.

---

# C.14 Event Listeners

## Basic event listener

```js
const buttonElement =
  document.querySelector("#action-button");

if (buttonElement === null) {
  throw new Error("Button was not found.");
}

buttonElement.addEventListener(
  "click",
  () => {
    console.log("Button clicked.");
  }
);
```

## Named event handler

```js
function handleButtonClick() {
  console.log("Button clicked.");
}

buttonElement.addEventListener(
  "click",
  handleButtonClick
);
```

Using a named function makes it possible to remove the listener later.

## Remove an event listener

```js
buttonElement.removeEventListener(
  "click",
  handleButtonClick
);
```

The same function reference must be supplied. This does not work:

```js
buttonElement.removeEventListener(
  "click",
  () => {
    console.log("Button clicked.");
  }
);
```

That creates a new function instead of referencing the original one.

---

# C.15 The Event Object

```js
buttonElement.addEventListener(
  "click",
  (event) => {
    console.log(event);
  }
);
```

Useful properties include:

### `event.type`

```js
console.log(event.type);
```

Expected result:

```text
click
```

### `event.target`

The element where the event began:

```js
console.log(event.target);
```

### `event.currentTarget`

The element whose listener is currently running:

```js
console.log(event.currentTarget);
```

These may differ when event bubbling is involved.

---

# C.16 Form Submission Events

HTML forms should normally be handled through the `submit` event:

```js
const formElement =
  document.querySelector("#task-form");

if (!(formElement instanceof HTMLFormElement)) {
  throw new Error("Form was not found.");
}

formElement.addEventListener(
  "submit",
  (event) => {
    event.preventDefault();

    console.log("Form submitted.");
  }
);
```

Why use `submit` rather than only listening for a button click?

Because `submit` also handles:

- Clicking the submit button.
- Pressing Enter inside a form input.
- Other browser-supported submission methods.

---

# C.17 `preventDefault`

Browsers have default behaviors.

Examples:

- A form submits and may reload the page.
- A link navigates to another URL.
- A checkbox changes state.
- A drag operation begins.

Use `preventDefault()` when your application intentionally replaces that behavior.

```js
formElement.addEventListener(
  "submit",
  (event) => {
    event.preventDefault();

    // Custom application behavior.
  }
);
```

Do not call it automatically for every event. Only prevent behavior when the application needs to handle it differently.

---

# C.18 Event Bubbling

Events normally move upward through ancestor elements.

### HTML

```html
<div id="outer">
  <button id="inner" type="button">
    Click
  </button>
</div>
```

### JavaScript

```js
const outerElement =
  document.querySelector("#outer");

const innerButtonElement =
  document.querySelector("#inner");

if (
  outerElement === null ||
  innerButtonElement === null
) {
  throw new Error("Required elements missing.");
}

outerElement.addEventListener(
  "click",
  () => {
    console.log("Outer element handled click.");
  }
);

innerButtonElement.addEventListener(
  "click",
  () => {
    console.log("Button handled click.");
  }
);
```

Clicking the button usually logs:

```text
Button handled click.
Outer element handled click.
```

The event began at the button and bubbled to the outer element.

---

# C.19 Event Delegation

Event delegation attaches one listener to a stable parent.

### HTML

```html
<ul id="task-list">
  <li data-task-id="1">
    <button
      type="button"
      data-action="remove"
    >
      Remove
    </button>
  </li>
</ul>
```

### JavaScript

```js
const taskListElement =
  document.querySelector("#task-list");

if (taskListElement === null) {
  throw new Error("Task list was not found.");
}

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

    const action =
      buttonElement.dataset.action;

    const taskId = Number(
      taskElement.dataset.taskId
    );

    console.log({
      action,
      taskId
    });
  }
);
```

This continues to work if JavaScript later adds more task items.

---

# C.20 `closest`

`closest()` finds the nearest ancestor matching a selector, including the element itself.

```js
const buttonElement =
  event.target.closest("button");
```

If the click originated on a nested element inside the button, `closest("button")` still finds the button.

If no match exists, it returns `null`.

Safe pattern:

```js
const taskElement =
  event.target.closest("[data-task-id]");

if (taskElement === null) {
  return;
}
```

---

# C.21 `matches`

`matches()` checks whether an element matches a selector.

```js
if (
  event.target instanceof Element &&
  event.target.matches("button[data-action='remove']")
) {
  console.log("Remove action selected.");
}
```

`matches()` checks one element. `closest()` searches upward through ancestors.

---

# C.22 Keyboard Events

### `keydown`

```js
const inputElement =
  document.querySelector("#task-title");

if (inputElement === null) {
  throw new Error("Input was not found.");
}

inputElement.addEventListener(
  "keydown",
  (event) => {
    if (event.key === "Escape") {
      inputElement.value = "";
    }
  }
);
```

### Enter key

For forms, prefer the form’s `submit` event. If you need to inspect a key:

```js
inputElement.addEventListener(
  "keydown",
  (event) => {
    if (event.key === "Enter") {
      console.log("Enter pressed.");
    }
  }
);
```

### Modifier keys

```js
document.addEventListener(
  "keydown",
  (event) => {
    if (event.ctrlKey && event.key === "s") {
      event.preventDefault();
      console.log("Custom save shortcut.");
    }
  }
);
```

On macOS, use `event.metaKey` for the Command key.

---

# C.23 `DOMContentLoaded` and `defer`

If a script runs before the HTML elements exist, selection may return `null`.

One option is to wait for `DOMContentLoaded`:

```js
document.addEventListener(
  "DOMContentLoaded",
  () => {
    const headingElement =
      document.querySelector("h1");

    console.log(headingElement);
  }
);
```

A simpler option is to use `defer`:

```html
<script
  src="./src/app.js"
  defer
></script>
```

With `defer`, the browser downloads the script while parsing HTML but executes it after parsing is complete.

For ordinary external application scripts, `defer` is a good default.

---

# C.24 Element Properties and Methods

Common element properties:

```js
element.id;
element.className;
element.textContent;
element.innerHTML;
element.value;
element.disabled;
element.hidden;
```

Common element methods:

```js
element.append();
element.prepend();
element.remove();
element.replaceChildren();
element.focus();
element.click();
element.setAttribute();
element.getAttribute();
element.removeAttribute();
element.addEventListener();
element.removeEventListener();
```

Use the property or method that matches the task.

For example:

```js
emptyStateElement.hidden = true;
```

is clearer than manually writing:

```js
emptyStateElement.style.display = "none";
```

The `hidden` property expresses the semantic intent: the element is currently hidden.

---

# C.25 Inline Styles

JavaScript can change styles directly:

```js
messageElement.style.color = "red";
```

This is valid but often less maintainable than toggling a class:

```js
messageElement.classList.add(
  "form-message--error"
);
```

Prefer CSS classes for application states:

```css
.form-message--error {
  color: #b42318;
}
```

JavaScript:

```js
messageElement.classList.toggle(
  "form-message--error",
  hasError
);
```

This keeps visual rules in CSS.

---

# C.26 Complete DOM Example

The following file demonstrates the main APIs together.

### `dom-reference.js`

```js
"use strict";

const headingElement =
  document.querySelector("#page-heading");

const statusMessageElement =
  document.querySelector("#status-message");

const actionButtonElement =
  document.querySelector("#action-button");

const itemListElement =
  document.querySelector("#item-list");

if (headingElement === null) {
  throw new Error("Heading was not found.");
}

if (statusMessageElement === null) {
  throw new Error("Status message was not found.");
}

if (actionButtonElement === null) {
  throw new Error("Action button was not found.");
}

if (itemListElement === null) {
  throw new Error("Item list was not found.");
}

function createListItem(text) {
  const itemElement =
    document.createElement("li");

  itemElement.className = "item";
  itemElement.textContent = text;

  return itemElement;
}

function renderItems(items) {
  itemListElement.replaceChildren();

  for (const item of items) {
    itemListElement.append(
      createListItem(item)
    );
  }
}

const items = [
  "Selected with querySelector",
  "Created with createElement",
  "Rendered with append"
];

headingElement.textContent =
  "DOM APIs are working";

statusMessageElement.textContent =
  "The page was updated by JavaScript.";

renderItems(items);

actionButtonElement.addEventListener(
  "click",
  () => {
    actionButtonElement.classList.toggle(
      "is-active"
    );

    statusMessageElement.textContent =
      actionButtonElement.classList.contains(
        "is-active"
      )
        ? "The button is active."
        : "The button is inactive.";
  }
);
```

## Verification

Open the page in a browser.

Confirm:

- The heading changes.
- The status message changes.
- The list is rebuilt.
- Clicking the button changes the status.
- Clicking the button again toggles the state back.

---

# C.27 Common DOM Mistakes

## Mistake 1: Selecting before the element exists

Problem:

```html
<script src="./app.js"></script>

<h1 id="heading">Heading</h1>
```

The script may run before the heading is parsed.

Solutions:

```html
<script
  src="./app.js"
  defer
></script>
```

or place the script before the closing body tag:

```html
<script src="./app.js"></script>
</body>
```

## Mistake 2: Incorrect selector

HTML:

```html
<button id="save-button">Save</button>
```

Correct:

```js
document.querySelector("#save-button");
```

Incorrect:

```js
document.querySelector("#saveButton");
```

## Mistake 3: Calling a method on `null`

Problem:

```js
const button =
  document.querySelector("#missing-button");

button.addEventListener("click", handleClick);
```

Correction:

```js
const button =
  document.querySelector("#missing-button");

if (button === null) {
  throw new Error("Button was not found.");
}

button.addEventListener("click", handleClick);
```

## Mistake 4: Using `innerHTML` with user input

Problem:

```js
element.innerHTML =
  `<p>${userInput}</p>`;
```

Safer:

```js
const paragraph =
  document.createElement("p");

paragraph.textContent = userInput;

element.replaceChildren(paragraph);
```

## Mistake 5: Forgetting `preventDefault`

Problem:

```js
form.addEventListener(
  "submit",
  () => {
    addTask();
  }
);
```

The browser may reload after submission.

Correction:

```js
form.addEventListener(
  "submit",
  (event) => {
    event.preventDefault();
    addTask();
  }
);
```

## Mistake 6: Assuming `dataset` values are numbers

Problem:

```js
const taskId =
  taskElement.dataset.taskId;

if (taskId === 2) {
  // This is false because taskId is "2", a string.
}
```

Correction:

```js
const taskId = Number(
  taskElement.dataset.taskId
);

if (taskId === 2) {
  // Correct.
}
```

---

# C.28 DOM API Quick Reference Table

| API | Purpose |
|---|---|
| `document.querySelector()` | Selects the first matching element |
| `document.querySelectorAll()` | Selects all matching elements |
| `document.createElement()` | Creates an element in memory |
| `element.textContent` | Reads or writes text safely |
| `element.innerHTML` | Reads or writes HTML markup |
| `element.append()` | Adds nodes or text at the end |
| `element.prepend()` | Adds nodes or text at the beginning |
| `element.remove()` | Removes an element |
| `element.replaceChildren()` | Clears and replaces children |
| `element.classList.add()` | Adds a CSS class |
| `element.classList.remove()` | Removes a CSS class |
| `element.classList.toggle()` | Adds or removes a class |
| `element.classList.contains()` | Checks for a class |
| `element.setAttribute()` | Sets an attribute |
| `element.getAttribute()` | Reads an attribute |
| `element.dataset` | Reads and writes `data-*` attributes |
| `element.addEventListener()` | Registers an event handler |
| `event.preventDefault()` | Cancels default browser behavior |
| `element.closest()` | Finds the nearest matching ancestor |
| `element.matches()` | Checks whether an element matches a selector |
| `element.focus()` | Moves keyboard focus to an element |
| `form.reset()` | Resets form controls |

---

# Appendix C Completion Checklist

You should now be able to:

- Explain what the DOM represents.
- Select elements by ID, class, tag, and attribute.
- Select multiple elements.
- Read and write text.
- Explain why `textContent` is safer for user input.
- Create elements.
- Append and remove elements.
- Clear a container with `replaceChildren`.
- Add, remove, and toggle classes.
- Read and write attributes.
- Use `dataset`.
- Read and validate form values.
- Listen for clicks and submissions.
- Prevent default form behavior.
- Explain event bubbling.
- Use event delegation.
- Find ancestors with `closest`.
- Inspect DOM changes in Developer Tools.
