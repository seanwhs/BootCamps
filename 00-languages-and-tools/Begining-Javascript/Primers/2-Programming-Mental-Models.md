# Primer 2: Programming Mental Models

Programming becomes easier when you have a useful mental model—a simple way to picture what the code is doing.

You do not need to understand the computer’s hardware in detail before writing JavaScript. However, you do need to understand a few recurring ideas:

- Programs are instructions.
- Values represent information.
- Variables give values names.
- Expressions produce values.
- Statements perform actions.
- Conditions make decisions.
- Loops repeat work.
- Functions package reusable instructions.
- Data structures organize information.
- State represents the application’s current condition.

This primer introduces those ideas before the main JavaScript lessons.

---

# 1. Programs Are Instructions

## The Target

Understand a program as an ordered set of instructions.

## The Concept

A program is similar to a recipe.

A recipe might say:

```text
1. Get a bowl.
2. Add flour.
3. Add water.
4. Mix the ingredients.
5. Bake the result.
```

A JavaScript program also contains ordered instructions:

```js
const firstNumber = 4;
const secondNumber = 6;
const total = firstNumber + secondNumber;

console.log(total);
```

The browser generally executes these instructions from top to bottom.

## The Implementation

### `instructions.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Programming Instructions</title>
  </head>

  <body>
    <main>
      <h1>Programming instructions</h1>

      <p id="result">
        JavaScript has not run yet.
      </p>
    </main>

    <script src="./instructions.js" defer></script>
  </body>
</html>
```

### `instructions.js`

```js
"use strict";

const firstNumber = 4;
const secondNumber = 6;
const total = firstNumber + secondNumber;

const resultElement =
  document.querySelector("#result");

if (resultElement === null) {
  throw new Error("Could not find #result.");
}

resultElement.textContent =
  `The total is ${total}.`;

console.log("First number:", firstNumber);
console.log("Second number:", secondNumber);
console.log("Total:", total);
```

## The Verification

Open `instructions.html` through a local server.

The page should display:

```text
The total is 10.
```

The console should show:

```text
First number: 4
Second number: 6
Total: 10
```

Change:

```js
const firstNumber = 4;
```

to:

```js
const firstNumber = 20;
```

Refresh the page.

The result should become:

```text
The total is 26.
```

This demonstrates that changing an earlier instruction changes the later result.

[COMPLETED: Program-as-instructions model demonstrated]  
[NEXT: Values and types]

---

# 2. Values Represent Information

## The Target

Understand values as the information programs manipulate.

## The Concept

A value is a piece of information.

Examples:

```js
"Learn JavaScript"
42
true
null
```

Different values represent different kinds of information.

| Value | Meaning |
|---|---|
| `"Learn JavaScript"` | Text |
| `42` | Number |
| `true` | Boolean state |
| `null` | Intentional absence |
| `undefined` | Missing assigned value |

The program can calculate with numbers, combine strings, compare values, and make decisions from booleans.

## The Implementation

### `values.js`

```js
"use strict";

const taskTitle = "Learn JavaScript";
const estimatedMinutes = 30;
const isBeginnerFriendly = true;
const selectedTask = null;
let optionalDescription;

console.log("Task title:", taskTitle);
console.log("Estimated minutes:", estimatedMinutes);
console.log("Beginner friendly:", isBeginnerFriendly);
console.log("Selected task:", selectedTask);
console.log("Optional description:", optionalDescription);

console.log("Task title type:", typeof taskTitle);
console.log(
  "Estimated minutes type:",
  typeof estimatedMinutes
);
console.log(
  "Beginner-friendly type:",
  typeof isBeginnerFriendly
);
console.log(
  "Optional description type:",
  typeof optionalDescription
);
```

## The Verification

Load `values.js` from a simple HTML page or paste the code into the browser console.

Expected output:

```text
Task title: Learn JavaScript
Estimated minutes: 30
Beginner friendly: true
Selected task: null
Optional description: undefined
Task title type: string
Estimated minutes type: number
Beginner-friendly type: boolean
Optional description type: undefined
```

The important question is:

> What kind of information does this value represent?

That question helps you choose the correct operation.

[COMPLETED: Values and data types demonstrated]  
[NEXT: Variables as named references]

---

# 3. Variables Are Named References

## The Target

Understand variables as names attached to values.

## The Concept

A variable is like a labeled container or a name tag.

```js
const taskTitle = "Learn variables";
```

Conceptually:

```text
taskTitle ─────> "Learn variables"
```

The variable allows later code to refer to the value without rewriting it.

```js
console.log(taskTitle);
```

Variables also make programs easier to change. If the title changes in one declaration, every later use receives the new value.

## The Implementation

### `variables.js`

```js
"use strict";

