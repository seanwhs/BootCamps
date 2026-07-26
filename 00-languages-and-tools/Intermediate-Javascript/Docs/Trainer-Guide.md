# Trainer Guide  
## Intermediate JavaScript: Asynchronous Flow & Code Organization

This guide helps instructors teach the complete **Intermediate JavaScript: Asynchronous Flow & Code Organization** series.

The course builds one browser application progressively:

```text
Simple JavaScript
      ↓
Asynchronous callbacks
      ↓
Promises and async/await
      ↓
Task classes and prototypes
      ↓
ES modules
      ↓
Browser storage
      ↓
Testing, accessibility, security, and extensions
```

---

# 1. Course Overview

## Course Title

**Intermediate JavaScript: Asynchronous Flow & Code Organization**

## Primary Project

**Async Task Manager**

## Intended Audience

Learners who already understand:

- Variables.
- Functions.
- Arrays.
- Objects.
- Conditions.
- Loops.
- Basic DOM selection.
- Basic browser events.
- Basic HTML and CSS.

## Prerequisites

Students should be able to read and write:

```javascript
const button = document.querySelector("#save-button");

button.addEventListener("click", () => {
  console.log("Clicked");
});
```

Students do not need prior experience with:

- Promises.
- `async`/`await`.
- Classes.
- Prototypes.
- ES modules.
- Browser storage.
- Backend development.
- Frameworks.

---

# 2. Recommended Delivery Formats

## Intensive Format

Recommended duration: **3–4 full days**

| Day | Topics |
|---|---|
| Day 1 | Primers, synchronous JavaScript, callbacks |
| Day 2 | Promises, `async`/`await`, error handling |
| Day 3 | Prototypes, classes, object-oriented patterns |
| Day 4 | Modules, storage, testing, security, capstone |

## Standard Workshop Format

Recommended duration: **8 sessions of 2–3 hours**

| Session | Topics |
|---|---|
| 1 | Setup, foundations, synchronous code |
| 2 | Call stack, event loop, callbacks |
| 3 | Promises and chaining |
| 4 | `async`/`await` and robust errors |
| 5 | Prototypes, constructors, classes |
| 6 | Inheritance and domain modeling |
| 7 | Modules and storage |
| 8 | Testing, accessibility, security, extensions |

## Extended Course

Recommended duration: **12–16 sessions**

Add dedicated sessions for:

- Developer Tools.
- Terminal and local development.
- Git.
- HTTP and APIs.
- Testing.
- Accessibility.
- Security.
- Extension projects.

---

# 3. Trainer Responsibilities

Before the course, the trainer should:

- [ ] Verify the complete project works.
- [ ] Test all code blocks in the target browser.
- [ ] Confirm the local server command.
- [ ] Prepare a clean starter repository.
- [ ] Prepare a completed reference repository.
- [ ] Test the slide deck.
- [ ] Test student exercises.
- [ ] Prepare known failure examples.
- [ ] Confirm internet access if using external APIs.
- [ ] Prepare a local JSON fixture as an API fallback.
- [ ] Review accessibility and security examples.
- [ ] Prepare optional Git checkpoints.

During the course, the trainer should:

- [ ] Require verification after each major change.
- [ ] Ask students to predict output before running code.
- [ ] Encourage console and breakpoint use.
- [ ] Avoid fixing code silently for students.
- [ ] Ask learners to explain the failure first.
- [ ] Separate syntax problems from architecture problems.
- [ ] Protect time for hands-on work.
- [ ] Use the reference solution only after students attempt the exercise.

After the course, the trainer should:

- [ ] Review student capstone work.
- [ ] Collect common misconceptions.
- [ ] Record unresolved technical issues.
- [ ] Update environment instructions.
- [ ] Refresh browser and dependency versions.

---

# 4. Learning Outcomes

By the end of the course, students should be able to:

## Asynchronous JavaScript

- Explain synchronous and asynchronous execution.
- Describe the call stack.
- Describe browser Web APIs.
- Explain the event loop at a practical level.
- Write callback-based asynchronous code.
- Identify callback nesting problems.
- Create and consume Promises.
- Use `.then()`, `.catch()`, and `.finally()`.
- Use `async`/`await`.
- Handle asynchronous errors with `try`/`catch`/`finally`.
- Prevent duplicate requests.
- Understand cancellation and stale responses.

