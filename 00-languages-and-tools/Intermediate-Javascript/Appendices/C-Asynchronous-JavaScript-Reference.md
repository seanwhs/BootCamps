# Appendix C: Asynchronous JavaScript Reference

This appendix is a practical reference for asynchronous JavaScript.

It explains how to:

- Understand the event loop.
- Use callbacks.
- Create and consume Promises.
- Use `async`/`await`.
- Handle errors.
- Run operations sequentially or concurrently.
- Add timeouts.
- Cancel requests.
- Avoid common asynchronous bugs.
- Test asynchronous behavior.

---

# 1. Synchronous Versus Asynchronous Code

## Synchronous Code

Synchronous code runs one statement at a time.

```javascript
console.log("First");

console.log("Second");

console.log("Third");
```

Output:

```text
First
Second
Third
```

Each statement must finish before the next one begins.

## Asynchronous Code

Asynchronous code allows JavaScript to start an operation and continue doing other work while waiting for the result.

```javascript
console.log("First");

setTimeout(() => {
  console.log("Delayed");
}, 1000);

console.log("Second");
```

Output:

```text
First
Second
Delayed
```

The timer callback runs later, even though it appears between the two other statements in the source code.

---

# 2. Blocking and Non-Blocking Work

## Blocking Code

This function blocks JavaScript for the specified duration:

```javascript
function blockForMilliseconds(duration) {
  const start = Date.now();

  while (Date.now() - start < duration) {
    // Deliberately blocks the JavaScript thread.
  }
}

console.log("Before blocking");

blockForMilliseconds(3000);

console.log("After blocking");
```

During the three-second loop, the browser cannot normally process other JavaScript work.

The page may fail to respond to:

- Clicks.
- Keyboard input.
- Screen updates.
- Other event handlers.

## Non-Blocking Delay

Use a timer instead:

```javascript
function wait(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

async function demonstrateNonBlockingDelay() {
  console.log("Before delay");

  await wait(3000);

  console.log("After delay");
}
```

The `await` pauses only `demonstrateNonBlockingDelay`. It does not freeze the browser.

---

# 3. The Call Stack

The **call stack** tracks the functions currently executing.

```javascript
function first() {
  second();
}

function second() {
  console.log("Inside second");
}

first();
```

A simplified execution sequence is:

```text
Call first()
  └── Call second()
        └── Call console.log()
        └── Return from console.log()
  └── Return from second()
Return from first()
```

The last function called is the first function to return. This is why it is called a stack.

---

# 4. The Event Loop

The browser typically coordinates asynchronous work using:

- The call stack.
- Browser Web APIs.
- Task queues.
- Microtask queues.
- The event loop.

A simplified model:

```text
JavaScript starts
      ↓
Synchronous code enters the call stack
      ↓
Browser APIs handle timers, events, and network activity
      ↓
Completed callbacks enter a queue
      ↓
The event loop waits for the stack to become empty
      ↓
A queued callback enters the stack
      ↓
The callback runs
```

Example:

```javascript
console.log("A");

setTimeout(() => {
  console.log("B");
}, 0);

console.log("C");
```

Output:

```text
A
C
B
```

The timer callback cannot interrupt the current script.

---

# 5. Microtasks and Tasks

JavaScript uses different queues for different categories of asynchronous work.

Promise handlers generally use the **microtask queue**.

Timers and many browser events generally use the **task queue**, sometimes called the macrotask queue.

Consider:

```javascript
console.log("A");

setTimeout(() => {
  console.log("Timer");
}, 0);

Promise.resolve().then(() => {
  console.log("Promise");
});

console.log("B");
```

Typical output:

```text
A
B
Promise
Timer
```

The sequence is:

1. Run current synchronous code.
2. Empty the microtask queue.
3. Process a task such as the timer callback.

This is a simplified model, but it explains why Promise handlers often run before timer callbacks that were scheduled at approximately the same time.

---

# 6. Callback Functions

A callback is a function passed to another function.

