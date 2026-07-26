# Primer 2: Browser Developer Tools and Debugging Fundamentals

Developer Tools are the browser’s built-in workshop for examining and debugging web applications.

They help you answer questions such as:

- Did the browser load the correct file?
- Did JavaScript run?
- What value does a variable contain?
- Which event triggered this function?
- Why is an element invisible?
- Was a network request sent?
- What data is in `localStorage`?
- Why did a Promise reject?
- Which line of code failed?

You will use Developer Tools throughout the main series. This primer teaches the most important panels and debugging techniques before asynchronous code and modules make the application more complex.

---

# 1. Open Developer Tools

## The Target

Open the browser’s Developer Tools.

## The Concept

Developer Tools are like a diagnostic dashboard for the browser.

The page is the machine. Developer Tools expose:

- The machine’s visible parts.
- The messages it produces.
- The operations it performs.
- The values it is currently using.
- The point where execution stops.

## The Implementation

Open any webpage in your browser.

Use one of these shortcuts:

### Windows/Linux

```text
F12
```

or:

```text
Ctrl + Shift + I
```

### macOS

```text
Cmd + Option + I
```

You can also right-click the page and select:

```text
Inspect
```

The main panels usually include:

```text
Elements
Console
Sources or Debugger
Network
Application or Storage
Performance
```

The exact names vary slightly by browser.

## The Verification

Open Developer Tools and confirm that you can find:

- A Console panel.
- An Elements or Inspector panel.
- A Sources or Debugger panel.
- A Network panel.
- An Application or Storage panel.

[COMPLETED: Step 1 — Developer Tools opened]  
[STARTING: Step 2 — Use the Console]

---

# 2. Use the Console

## The Target

Run JavaScript commands directly in the browser console.

## The Concept

The console is an interactive JavaScript workspace.

It is useful for:

- Testing small expressions.
- Inspecting page elements.
- Reading storage.
- Checking browser APIs.
- Logging application state.
- Reproducing small problems.

The console does not permanently change your source files. A value created in the console generally disappears when the page reloads.

## The Implementation

Open the **Console** panel and run:

```javascript
2 + 3;
```

The result should be:

```text
5
```

Run:

```javascript
"Hello".toUpperCase();
```

The result should be:

```text
"HELLO"
```

Run:

```javascript
[1, 2, 3].map((number) => number * 2);
```

The result should be:

```javascript
[2, 4, 6]
```

## The Verification

Run:

```javascript
console.log("The console is working.");
```

Expected output:

```text
The console is working.
```

Now run:

```javascript
console.warn("This is a warning.");
console.error("This is an error.");
```

You should see visually distinct warning and error messages.

[COMPLETED: Step 2 — Console experiments completed]  
[STARTING: Step 3 — Inspect the DOM with the Elements panel]

---

# 3. Inspect HTML with the Elements Panel

## The Target

Inspect and temporarily modify the page’s HTML.

## The Concept

The Elements panel shows the browser’s current DOM.

It displays the page after the browser has:

- Parsed the HTML.
- Applied JavaScript changes.
- Applied CSS classes.
- Added or removed elements.

This is important because the HTML source file and the current DOM may differ.

For example, JavaScript may execute:

```javascript
title.textContent = "Updated title";
```

The Elements panel shows the updated title.

## The Implementation

Create a temporary file:

### `devtools-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>Developer Tools Demo</title>

    <style>
      body {
        font-family: system-ui, sans-serif;
        margin: 2rem;
      }

      .highlight {
        color: #2457d6;
        font-weight: 800;
      }
    </style>
  </head>

  <body>
    <main>
      <h1 id="page-title">Original title</h1>

      <p id="message">
        Original message.
      </p>

      <button id="highlight-button" type="button">
        Highlight title
      </button>
    </main>

    <script>
      "use strict";

      const pageTitle = document.querySelector(
        "#page-title"
      );

      const message = document.querySelector(
        "#message"
      );

      const highlightButton = document.querySelector(
        "#highlight-button"
      );

      highlightButton.addEventListener("click", () => {
        pageTitle.classList.toggle("highlight");
        message.textContent =
          "The DOM was changed by JavaScript.";
      });
    </script>
  </body>
