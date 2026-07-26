# Appendix D: Browser Storage Reference

This appendix explains the browser storage APIs used by the Async Task Manager.

You will learn:

- What browser storage is.
- How `localStorage` works.
- How `sessionStorage` works.
- How to store objects and arrays with JSON.
- How to validate stored data.
- How to handle malformed data.
- How to handle storage failures.
- How storage is scoped by origin.
- What browser storage should and should not contain.
- When to consider IndexedDB instead.

---

# 1. What Browser Storage Is

Browser storage allows a web application to save data on the user’s device.

Without storage, application state exists only in memory:

```javascript
let tasks = [];
```

If the user refreshes the page, the array is recreated and the data disappears.

With `localStorage`, the application can save the data:

```javascript
localStorage.setItem("tasks", "...");
```

The browser keeps the value after refreshes and usually after the browser is closed and reopened.

A useful analogy is:

- JavaScript memory is a whiteboard.
- `sessionStorage` is a temporary desk drawer.
- `localStorage` is a filing cabinet.
- IndexedDB is a small local database.

---

# 2. Storage APIs

The two simple key-value storage APIs are:

```javascript
localStorage
sessionStorage
```

Both APIs use the same basic interface:

```javascript
setItem(key, value)
getItem(key)
removeItem(key)
clear()
key(index)
length
```

The important limitation is that both APIs store strings.

This is valid:

```javascript
localStorage.setItem("username", "Ada");
```

This is not a reliable way to store an object:

```javascript
localStorage.setItem("task", {
  title: "Learn storage",
});
```

The object is converted to an unhelpful string:

```text
[object Object]
```

Use JSON for structured values.

---

# 3. `localStorage`

## The Target

Store a value that survives page reloads.

## The Implementation

Open the browser developer console on your application’s origin and run:

```javascript
localStorage.setItem(
  "async-task-manager.example",
  "persistent value"
);
```

Read the value:

```javascript
const value = localStorage.getItem(
  "async-task-manager.example"
);

console.log(value);
```

Remove the value:

```javascript
localStorage.removeItem(
  "async-task-manager.example"
);
```

## The Verification

Run:

```javascript
localStorage.setItem(
  "async-task-manager.example",
  "persistent value"
);
```

Refresh the page, then run:

```javascript
localStorage.getItem(
  "async-task-manager.example"
);
```

Expected result:

```text
persistent value
```

Clean up:

```javascript
localStorage.removeItem(
  "async-task-manager.example"
);
```

---

# 4. `sessionStorage`

## The Target

Store a value for the current browser tab session.

## The Concept

`sessionStorage` is useful for temporary state such as:

- A selected filter.
- A multi-step form’s current step.
- A temporary sorting preference.
- A tab-specific UI setting.

Unlike `localStorage`, `sessionStorage` is associated with the current page session and tab.

## The Implementation

Run:

```javascript
sessionStorage.setItem(
  "async-task-manager.example",
  "temporary value"
);
```

Read it:

```javascript
const value = sessionStorage.getItem(
  "async-task-manager.example"
);

console.log(value);
```

Remove it:

```javascript
sessionStorage.removeItem(
  "async-task-manager.example"
);
```

## The Verification

Run:

```javascript
sessionStorage.setItem(
  "async-task-manager.example",
  "temporary value"
);
```

Refresh the current page and run:

```javascript
sessionStorage.getItem(
  "async-task-manager.example"
);
```

Expected result:

```text
temporary value
```

Remove the value:

```javascript
sessionStorage.removeItem(
  "async-task-manager.example"
);
```

---

# 5. Storage Keys

Storage values are accessed by string keys:

```javascript
localStorage.setItem("theme", "dark");
```

Key names should be:

- Descriptive.
- Stable.
- Namespaced.
- Versioned when the data format may change.

A weak key:

```javascript
"data"
```

A clearer key:

```javascript
"async-task-manager.tasks.v1"
```

The project uses:

```javascript
const TASKS_STORAGE_KEY = "async-task-manager.tasks.v1";
const FILTER_SESSION_KEY = "async-task-manager.filter.v1";
```

The application prefix reduces the chance of collisions with other features.

The version suffix makes future migrations possible:

```text
async-task-manager.tasks.v1
async-task-manager.tasks.v2
```

---

# 6. Storing Primitive Values

## Strings

```javascript
localStorage.setItem("language", "en");
```

## Numbers

Storage still stores the number as text:

```javascript
localStorage.setItem("task-count", "5");

const rawCount = localStorage.getItem("task-count");
const count = Number(rawCount);

console.log(count);
console.log(typeof count);
```

Output:

```text
5
number
```

## Booleans

Boolean values must be converted manually:

```javascript
localStorage.setItem("dark-mode", "true");

const isDarkMode =
  localStorage.getItem("dark-mode") === "true";

console.log(isDarkMode);
// true
```

Do not use:

```javascript
Boolean("false");
```

That returns `true` because every non-empty string is truthy.

---

# 7. Storing Objects with JSON

## The Target

Store a task object as JSON text.

## The Implementation

```javascript
const task = {
  id: 1,
  title: "Learn browser storage",
  completed: false,
};

const serializedTask = JSON.stringify(task);

localStorage.setItem(
  "async-task-manager.task.v1",
  serializedTask
);
```

Read the value:

```javascript
const rawTask = localStorage.getItem(
  "async-task-manager.task.v1"
);

if (rawTask !== null) {
  const restoredTask = JSON.parse(rawTask);

  console.log(restoredTask);
}
```

## The Verification

Run:

```javascript
localStorage.getItem(
  "async-task-manager.task.v1"
);
```

You should see JSON text similar to:

```json
{"id":1,"title":"Learn browser storage","completed":false}
```

Then run:

```javascript
const rawTask = localStorage.getItem(
  "async-task-manager.task.v1"
);

const restoredTask = JSON.parse(rawTask);

console.log(restoredTask.title);
```

Expected output:

```text
Learn browser storage
```

Clean up:

```javascript
localStorage.removeItem(
  "async-task-manager.task.v1"
);
```

---

# 8. Storing Arrays

```javascript
const tasks = [
  {
    id: 1,
    title: "First task",
    completed: false,
  },
  {
    id: 2,
    title: "Second task",
    completed: true,
  },
];

localStorage.setItem(
  "async-task-manager.tasks.v1",
  JSON.stringify(tasks)
);
```

Restore the array:

```javascript
const rawTasks = localStorage.getItem(
  "async-task-manager.tasks.v1"
);

const restoredTasks =
  rawTasks === null ? [] : JSON.parse(rawTasks);

console.log(restoredTasks);
```

Always verify that parsed data has the expected type:

```javascript
if (!Array.isArray(restoredTasks)) {
  throw new Error("Stored tasks must be an array.");
}
```

---

# 9. Safe JSON Parsing

`JSON.parse()` throws when the input is invalid.

Unsafe:

```javascript
const value = JSON.parse(rawValue);
```

If `rawValue` contains malformed JSON, the application can fail.

## Basic Safe Parser

```javascript
export function parseJSONSafely(rawValue) {
  try {
    return JSON.parse(rawValue);
  } catch {
    return null;
  }
}
```

Usage:

```javascript
const rawValue = localStorage.getItem("settings");

if (rawValue === null) {
  console.log("No settings saved.");
} else {
  const settings = parseJSONSafely(rawValue);

  if (settings === null) {
    console.error("Saved settings are invalid.");
  } else {
    console.log(settings);
  }
}
```

Returning `null` is convenient, but it loses information about the failure.

For application code, a descriptive error is often better.

## Error-Preserving Parser

```javascript
export function parseStoredJSON(
  rawValue,
  storageName
) {
  if (rawValue === null) {
    return null;
  }

  try {
    return JSON.parse(rawValue);
  } catch (error) {
    throw new Error(
      `Data in ${storageName} is not valid JSON.`,
      { cause: error }
    );
  }
}
```

---

# 10. Restoring Class Instances

JSON does not preserve a class prototype.

Consider:

```javascript
class Task {
  constructor(title) {
    this.title = title;
  }

  complete() {
    console.log("Completed");
  }
}

const originalTask = new Task("Learn classes");

const text = JSON.stringify(originalTask);
const parsedTask = JSON.parse(text);

console.log(parsedTask instanceof Task);
// false
```

`parsedTask` is an ordinary object.

The methods are not restored:

```javascript
parsedTask.complete();
```

This fails because `complete` is not present on the parsed object.

## Use a Static Restoration Method

```javascript
class Task {
  constructor(title) {
    this.title = title;
  }

  complete() {
    console.log("Completed");
  }

  static fromJSON(value) {
    return new Task(value.title);
  }
}
```

Restore the instance:

