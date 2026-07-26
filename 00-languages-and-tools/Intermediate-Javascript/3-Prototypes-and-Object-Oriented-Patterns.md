# Part 3: Prototypes and Object-Oriented Patterns

In the previous part, the application learned how to handle future results with Promises and `async`/`await`.

The task data is still represented by ordinary object literals:

```javascript
{
  id: 1,
  title: "Study JavaScript",
  completed: false
}
```

That works, but the application now needs a consistent model for tasks. A task should not be only data. It should also know how to perform task-specific operations, such as:

- Completing itself.
- Reopening itself.
- Reporting its status.
- Converting itself into storage-safe data.

In this part, we will study JavaScript’s object system and introduce a `Task` class.

You will learn:

- Prototypes.
- The prototype chain.
- Property lookup.
- Factory functions.
- Constructor functions.
- The `new` keyword.
- ES5-style object-oriented patterns.
- ES6 `class` syntax.
- Instance methods.
- Static methods.
- Inheritance with `extends`.
- Parent initialization with `super`.
- Why classes are built on top of prototypes.

---

# Part 3 Overview

We will build this functionality in stages:

1. Inspect JavaScript object prototypes.
2. Create a task with a factory function.
3. Create a task with a constructor function.
4. Convert the task model to an ES6 class.
5. Add task behavior as instance methods.
6. Add validation and serialization.
7. Add a specialized `ImportedTask` subclass.
8. Update the application to use `Task` objects.
9. Complete and verify the Part 3 application.

---

# Step 1: Inspect Prototypes

## The Target

Create a small prototype demonstration so you can see how JavaScript objects inherit behavior.

## The Concept

A **prototype** is another object that JavaScript consults when a requested property is not found directly on the current object.

Imagine a student asking:

> Do I have a calculator?

If the student does not, they ask the classroom:

> Does the classroom have one?

If the classroom does not, they ask the school.

This chain of lookups is similar to the **prototype chain**.

Every ordinary object is connected to another object through its internal prototype relationship.

Arrays inherit methods such as:

```javascript
map()
filter()
push()
```

Those methods are not copied individually into every array. They are available through `Array.prototype`.

## The Implementation

Create a temporary file.

### `prototype-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Prototype Demonstration</title>
  </head>
  <body>
    <h1>Open the browser console</h1>

    <script>
      const firstTask = {
        title: "Study prototypes",
      };

      const secondTask = {
        title: "Study classes",
      };

      console.log(
        "Prototype of firstTask:",
        Object.getPrototypeOf(firstTask)
      );

      console.log(
        "Prototype of secondTask:",
        Object.getPrototypeOf(secondTask)
      );

      console.log(
        "Both objects share Object.prototype:",
        Object.getPrototypeOf(firstTask) === Object.prototype &&
          Object.getPrototypeOf(secondTask) === Object.prototype
      );

      const numbers = [1, 2, 3];

      console.log(
        "Array prototype provides map:",
        typeof Array.prototype.map
      );

      console.log(
        "numbers can use map:",
        typeof numbers.map
      );
    </script>
  </body>
</html>
```

## The Verification

Open `prototype-demo.html`.

The console should show:

```text
Both objects share Object.prototype: true
Array prototype provides map: function
numbers can use map: function
```

Try this in the console:

```javascript
Object.getPrototypeOf(firstTask) === Object.prototype
```

The result should be:

```text
true
```

Then inspect the array prototype:

```javascript
Object.getPrototypeOf(numbers) === Array.prototype
```

The result should also be:

```text
true
```

Delete `prototype-demo.html` after testing.

[COMPLETED: Step 1 — Prototype lookup demonstrated]  
[STARTING: Step 2 — Create a task with a factory function]

---

# Step 2: Use a Factory Function

## The Target

Create tasks with a factory function.

A **factory function** is an ordinary function that creates and returns objects.

## The Concept

A factory is like a workshop that produces identical products.

Instead of repeatedly writing:

```javascript
const task = {
  id: 1,
  title: "Read",
  completed: false,
};
```

we create one function:

```javascript
function createTask(title) {
  return {
    id: createId(),
    title,
    completed: false,
  };
}
```

Every call produces a correctly shaped task.

Factory functions are useful because they:

- Hide object construction details.
- Validate or normalize input.
- Give objects consistent properties.
- Avoid requiring the caller to understand internal setup.

## The Implementation

Add this temporary code to the browser console:

```javascript
function createFactoryTask(title) {
  const normalizedTitle = title.trim();

  if (normalizedTitle.length === 0) {
    throw new Error("A task title is required.");
  }

  return {
    id: Date.now(),
    title: normalizedTitle,
    completed: false,

    complete() {
      this.completed = true;
    },

    reopen() {
      this.completed = false;
    },

    isCompleted() {
      return this.completed;
    },
  };
}

