# Appendix B: JavaScript Syntax Quick Reference

This appendix is a practical reference for the JavaScript syntax used throughout the series.

It is not intended to replace the full explanations in Parts 1–4. Instead, use it when you need a quick reminder of:

- Variables.
- Functions.
- Objects.
- Arrays.
- Destructuring.
- Spread syntax.
- Classes.
- Promises.
- Modules.
- Browser APIs.
- Common modern JavaScript patterns.

---

# 1. Comments

Comments explain code to people. JavaScript ignores them during execution.

## Single-Line Comments

```javascript
// This is a single-line comment.
const taskTitle = "Study JavaScript";
```

## Multi-Line Comments

```javascript
/*
 * This comment can span
 * several lines.
 */
const completed = false;
```

Use comments to explain:

- Why code exists.
- Why a non-obvious decision was made.
- A security consideration.
- An important browser behavior.
- A tricky algorithm.

Avoid comments that merely repeat the code:

```javascript
// Set title to task title.
task.title = taskTitle;
```

The code is already clear.

---

# 2. Variables

JavaScript provides `const` and `let`.

## `const`

Use `const` when the variable binding will not be reassigned.

```javascript
const applicationName = "Async Task Manager";
const maximumTitleLength = 120;
```

This is not allowed:

```javascript
const count = 1;
count = 2;
```

It causes an error because the binding cannot be reassigned.

## `let`

Use `let` when the variable must be reassigned.

```javascript
let currentFilter = "all";

currentFilter = "completed";
```

## Objects Declared with `const`

`const` prevents reassignment of the variable, but it does not make the object immutable.

```javascript
const task = {
  title: "Learn JavaScript",
  completed: false,
};

task.completed = true;
```

This is allowed because the object itself is still the same object.

This is not allowed:

```javascript
task = {
  title: "Different task",
  completed: false,
};
```

The variable cannot point to a new object.

## Arrays Declared with `const`

You can modify the contents:

```javascript
const tasks = [];

tasks.push("Learn arrays");
```

You cannot reassign the array:

```javascript
tasks = [];
```

---

# 3. Primitive Values

JavaScript has several primitive value types.

```javascript
const text = "Hello";
const number = 42;
const decimal = 3.14;
const isComplete = false;
const missingValue = undefined;
const emptyValue = null;
const uniqueValue = Symbol("id");
const largeNumber = 9007199254740993n;
```

Common primitive types include:

| Type | Example |
|---|---|
| String | `"Task"` |
| Number | `42` |
| Boolean | `true` |
| Undefined | `undefined` |
| Null | `null` |
| Symbol | `Symbol("key")` |
| BigInt | `123n` |

You can inspect a value with `typeof`:

```javascript
console.log(typeof "text"); // "string"
console.log(typeof 42); // "number"
console.log(typeof false); // "boolean"
console.log(typeof undefined); // "undefined"
console.log(typeof null); // "object"
```

The result for `typeof null` is a historical JavaScript behavior. Use an explicit check for `null`:

```javascript
if (value === null) {
  console.log("The value is null.");
}
```

---

# 4. Strings

## String Literals

```javascript
const first = "Double quotes";
const second = 'Single quotes';
const third = `Template literals`;
```

## Template Literals

Template literals use backticks and support interpolation:

```javascript
const taskTitle = "Learn modules";

const message = `The current task is: ${taskTitle}`;

console.log(message);
```

Output:

```text
The current task is: Learn modules
```

Expressions can be used inside `${}`:

```javascript
const completed = 3;
const total = 5;

console.log(`Completed ${completed} of ${total} tasks.`);
```

## Common String Methods

```javascript
const title = "  Learn JavaScript  ";

console.log(title.trim());
// "Learn JavaScript"

console.log(title.toUpperCase());
// "  LEARN JAVASCRIPT  "

console.log(title.toLowerCase());
// "  learn javascript  "

console.log(title.includes("JavaScript"));
// true

console.log(title.startsWith("  Learn"));
// true

console.log(title.endsWith("  "));
// true
```

## String Length

```javascript
const title = "Study";

console.log(title.length);
// 5
```

## Splitting a String

```javascript
const tags = "javascript,async,modules";

const tagList = tags.split(",");

console.log(tagList);
// ["javascript", "async", "modules"]
```

## Replacing Text