</html>
```

Open the file and click **Highlight title**.

## The Verification

Open the **Elements** panel.

Inspect:

```html
<h1 id="page-title">Original title</h1>
```

Click the button in the page.

The Elements panel should now show that:

- The heading has the `highlight` class.
- The paragraph text has changed.

You can also right-click an element and choose an option similar to:

```text
Break on → Attribute modifications
```

Then click the button again.

The debugger may pause when JavaScript changes the class.

Delete `devtools-demo.html` after testing.

[COMPLETED: Step 3 — DOM inspection completed]  
[STARTING: Step 4 — Inspect CSS and layout]

---

# 4. Inspect CSS and Layout

## The Target

Use the Elements panel to inspect styles and layout.

## The Concept

When an element looks wrong, you need to distinguish between:

- The wrong HTML structure.
- The wrong CSS rule.
- A CSS rule being overridden.
- Incorrect dimensions.
- An unexpected margin or padding.
- An element being hidden.

The Styles pane shows which CSS declarations apply to the selected element.

The Computed pane shows the final values after the browser resolves all rules.

## The Implementation

Use `devtools-demo.html` or the main application.

In the Elements panel:

1. Select the `h1`.
2. Inspect the **Styles** pane.
3. Find the `.highlight` rule.
4. Uncheck the `font-weight` declaration.
5. Check it again.
6. Add a temporary declaration.

For example:

```css
background: yellow;
```

To inspect layout, select the element and find the box model diagram.

It usually shows:

```text
margin
border
padding
content
```

## The Verification

Confirm that:

- Unchecking a declaration changes the page immediately.
- Adding a declaration changes the page immediately.
- The computed styles show the final values.
- The box model shows the element’s spacing.

These changes are temporary. To keep a change, copy it into the CSS file.

[COMPLETED: Step 4 — CSS inspection and box-model debugging completed]  
[STARTING: Step 5 — Add useful logging]

---

# 5. Add Useful Console Logging

## The Target

Log application values in a structured way.

## The Concept

Logs are temporary observation points.

A useful log answers a question:

```javascript
console.log("Current filter:", currentFilter);
```

A vague log is harder to interpret:

```javascript
console.log(currentFilter);
```

Structured logs are especially helpful when several values must be compared.

## The Implementation

Create:

### `logging-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>Logging Demo</title>
  </head>

  <body>
    <h1>Open the console</h1>

    <script>
      "use strict";

      const tasks = [
        {
          id: 1,
          title: "Learn logging",
          completed: false,
        },
        {
          id: 2,
          title: "Inspect objects",
          completed: true,
        },
      ];

      const currentFilter = "all";
      const isLoading = false;

      console.log("Tasks:", tasks);
      console.log("Current filter:", currentFilter);
      console.log("Loading state:", isLoading);

      console.log("Application state:", {
        tasks,
        currentFilter,
        isLoading,
      });

      console.table(tasks);

      console.warn(
        "This warning demonstrates a non-fatal problem."
      );

      console.error(
        "This error demonstrates a failure message."
      );
    </script>
  </body>
</html>
```

## The Verification

Open the page and inspect the Console.

You should see:

- Individual labeled values.
- One structured state object.
- A table of tasks.
- A warning.
- An error.

`console.table(tasks)` should display task properties in columns.

Delete `logging-demo.html` after testing.

[COMPLETED: Step 5 — Structured logging practiced]  
[STARTING: Step 6 — Use breakpoints]

---

# 6. Use Breakpoints

## The Target

Pause JavaScript execution at a specific line.

## The Concept

A breakpoint is a deliberate pause in execution.

When the browser pauses, you can inspect:

- Function arguments.
- Local variables.
- Global values.
- The current call stack.
- The next statement.
- The current DOM.

This is more powerful than adding many logs because you can inspect the entire execution context at the exact moment of interest.

## The Implementation

Create:

### `breakpoint-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>Breakpoint Demo</title>
  </head>

  <body>
    <button id="add-button" type="button">
      Add number
    </button>

    <p id="output">0</p>

    <script>
      "use strict";

      const addButton = document.querySelector(
        "#add-button"
      );

      const output = document.querySelector(
        "#output"
      );

      let total = 0;

      function addNumber(amount) {
        total += amount;
        output.textContent = String(total);
      }

      addButton.addEventListener("click", () => {
        addNumber(1);
      });
    </script>
  </body>
