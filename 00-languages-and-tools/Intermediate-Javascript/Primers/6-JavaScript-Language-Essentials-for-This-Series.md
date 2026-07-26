# Primer 6: JavaScript Language Essentials for This Series

This primer reviews the JavaScript language features used throughout the main tutorial series.

You will practice:

- Variables.
- Data types.
- Operators.
- Functions.
- Scope.
- Arrays and objects.
- Array methods.
- Destructuring.
- Spread syntax.
- Optional chaining.
- Classes.
- Errors.
- Strict mode.
- Equality and truthiness.

The main series focuses on asynchronous execution, object-oriented patterns, modules, and browser storage. These topics depend on the language fundamentals covered here.

---

# 1. Strict Mode

## The Target

Enable strict mode in a JavaScript file.

## The Concept

Strict mode asks JavaScript to enforce stricter rules.

It helps detect mistakes such as:

- Accidentally creating global variables.
- Assigning to read-only values.
- Using invalid syntax.
- Misusing certain language features.

## The Implementation

Create:

### `js/language-demo.js`

```javascript
"use strict";

const message = "Strict mode is enabled.";

console.log(message);
```

Load it from a temporary HTML file:

### `language-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>JavaScript Language Demo</title>
  </head>

  <body>
    <h1>Open the browser console</h1>

    <script src="./js/language-demo.js"></script>
  </body>
</html>
```

## The Verification

Open the page through your local server.

The console should show:

```text
Strict mode is enabled.
```

Now add this line to `language-demo.js`:

```javascript
accidentalGlobal = "This should fail.";
```

Refresh the page.

Strict mode should report an error because `accidentalGlobal` was never declared.

Remove the temporary line after testing.

[COMPLETED: Step 1 — Strict mode enabled]  
[STARTING: Step 2 — Understand variables and reassignment]

---

# 2. Variables with `const` and `let`

## The Target

Use `const` and `let` correctly.

## The Concept

A variable is a named reference to a value.

Use:

- `const` when the variable will not be reassigned.
- `let` when the variable must be reassigned.

Prefer `const` by default. Use `let` only when reassignment is necessary.

## The Implementation

Add to `js/language-demo.js`:

```javascript
const applicationName = "Async Task Manager";

let currentFilter = "all";

currentFilter = "completed";

console.log(applicationName);
console.log(currentFilter);
```

## The Verification

The console should show:

```text
Async Task Manager
completed
```

This fails:

```javascript
const count = 1;
count = 2;
```

A `const` variable cannot be reassigned.

This works:

```javascript
const task = {
  title: "Learn JavaScript",
  completed: false,
};

task.completed = true;

console.log(task.completed);
```

`const` prevents the variable from pointing to a different object. It does not freeze the object’s contents.

[COMPLETED: Step 2 — Variable declaration and reassignment practiced]  
[STARTING: Step 3 — Review JavaScript data types]

---

# 3. JavaScript Data Types

## The Target

Identify common JavaScript data types.

## The Concept

A value’s type describes what kind of data it represents.

Common types include:

```javascript
string
number
boolean
undefined
null
object
```

## The Implementation

Add:

```javascript
const taskTitle = "Learn types";
const taskCount = 3;
const isComplete = false;
let missingValue;
const emptyValue = null;
const task = {
  title: "Learn types",
};

console.log(typeof taskTitle);
console.log(typeof taskCount);
console.log(typeof isComplete);
console.log(typeof missingValue);
console.log(typeof emptyValue);
console.log(typeof task);
```

## The Verification

Expected output:

```text
string
number
boolean
undefined
object
object
```

`typeof null` returns `"object"` because of a historical JavaScript behavior. Check for `null` explicitly:

```javascript
if (emptyValue === null) {
  console.log("The value is null.");
}
```

[COMPLETED: Step 3 — Common JavaScript types reviewed]  
[STARTING: Step 4 — Use comparisons and logical operators]

---

# 4. Comparisons and Logical Operators

## The Target

Use conditions to make decisions.

## The Concept

Applications constantly make decisions:

- Is a task complete?
- Is the input empty?
- Is data loading?
- Did the request succeed?
- Which filter is selected?

## The Implementation

```javascript
const completed = false;
const title = "Study conditions";

if (completed === false) {
  console.log("The task is active.");
}

if (title.length > 0) {
  console.log("The task has a title.");
}

