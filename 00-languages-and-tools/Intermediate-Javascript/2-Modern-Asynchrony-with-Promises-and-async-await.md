# Part 2: Modern Asynchrony — Promises and `async`/`await`

In Part 1, the application used callbacks to load example tasks asynchronously.

That worked, but callbacks become difficult to manage when several asynchronous operations depend on one another. In this part, we will replace the callback-based loader with a Promise-based design.

By the end of this part, the application will:

- Represent future asynchronous results with Promises.
- Handle successful results with `.then()`.
- Handle failures with `.catch()`.
- Run cleanup with `.finally()`.
- Use `async` functions.
- Use `await` to pause an asynchronous function without blocking the browser.
- Handle errors with `try`/`catch`/`finally`.
- Prevent outdated asynchronous responses from incorrectly replacing newer data.

---

# Part 2 Overview

We will complete the following steps:

1. Understand the three Promise states.
2. Create a basic Promise.
3. Convert the callback loader to return a Promise.
4. Consume the Promise with `.then()`, `.catch()`, and `.finally()`.
5. Convert the loader to an `async`/`await` workflow.
6. Add robust error handling.
7. Add request protection to prevent duplicate operations.
8. Test both successful and failed asynchronous flows.
9. Review Promise behavior and troubleshooting patterns.

---

# Step 1: Understand Promise States

## The Target

Before changing the application, understand what a Promise represents.

## The Concept

A **Promise** is an object representing the eventual result of an asynchronous operation.

Think of a Promise as a claim ticket for a package:

- You have the ticket immediately.
- The package is not ready yet.
- Later, the package either arrives or the delivery fails.
- The ticket does not change back and forth forever.

A Promise has exactly one of three states:

### Pending

The operation is still in progress.

```text
The package has not arrived yet.
```

### Fulfilled

The operation completed successfully.

```text
The package arrived.
```

### Rejected

The operation failed.

```text
The delivery could not be completed.
```

Once a Promise is fulfilled or rejected, it is **settled**. A settled Promise cannot change to another state.

## The Implementation

Create a temporary file named `promise-demo.html` in the project root.

### `promise-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Promise Demonstration</title>
  </head>
  <body>
    <h1>Open the browser console</h1>

    <script>
      const taskPromise = new Promise((resolve, reject) => {
        setTimeout(() => {
          const requestSucceeded = true;

          if (requestSucceeded) {
            resolve("The asynchronous task succeeded.");
            return;
          }

          reject(new Error("The asynchronous task failed."));
        }, 1000);
      });

      console.log("Promise immediately after creation:", taskPromise);

      taskPromise.then((result) => {
        console.log("Promise result:", result);
      });
    </script>
  </body>
</html>
```

## The Verification

Open `promise-demo.html` in the browser.

Immediately after loading, the console should show a Promise in a pending state or a Promise that is still being processed.

After approximately one second, the console should show:

```text
Promise result: The asynchronous task succeeded.
```

Now change:

```javascript
const requestSucceeded = true;
```

to:

```javascript
const requestSucceeded = false;
```

Refresh the page.

The Promise will be rejected, but the example does not yet handle that rejection. The browser console should report an unhandled Promise rejection.

We will handle that correctly in the next step.

Delete `promise-demo.html` after completing this experiment.

[COMPLETED: Step 1 — Promise states demonstrated]  
[STARTING: Step 2 — Create a Promise-based task loader]

---

# Step 2: Replace the Callback Loader with a Promise

## The Target

Replace the callback-based `loadExampleTasks` function with a function that returns a Promise.

The new function will no longer receive a callback argument.

Instead, it will return a Promise:

```javascript
const taskPromise = loadExampleTasks();
```

## The Concept

The callback version directly calls another function when work finishes:

```javascript
loadExampleTasks((error, tasks) => {
  // Use the result here.
});
```

The Promise version returns an object representing the future result:

```javascript
const taskPromise = loadExampleTasks();
```

The caller can decide how to respond:

```javascript
taskPromise
  .then((tasks) => {
    // Handle success.
  })
  .catch((error) => {
    // Handle failure.
  });