```javascript
function executeLater(callback) {
  setTimeout(() => {
    callback("The operation finished.");
  }, 1000);
}

executeLater((message) => {
  console.log(message);
});
```

The callback is not executed when passed to `executeLater`. It is executed later by `executeLater`.

---

# 7. Error-First Callbacks

A common callback convention is:

```javascript
callback(error, result);
```

Success:

```javascript
callback(null, result);
```

Failure:

```javascript
callback(error, undefined);
```

Example:

```javascript
function loadTask(callback) {
  setTimeout(() => {
    const task = {
      id: 1,
      title: "Learn callbacks",
    };

    callback(null, task);
  }, 500);
}

loadTask((error, task) => {
  if (error) {
    console.error(error);
    return;
  }

  console.log(task);
});
```

The error check should happen before using the result.

---

# 8. Callback Failure Handling

```javascript
function loadTask(shouldFail, callback) {
  setTimeout(() => {
    if (shouldFail) {
      callback(
        new Error("The task could not be loaded."),
        undefined
      );
      return;
    }

    callback(null, {
      id: 1,
      title: "Learn error handling",
    });
  }, 500);
}

loadTask(true, (error, task) => {
  if (error) {
    console.error("Expected failure:", error.message);
    return;
  }

  console.log("Unexpected task:", task);
});
```

The `return` prevents the success path from executing after an error.

---

# 9. Callback Nesting

Suppose three operations depend on one another:

```javascript
loadUser((userError, user) => {
  if (userError) {
    handleError(userError);
    return;
  }

  loadProjects(user.id, (projectError, projects) => {
    if (projectError) {
      handleError(projectError);
      return;
    }

    loadTasks(projects[0].id, (taskError, tasks) => {
      if (taskError) {
        handleError(taskError);
        return;
      }

      renderTasks(tasks);
    });
  });
});
```

This is valid, but nesting increases as the workflow grows.

Problems include:

- Repeated error handling.
- Deep indentation.
- Difficult control flow.
- Harder refactoring.
- More opportunities to forget a `return`.

Promises flatten this structure.

---

# 10. Creating Promises

A Promise constructor receives an executor function:

```javascript
const promise = new Promise((resolve, reject) => {
  // Start asynchronous work.

  if (operationSucceeded) {
    resolve(result);
  } else {
    reject(new Error("Operation failed."));
  }
});
```

Complete example:

```javascript
function loadTask() {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      const shouldFail = false;

      if (shouldFail) {
        reject(new Error("Task loading failed."));
        return;
      }

      resolve({
        id: 1,
        title: "Learn Promises",
      });
    }, 500);
  });
}
```

The executor runs immediately when `loadTask()` is called.

---

# 11. Promise States

A Promise has three states:

```text
Pending
   ↓
Fulfilled
```

or:

```text
Pending
   ↓
Rejected
```

It cannot move from fulfilled back to pending or from rejected to fulfilled.

```javascript
const promise = new Promise((resolve, reject) => {
  resolve("First result");
  reject(new Error("Ignored failure"));
});
```

The Promise remains fulfilled with `"First result"`.

---

# 12. Consuming Promises with `.then()`

```javascript
loadTask().then((task) => {
  console.log("Loaded task:", task);
});
```

The callback passed to `.then()` receives the fulfilled value.

---

# 13. Handling Rejections with `.catch()`

```javascript
loadTask()
  .then((task) => {
    console.log("Loaded task:", task);
  })
  .catch((error) => {
    console.error("Could not load task:", error.message);
  });
```

A `.catch()` can handle:

- An explicit Promise rejection.
- An error thrown in an earlier `.then()` handler.

```javascript
loadTask()
  .then((task) => {
    throw new Error("Rendering failed.");
  })
  .catch((error) => {
    console.error(error.message);
  });
```

---

# 14. Cleanup with `.finally()`

Use `.finally()` for work that must happen regardless of the result.

```javascript
const button = document.querySelector("#load-button");

button.disabled = true;

loadTask()
  .then((task) => {
    console.log(task);
  })
  .catch((error) => {
    console.error(error);
  })
  .finally(() => {
    button.disabled = false;
  });
```

