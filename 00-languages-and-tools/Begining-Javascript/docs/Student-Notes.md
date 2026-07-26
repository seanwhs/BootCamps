# Beginning JavaScript: Foundations & Interactive Web

## Student Notes

These notes summarize the core ideas from the series.

Use them while:

- Watching or reading the lessons.
- Building the task application.
- Reviewing before exercises.
- Debugging unfamiliar code.
- Preparing for the next part.

---

# How to Use These Notes

For each topic:

1. Read the concept.
2. Copy the example.
3. Predict the output.
4. Run the code.
5. Record anything unexpected.
6. Explain the concept in your own words.

Useful learning cycle:

```text
Read
  ↓
Predict
  ↓
Code
  ↓
Run
  ↓
Observe
  ↓
Explain
```

---

# 1. How the Web Works

A web application usually combines three technologies:

```text
HTML       → structure
CSS        → presentation
JavaScript → behavior
```

The browser:

1. Requests files.
2. Reads HTML.
3. Loads CSS.
4. Loads JavaScript.
5. Builds the DOM.
6. Displays the page.
7. Responds to user interaction.

## HTML

HTML defines the page structure.

```html
<h1>Task List</h1>

<p>Learn JavaScript.</p>

<button type="button">
  Add task
</button>
```

## CSS

CSS controls appearance.

```css
button {
  padding: 0.75rem 1rem;
  color: white;
  background: black;
}
```

## JavaScript

JavaScript controls behavior.

```js
const buttonElement =
  document.querySelector("button");

buttonElement.addEventListener(
  "click",
  () => {
    console.log("Button clicked.");
  }
);
```

## Browser Runtime

The browser provides JavaScript and Web APIs.

JavaScript language features:

```js
const total = 4 + 6;
```

Browser APIs:

```js
document.querySelector("#task-list");
localStorage.setItem("theme", "dark");
fetch("/api/tasks");
```

---

# 2. The DOM

The DOM is the browser’s JavaScript representation of an HTML document.

HTML:

```html
<ul id="task-list">
  <li>Learn JavaScript</li>
</ul>
```

Conceptual DOM:

```text
document
└── ul#task-list
    └── li
        └── "Learn JavaScript"
```

JavaScript can:

- Find DOM elements.
- Change text.
- Add classes.
- Create elements.
- Remove elements.
- Listen for events.

```js
const taskListElement =
  document.querySelector("#task-list");

taskListElement.textContent =
  "Updated task list.";
```

---

# 3. The Programming Mental Model

A program is an ordered set of instructions.

```js
const firstNumber = 4;
const secondNumber = 6;
const total = firstNumber + secondNumber;

console.log(total);
```

The program:

1. Creates `firstNumber`.
2. Creates `secondNumber`.
3. Calculates `total`.
4. Prints `total`.

## Input, Processing, Output

Most applications follow this pattern:

```text
Input
  ↓
Processing
  ↓
Output
```

For a task application:

```text
Input:
user enters a title

Processing:
trim and validate the title

Output:
display the task
```

## Application Flow

```text
User action
  ↓
Event handler
  ↓
Read input
  ↓
Validate input
  ↓
Update state
  ↓
Render interface
```

---

# 4. Variables and Values

A variable gives a name to a value.

```js
const taskTitle = "Learn JavaScript";
```

Conceptually:

```text
taskTitle ───> "Learn JavaScript"
```

## `const`

Use `const` when the variable binding will not be reassigned.

```js
const applicationName = "Task List";
```

This is invalid:

```js
const applicationName = "Task List";

applicationName = "Another App";
```

## `let`

Use `let` when reassignment is needed.

```js
let completedCount = 0;

completedCount += 1;
```

## `var`

`var` is older syntax.

```js
var oldVariable = "legacy";
```

Modern rule:

```text
Use const by default.
Use let when reassignment is required.
Avoid var in new code.
```

---

# 5. JavaScript Data Types

## String

Text:

```js
const title = "Learn JavaScript";
```

## Number

Integers and decimals:

```js
const count = 10;
const price = 19.99;
```

## Boolean

True or false:

```js
const isCompleted = false;
```

## `undefined`

A variable without an assigned value:

```js
let note;

console.log(note);
```

Result:

```text
undefined
```

## `null`

An intentional empty value:

```js
const selectedTask = null;
```

