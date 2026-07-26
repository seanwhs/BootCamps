# Primer 4: Asynchronous JavaScript Foundations

Asynchronous JavaScript allows an application to start work that finishes later without freezing the entire program.

Examples include:

- Timers.
- Network requests.
- File operations.
- User interactions.
- Database queries.
- Worker communication.

This primer covers:

- Synchronous versus asynchronous execution.
- Callbacks.
- Timers.
- Promises.
- Promise chaining.
- `async` and `await`.
- Error handling.
- Concurrent operations.
- Cancellation.
- Timeouts.
- Basic `fetch()`.
- Async iteration.
- Common mistakes.
- Verification exercises.

The goal is to prepare you for Part 2, where we will study microtasks, macrotasks, the event loop, concurrency combinators, and cancellation in depth.

---

# 1. Prepare the Workspace

## The Target

We will create a separate directory for asynchronous examples.

## The Concept

Each example demonstrates one scheduling or control-flow behavior. Running examples independently makes it easier to change one detail and observe the result.

## Implementation

From the project root, run:

```bash
mkdir -p primer-4/src
mkdir -p primer-4/test
```

Create:

### `primer-4/package.json`

```json
{
  "name": "runtime-monitor-primer-4",
  "version": "1.0.0",
  "private": true,
  "description": "Asynchronous JavaScript foundations",
  "type": "module",
  "scripts": {
    "sync": "node src/synchronous.js",
    "callback": "node src/callbacks.js",
    "timers": "node src/timers.js",
    "promise": "node src/promises.js",
    "chain": "node src/promise-chain.js",
    "async": "node src/async-await.js",
    "concurrent": "node src/concurrent-work.js",
    "cancel": "node src/cancellation.js",
    "timeout": "node src/timeout.js",
    "iterator": "node src/async-iterator.js",
    "test": "node --test",
    "test:watch": "node --test --watch"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

## Verification

Run:

```bash
cd primer-4
npm run
```

Confirm that the scripts appear.

---

# 2. Synchronous Execution

## The Target

We will create a synchronous program that runs one statement at a time.

## The Concept

Synchronous code is like a single cashier serving one customer:

1. The current task begins.
2. The cashier finishes it.
3. The next task starts.

A long synchronous operation blocks later work.

## Implementation

### `primer-4/src/synchronous.js`

```js
function logStep(message) {
  console.log(message);
}

function calculateTotal(values) {
  let total = 0;

  for (const value of values) {
    total += value;
  }

  return total;
}

logStep("1. program started");

const values = [10, 20, 30];
const total = calculateTotal(values);

logStep(`2. total calculated: ${total}`);
logStep("3. program finished");
```

## Verification

Run:

```bash
npm run sync
```

Expected output:

```text
1. program started
2. total calculated: 60
3. program finished
```

Every statement completes before the next statement begins.

---

# 3. Synchronous Work Blocks Later Callbacks

## The Target

We will show that a timer cannot interrupt a synchronous loop.

## The Concept

JavaScript does not pause an active synchronous function to execute a timer callback.

The timer waits until the current call stack is clear.

## Implementation

### `primer-4/src/blocking.js`

```js
console.log("1. before timer");

setTimeout(() => {
  console.log("3. timer callback");
}, 0);

const endTime = Date.now() + 100;

while (Date.now() < endTime) {
  /*
   * This intentionally blocks the JavaScript thread.
   */
}

console.log("2. after blocking loop");
```

## Verification

Run:

```bash
node src/blocking.js
```

Expected output:

```text
1. before timer
2. after blocking loop
3. timer callback
```

The zero-millisecond timer does not interrupt the loop.

---

# 4. Callbacks

## The Target

We will create a callback-based asynchronous operation.

## The Concept

A callback is a function passed to another function so it can be called later.

A callback API often has this shape:

```js
startOperation((error, result) => {
  // handle completion
});
```

Older Node.js APIs commonly use the convention:

```js
callback(error, result)
```

where:

- `error` is `null` on success.
- `result` contains the successful value.

## Implementation

### `primer-4/src/callbacks.js`

```js
function delayWithCallback(milliseconds, value, callback) {
  if (typeof callback !== "function") {
    throw new TypeError(
      "callback must be a function"
    );
  }

  if (
    !Number.isFinite(milliseconds) ||
    milliseconds < 0
  ) {
    throw new RangeError(
      "milliseconds must be non-negative and finite"
    );
  }

  setTimeout(() => {
    callback(null, value);
  }, milliseconds);
}

console.log("operation started");

delayWithCallback(
  25,
  "operation completed",
  (error, result) => {
    if (error) {
      console.error("operation failed:", error);
      return;
    }

    console.log("result:", result);
  }
);

console.log("operation was scheduled");
```

## Verification

Run:

```bash
npm run callback
```

Expected output:

```text
operation started
operation was scheduled
result: operation completed
```

The callback runs after the current synchronous code finishes.

---

# 5. Callback Errors

## The Target

We will simulate a callback-based operation that can fail.

## The Concept

A callback API must define how failures are delivered.

The error-first convention uses:

```js
callback(error, result)
```

The caller must check the error before using the result.

## Implementation

### `primer-4/src/callback-errors.js`

```js
function loadConfiguration(
  shouldFail,
  callback
) {
  setTimeout(() => {
    if (shouldFail) {
      callback(
        new Error("configuration could not be loaded")
      );

      return;
    }

    callback(null, {
      environment: "development",
      timeoutMilliseconds: 5_000
    });
  }, 10);
}

