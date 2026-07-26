# Part 3: Data Structures in Practice

In the previous part, functions gave our code reusable behavior. Now we need a reliable way to store the information those functions operate on.

A **data structure** is an organized way to store data. Two of the most important JavaScript data structures are:

- **Arrays** — ordered collections of values.
- **Objects** — collections of named properties.

Our task application will use both:

```text
tasks array
│
├── task object
│   ├── id
│   ├── title
│   └── completed
│
├── task object
│   ├── id
│   ├── title
│   └── completed
│
└── task object
    ├── id
    ├── title
    └── completed
```

By the end of this part, you will be able to:

- Create and inspect arrays.
- Read array values by index.
- Add and remove array items.
- Traverse arrays.
- Use `push`, `pop`, `shift`, `slice`, and `indexOf`.
- Create object literals.
- Read and update object properties.
- Use dot notation and bracket notation.
- Use dynamic property keys.
- Store objects inside arrays.
- Build and update a collection of tasks.

[COMPLETED: Part 3 introduction]  
[STARTING: Step 1 — Prepare the Part 3 page]

---

# Step 1: Prepare the Part 3 Page

## The Target

We will update the project page so it loads:

```text
src/part-3.js
```

The page will continue using the existing output elements.

## The Concept

The HTML page provides a display area. JavaScript will populate that area with examples and task data.

Keeping the same element IDs gives the JavaScript a stable interface:

```text
#status-message  → short status
#results-output  → detailed output
```

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

    <title>JavaScript Foundations — Part 3</title>
  </head>

  <body>
    <main>
      <h1>JavaScript Foundations: Part 3</h1>

      <p>
        This page demonstrates arrays, objects, and task data.
      </p>

      <section aria-labelledby="status-heading">
        <h2 id="status-heading">Program status</h2>

        <p id="status-message">
          JavaScript has not run yet.
        </p>
      </section>

      <section aria-labelledby="results-heading">
        <h2 id="results-heading">Results</h2>

        <pre id="results-output">No results yet.</pre>
      </section>
    </main>

    <script src="./src/part-3.js" defer></script>
  </body>
</html>
```

## The Verification

Confirm that:

- `index.html` exists in the project root.
- The script path is exactly:

```html
<script src="./src/part-3.js" defer></script>
```

The JavaScript file does not exist yet, so the browser may display a file-loading error. That is expected.

[COMPLETED: Step 1 — Part 3 page prepared]  
[STARTING: Step 2 — Create the Part 3 entry point]

---

# Step 2: Create the Part 3 Entry Point

## The Target

We will create:

```text
src/part-3.js
```

The file will locate the output elements and prove that the script loaded.

## The Concept

Before working with arrays and objects, verify the connection between HTML and JavaScript. This gives us a known-good starting point.

## The Implementation

### `src/part-3.js`

```js
"use strict";

const statusMessageElement = document.querySelector("#status-message");
const resultsOutputElement = document.querySelector("#results-output");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

if (resultsOutputElement === null) {
  throw new Error("Could not find the #results-output element.");
}

statusMessageElement.textContent =
  "Part 3 JavaScript is running successfully.";

resultsOutputElement.textContent =
  "The data structures laboratory is ready.";

console.log("Part 3 JavaScript loaded successfully.");
```

## The Verification

Refresh the browser.

Expected page output:

```text
Part 3 JavaScript is running successfully.
```

and:

```text
The data structures laboratory is ready.
```

Expected console output:

```text
Part 3 JavaScript loaded successfully.
```

[COMPLETED: Step 2 — Part 3 entry point verified]  
[STARTING: Step 3 — Creating and reading arrays]

---

# Step 3: Creating and Reading Arrays

## The Target

We will create an array and read values from it by index.

## The Concept

An array is like a row of numbered storage compartments.

```text
Index:  0          1          2
Value: "Read"    "Write"    "Test"
```

JavaScript arrays are **zero-indexed**, meaning the first value is at index `0`.

## The Implementation

Replace `src/part-3.js` with:

### `src/part-3.js`

```js
"use strict";

const statusMessageElement = document.querySelector("#status-message");
const resultsOutputElement = document.querySelector("#results-output");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

if (resultsOutputElement === null) {
  throw new Error("Could not find the #results-output element.");
}