```

This separates two responsibilities:

- The loader performs the asynchronous work.
- The caller decides how to consume the result.

## The Implementation

Open `js/main.js`.

Remove the old callback-based function:

```javascript
function loadExampleTasks(shouldFail, callback) {
  setTimeout(() => {
    if (shouldFail) {
      const error = new Error(
        "The example task service could not load the tasks."
      );

      callback(error, undefined);
      return;
    }

    const exampleTasks = [
      {
        id: createTaskId(),
        title: "Read about the call stack",
        completed: false,
      },
      {
        id: createTaskId(),
        title: "Trace a timer through the event loop",
        completed: false,
      },
      {
        id: createTaskId(),
        title: "Explain why callbacks run later",
        completed: true,
      },
    ];

    callback(null, exampleTasks);
  }, 1500);
}
```

Replace it with this complete Promise-based version:

### `js/main.js`

```javascript
function loadExampleTasks(shouldFail = false) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (shouldFail) {
        reject(
          new Error("The example task service could not load the tasks.")
        );
        return;
      }

      const exampleTasks = [
        {
          id: createTaskId(),
          title: "Read about the call stack",
          completed: false,
        },
        {
          id: createTaskId(),
          title: "Trace a timer through the event loop",
          completed: false,
        },
        {
          id: createTaskId(),
          title: "Explain why callbacks run later",
          completed: true,
        },
      ];

      resolve(exampleTasks);
    }, 1500);
  });
}
```

The rest of `main.js` can remain unchanged for now.

## The Verification

Temporarily add this code at the bottom of `js/main.js`:

```javascript
loadExampleTasks()
  .then((loadedTasks) => {
    console.log("Promise succeeded:", loadedTasks);
  })
  .catch((error) => {
    console.error("Promise failed:", error);
  });
```

Refresh the application.

After approximately 1.5 seconds, the console should show an array containing three tasks.

Now test rejection by changing the temporary call to:

```javascript
loadExampleTasks(true)
  .then((loadedTasks) => {
    console.log("Unexpected success:", loadedTasks);
  })
  .catch((error) => {
    console.error("Promise failed as expected:", error.message);
  });
```

After approximately 1.5 seconds, the console should show:

```text
Promise failed as expected: The example task service could not load the tasks.
```

Remove the temporary test call before continuing.

[COMPLETED: Step 2 — Promise-based loader created]  
[STARTING: Step 3 — Add `.then()`, `.catch()`, and `.finally()`]

---

# Step 3: Consume the Promise with Promise Methods

## The Target

Update the task-loading workflow to use:

- `.then()` for success.
- `.catch()` for failure.
- `.finally()` for cleanup.

## The Concept

Promise methods form a workflow.

```javascript
loadExampleTasks()
  .then(handleSuccess)
  .catch(handleFailure)
  .finally(cleanUp);
