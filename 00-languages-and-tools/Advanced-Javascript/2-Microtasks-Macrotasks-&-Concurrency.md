# Part 2: Microtasks, Macrotasks & Concurrency

JavaScript is often described as single-threaded. That means one JavaScript instruction runs at a time on the main execution thread.

However, JavaScript applications still perform many operations that take time:

- Network requests.
- File-system operations.
- Timers.
- Database calls.
- User interactions.
- Stream processing.

The runtime handles these operations outside the immediate JavaScript call stack and later schedules their callbacks.

This part explains how that scheduling works and how to coordinate asynchronous operations safely.

We will build:

- An event-loop ordering laboratory.
- A microtask and macrotask demonstration.
- A concurrency utility module.
- Examples using all four major promise combinators.
- A cancellation-aware operation using `AbortController`.
- A timeout helper.
- A local asynchronous service simulation.
- Verification commands for every step.

---

# Part 2.1: Add Asynchronous Commands

## The Target

We will update `package.json` with commands for the new asynchronous examples.

## The Concept

A package script is a named shortcut for a repeatable terminal command.

Instead of repeatedly typing:

```bash
node src/part-2/event-loop-order.js
```

we can use:

```bash
npm run event-loop
```

This is useful because a project should make its important checks easy to discover and repeat.

## Implementation

### `package.json`

Replace the current file with:

```json
{
  "name": "runtime-monitor",
  "version": "1.0.0",
  "private": true,
  "description": "Advanced JavaScript runtime and architecture learning project",
  "type": "module",
  "scripts": {
    "context": "node src/part-1/execution-contexts.js",
    "hoisting": "node src/part-1/hoisting.js",
    "closures": "node src/part-1/closures.js",
    "this": "node src/part-1/this-binding.js",
    "memory": "node --expose-gc src/part-1/memory-retention.js",
    "event-loop": "node src/part-2/event-loop-order.js",
    "microtasks": "node src/part-2/microtask-starvation.js",
    "concurrency": "node src/part-2/promise-concurrency.js",
    "cancellation": "node src/part-2/cancellation.js",
    "timeout": "node src/part-2/timeout.js",
    "workflow": "node src/part-2/async-workflow.js"
  },
  "engines": {
    "node": ">=20.0.0"
  }
}
```

Create the new directory:

```bash
mkdir -p src/part-2
```

## Verification

Run:

```bash
npm run
```

You should see the new scripts listed.

---

# Part 2.2: Synchronous Execution Comes First

## The Target

We will create a program that shows synchronous statements completing before asynchronous callbacks begin.

## The Concept

Registering asynchronous work does not immediately execute its callback.

Consider a timer:

```js
setTimeout(() => {
  console.log("timer callback");
}, 0);
```

The `0` does not mean “run this before the next line.” It means “make this callback eligible after at least zero milliseconds, subject to runtime scheduling.”

The current synchronous code must finish first.

The runtime behaves like a single cashier:

1. The cashier finishes serving the current customer.
2. Waiting tasks are placed into queues.
3. The next eligible task is selected.
4. Its callback runs to completion.

## Implementation

### `src/part-2/synchronous-first.js`

```js
"use strict";

console.log("1. synchronous statement");

setTimeout(() => {
  console.log("4. timer callback");
}, 0);

Promise.resolve().then(() => {
  console.log("3. promise callback");
});

console.log("2. synchronous statement");
```

## Verification

Run:

```bash
node src/part-2/synchronous-first.js
```

Expected output:

```text
1. synchronous statement
2. synchronous statement
3. promise callback
4. timer callback
```

The two synchronous statements execute first, even though the asynchronous operations were registered between them.

---

# Part 2.3: Microtasks and Macrotasks

## The Target

We will compare:

- Synchronous code.
- Promise callbacks.
- `queueMicrotask()`.
- `setTimeout()`.
- `setImmediate()` in Node.js.

## The Concept

A **microtask** is a small unit of deferred work that runs after the current synchronous task completes and before the runtime proceeds to a later task.

Common microtask sources include:

- Promise reactions, such as `.then()` and `.catch()`.
- `queueMicrotask()`.
- `MutationObserver` callbacks in browsers.

A **macrotask**, often called a task, is a larger scheduled unit of work.

Common examples include:

- Timer callbacks.
- Some I/O callbacks.
- User-interface events.
- Message events.

The simplified ordering is:

```text
Run current synchronous code
        │
        ▼
Drain all microtasks
        │
        ▼
Run a later task such as a timer
        │
        ▼
Drain microtasks created by that task
```

Microtasks have priority over later timer callbacks. This is useful for promise behavior, but an endless chain of microtasks can delay timers and user-interface work.

## Implementation

### `src/part-2/event-loop-order.js`