const taskTitle = "Learn variables";
let completedTaskCount = 0;

completedTaskCount += 1;

console.log("Task title:", taskTitle);
console.log(
  "Completed task count:",
  completedTaskCount
);
```

## The Verification

Run the file.

Expected output:

```text
Task title: Learn variables
Completed task count: 1
```

Now change:

```js
completedTaskCount += 1;
```

to:

```js
completedTaskCount += 3;
```

Expected output:

```text
Completed task count: 3
```

Use `const` when the variable should not be reassigned:

```js
const applicationName = "Task List";
```

Use `let` when the value must change:

```js
let completedTaskCount = 0;
completedTaskCount += 1;
```

[COMPLETED: Variable mental model demonstrated]  
[NEXT: Expressions and statements]

---

# 4. Expressions Produce Values

## The Target

Understand the difference between an expression and a statement.

## The Concept

An **expression** is code that produces a value.

Examples:

```js
4 + 6
"Hello" + " world"
task.title
isCompleted
```

A **statement** is a complete instruction.

Examples:

```js
const total = 4 + 6;
console.log(total);
```

The right side of this assignment is an expression:

```js
4 + 6
```

The complete line is a statement:

```js
const total = 4 + 6;
```

A useful analogy:

```text
Expression → ingredient or result
Statement  → complete recipe instruction
```

## The Implementation

### `expressions.js`

```js
"use strict";

const firstNumber = 4;
const secondNumber = 6;

/*
  Each of these expressions produces a value.
*/
const additionResult = firstNumber + secondNumber;
const comparisonResult = firstNumber < secondNumber;
const greetingResult = "Hello, " + "JavaScript";

console.log("Addition:", additionResult);
console.log("Comparison:", comparisonResult);
console.log("Greeting:", greetingResult);
```

## The Verification

Expected output:

```text
Addition: 10
Comparison: true
Greeting: Hello, JavaScript
```

Try these expressions in the console:

```js
4 * 5
```

Expected:

```text
20
```

```js
10 > 3
```

Expected:

```text
true
```

```js
"Task".length
```

Expected:

```text
4
```

Each expression produces a value that another statement can use.

[COMPLETED: Expressions and statements demonstrated]  
[NEXT: Input, processing, and output]

---

# 5. Input, Processing, and Output

## The Target

Understand the basic data flow of most programs.

## The Concept

Many programs can be described with three stages:

```text
Input
    ↓
Processing
    ↓
Output
```

For the task application:

```text
Input:
user types a task title

Processing:
trim and validate the title

Output:
display the task in the list
```

This pattern appears everywhere:

- A calculator reads numbers and displays a result.
- A login form reads credentials and displays success or failure.
- A task application reads a title and displays a task.

## The Implementation

### `input-processing-output.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Input, Processing, and Output</title>
  </head>

  <body>
    <main>
      <h1>Task title processor</h1>

      <label for="task-title">
        Enter a task title
      </label>

      <input
        id="task-title"
        type="text"
      />

      <button
        id="process-button"
        type="button"
      >
        Process title
      </button>

      <p id="result"></p>
    </main>

    <script src="./input-processing-output.js" defer></script>
  </body>
</html>
```

### `input-processing-output.js`

```js
"use strict";

const taskTitleInputElement =
  document.querySelector("#task-title");

const processButtonElement =
  document.querySelector("#process-button");

const resultElement =
  document.querySelector("#result");

if (
  !(taskTitleInputElement instanceof HTMLInputElement)
) {
  throw new Error(
    "Could not find the task title input."
  );
}