## Object-Oriented JavaScript

- Explain prototypes.
- Describe prototype lookup.
- Write factory functions.
- Write constructor functions.
- Explain the `new` keyword.
- Define classes.
- Add instance methods.
- Add static methods.
- Use inheritance.
- Use `extends` and `super`.
- Restore class instances from JSON.

## Code Organization

- Explain separation of concerns.
- Use named exports.
- Use imports.
- Create module boundaries.
- Separate UI, services, models, API code, and storage.
- Keep the entry point small.

## Browser Storage

- Use `localStorage`.
- Use `sessionStorage`.
- Serialize data with `JSON.stringify`.
- Parse data with `JSON.parse`.
- Validate stored data.
- Handle malformed storage.
- Understand origin scope.
- Explain storage security limitations.

## Engineering Practice

- Use browser Developer Tools.
- Read console errors.
- Set breakpoints.
- Inspect network requests.
- Test success and failure paths.
- Consider accessibility.
- Consider XSS and storage risks.
- Use Git checkpoints.
- Extend the application safely.

---

# 5. Teaching Philosophy

## Beginner-Friendly Explanation

Use everyday analogies:

| Technical concept | Analogy |
|---|---|
| Call stack | A stack of plates |
| Event loop | A traffic controller |
| Callback | A phone number left for later notification |
| Promise | A receipt for future work |
| Prototype | A shared reference shelf |
| Module | A department with a defined interface |
| `localStorage` | A filing cabinet |
| `sessionStorage` | A temporary desk drawer |
| Service layer | A business operations desk |
| Model | A rulebook for valid objects |

Do not use the analogy as a substitute for technical accuracy. Use it to introduce the concept, then connect it to code.

## Ask Before Explaining

When students see:

```javascript
setTimeout(() => {
  console.log("Later");
}, 0);

console.log("Now");
```

ask:

> What will print first?

Have students write a prediction before running it.

## Prefer Evidence

When a student says:

> JavaScript runs this later because timers are slow.

Ask:

> What can we inspect to confirm that?

Then use:

- The console.
- A breakpoint.
- The call stack.
- A timeline.
- A controlled experiment.

---

# 6. Classroom Setup

## Recommended Room Setup

Students should have:

- One computer per learner or pair.
- A modern browser.
- A code editor.
- A terminal.
- Internet access or local API fixtures.
- Permission to run a local server.

## Pairing Model

Pair programming works well:

### Driver

Types the code.

### Navigator

Reads the instructions, predicts behavior, and checks verification.

Switch roles every 15–20 minutes.

## Trainer Display

The trainer should have:

- Slide deck.
- Browser with Developer Tools.
- Code editor.
- Terminal.
- Completed project.
- Deliberately broken project.
- Local API fixture.

---

# 7. Recommended Session Pattern

Use this pattern for each technical section:

```text
1. State the target.
2. Explain the concept.
3. Demonstrate a minimal example.
4. Ask for a prediction.
5. Run the example.
6. Implement the project feature.
7. Ask students to verify.
8. Introduce a deliberate failure.
9. Debug the failure.
10. Summarize the engineering lesson.
```

Suggested timing for a two-hour session:

| Activity | Time |
|---|---:|
| Review previous work | 10 minutes |
| Concept explanation | 20 minutes |
| Trainer demonstration | 20 minutes |
| Student implementation | 40 minutes |
| Debugging exercise | 20 minutes |
| Review and assessment | 10 minutes |

---

# 8. Diagnostic Assessment

Use this before the main series.

## Question 1

What does this print?

```javascript
console.log("A");

setTimeout(() => {
  console.log("B");
}, 0);

console.log("C");
```

Expected:

```text
A
C
B
```

## Question 2

What is wrong?

```javascript
const response = await fetch("/api/tasks");
const data = response.data;
```

Expected discussion:

- `await` must be inside an async context.
- A `Response` object is not the parsed body.
- The code needs `await response.json()`.

## Question 3