const factoryTask = createFactoryTask("Learn factory functions");

console.log(factoryTask.title);
console.log(factoryTask.isCompleted());

factoryTask.complete();

console.log(factoryTask.isCompleted());
```

## The Verification

The console should show:

```text
Learn factory functions
false
true
```

The object works, but each object created by this literal includes its own function properties.

For a small application this may be acceptable. For many objects, it is more efficient to place shared methods on a prototype. Constructor functions and classes provide patterns for doing that.

[COMPLETED: Step 2 — Factory function demonstrated]  
[STARTING: Step 3 — Use a constructor function and `new`]

---

# Step 3: Use a Constructor Function

## The Target

Create tasks with a constructor function.

## The Concept

Before the `class` syntax was introduced, JavaScript developers commonly used constructor functions.

A constructor function is called with `new`:

```javascript
const task = new Task("Learn constructors");
```

The `new` keyword performs several operations:

1. Creates a new object.
2. Connects that object to the constructor’s prototype.
3. Binds `this` inside the constructor to the new object.
4. Returns the new object unless the constructor explicitly returns another object.

## The Implementation

Run this in the browser console:

```javascript
function ConstructorTask(title) {
  const normalizedTitle = title.trim();

  if (normalizedTitle.length === 0) {
    throw new Error("A task title is required.");
  }

  this.id = Date.now();
  this.title = normalizedTitle;
  this.completed = false;
}

ConstructorTask.prototype.complete = function () {
  this.completed = true;
};

ConstructorTask.prototype.reopen = function () {
  this.completed = false;
};

ConstructorTask.prototype.isCompleted = function () {
  return this.completed;
};

const constructorTask = new ConstructorTask(
  "Learn constructor functions"
);

console.log(constructorTask.title);
console.log(constructorTask instanceof ConstructorTask);
console.log(constructorTask.isCompleted());

constructorTask.complete();

console.log(constructorTask.isCompleted());
```

## The Verification

The console should show:

```text
Learn constructor functions
true
false
true
```

Now inspect the relationship:

```javascript
Object.getPrototypeOf(constructorTask) === ConstructorTask.prototype
```

The result should be:

```text
true
```

The methods are available through the prototype:

```javascript
constructorTask.hasOwnProperty("complete")
```

The result should be:

```text
false
```

The method exists on `ConstructorTask.prototype`, not directly on the task instance.

[COMPLETED: Step 3 — Constructor function and prototype methods demonstrated]  
[STARTING: Step 4 — Replace the constructor function with an ES6 class]

---

# Step 4: Create the `Task` Class

## The Target

Create `js/task.js` containing a reusable `Task` class.

We are placing the class in its own file because it is a model: a structure that represents application data and behavior.

## The Concept

The `class` syntax is a cleaner way to write constructor-and-prototype patterns.

This:

```javascript
class Task {
  complete() {
    this.completed = true;
  }
}
```

still uses prototypes internally. The `complete` method is placed on `Task.prototype`.

The class syntax does not turn JavaScript into a fundamentally different object system. It gives us clearer syntax for a common pattern.

## The Implementation

Create the file below.

### `js/task.js`

```javascript
"use strict";

export class Task {
  constructor({ id, title, completed = false, createdAt = new Date() }) {
    if (!Number.isInteger(id) || id < 0) {
      throw new TypeError("Task id must be a non-negative integer.");
    }

    if (typeof title !== "string") {
      throw new TypeError("Task title must be a string.");
    }

    const normalizedTitle = title.trim();

    if (normalizedTitle.length === 0) {
      throw new Error("Task title cannot be empty.");
    }

    if (normalizedTitle.length > 120) {
      throw new Error("Task title cannot exceed 120 characters.");
    }

    if (typeof completed !== "boolean") {
      throw new TypeError("Task completed state must be a boolean.");
    }

    const normalizedCreatedAt =
      createdAt instanceof Date ? createdAt : new Date(createdAt);

    if (Number.isNaN(normalizedCreatedAt.getTime())) {
      throw new TypeError("Task createdAt must be a valid date.");
    }

    this.id = id;
    this.title = normalizedTitle;
    this.completed = completed;
    this.createdAt = normalizedCreatedAt;
  }