const learningTopics = [
  "variables",
  "functions",
  "arrays",
  "objects"
];

const firstTopic = learningTopics[0];
const secondTopic = learningTopics[1];
const lastTopic =
  learningTopics[learningTopics.length - 1];

const results = [
  `Number of topics: ${learningTopics.length}`,
  `First topic: ${firstTopic}`,
  `Second topic: ${secondTopic}`,
  `Last topic: ${lastTopic}`,
  `Missing index: ${learningTopics[99]}`
];

statusMessageElement.textContent =
  "Array creation and indexing are working.";

resultsOutputElement.textContent = results.join("\n");

console.log("Learning topics:", learningTopics);
```

## The Verification

Refresh the browser.

You should see:

```text
Number of topics: 4
First topic: variables
Second topic: functions
Last topic: objects
Missing index: undefined
```

The `length` property tells us how many items exist.

The last index is always:

```js
array.length - 1
```

For four items:

```text
length: 4
last index: 3
```

[COMPLETED: Step 3 — Array creation and indexing verified]  
[STARTING: Step 4 — Adding and removing array values]

---

# Step 4: `push`, `pop`, `shift`, and `unshift`

## The Target

We will add and remove items from the beginning and end of an array.

## The Concept

Imagine an array as a line of people:

```text
front → Alice, Bob, Carol ← back
```

- `push` adds to the back.
- `pop` removes from the back.
- `unshift` adds to the front.
- `shift` removes from the front.

These methods change the original array. This is called **mutation**.

## The Implementation

Replace `src/part-3.js` with:

### `src/part-3.js`

```js
"use strict";

const statusMessageElement = document.querySelector("#status-message");
const resultsOutputElement = document.querySelector("#results-output");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

if (resultsOutputElement === null) {
  throw new Error("Could not find the #results-output element.");
}

const actionLog = [];

actionLog.push("Opened application");

actionLog.push("Created task");

const removedLastAction = actionLog.pop();

actionLog.unshift("Loaded user preferences");

const removedFirstAction = actionLog.shift();

const results = [
  `Remaining actions: ${actionLog.join(" | ")}`,
  `Removed from end: ${removedLastAction}`,
  `Removed from beginning: ${removedFirstAction}`,
  `Final array length: ${actionLog.length}`
];

statusMessageElement.textContent =
  "Array insertion and removal are working.";

resultsOutputElement.textContent = results.join("\n");

console.log("Final action log:", actionLog);
```

## The Verification

Refresh the browser.

Expected output:

```text
Remaining actions: Created task
Removed from end: Created task
Removed from beginning: Loaded user preferences
Final array length: 1
```

Notice that:

```js
push()
pop()
shift()
unshift()
```

all modify the original array.

[COMPLETED: Step 4 — Array insertion and removal verified]  
[STARTING: Step 5 — Copying portions with slice]

---

# Step 5: The `slice` Method

## The Target

We will copy part of an array without changing the original array.

## The Concept

`slice` is like photocopying selected pages from a book. The original book remains unchanged.

```js
array.slice(startIndex, endIndex)
```

The starting index is included. The ending index is excluded.

```js
const values = ["a", "b", "c", "d"];

values.slice(1, 3);
```

Result:

```text
["b", "c"]
```

Index `1` is included, but index `3` is not.

## The Implementation

Replace `src/part-3.js` with:

### `src/part-3.js`

```js
"use strict";

const statusMessageElement = document.querySelector("#status-message");
const resultsOutputElement = document.querySelector("#results-output");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

if (resultsOutputElement === null) {
  throw new Error("Could not find the #results-output element.");
}

const allTopics = [
  "variables",
  "functions",
  "arrays",
  "objects",
  "dom"
];

const middleTopics = allTopics.slice(1, 4);
const firstTwoTopics = allTopics.slice(0, 2);
const finalTopics = allTopics.slice(3);

const results = [
  `All topics: ${allTopics.join(", ")}`,
  `Middle topics: ${middleTopics.join(", ")}`,
  `First two topics: ${firstTwoTopics.join(", ")}`,
  `Final topics: ${finalTopics.join(", ")}`,
  `Original length: ${allTopics.length}`
];

