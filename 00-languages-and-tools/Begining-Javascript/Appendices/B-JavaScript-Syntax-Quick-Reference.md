# Appendix B: JavaScript Syntax Quick Reference

This appendix is a lookup guide for the JavaScript syntax used throughout the series.

It is not intended to replace the explanations in Parts 1–4. Use it when you remember the concept but need to confirm the exact syntax.

The examples are complete and copy-pasteable.

---

## B.1 Comments

Comments explain code to humans. JavaScript ignores them during execution.

### Single-line comments

```js
// This is a single-line comment.

const taskCount = 3; // This comment explains the variable.
```

### Multi-line comments

```js
/*
  This is a multi-line comment.

  It can explain a larger section of code.
*/
const applicationName = "Task List";
```

Use comments to explain:

- Why code exists.
- Why a non-obvious decision was made.
- Important safety constraints.
- Architectural boundaries.

Avoid comments that merely repeat the code:

```js
// Add one to count.
count += 1;
```

A more useful comment explains a reason:

```js
/*
  IDs begin at 1 because zero is reserved for "no selection"
  in another part of the application.
*/
nextTaskId += 1;
```

---

## B.2 Strict Mode

Strict mode enables safer JavaScript behavior.

```js
"use strict";

const message = "Strict mode is enabled.";

console.log(message);
```

Place the directive at the top of a script or function.

Strict mode helps catch accidental errors such as undeclared variables:

```js
"use strict";

accidentalGlobal = "This causes an error.";
```

Expected result:

```text
ReferenceError
```

Without strict mode, older JavaScript behavior might accidentally create a global variable.

Use strict mode in traditional JavaScript scripts.

---

## B.3 Variables

A variable gives a name to a value.

### `const`

Use `const` when the variable binding will not be reassigned.

```js
const applicationName = "Task List";
const maximumTitleLength = 120;
```

This is invalid:

```js
const applicationName = "Task List";

applicationName = "Another App";
```

### `let`

Use `let` when the variable must be reassigned.

```js
let currentTaskCount = 0;

currentTaskCount += 1;
currentTaskCount += 1;

console.log(currentTaskCount);
```

Expected result:

```text
2
```

### `var`

`var` is an older declaration style.

```js
var olderVariable = "Legacy syntax";
```

Prefer:

```js
const fixedValue = "Use const";
let changingValue = "Use let";
```

### Practical rule

```text
Use const by default.
Use let when reassignment is required.
Avoid var in new code.
```

---

## B.4 Primitive Values

### String

A string represents text.

```js
const singleQuoted = 'Hello';
const doubleQuoted = "Hello";
const templateLiteral = `Hello`;
```

These all contain text.

### Number

```js
const integer = 42;
const decimal = 19.95;
const negative = -8;
```

JavaScript uses one primary `number` type for ordinary integers and decimals.

### Boolean

```js
const isVisible = true;
const isCompleted = false;
```

A boolean has only two values:

```js
true
false
```

### `undefined`

```js
let valueWithoutAssignment;

console.log(valueWithoutAssignment);
```

Expected result:

```text
undefined
```

### `null`

```js
const selectedTask = null;
```

`null` represents an intentional absence of a value.

### `NaN`

`NaN` means “Not a Number.”

```js
const invalidCalculation = Number("not a number");

console.log(invalidCalculation);
console.log(Number.isNaN(invalidCalculation));
```

Expected output:

```text
NaN
true
```

Use:

```js
Number.isNaN(value)
```

to check specifically for `NaN`.

---

## B.5 Checking Types

Use `typeof` for many primitive values:

```js
console.log(typeof "text");      // "string"
console.log(typeof 42);          // "number"
console.log(typeof true);        // "boolean"
console.log(typeof undefined);   // "undefined"
```

For `null`, JavaScript has a historical behavior:

```js
console.log(typeof null);
```

Result:

```text
"object"
```

Check `null` directly:

```js
const selectedTask = null;

if (selectedTask === null) {
  console.log("No task is selected.");
}
```

Check arrays with:

```js
Array.isArray(value)
```

Example:

```js
const tasks = [];

console.log(Array.isArray(tasks));
```

Expected result:

```text
true
```

---

## B.6 Strings

### String length

```js
const title = "Learn JavaScript";

console.log(title.length);
```

### Convert to uppercase

```js
const title = "learn javascript";

console.log(title.toUpperCase());
```

### Convert to lowercase

```js
const title = "LEARN JAVASCRIPT";

console.log(title.toLowerCase());
```

### Remove surrounding whitespace

```js
const rawTitle = "   Learn JavaScript   ";
const cleanTitle = rawTitle.trim();

console.log(cleanTitle);
```

Expected result:

```text
Learn JavaScript
```

`trim()` does not change the original string. It returns a new string.

### Check whether a string includes text

```js
const message = "JavaScript is running.";

console.log(message.includes("running"));
```

Expected result:

```text
true
```

### Check whether a string starts or ends with text

```js
const fileName = "script.js";

console.log(fileName.startsWith("script"));
console.log(fileName.endsWith(".js"));
```

### Extract part of a string with `slice`

```js
const language = "JavaScript";

const firstFourCharacters = language.slice(0, 4);

console.log(firstFourCharacters);
```

Expected result:

```text
Java
```

The starting index is included and the ending index is excluded.

### Replace text

```js
const message = "Learn HTML";

const updatedMessage = message.replace(
  "HTML",
  "JavaScript"
);

console.log(updatedMessage);
```

Expected result:

```text
Learn JavaScript
```

### Template literals

Template literals use backticks:

```js
const name = "Amina";
const lessonNumber = 4;

const message =
  `Welcome, ${name}. You are on lesson ${lessonNumber}.`;

console.log(message);
```

Expected result:

```text
Welcome, Amina. You are on lesson 4.
```

Expressions inside `${}` are evaluated:

```js
const firstNumber = 4;
const secondNumber = 6;

console.log(`Total: ${firstNumber + secondNumber}`);
```

---

## B.7 Numbers and Arithmetic

```js
const addition = 8 + 4;
const subtraction = 8 - 4;
const multiplication = 8 * 4;
const division = 8 / 4;
const remainder = 8 % 3;
```

Results:

```text
addition       → 12
subtraction    → 4
multiplication → 32
division       → 2
remainder      → 2
```

### Assignment operators

```js
let score = 10;

score += 5; // score = score + 5
score -= 2; // score = score - 2
score *= 2; // score = score * 2
score /= 2; // score = score / 2
```

### Increment and decrement

```js
let count = 0;

count += 1;
count -= 1;
```

These are generally clearer than relying on:

```js
count++;
count--;
```

The shorter forms are valid, but explicit assignment can be easier for beginners to read.

### Numeric validation

```js
const value = 42;

console.log(Number.isFinite(value));
console.log(Number.isInteger(value));
console.log(Number.isSafeInteger(value));
```

Use:

```js
Number.isFinite(value)
```

when decimals are allowed but infinite and non-numeric values are not.

Use:

```js
Number.isInteger(value)
```

when only whole numbers are valid.

Use:

```js
Number.isSafeInteger(value)
```

when an integer must be represented safely by JavaScript.

### Convert text to a number

```js
const inputValue = "42";
const numberValue = Number(inputValue);

console.log(numberValue);
console.log(typeof numberValue);
```

Expected output:

```text
42
number
```

Validate user input:

```js
const rawValue = "42";
const parsedValue = Number(rawValue);

if (!Number.isFinite(parsedValue)) {
  throw new Error("Expected a valid number.");
}
```

---

## B.8 Boolean Expressions

Comparison expressions produce booleans:

```js
const isLargeEnough = 10 >= 5;
const isSame = 10 === 10;
const isDifferent = 10 !== 5;
```

### Strict equality

```js
console.log(5 === 5);     // true
console.log(5 === "5");   // false
```

### Strict inequality

```js
console.log(5 !== 4);     // true
console.log(5 !== "5");   // true
```

Prefer strict operators:

```js
===
!==
```

Avoid loose equality unless you understand the conversion behavior:

```js
==
!=
```

---