## Checking Types

```js
typeof "text";       // "string"
typeof 42;           // "number"
typeof true;         // "boolean"
typeof undefined;    // "undefined"
```

Check arrays with:

```js
Array.isArray(value);
```

Historical behavior:

```js
typeof null; // "object"
```

Check `null` directly:

```js
if (selectedTask === null) {
  console.log("No task selected.");
}
```

---

# 6. Strings

## String Methods

```js
const rawTitle = "  Learn JavaScript  ";

const cleanTitle = rawTitle.trim();

console.log(cleanTitle);
```

Result:

```text
Learn JavaScript
```

Other useful methods:

```js
title.toUpperCase();
title.toLowerCase();
title.includes("JavaScript");
title.startsWith("Learn");
title.endsWith("Script");
title.slice(0, 4);
```

## String Length

```js
const title = "JavaScript";

console.log(title.length);
```

## Template Literals

Template literals use backticks:

```js
const name = "Amina";
const lessonNumber = 1;

const message =
  `Hello, ${name}. Lesson ${lessonNumber}.`;
```

Expressions can be evaluated:

```js
const total = 4 + 6;

console.log(`Total: ${total}`);
```

---

# 7. Numbers and Operators

## Arithmetic

```js
const addition = 10 + 5;
const subtraction = 10 - 5;
const multiplication = 10 * 5;
const division = 10 / 5;
const remainder = 10 % 3;
```

Results:

```text
addition       → 15
subtraction    → 5
multiplication → 50
division       → 2
remainder      → 1
```

## Assignment Operators

```js
let score = 10;

score += 5;
score -= 2;
score *= 2;
score /= 2;
```

## Comparisons

```js
10 === 10; // true
10 === "10"; // false
10 !== 5; // true
10 > 5; // true
10 < 5; // false
10 >= 10; // true
10 <= 10; // true
```

Prefer strict equality:

```js
===
!==
```

---

# 8. Logical Operators

## AND: `&&`

Both conditions must be true.

```js
const isLoggedIn = true;
const hasPermission = true;

const canEdit =
  isLoggedIn && hasPermission;
```

## OR: `||`

At least one condition must be true.

```js
const isAdmin = false;
const isOwner = true;

const canDelete =
  isAdmin || isOwner;
```

## NOT: `!`

Reverses a boolean.

```js
const isCompleted = false;
const isIncomplete = !isCompleted;
```

## Nullish Coalescing: `??`

Uses a fallback only for `null` or `undefined`.

```js
const savedTitle = null;

const title =
  savedTitle ?? "Untitled task";
```

---

# 9. Conditions

## `if`

```js
if (task.completed) {
  console.log("Task is complete.");
}
```

## `if...else`

```js
if (task.completed) {
  console.log("Complete.");
} else {
  console.log("Incomplete.");
}
```

## `else if`

```js
if (score >= 90) {
  console.log("Excellent.");
} else if (score >= 70) {
  console.log("Good.");
} else {
  console.log("Keep practicing.");
}
```

## Ternary Operator

```js
const label = task.completed
  ? "Complete"
  : "Incomplete";
```

Use ternaries for short choices. Use `if` statements for complex logic.

---

# 10. `switch`

Use `switch` when comparing one value against several exact choices.

```js
const filter = "completed";
let message;

switch (filter) {
  case "all":
    message = "Showing all tasks.";
    break;

  case "active":
    message = "Showing active tasks.";
    break;

  case "completed":
    message = "Showing completed tasks.";
    break;

  default:
    message = "Unknown filter.";
    break;
}
```

Remember:

```text
case  → possible value
break → stop this case
default → fallback
```

---

# 11. Loops

## `for`

Use when managing an index or repeating a known number of times.

```js
for (
  let index = 0;
  index < 3;
  index += 1
) {
  console.log(index);
}
```

## `while`

Use while a condition remains true.

```js
let count = 3;

while (count > 0) {
  console.log(count);
  count -= 1;
}
```

The condition must eventually become false.

## `for...of`

Use to process each value in a collection.

```js
const topics = [
  "variables",
  "functions",
  "arrays"
];

for (const topic of topics) {
  console.log(topic);
}
```

---

# 12. Primitive and Reference Values

## Primitive Copy

Primitive values are copied independently.