if (completed !== true && title.length > 0) {
  console.log("The task is active and has a title.");
}
```

Use strict equality:

```javascript
5 === 5;     // true
5 === "5";   // false
5 !== "5";   // true
```

Avoid relying on loose equality:

```javascript
5 == "5";    // true
```

## The Verification

The console should show:

```text
The task is active.
The task has a title.
The task is active and has a title.
```

Test:

```javascript
5 === "5";
```

Expected result:

```text
false
```

[COMPLETED: Step 4 — Comparisons and logical conditions practiced]  
[STARTING: Step 5 — Use functions]

---

# 5. Functions

## The Target

Create reusable functions.

## The Concept

A function packages behavior under a name.

A function can:

- Receive input through parameters.
- Perform work.
- Return a result.

## The Implementation

```javascript
function formatTaskMessage(title) {
  return `Task: ${title}`;
}

const message = formatTaskMessage(
  "Learn functions"
);

console.log(message);
```

Arrow-function equivalent:

```javascript
const formatTaskMessage = (title) => {
  return `Task: ${title}`;
};
```

Short arrow-function form:

```javascript
const formatTaskMessage = (title) =>
  `Task: ${title}`;
```

Default parameters:

```javascript
function getFilter(filter = "all") {
  return filter;
}

console.log(getFilter());
console.log(getFilter("completed"));
```

## The Verification

Expected output:

```text
Task: Learn functions
all
completed
```

[COMPLETED: Step 5 — Function declarations and parameters practiced]  
[STARTING: Step 6 — Understand return values]

---

# 6. Return Values

## The Target

Use function return values correctly.

## The Concept

A function can calculate something and give the result back to its caller.

Without `return`, a function returns `undefined`.

## The Implementation

```javascript
function add(firstNumber, secondNumber) {
  return firstNumber + secondNumber;
}

function logMessage(message) {
  console.log(message);
}

const total = add(2, 3);
const result = logMessage("Logged message");

console.log(total);
console.log(result);
```

## The Verification

Expected output:

```text
Logged message
5
undefined
```

`logMessage()` performs an action but does not return a value.

A function’s caller should know whether to expect:

- A returned value.
- A changed object.
- A Promise.
- No result.

[COMPLETED: Step 6 — Function return behavior understood]  
[STARTING: Step 7 — Understand scope]

---

# 7. Scope

## The Target

Understand where variables can be accessed.

## The Concept

Scope is the region of code where a variable exists.

Variables declared inside a function are not available outside it.

## The Implementation

```javascript
const globalMessage = "Available in this file.";

function demonstrateScope() {
  const localMessage = "Available inside the function.";

  console.log(globalMessage);
  console.log(localMessage);
}

demonstrateScope();
```

This would fail:

```javascript
console.log(localMessage);
```

because `localMessage` exists only inside `demonstrateScope()`.

Block-scoped variables:

```javascript
if (true) {
  const blockMessage = "Inside the block.";
  console.log(blockMessage);
}
```

This would fail:

```javascript
console.log(blockMessage);
```

## The Verification

Confirm that:

- `globalMessage` is available inside the function.
- `localMessage` is available only inside the function.
- `blockMessage` is available only inside the `if` block.

Modules create another scope boundary. Variables inside one module are not automatically global.

[COMPLETED: Step 7 — Function and block scope reviewed]  
[STARTING: Step 8 — Work with arrays]

---

# 8. Arrays

## The Target

Create and modify arrays.

## The Concept

An array stores an ordered collection of values.

Task applications use arrays to store task collections:

```javascript
const tasks = [];
```

## The Implementation

```javascript
const tasks = [
  "Learn arrays",
  "Learn objects",
];

console.log(tasks[0]);
console.log(tasks.length);

tasks.push("Learn functions");

console.log(tasks);

const removedTask = tasks.pop();

console.log("Removed:", removedTask);
console.log("Remaining:", tasks);
```

## The Verification

Expected output should include:

```text
Learn arrays
2
["Learn arrays", "Learn objects", "Learn functions"]
Removed: Learn functions
Remaining: ["Learn arrays", "Learn objects"]
```

Array indexes start at zero:

```javascript
tasks[0]; // first item
tasks[1]; // second item
```

[COMPLETED: Step 8 — Arrays created and modified]  
[STARTING: Step 9 — Use array iteration methods]

---

# 9. `map`, `filter`, and `find`

## The Target

Process arrays using common methods.

## The Concept

These methods express common collection operations.

### `map`

Transform every item.

### `filter`

Keep only matching items.

### `find`

Return the first matching item.

## The Implementation

```javascript
const tasks = [
  {
    id: 1,
    title: "Learn map",
    completed: false,
  },
  {
    id: 2,
    title: "Learn filter",
    completed: true,
  },
  {
    id: 3,
    title: "Learn find",
    completed: false,
  },
];