statusMessageElement.textContent =
  "Array slicing is working.";

resultsOutputElement.textContent = results.join("\n");

console.log("Original topics:", allTopics);
console.log("Middle topics:", middleTopics);
```

## The Verification

Refresh the browser.

Expected output:

```text
All topics: variables, functions, arrays, objects, dom
Middle topics: functions, arrays, objects
First two topics: variables, functions
Final topics: objects, dom
Original length: 5
```

The original array remains unchanged.

[COMPLETED: Step 5 — `slice` verified]  
[STARTING: Step 6 — Finding values with indexOf]

---

# Step 6: The `indexOf` Method

## The Target

We will find the position of a value in an array.

## The Concept

`indexOf` asks:

> At which index does this exact value appear?

If the value is not found, it returns `-1`.

```js
const topics = ["variables", "functions"];

topics.indexOf("functions"); // 1
topics.indexOf("objects");   // -1
```

Use strict matching mentally: `"1"` and `1` are different values.

## The Implementation

Replace `src/part-3.js` with:

### `src/part-3.js`

```js
"use strict";

const statusMessageElement = document.querySelector("#status-message");
const resultsOutputElement = document.querySelector("#results-output");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

if (resultsOutputElement === null) {
  throw new Error("Could not find the #results-output element.");
}

const topics = [
  "variables",
  "functions",
  "arrays",
  "objects"
];

const functionsIndex = topics.indexOf("functions");
const missingTopicIndex = topics.indexOf("dom");

const hasFunctionsTopic = functionsIndex !== -1;
const hasDomTopic = missingTopicIndex !== -1;

const results = [
  `"functions" index: ${functionsIndex}`,
  `"dom" index: ${missingTopicIndex}`,
  `Has functions topic: ${hasFunctionsTopic}`,
  `Has dom topic: ${hasDomTopic}`
];

statusMessageElement.textContent =
  "Array searching is working.";

resultsOutputElement.textContent = results.join("\n");

console.log("Functions index:", functionsIndex);
console.log("Missing topic index:", missingTopicIndex);
```

## The Verification

Refresh the browser.

Expected output:

```text
"functions" index: 1
"dom" index: -1
Has functions topic: true
Has dom topic: false
```

Do not write:

```js
if (topics.indexOf("dom")) {
  // incorrect
}
```

Because `indexOf` returns `0` for a value at the first position, and `0` is falsy.

Use:

```js
if (topics.indexOf("dom") !== -1) {
  // correct
}
```

[COMPLETED: Step 6 — `indexOf` verified]  
[STARTING: Step 7 — Creating objects]

---

# Step 7: Object Literals

## The Target

We will create objects representing individual tasks.

## The Concept

An object is like a labeled information card. Each property has:

- A key, also called a property name.
- A value.

```js
const task = {
  id: 1,
  title: "Learn objects",
  completed: false
};
```

The object groups related information together.

## The Implementation

Replace `src/part-3.js` with:

### `src/part-3.js`

```js
"use strict";

const statusMessageElement = document.querySelector("#status-message");
const resultsOutputElement = document.querySelector("#results-output");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

if (resultsOutputElement === null) {
  throw new Error("Could not find the #results-output element.");
}

const task = {
  id: 1,
  title: "Learn object literals",
  completed: false,
  priority: "high"
};

const results = [
  `Task id: ${task.id}`,
  `Task title: ${task.title}`,
  `Completed: ${task.completed}`,
  `Priority: ${task.priority}`
];

statusMessageElement.textContent =
  "Object literals are working.";

resultsOutputElement.textContent = results.join("\n");

console.log("Task object:", task);
```

## The Verification

Refresh the browser.

Expected output:

```text
Task id: 1
Task title: Learn object literals
Completed: false
Priority: high
```

The object can be inspected in the console:

```text
{
  id: 1,
  title: "Learn object literals",
  completed: false,
  priority: "high"
}
```

[COMPLETED: Step 7 — Object literals verified]  
[STARTING: Step 8 — Dot notation and bracket notation]

---

# Step 8: Accessing and Updating Object Properties

## The Target

We will read and update object properties using:

- Dot notation.
- Bracket notation.

## The Concept

Dot notation is convenient when the property name is known:

```js
task.title
```

Bracket notation is useful when:

- The property name contains unusual characters.
- The property name is stored in a variable.
- The property name is dynamic.

```js
const propertyName = "title";
task[propertyName];
```

These access the same property:

```js
task.title
task["title"]
```

## The Implementation

Replace `src/part-3.js` with:

### `src/part-3.js`

```js
"use strict";

