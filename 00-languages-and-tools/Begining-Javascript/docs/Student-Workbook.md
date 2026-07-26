# Beginning JavaScript: Foundations & Interactive Web

## Student Workbook

This workbook accompanies the **Beginning JavaScript: Foundations & Interactive Web** tutorial series.

Use it to:

- Record predictions before running code.
- Complete guided exercises.
- Track verification results.
- Document errors and fixes.
- Design and improve the task application.
- Reflect on what you understand and what needs more practice.

---

# How to Use This Workbook

For each exercise:

1. Read the goal.
2. Write your prediction before running the code.
3. Implement the exercise.
4. Verify the result.
5. Record what happened.
6. If something fails, document the error and fix.
7. Do not continue until the current step works.

Use this development loop:

```text
Plan
  ↓
Write code
  ↓
Save
  ↓
Run
  ↓
Observe
  ↓
Debug
  ↓
Record
  ↓
Continue
```

---

# Student Information

**Name:** ______________________________________

**Start date:** __________________________________

**Completion date:** _____________________________

**Primary browser:** _____________________________

**Code editor:** _________________________________

---

# Project Setup Checklist

- [ ] Installed a modern browser.
- [ ] Installed a code editor.
- [ ] Opened browser Developer Tools.
- [ ] Opened the browser Console.
- [ ] Created the project directory.
- [ ] Created the `src` directory.
- [ ] Started a local development server.
- [ ] Opened the project in the browser.

## Project Structure

```text
javascript-foundations/
├── index.html
├── styles.css
└── src/
```

## Local Development URL

```text
http://localhost:________________
```

## Tooling Verification

Run this in the browser Console:

```js
2 + 3
```

Expected result:

```text
5
```

Actual result:

```text
____________________________________________________
```

---

# Primer 1: How the Web Works

## Core Mental Model

Complete the following:

```text
HTML       → ______________________________________

CSS        → ______________________________________

JavaScript → ______________________________________

Browser    → ______________________________________
```

## Browser Loading Process

Complete the sequence:

```text
Request a resource
    ↓
Receive __________________
    ↓
Parse ____________________
    ↓
Load CSS and JavaScript
    ↓
Build the ____________________
    ↓
Display the page
```

## DOM Practice

Given this HTML:

```html
<main id="app">
  <h1 id="heading">Task List</h1>
  <p id="message">Ready.</p>
</main>
```

Write JavaScript that:

1. Selects the heading.
2. Selects the message.
3. Changes the heading to `"JavaScript Task List"`.
4. Changes the message to `"The DOM was updated."`.

```js
// Your solution:

```

## Prediction

What will the page display?

```js
const heading = document.querySelector("#heading");

heading.textContent = "Updated heading";
```

Prediction:

```text
____________________________________________________
```

Actual result:

```text
____________________________________________________
```

## Reflection

What is the difference between JavaScript and the DOM?

```text
____________________________________________________

____________________________________________________
```

---

# Primer 2: Programming Mental Models

## Complete the Definitions

A program is:

```text
____________________________________________________
```

A variable is:

```text
____________________________________________________
```

A function is:

```text
____________________________________________________
```

State is:

```text
____________________________________________________
```

Rendering means:

```text
____________________________________________________
```

## Application Flow

Complete the task-application flow:

```text
User action
    ↓
________________________
    ↓
Read input
    ↓
________________________
    ↓
Update application state
    ↓
________________________
```

## Input, Processing, Output

For a task form, identify each stage.

### Input

```text
____________________________________________________
```

### Processing

```text
____________________________________________________
```

### Output

```text
____________________________________________________
```

---

# Primer 3: How to Read JavaScript

## Read This Statement

```js
const taskTitle = "Learn JavaScript";
```

Identify each part:

| Part | Answer |
|---|---|
| Declaration keyword | __________________ |
| Variable name | __________________ |
| Operator | __________________ |
| Value | __________________ |
| Value type | __________________ |

## Read This Function Call

```js
const task = createTask("Learn functions", 1);
```

Function name:

```text
____________________________________________________
```

First argument:

```text
____________________________________________________
```

Second argument:

```text
____________________________________________________
```

Variable receiving the result:

```text
____________________________________________________
```

## Read This Event Handler

```js
button.addEventListener("click", () => {
  message.textContent = "Clicked";
});
```

