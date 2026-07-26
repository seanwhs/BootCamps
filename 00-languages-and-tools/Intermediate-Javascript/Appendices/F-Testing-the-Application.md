# Appendix F: Testing the Application

Testing checks whether software behaves as expected.

A test is not only a way to find bugs after development. Tests also help you:

- Clarify requirements.
- Protect existing features.
- Refactor with confidence.
- Detect regressions.
- Verify error paths.
- Document intended behavior.

This appendix covers manual testing first, then introduces automated tests for the task manager’s model and service layers.

---

# 1. Testing Levels

The application can be tested at several levels.

## Manual Testing

A person opens the application and performs actions.

Example:

```text
Enter a task title.
Click Add task.
Verify that the task appears.
```

Manual testing is useful for:

- Visual behavior.
- Accessibility.
- Responsive layouts.
- Real browser interactions.
- End-to-end workflows.

## Unit Testing

A unit test checks one small piece of code in isolation.

Examples:

- Does `validateTaskTitle()` reject an empty title?
- Does `Task.toggleCompletion()` change the completion state?
- Does `TaskService.remove()` delete the correct task?

## Integration Testing

An integration test checks whether multiple parts work together.

Examples:

- Does the storage service save and restore `Task` instances?
- Does the application coordinate the task service and UI?
- Does loading API data update storage and rendering?

## End-to-End Testing

An end-to-end test runs the entire application as a user would.

Example:

```text
Open browser
Add task
Complete task
Refresh page
Verify task remains completed
```

---

# 2. Testing Pyramid

A useful testing strategy resembles a pyramid:

```text
             End-to-end tests
          Integration tests
       Unit tests
```

The lower levels should contain more tests because they are usually:

- Faster.
- More deterministic.
- Easier to diagnose.
- Easier to run repeatedly.

The upper levels are valuable but typically:

- Slower.
- More dependent on browser behavior.
- More sensitive to timing.
- More difficult to diagnose.

For this project:

```text
Many unit tests
Some integration tests
A smaller number of end-to-end tests
```

---

# 3. What Should Be Tested?

The most important behaviors are:

## Task Model

- Valid task construction.
- Empty title rejection.
- Excessively long title rejection.
- Invalid identifiers.
- Invalid completion states.
- Completion behavior.
- Reopening behavior.
- Serialization.
- Restoration from JSON.

## Validation

- Valid title normalization.
- Empty title rejection.
- Whitespace-only title rejection.
- Maximum length enforcement.
- Valid filter values.
- Invalid filter values.

## Task Service

- Adding tasks.
- Finding tasks.
- Toggling tasks.
- Removing tasks.
- Filtering active tasks.
- Filtering completed tasks.
- Replacing all tasks.
- Counting completed tasks.

## Storage

- Saving task arrays.
- Restoring task instances.
- Handling no stored data.
- Handling malformed JSON.
- Ignoring malformed individual tasks.
- Clearing saved data.
- Saving filter preferences.

## API

- Successful asynchronous loading.
- Rejected asynchronous loading.
- Returned values being `Task` instances.

## UI

- Task rendering.
- Empty state rendering.
- Completion button behavior.
- Delete button behavior.
- Status message states.
- Form submission.

---

# 4. Manual Test Plan

Manual tests should be written before testing begins.

Each test should describe:

- The setup.
- The action.
- The expected result.

A useful format is:

| ID | Scenario | Action | Expected result |
|---|---|---|---|
| M-001 | Add valid task | Submit a title | Task appears |
| M-002 | Add empty task | Submit blank input | Error appears |
| M-003 | Complete task | Click completion button | Task becomes completed |
| M-004 | Reload persistence | Refresh page | Task remains |
| M-005 | Load examples | Click load button | Loading and success states appear |

---

# 5. Manual Test M-001: Initial Startup

## Setup

1. Open the project through a local server.
2. Clear existing application storage.

Run in the browser console:

```javascript
localStorage.removeItem(
  "async-task-manager.tasks.v1"
);

sessionStorage.removeItem(
  "async-task-manager.filter.v1"
);

location.reload();
```

## Expected Result

Verify:

- The page loads.
- No uncaught errors appear in the console.
- The status message says that the application is ready.
- The task list displays the empty state.
- The filter defaults to `All tasks`.

---

# 6. Manual Test M-002: Add a Valid Task

## Setup

Start from the loaded application.

## Action

Enter:

```text
Learn automated testing
```

