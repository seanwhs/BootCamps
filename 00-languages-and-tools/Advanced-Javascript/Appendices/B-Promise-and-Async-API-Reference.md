# Appendix B: Promise and Async API Reference

This appendix is a practical reference for JavaScript asynchronous programming.

It covers:

- Promise states.
- Promise creation.
- Promise resolution and rejection.
- `.then()`, `.catch()`, and `.finally()`.
- `async` and `await`.
- Promise combinators.
- `AbortController` and `AbortSignal`.
- Timeouts.
- Cancellation-aware operations.
- Error handling.
- Concurrency patterns.
- Common mistakes.
- Verification examples.

The examples use modern JavaScript and Node.js ECMAScript modules.

---

# B.1: Promise Fundamentals

## What Is a Promise?

A promise represents the eventual outcome of an asynchronous operation.

A promise has exactly one of three states:

```text
pending
   │
   ├── fulfilled
   └── rejected
```

Once a promise becomes fulfilled or rejected, it is **settled** and cannot change state again.

```js
const promise = new Promise((resolve, reject) => {
  resolve("first result");
  reject(new Error("ignored result"));
});
```

The rejection is ignored because the promise was already fulfilled.

---

## Promise Result States

### Pending

The operation has not completed.

```js
const pending = new Promise(() => {
  // The promise remains pending forever.
});
```

### Fulfilled

The operation completed successfully.

```js
const fulfilled = Promise.resolve("success");
```

### Rejected

The operation failed.

```js
const rejected = Promise.reject(
  new Error("operation failed")
);
```

---

## Promise Settlement Is Permanent

```js
const promise = new Promise((resolve, reject) => {
  resolve("accepted");

  setTimeout(() => {
    reject(new Error("too late"));
  }, 10);
});

promise.then(
  (value) => console.log("value:", value),
  (error) => console.log("error:", error.message)
);
```

Expected output:

```text
value: accepted
```

The later rejection has no effect.

---

# B.2: Creating Promises

## `Promise.resolve()`

`Promise.resolve()` creates an already-fulfilled promise.

```js
const promise = Promise.resolve(42);

promise.then((value) => {
  console.log(value);
});
```

Output:

```text
42
```

It is useful when an API should return a promise regardless of whether the result is immediately available.

```js
function getCachedValue(cache, key) {
  if (cache.has(key)) {
    return Promise.resolve(cache.get(key));
  }

  return loadValueFromNetwork(key);
}
```

---

## `Promise.reject()`

`Promise.reject()` creates an already-rejected promise.

```js
const promise = Promise.reject(
  new Error("request failed")
);

promise.catch((error) => {
  console.error(error.message);
});
```

Always attach a rejection handler when creating an intentionally rejected promise.

---

## The Promise Constructor

Use the `Promise` constructor when adapting callback-style or event-based APIs.

```js
function delay(milliseconds) {
  return new Promise((resolve) => {
    setTimeout(resolve, milliseconds);
  });
}
```

The constructor receives an executor function:

```js
new Promise((resolve, reject) => {
  // Start asynchronous work.
  // Call resolve(value) on success.
  // Call reject(error) on failure.
});
```

### Complete Example

```js
function readConfiguration() {
  return new Promise((resolve, reject) => {
    const configuration = {
      environment: "development"
    };

    if (!configuration.environment) {
      reject(new Error("environment is missing"));
      return;
    }

    resolve(configuration);
  });
}

readConfiguration()
  .then((configuration) => {
    console.log(configuration);
  })
  .catch((error) => {
    console.error(error);
  });
```

---

## Avoid the Promise Constructor Antipattern

This is unnecessary:

```js
function unnecessaryWrapper() {
  return new Promise((resolve, reject) => {
    fetch("/api/data")
      .then(resolve)
      .catch(reject);
  });
}
```

Return the existing promise instead:

```js
function betterFunction() {
  return fetch("/api/data");
}
```

Use a new promise only when you need to adapt a callback API, event, timer, or custom cancellation mechanism.

---

# B.3: Promise Handler Methods

## `.then()`

`.then()` registers a success handler and optionally a rejection handler.

```js
Promise.resolve("loaded").then((value) => {
  console.log(value);
});
```

It returns a new promise.

```js
const nextPromise = Promise.resolve(2).then((value) => {
  return value * 2;
});

nextPromise.then((value) => {
  console.log(value); // 4
});
```

---

## Returning a Value from `.then()`

The returned value fulfills the next promise.

```js
Promise.resolve(10)
  .then((value) => {
    return value + 5;
  })
  .then((value) => {
    console.log(value);
  });
```

Output:

```text
15
```

---

## Throwing from `.then()`

A thrown error rejects the next promise.