```js
"use strict";

const events = [];

function record(label) {
  events.push(label);
  console.log(`${events.length}. ${label}`);
}

record("synchronous: start");

queueMicrotask(() => {
  record("microtask: queueMicrotask");

  /*
   * This microtask is added while the runtime is draining the microtask queue.
   * It will also run before the timer callback.
   */
  queueMicrotask(() => {
    record("microtask: nested queueMicrotask");
  });
});

Promise.resolve().then(() => {
  record("microtask: Promise.then");

  /*
   * Promise callbacks also add work to the same microtask queue.
   */
  return Promise.resolve();
}).then(() => {
  record("microtask: chained Promise.then");
});

setTimeout(() => {
  record("task: setTimeout");

  /*
   * Microtasks created inside a timer are drained before another later task.
   */
  queueMicrotask(() => {
    record("microtask: created inside setTimeout");
  });
}, 0);

if (typeof setImmediate === "function") {
  setImmediate(() => {
    record("task: setImmediate");
  });
}

record("synchronous: end");

setTimeout(() => {
  console.log("\nFinal event order:");
  console.log(events.join(" -> "));
}, 50);
```

## Verification

Run:

```bash
npm run event-loop
```

The first lines should be:

```text
1. synchronous: start
2. synchronous: end
```

The promise and `queueMicrotask()` callbacks should run before the timer callback.

The relative ordering of `setTimeout(..., 0)` and `setImmediate()` can vary depending on where they are scheduled in Node.js. Do not build application logic that depends on their relative ordering unless the runtime phase is explicitly understood.

---

# Part 2.4: Microtask Starvation

## The Target

We will demonstrate why an unbounded microtask chain can delay a timer.

## The Concept

Because microtasks are drained before the runtime moves on to later tasks, code that continually schedules more microtasks can prevent timers and I/O callbacks from running.

This is called **starvation**.

It is similar to a receptionist who keeps accepting urgent internal messages and never returns to the people waiting in the lobby.

The problem is not that microtasks are bad. The problem is an unbounded chain with no opportunity for other tasks to run.

## Implementation

### `src/part-2/microtask-starvation.js`

```js
"use strict";

const MAX_MICROTASKS = 10_000;
let processedMicrotasks = 0;
let timerRan = false;

const startTime = Date.now();

setTimeout(() => {
  timerRan = true;

  const elapsedMilliseconds = Date.now() - startTime;

  console.log(
    `timer ran after ${elapsedMilliseconds} ms and ${processedMicrotasks} microtasks`
  );
}, 0);

function processMicrotaskBatch() {
  processedMicrotasks += 1;

  if (processedMicrotasks < MAX_MICROTASKS) {
    queueMicrotask(processMicrotaskBatch);
  }
}

queueMicrotask(processMicrotaskBatch);

setTimeout(() => {
  console.log(`timer status observed later: ${timerRan}`);
}, 100);
```

## Verification

Run:

```bash
npm run microtasks
```

You should see that the timer runs only after the microtask chain finishes.

The exact elapsed time varies by machine, but the ordering demonstrates the important point:

```text
microtasks finish first
timer runs afterward
```

## Production Rule

Do not process unbounded work in a single microtask chain.

For large workloads, periodically yield to the task queue:

```js
function yieldToRuntime() {
  return new Promise((resolve) => {
    setTimeout(resolve, 0);
  });
}
```

A batch-processing loop can then yield:

```js
async function processInBatches(items, processItem) {
  for (let index = 0; index < items.length; index += 1) {
    processItem(items[index]);

    if (index > 0 && index % 100 === 0) {
      await yieldToRuntime();
    }
  }
}
```

Yielding allows timers, input events, and I/O callbacks to receive processing time.

---

# Part 2.5: A Promise-Based Delay Utility

## The Target

We will create a reusable delay function.

## The Concept

A promise represents the eventual result of an operation.

A delay promise does not perform useful business work, but it is helpful for:

- Demonstrations.
- Tests.
- Retry backoff.
- Simulated asynchronous services.
- Rate-limiting workflows.

The function will return a promise that resolves after a specified duration.

Input validation is important because invalid delay values can make tests unreliable or cause confusing runtime behavior.

## Implementation

### `src/part-2/delay.js`

```js
"use strict";

export function delay(milliseconds, value) {
  if (!Number.isFinite(milliseconds) || milliseconds < 0) {
    throw new RangeError("milliseconds must be a non-negative finite number");
  }

  return new Promise((resolve) => {
    setTimeout(() => {
      resolve(value);
    }, milliseconds);
  });
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { delay } from "./src/part-2/delay.js";

const start = Date.now();
const result = await delay(25, "completed");
const elapsed = Date.now() - start;

console.log({ result, elapsedAtLeast25ms: elapsed >= 25 });
EOF
```

Expected output:

```text
{ result: 'completed', elapsedAtLeast25ms: true }
```

---

# Part 2.6: `Promise.all()`

## The Target