loadConfiguration(true, (error, configuration) => {
  if (error) {
    console.error("failed:", error.message);
    return;
  }

  console.log("configuration:", configuration);
});

loadConfiguration(false, (error, configuration) => {
  if (error) {
    console.error("failed:", error.message);
    return;
  }

  console.log("configuration:", configuration);
});
```

## Verification

Run:

```bash
node src/callback-errors.js
```

Expected output includes:

```text
failed: configuration could not be loaded
configuration: { environment: 'development', timeoutMilliseconds: 5000 }
```

---

# 6. Callback Nesting

## The Target

We will demonstrate nested callbacks.

## The Concept

When one operation depends on another, callback code can become deeply nested.

This resembles a staircase:

```text
load configuration
  └── load user
       └── load permissions
            └── render dashboard
```

## Implementation

### `primer-4/src/callback-nesting.js`

```js
function loadConfiguration(callback) {
  setTimeout(() => {
    callback(null, {
      apiBaseUrl: "https://api.example.test"
    });
  }, 10);
}

function loadUser(configuration, callback) {
  setTimeout(() => {
    callback(null, {
      id: "user-1",
      name: "Ada",
      apiBaseUrl: configuration.apiBaseUrl
    });
  }, 10);
}

function loadPermissions(user, callback) {
  setTimeout(() => {
    callback(null, {
      userId: user.id,
      permissions: ["dashboard:read"]
    });
  }, 10);
}

loadConfiguration((configurationError, configuration) => {
  if (configurationError) {
    console.error(configurationError);
    return;
  }

  loadUser(configuration, (userError, user) => {
    if (userError) {
      console.error(userError);
      return;
    }

    loadPermissions(user, (permissionsError, permissions) => {
      if (permissionsError) {
        console.error(permissionsError);
        return;
      }

      console.log({
        configuration,
        user,
        permissions
      });
    });
  });
});
```

## Verification

Run:

```bash
node src/callback-nesting.js
```

Expected output contains configuration, user, and permissions.

Promises can flatten this control flow.

---

# 7. Promisifying a Callback API

## The Target

We will convert a callback API into a promise-based API.

## The Concept

A promise adapter wraps callback completion in a promise:

```text
callback success → resolve
callback failure → reject
```

## Implementation

### `primer-4/src/promisify.js`

```js
function delayWithCallback(milliseconds, value, callback) {
  setTimeout(() => {
    callback(null, value);
  }, milliseconds);
}

function delay(milliseconds, value) {
  return new Promise((resolve, reject) => {
    delayWithCallback(
      milliseconds,
      value,
      (error, result) => {
        if (error) {
          reject(error);
          return;
        }

        resolve(result);
      }
    );
  });
}

const result = await delay(
  25,
  "converted to a promise"
);

console.log(result);
```

## Verification

Run:

```bash
node src/promisify.js
```

Expected output:

```text
converted to a promise
```

Node.js also provides utilities for adapting many error-first callback APIs:

```js
import { promisify } from "node:util";
```

---

# 8. Creating a Promise

## The Target

We will create a reusable delay promise.

## The Concept

The `Promise` constructor receives an executor function.

The executor receives:

- `resolve`: call on success.
- `reject`: call on failure.

## Implementation

### `primer-4/src/promise.js`

```js
function delay(milliseconds, value) {
  if (
    !Number.isFinite(milliseconds) ||
    milliseconds < 0
  ) {
    throw new RangeError(
      "milliseconds must be non-negative and finite"
    );
  }

  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(value);
    }, milliseconds);
  });
}

console.log("before delay");

const result = await delay(
  20,
  "delay finished"
);

console.log(result);
```

## Verification

Run:

```bash
npm run promise
```

Expected output:

```text
before delay
delay finished
```

---

# 9. Promise Resolution and Rejection

## The Target

We will create successful and failed promises.

## Implementation

### `primer-4/src/promise-states.js`

```js
const successful = Promise.resolve({
  status: "healthy"
});

const failed = Promise.reject(
  new Error("service unavailable")
);

successful.then((value) => {
  console.log("success:", value);
});

failed.catch((error) => {
  console.log("failure:", error.message);
});
```

## Verification

Run:

```bash
node src/promise-states.js
```

Expected output:

```text
success: { status: 'healthy' }
failure: service unavailable
```

A rejected promise needs a rejection handler. Otherwise, it may become an unhandled rejection.

---

# 10. Promise Chaining

## The Target

We will build a multi-step asynchronous workflow with `.then()`.

## The Concept

A promise chain passes each result to the next step.

```text
load configuration
        │
        ▼
validate configuration
        │
        ▼
create request
        │
        ▼
send request
```

## Implementation

### `primer-4/src/promise-chain.js`

```js
function loadConfiguration() {
  return Promise.resolve({
    baseUrl: "https://api.example.test",
    endpoint: "/metrics"
  });
}