This avoids duplicating cleanup:

```javascript
loadTask()
  .then((task) => {
    button.disabled = false;
    render(task);
  })
  .catch((error) => {
    button.disabled = false;
    showError(error);
  });
```

The `.finally()` version is easier to maintain.

---

# 15. Promise Chaining

Each `.then()` returns a new Promise.

```javascript
Promise.resolve(5)
  .then((number) => {
    return number * 2;
  })
  .then((number) => {
    return number + 1;
  })
  .then((result) => {
    console.log(result);
  });
```

Output:

```text
11
```

The returned value from one handler becomes the input to the next handler.

---

# 16. Returning Promises in a Chain

```javascript
function loadUser() {
  return Promise.resolve({
    id: 10,
    name: "Ada",
  });
}

function loadProjects(userId) {
  return Promise.resolve([
    {
      id: 20,
      name: "Task Manager",
      userId,
    },
  ]);
}

loadUser()
  .then((user) => {
    return loadProjects(user.id);
  })
  .then((projects) => {
    console.log(projects);
  })
  .catch((error) => {
    console.error(error);
  });
```

Returning `loadProjects(...)` tells the chain to wait for that Promise.

---

# 17. Forgetting to Return

This is incorrect:

```javascript
loadUser()
  .then((user) => {
    loadProjects(user.id);
  })
  .then((projects) => {
    console.log(projects);
  });
```

The first `.then()` returns `undefined`, so the next handler receives `undefined`.

Correct:

```javascript
loadUser()
  .then((user) => {
    return loadProjects(user.id);
  })
  .then((projects) => {
    console.log(projects);
  });
```

Or use an implicit return:

```javascript
loadUser()
  .then((user) => loadProjects(user.id))
  .then((projects) => {
    console.log(projects);
  });
```

---

# 18. `async` Functions

An `async` function always returns a Promise.

```javascript
async function getMessage() {
  return "Hello";
}
```

Even though the function returns a string internally, the caller receives a Promise:

```javascript
getMessage().then((message) => {
  console.log(message);
});
```

An `async` function is equivalent to returning a fulfilled Promise for ordinary returned values:

```javascript
function getMessage() {
  return Promise.resolve("Hello");
}
```

---

# 19. `await`

`await` waits for a Promise’s result inside an `async` function.

```javascript
async function loadAndRenderTask() {
  const task = await loadTask();

  renderTask(task);
}
```

The function pauses at `await`, but the browser can continue processing other work.

---

# 20. Handling `await` Errors

If the awaited Promise rejects, `await` throws.

```javascript
async function loadAndRenderTask() {
  try {
    const task = await loadTask();

    renderTask(task);
  } catch (error) {
    showError(error);
  }
}
```

A `try`/`catch` block is the standard way to handle awaited failures.

---

# 21. `try`, `catch`, and `finally`

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

Use:

- `try` for the operation.
- `catch` for failure.
- `finally` for cleanup.

---

# 22. Sequential Asynchronous Operations

Use sequential execution when the second operation depends on the first.

```javascript
async function loadUserTasks(userId) {
  const user = await loadUser(userId);
  const projects = await loadProjects(user.id);
  const tasks = await loadTasks(projects[0].id);

  return tasks;
}
```

The order is:

```text
load user
   ↓
load projects
   ↓
load tasks
```

---

# 23. Parallel Asynchronous Operations

Use `Promise.all()` when operations are independent.

```javascript
async function loadDashboard() {
  const [tasks, notifications] = await Promise.all([
    loadTasks(),
    loadNotifications(),
  ]);

  return {
    tasks,
    notifications,
  };
}
```

Both operations begin before the function waits for the combined result.

---

# 24. `Promise.all()`

`Promise.all()` fulfills only if every input Promise fulfills.

```javascript
const results = await Promise.all([
  Promise.resolve("First"),
  Promise.resolve("Second"),
]);

console.log(results);
// ["First", "Second"]
```

