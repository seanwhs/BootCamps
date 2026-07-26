# Beginning JavaScript: Foundations & Interactive Web

## Trainer Guide

This guide supports instructors delivering the **Beginning JavaScript: Foundations & Interactive Web** series.

The series teaches JavaScript fundamentals through the construction of a browser-based task application.

The primary learning sequence is:

```text
Web fundamentals
    ↓
JavaScript values and control flow
    ↓
Functions and scope
    ↓
Arrays and objects
    ↓
DOM manipulation and events
    ↓
Interactive task application
```

---

# 1. Course Overview

## Course purpose

By the end of the course, learners should be able to:

- Explain how HTML, CSS, JavaScript, and the browser work together.
- Write basic JavaScript using variables, values, conditions, and loops.
- Define and call functions.
- Explain scope and the differences between `var`, `let`, and `const`.
- Use arrays and objects to model application data.
- Select and manipulate DOM elements.
- Respond to browser events.
- Handle form submissions.
- Render data into the DOM.
- Build and debug a small interactive task application.
- Apply basic accessibility and security practices.

## Final project

Learners build a browser-based task application that supports:

- Adding tasks.
- Validating task titles.
- Displaying tasks.
- Completing and reopening tasks.
- Removing tasks.
- Updating task counts.
- Showing an empty state.
- Handling status and error messages.
- Using safe text rendering.
- Supporting keyboard interaction.

## Target audience

The course is designed for learners who:

- Are new to JavaScript.
- Know basic HTML and CSS.
- Have limited programming experience.
- Want a practical project.
- Need preparation for later JavaScript frameworks.

---

# 2. Teaching Philosophy

## Beginner-friendly outside, technically strong inside

Explain concepts using familiar analogies, but do not simplify the code into poor practices.

Recommended analogies:

| Concept | Analogy |
|---|---|
| Variable | Labeled container |
| Function | Reusable recipe |
| Array | Numbered row of storage boxes |
| Object | Information card |
| Scope | Room in a building |
| Event | Something that happens |
| DOM | Live tree representing the page |
| State | Application scoreboard |
| Rendering | Translating data into visible output |
| Callback | Instructions handed to another worker |

## Use the “predict, run, explain” cycle

For each code example:

1. Ask learners what they expect.
2. Run the code.
3. Compare the result.
4. Ask why the result occurred.
5. Connect the result to the underlying rule.

Example:

```js
let firstCount = 1;
let secondCount = firstCount;

secondCount = 2;
```

Ask:

```text
What is the value of firstCount?
What is the value of secondCount?
```

Then explain primitive copying.

## Prefer small verified steps

Do not present a large final file without first showing how it develops.

Use this pattern:

```text
The Target
The Concept
The Implementation
The Verification
```

Learners should verify each step before continuing.

## Teach debugging as normal work

Avoid presenting errors as failures of intelligence.

Use language such as:

```text
The program has reported an incorrect assumption.
Let's identify that assumption.
```

---

# 3. Recommended Delivery Format

## Suggested format

Each technical lesson should include:

1. Short explanation.
2. Instructor demonstration.
3. Learner prediction.
4. Guided implementation.
5. Individual modification.
6. Verification.
7. Reflection.
8. Short break or transition.

## Suggested session duration

A complete delivery can be organized into 8–10 sessions.

### Option A: Eight sessions

| Session | Content |
|---:|---|
| 1 | Web primers and JavaScript foundations |
| 2 | Variables, types, operators, and conditions |
| 3 | Loops and functions |
| 4 | Scope, callbacks, and closures |
| 5 | Arrays and objects |
| 6 | DOM selection and manipulation |
| 7 | Events, forms, and event delegation |
| 8 | Complete task application and assessment |

### Option B: Ten sessions

| Session | Content |
|---:|---|
| 1 | How the web works |
| 2 | Programming mental models and code reading |
| 3 | Variables, values, and operators |
| 4 | Conditions and loops |
| 5 | Functions and scope |
| 6 | Arrays and objects |
| 7 | DOM fundamentals |
| 8 | Events and forms |
| 9 | Complete task application |
| 10 | Review, extensions, and assessment |

## Recommended session rhythm

For a two-hour session:

```text
10 minutes  — Recap and warm-up
15 minutes  — Concept explanation
20 minutes  — Instructor demonstration
35 minutes  — Guided implementation
25 minutes  — Learner exercise
10 minutes  — Verification and debugging
5 minutes   — Reflection and exit ticket
```

Adjust the timing based on learner experience.