if (
  !(processButtonElement instanceof HTMLButtonElement)
) {
  throw new Error(
    "Could not find the process button."
  );
}

if (resultElement === null) {
  throw new Error("Could not find the result element.");
}

processButtonElement.addEventListener(
  "click",
  () => {
    /*
      INPUT:
      Read the value typed by the user.
    */
    const rawTitle =
      taskTitleInputElement.value;

    /*
      PROCESSING:
      Remove unnecessary whitespace.
    */
    const cleanedTitle = rawTitle.trim();

    if (cleanedTitle.length === 0) {
      resultElement.textContent =
        "Enter a title before processing.";

      return;
    }

    /*
      OUTPUT:
      Display the processed result.
    */
    resultElement.textContent =
      `Processed title: ${cleanedTitle}`;
  }
);
```

## The Verification

Open the page.

Enter:

```text
   Practice input  	
```

Click **Process title**.

Expected result:

```text
Processed title: Practice input
```

Submit an empty input.

Expected result:

```text
Enter a title before processing.
```

[COMPLETED: Input-processing-output model demonstrated]  
[NEXT: Decisions and branching]

---

# 6. Conditions Are Decision Points

## The Target

Understand how programs choose between different paths.

## The Concept

A condition is a question with a true or false answer.

Examples:

```js
title.length === 0
task.completed
score >= 70
```

An `if` statement chooses what to do when a condition is true.

```js
if (title.length === 0) {
  showError();
}
```

An `else` branch handles the alternative:

```js
if (title.length === 0) {
  showError();
} else {
  createTask();
}
```

Think of a condition as a fork in a road:

```text
                condition
                /       \
             true       false
              ↓           ↓
          path A       path B
```

## The Implementation

### `decisions.js`

```js
"use strict";

function describeScore(score) {
  if (!Number.isFinite(score)) {
    return "Score must be a number.";
  }

  if (score >= 90) {
    return "Excellent.";
  }

  if (score >= 70) {
    return "Good work.";
  }

  if (score >= 50) {
    return "Keep practicing.";
  }

  return "Start with the fundamentals.";
}

const scores = [95, 74, 53, 32];

for (const score of scores) {
  console.log(score, describeScore(score));
}
```

## The Verification

Expected output:

```text
95 Excellent.
74 Good work.
53 Keep practicing.
32 Start with the fundamentals.
```

Notice that each input follows one path through the conditions.

[COMPLETED: Conditional branching demonstrated]  
[NEXT: Repetition and loops]

---

# 7. Loops Repeat Work

## The Target

Understand loops as controlled repetition.

## The Concept

A loop says:

> Perform this operation repeatedly while a rule remains satisfied.

Without a loop:

```js
console.log("variables");
console.log("functions");
console.log("arrays");
console.log("objects");
```

With a loop:

```js
const topics = [
  "variables",
  "functions",
  "arrays",
  "objects"
];

for (const topic of topics) {
  console.log(topic);
}
```

The loop gives one instruction a collection of values.

## The Implementation

### `loops.js`

```js
"use strict";

const tasks = [
  {
    title: "Learn variables",
    completed: true
  },
  {
    title: "Practice functions",
    completed: false
  },
  {
    title: "Build a DOM feature",
    completed: false
  }
];

let completedCount = 0;

for (const task of tasks) {
  const state = task.completed
    ? "complete"
    : "incomplete";

  console.log(
    `${task.title}: ${state}`
  );

  if (task.completed) {
    completedCount += 1;
  }
}

console.log(
  `Completed tasks: ${completedCount}`
);
```

## The Verification

Expected output:

```text
Learn variables: complete
Practice functions: incomplete
Build a DOM feature: incomplete
Completed tasks: 1
```

A loop combines two ideas:

```text
collection of data
    +