const titles = tasks.map((task) => {
  return task.title;
});

const completedTasks = tasks.filter((task) => {
  return task.completed;
});

const selectedTask = tasks.find((task) => {
  return task.id === 2;
});

console.log("Titles:", titles);
console.log("Completed:", completedTasks);
console.log("Selected:", selectedTask);
```

## The Verification

Expected results:

```text
Titles:
["Learn map", "Learn filter", "Learn find"]
```

One completed task should be returned by `filter()`.

The task with ID `2` should be returned by `find()`.

If no item matches:

```javascript
const missingTask = tasks.find(
  (task) => task.id === 99
);

console.log(missingTask);
```

The result is:

```text
undefined
```

Always handle a possible missing result.

[COMPLETED: Step 9 — Array transformation and search practiced]  
[STARTING: Step 10 — Use objects]

---

# 10. Objects

## The Target

Represent a task with an object.

## The Concept

An object groups related properties.

A task object can contain:

```javascript
{
  id,
  title,
  completed
}
```

## The Implementation

```javascript
const task = {
  id: 1,
  title: "Learn objects",
  completed: false,
};

console.log(task.title);
console.log(task["completed"]);

task.completed = true;
task.priority = "high";

console.log(task);
```

Object method:

```javascript
const managedTask = {
  title: "Complete an object method",
  completed: false,

  complete() {
    this.completed = true;
  },
};

managedTask.complete();

console.log(managedTask.completed);
```

## The Verification

Expected output:

```text
Learn objects
false
```

The final object should contain:

```javascript
{
  title: "Complete an object method",
  completed: true
}
```

Inside an object method, `this` refers to the object used to call the method:

```javascript
managedTask.complete();
```

[COMPLETED: Step 10 — Task objects and methods practiced]  
[STARTING: Step 11 — Use destructuring]

---

# 11. Destructuring

## The Target

Extract values from objects and arrays.

## The Concept

Destructuring is a concise way to assign values from a larger structure.

## The Implementation

Object destructuring:

```javascript
const task = {
  id: 1,
  title: "Learn destructuring",
  completed: false,
};

const { id, title, completed } = task;

console.log(id);
console.log(title);
console.log(completed);
```

Rename values:

```javascript
const {
  title: taskTitle,
  completed: isCompleted,
} = task;

console.log(taskTitle);
console.log(isCompleted);
```

Function parameter destructuring:

```javascript
function describeTask({
  title,
  completed,
}) {
  return `${title}: ${
    completed ? "Completed" : "Active"
  }`;
}

console.log(describeTask(task));
```

Array destructuring:

```javascript
const coordinates = [10, 20];

const [x, y] = coordinates;

console.log(x);
console.log(y);
```

## The Verification

Expected output includes:

```text
1
Learn destructuring
false
Learn destructuring: Active
10
20
```

[COMPLETED: Step 11 — Object and array destructuring practiced]  
[STARTING: Step 12 — Use spread and rest syntax]

---

# 12. Spread and Rest Syntax

## The Target

Copy and combine arrays and objects.

## The Concept

The three dots, `...`, have two related uses.

### Spread

Expands values into a new array or object.

### Rest

Collects remaining values into an array.

## The Implementation

Copy an array:

```javascript
const originalTasks = ["One", "Two"];
const copiedTasks = [...originalTasks];

copiedTasks.push("Three");

console.log(originalTasks);
console.log(copiedTasks);
```

Copy and update an object:

```javascript
const task = {
  id: 1,
  title: "Original title",
  completed: false,
};

const completedTask = {
  ...task,
  completed: true,
};

console.log(task);
console.log(completedTask);
```

Collect function arguments:

```javascript
function sum(...numbers) {
  return numbers.reduce(
    (total, number) => total + number,
    0
  );
}