---

# 4. Trainer Preparation

## Before the course

Confirm that:

- [ ] The browser is installed.
- [ ] The code editor is installed.
- [ ] The local development server works.
- [ ] The starter project opens.
- [ ] The final task application runs.
- [ ] The browser Console is available.
- [ ] The projector or screen-sharing setup works.
- [ ] Learners have access to the tutorial and workbook.
- [ ] The final project has been tested in the target browsers.

## Recommended starter project

Provide:

```text
javascript-foundations/
├── index.html
├── styles.css
└── src/
    └── app.js
```

Use a known-good starter file before the first class.

## Trainer backup files

Maintain these copies:

```text
starter/
part-1-complete/
part-2-complete/
part-3-complete/
part-4-complete/
```

This allows learners to recover if they accidentally break their project.

## Pre-class verification

Run:

```bash
pwd
ls
```

or on Windows PowerShell:

```powershell
Get-Location
Get-ChildItem
```

Open the project using the local server.

Verify:

- The page loads.
- The stylesheet loads.
- The JavaScript loads.
- No Console errors appear.
- The task application can add, complete, and remove tasks.

---

# 5. Required Trainer Vocabulary

Introduce these terms gradually.

## Early terms

- Browser.
- HTML.
- CSS.
- JavaScript.
- Value.
- Variable.
- String.
- Number.
- Boolean.
- Condition.
- Loop.

## Middle terms

- Function.
- Parameter.
- Argument.
- Return value.
- Scope.
- Primitive.
- Reference.
- Array.
- Object.
- Property.

## Browser terms

- DOM.
- Element.
- Event.
- Event listener.
- Event bubbling.
- Event delegation.
- Render.
- State.
- `textContent`.
- `classList`.

Define each term the first time it appears.

---

# 6. Session 1: Web Fundamentals

## Learning objectives

Learners should be able to:

- Describe the responsibilities of HTML, CSS, and JavaScript.
- Explain the browser’s role.
- Describe the DOM at a basic level.
- Open Developer Tools.
- Run a minimal browser test.

## Key explanation

Use:

```text
HTML       → structure
CSS        → presentation
JavaScript → behavior
Browser    → runtime and display environment
```

## Demonstration

Show a page with:

```html
<h1 id="heading">Original heading</h1>
```

Then run:

```js
const headingElement =
  document.querySelector("#heading");

headingElement.textContent =
  "Updated heading";
```

Ask:

```text
What changed?
Which file defined the heading?
Which code changed it?
```

## Guided exercise

Learners create:

```text
index.html
styles.css
src/tooling-test.js
```

The page should:

- Display a heading.
- Display a paragraph.
- Apply CSS.
- Change text through JavaScript.

## Common problems

### JavaScript does not run

Check:

```html
<script
  src="./src/tooling-test.js"
  defer
></script>
```

### CSS does not load

Check:

```html
<link
  rel="stylesheet"
  href="./styles.css"
/>
```

### `querySelector` returns `null`

Compare the selector with the HTML ID character by character.

## Exit ticket

Ask learners to answer:

```text
What does HTML do?
What does CSS do?
What does JavaScript do?
What is the DOM?
```

---

# 7. Session 2: Variables, Values, and Operators

## Learning objectives

Learners should be able to:

- Declare variables.
- Identify common data types.
- Use `const` and `let`.
- Perform arithmetic.
- Compare values.
- Use logical operators.

## Key examples

```js
const taskTitle = "Learn JavaScript";
let completedCount = 0;

completedCount += 1;
```

Explain:

```text
const → binding should not be reassigned
let   → reassignment is required
```

## Demonstration: types

```js
console.log(typeof "text");
console.log(typeof 42);
console.log(typeof true);
console.log(typeof undefined);
```

Ask learners to predict:

```js
typeof null
```

Explain the historical behavior without overemphasizing it.

## Demonstration: strict equality

```js
console.log(5 === 5);
console.log(5 === "5");
```

Emphasize:

```text
Strict equality compares value and type.
```

## Guided exercises

Learners create:

- A course title.
- A lesson number.
- A completion boolean.
- A task count.
- A calculated total.

## Common misconceptions

### “const means the object cannot change”

Clarify:

```js
const task = {
  completed: false
};

task.completed = true;
```

The object can mutate, but the variable cannot be reassigned to a different object.

### “`==` and `===` are the same”

Demonstrate:

```js
5 == "5";  // true
5 === "5"; // false
```

Recommend strict equality.

