# Part 0: Introduction

Welcome to **Intermediate JavaScript: Asynchronous Flow & Code Organization**.

This series is designed to move you from writing small, step-by-step JavaScript scripts to building a browser application that can:

- Perform work asynchronously without freezing the page.
- Handle delayed results and failures safely.
- Organize code across multiple files.
- Use reusable objects and classes.
- Store data in the browser.
- Separate user-interface code from application logic.
- Evolve from a simple script into a maintainable application.

Rather than learning each topic as an isolated language feature, we will connect every concept to a single practical project.

---

## The Application We Will Build

Across the series, we will build a small browser application called **Async Task Manager**.

The application will allow a user to:

1. Create tasks.
2. Mark tasks as completed.
3. Delete tasks.
4. Filter tasks by status.
5. Load example tasks asynchronously.
6. Handle loading and error states.
7. Persist tasks in the browser.
8. Organize the application into separate modules.
9. Use classes and object-oriented patterns where they improve the design.

The final application will be a client-side web application built with:

- HTML
- CSS
- Modern JavaScript
- ES modules
- Browser storage APIs
- Promises
- `async`/`await`
- Classes and inheritance
- Native browser APIs

We will not hide the important parts behind a framework. The goal is to understand what JavaScript itself is doing.

Frameworks such as React, Vue, or Angular are useful, but they do not replace knowledge of:

- The event loop.
- Promises.
- Functions and closures.
- Modules.
- Objects and prototypes.
- Error handling.
- Browser storage.

Understanding those fundamentals makes framework code much easier to learn later.

---

## The Final Architecture

By the end of the series, our application will have a structure similar to this:

```text
async-task-manager/
├── index.html
├── styles.css
└── js/
    ├── main.js
    ├── app.js
    ├── api/
    │   └── task-api.js
    ├── models/
    │   └── task.js
    ├── services/
    │   ├── storage-service.js
    │   └── task-service.js
    ├── ui/
    │   ├── task-form.js
    │   ├── task-list.js
    │   └── status-message.js
    └── utils/
        ├── errors.js
        └── validation.js
```

Each directory will have a specific responsibility.

### `index.html`

This file will contain the permanent structure of the page:

- The task form.
- The task list container.
- Buttons and controls.
- Areas where status messages will appear.

HTML will describe the page, but it will not contain the application’s business rules.

### `styles.css`

This file will control the appearance of the application:

- Layout.
- Colors.
- Spacing.
- Completed-task styles.
- Loading and error states.

Keeping styling separate from JavaScript prevents the application logic from becoming mixed with visual details.

### `js/main.js`

This will be the browser’s entry point.

It will start the application by:

- Importing the application class or startup function.
- Creating the application.
- Calling the initialization method.

The entry point should remain small. Its job is to start the system, not contain every feature.

### `js/app.js`

This will coordinate the major parts of the application.

It will connect:

- The user interface.
- Task services.
- Storage.
- Asynchronous loading.
- Event handlers.

You can think of this file as the application’s manager. It will not directly perform every operation; instead, it will delegate work to specialized modules.

### `js/api/task-api.js`

This module will simulate or perform asynchronous task loading.

It will demonstrate:

- Delayed responses.
- Promise resolution.
- Promise rejection.
- `async`/`await`.
- Error handling.

The API module will represent communication with an external server, even when we initially use a local simulation.

### `js/models/task.js`

This module will define the `Task` object.

It will contain:

- The task’s identifier.
- The task title.
- The completion state.
- Creation metadata.
- Methods that operate on the task.

This gives us a practical reason to study constructors, prototypes, classes, `extends`, and `super`.

### `js/services/storage-service.js`

This module will handle browser persistence.

It will provide a safe, consistent interface for:

- Saving tasks.
- Loading tasks.
- Removing saved tasks.
- Parsing stored JSON.
- Handling malformed or missing data.

The rest of the application should not need to know how `localStorage` works internally.