```

You can think of this as a three-lane process:

1. The success lane receives the resolved value.
2. The failure lane receives the rejected error.
3. The cleanup lane runs regardless of success or failure.

### `.then()`

Runs when the Promise is fulfilled.

```javascript
promise.then((result) => {
  console.log(result);
});
```

### `.catch()`

Runs when the Promise is rejected.

```javascript
promise.catch((error) => {
  console.error(error);
});
```

### `.finally()`

Runs after the Promise settles, regardless of its outcome.

```javascript
promise.finally(() => {
  console.log("Operation finished.");
});
```

This is useful for cleanup such as:

- Re-enabling buttons.
- Hiding loading indicators.
- Closing a dialog.
- Stopping a spinner.

## The Implementation

Replace the existing `loadTasksIntoApplication` function with this version:

### `js/main.js`

```javascript
function loadTasksIntoApplication() {
  loadTasksButton.disabled = true;
  updateStatus("Loading example tasks...", "loading");

  const shouldFail = false;

  loadExampleTasks(shouldFail)
    .then((loadedTasks) => {
      tasks = loadedTasks;
      renderTasks();

      updateStatus(
        `Loaded ${loadedTasks.length} example tasks successfully.`,
        "success"
      );
    })
    .catch((error) => {
      console.error("Could not load example tasks:", error);

      updateStatus(
        `Could not load example tasks: ${error.message}`,
        "error"
      );
    })
    .finally(() => {
      /*
       * finally() executes for both success and failure.
       * This prevents duplicated cleanup code.
       */
      loadTasksButton.disabled = false;
    });
}
```

## The Verification

Refresh the page and click **Load example tasks**.

Immediately verify:

- The button becomes disabled.
- The status changes to the loading message.
- The task list remains usable.

After approximately 1.5 seconds, verify:

- Three tasks appear.
- The success message appears.
- The button becomes enabled.

Now change:

```javascript
const shouldFail = false;
```

to:

```javascript
const shouldFail = true;
```

Refresh the page and click **Load example tasks**.

Verify:

- The error message appears.
- The button becomes enabled.
- The browser console logs the error.
- No unhandled Promise rejection appears.

Restore:

```javascript
const shouldFail = false;
```

[COMPLETED: Step 3 — Promise success, failure, and cleanup handling added]  
[STARTING: Step 4 — Convert the workflow to `async`/`await`]

---

# Step 4: Use `async` and `await`

## The Target

Rewrite the task-loading workflow with `async`/`await`.

## The Concept

`async`/`await` is a cleaner way to write Promise-based code.

An `async` function always returns a Promise:

```javascript
async function getValue() {
  return 42;
}
```

Even though the function returns `42`, JavaScript automatically wraps that value in a fulfilled Promise.

`await` can be used inside an `async` function:

```javascript
const result = await somePromise;
```

This means:

> Wait for this Promise’s result before continuing this async function.

It does **not** block the browser’s main thread.

The difference is similar to waiting in a restaurant:

- A blocking function makes the entire restaurant stop working.
- `await` pauses only the current order-processing workflow.
- Other browser work can continue while the Promise is pending.

## The Implementation

Replace `loadTasksIntoApplication` with this version:

### `js/main.js`

```javascript
async function loadTasksIntoApplication() {
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
    console.error("Could not load example tasks:", error);

    updateStatus(
      `Could not load example tasks: ${error.message}`,
      "error"
    );
  } finally {
    /*
     * This runs after either the try block succeeds
     * or the catch block handles an error.
     */
    loadTasksButton.disabled = false;
  }
}
```

The event listener does not need to change:

```javascript
loadTasksButton.addEventListener("click", () => {
  loadTasksIntoApplication();
});
```

## The Verification

Refresh the page.

Click **Load example tasks**.

Confirm that the behavior is unchanged:

- The button disables.
- The loading state appears.
- The Promise resolves after the delay.
- Three tasks are rendered.
- The success message appears.
- The button is re-enabled.

Now change:

```javascript
const shouldFail = false;
```

to:

```javascript
const shouldFail = true;
```

Refresh and test again.

Confirm that:

- `await` produces an error when the Promise rejects.
- The `catch` block handles that error.
- The `finally` block re-enables the button.

Restore the value to:

```javascript
const shouldFail = false;
```

[COMPLETED: Step 4 — `async`/`await` workflow implemented]  
[STARTING: Step 5 — Add explicit input validation and error normalization]

---

# Step 5: Make Error Handling More Robust

## The Target

Improve error handling so the application can safely handle rejected values that are not ordinary `Error` objects.

## The Concept

JavaScript allows code to reject a Promise with almost any value:

```javascript
reject("Something failed");
```

It is also possible to write:

```javascript
throw "Something failed";
```

Although these patterns are legal, they are poor practice because strings do not contain useful error metadata such as:

- A stack trace.
- A standard name.
- A consistent message property.

Production code should reject and throw actual `Error` objects.

However, application boundaries may still receive unexpected values from third-party code. An error-normalizing helper converts unknown failures into predictable `Error` objects.

## The Implementation

Add this function near the top of `js/main.js`, after the DOM references:

### `js/main.js`

```javascript
function normalizeError(value) {
  if (value instanceof Error) {
    return value;
  }

  if (typeof value === "string" && value.trim().length > 0) {
    return new Error(value);
  }

  return new Error("An unknown asynchronous error occurred.");
}
```

Now replace the `catch` block inside `loadTasksIntoApplication`:

```javascript
  } catch (error) {
    console.error("Could not load example tasks:", error);

    updateStatus(
      `Could not load example tasks: ${error.message}`,
      "error"
    );
```

with:

```javascript
  } catch (error) {
    const normalizedError = normalizeError(error);

    console.error("Could not load example tasks:", normalizedError);

    updateStatus(
      `Could not load example tasks: ${normalizedError.message}`,
      "error"
    );
```

## The Verification

The normal success path should still work.

To test normalization, temporarily add this function:

```javascript
async function testErrorNormalization() {
  try {
    throw "A string was thrown unexpectedly.";
  } catch (error) {
    const normalizedError = normalizeError(error);
    console.log(normalizedError instanceof Error);
    console.log(normalizedError.message);
  }
}
```

Then temporarily call it:

```javascript
testErrorNormalization();
```

Refresh the page.

The console should show:

```text
true
A string was thrown unexpectedly.
```

Remove the test function and its call before continuing.

[COMPLETED: Step 5 — Error normalization added]  
[STARTING: Step 6 — Prevent duplicate asynchronous requests]

---

# Step 6: Protect Against Duplicate Requests

## The Target

Prevent the user from starting another load while the current load is still active.

## The Concept

Disabling the button is useful, but user interfaces should not rely on appearance alone.

For example:

- Another script could call the function.
- A future UI change could forget to disable the button.
- A keyboard interaction could trigger an unexpected event.
- A double-click could occur before the disabled state is painted.

A second protection is an application-level guard.

We will track whether a load is already active:

```javascript
let isLoadingTasks = false;
```

This is a small state variable. It acts like a locked door: even if someone reaches the function, the function refuses to start another operation while the first is active.

## The Implementation

Add this variable below the `tasks` declaration:

### `js/main.js`

```javascript
let isLoadingTasks = false;
```

Replace `loadTasksIntoApplication` with this version:

```javascript
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
```

## The Verification

Refresh the browser.

Click **Load example tasks** repeatedly while the request is pending.

You should observe:

- Only one request is started.
- The button remains disabled during the request.
- The task list is updated once.
- The button is restored after completion.

To verify the guard directly, temporarily replace the button event listener with:

```javascript
loadTasksButton.addEventListener("click", () => {
  loadTasksIntoApplication();
  loadTasksIntoApplication();
});
```

Click the button.

Only one load should complete.

Restore the normal listener:

```javascript
loadTasksButton.addEventListener("click", () => {
  loadTasksIntoApplication();
});
```

[COMPLETED: Step 6 — Duplicate asynchronous operations prevented]  
[STARTING: Step 7 — Finalizing the complete Part 2 implementation]

---

# Step 7: Complete `main.js`

## The Target

Replace `js/main.js` with the complete Part 2 implementation.

This file includes:

- In-memory task state.
- DOM rendering.
- Task creation.
- Completion toggling.
- Promise-based loading.
- `async`/`await`.
- Error normalization.
- Loading protection.
- Success, error, and cleanup states.

## The Implementation

### `js/main.js`

```javascript
"use strict";

const taskForm = document.querySelector("#task-form");
const taskTitleInput = document.querySelector("#task-title");
const taskList = document.querySelector("#task-list");
const taskCount = document.querySelector("#task-count");
const statusMessage = document.querySelector("#status-message");
const loadTasksButton = document.querySelector("#load-tasks-button");

let tasks = [
  {
    id: 1,
    title: "Understand synchronous JavaScript",
    completed: false,
  },
  {
    id: 2,
    title: "Practice reading the event loop",
    completed: false,
  },
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
  const completedTotal = tasks.filter((task) => task.completed).length;

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

    if (task.completed) {
      listItem.classList.add("task-completed");
    }

    const textContainer = document.createElement("div");

    const title = document.createElement("p");
    title.className = "task-title";
    title.textContent = task.title;

    const metadata = document.createElement("p");
    metadata.className = "task-meta";
    metadata.textContent = task.completed ? "Completed" : "Not completed";

    textContainer.append(title, metadata);

    const completionButton = document.createElement("button");
    completionButton.className = "task-action";
    completionButton.type = "button";
    completionButton.dataset.taskId = String(task.id);
    completionButton.textContent = task.completed
      ? "Mark as incomplete"
      : "Mark as complete";

    completionButton.addEventListener("click", () => {
      toggleTaskCompletion(task.id);
    });

    listItem.append(textContainer, completionButton);
    taskList.append(listItem);
  });

  updateTaskCount();
}