What does this return?

```javascript
const task = JSON.parse(rawJSON);
```

Expected discussion:

- An ordinary JavaScript value.
- Not automatically a class instance.
- Methods and prototypes are not restored.

## Question 4

Why use `textContent`?

Expected discussion:

- It renders content as text.
- It avoids interpreting user input as HTML.
- It reduces XSS risk.

## Question 5

What is the difference between `localStorage` and `sessionStorage`?

Expected discussion:

- `localStorage` is persistent.
- `sessionStorage` is associated with a browser tab session.
- Both store strings.

---

# 9. Primer Teaching Guide

## Primer 0: Prerequisites and Workflow

### Teaching Goal

Ensure every student can create, serve, and inspect a basic project.

### Trainer Demonstration

Show:

```bash
mkdir async-task-manager
cd async-task-manager
python3 -m http.server 8000
```

Then open:

```text
http://localhost:8000
```

### Common Problems

- Python command differs by operating system.
- Server started in the wrong directory.
- Port `8000` is already in use.
- Students open `file://` instead of `http://localhost`.

### Exit Criteria

Students can:

- Create a project directory.
- Open it in an editor.
- Start a local server.
- Open Developer Tools.
- Explain the current directory.

---

## Primer 1: HTML, CSS, and JavaScript Foundations

### Teaching Goal

Ensure students understand the DOM and event-driven browser behavior.

### Key Demonstration

Start with:

```html
<button id="demo-button" type="button">
  Click
</button>

<p id="message">Waiting.</p>
```

Then:

```javascript
const button = document.querySelector("#demo-button");
const message = document.querySelector("#message");

button.addEventListener("click", () => {
  message.textContent = "Clicked.";
});
```

### Emphasize

- IDs must match selectors.
- Form submission has default browser behavior.
- `preventDefault()` stops that behavior.
- State changes do not automatically update the DOM.
- Rendering must be explicit.

### Exit Criteria

Students can create a form and update a list from JavaScript.

---

## Primer 2: Developer Tools

### Teaching Goal

Make debugging a normal part of implementation.

### Demonstrate

1. Console logging.
2. Elements inspection.
3. CSS changes.
4. Breakpoints.
5. Call stack.
6. Network requests.
7. Storage inspection.

### Trainer Prompt

Ask:

> Which panel would you open first if the button does nothing?

Expected answers:

- Console.
- Elements.
- Sources/Debugger.
- Event listener inspection.

### Exit Criteria

Students can identify a source line from an error and inspect a stored value.

---

## Primer 3: Terminal and Local Development

### Teaching Goal

Make file paths and server behavior comfortable.

### Common Demonstration

Show that this path:

```html
<script src="./js/main.js"></script>
```

is relative to `index.html`.

Then show:

```javascript
import { Task } from "../models/task.js";
```

from a file inside `js/services/`.

### Exit Criteria

Students can explain the difference between:

```text
./
../
```

and can start a local server from the correct directory.

---

## Primer 4: HTTP, JSON, and APIs

### Teaching Goal

Prepare students to understand asynchronous data loading.

### Demonstration

Show a request in the Network panel:

```javascript
const response = await fetch(
  "https://jsonplaceholder.typicode.com/todos/1"
);

if (!response.ok) {
  throw new Error(`HTTP ${response.status}`);
}

const data = await response.json();

console.log(data);
```

### Emphasize

- `fetch()` returns a Promise.
- HTTP failure status is not always a rejected Promise.
- JSON parsing is asynchronous.
- Parsed data must be validated.
- CORS is controlled by the server.

### Exit Criteria

Students can explain:

```text
Request → Response → Status check → JSON parse → Validation
```

---

## Primer 5: Git

### Teaching Goal

Introduce safe checkpoints without overwhelming students.

### Minimum Commands

```bash
git init
git status
git add .
git commit -m "Message"
git log --oneline
```

### Recommended Practice

Require a commit after:

- Initial project setup.
- Callback implementation.
- Promise migration.
- Class introduction.
- Modularization.
- Storage integration.

### Exit Criteria

Students can restore a file to the last committed state and explain a commit.

---

## Primer 6: Language Essentials

