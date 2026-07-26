# Appendix H: JavaScript and Web Development Glossary

This glossary defines important terms used throughout the series in beginner-friendly language.

Each definition includes a small example where useful.

---

## H.1 Argument

An **argument** is the actual value passed to a function when it is called.

```js
function greetUser(name) {
  return `Hello, ${name}!`;
}

greetUser("Amina");
```

Here:

- `name` is the parameter.
- `"Amina"` is the argument.

---

## H.2 Array

An **array** is an ordered collection of values.

```js
const topics = [
  "variables",
  "functions",
  "arrays"
];
```

Array positions begin at index `0`:

```js
topics[0]; // "variables"
topics[1]; // "functions"
```

---

## H.3 Attribute

An **attribute** provides additional information about an HTML element.

```html
<input
  id="task-title"
  type="text"
  required
/>
```

Examples include:

- `id`
- `class`
- `type`
- `href`
- `src`
- `aria-label`
- `data-task-id`

JavaScript can read and update attributes:

```js
element.setAttribute(
  "aria-label",
  "Remove task"
);
```

---

## H.4 Boolean

A **boolean** is a value with only two possible states:

```js
true
false
```

Example:

```js
const isCompleted = false;
```

Booleans are commonly used in conditions:

```js
if (isCompleted) {
  console.log("Task is complete.");
}
```

---

## H.5 Browser

A **browser** is software that displays and runs web content.

Examples include:

- Chrome.
- Firefox.
- Edge.
- Safari.

A browser:

1. Loads HTML.
2. Parses CSS.
3. Executes JavaScript.
4. Builds the DOM.
5. Displays the resulting interface.

---

## H.6 Callback

A **callback** is a function passed to another function.

```js
function applyToValue(value, operation) {
  return operation(value);
}

const result = applyToValue(
  5,
  (number) => number * 2
);
```

The arrow function is the callback.

Callbacks are common in:

- Array methods.
- Event listeners.
- Timers.
- Asynchronous operations.

---

## H.7 Class

The word **class** has two common meanings in web development.

### CSS class

A CSS class labels an HTML element:

```html
<li class="task-item"></li>
```

JavaScript can manage it:

```js
element.classList.add("task-item--completed");
```

### JavaScript class

A JavaScript `class` is a syntax for creating object-oriented structures:

```js
class Task {
  constructor(title) {
    this.title = title;
    this.completed = false;
  }
}
```

The tutorial primarily uses CSS classes and object literals rather than JavaScript classes.

---

## H.8 Client-Side

**Client-side** code runs in the user’s browser.

Examples:

- Updating the DOM.
- Handling button clicks.
- Validating form input for user feedback.
- Reading `localStorage`.

Client-side validation improves usability but should not be the only validation in a server-backed application.

---

## H.9 Closure

A **closure** occurs when a function retains access to variables from its surrounding scope.

```js
function createCounter() {
  let count = 0;

  return function increase() {
    count += 1;
    return count;
  };
}

const counter = createCounter();

counter(); // 1
counter(); // 2
```

The returned function remembers `count`.

---

## H.10 Console

The **console** is a browser Developer Tools panel used to:

- Inspect values.
- View logs.
- Read errors.
- Test expressions.

Example:

```js
console.log("Application started.");
```

You can also inspect objects:

```js
console.log({
  taskCount: tasks.length,
  tasks
});
```

---

## H.11 Constructor

A **constructor** is a function or class operation used to create a new object.

With a JavaScript class:

```js
class Task {
  constructor(title) {
    this.title = title;
  }
}
```

The constructor runs when creating an object:

```js
const task = new Task("Read");
```

Built-in constructors include:

```js
new Date();
new URL("https://example.com");
```

---

## H.12 Cookie

A **cookie** is a small piece of data stored by the browser and associated with a website.

Cookies can be used for:

- Session identifiers.
- Preferences.
- Analytics.
- Authentication-related state.

Cookies have security and privacy considerations. The current task application uses `localStorage` instead.

---

## H.13 CSS

CSS stands for **Cascading Style Sheets**.

CSS controls the visual presentation of HTML:

- Colors.
- Fonts.
- Spacing.
- Layout.
- Borders.
- Responsive behavior.
- Focus styles.

Example:

```css
.task-item--completed {
  text-decoration: line-through;
}
```

---

## H.14 Data Attribute

A **data attribute** is a custom HTML attribute beginning with `data-`.

```html
<li data-task-id="42"></li>
```

JavaScript reads it through `dataset`:

```js
const taskId = element.dataset.taskId;
```

Data attribute values are strings, even when they contain numbers.

---

## H.15 Data Structure

A **data structure** is a way to organize information.

Examples:

- Array.
- Object.
- Map.
- Set.
- Queue.
- Stack.

The task application uses an array of objects:

```js
const tasks = [
  {
    id: 1,
    title: "Learn JavaScript",
    completed: false
  }
];
```

---

## H.16 Declaration

A **declaration** introduces a variable or function.

Variable declarations:

```js
const taskTitle = "Read";
let taskCount = 0;
```

Function declaration:

```js
function createTask(title) {
  return {
    title,
    completed: false
  };
}
```

---

## H.17 DOM

DOM stands for **Document Object Model**.

It is the browser’s object representation of an HTML document.

HTML:

```html
<h1 id="heading">Task List</h1>
```

JavaScript:

```js
const headingElement =
  document.querySelector("#heading");
```

The browser turns the HTML element into an object that JavaScript can inspect and modify.

---

## H.18 Element

An **element** is an HTML object represented in the DOM.

Examples:

```html
<h1>Heading</h1>
<p>Paragraph</p>
<button>Click</button>
```

JavaScript can create an element:

```js
const itemElement =
  document.createElement("li");
```

---

## H.19 Event

An **event** is something that happens in the browser.

Examples:

- User clicks a button.
- User submits a form.
- User types into an input.
- A page finishes loading.
- A key is pressed.

JavaScript listens for events:

```js
buttonElement.addEventListener(
  "click",
  () => {
    console.log("Clicked.");
  }
);
```

---

## H.20 Event Bubbling

**Event bubbling** is the process by which an event travels from its original target up through its ancestor elements.

```text
button
  ↑
li
  ↑
ul
  ↑
body
```

Event delegation depends on bubbling.

---

## H.21 Event Delegation

**Event delegation** means placing one event listener on a parent element to handle events from its children.

```js
taskListElement.addEventListener(
  "click",
  (event) => {
    if (!(event.target instanceof Element)) {
      return;
    }

    const button =
      event.target.closest("button");

    if (button === null) {
      return;
    }

    console.log("Task action clicked.");
  }
);
```

This is especially useful when child elements are created dynamically.

---

## H.22 Event Handler

An **event handler** is a function that responds to an event.

```js
function handleSubmit(event) {
  event.preventDefault();
  console.log("Form submitted.");
}

formElement.addEventListener(
  "submit",
  handleSubmit
);
```

---

## H.23 Expression

An **expression** is code that produces a value.

Examples:

```js
2 + 3
task.title
isCompleted
```

An expression can be assigned:

```js
const total = 2 + 3;
```

---

## H.24 Function

A **function** is a reusable group of instructions.

```js
function add(firstNumber, secondNumber) {
  return firstNumber + secondNumber;
}
```

Call it:

```js
const result = add(2, 3);
```

---

## H.25 Function Expression

A **function expression** creates a function as part of an assignment.

```js
const add = function (
  firstNumber,
  secondNumber
) {
  return firstNumber + secondNumber;
};
```

The function is stored in the variable `add`.

---

## H.26 Global Scope

**Global scope** is the outermost scope available to a script or environment.

```js
const applicationName = "Task List";

function getApplicationName() {
  return applicationName;
}
```

The function can read the outer variable.

Avoid putting unnecessary mutable data in global scope.

---

## H.27 Hoisting

**Hoisting** describes JavaScript’s handling of certain declarations before execution reaches their written location.

Function declarations can generally be called before their declaration:

```js
sayHello();

function sayHello() {
  console.log("Hello.");
}
```

Do not rely heavily on this behavior. Declare functions before using them for clearer code.

`let` and `const` cannot be accessed before initialization.

---

## H.28 HTML

HTML stands for **HyperText Markup Language**.

HTML defines the structure of a web page:

```html
<h1>Task List</h1>

<form>
  <label for="title">Title</label>
  <input id="title" />
</form>
```

HTML answers:

```text
What elements exist?
```

CSS answers:

```text
How do they look?
```

JavaScript answers:

```text
How do they behave?
```

---

## H.29 HTTP

HTTP stands for **HyperText Transfer Protocol**.

It describes communication between clients and servers.

A browser may send:

```text
GET /api/tasks
```

A server may respond with:

```json
[
  {
    "id": 1,
    "title": "Read",
    "completed": false
  }
]
```

Common HTTP methods include:

- `GET` — retrieve data.
- `POST` — create data.
- `PUT` — replace data.
- `PATCH` — partially update data.
- `DELETE` — remove data.

---

## H.30 Input Validation

**Input validation** checks whether data follows expected rules.

```js
function isValidTaskTitle(title) {
  return (
    typeof title === "string" &&
    title.trim().length > 0 &&
    title.length <= 120
  );
}
```

Client-side validation helps users. Server-side validation is required when a backend exists.

---

## H.31 JSON

JSON stands for **JavaScript Object Notation**.

It is a text format for structured data.

JavaScript object:

```js
const task = {
  id: 1,
  title: "Read",
  completed: false
};
```

Convert to JSON:

```js
const text = JSON.stringify(task);
```

Convert JSON back:

```js
const parsedTask = JSON.parse(text);
```

---

## H.32 Keyword

A **keyword** is a reserved word with special meaning in JavaScript.

Examples:

```js
const
let
function
return
if
else
for
while
class
import
export
```

Do not use keywords as variable names.

---

## H.33 Local Storage

`localStorage` is browser storage that persists text between page loads.

```js
localStorage.setItem(
  "theme",
  "dark"
);
```

Read the value:

```js
const theme =
  localStorage.getItem("theme");
```

Remove it:

```js
localStorage.removeItem("theme");
```

Objects must be serialized:

```js
localStorage.setItem(
  "tasks",
  JSON.stringify(tasks)
);
```

Storage is controlled by the user’s browser and should not be treated as a secure database.

---

## H.34 Loop

A **loop** repeats instructions.

### `for`

```js
for (
  let index = 0;
  index < 3;
  index += 1
) {
  console.log(index);
}
```

### `while`

```js
let count = 3;

while (count > 0) {
  console.log(count);
  count -= 1;
}
```

### `for...of`

```js
for (const task of tasks) {
  console.log(task.title);
}
```

---

## H.35 Method

A **method** is a function stored on an object.

```js
const taskTitle = "  Learn  ";

const cleanTitle = taskTitle.trim();
```

Here, `trim` is a string method.

Array methods include:

```js
tasks.push(task);
tasks.find(...);
tasks.filter(...);
```

---

## H.36 Module

A **module** is a JavaScript file with explicit imports and exports.

### Export

```js
export function createTask(title) {
  return {
    title,
    completed: false
  };
}
```

### Import

```js
import {
  createTask
} from "./tasks.js";
```

Load a module in HTML:

```html
<script
  type="module"
  src="./src/app.js"
></script>
```

Modules help divide large applications into focused files.

---

## H.37 Mutation

**Mutation** means changing an existing object or array.

```js
task.completed = true;
tasks.push(task);
```

An alternative is to create new values:

```js
const updatedTask = {
  ...task,
  completed: true
};
```

Both approaches are valid when used deliberately.

---

## H.38 Node

A **node** is a general object in the DOM tree.

Elements are nodes, but other node types also exist:

- Text nodes.
- Comment nodes.
- Document nodes.

For most beginner DOM work, you will mainly interact with element nodes.

---

## H.39 Object

An **object** stores named properties.

```js
const task = {
  id: 1,
  title: "Learn objects",
  completed: false
};
```

Read a property:

```js
task.title;
```

Update a property:

```js
task.completed = true;
```

---

## H.40 Parameter

A **parameter** is a named input in a function definition.

```js
function greetUser(name) {
  return `Hello, ${name}!`;
}
```

Here, `name` is a parameter.

---

## H.41 Primitive

A **primitive** is a basic JavaScript value.

Common primitives include:

```js
"string"
42
true
undefined
null
```

Primitive values behave differently from objects and arrays when copied.

---

## H.42 Reference

A **reference** is a connection to an object or array in memory.

```js
const firstTask = {
  title: "Read"
};

const secondTask = firstTask;

secondTask.title = "Write";

console.log(firstTask.title);
```

Output:

```text
Write
```

Both variables refer to the same object.

---

## H.43 Render

To **render** means to convert application data into visible interface output.

```js
function renderTasks(tasks) {
  taskListElement.replaceChildren();

  for (const task of tasks) {
    const itemElement =
      document.createElement("li");

    itemElement.textContent = task.title;
    taskListElement.append(itemElement);
  }
}
```

The function renders task data into the DOM.

---

## H.44 Scope

**Scope** determines where a variable can be accessed.

```js
function createMessage() {
  const message = "Private value";

  return message;
}
```

`message` exists inside the function but not outside it.

---

## H.45 Script

A **script** is JavaScript code executed by the browser.

HTML loads a script:

```html
<script
  src="./src/app.js"
  defer
></script>
```

A script can also be inline:

```html
<script>
  console.log("Inline script");
</script>
```

External scripts are generally easier to maintain.

---

## H.46 Semantic HTML

**Semantic HTML** uses elements according to their meaning.

Examples:

```html
<header></header>
<main></main>
<section></section>
<nav></nav>
<footer></footer>
<button></button>
<form></form>
```

Semantic elements improve:

- Accessibility.
- Maintainability.
- Search engine understanding.
- Browser behavior.

---

## H.47 Server-Side

**Server-side** code runs on a server rather than in the browser.

A server may:

- Validate requests.
- Authenticate users.
- Store data in a database.
- Return API responses.
- Enforce authorization.

The browser should not be trusted as the only security boundary.

---

## H.48 State

**State** is the data representing an application’s current condition.

For the task application:

```js
const tasks = [
  {
    id: 1,
    title: "Learn state",
    completed: false
  }
];
```