```js
Promise.resolve("input")
  .then(() => {
    throw new Error("transformation failed");
  })
  .catch((error) => {
    console.log(error.message);
  });
```

Output:

```text
transformation failed
```

---

## Returning a Promise from `.then()`

The next promise adopts the returned promise’s state.

```js
Promise.resolve("start")
  .then(() => {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve("finished later");
      }, 20);
    });
  })
  .then((value) => {
    console.log(value);
  });
```

Output:

```text
finished later
```

---

## `.catch()`

`.catch()` handles rejection.

```js
Promise.reject(new Error("service unavailable"))
  .catch((error) => {
    console.error("handled:", error.message);
  });
```

`.catch(handler)` is equivalent to:

```js
.then(undefined, handler)
```

Prefer `.catch()` because it communicates intent clearly.

---

## `.finally()`

`.finally()` runs whether the promise fulfills or rejects.

```js
let loading = true;

fetch("/api/metrics")
  .then((response) => response.json())
  .catch((error) => {
    console.error(error);
  })
  .finally(() => {
    loading = false;
  });
```

Use `finally` for cleanup:

- Hiding loading indicators.
- Releasing locks.
- Removing listeners.
- Clearing timers.
- Closing resources.

### `finally()` Does Not Receive the Result

```js
Promise.resolve("value").finally((value) => {
  console.log(value);
});
```

The output is:

```text
undefined
```

`finally()` receives no fulfillment value or rejection reason.

### `finally()` Preserves the Original Result

```js
Promise.resolve("value")
  .finally(() => {
    console.log("cleanup");
  })
  .then((value) => {
    console.log(value);
  });
```

Output:

```text
cleanup
value
```

### Throwing from `finally()`

If `finally()` throws, the resulting promise rejects with that new error.

```js
Promise.resolve("original")
  .finally(() => {
    throw new Error("cleanup failed");
  })
  .catch((error) => {
    console.log(error.message);
  });
```

Output:

```text
cleanup failed
```

Cleanup failures should be handled carefully because they can replace the original success or failure.

---

# B.4: Promise Chaining

## The Target

We will build a sequential asynchronous workflow.

## The Concept

A promise chain passes the output of one stage into the next.

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
        │
        ▼
parse response
```

## Implementation

### `appendix-b-chain.js`

```js
"use strict";

function loadConfiguration() {
  return Promise.resolve({
    baseUrl: "https://api.example.test",
    endpoint: "/metrics"
  });
}