When does the callback run?

```text
____________________________________________________
```

What does the callback change?

```text
____________________________________________________
```

---

# Primer 4: Browser Development Loop

## Development Loop

Write the missing steps:

```text
Plan
    ↓
____________________
    ↓
Save
    ↓
____________________
    ↓
Observe
    ↓
____________________
```

## Debugging Notes

When an error occurs, record:

**Error message:**

```text
____________________________________________________
```

**File and line:**

```text
____________________________________________________
```

**What I expected:**

```text
____________________________________________________
```

**What actually happened:**

```text
____________________________________________________
```

**My hypothesis:**

```text
____________________________________________________
```

**The fix:**

```text
____________________________________________________
```

---

# Part 1: The Building Blocks & Mental Model

## Part 1 Completion Checklist

- [ ] I can declare variables.
- [ ] I understand strings.
- [ ] I understand numbers.
- [ ] I understand booleans.
- [ ] I understand `null`.
- [ ] I understand `undefined`.
- [ ] I can use arithmetic operators.
- [ ] I can use strict equality.
- [ ] I can write `if` statements.
- [ ] I can write `switch` statements.
- [ ] I can write `for` loops.
- [ ] I can write `while` loops.
- [ ] I can write `for...of` loops.
- [ ] I understand primitive values.
- [ ] I understand object references.

---

## Part 1 Exercise 1: Variables

Create a file:

```text
src/part-1-exercise-1.js
```

Declare variables for:

- Your name.
- Your current lesson number.
- Whether you are enjoying JavaScript.
- An optional note.
- A selected task that currently does not exist.

Use:

- `const` where possible.
- `let` only where reassignment is required.

```js
"use strict";

// Your solution:

```

### Prediction

What values will each variable contain?

```text
____________________________________________________

____________________________________________________
```

### Verification

Add:

```js
console.log({
  // your variables
});
```

Record the result:

```text
____________________________________________________
```

---

## Part 1 Exercise 2: Types

Predict the result of each expression.

```js
typeof "JavaScript"
```

Prediction:

```text
____________________________________________________
```

```js
typeof 42
```

Prediction:

```text
____________________________________________________
```

```js
typeof false
```

Prediction:

```text
____________________________________________________
```

```js
typeof undefined
```

Prediction:

```text
____________________________________________________
```

```js
typeof null
```

Prediction:

```text
____________________________________________________
```

Run each expression and record the actual result.

---

## Part 1 Exercise 3: Arithmetic

Write JavaScript that calculates:

- A subtotal of `4` items costing `12.50` each.
- A tax amount of `20%`.
- A final total.

```js
"use strict";

// Your solution:

```

Expected subtotal:

```text
____________________________________________________
```

Expected tax:

```text
____________________________________________________
```

Expected total:

```text
____________________________________________________
```

Actual output:

```text
____________________________________________________
```

---

## Part 1 Exercise 4: Strict Equality

Predict whether each expression is `true` or `false`.

```js
5 === 5
```

```text
Prediction: ________________________________________
```

```js
5 === "5"
```

```text
Prediction: ________________________________________
```

```js
false === 0
```

```text
Prediction: ________________________________________
```

```js
"task" === "task"
```

```text
Prediction: ________________________________________
```

Explain one surprising result:

```text
____________________________________________________

____________________________________________________
```

---

## Part 1 Exercise 5: Conditions

Write a function named `describeAge` that returns:

- `"Child"` for ages below `13`.
- `"Teenager"` for ages from `13` through `17`.
- `"Adult"` for ages from `18` through `64`.
- `"Senior"` for ages `65` and above.
- `"Invalid age"` for negative or non-numeric values.

```js
"use strict";

function describeAge(age) {
  // Your solution:
}
```

Test it:

```js
console.log(describeAge(8));
console.log(describeAge(15));
console.log(describeAge(30));
console.log(describeAge(70));
console.log(describeAge(-1));
console.log(describeAge("30"));
```

Expected output:

```text
Child
Teenager
Adult
Senior
Invalid age
Invalid age
```

Actual output:

```text
____________________________________________________
```

---

## Part 1 Exercise 6: `switch`

Create a function named `getDifficultyMessage`.

It should support:

- `"beginner"`
- `"intermediate"`
- `"advanced"`