If one rejects, the combined Promise rejects:

```javascript
try {
  await Promise.all([
    Promise.resolve("Success"),
    Promise.reject(new Error("Failure")),
  ]);
} catch (error) {
  console.error(error.message);
}
```

Use `Promise.all()` when all results are required.

---

# 25. `Promise.allSettled()`

`Promise.allSettled()` waits for every Promise, whether it succeeds or fails.

```javascript
const results = await Promise.allSettled([
  Promise.resolve("Loaded tasks"),
  Promise.reject(new Error("Notifications failed")),
]);

console.log(results);
```

The result has this general shape:

```javascript
[
  {
    status: "fulfilled",
    value: "Loaded tasks"
  },
  {
    status: "rejected",
    reason: Error
  }
]
```

Use it when one failure should not prevent the application from examining other results.

---

# 26. `Promise.race()`

`Promise.race()` settles when the first input Promise settles.

```javascript
const result = await Promise.race([
  wait(1000).then(() => "Slow operation finished"),
  wait(100).then(() => "Fast operation finished"),
]);

console.log(result);
// "Fast operation finished"
```

The other operation may continue running. `Promise.race()` does not automatically cancel unfinished operations.

---

# 27. `Promise.any()`

`Promise.any()` fulfills when the first input Promise fulfills.

```javascript
const result = await Promise.any([
  Promise.reject(new Error("Server A failed")),
  Promise.resolve("Server B succeeded"),
]);

console.log(result);
// "Server B succeeded"
```

If every Promise rejects, `Promise.any()` rejects with an `AggregateError`.

---

# 28. Adding a Timeout

A timeout prevents an operation from waiting indefinitely.

```javascript
function timeout(milliseconds) {
  return new Promise((_, reject) => {
    setTimeout(() => {
      reject(
        new Error(
          `Operation exceeded ${milliseconds} milliseconds.`
        )
      );
    }, milliseconds);
  });
}
```

Use it with `Promise.race()`:

```javascript
async function loadWithTimeout() {
  return Promise.race([
    fetchTasks(),
    timeout(5000),
  ]);
}
```

A complete example:

```javascript
async function loadTasksSafely() {
  try {
    const tasks = await Promise.race([
      fetchTasks(),
      timeout(5000),
    ]);

    return tasks;
  } catch (error) {
    console.error("Task loading failed:", error);
    throw error;
  }
}
```

This detects a timeout but does not necessarily cancel the underlying request. Use `AbortController` for cancellation.

---

# 29. Cancelling Fetch Requests

The Fetch API supports cancellation through `AbortController`.

```javascript
async function fetchTasksWithCancellation(signal) {
  const response = await fetch("/api/tasks", {
    signal,
  });

  if (!response.ok) {
    throw new Error(
      `Request failed with status ${response.status}.`
    );
  }

  return response.json();
}
```

Use it like this:

```javascript
const controller = new AbortController();

const request = fetchTasksWithCancellation(
  controller.signal
);

controller.abort();

try {
  await request;
} catch (error) {
  if (error.name === "AbortError") {
    console.log("The request was cancelled.");
  } else {
    console.error(error);
  }
}
```

---

# 30. A Reusable Fetch Helper

A production-style JSON request helper should:

- Accept a URL.
- Accept request options.
- Check the HTTP response.
- Parse JSON.
- Throw useful errors.
- Accept an abort signal.

```javascript
export async function requestJSON(
  url,
  { signal, ...options } = {}
) {
  let response;

  try {
    response = await fetch(url, {
      ...options,
      signal,
      headers: {
        Accept: "application/json",
        ...options.headers,
      },
    });
  } catch (error) {
    if (error.name === "AbortError") {
      throw error;
    }

    throw new Error(
      "The network request could not be completed.",
      { cause: error }
    );
  }

  if (!response.ok) {
    throw new Error(
      `The server returned HTTP ${response.status}.`
    );
  }

  try {
    return await response.json();
  } catch (error) {
    throw new Error(
      "The server response was not valid JSON.",
      { cause: error }
    );
  }
}
```

