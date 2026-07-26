# Part 1: The Building Blocks & Mental Model

JavaScript programs are made from a small number of fundamental ideas:

- Values represent information.
- Variables give information names.
- Operators combine or compare information.
- Conditions choose between alternatives.
- Loops repeat instructions.
- Memory determines how values behave when they are copied or changed.

This part builds those foundations through a small browser-based JavaScript laboratory. Before adding the task application, we will create a page that lets us observe JavaScript directly in the browser.

By the end of this part, you will be able to:

- Create and update variables.
- Recognize common JavaScript data types.
- Explain the difference between primitive and reference values.
- Make decisions with `if`, `else if`, `else`, and `switch`.
- Repeat instructions with `for`, `while`, and `for...of`.
- Use strict equality safely.
- Avoid common type-conversion mistakes.
- Verify JavaScript behavior in the browser and console.

---

## Part 1 Project Structure

Create the following structure:

```text
javascript-foundations/
├── index.html
└── src/
    └── part-1.js
```

We will add CSS later. For now, the page only needs enough HTML to load JavaScript and display results.

---

# Step 1: Create the HTML Page

## The Target

We are creating the first browser page for the project:

```text
index.html
```

This file provides the page structure and loads the JavaScript file.

## The Concept

HTML is the frame of a house. JavaScript cannot display anything until the browser has a document to work with.

The `<script>` element tells the browser to load and execute a JavaScript file. The `defer` attribute tells the browser:

> Download this script while parsing the HTML, but wait until the HTML has been parsed before running the script.

This is useful because JavaScript may need to find elements on the page. With `defer`, those elements already exist when the script begins.

## The Implementation

### `index.html`

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />

    <!-- Ensures the page displays correctly on phones and tablets. -->
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1"
    />

    <title>JavaScript Foundations</title>
  </head>

  <body>
    <main>
      <h1>JavaScript Foundations</h1>

      <p>
        Open the browser console to inspect the JavaScript examples.
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
      "defer" makes the script execute after the HTML has been parsed.
      The path is relative to this index.html file.
    -->
    <script src="./src/part-1.js" defer></script>
  </body>
</html>
```

## The Verification

Open `index.html` in a browser.

You should see:

```text
JavaScript Foundations
Open the browser console to inspect the JavaScript examples.
Program status
JavaScript has not run yet.
Results
No results yet.
```

Open Developer Tools:

- Chrome or Edge: `F12` or `Ctrl+Shift+J` on Windows/Linux.
- Firefox: `F12` or `Ctrl+Shift+K`.
- macOS browsers: `Cmd+Option+J`.

The console may not show anything yet because the JavaScript file does not exist. That is expected at this stage.

[COMPLETED: Step 1 — HTML page created]  
[STARTING: Step 2 — JavaScript entry point]

---

# Step 2: Create the JavaScript Entry Point

## The Target

We are creating:

```text
src/part-1.js
```

This file will be the starting point for all Part 1 JavaScript.

## The Concept

A JavaScript file is a list of instructions. The browser reads those instructions from top to bottom.

We will begin with a small startup message and update the page status. This confirms that the browser loaded the correct file.

## The Implementation

### `src/part-1.js`

```js
"use strict";

/*
  Strict mode makes JavaScript reject several unsafe behaviors.

  For example, without strict mode, accidentally assigning a value to an
  undeclared variable could create a global variable. Strict mode turns that
  mistake into an immediate error.
*/

const statusMessageElement = document.querySelector("#status-message");

if (statusMessageElement === null) {
  throw new Error("Could not find the #status-message element.");
}

statusMessageElement.textContent = "JavaScript is running successfully.";