Click **Add task**.

## Expected Result

Verify:

- The task appears in the list.
- The input becomes empty.
- The input receives focus.
- The status message says:

```text
Added task: Learn automated testing
```

- The task count changes to:

```text
1 task · 0 completed
```

---

# 7. Manual Test M-003: Reject an Empty Task

## Action

Submit the form with an empty input.

Then submit it with whitespace:

```text
     
```

## Expected Result

Verify:

- No task is added.
- The status message displays an error.
- The task count does not increase.
- The browser console has no unexpected error.

Expected message:

```text
Task title cannot be empty.
```

---

# 8. Manual Test M-004: Enforce Maximum Title Length

The application allows a maximum of 120 characters.

## Action

Run this in the console:

```javascript
const longTitle = "a".repeat(121);
console.log(longTitle.length);
```

Copy the resulting string into the task input and submit it.

## Expected Result

The application should reject the title.

Expected message:

```text
Task title cannot contain more than 120 characters.
```

Now test exactly 120 characters:

```javascript
const validMaximumTitle = "a".repeat(120);
console.log(validMaximumTitle.length);
```

Submit it.

The task should be accepted.

---

# 9. Manual Test M-005: Complete a Task

## Setup

Add:

```text
Complete this task
```

## Action

Click **Mark as complete**.

## Expected Result

Verify:

- The title receives a strikethrough.
- The button changes to **Mark as incomplete**.
- The metadata changes to `Completed`.
- The completed count increases.
- A success message appears.

---

# 10. Manual Test M-006: Reopen a Task

## Action

Click **Mark as incomplete** on a completed task.

## Expected Result

Verify:

- The strikethrough disappears.
- The button changes to **Mark as complete**.
- The metadata changes to `Not completed`.
- The completed count decreases.

---

# 11. Manual Test M-007: Delete a Task

## Action

Click **Delete** on a task.

## Expected Result

Verify:

- The task disappears.
- The task count decreases.
- A success message appears.
- The task is removed from storage.

Inspect storage:

```javascript
const rawTasks = localStorage.getItem(
  "async-task-manager.tasks.v1"
);

console.log(rawTasks);
```

The deleted task should not appear.

---

# 12. Manual Test M-008: Filter Tasks

## Setup

Create these tasks:

```text
Active task one
Active task two
Completed task
```

Complete only `Completed task`.

## Action

Select:

```text
All tasks
```

Then:

```text
Active tasks
```

Then:

```text
Completed tasks
```

## Expected Result

### All tasks

All three tasks appear.

### Active tasks

Only these appear:

```text
Active task one
Active task two
```

### Completed tasks

Only this appears:

```text
Completed task
```

The task count should continue to represent the total task collection.

---

# 13. Manual Test M-009: Persist Tasks

## Action

1. Add a task.
2. Complete it.
3. Refresh the browser.

## Expected Result

Verify:

- The task remains.
- Its completed state remains.
- The selected filter remains if the same tab session continues.
- The console contains no restoration error.

---

# 14. Manual Test M-010: Load Example Tasks

## Action

Click **Load example tasks**.

## Expected Result During Loading

Immediately verify:

- The button is disabled.
- The status says:

```text
Loading example tasks...
```

- The browser remains responsive.
- Clicking the button again does not start another load.

## Expected Result After Success

After approximately 1.2 seconds:

- Three example tasks appear.
- The tasks are saved.
- The button is enabled again.
- The status confirms successful loading.

---

# 15. Manual Test M-011: Test Asynchronous Failure

The API currently defaults to success:

```javascript
fetchExampleTasks();
```

To test failure, temporarily change `js/app.js`:

```javascript
const exampleTasks = await fetchExampleTasks({
  shouldFail: true,
});
```

Or modify the call inside `handleLoadExampleTasks()`:

```javascript
const exampleTasks = await fetchExampleTasks({
  shouldFail: true,
});
```

## Expected Result

Verify:

- The loading state appears.
- The error message appears after the delay.
- The button becomes enabled.
- Existing tasks are not unexpectedly replaced.
- The console contains a useful error.

Restore the normal call:

```javascript
const exampleTasks = await fetchExampleTasks();
```

---

# 16. Manual Test M-012: Clear Saved Tasks

## Action

1. Create multiple tasks.
2. Click **Clear saved tasks**.
3. Refresh the page.

## Expected Result

Verify:

- The task list is empty.
- The task count is zero.
- The success message appears.
- Refreshing does not restore the cleared tasks.