function validateConfiguration(configuration) {
  if (
    typeof configuration.baseUrl !== "string" ||
    typeof configuration.endpoint !== "string"
  ) {
    throw new Error(
      "configuration is invalid"
    );
  }

  return configuration;
}

function createRequest(configuration) {
  return {
    url: `${configuration.baseUrl}${configuration.endpoint}`,
    method: "GET"
  };
}

function sendRequest(request) {
  console.log("sending request:", request);

  return Promise.resolve({
    status: 200,
    body: {
      requestsPerSecond: 125
    }
  });
}

function parseResponse(response) {
  if (response.status !== 200) {
    throw new Error(
      `unexpected response status: ${response.status}`
    );
  }

  return response.body;
}

loadConfiguration()
  .then(validateConfiguration)
  .then(createRequest)
  .then(sendRequest)
  .then(parseResponse)
  .then((metrics) => {
    console.log("metrics:", metrics);
  })
  .catch((error) => {
    console.error("workflow failed:", error.message);
  })
  .finally(() => {
    console.log("workflow finished");
  });
```

## Verification

Run:

```bash
npm run chain
```

Expected output:

```text
sending request: { url: 'https://api.example.test/metrics', method: 'GET' }
metrics: { requestsPerSecond: 125 }
workflow finished
```

---

# 11. Returning Values from Promise Handlers

## The Target

We will observe how returned values move through a promise chain.

## Implementation

### `primer-4/src/promise-values.js`

```js
Promise.resolve(10)
  .then((value) => {
    console.log("first value:", value);
    return value * 2;
  })
  .then((value) => {
    console.log("second value:", value);
    return value + 5;
  })
  .then((value) => {
    console.log("final value:", value);
  });
```

## Verification

Run:

```bash
node src/promise-values.js
```

Expected output:

```text
first value: 10
second value: 20
final value: 25
```

Returning a value fulfills the next promise with that value.

---

# 12. Errors in Promise Chains

## The Target

We will observe how thrown errors move to `.catch()`.

## Implementation

### `primer-4/src/promise-errors.js`

```js
Promise.resolve({
  timeoutMilliseconds: -1
})
  .then((configuration) => {
    if (configuration.timeoutMilliseconds < 0) {
      throw new RangeError(
        "timeout cannot be negative"
      );
    }

    return configuration;
  })
  .then((configuration) => {
    console.log("valid configuration:", configuration);
  })
  .catch((error) => {
    console.log({
      name: error.name,
      message: error.message
    });
  });
```

## Verification

Run:

```bash
node src/promise-errors.js
```

Expected output:

```text
{
  name: 'RangeError',
  message: 'timeout cannot be negative'
}
```

A thrown error inside a `.then()` handler rejects the promise returned by that handler.

---

# 13. `async` Functions

## The Target

We will create an `async` function.

## The Concept

An `async` function always returns a promise, even when it returns an ordinary value.

## Implementation

### `primer-4/src/async-function.js`

```js
async function getServiceName() {
  return "metrics";
}

const result = getServiceName();

console.log(
  "returns a promise:",
  result instanceof Promise
);

console.log(
  "resolved value:",
  await result
);
```

## Verification

Run:

```bash
node src/async-function.js
```

Expected output:

```text
returns a promise: true
resolved value: metrics
```

---

# 14. `await`

## The Target

We will use `await` to read a promise result.

## The Concept

`await` pauses the current async function until the value is available.

It does not freeze the entire Node.js process.

## Implementation

### `primer-4/src/async-await.js`

```js
function delay(milliseconds, value) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(value);
    }, milliseconds);
  });
}

async function loadService() {
  console.log("load started");

  const service = await delay(
    25,
    {
      name: "metrics",
      status: "healthy"
    }
  );

  console.log("load completed");

  return service;
}

const service = await loadService();

console.log(service);
```

## Verification

Run:

```bash
npm run async
```

Expected output:

```text
load started
load completed
{ name: 'metrics', status: 'healthy' }
```

---

# 15. `await` Does Not Block Other Work

## The Target

We will show that other callbacks can run while one async function is waiting.

## Implementation

### `primer-4/src/await-nonblocking.js`

```js
function delay(milliseconds, value) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(value);
    }, milliseconds);
  });
}

async function loadData() {
  console.log("load started");

  const result = await delay(
    50,
    "data loaded"
  );

  console.log(result);
}

loadData();

setTimeout(() => {
  console.log("independent timer ran");
}, 10);

console.log("main script continued");
```

## Verification

Run:

```bash
node src/await-nonblocking.js
```

Expected output:

```text
load started
main script continued
independent timer ran
data loaded
```

Only `loadData()` pauses. The entire runtime does not pause.

---

# 16. Async Error Handling

## The Target

We will use `try`, `catch`, and `finally` around `await`.

## The Concept

A rejected promise behaves like a thrown error at the `await` expression.

## Implementation

### `primer-4/src/async-errors.js`

```js
function failAfterDelay() {
  return new Promise((_, reject) => {
    setTimeout(() => {
      reject(new Error("service failed"));
    }, 10);
  });
}