repeated operation
```

[COMPLETED: Loop repetition model demonstrated]  
[NEXT: Functions as reusable recipes]

---

# 8. Functions Are Reusable Recipes

## The Target

Understand functions as named, reusable operations.

## The Concept

A function is like a recipe with:

- A name.
- Ingredients, called parameters.
- Instructions.
- A possible result.

```js
function createTask(title) {
  return {
    title,
    completed: false
  };
}
```

The function does not run when it is defined. It runs when called:

```js
const task = createTask("Learn functions");
```

Functions prevent duplicated code.

## The Implementation

### `functions.js`

```js
"use strict";

function cleanTaskTitle(rawTitle) {
  return rawTitle.trim();
}

function isValidTaskTitle(title) {
  return title.length > 0;
}

function createTask(title, id) {
  return {
    id,
    title,
    completed: false
  };
}

const rawTitle =
  "  Learn reusable functions  ";

const cleanedTitle =
  cleanTaskTitle(rawTitle);

if (!isValidTaskTitle(cleanedTitle)) {
  throw new Error(
    "The task title cannot be empty."
  );
}

const task =
  createTask(cleanedTitle, 1);

console.log(task);
```

## The Verification

Expected console output:

```text
{
  id: 1,
  title: "Learn reusable functions",
  completed: false
}
```

Each function has one primary responsibility:

```text
cleanTaskTitle   → cleans text
isValidTaskTitle → checks text
createTask       → creates task data
```

[COMPLETED: Function-as-recipe model demonstrated]  
[NEXT: Data structures as organized storage]

---

# 9. Data Structures Organize Information

## The Target

Understand why the task application uses arrays and objects together.

## The Concept

An object is like an information card with named fields:

```js
const task = {
  id: 1,
  title: "Learn objects",
  completed: false
};
```

An array is like a row of numbered cards:

```js
const tasks = [
  taskOne,
  taskTwo,
  taskThree
];
```

Together:

```text
Array
│
├── Object: task 1
├── Object: task 2
└── Object: task 3
```

This structure is more useful than storing separate, unrelated arrays:

```js
const taskTitles = [
  "Learn objects",
  "Practice arrays"
];

const taskStates = [
  false,
  true
];
```

The separate-array version requires keeping positions synchronized. An array of objects keeps each task’s information together.

## The Implementation

### `data-structures.js`

```js
"use strict";

const tasks = [
  {
    id: 1,
    title: "Learn arrays",
    completed: true
  },
  {
    id: 2,
    title: "Learn objects",
    completed: false
  },
  {
    id: 3,
    title: "Combine arrays and objects",
    completed: false
  }
];

for (const task of tasks) {
  console.log({
    id: task.id,
    title: task.title,
    completed: task.completed
  });
}
```

## The Verification

Expected output should contain three task objects.

Change the second task:

```js
completed: false
```

to:

```js
completed: true
```

Run the file again.

Both the first and second tasks should now report:

```text
completed: true
```

[COMPLETED: Data-structure model demonstrated]  
[NEXT: State and change over time]

---

# 10. State Represents the Current Condition

## The Target

Understand application state.

## The Concept

**State** is the information that describes what an application currently knows.

For the task application, state includes:

```js
const tasks = [];
```

When the user adds a task, state changes:

```js
tasks.push(task);
```

When the user completes a task, state changes:

```js
task.completed = true;
```

The page should display the current state.

Think of state as a scoreboard:

```text
Before action:
0 tasks

User adds a task

After action:
1 task
```

The application must update both:

```text
data state
visible interface
```

## The Implementation

### `state.js`

```js
"use strict";

const tasks = [];

function describeState() {
  return {
    taskCount: tasks.length,
    completedCount: tasks.filter(
      (task) => task.completed
    ).length
  };
}

console.log("Initial state:", describeState());

tasks.push({
  id: 1,
  title: "Learn application state",
  completed: false
});

console.log("After adding task:", describeState());

tasks[0].completed = true;