function validateConfiguration(configuration) {
  if (
    !configuration ||
    typeof configuration.baseUrl !== "string" ||
    typeof configuration.endpoint !== "string"
  ) {
    throw new Error("invalid configuration");
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
  console.log("request:", request);

  return Promise.resolve({
    status: 200,
    body: {
      requestsPerSecond: 125
    }
  });
}

function parseResponse(response) {
  if (response.status !== 200) {
    throw new Error(`unexpected status: ${response.status}`);
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
node appendix-b-chain.js
```

Expected output:

```text
request: { url: 'https://api.example.test/metrics', method: 'GET' }
metrics: { requestsPerSecond: 125 }
workflow finished
```

---

# B.5: `async` Functions

## The Concept

An `async` function always returns a promise.

```js
async function getNumber() {
  return 42;
}

const result = getNumber();

console.log(result instanceof Promise); // true
```

An `async` function wraps returned values in fulfilled promises.

```js
async function getValue() {
  return "value";
}

getValue().then(console.log);
```

---

## Async Function Rejection

Throwing inside an `async` function produces a rejected promise.

```js
async function fail() {
  throw new Error("failed");
}

fail().catch((error) => {
  console.error(error.message);
});
```

This:

```js
async function fail() {
  throw new Error("failed");
}
```

behaves externally like:

```js
function fail() {
  return Promise.reject(new Error("failed"));
}
```

---

# B.6: `await`

## The Concept

`await` pauses the current async function until the awaited value settles.

```js
async function run() {
  const value = await Promise.resolve(42);
  console.log(value);
}

run();
```

`await` accepts ordinary values too:

```js
async function run() {
  const value = await 42;
  console.log(value);
}
```

The value is treated as an already-fulfilled promise.

---

## `await` and Execution Order

```js
async function run() {
  console.log("inside before await");

  await Promise.resolve();

  console.log("inside after await");
}

run();

console.log("outside");
```

Output:

```text
inside before await
outside
inside after await
```

The code after `await` runs later as a microtask.

---

## `await` and Errors

A rejected promise throws at the `await` expression.

```js
async function load() {
  try {
    const response = await Promise.reject(
      new Error("request failed")
    );

    return response;
  } catch (error) {
    console.error("caught:", error.message);
    return null;
  }
}

await load();
```

---

## Top-Level `await`

ECMAScript modules support top-level `await`.

```js
const configuration = await Promise.resolve({
  environment: "development"
});

console.log(configuration);
```

Use top-level `await` carefully. Module loading waits for it to complete, so a slow operation can delay every module importing it.

---

# B.7: Sequential and Concurrent `await`

## Sequential Operations

Use sequential execution when one operation depends on the previous result.

```js
const user = await loadUser();
const permissions = await loadPermissions(user.id);
```

The second operation needs `user.id`.

---

## Concurrent Independent Operations

Start independent operations before awaiting them together.

```js
const userPromise = loadUser();
const configurationPromise = loadConfiguration();

const [user, configuration] = await Promise.all([
  userPromise,
  configurationPromise
]);
```

Or:

```js
const [user, configuration] = await Promise.all([
  loadUser(),
  loadConfiguration()
]);
```

---

## The Accidental Sequential Pattern

This is slower when operations are independent:

```js
const metrics = await loadMetrics();
const health = await loadHealth();
const activity = await loadActivity();
```

Prefer:

```js
const [metrics, health, activity] = await Promise.all([
  loadMetrics(),
  loadHealth(),
  loadActivity()
]);
```

---

# B.8: Promise Combinators

## `Promise.all()`

### Behavior

- Accepts an iterable of values or promises.
- Fulfills when all inputs fulfill.
- Preserves input order.
- Rejects when the first input rejects.
- Does not cancel remaining operations.

### Example

```js
const results = await Promise.all([
  Promise.resolve("metrics"),
  Promise.resolve("health"),
  Promise.resolve("activity")
]);

console.log(results);
```

Output:

```text
[ 'metrics', 'health', 'activity' ]
```

### Empty Input

```js
const result = await Promise.all([]);

console.log(result); // []
```

### Failure

```js
try {
  await Promise.all([
    Promise.resolve("first"),
    Promise.reject(new Error("second failed")),
    Promise.resolve("third")
  ]);
} catch (error) {
  console.log(error.message);
}
```

Output:

```text
second failed
```

The third operation may still continue if it was already started.

---

## `Promise.allSettled()`

### Behavior

- Waits for every input to settle.
- Always fulfills with result records.
- Preserves input order.
- Useful when partial results matter.

### Example

```js
const results = await Promise.allSettled([
  Promise.resolve("available"),
  Promise.reject(new Error("unavailable"))
]);

console.dir(results, { depth: null });
```

Output resembles:

```text
[
  { status: 'fulfilled', value: 'available' },
  {
    status: 'rejected',
    reason: Error: unavailable
  }
]
```

### Safe Result Processing

```js
for (const result of results) {
  if (result.status === "fulfilled") {
    console.log("value:", result.value);
  } else {
    console.error("error:", result.reason);
  }
}
```

---

## `Promise.race()`

### Behavior

- Settles when the first input settles.
- The first fulfillment fulfills the returned promise.
- The first rejection rejects the returned promise.
- Does not cancel losing operations.

### Example

```js
const result = await Promise.race([
  new Promise((resolve) => {
    setTimeout(() => resolve("slow"), 50);
  }),

  new Promise((resolve) => {
    setTimeout(() => resolve("fast"), 10);
  })
]);

console.log(result); // fast
```

### Timeout Pattern

```js
function timeout(milliseconds) {
  return new Promise((_, reject) => {
    setTimeout(() => {
      reject(new Error("timed out"));
    }, milliseconds);
  });
}

try {
  const result = await Promise.race([
    loadData(),
    timeout(1_000)
  ]);

  console.log(result);
} catch (error) {
  console.error(error.message);
}
```

For production use, prefer cancelling the underlying operation as well.

---

## `Promise.any()`

### Behavior

- Fulfills when the first input fulfills.
- Ignores rejected inputs while waiting.
- Rejects only when all inputs reject.
- Uses `AggregateError` when all inputs fail.

### Example

```js
const result = await Promise.any([
  Promise.reject(new Error("primary failed")),
  Promise.resolve("backup succeeded")
]);

console.log(result); // backup succeeded
```

### All Fail

```js
try {
  await Promise.any([
    Promise.reject(new Error("first failed")),
    Promise.reject(new Error("second failed"))
  ]);
} catch (error) {
  console.log(error.name); // AggregateError
  console.log(error.errors);
}
```

---

## `Promise.withResolvers()`

In modern runtimes that support it, `Promise.withResolvers()` returns the promise together with its resolve and reject functions.

```js
const { promise, resolve, reject } = Promise.withResolvers();

setTimeout(() => {
  resolve("completed");
}, 20);

console.log(await promise);
```

If runtime compatibility matters, use the traditional constructor pattern:

```js
function createDeferred() {
  let resolve;
  let reject;

  const promise = new Promise((promiseResolve, promiseReject) => {
    resolve = promiseResolve;
    reject = promiseReject;
  });

  return {
    promise,
    resolve,
    reject
  };
}
```

Do not use externally controlled promises without a clear ownership model. They can make control flow difficult to follow.

---

# B.9: `AbortController` and `AbortSignal`

## Basic Cancellation

```js
const controller = new AbortController();

controller.signal.addEventListener("abort", () => {
  console.log("aborted");
});

controller.abort();
```

The signal’s state changes permanently:

```js
console.log(controller.signal.aborted); // true
```

An `AbortController` cannot be reset. Create a new controller for a new operation.

---

## Passing a Signal to `fetch()`

```js
const controller = new AbortController();

const request = fetch("https://example.com/data", {
  signal: controller.signal
});

controller.abort();

try {
  await request;
} catch (error) {
  console.log(error.name); // AbortError
}
```

---

## Check Before Starting

```js
async function loadData(signal) {
  if (signal.aborted) {
    throw signal.reason ?? new Error("operation already aborted");
  }

  return fetch("https://example.com/data", { signal });
}
```

---

## Listen for Abort

```js
function cancellableOperation(signal) {
  return new Promise((resolve, reject) => {
    const timerId = setTimeout(() => {
      signal.removeEventListener("abort", handleAbort);
      resolve("completed");
    }, 100);

    function handleAbort() {
      clearTimeout(timerId);
      reject(signal.reason ?? new Error("cancelled"));
    }

    signal.addEventListener("abort", handleAbort, {
      once: true
    });
  });
}
```

The operation must clean up its timer and listener in every path.

---

## Abort Reasons

Modern runtimes support an optional reason:

```js
const controller = new AbortController();

controller.abort(
  new Error("user navigated away")
);

console.log(controller.signal.reason.message);
```

Use meaningful reasons when useful, but do not expose sensitive internal data to users.

---

## `AbortSignal.timeout()`

Where supported, `AbortSignal.timeout()` creates a signal that aborts automatically.

```js
try {
  const response = await fetch("https://example.com/data", {
    signal: AbortSignal.timeout(2_000)
  });

  console.log(response.status);
} catch (error) {
  console.error(error.name);
}
```

This is convenient for request deadlines.

---

## `AbortSignal.any()`

Where supported, `AbortSignal.any()` combines multiple signals.

The combined signal aborts when any input signal aborts.

```js
const userController = new AbortController();
const timeoutSignal = AbortSignal.timeout(2_000);

const combinedSignal = AbortSignal.any([
  userController.signal,
  timeoutSignal
]);

try {
  await fetch("https://example.com/data", {
    signal: combinedSignal
  });
} catch (error) {
  console.error("request stopped:", error.name);
}
```

This is useful when an operation should stop because of:

- User cancellation.
- Timeout.
- Application shutdown.
- Parent workflow cancellation.

---

# B.10: Cancellation-Aware Delay

## Complete Implementation

### `cancellable-delay.js`

```js
"use strict";

export function cancellableDelay(
  milliseconds,
  value,
  signal
) {
  if (
    !Number.isFinite(milliseconds) ||
    milliseconds < 0
  ) {
    throw new RangeError(
      "milliseconds must be a non-negative finite number"
    );
  }

  if (!(signal instanceof AbortSignal)) {
    throw new TypeError("signal must be an AbortSignal");
  }

  return new Promise((resolve, reject) => {
    let settled = false;

    const cleanup = () => {
      clearTimeout(timerId);
      signal.removeEventListener("abort", handleAbort);
    };

    const resolveOnce = () => {
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
        signal.reason ?? new DOMException(
          "The operation was aborted",
          "AbortError"
        )
      );
    };

    if (signal.aborted) {
      handleAbort();
      return;
    }

    const timerId = setTimeout(resolveOnce, milliseconds);

    signal.addEventListener("abort", handleAbort, {
      once: true
    });
  });
}
```

## Verification

```bash
node --input-type=module <<'EOF'
import { cancellableDelay } from "./cancellable-delay.js";

const controller = new AbortController();

const operation = cancellableDelay(
  1_000,
  "finished",
  controller.signal
);

setTimeout(() => {
  controller.abort();
}, 20);

try {
  await operation;
} catch (error) {
  console.log(error.name);
}
EOF
```

Expected output:

```text
AbortError
```

---

# B.11: Timeouts That Cancel Work

## The Problem with Raw `Promise.race()`

This reports a timeout:

```js
await Promise.race([
  fetch(url),
  timeoutPromise
]);
```

But the fetch may continue running after the timeout promise rejects.

The better design creates a child controller and aborts the operation when the deadline expires.

## Complete Implementation

### `with-timeout.js`

```js
"use strict";

export async function withTimeout(
  operation,
  milliseconds,
  parentSignal
) {
  if (typeof operation !== "function") {
    throw new TypeError("operation must be a function");
  }

  if (
    !Number.isFinite(milliseconds) ||
    milliseconds <= 0
  ) {
    throw new RangeError(
      "milliseconds must be a positive finite number"
    );
  }

  if (
    parentSignal !== undefined &&
    !(parentSignal instanceof AbortSignal)
  ) {
    throw new TypeError(
      "parentSignal must be an AbortSignal"
    );
  }

  const controller = new AbortController();
  let timerId;

  function abortFromParent() {
    controller.abort(
      parentSignal.reason ??
      new DOMException("Parent operation aborted", "AbortError")
    );
  }

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

  timerId = setTimeout(() => {
    controller.abort(
      new DOMException(
        `Operation timed out after ${milliseconds} ms`,
        "TimeoutError"
      )
    );
  }, milliseconds);

  try {
    return await operation(controller.signal);
  } finally {
    clearTimeout(timerId);

    if (parentSignal) {
      parentSignal.removeEventListener(
        "abort",
        abortFromParent
      );
    }
  }
}
```

## Verification

```bash
node --input-type=module <<'EOF'
import { withTimeout } from "./with-timeout.js";

try {
  await withTimeout(
    async (signal) => {
      await new Promise((resolve, reject) => {
        const timer = setTimeout(resolve, 1_000);

        signal.addEventListener("abort", () => {
          clearTimeout(timer);
          reject(signal.reason);
        }, { once: true });
      });
    },
    20
  );
} catch (error) {
  console.log(error.name);
  console.log(error.message);
}
EOF
```

Expected output:

```text
TimeoutError
Operation timed out after 20 ms
```

---

# B.12: Error Handling Patterns

## Handle at the Correct Boundary

```js
async function loadDashboard() {
  const results = await Promise.allSettled([
    loadMetrics(),
    loadHealth()
  ]);

  return results;
}
```

The function uses `allSettled()` because each dashboard section can fail independently.

A higher-level boundary can handle unexpected failures:

```js
try {
  const dashboard = await loadDashboard();
  renderDashboard(dashboard);
} catch (error) {
  showGlobalFailure(error);
}
```

---

## Do Not Catch and Ignore

Avoid:

```js
try {
  await loadData();
} catch {
  // Nothing happens.
}
```

This hides failures and makes debugging difficult.

Prefer:

```js
try {
  await loadData();
} catch (error) {
  logger.error("data loading failed", {
    name: error.name,
    message: error.message
  });

  showFallbackState();
}
```

---

## Rethrow After Adding Context

```js
async function loadMetrics() {
  try {
    return await requestMetrics();
  } catch (error) {
    throw new Error("failed to load metrics", {
      cause: error
    });
  }
}
```

The `cause` preserves the original failure.

---

## Handle Cancellation Separately

```js
try {
  await loadData(signal);
} catch (error) {
  if (error.name === "AbortError") {
    return;
  }

  throw error;
}
```

Cancellation usually means the caller no longer needs the result. It should not necessarily appear as an application failure.

---

## `unhandledRejection`

Avoid leaving promises without handlers:

```js
void operation().catch((error) => {
  logger.error("background operation failed", error);
});
```

If intentionally starting fire-and-forget work, make the error policy explicit.

---

# B.13: Fire-and-Forget Operations

## The Problem

This starts an asynchronous operation without observing its result:

```js
sendTelemetry();
```

If `sendTelemetry()` rejects, the rejection may become unhandled.

## Safer Pattern

```js
void sendTelemetry().catch((error) => {
  logger.warn("telemetry failed", {
    message: error.message
  });
});
```

The `void` communicates that the returned promise is intentionally not awaited, while `.catch()` handles failure.

## Helper

```js
function startBackgroundTask(task, logger) {
  if (typeof task !== "function") {
    throw new TypeError("task must be a function");
  }

  void Promise.resolve()
    .then(task)
    .catch((error) => {
      logger.error("background task failed", error);
    });
}
```

Usage:

```js
startBackgroundTask(
  () => sendTelemetry(),
  console
);
```

---

# B.14: Limiting Concurrency

## The Target

We will implement a simple concurrency limiter.

## The Concept

`Promise.all()` starts all supplied operations. That is appropriate for a small number of independent operations, but it can overload a service when processing hundreds or thousands of items.

A concurrency limiter allows only a fixed number of operations to run at once.

```text
maximum concurrency: 2

task A ────────────────
task B ─────────
task C       ─────────────
task D       ───────
```

## Implementation

### `concurrency-limit.js`

```js
"use strict";

export function createConcurrencyLimiter(maximumConcurrency) {
  if (
    !Number.isInteger(maximumConcurrency) ||
    maximumConcurrency < 1
  ) {
    throw new RangeError(
      "maximumConcurrency must be a positive integer"
    );
  }

  let activeCount = 0;
  const queue = [];

  function startNext() {
    while (
      activeCount < maximumConcurrency &&
      queue.length > 0
    ) {
      const task = queue.shift();
      activeCount += 1;

      Promise.resolve()
        .then(task.operation)
        .then(task.resolve, task.reject)
        .finally(() => {
          activeCount -= 1;
          startNext();
        });
    }
  }

  function schedule(operation) {
    if (typeof operation !== "function") {
      return Promise.reject(
        new TypeError("operation must be a function")
      );
    }

    return new Promise((resolve, reject) => {
      queue.push({
        operation,
        resolve,
        reject
      });

      startNext();
    });
  }

  return Object.freeze({
    schedule,

    get activeCount() {
      return activeCount;
    },

    get queuedCount() {
      return queue.length;
    }
  });
}

const limiter = createConcurrencyLimiter(2);
let activeOperations = 0;
let maximumObserved = 0;

function task(name, milliseconds) {
  return limiter.schedule(async () => {
    activeOperations += 1;
    maximumObserved = Math.max(
      maximumObserved,
      activeOperations
    );

    console.log("started:", name);

    await new Promise((resolve) => {
      setTimeout(resolve, milliseconds);
    });

    activeOperations -= 1;
    console.log("finished:", name);

    return name;
  });
}

const results = await Promise.all([
  task("A", 40),
  task("B", 20),
  task("C", 10),
  task("D", 10)
]);

console.log({
  results,
  maximumObserved
});
```

## Verification

Run:

```bash
node concurrency-limit.js
```

Expected behavior:

```text
maximumObserved: 2
```

No more than two operations should be active at once.

---

# B.15: Retry with Async Operations

## Basic Retry

```js
async function retryOperation(operation, maximumAttempts) {
  let lastError;

  for (
    let attempt = 1;
    attempt <= maximumAttempts;
    attempt += 1
  ) {
    try {
      return await operation(attempt);
    } catch (error) {
      lastError = error;
    }
  }

  throw lastError;
}
```

## Production Considerations

A production retry utility should also support:

- Retry classification.
- Backoff.
- Jitter.
- Cancellation.
- Overall deadline.
- Logging.
- Server-provided retry delays.
- Idempotency requirements.

Example:

```js
const result = await retry({
  operation: ({ signal }) =>
    requestData({ signal }),

  maximumAttempts: 3,

  isRetryable: (error) =>
    error.name === "TimeoutError" ||
    error.name === "TemporaryDependencyError",

  signal,

  onRetry: ({ attempt, delayMilliseconds }) => {
    logger.warn("retrying", {
      attempt,
      delayMilliseconds
    });
  }
});
```

---

# B.16: Async Iteration

## Async Iterable

An async iterable produces values asynchronously.

```js
async function* generateNumbers() {
  yield 1;
  yield 2;
  yield 3;
}
```

Consume it with `for await...of`:

```js
for await (const number of generateNumbers()) {
  console.log(number);
}
```

---

## Async Generator with Delay

```js
async function* pollValues(signal) {
  let value = 0;

  while (!signal.aborted) {
    await new Promise((resolve, reject) => {
      const timer = setTimeout(resolve, 100);

      signal.addEventListener("abort", () => {
        clearTimeout(timer);
        reject(signal.reason);
      }, { once: true });
    });

    value += 1;
    yield value;
  }
}
```

A production async generator should define clearly:

- How it stops.
- How it handles errors.
- Whether it retries.
- Whether it supports backpressure.
- Who owns the iterator.

---

## Async Iterator Cleanup

When a `for await...of` loop exits early, the iterator may receive an opportunity to clean up through `return()`.

```js
async function* resources() {
  try {
    yield "resource";
  } finally {
    console.log("resource cleanup");
  }
}

for await (const value of resources()) {
  console.log(value);
  break;
}
```

Expected output:

```text
resource
resource cleanup
```

---

# B.17: Promise-Based Queue

## The Concept

A promise queue lets callers add asynchronous work while a manager controls execution order.

## Implementation

### `promise-queue.js`

```js
"use strict";

export function createPromiseQueue() {
  let tail = Promise.resolve();
  let pendingCount = 0;

  function add(operation) {
    if (typeof operation !== "function") {
      return Promise.reject(
        new TypeError("operation must be a function")
      );
    }

    pendingCount += 1;

    const result = tail.then(operation);

    /*
     * The queue continues even if the previous operation rejects. Each caller
     * still receives the correct result or rejection for its own operation.
     */
    tail = result.catch(() => {});

    return result.finally(() => {
      pendingCount -= 1;
    });
  }

  return Object.freeze({
    add,

    get pendingCount() {
      return pendingCount;
    }
  });
}

const queue = createPromiseQueue();

const first = queue.add(async () => {
  console.log("first started");

  await new Promise((resolve) => {
    setTimeout(resolve, 20);
  });

  console.log("first finished");
  return "first result";
});

const second = queue.add(async () => {
  console.log("second started");
  return "second result";
});

console.log(await first);
console.log(await second);
```

## Verification

Run:

```bash
node promise-queue.js
```

Expected order:

```text
first started
first finished
first result
second started
second result
```

---

# B.18: Common Async Mistakes

## Mistake 1: Forgetting `await`

```js
async function load() {
  const data = fetchData();
  console.log(data.value);
}
```

`data` is a promise, not the resolved value.

Correct:

```js
async function load() {
  const data = await fetchData();
  console.log(data.value);
}
```

---

## Mistake 2: Using `forEach()` with `async`

This does not wait for asynchronous callbacks:

```js
items.forEach(async (item) => {
  await processItem(item);
});

console.log("finished");
```

The `"finished"` log may run before processing completes.

### Sequential Correct Version

```js
for (const item of items) {
  await processItem(item);
}
```

### Concurrent Correct Version

```js
await Promise.all(
  items.map((item) => processItem(item))
);
```

---

## Mistake 3: Accidental Sequential Requests

```js
const first = await loadFirst();
const second = await loadSecond();
```

If independent, use:

```js
const [first, second] = await Promise.all([
  loadFirst(),
  loadSecond()
]);
```

---

## Mistake 4: Catching Too Early

```js
async function load() {
  try {
    return await request();
  } catch {
    return null;
  }
}
```

This may hide the distinction between:

- Missing data.
- Network failure.
- Invalid response.
- Cancellation.
- Programming error.

Return a structured result or rethrow with context when the caller needs the failure information.

---

## Mistake 5: Using `Promise.race()` Without Cancellation

```js
await Promise.race([
  slowOperation(),
  timeout()
]);
```

The slow operation may continue.

Use an `AbortSignal` where possible.

---

## Mistake 6: Retrying Every Error

```js
while (true) {
  try {
    return await operation();
  } catch {
    // Retry everything forever.
  }
}
```

This can cause:

- Infinite loops.
- Retry storms.
- Duplicate side effects.
- Increased dependency load.
- Slow user-visible failures.

---

## Mistake 7: Swallowing Cancellation

```js
try {
  await operation(signal);
} catch {
  return fallbackData;
}
```

This may turn intentional cancellation into a misleading fallback.

Prefer:

```js
try {
  await operation(signal);
} catch (error) {
  if (error.name === "AbortError") {
    throw error;
  }

  return fallbackData;
}
```

---

# B.19: Async API Decision Table

| Requirement | Recommended approach |
|---|---|
| Convert a value to a promise | `Promise.resolve()` |
| Create a rejected promise | `Promise.reject()` |
| Adapt a callback API | `new Promise()` |
| Transform one async result | `.then()` or `await` |
| Handle failure | `.catch()` or `try/catch` |
| Always clean up | `.finally()` |
| Require every operation | `Promise.all()` |
| Preserve partial results | `Promise.allSettled()` |
| Enforce first settlement | `Promise.race()` |
| Accept first success | `Promise.any()` |
| Cancel an operation | `AbortController` |
| Cancel at a deadline | `AbortSignal.timeout()` or a child controller |
| Combine cancellation sources | `AbortSignal.any()` |
| Limit simultaneous operations | Concurrency limiter |
| Process values over time | Async iterator |
| Serialize async tasks | Promise queue |

---

# B.20: Promise Combinator Verification Program

## Implementation

### `promise-combinators-check.js`

```js
"use strict";

function delay(milliseconds, value, shouldReject = false) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      if (shouldReject) {
        reject(new Error(`${value} failed`));
        return;
      }

      resolve(value);
    }, milliseconds);
  });
}

