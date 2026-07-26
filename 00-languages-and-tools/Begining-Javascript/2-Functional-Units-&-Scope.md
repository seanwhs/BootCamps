# Part 2: Functional Units & Scope

In Part 1, the JavaScript file performed many operations from top to bottom. That approach is useful while learning, but larger programs become difficult to maintain if every instruction lives in one long sequence.

Part 2 introduces two ideas that help us organize code:

1. **Functions** — reusable groups of instructions.
2. **Scope** — the area of code where a variable can be accessed.

A function is like a named recipe:

```text
Recipe name: formatTaskTitle
Ingredients: a raw title
Instructions: clean and format the title
Result: a formatted title
```

Scope is like a room in a building. A variable created inside one room is not automatically available in every other room.

By the end of this part, you will be able to:

- Declare and call functions.
- Pass values into functions.
- Return values from functions.
- Distinguish parameters from arguments.
- Use function declarations.
- Use function expressions.
- Write arrow functions.
- Understand global, function, and block scope.
- Explain important differences between `var`, `let`, and `const`.
- Avoid accidental global variables.
- Build reusable functions for the task application.

---

## Part 2 Project Structure

We will continue using the existing project:

```text
javascript-foundations/
├── index.html
└── src/
    └── part-1.js
```

We will replace the Part 1 script with a Part 2 script. Keeping one active script prevents both lessons from writing to the same page at the same time.

Before changing the JavaScript, we need a better page heading so the browser identifies the current lesson.

---

# Step 1: Update the Page for Part 2

## The Target

We will update `index.html` so the page identifies itself as the Part 2 function and scope laboratory.

## The Concept

The HTML page is the application’s visible shell. The JavaScript supplies the behavior.

We will keep the same output elements:

- `#status-message`
- `#results-output`

Keeping stable element IDs means the new JavaScript can find the same page locations without changing the rest of the HTML.

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

    <title>JavaScript Foundations — Part 2</title>
  </head>

  <body>
    <main>
      <h1>JavaScript Foundations: Part 2</h1>

      <p>
        This page demonstrates functions, parameters, return values, and scope.
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

    <!--
      defer waits until the HTML has been parsed before executing the script.
    -->
    <script src="./src/part-2.js" defer></script>
  </body>
</html>
```

## The Verification

Do not refresh the browser yet, because `src/part-2.js` does not exist.

Confirm that the HTML contains:

```html
<script src="./src/part-2.js" defer></script>
```

The old `part-1.js` file should no longer be referenced.

[COMPLETED: Step 1 — Part 2 HTML shell prepared]  
[STARTING: Step 2 — Function entry point]

---

# Step 2: Create the Part 2 JavaScript Entry Point

## The Target

We will create:

```text
src/part-2.js
```

The file will:

- Find the page elements.
- Validate that they exist.
- Display a startup message.

## The Concept

A program should fail clearly when an essential dependency is missing.

If JavaScript expects an output element but the HTML does not contain it, silently continuing can produce confusing errors later. An explicit error points directly to the problem.

## The Implementation

### `src/part-2.js`

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
  "Part 2 JavaScript is running successfully.";

resultsOutputElement.textContent =
  "The function and scope laboratory is ready.";

console.log("Part 2 JavaScript loaded successfully.");
```

## The Verification

Refresh `index.html`.

The page should show:

```text
Part 2 JavaScript is running successfully.
```

and:

```text
The function and scope laboratory is ready.
```

The console should show:

```text
Part 2 JavaScript loaded successfully.
```

If you see a `404` or “failed to load resource” error, check that the file is located at:

```text
src/part-2.js
```

[COMPLETED: Step 2 — Part 2 entry point verified]  
[STARTING: Step 3 — Function declarations]

---

# Step 3: Function Declarations

## The Target

We will create and call a function declaration.

## The Concept

A function declaration defines a reusable operation.

```js
function functionName() {
  // instructions
}
```

Defining a function does not execute its body. The function runs only when it is called:

```js
functionName();
```

This is similar to writing down a recipe versus cooking the recipe. Writing the recipe prepares it for use; calling the function performs the instructions.

## The Implementation

Replace `src/part-2.js` with:

### `src/part-2.js`

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

/*
  This function declaration describes an operation.

  The function does not run while JavaScript reads this declaration.
  It runs when we call displayWelcomeMessage().
*/
function displayWelcomeMessage() {
  return "Welcome to functions and scope.";
}

const welcomeMessage = displayWelcomeMessage();

statusMessageElement.textContent =
  "Function declaration is working.";

resultsOutputElement.textContent = welcomeMessage;