## B.9 Logical Operators

### AND: `&&`

Both conditions must be true.

```js
const isLoggedIn = true;
const hasPermission = true;

const canEdit = isLoggedIn && hasPermission;

console.log(canEdit);
```

### OR: `||`

At least one condition must be true.

```js
const isAdmin = false;
const isOwner = true;

const canDelete = isAdmin || isOwner;

console.log(canDelete);
```

### NOT: `!`

Reverses a boolean.

```js
const isCompleted = false;
const isIncomplete = !isCompleted;

console.log(isIncomplete);
```

### Nullish coalescing: `??`

Uses a fallback only when the left side is `null` or `undefined`.

```js
const savedTitle = null;

const title = savedTitle ?? "Untitled task";

console.log(title);
```

Expected result:

```text
Untitled task
```

Unlike `||`, `??` preserves valid falsy values such as `0` and `""`.

```js
const count = 0;

console.log(count || 10); // 10
console.log(count ?? 10); // 0
```

---

## B.10 Conditional Statements

### `if`

```js
const taskTitle = "Learn conditions";

if (taskTitle.length > 0) {
  console.log("The title is valid.");
}
```

### `if...else`

```js
const taskTitle = "";

if (taskTitle.length > 0) {
  console.log("The title is valid.");
} else {
  console.log("The title is empty.");
}
```

### `if...else if...else`

```js
const score = 75;

if (score >= 90) {
  console.log("Excellent");
} else if (score >= 70) {
  console.log("Good");
} else {
  console.log("Keep practicing");
}
```

### Ternary operator

A ternary expression is a short conditional expression:

```js
const completed = true;

const label = completed
  ? "Complete"
  : "Incomplete";

console.log(label);
```

Use ternaries for short choices. Use `if` statements for longer or more complex logic.

---

## B.11 `switch`

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

console.log(message);
```

The `break` statements prevent fall-through into later cases.

---

## B.12 Functions

### Function declaration

```js
function greetUser(name) {
  return `Hello, ${name}!`;
}

const greeting = greetUser("Amina");

console.log(greeting);
```

### Function expression

```js
const greetUser = function (name) {
  return `Hello, ${name}!`;
};

console.log(greetUser("Amina"));
```

### Arrow function

```js
const greetUser = (name) => {
  return `Hello, ${name}!`;
};
```

### Concise arrow function

```js
const double = (number) => number * 2;

console.log(double(4));
```

### Multiple parameters

```js
function add(firstNumber, secondNumber) {
  return firstNumber + secondNumber;
}
```

### Default parameter

```js
function greetUser(name = "Guest") {
  return `Hello, ${name}!`;
}

console.log(greetUser());
```

### Rest parameter

A rest parameter gathers remaining arguments into an array:

```js
function addAll(...numbers) {
  let total = 0;

  for (const number of numbers) {
    total += number;
  }

  return total;
}

console.log(addAll(1, 2, 3, 4));
```

Expected result:

```text
10
```

### Early return

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

An early return stops the function immediately.

---

## B.13 Scope

### Block scope

```js
{
  const message = "Inside the block.";

  console.log(message);
}
```

`message` cannot be accessed outside the braces.

### Function scope

```js
function createMessage() {
  const message = "Inside the function.";

  return message;
}

console.log(createMessage());
```

The variable exists only within the function.

### Outer-scope access

```js
const applicationName = "Task List";

function getApplicationName() {
  return applicationName;
}

console.log(getApplicationName());
```

An inner function can read a value from an outer scope.

---

## B.14 Arrays

### Create an array

```js
const topics = [
  "variables",
  "functions",
  "arrays"
];
```

### Read by index

```js
console.log(topics[0]);
console.log(topics[1]);
```

### Read the length

```js
console.log(topics.length);
```

### Change an array item

```js
topics[0] = "values";
```

### Add to the end

```js
topics.push("objects");
```

### Remove from the end

```js
const removedTopic = topics.pop();
```

### Add to the beginning

```js
topics.unshift("introduction");
```

### Remove from the beginning

```js
const firstTopic = topics.shift();
```

### Copy a section

```js
const selectedTopics = topics.slice(0, 2);
```

### Find an index

```js
const arraysIndex = topics.indexOf("arrays");
```

### Check whether a value exists

```js
const hasArraysTopic =
  topics.indexOf("arrays") !== -1;