```javascript
const message = "Task status: pending";

const updatedMessage = message.replace(
  "pending",
  "completed"
);

console.log(updatedMessage);
// "Task status: completed"
```

---

# 5. Numbers and Numeric Validation

## Arithmetic

```javascript
const sum = 2 + 3;
const difference = 10 - 4;
const product = 5 * 2;
const quotient = 20 / 4;
const remainder = 7 % 2;
const exponent = 2 ** 3;
```

Results:

```javascript
console.log(sum); // 5
console.log(difference); // 6
console.log(product); // 10
console.log(quotient); // 5
console.log(remainder); // 1
console.log(exponent); // 8
```

## Incrementing and Decrementing

```javascript
let count = 0;

count += 1;
count++;

count -= 1;
count--;
```

## Number Validation

```javascript
Number.isInteger(10); // true
Number.isInteger(10.5); // false
Number.isNaN(Number("not a number")); // true
Number.isFinite(100); // true
```

## Converting Text to Numbers

```javascript
const input = "42";

const number = Number(input);

console.log(number);
// 42
```

Validate the result:

```javascript
const value = Number("abc");

if (Number.isNaN(value)) {
  console.log("The value is not a valid number.");
}
```

---

# 6. Booleans and Comparisons

## Boolean Values

```javascript
const isLoading = true;
const hasError = false;
```

## Strict Equality

Prefer strict equality:

```javascript
value === expectedValue;
value !== unexpectedValue;
```

Examples:

```javascript
5 === 5; // true
5 === "5"; // false
5 !== "5"; // true
```

Avoid relying on loose equality:

```javascript
5 == "5"; // true
```

Loose equality performs implicit type conversion, which can make code harder to predict.

## Relational Operators

```javascript
age > 18;
age >= 18;
age < 65;
age <= 65;
```

---

# 7. Logical Operators

## AND: `&&`

Both conditions must be true:

```javascript
if (task.completed && user.isAuthenticated) {
  showPrivateTaskDetails();
}
```

## OR: `||`

At least one condition must be true:

```javascript
const displayName = userName || "Anonymous";
```

If `userName` is a falsy value, `"Anonymous"` is used.

## NOT: `!`

Reverses a Boolean:

```javascript
const isActive = true;
const isInactive = !isActive;

console.log(isInactive);
// false
```

## Nullish Coalescing: `??`

Uses the fallback only when the left side is `null` or `undefined`:

```javascript
const savedFilter = null;

const filter = savedFilter ?? "all";

console.log(filter);
// "all"
```

Unlike `||`, it preserves valid falsy values such as `0`, `false`, and `""`:

```javascript
const savedCount = 0;

console.log(savedCount || 10);
// 10

console.log(savedCount ?? 10);
// 0
```

---

# 8. Conditional Statements

## `if`

```javascript
if (task.completed) {
  console.log("The task is complete.");
}
```

## `if`/`else`

```javascript
if (task.completed) {
  console.log("Completed");
} else {
  console.log("Active");
}
```

## `else if`

```javascript
if (filter === "all") {
  showAllTasks();
} else if (filter === "active") {
  showActiveTasks();
} else {
  showCompletedTasks();
}
```

## Ternary Operator

Use a ternary for a short two-option expression:

```javascript
const label = task.completed
  ? "Completed"
  : "Not completed";
```

This is equivalent to:

```javascript
let label;

if (task.completed) {
  label = "Completed";
} else {
  label = "Not completed";
}
```

Avoid deeply nested ternaries because they become difficult to read.

---

# 9. `switch`

Use `switch` when one value has several known alternatives:

```javascript
switch (filter) {
  case "all":
    showAllTasks();
    break;

  case "active":
    showActiveTasks();
    break;

  case "completed":
    showCompletedTasks();
    break;

  default:
    showAllTasks();
}
```

The `break` prevents execution from falling into the next case.

---

# 10. Functions

## Function Declaration

```javascript
function add(a, b) {
  return a + b;
}

console.log(add(2, 3));
// 5
```

## Function Expression

```javascript
const add = function (a, b) {
  return a + b;
};
```

## Arrow Function

```javascript
const add = (a, b) => {
  return a + b;
};
```

For a single expression, the return can be implicit:

```javascript
const add = (a, b) => a + b;
```

## One Parameter

Parentheses may be omitted for one simple parameter:

```javascript
const double = number => number * 2;
```

For consistency, many teams keep parentheses:

```javascript
const double = (number) => number * 2;
```

## No Parameters

```javascript
const getMessage = () => {
  return "Hello";
};
```

## Default Parameters

```javascript
function greet(name = "Anonymous") {
  return `Hello, ${name}`;
}

console.log(greet());
// Hello, Anonymous
```

## Rest Parameters

Rest parameters collect remaining arguments into an array:

```javascript
function sum(...numbers) {
  return numbers.reduce((total, number) => {
    return total + number;
  }, 0);
}

console.log(sum(1, 2, 3));
// 6
```

## Returning Early

Early returns reduce nesting:

```javascript
function renderTask(task) {
  if (!task) {
    return;
  }

  console.log(task.title);
}
```

Error handling commonly uses an early return:

```javascript
function handleResult(error, result) {
  if (error) {
    console.error(error);
    return;
  }

  console.log(result);
}
```

---

# 11. Scope

Scope determines where a variable can be accessed.

## Block Scope

`let` and `const` are block-scoped:

```javascript
if (true) {
  const message = "Inside the block";
  console.log(message);
}
```

This fails:

```javascript
console.log(message);
```

The variable exists only inside the `if` block.

## Function Scope

Function parameters and variables declared inside a function are local to that function:

```javascript
function createMessage() {
  const message = "Private message";
  return message;
}

console.log(createMessage());
```

This fails:

```javascript
console.log(message);
```

## Module Scope

Variables declared in a module are private to that module unless exported:

```javascript
const storageKey = "private-key";

export function saveValue(value) {
  localStorage.setItem(storageKey, value);
}
```

Another module cannot access `storageKey` directly.

---

# 12. Closures

A closure occurs when a function remembers variables from the scope where it was created.

```javascript
function createCounter() {
  let count = 0;

  return function increment() {
    count += 1;
    return count;
  };
}

const counter = createCounter();

console.log(counter());
// 1

console.log(counter());
// 2
```

The returned function still has access to `count`.

Closures are useful for:

- Private state.
- Factory functions.
- Event handlers.
- Callbacks.
- Configuration functions.

---

# 13. Arrays

## Creating Arrays

```javascript
const empty = [];

const tasks = [
  "Study callbacks",
  "Study Promises",
  "Study modules",
];
```

## Accessing Elements

```javascript
const firstTask = tasks[0];
const secondTask = tasks[1];
```

Array indexes start at zero.

## Array Length

```javascript
console.log(tasks.length);
```

## Adding Elements

```javascript
tasks.push("Study storage");
```

## Removing the Last Element

```javascript
const removedTask = tasks.pop();
```

## Removing the First Element

```javascript
const first = tasks.shift();
```

## Adding to the Beginning

```javascript
tasks.unshift("Review JavaScript");
```

---

# 14. Array Iteration Methods

## `forEach`

Use `forEach` when you want to perform an action for every item.

```javascript
tasks.forEach((task) => {
  console.log(task.title);
});
```

`forEach` does not create a new array.

## `map`

Use `map` to transform every item into a new array.

```javascript
const titles = tasks.map((task) => {
  return task.title;
});
```

Short form:

```javascript
const titles = tasks.map((task) => task.title);
```

## `filter`

Use `filter` to keep matching items.

```javascript
const completedTasks = tasks.filter((task) => {
  return task.completed;
});
```

Short form:

```javascript
const completedTasks = tasks.filter(
  (task) => task.completed
);
```

## `find`

Use `find` to return the first matching item.

```javascript
const task = tasks.find((task) => {
  return task.id === requestedId;
});
```

If no item matches, `find` returns `undefined`.

## `findIndex`

```javascript
const index = tasks.findIndex((task) => {
  return task.id === requestedId;
});
```

If no item matches, it returns `-1`.

## `some`

Returns `true` if at least one item matches.

```javascript
const hasCompletedTask = tasks.some(
  (task) => task.completed
);
```

## `every`

Returns `true` if every item matches.

```javascript
const allCompleted = tasks.every(
  (task) => task.completed
);
```

## `reduce`

Combines array values into one result.

```javascript
const completedCount = tasks.reduce(
  (count, task) => {
    return task.completed ? count + 1 : count;
  },
  0
);
```

A simpler version is often clearer:

```javascript
const completedCount = tasks.filter(
  (task) => task.completed
).length;
```

Use `reduce` when the accumulation logic is genuinely useful and readable.