We will run independent asynchronous operations concurrently with `Promise.all()`.

## The Concept

`Promise.all()` is like sending several workers to collect different items and waiting until every required item arrives.

It:

- Starts independent operations when the promises are created.
- Resolves with an ordered array when all operations resolve.
- Rejects as soon as one operation rejects.
- Does not automatically cancel the remaining operations.

The result order matches the input order, not completion order.

## Implementation

### `src/part-2/promise-all.js`

```js
"use strict";

import { delay } from "./delay.js";

async function loadService(name, milliseconds) {
  console.log(`${name}: started`);

  const result = await delay(milliseconds, {
    service: name,
    status: "healthy"
  });

  console.log(`${name}: completed`);
  return result;
}

async function run() {
  const start = Date.now();

  /*
   * Calling all functions before awaiting Promise.all starts their work
   * concurrently. If we awaited each call separately, the total time would
   * be approximately the sum of all delays.
   */
  const results = await Promise.all([
    loadService("metrics", 80),
    loadService("health", 30),
    loadService("activity", 50)
  ]);

  const elapsed = Date.now() - start;

  console.log("results:", results);
  console.log(`elapsed milliseconds: ${elapsed}`);
}

run().catch((error) => {
  console.error("workflow failed:", error);
  process.exitCode = 1;
});
```

## Verification

Run:

```bash
node src/part-2/promise-all.js
```

You should see:

- `health` complete first.
- `activity` complete second.
- `metrics` complete last.
- The result array ordered as metrics, health, activity.
- Total elapsed time close to the slowest operation, approximately 80 milliseconds, rather than 160 milliseconds.

---

# Part 2.7: The Sequential Mistake

## The Target

We will compare concurrent and sequential execution.

## The Concept

These two patterns are different:

### Concurrent

```js
await Promise.all([
  loadA(),
  loadB(),
  loadC()
]);
```

### Sequential

```js
const a = await loadA();
const b = await loadB();
const c = await loadC();
```

Sequential execution is correct when later work depends on earlier work. It is wasteful when operations are independent.

## Implementation

### `src/part-2/concurrent-vs-sequential.js`

```js
"use strict";

import { delay } from "./delay.js";

async function runOperation(name, milliseconds) {
  await delay(milliseconds);
  return name;
}

async function measure(label, operation) {
  const start = Date.now();
  const result = await operation();
  const elapsed = Date.now() - start;

  console.log(`${label}:`, {
    result,
    elapsedMilliseconds: elapsed
  });
}

await measure("sequential", async () => {
  const first = await runOperation("first", 60);
  const second = await runOperation("second", 60);
  const third = await runOperation("third", 60);

  return [first, second, third];
});

await measure("concurrent", async () => {
  return Promise.all([
    runOperation("first", 60),
    runOperation("second", 60),
    runOperation("third", 60)
  ]);
});
```

## Verification

Run:

```bash
node src/part-2/concurrent-vs-sequential.js
```

Expected behavior:

```text
sequential: ... elapsedMilliseconds: approximately 180
concurrent: ... elapsedMilliseconds: approximately 60
```

Timing is approximate. The concurrent duration should be near the longest individual operation.

---

# Part 2.8: `Promise.allSettled()`

## The Target

We will collect both successful and failed results without stopping at the first rejection.

## The Concept

`Promise.allSettled()` is useful when every operation is independent and partial results are valuable.

It always fulfills with an array containing records like:

```js
{
  status: "fulfilled",
  value: ...
}
```

or:

```js
{
  status: "rejected",
  reason: ...
}
```

This is appropriate for a dashboard that displays available services even when one service is temporarily unavailable.

## Implementation

### `src/part-2/promise-all-settled.js`

```js
"use strict";

import { delay } from "./delay.js";

async function succeed(name, milliseconds) {
  await delay(milliseconds);
  return {
    name,
    status: "available"
  };
}

async function fail(name, milliseconds) {
  await delay(milliseconds);
  throw new Error(`${name} service unavailable`);
}

const results = await Promise.allSettled([
  succeed("metrics", 40),
  fail("health", 20),
  succeed("activity", 10)
]);

for (const result of results) {
  if (result.status === "fulfilled") {
    console.log("fulfilled:", result.value);
  } else {
    console.log("rejected:", result.reason.message);
  }
}
```

## Verification

Run:

```bash
node src/part-2/promise-all-settled.js
```

Expected output:

```text
fulfilled: { name: 'metrics', status: 'available' }
rejected: health service unavailable
fulfilled: { name: 'activity', status: 'available' }
```

Notice that the result order follows the input order even though the operations finish at different times.

---

# Part 2.9: `Promise.race()`

## The Target

We will use `Promise.race()` to implement a timeout.

## The Concept

`Promise.race()` settles as soon as the first input promise settles.

That means the first result may be:

- A successful value.
- A rejection.
- A timeout error.