const statusMessageElement = document.querySelector("#status-message");
const resultsOutputElement = document.querySelector("#results-output");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

if (resultsOutputElement === null) {
  throw new Error("Could not find the #results-output element.");
}

const task = {
  id: 1,
  title: "Learn object properties",
  completed: false
};

const titleUsingDotNotation = task.title;
const titleUsingBracketNotation = task["title"];

task.completed = true;

const propertyToRead = "id";
const dynamicId = task[propertyToRead];

const results = [
  `Title with dot notation: ${titleUsingDotNotation}`,
  `Title with bracket notation: ${titleUsingBracketNotation}`,
  `Updated completed value: ${task.completed}`,
  `Dynamic property value: ${dynamicId}`
];

statusMessageElement.textContent =
  "Object property access is working.";

resultsOutputElement.textContent = results.join("\n");

console.log("Updated task:", task);
```

## The Verification

Refresh the browser.

Expected output:

```text
Title with dot notation: Learn object properties
Title with bracket notation: Learn object properties
Updated completed value: true
Dynamic property value: 1
```

This does not read the property named by the variable:

```js
task.propertyToRead
```

It looks for a property literally called `propertyToRead`.

Use:

```js
task[propertyToRead]
```

to use the variable’s value.

[COMPLETED: Step 8 — Object property access verified]  
[STARTING: Step 9 — Dynamic keys]

---

# Step 9: Dynamic Property Keys

## The Target

We will create object properties using computed, dynamic keys.

## The Concept

Sometimes the property name is not known until the program runs.

For example, a settings object may use a selected category:

```js
const selectedCategory = "theme";

const setting = {
  [selectedCategory]: "dark"
};
```

The brackets tell JavaScript to evaluate the expression and use its result as the property name.

Without brackets:

```js
const setting = {
  selectedCategory: "dark"
};
```

the property would literally be named `"selectedCategory"`.

## The Implementation

Replace `src/part-3.js` with:

### `src/part-3.js`

```js
"use strict";

const statusMessageElement = document.querySelector("#status-message");
const resultsOutputElement = document.querySelector("#results-output");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

if (resultsOutputElement === null) {
  throw new Error("Could not find the #results-output element.");
}

const selectedCategory = "work";
const categoryValue = "Study JavaScript";

const categorizedTask = {
  id: 1,
  title: "Organize dynamic data",
  [selectedCategory]: categoryValue
};

const results = [
  `Category key: ${selectedCategory}`,
  `Category value: ${categorizedTask[selectedCategory]}`,
  `Direct dynamic access: ${categorizedTask.work}`
];

statusMessageElement.textContent =
  "Dynamic object keys are working.";

resultsOutputElement.textContent = results.join("\n");

console.log("Categorized task:", categorizedTask);
```

## The Verification

Refresh the browser.

Expected output:

```text
Category key: work
Category value: Study JavaScript
Direct dynamic access: Study JavaScript
```

The object contains:

```js
{
  id: 1,
  title: "Organize dynamic data",
  work: "Study JavaScript"
}
```

[COMPLETED: Step 9 — Dynamic keys verified]  
[STARTING: Step 10 — Arrays of objects]

---

# Step 10: Arrays of Objects

## The Target

We will store multiple task objects in one array.

## The Concept

An array gives us order. Objects give each task named fields.

Together, they represent a task collection:

```js
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
  }
];
```

This is the primary data shape for the application.

## The Implementation

Replace `src/part-3.js` with:

### `src/part-3.js`

```js
"use strict";

const statusMessageElement = document.querySelector("#status-message");
const resultsOutputElement = document.querySelector("#results-output");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

if (resultsOutputElement === null) {
  throw new Error("Could not find the #results-output element.");
}

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

const taskLines = [];

for (const task of tasks) {
  const state = task.completed
    ? "complete"
    : "incomplete";

  taskLines.push(
    `${task.id}. ${task.title} — ${state}`
  );
}