</html>
```

Open the page.

Open **Sources** or **Debugger**.

Find the inline script or the document source.

Click the line containing:

```javascript
total += amount;
```

This creates a breakpoint.

Click **Add number**.

## The Verification

The browser should pause on:

```javascript
total += amount;
```

Inspect the variables panel.

You should see:

```text
amount: 1
total: 0
```

Use the debugger controls:

- **Resume** — continue execution.
- **Step over** — execute the current line without entering called functions.
- **Step into** — enter a called function.
- **Step out** — leave the current function.

Click **Resume**.

The page should update to:

```text
1
```

[COMPLETED: Step 6 — Breakpoints and debugger controls practiced]  
[STARTING: Step 7 — Use the `debugger` statement]

---

# 7. Use the `debugger` Statement

## The Target

Pause execution from inside source code.

## The Concept

The `debugger` statement is a programmatic breakpoint.

```javascript
debugger;
```

If Developer Tools are open, execution pauses there.

This is useful when:

- The line is difficult to find manually.
- You want to pause only after a condition.
- You are debugging a callback.
- You are debugging an asynchronous function.

## The Implementation

Update `breakpoint-demo.html`:

```javascript
function addNumber(amount) {
  debugger;

  total += amount;
  output.textContent = String(total);
}
```

## The Verification

Refresh the page and click **Add number**.

The browser should pause at:

```javascript
debugger;
```

Inspect:

```text
amount
total
output
```

Resume execution.

Remove the `debugger` statement after testing.

[COMPLETED: Step 7 — Programmatic breakpoint practiced]  
[STARTING: Step 8 — Inspect the call stack]

---

# 8. Inspect the Call Stack

## The Target

Understand which functions called the current function.

## The Concept

The call stack is the chain of active function calls.

Consider:

```javascript
function start() {
  process();
}

function process() {
  finish();
}

function finish() {
  debugger;
}

start();
```

When execution pauses inside `finish()`, the call stack shows:

```text
finish
process
start
global script
```

This helps answer:

> How did the code reach this line?

## The Implementation

Create:

### `stack-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>Call Stack Demo</title>
  </head>

  <body>
    <button id="start-button" type="button">
      Start workflow
    </button>

    <script>
      "use strict";

      const startButton = document.querySelector(
        "#start-button"
      );

      function startWorkflow() {
        prepareWorkflow();
      }

      function prepareWorkflow() {
        executeWorkflow();
      }

      function executeWorkflow() {
        debugger;

        console.log("Workflow executed.");
      }

      startButton.addEventListener(
        "click",
        startWorkflow
      );
    </script>
  </body>
</html>
```

## The Verification

1. Open Developer Tools.
2. Click **Start workflow**.
3. Inspect the call stack.

You should see functions similar to:

```text
executeWorkflow
prepareWorkflow
startWorkflow
event listener
```

Resume execution and confirm:

```text
Workflow executed.
```

Delete `stack-demo.html` afterward.

[COMPLETED: Step 8 — Call stack inspected]  
[STARTING: Step 9 — Debug errors with source locations]

---

# 9. Read a JavaScript Error

## The Target

Create and diagnose a deliberate error.

## The Concept

Errors contain useful information.

A typical error includes:

- The error type.
- A message.
- A source file.
- A line number.
- A stack trace.

Do not fear the error message. Read it as a diagnostic report.

## The Implementation

Create:

### `error-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>Error Demo</title>
  </head>

  <body>
    <h1>Error demonstration</h1>

    <script>
      "use strict";

      function readMissingProperty() {
        const value = null;

        return value.title;
      }

      readMissingProperty();
    </script>
  </body>
</html>
```

## The Verification

Open the page and read the console.

You should see an error similar to:

```text
TypeError:
Cannot read properties of null
```

Click the source location shown in the error.

The browser should open the exact line:

```javascript
return value.title;
```

Inspect the surrounding code and identify the cause:

```javascript
const value = null;
```

The code attempts to read `.title` from `null`.

Delete `error-demo.html` after testing.

[COMPLETED: Step 9 — Source error diagnosis practiced]  
[STARTING: Step 10 — Use conditional breakpoints]

---

# 10. Use Conditional Breakpoints

## The Target

Pause only when a specific condition is true.

## The Concept

A normal breakpoint pauses every time execution reaches a line.

A conditional breakpoint pauses only when a condition evaluates to `true`.

This is useful when:

- A loop processes many items.
- A callback runs repeatedly.
- Only one task ID is problematic.
- An error occurs only for a particular value.

## The Implementation

Create:

### `conditional-breakpoint-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>Conditional Breakpoint Demo</title>
  </head>

  <body>
    <h1>Open the debugger</h1>

    <script>
      "use strict";

      const tasks = [
        {
          id: 1,
          title: "First task",
        },
        {
          id: 2,
          title: "Second task",
        },
        {
          id: 3,
          title: "Third task",
        },
      ];

      for (const task of tasks) {
        console.log(task.title);
      }
    </script>
  </body>