let loading = true;

try {
  console.log("loading:", loading);

  await failAfterDelay();

  console.log("this line does not run");
} catch (error) {
  console.log("handled:", error.message);
} finally {
  loading = false;
  console.log("loading:", loading);
}
```

## Verification

Run:

```bash
node src/async-errors.js
```

Expected output:

```text
loading: true
handled: service failed
loading: false
```

Use `finally` for cleanup or state restoration that must occur on both success and failure.

---

# 17. Sequential Asynchronous Work

## The Target

We will execute dependent operations sequentially.

## The Concept

Sequential execution is appropriate when one operation needs the previous result.

```text
load user
   │
   ▼
use user.id to load permissions
   │
   ▼
use permissions to create session
```

## Implementation

### `primer-4/src/sequential-work.js`

```js
function delay(milliseconds, value) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(value);
    }, milliseconds);
  });
}

async function loadUser() {
  return delay(20, {
    id: "user-1",
    name: "Ada"
  });
}

async function loadPermissions(userId) {
  return delay(20, {
    userId,
    permissions: ["dashboard:read"]
  });
}

const user = await loadUser();
const permissions = await loadPermissions(user.id);

console.log({
  user,
  permissions
});
```

## Verification

Run:

```bash
node src/sequential-work.js
```

Expected output contains the user and permissions.

---

# 18. Concurrent Independent Work

## The Target

We will run independent operations concurrently.

## The Concept

If operations do not depend on one another, start them together.

Sequential:

```js
const first = await loadFirst();
const second = await loadSecond();
```

Concurrent:

```js
const [first, second] = await Promise.all([
  loadFirst(),
  loadSecond()
]);
```

## Implementation

### `primer-4/src/concurrent-work.js`

```js
function delay(milliseconds, value) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(value);
    }, milliseconds);
  });
}

async function loadMetrics() {
  return delay(40, {
    requestsPerSecond: 125
  });
}

async function loadHealth() {
  return delay(20, {
    status: "healthy"
  });
}

const startedAt = Date.now();

const [metrics, health] = await Promise.all([
  loadMetrics(),
  loadHealth()
]);

const elapsedMilliseconds =
  Date.now() - startedAt;

console.log({
  metrics,
  health,
  elapsedMilliseconds
});
```

## Verification

Run:

```bash
npm run concurrent
```

Expected elapsed time should be close to 40 milliseconds, not 60 milliseconds.

Timing varies slightly by machine.

---

# 19. `Promise.all()`

## The Target

We will require several operations to succeed.

## Implementation

### `primer-4/src/promise-all.js`

```js
function delay(milliseconds, value, shouldFail = false) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (shouldFail) {
        reject(new Error(`${value} failed`));
        return;
      }

      resolve(value);
    }, milliseconds);
  });
}

try {
  const results = await Promise.all([
    delay(20, "metrics"),
    delay(10, "health"),
    delay(15, "activity")
  ]);

  console.log(results);
} catch (error) {
  console.error("required workflow failed:", error);
}

try {
  await Promise.all([
    delay(10, "metrics"),
    delay(5, "health", true),
    delay(20, "activity")
  ]);
} catch (error) {
  console.error("failure example:", error.message);
}
```

## Verification

Run:

```bash
node src/promise-all.js
```

Expected output:

```text
[ 'metrics', 'health', 'activity' ]
failure example: health failed
```

The result order follows input order, not completion order.

---

# 20. `Promise.allSettled()`

## The Target

We will preserve successful and failed outcomes.

## Concept

Use `Promise.allSettled()` when one failed operation should not discard other results.

## Implementation

### `primer-4/src/promise-all-settled.js`

```js
function delay(milliseconds, value, shouldFail = false) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (shouldFail) {
        reject(new Error(`${value} failed`));
        return;
      }

      resolve(value);
    }, milliseconds);
  });
}

const results = await Promise.allSettled([
  delay(20, "metrics"),
  delay(5, "health", true),
  delay(10, "activity")
]);

for (const result of results) {
  if (result.status === "fulfilled") {
    console.log("success:", result.value);
  } else {
    console.log(
      "failure:",
      result.reason.message
    );
  }
}
```

## Verification

Run:

```bash
node src/promise-all-settled.js
```

Expected output:

```text
success: metrics
failure: health failed
success: activity
```

---

# 21. `Promise.race()`

## The Target

We will use `Promise.race()` for a basic deadline.

## Concept

`Promise.race()` settles when the first input promise settles.

The losing operation continues unless it supports cancellation.

## Implementation

### `primer-4/src/promise-race.js`

```js
function delay(milliseconds, value) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(value);
    }, milliseconds);
  });
}

function timeout(milliseconds) {
  return new Promise((_, reject) => {
    setTimeout(() => {
      reject(new Error("operation timed out"));
    }, milliseconds);
  });
}