```

### Loop through values

```js
for (const topic of topics) {
  console.log(topic);
}
```

### Loop through indexes

```js
for (
  let index = 0;
  index < topics.length;
  index += 1
) {
  console.log(index, topics[index]);
}
```

---

## B.15 Modern Array Methods

### `forEach`

Runs a function for every item.

```js
const topics = ["variables", "functions"];

topics.forEach((topic) => {
  console.log(topic);
});
```

`forEach` does not create a new array.

### `map`

Creates a new array by transforming every item.

```js
const numbers = [1, 2, 3];

const doubledNumbers = numbers.map(
  (number) => number * 2
);

console.log(doubledNumbers);
```

Expected result:

```text
[2, 4, 6]
```

### `filter`

Creates a new array containing only items that pass a condition.

```js
const tasks = [
  { title: "Read", completed: true },
  { title: "Write", completed: false }
];

const completedTasks = tasks.filter(
  (task) => task.completed
);

console.log(completedTasks);
```

### `find`

Returns the first matching item.

```js
const task = tasks.find(
  (item) => item.title === "Write"
);
```

If no item matches, the result is `undefined`.

### `findIndex`

Returns the first matching index.

```js
const taskIndex = tasks.findIndex(
  (item) => item.title === "Write"
);
```

If no item matches, the result is `-1`.

### `some`

Returns `true` if at least one item passes the condition.

```js
const hasCompletedTask = tasks.some(
  (task) => task.completed
);
```

### `every`

Returns `true` if every item passes the condition.

```js
const allTasksHaveTitles = tasks.every(
  (task) => task.title.length > 0
);
```

### `reduce`

Combines an array into one result.

```js
const numbers = [1, 2, 3, 4];

const total = numbers.reduce(
  (runningTotal, number) => {
    return runningTotal + number;
  },
  0
);

console.log(total);
```

Expected result:

```text
10
```

---

## B.16 Objects

### Object literal

```js
const task = {
  id: 1,
  title: "Learn objects",
  completed: false
};
```

### Dot notation

```js
console.log(task.title);
```

### Bracket notation

```js
console.log(task["title"]);
```

### Update a property

```js
task.completed = true;
```

### Add a property

```js
task.priority = "high";
```

### Delete a property

```js
delete task.priority;
```

Use deletion carefully. A consistent data shape is often easier to work with than objects whose properties appear and disappear unpredictably.

### Dynamic property access

```js
const propertyName = "title";

console.log(task[propertyName]);
```

### Dynamic property creation

```js
const categoryName = "work";

const categorizedTask = {
  title: "Study",
  [categoryName]: true
};

console.log(categorizedTask.work);
```

---

## B.17 Object Destructuring

Destructuring extracts named properties.

```js
const task = {
  id: 1,
  title: "Read",
  completed: false
};

const {
  id,
  title,
  completed
} = task;

console.log(id);
console.log(title);
console.log(completed);
```

Rename during destructuring:

```js
const {
  title: taskTitle
} = task;

console.log(taskTitle);
```

Use a default value:

```js
const {
  priority = "normal"
} = task;

console.log(priority);
```

---

## B.18 Array Destructuring

```js
const coordinates = [10, 20];

const [
  x,
  y
] = coordinates;

console.log(x);
console.log(y);
```

Skip a value:

```js
const values = ["first", "second", "third"];

const [
  first,
  ,
  third
] = values;

console.log(first);
console.log(third);
```

---

## B.19 Spread Syntax

### Copy an array

```js
const originalTopics = [
  "variables",
  "functions"
];

const copiedTopics = [
  ...originalTopics
];

copiedTopics.push("arrays");

console.log(originalTopics);
console.log(copiedTopics);
```

The arrays are separate outer arrays.

### Combine arrays

```js
const firstGroup = ["a", "b"];
const secondGroup = ["c", "d"];