---

# 15. Objects

## Object Literal

```javascript
const task = {
  id: 1,
  title: "Learn objects",
  completed: false,
};
```

## Reading Properties

```javascript
console.log(task.title);
console.log(task["title"]);
```

Dot notation is usually clearer when the property name is known:

```javascript
task.title;
```

Bracket notation is useful when the property name is dynamic:

```javascript
const propertyName = "title";

console.log(task[propertyName]);
```

## Adding and Updating Properties

```javascript
task.priority = "high";
task.completed = true;
```

## Deleting Properties

```javascript
delete task.priority;
```

Avoid deleting properties unnecessarily in performance-sensitive code. Prefer a stable object shape when practical.

## Object Methods

```javascript
const task = {
  title: "Learn methods",
  completed: false,

  complete() {
    this.completed = true;
  },
};

task.complete();
```

---

# 16. Object Shorthand

When variable names match property names:

```javascript
const title = "Learn shorthand";
const completed = false;

const task = {
  title,
  completed,
};
```

This is equivalent to:

```javascript
const task = {
  title: title,
  completed: completed,
};
```

---

# 17. Computed Property Names

```javascript
const propertyName = "title";

const task = {
  [propertyName]: "Learn computed properties",
};

console.log(task.title);
```

This is useful when creating objects with dynamic keys.

---

# 18. Destructuring

Destructuring extracts values from arrays or objects.

## Object Destructuring

```javascript
const task = {
  title: "Learn destructuring",
  completed: false,
};

const { title, completed } = task;

console.log(title);
console.log(completed);
```

## Renaming Destructured Values

```javascript
const {
  title: taskTitle,
  completed: isCompleted,
} = task;

console.log(taskTitle);
console.log(isCompleted);
```

## Default Values

```javascript
const {
  priority = "normal",
} = task;
```

If `task.priority` is missing, `priority` becomes `"normal"`.

## Nested Destructuring

```javascript
const response = {
  data: {
    tasks: [],
  },
};

const {
  data: { tasks },
} = response;
```

Avoid overly deep destructuring if it harms readability.

## Array Destructuring

```javascript
const coordinates = [10, 20];

const [x, y] = coordinates;

console.log(x);
console.log(y);
```

## Skipping Values

```javascript
const values = ["first", "second", "third"];

const [, second] = values;

console.log(second);
// "second"
```

---

# 19. Spread Syntax

Spread syntax uses `...`.

## Copying an Array

```javascript
const original = [1, 2, 3];
const copy = [...original];

copy.push(4);

console.log(original);
// [1, 2, 3]

console.log(copy);
// [1, 2, 3, 4]
```

This creates a shallow copy.

## Combining Arrays

```javascript
const first = [1, 2];
const second = [3, 4];

const combined = [...first, ...second];

console.log(combined);
// [1, 2, 3, 4]
```

## Copying an Object

```javascript
const task = {
  title: "Original",
  completed: false,
};

const updatedTask = {
  ...task,
  completed: true,
};
```

The later property overrides the earlier property.

## Combining Objects

```javascript
const baseTask = {
  title: "Learn JavaScript",
};

const metadata = {
  priority: "high",
};

const task = {
  ...baseTask,
  ...metadata,
};
```

## Rest Versus Spread

The same `...` syntax can have different meanings.

Spread expands values:

```javascript
const numbers = [1, 2, 3];

const copy = [...numbers];
```

Rest collects values:

```javascript
function logAll(...values) {
  console.log(values);
}
```

---

# 20. Optional Chaining

Optional chaining safely accesses a property when an earlier value may be `null` or `undefined`.

```javascript
const userName = user?.profile?.name;
```

Without optional chaining, this may throw:

```javascript
const userName = user.profile.name;
```

Optional chaining with function calls:

```javascript
onComplete?.();
```

This calls `onComplete` only if it exists and is callable.

Optional chaining should not replace validation when a value is required. If a required dependency is missing, an explicit error may be better.

---

# 21. Nullish Coalescing

Use `??` for defaults when only `null` and `undefined` should trigger the fallback.

```javascript
const savedFilter =
  localStorage.getItem("filter") ?? "all";
```

This preserves an empty string:

```javascript
const value = "" ?? "fallback";

console.log(value);
// ""
```

---

# 22. Classes

## Basic Class