try {
  const result = await Promise.race([
    delay(100, "slow result"),
    timeout(20)
  ]);

  console.log(result);
} catch (error) {
  console.log(error.message);
}
```

## Verification

Run:

```bash
node src/promise-race.js
```

Expected output:

```text
operation timed out
```

This is useful for understanding races, but production timeouts should also cancel underlying work.

---

# 22. `Promise.any()`

## The Target

We will accept the first successful source.

## Concept

`Promise.any()` ignores failures until one operation succeeds.

This is useful for redundant services or replicas.

## Implementation

### `primer-4/src/promise-any.js`

```js
function failAfter(milliseconds, name) {
  return new Promise((_, reject) => {
    setTimeout(() => {
      reject(new Error(`${name} failed`));
    }, milliseconds);
  });
}

function succeedAfter(milliseconds, name) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(`${name} succeeded`);
    }, milliseconds);
  });
}

const result = await Promise.any([
  failAfter(5, "primary"),
  succeedAfter(20, "secondary"),
  succeedAfter(30, "tertiary")
]);

console.log(result);
```

## Verification

Run:

```bash
node src/promise-any.js
```

Expected output:

```text
secondary succeeded
```

---

# 23. Timers

## The Target

We will use `setTimeout()` and `setInterval()`.

## The Concept

A timer schedules later work.

A delay is a minimum waiting period, not an exact execution time.

## Implementation

### `primer-4/src/timers.js`

```js
console.log("program started");

const timeoutId = setTimeout(() => {
  console.log("one-time timer");
}, 20);

const intervalId = setInterval(() => {
  console.log("repeating timer");
}, 15);

setTimeout(() => {
  clearTimeout(timeoutId);
  clearInterval(intervalId);

  console.log("timers cleared");
}, 70);
```

## Verification

Run:

```bash
npm run timers
```

Expected output includes:

```text
program started
repeating timer
one-time timer
repeating timer
...
timers cleared
```

The exact number of interval executions may vary slightly.

---

# 24. Avoid Overlapping Async Intervals

## The Target

We will compare an unsafe interval with sequential polling.

## The Concept

This can start overlapping operations:

```js
setInterval(async () => {
  await slowOperation();
}, 100);
```

If the operation takes 500 milliseconds, several calls can be active at once.

## Implementation

### `primer-4/src/polling.js`

```js
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

let pollCount = 0;
let stopped = false;

async function pollSequentially() {
  if (stopped) {
    return;
  }

  pollCount += 1;
  console.log("poll started:", pollCount);

  try {
    await delay(30);
    console.log("poll finished:", pollCount);
  } finally {
    if (!stopped) {
      setTimeout(pollSequentially, 20);
    }
  }
}

pollSequentially();

setTimeout(() => {
  stopped = true;
  console.log("polling stopped");
}, 150);
```

## Verification

Run:

```bash
node src/polling.js
```

Each poll should finish before the next poll begins.

---

# 25. Cancellation with `AbortController`

## The Target

We will create a cancellable delay.

## The Concept

An `AbortController` provides a stop signal.

The caller owns the controller. The operation receives the signal and listens for cancellation.

## Implementation

### `primer-4/src/cancellation.js`

```js
function createAbortError(message) {
  const error = new Error(message);
  error.name = "AbortError";
  return error;
}

function cancellableDelay(
  milliseconds,
  value,
  signal
) {
  if (!(signal instanceof AbortSignal)) {
    throw new TypeError(
      "signal must be an AbortSignal"
    );
  }

  return new Promise((resolve, reject) => {
    let settled = false;

    const cleanup = () => {
      clearTimeout(timerId);
      signal.removeEventListener(
        "abort",
        handleAbort
      );
    };

    const finish = () => {
      if (settled) {
        return;
      }

      settled = true;
      cleanup();
      resolve(value);
    };

    const handleAbort = () => {
      if (settled) {
        return;
      }

      settled = true;
      cleanup();

      reject(
        signal.reason ??
        createAbortError("operation cancelled")
      );
    };

    if (signal.aborted) {
      handleAbort();
      return;
    }

    const timerId = setTimeout(
      finish,
      milliseconds
    );

    signal.addEventListener(
      "abort",
      handleAbort,
      { once: true }
    );
  });
}

const controller = new AbortController();

const operation = cancellableDelay(
  1_000,
  "completed",
  controller.signal
);

setTimeout(() => {
  controller.abort(
    createAbortError("caller cancelled operation")
  );
}, 30);

try {
  console.log(await operation);
} catch (error) {
  if (error.name === "AbortError") {
    console.log("cancelled:", error.message);
  } else {
    throw error;
  }
}
```

## Verification

Run:

```bash
npm run cancel
```

Expected output:

```text
cancelled: caller cancelled operation
```

---

# 26. Timeout That Cancels the Operation

## The Target

We will create a timeout helper that aborts underlying work.

## The Concept

A raw promise race reports a timeout but does not necessarily stop the losing operation.

A cancellation-aware timeout:

1. Creates an internal controller.
2. Starts a timer.
3. Aborts the operation when the timer expires.
4. Clears the timer when the operation finishes.

## Implementation

### `primer-4/src/timeout.js`

```js
function createTimeoutError(milliseconds) {
  const error = new Error(
    `operation timed out after ${milliseconds} ms`
  );

  error.name = "TimeoutError";
  return error;
}