function addTask(title) {
  const normalizedTitle = title.trim();

  if (normalizedTitle.length === 0) {
    updateStatus("Enter a task title before adding a task.", "error");
    return;
  }

  const newTask = {
    id: createTaskId(),
    title: normalizedTitle,
    completed: false,
  };

  tasks.push(newTask);
  renderTasks();
  updateStatus(`Added task: ${normalizedTitle}`, "success");
}

function toggleTaskCompletion(taskId) {
  tasks = tasks.map((task) => {
    if (task.id !== taskId) {
      return task;
    }

    return {
      ...task,
      completed: !task.completed,
    };
  });

  renderTasks();
  updateStatus("Task status updated.", "success");
}

/*
 * This function returns a Promise.
 *
 * It resolves with an array of tasks on success.
 * It rejects with an Error object on failure.
 */
function loadExampleTasks(shouldFail = false) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (shouldFail) {
        reject(
          new Error("The example task service could not load the tasks.")
        );
        return;
      }

      const exampleTasks = [
        {
          id: createTaskId(),
          title: "Read about the call stack",
          completed: false,
        },
        {
          id: createTaskId(),
          title: "Trace a timer through the event loop",
          completed: false,
        },
        {
          id: createTaskId(),
          title: "Explain why callbacks run later",
          completed: true,
        },
      ];

      resolve(exampleTasks);
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