---

# 17. Manual Test M-013: Malformed JSON

Run:

```javascript
localStorage.setItem(
  "async-task-manager.tasks.v1",
  "{not valid JSON"
);
```

Refresh the page.

## Expected Result

Verify:

- The application does not silently crash.
- An error status appears.
- The console includes a storage error.
- The rest of the page remains usable.

Clean up:

```javascript
localStorage.removeItem(
  "async-task-manager.tasks.v1"
);

location.reload();
```

---

# 18. Manual Test M-014: Malformed Task Records

Run:

```javascript
localStorage.setItem(
  "async-task-manager.tasks.v1",
  JSON.stringify([
    {
      id: 1,
      title: "Valid task",
      completed: false,
      createdAt: new Date().toISOString()
    },
    {
      id: "invalid-id",
      title: "",
      completed: "not-a-boolean",
      createdAt: "invalid-date"
    }
  ])
);
```

Refresh the page.

## Expected Result

Verify:

- `Valid task` appears.
- The malformed task is ignored.
- A warning appears in the console.
- The application remains usable.

Clean up afterward.

---

# 19. Manual Test M-015: XSS-Safe Rendering

## Action

Enter this as a task title:

```html
<img src="invalid" onerror="alert('unexpected script')">
```

## Expected Result

The application should display the characters as text.

It must not:

- Create an image element.
- Execute the `onerror` handler.
- Display an alert.

The implementation should use:

```javascript
title.textContent = task.title;
```

not:

```javascript
title.innerHTML = task.title;
```

---

# 20. Manual Test M-016: Keyboard Accessibility

Test using only the keyboard.

1. Focus the task input.
2. Type a task title.
3. Press `Tab`.
4. Press `Enter` to submit where appropriate.
5. Tab through buttons.
6. Activate buttons with `Enter` or `Space`.
7. Use the filter without a mouse.

## Expected Result

Verify:

- Focus is visible.
- All interactive controls are reachable.
- Buttons can be activated with the keyboard.
- The input remains usable.
- Status messages are available to assistive technology.

---

# 21. Unit Testing Without a Framework

The project can use a minimal custom test harness before introducing a testing library.

## The Target

Create a reusable assertion helper.

## The Implementation

### `js/test-utils/assert.js`

```javascript
"use strict";

export function assert(condition, message) {
  if (!condition) {
    throw new Error(`Assertion failed: ${message}`);
  }
}

export function assertEqual(actual, expected, message) {
  if (actual !== expected) {
    throw new Error(
      `${message}\nExpected: ${expected}\nActual: ${actual}`
    );
  }
}

export function assertThrows(callback, message) {
  let didThrow = false;

  try {
    callback();
  } catch {
    didThrow = true;
  }

  if (!didThrow) {
    throw new Error(
      `Expected function to throw: ${message}`
    );
  }
}
```

Create the directory:

### macOS or Linux

```bash
mkdir -p js/test-utils
```

### Windows PowerShell

```powershell
New-Item -ItemType Directory -Force -Path js/test-utils
```

---

# 22. Unit Test the Task Model

## The Target

Test `Task` behavior independently from the DOM.

## The Implementation

### `js/task-model.test.js`