console.log("Part 1 JavaScript loaded successfully.");
```

## The Verification

Refresh `index.html`.

The page should now show:

```text
JavaScript is running successfully.
```

The browser console should show:

```text
Part 1 JavaScript loaded successfully.
```

If the page still says “JavaScript has not run yet,” check:

1. The file is named exactly `part-1.js`.
2. The file is inside the `src` directory.
3. The script path is exactly:

```html
<script src="./src/part-1.js" defer></script>
```

4. The browser console does not show a file-not-found error.

[COMPLETED: Step 2 — JavaScript entry point verified]  
[STARTING: Step 3 — Variables and values]

---

# Step 3: Variables and Values

## The Target

We will add examples of:

- Strings.
- Numbers.
- Booleans.
- `undefined`.
- `null`.
- Constants.
- Reassignable variables.

## The Concept

A **value** is a piece of information.

Examples:

```js
"Learn JavaScript"
42
true
```

A **variable** is a named label that lets us refer to a value later.

You can think of a variable as a labeled container:

```text
label: taskCount
value: 3
```

JavaScript provides three variable declarations:

- `const`: the variable binding cannot be reassigned.
- `let`: the variable binding can be reassigned.
- `var`: an older declaration style with behavior that can be confusing.

Modern JavaScript generally uses:

- `const` by default.
- `let` only when reassignment is required.
- `var` rarely, usually only when maintaining older code.

## The Implementation

Replace the contents of `src/part-1.js` with the following complete file:

### `src/part-1.js`

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
  A string is text enclosed in quotation marks.

  These are all strings:
  - "JavaScript"
  - 'JavaScript'
  - `JavaScript`

  Template literals use backticks and can include expressions later.
*/
const languageName = "JavaScript";

/*
  A number can represent an integer or a decimal value.
*/
const lessonNumber = 1;
const estimatedMinutes = 45;

/*
  A boolean has only two possible values:
  true or false.
*/
const isBeginnerFriendly = true;
const hasCompletedLesson = false;

/*
  undefined usually means that a variable exists but has not received
  a value yet.
*/
let optionalNote;

/*
  null is an intentional empty value.

  It means:
  "This variable currently has no object or meaningful value."
*/
const selectedTask = null;

/*
  "let" is used here because the value changes later.
*/
let completedExamples = 0;
completedExamples += 1;
completedExamples += 1;

const results = [
  `Language: ${languageName}`,
  `Lesson number: ${lessonNumber}`,
  `Estimated minutes: ${estimatedMinutes}`,
  `Beginner friendly: ${isBeginnerFriendly}`,
  `Completed: ${hasCompletedLesson}`,
  `Optional note: ${optionalNote}`,
  `Selected task: ${selectedTask}`,
  `Completed examples: ${completedExamples}`
];

statusMessageElement.textContent = "Variables and values are working.";
resultsOutputElement.textContent = results.join("\n");

console.log("languageName:", languageName);
console.log("lessonNumber:", lessonNumber);
console.log("isBeginnerFriendly:", isBeginnerFriendly);
console.log("optionalNote:", optionalNote);
console.log("selectedTask:", selectedTask);
console.log("completedExamples:", completedExamples);
```

## The Verification

Refresh the browser.

The page should show:

```text
Variables and values are working.
Language: JavaScript
Lesson number: 1
Estimated minutes: 45
Beginner friendly: true
Completed: false
Optional note: undefined
Selected task: null
Completed examples: 2
```

In the console, run:

```js
typeof "JavaScript"
```

Expected result:

```text
"string"
```

Run:

```js
typeof 42
```

Expected result:

```text
"number"
```

Run:

```js
typeof true
```

Expected result:

```text
"boolean"
```

Run:

```js
typeof undefined
```

Expected result:

```text
"undefined"
```

There is one historical JavaScript oddity:

```js
typeof null
```

The result is:

```text
"object"
```

Although this result is technically incorrect for the way developers usually think about `null`, it is part of JavaScript’s long-standing behavior. When you need to check for `null`, use:

```js
selectedTask === null
```

Do not rely on:

```js
typeof selectedTask === "object"
```

because that also matches arrays and ordinary objects.

[COMPLETED: Step 3 — Variables and values verified]  
[STARTING: Step 4 — Primitive values and memory]

---

# Step 4: Primitive Values and Reference Values

## The Target

We will demonstrate the difference between:

- Primitive values.
- Objects and arrays.
- Copying a value.
- Copying a reference.
- Mutating shared data.

## The Concept

A **primitive value** is a basic, indivisible value.

Common primitive types include:

- String.
- Number.
- Boolean.
- `undefined`.
- `null`.
- BigInt.
- Symbol.

For this series, the most important primitive values are strings, numbers, booleans, `undefined`, and `null`.

When a primitive is copied, the value itself is copied:

```js
let firstCount = 1;
let secondCount = firstCount;

secondCount = 2;
```

Now:

```text
firstCount  → 1
secondCount → 2
```

Objects and arrays behave differently. A variable holding an object usually holds a reference to that object in memory.

Think of a reference like a house address:

```text
firstTask  ─┐
            ├──> one shared object
secondTask ─┘
```

If either variable changes the shared object, the other variable sees that change.

## The Implementation

Add the following code to the end of `src/part-1.js`:

### `src/part-1.js`

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

const languageName = "JavaScript";
const lessonNumber = 1;
const estimatedMinutes = 45;
const isBeginnerFriendly = true;
const hasCompletedLesson = false;

let optionalNote;
const selectedTask = null;

let completedExamples = 0;
completedExamples += 1;
completedExamples += 1;

const primitiveResults = [
  `Language: ${languageName}`,
  `Lesson number: ${lessonNumber}`,
  `Estimated minutes: ${estimatedMinutes}`,
  `Beginner friendly: ${isBeginnerFriendly}`,
  `Completed: ${hasCompletedLesson}`,
  `Optional note: ${optionalNote}`,
  `Selected task: ${selectedTask}`,
  `Completed examples: ${completedExamples}`
];