## Exit ticket

Ask:

```text
When should you use const?
When should you use let?
Why is === generally preferred?
```

---

# 8. Session 3: Conditions and Loops

## Learning objectives

Learners should be able to:

- Use `if`, `else if`, and `else`.
- Use `switch`.
- Use `for`, `while`, and `for...of`.
- Explain loop termination.
- Avoid infinite loops.

## Demonstration: task validation

```js
function validateTaskTitle(title) {
  if (title.trim().length === 0) {
    return "Title cannot be empty.";
  }

  return "Title is valid.";
}
```

Ask learners to trace:

```js
validateTaskTitle("   ");
validateTaskTitle("Read JavaScript");
```

## Demonstration: loop tracing

```js
const topics = [
  "variables",
  "conditions",
  "loops"
];

for (const topic of topics) {
  console.log(topic);
}
```

Use a trace table:

| Iteration | Topic |
|---:|---|
| 1 | variables |
| 2 | conditions |
| 3 | loops |

## Infinite-loop demonstration

Show briefly:

```js
let count = 3;

while (count > 0) {
  console.log(count);
}
```

Ask:

```text
Why does this not stop?
```

Correct it:

```js
while (count > 0) {
  console.log(count);
  count -= 1;
}
```

## Exercises

Learners should:

- Print numbered topics.
- Count completed tasks.
- Validate a score.
- Build a countdown.

## Common misconceptions

### Array index versus item number

Explain:

```text
Human number: 1
Array index: 0
```

### `while` loop condition

Emphasize that something inside the loop must change the condition.

## Exit ticket

Ask learners to choose the correct loop:

```text
Need the index?          → for
Need each value?         → for...of
Unknown repetitions?     → while
```

---

# 9. Session 4: Functions and Scope

## Learning objectives

Learners should be able to:

- Define and call functions.
- Distinguish parameters and arguments.
- Return values.
- Use function expressions and arrow functions.
- Explain global, function, and block scope.
- Explain basic closure behavior.

## Demonstration: function design

```js
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
```

Ask:

```text
What is the responsibility of each function?
```

## Scope demonstration

```js
const applicationName = "Task List";

function reportScope() {
  const functionMessage = "Inside function.";

  if (true) {
    const blockMessage = "Inside block.";

    console.log(applicationName);
    console.log(functionMessage);
    console.log(blockMessage);
  }
}
```

Ask learners where each variable is available.

## Closure demonstration

```js
function createCounter() {
  let count = 0;

  return function increase() {
    count += 1;
    return count;
  };
}
```

Use the analogy of a private box that the returned function can still access.

## Common misconceptions

### Function declaration versus function call

Definition:

```js
function greet() {
  return "Hello";
}
```

Call:

```js
greet();
```

### Missing return

Show:

```js
const double = (number) => {
  number * 2;
};
```

Then explain why it returns `undefined`.

## Exercises

Learners create:

- Greeting functions.
- Calculator functions.
- Validation functions.
- A closure counter.
- A task factory.

## Exit ticket

Ask:

```text
What is a parameter?
What is an argument?
What does return do?
What does scope control?
```

---

# 10. Session 5: Arrays and Objects

## Learning objectives

Learners should be able to:

- Create arrays.
- Read and update array values.
- Use common array methods.
- Create objects.
- Access properties.
- Use dynamic keys.
- Store objects inside arrays.

## Key data model

```js
const task = {
  id: 1,
  title: "Learn objects",
  completed: false
};

const tasks = [
  task
];
```

Explain why this structure is useful:

```text
The array stores the collection.
Each object stores one complete task.
```

## Demonstration: methods

```js
tasks.push(task);
tasks.find(
  (item) => item.id === 1
);
tasks.findIndex(
  (item) => item.id === 1
);
```

Use a method table:

| Method | Purpose |
|---|---|
| `push` | Add to end |
| `pop` | Remove from end |
| `shift` | Remove from beginning |
| `unshift` | Add to beginning |
| `slice` | Copy a section |
| `find` | Find one value |
| `findIndex` | Find one index |
| `splice` | Remove or insert |

## Reference-value demonstration

```js
const firstTask = {
  completed: false
};

const secondTask = firstTask;

secondTask.completed = true;
```

Ask:

```text
What is firstTask.completed?
```

Explain shared references.

## Exercises

Learners should:

- Create a task array.
- Find a task by ID.
- Complete a task.
- Remove a task.
- Produce task descriptions.

## Common misconceptions

### `find` versus `findIndex`