</html>
```

Open the Sources or Debugger panel.

Set a breakpoint on:

```javascript
console.log(task.title);
```

Right-click the breakpoint and choose an option similar to:

```text
Add conditional breakpoint
```

Enter:

```javascript
task.id === 2
```

## The Verification

Reload the page.

The debugger should pause only for:

```javascript
{
  id: 2,
  title: "Second task"
}
```

It should not pause for task IDs `1` or `3`.

Delete the file after testing.

[COMPLETED: Step 10 — Conditional breakpoint practiced]  
[STARTING: Step 11 — Inspect network requests]

---

# 11. Inspect the Network Panel

## The Target

Observe browser requests.

## The Concept

The Network panel shows communication between the browser and servers.

It can reveal:

- Whether a request was sent.
- The request URL.
- The HTTP method.
- The status code.
- Request headers.
- Response headers.
- Response body.
- Timing.
- Failed requests.

Even when an application appears to do nothing, the Network panel can show whether a request was attempted.

## The Implementation

Create:

### `network-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>Network Demo</title>
  </head>

  <body>
    <button id="load-button" type="button">
      Load data
    </button>

    <pre id="output"></pre>

    <script>
      "use strict";

      const loadButton = document.querySelector(
        "#load-button"
      );

      const output = document.querySelector(
        "#output"
      );

      loadButton.addEventListener("click", async () => {
        output.textContent = "Loading...";

        try {
          const response = await fetch(
            "https://jsonplaceholder.typicode.com/todos/1"
          );

          if (!response.ok) {
            throw new Error(
              `Request failed with HTTP ${response.status}.`
            );
          }

          const data = await response.json();

          output.textContent = JSON.stringify(
            data,
            null,
            2
          );
        } catch (error) {
          output.textContent = error.message;
          console.error(error);
        }
      });
    </script>
  </body>
</html>
```

## The Verification

Open Developer Tools before clicking the button.

Open the **Network** panel.

Click **Load data**.

Inspect the request and verify:

- The request URL.
- The method, usually `GET`.
- The status, normally `200`.
- The response body.
- The request timing.

Click the request and inspect the **Headers**, **Preview**, and **Response** sections.

If the request fails because of network or cross-origin restrictions, the console and Network panel should provide more detail.

Delete the file after testing.

[COMPLETED: Step 11 — Network inspection practiced]  
[STARTING: Step 12 — Inspect browser storage]

---

# 12. Inspect `localStorage` and `sessionStorage`

## The Target

Use Developer Tools to inspect browser storage.

## The Concept

Storage debugging helps determine whether data was:

- Saved.
- Saved under the wrong key.
- Saved as malformed JSON.
- Saved under a different origin.
- Removed unexpectedly.

## The Implementation

Open the main project through a local server:

```bash
python3 -m http.server 8000
```

Open:

```text
http://localhost:8000
```

In the browser console, run:

```javascript
localStorage.setItem(
  "devtools-demo.tasks",
  JSON.stringify([
    {
      id: 1,
      title: "Inspect storage",
      completed: false,
    },
  ])
);

sessionStorage.setItem(
  "devtools-demo.filter",
  "active"
);
```

Open the **Application** panel in Chrome or Edge, or the **Storage** panel in Firefox.

Find:

```text
Local Storage
Session Storage
```

Select the current origin.

## The Verification

Confirm that you can see:

```text
devtools-demo.tasks
devtools-demo.filter
```

Inspect the local-storage value:

```javascript
const rawTasks = localStorage.getItem(
  "devtools-demo.tasks"
);

console.log(rawTasks);
console.log(JSON.parse(rawTasks));
```

Clean up:

```javascript
localStorage.removeItem(
  "devtools-demo.tasks"
);