statusMessageElement.textContent =
  "Arrays of objects are working.";

resultsOutputElement.textContent = taskLines.join("\n");

console.log("Task collection:", tasks);
```

## The Verification

Refresh the browser.

Expected output:

```text
1. Learn arrays — complete
2. Learn objects — incomplete
3. Combine arrays and objects — incomplete
```

[COMPLETED: Step 10 — Arrays of objects verified]  
[STARTING: Step 11 — Updating and removing objects in arrays]

---

# Step 11: Updating and Removing Task Data

## The Target

We will:

- Find a task by ID.
- Update its completion state.
- Remove an item using `splice`.

## The Concept

An array stores position. Each object stores identity through its `id`.

To update one task:

1. Find the task.
2. Change its property.

To remove one task:

1. Find its index.
2. Remove the item at that index.

`splice` mutates the original array:

```js
array.splice(startIndex, deleteCount)
```

## The Implementation

Replace `src/part-3.js` with:

### `src/part-3.js`

```js
"use strict";

const statusMessageElement = document.querySelector("#status-message");
const resultsOutputElement = document.querySelector("#results-output");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

if (resultsOutputElement === null) {
  throw new Error("Could not find the #results-output element.");
}

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
    title: "Practice task updates",
    completed: false
  }
];

const taskToComplete = tasks.find((task) => task.id === 2);

if (taskToComplete === undefined) {
  throw new Error("Could not find task with id 2.");
}

taskToComplete.completed = true;

const taskToRemoveIndex = tasks.findIndex(
  (task) => task.id === 1
);

if (taskToRemoveIndex === -1) {
  throw new Error("Could not find task with id 1.");
}

const removedTasks = tasks.splice(taskToRemoveIndex, 1);

const taskLines = [];

for (const task of tasks) {
  const state = task.completed
    ? "complete"
    : "incomplete";

  taskLines.push(
    `${task.id}. ${task.title} — ${state}`
  );
}

const removedTaskTitle =
  removedTasks[0]?.title ?? "No task removed.";

statusMessageElement.textContent =
  "Task updates and removal are working.";

resultsOutputElement.textContent = [
  `Removed task: ${removedTaskTitle}`,
  ...taskLines
].join("\n");

console.log("Remaining tasks:", tasks);
```

## The Verification

Refresh the browser.

Expected output:

```text
Removed task: Learn arrays
2. Learn objects — complete
3. Practice task updates — incomplete
```

`find` returns an object or `undefined`.

`findIndex` returns an index or `-1`.

The optional chaining expression:

```js
removedTasks[0]?.title
```

safely accesses `title` if an object exists.

The nullish coalescing operator:

```js
?? "No task removed."
```

uses the fallback only when the left side is `null` or `undefined`.

[COMPLETED: Step 11 — Task mutation and removal verified]  
[STARTING: Step 12 — Building reusable data functions]

---

# Step 12: Reusable Array and Object Functions

## The Target

We will create functions for common task operations:

- Creating tasks.
- Finding tasks.
- Completing tasks.
- Removing tasks.
- Describing tasks.

## The Concept

Data should not be modified randomly throughout the program. Small, named functions make changes predictable.

These functions form a simple data-management layer:

```text
createTask
findTaskById
completeTask
removeTaskById
describeTask
```

The functions operate on the task array but keep each responsibility clear.

## The Implementation

Replace `src/part-3.js` with:

### `src/part-3.js`

```js
"use strict";

const statusMessageElement = document.querySelector("#status-message");
const resultsOutputElement = document.querySelector("#results-output");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

if (resultsOutputElement === null) {
  throw new Error("Could not find the #results-output element.");
}