```javascript
import { Task } from "./models/task.js";
import {
  assert,
  assertEqual,
  assertThrows,
} from "./test-utils/assert.js";

function testTaskConstruction() {
  const task = new Task({
    id: 1,
    title: "Learn testing",
  });

  assert(
    task instanceof Task,
    "A new task is a Task instance"
  );

  assertEqual(
    task.title,
    "Learn testing",
    "The title is stored"
  );

  assertEqual(
    task.completed,
    false,
    "A task starts incomplete"
  );
}

function testTaskCompletion() {
  const task = new Task({
    id: 2,
    title: "Complete a task",
  });

  task.complete();

  assertEqual(
    task.isCompleted(),
    true,
    "complete() marks a task complete"
  );

  task.reopen();

  assertEqual(
    task.isCompleted(),
    false,
    "reopen() marks a task incomplete"
  );

  task.toggleCompletion();

  assertEqual(
    task.isCompleted(),
    true,
    "toggleCompletion() changes completion state"
  );
}

function testTaskValidation() {
  assertThrows(
    () =>
      new Task({
        id: 3,
        title: "",
      }),
    "Empty title should be rejected"
  );

  assertThrows(
    () =>
      new Task({
        id: 4,
        title: "a".repeat(121),
      }),
    "Titles over 120 characters should be rejected"
  );

  assertThrows(
    () =>
      new Task({
        id: -1,
        title: "Invalid identifier",
      }),
    "Negative IDs should be rejected"
  );

  assertThrows(
    () =>
      new Task({
        id: 5,
        title: "Invalid completion",
        completed: "false",
      }),
    "Non-Boolean completion state should be rejected"
  );
}

function testTaskSerialization() {
  const task = new Task({
    id: 6,
    title: "Serialize a task",
    completed: true,
  });

  const serialized = task.toJSON();

  assertEqual(
    serialized.id,
    6,
    "Serialization includes the ID"
  );

  assertEqual(
    serialized.title,
    "Serialize a task",
    "Serialization includes the title"
  );

  assertEqual(
    serialized.completed,
    true,
    "Serialization includes completion state"
  );

  const restored = Task.fromJSON(serialized);

  assert(
    restored instanceof Task,
    "fromJSON() restores a Task instance"
  );

  assertEqual(
    restored.title,
    task.title,
    "Restored task has the original title"
  );

  assertEqual(
    restored.isCompleted(),
    task.isCompleted(),
    "Restored task has the original state"
  );
}

function runTests() {
  testTaskConstruction();
  testTaskCompletion();
  testTaskValidation();
  testTaskSerialization();

  console.log("Task model tests passed.");
}

runTests();
```

## The Verification

Temporarily change `index.html`:

```html
<script
  type="module"
  src="./js/task-model.test.js"
></script>
```

Open the application through the local server.

Expected output:

```text
Task model tests passed.
```

Restore:

```html
<script type="module" src="./js/main.js"></script>
```

Delete the test file and test utility directory if you do not want to keep the custom harness.

---

# 23. Unit Test the Task Service

## The Target

Test task business operations without the browser UI.

## The Implementation

### `js/task-service.test.js`

```javascript
import { Task } from "./models/task.js";
import { TaskService } from "./services/task-service.js";
import {
  assert,
  assertEqual,
  assertThrows,
} from "./test-utils/assert.js";

function testAddingTasks() {
  const service = new TaskService();

  const task = service.add("Add a service task");

  assert(
    task instanceof Task,
    "The service creates a Task instance"
  );

  assertEqual(
    service.getAll().length,
    1,
    "The service contains one task"
  );

  assertEqual(
    service.getAll()[0].title,
    "Add a service task",
    "The added title is stored"
  );
}

function testTogglingTasks() {
  const service = new TaskService();

  const task = service.add("Toggle this task");

  assertEqual(
    task.isCompleted(),
    false,
    "New task is incomplete"
  );

  service.toggle(task.id);

  assertEqual(
    task.isCompleted(),
    true,
    "toggle() completes the task"
  );

  service.toggle(task.id);

  assertEqual(
    task.isCompleted(),
    false,
    "toggle() reopens the task"
  );
}

function testFilteringTasks() {
  const service = new TaskService();

  const activeTask = service.add("Active task");
  const completedTask = service.add("Completed task");

  service.toggle(completedTask.id);

  assertEqual(
    service.getByFilter("all").length,
    2,
    "All filter returns every task"
  );

  assertEqual(
    service.getByFilter("active").length,
    1,
    "Active filter returns one task"
  );

  assertEqual(
    service.getByFilter("active")[0].id,
    activeTask.id,
    "Active filter returns the correct task"
  );

  assertEqual(
    service.getByFilter("completed").length,
    1,
    "Completed filter returns one task"
  );

  assertEqual(
    service.getByFilter("completed")[0].id,
    completedTask.id,
    "Completed filter returns the correct task"
  );
}

function testRemovingTasks() {
  const service = new TaskService();

  const task = service.add("Remove this task");

  service.remove(task.id);

  assertEqual(
    service.getAll().length,
    0,
    "remove() deletes the task"
  );

  assertThrows(
    () => service.remove(task.id),
    "Removing a missing task should throw"
  );
}

function testInvalidTitles() {
  const service = new TaskService();

  assertThrows(
    () => service.add(""),
    "Empty task titles should be rejected"
  );

  assertThrows(
    () => service.add("   "),
    "Whitespace-only titles should be rejected"
  );
}

function runTests() {
  testAddingTasks();
  testTogglingTasks();
  testFilteringTasks();
  testRemovingTasks();
  testInvalidTitles();

  console.log("Task service tests passed.");
}

runTests();
```