/*
  Primitive copy demonstration.

  "secondCount = firstCount" copies the number 1.
  It does not connect the two variables together.
*/
let firstCount = 1;
let secondCount = firstCount;

secondCount = 2;

/*
  Object reference demonstration.

  Both variables refer to the same object.
  The object is created once, and the reference is copied.
*/
const originalTask = {
  title: "Understand memory",
  completed: false
};

const copiedTaskReference = originalTask;

/*
  This changes the shared object.

  Because copiedTaskReference and originalTask point to the same object,
  reading either variable now shows completed: true.
*/
copiedTaskReference.completed = true;

/*
  An array is also an object and therefore follows reference behavior.
*/
const originalTags = ["javascript", "browser"];
const copiedTagsReference = originalTags;

copiedTagsReference.push("fundamentals");

const memoryResults = [
  "",
  "Primitive copy:",
  `firstCount: ${firstCount}`,
  `secondCount: ${secondCount}`,
  "",
  "Shared object reference:",
  `originalTask.completed: ${originalTask.completed}`,
  `copiedTaskReference.completed: ${copiedTaskReference.completed}`,
  "",
  "Shared array reference:",
  `originalTags: ${originalTags.join(", ")}`,
  `copiedTagsReference: ${copiedTagsReference.join(", ")}`
];

statusMessageElement.textContent =
  "Primitive and reference values are working.";

resultsOutputElement.textContent = [
  ...primitiveResults,
  ...memoryResults
].join("\n");

console.log("Primitive copy result:", {
  firstCount,
  secondCount
});

console.log("Shared object result:", {
  originalTask,
  copiedTaskReference
});

console.log("Shared array result:", {
  originalTags,
  copiedTagsReference
});
```

## The Verification

Refresh the browser.

The results should include:

```text
Primitive copy:
firstCount: 1
secondCount: 2
```

This proves that changing `secondCount` did not change `firstCount`.

The results should also include:

```text
Shared object reference:
originalTask.completed: true
copiedTaskReference.completed: true
```

Both variables show `true` because they refer to the same object.

The array output should include:

```text
Shared array reference:
originalTags: javascript, browser, fundamentals
copiedTagsReference: javascript, browser, fundamentals
```

In the console, run:

```js
const firstObject = { value: 10 };
const secondObject = firstObject;

secondObject.value = 20;

console.log(firstObject.value);
```

Expected result:

```text
20
```

Now compare two separate objects:

```js
const firstSeparateObject = { value: 10 };
const secondSeparateObject = { value: 10 };

console.log(firstSeparateObject === secondSeparateObject);
```

Expected result:

```text
false
```

The objects contain the same property and value, but they are two different objects in memory.

[COMPLETED: Step 4 — Primitive and reference behavior verified]  
[STARTING: Step 5 — Operators and comparisons]

---

# Step 5: Operators and Comparisons

## The Target

We will use:

- Arithmetic operators.
- Assignment operators.
- Comparison operators.
- Logical operators.
- Strict equality.

## The Concept

Operators are symbols that perform actions on values.

Arithmetic operators work like a calculator:

```js
const total = 10 + 5;
```

Comparison operators ask questions:

```js
const isLargeEnough = total >= 10;
```

The result of a comparison is always a boolean:

```js
true
```

Use strict equality:

```js
value === expectedValue
```

Strict equality compares both the value and the type.

Avoid using loose equality unless you have a specific reason:

```js
value == expectedValue
```

Loose equality performs automatic type conversion, which can produce surprising results.

## The Implementation

Add this section to `src/part-1.js` after the existing variables:

### `src/part-1.js`

```js
/*
  Arithmetic operators.
*/
const addition = 10 + 5;
const subtraction = 10 - 5;
const multiplication = 10 * 5;
const division = 10 / 5;
const remainder = 10 % 3;

/*
  Assignment operators.

  These are shorter versions of:
  score = score + 5
  score = score - 2
*/
let score = 10;
score += 5;
score -= 2;

/*
  Strict comparisons.

  The result of each comparison is a boolean.
*/
const isExactNumber = 10 === 10;
const isDifferentNumber = 10 !== 5;
const isAtLeastTen = score >= 10;
const isBelowTwenty = score < 20;

/*
  Logical operators:

  && means "and": both sides must be true.
  || means "or": at least one side must be true.
  ! means "not": reverses a boolean.
*/
const canStartLesson = isBeginnerFriendly && !hasCompletedLesson;
const needsReview = hasCompletedLesson || score < 20;
const isNotCompleted = !hasCompletedLesson;

const operatorResults = [
  "",
  "Operators:",
  `10 + 5 = ${addition}`,
  `10 - 5 = ${subtraction}`,
  `10 * 5 = ${multiplication}`,
  `10 / 5 = ${division}`,
  `10 % 3 = ${remainder}`,
  `Score after += and -=: ${score}`,
  "",
  "Comparisons:",
  `10 === 10: ${isExactNumber}`,
  `10 !== 5: ${isDifferentNumber}`,
  `score >= 10: ${isAtLeastTen}`,
  `score < 20: ${isBelowTwenty}`,
  "",
  "Logical operators:",
  `Can start lesson: ${canStartLesson}`,
  `Needs review: ${needsReview}`,
  `Is not completed: ${isNotCompleted}`
];