```javascript
class Task {
  constructor(title) {
    this.title = title;
    this.completed = false;
  }

  complete() {
    this.completed = true;
  }
}
```

## Creating an Instance

```javascript
const task = new Task("Learn classes");
```

## Instance Methods

```javascript
task.complete();
```

## Checking an Instance

```javascript
console.log(task instanceof Task);
```

## Static Methods

```javascript
class Task {
  constructor(title) {
    this.title = title;
  }

  static createDefault() {
    return new Task("Untitled task");
  }
}

const task = Task.createDefault();
```

Static methods belong to the class, not to instances.

## Inheritance

```javascript
class ImportedTask extends Task {
  constructor(title, source) {
    super(title);
    this.source = source;
  }
}
```

`super(title)` calls the parent constructor.

## Overriding Methods

```javascript
class ImportedTask extends Task {
  getLabel() {
    return `Imported from ${this.source}`;
  }
}
```

## Calling the Parent Method

```javascript
class ImportedTask extends Task {
  getLabel() {
    return `Imported: ${super.getLabel()}`;
  }
}
```

---

# 23. Private Class Fields

Modern JavaScript supports private class fields using `#`.

```javascript
class Counter {
  #value = 0;

  increment() {
    this.#value += 1;
  }

  getValue() {
    return this.#value;
  }
}

const counter = new Counter();

counter.increment();

console.log(counter.getValue());
// 1
```

This fails:

```javascript
console.log(counter.#value);
```

Private fields can help protect internal state.

Use them when the class genuinely needs strong encapsulation. Do not add private fields merely for decoration.

---

# 24. Modules

## Exporting a Named Function

```javascript
export function formatTaskTitle(title) {
  return title.trim();
}
```

## Importing a Named Function

```javascript
import { formatTaskTitle } from "./format.js";
```

## Exporting a Class

```javascript
export class Task {
}
```

## Importing a Class

```javascript
import { Task } from "./models/task.js";
```

## Multiple Imports

```javascript
import {
  loadTasks,
  saveTasks,
} from "./storage-service.js";
```

## Default Export

```javascript
export default function startApplication() {
  console.log("Started");
}
```

Import:

```javascript
import startApplication from "./start.js";
```

## Browser Module Script

```html
<script type="module" src="./js/main.js"></script>
```

## Relative Import Paths

From:

```text
js/services/task-service.js
```

to:

```text
js/models/task.js
```

use:

```javascript
import { Task } from "../models/task.js";
```

The `.js` extension should be included in browser imports.

---

# 25. Promises

## Creating a Promise

```javascript
function wait(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve();
    }, milliseconds);
  });
}
```

## Resolving a Promise

```javascript
function getMessage() {
  return Promise.resolve("Completed");
}
```

## Rejecting a Promise

```javascript
function failOperation() {
  return Promise.reject(
    new Error("The operation failed.")
  );
}
```

## Consuming a Promise

```javascript
getMessage().then((message) => {
  console.log(message);
});
```

## Handling Rejection

```javascript
failOperation().catch((error) => {
  console.error(error.message);
});
```

## Cleanup

```javascript
performOperation()
  .then(handleSuccess)
  .catch(handleError)
  .finally(() => {
    console.log("Operation finished.");
  });
```

---

# 26. `async` and `await`

## Async Function

```javascript
async function getMessage() {
  return "Completed";
}
```

The function returns a Promise:

```javascript
getMessage().then((message) => {
  console.log(message);
});
```

## Awaiting a Promise

```javascript
async function loadMessage() {
  const message = await getMessage();

  console.log(message);
}
```

## Handling Errors

```javascript
async function loadTasks() {
  try {
    const tasks = await fetchTasks();
    renderTasks(tasks);
  } catch (error) {
    showError(error);
  }
}
```

## Cleanup with `finally`

```javascript
async function loadTasks() {
  setLoading(true);

  try {
    const tasks = await fetchTasks();
    renderTasks(tasks);
  } catch (error) {
    showError(error);
  } finally {
    setLoading(false);
  }
}
```

---

# 27. Parallel Promise Operations

## Sequential

```javascript
const users = await fetchUsers();
const tasks = await fetchTasks();
```

The second operation starts after the first finishes.

## Parallel

```javascript
const [users, tasks] = await Promise.all([
  fetchUsers(),
  fetchTasks(),
]);
```

Both operations begin before the function waits for their results.

Use parallel execution only when the operations are independent.