## The Verification

Temporarily load the test file from `index.html`.

Expected output:

```text
Task service tests passed.
```

Restore the application entry point afterward.

---

# 24. Testing Asynchronous Functions

Asynchronous tests must wait for the operation to finish.

## Incorrect Pattern

```javascript
function testLoading() {
  fetchExampleTasks().then((tasks) => {
    console.log(tasks);
  });

  console.log("Test finished");
}
```

`Test finished` may appear before the Promise resolves.

## Correct Pattern

```javascript
async function testLoading() {
  const tasks = await fetchExampleTasks();

  console.assert(
    tasks.length === 3,
    "Expected three example tasks"
  );

  console.log("Async test finished");
}
```

Call it with error handling:

```javascript
testLoading().catch((error) => {
  console.error("Async test failed:", error);
});
```

---

# 25. Test the Asynchronous API

## The Target

Test both success and failure paths of `fetchExampleTasks()`.

## The Implementation

### `js/task-api.test.js`

```javascript
import { fetchExampleTasks } from "./api/task-api.js";
import {
  assert,
  assertEqual,
} from "./test-utils/assert.js";

async function testSuccessfulRequest() {
  const tasks = await fetchExampleTasks();

  assertEqual(
    tasks.length,
    3,
    "Successful API request returns three tasks"
  );

  assert(
    tasks.every((task) => typeof task.title === "string"),
    "Every returned task has a title"
  );
}

async function testFailedRequest() {
  let didReject = false;

  try {
    await fetchExampleTasks({
      shouldFail: true,
    });
  } catch (error) {
    didReject = true;

    assertEqual(
      error.message,
      "The example task API could not load the tasks.",
      "API failure has the expected message"
    );
  }

  assert(
    didReject,
    "The API rejects when shouldFail is true"
  );
}

async function runTests() {
  await testSuccessfulRequest();
  await testFailedRequest();

  console.log("Task API tests passed.");
}

runTests().catch((error) => {
  console.error("Task API tests failed:", error);
});
```

## The Verification

Load the test file through `index.html`.

Expected output appears after approximately 1.2 seconds:

```text
Task API tests passed.
```

---

# 26. Testing Storage Safely

Storage tests need to avoid corrupting real application data.

Use a unique test key or clear test state before and after each test.

## The Implementation

### `js/storage-service.test.js`

```javascript
import { Task } from "./models/task.js";
import {
  clearTasks,
  loadTasks,
  saveTasks,
} from "./services/storage-service.js";
import {
  assert,
  assertEqual,
} from "./test-utils/assert.js";

function testEmptyStorage() {
  clearTasks();

  const tasks = loadTasks();

  assert(
    Array.isArray(tasks),
    "Empty storage returns an array"
  );

  assertEqual(
    tasks.length,
    0,
    "Empty storage returns no tasks"
  );
}

function testSaveAndRestore() {
  const originalTasks = [
    new Task({
      id: 100,
      title: "Save this task",
      completed: true,
    }),
  ];

  saveTasks(originalTasks);

  const restoredTasks = loadTasks();

  assertEqual(
    restoredTasks.length,
    1,
    "One task is restored"
  );

  assert(
    restoredTasks[0] instanceof Task,
    "Restored value is a Task instance"
  );

  assertEqual(
    restoredTasks[0].title,
    "Save this task",
    "The title is restored"
  );

  assertEqual(
    restoredTasks[0].isCompleted(),
    true,
    "The completion state is restored"
  );
}

function testClearStorage() {
  saveTasks([
    new Task({
      id: 101,
      title: "Clear this task",
    }),
  ]);

  clearTasks();

  assertEqual(
    loadTasks().length,
    0,
    "Clearing storage removes all tasks"
  );
}

function runTests() {
  try {
    testEmptyStorage();
    testSaveAndRestore();
    testClearStorage();

    console.log("Storage service tests passed.");
  } finally {
    /*
     * Always clean up test data, even if an assertion fails.
     */
    clearTasks();
  }
}

runTests();
```

## The Verification

Load the test file.

Expected output:

```text
Storage service tests passed.
```

Inspect `localStorage` afterward. The test key should not leave application tasks behind.

---

# 27. Testing the UI

UI tests require a DOM environment.

A browser-based manual test is appropriate for this project’s native UI modules.

You can also create a temporary test page that provides the required DOM.

## The Target