  complete() {
    this.completed = true;
  }

  reopen() {
    this.completed = false;
  }

  toggleCompletion() {
    this.completed = !this.completed;
  }

  isCompleted() {
    return this.completed;
  }

  getStatusLabel() {
    return this.completed ? "Completed" : "Not completed";
  }

  toJSON() {
    /*
     * Dates become strings before storage or network transfer.
     * Keeping this conversion here gives every caller the same format.
     */
    return {
      id: this.id,
      title: this.title,
      completed: this.completed,
      createdAt: this.createdAt.toISOString(),
    };
  }
}
```

## The Verification

At this point, the browser will not load the file as part of the application because `index.html` still loads `main.js` as a classic script.

We will connect the files after creating the remaining model code.

For now, start a local server from the project directory.

If Python is installed:

```bash
python3 -m http.server 8000
```

On Windows, this may be:

```powershell
python -m http.server 8000
```

Open:

```text
http://localhost:8000
```

The page should still load, although `task.js` is not yet used.

[COMPLETED: Step 4 — Validated `Task` class created]  
[STARTING: Step 5 — Add static construction and subclassing]

---

# Step 5: Add a Static Factory and `ImportedTask`

## The Target

Extend `js/task.js` with:

- A static `fromJSON` method.
- An `ImportedTask` subclass.
- The `extends` and `super` patterns.

## The Concept

A **static method** belongs to the class itself, not to individual instances.

Instance method:

```javascript
task.complete();
```

Static method:

```javascript
Task.fromJSON(data);
```

A static method is useful when the operation creates or validates an instance.

A subclass is a specialized version of a parent class.

For example:

- `Task` represents any task.
- `ImportedTask` represents a task loaded from an external source.

`extends` establishes inheritance.

`super()` calls the parent constructor so the parent can initialize shared properties.

## The Implementation

Replace `js/task.js` with this complete version:

### `js/task.js`

```javascript
"use strict";

export class Task {
  constructor({ id, title, completed = false, createdAt = new Date() }) {
    if (!Number.isInteger(id) || id < 0) {
      throw new TypeError("Task id must be a non-negative integer.");
    }

    if (typeof title !== "string") {
      throw new TypeError("Task title must be a string.");
    }

    const normalizedTitle = title.trim();

    if (normalizedTitle.length === 0) {
      throw new Error("Task title cannot be empty.");
    }

    if (normalizedTitle.length > 120) {
      throw new Error("Task title cannot exceed 120 characters.");
    }

    if (typeof completed !== "boolean") {
      throw new TypeError("Task completed state must be a boolean.");
    }

    const normalizedCreatedAt =
      createdAt instanceof Date ? createdAt : new Date(createdAt);

    if (Number.isNaN(normalizedCreatedAt.getTime())) {
      throw new TypeError("Task createdAt must be a valid date.");
    }

    this.id = id;
    this.title = normalizedTitle;
    this.completed = completed;
    this.createdAt = normalizedCreatedAt;
  }

  complete() {
    this.completed = true;
  }

  reopen() {
    this.completed = false;
  }

  toggleCompletion() {
    this.completed = !this.completed;
  }

  isCompleted() {
    return this.completed;
  }

  getStatusLabel() {
    return this.completed ? "Completed" : "Not completed";
  }

  toJSON() {
    return {
      id: this.id,
      title: this.title,
      completed: this.completed,
      createdAt: this.createdAt.toISOString(),
    };
  }

  static fromJSON(value) {
    if (typeof value !== "object" || value === null) {
      throw new TypeError("Task JSON value must be an object.");
    }

    return new Task({
      id: value.id,
      title: value.title,
      completed: value.completed,
      createdAt: value.createdAt,
    });
  }
}

export class ImportedTask extends Task {
  constructor({ source, ...taskData }) {
    super(taskData);

    if (typeof source !== "string" || source.trim().length === 0) {
      throw new Error("Imported task source is required.");
    }

    this.source = source.trim();
  }