It is useful for deadlines, but it has an important limitation: losing promises continue running unless they are explicitly cancelled.

We will first demonstrate the basic behavior, then add cancellation.

## Implementation

### `src/part-2/promise-race.js`

```js
"use strict";

import { delay } from "./delay.js";

function timeoutAfter(milliseconds) {
  return new Promise((_, reject) => {
    setTimeout(() => {
      reject(new Error(`operation exceeded ${milliseconds} ms`));
    }, milliseconds);
  });
}

async function run() {
  try {
    const result = await Promise.race([
      delay(100, "slow operation completed"),
      timeoutAfter(30)
    ]);

    console.log(result);
  } catch (error) {
    console.log("race rejected:", error.message);
  }
}

run();
```

## Verification

Run:

```bash
node src/part-2/promise-race.js
```

Expected output:

```text
race rejected: operation exceeded 30 ms
```

The 100-millisecond delay still exists in the background. It simply has no visible observer after the race rejects.

---

# Part 2.10: `Promise.any()`

## The Target

We will use `Promise.any()` to accept the first successful result.

## The Concept

`Promise.any()` is useful when several equivalent sources can satisfy the same requirement.

It:

- Fulfills when the first promise fulfills.
- Ignores earlier rejections if another promise succeeds.
- Rejects only when every promise rejects.
- Rejects with an `AggregateError`.

This is different from `Promise.race()`, which reacts to the first settlement, including rejection.

## Implementation

### `src/part-2/promise-any.js`

```js
"use strict";

import { delay } from "./delay.js";

async function failingReplica(name, milliseconds) {
  await delay(milliseconds);
  throw new Error(`${name} failed`);
}

async function healthyReplica(name, milliseconds) {
  await delay(milliseconds);
  return `${name} returned the configuration`;
}

async function demonstrateSuccess() {
  const result = await Promise.any([
    failingReplica("replica-a", 10),
    healthyReplica("replica-b", 30),
    healthyReplica("replica-c", 50)
  ]);

  console.log("first successful result:", result);
}

async function demonstrateAllFailure() {
  try {
    await Promise.any([
      failingReplica("replica-x", 10),
      failingReplica("replica-y", 20)
    ]);
  } catch (error) {
    console.log("error type:", error.name);
    console.log(
      "individual errors:",
      error.errors.map((individualError) => individualError.message)
    );
  }
}

await demonstrateSuccess();
await demonstrateAllFailure();
```

## Verification

Run:

```bash
node src/part-2/promise-any.js
```

Expected output:

```text
first successful result: replica-b returned the configuration
error type: AggregateError
individual errors: [ 'replica-x failed', 'replica-y failed' ]
```

---

# Part 2.11: Promise Combinator Decision Guide

| Requirement | Use |
|---|---|
| Every operation must succeed | `Promise.all()` |
| Keep successful and failed outcomes | `Promise.allSettled()` |
| First settled result wins | `Promise.race()` |
| First successful result wins | `Promise.any()` |

A practical example:

```js
const requiredData = await Promise.all([
  loadUser(),
  loadPermissions()
]);
```

Use:

```js
const dashboardSections = await Promise.allSettled([
  loadMetrics(),
  loadActivity(),
  loadNotifications()
]);
```

Use:

```js
const response = await Promise.race([
  request(),
  timeoutPromise()
]);
```

Use:

```js
const configuration = await Promise.any([
  loadFromPrimaryRegion(),
  loadFromSecondaryRegion(),
  loadFromCacheServer()
]);
```

The correct combinator depends on the business meaning of failure.

---

# Part 2.12: Cancellation with `AbortController`

## The Target

We will create an asynchronous operation that responds to cancellation.

## The Concept

JavaScript promises do not have a universal built-in cancellation method.

A promise can settle, but calling something like this does not exist:

```js
promise.cancel();
```

`AbortController` provides a standard cancellation signal.

It consists of:

- An `AbortController`, which owns the cancellation action.
- An `AbortSignal`, which is passed to the operation.
- An abort event or `signal.aborted` state.

The controller is like a stop button. The operation must be designed to listen to that stop button.

## Implementation

### `src/part-2/cancellation.js`

```js
"use strict";

function cancellableDelay(milliseconds, value, signal) {
  if (!Number.isFinite(milliseconds) || milliseconds < 0) {
    throw new RangeError("milliseconds must be a non-negative finite number");
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

      /*
       * AbortError is the conventional error name for cancellation. Callers
       * can distinguish cancellation from an ordinary service failure.
       */
      const error = new Error("operation was cancelled");
      error.name = "AbortError";
      reject(error);
    };

    if (signal.aborted) {
      handleAbort();
      return;
    }

    const timerId = setTimeout(resolveOnce, milliseconds);

    signal.addEventListener("abort", handleAbort, { once: true });
  });
}

async function run() {
  const controller = new AbortController();

  const operation = cancellableDelay(
    1_000,
    "operation completed",
    controller.signal
  );

  setTimeout(() => {
    controller.abort();
  }, 50);

  try {
    const result = await operation;
    console.log(result);
  } catch (error) {
    if (error.name === "AbortError") {
      console.log("operation cancelled intentionally");
      return;
    }

    throw error;
  }
}

run().catch((error) => {
  console.error("unexpected failure:", error);
  process.exitCode = 1;
});
```