Verify that `renderTaskList()` creates:

- A task title.
- A status label.
- A completion button.
- A delete button.

## The Implementation

### `ui-test.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>UI Test</title>
  </head>

  <body>
    <ul id="test-task-list"></ul>

    <script type="module">
      import { Task } from "./js/models/task.js";
      import { renderTaskList } from "./js/ui/task-list.js";

      const taskList = document.querySelector(
        "#test-task-list"
      );

      const tasks = [
        new Task({
          id: 1,
          title: "Render this task",
        }),
      ];

      let toggleId = null;
      let deleteId = null;

      renderTaskList(taskList, tasks, {
        onToggle: (taskId) => {
          toggleId = taskId;
          console.log("Toggle callback:", taskId);
        },
        onDelete: (taskId) => {
          deleteId = taskId;
          console.log("Delete callback:", taskId);
        },
      });

      console.assert(
        taskList.querySelector(".task-title")
          .textContent === "Render this task",
        "Task title should render"
      );

      console.assert(
        taskList.querySelectorAll("button").length === 2,
        "Task should have two action buttons"
      );

      const buttons = taskList.querySelectorAll("button");

      buttons[0].click();
      buttons[1].click();

      console.assert(
        toggleId === 1,
        "Toggle callback should receive task ID"
      );

      console.assert(
        deleteId === 1,
        "Delete callback should receive task ID"
      );

      console.log("UI test passed.");
    </script>
  </body>
</html>
```

## The Verification

Open:

```text
http://localhost:8000/ui-test.html
```

Expected console output:

```text
Toggle callback: 1
Delete callback: 1
UI test passed.
```

Delete the temporary test page afterward.

---

# 28. Testing Empty UI State

Create a task-list test with no tasks:

```javascript
renderTaskList(taskList, [], {
  onToggle: () => {},
  onDelete: () => {},
});
```

Verify:

```javascript
const emptyMessage =
  taskList.querySelector(".empty-state");

console.assert(
  emptyMessage !== null,
  "Empty state should render"
);

console.assert(
  emptyMessage.textContent ===
    "No tasks match the selected filter.",
  "Empty state should have the correct message"
);
```

---

# 29. Testing Unsafe HTML Input

A UI test should verify that user input is not interpreted as markup.

```javascript
const maliciousTitle =
  "<img src=x onerror=alert('bad')>";

const task = new Task({
  id: 1,
  title: maliciousTitle,
});

renderTaskList(taskList, [task], {
  onToggle: () => {},
  onDelete: () => {},
});

const titleElement =
  taskList.querySelector(".task-title");

console.assert(
  titleElement.textContent === maliciousTitle,
  "User input should render as text"
);

console.assert(
  titleElement.querySelector("img") === null,
  "User input should not create an image element"
);
```

This test protects an important security property.

---

# 30. Test Isolation

A test should not depend on another test’s previous state.

Bad:

```javascript
function testSecondFeature() {
  /*
   * Assumes testFirstFeature already added a task.
   */
}
```

Good:

```javascript
function testSecondFeature() {
  const service = new TaskService();

  service.add("Independent test task");

  /*
   * This test creates its own state.
   */
}
```

For storage tests:

```javascript
function beforeEachTest() {
  clearTasks();
}

function afterEachTest() {
  clearTasks();
}
```

Isolation makes tests predictable.

---

# 31. Arrange, Act, Assert

A common test structure is:

```text
Arrange
Act
Assert
```

## Arrange

Set up the state:

```javascript
const service = new TaskService();
```

## Act

Perform the behavior:

```javascript
const task = service.add("Test task");
```

## Assert

Check the result:

```javascript
assertEqual(
  task.title,
  "Test task",
  "The task title is correct"
);
```

Complete example:

```javascript
function testAddingTask() {
  // Arrange
  const service = new TaskService();

  // Act
  const task = service.add("Test task");

  // Assert
  assertEqual(
    task.title,
    "Test task",
    "The title is stored"
  );
}
```

This structure makes tests easier to read.

---

# 32. Test Names Should Describe Behavior

Weak test name:

```javascript
test1();
```

Better:

```javascript
testEmptyTaskTitleIsRejected();
```

Even better, if using a test framework:

```javascript
it("rejects an empty task title", () => {
});
```

A test name should explain:

- What behavior is being tested.
- Under what condition.
- What should happen.

---

# 33. Testing Error Messages

Error messages can be part of the user-facing contract.

```javascript
assertThrows(
  () => service.add(""),
  "Empty task title should be rejected"
);
```

If the exact message matters:

```javascript
try {
  service.add("");
  throw new Error(
    "Expected add() to reject an empty title."
  );
} catch (error) {
  assertEqual(
    error.message,
    "Task title cannot be empty.",
    "Empty title has the expected message"
  );
}
```

Avoid over-testing implementation details. Prefer testing observable behavior.

---

# 34. Testing Error Types

Custom error classes can be checked:

```javascript
import { ValidationError } from "./utils/errors.js";