It should return a fallback message for unknown values.

```js
"use strict";

function getDifficultyMessage(difficulty) {
  // Your solution:
}

console.log(getDifficultyMessage("beginner"));
console.log(getDifficultyMessage("intermediate"));
console.log(getDifficultyMessage("advanced"));
console.log(getDifficultyMessage("unknown"));
```

Expected output:

```text
____________________________________________________

____________________________________________________

____________________________________________________

____________________________________________________
```

---

## Part 1 Exercise 7: `for` Loop

Create an array:

```js
const topics = [
  "variables",
  "conditions",
  "loops",
  "functions"
];
```

Use a traditional `for` loop to print:

```text
1. variables
2. conditions
3. loops
4. functions
```

```js
"use strict";

const topics = [
  "variables",
  "conditions",
  "loops",
  "functions"
];

// Your solution:

```

---

## Part 1 Exercise 8: `while` Loop

Use a `while` loop to count down from `5` to `1`.

Expected output:

```text
5
4
3
2
1
Finished
```

```js
"use strict";

// Your solution:

```

What prevents the loop from continuing forever?

```text
____________________________________________________
```

---

## Part 1 Exercise 9: Primitive Copy

Predict the final values:

```js
let firstCount = 1;
let secondCount = firstCount;

secondCount = 2;
```

Final `firstCount`:

```text
Prediction: ________________________________________
```

Final `secondCount`:

```text
Prediction: ________________________________________
```

Run the code and record the result.

---

## Part 1 Exercise 10: Reference Copy

Predict the final values:

```js
const firstTask = {
  completed: false
};

const secondTask = firstTask;

secondTask.completed = true;
```

Final `firstTask.completed`:

```text
Prediction: ________________________________________
```

Final `secondTask.completed`:

```text
Prediction: ________________________________________
```

Why do both values change?

```text
____________________________________________________

____________________________________________________
```

---

# Part 2: Functional Units & Scope

## Part 2 Completion Checklist

- [ ] I can declare a function.
- [ ] I can call a function.
- [ ] I understand parameters.
- [ ] I understand arguments.
- [ ] I can return a value.
- [ ] I can write a function expression.
- [ ] I can write an arrow function.
- [ ] I understand global scope.
- [ ] I understand function scope.
- [ ] I understand block scope.
- [ ] I understand `var`.
- [ ] I understand `let`.
- [ ] I understand `const`.
- [ ] I understand callbacks.
- [ ] I understand closures.

---

## Part 2 Exercise 1: Greeting Function

Write a function named `greetUser`.

It should:

- Accept a name.
- Return `"Hello, NAME!"`.
- Use `"Guest"` if no name is provided.

```js
"use strict";

function greetUser(name = "Guest") {
  // Your solution:
}

console.log(greetUser("Amina"));
console.log(greetUser());
```

Expected output:

```text
Hello, Amina!
Hello, Guest!
```

---

## Part 2 Exercise 2: Calculator Functions

Create functions named:

- `add`
- `subtract`
- `multiply`
- `divide`

Each function should accept two numbers and return the result.

For division, reject division by zero.

```js
"use strict";

function add(firstNumber, secondNumber) {
  // Your solution:
}

function subtract(firstNumber, secondNumber) {
  // Your solution:
}

function multiply(firstNumber, secondNumber) {
  // Your solution:
}

function divide(firstNumber, secondNumber) {
  // Your solution:
}
```

Test:

```js
console.log(add(10, 5));
console.log(subtract(10, 5));
console.log(multiply(10, 5));
console.log(divide(10, 5));
```

Expected output:

```text
15
5
50
2
```

---

## Part 2 Exercise 3: Validation Function

Create a function named `isValidTaskTitle`.

Rules:

- Input must be a string.
- Trimmed title must contain at least one character.
- Title must not exceed `120` characters.

```js
"use strict";

function isValidTaskTitle(value) {
  // Your solution:
}
```

Test these values:

```js
console.log(isValidTaskTitle("Learn JavaScript"));
console.log(isValidTaskTitle("   "));
console.log(isValidTaskTitle(""));
console.log(isValidTaskTitle(42));
console.log(isValidTaskTitle("a".repeat(121)));
```

Expected results:

```text
true
false
false
false
false
```

---

## Part 2 Exercise 4: Function Expression