Run the complete application test.

### Initial state

Refresh the page.

Verify that the original two tasks appear.

### Add a task

Enter:

```text
Use async and await
```

Click **Add task**.

Verify that the task appears.

### Complete a task

Click **Mark as complete**.

Verify that its state changes.

### Successful Promise

Click **Load example tasks**.

Verify:

- The loading status appears.
- The page remains responsive.
- Three tasks eventually appear.
- The button is restored.

### Failed Promise

Change:

```javascript
const shouldFail = false;
```

to:

```javascript
const shouldFail = true;
```

Refresh and click the loading button.

Verify:

- The error is displayed.
- The button is re-enabled.
- No unhandled rejection appears.

Restore:

```javascript
const shouldFail = false;
```

[COMPLETED: Step 7 — Complete Promise-based application implemented]  
[STARTING: Part 2 Reference — Promise and `async`/`await` concepts]

---

# Part 2 Reference: Promises in Detail

## Creating a Promise

A Promise constructor receives an executor function:

```javascript
const promise = new Promise((resolve, reject) => {
  // Start asynchronous work here.

  if (success) {
    resolve(result);
    return;
  }

  reject(error);
});
```

The executor runs immediately when the Promise is created.

The asynchronous operation inside it may complete later.

### Important distinction

This code starts the work immediately:

```javascript
const promise = loadExampleTasks();
```

This code does not start the work until the function is called:

```javascript
function createPromise() {
  return loadExampleTasks();
}
```

Promises are not automatically lazy. The function that creates a Promise determines when the work begins.

---

## `resolve()` and `reject()`

Calling `resolve` fulfills the Promise:

```javascript
resolve(["Task A", "Task B"]);
```

Calling `reject` rejects the Promise:

```javascript
reject(new Error("Loading failed."));
```

After one of these functions settles the Promise, later calls do not change its state:

```javascript
const promise = new Promise((resolve, reject) => {
  resolve("First result");
  reject(new Error("This is ignored."));
});
```

The Promise remains fulfilled with `"First result"`.

A Promise settles only once.

---

## Promise Chaining

Each `.then()` returns a new Promise:

```javascript
loadExampleTasks()
  .then((tasks) => {
    return tasks.length;
  })
  .then((taskCount) => {
    console.log(`There are ${taskCount} tasks.`);
  });
```