resultsOutputElement.textContent = [
  ...primitiveResults,
  ...memoryResults,
  ...operatorResults
].join("\n");
```

## The Verification

Refresh the browser and confirm that the output includes:

```text
10 + 5 = 15
10 - 5 = 5
10 * 5 = 50
10 / 5 = 2
10 % 3 = 1
Score after += and -=: 13
```

In the browser console, compare strict and loose equality:

```js
console.log(5 === "5");
console.log(5 == "5");
```

Expected result:

```text
false
true
```

The first comparison is false because the number `5` and string `"5"` have different types.

The second comparison is true because loose equality converts one value before comparing it.

Prefer:

```js
5 === "5"
```

over:

```js
5 == "5"
```

[COMPLETED: Step 5 — Operators and comparisons verified]  
[STARTING: Step 6 — Conditional control flow]

---

# Step 6: `if`, `else if`, and `else`

## The Target

We will make JavaScript choose different actions based on conditions.

## The Concept

A conditional is a decision point.

Imagine a security guard:

```text
If the person has a valid ticket:
    allow entry
Otherwise:
    deny entry
```

JavaScript expresses that with `if` and `else`:

```js
if (hasTicket) {
  enter();
} else {
  showError();
}
```

Use `else if` when there are multiple possible conditions.

## The Implementation

Add this code to `src/part-1.js`:

### `src/part-1.js`

```js
/*
  Conditional decision-making.

  Because score is currently 13, the first condition is true.
*/
let progressMessage;

if (score >= 20) {
  progressMessage = "Excellent progress.";
} else if (score >= 10) {
  progressMessage = "Good progress. Keep practicing.";
} else {
  progressMessage = "Start with one small exercise.";
}

/*
  Validate a task title before using it.

  trim() removes whitespace from both ends of a string.
*/
const proposedTaskTitle = "  Learn conditionals  ";
const cleanedTaskTitle = proposedTaskTitle.trim();

let taskValidationMessage;

if (cleanedTaskTitle.length === 0) {
  taskValidationMessage = "The task title cannot be empty.";
} else {
  taskValidationMessage = `Accepted task: ${cleanedTaskTitle}`;
}

const conditionalResults = [
  "",
  "Conditionals:",
  progressMessage,
  taskValidationMessage
];

resultsOutputElement.textContent = [
  ...primitiveResults,
  ...memoryResults,
  ...operatorResults,
  ...conditionalResults
].join("\n");
```

## The Verification

Refresh the browser.

You should see:

```text
Good progress. Keep practicing.
Accepted task: Learn conditionals
```

Test another value by changing:

```js
const score = 13;
```

The current code uses:

```js
let score = 10;
score += 5;
score -= 2;
```

Change the update to:

```js
let score = 25;
```

The output should become:

```text
Excellent progress.
```

Then change it to:

```js
let score = 4;
```

The output should become:

```text
Start with one small exercise.
```

[COMPLETED: Step 6 — Conditional control flow verified]  
[STARTING: Step 7 — Multiple choices with switch]

---

# Step 7: `switch` Statements

## The Target

We will use a `switch` statement to select behavior based on one known value.

## The Concept

A `switch` statement is useful when one value can have several exact choices.

For example, a traffic light has named states:

```text
red    → stop
yellow → prepare
green  → go
```

A `switch` statement checks a value against several `case` labels.

The `break` statement stops execution from continuing into the next case. Without `break`, JavaScript may execute multiple cases, a behavior called **fall-through**.

The `default` case handles unexpected values.

## The Implementation

Add this code to `src/part-1.js`:

### `src/part-1.js`

```js
const selectedDifficulty = "beginner";
let difficultyMessage;

switch (selectedDifficulty) {
  case "beginner":
    difficultyMessage =
      "Beginner mode: focus on one concept at a time.";
    break;

  case "intermediate":
    difficultyMessage =
      "Intermediate mode: combine multiple concepts.";
    break;

  case "advanced":
    difficultyMessage =
      "Advanced mode: solve the problem with fewer hints.";
    break;

  default:
    difficultyMessage =
      "Unknown difficulty. Using beginner mode.";
    break;
}

const switchResults = [
  "",
  "Switch statement:",
  difficultyMessage
];