## Verification

Run:

```bash
npm run cancellation
```

Expected output:

```text
operation cancelled intentionally
```

The one-second operation is stopped after approximately 50 milliseconds.

---

# Part 2.13: Cancellation-Safe Timeout Helper

## The Target

We will create a reusable timeout function that cancels the underlying operation instead of merely racing against it.

## The Concept

A timeout should ideally do two things:

1. Tell the caller that the deadline was exceeded.
2. Stop the underlying work if that work is no longer useful.

A raw `Promise.race()` accomplishes only the first part.

The following helper creates a child `AbortController`, forwards parent cancellation, and aborts the operation when the timeout expires.

## Implementation

### `src/part-2/timeout.js`

```js
"use strict";

function createAbortError(message) {
  const error = new Error(message);
  error.name = "AbortError";
  return error;
}

function createTimeoutError(milliseconds) {
  const error = new Error(`operation timed out after ${milliseconds} ms`);
  error.name = "TimeoutError";
  return error;
}

export async function withTimeout(operation, milliseconds, parentSignal) {
  if (typeof operation !== "function") {
    throw new TypeError("operation must be a function");
  }

  if (!Number.isFinite(milliseconds) || milliseconds <= 0) {
    throw new RangeError("milliseconds must be a positive finite number");
  }

  if (
    parentSignal !== undefined &&
    !(parentSignal instanceof AbortSignal)
  ) {
    throw new TypeError("parentSignal must be an AbortSignal");
  }

  const controller = new AbortController();
  let timeoutId;

  const abortFromParent = () => {
    controller.abort(parentSignal.reason ?? createAbortError("parent aborted"));
  };

  if (parentSignal) {
    if (parentSignal.aborted) {
      abortFromParent();
    } else {
      parentSignal.addEventListener("abort", abortFromParent, {
        once: true
      });
    }
  }

  timeoutId = setTimeout(() => {
    controller.abort(createTimeoutError(milliseconds));
  }, milliseconds);

  try {
    return await operation(controller.signal);
  } catch (error) {
    /*
     * If the timeout controller caused the abort, expose a TimeoutError.
     * If the parent caused it, preserve the parent reason where possible.
     */
    if (controller.signal.aborted) {
      const reason = controller.signal.reason;

      if (reason instanceof Error) {
        throw reason;
      }

      throw createAbortError("operation aborted");
    }

    throw error;
  } finally {
    clearTimeout(timeoutId);

    if (parentSignal) {
      parentSignal.removeEventListener("abort", abortFromParent);
    }
  }
}

export function cancellableDelay(milliseconds, value, signal) {
  if (!Number.isFinite(milliseconds) || milliseconds < 0) {
    throw new RangeError("milliseconds must be a non-negative finite number");
  }

  if (!(signal instanceof AbortSignal)) {
    throw new TypeError("signal must be an AbortSignal");
  }

  return new Promise((resolve, reject) => {
    let finished = false;

    const cleanup = () => {
      clearTimeout(timerId);
      signal.removeEventListener("abort", handleAbort);
    };

    const handleAbort = () => {
      if (finished) {
        return;
      }

      finished = true;
      cleanup();

      const reason = signal.reason;

      if (reason instanceof Error) {
        reject(reason);
      } else {
        reject(createAbortError("operation aborted"));
      }
    };

    const finish = () => {
      if (finished) {
        return;
      }

      finished = true;
      cleanup();
      resolve(value);
    };

    if (signal.aborted) {
      handleAbort();
      return;
    }

    const timerId = setTimeout(finish, milliseconds);

    signal.addEventListener("abort", handleAbort, { once: true });
  });
}

async function demonstrateTimeout() {
  try {
    await withTimeout(
      (signal) => cancellableDelay(1_000, "finished", signal),
      40
    );
  } catch (error) {
    console.log({
      name: error.name,
      message: error.message
    });
  }
}

async function demonstrateSuccess() {
  const result = await withTimeout(
    (signal) => cancellableDelay(20, "completed before deadline", signal),
    100
  );

  console.log(result);
}

await demonstrateTimeout();
await demonstrateSuccess();
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
  message: 'operation timed out after 40 ms'
}
completed before deadline
```

The operation is cancelled when the timeout occurs.

---

# Part 2.14: Simulating Independent Services

## The Target

We will create a reusable fake service for testing concurrency behavior.

## The Concept