function cancellableDelay(
  milliseconds,
  value,
  signal
) {
  return new Promise((resolve, reject) => {
    let settled = false;

    const cleanup = () => {
      clearTimeout(timerId);
      signal.removeEventListener(
        "abort",
        handleAbort
      );
    };

    const handleAbort = () => {
      if (settled) {
        return;
      }

      settled = true;
      cleanup();
      reject(
        signal.reason ??
        new Error("operation aborted")
      );
    };

    const finish = () => {
      if (settled) {
        return;
      }

      settled = true;
      cleanup();
      resolve(value);
    };

    if (signal.aborted) {
      handleAbort();
      return;
    }

    const timerId = setTimeout(
      finish,
      milliseconds
    );

    signal.addEventListener(
      "abort",
      handleAbort,
      { once: true }
    );
  });
}

async function withTimeout(
  operation,
  milliseconds,
  parentSignal
) {
  const controller = new AbortController();

  let timeoutId;

  const abortFromParent = () => {
    controller.abort(parentSignal.reason);
  };

  if (parentSignal) {
    if (parentSignal.aborted) {
      abortFromParent();
    } else {
      parentSignal.addEventListener(
        "abort",
        abortFromParent,
        { once: true }
      );
    }
  }

  timeoutId = setTimeout(() => {
    controller.abort(
      createTimeoutError(milliseconds)
    );
  }, milliseconds);

  try {
    return await operation(controller.signal);
  } finally {
    clearTimeout(timeoutId);

    parentSignal?.removeEventListener(
      "abort",
      abortFromParent
    );
  }
}

try {
  const result = await withTimeout(
    (signal) =>
      cancellableDelay(
        1_000,
        "finished",
        signal
      ),
    30
  );

  console.log(result);
} catch (error) {
  console.log({
    name: error.name,
    message: error.message
  });
}
```

## Verification

Run:

```bash
npm run timeout
```

Expected output:

```text
{
  name: 'TimeoutError',
  message: 'operation timed out after 30 ms'
}
```

---

# 27. Basic `fetch()`

## The Target

We will request JSON from an HTTP endpoint.

## The Concept

`fetch()` returns a promise for an HTTP response.

Important:

```js
fetch()
```

rejects for network-level failures, but it usually does not reject automatically for HTTP statuses such as 404 or 500.

Check:

```js
response.ok
```

## Implementation

### `primer-4/src/fetch-json.js`

```js
async function fetchJson(
  url,
  signal
) {
  const response = await fetch(url, {
    signal
  });

  if (!response.ok) {
    const error = new Error(
      `request failed with status ${response.status}`
    );

    error.name = "HttpError";
    error.status = response.status;

    throw error;
  }

  return response.json();
}

try {
  const result = await fetchJson(
    "https://jsonplaceholder.typicode.com/todos/1"
  );

  console.log(result);
} catch (error) {
  console.error({
    name: error.name,
    message: error.message,
    status: error.status
  });

  process.exitCode = 1;
}
```

## Verification

Run:

```bash
node src/fetch-json.js
```

Expected output resembles:

```text
{
  userId: 1,
  id: 1,
  title: 'delectus aut autem',
  completed: false
}
```

This example requires network access.

---

# 28. Fetch with Timeout and Cancellation

## The Target

We will combine `fetch()`, `AbortController`, and a deadline.

## Implementation

### `primer-4/src/fetch-cancellable.js`

```js
async function fetchJsonWithTimeout(
  url,
  milliseconds,
  parentSignal
) {
  const controller = new AbortController();

  const abortFromParent = () => {
    controller.abort(parentSignal.reason);
  };

  if (parentSignal) {
    if (parentSignal.aborted) {
      abortFromParent();
    } else {
      parentSignal.addEventListener(
        "abort",
        abortFromParent,
        { once: true }
      );
    }
  }

  const timeoutId = setTimeout(() => {
    const error = new Error(
      `request timed out after ${milliseconds} ms`
    );

    error.name = "TimeoutError";
    controller.abort(error);
  }, milliseconds);

  try {
    const response = await fetch(url, {
      signal: controller.signal
    });

    if (!response.ok) {
      const error = new Error(
        `request failed with status ${response.status}`
      );

      error.name = "HttpError";
      error.status = response.status;

      throw error;
    }

    return await response.json();
  } finally {
    clearTimeout(timeoutId);

    parentSignal?.removeEventListener(
      "abort",
      abortFromParent
    );
  }
}

const controller = new AbortController();

try {
  const result = await fetchJsonWithTimeout(
    "https://jsonplaceholder.typicode.com/todos/1",
    5_000,
    controller.signal
  );

  console.log(result);
} catch (error) {
  console.error({
    name: error.name,
    message: error.message
  });
}
```

## Verification

Run:

```bash
node src/fetch-cancellable.js
```

The request should either return JSON or produce a controlled error.

---

# 29. Async Iterators

## The Target

We will create an asynchronous generator.

## The Concept

An async iterator produces values over time.

Use:

```js
for await (const value of source) {
  // process asynchronous values
}
```

This is useful for:

- Streams.
- Polling.
- Paginated APIs.
- Queues.
- Incremental processing.

## Implementation

### `primer-4/src/async-iterator.js`

```js
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}