resultsOutputElement.textContent = [
  ...primitiveResults,
  ...memoryResults,
  ...operatorResults,
  ...conditionalResults,
  ...switchResults
].join("\n");
```

## The Verification

Refresh the browser.

You should see:

```text
Beginner mode: focus on one concept at a time.
```

Change:

```js
const selectedDifficulty = "beginner";
```

to:

```js
const selectedDifficulty = "advanced";
```

Refresh the browser. You should see:

```text
Advanced mode: solve the problem with fewer hints.
```

Now use an unknown value:

```js
const selectedDifficulty = "expert";
```

You should see:

```text
Unknown difficulty. Using beginner mode.
```

[COMPLETED: Step 7 — `switch` control flow verified]  
[STARTING: Step 8 — Repeating instructions with for loops]

---

# Step 8: `for` Loops

## The Target

We will repeat an instruction a known number of times and process an array by index.

## The Concept

A loop is like a repeated checklist instruction:

```text
For each numbered item from 1 through 5:
    perform the same action
```

A traditional `for` loop has three sections:

```js
for (initialization; condition; update) {
  // repeated code
}
```

Example:

```js
for (let number = 1; number <= 5; number += 1) {
  console.log(number);
}
```

The three sections mean:

1. Start with `number = 1`.
2. Continue while `number <= 5`.
3. Increase `number` after each iteration.

## The Implementation

Add this code to `src/part-1.js`:

### `src/part-1.js`

```js
const practiceTopics = [
  "variables",
  "types",
  "conditions",
  "loops"
];

const indexedTopicLines = [];

/*
  Arrays use zero-based indexes.

  For an array with four items:
  - first item is index 0
  - last item is index 3
*/
for (let index = 0; index < practiceTopics.length; index += 1) {
  const topicNumber = index + 1;
  const topicName = practiceTopics[index];

  indexedTopicLines.push(`${topicNumber}. ${topicName}`);
}

const forLoopResults = [
  "",
  "for loop:",
  ...indexedTopicLines
];

resultsOutputElement.textContent = [
  ...primitiveResults,
  ...memoryResults,
  ...operatorResults,
  ...conditionalResults,
  ...switchResults,
  ...forLoopResults
].join("\n");
```

## The Verification

Refresh the browser.

You should see:

```text
for loop:
1. variables
2. types
3. conditions
4. loops
```

Use the console to inspect the first and last array values:

```js
practiceTopics[0]
```

This will fail in the browser console because `practiceTopics` is inside the JavaScript file’s module-like script scope and is not exposed as a convenient global. Instead, temporarily add this line to the file:

```js
console.log(practiceTopics[0], practiceTopics[practiceTopics.length - 1]);
```

Refresh the browser.

Expected console output:

```text
variables loops
```

Remove the temporary log afterward.

[COMPLETED: Step 8 — `for` loop verified]  
[STARTING: Step 9 — `while` loops]

---

# Step 9: `while` Loops

## The Target

We will repeat instructions while a condition remains true.

## The Concept

A `while` loop is useful when you do not know exactly how many repetitions are required in advance.

Imagine filling boxes while boxes remain available:

```text
While there are empty boxes:
    fill one box
```

The condition is checked before each iteration.

You must ensure that something inside the loop eventually makes the condition false. Otherwise, the loop may never stop. This is called an **infinite loop**.

## The Implementation

Add this code to `src/part-1.js`:

### `src/part-1.js`

```js
let remainingPracticeTopics = practiceTopics.length;
const countdownLines = [];

while (remainingPracticeTopics > 0) {
  countdownLines.push(
    `${remainingPracticeTopics} topic(s) remain.`
  );

  remainingPracticeTopics -= 1;
}

countdownLines.push("All topics processed.");

const whileLoopResults = [
  "",
  "while loop:",
  ...countdownLines
];

resultsOutputElement.textContent = [
  ...primitiveResults,
  ...memoryResults,
  ...operatorResults,
  ...conditionalResults,
  ...switchResults,
  ...forLoopResults,
  ...whileLoopResults
].join("\n");
```

## The Verification

Refresh the browser.

You should see:

```text
while loop:
4 topic(s) remain.
3 topic(s) remain.
2 topic(s) remain.
1 topic(s) remain.
All topics processed.
```

Check the code carefully:

```js
remainingPracticeTopics -= 1;
```

This line is essential. If you remove it, the value stays at `4`, meaning the condition remains true forever.

If you accidentally create an infinite loop, stop the page using the browser’s reload or stop button, then restore the decrement statement.

[COMPLETED: Step 9 — `while` loop verified]  
[STARTING: Step 10 — `for...of` loops]

---

# Step 10: `for...of` Loops

## The Target

We will process each item in an array without manually managing indexes.

## The Concept

A `for...of` loop means:

> For each value inside this collection, run this code.

It is often easier to read than a traditional indexed `for` loop.

Compare:

```js
for (let index = 0; index < topics.length; index += 1) {
  const topic = topics[index];
}
```

with:

```js
for (const topic of topics) {
  // use topic
}
```

Use an indexed `for` loop when you need the position. Use `for...of` when you mainly need each value.

## The Implementation

Add this code to `src/part-1.js`:

### `src/part-1.js`

```js
const topicDescriptions = [];