Rewrite this function declaration as a function expression:

```js
function square(number) {
  return number * number;
}
```

Your solution:

```js
const square = // Your solution
```

Test:

```js
console.log(square(4));
```

Expected:

```text
16
```

---

## Part 2 Exercise 5: Arrow Functions

Write these arrow functions:

```js
const double = // Your solution

const isEven = // Your solution

const formatLabel = // Your solution
```

Requirements:

- `double(4)` returns `8`.
- `isEven(4)` returns `true`.
- `formatLabel("task")` returns `"TASK"`.

---

## Part 2 Exercise 6: Scope

Predict which lines cause errors:

```js
const globalMessage = "Global";

function testScope() {
  const functionMessage = "Function";

  if (true) {
    const blockMessage = "Block";

    console.log(globalMessage);
    console.log(functionMessage);
    console.log(blockMessage);
  }

  console.log(globalMessage);
  console.log(functionMessage);
  console.log(blockMessage);
}
```

Will `globalMessage` be accessible inside the function?

```text
____________________________________________________
```

Will `functionMessage` be accessible inside the block?

```text
____________________________________________________
```

Will `blockMessage` be accessible after the block?

```text
____________________________________________________
```

Run the code and record the actual error.

---

## Part 2 Exercise 7: `var`, `let`, and `const`

Complete the table.

| Declaration | Reassignable? | Block-scoped? |
|---|---:|---:|
| `var` | __________ | __________ |
| `let` | __________ | __________ |
| `const` | __________ | __________ |

Write one example where `let` is appropriate:

```js
// Your solution:

```

Write one example where `const` is appropriate:

```js
// Your solution:

```

---

## Part 2 Exercise 8: Callback Function

Write a function named `applyToEachValue`.

It should accept:

1. An array.
2. A callback function.

It should return a new array containing the callback result for every item.

```js
"use strict";

function applyToEachValue(values, callback) {
  // Your solution:
}

const numbers = [1, 2, 3, 4];

const doubled = applyToEachValue(
  numbers,
  (number) => number * 2
);

console.log(doubled);
```

Expected:

```text
[2, 4, 6, 8]
```

---

## Part 2 Exercise 9: Closure Counter

Create a function named `createCounter`.

Each counter should maintain its own private number.

```js
"use strict";

function createCounter(startingValue = 0) {
  // Your solution:
}

const firstCounter = createCounter(0);
const secondCounter = createCounter(10);

console.log(firstCounter());
console.log(firstCounter());
console.log(secondCounter());
console.log(firstCounter());
console.log(secondCounter());
```

Expected output:

```text
1
2
11
3
12
```

Why do the counters not share one value?

```text
____________________________________________________

____________________________________________________
```

---

## Part 2 Exercise 10: Task Factory

Create a function named `createTask`.

It should:

- Accept a title and ID.
- Trim the title.
- Reject an empty title.
- Return an object with:
  - `id`
  - `title`
  - `completed`

```js
"use strict";

function createTask(title, id) {
  // Your solution:
}

const task = createTask(
  "  Practice task factories  ",
  1
);

console.log(task);
```

Expected:

```js
{
  id: 1,
  title: "Practice task factories",
  completed: false
}
```

---

# Part 3: Data Structures in Practice

## Part 3 Completion Checklist

- [ ] I can create arrays.
- [ ] I can read array values by index.
- [ ] I understand zero-based indexing.
- [ ] I can use `push`.
- [ ] I can use `pop`.
- [ ] I can use `shift`.
- [ ] I can use `unshift`.
- [ ] I can use `slice`.
- [ ] I can use `indexOf`.
- [ ] I can create object literals.
- [ ] I can use dot notation.
- [ ] I can use bracket notation.
- [ ] I can use dynamic keys.
- [ ] I can store objects in arrays.
- [ ] I can use `find`.
- [ ] I can use `findIndex`.
- [ ] I can use `splice`.

---

## Part 3 Exercise 1: Array Indexing

Create this array:

```js
const tools = [
  "browser",
  "editor",
  "terminal",
  "console"
];
```

Write code that displays:

- First item.
- Second item.
- Last item.
- Number of items.

```js
"use strict";

// Your solution:

```

Expected output:

```text
First item: browser
Second item: editor
Last item: console
Number of items: 4
```

---