async function* serviceStatuses() {
  yield {
    name: "metrics",
    status: "loading"
  };

  await delay(20);

  yield {
    name: "metrics",
    status: "healthy"
  };

  await delay(20);

  yield {
    name: "metrics",
    status: "degraded"
  };
}

for await (const service of serviceStatuses()) {
  console.log(service);
}
```

## Verification

Run:

```bash
npm run iterator
```

Expected output:

```text
{ name: 'metrics', status: 'loading' }
{ name: 'metrics', status: 'healthy' }
{ name: 'metrics', status: 'degraded' }
```

---

# 30. Async Iterator Cancellation

## The Target

We will stop an async generator using an abort signal.

## Concept

Long-running async iterators need a lifecycle policy. An `AbortSignal` allows the consumer to stop production.

## Implementation

### `primer-4/src/cancellable-iterator.js`

```js
function delay(milliseconds, signal) {
  return new Promise((resolve, reject) => {
    if (signal.aborted) {
      reject(
        signal.reason ??
        new Error("operation cancelled")
      );

      return;
    }

    const timerId = setTimeout(resolve, milliseconds);

    const handleAbort = () => {
      clearTimeout(timerId);

      reject(
        signal.reason ??
        new Error("operation cancelled")
      );
    };

    signal.addEventListener(
      "abort",
      handleAbort,
      { once: true }
    );
  });
}

async function* pollStatuses(signal) {
  let sequence = 0;

  try {
    while (!signal.aborted) {
      await delay(20, signal);

      sequence += 1;

      yield {
        sequence,
        status: sequence % 2 === 0
          ? "healthy"
          : "degraded"
      };
    }
  } finally {
    console.log("iterator cleanup complete");
  }
}

const controller = new AbortController();

setTimeout(() => {
  controller.abort(
    new Error("consumer stopped polling")
  );
}, 75);

try {
  for await (const value of pollStatuses(
    controller.signal
  )) {
    console.log(value);
  }
} catch (error) {
  console.log("polling stopped:", error.message);
}
```

## Verification

Run:

```bash
node src/cancellable-iterator.js
```

Expected output includes:

```text
iterator cleanup complete
polling stopped: consumer stopped polling
```

---

# 31. Common Async Mistakes

## Mistake 1: Forgetting `await`

Incorrect:

```js
const response = fetch(url);
console.log(response.status);
```

`response` is a promise.

Correct:

```js
const response = await fetch(url);
console.log(response.status);
```

---

## Mistake 2: Using `forEach()` with `async`

Incorrect:

```js
services.forEach(async (service) => {
  await refresh(service);
});

console.log("finished");
```

The outer code does not wait for the callbacks.

Sequential version:

```js
for (const service of services) {
  await refresh(service);
}
```

Concurrent version:

```js
await Promise.all(
  services.map((service) => refresh(service))
);
```

---

## Mistake 3: Accidental Sequential Work

Incorrect when operations are independent:

```js
const metrics = await loadMetrics();
const health = await loadHealth();
```

Better:

```js
const [metrics, health] = await Promise.all([
  loadMetrics(),
  loadHealth()
]);
```

---

## Mistake 4: Swallowing Errors

Avoid:

```js
try {
  await operation();
} catch {
  // ignored
}
```

Prefer:

```js
try {
  await operation();
} catch (error) {
  logger.error("operation failed", {
    message: error.message
  });

  throw error;
}
```

---

## Mistake 5: Retrying Cancellation

Do not retry intentional cancellation:

```js
try {
  await operation(signal);
} catch (error) {
  if (error.name === "AbortError") {
    return;
  }

  throw error;
}
```

---

## Mistake 6: Timeout Without Cleanup

If a timeout creates a timer, clear it after success or failure:

```js
const timerId = setTimeout(onTimeout, 5000);

try {
  return await operation();
} finally {
  clearTimeout(timerId);
}
```

---

## Mistake 7: Assuming `fetch()` Rejects on HTTP Errors

This can incorrectly treat a 500 response as success:

```js
const response = await fetch(url);
const body = await response.json();
```

Check:

```js
if (!response.ok) {
  throw new Error(`HTTP ${response.status}`);
}
```

---

# 32. Testing Asynchronous Code

## The Target

We will create tests for success, rejection, and cancellation.

## Implementation

### `primer-4/test/async.test.js`

```js
import test from "node:test";
import assert from "node:assert/strict";

function delay(milliseconds, value) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(value);
    }, milliseconds);
  });
}

function cancellableDelay(
  milliseconds,
  signal
) {
  return new Promise((resolve, reject) => {
    const timerId = setTimeout(resolve, milliseconds);

    const handleAbort = () => {
      clearTimeout(timerId);

      const error = new Error("cancelled");
      error.name = "AbortError";

      reject(error);
    };

    if (signal.aborted) {
      handleAbort();
      return;
    }

    signal.addEventListener(
      "abort",
      handleAbort,
      { once: true }
    );
  });
}

test("delay resolves with a value", async () => {
  const result = await delay(1, "done");

  assert.equal(result, "done");
});