console.log(welcomeMessage);
```

## The Verification

Refresh the page.

You should see:

```text
Function declaration is working.
```

and:

```text
Welcome to functions and scope.
```

The following call runs the function again:

```js
displayWelcomeMessage();
```

Because this function is declared at the top level of the script, it may be available in the browser console as a global in some browser configurations. The page output should not change because the returned value is not assigned or displayed a second time.

[COMPLETED: Step 3 — Function declaration verified]  
[STARTING: Step 4 — Parameters and arguments]

---

# Step 4: Parameters and Arguments

## The Target

We will make a function accept input.

## The Concept

A **parameter** is a named input listed in a function definition.

An **argument** is the actual value supplied when the function is called.

```js
function greetUser(name) {
  return `Hello, ${name}!`;
}

greetUser("Sam");
```

In this example:

- `name` is the parameter.
- `"Sam"` is the argument.

Parameters allow one function to work with many values instead of being permanently tied to one value.

## The Implementation

Replace `src/part-2.js` with:

### `src/part-2.js`

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

/*
  "name" is a parameter.

  The default value protects the function from producing an awkward
  message when no argument is supplied.
*/
function greetUser(name = "JavaScript learner") {
  return `Hello, ${name}!`;
}

const firstGreeting = greetUser("Amina");
const secondGreeting = greetUser("David");
const defaultGreeting = greetUser();

const greetings = [
  firstGreeting,
  secondGreeting,
  defaultGreeting
];

statusMessageElement.textContent =
  "Parameters and arguments are working.";

resultsOutputElement.textContent = greetings.join("\n");

console.log("First greeting:", firstGreeting);
console.log("Second greeting:", secondGreeting);
console.log("Default greeting:", defaultGreeting);
```

## The Verification

Refresh the browser.

You should see:

```text
Hello, Amina!
Hello, David!
Hello, JavaScript learner!
```

The third call supplies no argument:

```js
greetUser();
```

The default parameter is used:

```js
name = "JavaScript learner"
```

Try changing:

```js
greetUser("Amina");
```

to:

```js
greetUser("Priya");
```

The first line should change to:

```text
Hello, Priya!
```

[COMPLETED: Step 4 — Parameters, arguments, and defaults verified]  
[STARTING: Step 5 — Return values]

---

# Step 5: Return Values

## The Target

We will create functions that calculate and return useful values.

## The Concept

A function can send a result back to the code that called it. The `return` statement does this.

```js
function add(firstNumber, secondNumber) {
  return firstNumber + secondNumber;
}

const total = add(4, 6);
```

The function calculates `10`, and that value is assigned to `total`.

Once JavaScript reaches `return`, the function ends immediately. Code after `return` does not run.

A useful function usually has one clear responsibility. For example:

- `calculateTotal` calculates.
- `formatTaskTitle` formats.
- `isValidTaskTitle` validates.

This keeps the code easier to test and reuse.

## The Implementation

Replace `src/part-2.js` with:

### `src/part-2.js`

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

function addNumbers(firstNumber, secondNumber) {
  return firstNumber + secondNumber;
}

function calculateRectangleArea(width, height) {
  if (width < 0 || height < 0) {
    throw new Error("Rectangle dimensions cannot be negative.");
  }

  return width * height;
}

function formatTaskTitle(rawTitle) {
  return rawTitle.trim();
}

function isValidTaskTitle(taskTitle) {
  return taskTitle.length > 0;
}

const sum = addNumbers(8, 4);
const area = calculateRectangleArea(5, 3);

const rawTaskTitle = "  Practice return values  ";
const formattedTaskTitle = formatTaskTitle(rawTaskTitle);
const isTaskTitleValid = isValidTaskTitle(formattedTaskTitle);

const results = [
  `8 + 4 = ${sum}`,
  `Rectangle area: ${area}`,
  `Formatted title: "${formattedTaskTitle}"`,
  `Title is valid: ${isTaskTitleValid}`
];

statusMessageElement.textContent =
  "Return values are working.";

resultsOutputElement.textContent = results.join("\n");