const combined = [
  ...firstGroup,
  ...secondGroup
];

console.log(combined);
```

### Copy and update an object

```js
const originalTask = {
  id: 1,
  title: "Read",
  completed: false
};

const completedTask = {
  ...originalTask,
  completed: true
};

console.log(completedTask);
```

This is a common way to create an updated object without changing the original object.

---

## B.20 Loops

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
let remaining = 3;

while (remaining > 0) {
  console.log(remaining);
  remaining -= 1;
}
```

Always ensure the loop condition can eventually become false.

### `for...of`

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

### `break`

Stops a loop:

```js
for (const topic of topics) {
  if (topic === "functions") {
    break;
  }

  console.log(topic);
}
```

### `continue`

Skips the current iteration:

```js
for (const topic of topics) {
  if (topic === "functions") {
    continue;
  }

  console.log(topic);
}
```

Use `break` and `continue` sparingly. Clear conditions often make loops easier to understand.

---

## B.21 Error Handling

### Throw an error

```js
function createTask(title) {
  if (typeof title !== "string") {
    throw new TypeError(
      "Task title must be a string."
    );
  }

  return {
    title,
    completed: false
  };
}
```

### `try...catch`

```js
try {
  const task = createTask(42);
  console.log(task);
} catch (error) {
  console.error("Could not create task:", error.message);
}
```

### `finally`

`finally` runs whether an error occurs or not:

```js
try {
  console.log("Trying operation.");
} catch (error) {
  console.error(error);
} finally {
  console.log("Operation finished.");
}
```

### Error types

Use the most specific appropriate error type:

```js
throw new TypeError("Expected a string.");
throw new RangeError("Number is outside the allowed range.");
throw new Error("General application error.");
```

---

## B.22 JSON

JSON is a text format commonly used for storing and transferring structured data.

### Convert an object to JSON text

```js
const task = {
  id: 1,
  title: "Read",
  completed: false
};

const jsonText = JSON.stringify(task);

console.log(jsonText);
```

### Convert JSON text back to an object

```js
const jsonText = `{
  "id": 1,
  "title": "Read",
  "completed": false
}`;

const task = JSON.parse(jsonText);

console.log(task.title);
```

Handle invalid JSON:

```js
try {
  const parsedValue = JSON.parse("invalid JSON");
  console.log(parsedValue);
} catch (error) {
  console.error("Could not parse JSON:", error.message);
}
```

---

## B.23 Console Methods

### `console.log`

```js
console.log("Application started.");
```

### Log multiple values

```js
const taskCount = 3;

console.log("Task count:", taskCount);
```

### `console.warn`

```js
console.warn("This feature is experimental.");
```

### `console.error`

```js
console.error("The task could not be found.");
```

### `console.table`

Useful for arrays of objects:

```js
const tasks = [
  {
    id: 1,
    title: "Read",
    completed: false
  },
  {
    id: 2,
    title: "Write",
    completed: true
  }
];

console.table(tasks);
```

---

## B.24 DOM Syntax

### Select one element

```js
const headingElement =
  document.querySelector("h1");
```

### Select multiple elements

```js
const buttons =
  document.querySelectorAll("button");
```

`querySelectorAll` returns a collection that can be traversed:

```js
for (const button of buttons) {
  console.log(button.textContent);
}
```

### Create an element

```js
const listItemElement =
  document.createElement("li");
```

### Set text

```js
listItemElement.textContent = "Learn the DOM";
```

### Set a class

```js
listItemElement.className = "task-item";
```

or:

```js
listItemElement.classList.add("task-item");
```

### Append an element

```js
taskListElement.append(listItemElement);
```

### Remove an element

```js
listItemElement.remove();
```

### Set an attribute

```js
buttonElement.setAttribute(
  "aria-label",
  "Complete task"
);
```

### Read an attribute

```js
const label =
  buttonElement.getAttribute("aria-label");
```

### Set a data attribute

```js
listItemElement.dataset.taskId = "12";
```

### Read a data attribute

```js
const taskId =
  listItemElement.dataset.taskId;
```

---

## B.25 Events

### Click event