for (const topic of practiceTopics) {
  topicDescriptions.push(
    `Practice topic: ${topic}`
  );
}

const forOfResults = [
  "",
  "for...of loop:",
  ...topicDescriptions
];

resultsOutputElement.textContent = [
  ...primitiveResults,
  ...memoryResults,
  ...operatorResults,
  ...conditionalResults,
  ...switchResults,
  ...forLoopResults,
  ...whileLoopResults,
  ...forOfResults
].join("\n");

statusMessageElement.textContent =
  "Part 1 foundations are working successfully.";
```

## The Verification

Refresh the browser.

The page should end with:

```text
Part 1 foundations are working successfully.
```

The results should include:

```text
for...of loop:
Practice topic: variables
Practice topic: types
Practice topic: conditions
Practice topic: loops
```

[COMPLETED: Step 10 — `for...of` loop verified]  
[STARTING: Step 11 — Building the complete Part 1 demonstration]

---

# Step 11: Complete Part 1 File

## The Target

We will now consolidate all Part 1 examples into one complete, clean file.

This prevents the tutorial from leaving you with disconnected snippets. Replace your current JavaScript file with the complete version below.

## The Concept

A program becomes easier to maintain when related operations have a predictable structure:

1. Find required page elements.
2. Define values.
3. Demonstrate logic.
4. Build display output.
5. Update the page.
6. Write diagnostic information to the console.

This is still a deliberately educational file. In later parts, functions will help us divide this work into smaller units.

## The Implementation

### `src/part-1.js`

```js
"use strict";

/*
  Part 1 demonstrates JavaScript's basic building blocks:

  - Variables and values
  - Primitive and reference behavior
  - Operators
  - Conditions
  - switch statements
  - for loops
  - while loops
  - for...of loops
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
  VALUES AND VARIABLES
*/

const languageName = "JavaScript";
const lessonNumber = 1;
const estimatedMinutes = 45;
const isBeginnerFriendly = true;
const hasCompletedLesson = false;

let optionalNote;
const selectedTask = null;

let completedExamples = 0;
completedExamples += 1;
completedExamples += 1;

const primitiveResults = [
  `Language: ${languageName}`,
  `Lesson number: ${lessonNumber}`,
  `Estimated minutes: ${estimatedMinutes}`,
  `Beginner friendly: ${isBeginnerFriendly}`,
  `Completed: ${hasCompletedLesson}`,
  `Optional note: ${optionalNote}`,
  `Selected task: ${selectedTask}`,
  `Completed examples: ${completedExamples}`
];

/*
  PRIMITIVE VALUES AND REFERENCE VALUES
*/

let firstCount = 1;
let secondCount = firstCount;

secondCount = 2;

const originalTask = {
  title: "Understand memory",
  completed: false
};

const copiedTaskReference = originalTask;
copiedTaskReference.completed = true;

const originalTags = ["javascript", "browser"];
const copiedTagsReference = originalTags;
copiedTagsReference.push("fundamentals");

const memoryResults = [
  "",
  "Primitive copy:",
  `firstCount: ${firstCount}`,
  `secondCount: ${secondCount}`,
  "",
  "Shared object reference:",
  `originalTask.completed: ${originalTask.completed}`,
  `copiedTaskReference.completed: ${copiedTaskReference.completed}`,
  "",
  "Shared array reference:",
  `originalTags: ${originalTags.join(", ")}`,
  `copiedTagsReference: ${copiedTagsReference.join(", ")}`
];

/*
  OPERATORS
*/

const addition = 10 + 5;
const subtraction = 10 - 5;
const multiplication = 10 * 5;
const division = 10 / 5;
const remainder = 10 % 3;

let score = 10;
score += 5;
score -= 2;

const isExactNumber = 10 === 10;
const isDifferentNumber = 10 !== 5;
const isAtLeastTen = score >= 10;
const isBelowTwenty = score < 20;

const canStartLesson = isBeginnerFriendly && !hasCompletedLesson;
const needsReview = hasCompletedLesson || score < 20;
const isNotCompleted = !hasCompletedLesson;

const operatorResults = [
  "",
  "Operators:",
  `10 + 5 = ${addition}`,
  `10 - 5 = ${subtraction}`,
  `10 * 5 = ${multiplication}`,
  `10 / 5 = ${division}`,
  `10 % 3 = ${remainder}`,
  `Score after += and -=: ${score}`,
  "",
  "Comparisons:",
  `10 === 10: ${isExactNumber}`,
  `10 !== 5: ${isDifferentNumber}`,
  `score >= 10: ${isAtLeastTen}`,
  `score < 20: ${isBelowTwenty}`,
  "",
  "Logical operators:",
  `Can start lesson: ${canStartLesson}`,
  `Needs review: ${needsReview}`,
  `Is not completed: ${isNotCompleted}`
];