  getStatusLabel() {
    return `${super.getStatusLabel()} · Imported from ${this.source}`;
  }

  toJSON() {
    return {
      ...super.toJSON(),
      source: this.source,
    };
  }
}
```

## The Verification

Create a temporary module test file.

### `js/test-task.js`

```javascript
import { ImportedTask, Task } from "./task.js";

const task = new Task({
  id: 1,
  title: "Test the Task class",
});

console.log("Task instance:", task);
console.log("Task prototype:", Object.getPrototypeOf(task));
console.log("Completed initially:", task.isCompleted());

task.complete();

console.log("Completed after complete():", task.isCompleted());
console.log("Serialized task:", task.toJSON());

const importedTask = new ImportedTask({
  id: 2,
  title: "Test inheritance",
  completed: false,
  source: "Example API",
});

console.log("Imported task:", importedTask);
console.log("Imported status:", importedTask.getStatusLabel());
console.log("Is Task:", importedTask instanceof Task);
console.log("Is ImportedTask:", importedTask instanceof ImportedTask);
```

Temporarily change the script in `index.html`:

```html
<script type="module" src="./js/test-task.js"></script>
```

Refresh:

```text
http://localhost:8000
```

The console should show:

```text
Completed initially: false
Completed after complete(): true
Is Task: true
Is ImportedTask: true
```

Restore the script tag later to:

```html
<script type="module" src="./js/main.js"></script>
```

Delete `js/test-task.js`.

[COMPLETED: Step 5 — Static factory and subclassing implemented]  
[STARTING: Step 6 — Update the application to use `Task` instances]

---

# Step 6: Use Classes in the Application

## The Target

Update `index.html` to load `main.js` as a module and replace the application’s plain objects with `Task` instances.

## The Concept

A browser module can import code from another file:

```javascript
import { Task } from "./task.js";
```

The browser follows that dependency and makes the exported class available.

Because modules use `import` and `export`, the script must be marked as a module:

```html
<script type="module" src="./js/main.js"></script>
```

This is the first step toward the modular architecture that will be completed in Part 4.

## The Implementation

Change the final script tag in `index.html` from:

```html
<script src="./js/main.js"></script>
```

to:

```html
<script type="module" src="./js/main.js"></script>
```

Now replace `js/main.js` with this complete implementation:

### `js/main.js`

```javascript
"use strict";

import { Task } from "./task.js";

const taskForm = document.querySelector("#task-form");
const taskTitleInput = document.querySelector("#task-title");
const taskList = document.querySelector("#task-list");
const taskCount = document.querySelector("#task-count");
const statusMessage = document.querySelector("#status-message");
const loadTasksButton = document.querySelector("#load-tasks-button");

let tasks = [
  new Task({
    id: 1,
    title: "Understand synchronous JavaScript",
  }),
  new Task({
    id: 2,
    title: "Practice reading the event loop",
  }),
];

let isLoadingTasks = false;

function normalizeError(value) {
  if (value instanceof Error) {
    return value;
  }

  if (typeof value === "string" && value.trim().length > 0) {
    return new Error(value);
  }

  return new Error("An unknown asynchronous error occurred.");
}

function createTaskId() {
  return Date.now() + Math.floor(Math.random() * 1000);
}

function updateStatus(message, state = "default") {
  statusMessage.textContent = message;
  statusMessage.className = "status-message";

  if (state === "loading") {
    statusMessage.classList.add("status-loading");
  }

  if (state === "success") {
    statusMessage.classList.add("status-success");
  }

  if (state === "error") {
    statusMessage.classList.add("status-error");
  }
}

function updateTaskCount() {
  const taskTotal = tasks.length;
  const completedTotal = tasks.filter((task) => task.isCompleted()).length;

  taskCount.textContent =
    `${taskTotal} ${taskTotal === 1 ? "task" : "tasks"} · ` +
    `${completedTotal} completed`;
}