try {
  validateTaskTitle("");
} catch (error) {
  console.assert(
    error instanceof ValidationError,
    "The error should be a ValidationError"
  );
}
```

This is useful when different errors require different handling.

---

# 35. Testing Promise Cleanup

A loading operation must restore the UI after both success and failure.

A conceptual test:

```javascript
async function testCleanupAfterFailure() {
  let isLoading = false;

  try {
    isLoading = true;

    await Promise.reject(
      new Error("Expected failure")
    );
  } catch {
    // Expected failure.
  } finally {
    isLoading = false;
  }

  console.assert(
    isLoading === false,
    "Loading state should be reset"
  );
}
```

The real application test should verify:

- The button is disabled during the request.
- The button is enabled afterward.
- This occurs on success.
- This occurs on failure.

---

# 36. Testing Duplicate Request Protection

The application has:

```javascript
if (this.isLoading) {
  return;
}
```

A test should call the operation twice quickly and verify that only one request starts.

A simple API counter:

```javascript
let requestCount = 0;

function fakeLoadTasks() {
  requestCount += 1;

  return new Promise((resolve) => {
    setTimeout(() => {
      resolve([]);
    }, 100);
  });
}
```

Test:

```javascript
async function testDuplicateProtection() {
  let isLoading = false;

  async function loadOnce() {
    if (isLoading) {
      return;
    }

    isLoading = true;

    try {
      await fakeLoadTasks();
    } finally {
      isLoading = false;
    }
  }

  await Promise.all([
    loadOnce(),
    loadOnce(),
  ]);

  console.assert(
    requestCount === 1,
    "Only one request should start"
  );
}
```

---

# 37. Testing Stale Response Protection

```javascript
let latestRequestId = 0;
let renderedValue = null;

async function loadValue(requestPromise) {
  const requestId = ++latestRequestId;
  const value = await requestPromise;

  if (requestId !== latestRequestId) {
    return;
  }

  renderedValue = value;
}
```

Test with controlled delays:

```javascript
function delayedValue(value, delay) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(value);
    }, delay);
  });
}

async function testStaleResponseProtection() {
  const first = loadValue(
    delayedValue("old result", 200)
  );

  const second = loadValue(
    delayedValue("new result", 50)
  );

  await Promise.all([first, second]);

  console.assert(
    renderedValue === "new result",
    "The newest result should remain rendered"
  );
}
```

---

# 38. Browser Compatibility Testing

Test the application in the browsers your audience uses.

Recommended browsers:

- Chrome or Chromium.
- Firefox.
- Safari.
- Edge.

Check:

- ES module loading.
- `localStorage`.
- `sessionStorage`.
- `fetch`.
- `AbortController` if used.
- CSS layout.
- Focus behavior.
- Screen-reader output.

Do not assume that behavior in one browser proves behavior everywhere.

---

# 39. Responsive Testing

Use browser responsive design tools.

Test widths such as:

```text
320px
375px
768px
1024px
1440px
```

Verify:

- The input remains usable.
- Buttons do not overflow.
- Task actions remain reachable.
- Text wraps correctly.
- The task list remains readable.
- Focus indicators remain visible.

The stylesheet includes a mobile breakpoint:

```css
@media (max-width: 600px) {
}
```

Test both sides of that breakpoint.

---

# 40. Accessibility Testing

Manual keyboard testing should be combined with automated tools where available.

Check:

- Every input has a label.
- Buttons have meaningful text.
- Status updates use `aria-live`.
- Focus is visible.
- Color is not the only status signal.
- Text has adequate contrast.
- The page has a logical heading structure.
- Interactive controls are keyboard accessible.

The task form uses:

```html
<label for="task-title">Task title</label>
```

The status uses:

```html
<p
  id="status-message"
  role="status"
  aria-live="polite"