The value returned from one `.then()` becomes the input to the next `.then()`.

This is why the following works:

```javascript
Promise.resolve(5)
  .then((number) => {
    return number * 2;
  })
  .then((number) => {
    console.log(number);
  });
```

Output:

```text
10
```

---

## Returning a Promise from `.then()`

A `.then()` callback can return another Promise:

```javascript
getUser()
  .then((user) => {
    return getProjects(user.id);
  })
  .then((projects) => {
    console.log(projects);
  });
```

The next `.then()` waits for the returned Promise.

This avoids nesting:

```javascript
getUser().then((user) => {
  getProjects(user.id).then((projects) => {
    console.log(projects);
  });
});
```

The chained version is easier to read and extend.

---

## Errors in Promise Chains

An error thrown inside a `.then()` callback causes the returned Promise to reject:

```javascript
Promise.resolve("value")
  .then(() => {
    throw new Error("Something went wrong.");
  })
  .catch((error) => {
    console.error(error.message);
  });
```

The `.catch()` handles both:

- Explicit Promise rejection.
- Errors thrown in earlier `.then()` callbacks.

---

## Error Recovery

A `.catch()` can return a fallback value:

```javascript
loadExampleTasks()
  .catch((error) => {
    console.error(error);
    return [];
  })
  .then((tasks) => {
    console.log("Tasks:", tasks);
  });
```

If loading fails, the application continues with an empty array.

Whether this is appropriate depends on the feature. For a task manager, silently replacing server data with an empty list may be dangerous. Showing an error is often safer.

---

## `.finally()`

The callback passed to `.finally()` does not receive the Promise’s result:

```javascript
promise.finally(() => {
  console.log("Finished.");
});
```

Use `.then()` for successful results, `.catch()` for failures, and `.finally()` for common cleanup.

A common pattern is:

```javascript
button.disabled = true;

performOperation()
  .then(handleSuccess)
  .catch(handleError)
  .finally(() => {
    button.disabled = false;
  });
```

---

# `async` Functions

An `async` function always returns a Promise.

```javascript
async function getNumber() {
  return 42;
}

getNumber().then((number) => {
  console.log(number);
});
```

The returned value is automatically wrapped:

```javascript
Promise.resolve(42);
```

An `async` function that throws creates a rejected Promise:

```javascript
async function fail() {
  throw new Error("Failure.");
}

fail().catch((error) => {
  console.error(error.message);
});
```

---

# `await`

`await` extracts the fulfilled value from a Promise:

```javascript
async function showTasks() {
  const tasks = await loadExampleTasks();
  console.log(tasks);
}
```

If the Promise rejects, `await` throws an error:

```javascript
async function showTasks() {
  try {
    const tasks = await loadExampleTasks();
    console.log(tasks);
  } catch (error) {
    console.error(error);
  }
}
```

`await` pauses only the current `async` function. It does not block the browser’s event loop.

---

# Sequential Versus Parallel Work

Consider two independent asynchronous operations:

```javascript
const firstResult = await getFirstValue();
const secondResult = await getSecondValue();
```

This runs sequentially:

```text
Start first
Wait for first
Start second
Wait for second
```

If the operations are independent, they can often run in parallel:

```javascript
const [firstResult, secondResult] = await Promise.all([
  getFirstValue(),
  getSecondValue(),
]);
```

This starts both operations before waiting for the results.

A simplified timing comparison:

```text
Sequential:
Operation A: |---------|
Operation B:            |---------|
Total:                  2 durations

Parallel:
Operation A: |---------|
Operation B: |---------|
Total:       1 duration
```

Use `Promise.all()` when:

- All operations are required.
- Failure of one should fail the combined operation.
- The operations do not depend on one another.

---

# Promise Combinators

## `Promise.all()`

Fulfills when every Promise fulfills.

```javascript
const results = await Promise.all([
  getTasks(),
  getUsers(),
]);
```

Rejects immediately when one Promise rejects.

## `Promise.allSettled()`

Waits for every Promise, regardless of success or failure.

```javascript
const results = await Promise.allSettled([
  getTasks(),
  getUsers(),
]);
```