function renderTasks() {
  taskList.replaceChildren();

  if (tasks.length === 0) {
    const emptyMessage = document.createElement("p");
    emptyMessage.className = "empty-state";
    emptyMessage.textContent = "No tasks yet.";
    taskList.append(emptyMessage);
    updateTaskCount();
    return;
  }

  tasks.forEach((task) => {
    const listItem = document.createElement("li");
    listItem.className = "task-item";

    if (task.isCompleted()) {
      listItem.classList.add("task-completed");
    }

    const textContainer = document.createElement("div");

    const title = document.createElement("p");
    title.className = "task-title";
    title.textContent = task.title;

    const metadata = document.createElement("p");
    metadata.className = "task-meta";
    metadata.textContent = task.getStatusLabel();

    textContainer.append(title, metadata);

    const completionButton = document.createElement("button");
    completionButton.className = "task-action";
    completionButton.type = "button";
    completionButton.textContent = task.isCompleted()
      ? "Mark as incomplete"
      : "Mark as complete";

    completionButton.addEventListener("click", () => {
      task.toggleCompletion();
      renderTasks();
      updateStatus("Task status updated.", "success");
    });

    listItem.append(textContainer, completionButton);
    taskList.append(listItem);
  });

  updateTaskCount();
}

function addTask(title) {
  try {
    const newTask = new Task({
      id: createTaskId(),
      title,
    });

    tasks.push(newTask);
    renderTasks();
    updateStatus(`Added task: ${newTask.title}`, "success");
  } catch (error) {
    const normalizedError = normalizeError(error);
    updateStatus(normalizedError.message, "error");
  }
}

function loadExampleTasks(shouldFail = false) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (shouldFail) {
        reject(
          new Error("The example task service could not load the tasks.")
        );
        return;
      }

      resolve([
        new Task({
          id: createTaskId(),
          title: "Read about the call stack",
        }),
        new Task({
          id: createTaskId(),
          title: "Trace a timer through the event loop",
        }),
        new Task({
          id: createTaskId(),
          title: "Explain why callbacks run later",
          completed: true,
        }),
      ]);
    }, 1500);
  });
}

async function loadTasksIntoApplication() {
  if (isLoadingTasks) {
    return;
  }

  isLoadingTasks = true;
  loadTasksButton.disabled = true;
  updateStatus("Loading example tasks...", "loading");

  const shouldFail = false;

  try {
    const loadedTasks = await loadExampleTasks(shouldFail);

    tasks = loadedTasks;
    renderTasks();

    updateStatus(
      `Loaded ${loadedTasks.length} example tasks successfully.`,
      "success"
    );
  } catch (error) {
    const normalizedError = normalizeError(error);

    console.error("Could not load example tasks:", normalizedError);

    updateStatus(
      `Could not load example tasks: ${normalizedError.message}`,
      "error"
    );
  } finally {
    isLoadingTasks = false;
    loadTasksButton.disabled = false;
  }
}

taskForm.addEventListener("submit", (event) => {
  event.preventDefault();

  addTask(taskTitleInput.value);
  taskTitleInput.value = "";
  taskTitleInput.focus();
});

loadTasksButton.addEventListener("click", () => {
  loadTasksIntoApplication();
});

renderTasks();
updateStatus("Ready. Tasks are currently stored only in memory.");
```

## The Verification

Start the local server if it is not running:

```bash
python3 -m http.server 8000
```

Open:

```text
http://localhost:8000
```

Test the following.

### Initial task objects

The two initial tasks should appear.

### Add a task

Enter:

```text
Use a Task class
```

Click **Add task**.

The task should appear.

### Invalid task

Submit an empty title.

The application should show:

```text
Task title cannot be empty.
```

### Complete a task

Click **Mark as complete**.

The task should show:

```text
Completed
```

### Asynchronous loading

Click **Load example tasks**.

The three loaded tasks should appear after approximately 1.5 seconds.

[COMPLETED: Step 6 — Application migrated to `Task` instances]  
[STARTING: Step 7 — Add a model-focused verification suite]

---

# Step 7: Verify the Task Model

## The Target

Create a small model test file to verify the class independently from the application UI.

## The Concept

Testing a model separately is useful because it distinguishes model problems from browser rendering problems.

If a test fails here, the problem is likely in:

- Validation.
- Class behavior.
- Serialization.
- Inheritance.

If this test passes but the page fails, the problem is more likely in the UI or application coordination code.

## The Implementation

Create this temporary file:

### `js/task-test.js`

```javascript
import { ImportedTask, Task } from "./task.js";

function assert(condition, message) {
  if (!condition) {
    throw new Error(`Assertion failed: ${message}`);
  }

  console.log(`PASS: ${message}`);
}

const task = new Task({
  id: 10,
  title: "Test task",
});