console.log(sum(1, 2, 3));
```

## The Verification

The original array should remain:

```javascript
["One", "Two"]
```

The copied array should contain:

```javascript
["One", "Two", "Three"]
```

The original task should remain incomplete, while `completedTask` should be complete.

[COMPLETED: Step 12 — Spread and rest syntax practiced]  
[STARTING: Step 13 — Understand shallow copies]

---

# 13. Shallow Copies

## The Target

Understand what spread syntax does not copy deeply.

## The Concept

Spread creates a shallow copy.

Top-level properties are copied, but nested objects are still shared.

## The Implementation

```javascript
const original = {
  title: "Original",
  metadata: {
    priority: "normal",
  },
};

const copy = {
  ...original,
};

copy.title = "Changed title";
copy.metadata.priority = "high";

console.log(original.title);
console.log(original.metadata.priority);
```

## The Verification

The title should remain:

```text
Original
```

But the original priority may now be:

```text
high
```

because both objects reference the same nested `metadata` object.

For simple task records, shallow copies are often enough. For deeply nested data, use deliberate cloning or a suitable data model.

[COMPLETED: Step 13 — Shallow-copy behavior understood]  
[STARTING: Step 14 — Use optional chaining and nullish coalescing]

---

# 14. Optional Chaining and Nullish Coalescing

## The Target

Safely access optional values and provide defaults.

## The Concept

Optional chaining prevents errors when an earlier property is `null` or `undefined`.

Nullish coalescing provides a fallback only for `null` or `undefined`.

## The Implementation

```javascript
const response = {
  data: {
    task: {
      title: "Optional chaining",
    },
  },
};

console.log(response.data?.task?.title);

const missingResponse = null;

console.log(
  missingResponse?.data?.task?.title
);
```

Use `??`:

```javascript
const savedFilter = null;

const filter = savedFilter ?? "all";

console.log(filter);
```

Compare with `||`:

```javascript
const count = 0;

console.log(count || 10);
console.log(count ?? 10);
```

## The Verification

Expected output:

```text
Optional chaining
undefined
all
10
0
```

Use `??` when `0`, `false`, or an empty string are valid values that should not trigger the fallback.

[COMPLETED: Step 14 — Optional access and defaults practiced]  
[STARTING: Step 15 — Understand truthy and falsy values]

---

# 15. Truthy and Falsy Values

## The Target

Understand how JavaScript evaluates values in conditions.

## The Concept

A value is **truthy** when JavaScript treats it as true in a condition.

A value is **falsy** when JavaScript treats it as false.

Common falsy values include:

```javascript
false
0
""
null
undefined
NaN
```

Most other values are truthy, including:

```javascript
[]
{}
"false"
```

## The Implementation

```javascript
const title = "";

if (!title) {
  console.log("The title is empty.");
}

const tasks = [];

if (tasks) {
  console.log("An empty array is truthy.");
}

if (tasks.length === 0) {
  console.log("The array contains no items.");
}
```

## The Verification

Expected output:

```text
The title is empty.
An empty array is truthy.
The array contains no items.
```

Do not test whether an array contains values with:

```javascript
if (tasks) {
}
```

Use:

```javascript
if (tasks.length > 0) {
}
```

[COMPLETED: Step 15 — Truthy and falsy behavior reviewed]  
[STARTING: Step 16 — Use classes]

---

# 16. Classes

## The Target

Create a `Task` class.

## The Concept

A class defines a reusable object structure.

It can contain:

- A constructor.
- Instance properties.
- Instance methods.
- Static methods.

## The Implementation

```javascript
class Task {
  constructor({
    id,
    title,
    completed = false,
  }) {
    this.id = id;
    this.title = title;
    this.completed = completed;
  }

  complete() {
    this.completed = true;
  }

  reopen() {
    this.completed = false;
  }

  getStatusLabel() {
    return this.completed
      ? "Completed"
      : "Not completed";
  }
}

const task = new Task({
  id: 1,
  title: "Learn classes",
});

console.log(task.getStatusLabel());

task.complete();

console.log(task.getStatusLabel());
console.log(task instanceof Task);
```

## The Verification

Expected output:

```text
Not completed
Completed
true
```

The `new` keyword creates a new `Task` instance.

[COMPLETED: Step 16 — Class construction and methods practiced]  
[STARTING: Step 17 — Use static methods and inheritance]

---

# 17. Static Methods and Inheritance

## The Target

Use a static factory and a subclass.

## The Concept

A static method belongs to the class itself:

```javascript
Task.createDefault();
```

It does not belong to individual instances:

```javascript
task.createDefault();
```

Inheritance allows a specialized class to extend a general class.

## The Implementation

```javascript
class Task {
  constructor({
    id,
    title,
    completed = false,
  }) {
    this.id = id;
    this.title = title;
    this.completed = completed;
  }