### Teaching Goal

Fill syntax gaps before asynchronous control flow.

### Focus On

- Function return values.
- Array methods.
- Object references.
- Destructuring.
- Spread syntax.
- Classes.
- Errors.

### Avoid Overloading

Do not turn this primer into a complete JavaScript language course. Identify gaps, then direct students to the relevant reference sections.

---

# 10. Part 1 Teaching Guide: Asynchronous Paradigm

## Core Message

JavaScript usually runs one piece of JavaScript at a time, but the browser can coordinate delayed work.

## Demonstration Sequence

### Demonstration 1: Synchronous Order

```javascript
console.log("First");
console.log("Second");
console.log("Third");
```

Ask students to predict the output.

### Demonstration 2: Blocking

```javascript
function blockForMilliseconds(duration) {
  const start = Date.now();

  while (Date.now() - start < duration) {
  }
}
```

Ask students to click a button while the loop runs.

### Demonstration 3: Timer

```javascript
console.log("Start");

setTimeout(() => {
  console.log("Delayed");
}, 1000);

console.log("End");
```

### Demonstration 4: Callback Loader

```javascript
function loadExampleTasks(callback) {
  setTimeout(() => {
    callback(null, [
      {
        id: 1,
        title: "Read about the event loop",
        completed: false,
      },
    ]);
  }, 1000);
}
```

## Key Misconceptions

### Misconception: JavaScript Runs Timers in Parallel

Clarify:

- The browser tracks the timer.
- JavaScript callback execution still uses the JavaScript thread.
- The callback waits for the call stack.

### Misconception: Zero Delay Means Immediate

Demonstrate:

```javascript
setTimeout(callback, 0);
```

Explain that it means “eligible as soon as possible,” not “interrupt now.”

### Misconception: Asynchronous Means Simultaneous JavaScript

Explain that asynchronous coordination is not the same as multiple JavaScript functions executing simultaneously on the same thread.

## Check for Understanding

Ask students to explain:

```text
What handles the timer while JavaScript continues?
What happens to the callback after the timer finishes?
Why can the callback still be delayed?
```

## Practical Exercise

Ask students to add:

- Loading status.
- Success status.
- Failure status.
- Button disabling.
- Error-first callback handling.

## Exit Criteria

Students can trace:

```text
Click
  ↓
Timer registered
  ↓
Current code finishes
  ↓
Callback queued
  ↓
Callback executes
  ↓
UI updates
```

---

# 11. Part 2 Teaching Guide: Promises and `async`/`await`

## Core Message

Promises represent future results and provide a structured alternative to nested callbacks.

## Demonstration Sequence

### Demonstration 1: Promise States

```javascript
const promise = new Promise((resolve) => {
  setTimeout(() => {
    resolve("Finished");
  }, 1000);
});
```

Inspect immediately and after the timeout.

### Demonstration 2: `.then()`

```javascript
promise.then((result) => {
  console.log(result);
});
```

### Demonstration 3: `.catch()`

```javascript
Promise.reject(
  new Error("Expected failure")
).catch((error) => {
  console.error(error.message);
});
```

### Demonstration 4: `.finally()`

```javascript
promise.finally(() => {
  console.log("Cleanup");
});
```

### Demonstration 5: `async`/`await`

```javascript
async function run() {
  try {
    const result = await promise;
    console.log(result);
  } catch (error) {
    console.error(error);
  } finally {
    console.log("Cleanup");
  }
}
```

## Key Misconceptions

### Misconception: `await` Blocks the Browser

Clarify that `await` pauses the current async function, not the entire browser.

### Misconception: Every `fetch()` Failure Is a Rejection

Demonstrate why this is required:

```javascript
if (!response.ok) {
  throw new Error(
    `HTTP ${response.status}`
  );
}
```

### Misconception: `.finally()` Receives the Result

Explain:

```javascript
finally(() => {
  // No successful result argument.
});
```

It is for cleanup, not result processing.

### Misconception: `async` Makes Work Synchronous

Explain that `async` changes the function’s return type and enables `await`; it does not remove asynchronous behavior.

## Practical Exercise

Convert:

```javascript
loadTasks((error, tasks) => {
  if (error) {
    showError(error);
    return;
  }

  renderTasks(tasks);
});
```

to:

```javascript
async function loadTasksIntoApplication() {
  try {
    const tasks = await loadTasks();
    renderTasks(tasks);
  } catch (error) {
    showError(error);
  }
}
```

## Exit Criteria

Students can:

- Create a Promise.
- Handle fulfillment and rejection.
- Use `finally`.
- Convert callbacks to `async`/`await`.
- Explain why cleanup belongs in `finally`.

---

# 12. Part 3 Teaching Guide: Prototypes and Classes

## Core Message

Modern class syntax is built on JavaScript’s prototype system.

## Demonstration Sequence

### Demonstration 1: Object Prototype

```javascript
const task = {
  title: "Prototype demo",
};

Object.getPrototypeOf(task);
```

### Demonstration 2: Factory

```javascript
function createTask(title) {
  return {
    title,
    completed: false,
  };
}
```

### Demonstration 3: Constructor

```javascript
function Task(title) {
  this.title = title;
}

Task.prototype.complete = function () {
  this.completed = true;
};
```

### Demonstration 4: Class

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

### Demonstration 5: Inheritance

```javascript
class ImportedTask extends Task {
  constructor(title, source) {
    super(title);
    this.source = source;
  }
}
```

## Key Misconceptions

### Misconception: Classes Are Not Prototype-Based

Explain that methods are still available through the prototype chain.

### Misconception: JSON Restores Classes

Demonstrate:

```javascript
const task = new Task("Example");
const restored = JSON.parse(JSON.stringify(task));

console.log(restored instanceof Task);
// false
```

### Misconception: Inheritance Is Always Best

Discuss composition:

```text
TaskService has tasks.
ImportedTask is a Task.
```

Use inheritance only when the “is a” relationship is genuine.

## Practical Exercise

Ask students to add:

- `complete()`.
- `reopen()`.
- `toggleCompletion()`.
- `getStatusLabel()`.
- `toJSON()`.
- `Task.fromJSON()`.

## Exit Criteria

Students can explain:

```text
Task instance
  ↓
Task.prototype
  ↓
Object.prototype
  ↓
null
```

---

# 13. Part 4 Teaching Guide: Modules and Storage

## Core Message

Modules organize code; storage persists data; both require explicit boundaries and validation.

## Demonstration Sequence

### Demonstration 1: Named Export

```javascript
export function formatTitle(title) {
  return title.trim();
}
```

### Demonstration 2: Import

```javascript
import { formatTitle } from "./format.js";
```

### Demonstration 3: Storage

```javascript
localStorage.setItem(
  "tasks",
  JSON.stringify(tasks)
);
```

### Demonstration 4: Restoration

```javascript
const raw = localStorage.getItem("tasks");

const values = raw === null
  ? []
  : JSON.parse(raw);
```

### Demonstration 5: Class Restoration

```javascript
const tasks = values.map(Task.fromJSON);
```

## Key Misconceptions

### Misconception: Modules Are Just Separate Files

Explain that modules also provide:

- Scope.
- Explicit dependencies.
- Public interfaces.
- Better dependency direction.

### Misconception: Storage Saves JavaScript Objects Directly

Explain that storage saves strings.

### Misconception: JSON Parsing Restores Methods

Reinforce `Task.fromJSON()`.

### Misconception: Browser Storage Is Secure Private Storage

Explain that users and same-origin scripts can inspect it.

## Practical Exercise

Ask students to split a large script into:

```text
models/
services/
ui/
api/
utils/
```

Then add storage with:

- Missing data handling.
- Malformed JSON handling.
- Invalid record handling.
- Storage write error handling.

## Exit Criteria

Students can describe the flow:

```text
Read storage
  ↓
Parse JSON
  ↓
Validate shape
  ↓
Restore Task instances
  ↓
Give instances to service
  ↓
Render UI
```

---

# 14. Common Misconceptions and Responses