Usage:

```javascript
const tasks = await requestJSON("/api/tasks");
```

---

# 31. Handling HTTP Errors

`fetch()` does not reject merely because the server returns a `4xx` or `5xx` status.

This request may fulfill:

```javascript
const response = await fetch("/missing-resource");
```

You must inspect `response.ok`:

```javascript
if (!response.ok) {
  throw new Error(
    `Request failed with HTTP ${response.status}.`
  );
}
```

A reliable request function should check this before parsing the result.

---

# 32. Preventing Duplicate Requests

Use a state guard:

```javascript
let isLoading = false;

async function loadTasks() {
  if (isLoading) {
    return;
  }

  isLoading = true;

  try {
    return await fetchTasks();
  } finally {
    isLoading = false;
  }
}
```

Also disable the relevant button:

```javascript
loadButton.disabled = true;
```

The state guard protects the application even if the function is called from another location.

---

# 33. Preventing Stale Responses

Suppose a user starts two searches:

```text
Search for "java"
Search for "javascript"
```

If the first request finishes after the second request, it could incorrectly replace the newer results.

Use a request sequence:

```javascript
let latestRequestNumber = 0;

async function searchTasks(query) {
  const requestNumber = ++latestRequestNumber;
  const results = await fetchSearchResults(query);

  if (requestNumber !== latestRequestNumber) {
    return;
  }

  renderResults(results);
}
```

Only the latest request is allowed to update the page.

---

# 34. Stale Response Protection with `AbortController`

A stronger approach cancels the previous request:

```javascript
let activeController = null;

async function searchTasks(query) {
  activeController?.abort();

  activeController = new AbortController();

  try {
    const results = await fetchSearchResults(
      query,
      activeController.signal
    );

    renderResults(results);
  } catch (error) {
    if (error.name === "AbortError") {
      return;
    }

    showError(error);
  }
}
```

The optional chaining call:

```javascript
activeController?.abort();
```

runs only if a previous controller exists.

---

# 35. Error Normalization

Not every thrown value is an `Error`.

```javascript
throw "Failure";
```

This is legal but discouraged.

Normalize unexpected values:

```javascript
function normalizeError(value) {
  if (value instanceof Error) {
    return value;
  }

  if (typeof value === "string") {
    return new Error(value);
  }

  return new Error("An unknown error occurred.");
}
```

Use it at application boundaries:

```javascript
try {
  await performOperation();
} catch (error) {
  const normalizedError = normalizeError(error);

  showError(normalizedError.message);
}
```

---

# 36. Retrying an Operation

A retry helper can repeat a failed operation a limited number of times.

```javascript
async function retry(operation, {
  attempts = 3,
  delayMilliseconds = 500,
} = {}) {
  let lastError;

  for (let attempt = 1; attempt <= attempts; attempt += 1) {
    try {
      return await operation();
    } catch (error) {
      lastError = error;

      if (attempt === attempts) {
        break;
      }

      await wait(delayMilliseconds);
    }
  }

  throw lastError;
}
```

Usage:

```javascript
const tasks = await retry(
  () => fetchTasks(),
  {
    attempts: 3,
    delayMilliseconds: 1000,
  }
);
```

Do not retry every error automatically.

Usually retry:

- Temporary network failures.
- Timeouts.
- Service-unavailable responses.

Usually do not retry:

- Invalid user input.
- Authentication failures.
- Permission errors.
- A request that will produce the same permanent failure.

---

# 37. Exponential Backoff

Instead of waiting the same duration after every failure, increase the delay.

```javascript
async function retryWithBackoff(
  operation,
  {
    attempts = 3,
    initialDelayMilliseconds = 250,
  } = {}
) {
  let lastError;

  for (let attempt = 0; attempt < attempts; attempt += 1) {
    try {
      return await operation();
    } catch (error) {
      lastError = error;

      const isLastAttempt = attempt === attempts - 1;

      if (isLastAttempt) {
        break;
      }

      const delay =
        initialDelayMilliseconds * 2 ** attempt;

      await wait(delay);
    }
  }

  throw lastError;
}
```