function createTask(title, id) {
  if (typeof title !== "string") {
    throw new TypeError("Task title must be a string.");
  }

  const cleanedTitle = title.trim();

  if (cleanedTitle.length === 0) {
    throw new Error("Task title cannot be empty.");
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

function completeTask(tasks, taskId) {
  const task = findTaskById(tasks, taskId);

  if (task === undefined) {
    return false;
  }

  task.completed = true;
  return true;
}

function removeTaskById(tasks, taskId) {
  const index = tasks.findIndex(
    (task) => task.id === taskId
  );

  if (index === -1) {
    return false;
  }

  tasks.splice(index, 1);
  return true;
}

function describeTask(task) {
  const state = task.completed
    ? "complete"
    : "incomplete";

  return `${task.id}. ${task.title} — ${state}`;
}

const tasks = [
  createTask("Learn arrays", 1),
  createTask("Learn objects", 2),
  createTask("Build task data", 3)
];

completeTask(tasks, 2);
removeTaskById(tasks, 1);

const taskLines = [];

for (const task of tasks) {
  taskLines.push(describeTask(task));
}

statusMessageElement.textContent =
  "Reusable data functions are working.";

resultsOutputElement.textContent = taskLines.join("\n");

console.log("Managed tasks:", tasks);
```

## The Verification

Refresh the browser.

Expected output:

```text
2. Learn objects — complete
3. Build task data — incomplete
```

The first task was removed. The second task was completed. The third task remains incomplete.

[COMPLETED: Step 12 — Reusable data functions verified]  
[STARTING: Step 13 — Complete Part 3 implementation]

---

# Step 13: Complete Part 3 File

## The Target

We will consolidate the complete Part 3 implementation into one working file.

## The Concept

This final file separates the application’s data responsibilities into functions:

```text
Validation
    ↓
Task creation
    ↓
Task collection
    ↓
Task updates
    ↓
Task descriptions
```

This is not yet a browser interface. That comes in Part 4. For now, we are building and testing the data layer that the interface will use.

## The Implementation

### `src/part-3.js`

```js
"use strict";

/*
  Part 3 demonstrates:

  - Array creation
  - Array indexing
  - Array length
  - push
  - pop
  - shift
  - unshift
  - slice
  - indexOf
  - Objects
  - Dot notation
  - Bracket notation
  - Dynamic keys
  - Arrays of objects
  - find
  - findIndex
  - splice
  - Reusable task-data functions
*/

const statusMessageElement = document.querySelector("#status-message");
const resultsOutputElement = document.querySelector("#results-output");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

if (resultsOutputElement === null) {
  throw new Error("Could not find the #results-output element.");
}

/*
  ARRAY BASICS
*/

const learningTopics = [
  "variables",
  "functions",
  "arrays",
  "objects"
];

const arrayResults = [
  `Number of topics: ${learningTopics.length}`,
  `First topic: ${learningTopics[0]}`,
  `Last topic: ${
    learningTopics[learningTopics.length - 1]
  }`,
  `Functions index: ${
    learningTopics.indexOf("functions")
  }`,
  `Missing topic index: ${
    learningTopics.indexOf("dom")
  }`
];

/*
  ARRAY COPYING WITH SLICE
*/

const selectedTopics = learningTopics.slice(1, 3);

arrayResults.push(
  `Selected topics: ${selectedTopics.join(", ")}`
);

/*
  ARRAY INSERTION AND REMOVAL
*/

const actionLog = [];

actionLog.push("Opened application");
actionLog.push("Created task");

const removedLastAction = actionLog.pop();

actionLog.unshift("Loaded preferences");

const removedFirstAction = actionLog.shift();

arrayResults.push(
  `Remaining action: ${actionLog.join(", ")}`
);

arrayResults.push(
  `Removed final action: ${removedLastAction}`
);

arrayResults.push(
  `Removed first action: ${removedFirstAction}`
);

/*
  OBJECT CREATION AND PROPERTY ACCESS
*/

const selectedCategory = "work";

const exampleTask = {
  id: 100,
  title: "Inspect object properties",
  completed: false,
  [selectedCategory]: "Study JavaScript"
};

const objectResults = [
  `Object title: ${exampleTask.title}`,
  `Object title with brackets: ${
    exampleTask["title"]
  }`,
  `Dynamic category value: ${
    exampleTask[selectedCategory]
  }`
];

exampleTask.completed = true;

objectResults.push(
  `Updated completion: ${exampleTask.completed}`
);

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

function completeTask(tasks, taskId) {
  const task = findTaskById(tasks, taskId);

  if (task === undefined) {
    return false;
  }

  task.completed = true;
  return true;
}

function removeTaskById(tasks, taskId) {
  const index = tasks.findIndex(
    (task) => task.id === taskId
  );

  if (index === -1) {
    return false;
  }

  tasks.splice(index, 1);
  return true;
}

function describeTask(task) {
  if (
    task === null ||
    typeof task !== "object" ||
    !Number.isSafeInteger(task.id) ||
    typeof task.title !== "string" ||
    typeof task.completed !== "boolean"
  ) {
    throw new TypeError("Invalid task object.");
  }

  const state = task.completed
    ? "complete"
    : "incomplete";

  return `${task.id}. ${task.title} — ${state}`;
}

/*
  TASK COLLECTION
*/

const tasks = [
  createTask("Learn arrays", 1),
  createTask("Learn objects", 2),
  createTask("Practice task updates", 3)
];

const completedTaskResult = completeTask(tasks, 2);

if (!completedTaskResult) {
  throw new Error("Could not complete task with id 2.");
}

const removedTaskResult = removeTaskById(tasks, 1);

if (!removedTaskResult) {
  throw new Error("Could not remove task with id 1.");
}

const taskLines = [];

for (const task of tasks) {
  taskLines.push(describeTask(task));
}

/*
  FINAL PAGE OUTPUT
*/

const allResults = [
  "Array examples:",
  ...arrayResults,
  "",
  "Object examples:",
  ...objectResults,
  "",
  "Task collection:",
  ...taskLines
];

statusMessageElement.textContent =
  "Part 3 data structures are working successfully.";

resultsOutputElement.textContent = allResults.join("\n");

console.log("Learning topics:", learningTopics);
console.log("Example task:", exampleTask);
console.log("Final tasks:", tasks);
```

## The Verification

Refresh the browser.

The page should show output similar to:

```text
Array examples:
Number of topics: 4
First topic: variables
Last topic: objects
Functions index: 1
Missing topic index: -1
Selected topics: functions, arrays
Remaining action: Created task
Removed final action: Created task
Removed first action: Loaded preferences

Object examples:
Object title: Inspect object properties
Object title with brackets: Inspect object properties
Dynamic category value: Study JavaScript
Updated completion: true

Task collection:
2. Learn objects — complete
3. Practice task updates — incomplete
```

The status message should be:

```text
Part 3 data structures are working successfully.
```

The console should show:

- The topic array.
- The example task object.
- The final tasks array.

[COMPLETED: Step 13 — Complete Part 3 implementation verified]  
[STARTING: Part 3 reference section]

---

# Part 3 Reference: Arrays and Objects

## Array Method Summary

### `push`

Adds one or more items to the end and returns the new length.

```js
const values = ["a"];

const newLength = values.push("b");

console.log(values); // ["a", "b"]
console.log(newLength); // 2
```

### `pop`

Removes and returns the last item.

```js
const values = ["a", "b"];

const removed = values.pop();

console.log(removed); // "b"
console.log(values); // ["a"]
```

### `unshift`

Adds one or more items to the beginning.

```js
const values = ["b"];

values.unshift("a");

console.log(values); // ["a", "b"]
```

### `shift`

Removes and returns the first item.

```js
const values = ["a", "b"];

const removed = values.shift();

console.log(removed); // "a"
console.log(values); // ["b"]
```

### `slice`

Copies a section without mutating the original.

```js
const values = ["a", "b", "c", "d"];

const copiedSection = values.slice(1, 3);

console.log(copiedSection); // ["b", "c"]
console.log(values); // ["a", "b", "c", "d"]
```

### `indexOf`

Returns the first matching index or `-1`.

```js
const values = ["a", "b", "a"];

values.indexOf("a"); // 0
values.indexOf("z"); // -1
```

### `find`

Returns the first matching object or `undefined`.

```js
const tasks = [
  { id: 1, title: "Read" },
  { id: 2, title: "Write" }
];

const task = tasks.find(
  (item) => item.id === 2
);
```

### `findIndex`

Returns the first matching index or `-1`.

```js
const index = tasks.findIndex(
  (item) => item.id === 2
);
```

### `splice`

Removes or inserts items and mutates the original array.

```js
const values = ["a", "b", "c"];

values.splice(1, 1);

console.log(values); // ["a", "c"]
```

To insert without deleting:

```js
values.splice(1, 0, "new");
```

---

## Arrays Are Objects

This is why arrays can have properties such as:

```js
values.length
```

However, use arrays for ordered collections and objects for named records.

Good:

```js
const tasks = [
  {
    id: 1,
    title: "Read",
    completed: false
  }
];
```

Less suitable:

```js
const tasks = {
  first: {
    id: 1,
    title: "Read"
  }
};
```

The second structure may be appropriate in specific situations, but it does not naturally represent an ordered list.

---

## Object Property Names

Valid property names can be written directly:

```js
const user = {
  name: "Amina",
  age: 28
};
```

If a property name contains spaces or special characters, use quotes:

```js
const settings = {
  "font-size": "large"
};
```

Access it with brackets:

```js
settings["font-size"];
```

Dot notation would not work:

```js
settings.font-size;
```

JavaScript interprets that as subtraction.

---

## Object Mutation

Objects declared with `const` can still have their properties changed:

```js
const task = {
  completed: false
};

task.completed = true;
```

The variable still refers to the same object.

To replace the whole object, the variable must be declared with `let`:

```js
let task = {
  completed: false
};

task = {
  completed: true
};
```

Prefer `const` when the object reference should remain stable.

---

## Copying Objects

Assigning an object copies its reference:

```js
const firstTask = {
  title: "Read"
};

const secondTask = firstTask;

secondTask.title = "Write";

console.log(firstTask.title); // "Write"
```

A shallow copy creates a new outer object:

```js
const secondTask = {
  ...firstTask
};
```

Now changing a top-level property on `secondTask` does not change the top-level property on `firstTask`.

```js
const firstTask = {
  title: "Read",
  completed: false
};

const secondTask = {
  ...firstTask
};

secondTask.title = "Write";

console.log(firstTask.title); // "Read"
console.log(secondTask.title); // "Write"
```

Nested objects remain shared in a shallow copy:

```js
const firstTask = {
  metadata: {
    category: "study"
  }
};

const secondTask = {
  ...firstTask
};

secondTask.metadata.category = "work";

console.log(firstTask.metadata.category); // "work"
```

This topic becomes important when application state becomes more complex.

---

## Destructuring

Destructuring extracts values from arrays or objects.

### Object destructuring

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
```

Now these variables exist:

```js
id
title
completed
```

### Array destructuring

```js
const colors = ["red", "green", "blue"];

const [
  firstColor,
  secondColor
] = colors;
```

The variables contain:

```text
firstColor  → red
secondColor → green
```

Destructuring is useful, but dot notation is often clearer for beginners when only one property is needed.

---

## Spread Syntax

Spread syntax copies array values into a new array:

```js
const first = [1, 2];
const second = [3, 4];

const combined = [
  ...first,
  ...second
];
```

Result:

```js
[1, 2, 3, 4]
```

It can also copy object properties:

```js
const original = {
  title: "Read",
  completed: false
};

const updated = {
  ...original,
  completed: true
};
```

This creates a new object with one changed property.

---

## Data Modeling Rules for the Task Application

Each task should have a predictable shape:

```js
{
  id: 1,
  title: "Learn JavaScript",
  completed: false
}
```

The rules are:

- `id` is a non-negative safe integer.
- `title` is a non-empty string.
- `completed` is a boolean.

A predictable shape makes later DOM code simpler because rendering logic can rely on these properties existing.

Bad inconsistent data:

```js
[
  {
    id: 1,
    title: "Read"
  },
  {
    taskName: "Write",
    done: false
  }
]
```

Good consistent data:

```js
[
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
]
```

---

## Part 3 Completion Checklist

Before moving to Part 4, confirm that you can answer:

- Why does the first array item use index `0`?
- What does `length` represent?
- What does `push` do?
- What does `pop` do?
- What is the difference between `shift` and `unshift`?
- Does `slice` mutate the original array?
- What does `indexOf` return when no item is found?
- What is an object literal?
- What is the difference between dot and bracket notation?
- When are dynamic property keys useful?
- Why are arrays of objects useful for tasks?
- What is the difference between `find` and `findIndex`?
- What does `splice` do?
- Why can assigning an object to another variable create shared state?

The working page should end with:

```text
Part 3 data structures are working successfully.
```

[NEXT: Part 4 — Connecting JavaScript to the DOM & Events]