```js
buttonElement.addEventListener(
  "click",
  () => {
    console.log("Button clicked.");
  }
);
```

### Form submission

```js
formElement.addEventListener(
  "submit",
  (event) => {
    event.preventDefault();

    console.log("Form submitted.");
  }
);
```

### Input event

Runs as the user types:

```js
inputElement.addEventListener(
  "input",
  () => {
    console.log(inputElement.value);
  }
);
```

### Change event

Runs when a control’s value is committed:

```js
selectElement.addEventListener(
  "change",
  () => {
    console.log(selectElement.value);
  }
);
```

### Keyboard event

```js
inputElement.addEventListener(
  "keydown",
  (event) => {
    if (event.key === "Enter") {
      console.log("Enter was pressed.");
    }
  }
);
```

### Event target

```js
buttonElement.addEventListener(
  "click",
  (event) => {
    console.log(event.target);
  }
);
```

### Prevent default behavior

```js
linkElement.addEventListener(
  "click",
  (event) => {
    event.preventDefault();

    console.log("Navigation prevented.");
  }
);
```

---

## B.26 Common Naming Patterns

### Variables

Use descriptive nouns:

```js
const taskTitle = "Learn JavaScript";
const taskCount = 3;
const selectedTask = null;
```

### Functions

Use verbs:

```js
function createTask() {}
function renderTasks() {}
function removeTask() {}
function validateTitle() {}
```

### Booleans

Use names that sound like questions:

```js
const isCompleted = false;
const hasPermission = true;
const canSubmit = false;
const shouldRender = true;
```

### DOM elements

Make the element type clear:

```js
const taskFormElement = document.querySelector("#task-form");
const taskListElement = document.querySelector("#task-list");
const submitButtonElement =
  document.querySelector("button[type='submit']");
```

---

## B.27 Complete Mini Example

The following example combines the most important syntax patterns into one small program:

```js
"use strict";

const tasks = [];

let nextTaskId = 1;

function createTask(rawTitle) {
  if (typeof rawTitle !== "string") {
    throw new TypeError(
      "Task title must be a string."
    );
  }

  const title = rawTitle.trim();

  if (title.length === 0) {
    throw new Error(
      "Task title cannot be empty."
    );
  }

  const task = {
    id: nextTaskId,
    title,
    completed: false
  };

  nextTaskId += 1;

  return task;
}

function addTask(rawTitle) {
  const task = createTask(rawTitle);

  tasks.push(task);

  return task;
}

function completeTask(taskId) {
  const task = tasks.find(
    (item) => item.id === taskId
  );

  if (task === undefined) {
    return false;
  }

  task.completed = true;

  return true;
}

function describeTask(task) {
  const state = task.completed
    ? "complete"
    : "incomplete";

  return `${task.id}. ${task.title} (${state})`;
}

try {
  addTask("Learn variables");
  addTask("Practice functions");
  addTask("Build a task application");

  completeTask(2);

  const descriptions = tasks.map(
    (task) => describeTask(task)
  );

  console.log(descriptions.join("\n"));
} catch (error) {
  console.error(
    "Application error:",
    error.message
  );
}
```

Expected output:

```text
1. Learn variables (incomplete)
2. Practice functions (complete)
3. Build a task application (incomplete)
```

This example uses:

- Strict mode.
- `const` and `let`.
- Arrays.
- Objects.
- Functions.
- Parameters.
- Return values.
- Validation.
- `find`.
- `map`.
- Template literals.
- A ternary expression.
- `try...catch`.

---

# Appendix B Completion Checklist

Use this appendix to confirm that you can recognize and write:

- Comments.
- `const` and `let`.
- Strings, numbers, and booleans.
- `null` and `undefined`.
- Strict equality.
- Logical expressions.
- `if` statements.
- `switch` statements.
- Function declarations.
- Function expressions.
- Arrow functions.
- Parameters and return values.
- Arrays and array methods.
- Objects and object properties.
- Destructuring.
- Spread syntax.
- Loops.
- Error handling.
- DOM selection.
- DOM creation.
- Event listeners.
- Form submission handling.