```text
find      → object or undefined
findIndex → number or -1
```

### `slice` versus `splice`

```text
slice  → returns a copy, does not mutate
splice → changes the original array
```

## Exit ticket

Ask:

```text
Why do tasks use an array of objects?
What does findIndex return when no item matches?
```

---

# 11. Session 6: DOM Fundamentals

## Learning objectives

Learners should be able to:

- Select elements.
- Validate selections.
- Change text.
- Create elements.
- Append elements.
- Remove elements.
- Manage classes.
- Use data attributes.

## Demonstration: safe text

```js
titleElement.textContent =
  task.title;
```

Contrast with:

```js
titleElement.innerHTML =
  task.title;
```

Explain that user-entered text should be treated as data, not markup.

## Demonstration: rendering

```js
function renderTasks(tasks) {
  taskListElement.replaceChildren();

  for (const task of tasks) {
    const itemElement =
      document.createElement("li");

    itemElement.textContent =
      task.title;

    taskListElement.append(itemElement);
  }
}
```

Use the phrase:

```text
The array is the source of truth.
The DOM is the visible representation.
```

## Exercises

Learners should:

- Create a list item.
- Render three tasks.
- Add a completed CSS class.
- Display an empty state.
- Display a task count.

## Common problems

### Element is `null`

Check:

- ID spelling.
- File loading.
- Script timing.
- `defer`.
- HTML structure.

### New element does not appear

Check whether it was appended:

```js
taskListElement.append(itemElement);
```

## Exit ticket

Ask:

```text
What does createElement do?
What does append do?
Why is textContent safer than innerHTML for user input?
```

---

# 12. Session 7: Events and Forms

## Learning objectives

Learners should be able to:

- Register event listeners.
- Handle clicks.
- Handle form submission.
- Read input values.
- Prevent default form behavior.
- Reset and focus inputs.
- Display status messages.

## Demonstration: submit flow

```js
taskFormElement.addEventListener(
  "submit",
  (event) => {
    event.preventDefault();

    const title =
      taskTitleInputElement.value.trim();

    if (title.length === 0) {
      showFormMessage(
        "Enter a task title.",
        "error"
      );

      taskTitleInputElement.focus();
      return;
    }

    // Create and store task.
  }
);
```

Break the flow into named stages:

```text
Receive event
Prevent reload
Read input
Trim input
Validate input
Create task
Store task
Render task
Reset form
Focus input
```

## Accessibility emphasis

Ensure:

```html
<label for="task-title">
  Task title
</label>
```

and:

```html
<button type="submit">
  Add task
</button>
```

## Exercises

Learners should:

- Add a form.
- Reject empty titles.
- Display success messages.
- Reset the form.
- Return focus to the input.

## Common problems

### Page reloads

Check:

```js
event.preventDefault();
```

### Input value is empty

Check:

```js
taskTitleInputElement.value
```

### Button does not submit

Check:

```html
<button type="submit">
```

## Exit ticket

Ask learners to explain the form submission flow in plain language.

---

# 13. Session 8: Event Delegation and Final Application

## Learning objectives

Learners should be able to:

- Explain event bubbling.
- Use event delegation.
- Handle dynamic buttons.
- Complete tasks.
- Remove tasks.
- Render the final application.
- Verify the complete project.

## Event delegation demonstration

```js
taskListElement.addEventListener(
  "click",
  (event) => {
    if (!(event.target instanceof Element)) {
      return;
    }

    const buttonElement =
      event.target.closest("button");

    if (buttonElement === null) {
      return;
    }

    const action =
      buttonElement.dataset.action;

    console.log(action);
  }
);
```

Explain:

```text
A parent listens for events from its children.
```

## Final verification sequence

### Add

- Enter a valid title.
- Submit.
- Confirm appearance and count.

### Invalid input

- Submit empty input.
- Submit whitespace.
- Submit an overly long title.

### Complete

- Click Complete.
- Confirm visual state.
- Confirm button becomes Undo.

### Undo

- Click Undo.
- Confirm visual state returns.

### Remove

- Click Remove.
- Confirm task disappears.
- Confirm count updates.

### Empty state

- Remove all tasks.
- Confirm empty-state message appears.

### Safe rendering

Enter:

```html
<strong>Must remain text</strong>
```

Confirm that it appears literally.

### Keyboard

Use only the keyboard to:

- Focus the input.
- Submit a task.
- Focus task buttons.
- Complete a task.
- Remove a task.

---

# 14. Assessment Strategy