Real network calls make tutorials harder to reproduce because network conditions vary.

A deterministic fake service lets us control:

- Completion time.
- Success or failure.
- Returned value.
- Cancellation.
- Logging.

This is similar to using a flight simulator before flying a real aircraft. We can safely test the control logic before introducing external systems.

## Implementation

### `src/part-2/fake-service.js`

```js
"use strict";

import { cancellableDelay } from "./timeout.js";

export function createFakeService({
  name,
  delayMilliseconds,
  result,
  failureMessage,
  logger = console
}) {
  if (typeof name !== "string" || name.trim() === "") {
    throw new TypeError("name must be a non-empty string");
  }

  if (
    !Number.isFinite(delayMilliseconds) ||
    delayMilliseconds < 0
  ) {
    throw new RangeError(
      "delayMilliseconds must be a non-negative finite number"
    );
  }

  if (failureMessage !== undefined && typeof failureMessage !== "string") {
    throw new TypeError("failureMessage must be a string when provided");
  }

  return Object.freeze({
    async request(signal) {
      logger.log(`${name}: request started`);

      await cancellableDelay(delayMilliseconds, undefined, signal);

      if (failureMessage) {
        const error = new Error(failureMessage);
        error.name = "ServiceError";
        throw error;
      }

      logger.log(`${name}: request completed`);
      return result;
    }
  });
}
```

## Verification

Run:

```bash
node --input-type=module <<'EOF'
import { createFakeService } from "./src/part-2/fake-service.js";

const service = createFakeService({
  name: "health",
  delayMilliseconds: 20,
  result: { healthy: true }
});

const result = await service.request(new AbortController().signal);

console.log(result);
EOF
```

Expected output:

```text
health: request started
health: request completed
{ healthy: true }
```

---

# Part 2.15: Build a Concurrent Dashboard Workflow

## The Target

We will combine:

- Independent services.
- `Promise.allSettled()`.
- Cancellation.
- Partial results.
- Explicit status classification.

## The Concept

A dashboard usually should not fail completely because one optional panel fails.

Instead, the workflow should return a structured result:

```js
{
  metrics: { status: "fulfilled", value: ... },
  health: { status: "rejected", reason: ... },
  activity: { status: "fulfilled", value: ... }
}
```

This lets the UI render available data and show an error only where necessary.

## Implementation

### `src/part-2/async-workflow.js`

```js
"use strict";

import { createFakeService } from "./fake-service.js";
import { withTimeout } from "./timeout.js";

function createDashboardServices() {
  return {
    metrics: createFakeService({
      name: "metrics",
      delayMilliseconds: 60,
      result: {
        requestsPerSecond: 125,
        errorRate: 0.01
      }
    }),

    health: createFakeService({
      name: "health",
      delayMilliseconds: 25,
      result: {
        status: "healthy",
        checkedAt: new Date().toISOString()
      }
    }),

    activity: createFakeService({
      name: "activity",
      delayMilliseconds: 40,
      failureMessage: "activity service is temporarily unavailable"
    })
  };
}

function classifySettledResult(result) {
  if (result.status === "fulfilled") {
    return {
      status: "available",
      data: result.value
    };
  }

  if (result.reason?.name === "AbortError") {
    return {
      status: "cancelled",
      error: result.reason.message
    };
  }

  return {
    status: "unavailable",
    error: result.reason instanceof Error
      ? result.reason.message
      : String(result.reason)
  };
}

async function loadDashboard({ services, signal }) {
  const serviceEntries = Object.entries(services);

  const settledResults = await Promise.allSettled(
    serviceEntries.map(async ([serviceName, service]) => {
      const data = await withTimeout(
        (requestSignal) => service.request(requestSignal),
        200,
        signal
      );

      return {
        serviceName,
        data
      };
    })
  );

  return Object.fromEntries(
    serviceEntries.map(([serviceName], index) => {
      const result = settledResults[index];

      if (result.status === "fulfilled") {
        return [
          serviceName,
          classifySettledResult({
            status: "fulfilled",
            value: result.value.data
          })
        ];
      }

      return [serviceName, classifySettledResult(result)];
    })
  );
}

async function run() {
  const controller = new AbortController();
  const services = createDashboardServices();

  const dashboard = await loadDashboard({
    services,
    signal: controller.signal
  });

  console.log("\nDashboard result:");
  console.dir(dashboard, { depth: null });
}

run().catch((error) => {
  console.error("dashboard workflow failed:", error);
  process.exitCode = 1;
});
```

## Verification

Run:

```bash
npm run workflow
```

Expected behavior:

- `metrics` is available.
- `health` is available.
- `activity` is unavailable.
- The entire workflow still completes.

Output will resemble:

```text
metrics: request started
health: request started
activity: request started
health: request completed
metrics: request completed

Dashboard result:
{
  metrics: {
    status: 'available',
    data: { requestsPerSecond: 125, errorRate: 0.01 }
  },
  health: {
    status: 'available',
    data: { status: 'healthy', checkedAt: '...' }
  },
  activity: {
    status: 'unavailable',
    error: 'activity service is temporarily unavailable'
  }
}
```

---

# Part 2.16: Cancellation During a Dashboard Refresh

## The Target

We will cancel a dashboard refresh before all services finish.

## The Concept

Cancellation is especially useful when a request becomes obsolete.

Examples:

- A user changes a filter before the previous search finishes.
- A user navigates away from a page.
- A newer refresh supersedes an older refresh.
- A request exceeds its deadline.
- The application is shutting down.

The caller owns the controller because the caller owns the decision to stop the work.

## Implementation

### `src/part-2/cancel-dashboard.js`

```js
"use strict";

import { createFakeService } from "./fake-service.js";
import { withTimeout } from "./timeout.js";

const services = {
  metrics: createFakeService({
    name: "metrics",
    delayMilliseconds: 300,
    result: { requestsPerSecond: 125 }
  }),

  health: createFakeService({
    name: "health",
    delayMilliseconds: 300,
    result: { status: "healthy" }
  }),

  activity: createFakeService({
    name: "activity",
    delayMilliseconds: 300,
    result: { activeUsers: 42 }
  })
};

async function refreshDashboard(signal) {
  const entries = Object.entries(services);

  const results = await Promise.allSettled(
    entries.map(async ([name, service]) => {
      const value = await withTimeout(
        (requestSignal) => service.request(requestSignal),
        1_000,
        signal
      );

      return [name, value];
    })
  );

  return Object.fromEntries(
    results.map((result, index) => {
      const serviceName = entries[index][0];

      if (result.status === "fulfilled") {
        return [serviceName, { status: "available", value: result.value[1] }];
      }

      return [
        serviceName,
        {
          status: result.reason?.name === "AbortError"
            ? "cancelled"
            : "failed",
          error: result.reason?.message ?? String(result.reason)
        }
      ];
    })
  );
}

const controller = new AbortController();

const refreshPromise = refreshDashboard(controller.signal);

setTimeout(() => {
  console.log("Cancelling stale dashboard refresh");
  controller.abort();
}, 50);

const result = await refreshPromise;

console.dir(result, { depth: null });
```

## Verification

Run:

```bash
node src/part-2/cancel-dashboard.js
```

Expected output resembles:

```text
metrics: request started
health: request started
activity: request started
Cancelling stale dashboard refresh
{
  metrics: { status: 'cancelled', error: '...' },
  health: { status: 'cancelled', error: '...' },
  activity: { status: 'cancelled', error: '...' }
}
```

The important result is that the long-running operations do not continue for their full 300 milliseconds.

---

# Part 2.17: Preventing Stale Search Results

## The Target

We will implement a latest-request-wins pattern.

## The Concept

Suppose a user types:

```text
j
ja
jav
java
```

Four searches may start. The result for `j` might arrive after the result for `java`.

If the application displays every response when it arrives, an older result can overwrite a newer result.

A common solution is:

1. Abort the previous request.
2. Create a new controller for the latest request.
3. Ignore expected cancellation errors.
4. Display only the newest successful result.

## Implementation

### `src/part-2/latest-request-wins.js`

```js
"use strict";

import { cancellableDelay } from "./timeout.js";

function search(query, signal) {
  const normalizedQuery = query.trim();

  return cancellableDelay(
    normalizedQuery.length * 40,
    {
      query: normalizedQuery,
      results: [`result for "${normalizedQuery}"`]
    },
    signal
  );
}

function createSearchManager() {
  let activeController = null;

  return {
    async run(query) {
      if (activeController) {
        activeController.abort();
      }

      activeController = new AbortController();
      const currentController = activeController;

      try {
        const result = await search(query, currentController.signal);

        /*
         * A request may complete after another request has started. Check that
         * this is still the active controller before publishing the result.
         */
        if (currentController !== activeController) {
          return {
            status: "ignored",
            reason: "result was superseded"
          };
        }

        return {
          status: "display",
          result
        };
      } catch (error) {
        if (error.name === "AbortError") {
          return {
            status: "cancelled"
          };
        }

        throw error;
      }
    }
  };
}

const manager = createSearchManager();

const firstSearch = manager.run("j");

setTimeout(() => {
  void manager.run("javascript").then((result) => {
    console.log("latest search:", result);
  });
}, 10);

console.log("old search:", await firstSearch);
```

## Verification

Run:

```bash
node src/part-2/latest-request-wins.js
```

Expected behavior:

```text
old search: { status: 'cancelled' }
latest search: {
  status: 'display',
  result: {
    query: 'javascript',
    results: [ 'result for "javascript"' ]
  }
}
```

---

# Part 2.18: Reference — Promise Error Handling