console.log("Sum:", sum);
console.log("Area:", area);
console.log("Formatted title:", formattedTaskTitle);
console.log("Valid title:", isTaskTitleValid);
```

## The Verification

Refresh the page.

You should see:

```text
8 + 4 = 12
Rectangle area: 15
Formatted title: "Practice return values"
Title is valid: true
```

Test the validation function by changing:

```js
const rawTaskTitle = "  Practice return values  ";
```

to:

```js
const rawTaskTitle = "       ";
```

The output should include:

```text
Formatted title: ""
Title is valid: false
```

Test the error handling by changing:

```js
const area = calculateRectangleArea(5, 3);
```

to:

```js
const area = calculateRectangleArea(-5, 3);
```

The browser console should show:

```text
Error: Rectangle dimensions cannot be negative.
```

This is intentional defensive behavior. Invalid input should be rejected instead of producing an invalid result.

Restore the valid dimensions before continuing.

[COMPLETED: Step 5 — Return values and validation verified]  
[STARTING: Step 6 — Function expressions]

---

# Step 6: Function Expressions

## The Target

We will store a function in a variable.

## The Concept

A function expression creates a function and assigns it to a variable:

```js
const multiply = function (firstNumber, secondNumber) {
  return firstNumber * secondNumber;
};
```

The function is a value, just like a string or number. Because functions are values, they can be:

- Stored in variables.
- Passed into other functions.
- Returned from functions.
- Stored in arrays and objects.

Function declarations and function expressions are both useful.

A key difference is that function declarations are hoisted in a way that lets you call them before their declaration appears in the file. Function expressions assigned to `const` cannot be used before the assignment runs.

## The Implementation

Replace `src/part-2.js` with:

### `src/part-2.js`

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

/*
  Function declaration.
*/
function addNumbers(firstNumber, secondNumber) {
  return firstNumber + secondNumber;
}

/*
  Function expression.

  The anonymous function is assigned to the constant multiplyNumbers.
*/
const multiplyNumbers = function (firstNumber, secondNumber) {
  return firstNumber * secondNumber;
};

const sum = addNumbers(8, 4);
const product = multiplyNumbers(8, 4);

const results = [
  `Sum: ${sum}`,
  `Product: ${product}`
];

statusMessageElement.textContent =
  "Function expressions are working.";

resultsOutputElement.textContent = results.join("\n");

console.log("Function declaration result:", sum);
console.log("Function expression result:", product);
```

## The Verification

Refresh the page.

You should see:

```text
Sum: 12
Product: 32
```

Now temporarily place this line at the top of the file, before the function expression:

```js
console.log(multiplyNumbers(2, 3));
```

Refresh the page.

You should receive a `ReferenceError` because `multiplyNumbers` is not initialized until JavaScript reaches its assignment.

Remove the temporary line before continuing.

[COMPLETED: Step 6 — Function expressions verified]  
[STARTING: Step 7 — Arrow functions]

---

# Step 7: Arrow Functions

## The Target

We will rewrite a function expression using arrow-function syntax.

## The Concept

An arrow function is a shorter way to write many function expressions.

Traditional function expression:

```js
const add = function (firstNumber, secondNumber) {
  return firstNumber + secondNumber;
};
```

Arrow function:

```js
const add = (firstNumber, secondNumber) => {
  return firstNumber + secondNumber;
};
```

When an arrow function contains only one expression, it can use an implicit return:

```js
const add = (firstNumber, secondNumber) =>
  firstNumber + secondNumber;
```

The expression’s result is returned automatically.

Use braces when the function needs multiple instructions:

```js
const describeNumber = (number) => {
  const doubled = number * 2;
  return `Doubled value: ${doubled}`;
};
```

## The Implementation

Replace `src/part-2.js` with:

### `src/part-2.js`

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

const addNumbers = (firstNumber, secondNumber) =>
  firstNumber + secondNumber;

const multiplyNumbers = (firstNumber, secondNumber) => {
  return firstNumber * secondNumber;
};

const formatTaskTitle = (rawTitle) => {
  const cleanedTitle = rawTitle.trim();

  return cleanedTitle;
};

const sum = addNumbers(8, 4);
const product = multiplyNumbers(8, 4);
const formattedTitle = formatTaskTitle(
  "  Practice arrow functions  "
);

const results = [
  `Sum: ${sum}`,
  `Product: ${product}`,
  `Formatted title: "${formattedTitle}"`
];

statusMessageElement.textContent =
  "Arrow functions are working.";

resultsOutputElement.textContent = results.join("\n");

console.log("Arrow-function results:", {
  sum,
  product,
  formattedTitle
});
```

## The Verification

Refresh the page.

Expected output:

```text
Sum: 12
Product: 32
Formatted title: "Practice arrow functions"
```

Compare these two functions:

```js
const doubleA = (number) => number * 2;
```

```js
const doubleB = (number) => {
  return number * 2;
};
```

They return the same result:

```js
doubleA(5); // 10
doubleB(5); // 10
```

The braces version requires the explicit `return`.

This does **not** return a value:

```js
const incorrectDouble = (number) => {
  number * 2;
};
```

The braces create a function body, and without `return`, the function returns `undefined`.

[COMPLETED: Step 7 — Arrow functions verified]  
[STARTING: Step 8 — Global, function, and block scope]

---

# Step 8: Understanding Scope

## The Target

We will demonstrate three kinds of scope:

- Global scope.
- Function scope.
- Block scope.

## The Concept

**Scope** determines where a variable can be accessed.

Think of scope as rooms:

```text
Building
└── Room A
    └── Closet inside Room A
```

A variable created in the building may be visible in many rooms. A variable created in Room A is not automatically visible in another room. A variable created in the closet is even more restricted.

### Global scope

A variable declared outside functions and blocks has top-level scope.

### Function scope

A variable declared inside a function can be used inside that function, but not outside it.

### Block scope

A block is code surrounded by braces:

```js
{
  // block
}
```

`let` and `const` are limited to the block where they are declared.

## The Implementation

Replace `src/part-2.js` with:

### `src/part-2.js`

```js
"use strict";