## Formative assessment

Use throughout the course:

- Prediction questions.
- Console checks.
- Pair explanations.
- Short code modifications.
- Exit tickets.
- Debugging worksheets.
- Code tracing tables.

## Summative assessment

Learners complete the task application and explain:

1. The task data model.
2. The role of the `tasks` array.
3. The form submission flow.
4. The rendering function.
5. The event delegation strategy.
6. The use of `textContent`.
7. The handling of empty input.
8. The application’s accessibility features.

---

# 15. Final Project Rubric

Score each category from `0` to `3`.

| Category | 0 | 1 | 2 | 3 |
|---|---:|---:|---:|---:|
| Variables and types | Missing | Partially correct | Mostly correct | Correct and clear |
| Functions | Missing | Large or unclear | Mostly organized | Focused and reusable |
| Arrays and objects | Missing | Inconsistent data | Mostly correct | Clear and consistent model |
| DOM selection | Missing | Fragile | Mostly validated | Validated and clear |
| Rendering | Missing | Partial output | Works with issues | Reliable state rendering |
| Form handling | Missing | Basic handler | Validation works | Complete and accessible |
| Event handling | Missing | Static only | Dynamic actions partly work | Delegation works correctly |
| Validation | Missing | Minimal | Common cases handled | Robust and understandable |
| Debugging | Cannot diagnose | Needs substantial help | Can diagnose common issues | Uses systematic workflow |
| Accessibility | Missing | Basic labels | Keyboard partly works | Labels, focus, status, semantics |
| Security | Unsafe rendering | Some safe handling | Mostly safe | Consistently safe text handling |
| Code quality | Difficult to read | Inconsistent | Generally readable | Clear, maintainable style |

Maximum score:

```text
36 points
```

## Suggested interpretation

| Score | Interpretation |
|---:|---|
| 30–36 | Strong completion |
| 24–29 | Successful completion with minor gaps |
| 18–23 | Developing; targeted review needed |
| 0–17 | Significant guided support needed |

---

# 16. Common Learner Misconceptions

## “The browser runs all files automatically”

Clarify:

```text
HTML must reference CSS and JavaScript.
```

## “A variable stores the same thing as every other variable”

Explain primitive copying versus object references.

## “`const` objects cannot change”

Clarify binding versus object mutation.

## “A function runs when it is declared”

Clarify:

```text
Definition → describes behavior
Call       → executes behavior
```

## “`return` displays a result”

Clarify:

```text
return → sends a value to the caller
console.log → displays a value in the Console
```

## “`find` returns an index”

Clarify:

```text
find      → matching value
findIndex → matching position
```

## “The DOM is the application state”

Clarify:

```text
State → application data
DOM   → visible representation
```

## “Client-side validation makes data secure”

Clarify:

```text
Client validation → usability
Server validation → security boundary
```

## “A button is just a styled div”

Use real semantic elements:

```html
<button type="button">
  Remove
</button>
```

---

# 17. Differentiation Strategies

## Learners needing more support

Provide:

- Starter files.
- Function templates.
- Completed examples.
- Pair programming.
- Trace tables.
- Guided Console exercises.
- Smaller implementation steps.
- A reference copy of the current working project.

Use prompts such as:

```text
What value should this variable contain?
What element should this selector find?
What should happen when the condition is false?
```

## Learners ready for more challenge

Offer:

- `localStorage`.
- Task filtering.
- Task editing.
- Search.
- Priority.
- Due dates.
- ES modules.
- Automated tests.
- TypeScript exploration.
- Performance improvements.
- API integration design.

Avoid allowing advanced learners to skip the fundamentals. Ask them to explain their design decisions.

---

# 18. Pair Programming Roles

Use rotating roles.

## Driver

The driver:

- Controls the keyboard.
- Writes the code.
- Reads instructions aloud.
- Explains each change.

## Navigator

The navigator:

- Reads the requirement.
- Predicts behavior.
- Watches for errors.
- Suggests tests.
- Asks clarifying questions.

Switch roles every 10–20 minutes.

## Pair prompts

The navigator can ask:

```text
What is the current state?
What value should this function return?
What happens if the input is empty?
What does this selector match?
What will the loop do on the next iteration?
```

---

# 19. Trainer Troubleshooting Guide

## Learner has a blank page

Check:

1. Is the HTML valid?
2. Is the JavaScript file path correct?
3. Is there a syntax error?
4. Is the script using `defer`?
5. Is an earlier error stopping execution?

## Learner sees `null`