The delays are approximately:

```text
250 ms
500 ms
1000 ms
```

Add random jitter in high-traffic systems so many clients do not retry simultaneously.

---

# 38. Debouncing Asynchronous Searches

Debouncing waits until the user stops generating events.

```javascript
function debounce(callback, delayMilliseconds) {
  let timeoutId;

  return (...argumentsList) => {
    window.clearTimeout(timeoutId);

    timeoutId = window.setTimeout(() => {
      callback(...argumentsList);
    }, delayMilliseconds);
  };
}
```

Use it with a search input:

```javascript
const searchInput = document.querySelector("#search");

const performSearch = debounce(async (event) => {
  const query = event.target.value.trim();

  if (query.length === 0) {
    return;
  }

  try {
    const results = await searchTasks(query);
    renderResults(results);
  } catch (error) {
    showError(error);
  }
}, 300);

searchInput.addEventListener("input", performSearch);
```

Debouncing reduces unnecessary requests while the user is typing.

---

# 39. Throttling Asynchronous Work

Throttling limits how frequently a function can run.

A simple throttling helper:

```javascript
function throttle(callback, delayMilliseconds) {
  let isWaiting = false;

  return (...argumentsList) => {
    if (isWaiting) {
      return;
    }

    callback(...argumentsList);
    isWaiting = true;

    window.setTimeout(() => {
      isWaiting = false;
    }, delayMilliseconds);
  };
}
```

Use throttling for frequent events such as:

- Scrolling.
- Resizing.
- Pointer movement.

---

# 40. Async Iteration

An asynchronous iterable can produce values over time.

```javascript
async function* countWithDelay(maximum) {
  for (let number = 1; number <= maximum; number += 1) {
    await wait(500);
    yield number;
  }
}
```

Consume it with `for await...of`:

```javascript
for await (const number of countWithDelay(3)) {
  console.log(number);
}
```

Output appears over time:

```text
1
2
3
```

This pattern is useful for:

- Streams.
- Paginated data.
- Event sources.
- Incremental processing.

---

# 41. Loading Paginated Data

A pagination function may return one page at a time:

```javascript
async function loadAllPages() {
  const allTasks = [];
  let page = 1;
  let hasMorePages = true;

  while (hasMorePages) {
    const result = await fetchTaskPage(page);

    allTasks.push(...result.tasks);
    hasMorePages = result.hasMore;
    page += 1;
  }

  return allTasks;
}
```

This is sequential because the next page depends on the current page’s response.

---

# 42. Avoiding `forEach` with `await`

This does not wait for each operation:

```javascript
tasks.forEach(async (task) => {
  await saveTask(task);
});

console.log("Finished");
```

The `forEach` method does not wait for asynchronous callbacks.

## Sequential Alternative

```javascript
for (const task of tasks) {
  await saveTask(task);
}

console.log("Finished");
```

## Parallel Alternative

```javascript
await Promise.all(
  tasks.map((task) => saveTask(task))
);

console.log("Finished");
```

Choose sequential or parallel execution based on dependencies and resource limits.

---

# 43. Sequential Versus Parallel Example

```javascript
async function sequential() {
  const first = await wait(1000);
  const second = await wait(1000);

  return [first, second];
}
```

This takes approximately two seconds.

```javascript
async function parallel() {
  const [first, second] = await Promise.all([
    wait(1000),
    wait(1000),
  ]);

  return [first, second];
}
```

This takes approximately one second because both waits begin together.

---

# 44. A Complete Async Task Demo

Create this temporary file to test the central patterns.