| Misconception | Trainer response |
|---|---|
| “The timer runs JavaScript in parallel.” | The browser tracks the timer; the callback still waits for the call stack. |
| “Zero milliseconds means now.” | It means eligible after current synchronous work. |
| “`await` blocks the browser.” | It pauses the current async function. |
| “`fetch` rejects for 404.” | Check `response.ok` explicitly. |
| “JSON preserves classes.” | JSON preserves data, not prototypes or methods. |
| “A class is unrelated to prototypes.” | Class methods are available through the prototype. |
| “A module is just a file.” | It also creates scope and defines dependencies. |
| “localStorage stores objects.” | It stores strings; use JSON. |
| “Client validation protects the API.” | The server must validate independently. |
| “A disabled button prevents duplicate requests.” | Add an application-level state guard too. |
| “An empty array is false.” | Arrays are truthy; check `.length`. |
| “The DOM updates automatically when state changes.” | Explicit rendering is required. |
| “The browser console is only for errors.” | It is also an experiment and inspection tool. |
| “More inheritance always means better design.” | Prefer composition when the relationship is not “is a.” |

---

# 15. Facilitation Prompts

Use these questions during demonstrations:

## Before Running Code

- What do you predict will happen?
- Which line runs first?
- What type is this value?
- Will this function return immediately?
- What could fail?

## During Debugging

- What is the first error?
- What value is unexpected?
- Which function called this one?
- Is the problem in state, rendering, storage, or the API?
- What evidence supports your hypothesis?

## During Architecture Discussion

- Which module owns this responsibility?
- Should this function know about the DOM?
- Should this service know about storage?
- What happens if the data is malformed?
- Can this dependency be replaced for testing?

## During Review

- What is the happy path?
- What is the failure path?
- What cleanup must always happen?
- What could happen on refresh?
- What could a malicious user control?

---

# 16. Practical Lab Structure

Every lab should include:

## Target

State the exact file or behavior.

## Concept

Explain why the feature exists.

## Implementation

Students write or replace complete code.

## Verification

Students run a specific test.

## Reflection

Students answer:

```text
What changed?
Why does it work?
What could fail?
Which module owns this behavior?
```

---

# 17. Lab Assessment Rubric

Use a four-level scale.

| Level | Description |
|---|---|
| 4 — Independent | Implements, tests, explains, and debugs independently |
| 3 — Competent | Implements with minor guidance and explains the main behavior |
| 2 — Developing | Follows examples but needs help connecting concepts |
| 1 — Beginning | Requires substantial support to implement or explain |

Assess:

| Skill | Level |
|---|---:|
| DOM interaction | ____ |
| Event handling | ____ |
| Callback implementation | ____ |
| Promise handling | ____ |
| `async`/`await` | ____ |
| Error handling | ____ |
| Class design | ____ |
| Module organization | ____ |
| Storage handling | ____ |
| Debugging | ____ |
| Testing | ____ |
| Accessibility | ____ |
| Security awareness | ____ |

---

# 18. Capstone Assessment

Students should extend the application with at least one feature.

Recommended choices:

- Priorities.
- Due dates.
- Search.
- Sorting.
- Editing.
- Undo deletion.
- Statistics.
- Import/export.
- Theme switching.
- Offline awareness.
- Request cancellation.

## Required Deliverables

Each student or pair should submit:

1. Working source code.
2. Updated directory structure.
3. A short README.
4. A manual test plan.
5. At least three automated or assertion-based tests.
6. A short architecture explanation.
7. A security note.
8. An accessibility note.
9. A Git history with meaningful commits.

## Capstone Presentation

Students should explain:

- What feature they added.
- Which modules changed.
- What data model changes were required.
- How persistence works.
- How errors are handled.
- How they tested the feature.
- What they would improve next.

---

# 19. Capstone Rubric

| Category | Points |
|---|---:|
| Feature works correctly | 20 |
| Code organization | 15 |
| Error handling | 10 |
| Data validation | 10 |
| Async behavior | 10 |
| Persistence | 10 |
| Testing | 10 |
| Accessibility | 5 |
| Security awareness | 5 |
| Documentation | 5 |
| **Total** | **100** |

## Performance Levels

### Excellent: 90–100

- Feature is complete.
- Architecture is clear.
- Failure paths are handled.
- Tests are meaningful.
- Accessibility and security are considered.