console.log(
  "After completing task:",
  describeState()
);
```

## The Verification

Expected output:

```text
Initial state: { taskCount: 0, completedCount: 0 }
After adding task: { taskCount: 1, completedCount: 0 }
After completing task: { taskCount: 1, completedCount: 1 }
```

The data changes over time. That changing data is state.

[COMPLETED: Application-state model demonstrated]  
[NEXT: Rendering state]

---

# 11. Rendering Converts State into Interface

## The Target

Understand rendering as a translation from data to DOM.

## The Concept

Rendering means taking the current state and creating the visible representation.

State:

```js
const task = {
  title: "Learn rendering",
  completed: false
};
```

Rendered interface:

```html
<li>Learn rendering</li>
```

When the state changes:

```js
task.completed = true;
```

the interface should also change:

```html
<li class="task-item--completed">
  Learn rendering
</li>
```

## The Implementation

### `rendering.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Rendering Mental Model</title>

    <style>
      .completed {
        color: #667085;
        text-decoration: line-through;
      }
    </style>
  </head>

  <body>
    <main>
      <h1>Tasks</h1>

      <ul id="task-list"></ul>
    </main>

    <script src="./rendering.js" defer></script>
  </body>
</html>
```

### `rendering.js`

```js
"use strict";

const taskListElement =
  document.querySelector("#task-list");

if (taskListElement === null) {
  throw new Error(
    "Could not find the task list."
  );
}

const tasks = [
  {
    id: 1,
    title: "Learn rendering",
    completed: false
  },
  {
    id: 2,
    title: "Practice DOM updates",
    completed: true
  }
];

function renderTasks(tasks) {
  taskListElement.replaceChildren();

  for (const task of tasks) {
    const listItemElement =
      document.createElement("li");

    listItemElement.textContent = task.title;

    if (task.completed) {
      listItemElement.classList.add(
        "completed"
      );
    }

    taskListElement.append(listItemElement);
  }
}

renderTasks(tasks);
```

## The Verification

Open `rendering.html`.

The page should display:

- `Learn rendering` without a strikethrough.
- `Practice DOM updates` with a strikethrough.

Now change:

```js
completed: false
```

for the first task to:

```js
completed: true
```

Refresh the page.

The first task should now also appear completed.

[COMPLETED: State-to-interface rendering demonstrated]  
[NEXT: Pure transformations and side effects]

---

# 12. Pure Work Versus Side Effects

## The Target

Understand the difference between calculating a result and changing the outside world.

## The Concept

A **pure function**:

- Returns a result.
- Does not change outside data.
- Produces the same result for the same input.

```js
function add(firstNumber, secondNumber) {
  return firstNumber + secondNumber;
}
```

A **side effect** changes something outside the function.

Examples:

- Updating the DOM.
- Writing to `localStorage`.
- Logging to the console.
- Changing a shared array.
- Sending a network request.

Pure function:

```js
function getTaskLabel(count) {
  return count === 1
    ? "task"
    : "tasks";
}
```

Side effect:

```js
function updateMessage(message) {
  messageElement.textContent = message;
}
```

Separating pure calculations from side effects makes code easier to test.

## The Implementation

### `pure-and-impure.js`

```js
"use strict";

function countCompletedTasks(tasks) {
  return tasks.filter(
    (task) => task.completed
  ).length;
}

function getTaskSummary(tasks) {
  const completedCount =
    countCompletedTasks(tasks);

  return {
    total: tasks.length,
    completed: completedCount,
    active: tasks.length - completedCount
  };
}

const tasks = [
  {
    id: 1,
    title: "Read",
    completed: true
  },
  {
    id: 2,
    title: "Practice",
    completed: false
  }
];

const summary = getTaskSummary(tasks);

console.log(summary);
```

## The Verification

Expected output:

```text
{
  total: 2,
  completed: 1,
  active: 1
}
```

The functions calculate values but do not update the DOM or change the `tasks` array.

[COMPLETED: Pure-function and side-effect model demonstrated]  
[NEXT: Putting the models together]

---

# 13. Putting the Models Together

## The Target

Combine:

- Input.
- Processing.
- State.
- Rendering.
- Events.
- Output.

## The Concept

A small interactive application follows this cycle:

```text
1. Start with state.
2. Render the state.
3. Wait for an event.
4. Read input.
5. Validate and process input.
6. Update state.
7. Render the new state.
```

This is the central mental model for the task application.

## The Implementation

### `mental-model-task-list.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>Mental Model Task List</title>

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
        margin-block: 0.75rem;
      }

      .task-item--completed {
        color: #667085;
        text-decoration: line-through;
      }
    </style>
  </head>

  <body>
    <main>
      <h1>Task list</h1>

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

    <script src="./mental-model-task-list.js" defer></script>
  </body>