## Part 3 Exercise 2: Array Mutation

Start with:

```js
const actions = [];
```

Perform these operations:

1. Add `"Open editor"` to the end.
2. Add `"Create project"` to the end.
3. Remove the last item.
4. Add `"Start browser"` to the beginning.
5. Remove the first item.

```js
"use strict";

const actions = [];

// Your solution:

console.log(actions);
```

Record the final result:

```text
____________________________________________________
```

---

## Part 3 Exercise 3: `slice`

Given:

```js
const topics = [
  "variables",
  "functions",
  "arrays",
  "objects",
  "dom"
];
```

Use `slice` to create:

- The first two topics.
- The middle three topics.
- The final two topics.

```js
"use strict";

// Your solution:

```

Expected:

```text
First two: variables, functions
Middle three: functions, arrays, objects
Final two: objects, dom
```

---

## Part 3 Exercise 4: `indexOf`

Write code that checks whether the following topics exist:

```js
const topics = [
  "variables",
  "functions",
  "arrays"
];
```

Search for:

- `"functions"`
- `"dom"`

```js
"use strict";

// Your solution:

```

Remember:

```js
indexOf(...) !== -1
```

means the value was found.

---

## Part 3 Exercise 5: Object Literals

Create a task object with:

- ID `1`.
- Title `"Practice objects"`.
- Completed value `false`.
- Priority `"high"`.

```js
"use strict";

const task = {
  // Your solution:
};

console.log(task);
```

---

## Part 3 Exercise 6: Property Access

Using the task object, read:

- The title with dot notation.
- The title with bracket notation.
- The priority with a dynamic key.

```js
"use strict";

const task = {
  id: 1,
  title: "Practice objects",
  completed: false,
  priority: "high"
};

const propertyName = "priority";

// Your solution:

```

---

## Part 3 Exercise 7: Dynamic Keys

Create a variable:

```js
const selectedCategory = "work";
```

Use it to create an object with a dynamic property:

```js
const task = {
  title: "Study JavaScript",
  [selectedCategory]: true
};
```

Write the complete example:

```js
"use strict";

// Your solution:

```

Expected result:

```js
{
  title: "Study JavaScript",
  work: true
}
```

---

## Part 3 Exercise 8: Arrays of Objects

Create an array containing three tasks.

Each task must have:

```js
{
  id,
  title,
  completed
}
```

```js
"use strict";

const tasks = [
  // Your solution:
];

for (const task of tasks) {
  console.log(
    `${task.id}. ${task.title}`
  );
}
```

---

## Part 3 Exercise 9: Find a Task

Write a function named `findTaskById`.

```js
"use strict";

function findTaskById(tasks, taskId) {
  // Your solution:
}

const tasks = [
  {
    id: 1,
    title: "Read",
    completed: false
  },
  {
    id: 2,
    title: "Write",
    completed: false
  }
];

console.log(findTaskById(tasks, 2));
console.log(findTaskById(tasks, 99));
```

Expected:

```text
Task with id 2
undefined
```

---

## Part 3 Exercise 10: Complete a Task

Write a function named `completeTask`.

It should:

- Find a task by ID.
- Set `completed` to `true`.
- Return `true` when successful.
- Return `false` when no task exists.

```js
"use strict";

function completeTask(tasks, taskId) {
  // Your solution:
}
```

Test:

```js
const tasks = [
  {
    id: 1,
    title: "Practice updates",
    completed: false
  }
];

console.log(completeTask(tasks, 1));
console.log(tasks);
console.log(completeTask(tasks, 99));
```

Expected results:

```text
true
Task 1 completed: true
false
```

---

## Part 3 Exercise 11: Remove a Task

Write a function named `removeTaskById`.

```js
"use strict";

function removeTaskById(tasks, taskId) {
  // Your solution:
}
```

Requirements:

- Return `false` if the ID does not exist.
- Return `true` after removing a matching task.
- Use `findIndex`.
- Use `splice`.

---

## Part 3 Exercise 12: Task Summary

Write a function named `describeTask`.

It should return:

```text
1. Learn arrays — complete
```

or:

```text
1. Learn arrays — incomplete
```

```js
"use strict";

function describeTask(task) {
  // Your solution:
}
```

---

# Part 4: Connecting JavaScript to the DOM & Events

## Part 4 Completion Checklist