/*
  This variable is declared at the top level of the script.

  It is available to the code in this file.
*/
const applicationName = "Task Practice Application";

const statusMessageElement = document.querySelector("#status-message");
const resultsOutputElement = document.querySelector("#results-output");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

if (resultsOutputElement === null) {
  throw new Error("Could not find the #results-output element.");
}

function createScopeReport() {
  /*
    This variable belongs to the createScopeReport function.
    It cannot be accessed outside this function.
  */
  const functionMessage = "This value belongs to the function.";

  let blockMessage = "No block message yet.";

  {
    /*
      This variable belongs only to this block.
    */
    const blockOnlyMessage = "This value belongs to the block.";

    blockMessage = blockOnlyMessage;
  }

  return [
    `Application name: ${applicationName}`,
    `Function message: ${functionMessage}`,
    `Block message copied before block ended: ${blockMessage}`
  ];
}

const scopeResults = createScopeReport();

statusMessageElement.textContent =
  "Global, function, and block scope are working.";

resultsOutputElement.textContent = scopeResults.join("\n");

console.log("Scope results:", scopeResults);
```

## The Verification

Refresh the page.

You should see:

```text
Application name: Task Practice Application
Function message: This value belongs to the function.
Block message copied before block ended: This value belongs to the block.
```

Now temporarily add this line after the function call:

```js
console.log(functionMessage);
```

Refresh the page.

You should see:

```text
ReferenceError: functionMessage is not defined
```

That variable exists only inside `createScopeReport`.

Now temporarily add:

```js
console.log(blockOnlyMessage);
```

You should also receive a `ReferenceError`, because `blockOnlyMessage` exists only inside the braces where it was declared.

Remove both temporary lines.

[COMPLETED: Step 8 — Function and block scope verified]  
[STARTING: Step 9 — `var`, `let`, and `const`]

---

# Step 9: `var`, `let`, and `const`

## The Target

We will compare the scope and reassignment behavior of `var`, `let`, and `const`.

## The Concept

### `var`

`var` is function-scoped, not block-scoped.

```js
function example() {
  if (true) {
    var message = "hello";
  }

  console.log(message); // works
}
```

This behavior can allow values to escape blocks unexpectedly.

### `let`

`let` is block-scoped and can be reassigned:

```js
let count = 1;
count = 2;
```

### `const`

`const` is block-scoped and cannot be reassigned:

```js
const name = "Amina";
```

This fails:

```js
name = "David";
```

Modern practice:

```text
Use const by default.
Use let when reassignment is required.
Avoid var in new code.
```

## The Implementation

Replace `src/part-2.js` with:

### `src/part-2.js`

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

function demonstrateVariableDeclarations() {
  var functionScopedValue = "var belongs to the function scope.";
  let reassignableValue = "let can be changed.";
  const fixedBindingValue = "const cannot be reassigned.";

  reassignableValue = "let was reassigned successfully.";

  let blockResult;
  const blockResults = [];

  {
    var varInsideBlock = "var escaped the block.";
    let letInsideBlock = "let stayed inside the block.";
    const constInsideBlock = "const stayed inside the block.";

    blockResults.push(letInsideBlock);
    blockResults.push(constInsideBlock);

    blockResult = blockResults.join(" ");
  }

  /*
    varInsideBlock is accessible here because var is function-scoped.
    This is one reason var can be surprising.
  */
  return [
    functionScopedValue,
    reassignableValue,
    fixedBindingValue,
    blockResult,
    varInsideBlock
  ];
}

const declarationResults = demonstrateVariableDeclarations();

statusMessageElement.textContent =
  "var, let, and const examples are working.";

resultsOutputElement.textContent = declarationResults.join("\n");

console.log("Declaration results:", declarationResults);
```

## The Verification

Refresh the page.

You should see:

```text
var belongs to the function scope.
let was reassigned successfully.
const cannot be reassigned.
let stayed inside the block. const stayed inside the block.
var escaped the block.
```

The final line is the important one:

```text
var escaped the block.
```

This does not mean `var` escaped the function. It remains inside `demonstrateVariableDeclarations`, but it is available after the `if`-like block because `var` is function-scoped.

Now temporarily add this inside the function after the block:

```js
console.log(letInsideBlock);
```

Refresh the browser. It should fail with a `ReferenceError`.

Remove the temporary line.

[COMPLETED: Step 9 — `var`, `let`, and `const` verified]  
[STARTING: Step 10 — Functions as values]

---

# Step 10: Passing Functions as Arguments

## The Target

We will pass a function into another function.

## The Concept

Because functions are values, one function can receive another function as an argument.

A function passed to another function is often called a **callback**. A callback is simply a function that another function can call later.