</html>
```

### `mental-model-task-list.js`

```js
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
    "Could not find the task form."
  );
}

if (
  !(taskTitleInputElement
    instanceof HTMLInputElement)
) {
  throw new Error(
    "Could not find the task title input."
  );
}

if (messageElement === null) {
  throw new Error(
    "Could not find the message element."
  );
}

if (taskListElement === null) {
  throw new Error(
    "Could not find the task list."
  );
}

/*
  STATE
*/
const tasks = [];
let nextTaskId = 1;

/*
  PROCESSING
*/
function createTask(title) {
  return {
    id: nextTaskId,
    title,
    completed: false
  };
}

/*
  RENDERING
*/
function renderTasks() {
  taskListElement.replaceChildren();

  for (const task of tasks) {
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

        messageElement.textContent =
          task.completed
            ? `Completed ${task.title}.`
            : `Reopened ${task.title}.`;
      }
    );

    listItemElement.append(
      titleElement,
      completeButtonElement
    );

    taskListElement.append(listItemElement);
  }
}

/*
  INPUT EVENT
*/
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
      `Added ${task.title}.`;

    taskFormElement.reset();
    taskTitleInputElement.focus();
  }
);

/*
  INITIAL OUTPUT
*/
renderTasks();
```

## The Verification

Test the complete flow:

1. Open the page.
2. Confirm the initial list is empty.
3. Enter a task title.
4. Submit the form.
5. Confirm the task appears.
6. Click **Complete**.
7. Confirm the visual state changes.
8. Click **Undo**.
9. Confirm the visual state returns.
10. Submit an empty form.
11. Confirm that the error message appears.

[COMPLETED: Complete programming mental model demonstrated]  
[NEXT: Primer 2 summary]

---

# 14. A Practical Way to Read Any Small Program

When you encounter unfamiliar JavaScript, ask these questions in order.

## Question 1: What data exists?

Look for:

```js
const tasks = [];
const selectedTask = null;
const userName = "Amina";
```

Identify the values and their types.

## Question 2: What can change?

Look for:

```js
let nextTaskId = 1;
task.completed = true;
tasks.push(task);
```

These lines indicate changing state.

## Question 3: What functions exist?

List their responsibilities:

```text
createTask       → creates data
renderTasks      → updates the DOM
validateTitle    → checks input
handleSubmit     → coordinates form submission
```

## Question 4: What events start behavior?

Look for:

```js
addEventListener("click", ...)
addEventListener("submit", ...)
addEventListener("input", ...)
```

## Question 5: Where does the DOM change?

Look for:

```js
textContent
classList
append
remove
replaceChildren
```

## Question 6: What is the data flow?

Write it in plain language:

```text
Form submission
    ↓
Read title
    ↓
Trim title
    ↓
Reject empty title
    ↓
Create task
    ↓
Push task into array
    ↓
Render tasks
```

This technique turns a large file into a sequence of understandable operations.

---

# 15. Primer 2 Summary

The most important mental models are:

## Programs

```text
Ordered instructions
```

## Values

```text
Information manipulated by the program
```

## Variables

```text
Names attached to values
```

## Expressions

```text
Code that produces values
```

## Statements

```text
Complete instructions
```

## Conditions

```text
Decision points
```

## Loops

```text
Controlled repetition
```

## Functions

```text
Reusable recipes
```

## Arrays and objects

```text
Organized storage for data
```

## State

```text
What the application currently knows
```

## Rendering

```text
Converting state into visible interface output
```

## Events

```text
Notifications that something happened
```

## The full application cycle

```text
User action
    ↓
Event handler
    ↓
Input
    ↓
Processing
    ↓
State update
    ↓
Rendering
    ↓
Visible output
```

Keep this cycle in mind throughout the series. Every feature in the task application will be an expansion of this basic pattern.