- [ ] I can select DOM elements.
- [ ] I can validate selected elements.
- [ ] I can use `textContent`.
- [ ] I can create DOM elements.
- [ ] I can append elements.
- [ ] I can remove elements.
- [ ] I can use `classList`.
- [ ] I can use `dataset`.
- [ ] I can listen for events.
- [ ] I can handle form submission.
- [ ] I can call `preventDefault`.
- [ ] I understand event bubbling.
- [ ] I can use event delegation.
- [ ] I can render arrays of objects into the DOM.
- [ ] I can safely display user-entered text.

---

## Part 4 Exercise 1: Select Elements

Given:

```html
<form id="task-form">
  <input id="task-title" />
  <button type="submit">Add</button>
</form>

<p id="message"></p>

<ul id="task-list"></ul>
```

Write JavaScript that selects and validates all four elements.

```js
"use strict";

// Your solution:

```

---

## Part 4 Exercise 2: Change Text

Select:

```html
<p id="message">Original message</p>
```

Change its text to:

```text
The DOM was updated.
```

```js
"use strict";

// Your solution:

```

---

## Part 4 Exercise 3: Create an Element

Create a new list item with:

```text
Created by JavaScript
```

Append it to:

```html
<ul id="task-list"></ul>
```

```js
"use strict";

// Your solution:

```

---

## Part 4 Exercise 4: Toggle a Class

Given:

```html
<p id="task-title" class="task-title">
  Practice class toggling
</p>

<button id="toggle-button" type="button">
  Toggle
</button>
```

Create CSS:

```css
.task-title--completed {
  text-decoration: line-through;
}
```

Then make the button toggle the class.

```js
"use strict";

// Your solution:

```

---

## Part 4 Exercise 5: Read Input

Given:

```html
<label for="task-title">Task title</label>
<input id="task-title" type="text" />
<button id="read-button" type="button">
  Read title
</button>
<p id="message"></p>
```

Write JavaScript that:

- Reads the input value.
- Trims it.
- Rejects empty input.
- Displays the title.

```js
"use strict";

// Your solution:

```

---

## Part 4 Exercise 6: Handle Form Submission

Create a form that:

- Prevents page reload.
- Reads the title.
- Rejects empty input.
- Displays a success message.
- Resets the form.

```html
<form id="task-form">
  <label for="task-title">
    Task title
  </label>

  <input
    id="task-title"
    name="title"
    type="text"
  />

  <button type="submit">
    Add task
  </button>
</form>

<p id="message"></p>
```

```js
"use strict";

// Your solution:

```

---

## Part 4 Exercise 7: Render Tasks

Given:

```js
const tasks = [
  {
    id: 1,
    title: "Learn rendering",
    completed: false
  },
  {
    id: 2,
    title: "Practice rendering",
    completed: true
  }
];
```

Render each task into:

```html
<ul id="task-list"></ul>
```

Completed tasks should receive:

```text
task-item--completed
```

```js
"use strict";

// Your solution:

```

---

## Part 4 Exercise 8: Add Tasks from a Form

Build a form that adds new objects to an array and renders the updated list.

Your application should contain:

```js
const tasks = [];
let nextTaskId = 1;
```

The task shape should be:

```js
{
  id: 1,
  title: "Example",
  completed: false
}
```

Required flow:

```text
Submit form
    ↓
Prevent default
    ↓
Read input
    ↓
Trim input
    ↓
Reject empty input
    ↓
Create task
    ↓
Push task
    ↓
Render tasks
    ↓
Reset form
```

Implementation:

```js
"use strict";

// Your solution:

```

---

## Part 4 Exercise 9: Complete Tasks

Add a **Complete** button to every rendered task.

When clicked:

- Toggle `task.completed`.
- Re-render the list.
- Change the button text between:
  - `"Complete"`
  - `"Undo"`

```js
"use strict";

// Your solution:

```

---

## Part 4 Exercise 10: Remove Tasks

Add a **Remove** button to every rendered task.

When clicked:

- Find the task by ID.
- Remove it from the array.
- Re-render the list.
- Update the task count.

```js
"use strict";

// Your solution:

```

---

## Part 4 Exercise 11: Event Delegation

Instead of attaching a separate listener to every button, attach one listener to:

```html
<ul id="task-list"></ul>
```