Imagine giving a worker:

1. A list of items.
2. Instructions for what to do with each item.

The worker does not need to know every possible instruction in advance. It receives the instruction as a function.

## The Implementation

Replace `src/part-2.js` with:

### `src/part-2.js`

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

function applyToEachValue(values, operation) {
  const results = [];

  for (const value of values) {
    results.push(operation(value));
  }

  return results;
}

const numbers = [1, 2, 3, 4];

const doubledNumbers = applyToEachValue(
  numbers,
  (number) => number * 2
);

const formattedNumbers = applyToEachValue(
  numbers,
  (number) => `Number: ${number}`
);

const results = [
  `Original numbers: ${numbers.join(", ")}`,
  `Doubled numbers: ${doubledNumbers.join(", ")}`,
  ...formattedNumbers
];

statusMessageElement.textContent =
  "Functions can be passed as values.";

resultsOutputElement.textContent = results.join("\n");

console.log("Original numbers:", numbers);
console.log("Doubled numbers:", doubledNumbers);
console.log("Formatted numbers:", formattedNumbers);
```

## The Verification

Refresh the page.

Expected output:

```text
Original numbers: 1, 2, 3, 4
Doubled numbers: 2, 4, 6, 8
Number: 1
Number: 2
Number: 3
Number: 4
```

The same `applyToEachValue` function performed two different operations because we supplied different callbacks.

[COMPLETED: Step 10 — Callback functions verified]  
[STARTING: Step 11 — Closures and preserved scope]

---

# Step 11: Closures

## The Target

We will create a function that remembers a value from the scope where it was created.

## The Concept

A **closure** occurs when a function keeps access to variables from its surrounding scope, even after the surrounding function has finished running.

Imagine a small locked storage box:

1. A setup function places a value inside.
2. The setup function finishes.
3. A returned function still has the key to the box.

Closures are useful for:

- Private state.
- Counters.
- Configuration.
- Factory functions.
- Event handlers.

## The Implementation

Replace `src/part-2.js` with:

### `src/part-2.js`

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

function createCounter(startingValue = 0) {
  let currentValue = startingValue;

  return function increaseCounter() {
    currentValue += 1;
    return currentValue;
  };
}

const firstCounter = createCounter(0);
const secondCounter = createCounter(10);

const results = [
  `First counter: ${firstCounter()}`,
  `First counter: ${firstCounter()}`,
  `Second counter: ${secondCounter()}`,
  `First counter: ${firstCounter()}`,
  `Second counter: ${secondCounter()}`
];

statusMessageElement.textContent =
  "Closures are working.";

resultsOutputElement.textContent = results.join("\n");

console.log("Counter results:", results);
```

## The Verification

Refresh the page.

You should see:

```text
First counter: 1
First counter: 2
Second counter: 11
First counter: 3
Second counter: 12
```

The counters have separate private values:

```text
firstCounter  → 1, 2, 3
secondCounter → 11, 12
```

Calling one counter does not affect the other.

[COMPLETED: Step 11 — Closure behavior verified]  
[STARTING: Step 12 — Building reusable task functions]

---

# Step 12: Functions for the Task Application

## The Target

We will create reusable functions that will later support the task application.

These functions will:

- Clean task titles.
- Validate titles.
- Create task objects.
- Summarize task state.
- Render task-like text for the current page.

## The Concept

Instead of placing all task behavior in one large event handler, we will separate responsibilities.

Each function will have one main job:

```text
cleanTaskTitle       → remove unnecessary whitespace
isValidTaskTitle     → reject empty titles
createTask           → construct consistent task data
getTaskDescription   → create readable output
```

This makes functions easier to test and reuse.

## The Implementation

Replace `src/part-2.js` with:

### `src/part-2.js`

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

/*
  Cleans user-entered text.

  The function does not change the original string because strings are
  primitive values and string methods return new strings.
*/
function cleanTaskTitle(rawTitle) {
  return rawTitle.trim();
}

/*
  A valid task must contain at least one character after trimming.
*/
function isValidTaskTitle(taskTitle) {
  return taskTitle.length > 0;
}

/*
  Creates one consistent task object.

  The id is generated from the current timestamp for this educational
  browser-only application. A database-backed application would normally
  generate IDs on the server or use a UUID.
*/
function createTask(rawTitle, id = Date.now()) {
  const title = cleanTaskTitle(rawTitle);

  if (!isValidTaskTitle(title)) {
    throw new Error("A task title cannot be empty.");
  }

  return {
    id,
    title,
    completed: false
  };
}

function getTaskDescription(task) {
  const completionLabel = task.completed
    ? "complete"
    : "incomplete";

  return `${task.id}: ${task.title} (${completionLabel})`;
}

const firstTask = createTask(
  "  Learn function declarations  ",
  1
);

const secondTask = createTask(
  "Practice scope rules",
  2
);

secondTask.completed = true;