### `async-reference-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>Asynchronous JavaScript Reference</title>
  </head>

  <body>
    <h1>Open the browser console</h1>

    <script type="module">
      function wait(milliseconds) {
        return new Promise((resolve) => {
          setTimeout(resolve, milliseconds);
        });
      }

      function loadTask(shouldFail = false) {
        return new Promise((resolve, reject) => {
          setTimeout(() => {
            if (shouldFail) {
              reject(
                new Error("The task request failed.")
              );
              return;
            }

            resolve({
              id: 1,
              title: "Review asynchronous JavaScript",
            });
          }, 500);
        });
      }

      async function runDemo() {
        console.log("Demo started");

        try {
          const task = await loadTask();

          console.log("Task loaded:", task);

          await wait(300);

          console.log("Additional asynchronous work completed.");
        } catch (error) {
          console.error("Demo failed:", error.message);
        } finally {
          console.log("Demo finished.");
        }
      }

      await runDemo();

      try {
        await loadTask(true);
      } catch (error) {
        console.log(
          "Expected failure:",
          error.message
        );
      }
    </script>
  </body>
</html>
```

## Expected Output

The console should show output similar to:

```text
Demo started
Task loaded: { id: 1, title: "Review asynchronous JavaScript" }
Additional asynchronous work completed.
Demo finished.
Expected failure: The task request failed.
```

Delete the file after testing.

---

# 45. Common Asynchronous Mistakes

## Mistake: Forgetting to Handle Rejections

```javascript
loadTasks();
```

If the Promise rejects, the application may produce an unhandled rejection.

Better:

```javascript
loadTasks().catch((error) => {
  console.error(error);
});
```

Or:

```javascript
try {
  await loadTasks();
} catch (error) {
  console.error(error);
}
```

## Mistake: Assuming `fetch()` Rejects on HTTP Errors

```javascript
const response = await fetch("/api/tasks");

if (!response.ok) {
  throw new Error(
    `HTTP error: ${response.status}`
  );
}
```

## Mistake: Forgetting `return` in a Promise Chain

```javascript
getUser()
  .then((user) => {
    getTasks(user.id);
  })
  .then((tasks) => {
    renderTasks(tasks);
  });
```

Return the nested Promise:

```javascript
getUser()
  .then((user) => {
    return getTasks(user.id);
  })
  .then((tasks) => {
    renderTasks(tasks);
  });
```

## Mistake: Running `await` Outside an Async Context

Incorrect in a classic script:

```javascript
const tasks = await loadTasks();
```

Use an async function:

```javascript
async function start() {
  const tasks = await loadTasks();
}

start();
```

Browser modules support top-level `await` in modern browsers, but using an explicit startup function can make control flow clearer.

## Mistake: Using `forEach` with `await`

Use `for...of` for sequential work or `Promise.all()` for parallel work.

## Mistake: Updating the UI After a Stale Request

Protect against stale responses with:

- A request sequence number.
- `AbortController`.
- A current-query comparison.

## Mistake: Hiding All Errors

This is dangerous:

```javascript
try {
  await loadTasks();
} catch {
  // Ignore every failure.
}
```

At minimum, log or display an appropriate failure state.

---

# 46. Asynchronous Testing Checklist

Test these scenarios manually:

- Successful asynchronous loading.
- Failed asynchronous loading.
- A delayed response.
- A response that takes longer than the timeout.
- Repeated clicks during loading.
- A cancelled request.
- Two searches started quickly.
- Malformed server data.
- Invalid JSON.
- A network failure.
- A `4xx` response.
- A `5xx` response.
- Cleanup after success.
- Cleanup after failure.

For every asynchronous operation, verify:

```text
Loading state begins
      ↓
Operation starts exactly once
      ↓
Success or error is handled
      ↓
Cleanup always runs
      ↓
The interface returns to a usable state
```

---

# 47. Async Design Checklist

Before adding an asynchronous feature, answer these questions:

1. What operation is asynchronous?
2. What value does it return?
3. What errors can occur?
4. Who owns the error handling?
5. What does the user see while waiting?
6. Can the user start the operation twice?
7. Can an older response overwrite a newer one?
8. Can the operation be cancelled?
9. Does it need a timeout?
10. Should independent operations run in parallel?
11. What cleanup must happen?
12. How will the operation be tested?

A clear answer to these questions prevents many common asynchronous bugs.