```javascript
const restoredTask = Task.fromJSON(parsedTask);

console.log(restoredTask instanceof Task);
// true

restoredTask.complete();
```

The final task manager uses this pattern:

```javascript
const restoredTask = Task.fromJSON(storedValue);
```

---

# 11. Validating Stored Data

Stored data should be treated as external input.

It may have been:

- Manually changed in developer tools.
- Created by an older application version.
- Partially written.
- Corrupted.
- Created by a buggy previous release.
- Produced by another script on the same origin.

Do not trust this:

```javascript
const tasks = JSON.parse(rawValue);
```

Validate the outer structure:

```javascript
if (!Array.isArray(tasks)) {
  throw new Error("Stored task data must be an array.");
}
```

Validate each record:

```javascript
function isStoredTask(value) {
  return (
    typeof value === "object" &&
    value !== null &&
    Number.isInteger(value.id) &&
    typeof value.title === "string" &&
    typeof value.completed === "boolean" &&
    typeof value.createdAt === "string"
  );
}
```

Use it:

```javascript
const validTasks = tasks.filter(isStoredTask);
```

For stronger validation, reconstruct the domain object:

```javascript
const restoredTasks = [];

for (const value of tasks) {
  try {
    restoredTasks.push(Task.fromJSON(value));
  } catch (error) {
    console.warn("Ignoring invalid task:", error);
  }
}
```

This ensures the same validation rules apply to:

- New tasks.
- API tasks.
- Stored tasks.

---

# 12. A Complete Safe Storage Helper

## The Target

Create a reusable storage helper with safe access and JSON handling.

## The Implementation

### `safe-storage.js`

```javascript
"use strict";

export class SafeStorage {
  constructor(storage) {
    if (!storage) {
      throw new TypeError("A storage object is required.");
    }

    this.storage = storage;
  }

  getText(key) {
    try {
      return this.storage.getItem(key);
    } catch (error) {
      throw new Error(
        `Could not read storage key "${key}".`,
        { cause: error }
      );
    }
  }

  setText(key, value) {
    if (typeof value !== "string") {
      throw new TypeError("Storage values must be strings.");
    }

    try {
      this.storage.setItem(key, value);
    } catch (error) {
      throw new Error(
        `Could not write storage key "${key}".`,
        { cause: error }
      );
    }
  }

  remove(key) {
    try {
      this.storage.removeItem(key);
    } catch (error) {
      throw new Error(
        `Could not remove storage key "${key}".`,
        { cause: error }
      );
    }
  }

  getJSON(key, fallback = null) {
    const rawValue = this.getText(key);

    if (rawValue === null) {
      return fallback;
    }

    try {
      return JSON.parse(rawValue);
    } catch (error) {
      throw new Error(
        `Storage key "${key}" does not contain valid JSON.`,
        { cause: error }
      );
    }
  }

  setJSON(key, value) {
    let serializedValue;

    try {
      serializedValue = JSON.stringify(value);
    } catch (error) {
      throw new Error(
        `Could not serialize value for "${key}".`,
        { cause: error }
      );
    }

    this.setText(key, serializedValue);
  }
}
```

## The Verification

Create:

### `safe-storage-demo.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>Safe Storage Demo</title>
  </head>

  <body>
    <h1>Open the browser console</h1>

    <script type="module">
      import { SafeStorage } from "./safe-storage.js";

      const storage = new SafeStorage(localStorage);

      storage.setJSON("demo.settings", {
        theme: "light",
        filter: "all",
      });

      console.log(
        storage.getJSON("demo.settings")
      );

      storage.remove("demo.settings");

      console.log(
        storage.getJSON("demo.settings", {})
      );
    </script>
  </body>