const tasks = [
  firstTask,
  secondTask
];

const taskDescriptions = [];

for (const task of tasks) {
  taskDescriptions.push(getTaskDescription(task));
}

statusMessageElement.textContent =
  "Reusable task functions are working.";

resultsOutputElement.textContent = taskDescriptions.join("\n");

console.log("Tasks:", tasks);
```

## The Verification

Refresh the browser.

You should see:

```text
1: Learn function declarations (incomplete)
2: Practice scope rules (complete)
```

Notice that the first title was cleaned:

```text
"  Learn function declarations  "
```

became:

```text
"Learn function declarations"
```

Test invalid input by changing:

```js
const secondTask = createTask(
  "Practice scope rules",
  2
);
```

to:

```js
const secondTask = createTask(
  "      ",
  2
);
```

Refresh the page.

The console should show:

```text
Error: A task title cannot be empty.
```

Restore the valid title before continuing.

[COMPLETED: Step 12 — Reusable task functions verified]  
[STARTING: Step 13 — Complete Part 2 implementation]

---

# Step 13: Complete Part 2 File

## The Target

We will consolidate the complete Part 2 example into one final file.

## The Concept

The final file demonstrates:

- Function declarations.
- Parameters.
- Default parameters.
- Return values.
- Function expressions.
- Arrow functions.
- Scope.
- `var`, `let`, and `const`.
- Callbacks.
- Closures.
- Task-oriented functions.

The code intentionally keeps related examples together so you can inspect them in one place.

## The Implementation

### `src/part-2.js`

```js
"use strict";

/*
  Part 2 demonstrates:

  - Function declarations
  - Parameters and arguments
  - Default parameters
  - Return values
  - Function expressions
  - Arrow functions
  - Global, function, and block scope
  - var, let, and const
  - Callback functions
  - Closures
  - Reusable task functions
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
  FUNCTION DECLARATION
*/

function greetUser(name = "JavaScript learner") {
  return `Hello, ${name}!`;
}

/*
  PARAMETER VALIDATION AND RETURN VALUES
*/

function addNumbers(firstNumber, secondNumber) {
  return firstNumber + secondNumber;
}

function calculateRectangleArea(width, height) {
  if (!Number.isFinite(width) || !Number.isFinite(height)) {
    throw new TypeError(
      "Rectangle dimensions must be finite numbers."
    );
  }

  if (width < 0 || height < 0) {
    throw new RangeError(
      "Rectangle dimensions cannot be negative."
    );
  }

  return width * height;
}

function formatTaskTitle(rawTitle) {
  if (typeof rawTitle !== "string") {
    throw new TypeError("Task title must be a string.");
  }

  return rawTitle.trim();
}

function isValidTaskTitle(taskTitle) {
  return taskTitle.length > 0;
}

/*
  FUNCTION EXPRESSION
*/

const multiplyNumbers = function (firstNumber, secondNumber) {
  return firstNumber * secondNumber;
};

/*
  ARROW FUNCTIONS
*/

const subtractNumbers = (firstNumber, secondNumber) =>
  firstNumber - secondNumber;

const createUppercaseLabel = (value) => {
  return value.toUpperCase();
};

/*
  SCOPE
*/

const applicationName = "Task Practice Application";

function createScopeReport() {
  const functionMessage =
    "This value belongs to the function.";

  let blockMessage = "No block message yet.";

  {
    const blockOnlyMessage =
      "This value belongs only to the block.";

    blockMessage = blockOnlyMessage;
  }

  return [
    `Application: ${applicationName}`,
    `Function: ${functionMessage}`,
    `Block value copied: ${blockMessage}`
  ];
}

/*
  VAR, LET, AND CONST
*/

function demonstrateVariableDeclarations() {
  var functionScopedValue = "var is function-scoped.";
  let reassignableValue = "let can be reassigned.";
  const fixedBindingValue = "const cannot be reassigned.";

  reassignableValue = "let was reassigned.";

  let blockResult;

  {
    var varInsideBlock = "var is visible after the block.";
    const constInsideBlock =
      "const remains limited to the block.";

    blockResult = constInsideBlock;
  }

  return [
    functionScopedValue,
    reassignableValue,
    fixedBindingValue,
    blockResult,
    varInsideBlock
  ];
}

/*
  CALLBACK FUNCTIONS
*/

function applyToEachValue(values, operation) {
  if (!Array.isArray(values)) {
    throw new TypeError("values must be an array.");
  }

  if (typeof operation !== "function") {
    throw new TypeError("operation must be a function.");
  }

  const results = [];

  for (const value of values) {
    results.push(operation(value));
  }

  return results;
}

/*
  CLOSURES
*/

function createCounter(startingValue = 0) {
  if (!Number.isInteger(startingValue)) {
    throw new TypeError(
      "The counter starting value must be an integer."
    );
  }

  let currentValue = startingValue;

  return function increaseCounter() {
    currentValue += 1;
    return currentValue;
  };
}