assert(task instanceof Task, "Task is a Task instance");
assert(task.title === "Test task", "Task title is stored");
assert(task.isCompleted() === false, "Task starts incomplete");

task.complete();

assert(task.isCompleted() === true, "complete() marks task complete");

task.reopen();

assert(task.isCompleted() === false, "reopen() marks task incomplete");

task.toggleCompletion();

assert(task.isCompleted() === true, "toggleCompletion() changes state");

const serializedTask = task.toJSON();

assert(
  serializedTask.createdAt.endsWith("Z"),
  "Serialized date uses ISO format"
);

const restoredTask = Task.fromJSON(serializedTask);

assert(restoredTask instanceof Task, "fromJSON() creates a Task");
assert(restoredTask.title === task.title, "fromJSON() restores the title");
assert(
  restoredTask.isCompleted() === task.isCompleted(),
  "fromJSON() restores completion state"
);

const importedTask = new ImportedTask({
  id: 11,
  title: "Imported task",
  source: "Demo API",
});

assert(importedTask instanceof Task, "ImportedTask inherits from Task");
assert(
  importedTask instanceof ImportedTask,
  "ImportedTask has its own constructor type"
);
assert(
  importedTask.getStatusLabel().includes("Demo API"),
  "ImportedTask includes its source in the status"
);

let emptyTitleRejected = false;

try {
  new Task({
    id: 12,
    title: "   ",
  });
} catch (error) {
  emptyTitleRejected = true;
}

assert(emptyTitleRejected, "Empty titles are rejected");

console.log("All Task model tests passed.");
```

Temporarily change `index.html`:

```html
<script type="module" src="./js/task-test.js"></script>
```

## The Verification

Refresh:

```text
http://localhost:8000
```

The console should show multiple `PASS` messages and finish with:

```text
All Task model tests passed.
```

Restore `index.html`:

```html
<script type="module" src="./js/main.js"></script>
```

Delete:

```text
js/task-test.js
```

[COMPLETED: Step 7 — Task model verified independently]  
[STARTING: Part 3 Reference — Prototypes, classes, and inheritance]

---

# Part 3 Reference: Object-Oriented JavaScript

## Objects Store Data

An object can group related values:

```javascript
const task = {
  title: "Learn objects",
  completed: false,
};
```

This is useful when the data is simple.

As the application grows, related behavior can be grouped with the data:

```javascript
const task = {
  title: "Learn objects",
  completed: false,

  complete() {
    this.completed = true;
  },
};
```

The `this` keyword refers to the object used to call the method:

```javascript
task.complete();
```

Inside `complete`, `this` refers to `task`.

---

## Factory Functions

A factory function returns a new object:

```javascript
function createTask(title) {
  return {
    title,
    completed: false,
  };
}
```

Usage:

```javascript
const task = createTask("Learn factories");
```

Factory functions are often a good choice when:

- Objects have simple behavior.
- Private closures are useful.
- Inheritance is unnecessary.
- You want to avoid `new`.

---

## Constructor Functions

A constructor function uses `this` to initialize an object:

```javascript
function Task(title) {
  this.title = title;
  this.completed = false;
}
```

Usage requires `new`:

```javascript
const task = new Task("Learn constructors");
```

Calling a constructor without `new` can cause problems:

```javascript
const task = Task("Incorrect usage");
```

In strict mode, `this` may be `undefined`, causing an error.

Classes are generally safer and clearer for this pattern because calling a class without `new` throws an immediate error.

---

## The `new` Keyword

For:

```javascript
const task = new Task("Learn new");
```

JavaScript conceptually performs:

```javascript
const newObject = Object.create(Task.prototype);
Task.call(newObject, "Learn new");
return newObject;
```

This is a simplified explanation, but it captures the important idea:

- The new object inherits from `Task.prototype`.
- The constructor initializes its properties.
- The object is returned.

---

## Prototype Methods

Methods placed on a prototype are shared:

```javascript
function Task(title) {
  this.title = title;
}

Task.prototype.describe = function () {
  return `Task: ${this.title}`;
};
```

Every instance can use `describe`, but the method is stored once:

```javascript
const first = new Task("First");
const second = new Task("Second");

first.describe === second.describe;
```

The result is:

```javascript
true
```

---

## Classes

A class combines constructor logic and prototype methods:

```javascript
class Task {
  constructor(title) {
    this.title = title;
  }