Use:

```js
event.target.closest("button")
```

and:

```js
button.dataset.action
```

Support:

```text
toggle-complete
remove
```

```js
"use strict";

// Your solution:

```

---

## Part 4 Exercise 12: Safe Text Rendering

Test your application with this title:

```html
<strong>This should remain text</strong>
```

Expected visible output:

```text
<strong>This should remain text</strong>
```

It must not become bold.

Which DOM property should you use?

```text
____________________________________________________
```

Which property should you avoid for untrusted task titles?

```text
____________________________________________________
```

---

# Final Project: Interactive Task Application

## Required Features

Build a complete task application with:

- [ ] Task form.
- [ ] Task title validation.
- [ ] Task creation.
- [ ] Task list rendering.
- [ ] Completion toggling.
- [ ] Task removal.
- [ ] Task count.
- [ ] Empty state.
- [ ] Success messages.
- [ ] Error messages.
- [ ] Keyboard-friendly controls.
- [ ] Safe rendering with `textContent`.
- [ ] Event delegation.

## Required Project Structure

```text
javascript-foundations/
├── index.html
├── styles.css
└── src/
    └── app.js
```

## Data Model

```js
{
  id: 1,
  title: "Learn JavaScript",
  completed: false
}
```

## Application State

```js
const tasks = [];
let nextTaskId = 1;
```

## Required Functions

Create at least these functions:

```js
function createTask(title, id) {
  // ...
}

function findTaskById(tasks, taskId) {
  // ...
}

function removeTaskById(tasks, taskId) {
  // ...
}

function createTaskElement(task) {
  // ...
}

function renderTasks(tasks) {
  // ...
}

function showFormMessage(message, type) {
  // ...
}
```

## Final Verification

### Initial state

- [ ] The page loads without errors.
- [ ] The list is empty.
- [ ] The empty-state message appears.
- [ ] The count displays `0 tasks`.

### Add task

- [ ] A valid title creates a task.
- [ ] The task appears.
- [ ] The count increases.
- [ ] The form resets.
- [ ] Focus returns to the input.

### Invalid input

- [ ] Empty input is rejected.
- [ ] Whitespace-only input is rejected.
- [ ] Long input is rejected.
- [ ] An understandable error appears.

### Complete task

- [ ] The task receives a completed style.
- [ ] The button changes to `Undo`.
- [ ] The task count remains correct.
- [ ] The state is updated.

### Undo task

- [ ] The completed style is removed.
- [ ] The button changes back to `Complete`.

### Remove task

- [ ] The task disappears.
- [ ] The count decreases.
- [ ] The empty state returns when the final task is removed.

### Security

- [ ] HTML-looking input remains text.
- [ ] User input is not inserted with unsafe `innerHTML`.
- [ ] No user input is executed as JavaScript.

### Accessibility

- [ ] Every input has a label.
- [ ] Buttons are real `<button>` elements.
- [ ] Buttons have visible focus.
- [ ] Status messages use `aria-live`.
- [ ] The application works with the keyboard.

---

# Extension Challenges

## Challenge 1: Completed Count

Display:

```text
Total: 4
Active: 2
Completed: 2
```

Function starter:

```js
function getTaskStatistics(tasks) {
  // Your solution:
}
```

---

## Challenge 2: Clear Completed

Add a button that removes every completed task.

Function starter:

```js
function removeCompletedTasks(tasks) {
  // Your solution:
}
```

---

## Challenge 3: Filters

Add filters:

```text
All
Active
Completed
```

Function starter:

```js
function getVisibleTasks(tasks, filter) {
  // Your solution:
}
```

---

## Challenge 4: Edit Tasks

Allow a user to change an existing title.

Requirements:

- Add an Edit button.
- Show an input for the selected task.
- Save the new title.
- Reject empty titles.
- Support Escape to cancel.

---

## Challenge 5: Search

Add a search input.

```js
function searchTasks(tasks, query) {
  // Your solution:
}
```

Search should be case-insensitive.

---

## Challenge 6: Priority

Add:

```js
priority: "normal"
```

Allowed values:

```text
low
normal
high
```

---

## Challenge 7: Due Dates

Add an optional due date:

```js
dueDate: "2026-08-15"
```

Display overdue incomplete tasks differently.

---

## Challenge 8: `localStorage`