```js
let firstCount = 1;
let secondCount = firstCount;

secondCount = 2;

console.log(firstCount);
console.log(secondCount);
```

Result:

```text
1
2
```

## Reference Copy

Objects and arrays are reference values.

```js
const firstTask = {
  completed: false
};

const secondTask = firstTask;

secondTask.completed = true;

console.log(firstTask.completed);
```

Result:

```text
true
```

Both variables refer to the same object.

## Shallow Copy

Use spread syntax for a new outer object:

```js
const updatedTask = {
  ...firstTask,
  completed: true
};
```

For arrays:

```js
const copiedTasks = [
  ...tasks
];
```

---

# 13. Functions

A function is a reusable group of instructions.

```js
function greetUser(name) {
  return `Hello, ${name}!`;
}

const greeting =
  greetUser("Amina");
```

## Parameters and Arguments

```js
function add(firstNumber, secondNumber) {
  return firstNumber + secondNumber;
}

add(4, 6);
```

```text
firstNumber and secondNumber → parameters
4 and 6                    → arguments
```

## Default Parameters

```js
function greetUser(
  name = "Guest"
) {
  return `Hello, ${name}!`;
}
```

## Return Values

```js
function calculateTotal(price, quantity) {
  return price * quantity;
}

const total =
  calculateTotal(10, 3);
```

`return` sends a value back to the caller.

## Early Return

```js
function validateTitle(title) {
  if (typeof title !== "string") {
    return false;
  }

  if (title.trim().length === 0) {
    return false;
  }

  return true;
}
```

---

# 14. Function Expressions and Arrow Functions

## Function Expression

```js
const multiply = function (
  firstNumber,
  secondNumber
) {
  return firstNumber * secondNumber;
};
```

## Arrow Function

```js
const multiply = (
  firstNumber,
  secondNumber
) => {
  return firstNumber * secondNumber;
};
```

## Implicit Return

```js
const double =
  (number) => number * 2;
```

This is equivalent to:

```js
const double = (number) => {
  return number * 2;
};
```

When using braces, write `return` explicitly.

---

# 15. Scope

Scope determines where a variable can be accessed.

## Global or Outer Scope

```js
const applicationName = "Task List";

function getName() {
  return applicationName;
}
```

## Function Scope

```js
function createMessage() {
  const message = "Private";

  return message;
}
```

`message` is not available outside the function.

## Block Scope

```js
if (true) {
  const message = "Inside block";
}
```

`message` is not available outside the block.

## Scope Rules

```text
Outer code can be visible to inner code.
Inner variables are not automatically visible to outer code.
let and const are block-scoped.
var is function-scoped.
```

---

# 16. Callbacks and Closures

## Callback

A callback is a function passed to another function.

```js
function applyToValue(value, operation) {
  return operation(value);
}

const result =
  applyToValue(
    5,
    (number) => number * 2
  );
```

## Closure

A closure is a function that remembers variables from its surrounding scope.

```js
function createCounter(start = 0) {
  let count = start;

  return function increase() {
    count += 1;
    return count;
  };
}

const counter =
  createCounter();

counter(); // 1
counter(); // 2
```

The returned function retains access to `count`.

---

# 17. Arrays

An array is an ordered collection.

```js
const topics = [
  "variables",
  "functions",
  "arrays"
];
```

## Indexing

```js
topics[0]; // "variables"
topics[1]; // "functions"
```

Arrays begin at index `0`.

## Length

```js
topics.length;
```

The last index is:

```js
topics.length - 1;
```

## Add and Remove

```js
topics.push("objects");
topics.pop();
topics.unshift("introduction");
topics.shift();
```

## Slice

```js
const selectedTopics =
  topics.slice(0, 2);
```

The starting index is included. The ending index is excluded.

## Index Of

```js
const index =
  topics.indexOf("functions");
```

If not found:

```text
-1
```

---

# 18. Modern Array Methods

## `forEach`

Runs code for every item.

```js
tasks.forEach((task) => {
  console.log(task.title);
});
```

## `map`

Creates a new transformed array.

```js
const titles = tasks.map(
  (task) => task.title
);
```

## `filter`

Creates a new array containing matching items.

```js
const completedTasks =
  tasks.filter(
    (task) => task.completed
  );
```

## `find`

Returns the first matching object.

```js
const task =
  tasks.find(
    (item) => item.id === 2
  );
```

If not found:

```text
undefined
```

## `findIndex`

Returns the first matching index.

```js
const index =
  tasks.findIndex(
    (item) => item.id === 2
  );
```

If not found:

```text
-1
```

## `some`

Returns `true` if at least one item matches.

```js
const hasCompleted =
  tasks.some(
    (task) => task.completed
  );
```

## `every`

Returns `true` if all items match.

```js
const allHaveTitles =
  tasks.every(
    (task) => task.title.length > 0
  );
```

## `reduce`

Combines an array into one result.

```js
const total =
  numbers.reduce(
    (runningTotal, number) => {
      return runningTotal + number;
    },
    0
  );
```

---

# 19. Objects

An object stores named properties.

```js
const task = {
  id: 1,
  title: "Learn objects",
  completed: false
};
```

## Dot Notation

```js
task.title;
task.completed;
```

## Bracket Notation

```js
task["title"];
task["completed"];
```

## Dynamic Access

```js
const propertyName = "title";

task[propertyName];
```

## Update Properties

```js
task.completed = true;
```

## Add Properties

```js
task.priority = "high";
```

## Dynamic Keys

```js
const category = "work";

const task = {
  title: "Study",
  [category]: true
};
```

Result:

```js
{
  title: "Study",
  work: true
}
```

---

# 20. Task Data Model

The application uses an array of task objects.

```js
const tasks = [
  {
    id: 1,
    title: "Learn JavaScript",
    completed: false
  }
];
```

Each task should have a consistent shape:

```text
id        → non-negative safe integer
title     → non-empty string
completed → boolean
```

Create tasks through a function:

```js
function createTask(title, id) {
  const cleanedTitle = title.trim();

  if (cleanedTitle.length === 0) {
    throw new Error(
      "Task title cannot be empty."
    );
  }

  return {
    id,
    title: cleanedTitle,
    completed: false
  };
}
```

---

# 21. DOM Selection

## Select One Element

```js
const headingElement =
  document.querySelector("h1");
```

By ID:

```js
document.querySelector("#task-list");
```

By class:

```js
document.querySelector(".task-item");
```

By attribute:

```js
document.querySelector(
  "button[type='submit']"
);
```

If no match exists:

```js
null
```

Always validate required elements:

```js
if (headingElement === null) {
  throw new Error(
    "Heading was not found."
  );
}
```

## Select Multiple Elements

```js
const buttons =
  document.querySelectorAll("button");

for (const button of buttons) {
  console.log(button.textContent);
}
```

---

# 22. DOM Text and Elements

## Read and Write Text

```js
messageElement.textContent =
  "Task added.";
```

Use `textContent` for user-provided values.

## Create an Element

```js
const itemElement =
  document.createElement("li");
```

## Append

```js
itemElement.textContent =
  "Learn the DOM";

taskListElement.append(itemElement);
```

## Remove

```js
itemElement.remove();
```

## Clear Children

```js
taskListElement.replaceChildren();
```

## Safe Rendering

```js
titleElement.textContent =
  task.title;
```

Avoid:

```js
titleElement.innerHTML =
  task.title;
```

when `task.title` contains user input.

---

# 23. Classes and Attributes

## Add a Class

```js
element.classList.add(
  "task-item--completed"
);
```

## Remove a Class

```js
element.classList.remove(
  "task-item--completed"
);
```

## Toggle a Class

```js
element.classList.toggle(
  "task-item--completed",
  task.completed
);
```

## Check a Class

```js
element.classList.contains(
  "task-item--completed"
);
```

## Attributes

```js
button.setAttribute(
  "aria-label",
  "Remove task"
);
```

## Data Attributes

HTML:

```html
<li data-task-id="42"></li>
```

JavaScript:

```js
const taskIdText =
  element.dataset.taskId;

const taskId =
  Number(taskIdText);
```

`dataset` values are strings.

---

# 24. Events

Register an event listener:

```js
buttonElement.addEventListener(
  "click",
  () => {
    console.log("Clicked.");
  }
);
```

Common events:

```text
click
submit
input
change
keydown
focus
blur
```

## Event Object

```js
buttonElement.addEventListener(
  "click",
  (event) => {
    console.log(event.type);
    console.log(event.target);
    console.log(event.currentTarget);
  }
);
```

## Form Submission