/*
  TASK FUNCTIONS
*/

function createTask(rawTitle, id = Date.now()) {
  const title = formatTaskTitle(rawTitle);

  if (!isValidTaskTitle(title)) {
    throw new Error("A task title cannot be empty.");
  }

  if (!Number.isSafeInteger(id) || id < 0) {
    throw new RangeError(
      "Task id must be a non-negative safe integer."
    );
  }

  return {
    id,
    title,
    completed: false
  };
}

function getTaskDescription(task) {
  if (
    task === null ||
    typeof task !== "object" ||
    typeof task.id !== "number" ||
    typeof task.title !== "string" ||
    typeof task.completed !== "boolean"
  ) {
    throw new TypeError("Invalid task object.");
  }

  const completionLabel = task.completed
    ? "complete"
    : "incomplete";

  return `${task.id}: ${task.title} (${completionLabel})`;
}

/*
  FUNCTION EXECUTION
*/

const greetingResults = [
  greetUser("Amina"),
  greetUser("David"),
  greetUser()
];

const arithmeticResults = [
  `8 + 4 = ${addNumbers(8, 4)}`,
  `8 * 4 = ${multiplyNumbers(8, 4)}`,
  `8 - 4 = ${subtractNumbers(8, 4)}`,
  `Rectangle area = ${calculateRectangleArea(5, 3)}`
];

const callbackInput = [1, 2, 3, 4];

const doubledNumbers = applyToEachValue(
  callbackInput,
  (number) => number * 2
);

const uppercaseLabels = applyToEachValue(
  ["variables", "functions", "scope"],
  createUppercaseLabel
);

const firstCounter = createCounter(0);
const secondCounter = createCounter(10);

const counterResults = [
  `First counter: ${firstCounter()}`,
  `First counter: ${firstCounter()}`,
  `Second counter: ${secondCounter()}`,
  `First counter: ${firstCounter()}`,
  `Second counter: ${secondCounter()}`
];

const firstTask = createTask(
  "  Learn function declarations  ",
  1
);

const secondTask = createTask(
  "Practice scope rules",
  2
);

secondTask.completed = true;

const tasks = [
  firstTask,
  secondTask
];

const taskResults = [];

for (const task of tasks) {
  taskResults.push(getTaskDescription(task));
}

const allResults = [
  "Greetings:",
  ...greetingResults,
  "",
  "Arithmetic:",
  ...arithmeticResults,
  "",
  "Scope:",
  ...createScopeReport(),
  "",
  "Declarations:",
  ...demonstrateVariableDeclarations(),
  "",
  "Callbacks:",
  `Doubled numbers: ${doubledNumbers.join(", ")}`,
  `Uppercase labels: ${uppercaseLabels.join(", ")}`,
  "",
  "Closures:",
  ...counterResults,
  "",
  "Tasks:",
  ...taskResults
];

statusMessageElement.textContent =
  "Part 2 functions and scope are working successfully.";

resultsOutputElement.textContent = allResults.join("\n");

console.log("Part 2 loaded successfully.");
console.log("Tasks:", tasks);
console.log("Doubled numbers:", doubledNumbers);
console.log("Counter results:", counterResults);
```

## The Verification

Refresh the browser.

The page should display sections similar to:

```text
Greetings:
Hello, Amina!
Hello, David!
Hello, JavaScript learner!

Arithmetic:
8 + 4 = 12
8 * 4 = 32
8 - 4 = 4
Rectangle area = 15

Scope:
Application: Task Practice Application
Function: This value belongs to the function.
Block value copied: This value belongs only to the block.

Declarations:
var is function-scoped.
let was reassigned.
const cannot be reassigned.
const remains limited to the block.
var is visible after the block.

Callbacks:
Doubled numbers: 2, 4, 6, 8
Uppercase labels: VARIABLES, FUNCTIONS, SCOPE

Closures:
First counter: 1
First counter: 2
Second counter: 11
First counter: 3
Second counter: 12

Tasks:
1: Learn function declarations (incomplete)
2: Practice scope rules (complete)
```

The status message should be:

```text
Part 2 functions and scope are working successfully.
```

The console should contain no red errors.

[COMPLETED: Step 13 — Complete Part 2 implementation verified]  
[STARTING: Part 2 reference section]

---

# Part 2 Reference: Functions and Scope

## Function Declaration Syntax

```js
function functionName(parameterOne, parameterTwo) {
  return parameterOne + parameterTwo;
}
```

Call it with arguments:

```js
const result = functionName(2, 3);
```

The parameters are local variables created for that function call.

---

## Function Expression Syntax

```js
const functionName = function (parameter) {
  return parameter;
};
```

The function is assigned to a variable.

The semicolon belongs to the variable assignment:

```js
const functionName = function () {
  return "result";
};
```

---

## Arrow Function Syntax

One parameter:

```js
const square = number => number * number;
```

Multiple parameters:

```js
const add = (firstNumber, secondNumber) =>
  firstNumber + secondNumber;