sessionStorage.removeItem(
  "devtools-demo.filter"
);
```

[COMPLETED: Step 12 — Browser storage inspected]  
[STARTING: Step 13 — Debug asynchronous code]

---

# 13. Debug a Timer

## The Target

Observe when asynchronous callbacks execute.

## The Concept

A timer callback does not run immediately.

The browser:

1. Registers the timer.
2. Continues executing current code.
3. Waits until the delay has elapsed.
4. Places the callback into a queue.
5. Runs it when JavaScript can process it.

Breakpoints help you observe this sequence.

## The Implementation

Create:

### `async-debug-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>Asynchronous Debugging Demo</title>
  </head>

  <body>
    <button id="start-button" type="button">
      Start asynchronous work
    </button>

    <p id="status">Ready.</p>

    <script>
      "use strict";

      const startButton = document.querySelector(
        "#start-button"
      );

      const status = document.querySelector(
        "#status"
      );

      startButton.addEventListener("click", () => {
        console.log("1. Click handler started");

        status.textContent = "Loading...";

        setTimeout(() => {
          debugger;

          console.log("3. Timer callback executed");
          status.textContent = "Finished.";
        }, 1000);

        console.log("2. Timer registered");
      });
    </script>
  </body>
</html>
```

## The Verification

Open the Console and Sources panels.

Click the button.

Immediately, the console should show:

```text
1. Click handler started
2. Timer registered
```

After approximately one second, the debugger should pause inside the timer callback.

Resume execution.

The console should show:

```text
3. Timer callback executed
```

Observe the call stack while paused. The stack now represents the timer callback’s execution, not the original click handler’s active call.

Delete the file after testing.

[COMPLETED: Step 13 — Timer callback debugging practiced]  
[STARTING: Step 14 — Debug Promise and async/await code]

---

# 14. Debug Promises and `async`/`await`

## The Target

Pause inside an asynchronous function and inspect its state.

## The Concept

An `async` function can pause at `await`.

The function is not permanently blocked. It yields control while the Promise is pending and resumes later.

A breakpoint after `await` lets you inspect the resolved value.

## The Implementation

Create:

### `promise-debug-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>Promise Debugging Demo</title>
  </head>

  <body>
    <button id="load-button" type="button">
      Load task
    </button>

    <pre id="output"></pre>

    <script>
      "use strict";

      const loadButton = document.querySelector(
        "#load-button"
      );

      const output = document.querySelector(
        "#output"
      );

      function loadTask() {
        return new Promise((resolve) => {
          setTimeout(() => {
            resolve({
              id: 1,
              title: "Inspect a Promise result",
              completed: false,
            });
          }, 1000);
        });
      }

      async function loadAndDisplayTask() {
        output.textContent = "Loading...";

        try {
          const task = await loadTask();

          debugger;

          output.textContent = JSON.stringify(
            task,
            null,
            2
          );
        } catch (error) {
          output.textContent = error.message;
        }
      }

      loadButton.addEventListener("click", () => {
        loadAndDisplayTask();
      });
    </script>
  </body>
</html>
```

## The Verification

1. Open the Console and Sources panels.
2. Click **Load task**.
3. Wait approximately one second.
4. The debugger should pause after `await`.
5. Inspect the local variable `task`.
6. Resume execution.

The page should display:

```json
{
  "id": 1,
  "title": "Inspect a Promise result",
  "completed": false
}
```

Delete the file afterward.

[COMPLETED: Step 14 — Promise result debugging practiced]  
[STARTING: Step 15 — Monitor rejected Promises]

---

# 15. Debug Unhandled Promise Rejections

## The Target

Detect a Promise rejection that has no handler.

## The Concept

A rejected Promise should normally be handled intentionally.

Bad:

```javascript
loadData();
```

Better:

```javascript
loadData().catch((error) => {
  console.error(error);
});
```

During development, a global `unhandledrejection` listener can expose forgotten handlers.

## The Implementation

Create:

### `rejection-debug-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>Promise Rejection Demo</title>
  </head>

  <body>
    <button id="fail-button" type="button">
      Trigger rejection
    </button>

    <script>
      "use strict";

      window.addEventListener(
        "unhandledrejection",
        (event) => {
          console.error(
            "Unhandled rejection detected:",
            event.reason
          );
        }
      );

      function failOperation() {
        return Promise.reject(
          new Error("The operation failed.")
        );
      }

      document
        .querySelector("#fail-button")
        .addEventListener("click", () => {
          failOperation();
        });
    </script>
  </body>