</html>
```

Expected output:

```javascript
{
  theme: "light",
  filter: "all"
}
{}
```

Delete the temporary files after testing.

---

# 13. Storage Errors

Storage methods can throw exceptions.

Potential causes include:

- Private browsing restrictions.
- Disabled storage.
- Browser security policies.
- Quota exhaustion.
- User privacy settings.
- An invalid storage context.

Wrap storage operations when failure matters:

```javascript
function saveSettings(settings) {
  try {
    localStorage.setItem(
      "settings",
      JSON.stringify(settings)
    );
  } catch (error) {
    console.error("Settings could not be saved:", error);
  }
}
```

For a service layer, use a custom error:

```javascript
class StorageError extends Error {
  constructor(message, options = {}) {
    super(message, options);
    this.name = "StorageError";
  }
}
```

Then:

```javascript
function saveSettings(settings) {
  try {
    localStorage.setItem(
      "settings",
      JSON.stringify(settings)
    );
  } catch (error) {
    throw new StorageError(
      "Settings could not be saved.",
      { cause: error }
    );
  }
}
```

The UI can display a user-friendly message while the original error remains available as `error.cause`.

---

# 14. Quota Errors

Storage capacity is limited.

This operation may fail:

```javascript
try {
  localStorage.setItem(
    "large-value",
    veryLargeString
  );
} catch (error) {
  console.error("Storage quota may be full:", error);
}
```

Do not assume every browser provides the same limit.

Applications should:

- Store only necessary data.
- Avoid repeatedly duplicating large values.
- Remove obsolete data.
- Consider IndexedDB for larger datasets.
- Handle write failures gracefully.

---

# 15. Detecting Storage Availability

A storage object may exist but still be unusable.

Use a small test:

```javascript
export function canUseStorage(storage) {
  const testKey = "__storage_test__";

  try {
    storage.setItem(testKey, "test");
    storage.removeItem(testKey);
    return true;
  } catch {
    return false;
  }
}
```

Usage:

```javascript
if (canUseStorage(window.localStorage)) {
  console.log("localStorage is available.");
} else {
  console.warn("localStorage is unavailable.");
}
```

This test writes and removes a temporary value.

---

# 16. Origin Scope

Storage is scoped by **origin**.

An origin is generally defined by:

```text
scheme + host + port
```

These are different origins:

```text
http://localhost:8000
http://localhost:3000
https://localhost:8000
```

Their storage areas are separate.

This explains why data saved at:

```text
http://localhost:8000
```

may not appear at:

```text
http://127.0.0.1:8000
```

Even though both addresses may point to the same computer.

Use one consistent development URL when testing.

---

# 17. Storage and Multiple Tabs

If two tabs use the same origin, they can access the same `localStorage`.

The `storage` event can notify a page that another document changed storage:

```javascript
window.addEventListener("storage", (event) => {
  if (event.key !== "async-task-manager.tasks.v1") {
    return;
  }

  console.log("Tasks changed in another tab.");
  console.log("Previous value:", event.oldValue);
  console.log("New value:", event.newValue);
});
```

Important details:

- The event normally fires in other documents, not the document that made the change.
- The event includes the changed key.
- `event.newValue` is `null` when the key was removed.
- The page should reload or reconcile its state if cross-tab synchronization is required.

---

# 18. Cross-Tab Synchronization Example

```javascript
window.addEventListener("storage", (event) => {
  if (event.key !== "async-task-manager.tasks.v1") {
    return;
  }

  try {
    const updatedTasks =
      event.newValue === null
        ? []
        : JSON.parse(event.newValue);

    console.log("Tasks changed elsewhere:", updatedTasks);

    /*
     * A real application would reconstruct Task instances,
     * update its service, and re-render the visible list here.
     */
  } catch (error) {
    console.error(
      "Could not process cross-tab task update:",
      error
    );
  }
});
```

Do not blindly replace current unsaved state if the application allows local edits. Decide how conflicts should be handled.

---

# 19. Versioned Storage

The final project uses:

```javascript
"async-task-manager.tasks.v1"
```

The version is important when the data shape changes.

Suppose version 1 stores:

```json
{
  "id": 1,
  "title": "Learn storage",
  "completed": false
}
```

Version 2 adds priority:

```json
{
  "id": 1,
  "title": "Learn storage",
  "completed": false,
  "priority": "normal"
}
```

A migration can convert old records:

```javascript
function migrateTaskFromV1(value) {
  return {
    ...value,
    priority: "normal",
  };
}
```

A versioned storage strategy might use:

```javascript
const STORAGE_KEY_V1 =
  "async-task-manager.tasks.v1";

const STORAGE_KEY_V2 =
  "async-task-manager.tasks.v2";