>
```

These attributes help assistive technologies understand changes.

---

# 41. Test Coverage

Coverage measures which code was executed by tests.

Useful coverage categories include:

- Line coverage.
- Branch coverage.
- Function coverage.
- Statement coverage.

High coverage does not guarantee correct software.

This test could execute a line without verifying useful behavior:

```javascript
console.log("Executed");
```

Good tests assert meaningful outcomes.

Focus first on:

- Important business rules.
- Error branches.
- Persistence behavior.
- Security-sensitive output.
- Asynchronous cleanup.
- User-critical workflows.

---

# 42. What Not to Over-Test

Avoid testing implementation details that users and callers cannot observe.

Fragile test:

```javascript
assert(
  taskService.tasks.length === 1,
  "Internal array length is one"
);
```

Better:

```javascript
assertEqual(
  taskService.getAll().length,
  1,
  "The service returns one task"
);
```

The second test checks behavior through the public interface.

If the internal storage changes later, the better test can remain valid.

---

# 43. Test Doubles

A test double replaces a real dependency during testing.

Common types include:

- Stub.
- Mock.
- Fake.
- Spy.

## Fake API

```javascript
function createFakeApi(tasks) {
  return {
    fetchExampleTasks() {
      return Promise.resolve(tasks);
    },
  };
}
```

## Failure Stub

```javascript
function createFailingApi() {
  return {
    fetchExampleTasks() {
      return Promise.reject(
        new Error("Fake API failure")
      );
    },
  };
}
```

Test doubles make it possible to test failure paths reliably without waiting for real network errors.

---

# 44. Dependency Injection

The final `App` class imports its dependencies directly. A larger application can make dependencies replaceable by passing them into the constructor.

Example:

```javascript
export class TestableApp {
  constructor({
    taskService,
    api,
    storage,
  }) {
    this.taskService = taskService;
    this.api = api;
    this.storage = storage;
  }
}
```

Production construction:

```javascript
const app = new TestableApp({
  taskService: new TaskService(),
  api: {
    fetchExampleTasks,
  },
  storage: {
    loadTasks,
    saveTasks,
    clearTasks,
  },
});
```

Test construction:

```javascript
const app = new TestableApp({
  taskService: new TaskService(),
  api: createFakeApi([]),
  storage: createFakeStorage(),
});
```

Dependency injection reduces coupling and improves testing.

---

# 45. A Complete Manual Regression Checklist

Use this checklist after significant changes.

## Startup

- [ ] Page loads through HTTP.
- [ ] No module errors.
- [ ] No uncaught exceptions.
- [ ] Status message appears.
- [ ] Stored data restores.

## Task Creation

- [ ] Valid title is accepted.
- [ ] Leading whitespace is removed.
- [ ] Empty title is rejected.
- [ ] Whitespace-only title is rejected.
- [ ] Maximum-length title is accepted.
- [ ] Oversized title is rejected.

## Task Actions

- [ ] Active task can be completed.
- [ ] Completed task can be reopened.
- [ ] Task can be deleted.
- [ ] Missing task produces an error.

## Filtering

- [ ] All filter works.
- [ ] Active filter works.
- [ ] Completed filter works.
- [ ] Filter preference is saved.

## Persistence

- [ ] Add persists after refresh.
- [ ] Completion persists after refresh.
- [ ] Deletion persists after refresh.
- [ ] Clear removes persisted data.
- [ ] Malformed JSON is handled.
- [ ] Malformed records are handled.

## Asynchronous Behavior

- [ ] Loading message appears.
- [ ] Button is disabled during loading.
- [ ] Duplicate requests are prevented.
- [ ] Successful response renders.
- [ ] Failed response displays an error.
- [ ] Button is restored after failure.
- [ ] Button is restored after success.

## Security

- [ ] User text is rendered with `textContent`.
- [ ] User text does not execute HTML.
- [ ] No secrets are stored in browser storage.
- [ ] Stored data is validated.

## Accessibility

- [ ] Keyboard navigation works.
- [ ] Focus is visible.
- [ ] Labels are associated with inputs.
- [ ] Status changes are announced.
- [ ] Buttons have meaningful names.

---

# 46. Test Completion Criteria

The application is ready for the next stage when:

- Critical user workflows pass.
- Error paths have been tested.
- Storage behavior has been tested.
- Asynchronous cleanup has been tested.
- Security-sensitive rendering has been tested.
- The application works after refresh.
- No uncaught console errors remain.
- The code can be refactored without losing confidence.
- Tests can be repeated consistently.