</html>
```

## The Verification

Click **Trigger rejection**.

The console should show an unhandled rejection.

Now change:

```javascript
failOperation();
```

to:

```javascript
failOperation().catch((error) => {
  console.error(
    "Handled rejection:",
    error.message
  );
});
```

Refresh and click again.

The rejection should now be handled explicitly.

Delete the file afterward.

[COMPLETED: Step 15 — Promise rejection diagnosis practiced]  
[STARTING: Step 16 — Use network throttling and offline mode]

---

# 16. Simulate Slow and Offline Networks

## The Target

Test asynchronous behavior under poor network conditions.

## The Concept

An application that works on a fast development connection may fail or feel confusing on:

- Slow mobile data.
- Intermittent connections.
- Offline devices.
- High-latency networks.
- Failed requests.

Developer Tools can simulate these conditions.

## The Implementation

Open the Network panel.

Find the network throttling control, often labeled:

```text
No throttling
```

Choose:

```text
Fast 3G
```

or:

```text
Slow 3G
```

Open the Network panel’s offline option and select:

```text
Offline
```

Use the network demo or the main application’s asynchronous loading feature.

## The Verification

Under throttling, verify:

- Loading messages remain visible long enough to observe.
- Buttons remain disabled while work is active.
- The interface does not appear frozen.
- Errors are understandable when the request fails.
- Cleanup restores the interface.

Under offline mode, verify:

- Network errors are handled.
- The application does not display false success.
- Local features continue if designed to work offline.

Restore:

```text
No throttling
Online
```

[COMPLETED: Step 16 — Slow and offline network testing practiced]  
[STARTING: Step 17 — Preserve and copy diagnostic information]

---

# 17. Copy Console Errors and Network Details

## The Target

Capture useful diagnostic information when asking for help or recording a bug.

## The Concept

A good bug report contains evidence.

Include:

- The exact error message.
- The source file and line.
- The action that caused the error.
- The expected behavior.
- The actual behavior.
- Relevant network status.
- Whether the issue is reproducible.

Do not include secrets or private user data.

## The Implementation

When an error appears:

1. Right-click the console message.
2. Choose an option similar to:
   ```text
   Copy message
   ```
3. Copy the source location.
4. Record the browser and URL.
5. Record the steps that reproduced the problem.

For a network request:

1. Right-click the request.
2. Choose:
   ```text
   Copy → Copy as fetch
   ```
3. Review the copied request before sharing it.
4. Remove cookies, authorization headers, private data, and tokens.

## The Verification

Create a sample bug report:

```text
Title:
Load example tasks button remains disabled after failure.

Steps:
1. Open http://localhost:8000.
2. Set the simulated API failure flag to true.
3. Click Load example tasks.
4. Wait for the response.

Expected:
The error appears and the button becomes enabled.

Actual:
The error appears but the button remains disabled.

Console:
[paste sanitized error]

Browser:
[record browser and version]
```

[COMPLETED: Step 17 — Diagnostic information captured safely]  
[STARTING: Step 18 — Use the final debugging workflow]

---

# 18. The Complete Debugging Workflow

## The Target

Use a repeatable process for diagnosing the task manager.

## The Concept

Debugging becomes easier when it follows a consistent sequence.

Use this workflow:

```text
Reproduce
    ↓
Read the first error
    ↓
Inspect the relevant value
    ↓
Pause at the important line
    ↓
Trace the call stack
    ↓
Check the DOM or network
    ↓
Fix one cause
    ↓
Verify the original behavior
    ↓
Run regression tests
```

## The Implementation

When a feature fails, follow these steps.

### Step 1: Reproduce

Write the smallest sequence that causes the problem:

```text
1. Refresh page.
2. Select Completed tasks.
3. Click Load example tasks.
4. Observe the result.
```

### Step 2: Read the Console

Look for:

- Red errors.
- Promise rejection messages.
- Module errors.
- Storage errors.
- Network errors.

### Step 3: Inspect State

Log structured state:

```javascript
console.log("Application state:", {
  tasks: this.taskService.getAll(),
  currentFilter: this.currentFilter,
  isLoading: this.isLoading,
});
```

### Step 4: Add a Breakpoint

Pause before the suspected operation:

```javascript
const visibleTasks =
  this.taskService.getByFilter(
    this.currentFilter
  );