Save tasks:

```js
localStorage.setItem(
  "tasks",
  JSON.stringify(tasks)
);
```

Load tasks:

```js
const savedTasks =
  localStorage.getItem("tasks");
```

Remember to validate parsed data.

---

## Challenge 9: ES Modules

Split the application into:

```text
src/
├── app.js
├── dom.js
├── tasks.js
├── validation.js
└── storage.js
```

Use:

```js
export function createTask() {
  // ...
}
```

and:

```js
import { createTask } from "./tasks.js";
```

Update HTML:

```html
<script
  type="module"
  src="./src/app.js"
></script>
```

---

## Challenge 10: Automated Tests

Write tests for:

- Valid task creation.
- Empty-title rejection.
- Task lookup.
- Task completion.
- Task removal.
- Missing task behavior.

Test template:

```js
function assertEqual(actual, expected, message) {
  if (actual !== expected) {
    throw new Error(
      `${message}: expected ${expected}, received ${actual}`
    );
  }
}
```

---

# Debugging Worksheet

## Error 1

**Error message:**

```text
____________________________________________________
```

**Error type:**

```text
____________________________________________________
```

**File and line:**

```text
____________________________________________________
```

**What I expected:**

```text
____________________________________________________
```

**What happened:**

```text
____________________________________________________
```

**Fix:**

```text
____________________________________________________
```

---

## Error 2

**Error message:**

```text
____________________________________________________
```

**Error type:**

```text
____________________________________________________
```

**File and line:**

```text
____________________________________________________
```

**What I expected:**

```text
____________________________________________________
```

**What happened:**

```text
____________________________________________________
```

**Fix:**

```text
____________________________________________________
```

---

## Logic Error

Describe one logic error you encountered.

```text
____________________________________________________

____________________________________________________

____________________________________________________
```

How did you discover it?

```text
____________________________________________________
```

---

# Reflection Questions

## Part 1

What is the difference between `const` and `let`?

```text
____________________________________________________

____________________________________________________
```

What is the difference between a primitive value and a reference value?

```text
____________________________________________________

____________________________________________________
```

---

## Part 2

What is the difference between a parameter and an argument?

```text
____________________________________________________

____________________________________________________
```

What does `return` do?

```text
____________________________________________________
```

What is scope?

```text
____________________________________________________

____________________________________________________
```

---

## Part 3

Why are arrays of objects useful for task applications?

```text
____________________________________________________

____________________________________________________
```

What does `indexOf` return when it cannot find a value?

```text
____________________________________________________
```

What is the difference between `find` and `findIndex`?

```text
____________________________________________________

____________________________________________________
```

---

## Part 4

What is the DOM?

```text
____________________________________________________

____________________________________________________
```

Why should user-provided task titles be inserted with `textContent`?

```text
____________________________________________________

____________________________________________________
```

What does `event.preventDefault()` do for a form?

```text
____________________________________________________

____________________________________________________
```

What is event delegation?

```text
____________________________________________________

____________________________________________________
```

---

# Final Skills Assessment

Rate your confidence from `1` to `5`.

| Skill | Rating |
|---|---:|
| Variables | ____ / 5 |
| Data types | ____ / 5 |
| Conditions | ____ / 5 |
| Loops | ____ / 5 |
| Functions | ____ / 5 |
| Scope | ____ / 5 |
| Arrays | ____ / 5 |
| Objects | ____ / 5 |
| DOM selection | ____ / 5 |
| DOM manipulation | ____ / 5 |
| Events | ____ / 5 |
| Forms | ____ / 5 |
| Event delegation | ____ / 5 |
| Debugging | ____ / 5 |
| Accessibility | ____ / 5 |
| Safe text rendering | ____ / 5 |

## Strongest Skill

```text
____________________________________________________

____________________________________________________
```

## Skill Needing More Practice

```text
____________________________________________________

____________________________________________________
```

## Next Feature I Will Build

```text
____________________________________________________

____________________________________________________
```

## Final Reflection

What can you now build with plain JavaScript that you could not build before this series?

```text
____________________________________________________

____________________________________________________

____________________________________________________

____________________________________________________
```

# Completion Statement

I completed the Beginning JavaScript Student Workbook.

**Name:** ______________________________________

**Date:** ______________________________________

**Signature:** __________________________________