test("rejected promises can be asserted", async () => {
  await assert.rejects(
    Promise.reject(
      new Error("expected failure")
    ),
    {
      message: "expected failure"
    }
  );
});

test("cancellable delay rejects after abort", async () => {
  const controller = new AbortController();

  const operation = cancellableDelay(
    1_000,
    controller.signal
  );

  controller.abort();

  await assert.rejects(operation, {
    name: "AbortError"
  });
});
```

## Verification

Run:

```bash
npm test
```

All tests should pass.

---

# 33. Async Readiness Exercises

## Exercise 1: Create a Promise Delay

Implement:

```js
function delay(milliseconds, value) {
  // return a promise
}
```

Verify:

```js
console.log(await delay(10, "done"));
```

---

## Exercise 2: Load Three Services

Create:

```js
async function loadDashboard() {
  // load metrics, health, and activity concurrently
}
```

Use `Promise.all()` and return:

```js
{
  metrics,
  health,
  activity
}
```

---

## Exercise 3: Preserve Partial Results

Change the implementation to use `Promise.allSettled()`.

Return:

```js
{
  metrics: {
    status: "available",
    data: ...
  },
  health: {
    status: "unavailable",
    error: ...
  }
}
```

---

## Exercise 4: Add Cancellation

Create:

```js
function createRefreshManager() {
  // abort the previous refresh when a new one starts
}
```

Verify that only the newest refresh is displayed.

---

## Exercise 5: Add a Timeout

Wrap a slow operation with a 50-millisecond deadline.

Verify that:

- The operation rejects with `TimeoutError`.
- The underlying timer is cleared or aborted.
- The caller can distinguish timeout from cancellation.

---

# 34. Asynchronous Readiness Checklist

You are ready for Part 2 when you can explain and use:

## Core Concepts

- [ ] Synchronous versus asynchronous execution.
- [ ] Callbacks.
- [ ] Promise states.
- [ ] Promise resolution and rejection.
- [ ] Promise chaining.
- [ ] `async` functions.
- [ ] `await`.
- [ ] `try`, `catch`, and `finally`.

## Concurrency

- [ ] Sequential dependent work.
- [ ] Concurrent independent work.
- [ ] `Promise.all()`.
- [ ] `Promise.allSettled()`.
- [ ] `Promise.race()`.
- [ ] `Promise.any()`.

## Timers

- [ ] `setTimeout()`.
- [ ] `setInterval()`.
- [ ] `clearTimeout()`.
- [ ] `clearInterval()`.
- [ ] Why a zero-delay timer is not immediate.
- [ ] Why asynchronous intervals can overlap.

## Cancellation

- [ ] `AbortController`.
- [ ] `AbortSignal`.
- [ ] `AbortError`.
- [ ] Cancellation-aware cleanup.
- [ ] Timeout cancellation.

## Network

- [ ] Basic `fetch()`.
- [ ] `response.ok`.
- [ ] HTTP error handling.
- [ ] Request timeout.
- [ ] Request cancellation.

## Async Iteration

- [ ] Async generators.
- [ ] `for await...of`.
- [ ] Async iterator cleanup.

---

# 35. Complete Verification Commands

From the `primer-4` directory, run:

```bash
npm run sync
npm run callback
npm run timers
npm run promise
npm run chain
npm run async
npm run concurrent
npm run cancel
npm run timeout
npm run iterator
npm test
```

Run the supporting examples:

```bash
node src/blocking.js
node src/callback-errors.js
node src/callback-nesting.js
node src/promisify.js
node src/promise-states.js
node src/promise-values.js
node src/promise-errors.js
node src/async-function.js
node src/await-nonblocking.js
node src/async-errors.js
node src/sequential-work.js
node src/promise-all.js
node src/promise-all-settled.js
node src/promise-race.js
node src/promise-any.js
node src/polling.js
node src/fetch-json.js
node src/fetch-cancellable.js
node src/cancellable-iterator.js
```

The fetch examples require network access. If they fail because the network is unavailable, verify the error handling rather than treating the environment failure as a code failure.

---

# 36. Primer Summary

Asynchronous JavaScript follows this general model:

```text
start synchronous code
        │
        ▼
schedule asynchronous work
        │
        ▼
continue current code
        │
        ▼
asynchronous operation completes
        │
        ▼
callback or promise continuation runs later
```

A practical workflow looks like:

```text
caller
  │
  ▼
start operation
  │
  ├── success → resolve or return value
  ├── failure → reject or throw error
  ├── timeout → abort and classify
  └── cancellation → stop without false failure
```

The most important habits are:

1. Use `async` and `await` for readable asynchronous workflows.
2. Use `Promise.all()` for independent required operations.
3. Use `Promise.allSettled()` when partial results matter.
4. Do not use `forEach()` when you need to await asynchronous callbacks.
5. Give network operations deadlines.
6. Propagate `AbortSignal` through asynchronous layers.
7. Distinguish cancellation from failure.
8. Always clean up timers and event listeners.
9. Check `response.ok` after `fetch()`.
10. Test both success and failure paths.
11. Avoid overlapping polling operations unless explicitly intended.
12. Remember that promises coordinate work; they do not automatically make CPU-heavy code parallel.