Check:

1. Selector spelling.
2. HTML ID.
3. Script timing.
4. File being served.
5. Browser refresh.

## Learner’s form reloads

Check:

```js
event.preventDefault();
```

and ensure the listener is attached to:

```js
"submit"
```

not only `"click"`.

## Learner’s task appears twice

Check:

- `renderTasks` clears the list.
- The submit listener is registered once.
- The task is pushed once.
- The event is not handled by duplicate listeners.

## Learner uses `innerHTML` with user input

Explain the security issue and replace it with:

```js
element.textContent =
  userProvidedValue;
```

## Learner is stuck in a loop

Ask:

```text
Which variable controls the condition?
Where does that variable change?
Can the condition ever become false?
```

---

# 20. Trainer Prompts

Use these prompts instead of immediately giving answers.

## Variables

```text
What value is stored here?
Can this binding be reassigned?
```

## Conditions

```text
What does the condition evaluate to?
Which branch runs?
```

## Loops

```text
What is the loop variable on this iteration?
What makes the loop stop?
```

## Functions

```text
What are the inputs?
What is the output?
What responsibility should this function have?
```

## Arrays

```text
Is the first index 0 or 1?
Does this method mutate the original array?
```

## Objects

```text
Are you reading a property or a variable?
Should this use dot or bracket notation?
```

## DOM

```text
What element should this selector find?
What happens if the selector returns null?
```

## Events

```text
What event starts this behavior?
What is the event target?
Should the default action be prevented?
```

## Debugging

```text
What is the first error?
What assumption did the program make?
What is the smallest experiment that tests your hypothesis?
```

---

# 21. Reflection Activities

## One-minute explanation

Ask each learner to explain one concept in under one minute:

- `const` versus `let`.
- `find` versus `findIndex`.
- Function parameters.
- Scope.
- Event delegation.
- Rendering.
- `textContent`.

## Code tracing

Give learners this code:

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

const completedTasks =
  tasks.filter(
    (task) => task.completed
  );

console.log(completedTasks.length);
```

Ask:

```text
What is printed?
Why?
```

Expected:

```text
1
```

## Design explanation

Ask learners:

```text
Why is the tasks array the source of truth?
Why do we render after changing the array?
Why do we use textContent?
```

---

# 22. Final Instructor Checklist

## Before teaching

- [ ] Starter project tested.
- [ ] Final project tested.
- [ ] Browser and editor available.
- [ ] Slides available.
- [ ] Workbook available.
- [ ] Backup files available.
- [ ] Exercises selected.
- [ ] Timing planned.

## During teaching

- [ ] Ask for predictions.
- [ ] Demonstrate incrementally.
- [ ] Require verification.
- [ ] Normalize errors.
- [ ] Encourage explanations.
- [ ] Check learner file paths.
- [ ] Rotate pair roles.
- [ ] Provide extension work.

## Before completion

- [ ] Every learner has a working application.
- [ ] Every learner can explain the data model.
- [ ] Every learner can explain event handling.
- [ ] Every learner can debug a basic error.
- [ ] Keyboard interaction tested.
- [ ] User input rendered safely.
- [ ] Final reflection completed.

---

# 23. Recommended Final Demonstration

Ask learners to perform this live:

1. Open the application.
2. Explain the HTML form.
3. Explain the `tasks` array.
4. Add a task.
5. Show the form event handler.
6. Show the new task object.
7. Show the rendered DOM element.
8. Complete the task.
9. Explain event delegation.
10. Remove the task.
11. Explain the empty state.
12. Enter HTML-looking text.
13. Explain why it remains text.
14. Use the keyboard to repeat the workflow.

The learner should be able to describe:

```text
The user submits the form.
The handler prevents a reload.
The input is read and validated.
A task object is created.
The task is added to the array.
The array is rendered into the DOM.
Buttons change the task state.
The interface is rendered again.
```

---

# 24. Course Completion Statement

A learner has successfully completed the series when they can:

- Build the application from a starter project.
- Explain the major JavaScript concepts.
- Read and modify existing code.
- Find and fix common errors.
- Add at least one independent feature.
- Explain the relationship between state and DOM.
- Use safe text rendering.
- Demonstrate keyboard-accessible interactions.

The ultimate goal is not memorization.

The goal is independent reasoning:

```text
Understand the requirement
    ↓
Choose a data model
    ↓
Write a small function
    ↓
Connect the function to an event
    ↓
Update state
    ↓
Render the result
    ↓
Verify the behavior
```