## Rejected Promise

```js
const promise = Promise.reject(new Error("failed"));

promise.catch((error) => {
  console.error(error.message);
});
```

## `try`/`catch` with `await`

```js
try {
  const value = await operation();
  console.log(value);
} catch (error) {
  console.error("operation failed:", error);
}
```

## Always-Cleanup with `finally`

```js
let loading = true;

try {
  await operation();
} catch (error) {
  console.error(error);
} finally {
  loading = false;
}
```

`finally` is the correct place for cleanup that must happen whether the operation succeeds, fails, or is cancelled.

---

# Part 2.19: Reference — Why `await` Does Not Block the Whole Runtime

Consider:

```js
async function run() {
  console.log("before await");

  await Promise.resolve();

  console.log("after await");
}

run();

console.log("outside");
```

Output:

```text
before await
outside
after await
```

Calling `run()` begins synchronously. At `await`, the function pauses and returns a promise. The remaining function body is scheduled as a microtask.

`await` pauses the current async function. It does not freeze the entire JavaScript runtime.

---

# Part 2.20: Reference — Concurrency Versus Parallelism

**Concurrency** means managing multiple tasks that overlap in time.

**Parallelism** means multiple tasks execute at the same physical moment, usually on different CPU cores or workers.

This code expresses concurrency:

```js
await Promise.all([
  fetch("/metrics"),
  fetch("/health")
]);
```

The JavaScript thread coordinates both requests. The network operations progress independently.

CPU-heavy JavaScript still occupies the main thread:

```js
function expensiveCalculation() {
  let total = 0;

  for (let index = 0; index < 1_000_000_000; index += 1) {
    total += index;
  }

  return total;
}
```

Promises do not automatically move CPU-heavy work to another thread. For that, use appropriate worker mechanisms, such as:

- Web Workers in browsers.
- Worker Threads in Node.js.
- Separate processes.
- External compute services.

---

# Part 2.21: Reference — `AbortSignal` Rules

## Pass the Signal Downward

```js
async function loadData(signal) {
  return fetch("https://example.com/data", { signal });
}
```

Do not create a hidden controller inside every low-level function unless that function owns the lifecycle.

## Preserve Cancellation

```js
try {
  await operation(signal);
} catch (error) {
  if (error.name === "AbortError") {
    throw error;
  }

  throw new Error("operation failed", { cause: error });
}
```

Do not convert cancellation into an ordinary user-visible failure without a reason.

## Remove Listeners

If adding an abort listener manually:

```js
signal.addEventListener("abort", handleAbort, { once: true });
```

Also remove it during normal completion:

```js
signal.removeEventListener("abort", handleAbort);
```

The `{ once: true }` option prevents repeated abort handling, while explicit cleanup prevents a completed operation from retaining unnecessary references.

---

# Part 2.22: Complete Verification Checklist

Run the following commands:

```bash
node src/part-2/synchronous-first.js
npm run event-loop
npm run microtasks
node src/part-2/promise-all.js
node src/part-2/concurrent-vs-sequential.js
node src/part-2/promise-all-settled.js
node src/part-2/promise-race.js
node src/part-2/promise-any.js
npm run cancellation
npm run timeout
npm run workflow
node src/part-2/cancel-dashboard.js
node src/part-2/latest-request-wins.js
```

Confirm that:

- Synchronous statements run before asynchronous callbacks.
- Microtasks run before timer tasks.
- Nested microtasks are drained before later tasks.
- An unbounded microtask chain can delay timers.
- `Promise.all()` preserves input order.
- Independent operations complete concurrently.
- `Promise.allSettled()` preserves partial results.
- `Promise.race()` reacts to the first settlement.
- `Promise.any()` waits for the first fulfillment.
- Cancellation produces an identifiable `AbortError`.
- A timeout cancels the underlying operation.
- Dashboard sections can succeed or fail independently.
- A stale request can be cancelled before it overwrites newer data.

---

## Part 2 Summary

The most important ideas from this part are:

### The event loop

```text
Synchronous code
        │
        ▼
Microtasks
        │
        ▼
Later tasks such as timers and I/O
```

### Promise combinators

```text
all         → every operation required
allSettled  → collect every outcome
race        → first settled operation
any         → first successful operation
```

### Cancellation

```text
Caller creates AbortController
        │
        ▼
Caller passes AbortSignal
        │
        ▼
Operation listens for abort
        │
        ▼
Caller aborts obsolete work
```

### Concurrency design

Good asynchronous code answers:

- Which operations are independent?
- Should one failure stop the entire workflow?
- Can the work become obsolete?
- Who owns cancellation?
- What happens at the deadline?
- Are partial results useful?
- Can an older result overwrite a newer one?

The next part will use these runtime foundations to build predictable data transformations, functional composition, currying, immutability, and reactive state with `Proxy` and `Reflect`.