## `Promise.allSettled`

```javascript
const results = await Promise.allSettled([
  fetchUsers(),
  fetchTasks(),
]);

for (const result of results) {
  if (result.status === "fulfilled") {
    console.log(result.value);
  } else {
    console.error(result.reason);
  }
}
```

---

# 28. Error Handling

## Throwing an Error

```javascript
throw new Error("Something went wrong.");
```

## Catching an Error

```javascript
try {
  riskyOperation();
} catch (error) {
  console.error(error.message);
}
```

## `finally`

```javascript
try {
  performOperation();
} catch (error) {
  console.error(error);
} finally {
  releaseResources();
}
```

The `finally` block runs whether the operation succeeds or fails.

## Custom Error Class

```javascript
class ValidationError extends Error {
  constructor(message) {
    super(message);
    this.name = "ValidationError";
  }
}
```

Usage:

```javascript
throw new ValidationError(
  "Task title is required."
);
```

---

# 29. DOM Selection

## Select One Element

```javascript
const button = document.querySelector("#save-button");
```

## Select Multiple Elements

```javascript
const buttons = document.querySelectorAll("button");
```

## Select by Class

```javascript
const panels = document.querySelectorAll(".panel");
```

## Check for a Missing Element

```javascript
const form = document.querySelector("#task-form");

if (!form) {
  throw new Error("Task form was not found.");
}
```

---

# 30. Creating and Updating DOM Elements

## Create an Element

```javascript
const paragraph = document.createElement("p");
```

## Set Text Safely

```javascript
paragraph.textContent = "Task title";
```

Prefer `textContent` for user-provided content.

## Set a Class

```javascript
paragraph.className = "task-title";
```

## Add a Class

```javascript
paragraph.classList.add("task-completed");
```

## Remove a Class

```javascript
paragraph.classList.remove("task-completed");
```

## Toggle a Class

```javascript
paragraph.classList.toggle("task-completed");
```

## Append Elements

```javascript
container.append(paragraph);
```

Multiple elements can be appended:

```javascript
container.append(title, metadata, button);
```

## Remove All Children

```javascript
container.replaceChildren();
```

---

# 31. Events

## Register an Event Listener

```javascript
button.addEventListener("click", () => {
  console.log("Clicked");
});
```

## Form Submission

```javascript
form.addEventListener("submit", (event) => {
  event.preventDefault();

  console.log("Form handled by JavaScript.");
});
```

## Event Object

```javascript
input.addEventListener("input", (event) => {
  console.log(event.target.value);
});
```

## Event Delegation

Event delegation attaches one listener to a parent:

```javascript
taskList.addEventListener("click", (event) => {
  const button = event.target.closest("button");

  if (!button) {
    return;
  }

  console.log(button.dataset.taskId);
});
```

This can be useful when list items are created dynamically.

---

# 32. Data Attributes

HTML:

```html
<button data-task-id="42">Complete</button>
```

JavaScript:

```javascript
const taskId = button.dataset.taskId;

console.log(taskId);
// "42"
```

Data attributes are strings. Convert them when necessary:

```javascript
const numericTaskId = Number(button.dataset.taskId);
```

Validate the conversion:

```javascript
if (!Number.isInteger(numericTaskId)) {
  throw new Error("Invalid task ID.");
}
```

---

# 33. Browser Storage

## `localStorage`

```javascript
localStorage.setItem("theme", "light");

const theme = localStorage.getItem("theme");

localStorage.removeItem("theme");
```

## `sessionStorage`

```javascript
sessionStorage.setItem("filter", "completed");

const filter = sessionStorage.getItem("filter");
```

## Store an Object

Storage accepts strings, so use JSON:

```javascript
const settings = {
  filter: "completed",
  sortOrder: "newest",
};

localStorage.setItem(
  "settings",
  JSON.stringify(settings)
);
```

## Restore an Object

```javascript
const rawSettings = localStorage.getItem("settings");

if (rawSettings !== null) {
  const settings = JSON.parse(rawSettings);
  console.log(settings.filter);
}
```

## Safe Parsing

```javascript
function parseJSONSafely(value) {
  try {
    return JSON.parse(value);
  } catch {
    return null;
  }
}
```

For production code, it is often better to throw a descriptive application-specific error instead of returning `null` silently.

---

# 34. JSON

## Serialize