/*
  IF, ELSE IF, AND ELSE
*/

let progressMessage;

if (score >= 20) {
  progressMessage = "Excellent progress.";
} else if (score >= 10) {
  progressMessage = "Good progress. Keep practicing.";
} else {
  progressMessage = "Start with one small exercise.";
}

const proposedTaskTitle = "  Learn conditionals  ";
const cleanedTaskTitle = proposedTaskTitle.trim();

let taskValidationMessage;

if (cleanedTaskTitle.length === 0) {
  taskValidationMessage = "The task title cannot be empty.";
} else {
  taskValidationMessage = `Accepted task: ${cleanedTaskTitle}`;
}

const conditionalResults = [
  "",
  "Conditionals:",
  progressMessage,
  taskValidationMessage
];

/*
  SWITCH
*/

const selectedDifficulty = "beginner";
let difficultyMessage;

switch (selectedDifficulty) {
  case "beginner":
    difficultyMessage =
      "Beginner mode: focus on one concept at a time.";
    break;

  case "intermediate":
    difficultyMessage =
      "Intermediate mode: combine multiple concepts.";
    break;

  case "advanced":
    difficultyMessage =
      "Advanced mode: solve the problem with fewer hints.";
    break;

  default:
    difficultyMessage =
      "Unknown difficulty. Using beginner mode.";
    break;
}

const switchResults = [
  "",
  "Switch statement:",
  difficultyMessage
];

/*
  FOR LOOP
*/

const practiceTopics = [
  "variables",
  "types",
  "conditions",
  "loops"
];

const indexedTopicLines = [];

for (let index = 0; index < practiceTopics.length; index += 1) {
  const topicNumber = index + 1;
  const topicName = practiceTopics[index];

  indexedTopicLines.push(`${topicNumber}. ${topicName}`);
}

const forLoopResults = [
  "",
  "for loop:",
  ...indexedTopicLines
];

/*
  WHILE LOOP
*/

let remainingPracticeTopics = practiceTopics.length;
const countdownLines = [];

while (remainingPracticeTopics > 0) {
  countdownLines.push(
    `${remainingPracticeTopics} topic(s) remain.`
  );

  remainingPracticeTopics -= 1;
}

countdownLines.push("All topics processed.");

const whileLoopResults = [
  "",
  "while loop:",
  ...countdownLines
];

/*
  FOR...OF LOOP
*/

const topicDescriptions = [];

for (const topic of practiceTopics) {
  topicDescriptions.push(`Practice topic: ${topic}`);
}

const forOfResults = [
  "",
  "for...of loop:",
  ...topicDescriptions
];

/*
  PAGE OUTPUT
*/

const allResults = [
  ...primitiveResults,
  ...memoryResults,
  ...operatorResults,
  ...conditionalResults,
  ...switchResults,
  ...forLoopResults,
  ...whileLoopResults,
  ...forOfResults
];

statusMessageElement.textContent =
  "Part 1 foundations are working successfully.";

resultsOutputElement.textContent = allResults.join("\n");

/*
  CONSOLE OUTPUT

  These logs make it easier to inspect values while learning.
*/
console.log("Part 1 JavaScript loaded successfully.");
console.log("Primitive copy result:", {
  firstCount,
  secondCount
});

console.log("Shared object result:", {
  originalTask,
  copiedTaskReference
});

console.log("Shared array result:", {
  originalTags,
  copiedTagsReference
});

console.log("All practice topics:", practiceTopics);
```

## The Verification

Refresh the browser.

The page should display all of the following sections:

```text
Language: JavaScript
Lesson number: 1
Estimated minutes: 45
...
Primitive copy:
...
Operators:
...
Conditionals:
...
Switch statement:
...
for loop:
...
while loop:
...
for...of loop:
...
```

The status message should be:

```text
Part 1 foundations are working successfully.
```

The console should show objects and arrays for inspection.

To perform a final syntax check, open the browser console and confirm there are no red error messages.

If your editor or operating system provides a terminal, you can also inspect the project:

```bash
ls
```

macOS/Linux expected result:

```text
index.html
src
```

On Windows PowerShell:

```powershell
Get-ChildItem
```

Expected entries:

```text
index.html
src
```

[COMPLETED: Step 11 — Complete Part 1 demonstration verified]  
[STARTING: Part 1 reference section]

---

# Part 1 Reference: JavaScript Foundations

## Primitive Data Types

### String

Text:

```js
const title = "Learn JavaScript";
```

### Number

Integers and decimal values:

```js
const count = 10;
const price = 19.99;
```

JavaScript uses the `number` type for both.

### Boolean

True or false:

```js
const isVisible = true;
const isComplete = false;
```

### Undefined

A missing assigned value:

```js
let result;
console.log(result); // undefined
```

### Null

An intentional empty value:

```js
const selectedItem = null;
```

### BigInt

For integers larger than the safe range of ordinary numbers:

```js
const veryLargeNumber = 9007199254740993n;
```

The `n` suffix identifies a BigInt.

BigInt is not needed for this series.

### Symbol

A unique identifier:

```js
const identifier = Symbol("identifier");
```

Symbols are also outside the scope of this introductory series.

---

## `const` and `let`

Use `const` when the variable binding should not be reassigned:

```js
const courseName = "JavaScript Foundations";
```

This is not allowed:

```js
courseName = "Another course";
```

Use `let` when reassignment is required:

```js
let currentPage = 1;
currentPage = 2;
```

A `const` object can still be mutated:

```js
const user = {
  name: "Alex"
};