### `js/services/task-service.js`

This module will contain task-related operations such as:

- Adding a task.
- Completing a task.
- Deleting a task.
- Filtering tasks.
- Loading initial data.

This is an example of **separation of concerns**, which means giving each part of the program one clear type of responsibility.

### `js/ui/`

These modules will update the page:

- `task-form.js` will read and validate form input.
- `task-list.js` will render tasks.
- `status-message.js` will show loading, success, and error messages.

Keeping UI code separate from data and storage code makes both sides easier to understand and change.

### `js/utils/`

These modules will hold small reusable helpers:

- Validation functions.
- Custom error types.
- Common formatting logic.

A utility should be broadly reusable and should not depend heavily on the rest of the application.

---

## What You Will Learn

The series is divided into four major parts.

---

## Part 1: The Asynchronous Paradigm

In the first technical part, we will study why JavaScript can handle delayed work while continuing to respond to users.

You will learn:

- The difference between synchronous and asynchronous execution.
- Blocking and non-blocking code.
- The call stack.
- Browser Web APIs.
- The event loop.
- The task queue.
- Callback functions.
- How delayed work returns control to JavaScript.
- Why asynchronous code can appear to execute out of order.

We will use simple examples first, then connect those examples to the task manager.

A helpful analogy is a restaurant:

- The **call stack** is the chef’s current work surface.
- A browser API is like an assistant handling a long-running task.
- The **event loop** checks whether the chef is free.
- The **queue** holds completed orders waiting to be prepared.
- A callback is the instruction saying what to do when an order is ready.

The browser does not make JavaScript run multiple pieces of JavaScript simultaneously on the same main thread. Instead, it coordinates waiting work so the page can remain responsive.

---

## Part 2: Modern Asynchrony

The second part replaces deeply nested callbacks with modern tools.

You will learn:

- What a Promise represents.
- The `pending`, `fulfilled`, and `rejected` states.
- How `.then()` handles successful results.
- How `.catch()` handles failures.
- How `.finally()` runs cleanup logic.
- How Promise chains work.
- How `async` functions return Promises.
- How `await` makes asynchronous code easier to read.
- How `try/catch/finally` handles asynchronous failures.
- How to distinguish expected failures from programming errors.

A Promise is like a receipt for work that has not finished yet.

When you order something:

- The receipt starts as **pending**.
- You eventually receive the order, which is **fulfilled**.
- If the restaurant cannot complete the order, it is **rejected**.

The receipt does not contain the final food immediately. It represents the future result.

We will use these concepts to load task data and display:

- Loading indicators.
- Successful results.
- Failure messages.
- Cleanup behavior.

---

## Part 3: Prototypes and Object-Oriented Patterns

The third part explores how JavaScript objects work underneath the modern `class` syntax.

You will learn:

- What an object is.
- What a prototype is.
- How the prototype chain works.
- How JavaScript looks up properties and methods.
- Factory functions.
- Constructor functions.
- The `new` keyword.
- ES5-style object-oriented patterns.
- ES6 `class` syntax.
- Constructors and instance methods.
- Static methods.
- Inheritance with `extends`.
- Parent initialization with `super`.

JavaScript is prototype-based. This means objects can delegate property and method lookups to another object called a prototype.

The `class` syntax provides a cleaner way to write many common object-oriented patterns, but it does not change the prototype-based foundation underneath.

We will use a `Task` class to represent tasks consistently.

Instead of passing unrelated objects around like this:

```javascript
{
  id: 1,
  title: "Study JavaScript",
  completed: false
}
```

we will eventually create task instances with predictable behavior:

```javascript
const task = new Task({
  id: 1,
  title: "Study JavaScript",
  completed: false
});

task.complete();
task.isCompleted();
```

The object will contain both data and behavior.

---

## Part 4: Modular Architecture and Storage

The fourth part turns the application into a properly organized multi-file project.

You will learn:

- Why large scripts become difficult to maintain.
- Separation of concerns.
- ES module syntax.
- Named exports.
- Default exports.
- `import` statements.
- Module boundaries.
- Dependency direction.
- How browser modules are loaded.
- `localStorage`.
- `sessionStorage`.
- JSON serialization.
- JSON parsing.
- Safe handling of invalid stored data.
- Persistent and temporary browser data.

A module is like a department in a company.

For example:

- The storage department handles saved data.
- The UI department handles the page.
- The service department handles business rules.
- The API department handles remote or delayed data.

Each department has a clear job and communicates through defined interfaces.

This prevents one file from becoming responsible for everything.

---

# The Development Progression

We will not create the final architecture all at once.

The application will grow in stages.

## Stage 1: Synchronous Task Data

We will begin with simple JavaScript values and functions.

At this stage, the application may use an in-memory array:

```javascript
const tasks = [];
```

This means the data exists only while the page is open.

If the page is refreshed, the data disappears.

That limitation is intentional. We will first learn the language behavior before adding persistence.

## Stage 2: Asynchronous Task Loading

Next, we will simulate delayed data loading.

The application will need to handle:

- A task request that has not finished.
- A successful response.
- A failed response.
- User-visible loading states.

This will give us a practical reason to use callbacks, Promises, and `async`/`await`.

## Stage 3: Task Objects and Classes

Once asynchronous flow is understood, we will represent tasks using structured objects.

The application will gain:

- A `Task` class.
- Task methods.
- Validation.
- Completion behavior.
- Consistent object construction.

## Stage 4: Separate Modules

After the application has several responsibilities, we will divide it into modules.

Instead of one large file, we will create focused files that communicate using `import` and `export`.

## Stage 5: Browser Storage

Finally, we will persist tasks.

When the user reloads the page, tasks will be restored from browser storage.

We will also handle cases where:

- No data exists yet.
- Stored data is malformed.
- Stored data has an unexpected shape.
- Storage access fails.
- Old data does not match the current application format.

---

# Target Audience

This series is intended for developers who already understand basic JavaScript syntax, including:

- Variables.
- Primitive values.
- Arrays.
- Objects.
- Functions.
- Conditional statements.
- Loops.
- Basic DOM manipulation.
- Basic event handling.

You do not need to be an expert.

You should be comfortable reading code such as:

```javascript
const button = document.querySelector("#save-button");

button.addEventListener("click", () => {
  console.log("The button was clicked.");
});
```

You should also be willing to use the terminal and create files and directories.

---

# What This Series Does Not Assume

You do not need prior experience with:

- Node.js.
- TypeScript.
- React.
- Vue.
- Angular.
- Express.
- Databases.
- Build tools.
- Package managers.
- Backend development.

The application will run directly in a browser using native JavaScript modules.

Later, the same concepts will transfer naturally to larger JavaScript environments.

---

# Recommended Tools

You will need:

1. A modern browser:
   - Google Chrome
   - Mozilla Firefox
   - Microsoft Edge
   - Safari

2. A code editor:
   - Visual Studio Code is recommended.
   - Any editor that can create plain text files will work.

3. A terminal:
   - macOS Terminal
   - Windows PowerShell
   - Linux shell
   - The integrated terminal in Visual Studio Code

4. A local development server.

Browser ES modules are subject to security rules that can prevent them from working correctly when opened directly with a `file://` URL. We will use a local server when the project reaches the module stage.

---

# How to Read Each Technical Step

Every implementation step in the technical parts will follow the same structure.

## The Target

This identifies the exact file, feature, or configuration being created.

For example:

> Create `js/services/storage-service.js`.

## The Concept

This explains the underlying idea using a simple analogy before showing code.

For example:

> The storage service is a filing cabinet. Other parts of the application request files from it without needing to know how the cabinet is organized.

## The Implementation

This section contains the complete file contents.

Code will not be shortened with comments such as:

```javascript
// Add the remaining methods here
```