```javascript
const text = JSON.stringify({
  title: "Learn JSON",
  completed: false,
});
```

## Parse

```javascript
const value = JSON.parse(text);
```

## Serialize a Class Instance

```javascript
class Task {
  constructor(title) {
    this.title = title;
  }

  toJSON() {
    return {
      title: this.title,
    };
  }
}
```

Now:

```javascript
const task = new Task("Serialize me");

const text = JSON.stringify(task);

console.log(text);
```

The `toJSON()` method controls the serialized representation.

## Restore a Class Instance

```javascript
class Task {
  constructor(title) {
    this.title = title;
  }

  static fromJSON(value) {
    return new Task(value.title);
  }
}
```

Usage:

```javascript
const parsed = JSON.parse(text);
const task = Task.fromJSON(parsed);
```

---

# 35. Date Values

## Create a Date

```javascript
const now = new Date();
```

## Convert to ISO Text

```javascript
const timestamp = now.toISOString();
```

Example:

```text
2026-07-23T12:00:00.000Z
```

## Restore a Date

```javascript
const restoredDate = new Date(timestamp);
```

## Validate a Date

```javascript
if (Number.isNaN(restoredDate.getTime())) {
  throw new Error("Invalid date.");
}
```

Dates should generally be converted to strings before JSON storage.

---

# 36. Common Modern Patterns

## Normalize Input

```javascript
const normalizedTitle = title.trim();
```

## Validate Before Use

```javascript
if (normalizedTitle.length === 0) {
  throw new Error("A title is required.");
}
```

## Return a Copy

```javascript
getAll() {
  return [...this.tasks];
}
```

Returning a copy prevents callers from directly replacing the service’s internal array.

## Immutable Array Update

```javascript
tasks = tasks.map((task) => {
  if (task.id !== targetId) {
    return task;
  }

  return {
    ...task,
    completed: true,
  };
});
```

## Guard Clause

```javascript
if (isLoading) {
  return;
}
```

Guard clauses keep invalid or duplicate operations from proceeding.

## Normalize Errors

```javascript
function normalizeError(value) {
  if (value instanceof Error) {
    return value;
  }

  return new Error("Unknown error.");
}
```

## Cleanup in `finally`

```javascript
setLoading(true);

try {
  await loadData();
} finally {
  setLoading(false);
}
```

---

# 37. Useful Console Commands

## Log a Value

```javascript
console.log(value);
```

## Log a Warning

```javascript
console.warn("This may require attention.");
```

## Log an Error

```javascript
console.error("Operation failed.");
```

## Inspect an Object

```javascript
console.dir(object);
```

## Measure Execution Time

```javascript
console.time("operation");

performOperation();

console.timeEnd("operation");
```

## Assert a Condition

```javascript
console.assert(
  task.completed === true,
  "Task should be completed."
);
```

## Clear the Console

```javascript
console.clear();
```

---

# 38. Syntax Verification Exercise

Create a temporary file to verify several language features together.

### `syntax-reference-test.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Syntax Reference Test</title>
  </head>

  <body>
    <h1>Open the console</h1>

    <script type="module">
      const tasks = [
        {
          id: 1,
          title: "Learn syntax",
          completed: false,
        },
        {
          id: 2,
          title: "Practice syntax",
          completed: true,
        },
      ];

      const completedTasks = tasks.filter(
        (task) => task.completed
      );

      const titles = tasks.map((task) => task.title);

      const [firstTask] = tasks;

      const taskCopy = {
        ...firstTask,
        completed: true,
      };

      class Task {
        constructor({ id, title, completed = false }) {
          this.id = id;
          this.title = title;
          this.completed = completed;
        }

        getStatusLabel() {
          return this.completed
            ? "Completed"
            : "Not completed";
        }
      }

      const task = new Task(taskCopy);

      const result = {
        completedCount: completedTasks.length,
        titles,
        firstTaskTitle: firstTask.title,
        copiedTaskStatus: task.getStatusLabel(),
        fallbackFilter: null ?? "all",
      };

      console.log(result);
    </script>
  </body>
</html>
```

## Expected Output

The console should display an object equivalent to:

```javascript
{
  completedCount: 1,
  titles: [
    "Learn syntax",
    "Practice syntax"
  ],
  firstTaskTitle: "Learn syntax",
  copiedTaskStatus: "Completed",
  fallbackFilter: "all"
}
```

Delete the test file when finished.