```

### Step 5: Inspect the DOM

Confirm:

- The expected element exists.
- The expected class is present.
- The text is correct.
- The element is not hidden.
- A CSS rule is not overriding the expected style.

### Step 6: Inspect Network Activity

If asynchronous data is involved, check:

- Whether a request started.
- Whether it completed.
- Its status.
- Its response.
- Whether it was cancelled.

### Step 7: Inspect Storage

Check:

```javascript
localStorage.getItem(
  "async-task-manager.tasks.v1"
);
```

### Step 8: Make One Change

Avoid rewriting unrelated code.

### Step 9: Verify

Repeat the original reproduction steps.

### Step 10: Run Regression Tests

Confirm that existing features still work.

## The Verification

Practice the workflow with a deliberate problem.

Temporarily change the API loading code so that the button is not restored in `finally`.

Reproduce:

1. Start loading.
2. Trigger a failure.
3. Observe the disabled button.
4. Inspect the `catch` and `finally` blocks.
5. Restore the cleanup code.
6. Test both success and failure.

[COMPLETED: Step 18 — Complete debugging workflow practiced]  
[STARTING: Primer 2 Reference — Developer Tools quick reference]

---

# Developer Tools Quick Reference

## Console

Use for:

```javascript
console.log(value);
console.warn(message);
console.error(error);
console.table(array);
console.assert(condition, message);
console.clear();
```

## Elements

Use for:

- Inspecting HTML.
- Inspecting DOM changes.
- Inspecting CSS.
- Checking the box model.
- Testing temporary style changes.
- Watching attribute modifications.

## Sources/Debugger

Use for:

- Breakpoints.
- Conditional breakpoints.
- `debugger`.
- Stepping through code.
- Inspecting local variables.
- Reading the call stack.
- Pausing on exceptions.

## Network

Use for:

- Requests.
- HTTP statuses.
- Headers.
- Request payloads.
- Response bodies.
- Timing.
- Network failures.
- Throttling.
- Offline simulation.

## Application/Storage

Use for:

- `localStorage`.
- `sessionStorage`.
- Cookies.
- Cache Storage.
- Service workers.
- IndexedDB.

## Performance

Use for:

- Long-running tasks.
- Rendering delays.
- Layout problems.
- CPU-heavy synchronous work.
- Slow page interactions.

---

# Common Debugging Questions

## Is JavaScript Running?

Add:

```javascript
console.log("Script started.");
```

If it does not appear:

- The script path may be wrong.
- The script may not load.
- A syntax error may occur before the log.
- The wrong HTML file may be open.

## Does the Element Exist?

Run:

```javascript
document.querySelector("#task-list");
```

If the result is `null`, check the HTML ID and script timing.

## Did the Event Run?

Add:

```javascript
button.addEventListener("click", () => {
  console.log("Click handler ran.");
});
```

If the message does not appear, the listener may not be bound.

## Did the State Change?

Log before and after:

```javascript
console.log("Before:", tasks);

tasks.push(newTask);

console.log("After:", tasks);
```

## Did the DOM Render?

Inspect:

```javascript
document.querySelector("#task-list");
```

Then inspect its child elements in the Elements panel.

## Did the Promise Resolve?

Use:

```javascript
try {
  const result = await operation();
  console.log("Resolved:", result);
} catch (error) {
  console.error("Rejected:", error);
}
```

## Did Storage Work?

Run:

```javascript
localStorage.getItem(
  "async-task-manager.tasks.v1"
);
```

## Is the Browser Showing an Old File?

Save the source file and use:

```text
Ctrl + Shift + R
```

or:

```text
Cmd + Shift + R
```

---

# Primer 2 Completion Checklist

Before beginning Part 0, confirm that you can:

- [ ] Open Developer Tools.
- [ ] Run JavaScript in the Console.
- [ ] Inspect the current DOM.
- [ ] Inspect CSS rules.
- [ ] Inspect the box model.
- [ ] Add useful labeled logs.
- [ ] Use `console.table()`.
- [ ] Set a breakpoint.
- [ ] Use the `debugger` statement.
- [ ] Step over code.
- [ ] Step into a function.
- [ ] Inspect local variables.
- [ ] Inspect the call stack.
- [ ] Read an error’s source location.
- [ ] Use a conditional breakpoint.
- [ ] Inspect network requests.
- [ ] Inspect response status and body.
- [ ] Simulate slow network conditions.
- [ ] Simulate offline mode.
- [ ] Inspect `localStorage`.
- [ ] Inspect `sessionStorage`.
- [ ] Debug timer callbacks.
- [ ] Debug Promise results.
- [ ] Detect unhandled Promise rejections.
- [ ] Describe a bug with reproducible steps.
- [ ] Use a repeatable debugging workflow.