```

Migration flow:

```javascript
function loadVersionedTasks() {
  const versionTwoData =
    localStorage.getItem(STORAGE_KEY_V2);

  if (versionTwoData !== null) {
    return JSON.parse(versionTwoData);
  }

  const versionOneData =
    localStorage.getItem(STORAGE_KEY_V1);

  if (versionOneData !== null) {
    const oldTasks = JSON.parse(versionOneData);

    const migratedTasks = oldTasks.map(
      migrateTaskFromV1
    );

    localStorage.setItem(
      STORAGE_KEY_V2,
      JSON.stringify(migratedTasks)
    );

    return migratedTasks;
  }

  return [];
}
```

For larger applications, store an explicit schema version:

```javascript
const storedData = {
  version: 2,
  tasks: [],
};
```

Then select the appropriate migration path.

---

# 20. Do Not Store Secrets

Do not store sensitive credentials in browser storage.

Avoid storing:

- Passwords.
- Private encryption keys.
- Long-lived authentication tokens when safer alternatives exist.
- Payment card numbers.
- Government identification numbers.
- Confidential personal data.

Why?

JavaScript running on the page can usually access the storage. A cross-site scripting vulnerability could expose the values.

A safer architecture generally uses:

- Server-managed sessions.
- Secure, appropriately configured cookies.
- Server-side authorization.
- Minimal client-side sensitive data.

Browser storage is suitable for application state, not secret management.

---

# 21. XSS and Stored Data

Stored data can become an injection source if rendered as HTML.

Unsafe:

```javascript
taskContainer.innerHTML = task.title;
```

If the title is:

```html
<img src="x" onerror="alert('Injected')">
```

the browser may interpret it as markup.

Safe for plain text:

```javascript
taskContainer.textContent = task.title;
```

The final task manager uses:

```javascript
title.textContent = task.title;
```

Use `innerHTML` only when:

- The content is fully controlled.
- The markup is intentionally generated.
- Dynamic values are escaped or sanitized.
- The security implications are understood.

---

# 22. Storage Does Not Validate Permissions

A user can manually modify storage:

```javascript
localStorage.setItem(
  "async-task-manager.tasks.v1",
  "..."
);
```

Therefore, never treat browser storage as proof that an operation is authorized.

For example, a client-side value such as:

```javascript
{
  "isAdmin": true
}
```

must not be trusted for server authorization.

The server must enforce permissions independently.

---

# 23. Storage Serialization and Dates

Dates are converted to strings by JSON serialization.

```javascript
const value = {
  createdAt: new Date(),
};

const text = JSON.stringify(value);

console.log(text);
```

The stored representation is text.

Restore and validate it:

```javascript
const parsed = JSON.parse(text);
const createdAt = new Date(parsed.createdAt);

if (Number.isNaN(createdAt.getTime())) {
  throw new Error("Stored date is invalid.");
}
```

The `Task` class centralizes this logic:

```javascript
const normalizedCreatedAt =
  createdAt instanceof Date
    ? createdAt
    : new Date(createdAt);
```

---

# 24. JSON Limitations

JSON does not preserve:

- Class prototypes.
- Methods.
- `Date` instances.
- `Map`.
- `Set`.
- `undefined`.
- Functions.
- Symbols.
- Circular references.

Example:

```javascript
const value = {
  createdAt: new Date(),
  callback: () => {},
  missing: undefined,
};

const text = JSON.stringify(value);

console.log(text);
```

The function and `undefined` property are omitted.

For complex data structures, use a format and storage system designed for them.

---

# 25. Circular JSON Errors

This fails:

```javascript
const parent = {};
const child = {
  parent,
};

parent.child = child;

JSON.stringify(parent);
```

The objects refer to each other indefinitely.

The browser throws a circular structure error.

Avoid circular references in data intended for JSON storage, or define a custom serialization strategy.

---

# 26. When to Use IndexedDB

`localStorage` and `sessionStorage` are convenient for small string-based values.

Consider IndexedDB when you need:

- Larger data sets.
- Structured records.
- Indexed queries.
- Non-blocking database operations.
- Binary data.
- Multiple object stores.
- Transactions.
- More sophisticated client-side persistence.

A simplified IndexedDB opening example:

```javascript
const request = indexedDB.open(
  "async-task-manager",
  1
);

request.addEventListener("upgradeneeded", () => {
  const database = request.result;

  database.createObjectStore("tasks", {
    keyPath: "id",
  });
});

request.addEventListener("success", () => {
  console.log("IndexedDB opened.");
});