```js
formElement.addEventListener(
  "submit",
  (event) => {
    event.preventDefault();

    console.log("Submitted.");
  }
);
```

`preventDefault()` stops the browser’s normal form submission.

---

# 25. Event Bubbling and Delegation

Events travel upward:

```text
button
  ↑
li
  ↑
ul
  ↑
body
```

Event delegation uses a parent listener:

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

    const action =
      button.dataset.action;

    console.log(action);
  }
);
```

Delegation works well for dynamically created task buttons.

---

# 26. Rendering

Rendering converts application state into visible HTML.

State:

```js
const task = {
  id: 1,
  title: "Learn rendering",
  completed: false
};
```

Rendering:

```js
function createTaskElement(task) {
  const itemElement =
    document.createElement("li");

  itemElement.textContent =
    task.title;

  return itemElement;
}
```

Render a collection:

```js
function renderTasks(tasks) {
  taskListElement.replaceChildren();

  for (const task of tasks) {
    taskListElement.append(
      createTaskElement(task)
    );
  }
}
```

The array is the source of truth:

```text
tasks array
  ↓
renderTasks(tasks)
  ↓
DOM
```

---

# 27. Forms and Validation

Read an input:

```js
const rawTitle =
  taskTitleInputElement.value;
```

Clean it:

```js
const title =
  rawTitle.trim();
```

Validate it:

```js
if (title.length === 0) {
  showFormMessage(
    "Enter a task title.",
    "error"
  );

  return;
}
```

Limit length:

```js
if (title.length > 120) {
  showFormMessage(
    "Title is too long.",
    "error"
  );

  return;
}
```

Reset the form:

```js
taskFormElement.reset();
```

Focus the input:

```js
taskTitleInputElement.focus();
```

---

# 28. Accessibility Notes

## Use Semantic HTML

Prefer:

```html
<button type="button">
  Remove
</button>
```

Avoid using a generic `<div>` as a button.

## Label Inputs

```html
<label for="task-title">
  Task title
</label>

<input id="task-title" />
```

## Provide Focus Styles

```css
button:focus-visible,
input:focus-visible {
  outline: 3px solid black;
  outline-offset: 3px;
}
```

## Announce Status

```html
<p
  role="status"
  aria-live="polite"
  id="form-message"
></p>
```

## Describe Errors

```html
<input
  id="task-title"
  aria-describedby="form-message"
/>
```

## Do Not Use Color Alone

Bad:

```text
Green means complete.
Red means incomplete.
```

Better:

```text
Complete
Incomplete
```

Use color as an additional visual signal, not the only signal.

---

# 29. Security Notes

Treat user input as untrusted data.

Safe:

```js
titleElement.textContent =
  userProvidedTitle;
```

Risky:

```js
titleElement.innerHTML =
  userProvidedTitle;
```

Avoid:

```js
eval(userInput);
new Function(userInput);
```

Validate IDs:

```js
const taskId =
  Number(element.dataset.taskId);

if (!Number.isSafeInteger(taskId)) {
  throw new Error(
    "Invalid task ID."
  );
}
```

Client-side validation improves the user experience. A future server must validate data again.

---

# 30. Debugging

## Syntax Error

The browser cannot parse the code.

Example:

```js
const message = "Hello;
```

## Runtime Error

The code starts but fails while running.

Example:

```js
const task = null;

console.log(task.title);
```

## Logic Error

The code runs but produces the wrong result.

Example:

```js
const completedTasks =
  tasks.filter(
    (task) => !task.completed
  );
```

This selects incomplete tasks instead of completed tasks.

## Debugging Process

```text
Read the first error
  ↓
Open the referenced file
  ↓
Inspect the line
  ↓
Log relevant values
  ↓
Form one hypothesis
  ↓
Make one fix
  ↓
Run verification
```

## Useful Tools

```js
console.log(value);
console.table(tasks);
console.error(error);
console.assert(condition, message);
```

Use breakpoints in Developer Tools to pause execution.

---

# 31. Naming and Style

## Variables

Use descriptive `camelCase` names:

```js
const taskTitle = "Read";
const completedTaskCount = 2;
```

## Functions

Use action-oriented names:

```js
createTask();
renderTasks();
removeTask();
validateTitle();
```

## Booleans

Use question-like names:

```js
const isCompleted = false;
const hasTasks = true;
const canSubmit = false;
const shouldRender = true;
```

## DOM Elements

Use an `Element` suffix:

```js
const taskFormElement =
  document.querySelector("#task-form");