const allResults = await Promise.all([
  delay(30, "metrics"),
  delay(10, "health")
]);

console.log("all:", allResults);

const settledResults = await Promise.allSettled([
  delay(10, "activity"),
  delay(20, "notifications", true)
]);

console.log(
  "allSettled:",
  settledResults.map((result) => result.status)
);

try {
  await Promise.race([
    delay(50, "slow"),
    delay(10, "fast failure", true)
  ]);
} catch (error) {
  console.log("race:", error.message);
}

const anyResult = await Promise.any([
  delay(10, "first failure", true),
  delay(20, "backup success")
]);

console.log("any:", anyResult);
```

## Verification

Run:

```bash
node promise-combinators-check.js
```

Expected output:

```text
all: [ 'metrics', 'health' ]
allSettled: [ 'fulfilled', 'rejected' ]
race: fast failure failed
any: backup success
```

---

# B.21: Testing Async Code

## Node.js Built-In Test Runner

### `async.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

function delay(milliseconds, value) {
  return new Promise((resolve) => {
    setTimeout(() => resolve(value), milliseconds);
  });
}

test("delay resolves with its value", async () => {
  const result = await delay(5, "completed");

  assert.equal(result, "completed");
});

test("Promise.all preserves input order", async () => {
  const result = await Promise.all([
    delay(20, "slow"),
    delay(5, "fast")
  ]);

  assert.deepEqual(result, ["slow", "fast"]);
});