  static createDefault() {
    return new Task({
      id: Date.now(),
      title: "Untitled task",
    });
  }

  getStatusLabel() {
    return this.completed
      ? "Completed"
      : "Not completed";
  }
}

class ImportedTask extends Task {
  constructor({
    source,
    ...taskData
  }) {
    super(taskData);
    this.source = source;
  }

  getStatusLabel() {
    return `${super.getStatusLabel()} · ` +
      `Imported from ${this.source}`;
  }
}

const defaultTask = Task.createDefault();

const importedTask = new ImportedTask({
  id: 2,
  title: "Imported task",
  source: "Example API",
});

console.log(defaultTask.title);
console.log(importedTask.getStatusLabel());
console.log(importedTask instanceof Task);
```

## The Verification

Expected output includes:

```text
Untitled task
Not completed · Imported from Example API
true
```

`super(taskData)` invokes the parent constructor.

[COMPLETED: Step 17 — Static methods and inheritance practiced]  
[STARTING: Step 18 — Handle errors]

---

# 18. Errors and `try`/`catch`

## The Target

Throw and handle errors.

## The Concept

An error indicates that an operation could not complete normally.

Throw an `Error` object:

```javascript
throw new Error("Task title is required.");
```

Handle it:

```javascript
try {
  riskyOperation();
} catch (error) {
  console.error(error.message);
}
```

## The Implementation

```javascript
function validateTitle(title) {
  if (typeof title !== "string") {
    throw new TypeError(
      "Task title must be a string."
    );
  }

  const normalizedTitle = title.trim();

  if (normalizedTitle.length === 0) {
    throw new Error(
      "Task title cannot be empty."
    );
  }

  return normalizedTitle;
}

try {
  const title = validateTitle("   ");
  console.log(title);
} catch (error) {
  console.error(error.name);
  console.error(error.message);
}
```

## The Verification

Expected output:

```text
Error
Task title cannot be empty.
```

Test the type error:

```javascript
try {
  validateTitle(42);
} catch (error) {
  console.error(error.name);
  console.error(error.message);
}
```

Expected output:

```text
TypeError
Task title must be a string.
```

[COMPLETED: Step 18 — Synchronous error handling practiced]  
[STARTING: Step 19 — Use `finally` for cleanup]

---

# 19. The `finally` Block

## The Target

Run cleanup whether an operation succeeds or fails.

## The Concept

The `finally` block always runs after `try` and `catch`.

It is useful for:

- Re-enabling buttons.
- Hiding loading indicators.
- Closing resources.
- Resetting state.
- Stopping timers.

## The Implementation

```javascript
let isLoading = false;

function performOperation(shouldFail) {
  if (shouldFail) {
    throw new Error("Operation failed.");
  }

  return "Operation succeeded.";
}

function runOperation(shouldFail) {
  isLoading = true;

  try {
    const result = performOperation(shouldFail);
    console.log(result);
  } catch (error) {
    console.error(error.message);
  } finally {
    isLoading = false;
    console.log("Loading state:", isLoading);
  }
}

runOperation(false);
runOperation(true);
```

## The Verification

The final log for both calls should show:

```text
Loading state: false
```

This is the same pattern used later for asynchronous operations:

```javascript
try {
  await loadTasks();
} catch (error) {
  showError(error);
} finally {
  button.disabled = false;
}
```

[COMPLETED: Step 19 — Guaranteed cleanup practiced]  
[STARTING: Step 20 — Understand JSON and class restoration]

---

# 20. JSON and Class Restoration

## The Target

Understand why parsed JSON is not automatically a class instance.

## The Concept

JSON preserves data, not behavior.

After parsing JSON:

```javascript
const value = JSON.parse(text);
```

the result is an ordinary object.

It does not automatically regain:

- Class methods.
- A prototype.
- `instanceof` behavior.

## The Implementation

```javascript
class Task {
  constructor(title) {
    this.title = title;
  }

  complete() {
    console.log("Task completed.");
  }

  toJSON() {
    return {
      title: this.title,
    };
  }

  static fromJSON(value) {
    return new Task(value.title);
  }
}

const originalTask = new Task(
  "Serialize a Task"
);

const text = JSON.stringify(originalTask);
const parsedValue = JSON.parse(text);

console.log(parsedValue instanceof Task);
console.log(typeof parsedValue.complete);