### Proficient: 75–89

- Feature works.
- Some edge cases or documentation are incomplete.
- Architecture is mostly sound.

### Developing: 60–74

- Main path works with assistance.
- Error handling or persistence has gaps.
- Tests are limited.

### Beginning: Below 60

- Feature is incomplete.
- Core behavior is unreliable.
- Student cannot yet explain the data flow.

---

# 20. Live Debugging Exercise

Use a deliberately broken version of the application.

## Broken Example 1: Missing `finally`

```javascript
async function handleLoadTasks() {
  this.loadTasksButton.disabled = true;

  try {
    const tasks = await fetchExampleTasks();
    this.taskService.replaceAll(tasks);
  } catch (error) {
    this.status.show(error.message, "error");
  }

  this.render();
}
```

Ask students:

> What happens if the Promise rejects?

Expected discovery:

- The button remains disabled.
- Cleanup belongs in `finally`.

Corrected version:

```javascript
async function handleLoadTasks() {
  this.loadTasksButton.disabled = true;

  try {
    const tasks = await fetchExampleTasks();
    this.taskService.replaceAll(tasks);
  } catch (error) {
    this.status.show(error.message, "error");
  } finally {
    this.loadTasksButton.disabled = false;
  }

  this.render();
}
```

## Broken Example 2: Unsafe HTML

```javascript
title.innerHTML = task.title;
```

Ask students to enter:

```html
<img src="x" onerror="alert('bad')">
```

Correct:

```javascript
title.textContent = task.title;
```

## Broken Example 3: Plain Objects After JSON

```javascript
const tasks = JSON.parse(rawValue);

tasks[0].complete();
```

Expected discovery:

- Parsed values are plain objects.
- Use `Task.fromJSON()`.

---

# 21. Trainer Troubleshooting Guide

## Students See a Blank Page

Check:

1. Browser console.
2. JavaScript syntax.
3. Script path.
4. Module path.
5. Server URL.
6. HTML element IDs.

## Students See Import Errors

Check:

```html
<script type="module">
```

Check `.js` extensions:

```javascript
import { Task } from "./models/task.js";
```

Check relative paths from the importing file.

## Tasks Disappear

Check:

- `saveTasks()` is called.
- The storage key is consistent.
- The application uses the same origin.
- Startup does not overwrite restored state.
- Storage is not being cleared.

## Button Does Nothing

Check:

- The button selector.
- The event listener.
- Earlier console errors.
- Button type.
- Whether the script completed initialization.

## Promise Errors Are Unhandled

Check that every started Promise has:

```javascript
.catch(...)
```

or:

```javascript
try {
  await operation();
} catch (error) {
}
```

## Students Are Copying Without Understanding

Pause and ask:

- What does this function receive?
- What does it return?
- What state does it change?
- Which module owns it?
- How would you test failure?

---

# 22. Trainer Reference: Final Request Flows

## Add Task

```text
Submit form
    ↓
task-form.js reads input
    ↓
app.js receives title
    ↓
TaskService validates title
    ↓
Task instance is created
    ↓
StorageService serializes task
    ↓
localStorage saves JSON
    ↓
App renders visible tasks
```

## Toggle Task

```text
Click completion button
    ↓
task-list.js invokes callback
    ↓
app.js calls TaskService.toggle()
    ↓
Task changes completion state
    ↓
StorageService saves all tasks
    ↓
App renders updated list
```

## Load Tasks

```text
Click load button
    ↓
App disables button
    ↓
API returns Promise
    ↓
await waits without blocking browser
    ↓
Response is validated
    ↓
Task instances enter service
    ↓
Tasks persist
    ↓
UI renders
    ↓
finally restores button
```

## Restore Tasks

```text
App starts
    ↓
StorageService reads localStorage
    ↓
JSON.parse()
    ↓
Task.fromJSON()
    ↓
TaskService receives valid instances
    ↓
Filter is applied
    ↓
UI renders
```

---

# 23. Trainer Slide-Deck Guidance

The minimalist deck contains many slides. Do not present every slide as a lecture page.

Use slides for:

- Topic framing.
- Vocabulary.
- Code patterns.
- Architecture diagrams represented as text.
- Review prompts.
- Checkpoints.

Use the browser and editor for:

- Live demonstrations.
- Debugging.
- DOM inspection.
- Network inspection.
- Storage inspection.
- Student implementation.

Recommended rhythm:

```text
Slide
  ↓
Question
  ↓
Live code
  ↓
Student prediction
  ↓
Execution
  ↓
Discussion
  ↓
Implementation
```

Avoid reading slides word-for-word.

---

# 24. Trainer Timing Guidance

## Conceptual Explanation

Limit a single uninterrupted explanation to approximately:

```text
10–20 minutes
```

Then switch to:

- Prediction.
- Demonstration.
- Student work.
- Review.

## Live Coding

Use small increments:

```text
5–10 minutes of code
        ↓
Pause
        ↓
Ask students to run and verify
```

## Debugging

Allow students to struggle productively, but intervene when:

- They are repeating the same unsuccessful action.
- They cannot identify the relevant file.
- The environment is broken for everyone.
- The problem is unrelated to the learning objective.

---

# 25. Accessibility for the Course

The training experience should support:

- Keyboard navigation.
- Screen-reader access where practical.
- High-contrast materials.
- Captions for recorded sessions.
- Written code examples.
- Alternative explanations.
- Pauses for note-taking.
- Pair programming.
- Accessible slide text.

The monochrome slide deck supports a simple visual presentation, but trainers should still check:

- Font size.
- Text density.
- Focus visibility during demonstrations.
- Code readability.
- Verbal descriptions of architecture and UI changes.

---

# 26. Student Support Strategy

When helping a student, use progressive hints.

## Hint 1: Point to the Layer

```text
Is this problem in the DOM, service, model, storage, or API?
```

## Hint 2: Point to the Value

```text
What is the value of this variable at the failing line?
```

## Hint 3: Point to the Contract

```text
What does this function promise to return?
```

## Hint 4: Point to the Fix

```text
Should this cleanup happen only on success?
```

Avoid immediately giving the complete answer unless:

- The student has attempted diagnosis.
- The problem is environmental.
- Time constraints require intervention.
- The answer is being demonstrated to the whole group.

---

# 27. Post-Course Follow-Up

Suggested follow-up activities:

## Week 1

- Review Promise chains.
- Add task search.
- Write unit tests for `TaskService`.

## Week 2

- Replace simulated API with a local fixture.
- Add request cancellation.
- Add a timeout.

## Week 3

- Add import/export.
- Add schema versioning.
- Test malformed data.

## Week 4

- Convert the model to TypeScript.
- Add automated browser tests.
- Add a lightweight backend.

---

# 28. Trainer Completion Checklist

## Preparation

- [ ] Environment tested.
- [ ] Starter project prepared.
- [ ] Complete project prepared.
- [ ] Slides tested.
- [ ] Local API fixture prepared.
- [ ] Broken examples prepared.
- [ ] Git checkpoints prepared.

## Delivery

- [ ] Students make predictions.
- [ ] Students run verification steps.
- [ ] Students use Developer Tools.
- [ ] Students explain failures.
- [ ] Students commit stable milestones.
- [ ] Students test success and failure paths.
- [ ] Accessibility is discussed.
- [ ] Security is discussed.

## Assessment

- [ ] Diagnostic assessment completed.
- [ ] Part checkpoints reviewed.
- [ ] Final project verified.
- [ ] Capstone assessed.
- [ ] Student reflection completed.
- [ ] Follow-up work assigned.

---

# 29. Final Trainer Summary

The main teaching objective is not to make students memorize isolated syntax.

Students should leave able to reason about a JavaScript application:

```text
Where does the data live?
Who owns the rule?
When does the operation finish?
What happens if it fails?
Which module should change?
How is the result tested?
How is the user informed?
Is the output safe and accessible?
```

The final success condition is that a student can independently:

1. Create a small JavaScript feature.
2. Organize it in an appropriate module.
3. Handle asynchronous success and failure.
4. Validate external data.
5. Persist data safely.
6. Debug unexpected behavior.
7. Test the feature.
8. Explain the design to another developer.