Each result describes its own state:

```javascript
[
  {
    status: "fulfilled",
    value: [...]
  },
  {
    status: "rejected",
    reason: Error
  }
]
```

## `Promise.race()`

Settles when the first Promise settles:

```javascript
const result = await Promise.race([
  requestData(),
  timeoutAfterFiveSeconds(),
]);
```

This is useful for timeout patterns, although the unfinished operation may continue unless separately cancelled.

## `Promise.any()`

Fulfills when the first Promise fulfills.

It ignores rejected Promises until every option rejects.

---

# Common Mistakes

## Forgetting to Return a Promise

Incorrect:

```javascript
function loadData() {
  fetch("/data");
}
```

The function returns `undefined`, so callers cannot await it.

Correct:

```javascript
function loadData() {
  return fetch("/data");
}
```

Or:

```javascript
async function loadData() {
  return fetch("/data");
}
```

## Forgetting `await`

Incorrect:

```javascript
async function showData() {
  const data = loadData();
  console.log(data);
}
```

`data` is a Promise, not the final result.

Correct:

```javascript
async function showData() {
  const data = await loadData();
  console.log(data);
}
```

## Forgetting Error Handling

Incorrect:

```javascript
async function loadData() {
  const data = await requestData();
  render(data);
}
```

If the request rejects, the function returns a rejected Promise that may be unhandled.

Correct:

```javascript
async function loadData() {
  try {
    const data = await requestData();
    render(data);
  } catch (error) {
    showError(error);
  }
}
```

## Using `await` in a Non-Async Function

Incorrect:

```javascript
function loadData() {
  const result = await requestData();
}
```

Correct:

```javascript
async function loadData() {
  const result = await requestData();
}
```

## Treating `setTimeout` as an Exact Delay

This does not guarantee execution exactly after one second:

```javascript
setTimeout(callback, 1000);
```

It guarantees only that the callback will not be eligible before approximately one second has passed.

The callback may run later if:

- The call stack is busy.
- The browser is under load.
- The tab is throttled.
- The operating system pauses the process.

---

# Part 2 Troubleshooting

## The Error Message Says `error.message` Is Undefined

Use the `normalizeError` helper:

```javascript
const normalizedError = normalizeError(error);
```

Then use:

```javascript
normalizedError.message
```

Do not assume every thrown value is an `Error`.

## The Loading Button Stays Disabled

Ensure the button reset occurs inside `finally`:

```javascript
finally {
  isLoadingTasks = false;
  loadTasksButton.disabled = false;
}
```

If it appears only in the success path, failures will leave the interface locked.

## The Success Handler Runs After a Failure

Check that the rejection handler returns or that the Promise chain is structured correctly.

With `async`/`await`, verify that the success code is inside `try` and failure code is inside `catch`.

## The Page Is Frozen During `await`

`await` itself does not freeze the browser.

Look for synchronous blocking code such as:

```javascript
while (condition) {
  // Long-running work.
}
```

or a large computation performed before the Promise is created.

## A Promise Rejection Appears in the Console

Make sure every started Promise has a consumer:

```javascript
someOperation().catch((error) => {
  console.error(error);
});
```

or:

```javascript
try {
  await someOperation();
} catch (error) {
  console.error(error);
}
```

---

# Part 2 Completion Checklist

You have completed Part 2 when you can explain and demonstrate all of the following:

- A Promise represents a future result.
- A Promise begins as pending.
- A Promise settles as fulfilled or rejected.
- A settled Promise cannot change state.
- `.then()` handles fulfillment.
- `.catch()` handles rejection.
- `.finally()` handles shared cleanup.
- Promise chains pass returned values to later handlers.
- Errors thrown inside a Promise chain can be handled by `.catch()`.
- An `async` function returns a Promise.
- `await` pauses the current asynchronous function without blocking the browser.
- `try` handles successful asynchronous work.
- `catch` handles rejected Promises and thrown errors.
- `finally` performs cleanup regardless of outcome.
- Duplicate asynchronous operations can be prevented with state guards.
- Errors should be represented with predictable `Error` objects.