const taskListElement =
  document.querySelector("#task-list");
```

## Constants

Name important fixed values:

```js
const maximumTaskTitleLength = 120;
```

## Comments

Explain why:

```js
/*
  Use textContent so user-entered text
  is not interpreted as HTML.
*/
titleElement.textContent =
  task.title;
```

---

# 32. Development Workflow

Use this loop:

```text
Plan
  ↓
Edit
  ↓
Save
  ↓
Refresh
  ↓
Observe
  ↓
Debug
  ↓
Verify
```

Make small changes.

Good progression:

```text
Add HTML element
  ↓
Verify it appears
  ↓
Select it
  ↓
Verify selection
  ↓
Add event listener
  ↓
Verify event
  ↓
Update state
  ↓
Verify data
  ↓
Render result
```

Do not build on an unverified step.

---

# 33. Final Application Architecture

```text
index.html
  ├── Form
  ├── Input
  ├── Status message
  └── Task list

styles.css
  ├── Layout
  ├── Task styles
  ├── Completed state
  └── Focus styles

src/app.js
  ├── DOM references
  ├── Application state
  ├── Validation
  ├── Task creation
  ├── Rendering
  ├── Form events
  └── Task events
```

Application flow:

```text
Submit form
  ↓
Prevent default
  ↓
Read title
  ↓
Trim title
  ↓
Validate title
  ↓
Create task
  ↓
Push task into array
  ↓
Render task list
  ↓
Reset form
  ↓
Show status
```

Task action flow:

```text
Click Complete
  ↓
Find task ID
  ↓
Find task object
  ↓
Toggle completed
  ↓
Render task list
  ↓
Show status
```

Remove flow:

```text
Click Remove
  ↓
Find task ID
  ↓
Find array index
  ↓
Splice task
  ↓
Render task list
  ↓
Update count
  ↓
Show empty state if needed
```

---

# 34. Final Review Questions

## Foundations

1. What is a variable?
2. What is the difference between `const` and `let`?
3. What is a primitive value?
4. What is a reference value?
5. Why should strict equality usually be preferred?

Notes:

```text
____________________________________________________

____________________________________________________
```

## Functions

1. What is a parameter?
2. What is an argument?
3. What does `return` do?
4. What is a callback?
5. What is a closure?

Notes:

```text
____________________________________________________

____________________________________________________
```

## Data Structures

1. Why do arrays begin at index `0`?
2. What does `push` do?
3. What does `slice` do?
4. What does `find` return?
5. Why are arrays of objects useful?

Notes:

```text
____________________________________________________

____________________________________________________
```

## DOM and Events

1. What does `querySelector` do?
2. Why use `textContent`?
3. What does `preventDefault` do?
4. What is event bubbling?
5. What is event delegation?

Notes:

```text
____________________________________________________

____________________________________________________
```

---

# 35. Final Checklist

- [ ] I understand the browser development environment.
- [ ] I can explain HTML, CSS, and JavaScript.
- [ ] I can create variables.
- [ ] I understand common data types.
- [ ] I can use conditions.
- [ ] I can use loops.
- [ ] I can create functions.
- [ ] I understand scope.
- [ ] I can use arrays.
- [ ] I can use objects.
- [ ] I can store objects in arrays.
- [ ] I can select DOM elements.
- [ ] I can change DOM text.
- [ ] I can create DOM elements.
- [ ] I can manage CSS classes.
- [ ] I can listen for events.
- [ ] I can handle forms.
- [ ] I can render application state.
- [ ] I can validate user input.
- [ ] I can safely render user text.
- [ ] I can debug common errors.
- [ ] I can build the task application.

---

# Personal Notes

## Concepts I Understand Well

```text
____________________________________________________

____________________________________________________

____________________________________________________
```

## Concepts I Need to Practice

```text
____________________________________________________

____________________________________________________

____________________________________________________
```

## Questions I Still Have

```text
____________________________________________________

____________________________________________________

____________________________________________________
```

## Feature I Want to Build Next

```text
____________________________________________________

____________________________________________________
```

## Final Reflection

What can you now build with JavaScript?

```text
____________________________________________________

____________________________________________________

____________________________________________________

____________________________________________________
```