Every required line will be included.

## The Verification

This section explains how to prove that the step worked before continuing.

Verification may include:

- A terminal command.
- A browser action.
- A console command.
- A `curl` request.
- An expected output.
- An expected browser state.
- An expected error message.

This prevents problems from accumulating silently.

---

# Coding Standards Used Throughout the Series

The code will follow practical production-oriented habits.

## Explicit Names

We will prefer names that explain their purpose:

```javascript
const completedTasks = tasks.filter((task) => task.completed);
```

over vague names:

```javascript
const x = tasks.filter((item) => item.done);
```

## Small Responsibilities

Functions and modules will have focused responsibilities.

A function that saves data should not also render HTML, validate form fields, and display notifications.

## Defensive Input Handling

Data from users, APIs, and browser storage should be treated as untrusted.

We will validate:

- Empty strings.
- Incorrect types.
- Missing values.
- Unexpected object shapes.
- Invalid JSON.

## Predictable Error Handling

Errors should be:

- Detected.
- Described clearly.
- Handled at the appropriate layer.
- Communicated to the user when necessary.
- Logged for debugging when appropriate.

## No Hidden Global State

We will avoid placing application data into arbitrary global variables.

Modules will expose only the functions and values that other modules actually need.

## Clear Dependency Direction

The application will be structured so that:

- UI code can request operations from services.
- Services can use storage or API modules.
- Low-level modules do not directly manipulate unrelated UI elements.

This makes the code easier to test and replace.

---

# The End State

At the end of the series, the user will be able to:

1. Open the application in a browser.
2. Add a task.
3. See the task rendered in the page.
4. Mark the task as completed.
5. Filter the task list.
6. Delete a task.
7. Load initial tasks asynchronously.
8. See a loading state while data is being retrieved.
9. See an error state if loading fails.
10. Refresh the browser without losing saved tasks.
11. Inspect the application’s modules.
12. Explain how each module contributes to the whole system.

The final application will not merely demonstrate isolated syntax. It will show how JavaScript features cooperate in a real program.

---

# The Core Mental Model

The main lesson of this series is that a good JavaScript application has several layers:

```text
User interaction
       ↓
UI event handling
       ↓
Application coordination
       ↓
Business rules
       ↓
Asynchronous data or browser storage
```

For example, when a user adds a task:

```text
User submits the form
       ↓
The form module reads the input
       ↓
Validation confirms the title is valid
       ↓
The task service creates a Task object
       ↓
The storage service saves the task
       ↓
The UI renders the updated list
```

Each step has a clear purpose.

When something fails, the error can be located more easily because the application is not one tangled block of code.

---

# Expectations for the Hands-On Journey

This series will be code-heavy and incremental.

You should expect to:

- Create directories.
- Create files.
- Replace files with complete updated versions.
- Run commands.
- Open browser developer tools.
- Read console output.
- Intentionally trigger errors.
- Inspect stored browser data.
- Modify small pieces of code and observe the result.

Do not skip verification steps. A later part may depend on behavior introduced earlier.

If a command produces an unexpected result, stop at that point and fix it before continuing. Debugging is not a detour from software development; it is one of the main development skills this series is designed to build.

---

# Final Preview

The completed application will combine all four learning areas:

| Learning area | Where it appears in the application |
|---|---|
| Asynchronous execution | Loading task data and simulating delayed responses |
| Promises | Representing future API results |
| `async`/`await` | Reading asynchronous workflows clearly |
| Error handling | Displaying and recovering from failures |
| Prototypes and classes | Modeling tasks as reusable objects |
| Modules | Separating UI, services, storage, and API code |
| `localStorage` | Persisting tasks across page reloads |
| JSON | Converting task data to and from stored text |
| Separation of concerns | Keeping each part of the application focused |

The goal is not just to memorize syntax.

The goal is to understand how to design JavaScript code that remains readable when the application becomes larger than a single script.