```

Multiple statements:

```js
const describe = (value) => {
  const label = String(value);
  return `Value: ${label}`;
};
```

Remember:

```js
const incorrect = (value) => {
  value * 2;
};
```

returns `undefined`.

Correct:

```js
const correct = (value) => {
  return value * 2;
};
```

or:

```js
const concise = (value) => value * 2;
```

---

## Parameters Versus Arguments

```js
function createLabel(text) {
  return `Label: ${text}`;
}

createLabel("Important");
```

- `text` is a parameter.
- `"Important"` is an argument.

A function can accept multiple arguments:

```js
function createTaskSummary(title, completed) {
  return `${title}: ${completed}`;
}

createTaskSummary("Read", false);
```

---

## Default Parameters

```js
function greet(name = "Guest") {
  return `Hello, ${name}`;
}
```

When called without an argument:

```js
greet();
```

the default is used.

When called with an argument:

```js
greet("Amina");
```

the supplied value is used.

A default applies when the argument is `undefined`, not generally when it is an empty string:

```js
greet(""); // Hello, 
```

Input validation should handle empty strings separately.

---

## Return Versus Console Logging

These are different:

```js
function incorrectAdd(first, second) {
  console.log(first + second);
}
```

This displays a result but returns `undefined`.

```js
function correctAdd(first, second) {
  return first + second;
}
```

This sends the result back to the caller.

Use `return` when other code needs to use the result:

```js
const total = correctAdd(2, 3);
```

Use `console.log` for diagnostics and inspection:

```js
console.log(total);
```

---

## Scope Rules

### Top-level scope

```js
const applicationName = "Application";

function showName() {
  return applicationName;
}
```

The function can read `applicationName` because it was declared in an outer scope.

### Function scope

```js
function example() {
  const privateMessage = "private";
}

console.log(privateMessage); // ReferenceError
```

### Block scope

```js
if (true) {
  const message = "inside block";
}

console.log(message); // ReferenceError
```

`let` and `const` are block-scoped.

---

## The Temporal Dead Zone

`let` and `const` are technically known to the JavaScript engine before execution reaches their declaration, but they cannot be accessed before initialization.

```js
console.log(message);
const message = "Hello";
```

This produces a `ReferenceError`.

This protected period is commonly called the **temporal dead zone**.

Avoid relying on declaration ordering tricks. Declare variables before using them.

---

## `var` Hoisting

`var` behaves differently:

```js
console.log(message);
var message = "Hello";
```

The variable is hoisted, but its value is initially `undefined`, so the output is:

```text
undefined
```

This behavior can hide mistakes. Prefer `let` and `const`.

---

## Function Scope Versus Block Scope

```js
function example() {
  if (true) {
    var oldStyle = "var";
    let modernValue = "let";
    const fixedValue = "const";
  }

  console.log(oldStyle); // works
  console.log(modernValue); // ReferenceError
  console.log(fixedValue); // ReferenceError
}
```

`var` ignores the block boundary. `let` and `const` respect it.

---

## Pure Functions

A **pure function** produces the same output for the same input and does not change outside data.

```js
function add(firstNumber, secondNumber) {
  return firstNumber + secondNumber;
}
```

This function is pure.

An impure function changes external state:

```js
let total = 0;

function addToTotal(value) {
  total += value;
}
```

Pure functions are easier to test because they do not depend on hidden state.

Prefer pure functions for calculations and formatting. Keep state-changing operations explicit.

---

## Function Design Guidelines

A useful function should generally:

- Have one clear responsibility.
- Use a descriptive verb-based name.
- Accept necessary input through parameters.
- Return a useful result.
- Avoid unexpected changes to global variables.
- Validate input when invalid values would cause trouble.
- Avoid excessive parameter counts.
- Be small enough to understand without scrolling through a large file.

Good names:

```js
createTask()
formatTaskTitle()
isValidTaskTitle()
calculateTotal()
renderTask()
```

Unclear names:

```js
doThing()
process()
handleIt()
x()
```

---

## Part 2 Completion Checklist

Before moving to Part 3, confirm that you can answer:

- What is a function?
- What is the difference between a parameter and an argument?
- What does `return` do?
- What is the difference between a function declaration and expression?
- How does arrow-function syntax work?
- What happens when an arrow function uses braces but no `return`?
- What is global scope?
- What is function scope?
- What is block scope?
- Why is `var` usually avoided in new code?
- When should you use `let` instead of `const`?
- What is a callback?
- What is a closure?
- Why are small pure functions easier to test?

Your working page should end with:

```text
Part 2 functions and scope are working successfully.
```

[NEXT: Part 3 — Data Structures in Practice]