const restoredTask = Task.fromJSON(parsedValue);

console.log(restoredTask instanceof Task);
restoredTask.complete();
```

## The Verification

Expected output:

```text
false
undefined
true
Task completed.
```

The final application uses `Task.fromJSON()` when restoring stored data.

[COMPLETED: Step 20 — JSON serialization and model restoration understood]  
[STARTING: Primer 6 Reference — Language quick reference]

---

# JavaScript Language Quick Reference

## Variables

```javascript
const fixedValue = 1;

let changeableValue = 1;
changeableValue = 2;
```

## Conditions

```javascript
if (condition) {
  doSomething();
} else {
  doSomethingElse();
}
```

## Functions

```javascript
function add(first, second) {
  return first + second;
}
```

## Arrow Functions

```javascript
const add = (first, second) =>
  first + second;
```

## Arrays

```javascript
const values = [1, 2, 3];

values.push(4);
values.map((value) => value * 2);
values.filter((value) => value > 1);
values.find((value) => value === 2);
```

## Objects

```javascript
const task = {
  id: 1,
  title: "Learn objects",
  completed: false,
};
```

## Destructuring

```javascript
const {
  title,
  completed,
} = task;
```

## Spread

```javascript
const updatedTask = {
  ...task,
  completed: true,
};
```

## Optional Chaining

```javascript
const title = response?.data?.task?.title;
```

## Nullish Coalescing

```javascript
const filter = savedFilter ?? "all";
```

## Classes

```javascript
class Task {
  constructor(title) {
    this.title = title;
  }

  complete() {
    this.completed = true;
  }
}
```

## Errors

```javascript
try {
  performOperation();
} catch (error) {
  console.error(error);
} finally {
  cleanUp();
}
```

---

# Common Language Mistakes

## Mistake 1: Using Assignment Instead of Comparison

Incorrect:

```javascript
if (task.completed = true) {
}
```

This assigns `true`.

Correct:

```javascript
if (task.completed === true) {
}
```

Or more simply:

```javascript
if (task.completed) {
}
```

## Mistake 2: Forgetting to Return

Incorrect:

```javascript
function getTitle(task) {
  task.title;
}
```

Correct:

```javascript
function getTitle(task) {
  return task.title;
}
```

## Mistake 3: Mutating a Collection Accidentally

Be aware that methods such as:

```javascript
push()
pop()
sort()
splice()
```

mutate arrays.

Methods such as:

```javascript
map()
filter()
```

return new arrays.

## Mistake 4: Treating `find()` as Guaranteed

```javascript
const task = tasks.find(
  (candidate) => candidate.id === id
);

task.complete();
```

If no task matches, `task` is `undefined`.

Safer:

```javascript
if (!task) {
  throw new Error("Task not found.");
}

task.complete();
```

## Mistake 5: Assuming JSON Restores Classes

Incorrect:

```javascript
const task = JSON.parse(rawValue);
task.complete();
```

Correct:

```javascript
const value = JSON.parse(rawValue);
const task = Task.fromJSON(value);
task.complete();
```

## Mistake 6: Catching and Ignoring Errors

Avoid:

```javascript
try {
  operation();
} catch {
}
```

Use:

```javascript
try {
  operation();
} catch (error) {
  console.error("Operation failed:", error);
}
```

---

# Primer 6 Completion Checklist

Before beginning Part 0, confirm that you can:

- [ ] Enable strict mode.
- [ ] Choose between `const` and `let`.
- [ ] Identify common JavaScript types.
- [ ] Use strict equality.
- [ ] Use logical operators.
- [ ] Write regular and arrow functions.
- [ ] Return values from functions.
- [ ] Explain function and block scope.
- [ ] Create and modify arrays.
- [ ] Use `map()`.
- [ ] Use `filter()`.
- [ ] Use `find()`.
- [ ] Create and update objects.
- [ ] Define object methods.
- [ ] Understand `this` in a method.
- [ ] Use destructuring.
- [ ] Use spread syntax.
- [ ] Explain shallow copying.
- [ ] Use optional chaining.
- [ ] Use nullish coalescing.
- [ ] Explain truthy and falsy values.
- [ ] Create class instances.
- [ ] Use static methods.
- [ ] Use inheritance and `super`.
- [ ] Throw and catch errors.
- [ ] Use `finally` for cleanup.
- [ ] Serialize values with JSON.
- [ ] Restore class instances from parsed data.