State changes when:

- A task is added.
- A task is completed.
- A task is removed.
- A task is edited.

The DOM should reflect the current state.

---

## H.49 Strict Mode

Strict mode is a JavaScript execution mode that catches certain unsafe patterns.

```js
"use strict";
```

It helps prevent accidental globals and changes some older language behaviors.

---

## H.50 Ternary Operator

The ternary operator is a compact conditional expression.

```js
const label = task.completed
  ? "Complete"
  : "Incomplete";
```

It consists of:

```text
condition ? valueIfTrue : valueIfFalse
```

Use it for short choices. Use `if` statements when logic becomes complex.

---

## H.51 Type

A **type** describes the kind of value.

```js
typeof "hello"; // "string"
typeof 42;      // "number"
typeof true;    // "boolean"
```

Arrays require:

```js
Array.isArray(value);
```

Types matter because operations depend on the value’s type.

---

## H.52 User Input

**User input** is data supplied by a user through an interface.

Examples:

- Text entered into an input.
- A selected option.
- A checked checkbox.
- A file chosen through an upload control.

Treat user input as untrusted data:

```js
const title =
  taskTitleInputElement.value.trim();
```

Validate it before use and render it safely.

---

## H.53 Validation

**Validation** determines whether data meets defined rules.

Example:

```js
function validateTaskTitle(title) {
  if (typeof title !== "string") {
    return false;
  }

  const cleanedTitle = title.trim();

  return (
    cleanedTitle.length > 0 &&
    cleanedTitle.length <= 120
  );
}
```

---

## H.54 Variable

A **variable** is a named reference to a value.

```js
const taskTitle = "Learn JavaScript";
```

Variables allow code to refer to information by name.

---

## H.55 Event Target

`event.target` is the element where the event originally occurred.

```js
listElement.addEventListener(
  "click",
  (event) => {
    console.log(event.target);
  }
);
```

If a button inside the list is clicked, the target is usually the button.

---

## H.56 Event Current Target

`event.currentTarget` is the element whose listener is currently executing.

```js
listElement.addEventListener(
  "click",
  (event) => {
    console.log(event.currentTarget);
  }
);
```

In this example, `currentTarget` is the list, even when the clicked target is a button inside it.

---

## H.57 `preventDefault`

`preventDefault()` cancels the browser’s default action for an event.

```js
formElement.addEventListener(
  "submit",
  (event) => {
    event.preventDefault();
  }
);
```

It does not stop the event from bubbling. To stop propagation, use `stopPropagation()` carefully.

---

## H.58 `textContent`

`textContent` reads or writes plain text.

```js
messageElement.textContent =
  "Task added.";
```

It does not interpret the value as HTML, making it the preferred method for displaying user-entered text.

---

## H.59 `innerHTML`

`innerHTML` reads or writes HTML markup.

```js
element.innerHTML =
  "<strong>Trusted content</strong>";
```

Do not insert untrusted user input directly with `innerHTML`.

---

## H.60 Cross-Site Scripting

**Cross-site scripting**, commonly called XSS, occurs when an attacker causes a web application to execute unwanted code in another user’s browser.

Risky pattern:

```js
element.innerHTML =
  `<p>${userInput}</p>`;
```

Safer pattern:

```js
const paragraphElement =
  document.createElement("p");

paragraphElement.textContent = userInput;

element.append(paragraphElement);
```

---

# H.61 Glossary Quick Reference

| Term | Meaning |
|---|---|
| Argument | Actual value passed to a function |
| Array | Ordered collection of values |
| Attribute | Extra information on an HTML element |
| Boolean | `true` or `false` value |
| Callback | Function passed to another function |
| Closure | Function retaining access to outer variables |
| CSS | Language controlling visual presentation |
| DOM | JavaScript representation of an HTML document |
| Event | Something that happens in the browser |
| Function | Reusable group of instructions |
| JSON | Text format for structured data |
| Local storage | Browser storage for persistent text data |
| Method | Function belonging to an object |
| Module | JavaScript file with imports and exports |
| Mutation | Changing an existing object or array |
| Object | Collection of named properties |
| Parameter | Named function input |
| Primitive | Basic JavaScript value |
| Reference | Connection to an object or array |
| Render | Convert data into visible interface output |
| Scope | Area where a variable is available |
| State | Current condition of an application |
| Validation | Checking whether data follows rules |

---

# Appendix H Completion Checklist

Use this glossary to review whether you can explain:

- What an array is.
- What an object is.
- What a function parameter is.
- What a callback is.
- What the DOM represents.
- What an event is.
- What event bubbling means.
- What event delegation means.
- What state and rendering mean.
- What scope controls.
- Why user input must be validated.
- Why `textContent` is safer than unsafe `innerHTML`.
- How client-side and server-side code differ.