  describe() {
    return `Task: ${this.title}`;
  }
}
```

The method is still stored on the prototype:

```javascript
const task = new Task("Learn classes");

Object.getPrototypeOf(task) === Task.prototype;
```

The result is:

```javascript
true
```

---

## Instance Fields and Methods

An instance field is stored directly on each object:

```javascript
class Task {
  constructor(title) {
    this.title = title;
  }
}
```

Each instance has its own `title`.

A method is normally placed on the prototype:

```javascript
class Task {
  complete() {
    this.completed = true;
  }
}
```

This avoids creating a separate function object for every instance.

---

## Static Methods

Static methods belong to the class:

```javascript
class Task {
  static createEmpty() {
    return new Task("Untitled task");
  }
}
```

Use it like this:

```javascript
const task = Task.createEmpty();
```

Do not call it on an instance:

```javascript
task.createEmpty();
```

That fails because `createEmpty` belongs to `Task`, not `task`.

Static methods are useful for:

- Factory operations.
- Parsing.
- Validation.
- Utility behavior related to the class.

---

## Inheritance

A subclass extends a parent class:

```javascript
class ImportedTask extends Task {
  constructor(title, source) {
    super(title);
    this.source = source;
  }
}
```

`super()` invokes the parent constructor.

A subclass constructor must call `super()` before using `this`.

The prototype chain becomes:

```text
importedTask
  ↓
ImportedTask.prototype
  ↓
Task.prototype
  ↓
Object.prototype
  ↓
null
```

This allows an `ImportedTask` to use methods from both:

- `ImportedTask.prototype`
- `Task.prototype`

---

## Method Overriding

A subclass can provide a specialized implementation:

```javascript
class ImportedTask extends Task {
  getStatusLabel() {
    return `Imported: ${super.getStatusLabel()}`;
  }
}
```

`super.getStatusLabel()` calls the parent implementation.

This is useful when the child behavior should extend rather than completely replace the parent behavior.

---

## Composition Versus Inheritance

Inheritance describes an “is a” relationship:

```text
ImportedTask is a Task.
```

Composition describes a “has a” relationship:

```text
TaskManager has a collection of Tasks.
```

The application’s task manager should usually contain tasks rather than extend a task.

Inheritance is useful when a specialized object genuinely shares the parent’s identity and contract.

Composition is often better when an object simply uses another object.

---

# Common Object-Oriented Mistakes

## Forgetting `new`

Incorrect:

```javascript
const task = Task({
  id: 1,
  title: "Task",
});
```

Correct:

```javascript
const task = new Task({
  id: 1,
  title: "Task",
});
```

## Using an Arrow Function as a Constructor

Arrow functions do not have their own construct behavior:

```javascript
const Task = (title) => {
  this.title = title;
};
```

This cannot be used with `new`.

Use a class or ordinary constructor function instead.

## Losing `this`

This can lose its method context:

```javascript
const complete = task.complete;
complete();
```

The method is no longer called as `task.complete()`.

When passing methods as callbacks, bind the context or use an arrow function:

```javascript
button.addEventListener("click", () => {
  task.complete();
});
```

## Mutating an Object Without Validation

This bypasses the class’s constructor rules:

```javascript
task.title = "";
```

If the application requires stronger invariants, expose methods that validate changes rather than allowing every property to change freely.

## Confusing Serialization with Restoration

JSON does not preserve class prototypes.

After this:

```javascript
const text = JSON.stringify(task);
const value = JSON.parse(text);
```

`value` is an ordinary object, not a `Task` instance.

Use:

```javascript
const restoredTask = Task.fromJSON(value);
```

to reconstruct the class instance.

---

# Part 3 Completion Checklist

You have completed Part 3 when you can explain and demonstrate:

- Objects can inherit behavior through prototypes.
- The prototype chain is used for property lookup.
- Factory functions return objects directly.
- Constructor functions are used with `new`.
- `new` creates an object connected to a constructor prototype.
- Class methods are generally stored on the class prototype.
- Static methods belong to the class rather than instances.
- `extends` creates a subclass.
- `super()` invokes parent initialization.
- Subclasses can override parent methods.
- JSON parsing does not automatically restore class instances.
- `Task.fromJSON()` reconstructs a valid `Task`.
- The application now uses `Task` objects rather than unstructured task literals.
- Invalid task titles are rejected by the model.