test("rejected promises can be asserted", async () => {
  await assert.rejects(
    Promise.reject(new Error("expected failure")),
    {
      message: "expected failure"
    }
  );
});
```

## Verification

Run:

```bash
node --test async.test.js
```

Expected output indicates that all tests passed.

---

# B.22: Testing Cancellation

## Implementation

### `cancellation.test.js`

```js
"use strict";

import test from "node:test";
import assert from "node:assert/strict";

function cancellableDelay(milliseconds, signal) {
  return new Promise((resolve, reject) => {
    const timerId = setTimeout(resolve, milliseconds);

    function handleAbort() {
      clearTimeout(timerId);

      const error = new Error("cancelled");
      error.name = "AbortError";
      reject(error);
    }

    if (signal.aborted) {
      handleAbort();
      return;
    }

    signal.addEventListener("abort", handleAbort, {
      once: true
    });
  });
}

test("operation rejects with AbortError when cancelled", async () => {
  const controller = new AbortController();

  const promise = cancellableDelay(
    1_000,
    controller.signal
  );

  controller.abort();

  await assert.rejects(promise, {
    name: "AbortError"
  });
});
```

## Verification

Run:

```bash
node --test cancellation.test.js
```

---

# B.23: Production Async Checklist

Before shipping asynchronous code, verify:

## Promise Behavior

- Does every returned promise eventually settle?
- Can a promise remain pending forever?
- Are rejection paths handled?
- Are values returned from `.then()` correctly?
- Could `finally()` replace the original error?

## Concurrency

- Which operations are independent?
- Are independent operations running concurrently?
- Could `Promise.all()` reject too early?
- Are partial results needed?
- Could too many operations run at once?

## Cancellation

- Can obsolete operations be stopped?
- Is the signal passed through all relevant layers?
- Are timers and listeners cleaned up?
- Is cancellation distinguished from failure?

## Timeouts

- Does the timeout cancel underlying work?
- Is there an overall deadline?
- Do retries fit within the deadline?
- Are timeout errors classified correctly?

## Retries

- Is the error retryable?
- Is the operation idempotent?
- Are attempts bounded?
- Is backoff applied?
- Is jitter applied?
- Does cancellation stop retry delays?

## Errors

- Is the error handled at the appropriate boundary?
- Is useful context preserved?
- Are errors logged without sensitive data?
- Are fire-and-forget promises observed?
- Are process-level handlers only a final safety net?

---

# B.24: Final Async Reference

The most important async patterns are:

## Transform One Result

```js
const transformed = await transform(await load());
```

Prefer clearer intermediate variables for complex workflows:

```js
const loaded = await load();
const transformed = await transform(loaded);
```

## Run Independent Work Concurrently

```js
const [first, second] = await Promise.all([
  loadFirst(),
  loadSecond()
]);
```

## Preserve Partial Results

```js
const results = await Promise.allSettled([
  loadFirst(),
  loadSecond()
]);
```

## Cancel Obsolete Work

```js
const controller = new AbortController();

const promise = loadData(controller.signal);

controller.abort();
```

## Enforce a Cancellable Deadline

```js
const result = await withTimeout(
  (signal) => loadData(signal),
  5_000
);
```

## Handle Background Work

```js
void sendTelemetry().catch((error) => {
  logger.warn("telemetry failed", error);
});
```

## Limit Concurrency

```js
const limiter = createConcurrencyLimiter(5);

const results = await Promise.all(
  items.map((item) =>
    limiter.schedule(() => processItem(item))
  )
);
```

## Retry Carefully

```js
const result = await retry({
  operation,
  maximumAttempts: 3,
  isRetryable,
  signal
});
```