request.addEventListener("error", () => {
  console.error(
    "IndexedDB could not be opened:",
    request.error
  );
});
```

IndexedDB has a more complex API than `localStorage`, but it is better suited to database-like client-side storage.

---

# 27. IndexedDB with Promises

IndexedDB uses event-based operations. A Promise wrapper can make it easier to consume.

```javascript
function requestToPromise(request) {
  return new Promise((resolve, reject) => {
    request.addEventListener("success", () => {
      resolve(request.result);
    });

    request.addEventListener("error", () => {
      reject(request.error);
    });
  });
}
```

Example:

```javascript
async function openDatabase() {
  const request = indexedDB.open(
    "async-task-manager",
    1
  );

  request.addEventListener("upgradeneeded", () => {
    const database = request.result;

    if (!database.objectStoreNames.contains("tasks")) {
      database.createObjectStore("tasks", {
        keyPath: "id",
      });
    }
  });

  return requestToPromise(request);
}
```

This illustrates how older callback/event APIs can be adapted to modern Promise workflows.

---

# 28. Storage Service Pattern

A storage service hides browser details from the rest of the application.

A good service exposes operations such as:

```javascript
loadTasks();
saveTasks(tasks);
clearTasks();
```

The application does not need to know:

- Which storage key is used.
- Whether JSON is involved.
- How malformed records are handled.
- Whether the implementation uses localStorage or IndexedDB.

This makes it possible to replace the implementation later without rewriting the UI.

Example interface:

```javascript
export function loadTasks() {
  // Read, parse, validate, and restore tasks.
}

export function saveTasks(tasks) {
  // Serialize and persist tasks.
}

export function clearTasks() {
  // Remove persisted tasks.
}
```

---

# 29. Complete Storage Diagnostic Script

Create this temporary file in the project root.

### `storage-diagnostic.html`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta
      name="viewport"
      content="width=device-width, initial-scale=1.0"
    />
    <title>Storage Diagnostic</title>
  </head>

  <body>
    <h1>Open the browser console</h1>

    <script>
      "use strict";

      const localKey = "storage-diagnostic.local";
      const sessionKey = "storage-diagnostic.session";

      function canUseStorage(storage) {
        const testKey = "__storage_test__";

        try {
          storage.setItem(testKey, "test");
          storage.removeItem(testKey);
          return true;
        } catch (error) {
          console.error("Storage test failed:", error);
          return false;
        }
      }

      function testStorage(
        storageName,
        storage,
        key
      ) {
        console.log(
          `${storageName} available:`,
          canUseStorage(storage)
        );

        try {
          storage.setItem(
            key,
            JSON.stringify({
              name: storageName,
              timestamp: new Date().toISOString(),
            })
          );

          const rawValue = storage.getItem(key);
          const parsedValue = JSON.parse(rawValue);

          console.log(`${storageName} value:`, parsedValue);

          storage.removeItem(key);

          console.log(
            `${storageName} after removal:`,
            storage.getItem(key)
          );
        } catch (error) {
          console.error(
            `${storageName} diagnostic failed:`,
            error
          );
        }
      }

      testStorage(
        "localStorage",
        localStorage,
        localKey
      );

      testStorage(
        "sessionStorage",
        sessionStorage,
        sessionKey
      );
    </script>
  </body>
</html>
```

## The Verification

Open the file through the local server:

```text
http://localhost:8000/storage-diagnostic.html
```

The console should show:

```text
localStorage available: true
sessionStorage available: true
```

It should also show parsed objects and `null` after removal.

Delete the file after testing.

---

# 30. Browser Storage Checklist

Before using browser storage, verify:

- Is the data small enough?
- Does it need to survive browser restarts?
- Should it be shared across tabs?
- Is `localStorage` or `sessionStorage` more appropriate?
- Is the data sensitive?
- Is the data validated after parsing?
- Can JSON parsing fail?
- Can the storage write fail?
- Is the key namespaced?
- Is the data format versioned?
- Can older stored data be migrated?
- What happens if the user clears storage?
- What happens if storage is unavailable?
- Should IndexedDB be used instead?

---

# 31. Final Storage Rules

Use these rules as a practical summary:

1. Browser storage stores strings.
2. Use `JSON.stringify()` for objects and arrays.
3. Use `JSON.parse()` to restore JSON text.
4. Wrap parsing in error handling.
5. Validate parsed data.
6. Reconstruct class instances explicitly.
7. Use namespaced storage keys.
8. Version data formats that may change.
9. Handle storage write failures.
10. Never trust client storage for authorization.
11. Avoid storing secrets.
12. Use `textContent` for user-provided text.
13. Use `sessionStorage` for temporary tab state.
14. Use `localStorage` for small persistent preferences or application data.
15. Consider IndexedDB for larger structured data.