user.name = "Jordan";
```

This is allowed because the variable still refers to the same object.

This is not allowed:

```js
user = {
  name: "Taylor"
};
```

The binding cannot be replaced.

---

## Truthy and Falsy Values

When JavaScript expects a boolean, it can convert other values into boolean-like behavior.

Values commonly treated as falsy include:

```js
false
0
""
null
undefined
NaN
```

Most other values are truthy, including:

```js
"hello"
1
[]
{}
```

Example:

```js
const title = "";

if (title) {
  console.log("The title has content.");
} else {
  console.log("The title is empty.");
}
```

For beginner-friendly and predictable code, explicit comparisons are often clearer:

```js
if (title.trim().length === 0) {
  console.log("The title is empty.");
}
```

---

## Common Comparison Operators

| Operator | Meaning |
|---|---|
| `===` | Strictly equal |
| `!==` | Strictly not equal |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal to |
| `<=` | Less than or equal to |

Examples:

```js
10 === 10; // true
10 === "10"; // false
10 !== 5; // true
10 > 5; // true
10 <= 10; // true
```

Prefer strict comparisons:

```js
value === expected
```

---

## Logical Operators

### AND: `&&`

Both conditions must be true:

```js
const isLoggedIn = true;
const hasPermission = true;

const canEdit = isLoggedIn && hasPermission;
```

### OR: `||`

At least one condition must be true:

```js
const isAdmin = false;
const isOwner = true;

const canDelete = isAdmin || isOwner;
```

### NOT: `!`

Reverses a boolean:

```js
const isComplete = false;
const isIncomplete = !isComplete;
```

---

## Loop Selection Guide

Use a traditional `for` loop when:

- You need the index.
- You need precise control over the counter.
- You are iterating over a range of numbers.

```js
for (let index = 0; index < items.length; index += 1) {
  console.log(index, items[index]);
}
```

Use a `while` loop when:

- The number of repetitions is not known in advance.
- You want to continue while a condition remains true.

```js
while (queue.length > 0) {
  // process work
}
```

Use `for...of` when:

- You need every value in an iterable collection.
- You do not need to manage the index manually.

```js
for (const item of items) {
  console.log(item);
}
```

---

## Common Mistakes

### Mistake 1: Forgetting that arrays start at index `0`

Correct:

```js
const colors = ["red", "green", "blue"];

console.log(colors[0]); // red
```

Incorrect assumption:

```js
console.log(colors[1]); // green, not red
```

### Mistake 2: Creating an infinite `while` loop

Problem:

```js
let count = 3;

while (count > 0) {
  console.log(count);
}
```

`count` never changes, so the condition never becomes false.

Correct:

```js
let count = 3;

while (count > 0) {
  console.log(count);
  count -= 1;
}
```

### Mistake 3: Using assignment instead of comparison

Incorrect:

```js
if (isComplete = true) {
  // This assigns true instead of checking a value.
}
```

Correct:

```js
if (isComplete === true) {
  // This checks the value.
}
```

Even clearer:

```js
if (isComplete) {
  // This runs when isComplete is truthy.
}
```

### Mistake 4: Accidentally sharing an object

```js
const firstTask = {
  title: "Read"
};

const secondTask = firstTask;
secondTask.title = "Write";

console.log(firstTask.title); // Write
```

If you need a shallow copy of an object, use:

```js
const secondTask = {
  ...firstTask
};
```

For arrays:

```js
const secondTags = [
  ...firstTags
];
```

The spread syntax creates a new outer array or object. Nested objects still require additional care, which will become important in later application design.

---

## Part 1 Completion Checklist

Before moving to Part 2, confirm that you can answer these questions:

- What is the difference between a value and a variable?
- When should you use `const`?
- When should you use `let`?
- What is a primitive value?
- Why do two variables sometimes point to the same object?
- Why should strict equality usually be preferred?
- What does `&&` mean?
- What does `||` mean?
- What is the difference between `for` and `for...of`?
- Why must a `while` loop eventually make its condition false?
- Why does the first array item use index `0`?

You should also be able to run the project and see:

```text
Part 1 foundations are working successfully.
```

[NEXT: Part 2 — Functional Units & Scope]
